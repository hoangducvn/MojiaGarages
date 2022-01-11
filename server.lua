-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local OutsideVehicles = {}
local activePlayerPositions = {}
local housesLoaded = false
local AllGarages = {}
local vehiclesLoaded = false
-- Functions

local function GetClosestPlayerId(position) -- return the ID of the closest player
	local closestDistance = 1000000.0
	local closestPlayerID = nil
    local closestPos = nil
    for playerID, pos in pairs(activePlayerPositions) do
        local distance = #(position - pos)
        if (distance < closestDistance) then
            closestDistance = distance
            closestPlayerID = playerID
            closestPos = pos
        end
	end
    local distance = nil
    if (closestPlayerID ~= nil) then
        distance = #(position - closestPos)
    end
	return closestPlayerID, distance
end

local function ContainsPlate(plate, vehiclePlates)
    for i = 1, #vehiclePlates, 1 do
        if (plate == vehiclePlates[i]) then
            return true
        end
    end
    return false
end

local function GetRotationDifference(r1, r2) -- returns the difference in degrees from the axis with the highest difference
    local x = math.abs(r1.x - r2.x)
    local y = math.abs(r1.y - r2.y)
    local z = math.abs(r1.z - r2.z)

    if (x > y and x > z) then
        return x
    elseif (y > z) then
        return y
    else
        return z
    end
end

local function GetPlayerIdentifiersSorted(playerServerId) -- Return an array with all identifiers - e.g. ids['license'] = license:xxxxxxxxxxxxxxxx
	local ids = {}
	local identifiers = GetPlayerIdentifiers(playerServerId)
	for k, identifier in pairs (identifiers) do
		local i, j = string.find(identifier, ':')
		local idType = string.sub(identifier, 1, i-1)
		ids[idType] = identifier
	end
	return ids
end

local function IsPlayerWithLicenseActive(license) -- returns true if a player is active on the server with the specified license
    for playerId, playerPos in pairs(activePlayerPositions) do
        if (GetPlayerIdentifiersSorted(playerId)['license'] == license) then
            return true
        end
    end

    return false
end

local function TryGetLoadedVehicle(plate, loadedVehicles) -- returns a loaded vehicled with a given number plate
    for i = 1, #loadedVehicles, 1 do
        if (plate == GetVehicleNumberPlateText(loadedVehicles[i]) and DoesEntityExist(loadedVehicles[i])) then
            return loadedVehicles[i]
        end
    end
    return nil
end

