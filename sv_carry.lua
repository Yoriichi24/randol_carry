local function DoNotification(src, text, nType)
    lib.notify(src, { title = 'Notification', description = text, duration = 5000, type = nType, position = 'center-right'})
end

local function getClosestServerPlayer(coords, src)
    local players = GetActivePlayers()
    local closestId, closestPed, closestCoords
    local maxDistance = 1.5

    for i = 1, #players do
        local playerId = players[i]

        if playerId ~= src then
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(coords - playerCoords)

            if distance < maxDistance then
                maxDistance = distance
                closestId = playerId
                closestPed = playerPed
                closestCoords = playerCoords
            end
        end
    end

    return closestId, closestPed, closestCoords
end

lib.addCommand('carry', {
    help = 'Carry a nearby player.',
}, function(source, args)
    local src = source
    local ped = GetPlayerPed(src)
    local plyState = Player(src).state

    if plyState.beingCarried then
        return DoNotification(src, 'You cannot do this while being carried.', 'error')
    end

    if plyState.isCarrying then
        local targetId = plyState.isCarrying
        plyState:set('isCarrying', nil, true)
        Player(targetId).state:set('beingCarried', nil, true)
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local id, targetPed = getClosestServerPlayer(coords, src)

    if not id then
        return DoNotification(src, 'No player nearby', 'error')
    end

    if GetVehiclePedIsIn(ped, false) ~= 0 then
        return DoNotification(src, 'You cannot carry in vehicles.', 'error')
    end

    if GetVehiclePedIsIn(targetPed, false) ~= 0 then
        return DoNotification(src, 'You cannot carry players that are in vehicles.', 'error')
    end

    local targetState = Player(id).state

    if targetState.beingCarried or targetState.isCarrying then
        return DoNotification(src, 'Target is carrying or being carried already.', 'error')
    end

    plyState:set('isCarrying', id, true)
    targetState:set('beingCarried', src, true)
end)