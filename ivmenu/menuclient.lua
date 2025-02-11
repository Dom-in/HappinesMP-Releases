-- Create By LeChapellierFou
-- HappinessMP client menu
-- Parts of menu base v3.0

--------------------------------------
-------- variable core menu-----------
--------------------------------------
local MAX_PLAYERS = 32
local VersionOfMenu = "version 3.0"
local DateOfVersion = "26/10/2024"

local item_selected = 0
local menu_level = 0
local max_item = 0
local menu_len = 0
local Scroll_down = false
-- scrolling 
local menu_max = 0
local menu_start_scrolling = 0
local menu_consts_start_y = 0
local menu_consts_max = 0
-- scrolling speed
local hold_counter = 0
local press_counter = 0
local reset_counter = false
----------------------------
-------ITEM MENU------------
----------------------------
--paint menu
local in_paint = false
-- network players list
local in_network = false
-- Texture file from game
local NetworkTexture = nil
local Dictionary = nil

local Menu = {

    isOpen = false,
	InNetwork = false,
	InError = false,
	TextureViewer = false,
	item_name = {},
	type = {},
	action = {},
	extra_val = {},
	extra_Max = {},
	speed_val = {},
	last_selected = {},
	controlOfMenu = 0, -- keyboard, default 1 = mouse
	disable_frontend = false,

	-- All Buttons Menu
	--PC Controls, https://happinessmp.net/docs/game/keys
	ButtonUp = 200,
	ButtonDown = 208,
	ButtonLeft = 203,
	ButtonRight = 205,
	ButtonAccept = 28,
	ButtonBack = 14,
	ButtonOpen = 59, -- F1
	--xbox Controller
	BUTTON_SELECT = 0xD,
	BUTTON_X = 0xE,
	BUTTON_Y = 0xF,
	BUTTON_A = 0x10,
	BUTTON_B = 0x11,
	DPAD_UP = 0x8,
	DPAD_DOWN = 0x9,
	DPAD_LEFT = 0xA,
	DPAD_RIGHT = 0xB,
	BUTTON_LT = 0x5,
	BUTTON_RT = 0x7,
	BUTTON_LB = 0x4,
	BUTTON_RB = 0x6,
	STICK_LEFT = 0x12,
	STICK_RIGHT = 0x13,
	-- position of menu
	menu_posX, 
	menu_posY,
	menu_spacing,
	-- title menu & sub menu
	Title_menu = "iv Menu",
	Title_Item_Set = "",

	
    Player_option = { 
		godmod = false,
		freezeped = false,
		invisible = false,
		nocolision = false,
		neverwanted = false,
	},

	Vehicle_option = { 
		godmodcar = false,
		lockcar = false,
		invisiblecar = false,
		nocollisioncar = false,
		jumpcar = false,
		freezecar = false,
		speedometer = false,
		driftmode = false
	},

	Weapon_option = { 
		rapidfire = false
	},

	World_option = { 
		xyzh = false,
		time = false,
		mutegps = true,
		driveonwater = false,
		gravity = false,
		wind = false,
		playmovie = false,
		slowmotion = false,
		radioOff = false
	}
}

local Teleport_Blip = 0
local HelmetPed = false

local Gui = {
    Colour = { 
		White = { r = 255, g = 255, b = 255, a = 255 },
		Red = { r = 255, g = 0, b = 0, a = 255 },
		DarkBlue = { r = 0, g = 0, b = 255, a = 255 },
		Green = { r = 0, g = 255, b = 0, a = 255 },
		Grey = { r = 127, g = 127, b = 127, a = 255 },
		Black = { r = 0, g = 0, b = 0, a = 255 },
		Pink = { r = 255, g = 12, b = 242, a = 255 }
	},

	DisplayType = {
		Type_None = 0,
		Type_Boolean = 1,
		Type_Number = 2,
		Type_Number2 = 3,
		Type_Float = 4,
		Type_JumpOver = 5,
		Type_Display = 6
	}
}

-- player group, gang
local Ggroup = 0
local MAX_GANG_MEMBBERS = 3

local player_count = 0
local Network = {
	Id = {},
	Name = {},
	Index = {}
}

local Gang_count = 0
local GangMembers = {
	Gped = {}
}

-- Anims setup & function
local animation_Set = {}
local animation_Name = {}

-- texture viewer
local Texture_Set = {}
local Texture_Name = {}

--Drive/walk on water
local thingy = 0

local function Style_Setup()
	Menu.menu_posY =  0.2560
	Menu.menu_posX = 0.7676
	Menu.menu_spacing = 0.0300
	-- Max number of items before scrolling.
	menu_max = 10
	-- When to start scrolling.
	menu_start_scrolling = 10
end
-------------------------------------------------------------------------
---------------------- FUNCTIONS ----------------------------------------
-------------------------------------------------------------------------
local function AttachObjecttocar(model, veh, x0, y0, z0, rx, ry, rz)

	LoadModelFromCdimage(model)
	local objs = Game.CreateObjectNoOffset(model, 0, 0, 0, true)
	
	Game.FreezeObjectPosition(objs, true)
	Game.SetObjectVisible(objs, true)
	Game.SetObjectCollision(objs, false)
	Game.SetObjectLights(objs, true)
	Game.AttachObjectToCar(objs, veh, 0, x0, y0, z0, rx, ry, rz)
	Game.MarkModelAsNoLongerNeeded(model)
	
end

local function clear_objects_on_car(veh)
    if( not Game.DoesVehicleExist(veh) ) then return end

	for i=0,9999,1 do		
        if(Game.DoesObjectExistWithNetworkId(i)) then
			local delObj = Game.GetObjectFromNetworkId(i)
            if(Game.IsObjectAttached(delObj)) then
				if(Game.GetCarObjectIsAttachedTo(delObj) == veh) then
					Game.DeleteObject(delObj)
				end
			end
		end
	end
end

local function clear_objects_near()
    
	for i=0,9999,1 do		
        if(Game.DoesObjectExistWithNetworkId(i)) then
			local delObj = Game.GetObjectFromNetworkId(i)
            if(not Game.IsObjectAttached(delObj)) then
				Game.DeleteObject(delObj)
			end
		end
	end
end

local function ExtraAction(item_id)
	--from xbox 360 c++ file
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	
	if Game.IsCharInAnyCar(playerChar) then
		local playerCar = Game.GetCarCharIsUsing(playerChar)
		
		if Game.IsVehicleExtraTurnedOn(playerCar, item_id) then 
			Game.TurnOffVehicleExtra(playerCar, item_id, true)
			--Print("Extra "..item_id.." ~COL_NET_4~Disable")
		else
			Game.TurnOffVehicleExtra(playerCar, item_id, false)
			--Print("Extra "..item_id.." ~COL_NET_3~Enable")
		end
	end
end

local function AutoDelVeh()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	
	if Game.IsCharInAnyCar(playerChar) then
		local playerCar = Game.GetCarCharIsUsing(playerChar)
		local DriverCar = Game.GetDriverOfCar(playerCar)
		if DriverCar == playerChar then
			Game.DeleteCar(playerCar)
		end
	end
end

local function SetUptext(r, g, b, a)
	Game.SetTextScale(0.2680, 0.2680)
	Game.SetTextDropshadow(false, 0, 0, 0, 0)
	Game.SetTextEdge(false, 0, 0, 0, 255)
	Game.SetTextColour(r, g, b, a)
end

local function SetUptextDraw()
	Game.SetTextFont(0)
	Game.SetTextScale(0.2500, 0.2500)
	Game.SetTextDropshadow(false, 0, 0, 0, 0)
	Game.SetTextEdge(true, 0, 0, 0, 255)
	Game.SetTextColour(255, 255, 255, 255)
end

local function Print(_text_print, time)
	Game.ClearPrints()
	Game.PrintStringWithLiteralStringNow("STRING", _text_print, time, true)
end

local function LoadAnims(set)
	while not Game.HaveAnimsLoaded(set) do
		Game.RequestAnims(set)
		Thread.Pause(0)
	end
end

local SavePosWithBlip = function()
	local px,py,pz = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
	
	local bliptp = Game.AddBlipForCoord(px,py,pz)
	Game.ChangeBlipSprite(bliptp, 0)
	Game.ChangeBlipColour(bliptp, 3)
	Game.ChangeBlipScale(bliptp, 0.7)
	Game.ChangeBlipNameFromAscii(bliptp, "save pos")
	Game.SetBlipAsShortRange(bliptp, true)
	return bliptp
end

local function AddAnimToPed(ped, anim, set, time)

	Game.ClearCharTasksImmediately(ped)
	LoadAnims(set)
	Game.TaskPlayAnim(ped, anim, set, 4.00000000, false, false, false, false, time) 
end

local function AddMemberToGang(model)

	local px, py, pz = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
	
	if(not Game.DoesGroupExist(Ggroup)) then
		Ggroup = Game.CreateGroup(false, true)
		Game.SetGroupLeader(Ggroup, Game.GetPlayerChar(Game.GetPlayerId()))
		Game.SetGroupFormation(Ggroup, 1)
		Game.SetGroupFormationSpacing(Ggroup, 1)
	end

	local Indexp, countp = Game.GetGroupSize(Ggroup)	
	if((countp >= MAX_GANG_MEMBBERS) or (countp == MAX_GANG_MEMBBERS)) then -- max 3
		Print("Max 3 members in gang", 2500)
		return
	end

	if Game.DoesGroupExist(Ggroup) then
		
		if Game.IsModelInCdimage(model) then	
			while not Game.HasModelLoaded(model) do
				Game.RequestModel(model)
				Thread.Pause(0)
			end
		else 
			Game.ClearPrints()
			Game.PrintStringWithLiteralStringNow("STRING", "~r~Error :~w~ Model Not Exist !.", 4000, true)
		end

		GangMembers.Gped[Gang_count] = Game.CreateChar(26, model, px, py + 2, pz, true)

		Game.SetGroupMember(Ggroup, GangMembers.Gped[Gang_count])
		Game.SetCharNeverLeavesGroup(GangMembers.Gped[Gang_count], true)
		Game.SetCharRelationshipGroup(GangMembers.Gped[Gang_count], 24)
		Game.SetCharRelationship(GangMembers.Gped[Gang_count], 5, 0)
		Game.SetCharAccuracy(GangMembers.Gped[Gang_count], 100)
		Game.SetCharKeepTask(GangMembers.Gped[Gang_count], true)
		Game.SetSenseRange(GangMembers.Gped[Gang_count], 200.0)
		Game.SetPedGeneratesDeadBodyEvents(GangMembers.Gped[Gang_count], true)
		Game.SetCharShootRate(GangMembers.Gped[Gang_count], 100)
		Game.SetCharWillUseCover(GangMembers.Gped[Gang_count], true)
		Game.SetCharWillDoDrivebys(GangMembers.Gped[Gang_count], true)
		Game.SetCharSignalAfterKill(GangMembers.Gped[Gang_count], true)
		Game.SetCharWillUseCarsInCombat(GangMembers.Gped[Gang_count], true)
		Game.SetCharProvideCoveringFire(GangMembers.Gped[Gang_count], true)
		Game.SetCharCantBeDraggedOut(GangMembers.Gped[Gang_count], true)
		Game.SetCharStayInCarWhenJacked(GangMembers.Gped[Gang_count], true)
		Game.SetPedDontDoEvasiveDives(GangMembers.Gped[Gang_count], true)
		Game.SetDontActivateRagdollFromPlayerImpact(GangMembers.Gped[Gang_count], true)
		Game.SetPedPathMayDropFromHeight(GangMembers.Gped[Gang_count], true)
		Game.SetPedPathMayUseClimbovers(GangMembers.Gped[Gang_count], true)
		Game.SetPedPathMayUseLadders(GangMembers.Gped[Gang_count], true)
		Gang_count = Gang_count+1
	end
end

local function AddAnimsToGang(anim, set)
	if(Game.DoesGroupExist(Ggroup)) then
		local test, guards = Game.GetGroupSize(Ggroup)
		if guards <= 0 then 
			return
		end

		for i=0,Gang_count,1 do 
			if GangMembers.Gped[i] ~= nil then
				local MembersOfGang = GangMembers.Gped[i]
				Game.ClearCharTasksImmediately(MembersOfGang)
				AddAnimToPed(MembersOfGang, anim, set, -1)
			end
		end
	end
end

local function LoadMovie(file, time)
	Game.StopMovie()
	Game.ReleaseMovie()
	Game.SetCurrentMovie(file) 
	Game.PlayMovie()
	Game.SetMovieTime(time)
	Game.SetMovieVolume(-12.0000000)
end

------------------------------------------------------------------------
---------------------- Setup Functions ---------------------------------
------------------------------------------------------------------------

local function AddItem(_text)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemSub(_text)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = false
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemJumpOver(_text)
	Menu.item_name[menu_len] = _text
	Menu.type[menu_len] = Gui.DisplayType.Type_JumpOver
	Menu.extra_val[menu_len] = menu_len 

	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemBool(_text, val)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = val 
	Menu.type[menu_len] = Gui.DisplayType.Type_Boolean 
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemHash(_text, val)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = val 
	Menu.type[menu_len] = Gui.DisplayType.Type_None
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemNumber(_text, value, max)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = value 
	Menu.type[menu_len] = Gui.DisplayType.Type_Number2
	Menu.extra_Max[menu_len] = max 
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddColorPaint(_text, value, max)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = value 
	Menu.type[menu_len] = Gui.DisplayType.Type_Number
	Menu.extra_Max[menu_len] = max 
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddDisplay(_text, value)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = value 
	Menu.type[menu_len] = Gui.DisplayType.Type_Display
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

