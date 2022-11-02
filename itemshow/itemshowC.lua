local iShowCache = {}

local iShowState = false
local fadeTime = 1000
local showTime = 6000

localPlayer:setData("enableBubbles", true) 
localPlayer:setData("bubbleOn", false)

function showItem(data)
    local int2 = localPlayer.interior
    local dim2 = localPlayer.dimension
    
    localPlayer:setData("enableBubbles", false) 
    localPlayer:setData("bubbleOn", true)
    
    setTimer(
        function()
            localPlayer:setData("enableBubbles", true)
            localPlayer:setData("bubbleOn", false)
        end, fadeTime + showTime + fadeTime, 1
    )

    itemShowTrigger(localPlayer, localPlayer, data)

    local players = exports["cr_core"]:getNearbyPlayers("high")

    if #players >= 1 then 
        triggerLatentServerEvent("itemShowTrigger", 50000, false, localPlayer, localPlayer, players, data)
    end 
end

function itemShowTrigger(sourceElement, v, data)
    --outputChatBox(tostring(isElement(v)))
    --outputChatBox(tostring(sourceElement == localPlayer))
    iShowCache[sourceElement] = {0, data, "start", getTickCount()}
    
    local count = 0
    for k,v in pairs(iShowCache) do
        count = count + 1
    end
    
    generateRenderCache()
    generateRenderCache2()
    --outputChatBox(count)
    
    if count >= 1 then
        if not iShowState then
            --addEventHandler("onClientRender", root, drawnShowItem, true, "low-5")
            createRender("drawnShowItem", drawnShowItem)
            iShowState = true
        end
    else
        if iShowState then
            --removeEventHandler("onClientRender", root, drawnShowItem)
            destroyRender("drawnShowItem")
            iShowState = false
        end
    end
end
addEvent("itemShowTrigger", true)
addEventHandler("itemShowTrigger", root, itemShowTrigger)

animSpeed = 5
showTime = 4000
maxDistance = 18

function generateRenderCache()
    --renderCache = {}
    local px,py,pz = getElementPosition(localPlayer)
    local cameraX, cameraY, cameraZ = getCameraMatrix()
    local int2 = getElementInterior(localPlayer)
    local dim2 = getElementDimension(localPlayer)
    for k,v in pairs(iShowCache) do
        local _k = k
        local element = k
        local a, data, anim, startTick = unpack(v)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        
        if isElement(k) then
            local boneX, boneY, boneZ = getPedBonePosition(k, 5)
            boneZ = boneZ + 0.5
            if isElementOnScreen(k) then
                iShowCache[_k]["sightLine"] = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, localPlayer)
                iShowCache[_k]["distance"] = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                iShowCache[_k]["alpha"] = k.alpha >= 255
            end
        else
            --table.remove(iShowCache, _k)
            iShowCache[k] = nil
        end
    end
end
setTimer(generateRenderCache, 150, 0)

function generateRenderCache2()
    renderCache = {}
    local int2 = getElementInterior(localPlayer)
    local dim2 = getElementDimension(localPlayer)
    for k,v in pairs(iShowCache) do
        local _k = k
        local element = k
        local a, data, anim, startTick = unpack(v)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        
        local dim1 = getElementDimension(k)
        local int1 = getElementInterior(k)
        if isElement(k) and isElementStreamedIn(k) and dim1 == dim2 and int1 == int2 then
            if v["alpha"] then
                --boneZ = boneZ + 0.2
                local sightLine = v["sightLine"]
                if anames then
                    sightLine = true
                end
                if sightLine then
                    renderCache[_k] = v
                end
            end
        else
            iShowCache[k] = nil
        end
    end
end
setTimer(generateRenderCache2, 50, 0)

