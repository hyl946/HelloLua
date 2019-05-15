--[[
 * VideoAdPanel
 * @date    2018-09-04 15:26:03
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
local TurnCtrl = require "zoo.panel.incite.AdTurnCtrl"

local VideoAdRewardPanel = require "zoo.panel.incite.VideoAdRewardPanel"

VideoAdPanel = class(BasePanel)

local VideoAdOBKey = table.const{
	kTargetCountChange0 = 'kTargetCountChange0',
	kTargetCountChange1 = 'kTargetCountChange1',  
	kRefreshCanLotteryShow = 'kRefreshCanLotteryShow', 
}

local VideoAdPanelState = {
	kIdle = 1,
	kPlayAd = 2,
	kReward = 3,
}

function VideoAdPanel:create()
    local panel = VideoAdPanel.new()
    panel:loadRequiredResource("ui/VideoAdPanel.json")
    panel:init()
    return panel
end

function VideoAdPanel:init()
	self.m = InciteManager
	self.observers = {}

	self.ui = self:buildInterfaceGroup("VideoAd/Panel")
    BasePanel.init(self, self.ui)

    self.closeBtn = self.ui:getChildByName('close')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onCloseBtnTapped(event) 
	                               end)

	self.turnCtrl = TurnCtrl.new({
    	model = self,
    	turnHolder = self.ui:getChildByPath('up/turntable'),
    })
	self.turnCtrl.adPanel = self
    self.turnCtrl:setEnabled(false)
    self.turnCtrl.turntable:setRotation(22.5)

    self.state = VideoAdPanelState.kIdle
    self:initMid()

    self:initBottom()

    self:layout()

    self:refrash()
end

function VideoAdPanel:layout()
	local winSize = Director:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	if winSize.height > 1282 then 
	    local up = self.ui:getChildByName("up")
		local bottom = self.ui:getChildByName("bottom")

		up:setPositionY(up:getPositionY() + 35)
		bottom:setPositionY(bottom:getPositionY() - 90)

		self.closeBtn:setPositionY(self.closeBtn:getPositionY() + 35)
	end
end

function VideoAdPanel:unschedule()
	if self.scheduleId then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end
end

function VideoAdPanel:createSchedule()
	local function update1s()
		if self.prog and not self.prog.isDisposed then
			local countdown = self.m:getRewardCountdown()
			if countdown >= 0 then
				self.prog:setText(localize("watch_ad_cd_time", {time = convertSecondToHHMMSSFormat(countdown)}))
				self.btnTip = localize("watch_ad_cd", {time = convertSecondToHHMMSSFormat(countdown)})
				self.prog:setProgress(self.m:getCountdownProg())
			else
				self:unschedule()
				self:refrash()
			end
		else
			self:unschedule()
		end
	end
	if self.scheduleId then
		return
	end
	update1s()
	self.scheduleId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update1s, 1, false)
end

function VideoAdPanel:createBottomDesc( strkey, target, offset )
	local desc = BitmapText:create(localize(strkey), 'fnt/register2.fnt')
	desc:setScale(0.85)
	desc:setColor(ccc3(0, 153, 255))
	target:addChild(desc)

	local size = target:getGroupBounds().size
    desc:setPosition(ccp(size.width / 2 - 18 + (offset or 0), -40))
    return desc
end

function VideoAdPanel:initBottom()
	local bottom = self.ui:getChildByName("bottom")
	local video = bottom:getChildByName("video")
	local videoNum = getRedNumTip()
	videoNum:setPositionXY(80, 90)
	self.videoNum = videoNum
	video:addChild(videoNum)

	local function setHighLight(arrow, highlight)
		arrow:getChildByName("light"):setVisible(highlight)
		arrow:getChildByName("arrow"):setVisible(not highlight)
	end

	self.leftArrow = bottom:getChildByName("arrow1")
	self.rightArrow = bottom:getChildByName("arrow2")

	self.leftArrow.setHighLight = setHighLight
	self.rightArrow.setHighLight = setHighLight

	local turn = bottom:getChildByName("turn")
	local turnNum = getRedNumTip()
	turnNum:setNum(1)
	turnNum:setPositionXY(80, 90)
	self.turnNum = turnNum
	turn:addChild(turnNum)

	self:createBottomDesc("watch_ad_video_desc", video, -28)
	self:createBottomDesc("watch_ad_turn_desc", turn, -25)
	self:createBottomDesc("watch_ad_reward_desc", bottom:getChildByName("gift"), -5)
