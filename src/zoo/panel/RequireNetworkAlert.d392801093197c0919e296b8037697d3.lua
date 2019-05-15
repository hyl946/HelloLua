require "zoo.net.PostLoginLogic"
require "zoo.panel.CommonTip"

-------------------------------------------------------------------------
--  Class include: RequireNetworkAlert
-------------------------------------------------------------------------
kRequireNetworkAlertAnimation = {kDefault=0, kSync=1, kNoAnimation=2, kSyncLoad = 3}
kRequireNetworkAlertTipType = {kDefault=0, kNoTip=1}

UserLoginChecker = class()
local checkerInstance = nil
function UserLoginChecker.getInstance()
	if not checkerInstance then
		checkerInstance = UserLoginChecker.new()
		checkerInstance:init()
	end
	return checkerInstance
end

function UserLoginChecker:init()
	self.isLogining = false
	self.successCallbacks = {}
	self.failCallbacks = {}
	self.animation = nil
	self.coverLayer = nil
	self.timeoutID = nil
	self.animationType = nil
end

function UserLoginChecker:onResult(success)
	self.isLogining = false
	local callbacks = {}
	if success then
		callbacks = self.successCallbacks or {}
	else
		callbacks = self.failCallbacks or {}
	end
	self.successCallbacks = {}
	self.failCallbacks = {}
	if _G.isLocalDevelopMode then printx(0, "userLoginCheckLogic onResult:", success, #callbacks) end
	if callbacks and #callbacks > 0 then
		for _,v in ipairs(callbacks) do
			if type(v) == "function" then v() end
		end
	end
end

function UserLoginChecker:stopTimeout()
	if _G.isLocalDevelopMode then printx(0, "userLoginCheckLogic:: stop timeout check") end
	if self.timeoutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeoutID) end
end

function UserLoginChecker:onCancel(evt)
	if evt then evt.target:rma() end
	if self.logic then self.logic:rma() end
	self:removePopout()
	self:onResult(false)
end

function UserLoginChecker:removePopout()
	self:stopTimeout()
	if self.animation then 
		self.animation:removeFromParentAndCleanup(true) 
		self.animation = nil
	end
	if self.coverLayer then
		PopoutManager:sharedInstance():remove(self.coverLayer)
		self.coverLayer = nil
	end
end

function UserLoginChecker:replaceAnimation(scene, animationType)
	if self.animation then 
		self.animation:removeFromParentAndCleanup(true)
		self.animation = nil
	end

	if animationType == kRequireNetworkAlertAnimation.kSync then 
		self.animationType = animationType
		self.animation = CountDownAnimation:createSyncAnimation() 
	end
	if animationType == kRequireNetworkAlertAnimation.kDefault then
		if not self.coverLayer then self:addCoverLayer() end
		if self.coverLayer then 
			self.coverLayer.onKeyBackClicked = function() self:removePopout() end 
		end
		if scene and not scene.isDisposed then
			self.animationType = animationType
			self.animation = CountDownAnimation:createNetworkAnimation(scene, function(evt) self:onCancel(evt) end)
		else
			self:onCancel()
		end
	end
end

function UserLoginChecker:addCoverLayer()
	if self.coverLayer then return end

	local wSize = Director:sharedDirector():getWinSize()
  	local scene = Director:sharedDirector():getRunningScene()
  	local layer = LayerColor:create()
  	layer:changeWidthAndHeight(wSize.width, wSize.height)
  	layer:setTouchEnabled(true, 0, true)
  	layer:setOpacity(0)
  	PopoutManager:sharedInstance():add(layer, false, false)
  	self.coverLayer = layer
end

function UserLoginChecker:needReplaceAnimation(newType)
	if self.animationType then
		if self.animationType == kRequireNetworkAlertAnimation.kNoAnimation then
			return newType == kRequireNetworkAlertAnimation.kDefault or newType == kRequireNetworkAlertAnimation.kSync
		end
		if self.animationType == kRequireNetworkAlertAnimation.kDefault then
			return newType == kRequireNetworkAlertAnimation.kSync
		end
		if self.animationType == kRequireNetworkAlertAnimation.kSync then
			return false
		end
	else
		if newType and newType ~= kRequireNetworkAlertAnimation.kNoAnimation then
			return true
		end
	end
	return false
end

