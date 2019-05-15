
HappyCoinCountdown = class(LayerColor)

function HappyCoinCountdown:ctor()

end

function HappyCoinCountdown:init()
	LayerColor.initLayer(self)	
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.market_panel)
	local ui = builder:buildGroup("ios_promotion/countdown")
	self.ui = ui

	local spriteRect = self.ui:getGroupBounds()
	self.uiSize = {width = spriteRect.size.width, height = spriteRect.size.height}
	self:changeWidthAndHeight(self.uiSize.width, self.uiSize.height)
	self:setAnchorPoint(ccp(0.5, 0))
	self:addChild(self.ui)
	self.ui:setPosition(ccp(0, self.uiSize.height))
	self:setOpacity(0)

	self.countdownLabel = self.ui:getChildByName("label")
	if  __IOS or __WIN32 then
		self.countdownTime = IosPayGuide:getOneYuanFCashLeftSeconds()
	elseif __ANDROID then 
		self.countdownTime = AndroidSalesManager.getInstance():getGoldSalesLeftSeconds() 
	end
	
	self:startTimer()
end

function HappyCoinCountdown:startTimer()
	local function onTick()
		if self.isDisposed then
			return
		end
		local str
		if self.countdownTime > 0 then
			local timeLabel 
			-- if self.countdownTime > 3600 then 
				timeLabel = convertSecondToHHMMSSFormat(self.countdownTime)
			-- else
			-- 	timeLabel = convertSecondToMMSSFormat(self.countdownTime)
			-- end

			self.countdownLabel:setString("特惠 "..timeLabel)
			if  __IOS or __WIN32 then
				self.countdownTime = IosPayGuide:getOneYuanFCashLeftSeconds()
			elseif __ANDROID then 
				self.countdownTime = AndroidSalesManager.getInstance():getGoldSalesLeftSeconds() 
			end
		else
			if self.timer.started == true then
				self.countdownLabel:setString("特惠 "..convertSecondToMMSSFormat(0))
				self.timer:stop()
				self:removeFromParentAndCleanup(true)
			end
		end
	end
	self.timer = OneSecondTimer:create()
	self.timer:setOneSecondCallback(onTick)
	self.timer:start()
	onTick()
end

function HappyCoinCountdown:playShowAnimation()
	self:setScale(0)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1))
	arr:addObject(CCScaleTo:create(0.3, 0.95, 1.05))
	arr:addObject(CCScaleTo:create(0.2, 1.05, 0.95))
	arr:addObject(CCScaleTo:create(0.15, 1))
	self:runAction(CCSequence:create(arr))
end

function HappyCoinCountdown:getSize()
	return self.uiSize	
end

function HappyCoinCountdown:dispose()
	if self.timer and self.timer.started then 
		self.timer:stop()
	end
	LayerColor.dispose(self)	
end

function HappyCoinCountdown:create()
	local countdown = HappyCoinCountdown.new()
	countdown:init()
	return countdown
end