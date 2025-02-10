local SPAWN_MODEL = "M_Y_MULTIPLAYER";
local SPAWN_COORDS = [ -222.98, 430.16, 14.82, 122.23 ];

// From original R* scripts.
local function freezePlayer(id, freeze)
{
	local playerIndex = Game.ConvertIntToPlayerindex(id);
	Game.SetPlayerControlForNetwork(playerIndex, !freeze, false);

	local playerChar = Game.GetPlayerChar(playerIndex);
	Game.SetCharVisible(playerChar, !freeze);

	if (!freeze)
	{
		if (!Game.IsCharInAnyCar(playerChar))
		{
			Game.SetCharCollision(playerChar, true);
		}

		Game.FreezeCharPosition(playerChar, false);
		Game.SetCharNeverTargetted(playerChar, false);
		Game.SetPlayerInvincible(playerIndex, false);
	}
	else
	{
		Game.SetCharCollision(playerChar, false);
		Game.FreezeCharPosition(playerChar, true);
		Game.SetCharNeverTargetted(playerChar, true);
		Game.SetPlayerInvincible(playerIndex, true);
		Game.RemovePtfxFromPed(playerChar);

		if (!Game.IsCharFatallyInjured(playerChar))
		{
			Game.ClearCharTasksImmediately(playerChar);
		}
	}
}

local spawnLock = false;

local function spawnPlayer()
{
	// Check if spawnLock is active, if so, exit the function.
	if (spawnLock)
	{
		return;
	}

	// Set spawnLock to true to prevent re-entry while spawning.
    spawnLock = true;

	// If the screen is not already faded out, initiate a fade out.
	if (!Game.IsScreenFadedOut())
	{
		Game.DoScreenFadeOut(500);

		// Wait for the screen to finish fading out.
		while (Game.IsScreenFadingOut()) {
			Thread.Pause(0);
		}
	}

	// Get the hash key for the spawn model.
	local spawnModel = Game.GetHashKey(SPAWN_MODEL);

	// Check if the model is valid.
	if (!Game.IsModelInCdimage(spawnModel))
	{
		Console.Log("spawnPlayer: invalid spawn model");
		return;
	}

	// Get the player id and char.
	local playerId = Game.GetPlayerId();
	local playerChar = Game.GetPlayerChar(playerId);

	// Freeze player like in original R* scripts.
	freezePlayer(playerId, true);

	// If the player char does not have the spawn model, load it.
	if (!Game.IsCharModel(playerChar, spawnModel))
	{
		Game.RequestModel(spawnModel);
		Game.LoadAllObjectsNow();

		while (!Game.HasModelLoaded(spawnModel)) {
			Game.RequestModel(spawnModel);
			Thread.Pause(0);
		}

		Game.ChangePlayerModel(playerId, spawnModel);
		Game.MarkModelAsNoLongerNeeded(spawnModel);

		playerChar = Game.GetPlayerChar(playerId);
	}

	// Request collision at spawn coordinates.
	Game.RequestCollisionAtPosn(SPAWN_COORDS[0], SPAWN_COORDS[1], SPAWN_COORDS[2]);

	// Resurrect the network player at spawn coordinates.
	Game.ResurrectNetworkPlayer(playerId, SPAWN_COORDS[0], SPAWN_COORDS[1], SPAWN_COORDS[2], SPAWN_COORDS[3]);

	// Clear character tasks immediately.
	Game.ClearCharTasksImmediately(playerChar);

	// Reset player health.
	Game.SetCharHealth(playerChar, 300);

	// Remove all weapons from the player character.
	Game.RemoveAllCharWeapons(playerChar);

	// Clear the player's wanted level.
	Game.ClearWantedLevel(playerId);

	// Restore the camera's jumpcut.
	Game.CamRestoreJumpcut();

	// Disable loading screen.
	Game.ForceLoadingScreen(false);

	// Fade the screen back in.
	Game.DoScreenFadeIn(500);

	// Unfreeze the player.
	freezePlayer(playerId, false);

	// Trigger the "playerSpawn" event.
	Events.Call("playerSpawn", []);

	// Reset spawnLock.
	spawnLock = false;
}

Events.Subscribe("scriptInit", function() {
	// Respawn at death.
	Thread.Create(function() {
		while (true) {
			local playerId = Game.GetPlayerId();

			if (Game.IsNetworkPlayerActive(playerId))
			{
                if (Game.HowLongHasNetworkPlayerBeenDeadFor(playerId) > 2000)
				{
                    spawnPlayer();
				}
			}

			Thread.Pause(0);
		}
	});
});

Events.Subscribe("sessionInit", function() {
	Thread.Create(spawnPlayer);
});