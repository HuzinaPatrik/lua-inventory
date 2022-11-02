startAnimation = "InOutQuad"
startAnimationTime = 250 -- / 1000 = 0.2 másodperc

_destroyElement = destroyElement
function destroyElement(e)
    if isElement(e) then
        _destroyElement(e)
    end
end

local client = true
addEventHandler("onResourceStart", resourceRoot,
    function()
        client = false
    end
)

t, a = "assets/images", ".png"

function GetData(itemid, itemValue, nbt, data)
    if items[itemid] then
        if tonumber(nbt) and tonumber(nbt) > 1 then
            if items[itemid]["nbtData"] then
                if items[itemid]["nbtData"][tonumber(nbt)] then
                    if items[itemid]["nbtData"][tonumber(nbt)][data] ~= nil then 
                        return items[itemid]["nbtData"][tonumber(nbt)][data]
                    end
                end
            end
        end

        if tonumber(itemValue) and tonumber(itemValue) > 1 then
            if items[itemid]["valueData"] then
                if items[itemid]["valueData"][tonumber(itemValue)] then
                    if items[itemid]["valueData"][tonumber(itemValue)][data]  ~= nil then 
                        return items[itemid]["valueData"][tonumber(itemValue)][data]
                    end
                end
            end
        end
    
        if items[itemid][data] then
            return items[itemid][data]
        end
    end
    
    return false
end

