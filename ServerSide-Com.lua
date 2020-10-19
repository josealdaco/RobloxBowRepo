local BaseModule = require(game:WaitForChild("ServerStorage").GameDataScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerList = require(game:GetService("ServerScriptService").SoundRegionModule)
local messageStorageDB = require(game:GetService("ServerScriptService").MessageModule)
local PathfindingService = game:GetService("PathfindingService")

local TextService = game:GetService("TextService")
local playerCycleModule = require(script.Parent.PlayerCycleModule)
local remoteProgressEvent = ReplicatedStorage.Events:WaitForChild("remoteProgressEvent")
local LoadingScreenEnd = ReplicatedStorage.Events:WaitForChild("LoadingScreenEnd") -- This is the PlayButtonEvent
local ClientServerCom = ReplicatedStorage.Events:WaitForChild("ClientCommunication")
local CurrencyChange = ReplicatedStorage.Events:WaitForChild("CurrencyChange")
local ItemCollectEvent = ReplicatedStorage.Events:WaitForChild("ItemCollectEvent")
local ClothesChange =  ReplicatedStorage.Events:WaitForChild("ClothesChange")
local loadOutUpdate = ReplicatedStorage.Events:WaitForChild("ViewPortLoadOut")
local DataBaseChange = ReplicatedStorage.Events:WaitForChild("DataBaseChange")
local ChangeWeaponEvent = ReplicatedStorage.Events:WaitForChild("ChangeWeaponEvent")
local inventoryDisable = ReplicatedStorage:WaitForChild("Events"):WaitForChild("InventoryDisable")
local CampFireRemote = ReplicatedStorage.Events:WaitForChild("CampFire")
local pickRemote = ReplicatedStorage.Events:WaitForChild("PickEvent")
local PauseRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PetPause")
local playerCycle = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerDeadCycle")
local namePet = game:GetService("ReplicatedStorage").Events:WaitForChild("PetNameTest")
local dropItem = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemDrop")
local MessageDB = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChatEvent")
local readMessageData = ReplicatedStorage:WaitForChild("Events"):WaitForChild("MessageDB")
local MessageChangeDB = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChangeMessageDB")
local groupCreation  =  ReplicatedStorage:WaitForChild("Events"):WaitForChild("GroupCreation")
local NotificationBell = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Notification")
local otherUserData = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GrabOtherUserData")
local DeadScreen= ReplicatedStorage:WaitForChild("Events"):WaitForChild("DeadScreen")
local UINavigation = ReplicatedStorage:WaitForChild("Events"):WaitForChild("NavigationEvent")
local NewLocation = ReplicatedStorage:WaitForChild("Events"):WaitForChild("NewLocation")

local Players = game:GetService("Players")


local function communicateProgessClient(player)
remoteProgressEvent:FireClient(player) -- or FireAllClients() To communicate to several other clients
end
local function communicateLoadingScreenClient(player)
	LoadingScreenEnd:FireClient(player)
end
remoteProgressEvent.OnServerEvent:Connect(communicateProgessClient)
LoadingScreenEnd.OnServerEvent:Connect(communicateLoadingScreenClient)





---------Above code about loading scren is most likely not needed -----------

local function ChangeDataBaseFunction(player, productTable, TransactionType)
	assert(typeof(productTable) == "table") -- Make sure the product is a table
	BaseModule.ChangeStat(player, TransactionType.."RESET", productTable)

end



local function ChangingClothes(player, ClothesType, ID)
	if ClothesType == "SHIRT" then
		local webURL = "https://www.roblox.com/catalog/"..ID.."/White-Shirt"
		local assetId = tonumber(string.match(webURL, "%d+") or 0)  -- Extract the number
		local success, Shirt = pcall(function()
				return game:GetService("InsertService"):LoadAsset(assetId)
					end)
				if success then
				print("THERE SHOULD BE A SHIRT"..tostring(Shirt["Shirt"]["ShirtTemplate"]))

			local characterClone = game.Workspace:WaitForChild("UserClone_"..player.UserId)

			characterClone["Shirt"]["ShirtTemplate"] =  Shirt["Shirt"]["ShirtTemplate"]
			player.Character["Shirt"]["ShirtTemplate"] = Shirt["Shirt"]["ShirtTemplate"]






				else
					print("There was an error")
				end
	else if ClothesType == "PANTS" then
			local webURL = "https://www.roblox.com/catalog/"..ID.."/White-Shirt"
			local assetId = tonumber(string.match(webURL, "%d+") or 0)  -- Extract the number
			local success,Pants = pcall(function()
				return game:GetService("InsertService"):LoadAsset(assetId)
					end)
			if success then
				print("THERE SHOULD BE A SHIRT"..tostring(Pants["Pants"]["PantsTemplate"]))
				local characterClone = game.Workspace:WaitForChild("UserClone_"..player.UserId)
				characterClone["Pants"]["PantsTemplate"] = Pants["Pants"]["PantsTemplate"]
				player.Character["Pants"]["PantsTemplate"] = Pants["Pants"]["PantsTemplate"]
				else
					print("There was an error")
				end
		end
	end

end

local function GrabbingWeapon(player, weapon, reset, damage)
	if reset ~= nil then
		print("I am Resetting the weapon"..tostring(weapon))
		ChangeWeaponEvent:FireClient(player, true, weapon, true, damage)
	else
		ChangeWeaponEvent:FireClient(player, true, weapon, false, damage)
		print("I am Replacing the weapon"..tostring(weapon))

	end
end

local function namePetFunction(player, text)
	local textObject;
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(text, player.UserId)
	end)

	if success then
		local filteredMessage
	local successMessage, errorTextMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if successMessage then
			if string.match(filteredMessage, "#") then
				return nil
			else
				return filteredMessage
			end
	elseif errorTextMessage then
			print("Error filtering message:", errorMessage)
			return nil
	end
	elseif errorMessage then
		print("Error generating TextFilterResult:", errorMessage)
		return nil
	end

