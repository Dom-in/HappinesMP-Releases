-- Create By LeChapellierFou
-- HappinessMP client menu
-- Parts of menu base v3.0

function LoadModelFromCdimage(hash)

	if Game.IsModelInCdimage(hash) then	
		while not Game.HasModelLoaded(hash) do
			Game.RequestModel(hash)
			Thread.Pause(0)
		end
	else 
		Game.ClearPrints()
		Game.PrintStringWithLiteralStringNow("STRING", "~r~Error :~w~ Model Not Exist !.", 4000, true)
	end
end

function AddSkinZombie()
	--only original
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)

	Game.SetCharComponentVariation(playerChar, 0, 3, 3 )
	Game.SetCharComponentVariation(playerChar, 1, 4, 1 )
	Game.SetCharComponentVariation(playerChar, 2, 3, 0 )
	Game.SetCharComponentVariation(playerChar, 7, 0, 0 )
end

function create_throwable_object(hash, x, y, z)
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)

	if Game.IsModelInCdimage(hash) then	-- not load error model
		
		Game.RequestModel(hash)
		while not Game.HasModelLoaded(hash) do
			Game.RequestModel(hash)
			Thread.Pause(0)
		end
	
		local otmp = Game.CreateObject(hash,x,y,z,true)
	
		Game.FreezeObjectPosition(otmp,false)
		Game.SetObjectDynamic(otmp,true)
		Game.SetObjectAsStealable(otmp,true)
		Game.SetObjectCollision(otmp,true)
		if(hash == 0x9976ECC4 or hash == 0xF4A206E4 or hash == 0x90FA92C6) then
			Game.GivePedPickupObject(playerChar, otmp, true)
		end
		Game.MarkModelAsNoLongerNeeded(hash)
	end
end

function ChangePlayerToModel(hash, grp)
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local playerIndex = Game.ConvertIntToPlayerindex(playerId)
	
	if Game.IsModelInCdimage(hash) then	-- not load error model
		if not Game.IsCharModel(playerChar, hash) then
		
			Game.RequestModel(hash)
			while not Game.HasModelLoaded(hash) do
				Game.RequestModel(hash)
				Thread.Pause(0)
			end
				
			Game.ChangePlayerModel(playerId, hash)
			if( Game.DoesGroupExist(grp)) then Game.SetGroupLeader(grp, Game.GetPlayerChar(Game.GetPlayerId())) end -- gang
			Game.GiveWeaponToChar(Game.GetPlayerChar(Game.GetPlayerId()), 0, 1, false)-- fist
		
		end
	end
end

function Spawn_Car(hash)
	 
	local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
	local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))
	
	if Game.IsModelInCdimage(hash) then	
		while not Game.HasModelLoaded(hash) do
			Game.RequestModel(hash)
			Thread.Pause(0)
		end
	
		local car = Game.CreateCar(hash, x, y, z, true)
		Game.SetCarHeading(car, heading)
		Game.SetCarOnGroundProperly(car)
		Game.SetCarAsMissionCar(car)
		Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car)
	end
end

function ControleDoor(veh, door)

	if Game.IsCarDoorFullyOpen(veh, door) then
		Game.ShutCarDoor(veh, door)
	else
		Game.OpenCarDoor(veh, door)
	end
	
end

function AddCarColors(item_id)
	
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	local c
	local c3
	
	if Game.IsCharInAnyCar(playerChar) then
		local playerCar = Game.GetCarCharIsUsing(playerChar)
		if item_id == 0 then		c = 106  	c3 = 132	--Gold
		elseif item_id == 1 then	c = 93  	c3 = 127	--Cream
		elseif item_id == 2 then	c = 102  	c3 = 132	--Chocolate
		elseif item_id == 3 then	c = 0  		c3 = 101		--grape
		elseif item_id == 4 then	c = 44 		c3 = 101	--Magenta
		elseif item_id == 5 then	c = 36  	c3 = 124	--Blackcurrant
		elseif item_id == 6 then	c = 85  	c3 = 125	--Stinger
		elseif item_id == 7 then	c = 5  		c3 = 134		--Silver
		elseif item_id == 8 then	c = 34  	c3 = 125	--metallic red	
		elseif item_id == 9 then	c = 82  	c3 = 128		--Neon Blue
		elseif item_id == 10 then	c = 85  	c3 = 84		--Royal Blue
		elseif item_id == 11 then	c = 79  	c3 = 128		--silvery blue
		elseif item_id == 12 then	c = 0  		c3 = 128		--Electric Blue
		elseif item_id == 13 then	c = 95  	c3 = 127		--Champagne
		elseif item_id == 14 then	c = 91  	c3 = 127		--Pine/lime
		elseif item_id == 15 then	c = 60  	c3 = 127		--spearmint
		elseif item_id == 16 then	c = 56  	c3 = 51		--custom Green
		elseif item_id == 17 then	c = 51  	c3 = 127		--metallic green
		elseif item_id == 18 then	c = 88  	c3 = 101		--Metallic purple
		elseif item_id == 19 then	c = 0  		c3 = 127		--Electric yellow
		elseif item_id == 20 then	c = 35		c3 = 0			--red
		elseif item_id == 21 then	c = 131 	c3 = 0			--orange red
		elseif item_id == 22 then	c = 132		c3 = 0	--orange yellow
		elseif item_id == 23 then c = 56  c3 = 51 	--custom Green
		elseif item_id == 24 then c = 51  c3 = 127 		--metallic green
		elseif item_id == 25 then c = 88  c3 = 101 		--Metallic purple
		elseif item_id == 26  then c = 0  c3 = 127 end		--Electric yellow
		
		Game.ChangeCarColour(playerCar, c, c)
		Game.SetExtraCarColours(playerCar, c3, c)
	end
end

function Teleport_Char(ped, x, y, z)
	if(Game.IsCharInAnyCar(ped)) then
		local veh = Game.GetCarCharIsUsing(ped)

		Game.SetCarCoordinates(veh, x, y, z)
		Game.SetGameCamHeading(0.0)
		Game.RequestCollisionAtPosn(x, y, 0.0)
		Game.LoadAllObjectsNow()
	end
	Game.SetCharCoordinates(ped, x, y, z)
	Game.SetGameCamHeading(0.0)
	Game.RequestCollisionAtPosn(x, y, 0.0)
	Game.LoadAllObjectsNow()
end

function CreateWeaponWithAmmo(model, pickup_type, x, y, z)
	if Game.IsModelInCdimage(model) then	-- not load error model
		local weaponT = Game.GetWeapontypeModel(model)
		Game.CreatePickupWithAmmo( weaponT, pickupType, 100, x, y, z)
	end
end

function Create_Ped(model, relationship, x, y, z)
	if Game.IsModelInCdimage(model) then	-- not load error model
		local gameped = Game.CreateChar(relationship, model, x, y, z, true)
		Game.SetCharVisible(gameped, true)
		Game.SetCharRandomComponentVariation(gameped)
		Game.SetCharNeverTargetted( gameped, true)
	end
end

function create_explosion(explosiontype, x, y, z)
	Game.AddExplosion( x, y, z, explosiontype,10.0,true,false,0.7)
end

-- Check if string is a number.
function isNumber(str)
	local num = tonumber(str)
	if not num then return false
	else return true
	end
end