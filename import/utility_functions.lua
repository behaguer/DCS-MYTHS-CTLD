-----------------[[ utility_functions.lua ]]-----------------

--- print an object for a debugging log
function ctld.p(o, level)
    local MAX_LEVEL = 20
    if level == nil then level = 0 end
    if level > MAX_LEVEL then
        ctld.logError("max depth reached in ctld.p : " .. tostring(MAX_LEVEL))
        return ""
    end
    local text = ""
    if (type(o) == "table") then
        text = "\n"
        for key, value in pairs(o) do
            for i = 0, level do
                text = text .. " "
            end
            text = text .. "." .. key .. "=" .. ctld.p(value, level + 1) .. "\n"
        end
    elseif (type(o) == "function") then
        text = "[function]"
    elseif (type(o) == "boolean") then
        if o == true then
            text = "[true]"
        else
            text = "[false]"
        end
    else
        if o == nil then
            text = "[nil]"
        else
            text = tostring(o)
        end
    end
    return text
end

function ctld.formatText(text, ...)
    if not text then
        return ""
    end
    if type(text) ~= 'string' then
        text = ctld.p(text)
    else
        local args = ...
        if args and args.n and args.n > 0 then
            local pArgs = {}
            for i = 1, args.n do
                pArgs[i] = ctld.p(args[i])
            end
            text = text:format(unpack(pArgs))
        end
    end
    local fName = nil
    local cLine = nil
    if debug and debug.getinfo then
        local dInfo = debug.getinfo(3)
        fName = dInfo.name
        cLine = dInfo.currentline
    end
    if fName and cLine then
        return fName .. '|' .. cLine .. ': ' .. text
    elseif cLine then
        return cLine .. ': ' .. text
    else
        return ' ' .. text
    end
end

function ctld.logError(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" E - " .. ctld.Id .. message)
end

function ctld.logWarning(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" W - " .. ctld.Id .. message)
end

function ctld.logInfo(message, ...)
    message = ctld.formatText(message, arg)
    env.info(" I - " .. ctld.Id .. message)
end

function ctld.logDebug(message, ...)
    if message and ctld.Debug then
        message = ctld.formatText(message, arg)
        env.info(" D - " .. ctld.Id .. message)
    end
end

function ctld.logTrace(message, ...)
    if message and ctld.Trace then
        message = ctld.formatText(message, arg)
        env.info(" T - " .. ctld.Id .. message)
    end
end

ctld.nextUnitId = 1;
ctld.getNextUnitId = function()
    ctld.nextUnitId = ctld.nextUnitId + 1

    return ctld.nextUnitId
end

ctld.nextGroupId = 1;

ctld.getNextGroupId = function()
    ctld.nextGroupId = ctld.nextGroupId + 1

    return ctld.nextGroupId
end

function ctld.getTransportUnit(_unitName)
    if _unitName == nil then
        return nil
    end

    local transportUnitObject = Unit.getByName(_unitName)

    if transportUnitObject ~= nil and transportUnitObject:isActive() and transportUnitObject:getLife() > 0 then
        return transportUnitObject
    end
    return nil
end

function ctld.spawnCrateStatic(_country, _unitId, _point, _name, _weight, _side, _hdg, _model_type)
    local _crate
    local _spawnedCrate

    local hdg = _hdg or 0

    if ctld.staticBugWorkaround and ctld.slingLoad == false then
        local _groupId = ctld.getNextGroupId()
        local _groupName = "Crate Group #" .. _groupId

        local _group = {
            ["visible"] = false,
            -- ["groupId"] = _groupId,
            ["hidden"] = false,
            ["units"] = {},
            --                ["y"] = _positions[1].z,
            --                ["x"] = _positions[1].x,
            ["name"] = _groupName,
            ["task"] = {},
        }

        _group.units[1] = ctld.createUnit(_point.x, _point.z, hdg, { type = "UAZ-469", name = _name, unitId = _unitId })

        --switch to MIST
        _group.category = Group.Category.GROUND;
        _group.country = _country;

        local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

        -- Turn off AI
        trigger.action.setGroupAIOff(_spawnedGroup)

        _spawnedCrate = Unit.getByName(_name)
    else
        if _model_type ~= nil then
            _crate = mist.utils.deepCopy(ctld.spawnableCratesModels[_model_type])
        elseif ctld.slingLoad then
            _crate = mist.utils.deepCopy(ctld.spawnableCratesModels["sling"])
        else
            _crate = mist.utils.deepCopy(ctld.spawnableCratesModels["load"])
        end

        _crate["y"] = _point.z
        _crate["x"] = _point.x
        _crate["mass"] = _weight
        _crate["name"] = _name
        _crate["heading"] = hdg
        _crate["country"] = _country

        mist.dynAddStatic(_crate)

        _spawnedCrate = StaticObject.getByName(_crate["name"])
    end


    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _side == 1 then
        ctld.spawnedCratesRED[_name] = _crateType
    else
        ctld.spawnedCratesBLUE[_name] = _crateType
    end

    return _spawnedCrate
end

function ctld.spawnFOBCrateStatic(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["shape_name"] = "konteiner_red1",
        ["type"] = "Container red 1",
        --     ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country

    mist.dynAddStatic(_crate)

    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end

function ctld.spawnFOB(_country, _unitId, _point, _name)
    local _crate = {
        ["category"] = "Fortifications",
        ["type"] = "outpost",
        --    ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country
    mist.dynAddStatic(_crate)
    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    local _id = ctld.getNextUnitId()
    local _tower = {
        ["type"] = "house2arm",
        --     ["unitId"] = _id,
        ["rate"] = 100,
        ["y"] = _point.z + -36.57142857,
        ["x"] = _point.x + 14.85714286,
        ["name"] = "FOB Watchtower #" .. _id,
        ["category"] = "Fortifications",
        ["canCargo"] = false,
        ["heading"] = 0,
    }
    --coalition.addStaticObject(_country, _tower)
    _tower["country"] = _country

    mist.dynAddStatic(_tower)

    return _spawnedCrate
end

function ctld.spawnCrate(_arguments, bypassCrateWaitTime)
    local _status, _err = pcall(function(_args)
        -- use the cargo weight to guess the type of unit as no way to add description :(
        local _crateType = ctld.crateLookupTable[tostring(_args[2])]
        local _heli = ctld.getTransportUnit(_args[1])
        if not _heli then
            return
        end

        -- check crate spam
        if not (bypassCrateWaitTime) and _heli:getPlayerName() ~= nil and ctld.crateWait[_heli:getPlayerName()] and ctld.crateWait[_heli:getPlayerName()] > timer.getTime() then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("Sorry you must wait %1 seconds before you can get another crate",
                    (ctld.crateWait[_heli:getPlayerName()] - timer.getTime())), 20)
            return
        end

        if _crateType and _crateType.multiple then
            for _, weight in pairs(_crateType.multiple) do
                local _aCrateType = ctld.crateLookupTable[tostring(weight)]
                if _aCrateType then
                    ctld.spawnCrate({ _args[1], _aCrateType.weight }, true)
                end
            end
            return
        end

        if _crateType ~= nil and _heli ~= nil and ctld.inAir(_heli) == false then
            if ctld.inLogisticsZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You are not close enough to friendly logistics to get a crate!"), 10)
                return
            end

            if ctld.isJTACUnitType(_crateType.unit) then
                local _limitHit = false

                if _heli:getCoalition() == 1 then
                    if ctld.JTAC_LIMIT_RED == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_RED = ctld.JTAC_LIMIT_RED - 1
                    end
                else
                    if ctld.JTAC_LIMIT_BLUE == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_BLUE = ctld.JTAC_LIMIT_BLUE - 1
                    end
                end

                if _limitHit then
                    ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No more JTAC Crates Left!"), 10)
                    return
                end
            end

            if _heli:getPlayerName() ~= nil then
                ctld.crateWait[_heli:getPlayerName()] = timer.getTime() + ctld.crateWaitTime
            end

            local _heli = ctld.getTransportUnit(_args[1])

            local _model_type = nil

            local _point = ctld.getPointAt12Oclock(_heli, 15)
            local _position = "12"

            if ctld.unitDynamicCargoCapable(_heli) then
                _model_type = "dynamic"
                _point = ctld.getPointAt6Oclock(_heli, ctld.getSecureDistanceFromUnit(_heli))
                _position = "6"
            end

            local _unitId = ctld.getNextUnitId()

            local _side = _heli:getCoalition()

            local _name = string.format("%s #%i", _crateType.desc, _unitId)

            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crateType.weight, _side, 0, _model_type)

            -- add to move table
            ctld.crateMove[_name] = _name
                
            local refPoint = _heli:getPoint()
            local refLat, refLon = coord.LOtoLL(refPoint)
            local unitPos = _heli:getPosition()
   			local refHeading = math.deg(math.atan2(unitPos.x.z, unitPos.x.x))
 
            local destLat, destLon, destAlt = coord.LOtoLL(_point)	

            local relativePos, forma = ctld.tools.getRelativeBearing(refLat, refLon, refHeading, destLat, destLon, 'clock')
                
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock ",
                    _crateType.desc, _crateType.weight, relativePos), 20)
        else
            env.info("Couldn't find crate item to spawn")
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

ctld.randomCrateSpacing = 15 -- meters

function ctld.getPointAt12Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, 0)
end

function ctld.getPointAt6Oclock(_unit, _offset)
    return ctld.getPointAtDirection(_unit, _offset, math.pi)
end

function ctld.getPointInFrontSector(_unit, _offset)
    if _unit then
        local playerHeading = mist.getHeading(_unit)
        local randomHeading  = ctld.RandomReal(playerHeading - math.pi/4, playerHeading + math.pi/4)
        if _offset == nil then
            _offset = 20
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function  ctld.getPointInRearSector(_unit, _offset)
    if _unit then
        local playerHeading = mist.getHeading(_unit)
        local randomHeading  = ctld.RandomReal(playerHeading + math.pi - math.pi/4, playerHeading + math.pi + math.pi/4)
        if _offset == nil then
            _offset = 30
        end
        return ctld.getPointAtDirection(_unit, _offset, randomHeading)
    end
end

function ctld.getPointAtDirection(_unit, _offset, _directionInRadian)
    if _offset == nil then
        _offset = ctld.getSecureDistanceFromUnit(_unit:getName())
    end
    --ctld.logTrace("_offset = %s", ctld.p(_offset))
    local _randomOffsetX = math.random(0, ctld.randomCrateSpacing * 2) - ctld.randomCrateSpacing
    local _randomOffsetZ = math.random(0, ctld.randomCrateSpacing)
    --ctld.logTrace("_randomOffsetX = %s", ctld.p(_randomOffsetX))
    --ctld.logTrace("_randomOffsetZ = %s", ctld.p(_randomOffsetZ))
    local _position = _unit:getPosition()
    local _angle    = math.atan(_position.x.z, _position.x.x) + _directionInRadian
    local _xOffset  = math.cos(_angle) * (_offset + _randomOffsetX)
    local _zOffset  = math.sin(_angle) * (_offset + _randomOffsetZ)
    local _point    = _unit:getPoint()
    return { x = _point.x + _xOffset, z = _point.z + _zOffset, y = _point.y }
end

function ctld.getRelativePoint(_refPointXZTable, _distance, _angle_radians)  -- return coord point at distance and angle from _refPointXZTable
    local relativePoint = {}
    relativePoint.x = _refPointXZTable.x + _distance * math.cos(_angle_radians)
    if _refPointXZTable.z == nil then
        relativePoint.y = _refPointXZTable.y + _distance * math.sin(_angle_radians)
    else
        relativePoint.z = _refPointXZTable.z + _distance * math.sin(_angle_radians)
    end
    return relativePoint
end

function ctld.troopsOnboard(_heli, _troops)
    if ctld.inTransitTroops[_heli:getName()] ~= nil then
        local _onboard = ctld.inTransitTroops[_heli:getName()]

        if _troops then
            if _onboard.troops ~= nil and _onboard.troops.units ~= nil and #_onboard.troops.units > 0 then
                return true
            else
                return false
            end
        else
            if _onboard.vehicles ~= nil and _onboard.vehicles.units ~= nil and #_onboard.vehicles.units > 0 then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

-- if its dropped by AI then there is no player name so return the type of unit
function ctld.getPlayerNameOrType(_heli)
    if _heli:getPlayerName() == nil then
        return _heli:getTypeName()
    else
        return _heli:getPlayerName()
    end
end

function ctld.inExtractZone(_heli)
    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.extractZones) do
        --get distance to center
        local _dist = ctld.getDistance(_heliPoint, _zoneDetails.point)

        if _dist <= _zoneDetails.radius then
            return _zoneDetails
        end
    end

    return false
end

-- safe to fast rope if speed is less than 0.5 Meters per second
function ctld.safeToFastRope(_heli)
    if ctld.enableFastRopeInsertion == false then
        return false
    end

    --landed or speed is less than 8 km/h and height is less than fast rope height
    if (ctld.inAir(_heli) == false or (ctld.heightDiff(_heli) <= ctld.fastRopeMaximumHeight + 3.0 and mist.vec.mag(_heli:getVelocity()) < 2.2)) then
        return true
    end
end

function ctld.metersToFeet(_meters)
    local _feet = _meters * 3.2808399

    return mist.utils.round(_feet)
end

function ctld.inAir(_heli)
    if _heli:inAir() == false then
        return false
    end

    -- less than 5 cm/s a second so landed
    -- BUT AI can hold a perfect hover so ignore AI
    if mist.vec.mag(_heli:getVelocity()) < 0.05 and _heli:getPlayerName() ~= nil then
        return false
    end
    return true
end

function ctld.deployTroops(_heli, _troops)
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    -- deloy troops
    if _troops then
        if _onboard.troops ~= nil and #_onboard.troops.units > 0 then
            if ctld.inAir(_heli) == false or ctld.safeToFastRope(_heli) then
                -- check we're not in extract zone
                local _extractZone = ctld.inExtractZone(_heli)

                if _extractZone == false then
                    local _droppedTroops = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.troops, false)
                    if _onboard.troops.jtac or _droppedTroops:getName():lower():find("jtac") then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)
                        ctld.JTACStart(_droppedTroops:getName(), _code)
                    end

                    if _heli:getCoalition() == 1 then
                        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
                    else
                        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
                    end

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into combat",
                                ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into combat", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName()), 10)
                    end

                    ctld.processCallback({ unit = _heli, unloaded = _droppedTroops, action = "dropped_troops" })
                else
                    --extract zone!
                    local _droppedCount = trigger.misc.getUserFlag(_extractZone.flag)

                    _droppedCount = (#_onboard.troops.units) + _droppedCount

                    trigger.action.setUserFlag(_extractZone.flag, _droppedCount)

                    ctld.inTransitTroops[_heli:getName()].troops = nil
                    ctld.adaptWeightToCargo(_heli:getName())

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 fast-ropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 dropped troops from %2 into %3", ctld.getPlayerNameOrType(_heli),
                                _heli:getTypeName(), _extractZone.name), 10)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Too high or too fast to drop troops into combat! Hover below %1 feet or land.",
                        ctld.metersToFeet(ctld.fastRopeMaximumHeight)), 10)
            end
        end
    else
        if ctld.inAir(_heli) == false then
            if _onboard.vehicles ~= nil and #_onboard.vehicles.units > 0 then
                local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.vehicles, true)

                if _heli:getCoalition() == 1 then
                    table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
                else
                    table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
                end

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
                ctld.adaptWeightToCargo(_heli:getName())

                ctld.processCallback({ unit = _heli, unloaded = _droppedVehicles, action = "dropped_vehicles" })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 dropped vehicles from %2 into combat", ctld.getPlayerNameOrType(_heli),
                        _heli:getTypeName()), 10)
            end
        end
    end
