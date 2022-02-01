# MojiaGarages
🅿 Best advanced garages for QB-Core Framework 🅿

[Change Log](CHANGELOG.md)
## Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) -Main framework
- [PolyZone](https://github.com/qbcore-framework/PolyZone) -Needed for garages zone
- [qb-menu](https://github.com/qbcore-framework/qb-menu) -Needed for garages menu
- [qb-houses](https://github.com/qbcore-framework/qb-houses) -Needed for apartment garages
- [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys) -Needed for vehicle owner check

## Preview & tutorials:
[Preview and guide to installing a new garage - Youtube](https://youtu.be/1ECZIyZEmhY)

[Instructions for installing MojiaGarages on the original QB-Core - Youtube](https://youtu.be/C01WwrdL670)

[Real Life Parking Update](https://youtu.be/Llb7EdISVj0)

## Features(All in one):
- Park and taken out the vehicle as long as it's in the garage area
- When the vehicle is taken out, it will appear at the nearest parking line
- Depot system
- Impound system
- Separate parking system for each gang
- Vehicle for Work system(Planes, cars, boats...)
- In the Vehicle for Work system, You need to return the previously received vehicle before you can get a new one
- Items are available in the trunk of the vehicle for industries in the vehicle system for work
- Private parking at the headquarters of each profession
- Private parking for each apartment
- Automatically save coordinates, vehicle status
- Auto spawn car in its last position, if there are players nearby
- Depot only contains vehicles with fines greater than 0
- support multiple languages
- You can translate through your language easily through `lang.lua`
- Easy configuration via `config.lua`

## Installation:

### Manual:
- Download the script and put it in the `resources` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure MojiaGarages
```
### Important Note:
All garage data of pre-existing homes will not be compatible with this garage, you need to delete those garages and create new ones. When creating a new garage, you need to be on a vehicle.
### Edit the resources according to the following instructions:
#### qb-vehiclesales:
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
find:
```
QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned, balance)
```
replace with
```
QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned, balance)
```
#### qb-phone:
- Edit qb-phone\fxmanifest.lua:
```
shared_scripts {
    'config.lua',
    '@qb-apartments/config.lua',
    '@MojiaGarages/config.lua',
}
```
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
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?',
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
#### qb-policejob:
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

#### qb-houses:

- Edit qb-houses\client\main.lua:
```
local function SetClosestHouse()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    if not IsInside then
        for id, house in pairs(Config.Houses) do
            local distcheck = #(pos - vector3(Config.Houses[id].coords.enter.x, Config.Houses[id].coords.enter.y, Config.Houses[id].coords.enter.z))
            if current ~= nil then
                if distcheck < dist then
                    current = id
                    dist = distcheck
                end
            else
                dist = distcheck
                current = id
            end
        end
        ClosestHouse = current
        if ClosestHouse ~= nil and tonumber(dist) < 30 then
            QBCore.Functions.TriggerCallback('qb-houses:server:ProximityKO', function(key, owned)
                HasHouseKey = key
                isOwned = owned
            end, ClosestHouse)
        end
    end
end
```

```
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qb-houses:client:setHouses')
    SetClosestHouse()
    TriggerEvent('qb-houses:client:setupHouseBlips')
    if Config.UnownedBlips then TriggerEvent('qb-houses:client:setupHouseBlips2') end
    Wait(100)
    TriggerServerEvent("qb-houses:server:setHouses")
end)
```

```
RegisterNetEvent('qb-houses:client:createHouses', function(apartmentnumber, price, tier)
    local pos = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
	local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
    local street = GetStreetNameFromHashKey(s1)
    local coords = {
        enter 	= { x = pos.x, y = pos.y, z = pos.z, h = heading},
        cam 	= { x = pos.x, y = pos.y, z = pos.z, h = heading, yaw = -10.00},
    }
    street = 'No. ' .. apartmentnumber .. ' ' .. street:gsub('%-', ' ')
    TriggerServerEvent('qb-houses:server:addNewHouse', street, coords, price, tier)
    if Config.UnownedBlips then TriggerServerEvent('qb-houses:server:createBlip') end
end)
```

```
RegisterNetEvent('qb-houses:client:addGarage', function()
    if ClosestHouse ~= nil then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then            
            local veh = GetVehiclePedIsIn(ped)
			local vehpos = GetEntityCoords(veh)
			local x = QBCore.Shared.Round(vehpos.x, 2)
			local y = QBCore.Shared.Round(vehpos.y, 2)
			local z = QBCore.Shared.Round(vehpos.z, 2)
			local heading = GetEntityHeading(veh)
			local h = QBCore.Shared.Round(heading, 2)
			local forward, right, up, pos = GetEntityMatrix(veh)
			local x1 = QBCore.Shared.Round(pos.x + (forward.x * (3.0)) + (right.x * (2.0)), 2)
			local y1 = QBCore.Shared.Round(pos.y + (forward.y * (3.0)) + (right.y * (2.0)), 2)
			local x2 = QBCore.Shared.Round(pos.x + (forward.x * (-3.0)) + (right.x * (2.0)), 2)
			local y2 = QBCore.Shared.Round(pos.y + (forward.y * (-3.0)) + (right.y * (2.0)), 2)
			local x3 = QBCore.Shared.Round(pos.x + (forward.x * (-3.0)) + (right.x * (-2.0)), 2)
			local y3 = QBCore.Shared.Round(pos.y + (forward.y * (-3.0)) + (right.y * (-2.0)), 2)
			local x4 = QBCore.Shared.Round(pos.x + (forward.x * (3.0)) + (right.x * (-2.0)), 2)
			local y4 = QBCore.Shared.Round(pos.y + (forward.y * (3.0)) + (right.y * (-2.0)), 2)
            local coords = {
                x = x,
				y = y,
				z = z,
				h = h,
				x1 = x1,
				y1 = y1,
				x2 = x2,
				y2 = y2,
				x3 = x3,
				y3 = y3,
				x4 = x4,
				y4 = y4,
            }
            TriggerServerEvent('qb-houses:server:addGarage', ClosestHouse, coords)
        else
            QBCore.Functions.Notify("You need to be in the vehicle..", "error")
        end
    else
        QBCore.Functions.Notify("No house around..", "error")
    end
end)
```

```
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('qb-houses:client:setHouses')
    SetClosestHouse()
    TriggerEvent('qb-houses:client:setupHouseBlips')
    if Config.UnownedBlips then TriggerEvent('qb-houses:client:setupHouseBlips2') end
    Wait(100)
    TriggerServerEvent("qb-houses:server:setHouses")
end)
```

- Edit qb-houses\server\main.lua:
```
CreateThread(function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM houselocations', {})
    if result[1] then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = json.decode(v.garage) or {}
            Config.Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {}
            }
        end
    end
    TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Config.Houses)
end)
```

```
QBCore.Commands.Add("createhouse", "Create House (Real Estate Only)", {{name = "apartmentnumber", help = "Apartment number"}, {name = "price", help = "Price of the house"}, {name = "tier", help = "Name of the item(no label)"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local apartmentnumber = tonumber(args[1])
    local price = tonumber(args[2])
    local tier = tonumber(args[3])
    if Player.PlayerData.job.name == "realestate" then
        TriggerClientEvent("qb-houses:client:createHouses", src, apartmentnumber, price, tier)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.realestate_only"), "error")
    end
end)
```

```
RegisterNetEvent('qb-houses:server:addNewHouse', function(street, coords, price, tier)
    local src = source
    local street = street:gsub("%'", "")
    local price = tonumber(price)
    local tier = tonumber(tier)
	local name = street:lower()
    local label = street
    MySQL.Async.insert('INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)',
        {name, label, json.encode(coords), 0, price, tier})
    Config.Houses[name] = {
        coords = coords,
        owned = false,
        price = price,
        locked = true,
        adress = label,
        tier = tier,
        garage = {},
        decorations = {}
    }
    TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Config.Houses)
    TriggerClientEvent('QBCore:Notify', src, "You have added a house: " .. label)
    TriggerEvent('qb-log:server:CreateLog', 'house', 'House Created:', 'green', '**Address**:\n'..label..'\n\n**Listing Price**:\n$'..price..'\n\n**Tier**:\n'..tier..'\n\n**Listing Agent**:\n'..GetPlayerName(src))
end)
```

```
RegisterNetEvent('qb-houses:server:addGarage', function(house, coords)
    local src = source
    MySQL.Async.execute('UPDATE houselocations SET garage = ? WHERE name = ?', {json.encode(coords), house})
    TriggerClientEvent("MojiaGarages:client:updateGarage", -1) 	-- Update Garages
    TriggerClientEvent('QBCore:Notify', src, "You have added a garage: " .. Config.Houses[house].adress)
end)
```

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
        MySQL.Async.insert('INSERT INTO player_houses (house, identifier, citizenid, keyholders) VALUES (?, ?, ?, ?)',{house, pData.PlayerData.license, pData.PlayerData.citizenid, json.encode(housekeyholders[house])})
        MySQL.Async.execute('UPDATE houselocations SET owned = ? WHERE name = ?', {1, house})
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
#### qb-vehiclekeys:
- Edit qb-vehiclekeys\client\main.lua:

Add exports:
```
exports('HasVehicleKey', HasVehicleKey)
```
Right below:
```
local function HasVehicleKey(plate)
	QBCore.Functions.TriggerCallback('vehiclekeys:server:CheckHasKey', function(result)
		if result then
			HasVehicleKey = true
		else
			HasVehicleKey = false
		end
	end, plate)
	return HasVehicleKey
end
exports('HasVehicleKey', HasVehicleKey)
```
And now you can check your vehicle key by:
```
exports["qb-vehiclekeys"]:HasVehicleKey(plate)
```
- Add event to qb-vehiclekeys\server\main.lua:
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
### Event for F1 menu:
#### qb-radialmenu:
- Add MojiaGarages/client.lua:
```
CreateThread(function() -- Update for qb-radialmenu
	while true do		
		if inGarageStation and currentgarage ~= nil then
			TriggerEvent('MojiaGarages:client:updateRadialmenu')
		else
			TriggerEvent('MojiaGarages:client:updateRadialmenu')
		end
		Wait(1000)
	end
end)

RegisterNetEvent('MojiaGarages:client:updateRadialmenu', function()
	local PlayerData = QBCore.Functions.GetPlayerData()
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local ped = PlayerPedId()
	local veh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
		veh = GetVehiclePedIsIn(ped)
	end
	local plate = QBCore.Functions.GetPlate(veh)		
	--Open garage
	if inGarageStation and currentgarage ~= nil and not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and not IsPedInAnyVehicle(ped, false) then
		exports["qb-radialmenu"]:addSubMenu(3, 'opengarage', {
			id = 'opengarage',
			title = 'Open Garages',
			icon = 'car',
			type = 'client',
			event = 'MojiaGarages:client:openGarage',
			shouldClose = true
		})
	else
		exports["qb-radialmenu"]:removeSubMenu(3, 'opengarage')
	end
	--Store Vehicle
	if inGarageStation and currentgarage ~= nil and not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and Garages[currentgarage].canStoreVehicle and exports["qb-vehiclekeys"]:HasVehicleKey(plate) then
		exports["qb-radialmenu"]:addSubMenu(3, 'storevehicle', {
			id = 'storevehicle',
			title = 'Store Vehicle',
			icon = 'car',
			type = 'client',
			event = 'MojiaGarages:client:storeVehicle',
			shouldClose = true
		})
	else
		exports["qb-radialmenu"]:removeSubMenu(3, 'storevehicle')
	end
	--Job
	if PlayerData.job then
		if inGarageStation and currentgarage ~= nil and not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.onduty and inJobStation[PlayerData.job.name] and lastjobveh == nil and not IsPedInAnyVehicle(ped) then
			exports["qb-radialmenu"]:addJobSubMenu(PlayerData.job.name, PlayerData.job.name .. 'opengarage', {
				id = PlayerData.job.name .. 'opengarage',
				title = 'Open Garages',
				icon = 'car',
				type = 'client',
				event = 'MojiaGarages:client:openJobVehList',
				shouldClose = true
			})
		else
			exports["qb-radialmenu"]:removeJobSubMenu(PlayerData.job.name, PlayerData.job.name .. 'opengarage')
		end
		if inGarageStation and currentgarage ~= nil and not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.onduty and inJobStation[PlayerData.job.name] and lastjobveh == veh and exports["qb-vehiclekeys"]:HasVehicleKey(plate) then
			exports["qb-radialmenu"]:addJobSubMenu(PlayerData.job.name, PlayerData.job.name .. 'storevehicle', {
				id = PlayerData.job.name .. 'storevehicle',
				title = 'Store Vehicle',
				icon = 'car',
				type = 'client',
				event = 'MojiaGarages:client:HideJobVeh',
				shouldClose = true
			})
		else
			exports["qb-radialmenu"]:removeJobSubMenu(PlayerData.job.name, PlayerData.job.name .. 'storevehicle')
		end
	end
end)
```
- Edit qb-radialmenu\client\main.lua:
```
-- Sets the metadata when the player spawns
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
	TriggerEvent('MojiaGarages:client:updateRadialmenu')
end)
```
```
-- Sets the playerdata to an empty table when the player has quit or did /logout
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
	TriggerEvent('MojiaGarages:client:updateRadialmenu')
