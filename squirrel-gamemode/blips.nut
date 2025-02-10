local playerBlips = {};

function updatePlayerBlips()
{
    local playerID = Game.GetPlayerId();

    for (local i = 0; i < 32; i++)
    {
        if (i != playerID)
        {
            if (Game.IsNetworkPlayerActive(i))
            {
                if (!playerBlips.rawin(i) || !Game.DoesBlipExist(playerBlips[i]))
                {
                    playerBlips[i] <- Game.AddBlipForChar(Game.GetPlayerChar(i));
                    Game.ChangeBlipSprite(playerBlips[i], 0);
                    Game.ChangeBlipPriority(playerBlips[i], 3);
                    Game.ChangeBlipColour(playerBlips[i], Game.GetPlayerColour(i));
                    Game.ChangeBlipNameFromAscii(playerBlips[i], Game.GetPlayerName(i));
                    Game.ChangeBlipScale(playerBlips[i], 0.9);
                }
            }
            else
            {
                if (playerBlips.rawin(i))
                {
                    if (Game.DoesBlipExist(playerBlips[i]))
                    {
                        Game.RemoveBlip(playerBlips[i]);
                    }

                    delete playerBlips[i];
                }
            }
        }
    }
}

Events.Subscribe("scriptInit", function() {
	Thread.Create(function() {
        while (true) {
            updatePlayerBlips();

            Thread.Pause(1000);
        }
    });
});