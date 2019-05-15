require 'zoo.data.LoginExceptionManager'

ExceptionPanel = class(CocosObject)

function ExceptionPanel:create(errCode, onUseLocalFunc, onUseServerFunc, isNoClose)
	if table.exist(ExceptionErrorCodeIgnore, errCode) then  
		errCode = LoginExceptionManager:getInstance():getErrorCodeCache()
	end
	local winSize = CCDirector:sharedDirector():getWinSize()
	local ret = ExceptionPanel.new(CCNode:create())
	ret:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	ret:buildUI(errCode, onUseLocalFunc, onUseServerFunc, isNoClose)
	return ret
end

function ExceptionPanel:setAlertEnable(noFirstClickAlert, noFixAlert)
	self.noFirstClickAlert = noFirstClickAlert
	self.noFixAlert = noFixAlert
end

function ExceptionPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function ExceptionPanel:buildUI(errCode, onUseLocalFunc, onUseServerFunc, isNoClose)
	self.shouldShowReportBtn = LoginExceptionManager:getInstance():getShouldShowReportBtn()
	-- 特殊处理：封号处理用户屏蔽反馈问题按钮
	if tostring(errCode) == "109" then
		self.shouldShowReportBtn = false
	end

	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(winSize.width, winSize.height)
	layer:setColor(ccc3(0,0,0))
	layer:setOpacity(255 * 0.4)
	layer:setTouchEnabled(true, 0, true)
	self:addChild(layer)
	self:setPosition(ccp(0, 0))

	local ui = self.builder:buildGroup("exceptionpanel")--ResourceManager:sharedInstance():buildGroup("exceptionpanel")
	local contentSize = ui:getGroupBounds().size

	ui:setPosition(ccp((winSize.width - contentSize.width)/2, (winSize.height + contentSize.height)/2))
	ui:getChildByName("titleLabel"):setString(Localization:getInstance():getText("exception.panel.tittle"))
	ui:getChildByName("dataInfoLabel"):setString("")

	--刷新错误码
	LoginExceptionManager:getInstance():updateErrorHistory(errCode)
	--提示文案
	self.tipLabel = LoginExceptionManager:getInstance():getLoginErrorTip(errCode, self.shouldShowReportBtn)
	ui:getChildByName("infoLabel"):setString(self.tipLabel)

	if not isNoClose then
		--关闭按钮
		local closeBtn = ui:getChildByName('closeBtn')
		local firstClick = true
	    closeBtn:setTouchEnabled(true, 0, true)
	    local function onCloseBtnTapped()
	    	if not self.noFirstClickAlert and firstClick and tostring(errCode) ~= "109" then 
	    		firstClick = false
	    		self:alert(Localization:getInstance():getText("error.tip.desc2"))
	    	else
		    	self:removeFromParentAndCleanup(true)
		    	LoginExceptionManager:getInstance():setShowFunsClubWithoutUserLogin(true)
		    	LoginExceptionManager:getInstance():setShouldShowFunsClub(false)
		    	if onUseLocalFunc ~= nil then onUseLocalFunc() end
		    end
	    end
	    closeBtn:ad(DisplayEvents.kTouchTap, onCloseBtnTapped)
	else
		ui:getChildByName('closeBtn'):setVisible(false)
	end

    --修复按钮
	local syncBtn = GroupButtonBase:create(ui:getChildByName("syncBtn"))
	if tostring(errCode) == "109" then
		syncBtn:setString("知道了")
		local function onSyncTouch(evt)
			if onUseLocalFunc ~= nil then onUseLocalFunc() end
		end
		syncBtn:ad(DisplayEvents.kTouchTap, onSyncTouch)
	else
		syncBtn:setString("修复问题")
		local function onSyncTouch(evt)
			DcUtil:loginException("click_repairs")
			self:removeFromParentAndCleanup(true)
			LoginExceptionManager:getInstance():setShowFunsClubWithoutUserLogin(false)
			LoginExceptionManager:getInstance():setShouldShowFunsClub(false)
			if onUseServerFunc ~= nil then onUseServerFunc() end
			if not self.noFixAlert then
				self:alert(Localization:getInstance():getText("exception.panel.commit.tips"))
			end
		end
		syncBtn:ad(DisplayEvents.kTouchTap, onSyncTouch)
	end

	--反馈按钮
    local reportBtn = GroupButtonBase:create(ui:getChildByName("reportBtn"))
    reportBtn:setString("反馈问题")
    reportBtn:setColorMode(kGroupButtonColorMode.blue)
    local function onReportTouch(evt)
    	DcUtil:loginException("click_feedback")
		self:removeFromParentAndCleanup(true)
		LoginExceptionManager:getInstance():setShowFunsClubWithoutUserLogin(false)
		LoginExceptionManager:getInstance():setShouldShowFunsClub(true)
		if onUseServerFunc ~= nil then onUseServerFunc() end
	end
	if __WP8 or not self.shouldShowReportBtn then
		reportBtn:setVisible(false)

		local oriPos = syncBtn:getPosition()
		syncBtn:setPosition(ccp(oriPos.x, oriPos.y - 80))
	else
		reportBtn:ad(DisplayEvents.kTouchTap, onReportTouch)
	end

	-- -- 显示最高关卡
	-- self:showTopLevel(ui)

	self:addChild(ui)
	return true
end

function ExceptionPanel:showTopLevel(ui)
	local function onGetUserFinish( evt )
		evt.target:rma()
		if evt.data then
			local user = evt.data.user
			if user and ui and ui.list then
				local topLevelId = user.topLevelId
				local updateTime = tonumber(user.updateTime)
				updateTime = updateTime / 1000
				local dataInfoLabel = {space=" ", num=topLevelId, data=os.date("%x %H:%M", updateTime)}
				ui:getChildByName("dataInfoLabel"):setString(Localization:getInstance():getText("exception.panel.top.level", dataInfoLabel))
			end
		end
	end
	local http = GetUserHttp.new()
	http:addEventListener(Events.kComplete, onGetUserFinish)
	http:load()
end

function ExceptionPanel:alert(message)
	CommonTip:showTip(message, 'negative', nil, 2)
end

function ExceptionPanel:popout()
	-- 已经弹出面板就不再弹出
	if UserManager:getInstance().isExceptionPanelPop then
		return
	end
	UserManager:getInstance().isExceptionPanelPop = true
	local scene = Director:sharedDirector():getRunningScene()
	if scene then scene:addChild(self, SceneLayerShowKey.TOP_LAYER) end
end

function ExceptionPanel:dispose()
	UserManager:getInstance().isExceptionPanelPop = false
	LoginExceptionManager:getInstance():setErrorCodeCache(ExceptionErrorCodeIgnore.kServerUniformErrorCode_Two)
	CocosObject.dispose(self)
end