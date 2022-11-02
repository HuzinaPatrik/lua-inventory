_addCommandHandler = addCommandHandler
localPlayer:setData("enabledInventory", true)
local lastItem = 0
local realWeight = 0
invElement = localPlayer
local disableThisInt = {
    ["count"] = true,
}
firstLoad = false
oMoveInteractState = false

addEvent("returnValue", true)
addEventHandler("returnValue", root,
    function(sourceElement, rtype, args)
        if source and source == localPlayer then
            if sourceElement and sourceElement == localPlayer then
                if rtype == "items" then
                    local neededElement = args[1]

                    if not invElement then
                        invElement = neededElement
                    end

                    local eType = getEType(neededElement)
                    local eId = getEID(neededElement)
                    local items = args[2]
                    checkTableArray(eType, eId)

                    cache[eType][eId] = items

                    if isTimer(clickTimer) then killTimer(clickTimer) end

                    if invType then
                        weightAnimationStart = realWeight or 0
                        fullWeight = getWeight(invElement, invType)
                        weightAnimation = true
                        weightAnimationTick = getTickCount()
                    end

                    if not disableThisInt[args[3]] then
                        if state then
                            cancelMove()
                        end
                    end

                    if not firstLoad then
                        attachWeapons()
                        firstLoad = true
                    end

                    moveInteractDisabled = oMoveInteractState
                end
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if localPlayer:getData("loggedIn") then
            if getElementData(root, "loaded") then
                triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                startStateTimer()
            end
        end
    end
)

isInventoryDisabled = false
inAnim = localPlayer:getData("inAnim")

function checkIsInventoryDisabled()
    local cuffed = localPlayer:getData("char >> cuffed")
    local tazed = localPlayer:getData("char >> tazed")
    local jailed = localPlayer:getData("char >> ajail")
    inAnim = localPlayer:getData("inAnim")
    local inventoryForceDisabled = localPlayer:getData("inv >> forceDisabled")
    local tbl = localPlayer:getData("job >> data") or {}
    
    local woodInHand = localPlayer:getData('lumberjack >> objInHand')
    local wineInHand = localPlayer:getData('winemaker >> objInHand')
    local pizzaInHand = localPlayer:getData('pizza >> objInHand')
    local hotdogInHand = localPlayer:getData('hotdog >> objInHand')

    if cuffed or tazed or jailed or inventoryForceDisabled or tbl["rockInHand"] or tbl["bagInHand"] or inAnim or woodInHand or wineInHand or pizzaInHand or hotdogInHand then
        isInventoryDisabled = true
    else
        isInventoryDisabled = false
    end
end
checkIsInventoryDisabled()

function removeItemFromSlot(iType, slot, checkCount)
    if checkCount then 
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[1][accID][iType][slot])
        if count - checkCount <= 0 then
            cancelMove(5)
            cache[1][accID][iType][slot] = nil
            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, iType)
        else
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, iType, count - checkCount)
        end
    else 
        cancelMove(5)
        cache[1][accID][iType][slot] = nil
        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, iType)
    end 
end 

function startStateTimer()
    if isTimer(stateTimer) then killTimer(stateTimer) end
    stateTimer = setTimer(
        function()
            local playerItems = getItems(localPlayer, 1)
            local playerItems2 = getItems(localPlayer, 2)
            local isBankTicket = false

            for slot, data in pairs(playerItems2) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                if itemid == 128 then
                    if tonumber(value["timestamp"]) < getRealTime()["timestamp"] then
                        cancelMove(5)
                        cache[1][accID][2][slot] = nil
                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 2)
                        exports['cr_core']:takeMoney(localPlayer, value["penalty"] * 2, nil, true)
                        isBankTicket = true
                    end
                end
            end

            for slot, data in pairs(playerItems) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if GetData(itemid, value, nbt, "isStatus") and not GetData(itemid, value, nbt, "isWeapon") and not GetData(itemid, value, nbt, "disabledStatusInteract") then
                    if status - 1 >= 0 then
                        status = status - 1
                        cache[1][accID][1][slot][5] = status
                        triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, status)
                    end
                end
            end

            if isBankTicket then
                exports['cr_infobox']:addBox("warning", "Mivel nem fizetted be időben a csekkeidet, ezért azoknak a 200%-a lett levonva!")
            end
        end, 10 * 60 * 1000, 0
    )
end

local defendedNums = {
    [16] = 1,
    [17] = {10, 11, 12},
}
_addCommandHandler("tuneradio", 
    function(cmd, num)
        if localPlayer:getData("usingRadio") then 
            num = tonumber(num)
            if not num or not tonumber(num) or tonumber(num) <= 0 then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
                outputChatBox(syntax .. "/" .. cmd .. " [Új frekvencia]", 255, 255, 255, true)
                return 
            end 

            local hasPerm = false 
            if defendedNums[num] then 
                if type(defendedNums[num]) == "number" then 
                    hasPerm = exports['cr_dashboard']:isPlayerInFaction(localPlayer, defendedNums[num])
                elseif type(defendedNums[num]) == "table" then 
                    for k,v in pairs(defendedNums[num]) do 
                        if exports['cr_dashboard']:isPlayerInFaction(localPlayer, v) then 
                            hasPerm = true 
                            break
                        end 
                    end 
                end 
            else 
                hasPerm = true 
            end 

            if hasPerm then 
                localPlayer:setData("usingRadio.frekv", num)
                exports['cr_chat']:createMessage(localPlayer, "átállítja a rádió frekvenciáját", 1)
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem rendelkezel a megfelelő jogosultságokkal ennek a frekvenciának a használatához!", 255, 255, 255, true)
                return 
            end 
        end 
    end 
)

keysDenied = localPlayer:getData('keysDenied')
enabledInventory = localPlayer:getData('enabledInventory')

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "usingRadio.frekv" then
            if localPlayer:getData("usingRadio") then
                local slot = tonumber(localPlayer:getData("usingRadio.slot"))
                local value = tonumber(localPlayer:getData("usingRadio.frekv"))

                updateItemDetails(localPlayer, slot, 1, {"value", value}, true)
                cache[1][accID][1][slot][3] = value
            end
        elseif dName == "loggedIn" then
            local value = source:getData(dName)
            if value then
                if getElementData(root, "loaded") then
                    triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                    startStateTimer()
                end
            end
        elseif dName == "char >> cuffed" then
            local value = source:getData(dName)
            checkIsInventoryDisabled()
            if value then
                hideWeapon()
            end
        elseif dName == "char >> tazed" then
            local value = source:getData(dName)
            checkIsInventoryDisabled()
            if value then
                hideWeapon()
            end
        elseif dName == "char >> ajail" then
            local value = source:getData(dName)
            checkIsInventoryDisabled()
            if value then
                hideWeapon()
            end
        elseif dName == "inAnim" then 
            local value = source:getData(dName)
            checkIsInventoryDisabled()
            if value then
                hideWeapon()
            end
        elseif dName == "job >> data" then
            local value = source:getData(dName) or {}
            checkIsInventoryDisabled()
            if value["rockInHand"] or value["bagInHand"] then
                hideWeapon()
            end
        elseif dName == "inv >> forceDisabled" then
            local value = source:getData(dName)
            checkIsInventoryDisabled()
            if value then
                hideWeapon()
            end
        elseif dName == "char >> death" then
            local value = source:getData(dName)
            charDeath = value
        elseif dName == "inDeath" then
            local value = source:getData(dName)
            inDeath = value
        elseif dName == "acc >> id" then
            local value = source:getData(dName)
            accID = value
        elseif dName == "interface.drawn" then
            local value = source:getData(dName)
            interfaceDrawn = value
        elseif dName == 'keysDenied' then 
            local value = source:getData(dName)
            keysDenied = value
        elseif dName == 'enabledInventory' then 
            local value = source:getData(dName)
            enabledInventory = value
        end
    end
)

charDeath = localPlayer:getData("char >> death")
inDeath = localPlayer:getData("inDeath")
accID = localPlayer:getData("acc >> id")
interfaceDrawn = localPlayer:getData("interface.drawn")

setTimer(
    function()
        if invElement then
            if invElement.type == "vehicle" then
                if invType == specTypes["vehicle.in"] then
                    local val = invElement:getData("inventory.open2")
                    if not val then
                        invElement:setData("inventory.open2", localPlayer)
                    end
                else 
                    local val = invElement:getData("inventory.open")
                    if not val then
                        invElement:setData("inventory.open", localPlayer)
                    end
                end
            elseif invElement.type == "object" then
                local val = invElement:getData("inventory.open")
                if not val then
                    invElement:setData("inventory.open", localPlayer)
                end
            end
        end
    end, 50, 0
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "inventory.open2" then
            if source == invElement then
                local value = source:getData(dName)
                if value then
                    if oValue then
                        if val ~= oValue then
                            if localPlayer == val then
                                closeInventory()
                            end
                        end
                    end
                end
            end
        elseif dName == "inventory.open" then
            if source == invElement then
                local value = source:getData(dName)
                if value then
                    if oValue then
                        if val ~= oValue then
                            if localPlayer == val then
                                closeInventory()
                            end
                        end
                    end
                end
            end
        elseif dName == "loaded" then
            local value = getElementData(root, "loaded")
            if value then
                if localPlayer:getData("loggedIn") then
                    triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                    startStateTimer()
                end
            end
        end
    end
)

lastOpenTick = 0
lastClickTick = 0

bindKey("I", "down",
    function()
        if not getElementData(root, "loaded") then return end
        if getElementData(localPlayer, "score >> bar") then return end
        if exports['cr_network']:getNetworkStatus() then return end

        if localPlayer:getData("loggedIn") then
            state = not state
            if state then
                lastOpenTick = getTickCount()

                openInventory(localPlayer)
            else
                lastOpenTick = getTickCount()
                closeInventory(localPlayer)
            end
        end
    end
)

function showInventory(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "showinventory") then
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
            return
        end

        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if target then
            if not target:getData("loggedIn") then
                local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
                outputChatBox(syntax .. "A célpont nincs bejelentkezve!")
                return
            end
            state = true
            openInventory(target, true)
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Nincs ilyen játékos",255,255,255,true)
        end
    end
end
_addCommandHandler("showinv", showInventory)
_addCommandHandler("showInv", showInventory)
_addCommandHandler("showinventory", showInventory)
_addCommandHandler("showInventory", showInventory)

invType = 1

function cancelMove(typ, i)
    if not typ then typ = 1 end
    if typ == 1 then
        if moveState then
            moveState = false
            playSound("assets/sounds/move.mp3")
            if stacking then
                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                stacking = false
            end
            local moveSlot = moveSlot
            if tonumber(i) then
                moveSlot = tonumber(i)
            end
            cache[elementType][elementID][invType][moveSlot] = moveDetails
            moveDetails = nil
        end

        if craftMoveState then
            craftMoveState = false
            playSound("assets/sounds/move.mp3")
            local moveSlot = moveSlot
            if tonumber(i) then
                moveSlot = tonumber(i)
            end
            cache[1][accID][10][moveSlot] = moveDetails
            moveDetails = nil
        end
    elseif typ == 2 then
        if moveState then
            moveState = false
            playSound("assets/sounds/move.mp3")
            if stacking then
                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                stacking = false
            end
            local oSlotData2 = cache[elementType][elementID][invType][i]
            cache[elementType][elementID][invType][i] = moveDetails
            cache[elementType][elementID][invType][moveSlot] = oSlotData2
            local oSlotData = moveDetails
            moveDetails = nil

            return oSlotData, oSlotData2
        end

        if craftMoveState then
            craftMoveState = false
            playSound("assets/sounds/move.mp3")
            local oSlotData2 = cache[1][accID][10][i]
            cache[1][accID][10][i] = moveDetails
            cache[1][accID][10][moveSlot] = oSlotData2
            local oSlotData = moveDetails
            moveDetails = nil

            return oSlotData, oSlotData2
        end
    elseif typ == 3 then
        if moveState then
            moveState = false
            playSound("assets/sounds/move.mp3")
            cache[elementType][elementID][invType][moveSlot] = nil
            moveDetails = nil
            stacking = false
        end

        if craftMoveState then
            craftMoveState = false
            playSound("assets/sounds/move.mp3")
            cache[1][accID][10][moveSlot] = nil
            moveDetails = nil
            stacking = false
        end
    elseif typ == 4 then
        if moveState then
            moveState = false
            stacking = false
            moveDetails = nil
        end

        if craftMoveState then
            craftMoveState = false
            stacking = false
            moveDetails = nil
        end
    elseif typ == 5 then
        oMoveInteractState = moveInteractDisabled
        moveInteractDisabled = true
    end
end

