local sx, sy = guiGetScreenSize()
local start, startTick, alpha, state, hovered
local key = 1
local _key = key - 1
local maxColumns, maxLines = 10, 5
iSearchCache = {}
iCache = 0

_addCommandHandler("itemlist",
    function()
        if not exports['cr_permission']:hasPermission(localPlayer, "itemlist") then return end
        state = not state
        if state then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "success")
            outputChatBox(syntax .. "Itemlista előhozva!", 255,255,255,true)
            start = true
            startTick = getTickCount()
            --_addEventHandler("onClientRender", root, drawnTurnablePanel, true, "low-5")
            createRender("drawnTurnablePanel", drawnTurnablePanel)
            CreateNewBar("itemlist>search", {0,0,0,0}, {20, "", false, tocolor(255,255,255,255), {"Poppins-Medium", 14}, 1, "left", "center"}, 1)
            --createLogoAnim()
            oldKeysDenied = localPlayer:getData("keysDenied")
            localPlayer:setData("keysDenied", true)
        else
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
            outputChatBox(syntax .. "Itemlista eltüntetve!", 255,255,255,true)

            closeItemList()
        end
    end
)

function closeItemList()
    if start then 
        RemoveBar("itemlist>search")
        start = false
        startTick = getTickCount()
        --stopLogoAnim()
        localPlayer:setData("keysDenied", oldKeysDenied)
    end 
end 

function drawnTurnablePanel()
    local font = exports['cr_fonts']:getFont("Roboto", 13)
    
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
            state = false
            --removeEventHandler("onClientRender", root, drawnTurnablePanel)
            destroyRender("drawnTurnablePanel")
        end
    end

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    
    hovered = nil

    local w, h = 470, 320
    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Item lista", x + 10 + 26 + 10,y+5,x+w,y+5+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    if isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        hovered = "close"
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, "assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, "assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawRectangle(x + 10, y + 45, 445, 25, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10 + 445 - 20, y + 45 + 25/2 - 15/2, 15, 15, ":cr_scoreboard/files/search.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    UpdatePos("itemlist>search", {x + 10 + 5, y + 45 + 2, 445, 25})
    UpdateAlpha("itemlist>search", tocolor(242, 242, 242, alpha))

    local startX, startY = x + 10, y + 80
    local _startX, _startY = startX, startY
    local nowColumn, nowLine = 1, 1
    local w, h = 40, 40

    for i = key, _key + (maxColumns * maxLines) do
        if iCache >= 1 and iSearchCache[i] then
            local img = getItemPNG(iSearchCache[i])
            dxDrawRectangle(startX, startY, w, h, tocolor(41, 41, 41, alpha * 0.9))

            if isInSlot(startX, startY, w, h) then
                hovered = iSearchCache[i]
                dxDrawImage(startX + 1, startY + 1, w - 2, h - 2, img, 0,0,0, tocolor(255,255,255,alpha))
            else
                dxDrawImage(startX + 1, startY + 1, w - 2, h - 2, img, 0,0,0, tocolor(255,255,255,alpha * 0.75))
            end
            nowColumn = nowColumn + 1
            startX = startX + 5 + w

            if nowColumn > maxColumns then
                startX = _startX
                nowColumn = 1
                nowLine = nowLine + 1
                startY = startY + 5 + h
            end
        elseif iCache <= 0 and items[i] then
            local img = getItemPNG(i)
            dxDrawRectangle(startX, startY, w, h, tocolor(41, 41, 41, alpha * 0.9))

            if isInSlot(startX, startY, w, h) then
                hovered = i
                dxDrawImage(startX + 1, startY + 1, w - 2, h - 2, img, 0,0,0, tocolor(255,255,255,alpha))
            else
                dxDrawImage(startX + 1, startY + 1, w - 2, h - 2, img, 0,0,0, tocolor(255,255,255,alpha * 0.75))
            end
            nowColumn = nowColumn + 1
            startX = startX + 5 + w

            if nowColumn > maxColumns then
                startX = _startX
                nowColumn = 1
                nowLine = nowLine + 1
                startY = startY + 5 + h
            end
        end
    end

    if tonumber(hovered) then
        local itemid = tonumber(hovered)
        local color = getServerColor("yellow", true)
        local white = "#ffffff"

        local cx, cy = exports['cr_core']:getCursorPosition()

        local specData = {["alpha"] = alpha}
        exports['cr_dx']:drawTooltip(2, "ItemID: "..color.. tonumber(hovered) ..white.."\nNév: "..color..items[itemid]["name"]..white.."\nSúly: "..color..items[itemid]["weight"]..white.." KG", {cx, cy, specData})
    end

    --scrollbar
    local x = x + 462
    local y = y + 80

    local w = 3
    local h = 220

    local percent = items
    if iCache >= 1 then
        percent = iSearchCache
    end
    
    if not percent[key + (maxColumns * (maxLines - 1))] then
        key = 1
        _key = key - 1
    end
    
    local percent = #percent
    local _percent = percent
    
    if percent / maxColumns ~= math.floor(percent / maxColumns) then
        percent = math.ceil(percent / maxColumns) * maxColumns
    end
    
    local multiplier = math.min(math.max((maxColumns * (maxLines)) / percent, 0), 1)
    local multiplier2 = math.min(math.max(_key / percent, 0), 1)

    dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, alpha * 0.6))
    local y = y + ((h) * multiplier2)

    local h = h * multiplier

    dxDrawRectangle(x, y, w, h, tocolor(255,59,59, alpha))