end
-----------------
loadOutUpdate.OnServerEvent:Connect(function(player, objectName)
	loadOutUpdate:FireClient(player, objectName)
end)
NotificationBell.OnServerEvent:Connect(function(player, callType,description, ActionCall, ACTION, ID, handler, sender)
	--- Echo notification back----  callType, description, ActionCall, ACTION, ID, handler, optionalRequestPlayer
	--- We are gonna send this notification to the sender, if sending it to same player remember to have player be in sender slot
	NotificationBell:FireClient(sender, callType,  description,ActionCall, ACTION, ID, handler, sender)
end)

local function messageStorageFunction(player, storageType, mode, optionalMember)

	if storageType == "GLOBAL" then
		return messageStorageDB.globalChatRead()
	elseif storageType == "GROUP" then
		if  mode ~= nil and mode == "CHANNELS" then
			 return messageStorageDB.groupChannelsRead()
		elseif  mode ~= nil and mode == "MESSAGES" then
			return messageStorageDB.groupMessagesRead(player)
		else
			return {}
		end

	elseif storageType == "PRIVATE" then

		local OtherPlayer = messageStorageDB.individualGetOther(player)

		if OtherPlayer == nil then
			return {}
		else
			return messageStorageDB.individualMessagesRead(player,OtherPlayer)

		end

	elseif storageType == "PRIVATEOTHER" then
		 return messageStorageDB.individualGetOther(player)

	end

end

readMessageData.OnServerInvoke =  messageStorageFunction
local function returnOtherUserData(player, playerObject)

	return BaseModule.getPlayerData(playerObject)
end
otherUserData.OnServerInvoke =  returnOtherUserData
namePet.OnServerInvoke = namePetFunction
local function communicateFunction(player, statName, currency, value)
	if statName == "CurrencyChange" then
		CurrencyChange:FireClient(player, currency, value)
	end
end
local function itemCollected(player)
	ItemCollectEvent:FireClient(player, true)
end
ClientServerCom.OnServerEvent:Connect(communicateFunction)
ItemCollectEvent.OnServerEvent:Connect(itemCollected)
DataBaseChange.OnServerEvent:Connect(ChangeDataBaseFunction)
ClothesChange.OnServerEvent:Connect(ChangingClothes)
inventoryDisable.OnServerEvent:Connect(function(player,UI, value)
	inventoryDisable:FireClient(player, UI,value)
end)
ChangeWeaponEvent.OnServerEvent:Connect(GrabbingWeapon)

CampFireRemote.OnServerEvent:Connect(function(player, model, handler)
	CampFireRemote:FireClient(player, model, handler)
end)