function openInventory(e, spec, def)
    if def then
        state = true
    end

    if charDeath or inDeath then 
        return 
    end

    if e == localPlayer then
        if not localPlayer:getData("enabledInventory") then 
            return 
        end
    end 

    if localPlayer:getData("keysDenied") then 
        return 
    end

    if invElement and invElement.type == "vehicle" then
        if invType == specTypes["vehicle.in"] then
            setElementData(invElement, "inventory.open2", false)
        else
            setElementData(invElement, "inventory.open", false)
        end
    elseif invElement and invElement.type == "object" then
        setElementData(invElement, "inventory.open", false)
    end

    scrolling = false

    invElement = e
    elementID = getEID(e)
    elementType = getEType(e)

    alpha = 0
    multipler = 20
    lastItem = 0

    if specTypes[e.type] then
        invType = specTypes[e.type]
    else
        if invType >= 5 then
            invType = 1
        end
    end

    checkTableArray(elementID, elementType, invType)

    cancelMove()

    if spec then 
        oMoveInteractState = spec
    end
    moveInteractDisabled = spec

    if isCrafting then 
        invType = 5
        moveInteractDisabled = true
    end

    start = true
    startTick = getTickCount()
    exports['cr_interface']:setNode("Inventory", "active", true)

    x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    --addEventHandler("onClientRender", root, drawnInventory, true, "low-5")
    createRender("drawnInventory", drawnInventory)
    CreateNewBar("stack", {x + 10, y + 10, 55, 20}, {4, "", true, tocolor(255,255,255,255), {"Poppins-Regular", 10}, 1, "center", "center"}, 1)

    if e ~= localPlayer then
        triggerServerEvent("needValue", localPlayer, localPlayer, "items", e)
    end

    fullWeight = getWeight(invElement, invType)
    weightAnimation = false
    realWeight = 0
end

function closeInventory(e)
    if start then
        start = false
        startTick = getTickCount()
    end
end

local function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+1,w,h+1,color,fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x,y-1,w,h-1,color,fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x-1,y,w-1,h,color,fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x+1,y,w+1,h,color,fontsize,font,aligX,alignY, false, false, false, true);
end

cminLines, cmaxLines = 1, 10
gdata = {}

function drawnInventory()
    if charDeath or inDeath then
        cancelMove()
        if start then
            start = false
            startTick = getTickCount()
        end
    end

    if exports['cr_network']:getNetworkStatus() then
        cancelMove()
    end

    if isElement(invElement) then
        if invElement.type ~= "player" then
            if getDistanceBetweenPoints3D(invElement.position, localPlayer.position) > (invElement.type == "vehicle" and 5 or 3) then
                cancelMove()
                if start then
                    start = false
                    startTick = getTickCount()
                end
            end

            if invElement.type == "vehicle" then
                if not invElement:getData("veh >> boot") and invType == specTypes["vehicle"] then
                    cancelMove()
                    if start then
                        start = false
                        startTick = getTickCount()
                    end
                end

                if invType == specTypes["vehicle.in"] then 
                    if not localPlayer.vehicle or localPlayer.vehicle ~= invElement then 
                        cancelMove()
                        if start then
                            start = false
                            startTick = getTickCount()
                        end
                    end 
                end 
            end
        else  
            if invElement == localPlayer then
                if not enabledInventory then 
                    cancelMove()
                    if start then
                        start = false
                        startTick = getTickCount()
                    end
                end
            end 
        end
    end

    if keysDenied then
        cancelMove()
        if start then
            start = false
            startTick = getTickCount()
        end
    end

    if moveState and not isCursorShowing() or craftMoveState and not isCursorShowing() then
        cancelMove()
    end

    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )

        alpha = alph

        if progress >= 1 and not weightAnimation then
            weightAnimationStart = realWeight or 0
            weightAnimation = true
            weightAnimationTick = getTickCount()
        end
    else

        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )

        alpha = alph

        if progress >= 1 then
            alpha = 0

            if isElement(invElement) then 
                if invElement.type == "vehicle" then
                    if invType == specTypes["vehicle.in"] then
                        setElementData(invElement, "inventory.open2", false)
                        exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű kesztyűtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                    else
                        --exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                        setElementData(invElement, "inventory.open", false)
                    end
                elseif invElement.type == "object" then
                    exports['cr_chat']:createMessage(localPlayer, "bezárja egy közelében lévő széf ajtaját", 1)
                    setElementData(invElement, "inventory.open", false)
                end
            end 

            invElement = localPlayer
            --removeEventHandler("onClientRender", root, drawnInventory)
            destroyRender("drawnInventory")
            RemoveBar("stack")
            state = false
            exports['cr_interface']:setNode("Inventory", "active", false)
            return
        end
    end

    if not isElement(invElement) then 
        cancelMove()
        if start then
            start = false
            startTick = getTickCount()
        end

        return
    end 

    font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    font2 = exports['cr_fonts']:getFont("Poppins-Medium", 12)
    font3 = exports['cr_fonts']:getFont("Poppins-Regular", 12)
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    font5 = exports['cr_fonts']:getFont("RobotoB", 13)

    x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
    UpdatePos("stack", {x + 10, y + 10, 55, 20 + 2})
    UpdateAlpha("stack", tocolor(242,242,242,alpha))
    local _x, _y = x, y

    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
    local _w, _h = w, h
    local cx, cy = x, y

    local line = 1
    local column = 1
    local startX = _x + (10)
    local _startX = startX
    local startY = _y + (50) -- 28

    local data = cache[elementType][elementID][invType]

    if not data then
        checkTableArray(elementType, elementID, invType)
    end

    if invElement and isElement(invElement) and invElement.type == "player" and invElement ~= localPlayer then 
        local money = tonumber(invElement:getData("char >> money") or 0)
        local green = "#7cc576"
        if money < 0 then 
            green = "#d23131"
        end 
        shadowedText(exports['cr_dx']:formatMoney(money) .. " $", _x + 7, _y - 16, _x + 7 + 168, _y - 16, tocolor(0, 0, 0, alpha), 1, font5, "left", "center", false, false, false, true)
        dxDrawText(green .. exports['cr_dx']:formatMoney(money) .. " $", _x + 7, _y - 16, _x + 7 + 168, _y - 16, tocolor(242, 242, 242,alpha), 1, font5, "left", "center", false, false, false, true)
    end 

    dxDrawRectangle(_x, _y, w, h, tocolor(51,51,51,alpha * 0.8))
    dxDrawRectangle(_x + 10, _y + 10, 55, 20, tocolor(41, 41, 41,alpha * 0.9))

    if isInSlot(_x + w - 10 - 15, _y + 10, 15, 15) then 
        dxDrawImage(_x + w - 10 - 15, _y + 10, 15, 15, "assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(_x + w - 10 - 15, _y + 10, 15, 15, "assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    if invType == specTypes["vehicle"] or invType == specTypes["vehicle.in"] then
        local v = iconPositions[1]
        local ax, ay, name, typeID = unpack(v)
        local name = "vehicle"
        local w, h = 20,20
        dxDrawImage(_x + ax, _y + ay, w, h, "assets/images/"..name..".png", 0,0,0, tocolor(255,59,59,alpha))
    elseif invType == specTypes["object"] then
        local v = iconPositions[1]
        local ax, ay, name, typeID = unpack(v)
        local name = "safe"
        local w, h = 20,20
        dxDrawImage(_x + ax, _y + ay, w, h, "assets/images/"..name..".png", 0,0,0, tocolor(255,59,59,alpha))
    else
        for k,v in pairs(iconPositions) do
            local ax, ay, name, typeID, w, h = unpack(v)
            if invType == typeID or isInSlot(_x + ax, _y + ay, w, h) then
                dxDrawImage(_x + ax, _y + ay, w, h, "assets/images/"..name..".png", 0,0,0, tocolor(255,59,59,alpha))
            else
                dxDrawImage(_x + ax, _y + ay, w, h, "assets/images/"..name..".png", 0,0,0, tocolor(242,242,242,alpha * 0.6))
            end
        end
    end

    if invType == 5 then
        --CraftPositions:
        positions = {
            {_x + 250, _y + 70, 195, 15},
            {_x + 250, _y + 70 + (15 + 1), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*2), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*3), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*4), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*5), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*6), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*7), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*8), 195, 15},
            {_x + 250, _y + 70 + ((15 + 1)*9), 195, 15},
        }

        dxDrawText("Barkácslista", _x + 250, _y + 50, _x + 250 + 195, _y + 67, tocolor(242, 242, 242,alpha), 1, font, "center", "center")
        local w, h = drawnSize["bg"][1], drawnSize["bg"][2]

        cActive = nil
        for k,v in pairs(positions) do
            local x, y, w, h = unpack(v)
            if isInSlot(x,y,w,h) or cSelected == k then
                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))
                cActive = k
            else
                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
            end
        end


        if isInSlot(_x + 270, _y + 240, 155, 30) then
            dxDrawRectangle(_x + 270, _y + 240, 155, 30, tocolor(97, 177, 90, alpha))
            cActive = 11 -- 11 / Button
            local x,y,w,h = _x + 270, _y + 240, _x + 270 + 155, _y + 240 + 30
            dxDrawText("Elkészít", x, y, w, h, tocolor(242, 242, 242,alpha), 1, font3, "center", "center")
        else
            dxDrawRectangle(_x + 270, _y + 240, 155, 30, tocolor(97, 177, 90, alpha * 0.7))
            local x,y,w,h = _x + 270, _y + 240, _x + 270 + 155, _y + 240 + 30
            dxDrawText("Elkészít", x, y, w, h, tocolor(242,242,242,alpha * 0.6), 1, font3, "center", "center")
        end

        local index, num = 1, 1
        local awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 7)
        local isTooltipRenderNeedActive
        for k, v in pairs(craftG) do
            local ctype, listed, citems = unpack(v)

            if listed then
                if index >= cminLines and index <= cmaxLines then
                    local x, y, w, h = unpack(positions[num])
                    w = w + x
                    h = h + y
                    if isInSlot(x, y, w - x, h - y) then
                        dxDrawText(ctype..":", x + 5, y, w, h, tocolor(242,242,242,alpha * 0.9), 1, font3, "left", "center")
                    else
                        dxDrawText(ctype..":", x + 5, y, w, h, tocolor(242,242,242,alpha * 0.6), 1, font3, "left", "center")
                    end

                    dxDrawImage(x + (w - x) - 5 - 14, y + ((h - y)/2) - 12/2, 10, 12, "assets/craft/on.png", 0,0,0, tocolor(255,255,255,alpha))
                    num = num + 1
                end

                for k2,v2 in pairs(citems) do
                    local itemdata, crafttime, cdata, needed = unpack(v2)
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                    index = index + 1
                    if index >= cminLines and index <= cmaxLines then
                        local x, y, w, h = unpack(positions[num])
                        local _w = w
                        w = w + x
                        h = h + y

                        if isInSlot(x, y, w - x, h - y) then
                            dxDrawText(getItemName(itemid), x + 10, y, w, h, tocolor(242,242,242,alpha * 0.9), 1, font3, "left", "center")
                            dxDrawText("", x + (w - x) - 5 - 14, y, x + (w - x) - 5 - 14 + 10, h, tocolor(242,242,242,alpha * 0.9), 1, awesomeFont, "center", "center")

                            if isInSlot(w - 5 - 14, y, 12, h - y) then
                                isTooltipRenderNeedActive = true
                                local cx, cy = exports['cr_core']:getCursorPosition()
                                isTooltipRenderNeedActiveData = {cx, cy, cdata, alpha, true}
                            end
                        else
                            dxDrawText(getItemName(itemid), x + 10, y, w, h, tocolor(242,242,242,alpha * 0.6), 1, font3, "left", "center")
                            dxDrawText("", x + (w - x) - 5 - 14, y, x + (w - x) - 5 - 14 + 10, h, tocolor(242,242,242,alpha * 0.6), 1, awesomeFont, "center", "center")
                        end

                        num = num + 1
                    end
                end
            else
                if index >= cminLines and index <= cmaxLines then
                    local x, y, w, h = unpack(positions[num])
                    w = w + x
                    h = h + y
                    if isInSlot(x, y, w - x, h - y) then
                        dxDrawText(ctype, x + 5, y, w, h, tocolor(242,242,242,alpha * 0.9), 1, font3, "left", "center")
                    else
                        dxDrawText(ctype, x + 5, y, w, h, tocolor(242,242,242,alpha * 0.6), 1, font3, "left", "center")
                    end --14/16
                    dxDrawImage(x + (w - x) - 5 - 14, y + ((h - y)/2) - 12/2, 10, 12, "assets/craft/off.png", 0,0,0, tocolor(255,255,255,alpha))
                    num = num + 1
                end
            end
            index = index + 1
        end

        if cmaxLines > (index - 1) then 
            cmaxLines = math.max(10, index - 1)
            cminLines = cmaxLines - (10 - 1)
        end 

        local __startX = startX
        local startX, startY = _x + 10, _y + 50
        local _startX = startX
        local tooltip = false
        local column, line = 1, 1
        local breakColumn = 5
        for i = 1, 5*5 do
            local isIn = false
            local w,h =  drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            if isInSlot(startX, startY, w, h) then
                dxDrawRectangle(startX, startY, w, h, tocolor(92, 165, 86, alpha))
                isIn = true
                _lastItem = lastItem
                lastItem = i
            elseif gdata[i] and hasData[i] then
                dxDrawRectangle(startX, startY, w, h, tocolor(124,197,118, alpha))
            elseif gdata[i] and not hasData[i] then
                dxDrawRectangle(startX, startY, w, h, tocolor(210,49,49, alpha))
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.9))
            end

            if gdata then
                local data = gdata[i]
                if data then
                    local id = 5000
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                    if isIn then
                        tooltip = i

                        if _lastItem ~= i and not interfaceDrawn then
                            playSound("assets/sounds/hover.mp3")
                            lastItem = i
                        end
                    end
                    local _w = w
                    local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]
                    local b = 1

                    if dutyitem == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(210,49,49, alpha))
                    end

                    if premium ~= 0 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(255,168,0, alpha))
                    end

                    local itemAlpha = alpha 

                    if status < 100 then 
                        if GetData(itemid, value, nbt, "food") or GetData(itemid, value, nbt, "drink") or GetData(itemid, value, nbt, "fishItem") then 
                            itemAlpha = alpha * (status / 100)
                            dxDrawImage(startX + b, startY + b, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
                        elseif status == 0 and isWeapon(itemid, value, nbt) then 
                            itemAlpha = alpha * (status / 100)
                            dxDrawImage(startX + b, startY + b, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
                        end 
                    end 
                    
                    dxDrawImage(startX + b, startY + b, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,itemAlpha))

                    local count = count or 1
                    if count >= 2 then
                        dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                    end
                end
            end

            startX = startX + drawnSize["bg_cube"][1] + between
            column = column + 1
            if column > breakColumn then
                startY = startY + drawnSize["bg_cube"][2] + between
                startX = _startX
                column = 1
                line = line + 1
            end
        end

        --scrollbar
        local percent = math.max(0, index - 1)
        
        if percent >= 1 then
            local gW, gH = 5, 160
            local gX, gY = _x + w - 5, _y + 70
            _sX, _sY, _sW, _sH = gX, gY, gW, gH
            
            if scrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, _sY), _sY + _sH)
                        local y = (cy - _sY) / (_sH)
                        local num = percent * y
                        cminLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 10) + 1)))
                        cmaxLines = cminLines + (10 - 1)
                    end
                else
                    scrolling = false
                end
            end
            
            dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))
            
            local multiplier = math.min(math.max((cmaxLines - (cminLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((cminLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier
            local r,g,b = 51, 51, 51
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        end
        --

        local multipler = 0

        if weightAnimation then
            local elapsedTime = nowTick - weightAnimationTick
            local duration = (weightAnimationTick + startAnimationTime) - weightAnimationTick
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                weightAnimationStart * 100, 0, 0,
                0, 0, 0,
                progress, startAnimation
            )

            multipler = alph / 100
            realWeight = multipler
        end

        if isCrafting then -- csík
            local now = getTickCount()
            local elapsedTime = now - CraftStartTick
            local duration = endTick - CraftStartTick
            multipler = elapsedTime / duration
        end

        local w = 210
        local startX, startY = _x + 214 + 10, _y + 25
        dxDrawRectangle(startX, startY, w, 5, tocolor(242,242,242,alpha * 0.6))
        dxDrawRectangle(startX, startY, w * multipler, 5, tocolor(255,59,59,alpha))
        dxDrawText(math.floor(multipler * 100) .. "%", startX, _y, startX + w, _y + 25 + 2, tocolor(242, 242, 242, alpha), 1, font2, "left", "bottom")

        if isTooltipRenderNeedActive then
            renderTooltip(unpack(isTooltipRenderNeedActiveData))
        end

        if tooltip then
            local data = gdata[tooltip]
            local cx, cy = exports['cr_core']:getCursorPosition()
            renderTooltip(cx, cy, data, alpha)
            tooltip = false
        end
    else
        local tooltip = false
        for i = 1, maxLines * maxColumn do
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            local isActive = false
            if activeSlot[invType .. "-" .. i] then
                if invElement == localPlayer then
                    isActive = true
                end
            end

            if isInSlot(startX, startY, w, h) then
                dxDrawRectangle(startX, startY, w, h, tocolor(92, 165, 86, alpha))
                isIn = true
                _lastItem = lastItem
                lastItem = i
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.9))
            end

            if isActive and not isIn then
                dxDrawRectangle(startX, startY, w, h, tocolor(124,197,118, alpha))
            end

            if data then
                local data = data[i]
                if data then
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    if not GetData(itemid, value, nbt, "name") then
                        cancelMove(5)
                        cache[elementType][elementID][invType][i] = nil
                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, invType)
                    end

                    if isIn then
                        tooltip = i

                        if _lastItem ~= i and not interfaceDrawn then
                            playSound("assets/sounds/hover.mp3")
                            lastItem = i
                        end
                    end
                    local _w = w
                    local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]
                    local b = 1

                    if dutyitem == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(210,49,49, alpha))
                    end

                    if premium ~= 0 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(255,168,0, alpha))
                    end

                    local itemAlpha = alpha 

                    if status < 100 then 
                        if GetData(itemid, value, nbt, "food") or GetData(itemid, value, nbt, "drink") or GetData(itemid, value, nbt, "fishItem") then 
                            itemAlpha = alpha * (status / 100)
                            dxDrawImage(startX + b, startY + b, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
                        elseif status == 0 and isWeapon(itemid, value, nbt) then 
                            itemAlpha = alpha * (status / 100)
                            dxDrawImage(startX + b, startY + b, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
                        end 
                    end 

                    dxDrawImage(startX + b, startY + b, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,itemAlpha))
                    
                    if isInventoryDisabled then
                        if not inAnim or inAnim and itemid ~= 15 then 
                            dxDrawImage(startX + b, startY + b, w, h, "assets/images/delete.png", 0,0,0, tocolor(210,49,49,alpha))
                        end 
                    end

                    local count = count or 1
                    if count >= 2 then
                        dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                    end
                end
            end

            startX = startX + drawnSize["bg_cube"][1] + between
            column = column + 1
            if column > breakColumn then
                startY = startY + drawnSize["bg_cube"][2] + between
                startX = _startX
                column = 1
                line = line + 1
            end
        end

        if invType ~= 5 then
            local maxWeight = typeDetails[invType][2]
            local multipler = 0

            if weightAnimation then
                local elapsedTime = nowTick - weightAnimationTick
                local duration = (weightAnimationTick + startAnimationTime) - weightAnimationTick
                local progress = elapsedTime / duration
                local alph = interpolateBetween(
                    weightAnimationStart * 100, 0, 0,
                    math.min(fullWeight / maxWeight, 1) * 100, 0, 0,
                    progress, startAnimation
                )

                multipler = alph / 100
                realWeight = multipler
            end

            local w = 210
            local startX, startY = _x + 214 + 10, _y + 25
            dxDrawRectangle(startX, startY, w, 5, tocolor(242,242,242,alpha * 0.6))
            dxDrawRectangle(startX, startY, w * multipler, 5, tocolor(255,59,59,alpha))
            dxDrawText(math.floor(multipler * 100) .. "%", startX, _y, startX + w, _y + 25 + 2, tocolor(242, 242, 242, alpha), 1, font2, "left", "bottom")
        end

        if tooltip then
            local data = data[tooltip]
            if data then
                local cx, cy = exports['cr_core']:getCursorPosition()
                renderTooltip(cx, cy, data, alpha)
                tooltip = false
            end
        end
    end

    if moveState then
        if invElement == localPlayer then
            if isInSlot(_x + w/2 - 75/2, _y - 90, 75, 75) then
                dxDrawImage(_x + w/2 - 75/2, _y - 90, 75, 75, "assets/images/eye.png", 0,0,0, tocolor(255,240,240,alpha))
            else
                dxDrawImage(_x + w/2 - 75/2, _y - 90, 75, 75, "assets/images/eye.png", 0,0,0, tocolor(255,255,255,math.min(200,alpha)))
            end
        end

        local cx, cy = getCursorPosition()
        local x, y = cx - ax, cy - ay
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
        local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]

        local itemAlpha = alpha 

        if status < 100 then 
            if GetData(itemid, value, nbt, "food") or GetData(itemid, value, nbt, "drink") or GetData(itemid, value, nbt, "fishItem") then 
                itemAlpha = alpha * (status / 100)
                dxDrawImage(x, y, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
            elseif status == 0 and isWeapon(itemid, value, nbt) then 
                itemAlpha = alpha * (status / 100)
                dxDrawImage(x, y, w, h, getItemGreyPNG(itemid, value, nbt, status, alpha))
            end 
        end 

        dxDrawImage(x, y, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,itemAlpha))

        dxDrawText(count,x, x, x + w, y + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
    end
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if state then
            if invElement.type == "vehicle" then
                if invType == specTypes["vehicle.in"] then
                    setElementData(invElement, "inventory.open2", false)
                else
                    setElementData(invElement, "inventory.open", false)
                end
            elseif invElement.type == "object" then
                setElementData(invElement, "inventory.open", false)
            end
        end
    end
)

