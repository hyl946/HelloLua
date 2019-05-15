require "zoo.data.UserManager"
require "zoo.data.MetaManager"
require "zoo.panel.basePanel.BasePanel"
require "zoo.ui.ButtonBuilder"
require "zoo.panelBusLogic.IngamePaymentLogic"

FruitTreeTitlePanel = class(BasePanel)

local FRUIT_MAXLEVEL = 6

function FruitTreeTitlePanel:create()
	local panel = FruitTreeTitlePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	if not panel:_init() then panel = nil end
	return panel
end



function FruitTreeTitlePanel:_init()
	self.panel = self:buildInterfaceGroup("new_fruit/top")
	BasePanel.init(self, self.panel)
	self.panelLuaName = "FruitTree"
	self.button = self.panel:getChildByName("button")
	self.buttonSprite = self.button:getChildByName("sprite")
	self.content = self.panel:getChildByName("content")
	-- self.captain = self.panel:getChildByName("captain")
	self.hitArea = self.panel:getChildByName("hit_area")


	self:scaleAccordingToResolutionConfig()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.size = self.hitArea:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}
	self:setPosition(ccp((vSize.width - self.size.width) / 2 + vOrigin.x, vSize.height + vOrigin.y + _G.__EDGE_INSETS.top / 2))
	self.hitArea:removeFromParentAndCleanup(true)

	self.buttonSprite:setAnchorPointCenterWhileStayOrigianlPosition()
	self.buttonClicked = true

	-- self.captain:setText(Localization:getInstance():getText("fruit.tree.panel.title.captain"))
	self.content:setString(Localization:getInstance():getText("fruit.tree.panel.title.content"))
	self.button:getChildByName("text"):setString(Localization:getInstance():getText("fruit.tree.panel.title.rule"))

	-- center title
	-- local size = self.captain:getContentSize()
	-- self.captain:setPositionX((self.size.width / self:getScale() - size.width) / 2)

	local function onButton(evt)
		self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))
		if self.buttonClicked then
			self.buttonSprite:stopAllActions()
			self.buttonSprite:runAction(CCRotateTo:create(0.2, 270))
			self.button:setTouchEnabled(false)
			local function onAnimFinish() self.button:setTouchEnabled(true) end
			self.button:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onAnimFinish)))
			
			self.buttonClicked = false
		end
	end
	self.button:setTouchEnabled(true)
	self.button:addEventListener(DisplayEvents.kTouchTap, onButton)

	return true
end

function FruitTreeTitlePanel:onRulePanelRemove()
	self.buttonClicked = true
	self.buttonSprite:stopAllActions()
	self.buttonSprite:runAction(CCRotateTo:create(0.2, 90))
	self.button:setTouchEnabled(false)
	local function onAnimFinish() self.button:setTouchEnabled(true) end
	self.button:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onAnimFinish)))
end

function FruitTreeTitlePanel:disableClick(disabled, isSkipClose)
	self.button:setTouchEnabled(not disabled)
end

function FruitTreeTitlePanel:getBottomY()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	return vSize.height + vOrigin.y - self.size.height 
end

function FruitTreeTitlePanel:onEnterHandler() end

function FruitTreeTitlePanel:hitTestPoint( worldPosition,useGroupTest )
	return self.ui:getChildByName("_bg"):hitTestPoint(worldPosition,useGroupTest)
end

FruitTreeBottomPanel = class(BasePanel)

function FruitTreeBottomPanel:create()
	local panel = FruitTreeBottomPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	if not panel:_init() then panel = nil end
	return panel
end

function FruitTreeBottomPanel:_init()
	self.buttonEnabled = true

	self.panel = self:buildInterfaceGroup("fruitTreeBottomPanel")
	BasePanel.init(self, self.panel, "FruitTreeBottomPanel")

	self.button = self.panel:getChildByName("button")
	
	local fullLevelTip = BitmapText:create("已满级","fnt/green_button.fnt")
	fullLevelTip:setScale(0.7)
	fullLevelTip:setPositionX(self.button:getPositionX()  )
	fullLevelTip:setPositionY(self.button:getPositionY()  )
	self.panel:addChild(fullLevelTip)
	fullLevelTip:setVisible(false)
	self.fullLevelTip = fullLevelTip

	self.highlight = self.panel:getChildByName("highlight")
	self.highlight:setVisible(false)

	local picked = self.panel:getChildByName("picked")
	self.pickText = self.panel:getChildByName("pickTxt")
	self.vipLabel = self.panel:getChildByName("vipLabel")
	self.vipLabel:setVisible(false)
	self.level = self.panel:getChildByName("level")
	self.extraValue = self.panel:getChildByName("extraValue")
	self.extraValue:setAnchorPoint(ccp(0,0.5))
	self.extraValue:setPositionY(self.panel:getChildByName("_coin"):boundingBox():getMidY())
	self.extraValue:setDimensions(CCSizeMake(0,0))
	self.extraText = self.panel:getChildByName("extraTxt")
	self.hitArea = self.panel:getChildByName("hit_area")
	self.panelSize = self.hitArea:getGroupBounds().size
	self.panelSize = {width = self.panelSize.width, height = self.panelSize.height}
	self.picked = {}
	for i = 1, 8 do
		local icon = picked:getChildByName(tostring(i))
		table.insert(self.picked, icon)
	end
	self.button = GroupButtonBase:create(self.button)

	self:scaleAccordingToResolutionConfig()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.size = self.hitArea:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}
	self:setPosition(ccp((vSize.width - self.size.width) / 2 + vOrigin.x, self.size.height + vOrigin.y - _G.__EDGE_INSETS.bottom))
	self.hitArea:removeFromParentAndCleanup(true)

	self.button:setString(Localization:getInstance():getText("fruit.tree.panel.bottom.button"))

	-- self.button:setString("已满级")

	self.pickText:setString(Localization:getInstance():getText("fruit.tree.panel.bottom.pickTxt"))
	self.extraText:setString(Localization:getInstance():getText("fruit.tree.panel.bottom.extraTxt"))

	self:refresh()

	local function onButton(evt)
		self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))

		if self.guide then
			self.guide:removeFromParentAndCleanup(true)
			self.guide = nil
			self:dispatchEvent(Event.new("hideGuide",nil,self))
		end
		if self.guideHand then
			self.guideHand:removeFromParentAndCleanup(true)
			self.guideHand = nil
		end
	end
	self.button:addEventListener(DisplayEvents.kTouchTap, onButton)

	return true
end

function FruitTreeBottomPanel:refresh()
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
	local isFullLevel = FruitTreePanelModel:sharedInstance():getUpgradeLocked(level + 1)

	local coinFinish = FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1)
	local itemId,conditionFinish = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
	
	local canUpgrade = false --可以升级
	local bindCanUpgrade = false --绑定账号后可以升级
	if coinFinish and not isFullLevel then
		if conditionFinish then
			canUpgrade = true
		elseif itemId == 5 then
			bindCanUpgrade = true
		end
	end

	if canUpgrade or bindCanUpgrade then --2
		self.highlight:setVisible(true)
		self.highlight:setOpacity(255)
		self.highlight:stopAllActions()
		self.highlight:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
			CCFadeOut:create(15/24),
			CCFadeIn:create(15/24)
		)))
	else
		self.highlight:setVisible(false)
		self.highlight:stopAllActions()
	end

	-- 引导
	if not self.guide then
		if canUpgrade and level == 1 and not Cookie:getInstance():read(CookieKey.kHasFruitUpgradeGuide) then
			Cookie:getInstance():write(CookieKey.kHasFruitUpgradeGuide,true)

			self:dispatchEvent(Event.new("showGuide",nil,self))

			local vSize = Director:sharedDirector():getVisibleSize()
			local layer = LayerColor:create()
			layer:setOpacity(150)
			layer:setContentSize(vSize)
			layer:setScale(2)
			layer:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(ccp(0.5,0.5))
			layer:setPositionX(vSize.width/2)
			layer:setPositionY(vSize.height/2)
			layer:setTouchEnabled(true,-1,true)
			layer.hitTestPoint = function(_self,worldPosition,useGroupTest )
				if self.button:getContainer():hitTestPoint(worldPosition,useGroupTest) then
					return false
				else
					return not PopoutManager:haveWindowOnScreen()
				end
			end
			layer:addEventListener(DisplayEvents.kTouchTap,function( ... )
				if self.guideHand then
					return
				end
				if self.guide.ui.violation_text then
					self.guide.ui.violation_text:setVisible(true)
				end
				self.guideHand = GameGuideAnims:handclickAnim(0.5)
				local bounds = self.highlight:boundingBox()
				self.guideHand:setPositionX(bounds:getMidX())
				self.guideHand:setPositionY(bounds:getMidY())
				self.ui:addChild(self.guideHand)
			end)

			GameGuide:sharedInstance()
			self.guide = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_zhc_guoshu" }, false)
			self.guide:setPositionX(-50)
			self.guide:setPositionY(210)
			self.ui:addChildAt(self.guide,self.ui:getChildIndex(self.highlight))

			self.guide:addChildAt(layer,0)

			self.guide.ui.violation_text = table.find(self.guide.ui:getChildrenList(),function( v )
				if v.getString then
					return string.starts(v:getString(),"*需要")
				end
			end)
			if self.guide.ui.violation_text then
				self.guide.ui.violation_text:setVisible(false)
			end
		end
	end

	self.button:setVisible(not isFullLevel)
	self.fullLevelTip:setVisible(isFullLevel)

	self.button:setEnabled(not isFullLevel and self.buttonEnabled)
	self.level:setText(Localization:getInstance():getText("fruit.tree.panel.bottom.level", {level = tostring(level)}))
	local size = self.level:getContentSize()
	self.level:setPositionX((self.panelSize.width - size.width) / 2 + 10)
	self.extraValue:setString(Localization:getInstance():getText("fruit.tree.panel.bottom.extraValue", {plus = tostring(FruitTreePanelModel:sharedInstance():getPlus())}))
	local pickCount = FruitTreePanelModel:sharedInstance():getPickCount()
	local pickedCount = FruitTreePanelModel:sharedInstance():getPicked()
	if pickCount < pickedCount then pickedCount = pickCount end
	for i = 1, pickCount - pickedCount do
		if self.picked[i] then
			self.picked[i]:getChildByName("picked"):setVisible(true)
			local vipUI = self.picked[i]:getChildByName("vip")
			vipUI:setVisible(false)
		end
	end

	for i = pickCount - pickedCount + 1, 8 do
		if self.picked[i] then
			self.picked[i]:getChildByName("picked"):setVisible(false)
		end
		
	end
	for i = 1, pickCount do
		if self.picked[i] then
			self.picked[i]:setVisible(true)
			local vipUI = self.picked[i]:getChildByName("vip")
			vipUI:setVisible(false)
		end
	end
	for i = pickCount + 1, 8 do
		if self.picked[i] then
			self.picked[i]:setVisible(false)
			local vipUI = self.picked[i]:getChildByName("vip")
			vipUI:setVisible(false)
		end
		
	end
