require "zoo.mission.panels.MissionBubbleItem"
require "zoo.mission.panels.MissionPanelFlower"
require "zoo.mission.panels.MissionPanelBottle"
require "zoo.mission.panels.MissionAnimation"
require "zoo.mission.panels.MissionBugTip"
require "zoo.mission.panels.MissionPanelBug"
require "zoo.mission.panels.MissionTopPanel"
require "zoo.mission.panels.MissionMangaPanel"
require "zoo.mission.panels.MissionRulesPanel"



MissionPanel = class(BasePanel)

local playBugNormalTimerID = nil

function MissionPanel:create(onRewardCallback , onDoMissionCallback , onClose)
	local instance = MissionPanel.new()
	--instance:loadRequiredResource(PanelConfigFiles.mission_1)
	instance:loadRequiredResource(PanelConfigFiles.mission_2)
	--instance.missionLogic = missionLogic
	--instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance:init(onRewardCallback , onDoMissionCallback , onClose)

	--BuyObserver:sharedInstance():setMarketPanelRef(instance)

	return instance
end

function MissionPanel:init(onRewardCallback , onDoMissionCallback , onClose)

	MissionAnimation:getInstance():init()

	local uiHeight = 1055

	local ui = self:buildInterfaceGroup("missionPanel_MainPanel")
	--local ui = self:buildInterfaceGroup("MarketPanel")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)
	ui:setPosition( ccp(-150 , 0) )

	self.onCloseCallback = onClose
	self.actionQueue = {}
	self.isActionQueueRunning = false

	self.bottom = ui:getChildByName("mainpanel_bottom")

	self.closeButton = ui:getChildByName("btn_close")
	self.closeButton:setAnchorPoint(ccp(0.5,0.5))
	self.closeButton:setTouchEnabled(true, 0, false)
	self.closeButton:setButtonMode(true)
	self.closeButton:addEventListener(DisplayEvents.kTouchTap, 
									function (event) 
	                              		self:onCloseBtnTapped() 
									end)

	self.rulesButton = ui:getChildByName("btn_rules")
	self.rulesButton:setAnchorPoint(ccp(0.5,0.5))
	self.rulesButton:setTouchEnabled(true, 0, false)
	self.rulesButton:setButtonMode(true)
	self.rulesButton:addEventListener(DisplayEvents.kTouchTap, 
									function (event) 
	                              		self:showRulesPanel()
									end)

	self.title = ui:getChildByName("mainPanel_title")

	-------------------------右侧花朵-----------------------------------
	self.flower = MissionPanelFlower:create()
	self.flower:setPosition( ccp( 980 ,  -1*uiHeight - 255 ) )
	self.flower:setAnchorPoint(ccp(1, 1))
	self.ui:addChildAt(self.flower , 4)
	self.flower:playShakeAnimation()

	-------------------------四个任务泡泡-----------------------------------
	self.missionItems = {}

	local function onReward(bubblePosition)
		if onRewardCallback and type(onRewardCallback) == "function" then 
			onRewardCallback(bubblePosition)
		end
	end

	local function onDoMission(bubblePosition)
		if onDoMissionCallback and type(onDoMissionCallback) == "function" then 
			onDoMissionCallback(bubblePosition)
		end
	end

	for i= 1 , 4 do

		local item = MissionBubbleItem:create(i , onReward , onDoMission)
		
		if i == 1 then
			item:setPosition( ccp( 50 , -100 ) )
			self:addChild(item)
		elseif i == 2 then
			item:setPosition( ccp( 350 , -200 ) )
			self:addChild(item)
		elseif i == 3 then
			item:setPosition( ccp( 0 , -450 ) )
			self:addChild(item)
		elseif i == 4 then
			--item:setPosition( ccp( 0 , 0 ) )
			self.flower:addItem(item)
		end
		
		table.insert( self.missionItems , item )
		item:updateProgress(-1 , 0)
	end

	-------------------------瓢虫动画-----------------------------------
	local bug = MissionPanelBug:create()
	bug:setPositionXY(450, -1*uiHeight + 50)
	self.laddyBug = bug
	self:addChildAt(self.laddyBug , self.ui:getChildIndex(self.flower))


	-------------------------水瓶子-----------------------------------
	self.bottle = MissionPanelBottle:create()
	self.bottle:setPosition( ccp( -20 ,  -1*uiHeight + 105 ) )
	--self.bottle:setAnchorPoint(ccp(1, 1))
	self:addChild(self.bottle)
	
	--------------------------瓢虫Tip----------------------------------
	self.bugTip = MissionBugTip:create()
	self.bugTip:setPosition( ccp( 770 ,  -1*uiHeight - 60 ) )
	self:addChild(self.bugTip)
	------------------------------------------------------------------
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    local sourceUIWidth = 960
    local sourceUIHeight = 1200

	local lockrect = LayerColor:create()
	lockrect:setColor( ccc3(0,0,0) )
	lockrect:setOpacity(0)
	lockrect:changeWidthAndHeight(sourceUIWidth + 500 , sourceUIHeight + 120)
	lockrect:setPosition(ccp(-250,-1*sourceUIHeight - 120) )
	lockrect:setTouchEnabled(true , 0 , true)
	self.lockrect = lockrect
	self:addChild(lockrect)

    local fixScale = ( visibleSize.height * sourceUIWidth / sourceUIHeight ) / uiHeight
	self:setScale(  fixScale  )

	local fixX = (visibleSize.width - (visibleSize.width * fixScale)) / 2
	self:setPositionX(fixX)
	
	self:unlockSelf()
	self:playBugNormalAnimation()

	self.allowBackKeyTap = true
