-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local housesLoaded = false
local AllGarages = {}
local vehiclesLoaded = false
-- Functions

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

--Call back

QBCore.Functions.CreateCallback('MojiaGarages:server:getAllVehicle', function(source, cb) -- Get All Vehicles:
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles',{}, function(result)
		if result then
			cb(result)
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:checkHasVehicleOwner', function(source, cb, plate) -- Check Has Vehicle Owner:
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',
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
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',
		{
			plate
		}, function(result)
		if result[1] then
			 cb(result[1])
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:checkVehicleOwner', function(source, cb, plate) -- Check Vehicle Owner:
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
		{
			plate,
			Player.PlayerData.citizenid
		}, function(result)
		if result[1] then
			 cb(true, result[1].balance)
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback('MojiaGarages:server:GetUserVehicles', function(source, cb) -- Get a list of vehicles in the garage
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?',
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

QBCore.Functions.CreateCallback('MojiaGarages:server:GetimpoundVehicles', function(source, cb) -- Get a list of impounded vehicles
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE state = 2',{}, function(result)
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

RegisterNetEvent('MojiaGarages:server:updateVehicle', function(networkId, plate, modifications)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if (DoesEntityExist(vehicle)) then
        local currentTime = os.time()
        local position = GetEntityCoords(vehicle)
        position = vector3(math.floor(position.x * 100.0) / 100.0, math.floor(position.y * 100.0) / 100.0, math.floor(position.z * 100.0) / 100.0)
        local rotation = GetEntityRotation(vehicle)
        rotation = vector3(math.floor(rotation.x * 100.0) / 100.0, math.floor(rotation.y * 100.0) / 100.0, math.floor(rotation.z * 100.0) / 100.0)
        MySQL.Async.execute('UPDATE player_vehicles SET posX = @posX, posY = @posY, posZ = @posZ, rotX = @rotX, rotY = @rotY, rotZ = @rotZ, mods = @modifications, lastUpdate = @lastUpdate WHERE plate = @plate',{
			['@plate']          = plate,
			['@posX']           = position.x,
			['@posY']           = position.y,
			['@posZ']           = position.z,
			['@rotX']           = rotation.x,
			['@rotY']           = rotation.y,
			['@rotZ']           = rotation.z,
			['@modifications']  = json.encode(modifications),
			['@lastUpdate']     = currentTime
		})
    end
end)

RegisterNetEvent('MojiaGarages:server:UpdateGaragesZone', function() -- Update Garages
    local result = MySQL.Sync.fetchAll('SELECT * FROM houselocations', {})
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
        TriggerClientEvent('MojiaGarages:client:DestroyingZone', -1) -- Destroying all zone
		TriggerClientEvent('MojiaGarages:client:UpdateGaragesZone', -1, AllGarages) -- Reload garage information
	else
        TriggerClientEvent('MojiaGarages:client:DestroyingZone', -1) -- Destroying all zone
		TriggerClientEvent('MojiaGarages:client:UpdateGaragesZone', -1, Garages) -- Reload garage information
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

RegisterNetEvent('MojiaGarages:server:updateVehicleState', function(state, plate, garage) -- Vehicle status update
    MySQL.Async.execute('UPDATE player_vehicles SET state = ?, garage = ?, depotprice = ? WHERE plate = ?',
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
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',
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
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error.you_dont_have_enough_money'), 'error')
            end
        end
    end)
end)

RegisterNetEvent('MojiaGarages:server:updateOutSiteVehicles', function()
    TriggerClientEvent('MojiaGarages:client:updateOutSiteVehicles', -1)
end)

RegisterNetEvent('MojiaGarages:server:removeOutsideVehicles', function(plate) -- Update car is outside
	TriggerClientEvent('MojiaGarages:client:removeOutsideVehicles', -1, plate)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        if AutoRespawn then
            MySQL.Async.execute('UPDATE player_vehicles SET state = 1 WHERE state = 0 AND depotprice = 0', {})
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
			local currentTime = os.time()
			local threshold = 60 * 60 * cleanUpThresholdTime
			-- fetch all database results
			MySQL.Async.fetchAll('SELECT state, depotprice, plate, posX, posY, posZ, rotX, rotY, rotZ, mods, lastUpdate FROM player_vehicles', {}, function(results)
				if results then
					for k, v in pairs(results) do
						if v.lastUpdate < os.difftime(currentTime, threshold) then
							MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE state = @state AND depotprice = @depotprice AND plate = @plate',
								{
									['@state'] = 0,
									['@depotprice'] = 0,
									['@plate'] = plate
								}
							)
						end
					end
				end
			end)		
        end
        Wait(1000)
    end
end)
