IncitePanel = class(BasePanel)

function IncitePanel:create()
    local panel = IncitePanel.new()
    panel:loadRequiredResource(PanelConfigFiles.incite_panel)
    panel:init()
    return panel
end

function IncitePanel:init()
	self.m = InciteManager
	self.ui = self:buildInterfaceGroup("Incite/Panel")
    BasePanel.init(self, self.ui)

    self.closeBtn = self.ui:getChildByName('close')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onCloseBtnTapped(event) 
	                               end)

	self.gotRewardCloseBtn = self.ui:getChildByName('gotRewardCloseBtn')
	self.gotRewardCloseBtn:setTouchEnabled(true, 0, false)
	self.gotRewardCloseBtn:setButtonMode(true)
	self.gotRewardCloseBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onGotRewardCloseBtnTapped(event) 
	                               end)

	self.gotRewardCloseBtn:setVisible(false)

	self:initTurnTable()
	self:initBtn()

	self.turnBtn = GroupButtonBase:create(self.ui:getChildByName('turnBtn'))
	self.turnBtn.groupNode:getChildByName("_shadow"):setVisible(false)
	-- self.turnBtn.groupNode:getChildByName("light"):setVisible(false)

    local function onTapBtn()
    	self.turnBtn:setVisible(false)
       	self:startTrun()
    end

    self.turnBtn:ad(DisplayEvents.kTouchTap, onTapBtn)
    self.turnBtn:setVisible(false)
    self.turnBtn:setString("开始抽奖")
    self.turnBtn:useBubbleAnimation()

    self.getBtn = GroupButtonBase:create(self.ui:getChildByName('getReward'))

    local function onTapBtn()
    	self:gotReward()
    end

    self.getBtn:ad(DisplayEvents.kTouchTap, onTapBtn)
    self.getBtn:setVisible(false)
    self.getBtn:setString("领取")

    self.ui:getChildByName("remaindText"):setText("剩余")
    self.ui:getChildByName("remaind"):setScale(1.3)

    self.ui:getChildByName("remaindText"):setVisible(false)
    self.ui:getChildByName("remaind"):setVisible(false)

    self.descBtn = self.ui:getChildByName('descBtn')
	self.descBtn:setTouchEnabled(true, 0, false)
	self.descBtn:setButtonMode(true)
	self.descBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		local InciteDescPanel = require "zoo.panel.incite.InciteDescPanel"
	                               		InciteDescPanel:create():popout()
	                               end)

	self.ui:getChildByName("reward_light"):setVisible(false)
	self.ui:getChildByName("reward_light"):setAnchorPointCenterWhileStayOrigianlPosition()
	self.ui:getChildByName("reward_light"):setScale(3.0)
end

function IncitePanel:initTurnTable( ... )
	self.turnTable = self.ui:getChildByName("turntable")

	for i, v in ipairs(self.m:getRewardPool()) do
		if i > 8 then break end
		local sprite = self.turnTable:getChildByName("item"..tostring(i))
		local icon = sprite:getChildByName("icon")
		local iSize = icon:getContentSize()
		local iScale = icon:getScale()
		iSize = {width = iSize.width * iScale, height = iSize.height * iScale}
		icon:setVisible(false)
		local num = sprite:getChildByName("number")

		if v.itemId == 2 then
			local image = ResourceManager:sharedInstance():buildGroup("stackIcon")
			local size = image:getGroupBounds().size
			local scale = iSize.width / size.width
			if scale > iSize.height / size.height then
				scale = iSize.height / size.height
			end
			image:setScale(scale)
			image:setPositionX(icon:getPositionX() + (iSize.width - size.width * scale) / 2)
			image:setPositionY(icon:getPositionY() - (iSize.height - size.height * scale) / 2)
			sprite:addChildAt(image, sprite:getChildIndex(icon))
		else
			local image
			if ItemType:isTimeProp(v.itemId) then
				image = ResourceManager:sharedInstance():buildItemGroup(ItemType:getRealIdByTimePropId(v.itemId))
			else
				image = ResourceManager:sharedInstance():buildItemGroup(v.itemId)
			end
			local size = image:getGroupBounds().size
			local scale = iSize.width / size.width
			if scale > iSize.height / size.height then
				scale = iSize.height / size.height
			end
			image:setScale(scale)
			image:setPositionX(icon:getPositionX() + (iSize.width - size.width * scale) / 2)
			image:setPositionY(icon:getPositionY() - (iSize.height - size.height * scale) / 2)
			sprite:addChildAt(image, sprite:getChildIndex(icon))
		end
		num:setText('x'..tostring(v.num))
		num:setScale(1.2)
		num:setPositionX(icon:getPositionX() + (iSize.width - num:getContentSize().width * 1.2) / 2)

		local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(v.itemId, true)
	    if time_prop_flag then
	        sprite:addChild(time_prop_flag)
	        local size = sprite:getContentSize()
	        time_prop_flag:setPosition(ccp(size.width/2, -100))
	        time_prop_flag:setScale(0.7 / math.max(sprite:getScaleY(), sprite:getScaleX()))
	    end
	end
	-- self.turnTable:getChildByName("light"):setVisible(false)
    self.turnTable:setRotation(22.5)
