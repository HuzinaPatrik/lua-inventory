connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

phones = {}

spam = {}

spamTimers = {}

white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

function loadItems()
    setElementData(root, "loaded", false)
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local eType = tonumber(row["elementtype"])
                        local eId = tonumber(row["elementid"])
                        local iType = tonumber(row["itemtype"])
                        local itemid = tonumber(row["itemid"])    
                        local slot = tonumber(row["slot"])    
                        local value = tostring(row["value"])
                        local status = tonumber(row["status"])
                        local count = tonumber(row["count"])  
                        if not count then
                            count = 1
                        end
                        local dutyitem = tonumber(row["dutyitem"])    
                        local premium = tonumber(row["premium"])
                        local nbt = tostring(row["nbt"])
                        
                        checkTableArray(eType, eId, iType, slot)
                        
                        if iType == 10 then
                            local table = fromJSON(value)
                            table[3] = id
                            cache[eType][eId][iType][slot] = table
                        else
                            if tonumber(value) then
                                value = tonumber(value)
                            elseif fromJSON(value) then
                                value = fromJSON(value)
                            end
                            
                            if tonumber(nbt) then
                                nbt = tonumber(nbt)
                            elseif fromJSON(nbt) then
                                nbt = fromJSON(nbt)    
                            end

                            if itemid == 15 then 
                                phones[value] = {eId, nbt, iType, slot}
                            end 

                            cache[eType][eId][iType][slot] = {id, itemid, value, count, status, dutyitem, premium, nbt}
                        end
                    end,
                    
                    function()
                        setElementData(root, "loaded", true)
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." items in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `items`")
    
    giveCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local details = tostring(row["data"])
                        local ownerid = tonumber(row["ownerid"])
                        local ownertype = tonumber(row["ownertype"])
                        local iType = tonumber(row["iType"])
                        
                        local details = fromJSON(details)
                        local tble = {}
                        for k,v in pairs(details) do
                            if tonumber(k) then
                                tble[tonumber(k)] = v
                            else
                                tble[k] = v
                            end
                        end
                        
                        tble["id"] = id
                        
                        if not giveCache[ownertype] then
                            giveCache[ownertype] = {}
                        end
                        
                        if not giveCache[ownertype][ownerid] then
                            giveCache[ownertype][ownerid] = {}
                        end
                        
                        if not giveCache[ownertype][ownerid][iType] then
                            giveCache[ownertype][ownerid][iType] = {}
                        end
                        
                        table.insert(giveCache[ownertype][ownerid][iType], tble)
                    end,
                    
                    function()
                        setElementData(root, "loaded", true)
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." giveCache items in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `items_givecache`")
    
    trashCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local pos = fromJSON(tostring(row["pos"]))
                        
                        local x,y,z,rot,int,dim = unpack(pos)
                        local obj = createObject(1359, x,y,z)
                        obj.rotation.z = 0
                        obj.interior = int
                        obj.dimension = dim
                        obj:setData("trash.id", id)
                        trashCache[id] = obj
                    end,
                    
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." trash in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `trash`")
    
    safeCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local pos = fromJSON(tostring(row["pos"]))
                        
                        local x,y,z,rot1,rot2,rot3,int,dim = unpack(pos)
                        local obj = createObject(2332, x,y,z)
                        obj:setData("safe.id", id)
                        obj.rotation = Vector3(rot1,rot2,rot3)
                        obj.interior = int
                        obj.dimension = dim
                        safeCache[id] = obj
                    end,
                    
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." safe in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `safe`")
    
    worldItems = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local pos = fromJSON(tostring(row["pos"]))
                        local data = fromJSON(tostring(row["data"]))
                        
                        local objID, x,y,z,rot,dim,int = unpack(pos)
                        local obj = createObject(objID, x,y,z)
                        obj:setData("worldItemId", id)
                        obj:setData("worldItemData", data)
                        obj.interior = int
                        obj.dimension = dim
                        worldItems[id] = obj
                    end,
                    
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." worlditem in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `worlditems`")
end
addEventHandler("onResourceStart", resourceRoot, loadItems)

spamTimers["createWorldItem"] = {}

addEvent("createWorldItem", true)
addEventHandler("createWorldItem", root,
    function(sourceElement, itemDetails, oldSlot, pos)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemDetails)
        
        local iType = GetData(itemid, value, count, "invType")
        local eType = getEType(sourceElement)
        local eId = getEID(sourceElement)
        
        if cache[eType][eId][iType][oldSlot] and cache[eType][eId][iType][oldSlot][1] == id then
            if sourceElement.type == "player" then
                if isWeapon(itemid, value, nbt) then
                    triggerClientEvent(sourceElement, "deAttachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, value, nbt), itemid)
                end
            end
            
            local eType = getEType(sourceElement)
            local eId = getEID(sourceElement)

            for i = 1, 10 do
                if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                    local invType, slot2, id = unpack(cache[eType][eId][10][i])

                    if invType == iType then
                        if oldSlot == slot2 then
                            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                            cache[eType][eId][10][i] = nil
                        end
                    end
                end
            end

            cache[eType][eId][iType][oldSlot] = nil
            local id = itemDetails[1]
            local eType = getEType(sourceElement)
            dbExec(connection, "UPDATE `items` SET `elementtype`=? WHERE `id`=?", eType * -1, id)

            if itemid == 15 then 
                changePhoneData(value, "eId", eId)
                changePhoneData(value, "invType", iType)
            end 

            if checkItemsInGiveCache(sourceElement, iType) then
                setTimer(giveItemsFromGiveCache, 1000, 1, sourceElement, iType)
            end
            
            local objID, x,y,z,rot,dim,int = unpack(pos)
            local obj = createObject(objID, x,y,z)
            obj:setData("worldItemData", itemDetails)
            obj.interior = int
            obj.dimension = dim
            
            dbExec(connection, "INSERT INTO `worlditems` SET `pos`=?, `data`=?", toJSON(pos), toJSON(itemDetails))
            
            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                local id = tonumber(row["id"])
                                obj:setData("worldItemId", id)
                                worldItems[id] = obj
                            end
                        )
                    end
                end, 
            connection, "SELECT * FROM `worlditems` WHERE `pos`=? AND `data`=?", toJSON(pos), toJSON(itemDetails))

            exports['cr_animation']:applyAnimation(sourceElement,"CARRY","putdwn", 1500,false,false,false,false)
            
            exports['cr_chat']:createMessage(sourceElement, "lehelyez egy tárgyat a földre ("..getItemName(itemid, value, nbt)..")", 1)
        end
        
        local eId = getEID(sourceElement)
        exports['cr_logs']:addLog(sourceElement, "Inventory", "worlditems.create", "Item kidobás: "..eId.." létrehozott egy világitemet: "..toJSON(itemDetails))
        
        needValue(sourceElement, "items", sourceElement)
    end
)

