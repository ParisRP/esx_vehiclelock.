ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Verrouiller/Déverrouiller via Télécommande
RegisterNetEvent('esx_vehiclelock:toggleLock')
AddEventHandler('esx_vehiclelock:toggleLock', function(vehiclePlate)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 10.0)

    if #vehicles == 0 then
        ESX.ShowNotification("~r~Aucun véhicule à proximité.")
        return
    end

    for _, vehicle in ipairs(vehicles) do
        local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

        if plate == vehiclePlate then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if lockStatus == 1 then
                SetVehicleDoorsLocked(vehicle, 2)
                ESX.ShowNotification("~r~Véhicule verrouillé.")
            else
                SetVehicleDoorsLocked(vehicle, 1)
                ESX.ShowNotification("~g~Véhicule déverrouillé.")
            end

            PlayLockAnimation(playerPed)
            FlashVehicleLights(vehicle)
            return
        end
    end

    ESX.ShowNotification("~r~Ce véhicule n'est pas à vous.")
end)

-- Animation lors du verrouillage/déverrouillage
function PlayLockAnimation(ped)
    local animDict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, animDict, "fob_click", 8.0, 8.0, -1, 48, 0, false, false, false)
    Citizen.Wait(1000)
    ClearPedTasks(ped)
end

-- Lumières clignotantes pour confirmation
function FlashVehicleLights(vehicle)
    SetVehicleLights(vehicle, 2)
    Citizen.Wait(150)
    SetVehicleLights(vehicle, 0)
    Citizen.Wait(150)
    SetVehicleLights(vehicle, 2)
    Citizen.Wait(150)
    SetVehicleLights(vehicle, 0)
end

-- Création de doubles des clés
local locksmithCoords = vector3(410.0, 320.0, 103.0) -- Coordonnées du serrurier
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - locksmithCoords)

        if distance < 10.0 then
            DrawMarker(2, locksmithCoords.x, locksmithCoords.y, locksmithCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 0, 157, 0, 100, false, true, 2, nil, nil, false)
            if distance < 2.0 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour dupliquer une clé.")
                if IsControlJustPressed(1, 38) then
                    OpenKeyCopyMenu()
                end
            end
        end

        Citizen.Wait(0)
    end
end)

function OpenKeyCopyMenu()
    ESX.TriggerServerCallback('esx_vehiclelock:getPlayerVehicles', function(vehicles)
        local elements = {}
        for _, v in ipairs(vehicles) do
            table.insert(elements, { label = "Véhicule : " .. v.plate, value = v.plate })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'key_copy_menu', {
            title = "Serrurier - Duplication de clés",
            align = 'right',
            elements = elements
        }, function(data, menu)
            TriggerServerEvent('esx_vehiclelock:copyKey', data.current.value)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end)
end
