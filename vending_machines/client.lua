local start, startTick

local objects = {
    --[ID] = itemID,
    [955] = 7,
    [1775] = 7,
    [1776] = 6,
    [956] = 6,
    [2443] = 7,
    [1340] = 1,
    [1341] = 2,
}

local offsets = {
    [955] = {0, -0.75, -0.5},
    [1775] = {0, -0.75, -0.5},
    [1776] = {0, -0.75, -0.5},
    [956] = {0, -0.75, -0.5},
    [2443] = {0, -0.75, -0.5},
    [1340] = {1, 0, -1},
    [1341] = {1, -0.5, -1},
}

local costs = {
    --[ItemID] = money
    [1] = 2,
    [7] = 3,
    [2] = 4,
    [6] = 1,
}

local cache = {}
local itemid, itemName, state
local lastCheckTick = -500

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("object")) do
            if objects[v.model] then
                local x, y, z = getElementPosition(v) 
                v.collisions = true
                local rot = v.rotation.z
                local vMatrix = Matrix(x,y,z, 0, 0, rot)
                local pos = vMatrix:transformPosition(unpack(offsets[v.model]))
                local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(v)
                
                local marker = Marker(pos, "cylinder", 0.8, 225, 225, 80, 180);
                attachElements(marker, v, unpack(offsets[v.model]))
                marker.alpha = 0
                marker.dimension = v.dimension ~= -1 and v.dimension or 0
                marker.interior = v.interior
                --localPlayer.position = marker.position
                cache[marker] = v
            end
        end
    end
)

addEventHandler("onClientMarkerHit", root,
    function(thePlayer, matchingDimension)
        if matchingDimension and thePlayer == localPlayer then 
            --outputChatBox(tostring(cache[source]))
            if cache[source] then
                local x,y,z = getElementPosition(source)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                if dist <= 2 then
                    if not start then
                        local obj = cache[source]
                        local modelID = obj.model
                        itemid = objects[modelID]
                        itemName = getItemName(itemid)
                        cost = costs[itemid]
                        playSound(":cr_skinshop/files/pep.mp3")
                        sourceCol = source

                        local colorCode = '#ff3b3b'
                        local colorCode2 = exports['cr_core']:getServerColor("green", true)
                        local colorCode3 = exports['cr_core']:getServerColor("yellow", true)
                        local white = "#f2f2f2"
                        
                        local text = white.."Egy "..colorCode3.."'"..itemName.."'"..white.." vásárlásához használd az ["..colorCode.."E"..white.."] billentyűt! ["..colorCode2.."$"..cost..white.."]"

                        exports['cr_dx']:startInfoBar(text)
                        start = true

                        bindKey("E", "down", doingShopping)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientMarkerLeave", root,
    function(thePlayer, matchingDimension)
        if matchingDimension and thePlayer == localPlayer then 
            --outputChatBox(tostring(cache[source]))
            if start then
                start = false 
                
                exports['cr_dx']:closeInfoBar()

                unbindKey("E", "down", doingShopping)
            end
        end
    end
)

function doingShopping()
    if not start then return end
    
    local a = 5
    local now = getTickCount()
    if now <= lastCheckTick + a * 1000 then
        return
    end
    lastCheckTick = now
    
    if exports['cr_network']:getNetworkStatus() then return end
    
    if exports['cr_core']:takeMoney(localPlayer, cost, false) then
        local colorCode = exports['cr_core']:getServerColor("yellow", true)
        local white = "#e5e5e5"
        if isElementHasSpace(localPlayer, nil, itemid, 1, 1, 1) then
            giveItem(localPlayer, itemid, 1, 1, 100, 0, 0, 0)
            exports['cr_infobox']:addBox("success", "Sikeresen vásároltál egy "..colorCode..itemName..white.."-t")
        else
            exports['cr_infobox']:addBox("error", "Nincs elég hely az inventorydban!")
        end    
    else
        exports['cr_infobox']:addBox("error", "Nincs elég pénzed")
    end
end