addEvent("pickupWorldItem", true)
addEventHandler("pickupWorldItem", root,
    function(sourceElement, obj)
        if isElement(obj) then
            local itemDetails = obj:getData("worldItemData") 
            if itemDetails then
                local objID = obj:getData("worldItemId")
                if worldItems[objID] then
                    worldItems[objID] = nil
                    dbExec(connection, "DELETE FROM `worlditems` WHERE `id`=?", tonumber(objID))
                    obj:destroy()
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemDetails)

                    local iType = GetData(itemid, value, count, "invType")
                    local eType = getEType(sourceElement)
                    local eId = getEID(sourceElement)

                    if isElementHasSpace(sourceElement, iType, itemid, value, nbt, count) then
                        local slot = getFreeSlot(sourceElement, iType)

                        checkTableArray(eType, eId, iType, slot)

                        if sourceElement.type == "player" then
                            if isWeapon(itemid, value, nbt) then
                                triggerClientEvent(sourceElement, "attachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, value, nbt), value, itemid)
                            end
                        end

                        cache[eType][eId][iType][slot] = itemDetails
                        local id = itemDetails[1]
                        dbExec(connection, "UPDATE `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `slot`=? WHERE `id`=?", eType, eId, iType, slot, id)

                        if itemid == 15 then 
                            changePhoneData(value, "eId", eId)
                            changePhoneData(value, "invType", iType)
                            changePhoneData(value, "slot", slot)
                        end 
                    else
                        --addItemToGiveCache(sourceElement, {iType, itemDetails}, "transportItem")
                        exports['cr_infobox']:addBox(from, "error", "Nincs elég hely/slot az inventorydban!")
                        needValue(from, "items", from)
                        return
                    end

                    exports['cr_chat']:createMessage(sourceElement, "felvesz egy tárgyat a földről ("..getItemName(itemid, value, nbt)..")", 1)
                    exports['cr_animation']:applyAnimation(sourceElement,"CARRY","liftup", 1700,false,false,false,false)
                    needValue(sourceElement, "items", sourceElement)
                end
            end
        end
    end
)

function createTrash(sourceElement, cmd)
    if exports['cr_permission']:hasPermission(sourceElement, "addtrash") then
        local x,y,z = getElementPosition(sourceElement)
        z = z - 0.35
        local rot = 0--getElementRotation(sourceElement)
        local dim = sourceElement.dimension
        local int = sourceElement.interior
        local t = toJSON({x,y,z,rot,int,dim})
        
        sourceElement.position = Vector3(x,y,z+1)
        
        dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local pos = fromJSON(tostring(row["pos"]))

                            local x,y,z,rot,int,dim = unpack(pos)
                            local obj = createObject(1359, x,y,z)
                            obj.interior = int
                            obj.dimension = dim
                            obj:setData("trash.id", id)
                            trashCache[id] = obj
                            
                            local green = exports['cr_core']:getServerColor('yellow', true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "success")
                            outputChatBox(syntax .. "Sikeresen létrehoztál egy kukát (#"..green..id..white..")", sourceElement, 255,255,255,true)
                            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                            local syntax = exports['cr_admin']:getAdminSyntax()
                            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." létrehozott egy kukát (#"..green..id..white..")", 8)
                            
                            exports['cr_logs']:addLog(sourceElement, "Inventory", "addtrash", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " létrehozott egy kukát (#"..id..")")
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `trash` WHERE `pos`=?", t)
        
    end
end
addCommandHandler("addtrash", createTrash)
addCommandHandler("maketrash", createTrash)
addCommandHandler("ctrash", createTrash)

