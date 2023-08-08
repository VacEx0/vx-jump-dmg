local airThreadRunning = false

local function vehicleLanded(vehicle, time)
    local _func
    
    for minTime, func in pairs(Config.landFunctions) do
        if time >= minTime then _func = func end
    end

    if _func == nil then return end

    _func(vehicle)
end

local function startAirThread(vehicle)
    airThreadRunning = true
    CreateThread(function()
        local startTime = GetGameTimer()
        while IsEntityInAir(vehicle) do Wait(100) end
        vehicleLanded(vehicle, GetGameTimer() - startTime)
        airThreadRunning = false
    end)
end

local function isBlacklisted(vehicle)
    local vehClass = GetVehicleClass(vehicle)
    for _, class in pairs(Config.blacklistedClasses) do
        if vehClass == class then return true end
    end

    local modelHash = GetEntityModel(vehicle)
    for _, modelOrHash in pairs(Config.blacklist) do
        if modelOrHash == GetHashKey(model) or modelOrHash == modelHash then
            return true
        end
    end

    return false
end

CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle > 0 and not airThreadRunning and IsEntityInAir(vehicle) then
            if not isBlacklisted(vehicle) then startAirThread(vehicle) end
        end
    end
end)