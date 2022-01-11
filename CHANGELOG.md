# Change Log
## Date: 11/01/22
- Update compatible with old database
- Edit qb-phone\client\main.lua:
```
RegisterNUICallback('track-vehicle', function(data, cb)
    local veh = data.veh
    TriggerEvent('MojiaGarages:client:trackVehicle', veh.plate)
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

- Edit: qb-core\client\functions.lua:
```
function QBCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
    DeleteVehicle(vehicle)
end
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
