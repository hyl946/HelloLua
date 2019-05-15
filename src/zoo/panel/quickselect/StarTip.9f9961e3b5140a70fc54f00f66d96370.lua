local UIHelper = require 'zoo.panel.UIHelper'
local TIP_DURATION = 3 --sec

StarTip = class(BasePanel)

local arrowPosY = 32

function StarTip:create(content, delta, duration)
	local panel = StarTip.new()
	panel:init(content, delta, duration) 
	return panel
end


function StarTip:init(content, delta, duration)
	-- 默认值以及依赖资源的值
	self.defaultWidth = 287.45
	self.defaultHeight = 227.15
	self.contentMargin = 30 --px
	self.duration = duration or TIP_DURATION

	self.delta = delta
	-- 创建窗口
	self.ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/startips')
	BasePanel.init(self, self.ui)
	
	-- 获取控件
	self.panel = self.ui:getChildByName("startipsbg")
	self.arrow = self.ui:getChildByName("arrow")
	-- self.arrow:setVisible(false)
	if not self.panel or not self.arrow then return false end
	self.arrowHeight = self.arrow:getGroupBounds().size.height

	local function createStarText( starNum  ,posX , posY , panel ,_color)

    	local textTable = {}
    	textTable[1] = BitmapText:create(  "再获得" , "fnt/register2.fnt")
    	textTable[2] = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/starticon0000")
    	textTable[3] = BitmapText:create(  starNum.."" , "fnt/hud.fnt")
    	textTable[4] = BitmapText:create(  "颗可以领奖" , "fnt/register2.fnt")
    	textTable[3]:setScale(1.2)
    	local totalWidth = 0

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
    	end

    	local leftPosX = posX - totalWidth/2 

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		local leftNode = textTable[i-1]
    		textNode:setAnchorPoint(ccp(0.5,0.5))
    		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
    		if leftNode then
    			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
    		end
    		textNode:setPositionXY( myPosX , posY )
    		panel:addChild( textNode )
    		if i~=2 then
    			textNode:setColor(_color)
    		end
    		
    	end
    	return totalWidth
    end 

    local totalWidth = createStarText( delta , -7 , 65 , self.ui , hex2ccc3('406CCD') )

	if content then
		self.panel:addChild(content)
		local size = content:getContentSize()
		local panelSize = CCSizeMake(size.width + self.contentMargin * 2, size.height + self.contentMargin * 2)
		self.width = panelSize.width
		self.height = panelSize.height
		content:setPosition(ccp(self.contentMargin, self.contentMargin + size.height))
		self.panel:addChild(content)
	end

	self.width, self.height = self.width or self.defaultWidth, self.height or self.defaultHeight
	self.panel:setPreferredSize(CCSizeMake( totalWidth + 75 , 97))

	self.panel:setAnchorPoint(ccp(0, 1))
	self.panel:setPosition(ccp(0, 0))

	self.ui:setTouchEnabled(true, 0, true)
	local function __onTouchDelegate(event)
		self:onTouchTap(event)
	end
	self.ui:addEventListener(DisplayEvents.kTouchTap, __onTouchDelegate)

	self.touchCheckLayer = Layer:create()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	self.touchCheckLayer:setAnchorPoint(ccp(0,0))
	self.touchCheckLayer:setPosition(ccp(visibleOrigin.x, visibleOrigin.y))
	self.touchCheckLayer:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	self.touchCheckLayer:setTouchEnabled(true, 0, false)
	Director:sharedDirector():getRunningScene():addChild(self.touchCheckLayer, SceneLayerShowKey.POP_OUT_LAYER)





	

	return true
end

function StarTip:onTouchTap(event)
	if _G.isLocalDevelopMode then printx(0, 'touched') end
	local time = self.duration --sec
	if self.timerId then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
		self.timerId = 
			Director:sharedDirector():getScheduler():scheduleScriptFunc(
		                                                   function () self:hide() end,
											               time, 	
											               false)
	end
end

