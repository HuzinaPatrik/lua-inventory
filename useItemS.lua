local objs = {}

addEvent("giveWeaponH", true)
addEventHandler("giveWeaponH", root,
    function(sourceElement, weaponID, ammo, itemid, value, nbt)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                local _weaponID = weaponID
                if weaponID == -1 then weaponID = 24 end
                giveWeapon(sourceElement, weaponID, 99999, true)
                
                --[[
                if getWeaponProperty(weaponID, "poor", "maximum_clip_ammo") ~= 1000 then 
                    setWeaponProperty(weaponID, "poor", "maximum_clip_ammo", 1000)
                    setWeaponProperty(weaponID, "std", "maximum_clip_ammo", 1000)
                    setWeaponProperty(weaponID, "pro", "maximum_clip_ammo", 1000)
                end ]]
                
                local weaponID = _weaponID
                
                --outputChatBox(tonumber(itemid or -1))
                local obj
                if tonumber(itemid or -1) == 51 then
                    obj = Object(17426, sourceElement.position)
                    obj.collisions = false
                    obj.interior = sourceElement.interior
                    obj.dimension = sourceElement.dimension
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.03,-0.03,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
                elseif tonumber(itemid or -1) == 127 then
                    obj = Object(10012, sourceElement.position)
                    obj.collisions = false
                    obj.interior = sourceElement.interior
                    obj.dimension = sourceElement.dimension
                    sourceElement:setData("taser>obj", obj)
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.01,0,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
				elseif tonumber(itemid or -1) == 52 then 
                    obj = Object(7572, sourceElement.position)
                    obj.collisions = false
                    obj.interior = sourceElement.interior
                    obj.dimension = sourceElement.dimension
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.03,-0.03,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
				elseif tonumber(itemid or -1) == 171 then
                    obj = Object(8082, sourceElement.position)
                    obj.collisions = false
                    obj.interior = sourceElement.interior
                    obj.dimension = sourceElement.dimension
                    sourceElement:setData("taser>obj", obj)
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.01,0,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
				end
                
                if isElement(obj) then
                    triggerClientEvent(sourceElement, "pj>apply", sourceElement, itemid, value, nbt, obj)
                end
            end
        end
    end
)

addEvent("takeAllWeapons", true)
addEventHandler("takeAllWeapons", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                takeAllWeapons(sourceElement)
                
                destroyTaser(sourceElement)
            end
        end
    end
)

addEvent("reloadPedWeapon", true)
addEventHandler("reloadPedWeapon", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                reloadPedWeapon(sourceElement)
            end 
        end 
    end 
)

addEvent("setWeaponAmmo", true)
addEventHandler("setWeaponAmmo", root,
    function(sourceElement, weaponID, ammo)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                setWeaponAmmo(sourceElement, weaponID, 99999)
            end
        end
    end
)

--[[
addEvent("weaponAnim", true)
addEventHandler("weaponAnim", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                local anim = sourceElement:getData("forceAnimation") or {"", ""}
                if anim[1] ~= "" or anim[2] ~= "" then 
                    return 
                end
                sourceElement:setData("forceAnimation", {"COLT45", "sawnoff_reload", 500, false, false, false, false})
            end
        end
    end
)

addEvent("anim", true)
addEventHandler("anim", root,
    function(sourceElement, details)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                local anim = sourceElement:getData("forceAnimation") or {"", ""}
                if anim[1] ~= "" or anim[2] ~= "" then return end
                sourceElement:setData("forceAnimation", unpack(details))
            end
        end
    end
)

local timers = {}

addEvent("reloadAnim", true)
addEventHandler("reloadAnim", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                if isTimer(timers[sourceElement]) then
                    killTimer(timers[sourceElement])
                end
                local anim = sourceElement:getData("forceAnimation") or {"", ""}
                if anim[1] ~= "" or anim[2] ~= "" then return end
                sourceElement:setData("forceAnimation", {"BUDDY", "buddy_reload", 1000, false, true, false})
                timers[sourceElement] = setTimer(
                    function(client)
                        sourceElement:setData("forceAnimation", {"", ""})
                    end, 
                800, 1, sourceElement)
            end
        end
    end
)]]