end

local function SetEnabled(btn, isEnabled, notChangeColor)
	if btn.isEnabled ~= isEnabled then
		btn.isEnabled = isEnabled

		if btn.animContoller and btn.animContoller.cancelBubbleAnimation then
			if not isEnabled then
				btn.animContoller.cancelBubbleAnimation(btn)
			else
				btn.animContoller = btn:useBubbleAnimation()
			end
		end

		if btn.groupNode and btn.groupNode.refCocosObj then
			btn.groupNode:setTouchEnabled(isEnabled, 0, true)
			-- btn.groupNode:getChildByName("light"):setVisible(isEnabled)
			if not notChangeColor then 
				if isEnabled then
					btn:setColorMode(btn.colorMode, true)
				else
					local background = btn.background
					
					if background and background.refCocosObj then
						background:applyAdjustColorShader()
						background:adjustColor(0,-1, 0, 0)
					end
				end
			end
		end		
	end
end

function IncitePanel:initBtn()
	local function unscheduleUpdate()
		if self.schedule then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.schedule = nil
		end
	end

	local function update1s()
		if self.cd and not self.cd.isDisposed then
			local countdown = self.m:getRewardCountdown()
			if countdown >= 0 then
				self.cd:setString(tostring(convertSecondToHHMMSSFormat(countdown)))
			else
				unscheduleUpdate()
				self:refrash()
			end
		else
			unscheduleUpdate()
		end
	end

	self.cd = TextField:createWithUIAdjustment(self.ui:getChildByName("cdPh"), self.ui:getChildByName("cd"))
    self.ui:addChild(self.cd)

	self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))

	self.btn.setEnabled = SetEnabled

	self.btn.changeState = function ( btn, state )
		if state == "play" then
			self.btn:setEnabled(true)
			self.btn:setVisible(true)
			self.ui:getChildByName("over"):setVisible(false)
		elseif state == "used" then
			self.btn:setEnabled(false)
			self.btn:setVisible(false)
			self.ui:getChildByName("over"):setVisible(true)
		end

		if state == "delay" then
			self.btn:setEnabled(false)
			self.btn:setString("请稍等")
		else
			self.btn:setString("观看并抽奖")
		end

		if state == "countdown" then
			if self.schedule == nil then
				self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update1s, 1, false)
			end
			update1s()
			self.btn:setEnabled(false)
			self.btn:setVisible(true)
			self.ui:getChildByName("nextRewardText"):setVisible(true)
			self.ui:getChildByName("over"):setVisible(false)
			self.cd:setVisible(true)
		else
			unscheduleUpdate()
			self.ui:getChildByName("nextRewardText"):setVisible(false)
			self.cd:setVisible(false)
		end
	end

    local function onTapBtn()
    	self.btn:setEnabled(false)
       	self:onTapBtn()
    end

    self.btn:ad(DisplayEvents.kTouchTap, onTapBtn)
   	self.btn.animContoller = self.btn:useBubbleAnimation()
    self.btn:setString("观看并抽奖")

    self:refrash()
end