isEnabledTypeForOpen = {
    ["Automobile"] = true,
    ["Plane"] = true,
    ["Helicopter"] = true,
    ["Boat"] = true,
}

isEnabledTypeForOpen2 = {
    ["Automobile"] = true,
    ["Plane"] = true,
    ["Helicopter"] = true,
    ["Boat"] = true,
}

function findAndUseItemByIDAndValue(itemid, value)
    local invType = items[itemid].invType;
    assert(type(invType) == "number", "got "..type(invType));

    for slot, data in pairs(cache[1][getEID(localPlayer)][invType]) do
        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        if data[2] == itemid and data[3] == value  then
            useItem(slot, unpack(data));
            return true;
        end
    end
    return false;
end

function findAndUseItemByIDAndDBID(itemid, dbId)
    local invType = items[itemid].invType;
    assert(type(invType) == "number", "got "..type(invType));

    for slot, data in pairs(cache[1][getEID(localPlayer)][invType]) do
        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        if data[2] == itemid and data[1] == dbId then
            useItem(slot, unpack(data));
            return true;
        end
    end
    return false;
end

addEventHandler("onClientClick", root,
    function(b, s, abX, abY, wx, wy, wz, worldE)
        if charDeath or inDeath then
            cancelMove()
            return
        end

        if exports['cr_network']:getNetworkStatus() then
            cancelMove()
            return
        end

        if b == "right" and s == "down" and not moveState then
            if localPlayer:getData("Actionbar.enabled") then
                local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")

                if isInSlot(ax, ay, aw, ah) then
                    acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                    if acType == 1 then
                        local startX = ax + 5
                        local startY = ay + 5

                        checkTableArray(1, accID, 10)
                        local data = cache[1][accID][10]
                        local tooltip = false
                        for i = 1, columns do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            local isIn = false
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local _invType = invType
                                        local invType, pairSlot, id = unpack(data)
                                        local data = cache[1][accID][invType][pairSlot]
                                        if moveState then
                                            if pairSlot == moveSlot and invType == _invType then
                                                data = moveDetails
                                            end
                                        end
                                        if data then
                                            cancelMove(5)
                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, 10)
                                            cache[1][accID][10][i] = nil
                                            playSound("assets/sounds/move.mp3")
                                            return
                                        end
                                    end
                                end
                            end

                            startX = startX + w + 5
                        end
                    elseif acType == 2 then
                        local startX = ax + 5
                        local startY = ay + 5

                        local data = cache[1][accID][10]
                        local tooltip = false
                        for i = 1, columns do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            local isIn = false
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local _invType = invType
                                        local invType, pairSlot, id = unpack(data)
                                        local data = cache[1][accID][invType][pairSlot]
                                        if moveState then
                                            if pairSlot == moveSlot and invType == _invType then
                                                data = moveDetails
                                            end
                                        end
                                        if data then
                                            cancelMove(5)
                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, 10)
                                            cache[1][accID][10][i] = nil
                                            playSound("assets/sounds/move.mp3")
                                            return
                                        end
                                    end
                                end
                            end

                            startY = startY + h + 5
                        end
                    end
                end
            end

            if state then
                if invType == specTypes["vehicle.in"] then
                    local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                    local _x, _y = x, y

                    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                    local cx, cy = x, y

                    local line = 1
                    local column = 1
                    local startX = _x + (10)
                    local _startX = startX
                    local startY = _y + (50)

                    local data = cache[elementType][elementID][invType]

                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local slot = i
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                                        if dutyitem == 1 then
                                            exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (DutyItem)")

                                            cancelMove()
                                            return
                                        end

                                        local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                        if not canMove then
                                            exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")

                                            cancelMove()
                                            return
                                        end

                                        local a2 = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                                        local itemName = getItemName(itemid, value, nbt)

                                        cancelMove()

                                        --exports['cr_chat']:createMessage(localPlayer, "kivesz egy tárgyat a jármű kesztyűtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                                        local chatData = {localPlayer, "kivesz egy tárgyat a jármű kesztyűtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1}

                                        cancelMove(5)
                                        triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, localPlayer, invType, a2, data, slot, chatData)

                                        cancelMove(3)

                                        weightAnimationStart = realWeight or 0
                                        fullWeight = getWeight(invElement, invType)
                                        weightAnimation = true
                                        weightAnimationTick = getTickCount()
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                elseif invElement == localPlayer then
                    local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                    local _x, _y = x, y
                    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                    local cx, cy = x, y

                    local line = 1
                    local column = 1
                    local startX = _x + (10)
                    local _startX = startX
                    local startY = _y + (50)

                    if not isTableArray(elementType, elementID, invType) then
                        return
                    end

                    local data = cache[elementType][elementID][invType]

                    local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                    local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")

                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local slot = i

                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt)
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                end
            end
        end

        local actbarx, actbary = getNode("Actionbar", "x"), getNode("Actionbar", "y")
        local actbarw, actbarh = getNode("Actionbar", "width"), getNode("Actionbar", "height")

        if state or localPlayer:getData("Actionbar.enabled") and isInSlot(actbarx, actbary, actbarw, actbarh) or b == "left" and s == "up" and craftMoveState then
            if b == "left" and s == "down" then
                if not moveState and not moveInteractDisabled and not craftMoveState then
                    local acx, acy = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                    local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
                    if localPlayer:getData("Actionbar.enabled") and isInSlot(acx, acy, aw, ah) then
                        acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                        if acType == 1 then
                            local startX = acx + 5
                            local startY = acy + 5

                            checkTableArray(1, accID, 10)
                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local _data = data[i]
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                local i = i
                                                local cx, cy = getCursorPosition()
                                                ax = cx - startX
                                                ay = cy - startY
                                                clickTimer = setTimer(
                                                    function()
                                                        if getKeyState("mouse1") then
                                                            craftMoveState = true
                                                            playSound("assets/sounds/select.mp3")
                                                            moveSlot = i
                                                            moveDetails = _data
                                                            cache[1][accID][10][i] = nil
                                                        end
                                                    end, 150, 1
                                                )

                                                return
                                            end
                                        end
                                    end
                                end

                                startX = startX + w + 5
                            end
                        elseif acType == 2 then
                            local startX = acx + 5
                            local startY = acy + 5

                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local _data = data[i]
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                local i = i
                                                local cx, cy = getCursorPosition()
                                                ax = cx - startX
                                                ay = cy - startY
                                                clickTimer = setTimer(
                                                    function()
                                                        if getKeyState("mouse1") then
                                                            craftMoveState = true
                                                            playSound("assets/sounds/select.mp3")
                                                            moveSlot = i
                                                            moveDetails = _data
                                                            cache[1][accID][10][i] = nil
                                                        end
                                                    end, 150, 1
                                                )

                                                return
                                            end
                                        end
                                    end
                                end

                                startY = startY + h + 5
                            end
                        end
                    end
                end

                local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                local _x, _y = x, y

                local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                local cx, cy = x, y

                local line = 1
                local column = 1
                local startX = _x + (10)
                local _startX = startX
                local startY = _y + (50)

                if invElement == localPlayer and invType == 5 then
                    if isInSlot(_sX, _sY, _sW, _sH) then
                        scrolling = true

                        return
                    end

                    local index, num = 1, 1

                    if cActive == 11 then
                        if gdata and ginfo then
                            local now = getTickCount()
                            local a = 15
                            if now <= lastClickTick + a * 1000 then
                                exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként craftolhatsz!")
                                return
                            end

                            lastClickTick = getTickCount()
                            local breaked = false
                            for k,v in pairs(gdata) do
                                if not hasData[k] then
                                    breaked = true
                                end
                            end

                            if not breaked and not isCrafting then
                                local itemdata, crafttime, cdata, needed = unpack(ginfo)
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                                local faction, location, blueprint = unpack(cdata)

                                if faction and type(faction) == "table" then
                                    local val = false 

                                    for k,v in pairs(faction) do 
                                        if exports['cr_dashboard']:isPlayerInFaction(localPlayer, v) then 
                                            val = true 
											break
                                        end 
                                    end 

                                    if not val then
                                        exports['cr_infobox']:addBox("warning", "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő szervezetben kell légy!")
                                        return
                                    end
                                end

                                if location and type(location) == "table" then
                                    local playerInterior = localPlayer.interior
                                    local playerDimension = localPlayer.dimension

                                    local canCraft = false
                                    local playerX, playerY, playerZ = getElementPosition(localPlayer)

                                    for k, v in pairs(location) do 
                                        local x, y, z, interior, dimension = unpack(v)
                                        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z)

                                        if distance <= 5 and playerInterior == interior and playerDimension == dimension then 
                                            canCraft = true
                                            break
                                        end
                                    end

                                    if not canCraft then 
                                        exports['cr_infobox']:addBox("warning", "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő helyen kell légy!")
                                        return
                                    end
                                end

                                if blueprint and type(blueprint) == "table" then
                                    local blueprints = localPlayer:getData("blueprints") or {}
                                    local has = true
                                    for k,v in pairs(blueprint) do
                                        if not blueprints[k] then
                                            has = false
                                            break
                                        end
                                    end

                                    if not has then
                                        exports['cr_infobox']:addBox("warning", "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő tudást el kell sajátítanod (Blueprint)!")
                                        return
                                    end
                                end

                                if isInventoryDisabled then
                                    return
                                end

                                local eType = getEType(localPlayer)
                                local eId = getEID(localPlayer)
                                for k,v in pairs(gdata) do
                                    local iType = items[v[2]]["invType"]
                                    local boolean, slot, data = unpack(hasData[k])
                                    local isActive = false
                                    if activeSlot[iType .. "-" .. slot] then
                                        if invElement == localPlayer then
                                            isActive = true
                                        end
                                    end

                                    if isActive then
                                        return
                                    end

                                    if boolean then
                                        if v[1] ~= -1 then
                                            checkTableArray(eType, eId, iType)
                                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])
                                            if count - v[3] <= 0 then
                                                cancelMove(5)
                                                cache[eType][eId][iType][slot] = nil
                                                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, iType)
                                            else
                                                cancelMove(5)
                                                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, iType, count - v[3])
                                            end
                                        end
                                    else
                                        return
                                    end
                                end

                                isCrafting = true
                                CraftStartTick = getTickCount()
                                lastClickTick = getTickCount()
                                local b = crafttime * 1000
                                endTick = CraftStartTick + b
                                exports['cr_infobox']:addBox("info", "A tárgy készítése elkezdődött. ("..getItemName(itemid)..")")
                                localPlayer:setData("forceAnimation", {"bd_fire", "wash_up"})
                                exports['cr_chat']:createMessage(localPlayer, "elkezdett elkészíteni egy tárgyat ("..getItemName(itemid)..")", 1)
                                craftSound = playSound("assets/sounds/craftSound.mp3", true)

                                setTimer(
                                    function()
                                        isCrafting = false
                                        moveInteractDisabled = false
                                        CraftStartTick = nil
                                        endTick = nil
                                        if isElement(craftSound) then destroyElement(craftSound) end
                                        craftSound = nil
                                        exports['cr_infobox']:addBox("success", "Sikeresen készítettél egy "..getItemName(itemid).."-at/et")
                                        cancelMove(5)
                                        giveItem(localPlayer, itemid, value, count, status, dutyitem, premium, nbt)
                                        showItem({-5000, itemid, value, count, status, dutyitem, premium, nbt})

                                        exports['cr_chat']:createMessage(localPlayer, "elkészített egy tárgyat ("..getItemName(itemid)..")", "do")
                                        localPlayer:setData("forceAnimation", {"", ""})
                                    end, b, 1
                                )
                            else
                                exports['cr_infobox']:addBox("error", "Ahhoz, hogy ezt a tárgyat elkészíthesd az összes szükséges tárgynak nálad kell legyen!")
                                return
                            end
                        end
                    end

                    local num = 0
                    for k, v in pairs(craftG) do
                        local ctype, listed, citems = unpack(v)

                        if listed then
                            if index >= cminLines and index <= cmaxLines then
                                num = num + 1
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        hasData = {}
                                        ginfo = nil
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end
                            end

                            for k2,v2 in pairs(citems) do
                                local itemdata, crafttime, cdata, needed = unpack(v2)
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                                index = index + 1
                                if index >= cminLines and index <= cmaxLines then
                                    num = num + 1
                                    if cActive == num then
                                        gdata = needed
                                        ginfo = v2
                                        hasData = {}
                                        for k,v in pairs(gdata) do
                                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                                            if hasItem(localPlayer, itemid, value) then
                                                hasData[k] = {hasItem(localPlayer, itemid, value)}
                                            end
                                        end

                                        updateTimer = setTimer(
                                            function()
                                                hasData = {}
                                                for k,v in pairs(gdata) do
                                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                                                    if hasItem(localPlayer, itemid, value) then
                                                        hasData[k] = {hasItem(localPlayer, itemid, value)}
                                                    end
                                                end
                                            end, 1000, 0
                                        )
                                        gdatak = k
                                    end
                                end
                            end
                        else
                            if index >= cminLines and index <= cmaxLines then
                                num = num + 1
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        ginfo = nil
                                        hasData = {}
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end
                            end
                        end
                        index = index + 1
                    end
                end

                if isInSlot(_x + w - 10 - 15, _y + 10, 15, 15) then 
                    if exports['cr_network']:getNetworkStatus() then return end

                    lastOpenTick = getTickCount()
                    closeInventory(localPlayer)

                    return
                end 

                if invElement.type == "player" then
                    if not invElement:getData("enabledInventory") then 
                        return 
                    end
                end

                if localPlayer:getData("keysDenied") then 
                    return 
                end

                if not isTableArray(elementType, elementID, invType) then
                    return
                end

                local data = cache[elementType][elementID][invType]
                
                if not moveState and not craftMoveState then
                    if invElement.type == "player" then
                        for k,v in pairs(iconPositions) do
                            local ax, ay, name, typeID, w, h = unpack(v)
                            if isInSlot(_x + ax, _y + ay, w, h) then
                                if typeID ~= 5 then
                                    if invType ~= typeID then
                                        playSound("assets/sounds/bincoselect.mp3")
                                    end
                                    invType = typeID
                                    gdata = {}
                                    ginfo = nil
                                    hasData = {}
                                    if isTimer(updateTimer) then killTimer(updateTimer) end
                                    weightAnimationStart = realWeight or 0
                                    fullWeight = getWeight(invElement, invType)
                                    weightAnimation = true
                                    weightAnimationTick = getTickCount()
                                else
                                    if invElement == localPlayer then
                                        weightAnimationStart = realWeight or 0
                                        fullWeight = 0 --getWeight(invElement, invType)
                                        weightAnimation = true
                                        weightAnimationTick = getTickCount()
                                        if invType ~= typeID then
                                            playSound("assets/sounds/bincoselect.mp3")
                                        end
                                        gdata = {}
                                        ginfo = nil
                                        hasData = {}
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                        invType = typeID
                                    end
                                end
                                return
                            end
                        end
                    end
                end 

                if not moveState and not moveInteractDisabled and not craftMoveState then
                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local num = tonumber(textbars["stack"][2][2])
                                        if num and num >= 1 then
                                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[elementType][elementID][invType][i])
                                            local isStackable = GetData(itemid, value, nbt, "canStack") --items[itemid]["canStack"]
                                            if isStackable then
                                                if num <= count - 1 then
                                                    local isActive = false
                                                    if activeSlot[invType .. "-" .. i] then
                                                        if invElement == localPlayer then
                                                            isActive = true
                                                        end
                                                    end
                                                    if isActive then
                                                        cancelMove()
                                                        return
                                                    end

                                                    if isInventoryDisabled then
                                                        return
                                                    end

                                                    local cx, cy = getCursorPosition()
                                                    ax = cx - startX
                                                    ay = cy - startY
                                                    local newCount = count - num
                                                    moveState = true
                                                    playSound("assets/sounds/select.mp3")
                                                    moveSlot = i
                                                    textbars["stack"][2][2] = ""
                                                    stacking = true
                                                    moveDetails = {id, itemid, value, num, status, dutyitem, premium, nbt, i, count}
                                                    cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                else
                                                    exports['cr_infobox']:addBox("error", "Ennyit nem választhatsz szét!")
                                                end
                                            else
                                                exports['cr_infobox']:addBox("error", "Ez az item nem szétszedhető!")
                                            end
                                        else
                                            if activeSlot[invType .. "-" .. i] then
                                                if invElement == localPlayer then
                                                    return
                                                end
                                            end

                                            if isInventoryDisabled then
                                                return
                                            end

                                            local i = i
                                            local cx, cy = getCursorPosition()
                                            ax = cx - startX
                                            ay = cy - startY
                                            clickTimer = setTimer(
                                                function()
                                                    if getKeyState("mouse1") then
                                                        moveState = true
                                                        playSound("assets/sounds/select.mp3")
                                                        moveSlot = i
                                                        moveDetails = cache[elementType][elementID][invType][i]
                                                        moveDetails[9] = i
                                                        moveDetails[10] = moveDetails[4]
                                                        cache[elementType][elementID][invType][i] = nil
                                                    end
                                                end, 150, 1
                                            )
                                        end
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                end
            elseif b == "left" and s == "up" then
                if scrolling then
                    scrolling = false
                end

                if isTimer(clickTimer) then
                    killTimer(clickTimer)
                end

                if craftMoveState then
                    local acx, acy = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                    local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")

                    if localPlayer:getData("Actionbar.enabled") and isInSlot(acx, acy, aw, ah) then
                        acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                        if acType == 1 then
                            local startX = acx + 5
                            local startY = acy + 5

                            checkTableArray(1, accID, 10)
                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local _data = data[i]
                                        local data = data[i]
                                        if moveSlot ~= i then
                                            if data then
                                                local oSlotData, oSlotData2 = cancelMove(2, i)

                                                cancelMove(5)
                                                triggerServerEvent("changeSlot", localPlayer, localPlayer, moveSlot, i, 10, oSlotData, oSlotData2)
                                                return
                                            else
                                                local oSlotData = moveDetails
                                                cancelMove(1, i)

                                                cancelMove(5)
                                                triggerServerEvent("updateSlot", localPlayer, localPlayer, moveSlot, i, 10, oSlotData)
                                                return
                                            end
                                        else
                                            cancelMove()
                                        end
                                    end
                                end

                                startX = startX + w + 5
                            end

                            cancelMove()
                            return
                        elseif acType == 2 then
                            local startX = acx + 5
                            local startY = acy + 5

                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local _data = data[i]
                                        local data = data[i]
                                        if moveSlot ~= i then
                                            if data then
                                                local oSlotData, oSlotData2 = cancelMove(2, i)

                                                cancelMove(5)
                                                triggerServerEvent("changeSlot", localPlayer, localPlayer, moveSlot, i, 10, oSlotData, oSlotData2)
                                                return
                                            else
                                                local oSlotData = moveDetails
                                                cancelMove(1, i)

                                                cancelMove(5)
                                                triggerServerEvent("updateSlot", localPlayer, localPlayer, moveSlot, i, 10, oSlotData)
                                                return
                                            end
                                        else
                                            cancelMove()
                                        end
                                    end
                                end

                                startY = startY + h + 5
                            end

                            cancelMove()
                            return
                        end
                    end

                    cancelMove()
                end

                local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                local _x, _y = x, y

                local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                local cx, cy = x, y

                local line = 1
                local column = 1
                local startX = _x + (10)
                local _startX = startX
                local startY = _y + (50)

                local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")

                if not isTableArray(elementType, elementID, invType) then
                    return
                end

                local data = cache[elementType][elementID][invType]
                if moveState then
                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]

                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local isActive = false
                                        if activeSlot[invType .. "-" .. i] then
                                            if invElement == localPlayer then
                                                isActive = true
                                            end
                                        end

                                        if isActive then
                                            cancelMove()
                                            return
                                        end
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)

                                        if itemid == itemid2 then
                                            local canStack = GetData(itemid, value, nbt, "canStack") --items[itemid]["canStack"]
                                            local maxStack = GetData(itemid, value, nbt, "maxStack") --items[itemid]["maxStack"]

                                            local between = math.abs(status - status2)
                                            if between > 5 then
                                                exports['cr_infobox']:addBox('error', 'A két item státuszának különbsége nagyobb mint 5!')
                                                canStack = false
                                            end

                                            if dutyitem == 1 or dutyitem2 == 1 then
                                                if dutyitem ~= dutyitem2 then
                                                    exports['cr_infobox']:addBox('error', 'A két item duty értéke különböző!')
                                                    canStack = false
                                                end
                                            end

                                            if premium ~= 0 or premium2 ~= 0 then
                                                if premium ~= premium2 then
                                                    exports['cr_infobox']:addBox('error', 'A két item prémium státusza különböző!')
                                                    canStack = false
                                                end
                                            end

                                            if value ~= value2 then
                                                exports['cr_infobox']:addBox('error', 'A két item értékei különbözőek!')
                                                canStack = false
                                            end

                                            if nbt ~= nbt2 then
                                                exports['cr_infobox']:addBox('error', 'A két item NBT értékei különbözőek!')
                                                canStack = false
                                            end

                                            if canStack then
                                                if count + count2 <= maxStack then
                                                    if i ~= moveSlot then
                                                        if stacking then
                                                            local newCount = count + count2
                                                            cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}

                                                            local count3 = moveDetails[10]

                                                            cancelMove(5)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, i, invType, newCount, true)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, moveSlot, invType, count3 - count2)

                                                            cancelMove(4)
                                                        else
                                                            local newCount = count + count2
                                                            cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                            cancelMove(3)

                                                            cancelMove(5)
                                                            triggerServerEvent("removeItemFromSlot", localPlayer, invElement, moveSlot, invType, true)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, i, invType, newCount)
                                                        end

                                                        return
                                                    end
                                                end

                                                cancelMove()
                                                return
                                            else
                                                local oSlotData, oSlotData2 = cancelMove(2, i)

                                                if i ~= moveSlot then
                                                    local data = cache[1][accID][10]
                                                    for i2 = 1, 9 do
                                                        if data then
                                                            local data = data[i2]
                                                            if data then
                                                                local _invType = invType
                                                                local invType, pairSlot, id = unpack(data)
                                                                local data = cache[1][accID][invType][pairSlot]
                                                                if pairSlot == moveSlot and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, i, id}
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                                end
                                                            end
                                                        end
                                                    end

                                                    local data = cache[1][accID][10]
                                                    for i2 = 1, 9 do
                                                        if data then
                                                            local data = data[i2]
                                                            if data then
                                                                local _invType = invType
                                                                local invType, pairSlot, id = unpack(data)
                                                                local data = cache[1][accID][invType][pairSlot]
                                                                if pairSlot == moveSlot and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, moveSlot, id}
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, moveSlot, id})
                                                                elseif pairSlot == i and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, i, id}
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                                end
                                                            end
                                                        end
                                                    end
                                                    cancelMove(5)
                                                    triggerServerEvent("changeSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData, oSlotData2)
                                                end

                                                return
                                            end
                                        else
                                            local oSlotData, oSlotData2 = cancelMove(2, i)

                                            if i ~= moveSlot then
                                                local data = cache[1][accID][10]
                                                for i2 = 1, 9 do
                                                    if data then
                                                        local data = data[i2]
                                                        if data then
                                                            local _invType = invType
                                                            local invType, pairSlot, id = unpack(data)
                                                            local data = cache[1][accID][invType][pairSlot]
                                                            if pairSlot == moveSlot and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, i, id}
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                            elseif pairSlot == i and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, moveSlot, id}
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, moveSlot, id})
                                                            end
                                                        end
                                                    end
                                                end
                                                cancelMove(5)
                                                triggerServerEvent("changeSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData, oSlotData2)
                                            end

                                            return
                                        end

                                        cancelMove()

                                        return
                                    else
                                        if stacking then
                                            if i ~= moveSlot then
                                                cancelMove(5)
                                                cache[elementType][elementID][invType][i] = moveDetails
                                                triggerServerEvent("addItemToSlot", localPlayer, invElement, i, invType, moveDetails, true)
                                                local newCount = moveDetails[10] - moveDetails[4]
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                triggerServerEvent("countUpdate", localPlayer, invElement, moveSlot, invType, newCount)
                                            end

                                            stacking = false
                                            cancelMove(4)
                                        else
                                            local oSlotData = moveDetails
                                            cancelMove(1, i)

                                            if i ~= moveSlot then
                                                local data = cache[1][accID][10]
                                                for i2 = 1, 9 do
                                                    if data then
                                                        local data = data[i2]
                                                        if data then
                                                            local _invType = invType
                                                            local invType, pairSlot, id = unpack(data)
                                                            local data = cache[1][accID][invType][pairSlot]
                                                            if pairSlot == moveSlot and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, i, id}
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                            end
                                                        end
                                                    end
                                                end
                                                cancelMove(5)
                                                triggerServerEvent("updateSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData)
                                            end
                                        end
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end


                        cancelMove()
                    elseif state and isInSlot(_x + w/2 - 75/2, _y - 90, 75, 75) then
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                        local itemName = getItemName(itemid, value, nbt)

                        showItem(moveDetails)

                        exports['cr_chat']:createMessage(localPlayer, "felmutat egy tárgyat ("..itemName..")", 1)

                        cancelMove()
                    elseif localPlayer:getData("Actionbar.enabled") and isInSlot(ax, ay, aw, ah) and invElement == localPlayer then
                        acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                        if acType == 1 then
                            local startX = ax + 5
                            local startY = ay + 5

                            checkTableArray(1, accID, 10)
                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                cancelMove()
                                                return
                                            end
                                        end
                                    end

                                    cancelMove(5)
                                    triggerServerEvent("addItemToSlot", localPlayer, localPlayer, i, 10, {invType, moveSlot, -1})

                                    cancelMove()

                                    checkTableArray(1, accID, 10)
                                    cache[1][accID][10][i] = {invType, moveSlot}
                                    return
                                end

                                startX = startX + w + 5
                            end

                            cancelMove()

                            return
                        elseif acType == 2 then

                            local startX = ax + 5
                            local startY = ay + 5

                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                cancelMove()
                                                return
                                            end
                                        end
                                    end

                                    cancelMove(5)
                                    triggerServerEvent("addItemToSlot", localPlayer, localPlayer, i, 10, {invType, moveSlot, -1})

                                    cancelMove()
                                    checkTableArray(1, accID, 10)
                                    cache[1][accID][10][i] = {invType, moveSlot}
                                    return
                                end

                                startY = startY + h + 5
                            end

                            cancelMove()
                            return
                        end

                        cancelMove()
                    else
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                        if worldE and worldE.type == "player" then
                            if worldE ~= localPlayer and invElement == localPlayer then

                                local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                if not canMove then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")

                                    cancelMove()
                                    return
                                end

                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                if dutyitem == 1 then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (Dutyitem)")

                                    cancelMove()
                                    return
                                end

                                local veh = getPedOccupiedVehicle(localPlayer)
                                if veh then
                                    exports['cr_infobox']:addBox("error", "Kocsiban ülve nem tudod átadni a tárgyat!")

                                    cancelMove()
                                    return
                                end

                                local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                if dist > (worldE.type == "vehicle" and 5 or 3) then
                                    exports['cr_infobox']:addBox("error", "A célpont túl messze van")

                                    cancelMove()
                                    return
                                end

                                if stacking then
                                    cancelMove()
                                    return
                                end

                                local itemName = getItemName(itemid, value, nbt)
                                --exports['cr_chat']:createMessage(localPlayer, "átad egy tárgyat egy közelében lévő embernek ("..itemName..")", 1)
                                local chatData = {localPlayer, "átad egy tárgyat " .. exports.cr_admin:getAdminName(worldE) .. "-nak/nek ("..itemName..")", 1}

                                local a2 = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                                cancelMove(5)
                                triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot, chatData)

                                cancelMove(3)

                                weightAnimationStart = realWeight or 0
                                fullWeight = getWeight(invElement, invType)
                                weightAnimation = true
                                weightAnimationTick = getTickCount()

                                return
                            elseif worldE == localPlayer and invElement ~= localPlayer then
                                if invType == specTypes["vehicle"] then
                                    local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                    if not canMove then
                                        exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")

                                        cancelMove()
                                        return
                                    end

                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                    if dutyitem == 1 then
                                        exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (Dutyitem)")

                                        cancelMove()
                                        return
                                    end

                                    local veh = getPedOccupiedVehicle(localPlayer)
                                    if veh then
                                        exports['cr_infobox']:addBox("error", "Kocsiban ülve nem tudod átadni a tágyat!")

                                        cancelMove()
                                        return
                                    end

                                    if stacking then
                                        cancelMove()
                                        return
                                    end

                                    local a2 = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                                    local itemName = getItemName(itemid, value, nbt)

                                    --exports['cr_chat']:createMessage(localPlayer, "kivesz egy tárgyat a jármű csomagtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                                    local chatData = {localPlayer, "kivesz egy tárgyat a jármű csomagtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1}
                                    cancelMove(5)
                                    triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot, chatData)

                                    cancelMove(3)

                                    weightAnimationStart = realWeight or 0
                                    fullWeight = getWeight(invElement, invType)
                                    weightAnimation = true
                                    weightAnimationTick = getTickCount()
                                    return
                                elseif invType == specTypes['object'] then 
                                    local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                    if not canMove then
                                        exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")

                                        cancelMove()
                                        return
                                    end

                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                    if dutyitem == 1 then
                                        exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (Dutyitem)")

                                        cancelMove()
                                        return
                                    end

                                    local veh = getPedOccupiedVehicle(localPlayer)
                                    if veh then
                                        exports['cr_infobox']:addBox("error", "Kocsiban ülve nem tudod átadni a tágyat!")

                                        cancelMove()
                                        return
                                    end

                                    if stacking then
                                        cancelMove()
                                        return
                                    end

                                    local a2 = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                                    local itemName = getItemName(itemid, value, nbt)

                                    local chatData = {localPlayer, "kivesz egy tárgyat a széfből ("..itemName..")", 1}
                                    cancelMove(5)
                                    triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot, chatData)

                                    cancelMove(3)

                                    weightAnimationStart = realWeight or 0
                                    fullWeight = getWeight(invElement, invType)
                                    weightAnimation = true
                                    weightAnimationTick = getTickCount()
                                    return
                                end
                            end

                            cancelMove()
                            return
                        elseif worldE and worldE.type == "vehicle" then
                            if invElement ~= localPlayer then
                                cancelMove()
                                return
                            end

                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                            if dutyitem == 1 then
                                exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (Dutyitem)")

                                cancelMove()
                                return
                            end

                            local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                            if not canMove then
                                exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")

                                cancelMove()
                                return
                            end

                            local veh = getPedOccupiedVehicle(localPlayer)
                            if veh and veh ~= worldE then
                                exports['cr_infobox']:addBox("error", "Nem tudsz átnyúlni az egyik kocsiból a másikba, hogy berakd oda a cuccod.")

                                cancelMove()
                                return
                            end

                            local seat = getPedOccupiedVehicleSeat(localPlayer)
                            if veh and seat >= 2 then
                                exports['cr_infobox']:addBox("error", "A kesztyűtartóba csak a vezető és anyósülésen lévő játékos tud tárgyat berakni.")

                                cancelMove()
                                return
                            end

                            local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                            if dist > (worldE.type == "vehicle" and 5 or 3) then
                                exports['cr_infobox']:addBox("error", "A célpont túl messze van")

                                cancelMove()
                                return
                            end

                            local eId = getEID(worldE)
                            if not veh then
                                if not worldE:getData("veh >> boot") then
                                    exports['cr_infobox']:addBox("error", "A célpont zárva van!")
                                    cancelMove()
                                    return
                                end
                            end

                            if stacking then
                                cancelMove()
                                return
                            end

                            local a2 = specTypes["vehicle"]
                            local text = "csomagtartójába"

                            if veh then
                                a2 = specTypes["vehicle.in"]
                                text = "kesztyűtartójába"
                            end

                            if isKey(itemid, value, nbt) then
                                exports['cr_infobox']:addBox("error", "Kulcsok nem helyezhetőek csomagtartóba!")

                                cancelMove()
                                return
                            end

                            if itemid == 317 then 
                                exports.cr_infobox:addBox("error", "Pénzkazetta nem helyezhető csomagtartóba!")

                                cancelMove()
                                return
                            end

                            local itemName = getItemName(itemid, value, nbt)
                            --exports['cr_chat']:createMessage(localPlayer, "berak egy tárgyat a jármű "..text.." ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                            local chatData = {localPlayer, "berak egy tárgyat a jármű "..text.." ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1}

                            cancelMove(5)
                            triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot, chatData)

                            cancelMove(3)

                            weightAnimationStart = realWeight or 0
                            fullWeight = getWeight(invElement, invType)
                            weightAnimation = true
                            weightAnimationTick = getTickCount()
                            return
                        elseif worldE and worldE.type == "object" then
                            if worldE.model == 1359 then -- kuka
                                if invElement ~= localPlayer then
                                    cancelMove()
                                    return
                                end

                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                --[[
                                if dutyitem == 1 then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem kidobható! (Dutyitem)")

                                    cancelMove()
                                    return
                                end]]

                                local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                if not canMove then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem kidobható!")

                                    cancelMove()
                                    return
                                end

                                local veh = getPedOccupiedVehicle(localPlayer)
                                if veh then
                                    exports['cr_infobox']:addBox("error", "Nem tudsz átnyúlni a kocsiból, hogy kidobd a cuccod.")

                                    cancelMove()
                                    return
                                end

                                local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                if dist > (worldE.type == "vehicle" and 5 or 3) then
                                    exports['cr_infobox']:addBox("error", "A célpont túl messze van")

                                    cancelMove()
                                    return
                                end

                                if stacking then
                                    cancelMove()
                                    return
                                end

                                exports['cr_chat']:createMessage(localPlayer, "kidob egy tárgyat a közelében lévő kukába ("..getItemName(itemid, value, nbt)..")", 1)

                                cancelMove(5)
                                triggerServerEvent("deleteItem", localPlayer, localPlayer, moveSlot, itemid)

                                cancelMove(3)
                                return
                            elseif worldE:getData("safe.id") then -- széf
                                if invElement ~= localPlayer then
                                    cancelMove()
                                    return
                                end

                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                if dutyitem == 1 then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható! (Dutyitem)")

                                    cancelMove()
                                    return
                                end

                                local canMove = GetData(itemid, value, nbt, "canMove") --items[itemid]["canMove"]
                                if not canMove then
                                    exports['cr_infobox']:addBox("error", "Ez a tárgy nem átadható!")
                                    cancelMove()
                                    return
                                end

                                local veh = getPedOccupiedVehicle(localPlayer)
                                if veh and veh ~= worldE then
                                    exports['cr_infobox']:addBox("error", "Nem tudsz átnyúlni az egyik kocsiból a másikba, hogy berakd oda a cuccod.")
                                    cancelMove()
                                    return
                                end

                                local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                if dist > (worldE.type == "vehicle" and 5 or 3) then
                                    exports['cr_infobox']:addBox("error", "A célpont túl messze van")
                                    cancelMove()
                                    return
                                end

                                local a2 = specTypes["object"]
                                local text = "széfbe"

                                if veh then
                                    cancelMove()
                                    return
                                end

                                local eId = getEID(worldE)
                                local _itemid = convertKey("safe")
                                local hasKey = hasItem(localPlayer, _itemid, eId)

                                if not hasKey then
                                    exports['cr_infobox']:addBox("error", "A célponthoz nincs kulcsod!")
                                    cancelMove()
                                    return
                                end

                                -- if isKey(itemid, value, nbt) then
                                --     exports['cr_infobox']:addBox("error", "Kulcsok nem helyezhetőek széfbe.")
                                --     cancelMove()
                                --     return
                                -- end

                                if itemid == 317 then 
                                    exports.cr_infobox:addBox("error", "Pénzkazetta nem helyezhető széfbe!")
    
                                    cancelMove()
                                    return
                                end

                                if stacking then
                                    cancelMove()
                                    return
                                end

                                local itemName = getItemName(itemid, value, nbt)
                                --exports['cr_chat']:createMessage(localPlayer, "berak egy tárgyat egy "..text.." ("..itemName..")", 1)
                                local chatData = {localPlayer, "berak egy tárgyat egy "..text.." ("..itemName..")", 1}

                                cancelMove(5)
                                triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot, chatData)

                                cancelMove(3)
                                weightAnimationStart = realWeight or 0
                                fullWeight = getWeight(invElement, invType)
                                weightAnimation = true
                                weightAnimationTick = getTickCount()
                            elseif worldE and invElement == localPlayer then
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                if stacking then
                                    cancelMove()
                                    return
                                end

                                if itemid == 97 then -- bankkártya
                                    if not localPlayer.vehicle then 
                                        if worldE:getData("bank >> atm") and not worldE:getData("atm >> unavailable") then
                                            if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then
                                                exports["cr_bank"]:openATM(worldE, value)
                                            end
                                        end
                                    end 
                                end 

                                if itemid == 27 or itemid == 28 or itemid == 78 then
                                    if worldE:getData("ped >> license") then
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then
                                            exports["cr_license"]:renewDocument(localPlayer, itemid, moveDetails, moveSlot)
                                        end 
                                    end
                                end

                                cancelMove()
                                return
                            end

                            worldItemInteract(wx, wy, wz)
                            return
                        elseif(worldE and worldE.type == "ped") and invElement == localPlayer then
                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                            local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                            local eType = getEType(localPlayer)
                            local eId = getEID(localPlayer)
                            local doRemoveItem = false

                            if isKey(itemid, value, nbt) then
                                cancelMove()
                                return
                            end

                            if stacking then
                                cancelMove()
                                return
                            end

                            if itemid == 97 then
                                if not localPlayer.vehicle then 
                                    if worldE:getData("bank >> ped") then
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then
                                            exports["cr_bank"]:openBank(worldE, value)
                                            cancelMove()
                                            return
                                        end
                                    end
                                end
                            end

                            if GetData(itemid, value, nbt, "hunterItem") and GetData(itemid, value, nbt, "hunterItemPrice") then 
                                if not localPlayer.vehicle then 
                                    if worldE:getData("hunter >> collectorPed") then 
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then
                                            cancelMove()
                                            exports['cr_core']:giveMoney(localPlayer, (GetData(itemid, value, nbt, "hunterItemPrice") * count))
                                            exports['cr_infobox']:addBox("success", "Sikeresen eladtad a(z) "..GetData(itemid, value, nbt, "name").."-ot/et "..(GetData(itemid, value, nbt, "hunterItemPrice") * count).." $-ért!")
                                            removeItemFromSlot(invType, moveSlot, false)
                                            return
                                        end
                                    end 
                                end 
                            end 
                            
                            if GetData(itemid, value, nbt, "fishItem") and GetData(itemid, value, nbt, "fishItemPrice") then 
                                if not localPlayer.vehicle then 
                                    if worldE:getData("fishing >> collectorPed") then 
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then 
                                            cancelMove()

                                            local price = GetData(itemid, value, nbt, "fishItemPrice") * count
                                            local realPrice = math.floor(price * (status / 100))

                                            if price and price > 0 and realPrice and realPrice > 0 then 
                                                local syntax = exports["cr_core"]:getServerSyntax("Fishing", "success")
                                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                                                outputChatBox(syntax.."Sikeresen leadtad: "..serverHex..GetData(itemid, value, nbt, "name").."#ffffff. Állapot: "..serverHex..status.."%", 255, 0, 0, true)
                                                outputChatBox(syntax.."Eladási ár: "..serverHex.."$"..exports["cr_dx"]:formatMoney(realPrice), 255, 0, 0, true)

                                                exports["cr_core"]:giveMoney(localPlayer, realPrice, false)
                                                removeItemFromSlot(invType, moveSlot, false)
                                            end

                                            return 
                                        end
                                    end
                                end
                            end

                            if itemid == 15 then 
                                if not localPlayer.vehicle then 
                                    if worldE:getData("ped >> wallet") then 
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then 
                                            exports["cr_walletreplenishment"]:updateDatas(nbt, value, worldE)
                                            cancelMove()
                                            return 
                                        end
                                    end
                                end
                            end

                            if itemid == 128 then 
                                if not localPlayer.vehicle then 
                                    if worldE:getData("ticketPed") then 
                                        if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then 
                                            if type(value) == "table" then 
                                                local cost = value.penalty

                                                if tonumber(cost) then 
                                                    if exports.cr_core:hasMoney(localPlayer, tonumber(cost), false) then 
                                                        exports.cr_core:takeMoney(localPlayer, tonumber(cost), false)
                                                        exports.cr_infobox:addBox("success", "Sikeresen befizetted a csekket!")

                                                        local govId = 4
                                                        local sheriffId = 1

                                                        local mdId = 2
                                                        local actualId = value.mdTicket and mdId or sheriffId

                                                        local moneyForGov = math.floor(tonumber(cost) * 0.75)
                                                        local moneyForBoth = math.floor(tonumber(cost) * 0.25)

                                                        triggerServerEvent("dashboard.setFactionBankMoney", localPlayer, govId, moneyForGov)
                                                        triggerServerEvent("dashboard.setFactionBankMoney", localPlayer, actualId, moneyForBoth)
                                                        
                                                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                                        cancelMove(3)
                                                    else
                                                        exports.cr_infobox:addBox("error", "Nincs elég pénzed a csekk befizetéséhez.")
                                                        cancelMove()
                                                    end
                                                end
                                            end

                                            return
                                        end
                                    end
                                end
                            end

                            if not doRemoveItem then
                                cancelMove()
                            else
                                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                cancelMove(3)
                            end
                            
                            return
                        end

                        worldItemInteract(wx, wy, wz)
                        return
                    end
                end
            end
        end

        if b == "right" and s == "down" then
            if worldE and worldE.type == "vehicle" then
                local veh = getPedOccupiedVehicle(localPlayer)
                if veh then
                    if localPlayer:getData("keysDenied") then 
                        return 
                    end

                    if worldE == veh then
                        local seat = getPedOccupiedVehicleSeat(localPlayer)
                        if seat <= 1 then
                            if isEnabledTypeForOpen2[getVehicleType(veh)] then
                                if not getElementData(worldE, "inventory.open2") then
                                    local eId = getEID(worldE)
									if getElementData(worldE, "drone >> isDrone") or getElementData(worldE, "veh >> temporaryVehicle") or getElementData(worldE, "veh >> job") then return end
                                    setElementData(worldE, "inventory.open2", localPlayer)
                                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a jármű kesztyűtartóját ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                                    state = true
                                    openInventory(worldE)
                                    invType = specTypes["vehicle.in"]
                                    return
                                else
                                    local syntax = getServerSyntax("Inventory", "error")
                                    exports['cr_infobox']:addBox("error", "Ez az inventory jelenleg használatban van!")
                                    return
                                end
                            else
                                local syntax = getServerSyntax("Inventory", "error")
                                exports['cr_infobox']:addBox("error", "Ennél a fajta járműnél nem lehetséges a kesztyűtartója megnyitása.")
                                return
                            end
                        else
                            local syntax = getServerSyntax("Inventory", "error")
                            exports['cr_infobox']:addBox("error", "Csak a vezető és anyósülésen ülő játékos nyithatja meg a kesztyűtartót!")
                            return
                        end
                    else
                        local syntax = getServerSyntax("Inventory", "error")
                        exports['cr_infobox']:addBox("error", "Mivel nem vagy varázsló ezért nem tudsz átnyúlni a kocsidból egy másik kocsi csomagtartójába... !")
                        return
                    end
                end
            end
        end
    end
)

