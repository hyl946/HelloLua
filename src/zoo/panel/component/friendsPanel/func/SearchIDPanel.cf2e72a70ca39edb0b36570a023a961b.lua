local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"

local Input = require "zoo.panel.phone.Input"

local SearchIDPanel = class(BasePanel)
function SearchIDPanel:create()
	local panel = SearchIDPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.friends_panel)
	panel:init()
	return panel
end

function SearchIDPanel:init(ui)
	self.ui = self:buildInterfaceGroup("interface/SearchByIDPane")
	BasePanel.init(self, self.ui)

	local close = self.ui:getChildByName("btnClose")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	
	self.addFriendPanelLogic = AddFriendPanelLogic:create()
	self.context = self

	self.isActive = true -- hack this
    
    self:initContent()
end

function SearchIDPanel:unloadRequiredResource( ... )
end

function SearchIDPanel:initContent()
	self:_tabSearch_init(self.ui:getChildByName("content"))
end

function SearchIDPanel:__toActive(byDefault)
	SuperCls.__toActive(self, byDefault)

	if not byDefault then
		self.tabSearch.input:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self.tabSearch.input, ccp()))
	end

	if self.tabSearch ~= nil and self.tabSearch.xxlIDInput ~= nil then
		self.tabSearch.xxlIDInput:show()
	end
end

function SearchIDPanel:__toDeActive()
	if self.tabSearch ~= nil and self.tabSearch.xxlIDInput ~= nil then
		self.tabSearch.xxlIDInput:hide()
	end
	SuperCls.__toDeActive(self)
end

function SearchIDPanel:_tabSearch_removeSearchResult()
	self.tabSearch.input.btnLoad:setVisible(false)
	self.tabSearch.noUserImg:setVisible(false)
	self.tabSearch.noUserText:setString("")
	self.tabSearch.userImg:setVisible(false)
	if self.tabSearch.userHead then
        self.tabSearch.userHead:setVisible(false)
		self.tabSearch.userHead:removeFromParentAndCleanup(true) 
		self.tabSearch.userHead = nil
	end
	self.tabSearch.userName:setVisible(false)
	self.tabSearch.starIcon:setVisible(false)
	self.tabSearch.userStar:setVisible(false)
	self.tabSearch.userACG:setVisible(false)
	self.tabSearch.userLevel:setVisible(false)
	self.tabSearch.bgResultBG:setVisible(false)
	self.tabSearch.btnAdd:setVisible(false)
	self.tabSearch.btnAdd:setEnabled(false)
end

function SearchIDPanel:runHideSearchResultAction(noAnim)
	if self.isDisposed then return end

	if not noAnim then
		self:cancelRunHideTimeOut()

		local TAG = 601
		self.tabSearch.resultCell:stopActionByTag(TAG)

		local action = CCSequence:createWithTwoActions(CCFadeOut:create(0.5), 
													   CCCallFunc:create(function() 
													   							self:_tabSearch_removeSearchResult() 
													   							self:showGameID()
													   					  end))
		action:setTag(TAG)
		self.tabSearch.resultCell:runAction(action)
	else
		self.tabSearch.resultCell:setOpacity(0)
		self:_tabSearch_removeSearchResult() 
		self:showGameID()
	end
end

function SearchIDPanel:showGameID()
	self.tabSearch.inviteText:setVisible(true)
	self.tabSearch.inviteCode:setVisible(true)
	self.copyBtn:setVisible(true)
	self.copyBtn.canClk = true
	--self.tabSearch.inviteBtn:setVisible(not PlatformConfig:isJJPlatform())