local function AddItemFloat(_text, value, max, speed)
	Menu.item_name[menu_len] = _text
	Menu.action[menu_len] = true
	Menu.extra_val[menu_len] = value 
	Menu.type[menu_len] = Gui.DisplayType.Type_Float
	Menu.extra_Max[menu_len] = max 
	Menu.speed_val[menu_len] = speed 
	
	menu_len = menu_len + 1
	max_item = menu_len - 1
end

----------- ITEM FUNCTION ---------------------------

local function ResetMenu()
	local mlen = menu_len - 1

	for i=0,mlen,1 do		
		Menu.extra_val[i] = 0 		
		Menu.type[i] = 0
		Menu.extra_Max[i] = 0
		Menu.Title_Item_Set = " "
	end

	-- Reset menu_start_y & menu_max
	Menu.menu_posY = menu_consts_start_y
	menu_max = menu_consts_max
end

local function ResetNetworkMenu()
	for i=0, MAX_PLAYERS, 1 do 
		Network.Id[i] = nil
		Network.Index[i] = nil
		Network.Name[i] = nil
	end
end

local function JumpOverItem(mode, itemi)

	if mode ~= -1 and itemi ~= -1 then
		if mode == "+" then
			if item_selected == itemi then
				item_selected = item_selected + 1
			end
		elseif mode == "-" then
			if item_selected == itemi then
				item_selected = item_selected - 1
			end
		end
	end
end

--------------------------------------------------------------------------------

