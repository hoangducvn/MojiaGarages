-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local GarageLocation = {}
local inGarageStation = false
local currentgarage = nil
local nearspawnpoint = nil
local lastjobveh = nil
local OutsideVehicles = {}
local PlayerData = {}
local inJobStation = {}
local hasHouseKey = false
local HouseKeys = {}
local Blips = {}

-- Functions

local function GetVehicleModifications(vehicle) --Get all vehicle information
    local color1, color2               = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local extras = {}
    for i = 0, 20, 1 do
        if (DoesExtraExist(vehicle, i)) then
            if (IsVehicleExtraTurnedOn(vehicle, i)) then
                table.insert(extras, { i, 0 })
            else
                table.insert(extras, { i, 1 })
            end
        end
    end
    local tiresBurst = {}
    for i = 0, 5, 1 do
        if (IsVehicleTyreBurst(vehicle, i, true)) then
            table.insert(tiresBurst, { i, true })
        elseif (IsVehicleTyreBurst(vehicle, i, false)) then
            table.insert(tiresBurst, { i, false })
        end
    end
    local windowsBroken = {}
    for i = 0, 13, 1 do
        if (not IsVehicleWindowIntact(vehicle, i)) then
            table.insert(windowsBroken, i)
        end
    end
	local doorsMissing = {}
	for i = 0, 7, 1 do 
		if IsVehicleDoorDamaged(vehicle, i) then
			table.insert(doorsMissing, i)
		end 
	end
    -- custom colors
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local customPrimaryColor = nil
    if (hasCustomPrimaryColor) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        customPrimaryColor = { r, g, b }
    end
    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
    local customSecondaryColor = nil
    if (hasCustomSecondaryColor) then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        customSecondaryColor = { r, g, b }
    end
    return {
        -- 1 model
        GetEntityModel(vehicle),
        -- 2 lockStatus
        GetVehicleDoorLockStatus(vehicle),
        -- 3 health
        math.floor(GetEntityHealth(vehicle) * 10.0) / 10.0,
        -- 4 bodyHealth
        math.floor(GetVehicleBodyHealth(vehicle) * 10.0) / 10.0,
        -- 5 engineHealth
        math.floor(GetVehicleEngineHealth(vehicle) * 10.0) / 10.0,
        -- 6 petrolTankHealth
        math.floor(GetVehiclePetrolTankHealth(vehicle) * 10.0) / 10.0,
        -- 7 dirtLevel
        math.floor(GetVehicleDirtLevel(vehicle) * 10.0) / 10.0,
        -- 8 fuelLevel
        math.floor(GetVehicleFuelLevel(vehicle) * 10.0) / 10.0,
        -- 9 plateIndex
        GetVehicleNumberPlateTextIndex(vehicle),
        -- 10 primaryColor
        color1,
        -- 11 secondaryColor
        color2,
        -- 12 pearlescentColor
        pearlescentColor,
        -- 13 wheelColor
        wheelColor,
        -- 14 wheelType
        GetVehicleWheelType(vehicle),
        -- 15 customWheelsFront
        GetVehicleModVariation(vehicle, 23);
        -- 16 customWheelsBack
        GetVehicleModVariation(vehicle, 24);
        -- 17 windowTint
        GetVehicleWindowTint(vehicle),
        -- 18 enabledNeon
        {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3),
        },
        -- 19 neonColor
        table.pack(GetVehicleNeonLightsColour(vehicle)),
        -- 20 tireSmokeColor
        table.pack(GetVehicleTyreSmokeColor(vehicle)),
        -- 21 extras
        extras,
        -- 22-32 mods
        GetVehicleMod(vehicle, 0),
        GetVehicleMod(vehicle, 1),
        GetVehicleMod(vehicle, 2),
        GetVehicleMod(vehicle, 3),
        GetVehicleMod(vehicle, 4),
        GetVehicleMod(vehicle, 5),
        GetVehicleMod(vehicle, 6),
        GetVehicleMod(vehicle, 7),
        GetVehicleMod(vehicle, 8),
        GetVehicleMod(vehicle, 9),
        GetVehicleMod(vehicle, 10),
        -- 33-38 mods
        GetVehicleMod(vehicle, 11),
        GetVehicleMod(vehicle, 12),
        GetVehicleMod(vehicle, 13),
        GetVehicleMod(vehicle, 14),
        GetVehicleMod(vehicle, 15),
        GetVehicleMod(vehicle, 16),
        -- 39-41 mods
        IsToggleModOn(vehicle,  18),
        IsToggleModOn(vehicle,  20),
        IsToggleModOn(vehicle,  22),
        -- 42-43 mods
        GetVehicleMod(vehicle, 23),
        GetVehicleMod(vehicle, 24),
        -- 44-66 mods
        GetVehicleMod(vehicle, 25),
        GetVehicleMod(vehicle, 26),
        GetVehicleMod(vehicle, 27),
        GetVehicleMod(vehicle, 28),
        GetVehicleMod(vehicle, 29),
        GetVehicleMod(vehicle, 30),
        GetVehicleMod(vehicle, 31),
        GetVehicleMod(vehicle, 32),
        GetVehicleMod(vehicle, 33),
        GetVehicleMod(vehicle, 34),
        GetVehicleMod(vehicle, 35),
        GetVehicleMod(vehicle, 36),
        GetVehicleMod(vehicle, 37),
        GetVehicleMod(vehicle, 38),
        GetVehicleMod(vehicle, 39),
        GetVehicleMod(vehicle, 40),
        GetVehicleMod(vehicle, 41),
        GetVehicleMod(vehicle, 42),
        GetVehicleMod(vehicle, 43),
        GetVehicleMod(vehicle, 44),
        GetVehicleMod(vehicle, 45),
        GetVehicleMod(vehicle, 46),
        GetVehicleMod(vehicle, 48),
        -- 67 livery
        GetVehicleLivery(vehicle),
        -- 68 missingDoors
        doorsMissing,
        -- 69 bulletproofTires
        not GetVehicleTyresCanBurst(vehicle),
        -- 70 tiresBurst
        tiresBurst,
        -- 71 brokenWindows
        windowsBroken,
        -- 72 xenon lights
        GetVehicleXenonLightsColour(vehicle),
        -- 73 custom primary color
        customPrimaryColor,
        -- 74 custom secondary color
        customSecondaryColor,
        -- 75 interior color
        GetVehicleInteriorColor(vehicle),	
    }