function deleteTrash(sourceElement, cmd, id)
    if exports['cr_permission']:hasPermission(sourceElement, "deltrash") then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if trashCache[id] then
            local obj = trashCache[id]
            local x,y,z = getElementPosition(obj)
            local rot = 0--obj.rotation.z
            local dim = obj.dimension
            local int = obj.interior
            local t = toJSON({x,y,z,rot,int,dim})
            dbExec(connection, "DELETE FROM `trash` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            trashCache[id] = nil
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen töröltél egy kukát (#"..green..id..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy kukát (#"..green..id..white..")", 8)
            
            exports['cr_logs']:addLog(sourceElement, "Inventory", "deltrash", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy kukát (#"..id..")")
        end
    end
end
addCommandHandler("deltrash", deleteTrash)

function deleteWorldItem(sourceElement, cmd, id)
    if exports['cr_permission']:hasPermission(sourceElement, "deltrash") then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if worldItems[id] then
            local obj = worldItems[id]
            dbExec(connection, "DELETE FROM `worlditems` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            worldItems[id] = nil
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen töröltél egy világitemet (#"..green..id..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy világitemet (#"..green..id..white..")", 8)
            
            exports['cr_logs']:addLog(sourceElement, "Inventory", "delworlditem", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy világitemet (#"..id..")")
        end
    end
end
addCommandHandler("delworlditem", deleteWorldItem)

function createSafe(sourceElement, cmd, ignorePerm, xyz, specRot)
    if exports['cr_permission']:hasPermission(sourceElement, "addsafe") or ignorePerm then
        local x,y,z = unpack(xyz) --getElementPosition(sourceElement)
        z = z - 0.35
        local rot = sourceElement.rotation
        local dim = sourceElement.dimension
        local int = sourceElement.interior
        if xyz then
            x,y,z = unpack(xyz)
        end
        if specRot then 
            rot = Vector3(unpack(specRot))
        end 
        local t = toJSON({x,y,z,rot.x,rot.y,rot.z,int,dim})
        
        dbExec(connection, "INSERT INTO `safe` SET `pos`=?", t)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local pos = fromJSON(tostring(row["pos"]))

                            local x,y,z,rot1,rot2,rot3,int,dim = unpack(pos)
                            local obj = createObject(2332, x,y,z)
                            obj:setData("safe.id", id)
                            obj.rotation = Vector3(rot1,rot2,rot3)
                            obj.interior = int
                            obj.dimension = dim
                            safeCache[id] = obj
                            
                            if not ignorePerm then
                                local green = exports['cr_core']:getServerColor('yellow', true)
                                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                                outputChatBox(syntax .. "Sikeresen létrehoztál egy széfet (#"..green..id..white..")", sourceElement, 255,255,255,true)
                                local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                                local syntax = exports['cr_admin']:getAdminSyntax()
                                exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." létrehozott egy széfet (#"..green..id..white..")", 8)
                            end

                            exports['cr_logs']:addLog(sourceElement, "Inventory", "addsafe", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " létrehozott egy széfet (#"..id..")")
                            giveItem(sourceElement, convertKey("safe"), id, 1, 100, 0, 0, 0, true)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `safe` WHERE `pos`=?", t)
        
    end
end

addEvent("createSafe", true)
addEventHandler("createSafe", root,
    function(sourceElement, cmd, ignorePerm, pos)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                createSafe(sourceElement, cmd, ignorePerm, pos)
            end
        end
    end
)

function updateSafePosition(e, pos)
    if isElement(e) and tonumber(e:getData("safe.id")) then
        local x,y,z,rx,ry,rz = unpack(pos)
        e.position = Vector3(x,y,z)
        e.rotation = Vector3(rx,ry,rz)
        local t = toJSON({x,y,z,rx,ry,rz,e.interior,e.dimension})
        dbExec(connection, "UPDATE `safe` SET `pos`=? WHERE `id`=?", t, tonumber(e:getData("safe.id")))
    end
end
addEvent("updateSafePosition", true)
addEventHandler("updateSafePosition", root, updateSafePosition)

function safeChangeState(e, alpha)
    if isElement(e) then
        e.alpha = alpha
        if alpha == 255 then
            e.collisions = true
        elseif alpha == 180 then
            e.collisions = false
        end
    end
end
addEvent("safeChangeState", true)
addEventHandler("safeChangeState", root, safeChangeState)

function deleteSafe(sourceElement, cmd, id, ignorePerm)
    if exports['cr_permission']:hasPermission(sourceElement, "delsafe") or ignorePerm then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if safeCache[id] then
            local obj = safeCache[id]
            local x,y,z = getElementPosition(obj)
            local rot = obj.rotation.z
            local dim = obj.dimension
            local int = obj.interior
            local t = toJSON({x,y,z,rot,int,dim})

            dbExec(connection, "DELETE FROM `safe` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            safeCache[id] = nil

            if not ignorePerm then
                local green = exports['cr_core']:getServerColor('yellow', true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                outputChatBox(syntax .. "Sikeresen töröltél egy széfet (#"..green..id..white..")", sourceElement, 255,255,255,true)
                local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy széfet (#"..green..id..white..")", 8)
            end
            exports['cr_logs']:addLog(sourceElement, "Inventory", "delsafe", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy széfet (#"..id..")")
        end
    end
end
addCommandHandler("delsafe", deleteSafe)

addEvent("deleteSafe", true)
addEventHandler("deleteSafe", root,
    function(sourceElement, cmd, id, ignorePerm)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                deleteSafe(sourceElement, cmd, id, ignorePerm)
            end
        end
    end
)

function getSafe(sourceElement, cmd, id)
    if exports['cr_permission']:hasPermission(sourceElement, "getsafe") then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if safeCache[id] then
            local obj = safeCache[id]

            if obj.dimension == sourceElement.dimension and obj.interior == sourceElement.interior then 
                local pos = sourceElement.position
                sourceElement.position = Vector3(pos.x, pos.y, pos.z + 0.5)

                obj.position = Vector3(pos.x, pos.y, pos.z - 0.5)
                obj.rotation = Vector3(0, 0, exports['cr_core']:findRotation(sourceElement.position.x, sourceElement.position.y, pos.x, pos.y))

                local t = toJSON({pos.x,pos.y,pos.z - 0.5,obj.rotation.x,obj.rotation.y,obj.rotation.z,obj.interior,obj.dimension})
        
                dbExec(connection, "UPDATE `safe` SET `pos`= ? WHERE `id`=?", t, tonumber(id))

                if not ignorePerm then
                    local green = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    outputChatBox(syntax .. "Sikeresen áthelyeztél egy széfet (#"..green..id..white..")", sourceElement, 255,255,255,true)
                    local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." áthelyeztél egy széfet (#"..green..id..white..")", 8)
                end

                exports['cr_logs']:addLog(sourceElement, "getsafe", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " áthelyezett egy széfet (#"..id..")")
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. 'Nem vagy egy dimenzióban/interiorban ezzel a széffel!', sourceElement, 255, 255, 255, true)
            end
        end
    end
end
addCommandHandler("getsafe", getSafe)

function needValue(sourceElement, rtype, neededElement, spec)
    if rtype == "items" then
        local args = {}
        local eType = getEType(neededElement)
        local eId = getEID(neededElement)
        if cache[eType] then
            if cache[eType][eId] then
                args = cache[eType][eId]
            end
        end

        args = args
        if sourceElement.type ~= "player" then
            local invE = sourceElement:getData("inventory.open")
            if invE and isElement(invE) and invE.type == "player" then
                sourceElement = invE
                triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
            end
            
            local invE = sourceElement:getData("inventory.open2")
            if invE and isElement(invE) and invE.type == "player" then
                sourceElement = invE
                triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
            end
        else
            triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
        end
    end
end

addEvent("needValue", true)
addEventHandler("needValue", root,
    function(sourceElement, rtype, neededElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client and neededElement then
                needValue(sourceElement, rtype, neededElement)
            end
        end
    end
)

spamTimers["changeSlot"] = {}

function changeSlot(sourceElement, oldSlot, newSlot, iType, oData, oData2)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    if cache[eType][eId][iType][oldSlot] and type(cache[eType][eId][iType][oldSlot][1]) == "number" and cache[eType][eId][iType][oldSlot][1] == oData[1] and cache[eType][eId][iType][newSlot] and type(cache[eType][eId][iType][newSlot][1]) == "number" and cache[eType][eId][iType][newSlot][1] == oData2[1] then
        
        local oData = cache[eType][eId][iType][oldSlot]
        local oData2 = cache[eType][eId][iType][newSlot]
        cache[eType][eId][iType][newSlot] = oData
        cache[eType][eId][iType][oldSlot] = oData2
        
        if sourceElement:getData("usingRadio") then
            if tonumber(sourceElement:getData("usingRadio.slot") or 0) == oldSlot then
                sourceElement:setData("usingRadio.slot", newSlot)
            end
        end
        
        if iType == 10 then
            local invType, pairSlot, id = unpack(oData)
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)
            
            local invType, pairSlot, id = unpack(oData2)
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", oldSlot, id)
        else
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(oData)
            if itemid == 15 then 
                changePhoneData(value, "slot", oldSlot)
            end 
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)

            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(oData2)
            if itemid == 15 then 
                changePhoneData(value, "slot", newSlot)
            end 
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", oldSlot, id)
        end
    end
    
    needValue(sourceElement, "items", sourceElement)
end

addEvent("changeSlot", true)
addEventHandler("changeSlot", root,
    function(sourceElement, oldSlot, newSlot, iType, oData, oData2)
        changeSlot(sourceElement, oldSlot, newSlot, iType, oData, oData2)
    end
)

spamTimers["updateSlot"] = {}

function updateSlot(sourceElement, oldSlot, newSlot, iType, oData)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    if cache[eType][eId][iType][oldSlot] and type(cache[eType][eId][iType][oldSlot][1]) == "number" and cache[eType][eId][iType][oldSlot][1] == oData[1] and not cache[eType][eId][iType][newSlot] then
        
        cache[eType][eId][iType][newSlot] = cache[eType][eId][iType][oldSlot]
        cache[eType][eId][iType][oldSlot] = nil
        
        if sourceElement:getData("usingRadio") then
            if tonumber(sourceElement:getData("usingRadio.slot") or 0) == oldSlot then
                sourceElement:setData("usingRadio.slot", newSlot)
            end
        end
        
        if iType == 10 then
            local invType, pairSlot, id = unpack(cache[eType][eId][iType][newSlot])
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)
        else
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][newSlot])
            if itemid == 15 then 
                changePhoneData(value, "slot", newSlot)
            end 
            
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)
        end
    end
    
    needValue(sourceElement, "items", sourceElement)
end

addEvent("updateSlot", true)
addEventHandler("updateSlot", root,
    function(sourceElement, oldSlot, newSlot, iType, oData)
        updateSlot(sourceElement, oldSlot, newSlot, iType, oData)
    end
)

spamTimers["countUpdate"] = {}

function countUpdate(sourceElement, slot, iType, newCount, ignoreTrigger)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])
    
    if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
        
        local oldCount = cache[eType][eId][iType][slot][4]
        cache[eType][eId][iType][slot] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}

        dbExec(connection, "UPDATE `items` SET `count`=? WHERE `id`=?", newCount, id)
    end
    
    if not ignoreTrigger then
        needValue(sourceElement, "items", sourceElement, "count")
    end
end

addEvent("countUpdate", true)
addEventHandler("countUpdate", root,
    function(sourceElement, slot, iType, newCount, ignoreTrigger)
        if client and client.type == "player" then
            countUpdate(sourceElement, slot, iType, newCount, ignoreTrigger)
        end
    end
)

spamTimers["acValueUpdate"] = {}

function acValueUpdate(sourceElement, slot, iType, newValue)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    if cache[eType][eId][iType][slot] then
        local oldValue = cache[eType][eId][iType][slot]
        local id = oldValue[3]
        newValue[3] = oldValue[3]
        cache[eType][eId][iType][slot] = newValue

        dbExec(connection, "UPDATE `items` SET `value`=? WHERE `id`=?", toJSON(newValue), id)
    end
end

addEvent("ac.valueUpdate", true)
addEventHandler("ac.valueUpdate", root,
    function(sourceElement, slot, iType, newValue)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                acValueUpdate(sourceElement, slot, iType, newValue)
            end
        end
    end
)

spamTimers["removeItemFromSlot"] = {}

function removeItemFromSlot(sourceElement, slot, iType, ignoreTrigger)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    if iType == 10 then
        if cache[eType][eId][iType][slot] then
            local value = cache[eType][eId][iType][slot]
            local id = value[3]
            cache[eType][eId][iType][slot] = nil
            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
        end
    else
        if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])
            if sourceElement.type == "player" then
                if itemid == 19 then
                    if sourceElement:getData("usingRadio") then
                        if tonumber(sourceElement:getData("usingRadio.slot") or 0) == slot then
                            sourceElement:setData("usingRadio", false)
                        end
                    end
                end

                if itemid == 15 then 
                    if phones[value] then 
                        phones[value] = nil 
                        collectgarbage("collect")
                    end 
                end 
                
                if isWeapon(itemid, value, nbt) then
                    triggerClientEvent(sourceElement, "deAttachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, value, nbt), itemid)
                end
            end
            
            for i = 1, 10 do
                if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                    local invType, slot2, id = unpack(cache[eType][eId][10][i])

                    if invType == iType then
                        if slot == slot2 then
                            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                            cache[eType][eId][10][i] = nil
                        end
                    end
                end
            end
            
            cache[eType][eId][iType][slot] = nil
            
            if checkItemsInGiveCache(sourceElement, iType) then
                setTimer(giveItemsFromGiveCache, 1000, 1, sourceElement, iType)
            end

            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
        end
    end
    
    if not ignoreTrigger then
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("removeItemFromSlot", true)
addEventHandler("removeItemFromSlot", root,
    function(sourceElement, slot, iType, ignoreTrigger)
        if client and client.type == "player" then
            removeItemFromSlot(sourceElement, slot, iType, ignoreTrigger)
        end
    end
)

spamTimers["addItemToSlot"] = {}

function addItemToSlot(sourceElement, slot, iType, details, ignoreTrigger)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    if not isTableArray(eType, eId, iType) then
        checkTableArray(eType, eId, iType)
    end
    
    if not cache[eType][eId][iType][slot] then
        cache[eType][eId][iType][slot] = details

        if iType ~= 10 then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(details)

            dbExec(connection, "INSERT INTO `items` SET `status`=?, `dutyitem`=?, `count`=?,`value`=?,`itemid`=?,`premium`=?,`nbt`=?,`itemtype`=?,`elementtype`=?,`elementid`=?,`slot`=?", status, dutyitem, count, value, itemid, premium, nbt, iType, eType, eId, slot)

            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                local id = tonumber(row["id"])
                                cache[eType][eId][iType][slot][1] = id
                                needValue(sourceElement, "items", sourceElement)
                            end
                        )
                    end
                end, 
            connection, "SELECT * FROM `items` WHERE `elementtype`=? AND `elementid`=? AND `itemtype`=? AND `slot`=?", eType, eId, iType, slot)
        else
            local value = toJSON(details)
            dbExec(connection, "INSERT INTO `items` SET `value`=?,`itemtype`=?,`elementtype`=?,`elementid`=?,`slot`=?", value, iType, eType, eId, slot)

            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                local id = tonumber(row["id"])
                                local nbt = tostring(row["nbt"])
                                cache[eType][eId][iType][slot][3] = id

                                if tonumber(nbt) then
                                    nbt = tonumber(nbt)
                                elseif fromJSON(nbt) then
                                    nbt = fromJSON(nbt)    
                                end

                                if itemid == 15 then 
                                    phones[value] = {eId, nbt, iType, slot}
                                end 

                                if oldID then
                                    local _id = id
                                    local id = tonumber(oldID)
                                    cache[eType][eId][iType][slot][3] = id

                                    dbExec(connection, "UPDATE `items` SET `id`=? WHERE `id`=?", id, _id)
                                end
                                needValue(sourceElement, "items", sourceElement)
                            end
                        )
                    end
                end, 
            connection, "SELECT * FROM `items` WHERE `value`=? AND `itemtype`=? AND `elementtype`=? AND `elementid`=? AND `slot`=?", value, iType, eType, eId, slot)
        end

        if not ignoreTrigger then
            needValue(sourceElement, "items", sourceElement)
        end
    end
