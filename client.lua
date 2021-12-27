-----------------------------------------------
--Variables:
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
-----------------------------------------------

-----------------------------------------------
--Create gagages blip:
local function CreateBlip()
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
							AddTextComponentString(v.label)
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
								AddTextComponentString(v.label)
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
							AddTextComponentString(v.label)
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
-----------------------------------------------

-----------------------------------------------
--Event when player has successfully loaded:
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    GarageLocation = {}
	Wait(100)
	--Reload player information:
	PlayerData = QBCore.Functions.GetPlayerData()
	Wait(100)
	--Reload garage information:
	TriggerServerEvent('MojiaGarages:server:garageConfig')
	Wait(100)
	--Reload house key information:
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys')
	Wait(100)
	--Reload blips
	CreateBlip()
end)
-----------------------------------------------

-----------------------------------------------
--Event when the player has left:
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	--Reset all variables:
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
-----------------------------------------------

-----------------------------------------------
--Event when resource is reloaded:
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        GarageLocation = {}
		Wait(100)
		--Reload player information:
		PlayerData = QBCore.Functions.GetPlayerData()
		Wait(100)
		--Reload garage information:
		TriggerServerEvent('MojiaGarages:server:garageConfig')
		Wait(100)
		--Reload house key information:
		TriggerServerEvent('MojiaGarages:server:updateHouseKeys')
		Wait(100)
		--Reload blips
		CreateBlip()
    end
end)
-----------------------------------------------

-----------------------------------------------
--Events when players change jobs:
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
	Wait(100)
	--Reload player information:
	PlayerData = QBCore.Functions.GetPlayerData()
	Wait(100)
	--Reload blips
	CreateBlip()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
	Wait(100)
	--Reload player information:
	PlayerData = QBCore.Functions.GetPlayerData()
	Wait(100)
	--Reload blips
	CreateBlip()
end)
-----------------------------------------------

-----------------------------------------------
--Check if the player is in the garage area and if the garage is open for parking:
local function IsInGarage()
	local checkIsingarage, checkCanStoreVehicle = false, false
	if inGarageStation and currentgarage ~= nil then
		checkIsingarage = true
		checkCanStoreVehicle = Garages[currentgarage].canStoreVehicle
	end
	return checkIsingarage, checkCanStoreVehicle
end
-----------------------------------------------

-----------------------------------------------
--Check player is in job gagage location or not:
local function isInJobStation(job)
	return inJobStation[job], lastjobveh
end
-----------------------------------------------

-----------------------------------------------
--
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
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end
	return nearbyEntities
end
-----------------------------------------------

-----------------------------------------------
--Vehicle inspection in designated area:
local function GetVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(QBCore.Functions.GetVehicles(), false, coords, maxDistance) 
end
-----------------------------------------------

-----------------------------------------------
--Check the spawn point to see if it's empty or not:
local function IsSpawnPointClear(coords, maxDistance) 
	return #GetVehiclesInArea(coords, maxDistance) == 0 
end
-----------------------------------------------

-----------------------------------------------
--Get nearest spawn point:
local function GetNearSpawnPoint()
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
-----------------------------------------------

-----------------------------------------------
--Get nearest spawn point for job garage:
local function GetNearJobSpawnPoint()
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
-----------------------------------------------

-----------------------------------------------
--Set trunk item for job vehicle:
local function SetJobVehItems(job)
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
-----------------------------------------------

-----------------------------------------------
--Delete the vehicle if it is somewhere outside:
local function Deleteveh(plate)
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
-----------------------------------------------

-----------------------------------------------
--Check if there is someone in the car, if so, get that person out of the car:
local function CheckPlayers(vehicle)
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
-----------------------------------------------

-----------------------------------------------
--Set the damage degree of the vehicle:
local function doCarDamage(currentVehicle, veh)
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
-----------------------------------------------

-----------------------------------------------
exports('IsInGarage', IsInGarage)
exports('isInJobStation', isInJobStation)
-----------------------------------------------

