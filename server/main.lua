ESX.RegisterServerCallback('esx_vehiclelock:getPlayerVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(vehicles)
        local result = {}
        for _, vehicle in ipairs(vehicles) do
            table.insert(result, { plate = vehicle.plate, props = json.decode(vehicle.vehicle) })
        end
        cb(result)
    end)
end)

RegisterServerEvent('esx_vehiclelock:copyKey')
AddEventHandler('esx_vehiclelock:copyKey', function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('INSERT INTO vehicle_keys (owner, plate) VALUES (@owner, @plate)', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function(rowsChanged)
        if rowsChanged > 0 then
            xPlayer.showNotification("~g~Clé dupliquée avec succès.")
        else
            xPlayer.showNotification("~r~Erreur lors de la duplication.")
        end
    end)
end)
