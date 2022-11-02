localPlayer:setData("usingRadio", false)
weaponInHand = false
byBone = false
weaponInHandID = 0
localPlayer:setData("weaponInHand", weaponInHand)
isUsingFood = false
usedPhoneSlot = nil;
localPlayer:setData("isUsingFood", isUsingFood)
weaponDatas = {}
weaponHeatTable = {}
weaponHeatTick = {}
weaponHeatedTable = {}
usedWeaponCache = {}
activeSlot = {}--{0, 0}
lastTick = -500
lastBloodTick = -60000
wMultipler = 1
local start, startTick
--toggleControl("next_weapon", false)
--toggleControl("previous_weapon", false)
canShot = false
weaponHeated = nil
--toggleControl("action", false) 

local lastRammingAction = 0
local usedBulletProofVestAt = 0

local usedVitaminAt = 0
local usedMedicineAt = 0

local usedJointAt = 0
local usedKokainAt = 0
local usedHeroinAt = 0

function removeAlcohol()
    if getElementData(localPlayer, "char >> death") or getElementData(localPlayer, "inDeath") then return end
    if not localPlayer:getData("loggedIn") then return end
    if localPlayer:getData("drunkLevel") > 0 then
        local drunkLevel = localPlayer:getData("drunkLevel")
        localPlayer:setData("drunkLevel", math.max(drunkLevel - 0.25, 0))
    end
end
setTimer(removeAlcohol, 2.5 * 60000, 0)  -- 2.5 percenként 0.25-t fogy

function checkBone(dName, oValue, nValue)
    if (dName == "drunkLevel") then
        local level = nValue
        
        if (level >= 0) then
            local shakeMultiplier = math.min(level, 6) / 6
            local shakeLevel = 255 * shakeMultiplier 
            
            setCameraShakeLevel(shakeLevel)
            if (level >= 10) then -- halál
                localPlayer:setData("specialReason", "Alkohol túladagolás miatt")
                localPlayer.health = 0
            elseif (level >= 9) then -- max vérzés
                if not isTimer(drunkTimer2) then
                    drunkTimer2 = setTimer(
                        function()
                            local newHealth = localPlayer.health - 2
                            if (newHealth <= 0) then
                                localPlayer:setData("specialReason", "Alkohol túladagolás miatt", "Alkohol túladagolás miatt")
                                setElementData(localPlayer, "char >> health", newHealth)
                                localPlayer:setData("drunkLevel", 0)
                            else 
                                setElementData(localPlayer, "char >> health", newHealth)
                            end
                        end, 0.5 * 60000, 0 -- 0.5 percenként -2 hp = 1 perc -4 hp = 100 hp = 25 perc
                    )
                end
            elseif (level >= 8) then -- min vérzés
                if not isTimer(drunkTimer1) then
                    drunkTimer1 = setTimer(
                        function()
                            local newHealth = localPlayer.health - 1
                            if (newHealth <= 0) then
                                localPlayer:setData("specialReason", "Alkohol túladagolás miatt")
                                setElementData(localPlayer, "char >> health", newHealth)
                                localPlayer:setData("drunkLevel", 0)
                            else 
                                setElementData(localPlayer, "char >> health", newHealth)
                            end
                        end, 0.5 * 60000, 0 -- 0.5 percenként -1 hp = 1 perc -2 hp = 100 hp = 50 perc
                    )
                end
            elseif (level >= 7) then -- beszéd
                if not localPlayer:getData("drunkSpeak") then
                    localPlayer:setData("drunkSpeak", true)
                end
            elseif (level >= 6) then -- járás
                local oWalkStyle = localPlayer:getData("char >> walkStyle")
                if oWalkStyle ~= 126 then
                    localPlayer:setData("oWalkStyle", oWalkStyle)
                    localPlayer:setData("char >> walkStyle", 126)
                    exports['cr_controls']:toggleControl("sprint", false, "high")
                    exports['cr_controls']:toggleControl("jump", false, "high")
                end
            end
            
            if (level < 9) then -- remove timer 2
                if isTimer(drunkTimer2) then killTimer(drunkTimer2) end
            end
            
            if (level < 8) then -- remove timer 1
                if isTimer(drunkTimer1) then killTimer(drunkTimer1) end
            end
            
            if (level < 7) then -- remove drugSpeak
                localPlayer:setData("drunkSpeak", false)
            end
            
            if (level < 6) then -- remove walkStyle
                if localPlayer:getData("oWalkStyle") then
                    local oWalkStyle = localPlayer:getData("oWalkStyle")
                    localPlayer:setData("char >> walkStyle", oWalkStyle)
                    localPlayer:setData("oWalkStyle", nil)

                    exports['cr_controls']:toggleControl("sprint", true, "high")
                    exports['cr_controls']:toggleControl("jump", true, "high")
                end
            end
            
        else
            setCameraShakeLevel(0)
            
            if localPlayer:getData("oWalkStyle") then
                local oWalkStyle = localPlayer:getData("oWalkStyle")
                localPlayer:setData("char >> walkStyle", oWalkStyle)
                localPlayer:setData("oWalkStyle", nil)

                exports['cr_controls']:toggleControl("sprint", true, "high")
                exports['cr_controls']:toggleControl("jump", true, "high")
            end
            
            localPlayer:setData("drunkSpeak", false)
            
            if isTimer(drunkTimer1) then killTimer(drunkTimer1) end
            if isTimer(drunkTimer2) then killTimer(drunkTimer2) end
        end
        
        return
    end
    
    if weaponInHand then
        if dName == "char >> bone" then
            local value = source:getData(dName) or {true, true, true, true, true}
            if value[1] and not value[2] and not value[3] then
                exports['cr_infobox']:addBox("error", "Mivel eltört mindkét kezed a fegyvert tovább nem használhatod!")
                hideWeapon()
            end

            if not canShot then
                exports['cr_controls']:toggleControl("next_weapon", false, "high")
                exports['cr_controls']:toggleControl("previous_weapon", false, "high")
                exports['cr_controls']:toggleControl("fire", false, "high")
                exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                exports['cr_controls']:toggleControl("action", false, "high") 
            end
        elseif source == localPlayer and dName == "inHorse" then
            local value = source:getData(dName)
            if value then
                hideWeapon()
            end
        end
    end
end
addEventHandler("onClientElementDataChange", localPlayer, checkBone)

function putdownWeapon()
    hideWeapon()
end

localPlayer:setData("laserState", nil)

function convertFoodType(text)
    return text == "food" and "kaját" or "italt"
end

specialCardUseTick = -60000

function useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt, triggerByActionbar)
    
    if exports['cr_network']:getNetworkStatus() then return end
    if getElementData(localPlayer, "char >> death") or getElementData(localPlayer, "inDeath") then return end
    if getElementData(localPlayer, "inHorse") or getElementData(localPlayer, "inHorseE") then return end
    
    if not inAnim or inAnim and itemid ~= 15 then 
        if isInventoryDisabled then
            return
        end
    end 
    
    if lastTick + 500 > getTickCount() then
        return
    end
    lastTick = getTickCount()
    
    if moveState and moveSlot and tonumber(moveSlot) and tonumber(moveSlot) >= 1 then return end

    if itemid == 199 then
        if getTickCount() - usedHeroinAt >= 5 * 60000 and getTickCount() - usedJointAt >= 5 * 60000 and getTickCount() - usedKokainAt >= 5 * 60000 then 
            processDrugEffect("heroin", true)
            exports.cr_chat:createMessage(localPlayer, "magába szúr egy heroinos fecskendőt.", 1)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end

            usedHeroinAt = getTickCount()
        else
            local syntax = exports.cr_core:getServerSyntax("Drug", "error")

            outputChatBox(syntax .. "Csak 5 percenként használhatod.", 255, 0, 0, true)
        end
    elseif itemid == 13 then
        if getTickCount() - usedKokainAt >= 5 * 60000 and getTickCount() - usedHeroinAt >= 5 * 60000 and getTickCount() - usedJointAt >= 5 * 60000 then 
            processDrugEffect("kokain", true)
            exports.cr_chat:createMessage(localPlayer, "felszív egy kis kokaint.", 1)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end

            usedKokainAt = getTickCount()
        else
            local syntax = exports.cr_core:getServerSyntax("Drug", "error")

            outputChatBox(syntax .. "Csak 5 percenként használhatod.", 255, 0, 0, true)
        end
    elseif itemid == 14 then
        if getTickCount() - usedJointAt >= 5 * 60000 and getTickCount() - usedKokainAt >= 5 * 60000 and getTickCount() - usedHeroinAt >= 5 * 60000 then 
            processDrugEffect("weed", true)
            exports.cr_chat:createMessage(localPlayer, "elszív egy füves cigit.", 1)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end

            usedJointAt = getTickCount()
        else
            local syntax = exports.cr_core:getServerSyntax("Drug", "error")

            outputChatBox(syntax .. "Csak 5 percenként használhatod.", 255, 0, 0, true)
        end
    elseif itemid == 15 then        
        local thisPhoneSlot = GetData(itemid, value, nbt, "invType") .. "-" .. slot;

        -- set old phone as inactive(if not the same as this)
        if (usedPhoneSlot and thisPhoneSlot ~= usedPhoneSlot) then 
            --activeSlot[usedPhoneSlot] = nil; 
            exports['cr_infobox']:addBox("error", "Már használatban van 1 telefon előbb tedd azt el!")
            return 
        end

        -- tog this items visibility
        activeSlot[thisPhoneSlot] = not activeSlot[thisPhoneSlot];
        usedPhoneSlot = activeSlot[thisPhoneSlot] and thisPhoneSlot or nil;

        exports["cr_phone"]:showPhone({value, slot, nbt}, activeSlot[thisPhoneSlot])
    elseif itemid == 16 then
        exports['cr_vehicle']:triggerVehicleLock(value)
    elseif itemid == 19 then
        if localPlayer:getData("usingRadio") then
            if tonumber(localPlayer:getData("usingRadio.slot") or 0) == slot then
                localPlayer:setData("usingRadio", false)
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
                exports['cr_chat']:createMessage(localPlayer, "abbahagyja egy rádió hallgatását", 1) -- / ?! majd megváltoztatjátok
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                exports['cr_infobox']:addBox("error", "Egy másik rádióra rá vagy hangolódva!")
            end
        else
            localPlayer:setData("usingRadio.slot", tonumber(slot))
            localPlayer:setData("usingRadio.frekv", tonumber(value))
            localPlayer:setData("usingRadio", true)
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            
            exports['cr_chat']:createMessage(localPlayer, "elkezdi egy rádió hallgatását", 1) -- / ?! majd megváltoztatjátok
        end
    elseif itemid == 21 then
        exports['cr_chat']:createMessage(localPlayer, " gurított egyet a kockával ami " .. math.random( 1, 6 ) .."-ot mutat.", "do")
    elseif itemid == 22 then
        if localPlayer.vehicle then
            exports['cr_infobox']:addBox("error", "Kocsiban nem rakhatod le!")
            return
        end
        local pos = localPlayer.position
        local wx, wy, wz = localPlayer.position.x, localPlayer.position.y, localPlayer.position.z - 1
        localPlayer.position = Vector3(localPlayer.position.x, localPlayer.position.y, localPlayer.position.z + 0.5)
        local invType = GetData(itemid, value, nbt, "invType")
        cancelMove(5)
        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
        local eType = getEType(localPlayer)
        local eId = getEID(localPlayer)
        exports['cr_chat']:createMessage(localPlayer, "lehelyez a földre egy hifit", 1)
        triggerServerEvent("createHifi", localPlayer, localPlayer, wx,wy,wz, localPlayer.dimension, localPlayer.interior)
        return
    elseif itemid == 23 then
        if getTickCount() - usedVitaminAt >= 2 * 60000 then 
            if localPlayer.health >= 100 then 
                exports.cr_infobox:addBox("error", "Nincs szükséged vitaminra!")
                return
            end

            localPlayer.health = math.min(100, localPlayer.health + 20)

            exports.cr_chat:createMessage(localPlayer, "bevesz egy vitamint.", 1)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end

            usedVitaminAt = getTickCount()
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak 2 percenként vehetsz be egy vitamint.", 255, 0, 0, true)
        end
    elseif itemid == 24 then
        if getTickCount() - usedMedicineAt >= 2 * 60000 then 
            if localPlayer.health >= 100 then 
                exports.cr_infobox:addBox("error", "Nincs szükséged gyógyszerre!")
                return
            end

            localPlayer.health = math.min(100, localPlayer.health + 40)

            exports.cr_chat:createMessage(localPlayer, "bevesz egy gyógyszert.", 1)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end

            usedMedicineAt = getTickCount()
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak 5 percenként vehetsz be egy gyógyszert.", 255, 0, 0, true)
        end
    elseif itemid == 33 then
        local markerElement = exports.cr_interior:getActiveInterior()

        if isElement(markerElement) then 
            if markerElement:getData("marker >> data") then 
                local markerData = markerElement:getData("marker >> data")
                local interiorType = markerData.type

                if interiorType ~= 1 and interiorType ~= 3 and interiorType ~= 4 then 
                    local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")

                    outputChatBox(syntax .. "Ennél a típusú ingatlannál nem végezhető el ez a művelet.", 255, 0, 0, true)
                    return
                end

                local rammingState = localPlayer:getData("rammingState")
                if not rammingState then 
                    if lastRammingAction + (5 * 60000) > getTickCount() then 
                        local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")
            
                        outputChatBox(syntax .. "Csak 5 percenként tudod használni ezt a tárgyat.", 255, 0, 0, true)
                        return
                    end

                    if not markerData.locked then 
                        local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")
    
                        outputChatBox(syntax .. "Ez az ingatlan már nyitva van.", 255, 0, 0, true)
                        return
                    end

                    localPlayer:setData("startedRamming", true)
                    exports.cr_faction_scripts:manageRamming("init", value)
                    exports.cr_chat:createMessage(localPlayer, "a kezébe vesz egy faltörő kost.", 1)

                    activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                    lastRammingAction = getTickCount()
                else
                    if rammingState == "success" or rammingState == "failed" then 
                        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
                        localPlayer:setData("rammingState", nil)

                        exports.cr_chat:createMessage(localPlayer, "elrak egy faltörő kost.", 1)
                    end
                end
            else
                local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")
                outputChatBox(syntax .. "Csak a bejáratnál tudod használni a tárgyat.", 255, 0, 0, true)
            end
        else
            local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")
            outputChatBox(syntax .. "Nem állsz interior markerben.", 255, 0, 0, true)
        end
    elseif itemid == 36 then
        local badgeContent = nbt["badgeContent"]

        local badgeState = localPlayer:getData("char >> specText")
        if not badgeState then 
            localPlayer:setData("char >> specText", badgeContent)
            exports["cr_chat"]:createMessage(localPlayer, "felhelyez egy jelvényt", 1)

            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
        else 
            if badgeContent == badgeState then 
                localPlayer:setData("char >> specText", nil)
                exports["cr_chat"]:createMessage(localPlayer, "leveszi a jelvényt", 1)

                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            end
        end
	elseif itemid == 37 then
        local occupiedVehicle = localPlayer.vehicle
		local allowedVehicles = exports.cr_mdc:getAllowedVehicles() or {}
		
		if occupiedVehicle and not allowedVehicles[occupiedVehicle.model] then 
			local sirenState = exports.cr_sirenpanel:createSirenObject(occupiedVehicle, id)
			
			if sirenState then
                if sirenState == "active" then 
                    activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                    exports.cr_chat:createMessage(localPlayer, "felhelyez egy villogót a járművére.", 1)
                else 
                    activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
				    exports.cr_chat:createMessage(localPlayer, "levesz egy villogót a járművéről.", 1)
                end
			end
		end
    elseif itemid == 72 then 
        if localPlayer:getData("inInterior") then
            if localPlayer:getData("inInterior"):getData("marker >> data")["owner"] == localPlayer:getData("acc >> id") then 
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
                    local pos = localPlayer.position
                    localPlayer.position = Vector3(pos.x, pos.y, pos.z + 0.5)
                    setTimer(triggerServerEvent, 200, 1, "createSafe", localPlayer, localPlayer, nil, true, {pos.x, pos.y, pos.z - 0.5}, {0, 0, exports['cr_core']:findRotation(localPlayer.position.x, localPlayer.position.y, pos.x, pos.y)})

                    cancelMove(5)
                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    cache[eType][eId][invType][slot] = nil

                    exports['cr_chat']:createMessage(localPlayer, 'lehelyez egy széfet', 1)
                    return
                else
                    exports['cr_infobox']:addBox("error", "Ez a széf nem helyezhető le hisz már elérted a limitet ("..max..")!")
                end
            else
                exports['cr_infobox']:addBox("error", "Csak saját interiorban helyezhető le széf")
            end
        else
            exports['cr_infobox']:addBox("error", "Csak interiorban helyezhető le széf")
        end
    elseif itemid == 75 then
        if localPlayer.vehicle then 
            if tonumber(localPlayer.vehicle:getData('veh >> owner') or -1) == tonumber(localPlayer:getData("acc >> id") or -2) or tonumber(localPlayer.vehicle:getData('veh >> faction') or 0) > 0 and exports['cr_dashboard']:isPlayerInFaction(localPlayer, tonumber(localPlayer.vehicle:getData('veh >> faction') or 0)) then
                exports['cr_chat']:createMessage(localPlayer, "felrak egy taxi táblát", 1) -- // ?!
                deleteItem(localPlayer, slot, itemid)

                exports['cr_infobox']:addBox('success', 'Sikeresen felraktad a taxi táblát!')

                exports['cr_taxipanel']:createTaxiLamp(localPlayer.vehicle)
            else
                exports['cr_infobox']:addBox('error', 'Nincs jogosultságod ahhoz, hogy felrakd ezt a taxi táblát!')
            end 
        else
            exports['cr_infobox']:addBox('error', 'Ez a tárgy csak járműben használható!')
        end 
    elseif itemid == 25 or itemid == 28 or itemid == 77 or itemid == 78 or itemid == 82 or itemid == 148 or itemid == 149 then
        local val = exports['cr_license']:openIdentity(id, itemid, value, nbt, slot)

        if type(val) ~= 'string' then
            if val then
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            else
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            end
        end
    elseif itemid == 80 then
        if type(value) == "table" then 
            local state = exports.cr_propertytransfer:showPropertyTransferContract(value, id)

            if state == "init" then 
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            else
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            end
        end
    elseif itemid == 84 then
        exports['cr_vehicle']:triggerVehicleLock(value, true)
    elseif itemid == 85 then
        if not localPlayer.vehicle then
            if weaponInHand and getPedWeapon(localPlayer) > 0 then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                exports['cr_infobox']:addBox("error", "Mielőtt elővennéd a horgászbotot, rakd el a fegyvert")
                return    
            end
            
            if isUsingFood then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                exports['cr_infobox']:addBox("error", "Mielőtt elővennéd a horgászbotot, rakd el a kaját")
                return
            end

            weaponInHand = exports.cr_fishing:createFishingRod();
            if weaponInHand then
                weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt, 0, {0,0}}
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                disabled = true
            else
                weaponDatas = {}
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil --{0,0}
            end
        end
    elseif itemid == 105 then 
        local bloodData = localPlayer:getData("bloodData")
        if bloodData and #bloodData >= 1 then 
            if lastBloodTick + 60000 > getTickCount() then
                exports['cr_infobox']:addBox("error", "A kötszert csak 1 percenként használhatod!")
                return
            end
            lastBloodTick = getTickCount()
            
            for k,v in pairs(bloodData) do 
                local minus, weapon, bodypart = unpack(v)
                minus = minus - (minus * 0.2)
                bloodData[k] = {minus, weapon, bodypart}
            end 
            localPlayer:setData("bloodData", bloodData)
            exports['cr_chat']:createMessage(localPlayer, "elhasznál egy kötszert", 1) -- // ?!

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end
        else
            exports['cr_infobox']:addBox("error", "Nem vérzel!") 
        end 
	elseif itemid == 126 then
		exports.cr_bank_script:createDrone() 
		if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif itemid == 128 then
        if type(value) == "table" then 
            local state = exports.cr_faction_scripts:showTicket(value, value.mdTicket, id)
            
            if state == "init" then 
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            else
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            end
        end
    elseif itemid == 129 then
        if laserState then 
            if activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] then 
                laserState = false  
                localPlayer:setData("laserState", laserState)
                exports['cr_chat']:createMessage(localPlayer, "abbahagyja a célzólézer használatát", 1) -- // ?!
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            else 
                exports['cr_infobox']:addBox("warning", "Már használatban van egy célzólézer!")
            end 
        else 
            laserState = true  
            localPlayer:setData("laserState", laserState)
            exports['cr_chat']:createMessage(localPlayer, "elkezdi használni a célzólézert", 1) -- // ?!
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
        end 
    elseif GetData(itemid, value, nbt, "mask") then --items[itemid] and items[itemid]["mask"] then
        if oMaskDBID == id or not oMaskDBID then
            maskState = not maskState
            localPlayer:setData("maskState", maskState)
            
            if maskState then
                oMaskDBID = id
                oMaskItemID = itemid
                oMaskValue = value
                oMaskSlot = slot
                oMaskNBT = nbt
                exports['cr_chat']:createMessage(localPlayer, "feltesz egy maszkot a fejére ("..nbt["name"]..")", 1) -- // ?!
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                
                local red = exports['cr_core']:getServerColor("yellow", true)
                local blue = exports['cr_core']:getServerColor("yellow", true)
                local white = "#ffffff"
                oldCustomName = localPlayer:getData("char >> customName")
                localPlayer:setData("char >> customName", "(" .. red .. tostring(nbt["name"]) .. "#ffffff)")
                
                local syntax = exports['cr_core']:getServerSyntax("Mask", "info")
                exports['cr_infobox']:addBox("info", "A maszk "..blue.."nevének"..white.." változtatásához használd a "..blue.."/maskname"..white.." parancsot!")
                exports['cr_infobox']:addBox("info", "A maszk "..blue.."poziciójának"..white.." módosításához használd a "..blue.."/maskpos"..white.." parancsot!")
                
                --outputChatBox(nbt["scale"])
                local objID = GetData(itemid, value, nbt, "modelID") --items[itemid]["modelID"]
                local offsets = nbt["offsets"]
                if not offsets or type(offsets) ~= "table" then
                    offsets = GetData(itemid, value, nbt, "defOffsets") --items[itemid]["defOffsets"] 
                end
                
                oMaskObjID = objID
                triggerServerEvent("createMask", localPlayer, localPlayer, objID, oMaskItemID, oMaskValue, oMaskNBT, offsets, nbt["scale"])
                addCommandHandler("maskname", changeMaskName)
                addCommandHandler("maskpos", changeMaskPosition)
            else
                maskState = true
                stopMaskEditing(true)
            end
        else
            exports['cr_infobox']:addBox("error", "Egyszerre csak 1 maszkot használhatsz!")
        end
    elseif GetData(itemid, value, nbt, "isMasterBook") then 
        local statID = GetData(itemid, value, nbt, "statID")
        if localPlayer:getStat(statID) < 1000 then 
            local itemName = getItemName(itemid, value, nbt)
            exports['cr_chat']:createMessage(localPlayer, "kiolvas egy mesterkönyvet ("..itemName..")", 1)
            triggerLatentServerEvent("changePlayerStats", 5000, false, localPlayer, localPlayer, statID, 1000)
            local invType = GetData(itemid, value, nbt, "invType")
            cancelMove(5)
            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            cache[eType][eId][invType][slot] = nil
        else 
            exports['cr_infobox']:addBox("error", "Ezt a mesterkönyvet nem használhatod!")
        end 
    elseif itemid == 131 then
        if exports['cr_dashboard']:isPlayerInFaction(localPlayer, 1) then
            if localPlayer.dimension == 33 and localPlayer.interior == 6 then
                local pos = Vector3(238.43147277832, 71.359100341797, 1005.0390625)
                if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
                    local invType = GetData(itemid, value, nbt, "invType")
                    cancelMove(5)
                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    cache[eType][eId][invType][slot] = nil
                    giveItem(localPlayer, 132, value)
                else
                    exports['cr_infobox']:addBox("error", "Itt nem lehetséges az item használata!")
                end
            else
                exports['cr_infobox']:addBox("error", "Itt nem lehetséges az item használata!")
            end
        else
            exports['cr_infobox']:addBox("error", "Nem vagy a Sheriffség tagja!")
        end
    elseif itemid == 134 then 
        local megaphoneState = localPlayer:getData("char >> megaphoneInHand")

        if not megaphoneState then 
            localPlayer:setData("char >> megaphoneInHand", true)

            exports["cr_chat"]:createMessage(localPlayer, "elővesz egy megafont", 1)
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
        else
            localPlayer:setData("char >> megaphoneInHand", false)

            exports["cr_chat"]:createMessage(localPlayer, "elrak egy megafont", 1)
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
        end
    elseif itemid == 139 then 
        if not localPlayer:getData('inDeath') then 
            if localPlayer.health < 100 then 
                if specialCardUseTick + (60 * 1000) > getTickCount() then
                    exports['cr_infobox']:addBox('warning', 'Ez a tárgy percenként használható!')
                    return
                end
                specialCardUseTick = getTickCount()

                setElementData(localPlayer, "char >> bone", {true, true, true, true, true})

                triggerServerEvent("anim - give", localPlayer, localPlayer, {"", ""})

                setElementData(localPlayer, "attackOnHand", 0)
                setElementData(localPlayer, "torsoAmmo", 0)
                setElementData(localPlayer, "drunkLevel", 0)
                setElementData(localPlayer, "bloodData", {})
                setElementData(localPlayer, "isRespawning", false)
                setElementData(localPlayer, "isRespawningE", false)

                triggerServerEvent("health - give", localPlayer, localPlayer, true)
                
                exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad a heal kártyát!')

                if count - 1 <= 0 then
                    deleteItem(localPlayer, slot, itemid)
                else
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    local invType = GetData(itemid, value, nbt, "invType")
                    checkTableArray(eType, eId, invType)
                    cache[eType][eId][invType][slot][4] = count - 1
                    cancelMove(5)
                    triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                end
            else 
                exports['cr_infobox']:addBox('error', 'Ez a tárgy csak sérülten használható!')
            end 
        else 
            exports['cr_infobox']:addBox('error', 'Ez a tárgy halottként nem használható!')
        end 
    elseif itemid == 140 then -- Fix kártya 
        if localPlayer.vehicle then 
            if localPlayer.vehicle.health < 1000 then 
                if specialCardUseTick + (60 * 1000) > getTickCount() then
                    exports['cr_infobox']:addBox('warning', 'Ez a tárgy percenként használható!')
                    return
                end
                specialCardUseTick = getTickCount()

                triggerServerEvent("fixVehicle", localPlayer, localPlayer.vehicle)
                exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad a fix kártyát!')

                if count - 1 <= 0 then
                    deleteItem(localPlayer, slot, itemid)
                else
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    local invType = GetData(itemid, value, nbt, "invType")
                    checkTableArray(eType, eId, invType)
                    cache[eType][eId][invType][slot][4] = count - 1
                    cancelMove(5)
                    triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                end
            else 
                exports['cr_infobox']:addBox('error', 'Ez a tárgy csak sérült járműben használható!')
            end 
        else 
            exports['cr_infobox']:addBox('error', 'Ez a tárgy csak járműben használható!')
        end 
    elseif itemid == 141 then 
        if localPlayer.vehicle then 
            if specialCardUseTick + (60 * 1000) > getTickCount() then
                exports['cr_infobox']:addBox('warning', 'Ez a tárgy percenként használható!')
                return
            end
            specialCardUseTick = getTickCount()

            triggerServerEvent("unflipVehicle", localPlayer, localPlayer.vehicle)
            exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad az unflip kártyát!')

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end
        else 
            exports['cr_infobox']:addBox('error', 'Ez a tárgy csak járműben használható!')
        end 
    elseif itemid == 143 then 
        if localPlayer.vehicle then 
            local maxFuel = exports['cr_vehicle']:getMaxFuel()[getElementModel(localPlayer.vehicle)]

            if tonumber(localPlayer.vehicle:getData("veh >> fuel") or 0) < maxFuel then 
                if specialCardUseTick + (60 * 1000) > getTickCount() then
                    exports['cr_infobox']:addBox('warning', 'Ez a tárgy percenként használható!')
                    return
                end
                specialCardUseTick = getTickCount()

                setElementData(localPlayer.vehicle, "veh >> fuel", maxFuel)
                exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad az üzemanyag kártyát!')

                if count - 1 <= 0 then
                    deleteItem(localPlayer, slot, itemid)
                else
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    local invType = GetData(itemid, value, nbt, "invType")
                    checkTableArray(eType, eId, invType)
                    cache[eType][eId][invType][slot][4] = count - 1
                    cancelMove(5)
                    triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
                end
            else 
                exports['cr_infobox']:addBox('error', 'Ez a tárgy csak nem tele tankolt járműben használható!')
            end 
        else 
            exports['cr_infobox']:addBox('error', 'Ez a tárgy csak járműben használható!')
        end 
    elseif itemid == 144 then
        if not localPlayer.vehicle then 
            if weaponInHand and getPedWeapon(localPlayer) > 0 then
                exports.cr_infobox:addBox("error", "Mielőtt elővennéd a flexet, rakd el a fegyvert")
                return    
            end
            
            if isUsingFood then
                exports.cr_infobox:addBox("error", "Mielőtt elővennéd a flexet, rakd el a kaját")
                return
            end

            weaponInHand = exports.cr_robbery:createGrinder()

            if weaponInHand then
                weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt, 0, {0, 0}}
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                disabled = true
            else
                weaponDatas = {}
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
            end
        end
    elseif itemid == 150 then
        if usedBulletProofVestAt + (5 * 60000) > getTickCount() then 
            local syntax = exports.cr_core:getServerSyntax("Bulletproof Vest", "error")

            outputChatBox(syntax .. "Csak 5 percenként használhatsz golyóálló mellényt.", 255, 0, 0, true)
            return
        end

        if localPlayer.armor >= 100 then 
            local syntax = exports.cr_core:getServerSyntax("Bulletproof Vest", "error")

            outputChatBox(syntax .. "A páncélszintednek kisebbnek kell lennie 100-nál, hogy fel tudd venni a golyóálló mellényt.", 255, 0, 0, true)
            return
        end

        localPlayer.armor = 100
        exports.cr_infobox:addBox("success", "Sikeresen felvettél egy golyóálló mellényt!")
        exports.cr_chat:createMessage(localPlayer, "felvesz egy golyóálló mellényt.", 1)

        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end

        usedBulletProofVestAt = getTickCount()
    elseif itemid == 151 then 
        local state = exports.cr_faction_scripts:showTicketPanel()

        if state == "init" then 
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
        else
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
        end
    elseif itemid == 155 then 
        localPlayer:setData("char >> vehicleLimit", tonumber(localPlayer:getData('char >> vehicleLimit') or 0) + 1)
        exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad a jármű slot kártyát!')

        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif itemid == 156 then 
        localPlayer:setData("char >> interiorLimit", tonumber(localPlayer:getData('char >> interiorLimit') or 0) + 1)
        exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad a interior slot kártyát!')

        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif itemid == 158 then 
        if localPlayer:getData("inInterior") then
            local intData = localPlayer:getData("inInterior"):getData("marker >> data")
            local max = tonumber(intData['maxSafe'] or 3)

            intData['maxSafe'] = max + 1

            localPlayer:getData("inInterior"):setData("marker >> data", intData)
            exports['cr_infobox']:addBox('success', 'Sikeresen elhasználtad a Raktárfejlesztés (Interior) kártyát! (Új slot: '..intData['maxSafe']..')')

            triggerServerEvent("updateInteriorSafeSlots", localPlayer, localPlayer:getData("inInterior"), intData['maxSafe'])

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end
        else
            exports['cr_infobox']:addBox('error', 'Ezt a kártyát csak interiorban használhatod!')
        end 
    elseif itemid == 159 then
        if type(value) == "number" then 
            exports.cr_core:giveMoney(localPlayer, tonumber(value))
            exports.cr_infobox:addBox("success", "Sikeresen kivettél $" .. value .. "-t a zsákból!")
        end

        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif itemid == 181 or itemid == 182 or itemid == 183 then
        if localPlayer:getData("inInterior") then 
            triggerServerEvent("plant.createPlant", localPlayer, itemid, value)

            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end
        else
            exports.cr_infobox:addBox("error", "Csak interiorban helyezheted le a cserepet!")
        end
    elseif itemid == 188 then
        if not localPlayer:getData("usingWaterCan") then 
            if localPlayer:getData("inInterior") then 
                if localPlayer:getData("wateringPlant") then 
                    return
                end

                triggerServerEvent("plant.manageWaterCan", localPlayer, false, "create", value)

                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            else 
                exports.cr_infobox:addBox("error", "Csak interiorban veheted elő a vizes kannát!")
            end
        else 
            if localPlayer:getData("wateringPlant") then 
                return
            end
            
            triggerServerEvent("plant.manageWaterCan", localPlayer, false, "destroy")

            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
        end
    elseif itemid == 317 then
        if not localPlayer:getData("openingCashbox") then 
            local availablePositions = exports.cr_robbery:getAvailableOpeningPositions()
            local canOpen = false
            local localPosition = localPlayer.position

            for i = 1, #availablePositions do 
                local v = availablePositions[i]

                if getDistanceBetweenPoints3D(localPosition, unpack(v.position)) <= 3 then 
                    canOpen = true
                    break
                end
            end

            if exports.cr_robbery:hasPermissionToRob("atmRob") then 
                if canOpen then 
                    if hasItem(localPlayer, 145) and hasItem(localPlayer, 194) then 
                        localPlayer:setData("openingCashbox", true)

                        exports.cr_robbery:manageLockpickMinigame("init", id)
                        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                    else 
                        exports.cr_infobox:addBox("error", "A nyitás megkezdéséhez szükséged van a következő tárgyakra: Csavarhúzó, zárfésű.")
                    end
                else 
                    exports.cr_infobox:addBox("error", "Túl messze vagy.")
                end
            else 
                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod.")
            end
        else
            if sourceResource and getResourceName(sourceResource) == "cr_robbery" then 
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil

                if count - 1 <= 0 then
                    deleteItem(localPlayer, slot, itemid)
                else
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    local invType = GetData(itemid, value, nbt, "invType")
                    checkTableArray(eType, eId, invType)
                    cache[eType][eId][invType][slot][4] = count - 1
                    cancelMove(5)
                    triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, invType, count - 1)
                end
            end
        end
    elseif GetData(itemid, value, nbt, "food") or GetData(itemid, value, nbt, "drink") then
        if weaponInHand then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            exports['cr_infobox']:addBox("error", "Mielőtt elővennéd a kaját, rakd el a kezedben lévő eszközt (fegyver, horgászbot, etc...)")
            return
        end
        
        local itemName = getItemName(itemid, value, nbt)
        if not isUsingFood then
            weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt}
            exports['cr_chat']:createMessage(localPlayer, "elővesz egy "..convertFoodType(GetData(itemid, value, nbt, "food") and "food" or GetData(itemid, value, nbt, "drink") and "water").." ("..itemName..")", 1)
            
            --addEventHandler("onClientRender", root, drawnFoodBar, true, "low-5")
            createRender("drawnFoodBar", drawnFoodBar)
            start = true
            startTick = getTickCount()
            addEventHandler("onClientClick", root, interactFoodBar)
            dropNum = GetData(itemid, value, nbt, "BiteMax") --items[itemid]["BiteMax"] --math.random(2, 5)
            _dropNum = dropNum
            isEaten = false
            
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            local green = exports['cr_core']:getServerColor(nil, true)
            outputChatBox(syntax .. "Az eldobáshoz használd az egér "..green.."'Bal'#ffffff klikkjét, az evéshez pedig a "..green.."'Jobb' #ffffffklikket.",255,255,255,true)

            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
            activePage = 1
            start = true
            startTick = getTickCount()

            isUsingFood = true
            localPlayer:setData("isUsingFood.foodType", GetData(itemid, value, nbt, "food") and "food" or GetData(itemid, value, nbt, "drink")and "water")
            localPlayer:setData("isUsingFood", isUsingFood)
            triggerServerEvent("usingFood", localPlayer, localPlayer, localPlayer:getData("isUsingFood"), localPlayer:getData("isUsingFood.foodType"))
        else
            if weaponDatas[1] == slot and activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] then
                if not isEaten then
                    if _dropNum == dropNum then
                        exports['cr_chat']:createMessage(localPlayer, "elrak egy "..convertFoodType(GetData(itemid, value, nbt, "food") and "food" or GetData(itemid, value, nbt, "drink") and "water").." ("..itemName..")", 1)
                        isUsingFood = false
                        localPlayer:setData("isUsingFood", isUsingFood)
                        triggerServerEvent("usingFood", localPlayer, localPlayer, localPlayer:getData("isUsingFood"), localPlayer:getData("isUsingFood.foodType"))
                        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil

                        start = false
                        startTick = getTickCount()
                        removeEventHandler("onClientClick", root, interactFoodBar)
                    else
                        local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                        exports['cr_infobox']:addBox("error", "Mivel már ettél/itál ebből a kajából/italból ezért már csak eldobni tudod!")
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                    exports['cr_infobox']:addBox("error", "Mivel már ettél/itál ebből a kajából/italból ezért már csak eldobni tudod!")
                end
            end
        end
    elseif GetData(itemid, value, nbt, "isAmmo") then
        if weaponInHand then
            local _slot = slot 
            local _data = {id, itemid, value, count, status, dutyitem, premium, nbt}
            local _itemid, _value, _nbt = itemid, value, nbt

            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            local slot2, data = unpack(hasData)
            
            local ammoItemID = GetData(itemid, value, nbt, "ammoID") --items[itemid]["ammoID"]
            if ammoItemID == _itemid then 
                if activeSlot[GetData(_itemid, _value, _nbt, "invType") .. "-" .. _slot] then 
                    setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
                    setElementData(localPlayer, "pulling", false)   

                    exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                    exports['cr_controls']:toggleControl("fire", false, "high")
                    canShot = false
                    exports['cr_controls']:toggleControl("action", false, "high")

                    if not binded then
                        bindKey("r", "down", reloadWeapon)
                        binded = true
                    end

                    if clipBinded then 
                        unbindKey("r", "down", reloadWeaponClip)        
                        clipBinded = false
                    end 

                    weaponDatas[10] = 0

                    activeSlot[GetData(_itemid, _value, _nbt, "invType") .. "-" .. _slot] = false

                    local weaponName = getItemName(itemid, value, nbt)
                    exports['cr_chat']:createMessage(localPlayer, "kitölt egy fegyvert ("..weaponName..")", 1)
                    
                    return
                else 
                    setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
                    setElementData(localPlayer, "pulling", false)   

                    exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                    exports['cr_controls']:toggleControl("fire", false, "high")
                    canShot = false
                    exports['cr_controls']:toggleControl("action", false, "high")

                    if not clipBinded then 
                        bindKey("r", "down", reloadWeaponClip)        
                        clipBinded = true
                    end 

                    weaponDatas[10] = 0

                    if tonumber(slot2) and tonumber(slot2) >= 1 then
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot2] = nil
                    end

                    local hasData = {_slot, _data}
                    ammo = _data[4]
                    weaponDatas[10] = ammo
                    weaponDatas[11] = hasData
                    activeSlot[GetData(_data[2], _data[3], _data[8], "invType") .. "-" .. _slot] = true
                    local weaponName = getItemName(itemid, value, nbt)
                    exports['cr_chat']:createMessage(localPlayer, "betölt egy fegyvert ("..weaponName..")", 1)
                    exports['cr_controls']:toggleControl("fire", true, "high")
                    exports['cr_controls']:toggleControl("vehicle_fire", true, "high")
                    canShot = true
                    exports['cr_controls']:toggleControl("action", false, "high")
                    if binded then
                        unbindKey("r", "down", reloadWeapon)
                        binded = false
                    end
                    localPlayer:setData("weaponDatas", weaponDatas)
                    
                    local weaponID = convertIdToWeapon(itemid, value, nbt)
                    triggerServerEvent("setWeaponAmmo", localPlayer, localPlayer, weaponID, ammo)
                    
                    local crouch = false;
                    if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
                        crouch = true;
                    end
                    if not crouch then
                        local anim = localPlayer:getData("forceAnimation") or {"", ""}
                        if anim[1] ~= "" or anim[2] ~= "" then return end

                        triggerServerEvent('reloadPedWeapon', localPlayer, localPlayer)
                    end
                end 
            end 
        end 
    elseif isWeapon(itemid, value, nbt) then
        if isTimer(clickTimer) then killTimer(clickTimer) end
        if isUsingFood then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            exports['cr_infobox']:addBox("error", "Mielőtt elővennéd a fegyvert, rakd el a kaját")
            return
        end
        
        if weaponInHand and getPedWeapon(localPlayer) <= 0 then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            exports['cr_infobox']:addBox("error", "Mielőtt elővennéd a fegyvert, rakd el a kezedben lévő eszközt (csákány, horgászbot, etc...)")
            return
        end
        
        local weaponID = convertIdToWeapon(itemid, value, nbt)
        if weaponID then
            if not weaponInHand then
                if status <= 0 then
                    exports['cr_infobox']:addBox("error", "Ez a fegyver nem használható, hisz törött!")
                    return
                end
                
                if localPlayer.vehicle then
                    if localPlayer.vehicle.controller == localPlayer then
                        if not ignoreWeaponInteractions[weaponInHandID] then 
                            exports['cr_infobox']:addBox("error", "Fegyvert nem vehetsz elő vezetői ülésben!")
                            return
                        end
                    end
                end

                if getPedControlState("fire") then 
                    exports['cr_infobox']:addBox("error", "Ameddig lenyomva tartod a lövés gombot nem veheted elő a fegyvert!")
                    return 
                end 
                
                local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
                if not bone[2] and not bone[3] then
                    exports['cr_infobox']:addBox("error", "Ez a fegyver nem használható, hisz mindkét kezed törött!")
                    return
                end

                if localPlayer:getData("char >> enteringToInterior") then 
                    exports['cr_infobox']:addBox("error", "Ameddig az interior spawn védelme alatt állsz nem vehetsz elő fegyvert!")
                    return
                end
                
                local ammo = 0
                local ammoItemID = GetData(itemid, value, nbt, "ammoID") --items[itemid]["ammoID"]
                
                disabled = false
                if ammoItemID <= 0 then -- // Gránátok
                    ammo = 1000
                    disabled = true
                end
                
                local has, slot2, data = hasItem(localPlayer, ammoItemID)
                
                if disabled then
                    has = true
                end
                
                if ammoItemID == -2 then
                    if value <= 0 then
                        has = false
                    end
                end
                
                if ammoItemID == -4 then
                    has = true
                end
                
                local hasData = {slot2, data}
                
                if has then
                    exports['cr_controls']:toggleControl("fire", true, "high")
                    exports['cr_controls']:toggleControl("vehicle_fire", true, "high")
                    canShot = true
                    exports['cr_controls']:toggleControl("action", false, "high")
                    if not disabled then
                        ammo = data[4]

                        if not clipBinded then 
                            bindKey("r", "down", reloadWeaponClip)        
                            clipBinded = true
                        end 
                    end
                else
                    exports['cr_controls']:toggleControl("fire", false, "high")
                    exports['cr_controls']:toggleControl("vehicle_fire", true, "high")
                    canShot = false
                    exports['cr_controls']:toggleControl("action", false, "high")
                    if not disabled then
                        if not binded then
                            bindKey("r", "down", reloadWeapon)
                            binded = true
                        end
                    end
                end
                
                exports['cr_controls']:toggleControl("next_weapon", false, "high")
                exports['cr_controls']:toggleControl("previous_weapon", false, "high")
                
                weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData}
                
                local tex = GetData(itemid, value, nbt, "textureName") --items[itemid]["textureName"]
                
                if isTimer(shotTimer) then killTimer(shotTimer) end
                local weaponName = getItemName(itemid, value, nbt)
                oldWeaponDamageStatus = tonumber(status)
                exports['cr_chat']:createMessage(localPlayer, "elővesz egy fegyvert ("..weaponName..")", 1)
                
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = true
                
                if tonumber(slot2) and tonumber(slot2) >= 1 and tonumber(ammoItemID) and tonumber(ammoItemID) >= 1 then
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(hasData)
                    activeSlot[GetData(ammoItemID, value, nbt, "invType") .. "-" .. slot2] = true
                end
                activePage = 1
                
                if isWeapon(itemid, value, nbt) then
                    triggerEvent("deAttachWeapon", localPlayer, localPlayer, convertIdToWeapon(itemid, value, nbt), itemid)
                end
                
                weaponInHand = true
                weaponInHandID = convertIdToWeapon(itemid, value, nbt)
                usedWeaponCache[id] = weaponInHandID
                weaponInHandDBID = id
                localPlayer:setData("weaponInHand", weaponInHand)
                localPlayer:setData("weaponDatas", weaponDatas)
                
                local hasPJ = GetData(itemid, value, nbt, "hasPJ")
                local pjSrc
                if hasPJ then
                    pjSrc = GetData(itemid, value, nbt, "customTexturePath") or ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
                    local tex = GetData(itemid, value, nbt, "textureName") --items[itemid]["textureName"]
                    if type(tex) == "table" then
                        for k,v in pairs(tex) do
                            if fileExists(v) then
                                pjSrc = v
                            end
                            exports['cr_texturechanger']:replace(localPlayer, k, pjSrc, true)
                        end
                    else
                        exports['cr_texturechanger']:replace(localPlayer, tex, pjSrc, true)
                    end
                end
                
                local crouch = false;
                if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
                    crouch = true;
                end
                if not crouch then
                    --triggerServerEvent("weaponAnim", localPlayer, localPlayer)
                    local anim = localPlayer:getData("forceAnimation") or {"", ""}
                    if anim[1] ~= "" or anim[2] ~= "" then 
                        return 
                    end
                    localPlayer:setData("forceAnimation", {"COLT45", "sawnoff_reload", 500, false, false, false, false})
                end
                gwMultipler = 0
                wMultipler = tonumber(weaponHeatTable[id]) or 100 --1
                isItStartAnim = true
                
                if weaponHeatedTable[id] then
                    exports['cr_controls']:toggleControl("fire", false, "high")
                    exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                    weaponHeated = true
                    exports['cr_controls']:toggleControl("action", false, "high")
                end

                triggerServerEvent("giveWeaponH", localPlayer, localPlayer, weaponID, ammo, itemid, value, nbt)
            else
                local _, _, itemid, value, _, _, _, _, nbt, _, _ = unpack(weaponDatas)
                if weaponDatas[1] == slot and activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. weaponDatas[1]] then
                    if triggerByActionbar or invType == GetData(itemid, value, nbt, "invType") then 
                        hideWeapon()
                    end 
                end
            end
        end
        
    else
        local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        exports['cr_infobox']:addBox("error", "Ehhez a tárgyhoz nem kapcsolódik funkció.")
    end