end

function FruitTreeBottomPanel:disableClick(disabled)
	self.buttonEnabled = not disabled
	self:refresh()
end

function FruitTreeBottomPanel:onEnterHandler() end

FruitTreeRulePanel = class(BasePanel)

function FruitTreeRulePanel:create(bottomY)
	local panel = FruitTreeRulePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	if not panel:_init(bottomY) then panel = nil end
	return panel
end

function FruitTreeRulePanel:_init(bottomY)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	bottomY = bottomY or vSize.height + vOrigin.y
	self.panel = self:buildInterfaceGroup("new_fruit/bottom")
	BasePanel.init(self, self.panel)

	-- self.button = self.panel:getChildByName("button")
	self.descText = self.panel:getChildByName("descText")
	-- self.content = self.panel:getChildByName("content")
	self.hitArea = self.panel:getChildByName("hit_area")
	self.level0 = self.panel:getChildByName("level0")
	self.level6 = self.panel:getChildByName("level6")
	self.coin = self.panel:getChildByName("coin")
	self.energy = self.panel:getChildByName("energy")
	self.gold = self.panel:getChildByName("gold")
	self.regen = self.panel:getChildByName("regen")
	self.speed = self.panel:getChildByName("speed")
	self.regenText = self.panel:getChildByName("regenText")
	self.speedText = self.panel:getChildByName("speedText")

	self:scaleAccordingToResolutionConfig()
	self.size = self.hitArea:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}
	self:setPosition(ccp((vSize.width - self.size.width) / 2 + vOrigin.x, bottomY))
	self.hitArea:removeFromParentAndCleanup(true)
	local function setMethodUI(ctrl, text)
		local name = {"regen", "speed"}
		for k, v in ipairs(name) do
			local icn = ctrl:getChildByName("icn_"..v)
			if icn and v ~= text then icn:removeFromParentAndCleanup(true) end
		end
		local label = ctrl:getChildByName("text")
		if label then 
			label:setText(Localization:getInstance():getText("fruit.tree.scene."..text)) 
			label:setPositionX(label:getPositionX() - 25)
			label:setPositionY(label:getPositionY() + 15)
		end
	end
	setMethodUI(self.regen, "regen")
	setMethodUI(self.speed, "speed")

	-- self.content:setString(Localization:getInstance():getText("fruit.tree.panel.rule.content"))
	self.descText:setString(Localization:getInstance():getText("fruit.tree.panel.rule.descText"))
	self.descText:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	self.descText:setScale(1.1)

	self.level0:setText(Localization:getInstance():getText("fruit.tree.scene.level", {level = 0}))
	self.level6:setText(Localization:getInstance():getText("fruit.tree.scene.level", {level = 6}))
	self.coin:setString(tostring(FruitTreePanelModel:sharedInstance():getFruitCoinRewardString()))
	self.energy:setString(tostring(FruitTreePanelModel:sharedInstance():getFruitEnergyRewardString()))
	self.gold:setString(tostring(FruitTreePanelModel:sharedInstance():getFruitGoldRewardString()))
	self.regenText:setString(Localization:getInstance():getText("fruit.tree.panel.rule.regen.text"))
	self.speedText:setString(Localization:getInstance():getText("fruit.tree.panel.rule.speed.text"))

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setButtonMode(true)
	closeBtn:setTouchEnabled(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	return true
end

function FruitTreeRulePanel:remove()
	self:playSlideOutAnim()
end

function FruitTreeRulePanel:playSlideInAnim()
	local layer = LayerColor:create()
	self.layer = layer
	layer:setOpacity(0)
	local wSize = Director:sharedDirector():getWinSize()
	layer:changeWidthAndHeight(wSize.width, wSize.height)
	layer:runAction(CCFadeTo:create(0.5, 150))
	local parent = self:getParent()
	if parent then
		local index = parent:getChildIndex(self)
		if _G.isLocalDevelopMode then printx(0, "index", index) end
		parent:addChildAt(layer, index)
	else if _G.isLocalDevelopMode then printx(0, "no parent") end layer:dispose() end
	local list = {}
	self.panel:getVisibleChildrenList(list)
	if type(list) == "table" and #list > 0 then
		for k, v in ipairs(list) do
			v:setOpacity(0)
			v:runAction(CCFadeIn:create(0.2))
		end
	end
	self:setPositionY(self:getPositionY() + 300)
	self:runAction(CCEaseBackOut:create(CCMoveBy:create(0.5, ccp(0, -300))))
end

function FruitTreeRulePanel:playSlideOutAnim()
	local list = {}
	self.panel:getVisibleChildrenList(list)
	if type(list) == "table" and #list > 0 then
		for k, v in ipairs(list) do
			v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCFadeOut:create(0.2)))
		end
	end
	local array = CCArray:create()
	array:addObject(CCEaseBackIn:create(CCMoveBy:create(0.5, ccp(0, 300))))
	local function dispatchEvent() self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self)) end
	array:addObject(CCCallFunc:create(dispatchEvent))
	self:runAction(CCSequence:create(array))
	if self.layer and not self.layer.isDisposed then
		local function dispose() self.layer:removeFromParentAndCleanup(true) end
		self.layer:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCCallFunc:create(dispose)))
	end
end

function FruitTreeRulePanel:onKeyBackClicked()
	self:playSlideOutAnim()
end

function FruitTreeRulePanel:onEnterHandler() end

function FruitTreeRulePanel:hitTestPoint( worldPosition,useGroupTest )
	return self.ui:getChildByName("_bg"):hitTestPoint(worldPosition,useGroupTest)
end


FruitTreeUpgradePanel_New = class(BasePanel)

function FruitTreeUpgradePanel_New:create()
	local panel = FruitTreeUpgradePanel_New.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	if not panel:_init() then panel = nil end
	return panel
end

