-----------------[[ ME_functions.lua ]]-----------------

-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************

-----------------------------------------------------------------
-- Spawn group at a trigger and set them as extractable. Usage:
-- ctld.spawnGroupAtTrigger("groupside", number, "triggerName", radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group description
-- "triggerName" = trigger name in mission editor between commas
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtTrigger("red", 2, "spawn1", 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtTrigger("blue", {mg=1,at=2,aa=3,inf=4,mortar=5},"spawn2", 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
--
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    local _spawnTrigger = trigger.misc.getZone(_triggerName)     -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find trigger called %1", _triggerName), 10)
        return
    end

    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_pos3, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-----------------------------------------------------------------
-- Spawn group at a Vec3 Point and set them as extractable. Usage:
-- ctld.spawnGroupAtPoint("groupside", number,Vec3 Point, radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group Description
-- Vec3 Point = A vec3 point like {x=1,y=2,z=3}. Can be obtained from a unit like so: Unit.getName("Unit1"):getPoint()
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtPoint("red", 2, {x=1,y=2,z=3}, 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtPoint("blue", {mg=1,at=2,aa=3,inf=4,mortar=5}, {x=1,y=2,z=3}, 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
function ctld.spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)
    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_point, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end

-- Preloads a transport with troops or vehicles
-- replaces any troops currently on board
function ctld.preLoadTransport(_unitName, _number, _troops)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        -- will replace any units currently on board
        --                if not ctld.troopsOnboard(_unit,_troops)    then
        ctld.loadTroops(_unit, _troops, _number)
        --                end
    end
end

-- Continuously counts the number of crates in a zone and sets the value of the passed in flag
-- to the count amount
-- This means you can trigger actions based on the count and also trigger messages before the count is reached
-- Just pass in the zone name and flag number like so as a single (NOT Continuous) Trigger
-- This will now work for Mission Editor and Spawned Crates
-- e.g. ctld.cratesInZone("DropZone1", 5)
function ctld.cratesInZone(_zone, _flagNumber)
    local _triggerZone = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    --ignore side, if crate has been used its discounted from the count
    local _crateTables = { ctld.spawnedCratesRED, ctld.spawnedCratesBLUE, ctld.missionEditorCargoCrates }

    local _crateCount = 0

    for _, _crates in pairs(_crateTables) do
        for _crateName, _dontUse in pairs(_crates) do
            --get crate
            local _crate = ctld.getCrateObject(_crateName)

            --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
            if _crate ~= nil and _crate:getLife() > 0
                and (ctld.inAir(_crate) == false) then
                local _dist = ctld.getDistance(_crate:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    _crateCount = _crateCount + 1
                end
            end
        end
    end

    --set flag stuff
    trigger.action.setUserFlag(_flagNumber, _crateCount)

    -- env.info("FLAG ".._flagNumber.." crates ".._crateCount)

    --retrigger in 5 seconds
    timer.scheduleFunction(function(_args)
        ctld.cratesInZone(_args[1], _args[2])
    end, { _zone, _flagNumber }, timer.getTime() + 5)
end

-- Creates an extraction zone
-- any Soldiers (not vehicles) dropped at this zone by a helicopter will disappear
-- and be added to a running total of soldiers for a set flag number
-- The idea is you can then drop say 20 troops in a zone and trigger an action using the mission editor triggers
-- and the flag value
--
-- The ctld.createExtractZone function needs to be called once in a trigger action do script.
-- if you dont want smoke, pass -1 to the function.
--Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4, NO SMOKE = -1
--
-- e.g. ctld.createExtractZone("extractzone1", 2, -1) will create an extraction zone at trigger zone "extractzone1", store the number of troops dropped at
-- the zone in flag 2 and not have smoke
--
--
--
function ctld.createExtractZone(_zone, _flagNumber, _smoke)
    local _triggerZone = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    trigger.action.setUserFlag(_flagNumber, 0)     --start at 0

    local _details = { point = _pos3, name = _zone, smoke = _smoke, flag = _flagNumber, radius = _triggerZone.radius }

    ctld.extractZones[_zone .. "-" .. _flagNumber] = _details

    if _smoke ~= nil and _smoke > -1 then
        local _smokeFunction

        _smokeFunction = function(_args)
            local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]
            -- check zone is still active
            if _extractDetails == nil then
                -- stop refreshing smoke, zone is done
                return
            end


            trigger.action.smoke(_args.point, _args.smoke)
            --refresh in 5 minutes
            timer.scheduleFunction(_smokeFunction, _args, timer.getTime() + 300)
        end

        --run local function
        _smokeFunction(_details)
    end
end

-- Removes an extraction zone
--
-- The smoke will take up to 5 minutes to disappear depending on the last time the smoke was activated
--
-- The ctld.removeExtractZone function needs to be called once in a trigger action do script.
--
-- e.g. ctld.removeExtractZone("extractzone1", 2) will remove an extraction zone at trigger zone "extractzone1"
-- that was setup with flag 2
--
--
--
function ctld.removeExtractZone(_zone, _flagNumber)
    local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]

    if _extractDetails ~= nil then
        --remove zone
        ctld.extractZones[_zone .. "-" .. _flagNumber] = nil
    end
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- GROUPS in a zone and store the values in two flags
-- A group is only counted as being in a zone when the leader of that group
-- is in the zone
-- Use: ctld.countDroppedGroupsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedGroupsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }
    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = mist.utils.zoneToVec3(_zone)
                local _dist = ctld.getDistance(_groupUnits[1]:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    if (_groupUnits[1]:getCoalition() == 1) then
                        _redCount = _redCount + 1;
                    else
                        _blueCount = _blueCount + 1;
                    end
                end
            end
        end
    end
    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Groups in zone ".._blueCount.." ".._redCount)
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- UNITS in a zone and store the values in two flags

-- Use: ctld.countDroppedUnitsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedUnitsInZone(_zone, _blueFlag, _redFlag)
    local _triggerZone = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld
        .droppedVehiclesBLUE }

    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = mist.utils.zoneToVec3(_zone)
                for _, _unit in pairs(_groupUnits) do
                    local _dist = ctld.getDistance(_unit:getPoint(), _zonePos)

                    if _dist <= _triggerZone.radius then
                        if (_unit:getCoalition() == 1) then
                            _redCount = _redCount + 1;
                        else
                            _blueCount = _blueCount + 1;
                        end
                    end
                end
            end
        end
    end


    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --    env.info("Units in zone ".._blueCount.." ".._redCount)
end

--***************************************************************
function ctld.getNextDynamicLogisticUnitIndex()
    ctld.dynamicLogisticUnitsIndex = ctld.dynamicLogisticUnitsIndex + 1
    return ctld.dynamicLogisticUnitsIndex
end

-- Creates a radio beacon on a random UHF - VHF and HF/FM frequency for homing
-- This WILL NOT WORK if you dont add beacon.ogg and beaconsilent.ogg to the mission!!!
-- e.g. ctld.createRadioBeaconAtZone("beaconZone","red", 1440,"Waypoint 1") will create a beacon at trigger zone "beaconZone" for the Red side
-- that will last 1440 minutes (24 hours ) and named "Waypoint 1" in the list of radio beacons
--
-- e.g. ctld.createRadioBeaconAtZone("beaconZoneBlue","blue", 20) will create a beacon at trigger zone "beaconZoneBlue" for the Blue side
-- that will last 20 minutes
function ctld.createRadioBeaconAtZone(_zone, _coalition, _batteryLife, _name)
    local _triggerZone = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    ctld.beaconCount = ctld.beaconCount + 1

    if _name == nil or _name == "" then
        _name = "Beacon #" .. ctld.beaconCount
    end

    if _coalition == "red" then
        ctld.createRadioBeacon(_zonePos, 1, 0, _name, _batteryLife)         --1440
    else
        ctld.createRadioBeacon(_zonePos, 2, 2, _name, _batteryLife)         --1440
    end
end

-- Activates a pickup zone
-- Activates a pickup zone when called from a trigger
-- EG: ctld.activatePickupZone("pickzone3")
-- This is enable pickzone3 to be used as a pickup zone for the team set
function ctld.activatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)     -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone or ship called %1", _zoneName), 10)
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[4] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[4] = "1"                             --activate zone

            if ctld.disableAllSmoke == true then             --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a pickup zone
-- Deactivates a pickup zone when called from a trigger
-- EG: ctld.deactivatePickupZone("pickzone3")
-- This is disables pickzone3 and can no longer be used to as a pickup zone
-- These functions can be called by triggers, like if a set of buildings is used, you can trigger the zone to be 'not operational'
-- once they are destroyed
function ctld.deactivatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)     -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            -- i'd just ignore it if its already been deactivated
            _zoneDetails[4] = "0"            --deactivate zone
        end
    end
end

-- Change the remaining groups currently available for pickup at a zone
-- e.g. ctld.changeRemainingGroupsForPickupZone("pickup1", 5) -- adds 5 groups
-- ctld.changeRemainingGroupsForPickupZone("pickup1", -3) -- remove 3 groups
function ctld.changeRemainingGroupsForPickupZone(_zoneName, _amount)
    local _triggerZone = trigger.misc.getZone(_zoneName)     -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end
    end

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            ctld.updateZoneCounter(_zoneName, _amount)
        end
    end
end

-- Activates a Waypoint zone
-- Activates a Waypoint zone when called from a trigger
-- EG: ctld.activateWaypointZone("pickzone3")
-- This means that troops dropped within the radius of the zone will head to the center
-- of the zone instead of searching for troops
function ctld.activateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)     -- trigger to use as reference position


    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)

        return
    end

    for _, _zoneDetails in pairs(ctld.wpZones) do
        if _zoneName == _zoneDetails[1] then
            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[3] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                return
            end

            _zoneDetails[3] = "1" --activate zone

            if ctld.disableAllSmoke == true then -- smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then
                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end

