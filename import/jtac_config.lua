-----------------[[ jtac_config.lua ]]-----------------

-- if the unit is on this list, it will be made into a JTAC when deployed
ctld.jtacUnitTypes     = {
    "SKP", "Hummer",            -- there are some wierd encoding issues so if you write SKP-11 it wont match as the - sign is encoded differently...
    "MQ", "RQ"                  --"MQ-9 Repear", "RQ-1A Predator"}
}
ctld.jtacDroneRadius   = 1000   -- JTAC offset radius in meters for orbiting drones
ctld.jtacDroneAltitude = 7000   -- JTAC altitude in meters for orbiting drones

-----------------[[ END OF jtac_config.lua ]]-----------------
