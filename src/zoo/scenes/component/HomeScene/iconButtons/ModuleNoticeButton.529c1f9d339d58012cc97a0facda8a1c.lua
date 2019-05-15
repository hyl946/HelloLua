ModuleNoticeID = {
	LADYBUG = 1,
	STAR_AWARD = 2,
	MARK = 3,
	FRUIT_TREE = 4,
	WEEKLY_RACE = 5,
	JUMP_LEVEL = 6,
	ACCOUNT_BIND = 7,
	NEW_GIFT = 8,--新手奖励
	AREA_TASK = 9,--限时闯关
}

ModuleNoticeConfig = {
	{id = ModuleNoticeID.LADYBUG, action = "LadyBugTaskPanelPopoutAction", unLockLevel = 7, pos = ccp(3, 70), icon = "home_scene_icon/btn_cells/i_ladybug0000", tipKey = "worldScene.moduleBtn.clkTip.ladybug"},
	{id = ModuleNoticeID.STAR_AWARD, action = "StarRewardPanelPopoutAction", unLockLevel = 9, pos = ccp(3, 70), icon = "home_scene_icon/btn_cells/i_star_reward0000", tipKey = "worldScene.moduleBtn.clkTip.starAward"},
	{id = ModuleNoticeID.MARK, action = "MarkNoticePanelPopoutAction", unLockLevel = 14, pos = ccp(3, 70), icon = "home_scene_icon/btn_cells/i_mark0000", tipKey = "worldScene.moduleBtn.clkTip.mark"},
	{id = ModuleNoticeID.FRUIT_TREE, action = "FruitTreeNoticePanelPopoutAction", unLockLevel = 16, pos = ccp(3, 70), icon = "home_scene_icon/btn_cells/i_fruit_tree0000", tipKey = "worldScene.moduleBtn.clkTip.fruitTree"},
	{id = ModuleNoticeID.WEEKLY_RACE, action = "WeeklyRaceTriggerPopoutAction", unLockLevel = 31, pos = ccp(3, 70), icon = "home_scene_icon/btn_cells/i_rank_race0000", tipKey = "worldScene.moduleBtn.clkTip.weekRace"},
	{id = ModuleNoticeID.JUMP_LEVEL, action = "", unLockLevel = 40, pos = ccp(3, 70), icon = "moduleNotice/module_notice_jump_level", tipKey = "worldScene.moduleBtn.clkTip.jumpLevel"},
	--{id = ModuleNoticeID.ACCOUNT_BIND, unLockLevel = 17, pos = ccp(3, 70), icon = "moduleNotice/module_notice_bind_account", tipKey = "worldScene.moduleBtn.clkTip.accountBind"},
	{id = ModuleNoticeID.NEW_GIFT, action = "NewerGiftPanelPopoutAction", unLockLevel = 11, pos = ccp(3, 70), icon = "moduleNotice/module_notice_new_gift", tipKey = "worldScene.moduleBtn.clkTip.newGift"},
}

if PlatformConfig:isPlayDemo() then
	ModuleNoticeConfig = {}
end

function ModuleNoticeConfig.isVisible(cfg)
	if  UserManager.getInstance().user:getTopLevelId() >= cfg.unLockLevel then
		return false
	end

	if cfg.id == ModuleNoticeID.ACCOUNT_BIND then
		if not PersonalCenterManager:getData(PersonalCenterManager.SHOW_ACCBTN_OUTSIDE_REDDOT) then --已绑定账号 不显示 绑定账号的icon
			return false
		end
	end

	if cfg.id == ModuleNoticeID.LADYBUG then 
		local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
    	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	
		if UserManager:getInstance().userExtend.ladyBugStart ~= 0 or LadybugDataManager:getInstance():hadTrigger() then
			return false
		end
	end

	if cfg.id == ModuleNoticeID.NEW_GIFT then 
		if UserManager:getInstance().userExtend:getNewUserReward() == 2 then
			return false
		end
	end

	return true
end

function ModuleNoticeConfig.hasNoticeInLevel(level)
	for i=1, #ModuleNoticeConfig do
		if ModuleNoticeConfig[i].unLockLevel == level and ModuleNoticeConfig.isVisible(ModuleNoticeConfig[i]) then
			return true
		end
	end

	return false
end

ModuleNoticeButton = class(BaseUI)

local timeSlice = 0.03

function ModuleNoticeButton:create(cfg)
	local btn = ModuleNoticeButton.new()
	btn:init(cfg)
	return btn
end