-- Deactivates a Waypoint zone
-- Deactivates a Waypoint zone when called from a trigger
-- EG: ctld.deactivateWaypointZone("wpzone3")
-- This disables wpzone3 so that troops dropped in this zone will search for troops as normal
-- These functions can be called by triggers
function ctld.deactivateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName)

    if _triggerZone == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zoneName), 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do
        if _zoneName == _zoneDetails[1] then
            _zoneDetails[3] = 0             --deactivate zone
        end
    end
end

-- Continuous Trigger Function
-- Causes an AI unit with the specified name to unload troops / vehicles when
-- an enemy is detected within a specified distance
-- The enemy must have Line or Sight to the unit to be detected
function ctld.unloadInProximityToEnemy(_unitName, _distance)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil and _unit:getPlayerName() == nil then
        -- no player name means AI!
        -- the findNearest visible enemy you'd want to modify as it'll find enemies quite far away
        -- limited by    ctld.JTAC_maxDistance
        local _nearestEnemy = ctld.findNearestVisibleEnemy(_unit, "all", _distance)

        if _nearestEnemy ~= nil then
            if ctld.troopsOnboard(_unit, true) then
                ctld.deployTroops(_unit, true)
                return true
            end

            if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
                ctld.deployTroops(_unit, false)
                return true
            end
        end
    end

    return false
