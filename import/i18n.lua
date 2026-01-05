-----------------[[ i18n.lua ]]-----------------

-- If you want to change the language replace "en" with the language you want to use

--========    ENGLISH - the reference ===========================================================================
ctld.i18n_lang = "en"
--========    FRENCH - FRANCAIS =================================================================================
--ctld.i18n_lang = "fr"
--======    SPANISH : ESPAÃ‘OL ====================================================================================
--ctld.i18n_lang = "es"
--======    Korean : í•œêµ­ì–´ ====================================================================================
--ctld.i18n_lang = "ko"

if not ctld.i18n then  -- should be defined first by CTLD-i18n.lua, but just in case it's an old mission, let's keep it here
    ctld.i18n = {}     -- DONT REMOVE!
end

-- This is the default language
-- If a string is not found in the current language then it will default to this language
-- Note that no translation is provided for this language (obviously) but that we'll maintain this table to help the translators.
ctld.i18n["en"] = {}
ctld.i18n["en"].translation_version = "1.6"            -- make sure that all the translations are compatible with this version of the english language texts
local lang = "en"; env.info(string.format("I - CTLD.i18n_translate: Loading %s language version %s", lang,
    tostring(ctld.i18n[lang].translation_version)))

--- groups names
ctld.i18n["en"]["Standard Group"] = ""
ctld.i18n["en"]["Anti Air"] = ""
ctld.i18n["en"]["Anti Tank"] = ""
ctld.i18n["en"]["Mortar Squad"] = ""
ctld.i18n["en"]["JTAC Group"] = ""
ctld.i18n["en"]["Single JTAC"] = ""
ctld.i18n["en"]["2x - Standard Groups"] = ""
ctld.i18n["en"]["2x - Anti Air"] = ""
ctld.i18n["en"]["2x - Anti Tank"] = ""
ctld.i18n["en"]["2x - Standard Groups + 2x Mortar"] = ""
ctld.i18n["en"]["3x - Standard Groups"] = ""
ctld.i18n["en"]["3x - Anti Air"] = ""
ctld.i18n["en"]["3x - Anti Tank"] = ""
ctld.i18n["en"]["3x - Mortar Squad"] = ""
ctld.i18n["en"]["5x - Mortar Squad"] = ""
ctld.i18n["en"]["Mortar Squad Red"] = ""