function FruitTreeUpgradePanel_New:_init()

	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	self.panel = self:buildInterfaceGroup("fruitTreeUpgradePanel2")
	BasePanel.init(self, self.panel)

	self.close = self.panel:getChildByName("close")

	self.upgradeFriend = self.panel:getChildByName("upgradeFriend")
	self.upgradeFriendText = self.panel:getChildByName("upgradeFriendText")

	self.conditionText = self.panel:getChildByName("conditionText")
	self.conditionTextInitPosX = self.conditionText:getPositionX()



	self.upgradeCoin = self.panel:getChildByName("upgradeCoin")
	self.upgradeCoin:setVisible(false)

	self.coin = self.panel:getChildByName("coin")
	self.pngor = self.panel:getChildByName("pngor")


	self.condition = {}
	self.condition[0] = self.panel:getChildByName("condition0")
	self.condition[1] = self.panel:getChildByName("condition1")
	self.condition[2] = self.panel:getChildByName("condition2")
	self.condition[3] = self.panel:getChildByName("condition3")
	self.condition[5] = self.panel:getChildByName("condition5")


	self.conditionInitPosX = {}

	for i=0,5 do
		local valueNode = self.condition[i]
		if valueNode then
			self.conditionInitPosX[i] = valueNode:getPositionX()
		end
	end
	self.condition[0] :setVisible(false)

	self.upgradeText = self.panel:getChildByName("upgradeText")
	self.pickArrow = self.panel:getChildByName("pickArrow")
	self.coinArrow = self.panel:getChildByName("coinArrow")
	self.pickBefore = self.panel:getChildByName("pickBefore")
	-- self.pickAfter = self.panel:getChildByName("pickAfter")
	self.coinBefore = self.panel:getChildByName("coinBefore")
	-- self.coinAfter = self.panel:getChildByName("coinAfter")
	self.pickText = self.panel:getChildByName("pickText")
	self.coinText = self.panel:getChildByName("coinText")
	self.captain = self.panel:getChildByName("captain")
	self.hitArea = self.panel:getChildByName("hit_area")

	self.bg_inner_fruits5 = self.panel:getChildByName("bg_inner_fruits5")
	self.bg_inner_fruits5:setVisible( false )
		
	self.bg_inner_fruits = self.panel:getChildByName("bg_inner_fruits")

	self.pickNumTitle = self.panel:getChildByName("pickNumTitle")
	self.pickNum = self.panel:getChildByName("pickNum")

	self.maohao1 = self.panel:getChildByName("maohao1")
	self.maohao2 = self.panel:getChildByName("maohao2")
	self.maohao3 = self.panel:getChildByName("maohao3")

	self.upgradetitle2 = self.panel:getChildByName("upgradetitle2")
	self.upgradetitle = self.panel:getChildByName("upgradetitle")

	self.levelTitle = self.panel:getChildByName("levelTitle")
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()	
	local titleTexts = { "升级到 ", tostring(level+1), " 级效果：" }
	for i,v in ipairs(titleTexts) do
		local t = self.levelTitle:getChildByName(tostring(i))
		if i == 2 then
			t:setPreferredSize(999999,45)
			t:setColor(ccc3(0x23,0x79,0x00))
		else
			t:setPreferredSize(999999,32)
			t:setColor(ccc3(0x66,0x33,0x00))
		end
		t:setString(v)

		if i > 1 then
			local lastBoundingBox = self.levelTitle:getChildByName(tostring(i-1)):boundingBox()
			t:setAnchorPoint(ccp(0,0.5))
			t:setPositionX(lastBoundingBox:getMaxX())
			t:setPositionY(lastBoundingBox:getMidY())
		end
	end

	self.pickText:setPreferredSize(999999,32)
	self.pickText:setColor(ccc3(0x66,0x33,0x00))
	self.pickText:setString("每日摘取果实数")


	self.upgradetitle2:setPreferredSize(999999,32)
	self.upgradetitle2:setColor(ccc3(0x66,0x33,0x00))
	self.upgradetitle2:setString("升级需要：")


	self.pickBefore:setPreferredSize(999999,40)
	self.pickBefore:setColor(ccc3(0x23,0x79,0x00))
	self.pickBefore:setAnchorPoint(ccp(0,0.5))
	self.pickBefore:setPositionY(self.pickText:boundingBox():getMidY())
	
	self.maohao2:setPreferredSize(999999,32)
	self.maohao2:setColor(ccc3(0x66,0x33,0x00))
	self.maohao2:setAnchorPoint(ccp(0,0.5))
	self.maohao2:setString("：")
	self.maohao2:setPositionY(self.pickText:boundingBox():getMidY())

	self.coinText:setPreferredSize(999999,32)
	self.coinText:setColor(ccc3(0x66,0x33,0x00))
	self.coinText:setString("银币果实额外收益")

	self.pickNumTitle:setPreferredSize(999999,32)
	self.pickNumTitle:setColor(ccc3(0x66,0x33,0x00))
	self.pickNumTitle:setString("树上一次可结果实数量")

	self.pickNum:setPreferredSize(999999,40)
	self.pickNum:setColor(ccc3(0x23,0x79,0x00))
	self.pickNum:setAnchorPoint(ccp(0,0.5))
	self.pickNum:setPositionY(self.pickNumTitle:boundingBox():getMidY())

	self.maohao3:setPreferredSize(999999,32)
	self.maohao3:setColor(ccc3(0x66,0x33,0x00))
	self.maohao3:setAnchorPoint(ccp(0,0.5))
	self.maohao3:setString("：")
	self.maohao3:setPositionY(self.pickNumTitle:boundingBox():getMidY())


	self.coinBefore:setPreferredSize(999999,40)
	self.coinBefore:setColor(ccc3(0x23,0x79,0x00))
	self.coinBefore:setAnchorPoint(ccp(0,0.5))
	self.coinBefore:setPositionY(self.coinText:boundingBox():getMidY())


	self.maohao1:setPreferredSize(999999,32)
	self.maohao1:setColor(ccc3(0x66,0x33,0x00))
	self.maohao1:setAnchorPoint(ccp(0,0.5))
	self.maohao1:setString("：")
	self.maohao1:setPositionY(self.coinText:boundingBox():getMidY())
	-- self.coinAfter:setPreferredSize(999999,32)
	-- self.coinAfter:setColor(ccc3(0x66,0x33,0x00))


	self.jiantou1 = self.panel:getChildByName("jiantou1")
	self.jiantou2 = self.panel:getChildByName("jiantou2")

	self.buybutton = self.panel:getChildByName("buybutton")
	self.buybutton = ButtonIconNumberBase:create(self.panel:getChildByName('buybutton'))
	self.buybutton:setString( "立即升级" )
	self.button_center = self.panel:getChildByName("button_center")
	self.button_center = ButtonIconNumberBase:create(self.panel:getChildByName('button_center'))
	self.button_center:setString( "升级" )
	self.button_center:setColorMode( kGroupButtonColorMode.blue )

	self.coinBtn = self.panel:getChildByName("coinBtn")
	self.coinBtn = GroupButtonBase:create(self.coinBtn)
	self.coinBtn:setVisible(false)

	self.button = self.panel:getChildByName("button")
	self.button = ButtonIconNumberBase:create(self.panel:getChildByName('button'))
	self.button:setString( "升级" )
	self.button:setColorMode( kGroupButtonColorMode.blue )

	self.button:setIconByFrameName("imgs/coinIcon0000", true)
	self.button_center:setIconByFrameName("imgs/coinIcon0000", true)

	self.button:setNumberAlignment( kButtonTextAlignment.left )
	self.button_center:setNumberAlignment( kButtonTextAlignment.left )

	-- self.button_center = self.panel:getChildByName("button_center")
	-- self.button_center = GroupButtonBase:create(self.panel:getChildByName('button_center'))
	-- self.button_center:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.button"))
	
	self.coinBtn:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.coinButton"))

	self.close = self.panel:getChildByName("close")

	local function onButton(evt)
		if self.isDisposed then return end
		self:onKeyBackClicked()
	end
	-- self.button:addEventListener(DisplayEvents.kTouchTap, onButton)

	self.friendBtn = self.panel:getChildByName("friendBtn")
	self.friendBtn = GroupButtonBase:create(self.friendBtn)

	self.friendBtn:setColorMode( kGroupButtonColorMode.orange)
	self.coinBtn:setColorMode( kGroupButtonColorMode.blue)

	self.size = self.hitArea:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}
	self:setPosition(ccp((vSize.width - self.size.width) / 2 + vOrigin.x, self.size.height + vOrigin.y))
	self.hitArea:removeFromParentAndCleanup(true)

	local function onClose(evt)
		self.button:setEnabled(false)
		self.button_center:setEnabled(false)
		-- self.close:setTouchEnabled(false)
		self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
	end
	-- self.close:setTouchEnabled(true)
	-- self.close:setButtonMode(true)

	 UIUtils:setTouchHandler(  self.ui:getChildByName('close') , function ()
     	onClose()
     end)

	-- self.close:addEventListener(DisplayEvents.kTouchTap, onClose)
	-- self.button_center:setString("升级果树")
	-- self.button_center.label:setAnchorPointCenterWhileStayOrigianlPosition(ccp(0,0))
	-- self.button:setString("升级果树")
	-- self.button.label:setAnchorPointCenterWhileStayOrigianlPosition(ccp(0,0))
	-- self.button.label:setScale(0.95)

	self.buybutton:setString("立即升级")
	-- self.buybutton.label:setAnchorPointCenterWhileStayOrigianlPosition(ccp(0,0))
	-- self.buybutton.label:setScale(0.9)
	self.buybutton:setColorMode( kGroupButtonColorMode.blue )

	local goodsItem =  MetaManager:getInstance():getGoodMeta( 509 )
	self.buybutton:setNumber( goodsItem.qCash )	

	-- self.buybutton:setIconByFrameName('CollectStars2018/icon1070000', true)

	self.buybutton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000", true)
	
	local function onButton(evt)
		if self.isDisposed  then return end

		if _G.isLocalDevelopMode  then printx(100 , "FruitTreeUpgradePanel_New  onButton =  "  ) end
		local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
		local condition, fulfill, value, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)

		if not fulfill then

			if condition == 3 then
				--3是闯关
				if level ==4 then
					CommonTip:showTip(Localization:getInstance():getText("fruit.tree.upgrade.lack.level", "negative"))
				else
					CommonTip:showTip(Localization:getInstance():getText("fruit.tree.upgrade.lack.level1", "negative"))
				end

			elseif condition == 5 then
				--5是第三方绑定
				CommonTip:showTip(Localization:getInstance():getText("fruit.tree.upgrade.lack.account", "negative"))
			end			
			return
		end

		local finish, coin, upgradeCoin = FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1)
		if not finish then
		    -- CommonTip:showTip(Localization:getInstance():getText("fruit.tree.upgrade.lack.coin", "negative")) --弃用
			if self.isDisposed then return end

			if self.doClickOther then
				self.doClickOther = false 
				return
			end

			local function onSuccCallBack()
				CommonTip:showTip("购买成功~","positive")
				self:refresh()
				-- 若银币购买充足则自动升级果树
				-- local canAffordNow = FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1)
				-- if canAffordNow then onButton(evt) end
			end
			PayPanelCoin:create(upgradeCoin, BuyCoinReasonType.kFruitTreeUpdate, onSuccCallBack)
			return 
		end
		

		-- if self.notTouchButton then
		-- 	return
		-- end
		if self.isBuying then
			return
		end
		local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
		local inviteNeed = FruitTreePanelModel:sharedInstance():getUpgradeCondition(level + 1)
		local coin = FruitTreePanelModel:sharedInstance():getUserCoin()
		local coinNeed = FruitTreePanelModel:sharedInstance():getUpgradeCoin(level + 1)
		local function onSuccess(data)
			if self.isDisposed then return end
			local scene = HomeScene:sharedInstance()
			if scene then scene:checkDataChange() end

			-- local button = self.panel:getChildByName("button")
			-- self.button:playFloatAnimation('-'..tostring(coinNeed))

			-- 此次不弹出消耗银币的动画，因为必弹果树升级炫耀动画
			-- AchievementManager:onDataUpdate(AchievementManager.COIN_COST_NUM, tonumber(coinNeed) or 0)
			UserManager:getInstance().achievement.spentCoins = UserManager:getInstance().achievement.spentCoins + tonumber(coinNeed) or 0
	
			
			if level == 4 then
				--升级5级果树时 因为解锁了一个新的果子 需要拉一边info
				local function onSuccess()
					-- self:refresh("update", target)
					self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdate, nil, self))
					self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))
				end
				local function onFail(err)

				end
				local logic = FruitTreeLogic:create()
				logic:updateTreeInfo(onSuccess, onFail)		

			else
				self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdate, nil, self))
				self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))

			end

		end
		local function onFail(err)
			if self.isDisposed then return end
			-- self.button:setEnabled(true)
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err), "negative"))
		end
		local function onCancel()
			if self.isDisposed then return end
			-- self.button:setEnabled(true)
		end

		local function startUpgrade()
			self.button:setEnabled(false)
			local logic = FruitTreeUpgradePanelLogic:create(self.invitedFriendCount)
			logic:upgrade(onSuccess, onFail, onCancel)
		end
		RequireNetworkAlert:callFuncWithLogged(startUpgrade)
	end
	-- UIUtils:setTouchHandler(  self.ui:getChildByName('button') , function ()
 --     	onButton()
 --     end)
	-- UIUtils:setTouchHandler(  self.ui:getChildByName('button_center') , function ()
 --     	onButton()
 --     end)
 	local function onBuyBtnTapped(err)
		if self.isDisposed  then return end

		self.doClickOther = true 
		self:onBuyBtnTapped()
	end
	self.button:addEventListener(DisplayEvents.kTouchTap, preventContinuousClick(onButton , 1) )
	self.button_center:addEventListener(DisplayEvents.kTouchTap,  preventContinuousClick(onButton , 1) )
	self.buybutton:addEventListener(DisplayEvents.kTouchTap, onBuyBtnTapped)

	-- UIUtils:setTouchHandler(  self.ui:getChildByName('buybutton') , function ()
 --     	self:onBuyBtnTapped()
 --     end)

	local function onPopdown()
		self:refresh()
	end

	local function onCoinBtn(evt)
		local id = MarketManager:sharedInstance():getBuyCoinPageIndex()
		if id ~= 0 then
			local panel = createMarketPanel(id)
			panel:addEventListener(kPanelEvents.kClose, onPopdown)
			panel:popout()
		end
	end
	self.coinBtn:addEventListener(DisplayEvents.kTouchTap, onCoinBtn)

	local function onBind(  )
		if not self.friendBtn.authType then
			return
		end

		local function onErrorCallback( ... )
			-- body
		end

		local function onCancelCallback( ... )

		end

		local function onSuccessCallback( ... )
			self:refresh()
		end

		if self.friendBtn.authType == PlatformAuthEnum.kPhone then

            local bGoToSvipPanel = false
            ----SVIP 绑定手机活动 不弹旧手机绑定ICON
            local bGoToSvipPanel = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()

            ----
            if bGoToSvipPanel then
                Director:sharedDirector():popScene()

                local function openActivity()
                    SVIPGetPhoneManager:getInstance():openActivity()
                end
                setTimeOut( openActivity, 1 )
            else
			    AccountBindingLogic:bindNewPhone(onCancelCallback, onSuccessCallback, AccountBindingSource.FRUIT_TREE)
            end
		else
			AccountBindingLogic:bindNewSns(self.friendBtn.authType, onSuccessCallback, onErrorCallback, onCancelCallback, AccountBindingSource.FRUIT_TREE)
		end
	end

	local function onPlay( ... )
		self:dispatchEvent(Event.new("gotoPlayTopLevel"))
	end

	self.friendBtn:addEventListener(DisplayEvents.kTouchTap, function( ... )
		if not self.friendBtn.condition then
			return
		end
		if self.friendBtn.condition == 5 then
			onBind()
		elseif self.friendBtn.condition == 3 then
			onPlay()
		end
	end)
	-- buybutton
	self:refresh()

	return true

