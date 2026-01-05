-----------------[[ config.lua ]]-----------------

ctld.staticBugWorkaround = false --    DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE

ctld.disableAllSmoke = false     -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below

-- Allow units to CTLD by aircraft type and not by pilot name - this is done everytime a player enters a new unit
ctld.addPlayerAircraftByType = true

ctld.hoverPickup = true       --    if set to false you can load crates with the F10 menu instead of hovering... Only if not using real crates!
ctld.loadCrateFromMenu = true -- if set to true, you can load crates with the F10 menu OR hovering, in case of using choppers and planes for example.

ctld.enableCrates = true      -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
ctld.enableAllCrates = true   -- if false, the "all crates" menu items will not be displayed
ctld.slingLoad = false        -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
-- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
-- to use the other method.
-- Set staticBugFix    to FALSE if use set ctld.slingLoad to TRUE
ctld.enableSmokeDrop = true                                                   -- if false, helis and c-130 will not be able to drop smoke
ctld.maxExtractDistance = 125                                                 -- max distance from vehicle to troops to allow a group extraction
ctld.maximumDistanceLogistic = 1000                                            -- max distance from vehicle to logistics to allow a loading or spawning operation
ctld.maxDistanceBetweenCratesForBuilding = 1000                     -- max distance between crates to allow building a vehicle or AA system
ctld.enableRepackingVehicles = true                                           -- if true, vehicles can be repacked into crates
ctld.maximumDistanceRepackableUnitsSearch = 200                               -- max distance from transportUnit to search force repackable units in meters
ctld.maximumSearchDistance = 4000                                             -- max distance for troops to search for enemy
ctld.maximumMoveDistance = 2000                                               -- max distance for troops to move from drop point if no enemy is nearby
ctld.minimumDeployDistance = 1000                                             -- minimum distance from a friendly pickup zone where you can deploy a crate
ctld.numberOfTroops = 10                                                      -- default number of troops to load on a transport heli or C-130
-- also works as maximum size of group that'll fit into a helicopter unless overridden
ctld.enableFastRopeInsertion = true                                           -- allows you to drop troops by fast rope
ctld.fastRopeMaximumHeight = 18.28                                            -- in meters which is 60 ft max fast rope (not rappell) safe height
ctld.vehiclesForTransportRED = { "BRDM-2", "BTR_D" }                          -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
ctld.vehiclesForTransportBLUE = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}
ctld.vehiclesWeight = {
    ["BRDM-2"] = 7000,
    ["BTR_D"] = 8000,
    ["M1045 HMMWV TOW"] = 3220,
    ["M1043 HMMWV Armament"] = 2500
}

ctld.spawnRPGWithCoalition = true --spawns a friendly RPG unit with Coalition forces
ctld.spawnStinger = false         -- spawns a stinger / igla soldier with a group of 6 or more soldiers!
ctld.enabledFOBBuilding = true    -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
-- In future i'd like it to be a FARP but so far that seems impossible...
-- You can also enable troop Pickup at FOBS
ctld.cratesRequiredForFOB = 1 -- The amount of crates required to build a FOB. Once built, helis can spawn crates at this outpost to be carried and deployed in another area.
-- The large crates can only be loaded and dropped by large aircraft, like the C-130 and listed in ctld.vehicleTransportEnabled
-- Small FOB crates can be moved by helicopter. The FOB will require ctld.cratesRequiredForFOB larges crates and small crates are 1/3 of a large fob crate
-- To build the FOB entirely out of small crates you will need ctld.cratesRequiredForFOB * 3

ctld.troopPickupAtFOB = true            -- if true, troops can also be picked up at a created FOB
ctld.buildTimeFOB = 120                 --time in seconds for the FOB to be built
ctld.crateWaitTime = 40                 -- time in seconds to wait before you can spawn another crate
ctld.forceCrateToBeMoved = true         -- a crate must be picked up at least once and moved before it can be unpacked. Helps to reduce crate spam
ctld.radioSound = "beacon.ogg"          -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
ctld.radioSoundFC3 ="beaconsilent.ogg"  -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)
ctld.deployedBeaconBattery = 30         -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed
ctld.enabledRadioBeaconDrop = true      -- if its set to false then beacons cannot be dropped by units
ctld.allowRandomAiTeamPickups = false   -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones
-- Limit the dropping of infantry teams -- this limit control is inactive if ctld.nbLimitSpawnedTroops = {0, 0} ----
ctld.nbLimitSpawnedTroops = {0, 0}      -- {redLimitInfantryCount, blueLimitInfantryCount} when this cumulative number of troops is reached, no more troops can be loaded onboard
ctld.InfantryInGameCount  = {0, 0}      -- {redCoaInfantryCount, blueCoaInfantryCount}

-- Simulated Sling load configuration
ctld.minimumHoverHeight = 7.5   -- Lowest allowable height for crate hover
ctld.maximumHoverHeight = 12.0  -- Highest allowable height for crate hover
ctld.maxDistanceFromCrate = 5.5 -- Maximum distance from from crate for hover
ctld.hoverTime = 10             -- Time to hold hover above a crate for loading in seconds

-- end of Simulated Sling load configuration

-- ***************** AA SYSTEM CONFIG *****************
ctld.aaLaunchers = 3 -- controls how many launchers to add to the AA systems when its spawned if no amount is specified in the template.
-- Sets a limit on the number of active AA systems that can be built for RED.
-- A system is counted as Active if its fully functional and has all parts
-- If a system is partially destroyed, it no longer counts towards the total
-- When this limit is hit, a player will still be able to get crates for an AA system, just unable
-- to unpack them

ctld.AASystemLimitRED = 20  -- Red side limit
ctld.AASystemLimitBLUE = 20 -- Blue side limit

-- Allows players to create systems using as many crates as they like
-- Example : an amount X of patriot launcher crates allows for Y launchers to be deployed, if a player brings 2*X+Z crates (Z being lower then X), then deploys the patriot site, 2*Y launchers will be in the group and Z launcher crate will be left over

ctld.AASystemCrateStacking = false
--END AA SYSTEM CONFIG ------------------------------------

-----------------[[ END OF config.lua ]]-----------------