end

function ctld.insertIntoTroopsArray(_troopType, _count, _troopArray, _troopName)
    for _i = 1, _count do
        local _unitId = ctld.getNextUnitId()
        table.insert(_troopArray,
            { type = _troopType, unitId = _unitId, name = string.format("Dropped %s #%i", _troopName or _troopType,
                _unitId) })
    end

    return _troopArray
end

function ctld.generateTroopTypes(_side, _countOrTemplate, _country)
    local _troops = {}
    local _weight = 0
    local _hasJTAC = false

    local function getSoldiersWeight(count, additionalWeight)
        local _weight = 0
        for i = 1, count do
            local _soldierWeight = math.random(90, 120) * ctld.SOLDIER_WEIGHT / 100
            _weight = _weight + _soldierWeight + ctld.KIT_WEIGHT + additionalWeight
        end
        return _weight
    end

    if type(_countOrTemplate) == "table" then
        if _countOrTemplate.aa then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier stinger", _countOrTemplate.aa, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("SA-18 Igla manpad", _countOrTemplate.aa, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.aa, ctld.MANPAD_WEIGHT)
        end

        if _countOrTemplate.inf then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.inf, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.inf, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.inf, ctld.RIFLE_WEIGHT)
        end

        if _countOrTemplate.mg then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M249", _countOrTemplate.mg, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Paratrooper AKS-74", _countOrTemplate.mg, _troops)
            end
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mg, ctld.MG_WEIGHT)
        end

        if _countOrTemplate.at then
            _troops = ctld.insertIntoTroopsArray("Paratrooper RPG-16", _countOrTemplate.at, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.at, ctld.RPG_WEIGHT)
        end

        if _countOrTemplate.mortar then
            _troops = ctld.insertIntoTroopsArray("2B11 mortar", _countOrTemplate.mortar, _troops)
            _weight = _weight + getSoldiersWeight(_countOrTemplate.mortar, ctld.MORTAR_WEIGHT)
        end

        if _countOrTemplate.jtac then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4 GRG", _countOrTemplate.jtac, _troops, "JTAC")
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.jtac, _troops, "JTAC")
            end
            _hasJTAC = true
            _weight = _weight + getSoldiersWeight(_countOrTemplate.jtac, ctld.JTAC_WEIGHT + ctld.RIFLE_WEIGHT)
        end
    else
        for _i = 1, _countOrTemplate do
            local _unitType = "Infantry AK"

            if _side == 2 then
                if _i <= 2 then
                    _unitType = "Soldier M249"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "Soldier stinger"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Soldier M4 GRG"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            else
                if _i <= 2 then
                    _unitType = "Paratrooper AKS-74"
                    _weight = _weight + getSoldiersWeight(1, ctld.MG_WEIGHT)
                elseif ctld.spawnRPGWithCoalition and _i > 2 and _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                    _weight = _weight + getSoldiersWeight(1, ctld.RPG_WEIGHT)
                elseif ctld.spawnStinger and _i > 4 and _i <= 5 then
                    _unitType = "SA-18 Igla manpad"
                    _weight = _weight + getSoldiersWeight(1, ctld.MANPAD_WEIGHT)
                else
                    _unitType = "Infantry AK"
                    _weight = _weight + getSoldiersWeight(1, ctld.RIFLE_WEIGHT)
                end
            end

            local _unitId = ctld.getNextUnitId()

            _troops[_i] = { type = _unitType, unitId = _unitId, name = string.format("Dropped %s #%i", _unitType, _unitId) }
        end
    end

    local _groupId = ctld.getNextGroupId()
    local _groupName = "Dropped Group"
    if _hasJTAC then
        _groupName = "Dropped JTAC Group"
    end
    local _details = { units = _troops, groupId = _groupId, groupName = string.format("%s %i", _groupName, _groupId), side =
    _side, country = _country, weight = _weight, jtac = _hasJTAC }

    return _details
end

--Special F10 function for players for troops
function ctld.unloadExtractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return false
    end


    local _extract = nil
    if not ctld.inAir(_heli) then
        if _heli:getCoalition() == 1 then
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end
    end

    if _extract ~= nil and not ctld.troopsOnboard(_heli, true) then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), true })
    else
        return ctld.unloadTroops({ _heli:getName(), true, true })
    end
end

-- load troops onto vehicle
function ctld.loadTroops(_heli, _troops, _numberOrTemplate)
    -- load troops + vehicles if c130 or herc
    -- "M1045 HMMWV TOW"
    -- "M1043 HMMWV Armament"
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    --number doesnt apply to vehicles
    if _numberOrTemplate == nil or (type(_numberOrTemplate) ~= "table" and type(_numberOrTemplate) ~= "number") then
        _numberOrTemplate = ctld.getTransportLimit(_heli:getTypeName())
    end

    if _onboard == nil then
        _onboard = { troops = {}, vehicles = {} }
    end

    local _list
    if _heli:getCoalition() == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    if _troops then
        _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(), _numberOrTemplate, _heli:getCountry())
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded troops into %2", ctld.getPlayerNameOrType(_heli), _heli:getTypeName()), 10)

        ctld.processCallback({ unit = _heli, onboard = _onboard.troops, action = "load_troops" })
    else
        _onboard.vehicles = ctld.generateVehiclesForTransport(_heli:getCoalition(), _heli:getCountry())

        local _count = #_list

        ctld.processCallback({ unit = _heli, onboard = _onboard.vehicles, action = "load_vehicles" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded %2 vehicles into %3", ctld.getPlayerNameOrType(_heli), _count,
                _heli:getTypeName()), 10)
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())
end

function ctld.generateVehiclesForTransport(_side, _country)
    local _vehicles = {}
    local _list
    if _side == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end


    for _i, _type in ipairs(_list) do
        local _unitId = ctld.getNextUnitId()
        local _weight = ctld.vehiclesWeight[_type] or 2500
        _vehicles[_i] = { type = _type, unitId = _unitId, name = string.format("Dropped %s #%i", _type, _unitId), weight =
        _weight }
    end


    local _groupId = ctld.getNextGroupId()
    local _details = { units = _vehicles, groupId = _groupId, groupName = string.format("Dropped Group %i", _groupId), side =
    _side, country = _country }

    return _details
end

function ctld.loadUnloadFOBCrate(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return
    end

    if ctld.inAir(_heli) == true then
        return
    end


    local _side = _heli:getCoalition()

    local _inZone = ctld.inLogisticsZone(_heli)
    local _crateOnboard = ctld.inTransitFOBCrates[_heli:getName()] ~= nil

    if _inZone == false and _crateOnboard == true then
        ctld.inTransitFOBCrates[_heli:getName()] = nil

        local _position = _heli:getPosition()
        local _point = _heli:getPoint()
        local _side = _heli:getCoalition()

        -- Spawn 9 FOB crates in a 3x3 grid pattern
        local _cratesSpawned = 0
        local _spacing = 15 -- Distance between crates
        
        for _row = -1, 1 do
            for _col = -1, 1 do
                local _unitId = ctld.getNextUnitId()
                local _name = string.format("FOB Crate #%i", _unitId)
                
                -- Calculate offset from helicopter position
                local _xOffset = _col * _spacing
                local _yOffset = _row * _spacing
                
                -- Try to spawn at 6 oclock with grid offset
                local _angle = math.atan2(_position.x.z, _position.x.x)
                local _baseXOffset = math.cos(_angle) * -60
                local _baseYOffset = math.sin(_angle) * -60
                
                local _spawnedCrate = ctld.spawnFOBCrateStatic(_heli:getCountry(), _unitId,
                    { x = _point.x + _baseXOffset + _xOffset, z = _point.z + _baseYOffset + _yOffset }, _name)

                if _side == 1 then
                    ctld.droppedFOBCratesRED[_name] = _name
                else
                    ctld.droppedFOBCratesBLUE[_name] = _name
                end
                
                _cratesSpawned = _cratesSpawned + 1
            end
        end

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 delivered %2 FOB Crates", ctld.getPlayerNameOrType(_heli), _cratesSpawned), 10)

        ctld.displayMessageToGroup(_heli, string.format("Delivered %d FOB Crates in a grid pattern behind you", _cratesSpawned), 10)
    elseif _inZone == true and _crateOnboard == true then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate dropped back to base"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = nil
    elseif _inZone == true and _crateOnboard == false then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)

        ctld.inTransitFOBCrates[_heli:getName()] = true

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)
    else
        -- nearest Crate
        local _crates = ctld.getCratesAndDistance(_heli)
        local _nearestCrate = ctld.getClosestCrate(_heli, _crates, "FOB")

        if _nearestCrate ~= nil and _nearestCrate.dist < 150 then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("FOB Crate Loaded"), 10)
            ctld.inTransitFOBCrates[_heli:getName()] = true

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 loaded a FOB Crate ready for delivery!", ctld.getPlayerNameOrType(_heli)), 10)

            if _side == 1 then
                ctld.droppedFOBCratesRED[_nearestCrate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
            end

            --remove
            _nearestCrate.crateUnit:destroy()
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate("There are no friendly logistic units nearby to load a FOB crate from!"), 10)
        end
    end
end

function ctld.updateTroopsInGame(params, t)		-- return count of troops in game by Coalition
 	if t == nil then t = timer.getTime() + 1; end
    ctld.InfantryInGameCount  = {0, 0}
    for coalitionId=1, 2 do				-- for each CoaId
        for k,v in ipairs(coalition.getGroups(coalitionId, Group.Category.GROUND)) do   -- for each GROUND type group
			for index, unitObj in pairs(v:getUnits()) do		-- for each unit in group
                if unitObj:getDesc().attributes.Infantry then
                    ctld.InfantryInGameCount[coalitionId] = ctld.InfantryInGameCount[coalitionId] + 1
                end
            end
        end
    end
    return 5		-- reschedule each 5"
end

function ctld.loadTroopsFromZone(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]
    local _groupTemplate = _args[3] or ""
    local _allowExtract = _args[4]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end
        return false
    end

    local _extract

    if _allowExtract then
        -- first check for extractable troops regardless of if we're in a zone or not
        if _troops then
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
            end
        else

            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
            end
        end
    end

    if _extract ~= nil then
        -- search for nearest troops to pickup
        return ctld.extractTroops({_heli:getName(), _troops})
    elseif _zone.inZone == true then
        local heloCoa = _heli:getCoalition()
        ctld.logTrace("FG_ heloCoa =  %s", ctld.p(heloCoa))
        ctld.logTrace("FG_ (ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0) =  %s", ctld.p(ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0))
        ctld.logTrace("FG_ ctld.InfantryInGameCount[heloCoa] =  %s", ctld.p(ctld.InfantryInGameCount[heloCoa]))
        ctld.logTrace("FG_ _groupTemplate.total =  %s", ctld.p(_groupTemplate.total))
        ctld.logTrace("FG_ ctld.nbLimitSpawnedTroops[%s].total =  %s", ctld.p(heloCoa), ctld.p(ctld.nbLimitSpawnedTroops[heloCoa]))

        local limitReached = true
        if (ctld.nbLimitSpawnedTroops[1]~=0 or ctld.nbLimitSpawnedTroops[2]~=0) and (ctld.InfantryInGameCount[heloCoa] + _groupTemplate.total > ctld.nbLimitSpawnedTroops[heloCoa]) then  -- load troops only if Coa limit not reached
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Count Infantries limit in the mission reached, you can't load more troops"), 10)
            return false
        end
        if _zone.limit - 1 >= 0 then
            -- decrease zone counter by 1
            ctld.updateZoneCounter(_zone.index, -1)
            ctld.loadTroops(_heli, _troops,_groupTemplate)
            return true
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("This area has no more reinforcements available!"), 20)
            return false
        end
    else
        if _allowExtract then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You are not in a pickup zone and no one is nearby to extract"), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You are not in a pickup zone"), 10)
        end

        return false
    end
end

function ctld.unloadTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)
    if not ctld.troopsOnboard(_heli, _troops) then
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No one to unload"), 10)

        return false
    else
        -- troops must be onboard to get here
        if _zone.inZone == true then
            if _troops then
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped troops back to base"), 20)

                ctld.processCallback({ unit = _heli, unloaded = ctld.inTransitTroops[_heli:getName()].troops, action =
                "unload_troops_zone" })

                ctld.inTransitTroops[_heli:getName()].troops = nil
            else
                ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Dropped vehicles back to base"), 20)

                ctld.processCallback({ unit = _heli, unloaded = ctld.inTransitTroops[_heli:getName()].vehicles, action =
                "unload_vehicles_zone" })

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
            end

            ctld.adaptWeightToCargo(_heli:getName())

            -- increase zone counter by 1
            ctld.updateZoneCounter(_zone.index, 1)

            return true
        elseif ctld.troopsOnboard(_heli, _troops) then
            return ctld.deployTroops(_heli, _troops)
        end
    end
end

function ctld.extractTroops(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    if ctld.inAir(_heli) then
        return false
    end

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have troops onboard."), 10)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You already have vehicles onboard."), 10)
        end

        return false
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        _onboard = { troops = nil, vehicles = nil }
    end

    local _extracted = false

    if _troops then
        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end


        if _extractTroops ~= nil then
            local _limit = ctld.getTransportLimit(_heli:getTypeName())

            local _size = #_extractTroops.group:getUnits()

            if _limit < #_extractTroops.group:getUnits() then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3", _size,
                        _limit, _heli:getTypeName()), 20)

                return
            end

            _onboard.troops = _extractTroops.details
            _onboard.troops.weight = #_extractTroops.group:getUnits() * 130             -- default to 130kg per soldier

            if _extractTroops.group:getName():lower():find("jtac") then
                _onboard.troops.jtac = true
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted troops in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            ctld.processCallback({ unit = _heli, extracted = _extractTroops, action = "extract_troops" })

            --remove
            _extractTroops.group:destroy()

            _extracted = true
        else
            _onboard.troops = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable troops nearby!"), 20)
        end
    else
        local _extractVehicles


        if _heli:getCoalition() == 1 then
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
        else
            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
        end

        if _extractVehicles ~= nil then
            _onboard.vehicles = _extractVehicles.details

            if _heli:getCoalition() == 1 then
                ctld.droppedVehiclesRED[_extractVehicles.group:getName()] = nil
            else
                ctld.droppedVehiclesBLUE[_extractVehicles.group:getName()] = nil
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 extracted vehicles in %2 from combat", ctld.getPlayerNameOrType(_heli),
                    _heli:getTypeName()), 10)

            ctld.processCallback({ unit = _heli, extracted = _extractVehicles, action = "extract_vehicles" })
            --remove
            _extractVehicles.group:destroy()
            _extracted = true
        else
            _onboard.vehicles = nil
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No extractable vehicles nearby!"), 20)
        end
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
    ctld.adaptWeightToCargo(_heli:getName())

    return _extracted
end

function ctld.checkTroopStatus(_args)
    local _unitName = _args[1]
    --list onboard troops, if c130
    local _heli = ctld.getTransportUnit(_unitName)

    if _heli == nil then
        return
    end

    local _, _message = ctld.getWeightOfCargo(_unitName)
    if _message and _message ~= "" then
        ctld.displayMessageToGroup(_heli, _message, 10)
    end
end

-- Removes troops from transport when it dies
function ctld.checkTransportStatus()
    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 3)

    for _, _name in ipairs(ctld.transportPilotNames) do
        local _transUnit = ctld.getTransportUnit(_name)

        if _transUnit == nil then
            --env.info("CTLD Transport Unit Dead event")
            ctld.inTransitTroops[_name] = nil
            ctld.inTransitFOBCrates[_name] = nil
            ctld.inTransitSlingLoadCrates[_name] = nil
        end
    end