function cursorWorldPos()
    local _, _, x,y,z = getCursorPos()
    local cx, cy = getCursorPosition()
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition(cx, cy, 0.1)
	local col, x, y, z, hoverElement = processLineOfSight(cameraX, cameraY, cameraZ, x,y,z)
	return col, x, y, z, hoverElement
end

setTimer(
    function()
        isCursorHoverElement = nil
        if localPlayer:getData("loggedIn") then
            if isCursorShowing() then
                local col, x, y, z, hoverElement = cursorWorldPos()
                if hoverElement then
                    if hoverElement:getData("worldItemId") then
                        local yard = getDistanceBetweenPoints3D(localPlayer.position, hoverElement.position)
                        if yard <= 2 then
                            local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                            local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                            local breaked = false
                            local acx, acy = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                            local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
                            if state and isInSlot(x, y, w, h) then
                                breaked = true
                            elseif localPlayer:getData("Actionbar.enabled") and isInSlot(acx, acy, aw, ah) then
                                breaked = true
                            end

                            if not breaked then
                                isCursorHoverElement = hoverElement
                                isCursorHoverElementData = hoverElement:getData("worldItemData")
                            end
                        end
                    end
                end
            end
        end
    end, 200, 0
)

lastPickUpTick = -500
addEventHandler("onClientClick", root,
    function(b, s, abX, abY, wx, wy, wz, worldE)
        if b == "left" and s == "down" then
            if isElement(worldE) and worldE:getData("worldItemId") then
                if isCursorHoverElement and isCursorHoverElementData then
                    if isCursorHoverElement == worldE then
                        local yard = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                        if yard <= 2 then
                            local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                            local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                            local breaked = false
                            local acx, acy = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                            local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
                            if state and isInSlot(x, y, w, h) then
                                breaked = true
                            elseif localPlayer:getData("Actionbar.enabled") and isInSlot(acx, acy, aw, ah) then
                                breaked = true
                            end

                            if exports['cr_network']:getNetworkStatus() then return end
                            if getElementData(localPlayer, "char >> death") or getElementData(localPlayer, "inDeath") then return end
                            if getElementData(localPlayer, "inHorse") or getElementData(localPlayer, "inHorseE") then return end

                            if not localPlayer.vehicle then
                                if not breaked then
                                    local now = getTickCount()
                                    local a = 1
                                    if now <= lastPickUpTick + a * 1000 then
                                        exports['cr_infobox']:addBox("warning", "Csak "..a.." másodpercenként vehetsz fel itemeket!")
                                        return
                                    end
                                    lastPickUpTick = getTickCount()

                                    isCursorHoverElement = nil
                                    isCursorHoverElementData = nil
                                    triggerServerEvent("pickupWorldItem", localPlayer, localPlayer, worldE)
                                    worldE:destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)