end

function MissionPanel:getExpireTime()

	if self.flower and self.flower.expireTime then
		return self.flower.expireTime
	end

	return 0
end

function MissionPanel:doBuildMissionItem(index , state ,  data , showAdditionalReward)
	local item = self.missionItems[index]
	if item and data then
		data.index = index
		

		if index == 4 then

			if data.expireTime and data.expireTime > 9999999999 then
				data.expireTime = math.floor( data.expireTime / 1000 )
			end

			if state == MissionBubbleItemState.kDone then
				item:updateState(state)
			else
				if data.expireTime and data.expireTime > Localhost:timeInSec() then
					item:updateState(state)
				else
					--任务已过期
					item:updateState(MissionBubbleItemState.kRewarded)
				end
			end

			if state ~= MissionBubbleItemState.kInProgress then
				self.flower:hideTimeTic()
			else
				if data.expireTime then
					self.flower:showTimeTic(data.expireTime)
				end
			end
			
		else
			item:updateState(state)
			
		end

		item:updateProgress(data.currValue , data.targetValue)
		item:updateInfo(data)
		item:setAdditionalRewardVisible(showAdditionalReward)

	end
	--self:runQueue()
end

function MissionPanel:buildMissionItem(index , state ,  data , showAdditionalReward)
	self:doBuildMissionItem(index , state ,  data , showAdditionalReward)
	--[[
	self:addQueue( {
		action="doBuildMissionItem",
		index=index,
		state=state,
		data=data,
		showAdditionalReward = showAdditionalReward,
		} )
	--]]
end

function MissionPanel:setMissionItemDoneDes(index , textType)
	local item = self.missionItems[index]
	if item then
		item:setDoneDesText(textType)
	end
end

function MissionPanel:updateProgress(positionIndex , currValue , targetValue)
	local item = self.missionItems[positionIndex]
	if item then
		item:updateProgress(currValue , targetValue)
	end
end

function MissionPanel:openMissionTopPanel(rewards , rewardCallback , cancelCallback)

	local function removePanel()
		if self.topPanel then
			self.topPanel:removeFromParentAndCleanup(true)
			self.topPanel = nil
			self:unlockSelf()
		end
	end

	local function onReward()
		removePanel()
	end

	local function onCancel()
		removePanel()
	end

	self.topPanel = MissionTopPanel:create(rewards , onReward , onCancel)
	self.topPanel:setPosition( ccp( 20 , -400 ) )
	self:addChild( self.topPanel )
	self:lockSelf(0.7)
