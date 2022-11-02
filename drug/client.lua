local screenX, screenY = guiGetScreenSize()

local drugEffectCache = {}

local function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle)
 
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
 
    return x + dx, y + dy
end

local function spawnRandomNPCs()
    for k, v in pairs(drugEffectCache.elementCache) do 
        if isElement(k) then 
            k:destroy()
        end
    end

    if drugEffectCache.fadeQueue then 
        for k, v in pairs(drugEffectCache.fadeQueue) do 
            if isElement(v.effectElement) then 
                v.effectElement:destroy()
                v.effectElement = nil
            end
        end
    end

    drugEffectCache.elementCache = {}
    drugEffectCache.fadeQueue = {}

    local randomElementCount = 30
    local playerPosition = localPlayer.position
    local interior, dimension = localPlayer.interior, localPlayer.dimension
    local availableSkins = {205, 196, 197, 199}

    for i = 1, randomElementCount do 
        local x, y = getPointFromDistanceRotation(playerPosition.x, playerPosition.y, 5, 360 * (i / randomElementCount))
        local pedElement = Ped(availableSkins[math.random(1, #availableSkins)], x, y, playerPosition.z)

        pedElement.interior = interior
        pedElement.dimension = dimension
        pedElement.frozen = true

        drugEffectCache.elementCache[pedElement] = 0
    end
end

local availableDrugEffects = {
    weed = function(state)
        if state then 
            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            localPlayer.armor = math.min(100, localPlayer.armor + 5)

            drugEffectCache = {
                screenSource = dxCreateScreenSource(screenX, screenY),
                drugTimer = false,

                level = 100,
                value = 0,

                animationState = false,
                currentEffect = "weed",
                startTick = getTickCount()
            }

            drugEffectCache.oldData = {}
            drugEffectCache.oldData.chat = exports["cr_custom-chat"]:isChatVisible()
            drugEffectCache.oldData.keys = localPlayer:getData("keysDenied")
            drugEffectCache.oldData.hud = localPlayer:getData("hudVisible")
            drugEffectCache.oldData.gameSpeed = getGameSpeed()

            exports["cr_custom-chat"]:showChat(false)
            localPlayer:setData("keysDenied", true)
            localPlayer:setData("hudVisible", false)

            if isElement(drugEffectCache.screenSource) then 
                dxSetTextureEdge(drugEffectCache.screenSource, "mirror")
            end

            setGameSpeed(0.5)

            exports["cr_custom-chat"]:showChat(false)
            drugEffectCache.drugTimer = setTimer(processDrugEffect, 3 * 60000, 1, "weed", false)

            createRender("renderDrugEffect", renderDrugEffect)
            addEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        else
            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            if isElement(drugEffectCache.screenSource) then 
                drugEffectCache.screenSource:destroy()
                drugEffectCache.screenSource = nil
            end

            setGameSpeed(drugEffectCache.oldData.gameSpeed)

            exports["cr_custom-chat"]:showChat(drugEffectCache.oldData.chat)
            localPlayer:setData("keysDenied", drugEffectCache.oldData.keys)
            localPlayer:setData("hudVisible", drugEffectCache.oldData.hud)

            drugEffectCache = {}
            destroyRender("renderDrugEffect")

            removeEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        end
    end,

    kokain = function(state)
        if state then 
            localPlayer.armor = math.min(100, localPlayer.armor + 8)

            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            if isTimer(drugEffectCache.npcSpawnTimer) then 
                killTimer(drugEffectCache.npcSpawnTimer)
                drugEffectCache.npcSpawnTimer = nil
            end

            if isTimer(drugEffectCache.customYawTimer) then 
                killTimer(drugEffectCache.customYawTimer)
                drugEffectCache.customYawTimer = nil
            end

            if isElement(drugEffectCache.soundElement) then 
                drugEffectCache.soundElement:destroy()
                drugEffectCache.soundElement = nil 
            end

            drugEffectCache = {}

            drugEffectCache.oldData = {}
            drugEffectCache.oldData.chat = exports["cr_custom-chat"]:isChatVisible()
            drugEffectCache.oldData.keys = localPlayer:getData("keysDenied")
            drugEffectCache.oldData.hud = localPlayer:getData("hudVisible")
            drugEffectCache.oldData.skyGradient = {getSkyGradient()}
            drugEffectCache.oldData.gameSpeed = getGameSpeed()
            drugEffectCache.elementCache = {}
            drugEffectCache.fadeQueue = {}
            drugEffectCache.currentEffect = "kokain"

            drugEffectCache.drugTimer = setTimer(processDrugEffect, 2 * 60000, 1, "kokain", false)
            drugEffectCache.npcSpawnTimer = setTimer(spawnRandomNPCs, 5000, 0)

            drugEffectCache.soundElement = playSound("assets/sounds/drugeffect.mp3", true)
            -- spawnRandomNPCs()

            drugEffectCache.customYawTimer = setTimer(
                function()
                    for k, v in pairs(drugEffectCache.elementCache) do 
                        if isElement(k) then 
                            drugEffectCache.elementCache[k] = drugEffectCache.elementCache[k] + 20
                        end
                    end
                end, 80, 0
            )

            setGameSpeed(1.5)
            setSkyGradient(255, 50, 255, 255, 50, 255)

            addEventHandler("onClientPedsProcessed", root, onPedsProcessed)
            addEventHandler("onClientPedDamage", root, onPedDamage)

            createRender("renderDrugEffect", renderDrugEffect)
            addEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        else
            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            if isTimer(drugEffectCache.npcSpawnTimer) then 
                killTimer(drugEffectCache.npcSpawnTimer)
                drugEffectCache.npcSpawnTimer = nil
            end

            if isTimer(drugEffectCache.customYawTimer) then 
                killTimer(drugEffectCache.customYawTimer)
                drugEffectCache.customYawTimer = nil
            end

            if isElement(drugEffectCache.soundElement) then 
                drugEffectCache.soundElement:destroy()
                drugEffectCache.soundElement = nil 
            end

            for k, v in pairs(drugEffectCache.elementCache) do 
                if isElement(k) then 
                    k:destroy()
                end
            end

            for k, v in pairs(drugEffectCache.fadeQueue) do 
                if isElement(v.effectElement) then 
                    v.effectElement:destroy()
                    v.effectElement = nil
                end
            end

            setGameSpeed(drugEffectCache.oldData.gameSpeed)
            setSkyGradient(unpack(drugEffectCache.oldData.skyGradient))

            exports["cr_custom-chat"]:showChat(drugEffectCache.oldData.chat)
            localPlayer:setData("keysDenied", drugEffectCache.oldData.keys)
            localPlayer:setData("hudVisible", drugEffectCache.oldData.hud)

            drugEffectCache = {}
            destroyRender("renderDrugEffect")

            removeEventHandler("onClientPedsProcessed", root, onPedsProcessed)
            removeEventHandler("onClientPedDamage", root, onPedDamage)
            removeEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        end
    end,

    heroin = function(state)
        if state then 
            localPlayer.armor = math.min(100, localPlayer.armor + 10)

            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            if isTimer(drugEffectCache.drugEffectChangeTimer) then 
                killTimer(drugEffectCache.drugEffectChangeTimer)
                drugEffectCache.drugEffectChangeTimer = nil
            end

            drugEffectCache.oldData = {}
            drugEffectCache.oldData.chat = exports["cr_custom-chat"]:isChatVisible()
            drugEffectCache.oldData.keys = localPlayer:getData("keysDenied")
            drugEffectCache.oldData.hud = localPlayer:getData("hudVisible")
            drugEffectCache.oldData.gameSpeed = getGameSpeed()
            drugEffectCache.currentEffect = "heroin"

            exports["cr_custom-chat"]:showChat(false)
            localPlayer:setData("keysDenied", true)
            localPlayer:setData("hudVisible", false)

            setGameSpeed(0.4)
            setCameraGoggleEffect("thermalvision", false)

            drugEffectCache.drugTimer = setTimer(processDrugEffect, 60000, 1, "heroin", false)

            drugEffectCache.drugEffectChangeTimer = setTimer(
                function()
                    local cameraGoggleEffect = getCameraGoggleEffect()
                    local currentEffect = cameraGoggleEffect == "thermalvision" and "nightvision" or "thermalvision"
                    
                    setCameraGoggleEffect(currentEffect, false)
                end, 50, 0
            )

            addEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        else
            if isTimer(drugEffectCache.drugTimer) then 
                killTimer(drugEffectCache.drugTimer)
                drugEffectCache.drugTimer = nil
            end

            if isTimer(drugEffectCache.drugEffectChangeTimer) then 
                killTimer(drugEffectCache.drugEffectChangeTimer)
                drugEffectCache.drugEffectChangeTimer = nil
            end

            exports["cr_custom-chat"]:showChat(drugEffectCache.oldData.chat)
            localPlayer:setData("keysDenied", drugEffectCache.oldData.keys)
            localPlayer:setData("hudVisible", drugEffectCache.oldData.hud)

            setGameSpeed(drugEffectCache.oldData.gameSpeed)
            setCameraGoggleEffect("normal")

            drugEffectCache = {}
            destroyRender("renderDrugEffect")

            removeEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
        end
    end
}

function processDrugEffect(effect, state)
    if availableDrugEffects[effect] then 
        if type(availableDrugEffects[effect]) == "function" then 
            local drugEffectHandler = availableDrugEffects[effect]

            drugEffectHandler(state)
        end
    end
end

function renderDrugEffect()
    local nowTick = getTickCount()

    if drugEffectCache.currentEffect == "weed" then 
        local elapsedTime = nowTick - drugEffectCache.startTick
        local duration = 3000
        local progress = elapsedTime / duration

        if isElement(drugEffectCache.screenSource) then 
            dxUpdateScreenSource(drugEffectCache.screenSource)
        end

        if not drugEffectCache.animationState then 
            drugEffectCache.value = interpolateBetween(0, 0, 0, drugEffectCache.level, 0, 0, progress, "InOutQuad")

            if progress >= 1 then 
                drugEffectCache.animationState = true
                drugEffectCache.startTick = getTickCount()
            end
        else
            drugEffectCache.value = interpolateBetween(drugEffectCache.level, 0, 0, 0, 0, 0, progress, "InOutQuad")

            if progress >= 1 then 
                drugEffectCache.animationState = false
                drugEffectCache.startTick = getTickCount()
            end
        end

        dxDrawImageSection(0, 0, screenX, screenY, drugEffectCache.value, drugEffectCache.value, screenX, screenY, drugEffectCache.screenSource, 0, 0, 0, tocolor(255, 255, 255))
        dxDrawImageSection(0, 0, screenX, screenY, -drugEffectCache.value, -drugEffectCache.value, screenX, screenY, drugEffectCache.screenSource, 0, 0, 0, tocolor(255, 255, 255, 100))
    elseif drugEffectCache.currentEffect == "kokain" then
        if drugEffectCache.fadeQueue then 
            for k, v in pairs(drugEffectCache.fadeQueue) do 
                if isElement(k) then 
                    local elapsedTime = nowTick - v.startTick
                    local duration = 500
                    local progress = elapsedTime / duration

                    local val = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "InOutQuad")

                    setElementAlpha(k, val)

                    if progress >= 1 then 
                        k:destroy()

                        if isElement(v.effectElement) then 
                            v.effectElement:destroy()
                            v.effectElement = nil
                        end

                        drugEffectCache.elementCache[k] = nil
                        drugEffectCache.fadeQueue[k] = nil
                    end
                end
            end
        end
    end
end

function onPedsProcessed()
    if drugEffectCache.elementCache then 
        for k, v in pairs(drugEffectCache.elementCache) do 
            if isElement(k) then 
                local yaw, pitch, roll = getElementBoneRotation(k, 2)
                
                pitch = tonumber(pitch) or 0
                roll = tonumber(roll) or 0

                setElementBoneRotation(k, 2, v, pitch, roll)

                for k2, v2 in pairs({22, 32}) do 
                    setElementBoneRotation(k, v2, 0, 0, 0)
                end

                updateElementRpHAnim(k)
            end
        end
    end
end

function onPedDamage()
    if drugEffectCache.elementCache[source] then 
        if not drugEffectCache.fadeQueue[source] then 
            drugEffectCache.fadeQueue[source] = {startTick = getTickCount()}

            local effectElement = createEffect("prt_collisionsmoke", source.position)
            effectElement.interior = source.interior
            effectElement.dimension = source.dimension

            drugEffectCache.fadeQueue[source].effectElement = effectElement
        end
    end
end

function onClientWasted()
    if drugEffectCache and drugEffectCache.currentEffect then 
        processDrugEffect(drugEffectCache.currentEffect, false)
    end
end