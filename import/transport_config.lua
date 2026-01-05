-----------------[[ transport_config.lua ]]-----------------

-- Transportable Craft Names
-- If ctld.addPlayerAircraftByType = True, comment or uncomment lines to allow aircraft's type carry CTLD

ctld.aircraftTypeTable = {
    --%%%%% MODS %%%%%
    --"Bronco-OV-10A",
    --"Hercules",
    --"SK-60",
    --"UH-60L",
    --"T-45",

    --%%%%% CHOPPERS %%%%%
    --"Ka-50",
    --"Ka-50_3",
    "Mi-8MT",
    "Mi-24P",
    --"SA342L",
    --"SA342M",
    --"SA342Mistral",
    --"SA342Minigun",
    "UH-1H",
    "CH-47Fbl1",

    --%%%%% AIRCRAFTS %%%%%
    --"C-101EB",
    --"C-101CC",
    --"Christen Eagle II",
    --"L-39C",
    --"L-39ZA",
    --"MB-339A",
    --"MB-339APAN",
    --"Mirage-F1B",
    --"Mirage-F1BD",
    --"Mirage-F1BE",
    --"Mirage-F1BQ",
    --"Mirage-F1DDA",
    --"Su-25T",
    --"Yak-52",
    "C-130J-30",

    --%%%%% WARBIRDS %%%%%
    --"Bf-109K-4",
    --"Fw 190A8",
    --"FW-190D9",
    --"I-16",
    --"MosquitoFBMkVI",
    --"P-47D-30",
    --"P-47D-40",
    --"P-51D",
    --"P-51D-30-NA",
    --"SpitfireLFMkIX",
    --"SpitfireLFMkIXCW",
    --"TF-51D",
}

-- Use any of the predefined names or set your own ones
ctld.transportPilotNames = {
    "helicargo1",
    "helicargo2",
    "helicargo3",
    "helicargo4",
    "helicargo5",
    "helicargo6",
    "helicargo7",
    "helicargo8",
    "helicargo9",
    "helicargo10",

    "helicargo11",
    "helicargo12",
    "helicargo13",
    "helicargo14",
    "helicargo15",
    "helicargo16",
    "helicargo17",
    "helicargo18",
    "helicargo19",
    "helicargo20",

    "helicargo21",
    "helicargo22",
    "helicargo23",
    "helicargo24",
    "helicargo25",

    "MEDEVAC #1",
    "MEDEVAC #2",
    "MEDEVAC #3",
    "MEDEVAC #4",
    "MEDEVAC #5",
    "MEDEVAC #6",
    "MEDEVAC #7",
    "MEDEVAC #8",
    "MEDEVAC #9",
    "MEDEVAC #10",
    "MEDEVAC #11",
    "MEDEVAC #12",
    "MEDEVAC #13",
    "MEDEVAC #14",
    "MEDEVAC #15",
    "MEDEVAC #16",

    "MEDEVAC RED #1",
    "MEDEVAC RED #2",
    "MEDEVAC RED #3",
    "MEDEVAC RED #4",
    "MEDEVAC RED #5",
    "MEDEVAC RED #6",
    "MEDEVAC RED #7",
    "MEDEVAC RED #8",
    "MEDEVAC RED #9",
    "MEDEVAC RED #10",
    "MEDEVAC RED #11",
    "MEDEVAC RED #12",
    "MEDEVAC RED #13",
    "MEDEVAC RED #14",
    "MEDEVAC RED #15",
    "MEDEVAC RED #16",
    "MEDEVAC RED #17",
    "MEDEVAC RED #18",
    "MEDEVAC RED #19",
    "MEDEVAC RED #20",
    "MEDEVAC RED #21",

    "MEDEVAC BLUE #1",
    "MEDEVAC BLUE #2",
    "MEDEVAC BLUE #3",
    "MEDEVAC BLUE #4",
    "MEDEVAC BLUE #5",
    "MEDEVAC BLUE #6",
    "MEDEVAC BLUE #7",
    "MEDEVAC BLUE #8",
    "MEDEVAC BLUE #9",
    "MEDEVAC BLUE #10",
    "MEDEVAC BLUE #11",
    "MEDEVAC BLUE #12",
    "MEDEVAC BLUE #13",
    "MEDEVAC BLUE #14",
    "MEDEVAC BLUE #15",
    "MEDEVAC BLUE #16",
    "MEDEVAC BLUE #17",
    "MEDEVAC BLUE #18",
    "MEDEVAC BLUE #19",
    "MEDEVAC BLUE #20",
    "MEDEVAC BLUE #21",

    -- *** AI transports names (different names only to ease identification in mission) ***

    -- Use any of the predefined names or set your own ones
    "transport1",
    "transport2",
    "transport3",
    "transport4",
    "transport5",
    "transport6",
    "transport7",
    "transport8",
    "transport9",
    "transport10",

    "transport11",
    "transport12",
    "transport13",
    "transport14",
    "transport15",
    "transport16",
    "transport17",
    "transport18",
    "transport19",
    "transport20",

    "transport21",
    "transport22",
    "transport23",
    "transport24",
    "transport25",
}

-- *************** Optional Extractable GROUPS *****************

-- Use any of the predefined names or set your own ones
ctld.extractableGroups = {
    "extract1",
    "extract2",
    "extract3",
    "extract4",
    "extract5",
    "extract6",
    "extract7",
    "extract8",
    "extract9",
    "extract10",
    "extract11",
    "extract12",
    "extract13",
    "extract14",
    "extract15",
    "extract16",
    "extract17",
    "extract18",
    "extract19",
    "extract20",
    "extract21",
    "extract22",
    "extract23",
    "extract24",
    "extract25",
}

-- ************** Logistics UNITS FOR CRATE SPAWNING ******************

-- Use any of the predefined names or set your own ones
-- PLEASE NOTE: When a logistic unit is destroyed, you will no longer be able to spawn crates
ctld.dynamicLogisticUnitsIndex = 0 -- This is the unit that will be spawned first and then subsequent units will be from the next in the list
ctld.logisticUnits = {
    "logistic1",
    "logistic2",
    "logistic3",
    "logistic4",
    "logistic5",
    "logistic6",
    "logistic7",
    "logistic8",
    "logistic9",
    "logistic10",
}

-- ************** UNITS ABLE TO TRANSPORT VEHICLES ******************
-- Add the model name of the unit that you want to be able to transport and deploy vehicles
-- units db has all the names or you can extract a mission.miz file by making it a zip and looking
-- in the contained mission file
ctld.vehicleTransportEnabled = {
    "76MD",     -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
    "Hercules",
    "C-130J-30",
    --"CH-47Fbl1",
}

-----------------[[ END OF transport_config.lua ]]-----------------