
local AFHSchemaPanel = class(BasePanel)

function AFHSchemaPanel:create(levelId, selectCallBack)
	local panel = AFHSchemaPanel.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(levelId, selectCallBack)
	return panel
end

function AFHSchemaPanel:init(levelId, selectCallBack)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/SchemaTip")
	BasePanel.init(self, self.ui)

	printx(0, "AFHSchemaPanel:", levelId, selectCallBack)
	assert(type(levelId) == "number" and type(selectCallBack) == "function")
	self.levelId = levelId
	self.selectCallBack = selectCallBack

	local lbNumStub = self.ui:getChildByName('lbNumStub')
	local pos = lbNumStub:getPosition()
	self.lbLevelNum = self.ui:getChildByName('lbNum')
	self.lbLevelNum:setAnchorPoint(ccp(0.5, 0.5))
	self.lbLevelNum:setPosition(ccp(pos.x, pos.y))
	self.lbLevelNum:setScale(1.6)
	self.lbLevelNum:changeFntFile('fnt/skip_level_word2.fnt')
	self.lbLevelNum:setText(tostring(self.levelId))
	lbNumStub:removeFromParentAndCleanup()

	self.btnAddFriends = GroupButtonBase:create(self.ui:getChildByName("btnStart"))
	self.btnAddFriends:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:btnStart() end)
	self.btnAddFriends:setString("去闯关")

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true,0,true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onKeyBackClicked() end)

	self:refresh()
end

function AFHSchemaPanel:refresh( ... )
end

function AFHSchemaPanel:btnStart( ... )
	self:onKeyBackClicked()
	return self.selectCallBack(true)
end

function AFHSchemaPanel:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHSchemaPanel:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false

	return self.selectCallBack(false)
end

function AFHSchemaPanel:dispose( ... )
	BasePanel.dispose(self)
end

return AFHSchemaPanel