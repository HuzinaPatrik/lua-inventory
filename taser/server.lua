addEvent("killPedByTaser", true)
addEventHandler("killPedByTaser", root,
    function(sourceElement, attacker, weapon, bodypart)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                --outputCh
                killPed(sourceElement, attacker, weapon, bodypart)
            end
        end
    end
)

addEvent("hpDmgByTaser", true)
addEventHandler("hpDmgByTaser", root,
    function(sourceElement, loss)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                --outputChatBox(loss)
                setElementHealth(sourceElement, loss)
            end
        end
    end
)

function startTazedEffectAttacker(player, attacker)
    if isElement(player) and isElement(attacker) then 
        triggerClientEvent(attacker, "startTazedEffectAttacker", attacker, player)
    end 
end 
addEvent("startTazedEffectAttacker", true)
addEventHandler("startTazedEffectAttacker", root, startTazedEffectAttacker)

function startBeanbagEffectAttacker(player, attacker)
    if isElement(player) and isElement(attacker) then 
        triggerClientEvent(attacker, "startBeanbagEffectAttacker", attacker, player)
    end 
end 
addEvent("startBeanbagEffectAttacker", true)
addEventHandler("startBeanbagEffectAttacker", root, startBeanbagEffectAttacker)