end    

bindKey("mouse_wheel_down", "down", 
    function()
        if state then
            if isInSlot(sx/2 - 503/2, sy/2-247/2, 503, 247) then
                key = key + maxColumns
                
                if iCache <= 0 then
                    if not items[key + (maxColumns * (maxLines - 1))] then
                        key = key - maxColumns
                    end
                else
                    if not iSearchCache[key + (maxColumns * (maxLines - 1))] then
                        key = key - maxColumns
                    end
                end
                
                _key = key - 1
            end
        end
    end
)

bindKey("mouse_wheel_up", "down", 
    function()
        if state then
            if isInSlot(sx/2 - 503/2, sy/2-247/2, 503, 247) then
                key = key - maxColumns
                
                if key <= 1 then
                    key = 1
                end
                
                _key = key - 1
            end
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if state then
            if b == "middle" and s == "down" then 
                if hovered then
                    if tonumber(hovered) then 
                        if exports['cr_permission']:hasPermission(localPlayer, "giveitem") then
                            selectedHovered = tonumber(hovered)
                            triggerEvent("dashboard.giveItemAlert", localPlayer, tonumber(hovered))
                        else
                            exports['cr_infobox']:addBox("error", "Neked nincs jogod az item addoláshoz!")
                        end
                    end 

                    hovered = nil 
                    return
                end 
            elseif b == "left" and s == "down" then 
                if hovered then
                    if hovered == "close" then 
                        closeItemList()
                    end 

                    hovered = nil 
                    return
                end 
            end
        end
    end
)

addEvent("giveSelectedItem", true)
addEventHandler("giveSelectedItem", root, 
    function(count)
        if tonumber(selectedHovered) and tonumber(count) then 
            giveItem(localPlayer, tonumber(selectedHovered), 1, tonumber(count))
            exports['cr_infobox']:addBox("success", "Sikeres addolás!")

            local adminSyntax = exports.cr_admin:getAdminSyntax()
            local localName = exports.cr_admin:getAdminName(localPlayer, true)
            local itemName = getItemName(tonumber(selectedHovered))

            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local white = "#ffffff"

            exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adott magának " .. hexColor .. tonumber(count) .. white .. " db " .. hexColor .. itemName .. white .. " nevű tárgyat.", 3)
        end 
    end 
)