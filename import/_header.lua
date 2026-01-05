--[[ ! IMPORTANT : You must must use the version of MIST supplied in the CTLD pack to correctly manage dynamic spwans

        Combat Troop and Logistics Drop

        Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
        without requiring external mods.

        Supports all of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

        Supports deployment of Auto Lasing JTAC to the field

        See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

        Contributors:
                - FullGas1 - https://github.com/FullGas1 (i18n concept, FR and SP translations)
                - Rex (VEAF) - https://github.com/RexAttaque (code, testing, JTAC)
                - Zip (VEAF) - https://github.com/davidp57 (project management, code, testing)
                - Steggles - https://github.com/Bob7heBuilder
                - mvee - https://github.com/mvee
                - jmontleon - https://github.com/jmontleon
                - emilianomolina - https://github.com/emilianomolina
                - davidp57 - https://github.com/veaf
                - Queton1-1 - https://github.com/Queton1-1
                - Proxy404 - https://github.com/Proxy404
                - atcz - https://github.com/atcz
                - marcos2221- https://github.com/marcos2221

        Add [issues](https://github.com/ciribob/DCS-CTLD/issues) to the GitHub repository if you want to report a bug or suggest a new feature.

        Contact Zip [on Discord](https://discordapp.com/users/421317390807203850) or [on Github](https://github.com/davidp57) if you need help or want to have a friendly chat.

        Send beers (or kind messages) to Ciribob [on Discord](https://discordapp.com/users/204712384747536384), he's the reason we have CTLD ^^
 ]]

if not ctld then  -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    trigger.action.outText(
    "\n\n** HEY MISSION-DESIGNER! **\n\nCTLD-i18n has not been loaded!\n\nMake sure CTLD-i18n is loaded\n*before* running this script!\n\nIt contains all the translations!\n",
        10)
    ctld = {}     -- DONT REMOVE!
end

--- Identifier. All output in DCS.log will start with this.
ctld.Id = "CTLD - "

--- Version.
ctld.Version = "1.6.1"

-- To add debugging messages to dcs.log, change the following log levels to `true`; `Debug` is less detailed than `Trace`
ctld.Debug = false
ctld.Trace = false

ctld.dontInitialize = false -- if true, ctld.initialize() will not run; instead, you'll have to run it from your own code - it's useful when you want to override some functions/parameters before the initialization takes place