end

addEvent("addItemToSlot", true)
addEventHandler("addItemToSlot", root,
    function(sourceElement, slot, iType, details, ignoreTrigger)
        if client and client.type == "player" then
            addItemToSlot(sourceElement, slot, iType, details, ignoreTrigger)
        end
    end
)

local execTable = {}

function updateStatus(sourceElement, slot, newStatus, invType)   
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    local iType = invType or 1

    if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
        cache[eType][eId][iType][slot][5] = newStatus

        local dbid = cache[eType][eId][iType][slot][1]
        table.insert(execTable, {"UPDATE `items` SET `status`=? WHERE `id`=?", {newStatus, dbid}})
    else
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("updateStatus", true)
addEventHandler("updateStatus", root,
    function(sourceElement, slot, newStatus, invType)
        if client and client.type == "player" then
            updateStatus(sourceElement, slot, newStatus, invType)
        end
    end
)

function doExec()
    local count = 0
    local tick = getTickCount()
    --local removeTable = {}
    for k,v in ipairs(execTable) do
        local text, variables = unpack(v)
        dbExec(connection, text, unpack(variables))
        --table.insert(removeTable, k)
        count = count + 1
    end
    
    --[[for k,v in ipairs(removeTable) do 
        table.remove(execTable, v)
    end --]]
    execTable = {}
    collectgarbage("collect")
    outputDebugString("Finished #"..count.." dbExec in "..(getTickCount()-tick).." ms!", 0, 255, 50, 255)
