local weapons =  { "baseballbat": 1,
                   "poolcue": 2,
                   "knife": 3,
                   "grenade": 4,
                   "molotov": 5,
                   "pistol": 7,
                   "deagle": 9,
                   "deserteagle": 9,
                   "shotgun": 10,
                   "baretta": 11,
                   "microuzi": 12,
                   "uzi": 12,
                   "mp5": 13,
                   "ak47": 14,
                   "m4": 15,
                   "sniper": 16,
                   "m40a1": 17,
                   "rpg": 18,
                   "rocketlauncher": 18 };

// Returns a weather name by weather id.
local function getWeatherName(id)
{
	switch(id)
	{
		case 0: return "Extra sunny";
		case 1: return "Sunny";
		case 2: return "Sunny and windy";
		case 3: return "Cloudy";
		case 4: return "Raining";
		case 5: return "Drizzle";
		case 6: return "Foggy";
		case 7: return "Thunderstorm";
		case 8: return "Extra sunny 2";
		case 9: return "Sunny and windy 2";
		default: return "Unknown";
	}
}

// Creates a vehicle by model name.
local function createVehicle(modelname)
{
    local model = Game.GetHashKey(modelname);

    // Check if model exist in cd image.
    if (!Game.IsModelInCdimage(model)) {
        Chat.AddMessage("Error: Unknown model");
        return;
    }

    // If player is currently the driver of a car, delete it.
    if (Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId()))) {
        local currentCar = Game.GetCarCharIsUsing(Game.GetPlayerChar(Game.GetPlayerId()));

        if (Game.GetDriverOfCar(currentCar) == Game.GetPlayerChar(Game.GetPlayerId())) {
            Game.DeleteCar(currentCar);
        }
    }

    Thread.Create(function() {
        local pos = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()));
        local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()));

        Game.RequestModel(model);

        while (!Game.HasModelLoaded(model)) {
            Thread.Pause(0);
        }

        local car = Game.CreateCar(model, pos[0], pos[1], pos[2], true);
        Game.SetCarHeading(car, heading);
        Game.SetCarOnGroundProperly(car);

        Game.SetVehicleDirtLevel(car, 0.0);
        Game.WashVehicleTextures(car, 255);

        local colour = random(0, 132);
        Game.ChangeCarColour(car, colour.tointeger(), colour.tointeger());

        Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car);

        Game.MarkModelAsNoLongerNeeded(model);
        Game.MarkCarAsNoLongerNeeded(car);

        Chat.AddMessage("Spawned " + Game.GetDisplayNameFromVehicleModel(model));
    });
}

local function giveWeapon(weapon, ammo)
{
    Thread.Create(function() {
        local model = Game.GetWeapontypeModel(weapon);
        Game.RequestModel(model);

        while (!Game.HasModelLoaded(model)) {
            Thread.Pause(0);
        }

        Game.GiveWeaponToChar(Game.GetPlayerChar(Game.GetPlayerId()), weapon, ammo, true);
        Game.MarkModelAsNoLongerNeeded(model);
    });
}

local function setWantedLevel(level)
{
    local playerId = Game.GetPlayerId();

    Game.ClearWantedLevel(playerId);
    Game.AlterWantedLevel(playerId, level);
    Game.ApplyWantedLevelChangeNow(playerId);

    Chat.AddMessage("Wanted level changed to " + level);
}

local function repairVehicle()
{
    local playerId = Game.GetPlayerId();
    local playerChar = Game.GetPlayerChar(playerId);

    if (Game.IsCharInAnyCar(playerChar)) {
        local playerCar = Game.GetCarCharIsUsing(playerChar);

        // Repair vehicle.
        Game.FixCar(playerCar);

        Chat.AddMessage("Vehicle repaired");
    }
}

local function flipVehicle()
{
    local playerId = Game.GetPlayerId();
    local playerChar = Game.GetPlayerChar(playerId);

    if (Game.IsCharInAnyCar(playerChar)) {
        local playerCar = Game.GetCarCharIsUsing(playerChar);

        // Get vehicle coordinates.
        local pos = Game.GetCarCoordinates(playerCar);
        local h = Game.GetCarHeading(playerCar);

        // Flip vehicle.
        Game.SetCarCoordinates(playerCar, pos[0], pos[1], pos[2]);
        Game.SetCarHeading(playerCar, h);

        Chat.AddMessage("Vehicle flipped");
    }
}

local function healPlayer()
{
    local playerId = Game.GetPlayerId();
    local playerChar = Game.GetPlayerChar(playerId);

    // Set char health and armour to full.
    Game.SetCharHealth(playerChar, 200);
    Game.AddArmourToChar(playerChar, 200);

    Chat.AddMessage("Healed");
}

