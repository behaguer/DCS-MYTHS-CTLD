-----------------[[ spawn_config.lua ]]-----------------

-- ************** SPAWNABLE CRATES ******************
-- Crates you can spawn via F10 MENU
-- weight is in KG
-- Desc is the description on the F10 MENU
-- unit is the model name of the unit to spawn
-- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
-- side is optional but 2 is BLUE and 1 is RED

-- Some descriptions are filtered to determine if JTAC or not!
-- PLEASE NOTE: Weights must be unique as we use the weight to change the cargo to the correct unit when we unpack

ctld.spawnableCrates = {
    -- name of the sub menu on F10 for spawning crates
    ["Combat Vehicles"] = {
        --- BLUE
        { weight = 1000.01,                                desc = ctld.i18n_translate("Humvee - MG"),                      unit = "M1043 HMMWV Armament", side = 2 }, --careful with the names as the script matches the desc to JTAC types
        { weight = 1000.02,                                desc = ctld.i18n_translate("Humvee - TOW"),                     unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
        { multiple = { 1000.02,1000.02 },                  desc = ctld.i18n_translate("Humvee - TOW - All crates"),        side = 2 },
        { weight = 1000.03,                                desc = ctld.i18n_translate("Light Tank - MRAP"),                unit = "MaxxPro_MRAP",         side = 2, cratesRequired = 2 },
        { multiple = { 1000.03, 1000.03 },                 desc = ctld.i18n_translate("Light Tank - MRAP - All crates"),   side = 2 },
        { weight = 1000.04,                                desc = ctld.i18n_translate("Med Tank - LAV-25"),                unit = "LAV-25",               side = 2, cratesRequired = 3 },
        { multiple = { 1000.04, 1000.04, 1000.04 },        desc = ctld.i18n_translate("Med Tank - LAV-25 - All crates"),   side = 2 },
        { weight = 1000.05,                                desc = ctld.i18n_translate("Heavy Tank - Abrams"),              unit = "M-1 Abrams",         side = 2, cratesRequired = 4 },
        { multiple = { 1000.05, 1000.05, 1000.05, 1000.05 }, desc = ctld.i18n_translate("Heavy Tank - Abrams - All crates"), side = 2 },

        --- RED
        { weight = 1000.11,                                desc = ctld.i18n_translate("BTR-D"),                            unit = "BTR_D",                side = 1 },
        { weight = 1000.12,                                desc = ctld.i18n_translate("BRDM-2"),                           unit = "BRDM-2",               side = 1 },

    },
    ["Support"] = {
        --- BLUE
        { weight = 1001.01,                       desc = ctld.i18n_translate("Hummer - JTAC"),                    unit = "Hummer",            side = 2,          cratesRequired = 2 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { multiple = { 1001.01, 1001.01 },        desc = ctld.i18n_translate("Hummer - JTAC - All crates"),       side = 2 },
        { weight = 1001.02,                       desc = ctld.i18n_translate("M-818 Ammo Truck"),                 unit = "M 818",             side = 2,          cratesRequired = 2 },
        { multiple = { 1001.02, 1001.02 },        desc = ctld.i18n_translate("M-818 Ammo Truck - All crates"),    side = 2 },
        { weight = 1001.03,                       desc = ctld.i18n_translate("M-978 Tanker"),                     unit = "M978 HEMTT Tanker", side = 2,          cratesRequired = 2 },
        { multiple = { 1001.03, 1001.03 },        desc = ctld.i18n_translate("M-978 Tanker - All crates"),        side = 2 },

        --- RED
        { weight = 1001.11,                       desc = ctld.i18n_translate("SKP-11 - JTAC"),                    unit = "SKP-11",            side = 1 }, -- used as jtac and unarmed, not on the crate list if JTAC is disabled
        { weight = 1001.12,                       desc = ctld.i18n_translate("Ural-375 Ammo Truck"),              unit = "Ural-375",          side = 1,          cratesRequired = 2 },
        { multiple = { 1001.12, 1001.12 },        desc = ctld.i18n_translate("Ural-375 Ammo Truck - All crates"), side = 1 },
        { weight = 1001.13,                       desc = ctld.i18n_translate("KAMAZ Ammo Truck"),                 unit = "KAMAZ Truck",       side = 1,          cratesRequired = 2 },

        --- Both
        { weight = 1001.21,                       desc = ctld.i18n_translate("EWR Radar"),                        unit = "FPS-117",           cratesRequired = 3 },
        { multiple = { 1001.21, 1001.21, 1001.21 }, desc = ctld.i18n_translate("EWR Radar - All crates") },
        { weight = 1001.22,                         desc = ctld.i18n_translate("FOB Crate - Small"),                unit = "FOB-SMALL" }, -- Builds a FOB! - requires 3 * ctld.cratesRequiredForFOB
        { multiple = { 1001.22, 1001.22, 1001.22 }, desc = ctld.i18n_translate("FOB Crate - Small - All crates"),                unit = "FOB-SMALL" }, -- Builds a FOB! - requires 3 * ctld.cratesRequiredForFOB

    },
    ["Artillery"] = {
        --- BLUE
        { weight = 1002.01,                       desc = ctld.i18n_translate("MLRS"),                       unit = "MLRS",         side = 2, cratesRequired = 3 },
        { multiple = { 1002.01, 1002.01, 1002.01 }, desc = ctld.i18n_translate("MLRS - All crates"),        side = 2 },
        { weight = 1002.02,                       desc = ctld.i18n_translate("SpGH DANA"),                  unit = "SpGH_Dana",    side = 2, cratesRequired = 3 },
        { multiple = { 1002.02, 1002.02, 1002.02 }, desc = ctld.i18n_translate("SpGH DANA - All crates"),   side = 2 },
        { weight = 1002.03,                       desc = ctld.i18n_translate("T155 Firtina"),               unit = "T155_Firtina", side = 2, cratesRequired = 3 },
        { multiple = { 1002.03, 1002.03, 1002.03 }, desc = ctld.i18n_translate("T155 Firtina - All crates"), side = 2 },
        { weight = 1002.04,                       desc = ctld.i18n_translate("Howitzer"),                   unit = "M-109",        side = 2, cratesRequired = 3 },
        { multiple = { 1002.04, 1002.04, 1002.04 }, desc = ctld.i18n_translate("Howitzer - All crates"),    side = 2 },

        --- RED
        { weight = 1002.11,                       desc = ctld.i18n_translate("SPH 2S19 Msta"),              unit = "SAU Msta",     side = 1, cratesRequired = 3 },
        { multiple = { 1002.11, 1002.11, 1002.11 }, desc = ctld.i18n_translate("SPH 2S19 Msta - All crates"), side = 1 },

    },
    ["SAM short range"] = {
        --- BLUE
        { weight = 1003.01,                       desc = ctld.i18n_translate("M1097 Avenger"),                unit = "M1097 Avenger",       side = 2, cratesRequired = 3 },
        { multiple = { 1003.01, 1003.01, 1003.01 }, desc = ctld.i18n_translate("M1097 Avenger - All crates"), side = 2 },
        { weight = 1003.02,                       desc = ctld.i18n_translate("M48 Chaparral"),                unit = "M48 Chaparral",       side = 2, cratesRequired = 2 },
        { multiple = { 1003.02, 1003.02 },        desc = ctld.i18n_translate("M48 Chaparral - All crates"),   side = 2 },
        { weight = 1003.03,                       desc = ctld.i18n_translate("Roland ADS"),                   unit = "Roland ADS",          side = 2, cratesRequired = 3 },
        { multiple = { 1003.03, 1003.03, 1003.03 }, desc = ctld.i18n_translate("Roland ADS - All crates"),    side = 2 },
        { weight = 1003.04,                       desc = ctld.i18n_translate("Gepard AAA"),                   unit = "Gepard",              side = 2, cratesRequired = 3 },
        { multiple = { 1003.04, 1003.04, 1003.04 }, desc = ctld.i18n_translate("Gepard AAA - All crates"),    side = 2 },
        { weight = 1003.05,                       desc = ctld.i18n_translate("LPWS C-RAM"),                   unit = "HEMTT_C-RAM_Phalanx", side = 2, cratesRequired = 3 },
        { multiple = { 1003.05, 1003.05, 1003.05 }, desc = ctld.i18n_translate("LPWS C-RAM - All crates"),    side = 2 },

        --- RED
        { weight = 1003.11,                       desc = ctld.i18n_translate("9K33 Osa"),                     unit = "Osa 9A33 ln",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.11, 1003.11, 1003.11 }, desc = ctld.i18n_translate("9K33 Osa - All crates"),      side = 1 },
        { weight = 1003.12,                       desc = ctld.i18n_translate("9P31 Strela-1"),                unit = "Strela-1 9P31",       side = 1, cratesRequired = 3 },
        { multiple = { 1003.12, 1003.12, 1003.12 }, desc = ctld.i18n_translate("9P31 Strela-1 - All crates"), side = 1 },
        { weight = 1003.13,                       desc = ctld.i18n_translate("9K35M Strela-10"),              unit = "Strela-10M3",         side = 1, cratesRequired = 3 },
        { multiple = { 1003.13, 1003.13, 1003.13 }, desc = ctld.i18n_translate("9K35M Strela-10 - All crates"), side = 1 },
        { weight = 1003.14,                       desc = ctld.i18n_translate("9K331 Tor"),                    unit = "Tor 9A331",           side = 1, cratesRequired = 3 },
        { multiple = { 1003.14, 1003.14, 1003.14 }, desc = ctld.i18n_translate("9K331 Tor - All crates"),     side = 1 },
        { weight = 1003.15,                       desc = ctld.i18n_translate("2K22 Tunguska"),                unit = "2S6 Tunguska",        side = 1, cratesRequired = 3 },
        { multiple = { 1003.15, 1003.15, 1003.15 }, desc = ctld.i18n_translate("2K22 Tunguska - All crates"), side = 1 },
    },
    ["SAM mid range"] = {
        --- BLUE
        { weight = 1004.01,                       desc = ctld.i18n_translate("HAWK Launcher"),             unit = "Hawk ln",              side = 2 },
        { weight = 1004.02,                       desc = ctld.i18n_translate("HAWK Search Radar"),         unit = "Hawk sr",              side = 2 },
        { weight = 1004.03,                       desc = ctld.i18n_translate("HAWK Track Radar"),          unit = "Hawk tr",              side = 2 },
        { weight = 1004.04,                       desc = ctld.i18n_translate("HAWK PCP"),                  unit = "Hawk pcp",             side = 2 },
        { weight = 1004.05,                       desc = ctld.i18n_translate("HAWK CWAR"),                 unit = "Hawk cwar",            side = 2 },
        { weight = 1004.06,                       desc = ctld.i18n_translate("HAWK Repair"),               unit = "HAWK Repair",          side = 2 },
        { multiple = { 1004.01, 1004.02, 1004.03 }, desc = ctld.i18n_translate("HAWK - All crates"),       side = 2 },
        { weight = 1004.11,                       desc = ctld.i18n_translate("NASAMS Launcher 120C"),      unit = "NASAMS_LN_C",          side = 2 },
        { weight = 1004.12,                       desc = ctld.i18n_translate("NASAMS Search/Track Radar"), unit = "NASAMS_Radar_MPQ64F1", side = 2 },
        { weight = 1004.13,                       desc = ctld.i18n_translate("NASAMS Command Post"),       unit = "NASAMS_Command_Post",  side = 2 },
        { weight = 1004.14,                       desc = ctld.i18n_translate("NASAMS Repair"),             unit = "NASAMS Repair",        side = 2 },
        { multiple = { 1004.11, 1004.12, 1004.13 }, desc = ctld.i18n_translate("NASAMS - All crates"),     side = 2 },

        --- RED
        { weight = 1004.21,                       desc = ctld.i18n_translate("KUB Launcher"),              unit = "Kub 2P25 ln",          side = 1 },
        { weight = 1004.22,                       desc = ctld.i18n_translate("KUB Radar"),                 unit = "Kub 1S91 str",         side = 1 },
        { weight = 1004.23,                       desc = ctld.i18n_translate("KUB Repair"),                unit = "KUB Repair",           side = 1 },
        { multiple = { 1004.21, 1004.22 },        desc = ctld.i18n_translate("KUB - All crates"),          side = 1 },
        { weight = 1004.31,                       desc = ctld.i18n_translate("BUK Launcher"),              unit = "SA-11 Buk LN 9A310M1", side = 1 },
        { weight = 1004.32,                       desc = ctld.i18n_translate("BUK Search Radar"),          unit = "SA-11 Buk SR 9S18M1",  side = 1 },
        { weight = 1004.33,                       desc = ctld.i18n_translate("BUK CC Radar"),              unit = "SA-11 Buk CC 9S470M1", side = 1 },
        { weight = 1004.34,                       desc = ctld.i18n_translate("BUK Repair"),                unit = "BUK Repair",           side = 1 },
        { multiple = { 1004.31, 1004.32, 1004.33 }, desc = ctld.i18n_translate("BUK - All crates"),        side = 1 },
        -- END of BUK
    },
    ["SAM long range"] = {
        --- BLUE
        { weight = 1005.01,                                         desc = ctld.i18n_translate("Patriot Launcher"),            unit = "Patriot ln",        side = 2 },
        { weight = 1005.02,                                         desc = ctld.i18n_translate("Patriot Radar"),               unit = "Patriot str",       side = 2 },
        { weight = 1005.03,                                         desc = ctld.i18n_translate("Patriot ECS"),                 unit = "Patriot ECS",       side = 2 },
        -- { weight = 1005.04, desc = ctld.i18n_translate("Patriot ICC"), unit = "Patriot cp", side = 2 },
        -- { weight = 1005.05, desc = ctld.i18n_translate("Patriot EPP"), unit = "Patriot EPP", side = 2 },
        { weight = 1005.06,                                         desc = ctld.i18n_translate("Patriot AMG (optional)"),      unit = "Patriot AMG",       side = 2 },
        { weight = 1005.07,                                         desc = ctld.i18n_translate("Patriot Repair"),              unit = "Patriot Repair",    side = 2 },
        { multiple = { 1005.01, 1005.02, 1005.03 },                 desc = ctld.i18n_translate("Patriot - All crates"),        side = 2 },
        { weight = 1005.11,                                         desc = ctld.i18n_translate("S-300 Grumble TEL C"),         unit = "S-300PS 5P85C ln",  side = 1 },
        { weight = 1005.12,                                         desc = ctld.i18n_translate("S-300 Grumble Flap Lid-A TR"), unit = "S-300PS 40B6M tr",  side = 1 },
        { weight = 1005.13,                                         desc = ctld.i18n_translate("S-300 Grumble Clam Shell SR"), unit = "S-300PS 40B6MD sr", side = 1 },
        { weight = 1005.14,                                         desc = ctld.i18n_translate("S-300 Grumble Big Bird SR"),   unit = "S-300PS 64H6E sr",  side = 1 },
        { weight = 1005.15,                                         desc = ctld.i18n_translate("S-300 Grumble C2"),            unit = "S-300PS 54K6 cp",   side = 1 },
        { weight = 1005.16,                                         desc = ctld.i18n_translate("S-300 Repair"),                unit = "S-300 Repair",      side = 1 },
        { multiple = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = ctld.i18n_translate("Patriot - All crates"),      side = 1 },
    },
    ["Drone"] = {
        --- BLUE MQ-9 Repear
        { weight = 1006.01, desc = ctld.i18n_translate("MQ-9 Repear - JTAC"),    unit = "MQ-9 Reaper",    side = 2 },

        --- RED MQ-1A Predator
        { weight = 1006.11, desc = ctld.i18n_translate("MQ-1A Predator - JTAC"), unit = "RQ-1A Predator", side = 1 },

    },
}

ctld.spawnableCratesModels = {
    ["load"] = {
        ["category"] = "Cargos",    --"Fortifications"
        ["type"] = "ammo_cargo",    --"uh1h_cargo"    --"Cargo04"
        ["canCargo"] = false,
    },
    ["sling"] = {
        ["category"] = "Cargos",
        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",
        ["canCargo"] = true
    },
    ["dynamic"] = {
        ["category"] = "Cargos",
        ["type"] = "ammo_cargo",
        ["canCargo"] = true
    }
}


--[[ Placeholder for different type of cargo containers. Let's say pipes and trunks, fuel for FOB building
        ["shape_name"] = "ab-212_cargo",
        ["type"] = "uh1h_cargo" --new type for the container previously used

        ["shape_name"] = "ammo_box_cargo",
        ["type"] = "ammo_cargo",

        ["shape_name"] = "barrels_cargo",
        ["type"] = "barrels_cargo",

        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",

        ["shape_name"] = "f_bar_cargo",
        ["type"] = "f_bar_cargo",

        ["shape_name"] = "fueltank_cargo",
        ["type"] = "fueltank_cargo",

        ["shape_name"] = "iso_container_cargo",
        ["type"] = "iso_container",

        ["shape_name"] = "iso_container_small_cargo",
        ["type"] = "iso_container_small",

        ["shape_name"] = "oiltank_cargo",
        ["type"] = "oiltank_cargo",

        ["shape_name"] = "pipes_big_cargo",
        ["type"] = "pipes_big_cargo",

        ["shape_name"] = "pipes_small_cargo",
        ["type"] = "pipes_small_cargo",

        ["shape_name"] = "tetrapod_cargo",
        ["type"] = "tetrapod_cargo",

        ["shape_name"] = "trunks_long_cargo",
        ["type"] = "trunks_long_cargo",

        ["shape_name"] = "trunks_small_cargo",
        ["type"] = "trunks_small_cargo",
]] --
 
-----------------[[ END OF spawn_config.lua ]]-----------------