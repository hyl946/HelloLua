require "zoo.localActivity.CollectStars.CollectStarsManager"
local UIHelper = require 'zoo.panel.UIHelper'

CollectStarsYEMgr = class()

local instance = nil
function CollectStarsYEMgr.getInstance()
	if not instance then
		instance = CollectStarsYEMgr.new()
		instance:init()
	end
	return instance
end

function CollectStarsYEMgr:init()
	self.leftBuffCount = 0
	self.ingameFlag = false
	self.replayFlag = false
end

function CollectStarsYEMgr:setIngameFlag(flag)
	self.ingameFlag = flag
end

function CollectStarsYEMgr:getIngameFlag()
	return self.ingameFlag
end

function CollectStarsYEMgr:setReplayFlag(flag)
	self.replayFlag = flag
end

function CollectStarsYEMgr:getReplayFlag()
	return self.replayFlag
end

function CollectStarsYEMgr:loadRes()
	UIHelper:loadArmature('tempFunctionRes/CollectStars/skeleton/collect_star_y_e', 'collect_star_y_e', 'collect_star_y_e')
	UIHelper:loadArmature('tempFunctionRes/CollectStars/skeleton/StartGameLadybug', 'StartGameLadybug', 'StartGameLadybug')
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile('tempFunctionRes/CollectStars/yellowEnergy/yellowEnergy.plist')
end

function CollectStarsYEMgr:unloadRes()
	UIHelper:unloadArmature('tempFunctionRes/CollectStars/skeleton/collect_star_y_e', true)
	UIHelper:unloadArmature('tempFunctionRes/CollectStars/skeleton/StartGameLadybug', true)
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile('tempFunctionRes/CollectStars/yellowEnergy/yellowEnergy.plist')
end

function CollectStarsYEMgr:isBuffIngameEffective()
	if self:getIngameFlag() or self:getReplayFlag() then
		self:loadRes()
		return true
	end
	return false
end

function CollectStarsYEMgr:isBuffEffective(levelId , levelType ,isUpdateCollectStarBuff) 
	--buff是否生效 以及剩余次数
	if not isUpdateCollectStarBuff then
		isUpdateCollectStarBuff = false
	end
	self.leftBuffCount = 0
	self.levelId = levelId
	self.levelType = levelType
	local isEffective, leftBuffCount = CollectStarsManager.getInstance():isBuffEffective( levelId , levelType ) 
	if not isEffective then 
		return false 
	end
	self.leftBuffCount = leftBuffCount 
	if self.leftBuffCount <= 0 then
		return false 
	end
	self:loadRes()
	if CollectStarsManager.getInstance():getIsActivationBuff() == false and isUpdateCollectStarBuff == false then
		return false
	end
	return true
end

function CollectStarsYEMgr:getScoreByPercent(levelId, percent)
	local curLevelScoreTarget = MetaModel:sharedInstance():getLevelTargetScores(levelId)
	local star3Score = curLevelScoreTarget[3]
	if not star3Score then
		assert(false, "CollectStarsYEMgr:getScoreByPercent----no star3Score config:" .. levelId) 
	end
	return math.ceil(star3Score * percent)
end

------------------------------animation------------------------------
function CollectStarsYEMgr:playBuffAnim(mainLogic, endCallback)
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
	local scoreAddPercent = 0.3
	local oriScoreAdded = self:getScoreByPercent(mainLogic.level, scoreAddPercent)
	mainLogic.totalScore = mainLogic.totalScore + oriScoreAdded

	local action = GameBoardActionDataSet:createAs(
	GameActionTargetType.kTopPartAction,
	GameBoardTopPartActionType.kBranchProgress,
	nil,
	nil,
	GamePlayConfig_MaxAction_time)

	action.startPos = {x = vo.x + vs.width/2, y = vo.y + vs.height/2}
	action.scoreToShow = mainLogic.totalScore
	action.completeCallback = endCallback
	mainLogic:addGlobalCoreAction(action)
end