createRender("drawnTooltip",
    function()
        if isCursorShowing() then
            if isCursorHoverElement and isCursorHoverElementData then
                local cx, cy = exports['cr_core']:getCursorPosition()
                renderTooltip(cx, cy, isCursorHoverElementData, 255)
            end
        end
    end
)

function upMove()
    if not positions then return end
    local isIn = false
    for i = 1,6 do
        local x,y,w,h = unpack(positions[i])
        h = h + 10
        if isInSlot(x,y,w,h) then
            isIn = true
        end
    end

    if isIn then
        if cminLines - 1 >= 1 then
            cminLines = cminLines - 1
            cmaxLines = cmaxLines - 1
        end
    end
end

function downMove()
    if not positions then return end
    local isIn = false
    for i = 1, 6 do
        local x,y,w,h = unpack(positions[i])
        h = h + 10
        if isInSlot(x,y,w,h) then
            isIn = true
        end
    end

    local index, num = 1, 0

    for k, v in pairs(craftG) do
        local ctype, listed, citems = unpack(v)

        if listed then
            if index >= cminLines and index <= cmaxLines then
                num = num + 1
            end

            for k2,v2 in pairs(citems) do
                local itemdata, crafttime, cdata, needed = unpack(v2)
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                index = index + 1
                if index >= cminLines and index <= cmaxLines then
                    num = num + 1
                end
            end
        else
            if index >= cminLines and index <= cmaxLines then
                num = num + 1
            end
        end
        index = index + 1
    end

    if isIn then
        if cmaxLines + 1 < index then
            cminLines = cminLines + 1
            cmaxLines = cmaxLines + 1
        end
    end