end

-- Unit will unload any units onboard if the unit is on the ground
-- when this function is called
function ctld.unloadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        if ctld.troopsOnboard(_unit, true) then
            ctld.unloadTroops({ _unitName, true })
        end

        if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
            ctld.unloadTroops({ _unitName, false })
        end
    end
end

-- Loads Troops and Vehicles from a zone or picks up nearby troops or vehicles
function ctld.loadTransport(_unitName)
    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then
        ctld.loadTroopsFromZone({ _unitName, true, "", true })

        if ctld.unitCanCarryVehicles(_unit) then
            ctld.loadTroopsFromZone({ _unitName, false, "", true })
        end
    end
end

-- adds a callback that will be called for many actions ingame
function ctld.addCallback(_callback)
    table.insert(ctld.callbacks, _callback)
end

-- Spawns a sling loadable crate at a Trigger Zone
--
-- Weights can be found in the ctld.spawnableCrates list
-- e.g. ctld.spawnCrateAtZone("red", 500,"triggerzone1") -- spawn a humvee at triggerzone 1 for red side
-- e.g. ctld.spawnCrateAtZone("blue", 505,"triggerzone1") -- spawn a tow humvee at triggerzone1 for blue side
--
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    local _spawnTrigger = trigger.misc.getZone(_zone)     -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find zone called %1", _zone), 10)
        return
    end

    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _point = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side)