end
------------------------------------------
-- TabSearch
------------------------------------------
function SearchIDPanel:_tabSearch_init(ui)
	-- get & create controls
	self.tabSearch = {}
	self.tabSearch.ui = ui
	self.tabSearch.resultCell = ui:getChildByName("resultCell")
	self.tabSearch.btnAdd = self.tabSearch.resultCell:getChildByName("btn_add")
	self.tabSearch.btnAdd = GroupButtonBase:create(self.tabSearch.btnAdd)
	self.tabSearch.bgResultBG = self.tabSearch.resultCell:getChildByName("bg_resultArea"):getChildByName("bg")
	self.tabSearch.starIcon = self.tabSearch.resultCell:getChildByName("StarIcon")
	self.tabSearch.userName = self.tabSearch.resultCell:getChildByName("lbl_userName")
	self.tabSearch.userStar = self.tabSearch.resultCell:getChildByName("lbl_userStar")
	self.tabSearch.userACG = self.tabSearch.resultCell:getChildByName("lbl_userACG")
	self.tabSearch.userLevel = self.tabSearch.resultCell:getChildByName("lbl_userLevel")
	self.tabSearch.userImg = self.tabSearch.resultCell:getChildByName("img_userImg")
	self.tabSearch.noUserImg = self.tabSearch.resultCell:getChildByName("img_noUser")
	self.tabSearch.noUserText = self.tabSearch.resultCell:getChildByName("lbl_noUser")
	local bgResultIndex = ui:getChildIndex(self.tabSearch.resultCell)

	self.tabSearch.btnAdd.groupNode:removeFromParentAndCleanup(false)
	self.tabSearch.bgResultBG:removeFromParentAndCleanup(false)
	self.tabSearch.userName:removeFromParentAndCleanup(false)
	self.tabSearch.starIcon:removeFromParentAndCleanup(false)
	self.tabSearch.userStar:removeFromParentAndCleanup(false)
	self.tabSearch.userACG:removeFromParentAndCleanup(false)
	self.tabSearch.userLevel:removeFromParentAndCleanup(false)
	self.tabSearch.userImg:removeFromParentAndCleanup(false)
	self.tabSearch.noUserImg:removeFromParentAndCleanup(false)
	self.tabSearch.noUserText:removeFromParentAndCleanup(false)

	local tempContainer = LayerColor:create()
	tempContainer:setCascadeOpacityEnabled(true)
	
	tempContainer:setPositionXY(self.tabSearch.resultCell:getPositionX(), self.tabSearch.resultCell:getPositionY())
	tempContainer:addChild(self.tabSearch.bgResultBG)
	tempContainer:addChild(self.tabSearch.btnAdd.groupNode)
	tempContainer:addChild(self.tabSearch.userName)
	tempContainer:addChild(self.tabSearch.starIcon)
	tempContainer:addChild(self.tabSearch.userStar)
	tempContainer:addChild(self.tabSearch.userACG)
	tempContainer:addChild(self.tabSearch.userLevel)
	tempContainer:addChild(self.tabSearch.userImg)
	tempContainer:addChild(self.tabSearch.noUserImg)
	tempContainer:addChild(self.tabSearch.noUserText)
	local cellP = self.tabSearch.resultCell:getParent()
	cellP:addChildAt(tempContainer, bgResultIndex)
	self.tabSearch.resultCell:removeFromParentAndCleanup(true)
	self.tabSearch.resultCell = tempContainer

	self.tabSearch.bgResultBG:setPreferredSize(CCSizeMake(464, 274))
	
	self.tabSearch.input = ui:getChildByName("ipt_input")
	-- self.tabSearch.input.focused = self.tabSearch.input:getChildByName("focused")
	self.tabSearch.input.text = self.tabSearch.input:getChildByName("text")
	self.tabSearch.input.reBecomeTopStack = function()
    	self:reBecomeTopStack()
    end
    self.tabSearch.input.becomeSecondStack = function()
    	self:becomeSecondStack()
    end
	self.tabSearch.input.btnLoad = self.tabSearch.input:getChildByName("btnLoad")
	self.tabSearch.input.btnCancel = self.tabSearch.input:getChildByName("btnCancel")
	self:createInput()
	self.tabSearch.inviteText = ui:getChildByName("lbl_share")
	self.tabSearch.inviteCode = ui:getChildByName("lbl_code")
	--self.tabSearch.inviteBtn = ui:getChildByName("btn_share")
	--self.tabSearch.inviteBtn = ButtonIconsetBase:create(self.tabSearch.inviteBtn)
	--self.tabSearch.inviteBtn:setColorMode(kGroupButtonColorMode.blue)
	self.copyBtn = GroupButtonBase:create(ui:getChildByName("copyBtn"))
	self.copyBtn:setString("复制")
	local myInviteCode = AddFriendPanelModel:getUserInviteCode()
	if myInviteCode ~= nil and #myInviteCode >= 9 and #myInviteCode <= 11 and tonumber(myInviteCode) ~= nil then
    	self.copyBtn:setEnabled(true, 0, false)
    	self.copyBtn.canClk = true
    	self.copyBtn:addEventListener(DisplayEvents.kTouchTap, function (event)
    	    if not self.copyBtn.inClk and self.copyBtn.canClk then
    	        self.copyBtn.inClk = true
    	        setTimeOut(
					function( ... ) 
						if self.copyBtn ~= nil and not self.copyBtn.isDisposed then 
							self.copyBtn.inClk = false 
						end 
					end, 0.5)
    	        local preStr = localize("addfriend_copy_sms_pre")
    	        local tagStr = localize("addfriend_copy_sms_tag")
    	        ClipBoardUtil.copyText(preStr .. myInviteCode .. tagStr)
    	        CommonTip:showTip(localize("addfriend_auto_add_copy_sucess"), "positive") 
    	        local dcData = {}
				dcData.category = "add_friend"
				dcData.sub_category = "copyID"
				dcData.t1 = 2
				DcUtil:log(AcType.kUserTrack, dcData, true)
    	    end
    	end)
	else
		self.copyBtn:setVisible(false)
	end

	--[[self.tabSearch.wdjBtn = GroupButtonBase:create(self.tabSearch.ui:getChildByName('btn_wdj'))
		local wdjLocator = self.tabSearch.ui:getChildByName('ver.WDJ_WdjBtnLocator')
		local wechatLocator = self.tabSearch.ui:getChildByName('ver.WDJ_WechatBtnLocator')]]--

	-- set strings
  
	local tmpstr = Localization:getInstance():getText("add.friend.panel.input.tip")
	if __WP8 then tmpstr = tmpstr:gsub("•", "●") end
	-- self.tabSearch.inputText:setString(tmpstr)
  
	self.tabSearch.input.text:setString("")
	self.tabSearch.noUserText:setString(Localization:getInstance():getText("add.friend.panel.no.user.text"))
	self.tabSearch.userName:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	self.tabSearch.userStar:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	self.tabSearch.userACG:setString(Localization:getInstance():getText("friends.panel.unknow.acg"))
	self.tabSearch.userLevel:setString(Localization:getInstance():getText("add.friend.panel.no.user.level"))
	self.tabSearch.btnAdd:setString(Localization:getInstance():getText("add.friend.panel.btn.add.text"))
  
	tmpstr = Localization:getInstance():getText("friends.friend.addByXXL.code.desc")
	if __WP8 then tmpstr = tmpstr:gsub("•", "●") end
	self.tabSearch.inviteText:setString(tmpstr)
	--[[self.tabSearch.inviteBtn:setString(Localization:getInstance():getText("invite.friend.panel.invite.button"))
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		self.tabSearch.inviteBtn:setString(localize("invite.friend.panel.button.text.mitalk"))
	end]]--

	-- set status
	local code = tostring(AddFriendPanelModel:getUserInviteCode())
	if code and string.len(code) > 0 and code ~= "nil" then
		--self.tabSearch.inviteCode:setPreferredSize(331, 65)
		self.tabSearch.inviteCode:changeFntFile('fnt/tutorial_white.fnt')
		self.tabSearch.inviteCode:setRichText(code, '0296FF')
		self.tabSearch.inviteCode:setScale(1.4)
		local position = ccp(self.tabSearch.inviteCode:getPositionX() + 20, self.tabSearch.inviteCode:getPositionY() + 15)
		self.tabSearch.inviteCode:setPosition(position)
	else
		self.tabSearch.inviteText:setVisible(false)
		self.tabSearch.inviteCode:setVisible(false)
	end
	self.tabSearch.input.btnCancel:setVisible(false)
	-- self.tabSearch.input.focused:setVisible(false)
	local pos = self.tabSearch.input.btnLoad:getPosition()
	local size = self.tabSearch.input.btnLoad:getGroupBounds().size
	self.tabSearch.input.btnLoad:setAnchorPoint(ccp(0.5, 0.5))
	self.tabSearch.input.btnLoad:setPosition(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
	self.tabSearch.input.btnLoad:runAction(CCRepeatForever:create(CCRotateBy:create(1, 360)))
	self.tabSearch.userImg:setVisible(false)

	local shareType = SnsUtil.getShareType()
	-- local icon = ShareShowUtil.getInstance():getBtnIconByType(shareType)
	-- icon:setAnchorPoint(ccp(0, 1))
	--self.tabSearch.inviteBtn:setIcon(icon, true)

	--[[if PlatformConfig:isJJPlatform() then
		self.tabSearch.inviteBtn:setVisible(false) 
		self.tabSearch.wdjBtn:removeFromParentAndCleanup(true)
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) or PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		self.tabSearch.wdjBtn:setPosition(ccp(wdjLocator:getPositionX(), wdjLocator:getPositionY()))
		self.tabSearch.inviteBtn:setPosition(ccp(wechatLocator:getPositionX(), wechatLocator:getPositionY()))
		self.tabSearch.wdjBtn:setScale(self.tabSearch.wdjBtn:getScale() * 0.8)
		self.tabSearch.inviteBtn:setScale(self.tabSearch.inviteBtn:getScale() * 0.8)
	else
	 	self.tabSearch.wdjBtn:removeFromParentAndCleanup(true) 
	end

	if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) then
		self.tabSearch.wdjBtn:setString(localize("invite.friend.panel.button.text.wdj"))
	end

	if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		self.tabSearch.wdjBtn:setString(localize("invite.friend.panel.button.text.360"))
	end

	wdjLocator:removeFromParentAndCleanup(true)
	wechatLocator:removeFromParentAndCleanup(true)]]--

	local function onBtnAddTapped()
		if RequireNetworkAlert:popout() then
			self:_tabSearch_addFriend()
		end
	end
	self.tabSearch.btnAdd:addEventListener(DisplayEvents.kTouchTap, onBtnAddTapped)

	local function shareInviteCode()
		local function restoreBtn()
			if self.tabSearch.ui.isDisposed then return end
			if not self.tabSearch.ui:isVisible() then return end
			--if self.tabSearch.inviteBtn.isDisposed then return end
			--self.tabSearch.inviteBtn:setEnabled(true)
		end

		if __IOS_FB then
			SnsProxy:inviteFriends(nil)
		else
			local ipt = {
				onSuccess = restoreBtn,
				onError = restoreBtn,
				onCancel = restoreBtn,
			}
			--self.tabSearch.inviteBtn:setEnabled(false)
			setTimeOut(restoreBtn, 2)

			local shareType, delayResume = SnsUtil.getShareType()
			SnsUtil.sendInviteMessage( shareType, ipt )
		end
	end
	--self.tabSearch.inviteBtn:addEventListener(DisplayEvents.kTouchTap, shareInviteCode)

	--[[local function onWdjBtnTapped()
		self:onWdjBtnTapped()
	end
	if self.tabSearch.wdjBtn and not self.tabSearch.wdjBtn.isDisposed then
		self.tabSearch.wdjBtn:addEventListener(DisplayEvents.kTouchTap, onWdjBtnTapped)
	end]]--

	-- clear panel
	self:_tabSearch_removeSearchResult()

	-- block click while not in front
	self.tabSearch.hide = function()
		self.tabSearch.ui:setVisible(false)
		self.tabSearch.input:setTouchEnabled(false)
		self.tabSearch.input.btnCancel:setTouchEnabled(false)
		self.tabSearch.btnAdd:setVisible(false)
		self.tabSearch.btnAdd:setEnabled(false)
		--self.tabSearch.inviteBtn:setEnabled(false)
		--self.tabSearch.wdjBtn:setEnabled(false)
		self.copyBtn:setVisible(false)
		self.copyBtn.canClk = false
	end
	self.tabSearch.expand = function()
		self.tabSearch.input:setTouchEnabled(true)
		self.tabSearch.input.btnCancel:setTouchEnabled(true, 0, true)
		self.tabSearch.btnAdd:setVisible(true)
		self.tabSearch.btnAdd:setEnabled(true)
		--self.tabSearch.inviteBtn:setEnabled(true)
		--self.tabSearch.wdjBtn:setEnabled(true)
		self.tabSearch.ui:setVisible(true)
		self.copyBtn:setVisible(true)
		self.copyBtn.canClk = true
	end

	self.tabSearch.input.btnCancel:setTouchEnabled(true, 0, true)
	self.tabSearch.input.btnCancel:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkBtnCancel()
	end)