-- rect: the box around which the tip should show itself
-- direction: on which direction of the rect the tip should put itself
function StarTip:pointTo(rect, preferredDirection)
	local size = rect.size
	local origin = rect.origin
	-- origin.x = origin.x - 40
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local left = ccp(origin.x, origin.y + size.height / 2)
	local right = ccp(origin.x + size.width, origin.y + size.height / 2)
	local top = ccp(origin.x + size.width / 2, origin.y + size.height)
	local bottom = ccp(origin.x + size.width / 2, origin.y)

	local arrowSize = self.arrow:getGroupBounds().size
	local panelSize = self.panel:getGroupBounds().size

	local direction = right -- default the tip appears on the right

	-- check border
	local rightOut = false
	local leftOut = false
	local topOut = false
	local bottomOut = false

	if right.x + arrowSize.width + panelSize.width > visibleOrigin.x + visibleSize.width
	then 
		rightOut = true
	end

	if left.x - arrowSize.width - panelSize.width < visibleOrigin.x
	then 
		leftOut = true
	end

	if top.y + arrowSize.height + panelSize.height > visibleOrigin.y + visibleSize.height
	then 
		topOut = true
	end

	if top.y - arrowSize.height - panelSize.height < visibleOrigin.y
	then
		bottomOut = true
	end


	local panelOffset = arrowSize.width * (0.33) 

	local function tryUpOrDown(isUp)
		if _G.isLocalDevelopMode then printx(0, 'tryTop') end
		--先尝试居中
		local maxOffset = panelSize.width / 2 - arrowSize.width / 2
		local leftBorder = top.x - panelSize.width/2
		local rightBorder = top.x + panelSize.width/2
		local offset = 0
		if leftBorder < visibleOrigin.x then
			offset = visibleOrigin.x - leftBorder -- offset > 0
			if offset > maxOffset then offset = maxOffset end
		elseif rightBorder > visibleOrigin.x + visibleSize.width then
			offset = (visibleOrigin.x + visibleSize.width) - rightBorder
			if offset < -maxOffset then offset = -maxOffset end
		end
		if _G.isLocalDevelopMode then printx(0, 'offset', offset) end
		if isUp then
			self.ui:setAnchorPoint(ccp(0.5, 0))
			self.arrow:setRotation(0)
			self.arrow:setPosition(ccp(0,arrowPosY))
			self.panel:setAnchorPoint(ccp(0.5, 0))
			self.panel:setPosition(ccp(offset, panelOffset))
			self.ui:setPosition(top)
		else
			self.ui:setAnchorPoint(ccp(0.5, 1))
			self.arrow:setRotation(180)
			self.arrow:setPosition(ccp(0, arrowPosY))
			self.panel:setAnchorPoint(ccp(0.5, 1))
			self.panel:setPosition(ccp(offset, -panelOffset))
			self.ui:setPosition(bottom)
		end
	end

	local function tryLeftOrRight(isLeft)
		if _G.isLocalDevelopMode then printx(0, 'tryLeft') end
		local maxOffset = panelSize.height / 2 - arrowSize.height / 2
		local topBorder = left.y + panelSize.height/2
		local bottomBorder = left.y - panelSize.height/2
		local offset = 0
		if bottomBorder < visibleOrigin.y then
			offset = visibleOrigin.y - bottomBorder -- offset > 0
			if offset > maxOffset then offset = maxOffset end
		elseif topBorder > visibleOrigin.y + visibleSize.height then
			offset = (visibleOrigin.y + visibleSize.height) - topBorder
			if offset < -maxOffset then offset = -maxOffset end
		end
		if _G.isLocalDevelopMode then printx(0, 'offset', offset) end
		if isLeft then
			self.ui:setAnchorPoint(ccp(1, 0.5))
			self.arrow:setRotation(-90)
			self.arrow:setPosition(ccp(0, arrowPosY))
			self.panel:setAnchorPoint(ccp(1, 0.5))
			self.panel:setPosition(ccp(-panelOffset, offset))
			self.ui:setPosition(left)
		else
			self.ui:setAnchorPoint(ccp(0, 0.5))
			self.arrow:setRotation(90) -- point to left
			self.arrow:setPosition(ccp(0, arrowPosY))
			self.panel:setAnchorPoint(ccp(0, 0.5))
			self.panel:setPosition(ccp(panelOffset, offset))
			self.ui:setPosition(right)
		end
	end

	if preferredDirection == 'up' and not topOut then
		tryUpOrDown(true)
	elseif preferredDirection == 'down' and not bottomOut then
		tryUpOrDown(false)
	elseif preferredDirection == 'left' and not leftOut then
		tryLeftOrRight(true)
	elseif preferredDirection == 'right' and not rightOut then
		tryLeftOrRight(false)
	else

		if not topOut then
			tryUpOrDown(true)
		elseif not leftOut then
			tryLeftOrRight(true)
		elseif not rightOut then
			tryLeftOrRight(false)
		elseif not bottomOut then
			tryUpOrDown(false)
		else 
			tryUpOrDown(true)
		end
	end

end


function StarTip:onEnterHandler(evt)
	-- 什么也不做，只为了覆盖方法
end

function StarTip:isPopedOut()
	if self._isPopedOut == nil then self._isPopedOut = false end
	return self._isPopedOut;
end

-- preferredDirection : 'up' 'down' 'left' 'right'
function StarTip:show(rect, preferredDirection)
	local time = self.duration --sec
	local function __hideDelegate(event)
		self:hide()
	end

	self.timerId = Director:sharedDirector():getScheduler():scheduleScriptFunc(__hideDelegate, time, false)
	self.touchCheckLayer:addEventListener(DisplayEvents.kTouchBegin, __hideDelegate, nil)

	local scene = Director:sharedDirector():getRunningScene()
	if scene then 

		if _G.isLocalDevelopMode then printx(0, self.ui:getGroupBounds().origin.x, self.ui:getGroupBounds().origin.y) end
		if _G.isLocalDevelopMode then printx(0, self.ui:getGroupBounds().size.width, self.ui:getGroupBounds().size.height) end
		self:pointTo(rect, preferredDirection)
		scene:addChild(self, SceneLayerShowKey.POP_OUT_LAYER)
		self._isPopedOut = true
	end
end

function StarTip:hide()
	if self.timerId ~= nil then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
	end
	self:removeFromParentAndCleanup(true)
	self.touchCheckLayer:removeEventListenerByName(DisplayEvents.kTouchBegin)
	self.touchCheckLayer:removeFromParentAndCleanup(true)
	self._isPopedOut = false
end

function StarTip:dispose()
	print 'bubble tip dispose'
	-- self:hide()
	-- self.touchCheckLayer:removeFromParentAndCleanup(false)
	BaseUI.dispose(self)
end

