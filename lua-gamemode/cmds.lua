local weapons = {}
weapons["baseballbat"] = 1
weapons["poolcue"] = 2
weapons["knife"] = 3
weapons["grenade"] = 4
weapons["molotov"] = 5
weapons["pistol"] = 7
weapons["deagle"] = 9
weapons["deserteagle"] = 9
weapons["shotgun"] = 10
weapons["baretta"] = 11
weapons["microuzi"] = 12
weapons["uzi"] = 12
weapons["mp5"] = 13
weapons["ak47"] = 14
weapons["m4"] = 15
weapons["sniper"] = 16
weapons["m40a1"] = 17
weapons["rpg"] = 18
weapons["rocketlauncher"] = 18

-- Returns a weather name by weather id.
local function getWeatherName(id)
    if id == 0 then return "Extra sunny"
    elseif id == 1 then return "Sunny"
    elseif id == 2 then return "Sunny and windy"
    elseif id == 3 then return "Cloudy"
    elseif id == 4 then return "Raining"
    elseif id == 5 then return "Drizzle"
    elseif id == 6 then return "Foggy"
    elseif id == 7 then return "Thunderstorm"
    elseif id == 8 then return "Extra sunny 2"
    elseif id == 9 then return "Sunny and windy 2"
    else return "Unknown"
    end
end

-- Creates a vehicle by model name.
local function createVehicle(modelname)
    local model = Game.GetHashKey(tostring(modelname))

    -- Check if model exist in cd image.
    if not Game.IsModelInCdimage(model) then
        Chat.AddMessage("Error: Unknown model")
        return
    end

    -- If player is currently the driver of a car, delete it.
    if Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId())) then
        local currentCar = Game.GetCarCharIsUsing(Game.GetPlayerChar(Game.GetPlayerId()))

        if Game.GetDriverOfCar(currentCar) == Game.GetPlayerChar(Game.GetPlayerId()) then
            Game.DeleteCar(currentCar)
        end
    end

    Thread.Create(function()
        local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
        local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))

        Game.RequestModel(model)

        while not Game.HasModelLoaded(model) do
            Thread.Pause(0)
        end

        local car = Game.CreateCar(model, x, y, z, true)
        Game.SetCarHeading(car, heading)
        Game.SetCarOnGroundProperly(car)

        Game.SetVehicleDirtLevel(car, 0.0)
        Game.WashVehicleTextures(car, 255)

        local colour = math.random(0, 132)
        Game.ChangeCarColour(car, colour, colour)

        Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car)

        Game.MarkModelAsNoLongerNeeded(model)
        Game.MarkCarAsNoLongerNeeded(car)

        Chat.AddMessage("Spawned " .. Game.GetDisplayNameFromVehicleModel(model))
    end)
end

local function giveWeapon(weapon, ammo)
    Thread.Create(function()
        local model = Game.GetWeapontypeModel(weapon)
        Game.RequestModel(model)

        while not Game.HasModelLoaded(model) do
            Thread.Pause(0)
        end

        Game.GiveWeaponToChar(Game.GetPlayerChar(Game.GetPlayerId()), weapon, ammo, true)
        Game.MarkModelAsNoLongerNeeded(model)
    end)
end

local function setWantedLevel(level)
    local playerId = Game.GetPlayerId()

    Game.ClearWantedLevel(playerId)
    Game.AlterWantedLevel(playerId, level)
    Game.ApplyWantedLevelChangeNow(playerId)

    Chat.AddMessage("Wanted level changed to " .. level)
end

local function repairVehicle()
    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)

    if Game.IsCharInAnyCar(playerChar) then
        local playerCar = Game.GetCarCharIsUsing(playerChar)

        -- Repair vehicle.
        Game.FixCar(playerCar)

        Chat.AddMessage("Vehicle repaired")
    end
end

local function flipVehicle()
    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)

    if Game.IsCharInAnyCar(playerChar) then
        local playerCar = Game.GetCarCharIsUsing(playerChar)

        -- Get vehicle coordinates.
        local x, y, z = Game.GetCarCoordinates(playerCar)
        local h = Game.GetCarHeading(playerCar)

        -- Flip vehicle.
        Game.SetCarCoordinates(playerCar, x, y, z)
        Game.SetCarHeading(playerCar, h)

        Chat.AddMessage("Vehicle flipped")
    end
end

local function healPlayer()
    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)

    -- Set char health and armour to full.
    Game.SetCharHealth(playerChar, 200)
    Game.AddArmourToChar(playerChar, 200)

    Chat.AddMessage("Healed")
end

