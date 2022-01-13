# Change Log
## Date: 13/01/22
- Fix impound garage and new way to qb-radialmenu
- Add to qb-radialmenu\client\main.lua:

```
local function CheckHasID(id1, id2)
	local has = false
	for k, v in pairs(Config.MenuItems[id1].items) do
		if v.id == id2 then
			has = true
		end
	end
	return has
end

local function CheckHasID1(id1, id2)
	local has = false
	for k, v in pairs(Config.JobInteractions[id1]) do
		if v.id == id2 then
			has = true
		end
	end
	return has
end

CreateThread(function()
	while true do
		local PlayerData = QBCore.Functions.GetPlayerData()
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)
		local ped = PlayerPedId()
		local veh = QBCore.Functions.GetClosestVehicle(pos)
		if IsPedInAnyVehicle(ped) then
			veh = GetVehiclePedIsIn(ped)
		end
		local plate = QBCore.Functions.GetPlate(veh)
		local isingarage, canStoreVehicle = exports['MojiaGarages']:IsInGarage()
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and isingarage and not IsPedInAnyVehicle(ped, false) then 
			if not CheckHasID(3, 'opengarage') then
				Config.MenuItems[3].items[#Config.MenuItems[3].items + 1] = {
					id = 'opengarage',
					title = 'Open Garages',
					icon = 'car',
					type = 'client',
					event = 'MojiaGarages:client:openGarage',
					shouldClose = true
				}
			end
			
		else
			for k, v in pairs(Config.MenuItems[3].items) do
				if v.id == 'opengarage' then
					Config.MenuItems[3].items[k] = nil
				end
			end
		end
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and isingarage and canStoreVehicle and exports["qb-vehiclekeys"]:HasVehicleKey(plate) then 
			if not CheckHasID(3, 'storeVehicle') then
				Config.MenuItems[3].items[#Config.MenuItems[3].items + 1] = {
					id = 'storeVehicle',
					title = 'Store Vehicle',
					icon = 'car',
					type = 'client',
					event = 'MojiaGarages:client:storeVehicle',
					shouldClose = true
				}
			end
		else
			for k, v in pairs(Config.MenuItems[3].items) do
				if v.id == 'storeVehicle' then
					Config.MenuItems[3].items[k] = nil
				end
			end
		end
		local isInJobGarage, lastJobVehicle = exports['MojiaGarages']:isInJobStation('police')
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.name == 'police' and PlayerData.job.onduty and isInJobGarage and lastJobVehicle == nil and not IsPedInAnyVehicle(ped) then  
			if not CheckHasID1('police', 'openpolicejobveh') then
				Config.JobInteractions['police'][#Config.JobInteractions['police'] +1 ] = {
					id = 'openpolicejobveh',
					title = 'Police Job Vehicle',
					icon = 'car',
					type = 'client',
					event = 'MojiaGarages:client:openJobVehList',
					shouldClose = true
				}
			end
		else
			for k, v in pairs(Config.JobInteractions['police']) do
				if v.id == 'openpolicejobveh' then
					Config.JobInteractions['police'][k] = nil
				end
			end
		end
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.name == 'police' and PlayerData.job.onduty and isInJobGarage and lastJobVehicle ~= nil and exports["qb-vehiclekeys"]:HasVehicleKey(plate) and veh == lastJobVehicle then  
			if not CheckHasID1('police', 'storepolicejobveh') then
				Config.JobInteractions['police'][#Config.JobInteractions['police'] +1 ] = {
					id = 'storepolicejobveh',
					title = 'Store Job Vehicle',
					icon = 'car',
					type = 'client',
					event = 'MojiaGarages:client:HideJobVeh',
					shouldClose = true
				}
			end
		else
			for k, v in pairs(Config.JobInteractions['police']) do
				if v.id == 'storepolicejobveh' then
					Config.JobInteractions['police'][k] = nil
				end
			end
		end
		Wait(1000)
	end
end)
```
## Date: 11/01/22
- Update compatible with old database
- Edit qb-phone\client\main.lua:
```
RegisterNUICallback('track-vehicle', function(data, cb)
    local veh = data.veh
    TriggerEvent('MojiaGarages:client:trackVehicle', veh.plate)
end)
```
- Edit qb-phone\server\main.lua:
```
QBCore.Functions.CreateCallback('qb-phone:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?',
        {
			Player.PlayerData.citizenid
		}
	)
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local VehicleData = QBCore.Shared.Vehicles[v.vehicle]
			local modifications = json.decode(v.mods)
            local VehicleGarage = "None"
            if v.garage ~= nil then
                if Garages[v.garage] ~= nil then
                    VehicleGarage = Garages[v.garage]["label"]
                end
            end
            local VehicleState = "In"
            if v.state == 0 then
				if v.depotprice == 0 then
					VehicleGarage = "None"
					VehicleState = "Out"
				else
					VehicleGarage = "Depot"
					VehicleState = "In Depot"
				end
            elseif v.state == 2 then
                VehicleGarage = "Police Depot"
				VehicleState = "Impounded"
            end
            local vehdata = {}
            if VehicleData["brand"] ~= nil then
                vehdata = {
                    fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                    brand = VehicleData["brand"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = modifications.fuelLevel,
                    engine = modifications.engineHealth,
                    body = modifications.bodyHealth
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = modifications.fuelLevel,
                    engine = modifications.engineHealth,
                    body = modifications.bodyHealth
                }
            end
            Vehicles[#Vehicles+1] = vehdata
        end
        cb(Vehicles)
    else
        cb(nil)
    end
end)
```