PauseRemote.OnServerEvent:Connect(function(player, petID, order)
	game.Workspace[petID].Target.Value = order
end)
pickRemote.OnServerEvent:Connect(function(player, value, handler)
	if handler == "DESTROY" then
		pickRemote:FireClient(player, value, "Disable")
		value:Destroy()


	else
			pickRemote:FireClient(player, value, handler)

	end

end)
MessageDB.OnServerEvent:Connect(function(player, message, channel, optionalSender, optionalInvite , systemMessage)
	print("RECIEVING MESSAGE")  -- All system messages will be send to the same player
	local timeStamp = os.time()
	local chatType;
	if channel == "Global" then
		chatType = 1
	elseif channel  == "Group" then
		chatType = 2
	elseif channel == "Private" then
		chatType = 2
	end
	---- we need to grab the region they are from then filter out the text message
	local region = PlayerList.getPlayer(player)
	local filteredMessage;
	local successMessage, errorTextMessage = pcall(function()
		filteredMessage = TextService:FilterStringAsync(message, player.UserId, chatType) ---1 for public, 2 for private
	end)
	if successMessage then
		print("SENDING MESSAGE BACK"..tostring(region)..tostring(filteredMessage))
		if channel == "Global" then
			MessageDB:FireAllClients(player.UserId,filteredMessage:GetChatForUserAsync(player.UserId), region, "GLOBAL", nil)
			messageStorageDB.globalChatAdd(player, message, region, timeStamp)
		elseif channel == "Group" then
			local inChannel = messageStorageDB.IsInGroup(player)
			if inChannel then
				-- resume the message
				local Members  = messageStorageDB.getGroupMembers(player)
				for _, MemberPlayer in pairs(Members) do
					MessageDB:FireClient(MemberPlayer, player.UserId, filteredMessage:GetChatForUserAsync(player.UserId), region, "GROUP" , nil, false)

				end
				-- Now store in DataBase
				messageStorageDB.groupMessagesAdd(player,message, timeStamp, region)
			else
				MessageDB:FireClient(player, player.UserId, "Not currently in a group", "None", "GROUP" , nil, true)

			end
		elseif channel == "Private" then
			if optionalInvite == nil then
				if systemMessage then
					--- New user connection has been made, connect booth sender and other to storage
					MessageDB:FireClient(Players:GetPlayerByUserId(optionalSender), optionalSender, "YOU ARE NOW CHATTING WITH: "..player.Name, "None", "PRIVATE" , nil, true)
					MessageDB:FireClient(player, optionalSender, "YOU ARE NOW CHATTING WITH: "..Players:GetPlayerByUserId(optionalSender).Name, "None", "PRIVATE" , nil, true)

					print("WE ARE CREATING THE USERS HERE~1".."  :User: "..tostring(player).. "    :Sender:"..tostring( Players:GetPlayerByUserId(optionalSender)))
					messageStorageDB.individualCreate(player, Players:GetPlayerByUserId(optionalSender))
				else
					-- We are sending private message, grab other and if none exist return a NO PRIVATE USER FOUND back

					local OtherPlayer = messageStorageDB.individualGetOther(player)
					if OtherPlayer == nil then
						--send warning
						MessageDB:FireClient(player, player.UserId, "NO PRIVATE USER FOUND", "None", "PRIVATE" , nil, true)


					else
						MessageDB:FireClient(OtherPlayer, player.UserId, filteredMessage:GetChatForUserAsync(player.UserId), region, "PRIVATE" , nil, false)
						MessageDB:FireClient(player, player.UserId, filteredMessage:GetChatForUserAsync(player.UserId), region, "PRIVATE" , nil, false)
						---Now add it in the DataStorage

						messageStorageDB.individualMessagesAdd(player, OtherPlayer, message, region)
					end

				end
			else

				print("senging it to"..tostring(optionalSender).."   "..tostring(filteredMessage:GetChatForUserAsync(player.UserId)).."  "..tostring(region))
				--- We are just sending an invite, do nto store this into their DB
				MessageDB:FireClient(optionalSender,player.UserId, filteredMessage:GetChatForUserAsync(player.UserId), region, "PRIVATE" , "INVITE")
			end
		end


	else
		MessageDB:FireClient(player, "MESSAGE COULD NOT BE SENT, ONLY YOU CAN SEE THIS", region, "GLOBAL")
	end

end)
MessageChangeDB.OnServerEvent:Connect(function(player, scope, mode)
	if scope == "PRIVATE" then
		if mode == "DELETE" then
			-- use does not want to continue chatting
			local OtherPlayer = messageStorageDB.individualGetOther(player)
			if OtherPlayer ~= nil then
			local deleteOperation = 	messageStorageDB.individualDelete(player, OtherPlayer)
				if deleteOperation == nil then
					MessageDB:FireClient(player, player.UserId, "COULD NOT QUIT CHAT, PLEASE REMOTE THIS ERROR ON FORUM", "None", "PRIVATE" , nil, true)

				else
					MessageDB:FireClient(OtherPlayer, player.UserId, "EITHER YOU OR OTHER USER ENDED CHAT", "None", "PRIVATE" , nil, true)
					MessageDB:FireClient(player, player.UserId, "EITHER YOU OR OTHER USER ENDED CHAT", "None", "PRIVATE" , nil, true)

				end

			else
				MessageDB:FireClient(player, player.UserId, "Could not delete chat, chat is Non Existing", "None", "PRIVATE" , nil, true)

			end

		end
	end
end)
local function createGroup(player, title, mode, optionalSender, private)
	print("Getting a singal for group"..tostring(mode))
	if mode == "CREATION" then
		print("WE ARE UNDER CREATION")
		--- check to see if name already exists
		local Exist = messageStorageDB.groupMessageNameExist(string.gsub(title, " ", ""))
		local inChannel = messageStorageDB.IsInGroup(player)
		local filteredTitle;
		local filteredTitle2;
		local successMessage, errorTextMessage = pcall(function()
			filteredTitle = TextService:FilterStringAsync(title, player.UserId, 1) ---1 for public, 2 for private
		end)

		local sucessWordCheck, errorText = pcall(function()
			filteredTitle2 = TextService:FilterStringAsync(string.gsub(title, " ", ""), player.UserId, 1)
		end)

		local reversedWord = string.reverse(filteredTitle2:GetChatForUserAsync(player.UserId))
		local isreversed = reversedWord == filteredTitle2:GetChatForUserAsync(player.UserId)

		if Exist or  not successMessage  or   isreversed  then
			----- Send a warning somehow
			return nil
		else
			if not inChannel then
				local maxSize = BaseModule.getPlayerData(player)["GroupChatSize"]
				print("MAX SIZE FOR CHAT"..tostring(maxSize))
				messageStorageDB.CreateGroup(player, filteredTitle:GetChatForUserAsync(player.UserId),maxSize , private)
			--- Now message channel that the user may now use it
				MessageDB:FireClient(player, player.UserId, "WELCOME TO THE "..title.." CHANNEL", "None", "GROUP" , nil, true)
				return title
			else
				MessageDB:FireClient(player, player.UserId, "YOU  ARE ALREADDY IN A GROUP", "None", "GROUP" , nil, true)
				return nil
			end
		end

	elseif mode == "MEMBERREQUEST" then
		--- Add reques to backLog to avoid spamming, then notify owner of request, onoly if ur group size is enough
		local groupExists = messageStorageDB.GroupExist(title)
		if messageStorageDB.ReadMaxPlayers(title) ~= table.getn(messageStorageDB.SendGroupData(title)["Members"]) and  groupExists then


		local form = messageStorageDB.ModifyGroup(player,  title,"Requests",  player,"Add")

		local owner = messageStorageDB.SendGroupData(title)["Owner"]
		NotificationBell:FireClient(owner, "CAMPFIRE", player.Name.." Has requested to Join your group","ACCEPT", "GROUPREQUEST", title  , "ALERT", player) ---Player


			return form
		else
			return false
		end

	elseif mode == "MEMBERREQUESTREMOVE"	 then
		local form = messageStorageDB.ModifyGroup(player,  title,"Requests",  optionalSender,"Delete")

		return form
	elseif mode ~= nil and mode == "MAXMEMBERS" then
		return  messageStorageDB.ReadMaxPlayers(title)
	elseif mode ~= nil and mode == "PLAYERGROUP" then
		return  messageStorageDB.ReadGroupName(player)
	elseif mode == "MEMBERREQUESTACCEPT" then

		local form = messageStorageDB.ModifyGroup(player,  title,"Requests",  optionalSender,"Delete") -- DELETE FIRST


		local NewUser =  messageStorageDB.ModifyGroup(player,  title,"Members",  optionalSender,"Add") -- Add user



		if NewUser == nil then
			--- Other person has beeen accepted to a different group already
			MessageDB:FireClient(player, player.UserId, "User you attempted to add is already in a  group", "None", "GROUP" , nil, true)

		else
			MessageDB:FireClient(optionalSender, optionalSender.UserId, "WELCOME TO THE "..title.." CHANNEL", "None", "GROUP" , nil, true)  -- Notify on their chats
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupChange"):FireClient(optionalSender, title, "ENTER") -- either enter or leave
			local Members  = messageStorageDB.getGroupMembers(player)
			for _, MemberPlayer in pairs(Members) do
				if MemberPlayer ~= optionalSender then
					MessageDB:FireClient(MemberPlayer, player.UserId, "New member Added", "None", "GROUP" , nil, true)
					game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupChange"):FireClient(MemberPlayer, title, "NEWMEMBER") -- either enter or leave

				end
			end


			local isPrivate = messageStorageDB.SendGroupData(title)["Private"]
			local owner = messageStorageDB.SendGroupData(title)["Owner"]
			if isPrivate then
				---- Update Owner Log
				game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupMemberCount"):FireClient(owner)


			end

		end
		return NewUser

	elseif mode == "LEAVE" then
		-- Grab local owner
		local owner = messageStorageDB.GetOwner(title)
		if owner == player then
			---- OWNER IS TRYING TO DISMANTLE THE GROUP, SEND NOTIFICATIONS VIA CHAT TO EVERYONE
			local members = messageStorageDB.SendGroupData(title)["Members"]
			local form = messageStorageDB.ModifyGroup(owner,  title,"Requests", owner,"GroupDelete") -- DELETE FIRST
			if form == nil then
				MessageDB:FireClient(owner, player.UserId, "YOU ARE NOT THE OWNER, REPORT THIS ERROR", "None", "GROUP" , nil, true)
			else
				MessageDB:FireClient(owner, owner.UserId, "YOU HAVE DELETED CHANNEL", "None", "GROUP" , nil, true)
				game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupChange"):FireClient(owner, title, "LEAVE") -- either enter or leave

				for _, member in pairs(members) do
					if member ~= owner then
						MessageDB:FireClient(member, member.UserId, "OWNER HAS DELETE CHATROOM", "None", "GROUP" , nil, true)
						game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupChange"):FireClient(member, title, "LEAVE") -- either enter or leave

					end
				end

				return form
			end
		else
			--- Rember to update chat and their individual GroupUI
			local form = messageStorageDB.ModifyGroup(owner,  title,"Members", player,"Delete") -- DELETE FIRST
			local members;
			if messageStorageDB.SendGroupData(title) == nil then
				--- Player is spamming creation/LeaveButton Button---
				MessageDB:FireClient(player, player.UserId, "STOP SPAMMING!, THIS CAN LEAD TO BANNING", "None", "GROUP" , nil, true)
				return nil
			else
				members = messageStorageDB.SendGroupData(title)["Members"]

			end

			for _, member in pairs(members) do

				MessageDB:FireClient(member, member.UserId, player.Name.." Has Left the group", "None", "GROUP" , nil, true)
				game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GroupChange"):FireClient(member, title, "LEAVE") -- This will update they UI and TAG

			end
			return form

		end

	elseif mode == "GETGROUPDATA" then
		return messageStorageDB.SendGroupData(title)
	elseif mode == "CHECKPLAYERGROUP" then
		return messageStorageDB.IsInGroup(player)
	end
	return nil