local function TrySpawnVehicles() -- checks if vehicles have to be spawned and spawns them if necessary
	local loadedVehicles = GetAllVehicles()
    local playerVehiclePlates = {}
    for id, position in pairs(activePlayerPositions) do
        local ped = GetPlayerPed(id)
        local veh = GetVehiclePedIsIn(ped, false)
        if (DoesEntityExist(veh)) then
            table.insert(playerVehiclePlates, GetVehicleNumberPlateText(veh))
        end
    end
	for plate, vehicleData in pairs(OutsideVehicles) do
		if (not vehicleData.spawning) then
			local closestPlayer, dist = GetClosestPlayerId(vehicleData.position)
			if (closestPlayer ~= nil and dist < spawnDistance and not ContainsPlate(plate, playerVehiclePlates)) then
				if (vehicleData.handle ~= nil and DoesEntityExist(vehicleData.handle)) then -- vehicle found on server side
					TriggerClientEvent('MojiaGarages:client:updateVehicle', vehicleData.handle)
				else -- vehicle not found on server side. Check, if it is loaded differently
					local loadedVehicle = TryGetLoadedVehicle(plate, loadedVehicles)
					if (loadedVehicle ~= nil) then -- vehicle found
                        vehicleData.handle = loadedVehicle                    
                        TriggerClientEvent('MojiaGarages:client:updateVehicle', vehicleData.handle)
                    else -- vehicle not found. Try and spawn it
						local playerId, distance = GetClosestPlayerId(vehicleData.position)
						if (playerId and distance < spawnDistance) then
							vehicleData.spawning = true
							CreateThread(function()
                                local vec4 = vector4(vehicleData.position.x, vehicleData.position.y, vehicleData.position.z, vehicleData.rotation.z)
                                local vehicle = Citizen.InvokeNative(GetHashKey('CREATE_AUTOMOBILE'), vehicleData.modifications.model, vec4.xyzw)
                                while (not DoesEntityExist(vehicle)) do
                                    Wait(0)
                                end
                                SetEntityCoords(vehicle, vehicleData.position.x, vehicleData.position.y, vehicleData.position.z)
                                SetEntityRotation(vehicle, vehicleData.rotation.x, vehicleData.rotation.y, vehicleData.rotation.z)
                                vehicleData.handle = vehicle
                                local networkOwner = -1
                                while (networkOwner == -1) do
                                    Wait(0)
                                    networkOwner = NetworkGetEntityOwner(vehicleData.handle)
                                end
                                vehicleData.spawningPlayer = GetPlayerIdentifiersSorted(networkOwner)
                                TriggerClientEvent('MojiaGarages:client:setVehicleMods', networkOwner, NetworkGetNetworkIdFromEntity(vehicleData.handle), plate, vehicleData.modifications)
                                TriggerClientEvent('MojiaGarages:client:updateVehicleKey', -1, plate) -- Update vehicle key for qb-vehiclekey
                            end)
						end
					end
				end
			end
		elseif (vehicleData.spawningPlayer) then
            if (not IsPlayerWithLicenseActive(vehicleData.spawningPlayer)) then -- if vehicle is currently spawning check if responsible player is still connected
                TriggerEvent('MojiaGarages:server:setVehicleModsFailed', plate)
            end
		end
	end
end

local function GetActivePlayerCount()
	local playerCount = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        playerCount = playerCount + 1
    end
    return playerCount
end

local function CleanUp() -- Default cleaning function. seize vehicles that are outside and just parked in one location without any change over a period of time
    local currentTime = os.time()
    local threshold = 60 * 60 * cleanUpThresholdTime
    local toDelete = {}
    for plate, vehicle in pairs(OutsideVehicles) do
        if vehicle.lastUpdate < os.difftime(currentTime, threshold) then
            exports.oxmysql:execute('UPDATE player_vehicles SET state = 2 WHERE state = @state AND depotprice = @depotprice AND plate = @plate',
				{
					['@state'] = 0,
					['@depotprice'] = 0,
					['@plate'] = plate
				}
			)
            table.insert(toDelete, plate)
        end
    end    
    for i = 1, #toDelete, 1 do
        local plate = toDelete[i]
        OutsideVehicles[plate] = nil
    end
end