end)
```
```
-- This will update all the PlayerData that doesn't get updated with a specific event other than this like the metadata
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
	TriggerEvent('MojiaGarages:client:updateRadialmenu')
end)
```
- Add to qb-radialmenu\client\main.lua:

```
local function CheckHasID(id1, id2)
	local has = false
	if Config.MenuItems[id1].items then
		for k, v in pairs(Config.MenuItems[id1].items) do
			if v.id == id2 then
				has = true
			end
		end
	end
	return has
end

local function CheckHasID2(job, id)
	local has = false
	if Config.JobInteractions[job] then
		for k, v in pairs(Config.JobInteractions[job]) do
			if v.id == id then
				has = true
			end
		end
	end
	return has
end

local function addSubMenu(id1, id2, menu)
	if Config.MenuItems[id1].items and not CheckHasID(id1, id2) then
		Config.MenuItems[id1].items[#Config.MenuItems[id1].items + 1] = menu
	end
end

local function addJobSubMenu(job, id, menu)
	if Config.JobInteractions[job] and not CheckHasID2(job, id) then
		Config.JobInteractions[job][#Config.JobInteractions[job] +1 ] =  menu
	end
end

local function removeSubMenu(id1, id2)
	if Config.MenuItems[id1].items and CheckHasID(id1, id2) then
		for k, v in pairs(Config.MenuItems[id1].items) do
			if v.id == id2 then
        if k == #Config.MenuItems[id1].items then
				  Config.MenuItems[id1].items[k] = nil
        else
          Config.MenuItems[id1].items[k] = Config.MenuItems[id1].items[#Config.MenuItems[id1].items]
          Config.MenuItems[id1].items[#Config.MenuItems[id1].items] = nil
        end
			end
		end
	end
end

local function removeJobSubMenu(job, id)
	if Config.JobInteractions[job] and CheckHasID2(job, id) then
		for k, v in pairs(Config.JobInteractions[job]) do
			if v.id == id then
        if k == #Config.JobInteractions[job] then
				  Config.JobInteractions[job][k] = nil
        else
          Config.JobInteractions[job][k] = Config.JobInteractions[job][#Config.JobInteractions[job]]
          Config.JobInteractions[job][#Config.JobInteractions[job]] = nil
        end
			end
		end
	end
end

exports('addSubMenu', addSubMenu)
exports('addJobSubMenu', addJobSubMenu)
exports('removeSubMenu', removeSubMenu)
exports('removeJobSubMenu', removeJobSubMenu)
```
#### Other Menu:
##### Open Garage:
- Event:
```
'MojiaGarages:client:openGarage'
```
- Enable Menu(If your radial menu can enable/hide button):
```
local isingarage, canStoreVehicle = exports["MojiaGarages"]:IsInGarage()
```
isingarage → check if you are in the garage area → True|False → you can use:
```
if isingarage then
```
canStoreVehicle → check if the garage allows parking → True|False →  don't need it.

Check if you are in the vehicle or not → you can use:
```
if not IsPedInAnyVehicle(PlayerPedId()) then
```
##### Store Vehicle:
- Event:
```
'MojiaGarages:client:storeVehicle'
```
- Enable Menu(If your radial menu can enable/hide button):
```
local isingarage, canStoreVehicle = exports["MojiaGarages"]:IsInGarage()
```
isingarage → check if you are in the garage area → True|False → you can use:
```
if isingarage then
```
canStoreVehicle → check if the garage allows parking → True|False →  you can use:
```
if canStoreVehicle then
```
You should have more vehicle key check function here:
```
if exports["qb-vehiclekeys"]:HasVehicleKey(plate) then
```
##### Open vehicle list for work:
- Event:
```
'MojiaGarages:client:openJobVehList'
```
- Enable Menu(If your radial menu can enable/hide button):
```
isInJobGarage, lastJobVehicle = exports["MojiaGarages"]:isInJobStation('your job')
```
isInJobGarage → check if you are in the garage area → True|False → you can use:
```
if isInJobGarage then
```
lastJobVehicle → return vehicle or nil →  you can use:
```
if lastJobVehicle == nil then
```
Check if you are in the vehicle or not → you can use:
```
if not IsPedInAnyVehicle(PlayerPedId()) then
```

##### Hide vehicle for work:
- Event:
```
'MojiaGarages:client:HideJobVeh'
```
- Enable Menu(If your radial menu can enable/hide button):
```
isInJobGarage, lastJobVehicle = exports["MojiaGarages"]:isInJobStation('your job')
```
isInJobGarage → check if you are in the garage area → True|False → you can use:
```
if isInJobGarage then
```
lastJobVehicle → return vehicle or nil →  you can use:
```
if lastJobVehicle ~= nil then
```
You should have more vehicle key check function here:
```
if exports["qb-vehiclekeys"]:HasVehicleKey(plate) then
```
### In progress:
- Parking system for boats
- Parking system for planes
### Note:
- This script is completely free for community, it is strictly forbidden to use this script for commercial purposes.
- If you want to offer me a cup of coffee, you can donate to me through: [https://www.buymeacoffee.com/hoangducdt](https://www.buymeacoffee.com/hoangducdt)
- Follow me on [My Github](https://github.com/hoangducdt) or subscribe to [My Youtube Channel](https://www.youtube.com/channel/UCFIsOgj9zvEWAwFTPRT5mbQ) for latest updates
- My Discord: ✯✯✯✯✯#8386