items = {
    {
        ["name"] = "Hot-dog",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["disabledStatusInteract"] = false, -- true (10 percenként nem fog fogyni a state*je)
        ["food"] = true,
        ["BiteAdd"] = 8, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 5, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 1
    
	{
        ["name"] = "Hamburger",
        ["invType"] = 1,
        ["weight"] = 0.75,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["food"] = true,
        ["BiteAdd"] = 11, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 4, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 2
    
	{
        ["name"] = "Taco",
        ["invType"] = 1,
        ["weight"] = 0.65,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["food"] = true,
        ["BiteAdd"] = 12, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 5, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 3
    
	{
        ["name"] = "Burger",
        ["invType"] = 1,
        ["weight"] = 0.35,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["food"] = true,
        ["BiteAdd"] = 8, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 4, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 4
    
	{
        ["name"] = "Fánk",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["food"] = true,
        ["BiteAdd"] = 4, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 3, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 5
    
	{
        ["name"] = "Süti",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["food"] = true,
        ["BiteAdd"] = 5, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 3, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 6
    
	{
        ["name"] = "Üdítőital",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["drink"] = true,
        ["BiteAdd"] = 4, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 3, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 7
    
	{
        ["name"] = "Víz",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["drink"] = true,
        ["BiteAdd"] = 12, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 4, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 8
    
	{
        ["name"] = "Sör",
        ["invType"] = 1,
        ["weight"] = 0.35,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["drink"] = true,
        ["isDrunkDrink"] = true,
        ["drunkIndexAdd"] = 0.2,
        ["BiteAdd"] = 4, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 5, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 9
    
	{
        ["name"] = "Vodka",
        ["invType"] = 1,
        ["weight"] = 0.7,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["drink"] = true,
        ["isDrunkDrink"] = true,
        ["drunkIndexAdd"] = 0.4,
        ["BiteAdd"] = 6, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 4, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 10
    
	{
        ["name"] = "Whiskey",
        ["invType"] = 1,
        ["weight"] = 0.7,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["drink"] = true,
        ["isDrunkDrink"] = true,
        ["drunkIndexAdd"] = 0.5,
        ["BiteAdd"] = 6, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 5, -- Hány harapás 1 kaja
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 11

	{
        ["name"] = "Heroin por",
        ["invType"] = 1,
        ["weight"] = 0.01,
        ["canStack"] = true,
        ["maxStack"] = 50,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 12

	{
        ["name"] = "Kokain",
        ["invType"] = 1,
        ["weight"] = 0.01,
        ["canStack"] = true,
        ["maxStack"] = 50,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 13

	{
        ["name"] = "Füves cigi",
        ["invType"] = 1,
        ["weight"] = 0.015,
        ["canStack"] = true,
        ["maxStack"] = 20,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 14

	{
        ["name"] = "Iphone X",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["disableWeightTextTooltip"] = true, 
        ["defaultNBT"] = {
            ["myCallNumber"] = false,
            ["service"] = "",
            ["wallet"] = 0,
            ["wallpaper"] = 1,
            ["lockscreen"] = 1,
            ["ringtone"] = 1,
            ["ringtoneVolume"] = 1,
            ["normalads"] = true,
            ["darkwebads"] = true,
            ["messages"] = {},
            ["contacts"] = {},
            ["gallery"] = {},
            ["showMyNumber"] = true,
            ["calendar"] = {},
            ["clock"] = {["alarm"] = {}, ["timer"] = {}},
            ["simHistory"] = {},
            ["callHistory"] = {},
        },
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 15

	{
        ["name"] = "Jármű kulcs",
        ["invType"] = 3,
        ["weight"] = 0.05,
        ["canMove"] = true,
        ["isKey"] = true,
        ["keyType"] = "vehicle",
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 16
 
	{
        ["name"] = "Lakás kulcs",
        ["invType"] = 3,
        ["weight"] = 0.05,
        ["canMove"] = true,
        ["isKey"] = true,
        ["keyType"] = "house",
		["canStack"] = true,
        ["maxStack"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 17

	{
        ["name"] = "Biznisz kulcs",
        ["invType"] = 3,
        ["weight"] = 0.05,
        ["canMove"] = true,
        ["isKey"] = true,
        ["keyType"] = "busines",
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 18

	{
        ["name"] = "Rádió",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 19

	{
        ["name"] = "Kapu távirányító",
        ["invType"] = 3,
        ["weight"] = 0.07,
        ["isKey"] = true,
        ["keyType"] = "gate",
        ["canMove"] = true,
		["canStack"] = true,
        ["maxStack"] = 0,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 20

	{
        ["name"] = "Kocka",
        ["invType"] = 1,
        ["weight"] = 0.001,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 21

    {
        ["name"] = "HI-FI",
        ["invType"] = 1,
        ["weight"] = 2.5,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 22

	{
        ["name"] = "Vitamin",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 20,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 23

	{
        ["name"] = "Gyógyszer",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 20,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 24

	{
        ["name"] = "Fegyverviselési engedély",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Fegyverviselési engedély",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local data = {
                name = exports.cr_admin:getAdminName(player),
                gender = player:getData("char >> details").neme or 1,
                endDate = getRealTime().timestamp + (1 * 31 * 24 * 60 * 60)
            }

            return data 
        end,
    }, -- 25

	{
        ["name"] = "Üres adásvételi",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 26

	{
        ["name"] = "Útlevél",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 27
    
    {
        ["name"] = "Horgász engedély",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local data = {
                ['name'] = exports['cr_admin']:getAdminName(player),
                ['gender'] = player:getData('char >> details')['neme'] or 1,
                ['startDate'] = getRealTime()['timestamp'],
                ['endDate'] = getRealTime()['timestamp'] + (1 * 31 * 24 * 60 * 60),
                ['skinID'] = player.model,
            }

            return data 
        end,
    }, -- 28

	{
        ["name"] = "Széf kulcs",
        ["invType"] = 3,
        ["weight"] = 0.06,
        ["isKey"] = true,
        ["keyType"] = "safe",
        ["canMove"] = true,
		["canStack"] = true,
        ["maxStack"] = 0,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 29

	{
        ["name"] = "Gáz maszk",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 30

    {
        ["name"] = "Flashbang",
        ["invType"] = 4,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 31
    
    {
        ["name"] = "Füstgránát",
        ["invType"] = 4,
        ["weight"] = 0.1,
        ["isWeapon"] = true,
        ["canMove"] = true,
        ["weaponID"] = 17,
        ["ammoID"] = -3,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 32

    {   
        ["name"] = "Faltörő kos",
        ["invType"] = 1,
        ["weight"] = 1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 33

    {
        ["name"] = "Bilincs",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 34
    
    {
        ["name"] = "Bilincs kulcs",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 35
    
    {
        ["name"] = "Jelvény",
        ["invType"] = 2,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 36

    {
        ["name"] = "Villogó",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 37
    
    {
        ["name"] = "Boxer",
        ["invType"] = 4,
        ["weight"] = 0.6,
        ["isWeapon"] = true,
        ["weaponID"] = 1,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 38

    {
        ["name"] = "Golf ütő",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isWeapon"] = true,
        ["weaponID"] = 2,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 39
    
    {
        ["name"] = "Gumibot",
        ["invType"] = 4,
        ["weight"] = 0.5,
        ["isWeapon"] = true,
        ["weaponID"] = 3,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["attachWeapon"] = true,
        ["modelID"] = 334,
        ["defAttachData"] = {13, -0.035, -0.1, 0.3, 0, 0, 90},
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 40

    {
        ["name"] = "Kés",
        ["invType"] = 4,
        ["weight"] = 1,
        ["weaponID"] = 4,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 335,
        ["defAttachData"] = {14, 0.1, -0.1, 0.1, 0, 0, 90},
        ["textureName"] = "powerframe",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Knife",
                ["description"] = "Gold Knife",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/41-2.png",
                ["textureName"] = "kabar",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },

            [3] = {
                ["hasPJ"] = true,
                ["name"] = "Future Knife",
                ["description"] = "Future Knife",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/41-3.png",
                ["textureName"] = "kabar",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 41

    {
        ["name"] = "Baseball Ütő",
        ["invType"] = 4,
        ["weight"] = 2,
        ["weaponID"] = 5,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 336,
        ["defAttachData"] = {6, -0.09, -0.1, 0.1, 10, 260, 95},
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 42

    {
        ["name"] = "Ásó",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isWeapon"] = true,
        ["weaponID"] = 6,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 43
    
    {
        ["name"] = "Katana",
        ["invType"] = 4,
        ["weight"] = 3.5,
        ["weaponID"] = 8,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 339,
        ["defAttachData"] = {6, -0.15, 0, -0.02, -10, -105, 90},
        ["textureName"] = "1",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Katana",
                ["description"] = "Gold katana",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/44-2.png",
                ["textureName"] = "map",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 44
    
    {
        ["name"] = "Balta",
        ["invType"] = 1,
        ["weight"] = 3,
        ["isWeapon"] = true,
        ["weaponID"] = 10,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 45

    {
        ["name"] = "Virág",
        ["invType"] = 1,
        ["weight"] = 0.4,
        ["isWeapon"] = true,
        ["weaponID"] = 14,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 46
    
    {
        ["name"] = "Sétabot",
        ["invType"] = 1,
        ["weight"] = 1,
        ["isWeapon"] = true,
        ["weaponID"] = 15,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 47

    {
        ["name"] = "Molotov koktél",
        ["invType"] = 4,
        ["weight"] = 0.65,
        ["isWeapon"] = true,
        ["weaponID"] = 18,
        ["ammoID"] = -3,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 48
    
    {
        ["name"] = "Glock 18",
        ["invType"] = 4,
        ["weight"] = 1.6,
        ["isStatus"] = true,
        ["weaponID"] = 22,
        ["ammoID"] = 66,            
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 346,
        ["defAttachData"] = {13, -0.05, 0.05, 0, 0, -90, 90},
        ["textureName"] = "glock17_body",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Glock 18",
                ["description"] = "Gold Glock",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/49-2.png",
                ["textureName"] = "1",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			[3] = {
                ["hasPJ"] = true,
                ["name"] = "Snowy Glock 18",
                ["description"] = "Snowy Glock",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/49-3.png",
                ["textureName"] = "1",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			[4] = {
                ["hasPJ"] = true,
                ["name"] = "Hotline Glock 18",
                ["description"] = "Hotline Glock",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/49-4.png",
                ["textureName"] = "1",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 49
    
    {
        ["name"] = "Hangtompítós Colt-45",
        ["invType"] = 4,
        ["weight"] = 2,
        ["isStatus"] = true,
        ["weaponID"] = 23,
        ["ammoID"] = 66,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 347,
        ["defAttachData"] = {13, -0.05, 0.05, 0, 0, -90, 90},
        ["textureName"] = "usp_texture_0",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Silenced",
                ["description"] = "Gold Silenced",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/50-2.png",
                ["textureName"] = "1911",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[3] = {
                ["hasPJ"] = true,
                ["name"] = "Snowy Silenced",
                ["description"] = "Snowy Silenced",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/50-3.png",
                ["textureName"] = "1911",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 50
    
    {
        ["name"] = "Desert Eagle",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isStatus"] = true,
        ["weaponID"] = 24,
        ["ammoID"] = 66,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 17426,
        ["defAttachData"] = {13, -0.05, 0.05, 0, 0, -90, 90},
        ["textureName"] = "deserte",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Desert Eagle",
                ["description"] = "Gold Deagle",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/51-2.png",
                ["textureName"] = "deagle",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
            [3] = {
                ["hasPJ"] = true,
                ["name"] = "Hello Desert Eagle",
                ["description"] = "Hello Deagle",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/51-3.png",
                ["textureName"] = "deagle",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			[4] = {
                ["hasPJ"] = true,
                ["name"] = "Rust Desert Eagle",
                ["description"] = "Rust Deagle",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/51-4.png",
                ["textureName"] = "deagle",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			[5] = {
                ["hasPJ"] = true,
                ["name"] = "Disco Tech Desert Eagle",
                ["description"] = "Disco Tech Deagle",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/51-5.png",
                ["textureName"] = "deagle",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 51
    
    {
        ["name"] = "Sörétes puska",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isStatus"] = true,
        ["weaponID"] = 25,
        ["ammoID"] = 69,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 7572,
        ["defAttachData"] = {5, 0.10, -0.1, 0.2, 0, 155, 90},
        ["textureName"] = "rec_rec",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
		["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Sörétes puska",
                ["description"] = "Gold Sörétes puska",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/52-2.png",
                ["textureName"] = "m870t",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 52

    {
        ["name"] = "Rövid csövű sörétes puska",
        ["invType"] = 4,
        ["weight"] = 4.6,
        ["isStatus"] = true,
        ["weaponID"] = 26,
        ["ammoID"] = 69,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 350,
        ["defAttachData"] = {14, 0.12, 0.05, 0, 0, -90, 90},
        ["textureName"] = "map",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
		["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Sawed-off",
                ["description"] = "Gold Sawed-off",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/53-2.png",
                ["textureName"] = "sawedoff",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			[3] = {
                ["hasPJ"] = true,
                ["name"] = "Snowy Sawed-off",
                ["description"] = "Snowy Sawed-off",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/53-3.png",
                ["textureName"] = "sawedoff",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 53
    
    {
        ["name"] = "SPAZ-12 taktikai sörétes puska",
        ["invType"] = 4,
        ["weight"] = 5.6,
        ["isStatus"] = true,
        ["weaponID"] = 27,
        ["ammoID"] = 69,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 351,
        ["defAttachData"] = {6, -0.09, 0.02, 0.2, 10, 155, 95},
        ["textureName"] = "sp12",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 54
    
    {
        ["name"] = "Uzi",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isStatus"] = true,
        ["weaponID"] = 28,
        ["ammoID"] = 67,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 352,
        ["defAttachData"] = {14, 0.1, 0.05, 0, 0, -90, 90},
        ["textureName"] = "9MM_C",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
		["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Uzi",
                ["description"] = "Gold Uzi",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/55-2.png",
                ["textureName"] = "9MM_C",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 55
    
    {
        ["name"] = "MP5",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isStatus"] = true,
        ["weaponID"] = 29,
        ["ammoID"] = 67,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 353,
        ["defAttachData"] = {13, -0.07, 0.04, 0.06, 0, -90, 95},
        ["textureName"] = "gun_mp5_LONG2",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
		["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold MP5",
                ["description"] = "Gold MP5",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/56-2.png",
                ["textureName"] = "mp5lng",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 56

    {
        ["name"] = "AK-47",
        ["invType"] = 4,
        ["weight"] = 5,
        ["isStatus"] = true,
        ["weaponID"] = 30,
        ["ammoID"] = 71,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 355,
        ["defAttachData"] = {6, -0.08, -0.1, 0.2, 10, 155, 95},
        ["textureName"] = "ak",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        
        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold AK-47",
                ["description"] = "Gold AK-47",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/57-2.png",
                ["textureName"] = "ak",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },

            [3] = {
                ["hasPJ"] = true,
                ["name"] = "Silver AK-47",
                ["description"] = "Silver AK-47",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/57-3.png",
                ["textureName"] = "ak",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[4] = {
                ["hasPJ"] = true,
                ["name"] = "Snowy AK-47",
                ["description"] = "Snowy AK-47",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/57-4.png",
                ["textureName"] = "ak",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 57
    
    {
        ["name"] = "M4",
        ["invType"] = 4,
        ["weight"] = 5,
        ["isStatus"] = true,
        ["weaponID"] = 31,
        ["ammoID"] = 68,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 356,
        ["defAttachData"] = {5, 0.10, -0.1, 0.2, -10, 155, 90},
        ["textureName"] = "1stpersonassualtcarbine",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold M4",
                ["description"] = "Gold M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-2.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[3] = {
                ["hasPJ"] = true,
                ["name"] = "Snowy M4",
                ["description"] = "Snowy M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-3.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[4] = {
                ["hasPJ"] = true,
                ["name"] = "Vanquish M4",
                ["description"] = "Vanquish M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-4.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[5] = {
                ["hasPJ"] = true,
                ["name"] = "Hotline M4",
                ["description"] = "Hotline M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-5.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[6] = {
                ["hasPJ"] = true,
                ["name"] = "Bronze M4",
                ["description"] = "Bronze M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-6.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
			
			[7] = {
                ["hasPJ"] = true,
                ["name"] = "Hello M4",
                ["description"] = "Hello M4",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/58-7.png",
                ["textureName"] = "1stpersonassualtcarbine",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 58
    
    {
        ["name"] = "TEC-9",
        ["invType"] = 4,
        ["weight"] = 3,
        ["isStatus"] = true,
        ["weaponID"] = 32,
        ["ammoID"] = 67,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 372,
        ["defAttachData"] = {14, 0.12, 0.05, 0, 0, -90, 90},
        ["textureName"] = "gun",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
		["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Tec-9",
                ["description"] = "Gold Tec-9",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/59-2.png",
                ["textureName"] = "bm_uzi_micro1",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 59
    
    {
        ["name"] = "Vadász puska",
        ["invType"] = 4,
        ["weight"] = 5,
        ["isStatus"] = true,
        ["weaponID"] = 33,
        ["ammoID"] = 70,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 357,
        ["defAttachData"] = {6, -0.09, -0.1, 0.2, 10, 155, 95},
        ["textureName"] = "wood",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 60

    {
        ["name"] = "Mesterlövész",
        ["invType"] = 4,
        ["weight"] = 6,
        ["isStatus"] = true,
        ["weaponID"] = 34,
        ["ammoID"] = 70,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 358,
        ["defAttachData"] = {5, 0.10, -0.1, 0.2, -10, 155, 90},
        ["textureName"] = "Main_Body",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
		
        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Gold Sniper",
                ["description"] = "Gold Sniper",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/weaponstickers/61-2.png",
                ["textureName"] = "tekstura",
                
                --[[
                ["textureName"] = {
                    ["ak"] = "path", -- mindkettő különféle pathot kaphat
                    ["ak2"] = "path", -- mindkettő különféle pathot kaphat vagy ha random nem létező fájl srcét adod meg akkor az alap texet teszi rá amit a customTexturePath vagy a def generált szöveg alapján határozz meg
                },]]
            },
        },
    }, -- 61
    
    {
        ["name"] = "Spray",
        ["invType"] = 1,
        ["weight"] = 1,
        ["weaponID"] = 41,
        ["isWeapon"] = true,
        ["ammoID"] = 102,
        ["ignoreIdentity"] = true,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 62
    
    {
        ["name"] = "Poroltó",
        ["invType"] = 1,
        ["weight"] = 5,
        ["weaponID"] = 42,
        ["isWeapon"] = true,
        ["ammoID"] = 103,
        ["ignoreIdentity"] = true,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 63
        
    {
        ["name"] = "Kamera",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["isWeapon"] = true,
        ["weaponID"] = 43,
        ["isWeapon"] = true,
        ["ammoID"] = 104,
        ["ignoreIdentity"] = true,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 64
        
    {
        ["name"] = "Ejtőernyő",
        ["invType"] = 1,
        ["weight"] = 3,
        ["weaponID"] = 46,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 65
        
    {
        ["name"] = "5x9mm-es töltény",
        ["invType"] = 4,
        ["weight"] = 0.002,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 66
        
    {
        ["name"] = "Kis gépfegyver töltények",
        ["invType"] = 4,
        ["weight"] = 0.0025,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 67
        
    {
        ["name"] = "M4 töltény",
        ["invType"] = 4,
        ["weight"] = 0.003,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 68
        
    {
        ["name"] = "Sörétes töltény",
        ["invType"] = 4,
        ["weight"] = 0.003,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 69
        
    {
        ["name"] = "Vadászpuska töltény",
        ["invType"] = 4,
        ["weight"] = 0.004,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 70
        
    {
        ["name"] = "AK-47 töltény",
        ["invType"] = 4,
        ["weight"] = 0.003,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["isAmmo"] = true,
    }, -- 71
        
    {
        ["name"] = "Széf",
        ["invType"] = 1,
        ["weight"] = 3.5,
        ["canMove"] = true,
        ["description"] = "Páncélszekrény",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 72
         
    {
        ["name"] = "Elsősegély doboz",
        ["invType"] = 1,
        ["weight"] = 1,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 73
        
    {
        ["name"] = "Öngyújtó",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 74
        
    {
        ["name"] = "Taxi tábla",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 75
        
    {
        ["name"] = "Pilóta engedély",
        ["invType"] = 2,
        ["weight"] = 0.01,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 76
        
    {
        ["name"] = "Vezetői engedély",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player, _, category)
            local data = {
                ['name'] = exports['cr_admin']:getAdminName(player),
                ['gender'] = player:getData('char >> details')['neme'] or 1,
                ['startDate'] = getRealTime()['timestamp'],
                ['endDate'] = getRealTime()['timestamp'] + (1 * 31 * 24 * 60 * 60),
                ['skinID'] = player.model,
                ['category'] = category or 'A',
            }

            return data 
        end,
    }, -- 77
    
    {
        ["name"] = "Személyi igazolvány",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local data = {
                ['name'] = exports['cr_admin']:getAdminName(player),
                ['gender'] = player:getData('char >> details')['neme'] or 1,
                ['startDate'] = getRealTime()['timestamp'],
                ['endDate'] = getRealTime()['timestamp'] + (1 * 31 * 24 * 60 * 60),
                ['skinID'] = player.model,
            }

            return data 
        end,
    }, -- 78
        
    {
        ["name"] = "Forgalmi engedély",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 79
        
    {
        ["name"] = "Adásvételi szerződés",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 80
        
    {
        ["name"] = "Toll",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 81
        
    {
        ["name"] = "Vadász engedély",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Vadász engedély",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local data = {
                name = exports.cr_admin:getAdminName(player),
                gender = player:getData("char >> details").neme or 1,
                endDate = getRealTime().timestamp + (1 * 31 * 24 * 60 * 60)
            }

            return data 
        end,
    }, -- 82
        
    {
        ["name"] = "Cigaretta",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 83
        
    {
        ["name"] = "Távvezérlő jármű kulcs",
        ["invType"] = 3,
        ["weight"] = 0.05,
        ["isKey"] = true,
        ["keyType"] = "vehicleremote",
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 84
        
    {
        ["name"] = "Horgászbot",
        ["invType"] = 1,
        ["weight"] = 1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 85
        
    {
        ["name"] = "Bakancs",
        ["invType"] = 1,
        ["weight"] = 0.4,
        ["canStack"] = true,
        ["maxStack"] = 5,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 5,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 86
        
    {
        ["name"] = "Döglött hal",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canStack"] = true,
        ["maxStack"] = 15,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 10,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 87
        
    {
        ["name"] = "Konzervdoboz",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 5,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 88
        
    {
        ["name"] = "Cápa",
        ["invType"] = 1,
        ["weight"] = 1.5,
        ["canStack"] = true,
        ["maxStack"] = 5,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 500,
        ["isStatus"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 89
        
    {
        ["name"] = "Hínár",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canStack"] = true,
        ["maxStack"] = 15,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 5,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 90
         
    {
        ["name"] = "Tonhal",
        ["invType"] = 1,
        ["weight"] = 2,
        ["canStack"] = true,
        ["maxStack"] = 5,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 600,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 91
        
    {
        ["name"] = "Polip",
        ["invType"] = 1,
        ["weight"] = 2,
        ["canStack"] = true,
        ["maxStack"] = 4,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 225,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 92
        
    {
        ["name"] = "Ördöghal",
        ["invType"] = 1,
        ["weight"] = 1,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 200,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 93
        
    {
        ["name"] = "Kardhal",
        ["invType"] = 1,
        ["weight"] = 2,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 250,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 94
        
    {
        ["name"] = "Szamuráj rák",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 550,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 95
        
    {
        ["name"] = "Csillag",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 15,
        ["isStatus"] = true,
        ["canMove"] = true,
        ["fishItem"] = true,
        ["fishItemPrice"] = 150,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 96
        
    {
        ["name"] = "Bankkártya",
        ["invType"] = 2,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 97
        
    {
        ["name"] = "SIM kártya",
        ["invType"] = 2,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 98
        
    {
        ["name"] = "Csákány",
        ["invType"] = 1,
        ["weight"] = 3,
        ["isWeapon"] = true,
        ["weaponID"] = 11,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 99
	
    {
        ["name"] = "Kutya snack",
        ["invType"] = 1,
        ["weight"] = 0.35,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["invType"] = 1,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 100

    {
        ["name"] = "Kutya víz",
        ["invType"] = 1,
        ["weight"] = 0.35,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["invType"] = 1,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["isStatus"] = true,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 101
    
    {
        ["name"] = "Spray patron",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 102
        
    {
        ["name"] = "Poroltó patron",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canStack"] = true,
        ["maxStack"] = 1000,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 103
        
    {
        ["name"] = "Kamera tekercs",
        ["invType"] = 1,
        ["weight"] = 0.0005,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 104
        
    {
        ["name"] = "Kötszer",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canMove"] = true,
        ["description"] = "Ez egy kötszer leírása",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 105
        
    {
        ["name"] = "Róka Trófea",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 250,
        ["description"] = "Ez egy róka trófea",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 106
        
    {
        ["name"] = "Róka Bőr",
        ["invType"] = 1,
        ["weight"] = 2,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 250,
        ["description"] = "Ez egy róka bőr",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 107
        
    {
        ["name"] = "UV Lámpa",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 108
        
    {
        ["name"] = "PP Snack",
        ["invType"] = 1,
        ["weight"] = 1,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 109
    
    {
        ["name"] = "Kő",
        ["invType"] = 1,
        ["weight"] = 0.03,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 110
        
    {
        ["name"] = "Alumínium",
        ["invType"] = 1,
        ["weight"] = 0.05,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 111
        
    {
        ["name"] = "Homokkő",
        ["invType"] = 1,
        ["weight"] = 0.07,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 112
        
    {
        ["name"] = "Szén",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 113
    
    {
        ["name"] = "Vas",
        ["invType"] = 1,
        ["weight"] = 0.15,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 114
        
    {
        ["name"] = "Titán",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 115
        
    {
        ["name"] = "Ólom",
        ["invType"] = 1,
        ["weight"] = 0.22,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 116
        
    {
        ["name"] = "Vörösréz",
        ["invType"] = 1,
        ["weight"] = 0.3,
        ["canStack"] = true,
        ["maxStack"] = 25,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 117
	
    {
        ["name"] = "Fa",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 118
        
    {
        ["name"] = "Kén",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 119
        
    {
        ["name"] = "Salétrom",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 120
        
    {
        ["name"] = "Gumi",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 121
        
    {
        ["name"] = "Acél",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 122
        
    {
        ["name"] = "Kalapács",
        ["invType"] = 1,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 123
        
    {
        ["name"] = "Papir",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 124
        
    {
        ["name"] = "Sav",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 125
        
    {
        ["name"] = "Drón",
        ["invType"] = 1,
        ["weight"] = 2,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 126
        
    {
        ["name"] = "Sokkoló",
        ["invType"] = 4,
        ["weight"] = 1.5,
        ["isStatus"] = true,
        ["weaponID"] = 24,
        ["ammoID"] = -4,
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 10012,
        ["defAttachData"] = {14, 0.10, 0, 0, 0, 264, 90},
        ["textureName"] = "taser",
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 127
	
    {
        ["name"] = "Csekk",
        ["invType"] = 2,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 128
        
    {
        ["name"] = "Célzólézer",
        ["invType"] = 1,
        ["weight"] = 0.85,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 129
        
    {
        ["name"] = "Esettáska",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 130
        
    {
        ["name"] = "Ismeretlen lőszermaradvány",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 131
         
    {
        ["name"] = "Lőszermaradvány",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 132
        
    {
        ["name"] = "Övelvágó kés",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 133
        
    {
        ["name"] = "Megafon",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 134
    
    {
        ["name"] = "Kötél",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 135
        
    {
        ["name"] = "Szemfedő",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 136
    
    {
        ["name"] = "Hockey Maszk",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["mask"] = true,
        ["modelID"] = 6907,
        ["defOffsets"] = {0,0,0,0,0,0},
        ["defaultNBT"] = {["name"] = "Ismeretlen", ["scale"] = 1, ["offsets"] = {0,0,0,0,0,0}},
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        
        ["valueData"] = {
            [2] = {
                ["hasPJ"] = true,
                ["name"] = "Színes hockey maszk",
                ["description"] = "Ez egy paintjobos hockey maszk",
                ["customIconPath"] = true,
                ["customTexturePath"] = ":cr_inventory/assets/maskstickers/137/2.png",
                ["textureName"] = "MaskV_Cyb3rMotion",
            },
        },
    }, -- 137
    
    {
        ["name"] = "Zorro Maszk",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["mask"] = true,
        ["modelID"] = 16197,
        ["defOffsets"] = {0,0,0,0,0,0},
        ["defaultNBT"] = {["name"] = "Ismeretlen", ["scale"] = 1, ["offsets"] = {0,0,0,0,0,0}},
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 138
    
    {
        ["name"] = "Heal Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["disableDrop"] = true,
    }, -- 139
    
    {
        ["name"] = "Fix Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 140
        
    {
        ["name"] = "Unflip Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 141
        
    {
        ["name"] = "Prés",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 142
    
    {
        ["name"] = "Üzemanyag Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 143

    {
        ["name"] = "Flex",
        ["invType"] = 1,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["canMove"] = true,
        ["description"] = "Flex",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 144

    {
        ["name"] = "Csavarhúzó",
        ["invType"] = 1,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["canMove"] = true,
        ["description"] = "Csavarhúzó",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 145

    {
        ["name"] = "Véső",
        ["invType"] = 1,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["canMove"] = true,
        ["description"] = "Véső",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 146

    {
        ["name"] = "Duct Tape",
        ["invType"] = 1,
        ["weight"] = 0,
        ["disableWeightTextTooltip"] = true,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Duct Tape",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 147

    {
        ["name"] = "Egészségügyi kártya",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local data = {
                name = exports.cr_admin:getAdminName(player),
                gender = player:getData('char >> details').neme or 1,
                startDate = getRealTime().timestamp,
                endDate = getRealTime().timestamp + (1 * 31 * 24 * 60 * 60),
                skinID = player.model,
            }

            return data 
        end,
    }, -- 148

    {
        ["name"] = "Önkormányzati azonosító",
        ["invType"] = 2,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Önkormányzati azonosító",
        ["objectID"] = {3013, 0, 0, 0.13},

        ["defaultValue"] = function(player)
            local factionId = 4
            local playerRank = exports.cr_dashboard:getPlayerFactionRankName(player, factionId) or "Ismeretlen"
            local randomSerial = math.random(100000, 999999)

            local data = {
                name = exports.cr_admin:getAdminName(player),
                rank = playerRank,
                serial = randomSerial
            }

            return data 
        end,
    }, -- 149

    {
        ["name"] = "Golyóálló mellény",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Rendőrség által használt mellény.",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 150

    {
        ["name"] = "Csekkfüzet",
        ["invType"] = 2,
        ["weight"] = 0.05,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Csekkfüzet",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 151

    {
        ["name"] = "Horgászbot (Csali nélkül)",
        ["invType"] = 1,
        ["weight"] = 0.9,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 152

    {
        ["name"] = "Csali",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
		["canStack"] = true,
        ["maxStack"] = 10,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 153

    {
        ["name"] = "Damil",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
		["canStack"] = true,
        ["maxStack"] = 10,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 154

    {
        ["name"] = "Jármű Slot Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 155

    {
        ["name"] = "Interior Slot Kártya",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 156

    {
        ["name"] = "Bárd",
        ["invType"] = 1,
        ["weight"] = 0.4,
        ["isWeapon"] = true,
        ["weaponID"] = 12,
        ["ammoID"] = -1,
        ["canMove"] = true,
        ["description"] = "Ez egy bárd!",
        ["objectID"] = {323, 0, 0, 0.13},
    }, -- 157

    {
        ["name"] = "Raktárfejlesztés (Interior)",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canStack"] = true,
        ["maxStack"] = 10,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 158
    
    {
        ["name"] = "Pénzeszsák",
        ["invType"] = 1,
        ["weight"] = 0.05,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Pénz van benne.",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 159

    {
        ["name"] = "Colt-45 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 69,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 160

    {
        ["name"] = "Hangtompítós Colt-45 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 70,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 161

    {
        ["name"] = "Desert Eagle mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 71,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 162

    {
        ["name"] = "Sörétes mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 72,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 163

    {
        ["name"] = "Lefűrészelt csövű sörétes mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 73,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 164

    {
        ["name"] = "Taktikai sörétes mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 74,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 165

    {
        ["name"] = "UZI & Tec-9 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 75,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 166

    {
        ["name"] = "MP5 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 76,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 167

    {
        ["name"] = "AK-47 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 77,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 168

    {
        ["name"] = "M4 mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 78,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 169

    {
        ["name"] = "Vadász & Mesterlövész mesterkönyv",
        ["invType"] = 1,
        ["weight"] = 0.2,
        ["canMove"] = true,
        ["description"] = "Ez egy mesterkönyv",
        ["isMasterBook"] = true, 
        ["statID"] = 79,
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 170
	
	{
        ["name"] = "Beanbag Shotgun",
        ["invType"] = 4,
        ["weight"] = 2,
        ["isStatus"] = true,
        ["weaponID"] = 25,
        ["ammoID"] = -4, -- -4
        ["canMove"] = true,
        ["isWeapon"] = true,
        ["attachWeapon"] = true,
        ["modelID"] = 8082,
        ["defAttachData"] = {5, 0.10, -0.1, 0.2, 0, 155, 90},
        ["textureName"] = "wood",
        ["description"] = "Beanbag Shotgun",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 171

    {
        ["name"] = "Blueprint: Kés",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Kés tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 172

    {
        ["name"] = "Blueprint: Glock-18",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Glock-18 tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 173

    {
        ["name"] = "Blueprint: Hangtompítós Colt-45",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Hangtompítós Colt-45 tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 174

    {
        ["name"] = "Blueprint: Desert Eagle",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Desert Eagle tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 175

    {
        ["name"] = "Blueprint: Sörétes Puska",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Sörétes Puska tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 176

    {
        ["name"] = "Blueprint: Uzi",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Az Uzi tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 177

    {
        ["name"] = "Blueprint: AK-47",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Az AK-47 tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 178

    {
        ["name"] = "Blueprint: TEC-9",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A TEC-9 tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 179

    {
        ["name"] = "Blueprint: Vadász puska",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "A Vadász Puska tervrajza",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 180

    {
        ["name"] = "Cserepes növény: Marihuana",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canMove"] = true,
        ["description"] = "Cserepes növény: Marihuana",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["defaultValue"] = "3259",
    }, -- 181

    {
        ["name"] = "Cserepes növény: Kokain",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canMove"] = true,
        ["description"] = "Cserepes növény: Kokain",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["defaultValue"] = "3277",
    }, -- 182

    {
        ["name"] = "Cserepes növény: Mák",
        ["invType"] = 1,
        ["weight"] = 0.5,
        ["canMove"] = true,
        ["description"] = "Cserepes növény: Mák",
        ["objectID"] = {3013, 0, 0, 0.13},
        ["defaultValue"] = "3267",
    }, -- 183

    {
        ["name"] = "Bibe",
        ["invType"] = 1,
        ["weight"] = 0.005,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Bibe",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 184

    {
        ["name"] = "Kokalevél",
        ["invType"] = 1,
        ["weight"] = 0.005,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Kokalevél",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 185

    {
        ["name"] = "Mákszalma",
        ["invType"] = 1,
        ["weight"] = 0.005,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Mákszalma",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 186

    {
        ["name"] = "Elszáradt növény",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Elszáradt növény",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 187

    {
        ["name"] = "Vizes kanna",
        ["invType"] = 1,
        ["weight"] = 0.15,
        ["canMove"] = true,
        ["description"] = "Vizes kanna",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 188

    {
        ["name"] = "Föld",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Egy zsák föld",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 189

    {
        ["name"] = "Cserép",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Cserép",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 190

    {
        ["name"] = "Szárított marihuana",
        ["invType"] = 1,
        ["weight"] = 0.005,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Szárított marihuana",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 191

	{
        ["name"] = "Bot",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["maxStack"] = 100,
		["canStack"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 192
	
	{
        ["name"] = "Orsó",
        ["invType"] = 1,
        ["weight"] = 0.1,
        ["canMove"] = true,
        ["maxStack"] = 100,
		["canStack"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 193
	
	{
        ["name"] = "Zárfésű",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 194
	
	{
        ["name"] = "Cigaretta papír",
        ["invType"] = 1,
        ["weight"] = 0.0015,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 195
	
	{
        ["name"] = "Mák mag",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 196
	
	{
        ["name"] = "Kokain mag",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 197
	
	{
        ["name"] = "Marihuana mag",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canMove"] = true,
        ["maxStack"] = 100,
        ["canStack"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 198
	
	{
        ["name"] = "Heroinos fecskendő",
        ["invType"] = 1,
        ["weight"] = 0.01,
        ["canStack"] = true,
        ["maxStack"] = 50,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 199
	
	{
        ["name"] = "Fecskendő",
        ["invType"] = 1,
        ["weight"] = 0.0005,
        ["canStack"] = true,
        ["maxStack"] = 50,
		["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 200
	
	{
        ["name"] = "Kanál",
        ["invType"] = 1,
        ["weight"] = 0.0005,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 201
	
	{
        ["name"] = "Penge",
        ["invType"] = 1,
        ["weight"] = 0.0001,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 202
	
	{
        ["name"] = "Szódabikarbóna",
        ["invType"] = 1,
        ["weight"] = 0.0001,
		["canStack"] = true,
        ["maxStack"] = 50,
        ["canMove"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 203
	
	{
        ["name"] = "Mosómedve trófea",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 400,
        ["description"] = "Ez egy mosómedve trófea",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 204
	
	{
        ["name"] = "Mosómedve bőr",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 350,
        ["description"] = "Ez egy mosómedve bőr",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 205
	
	{
        ["name"] = "Medve trófea",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 550,
        ["description"] = "Ez egy medve trófea",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 206

	{
        ["name"] = "Medve bőr",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 500,
        ["description"] = "Ez egy medve bőr",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 207

    {
        ["name"] = "Szarvas trófea",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 450,
        ["description"] = "Ez egy szarvas trófea",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 208

    {
        ["name"] = "Szarvas bőr",
        ["invType"] = 1,
        ["weight"] = 5,
        ["canMove"] = true,
        ["hunterItem"] = true,
        ["hunterItemPrice"] = 420,
        ["description"] = "Ez egy szarvas bőr",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 209

    {
        ["name"] = "Invalid item",
        ["invType"] = 1,
        ["weight"] = 0,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = true,
        ["description"] = "Ez egy alap leírás",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 210


	{
        ["name"] = "Barna kanapé",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1702, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 25000,
        ["furnitureObjID"] = 1702,
    }, -- 211
	
    {
        ["name"] = "Fekete bőrszék",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1714, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1714,
    }, -- 212

    {
        ["name"] = "Könyvespolc",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1742, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1742,
    }, -- 213

    {
        ["name"] = "Fekete hosszú fotel",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1723, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1723,
    }, -- 214

    {
        ["name"] = "Fekete rövid fotel",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1724, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1724,
    }, -- 215

    {
        ["name"] = "Modern polc",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1730, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1730,
    }, -- 216

    {
        ["name"] = "Szürke franciágy",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1725, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1725,
    }, -- 217

    {
        ["name"] = "Barna fa szék",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1739, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1739,
    }, -- 218

    {
        ["name"] = "Barna éjjeli szekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1740, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1740,
    }, -- 219

    {
        ["name"] = "Barna komód",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1741, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1741,
    }, -- 220

    {
        ["name"] = "Fekete TV",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1752, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1752,
    }, -- 221

    {
        ["name"] = "Barna TV",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1751, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1751,
    }, -- 222

    {
        ["name"] = "Modern Fekete TV",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1792, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1792,
    }, -- 223

    {
        ["name"] = "Kicsi foltos kanapé",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1751, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1751,
    }, -- 224

    {
        ["name"] = "Hosszú foltos kanapé",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1760, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1760,
    }, -- 225

    {
        ["name"] = "Felmosó",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1778, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1778,
    }, -- 226

    {
        ["name"] = "Modern Franciaágy",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1799, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1799,
    }, -- 227

    {
        ["name"] = "Átlagos Franciaágy",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1794, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1794,
    }, -- 228

    {
        ["name"] = "Számítógépes szék",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1806, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1806,
    }, -- 229

    {
        ["name"] = "Konyhai szék",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1811, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1811,
    }, -- 230

    {
        ["name"] = "Barna fa asztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1814, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1814,
    }, -- 231

    {
        ["name"] = "Bár szék",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1805, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1805,
    }, -- 232

    {
        ["name"] = "Fa üvegasztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1817, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1817,
    }, -- 233

    {
        ["name"] = "Fa kávéasztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1819, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1819,
    }, -- 234

    {
        ["name"] = "Fa kávéasztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1819, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1819,
    }, -- 235

    {
        ["name"] = "Fekete kávéasztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1822, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1822,
    }, -- 236

    {
        ["name"] = "Nagy üvegasztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1827, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1827,
    }, -- 237

    {
        ["name"] = "Mélyhűtő",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1990, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1990,
    }, -- 238

    {
        ["name"] = "Márvány asztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2030, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2030,
    }, -- 239

    {
        ["name"] = "Irattartó",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2067, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2067,
    }, -- 240

    {
        ["name"] = "Nagy állványozott lámpa",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2069, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2069,
    }, -- 241

    {
        ["name"] = "Szerteágazó lámpa",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2071, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2071,
    }, -- 242

    {
        ["name"] = "Csillár",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2076, 0, 0, -0.25},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2076,
    }, -- 243

    {
        ["name"] = "Barna konyha bútor szett #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2013, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2013,
    }, -- 244

    {
        ["name"] = "Barna konyha bútor szett #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2014, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2014,
    }, -- 245

    {
        ["name"] = "Barna konyha bútor szett #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2015, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2015,
    }, -- 246

    {
        ["name"] = "Barna konyha bútor szett #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2016, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2016,
    }, -- 247

    {
        ["name"] = "Barna konyha bútor szett #5",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2017, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2017,
    }, -- 248

    {
        ["name"] = "Barna konyha bútor szett #6",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2018, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2018,
    }, -- 249

    {
        ["name"] = "Barna konyha bútor szett #7",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2019, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2019,
    }, -- 250

    {
        ["name"] = "Barna konyha bútor szett #8",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2022, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2022,
    }, -- 251

    {
        ["name"] = "Fiókos szekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2021, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2021,
    }, -- 252

    {
        ["name"] = "Fekete álló lámpa",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2023, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2023,
    }, -- 253

    {
        ["name"] = "Barna fegyverszekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2046, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2046,
    }, -- 254

    {
        ["name"] = "Barna álló lámpa",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2069, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2069,
    }, -- 255

    {
        ["name"] = "Fekete Vitrin",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2078, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2078,
    }, -- 256

    {
        ["name"] = "HI-FI szekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2100, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2100,
    }, -- 257

    {
        ["name"] = "Nagy HI-FI szekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2100, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2100,
    }, -- 258

    {
        ["name"] = "Éjjeli lámpa",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2106, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2106,
    }, -- 259

    {
        ["name"] = "Piros konyha bútor szett #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2127, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2127,
    }, -- 260

    {
        ["name"] = "Piros konyha bútor szett #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2128, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2128,
    }, -- 261

    {
        ["name"] = "Piros konyha bútor szett #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2129, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2129,
    }, -- 262

    {
        ["name"] = "Piros konyha bútor szett #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2130, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2130,
    }, -- 263

    {
        ["name"] = "Piros konyha bútor szett #5",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2125, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2125,
    }, -- 264

    {
        ["name"] = "Mikró",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2149, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2149,
    }, -- 265

    {
        ["name"] = "Modern fehér hűtő",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2153, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2153,
    }, -- 266

    {
        ["name"] = "Fa könyvespolc",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2161, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2161,
    }, -- 267

    {
        ["name"] = "Számítógép asztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2169, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2169,
    }, -- 268

    {
        ["name"] = "Irodai asztal #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2171, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2171,
    }, -- 269

    {
        ["name"] = "Irodai asztal #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2173, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2173,
    }, -- 270

    {
        ["name"] = "Irodai asztal #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2205, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2205,
    }, -- 271

    {
        ["name"] = "Fénymásoló",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2186, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2186,
    }, -- 272

    {
        ["name"] = "Festmény #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2280, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2280,
    }, -- 273

    {
        ["name"] = "Festmény #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2281, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2281,
    }, -- 274

    {
        ["name"] = "Festmény #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2282, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2282,
    }, -- 275

    {
        ["name"] = "Festmény #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2283, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2283,
    }, -- 276

    {
        ["name"] = "Festmény #5",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2284, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2284,
    }, -- 277

    {
        ["name"] = "Festmény #6",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2285, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2285,
    }, -- 278

    {
        ["name"] = "Festmény #7",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2286, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2286,
    }, -- 279

    {
        ["name"] = "Festmény #8",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2287, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2287,
    }, -- 280

    {
        ["name"] = "WC",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2514, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2514,
    }, -- 281

    {
        ["name"] = "Fürdőkád",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2519, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2519,
    }, -- 282

    {
        ["name"] = "Súlyemelő",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2629, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2629,
    }, -- 283

    {
        ["name"] = "Futógép",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2630, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2630,
    }, -- 284

    {
        ["name"] = "Sztriptíz rúd",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {3503, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 3503,
    }, -- 285

    {
        ["name"] = "Virág #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2245, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2245,
    }, -- 286

    {
        ["name"] = "Virág #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2241, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2241,
    }, -- 287

    {
        ["name"] = "Virág #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2811, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2811,
    }, -- 288

    {
        ["name"] = "Virág #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {949, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 949,
    }, -- 289

    {
        ["name"] = "Virág #5",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1361, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1361,
    }, -- 290

    {
        ["name"] = "Virág #6",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2001, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2001,
    }, -- 291

    {
        ["name"] = "Virág #7",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2195, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2195,
    }, -- 292
	
	{
        ["name"] = "Bevásárlókosár",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1885, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1885,
    }, -- 293
	
	{
        ["name"] = "Hardcore VHS polc",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2582, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2582,
    }, -- 294
	
	{
        ["name"] = "Kétoldalú bolti hűtőszekrény #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1891, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1891,
    }, -- 295
	
	{
        ["name"] = "Kétoldalú bolti hűtőszekrény #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1884, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1884,
    }, -- 296
	
	{
        ["name"] = "Kétoldalú bolti hűtőszekrény #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1889, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1889,
    }, -- 297
	
	{
        ["name"] = "Bolti hűtőszekrény #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1847, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1847,
    }, -- 298
	
	{
        ["name"] = "Bolti hűtőszekrény #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1843, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1843,
    }, -- 299
	
	{
        ["name"] = "Bolti hűtőszekrény #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1844, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1844,
    }, -- 300
	
	{
        ["name"] = "Bolti hűtőszekrény #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1888, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1888,
    }, -- 301
	
	{
        ["name"] = "Bolti lapos hűtőszekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1883, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1883,
    }, -- 302
	
	{
        ["name"] = "Bolti ruhásszekrény #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2375, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2375,
    }, -- 303
	
	{
        ["name"] = "Bolti ruhásszekrény #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2387, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2387,
    }, -- 304
	
	{
        ["name"] = "Bolti ruhásszekrény #3",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2391, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2391,
    }, -- 305
	
	{
        ["name"] = "Bolti ruhásszekrény #4",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2396, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2396,
    }, -- 306
	
	{
        ["name"] = "Bolti játékautó",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2480, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2480,
    }, -- 307
	
	{
        ["name"] = "Bolti üres polc #1",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1850, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1850,
    }, -- 308
	
	{
        ["name"] = "Bolti üres polc #2",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1845, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1845,
    }, -- 309
	
	{
        ["name"] = "Bolti kellékek - Pénztárgép",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1514, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1514,
    }, -- 310
	
	{
        ["name"] = "Bolti kellékek - italautómata",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1775, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1775,
    }, -- 311
	
	{
        ["name"] = "Bolti kellékek - italhűtőszekrény",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2452, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2452,
    }, -- 312
	
	{
        ["name"] = "Bolti kellékek - cipősdoboz",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2694, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2694,
    }, -- 313
	
	{
        ["name"] = "Bolti kellékek - kis ital autómata",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {2427, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 2427,
    }, -- 314
	
	{
        ["name"] = "Bolti kellékek - pénztárgép asztal",
        ["invType"] = 1,
        ["weight"] = 0.25,
        ["canMove"] = true,
        ["description"] = "Ez egy bútor",
        ["objectID"] = {1984, 0, 0, 0.13},
        ["isFurniture"] = true,
        ["furnitureItemPrice"] = 250,
        ["furnitureObjID"] = 1984,
    }, -- 315
	
	{
        ["name"] = "Cini Minis",
        ["invType"] = 1,
        ["weight"] = 0.045,
        ["canMove"] = true,
        ["description"] = "Cini Minis",
		["disabledStatusInteract"] = false,
        ["food"] = true,
        ["BiteAdd"] = 100, -- Mennyit tölt 1 harapás
        ["BiteMax"] = 1, -- Hány harapás 1 kaja
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 316
	
	{
        ["name"] = "Pénzkazetta",
        ["invType"] = 1,
        ["weight"] = 1.5,
        ["canMove"] = true,
        ["disableWeightTextTooltip"] = false,
        ["description"] = "ATMben tárolt pénzt tartalmazó kazetta",
        ["objectID"] = {3013, 0, 0, 0.13},
    }, -- 317
	
	
}

function getAllItems()
	return items
end

local furnitures = {}
local allFurnitures = {}

for k,v in pairs(items) do 
    if v["isFurniture"] then 
        furnitures[v["furnitureObjID"]] = k

        table.insert(allFurnitures, {
            objectId = v.furnitureObjID,
            price = v.furnitureItemPrice,
            itemId = k
        })
    end 
end 

function getFurnitureItemIDByObjectID(objectID)
    return furnitures[objectID]
end 

function getAllFurniture()
    return allFurnitures
end

function getItemWeight(itemid, itemValue, nbt)
    return GetData(itemid, itemValue, nbt, "weight")
end

craftG = {
    --[[
	{"CRAFT TYPE", false,
        {
            {{RemoveItem(-1(no) or 0(yes)), id, itemid, value, count, status, dutyitem (0-1), premium (0-1), nbt (table or false)}, CraftingTime, {NeedFaction false or {FactionID}, NeedLocation {{x,y,z,dim,int}}, NeedBlueprint ["ak47"] = true}, 
                {
					[CraftingBoxID] = {RemoveItem(-1(no) or 0(yes)), id, itemid, value, count, status, dutyitem (0-1), premium (0-1), nbt (table or false)},
                },
            },
        },
    },
    ]]
    {"Hobbi", false,
		{
			{{0, 152, 1, 1, 100, 0, 0, false}, 15, {false, false, false},
                {
					[12] = {0, 154, 1, 0, 0, 0, 0, 0},
					[13] = {0, 192, 1, 0, 0, 0, 0, 0},
					[14] = {0, 193, 1, 0, 0, 0, 0, 0},
                },
            },
			
			{{0, 85, 1, 1, 100, 0, 0, false}, 15, {false, false, false},
                {
					[8] = {0, 153, 1, 0, 0, 0, 0, 0},
					[13] = {0, 152, 1, 0, 0, 0, 0, 0},
                },
            },
		},
    },
	{"Drogok", false,
        {
            {{0, 181, 1, 1, 100, 0, 0, false}, 30, {{7,9,10}, false, false}, 
                {
                    [8] = {0, 198, 1, 0, 0, 0, 0, 0},
                    [13] = {0, 189, 1, 0, 0, 0, 0, 0},
                    [18] = {0, 190, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 182, 1, 1, 100, 0, 0, false}, 30, {{7,9,10}, false, false}, 
                {
                    [8] = {0, 197, 1, 0, 0, 0, 0, 0},
                    [13] = {0, 189, 1, 0, 0, 0, 0, 0},
                    [18] = {0, 190, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 183, 1, 1, 100, 0, 0, false}, 30, {{7,9,10}, false, false}, 
                {
                    [8] = {0, 196, 1, 0, 0, 0, 0, 0},
                    [13] = {0, 189, 1, 0, 0, 0, 0, 0},
                    [18] = {0, 190, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 191, 1, 1, 100, 0, 0, false}, 15, {{7,9,10}, {{2556.12109375, -1293.2468261719, 1044.125, 2, 44}}, false}, 
                {
                    [8] = {-1, 108, 1, 0, 0, 0, 0, 0},
					[13] = {0, 184, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 14, 1, 1, 100, 0, 0, false}, 30, {{7,9,10}, false, false}, 
                {
					[8] = {0, 191, 1, 0, 0, 0, 0, 0},
					[13] = {0, 195, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 199, 1, 1, 100, 0, 0, false}, 50, {{7,9,10}, {{2556.12109375, -1293.2468261719, 1044.125, 2, 44}}, false}, 
                {
                    [7] = {0, 200, 1, 0, 0, 0, 0, 0},
					[8] = {0, 186, 1, 0, 0, 0, 0, 0},
                    [13] = {-1, 201, 1, 0, 0, 0, 0, 0},
                    [18] = {-1, 74, 1, 0, 0, 0, 0, 0},
                },
            },

            {{0, 13, 1, 1, 100, 0, 0, false}, 60, {{7,9,10}, {{2556.12109375, -1293.2468261719, 1044.125, 2, 44}}, false}, 
                {
                    [7] = {-1, 202, 1, 0, 0, 0, 0, 0},
                    [8] = {0, 203, 1, 0, 0, 0, 0, 0},
                    [12] = {0, 185, 1, 0, 0, 0, 0, 0},
                    [13] = {-1, 201, 1, 0, 0, 0, 0, 0},
                    [18] = {-1, 74, 1, 0, 0, 0, 0, 0},
                },
            },
        },
    },
	--[[{"Fegyverek", false,
        {
            {{2, 1, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
            {{2, 2, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
        },
    },]]
}

function getItemName(itemid, itemValue, nbt)
    if not items[itemid] or not items[itemid]["name"] then
        return "Ismeretlen tárgy"
    else
        return GetData(itemid, itemValue, nbt, "name"), items[itemid]
    end
end

local keyTable = {}
for k,v in pairs(items) do
    if v["isKey"] then
        keyTable[k] = v["keyType"]
    end
end

function isKey(itemid, itemValue, nbt)
    return GetData(itemid, itemValue, nbt, "isKey")
end

function convertKey(t)
    local table = {}
    for k,v in pairs(keyTable) do 
        table[v] = k 
    end
    
    if table[t] then
        return table[t]
    end
    return false
end

function isWeapon(itemid, itemValue, nbt)
    return GetData(itemid, itemValue, nbt, "isWeapon")
end

function convertIdToWeapon(itemid, itemValue, nbt)
    if isWeapon(itemid, itemValue, nbt) then
        if itemid == 127 then -- Sokkoló
            return -1
        end
        
        return GetData(itemid, itemValue, nbt, "weaponID")
    end
    return false
end

local gTex = {}
local gTexGrey = {}

if type(triggerServerEvent) == "function" then
    noPicture = dxCreateTexture("assets/items/0.png", "argb", true, "clamp")

    function getItemPNG(itemid, value, nbt, status)
        local customIconPath = GetData(itemid, value, nbt, "customIconPath")
        if customIconPath then
            if type(customIconPath) == "string" then
                local tex = gTex[itemid .. "-" ..value]
                if tex then
                    return tex
                else
                    if fileExists(customIconPath) then
                        tex = dxCreateTexture(customIconPath, "argb", true, "clamp")
                    end
                    if not tex then
                        if fileExists("assets/items/"..itemid..".png") then
                            tex = dxCreateTexture("assets/items/"..itemid..".png", "argb", true, "clamp")
                        end
                        if not tex then
                            tex = noPicture
                        end
                    end
                    gTex[itemid .. "-" ..value] = tex 

                    return tex
                end
            else
                local tex = gTex[itemid .. "-" ..value]
                if tex then
                    return tex
                else
                    if fileExists("assets/items/"..itemid.."/"..value..".png") then
                        tex = dxCreateTexture("assets/items/"..itemid.."/"..value..".png", "argb", true, "clamp")
                    end
                    if not tex then
                        if fileExists("assets/items/"..itemid..".png") then
                            tex = dxCreateTexture("assets/items/"..itemid..".png", "argb", true, "clamp")
                        end
                        if not tex then
                            tex = noPicture
                        end
                    end
                    gTex[itemid .. "-" ..value] = tex

                    return tex
                end
            end
        end
        
        
        local tex = gTex[itemid]
        if tex then
            return tex
        else
            if fileExists("assets/items/"..itemid..".png") then
                tex = dxCreateTexture("assets/items/"..itemid..".png", "argb", true, "clamp")
            end
            if not tex then
                tex = noPicture
            end

            gTex[itemid] = tex
            return tex
        end
    end

    function getItemGreyPNG(itemid, value, nbt, status, alpha)
        local tex = gTexGrey[itemid]
        if tex then
            dxSetShaderValue(tex, "alpha", (alpha / 255));

            return tex
        else
            tex = dxCreateShader("assets/shaders/blackwhite.fx")
            dxSetShaderValue(tex, "screenSource", getItemPNG(itemid, value, nbt, status))
            dxSetShaderValue(tex, "alpha", (alpha / 255));

            gTexGrey[itemid] = tex

            return tex 
        end 
    end 
end

function getItemDescription(itemid, value, nbt)
    return GetData(itemid, value, nbt, "description")
end

typeDetails = {
    --[typeID] = {imgSource, name, maxSuly},
    [1] = {"Hátizsák", 10},
    [2] = {"Iratok", 2},
    [3] = {"Kulcsok", 3},
    [4] = {"Fegyverek", 15},
    [5] = {"Craft", 0},
    [6] = {"Csomagtartó", 70},
    [7] = {"Széf", 100},
    [8] = {"Műszerfal", 3},
    [9] = {"Kuka", 5},
    [10] = {"Actionbar", 0},
}

overheatIncreaseValues = {
	[22] = 4, --glock
	[23] = 4, -- silenced
	[24] = 5, --dezi
	[25] = 8, --shoti
	[26] = 7, --sawed-off
	[27] = 8, --spaz
	[28] = 0.8, --uzi
	[29] = 1.5, -- MP5
	[32] = 0.8, --TEC9
	[30] = 2, -- AK
	[31] = 1.5, --M4
	[33] = 20, --Vadászpuska
	[34] = 25, --sniper
}

overheatDecreaseValues = {
	[22] = 0.003, --glock
	[23] = 0.003,--silenced
	[24] = 0.0025, --dezi
	[25] = 0.0025, --shoti
	[26] = 0.002, --sawed-off
	[27] = 0.002, --spaz
	[28] = 0.004, --uzi
	[29] = 0.006, --MP5
	[32] = 0.0045, --tec9
	[30] = 0.008, --ak47
	[31] = 0.0075, --m4
	[33] = 0.005, --vadász
	[34] = 0.0055, --sniper
}

specTypes = {
    ["vehicle"] = 6,
    ["object"] = 7,
    ["vehicle.in"] = 8,
    ["trash"] = 9,
}

function getWeaponAmmoItemID(itemid, value, nbt)
    return GetData(itemid, value, nbt, "ammoID")
end

function getMaxWeight(type)
	type = tonumber(type)
	if(not type) then
		type = 1
	end
	return typeDetails[type][2]
end

if type(triggerServerEvent) == "function" then
    _dxDrawImage = dxDrawImage

    function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
        if type(img) == "string" then
            if not img:find(':cr_') then 
                img = ':cr_inventory/' .. img
            end

            return exports['cr_dx']:dxDrawImageAsTexture(x,y,w,h,img, r, rx, ry, color, postgui);
        else 
            return _dxDrawImage(x,y,w,h,img,r,rx,ry,color,postgui);
        end
    end
end

iconPositions = {
    {75, 10, "backpack", 1, 16, 20},
    {75 + 16 + 10, 10, "file", 2, 27, 20},
    {75 + 16 + 10 + 27 + 10, 10, "keys", 3, 20, 20},
    {75 + 16 + 10 + 27 + 10 + 20 + 10, 10, "weapons", 4, 20, 20},
    {75 + 16 + 10 + 27 + 10 + 20 + 10 + 20 + 10, 10, "craft", 5, 20, 20},
}

drawnSize = {
    ["bg"] = {465, 280},
    ["icons"] = {600, 600},
    ["vehicons"] = {600, 600},
    ["weight"] = {600, 600},
    ["ac.left/right"] = {14, 80},
    ["bg_cube"] = {40,40},
    ["bg_cube_img"] = {38, 38},
    ["left/right"] = {14, 80}, -- 72 Y
}

realSize = {
    ["bg"] = {465, 280},
    ["icons"] = drawnSize["bg"],
    ["vehicons"] = drawnSize["bg"],
    ["weight"] = drawnSize["weight"],
    ["ac.left/right"] = drawnSize["ac.left/right"],
    ["bg_cube"] = drawnSize["bg_cube"],
    ["bg_cube_img"] = drawnSize["bg_cube_img"],
    ["left/right"] = drawnSize["left/right"],
}

cache = {}
--Tábla felépítése: cache[elementtype][elementid][itemtype][slot] = {id, itemid, value, count, status, dutyitem}

function getEType(e)
    if e.type == "player" then
        return 1
    elseif e.type == "object" then
        return 2
    elseif e.type == "vehicle" then
        return 3
    elseif e.type == "ped" then
        return 4
    else
        return 5
    end
end

function getEID(e)
    if e.type == "player" then
        return getElementData(e, "acc >> id") or -1
    elseif e.type == "object" then
        return getElementData(e, "safe.id") or -1
    elseif e.type == "vehicle" then
        return getElementData(e, "veh >> id") or -1
    elseif e.type == "ped" then
        return getElementData(e, "ped >> id") or -1
    else
        return 5
    end
end

function getWeight(e, i)
    local elementID = getEID(e)
    local elementType = getEType(e)
    checkTableArray(elementType, elementID, i)

    local weight = 0
    local data = cache[elementType][elementID][i]
    for slot = 1, maxLines * maxColumn do
        if data and data[slot] then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data[slot])
            if not count then
                count = 1
            end
            
            if items[itemid] then
                local nw = getItemWeight(itemid, value, nbt)
                nw = nw * count
                weight = weight + nw
            end
        end
    end

    return weight
end

function getFreeSlot(e, invType)
    --outputChatBox(tostring(invType))
    local elementID = getEID(e)
    local elementType = getEType(e)
    checkTableArray(elementType, elementID, invType)
    local data = cache[elementType][elementID][invType]
    
    if not data then
        return 1
    end
    for slot = 1, maxLines * maxColumn do
        if not data[slot] then
            return slot
        end
    end
    
    return false
end

function isElementHasSpace(e, iType, itemid, value, nbt, count, ignoreSlot)
    if not iType then
        iType = GetData(itemid, value, nbt, "invType") 
    end
    local nowWeight = getWeight(e, iType)
    local addWeight = getItemWeight(itemid, value, nbt) * count
    local maxWeight = typeDetails[iType][2]
    local freeSlot = getFreeSlot(e, iType)
    if ignoreSlot then freeSlot = true end

    if nowWeight + addWeight <= maxWeight and freeSlot then
        return true
    end
    
    return false
end

maxLines = 5
maxColumn = 10
breakColumn = 10
between = 5

function checkTableArray(eType, eId, invType, slot)
    if eType then
        if not cache[eType] then
            cache[eType] = {}
        end
    end
    
    if eId then
        if not cache[eType][eId] then
            cache[eType][eId] = {}
        end
    end
    
    if invType then
        if not cache[eType][eId][invType] then
            cache[eType][eId][invType] = {}
        end
    end
    
    if slot then
        if not cache[eType][eId][invType][slot] then
            cache[eType][eId][invType][slot] = {}
        end
    end
end

function isTableArray(eType, eId, invType, slot)
    if eType or eId or invType or slot then
        if not cache[eType] then
            return false
        end
    end
    
    if eId or invType or slot then
        if not cache[eType][eId] then
            return false
        end
    end
    
    if invType or slot then
        if not cache[eType][eId][invType] then
            return false
        end
    end
    
    if slot then
        if not cache[eType][eId][invType][slot] then
            return false
        end
    end
    
    return true
end

function isStackable(itemid, value, nbt)
    return GetData(itemid, value, nbt, "canStack")
end

function getItemType(itemid, value, nbt)
    return GetData(itemid, value, nbt, "invType")
end

function getServerSyntax(...)
    return exports['cr_core']:getServerSyntax(...)
end

function getServerColor(...)
    return exports['cr_core']:getServerColor(...)
end

ignoreWeaponInteractions = {
    [1] = true, 
    [3] = true, 
    [4] = true, 
    [22] = true, 
    [23] = true, 
    [24] = true, 
    [28] = true, 
    [32] = true, 
    [16] = true, 
    [17] = true, 
    [18] = true, 
    [41] = true, 
    [43] = true, 
    [14] = true, 
    [46] = true,
}