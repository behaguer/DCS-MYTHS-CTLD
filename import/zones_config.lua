-----------------[[ zones_config.lua ]]-----------------

-- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",
-- Use any of the predefined names or set your own ones
-- You can add number as a third option to limit the number of soldier or vehicle groups that can be loaded from a zone.
-- Dropping back a group at a limited zone will add one more to the limit
-- If a zone isn't ACTIVE then you can't pickup from that zone until the zone is activated by ctld.activatePickupZone
-- using the Mission editor
-- You can pickup from a SHIP by adding the SHIP UNIT NAME instead of a zone name
-- Side - Controls which side can load/unload troops at the zone
-- Flag Number - Optional last field. If set the current number of groups remaining can be obtained from the flag value

-- pickupZones = { "Zone name or Ship Unit Name", "smoke color", "limit (-1 unlimited)", "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", flag number (optional) }
ctld.pickupZones = {
    { "pickzone1",   "blue", -1, "yes", 0 },
    -- { "pickzone2",   "red",  -1, "yes", 0 },
    -- { "pickzone3",   "none", -1, "yes", 0 },
    -- { "pickzone4",   "none", -1, "yes", 0 },
    -- { "pickzone5",   "none", -1, "yes", 0 },
    -- { "pickzone6",   "none", -1, "yes", 0 },
    -- { "pickzone7",   "none", -1, "yes", 0 },
    -- { "pickzone8",   "none", -1, "yes", 0 },
    -- { "pickzone9",   "none", 5,  "yes", 1 },    -- limits pickup zone 9 to 5 groups of soldiers or vehicles, only red can pick up
    -- { "pickzone10",  "none", 10, "yes", 2 },    -- limits pickup zone 10 to 10 groups of soldiers or vehicles, only blue can pick up
    -- { "pickzone11",  "blue", 20, "no",  2 },    -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    -- { "pickzone12",  "red",  20, "no",  1 },    -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
    -- { "pickzone13",  "none", -1, "yes", 0 },
    -- { "pickzone14",  "none", -1, "yes", 0 },
    -- { "pickzone15",  "none", -1, "yes", 0 },
    -- { "pickzone16",  "none", -1, "yes", 0 },
    -- { "pickzone17",  "none", -1, "yes", 0 },
    -- { "pickzone18",  "none", -1, "yes", 0 },
    -- { "pickzone19",  "none", 5,  "yes", 0 },
    -- { "pickzone20",  "none", 10, "yes", 0, 1000 },     -- optional extra flag number to store the current number of groups available in
    -- { "USA Carrier", "blue", 10, "yes", 0, 1001 },     -- instead of a Zone Name you can also use the UNIT NAME of a ship
}

-- dropOffZones = {"name","smoke colour",0,side 1 = Red or 2 = Blue or 0 = Both sides}
ctld.dropOffZones = {
    { "dropzone1",  "green",  2 },
    { "dropzone2",  "blue",   2 },
    { "dropzone3",  "orange", 2 },
    { "dropzone4",  "none",   2 },
    { "dropzone5",  "none",   1 },
    { "dropzone6",  "none",   1 },
    { "dropzone7",  "none",   1 },
    { "dropzone8",  "none",   1 },
    { "dropzone9",  "none",   1 },
    { "dropzone10", "none",   1 },
}

--wpZones = { "Zone name", "smoke color",    "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", }
ctld.wpZones = {
    { "wpzone1",  "green",  "yes", 2 },
    { "wpzone2",  "blue",   "yes", 2 },
    { "wpzone3",  "orange", "yes", 2 },
    { "wpzone4",  "none",   "yes", 2 },
    { "wpzone5",  "none",   "yes", 2 },
    { "wpzone6",  "none",   "yes", 1 },
    { "wpzone7",  "none",   "yes", 1 },
    { "wpzone8",  "none",   "yes", 1 },
    { "wpzone9",  "none",   "yes", 1 },
    { "wpzone10", "none",   "no",  0 }, -- Both sides as its set to 0
}

-----------------[[ END OF zones_config.lua ]]-----------------