function drawnShowItem()
    local nowTick = getTickCount()
    --local px,py,pz = getElementPosition(localPlayer)
    for k,v in pairs(renderCache) do
        local element = k
        local a, data, anim, startTick = unpack(v)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        --outputChatBox(showTime)
        
        if not isElement(element) then
            renderCache[k] = nil
            iShowCache[k] = nil

            local count = 0
            for k,v in pairs(iShowCache) do
                count = count + 1
            end

            generateRenderCache()
            generateRenderCache2()
            --outputChatBox(count)

            if count >= 1 then
                if not iShowState then
                    --addEventHandler("onClientRender", root, drawnShowItem, true, "low-5")
                    createRender("drawnShowItem", drawnShowItem)
                    iShowState = true
                end
            else
                if iShowState then
                    --removeEventHandler("onClientRender", root, drawnShowItem)
                    destroyRender("drawnShowItem")
                    iShowState = false
                end
            end
        end
        local distance = v["distance"]
        if distance < 0 then
            distance = 0
        end
        local boneX, boneY, boneZ = getPedBonePosition(element, 5)
        --local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
        if distance < maxDistance then
            local size = 1 - (distance / maxDistance)
            --size = size + 0.1
            --outputChatBox(size)
            local sx, sy = getScreenFromWorldPosition(boneX, boneY, boneZ + (0.5 * size))
            --local specialText = getElementData(element, "specialText")
            --if specialText then
                --sx, sy = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.6)
            --end
            local veh = getPedOccupiedVehicle(element)
            if veh == localPlayer.vehicle then
                veh = nil
            end
            if veh then
                --removeText(element, text)
                renderCache[k] = nil
                iShowCache[k] = nil
            end
            --local a 
            if sx and sy and not veh then
                local sy = sy - ((40 * 2) * size)
                --local sx, sy = math.floor(sx), math.floor(sy)
                local wMultipler = 0
                if anim == "start" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + 1000) - startTick
                    local progress = elapsedTime / duration
                    local alph = interpolateBetween(
                        0, 0, 0,
                        255, 0, 0,
                        progress, "InOutQuad"
                    )

                    a = alph

                    if progress >= 1 then
                        if iShowCache[k] then
                            iShowCache[k][1] = 255
                            iShowCache[k][3] = "showing"
                            iShowCache[k][4] = getTickCount()
                        end
                    end
                    
                    wMultipler = 1
                elseif anim == "showing" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + (showTime)) - startTick
                    local progress = elapsedTime / duration
                    local alph = 255
                    
                    a = 255

                    if progress >= 1 then
                        if iShowCache[k] then
                            iShowCache[k][3] = "shading"
                            iShowCache[k][4] = getTickCount()
                        end
                    end
                    
                    wMultipler = 1 - progress
                elseif anim == "shading" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + 1000) - startTick
                    local progress = elapsedTime / duration
                    local alph = interpolateBetween(
                        255, 0, 0,
                        0, 0, 0,
                        progress, "InOutQuad"
                    )

                    a = alph

                    if progress >= 1 then
                        a = 0
                        if iShowCache[k] then
                            iShowCache[k][1] = 0
                            iShowCache[k][3] = "normal"
                        end
                        renderCache[k] = nil
                        iShowCache[k] = nil
                        
                        local count = 0
                        for k,v in pairs(iShowCache) do
                            count = count + 1
                        end

                        generateRenderCache()
                        generateRenderCache2()
                        --outputChatBox(count)

                        if count >= 1 then
                            if not iShowState then
                                --addEventHandler("onClientRender", root, drawnShowItem, true, "low-5")
                                createRender("drawnShowItem", drawnShowItem)
                                iShowState = true
                            end
                        else
                            if iShowState then
                                --removeEventHandler("onClientRender", root, drawnShowItem)
                                destroyRender("drawnShowItem")
                                iShowState = false
                            end
                        end
                        --removeText(element, text)
                    end
                end
                local alpha = a
                
                local c = 50 * size
                local b = 45 * size
                dxDrawRectangle(sx - c/2, sy - c/2, c, c, tocolor(51, 51, 51, alpha * 0.8))

                local itemAlpha = alpha 

                if status < 100 then 
                    if GetData(itemid, value, nbt, "food") or GetData(itemid, value, nbt, "drink") then 
                        itemAlpha = alpha * (status / 100)
                        dxDrawImage(sx - b/2, sy - b/2, b, b, getItemGreyPNG(itemid, value, nbt, status, alpha))
                    elseif status == 0 and isWeapon(itemid, value, nbt) then 
                        itemAlpha = alpha * (status / 100)
                        dxDrawImage(sx - b/2, sy - b/2, b, b, getItemGreyPNG(itemid, value, nbt, status, alpha))
                    end 
                end 

                dxDrawImage(sx - b/2, sy - b/2, b, b, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,itemAlpha))
                
                local data = fromJSON(toJSON(data))
                data["size"] = size
                
                local startY = sy - c
                renderTooltip(sx, startY, data, math.min(alpha, 255 * 0.75))
            end
        end
    end
end

addEventHandler("onClientPlayerQuit", root,
    function()
        if iShowCache[source] then
            iShowCache[source] = nil
        end
    end
)