end


function FruitTreeUpgradePanel_New:goldNotEnough( ... ) 
    local function updateGold()

        self.isBuying = false
    end
    local function createGoldPanel()
        local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
        if index ~= 0 then
            -- local config = {TabsIdConst.kHappyeCoin}
            local panel = createMarketPanel(index)
            panel:addEventListener(kPanelEvents.kClose, updateGold)
            panel:popout()
        else 

        end
    end

    local function cancelCallback()
        if self.cancelCallback then 
            self.cancelCallback()
        end
        self.isBuying = false
    end
    GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)

end


function FruitTreeUpgradePanel_New:onBuyBtnTapped()


    if self.isDisposed then return end
    if self.isBuying then
        return
    end
    self.isBuying = true

    local function onCheckSuccess()
        if self.isDisposed then return end
        
        local function onSuccess( event )
            if self.isDisposed then return end
            

            local scene = HomeScene:sharedInstance()
            local button = scene.goldButton
            if button then button:updateView() end
            scene:checkDataChange()
           

            local treeLevel = FruitTreePanelModel:getTreeLevel()

			local extend = UserManager:getInstance():getUserExtendRef()
			if extend then extend:setFruitTreeLevel(extend:getFruitTreeLevel() + 1) end

			local serviceExtend = UserService:getInstance():getUserExtendRef()
			if serviceExtend then serviceExtend:setFruitTreeLevel(serviceExtend:getFruitTreeLevel() + 1) end
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData() end

			local goodsItem =  MetaManager:getInstance():getGoodMeta( 509 )
			DcUtil:fruitTreeUpgrade(treeLevel , 1 ,goodsItem.qCash)

			local function onSuccess()
				self.isBuying = false
				 CommonTip:showTip( "果树升级成功"  , "positive")
				-- self:refresh("update", target)
				self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdate, nil, self))
				self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))
			end
			local function onFail(err)
				local function exit() self:dispatchEvent(Event.new(kFruitTreeEvents.kExit, nil, self)) end
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative", exit)
				self.isBuying = false
			end
			local logic = FruitTreeLogic:create()
			logic:updateTreeInfo(onSuccess, onFail)
			-- self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))

        end
    
        local function onFail(event)
            if self.isDisposed then return end
            
            if type(event) == "number" then
                if event == 730330 then
                	self:goldNotEnough() 
                else
                    self.isBuying = false
                end
            else
                if event.data == 730330 then 
                    self:goldNotEnough()
                else 
                    self.isBuying = false
                    -- CommonTip:showTip( "  " )
                end
            end
            self.isBuying = false
        end
    
        local function onCancel(event)
            if self.isDisposed then return end
            self.isBuying = false
        end
        
        local logic = BuyLogic:create(509, MoneyType.kGold, DcFeatureType.kFruitTree, DcSourceType.kFruitTreeUpdate)
        logic:getPrice()
        logic:setCancelCallback(onCancel)
        logic:start(1, onSuccess, onFail, true)
    end

    local function onCheckFailed()
        self.isBuying = false
    end

    self:onlineHandle(onCheckSuccess, onCheckFailed)

end

function FruitTreeUpgradePanel_New:onlineHandle(successFunc, failFunc)
    RequireNetworkAlert:callFuncWithLogged(function ()
        PaymentNetworkCheck.getInstance():check(function ()
            if successFunc then successFunc() end
            ConnectionManager:block()
            SyncManager:getInstance():flushCachedHttp()
            ConnectionManager:flush()
        end, function ()
            if failFunc then failFunc() end
            CommonTip:showNetworkAlert()
        end)
    end, function ()
        if failFunc then failFunc() end
        CommonTip:showNetworkAlert()
    end)
end


function FruitTreeUpgradePanel_New:onEnterHandler() 



end