local function menu_setup()
	menu_len = 0
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local Episode = Game.GetCurrentEpisode()

	if menu_level == 0 then
		Menu.Title_Item_Set = "Main Menu"
		ResetNetworkMenu()

		AddItemSub("Player Options >")-- 0
		AddItemSub("Vehicle Options >") --1
		AddItemSub("Weapons Options >") --2
		AddItemSub("Spawn Cars >") --3
		AddItemSub("Garage Mod >") --4
		AddItemSub("Teleport >") --5
		AddItemSub("World Options >") --6
		AddItemSub("Network >") --7
		AddItemSub("Menu Options >") --8
		AddItemSub("Credits >")	-- 9
	elseif menu_level == 1 then
		if Menu.last_selected[0] == 0 then -- player
			Menu.Title_Item_Set = "Player options"
			AddItemBool("God Mod", Menu.Player_option.godmod)
			AddItemBool("Freeze Ped", Menu.Player_option.freezeped)
			AddItemBool("Invisible", Menu.Player_option.invisible)
			AddItemBool("No Collision", Menu.Player_option.nocolision)
			AddItemBool("Never Wanted", Menu.Player_option.neverwanted)
			AddItem("Add 6 Stars")
			AddItem("Remove All Stars")
			AddItem("Random Clothes")
			AddItem("Zombie Skin")
			AddItemSub("Annimations >")
			AddItemSub("Model Changer >")
			AddItem("Add/Remove Helmet")
			AddItem("Give Full Health&Armor")
		elseif Menu.last_selected[0] == 1 then -- vehicle 
			Menu.Title_Item_Set = "Vehicle Options"
			AddItemBool("God Mod", Menu.Vehicle_option.godmodcar)
			AddItem("Repair")
			AddItem("Delete")
			AddItem("Flip")
			AddItem("Open/Close Doors")
			AddItemBool("Invisible", Menu.Vehicle_option.invisiblecar)
			AddItemBool("No Collision", Menu.Vehicle_option.nocollisioncar)
			AddItemBool("Freeze", Menu.Vehicle_option.freezecar)
			AddItemBool("Drift Mode", Menu.Vehicle_option.driftmode)
			AddItemBool("Speedometer", Menu.Vehicle_option.speedometer)
			AddItem("Next Seat")
			AddItem("Jump Car")
			AddItem("Boost")
			AddItem("Wash Veh")
			AddItem("Damage Car")
			AddItemSub("Car Stunt >")
		elseif Menu.last_selected[0] == 2 then -- weapon
			Menu.Title_Item_Set = "Weapons Options"
			AddItemSub("Gta iv Weapons >")
			AddItemSub("Tbogt Weapons >")
			AddItemSub("Tlad Weapons >")
			AddItemBool("Rapide Fire", Menu.Weapon_option.rapidfire)
		elseif Menu.last_selected[0] == 3 then -- spawn car
			Menu.Title_Item_Set = "Category"
			AddItemSub("Tbogt >")
			AddItemSub("Tlad >")
			AddItemSub("Sport >")
			AddItemSub("Muscle Car >")
			AddItemSub("2 Doors >")
			AddItemSub("4 Doors >")
			AddItemSub("Rust car >")
			AddItemSub("4x4, Suv, Van >")
			AddItemSub("Commercial >")
			AddItemSub("Emergency >")
			AddItemSub("Services >")
			AddItemSub("Motocycles >")
			AddItemSub("Boat >")
			AddItemSub("Aircraft >")
			AddItemSub("Others >")
		elseif Menu.last_selected[0] == 4 then -- garage menu
			Menu.Title_Item_Set = "Garage"
			in_paint = false
			AddItemSub("Paint >")
			AddItemSub("Extras >")
			AddItemSub("Neons >")
			AddItemSub("Doors >")
		elseif Menu.last_selected[0] == 5 then -- teleport menu
			Menu.Title_Item_Set = "Teleport"
			AddItemSub("Save/Tp Coord >")
			AddItem("Tp 5m in Front")
			AddItem("Airport Top Hangar")
			AddItem("Hove Beach")
			AddItem("Majestic Hotel")
			AddItem("Skydive")
			AddItem("Middle Park")
			AddItem("Playboy X's Pad")
			AddItem("Rotterdam Tower")
			AddItem("Prison Cage")
			AddItem("Crack House")
			AddItem("Westminster Towers")
			AddItem("Underground Parking Garage")
			AddItem("Algonquin Safe House")
			AddItem("Scrapyard")
			AddItem("Construction Site")
			AddItem("Subway")
			AddItem("Sprunk Factory")
		elseif Menu.last_selected[0] == 6 then -- world options
			Menu.Title_Item_Set = "World"
			-- reset movie
			Menu.World_option.playmovie = false
			Game.StopMovie()
			Game.ReleaseMovie()

			AddItemBool("Display Pos xyzh", Menu.World_option.xyzh)
			AddItemBool("Display Time", Menu.World_option.time)
			AddItemSub("Weather & Time >")
			AddItemSub("Object throwable >")
			AddItemSub("Gang >")
			AddItemBool("Mute Gps", Menu.World_option.mutegps) 
			AddItemSub("Texture Viewer >")
			AddItemBool("Drive/Walk On Water", Menu.World_option.driveonwater)
			AddItemSub("Play Movie >")
			AddItemBool("Radio", Menu.World_option.radioOff)
		elseif Menu.last_selected[0] == 7 then --online players
			Menu.Title_Item_Set = "Online Players"
			Menu.InNetwork = false
			player_count = 0
			if Game.GetNumberOfPlayers() > 1 then
				for i = 0, MAX_PLAYERS do 
					if(Game.IsNetworkPlayerActive(i)) then
						if playerId ~= i then -- not display your gt 
							AddItemSub(""..Game.GetPlayerName(i).." >")

							Network.Id[player_count] = i
							Network.Index[player_count] = Player.GetServerID(i)
							Network.Name[player_count] = Game.GetPlayerName(i)
							player_count = player_count + 1
						end
					end
				end
			else
				Menu.Title_Item_Set = "Empty Player"
				Menu.InError = true	
			end
		elseif Menu.last_selected[0] == 8 then -- Menu options
			Menu.Title_Item_Set = "Menu Options"
			AddItemSub("Position >")
			AddItemSub("Controller >")
		elseif Menu.last_selected[0] == 9 then -- credits
			Menu.Title_Item_Set = "Credits"
			Menu.InError = true
			AddItem("Menu Base By :") 
			AddItem("LechapellierFou")
			AddItem("Style By : Al-Patch")
			AddItem(DateOfVersion)
			AddItemJumpOver("---------------------------------")
			AddItem("Testers :") 
			AddItem("BEASTDBA21") 
			AddItem("KOE") 
		end
	elseif menu_level == 2 then
		if Menu.last_selected[0] == 0 then -- player
			if Menu.last_selected[1] == 9 then -- annimations
				Menu.Title_Item_Set = "Annimations"
				
				AddItem("Stop Anims")
				for i=1,#AllAnims,1 do
					animation_Set[i] = AllAnims[i][1]
					AddItemSub(animation_Set[i])
				end
			elseif Menu.last_selected[1] == 10 then -- model changer
				Menu.Title_Item_Set = "Model Changer"
				AddItemSub("Original >")
				AddItemSub("Tlad >")
				AddItemSub("Tbogt >")
			end
		elseif Menu.last_selected[0] == 1 then -- vehicle
			if Menu.last_selected[1] == 15 then -- figure
				if(Game.IsCharInAnyCar(playerChar)) then
					Menu.Title_Item_Set = "Stunt"
					AddItem("Up")
					AddItem("Left")
					AddItem("Right")
					AddItem("Rear")
					AddItem("Front")
					AddItem("Demi-Tour")
					AddItem("Special")
				else
					Menu.Title_Item_Set = "Not available"
					Menu.InError = true	
				end
			end
		elseif Menu.last_selected[0] == 2 then -- Weapons Options
			if Menu.last_selected[1] == 0 then -- gta iv Weapons
				Menu.Title_Item_Set = "Select Weapons"
				local Weapon_name = {}
				local Weapon_id = {}
				local current_select = item_selected+1
				for i=1,#GTAIV_WEAPON,1 do --GTAIV_TBOGT_WEAPON
					Weapon_name[i] = GTAIV_WEAPON[i][1]
					Weapon_id[i] = GTAIV_WEAPON[i][2]
					AddItemHash(Weapon_name[i], Weapon_id[i])
				end
			elseif Menu.last_selected[1] == 1 then -- tbogt Weapons
				Menu.Title_Item_Set = "Tbogt Weapons"
				local Weapon_name = {}
				local Weapon_id = {}
				local current_select = item_selected+1
				for i=1,#GTAIV_TBOGT_WEAPON,1 do --
					Weapon_name[i] = GTAIV_TBOGT_WEAPON[i][1]
					Weapon_id[i] = GTAIV_TBOGT_WEAPON[i][2]
					AddItemHash(Weapon_name[i], Weapon_id[i])
				end
			elseif Menu.last_selected[1] == 2 then -- tlad Weapons
				Menu.Title_Item_Set = "Tlad Weapons"
				local Weapon_name = {}
				local Weapon_id = {}
				local current_select = item_selected+1
				for i=1,#GTAIV_TLAD_WEAPON,1 do --
					Weapon_name[i] = GTAIV_TLAD_WEAPON[i][1]
					Weapon_id[i] = GTAIV_TLAD_WEAPON[i][2]
					AddItemHash(Weapon_name[i], Weapon_id[i])
				end
			end
		elseif Menu.last_selected[0] == 3 then --"Spawn Cars"
			if Menu.last_selected[1] == 0 then -- Tbogt
				Menu.Title_Item_Set = "Tbogt"
				local Vehicle_name = {}
				local Vehicle_hash = {}
				for i=1,#TBOGT_MODEL_CAR,1 do --
					Vehicle_name[i] = TBOGT_MODEL_CAR[i][1]
					Vehicle_hash[i] = TBOGT_MODEL_CAR[i][2]
					AddItemHash(Vehicle_name[i], Vehicle_hash[i])
				end
			elseif Menu.last_selected[1] == 1 then -- Tlad
				Menu.Title_Item_Set = "Tlad"
				local Vehicle_name = {}
				local Vehicle_hash = {}
				for i=1,#TLAD_MODEL_CAR,1 do --
					Vehicle_name[i] = TLAD_MODEL_CAR[i][1]
					Vehicle_hash[i] = TLAD_MODEL_CAR[i][2]
					AddItemHash(Vehicle_name[i], Vehicle_hash[i])
				end
			elseif Menu.last_selected[1] == 2 then -- Sports
				Menu.Title_Item_Set = "Sports"
				AddItemHash("Bravado Banshee","BANSHEE")
				AddItemHash("Pfister Comet","COMET")
				AddItemHash("Invetero Coquette","COQUETTE")
				AddItemHash("Pegassi Infernus","INFERNUS")
				AddItemHash("Ubermacht Sentinel","SENTINEL")
				AddItemHash("Karin Sultan RS","SULTANRS")
				AddItemHash("Dewbauchee SuperGT","SUPERGT")
				AddItemHash("Grotti Turismo","TURISMO")
			elseif Menu.last_selected[1] == 3 then -- Muscle Cars
				Menu.Title_Item_Set = "Muscle Cars"
				AddItemHash("Albany Buccaneer","BUCCANEER")
				AddItemHash("Imponte Dukes","DUKES")
				AddItemHash("Willard Faction","FACTION")
				AddItemHash("Albany Manana","MANANA")
				AddItemHash("Vapid Peyote","PEYOTE")
				AddItemHash("Imponte Ruiner","RUINER")
				AddItemHash("Declasse Sabre","SABRE")
				AddItemHash("Declasse Sabre GT","SABREGT")
				AddItemHash("Classique Stallion","STALION")
				AddItemHash("Declasse Vigero","VIGERO")
				AddItemHash("Dundreary Virgo","VIRGO")
				AddItemHash("Declasse Voodoo","VOODOO")
			elseif Menu.last_selected[1] == 4 then -- 2 doors
				Menu.Title_Item_Set = "2 doors"
				AddItemHash("Karin Futo","FUTO")
				AddItemHash("Vapid Fortune","FORTUNE")
				AddItemHash("Dinka Blista","BLISTA")
				AddItemHash("Vapid Uranus","URANUS")
				AddItemHash("Benefactor Feltzer","FELTZER")
			elseif Menu.last_selected[1] == 5 then -- 4 Doors
				Menu.Title_Item_Set = "4 Doors"
				AddItemHash("Dundreary Admiral","ADMIRAL")
				AddItemHash("Dinka Chavos","CHAVOS")
				AddItemHash("Enus Cognoscenti","COGNOSCENTI")
				AddItemHash("Imponte DF8-90","DF8")
				AddItemHash("Karin Dilettante","DILETTANTE")
				AddItemHash("Albany Emperor","EMPEROR")
				AddItemHash("Albany Esperanto","ESPERANTO")
				AddItemHash("Bravado Feroci","FEROCI")
				AddItemHash("Dinka Hakumai","HAKUMAI")
				AddItemHash("Vulcar Ingot","INGOT")
				AddItemHash("Karin Intruder","INTRUDER")
				AddItemHash("Emperor Lokus","LOKUS")
				AddItemHash("Willard Marbelle","MARBELLA")
				AddItemHash("Declasse Merit","MERIT")
				AddItemHash("Ubermacht Oracle","ORACLE")
				AddItemHash("Annis Pinnacle","PINNACLE")
				AddItemHash("Schyster PMP 600","PMP600")
				AddItemHash("Declasse Premier","PREMIER")
				AddItemHash("Albany Presidente","PRES")
				AddItemHash("Albany Primo","PRIMO")
				AddItemHash("Albany Roman's Taxi","ROM")
				AddItemHash("Benefactor Schafter","SCHAFTER")
				AddItemHash("Willard Solair","SOLAIR")
				AddItemHash("Zirconium Stratum","STRATUM")
				AddItemHash("Maibatsu Vincent","VINCENT")
				AddItemHash("Willard Faction","WILLARD")
				AddItemHash("Albany Washington","WASHINGTON")
			elseif Menu.last_selected[1] == 6 then -- Rust Cars
				Menu.Title_Item_Set = "Rust Cars"
				AddItemHash("Albany Emperor","EMPEROR2")
				AddItemHash("Declasse Sabre","SABRE2")
				AddItemHash("Declasse Vigero","VIGERO2")
			elseif Menu.last_selected[1] == 7 then -- 4x4, Suvs, Vans
				Menu.Title_Item_Set = "4x4, Suvs, Vans"
				AddItemHash("Vapid Bobcat","BOBCAT")
				AddItemHash("Albany Cavalcade","CAVALCADE")
				AddItemHash("Albany Cavalcade FXT","FXT")
				AddItemHash("Vapid Contender","E109")
				AddItemHash("Emperor Habanero","HABANO")
				AddItemHash("Vapid Huntley Sport","HUNTLEY")
				AddItemHash("Dundreary Landstalker","LANDSTALTKER")
				AddItemHash("Vapid Minivan","MINIVAN")
				AddItemHash("Declasse Moonbeam","MOONBEAN")
				AddItemHash("Mammoth Patriot","PATRIOT")
				AddItemHash("Dinka Perennial","PERENIAL")
				AddItemHash("Declasse Rancher","RANCHER")
				AddItemHash("Ubermacht Rebla","REBLA")
			elseif Menu.last_selected[1] == 8 then 
				Menu.Title_Item_Set = "Commercials" -- Commercials
				AddItemHash("Airtug","AIRTUG")
				AddItemHash("Vapid Benson","BENSON")
				AddItemHash("HVY Biff","BIFF")
				AddItemHash("Brute Boxville","BOXVILLE")
				AddItemHash("Declasse Burrito","BURITO")
				AddItemHash("Declasse Burrito","BURITO2")
				AddItemHash("MTL Flatbed","FLATBED")
				AddItemHash("Bravado Feroci","FEROCI2")
				AddItemHash("Dinka Perennial FlyUS","PERENIAL2")
				AddItemHash("HVY Ripley","RIPLEY")
				AddItemHash("Brute Securicar","STOCKADE")
				AddItemHash("Vapid Speedo","SPEEDO")
				AddItemHash("Vapid Steed","STEED")
				AddItemHash("Vapid Yankee","YANKEE")
				AddItemHash("HVY Forklift","FORKLIFT")
				AddItemHash("Brute Pony","PONY")
				AddItemHash("Maibatsu Mule","MULE")
				AddItemHash("MTL Packer","PACKER")
				AddItemHash("JoBuilt Phantom","PHANTOM")
			elseif Menu.last_selected[1] == 9 then -- Emergency
				Menu.Title_Item_Set = "Emergency"
				AddItemHash("Brute Ambulance","AMBULANCE")
				AddItemHash("MTL Fire Truck","FIRETRUK")
				AddItemHash("Brute Enforcer","NSTOCKADE")
				AddItemHash("Vapid NOOSE Stanier","NOOSE")
				AddItemHash("Bravado FIB Buffalo","FBI")
				AddItemHash("Mammoth NOOSE Patriot","POLPATRIOT")
				AddItemHash("Declasse Police Merit","POLICE")
				AddItemHash("Vapid Police Stanier","POLICE2")
				AddItemHash("Brute Police Stockade","PSTOCKADE")
			elseif Menu.last_selected[1] == 10 then -- Services
				Menu.Title_Item_Set = "Services"
				AddItemHash("Brute Bus","BUS")
				AddItemHash("Schyster Cabby","CABBY")
				AddItemHash("Albany Romero","ROMERO")
				AddItemHash("Declasse Merit Taxi","TAXI")
				AddItemHash("Vapid Stanier Taxi","TAXI2")
				AddItemHash("Brute Trashmaster","TRASH")
				AddItemHash("Dundreary Stretch","STRETCH")
				AddItemHash("Brute Mr. Tasty","MRTASTY")
			elseif Menu.last_selected[1] == 11 then -- Motorcycles
				Menu.Title_Item_Set = "Motorcycles"
				AddItemHash("Principe Faggio","FAGGIO")
				AddItemHash("WMC Freeway","BOBBER")
				AddItemHash("Hellfury","HELLFURY")
				AddItemHash("LCC Zombie","ZOMBIEB")
				AddItemHash("Maibatsu Sanchez","SANCHEZ")
				AddItemHash("Shitzu NRG 900","NRG900")
				AddItemHash("Shitzu PCJ 600","PCJ")
			elseif Menu.last_selected[1] == 12 then -- Boats
				Menu.Title_Item_Set = "Boats"
				AddItemHash("Nagasaki Dinghy","DINGHY")
				AddItemHash("Grotti Jetmax","JETMAX")
				AddItemHash("Dinka Marquis","MARQUIS")
				AddItemHash("Police Predator","PREDATOR")
				AddItemHash("Reefer","REEFER")
				AddItemHash("Grotti Squalo","SQUALO")
				AddItemHash("Grotti Tropic","TROPIC")
				AddItemHash("Buckingham Tug","TUGA")
			elseif Menu.last_selected[1] == 13 then -- Aircraft
				Menu.Title_Item_Set = "Aircraft"
				AddItemHash("Western Annihilator","ANNIHILATOR")
				AddItemHash("Western Maverick","MAVERICK")
				AddItemHash("Western Helitours Maverick","TOURMAV")
				AddItemHash("Western Police Maverick","POLMAV")
			elseif Menu.last_selected[1] == 14 then -- others
				Menu.Title_Item_Set = "Others"
				AddItemHash("Subway 1","SUBWAY_HI")
				AddItemHash("Subway 2","SUBWAY_LO")
				AddItemHash("Cablecar","CABLECAR")
			end
		elseif Menu.last_selected[0] == 4 then -- garage
			if Menu.last_selected[1] == 0 then -- paint
				if Game.IsCharInAnyCar(playerChar) then
					Menu.Title_Item_Set = "Colours"
					in_paint = true
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local ColorC1, ColorC2 = Game.GetCarColours(playerCar)
					local ColorC3, ColorC4 = Game.GetExtraCarColours(playerCar)
					local CarModel = Game.GetCarModel(playerCar)

					AddColorPaint("Colour 1", ColorC1, 134)
					AddColorPaint("Colour 2", ColorC2, 134)
					AddColorPaint("Colour 3", ColorC3, 134)
					AddColorPaint("Colour 4", ColorC4, 134)
					AddItemSub("Specials >")
				else
					in_paint = false
					Menu.InError = true
					Menu.Title_Item_Set = "not vehicle"
				end
			elseif Menu.last_selected[1] == 1 then -- extra
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					Menu.Title_Item_Set = "Extras"
					AddItemBool("Extra 1", Game.IsVehicleExtraTurnedOn(playerCar, 0))
					AddItemBool("Extra 2", Game.IsVehicleExtraTurnedOn(playerCar, 1))
					AddItemBool("Extra 3", Game.IsVehicleExtraTurnedOn(playerCar, 2))
					AddItemBool("Extra 4", Game.IsVehicleExtraTurnedOn(playerCar, 3))
					AddItemBool("Extra 5", Game.IsVehicleExtraTurnedOn(playerCar, 4))
					AddItemBool("Extra 6", Game.IsVehicleExtraTurnedOn(playerCar, 5))
					AddItemBool("Extra 7", Game.IsVehicleExtraTurnedOn(playerCar, 6))
					AddItemBool("Extra 8", Game.IsVehicleExtraTurnedOn(playerCar, 7))
					AddItemBool("Extra 9", Game.IsVehicleExtraTurnedOn(playerCar, 8))
					AddItemBool("Extra 10", Game.IsVehicleExtraTurnedOn(playerCar, 9))
				else
					Menu.InError = true
					Menu.Title_Item_Set = "not vehicle"
				end
			elseif Menu.last_selected[1] == 2 then -- neon object
				if Game.IsCharInAnyCar(playerChar) then
					Menu.Title_Item_Set = "Neons (obj)"
					AddItem("Delete Alls Objects On Car")
					AddItem("Bleu")
					AddItem("Red")
					AddItem("White")
					AddItemJumpOver("---------- Tbogt only ----------")
					AddItem("Orange")
					AddItem("Yellow")
					AddItem("Green")
				else
					Menu.InError = true
					Menu.Title_Item_Set = "not vehicle"
				end
			elseif Menu.last_selected[1] == 3 then
				if(Game.IsCharInAnyCar(playerChar)) then 
					Title_Item_Set = "Doors"
					AddItem("Driver")
					AddItem("Front Right")
					AddItem("Rear Left")
					AddItem("Rear Right")
					AddItem("Hood")
					AddItem("Trunk")
					AddItem("Close All")
					AddItem("Detach All")
				else
					Menu.Title_Item_Set = "Not available"
					Menu.InError = true	
				end
			end	
		elseif Menu.last_selected[0] == 5 then -- teleport menu
			if Menu.last_selected[1] == 0 then -- Save pos as blip
				Menu.Title_Item_Set = "Save pos as blip"
				AddItem("Save your pos")
				AddItem("Tp to last pos")
				AddItem("Remove")
			end
		elseif Menu.last_selected[0] == 6 then -- world options
			if Menu.last_selected[1] == 2 then -- weather
				Menu.Title_Item_Set = "Weather & Time"
				AddItem("8 h 00")
				AddItem("12 h 00")
				AddItem("20 h 00")
				AddItemBool("Gravity to 0", Menu.World_option.gravity)
				AddItemBool("Force Wind", Menu.World_option.wind)
				AddItemBool("Slow Motion", Menu.World_option.slowmotion)
				AddItemJumpOver("---------------------------------")
				AddItemHash("Extra Sunny",0)
				AddItemHash("Sunny",1)
				AddItemHash("Sunny and Windy",2)
				AddItemHash("Cloudy",3)
				AddItemHash("Raining",4)
				AddItemHash("Drizzle",5)
				AddItemHash("Foggy",6)
				AddItemHash("Thunderstorm",7)
				AddItemHash("Extra Sunny 2",8)
				AddItemHash("Sunny and Windy 2",9)
			elseif Menu.last_selected[1] == 3 then -- object throwable
				Menu.Title_Item_Set = "Objects Throwable"
				AddItem("Delete All Objects")
				AddItemJumpOver("---------------------------------")
				AddItem("x6 Cube color")
				AddItem("Dildo")
				AddItem("Axe")
				AddItem("Bowling Pin")
				AddItem("Sprunk Box")	
				AddItem("TV")
				AddItem("Bowling Ball")
				AddItem("Gumball Machine")
			elseif Menu.last_selected[1] == 4 then -- gang
				Menu.Title_Item_Set = "Gang"
				AddItemSub("Add members >")
				AddItemSub("Options >")
				AddItemSub("Give Weapons >")
				AddItemSub("Give Animations >")
			elseif Menu.last_selected[1] == 6 then -- textures viewer
				Menu.Title_Item_Set = "Texture Viewer .wtd"
				Menu.TextureViewer = false
				
				for i=1,#WTD_TEXTURES,1 do 
					Texture_Set[i] = WTD_TEXTURES[i][1]
					AddItemSub(Texture_Set[i].." >")
					if Dictionary ~= nil then 
						Game.RemoveTxd(Dictionary)
						Dictionary = nil
					end
				end
			elseif Menu.last_selected[1] == 8 then
				Menu.Title_Item_Set = "Movies"
				Menu.World_option.playmovie = true
				AddItem("weazel")
				AddItem("CNT")
				AddItem("static")
				AddItem("burgershot nosound")
				AddItem("static nosound")
			end
		elseif Menu.last_selected[0] == 7 then -- online players
			if Menu.last_selected[1] >= 0 then -- network list
				local index = Menu.last_selected[(menu_level - 1)]
				local netid = Network.Id[index]
				Menu.Title_Item_Set = Game.GetPlayerName(netid)
				AddItem("Tp to player")
				AddItem("Tp on foot (host only)")
				AddItem("Kick Player (host only)")
			end
		elseif Menu.last_selected[0] == 8 then -- Menu options
			if Menu.last_selected[1] == 0 then --position 
				Menu.Title_Item_Set = "Position"
				AddItem("Right") 
				AddItem("Centre") 
				AddItem("Left") 
			elseif Menu.last_selected[1] == 1 then --controller 
				Menu.Title_Item_Set = "Controls"
				AddItem("Keyboard (default)") 
				AddItem("Mouse") 
				AddItem("Gamepad") 
			end
		end
	elseif menu_level == 3 then
		if Menu.last_selected[0] == 0 then -- joueur
			if Menu.last_selected[1] == 9 then -- annimations
				local last_item_selected = Menu.last_selected[menu_level-1]+1
				Menu.Title_Item_Set = animation_Set[last_item_selected-1]
				
				-- amb@next_club 19 name of anim
				for i=2,22,1 do
					if AllAnims[last_item_selected][i] ~= nil then
						animation_Name[i] = AllAnims[last_item_selected][i]
						AddItem(animation_Name[i])
					end
				end
			elseif Menu.last_selected[1] == 10 then -- model changer
				if Menu.last_selected[2] == 0 then -- original models
					Menu.Title_Item_Set = "Models Original"
					local Model_episode_0 = {}
					for i=1,#GTAIV_PLAYER_MODELS,1 do
						Model_episode_0[i] = GTAIV_PLAYER_MODELS[i][1]
						AddItem(Model_episode_0[i])
					end
				elseif Menu.last_selected[2] == 1 then -- tlad models
					Menu.Title_Item_Set = "Models Tlad"
					local Model_episode_1 = {}
					for i=1,#TLAD_PLAYER_MODELS,1 do
						Model_episode_1[i] = TLAD_PLAYER_MODELS[i][1]
						AddItem(Model_episode_1[i])
					end
				elseif Menu.last_selected[2] == 2 then -- tbogt models
					Menu.Title_Item_Set = "Models Tbogt"
					local Model_episode_2 = {}
					for i=1,#TBOGT_PLAYER_MODELS,1 do
						Model_episode_2[i] = TBOGT_PLAYER_MODELS[i][1]
						AddItem(Model_episode_2[i])
					end
				end
			end
		elseif Menu.last_selected[0] == 4 then -- garage
			if Menu.last_selected[1] == 0 then -- paint
				if Menu.last_selected[2] == 4 then -- Colours 
					Menu.Title_Item_Set = "Colours"
					in_paint = false
					AddItem("Gold")	
					AddItem("Cream")		
					AddItem("Chocolate")		
					AddItem("Grape")				
					AddItem("Magenta")			
					AddItem("Blackcurrant")		
					AddItem("Stinger")			
					AddItem("Silver")			
					AddItem("Metallic Red")	
					AddItem("Neon Blue")		
					AddItem("Royal Blue")		
					AddItem("Silvery Blue")	
					AddItem("Electric Blue")		
					AddItem("Champagne")			
					AddItem("Pine")			
					AddItem("Spearmint")	
				end
			end
		elseif Menu.last_selected[0] == 6 then -- world options
			if Menu.last_selected[1] == 4 then -- gang options
				if Menu.last_selected[2] == 0 then -- add members
					Menu.Title_Item_Set = "Add members"
					AddItemHash("Jew","M_O_HASID_01")
					AddItemHash("Lil Jacob","IG_LILJACOB")
					AddItemHash("Brucie","IG_BRUCIE")
					AddItemHash("Nigga","M_Y_GAFR_LO_01")
					AddItemHash("Multiplayer Male","M_Y_MULTIPLAYER")
					AddItemHash("Multiplayer Female","F_Y_MULTIPLAYER")
					AddItemHash("Army Guy","M_M_GUNNUT_01")
					AddItemHash("Club","M_Y_CLUBFIT")
					AddItemHash("Stripper","F_Y_STRIPPERC01")
					AddItemHash("Suited","M_Y_GMAF_HI_02")
					AddItemHash("Thief","M_Y_THIEF")
				elseif Menu.last_selected[2] == 1 then -- options
					Menu.Title_Item_Set = "Add members"
					AddItem("Delete all")
					AddItem("Tp all on you")
					AddItemJumpOver("---------------------------------")
					AddItemNumber("Formation :", 1, 3)
					AddItemNumber("Spacing :", 1, 8)
				elseif Menu.last_selected[2] == 2 then -- Select Weapons
					Menu.Title_Item_Set = "Give Weapons"
					AddItemHash("Fist", 0)
					AddItemHash("Baseball bat", 1)
					AddItemHash("Knife", 3)
					AddItemHash("Pool cue", 2)
					AddItemHash("Grenade ", 4)
					AddItemHash("Molotof", 5)
					AddItemHash("Rocket Launcher", 18)
					AddItemHash("Combat Pistol", 7)
					AddItemHash("Desert eagle", 9)
					AddItemHash("Pump Shotgun", 10)
					AddItemHash("Combat Shotgun", 11)
					AddItemHash("Carabine Rifle", 15)
					AddItemHash("Assault Rifle", 14)
					AddItemHash("Smg", 13)
					AddItemHash("Micro-Uzi", 12)
					AddItemHash("Sniper Rifle", 18)
					AddItemHash("Combat Sniper", 16)
				elseif Menu.last_selected[2] == 3 then -- annimation 
					Menu.Title_Item_Set = "Give Anims"
					AddItem("Stop All Tasks")
					AddItemNumber("Taichi", 1, 2)
					AddItemNumber("Male Dance", 1, 4)
					AddItemNumber("Female Dance", 1, 3)
				end
			elseif Menu.last_selected[1] == 6 then -- texture viewer
				if Menu.last_selected[2] >= 0 then 
					local last_item_selected = Menu.last_selected[2]
					Menu.Title_Item_Set = Texture_Set[last_item_selected+1]
					Menu.TextureViewer = true
					
					for i=2,50,1 do
						if WTD_TEXTURES[last_item_selected+1][i] ~= nil then
							Texture_Name[i] = WTD_TEXTURES[last_item_selected+1][i]
							AddItem(Texture_Name[i])
						end
					end
				end
			end
		end
	end
