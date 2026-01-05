<#
.SYNOPSIS
    Splits a large Lua file into smaller individual Lua files based on specific delimiters,
    or builds a single Lua file from previously split files.

.DESCRIPTION
    This script has two primary modes of operation:

    1.  **Splitting Mode (Default):**
        Reads a single large Lua file. Any content before the first file delimiter
        (e.g., a header comment block) will be saved as '_header.lua'.
        Subsequent smaller Lua files are identified by a start delimiter
        (e.g., "-----------------[[ Filename.lua ]]-----------------") and an end delimiter
        (e.g., "-----------------[[ END OF Filename.lua ]]-----------------").
        For each identified block, the script extracts the content (including delimiters)
        and saves it to a new .lua file with the corresponding filename in a specified
        output directory. Additionally, it creates a '_export_registry.txt' file in the
        same output directory, listing '_header.lua' (if present) followed by the names
        of the extracted files in the order they appeared in the original file.

    2.  **Building Mode (-Build parameter):**
        Reads the '_export_registry.txt' file from the specified OutputDirectory to determine
        the order of files. It then concatenates the content of these individual Lua files
        (which are expected to already contain their respective start and end delimiters,
        and '_header.lua' if it exists) into a single, combined Lua file. The output file
        will be named based on the original input file (e.g., 'original_file_rebuilt.lua').

.PARAMETER InputFilePath
    In splitting mode, the full path to the large Lua file that needs to be split.
    In building mode, this is used to derive the name of the rebuilt output file.
    If only a filename is provided, the script will look for it in the current directory.
    If not provided, the script will prompt the user to enter the filename (assumed to be in the current directory).

.PARAMETER OutputDirectory
    The name of the directory where the split Lua files and the registry file will be saved
    in splitting mode, or where the individual Lua files are read from in building mode.
    This directory will be created if it does not exist in splitting mode. Defaults to "import".

.PARAMETER Build
    A switch parameter. If present, the script will operate in building mode,
    combining files based on the '_export_registry.txt' file.
    If omitted, the script will operate in splitting mode.

.EXAMPLE
    To run the script, save it as a .ps1 file (e.g., build.ps1) and then execute it
    from PowerShell:

    # Example 1: Split a file (default mode) with a specific input file (full path)
    .\build.ps1 -InputFilePath "C:\MyProject\CTLD.lua"

    # Example 2: Split a file (default mode) with a filename (assumes file is in the current directory)
    .\build.ps1 -InputFilePath "CTLD.lua"

    # Example 3: Split a file (default mode) without parameters (will prompt for filename)
    .\build.ps1

    # Example 4: Split a file with a custom output directory
    .\build.ps1 -InputFilePath "CTLD.lua" -OutputDirectory "ExtractedLua"

    # Example 5: Build a combined file from previously split files
    # Assumes 'CTLD.lua' was the original input file for splitting,
    # and the split files are in 'import'.
    # The output will be 'CTLD_rebuilt.lua' in the script's directory.
    .\build.ps1 -InputFilePath "CTLD.lua" -Build

    # Example 6: Build a combined file from previously split files in a custom directory
    # Assumes 'CTLD.lua' was the original input file, and split files are in 'ExtractedLua'.
    .\build.ps1 -InputFilePath "CTLD.lua" -OutputDirectory "ExtractedLua" -Build

.NOTES
    - The script expects the delimiters to be exactly as shown in your example:
      "-----------------[[ Filename.lua ]]-----------------"
      "-----------------[[ END OF Filename.lua ]]-----------------"
    - In splitting mode, if a start tag is found without a corresponding end tag before
      another start tag or the end of the file, the content will still be saved under
      the last identified filename.
    - In splitting mode, mismatched end tags (e.g., "END OF FileA.lua" when currently
      processing "FileB.lua") will be warned about but will not stop the current file's processing.
#>

param(
    [string]$InputFilePath = "", # Make it optional by providing a default empty string
    [string]$OutputDirectory = "import",
    [switch]$Build # New parameter for build mode
)

