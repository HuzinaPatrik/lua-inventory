local fCache = {}
local white = "#ffffff"

local function createBlip(sourceElement, targetElement)
    if client and client == sourceElement then
        local name = exports['cr_admin']:getAdminName(sourceElement, false)
        --triggerClientEvent(targetElement, "createStayBlip", targetElement, name, x, y, 1, "cel", 32,32,255,255,255)

        local syntax = exports['cr_core']:getServerSyntax("Checkpoint", "info")
        local green = exports['cr_core']:getServerColor(nil, true)
        outputChatBox(syntax .. "Egy fémkapu beriasztott ("..green..getZoneName(getElementPosition(sourceElement))..white..") ("..green..name..white..")", targetElement, 255,255,255,true)

        setTimer(endBlip, 1 * 60 * 1000, 1, targetElement)
        fCache[targetElement] = sourceElement
    end
end
addEvent("createBlip", true)
addEventHandler("createBlip", root, createBlip)

function endBlip(targetElement)
    if fCache[targetElement] then
        local sourceElement = fCache[targetElement]
        local name = exports['cr_admin']:getAdminName(sourceElement, false)
        local syntax = exports['cr_core']:getServerSyntax("Checkpoint", "error")
        local green = exports['cr_core']:getServerColor(nil, true)
        outputChatBox(syntax .. "A jel megszakadt... ("..green..name..white..")", targetElement, 255,255,255,true)

        --triggerClientEvent(targetElement, "destroyStayBlip", targetElement, name)
        fCache[targetElement] = nil
    end
end

addEventHandler("onPlayerQuit", root,
    function()
        endBlip(source)
    end
)