local playerBlips = {}

local function updatePlayerBlips()
    local playerID = Game.GetPlayerId()

    for i = 0, 31 do
        if i ~= playerID then
            if Game.IsNetworkPlayerActive(i) then
                if playerBlips[i] == nil or not Game.DoesBlipExist(playerBlips[i]) then
                    playerBlips[i] = Game.AddBlipForChar(Game.GetPlayerChar(i))
                    Game.ChangeBlipSprite(playerBlips[i], 0)
                    Game.ChangeBlipPriority(playerBlips[i], 3)
                    Game.ChangeBlipColour(playerBlips[i], Game.GetPlayerColour(i))
                    Game.ChangeBlipNameFromAscii(playerBlips[i], Game.GetPlayerName(i))
                    Game.ChangeBlipScale(playerBlips[i], 0.9)
                end
            else
                if playerBlips[i] ~= nil then
                    if Game.DoesBlipExist(playerBlips[i]) then
                        Game.RemoveBlip(playerBlips[i])
                    end

                    playerBlips[i] = nil
                end
            end
        end
    end
end

Events.Subscribe("scriptInit", function()
	Thread.Create(function()
        while true do
            updatePlayerBlips()

            Thread.Pause(1000)
        end
    end)
end)