end

function checkHandWeapon()
    local id = weaponInHandID or 0
    if weaponInHandID == -1 then -- Sokkoló
        id = 24
    elseif weaponInHandID == -1 then -- Beanbag
        id = 25
    end
    
    local wep = getPedWeapon(localPlayer)
    if tonumber(id) ~= tonumber(wep) then
        triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)

        if weaponInHand then
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            local tex = GetData(itemid, value, nbt, "textureName")  -- items[itemid]["textureName"]
            triggerServerEvent("giveWeaponH", localPlayer, localPlayer, weaponInHandID, 99000, itemid, value, tex)
            
            local hasPJ = GetData(itemid, value, nbt, "hasPJ")
            local pjSrc
            if hasPJ then
                pjSrc = GetData(itemid, value, nbt, "customTexturePath") or ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
                local tex = GetData(itemid, value, nbt, "textureName") --items[itemid]["textureName"]
                if type(tex) == "table" then
                    for k,v in pairs(tex) do
                        if fileExists(v) then
                            pjSrc = v
                        end
                        exports['cr_texturechanger']:replace(localPlayer, k, pjSrc, true)
                    end
                else
                    exports['cr_texturechanger']:replace(localPlayer, tex, pjSrc, true)
                end
            end
        end
    end
end
setTimer(checkHandWeapon, 1000, 0)