function ModuleNoticeButton:init(cfg)
	self.cfg = cfg
	self.cfg.btn = self

	local ui = ResourceManager:sharedInstance():buildGroup("moduleNotice/ModuleNoticeBtn")
	local icon
	if cfg.id == ModuleNoticeID.JUMP_LEVEL or cfg.id == ModuleNoticeID.NEW_GIFT then
		icon = ResourceManager:sharedInstance():buildGroup(cfg.icon)
	else
		icon = Sprite:createWithSpriteFrameName(cfg.icon)
	end
	icon:setPosition(self.cfg.pos)
	ui:addChild(icon)
	self.icon = icon
	BaseUI.init(self, ui)

	self.ui:setTouchEnabled(true, 0, true)
	self.ui:ad(DisplayEvents.kTouchTap, function( ... )
		self:onClk()
	end)

	self.uiOringinPos = ccp( self.ui:getPosition().x , self.ui:getPosition().y )

	--self:changeState("nearby")
end

function ModuleNoticeButton:changeState(state)

	self.ui:stopAllActions()
	self:stopAllActions()

	self.ui:setPositionXY( self.uiOringinPos.x , self.uiOringinPos.y )
	--self.ui:setRotate

	if state == "normal" then
		local floatDown = CCMoveBy:create(1.1, ccp(0, -12))
	  	local floatUp = CCMoveBy:create(1.1, ccp(0, 12))
		self.ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(floatDown, floatUp)))
	elseif state == "nearby" then
		local floatDown = CCMoveBy:create(1.1, ccp(0, -12))
	  	local floatUp = CCMoveBy:create(1.1, ccp(0, 12))

	  	arr = CCArray:create()
    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, 6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )
    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, -6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )

    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, 6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )
    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, -6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )

    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, 6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )
    	arr:addObject( CCEaseSineOut:create( CCRotateTo:create(0.05, -6) ) )
    	arr:addObject( CCEaseSineIn:create( CCRotateTo:create(0.05, 0) ) )


    	arr:addObject( CCDelayTime:create(3) )

    	

		self.ui:runAction(CCRepeatForever:create(CCSequence:create(arr)))

		local floatDown = CCMoveBy:create(1.1, ccp(0, -12))
	  	local floatUp = CCMoveBy:create(1.1, ccp(0, 12))
		self.ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(floatDown, floatUp)))
	end

end


function ModuleNoticeButton:onClk()
	local tipStr = localize(self.cfg.tipKey, {num = self.cfg.unLockLevel})
	
	if self.cfg.id == ModuleNoticeID.NEW_GIFT then 
		local tipPanel = BoxRewardTipPanel:create({ rewards = MetaManager.getInstance():getNewUserRewards() })
		tipPanel:setTipString("礼包奖励如下：")
	
		local scene = Director:sharedDirector():getRunningScene()
		scene:addChild(tipPanel, SceneLayerShowKey.TOP_LAYER)
		local bounds = self.ui:getGroupBounds()
		tipPanel:scaleAccordingToResolutionConfig()
		tipPanel:setArrowPointPositionInWorldSpace( bounds.size.width/2 , bounds:getMidX() , bounds:getMidY() + 50)
	else
		require "zoo.panel.HomeSceneIconTipPanel"
		local panel = HomeSceneIconTipPanel:create( self.cfg.id , tipStr)
		panel:popout()
	end

	--setTimeOut( function () self:playDisapear() end , 2 )
	--CommonTip:showTip(tipStr, "positive")

	DcUtil:UserTrack({category = "cirrusshow", sub_category = "start", t1 = 2, t2 = self.cfg.id}, true)

	--PushBindingLogic:tryPopout( function () end , true)
end

function ModuleNoticeButton:posLevelID()
	return cfg.unLockLevel
end

function ModuleNoticeButton:removeSelf(  flyFinishallback )

	self.ui:stopAllActions()
	if self.cfg.id == ModuleNoticeID.JUMP_LEVEL or self.cfg.id == ModuleNoticeID.ACCOUNT_BIND or self.cfg.id == ModuleNoticeID.NEW_GIFT then
		self.ui:removeFromParentAndCleanup(true)

		if self.cfg.id == ModuleNoticeID.ACCOUNT_BIND then
			PushBindingLogic:tryPopout( function () end , true)
		end
	else
		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.732), CCCallFunc:create(function( ... )
			self:playDisapear( flyFinishallback )
		end)))
	end
	self.cfg.btn = nil
	DcUtil:UserTrack({category = "cirrusshow", sub_category = "end", t1 = 2, t2 = self.cfg.id}, true)
end


function ModuleNoticeButton:playDisapear( flyFinishallback )


-------------------------------------------------------

	local homeScene = HomeScene:sharedInstance()
	local canvas = HomeScene:sharedInstance()


	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(255 * 0.6)
	mask:setPosition(ccp(0, 0))
