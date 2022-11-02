local _fileDelete = fileDelete
local function fileDelete(e)
    if fileExists(e) then
        _fileDelete(e)
    end
end

fileDelete("async/global.lua")
fileDelete("triggerHack.lua")
fileDelete("importer/importer.lua")
fileDelete("bar/client.lua")
fileDelete("global.lua")
fileDelete("client.lua")
fileDelete("useItemC.lua")
fileDelete("actionbar/client.lua")
fileDelete("itemlist/client.lua")
fileDelete("weapon/client.lua")
fileDelete("itemshow/itemshowC.lua")
fileDelete("weapon_attach/client.lua")
fileDelete("checkpoints/client.lua")
fileDelete("vending_machines/client.lua")

local modelCache = {}
local objCache = {}

function checkModelCacheArray(e)
    if not modelCache[e] then
        modelCache[e] = {}
    end
    
    if not objCache[e] then
        objCache[e] = {}
    end
end

localPlayer:setData("weapon_attach.table", {})

function attachWeaponToBone(sourceElement, weapon, pj, itemid)
    if not isElement(sourceElement) then return end
    if not weapon then return end
    
    local isHidden = getElementData(sourceElement, "weapons >> hidden") or {}
    --outputChatBox(weapon .. itemid)
    if not isHidden[weapon .. itemid] and GetData(itemid, pj, nbt, "attachWeapon") then
        if GetData(itemid, pj, nbt, "modelID") and GetData(itemid, pj, nbt, "defAttachData") then
            checkModelCacheArray(sourceElement)
            if not modelCache[sourceElement][weapon] then
                local bone, ox, oy, oz, orx, ory, orz = unpack(GetData(itemid, pj, nbt, "defAttachData"))
                local obj = createObject(GetData(itemid, pj, nbt, "modelID"), 0,0,0)
                obj.dimension = sourceElement.dimension
                obj.interior = sourceElement.interior
                obj:setCollisionsEnabled(false)
                modelCache[sourceElement][weapon] = {tonumber(pj or 0), itemid}
                objCache[sourceElement][weapon] = obj
                local ws = sourceElement.walkingStyle
                local hasPJ = GetData(itemid, pj, nbt, "hasPJ")
                local pjSrc
                --outputChatBox(tostring(hasPJ))
                if hasPJ then
                    pjSrc = GetData(itemid, pj, nbt, "customTexturePath") or ":cr_inventory/assets/weaponstickers/"..weapon.."-"..pj..".png"
                    local tex = GetData(itemid, pj, nbt, "textureName") --items[itemid]["textureName"]
                    --outputChatBox(tex)
                    if type(tex) == "table" then
                        for k,v in pairs(tex) do
                            if fileExists(v) then
                                pjSrc = v
                            end
                            
                            exports['cr_texturechanger']:replace(obj, k, pjSrc, true)
                        end
                    else
                        exports['cr_texturechanger']:replace(obj, tex, pjSrc, true)
                    end
                end


                if sourceElement == localPlayer then
                    localPlayer:setData("weapon_attach.table", modelCache[sourceElement])
                end
                
                exports['cr_bone_attach']:attachElementToBone(obj, sourceElement, bone, ox, oy, oz, orx, ory, orz)
            end
        end
    end
end

function attachWeapons()
    local items = getItems(localPlayer, 4)
    ------outputChatBox"as")
    for k,v in pairs(items) do
        if not activeSlot[4 .. "-" .. k] then
            ------outputChatBox"asd")
            local id, itemid, value, count, status, dutyitem = unpack(v)

            if isWeapon(itemid, value, nbt) then
                local weaponID = convertIdToWeapon(itemid, value, nbt)
                attachWeaponToBone(localPlayer, weaponID, value, itemid)
            end
        end
    end
end

function attachWeapon(e, weaponID, pj, itemid) 
    if not isElement(e) then return end
    
    local isHidden = getElementData(e, "weapons >> hidden") or {}
    if not isHidden[weaponID .. itemid] then
        attachWeaponToBone(e, weaponID, pj, itemid)
    end
end
addEvent("attachWeapon", true)
addEventHandler("attachWeapon", root, attachWeapon)

function hideWeaponC(e, weaponID, state)
    if not isElement(e) then return end
    --outputChatBox(tostring(state))
    local weaponDatas = e:getData("weaponDatas") or {}
    if weaponDatas[3] then 
        local itemid = weaponDatas[3]
        if state then -- True = Elrejt, False = Megjelenít
            local isHidden = getElementData(e, "weapons >> hidden") or {}
            isHidden[weaponID .. itemid] = true
            setElementData(e, "weapons >> hidden", isHidden)
            deAttachWeapon(e, weaponID)
        else
            local isHidden = getElementData(e, "weapons >> hidden") or {}
            isHidden[weaponID .. itemid] = false
            setElementData(e, "weapons >> hidden", isHidden)
            attachWeapons()
        end
    end
end

local enabledToHide = {
    [3] = true, -- Gumibot
    [4] = true, -- Kés 
    [22] = true, -- Glock
    [23] = true, -- Silenced
    [24] = true, -- Dezi
    [-1] = true, -- sokkoló
}

function hideWeapCMD(cmd)
    local weaponDatas = localPlayer:getData("weaponDatas") or {}
    if weaponDatas[3] and weaponDatas[4] and weaponDatas[9] then 
        local w = convertIdToWeapon(weaponDatas[3], weaponDatas[4], weaponDatas[9])
        if w and enabledToHide[w] then
            if weaponDatas[3] then 
                local itemid = weaponDatas[3]
                local isHidden = getElementData(localPlayer, "weapons >> hidden") or {}
                if isHidden[w .. itemid] then
                    hideWeaponC(localPlayer, w, false)
                    local syntax = getServerSyntax("Inventory", "success")
                    exports['cr_infobox']:addBox("success", "Sikeresen megjelenítetted a kezedben lévő fegyvert!")
                else
                    hideWeaponC(localPlayer, w, true)
                    local syntax = getServerSyntax("Inventory", "success")
                    exports['cr_infobox']:addBox("success", "Sikeresen eltüntetted a kezedben lévő fegyvert!")
                end
            end
        end 
    end