end

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--[[
kTextInputEvents = {
  kBegan = "began", kEnded = "ended", kChanged = "changed", kReturn = "return", kGotFocus = "gotFocus", kLostFocus = "lostFocus",
} 
]]
function SearchIDPanel:createInput( ... )
	local lableHolder = self.tabSearch.input:getChildByName("text")
	local xxlIDInput = Input:create(lableHolder, self.context, true)
	xxlIDInput:setPlaceHolder(localize("addfriend.panel.searchID.default"))--"请输入您的手机号"
	xxlIDInput:setInputMode(kEditBoxInputModeNumeric)
	xxlIDInput:setFontColor(ccc3(1,103,154))
	xxlIDInput.input:addEventListener(kTextInputEvents.kGotFocus, function()
		-- RemoteDebug:log("-------------------kGotFocus")
		-- RemoteDebug:uploadLog()
		self:onInputTextGotFocus()
	end)
	xxlIDInput.input:addEventListener(kTextInputEvents.kLostFocus, function()
		-- RemoteDebug:log("-------------------kLostFocus")
		-- RemoteDebug:uploadLog()
		self:onInputTextLostFocus()
	end)
	xxlIDInput.input:addEventListener(kTextInputEvents.kBegan, function()
		-- RemoteDebug:log("-------------------kBegan")
		-- RemoteDebug:uploadLog()
		self:onInputTextGotFocus()
	end)
	-- xxlIDInput.input:addEventListener(kTextInputEvents.kEnded, function()
	-- 	-- RemoteDebug:log("-------------------kEnded")
	-- 	-- RemoteDebug:uploadLog()
	-- 	self:onInputTextLostFocus()
	-- end)
	-- xxlIDInput.input:addEventListener(kTextInputEvents.kChanged, function()
	-- 	-- RemoteDebug:log("-------------------kChanged")
	-- 	-- RemoteDebug:uploadLog()
	-- end)
	xxlIDInput.input:addEventListener(kTextInputEvents.kReturn, function()
		-- RemoteDebug:log("-------------------kReturn")
		-- RemoteDebug:uploadLog()
		self:onInputTextLostFocus()
	end)

	self.tabSearch.input:addChild(xxlIDInput)
	xxlIDInput:setKeepPanelPos(true)
	self.tabSearch.xxlIDInput = xxlIDInput