--	homeScene:addChild(mask)
	homeScene:addChild_ModuleNoticeBtn_Fly_Mask( nil , mask )

	local iconAnimTime = 12
	local scaleTo = CCScaleTo:create(iconAnimTime * timeSlice, 0.37)
	local fadeTo = CCFadeTo:create(iconAnimTime * timeSlice, 127)
	local endCallBack = CCCallFunc:create(function( ... )
		if self.ui and not self.ui.isDisposed then
			self.ui:setVisible(false)
		end
	end)

	local uiPos = homeScene:convertToNodeSpace( self.ui:convertToWorldSpace( ccp(0,0) ) )
	self.ui:getParent():removeChild( self.ui , false)
	homeScene:addChild(self.ui)
	self.ui:setPosition(uiPos)
	self.ui:runAction(CCSequence:createWithTwoActions(CCSpawn:createWithTwoActions(scaleTo, fadeTo), endCallBack))

	-- icon
	local activityIconButtons = canvas.activityIconButtons

	local hideAndShowBtn = homeScene.hideAndShowBtn

	-- position
	local bounds = self.ui:getGroupBounds()
	local wPos = ccp(bounds:getMidX(), bounds:getMidY())
	local srcPos = homeScene:convertToNodeSpace(wPos)

	local bounds = hideAndShowBtn:getGroupBounds()
	local dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))

	if self.cfg.id == ModuleNoticeID.MARK then
		if homeScene.markButton ~= nil and homeScene.markButton.ui:getParent() ~= nil then --签到按钮显示
			--glowToPos = homeScene.markButton.ui:convertToWorldSpace(ccp(40, -40))

			bounds = homeScene.markButton:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end
	elseif self.cfg.id == ModuleNoticeID.FRUIT_TREE then
		if homeScene.fruitTreeBtn ~= nil and homeScene.fruitTreeBtn.ui:getParent() ~= nil then
			--glowToPos = homeScene.fruitTreeBtn.ui:convertToWorldSpace(ccp(0, 0))

			bounds = homeScene.fruitTreeBtn:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end
	elseif self.cfg.id == ModuleNoticeID.WEEKLY_RACE then

		if homeScene.rankRaceButton ~= nil then
			bounds = homeScene.rankRaceButton:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end

	elseif self.cfg.id == ModuleNoticeID.LADYBUG then
		if homeScene.ladybugButton ~= nil then
			bounds = homeScene.ladybugButton:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end

		if homeScene.newLadybugButton ~= nil then
			bounds = homeScene.newLadybugButton:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end
	elseif self.cfg.id == ModuleNoticeID.STAR_AWARD then

		if homeScene.starButton ~= nil then
			bounds = homeScene.starRewardButton:getGroupBounds()
			dstPos = homeScene:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))
		end

	end

	--local sz = self.avatar:getGroupBounds(self.ui).size

	--print(srcPos.x, srcPos.y, dstPos.x, dstPos.y)
	--config.trueMask:setVisible(true)

	-- fly
	

	local fly = ParticleSystemQuad:create("particle/fly.plist")
--	fly:doCleanupFromParent()
	fly:setVisible(false)
	fly:setPosition(ccp(srcPos.x + 5, srcPos.y - 20))

--	fly:setAutoRemoveOnFinish(true)