local lastCall = -1
local lastCallTick = -5000
local updateTimer 
addEventHandler("onClientPlayerWeaponFire", localPlayer,
    function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
        if weaponInHand then
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            local slot2, data = unpack(hasData)
            
            local ammoItemID = GetData(itemid, value, nbt, "ammoID") --items[itemid]["ammoID"]
            if ammoItemID == -3 then -- grenade
                local invType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
                hideWeapon()
                cancelMove(5)
                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                
                cache[eType][eId][invType][slot] = nil
                cancelEvent()
                return
            elseif ammoItemID == -2 then
                local invType = GetData(itemid, value, nbt, "invType") --activeSlot[3]
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                value = value - 1
                
                updateItemDetails(localPlayer, slot, invType, {"value", value}, true)
                cache[eType][eId][invType][slot][3] = value
                
                if value <= 0 then
                    hideWeapon()
                end
                
                cancelEvent()    
                return
            end
            
            if disabled then return end
            
            if not slot2 or slot2 <= 0 then
                exports['cr_controls']:toggleControl("fire", false, "high")
                exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                canShot = false
                exports['cr_controls']:toggleControl("action", false, "high") 
                cancelEvent()
                return
            end

            
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            checkTableArray(eType, eId, 1)
            
            ammo = math.max(0, ammo - 1)
            weaponDatas[10] = ammo
            --localPlayer:setData("weaponDatas", weaponDatas)
            if isTimer(updateTimer) then killTimer(updateTimer) end 
            updateTimer = setTimer(setElementData, 500, 1, localPlayer, "weaponDatas", weaponDatas)
            
            if not GetData(itemid, value, nbt, "ignoreIdentity") then 
                started = false
                destroyAnimation(1)
                local weapDmg = overheatIncreaseValues[weapon]
                wMultipler = math.max(0, wMultipler - weapDmg)
                weaponHeatTable[id] = wMultipler
                
                if wMultipler <= 0 then
                    local chance = 1
                    if chance == 1 then
                        local _oldState = oldState
                        local oldState = weaponDatas[6]
                        
                        local damage = math.random(1,10)
                        weaponDatas[6] = math.max(0, oldState - damage)
                        local invType = GetData(itemid, value, nbt, "invType")
                        cache[eType][eId][invType][slot][6] = weaponDatas[6]
                        
                        exports['cr_controls']:toggleControl("fire", false, "high")
                        exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                        weaponHeated = true
                        weaponHeatedTable[id] = true
                        exports['cr_controls']:toggleControl("action", false, "high")
                        
                        playSound("assets/sounds/overheat.mp3")
                        
                        exports['cr_infobox']:addBox("error", "A fegyvered túlmelegedett!")
                        
                        triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], invType)
                        triggerServerEvent("weaponHeatedSound", localPlayer, localPlayer)
                        
                        if weaponDatas[6] <= 0 then
                            hideWeapon()
                        end
                    end
                end
                
                weaponHeatTick[id] = getTickCount()
            end
            
            local weaponID = convertIdToWeapon(itemid, value, nbt)
            if ammo == 1 or ammo == 0 or ammo == 2 then
                triggerServerEvent("setWeaponAmmo", localPlayer, localPlayer, weaponID, 30)
            end
            
            if ammo <= 0 then
                local now = getTickCount()
                if now <= lastCallTick + 2500 then
                    cancelLatentEvent(lastCall)
                end 

                local weaponName = getItemName(itemid, value, nbt)
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                exports['cr_chat']:createMessage(localPlayer, "kifogyott a lőszer ("..weaponName..")", "do")
                
                setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
                setElementData(localPlayer, "pulling", false)   
                local blue = exports['cr_core']:getServerColor("blue", true)
                exports['cr_infobox']:addBox("error", "A fegyver újratöltéséhez használd az "..blue.."'R'#ffffff bilentyűt!")
                exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
                exports['cr_controls']:toggleControl("fire", false, "high")
                canShot = false
                exports['cr_controls']:toggleControl("action", false, "high")
                
                if not binded then
                    bindKey("r", "down", reloadWeapon)
                    binded = true
                end

                if clipBinded then 
                    unbindKey("r", "down", reloadWeaponClip)        
                    clipBinded = false
                end 

                cancelMove(5)
                local invType = GetData(itemid, value, nbt, "invType")
                cache[eType][eId][invType][slot2] = nil
                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot2, invType)
                local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
                if hasData then
                    local slot2, data = unpack(hasData)
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    if tonumber(slot2) and tonumber(slot2) >= 1 then
                        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot2] = nil
                    end
                end
                local itemID = weaponDatas[3]
                
                return
            elseif ammo > 0 then
                local invType = GetData(itemid, value, nbt, "invType")
                cache[eType][eId][invType][slot2][4] = ammo
                cancelMove(5)

                local now = getTickCount()
                if now <= lastCallTick + 2500 then
                    cancelLatentEvent(lastCall)
                end 
                triggerLatentServerEvent("countUpdate", 50000, false, localPlayer, localPlayer, slot2, invType, ammo)
                lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
                lastCallTick = getTickCount()
            end
        else
            triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)
            cancelEvent()
        end
    end
)

