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
            QBCore.Functions.DeleteVehicle(vehicle)
        end
   end
end

local function doCarDamage(currentVehicle, veh) -- Set the damage degree of the vehicle
	smash = false
	damageOutside = false
	damageOutside2 = false
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end

    if engine > 1000.0 then
        engine = 1000.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 900.0 then
		smash = true
	end

	if body < 800.0 then
		damageOutside = true
	end

	if body < 500.0 then
		damageOutside2 = true
	end

    Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end

-- Events

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
							debugPoly = true
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
						debugPoly = true
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

RegisterNetEvent('MojiaGarages:client:updateHouseKeys', function(keylist) --Update House Keys
	if keylist then
		HouseKeys = keylist
	end
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
						event = 'MojiaMenu:closeMenu',
					}
				}
				for i, v in pairs(result) do
					if v.state == Garages[currentgarage].garastate then
						if v.state == 1 then
							if v.garage == currentgarage then
								if Garages[currentgarage].fullfix then
									v.engine = 1000
									v.body = 1000
									v.fuel = 100
								end
								enginePercent = QBCore.Shared.Round(v.engine / 10, 0)
								bodyPercent = QBCore.Shared.Round(v.body / 10, 0)
								currentFuel = v.fuel
								MenuGaraOptions[#MenuGaraOptions + 1] = {
									header = QBCore.Shared.Vehicles[v.vehicle].name,
									txt = string.format(GetText('vehicle_info'), v.plate, currentFuel .. '%', enginePercent .. '%', bodyPercent .. '%'),
									params = {
										event = 'MojiaGarages:client:TakeOutVehicle',
										args = v
									}
								}
							end
						elseif v.state == 0 then
							if OutsideVehicles ~= nil and next(OutsideVehicles) ~= nil and OutsideVehicles[v.plate] ~= nil and isVehicleExistInRealLife(v.plate) then
							
							else
								if not isVehicleExistInRealLife(v.plate) then
									if Garages[currentgarage].fullfix then
										v.engine = 1000
										v.body = 1000
										v.fuel = 100
									end
									enginePercent = QBCore.Shared.Round(v.engine / 10, 0)
									bodyPercent = QBCore.Shared.Round(v.body / 10, 0)
									currentFuel = v.fuel
									if v.depotprice > 0 then
										vname = string.format(GetText('vehicle_info_and_price'), v.depotprice, v.plate, currentFuel..'%', enginePercent..'%', bodyPercent..'%')
									else
										vname = string.format(GetText('vehicle_info'), v.plate, currentFuel .. '%', enginePercent .. '%', bodyPercent .. '%')
									end
									MenuGaraOptions[#MenuGaraOptions + 1] = {
										header = QBCore.Shared.Vehicles[v.vehicle].name,
										txt = vname,
										params = {
											event = 'MojiaGarages:client:TakeOutVehicle',
											args = v
										}
									}
								end
							end
						else
							if Garages[currentgarage].fullfix then
								v.engine = 1000
								v.body = 1000
								v.fuel = 100
							end
							enginePercent = QBCore.Shared.Round(v.engine / 10, 0)
							bodyPercent = QBCore.Shared.Round(v.body / 10, 0)
							currentFuel = v.fuel
							vname = string.format(GetText('vehicle_info'), v.plate, currentFuel .. '%', enginePercent .. '%', bodyPercent .. '%')
							MenuGaraOptions[#MenuGaraOptions + 1] = {
								header = QBCore.Shared.Vehicles[v.vehicle].name,
								txt = vname,
								params = {
									event = 'MojiaGarages:client:TakeOutVehicle',
									args = v
								}
							}
						end
					end
				end				
				exports['MojiaMenu']:openMenu(MenuGaraOptions)
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
					QBCore.Functions.SetVehicleProperties(veh, properties)
					enginePercent = QBCore.Shared.Round(vehicle.engine / 10, 1)
					bodyPercent = QBCore.Shared.Round(vehicle.body / 10, 1)
					currentFuel = vehicle.fuel
					if vehicle.plate ~= nil then
						OutsideVehicles[vehicle.plate] = veh
						TriggerServerEvent('MojiaGarages:server:UpdateOutsideVehicles', OutsideVehicles)
					end
					SetVehicleNumberPlateText(veh, vehicle.plate)
					SetEntityHeading(veh, Garages[currentgarage].spawnPoint[lastnearspawnpoint].w)
					exports['MojiaFuel']:SetFuel(veh, vehicle.fuel)
					doCarDamage(veh, vehicle)
					SetEntityAsMissionEntity(veh, true, true)
					TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
					QBCore.Functions.Notify(string.format(GetText('take_out_x_out_of_x_garage'), QBCore.Shared.Vehicles[vehicle.vehicle].name, Garages[currentgarage].label), 'success', 4500)
					TriggerEvent('MojiaVehicles:addTempKey', QBCore.Functions.GetPlate(veh))
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
			if exports["MojiaVehicleKey"]:CheckHasKey(curVeh) then
				if curVeh and #(pos - vehpos) < 7.5 then
					QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
						if owned then					
							local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
							local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
							local totalFuel = exports['MojiaFuel']:GetFuel(curVeh)
							local passenger = GetVehicleMaxNumberOfPassengers(curVeh)
							if IsPedInAnyVehicle(ped) then
								CheckPlayers(curVeh)
							else
								QBCore.Functions.DeleteVehicle(curVeh)
							end
							TriggerServerEvent('MojiaGarages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, lastcurrentgarage)
							TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, lastcurrentgarage)
							if plate ~= nil then
								OutsideVehicles[plate] = veh
								TriggerServerEvent('MojiaGarages:server:UpdateOutsideVehicles', OutsideVehicles)
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
				event = 'MojiaMenu:closeMenu',
			}
		}
		for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].vehicle[PlayerData.job.grade.level]) do
			local plate = JobVeh[PlayerData.job.name][currentgarage].plate .. tostring(math.random(1000, 9999))
			vehicleMenu[#vehicleMenu + 1] = {
				header = v.name,
				txt = string.format(GetText('vehicle_info'), plate, '100%', '100%', '100%'),
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
		exports['MojiaMenu']:openMenu(vehicleMenu)
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
        exports['MojiaFuel']:SetFuel(veh, 100.0)
        TriggerEvent('MojiaVehicles:addTempKey', QBCore.Functions.GetPlate(veh))
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
	if exports["MojiaVehicleKey"]:CheckHasKey(curVeh) and curVeh == lastjobveh then
		if IsPedInAnyVehicle(ped) then
			CheckPlayers(curVeh)
		else
			QBCore.Functions.DeleteVehicle(curVeh)
		end
		lastjobveh = nil
	end
end)

CreateThread(function() -- Get nearest spawn point
	while true do
		Wait(1000)
		if inGarageStation and currentgarage ~= nil then
			nearspawnpoint = GetNearSpawnPoint()
		end
	end
end)

-- export

exports('IsInGarage', IsInGarage)
exports('isInJobStation', isInJobStation)