end
	

function MissionPanel:lockSelf(alpha)
	self.lockrect:setVisible(true)
	if alpha then
		self.lockrect:setOpacity(255*alpha)
	else
		self.lockrect:setOpacity(255*0)
	end
end

function MissionPanel:unlockSelf()
	self.lockrect:setOpacity(0)
	self.lockrect:setVisible(false)
end

function MissionPanel:addQueue(data)

	table.insert( self.actionQueue , data )
	self.allowBackKeyTap = false

	if not self.isActionQueueRunning then
		self:runQueue()
	end
end

function MissionPanel:runQueue()

	--if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
	local data = self.actionQueue[1]

	if data then
		self.isActionQueueRunning = true
		table.remove( self.actionQueue , 1 )

		if data.action == "doPlayAddRewardAnimation" then
			self:doPlayAddRewardAnimation( data.index , data.propId , data.callback )
		elseif data.action == "doPlayChangeMissionAnimation" then
			self:doPlayChangeMissionAnimation( data.index , data.newData , data.callback )
		elseif data.action == "doPlayGetMissionRewardAnimation" then
			self:doPlayGetMissionRewardAnimation( data.index , data.newItemData , data.newBottleReward , data.bottleCurr , data.bottleTotal ,data.callback )
		elseif data.action == "doBuildMissionItem" then
			self:doBuildMissionItem( data.index , data.state , data.data , data.showAdditionalReward)
		elseif data.action == "doPlayBottleAnimation" then
			self:doPlayBottleAnimation( data.waterLevel , data.callback)
		elseif data.action == "doRebuildBottleRewardAnimation" then
			self:doRebuildBottleRewardAnimation( data.newBottleRewards , data.callback)
		end
	else
		self.isActionQueueRunning = false
		self.allowBackKeyTap = true
	end
end

function MissionPanel:doPlayAddRewardAnimation(index , propId , callback)
	self:lockSelf()
	self.bugTip:clearTips()

	local item = self.missionItems[index]
	item:setAdditionalRewardVisible(false)

	local function tipCallback()

		local startPoint = self.bugTip:getTipIconGlobalPosition()

		
		local endPoint = item:getRewardIconGlobalPosition(1)

		local icon = ResourceManager:sharedInstance():buildItemGroup(propId)
		icon:setAnchorPoint( ccp(0,1) )
		icon:setScale(0.7)
		local scene = Director:sharedDirector():getRunningScene()
		icon:setPosition(ccp( startPoint.x , startPoint.y ) )
		scene:addChild(icon)

		local function ontime()

			self:unlockSelf()
			icon:removeFromParentAndCleanup(true)
			item:setAdditionalRewardVisible(true)

			local eff = MissionAnimation:getInstance():createMissionChangeEff()
			eff:setPosition(ccp( endPoint.x - 0 , endPoint.y + 70 ))
			eff:setScale(0.5)
			scene:addChild(eff)

			TimerUtil.addAlarm(function() self:hideBugTip() end, 3 , 1)
			
			self:playBugNormalAnimation()

			if callback and type(callback) == "function" then
				callback()
			end
			self:runQueue()
		end

		local actArr = CCArray:create()
		actArr:addObject( CCMoveTo:create( 1 , ccp( endPoint.x , endPoint.y ) ) )
		actArr:addObject( CCCallFunc:create( ontime ) )
		icon:runAction( CCSequence:create(actArr) )

	end
	self:showBugTip( 2 , propId , tipCallback)
	self:playBugIdleAnimation()
end

function MissionPanel:playAddRewardAnimation(index , propId , callback)
	self:addQueue( {
		action="doPlayAddRewardAnimation",
		index=index,
		propId=propId,
		callback=callback,
		} )
end