end

local function SetVehicleModifications(vehicle, plate, modifications)-- Apply all modifications to a vehicle entity
    SetVehicleModKit(vehicle, 0)
    -- plate
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleNumberPlateTextIndex(vehicle, modifications[9])
    -- lockStatus
    SetVehicleDoorsLocked(vehicle, modifications[2])
    -- colours
    SetVehicleColours(vehicle, modifications[10], modifications[11])
    if (modifications[73]) then
        SetVehicleCustomPrimaryColour(vehicle, modifications[73][1], modifications[73][2], modifications[73][3])
    end
    if (modifications[74]) then
        SetVehicleCustomSecondaryColour(vehicle, modifications[74][1], modifications[74][2], modifications[74][3])
    end
    if (modifications[75]) then
        SetVehicleInteriorColor(vehicle, modifications[75])
    end
    SetVehicleExtraColours(vehicle, modifications[12], modifications[13])
    SetVehicleTyreSmokeColor(vehicle, modifications[20][1], modifications[20][2], modifications[20][3])
    -- wheels
    SetVehicleWheelType(vehicle, modifications[14])
    -- windows
    SetVehicleWindowTint(vehicle, modifications[17])
    -- neonlight
    SetVehicleNeonLightEnabled(vehicle, 0, modifications[18][1])
    SetVehicleNeonLightEnabled(vehicle, 1, modifications[18][2])
    SetVehicleNeonLightEnabled(vehicle, 2, modifications[18][3])
    SetVehicleNeonLightEnabled(vehicle, 3, modifications[18][4])
    SetVehicleNeonLightsColour(vehicle, modifications[19][1], modifications[19][2], modifications[19][3])
    -- mods
    SetVehicleMod(vehicle,  0, modifications[22], modifications[15])
    SetVehicleMod(vehicle,  1, modifications[23], modifications[15])
    SetVehicleMod(vehicle,  2, modifications[24], modifications[15])
    SetVehicleMod(vehicle,  3, modifications[25], modifications[15])
    SetVehicleMod(vehicle,  4, modifications[26], modifications[15])
    SetVehicleMod(vehicle,  5, modifications[27], modifications[15])
    SetVehicleMod(vehicle,  6, modifications[28], modifications[15])
    SetVehicleMod(vehicle,  7, modifications[29], modifications[15])
    SetVehicleMod(vehicle,  8, modifications[30], modifications[15])
    SetVehicleMod(vehicle,  9, modifications[31], modifications[15])
    SetVehicleMod(vehicle, 10, modifications[32], modifications[15])
    SetVehicleMod(vehicle, 11, modifications[33], modifications[15])
    SetVehicleMod(vehicle, 12, modifications[34], modifications[15])
    SetVehicleMod(vehicle, 13, modifications[35], modifications[15])
    SetVehicleMod(vehicle, 14, modifications[36], modifications[15])
    SetVehicleMod(vehicle, 15, modifications[37], modifications[15])
    SetVehicleMod(vehicle, 16, modifications[38], modifications[15])
    ToggleVehicleMod(vehicle, 18, modifications[39])
    ToggleVehicleMod(vehicle, 20, modifications[40])
    ToggleVehicleMod(vehicle, 22, modifications[41])
    SetVehicleMod(vehicle, 23, modifications[42], modifications[15])
    SetVehicleMod(vehicle, 24, modifications[43], modifications[16])
    SetVehicleMod(vehicle, 25, modifications[44], modifications[15])
    SetVehicleMod(vehicle, 26, modifications[45], modifications[15])
    SetVehicleMod(vehicle, 27, modifications[46], modifications[15])
    SetVehicleMod(vehicle, 28, modifications[47], modifications[15])
    SetVehicleMod(vehicle, 29, modifications[48], modifications[15])
    SetVehicleMod(vehicle, 30, modifications[49], modifications[15])
    SetVehicleMod(vehicle, 31, modifications[50], modifications[15])
    SetVehicleMod(vehicle, 32, modifications[51], modifications[15])
    SetVehicleMod(vehicle, 33, modifications[52], modifications[15])
    SetVehicleMod(vehicle, 34, modifications[53], modifications[15])
    SetVehicleMod(vehicle, 35, modifications[54], modifications[15])
    SetVehicleMod(vehicle, 36, modifications[55], modifications[15])
    SetVehicleMod(vehicle, 37, modifications[56], modifications[15])
    SetVehicleMod(vehicle, 38, modifications[57], modifications[15])
    SetVehicleMod(vehicle, 39, modifications[58], modifications[15])
    SetVehicleMod(vehicle, 40, modifications[59], modifications[15])
    SetVehicleMod(vehicle, 41, modifications[60], modifications[15])
    SetVehicleMod(vehicle, 42, modifications[61], modifications[15])
    SetVehicleMod(vehicle, 43, modifications[62], modifications[15])
    SetVehicleMod(vehicle, 44, modifications[63], modifications[15])
    SetVehicleMod(vehicle, 45, modifications[64], modifications[15])
    SetVehicleMod(vehicle, 46, modifications[65], modifications[15])
    SetVehicleMod(vehicle, 48, modifications[66], modifications[15])
    SetVehicleLivery(vehicle, modifications[67])
    -- extras
    for i = 1, #modifications[21], 1 do
        SetVehicleExtra(vehicle, modifications[21][i][1], modifications[21][i][2])
    end
    -- stats
    SetEntityHealth(vehicle, modifications[3])
    SetVehicleBodyHealth(vehicle, modifications[4])
    SetVehicleEngineHealth(vehicle, modifications[5])
    SetVehiclePetrolTankHealth(vehicle, modifications[6])
    if (renderScorched and (modifications[5] < -3999.0 or modifications[6] < -999.0)) then
        TriggerServerEvent('AdvancedParking:renderScorched', NetworkGetNetworkIdFromEntity(vehicle), true)
    end
    SetVehicleDirtLevel(vehicle, modifications[7])
    SetVehicleFuelLevel(vehicle, modifications[8])
    -- doors
    for i = 1, #modifications[68], 1 do
        SetVehicleDoorBroken(vehicle, modifications[68][i], true)
    end
    -- tires
    SetVehicleTyresCanBurst(vehicle, not modifications[69])
    if (not modifications[69]) then
        for i = 1, #modifications[70], 1 do
            SetVehicleTyreBurst(vehicle, modifications[70][i][1], modifications[70][i][2], 1000.0)
        end
    end
    -- windows
    for i = 1, #modifications[71], 1 do
        SmashVehicleWindow(vehicle, modifications[71][i])
    end
    -- xenon lights
	if (modifications[72]) then
		SetVehicleXenonLightsColour(vehicle, modifications[72])
	end
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