# --- Configuration ---
$registryFileName = "_export_registry.txt" # Renamed from file_order.txt
$headerFileName = "_header.lua" # New file name for the initial header block
# Regex pattern to match the start delimiter and capture the filename
# This pattern ensures the filename does not contain "END OF"
$startDelimiterPattern = "^-----------------\[\[\s*(?<filename>(?:(?!END OF).)*?\.lua)\s*\]\]-----------------$"
# Regex pattern to match the end delimiter and capture the filename
$endDelimiterPattern = "^-----------------\[\[\s*END OF\s*(?<filename>.*?\.lua)\s*\]\]-----------------$"

# --- Input Validation ---
# Determine the directory where the script is running
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# If InputFilePath is not provided as a parameter, prompt the user for the filename
if ([string]::IsNullOrEmpty($InputFilePath)) {
    $promptMessage = "Please enter the name of the large Lua file (e.g., pretense_compiled.lua). It will be looked for in the current directory."
    if ($Build) {
        $promptMessage = "Please enter the original name of the large Lua file that was split (e.g., pretense_compiled.lua). This is used for naming the rebuilt file."
    }
    $fileNameOnly = Read-Host $promptMessage
    # Construct the full path using the script's directory and the provided filename
    $InputFilePath = Join-Path $ScriptDirectory $fileNameOnly
}
# If InputFilePath was provided, but it's just a filename (no directory separators),
# assume it's in the current script's directory.
elseif (-not (Test-Path $InputFilePath -PathType Leaf) -and -not $InputFilePath.Contains('\') -and -not $InputFilePath.Contains('/')) {
    $InputFilePath = Join-Path $ScriptDirectory $InputFilePath
}

# In splitting mode, check if the specified input file exists
if (-not $Build -and -not (Test-Path $InputFilePath -PathType Leaf)) {
    Write-Error "Error: In splitting mode, the specified input file '$InputFilePath' does not exist or is not a file."
    exit 1 # Exit the script with an error code
}

# --- Setup Output Directory ---
try {
    # In splitting mode, create the output directory if it doesn't exist
    if (-not $Build -and -not (Test-Path $OutputDirectory -PathType Container)) {
        Write-Host "Creating output directory: $OutputDirectory"
        New-Item -ItemType Directory -Path $OutputDirectory | Out-Null # Out-Null suppresses default output
    }
    # In building mode, ensure the output directory (where split files reside) exists
    elseif ($Build -and -not (Test-Path $OutputDirectory -PathType Container)) {
        Write-Error "Error: In building mode, the specified OutputDirectory '$OutputDirectory' does not exist. It should contain the split Lua files and the registry."
        exit 1
    }
} catch {
    Write-Error "Error setting up output directory '$OutputDirectory': $($_.Exception.Message)"
    exit 1 # Exit the script with an error code
}

# --- Helper function to save content ---
function Save-LuaFileContent {
    param(
        [string]$FileName,
        [System.Collections.ArrayList]$Content,
        [string]$BaseOutputDirectory
    )
    # Construct the full output path for the file
    $fullOutputPath = Join-Path $BaseOutputDirectory $FileName

    # Get the directory part of the full output path
    $fileDirectory = Split-Path -Parent $fullOutputPath

    # Create the directory if it doesn't exist (including nested directories)
    try {
        if (-not (Test-Path $fileDirectory -PathType Container)) {
            Write-Host "  Creating subdirectory: '$fileDirectory'"
            New-Item -ItemType Directory -Path $fileDirectory -Force | Out-Null
        }
    } catch {
        Write-Error "Error creating subdirectory '$fileDirectory': $($_.Exception.Message)"
        throw # Re-throw the exception to stop script execution if directory creation fails
    }

    # Write the content to the file
    Write-Host "  Saving content to: '$fullOutputPath'"
    [System.IO.File]::WriteAllLines($fullOutputPath, $Content)
}

# --- Main Logic ---
if ($Build) {
    Write-Host "Starting to build combined Lua file..."

    $registryFilePath = Join-Path $OutputDirectory $registryFileName
    if (-not (Test-Path $registryFilePath -PathType Leaf)) {
        Write-Error "Error: Registry file '$registryFilePath' not found. Cannot build combined file."
        exit 1
    }

    # Determine the name for the rebuilt file
    $originalFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($InputFilePath)
    $rebuiltFileName = "${originalFileNameWithoutExtension}_rebuilt.lua"
    $rebuiltFilePath = Join-Path $ScriptDirectory $rebuiltFileName

    $combinedContent = [System.Collections.ArrayList]::new()

    Write-Host "Reading file order from: '$registryFilePath'"
    $fileNamesToBuild = Get-Content $registryFilePath

    # Check for and prepend header if it exists in the registry and is the first entry
    if ($fileNamesToBuild.Count -gt 0 -and $fileNamesToBuild[0] -eq $headerFileName) {
        $headerFilePath = Join-Path $OutputDirectory $headerFileName
        if (Test-Path $headerFilePath -PathType Leaf) {
            Write-Host "  Adding header file '$headerFileName' to combined file."
            Get-Content $headerFilePath | ForEach-Object { $combinedContent.Add($_) | Out-Null }
        } else {
            Write-Warning "  Warning: Header file '$headerFilePath' listed in registry but not found. Skipping."
        }
        # Remove header from the list to process remaining files
        $fileNamesToBuild = $fileNamesToBuild | Select-Object -Skip 1
    }

    foreach ($fileName in $fileNamesToBuild) {
        $individualFilePath = Join-Path $OutputDirectory $fileName
        if (Test-Path $individualFilePath -PathType Leaf) {
            Write-Host "  Adding '$fileName' to combined file."
            # Read content and add to buffer. The split files already contain delimiters.
            Get-Content $individualFilePath | ForEach-Object { $combinedContent.Add($_) | Out-Null }
        } else {
            Write-Warning "  Warning: Individual file '$individualFilePath' not found as listed in registry. Skipping."
        }
    }

    try {
        Write-Host "Writing combined file to: '$rebuiltFilePath'"
        [System.IO.File]::WriteAllLines($rebuiltFilePath, $combinedContent)
        Write-Host "Build finished successfully. Combined file is: '$rebuiltFilePath'."
    } catch {
        Write-Error "An error occurred while writing the combined file: $($_.Exception.Message)"
        exit 1
    }

} else { # Splitting Mode
    Write-Host "Starting to process '$InputFilePath' (Splitting Mode)..."

    # --- Initialization for Splitting ---
    $isCapturing = $false
    $currentFileName = ""
    $contentBuffer = [System.Collections.ArrayList]::new()
    $fileOrder = [System.Collections.ArrayList]::new()
    $headerBuffer = [System.Collections.ArrayList]::new() # New buffer for header
    $isHeaderCapturing = $true # New flag for header capturing

    try {
        # Read the input file line by line
        Get-Content $InputFilePath | ForEach-Object {
            $line = $_ # Current line being processed

            if ($isHeaderCapturing) {
                # Check if this line is the start of the first actual Lua file
                if ($line -match $startDelimiterPattern) {
                    $isHeaderCapturing = $false # Stop header capturing

                    # If there's content in the header buffer, save it as a special file
                    if ($headerBuffer.Count -gt 0) {
                        Save-LuaFileContent -FileName $headerFileName -Content $headerBuffer -BaseOutputDirectory $OutputDirectory
                        $fileOrder.Add($headerFileName) | Out-Null # Add header file to the order list
                    }

                    # Now, proceed with the first actual Lua file
                    $currentFileName = $Matches.filename # Extract filename from the regex match
                    $fileOrder.Add($currentFileName) | Out-Null # Add the filename to the order list
                    $isCapturing = $true # Start capturing content for the first file
                    $contentBuffer.Clear() # Clear the buffer for the new file
                    $contentBuffer.Add($line) | Out-Null # Add the start delimiter line to the buffer
                    Write-Host "  Found start of: '$currentFileName'"
                } else {
                    # Still in header, add line to header buffer
                    $headerBuffer.Add($line) | Out-Null
                }
            }
            # This 'else if' block handles subsequent file starts and content, only if not in header capturing mode
            elseif ($line -match $startDelimiterPattern) {
                # If we were already capturing content for a previous file, it means that
                # file block was not properly ended. Save its buffered content.
                if ($isCapturing -and $currentFileName) {
                    Write-Warning "  Warning: Found new start tag for '$Matches.filename' before end tag for '$currentFileName'. Saving content for '$currentFileName'."
                    Save-LuaFileContent -FileName $currentFileName -Content $contentBuffer -BaseOutputDirectory $OutputDirectory
                }

                $currentFileName = $Matches.filename # Extract filename from the regex match
                $fileOrder.Add($currentFileName) | Out-Null # Add the filename to the order list
                $isCapturing = $true # Start capturing content
                $contentBuffer.Clear() # Clear the buffer for the new file
                $contentBuffer.Add($line) | Out-Null # Add the start delimiter line to the buffer
                Write-Host "  Found start of: '$currentFileName'"
            }
            # Check if the current line matches the end delimiter pattern
            elseif ($line -match $endDelimiterPattern) {
                $endFileName = $Matches.filename # Extract filename from the end tag
                # If we are capturing and the end tag matches the current file's name
                if ($isCapturing -and $currentFileName -eq $endFileName) {
                    $contentBuffer.Add($line) | Out-Null # Add the end delimiter line to the buffer
                    Save-LuaFileContent -FileName $currentFileName -Content $contentBuffer -BaseOutputDirectory $OutputDirectory
                    $isCapturing = $false # Stop capturing
                    $contentBuffer.Clear() # Clear the buffer
                }
                # If we are capturing but the end tag filename doesn't match the current file
                elseif ($isCapturing -and $currentFileName -ne $endFileName) {
                    Write-Warning "  Warning: Mismatched END OF tag found. Expected '$currentFileName', got '$endFileName'. Continuing capture for '$currentFileName'."
                    # In this case, we assume the end tag was misplaced and continue capturing for the current file.
                    $contentBuffer.Add($line) | Out-Null # Add the mismatched end tag to the buffer as regular content
                }
                # If an end tag is found when not capturing any file block
                else {
                    Write-Warning "  Warning: Found END OF tag ('$endFileName') while not actively capturing a file block. Skipping this line."
                }
            }
            # If we are currently capturing and the line is not a delimiter, add it to the buffer
            elseif ($isCapturing) {
                $contentBuffer.Add($line) | Out-Null
            }
        }

        # --- Final Check for splitting mode: Handle any remaining content (including header) ---
        # If header was still being captured at EOF
        if ($isHeaderCapturing -and $headerBuffer.Count -gt 0) {
            Write-Warning "  Warning: Input file ended while still capturing header content. Saving remaining header."
            Save-LuaFileContent -FileName $headerFileName -Content $headerBuffer -BaseOutputDirectory $OutputDirectory
            $fileOrder.Add($headerFileName) | Out-Null # Add header file to the order list
        }
        # If a regular file was still being captured at EOF
        elseif ($isCapturing -and $currentFileName) {
            Write-Warning "  Warning: Input file ended while still capturing content for '$currentFileName'. Saving remaining content."
            Save-LuaFileContent -FileName $currentFileName -Content $contentBuffer -BaseOutputDirectory $OutputDirectory
        }

        # --- Write the file order list ---
        # Ensure header is always first if it exists in the fileOrder list
        if ($fileOrder.Contains($headerFileName)) {
            $fileOrder.Remove($headerFileName) | Out-Null
            $fileOrder.Insert(0, $headerFileName) | Out-Null
        }
        $registryFilePath = Join-Path $OutputDirectory $registryFileName
        Write-Host "Writing file order to: '$registryFilePath'"
        $fileOrder | Set-Content $registryFilePath # Write the list of filenames to the order file

        Write-Host "Script finished successfully. Split files and registry list are in '$OutputDirectory'."

    } catch {
        Write-Error "An unexpected error occurred during file processing: $($_.Exception.Message)"
        exit 1 # Exit the script with an error code
    }
}
