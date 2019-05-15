---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-15 15:34:18
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-02-10 10:17:48
---------------------------------------------------------------------------------------
local Panel = class(BasePanel)

function Panel:ctor()

end

function Panel:create(loginUserData, onAutoLoginCallback, onChangeAccountCallback)
	assert(type(loginUserData) == "table")
	local panel = Panel.new()
	panel:loadRequiredResource("ui/login.json")	
	panel:init(loginUserData, onAutoLoginCallback, onChangeAccountCallback)
	return panel
end

function Panel:init(loginUserData, onAutoLoginCallback, onChangeAccountCallback)
	self.ui = self:buildInterfaceGroup("preloadingscene_auto_login_panel")
	BasePanel.init(self, self.ui)

	self.ui:getChildByPath('loginPanel/headImgBg'):setVisible(false)

	self.onAutoLoginCallback = onAutoLoginCallback
	self.onChangeAccountCallback = onChangeAccountCallback

	local loginPanel = self.ui:getChildByName("loginPanel")
	local switchBtn = self.ui:getChildByName("switchBtn")

	self:initLoginPanel(loginPanel, loginUserData)

	local function onAutoLoginTapped(evt)
		self:onAutoLoginTapped(evt)
	end
	loginPanel:setTouchEnabled(true)
	loginPanel:ad(DisplayEvents.kTouchTap, onAutoLoginTapped)

	local function onSwitchBtnTapped(evt)
		self:onSwitchBtnTapped(evt)
	end

	switchBtn:setButtonMode(true)
	switchBtn:setTouchEnabled(true)
	switchBtn:ad(DisplayEvents.kTouchTap, onSwitchBtnTapped)
end

function Panel:initLoginPanel(panelUi, loginUserData)
	local headImgHolder = panelUi:getChildByName("headImg")

	local nickNameLabel = panelUi:getChildByName("nickName")
	local statusLabel = panelUi:getChildByName("status")
	local loadingAnim = panelUi:getChildByName("animation")
	local animPos = loadingAnim:getPosition()

	local count = 0
	local function playAnimate()
		loadingAnim:setChildrenVisible(false, true)
		if count > 0 then
			loadingAnim:getChildByName("a"..tostring(count)):setVisible(true)
		end
		count = count + 1
		if count > 3 then count = 0 end
	end
	local animate = CCSequence:createWithTwoActions(CCCallFunc:create(playAnimate), CCDelayTime:create(0.3))
	loadingAnim:runAction(CCRepeatForever:create(animate))

	local uid = loginUserData.uid
	local authorizeType = SnsProxy:getAuthorizeType()
	local snsInfo = nil
	local profile
	if loginUserData.profile and authorizeType then
		profile = ProfileRef.new()
		profile:fromLua( loginUserData.profile )
	 	snsInfo = profile:getSnsInfo(authorizeType)
	end
	local nickName = profile and profile:getDisplayName() or nil
	local headUrl = profile and profile.headUrl or 1
	if not nickName or string.len(nickName) < 1 then
		nickName = loginUserData.inviteCode or "游客"
	end
	nickName = TextUtil:ensureTextWidth( nickName, nickNameLabel:getFontSize(), nickNameLabel:getDimensions() )
	if nickName then nickNameLabel:setString(nickName.." ") end
	-- statusLabel:setString("正在登录中...")

	local headImgSize = headImgHolder:getGroupBounds().size
	local imgWidth = headImgSize.width
	local imgHeight = headImgSize.height
	local function onImageLoadFinishCallback(headImg)
		local cSize = headImg:getContentSize()
		headImg:setScale(imgWidth / cSize.width, imgHeight / cSize.height)
	end
	local headImg = HeadImageLoader:createWithDesignatedFrame(uid, headUrl, nil, HeadFrameType.kNormal, HeadFrameStyle.k1)
	headImg:setPosition(ccp(headImgHolder:getPositionX() + imgWidth / 2, headImgHolder:getPositionY() - imgHeight / 2))
	panelUi:addChild(headImg)

	headImgHolder:removeFromParentAndCleanup(true)
end

function Panel:onAutoLoginTapped(evt)
	if self.onAutoLoginCallback then self.onAutoLoginCallback() end
end

function Panel:onSwitchBtnTapped(evt)
	if self.onChangeAccountCallback then self.onChangeAccountCallback() end
end

function Panel:onCloseBtnTapped()

end

function Panel:unloadRequiredResource()

end

return Panel