--Call back
QBCore.Functions.CreateCallback('MojiaGarages:server:GetOwner', function(source, cb, plate) -- Get vehicle owner for check key qb-vehiclekey
    local owner = nil
    local result = exports.oxmysql:fetchSync('SELECT citizenid FROM player_vehicles WHERE plate = ?',
		{
			plate
		}
	)
    if result[1] ~= nil then
        owner = result[1].citizenid
    end
    cb(owner)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:getVehicleLocation', function(source, cb, plate) -- Check Vehicle locaton:
    local properties = {}
    local result = exports.oxmysql:fetchSync('SELECT garage, state, depotprice, posX, posY FROM player_vehicles WHERE plate = ?',
		{
			plate
		}
	)
    if result[1] ~= nil then
        properties = result[1]
    end
    cb(properties)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:GetVehicleProperties', function(source, cb, plate) -- Get vehicle information
    local src = source
    local properties = {}
    local result = exports.oxmysql:fetchSync('SELECT mods FROM player_vehicles WHERE plate = ?',
		{
			plate
		}
	)
    if result[1] ~= nil then
        properties = json.decode(result[1].mods)
    end
    cb(properties)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:checkHasVehicleOwner', function(source, cb, plate) -- Check Has Vehicle Owner:
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ?',
		{
			plate
		}, function(result)
		if result[1] ~= nil then
			 cb(true, result[1].balance)
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:getVehicleData', function(source, cb, plate) -- Get Vehicle Data:
    local properties = {}
    local result = exports.oxmysql:fetchSync('SELECT state, depotprice, plate, posX, posY, posZ, rotX, rotY, rotZ, mods FROM player_vehicles WHERE plate = ?',
		{
			plate
		}
	)
    if result[1] ~= nil then
        properties = result[1]
    end
    cb(properties)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:checkVehicleOwner', function(source, cb, plate) -- Check Vehicle Owner:
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
		{
			plate,
			Player.PlayerData.citizenid
		}, function(result)
		if result[1] ~= nil then
			 cb(true, result[1].balance)
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:GetUserVehicles', function(source, cb) -- Get a list of vehicles in the garage
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE citizenid = ?',
		{
			Player.PlayerData.citizenid
		}, function(result)
		if result[1] ~= nil then
			cb(result)
		else
			cb(nil)
		end
	end)
end)

--Events
RegisterNetEvent('MojiaGarages:server:renderScorched', function(vehicleNetId, scorched) -- render entity scorched (trigger with netid of the vehicle and false when repairing)
    local vehicleHandle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if (DoesEntityExist(vehicleHandle)) then
        TriggerClientEvent('MojiaGarages:client:renderScorched', -1, vehicleNetId, scorched)
    end
end)

RegisterNetEvent('MojiaGarages:server:updateVehicle', function(networkId, modifications)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if (DoesEntityExist(vehicle)) then
        local currentTime = os.time()
        local plate = GetVehicleNumberPlateText(vehicle)
        local position = GetEntityCoords(vehicle)
        position = vector3(math.floor(position.x * 100.0) / 100.0, math.floor(position.y * 100.0) / 100.0, math.floor(position.z * 100.0) / 100.0)
        local rotation = GetEntityRotation(vehicle)
        rotation = vector3(math.floor(rotation.x * 100.0) / 100.0, math.floor(rotation.y * 100.0) / 100.0, math.floor(rotation.z * 100.0) / 100.0)
        if (OutsideVehicles[plate] ~= nil) then
            -- already on server list
            if (OutsideVehicles[plate].handle ~= vehicle) then
                if (DoesEntityExist(OutsideVehicles[plate].handle)) then
                    DeleteEntity(OutsideVehicles[plate].handle)
                end
                OutsideVehicles[plate].handle = vehicle
            end
            OutsideVehicles[plate].position = position
            OutsideVehicles[plate].rotation = rotation
            OutsideVehicles[plate].modifications = modifications
            OutsideVehicles[plate].lastUpdate = currentTime
            exports.oxmysql:execute('UPDATE player_vehicles SET posX = @posX, posY = @posY, posZ = @posZ, rotX = @rotX, rotY = @rotY, rotZ = @rotZ, mods = @modifications, lastUpdate = @lastUpdate WHERE plate = @plate',{
                ['@plate']          = plate,
                ['@posX']           = OutsideVehicles[plate].position.x,
                ['@posY']           = OutsideVehicles[plate].position.y,
                ['@posZ']           = OutsideVehicles[plate].position.z,
                ['@rotX']           = OutsideVehicles[plate].rotation.x,
                ['@rotY']           = OutsideVehicles[plate].rotation.y,
                ['@rotZ']           = OutsideVehicles[plate].rotation.z,
                ['@modifications']  = json.encode(OutsideVehicles[plate].modifications),
                ['@lastUpdate']     = OutsideVehicles[plate].lastUpdate
            })
        else
            -- insert in db
            OutsideVehicles[plate] = {
                handle          = vehicle,
                position        = position,
                rotation        = rotation,
                modifications   = modifications,
                lastUpdate      = currentTime,
                spawning        = false,
	            spawningPlayer  = nil
            }
            exports.oxmysql:execute('UPDATE player_vehicles SET posX = @posX, posY = @posY, posZ = @posZ, rotX = @rotX, rotY = @rotY, rotZ = @rotZ, mods = @modifications, lastUpdate = @lastUpdate WHERE plate = @plate',{
                ['@plate']          = plate,
                ['@posX']           = OutsideVehicles[plate].position.x,
                ['@posY']           = OutsideVehicles[plate].position.y,
                ['@posZ']           = OutsideVehicles[plate].position.z,
                ['@rotX']           = OutsideVehicles[plate].rotation.x,
                ['@rotY']           = OutsideVehicles[plate].rotation.y,
                ['@rotZ']           = OutsideVehicles[plate].rotation.z,
                ['@modifications']  = json.encode(OutsideVehicles[plate].modifications),
                ['@lastUpdate']     = OutsideVehicles[plate].lastUpdate
            })
        end
    end
end)