-----------------------------------------------
--Update Garages and Poly Box:
RegisterNetEvent('MojiaGarages:client:GarageConfig', function(garageConfig)
	if garageConfig then		
		Garages = garageConfig
		for k, v in pairs(Garages) do
			GarageLocation[k] = PolyZone:Create(v.zones, {
				name='GarageStation '..k,
				minZ = 	v.minz,
				maxZ = v.maxz,
				debugPoly = false
			})
			GarageLocation[k]:onPlayerInOut(function(isPointInside)
				if isPointInside then
					if Garages[k].job ~= nil then
						if PlayerData.job and PlayerData.job.name == Garages[k].job or PlayerData.gang and PlayerData.gang.name == Garages[k].job then
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
					else
						if Garages[k].isHouseGarage then
							if HouseKeys[k] then
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
						else
							inGarageStation = true
							currentgarage = k
							if PlayerData.job and inJobStation[PlayerData.job.name] then
								inJobStation[PlayerData.job.name] = false
							end
						end
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
end)
-----------------------------------------------

-----------------------------------------------
--Update House Keys
RegisterNetEvent('MojiaGarages:client:updateHouseKeys', function(keylist)
	if keylist then
		HouseKeys = keylist
	end
end)
-----------------------------------------------

-----------------------------------------------
--Update Garages:
RegisterNetEvent('MojiaGarages:client:updateGarage', function()
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData()
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:garageConfig')
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys')
	Wait(100)
	CreateBlip()
end)
-----------------------------------------------

-----------------------------------------------
--Get nearest spawn point:
CreateThread(function()
	while true do
		Wait(1000)
		if inGarageStation and currentgarage ~= nil then
			nearspawnpoint = GetNearSpawnPoint()
		end
	end
end)
-----------------------------------------------

-----------------------------------------------
--Garages Menu:
RegisterNetEvent('MojiaGarages:client:openGarage', function()
    if inGarageStation and currentgarage ~= nil then
		QBCore.Functions.TriggerCallback('MojiaGarages:server:GetUserVehicles', function(result)
			if result then
				local MenuGaraOptions = {
					{
						header = '🚘| ' .. Garages[currentgarage].label,
						isMenuHeader = true
					},
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
								table.insert(MenuGaraOptions, {
									header = QBCore.Shared.Vehicles[v.vehicle].name,
									txt = 'Plate: '..v.plate..'<br>Fuel: '..currentFuel..'%<br>Engine: '..enginePercent..'%<br>Body: '..bodyPercent..'%',
									params = {
										event = 'MojiaGarages:client:TakeOutVehicle',
										args = v
									}
								})
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
							
							if v.state == 0 and v.depotprice > 0 then
								vname = 'Price: $'..v.depotprice..'<br>Plate: '..v.plate..'<br>Fuel: '..currentFuel..'%<br>Engine: '..enginePercent..'%<br>Body: '..bodyPercent..'%'
							else
								vname = 'Plate: '..v.plate..'<br>Fuel: '..currentFuel..'%<br>Engine: '..enginePercent..'%<br>Body: '..bodyPercent..'%'
							end
							
							table.insert(MenuGaraOptions, {
								header = QBCore.Shared.Vehicles[v.vehicle].name,
								txt = vname,
								params = {
									event = 'MojiaGarages:client:TakeOutVehicle',
									args = v
								}
							})
						end
					end
				end
				table.insert(MenuGaraOptions, {
					header = '❌| Close',
					txt = '',
					params = {
						event = 'qb-menu:closeMenu',
					}
				})
				exports['qb-menu']:openMenu(MenuGaraOptions)
			else
				QBCore.Functions.Notify('There are no vehicles in the garage', 'error', 5000)
			end
		end)
	end
end)
-----------------------------------------------

-----------------------------------------------
--Option to take the vehicle out:
RegisterNetEvent('MojiaGarages:client:TakeOutVehicle', function(vehicle)
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		if vehicle.state == 0 and vehicle.depotprice > 0 then
			TriggerServerEvent('MojiaGarages:server:PayDepotPrice', vehicle)
			Wait(1000)
		else
			TriggerEvent('MojiaGarages:client:doTakeOutVehicle', vehicle)
		end
	end
end)
-----------------------------------------------

-----------------------------------------------
--Take the vehicle out:
RegisterNetEvent('MojiaGarages:client:doTakeOutVehicle', function(vehicle)
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		local lastnearspawnpoint = nearspawnpoint		
		if not IsSpawnPointClear(vector3(Garages[currentgarage].spawnPoint[lastnearspawnpoint].x, Garages[currentgarage].spawnPoint[lastnearspawnpoint].y, Garages[currentgarage].spawnPoint[lastnearspawnpoint].z), 2.5) then
			QBCore.Functions.Notify('The receiving area is obstructed by something', 'error', 2500)
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
					exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
					doCarDamage(veh, vehicle)
					SetEntityAsMissionEntity(veh, true, true)
					TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
					QBCore.Functions.Notify('Take out ' .. QBCore.Shared.Vehicles[vehicle.vehicle].name .. ' Motor:' .. enginePercent .. '% Body:' .. bodyPercent.. '% Fuel: '..currentFuel.. '%', 'success', 4500)
					TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
				end, vehicle.plate)
			end, Garages[currentgarage].spawnPoint[lastnearspawnpoint], true)
		end
	end
end)
-----------------------------------------------