end

-- Spawns a sling loadable crate at a Point
--
-- Weights can be found in the ctld.spawnableCrates list
-- Points can be made by hand or obtained from a Unit position by Unit.getByName("PilotName"):getPoint()
-- e.g. ctld.spawnCrateAtPoint("red", 500,{x=1,y=2,z=3}) -- spawn a humvee at triggerzone 1 for red side at a specified point
-- e.g. ctld.spawnCrateAtPoint("blue", 505,{x=1,y=2,z=3}) -- spawn a tow humvee at triggerzone1 for blue side at a specified point
--
--
function ctld.spawnCrateAtPoint(_side, _weight, _point, _hdg)
    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText(ctld.i18n_translate("CTLD.lua ERROR: Can't find crate with weight %1", _weight), 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side, _hdg)
end

-- ***************************************************************
function ctld.getSecureDistanceFromUnit(_unitOrName)	-- return a distance between the center of unitName, to be sure not touch the unitName
    local rotorDiameter = 19    -- meters  -- ok for UH & CH47
    local unit = _unitOrName
    if type(unit) == "string" then
        unit = Unit.getByName(_unitOrName)
    end
    local secureDistanceFromUnit = rotorDiameter
    if unit then
        local unitUserBox = unit:getDesc().box
        if unitUserBox then
        if math.abs(unitUserBox.max.x) >= math.abs(unitUserBox.min.x) then
                secureDistanceFromUnit = math.abs(unitUserBox.max.x) + (rotorDiameter/2)
        else
                secureDistanceFromUnit = math.abs(unitUserBox.min.x) + (rotorDiameter/2)
        end
	end
	end
    return secureDistanceFromUnit
end

-- ***************************************************************
--               Repack vehicules crates functions
-- ***************************************************************
ctld.repackRequestsStack = {} -- table to store the repack request
ctld.inAirMemorisation   = {} -- last helico state of InAir()
function ctld.updateRepackMenuOnlanding(p, t)       -- update helo repack menu when a helo landing is detected
    if t == nil then t = timer.getTime() + 1; end
    if ctld.transportPilotNames then
        for _, _unitName in pairs(ctld.transportPilotNames) do
            if Unit.getByName(_unitName) ~= nil and Unit.getByName(_unitName):isActive() == true then
                if ctld.inAirMemorisation[_unitName] == nil then ctld.inAirMemorisation[_unitName] = false end      -- init InAir() state
                local _heli = Unit.getByName(_unitName)
                if ctld.inAir(_heli) == false then
                    if  ctld.inAirMemorisation[_unitName] == true then  -- if transition from inAir to Landed => updateRepackMenu
                        ctld.updateRepackMenu(_unitName)
                    end
                    ctld.inAirMemorisation[_unitName] = false
                else
                    ctld.inAirMemorisation[_unitName] = true
                end
            end
        end
    end
    return t + 5        -- reschdule each 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInRepackRadius(_PlayerTransportUnitName, _radius)
    if _radius == nil then
        _radius = ctld.maximumDistanceRepackableUnitsSearch
    end

    local unit = ctld.getTransportUnit(_PlayerTransportUnitName)
    if unit == nil then
        return
    end

    local unitsNamesList  = ctld.getNearbyUnits(unit:getPoint(), _radius, unit:getCoalition())

    local repackableUnits = {}
    for i = 1, #unitsNamesList do
        local unitObject     = Unit.getByName(unitsNamesList[i])
        local repackableUnit = ctld.isRepackableUnit(unitsNamesList[i])
        if repackableUnit then
            repackableUnit["repackableUnitGroupID"] = unitObject:getGroup():getID()
            table.insert(repackableUnits, mist.utils.deepCopy(repackableUnit))
        end
    end
    return repackableUnits