--	homeScene:addChild(fly)
	homeScene:addChild_ModuleNoticeBtn_Fly_Mask( fly , nil  )
	printx( 1 , "fly pos = " , srcPos.x + 5, srcPos.y - 20)

	local p1 = ccp(100, 0)
	local p2 = ccp(180, 0.85*(dstPos.y - srcPos.y))
	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = ccp(srcPos.x +  p1.x, srcPos.y +  p1.y)
	bezierConfig.controlPoint_2 = ccp(srcPos.x +  p2.x, srcPos.y +  p2.y)
	bezierConfig.endPosition = dstPos
	local bezierAction_1 = CCEaseInOut:create(CCBezierTo:create(1, bezierConfig), 1.5)

	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(8/24))
	local function playParticle()
		fly:setVisible(true)
	end
	sequenceArr:addObject(CCCallFunc:create(playParticle))

	sequenceArr:addObject(bezierAction_1)

	local function onFlyFinished()
		--config.trueMask:setVisible(false)
		fly:removeFromParentAndCleanup()
		if mask and not mask.isDisposed then mask:removeFromParentAndCleanup() end
		if flyFinishallback then
			flyFinishallback( fly , mask  )
		end
		--self.animNode = ArmatureNode:create("commonEffAnimation/BoomEff_1")

		----[[
		local iconEffect = ArmatureNode:create("commonEffAnimation/BoomEff_1")
		printx(1 , "RRRR   iconEffect = " , iconEffect , type(iconEffect) , "Test123" , nil , "WTF!!!"  )
		--printx( 1 , "ModuleNoticeButton:playDisapear iconEffect = " , iconEffect)
		homeScene:addChild(iconEffect)
    	iconEffect:setPosition(ccp(dstPos.x - 2, dstPos.y))
    	iconEffect:playByIndex(0)
    	local function onParticlePlayFinished()
    	    iconEffect:rma()
    	end
    	iconEffect:addEventListener(ArmatureEvents.COMPLETE, onParticlePlayFinished)
    	--]]

    	local function notify(canPop)
    		Notify:dispatch("AutoPopoutEventAwakenAction", _G[self.cfg.action], {id = self.cfg.id, x = dstPos.x, y = dstPos.y, canForcePop = canPop})
    	end

    	if self.cfg.id == ModuleNoticeID.LADYBUG then
	    	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
			LadybugDataManager:getInstance():onEnterHomeScene(true, notify)
		else
    		notify(true)
    	end

    	self:playNodeAnim(iconEffect)

    	if self.ui and not self.ui.isDisposed then
			self.ui:removeFromParentAndCleanup(true)
		end
		
	end
	sequenceArr:addObject(CCCallFunc:create(onFlyFinished))
	fly:runAction(CCSequence:create(sequenceArr))

	--[[
	-- avatar
	local avatar = self.avatar
	local function onPlayFinished()
        avatar:rma()
    end
	avatar:rma()
	avatar:playByIndex(2)
    avatar:addEventListener(ArmatureEvents.COMPLETE, onPlayFinished)
    ]]
end

function ModuleNoticeButton:playNodeAnim(levelNode)
	--for i = 1, 15 do self.flyGlow:addChild(self:getADot(101, 100, 50, 40, 10, 10)) end
	for i = 1, 15 do levelNode:addChild(self:getADot(0, 0, 50, 40, 10, 10)) end
end

function ModuleNoticeButton:getADot(centerX, centerY, dotRadius, randomRadius, flyX, flyY)
	local dotIcon = Sprite:createWithSpriteFrameName("area_blocker_fg_glow0000")
	dotIcon:setScale(0.7 + math.random())
	local angle = -math.pi * (0.5 - math.random())
	if angle < 0 then
		angle = angle - math.pi / 6
	else
		angle = angle + math.pi / 6
	end
	local radius = dotRadius + math.random(randomRadius)
	local dotPosX, dotPosY = centerX + radius * math.sin(angle), centerY + radius * math.cos(angle)
	dotIcon:setPositionXY(dotPosX, dotPosY)
	local toX, toY = flyX + math.random(6), -flyY - math.random(10)
	if angle < 0 then toX = -toX end
	local moveTime = timeSlice * (20 + math.random(3))
	local move = CCMoveBy:create(moveTime, ccp(toX, toY))
	local fadeOut = CCSequence:createWithTwoActions(CCDelayTime:create(moveTime / 3), CCFadeOut:create(moveTime * 2 / 3))
	local spawn = CCSpawn:createWithTwoActions(move, fadeOut)
	local del = CCCallFunc:create(function()
		if dotIcon.isDisposed or dotIcon:getParent() == nil then return end
		dotIcon:removeFromParentAndCleanup(true)
	end)
	dotIcon:runAction(CCSequence:createWithTwoActions(spawn, del))

	return dotIcon
end

local needShowHandClickGuide = false
local clickedPlayNext = false

function ModuleNoticeButton:setPlayNext( playNext )
	clickedPlayNext = playNext
end

function ModuleNoticeButton:shouldPlayNext( ... )
	local ret = clickedPlayNext
	clickedPlayNext = false
	return ret
end

function ModuleNoticeButton:tryPopoutStartGamePanel( ... )


	--马俊松注释 不掉起来 startGamePanel
	-- if ModuleNoticeButton:shouldPlayNext() then
 --        local topLevel = UserManager.getInstance().user:getTopLevelId()
 --        local passed = UserManager.getInstance():hasPassedLevelEx(topLevel)
 --        local popall = PopoutQueue:sharedInstance():isPopAll()
 --        if not PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip() and popall then
 --            if not passed then
 --            	needShowHandClickGuide = true
 --                local startGamePanel = StartGamePanel:create(topLevel, GameLevelType.kMainLevel)
 --                startGamePanel:popout(false)
 --            end
 --        end
 --    end




end

function ModuleNoticeButton:shouldPlayHandClickGuide( ... )
	local ret = needShowHandClickGuide
	needShowHandClickGuide = false
	return ret
end