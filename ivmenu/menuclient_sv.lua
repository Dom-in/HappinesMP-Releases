-- Create By LeChapellierFou
-- HappinessMP client menu
-- Parts of menu base v3.0


Events.Subscribe("send_message", function(id, message)
    local source = Events.GetSource()

    Chat.SendMessage(source, "Menu : Send Message Succefully To " .. Player.GetName(id) .." : " .. message)

    Chat.SendMessage(id, " " .. Player.GetName(source) .. " Send You Message :"..message)
end, true)

Events.Subscribe("kick_player", function(id)
	
   	Chat.BroadcastMessage("" .. Player.GetName(id) .. " Kick from server")
	Thread.Create(function()
		Thread.Pause(1000) -- 1 sec
		Player.Kick(id)
	end)
end, true)