end

-- ***************************************************************
function ctld.getNearbyUnits(_point, _radius, _coalition)
    if _coalition == nil then
        _coalition = 4         -- all coalitions
    end
    local unitsByDistance = {}
    local cpt = 1
    local _units = {}
    for _unitName, _ in pairs(mist.DBs.unitsByName) do
        local u = Unit.getByName(_unitName)
        local e = (u and u:isExist()) or false
        -- pcall is needed because getCoalition() fails if the unit is an object without coalition (like a smoke effect)
        local c = nil
        pcall(function() c = (u and e and u:getCoalition()) or nil end)
            if u and e and (_coalition == 4 or c == _coalition) then
            local _dist = mist.utils.get2DDist(u:getPoint(), _point)
            if _dist <= _radius then
                unitsByDistance[cpt] = {id =cpt, dist = _dist, unit = _unitName, typeName = u:getTypeName()}
                cpt = cpt + 1
            end
        end
    end

    --table.sort(unitsByDistance, function(a,b) return a.dist < b.dist end)       -- sort the table by distance (the nearest first)
    table.sort(unitsByDistance, function(a,b) return a.typeName < b.typeName end)   -- sort the table by typeNAme
    for i, v in ipairs(unitsByDistance) do
        table.insert(_units, v.unit)                 -- insert nearby unitName
    end
    return _units
end

-- ***************************************************************
function ctld.isRepackableUnit(_unitName)
    local unitObject = Unit.getByName(_unitName)
    local unitType   = unitObject:getTypeName()
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _unitName then
                if ctld.spawnableCrates[k][i].unit == unitType then
                    local repackableUnit = mist.utils.deepCopy(ctld.spawnableCrates[k][i])
                    repackableUnit["repackableUnitName"] = _unitName
                    return repackableUnit
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.getCrateDesc(_crateWeight)
    for k, v in pairs(ctld.spawnableCrates) do
        for i = 1, #ctld.spawnableCrates[k] do
            if _crateWeight then
                if ctld.spawnableCrates[k][i].weight == _crateWeight then
                    return ctld.spawnableCrates[k][i]
                end
            end
        end
    end
    return nil
end

-- ***************************************************************
function ctld.repackVehicleRequest(_params) -- update rrs table 'repackRequestsStack' with the request
    --ctld.logTrace("FG_    ctld.repackVehicleRequest._params = " .. ctld.p(_params))
    ctld.repackRequestsStack[#ctld.repackRequestsStack + 1] = _params
end

-- ***************************************************************
function ctld.repackVehicle(_params, t) -- scan rrs table 'repackRequestsStack' to process each request
    --ctld.logTrace("FG_ XXXXXXXXXXXXXXXXXXXXXXXXXXX ctld.repackVehicle.ctld.repackRequestsStack XXXXXXXXXXXXXXXXXXXXXXXXXXX")
    if t == nil then
        t = timer.getTime()
    end
    if #ctld.repackRequestsStack ~= 0 then
        ctld.logTrace("FG_    ctld.repackVehicle.ctld.repackRequestsStack = %s", ctld.p(ctld.repackRequestsStack))
    end
    for ii, v in ipairs(ctld.repackRequestsStack) do
        ctld.logTrace("FG_    ctld.repackVehicle.v[%s] = %s", ii, ctld.p(v))
        local repackableUnitName  = v.repackableUnitName
        local repackableUnit      = Unit.getByName(repackableUnitName)
        local crateWeight         = v.weight
        local playerUnitName      = v.playerUnitName
        if repackableUnit then
            if repackableUnit:isExist() then
                local PlayerTransportUnit = Unit.getByName(playerUnitName)
                local playerCoa           = PlayerTransportUnit:getCoalition()
                local refCountry          = PlayerTransportUnit:getCountry()
                -- calculate the heading of the spawns to be carried out
                local playerHeading  = mist.getHeading(PlayerTransportUnit)
                local playerPoint    = PlayerTransportUnit:getPoint()
                local offset         = 5
                local randomHeading  = ctld.RandomReal(playerHeading - math.pi/4, playerHeading + math.pi/4)
                if ctld.unitDynamicCargoCapable(PlayerTransportUnit) ~= false then
                    randomHeading  = ctld.RandomReal(playerHeading + math.pi - math.pi/4, playerHeading + math.pi + math.pi/4)
                end
                repackableUnit:destroy()                  -- destroy repacked unit
                for i = 1, v.cratesRequired or 1 do
                    -- see to spawn the crate at random position heading the transport unit
                    local _unitId        = ctld.getNextUnitId()
                    local _name          = string.format("%s_%i", v.desc, _unitId)
                    local secureDistance = ctld.getSecureDistanceFromUnit(playerUnitName) or 10
                    local relativePoint  = ctld.getRelativePoint(playerPoint, secureDistance + (i * offset), randomHeading) -- 7 meters from the transport unit

                    if ctld.unitDynamicCargoCapable(PlayerTransportUnit) == false then
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa, playerHeading, nil)
                    else
                        ctld.spawnCrateStatic(refCountry, _unitId, relativePoint, _name, crateWeight, playerCoa, playerHeading, "dynamic")
                    end
                end
            end
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1)  -- for add unpacked unit in repack menu
        end
        ctld.repackRequestsStack[ii] = nil                -- remove the processed request from the stacking table
    end



    if ctld.enableRepackingVehicles == true then
        return t + 3         -- reschedule the function in 3 seconds
    else
        return nil           --stop scheduling
    end