end

function SearchIDPanel:onInputTextChanged()
	local xxlID = self.tabSearch.xxlIDInput:getText()
	if xxlID ~= nil and #xxlID > 0 then
		self.tabSearch.input.text:setVisible(true)
		self.tabSearch.input.btnCancel:setVisible(true)
		self.tabSearch.xxlID = xxlID
	end
end

function SearchIDPanel:onClkBtnCancel()
	self.curSearchID = nil
	self:showGameID()
	-- self.tabSearch.input.focused:setVisible(false)
	self:_tabSearch_removeSearchResult()
	self.tabSearch.input.btnCancel:setVisible(false)
	self.tabSearch.xxlIDInput.input:setText("")
	self.tabSearch.xxlIDInput:setPlaceHolder(localize("addfriend.panel.searchID.default"))--"请输入您的手机号"
end

function SearchIDPanel:onInputTextGotFocus()
	if self.isDisposed then return end
	self:cancelRunHideTimeOut()
	-- self.tabSearch.input.focused:setVisible(true)
	self.tabSearch.input.btnCancel:setVisible(false)
end

function SearchIDPanel:onInputTextLostFocus()
	if self.isDisposed then return end
	self:cancelRunHideTimeOut()

	local xxlID = self.tabSearch.xxlIDInput:getText()

	if xxlID == nil or #xxlID < 1 then
		-- self.tabSearch.input.focused:setVisible(false)
		self.tabSearch.xxlIDInput:setPlaceHolder(localize("addfriend.panel.searchID.default"))--"请输入您的手机号"
		self:runHideSearchResultAction()
	else
		-- self.tabSearch.input.focused:setVisible(false)
		self.tabSearch.input.btnCancel:setVisible(true)
		if xxlID ~= nil and #xxlID > 0 and self.isActive and self.curSearchID ~= xxlID then
			self.curSearchID = xxlID
			-- self.tabSearch.input.focused:setVisible(false)
			self.tabSearch.input.btnCancel:setVisible(true)
			self:_tabSearch_searchFriend(xxlID, #xxlID)
		end
	end
end

function SearchIDPanel:reBecomeTopStack()
	self.tabSearch.xxlIDInput:show()
end

function SearchIDPanel:becomeSecondStack()
	self.tabSearch.xxlIDInput:hide()
end

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

function SearchIDPanel:hideGameID()
	self.tabSearch.inviteText:setVisible(false)
	self.tabSearch.inviteCode:setVisible(false)
	self.copyBtn:setVisible(false)
	self.copyBtn.canClk = false
end

function SearchIDPanel:_showSearchResultUI( ... )
	if self.isDisposed then return end
	self:cancelRunHideTimeOut()

	self:_tabSearch_removeSearchResult()

	self.tabSearch.resultCell:setOpacity(255)
	self.tabSearch.bgResultBG:setVisible(true)
	self.tabSearch.userName:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	self.tabSearch.userStar:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	self.tabSearch.userACG:setString(Localization:getInstance():getText("friends.panel.unknow.acg"))
	self.tabSearch.userLevel:setString(Localization:getInstance():getText("add.friend.panel.no.user.level"))
	self.tabSearch.userImg:setVisible(false)
	self.tabSearch.userName:setVisible(true)
	self.tabSearch.starIcon:setVisible(true)
	self.tabSearch.userStar:setVisible(true)
	self.tabSearch.userACG:setVisible(true)
	self.tabSearch.userLevel:setVisible(true)
	self.tabSearch.input.btnCancel:setVisible(false)
	self.tabSearch.input.btnLoad:setVisible(true)
end

function SearchIDPanel:_tabSearch_searchFriend(code, length)
	

	local noUserTextStr = ""

	local function fakeLoadEnd()

		-- self:runHideSearchResultAction(true)
		self:_showSearchResultUI()

		self.curSearchID = nil
		self:hideGameID()
		self.tabSearch.userName:setVisible(false)
		self.tabSearch.starIcon:setVisible(false)
		self.tabSearch.userStar:setVisible(false)
		self.tabSearch.userACG:setVisible(false)
		self.tabSearch.userLevel:setVisible(false)
		self.tabSearch.userImg:setVisible(false)
		self.tabSearch.btnAdd:setVisible(false)
		self.tabSearch.btnAdd:setEnabled(false)
		if self.tabSearch.userHead then
			self.tabSearch.userHead:setVisible(false)
			self.tabSearch.userHead:removeFromParentAndCleanup(true) 
			self.tabSearch.userHead = nil
		end
		self.tabSearch.noUserImg:setVisible(true)
		self.tabSearch.noUserText:setString(noUserTextStr)
		self.tabSearch.input.btnLoad:setVisible(false)
		self.tabSearch.input.btnCancel:setVisible(true)
		--self.tabSearch.inviteBtn:setVisible(false)--(not PlatformConfig:isJJPlatform())
		self:setRunHideTimeOut(function()
			if self.tabSearch.noUserImg:isVisible() then
				self:runHideSearchResultAction()
			end
		end, 2)
	end

	local str_code = code

	if code ~= nil then code = tonumber(code) end

	-- 如果 code 超过 int 范围，那么 code ~= tostring(tonumber(code))
	if str_code ~= tostring(code) then 
		code = nil
	end


	if code == nil or length < 9 then
		noUserTextStr = Localization:getInstance():getText("add.friend.panel.no.user.text")
		-- self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(fakeLoadEnd)))
		fakeLoadEnd()
	elseif not UserManager:getInstance():isSameInviteCodePlatform(code) then 
		CommonTip:showTip(Localization:getInstance():getText("error.tip.add.friends"), "negative", nil, 3 )
		noUserTextStr = Localization:getInstance():getText("add.friend.panel.find.other.text")
		-- self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(fakeLoadEnd)))
		fakeLoadEnd()
	else
		self:_tabSearch_doSearchFriend(code)
	end