function UserLoginChecker:doLogin(scene, onCompleteFunc, onFailFunc, animationType , tipType)
	animationType = animationType or kRequireNetworkAlertAnimation.kDefault
	if tipType == nil then tipType = kRequireNetworkAlertTipType.kDefault end

	if onCompleteFunc then table.insert(self.successCallbacks, onCompleteFunc) end
	if onFailFunc then table.insert(self.failCallbacks, onFailFunc) end

	if self.isLogining then
		if self:needReplaceAnimation(animationType) then
			self:replaceAnimation(scene, animationType)
		end
	 	return 
	end
	self.isLogining = true

	local responsed = false
	local hasException = false
	
	local function onRegisterError( evt )
		responsed = true
		if evt then evt.target:removeAllEventListeners() end
		if _G.isLocalDevelopMode then printx(0, "post register error") end
		self:removePopout()

		if animationType == kRequireNetworkAlertAnimation.kDefault and tipType == kRequireNetworkAlertTipType.kDefault then
			if -7==evt.data then
				CommonTip:showTip(Localization:getInstance():getText("error.tip.-7"), 4)
			else
				CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
			end
		end
		self:onResult(false)
	end
	local function onRegisterFinish( evt )
		responsed = true
		evt.target:removeAllEventListeners()
		self:removePopout()
		local ret = true
		if hasException then ret = false end
		self:onResult(ret)
	end 
	-- 同步出现数据异常，
	local function onLoginException( evt )
		responsed = true
		--hasException = true
	end

	local function onTimeout()
		if not responsed and animationType == kRequireNetworkAlertAnimation.kDefault then
			self:replaceAnimation(scene, kRequireNetworkAlertAnimation.kDefault)
		end
		if _G.isLocalDevelopMode then printx(0, "timeout @ userLoginCheckLogic") end
		self:stopTimeout()
	end
	if animationType == kRequireNetworkAlertAnimation.kSync then 
		self:replaceAnimation(scene, kRequireNetworkAlertAnimation.kSync)
	elseif animationType == kRequireNetworkAlertAnimation.kDefault then
		self:addCoverLayer()
	end
	self.timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout,1,false)

	if _G.isLocalDevelopMode then printx(0, "--------------begin post user login logic.") end
	local logic = PostLoginLogic.new()
	logic:addEventListener(PostLoginLogicEvents.kComplete, onRegisterFinish)
	logic:addEventListener(PostLoginLogicEvents.kError, onRegisterError)
	logic:addEventListener(PostLoginLogicEvents.kException, onLoginException)
	logic:load()

	self.logic = logic
end

local function userLoginCheckLogic(scene, onCompleteFunc, animationType, onFailFunc , tipType)
	if tipType == nil then tipType = kRequireNetworkAlertTipType.kDefault end
	UserLoginChecker.getInstance():doLogin(scene, onCompleteFunc, onFailFunc, animationType , tipType)
	return false
end

--
-- RequireNetworkAlert ---------------------------------------------------------
--
RequireNetworkAlert = class(CocosObject)
function RequireNetworkAlert:popout(onCompleteFunc, animationType)
	if animationType == nil then animationType = kRequireNetworkAlertAnimation.kDefault end
	if not onCompleteFunc then
		if _G.isLocalDevelopMode then printx(0, "[WARNING!!!] Please call RequireNetworkAlert:callFuncWithLogged function instead.") end
	end

	local scene = Director:sharedDirector():getRunningScene()
	if scene then 
		if _G.kUserLogin then return true end

		if __IOS then
			if ReachabilityUtil.getInstance():isNetworkAvailable() then 
				--network available
				return userLoginCheckLogic(scene, onCompleteFunc, animationType)
			else
				local kDebugLoading = NetworkConfig.noNetworkMode
				if kDebugLoading then return userLoginCheckLogic(scene, onCompleteFunc, animationType)
				else
					if animationType == kRequireNetworkAlertAnimation.kDefault then
						CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips")) 
					end
					return false
				end
			end
		else
			return userLoginCheckLogic(scene, onCompleteFunc, animationType)
		end
	end
	return false
end

function RequireNetworkAlert:callFuncWithLogged(onSuccessFunc, onFailFunc, animationType , tipType)
	if animationType == nil then animationType = kRequireNetworkAlertAnimation.kDefault end
	if tipType == nil then tipType = kRequireNetworkAlertTipType.kDefault end

	local scene = Director:sharedDirector():getRunningSceneLua()

	if scene then
		if _G.kUserLogin then -- already login
			if onSuccessFunc then onSuccessFunc() end
		else -- try do login
			local needDoLogin = false
			if __IOS then
				if ReachabilityUtil.getInstance():isNetworkAvailable() or NetworkConfig.noNetworkMode then 
					--network available
					needDoLogin = true
				else
					if animationType == kRequireNetworkAlertAnimation.kDefault then
						if tipType == kRequireNetworkAlertTipType.kDefault then
							CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips")) 
						end
					end
				end
			else
				needDoLogin = true
			end

			if needDoLogin then
				userLoginCheckLogic(scene, onSuccessFunc, animationType, onFailFunc , tipType)
			else
				if onFailFunc then onFailFunc() end
			end
		end
	else
		if onFailFunc then onFailFunc() end
	end
end

function RequireNetworkAlert:buildUI(message)
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	self:setPosition(ccp(vOrigin.x, vOrigin.y))

	local function onAnimationFinished() self:removeFromParentAndCleanup(true) end
	local container = CocosObject:create()
	local panel = ResourceManager:sharedInstance():buildGroup("panel_require_swape")
	local targetSize = panel:getGroupBounds().size
	local label = panel:getChildByName("label")
	label:setString(message or "")
	label:setFontSize(30)
	panel:setPosition(ccp(-targetSize.width/2, targetSize.height/2 + 100))
	container:addChild(panel)
	container:setPosition(ccp(vSize.width/2, vSize.height/2))

	local panelChildren = {}
	panel:getVisibleChildrenList(panelChildren)
	for i,child in ipairs(panelChildren) do
		local array = CCArray:create()
		array:addObject(CCFadeIn:create(0.1))
		array:addObject(CCDelayTime:create(1.5))
		array:addObject(CCFadeOut:create(0.06))
		child:setOpacity(0)
		child:runAction(CCSequence:create(array))
	end

	local seq = CCArray:create()
	seq:addObject(CCEaseElasticOut:create(CCMoveBy:create(0.1, ccp(0, -100)))) 
	seq:addObject(CCDelayTime:create(1.5))
	seq:addObject(CCCallFunc:create(onAnimationFinished))
	panel:runAction(CCSequence:create(seq))

	self:addChild(container)
end