function FruitTreeUpgradePanel_New:refresh()

	if self.isDisposed then return end
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()

	if level == 4 then
		self.bg_inner_fruits5:setVisible( true )
		self.bg_inner_fruits:setVisible( false ) 
		self.upgradetitle:setVisible( true )
		self.upgradetitle2:setVisible( false )
	else
		self.upgradetitle:setVisible( false )
		self.upgradetitle2:setVisible( true )
	end

	local enabled = not FruitTreePanelModel:sharedInstance():getUpgradeLocked(level + 1)

	local finish, coin, upgradeCoin = FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1)
	local coinText = ""
	if coin > 10000 then
		coinText = string.format("%d万",coin/10000)
	else
		coinText = tostring(coin)
	end
	if finish then
		if self.coinBtn then
			self.coinBtn:setVisible(false)
		end
		
		self.upgradeCoin:setRichText(string.format(
			"[#237900]%s[/#][#237900]/%d万[/#]",coinText,upgradeCoin/10000
		))
	else
		if self.coinBtn then
			self.coinBtn:setVisible(false)
		end
		enabled = false
		self.upgradeCoin:setRichText(string.format(
			"[#FF0000]%s[/#][#237900]/%d万[/#]",coinText,upgradeCoin/10000
		))
	end
	local upgradeCoinText = upgradeCoin/10000 .. "万"

	local buttonNeedOffset = false 
	if upgradeCoin/10000 < 100 then
		buttonNeedOffset = true
	end

	-- self.button:setString( upgradeCoinText )
	-- self.button_center:setString( upgradeCoinText )

	self.button:setNumber( upgradeCoinText )
	self.button_center:setNumber( upgradeCoinText )
		
	-- self.button:useStaticNumberLabel( 40 , "微软雅黑" , ccc3(255,255,255) )
	-- self.button_center:useStaticNumberLabel( 40 , "微软雅黑" , ccc3(255,255,255) )

	-- self.button:setString( "升级" )
	-- self.button_center:setString( "升级" )

	-- if _G.isLocalDevelopMode  then printx(100 , "FruitTreeUpgradePanel_New  upgradeCoinText =  " , upgradeCoinText ) end


	local scale = 32/self.upgradeCoin:getContentSize().height
	self.upgradeCoin:setScale(scale)
	self.conditionText:setScale(scale)

	local condition, fulfill, value, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
		
	self.innerbg2 = self.ui:getChildByName("innerbg2")
	self.innerbg = self.ui:getChildByName("innerbg")


	if condition == 4 then 
		self.innerbg:setVisible( not finish ) 
		self.innerbg2:setVisible( finish ) 
	else
		self.innerbg:setVisible( not fulfill ) 
		self.innerbg2:setVisible( fulfill ) 

	end
	



	for k,v in pairs(self.condition) do
		if k > 0 then
			v:setVisible(k == condition)
		end
	end

	local function setConditionText( condition,value,nextValue )
		if type(condition) == "string" and value == nil and nextValue == nil then
			self.conditionText:setRichText(condition)
		elseif value and nextValue and value >= nextValue then
			self.conditionText:setRichText(string.format(
				"[#663300]%s([#237900]%s[/#][#237900]/%s[/#])[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.condition"..tostring(condition),{ num=nextValue }),
				tostring(value),
				tostring(nextValue)
			))
		else
			self.conditionText:setRichText(string.format(
				"[#663300]%s([#FF0000]%s[/#][#237900]/%s[/#])[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.condition"..tostring(condition),{ num=nextValue }),
				tostring(value),
				tostring(nextValue)
			))
		end
	end

	self.coinBtn:setVisible( false )
	self.upgradeCoin:setVisible(false)
	self.condition[0]:setVisible(false)

	if condition == 4 then --没有

		self.conditionText:setVisible(false)
		self.friendBtn:setVisible(false)

		self.coinBtn:setVisible( not finish  )
		self.upgradeCoin:setVisible( true )
		self.condition[0]:setVisible(true)

	elseif condition == 2 then
		self.friendBtn.condition = 2
		self.friendBtn:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.friendButton"))
		self.friendBtn:setVisible(true)

		if self.invitedFriendCount then
			fulfill, value = self.invitedFriendCount >= nextValue, self.invitedFriendCount
			if fulfill then
				self.friendBtn:setVisible(false)
			else
				self.friendBtn:setVisible(true)
				enabled = false
			end
			setConditionText(condition,value,nextValue)
		else
			local function onSuccess(data)
				self.invitedFriendCount = data
				self:refresh()
			end
			local function onFail(err)
				self.invitedFriendCount = 0
				self:refresh()
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
			end
			enabled = false
			setConditionText(string.format(
				"[#FF0000]%s[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.loading")
			))
			local logic = FruitTreeUpgradePanelLogic:create()
			logic:getInvitedFriendCount(onSuccess, onFail)
		end
	else
		if condition == 5 then
			for k,v in pairs(self.condition[5]:getChildByName("sprite"):getChildrenList()) do
				v:setVisible(false)
			end
			local authTypes = {
				{PlatformAuthEnum.kQQ,"qq"},
				{PlatformAuthEnum.kWechat,"wechat"},
				{PlatformAuthEnum.kPhone,"phone"},
				{PlatformAuthEnum.k360,"360"},
				{PlatformAuthEnum.kMI,"mi"},
				{PlatformAuthEnum.kWDJ,"wdj"},
				{PlatformAuthEnum.kWeibo,"weibo"},
			}
			local cfgPriorityMaintenance = MaintenanceManager:getInstance():getMaintenanceByKey("FruitTreePushPriority")
			local cfgPriority
			if cfgPriorityMaintenance ~= nil then cfgPriority = cfgPriorityMaintenance.extra end
			if cfgPriority == nil then  cfgPriority = "phone,wechat,qq,360,mi,wdj,weibo" end

			table.sort(authTypes, function(a, b)
								   		local idxA = string.find(cfgPriority, a[2])
								   		local idxB = string.find(cfgPriority, b[2])
								   		if not idxA or not idxB then
								   			return false
								   		end
								   		if idxA == idxB then 
								   			return 
								   			false
								   		else return 
								   			idxA < idxB 
								   		end
								  end)
			self.friendBtn.authType = nil

			if _G.sns_token and _G.sns_token.authorType then
				local k = table.find(authTypes,function( v )
					return v[1] == _G.sns_token.authorType
				end)
				if k then
					self.condition[5]:getChildByName("sprite"):getChildByName(k[2]):setVisible(true)
				end
				setConditionText(string.format(
					"[#663300]绑定%s账号(已绑定)[/#]",
					PlatformConfig:getPlatformNameLocalization(_G.sns_token.authorType)
				))
				fulfill = true
			else
				
				for i,v in ipairs(authTypes) do
					if v[1] ~= PlatformAuthEnum.kQQ and PlatformConfig:hasAuthConfig(v[1]) then
						if fulfill then
							if UserManager.getInstance().profile:getSnsInfo(v[1]) then
								self.condition[5]:getChildByName("sprite"):getChildByName(v[2]):setVisible(true)
								self.friendBtn.authType = v[1]
								setConditionText(string.format(
									"[#663300]绑定%s账号(已绑定)[/#]",
									PlatformConfig:getPlatformNameLocalization(v[1])
								))
								break
							end
						else
							self.condition[5]:getChildByName("sprite"):getChildByName(v[2]):setVisible(true)
							self.friendBtn.authType = v[1]
							setConditionText(string.format(
								"[#663300]绑定%s账号(未绑定)[/#]",
								PlatformConfig:getPlatformNameLocalization(v[1])
							))
							break
						end
					end
				end
			end
			self.friendBtn.condition = 5
			self.friendBtn:setVisible(not fulfill)
			self.friendBtn:setString("绑定")
		elseif condition == 3 then
			setConditionText( condition , value , nextValue )
			self.friendBtn.condition = 3
			self.friendBtn:setVisible(not fulfill)
			self.friendBtn:setString("闯关")
		else
			setConditionText(condition,value,nextValue)
			self.friendBtn:setVisible(false)
		end

		if not fulfill then
			enabled = false
		end

	end

	local incPlus, plus, nextPlus,nextNextPlus = FruitTreePanelModel:sharedInstance():getShowUpgradePlus()
	self.coinBefore:setString(string.format("%d%%",nextPlus))

	local incPick, pick, nextPick,nextNextPicked = FruitTreePanelModel:sharedInstance():getShowUpgradePick()
	self.pickBefore:setString(string.format("%d颗",nextPick))

	self.pickNum:setString(string.format("%d颗", pick ))

	-- if nextNextPicked > 0 then
	-- 	self.pickAfter:setString(string.format("(下一级%d颗)",nextNextPicked))
	-- else
	-- 	self.pickAfter:setString("")
	-- end

	-- self.button:setEnabled(enabled)
	self.button:setVisible(false)
	self.button_center:setVisible(false)
	-- self.buybutton:setVisible(false)
	self.jiantou1:setVisible(false)
	self.jiantou2:setVisible(false)
	self.pngor:setVisible(false)
	self.buybutton:setVisible(false)


	if level == 4 then
		self.button:setVisible(true)
		self.jiantou1:setVisible(true)
		self.pngor:setVisible(true)
		self.buybutton:setVisible(true)
	else
		self.button_center:setVisible(true)
		self.jiantou2:setVisible(true)
		
	end

	-- local condition, fulfill, value, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
	self.button:setEnabledForColorOnly( fulfill )
	self.button_center:setEnabledForColorOnly( fulfill )

	-- if enabled == false then
	-- 	self.jiantou1:setVisible( true )
	-- 	self.button:setVisible(true)
	-- 	self.buybutton:setVisible(true)
	-- 	self.notTouchButton = true 
	-- 	-- self.button:setEnabled(false)
	-- 	-- self.button:setEnabledForColorOnly(false)
	-- 	-- self.button_center:setEnabledForColorOnly(false)
	-- else
	-- 	self.button_center:setVisible(true)
	-- 	self.jiantou2:setVisible( true )
	-- 	self.notTouchButton = false 
	-- end

	self.button:setEnabled(true)
	self.button_center:setEnabled(true)

	local finishLocal = fulfill
	if condition == 4 then 
		finishLocal = finish
	end

	if finishLocal  then
		
		local offSetDistance = 150

		local totalWidth = self.conditionText:getContentSize().width + offSetDistance
		if condition == 4 then
			offSetDistance = 60 
			totalWidth = self.upgradeCoin:getContentSize().width + offSetDistance
		end 

		local mainWidth = 331
		local leftPosX = self.innerbg2:getPositionX()
		local leftNodePos = (mainWidth - totalWidth )/2
		local conditionTextPosX = leftPosX + leftNodePos + offSetDistance
		local distance = conditionTextPosX - self.conditionTextInitPosX 
		for i=0,5 do
			local valueNode = self.condition[i]
			if valueNode then
				valueNode:setPositionX( self.conditionInitPosX[i]  + distance  )
			end
		end

		self.upgradeCoin :setPositionX( self.conditionTextInitPosX  + distance )
		self.conditionText :setPositionX( self.conditionTextInitPosX  + distance )
		
		-- if _G.isLocalDevelopMode  then printx(100 , "FruitTreeUpgradePanel_New:refresh()  totalWidth =  " ,  totalWidth ) end
		-- if _G.isLocalDevelopMode  then printx(100 , "FruitTreeUpgradePanel_New:refresh()  distance =  " ,  distance ) end
	else

		self.upgradeCoin :setPositionX( self.conditionTextInitPosX   )
		self.conditionText :setPositionX( self.conditionTextInitPosX   )
		for i=0,5 do
			local valueNode = self.condition[i]
			if valueNode then
				valueNode:setPositionX( self.conditionInitPosX[i]    )
			end
		end

	end

	if buttonNeedOffset then
		if self.button_center and self.button_center.label then
			local posX_Now = self.button_center.label:getPositionX()
			self.button_center.label:setPositionX( posX_Now - 10 )
		end
		if self.button and self.button.label then
			local posX_Now = self.button.label:getPositionX()
			self.button.label:setPositionX( posX_Now - 10 )
		end
	end