end

function SearchIDPanel:setRunHideTimeOut( func, timeout )
	self:cancelRunHideTimeOut()
	self.timeOutID = setTimeOut( func, timeout)
end

function SearchIDPanel:cancelRunHideTimeOut( ... )
	-- body
	if self.timeOutID then
		cancelTimeOut(self.timeOutID)
		self.timeOutID = nil
	end
end

function SearchIDPanel:_tabSearch_doSearchFriend(code)

	local function onSuccess(data, context)
		if self.ui.isDisposed  then return end

		-- self:runHideSearchResultAction(true)
		self:_showSearchResultUI()

		self:hideGameID()
		self.userInviteCode = code
		self:_tabSearch_updateFriendInfo(data)
		if _G.isLocalDevelopMode then printx(0, "_tabSearch_doSearchFriend success!!!!!!") end
	end

	local function onFail(err, context)
		if self.ui.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
		-- self:runHideSearchResultAction(true)
		self:_showSearchResultUI()

		self:_tabSearch_updateFriendInfo()
		if _G.isLocalDevelopMode then printx(0, "_tabSearch_doSearchFriend failed!!!!!!") end
		self.curSearchID = nil
	end

	local function onCancel(context)
		if self.ui.isDisposed then return end
		-- self:runHideSearchResultAction(true)
		self:_showSearchResultUI()
		self:_tabSearch_updateFriendInfo()
		self.curSearchID = nil
	end
	self.addFriendPanelLogic:searchUser(code, onSuccess, onFail, onCancel, self.tabStatus)
