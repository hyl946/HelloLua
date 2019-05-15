require "zoo.baseUI.BaseUI"
require "zoo.panelBusLogic.UnlockLevelAreaLogic"
require "zoo.panelBusLogic.IsLockedCloudCanWaitToOpenLogic"
require "zoo.panel.RequireNetworkAlert"
require "zoo.panel.areaUnlock.AreaUnlockPanelPopoutLogic"
require 'zoo.account.AccountBindingLogic'
require "zoo.panel.areaUnlock.UnlockTipPanel"
require "zoo.panel.areaUnlock.UnlockBlockerAndPlayPanel"


---------------------------------------------------
-------------- NewLockedCloud
---------------------------------------------------
NewLockedCloud = class(Sprite)
LockedCloudState = {
	STATIC = 1,
	WAIT_TO_OPEN = 2,
	OPENING = 3
}

PLANET_CLOUD_ID_1 = 40068
PLANET_CLOUD_ID_2 = 40101

local lockedCloudSizeWidth = 1010
local lockedCloudSizeHeight = 309.8

local lockedBigCloudSizeWidth = 1085
local lockedBigCloudSizeHeight = 575

local lockedCDCloudSizeWidth = 1509
local lockedCDCloudSizeHeight = 428


local function checkLockedCloudState(state, ...)
	assert(state)
	assert(#{...} == 0)
	assert(state == LockedCloudState.STATIC or
		state == LockedCloudState.WAIT_TO_OPEN or
		state == LockedCloudState.OPENING)
end

function NewLockedCloud:create(lockedCloudId, animLayer, texture, areaId, ...)
	assert(type(lockedCloudId) == "number")
	assert(animLayer)
	assert(texture)
	assert(#{...} == 0)
	local newLockedCloud = NewLockedCloud.new()
	newLockedCloud:init(lockedCloudId, animLayer, texture, areaId)
	return newLockedCloud
end

function NewLockedCloud:reinit( lockedCloudId , areaId )
	self.id = lockedCloudId
	self.areaId = areaId
	self.inClkPanelUnlock = false
	self:removeAllEventListeners()
	self.canWaitToOpen = self:ifCanWaitToOpen()
	if self.canWaitToOpen then 
		self:changeToStateWaitToOpen()
	else
		self:changeToStateStatic()
	end
end

function NewLockedCloud:init(lockedCloudId, animLayer, texture, areaId)
	assert(type(lockedCloudId) == "number")
	assert(animLayer)
	assert(texture)
	-- ----------------
	-- Init Base Class
	-- ---------------
	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite)
	self.refCocosObj:setTexture(texture)
	self.isCachedInPool = false
	-- -----
	-- Data
	-- ------
	self.id 		= lockedCloudId
	self.areaId = areaId
	-- self.selfAnimated	= Layer:create()	-- Represetn Self In self.animLayer
	-----------------
	-- Data About UI
	-- ------------
	self.staticCloudWidth = false
	self.staticCloudHeight = false
	self.staticSpriteWidth = false
	self.waitToOpenSpriteWidth = false
	self.openingSpriteWidth	= false
	self.canWaitToOpen = self:ifCanWaitToOpen()
	if self.canWaitToOpen then
		self:changeToStateWaitToOpen(true)
	else
		self:changeToStateStatic()
	end
	-------------
	--- Init Position 
	---------------
	-- Get Position Y Based On Node Position
	-- Get Start Node Id In Cur Level Area
	local curLevelAreaData = MetaModel:sharedInstance():getLevelAreaDataById(self.id)
	local curStartNodeId = tonumber(curLevelAreaData.minLevel)
	assert(curStartNodeId)
	self.startNodeId = curStartNodeId
	function self:hitTestPoint( worldPosition, useGroupTest )
		local bounds = self:getGroupBounds()
		return bounds:containsPoint(worldPosition)
 	end
end

function NewLockedCloud:addEventListener(eventName, listener, context)
	if self.lockedCloud and not self.lockedCloud.isDisposed and self.lockedCloud.touchLayer then 
		self.lockedCloud.touchLayer:addEventListener(eventName, listener, context)
	else
		Sprite.addEventListener(self, eventName, listener, context)
	end
end

function NewLockedCloud:removeEventListenerByName(eventName)
	if self.lockedCloud and not self.lockedCloud.isDisposed and self.lockedCloud.touchLayer then 
		self.lockedCloud.touchLayer:removeEventListenerByName(eventName)
	else
		Sprite.removeEventListenerByName(self, eventName, listener, context)
	end
end

function NewLockedCloud:isPlanetTypeByID(id)
	if tonumber(id) == PLANET_CLOUD_ID_1 or tonumber(id) == PLANET_CLOUD_ID_2 then
		return true
	end

	return false
end

function NewLockedCloud:setAreaBlockerShow( blockerShow )
	self.blockerShow = blockerShow
	if self.inClkPanelUnlock then
		self.blockerShow:hide() 
	end
end

function NewLockedCloud:updateState( ... )
	self.canWaitToOpen = self:ifCanWaitToOpen()
	if self.canWaitToOpen then
		self:changeState(LockedCloudState.WAIT_TO_OPEN, false)
	end
end

function NewLockedCloud:getStartNodeId(...)
	assert(#{...} == 0)
	return self.startNodeId
end

-------------------------
---- Change State
------------------------
function NewLockedCloud:changeState(newState, animFinishCallback)
	if self.isDisposed then
		--倒计时解锁新区域功能加入后 断网进游戏 倒计时解锁后联网解锁的情况下 为了直接解锁 调用了postlogin postlogin的返回会重新创建
		--解锁云 导致同一位置旧的云会被remove 然后会走到目前这段分支 所以有了以下处理 通过云id 取到新创建的云 用新云播放解锁动画
		if newState == LockedCloudState.OPENING and self.id then
			local newSameCloud = HomeScene:sharedInstance().worldScene:getLockedCloud(self.id)
			if newSameCloud then 
				newSameCloud:changeToStateOpening(animFinishCallback)
			else
				if animFinishCallback then animFinishCallback() end
			end
		else
			if animFinishCallback then animFinishCallback() end
		end
		return
	end

	assert(newState)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	checkLockedCloudState(newState)
	if newState == LockedCloudState.STATIC then
		self:changeToStateStatic()
	elseif newState == LockedCloudState.WAIT_TO_OPEN then
		self:changeToStateWaitToOpen()
	elseif newState == LockedCloudState.OPENING then
		self:changeToStateOpening(animFinishCallback)
	end
end

function NewLockedCloud:__changeCloudShow(newState)
	if self.isDisposed then return end

	if not self.lockedCloud then
    	self.lockedCloud = NewClouds:create(newState , self.id)
    	local size = self.lockedCloud:getGroupBounds().size
		self.lockedCloud:setPosition(ccp(size.width/2, -size.height/2))
		self:addChildAt(self.lockedCloud , 0)
    else
    	self.lockedCloud:changeState(newState , false , self.id)
    	--local size = self.lockedCloud:getGroupBounds().size
    	if self:isCountdownCloud() then 
    		self.lockedCloud:setPosition(ccp(lockedCDCloudSizeWidth/2, lockedCDCloudSizeHeight/-2))
    	elseif self.id == PLANET_CLOUD_ID_1 or self.id == PLANET_CLOUD_ID_2 then
    		self.lockedCloud:setPosition(ccp(lockedBigCloudSizeWidth/2, lockedBigCloudSizeHeight/-2))
    	else
    		self.lockedCloud:setPosition(ccp(lockedCloudSizeWidth/2, lockedCloudSizeHeight/-2))
    	end
    end
end

function NewLockedCloud:isCountdownCloud()
	if self.lockedCloud and self.lockedCloud.armatureType == 4 then 
		return true
	end
	return false
end

function NewLockedCloud:isCountdownOver()
	if self.lockedCloud then 
		return self.lockedCloud.isCountdownOver
	end
	return false
end

function NewLockedCloud:setPositionX(x)
	assert(type(x) == "number")
	CocosObject.setPositionX(self, x)
	-- self.selfAnimated:setPositionX(x)
end

function NewLockedCloud:setPositionY(y)
	assert(type(y) == "number")
	CocosObject.setPositionY(self, y)
	-- self.selfAnimated:setPositionY(y)
end

function NewLockedCloud:stopFloatAnim()
	if self.inFloat and self.lockedCloud ~= nil and self.lockedCloud:getParent() ~= nil then
		self.inFloat = false
		self.lockedCloud:stopFloatAnim()
		if self.blockerShow ~= nil then self.blockerShow:stopFloat() end
	end
end

function NewLockedCloud:startFloatAnim()
	if not self.inFloat and self.lockedCloud ~= nil and self.lockedCloud:getParent() ~= nil then
		self.inFloat = true
		self.lockedCloud:startFloatAnim()
		if self.blockerShow ~= nil then self.blockerShow:startFloat() end
	end
end

function NewLockedCloud:onLockedCloudTapped(event)
	DcUtil:UserTrack({category='unlock', sub_category='push_unlock'})
	if self.state == LockedCloudState.STATIC then
		self:handleStatic()
	elseif self.state == LockedCloudState.WAIT_TO_OPEN then
		self:handleWaitToOpen()
		Notify:dispatch("AutoPopoutEventStopCurAction", AreaUnlockGuidePopoutAction)
	elseif self.state == LockedCloudState.OPENING then
		-- Do Nothing
	end
end

------------------------
--------- State Static
-----------------------
function NewLockedCloud:changeToStateStatic()
	self.state = LockedCloudState.STATIC
    self:__changeCloudShow(self.state)
    local function onLockedCloudTapped(event)
		assert(event)
		self:onLockedCloudTapped(event)
	end
	self:removeEventListenerByName(DisplayEvents.kTouchTap)
	self:addEventListener(DisplayEvents.kTouchTap, onLockedCloudTapped)
end

----------------------------------------------
----- State: Wait_To_Open
-------------------------------------------
function NewLockedCloud:changeToStateWaitToOpen(isInit)
	-- -------------------
	-- Add Event Listener
	-- ----------------------
	local function onLockedCloudTapped(event)
		assert(event)
		self:onLockedCloudTapped(event)
	end

	self.state = LockedCloudState.WAIT_TO_OPEN
	self:__changeCloudShow(self.state)
	self:removeEventListenerByName(DisplayEvents.kTouchTap)
	self:addEventListener(DisplayEvents.kTouchTap, onLockedCloudTapped)

	self:checkHideLock()

	--过关直接解锁
	local canTimeUnlock = false--UserManager:getInstance():canUnlockAreaByTime(self.id)
	if (not isInit and _G.forUnlockAreaFromPassLevel) or (isInit and canTimeUnlock) then
		_G.forUnlockAreaFromPassLevel = false
		onLockedCloudTapped({})
	end
end

function NewLockedCloud:checkHideLock()
	self.inClkPanelUnlock = false
end

------------------------------------------------
--------- State: Opening
--------------------------------------------
function NewLockedCloud:changeToStateOpening(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local animWaitToFinish = 1

	if self.blockerShow ~= nil then animWaitToFinish = animWaitToFinish + 1 end
	local runningScene = HomeScene:sharedInstance()
	local showFriendHelpPanelAnim = false
	if runningScene.worldScene.worldSceneUnlockInfoPanel ~= nil and not runningScene.worldScene.worldSceneUnlockInfoPanel.isDisposed then
		showFriendHelpPanelAnim = true
		animWaitToFinish = animWaitToFinish + 1
	end

	local function lockAnimFinished()
		animWaitToFinish = animWaitToFinish - 1
		if animWaitToFinish == 0 then
			if self.blockerShow ~= nil and self.blockerShow.hasBlocker and self.areaId >= 4
			and Director:sharedDirector():getRunningSceneLua():is(HomeScene) 
			then
				-- UnlockBlockerAndPlayPanel:create(self.areaId):popout()
				Notify:dispatch("AutoPopoutEventAwakenAction", UnlockBlockerAndPlayPopoutAction, self.areaId)
			end
			if animFinishCallback then
				animFinishCallback()
			end
		end
	end
	self.state = LockedCloudState.OPENING
	self:__changeCloudShow(self.state)
	self.lockedCloud.fg:addEventListener(ArmatureEvents.COMPLETE, lockAnimFinished)
	if self.blockerShow ~= nil then 
		local flyToLevel = (self.areaId - 1) * 15 + 1
		local flyToNode = HomeScene:sharedInstance().worldScene.levelToNode[flyToLevel]
		self.blockerShow:fadeOut(flyToNode, lockAnimFinished)
	end
	if showFriendHelpPanelAnim then
		runningScene.worldScene.worldSceneUnlockInfoPanel:fadeOut(lockAnimFinished)
	end
end

function NewLockedCloud:endStateOpening(...)
	assert(#{...} == 0)
	assert(self.state == LockedCloudState.OPENING)
end

function NewLockedCloud:unlockCloud(  )
	if self.state == LockedCloudState.WAIT_TO_OPEN then
		local function onOpeningAnimFinished()
			local runningScene = HomeScene:sharedInstance()
			runningScene:checkDataChange()
			runningScene.starButton:updateView()
			runningScene.goldButton:updateView()
			runningScene.worldScene:onAreaUnlocked(self.id)
		end
		self:removeAllEventListeners()
		self:changeState(LockedCloudState.OPENING, onOpeningAnimFinished)
	end
end

function NewLockedCloud:checkTouchedLock(gPos)
	if self.touchLayer ~= nil then 
		if self.touchLayer:hitTestPoint(gPos, true) then
			return true
		end
	end

	return false
end

function NewLockedCloud:checkTouchedBlocker(gPos)
	-- 如果云是wait_to_open那么blockerShow就不响应点击
	-- i.e. 点哪都是点云
	if self.state == LockedCloudState.WAIT_TO_OPEN then
		return false
	end
	if self.blockerShow ~= nil then 
		if self.blockerShow:checkTouched(gPos) then
			return true
		end
	end

	return false
end

function NewLockedCloud:doTouchedBlocker()
	if self.blockerShow ~= nil then 
		self.blockerShow:doTouched()
	end
end
---------------------------------------------------
---------- Event handler
-----------------------------------------------
function NewLockedCloud:handleWaitToOpen()
    -- 预装包只能玩到180关
    if (_G.isPrePackage and (UserManager.getInstance():getUserScore(180) ~= nil and UserManager.getInstance().user:getTopLevelId() == 180 ) ) then
        local panel = PrePackageUpdatePanel:create()
        panel:popout()
        return
    end

    local function handleUnlock()
    	NewAreaOpenMgr.getInstance():onlineUnlockCheck(self.id, function ()
    		AreaUnlockPanelPopoutLogic:checkPopoutPanel(self)
    	end)
    end
    if self:isCountdownCloud() then  
    	if self:isCountdownOver() then 
    		handleUnlock()
    	else
    		if self.lockedCloud then 
    			self.lockedCloud:playCountdownAni()
    		end
    	end
    else
   		handleUnlock()
   	end
end

function NewLockedCloud:handleStatic()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()
	local unLockLevel = (self.areaId - 1) * 15 + 1
	print(unLockLevel, topLevelId)
	if unLockLevel - topLevelId <= 15 and topPassedLevelId ~= unLockLevel - 1 then
		-- print(self.blockerShow) debug.debug()
		UnlockTipPanel:create(self.areaId, self.blockerShow ~= nil and self.blockerShow.hasBlocker):popout()
	end
end

function NewLockedCloud:ifCanWaitToOpen()
	local logic = IsLockedCloudCanWaitToOpenLogic:create(self.id)
	return logic:start()
end

local function now()
    return os.time() + __g_utcDiffSeconds or 0
end