end

bindKey("mouse_wheel_up", "down", upMove)
bindKey("mouse_wheel_down", "down", downMove)

function giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
    triggerServerEvent("giveItem", sourceElement, sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
end
addEvent("giveItem", true)
addEventHandler("giveItem", root, giveItem)

function deleteItem(sourceElement, slot, itemid, ignoreTrigger, spec)
    local iType = items[itemid]["invType"]
    if activeSlot[iType .. "-" .. slot] then 
        local data = getItems(sourceElement, iType)[slot]

        if data then 
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

            useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt)
        end 
    end 

    triggerServerEvent("deleteItem", sourceElement, sourceElement, slot, itemid, ignoreTrigger, spec)
end
addEvent("deleteItem", true)
addEventHandler("deleteItem", root, deleteItem)

function updateItemDetails(sourceElement, slot, iType, details, needTrigger)
    triggerServerEvent("updateItemDetails", sourceElement, sourceElement, slot, iType, details, needTrigger)
end
addEvent("updateItemDetails", true)
addEventHandler("updateItemDetails", root, updateItemDetails)

function getItems(element, invType)
    local eType = getEType(element)
    local eId = getEID(element)
    checkTableArray(eType, eId, invType)

    return cache[eType][eId][invType]
end

function hasItem(element, itemID, itemValue)
    if not element or type(element) == "number" then
        element = localPlayer
    end

    if itemValue then
        for i = 1, 4 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                local iType = i --items[itemid][2]
                local isActive = false
                if activeSlot[iType .. "-" .. slot] then
                    if invElement == localPlayer then
                        isActive = true
                    end
                end

                if not isActive and itemid == itemID and value == itemValue then
                    return true, slot, data
                end
            end
        end

        return false
    else
        for i = 1, 4 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                local iType = i --items[itemid][2]
                local isActive = false
                if activeSlot[iType .. "-" .. slot] then
                    if invElement == localPlayer then
                        isActive = true
                    end
                end

                if not isActive and itemid == itemID then
                    return true, slot, data
                end
            end
        end

        return false
    end