end

function SearchIDPanel:refresh()
	SuperCls.refresh(self)

	local ary = CCArray:create()
	ary:addObject(CCDelayTime:create(0.5))
	ary:addObject(CCCallFunc:create(function() 
			if self.ui == nil or self.ui.isDisposed then return end

			self.tabSearch.xxlIDInput:openKeyBoard() 
		end))
	self.ui:runAction(CCSequence:create(ary))
end

function SearchIDPanel:_tabSearch_updateFriendInfo(dataTable)
	if self.tabSearch.isDisposed then return end

	self.tabSearch.input.btnLoad:setVisible(false)
	self.tabSearch.input.btnCancel:setVisible(true)

	if dataTable then
		if #dataTable > 0 then
			local data = dataTable[1]
			if data.userLevel then
				self.tabSearch.userLevel:setString(Localization:getInstance():getText("add.friend.panel.user.info.level", {n = data.userLevel}))
			end
			if self.tabSearch.userHead then 
				self.tabSearch.userHead:removeFromParentAndCleanup(true) 
				self.tabSearch.userHead = nil
			end
			self.tabSearch.userHead = HeadImageLoader:createWithFrame(data.uid, data.headUrl, nil, nil, data.profile)
			if self.tabSearch.userHead then
				local position = self.tabSearch.userImg:getPosition()
				self.tabSearch.userHead:setAnchorPoint(ccp(-0.5, 0.5))
				self.tabSearch.userHead:setPosition(ccp(position.x, position.y))
				self.tabSearch.userImg:getParent():addChild(self.tabSearch.userHead)
				self.tabSearch.userImg:setVisible(false)
			else
				self.tabSearch.userImg:setVisible(false)
			end
			local userName = nameDecode(data.userName or "")
			if userName and string.len(userName) > 0 then self.tabSearch.userName:setString(userName) end

			local star = tonumber(data.star or 0) + tonumber(data.hideStar or 0)
			self.tabSearch.userStar:setString(tostring(star))

			local info = FriendsUtils:ACGINFO(data.profile, true)
			if info and info ~= "" then
				local secureInfo = TextUtil:ensureTextWidth(info, self.tabSearch.userACG:getFontSize(), self.tabSearch.userACG:getDimensions())
				if secureInfo then 
					info = secureInfo
				end
				self.tabSearch.userACG:setString(info)
			end
			
			self.tabSearch.userName:setVisible(true)
			self.tabSearch.starIcon:setVisible(true)
			self.tabSearch.userStar:setVisible(true)
			self.tabSearch.userACG:setVisible(true)
			self.tabSearch.userLevel:setVisible(true)
			self.tabSearch.btnAdd:setVisible(true)
			self.tabSearch.btnAdd:setEnabled(true)
		else
			if self.tabSearch.userHead then 
				self.tabSearch.userHead:setVisible(false)
			end
			self.tabSearch.userImg:setVisible(false)
			self.tabSearch.userName:setVisible(false)
			self.tabSearch.starIcon:setVisible(false)
			self.tabSearch.userStar:setVisible(false)
			self.tabSearch.userACG:setVisible(false)
			self.tabSearch.userLevel:setVisible(false)
			self.tabSearch.noUserImg:setVisible(true)
			self.tabSearch.btnAdd:setVisible(false)
			self.tabSearch.btnAdd:setEnabled(false)
			self.tabSearch.noUserText:setString(Localization:getInstance():getText("add.friend.panel.no.user.text"))
			-- if _G.isLocalDevelopMode then printx(0, "pre hide =========================================0") end
			self:setRunHideTimeOut(function()
							-- if _G.isLocalDevelopMode then printx(0, "pre hide ====================================", self.tabSearch.noUserImg:isVisible()) end
							if self.tabSearch.noUserImg:isVisible() then
								-- if _G.isLocalDevelopMode then printx(0, "pre hide =========================================1") end
								self:runHideSearchResultAction()
							end
						end, 2)
		end
	else
		self.tabSearch.bgResultBG:setVisible(false)
		self.tabSearch.userImg:setVisible(false)
		if self.tabSearch.userHead then 
			self.tabSearch.userHead:setVisible(false)
		end
		self.tabSearch.userName:setVisible(false)
		self.tabSearch.starIcon:setVisible(false)
		self.tabSearch.userStar:setVisible(false)
		self.tabSearch.userACG:setVisible(false)
		self.tabSearch.userLevel:setVisible(false)
		self.tabSearch.noUserImg:setVisible(false)
		self.tabSearch.noUserText:setString("")
		self.tabSearch.btnAdd:setVisible(false)
		self.tabSearch.btnAdd:setEnabled(false)
	end