end

function ctld.adaptWeightToCargo(unitName)
    local _weight = ctld.getWeightOfCargo(unitName)
    trigger.action.setUnitInternalCargo(unitName, _weight)
end

function ctld.getWeightOfCargo(unitName)
    local FOB_CRATE_WEIGHT = 800
    local _weight = 0
    local _description = ""

    ctld.inTransitSlingLoadCrates[unitName] = ctld.inTransitSlingLoadCrates[unitName] or {}

    -- add troops weight
    if ctld.inTransitTroops[unitName] then
        local _inTransit = ctld.inTransitTroops[unitName]
        if _inTransit then
            local _troops = _inTransit.troops
            if _troops and _troops.units then
                _description = _description ..
                ctld.i18n_translate("%1 troops onboard (%2 kg)\n", #_troops.units, _troops.weight)
                _weight = _weight + _troops.weight
            end
            local _vehicles = _inTransit.vehicles
            if _vehicles and _vehicles.units then
                for _, _unit in pairs(_vehicles.units) do
                    _weight = _weight + _unit.weight
                end
                _description = _description ..
                ctld.i18n_translate("%1 vehicles onboard (%2)\n", #_vehicles.units, _weight)
            end
        end
    end

    -- add FOB crates weight
    if ctld.inTransitFOBCrates[unitName] then
        _weight = _weight + FOB_CRATE_WEIGHT
        _description = _description .. ctld.i18n_translate("1 FOB Crate oboard (%1 kg)\n", FOB_CRATE_WEIGHT)
    end

    -- add simulated slingload crates weight
    for i = 1, #ctld.inTransitSlingLoadCrates[unitName] do
        local _crate = ctld.inTransitSlingLoadCrates[unitName][i]
        if _crate and _crate.simulatedSlingload then
            _weight = _weight + _crate.weight
            _description = _description .. ctld.i18n_translate("%1 crate onboard (%2 kg)\n", _crate.desc, _crate.weight)
        end
    end
    if _description ~= "" then
        _description = _description .. ctld.i18n_translate("Total weight of cargo : %1 kg\n", _weight)
    else
        _description = ctld.i18n_translate("No cargo.")
    end

    return _weight, _description
end

function ctld.checkHoverStatus()
    timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1.0)

    local _status, _result = pcall(function()
        for _, _name in ipairs(ctld.transportPilotNames) do
            local _reset = true
            local _transUnit = ctld.getTransportUnit(_name)
            local _transUnitTypeName = _transUnit and _transUnit:getTypeName()
            local _cargoCapacity = ctld.internalCargoLimits[_transUnitTypeName] or 1
            ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

            --only check transports that are hovering and not planes
            if _transUnit ~= nil and #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity and ctld.inAir(_transUnit) and ctld.unitCanCarryVehicles(_transUnit) == false and not ctld.unitDynamicCargoCapable(_transUnit) then
                local _crates = ctld.getCratesAndDistance(_transUnit)

                for _, _crate in pairs(_crates) do
                    local _crateUnitName = _crate.crateUnit:getName()
                    if _crate.dist < ctld.maxDistanceFromCrate and _crate.details.unit ~= "FOB" then
                        --check height!
                        local _height = _transUnit:getPoint().y - _crate.crateUnit:getPoint().y
                        if _height > ctld.minimumHoverHeight and _height <= ctld.maximumHoverHeight then
                            local _time = ctld.hoverStatus[_name]

                            if _time == nil then
                                ctld.hoverStatus[_name] = ctld.hoverTime
                                _time = ctld.hoverTime
                            else
                                _time = ctld.hoverStatus[_name] - 1
                                ctld.hoverStatus[_name] = _time
                            end

                            if _time > 0 then
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate(
                                    "Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!",
                                        _crate.details.desc, _time), 10, true)
                            else
                                ctld.hoverStatus[_name] = nil
                                ctld.displayMessageToGroup(_transUnit,
                                    ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc), 10, true)

                                --crates been moved once!
                                ctld.crateMove[_crateUnitName] = nil

                                if _transUnit:getCoalition() == 1 then
                                    ctld.spawnedCratesRED[_crateUnitName] = nil
                                else
                                    ctld.spawnedCratesBLUE[_crateUnitName] = nil
                                end

                                _crate.crateUnit:destroy()

                                local _copiedCrate = mist.utils.deepCopy(_crate.details)
                                _copiedCrate.simulatedSlingload = true
                                table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                                ctld.adaptWeightToCargo(_name)
                            end

                            _reset = false

                            break
                        elseif _height <= ctld.minimumHoverHeight then
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too low to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        else
                            ctld.displayMessageToGroup(_transUnit,
                                ctld.i18n_translate("Too high to hook %1 crate.\n\nHold hover for %2 seconds",
                                    _crate.details.desc, ctld.hoverTime), 5, true)
                            break
                        end
                    end
                end
            end

            if _reset then
                ctld.hoverStatus[_name] = nil
            end
        end
    end)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _result))
    end
end

function ctld.loadNearbyCrate(_name)
    local _transUnit = ctld.getTransportUnit(_name)

    if _transUnit ~= nil then
        local _cargoCapacity = ctld.internalCargoLimits[_transUnit:getTypeName()] or 1
        ctld.inTransitSlingLoadCrates[_name] = ctld.inTransitSlingLoadCrates[_name] or {}

        if ctld.inAir(_transUnit) then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("You must land before you can load a crate!"), 10,
                true)
            return
        end

        local _crates = ctld.getCratesAndDistance(_transUnit)
        local loaded = false
        for _, _crate in pairs(_crates) do
            if _crate.dist < 50.0 then
                if #ctld.inTransitSlingLoadCrates[_name] < _cargoCapacity then
                    ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("Loaded %1 crate!", _crate.details.desc),
                        10)

                    if _transUnit:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                    else
                        ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                    end

                    ctld.crateMove[_crate.crateUnit:getName()] = nil

                    _crate.crateUnit:destroy()

                    local _copiedCrate = mist.utils.deepCopy(_crate.details)
                    _copiedCrate.simulatedSlingload = true
                    table.insert(ctld.inTransitSlingLoadCrates[_name], _copiedCrate)
                    loaded = true
                    ctld.adaptWeightToCargo(_name)
                else
                    -- Max crates onboard
                    local outputMsg = ctld.i18n_translate("Maximum number of crates are on board!")
                    for i = 1, _cargoCapacity do
                        outputMsg = outputMsg .. "\n" .. ctld.inTransitSlingLoadCrates[_name][i].desc
                    end
                    ctld.displayMessageToGroup(_transUnit, outputMsg, 10, true)
                    return
                end
            end
        end
        if not loaded then
            ctld.displayMessageToGroup(_transUnit, ctld.i18n_translate("No Crates within 50m to load!"), 10, true)
        end
    end
end

--check each minute if the beacons' batteries have failed, and stop them accordingly
--there's no more need to actually refresh the beacons, since we set "loop" to true.
function ctld.refreshRadioBeacons()
    timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 60)


    for _index, _beaconDetails in ipairs(ctld.deployedRadioBeacons) do
        if ctld.updateRadioBeacon(_beaconDetails) == false then
            --search used frequencies + remove, add back to unused

            for _i, _freq in ipairs(ctld.usedUHFFrequencies) do
                if _freq == _beaconDetails.uhf then
                    table.insert(ctld.freeUHFFrequencies, _freq)
                    table.remove(ctld.usedUHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedVHFFrequencies) do
                if _freq == _beaconDetails.vhf then
                    table.insert(ctld.freeVHFFrequencies, _freq)
                    table.remove(ctld.usedVHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedFMFrequencies) do
                if _freq == _beaconDetails.fm then
                    table.insert(ctld.freeFMFrequencies, _freq)
                    table.remove(ctld.usedFMFrequencies, _i)
                end
            end

            --clean up beacon table
            table.remove(ctld.deployedRadioBeacons, _index)
        end
    end
end

function ctld.getClockDirection(_heli, _crate)
    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p          -- get position of crate
    local _playerPosition = _heli:getPosition().p     -- get position of helicopter
    local _relativePosition = mist.vec.sub(_position, _playerPosition)

    local _playerHeading = mist.getHeading(_heli)     -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = { x = math.cos(_playerHeading), y = 0, z = math.sin(_playerHeading) }

    local _headingVectorPerpendicular = { x = math.cos(_playerHeading + math.pi / 2), y = 0, z = math.sin(_playerHeading +
    math.pi / 2) }

    local _forwardDistance = mist.vec.dp(_relativePosition, _headingVector)

    local _rightDistance = mist.vec.dp(_relativePosition, _headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance, _forwardDistance) * 180 / math.pi

    if _angle < 0 then
        _angle = 360 + _angle
    end
    _angle = math.floor(_angle * 12 / 360 + 0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end

function ctld.getCompassBearing(_ref, _unitPos)
    _ref = mist.utils.makeVec3(_ref, 0)             -- turn it into Vec3 if it is not already.
    _unitPos = mist.utils.makeVec3(_unitPos, 0)     -- turn it into Vec3 if it is not already.

    local _vec = { x = _unitPos.x - _ref.x, y = _unitPos.y - _ref.y, z = _unitPos.z - _ref.z }

    local _dir = mist.utils.getDir(_vec, _ref)

    local _bearing = mist.utils.round(mist.utils.toDegree(_dir), 0)

    return _bearing
end

function ctld.listNearbyCrates(_args)
    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return         -- no heli!
    end

    local _crates = ctld.getCratesAndDistance(_heli)

    --sort
    local _sort = function(a, b) return a.dist < b.dist end
    table.sort(_crates, _sort)

    for _, _crate in pairs(_crates) do
        if _crate.dist < 1000 and _crate.details.unit ~= "FOB" then
            _message = ctld.i18n_translate("%1\n%2 crate - kg %3 - %4 m - %5 o'clock", _message, _crate.details.desc,
                _crate.details.weight, _crate.dist, ctld.getClockDirection(_heli, _crate.crateUnit))
        end
    end


    local _fobMsg = ""
    for _, _fobCrate in pairs(_crates) do
        if _fobCrate.dist < 1000 and _fobCrate.details.unit == "FOB" then
            _fobMsg = _fobMsg ..
            ctld.i18n_translate("FOB Crate - %1 m - %2 o'clock\n", _fobCrate.dist,
                ctld.getClockDirection(_heli, _fobCrate.crateUnit))
        end
    end

    local _txt = ctld.i18n_translate("No Nearby Crates")
    if _message ~= "" or _fobMsg ~= "" then
        _txt = ""

        if _message ~= "" then
            _txt = ctld.i18n_translate("Nearby Crates:\n%1", _message)
        end

        if _fobMsg ~= "" then
            if _txt ~= "" then
                _txt = _txt .. "\n\n"
            end

            _txt = _txt .. ctld.i18n_translate("Nearby FOB Crates (Not Slingloadable):\n%1", _fobMsg)
        end
    end
    ctld.displayMessageToGroup(_heli, _txt, 20)
end

function ctld.listFOBS(_args)
    local _msg = ctld.i18n_translate("FOB Positions:")

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return         -- no heli!
    end

    -- get fob positions
    local _fobs = ctld.getSpawnedFobs(_heli)

    if _fobs and #_fobs > 0 then
        -- now check spawned fobs
        for _, _fob in ipairs(_fobs) do
            _msg = ctld.i18n_translate("%1\nFOB @ %2", _msg, ctld.getFOBPositionString(_fob))
        end
    else
        _msg = ctld.i18n_translate("Sorry, there are no active FOBs!")
    end
    ctld.displayMessageToGroup(_heli, _msg, 20)
end

function ctld.getFOBPositionString(_fob)
    local _lat, _lon = coord.LOtoLL(_fob:getPosition().p)

    local _latLngStr = mist.tostringLL(_lat, _lon, 3, ctld.location_DMS)

    --     local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_fob:getPosition().p)), 5)

    local _message = _latLngStr

    local _beaconInfo = ctld.fobBeacons[_fob:getName()]

    if _beaconInfo ~= nil then
        _message = string.format("%s - %.2f KHz ", _message, _beaconInfo.vhf / 1000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.uhf / 1000000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.fm / 1000000)
    end

    return _message
end

function ctld.displayMessageToGroup(_unit, _text, _time, _clear)
    local _groupId = ctld.getGroupId(_unit)
    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time, _clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

function ctld.heightDiff(_unit)
    local _point = _unit:getPoint()

    -- env.info("heightunit " .. _point.y)
    --env.info("heightland " .. land.getHeight({ x = _point.x, y = _point.z }))

    return _point.y - land.getHeight({ x = _point.x, y = _point.z })
end

