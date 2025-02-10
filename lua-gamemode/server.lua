Events.Subscribe("playerJoin", function()
    local source = Events.GetSource()

	Chat.BroadcastMessage(" ** " .. Player.GetName(source) .. "(" .. source .. ") connected to server.")
end, true)

Events.Subscribe("playerDisconnect", function(id, name, reason)
	Chat.BroadcastMessage(" ** " .. name .. "(" .. id .. ") disconnected from server (Reason: " .. (reason == 1 and "Quit" or "Timed Out") .. ").")
end)

Events.Subscribe("cmdSession", function(id)
    local source = Events.GetSource()

    Player.SetSession(source, id)
    Chat.SendMessage(source, "Switching session to " .. id)
end, true)

Events.Subscribe("cmdWhisper", function(id, message)
    local source = Events.GetSource()

    Chat.SendMessage(source, " << " .. Player.GetName(id) .. "(" .. id .. "): " .. message)
    Chat.SendMessage(id, " >> " .. Player.GetName(source) .. "(" .. source .. "): " .. message)
end, true)