
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月11日 11:26:37
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- TreeTopLockedCloud
---------------------------------------------------

assert(not TreeTopLockedCloud)
assert(BaseUI)
TreeTopLockedCloud = class(BaseUI)

function TreeTopLockedCloud:init(...)
	assert(#{...} == 0)

	-------------------
	-- Init Base Class
	-- ---------------
	BaseUI.init(self, false)

	-- ----------------
	-- Create Wait Cloud
	-- -------------------
	-- self.waitedCloud	= Clouds:buildWait()
	self.waitedCloud = self:buildStatic()
	
	-- Set Self Texture
	local texture = self.waitedCloud:getTexture()
	self.batchNode = SpriteBatchNode:createWithTexture(texture)

	self.batchNode:addChild(self.waitedCloud)

	self:addChild(self.batchNode)

	self.waitedCloud:setAnchorPoint(ccp(0.5,0.5))
	self.waitedCloud:setPositionX(807 - 80)
	self.waitedCloud:setPositionY(-403/2)

	-- if _G.isLocalDevelopMode then printx(0, "waitedCloud>>>>>>",self.waitedCloud:getPositionX(),self.waitedCloud:getPositionY(),self.waitedCloud:getContentSize().width,self.waitedCloud:getContentSize().height) end

	self:buildMoveCloud()
end

function TreeTopLockedCloud:buildStatic()

	local cloud = Sprite:createWithSpriteFrameName("home_top_bg_clouds0000")
	cloud:setScaleX(2)

	return cloud
end

function TreeTopLockedCloud:buildMoveCloud( ... )
	local function buildCloud( width,height )
		local cloud = Sprite:createWithSpriteFrameName("home_top_clouds0000")
		cloud:setScaleX(width/cloud:getContentSize().width)
		cloud:setScaleY(height/cloud:getContentSize().height)
		return cloud
	end

	local data = {
		{ width=500,height=200,y=220,x={
			{fromX=-255,toX=1200,t=1230}
		}},
		{ width=328,height=172,y=235,x={
			{fromX=1177,toX=-102,t=1230}
		}},
		{ width=765,height=361,y=46, x={
			{fromX=347,toX=1200,t=650},
			{fromX=-512,toX=347,t=1230-650}
		}},
		{ width=765,height=361,y=30, x={
			{fromX=-528,toX=240.1,t=450},
			{fromX=240,toX=1180.1,t=1230-450}
		}},
		{ width=765,height=361,y=30, x={
			{fromX=111.9,toX=-512.05,t=480},
			{fromX=-512.05,toX=111.9,t=1230-480}
		}},
	}

	for i,v in ipairs(data) do
		v.y = -v.y

		local cloud = buildCloud(v.width,v.height)
		cloud:setAnchorPoint(ccp(0,1))

		local actions = CCArray:create()
		for k,v2 in pairs(v.x) do
			actions:addObject(CCPlace:create(ccp(v2.fromX,v.y)))
			actions:addObject(CCMoveTo:create(v2.t/24,ccp(v2.toX,v.y)))
		end
		cloud:runAction(CCRepeatForever:create(CCSequence:create(actions)))

		self.batchNode:addChildAt(cloud,1)
	end
end

function TreeTopLockedCloud:playAnim(...)
	assert(#{...} == 0)

	if self.isOpened then
		return 
	end
	self.isOpened = true

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()


	self.lock = Clouds:buildLock()
	self.lock:setPositionY(-200)
	self.lock:setPositionX(self:convertToNodeSpace(ccp(visibleOrigin.x + visibleSize.width/2,0)).x)
	self:addChild(self.lock)

	local fontName		= "Helvetica"
	local fontSize		= 30
	local dimensions	= CCSizeMake(480, 100)

	self.desLabel		= TextField:create("", fontName, fontSize, dimensions)
	self.desLabel:setColor(ccc3(0x7B,0x3E,0x00))
	self.desLabel:setHorizontalAlignment(kCCTextAlignmentCenter)

	self.desLabel:setAnchorPoint(ccp(0.5,1))
	self.desLabel:setPositionX(self.lock:getPositionX())
	-- self.desLabel:setPositionY(self.lock:getPositionY() - 55)
	self:addChild(self.desLabel)

	if NewVersionUtil:hasNewVersion() then
		if (_G.isPrePackage) then
			self.desLabel:setString("更新游戏版本，体验更多精彩关卡吧！")

		    self.clickLayer = LayerColor:createWithColor(ccc4(255,0,0,255), self.waitedCloud:getContentSize().width, self.waitedCloud:getContentSize().height)
		    self.clickLayer:setOpacity(0)
			-- self.clickLayer:setAnchorPoint(ccp(0.5,1))
			self.clickLayer:setPositionX(self:convertToNodeSpace(ccp(visibleOrigin.x + (visibleSize.width - self.waitedCloud:getContentSize().width)/2,0)).x)
			self.clickLayer:setPositionY(-280)

		    self.clickLayer:setTouchEnabled(true)
			self.clickLayer:ad(DisplayEvents.kTouchTap,function() 
					local scene =  Director:sharedDirector():getRunningScene()
					-- local position = self.updateVersionButton:getPosition()
					local panel = PrePackageUpdatePanel:create(position) 

					if panel then
						local function onClose()
							if not scene.updateVersionButton or scene.updateVersionButton.isDisposed then return end
							scene.updateVersionButton.wrapper:setTouchEnabled(true)
						end
						panel:addEventListener(kPanelEvents.kClose, onClose)
						scene.updateVersionButton.wrapper:setTouchEnabled(false)
						panel:popout()
					end
				end)
			self:addChild(self.clickLayer)


		elseif (UserManager.getInstance().updateInfo.maximumTips) then
			self.desLabel:setString(UserManager.getInstance().updateInfo.maximumTips)
		end
	else 
		self.desLabel:setString(Localization:getInstance():getText("unlock.cloud.new.area.lock"))
	end

	local countdownAreaId = NewAreaOpenMgr.getInstance():getNextCountdownArea()
	if countdownAreaId then 

		local now = Localhost:timeInSec()
		local endTime = NewAreaOpenMgr.getInstance():getCountdownEndTime(countdownAreaId)

		if endTime > now then
			if endTime > 0 and not _G.isPrePackage then 
				self:initCountdown(endTime)
				self.desLabel:setVisible(false)
			end
		else
			self:showNewLevelOnTimeText()
		end
	end
	self.desLabel:setPositionY(self.lock:getPositionY() - 55)

	self.lock:stop()
	-- self.waitedCloud:wait()
end

function TreeTopLockedCloud:showNewLevelOnTimeText()
	if NewVersionUtil:hasDynamicUpdate() then 
		self.desLabel:setString(localize("发现新版本！请联网重新登录游戏进行更新！"))
	elseif NewVersionUtil:hasPackageUpdate() then 
		self.desLabel:setString(localize("发现新版本！请到应用商店或在游戏内更新！"))
	elseif not NewAreaOpenMgr.getInstance():checkNextCountdownAreaVersionAvailable() then
		self.desLabel:setString(localize("发现新版本！请到应用商店更新！"))
	else
		self.desLabel:setString(localize("error.tip.731527"))	
	end
end

function TreeTopLockedCloud:initCountdown(endTime)
	if not self.areaCountdownTip then 
		local _pos = self.lock:getPosition()
		self.lock:setVisible(false)

		local pos = {x = _pos.x, y = _pos.y}
	    self.areaCountdownTip = BitmapText:create('', 'fnt/unlocknew2.fnt')
	    self.areaCountdownTip:setScale(1.1)
	    self.areaCountdownTip:setAnchorPoint(ccp(0, 0.5))
	    self:addChild(self.areaCountdownTip)
	    self.areaCountdownTip:setPosition(ccp(pos.x - 50, pos.y + 30))

	    local tip1 = BitmapText:create('倒计时', 'fnt/unlocknew.fnt')
	    tip1:setColor((ccc3(0x00, 0x66, 0x99)))
	    tip1:setAnchorPoint(ccp(1, 0.5))
	    self:addChild(tip1)
	    tip1:setPosition(ccp(pos.x - 55, pos.y + 30))
	    self.areaCountdownTip1 = tip1

	    local tip2 = BitmapText:create('', 'fnt/unlocknew.fnt')
	    tip2:setAnchorPoint(ccp(0.5, 0.5))
	    local timeDesc = NewAreaOpenMgr.getInstance():getTimeDesc(endTime)
	    tip2:setRichText("新关来袭，[#0099FF]"..timeDesc.."[/#] 统一开启", "006699")
	    self:addChild(tip2)
	    tip2:setPosition(ccp(pos.x + 10, pos.y + 80))
	    self.areaCountdownTip2 = tip2

	    self.countdownLock = Sprite:create("materials/countdownLock.png")	
	    self:addChild(self.countdownLock)
	    self.countdownLock:setPosition(ccp(pos.x , pos.y - 60))
	end 
	local function onTick()
		if self.isDisposed then return end
	    local timeStr, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
	    if isOver then 
	    	self:stopCountDown()
	    	self.countdownLock:setPositionY(self.countdownLock:getPositionY() + 60)

	    	self.desLabel:setVisible(true)
	    	self:showNewLevelOnTimeText()
	    else
	    	self.areaCountdownTip:setText(timeStr)
	    end
	end
	self.oneSecondTimer = OneSecondTimer:create()
    self.oneSecondTimer:setOneSecondCallback(function ()
        onTick()
    end)
    onTick()
    self.oneSecondTimer:start()
end

function TreeTopLockedCloud:stopCountDown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
		self.oneSecondTimer = nil
	end
	if self.areaCountdownTip then 
		self.areaCountdownTip:setVisible(false)
	end
	if self.areaCountdownTip1 then 
		self.areaCountdownTip1:setVisible(false)
	end
	if self.areaCountdownTip2 then 
		self.areaCountdownTip2:setVisible(false)
	end
end

function TreeTopLockedCloud:dispose()
	self:stopCountDown()
	BaseUI.dispose(self)
end

function TreeTopLockedCloud:create(...)
	assert(#{...} == 0)

	local newTreeTopLock = TreeTopLockedCloud.new()
	newTreeTopLock:init()
	return newTreeTopLock
end