--includes fob crates!
function ctld.getCratesAndDistance(_heli)
    local _crates = {}

    local _allCrates
    if _heli:getCoalition() == 1 then
        _allCrates = ctld.spawnedCratesRED
    else
        _allCrates = ctld.spawnedCratesBLUE
    end

    for _crateName, _details in pairs(_allCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0 then
            local _isInAir = ctld.inAir(_crate)
            
            -- For airdropped crates, also check if they're effectively on ground by checking height and velocity
            local _canUse = not _isInAir
            if _isInAir then
                local _cratePoint = _crate:getPoint()
                local _terrainHeight = land.getHeight({x = _cratePoint.x, y = _cratePoint.z})
                local _crateHeight = _cratePoint.y - _terrainHeight
                local _velocity = _crate:getVelocity()
                local _speed = mist.vec.mag(_velocity)
                
                -- Consider crate as landed if it's close to ground and slow/stopped
                if _crateHeight < 5 and _speed < 1 then
                    _canUse = true
                    ctld.logTrace("FG_ Airdropped crate considered landed: %s (height: %.2f, speed: %.2f)", _crateName, _crateHeight, _speed)
                end
            end
            
            if _canUse then
                local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

                local _crateDetails = { crateUnit = _crate, dist = _dist, details = _details }

                table.insert(_crates, _crateDetails)
            end
        end
    end

    local _fobCrates
    if _heli:getCoalition() == 1 then
        _fobCrates = ctld.droppedFOBCratesRED
    else
        _fobCrates = ctld.droppedFOBCratesBLUE
    end

    for _crateName, _details in pairs(_fobCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then
            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

            local _crateDetails = { crateUnit = _crate, dist = _dist, details = { unit = "FOB-SMALL" }, }

            table.insert(_crates, _crateDetails)
        end
    end

    return _crates
end

function ctld.getAirdropCratesAndDistance(_heli)
    local _crates = {}

    local _allCrates
    if _heli:getCoalition() == 1 then
        _allCrates = ctld.spawnedCratesRED
    else
        _allCrates = ctld.spawnedCratesBLUE
    end

    for _crateName, _details in pairs(_allCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        --enhanced detection for airdrops - same logic as updated getCratesAndDistance
        if _crate ~= nil and _crate:getLife() > 0 then
            local _isInAir = ctld.inAir(_crate)
            
            -- For airdropped crates, also check if they're effectively on ground by checking height and velocity
            local _canUse = not _isInAir
            if _isInAir then
                local _cratePoint = _crate:getPoint()
                local _terrainHeight = land.getHeight({x = _cratePoint.x, y = _cratePoint.z})
                local _crateHeight = _cratePoint.y - _terrainHeight
                local _velocity = _crate:getVelocity()
                local _speed = mist.vec.mag(_velocity)
                
                -- Consider crate as landed if it's close to ground and slow/stopped
                if _crateHeight < 5 and _speed < 1 then
                    _canUse = true
                    ctld.logTrace("FG_ Airdropped crate considered landed: %s (height: %.2f, speed: %.2f)", _crateName, _crateHeight, _speed)
                end
            end
            
            if _canUse then
                local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

                local _crateDetails = { crateUnit = _crate, dist = _dist, details = _details }

                table.insert(_crates, _crateDetails)
                ctld.logTrace("FG_ Added airdrop crate: %s at distance %.1f", _crateName, _dist)
            end
        end
    end

    -- Also check FOB crates with same enhanced detection
    local _fobCrates
    if _heli:getCoalition() == 1 then
        _fobCrates = ctld.droppedFOBCratesRED
    else
        _fobCrates = ctld.droppedFOBCratesBLUE
    end

    for _crateName, _details in pairs(_fobCrates) do
        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then
            local _isInAir = ctld.inAir(_crate)
            
            local _canUse = not _isInAir
            if _isInAir then
                local _cratePoint = _crate:getPoint()
                local _terrainHeight = land.getHeight({x = _cratePoint.x, y = _cratePoint.z})
                local _crateHeight = _cratePoint.y - _terrainHeight
                local _velocity = _crate:getVelocity()
                local _speed = mist.vec.mag(_velocity)
                
                if _crateHeight < 5 and _speed < 1 then
                    _canUse = true
                    ctld.logTrace("FG_ Airdropped FOB crate considered landed: %s", _crateName)
                end
            end
            
            if _canUse then
                local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

                local _crateDetails = { crateUnit = _crate, dist = _dist, details = { unit = "FOB-SMALL" }, }

                table.insert(_crates, _crateDetails)
            end
        end
    end

    return _crates
end

function ctld.getClosestCrate(_heli, _crates, _type)
    local _closetCrate = nil
    local _shortestDistance = -1
    local _distance = 0
    local _minimumDistance = 5     -- prevents dynamic cargo crates from unpacking while in cargo hold
    local _maxDistance     = 75    -- prevents onboard dynamic cargo crates from unpacking requested by other helo
    for _, _crate in pairs(_crates) do
        if (_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) and _distance > _minimumDistance and _distance < _maxDistance then
                _shortestDistance = _distance
                _closetCrate = _crate
            end
        end
    end

    return _closetCrate
end

function ctld.getClosestCrateOnGround(_heli, _crates, _type)
    local _closetCrate = nil
    local _shortestDistance = -1
    local _distance = 0
    local _minimumDistance = 5     -- prevents dynamic cargo crates from unpacking while in cargo hold
    local _maxDistance     = 30000    -- prevents onboard dynamic cargo crates from unpacking requested by other helo

    for _, _crate in pairs(_crates) do
        if (_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist
            if _distance ~= nil and (_shortestDistance == -1 
            or  _distance < _shortestDistance) 
            and _distance > _minimumDistance 
            and _distance < _maxDistance 
            and ctld.heightDiff(_crate.crateUnit) <= 1 then
                _shortestDistance = _distance
                _closetCrate = _crate
            end
        end
    end

    return _closetCrate
end

function ctld.findNearestAASystem(_heli, _aaSystem)
    local _closestHawkGroup = nil
    local _shortestDistance = -1
    local _distance = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)

        --    env.info(_groupName..": "..mist.utils.tableShow(_hawkDetails))
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() and _hawkDetails[1].system.name == _aaSystem.name then
            local _units = _hawkGroup:getUnits()

            for _, _leader in pairs(_units) do
                if _leader ~= nil and _leader:getLife() > 0 then
                    _distance = ctld.getDistance(_leader:getPoint(), _heli:getPoint())

                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestHawkGroup = _hawkGroup
                    end

                    break
                end
            end
        end
    end

    if _closestHawkGroup ~= nil then
        return { group = _closestHawkGroup, dist = _shortestDistance }
    end
    return nil
end

function ctld.getCrateObject(_name)
    local _crate

    if ctld.staticBugWorkaround then
        _crate = Unit.getByName(_name)
    else
        _crate = StaticObject.getByName(_name)
    end
    return _crate
end

function ctld.unpackCrates(_arguments)
    ctld.logTrace("FG_ ctld.unpackCrates._arguments =  %s", ctld.p(_arguments))
    local _status, _err = pcall(function(_args)
        local _heli = ctld.getTransportUnit(_args[1])
        ctld.logTrace("FG_ ctld.unpackCrates._args =  %s", ctld.p(_args))
        if _heli ~= nil and ctld.inAir(_heli) == false then
            local _crates = ctld.getCratesAndDistance(_heli)
            local _crate = ctld.getClosestCrate(_heli, _crates)
            ctld.logTrace("FG_ ctld.unpackCrates._crate =  %s", ctld.p(_crate))

            if ctld.inLogisticsZone(_heli) == true or ctld.farEnoughFromLogisticZone(_heli) == false then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)
                return
            end

            if _crate ~= nil and _crate.dist < 750
                and (_crate.details.unit == "FOB" or _crate.details.unit == "FOB-SMALL") then
                ctld.unpackFOBCrates(_crates, _heli)

                return
            elseif _crate ~= nil and _crate.dist < 200 then
                if ctld.forceCrateToBeMoved and ctld.crateMove[_crate.crateUnit:getName()] and not ctld.unitDynamicCargoCapable(_heli) then
                    ctld.displayMessageToGroup(_heli,
                        ctld.i18n_translate("Sorry you must move this crate before you unpack it!"), 20)
                    return
                end


                local _aaTemplate = ctld.getAATemplate(_crate.details.unit)

                if _aaTemplate then
                    if _crate.details.unit == _aaTemplate.repair then
                        ctld.repairAASystem(_heli, _crate, _aaTemplate)
                    else
                        ctld.unpackAASystem(_heli, _crate, _crates, _aaTemplate)
                    end

                    return                     -- stop processing
                    -- is multi crate?
                elseif _crate.details.cratesRequired ~= nil and _crate.details.cratesRequired > 1 then
                    -- multicrate

                    ctld.unpackMultiCrate(_heli, _crate, _crates)

                    return
                else
                    ctld.logTrace("single crate =  %s", ctld.p(_arguments))
                    -- single crate
                    --local _cratePoint = _crate.crateUnit:getPoint()
                    local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                    if ctld.unitDynamicCargoCapable(_heli) == true then
                        _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
                    end
                    local _crateName  = _crate.crateUnit:getName()
                    local _crateHdg   = mist.getHeading(_crate.crateUnit, true)

                    --remove crate
                    --    if ctld.slingLoad == false then
                    _crate.crateUnit:destroy()
                    -- end
                    ctld.logTrace("_crate =  %s", ctld.p(_crate))
                    local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _point }, { _crate.details.unit }, { _crateHdg })
                    ctld.logTrace("_spawnedGroups =  %s", ctld.p(_spawnedGroups))

                    if _heli:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crateName] = nil
                    else
                        ctld.spawnedCratesBLUE[_crateName] = nil
                    end

                    ctld.processCallback({ unit = _heli, crate = _crate, spawnedGroup = _spawnedGroups, action = "unpack" })

                    if _crate.details.unit == "1L13 EWR" then
                        ctld.addEWRTask(_spawnedGroups)

                        --             env.info("Added EWR")
                    end


                    trigger.action.outTextForCoalition(_heli:getCoalition(),
                            ctld.i18n_translate("%1 successfully deployed %2 to the field", ctld.getPlayerNameOrType(_heli),
                            _crate.details.desc), 10)
                    timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1)  -- for add unpacked unit in repack menu
                    if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then
                        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                        --put to the end
                        table.insert(ctld.jtacGeneratedLaserCodes, _code)

                        ctld.JTACStart(_spawnedGroups:getName(), _code)                         --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("No friendly crates close enough to unpack, or crate too close to aircraft."), 20)
            end
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

function ctld.unpackC130Airdrop(_arguments)
    ctld.logTrace("FG_ ctld.unpackC130Airdrop._arguments =  %s", ctld.p(_arguments))
    local _status, _err = pcall(function(_args)
        local _heli = ctld.getTransportUnit(_args[1])
        ctld.logTrace("FG_ ctld.unpackC130Airdrop._args =  %s", ctld.p(_args))
        if _heli ~= nil and ctld.inAir(_heli) == true then
            local _crates = ctld.getCratesAndDistance(_heli)
            local _crate = ctld.getClosestCrateOnGround(_heli, _crates)
            ctld.logTrace("FG_ ctld.unpackC130Airdrop._crate =  %s", ctld.p(_crate))
            ctld.logTrace("FG_ ctld.unpackC130Airdrop._crates =  %s", ctld.p(_crates))

            if _crate ~= nil and _crate.dist < 30000 
                and _crate.details.unit == "FOB-SMALL" then
                    ctld.unpackAirdropFOB(_heli, _crate, _crates)
                return
            elseif _crate ~= nil and _crate.dist < 30000 then
                if ctld.forceCrateToBeMoved and ctld.crateMove[_crate.crateUnit:getName()] and not ctld.unitDynamicCargoCapable(_heli) then
                    ctld.displayMessageToGroup(_heli,
                        ctld.i18n_translate("Sorry you must move this crate before you unpack it!"), 20)
                    return
                end

                local _aaTemplate = ctld.getAATemplate(_crate.details.unit)

                if _aaTemplate then
                    if _crate.details.unit == _aaTemplate.repair then
                        ctld.repairAASystem(_heli, _crate, _aaTemplate)
                    else
                        ctld.unpackAirdropAASystem(_heli, _crate, _crates, _aaTemplate)
                    end
                    return 
                elseif _crate.details.cratesRequired ~= nil and _crate.details.cratesRequired > 1 then
                    -- multicrate for airdrop
                    ctld.unpackAirdropMultiCrate(_heli, _crate, _crates)
                    return
                else
                    ctld.unpackAirdropSingleCrate(_heli, _crate)
                end
            else
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("No friendly crates close enough to unpack, or crate too close to aircraft."), 20)
            end
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

-- builds a fob!
function ctld.unpackFOBCrates(_crates, _heli)
    if ctld.inLogisticsZone(_heli) == true then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)

        return
    end

    -- unpack multi crate
    local _nearbyMultiCrates = {}

    local _bigFobCrates = 0
    local _smallFobCrates = 0
    local _totalCrates = 0

    for _, _nearbyCrate in pairs(_crates) do
        if _nearbyCrate.dist < 750 then
            if _nearbyCrate.details.unit == "FOB" then
                _bigFobCrates = _bigFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            elseif _nearbyCrate.details.unit == "FOB-SMALL" then
                _smallFobCrates = _smallFobCrates + 1
                table.insert(_nearbyMultiCrates, _nearbyCrate)
            end

            --catch divide by 0
            if _smallFobCrates > 0 then
                _totalCrates = _bigFobCrates + (_smallFobCrates / 3.0)
            else
                _totalCrates = _bigFobCrates
            end

            if _totalCrates >= ctld.cratesRequiredForFOB then
                break
            end
        end
    end

    --- check crate count
    if _totalCrates >= ctld.cratesRequiredForFOB then
        -- destroy crates

        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do
            if _heli:getCoalition() == 1 then
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())

            --destroy
            _crate.crateUnit:destroy()
        end

        local _centroid = ctld.getCentroid(_points)

        timer.scheduleFunction(function(_args)
            local _unitId = ctld.getNextUnitId()
            local _name = "Deployed FOB #" .. _unitId

            local _fob = ctld.spawnFOB(_args[2], _unitId, _args[1], _name)

            --make it able to deploy crates
            table.insert(ctld.logisticUnits, _fob:getName())

            ctld.beaconCount = ctld.beaconCount + 1

            local _radioBeaconName = "FOB Beacon #" .. ctld.beaconCount

            local _radioBeaconDetails = ctld.createRadioBeacon(_args[1], _args[3], _args[2], _radioBeaconName, nil, true)

            ctld.fobBeacons[_name] = { vhf = _radioBeaconDetails.vhf, uhf = _radioBeaconDetails.uhf, fm =
            _radioBeaconDetails.fm }

            if ctld.troopPickupAtFOB == true then
                table.insert(ctld.builtFOBS, _fob:getName())

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates and Troops can now be picked up."), 10)
            else
                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates can now be picked up."), 10)
            end
        end, { _centroid, _heli:getCountry(), _heli:getCoalition() }, timer.getTime() + ctld.buildTimeFOB)

        ctld.processCallback({ unit = _heli, position = _centroid, action = "fob" })

        trigger.action.smoke(_centroid, trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
            "%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke.",
                ctld.getPlayerNameOrType(_heli), _totalCrates, ctld.buildTimeFOB, 10))
    else
        local _txt = ctld.i18n_translate(
        "Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other",
            ctld.cratesRequiredForFOB, _totalCrates)
        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

--unloads the sling crate when the helicopter is on the ground or between 4.5 - 10 meters
function ctld.dropSlingCrate(_args)
    local _unitName = _args[1]
    local _heli = ctld.getTransportUnit(_unitName)
    ctld.inTransitSlingLoadCrates[_unitName] = ctld.inTransitSlingLoadCrates[_unitName] or {}

    if _heli == nil then
        return         -- no heli!
    end

    local _currentCrate = ctld.inTransitSlingLoadCrates[_unitName][#ctld.inTransitSlingLoadCrates[_unitName]]

    if _currentCrate == nil then
        if ctld.hoverPickup and ctld.loadCrateFromMenu then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands.",
                    ctld.hoverTime), 10)
        elseif ctld.hoverPickup then
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate.",
                    ctld.hoverTime), 10)
        else
            ctld.displayMessageToGroup(_heli,
                ctld.i18n_translate(
                "You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."),
                10)
        end
    else
        local _point = _heli:getPoint()
        local _side = _heli:getCoalition()
        local _hdg = mist.getHeading(_heli, true)
        local _heightDiff = ctld.heightDiff(_heli)

        if _heightDiff > 40.0 then
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.adaptWeightToCargo(_unitName)
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You were too high! The crate has been destroyed"), 10)
            return
        end
        local _loadedCratesCopy = mist.utils.deepCopy(ctld.inTransitSlingLoadCrates[_unitName])
        ctld.logTrace("_loadedCratesCopy = %s", ctld.p(_loadedCratesCopy))
        for _, _crate in pairs(_loadedCratesCopy) do
            ctld.logTrace("_crate = %s", ctld.p(_crate))
            ctld.logTrace("ctld.inAir(_heli) = %s", ctld.p(ctld.inAir(_heli)))
            ctld.logTrace("_heightDiff = %s", ctld.p(_heightDiff))
            local _unitId = ctld.getNextUnitId()
            local _name = string.format("%s #%i", _crate.desc, _unitId)
            local _model_type = nil
            if ctld.inAir(_heli) == false or _heightDiff <= 7.5 then
                _point = ctld.getPointAt12Oclock(_heli, 15)
                local _position = "12"
                if ctld.unitDynamicCargoCapable(_heli) then
                    _model_type = "dynamic"
                    _point = ctld.getPointAt6Oclock(_heli, ctld.getSecureDistanceFromUnit(_heli))
                    _position = "6"
                end
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely unhooked and is at your %2 o'clock", _crate.desc, _position), 10)
            elseif _heightDiff > 7.5 and _heightDiff <= 40.0 then
                ctld.displayMessageToGroup(_heli,
                    ctld.i18n_translate("%1 crate has been safely dropped below you", _crate.desc), 10)
            end
            --remove crate from cargo
            table.remove(ctld.inTransitSlingLoadCrates[_unitName], #ctld.inTransitSlingLoadCrates[_unitName])
            ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crate.weight, _side, _hdg, _model_type)
        end
        ctld.adaptWeightToCargo(_unitName)
    end
end