function MissionPanel:doPlayChangeMissionAnimation(index , newData , callback)
	self:lockSelf()
	self.bugTip:clearTips()
	local function tipCallback()

		local startPoint = ccp( self.bugTip:getPosition().x - 160 , self.bugTip:getPosition().y + 80)

		local item = self.missionItems[index]
		local endPoint = ccp( item:getPosition().x  + 150 , item:getPosition().y - 140 )

		if index == 4 then
			endPoint = ccp (550 , -690)
		end
		

		self:loadRequiredResource(PanelConfigFiles.mission_1)
		--self:loadRequiredResource(PanelConfigFiles.mission_2)
		local eff = self:buildInterfaceGroup("missionPanel_tip_flyEff")
		local effBG = eff:getChildByName("bg")
		local effBGSize = effBG:getGroupBounds().size
		--eff:getParent():removeChild(eff)
		effBG:setPosition( ccp( effBGSize.width / -2 , effBGSize.height / 2 ) )
		--eff:setAnchorPoint( ccp(0.5,0.5) )
		eff:setPosition( ccp( startPoint.x , startPoint.y ) )
		self:addChild(eff)

		local la = endPoint.y - startPoint.y
		local lb = startPoint.x - endPoint.x
		local rotation = math.atan2 (lb, la)
		printx( 1 , "    2222222222222222222222   " , rotation , (rotation / math.pi) * 180)
		eff:setRotation( 90 - ((rotation / math.pi) * 180) )	

		local actArr = CCArray:create()
		actArr:addObject( CCMoveTo:create( 0.3 , ccp( endPoint.x , endPoint.y ) ) )
		actArr:addObject( CCCallFunc:create( function ()
				if eff and eff:getParent() then eff:removeFromParentAndCleanup(true) end
			end ) )
		eff:runAction( CCSequence:create(actArr) )

		
		local actArr2 = CCArray:create()
		actArr2:addObject( CCScaleTo:create( 0.1 , 0.5 , 1 ) )
		--actArr2:addObject( CCCallFunc:create( ontime ) )
		actArr2:addObject( CCScaleTo:create( 0.1 , 1 , 1 ) )
		actArr2:addObject( CCScaleTo:create( 0.1 , 0.5 , 1 ) )
		eff:runAction( CCSequence:create(actArr2) )


		local function onPlayExplode()
			--item:setAdditionalRewardVisible(true)
			local changeEff = MissionAnimation:getInstance():createMissionChangeEff()
			changeEff:setPosition(ccp( endPoint.x - 25 , endPoint.y + 180 ))
			changeEff:setScale(1)
			self:addChild(changeEff)
		end
		TimerUtil.addAlarm( onPlayExplode , 0.6 , 1)


		TimerUtil.addAlarm(function() 
			self:hideBugTip() end, 3.1 , 1)

		local function onChange()
			self:unlockSelf()

			if newData then
				self:buildMissionItem( index , 1 , newData , true )
			end

			self:playBugNormalAnimation()

			if callback and type(callback) == "function" then
				callback()
			end
			self:runQueue()
		end
		TimerUtil.addAlarm( onChange , 0.6 , 1)

	end
	self:showBugTip( 3 , 0 , tipCallback)
	self:playBugIdleAnimation()
end

function MissionPanel:playChangeMissionAnimation(index , newData , callback)

	self:addQueue( {
		action="doPlayChangeMissionAnimation",
		index=index,
		newData=newData,
		callback=callback,
		} )
end

function MissionPanel:doPlayBottleAnimation(waterLevel , callback)

	local function onAnimationFin()
		if callback and type(callback) == "function" then
			callback()
		end
		self:runQueue()
	end
	
	self:setBottleWaveLevel(waterLevel , false , onAnimationFin)
end

function MissionPanel:playBottleAnimation(waterLevel , callback)
	self:addQueue( {
		action="doPlayBottleAnimation",
		waterLevel=waterLevel,
		callback=callback,
		} )
end