local function CreateBlip() -- Create Garages blip
	if Garages then
		for k, v in pairs(Garages) do
			if v.showBlip then
				if v.job ~= nil then
					if PlayerData.job and PlayerData.job.name == v.job or PlayerData.gang and PlayerData.gang.name == v.job then
						if not DoesBlipExist(Blips[k]) then
							Blips[k] = AddBlipForCoord(v.blippoint)
							SetBlipSprite(Blips[k], v.blipsprite)
							SetBlipDisplay(Blips[k], 4)
							SetBlipScale(Blips[k], v.blipscale)
							SetBlipAsShortRange(Blips[k], true)
							SetBlipColour(Blips[k], v.blipcolour)
							SetBlipAlpha(Blips[k], 0.7)
							BeginTextCommandSetBlipName('STRING')
							if CustomFont ~= nil then
								AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
							else
								AddTextComponentString(v.label)
							end							
							EndTextCommandSetBlipName(Blips[k])
						end
					else
						if DoesBlipExist(Blips[k]) then
							RemoveBlip(Blips[k])
						end
					end
				else
					if v.isHouseGarage then
						if HouseKeys[k] then
							if not DoesBlipExist(Blips[k]) then
								Blips[k] = AddBlipForCoord(v.blippoint)
								SetBlipSprite(Blips[k], v.blipsprite)
								SetBlipDisplay(Blips[k], 4)
								SetBlipScale(Blips[k], v.blipscale)
								SetBlipAsShortRange(Blips[k], true)
								SetBlipColour(Blips[k], v.blipcolour)
								SetBlipAlpha(Blips[k], 0.7)
								BeginTextCommandSetBlipName('STRING')
								if CustomFont ~= nil then
									AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
								else
									AddTextComponentString(v.label)
								end	
								EndTextCommandSetBlipName(Blips[k])
							end
						else
							if DoesBlipExist(Blips[k]) then
								RemoveBlip(Blips[k])
							end
						end
					else
						if not DoesBlipExist(Blips[k]) then
							Blips[k] = AddBlipForCoord(v.blippoint)
							SetBlipSprite(Blips[k], v.blipsprite)
							SetBlipDisplay(Blips[k], 4)
							SetBlipScale(Blips[k], v.blipscale)
							SetBlipAsShortRange(Blips[k], true)
							SetBlipColour(Blips[k], v.blipcolour)
							SetBlipAlpha(Blips[k], 0.7)
							BeginTextCommandSetBlipName('STRING')
							if CustomFont ~= nil then
								AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
							else
								AddTextComponentString(v.label)
							end	
							EndTextCommandSetBlipName(Blips[k])
						end
					end
				end
			else
				if DoesBlipExist(Blips[k]) then
					RemoveBlip(Blips[k])
				end
			end
		end
	end
