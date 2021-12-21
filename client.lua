local inGarageStation = false
local currentgarage = nil
local nearspawnpoint = nil
local OutsideVehicles = {}
local Stations = {}

local function CreateBlip(coords, sprite, scale, color, text)
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip, sprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, scale)
	SetBlipAsShortRange(blip, true)
	SetBlipColour(blip, color)
	SetBlipAlpha(Blip, 0.7)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

local function GetVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(QBCore.Functions.GetVehicles(), false, coords, maxDistance) 
end

local function IsSpawnPointClear(coords, maxDistance) 
	return #GetVehiclesInArea(coords, maxDistance) == 0 
end

CreateThread(function()
	for k, v in pairs(Garages) do
		if v.showBlip then
			PlayerData = QBCore.Functions.GetPlayerData()
			if v.job ~= nil and (PlayerData.job.name == v.job or PlayerData.gang.name == v.job) then
				CreateBlip(v.blippoint, v.blipsprite, v.blipscale, v.blipcolour, v.label)
			else
				CreateBlip(v.blippoint, v.blipsprite, v.blipscale, v.blipcolour, v.label)
			end
		end
	end
end)

CreateThread(function() 
    for k, v in pairs(Garages) do
		Stations[k] = PolyZone:Create(v.zones, {
			name="GarageStation "..k,
			minZ = 	v.minz,
			maxZ = v.maxz,
			debugPoly = true
		})
		Stations[k]:onPlayerInOut(function(isPointInside)
			if isPointInside then
				if Garages[k].job ~= nil then
					PlayerData = QBCore.Functions.GetPlayerData()
					if PlayerData.job.name == Garages[k].job or PlayerData.gang.name == Garages[k].job then
						inGarageStation = true
						currentgarage = k
					else
						inGarageStation = false
						currentgarage = nil
					end
				else
					inGarageStation = true
					currentgarage = k
				end
			else
				inGarageStation = false
				currentgarage = nil
			end
		end)
    end
end)

CreateThread(function()
	while true do
		Wait(1000)
		if inGarageStation and currentgarage ~= nil then
			nearspawnpoint = GetNearSpawnPoint()
		end
	end
end)


function IsInGarage()
	local check, garastate = false, nil
	if inGarageStation and currentgarage ~= nil then
		check = true
		garastate = Garages[currentgarage].garastate
	end
	return check, garastate
end

--Mở danh sách xe trong gara:
RegisterNetEvent('MojiaGarages:openGarage', function()
    if inGarageStation and currentgarage ~= nil then
		QBCore.Functions.TriggerCallback("MojiaGarages:server:GetUserVehicles", function(result)
			if result == nil then
				QBCore.Functions.Notify("There are no vehicles in the garage", "error", 5000)
			else
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
									txt = "Plate: "..v.plate.."<br>Fuel: "..currentFuel.."%<br>Engine: "..enginePercent.."%<br>Body: "..bodyPercent.."%",
									params = {
										event = "MojiaGarages:client:TakeOutVehicle",
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
								vname = "Price: $"..v.depotprice.."<br>Plate: "..v.plate.."<br>Fuel: "..currentFuel.."%<br>Engine: "..enginePercent.."%<br>Body: "..bodyPercent.."%"
							else
								vname = "Plate: "..v.plate.."<br>Fuel: "..currentFuel.."%<br>Engine: "..enginePercent.."%<br>Body: "..bodyPercent.."%"
							end
							
							table.insert(MenuGaraOptions, {
								header = QBCore.Shared.Vehicles[v.vehicle].name,
								txt = vname,
								params = {
									event = "MojiaGarages:client:TakeOutVehicle",
									args = v
								}
							})
						end
					end
				end
				table.insert(MenuGaraOptions, {
					header = '❌| Close',
					txt = "",
					params = {
						event = "qb-menu:closeMenu",
					}
				})
				exports['qb-menu']:openMenu(MenuGaraOptions)
			end
		end)
	end
end)

--Lấy xe khỏi gara:
RegisterNetEvent('MojiaGarages:client:TakeOutVehicle', function(vehicle)
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		if vehicle.state == 0 and vehicle.depotprice > 0 then
			TriggerServerEvent("MojiaGarages:server:PayDepotPrice", vehicle)
			Wait(1000)
		else
			TriggerEvent("MojiaGarages:client:doTakeOutVehicle", vehicle)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:doTakeOutVehicle', function(vehicle)
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		local lastnearspawnpoint = nearspawnpoint
		if not IsSpawnPointClear(vector3(Garages[currentgarage].spawnPoint[lastnearspawnpoint].x, Garages[currentgarage].spawnPoint[lastnearspawnpoint].y, Garages[currentgarage].spawnPoint[lastnearspawnpoint].z), 2.5) then
			QBCore.Functions.Notify('The receiving area is obstructed by something...', "error", 2500)
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
					QBCore.Functions.Notify('Take out ' .. QBCore.Shared.Vehicles[vehicle.vehicle].name .. ' | Motor: ' .. enginePercent .. '% Body: ' .. bodyPercent.. '% Fuel: '..currentFuel.. '%', "success", 4500)
					--TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
					TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
					--SetVehicleEngineOn(veh, true, true)
				end, vehicle.plate)

			end, Garages[currentgarage].spawnPoint[lastnearspawnpoint], true)
		end
	end
end)

function Deleteveh(plate)
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

--Gửi xe vào gara:
RegisterNetEvent('MojiaGarages:storeVehicle', function()
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
				QBCore.Functions.TriggerCallback('MojiaVehicles:checkVehicleOwner', function(owned)
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
						QBCore.Functions.Notify('Vehicle parked in ' .. Garages[currentgarage].label, "success", 4500)
					else
						QBCore.Functions.Notify('Nobody owns this vehicle!', "error", 3500)
					end
				end, plate)
			end
		end
	end
end)

function GetNearSpawnPoint()
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

function CheckPlayers(vehicle)
    for i = -1, 5,1 do                
        seat = GetPedInVehicleSeat(vehicle,i)
        if seat ~= 0 then
            TaskLeaveVehicle(seat,vehicle,0)
            SetVehicleDoorsLocked(vehicle)
            Wait(1500)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
   end
end

function doCarDamage(currentVehicle, veh)
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