end

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end

local maxDist = 150

local white = "#ffffff"

_addCommandHandler("nearbytrash",
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbytrash") then
            local syntax = getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő kukák: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("trash.id")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..white..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)

_addCommandHandler("nearbyworlditems",
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbytrash") then
            local syntax = getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő világitemek: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("worldItemId")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..white..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)

_addCommandHandler("nearbysafe",
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbysafe") then
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő széfek: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("safe.id")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..white..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)

function formatTimeStamp(t, onlyDatum)
    local time = getRealTime(t)
    local year = time.year
    local month = time.month+1
    local day = time.monthday
    local hours = time.hour
    local minutes = time.minute
    local seconds = time.second
    if(month < 10) then
        month = "0"..month
    end
    if(day < 10) then
        day = "0"..day
    end
    if (hours < 10) then
        hours = "0"..hours
    end
    if (minutes < 10) then
        minutes = "0"..minutes
    end
    if (seconds < 10) then
        seconds = "0"..seconds
    end
    return 1900+year .. "." ..  month .. "." .. day .. (onlyDatum and '' or (" - " .. hours .. ":" .. minutes))
end

local textHeights = {}

local interiorNames = {}

function getInteriorName(id)
    local id = id
    for k,v in pairs(getElementsByType("marker")) do
        if v:getData("marker >> data") and v:getData("marker >> data")["id"] == id then
            interiorNames[id] = v:getData("marker >> data")["name"]

            addEventHandler("onClientElementDataChange", v,
                function(dName)
                    if dName == "marker >> data" then
                        local id = source:getData("marker >> data")["id"]
                        interiorNames[id] = v:getData("marker >> data")["name"]
                    end
                end
            )

            break
        end
    end
end

local sx, sy = guiGetScreenSize()
function renderTooltip(startX, startY, data, alpha, specText)
    if interfaceDrawn then return end
    if not gColor then
        gColor = getServerColor(nil, true)
    end
    if not white then
        white = "#ffffff"
    end
    local w, h = drawnSize["left/right"][1], drawnSize["left/right"][2]
    if not count then count = 1 end
    if not value then value = 1 end
    local id, itemid, value, count, status, dutyitem, premium, nbt, name, weight, description, text

    if specText then
        if type(data) == "table" then
            local faction, location, blueprint = unpack(data)
            text = "#ffffffHely: " .. (location and "#d23131Szükséges" or "#7cc576Nem szükséges") .. "\n#ffffffSzervezet: " .. (faction and "#d23131Szükséges" or "#7cc576Nem szükséges") .. "\n#ffffffRecept: " .. (blueprint and "#d23131Szükséges" or "#7cc576Nem szükséges")
        else
            text = specText
        end
    else
        local white = "#ffffff"
        local gColor = "#3d7abc"
        id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        local count = count or 1
        name, weight, description = getItemName(itemid, value, nbt), GetData(itemid, value, nbt, "weight"), GetData(itemid, value, nbt, "description")
        local weightText = "\nSúly: "..gColor..weight * count.." kg"..white
        if not GetData(itemid, value, nbt, "disableWeightTextTooltip") then --items[itemid]["disableWeightTextTooltip"] then
            text = white .. "Név: #7cc576"..name..white.."@|@C@A"..weightText --Leírás: #7cc576"..description..white.."\n"
        else
            text = white .. "Név: #7cc576"..name..white.."@|@C@A"..white --Leírás: #7cc576"..description..white.."\n"
        end

        if GetData(itemid, value, nbt, "mask") then
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            text = string.gsub(text, "@A", "\nBecenév: " ..yellow..nbt["name"]..white.."")
        elseif isWeapon(itemid, value, nbt) and GetData(itemid, value, nbt, "ammoID") > 1 or GetData(itemid, value, nbt, "ammoID") == -4 and not GetData(itemid, value, nbt, "ignoreIdentity") then -- isWeapon
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            text = string.gsub(text, "@A", "\nAzonosító: " ..yellow..utf8.sub(md5(id), 1, 12)..white.."")
        elseif itemid == 15 then 
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            local orange = exports['cr_core']:getServerColor("orangeNew", true)
            local green = exports['cr_core']:getServerColor("green", true)
            if tostring(value):gsub(" ", ""):lower() == (""):lower() or tonumber(value) and tonumber(value) == 0 or not value then 
                value = "Ismeretlen"
            end 
            local service = nbt["service"]
            if service:gsub(" ", ""):lower() == (""):lower() then 
                service = "Nincs"
            end 

            if service:lower() ~= ("Nincs"):lower() then 
                text = string.gsub(text, "@A", "\nTelefonszám: " ..yellow..exports["cr_phone"]:formatPhoneNumber(value)..white.."\nSzolgáltató: "..orange..service..white.."\nEgyenleg: "..green..nbt["wallet"].." $"..white)
            else 
                text = string.gsub(text, "@A", "\nSzolgáltató: "..orange..service..white)
            end 
        elseif itemid == 33 then
            local yellow = exports['cr_core']:getServerColor("yellow", true)
            text = string.gsub(text, "@A", "\nAzonosító: " ..yellow..utf8.sub(md5(id), 1, 5)..white.."")
        elseif itemid == 35 then 
            text = string.gsub(text, "@A", "\nÉrték: #7cc576"..value..white)
        elseif itemid == 36 then 
            local badgeContent = nbt["badgeContent"]
            local orange = exports["cr_core"]:getServerColor("orangeNew", true)

            text = string.gsub(text, "@A", "\nJelvényszám: "..orange..badgeContent..white)
        else
            text = string.gsub(text, "@A", "")
        end

        if dutyitem == 1 then
            text = string.gsub(text, "@|", " #D23131[Dutyitem]" .. white)
        else
            text = string.gsub(text, "@|", "")
        end

        if premium ~= 0 then
            local gText = " #FFA800[Prémium]" .. white
            text = string.gsub(text, "@C", gText)
        else
            local gText = ""
            text = string.gsub(text, "@C", gText)
        end

        if itemid == 16 and tonumber(nbt) and tonumber(nbt) > 1 then
            local vehName = exports['cr_vehicle']:getVehicleName(nbt)
            text = text .. " #7cc576["..vehName.."]" .. white .. weightText
        end

        if itemid == 17 or itemid == 18 then
            if not interiorNames[value] then
                interiorNames[value] = ""
                getInteriorName(value)
            end
            local vehName = interiorNames[value]
            text = text .. " #7cc576["..vehName.."]" .. white .. weightText
        end

        if GetData(itemid, value, nbt, "isStatus") then --items[itemid]["isStatus"] then -- isStatus
            local color = {}
            if status <= 25 then
                color = {210,49,49}
            elseif status <= 50 then
                color = {244,137,66}
            elseif status <= 75 then
                color = {255, 168, 0}
            elseif status <= 100 then
                color = {124,197,118}
            end
            color = RGBToHex(unpack(color))
            text = text .. "\nÁllapot: "..color..status.."%"..white
        else
            if itemid == 16 or itemid == 17 or itemid == 18 or itemid == 20 or itemid == 29 then
                text = text .. "\nAzonosító: #7cc576"..value..white
            elseif itemid == 97 then
                text = text .. "\nKártyaszám: #7cc576"..exports['cr_bank']:formatCardNumber(value)..white
            elseif itemid == 78 or itemid == 77 or itemid == 82 or itemid == 25 or itemid == 28 or itemid == 148 then
                text = text .. "\nTulajdonos: #7cc576"..(value.name)..white .. "\nLejárat: #7cc576"..formatTimeStamp(value.endDate, true)..white
            elseif itemid == 80 then
                if type(value) == "table" then 
                    local isVehicle = value.isVehicle
                    local isInterior = value.isInterior

                    if isVehicle then 
                        local vehicleName = value.vehicleName
                        local vehiclePrice = value.price
                        local date = value.date

                        if vehicleName and vehiclePrice and date then 
                            text = text .. "\nJármű neve: #7cc576" .. vehicleName .. white .. "\nÁr: #7cc576$"  .. vehiclePrice .. white .. "\nDátum: #7cc576" .. date .. white
                        end
                    elseif isInterior then
                        local interiorName = value.interiorName
                        local interiorPrice = value.price
                        local date = value.date

                        if interiorName and interiorPrice and date then 
                            text = text .. "\nIngatlan címe: #7cc576" .. interiorName .. white .. "\nÁr: #7cc576$"  .. interiorPrice .. white .. "\nDátum: #7cc576" .. date .. white
                        end
                    end
                end
            elseif itemid == 149 then
                text = text .. "\nNév: #7cc576" .. value.name .. white .. "\nBeosztás: #7cc576" .. value.rank .. white .. "\nAzonosító: #7cc576#" .. "#7cc576" .. value.serial .. white 
            elseif itemid == 132 then
                local bulletName
                if type(value[2]) == "number" then
                    bulletName = getItemName(value[2], 1, 0)
                else
                    bulletName = value[2]
                end
                text = text .. "\nFegyver azonosító: #7cc576"..value[1]..white.."\nLőszer típus: #7cc576"..bulletName..white
            elseif itemid == 128 then
                if type(value) == "table" then 
                    local cost = value["penalty"]

                    if cost then 
                        if tonumber(value["timestamp"]) < getRealTime()["timestamp"] then
                            cost = cost * 2
                        end

                        text = text .. "\nIndok: #7cc576"..value["reason"]..white.."\nBírság: #7cc576$" .. cost .. white .. "\nLejárat: #7cc576"..formatTimeStamp(value["timestamp"])
                    end
                end
            elseif itemid == 159 then
                if type(value) == "number" then 
                    text = text .. "\nTartalom: #7cc576$" .. value
                end
            elseif itemid == 19 then
                text = text .. "\nFrekvencia: #7cc576"..value..white
            end
        end
    end

    local specData = {["alpha"] = alpha}
    if data["size"] then
        specData["size"] = data["size"]
    end
    
    exports['cr_dx']:drawTooltip(2, text, {startX, startY, specData})