end
setTimer(doExec, 10 * 60 * 1000, 0)
addEventHandler("onResourceStop", resourceRoot, doExec)

spamTimers["transportItem"] = {}

addEvent("transportItem", true)
addEventHandler("transportItem", root,
    function(sourceElement, from, to, fromiType, toiType, itemDetails, oldSlot, chatData)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemDetails)
        
        local eType = getEType(from)
        local eId = getEID(from)
        if cache[eType][eId][fromiType][oldSlot] and cache[eType][eId][fromiType][oldSlot][1] == id then
            local hasSpace = isElementHasSpace(to, toiType, itemid, value, nbt, count)
            if not hasSpace then ---if nowWeight + addWeight > maxWeight then
                --addItemToGiveCache(to, {toiType, itemDetails}, "transportItem")
                exports['cr_infobox']:addBox(from, "error", "Nincs elég hely/slot a célpontnál!")
                needValue(from, "items", from)
                return
            end
            
            if from.type == "player" then
                if isWeapon(itemid, value, nbt) then
                    triggerClientEvent(from, "deAttachWeapon", from, from, convertIdToWeapon(itemid, value, nbt), itemid)
                end
            end
            
            if hasSpace then
                if to.type == "player" then
                    if isWeapon(itemid, value, nbt) then
                        triggerClientEvent(to, "attachWeapon", to, to, convertIdToWeapon(itemid, value, nbt), value, itemid)
                    end
                end
            end

            local eType = getEType(from)
            local eId = getEID(from)


            for i = 1, 10 do
                if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                    local invType, slot2, id = unpack(cache[eType][eId][10][i])

                    if invType == fromiType then
                        if oldSlot == slot2 then
                            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                            cache[eType][eId][10][i] = nil
                        end
                    end
                end
            end

            cache[eType][eId][fromiType][oldSlot] = nil
            if not hasSpace then
                local id = itemDetails[1]
                local eType = getEType(to)
                dbExec(connection, "UPDATE `items` SET `elementtype`=? WHERE `id`=?", eType * -1, id)
            end

            if checkItemsInGiveCache(from, fromiType) then
                setTimer(giveItemsFromGiveCache, 1000, 1, from, fromiType)
            end

            if hasSpace then 
                local eType = getEType(to)
                local eId = getEID(to)
                local iType = toiType
                local slot = getFreeSlot(to, toiType)

                checkTableArray(eType, eId, iType, slot)

                cache[eType][eId][iType][slot] = itemDetails

                if itemid == 15 then 
                    changePhoneData(value, "eId", eId)
                    changePhoneData(value, "invType", iType)
                    changePhoneData(value, "slot", slot)
                end 
                local id = itemDetails[1]

                if to.type == "player" and from.type == "player" then
                    itemDetails[7] = 0
                end 

                if from.type ~= "player" and to.type == "player" then 
                    if tonumber(itemDetails[7] or 0) ~= 0 then 
                        if to:getData('acc >> id') ~= itemDetails[7] then 
                            itemDetails[7] = 0
                        end 
                    end 
                end 
                
                dbExec(connection, "UPDATE `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `slot`=?, `premium`=? WHERE `id`=?", eType, eId, iType, slot, itemDetails[7], id)
            end

            exports['cr_animation']:applyAnimation(from,"DEALER","DEALER_DEAL",3000,false,false,false,false)
            exports['cr_animation']:applyAnimation(to,"DEALER","DEALER_DEAL",3000,false,false,false,false)
            
            if chatData and type(chatData) == "table" then
                exports['cr_chat']:createMessage(unpack(chatData))
            end
        end
        
        if to.type == "player" and from.type == "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.player-to-player", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        elseif to.type == "player" and from.type ~= "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.model-to-player", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        elseif from.type == "player" and to.type ~= "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.player-to-object", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        end
        
        needValue(from, "items", to)
        needValue(from, "items", from)
        
        needValue(to, "items", to)
        needValue(to, "items", from)
    end
)