local function teleportToPlayer(player)
{
    local targetId = null

    // Get player id from serverid or name.
    if (isNumber(player)) {
        targetId = Player.GetIDFromServerID(player.tointeger());
    } else {
        for (local i = 0; i < 32; i++) {
            if (Game.IsNetworkPlayerActive(i)) {
                if (Game.GetPlayerName(i).tolower() == player.tolower()) {
                    targetId = i;
                    break;
                }
            }
        }
    }

    // Check if target player found.
    if (targetId == null) {
        return Chat.AddMessage("Error: Player doesn't exist.");
    }

    // Check if target is in a car.
    if (Game.IsCharInAnyCar(Game.GetPlayerChar(targetId))) {
        local targetCar = Game.GetCarCharIsUsing(Game.GetPlayerChar(targetId));

        // Check if player and target are in same car.
        if (Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId())) && targetCar == Game.GetCarCharIsUsing(Game.GetPlayerChar(Game.GetPlayerId()))) {
            return Chat.AddMessage("Error: You are already in the same car.");
        }

        // Check if there is a seat free in the target car.
        if (Game.GetMaximumNumberOfPassengers(targetCar) == Game.GetNumberOfPassengers(targetCar)) {
            return Chat.AddMessage("Error: There's no more free seats in " + Game.GetPlayerName(targetId) + "'s vehicle.");
        }

        // Teleport in target player's car.
        Game.WarpCharIntoCarAsPassenger(Game.GetPlayerChar(Game.GetPlayerId()), Game.GetCarCharIsUsing(Game.GetPlayerChar(targetId)), -1);

        // Send confirmation message.
        return Chat.AddMessage("Teleported into " + Game.GetPlayerName(targetId) + "'s vehicle.");
    }

    // Get coords from the target player.
    local pos = Game.GetCharCoordinates(Game.GetPlayerChar(targetId));
    local heading = Game.GetCharHeading(Game.GetPlayerChar(targetId));

    // Teleport to target player.
    if (Game.IsCharInAnyCar(Game.GetPlayerChar(Game.GetPlayerId()))) {
        Game.WarpCharFromCarToCoord(Game.GetPlayerChar(Game.GetPlayerId()), pos[0], pos[1], pos[2]);
    } else {
        Game.SetCharCoordinatesNoOffset(Game.GetPlayerChar(Game.GetPlayerId()), pos[0], pos[1], pos[2]);
        Game.SetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()), heading);
    }

    // Send confirmation message.
    Chat.AddMessage("Teleported to " + Game.GetPlayerName(targetId));
}

local function whisperToPlayer(player, message)
{
    local targetId = null

    // Get serverID if name.
    if (!isNumber(player)) {
        for (local i = 0; i < 32; i++) {
            if (Game.IsNetworkPlayerActive(i)) {
                if (Game.GetPlayerName(i).tolower() == player.tolower()) {
                    targetId = Player.GetServerID(i);
                    break;
                }
            }
        }
    } else {
        targetId = player.tointeger();
    }

    // Check if target player found.
    if (targetId == null) {
        return Chat.AddMessage("Error: Player doesn't exist.");
    }

    Events.CallRemote("cmdWhisper", [ targetId, message ]);
}

Events.Subscribe("chatCommand", function(fullcommand) {
    local command = split(fullcommand, " ");

    if (command[0] == "/weather") {
        if (command.len() != 2 || !isNumber(command[1])) Chat.AddMessage("Usage: /weather [id]");
        else if (command[1].tointeger() < 0 || command[1].tointeger() > 9) Chat.AddMessage("Weather IDs: 0-9");
        else {
            Game.ForceWeatherNow(command[1].tointeger());
            Chat.AddMessage("Changed weather to " + getWeatherName(command[1].tointeger()));
        }
    }
    else if (command[0] == "/veh") {
        if (command.len() != 2) Chat.AddMessage("Usage: /veh [model]");
        else createVehicle(command[1]);
    }
    else if (command[0] == "/wep") {
        if (command.len() != 2) Chat.AddMessage("Usage: /wep [weapon]");
        else if (!weapons.rawin(command[1])) Chat.AddMessage("Error: Invalid weapon");
        else giveWeapon(weapons[command[1]], 10000);
    }
    else if (command[0] == "/wanted") {
        if (command.len() != 2 || !isNumber(command[1])) Chat.AddMessage("Usage: /wanted [level]");
        else setWantedLevel(command[1].tointeger());
    }
    else if (command[0] == "/repair") {
        repairVehicle();
    }
    else if (command[0] == "/flip") {
        flipVehicle();
    }
    else if (command[0] == "/heal") {
        healPlayer();
    }
    else if (command[0] == "/kill") {
        Game.SetCharHealth(Game.GetPlayerChar(Game.GetPlayerId()), 99);
    }
    else if (command[0] == "/session") {
        if (command.len() != 2 || !isNumber(command[1])) Chat.AddMessage("Usage: /session [id]");
        else Events.CallRemote("cmdSession", [ command[1].tointeger() ]);
    }
    else if (command[0] == "/tp" || command[0] == "/goto") {
        if (command.len() != 2) Chat.AddMessage("Usage: /tp [player]");
        else teleportToPlayer(command[1]);
    }
    else if (command[0] == "/pm" || command[0] == "/whisper") {
        if (command.len() < 3) Chat.AddMessage("Usage: /pm [player] [message]");
        else whisperToPlayer(command[1], fullcommand.slice(command[0].len() + command[1].len() + 2));
    }
    else if (command[0] == "/mypos") {
        local pos = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()));
        Chat.AddMessage("Your coordinates in world: " + pos[0] + ", " + pos[1] + ", " + pos[2]);
    }
    else if (command[0] == "/help") {
        Chat.AddMessage(" ** /weather, /wep, /wanted, /kill, /heal");
        Chat.AddMessage(" ** /veh, /repair, /flip, /tp, /pm, /session, /mypos");
    }
    else
    {
        Chat.AddMessage("Error: Unknown command");
    }
});

// Generates a pseudo-random number in specified range.
function random(min = 0, max = RAND_MAX)
{
   return (rand() % ((max + 1) - min)) + min;
}

// Check if string is a number.
function isNumber(str)
{
	try {
        str.tointeger();
        return true;
    }
    catch (err) {
        return false;
    }
}