end

-- ***************************************************************
function ctld.addStaticLogisticUnit(_point, _country) -- create a temporary logistic unit with a Windsock object
    local dynamicLogisticUnitName = "%dynLogisticName_" .. tostring(ctld.getNextDynamicLogisticUnitIndex())
    ctld.logisticUnits[#ctld.logisticUnits + 1] = dynamicLogisticUnitName
    local LogUnit = {
        ["category"] = "Fortifications",
        ["shape_name"] = "H-Windsock_RW",
        ["type"] = "Windsock",
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = dynamicLogisticUnitName,
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    LogUnit["country"] = _country
    mist.dynAddStatic(LogUnit)
    return StaticObject.getByName(LogUnit["name"])
end

-- ***************************************************************
function ctld.updateDynamicLogisticUnitsZones() -- remove Dynamic Logistic Units if no statics units (crates) are in the zone
    local _units = {}
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if string.sub(logUnit, 1, 17) == "%dynLogisticName_" then         -- check if the unit is a dynamic logistic unit
            local unitsInLogisticUnitZone = ctld.getUnitsInLogisticZone(logUnit)
            if #unitsInLogisticUnitZone == 0 then
                local _logUnit = StaticObject.getByName(logUnit)
                if _logUnit then
                    _logUnit:destroy()                              -- destroy the    dynamic Logistic unit object from map
                    ctld.logisticUnits[i] = nil                     -- remove the dynamic Logistic unit from the list
                end
            end
        end
    end
    return 5     -- reschedule the function in 5 seconds
end

-- ***************************************************************
function ctld.getUnitsInLogisticZone(_logisticUnitName, _coalition)
    local _unit = StaticObject.getByName(_logisticUnitName)
    if _unit then
        local _point = _unit:getPoint()
        local _unitList = ctld.getNearbyUnits(_point, ctld.maximumDistanceLogistic, _coalition)
        return _unitList
    end
    return {}
end

-- ***************************************************************
function ctld.isUnitInNamedLogisticZone(_unitName, _logisticUnitName) -- check if a unit is in the named logistic zone
    --ctld.logTrace("FG_    ctld.isUnitInNamedLogisticZone._logisticUnitName = %s", ctld.p(_logisticUnitName))
    local _unit = Unit.getByName(_unitName)
    if _unit == nil then
        return false
    end
    local unitPoint = _unit:getPoint()
    if StaticObject.getByName(_logisticUnitName) then
        local logisticUnitPoint = StaticObject.getByName(_logisticUnitName):getPoint()
        local _dist = ctld.getDistance(unitPoint, logisticUnitPoint)
        if _dist <= ctld.maximumDistanceLogistic then
            return true
        end
    end
    return false
end

-- ***************************************************************
function ctld.isUnitInALogisticZone(_unitName) -- check if a unit is in a logistic zone if true then return the logisticUnitName of the zone
    --ctld.logTrace("FG_    ctld.isUnitInALogisticZone._unitName = %s", ctld.p(_unitName))
    for i, logUnit in ipairs(ctld.logisticUnits) do
        if ctld.isUnitInNamedLogisticZone(_unitName, logUnit) then
            return logUnit
        end
    end
    return nil
end

-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

--- Tells CTLD What multipart AA Systems there are and what parts they need
-- A New system added here also needs the launcher added
-- The number of times that each part is spawned for each system is specified by the entry "amount", NOTE : they will be spawned in a circle with the corresponding headings, NOTE 2 : launchers will use the default ctld.aaLauncher amount if nothing is specified
-- If a component does not require a crate, it can be specified via the entry "NoCrate" set to true
ctld.AASystemTemplate = {

    {
        name = "HAWK AA System",
        count = 5,
        parts = {
            { name = "Hawk ln",   desc = "HAWK Launcher",     launcher = true },
            { name = "Hawk tr",   desc = "HAWK Track Radar",  amount = 2 },
            { name = "Hawk sr",   desc = "HAWK Search Radar", amount = 2 },
            { name = "Hawk pcp",  desc = "HAWK PCP",          NoCrate = true },
            { name = "Hawk cwar", desc = "HAWK CWAR",         amount = 2,     NoCrate = true },
        },
        repair = "HAWK Repair",
    },
    {
        name = "Patriot AA System",
        count = 4,
        parts = {
            { name = "Patriot ln",  desc = "Patriot Launcher",               launcher = true, amount = 8 },
            { name = "Patriot ECS", desc = "Patriot Control Unit" },
            { name = "Patriot str", desc = "Patriot Search and Track Radar", amount = 2 },
            --{name = "Patriot cp", desc = "Patriot ICC", NoCrate = true},
            --{name = "Patriot EPP", desc = "Patriot EPP", NoCrate = true},
            { name = "Patriot AMG", desc = "Patriot AMG DL relay",           NoCrate = true },
        },
        repair = "Patriot Repair",
    },
    {
        name = "NASAMS AA System",
        count = 3,
        parts = {
            { name = "NASAMS_LN_C",          desc = "NASAMS Launcher 120C",     launcher = true },
            { name = "NASAMS_Radar_MPQ64F1", desc = "NASAMS Search/Track Radar" },
            { name = "NASAMS_Command_Post",  desc = "NASAMS Command Post" },
        },
        repair = "NASAMS Repair",
    },
    {
        name = "BUK AA System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher",    launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1",  desc = "BUK Search Radar" },
        },
        repair = "BUK Repair",
    },
    {
        name = "KUB AA System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln",  desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "KUB Repair",
    },
    {
        name = "S-300 AA System",
        count = 6,
        parts = {
            { desc = "S-300 Grumble TEL C",         name = "S-300PS 5P85C ln", launcher = true, amount = 1 },
            { desc = "S-300 Grumble TEL D",         name = "S-300PS 5P85D ln", NoCrate = true,  amount = 2 },
            { desc = "S-300 Grumble Flap Lid-A TR", name = "S-300PS 40B6M tr" },
            { desc = "S-300 Grumble Clam Shell SR", name = "S-300PS 40B6MD sr" },
            { desc = "S-300 Grumble Big Bird SR",   name = "S-300PS 64H6E sr" },
            { desc = "S-300 Grumble C2",            name = "S-300PS 54K6 cp" },
        },
        repair = "S-300 Repair",
    },
}


ctld.crateWait = {}
ctld.crateMove = {}

-----------------[[ END OF ME_functions.lua ]]-----------------
