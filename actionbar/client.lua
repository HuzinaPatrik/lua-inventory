local lastItem = 0

gNum = 255

isInUse = {}

function getNode(Name, column)
    local enabled, x,y,w,h,sizable,turnable, sizeDetails, t, columns = getDetails(Name)
    if enabled then
        if column == "x" then
            return tonumber(x)
        elseif column == "y" then
            return tonumber(y)
        elseif column == "w" or column == "width" then
            return tonumber(w)
        elseif column == "h" or column == "height" then
            return tonumber(h)
        elseif column == "type" then
            return tonumber(t)
        elseif column == "columns" then
            return tonumber(columns)
        end
    end
    return 0;
end

function DxDrawActionbar()
    local alpha = gNum
    
    font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    font3 = exports['cr_fonts']:getFont("Rubik-Regular", 10)
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    
    local _ax, _ay = ax, ay
    local enabled, ax,ay,aw,ah,sizable,turnable, sizeDetails, acType, columns = getDetails("Actionbar")
    
    if acType == 1 then
        local w, h = (drawnSize["bg_cube"][1] * columns + (columns * 5)) + 5, 50
        dxDrawRectangle(ax, ay, w, h, tocolor(51, 51, 51, alpha * 0.8))
        
        local _w = w
        
        local startX = ax + 5
        local startY = ay + 5
        
        if not isTableArray(1, accID, 10) then 
            checkTableArray(1, accID, 10)
            return
        end
        
        local data = cache[1][accID][10]
        
        if isCursorShowing() and interfaceDrawn then
            local aw = aw
            dxDrawRectangle(ax + aw, ay, 20, 20, tocolor(51, 51, 51, alpha * 0.9))
            if isInSlot(ax + aw, ay, 20, 20) then
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(242,242,242,alpha), 1, font, "center", "center")
            else
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(242,242,242,alpha * 0.6), 1, font, "center", "center")
            end
            
            dxDrawRectangle(ax + aw, ay + 20, 20, 20, tocolor(51, 51, 51, alpha * 0.9))
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(242,242,242,alpha), 1, font, "center", "center")
            else
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(242,242,242,alpha * 0.6), 1, font, "center", "center")
            end
        end
        local tooltip = false
        for i = 1, columns do
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            
            if isInSlot(startX, startY, w, h) or getKeyState(i) and not isConsoleActive() and not guiState then
                dxDrawRectangle(startX, startY, w, h, tocolor(92, 165, 86, alpha))
                if not getKeyState(i) then
                    isIn = true
                    _lastItem = lastItem
                    lastItem = i
                end
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.9))
            end

            if data then
                local data = data[i]
                if data then
                    local _invType = invType
                    local invType, pairSlot = unpack(data)
                    local data = cache[1][accID][invType][pairSlot]
                    if moveState then
                        if pairSlot == moveSlot and invType == _invType then
                            data = moveDetails
                        end
                    end
                    
                    local isActive = false
                    if activeSlot[invType .. "-" .. pairSlot] then
                        isActive = true
                    end
                    
                    if data then
                        
                        if isActive and not isIn then
                            dxDrawRectangle(startX, startY, w, h, tocolor(124,197,118, alpha))
                        end
                        
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if isIn then
                            tooltip = i
                            tooltipD = data
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

                        if count >= 2 then
                            dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                        end
                    end
                end
            end
            
            startX = startX + w + 5
        end
        
        if tooltip then
            local data = tooltipD
            local cx, cy = exports['cr_core']:getCursorPosition()
            renderTooltip(cx, cy, data, alpha)
            tooltip = false
        end
        
    elseif acType == 2 then
        local w, h = 50, (drawnSize["bg_cube"][2] * columns + (columns * 5)) + 5
        dxDrawRectangle(ax, ay, w, h, tocolor(51, 51, 51, alpha * 0.8))
        
        if isCursorShowing() and interfaceDrawn then
            local aw = aw
            dxDrawRectangle(ax + aw, ay, 20, 20, tocolor(51, 51, 51, alpha * 0.9))
            if isInSlot(ax + aw, ay, 20, 20) then
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(242,242,242,alpha), 1, font, "center", "center")
            else
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(242,242,242,alpha * 0.6), 1, font, "center", "center")
            end
            
            dxDrawRectangle(ax + aw, ay + 20, 20, 20, tocolor(51, 51, 51, alpha * 0.9))
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(242,242,242,alpha), 1, font, "center", "center")
            else
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(242,242,242,alpha * 0.6), 1, font, "center", "center")
            end
        end
        
        local _h = h
        
        local startX = ax + 5
        local startY = ay + 5
        
        if not isTableArray(1, accID, 10) then 
            checkTableArray(1, accID, 10)
            return
        end
        local data = cache[1][accID][10]
        local tooltip = false
        for i = 1, columns do
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            
            if isInSlot(startX, startY, w, h) or getKeyState(i) and not isConsoleActive() and not guiState then
                dxDrawRectangle(startX, startY, w, h, tocolor(92, 165, 86, alpha))
                if not getKeyState(i) then
                    isIn = true
                    _lastItem = lastItem
                    lastItem = i
                end
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.9))
            end

            if data then
                local data = data[i]
                if data then
                    local _invType = invType
                    local invType, pairSlot = unpack(data)
                    local data = cache[1][accID][invType][pairSlot]
                    if moveState then
                        if pairSlot == moveSlot and invType == _invType then
                            data = moveDetails
                        end
                    end
                    
                    local isActive = false
                    if activeSlot[invType .. "-" .. pairSlot] then
                        isActive = true
                    end
                    
                    if data then
                        
                        if isActive and not isIn then
                            dxDrawRectangle(startX, startY, w, h, tocolor(124,197,118, alpha))
                        end
                        
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if isIn then
                            tooltip = i
                            tooltipD = data
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

                        if count >= 2 then
                            dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                        end
                    end
                end
            end
            
            startY = startY + h + 5
        end
        
        if tooltip then
            local data = tooltipD
            local cx, cy = exports['cr_core']:getCursorPosition()
            renderTooltip(cx, cy, data, alpha)
            tooltip = false
        end
    end
    
    if craftMoveState then
        local cx, cy = getCursorPosition()
        local x, y = cx - _ax, cy - _ay
        local data = moveDetails
        if data then
            local _invType = invType
            local invType, pairSlot, id = unpack(data)
            local data = cache[1][accID][invType][pairSlot]
            if data then
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
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
    end