-----------------------------------------------
--Store Vehicle:
RegisterNetEvent('MojiaGarages:client:storeVehicle', function()
    if inGarageStation and currentgarage ~= nil then
		if Garages[currentgarage].garastate == 1 then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local curVeh = QBCore.Functions.GetClosestVehicle(pos)
			if IsPedInAnyVehicle(ped) then
				curVeh = GetVehiclePedIsIn(ped)
			end
			local plate = QBCore.Functions.GetPlate(curVeh)
			local vehpos = GetEntityCoords(curVeh)
			
			if curVeh and #(pos - vehpos) < 7.5 then
				QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
					if owned then					
						local bodyDamage = math.ceil(GetVehicleBodyHealth(curVeh))
						local engineDamage = math.ceil(GetVehicleEngineHealth(curVeh))
						local totalFuel = exports['LegacyFuel']:GetFuel(curVeh)
						local passenger = GetVehicleMaxNumberOfPassengers(curVeh)
						if IsPedInAnyVehicle(ped) then
							CheckPlayers(curVeh)
						else
							QBCore.Functions.DeleteVehicle(curVeh)
						end
						TriggerServerEvent('MojiaGarages:server:updateVehicleStatus', totalFuel, engineDamage, bodyDamage, plate, currentgarage)
						TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, currentgarage)
						if plate ~= nil then
							OutsideVehicles[plate] = veh
							TriggerServerEvent('MojiaGarages:server:UpdateOutsideVehicles', OutsideVehicles)
						end
						QBCore.Functions.Notify('Vehicle parked in '..Garages[currentgarage].label, 'success', 4500)
					else
						QBCore.Functions.Notify('Nobody owns this vehicle', 'error', 3500)
					end
				end, plate)
			end
		end
	end
end)
-----------------------------------------------

-----------------------------------------------
--Job Vehicles Menu:
RegisterNetEvent('MojiaGarages:client:openJobVehList', function()
	PlayerData = QBCore.Functions.GetPlayerData()
	local vehicleMenu = {
        {
            header = PlayerData.job.grade.name .. '\'s Vehicle List',
            isMenuHeader = true
        }
    }
    for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].vehicle[PlayerData.job.grade.level]) do
        local plate = JobVeh[PlayerData.job.name][currentgarage].plate .. tostring(math.random(1000, 9999))
		table.insert(vehicleMenu, {
			header = v.name,
			txt = 'Plate: ' .. plate .. '<br>Fuel: 100%<br>Engine: 100%<br>Body: 100%',
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
		})                             
    end
    table.insert(vehicleMenu, {
		header = '❌| Close',
		txt = '',
		params = {
			event = 'qb-menu:closeMenu',
		}
	})
    exports['qb-menu']:openMenu(vehicleMenu)
end)
-----------------------------------------------

-----------------------------------------------
--Take vehicle for job:
RegisterNetEvent('MojiaGarages:client:SpawnJobVeh', function(data)
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
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
		TriggerServerEvent('inventory:server:addTrunkItems', QBCore.Functions.GetPlate(veh), VehJobItems[PlayerData.job.name])
		lastjobveh = veh
    end, pos, true)
end)
-----------------------------------------------

-----------------------------------------------
--Hide vehicle for job:
RegisterNetEvent('MojiaGarages:client:HideJobVeh', function()
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local curVeh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
		curVeh = GetVehiclePedIsIn(ped)
	end
	if curVeh == lastjobveh then
		if IsPedInAnyVehicle(ped) then
			CheckPlayers(curVeh)
		else
			QBCore.Functions.DeleteVehicle(curVeh)
		end
		lastjobveh = nil
	end
end)
-----------------------------------------------