local kAnimationTime = 1/30
function CollectStarsYEMgr:doPlayBuffAnim(playUIDelegate, startPos, scoreToShow, endCallback)
	if playUIDelegate and playUIDelegate.scoreProgressBar and playUIDelegate.scoreProgressBar.ladyBugAnimation then
		local yellowEnergyAnim
		local flyContainer
		local progressBar = playUIDelegate.scoreProgressBar
		local ladyBugAnim = progressBar.ladyBugAnimation
		local bounds = ladyBugAnim.animal:getGroupBounds()
		local ladybugEndPos = ccp(bounds:getMidX(), bounds:getMidY())

		local function onProgressMove()
			if flyContainer then flyContainer:removeFromParentAndCleanup(true) end
			local scale = ladyBugAnim.ladybug:getScale()

			local branchLightAnim = UIHelper:createArmature("collect_star_y_e_ani/branch_light")
			branchLightAnim:setScale(scale)
			local pos = ladyBugAnim.ladybug:getPosition()
			pos = ladyBugAnim.ladybug:getParent():convertToWorldSpace(ccp(pos.x - 27 * scale, pos.y - 35 * scale))
			playUIDelegate:addChild(branchLightAnim)
			branchLightAnim:setPosition(ccp(pos.x, pos.y))
		    branchLightAnim:playByIndex(0, 1)
		    branchLightAnim:addEventListener(ArmatureEvents.COMPLETE, function ()
		    	if branchLightAnim then branchLightAnim:removeFromParentAndCleanup(true) end
		    	if endCallback then endCallback() end
		    end)

		    local explodeAnim = UIHelper:createArmature("collect_star_y_e_ani/explode")
			explodeAnim:setScale(scale)
			playUIDelegate:addChild(explodeAnim)
			explodeAnim:setPosition(ccp(ladybugEndPos.x, ladybugEndPos.y))
		    explodeAnim:playByIndex(0, 1)
		    explodeAnim:addEventListener(ArmatureEvents.COMPLETE, function ()
		    	if explodeAnim then explodeAnim:removeFromParentAndCleanup(true) end
		    end)

		    local bigLadybug = Sprite:createWithSpriteFrameName("yellowEnergy/csye_ladybug_res_20000")
		    local ladybugMoveTime = 1 
			bigLadybug:setScale(0.7 * scale)
			playUIDelegate:addChild(bigLadybug)
			bigLadybug:setPosition(ccp(ladybugEndPos.x, ladybugEndPos.y))
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(kAnimationTime * 4, scale * 1.21))
			arr:addObject(CCScaleTo:create(kAnimationTime * 4, scale))
			arr:addObject(CCCallFunc:create(function ()
				bigLadybug:scheduleUpdateWithPriority(function ()
					if not ladyBugAnim or not ladyBugAnim.animal or ladyBugAnim.animal.isDisposed then return end
					local _bounds = ladyBugAnim.animal:getGroupBounds()
					local _ladybugEndPos = ccp(_bounds:getMidX(), _bounds:getMidY())
					local rotation = ladyBugAnim.animal:getRotation()
					bigLadybug:setPosition(_ladybugEndPos)
					bigLadybug:setRotation(rotation)
				end, 0)
				progressBar:addScore(scoreToShow, ccp(0, 0), ladybugMoveTime)
			end))
			arr:addObject(CCDelayTime:create(ladybugMoveTime))
			arr:addObject(CCScaleTo:create(kAnimationTime * 4, scale * 1.21))
			arr:addObject(CCScaleTo:create(kAnimationTime * 4, scale * 0.7))
			arr:addObject(CCCallFunc:create(function ()				
				bigLadybug:removeFromParentAndCleanup(true)
			end))
			bigLadybug:runAction(CCSequence:create(arr))
		end

		local function onPlayFlyAnim()
			if yellowEnergyAnim then yellowEnergyAnim:removeFromParentAndCleanup(true) end

			flyContainer = CocosObject:create()
			playUIDelegate:addChild(flyContainer)
			flyContainer:setPosition(ccp(startPos.x, startPos.y))
			local flyAnim = self:buildFlyAnim(flyContainer, ladybugEndPos, onProgressMove)
			flyAnim:play()
		end

		yellowEnergyAnim = UIHelper:createArmature("collect_star_y_e_ani/yellow_energy")
		playUIDelegate:addChild(yellowEnergyAnim)
		yellowEnergyAnim:setPosition(ccp(startPos.x, startPos.y))
	    yellowEnergyAnim:playByIndex(0, 1)
	    yellowEnergyAnim:addEventListener(ArmatureEvents.COMPLETE, onPlayFlyAnim)
	else
		if endCallback then endCallback() end
	end 
end

function CollectStarsYEMgr:buildMotionStreak(fade, stroke)
	local _fade = fade or 0.3
	local _stroke = stroke or 32

	local sprite = Sprite:createWithSpriteFrameName("home_top_bar_ani/cells/tail_star0000")
	local renderTexture = CCRenderTexture:create(36, 110)
	renderTexture:beginWithClear(255, 255, 255, 0)
	sprite:setPosition(ccp(18, 55))
	sprite:visit()
	sprite:dispose()
	renderTexture:endToLua()
	if __WP8 then renderTexture:saveToCache() end
	renderTexture:retain()

	local motionStreakUseTexture = renderTexture:getSprite():getTexture():getTexture()
	motionStreakUseTexture:setAntiAliasTexParameters()

	local motionStreak = CocosObject.new(CCMotionStreak:create(_fade, 10, _stroke, ccc3(255, 255, 255), motionStreakUseTexture))
    return motionStreak