function vehBoot(e, val)
    local source = e
    if val then
        source:setDoorOpenRatio(1, 1, 450)
    else
        source:setDoorOpenRatio(1, 0, 450)
    end
end
addEvent("vehBoot", true)
addEventHandler("vehBoot", root, vehBoot)

function addItemToGiveCache(sourceElement, details, type)
    local _sourceElement = sourceElement
    local sourceElement = getEID(_sourceElement)
    local eType = getEType(_sourceElement)
    if not sourceElement then return end

    if not details or tonumber(details[6] or 0) == 1 then -- DutyItem hotfix
        return 
    end

    if not giveCache[eType] then
        giveCache[eType] = {}
    end
    
    if not giveCache[eType][sourceElement] then
        giveCache[eType][sourceElement] = {}
    end
    
    local iType
    if type == "giveItem" then
        iType = GetData(details[1], value, nbt, "invType") --items[details[1]]["invType"]
    elseif type == "transportItem" then
        iType = details[1]
    end
    
    if not giveCache[eType][sourceElement][iType] then
        giveCache[eType][sourceElement][iType] = {}
    end
    
    local tble = details
    tble["type"] = type
    
    local time = getRealTime()["timestamp"]
    local jsontble = toJSON(tble)
    dbExec(connection, "INSERT INTO `items_givecache` SET `ownerid`=?, `ownertype`=?, `data`=?, `iType`=?, `time`=?", sourceElement, eType, jsontble, iType, (time))
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        tble["id"] = id
                        table.insert(giveCache[eType][sourceElement][iType], tble)
                        
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Mivel nincs elég hely az inventorydban ezért várólistára került a neked adni kivánt tárgy!")
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[eType][sourceElement][iType].." tárgy van várólistán")
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `items_givecache` WHERE `ownerid`=? AND `ownertype`=? AND `data`=? AND `iType`=? AND `time`=?", sourceElement, eType, jsontble, iType, (time))
end

function checkItemsInGiveCache(sourceElement, iType)
    local _sourceElement = sourceElement
    local sourceElement = getEID(_sourceElement)
    local eType = getEType(_sourceElement)
    if not sourceElement then return end
    if giveCache[eType] and giveCache[eType][sourceElement] and giveCache[eType][sourceElement][iType] and #giveCache[eType][sourceElement][iType] >= 1 then
        return true
    else
        return false
    end
end

function giveItemsFromGiveCache(sourceElement, iType)
    if checkItemsInGiveCache(sourceElement, iType) then
        local _sourceElement = sourceElement
        local sourceElement = getEID(_sourceElement)
        local eType = getEType(_sourceElement)
        for k,v in pairs(giveCache[eType][sourceElement][iType]) do
            local i = k
            local details = giveCache[eType][sourceElement][iType][i]
            if details then
                local typ = details["type"]
                local dbid = details["id"]
                details["type"] = nil
                details["id"] = nil
                if typ == "giveItem" then
                    local itemid, value, count, status, dutyitem, premium, nbt = unpack(details)

                    if isElementHasSpace(_sourceElement, iType, itemid, value, nbt, count) then
                        dbExec(connection, "DELETE FROM `items_givecache` WHERE `id`=?", dbid)
                        table.remove(giveCache[eType][sourceElement][iType], i)
                        giveItem(_sourceElement, unpack(details))
                        exports['cr_infobox']:addBox(_sourceElement, "info", "Mivel felszabadult egy slot az inventorydban ezért sikerült odaadni a várólistán lévő tárgyat!")
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[eType][sourceElement][iType].." tárgy van várólistán")
                    end
                elseif typ == "transportItem" then -- transport: rework
                    local to = _sourceElement
                    local iType, itemDetails = unpack(details)
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemDetails)
                    
                    if isElementHasSpace(_sourceElement, iType, itemid, value, nbt, count) then
                        dbExec(connection, "DELETE FROM `items_givecache` WHERE `id`=?", dbid)
                        table.remove(giveCache[eType][sourceElement][iType], i)
                        
                        local eType = getEType(to)
                        local eId = getEID(to)
                        local slot = getFreeSlot(to, iType)
                        
                        checkTableArray(eType, eId, iType, slot)
                        
                        if to.type == "player" then
                            if isWeapon(itemid, value, nbt) then
                                triggerClientEvent(to, "attachWeapon", to, to, convertIdToWeapon(itemid, value, nbt), value, itemid)
                            end
                        end

                        cache[eType][eId][iType][slot] = itemDetails
                        local id = itemDetails[1]
                        dbExec(connection, "UPDATE `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `slot`=? WHERE `id`=?", eType, eId, iType, slot, id)
                        
                        needValue(_sourceElement, "items", _sourceElement)
                        
                        exports['cr_infobox']:addBox(_sourceElement, "info", "Mivel felszabadult egy slot az inventorydban ezért sikerült odaadni a várólistán lévő tárgyat!")
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[eType][sourceElement][iType].." tárgy van várólistán")
                    end
                end
            end
        end
    end
    
    return false