end

function SearchIDPanel:_tabSearch_addFriend()
	local function onSuccess(data, context)
		if self.ui.isDisposed then return end
		DcUtil:sendInviteRequest(self.userInviteCode)
		CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.add.success"), "positive")
        self:runHideSearchResultAction()
		self.tabSearch.btnAdd:setEnabled(false)
	end
	local function onFail(err, context)
		if self.ui.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
	end
	self.addFriendPanelLogic:sendAddMessage(nil, onSuccess, onFail, nil, self.tabStatus, ADD_FRIEND_SOURCE.XXL_CODE)
end

function SearchIDPanel:onWdjBtnTapped(event)
	if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) then
	elseif PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		if not SnsProxy:isLogin() then 
			CommonTip:showTip(Localization:getInstance():getText("该功能需要360账号联网登录"), "positive")
			return 
		end
	else
		return
	end

	local function onSuccess(data)
		local dataTable = luaJavaConvert.map2Table(data)
		local count = 0
		if dataTable then 
			count = #dataTable
		end
		DcUtil:wdjInvite(count)
	end
	local function onError(data)
		if data then if _G.isLocalDevelopMode then printx(0, table.tostring(data)) end end
		if _G.isLocalDevelopMode then printx(0, 'error') end
	end

	local function onCancel(data)
		if data then if _G.isLocalDevelopMode then printx(0, table.tostring(data)) end end
		if _G.isLocalDevelopMode then printx(0, 'cancel') end
	end
	local callback = {onSuccess = onSuccess, onError = onError, onCancel = onCancel}
	SnsProxy:inviteFriends(callback)
	DcUtil:wdjClick()
end

function SearchIDPanel:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function SearchIDPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

return SearchIDPanel