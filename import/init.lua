-----------------[[ init.lua ]]-----------------
function ctld.initialize()
    ctld.logInfo(string.format("Initializing version %s", ctld.Version))

    assert(mist ~= nil,
        "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

    ctld.addedTo = {}
    ctld.spawnedCratesRED = {}        -- use to store crates that have been spawned
    ctld.spawnedCratesBLUE = {}       -- use to store crates that have been spawned

    ctld.droppedTroopsRED = {}        -- stores dropped troop groups
    ctld.droppedTroopsBLUE = {}       -- stores dropped troop groups

    ctld.droppedVehiclesRED = {}      -- stores vehicle groups for c-130 / hercules
    ctld.droppedVehiclesBLUE = {}     -- stores vehicle groups for c-130 / hercules

    ctld.inTransitTroops = {}

    ctld.inTransitFOBCrates = {}

    ctld.inTransitSlingLoadCrates = {}     -- stores crates that are being transported by helicopters for alternative to real slingload

    ctld.droppedFOBCratesRED = {}
    ctld.droppedFOBCratesBLUE = {}

    ctld.builtFOBS = {}                -- stores fully built fobs

    ctld.completeAASystems = {}        -- stores complete spawned groups from multiple crates

    ctld.fobBeacons = {}               -- stores FOB radio beacon details, refreshed every 60 seconds

    ctld.deployedRadioBeacons = {}     -- stores details of deployed radio beacons

    ctld.beaconCount = 1

    ctld.usedUHFFrequencies = {}
    ctld.usedVHFFrequencies = {}
    ctld.usedFMFrequencies = {}

    ctld.freeUHFFrequencies = {}
    ctld.freeVHFFrequencies = {}
    ctld.freeFMFrequencies = {}

    --used to lookup what the crate will contain
    ctld.crateLookupTable = {}

    ctld.extractZones = {}                 -- stored extract zones

    ctld.missionEditorCargoCrates = {}     -- crates added by mission editor for triggering cratesinzone
    ctld.hoverStatus = {}                  -- tracks status of a helis hover above a crate

    ctld.callbacks = {}                    -- function callback
    ctld.vehicleCommandsPath = {}          -- memory of F10 c=CTLD menu path bay unitNames

    -- Remove intransit troops when heli / cargo plane dies
    --ctld.eventHandler = {}
    --function ctld.eventHandler:onEvent(_event)
    --
    --        if _event == nil or _event.initiator == nil then
    --                env.info("CTLD null event")
    --        elseif _event.id == 9 then
    --                -- Pilot dead
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --        elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
    --                -- env.info("Event unit - Pilot Ejected or Unit Dead")
    --                ctld.inTransitTroops[_event.initiator:getName()] = nil
    --
    --                -- env.info(_event.initiator:getName())
    --        end
    --
    --end

    -- create crate lookup table
    for _subMenuName, _crates in pairs(ctld.spawnableCrates) do
        for _, _crate in pairs(_crates) do
            -- convert number to string otherwise we'll have a pointless giant
            -- table. String means 'hashmap' so it will only contain the right number of elements
            if _crate.multiple then
                local _totalWeight = 0
                for _, _weight in pairs(_crate.multiple) do
                    _totalWeight = _totalWeight + _weight
                end
                _crate.weight = _totalWeight
            end
            ctld.crateLookupTable[tostring(_crate.weight)] = _crate
        end
    end


    --sort out pickup zones
    for _, _zone in pairs(ctld.pickupZones) do
        local _zoneName = _zone[1]
        local _zoneColor = _zone[2]
        local _zoneActive = _zone[4]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1             -- no smoke colour
        end

        -- add in counter for troops or units
        if _zone[3] == -1 then
            _zone[3] = 10000;
        end

        -- change active to 1 / 0
        if _zoneActive == "yes" then
            _zone[4] = 1
        else
            _zone[4] = 0
        end
    end

    --sort out dropoff zones
    for _, _zone in pairs(ctld.dropOffZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1             -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        _zone[4] = 1
    end

    --sort out waypoint zones
    for _, _zone in pairs(ctld.wpZones) do
        local _zoneColor = _zone[2]

        if _zoneColor == "green" then
            _zone[2] = trigger.smokeColor.Green
        elseif _zoneColor == "red" then
            _zone[2] = trigger.smokeColor.Red
        elseif _zoneColor == "white" then
            _zone[2] = trigger.smokeColor.White
        elseif _zoneColor == "orange" then
            _zone[2] = trigger.smokeColor.Orange
        elseif _zoneColor == "blue" then
            _zone[2] = trigger.smokeColor.Blue
        else
            _zone[2] = -1             -- no smoke colour
        end

        --mark as active for refresh smoke logic to work
        -- change active to 1 / 0
        if _zone[3] == "yes" then
            _zone[3] = 1
        else
            _zone[3] = 0
        end
    end

    -- Sort out extractable groups
    for _, _groupName in pairs(ctld.extractableGroups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            if _group:getCoalition() == 1 then
                table.insert(ctld.droppedTroopsRED, _group:getName())
            else
                table.insert(ctld.droppedTroopsBLUE, _group:getName())
            end
        end
    end


    -- Seperate troop teams into red and blue for random AI pickups
    if ctld.allowRandomAiTeamPickups == true then
        ctld.redTeams = {}
        ctld.blueTeams = {}
        for _, _loadGroup in pairs(ctld.loadableGroups) do
            if not _loadGroup.side then
                table.insert(ctld.redTeams, _)
                table.insert(ctld.blueTeams, _)
            elseif _loadGroup.side == 1 then
                table.insert(ctld.redTeams, _)
            elseif _loadGroup.side == 2 then
                table.insert(ctld.blueTeams, _)
            end
        end
    end

    -- add total count

    for _, _loadGroup in pairs(ctld.loadableGroups) do
        _loadGroup.total = 0
        if _loadGroup.aa then
            _loadGroup.total = _loadGroup.aa + _loadGroup.total
        end

        if _loadGroup.inf then
            _loadGroup.total = _loadGroup.inf + _loadGroup.total
        end


        if _loadGroup.mg then
            _loadGroup.total = _loadGroup.mg + _loadGroup.total
        end

        if _loadGroup.at then
            _loadGroup.total = _loadGroup.at + _loadGroup.total
        end

        if _loadGroup.mortar then
            _loadGroup.total = _loadGroup.mortar + _loadGroup.total
        end
    end

    --*************************************************************************************************
    -- Scheduled functions (run cyclically) -- but hold execution for a second so we can override parts
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 1)
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 5)

    timer.scheduleFunction(function()
        timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.addOtherF10MenuOptions, nil, timer.getTime() + 5)
        timer.scheduleFunction(ctld.updateDynamicLogisticUnitsZones, nil, timer.getTime() + 5)
        if ctld.enableCrates == true and ctld.hoverPickup == true then
            timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1)
        end
        if ctld.enableRepackingVehicles == true then
            timer.scheduleFunction(ctld.updateRepackMenuOnlanding, nil, timer.getTime() + 1)    -- update helo repack menu when a helo landing is detected
            timer.scheduleFunction(ctld.repackVehicle, nil, timer.getTime() + 1)
        end
        if ctld.enableAutoOrbitingFlyingJtacOnTarget then
            timer.scheduleFunction(ctld.TreatOrbitJTAC, {}, timer.getTime()+3)
        end
        if ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0 then
            timer.scheduleFunction(ctld.updateTroopsInGame, {}, timer.getTime()+1)
        end
    end, nil, timer.getTime() + 1)

    --event handler for deaths
    --world.addEventHandler(ctld.eventHandler)

    --env.info("CTLD event handler added")

    env.info("Generating Laser Codes")
    ctld.generateLaserCode()
    env.info("Generated Laser Codes")



    env.info("Generating UHF Frequencies")
    ctld.generateUHFrequencies()
    env.info("Generated    UHF Frequencies")

    env.info("Generating VHF Frequencies")
    ctld.generateVHFrequencies()
    env.info("Generated VHF Frequencies")


    env.info("Generating FM Frequencies")
    ctld.generateFMFrequencies()
    env.info("Generated FM Frequencies")

    -- Search for crates
    -- Crates are NOT returned by coalition.getStaticObjects() for some reason
    -- Search for crates in the mission editor instead
    env.info("Searching for Crates")
    for _coalitionName, _coalitionData in pairs(env.mission.coalition) do
        if (_coalitionName == 'red' or _coalitionName == 'blue')
            and type(_coalitionData) == 'table' then
            if _coalitionData.country then             --there is a country table
                for _, _countryData in pairs(_coalitionData.country) do
                    if type(_countryData) == 'table' then
                        for _objectTypeName, _objectTypeData in pairs(_countryData) do
                            if _objectTypeName == "static" then
                                if ((type(_objectTypeData) == 'table')
                                        and _objectTypeData.group
                                        and (type(_objectTypeData.group) == 'table')
                                        and (#_objectTypeData.group > 0)) then
                                    for _groupId, _group in pairs(_objectTypeData.group) do
                                        if _group and _group.units and type(_group.units) == 'table' then
                                            for _unitNum, _unit in pairs(_group.units) do
                                                if _unit.canCargo == true then
                                                    local _cargoName = env.getValueDictByKey(_unit.name)
                                                    ctld.missionEditorCargoCrates[_cargoName] = _cargoName
                                                    env.info("Crate Found: " .. _unit.name .. " - Unit: " .. _cargoName)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    env.info("END search for crates")

    -- register event handler
    ctld.logInfo("registering event handler")
    world.addEventHandler(ctld.eventHandler)
    env.info("CTLD READY")
end

--- Handle world events.
ctld.eventHandler = {}
function ctld.eventHandler:onEvent(event)
    --ctld.logTrace("ctld.eventHandler:onEvent()")
    if event == nil then
        ctld.logError("Event handler was called with a nil event!")
        return
    end

    local eventName = "unknown"
    -- check that we know the event
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        eventName = "S_EVENT_PLAYER_ENTER_UNIT"
    elseif event.id == world.event.S_EVENT_BIRTH then
        eventName = "S_EVENT_BIRTH"
    else
        --ctld.logTrace("Ignoring event %s", ctld.p(event))
        return
    end
    ctld.logDebug("caught event %s: %s", ctld.p(eventName), ctld.p(event))

    -- find the originator unit
    local unitName = nil
    if event.initiator ~= nil and event.initiator.getName then
        unitName = event.initiator:getName()
        ctld.logDebug("unitName = [%s]", ctld.p(unitName))
    end
    if not unitName then
        ctld.logInfo("no unitname found in event %s", ctld.p(event))
        return
    end

    local function processHumanPlayer()
        ctld.logTrace("in the 'processHumanPlayer' function processHumanPlayer()- unitName = %s", ctld.p(unitName))
        --ctld.logTrace("in the 'processHumanPlayer' function processHumanPlayer()- mist.DBs.humansByName[unitName] = %s", ctld.p(mist.DBs.humansByName[unitName]))
        if mist.DBs.humansByName[unitName] then         -- it's a human unit
            ctld.logDebug("caught event %s for human unit [%s]", ctld.p(eventName), ctld.p(unitName))
            local _unit = Unit.getByName(unitName)
            if _unit ~= nil then
                local _groupId = _unit:getGroup():getID()
                -- assign transport pilot
                ctld.logTrace("_unit = %s", ctld.p(_unit))

                local playerTypeName = _unit:getTypeName()
                ctld.logTrace("playerTypeName = %s", ctld.p(playerTypeName))

                -- Allow units to CTLD by aircraft type and not by pilot name
                if ctld.addPlayerAircraftByType then
                    for _, aircraftType in pairs(ctld.aircraftTypeTable) do
                        if aircraftType == playerTypeName then
                            ctld.logTrace("adding by aircraft type, unitName = %s", ctld.p(unitName))
                            if ctld.tools.isValueInIpairTable(ctld.transportPilotNames, unitName) == false then
                                table.insert(ctld.transportPilotNames, unitName)  -- add transport unit to the list
                            end
                            if ctld.addedTo[tostring(_groupId)] == nil then  -- only if menu not already set up
                                ctld.addTransportF10MenuOptions(unitName)    -- add transport radio menu
                                break
                            end
                        end
                    end
                else
                    for _, _unitName in pairs(ctld.transportPilotNames) do
                        if _unitName == unitName then
                            ctld.logTrace("adding by transportPilotNames, unitName = %s", ctld.p(unitName))
                            ctld.addTransportF10MenuOptions(unitName)                             -- add transport radio menu
                            break
                        end
                    end
                end
            end
        end
    end

    if not mist.DBs.humansByName[unitName] then
        -- give a few milliseconds for MiST to handle the BIRTH event too
        ctld.logTrace("NOT IN MIST humansByName yet - scheduling a timer to call processHumanPlayer() for - ".. unitName);
        ctld.logTrace("give MiST some time to handle the BIRTH event too")
        timer.scheduleFunction(function()
            ctld.logTrace("calling the 'processHumanPlayer' function in a timer")
            processHumanPlayer()
        end, nil, timer.getTime() + 2)      --1.5
    else
        ctld.logTrace("calling the 'processHumanPlayer' function immediately")
        processHumanPlayer()
    end
end

function ctld.i18n_check(language, verbose)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        ctld.logError(string.format("CTLD.i18n_check: Language %s not found", language))
        return false
    end
    local englishVersion = english.translation_version
    local tocheckVersion = tocheck.translation_version
    if englishVersion ~= tocheckVersion then
        ctld.logError(string.format("CTLD.i18n_check: Language version mismatch: EN has version %s, %s has version %s",
            englishVersion, language, tocheckVersion))
    end
    --ctld.logTrace(string.format("english = %s", ctld.p(english)))
    for textRef, textEnglish in pairs(english) do
        if textRef ~= "translation_version" then
            local textTocheck = tocheck[textRef]
            if not textTocheck then
                ctld.logError(string.format("CTLD.i18n_check: NOT FOUND: checking %s text [%s]", language, textRef))
            elseif textTocheck == textEnglish then
                ctld.logWarning(string.format("CTLD.i18n_check:         SAME: checking %s text [%s] as in EN", language,
                    textRef))
            elseif verbose then
                ctld.logInfo(string.format("CTLD.i18n_check:             OK: checking %s text [%s]", language, textRef))
            end
        end
    end
end

-- example of usage:
--ctld.i18n_check("fr")


-- initialize the random number generator to make it almost random
math.random(); math.random(); math.random()

function ctld.RandomReal(mini, maxi)
    local rand = math.random() --random value between 0 and 1
    local result = mini + rand * (maxi - mini)	--	scale the random value between [mini, maxi]
    return result
end

-- Tools
ctld.tools = {}
function ctld.tools.isValueInIpairTable(tab, value)
    for i, v in ipairs(tab) do
      if v == value then
        return true -- La valeur existe
      end
    end
    return false -- La valeur n'existe pas
  end
------------------------------------------------------------------------------------
--- Calculates the orientation of an end point relative to a reference point.
--- The calculation takes into account the current orientation of the reference point.
---
--- @param refLat number Latitude of the reference point in degrees.
--- @param refLon number Longitude of the reference point in degrees.
--- @param refHeading number Current orientation of the reference point in degrees (0 = North, 90 = East).
--- @param destLat number Latitude of the arrival point in degrees.
--- @param destLon number Longitude of the arrival point in degrees.
--- @param resultFormat string The desired output format: "radian", "degree" or "clock".
--- @return number The relative orientation in the specified resultFormat.
function ctld.tools.getRelativeBearing(refLat, refLon, refHeading, destLat, destLon, resultFormat)
  -- Converting degrees to radians for geometric calculations
  local radrefLat = math.rad(refLat)
  local raddestLat = math.rad(destLat)
  local radrefLon = math.rad(refLon)
  local raddestLon = math.rad(destLon)
  local radrefHeading = math.rad(refHeading)

  -- Calculating the longitude difference between the two points
  local deltaLon = raddestLon - radrefLon

  -- Using the great circle formula for azimuth (bearing)
  -- This formula is based on spherical trigonometry and uses atan2
  -- to correctly handle all quadrants.
  local y = math.sin(deltaLon) * math.cos(raddestLat)
  local x = math.cos(radrefLat) * math.sin(raddestLat) - math.sin(radrefLat) * math.cos(raddestLat) * math.cos(deltaLon)
  local absoluteBearingRad = math.atan2(y, x)

  -- Calculate relative orientation by subtracting the reference refHeading
  local relativeBearingRad = absoluteBearingRad - radrefHeading

  -- Normalizes the angle to be in the range [-pi, pi]
  -- This ensures a consistent angle, whether positive or negative.
  local normalizedRad = (relativeBearingRad + math.pi) % (2 * math.pi) - math.pi

  -- Returns the value in the requested resultFormat
  if resultFormat == "radian" then
    return normalizedRad, resultFormat
  elseif resultFormat == "clock" then
    -- Convert to clock position (12h = front, 3h = right, 6h = back, etc..)
    local bearingDeg = math.deg(normalizedRad)
    local clockPosition = ((bearingDeg + 360) % 360) / 30
    clockPosition =  clockPosition >= 0 and math.floor(clockPosition + 0.5) or math.ceil(clockPosition - 0.5), resultFormat		-- rounded clockPosition
    if clockPosition == 0 then clockPosition = 12 end
    return clockPosition, resultFormat
  else -- By default, the resultFormat is "degree"
    resultFormat = "degree"
    local bearingDeg = math.deg(normalizedRad)
    return (bearingDeg + 360) % 360, resultFormat
  end
end

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

-- initialize CTLD
-- if you need to have a chance to modify the configuration before initialization in your other scripts, please set ctld.dontInitialize to true and call ctld.initialize() manually
if ctld.dontInitialize then
    ctld.logInfo(string.format("Skipping initializion of version %s because ctld.dontInitialize is true", ctld.Version))
else
    ctld.logInfo(string.format("CTLD - Initializing version %s", ctld.Version))
    ctld.initialize()
end
-----------------[[ END OF init.lua ]]-----------------