function MissionPanel:doRebuildBottleRewardAnimation(newBottleRewards , callback)

	setTimeOut( function () 
			self:setBottleReward(newBottleRewards) 

			self:unlockSelf()

			if callback and type(callback) == "function" then
				callback()
			end
			self:runQueue()

		end , 1.5)
	
end

function MissionPanel:rebuildBottleRewardAnimation(newBottleRewards , callback)
	self:addQueue( {
		action="doRebuildBottleRewardAnimation",
		newBottleRewards=newBottleRewards,
		callback=callback,
		} )
end


function MissionPanel:doPlayGetMissionRewardAnimation(index , newItemData ,  newBottleReward , bottleCurr , bottleTotal , callback)
	self:lockSelf()
	local newRewards = nil
	local item = self.missionItems[index]

	if item.data and item.data.rewards and #item.data.rewards then
		for k, v in ipairs(item.data.rewards) do
			if item["itemIcon_" .. k] then
				local reward = { itemId=v.propId,num=v.num }
				local anim = FlyItemsAnimation:create({reward})
				local bounds = item["itemIcon_" .. k]:getGroupBounds()
				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:play()
			end
		end
	end
	--item:updateState(3)
	self:buildMissionItem( index , MissionBubbleItemState.kRewarded , newItemData )
	--item.ui:setOpacity(0)
	
	item.sprite_done_bg_1:setOpacity(0)
	item.sprite_done_bg_1:runAction( CCFadeTo:create(0.2,255) )
	item.label_done:setOpacity(0)
	item.label_done:runAction( CCFadeTo:create(0.2,255) )
	item.label_done_bg:setOpacity(0)
	item.label_done_bg:runAction( CCFadeTo:create(0.2,255) )
	--item:runAction( CCFadeTo:create(5,100) )

	local itemPos = item:getPosition()

	if index == 4 then
		itemPos = ccp (300 , -550)
	end

	local eff = MissionAnimation:getInstance():createMissionBubbleExplodeEff()
	eff:setPosition( ccp(itemPos.x + 240 , itemPos.y - 130) )
	self:addChild(eff)

	local bottlePos = self.bottle:getPosition()

	local function onWaveEffFin()
		self:unlockSelf()
		if newRewards then
			setTimeOut( function () self:setBottleReward(newRewards) end , 1.5)
			
		end
		if callback and type(callback) == "function" then
			callback()
		end
		self:runQueue()
	end

	local function onBottleEffFin()
		----[[
		local lv = self:getBottleWaveLevel()
		lv = lv + 1

		if lv > 3 then
			lv = 1
		end
		
		self:setBottleWaveLevel(lv , false , onWaveEffFin)
		--]]

		--[[
		if callback and type(callback) == "function" then
			callback()
		end
		self:runQueue()
		]]
	end

	local function onBubbleFlyFin()
		
	end

	local actArr = CCArray:create()
	actArr:addObject( CCEaseSineIn:create( CCMoveTo:create( 1 , ccp( bottlePos.x + 220 , bottlePos.y + 30 ) ) ) )
	actArr:addObject( CCCallFunc:create( onBubbleFlyFin ) )
	eff:runAction( CCSequence:create(actArr) )

	local function playBottleEff()
		local bottleEff = MissionAnimation:getInstance():createAddWaterEff(true , onBottleEffFin)
		bottleEff:setPosition(ccp( 200 , 65 ))
		self.bottle:addChild(bottleEff)

		if self:getBottleWaveLevel() == self.bottle.maxWaterLevel then
			self:stopBugNormalAnimation() 
			self.bugTip:clearTips()

			self.laddyBug:playEat(function () self:playBugNormalAnimation() end)

			
			local delayTime = {[1]=1.3,[2]=1.6,[3]=1.9,}
			local function addPropToBag(propId , animeindex , num)
				HomeScene:sharedInstance():checkDataChange()

				local reward = { itemId=propId,num=num }
				local anim = FlyItemsAnimation:create({ reward })
				anim:setWorldPosition(ccp(140 + (90 * (animeindex - 1)),380))
				-- anim:play()
				setTimeOut(function () anim:play() end , delayTime[animeindex] )

			end
			
			if self.bottle.bottleReward then

				for k,v in pairs(self.bottle.bottleReward) do
					setTimeOut(function () addPropToBag(tonumber(v.itemId) , k , tonumber(tonumber(v.num))) end, 1 )
					--addPropToBag(tonumber(v) , k)
				end

			end

			local function onHideBalls()
				
			end
			newRewards = newBottleReward
			self.bottle:hideBalls(onHideBalls)
			
		end
	end

	eff:runAction( CCSequence:createWithTwoActions( 
		CCDelayTime:create(0.5) , 
		CCCallFunc:create( playBottleEff ) 
		))