end


function FruitTreeUpgradePanel_New:onKeyBackClicked()
	-- self.button:setEnabled(false)
	-- self.close:setTouchEnabled(false)
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
end

FruitTreeUpgradePanel = class(BasePanel)

function FruitTreeUpgradePanel:create()
	local panel = FruitTreeUpgradePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_fruit_tree)
	if not panel:_init() then panel = nil end
	return panel
end

function FruitTreeUpgradePanel:_init()
	self.panel = self:buildInterfaceGroup("fruitTreeUpgradePanel")
	BasePanel.init(self, self.panel)

	self.button = self.panel:getChildByName("button")
	self.close = self.panel:getChildByName("close")
	self.friendBtn = self.panel:getChildByName("friendBtn")
	self.coinBtn = self.panel:getChildByName("coinBtn")
	self.upgradeFriend = self.panel:getChildByName("upgradeFriend")
	self.upgradeFriendText = self.panel:getChildByName("upgradeFriendText")
	self.conditionText = self.panel:getChildByName("conditionText")
	self.upgradeCoin = self.panel:getChildByName("upgradeCoin")
	self.coin = self.panel:getChildByName("coin")

	self.condition = {}
	self.condition[0] = self.panel:getChildByName("condition0")
	self.condition[1] = self.panel:getChildByName("condition1")
	self.condition[2] = self.panel:getChildByName("condition2")
	self.condition[3] = self.panel:getChildByName("condition3")
	self.condition[5] = self.panel:getChildByName("condition5")

	self.upgradeText = self.panel:getChildByName("upgradeText")
	self.pickArrow = self.panel:getChildByName("pickArrow")
	self.coinArrow = self.panel:getChildByName("coinArrow")
	self.pickBefore = self.panel:getChildByName("pickBefore")
	self.pickAfter = self.panel:getChildByName("pickAfter")
	self.coinBefore = self.panel:getChildByName("coinBefore")
	self.coinAfter = self.panel:getChildByName("coinAfter")
	self.pickText = self.panel:getChildByName("pickText")
	self.coinText = self.panel:getChildByName("coinText")
	self.captain = self.panel:getChildByName("captain")
	self.hitArea = self.panel:getChildByName("hit_area")
	-- self.lock = self.panel:getChildByName("lock")
	-- self.lockText = self.panel:getChildByName("lockText")
	self.friendBtn = GroupButtonBase:create(self.friendBtn)
	self.coinBtn = GroupButtonBase:create(self.coinBtn)
	self.button = GroupButtonBase:create(self.button)

	self.levelTitle = self.panel:getChildByName("levelTitle")
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()	
	local titleTexts = { "升级到 ", tostring(level+1), " 级效果：" }
	for i,v in ipairs(titleTexts) do
		local t = self.levelTitle:getChildByName(tostring(i))
		if i == 2 then
			t:setPreferredSize(999999,45)
			t:setColor(ccc3(0x23,0x79,0x00))
		else
			t:setPreferredSize(999999,32)
			t:setColor(ccc3(0x66,0x33,0x00))
		end
		t:setString(v)

		if i > 1 then
			local lastBoundingBox = self.levelTitle:getChildByName(tostring(i-1)):boundingBox()
			t:setAnchorPoint(ccp(0,0.5))
			t:setPositionX(lastBoundingBox:getMaxX())
			t:setPositionY(lastBoundingBox:getMidY())
		end
	end

	self:scaleAccordingToResolutionConfig()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.size = self.hitArea:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}
	self:setPosition(ccp((vSize.width - self.size.width) / 2 + vOrigin.x, self.size.height + vOrigin.y))
	self.hitArea:removeFromParentAndCleanup(true)
	self.friendBtn:setColorMode(kGroupButtonColorMode.orange)
	self.coinBtn:setColorMode(kGroupButtonColorMode.blue)
	-- self.lock:setVisible(false)
	-- self.lockText:setVisible(false)

	local layer = LayerColor:create()
	layer:setOpacity(150)
	layer:setScale(4)
	layer:changeWidthAndHeight(vSize.width, vSize.height)
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(ccp(0.5,0.5))
	layer:setPositionX(vSize.width/2)
	layer:setPositionY(vSize.height/2)
	self.ui:addChildAt(layer,0)

	self.button:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.button"))
	self.coinBtn:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.coinButton"))
	-- self.upgradeFriendText:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.friendText"))
	
	self.upgradeText:setPreferredSize(999999,32)
	self.upgradeText:setColor(ccc3(0x66,0x33,0x00))
	self.upgradeText:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.upgradeText"))
	
	self.pickText:setPreferredSize(999999,32)
	self.pickText:setColor(ccc3(0x66,0x33,0x00))
	self.pickText:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.pickText"))
	self.pickBefore:setPreferredSize(999999,40)
	self.pickBefore:setColor(ccc3(0x23,0x79,0x00))
	self.pickBefore:setAnchorPoint(ccp(0,0.5))
	self.pickBefore:setPositionY(self.pickText:boundingBox():getMidY())
	self.pickAfter:setPreferredSize(999999,32)
	self.pickAfter:setColor(ccc3(0x66,0x33,0x00))

	self.coinText:setPreferredSize(999999,32)
	self.coinText:setColor(ccc3(0x66,0x33,0x00))
	-- self.coinText:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.coinText"))
	self.coinText:setString("银币果实额外收益：")
	self.coinBefore:setPreferredSize(999999,40)
	self.coinBefore:setColor(ccc3(0x23,0x79,0x00))
	self.coinBefore:setAnchorPoint(ccp(0,0.5))
	self.coinBefore:setPositionY(self.coinText:boundingBox():getMidY())
	self.coinAfter:setPreferredSize(999999,32)
	self.coinAfter:setColor(ccc3(0x66,0x33,0x00))


	self:refresh()

	local function onClose(evt)
		self.button:setEnabled(false)
		self.close:setTouchEnabled(false)
		self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
	end
	self.close:setTouchEnabled(true)
	self.close:setButtonMode(true)
	self.close:addEventListener(DisplayEvents.kTouchTap, onClose)

	local function onPopdown()
		self:refresh()
	end
	
	local function onBind(  )
		if not self.friendBtn.authType then
			return
		end

		local function onErrorCallback( ... )
			-- body
		end

		local function onCancelCallback( ... )

		end

		local function onSuccessCallback( ... )
			self:refresh()
		end

		if self.friendBtn.authType == PlatformAuthEnum.kPhone then

            local bGoToSvipPanel = false
            ----SVIP 绑定手机活动 不弹旧手机绑定ICON
            local bGoToSvipPanel = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()

            ----
            if bGoToSvipPanel then
                Director:sharedDirector():popScene()

                local function openActivity()
                    SVIPGetPhoneManager:getInstance():openActivity()
                end
                setTimeOut( openActivity, 1 )
            else
			    AccountBindingLogic:bindNewPhone(onCancelCallback, onSuccessCallback, AccountBindingSource.FRUIT_TREE)
            end
		else
			AccountBindingLogic:bindNewSns(self.friendBtn.authType, onSuccessCallback, onErrorCallback, onCancelCallback, AccountBindingSource.FRUIT_TREE)
		end
	end
	local function onPlay( ... )
		self:dispatchEvent(Event.new("gotoPlayTopLevel"))
	end
	self.friendBtn:addEventListener(DisplayEvents.kTouchTap, function( ... )
		if not self.friendBtn.condition then
			return
		end
		if self.friendBtn.condition == 5 then
			onBind()
		elseif self.friendBtn.condition == 3 then
			onPlay()
		end
	end)



	local function onCoinBtn(evt)
		local id = MarketManager:sharedInstance():getBuyCoinPageIndex()
		if id ~= 0 then
			local panel = createMarketPanel(id)
			panel:addEventListener(kPanelEvents.kClose, onPopdown)
			panel:popout()
		end
	end
	self.coinBtn:addEventListener(DisplayEvents.kTouchTap, onCoinBtn)
	local function onButton(evt)
		local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
		local inviteNeed = FruitTreePanelModel:sharedInstance():getUpgradeCondition(level + 1)
		local coin = FruitTreePanelModel:sharedInstance():getUserCoin()
		local coinNeed = FruitTreePanelModel:sharedInstance():getUpgradeCoin(level + 1)
		local function onSuccess(data)
			if self.isDisposed then return end
			local scene = HomeScene:sharedInstance()
			if scene then scene:checkDataChange() end

			local button = self.panel:getChildByName("button")
			self.button:playFloatAnimation('-'..tostring(coinNeed))

			-- 此次不弹出消耗银币的动画，因为必弹果树升级炫耀动画
			-- AchievementManager:onDataUpdate(AchievementManager.COIN_COST_NUM, tonumber(coinNeed) or 0)
			UserManager:getInstance().achievement.spentCoins = UserManager:getInstance().achievement.spentCoins + tonumber(coinNeed) or 0

			self:dispatchEvent(Event.new(kPanelEvents.kButton, nil, self))
		end
		local function onFail(err)
			if self.isDisposed then return end
			self.button:setEnabled(true)
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err), "negative"))
		end
		local function onCancel()
			if self.isDisposed then return end
			self.button:setEnabled(true)
		end

		local function startUpgrade()
			self.button:setEnabled(false)
			local logic = FruitTreeUpgradePanelLogic:create(self.invitedFriendCount)
			logic:upgrade(onSuccess, onFail, onCancel)
		end
		RequireNetworkAlert:callFuncWithLogged(startUpgrade)
	end
	self.button:addEventListener(DisplayEvents.kTouchTap, onButton)

	



	return true