end

local function IsInGarage() -- Check if the player is in the garage area and if the garage is open for parking
	local checkIsingarage, checkCanStoreVehicle = false, false
	if inGarageStation and currentgarage ~= nil then
		checkIsingarage = true
		checkCanStoreVehicle = Garages[currentgarage].canStoreVehicle
	end
	return checkIsingarage, checkCanStoreVehicle
end

local function isInJobStation(job) -- Check player is in job gagage location or not
	return inJobStation[job], lastjobveh
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}
	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end
	for k, entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities+1] = isPlayerEntities and k or entity
		end
	end
	return nearbyEntities
end

local function GetVehiclesInArea(coords, maxDistance) -- Vehicle inspection in designated area
	return EnumerateEntitiesWithinDistance(QBCore.Functions.GetVehicles(), false, coords, maxDistance) 
end

local function IsSpawnPointClear(coords, maxDistance) -- Check the spawn point to see if it's empty or not:
	return #GetVehiclesInArea(coords, maxDistance) == 0 
end

local function GetNearSpawnPoint() -- Get nearest spawn point
	local near = nil
	local distance = 10000
	if inGarageStation and currentgarage ~= nil then
		for k, v in pairs(Garages[currentgarage].spawnPoint) do
			if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
				local ped = PlayerPedId()
				local pos = GetEntityCoords(ped)
				local cur_distance = #(pos - vector3(v.x, v.y, v.z))
				if cur_distance < distance then
					distance = cur_distance
					near = k
				end
			end
		end
	end
	return near
end

local function GetNearJobSpawnPoint() -- Get nearest spawn point for job garage
	local near = nil
	local distance = 10000
	PlayerData = QBCore.Functions.GetPlayerData()
	if inGarageStation and inJobStation[PlayerData.job.name] then
		for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].spawnPoint) do
			if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
				local ped = PlayerPedId()
				local pos = GetEntityCoords(ped)
				local cur_distance = #(pos - vector3(v.x, v.y, v.z))
				if cur_distance < distance then
					distance = cur_distance
					near = k
				end
			end
		end
	end
	return near
end

local function SetJobVehItems(job) -- Set trunk item for job vehicle
	local items = {}
	for k, item in pairs(VehJobItems[job]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo['name'],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo['label'],
			description = itemInfo['description'] and itemInfo['description'] or '',
			weight = itemInfo['weight'],
			type = itemInfo['type'],
			unique = itemInfo['unique'],
			useable = itemInfo['useable'],
			image = itemInfo['image'],
			slot = item.slot,
		}
	end
	VehJobItems[job] = items
end

local function Deleteveh(plate) -- Delete the vehicle if it is somewhere outside
	local gameVehicles = QBCore.Functions.GetVehicles()
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == plate then
				QBCore.Functions.DeleteVehicle(vehicle)
            end
        end
    end
end

local function isVehicleExistInRealLife(plate)
	local gameVehicles = QBCore.Functions.GetVehicles()
	local check = false
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == plate then
				check = true
            end
        end
    end
	return check
end

local function CheckPlayers(vehicle) -- Check if there is someone in the car, if so, get that person out of the car
    for i = -1, 5,1 do                
        seat = GetPedInVehicleSeat(vehicle,i)
        if seat ~= 0 then
            TaskLeaveVehicle(seat,vehicle,0)
            SetVehicleDoorsLocked(vehicle)			
            Wait(3000)
			TriggerEvent('MojiaGarages:client:updateVehicle', vehicle)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
   end
end

function GetAllVehicles() -- Returns all loaded vehicles on client side
    return QBCore.Functions.GetVehicles()
end