end

function MissionPanel:playGetMissionRewardAnimation(index , newItemData , newBottleReward , bottleCurr , bottleTotal , callback)
	self:addQueue( {
		action="doPlayGetMissionRewardAnimation",
		index=index,
		newItemData = newItemData,
		newBottleReward=newBottleReward,
		bottleCurr=bottleCurr,
		bottleTotal=bottleTotal,
		callback=callback,
		} )
end


function MissionPanel:playBugNormalAnimation()

	self:stopBugNormalAnimation()

	self.laddyBug:playIdle()

	local function ontimer() 
			
		self.bugTip:clearTips()
		self:showBugTip(1) 
		self.laddyBug:playTalk(function () self:hideBugTip() end)

		playBugNormalTimerID = TimerUtil.addAlarm( ontimer , math.random(60,65) , 1)
	end

	playBugNormalTimerID = TimerUtil.addAlarm( ontimer , math.random(20,30) , 1)
end

function MissionPanel:stopBugNormalAnimation()
	if playBugNormalTimerID then
		TimerUtil.removeAlarm(playBugNormalTimerID)
		playBugNormalTimerID = nil
	end
end

function MissionPanel:playBugIdleAnimation()
	if not self.isDisposed then
		self:stopBugNormalAnimation()
		self.laddyBug:playIdle()
	end
end

function MissionPanel:showBugTip(tipType , propId , callback)
	if not self.isDisposed then
		self.bugTip:showTips(tipType , propId , callback)
	end
end

function MissionPanel:hideBugTip(callback)
	self.bugTip:hideTips(callback)
end

function MissionPanel:setBottleReward(rewardIds)
	if not self.isDisposed then
		self.bottle:buildItems(rewardIds)
	end
end

function MissionPanel:setBottleWaveLevel(level , noAnime , callback)
	if not self.isDisposed then
		self.bottle:setWaveLevel(level , noAnime , callback)
	end
end

function MissionPanel:getBottleWaveLevel()
	return self.bottle:getWaveLevel()
end

function MissionPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end

local testTip = true

function MissionPanel:onCloseBtnTapped(needShowMange)
	if self:getParent() then
		PopoutManager:sharedInstance():remove(self)
	end

	if self.onCloseCallback and type(self.onCloseCallback) == "function" then
		self.onCloseCallback(needShowMange)
	end
	--self:playAddRewardAnimation(3 , 10003)
	--self:playGetMissionRewardAnimation(2 , {[1]=10002,[2]=10003,[3]=10004} )
	--self:playChangeMissionAnimation(1)

	--[[
	if testTip then
		testTip = false
		self:hideBugTip()
	else
		testTip = true
		self:showBugTip(1)
	end
	--]]
	
	--self:openMissionTopPanel()
end

function MissionPanel:showRulesPanel()

	local function onClose()
		if self.rulesPanel and not self.rulesPanel.isDisposed then
			self.rulesPanel:removeFromParentAndCleanup(true)
			self.rulesPanel = nil
		end

		self:unlockSelf()
	end

	local function onShowMange()
		self:onCloseBtnTapped(true)
	end

	local rulesPanel = MissionRulesPanel:create(onClose , onShowMange)
	rulesPanel:setPositionXY( -5 , -180 )
	self.rulesPanel = rulesPanel
	self:lockSelf(0.8)
	self:addChild( rulesPanel )
end