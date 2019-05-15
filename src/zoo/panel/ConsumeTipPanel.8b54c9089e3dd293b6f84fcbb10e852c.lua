
require "zoo.panel.ConsumeHistoryPanel"

local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
local visibleSize = Director.sharedDirector():getVisibleSize()

ConsumeTipPanel = class(BasePanel)

function ConsumeTipPanel:create( price )
	local panel = ConsumeTipPanel.new()
	panel:loadRequiredResource("ui/consume_tip.json")
	panel:init(price)
	return panel
end

function ConsumeTipPanel:init( props )

	self.ui = self:buildInterfaceGroup("consumeTip/panel")
	BasePanel.init(self, self.ui)

	local text= self.ui:getChildByName("text")
	self._text = text 
	local string = Localization:getInstance():getText("consume.tip.panel.text.1",{n=props})
	text:setDimensions(CCSizeMake(0,0))
	self:setText(string)
	-- text:setAnchorPoint(ccp(0,0.5))
	-- text:setPositionY(text:boundingBox():getMidY())
	local size = text:getContentSize()
	local bg = self.ui:getChildByName("bg")
	if bg then
		local bgSize = bg:getGroupBounds().size
		text:setPositionX((bgSize.width - size.width) / 2)
	end


	local text2 = self.ui:getChildByName("text2")
	local icon = self.ui:getChildByName("icon")

	if ConsumeHistoryPanel.isShowCustomerPhone() then
		text2:setString(Localization:getInstance():getText("consume.tip.panel.text.2"))
		text2:setAnchorPoint(ccp(0,0.5))
		text2:setPositionY(icon:boundingBox():getMidY())
		text2:setDimensions(CCSizeMake(text2:getDimensions().width,0))
	else
		icon:setVisible(false)
		-- text:setPositionX(text:getPositionX() - 25)
		text:setPositionY(text:getPositionY() - 20)
	end


	self.link = self.ui:getChildByName("logLink")
	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap,function()
		self.ui:setTouchEnabled(false)
		self:runAction(CCCallFunc:create(function( ... )
			ConsumeHistoryPanel:create():popout()
			
			self:removeFromParentAndCleanup(true)
		end))
	end)

end

function ConsumeTipPanel:setText( text )
	-- body
	self._text:setString(text)
end

function ConsumeTipPanel:popout(callback, duration)
	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end
	if scene:is(GamePlaySceneUI) then 
		self.link:setVisible(false)	
		self.ui:setTouchEnabled(false)
	end

	local bounds = self:getGroupBounds()

	local container = CocosObject:create()
	container:setContentSize(bounds.size)
	container:setAnchorPoint(ccp(0.5,0.5))

	self:setPositionY(bounds.size.height)
	container:addChild(self)

	local toPos = ccp(
		visibleOrigin.x + visibleSize.width/2 + 7,
		visibleOrigin.y + visibleSize.height - bounds.size.height/2 - 40
	)
	local actions = CCArray:create()

	if scene:is(HomeScene) then 
		local goldBounds = scene.goldButton.ui:getGroupBounds()

		container:setScale(0)
		container:setPositionX(goldBounds:getMaxX())
		container:setPositionY(goldBounds:getMinY())

		actions:addObject(CCEaseBounceOut:create(CCSpawn:createWithTwoActions(
			CCScaleTo:create(10/30,1.0),
			CCMoveTo:create(10/30,toPos)
		)))
	else
		container:setPositionX(toPos.x)
		container:setPositionY(visibleOrigin.y + visibleSize.height + bounds.size.height/2)

		actions:addObject(CCEaseBounceOut:create(
			CCMoveTo:create(10/30,toPos)
		))
	end

	actions:addObject(CCDelayTime:create(duration or 3))
	actions:addObject(CCCallFunc:create(function( ... )
		if callback then
			callback()
		end
		scene:superRemoveChild(container, true)
	end))

	container:runAction(CCSequence:create(actions))

	scene:superAddChild(container)
end






-- 利用原来的素材，新写一个创建并初始化的方法，原来的一些逻辑不需要了
-- 和原来的逻辑可以共存 互不影响
-- 新逻辑可以自适应高度

function ConsumeTipPanel:createWithString(string, isShowLogBtn)
	local panel = ConsumeTipPanel.new()
	panel:loadRequiredResource("ui/consume_tip.json")
	panel:initWithString(string, isShowLogBtn)
	return panel
end


function ConsumeTipPanel:initWithString(string , isShowLogBtn)
	if isShowLogBtn == nil then
		isShowLogBtn = true
	end

	local lineSpace = 20        -- 背景框 Text link 三者之间的间距
	local offsetY = lineSpace

	self.ui = self:buildInterfaceGroup("consumeTip/panel")
	BasePanel.init(self, self.ui)

	self.text = self.ui:getChildByName("text")

	self.link = self.ui:getChildByName("logLink")
	self.bg = self.ui:getChildByName("bg")

	self.text:setPositionY(- offsetY)
	
	self.text:setDimensions(CCSizeMake(self.text:getDimensions().width, 0)) -- 不限制高度 可以放下任意长度的文案，也能取到实际高度
	self.text:setString(string)

	-- IOS上在这会缺一行字，需要额外多加一个像素
	self.text:setDimensions(CCSizeMake(self.text:getDimensions().width, self.text:getContentSize().height + 1))
	self.text:setString(string)

	offsetY = offsetY + self.text:getContentSize().height + lineSpace

	self.link:setPositionY(- offsetY)
	if isShowLogBtn then
		self.ui:setTouchEnabled(true, 0, true)
		self.ui:addEventListener(DisplayEvents.kTouchTap,function()
			self.ui:setTouchEnabled(false)
			self:runAction(CCCallFunc:create(function( ... )
				ConsumeHistoryPanel:create():popout()
			end))
		end)
		offsetY = offsetY + self.link:getGroupBounds().size.height + lineSpace
	else
		self.link:setVisible(false)
	end

	self.bg:setPreferredSize(CCSizeMake(self.bg:getGroupBounds().size.width, offsetY))

	local text2 = self.ui:getChildByName("text2")
	local icon = self.ui:getChildByName("icon")
	text2:setVisible(false)
	icon:setVisible(false)
end

function ConsumeTipPanel:getGoldIconWorldPosXY()
	local bounds = self:getGroupBounds()
	return bounds:getMidX(), bounds:getMidY()
end
