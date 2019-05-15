--[[
 * StarBankAddStarSuccessPanel
 * @date    2017-12-13 18:20:55
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

StarBankAddStarSuccessPanel = class(BasePanel)

function StarBankAddStarSuccessPanel:ctor( ... )
	-- body
end

function StarBankAddStarSuccessPanel:create( preStarNum, starNum, gainWm, hadFull )
	local panel = StarBankAddStarSuccessPanel.new()
	panel:loadRequiredResource("ui/StarBankAddStarSuccessPanel.json")
	panel:init(preStarNum, starNum, gainWm, hadFull)
	return panel
end

function StarBankAddStarSuccessPanel:init( preStarNum, starNum, gainWm, hadFull )
	FrameLoader:loadArmature('skeleton/StarBankAddStarSuccess', 'StarBankAddStarSuccess', 'StarBankAddStarSuccess')

	self.ui = self:buildInterfaceGroup("StarBankAddStar/SuccessPanel")
	BasePanel.init(self, self.ui)

	self.preStarNum = preStarNum
	self.starNum = starNum
	self.gainWm = gainWm
	self.hadFull = hadFull
	self.ui:getChildByName("ph"):setVisible(false)

	local animNode = ArmatureNode:create("StarBankAddStarSuccess")
	if hadFull then
		animNode:playByIndex(1)
	else
		animNode:playByIndex(0)
	end
	animNode:update(0.001)
	animNode:stop()
	animNode:unscheduleUpdate()
	self.ui:addChild(animNode)
	animNode:setPosition(ccp(70, 112))
	self.animNode = animNode

	local config = StarBank:getConfig()
	local state = StarBank.state

	local star3 = {1,2,3}
	local star4 = {4,5,6,7}

	local visibleIndex = starNum == 4 and star4 or star3
	local notVisibleIndex = starNum == 4 and star3 or star4

	for _,index in ipairs(notVisibleIndex) do
		self:setSlotVisible("star"..index, false)
		self:setSlotVisible("stara"..index)
	end

	self:setSlotVisible("starbg"..(starNum == 4 and 1 or 2), false)

	self:setSlotVisible("bow1", config.color == "blue")
	self:setSlotVisible("bow2", config.color == "green")
	self:setSlotVisible("bow3", config.color == "orange")
	self:setSlotVisible("bow4", config.color == "purple")
	self:setSlotVisible("bow5", config.color == "gold")

	local showStar = preStarNum
	for index=1,starNum do
		if index <= showStar then
			self:setSlotVisible("star"..(index + visibleIndex[1] - 1), false)
		else
			self:setSlotVisible("stara"..(index + visibleIndex[1] - 1), false)
		end
	end

	for index=starNum+1,4 do
		self:setSlotVisible("star"..index, false)
		self:setSlotVisible("stara"..index, false)
	end

	if state == StarBankState.kNotEnoughBuy then
		for i=2,4 do
			self:setSlotVisible("coin"..i, false)
		end
	elseif state == StarBankState.kNotFullCanBuy then
		for i=3,4 do
			self:setSlotVisible("coin"..i, false)
		end
	end

	if state ~= StarBankState.kFullCanBuy then
		self.ui:getChildByName("bg"):setScaleY(0.85)
	end

	if state == StarBankState.kFullCanBuy then
		self:setSlotVisible("bs1", false)
	else
		self:setSlotVisible("abottle2", false)
		self:setSlotVisible("abottle4", false)
		self:setSlotVisible("abs2", false)
		self:setSlotVisible("abottle3", false)
		self:setSlotVisible("fullbg", false)
	end

	local time = self.ui:getChildByName("time")
	self.timeTxt = TextField:createWithUIAdjustment(time:getChildByName('ph'), time:getChildByName('time'))
    time:addChild(self.timeTxt)
    time:setVisible(state == StarBankState.kFullCanBuy)

	local slot = animNode:getSlot('tip')
    local wmnum = BitmapText:create(tostring(StarBank.curWm), 'fnt/piggybank.fnt', 0)
    wmnum:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(wmnum)
    wmnum:setPosition(ccp(93, -114))
    slot:setDisplayImage(sprite.refCocosObj)

    if state == StarBankState.kFullCanBuy then
		self:setSlotVisible("tip", false)
		local slot = animNode:getSlot('qipao')
	    local sprite = Sprite:createEmpty()
	    local qipao = Sprite:create("skeleton/StarBankAddStarSuccess/StarBankFullPop.png")
	    sprite:addChild(qipao)
	    qipao:setPosition(ccp(110, -90))
	    slot:setDisplayImage(sprite.refCocosObj)
	end

    local slot = animNode:getSlot('coinnumber')
    local coinnumber = self.builder:buildGroup("StarBankAddStar/coinnumber")
    coinnumber:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(coinnumber)
    self.coinnumber = coinnumber
    coinnumber:setPosition(ccp(-70, 0))

    local cn = coinnumber:getChildByName("cn")
    self.addStarNum = TextField:createWithUIAdjustment(cn:getChildByName("ph"), cn:getChildByName("number"))
    self.addStarNum:setString("+0")
    cn:addChild(self.addStarNum)
    local size = self.addStarNum:getContentSize()
    local cnbg = coinnumber:getChildByName("bg")
    local bgsize = cnbg:getGroupBounds().size
    cn:setPositionX(bgsize.width/2 - (size.width+95)/2)
    self.cn = cn

    slot:setDisplayImage(sprite.refCocosObj)

    Notify:register("StarBankUpdateStateEvent", self.updateState, self)
    self:updateState()
end

function StarBankAddStarSuccessPanel:updateState( ... )
	local state = StarBank.state
	if state == StarBankState.kFullCanBuy and not self.isDisposed then 
		local now = Localhost:timeInSec()
		local t = StarBank.buyDeadline - now
		self.timeTxt:setString("剩余："..convertSecondToHHMMSSFormat(t))
	end
end

function StarBankAddStarSuccessPanel:setSlotVisible( slotName, visible )
	local slot = self.animNode:getSlot(slotName)
	if slot and not visible then
		local sprite = Sprite:createEmpty()
	    slot:setDisplayImage(sprite.refCocosObj)
	end
end

function StarBankAddStarSuccessPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
	Notify:unregister("StarBankUpdateStateEvent", self)
end

function StarBankAddStarSuccessPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function StarBankAddStarSuccessPanel:createShowAnim()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local size = {width = winSize.width, height = winSize.height}

    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + size.height / 2
        self:setPosition(ccp(initPosX, initPosY))
    end

    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter = CCMoveTo:create(0.2, ccp(centerPosX, centerPosY))

    local function onEnterAnimationFinished( )self:onEnterAnimationFinished() end
    local function onTouch( evt )
    	local ph = self.ui:getChildByName("ph")
    	if self.hadFull and ph:hitTestPoint(evt.globalPosition, true) then
			StarBank:showPanel(3)
			StarBank.needPopPanel = false
			self:onCloseBtnTapped()
			return
		end

    	local bg = self.ui:getChildByName("bg")
		if bg:hitTestPoint(evt.globalPosition, true) then
			return
		end

    	if StarBank.needPopPanel then
    		StarBank.needPopPanel = false
			StarBank:showPanel(1)
			self:onCloseBtnTapped()
			return
		end
		self:remove()
    end

    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(moveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    actionArray:addObject(CCCallFunc:create(function ( ... )
    	local layer = Layer:create()
    	layer:setContentSize(CCSizeMake(size.width, size.height))
		layer:setTouchEnabled(true)
		local pos = CCDirector:sharedDirector():getVisibleOrigin()
		pos = self.ui:convertToNodeSpace(pos)
		layer:setPositionXY(pos.x, pos.y)
		self.ui:addChild(layer)
		layer:addEventListener(DisplayEvents.kTouchTap, onTouch)
    end))
    actionArray:addObject(CCDelayTime:create(5))
    actionArray:addObject(CCMoveBy:create(0.2,ccp(0, size.height/2)))
    actionArray:addObject(CCCallFunc:create(function ( ... )
    	self:onCloseBtnTapped()
    	if StarBank.needPopPanel then
    		StarBank.needPopPanel = false
			StarBank:showPanel(1)
		end
    end))

    return CCSequence:create(actionArray)
end

function StarBankAddStarSuccessPanel:remove()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	self:stopAllActions()
	local actionArray = CCArray:create()
    actionArray:addObject(CCMoveBy:create(0.2,ccp(0, winSize.height/2)))
    actionArray:addObject(CCCallFunc:create(function ( ... )
    	self:onCloseBtnTapped()
    end))

     self:runAction(CCSequence:create(actionArray))
end

function StarBankAddStarSuccessPanel:onEnterAnimationFinished()
	local scheduleObj = CocosObject:create()
	scheduleObj:scheduleUpdateWithPriority(
		function()
			if self.animNode.isDisposed then return end
			self.animNode.refCocosObj:advanceTime(1/45)
		end
		,1)
	self.animNode:addChild(scheduleObj)
	if self.hadFull then
		self.animNode:playByIndex(1)
	else
		self.animNode:playByIndex(0)
	end

	local wm = 0
    local frame = 6
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(0.3))
    for i=1,frame do
    	actionArray:addObject(CCDelayTime:create(0.05))
	    actionArray:addObject(CCCallFunc:create(function ( ... )
	    	wm = wm + math.ceil(self.gainWm / frame)
	    	if wm > self.gainWm then
	    		wm = self.gainWm
	    	end
	    	self.addStarNum:setString("+"..wm)
	    	local size = self.addStarNum:getContentSize()
	    	local cnbg = self.coinnumber:getChildByName("bg")
		    local bgsize = cnbg:getGroupBounds().size
		    self.cn:setPositionX(bgsize.width/2 - (size.width+100)/2)
	    end))
    end
    self.addStarNum:runAction(CCSequence:create(actionArray))
end

function StarBankAddStarSuccessPanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)
end