end

addEventHandler("onClientResourceStart",resourceRoot,
    function()     
        if getElementData(localPlayer, "loggedIn") and getElementData(localPlayer, "hudVisible") and getElementData(localPlayer, "Actionbar.enabled") and getElementData(root, "loaded") then
            --addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
            createRender("DxDrawActionbar", DxDrawActionbar)
        end	
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "loggedIn" then
            local value = getElementData(source, dName)
            if value then
                if getElementData(source, "hudVisible") and source:getData("Actionbar.enabled") and getElementData(root, "loaded") then
                    --addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                    createRender("DxDrawActionbar", DxDrawActionbar)
                end
            else
                --removeEventHandler("onClientRender",root,DxDrawActionbar)
                destroyRender("DxDrawActionbar")
            end
        elseif dName == "hudVisible" then
            local value = getElementData(source, dName)
            if value then
                if getElementData(source, "loggedIn") and source:getData("Actionbar.enabled") and getElementData(root, "loaded") then
                    --addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                    createRender("DxDrawActionbar", DxDrawActionbar)
                end
            else
                --removeEventHandler("onClientRender",root,DxDrawActionbar)
                destroyRender("DxDrawActionbar")
            end    
        elseif dName == "Actionbar.enabled" then
            local value = getElementData(source, dName)
            if value then
                if getElementData(source, "loggedIn") and getElementData(source, "hudVisible") and getElementData(root, "loaded") then
                    --addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                    createRender("DxDrawActionbar", DxDrawActionbar)
                end
            else
                --removeEventHandler("onClientRender",root,DxDrawActionbar)
                destroyRender("DxDrawActionbar")
            end    
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "loaded" then
            local value = getElementData(root, "loaded")
            if value then
                if getElementData(localPlayer, "hudVisible") and localPlayer:getData("Actionbar.enabled") and localPlayer:getData("loggedIn") then
                    --addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                    createRender("DxDrawActionbar", DxDrawActionbar)
                end
            end
        end
    end
)


