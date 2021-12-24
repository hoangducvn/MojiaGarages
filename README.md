# Preview & Set up
- [Preview and set up new garage - Youtube](https://youtu.be/soYaVYM2ORc)

# Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [PolyZone](https://github.com/qbcore-framework/PolyZone)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)

# Edit in qb-phone\fxmanifest.lua:
```
shared_scripts {
    'config.lua',
    '@qb-apartments/config.lua',
    '@MojiaGarages/config.lua',
}
```
# Edit in qb-phone\server\main.lua:
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
                --elseif GangGarages[v.garage] ~= nil then
                    --VehicleGarage = GangGarages[v.garage]["label"]
                --elseif JobGarages[v.garage] ~= nil then
                    --VehicleGarage = JobGarages[v.garage]["label"]
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
# Add event to F1 menu:
- Open Garage:
```
'MojiaGarages:openGarage'
```
For example:
```
--Open Garage:
{
	id = "opengarage",
	title = 'Open Garage',
	icon = '#garage-open',
	type = 'client',
	event = 'MojiaGarages:openGarage',
	enableMenu = function()
		PlayerData = QBCore.Functions.GetPlayerData()
		local isingarage, garastate = exports["MojiaGarages"]:IsInGarage()
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and isingarage and garastate ~= nil then 
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped, false) then
				return true
			end
		end
		return false
	end
},
```
- Store Vehicle:
```
'MojiaGarages:storeVehicle'
```
For example:
```
-- Store Vehicle:
{
	id = "storeVehicle",
	title = 'Store Vehicle',
	icon = '#parking',
	type = 'client',
	event = 'MojiaGarages:storeVehicle',
	enableMenu = function()
		PlayerData = QBCore.Functions.GetPlayerData()
		local isingarage, garastate = exports["MojiaGarages"]:IsInGarage()
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and isingarage and garastate ~= nil then 
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local ped = PlayerPedId()
			local veh = QBCore.Functions.GetClosestVehicle(pos)
			if IsPedInAnyVehicle(ped) then
				veh = GetVehiclePedIsIn(ped)
			end
			local plate = QBCore.Functions.GetPlate(veh)
			if CheckHasKey(plate) and garastate == 1 then
				return true
			end
		end
		return false
	end
},
```
- Open Job Vehicles List:
```
'MojiaGarages:openJobVehList'
```
For example:
```
{
	id = "policeveh",
	title = 'Job Veh',
	icon = '#mj-garage-open',
	type = 'client',
	event = 'MojiaGarages:openJobVehList',
	enableMenu = function()
		PlayerData = QBCore.Functions.GetPlayerData()
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.name == 'police' and PlayerData.job.onduty and exports["MojiaGarages"]:isInStation('police') then  
			if not IsPedInAnyVehicle(PlayerPedId()) then
				return true
			end
		end
		return false
	end
},
```
- Hide Job Vehicle:
```
'MojiaGarages:client:HideJobVeh'
```
For example:

```
{
	id = "hidejobveh",
	title = 'Hide Job Veh',
	icon = '#mj-parking',
	type = 'client',
	event = 'MojiaGarages:client:HideJobVeh',
	enableMenu = function()
		PlayerData = QBCore.Functions.GetPlayerData()
		if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and PlayerData.job.name == 'police' and PlayerData.job.onduty and exports["MojiaGarages"]:isInStation('police') then  
			local ped = PlayerPedId()						
			if IsPedInAnyVehicle(ped) then 
				return true
			end
		end
		return false
	end
},
```


# In progress:
House garages
# Note:

This script is completely free for community, it is strictly forbidden to use this script for commercial purposes