-- Events
RegisterNetEvent('MojiaGarages:client:setVehicleMods', function(netId, plate, modifications)
	local timer = GetGameTimer()
	while (not NetworkDoesEntityExistWithNetworkId(netId)) do
		Wait(0)
		if (GetGameTimer() - 10000 > timer) then
			TriggerServerEvent('MojiaGarages:server:setVehicleModsFailed', plate)
			return
		end
	end
	local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle)) then
        SetVehicleModifications(vehicle, plate, modifications)
		TriggerServerEvent('MojiaGarages:server:setVehicleModsSuccess', plate)
	else
		TriggerServerEvent('MojiaGarages:server:setVehicleModsFailed', plate)
    end
end)

RegisterNetEvent('MojiaGarages:client:updateVehicle', function(vehicle)
	if (vehicle == nil) then
		return
	end
	if DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle) then
		local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		local modifications = GetVehicleModifications(vehicle)
		TriggerServerEvent('MojiaGarages:server:updateVehicle', networkId, modifications)
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() -- Event when player has successfully loaded
    TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() -- Event when the player has left --Reset all variables
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	GarageLocation = {} 
	inGarageStation = false
	currentgarage = nil
	nearspawnpoint = nil
	lastjobveh = nil
	OutsideVehicles = {}
	PlayerData = {}
	inJobStation = {}
	hasHouseKey = false
	HouseKeys = {}
	Blips = {}
end)

AddEventHandler('onResourceStart', function(resource) -- Event when resource is reloaded
    if resource == GetCurrentResourceName() then -- Reload player information
        TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
		Wait(100)
		PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
		Wait(100)
		TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
		Wait(100)
		TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
		Wait(100)
		CreateBlip() --Reload blips
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) --Events when players change jobs
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo) -- Reload player information
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('MojiaGarages:client:UpdateGaragesZone', function(garageConfig) -- Update Garages Zone
	if garageConfig then		
		Garages = garageConfig
		for k, v in pairs(Garages) do
			if Garages[k].job ~= nil then
				if PlayerData.job and PlayerData.job.name == Garages[k].job or PlayerData.gang and PlayerData.gang.name == Garages[k].job then
					GarageLocation[k] = PolyZone:Create(v.zones, {
						name='GarageStation '..k,
						minZ = 	v.minz,
						maxZ = v.maxz,
						debugPoly = false
					})
					GarageLocation[k]:onPlayerInOut(function(isPointInside)
						if isPointInside then
							inGarageStation = true
							currentgarage = k
							if PlayerData.job and not inJobStation[PlayerData.job.name] and k ~= 'impound' then
								inJobStation[PlayerData.job.name] = true
							end
						else
							inGarageStation = false
							currentgarage = nil
							if PlayerData.job and inJobStation[PlayerData.job.name] then
								inJobStation[PlayerData.job.name] = false
							end
						end
					end)
				end
			else
				if Garages[k].isHouseGarage then
					if HouseKeys[k] then
						GarageLocation[k] = PolyZone:Create(v.zones, {
							name='GarageStation '..k,
							minZ = 	v.minz,
							maxZ = v.maxz,
							debugPoly = false
						})
						GarageLocation[k]:onPlayerInOut(function(isPointInside)
							if isPointInside then
								inGarageStation = true
								currentgarage = k
								if PlayerData.job and inJobStation[PlayerData.job.name] then
									inJobStation[PlayerData.job.name] = false
								end
							else
								inGarageStation = false
								currentgarage = nil
								if PlayerData.job and inJobStation[PlayerData.job.name] then
									inJobStation[PlayerData.job.name] = false
								end
							end
						end)
					end
				else
					GarageLocation[k] = PolyZone:Create(v.zones, {
						name='GarageStation '..k,
						minZ = 	v.minz,
						maxZ = v.maxz,
						debugPoly = false
					})
					GarageLocation[k]:onPlayerInOut(function(isPointInside)
						if isPointInside then
							inGarageStation = true
							currentgarage = k
							if PlayerData.job and inJobStation[PlayerData.job.name] then
								inJobStation[PlayerData.job.name] = false
							end
						else
							inGarageStation = false
							currentgarage = nil
							if PlayerData.job and inJobStation[PlayerData.job.name] then
								inJobStation[PlayerData.job.name] = false
							end
						end
					end)
				end
			end
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:DestroyingZone', function() -- Destroying all zone
    if GarageLocation then
		for k, v in pairs(GarageLocation) do
			GarageLocation[k]:destroy()
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:updateGarage', function() -- Update Garages
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('MojiaGarages:client:updateHouseKeys', function(keylist) --Update House Keys
	if keylist then
		HouseKeys = keylist
	end
end)

RegisterNetEvent('MojiaGarages:client:trackVehicle', function(plate) -- Track Vehicle
    QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleLocation', function(location)
		if location then
			if location.state == 1 then
				SetNewWaypoint(Garages[location.garage].blippoint.x, Garages[location.garage].blippoint.y)
				QBCore.Functions.Notify(GetText('your_vehicle_has_been_marked'), 'success')
			elseif location.state == 0 then
				if location.depotprice == 0 then
					SetNewWaypoint(location.posX, location.posY)
					QBCore.Functions.Notify(GetText('your_vehicle_has_been_marked'), 'success')
				else
					SetNewWaypoint(Garages['depot'].blippoint.x, Garages['depot'].blippoint.y)
					QBCore.Functions.Notify(GetText('your_vehicle_has_been_marked'), 'success')
				end
			else
				SetNewWaypoint(Garages['impound'].blippoint.x, Garages['impound'].blippoint.y)
				QBCore.Functions.Notify(GetText('your_vehicle_has_been_marked'), 'success')
			end
		end
	end, plate)
end)