bindKey("mouse3", "down",
    function()
        local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
        local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
        local acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
    
        local w, h = (drawnSize["bg_cube"][1] * columns + (columns * 5)) + 5, 50
        if isInSlot(ax, ay, aw, ah) then
            local a = 1
            if acType == 1 then
                a = 2
            end
            
            local w,h = (drawnSize["bg_cube"][1] * columns + (columns * 5)) + 5, 50
            
            if a == 2 then
                h = w
                w = 50
            end
            
            exports['cr_interface']:setNode("Actionbar", "type", a)
            exports['cr_interface']:setNode("Actionbar", "width", w)
            exports['cr_interface']:setNode("Actionbar", "height", h)
        end
    end
)

addCommandHandler("togactionbar", 
    function(subTag) 
        gNum = gNum == 0 and 255 or 0
        
        if subTag then
            --Klienset optimalizáló szar
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" and isCursorShowing() and interfaceDrawn then
            local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
            local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
            if isInSlot(ax + aw, ay, 20, 20) then
                local oldColumns = getNode("Actionbar", "columns")
                if oldColumns + 1 <= 9 then
                    exports['cr_interface']:setNode("Actionbar", "columns", oldColumns + 1)
                    
                    local acType = getNode("Actionbar", "type")
                    if acType == 1 then
                        local w, h = (drawnSize["bg_cube"][1] * (oldColumns + 1) + ((oldColumns + 1) * 5)) + 5, 50
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    else
                        local w, h = 50, (drawnSize["bg_cube"][1] * (oldColumns + 1) + ((oldColumns + 1) * 5)) + 5
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    end
                end
            end
            
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                local oldColumns = getNode("Actionbar", "columns")
                if oldColumns - 1 >= 1 then
                    exports['cr_interface']:setNode("Actionbar", "columns", oldColumns - 1)
                    
                    local acType = getNode("Actionbar", "type")
                    if acType == 1 then
                        local w, h = (drawnSize["bg_cube"][1] * (oldColumns - 1) + ((oldColumns - 1) * 5)) + 5, 50
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    else
                        local w, h = 50, (drawnSize["bg_cube"][1] * (oldColumns - 1) + ((oldColumns - 1) * 5)) + 5
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    end
                end
            end
        end
    end
)

for i = 1, 9 do
    bindKey(i, "down",
        function(i)
            if localPlayer:getData("keysDenied") then
                return
            end
            i = tonumber(i)
            
            local columns = getNode("Actionbar", "columns")
            
            if i <= columns then
                if localPlayer:getData("loggedIn") and not guiState then
                    local data = cache[1][accID][10]
                    if data then
                        local data = data[i]
                        if data then
                            local _invType = invType
                            local invType, pairSlot = unpack(data)
                            local data = cache[1][accID][invType][pairSlot]
                            if moveState then
                                if pairSlot == moveSlot and invType == _invType then
                                    data = moveDetails
                                end
                            end
                            if data then
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                useItem(pairSlot, id, itemid, value, count, status, dutyitem, premium, nbt, true)
                                playSound("assets/sounds/key.mp3")
                            end
                        end
                    end
                end
            end
        end, i
    )
end