end

function VideoAdPanel:initMid()
	local mid = self.ui:getChildByName("mid")
	local btnui = mid:getChildByName("btn")
	self.btnLight = btnui:getChildByName("light")
	self.btn = GroupButtonBase:create(btnui)

	local numTip = getRedNumTip()
	numTip:setScale(1.3)
 	numTip:setPositionXY(150, 48)
 	numTip:setNum(1)
 	self.btn.numTip = numTip
 	btnui:addChild(numTip)

 	local ph = mid:getChildByName("descph")
 	local pos = ph:getPosition()
 	local size = ph:getGroupBounds().size
 	local desc = BitmapText:create('', 'fnt/register2.fnt')
    desc:setAnchorPoint(ccp(0.5, 1))
    desc:setPosition(ccp(pos.x + size.width/2, pos.y))
	mid:addChild(desc)
	desc:setScale(1.08)
	ph:setVisible(false)

	self.midDesc = desc

	self.btn.setEnabled = function ( _,isEnabled, notChangeColor )
		GroupButtonBase.setEnabled(self.btn, isEnabled, notChangeColor)
		self.btn.groupNode:setTouchEnabled(true, 0, true)
	end

	self.btn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event)
	                               		self:cancelHandTimer()

	                               		if self.btn.isEnabled then
	                               			self:onTapBtn()
	                               		elseif self.btnTip then
	                               			CommonTip:showTip(self.btnTip or "")
	                               		end
	                               end)

	local prog = mid:getChildByName("prog")
	local bg = prog:getChildByName("bg")
	local mask = Sprite:createWithSpriteFrameName('VideoAd/cell/mask0000')
	local pcn = ClippingNode.new(CCClippingNode:create(mask.refCocosObj))
	mask:setAnchorPoint(ccp(0, 0))
	bg:addChildAt(pcn, 1)
	mask:dispose()
	
	pcn:setPosition(ccp(10, 8))
	pcn:setInverted(false)
	pcn:setAnchorPoint(ccp(0, 0))
	pcn:ignoreAnchorPointForPosition(false)
	pcn:setAlphaThreshold(0.5)

	local progs = prog:getChildByName("mask")
	progs:removeFromParentAndCleanup(false)
	progs:setAnchorPoint(ccp(0, 0))
	pcn:addChild(progs)

	local progtext = BitmapText:create("", "fnt/video.fnt")
	bg:addChild(progtext)
	progtext:setPosition(ccp(220, 20))

	self.prog = prog
	prog.setProgress = function ( _, progress )
		progs:setPositionX((progress - 1) * 400)
	end

	prog.setText = function ( _, text )
		progtext:setText(text)
	end

	local over = BitmapText:create(localize("watch_ad_chance_over"), 'fnt/register2.fnt')
	over:setColor(ccc3(0, 153, 255))
	over:setPosition(ccp(0, -120))
    mid:addChild(over)
    self.overDesc = over
end

function VideoAdPanel:showHand()
	if self.ui.isDisposed then return end
	if self.state ~= VideoAdPanelState.kIdle then
		return
	end

	local countdown = self.m:getRewardCountdown()
	local readySdk = self.m:getReadySdk(nil, EntranceType.kPassLevel)
	local remaind = self.m:getRemaindTime()
	local canShowAd = readySdk and countdown <= 0 and remaind > 0
	if not canShowAd then
		return
	end

	local pos = ccp(300, -980)

    local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
    local layer = Layer:create()
    hand:setPosition(pos)
    layer:addChild(hand)
    self.ui:getParent():addChild(layer)

    local function onTouchCurrentLayer(eventType, x, y)
        if layer and (not layer.isDisposed) then
            layer:removeFromParentAndCleanup(true)
        end
    end
    layer:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    layer.refCocosObj:setTouchEnabled(true)

    self.handLayer = layer
