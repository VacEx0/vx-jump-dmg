Config = {}

-- Vehicle types this script should not effect.
-- I dont recomend changing this.
Config.blacklistedClasses = {
    13, -- Cycles  
    14, -- Boats  
    15, -- Helicopters  
    16, -- Planes  
}

-- Add vehicle models or hashnames here to prevent this script from effecting them.
Config.blacklist = {
    -- 'zentorno'
}

Config.landFunctions = {
    -- The function will be fired if the vehicle is in the air for the minimum amount of time.
    -- [minimum time] = client sided function
    [7000] = function(vehicle)
        local wheels = {
            [0] = GetEntityBoneIndexByName(vehicle, 'wheel_lf'),
            [1] = GetEntityBoneIndexByName(vehicle, 'wheel_rf'),
            [2] = GetEntityBoneIndexByName(vehicle, 'wheel_lm'),
            [3] = GetEntityBoneIndexByName(vehicle, 'wheel_rm'),
            [4] = GetEntityBoneIndexByName(vehicle, 'wheel_lr'),
            [5] = GetEntityBoneIndexByName(vehicle, 'wheel_rr')
        }

        local numWheels = 0
        local groundedWheels = {}

        for wheelIndex, boneIndex in pairs(wheels) do
            local bonePos = GetEntityBonePosition_2(vehicle, boneIndex)
            
            if bonePos.x ~= 0 or bonePos.y ~= 0 or bonePos.z ~= 0 then
                local _, groundZ = GetGroundZFor_3dCoord(bonePos.x, bonePos.y, bonePos.z, false)
                local groundDistance = math.abs(bonePos.z - groundZ)

                if groundDistance <= 1.0 then
                    groundedWheels[wheelIndex] = true
                else
                    groundedWheels[wheelIndex] = false
                end

                numWheels = numWheels + 1
            end
        end

        for wheelIndex, grounded in pairs(groundedWheels) do
            if grounded then
                SetVehicleTyreBurst(vehicle, wheelIndex, true, 1000)
            else
                local curEngine = GetVehicleEngineHealth(vehicle)
                local newEngine = math.max(curEngine - (1000 / numWheels), 1)
                if newEngine < curEngine then
                    SetVehicleEngineHealth(vehicle, newEngine)
                end
            end
        end
    end,

    [10000] = function(vehicle)
        NetworkExplodeVehicle(vehicle, true, false, false)
    end,
}