end
_addCommandHandler("elrejt", hideWeapCMD)
_addCommandHandler("Elrejt", hideWeapCMD)
_addCommandHandler("elrejtem", hideWeapCMD)
_addCommandHandler("Elrejtem", hideWeapCMD)
_addCommandHandler("hide", hideWeapCMD)
_addCommandHandler("Hide", hideWeapCMD)

function deAttachWeapon(e, weaponID) 
    exports['cr_bone_attach']:detachElementFromBone(objCache[e][weaponID])
    destroyElement(objCache[e][weaponID])
    modelCache[e][weaponID] = nil
    objCache[e][weaponID] = nil
    collectgarbage("collect")
    setTimer(
        function()
            attachWeapons()
        end, 1000, 1
    )
    if e == localPlayer then
        e:setData("weapon_attach.table", modelCache[e])
    end
end
addEvent("deAttachWeapon", true)
addEventHandler("deAttachWeapon", root, deAttachWeapon)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setTimer(
            function()
                for k,v in pairs(getElementsByType("player", _, true)) do
                    if isElementStreamedIn(v) then
                        checkModelCacheArray(v)

                        local value = v:getData("weapon_attach.table") or {}
                        local have = {}
                        local _v = v
                        for k,v in pairs(value) do -- modellCache[sourceElement] >> k = weapon
                            ----outputChatBox"Elviekben nincs "..k)
                            if not modelCache[_v][k] then
                                ----outputChatBox"Kajakra nincs "..k)
                                local pj = v[1]
                                local itemid = v[2]
                                attachWeaponToBone(_v, k, pj, itemid)
                            end

                            have[k] = true
                        end

                        if modelCache and modelCache[source] then
                            for k,v in pairs(modelCache[source]) do
                                ----outputChatBox"Elviekben van / nincs "..k)
                                --for k2, v2 in pairs(modelCache[source][k]) do
                                if not have[k] then
                                    ----outputChatBox"Mivel nincs törlés "..k)
                                    exports['cr_bone_attach']:detachElementFromBone(objCache[_v][k])
                                    destroyElement(objCache[_v][k])
                                    modelCache[_v][k] = nil
                                    objCache[_v][k] = nil
                                    collectgarbage("collect")
                                end
                                --end1
                            end
                        end
                    end
                end
            end, 1000, 1
        )
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "weapon_attach.table" then
            if isElementStreamedIn(source) and source ~= localPlayer then 
                checkModelCacheArray(source)
                
                local value = source:getData(dName)
                local have = {}
                for k,v in pairs(value) do -- modellCache[sourceElement] >> k = weapon
                    ----outputChatBox"Elviekben nincs "..k)
                    if not modelCache[source][k] then
                        ----outputChatBox"Kajakra nincs "..k)
                        --local pj = modelCache[source][k]
                        local pj = v[1]
                        local itemid = v[2]
                        attachWeaponToBone(source, k, pj, itemid)
                    end
                    
                    have[k] = true
                end
                
                if modelCache and modelCache[source] then
                    for k,v in pairs(modelCache[source]) do
                        ----outputChatBox"Elviekben van / nincs "..k)
                        --for k2, v2 in pairs(modelCache[source][k]) do
                        if not have[k] then
                            ----outputChatBox"Mivel nincs törlés "..k)
                            exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                            destroyElement(objCache[source][k])
                            modelCache[source][k] = nil
                            objCache[source][k] = nil
                            collectgarbage("collect")
                        end
                        --end1
                    end
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source.type == "player" then
            checkModelCacheArray(source)
            
            local value = source:getData("weapon_attach.table") or {}
            for k,v in pairs(value) do -- modellCache[sourceElement]
                
                --outputChatBox("Elviekben nincs nála "..k)
                --for k2, v2 in pairs(value[k]) do -- modellCache[sourceElement][Weapon]
                if not modelCache[source][k] then
                    --outputChatBox("Kajakra nincs adjunk neki "..k)
                    local pj = v[1]
                    local itemid = v[2]
                    attachWeaponToBone(source, k, pj, itemid)
                end
                --end
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        checkModelCacheArray(source)
        if source.type == "player" then
            if modelCache and modelCache[source] then
                --outputChatBox("Töröljük mert már nem látjuk a buzit")
                for k,v in pairs(modelCache[source]) do
                    --outputChatBox("Ezt töröljük:" ..k)
                    --for k2, v2 in pairs(modelCache[source][k]) do
                    exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                    destroyElement(objCache[source][k])
                    modelCache[source][k] = nil
                    objCache[source][k] = nil
                    collectgarbage("collect")
                    --end
                end
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        if modelCache and modelCache[source] then
            for k,v in pairs(modelCache[source]) do
                --for k2, v2 in pairs(modelCache[source][k]) do
                exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                destroyElement(objCache[source][k])
                modelCache[source][k] = nil
                objCache[source][k] = nil
                collectgarbage("collect")
                --end
            end
        end
    end
)


--[[
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for k,v in pairs(modelCache) do
            for k2,v2 in pairs(modelCache[k]) do
                ---for k3, v3 in pairs(modelCache[k][k2]) do
                exports['cr_bone_attach']:detachElementFromBone(objCache[k3])
                destroyElement(objCache[k2])
                modelCache[source][k2] = nil
                objCache[k2] = nil
                --end
            end
        end
    end
)]]