- Edit qb-policejob\client\job.lua:
```
RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = QBCore.Functions.GetPlate(vehicle)
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)			
            QBCore.Functions.DeleteVehicle(vehicle)
            TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
        end
    end
end)
```
- Edit qb-vehiclesales\client\main.lua:
```
local function SellToDealer(sellVehData, vehicleHash)
    CreateThread(function()
        local keepGoing = true
        while keepGoing do
            local coords = GetEntityCoords(vehicleHash)
            DrawText3Ds(coords.x, coords.y, coords.z + 1.6, '~g~7~w~ - Confirm / ~r~8~w~ - Cancel ~g~')
            if IsDisabledControlJustPressed(0, 161) then
                TriggerServerEvent('qb-occasions:server:sellVehicleBack', sellVehData)
                local plate = QBCore.Functions.GetPlate(vehicleHash)
                TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
                QBCore.Functions.DeleteVehicle(vehicleHash)
                keepGoing = false
            end
            if IsDisabledControlJustPressed(0, 162) then
                keepGoing = false
            end
            if #(Config.SellVehicleBack - coords) > 3 then
                keepGoing = false
            end
            Wait(0)
        end
    end)
end
```

```
local function sellVehicleWait(price)
    DoScreenFadeOut(250)
    Wait(250)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
    QBCore.Functions.DeleteVehicle(vehicle)
    Wait(1500)
    DoScreenFadeIn(250)
    QBCore.Functions.Notify('Your car has been put up for sale! Price - $'..price, 'success')
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end
```
## Date: 10/01/22
- Update Track Vehicle
- Add cleanup function
- Edit qb-phone\client\main.lua:
```
RegisterNUICallback('track-vehicle', function(data, cb)
    local veh = data.veh
    TriggerEvent('MojiaGarages:client:trackVehicle', veh.plate)
end)
```
- Edit qb-vehiclesales\server\main.lua:
```
local function SellToDealer(sellVehData, vehicleHash)
    CreateThread(function()
        local keepGoing = true
        while keepGoing do
            local coords = GetEntityCoords(vehicleHash)
            DrawText3Ds(coords.x, coords.y, coords.z + 1.6, '~g~7~w~ - Confirm / ~r~8~w~ - Cancel ~g~')
            if IsDisabledControlJustPressed(0, 161) then
                TriggerServerEvent('qb-occasions:server:sellVehicleBack', sellVehData)
                local plate = QBCore.Functions.GetPlate(vehicleHash)
                TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
                QBCore.Functions.DeleteVehicle(vehicleHash)
                keepGoing = false
            end
            if IsDisabledControlJustPressed(0, 162) then
                keepGoing = false
            end
            if #(Config.SellVehicleBack - coords) > 3 then
                keepGoing = false
            end
            Wait(0)
        end
    end)
end
```

