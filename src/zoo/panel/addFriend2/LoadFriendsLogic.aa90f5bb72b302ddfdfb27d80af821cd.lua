local LoadFriendsLogic = class()

local logic = nil
local max_batch_count = 30
function LoadFriendsLogic:create()
	if not logic then
		logic = LoadFriendsLogic.new()
	end

	return logic
end


function LoadFriendsLogic:loadFriendsByPhoneNOs(phoneNumbers, onSuccess, onError, onCancel)

	local function onRequestSuccess(evt)
		local phoneNumberUids = evt.data and evt.data.phoneNumberUids or {}
		if _G.isLocalDevelopMode then printx(0, "phoneNumberUids: ", table.tostring(phoneNumberUids)) end

		local initProfiles = evt.data and evt.data.profiles or {}
		local uid2PhoneNumberMap = {}
		for __,v in ipairs(phoneNumberUids) do
				uid2PhoneNumberMap[tostring(v.second)] = tostring(v.first)
		end

		self.uid2ProfileMap = self.uid2ProfileMap or {}
		for _,v in pairs(initProfiles) do
			self.uid2ProfileMap[v.uid] = v
		end

		self.phoneNumberUids = phoneNumberUids

		if onSuccess then onSuccess(uid2PhoneNumberMap, initProfiles, evt.data) end
	end

	local function onRequestFail(evt)
		--nothing to do
		if onError then
			onError(evt.data)
		end
	end

	local function onRequestCancel(evt)
		--nothing to do
		if onCancel then onCancel() end
	end

    local http = LoadFriendsByPhoneNumbersHttp.new(false)
	http:addEventListener(Events.kComplete, onRequestSuccess)
	http:addEventListener(Events.kError, onRequestFail)
	http:addEventListener(Events.kCancel, onRequestCancel)

	--http:syncLoad(phoneNumbers)

	RequireNetworkAlert:callFuncWithLogged(function()
						http:syncLoad(phoneNumbers)
					end, 
					function()
						if onError then onError(200) end
					end, 
					kRequireNetworkAlertAnimation.kNoAnimation)
end

function LoadFriendsLogic:loadProfilesByUids(uids, onSuccess, onError)
	local function onRequestSuccess(evt)
		local profiles = evt.data and evt.data.profiles or {}

		local items4Append = {}
		--todo: create the items data for display;
		for k,v in pairs(profiles) do
			if not FriendManager.getInstance().friends[tostring(v.uid)] then
				local phoneNumber = self.uid2PhoneNumberMap[v.uid]
				local phoneName = self.contactlistInPhone[phoneNumber]
				v.phoneName = phoneName
				table.insert(items4Append, v)
				table.insert(self.items4Show, v)

				self.uid2ProfileMap[v.uid] = v
			end
		end

		if onSuccess then onSuccess(items4Append, evt.data) end
	end

	local function onRequestFail(evt)
		--nothing to do
		if onError then onError() end
	end

	local function onRequestCancel(evt)
		--nothing to do
		if onCancel then onCancel() end
	end

    local http = LoadProfilesByUidsHttp.new(false)
	http:addEventListener(Events.kComplete, onRequestSuccess)
	http:addEventListener(Events.kError, onRequestFail)
	http:addEventListener(Events.kCancel, onRequestCancel)

	RequireNetworkAlert:callFuncWithLogged(function()
						http:syncLoad(uids)
					end, 
					function()
						if onError then onError() end
					end, 
					kRequireNetworkAlertAnimation.kDefault)
end

function LoadFriendsLogic:getRemainingUids()
	local remainingUids = {}

	for k,v in pairs(self.uid2PhoneNumberMap) do
		if not self.uid2ProfileMap[k] and #remainingUids < max_batch_count then
			table.insert(remainingUids, k)
		end
	end

	return remainingUids
end

function LoadFriendsLogic:loadFriendsInContacts(onSuccess, onError, onCancel)
	local loadingAnimation = nil
	local loadFriendsCanceled = false

	local function removeLoading()
		if loadingAnimation then loadingAnimation:removeFromParentAndCleanup(true) end
	end

	local function loadFriendSuccess(uid2PhoneNumberMap, profiles, dataProvider)
		if loadFriendsCanceled then
			return
		end

		removeLoading()
		self.items4Show = {}
		self.uid2PhoneNumberMap = uid2PhoneNumberMap
		--todo: create the items data for display;
		if _G.isLocalDevelopMode then printx(0, "uid2PhoneNumberMap: ",table.tostring(uid2PhoneNumberMap)) end
		for k,v in pairs(profiles) do
			if not FriendManager.getInstance().friends[tostring(v.uid)] then
				local phoneNumber = uid2PhoneNumberMap[v.uid]
				local phoneName = self.contactlistInPhone[phoneNumber]
				v.phoneName = phoneName
				table.insert(self.items4Show, v)
			end
		end

		onSuccess(self.items4Show, dataProvider)
	end

	local function loadFriendsFailed(errCode)
		if loadFriendsCanceled then
			return
		end

		removeLoading()
		onError(errCode)
	end

	local callback = {
		onSuccess = function(result) 
			if loadFriendsCanceled then
				return
			end

			self.contactlistInPhone = result

        	local phoneNumberList = {}
        	for k,v in pairs(self.contactlistInPhone) do
        		if _G.isLocalDevelopMode then printx(0, "contactList retrived2, phoneNO: "..tostring(k)..", name:"..tostring(v)) end
        		table.insert(phoneNumberList, k)
        	end

        	if #phoneNumberList == 0 then
        		CommonTip:showTip(localize("add.friend.panel.add.phone.tip1"), 'negative')
        		removeLoading()
        		if _G.isLocalDevelopMode then printx(0, "phoneNumberList is empty!!!!!!!!!!!!!!") end
        		if onCancel then 
        			onCancel() 
        			if _G.isLocalDevelopMode then printx(0, "onCancel called!!!!!!") end
        		end
        	else
        		self:loadFriendsByPhoneNOs(phoneNumberList, loadFriendSuccess, loadFriendsFailed, onCancel)
        	end
        	
		end,
		onFailed = function(errCode)
			removeLoading()
			onError(errCode or 100)
		end,
		onCancel = function()
			-- body
			removeLoading()
			if onCancel then onCancel() end
		end
	}

	loadingAnimation = CountDownAnimation:createNetworkAnimation(
									Director:sharedDirector():getRunningScene(),
									function()
										loadFriendsCanceled = true
										loadingAnimation:removeFromParentAndCleanup(true)
										if onCancel then
											onCancel()
										end
										CommonTip:showTip(localize("add.friend.panel.cancel.phonebook"), 'negative')
									end,
									localize("loading.traversal.phonebook")
							)

	local contactDelegate = require("zoo.panel.addFriend2.ContactReader")
	contactDelegate:readContact(callback)
end

return LoadFriendsLogic