addEvent("weaponHeatedSound", true)
addEventHandler("weaponHeatedSound", root,
    function(e)
        if isElementStreamedIn(e) then
            if e ~= localPlayer then
                attachElements(playSound3D("assets/sounds/overheat.mp3", getElementPosition(e)), e)
            end
        end
    end
)

function reloadWeapon()
    local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
    local ammoItemID = GetData(itemid, value, nbt, "ammoID") --items[itemid]["ammoID"]
                
    local has, slot2, data = hasItem(localPlayer, ammoItemID)
    
    if has then
        if weaponHeated then
            exports['cr_infobox']:addBox("error", "A fegyvered túlmelegedett így nemtudod újratölteni!")
            return
        end
        
        local hasData = {slot2, data}
        ammo = data[4]
        weaponDatas[10] = ammo
        weaponDatas[11] = hasData
        activeSlot[GetData(data[2], data[3], data[8], "invType") .. "-" .. slot2] = true
        local weaponName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "újratölt egy fegyvert ("..weaponName..")", 1)
        exports['cr_controls']:toggleControl("fire", true, "high")
        exports['cr_controls']:toggleControl("vehicle_fire", true, "high")
        canShot = true
        exports['cr_controls']:toggleControl("action", false, "high")
        if binded then
            unbindKey("r", "down", reloadWeapon)
            binded = false
        end

        if not clipBinded then 
            bindKey("r", "down", reloadWeaponClip)        
            clipBinded = true
        end 

        localPlayer:setData("weaponDatas", weaponDatas)
        
        local weaponID = convertIdToWeapon(itemid, value, nbt)
        triggerServerEvent("setWeaponAmmo", localPlayer, localPlayer, weaponID, ammo)
        
        local crouch = false;
        if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
            crouch = true;
        end
        if not crouch then
            local anim = localPlayer:getData("forceAnimation") or {"", ""}
            if anim[1] ~= "" or anim[2] ~= "" then return end
            
            triggerServerEvent('reloadPedWeapon', localPlayer, localPlayer)
        end
    else
        local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        exports['cr_infobox']:addBox("error", "Nincs nálad a fegyverhez való lőszer ("..GetData(ammoItemID, nil, nil, "name") ..")")
    end