addEventHandler("onResourceStart", resourceRoot,
    function()
        takeAllWeapons(root)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        takeAllWeapons(root)
    end
)

local foodE = {}

function getFoodE(e)
    if not foodE[e] then
        local obj = createObject(e:getData("isUsingFood.foodType") == "food" and 2703 or 2647, 0,0,0)
        obj.collisions = false
        obj.interior = e.interior
        obj.dimension = e.dimension

        if obj.model == 2647 then 
            setObjectScale(obj, 0.7)
        end
    
        foodE[e] = obj

        return obj
    else
        return foodE[e]
    end
end

function destroyFoodE(e)
    if foodE[e] then
        exports['cr_bone_attach']:detachElementFromBone(getFoodE(source))
        destroyElement(foodE[e])
        foodE[e] = nil
    end
end

function destroyTaser(e)
    local sourceElement = e
    if objs[sourceElement] then
        local obj = objs[sourceElement]
        if isElement(obj) then
            sourceElement:setData("taser>obj", nil)
            exports['cr_bone_attach']:detachElementFromBone(obj)
            destroyElement(obj)
            objs[sourceElement] = nil
            collectgarbage("collect")
        end
    end
end

addEventHandler("onPlayerQuit", root, 
    function()
        destroyTaser(source)
        destroyFoodE(source)
        destroyMask(source)
    end
)

--[[
addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "isUsingFood" then
            local value = source:getData(dName)
            if value then
                if source:getData("isUsingFood.foodType") == "food" then
                    exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 12, -0.07, 0.02, 0.085, 0,0,0)
                else
                    exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 11, 0.07, 0, 0.085, 90, 45, 0)
                end
            else
                destroyFoodE(source)
            end
        end
    end
)]]

function usingFood(e, val, type)
    local source = e
    if val then
        if type == "food" then
            exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 12, -0.07, 0.02, 0.085, 0,0,0)
        else
            exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 11, 0.07, 0, 0.085, 90, 45, 0)
        end
    else
        destroyFoodE(source)
    end
end
addEvent("usingFood", true)
addEventHandler("usingFood", root, usingFood)

addEventHandler("onResourceStop", root, 
    function()
        for k,v in pairs(foodE) do
            destroyFoodE(k)
            destroyMask(k)
        end
    end
)

local masks = {}

function destroyMask(e)
    if masks[e] then
        exports['cr_bone_attach']:detachElementFromBone(masks[e])
        destroyElement(masks[e])
        masks[e] = nil
    end
end
addEvent("destroyMask", true)
addEventHandler("destroyMask", root, destroyMask)

function createMask(e, objID, itemid, value, nbt, offsets, scale)
    if not masks[e] then
        
        if not scale then scale = 1 end
        
        local obj = Object(objID, e.position)
        obj.interior = e.interior
        obj.dimension = e.dimension
        obj.collisions = false
        obj.scale = scale
        obj:setData("mask", true)
        obj:setData("maskParent", e)
        e:setData("maskParent", obj)
        
        exports['cr_bone_attach']:attachElementToBone(obj, source, 1, unpack(offsets))
        masks[e] = obj
        
        if tonumber(value) >= 1 then -- pj
            triggerClientEvent(e, "pj>apply", e, itemid, value, nbt, obj)
        end
    end
end
addEvent("createMask", true)
addEventHandler("createMask", root, createMask)

addEvent("weaponHeatedSound", true)
addEventHandler("weaponHeatedSound", root,
    function(e)
        triggerClientEvent(root, "weaponHeatedSound", getRandomPlayer(), e)
    end
)