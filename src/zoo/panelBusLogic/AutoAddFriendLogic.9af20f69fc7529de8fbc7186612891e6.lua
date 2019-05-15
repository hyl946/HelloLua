-- 通过链接自动添加好友
-- http://wiki.happyelements.net/pages/viewpage.action?pageId=23532043

AutoAddFriendLogic = class()

function AutoAddFriendLogic:create()
	local logic = AutoAddFriendLogic.new()
	logic:init()
	return logic
end

function AutoAddFriendLogic:init()
end

function AutoAddFriendLogic:start(uid, type, successCallback, failCallback, cancelCallback, context)

	local eType = tonumber(type) or -1
	if eType < ADD_FRIEND_SOURCE.ACTIVITY or eType >= ADD_FRIEND_SOURCE.UNKNOW then
		if failCallback then failCallback(0, context) end
		return
	end

	require("zoo.panel.component.friendsPanel.func.FriendsFullPanel")
	if FriendsFullPanel:checkFullZombieShow() then
	-- if FriendManager:getInstance():isFriendCountReachedMax() then
		if failCallback then failCallback(731014, context) end
		return
	end

	local friends = FriendManager.getInstance().friends or {}
	local profile = friends[tostring(uid)]
	if profile then
		if failCallback then failCallback(1, context) end
		return
	end

	local user = UserManager:getInstance():getUserRef()
	if uid == tostring(user.uid or '') then
		if failCallback then failCallback(2, context) end
		return
	end

	local function onSuccess(evt)
		if successCallback then successCallback(evt.data, context) end
	end

	local function onFail(evt)
		if failCallback then failCallback(evt.data, context) end
	end

	local function onCancel(evt)
		if cancelCallback then cancelCallback(evt.data, context) end
	end

	local http = RequestFriendHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(nil, uid, eType)
end