end

local function menu_startup()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local playerIndex = Game.ConvertIntToPlayerindex(playerId)

	Menu.isOpen = true
	menu_level = 0
	item_selected = 0
	Style_Setup()
	menu_setup()
	menu_consts_start_y = Menu.menu_posY
	menu_consts_max = menu_max
	press_counter = 2

	if(Menu.controlOfMenu == 1) then
		Game.SetPlayerControlForNetwork(playerIndex, false, false)
	end
	NetworkTexture = Game.LoadTxd("network")
end

local function menu_shutdown()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local playerIndex = Game.ConvertIntToPlayerindex(playerId)

	Menu.isOpen = false
	menu_level = 0
	item_selected = 0
	Game.SetPlayerControlForNetwork(playerIndex, true, false)

	Game.RemoveTxd(NetworkTexture)
end

local function ReloadMenu()
	ResetMenu()
	menu_setup()
end

local function menu_function()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local playerIndex = Game.ConvertIntToPlayerindex(playerId)

	if menu_level == 1 then
		if Menu.last_selected[0] == 0 then -- player function
			if item_selected == 0 then
				if not Menu.Player_option.godmod then
					Menu.Player_option.godmod = true
				else 
					Menu.Player_option.godmod = false
					Game.SetPlayerInvincible(playerIndex, false)
				end
				ReloadMenu()
			elseif item_selected == 1 then
				if not Menu.Player_option.freezeped then
					Menu.Player_option.freezeped = true
				else 
					Menu.Player_option.freezeped = false
					Game.FreezeCharPosition(playerChar, false)
				end
				ReloadMenu()
			elseif item_selected == 2 then
				if not Menu.Player_option.invisible then
					Menu.Player_option.invisible = true
				else 
					Menu.Player_option.invisible = false
					Game.SetCharVisible(playerChar, true)
				end
				ReloadMenu()
			elseif item_selected == 3 then
				if not Menu.Player_option.nocolision then
					Menu.Player_option.nocolision = true
				else 
					Menu.Player_option.nocolision = false
					Game.SetCharCollision(playerChar, true)
				end
				ReloadMenu()
			elseif item_selected == 4 then
				if not Menu.Player_option.neverwanted then
					Menu.Player_option.neverwanted = true
				else 
					Menu.Player_option.neverwanted = false
				end
				ReloadMenu()
			elseif item_selected == 5 then
				Game.ClearWantedLevel(playerId)
				Game.AlterWantedLevel(playerId, 6)-- max
				Game.ApplyWantedLevelChangeNow(playerId)
				Print("6 Stars, Run !!!!!!", 1000)
			elseif item_selected == 6 then
				Game.ClearWantedLevel(playerId)
				Game.AlterWantedLevel(playerId, 0)-- max
				Game.ApplyWantedLevelChangeNow(playerId)
				Print("Clear Wanted Level", 1000)
			elseif item_selected == 7 then
				Game.SetCharRandomComponentVariation(playerChar)
				Print("Random Clothes", 1000)
			elseif item_selected == 8 then
				if Game.GetCurrentEpisode() == 0 then
					AddSkinZombie()
				else
					Print("Only episode 0", 1000)
				end
			elseif item_selected == 11 then
				if not HelmetPed then 
					Game.GivePedHelmet(playerChar)
					HelmetPed = true
				else
					Game.RemovePedHelmet(playerChar, true)
					HelmetPed = false
				end
			elseif item_selected == 12 then
				Game.SetCharHealth(playerChar, 200)
				Game.AddArmourToChar(playerChar, 100)
			end
		elseif Menu.last_selected[0] == 1 then -- vehicle function
			if item_selected == 0 then	
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if not Menu.Vehicle_option.godmodcar then
						Menu.Vehicle_option.godmodcar = true
					else 
						Menu.Vehicle_option.godmodcar = false
						Game.SetCarCanBeDamaged(playerCar,true)
						Game.SetCarCanBeVisiblyDamaged(playerCar,true)
						Game.SetCanBurstCarTyres(playerCar,true)
						Game.SetCarProofs(playerCar, false, false, false, false, false)
					end
					ReloadMenu()
				end
			elseif item_selected == 1 then	
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local DriverCar = Game.GetDriverOfCar(playerCar)
					if DriverCar == playerChar then
						Game.FixCar(playerCar)
					end
				end
			elseif item_selected == 2 then
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local DriverCar = Game.GetDriverOfCar(playerCar)
					if DriverCar == playerChar then
						Game.DeleteCar(playerCar)
					end
				end
			elseif item_selected == 3 then
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local DriverCar = Game.GetDriverOfCar(playerCar)
					local HeadingCar = Game.GetCarHeading(playerCar)
					if DriverCar == playerChar then
						-- usable all vehicle type 
						Game.SetVehicleQuaternion(playerCar, 0, 0, 0, 0)
						Game.SetCarHeading(playerCar, HeadingCar)
					end
				end
			elseif item_selected == 4 then
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if not Menu.Vehicle_option.lockcar then
						Menu.Vehicle_option.lockcar = true
						Game.LockCarDoors(playerCar, 4) -- ImpossibleToOpen
						Print("Vehicle Locked !", 1000)
					else 
						Menu.Vehicle_option.lockcar = false
						Game.LockCarDoors(playerCar, 1) -- unlock 
						Print("Vehicle Unlock !", 1000)
					end
				end
			elseif item_selected == 5 then
				local playerCar = Game.GetCarCharIsUsing(playerChar)
				if not Menu.Vehicle_option.invisiblecar then
					Menu.Vehicle_option.invisiblecar = true
				else 
					Menu.Vehicle_option.invisiblecar = false
				end
				ReloadMenu()
			elseif item_selected == 6 then
				if not Menu.Vehicle_option.nocollisioncar then
					Menu.Vehicle_option.nocollisioncar = true
				else 
					Menu.Vehicle_option.nocollisioncar = false
				end
				ReloadMenu()
			elseif item_selected == 7 then
				if not Menu.Vehicle_option.freezecar then
					Menu.Vehicle_option.freezecar = true
				else 
					Menu.Vehicle_option.freezecar = false
				end
				ReloadMenu()
			elseif item_selected == 8 then
				local playerCar = Game.GetCarCharIsUsing(playerChar)
				if not Menu.Vehicle_option.driftmode then
					Menu.Vehicle_option.driftmode = true
				else 
					Menu.Vehicle_option.driftmode = false
				end
				ReloadMenu()
			elseif item_selected == 9 then
				if not Menu.Vehicle_option.speedometer then
					Menu.Vehicle_option.speedometer = true
				else 
					Menu.Vehicle_option.speedometer = false	
				end
				ReloadMenu()
			elseif item_selected == 10 then
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					Game.TaskShuffleToNextCarSeat(playerChar, playerCar)
				end
			elseif item_selected == 11 then
				if Game.IsCharInAnyCar(playerChar) then	
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					Game.ApplyForceToCar(playerCar, 1, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0, true, true, true)
				end
			elseif item_selected == 12 then
				if Game.IsCharInAnyCar(playerChar) then	
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local SpeedVeh = Game.GetCarSpeed(playerCar)
					local nspeed = 0
					nspeed = SpeedVeh*2
					
					Game.SetCarForwardSpeed(playerCar, nspeed)
				end
			elseif item_selected == 13 then
				if Game.IsCharInAnyCar(playerChar) then	
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					Game.SetVehicleDirtLevel(playerCar, 0.0)
				end
			elseif item_selected == 14 then
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					Game.DamageCar(playerCar, -0.4, 0, 0, 500.0, 500.0, true)
					Game.DamageCar(playerCar, 0.4, 0, 0, 500.0, 500.0, true)
					Game.DamageCar(playerCar, 0.0, -0.4, 0, 500.0, 500.0, true)
					Game.DamageCar(playerCar, 0.0, 0.4, 0, 500.0, 500.0, true)
				end
			end
		elseif Menu.last_selected[0] == 2 then -- weapon function 
			if item_selected == 3 then
				if not Menu.Weapon_option.rapidfire then
					Menu.Weapon_option.rapidfire = true
				else 
					Menu.Weapon_option.rapidfire = false
					Game.SetCharAllAnimsSpeed(playerChar, 1)
					Game.EnableMaxAmmoCap(true)
				end
				ReloadMenu()
			end
		elseif Menu.last_selected[0] == 5 then -- teleport
			if item_selected == 1 then 
				local pos = table.pack(Game.GetCharCoordinates(playerChar))
				local ph = Game.GetCharHeading(playerChar)
				Teleport_Char(playerChar, pos[1]+(5*Game.Sin((-1*ph))), pos[2]+(5*Game.Cos((-1*ph))), pos[3])
			elseif item_selected == 2 then 
				Teleport_Char(playerChar,2175.3516,761.2235,30.0)
			elseif item_selected == 3 then
				Teleport_Char(playerChar,1100.5,-747.0,7.39)
			elseif item_selected == 4 then
				Teleport_Char(playerChar,-178.2,582.6,126.85)
			elseif item_selected == 5 then
				Teleport_Char(playerChar,-2476.0,942.7,1100.0)
			elseif item_selected == 6 then
				Teleport_Char(playerChar,-236.0,795.9,6.20)
			elseif item_selected == 7 then
				Teleport_Char(playerChar,-415.17,1463.54,39.0)
			elseif item_selected == 8 then
				Teleport_Char(playerChar,-279.77,-99.66,386.791)
			elseif item_selected == 9 then
				Teleport_Char(playerChar,-1079.8,-469.7,2.62)
			elseif item_selected == 10 then
				Teleport_Char(playerChar,1375.8765,197.4544,48.0)
			elseif item_selected == 11 then
				Teleport_Char(playerChar,-532.681,1273.3307,105.65)
			elseif item_selected == 12 then
				Teleport_Char(playerChar,55.3537,1125.3387,2.4527)
			elseif item_selected == 13 then
				Teleport_Char(playerChar,104.13,856.53,45.58)
			elseif item_selected == 14 then
				Teleport_Char(playerChar,-473.0176,1746.8829,6.26)
			elseif item_selected == 15 then
				Teleport_Char(playerChar,237.5457,-805.6555,13.7)
			elseif item_selected == 16 then
				Teleport_Char(playerChar,-3.4734,270.6067,-2.9470)
			elseif item_selected == 17 then
				Teleport_Char(playerChar,-1539.8414,163.2967,9.9000)
			end
		elseif Menu.last_selected[0] == 6 then -- world 
			if item_selected == 0 then	
				if not Menu.World_option.xyzh then
					Menu.World_option.xyzh = true
				else 
					Menu.World_option.xyzh = false
				end
				ReloadMenu()
			elseif item_selected == 1 then	
				if not Menu.World_option.time then
					Menu.World_option.time = true
				else 
					Menu.World_option.time = false
				end
				ReloadMenu()
			elseif item_selected == 5 then	
				if not Menu.World_option.mutegps then
					Menu.World_option.mutegps = true
				else 
					Menu.World_option.mutegps = false
				end
				ReloadMenu()
			elseif item_selected == 7 then	
				if not Menu.World_option.driveonwater then
					Menu.World_option.driveonwater = true
				else 
					Menu.World_option.driveonwater = false
					if(Game.DoesObjectExist(thingy)) then Game.DeleteObject(thingy) end
				end
				ReloadMenu()
			elseif item_selected == 9 then	
				if not Menu.World_option.radioOff then
					Menu.World_option.radioOff = true
				else 
					Menu.World_option.radioOff = false
					Game.EnableFrontendRadio()
					Game.SetMobileRadioEnabledDuringGameplay(false)
					Game.SetMobilePhoneRadioState(false)
				end
				ReloadMenu()
			end
		end
	elseif menu_level == 2 then
		if Menu.last_selected[0] == 0 then -- player
			if Menu.last_selected[1] == 9 then -- annimations
				if(item_selected == 0) then
					Game.ClearCharTasksImmediately(playerChar)
				end
			end
		elseif Menu.last_selected[0] == 1 then -- vehicle
			if Menu.last_selected[1] == 15 then -- figure
				if(Game.IsCharInAnyCar(playerChar)) then 
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if item_selected == 0 then 
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 6.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 1 then 
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, 1.50000000, 0.00000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 2 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, -1.50000000, 0.00000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 3 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 2.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, 0.00000000, -1.50000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 4 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 2.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, 0.00000000, 1.50000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 5 then
						for i=0, 6, 1 do
							local forcex = math.sin(i*60*math.pi/180)		
							local forcey = math.cos(i*60*math.pi/180)	
							Game.ApplyForceToCar(playerCar, 3, -forcex, -forcey, 0, -10, 0, 0, 0, true, true, true)
							Game.SetCarForwardSpeed(playerCar, -5)
						end
					elseif item_selected == 6 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 2.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, -1.50000000, 0.00000000, 0.00000000, 0, true, true, true)
					end
				elseif(Game.IsCharOnAnyBike(playerChar)) then 
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if item_selected == 0 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 6.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 1 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 2.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, 0.00000000, -1.50000000, 0.00000000, 0, true, true, true)
					elseif item_selected == 2 then
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 2.00000000, 0.00000000, 0.00000000, 0.00000000, 0, true, true, true)
						Game.ApplyForceToCar(playerCar, 1, 0.00000000, 0.00000000, 5.00000000, 0.00000000, 1.50000000, 0.00000000, 0, true, true, true)
					end
				end
			end
		elseif Menu.last_selected[0] == 2 then --weapon select, gta iv, tbogt, tlad
			local modelWep = Menu.extra_val[item_selected]
			Game.GiveWeaponToChar(playerChar, modelWep, 500, false)
			Game.SetCurrentCharWeapon(playerChar, modelWep, true)
			--Game.SetCurrentCharWeapon(playerChar, 0, true)
		elseif Menu.last_selected[0] == 3 then --"Spawn Cars"
			if Menu.last_selected[1] >= 0 and Menu.last_selected[1] <= 1 then -- tbogt and tlad
				AutoDelVeh()
				Spawn_Car(Menu.extra_val[item_selected])-- hash of veh 
			else -- original veh
				AutoDelVeh()
				local modelPc = Game.GetHashKey(Menu.extra_val[item_selected])-- name of veh
				Spawn_Car(modelPc)
			end
		elseif Menu.last_selected[0] == 4 then -- garage
			if Menu.last_selected[1] == 1 then -- extra
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					ExtraAction(item_selected)
					ReloadMenu()
				end
			elseif Menu.last_selected[1] == 2 then -- neon object
				if Game.IsCharInAnyCar(playerChar) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if item_selected == 0 then
						clear_objects_on_car(playerCar)
					elseif item_selected == 1 then -- blue
						--Events.Call("LoadModelFromCdimage", {0xD20167BE} )
						AttachObjecttocar(0xD20167BE, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0) -- front
						AttachObjecttocar(0xD20167BE, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) -- center
						AttachObjecttocar(0xD20167BE, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0) -- rear
					elseif item_selected == 2 then -- red
						--Events.Call("LoadModelFromCdimage", {0xCB26803D} )
						AttachObjecttocar(0xCB26803D, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xCB26803D, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xCB26803D, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0) 
					elseif item_selected == 3 then -- white
						--Events.Call("LoadModelFromCdimage", {0xFCB32869} )
						AttachObjecttocar(0xFCB32869, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0)
						AttachObjecttocar(0xFCB32869, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xFCB32869, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0) 
					elseif item_selected == 5 then -- orange
						--Events.Call("LoadModelFromCdimage", {0x2F8AEA79} )
						AttachObjecttocar(0x2F8AEA79, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0x2F8AEA79, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0x2F8AEA79, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0)
					elseif item_selected == 6 then -- yellow
						--Events.Call("LoadModelFromCdimage", {0xB3AC6409} )
						AttachObjecttocar(0xB3AC6409, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xB3AC6409, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xB3AC6409, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0)
					elseif item_selected == 7 then -- green
						--Events.Call("LoadModelFromCdimage", {0xD611D7B6} )
						AttachObjecttocar(0xD611D7B6, playerCar,  -0.0103, 0.7348, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xD611D7B6, playerCar, -0.0103, -1.0130, -0.1368, -1.5365, 0, 0) 
						AttachObjecttocar(0xD611D7B6, playerCar, -0.0103, -1.1795, -0.1368, 1.6107, 0, 0)	
					end
				end
			elseif Menu.last_selected[1] == 3 then
				-- only car 
				if((not Game.IsCharInAnyBoat(playerChar)) and (not Game.IsCharInAnyHeli(playerChar)) and (not Game.IsCharOnAnyBike(playerChar))) then
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					if item_selected == 0 then -- driver
						ControleDoor(playerCar, 0)
					elseif item_selected == 1 then -- front right
						ControleDoor(playerCar, 1)
					elseif item_selected == 2 then -- rear left
						ControleDoor(playerCar, 2)
					elseif item_selected == 3 then -- rear right
						ControleDoor(playerCar, 3)
					elseif item_selected == 4 then -- hood/capot
						ControleDoor(playerCar, 4)
					elseif item_selected == 5 then -- trunk/coffre
						ControleDoor(playerCar, 5)
					elseif item_selected == 6 then -- close all door
						Game.CloseAllCarDoors(playerCar)
					elseif item_selected == 7 then -- detach all door
						Game.BreakCarDoor(playerCar, 0, false)
						Game.BreakCarDoor(playerCar, 1, false)
						Game.BreakCarDoor(playerCar, 2, false)
						Game.BreakCarDoor(playerCar, 3, false)
						Game.BreakCarDoor(playerCar, 4, false)
						Game.BreakCarDoor(playerCar, 5, false)
					end
				end
			end
		elseif Menu.last_selected[0] == 5 then -- teleport
			if Menu.last_selected[1] == 0 then -- options blip
				if item_selected == 0 then
					if not Game.DoesBlipExist(Teleport_Blip) then
						Teleport_Blip = SavePosWithBlip()
					end
				elseif item_selected == 1 then
					if Game.DoesBlipExist(Teleport_Blip) then
						local pos = table.pack(Game.GetBlipCoords(Teleport_Blip))
						Events.Call("Teleport_Char", {playerChar, pos[1], pos[2], pos[3]})
					end
				elseif item_selected == 2 then
					if Game.DoesBlipExist(Teleport_Blip) then
						Game.RemoveBlip(Teleport_Blip)
					end
				end
			end
		elseif Menu.last_selected[0] == 6 then -- world options
			if Menu.last_selected[1] == 2 then -- weather
				--local hour, min = Game.GetTimeOfDay()
				if item_selected == 0 then
					Game.SetTimeOfDay(8, 0)
				elseif item_selected == 1 then
					Game.SetTimeOfDay(12, 0)
				elseif item_selected == 2 then
					Game.SetTimeOfDay(20, 0)
				elseif item_selected == 3 then	
					if not Menu.World_option.gravity then
						Menu.World_option.gravity = true
					else 
						Menu.World_option.gravity = false
						Game.SetGravityOff(false)
					end
					ReloadMenu()
				elseif item_selected == 4 then	
					if not Menu.World_option.wind then
						Menu.World_option.wind = true
					else 
						Menu.World_option.wind = false
						Game.ForceWind(0.0)
					end
					ReloadMenu()
				elseif item_selected == 5 then	
					if not Menu.World_option.slowmotion then
						Menu.World_option.slowmotion = true
					else 
						Menu.World_option.slowmotion = false
						Game.SetTimeScale(1.0)
					end
					ReloadMenu()
				elseif item_selected >= 7 and item_selected <= 16 then
					Game.ForceWeatherNow(Menu.extra_val[item_selected])
					Print("Weather Changed To :"..Menu.item_name[item_selected], 2500)
				end
			elseif Menu.last_selected[1] == 3 then -- object throwable
				local pos = table.pack(Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId())))
				if item_selected == 0 then
					clear_objects_near()
					return
				elseif item_selected == 2 then
					create_throwable_object(0x2718C626, pos[1], pos[2], pos[3])
					create_throwable_object(0xDD28B247, pos[1], pos[2] + 1.5,  pos[3])
					create_throwable_object(0xCCEA11CA, pos[1], pos[2] + ( 1.5 * 2), pos[3])
					create_throwable_object(0xBB1F6E71, pos[1], pos[2] + ( 1.5 * 3), pos[3])
					create_throwable_object(0xA6E545FD, pos[1], pos[2] + ( 1.5 * 4), pos[3])
					create_throwable_object(0x5C5030D4, pos[1], pos[2] + ( 1.5 * 5), pos[3])
				elseif (item_selected == 3) then 
					create_throwable_object(0x9976ECC4, pos[1], pos[2], pos[3])
				elseif (item_selected == 4) then 
					create_throwable_object(0x3129B913, pos[1], pos[2], pos[3])
				elseif (item_selected == 5) then 
					create_throwable_object(0xF4A206E4, pos[1], pos[2], pos[3])
				elseif (item_selected == 6) then 
					create_throwable_object(0x7FC5F693, pos[1], pos[2], pos[3])
				elseif (item_selected == 7) then 
					create_throwable_object(0xD318157E, pos[1], pos[2], pos[3])
				elseif (item_selected == 8) then 
					create_throwable_object(0x90FA92C6, pos[1], pos[2], pos[3])
				elseif (item_selected == 9) then 
					create_throwable_object(0x6066DF1D, pos[1], pos[2], pos[3])
				end 
			elseif Menu.last_selected[1] == 8 then -- movies
				if item_selected == 0 then 
					LoadMovie("weazel", 0)
				elseif item_selected == 1 then 
					LoadMovie("CNT", 0)
				elseif item_selected == 2 then 
					LoadMovie("static", 0)
				elseif item_selected == 3 then 
					LoadMovie("burgershot_nosound", 0)
				elseif item_selected == 4 then 
					LoadMovie("static_nosound", 0)
				elseif item_selected == 5 then 
					LoadMovie("static", 0)
				end
			end
		elseif Menu.last_selected[0] == 7 then -- online players
			if Menu.last_selected[1] >= 0 then -- network
				local index = Menu.last_selected[(menu_level - 1)]-- item count
				local netid = Network.Index[index] -- Player.GetServerID(i), L.650
				local nid = Network.Id[index] -- player id, L.649
				local Online_players = Player.GetIDFromServerID(tonumber(netid))
				local PlayerPedNet = Game.GetPlayerChar(Online_players)


				if Game.IsNetworkPlayerActive(nid) then
					if item_selected == 0 then
						if Game.DoesCharExist(PlayerPedNet) then 
							local pos = table.pack(Game.GetCharCoordinates(PlayerPedNet))
							if Game.IsCharInAnyCar(PlayerPedNet) then
								local veh_online = Game.GetCarCharIsUsing(PlayerPedNet)
								local maxSeats = Game.GetMaximumNumberOfPassengers(veh_online)
								for i=0, maxSeats, 1 do  
									if(Game.IsCarPassengerSeatFree(veh_online, i)) then 
										Game.WarpCharIntoCarAsPassenger(playerChar, veh_online, i)
									end
								end
							else
								Teleport_Char(playerChar, pos[1], pos[2]-2, pos[3])
							end
						else
							Print("Error : Player not exist !", 2500)
						end
					elseif item_selected == 1 then
						if Game.DoesCharExist(PlayerPedNet) then 
							if Game.IsCharOnFoot(PlayerPedNet) then 
								if Game.GetHostId() == playerId then
									local pos = table.pack(Game.GetCharCoordinates(playerChar))
									Game.ResurrectNetworkPlayer(nid, pos[1], pos[2], pos[3], 0.0)
								else
									Print("You Are Not Host !", 3000)
								end
							end
						else
							Print("Error : Player not exist !", 2500)
						end
					elseif item_selected == 2 then
						if Game.GetHostId() == playerId then
							Events.CallRemote("kick_player", {netid})
						else
							Print("You Are Not Host !", 3000)
						end
					end
				end
			end
		elseif Menu.last_selected[0] == 8 then -- Menu options
			if Menu.last_selected[1] == 0 then --position 
				if item_selected == 0 then
					Menu.menu_posX = 0.7676 -- right
					Menu.disable_frontend = false
				elseif item_selected == 1 then
					Menu.menu_posX = 0.4256 -- centre
					Menu.disable_frontend = true
				elseif item_selected == 2 then
					Menu.menu_posX = 0.0346 -- left
					Menu.disable_frontend = true
				end
			elseif Menu.last_selected[1] == 1 then --controller
				if item_selected == 0 then -- keybord, default
					Menu.controlOfMenu = 0
					Print("Keyboard control", 2500)
					Game.SetPlayerControlForNetwork(playerIndex, true, false)
				elseif item_selected == 1 then -- mouse
					Menu.controlOfMenu = 1
					Print("Mouse control", 2500)
					Game.SetPlayerControlForNetwork(playerIndex, false, false)
				elseif item_selected == 2 then -- gamepad
					Menu.controlOfMenu = 2
					Print("Gamepad control", 2500)
					Game.SetPlayerControlForNetwork(playerIndex, true, false)
				end
			end
		end
	elseif menu_level == 3 then
		if Menu.last_selected[0] == 0 then -- joueur
			if Menu.last_selected[1] == 9 then -- annimations
				if Menu.last_selected[2] >= 0 then -- anim set 
					local last_item_selected = Menu.last_selected[menu_level-1]+1
					--all item_selected, +300
					if item_selected >= 0 then
						LoadAnims(animation_Set[last_item_selected])
						Game.TaskPlayAnim(playerChar, Menu.item_name[item_selected], animation_Set[last_item_selected], 8.00000000, false, false, false, false, -2) 
					end
				end
			elseif Menu.last_selected[1] == 10 then -- model changer
				--all item_selected, +300
				local modelPc = Game.GetHashKey(Menu.item_name[item_selected])-- name of model player
				ChangePlayerToModel(modelPc, Ggroup)
			end
		elseif Menu.last_selected[0] == 4 then -- garage
			if Menu.last_selected[1] == 0 then -- paint
				if Menu.last_selected[2] == 4 then -- Specials 
					AddCarColors(item_selected)
				end
			end
		elseif Menu.last_selected[0] == 6 then -- world options
			if Menu.last_selected[1] == 4 then -- gang options
				if Menu.last_selected[2] == 0 then -- add members
					local modelped = Game.GetHashKey(Menu.extra_val[item_selected])
					AddMemberToGang(modelped)
				elseif Menu.last_selected[2] == 1 then -- option
					if item_selected == 0 then -- delete all members
						if(Game.DoesGroupExist(Ggroup)) then
							local test, guards = Game.GetGroupSize(Ggroup)
							if guards <= 0 then 
								return
							end

							for i=0,Gang_count,1 do 
								if GangMembers.Gped[i] ~= nil then
									local MembersOfGang = GangMembers.Gped[i]
									Game.RemoveCharFromGroup(MembersOfGang)
									Game.DeleteChar(MembersOfGang)
									Game.MarkCharAsNoLongerNeeded(MembersOfGang)
								end
							end
							Gang_count = 0
							return
						end
					elseif item_selected == 1 then -- tp all members on you
						if(Game.DoesGroupExist(Ggroup)) then
							local pos = table.pack(Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId())))
							local test, guards = Game.GetGroupSize(Ggroup)
							if guards <= 0 then 
								return
							end

							for i=0,Gang_count,1 do 
								if GangMembers.Gped[i] ~= nil then
									local MembersOfGang = GangMembers.Gped[i]
									Game.SetCharCoordinates(MembersOfGang, pos[1], pos[2] + 2, pos[3])
								end
							end
							return
						end
					elseif item_selected == 2 then 
						if(Game.DoesGroupExist(Ggroup)) then
							Game.SetGroupFormation(Ggroup, Menu.extra_val[item_selected])
						end
					elseif item_selected == 3 then 
						if(Game.DoesGroupExist(Ggroup)) then
							Game.SetGroupFormationSpacing(Ggroup, Menu.extra_val[item_selected])
						end
					end
				elseif Menu.last_selected[2] == 2 then -- select weapon 
					if(Game.DoesGroupExist(Ggroup)) then
						local pos = table.pack(Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId())))
						local test, guards = Game.GetGroupSize(Ggroup)
						if guards <= 0 then 
							return
						end

						for i=0,Gang_count,1 do 
							if GangMembers.Gped[i] ~= nil then
								local MembersOfGang = GangMembers.Gped[i]
								Game.GiveWeaponToChar(MembersOfGang, Menu.extra_val[item_selected], 500, false)
								Game.SetCurrentCharWeapon(MembersOfGang, Menu.extra_val[item_selected], true)
							end
						end
						return
					end
				elseif Menu.last_selected[2] == 3 then -- select anims
					if(item_selected == 0) then
						if(Game.DoesGroupExist(Ggroup)) then
							local pos = table.pack(Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId())))
							local test, guards = Game.GetGroupSize(Ggroup)
							if guards <= 0 then 
								return
							end
	
							for i=0,Gang_count,1 do 
								if GangMembers.Gped[i] ~= nil then
									local MembersOfGang = GangMembers.Gped[i]
									Game.ClearCharTasksImmediately(MembersOfGang)
								end
							end
							return
						end
					elseif(item_selected == 1) then 
						if(Menu.extra_val[item_selected] == 1) then
							AddAnimsToGang("taichi01","amb@park_taichi_a")
						elseif(Menu.extra_val[item_selected] == 2) then
							AddAnimsToGang("taichi02","amb@park_taichi_b")
						end
					elseif(item_selected == 2) then
						if(Menu.extra_val[item_selected] == 1) then
							AddAnimsToGang("loop_a","amb@dance_maleidl_a")
						elseif(Menu.extra_val[item_selected] == 2) then
							AddAnimsToGang("loop_b","amb@dance_maleidl_b")
						elseif(Menu.extra_val[item_selected] == 3) then
							AddAnimsToGang("loop_c","amb@dance_maleidl_c")
						elseif(Menu.extra_val[item_selected] == 4) then
							AddAnimsToGang("loop_d","amb@dance_maleidl_d")
						end
					elseif(item_selected == 3) then
						if(Menu.extra_val[item_selected] == 1) then
							AddAnimsToGang("loop_a","amb@dance_femidl_a")
						elseif(Menu.extra_val[item_selected] == 2) then
							AddAnimsToGang("loop_b","amb@dance_femidl_b")
						elseif(Menu.extra_val[item_selected] == 3) then
							AddAnimsToGang("loop_c","amb@dance_femidl_c")
						end
					elseif(item_selected == 4) then
						AddAnimsToGang("pole_dance_a","missstripclublo")
					end
				end	
			end
		end
	end