RegisterNetEvent('MojiaGarages:client:openGarage', function() -- Garages Menu
    if inGarageStation and currentgarage ~= nil then
		QBCore.Functions.TriggerCallback('MojiaGarages:server:GetUserVehicles', function(result)
			if result then
				local MenuGaraOptions = {
					{
						header = string.format(GetText('garage_menu_header'), Garages[currentgarage].label),
						isMenuHeader = true
					},
				}
				MenuGaraOptions[#MenuGaraOptions + 1] = {
					header = GetText('close_menu'),
					txt = '',
					params = {
						event = 'qb-menu:closeMenu',
					}
				}
				for i, v in pairs(result) do
					if v.state == Garages[currentgarage].garastate then
						if v.state == 1 then
							if v.garage == currentgarage then
								local modifications = json.decode(v.modifications)
								bodyPercent = QBCore.Shared.Round(modifications[4] / 10, 0)
								enginePercent = QBCore.Shared.Round(modifications[5] / 10, 0)								
								petrolTankPercent = QBCore.Shared.Round(modifications[6] / 10, 0)
								dirtPercent = QBCore.Shared.Round(modifications[7] / 10, 0)
								currentFuel = QBCore.Shared.Round(modifications[8], 0)
								if Garages[currentgarage].fullfix then
									modifications[4] = 1000
									modifications[5] = 1000
									modifications[6] = 1000
									modifications[7] = 0
									modifications[8] = 100
									v.modifications = json.encode(modifications)
								end
								MenuGaraOptions[#MenuGaraOptions + 1] = {
									header = QBCore.Shared.Vehicles[v.vehicle].name,
									txt = string.format(GetText('vehicle_info'), v.plate, currentFuel .. '%', enginePercent .. '%', bodyPercent .. '%', petrolTankPercent .. '%', dirtPercent .. '%'),
									params = {
										event = 'MojiaGarages:client:TakeOutVehicle',
										args = v
									}
								}
							end
						elseif v.state == 0 then
							if v.depotprice > 0 then
								if OutsideVehicles ~= nil and next(OutsideVehicles) ~= nil and OutsideVehicles[v.plate] ~= nil and isVehicleExistInRealLife(v.plate) then
								
								else
									if not isVehicleExistInRealLife(v.plate) then
										local modifications = json.decode(v.modifications)
										bodyPercent = QBCore.Shared.Round(modifications[4] / 10, 0)
										enginePercent = QBCore.Shared.Round(modifications[5] / 10, 0)								
										petrolTankPercent = QBCore.Shared.Round(modifications[6] / 10, 0)
										dirtPercent = QBCore.Shared.Round(modifications[7] / 10, 0)
										currentFuel = QBCore.Shared.Round(modifications[8], 0)
										if Garages[currentgarage].fullfix then
											modifications[4] = 1000
											modifications[5] = 1000
											modifications[6] = 1000
											modifications[7] = 0
											modifications[8] = 100
											v.modifications = json.encode(modifications)
										end
										MenuGaraOptions[#MenuGaraOptions + 1] = {
											header = QBCore.Shared.Vehicles[v.vehicle].name,
											txt = string.format(GetText('vehicle_info_and_price'), v.depotprice, v.plate, currentFuel..'%', enginePercent..'%', bodyPercent..'%', petrolTankPercent .. '%', dirtPercent .. '%'),
											params = {
												event = 'MojiaGarages:client:TakeOutVehicle',
												args = v
											}
										}
									end
								end
							end
						else
							local modifications = json.decode(v.modifications)
							bodyPercent = QBCore.Shared.Round(modifications[4] / 10, 0)
							enginePercent = QBCore.Shared.Round(modifications[5] / 10, 0)								
							petrolTankPercent = QBCore.Shared.Round(modifications[6] / 10, 0)
							dirtPercent = QBCore.Shared.Round(modifications[7] / 10, 0)
							currentFuel = QBCore.Shared.Round(modifications[8], 0)
							if Garages[currentgarage].fullfix then
								modifications[4] = 1000
								modifications[5] = 1000
								modifications[6] = 1000
								modifications[7] = 0
								modifications[8] = 100
								v.modifications = json.encode(modifications)
							end
							MenuGaraOptions[#MenuGaraOptions + 1] = {
								header = QBCore.Shared.Vehicles[v.vehicle].name,
								txt = string.format(GetText('vehicle_info'), v.plate, currentFuel .. '%', enginePercent .. '%', bodyPercent .. '%', petrolTankPercent .. '%', dirtPercent .. '%'),
								params = {
									event = 'MojiaGarages:client:TakeOutVehicle',
									args = v
								}
							}
						end
					end
				end				
				exports['qb-menu']:openMenu(MenuGaraOptions)
			else
				QBCore.Functions.Notify(GetText('there_are_no_vehicles_in_the_garage'), 'error', 5000)
			end
		end)
	end
end)