--spawns a radio beacon made up of two units,
-- one for VHF and one for UHF
-- The units are set to to NOT engage
function ctld.createRadioBeacon(_point, _coalition, _country, _name, _batteryTime, _isFOB)
    local _freq = ctld.generateADFFrequencies()

    --create timeout
    local _battery

    if _batteryTime == nil then
        _battery = timer.getTime() + (ctld.deployedBeaconBattery * 60)
    else
        _battery = timer.getTime() + (_batteryTime * 60)
    end

    local _lat, _lon = coord.LOtoLL(_point)

    local _latLngStr = mist.tostringLL(_lat, _lon, 3, ctld.location_DMS)

    --local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_point)), 5)

    local _freqsText = _name

    if _isFOB then
        --    _message = "FOB " .. _message
        _battery = -1         --never run out of power!
    end

    _freqsText = _freqsText .. " - " .. _latLngStr


    _freqsText = string.format("%.2f kHz - %.2f / %.2f MHz", _freq.vhf / 1000, _freq.uhf / 1000000, _freq.fm / 1000000)

    local _uhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _vhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _fmGroup = ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)

    local _beaconDetails = {
        vhf = _freq.vhf,
        vhfGroup = _vhfGroup:getName(),
        uhf = _freq.uhf,
        uhfGroup = _uhfGroup:getName(),
        fm = _freq.fm,
        fmGroup = _fmGroup:getName(),
        text = _freqsText,
        battery = _battery,
        coalition = _coalition,
    }

    ctld.updateRadioBeacon(_beaconDetails)

    table.insert(ctld.deployedRadioBeacons, _beaconDetails)

    return _beaconDetails
end

function ctld.generateADFFrequencies()
    if #ctld.freeUHFFrequencies <= 3 then
        ctld.freeUHFFrequencies = ctld.usedUHFFrequencies
        ctld.usedUHFFrequencies = {}
    end

    --remove frequency at RANDOM
    local _uhf = table.remove(ctld.freeUHFFrequencies, math.random(#ctld.freeUHFFrequencies))
    table.insert(ctld.usedUHFFrequencies, _uhf)


    if #ctld.freeVHFFrequencies <= 3 then
        ctld.freeVHFFrequencies = ctld.usedVHFFrequencies
        ctld.usedVHFFrequencies = {}
    end

    local _vhf = table.remove(ctld.freeVHFFrequencies, math.random(#ctld.freeVHFFrequencies))
    table.insert(ctld.usedVHFFrequencies, _vhf)

    if #ctld.freeFMFrequencies <= 3 then
        ctld.freeFMFrequencies = ctld.usedFMFrequencies
        ctld.usedFMFrequencies = {}
    end

    local _fm = table.remove(ctld.freeFMFrequencies, math.random(#ctld.freeFMFrequencies))
    table.insert(ctld.usedFMFrequencies, _fm)

    return { uhf = _uhf, vhf = _vhf, fm = _fm }
    --- return {uhf=_uhf,vhf=_vhf}
end

function ctld.spawnRadioBeaconUnit(_point, _country, _name, _freqsText)
    local _groupId = ctld.getNextGroupId()

    local _unitId = ctld.getNextUnitId()

    local _radioGroup = {
        ["visible"] = false,
        -- ["groupId"] = _groupId,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["y"] = _point.z,
                ["type"] = "TACAN_beacon",
                ["name"] = "Unit #" .. _unitId .. " - " .. _name .. " [" .. _freqsText .. "]",
                --     ["unitId"] = _unitId,
                ["heading"] = 0,
                ["playerCanDrive"] = true,
                ["skill"] = "Excellent",
                ["x"] = _point.x,
            }
        },
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = "Group #" .. _groupId .. " - " .. _name,
        ["task"] = {},
        --added two fields below for MIST
        ["category"] = Group.Category.GROUND,
        ["country"] = _country
    }

    -- return coalition.addGroup(_country, Group.Category.GROUND, _radioGroup)
    return Group.getByName(mist.dynAdd(_radioGroup).name)
end

function ctld.updateRadioBeacon(_beaconDetails)
    local _vhfGroup = Group.getByName(_beaconDetails.vhfGroup)

    local _uhfGroup = Group.getByName(_beaconDetails.uhfGroup)

    local _fmGroup = Group.getByName(_beaconDetails.fmGroup)

    local _radioLoop = {}

    if _vhfGroup ~= nil and _vhfGroup:getUnits() ~= nil and #_vhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _vhfGroup, freq = _beaconDetails.vhf, silent = false, mode = 0 })
    end

    if _uhfGroup ~= nil and _uhfGroup:getUnits() ~= nil and #_uhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _uhfGroup, freq = _beaconDetails.uhf, silent = true, mode = 0 })
    end

    if _fmGroup ~= nil and _fmGroup:getUnits() ~= nil and #_fmGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _fmGroup, freq = _beaconDetails.fm, silent = false, mode = 1 })
    end

    local _batLife = _beaconDetails.battery - timer.getTime()

    if (_batLife <= 0 and _beaconDetails.battery ~= -1) or #_radioLoop ~= 3 then
        -- ran out of batteries
        if _vhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_vhfGroup:getName())
            _vhfGroup:destroy()
        end
        if _uhfGroup ~= nil then
            trigger.action.stopRadioTransmission(_uhfGroup:getName())
            _uhfGroup:destroy()
        end
        if _fmGroup ~= nil then
            trigger.action.stopRadioTransmission(_fmGroup:getName())
            _fmGroup:destroy()
        end

        return false
    end

    --fobs have unlimited battery life
    --        if _battery ~= -1 then
    --                _text = _text.." "..mist.utils.round(_batLife).." seconds of battery"
    --        end

    for _, _radio in pairs(_radioLoop) do
        local _groupController = _radio.group:getController()

        local _sound = ctld.radioSound
        if _radio.silent then
            _sound = ctld.radioSoundFC3
        end

        _sound = "l10n/DEFAULT/" .. _sound

        _groupController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)


        -- stop the transmission at each call to the ctld.updateRadioBeacon method (default each minute)
        trigger.action.stopRadioTransmission(_radio.group:getName())

        -- restart it as the battery is still up
        -- the transmission is set to loop and has the name of the transmitting DCS group (that includes the type - i.e. FM, UHF, VHF)
        trigger.action.radioTransmission(_sound, _radio.group:getUnit(1):getPoint(), _radio.mode, true, _radio.freq, 1000,
            _radio.group:getName())
    end

    return true
end

function ctld.listRadioBeacons(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil then
        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                _message = _message .. _details.text .. "\n"
            end
        end

        if _message ~= "" then
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("Radio Beacons:\n%1", _message), 20)
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Active Radio Beacons"), 20)
        end
    end
end

function ctld.dropRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        --deploy 50 m infront
        --try to spawn at 12 oclock to us
        local _point = ctld.getPointAt12Oclock(_heli, 50)

        ctld.beaconCount = ctld.beaconCount + 1
        local _name = "Beacon #" .. ctld.beaconCount

        local _radioBeaconDetails = ctld.createRadioBeacon(_point, _heli:getCoalition(), _heli:getCountry(), _name, nil,
            false)

        -- mark with flare?

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 deployed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                _radioBeaconDetails.text, 20))
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before you can deploy a Radio Beacon!"),
            20)
    end
end

--remove closet radio beacon
function ctld.removeRadioBeacon(_args)
    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil and ctld.inAir(_heli) == false then
        -- mark with flare?

        local _closestBeacon = nil
        local _shortestDistance = -1
        local _distance = 0

        for _x, _details in pairs(ctld.deployedRadioBeacons) do
            if _details.coalition == _heli:getCoalition() then
                local _group = Group.getByName(_details.vhfGroup)

                if _group ~= nil and #_group:getUnits() == 1 then
                    _distance = ctld.getDistance(_heli:getPoint(), _group:getUnit(1):getPoint())
                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestBeacon = _details
                    end
                end
            end
        end

        if _closestBeacon ~= nil and _shortestDistance then
            local _vhfGroup = Group.getByName(_closestBeacon.vhfGroup)

            local _uhfGroup = Group.getByName(_closestBeacon.uhfGroup)

            local _fmGroup = Group.getByName(_closestBeacon.fmGroup)

            if _vhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_vhfGroup:getName())
                _vhfGroup:destroy()
            end
            if _uhfGroup ~= nil then
                trigger.action.stopRadioTransmission(_uhfGroup:getName())
                _uhfGroup:destroy()
            end
            if _fmGroup ~= nil then
                trigger.action.stopRadioTransmission(_fmGroup:getName())
                _fmGroup:destroy()
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 removed a Radio Beacon.\n\n%2", ctld.getPlayerNameOrType(_heli),
                    _closestBeacon.text, 20))
        else
            ctld.displayMessageToGroup(_heli, ctld.i18n_translate("No Radio Beacons within 500m."), 20)
        end
    else
        ctld.displayMessageToGroup(_heli, ctld.i18n_translate("You need to land before remove a Radio Beacon"), 20)
    end
end

-- gets the center of a bunch of points!
-- return proper DCS point with height
function ctld.getCentroid(_points)
    local _tx, _ty = 0, 0
    for _index, _point in ipairs(_points) do
        _tx = _tx + _point.x
        _ty = _ty + _point.z
    end

    local _npoints = #_points

    local _point = { x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({ _point.x, _point.z })

    return _point
end

function ctld.getAATemplate(_unitName)
    for _, _system in pairs(ctld.AASystemTemplate) do
        if _system.repair == _unitName then
            return _system
        end

        for _, _part in pairs(_system.parts) do
            if _unitName == _part.name then
                return _system
            end
        end
    end

    return nil
end

function ctld.getLauncherUnitFromAATemplate(_aaTemplate)
    for _, _part in pairs(_aaTemplate.parts) do
        if _part.launcher then
            return _part.name
        end
    end

    return nil
end

function ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    -- are we adding to existing aa system?
    -- check to see if the crate is a launcher
    if ctld.getLauncherUnitFromAATemplate(_aaSystemTemplate) == _nearestCrate.details.unit then
        -- find nearest COMPLETE AA system
        local _nearestSystem = ctld.findNearestAASystem(_heli, _aaSystemTemplate)

        if _nearestSystem ~= nil and _nearestSystem.dist < 300 then
            local _uniqueTypes = {}             -- stores each unique part of system
            local _types = {}
            local _points = {}
            local _hdgs = {}

            local _units = _nearestSystem.group:getUnits()

            if _units ~= nil and #_units > 0 then
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        --this allows us to count each type once
                        _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                        table.insert(_points, _units[x]:getPoint())
                        table.insert(_types, _units[x]:getTypeName())
                        table.insert(_hdgs, mist.getHeading(_units[x], true))
                    end
                end
            end

            -- do we have the correct number of unique pieces and do we have enough points for all the pieces
            if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                -- rearm aa system
                -- destroy old group
                ctld.completeAASystems[_nearestSystem.group:getName()] = nil

                _nearestSystem.group:destroy()

                local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

                ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup,
                    _aaSystemTemplate)

                ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action =
                "rearm" })

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("%1 successfully rearmed a full %2 in the field", ctld.getPlayerNameOrType(_heli),
                        _aaSystemTemplate.name, 20))

                if _heli:getCoalition() == 1 then
                    ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
                else
                    ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
                end

                -- remove crate
                --         if ctld.slingLoad == false then
                _nearestCrate.crateUnit:destroy()
                --    end

                return true                 -- all done so quit
            end
        end
    end

    return false
end

function ctld.getAASystemDetails(_hawkGroup, _aaSystemTemplate)
    local _units = _hawkGroup:getUnits()

    local _hawkDetails = {}

    for _, _unit in pairs(_units) do
        table.insert(_hawkDetails,
            { point = _unit:getPoint(), unit = _unit:getTypeName(), name = _unit:getName(), system = _aaSystemTemplate, hdg =
            mist.getHeading(_unit, true) })
    end

    return _hawkDetails
end

function ctld.countTableEntries(_table)
    if _table == nil then
        return 0
    end


    local _count = 0

    for _key, _value in pairs(_table) do
        _count = _count + 1
    end

    return _count
end