```
local function sellVehicleWait(price)
    DoScreenFadeOut(250)
    Wait(250)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
    QBCore.Functions.DeleteVehicle(vehicle)
    Wait(1500)
    DoScreenFadeIn(250)
    QBCore.Functions.Notify('Your car has been put up for sale! Price - $'..price, 'success')
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end
```

## Date: 08/01/22
- Automatically save coordinates, vehicle status
- Auto spawn car in its last position, if there are players nearby
- Depot only contains vehicles with fines greater than 0
- Need Add event to qb-vehiclekeys\server\main.lua:
```
RegisterNetEvent('MojiaGarages:server:updateOutSiteVehicleKeys', function(plate, citizenid) --Update vehicle Keys for qb-vehicle key
    if plate and citizenid then
        if VehicleList then
            -- VehicleList exists so check for a plate
            local val = VehicleList[plate]
            if val then
                -- The plate exists
                VehicleList[plate].owners[citizenid] = true
            else
                -- Plate not currently tracked so store a new one with one owner
                VehicleList[plate] = {
                    owners = {}
                }
                VehicleList[plate].owners[citizenid] = true
            end
        else
            -- Initialize new VehicleList
            VehicleList = {}
            VehicleList[plate] = {
                owners = {}
            }
            VehicleList[plate].owners[citizenid] = true
        end
    end
end)
```
## Date: 31/12/21
- Show only the necessary zones
- Delete unnecessary zones every time there is a change (job, gang...)
- Set house key check event before garage update event to fix incorrect garage update every time job change
- Update event to check house key:
Need Edit qb-houses\server\main.lua:
```
RegisterNetEvent('qb-houses:server:buyHouse', function(house)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local price = Config.Houses[house].price
    local HousePrice = math.ceil(price * 1.21)
    local bankBalance = pData.PlayerData.money["bank"]

    if (bankBalance >= HousePrice) then
        houseowneridentifier[house] = pData.PlayerData.license
        houseownercid[house] = pData.PlayerData.citizenid
        housekeyholders[house] = {
            [1] = pData.PlayerData.citizenid
        }
        exports.oxmysql:insert('INSERT INTO player_houses (house, identifier, citizenid, keyholders) VALUES (?, ?, ?, ?)',{house, pData.PlayerData.license, pData.PlayerData.citizenid, json.encode(housekeyholders[house])})
        exports.oxmysql:execute('UPDATE houselocations SET owned = ? WHERE name = ?', {1, house})
        TriggerClientEvent('qb-houses:client:SetClosestHouse', src)
        pData.Functions.RemoveMoney('bank', HousePrice, "bought-house") -- 21% Extra house costs
        TriggerEvent('qb-bossmenu:server:addAccountMoney', "realestate", (HousePrice / 100) * math.random(18, 25))
        TriggerEvent('qb-log:server:CreateLog', 'house', 'House Purchased:', 'green', '**Address**:\n'..house:upper()..'\n\n**Purchase Price**:\n$'..HousePrice..'\n\n**Purchaser**:\n'..pData.PlayerData.charinfo.firstname..' '..pData.PlayerData.charinfo.lastname)
		TriggerClientEvent("MojiaGarages:client:updateGarage", -1) 	-- Update Garages	
	else
        TriggerClientEvent('QBCore:Notify', source, "You dont have enough money..", "error")
    end
end)
```
## Date: 30/12/21
**Added:**
- Change Log