RegisterNetEvent('MojiaGarages:server:setVehicleModsSuccess', function(plate)
    if (OutsideVehicles[plate]) then
        OutsideVehicles[plate].spawning = false
        OutsideVehicles[plate].spawningPlayer = nil
    end
end)

RegisterNetEvent('MojiaGarages:server:setVehicleModsFailed', function(plate)
    if (OutsideVehicles[plate] and OutsideVehicles[plate].handle and DoesEntityExist(OutsideVehicles[plate].handle)) then
        local networkOwner = -1
        while (networkOwner == -1) do
            Citizen.Wait(0)
            networkOwner = NetworkGetEntityOwner(OutsideVehicles[plate].handle)
        end
        OutsideVehicles[plate].spawningPlayer = GetPlayerIdentifiersSorted(networkOwner)
        TriggerClientEvent('MojiaGarages:client:setVehicleMods', networkOwner, NetworkGetNetworkIdFromEntity(OutsideVehicles[plate].handle), plate, OutsideVehicles[plate].modifications)
    end
end)

RegisterNetEvent('MojiaGarages:server:syncPlayerPosition', function(position) -- sync player position
	activePlayerPositions[source] = position
end)

-- player disconnected
RegisterNetEvent('playerDropped', function(disconnectReason)
    activePlayerPositions[source] = nil
end)

RegisterNetEvent('MojiaGarages:server:removeOutsideVehicles', function(plate) -- Update car is outside
    OutsideVehicles[plate] = nil
end)

RegisterNetEvent('MojiaGarages:server:UpdateGaragesZone', function() -- Update Garages
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations', {})
    if result[1] then        
		AllGarages = Garages
		for k, v in pairs(result) do
            local garage = json.decode(v.garage) or {} 
			if v.garage ~= nil then
            
				AllGarages[v.name] = {
					label = v.label,
					spawnPoint = {
						vector4(garage.x, garage.y, garage.z, garage.h),
					},
					blippoint = vector3(garage.x, garage.y, garage.z),
					showBlip = true,
					blipsprite = 357,
					blipscale = 0.65,
					blipcolour = 3,
					job = nil, -- [nil: public garage] ['police: police garage'] ...
					fullfix = false, -- [true: full fix when take out vehicle]
					garastate = 1, -- [0: Depot] [1: Garage] [2: Impound]
					isHouseGarage = true,
					canStoreVehicle = true,
					zones = {
						vector2(garage.x1, garage.y1),
						vector2(garage.x2, garage.y2),
						vector2(garage.x3, garage.y3),
						vector2(garage.x4, garage.y4),					
					},
					minz = garage.z - 1,
					maxz = garage.z + 3,
				}
			end
			
        end
		TriggerClientEvent('MojiaGarages:client:UpdateGaragesZone', -1, AllGarages)
	else
		TriggerClientEvent('MojiaGarages:client:UpdateGaragesZone', -1, Garages)
    end
end)