function ctld.unpackAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    ctld.logTrace("_nearestCrate = %s", ctld.p(_nearestCrate))
    ctld.logTrace("_nearbyCrates = %s", ctld.p(_nearbyCrates))
    ctld.logTrace("_aaSystemTemplate = %s", ctld.p(_aaSystemTemplate))

    if ctld.rearmAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate) then
        -- rearmed system
        return
    end

    local _systemParts = {}

    --initialise list of parts
    for _, _part in pairs(_aaSystemTemplate.parts) do
        local _systemPart = { name = _part.name, desc = _part.desc, launcher = _part.launcher, amount = _part.amount, NoCrate =
        _part.NoCrate, found = 0, required = 1 }
        -- if the part is a NoCrate required, it's found by default
        if _systemPart.NoCrate ~= nil then
            _systemPart.found = 1
        end
        _systemParts[_part.name] = _systemPart
    end

    local _cratePositions = {}
    local _crateHdg = {}

    local crateDistance = 500

    -- find all crates close enough and add them to the list if they're part of the AA System
    for _, _nearbyCrate in pairs(_nearbyCrates) do
        ctld.logTrace("_nearbyCrate = %s", ctld.p(_nearbyCrate))
        if _nearbyCrate.dist < crateDistance then
            local _name = _nearbyCrate.details.unit
            ctld.logTrace("_name = %s", ctld.p(_name))

            if _systemParts[_name] ~= nil then
                local foundCount = _systemParts[_name].found
                ctld.logTrace("foundCount = %s", ctld.p(foundCount))

                if not _cratePositions[_name] then
                    _cratePositions[_name] = {}
                end
                if not _crateHdg[_name] then
                    _crateHdg[_name] = {}
                end

                -- if this is our first time encountering this part of the system
                if foundCount == 0 then
                    local _foundPart = _systemParts[_name]

                    _foundPart.found = 1

                    -- store the number of crates required to compute how many crates will have to be removed later and to see if the system can be deployed
                    local cratesRequired = _nearbyCrate.details.cratesRequired
                    ctld.logTrace("cratesRequired = %s", ctld.p(cratesRequired))
                    if cratesRequired ~= nil then
                        _foundPart.required = cratesRequired
                    end

                    _systemParts[_name] = _foundPart
                else
                    -- otherwise, we found another crate for the same part
                    _systemParts[_name].found = foundCount + 1
                end

                -- add the crate to the part info along with it's position and heading
                local crateUnit = _nearbyCrate.crateUnit
                if not _systemParts[_name].crates then
                    _systemParts[_name].crates = {}
                end
                table.insert(_systemParts[_name].crates, _nearbyCrate)
                table.insert(_cratePositions[_name], crateUnit:getPoint())
                table.insert(_crateHdg[_name], mist.getHeading(crateUnit, true))
            end
        end
    end

    -- Compute the centroids for each type of crates and then the centroid of all the system crates which is used to find the spawn location for each part and a position for the NoCrate parts respectively
    -- One issue, all crates are considered for the centroid and the headings but not all of them may be used if crate stacking is allowed
    local _crateCentroids = {}
    local _idxCentroids = {}
    for _partName, _partPositions in pairs(_cratePositions) do
        _crateCentroids[_partName] = ctld.getCentroid(_partPositions)
        table.insert(_idxCentroids, _crateCentroids[_partName])
    end
    local _crateCentroid = ctld.getCentroid(_idxCentroids)

    -- Compute the average heading for each type of crates to know the heading to spawn the part
    local _aveHdg = {}
    -- Headings of each group of crates
    for _partName, _crateHeadings in pairs(_crateHdg) do
        local crateCount = #_crateHeadings
        _aveHdg[_partName] = 0
        -- Heading of each crate within a group
        for _index, _crateHeading in pairs(_crateHeadings) do
            _aveHdg[_partName] = _crateHeading / crateCount + _aveHdg[_partName]
        end
    end

    local spawnDistance = 50     -- circle radius to spawn units in a circle and randomize position relative to the crate location
    local arcRad = math.pi * 2

    local _txt = ""

    local _posArray = {}
    local _hdgArray = {}
    local _typeArray = {}
    -- for each part of the system parts
    for _name, _systemPart in pairs(_systemParts) do
        -- check if enough crates were found to build the part
        if _systemPart.found < _systemPart.required then
            _txt = _txt .. ctld.i18n_translate("Missing %1\n", _systemPart.desc)
        else
            -- use the centroid of the crates for this part as a spawn location
            local _point = _crateCentroids[_name]
            -- in the case this centroid does not exist (NoCrate), use the centroid of all crates found and add some randomness
            if _point == nil then
                _point = _crateCentroid
                _point = { x = _point.x + math.random(0, 3) * spawnDistance, y = _point.y, z = _point.z +
                math.random(0, 3) * spawnDistance }
            end

            -- use the average heading to spawn the part at
            local _hdg = _aveHdg[_name]
            -- if non are found (NoCrate), random heading
            if _hdg == nil then
                _hdg = math.random(0, arcRad)
            end

            -- search for the amount of times this part needs to be spawned, by default 1 for any unit and aaLaunchers for launchers
            local partAmount = 1
            if _systemPart.amount == nil then
                if _systemPart.launcher ~= nil then
                    partAmount = ctld.aaLaunchers
                end
            else
                -- but the amount may also be specified in the template
                partAmount = _systemPart.amount
            end
            -- if crate stacking is allowed, then find the multiplication factor for the amount depending on how many crates are required and how many were found
            if ctld.AASystemCrateStacking then
                _systemPart.amountFactor = _systemPart.found - _systemPart.found % _systemPart.required
            else
                _systemPart.amountFactor = 1
            end
            partAmount = partAmount * _systemPart.amountFactor

            --handle multiple units per part by spawning them in a circle around the crate
            if partAmount > 1 then
                local angular_step = arcRad / partAmount

                for _i = 1, partAmount do
                    local _angle = (angular_step * (_i - 1) + _hdg) % arcRad
                    local _xOffset = math.cos(_angle) * spawnDistance
                    local _yOffset = math.sin(_angle) * spawnDistance

                    table.insert(_posArray, { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset })
                    table.insert(_hdgArray, _angle)                     -- also spawn them perpendicular to that point of the circle
                    table.insert(_typeArray, _name)
                end
            else
                table.insert(_posArray, _point)
                table.insert(_hdgArray, _hdg)
                table.insert(_typeArray, _name)
            end
        end
    end

    local _activeLaunchers = ctld.countCompleteAASystems(_heli)

    local _allowed = ctld.getAllowedAASystems(_heli)

    env.info("Active: " .. _activeLaunchers .. " Allowed: " .. _allowed)

    if _activeLaunchers + 1 > _allowed then
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("Out of parts for AA Systems. Current limit is %1\n", _allowed, 10))
        return
    end

    if _txt ~= "" then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot build %1\n%2\n\nOr the crates are not close enough together",
                _aaSystemTemplate.name, _txt), 20)
        return
    else
        -- destroy crates
        for _name, _systemPart in pairs(_systemParts) do
            -- if there is a crate to delete in the first place
            if _systemPart.NoCrate ~= true then
                -- figure out how many crates to delete since we searched for as many as possible, not all of them might have been used
                local amountToDel = _systemPart.amountFactor * _systemPart.required
                local DelCounter = 0

                -- for each crate found for this part
                for _index, _crate in pairs(_systemPart.crates) do
                    -- if we still need to delete some crates
                    if DelCounter < amountToDel then
                        if _heli:getCoalition() == 1 then
                            ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                        else
                            ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                        end

                        --destroy
                        -- if ctld.slingLoad == false then
                        _crate.crateUnit:destroy()
                        DelCounter = DelCounter + 1                                 -- count up for one more crate has been deleted
                        --end
                    else
                        break
                    end
                end
            end
        end

        -- HAWK / BUK READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray, _hdgArray)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
            "%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4",
                ctld.getPlayerNameOrType(_heli), _aaSystemTemplate.name, _allowed, (_activeLaunchers + 1)), 10)
    end
end

--count the number of captured cities, sets the amount of allowed AA Systems
function ctld.getAllowedAASystems(_heli)
    if _heli:getCoalition() == 1 then
        return ctld.AASystemLimitBLUE
    else
        return ctld.AASystemLimitRED
    end
end

function ctld.countCompleteAASystems(_heli)
    local _count = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do
        local _hawkGroup = Group.getByName(_groupName)

        --    env.info(_groupName..": "..mist.utils.tableShow(_hawkDetails))
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() then
            local _units = _hawkGroup:getUnits()

            if _units ~= nil and #_units > 0 then
                --get the system template
                local _aaSystemTemplate = _hawkDetails[1].system

                local _uniqueTypes = {}                 -- stores each unique part of system
                local _types = {}
                local _points = {}

                if _units ~= nil and #_units > 0 then
                    for x = 1, #_units do
                        if _units[x]:getLife() > 0 then
                            --this allows us to count each type once
                            _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                            table.insert(_points, _units[x]:getPoint())
                            table.insert(_types, _units[x]:getTypeName())
                        end
                    end
                end

                -- do we have the correct number of unique pieces and do we have enough points for all the pieces
                if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                    _count = _count + 1
                end
            end
        end
    end

    return _count
end

function ctld.repairAASystem(_heli, _nearestCrate, _aaSystem)
    -- find nearest COMPLETE AA system
    local _nearestHawk = ctld.findNearestAASystem(_heli, _aaSystem)



    if _nearestHawk ~= nil and _nearestHawk.dist < ctld.maxDistanceBetweenCratesForBuilding then
        local _oldHawk = ctld.completeAASystems[_nearestHawk.group:getName()]

        --spawn new one

        local _types = {}
        local _hdgs = {}
        local _points = {}

        for _, _part in pairs(_oldHawk) do
            table.insert(_points, _part.point)
            table.insert(_hdgs, _part.hdg)
            table.insert(_types, _part.unit)
        end

        --remove old system
        ctld.completeAASystems[_nearestHawk.group:getName()] = nil
        _nearestHawk.group:destroy()

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types, _hdgs)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystem)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "repair" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 successfully repaired a full %2 in the field.", ctld.getPlayerNameOrType(_heli),
                _aaSystem.name), 10)

        if _heli:getCoalition() == 1 then
            ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
        else
            ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
        end

        -- remove crate
        -- if ctld.slingLoad == false then
        _nearestCrate.crateUnit:destroy()
        -- end
    else
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot repair %1. No damaged %2 within %3", _aaSystem.name, _aaSystem.name, ctld.maxDistanceBetweenCratesForBuilding), 10)
    end
end

function ctld.unpackMultiCrate(_heli, _nearestCrate, _nearbyCrates)
    ctld.logTrace("FG_ ctld.unpackMultiCrate, _nearestCrate =  %s", ctld.p(_nearestCrate))
    -- unpack multi crate
    local _nearbyMultiCrates = {}

    for _, _nearbyCrate in pairs(_nearbyCrates) do
        if _nearbyCrate.dist < ctld.maxDistanceBetweenCratesForBuilding then
            if _nearbyCrate.details.unit == _nearestCrate.details.unit then
                table.insert(_nearbyMultiCrates, _nearbyCrate)
                if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
                    break
                end
            end
        end
    end

    --- check crate count
    if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
        --local _point    = _nearestCrate.crateUnit:getPoint()
        --local _point    = _heli:getPoint()
        --local secureDistanceFromUnit = ctld.getSecureDistanceFromUnit(_heli:getName())
        --_point.x = _point.x + secureDistanceFromUnit
        local _point = ctld.getPointInFrontSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        if ctld.unitDynamicCargoCapable(_heli) == true then
            _point = ctld.getPointInRearSector(_heli, ctld.getSecureDistanceFromUnit(_heli:getName()))
        end

        local _crateHdg = mist.getHeading(_nearestCrate.crateUnit, true)

        -- destroy crates
        for _, _crate in pairs(_nearbyMultiCrates) do
            if _point == nil then
                _point = _crate.crateUnit:getPoint()
            end

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            --destroy
            --     if ctld.slingLoad == false then
            _crate.crateUnit:destroy()
            --     end
        end


        local _spawnedGroup = ctld.spawnCrateGroup(_heli, { _point }, { _nearestCrate.details.unit }, { _crateHdg })
        if _spawnedGroup == nil then
            ctld.logError("ctld.unpackMultiCrate group was not spawned - skipping setGrpROE")
        else
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1)  -- for add unpacked unit in repack menu
            ctld.setGrpROE(_spawnedGroup)
            ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })
            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 successfully deployed %2 to the field using %3 crates.",
                    ctld.getPlayerNameOrType(_heli), _nearestCrate.details.desc, #_nearbyMultiCrates), 10)
        end
    else
        local _txt = ctld.i18n_translate(
        "Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within %4 of each other",
            _nearestCrate.details.desc, _nearestCrate.details.cratesRequired, #_nearbyMultiCrates, ctld.maxDistanceBetweenCratesForBuilding)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.unpackAirdropFOB(_heli, _nearestCrate, _nearbyCrates)
    ctld.logTrace("FG_ ctld.unpackAirdropFOB, _nearestCrate =  %s", ctld.p(_nearestCrate))
    
    if ctld.inLogisticsZone(_heli) == true then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("You can't unpack that here! Take it to where it's needed!"), 20)
        return
    end

    -- Get enhanced crate detection for airdrops
    local _enhancedCrates = ctld.getAirdropCratesAndDistance(_heli)
    
    local _nearbyMultiCrates = {}
    local _bigFobCrates = 0
    local _smallFobCrates = 0
    local _totalCrates = 0

    for _, _enhancedCrate in pairs(_enhancedCrates) do
        -- Check distance between this crate and the nearest crate, not distance to helicopter
        local _distBetweenCrates = ctld.getDistance(_enhancedCrate.crateUnit:getPoint(), _nearestCrate.crateUnit:getPoint())
        
        if _distBetweenCrates < 750 then
            if _enhancedCrate.details.unit == "FOB-SMALL" then
                _smallFobCrates = _smallFobCrates + 1
                table.insert(_nearbyMultiCrates, _enhancedCrate)
                ctld.logTrace("FG_ Found airdrop FOB-SMALL crate: %s at distance %.1f from nearest crate", _enhancedCrate.crateUnit:getName(), _distBetweenCrates)
            end

            --catch divide by 0
            if _smallFobCrates > 0 then
                _totalCrates = _bigFobCrates + (_smallFobCrates / 3.0)
            else
                _totalCrates = _bigFobCrates
            end

            if _totalCrates >= ctld.cratesRequiredForFOB then
                break
            end
        else
            ctld.logTrace("FG_ Airdrop FOB crate too far: %s at distance %.1f from nearest crate (max: 750)", _enhancedCrate.crateUnit:getName(), _distBetweenCrates)
        end
    end

    ctld.logTrace("FG_ Found %d airdrop FOB crates (total equivalent: %.1f of required %d)", #_nearbyMultiCrates, _totalCrates, ctld.cratesRequiredForFOB)

    --- check crate count
    if _totalCrates >= ctld.cratesRequiredForFOB then
        -- destroy crates and collect positions
        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do
            if _heli:getCoalition() == 1 then
                ctld.droppedFOBCratesRED[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedFOBCratesBLUE[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())
            _crate.crateUnit:destroy()
        end

        -- Use the nearest crate position as the FOB location for airdrops
        local _centroid = _nearestCrate.crateUnit:getPoint()
        
        -- If multiple crates, calculate average position for better centering
        if #_points > 1 then
            _centroid = ctld.getCentroid(_points)
        end

        timer.scheduleFunction(function(_args)
            local _unitId = ctld.getNextUnitId()
            local _name = "Deployed FOB #" .. _unitId

            local _fob = ctld.spawnFOB(_args[2], _unitId, _args[1], _name)

            --make it able to deploy crates
            table.insert(ctld.logisticUnits, _fob:getName())

            ctld.beaconCount = ctld.beaconCount + 1

            local _radioBeaconName = "FOB Beacon #" .. ctld.beaconCount

            local _radioBeaconDetails = ctld.createRadioBeacon(_args[1], _args[3], _args[2], _radioBeaconName, nil, true)

            ctld.fobBeacons[_name] = { vhf = _radioBeaconDetails.vhf, uhf = _radioBeaconDetails.uhf, fm =
            _radioBeaconDetails.fm }

            if ctld.troopPickupAtFOB == true then
                table.insert(ctld.builtFOBS, _fob:getName())

                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates and Troops can now be picked up."), 10)
            else
                trigger.action.outTextForCoalition(_heli:getCoalition(),
                    ctld.i18n_translate("Finished building FOB! Crates can now be picked up."), 10)
            end
        end, { _centroid, _heli:getCountry(), _heli:getCoalition() }, timer.getTime() + ctld.buildTimeFOB)

        ctld.processCallback({ unit = _heli, position = _centroid, action = "fob" })

        trigger.action.smoke(_centroid, trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
            "%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke.",
                ctld.getPlayerNameOrType(_heli), _totalCrates, ctld.buildTimeFOB, 10))
    else
        local _txt = ctld.i18n_translate(
        "Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other",
            ctld.cratesRequiredForFOB, _totalCrates)
        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.unpackAirdropAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)
    ctld.logTrace("FG_ ctld.unpackAirdropAASystem, _nearestCrate = %s", ctld.p(_nearestCrate))
    ctld.logTrace("FG_ ctld.unpackAirdropAASystem, _aaSystemTemplate = %s", ctld.p(_aaSystemTemplate))

    -- Use enhanced airdrop crate detection
    local _enhancedCrates = ctld.getAirdropCratesAndDistance(_heli)
    
    if ctld.rearmAASystem(_heli, _nearestCrate, _enhancedCrates, _aaSystemTemplate) then
        -- rearmed system
        return
    end

    local _systemParts = {}

    --initialise list of parts
    for _, _part in pairs(_aaSystemTemplate.parts) do
        local _systemPart = { name = _part.name, desc = _part.desc, launcher = _part.launcher, amount = _part.amount, NoCrate =
        _part.NoCrate, found = 0, required = 1 }
        -- if the part is a NoCrate required, it's found by default
        if _systemPart.NoCrate ~= nil then
            _systemPart.found = 1
        end
        _systemParts[_part.name] = _systemPart
    end

    local _cratePositions = {}
    local _crateHdg = {}

    local crateDistance = 500

    -- find all crates close enough and add them to the list if they're part of the AA System
    -- Use enhanced crates instead of nearbyCrates for airdrop detection
    for _, _enhancedCrate in pairs(_enhancedCrates) do
        ctld.logTrace("FG_ Processing airdrop crate: %s", ctld.p(_enhancedCrate))
        
        -- Check distance between this crate and the nearest crate, not distance to helicopter
        local _distBetweenCrates = ctld.getDistance(_enhancedCrate.crateUnit:getPoint(), _nearestCrate.crateUnit:getPoint())
        
        if _distBetweenCrates < crateDistance then
            local _name = _enhancedCrate.details.unit
            ctld.logTrace("FG_ Airdrop AA crate name: %s", ctld.p(_name))

            if _systemParts[_name] ~= nil then
                local foundCount = _systemParts[_name].found
                ctld.logTrace("FG_ Found airdrop AA system part: %s (foundCount: %d)", _name, foundCount)

                if not _cratePositions[_name] then
                    _cratePositions[_name] = {}
                end
                if not _crateHdg[_name] then
                    _crateHdg[_name] = {}
                end

                -- if this is our first time encountering this part of the system
                if foundCount == 0 then
                    local _foundPart = _systemParts[_name]

                    _foundPart.found = 1

                    -- store the number of crates required to compute how many crates will have to be removed later and to see if the system can be deployed
                    local cratesRequired = _enhancedCrate.details.cratesRequired
                    ctld.logTrace("FG_ cratesRequired = %s", ctld.p(cratesRequired))
                    if cratesRequired ~= nil then
                        _foundPart.required = cratesRequired
                    end

                    _systemParts[_name] = _foundPart
                else
                    -- otherwise, we found another crate for the same part
                    _systemParts[_name].found = foundCount + 1
                end

                -- add the crate to the part info along with it's position and heading
                local crateUnit = _enhancedCrate.crateUnit
                if not _systemParts[_name].crates then
                    _systemParts[_name].crates = {}
                end
                table.insert(_systemParts[_name].crates, _enhancedCrate)
                table.insert(_cratePositions[_name], crateUnit:getPoint())
                table.insert(_crateHdg[_name], mist.getHeading(crateUnit, true))
            end
        else
            ctld.logTrace("FG_ Airdrop AA crate too far: %s at distance %.1f from nearest crate (max: %d)", _enhancedCrate.crateUnit:getName(), _distBetweenCrates, crateDistance)
        end
    end

    -- Rest of the function is identical to unpackAASystem but uses the enhanced crate detection results

    -- Compute the centroids for each type of crates and then the centroid of all the system crates 
    local _crateCentroids = {}
    local _idxCentroids = {}
    for _partName, _partPositions in pairs(_cratePositions) do
        _crateCentroids[_partName] = ctld.getCentroid(_partPositions)
        table.insert(_idxCentroids, _crateCentroids[_partName])
    end
    local _crateCentroid = ctld.getCentroid(_idxCentroids)

    -- Compute the average heading for each type of crates to know the heading to spawn the part
    local _aveHdg = {}
    for _partName, _crateHeadings in pairs(_crateHdg) do
        local crateCount = #_crateHeadings
        _aveHdg[_partName] = 0
        for _index, _crateHeading in pairs(_crateHeadings) do
            _aveHdg[_partName] = _crateHeading / crateCount + _aveHdg[_partName]
        end
    end

    local spawnDistance = 50
    local arcRad = math.pi * 2

    local _txt = ""

    local _posArray = {}
    local _hdgArray = {}
    local _typeArray = {}
    
    for _name, _systemPart in pairs(_systemParts) do
        if _systemPart.found < _systemPart.required then
            _txt = _txt .. ctld.i18n_translate("Missing %1\n", _systemPart.desc)
        else
            local _point = _crateCentroids[_name]
            if _point == nil then
                _point = _crateCentroid
                _point = { x = _point.x + math.random(0, 3) * spawnDistance, y = _point.y, z = _point.z +
                math.random(0, 3) * spawnDistance }
            end

            local _hdg = _aveHdg[_name]
            if _hdg == nil then
                _hdg = math.random(0, arcRad)
            end

            local partAmount = 1
            if _systemPart.amount == nil then
                if _systemPart.launcher ~= nil then
                    partAmount = ctld.aaLaunchers
                end
            else
                partAmount = _systemPart.amount
            end
            
            if ctld.AASystemCrateStacking then
                _systemPart.amountFactor = _systemPart.found - _systemPart.found % _systemPart.required
            else
                _systemPart.amountFactor = 1
            end
            partAmount = partAmount * _systemPart.amountFactor

            if partAmount > 1 then
                local angular_step = arcRad / partAmount

                for _i = 1, partAmount do
                    local _angle = (angular_step * (_i - 1) + _hdg) % arcRad
                    local _xOffset = math.cos(_angle) * spawnDistance
                    local _yOffset = math.sin(_angle) * spawnDistance

                    table.insert(_posArray, { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset })
                    table.insert(_hdgArray, _angle)
                    table.insert(_typeArray, _name)
                end
            else
                table.insert(_posArray, _point)
                table.insert(_hdgArray, _hdg)
                table.insert(_typeArray, _name)
            end
        end
    end

    local _activeLaunchers = ctld.countCompleteAASystems(_heli)
    local _allowed = ctld.getAllowedAASystems(_heli)

    env.info("Active: " .. _activeLaunchers .. " Allowed: " .. _allowed)

    if _activeLaunchers + 1 > _allowed then
        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("Out of parts for AA Systems. Current limit is %1\n", _allowed, 10))
        return
    end

    if _txt ~= "" then
        ctld.displayMessageToGroup(_heli,
            ctld.i18n_translate("Cannot build %1\n%2\n\nOr the airdrop crates are not close enough together",
                _aaSystemTemplate.name, _txt), 20)
        return
    else
        -- destroy crates
        for _name, _systemPart in pairs(_systemParts) do
            if _systemPart.NoCrate ~= true then
                local amountToDel = _systemPart.amountFactor * _systemPart.required
                local DelCounter = 0

                for _index, _crate in pairs(_systemPart.crates) do
                    if DelCounter < amountToDel then
                        if _heli:getCoalition() == 1 then
                            ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                        else
                            ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                        end

                        _crate.crateUnit:destroy()
                        DelCounter = DelCounter + 1
                    else
                        break
                    end
                end
            end
        end

        -- AA SYSTEM READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray, _hdgArray)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate(
            "%1 successfully deployed a full %2 in the field using airdrop crates. \n\nAA Active System limit is: %3\nActive: %4",
                ctld.getPlayerNameOrType(_heli), _aaSystemTemplate.name, _allowed, (_activeLaunchers + 1)), 10)
    end
