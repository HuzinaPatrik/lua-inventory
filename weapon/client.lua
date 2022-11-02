local started = false
local id = getPedWeapon(localPlayer)
setTimer(
    function()
        id = getPedWeapon(localPlayer)
    end, 100, 0
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "loggedIn") then
            if getElementData(localPlayer, "weapon.enabled") then
                --addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
                createRender("drawnWeapon", drawnWeapon)
            end
        end
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "loggedIn" then        
            --id = getElementData(localPlayer, "id") or -1
            if getElementData(localPlayer, "weapon.enabled") then
                --addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
                createRender("drawnWeapon", drawnWeapon)
            end
        elseif dName == "weapon.enabled" then
            if not localPlayer:getData("weapon-damage.enabled") then 
                local value = getElementData(source, dName)
                if value then
                    --addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
                    createRender("drawnWeapon", drawnWeapon)
                else
                    --removeEventHandler("onClientRender", root, drawnWeapon)
                    destroyRender("drawnWeapon")
                end 
            end
        elseif dName == "weapon-damage.enabled" then 
            if not localPlayer:getData("weapon.enabled") then 
                local value = localPlayer:getData(dName)

                if value then 
                    createRender("drawnWeapon", drawnWeapon)
                else
                    destroyRender("drawnWeapon")
                end
            end
        end
    end
)

local nodes = {}
local nodesT = {}

function getDetails(...)
    return exports['cr_interface']:getDetails(...)
end

gwMultipler = 0

function drawnWeapon()
    local enabled,sx,sy,sw,sh,sizable,turnable = getDetails("weapon")
    --if not enabled then return end
    
    --_dxDrawRectangle(sx, sy, sw, sh, tocolor(55, 55, 55-, 255))

    --local id = getPedWeapon(localPlayer)
    if enabled and getElementData(localPlayer, "hudVisible") then
        dxDrawImage(sx - 1, sy - 2, 128, 64, ":cr_interface/weapon/files/_w"..id..".png")
    end
    
    local enabled,sx,sy,sw,sh,sizable,turnable = getDetails("weapon-damage")
    
    if disabled then return end
    if weaponInHand then
        local a2 = gwMultipler
        if a2 ~= wMultipler then
            if not aAnimating then
                animate(gwMultipler, wMultipler, "Linear", (isItStartAnim and 1000) or 175, 
                    function(v)
                        gwMultipler = v
                    end,

                    function()
                        if isItStartAnim then
                            isItStartAnim = nil
                        end
                        aAnimating = false
                    end, "animating"
                )

                aAnimating = true
            end
        end
        
        if enabled and getElementData(localPlayer, "hudVisible") then
            local font = exports['cr_fonts']:getFont("Poppins-Bold", 10)
            local _id = id
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            local slot2, data = unpack(hasData)

            --local maximum_clip_ammo = getWeaponProperty(_id, "poor", "maximum_clip_ammo") or 30
            dxDrawImage(sx + sw - 60, sy, 60, 20, "assets/images/weapon-status-bg.png", 0, 0, 0, tocolor(255, 255, 255, 255))
            dxDrawText(localPlayer:getAmmoInClip() .. ' | ' .. ammo, sx + sw - 60, sy, sx + sw - 60 + 60, sy + 24, tocolor(242, 242, 242, 255), 1, font, "center", "center")

            local size = 0
            local w, h = 105, 15
            local x, y = sx + size, sy + 27
            --_dxDrawRectangle(x, y, w, 15, tocolor(44, 44, 55, 255))
            dxDrawRectangle(x,y,w,h, tocolor(51, 51, 51, 255 * 0.6))
            dxDrawRectangle(x + 2,y + 2,(w - 4) * (gwMultipler / 100),h - 4, tocolor(255, 59, 59, 255))
            dxDrawText(math.floor(gwMultipler).."%", x,y + 2, x + w - 5,y + 2 + (h - 4) + 2, tocolor(242,242,242,255), 1, font, "right", "center", false, false, false, true)
        end
    end
end    

addEventHandler("onClientPreRender", root,
	function(timeSlice)
		for k, fireStartedTick in pairs(weaponHeatTick) do
			if getTickCount() - fireStartedTick >= 500 then
				if weaponHeatTable[k] <= 25 then
					weaponHeatTable[k] = weaponHeatTable[k] + overheatDecreaseValues[usedWeaponCache[k]] * 0.5 * timeSlice
                    if weaponInHand and weaponInHandDBID == k then
                        wMultipler = weaponHeatTable[k]
                    end
				else
					weaponHeatTable[k] = weaponHeatTable[k] + overheatDecreaseValues[usedWeaponCache[k]] * timeSlice
                    if weaponInHand and weaponInHandDBID == k then
                        wMultipler = weaponHeatTable[k]
                    end
				end
                
                if weaponHeatTable[k] > 25 then
                    if weaponHeatedTable[k] then
                        weaponHeatedTable[k] = nil
                        
                        if weaponInHand and weaponInHandDBID == k then
                            if canShot then
                                exports['cr_controls']:toggleControl("fire", true, "high")
                                exports['cr_controls']:toggleControl("vehicle_fire", true, "high")
                                exports['cr_controls']:toggleControl("action", false, "high")
                            end
                        end
                    end
				end
                
                if weaponHeatTable[k] > 100 then
					weaponHeatTable[k] = 100
                    if weaponInHand and weaponInHandDBID == k then
                        wMultipler = weaponHeatTable[k]
                    end
					weaponHeatTick[k] = nil
				end
			end
		end
	end
)

--
local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function animate(f, t, easing, duration, onChange, onEnd, boolean)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    if boolean then
        anims[boolean] = {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd}
    else
	   table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
    end
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
    started = false
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in pairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
            if type(k) == "number" then
			    table.remove(anims, k)
            else
                anims[k] = nil
            end
		end
	end
end)

screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()
    --outputChatBox(tostring(isCursorShowing()))
    if isCursorShowing() then
        --outputChatBox("asd")
        local x,y = getCursorPos()
        --outputChatBox("x"..tostring(x)
        --outputChatBox("y"..tostring(y))
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition()
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end