end

lastRelodClipTick = -1000
function reloadWeaponClip()
    if weaponInHand then
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo = unpack(weaponDatas)

        if tonumber(ammo or 0) > 0 then 
            if localPlayer:getAmmoInClip() < getWeaponProperty(weaponInHandID, 'poor', 'maximum_clip_ammo') then
                if lastRelodClipTick + 1000 > getTickCount() then
                    return
                end
                lastRelodClipTick = getTickCount()

                if weaponHeated then
                    return
                end

                local crouch = false;
                if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
                    crouch = true;
                end
                if not crouch then
                    triggerServerEvent('reloadPedWeapon', localPlayer, localPlayer)
                end 
            end 
        end 
    end 
end 

local sx, sy = guiGetScreenSize()

function drawnFoodBar()
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
            alpha = 0
            --removeEventHandler("onClientRender", root, drawnFoodBar)
            destroyRender("drawnFoodBar")
            return
        end
    end
    
    local tooltip = false
    
    local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
    
    local sw = getNode("Actionbar", "w")
    local sx, sy = getNode("Actionbar", "x") + sw/2, getNode("Actionbar", "y") - 50 - 20
    
    local b = 45
    
    local startX, startY = sx, sy - b/2
    dxDrawRectangle(startX - b/2 - 1, startY - 1, b + 2, b + 2, tocolor(0,0,0,math.min(alpha, 255*0.75)))
    dxDrawImage(startX - b/2, startY, b, b, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,alpha))
    
    if isInSlot(startX - b/2, startY, b, b) then
        tooltip = true
    end
    
    if tooltip then
        local cx, cy = exports['cr_core']:getCursorPosition()
        renderTooltip(cx, cy, {id, itemid, value, count, status, dutyitem, premium, nbt}, alpha)
        tooltip = false
    end
    
    local startY = startY + b
    
    local wMultipler = 1 - (math.abs(dropNum - _dropNum) / _dropNum)
    local color = {} 
    if wMultipler <= 0.25 then
        color = {253, 0, 0}
    elseif wMultipler <= 0.5 then
        color = {253, 105, 0}
    elseif wMultipler <= 0.75 then
        color = {253, 168, 0} 
    elseif wMultipler <= 1 then 
        color = {106, 253, 0}
    end  
    local w, h = 80, 10
    local x, y = sx - w/2, startY + 10
    dxDrawRectangle(x,y + h,w,h, tocolor(242, 242, 242, alpha * 0.6))
    dxDrawRectangle(x,y + h,w * wMultipler,h, tocolor(255,59,59, alpha))