end

function CollectStarsYEMgr:buildFlyAnim(flyContainer, endPos, _finishCallback)
	local animation = {}

	local flyMotionStreak = self:buildMotionStreak(0.3, 35)
	flyContainer:addChild(flyMotionStreak)
	local flyLight = Sprite:createWithSpriteFrameName('yellowEnergy/csye_fly_light0000')
	flyContainer:addChild(flyLight)

	local flyToConfig = {
		duration = 0.5,
		sprites = {flyLight},
		dstPosition = endPos,
		direction = false,
		delayTime = 0,
		finishCallback = function ()
			if flyContainer then flyContainer:removeFromParentAndCleanup(true) end
			if _finishCallback then _finishCallback() end
		end,
	}

	function animation:play()
		flyContainer:scheduleUpdateWithPriority(function ()
			if not flyLight or flyLight.isDisposed then return end
			flyMotionStreak:setPosition(flyLight:getPosition())
		end, 0)
		BezierFlyToAnimation:create(flyToConfig) 		
	end

	return animation
end

local function getDayEndTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds) + oneDaySeconds
end

function CollectStarsYEMgr:buildStartGameLadybug( isOpen )

	local startGameLadybugAnim = UIHelper:createArmature("StartGameLadybug_sk/StartGameLadybug")
	local mainbg = startGameLadybugAnim:getSlot('mainbg')
	local mainbg2 = startGameLadybugAnim:getSlot('mainbg2')
	
	local context = self
	local isEffective, leftBuffCount = CollectStarsManager.getInstance():isBuffEffective( self.levelId , self.levelType ) 
	context.leftBuffCount = leftBuffCount 

	local posYOffset = -5 

	local bubbleBgEmptySPrite = Sprite:createEmpty()

	local bubbleBg = Sprite:createWithSpriteFrameName("yellowEnergy/csye_bg0000")
	bubbleBg:setAnchorPoint(ccp(0, 1))
	bubbleBgEmptySPrite:addChild( bubbleBg )
	bubbleBg:setPosition(ccp(-5,-5))
	local label = BitmapText:create('剩余', 'fnt/unlocknew.fnt')
	label:setColor(hex2ccc3('9A7946'))
	bubbleBg:addChild(label)
	label:setPosition(ccp(50, 80 + posYOffset ))

	local yellowEnergy = Sprite:createWithSpriteFrameName("yellowEnergy/csye_icon0000")
	yellowEnergy:setScale(0.8)
	bubbleBg:addChild(yellowEnergy)
	yellowEnergy:setPosition(ccp(98, 87 + posYOffset))

	local layerbugclose = Sprite:createWithSpriteFrameName("yellowEnergy/layerbugclose0000")
	bubbleBg:addChild(layerbugclose)
	layerbugclose:setPosition(ccp(145, 95 ))

	local leftTimeLabelPosX = 120
	local leftTimeLabelPosY = 77
	local leftTimeLabel = BitmapText:create('x'..context.leftBuffCount, 'fnt/shuaxing.fnt')
	bubbleBg:addChild(leftTimeLabel)
	leftTimeLabel:setPosition(ccp(leftTimeLabelPosX, leftTimeLabelPosY + posYOffset ))

	local countdownLabel = BitmapText:create('00:00:00', 'fnt/unlocknew.fnt')
	countdownLabel:setColor(hex2ccc3('9A7946'))
	bubbleBg:addChild(countdownLabel)
	countdownLabel:setPosition(ccp(82, 45 + posYOffset ))

	local oneSecondTimer = nil
	local todayEndTime = getDayEndTimeByTS(Localhost:timeInSec())
	local function stopCountdown()
		if oneSecondTimer then
			oneSecondTimer:stop()
		end
		oneSecondTimer = nil
	end
	local function onTick()
		if not countdownLabel or countdownLabel.isDisposed then return end
		local leftSeconds = todayEndTime - Localhost:timeInSec() 
		if leftSeconds <= 0 then
			stopCountdown()
		end
		countdownLabel:setText(convertSecondToHHMMSSFormat(leftSeconds))
	end

	oneSecondTimer = OneSecondTimer:create()
	oneSecondTimer:setOneSecondCallback(onTick)
	oneSecondTimer:start()
	onTick()


	local oldDispose = countdownLabel.dispose
    function countdownLabel:dispose(...)
    	stopCountdown()
        oldDispose(self, ...)
    end

	function startGameLadybugAnim:playDecreaseAnim(endCallback)
		if not bubbleBg or bubbleBg.isDisposed then 
			if endCallback then endCallback() end
			return 
		end
		local numLabel = BitmapText:create("-1", "fnt/shuaxing.fnt")
		bubbleBg:addChild(numLabel)
		numLabel:setPosition(ccp(leftTimeLabelPosX, leftTimeLabelPosY + 20 + posYOffset ))

		local arr = CCArray:create()
		arr:addObject(CCCallFunc:create(function ()
			local leftBuffCount = math.max(context.leftBuffCount - 1, 0)
			leftTimeLabel:setText("x".. leftBuffCount)
		end))
		arr:addObject(CCMoveBy:create(kAnimationTime*10,ccp(0,20)))
		arr:addObject(CCSpawn:createWithTwoActions(
			 CCFadeOut:create(kAnimationTime*8),
			 CCMoveBy:create(kAnimationTime*8, ccp(0,10))
		))
		arr:addObject(CCCallFunc:create(function()
			if endCallback then endCallback() end
			numLabel:removeFromParentAndCleanup(true)
		end))
		numLabel:runAction(CCSequence:create(arr))
	end


	function startGameLadybugAnim:playShowAnim()
		if startGameLadybugAnim then
			startGameLadybugAnim:playByIndex(0,1)
		end
	end

	if mainbg then
        mainbg:setDisplayImage(bubbleBgEmptySPrite.refCocosObj)
    end

    UIUtils:setTouchHandler( bubbleBg, preventContinuousClick(function ( ... )
        if startGameLadybugAnim.isDisposed then return end
        if startGameLadybugAnim then
			startGameLadybugAnim:playByIndex(1,1)
		end
		startGameLadybugAnim.nowPlayIndex = 1

		if self.delegate and self.delegate.onHideLayBuy then
			self.delegate:onHideLayBuy()
		end

    end))

    local bubbleBg2 = Sprite:createWithSpriteFrameName("yellowEnergy/csye_bg20000")
	bubbleBg2:setAnchorPoint(ccp(0, 0.9))

	local yellowEnergy2 = Sprite:createWithSpriteFrameName("yellowEnergy/csye_icon0000")

	bubbleBg2:addChild(yellowEnergy2)
	yellowEnergy2:setPosition(ccp(45, 50))
	yellowEnergy2:setScale(0.8)
	local leftTimeLabelPosX = 75
	local leftTimeLabelPosY = 40
	local leftTimeLabel2 = BitmapText:create('x'..context.leftBuffCount, 'fnt/shuaxing.fnt')
	bubbleBg2:addChild(leftTimeLabel2)
	leftTimeLabel2:setPosition(ccp(leftTimeLabelPosX, leftTimeLabelPosY + posYOffset ))
	leftTimeLabel2:setScale(1.1)

	local userLabel = TextField:create("点击使用", nil, 20)
	userLabel:setAnchorPoint(ccp(0, 0))
	userLabel:setPosition(ccp(10,-15))
	-- userLabel:setColor(ccc3(0, 0, 0))
	userLabel:setColor(ccc3(153, 102, 3))
	bubbleBg2:addChild( userLabel )
	if mainbg2 then
        mainbg2:setDisplayImage(bubbleBg2.refCocosObj)
    end

    UIUtils:setTouchHandler( bubbleBg2, preventContinuousClick(function ( ... )
        if startGameLadybugAnim.isDisposed then return end
        if startGameLadybugAnim then
			startGameLadybugAnim:playByIndex(3,1)
		end
		startGameLadybugAnim.nowPlayIndex = 3
		if self.delegate and self.delegate.onShowLayBuy then
			self.delegate:onShowLayBuy()
		end
    end))


	startGameLadybugAnim:addEventListener(ArmatureEvents.COMPLETE,function( ... )
        if startGameLadybugAnim.isDisposed then return end  
        if startGameLadybugAnim.nowPlayIndex == 1 then
        	startGameLadybugAnim:playByIndex( 2,0 )

        elseif startGameLadybugAnim.nowPlayIndex == 3 then
        	
        end
    end)


	function startGameLadybugAnim:updateNum()

		if startGameLadybugAnim and leftTimeLabel and leftTimeLabel2 then
			local isEffective, leftBuffCount = CollectStarsManager.getInstance():isBuffEffective(context.levelId , context.levelType ) 
			leftTimeLabel:setText("x".. leftBuffCount)
			leftTimeLabel2:setText("x".. leftBuffCount)
			stopCountdown()
			todayEndTime = getDayEndTimeByTS(Localhost:timeInSec())
			oneSecondTimer = OneSecondTimer:create()
			oneSecondTimer:setOneSecondCallback(onTick)
			oneSecondTimer:start()
			onTick()

		end
	end
	


	return startGameLadybugAnim
end


function CollectStarsYEMgr:setDelegate( delegate )
	self.delegate = delegate

end