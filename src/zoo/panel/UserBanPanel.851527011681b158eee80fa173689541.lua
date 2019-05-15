require 'zoo.data.LoginExceptionManager'

UserBanPanel = class(CocosObject)


function UserBanPanel:create( onCloseGame, onContact , banData )

	local winSize = CCDirector:sharedDirector():getWinSize()
	local ret = UserBanPanel.new(CCNode:create())
	ret:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	
	if banData then
		ret:buildUI( onCloseGame, onContact , banData)
		return ret
	else
		return nil
	end
end

function UserBanPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function UserBanPanel:buildUI( onCloseGame, onContact , banData)

	self.shouldShowReportBtn = LoginExceptionManager:getInstance():getShouldShowReportBtn()
	-- 特殊处理：封号处理用户屏蔽反馈问题按钮
	self.shouldShowReportBtn = false

	printx( 1 , "    UserBanPanel:buildUI   banData = " , table.tostring( banData ) )
	
	local userId = UserManager.getInstance().uid or _G.kTransformedUserID or _G.kDeviceID

	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(winSize.width, winSize.height)
	layer:setColor(ccc3(0,0,0))
	layer:setOpacity(255 * 0.4)
	layer:setTouchEnabled(true, 0, true)
	self:addChild(layer)
	self:setPosition(ccp(origin.x, origin.y))

	local ui = self.builder:buildGroup("exceptionpanel")--ResourceManager:sharedInstance():buildGroup("exceptionpanel")
	local contentSize = ui:getGroupBounds().size

	ui:setPosition(ccp((winSize.width - contentSize.width)/2, (winSize.height + contentSize.height)/2))
	printx( 1 , "    titleLabel = " , Localization:getInstance():getText("exception.panel.tittle"))
	local titleLabel = ui:getChildByName("titleLabel")
	titleLabel:setString("账号封停")
	titleLabel:setPositionY( titleLabel:getPositionY() + 75 )
	local dataInfoLabel = ui:getChildByName("dataInfoLabel")

	--刷新错误码
	LoginExceptionManager:getInstance():updateErrorHistory(errCode)
	--提示文案
	self.tipLabel = LoginExceptionManager:getInstance():getLoginErrorTip(errCode, self.shouldShowReportBtn)
	printx( 1 , "   tipLabel = " , self.tipLabel)

	local endTime = ""
	if banData.endTime then
		local ts = math.floor(banData.endTime / 1000)
		local month =  tonumber( os.date( "%m" , ts ) )
		local day =  tonumber( os.date( "%d" , ts ) )
		local hour =  tonumber( os.date( "%H" , ts ) )
		local min =  tonumber( os.date( "%M" , ts ) )
		endTime = os.date( "%Y" , math.floor(ts) ) .. "年" 
					.. tostring(month) .. "月" 
					.. tostring(day) .. "日" 
					.. tostring(hour) .. "时" 
					.. tostring(min) .. "分"
	end

	dataInfoLabel:setString("")

	local tipString = ""

	if banData.reason >= 1 and banData.reason <= 10 then
		tipString = tipString .. Localization:getInstance():getText("exception.userban.reason_" .. banData.reason)
		tipString = tipString .. Localization:getInstance():getText(
									"exception.userban.type_" .. banData.type , {day = banData.day , endTime = endTime} )
		tipString = tipString  .. Localization:getInstance():getText(
									"exception.userban.do_" .. banData.type )
		
		tipString = tipString  .. "\n" .. "游戏ID：" .. tostring(userId)
	else
		tipString = tipString .. Localization:getInstance():getText("exception.userban.reason_1")
		tipString = tipString .. Localization:getInstance():getText(
									"exception.userban.type_2" , {day = banData.day , endTime = endTime} )
		tipString = tipString  .. Localization:getInstance():getText(
									"exception.userban.do_1" )
		
		tipString = tipString  .. "\n" .. "游戏ID：" .. tostring(userId)
	end

	

	local infoLabel = ui:getChildByName("infoLabel")
	infoLabel:setString(tipString)
	infoLabel:setPositionY( infoLabel:getPositionY() + 70 )

	--关闭按钮
	local closeBtn = ui:getChildByName('closeBtn')
	local firstClick = true
    closeBtn:setTouchEnabled(true, 0, true)
    local function onCloseBtnTapped()
    	self:removeFromParentAndCleanup(true)
    	--LoginExceptionManager:getInstance():setShowFunsClubWithoutUserLogin(true)
    	--LoginExceptionManager:getInstance():setShouldShowFunsClub(false)
    	if onCloseGame ~= nil then onCloseGame() end
    end
    closeBtn:ad(DisplayEvents.kTouchTap, onCloseBtnTapped)

    --修复按钮
	local syncBtn = GroupButtonBase:create(ui:getChildByName("syncBtn"))
	
	
	if banData.type == 1 or banData.type == 2 then
		syncBtn:setString("联系客服")
		syncBtn:setColorMode(kGroupButtonColorMode.blue)
	else
		syncBtn:setString("知道了")
	end

	local function onSyncTouch(evt)
		
		if banData.type == 1 or banData.type == 2 then
			if onContact then onContact() end
		else
			if onCloseGame ~= nil then onCloseGame() end
		end
	end
	syncBtn:ad(DisplayEvents.kTouchTap, onSyncTouch)
	syncBtn:setPositionY( syncBtn:getPositionY() - 60 )

	local reportBtn = GroupButtonBase:create(ui:getChildByName("reportBtn"))
	reportBtn:setVisible(false)
	--[[
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
	]]

	self:addChild(ui)
	return true
end

function UserBanPanel:popout()
	local scene = Director:sharedDirector():getRunningScene()
	if scene then scene:addChild(self, SceneLayerShowKey.POP_OUT_LAYER) end
end

function UserBanPanel:dispose()
	LoginExceptionManager:getInstance():setErrorCodeCache(ExceptionErrorCodeIgnore.kServerUniformErrorCode_Two)
	CocosObject.dispose(self)
end