function IncitePanel:refrash()
	if self.ui.isDisposed then return end
	
	local remaindTime = self.m:getRemaindTime()
    if remaindTime <= 0 then
    	self.btn:changeState("used")
    else
    	local cd = self.m:getRewardCountdown()
    	if cd <= 0 then
    		self.btn:changeState("play")
    		if not self.m:getReadySdk(nil, EntranceType.kPassLevel) then
    			self.btn:changeState("delay")
    			InciteManager:tryLoadAd()
    		end
    	else
    		self.btn:changeState("countdown")
    	end
    end

    local time = remaindTime <= 0 and 0 or remaindTime

    self.ui:getChildByName("remaind"):setText(time.."次")
    -- self.turnTable:getChildByName("light"):setVisible(false)
    self.turnTable:getChildByName("bg"):setVisible(true)
end

function IncitePanel:showReward(reward)
	self.ui:setChildIndex(self.maskLayer, self.ui:getChildIndex(self.ui:getChildByName("remaindText"))+1)
	self.getBtn:setVisible(true)

	FrameLoader:loadArmature('skeleton/incite_show_reward')

	local animNode = ArmatureNode:create("incite/showReward")

	local slot = animNode:getSlot("item")

	local image = nil
	if reward.itemId == 2 then
		image = ResourceManager:sharedInstance():buildGroup("stackIcon")
	else
		if ItemType:isTimeProp(reward.itemId) then
			image = ResourceManager:sharedInstance():buildItemGroup(ItemType:getRealIdByTimePropId(reward.itemId))
		else
			image = ResourceManager:sharedInstance():buildItemGroup(reward.itemId)
		end
	end

	local sprite = Sprite:createEmpty()
	local size = image:getGroupBounds().size
	image:setPosition(ccp(size.width/2, -size.height/2))

	if reward.itemId == 2 then
		image:setPosition(ccp(size.width/2 - 40, -size.height/2 + 30))
	end

	sprite:addChild(image)

	local numLabel = BitmapText:create("x" .. reward.num, "fnt/event_default_digits.fnt")
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPositionX(size.width)
	numLabel:setPositionY(-size.height - 10)

	image:addChild(numLabel)

	slot:setDisplayImage(sprite.refCocosObj)

    animNode:setPosition(ccp(120, -350))
    self.ui:addChild(animNode)
    animNode:playByIndex(0)

    self.ui:getChildByName("reward_light"):setVisible(true)
    self.ui:getChildByName("reward_light"):runAction(CCRepeatForever:create(CCRotateBy:create(5, 360)))

    self.animNode = animNode
end

function IncitePanel:gotReward()
	local reward = self.reward
	self.reward = nil
	self.maskLayer:removeFromParentAndCleanup(true)
	self.maskLayer = nil
	self.getBtn:setVisible(false)
	self.animNode:removeFromParentAndCleanup(true)
	self.ui:getChildByName("reward_light"):setVisible(false)

	local function onAnimFinish( ... )

	end

	local anim = FlyItemsAnimation:create({reward})
    local bounds = self.ui:getGroupBounds()
    local pos = ccp(bounds:getMidX(), bounds:getMidY())
    anim:setWorldPosition(pos)
    anim:setFinishCallback(onAnimFinish)
    anim:play()

    self.turnBtn:setVisible(false)
    self.gotRewardCloseBtn:setVisible(false)
    self:refrash()

    self.m:saveState()
    self.allowBackKeyTap = true
end

function IncitePanel:turnToTarget( reward )
	local index = nil
	for i, v in ipairs(self.m:getRewardPool()) do
		if v.itemId == reward.itemId and v.num == reward.num then
			index = i
			break
		end
	end

	if index then
		local r = 45 * (9 - index)
		local maxR = r + 15
		local minR = r - 15
		local rotate = math.random(minR, maxR)

		local function onFinished()
			self:showReward(reward)
		end

		self.turnTable:stopAllActions()

		local rotated = self.turnTable:getRotation() % 360
		self.turnTable:setRotation(rotated)

		local targetR = rotate + 720 - rotated
		local time = 0.5*(targetR-rotated)/360 + 1.5

		if _G.isLocalDevelopMode then printx(0, "[IncitePanel] had turn rotate ", rotated) end
		if _G.isLocalDevelopMode then printx(0, "[IncitePanel] need turn rotate ", targetR) end

		self.turnTable:runAction(CCSequence:createWithTwoActions(CCEaseExponentialOut:create(CCRotateBy:create(time, targetR)), CCCallFunc:create(onFinished)))
	end