--- crates names
ctld.i18n["en"]["Humvee - MG"] = ""
ctld.i18n["en"]["Humvee - TOW"] = ""
ctld.i18n["en"]["Light Tank - MRAP"] = ""
ctld.i18n["en"]["Med Tank - LAV-25"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams"] = ""
ctld.i18n["en"]["BTR-D"] = ""
ctld.i18n["en"]["BRDM-2"] = ""
ctld.i18n["en"]["Hummer - JTAC"] = ""
ctld.i18n["en"]["M-818 Ammo Truck"] = ""
ctld.i18n["en"]["M-978 Tanker"] = ""
ctld.i18n["en"]["SKP-11 - JTAC"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck"] = ""
ctld.i18n["en"]["KAMAZ Ammo Truck"] = ""
ctld.i18n["en"]["EWR Radar"] = ""
ctld.i18n["en"]["FOB Crate - Small"] = ""
ctld.i18n["en"]["MQ-9 Repear - JTAC"] = ""
ctld.i18n["en"]["RQ-1A Predator - JTAC"] = ""
ctld.i18n["en"]["MLRS"] = ""
ctld.i18n["en"]["SpGH DANA"] = ""
ctld.i18n["en"]["T155 Firtina"] = ""
ctld.i18n["en"]["Howitzer"] = ""
ctld.i18n["en"]["SPH 2S19 Msta"] = ""
ctld.i18n["en"]["M1097 Avenger"] = ""
ctld.i18n["en"]["M48 Chaparral"] = ""
ctld.i18n["en"]["Roland ADS"] = ""
ctld.i18n["en"]["Gepard AAA"] = ""
ctld.i18n["en"]["LPWS C-RAM"] = ""
ctld.i18n["en"]["9K33 Osa"] = ""
ctld.i18n["en"]["9P31 Strela-1"] = ""
ctld.i18n["en"]["9K35M Strela-10"] = ""
ctld.i18n["en"]["9K331 Tor"] = ""
ctld.i18n["en"]["2K22 Tunguska"] = ""
ctld.i18n["en"]["HAWK Launcher"] = ""
ctld.i18n["en"]["HAWK Search Radar"] = ""
ctld.i18n["en"]["HAWK Track Radar"] = ""
ctld.i18n["en"]["HAWK PCP"] = ""
ctld.i18n["en"]["HAWK CWAR"] = ""
ctld.i18n["en"]["HAWK Repair"] = ""
ctld.i18n["en"]["NASAMS Launcher 120C"] = ""
ctld.i18n["en"]["NASAMS Search/Track Radar"] = ""
ctld.i18n["en"]["NASAMS Command Post"] = ""
ctld.i18n["en"]["NASAMS Repair"] = ""
ctld.i18n["en"]["KUB Launcher"] = ""
ctld.i18n["en"]["KUB Radar"] = ""
ctld.i18n["en"]["KUB Repair"] = ""
ctld.i18n["en"]["BUK Launcher"] = ""
ctld.i18n["en"]["BUK Search Radar"] = ""
ctld.i18n["en"]["BUK CC Radar"] = ""
ctld.i18n["en"]["BUK Repair"] = ""
ctld.i18n["en"]["Patriot Launcher"] = ""
ctld.i18n["en"]["Patriot Radar"] = ""
ctld.i18n["en"]["Patriot ECS"] = ""
ctld.i18n["en"]["Patriot ICC"] = ""
ctld.i18n["en"]["Patriot EPP"] = ""
ctld.i18n["en"]["Patriot AMG (optional)"] = ""
ctld.i18n["en"]["Patriot Repair"] = ""
ctld.i18n["en"]["S-300 Grumble TEL C"] = ""
ctld.i18n["en"]["S-300 Grumble Flap Lid-A TR"] = ""
ctld.i18n["en"]["S-300 Grumble Clam Shell SR"] = ""
ctld.i18n["en"]["S-300 Grumble Big Bird SR"] = ""
ctld.i18n["en"]["S-300 Grumble C2"] = ""
ctld.i18n["en"]["S-300 Repair"] = ""
ctld.i18n["en"]["Humvee - TOW - All crates"] = ""
ctld.i18n["en"]["Light Tank - MRAP - All crates"] = ""
ctld.i18n["en"]["Med Tank - LAV-25 - All crates"] = ""
ctld.i18n["en"]["Heavy Tank - Abrams - All crates"] = ""
ctld.i18n["en"]["Hummer - JTAC - All crates"] = ""
ctld.i18n["en"]["M-818 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["M-978 Tanker - All crates"] = ""
ctld.i18n["en"]["Ural-375 Ammo Truck - All crates"] = ""
ctld.i18n["en"]["EWR Radar - All crates"] = ""
ctld.i18n["en"]["MLRS - All crates"] = ""
ctld.i18n["en"]["SpGH DANA - All crates"] = ""
ctld.i18n["en"]["T155 Firtina - All crates"] = ""
ctld.i18n["en"]["Howitzer - All crates"] = ""
ctld.i18n["en"]["SPH 2S19 Msta - All crates"] = ""
ctld.i18n["en"]["M1097 Avenger - All crates"] = ""
ctld.i18n["en"]["M48 Chaparral - All crates"] = ""
ctld.i18n["en"]["Roland ADS - All crates"] = ""
ctld.i18n["en"]["Gepard AAA - All crates"] = ""
ctld.i18n["en"]["LPWS C-RAM - All crates"] = ""
ctld.i18n["en"]["9K33 Osa - All crates"] = ""
ctld.i18n["en"]["9P31 Strela-1 - All crates"] = ""
ctld.i18n["en"]["9K35M Strela-10 - All crates"] = ""
ctld.i18n["en"]["9K331 Tor - All crates"] = ""
ctld.i18n["en"]["2K22 Tunguska - All crates"] = ""
ctld.i18n["en"]["HAWK - All crates"] = ""
ctld.i18n["en"]["NASAMS - All crates"] = ""
ctld.i18n["en"]["KUB - All crates"] = ""
ctld.i18n["en"]["BUK - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""
ctld.i18n["en"]["Patriot - All crates"] = ""

--- mission design error messages
ctld.i18n["en"]["CTLD.lua ERROR: Can't find trigger called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = ""
ctld.i18n["en"]["CTLD.lua ERROR: Can't find crate with weight %1"] = ""

--- runtime messages
ctld.i18n["en"]["You are not close enough to friendly logistics to get a crate!"] = ""
ctld.i18n["en"]["No more JTAC Crates Left!"] = ""
ctld.i18n["en"]["Sorry you must wait %1 seconds before you can get another crate"] = ""
ctld.i18n["en"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into combat"] = ""
ctld.i18n["en"]["%1 fast-ropped troops from %2 into %3"] = ""
ctld.i18n["en"]["%1 dropped troops from %2 into %3"] = ""
ctld.i18n["en"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = ""
ctld.i18n["en"]["%1 dropped vehicles from %2 into combat"] = ""
ctld.i18n["en"]["%1 loaded troops into %2"] = ""
ctld.i18n["en"]["%1 loaded %2 vehicles into %3"] = ""
ctld.i18n["en"]["%1 delivered a FOB Crate"] = ""
ctld.i18n["en"]["Delivered FOB Crate 60m at 6'oclock to you"] = ""
ctld.i18n["en"]["FOB Crate dropped back to base"] = ""
ctld.i18n["en"]["FOB Crate Loaded"] = ""
ctld.i18n["en"]["%1 loaded a FOB Crate ready for delivery!"] = ""
ctld.i18n["en"]["There are no friendly logistic units nearby to load a FOB crate from!"] = ""
ctld.i18n["en"]["This area has no more reinforcements available!"] = ""
ctld.i18n["en"]["You are not in a pickup zone and no one is nearby to extract"] = ""
ctld.i18n["en"]["You are not in a pickup zone"] = ""
ctld.i18n["en"]["No one to unload"] = ""
ctld.i18n["en"]["Dropped troops back to base"] = ""
ctld.i18n["en"]["Dropped vehicles back to base"] = ""
ctld.i18n["en"]["You already have troops onboard."] = ""
ctld.i18n["en"]["Count Infantries limit in the mission reached, you can't load more troops"] = ""
ctld.i18n["en"]["You already have vehicles onboard."] = ""
ctld.i18n["en"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = ""
ctld.i18n["en"]["%1 extracted troops in %2 from combat"] = ""
ctld.i18n["en"]["No extractable troops nearby!"] = ""
ctld.i18n["en"]["%1 extracted vehicles in %2 from combat"] = ""
ctld.i18n["en"]["No extractable vehicles nearby!"] = ""
ctld.i18n["en"]["%1 troops onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["%1 vehicles onboard (%2)\n"] = ""
ctld.i18n["en"]["1 FOB Crate oboard (%1 kg)\n"] = ""
ctld.i18n["en"]["%1 crate onboard (%2 kg)\n"] = ""
ctld.i18n["en"]["Total weight of cargo : %1 kg\n"] = ""
ctld.i18n["en"]["No cargo."] = ""
ctld.i18n["en"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] =
""
ctld.i18n["en"]["Loaded %1 crate!"] = ""
ctld.i18n["en"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = ""
ctld.i18n["en"]["You must land before you can load a crate!"] = ""
ctld.i18n["en"]["No Crates within 50m to load!"] = ""
ctld.i18n["en"]["Maximum number of crates are on board!"] = ""
ctld.i18n["en"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = ""
ctld.i18n["en"]["FOB Crate - %1 m - %2 o'clock\n"] = ""
ctld.i18n["en"]["No Nearby Crates"] = ""
ctld.i18n["en"]["Nearby Crates:\n%1"] = ""
ctld.i18n["en"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = ""
ctld.i18n["en"]["FOB Positions:"] = ""
ctld.i18n["en"]["%1\nFOB @ %2"] = ""
ctld.i18n["en"]["Sorry, there are no active FOBs!"] = ""
ctld.i18n["en"]["You can't unpack that here! Take it to where it's needed!"] = ""
ctld.i18n["en"]["Sorry you must move this crate before you unpack it!"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field"] = ""
ctld.i18n["en"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = ""
ctld.i18n["en"]["Finished building FOB! Crates and Troops can now be picked up."] = ""
ctld.i18n["en"]["Finished building FOB! Crates can now be picked up."] = ""
ctld.i18n["en"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] =
""
ctld.i18n["en"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] =
""
ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] =
""
ctld.i18n["en"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = ""
ctld.i18n["en"]["%1 crate has been safely dropped below you"] = ""
ctld.i18n["en"]["You were too high! The crate has been destroyed"] = ""
ctld.i18n["en"]["Radio Beacons:\n%1"] = ""
ctld.i18n["en"]["No Active Radio Beacons"] = ""
ctld.i18n["en"]["%1 deployed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["You need to land before you can deploy a Radio Beacon!"] = ""
ctld.i18n["en"]["%1 removed a Radio Beacon.\n\n%2"] = ""
ctld.i18n["en"]["No Radio Beacons within 500m."] = ""
ctld.i18n["en"]["You need to land before remove a Radio Beacon"] = ""
ctld.i18n["en"]["%1 successfully rearmed a full %2 in the field"] = ""
ctld.i18n["en"]["Missing %1\n"] = ""
ctld.i18n["en"]["Out of parts for AA Systems. Current limit is %1\n"] = ""
ctld.i18n["en"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = ""
ctld.i18n["en"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = ""
ctld.i18n["en"]["%1 successfully repaired a full %2 in the field."] = ""
ctld.i18n["en"]["Cannot repair %1. No damaged %2 within 300m"] = ""
ctld.i18n["en"]["%1 successfully deployed %2 to the field using %3 crates."] = ""
ctld.i18n["en"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not close enought to each other"] =
""
ctld.i18n["en"]["%1 dropped %2 smoke."] = ""

--- JTAC messages
ctld.i18n["en"]["JTAC Group %1 KIA!"] = ""
ctld.i18n["en"]["%1, selected target reacquired, %2"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"]["new target, "] = ""
ctld.i18n["en"]["standing by on %1"] = ""
ctld.i18n["en"]["lasing %1"] = ""
ctld.i18n["en"][", temporarily %1"] = ""
ctld.i18n["en"]["target lost"] = ""
ctld.i18n["en"]["target destroyed"] = ""
ctld.i18n["en"][", selected %1"] = ""
ctld.i18n["en"]["%1 %2 target lost."] = ""
ctld.i18n["en"]["%1 %2 target destroyed."] = ""
ctld.i18n["en"]["JTAC STATUS: \n\n"] = ""
ctld.i18n["en"][", available on %1 %2,"] = ""
ctld.i18n["en"]["UNKNOWN"] = ""
ctld.i18n["en"][" targeting "] = ""
ctld.i18n["en"][" targeting selected unit "] = ""
ctld.i18n["en"][" attempting to find selected unit, temporarily targeting "] = ""
ctld.i18n["en"]["(Laser OFF) "] = ""
ctld.i18n["en"]["Visual On: "] = ""
ctld.i18n["en"][" searching for targets %1\n"] = ""
ctld.i18n["en"]["No Active JTACs"] = ""
ctld.i18n["en"][", targeting selected unit, %1"] = ""
ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ""
ctld.i18n["en"][", target selection reset."] = ""
ctld.i18n["en"]["%1, laser and smokes enabled"] = ""
ctld.i18n["en"]["%1, laser and smokes disabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations enabled"] = ""
ctld.i18n["en"]["%1, wind and target speed laser spot compensations disabled"] = ""
ctld.i18n["en"]["%1, WHITE smoke deployed near target"] = ""

--- F10 menu messages
ctld.i18n["en"]["Actions"] = ""
ctld.i18n["en"]["Troop Transport"] = ""
ctld.i18n["en"]["Unload / Extract Troops"] = ""
ctld.i18n["en"]["Next page"] = ""
ctld.i18n["en"]["Load "] = ""
ctld.i18n["en"]["Vehicle / FOB Transport"] = ""
ctld.i18n["en"]["Crates: Vehicle / FOB / Drone"] = ""
ctld.i18n["en"]["Unload Vehicles"] = ""
ctld.i18n["en"]["Load / Extract Vehicles"] = ""
ctld.i18n["en"]["Load / Unload FOB Crate"] = ""
ctld.i18n["en"]["Repack Vehicles"] = ""
ctld.i18n["en"]["CTLD Commands"] = ""
ctld.i18n["en"]["CTLD"] = ""
ctld.i18n["en"]["Check Cargo"] = ""
ctld.i18n["en"]["Load Nearby Crate(s)"] = ""
ctld.i18n["en"]["Unpack Any Crate"] = ""
ctld.i18n["en"]["Drop Crate(s)"] = ""
ctld.i18n["en"]["List Nearby Crates"] = ""
ctld.i18n["en"]["List FOBs"] = ""
ctld.i18n["en"]["List Beacons"] = ""
ctld.i18n["en"]["List Radio Beacons"] = ""
ctld.i18n["en"]["Smoke Markers"] = ""
ctld.i18n["en"]["Drop Red Smoke"] = ""
ctld.i18n["en"]["Drop Blue Smoke"] = ""
ctld.i18n["en"]["Drop Orange Smoke"] = ""
ctld.i18n["en"]["Drop Green Smoke"] = ""
ctld.i18n["en"]["Drop Beacon"] = ""
ctld.i18n["en"]["Radio Beacons"] = ""
ctld.i18n["en"]["Remove Closest Beacon"] = ""
ctld.i18n["en"]["JTAC Status"] = ""
ctld.i18n["en"]["DISABLE "] = ""
ctld.i18n["en"]["ENABLE "] = ""
ctld.i18n["en"]["REQUEST "] = ""
ctld.i18n["en"]["Reset TGT Selection"] = ""
-- F10 RECON menus
ctld.i18n["en"]["RECON"] = ""
ctld.i18n["en"]["Show targets in LOS (refresh)"] = ""
ctld.i18n["en"]["Hide targets in LOS"] = ""
ctld.i18n["en"]["START autoRefresh targets in LOS"] = ""
ctld.i18n["en"]["STOP autoRefresh targets in LOS"] = ""

--- Translates a string (text) with parameters (parameters) to the language defined in ctld.i18n_lang
---@param text string The text to translate, with the parameters as %1, %2, etc. (all strings!!!!)
---@param ... any (list) The parameters to replace in the text, in order (all paremeters will be converted to string)
---@return string the translated and formatted text
function ctld.i18n_translate(text, ...)
    local _text

    if not ctld.i18n[ctld.i18n_lang] then
        env.info(string.format(" E - CTLD.i18n_translate: Language %s not found, defaulting to 'en'",
            tostring(ctld.i18n_lang)))
        _text = ctld.i18n["en"][text]
    else
        _text = ctld.i18n[ctld.i18n_lang][text]
    end

    -- default to english
    if _text == nil then
        _text = ctld.i18n["en"][text]
    end

    -- default to the provided text
    if _text == nil or _text == "" then
        _text = text
    end

    if arg and arg.n and arg.n > 0 then
        local _args = {}
        for i = 1, arg.n do
            _args[i] = tostring(arg[i]) or ""
        end
        for i = 1, #_args do
            _text = string.gsub(_text, "%%" .. i, _args[i])
        end
    end

    return _text
end

-----------------[[ END OF i18n.lua ]]-----------------