end

function VideoAdPanel:onGetReward()
	if self.ui.isDisposed then return end
	--wait user click
	local size = CCDirector:sharedDirector():getVisibleSize()
	if not self.maskLayer then
		self.maskLayer = LayerColor:createWithColor(ccc3(0, 0, 0), size.width*2, size.height*2)
		self.maskLayer:setOpacity(200)
		self.maskLayer:setPosition(self.ui:convertToNodeSpace(ccp(0,0)))
		self.maskLayer:setTouchEnabled(true, 0, true)
		self.ui:addChildAt(self.maskLayer, self.ui:getChildIndex(self.ui:getChildByName('up')))
	end
end

function VideoAdPanel:onPlayFinsihed( ads, placementId, state )
	if self.ui.isDisposed then return end

	self.ads = ads

	if state == AdsFinishState.kCompleted then
		self:changeState(VideoAdPanelState.kReward)
	elseif state == AdsFinishState.kNotCompleted then
		self:refrash()
	else
		self:refrash()
	end
end

function VideoAdPanel:changeState(state)
	self.pstate = self.state
	self.state = state
	self:refrash()
end

function VideoAdPanel:onTapBtn()
	local function onPlayFinsihed(ads, placementId, state)
		self:onPlayFinsihed(ads, placementId, state)
	end

	local function onPlayError( ads, code, msg )
		self:refrash()
	end

	self.m:showAds(nil, onPlayFinsihed, onPlayError)
end

function VideoAdPanel:cancelHandTimer()
	if self.handGuide then
		cancelTimeOut(self.handGuide)
		self.handGuide = nil
	end
end

function VideoAdPanel:refrash()
	local state = self.state
	if state == VideoAdPanelState.kPlayAd then
		self.allowBackKeyTap = false
		self.btn:setEnabled(false)
	elseif state == VideoAdPanelState.kReward then
		self.allowBackKeyTap = false
		self.closeBtn:setVisible(false)
		self.turnCtrl:setEnabled(true)
		self.btn:setEnabled(false)
		self:onGetReward()
		local remaind = self.m:getRemaindTime()
		self.leftArrow:setHighLight(remaind > 0)
		self.rightArrow:setHighLight(true)
		self.turnNum:setVisible(true)

		self.btn.numTip:setVisible(false)
		self.btnLight:setVisible(false)
		if self.btnAnim then
			self.btnAnim:cancelBubbleAnimation()
			self.btnAnim = nil
		end

		-- self.videoNum:setNum(remaind - 1)
		-- self.videoNum:setVisible(remaind > 0)
		self.videoNum:setVisible(false)

		self.midDesc:setRichText(localize("watch_ad_remaind_desc", {remaind = remaind - 1}), "0099FF")
		self.midDesc:setVisible(false)
	elseif state == VideoAdPanelState.kIdle then
		self.allowBackKeyTap = true
		local countdown = self.m:getRewardCountdown()
		local readySdk = self.m:getReadySdk(nil, EntranceType.kPassLevel)
		local remaind = self.m:getRemaindTime()

		self.closeBtn:setVisible(true)

		if countdown <= 0 then
			self:unschedule()
		end

		local canShowAd = readySdk and countdown <= 0 and remaind > 0

		self.btn.numTip:setNum(remaind)
		self.btn:setEnabled(canShowAd)
		self.btn.numTip:setVisible(canShowAd)

		if canShowAd then
			if not self.btnAnim then
				self.btnAnim = self.btn:useBubbleAnimation()
			end
			--hand guide
			if not self.handGuide then
				self.handGuide = setTimeOut(function ()
					if self.state == VideoAdPanelState.kIdle then
						self:showHand()
					end
			  		self.handGuide = nil
				end, 10)
			end
		else
			self:cancelHandTimer()
			if self.btnAnim then
				self.btnAnim:cancelBubbleAnimation()
				self.btnAnim = nil
			end
		end

		self.midDesc:setRichText(localize("watch_ad_remaind_desc", {remaind = remaind}), "0099FF")
		self.midDesc:setVisible(remaind > 0 and countdown <= 0)

		self.prog:setProgress(self.m:getCountdownProg())
		self.prog:setVisible(countdown > 0 and remaind > 0)

		self.btnLight:setVisible(canShowAd)

		local delay = not readySdk and countdown <= 0 and remaind > 0
		if delay then
			self.btn:setString(localize("watch_ad_btn_waiting"))
			self.btnTip = localize("watch_ad_btn_tip_notready")
		else
			self.btn:setString(localize("watch_ad_btn_normal"))
			self.btnTip = nil
		end

		self.btn:setVisible(true)
		self.overDesc:setVisible(remaind <= 0)

		if countdown > 0 and remaind > 0 then
			self.btnTip = localize("watch_ad_cd", {time = convertSecondToHHMMSSFormat(countdown)})
			self:createSchedule()
		elseif remaind <= 0 then
			self.btn:setVisible(false)
		end

		-- self.videoNum:setNum(remaind)
		-- self.videoNum:setVisible(remaind > 0)
		self.videoNum:setVisible(false)

		self.turnNum:setVisible(false)

		self.leftArrow:setHighLight(remaind > 0)
		self.rightArrow:setHighLight(false)

		if self.maskLayer then
			self.maskLayer:removeFromParentAndCleanup(true)
			self.maskLayer = nil
		end
	end
