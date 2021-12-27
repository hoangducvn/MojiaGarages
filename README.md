# MojiaGarages
🅿 Best advanced garages for QB-Core Framework 🅿

## Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) -Main framework
- [PolyZone](https://github.com/qbcore-framework/PolyZone) -Need for garages zone
- [qb-menu](https://github.com/qbcore-framework/qb-menu) -Need for garages menu
- [qb-houses](https://github.com/qbcore-framework/qb-houses) -Need for apartment garages

## Preview & tutorials:
[Previews and tutorials - Youtube](https://youtu.be/1ECZIyZEmhY)

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
- Easy configuration via `config.lua`

## Installation:

### Manual:
- Download the script and put it in the `resources` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure MojiaGarages
```
### Edit the resources according to the following instructions:

#### qb-phone:
- Edit qb-phone\fxmanifest.lua:
```
shared_scripts {
    'config.lua',
    '@qb-apartments/config.lua',
    '@MojiaGarages/config.lua',
}
```
- Edit qb-phone\server\main.lua:
```
QBCore.Functions.CreateCallback('qb-phone:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}

    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?',
        {Player.PlayerData.citizenid})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local VehicleData = QBCore.Shared.Vehicles[v.vehicle]

            local VehicleGarage = "None"
            if v.garage ~= nil then
                if Garages[v.garage] ~= nil then
                    VehicleGarage = Garages[v.garage]["label"]
                end
            end

            local VehicleState = "In"
            if v.state == 0 then
                VehicleState = "Out"
            elseif v.state == 2 then
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
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
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
                HasKey = key
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
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations', {})
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
        TriggerClientEvent('QBCore:Notify', src, "Only realestate can use this command", "error")
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
    exports.oxmysql:insert('INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)',
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
    exports.oxmysql:execute('UPDATE houselocations SET garage = ? WHERE name = ?', {json.encode(coords), house})
    TriggerClientEvent("MojiaGarages:client:updateGarage", -1)
    TriggerClientEvent('QBCore:Notify', src, "You have added a garage: " .. Config.Houses[house].adress)
end)
```
- On qb-vehiclekeys\client\main.lua(If you use it):

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
### Event for F1 menu:
#### Open Garage:
- Event:
```
'MojiaGarages:client:openGarage'
```
- Enable Menu:
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
#### Store Vehicle:
- Event:
```
'MojiaGarages:client:storeVehicle'
```
- Enable Menu:
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
if havekey(vehicle) then

or

if havekey(plate) then
```
#### Open vehicle list for work:
- Event:
```
'MojiaGarages:client:openJobVehList'
```
- Enable Menu:
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
- For example(this is an example not the way to use every radial menu):
```
#### Hide vehicle for work:
- Event:
```
'MojiaGarages:client:HideJobVeh'
```
- Enable Menu:
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
if havekey(vehicle) then

or

if havekey(plate) then
```
### In progress:
- Parking system for boats
- Parking system for planes
### Note:
- This script is completely free for community, it is strictly forbidden to use this script for commercial purposes.
- If you want to offer me a cup of coffee, you can donate to me through: [https://www.buymeacoffee.com/hoangducdt](https://www.buymeacoffee.com/hoangducdt)
- Follow me on [My Github](https://github.com/hoangducdt) or subscribe to [My Youtube Channel](https://www.youtube.com/channel/UCFIsOgj9zvEWAwFTPRT5mbQ) for latest updates