end

function ctld.unpackAirdropSingleCrate(_heli, _crate)
    ctld.logTrace("FG_ ctld.unpackAirdropSingleCrate, _crate =  %s", ctld.p(_crate))
    
    -- For airdrops, spawn at the crate location, not aircraft location
    local _point = _crate.crateUnit:getPoint()
    local _crateName = _crate.crateUnit:getName()
    local _crateHdg = mist.getHeading(_crate.crateUnit, true)

    _crate.crateUnit:destroy()

    ctld.logTrace("FG_ Airdrop single crate destroyed: %s", _crateName)

    local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _point }, { _crate.details.unit }, { _crateHdg })

    ctld.logTrace("FG_ Airdrop single crate spawned groups: %s", ctld.p(_spawnedGroups))

    if _heli:getCoalition() == 1 then
        ctld.spawnedCratesRED[_crateName] = nil
    else
        ctld.spawnedCratesBLUE[_crateName] = nil
    end

    ctld.processCallback({ unit = _heli, crate = _crate, spawnedGroup = _spawnedGroups, action = "unpack" })

    if _crate.details.unit == "1L13 EWR" then
        ctld.addEWRTask(_spawnedGroups)
    end

    trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 successfully deployed %2 to the field", ctld.getPlayerNameOrType(_heli), _crate.details.desc), 10)

    timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1)  -- for add unpacked unit in repack menu
    
    if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then
        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
        --put to the end
        table.insert(ctld.jtacGeneratedLaserCodes, _code)
        ctld.JTACStart(_spawnedGroups:getName(), _code)
    end
end

