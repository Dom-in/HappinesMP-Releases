Events.Subscribe("scriptInit", function() {
    Chat.AddMessage(" ** Use /help for commands list. Thank you for testing!");

    Events.CallRemote("playerJoin", []);
});