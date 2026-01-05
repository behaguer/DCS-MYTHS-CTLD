-----------------[[ unit_config.lua ]]-----------------

-- ************** Units able to use DCS dynamic cargo system ******************
-- DCS (version) added the ability to load and unload cargo from aircraft.
-- Units listed here will spawn a cargo static that can be loaded with the standard DCS cargo system
-- We will also use this to make modifications to the menu and other checks and messages
ctld.dynamicCargoUnits = {
   "CH-47Fbl1",
   "UH-1H",
   "Mi-8MT",
   "Mi-24P",
   "C-130J-30"
}

-- ************** Maximum Units SETUP for UNITS ******************
-- Put the name of the Unit you want to limit group sizes too
-- i.e
-- ["UH-1H"] = 10,
--
-- Will limit UH1 to only transport groups with a size 10 or less
-- Make sure the unit name is exactly right or it wont work

ctld.unitLoadLimits = {
    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = 4,
    -- ["SA342L"] = 4,
    -- ["SA342M"] = 4,

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = 4,
    ["Hercules"] = 30,
    --["SK-60"] = 1,
    ["UH-60L"] = 12,
    --["T-45"] = 1,

    --%%%%% CHOPPERS %%%%%
    ["Mi-8MT"] = 16,
    ["Mi-24P"] = 10,
    --["SA342L"] = 4,
    --["SA342M"] = 4,
    --["SA342Mistral"] = 4,
    --["SA342Minigun"] = 3,
    ["UH-1H"] = 8,
    ["CH-47Fbl1"] = 33,

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = 1,
    --["C-101CC"] = 1,
    --["Christen Eagle II"] = 1,
    --["L-39C"] = 1,
    --["L-39ZA"] = 1,
    --["MB-339A"] = 1,
    --["MB-339APAN"] = 1,
    --["Mirage-F1B"] = 1,
    --["Mirage-F1BD"] = 1,
    --["Mirage-F1BE"] = 1,
    --["Mirage-F1BQ"] = 1,
    --["Mirage-F1DDA"] = 1,
    --["Su-25T"] = 1,
    --["Yak-52"] = 1,
    ["C-130J-30"] = 80

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = 1,
    --["Fw 190A8"] = 1,
    --["FW-190D9"] = 1,
    --["I-16"] = 1,
    --["MosquitoFBMkVI"] = 1,
    --["P-47D-30"] = 1,
    --["P-47D-40"] = 1,
    --["P-51D"] = 1,
    --["P-51D-30-NA"] = 1,
    --["SpitfireLFMkIX"] = 1,
    --["SpitfireLFMkIXCW"] = 1,
    --["TF-51D"] = 1,
}

-- Put the name of the Unit you want to enable loading multiple crates
ctld.internalCargoLimits = {

    -- Remove the -- below to turn on options
    ["Mi-8MT"] = 2,
    ["CH-47Fbl1"] = 8,
    ["C-130J-30"] = 20
}


-- ************** Allowable actions for UNIT TYPES ******************
-- Put the name of the Unit you want to limit actions for
-- NOTE - the unit must've been listed in the transportPilotNames list above
-- This can be used in conjunction with the options above for group sizes
-- By default you can load both crates and troops unless overriden below
-- i.e
-- ["UH-1H"] = {crates=true, troops=false},
--
-- Will limit UH1 to only transport CRATES but NOT TROOPS
--
-- ["SA342Mistral"] = {crates=fales, troops=true},
-- Will allow Mistral Gazelle to only transport crates, not troops

ctld.unitActions = {

    -- Remove the -- below to turn on options
    -- ["SA342Mistral"] = {crates=true, troops=true},
    -- ["SA342L"] = {crates=false, troops=true},
    -- ["SA342M"] = {crates=false, troops=true},

    --%%%%% MODS %%%%%
    --["Bronco-OV-10A"] = {crates=true, troops=true},
    ["Hercules"] = { crates = true, troops = true },
    ["SK-60"] = { crates = true, troops = true },
    ["UH-60L"] = { crates = true, troops = true },
    ["C-130J-30"] = { crates = true, troops = true },
    --["T-45"] = {crates=true, troops=true},

    --%%%%% CHOPPERS %%%%%
    --["Ka-50"] = {crates=true, troops=false},
    --["Ka-50_3"] = {crates=true, troops=false},
    ["Mi-8MT"] = { crates = true, troops = true },
    ["Mi-24P"] = { crates = true, troops = true },
    --["SA342L"] = {crates=false, troops=true},
    --["SA342M"] = {crates=false, troops=true},
    --["SA342Mistral"] = {crates=false, troops=true},
    --["SA342Minigun"] = {crates=false, troops=true},
    ["UH-1H"] = { crates = true, troops = true },
    ["CH-47Fbl1"] = { crates = true, troops = true },

    --%%%%% AIRCRAFTS %%%%%
    --["C-101EB"] = {crates=true, troops=true},
    --["C-101CC"] = {crates=true, troops=true},
    --["Christen Eagle II"] = {crates=true, troops=true},
    --["L-39C"] = {crates=true, troops=true},
    --["L-39ZA"] = {crates=true, troops=true},
    --["MB-339A"] = {crates=true, troops=true},
    --["MB-339APAN"] = {crates=true, troops=true},
    --["Mirage-F1B"] = {crates=true, troops=true},
    --["Mirage-F1BD"] = {crates=true, troops=true},
    --["Mirage-F1BE"] = {crates=true, troops=true},
    --["Mirage-F1BQ"] = {crates=true, troops=true},
    --["Mirage-F1DDA"] = {crates=true, troops=true},
    --["Su-25T"]= {crates=true, troops=false},
    --["Yak-52"] = {crates=true, troops=true},

    --%%%%% WARBIRDS %%%%%
    --["Bf-109K-4"] = {crates=true, troops=false},
    --["Fw 190A8"] = {crates=true, troops=false},
    --["FW-190D9"] = {crates=true, troops=false},
    --["I-16"] = {crates=true, troops=false},
    --["MosquitoFBMkVI"] = {crates=true, troops=true},
    --["P-47D-30"] = {crates=true, troops=false},
    --["P-47D-40"] = {crates=true, troops=false},
    --["P-51D"] = {crates=true, troops=false},
    --["P-51D-30-NA"] = {crates=true, troops=false},
    --["SpitfireLFMkIX"] = {crates=true, troops=false},
    --["SpitfireLFMkIXCW"] = {crates=true, troops=false},
    --["TF-51D"] = {crates=true, troops=true},
}

-----------------[[ END OF unit_config.lua ]]-----------------