end

function VideoAdPanel:createRewardPanel(rewardItem, done)
	local function finished()
		self:changeState(VideoAdPanelState.kIdle)
		return done and done()
	end
	if not self.isDisposed then
		VideoAdRewardPanel:create(rewardItem, nil, self.builder):popout(finished)
	else
		finished()
	end
end

function VideoAdPanel:receiveLotteryRewards( onSuccess, onFail, onCancel )
	local function __success( evt )
		local data = evt.data
		local reward = evt.data.reward or {}

		DcUtil:adsIOSReward({
					sub_category = "get_reward",
					entry = InciteManager.entranceType,
					reward_id = reward.itemId,
				})

		self.m:refrashRewardTime( data.nextRewardTime )
		self.m:refreshLastTime( data.lastRewardTime )
		self.m:addReward( reward )

		UserManager:getInstance():addReward(reward)
		UserService:getInstance():addReward(reward)
		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kIncentiveVideo, reward.itemId, reward.num, DcSourceType.kAdverTurn)

		HomeScene:sharedInstance():checkDataChange()
		Localhost:getInstance():flushCurrentUserData()

		local scene = HomeScene:sharedInstance()
		if scene and scene.coinButton then scene.coinButton:updateView() end
		if scene and scene.goldButton then scene.goldButton:updateView() end

		if onSuccess then
			onSuccess({reward})
		end
	end

	local function __onFail(evt)
		self.closeBtn:setVisible(true)
		if onFail then onFail(evt) end
	end

	local http = GetVideoSDKTurntableRewardHttp.new()
	http:addEventListener(Events.kComplete, __success)
	http:addEventListener(Events.kError, __onFail)
	http:load(self.m:getRewardConfig())
end

function VideoAdPanel:canDrawLottery()
	return self.state == VideoAdPanelState.kReward
end

function VideoAdPanel:addObserver(observer)
	table.insert(self.observers, observer)
end

function VideoAdPanel:removeObserver(observer)
	table.removeValue(self.observers, observer)
end

function VideoAdPanel:notify(obKey, ... )
	for _, observer in ipairs(self.observers) do
		if type(observer) =='table' then
			if type(observer.onNotify) == 'function' then
				observer:onNotify(obKey, ...)
			end
		end
	end
end

function VideoAdPanel:getMeta()
	return {getLotteryConfig = function ()
		return self.m:getRewardPool()
	end}
end

function VideoAdPanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

    local uisize = self:getGroupBounds().size
	local director = Director:sharedDirector()
    local origin = director:getVisibleOrigin()
    local size = director:getVisibleSize()
    local hr = size.height / uisize.height
    local wr = size.width / uisize.width
    if hr < 1 then
    	self:setScale((hr < wr) and hr or wr)
    end

    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    self:setPositionX(centerPosX)
end

function VideoAdPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
	self.m:onCloseIncitePanel()
end