end

function FruitTreeUpgradePanel:onKeyBackClicked()
	self.button:setEnabled(false)
	self.close:setTouchEnabled(false)
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
end

function FruitTreeUpgradePanel:refresh()
	if self.isDisposed then return end
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
	local enabled = not FruitTreePanelModel:sharedInstance():getUpgradeLocked(level + 1)

	local finish, coin, upgradeCoin = FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1)
	local coinText = ""
	if coin > 10000 then
		coinText = string.format("%d万",coin/10000)
	else
		coinText = tostring(coin)
	end
	if finish then
		self.coinBtn:setVisible(false)
		self.upgradeCoin:setRichText(string.format(
			"[#237900]%s[/#][#237900]/%d万[/#]",coinText,upgradeCoin/10000
		))
	else
		self.coinBtn:setVisible(true)
		enabled = false
		self.upgradeCoin:setRichText(string.format(
			"[#FF0000]%s[/#][#237900]/%d万[/#]",coinText,upgradeCoin/10000
		))
	end
	local scale = 32/self.upgradeCoin:getContentSize().height
	self.upgradeCoin:setScale(scale)
	self.conditionText:setScale(scale)

	local condition, fulfill, value, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
		
	for k,v in pairs(self.condition) do
		if k > 0 then
			v:setVisible(k == condition)
		end
	end

	local function setConditionText( condition,value,nextValue )
		if type(condition) == "string" and value == nil and nextValue == nil then
			self.conditionText:setRichText(condition)
		elseif value and nextValue and value >= nextValue then
			self.conditionText:setRichText(string.format(
				"[#663300]%s([#237900]%s[/#][#237900]/%s[/#])[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.condition"..tostring(condition),{ num=nextValue }),
				tostring(value),
				tostring(nextValue)
			))
		else
			self.conditionText:setRichText(string.format(
				"[#663300]%s([#FF0000]%s[/#][#237900]/%s[/#])[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.condition"..tostring(condition),{ num=nextValue }),
				tostring(value),
				tostring(nextValue)
			))
		end
	end

	if condition == 4 then --没有
		self.conditionText:setVisible(false)
		self.friendBtn:setVisible(false)
	elseif condition == 2 then
		self.friendBtn.condition = 2
		self.friendBtn:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.friendButton"))
		self.friendBtn:setVisible(true)

		if self.invitedFriendCount then
			fulfill, value = self.invitedFriendCount >= nextValue, self.invitedFriendCount
			if fulfill then
				self.friendBtn:setVisible(false)
			else
				self.friendBtn:setVisible(true)
				enabled = false
			end
			setConditionText(condition,value,nextValue)
		else
			local function onSuccess(data)
				self.invitedFriendCount = data
				self:refresh()
			end
			local function onFail(err)
				self.invitedFriendCount = 0
				self:refresh()
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
			end
			enabled = false
			setConditionText(string.format(
				"[#FF0000]%s[/#]",
				Localization:getInstance():getText("fruit.tree.panel.upgrade.loading")
			))

			local logic = FruitTreeUpgradePanelLogic:create()
			logic:getInvitedFriendCount(onSuccess, onFail)
		end
	else
		if condition == 5 then
			for k,v in pairs(self.condition[5]:getChildByName("sprite"):getChildrenList()) do
				v:setVisible(false)
			end

			local authTypes = {
				{PlatformAuthEnum.kQQ,"qq"},
				{PlatformAuthEnum.kWechat,"wechat"},
				{PlatformAuthEnum.kPhone,"phone"},
				{PlatformAuthEnum.k360,"360"},
				{PlatformAuthEnum.kMI,"mi"},
				{PlatformAuthEnum.kWDJ,"wdj"},
				{PlatformAuthEnum.kWeibo,"weibo"},
			}
			local cfgPriorityMaintenance = MaintenanceManager:getInstance():getMaintenanceByKey("FruitTreePushPriority")
			local cfgPriority
			if cfgPriorityMaintenance ~= nil then cfgPriority = cfgPriorityMaintenance.extra end
			if cfgPriority == nil then  cfgPriority = "phone,wechat,qq,360,mi,wdj,weibo" end

			table.sort(authTypes, function(a, b)
								   		local idxA = string.find(cfgPriority, a[2])
								   		local idxB = string.find(cfgPriority, b[2])
								   		if not idxA or not idxB then
								   			return false
								   		end
								   		if idxA == idxB then 
								   			return 
								   			false
								   		else return 
								   			idxA < idxB 
								   		end
								  end)
			self.friendBtn.authType = nil

			if _G.sns_token and _G.sns_token.authorType then
				local k = table.find(authTypes,function( v )
					return v[1] == _G.sns_token.authorType
				end)
				if k then
					self.condition[5]:getChildByName("sprite"):getChildByName(k[2]):setVisible(true)
				end
				setConditionText(string.format(
					"[#663300]绑定%s账号(已绑定)[/#]",
					PlatformConfig:getPlatformNameLocalization(_G.sns_token.authorType)
				))
				fulfill = true
			else
				
				
				for i,v in ipairs(authTypes) do
					if v[1] ~= PlatformAuthEnum.kQQ and PlatformConfig:hasAuthConfig(v[1]) then
						if fulfill then
							if UserManager.getInstance().profile:getSnsInfo(v[1]) then
								self.condition[5]:getChildByName("sprite"):getChildByName(v[2]):setVisible(true)
								self.friendBtn.authType = v[1]
								setConditionText(string.format(
									"[#663300]绑定%s账号(已绑定)[/#]",
									PlatformConfig:getPlatformNameLocalization(v[1])
								))
								break
							end
						else
							self.condition[5]:getChildByName("sprite"):getChildByName(v[2]):setVisible(true)
							self.friendBtn.authType = v[1]
							setConditionText(string.format(
								"[#663300]绑定%s账号(未绑定)[/#]",
								PlatformConfig:getPlatformNameLocalization(v[1])
							))
							break
						end
					end
				end
			end
			self.friendBtn.condition = 5
			self.friendBtn:setVisible(not fulfill)
			self.friendBtn:setString("绑定")
		elseif condition == 3 then
			setConditionText(condition,value,nextValue)
			self.friendBtn.condition = 3
			self.friendBtn:setVisible(not fulfill)
			self.friendBtn:setString("闯关")
		else
			setConditionText(condition,value,nextValue)
			self.friendBtn:setVisible(false)
		end

		if not fulfill then
			enabled = false
		end

	end

	local incPlus, plus, nextPlus,nextNextPlus = FruitTreePanelModel:sharedInstance():getShowUpgradePlus()
	-- self.coinBefore:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.plusValue", {plus = tostring(plus)}))
	-- self.coinAfter:setString(Localization:getInstance():getText("fruit.tree.panel.upgrade.plusValue", {plus = tostring(nextPlus)}))
	self.coinBefore:setString(string.format("%d%%",nextPlus))
	if nextNextPlus > 0 then
		self.coinAfter:setString(string.format("(下一级%d%%)",nextNextPlus))
	else
		self.coinAfter:setString("")
	end

	local incPick, pick, nextPick,nextNextPicked = FruitTreePanelModel:sharedInstance():getShowUpgradePick()
	self.pickBefore:setString(string.format("%d颗",nextPick))
	if nextNextPicked > 0 then
		self.pickAfter:setString(string.format("(下一级%d颗)",nextNextPicked))
	else
		self.pickAfter:setString("")
	end

	self.button:setEnabled(enabled)

end



function FruitTreeUpgradePanel:onEnterHandler() end

FruitTreeUpgradePanelLogic = class()

function FruitTreeUpgradePanelLogic:create(invitedFriendCount)
	local logic = FruitTreeUpgradePanelLogic.new()
	logic.invitedFriendCount = invitedFriendCount
	return logic
end