end

local menu_hold_pressed = function(p_id)
	if (Menu.controlOfMenu == 0) then 
		if Game.IsGameKeyboardKeyPressed(p_id) then 
			press_id = p_id
			if (hold_counter > 40) then 
				hold_counter = 0
			end

			hold_counter = hold_counter+1
			press_counter = press_counter+1
		elseif (press_id == p_id) then
			hold_counter = 0
		end
	elseif (Menu.controlOfMenu == 2) then 
		if Game.IsButtonPressed(0, p_id) then 
			press_id = p_id
			if (hold_counter > 40) then 
				hold_counter = 0
			end

			hold_counter = hold_counter+1
			press_counter = press_counter+1
		elseif (press_id == p_id) then
			hold_counter = 0
		end
	end
end

local menu_up_pressed = function(counter)

	if (Menu.controlOfMenu == 0) then
		if ( Game.IsGameKeyboardKeyJustPressed(Menu.ButtonUp) or ( press_counter > 6 and Game.IsGameKeyboardKeyPressed(Menu.ButtonUp) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.ButtonUp)
		end
	elseif (Menu.controlOfMenu == 2) then
		if ( Game.IsButtonJustPressed(0, Menu.DPAD_UP) or ( press_counter > 6 and Game.IsButtonPressed(0, Menu.DPAD_UP) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.DPAD_UP)
		end
	end
	return false
end
local menu_down_pressed = function(counter)
	if (Menu.controlOfMenu == 0) then
		if ( Game.IsGameKeyboardKeyJustPressed(Menu.ButtonDown) or ( press_counter > 6 and Game.IsGameKeyboardKeyPressed(Menu.ButtonDown) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.ButtonDown)
		end
	elseif (Menu.controlOfMenu == 2) then
		if ( Game.IsButtonJustPressed(0, Menu.DPAD_DOWN) or ( press_counter > 6 and Game.IsButtonPressed(0, Menu.DPAD_DOWN) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.DPAD_DOWN)
		end
	end
	return false
end
local menu_left_pressed = function(counter)
	if (Menu.controlOfMenu == 0) then
		if ( Game.IsGameKeyboardKeyJustPressed(Menu.ButtonLeft) or ( press_counter > 6 and Game.IsGameKeyboardKeyPressed(Menu.ButtonLeft) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.ButtonLeft)
		end
	elseif (Menu.controlOfMenu == 2) then
		if ( Game.IsButtonJustPressed(0, Menu.DPAD_LEFT) or ( press_counter > 6 and Game.IsButtonPressed(0, Menu.DPAD_LEFT) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.DPAD_LEFT)
		end
	end
	return false
end
local menu_right_pressed = function(counter)
	if (Menu.controlOfMenu == 0) then
		if ( Game.IsGameKeyboardKeyJustPressed(Menu.ButtonRight) or ( press_counter > 6 and Game.IsGameKeyboardKeyPressed(Menu.ButtonRight) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.ButtonRight)
		end
	elseif (Menu.controlOfMenu == 2) then
		if ( Game.IsButtonJustPressed(0, Menu.DPAD_RIGHT) or ( press_counter > 6 and Game.IsButtonPressed(0, Menu.DPAD_RIGHT) ) ) then
			reset_counter = true
			return true
		end

		if counter then 
			menu_hold_pressed(Menu.DPAD_RIGHT)
		end
	end
	return false
end

local function Engine()
	-- CORE MENU
	-- down

	if (Menu.controlOfMenu == 0 or Menu.controlOfMenu == 2) then -- keyboard, default / gamepad
		if menu_down_pressed(true) and not Menu.InError then
			if (item_selected > max_item-1) then 
				item_selected = 0
				ResetMenu()
				menu_setup()
			else
				item_selected = item_selected + 1
				if (menu_len > menu_consts_max and item_selected > menu_start_scrolling) then
					Menu.menu_posY = Menu.menu_posY - Menu.menu_spacing
					menu_max = menu_max + 1
				end
				if Menu.type[item_selected] == Gui.DisplayType.Type_JumpOver then 
					JumpOverItem("+", Menu.extra_val[item_selected])
				end
			end													
		elseif menu_up_pressed(true) and not Menu.InError then
			if (item_selected <= 0) then
				item_selected = menu_len-1
				Scroll_down = true
			else
				item_selected = item_selected - 1
				if (menu_len > menu_consts_max and item_selected > menu_start_scrolling-1 ) then
					Menu.menu_posY = Menu.menu_posY + Menu.menu_spacing
					menu_max = menu_max - 1
				end
				if Menu.type[item_selected] == Gui.DisplayType.Type_JumpOver then 
					JumpOverItem("-", Menu.extra_val[item_selected])
				end
			end	
		elseif menu_right_pressed(true) and not Menu.InError then
	
			if Menu.type[item_selected] == Gui.DisplayType.Type_Number then	
	
				if Menu.extra_val[item_selected] == Menu.extra_Max[item_selected] then
	
					Menu.extra_val[item_selected] = 0
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Number2 then	
	
				if Menu.extra_val[item_selected] == Menu.extra_Max[item_selected] then
	
					Menu.extra_val[item_selected] = 1
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Float then	
	
				if Menu.extra_val[item_selected] > Menu.extra_Max[item_selected] then
	
					Menu.extra_val[item_selected] = Menu.extra_Max[item_selected]
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + Menu.speed_val[item_selected]
				end
			end
		elseif menu_left_pressed(true) and not Menu.InError then
	
			if Menu.type[item_selected] == Gui.DisplayType.Type_Number then	
				
				if Menu.extra_val[item_selected] == 0 then
					Menu.extra_val[item_selected] = Menu.extra_Max[item_selected]
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Number2 then	
				
				if Menu.extra_val[item_selected] == 1 then
					Menu.extra_val[item_selected] = Menu.extra_Max[item_selected]
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Float then	
				if Menu.extra_val[item_selected] == 0.0000 then
					Menu.extra_val[item_selected] = 0.0000
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - Menu.speed_val[item_selected]
				end
			end
			-- accept
		elseif Game.IsGameKeyboardKeyJustPressed(Menu.ButtonAccept) or Game.IsButtonJustPressed(0, Menu.BUTTON_X) and not Menu.InError then
			if Menu.action[item_selected] then
				menu_function()
			else
				Menu.last_selected[menu_level] = item_selected
				menu_level = menu_level + 1
				item_selected = 0
				ResetMenu()
				menu_setup()
			end
	
		elseif Game.IsGameKeyboardKeyJustPressed(Menu.ButtonBack)  or Game.IsButtonJustPressed(0, Menu.BUTTON_B) then
			if menu_level > 0 then
				menu_level = menu_level - 1
				item_selected = Menu.last_selected[menu_level]
				ResetMenu()
				menu_setup()
			else
				menu_shutdown()
			end
			Menu.InError = false
		end
	elseif(Menu.controlOfMenu == 1) then -- mouse
		if Game.GetMouseWheel() > 0 and not Menu.InError then
			if (item_selected > max_item-1) then 
				item_selected = 0
				ResetMenu()
				menu_setup()
			else
				item_selected = item_selected + 1
				if (menu_len > menu_consts_max and item_selected > menu_start_scrolling) then
					Menu.menu_posY = Menu.menu_posY - Menu.menu_spacing
					menu_max = menu_max + 1
				end
				if Menu.type[item_selected] == Gui.DisplayType.Type_JumpOver then 
					JumpOverItem("+", Menu.extra_val[item_selected])
				end
			end													
		elseif Game.GetMouseWheel() < 0 and not Menu.InError then
			if (item_selected <= 0) then
				item_selected = menu_len-1
				Scroll_down = true
			else
				item_selected = item_selected - 1
				if (menu_len > menu_consts_max and item_selected > menu_start_scrolling-1 ) then
					Menu.menu_posY = Menu.menu_posY + Menu.menu_spacing
					menu_max = menu_max - 1
				end
				if Menu.type[item_selected] == Gui.DisplayType.Type_JumpOver then 
					JumpOverItem("-", Menu.extra_val[item_selected])
				end
			end	
		elseif menu_right_pressed(true) and not Menu.InError then

			if Menu.type[item_selected] == Gui.DisplayType.Type_Number then	

				if Menu.extra_val[item_selected] == Menu.extra_Max[item_selected] then

					Menu.extra_val[item_selected] = 0
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Number2 then	

				if Menu.extra_val[item_selected] == Menu.extra_Max[item_selected] then

					Menu.extra_val[item_selected] = 1
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Float then	

				if Menu.extra_val[item_selected] >= Menu.extra_Max[item_selected] then

					Menu.extra_val[item_selected] = 0.0
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] + Menu.speed_val[item_selected]
				end
			end
		elseif menu_left_pressed(true) and not Menu.InError then

			if Menu.type[item_selected] == Gui.DisplayType.Type_Number then	
				
				if Menu.extra_val[item_selected] == 0 then
					Menu.extra_val[item_selected] = Menu.extra_Max[item_selected]
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Number2 then	
				
				if Menu.extra_val[item_selected] == 1 then
					Menu.extra_val[item_selected] = Menu.extra_Max[item_selected]
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - 1
				end
			elseif Menu.type[item_selected] == Gui.DisplayType.Type_Float then	
				if Menu.extra_val[item_selected] <= 0.0000 then
					Menu.extra_val[item_selected] = 0.0000
				else
					Menu.extra_val[item_selected] = Menu.extra_val[item_selected] - Menu.speed_val[item_selected]
				end
			end
			-- accept
		elseif Game.IsMouseButtonJustPressed(1) and not Menu.InError then
			if Menu.action[item_selected] then
				menu_function()
			else
				Menu.last_selected[menu_level] = item_selected
				menu_level = menu_level + 1
				item_selected = 0
				ResetMenu()
				menu_setup()
			end

		elseif Game.IsMouseButtonJustPressed(2) then
			if menu_level > 0 then
				menu_level = menu_level - 1
				item_selected = Menu.last_selected[menu_level]
				ResetMenu()
				menu_setup()
			else
				menu_shutdown()
			end
			Menu.InError = false
		end
	end

	if reset_counter then
		press_counter = 2
		reset_counter = false
	end

	if (Game.IsGameKeyboardKeyJustPressed(Menu.ButtonBack) or (Game.IsMouseButtonJustPressed(2) or Game.IsButtonJustPressed(0, Menu.BUTTON_B) and Menu.controlOfMenu == 1 )) then --and Menu.last_selected[menu_level] ~= 0
		if menu_level > 0 then
			if Menu.last_selected[menu_level] <= menu_len then
				item_selected = Menu.last_selected[menu_level]
			else
				item_selected = menu_len
			end
			Menu.last_selected[menu_level] = 0
			
			if (menu_len > menu_consts_max and item_selected > menu_start_scrolling) then 
				for I = menu_start_scrolling+1, item_selected, 1 do 
					Menu.menu_posY = Menu.menu_posY - Menu.menu_spacing
					menu_max = menu_max + 1
				end
			end
		end
	end

	if Scroll_down then 
		Scroll_down = false
		if menu_level > 0 then
			if (menu_len > menu_consts_max and item_selected > menu_start_scrolling) then 
				for I = menu_start_scrolling+1, item_selected, 1 do 
					Menu.menu_posY = Menu.menu_posY - Menu.menu_spacing
					menu_max = menu_max + 1
				end
			end
		end
	end
end

local function menu_displays()
	local episode = Game.GetCurrentEpisode()
  -- centre  menu_posX = 0.4256
  -- left menu_posX = 0.0346
  -- right menu_posX = 0.7676

 	if menu_len > menu_consts_max then
		Game.DrawCurvedWindow(Menu.menu_posX - 0.0126, 0.2480, 0.2220, 0.0600 + (Menu.menu_spacing * 11), 255)
		Game.DrawRect(Menu.menu_posX + 0.0984, 0.2940 + (Menu.menu_spacing * 11), 0.2220, 0.0330, 22, 80, 255, 255) -- bleu
		-- Title item info
		
		Game.SetTextScale(0.26, 0.26)
		Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
		local OptionCount = item_selected+1
		local MaxOptionCount = max_item+1
		if not Menu.InError then Game.DisplayTextWithLiteralString(Menu.menu_posX - 0.0100, 0.2850 + (Menu.menu_spacing * 11), "STRING", " "..OptionCount.." / "..MaxOptionCount) end
		Game.SetTextScale(0.26, 0.26)
		Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
		Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1220, 0.2850 + (Menu.menu_spacing * 11), "STRING", VersionOfMenu)
	else
		Game.DrawCurvedWindow(Menu.menu_posX - 0.0126, 0.2480, 0.2220, 0.0600 + (Menu.menu_spacing * menu_len), 255)
		Game.DrawRect(Menu.menu_posX + 0.0984, 0.2940 + (Menu.menu_spacing * menu_len), 0.2220, 0.0330, 22, 80, 255, 255) -- bleu
		-- Title item info
		
		Game.SetTextScale(0.26, 0.26)
		Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
		local OptionCount = item_selected+1
		local MaxOptionCount = max_item+1
		if not Menu.InError then Game.DisplayTextWithLiteralString(Menu.menu_posX - 0.0100, 0.2850 + (Menu.menu_spacing * menu_len), "STRING"," "..OptionCount.." / "..MaxOptionCount) end
		Game.SetTextScale(0.26, 0.26)
		Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
		Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1220, 0.2850 + (Menu.menu_spacing * menu_len), "STRING", VersionOfMenu)
	end

	Game.DrawRect(Menu.menu_posX + 0.0984, 0.2360, 0.2220, 0.0950 , 22, 80, 255, 255) -- blue
	Game.DrawRect(Menu.menu_posX + 0.0984, 0.2400, 0.2220, 0.0300 ,  0, 0, 0, 100) -- Black

	if (menu_len > menu_consts_max and item_selected > menu_start_scrolling) then -- top
		local texture_1 = Game.GetTexture(NetworkTexture,"icon_w_arrow_up") 
		Game.DrawSprite(texture_1,Menu.menu_posX + 0.0930, 0.2740,0.0160, 0.0160, 0,255,255,255,255)	
	end

	if menu_len > menu_consts_max then -- down
		local texture_2 = Game.GetTexture(NetworkTexture,"icon_w_arrow_up") 
		Game.DrawSprite(texture_2,Menu.menu_posX + 0.0930, 0.2880+(Menu.menu_spacing * 11),0.0160, 0.0160, 180.0,255,255,255,255)
	end

	-- Title menu
	--Game.SetTextFont(7)
	Game.SetTextScale(0.35, 0.35)
	Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
	Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.0444, 0.1940, "STRING", Menu.Title_menu)

	-- Title submenu
	--Game.SetTextFont(0)
	Game.SetTextScale(0.30, 0.30)
	Game.SetTextColour(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
	Game.DisplayTextWithLiteralString(Menu.menu_posX - 0.0080, 0.2300, "STRING", Menu.Title_Item_Set)

end

local function CoreMenu(items)
	local mlen = menu_len - 1
	menu_displays()

	local Ipos_y = Menu.menu_posY
	for i=0,mlen,1 do
		Ipos_y = Ipos_y + Menu.menu_spacing
		if (i <= menu_max and Ipos_y > menu_consts_start_y) then
		
			local item_text = items[i]
			
			if(item_selected == i and not Menu.InError) then
				SetUptext(22, 80, 255, 255)-- blue
				Game.DrawRect(Menu.menu_posX - 0.0107, Ipos_y + 0.0090, 0.0028, 0.0250, Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, 255) -- White
			else 
				SetUptext(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
			end

			Game.DisplayTextWithLiteralString(Menu.menu_posX - 0.0071, Ipos_y, "STRING", item_text)

			if Menu.type[i] == Gui.DisplayType.Type_Boolean then
				if Menu.extra_val[i] == true then
					SetUptext(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
					Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1750, Ipos_y, "STRING", "~COL_NET_3~On")
				else
					SetUptext(Gui.Colour.White.r, Gui.Colour.White.g, Gui.Colour.White.b, Gui.Colour.White.a)
					Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1750, Ipos_y, "STRING", "~COL_NET_4~Off")
				end
			
			elseif Menu.type[i] == Gui.DisplayType.Type_Number then-- paint 0 / 134	
				SetUptext(Gui.Colour.Green.r, Gui.Colour.Green.g, Gui.Colour.Green.b, Gui.Colour.Green.a)
				Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1360, Ipos_y, "STRING", " "..Menu.extra_val[i].." / "..Menu.extra_Max[i])

			elseif Menu.type[i] == Gui.DisplayType.Type_Number2 then -- 1 -10 ....
				SetUptext(Gui.Colour.Green.r, Gui.Colour.Green.g, Gui.Colour.Green.b, Gui.Colour.Green.a)
				Game.DisplayTextWithLiteralString(Menu.menu_posX + 0.1360, Ipos_y, "STRING", "< "..Menu.extra_val[i].." >")

			elseif Menu.type[i] == Gui.DisplayType.Type_Display then
				SetUptext(Gui.Colour.Green.r, Gui.Colour.Green.g, Gui.Colour.Green.b, Gui.Colour.Green.a)	
				Game.DisplayTextWithNumber(Menu.menu_posX + 0.1580, Ipos_y, "NUMBR", Menu.extra_val[i])
			
			elseif Menu.type[i] == Gui.DisplayType.Type_Float then
				SetUptext(Gui.Colour.Green.r, Gui.Colour.Green.g, Gui.Colour.Green.b, Gui.Colour.Green.a)	
				Game.DisplayTextWithFloat(Menu.menu_posX + 0.1580, Ipos_y, "NUMBR", Menu.extra_val[i], 4)
			end
		end
	end
end

local function loop_functions()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local playerIndex = Game.ConvertIntToPlayerindex(playerId)
	
--------------------------------------------------
--					PLAYER  					--
--------------------------------------------------  
	if Menu.Player_option.godmod then 
		Game.SetPlayerInvincible(playerIndex, true)
	end

	if Menu.Player_option.freezeped then 
		Game.FreezeCharPosition(playerChar, true)
	end
	
	if Menu.Player_option.neverwanted then 
		Game.ClearWantedLevel(playerId)
		Game.AlterWantedLevel(playerId, 0)
		Game.ApplyWantedLevelChangeNow(playerId)
	end

	if Menu.Player_option.invisible then
		Game.SetCharVisible(playerChar, false)
	end

	if Menu.Player_option.nocolision then 
		Game.SetCharCollision(playerChar, false)
	end

	if Game.IsCharDead(playerChar) then
		-- remove your group if you dead
		if(Game.DoesGroupExist(Ggroup)) then
			local test, guards = Game.GetGroupSize(Ggroup)
			if guards <= 0 then 
				return
			end

			for i=0,Gang_count,1 do 
				if GangMembers.Gped[i] ~= nil then
					local MembersOfGang = GangMembers.Gped[i]
					Game.RemoveCharFromGroup(MembersOfGang)
					Game.DeleteChar(MembersOfGang)
					Game.MarkCharAsNoLongerNeeded(MembersOfGang)
				end
			end
			Gang_count = 0
			Game.RemoveGroup(Ggroup)
			return
		end
	end
--------------------------------------------------
--					VEHICLE  					--
--------------------------------------------------  
	if Game.IsCharInAnyCar(playerChar) then
		local playerCar = Game.GetCarCharIsUsing(playerChar)
		local DriverCar = Game.GetDriverOfCar(playerCar)
		local SpeedVeh = Game.GetCarSpeed(playerCar)
		local vx, vy, vz = Game.GetCarCoordinates(playerCar)
		
		if Menu.Vehicle_option.godmodcar then
			playerCar = Game.GetCarCharIsUsing(playerChar)

			Game.SetCarCanBeDamaged(playerCar,false)
			Game.SetCarCanBeVisiblyDamaged(playerCar,false)
			Game.SetCanBurstCarTyres(playerCar,false)
			Game.SetVehicleDirtLevel(playerCar,0.0)
			Game.WashVehicleTextures(playerCar, 255)
			Game.SetCarProofs(playerCar, true, true, true, true, true)
		end
	
		if Menu.Vehicle_option.invisiblecar then
			Game.SetCarVisible(playerCar, false)
		else 
			Game.SetCarVisible(playerCar, true)
		end

		if Menu.Vehicle_option.nocollisioncar then
			Game.SetCarCollision(playerCar, false)
		else 
			Game.SetCarCollision(playerCar, true)
		end

		if Menu.Vehicle_option.freezecar then
			Game.FreezeCarPosition(playerCar, true)
		else
			Game.FreezeCarPosition(playerCar, false)
		end

		if Menu.Vehicle_option.speedometer then
			--local iSpeed = SpeedVeh
			--iSpeed = iSpeed * 2.85
			local iSpeed = math.ceil(SpeedVeh * 3.6)
			
			--Game.SetTextFont(3)
			Game.SetTextScale(0.25, 0.25)
			Game.SetTextColour(255, 255, 255, 255)
			Game.DisplayTextWithLiteralString(0.08,0.7120, "STRING", "Km/h")

			--Game.SetTextFont(3)
			Game.SetTextScale(0.25, 0.25)
			Game.SetTextColour(255, 255, 255, 255)
			Game.DisplayTextWithFloat(0.15,0.7120, "NUMBR", iSpeed, 0)
		end

		if(Menu.Vehicle_option.driftmode) then 
			if((not Game.IsCharInAnyBoat(playerChar)) and (not Game.IsCharInAnyHeli(playerChar)) and (not Game.IsCharOnAnyBike(playerChar)) and (Game.IsVehicleOnAllWheels(playerCar))) then
				Game.ApplyForceToCar(playerCar, 1, 0.0, 0.0, 0.0700, 0.0, 0.0, 0.0, 0, true, true, true)
			end
		end
	end

	if in_paint then 
		if menu_level == 2 then 
			if Menu.last_selected[0] == 4 then -- garage
				if Menu.last_selected[1] == 0 then -- paint
					
					local playerCar = Game.GetCarCharIsUsing(playerChar)
					local ColorC1, ColorC2 = Game.GetCarColours(playerCar)
					local ColorC3, ColorC4 = Game.GetExtraCarColours(playerCar)

					if (item_selected == 0) then
						Game.ChangeCarColour(playerCar, Menu.extra_val[item_selected], ColorC2)	
					elseif (item_selected == 1) then
						Game.ChangeCarColour(playerCar, ColorC1, Menu.extra_val[item_selected])		
					elseif (item_selected == 2) then
						Game.SetExtraCarColours(playerCar, Menu.extra_val[item_selected], ColorC4)		
					elseif (item_selected == 3) then
						Game.SetExtraCarColours(playerCar, ColorC3, Menu.extra_val[item_selected])
					elseif (item_selected == 4) then
						Game.SetCarLivery(playerCar, Menu.extra_val[item_selected])
					end
				end
			end
		end
	end
--------------------------------------------------
--					WEAPON  					--
--------------------------------------------------  

	if Menu.Weapon_option.rapidfire then
		
		Game.SetPlayerFastReload(playerIndex, true)
		Game.EnableMaxAmmoCap(false)
		
		local iWeapon = Game.GetCurrentCharWeapon(playerChar)
		if(Game.IsMouseButtonPressed(1) and iWeapon ~= 0) then
			Game.SetCharAllAnimsSpeed(playerChar, 15)
		else
			Game.SetCharAllAnimsSpeed(playerChar, 1)
		end
	end
--------------------------------------------------
--					WORLD	  					--
--------------------------------------------------  
	Game.DisableGps(Menu.World_option.mutegps)

	if Menu.World_option.xyzh then
		-- x, y, z, h positions
		local px, py, pz = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
		local ph = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))
		Game.DrawCurvedWindow(0.1770, 0.8070, 0.1140, 0.1500, 255) -- Full Black, 255 is opacity
		--
		SetUptextDraw()
		Game.DisplayTextWithLiteralString(0.2130 - 0.0300, 0.8130, "STRING", "X :")
		SetUptextDraw()
		Game.DisplayTextWithFloat(0.2130, 0.8130, "NUMBR", tonumber(px), 4)
		--
		SetUptextDraw()
		Game.DisplayTextWithLiteralString(0.2130 - 0.0300, 0.8130 + 0.0400, "STRING", "Y :")
		SetUptextDraw()
		Game.DisplayTextWithFloat(0.2130, 0.8130 + 0.0400, "NUMBR", tonumber(py), 4)
		--
		SetUptextDraw()
		Game.DisplayTextWithLiteralString(0.2130 - 0.0300, 0.8130 + (0.0400 * 2), "STRING", "Z :")
		SetUptextDraw()
		Game.DisplayTextWithFloat(0.2130, 0.8130 + (0.0400 * 2), "NUMBR", tonumber(pz), 4)
		--
		SetUptextDraw()
		Game.DisplayTextWithLiteralString(0.2130 - 0.0300, 0.8130 + (0.0400 * 3), "STRING", "H :")
		SetUptextDraw()
		Game.DisplayTextWithFloat(0.2130, 0.8130 + (0.0400 * 3), "NUMBR", tonumber(ph), 4)
	end

	if Menu.World_option.time then
		--clock of game
		local hour, minute = Game.GetTimeOfDay()

		Game.DrawCurvedWindow(0.8730, 0.0200, 0.0620, 0.0380, 255)
		SetUptextDraw()
		Game.DisplayTextWithLiteralString(0.8760, 0.0290, "STRING", " "..hour.." : "..minute)
	end

	if Menu.World_option.slowmotion then
		Game.SetTimeScale(0.3)
	end

	if Menu.TextureViewer then
		Dictionary = Game.LoadTxd(Menu.Title_Item_Set)
		local textureDict = Game.GetTexture(Dictionary,Menu.item_name[item_selected])
		Game.DrawSprite(textureDict, 0.5, 0.5,0.06,0.06,0,255,255,255,255)	
	end

	if Menu.World_option.gravity then
		Game.SetGravityOff(true)
	end

	if Menu.World_option.wind then
		Game.ForceWind(10000.0)
	end

	if Menu.World_option.driveonwater then
		local px, py, pz 
		if(Game.IsCharInAnyCar(playerChar)) then 
			local playerCar = Game.GetCarCharIsUsing(playerChar)
			px, py, pz = Game.GetCarCoordinates(playerCar)
		else
			px, py, pz = Game.GetCharCoordinates(playerChar)
		end

		if(not Game.DoesObjectExist (thingy)) then 
			local bl, sealevel = Game.GetWaterHeight(px, py, pz)
			local sealvl = sealevel - 9.5

			LoadModelFromCdimage(0x4F9981BE)

			thingy = Game.CreateObject(0x4F9981BE, px, py, sealvl, true)
			Game.MarkModelAsNoLongerNeeded(0x4F9981BE)
			Game.SetObjectVisible(thingy, false)
			Game.SetObjectInvincible(thingy, true)
		else
			local bl, sealevel = Game.GetWaterHeight(px, py, pz)
			local sealvl = sealevel - 9.5

			Game.SetObjectCoordinates(thingy, px, py, sealvl)
			Game.FreezeObjectPosition(thingy, true)
		end
	end

	if Menu.World_option.playmovie then 
		Game.DrawMovie(0.3750, 0.5020, 0.7360, 0.9480, 0.00000000, 255, 255, 255, 255)
	end

	if Menu.World_option.radioOff then
		Game.DisableFrontendRadio()
		Game.SetMobileRadioEnabledDuringGameplay(true)
		Game.SetMobilePhoneRadioState(true)
	end
end

local function drawFrontend()
	Game.InitFrontendHelperText()
	if (not Menu.disable_frontend)then
		if not Menu.InError then 
			if (menu_level > 0) then 
				Game.DrawFrontendHelperText("", "BACK", false)
			else
				Game.DrawFrontendHelperText("", "LEAVE", false)
			end

			if Menu.action[item_selected] then 
				Game.DrawFrontendHelperText("", "CONFIRM", false)
			else
				Game.DrawFrontendHelperText("", "KYB_ENTER", false)
			end

			if Menu.type[item_selected] == Gui.DisplayType.Type_Number or Menu.type[item_selected] == Gui.DisplayType.Type_Number2 then 
				Game.DrawFrontendHelperText("", "SCROLL", false)
			end
		else
			Game.DrawFrontendHelperText("", "BACK", false)
		end
	end
end

Events.Subscribe("scriptInit", function()
	Thread.Create(function()
		
		while true do
			Thread.Pause(0)
			Game.SetPlayerTeam(Game.GetPlayerId(), 0)-- fix tp in car to char

			local inputActive = Chat.IsInputActive()-- disable control of menu, if chat is active

			if Game.IsGameKeyboardKeyJustPressed(Menu.ButtonOpen)  or (Game.IsButtonPressed(0, Menu.BUTTON_RB) and Game.IsButtonJustPressed(0, Menu.BUTTON_A) ) then 
				if not Menu.isOpen then 
					menu_startup()
				end
			end
			
			if Menu.isOpen and not Game.IsPauseMenuActive() and not Game.IsPayNSprayActive() then
				if not inputActive then Engine() end -- disable control menu if chat input enable
				CoreMenu(Menu.item_name) 
				drawFrontend() 
			end

			loop_functions()
		end
	end)
end)

