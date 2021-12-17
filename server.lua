local QBCore = exports['MojiaCity']:GetCoreObject()

QBCore.Functions.CreateCallback('MojiaVehicles:checkVehicleOwner', function(source, cb, plate)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
	{plate, pData.PlayerData.citizenid}, function(result)
		if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end
	end)
end)

--Lấy danh sách xe trong gara:
QBCore.Functions.CreateCallback("MojiaGarages:server:GetUserVehicles", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE citizenid = ?',
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
--Lấy thông tin xe:
QBCore.Functions.CreateCallback("MojiaGarages:server:GetVehicleProperties", function(source, cb, plate)
    local src = source
    local properties = {}
    local result = exports.oxmysql:fetchSync('SELECT mods FROM player_vehicles WHERE plate = ?', {plate})
    if result[1] ~= nil then
        properties = json.decode(result[1].mods)
    end
    cb(properties)
end)

RegisterServerEvent('MojiaGaragess:server:UpdateOutsideVehicles')
AddEventHandler('MojiaGaragess:server:UpdateOutsideVehicles', function(Vehicles)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local CitizenId = Ply.PlayerData.citizenid

    OutsideVehicles[CitizenId] = Vehicles
end)

RegisterServerEvent('MojiaGarages:server:updateVehicleState')
AddEventHandler('MojiaGarages:server:updateVehicleState', function(state, plate, garage)
    exports.oxmysql:execute('UPDATE player_vehicles SET state = ?, garage = ?, depotprice = ? WHERE plate = ?',
        {state, garage, 0, plate})
end)

RegisterServerEvent('MojiaGarages:server:updateVehicleStatus')
AddEventHandler('MojiaGarages:server:updateVehicleStatus', function(fuel, engine, body, plate, garage)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    if engine > 1000 then
        engine = engine / 1000
    end

    if body > 1000 then
        body = body / 1000
    end

    exports.oxmysql:execute(
        'UPDATE player_vehicles SET fuel = ?, engine = ?, body = ? WHERE plate = ? AND citizenid = ? AND garage = ?',
        {fuel, engine, body, plate, pData.PlayerData.citizenid, garage})
end)

RegisterServerEvent('MojiaGarages:server:PayDepotPrice')
AddEventHandler('MojiaGarages:server:PayDepotPrice', function(vehicle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ?',
		{
			vehicle.plate
		}, function(result)
        if result[1] ~= nil then
            if bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney("bank", result[1].depotprice, "paid-depot")
                TriggerClientEvent("Garage:client:doTakeOutVehicle", src, vehicle)
            end
        end
    end)
end)