function FruitTreeUpgradePanelLogic:getInvitedFriendCount(successCallback, failCallback)
	local function onSuccess(evt)
		if not evt.data then
			if failCallback then failCallback(evt.data) end
			return
		end
		local length = 0
		for k, v in ipairs(evt.data) do
			if v.friendUid and tonumber(v.friendUid) ~= 0 then length = length + 1 end
		end
		if successCallback then successCallback(length) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local http = GetInviteFriendsInfo.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load()
end

function FruitTreeUpgradePanelLogic:upgrade(successCallback, failCallback, cancelCallback)
	--[[
  /**
     * reward 存在check condition时的check type
     */
    int CONDITION_CHECK_TYPE_NONE = 0;
    int CONDITION_CHECK_TYPE_STAR = 1;
    int CONDITION_CHECK_TYPE_INVITE = 2;
    int CONDITION_CHECK_TYPE_TOPLEVEL = 3;
    int CONDITION_CHECK_TYPE_UNKNOWN = 4;
    int CONDITION_CHECK_TYPE_CONNECT = 5;
    --]]



	local treeLevel = FruitTreePanelModel:getTreeLevel()
	local function onSuccess(evt)
		local extend = UserManager:getInstance():getUserExtendRef()
		if extend then extend:setFruitTreeLevel(extend:getFruitTreeLevel() + 1) end
		local costCoin = FruitTreePanelModel:sharedInstance():getUpgradeCoin()
		UserManager:getInstance():addCoin(-costCoin)

		local serviceExtend = UserService:getInstance():getUserExtendRef()
		if serviceExtend then serviceExtend:setFruitTreeLevel(serviceExtend:getFruitTreeLevel() + 1) end
		UserService:getInstance():addCoin(-costCoin)
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData() end
		GainAndConsumeMgr.getInstance():consumeCurrency(DcFeatureType.kFruitTree, DcDataCurrencyType.kCoin, costCoin, nil, nil, nil, nil, DcSourceType.kFruitTreeUpdate)

		DcUtil:fruitTreeUpgrade(treeLevel)
		if successCallback then successCallback(evt.data) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
	local upgrade, errCode = true, nil
	if not FruitTreePanelModel:sharedInstance():getFinishUpgradeCoin(level + 1) then upgrade, errCode = false, 730321 end -- not enough coin
	local uType, fulfill, _, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
	if uType ~= 2 then upgrade = upgrade and fulfill
	else upgrade = upgrade and (type(self.invitedFriendCount) == "number" and self.invitedFriendCount >= nextValue) end
	if upgrade then
			local http = UpgradeFruitTreeHttp.new(true)
			http:addEventListener(Events.kComplete, onSuccess)
			http:addEventListener(Events.kError, onFail)
			http:addEventListener(Events.kCancel, onCancel)
			http:syncLoad()
	else
		errCode = errCode or 730232 -- coindition fail
		if failCallback then failCallback(errCode) end
	end
end

FruitTreePanelModel = class()

local instance = nil
function FruitTreePanelModel:sharedInstance()
	if not instance then
		instance = FruitTreePanelModel.new()
		instance:_init()
	end
	return instance
end

function FruitTreePanelModel:_init()
	local meta = MetaManager:getInstance().fruits_upgrade
	self.upgrade = {}
	for k, v in ipairs(meta) do
		if v.level >= FRUIT_MAXLEVEL then
			FRUIT_MAXLEVEL = v.level
		end
		self.upgrade[v.level] = v 
	end
	meta = MetaManager:getInstance().fruits
	self.fruits = {}
	for k, v in ipairs(meta) do
		local rec = {id = v.id, level = v.level, upgrade = v.upgrade}
		for _, v2 in ipairs(v.reward) do
			if v2.itemId == 2 then rec.coin = v2.num
			elseif v2.itemId == 4 then rec.energy = v2.num
			elseif v2.itemId == 14 then rec.gold = v2.num end
		end
		table.insert(self.fruits, rec)
	end


	 -- if _G.isLocalDevelopMode  then printx(100 , "FruitTreePanelModel  self.upgrade =  " , table.tostring( self.upgrade ) ) end
	 -- if _G.isLocalDevelopMode  then printx(100 , "FruitTreePanelModel  FRUIT_MAXLEVEL =  " , FRUIT_MAXLEVEL ) end
end

function FruitTreePanelModel:getTreeLevel()
	local extend = UserManager:getInstance():getUserExtendRef()
	if extend then return extend:getFruitTreeLevel()
	else return 1 end
end

function FruitTreePanelModel:incTreeLevel()
	local extend = UserManager:getInstance():getUserExtendRef()
	if extend then
		extend:setFruitTreeLevel(extend:getFruitTreeLevel() + 1)
	end
end

function FruitTreePanelModel:canUpgrade()
	local level = self:getTreeLevel()
	if level >= FRUIT_MAXLEVEL then return false end
	return true
end

function FruitTreePanelModel:getPlus(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].plus then return 0 end
	return self.upgrade[level].plus
end

function FruitTreePanelModel:getShowUpgradePlus(level)
	level = level or self:getTreeLevel()
	local plus, nextPlus,nextNextPlus = self:getPlus(), self:getPlus(level + 1), self:getPlus(level + 2)
	if self:getUpgradeLocked(level + 2) then
		nextNextPlus = 0
	end
	return plus < nextPlus, plus, nextPlus,nextNextPlus
end

function FruitTreePanelModel:getPickCount(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].pickCount then return 0 end
	return self.upgrade[level].pickCount + Achievement:getRightsExtra( "FruitGetCount" )
end

function FruitTreePanelModel:getPickCountWithoutAchiRights(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].pickCount then return 0 end
	return self.upgrade[level].pickCount
end

function FruitTreePanelModel:getPicked()
	local dailyData = UserManager:getInstance():getDailyData()
	if not dailyData then return 0 end
	return dailyData.pickFruitCount
end

function FruitTreePanelModel:getShowUpgradePick(level)
	level = level or self:getTreeLevel()
	local picked, nextPicked, nextNextPicked = self:getPickCountWithoutAchiRights(), self:getPickCountWithoutAchiRights(level + 1), self:getPickCountWithoutAchiRights(level + 2)
	if self:getUpgradeLocked(level + 2) then
		nextNextPicked = 0
	end
	return picked < nextPicked, picked, nextPicked, nextNextPicked
end

function FruitTreePanelModel:getUpgradeLocked(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or self.upgrade[level].lock == nil then return true end
	return self.upgrade[level].lock
end

function FruitTreePanelModel:getUpgradeCondition(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].upgradeCondition then return nil end
	local condition = self.upgrade[level].upgradeCondition[1]
	return condition.itemId, condition.num
end

function FruitTreePanelModel:getIsFinishUpgradeCondition(level)
	-- if 1 then
	-- 	return 4, true, 0, 0
	-- end

	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].upgradeCondition then return 0, false, 0, 0 end
	local condition = self.upgrade[level].upgradeCondition[1]
	if type(condition) ~= "table" then return 0, false, 0, 0 end
	if condition.itemId == 1 then
		local star = UserManager:getInstance():getUserRef():getStar()
		local finish = (star >= condition.num)
		return condition.itemId, finish, star, condition.num
	elseif condition.itemId == 3 then
		local level = UserManager:getInstance():getTopPassedLevel()
		return condition.itemId, level >= condition.num, level, condition.num
	elseif condition.itemId == 5 then --绑定sns账号qq&手机
		if WXJPPackageUtil.getInstance():isWXJPPackage() then 
			--精品包不显示绑定账号相关
			return 4, true, 0, 0
		end
		local finish = false
		for k,v in pairs(PlatformAuthEnum) do
			if v ~= PlatformAuthEnum.kGuest and (PlatformConfig:hasAuthConfig(v) or (_G.sns_token and _G.sns_token.authorType == v))then
				if UserManager.getInstance().profile:getSnsInfo(v) then
					finish = true
					break
				end
			end	
		end
		return condition.itemId,finish,0,condition.num
	elseif condition.itemId == 4 then --没有这个条件
		return condition.itemId, true, 0, 0
	else
		return condition.itemId, false, 0, condition.num
	end
end

function FruitTreePanelModel:getFruitCoinRewardString()
	for k, v in ipairs(self.fruits) do
		if v.level == 6 then return v.coin end
	end
end

function FruitTreePanelModel:getFruitEnergyRewardString()
	for k, v in ipairs(self.fruits) do
		if v.level == 6 then return v.energy end
	end
end

function FruitTreePanelModel:getFruitGoldRewardString()
	for k, v in ipairs(self.fruits) do
		if v.level == 6 then return v.gold end
	end
end

function FruitTreePanelModel:getUpgradeCoin(level)
	level = level or self:getTreeLevel()
	if not self.upgrade[level] or not self.upgrade[level].coin then return 0 end
	return self.upgrade[level].coin
end

function FruitTreePanelModel:getUserCoin()
	local user = UserManager:getInstance():getUserRef()
	if not user then return 0 end
	return user:getCoin()
end

function FruitTreePanelModel:getFinishUpgradeCoin(level)
	level = level or self:getTreeLevel()
	local finish, upgradeCoin = true, 99999999
	if not self.upgrade[level] or not self.upgrade[level].coin then finish = false end
	upgradeCoin = self:getUpgradeCoin(level)
	local user = UserManager:getInstance():getUserRef()
	if not user then return finish, 0, upgradeCoin end
	local coin = user:getCoin()
	if coin < upgradeCoin then finish = false end
	return finish, coin, upgradeCoin
end