RegisterNetEvent('MojiaGarages:client:TakeOutVehicle', function(vehicle) -- Option to take the vehicle out
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		if vehicle.state == 0 and vehicle.depotprice > 0 then
			TriggerServerEvent('MojiaGarages:server:PayDepotPrice', vehicle)
			Wait(1000)
		else
			TriggerEvent('MojiaGarages:client:doTakeOutVehicle', vehicle)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:doTakeOutVehicle', function(vehicle) -- Take the vehicle out
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		local lastnearspawnpoint = nearspawnpoint		
		if not IsSpawnPointClear(vector3(Garages[currentgarage].spawnPoint[lastnearspawnpoint].x, Garages[currentgarage].spawnPoint[lastnearspawnpoint].y, Garages[currentgarage].spawnPoint[lastnearspawnpoint].z), 2.5) then
			QBCore.Functions.Notify(GetText('the_receiving_area_is_obstructed_by_something'), 'error', 2500)
			return
		else
			Deleteveh(vehicle.plate)
			QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
				QBCore.Functions.TriggerCallback('MojiaGarages:server:GetVehicleProperties', function(properties)
					SetVehicleModifications(veh, vehicle.plate, properties)
					if vehicle.plate ~= nil then
						OutsideVehicles[vehicle.plate] = veh
					end
					SetEntityHeading(veh, Garages[currentgarage].spawnPoint[lastnearspawnpoint].w)
					TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
					QBCore.Functions.Notify(string.format(GetText('take_out_x_out_of_x_garage'), QBCore.Shared.Vehicles[vehicle.vehicle].name, Garages[currentgarage].label), 'success', 4500)
					TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
				end, vehicle.plate)
			end, Garages[currentgarage].spawnPoint[lastnearspawnpoint], true)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:storeVehicle', function() -- Store Vehicle
    if inGarageStation and currentgarage ~= nil then
		local lastcurrentgarage = currentgarage
		if Garages[lastcurrentgarage].garastate == 1 then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local curVeh = QBCore.Functions.GetClosestVehicle(pos)
			if IsPedInAnyVehicle(ped) then
				curVeh = GetVehiclePedIsIn(ped)
			end
			local plate = QBCore.Functions.GetPlate(curVeh)
			local vehpos = GetEntityCoords(curVeh)
			if exports['qb-vehiclekeys']:HasVehicleKey(plate) then
				if curVeh and #(pos - vehpos) < 7.5 then
					QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
						if owned then
							
							if IsPedInAnyVehicle(ped) then
								CheckPlayers(curVeh)
							else
								TriggerEvent('MojiaGarages:client:updateVehicle', curVeh)
								QBCore.Functions.DeleteVehicle(curVeh)
							end
							TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, lastcurrentgarage)
							TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
							if plate ~= nil then
								OutsideVehicles[plate] = nil
							end
							QBCore.Functions.Notify(string.format(GetText('vehicle_parked_in_x'), Garages[lastcurrentgarage].label), 'success', 4500)
						else
							QBCore.Functions.Notify(GetText('nobody_owns_this_vehicle'), 'error', 3500)
						end
					end, plate)
				end
			end
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:openJobVehList', function() --Job Vehicles Menu
	PlayerData = QBCore.Functions.GetPlayerData()
	if lastjobveh ~= nil then
		QBCore.Functions.Notify(GetText('you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one'), 'error', 3500)
	else
		local vehicleMenu = {
			{
				header = string.format(GetText('job_vehicle_menu_header'), PlayerData.job.grade.name),
				isMenuHeader = true
			}
		}
		vehicleMenu[#vehicleMenu + 1] = {
			header = GetText('close_menu'),
			txt = '',
			params = {
				event = 'qb-menu:closeMenu',
			}
		}
		for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].vehicle[PlayerData.job.grade.level]) do
			local plate = JobVeh[PlayerData.job.name][currentgarage].plate .. tostring(math.random(1000, 9999))
			vehicleMenu[#vehicleMenu + 1] = {
				header = v.name,
				txt = string.format(GetText('vehicle_info'), plate, '100%', '100%', '100%', '100%', '0%'),
				params = {
					event = 'MojiaGarages:client:SpawnJobVeh',
					args = {
						model = k,
						plate = plate,
						livery = v.livery,
						modType = v.modType,
						modIndex = v.modIndex,
					}
				}
			}
		end		
		exports['qb-menu']:openMenu(vehicleMenu)
	end
end)

