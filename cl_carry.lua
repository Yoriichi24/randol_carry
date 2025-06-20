local plyState = LocalPlayer.state

local function carryingLoop(id)
    if plyState.isCarrying then return end

    local anim, dict = 'fin_c2_mcs_1_camman', 'missfinale_c2mcs_1'

    Wait(0) -- magic wait(0)?

    while plyState.isCarrying do
        local player = GetPlayerFromServerId(id)
        local ped = player > 0 and GetPlayerPed(player)
        if not ped then break end

        if not IsEntityPlayingAnim(cache.ped, dict, anim, 3) then
            lib.playAnim(cache.ped, dict, anim, 8.0, -8.0, -1, 49, 0.0, false, false, false)
        end

        Wait(100)
    end

    DetachEntity(cache.ped, true, false)
    StopAnimTask(cache.ped, dict, anim, 2.5)
    plyState:set('isCarrying', nil, true)
end

local function beingCarriedLoop(id)
    if plyState.beingCarried then return end

    local anim, dict = 'firemans_carry', 'nm'

    Wait(0) -- magic wait(0)?

    while plyState.beingCarried do
        local player = GetPlayerFromServerId(id)
        local ped = player > 0 and GetPlayerPed(player)

        if not ped then break end

        if not IsEntityAttachedToEntity(cache.ped, ped) then
            AttachEntityToEntity(cache.ped, ped, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 180, false, false, false, false, 2, false)
        end

        if not IsEntityPlayingAnim(cache.ped, dict, anim, 3) then
            lib.playAnim(cache.ped, dict, anim, 8.0, -8.0, -1, 33, 0.0, false, false, false)
        end

        Wait(100)
    end
    
    DetachEntity(cache.ped, true, false)
    StopAnimTask(cache.ped, dict, anim, 2.5)
    plyState:set('beingCarried', nil, true)
end

exports.ox_target:addGlobalPlayer({
    name = 'carry',
    distance = 1.5,
    label = 'Carry',
    icon = 'fas fa-hand-holding',
    onSelect = function(data)
        TriggerServerEvent('randol_carry:attemptCarry')
    end,
})

local cancelCarryKeybind = lib.addKeybind({
    name = 'cancelCarry',
    description = 'Cancelar Carry',
    defaultKey = 'X',
    onPressed = function(self)
        TriggerServerEvent('randol_carry:cancelCarry')
    end,
})


lib.onCache('vehicle', function(newVehicle, oldVehicle)
    local ped = PlayerPedId()

    -- If player just got into a vehicle
    if newVehicle and newVehicle ~= 0 then
        -- Check if ped is on a bike/motorcycle
        if IsPedOnAnyBike(ped) then
            TriggerServerEvent('randol_carry:cancelCarry')
        end
    end
end)

AddStateBagChangeHandler('isCarrying', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value then carryingLoop(value) end
end)

AddStateBagChangeHandler('beingCarried', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value then beingCarriedLoop(value) end
end)