end

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)

	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function hasKey(type, id)
    local itemid = convertKey(type);
    return hasItem(localPlayer, itemid, id);
end


function openBoot(worldE)
    if localPlayer:getData("keysDenied") then 
        return 
    end

    if isEnabledTypeForOpen[getVehicleType(worldE)] then
        if not getElementData(worldE, "inventory.open") then
            local eId = getEID(worldE)
            local itemid = convertKey("vehicle")
            if worldE:getData("veh >> boot") then
                if getElementData(worldE, "drone >> isDrone") or getElementData(worldE, "veh >> temporaryVehicle") or getElementData(worldE, "veh >> job") then return end
                setElementData(worldE, "inventory.open", localPlayer)
                exports['cr_chat']:createMessage(localPlayer, "belenézz a jármű csomagtartójába ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                state = true
                openInventory(worldE)
                invType = specTypes["vehicle"]
                return
            else
                local syntax = getServerSyntax("Inventory", "error")
                exports['cr_infobox']:addBox("error", "Ezt az inventory-t nem tudod megnyitni mert zárva van a csomagtartója!")
                return
            end
        else
            local syntax = getServerSyntax("Inventory", "error")
            exports['cr_infobox']:addBox("error", "Ez az inventory jelenleg használatban van!")
            return
        end
    else
        local syntax = getServerSyntax("Inventory", "error")
        exports['cr_infobox']:addBox("error", "Ennél a fajta járműnél nem lehetséges a csomagtartó megnyitása.")
        return
    end
end

function openSafe(worldE)
    if localPlayer:getData("keysDenied") then 
        return 
    end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then
        if getDistanceBetweenPoints3D(worldE.position, localPlayer.position) > 3 then
            return
        end

        if not getElementData(worldE, "inventory.open") then
            local eId = getEID(worldE)
            local itemid = convertKey("safe")
            local hasKey = hasItem(localPlayer, itemid, eId)
            if hasKey or exports['cr_permission']:hasPermission(localPlayer, 'forceSafeOpen') then
                setElementData(worldE, "inventory.open", localPlayer)
                exports['cr_chat']:createMessage(localPlayer, "kinyitja egy közelében lévő széf ajtaját", 1)
                state = true
                openInventory(worldE)
                invType = specTypes["object"]

                if exports.cr_permission:hasPermission(localPlayer, "forceSafeOpen") and not hasKey then 
                    local localName = exports.cr_admin:getAdminName(localPlayer, true)

                    local adminSyntax = exports.cr_admin:getAdminSyntax()
                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local white = "#ffffff"

                    exports.cr_logs:addLog(localPlayer, "SafeOpening", "SafeOpen", localName .. " kulcs nélkül belenézett egy széfbe. Széf id: " .. eId)
                    exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " kulcs nélkül belenézett egy széfbe. " .. hexColor .. "(" .. eId .. ")", 8)
                end

                return
            else
                local syntax = getServerSyntax("Inventory", "error")
                exports['cr_infobox']:addBox("error", "Ezt az inventory-t nem tudod megnyitni mert vagy nincs hozzá kulcsod vagy pedig zárva van!")
                return
            end
        else
            local syntax = getServerSyntax("Inventory", "error")
            exports['cr_infobox']:addBox("error", "Ez az inventory jelenleg használatban van!")
            return
        end
    end
end

function destroySafe(worldE)
    local eId = getEID(worldE)
    local itemid = convertKey("safe")
    local hasKey, slot, data = hasItem(localPlayer, itemid, eId)
    if hasKey then
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        worldE:setData("inventory.open", nil)

        local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType, true)
        local eType = getEType(localPlayer)
        local eId = getEID(localPlayer)
        cache[eType][eId][invType][slot] = nil

        cancelMove(5)
        giveItem(localPlayer, 72, 1)

        triggerServerEvent("deleteSafe", localPlayer, localPlayer, nil, worldE:getData("safe.id"), true)
    else
        local syntax = getServerSyntax("Inventory", "error")
        exports['cr_infobox']:addBox("error", "Ez a széf nem felvehető hisz nincs hozzá kulcsod!")
        return
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "safe >> movedBy" then
            local val = source:getData(dName)
            if val then
                if oValue then
                    if val ~= oValue then
                        if localPlayer == val then
                            exports['cr_elementeditor']:resetEditorElementChanges(true)
                        end
                    end
                end
            end
        end
    end
)

addEvent("onSaveSafePositionEditor",true)
addEventHandler("onSaveSafePositionEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
        triggerServerEvent("updateSafePosition", localPlayer, element, {x,y,z,rx,ry,rz})
        triggerServerEvent("safeChangeState", localPlayer, element, 255)
        element:setData("safe >> movedBy", nil)
    end
)

addEvent("onSaveSafeDeleteEditor", true)
addEventHandler("onSaveSafeDeleteEditor", root,
    function(element, x, y, z, rx, ry, rz, scale)
        triggerServerEvent("safeChangeState", localPlayer, element, 255)
        element:setData("safe >> movedBy", nil)
    end
)

function worldItemInteract(wx, wy, wz)
    if not moveDetails then 
        cancelMove()
        return
    end 

    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
    if isKey(itemid, value, nbt) then
        cancelMove()
        return
    end

    if stacking then
        cancelMove()
        return
    end

    if invElement ~= localPlayer then
        cancelMove()
        return
    end

    local disableChatInteract = nil
    local pos = Vector3(wx, wy, wz)

    if itemid == 22 then
        if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
            local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
            cancelMove(5)
            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            cancelMove(3)
            exports['cr_chat']:createMessage(localPlayer, "lehelyez a földre egy hifit", 1)
            triggerServerEvent("createHifi", localPlayer, localPlayer, wx,wy,wz, localPlayer.dimension, localPlayer.interior)
            
            return
        else
            disableChatInteract = {"box", {"error", "Túl messzire szeretnéd lehelyezni a hifit!"}}
        end
    elseif GetData(itemid, value, nbt, "isFurniture") then 
        if not localPlayer:getData("inInterior") then
            exports['cr_infobox']:addBox("error", "Nem vagy interiorban!")
            cancelMove()
            return
        end

        local markerData = localPlayer:getData("inInterior"):getData("marker >> data")
        local canPlaceFurniture = false
        local needLog = false

        if markerData.faction and markerData.faction > 0 then 
            if exports.cr_dashboard:hasPlayerPermission(localPlayer, markerData.faction, "interior.customization") or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, markerData.faction) then 
                canPlaceFurniture = true
                needLog = true
            end
        elseif markerData.owner == localPlayer:getData("acc >> id") then
            canPlaceFurniture = true
        end

        if not canPlaceFurniture then
            exports['cr_infobox']:addBox("error", "Ez nem a te interiorod!")
            cancelMove()
            return
        end

        if needLog then 
            local localName = exports.cr_admin:getAdminName(localPlayer)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local white = "#ffffff"

            triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, markerData.faction, hexColor .. localName .. white .. " lehelyezett egy bútort.")
        end

        if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
            cancelMove()
            local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
            removeItemFromSlot(invType, moveSlot, 1)

            exports['cr_chat']:createMessage(localPlayer, "lehelyez egy bútort", 1)
            triggerLatentServerEvent("createFurniture", 5000, false, localPlayer, localPlayer, GetData(itemid, value, nbt, "furnitureObjID"), wx,wy,wz, localPlayer.dimension, localPlayer.interior)
            return
        else
            disableChatInteract = {"box", {"error", "Túl messzire szeretnéd lehelyezni a bútort!"}}
        end
    elseif itemid == 72 then
        if localPlayer:getData("inInterior") then
            local markerData = localPlayer:getData("inInterior"):getData("marker >> data") or {}
            local canPlaceSafe = false
            local needLog = false

            if markerData.faction and markerData.faction > 0 then 
                if exports.cr_dashboard:hasPlayerPermission(localPlayer, markerData.faction, "interior.customization") or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, markerData.faction) then 
                    canPlaceSafe = true
                    needLog = true
                end
            elseif markerData.owner == localPlayer:getData("acc >> id") then
                canPlaceSafe = true
            end

            if canPlaceSafe then 
                if needLog then 
                    local localName = exports.cr_admin:getAdminName(localPlayer)
                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local white = "#ffffff"

                    triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, markerData.faction, hexColor .. localName .. white .. " lehelyezett egy széfet.")
                end

                if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
                    local objectsInDim = 0
                    for k,v in pairs(getElementsByType("object")) do
                        if v.dimension == localPlayer.dimension and v.interior == localPlayer.interior and v.model == 2332 and v:getData("safe.id") then
                            objectsInDim = objectsInDim + 1
                            if objectsInDim == max then 
                                break 
                            end 
                        end
                    end

                    local max = tonumber(localPlayer:getData("inInterior"):getData("marker >> data")['maxSafe'] or 3)
                    if objectsInDim + 1 <= max then
                        cancelMove(5)
                        setTimer(triggerServerEvent, 200, 1, "createSafe", localPlayer, localPlayer, nil, true, {pos.x, pos.y, pos.z + 0.5}, {0, 0, exports['cr_core']:findRotation(localPlayer.position.x, localPlayer.position.y, pos.x, pos.y)})
                        local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                        cancelMove(3)

                        exports['cr_chat']:createMessage(localPlayer, 'lehelyez egy széfet', 1)
                        return
                    else
                        disableChatInteract = {"box", {"error", "Ez a széf nem helyezhető le hisz már elérted a limitet ("..max..")!"}}
                    end
                else
                    disableChatInteract = {"box", {"error", "Túl messzire szeretnéd lehelyezni a széfet!"}}
                end
            else
                disableChatInteract = {"box", {"error", "Csak saját interiorban helyezhető le széf"}}
            end
        else
            disableChatInteract = {"box", {"error", "Csak interiorban helyezhető le széf"}}
        end
    else
        if localPlayer.interior < 1 then
            cancelMove()
            return
        end

        if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 3 then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
            if not GetData(itemid, value, nbt, "disableDrop") then
                if dutyitem ~= 1 then
                    local objID = GetData(itemid, value, nbt, "objectID")
                    if objID and objID[1] then
                        if not localPlayer.vehicle then
                            local pos = {objID[1], wx + objID[2], wy + objID[3], wz + objID[4], 0, localPlayer.dimension, localPlayer.interior}
                            local itemDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                            cancelMove(5)
                            triggerServerEvent("createWorldItem", localPlayer, localPlayer, itemDetails, moveSlot, pos)

                            cancelMove(3)
                            return
                        end
                    end
                end
            end
        end
    end

    if disableChatInteract then
        if type(disableChatInteract) == "table" then
            if disableChatInteract[1] == "chat" then
                outputChatBox(disableChatInteract[2], 255,255,255,true)
            elseif disableChatInteract[1] == "box" then
                exports['cr_infobox']:addBox(disableChatInteract[2][1], disableChatInteract[2][2])
            end
        end
    else
        local syntax = getServerSyntax("Inventory", "error")
        exports['cr_infobox']:addBox("error", "Ezzel a tárggyal nem végezhető ilyen interakció. (Kidobás / Lehelyezés)")
    end

    cancelMove()
end