end

function IncitePanel:onGotRewardCloseBtnTapped()
	if self.maskLayer then self.maskLayer:removeFromParentAndCleanup(true) end
	self:refrash()
	self.turnBtn:setVisible(false)
	self.gotRewardCloseBtn:setVisible(false)
end

function IncitePanel:startTrun()
	DcUtil:adsIOSClick({
			sub_category = "rotate",
			entry = self.m.entranceType,
			adver = self.ads,
		})
	-- self.turnTable:getChildByName("light"):setVisible(true)
	self.turnTable:getChildByName("bg"):setVisible(false)
	self.turnTable:runAction(CCRepeatForever:create(CCRotateBy:create(0.5,360)))

	local function onFailed(event)
		if not self.ui.isDisposed then
			local err = event and tonumber(event.data)
			if err == 731239 or err == 731240 then
				CommonTip:showTip(localize("error.tip."..tostring(err)), "negative")
			else
				CommonTip:showTip("网络出现问题了哦~再试试吧~", "negative")
			end
			
			self.turnTable:stopAllActions()
			self.turnBtn:setVisible(true)
			self.gotRewardCloseBtn:setVisible(true)
		end
	end

	local function onSuccess(event)
		local data = event.data
		if data and data.reward and not self.ui.isDisposed then
			self.reward = data.reward

			DcUtil:adsIOSReward({
					sub_category = "get_reward",
					entry = InciteManager.entranceType,
					reward_id = self.reward.itemId,
				})

			self.m:refrashRewardTime( data.nextRewardTime )

			self.m:addReward( self.reward )

			self:turnToTarget( self.reward )

			UserManager:getInstance():addReward(self.reward)
			UserService:getInstance():addReward(self.reward)
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kIncentiveVideo, self.reward.itemId, self.reward.num, DcSourceType.kAdverTurn)

			HomeScene:sharedInstance():checkDataChange()
			Localhost:getInstance():flushCurrentUserData()

			local scene = HomeScene:sharedInstance()
			if scene and scene.coinButton then scene.coinButton:updateView() end
			if scene and scene.goldButton then scene.goldButton:updateView() end
		else
			onFailed()
		end
	end

	local http = GetVideoSDKTurntableRewardHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:load(self.m:getRewardConfig())
end

function IncitePanel:onGetReward()
	if self.ui.isDisposed then return end

	self.turnBtn:setVisible(true)

	local size = CCDirector:sharedDirector():getVisibleSize()
	self.maskLayer = LayerColor:createWithColor(ccc3(0, 0, 0), size.width*2, size.height*2)
	self.maskLayer:setOpacity(200)
	self.maskLayer:setPosition(self.ui:convertToNodeSpace(ccp(0,0)))
	self.maskLayer:setTouchEnabled(true, 0, true)
	self.ui:addChildAt(self.maskLayer, self.ui:getChildIndex(self.turnTable))
	self.allowBackKeyTap = false
end

function IncitePanel:onPlayFinsihed( ads, placementId, state )
	if self.ui.isDisposed then return end

	self.ads = ads

	if state == AdsFinishState.kCompleted then
		self:onGetReward()
	elseif state == AdsFinishState.kNotCompleted then
		self:refrash()
	else
		self:refrash()
	end

	if VideoAdUnitTest and VideoAdUnitTest.restartPanel then
		self:onCloseBtnTapped()
	end
end

function IncitePanel:onTapBtn()
	local function onPlayFinsihed(ads, placementId, state)
		self:onPlayFinsihed(ads, placementId, state)
	end

	local function onPlayError( ads, code, msg )
		self:refrash()
	end

	self.m:showAds(nil, onPlayFinsihed, onPlayError)
end

function IncitePanel:popout()
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
        
    self:setPosition(ccp(centerPosX, centerPosY))
end

function IncitePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
	self.m:onCloseIncitePanel()
end