end

function giveHunger(give)
	if give then
		if getElementData(localPlayer, "char >> food") + give <= 100 then
			setElementData(localPlayer, "char >> food", getElementData(localPlayer, "char >> food") + give)
            isEaten = true
			return true
		elseif getElementData(localPlayer, "char >> food") == 100 then 
			exports['cr_infobox']:addBox("warning", "Nem vagy éhes")
            isEaten = true
			return false
		elseif getElementData(localPlayer, "char >> food") + give > 100 then
			setElementData(localPlayer, "char >> food", 100)
            isEaten = true
			return true
		end 
	end 
end

function giveWater(give, ignoreWaterLevel)
	if give then
		if getElementData(localPlayer, "char >> drink") + give <= 100 then
			setElementData(localPlayer, "char >> drink", getElementData(localPlayer, "char >> drink") + give)
            isEaten = true
			return true
		elseif getElementData(localPlayer, "char >> drink") == 100 and not ignoreWaterLevel then 
			exports['cr_infobox']:addBox("warning", "Nem vagy szomjas")
            isEaten = true
			return false
		elseif getElementData(localPlayer, "char >> drink") + give > 100 then
			setElementData(localPlayer, "char >> drink", 100)
            isEaten = true
			return true
		end 
	end 
end

lastFoodTick = -1000

function interactFoodBar(b,s)
    local sx, sy = getNode("Actionbar", "x") + (getNode("Actionbar", "w")/2), getNode("Actionbar", "y") - 50 - 20
    
    local c = 50
    local _b = b
    local b = 45
    
    if not isInSlot(sx - c/2, sy - c/2, c, c) then
        return
    end
    
    local b = _b
    
    if b == "left" and s == "down" then
        if lastFoodTick + 500 > getTickCount() then
            return
        end
        lastFoodTick = getTickCount()
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        local itemName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "eldob egy "..convertFoodType(GetData(itemid, value, nbt, "food") and "food" or GetData(itemid, value, nbt, "drink")and "water").." ("..itemName..")", 1)
        isUsingFood = false
        localPlayer:setData("isUsingFood", isUsingFood)
        triggerServerEvent("usingFood", localPlayer, localPlayer, localPlayer:getData("isUsingFood"), localPlayer:getData("isUsingFood.foodType"))
        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil

        start = false
        startTick = getTickCount()
        removeEventHandler("onClientClick", root, interactFoodBar)
        
        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, invType, count - 1)
        end
    elseif b == "right" and s == "down" then
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)

        if lastFoodTick + ((GetData(itemid, value, nbt, "food") and 2 * 1000 or GetData(itemid, value, nbt, "drink") and 5 * 1000)) > getTickCount() then
            return
        end
        lastFoodTick = getTickCount()

        local itemName = getItemName(itemid, value, nbt)
        local chance = 100 - status
        local rand = math.random(1, 100)
        local hpRemove = math.random(15, 50) * (chance / 100)
        
        local foodType = (GetData(itemid, value, nbt, "food") and "food" or GetData(itemid, value, nbt, "drink") and "water") == "food" and "kajától" or "italtól"
        
        local text = "a(z) "..foodType
        
        dropNum = dropNum - 1
        
        if rand <= chance then
            if foodType == "kajától" then
                localPlayer:setData("forceAnimation", {"food", "eat_burger", 4000, false, true, true})
            else
                localPlayer:setData("forceAnimation", {"VENDING", "VEND_Drink_P", 4000, false, true, true})
            end
            playSound("assets/sounds/eat.mp3")
            isEaten = true
            exports['cr_chat']:createMessage(localPlayer, "rosszul lett "..text.." ("..itemName..")", "do")
            setElementHealth(localPlayer, math.max(0, getElementHealth(localPlayer) - hpRemove))
        else
            if foodType == "kajától" then
                local give = GetData(itemid, value, nbt, "BiteAdd") * (status / 100)

                if giveHunger(give) then
                    exports['cr_chat']:createMessage(localPlayer, "eszik egy harapást a(z) "..foodType:gsub("tól", "ból").." ("..itemName..")", 1)
                    localPlayer:setData("forceAnimation", {"food", "eat_burger", 4000, false, true, true, false})
                    playSound("assets/sounds/eat.mp3")
                    isEaten = true
                else
                    dropNum = dropNum + 1
                end
            else
                local give = GetData(itemid, value, nbt, "BiteAdd") * (status / 100)

                if giveWater(give, GetData(itemid, value, nbt, "isDrunkDrink")) then
                    if GetData(itemid, value, nbt, "isDrunkDrink") then
                        local drunkLevel = tonumber(localPlayer:getData("drunkLevel") or 0)
                        local drunkAdd = GetData(itemid, value, nbt, "drunkIndexAdd")
                        localPlayer:setData("drunkLevel", drunkLevel + drunkAdd)
                    end
                    exports['cr_chat']:createMessage(localPlayer, "iszik egy kortyot a(z) "..foodType:gsub("tól", "ból").." ("..itemName..")", 1)
                    localPlayer:setData("forceAnimation", {"VENDING", "VEND_Drink_P", 4000, false, true, true, false})
                    playSound("assets/sounds/drink.mp3")
                    isEaten = true
                else
                    dropNum = dropNum + 1    
                end
            end
        end
        
        if dropNum <= 0 then
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
            local itemName = getItemName(itemid, value, nbt)
            isUsingFood = false
            localPlayer:setData("isUsingFood", isUsingFood)
            triggerServerEvent("usingFood", localPlayer, localPlayer, localPlayer:getData("isUsingFood"), localPlayer:getData("isUsingFood.foodType"))
            activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil

            start = false
            startTick = getTickCount()
            removeEventHandler("onClientClick", root, interactFoodBar)
            
            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local invType = GetData(itemid, value, nbt, "invType")
                checkTableArray(eType, eId, invType)
                cache[eType][eId][invType][slot][4] = count - 1
                cancelMove(5)
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, invType, count - 1)
            end
            return
        end
    end