local function teleportToPlayer(player)
    local targetId = nil

    -- Get player id from serverid or name.
    if isNumber(player) then
        targetId = Player.GetIDFromServerID(tonumber(player))
    else
        for i = 0, 31 do
            if Game.IsNetworkPlayerActive(i) then
                if string.lower(Game.GetPlayerName(i)) == string.lower(tostring(player)) then
                    targetId = i
                    break
                end
            end
        end
    end

    -- Check if target player found.
    if targetId == nil then
        return Chat.AddMessage("Error: Player doesn't exist.")
    end

    -- Check if target is in a car.
    if Game.IsCharInAnyCar(Game.GetPlayerChar(targetId)) then
        local targetCar = Game.GetCarCharIsUsing(Game.GetPlayerChar(targetId))

        -- Check if player and target are in same car.
        if Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId())) and targetCar == Game.GetCarCharIsUsing(Game.GetPlayerChar(Game.GetPlayerId())) then
            return Chat.AddMessage("Error: You are already in the same car.")
        end

        -- Check if there is a seat free in the target car.
        if Game.GetMaximumNumberOfPassengers(targetCar) == Game.GetNumberOfPassengers(targetCar) then
            return Chat.AddMessage("Error: There's no more free seats in " .. Game.GetPlayerName(targetId) .. "'s vehicle.")
        end

        -- Teleport in target player's car.
        Game.WarpCharIntoCarAsPassenger(Game.GetPlayerChar(Game.GetPlayerId()), Game.GetCarCharIsUsing(Game.GetPlayerChar(targetId)), -1)

        -- Send confirmation message.
        return Chat.AddMessage("Teleported into " .. Game.GetPlayerName(targetId) .. "'s vehicle.")
    end

    -- Get coords from the target player.
    local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(targetId))
    local heading = Game.GetCharHeading(Game.GetPlayerChar(targetId))

    -- Teleport to target player.
    if Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId())) then
        Game.WarpCharFromCarToCoord(Game.GetPlayerChar(Game.GetPlayerId()), x, y, z)
    else
        Game.SetCharCoordinatesNoOffset(Game.GetPlayerChar(Game.GetPlayerId()), x, y, z)
        Game.SetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()), heading)
    end

    -- Send confirmation message.
    Chat.AddMessage("Teleported to " .. Game.GetPlayerName(targetId))
end

local function whisperToPlayer(player, message)
    local targetId = nil

    -- Get serverID if name.
    if not isNumber(player) then
        for i = 0, 31 do
            if Game.IsNetworkPlayerActive(i) then
                if string.lower(Game.GetPlayerName(i)) == string.lower(tostring(player)) then
                    targetId = Player.GetServerID(i)
                    break
                end
            end
        end
    else
        targetId = tonumber(player)
    end

    -- Check if target player found.
    if targetId == nil then
        return Chat.AddMessage("Error: Player doesn't exist.")
    end

    Events.CallRemote("cmdWhisper", { targetId, message })
end

Events.Subscribe("chatCommand", function(fullcommand)
	local command = stringsplit(fullcommand, ' ')

    if command[1] == "/weather" then
        if command[2] == nil or not isNumber(command[2]) then Chat.AddMessage("Usage: /weather [id]")
        elseif tonumber(command[2]) < 0 or tonumber(command[2]) > 9 then Chat.AddMessage("Weather IDs: 0-9")
        else
            Game.ForceWeatherNow(tonumber(command[2]))
            Chat.AddMessage("Changed weather to " .. getWeatherName(tonumber(command[2])))
        end
    elseif command[1] == "/veh" then
        if command[2] == nil then Chat.AddMessage("Usage: /veh [model]")
        else createVehicle(command[2])
        end
    elseif command[1] == "/wep" then
        if command[2] == nil then Chat.AddMessage("Usage: /wep [weapon]")
        elseif weapons[command[2]] == nil then Chat.AddMessage("Error: Invalid weapon")
        else giveWeapon(weapons[command[2]], 10000)
        end
    elseif command[1] == "/wanted" then
        if command[2] == nil or not isNumber(command[2]) then Chat.AddMessage("Usage: /wanted [level]")
        else setWantedLevel(tonumber(command[2]))
        end
    elseif command[1] == "/repair" then
        repairVehicle()
    elseif command[1] == "/flip" then
        flipVehicle()
    elseif command[1] == "/heal" then
        healPlayer()
    elseif command[1] == "/kill" then
        Game.SetCharHealth(Game.GetPlayerChar(Game.GetPlayerId()), 99)
    elseif command[1] == "/session" then
        if command[2] == nil or not isNumber(command[2]) then Chat.AddMessage("Usage: /session [id]")
        else Events.CallRemote("cmdSession", { tonumber(command[2]) })
        end
    elseif command[1] == "/tp" or command[1] == "/goto" then
        if command[2] == nil then Chat.AddMessage("Usage: /tp [player]")
        else teleportToPlayer(command[2])
        end
    elseif command[1] == "/pm" or command[1] == "/whisper" then
        if command[2] == nil or command[3] == nil then Chat.AddMessage("Usage: /pm [player] [message]")
        else whisperToPlayer(command[2], string.sub(fullcommand, string.len(command[1]) + string.len(command[2]) + 2))
        end
    elseif command[1] == "/mypos" then
        local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
        Chat.AddMessage("Your coordinates in world: " .. x .. ", " .. y .. ", " .. z)
    elseif command[1] == "/help" then
        Chat.AddMessage(" ** /weather, /wep, /wanted, /kill, /heal")
        Chat.AddMessage(" ** /veh, /repair, /flip, /tp, /pm, /session, /mypos")
    else
        Chat.AddMessage("Error: Unknown command")
    end
end)

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- Check if string is a number.
function isNumber(str)
	local num = tonumber(str)
	if not num then return false
	else return true
	end
end