function ctld.unpackAirdropMultiCrate(_heli, _nearestCrate, _nearbyCrates)
    ctld.logTrace("FG_ ctld.unpackAirdropMultiCrate, _nearestCrate =  %s", ctld.p(_nearestCrate))
    
    -- Get enhanced crate detection for airdrops
    local _enhancedCrates = ctld.getAirdropCratesAndDistance(_heli)
    
    -- unpack multi crate with enhanced detection
    local _nearbyMultiCrates = {}

    for _, _enhancedCrate in pairs(_enhancedCrates) do
        if _enhancedCrate.details.unit == _nearestCrate.details.unit then
            -- Check distance between this crate and the nearest crate, not distance to helicopter
            local _distBetweenCrates = ctld.getDistance(_enhancedCrate.crateUnit:getPoint(), _nearestCrate.crateUnit:getPoint())
            
            if _distBetweenCrates < ctld.maxDistanceBetweenCratesForBuilding then
                table.insert(_nearbyMultiCrates, _enhancedCrate)
                ctld.logTrace("FG_ Found matching airdrop crate: %s at distance %.1f from nearest crate", _enhancedCrate.crateUnit:getName(), _distBetweenCrates)
                if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
                    break
                end
            else
                ctld.logTrace("FG_ Airdrop crate too far: %s at distance %.1f from nearest crate (max: %d)", _enhancedCrate.crateUnit:getName(), _distBetweenCrates, ctld.maxDistanceBetweenCratesForBuilding)
            end
        else
            ctld.logTrace("FG_ Airdrop crate type mismatch: %s has type '%s', expected '%s'", _enhancedCrate.crateUnit:getName(), _enhancedCrate.details.unit, _nearestCrate.details.unit)
        end
    end

    ctld.logTrace("FG_ Found %d airdrop crates of required %d", #_nearbyMultiCrates, _nearestCrate.details.cratesRequired)

    --- check crate count
    if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
        -- For airdrops, spawn at the crate location, not aircraft location
        local _point = _nearestCrate.crateUnit:getPoint()
        
        -- Calculate average position if multiple crates (for better centering)
        if #_nearbyMultiCrates > 1 then
            local _totalX, _totalZ = 0, 0
            for _, _crate in pairs(_nearbyMultiCrates) do
                local _cratePos = _crate.crateUnit:getPoint()
                _totalX = _totalX + _cratePos.x
                _totalZ = _totalZ + _cratePos.z
            end
            _point = {
                x = _totalX / #_nearbyMultiCrates,
                y = _point.y, -- Keep the Y from the nearest crate
                z = _totalZ / #_nearbyMultiCrates
            }
            ctld.logTrace("FG_ Calculated average spawn position from %d crates: x=%.1f, z=%.1f", #_nearbyMultiCrates, _point.x, _point.z)
        else
            ctld.logTrace("FG_ Using single crate position for spawn: x=%.1f, z=%.1f", _point.x, _point.z)
        end

        local _crateHdg = mist.getHeading(_nearestCrate.crateUnit, true)

        -- destroy crates
        for _, _crate in pairs(_nearbyMultiCrates) do
            if _point == nil then
                _point = _crate.crateUnit:getPoint()
            end

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            --destroy
            _crate.crateUnit:destroy()
        end

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, { _point }, { _nearestCrate.details.unit }, { _crateHdg })
        if _spawnedGroup == nil then
            ctld.logError("ctld.unpackAirdropMultiCrate group was not spawned - skipping setGrpROE")
        else
            timer.scheduleFunction(ctld.autoUpdateRepackMenu, { reschedule = false }, timer.getTime() + 1)
            ctld.setGrpROE(_spawnedGroup)
            ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })
            trigger.action.outTextForCoalition(_heli:getCoalition(),
                ctld.i18n_translate("%1 successfully deployed %2 to the field using %3 airdrop crates.",
                    ctld.getPlayerNameOrType(_heli), _nearestCrate.details.desc, #_nearbyMultiCrates), 10)
        end
    else
        local _txt = ctld.i18n_translate(
        "Cannot build %1!\n\nIt requires %2 airdrop crates and there are %3 \n\nOr the crates are not within %4 of each other",
            _nearestCrate.details.desc, _nearestCrate.details.cratesRequired, #_nearbyMultiCrates, ctld.maxDistanceBetweenCratesForBuilding)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.spawnCrateGroup(_heli, _positions, _types, _hdgs)
    -- ctld.logTrace("_heli      =  %s", ctld.p(_heli))
    -- ctld.logTrace("_positions =  %s", ctld.p(_positions))
    -- ctld.logTrace("_types     =  %s", ctld.p(_types))
    -- ctld.logTrace("_hdgs      =  %s", ctld.p(_hdgs))

    local _id = ctld.getNextGroupId()
    local _groupName = _types[1] .. "    #" .. _id
    local _side = _heli:getCoalition()
    local _group = {
        ["visible"]  = false,
        -- ["groupId"] = _id,
        ["hidden"]   = false,
        ["units"]    = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"]     = _groupName,
        ["tasks"]    = {},
        ["radioSet"] = false,
        ["task"]     = "Reconnaissance",
        ["route"]    = {},
    }

    local _hdg = 120 * math.pi / 180                                         -- radians = 120 degrees
    if _types[1] ~= "MQ-9 Reaper" and _types[1] ~= "RQ-1A Predator" then     -- non-drones - JTAC
        local _spreadMin = 5
        local _spreadMax = 5
        local _spreadMult = 1
        for _i, _pos in ipairs(_positions) do
            local _unitId = ctld.getNextUnitId()
            local _details = { type = _types[_i], unitId = _unitId, name = string.format("Unpacked %s #%i", _types[_i], _unitId) }
            --ctld.logTrace("Group._details =  %s", ctld.p(_details))
            if _hdgs and _hdgs[_i] then
                _hdg = _hdgs[_i]
            end

            _group.units[_i] = ctld.createUnit(_pos.x + math.random(_spreadMin, _spreadMax) * _spreadMult,
                _pos.z + math.random(_spreadMin, _spreadMax) * _spreadMult,
                _hdg,
                _details)
        end
        _group.category = Group.Category.GROUND
    else     -- drones - JTAC
        local _unitId = ctld.getNextUnitId()
        local _details = {
            type      = _types[1],
            unitId    = _unitId,
            name      = string.format("Unpacked %s #%i", _types[1], _unitId),
            livery_id = "'camo' scheme",
            skill     = "High",
            speed     = 80,
            payload   = { pylons = {}, fuel = 1300, flare = 0, chaff = 0, gun = 100 }
        }

        _group.units[1] = ctld.createUnit(_positions[1].x,
            _positions[1].z + ctld.jtacDroneRadius,
            _hdg,
            _details)

        _group.category = Group.Category.AIRPLANE         -- for drones

        -- create drone orbiting route
        local DroneRoute = {
            ["points"] =
            {
                [1] =
                {
                    ["alt"] = 2000,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] =
                    {
                        ["addopt"] = {},
                    }, -- end of ["properties"]
                    ["speed"] = 80,
                    ["task"] =
                    {
                        ["id"] = "ComboTask",
                        ["params"] =
                        {
                            ["tasks"] =
                            {
                                [1] =
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 1,
                                    ["params"] =
                                    {
                                        ["action"] =
                                        {
                                            ["id"] = "EPLRS",
                                            ["params"] =
                                            {
                                                ["value"] = true,
                                                ["groupId"] = 0,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [1]
                                [2] =
                                {
                                    ["number"] = 2,
                                    ["auto"] = false,
                                    ["id"] = "Orbit",
                                    ["enabled"] = true,
                                    ["params"] =
                                    {
                                        ["altitude"] = ctld.jtacDroneAltitude,
                                        ["pattern"]  = "Circle",
                                        ["speed"]    = 80,
                                    }, -- end of ["params"]
                                }, -- end of [2]
                                [3] =
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 3,
                                    ["params"] =
                                    {
                                        ["action"] =
                                        {
                                            ["id"] = "Option",
                                            ["params"] =
                                            {
                                                ["value"] = true,
                                                ["name"] = 6,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [3]
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = _positions[1].z,
                    ["x"] = _positions[1].x,
                    ["speed_locked"] = true,
                    ["formation_template"] = "",
                }, -- end of [1]
            }, -- end of ["points"]
        } -- end of ["route"]
        ---------------------------------------------------------------------------------
        _group.route = DroneRoute
    end

    _group.country = _heli:getCountry()
    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)
    return _spawnedGroup
end

-- spawn normal group
function ctld.spawnDroppedGroup(_point, _details, _spawnBehind, _maxSearch)
    local _groupName = _details.groupName

    local _group = {
        ["visible"] = false,
        --    ["groupId"] = _details.groupId,
        ["hidden"] = false,
        ["units"] = {},
        --                ["y"] = _positions[1].z,
        --                ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["task"] = {},
    }


    if _spawnBehind == false then
        -- spawn in circle around heli

        local _pos = _point

        for _i, _detail in ipairs(_details.units) do
            local _angle = math.pi * 2 * (_i - 1) / #_details.units
            local _xOffset = math.cos(_angle) * 30
            local _yOffset = math.sin(_angle) * 30

            _group.units[_i] = ctld.createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _detail)
        end
    else
        local _pos = _point

        --try to spawn at 6 oclock to us
        local _angle   = math.atan(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * -30
        local _yOffset = math.sin(_angle) * -30


        for _i, _detail in ipairs(_details.units) do
            _group.units[_i] = ctld.createUnit(_pos.x + (_xOffset + 10 * _i), _pos.z + (_yOffset + 10 * _i), _angle,
                _detail)
        end
    end

    --switch to MIST
    _group.category = Group.Category.GROUND;
    _group.country = _details.country;

    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

    --local _spawnedGroup = coalition.addGroup(_details.country, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    if _maxSearch == nil then
        _maxSearch = ctld.maximumSearchDistance
    end

    local _wpZone = ctld.inWaypointZone(_point, _spawnedGroup:getCoalition())

    if _wpZone.inZone then
        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _wpZone.point)
        env.info("Heading to waypoint - In Zone " .. _wpZone.name)
    else
        local _enemyPos = ctld.findNearestEnemy(_details.side, _point, _maxSearch)

        ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _enemyPos)
    end

    return _spawnedGroup
end

function ctld.findNearestEnemy(_side, _point, _searchDistance)
    local _closestEnemy = nil

    local _groups

    local _closestEnemyDist = _searchDistance

    local _heliPoint = _point

    if _side == 2 then
        _groups = coalition.getGroups(1, Group.Category.GROUND)
    else
        _groups = coalition.getGroups(2, Group.Category.GROUND)
    end

    for _, _group in pairs(_groups) do
        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        _leader = _units[x]
                        break
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestEnemyDist then
                        _closestEnemyDist = _dist
                        _closestEnemy = _leaderPos
                    end
                end
            end
        end
    end


    -- no enemy - move to random point
    if _closestEnemy ~= nil then
        -- env.info("found enemy")
        return _closestEnemy
    else
        local _x = _heliPoint.x + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _z = _heliPoint.z + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _y = _heliPoint.y + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)

        return { x = _x, z = _z, y = _y }
    end
end

function ctld.findNearestGroup(_heli, _groups)
    local _closestGroupDetails = {}
    local _closestGroup = nil

    local _closestGroupDist = ctld.maxExtractDistance

    local _heliPoint = _heli:getPoint()

    for _, _groupName in pairs(_groups) do
        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then
                local _leader = nil

                local _groupDetails = { groupId = _group:getID(), groupName = _group:getName(), side = _group
                :getCoalition(), units = {} }

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        if _leader == nil then
                            _leader = _units[x]
                            -- set country based on leader
                            _groupDetails.country = _leader:getCountry()
                        end

                        local _unitDetails = { type = _units[x]:getTypeName(), unitId = _units[x]:getID(), name = _units
                        [x]:getName() }

                        table.insert(_groupDetails.units, _unitDetails)
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestGroupDist then
                        _closestGroupDist = _dist
                        _closestGroupDetails = _groupDetails
                        _closestGroup = _group
                    end
                end
            end
        end
    end


    if _closestGroup ~= nil then
        return { group = _closestGroup, details = _closestGroupDetails }
    else
        return nil
    end
end

function ctld.createUnit(_x, _y, _angle, _details)
    local _newUnit = {
        ["y"] = _y,
        ["type"] = _details.type,
        ["name"] = _details.name,
        --    ["unitId"] = _details.unitId,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function ctld.addEWRTask(_group)
    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_ewrGroup)
        local _grp = ctld.getAliveGroup(_ewrGroup)

        if _grp ~= nil then
            local _controller = _grp:getController();
            local _EWR = {
                id = 'EWR',
                auto = true,
                params = {
                }
            }
            _controller:setTask(_EWR)
        end
    end
    , _group:getName(), timer.getTime() + 2)
end

function ctld.orderGroupToMoveToPoint(_leader, _destination)
    local _group = _leader:getGroup()

    local _path = {}
    table.insert(_path, mist.ground.buildWP(_leader:getPoint(), 'Off Road', 50))
    table.insert(_path, mist.ground.buildWP(_destination, 'Off Road', 50))

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points = _path
            },
        },
    }


    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_arg)
        local _grp = ctld.getAliveGroup(_arg[1])

        if _grp ~= nil then
            local _controller = _grp:getController();
            Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
            Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            _controller:setTask(_arg[2])
        end
    end
    , { _group:getName(), _mission }, timer.getTime() + 2)
end

-- are we in pickup zone
function ctld.inPickupZone(_heli)
    if ctld.inAir(_heli) then
        return { inZone = false, limit = -1, index = -1 }
    end

    local _heliPoint = _heli:getPoint()

    for _i, _zoneDetails in pairs(ctld.pickupZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone == nil then
            local _ship = ctld.getTransportUnit(_zoneDetails[1])

            if _ship then
                local _point = _ship:getPoint()
                _triggerZone = {}
                _triggerZone.point = _point
                _triggerZone.radius = 200                 -- should be big enough for ship
            end
        end

        if _triggerZone ~= nil then
            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)
            if _dist <= _triggerZone.radius then
                local _heliCoalition = _heli:getCoalition()
                if _zoneDetails[4] == 1 and (_zoneDetails[5] == _heliCoalition or _zoneDetails[5] == 0) then
                    return { inZone = true, limit = _zoneDetails[3], index = _i }
                end
            end
        end
    end

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do
        --get distance to center

        local _dist = ctld.getDistance(_heliPoint, _fob:getPoint())

        if _dist <= 150 then
            return { inZone = true, limit = 10000, index = -1 };
        end
    end



    return { inZone = false, limit = -1, index = -1 };
end

function ctld.getSpawnedFobs(_heli)
    local _fobs = {}

    for _, _fobName in ipairs(ctld.builtFOBS) do
        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getCoalition() == _heli:getCoalition() and _fob:getLife() > 0 then
            table.insert(_fobs, _fob)
        end
    end

    return _fobs
end

-- are we in a dropoff zone
function ctld.inDropoffZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.dropOffZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil and (_zoneDetails[3] == _heli:getCoalition() or _zoneDetails[3] == 0) then
            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    return false
end

-- are we in a waypoint zone
function ctld.inWaypointZone(_point, _coalition)
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --right coalition and active?
        if _triggerZone ~= nil and (_zoneDetails[4] == _coalition or _zoneDetails[4] == 0) and _zoneDetails[3] == 1 then
            --get distance to center

            local _dist = ctld.getDistance(_point, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return { inZone = true, point = _triggerZone.point, name = _zoneDetails[1] }
            end
        end
    end

    return { inZone = false }
end

-- are we near friendly logistics zone
function ctld.inLogisticsZone(_heli)
    ctld.logDebug("ctld.inLogisticsZone(), _heli = %s", ctld.p(_heli))

    if ctld.inAir(_heli) then
        return false
    end
    
    local _heliPoint = _heli:getPoint()
    ctld.logDebug("_heliPoint = %s", ctld.p(_heliPoint))
    for _, _name in pairs(ctld.logisticUnits) do
        ctld.logDebug("_name = %s", ctld.p(_name))
        local _logistic = StaticObject.getByName(_name)
        if not _logistic then
            _logistic = Unit.getByName(_name)
        end
        ctld.logDebug("_logistic = %s", ctld.p(_logistic))
        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() and _logistic:getLife() > 0 then
            --get distance
            local _dist = ctld.getDistance(_heliPoint, _logistic:getPoint())
            if _dist <= ctld.maximumDistanceLogistic then
                return true
            end
        end
    end

    return false
end

-- are far enough from a friendly logistics zone
function ctld.farEnoughFromLogisticZone(_heli)
    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    local _farEnough = true

    for _, _name in pairs(ctld.logisticUnits) do
        local _logistic = StaticObject.getByName(_name)

        if _logistic ~= nil and _logistic:getCoalition() == _heli:getCoalition() then
            --get distance
            local _dist = ctld.getDistance(_heliPoint, _logistic:getPoint())
            -- env.info("DIST ".._dist)
            if _dist <= ctld.minimumDeployDistance then
                -- env.info("TOO CLOSE ".._dist)
                _farEnough = false
            end
        end
    end

    return _farEnough
end

function ctld.refreshSmoke()
    if ctld.disableAllSmoke == true then
        return
    end

    for _, _zoneGroup in pairs({ ctld.pickupZones, ctld.dropOffZones }) do
        for _, _zoneDetails in pairs(_zoneGroup) do
            local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

            if _triggerZone == nil then
                local _ship = ctld.getTransportUnit(_triggerZone)

                if _ship then
                    local _point = _ship:getPoint()
                    _triggerZone = {}
                    _triggerZone.point = _point
                end
            end


            --only trigger if smoke is on AND zone is active
            if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[4] == 1 then
                -- Trigger smoke markers

                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end

    --waypoint zones
    for _, _zoneDetails in pairs(ctld.wpZones) do
        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --only trigger if smoke is on AND zone is active
        if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[3] == 1 then
            -- Trigger smoke markers

            local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
            local _alt = land.getHeight(_pos2)
            local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

            trigger.action.smoke(_pos3, _zoneDetails[2])
        end
    end


    --refresh in 5 minutes
    timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 300)
end

function ctld.dropSmoke(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil then
        local _colour = ""

        if _args[2] == trigger.smokeColor.Red then
            _colour = "RED"
        elseif _args[2] == trigger.smokeColor.Blue then
            _colour = "BLUE"
        elseif _args[2] == trigger.smokeColor.Green then
            _colour = "GREEN"
        elseif _args[2] == trigger.smokeColor.Orange then
            _colour = "ORANGE"
        end

        local _point = _heli:getPoint()

        local _pos2 = { x = _point.x, y = _point.z }
        local _alt = land.getHeight(_pos2)
        local _pos3 = { x = _point.x, y = _alt, z = _point.z }

        trigger.action.smoke(_pos3, _args[2])

        trigger.action.outTextForCoalition(_heli:getCoalition(),
            ctld.i18n_translate("%1 dropped %2 smoke.", ctld.getPlayerNameOrType(_heli), _colour), 10)
    end
end

function ctld.unitCanCarryVehicles(_unit)
    local _type = string.lower(_unit:getTypeName())

    for _, _name in ipairs(ctld.vehicleTransportEnabled) do
        local _nameLower = string.lower(_name)
        if string.find(_type, _nameLower, 1, true) then
            return true
        end
    end

    return false
end

function ctld.unitDynamicCargoCapable(_unit)
    local cache = {}
    local _type = string.lower(_unit:getTypeName())
    local result = cache[_type]
    if result == nil then
        result = false
        --ctld.logDebug("ctld.unitDynamicCargoCapable(_type=[%s])", ctld.p(_type))
        for _, _name in ipairs(ctld.dynamicCargoUnits) do
            local _nameLower = string.lower(_name)
            if string.find(_type, _nameLower, 1, true) then    --string.match does not work with patterns containing '-' as it is a magic character
                result = true
                break
            end
        end
        cache[_type] = result
    end
    return result
end

function ctld.isJTACUnitType(_type)
    if _type then
        _type = string.lower(_type)
        for _, _name in ipairs(ctld.jtacUnitTypes) do
            local _nameLower = string.lower(_name)
            if string.match(_type, _nameLower) then
                return true
            end
        end
    end
    return false
end

function ctld.updateZoneCounter(_index, _diff)
    if ctld.pickupZones[_index] ~= nil then
        ctld.pickupZones[_index][3] = ctld.pickupZones[_index][3] + _diff

        if ctld.pickupZones[_index][3] < 0 then
            ctld.pickupZones[_index][3] = 0
        end

        if ctld.pickupZones[_index][6] ~= nil then
            trigger.action.setUserFlag(ctld.pickupZones[_index][6], ctld.pickupZones[_index][3])
        end
        --    env.info(ctld.pickupZones[_index][1].." = " ..ctld.pickupZones[_index][3])
    end
end

function ctld.processCallback(_callbackArgs)
    for _, _callback in pairs(ctld.callbacks) do
        local _status, _result = pcall(function()
            _callback(_callbackArgs)
        end)

        if (not _status) then
            env.error(string.format("CTLD Callback Error: %s", _result))
        end
    end
end

-- checks the status of all AI troop carriers and auto loads and unloads troops
-- as long as the troops are on the ground
function ctld.checkAIStatus()
    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 2)


    for _, _unitName in pairs(ctld.transportPilotNames) do
        local status, error = pcall(function()
            local _unit = ctld.getTransportUnit(_unitName)

            -- no player name means AI!
            if _unit ~= nil and _unit:getPlayerName() == nil then
                local _zone = ctld.inPickupZone(_unit)
                --    env.error("Checking.. ".._unit:getName())
                if _zone.inZone == true and not ctld.troopsOnboard(_unit, true) then
                    --     env.error("in zone, loading.. ".._unit:getName())

                    if ctld.allowRandomAiTeamPickups == true then
                        -- Random troop pickup implementation
                        local _team = nil
                        if _unit:getCoalition() == 1 then
                            _team = math.floor((math.random(#ctld.redTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.redTeams[_team]], true })
                        else
                            _team = math.floor((math.random(#ctld.blueTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.blueTeams[_team]], true })
                        end
                    else
                        ctld.loadTroopsFromZone({ _unitName, true, "", true })
                    end
                elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, true) then
                    --         env.error("in dropoff zone, unloading.. ".._unit:getName())
                    ctld.unloadTroops({ _unitName, true })
                end

                if ctld.unitCanCarryVehicles(_unit) then
                    if _zone.inZone == true and not ctld.troopsOnboard(_unit, false) then
                        ctld.loadTroopsFromZone({ _unitName, false, "", true })
                    elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, false) then
                        ctld.unloadTroops({ _unitName, false })
                    end
                end
            end
        end)

        if (not status) then
            env.error(string.format("Error with ai status: %s", error), false)
        end
    end
end

function ctld.getTransportLimit(_unitType)
    if ctld.unitLoadLimits[_unitType] then
        return ctld.unitLoadLimits[_unitType]
    end

    return ctld.numberOfTroops
end

function ctld.getUnitActions(_unitType)
    if ctld.unitActions[_unitType] then
        return ctld.unitActions[_unitType]
    end

    return { crates = true, troops = true }
end

function ctld.getGroupId(_unit)
    local _unitDB = mist.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    end

    -- Check humansByName database for dynamically spawned units
    local _humanDB = mist.DBs.humansByName[_unit:getName()]
    if _humanDB ~= nil and _humanDB.groupId then
        return _humanDB.groupId
    end

    -- Fallback: get group ID directly from the unit's group
    local _group = Unit.getGroup(_unit)
    if _group then
        local _groupName = _group:getName()
        local _groupDB = mist.DBs.groupsByName[_groupName]
        if _groupDB and _groupDB.groupId then
            return _groupDB.groupId
        end
        
        -- Final fallback: try to get from group ID directly
        local _groupId = tonumber(_group:getID())
        if _groupId then
            return _groupId
        end
    end

    return nil
end

--get distance in meters assuming a Flat world
function ctld.getDistance(_point1, _point2)
    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

-----------------[[ END OF utility_functions.lua ]]-----------------