end

function hideWeapon()    
    if weaponInHand then
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        setPedWeaponSlot(localPlayer, 0)
        exports['cr_controls']:toggleControl("fire", true, "high")
        exports['cr_controls']:toggleControl("vehicle_fire", false, "high")
        canShot = false
        weaponHeated = nil
        exports['cr_controls']:toggleControl("action", false, "high")
        local weaponName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "elrak egy fegyvert ("..weaponName..")", 1)
        if isTimer(shotTimer) then killTimer(shotTimer) end
        if oldWeaponDamageStatus ~= weaponDatas[6] then
            triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 4)    
        end
        
        if binded then
            unbindKey("r", "down", reloadWeapon)
            binded = false
        end

        if clipBinded then 
            unbindKey("r", "down", reloadWeaponClip)        
            clipBinded = false
        end 
    
        setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
        setElementData(localPlayer, "pulling", false)

        local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil
        if hasData then
            local slot2, data = unpack(hasData)
            if tonumber(slot2) and tonumber(slot2) >= 1 then
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot2] = nil
            end
        end
        if isWeapon(itemid, value, nbt) and convertIdToWeapon(itemid, value, nbt) then
            triggerEvent("attachWeapon", localPlayer, localPlayer, convertIdToWeapon(itemid, value, nbt), value, itemid)
        end
        
        local hasPJ = GetData(itemid, value, nbt, "hasPJ")
        local pjSrc
        if hasPJ then
            pjSrc = GetData(itemid, value, nbt, "customTexturePath") or ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
            local tex = GetData(itemid, value, nbt, "textureName") --items[itemid]["textureName"]
            if type(tex) == "table" then
                for k,v in pairs(tex) do
                    if fileExists(v) then
                        pjSrc = v
                    end
                    exports['cr_texturechanger']:destroy(localPlayer, k, pjSrc, true)
                end
            else
                exports['cr_texturechanger']:destroy(localPlayer, tex, pjSrc, true)
            end
        end

        triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)
        weaponInHand = false
        weaponInHandID = 0
        weaponInHandDBID = nil
        localPlayer:setData("weaponInHand", weaponInHand)
    end
    
    if isUsingFood then
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        local itemName = getItemName(itemid, value, nbt)
        isUsingFood = false
        localPlayer:setData("isUsingFood", isUsingFood)
        triggerServerEvent("usingFood", localPlayer, localPlayer, localPlayer:getData("isUsingFood"), localPlayer:getData("isUsingFood.foodType"))
        activeSlot[GetData(itemid, value, nbt, "invType") .. "-" .. slot] = nil

        start = false
        startTick = getTickCount()
        removeEventHandler("onClientClick", root, interactFoodBar)
        
        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            local invType = GetData(itemid, value, nbt, "invType")
            checkTableArray(eType, eId, invType)
            cache[eType][eId][invType][slot][4] = count - 1
            cancelMove(5)
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, invType, count - 1)
        end
    end
end

addEventHandler("onClientPlayerSpawn", localPlayer, 
    function()
        hideWeapon()
        stopMaskEditing(true)
    end
)

addEventHandler("onClientPlayerWasted", localPlayer, 
    function()
        hideWeapon()
        stopMaskEditing(true)
    end
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        localPlayer:setData("drunkLevel", 0)
        
        hideWeapon()
        stopMaskEditing(true)
    end
)

addEvent("pj>apply", true)
addEventHandler("pj>apply", localPlayer,
    function(itemid, value, nbt, obj)        
        local hasPJ = GetData(itemid, value, nbt, "hasPJ")
        local pjSrc
        if hasPJ then
            local weaponID = GetData(itemid, value, nbt, "weaponID")
            pjSrc = GetData(itemid, value, nbt, "customTexturePath") or ":cr_inventory/assets/weaponstickers/"..weaponID.."-"..value..".png"
            local tex = GetData(itemid, value, nbt, "textureName") --items[itemid]["textureName"]
            setTimer(
                function()
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
                end, 500, 1
            )
        end
    end
)

addEventHandler("onClientVehicleStartEnter", root, 
    function(player,seat,door)
        if (player == localPlayer and seat == 0)then
            if weaponInHand then
                if not ignoreWeaponInteractions[weaponInHandID] then 
                    exports['cr_infobox']:addBox("error", "Vezetői ülésbe nem szállhatsz be fegyverrel!")
                    cancelEvent()
                    return
                end 
            end
            
            local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
            if not bone[2] and not bone[3] then
                exports['cr_infobox']:addBox("error", "Vezetői ülésbe nem szállhatsz be hisz törött mindkét kezed!")
                cancelEvent()
                return
            end
        end
    end
)

localPlayer:setData("char >> customName", nil)
lastChangeTick = getTickCount()
function changeMaskName(cmd, ...)
    if (...) then
        local newName = table.concat({...}, " ")
        if #newName >= 1 and #newName <= 30 then
            if newName ~= oMaskNBT["name"] then
                if lastChangeTick + 1000 > getTickCount() then
                    exports['cr_infobox']:addBox("error", "Túl gyors!")
                    return
                end
                lastChangeTick = getTickCount()
                
                local red = exports['cr_core']:getServerColor("yellow", true)
                local blue = exports['cr_core']:getServerColor("blue", true)
                local white = "#ffffff"
                newName = string.gsub(newName, "#" .. string.rep("%x", 6), "")
                newName = newName:gsub("_", " ")
                oMaskNBT["name"] = newName
                updateItemDetails(localPlayer, oMaskSlot, 1, {"nbt", oMaskNBT}, true)
                localPlayer:setData("char >> customName", "(" .. red .. tostring(newName) .. white .. ")")

                exports['cr_infobox']:addBox("info", "A maszkod új neve: "..newName)
            else
                exports['cr_infobox']:addBox("error", "A maszk neve nem lehet ugyanaz!")
            end
        else
            exports['cr_infobox']:addBox("error", "Minimum 1 karakter, maximum 30!")
        end
    end
end

function changeMaskPosition(cmd)
    if not editingMaskPos then
        editingMaskPos = true
        local e = localPlayer:getData("maskParent")
        if e then
            e.alpha = 180
            editingMaskElement = e
            exports['cr_head']:initHeadMove(true)
            exports['cr_elementeditor']:toggleEditor(e, "maskSaveTrigger", "maskRemoveTrigger", true)
        end
    end
end

addEvent("maskSaveTrigger", true)
addEventHandler("maskSaveTrigger", root,
    function(e, x, y, z, rx, ry, rz, scale)
        if e:getData("maskParent") == localPlayer then
            editingMaskPos = false
            editingMaskElement = nil
            
            e.alpha = 255
            
            local offsets = {x, y, z, rx, ry, rz}
            
            oMaskNBT["offsets"] = offsets
            oMaskNBT["scale"] = scale
            updateItemDetails(localPlayer, oMaskSlot, 1, {"nbt", oMaskNBT}, true)
            
            exports['cr_head']:initHeadMove(false)
            triggerServerEvent("destroyMask", localPlayer, localPlayer)
            triggerServerEvent("createMask", localPlayer, localPlayer, oMaskObjID, oMaskItemID, oMaskValue, oMaskNBT, oMaskNBT["offsets"], oMaskNBT["scale"])
        end
    end
)

addEvent("maskRemoveTrigger", true)
addEventHandler("maskRemoveTrigger", root,
    function(e, x, y, z, rx, ry, rz, scale)
        if e:getData("maskParent") == localPlayer and editingMaskElement == e then
            editingMaskPos = false
            editingMaskElement = nil
            
            e.alpha = 255
            exports['cr_head']:initHeadMove(false)
            triggerServerEvent("destroyMask", localPlayer, localPlayer)
            triggerServerEvent("createMask", localPlayer, localPlayer, oMaskObjID, oMaskItemID, oMaskValue, oMaskNBT, oMaskNBT["offsets"], oMaskNBT["scale"])
        end
    end
)

function stopMaskEditing(needDestroy)
    if editingMaskPos then
        local e = editingMaskElement
        if e:getData("maskParent") == localPlayer and editingMaskElement == e then
            exports['cr_elementeditor']:quitEditor(true)
            exports['cr_head']:initHeadMove(false)
            
            editingMaskPos = false
            editingMaskElement = nil
        end
    end
    
    if maskState then
        if needDestroy then
            maskState = false
            
            activeSlot[GetData(oMaskItemID, oMaskValue, oMaskNBT, "invType") .. "-" .. oMaskSlot] = nil
            triggerServerEvent("destroyMask", localPlayer, localPlayer)
            
            oMaskDBID = nil
            oMaskItemID = nil
            oMaskValue = nil
            oMaskSlot = nil
            oMaskNBT = nil

            exports['cr_chat']:createMessage(localPlayer, "levesz egy maszkot a fejéről", 1) -- // ?!

            localPlayer:setData("char >> customName", oldCustomName)

            removeCommandHandler("maskname", changeMaskName)
            removeCommandHandler("maskname", changeMaskPosition)
        end
    end
end