end

spamTimers["giveItem"] = {}

function giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
    if not tonumber(itemid) then itemid = 1 end
    if not value then value = 1 end
    if not nbt then nbt = 1 end
    if not tonumber(count) then count = 1 end
    if not tonumber(status) then status = 100 end
    if not tonumber(dutyitem) then dutyitem = 0 end
    if not tonumber(premium) then premium = 0 end
    
    itemid = tonumber(itemid)
    if tonumber(value) then 
        value = tonumber(value) 
    end
    if fromJSON(tostring(value)) then
        value = fromJSON(tostring(value))
    end
    count = tonumber(count)
    status = tonumber(status)
    dutyitem = tonumber(dutyitem)
    premium = tonumber(premium)
    if tonumber(nbt) then 
        nbt = tonumber(nbt) 
    end
    if fromJSON(tostring(nbt)) then
        nbt = fromJSON(tostring(nbt))
    end
    
    if tonumber(value) and value <= 1 or not value then
        if GetData(itemid, value, nbt, "defaultValue") then
            local _value = value 

            value = GetData(itemid, value, nbt, "defaultValue")

            if type(value) == 'function' then 
                value = value(sourceElement, itemid, _value, count, status, dutyitem, premium, nbt)
            end 
        end
    end
    
    if tonumber(nbt) and nbt <= 1 or not nbt then
        if GetData(itemid, value, nbt, "defaultNBT") then
            local _nbt = nbt 

            nbt = GetData(itemid, value, nbt, "defaultNBT")

            if type(nbt) == 'function' then 
                nbt = nbt(sourceElement, itemid, value, count, status, dutyitem, premium, _nbt)
            end 
        end
    end
    
    local iType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
    if not isElementHasSpace(sourceElement, iType, itemid, value, nbt, count) then --nowWeight + addWeight > maxWeight then
        addItemToGiveCache(sourceElement, {itemid, value, count, status, dutyitem, premium, nbt}, "giveItem")
        return
    end
    
    local freeSlot = getFreeSlot(sourceElement, iType)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    checkTableArray(eType, eId, iType, slot)
    cache[eType][eId][iType][freeSlot] = {-1, itemid, value, count, status, dutyitem, premium, nbt}
    
    if tonumber(value) then
        value = tonumber(value)
    elseif toJSON(value) then
        value = toJSON(value)
    end
    
    if tonumber(nbt) then
        nbt = tonumber(nbt)
    elseif toJSON(nbt) then
        nbt = toJSON(nbt)
    end

    -- phone
    if (itemid == 15) then 
        value = exports.cr_phone:createNewPhone() 
    end
    
    dbExec(connection, "INSERT INTO `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `itemid`=?, `slot`=?, `value`=?, `count`=?, `status`=?, `dutyitem`=?, `premium`=?, `nbt`=?", eType, eId, iType, itemid, freeSlot, value, count, status, dutyitem, premium, nbt)
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local eType = tonumber(row["elementtype"])
                        local eId = tonumber(row["elementid"])
                        local iType = tonumber(row["itemtype"])
                        local itemid = tonumber(row["itemid"])    
                        local slot = tonumber(row["slot"])    
                        local value = tostring(row["value"])
                        local status = tonumber(row["status"])
                        local count = tonumber(row["count"])    
                        local dutyitem = tonumber(row["dutyitem"])
                        local premium = tonumber(row["premium"])
                        local nbt = tostring(row["nbt"])
                        
                        checkTableArray(eType, eId, iType, slot)
                        
                        if iType == 10 then
                            cache[eType][eId][iType][slot] = fromJSON(value)
                        else
                            if tonumber(value) then
                                value = tonumber(value)
                            elseif fromJSON(value) then
                                value = fromJSON(value)
                            end
                            
                            if tonumber(nbt) then
                                nbt = tonumber(nbt)
                            elseif fromJSON(nbt) then
                                nbt = fromJSON(nbt)    
                            end

                            if itemid == 15 then 
                                phones[value] = {eId, nbt, iType, slot}
                            end 
                            
                            cache[eType][eId][iType][slot] = {id, itemid, value, count, status, dutyitem, premium, nbt}
                            exports['cr_logs']:addLog(sourceElement, "Inventory", "giveitem", "Item adás: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..")")
                            
                            if sourceElement.type == "player" then
                                if isWeapon(itemid, value, nbt) then
                                    triggerClientEvent(sourceElement, "attachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, value, nbt), value, itemid)
                                end
                            end
                        end
                        
                        needValue(sourceElement, "items", sourceElement)
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `items` WHERE `elementtype`=? AND `elementid`=? AND `itemtype`=? AND `slot`=?", eType, eId, iType, freeSlot)
end

function giveItemCMD(sourceElement, cmd, who, itemid, value, count, status, dutyitem, premium, nbt)
    if exports['cr_permission']:hasPermission(sourceElement, "giveitem") then
        if not itemid or not who then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/giveitem [who] [itemid] [érték] [darab] [státusz] [dutyitem (1 = Igen, 0 = Nem)] [premium (1 = Igen, 0 = Nem)] [nbt]", sourceElement, 255,255,255,true)
            return
        end
        
        local who = exports['cr_core']:findPlayer(sourceElement, who)
        
        if who then
            itemid = tonumber(itemid)
            local id = getElementData(who, "char >> name"):gsub("_", " ")
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen adtál "..green..id..white.."nak/nek egy tárgyat! ("..green..getItemName(itemid, value, nbt)..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." adott "..green..id..white.."nak/nek egy tárgyat! ("..green..getItemName(itemid, value, nbt)..white..")", 3)
            
            exports['cr_logs']:addLog(sourceElement, "Inventory", "giveitemCMD", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " adott "..(tonumber(getElementData(who, "acc >> id")) or inspect(who)).."nak/nek egy tárgyat! ("..getItemName(itemid, value, nbt)..")")
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local text = syntax .. green .. aName .. white .. " adott neked egy tárgyat ("..green..getItemName(itemid, value, nbt)..white..")"
            outputChatBox(text, who, 255,255,255,true)
            giveItem(who, itemid, value, count, status, dutyitem, premium, nbt, true)
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Hibás Név/ID!", sourceElement, 255,255,255,true)
        end
    end
end
addCommandHandler("giveitem", giveItemCMD)

addEvent("giveItem", true)
addEventHandler("giveItem", root,
    function(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
        if client and client.type == "player" then
            giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
        end
    end
)

-- returns all items in a given inv type. If an itemID is given only that itemIDs are collected.
function getItems(element, invType, itemID)
    local eType = getEType(element)
    local eId = getEID(element)
    checkTableArray(eType, eId, invType)

    if (itemID) then
        local items = {};
        for _, v in pairs(cache[eType][eId][invType]) do
            if (v[2] == itemID) then
                table.insert(items, v)
            end
        end

        return items
    else
        return cache[eType][eId][invType]
    end
end

-- retruns all items from all inventory types. If an itemID is given only that itemIDs are collected.
function getAllItems(element, itemID)
    local items = {};
    for i = 1, 4 do
        for _, v in pairs(getItems(element, i, itemID)) do
            table.insert(items, v);
        end
    end 

    return items;
end

function hasItem(element, itemID, itemValue)
    if itemValue then
        for i = 1, 4 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if itemid == itemID and value == itemValue then
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
                if itemid == itemID then
                    return true, slot, data
                end
            end
        end
        
        return false
    end
end

function getCurrentPhoneSlot(element, itemValue)
    if itemValue then 
        local items = getItems(element, 1)
        triggerLatentClientEvent(element, "phone >> checkPhoneSlot", 50000, false, element, element, items, itemValue)
    end
end

spamTimers["deleteItem"] = {}
function deleteItem(sourceElement, slot, itemid, ignoreTrigger, spec)
    local iType = GetData(itemid, value, nbt, "invType") --items[itemid]["invType"]
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    local data = cache[eType][eId][iType][slot]

    if data then 
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        cache[eType][eId][iType][slot] = nil

        if checkItemsInGiveCache(sourceElement, iType) then
            if spec and spec == "removeDutyItems" then 
                local itemsGiveCache = giveCache[eType][eId][iType]

                for k, v in pairs(itemsGiveCache) do 
                    local data = itemsGiveCache[k]
                    
                    if data then 
                        local typ = data["type"]
                        local dbid = data["id"]
                        data["type"] = nil
                        data["id"] = nil

                        if typ == "giveItem" then 
                            local itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                            if dutyitem and dutyitem == 1 then 
                                dbExec(connection, "DELETE FROM `items_givecache` WHERE `id`=?", dbid)
                                table.remove(giveCache[eType][eId][iType], k)
                            end
                        end
                    end
                end
            end

            setTimer(giveItemsFromGiveCache, 1000, 1, sourceElement, iType)
        end
        
        dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
        exports['cr_logs']:addLog(sourceElement, "Inventory", "deleteitem", "Item törlés: "..toJSON(data).." (Slot: "..slot..")")
        
        if sourceElement.type == "player" then
            if itemid == 15 then 
                if phones[value] then 
                    phones[value] = nil 
                    collectgarbage("collect")
                end 
            end 

            for i = 1, 10 do
                if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                    local invType, slot2, id = unpack(cache[eType][eId][10][i])

                    if invType == iType then
                        if slot == slot2 then
                            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                            cache[eType][eId][10][i] = nil
                        end
                    end
                end
            end
            
            if isWeapon(itemid, value, nbt) then
                triggerClientEvent(sourceElement, "deAttachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, value, nbt), itemid)
            end
            
            if not ignoreTrigger then 
                needValue(sourceElement, "items", sourceElement)
            end
        end
    end 
end

addEvent("deleteItem", true)
addEventHandler("deleteItem", root,
    function(sourceElement, slot, itemid, ignoreTrigger, spec)
        if client and client.type == "player" then
            deleteItem(sourceElement, slot, itemid, ignoreTrigger, spec)
        end
    end
)

local compileDetails = {
    ["id"] = {"id", 1},
    ["itemid"] = {"itemid", 2},
    ["value"] = {"value", 3},
    ["count"] = {"count", 4},
    ["status"] = {"status", 5},
    ["dutyitem"] = {"dutyitem", 6},
    ["premium"] = {"premium", 7},
    ["nbt"] = {"nbt", 8},
}

function updateItemDetails(sourceElement, slot, iType, details, needTrigger)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    local name, number = unpack(compileDetails[details[1]])
    local newValue = details[2]
    local data = cache[eType][eId][iType][slot]

    if data then
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        if number == 3 then 
            if itemid == 15 then 
                if phones[value] then 
                    phones[value] = nil 
                    collectgarbage("collect")
                end 

                phones[newValue] = {eId, nbt, eType, slot}
            end 
        elseif number == 8 then 
            if itemid == 15 then 
                if phones[value] then 
                    changePhoneData(value, "nbt", newValue)
                end 
            end 
        end 

        cache[eType][eId][iType][slot][number] = newValue
        if number == 3 or number == 8 then
            if tonumber(newValue) then
                newValue = tonumber(newValue)
            elseif toJSON(newValue) then
                newValue = toJSON(newValue)
            end
        end
        table.insert(execTable, {"UPDATE `items` SET `"..name.."`=? WHERE `id`=?", {newValue, id}})
    end
    
    if needTrigger then
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("updateItemDetails", true)
addEventHandler("updateItemDetails", root,
    function(sourceElement, slot, iType, details, needTrigger)
        if client and client.type == "player" then
            updateItemDetails(sourceElement, slot, iType, details, needTrigger)
        end
    end
)

function hasPhone(val) 
    if phones[val] then 
        if phones[val][3] == 1 then 
            return phones[val]
        end 
    end 

    return false 
end 

function changePhoneData(number, dataName, data)
    number = tonumber(number)

    if phones[number] then
        local pos = 0
        if dataName == "eId" then 
            pos = 1
        elseif dataName == "nbt" then 
            pos = 2
        elseif dataName == "invType" then 
            pos = 3
        elseif dataName == "slot" then 
            pos = 4
        end

        phones[number][pos] = data 

        return phones[number]
    end

    return false
end

function onQuit()
    local items = getItems(source, 1)

    for k, v in pairs(items) do 
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

        if itemid == 317 then 
            deleteItem(source, k, itemid, true)
        end
    end
end
addEventHandler("onPlayerQuit", root, onQuit)