RegisterNetEvent('MojiaGarages:client:SpawnJobVeh', function(data) -- Take vehicle for job
	local pos = nil
	local header = nil
	local lastnearspawnpoint = nearspawnpoint
	local lastnearjobspawnpoint = GetNearJobSpawnPoint()
	if JobVeh[PlayerData.job.name][currentgarage].useJobspawnPoint then
		pos = JobVeh[PlayerData.job.name][currentgarage].spawnPoint[lastnearjobspawnpoint]
		header = JobVeh[PlayerData.job.name][currentgarage].spawnPoint[lastnearjobspawnpoint].w
	else
		pos = Garages[currentgarage].spawnPoint[lastnearspawnpoint]
		header = Garages[currentgarage].spawnPoint[lastnearspawnpoint].w
	end
	QBCore.Functions.SpawnVehicle(data.model, function(veh)
        SetJobVehItems(PlayerData.job.name)
		if data.livery ~= nil then
			SetVehicleLivery(veh, data.livery)
		end
		if data.modType ~= nil and data.modIndex ~= nil then
			SetVehicleMod(veh, data.modType, data.modIndex)
		end
		SetVehicleNumberPlateText(veh, data.plate)
        SetEntityHeading(veh, header)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
		TriggerServerEvent('inventory:server:addTrunkItems', QBCore.Functions.GetPlate(veh), VehJobItems[PlayerData.job.name])
		lastjobveh = veh
    end, pos, true)
end)

RegisterNetEvent('MojiaGarages:client:HideJobVeh', function() -- Hide vehicle for job
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local curVeh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
		curVeh = GetVehiclePedIsIn(ped)
	end
	local plate = QBCore.Functions.GetPlate(curVeh)
	if exports['qb-vehiclekeys']:HasVehicleKey(plate) and curVeh == lastjobveh then
		if IsPedInAnyVehicle(ped) then
			CheckPlayers(curVeh)
		else
			QBCore.Functions.DeleteVehicle(curVeh)
		end
		lastjobveh = nil
	end
end)

RegisterNetEvent('MojiaGarages:client:updateVehicleKey', function(plate) -- Update vehicle key for qb-vehiclekey
	QBCore.Functions.TriggerCallback('MojiaGarages:server:GetOwner', function(owner)
		if owner ~= nil then
			TriggerServerEvent('MojiaGarages:server:updateOutSiteVehicleKeys', plate, owner)
		end
	end, plate)
end)

-- Thread

CreateThread(function() -- Get nearest spawn point
	while true do
		Wait(1000)
		if inGarageStation and currentgarage ~= nil then
			nearspawnpoint = GetNearSpawnPoint()
		end
	end
end)

CreateThread(function() --Save vehicle data on real times
	while (true) do
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)
		local curVeh = QBCore.Functions.GetClosestVehicle(pos)
		if IsPedInAnyVehicle(ped) then
			curVeh = GetVehiclePedIsIn(ped)
		end
		local plate = QBCore.Functions.GetPlate(curVeh)
		local vehpos = GetEntityCoords(curVeh)
		local vehRot = GetEntityRotation(curVeh)
		local newLockStatus = GetVehicleDoorLockStatus(curVeh)
		local newBodyHealth  = math.floor(GetVehicleBodyHealth(curVeh) * 10.0) * 0.1
		local newEngineHealth = math.floor(GetVehicleEngineHealth(curVeh) * 10.0) * 0.1
		local newTankHealth = math.floor(GetVehiclePetrolTankHealth(curVeh) * 10.0) * 0.1
		if NetworkGetEntityIsNetworked(curVeh) and DoesEntityExist(curVeh) then
			QBCore.Functions.TriggerCallback('MojiaGarages:server:checkHasVehicleOwner', function(hasowned)
				if hasowned then					
					QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleData', function(VehicleData)
						if VehicleData then					
							local modifications = json.decode(VehicleData.modifications)
							if (#(vector3(VehicleData.posX, VehicleData.posY, VehicleData.posZ) - vehpos) > 1.0 
								or GetRotationDifference(vector3(VehicleData.rotX, VehicleData.rotY, VehicleData.rotZ), vehRot) > 15.0
								or newLockStatus ~= modifications[2]
								or math.abs(newBodyHealth - modifications[4]) > 5.0
								or math.abs(newEngineHealth - modifications[5]) > 5.0
								or math.abs(newTankHealth - modifications[6]) > 5.0
							) then
								TriggerEvent('MojiaGarages:client:updateVehicle', curVeh)
							end
						end
					end, plate)
				end
			end, plate)
		end
		Wait(3000)
	end
end)

CreateThread(function() -- sync player position
	while (true) do
		local playerPed = PlayerPedId()
		if (DoesEntityExist(playerPed)) then
			TriggerServerEvent('MojiaGarages:server:syncPlayerPosition', GetEntityCoords(playerPed))
		end
		Wait(3000)
	end
end)

-- export

exports('IsInGarage', IsInGarage)
exports('isInJobStation', isInJobStation)
