-----------------[[ jtac_config.lua ]]-----------------

ctld.JTAC_LIMIT_RED = 10             -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE = 10            -- max number of JTAC Crates for the BLUE Side
ctld.JTAC_dropEnabled = true         -- allow JTAC Crate spawn from F10 menu
ctld.JTAC_maxDistance = 10000        -- How far a JTAC can "see" in meters (with Line of Sight)
ctld.JTAC_smokeOn_RED = false        -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE = false       -- enables marking of target with smoke for BLUE forces
ctld.JTAC_smokeColour_RED = 4        -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE = 1       -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeMarginOfError = 50    -- error that the JTAC is allowed to make when popping a smoke (in meters)
ctld.JTAC_smokeOffset_x = 0.0        -- distance in the X direction from target to smoke (meters)
ctld.JTAC_smokeOffset_y = 2.0        -- distance in the Y direction from target to smoke (meters)
ctld.JTAC_smokeOffset_z = 0.0        -- distance in the z direction from target to smoke (meters)
ctld.JTAC_jtacStatusF10 = true       -- enables F10 JTAC Status menu
ctld.JTAC_location = true            -- shows location of target in JTAC message
ctld.location_DMS = false            -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes
ctld.JTAC_lock = "all"               -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units
ctld.JTAC_allowStandbyMode = true    -- if true, allow players to toggle lasing on/off
ctld.JTAC_laseSpotCorrections = true -- if true, each JTAC will have a special option (toggle on/off) available in it's menu to attempt to lead the target, taking into account current wind conditions and the speed of the target (particularily useful against moving heavy armor)
ctld.JTAC_allowSmokeRequest = true   -- if true, allow players to request a smoke on target (temporary)
ctld.JTAC_allow9Line = true          -- if true, allow players to ask for a 9Line (individual) for a specific JTAC's target

-- if the unit is on this list, it will be made into a JTAC when deployed
ctld.jtacUnitTypes     = {
    "SKP", "Hummer",            -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
    "MQ", "RQ"                  --"MQ-9 Repear", "RQ-1A Predator"}
}
ctld.jtacDroneRadius   = 1000   -- JTAC offset radius in meters for orbiting drones
ctld.jtacDroneAltitude = 7000   -- JTAC altitude in meters for orbiting drones

-----------------[[ END OF jtac_config.lua ]]-----------------
