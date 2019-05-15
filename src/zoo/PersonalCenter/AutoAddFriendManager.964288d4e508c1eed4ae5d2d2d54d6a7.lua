AutoAddFriendManager = class()
local PanelCls =  require("zoo.PersonalCenter.AutoAddFriendPanel")

local mgr = nil
local personalCenterMgr
local panelCloseCallBack

function AutoAddFriendManager.getInstance()
	if mgr == nil then
		mgr = AutoAddFriendManager.new()
	end

	return mgr
end


function AutoAddFriendManager:setIsOpenBylink(isByLink)
	self.isOpenBylink = isByLink
end

function AutoAddFriendManager:getIsOpenBylink(isByLink)
	return self.isOpenBylink
end

function AutoAddFriendManager:clearIsOpenBylink()
	self.isOpenBylink = false
end

function AutoAddFriendManager.setPersonalCenterManager(personalCenterManager)
	personalCenterMgr = personalCenterManager
end

function AutoAddFriendManager:canPop(pasteStr, cb)
	if not PanelCls:canAddPop() then
		if cb then cb(false) end
		return
	end

	local mayNeedPop = false
	local myInviteCode = personalCenterMgr:getData(personalCenterMgr.INVITE_CODE)
	if myInviteCode ~= nil then
		myInviteCode = tostring(myInviteCode)
		if #myInviteCode >= 9 and #myInviteCode <= 11 and tonumber(myInviteCode) ~= nil then
			-- ClipBoardUtil.callWithClipboardText(function(pasteStr)
				local ret = false
				if pasteStr and #pasteStr > 0 then
					local preStr = localize("addfriend_copy_sms_pre")
					local tagStr = localize("addfriend_copy_sms_tag")
					local preStart, preEnd = string.find(pasteStr, preStr)
					local tagStart, tagEnd = string.find(pasteStr, tagStr)
					ret = preStart ~= nil and preEnd ~= nil and tagStart ~= nil and tagEnd ~= nil
					ret = ret and (preEnd + 1 < tagStart)

					if ret then
						local xxlID = string.sub(pasteStr, preEnd + 1, tagStart - 1)
						ret = ret and xxlID ~= nil and #xxlID > 8 and #xxlID < 11
						xxlID = tonumber(xxlID)
						ret = ret and xxlID ~= nil and xxlID > 0
					end
				end

				if cb then cb(ret) end
				return
			-- end)
		end
	end
end

function AutoAddFriendManager:autoAddCheck(pasteStr, closeCallback)
	panelCloseCallBack = closeCallback
	if not PanelCls:canAddPop() then
		closeCallback()
		return 
	end

	self.mayNeedPop = false
	local myInviteCode = personalCenterMgr:getData(personalCenterMgr.INVITE_CODE)
	if myInviteCode ~= nil then
		myInviteCode = tostring(myInviteCode)
		if #myInviteCode >= 9 and #myInviteCode <= 11 and tonumber(myInviteCode) ~= nil then
			-- ClipBoardUtil.callWithClipboardText(function(pasteStr)
				self:__autoAddCheck(pasteStr)	
			-- end)
		end
	end

	if not self.mayNeedPop then closeCallback() end
end

function AutoAddFriendManager:__autoAddCheck(pasteStr)
	if pasteStr ~= nil and #pasteStr > 0 then
		local preStr = localize("addfriend_copy_sms_pre")
		local tagStr = localize("addfriend_copy_sms_tag")
		local preStart, preEnd = string.find(pasteStr, preStr)
		local tagStart, tagEnd = string.find(pasteStr, tagStr)

		if preStart ~= nil and preEnd ~= nil and tagStart ~= nil and tagEnd ~= nil then --当前是复制了特定文案状态
			if preEnd + 1 < tagStart then
				local xxlID = string.sub(pasteStr, preEnd + 1, tagStart - 1) --提取消消乐号
				if xxlID ~= nil and #xxlID > 8 and #xxlID < 11 then --（2）真实的用户ID
					xxlID = tonumber(xxlID) 
					if xxlID ~= nil and xxlID > 0 then
						local selfID = tonumber(personalCenterMgr:getData(personalCenterMgr.INVITE_CODE))
						if selfID ~= nil and xxlID ~= selfID then --（3）如果检测是自己的ID ，流程结束。
							if WXJPPackageUtil.getInstance():isWXJPPackage() then 
								CommonTip:showTip(localize("error.tip.add.friends"), "negative")
								-- ClipBoardUtil.copyText("")
							elseif UserManager:getInstance():isSamePlatform(xxlID, selfID) then--相同平台，取对方用户数据
								self.mayNeedPop = true
								self:requestPlayerInfo(xxlID)
							else --（4）非应用宝和应用宝非同平台，提示用户不同平台无法添加，流程结束。
								local dcData = {}
								dcData.category = "add_friend"
								dcData.sub_category = "auto_eorre_yyb"
								DcUtil:log(AcType.kUserTrack, dcData, true)
								
								if UserManager:getInstance():isYYBInviteCodePlatform(selfID) then
									CommonTip:showTip(localize("addfriend_auto_add_yyb1"), "negative")
								else
									CommonTip:showTip(localize("addfriend_auto_add_yyb2"), "negative")
								end
								-- ClipBoardUtil.copyText("") -- bug fix
							end
						else
							if selfID ~= nil and xxlID == selfID then
								local dcData = {}
								dcData.category = "add_friend"
								dcData.sub_category = "auto_eorre"
								dcData.t1 = 3
								DcUtil:log(AcType.kUserTrack, dcData, true)
							else
								local dcData = {}
								dcData.category = "add_friend"
								dcData.sub_category = "auto_dev"
								dcData.t1 = 2
								DcUtil:log(AcType.kUserTrack, dcData, true)
								-- ClipBoardUtil.copyText("")
							end
						end
					else
						local dcData = {}
						dcData.category = "add_friend"
						dcData.sub_category = "auto_dev"
						dcData.t1 = 2
						DcUtil:log(AcType.kUserTrack, dcData, true)
						-- CommonTip:showTip("not 真实的用户ID ，流程结束:" .. xxlID, "negative")
						-- ClipBoardUtil.copyText("")
					end
				end
			end
		end
	end
end

function AutoAddFriendManager:requestPlayerInfo(xxlID)
	local function onSuccess(evt)
		if type(evt.data.user) ~= "table" or type(evt.data.profile) ~= "table" then
			--玩家要自动添加的好友如果是不存在
			panelCloseCallBack()
			return
		end

		local scene = Director:sharedDirector():run()
		if scene == nil or not scene:is(HomeScene) then
			panelCloseCallBack()
			return
		end

		PanelCls:create(evt.data):popout(panelCloseCallBack)
	end
	local function onFail(evt)
		local dcData = {}
		dcData.category = "add_friend"
		dcData.sub_category = "auto_dev"
		dcData.t1 = 1
		DcUtil:log(AcType.kUserTrack, dcData, true)
		panelCloseCallBack()
	end

	local http = QueryUserHttp.new(false)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load(xxlID)

end