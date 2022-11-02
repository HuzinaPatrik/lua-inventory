function itemShowTrigger(sourceElement, v, data)
    triggerClientEvent(v, "itemShowTrigger", sourceElement, sourceElement, v, data)
end
addEvent("itemShowTrigger", true)
addEventHandler("itemShowTrigger", root, itemShowTrigger)