RegisterNetEvent('MojiaGarages:server:updateHouseKeys', function() --Update House Keys
    local HouseKeys = {}
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		local identifier = Player.PlayerData.license
        local cid = Player.PlayerData.citizenid
		if AllGarages then
			for k, v in pairs(AllGarages) do
				if v.isHouseGarage then
					if Player.PlayerData.job.name == 'realestate' then
						HouseKeys[k] = true
					else
						HouseKeys[k] = exports['qb-houses']:hasKey(identifier, cid, k)
					end
				else
					HouseKeys[k] = false
				end
			end
			TriggerClientEvent('MojiaGarages:client:updateHouseKeys', source, HouseKeys)
		end
	end
end)

RegisterNetEvent('MojiaGarages:server:UpdateOutsideVehicles', function(Vehicles) -- Update car is outside
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CitizenId = Player.PlayerData.citizenid
    Vehicles[CitizenId] = Vehicles
end)

RegisterNetEvent('MojiaGarages:server:updateVehicleState', function(state, plate, garage) -- Vehicle status update
    exports.oxmysql:execute('UPDATE player_vehicles SET state = ?, garage = ?, depotprice = ? WHERE plate = ?',
        {
			state,
			garage,
			0,
			plate
		}
	)
end)


RegisterNetEvent('MojiaGarages:server:PayDepotPrice', function(vehicle) -- Payment of vehicle fines
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money['bank']
    local cashBalance = Player.PlayerData.money['cash']
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ?',
		{
			vehicle.plate
		}, function(result)
        if result[1] ~= nil then
            if bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney('bank', result[1].depotprice, 'Paying fines for vehicle in the depot')
                TriggerClientEvent('MojiaGarages:client:doTakeOutVehicle', src, vehicle)
            elseif cashBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney('cash', result[1].depotprice, 'Paying fines for vehicle in the depot')
                TriggerClientEvent('MojiaGarages:client:doTakeOutVehicle', src, vehicle)
            else
                TriggerClientEvent('QBCore:Notify', src, GetText('you_dont_have_enough_money'), 'error')
            end
        end
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        if AutoRespawn then
            exports.oxmysql:execute('UPDATE player_vehicles SET state = 1 WHERE state = 0 AND depotprice = 0', {})
        end
    end
end)

--Thread

CreateThread(function() -- Update houses
    while true do
        if not housesLoaded then
            housesLoaded = true
			TriggerEvent('MojiaGarages:server:updateHouseKeys')
			TriggerEvent('MojiaGarages:server:UpdateGaragesZone')			
        end
        Wait(1000)
    end
end)

CreateThread(function() -- read all vehicles from the database on startup and do a cleanup check
    while true do
        if not vehiclesLoaded then
            vehiclesLoaded = true
			-- fetch all database results
			exports.oxmysql:fetch('SELECT state, depotprice, plate, posX, posY, posZ, rotX, rotY, rotZ, mods, lastUpdate FROM player_vehicles', {}, function(results)
				for i = 1, #results do
					if results[i].state == 0 and results[i].depotprice == 0 then
						OutsideVehicles[results[i].plate] = {
							handle          = nil,
							position        = vector3(results[i].posX, results[i].posY, results[i].posZ),
							rotation        = vector3(results[i].rotX, results[i].rotY, results[i].rotZ),
							modifications   = json.decode(results[i].mods),
							lastUpdate      = results[i].lastUpdate,
							spawning        = false,
							spawningPlayer  = nil
						}
					end
				end
				CleanUp()
			end)		
        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function() -- loop to spawn vehicles near players
    while (true) do
        Citizen.Wait(5000)
        if (GetActivePlayerCount() > 0) then
			TrySpawnVehicles()
        end
    end
end)