end
groupCreation.OnServerInvoke = createGroup


local function createPath(player, shopPosition)
	local character;
	if game.Workspace:FindFirstChild(player.Name) then
		character = game.Workspace[player.Name]
	end
	-- Create the path object
	local path = PathfindingService:CreatePath()

	-- Compute the path
	path:ComputeAsync(character.HumanoidRootPart.Position, shopPosition)

	-- Get the path waypoints
	local waypoints = path:GetWaypoints()




	return waypoints
end


UINavigation.OnServerInvoke = createPath
playerCycle.OnServerEvent:Connect(function(player, mode)

	----When a player Died connect it here
	if mode == "ADD" then
		playerCycleModule.DeadUsersAdd(player.UserId)
	elseif mode == "REMOVE" then
		playerCycleModule.DeadUsersDelete(player.UserId)

	end
end)
DeadScreen.OnServerEvent:Connect(function(player, mode, loadPlayer)
	if loadPlayer ~= nil  and loadPlayer then
		player:LoadCharacter()
	else
		DeadScreen:FireClient(player, mode)

	end

end)

NewLocation.OnServerEvent:Connect(function(player, wayPoints)
	NewLocation:FireClient(player, wayPoints) --- echo response back 200 Ok
end)
--dropItem.OnServerEvent:Connect(function(player, objectName, position)
--	local object = game:GetService("ServerStorage"):WaitForChild(objectName):Clone()
--	object:SetPrimaryPartCFrame(position)
--	object.Parent = game.Workspace
--end)
