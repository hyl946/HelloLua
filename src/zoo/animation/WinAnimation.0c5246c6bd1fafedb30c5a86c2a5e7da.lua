-------------------------------------------------------------------------
--  Class include: WinAnimation, TimebackAnimation, AddEnergyAnimation, CommonSkeletonAnimation
-------------------------------------------------------------------------

require "hecore.display.Director"
require "hecore.display.ArmatureNode"

--
-- WinAnimation ---------------------------------------------------------
--
WinAnimation = class(CocosObject)

--defined position in flash
local animal_positions = {
	huanxiong_anime = {x=253.35, y=10.65},
	thre_anime = {x=97.4, y=16.85},
	chicken = {x=-196.5, y=-26.7},
	bear12 = {x=-268.3, y=-46.45},
	["yan_hua/anim"] = {x = -290, y = -240 },
	["spring_2019/huanxiong_anime"] = {x=253.35, y=10.65},
	["spring_2019/thre_anime"] = {x=80, y=-10},
	["spring_2019/chicken"] = {x=-155, y=-20},
	["spring_2019/bear12"] = {x=-243, y=-18},
	["qixi/win_animate_qixi"] = {x=0, y=0},
	-- 122.41494750977     71.57958984375
	["qixi_rose_bubble"] = {x=122, y=-71},
	["qixi/win_animate_qixi_fail"] = {x=-122, y=-241},

	-- ["countdown_party_2017/npc_chicken"] = {x=-195, y=-27},
	["countdown_party_2017/npc_bear_1"] = {x=150, y=-215},
	["countdown_party_2017/npc_bear_2"] = {x=125, y=-130},
	["countdown_party_2017/npc_fox"]  = {x=-220, y=-15},

	["public_service/monkey"] = {x=210, y=-60},

    ["countdown_party_2018/npc_bear_1"] = {x=150, y=-215-44},
	["countdown_party_2018/npc_bear_2"] = {x=125, y=-130-128},
    ["countdown_party_2018/npc_bear_3"] = {x=125, y=-130-128+50/0.7},
    ["countdown_party_2018/npc_bear_4"] = {x=125, y=-130-128+30/0.7},

    ["scoreBuffBottle_levelInfoNPC"] = {x = 115, y = -155},

    ["HalloweenAnim/chicken"] = {x = 115, y = -155},
    ["HalloweenAnim/moon"] = {x = 115-352/0.7, y = -155-67/0.7},

    ["HalloweenAnim/bear_halloween_win"] = {x = 115-352/0.7-420, y = -155-67/0.7},
    ["HalloweenAnim/chicken_halloween_win"] = {x = 115-352/0.7-117-159/0.7, y = -155-67/0.7+36},
    ["HalloweenAnim/hema_halloween_win"] = {x = 115-352/0.7-498+347/0.7, y = -155-67/0.7+50-18/0.7},
    ["HalloweenAnim/huanxiong_halloween_win"] = {x = 115-352/0.7+104/0.7, y = -155-67/0.7},

    ["countdown_party_2018/chiken_animation_thanksgiving_win"] =  {x=150, y=-185},
    ["countdown_party_2018/chiken_animation_thanksgiving"] = {x=125, y=-190},
    ["countdown_party_2018/huli_animation"] = {x=125-220/0.7, y=-190-10/0.7},

    ["tutorial_upzhousai"] = {x=253.35-79/0.7, y=10.65-153/0.7},
    
    
}

local function createAnimal( name, parent,isLoop)
	if not isLoop then
		isLoop = false
	end

	local position = animal_positions[name]
	local node = ArmatureNode:create(name)
	if node then 
		node.name = name
		node:setAnimationScale(2.5)
		if isLoop then
			node:playByIndex(0,0)
		else
			node:playByIndex(0)
		end
		node:setPosition(ccp(position.x, -position.y))
		node:setVisible(false)
		parent:addChild(node:wrapWithBatchNode())
	else
		assert(false, "armature node ".. name .."create failed")
	end
	return node
end

function WinAnimation:create(isActivity)
	local container = WinAnimation.new(CCNode:create())
	container:initialize(isActivity)
	return container
end

function WinAnimation:createQixi2017Anim( __type, callback)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initializeLaborDay(__type)
	return container
end


function WinAnimation:createCollectStarsAni(__type, callback)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initCollectStars(__type)
	return container
end
function WinAnimation:createCountdownPartyAni(__type, callback)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initCountdownParty(__type)
	return container
end

function WinAnimation:createPublicServiceAni(__type, callback)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initPublicService(__type)
	return container
end

function WinAnimation:createHalloweenAni(__type, callback, isNormalLevel)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initHalloweenParty( __type, isNormalLevel )
	return container
end

function WinAnimation:createRecallA2019Ani(__type, callback)
	local container = WinAnimation.new(CCNode:create())
	container.callback = callback
	container:initRecallA2019downParty(__type)
	return container
end

function WinAnimation:initialize(isActivity)
	if isActivity then
		self.thre_anime = createAnimal("spring_2019/thre_anime", self)
		self.thre_anime:setRotation(6.2)
		self.huanxiong_anime = createAnimal("spring_2019/huanxiong_anime", self)
		self.huanxiong_anime:setScale(0.96)
		self.huanxiong_anime:setAnimationScale(2)
		self.bear12 = createAnimal("spring_2019/bear12", self)
		self.bear12:setRotation(-16.7)
		self.bear12:setAnimationScale(12)
		self.chicken = createAnimal("spring_2019/chicken", self)
		self.chicken:setRotation(-7.5)
		self.chicken:setAnimationScale(8)

		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.yan_hua:setAnimationScale(1)
	else
		self.thre_anime = createAnimal("thre_anime", self)
		self.huanxiong_anime = createAnimal("huanxiong_anime", self)
		self.huanxiong_anime:setAnimationScale(0.8)
		self.bear12 = createAnimal("bear12", self)
		self.chicken = createAnimal("chicken", self)
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.yan_hua:setAnimationScale(1)
	end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end

function WinAnimation:createRose(parent)
	local position = animal_positions['qixi_rose_bubble']
	local group = ResourceManager:sharedInstance():buildGroup('qixi_2017/qixi_rose_bubble')
	group.name = 'qixi_rose_bubble'
	group:setPosition(ccp(position.x, -position.y))
	group:setVisible(false)
	parent:addChild(group)
	return group
end

function WinAnimation:initializeLaborDay(__type)
	if __type == nil  then
		__type = 1
	end
	if __type == 1 then
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.huanxiong_anime = createAnimal("qixi/win_animate_qixi", self)
		self.huanxiong_anime:setAnimationScale(0.8)

		self.rose = self:createRose(self)
		self.bear12 = createAnimal("bear12", self)
		self.chicken = createAnimal("chicken", self)
		self.yan_hua:setAnimationScale(1)
	else
		self.huanxiong_anime = createAnimal("qixi/win_animate_qixi_fail", self)
		self.huanxiong_anime:setAnimationScale(0.8)
		self.rose = self:createRose(self)
	end

	-- wrapUiForRePosition(self.rose)

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)

end

function WinAnimation:initPublicService(__type)
	if __type == nil  then __type = 1 end
	if __type == 1 then
		-- self.thre_anime = createAnimal("thre_anime", self)
		self.huanxiong_anime = createAnimal("public_service/monkey", self)
		self.bear12 = createAnimal("bear12", self)
		self.chicken = createAnimal("chicken", self)
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.yan_hua:setAnimationScale(1)
	else
		self.huanxiong_anime = createAnimal("public_service/monkey", self)
	end
	if self.huanxiong_anime then 
		self.huanxiong_anime:setAnimationScale(0.8)
		self.huanxiong_anime:setRotation(13.5)
	end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end

function WinAnimation:initCountdownParty(__type)


	if __type == nil  then __type = 1 end
	if __type == 1 then
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.huanxiong_anime = createAnimal("countdown_party_2018/chiken_animation_thanksgiving_win", self, true )

		self.huli_animation = createAnimal("countdown_party_2018/huli_animation", self, true )
        self.huli_animation:setPositionX( self.huli_animation:getPositionX() + 100 )
        self.huli_animation:setScaleX(-1)
        self.huli_animation:setRotation( -15 )
		self.huli_animation:setAnimationScale(1)
		self.yan_hua:setAnimationScale(1)
	else
		self.huanxiong_anime = createAnimal("countdown_party_2018/chiken_animation_thanksgiving", self, true)
	end

	if self.huanxiong_anime then 
		self.huanxiong_anime:setAnimationScale(0.8)
	end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end


function WinAnimation:initHalloweenParty( __type, isNormalLevel )

    if __type == 1 then
        if isNormalLevel then
            animal_positions["HalloweenAnim/chicken"] = {x = 115, y = -155}
        else
            animal_positions["HalloweenAnim/chicken"] = {x = 115+30, y = -155 - 30 }
        end

	    self.huanxiong_anime = createAnimal("HalloweenAnim/chicken", self, true)

	    if self.huanxiong_anime then 
		    self.huanxiong_anime:setAnimationScale(0.8)
	    end

        self.huanxiong_anime_moon = createAnimal("HalloweenAnim/moon", self, true)

	    if self.huanxiong_anime_moon then 
		    self.huanxiong_anime_moon:setAnimationScale(0.8)
	    end
    elseif __type == 2 then
        if isNormalLevel then
            animal_positions["HalloweenAnim/bear_halloween_win"] = {x = 115-362/0.7-420, y = -155-67/0.7-15}
            animal_positions["HalloweenAnim/chicken_halloween_win"] = {x = 115-342/0.7-117-159/0.7, y = -155-67/0.7+36-15}
            animal_positions["HalloweenAnim/hema_halloween_win"] = {x = 115-352/0.7-498+347/0.7-38/0.7, y = -155-67/0.7+50-18/0.7}
            animal_positions["HalloweenAnim/huanxiong_halloween_win"] = {x = 115-352/0.7+104/0.7-38/0.7, y = -155-67/0.7}
        else
            animal_positions["HalloweenAnim/bear_halloween_win"] = {x = 115-362/0.7-420, y = -155-67/0.7-15 - 20 }
            animal_positions["HalloweenAnim/chicken_halloween_win"] = {x = 115-342/0.7-117-159/0.7, y = -155-67/0.7+36-15 - 10 }
            animal_positions["HalloweenAnim/hema_halloween_win"] = {x = 115-352/0.7-498+347/0.7-38/0.7, y = -155-67/0.7+50-18/0.7 - 10 }
            animal_positions["HalloweenAnim/huanxiong_halloween_win"] = {x = 115-352/0.7+104/0.7-38/0.7, y = -155-67/0.7}
        end

        animal_positions["yan_hua/anim"] = {x = -290, y = -240 }

        --临时修改
        animal_positions["yan_hua/anim"] = {x = -290-370/0.7, y = -240-160/0.7 }
        self.yan_hua = createAnimal("yan_hua/anim" ,self)
		self.yan_hua:setAnimationScale(1)
--        animal_positions["yan_hua/anim"] = {x = -290, y = -240 }

        

        self.chicken_halloween = createAnimal("HalloweenAnim/chicken_halloween_win", self, true)

	    if self.chicken_halloween then 
		    self.chicken_halloween:setAnimationScale(0.8)
	    end

        self.huanxiong_halloween = createAnimal("HalloweenAnim/huanxiong_halloween_win", self, true)
	    if self.huanxiong_halloween then 
		    self.huanxiong_halloween:setAnimationScale(1.6)
	    end

        self.hema_halloween = createAnimal("HalloweenAnim/hema_halloween_win", self, true)

	    if self.hema_halloween then 
		    self.hema_halloween:setAnimationScale(1)
	    end

        self.bear_halloween = createAnimal("HalloweenAnim/bear_halloween_win", self, true)
        self.bear_halloween:setRotation(-25)
	    if self.bear_halloween then 
		    self.bear_halloween:setAnimationScale(1)
	    end
    end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end

function WinAnimation:initCollectStars(__type)
	local isLoop = true
	local huanxiongScale = 0.78
	local huanxiongAnimScale = 1

	if __type == nil then __type = 1 end
	if __type == 1 then
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
		-- self.huanxiong_anime = createAnimal("huanxiong_anime", self , isLoop)
		self.huanxiong_anime = createAnimal("scoreBuffBottle_levelInfoNPC", self, isLoop)

		self.bear12 = createAnimal("bear12", self)
		self.chicken = createAnimal("chicken", self)
		
		self.yan_hua:setAnimationScale(1)
	elseif __type == 3 then
		self.huanxiong_anime = createAnimal("scoreBuffBottle_levelInfoNPC", self, isLoop)
	else
		self.huanxiong_anime = createAnimal("countdown_party_2018/npc_bear_3", self,isLoop)
		huanxiongScale = 1
		huanxiongAnimScale = 2
	end
	
	if self.huanxiong_anime then 
		self.huanxiong_anime:setScale(huanxiongScale)
		self.huanxiong_anime:setAnimationScale(huanxiongAnimScale)
	end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end

function WinAnimation:initRecallA2019downParty(__type)


	if __type == nil  then __type = 1 end
	if __type == 1 then
		self.yan_hua = createAnimal("yan_hua/anim" ,self)
        self.yan_hua:setAnimationScale(0.7)

		self.huanxiong_anime = createAnimal("huanxiong_anime", self, true )
        self.huanxiong_anime:setAnimationScale(0.7)
	else
		self.huanxiong_animeRecall = createAnimal("tutorial_upzhousai", self, true)
        self.huanxiong_animeRecall:setScale(0.7)
        self.huanxiong_animeRecall:setAnimationScale(0.7)
	end

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(703.05, 211.84))
	self:addChild(hitArea)
end

local function fadeIn( object, delay, offsetY)
	if not object then
		return
	end

	if offsetY == nil then
		offsetY = - 200
	end

	local position = animal_positions[object.name]
	local move = CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(position.x, -position.y)))
	object:setPosition(ccp(position.x, -position.y + offsetY))
	object:setVisible(true)
	object:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), move))
end

local function fadeInEx( object, delay, offsetY)
	if not object then
		return
	end

	if offsetY == nil then
		offsetY = - 200
	end

	local position = animal_positions[object.name]
	local move = CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(position.x, -position.y)))
    object:setPositionY( -position.y + offsetY)
	object:setVisible(true)
	object:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), move))
end

local function fadeInEx2( object, delay, offsetY)
	if not object then
		return
	end

	if offsetY == nil then
		offsetY = - 200
	end

	local position = animal_positions[object.name]
	local move = CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(position.x, -position.y)))
	object:setPosition(ccp(position.x, -position.y + offsetY))
	object:setVisible(true)
	object:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), move))
end

function WinAnimation:play(delayTime)
	delayTime = delayTime or 0
	fadeIn(self.huanxiong_anime, delayTime)
	fadeIn(self.chicken, delayTime + 0.2)
	fadeIn(self.bear12, delayTime + 0.28)
	fadeIn(self.thre_anime, delayTime + 0.33)

    if self.huanxiong_anime_moon then
        fadeIn(self.huanxiong_anime_moon, delayTime, -50 )
    end

    if self.chicken_halloween then
        fadeIn(self.chicken_halloween, delayTime )
    end

    if self.huanxiong_halloween then
        fadeIn(self.huanxiong_halloween, delayTime )
    end

    if self.hema_halloween then
        fadeIn(self.hema_halloween, delayTime )
    end

    if self.bear_halloween then
        fadeIn(self.bear_halloween, delayTime )
    end

	if self.yan_hua then
		fadeIn(self.yan_hua, delayTime + 2, 0)
	end

    if self.huli_animation then
		fadeInEx(self.huli_animation, delayTime + 0.28)
	end

    if self.huanxiong_animeRecall then
		fadeInEx2(self.huanxiong_animeRecall, delayTime)
	end

    

	--五一活动用的一个动画
	if self.rose then
		-- fadeIn(self.rose, delayTime + 0.33)
		local function fly(callback)
			require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"
			local icon = require 'activity/Qixi2017/src/Icon.lua'
			if not icon then
				return callback()
			end
			local iconUi = icon:copy('Qixi2017/Config.lua', '')
			local scene = Director:sharedDirector():getRunningSceneLua()
			if not scene then return callback() end
			scene:addChild(iconUi)
			local vs = Director:sharedDirector():getVisibleSize()
			local vo = Director:sharedDirector():getVisibleOrigin()
			iconUi:setPositionXY(vo.x+vs.width-100, vo.y+vs.height*0.67)
			local rose = self.rose:getChildByName('rose')
			local anim = FlySpecialItemAnimation:create({itemId=0, num=1}, 'qixi_2017/qixi_rose_sprite_frame0000', ccp(iconUi:getPositionX()+40, iconUi:getPositionY()-40))
			anim:setScale(1.2)
			anim:setWorldPosition(self.rose:getParent():convertToWorldSpace(self.rose:getPosition()))
			anim:setFinishCallback(function() if callback() then callback() end end)
			anim:play()
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(0.4))
			arr:addObject(CCScaleTo:create(0.1, 1.2))
			arr:addObject(CCScaleTo:create(0.1, 1.0))
			arr:addObject(CCDelayTime:create(0.8))
			arr:addObject(CCCallFunc:create(function() iconUi:removeFromParentAndCleanup(true) end))
			iconUi:runAction(CCSequence:create(arr))

		end
		self.rose:setScale(0)
		self.rose:setVisible(true)
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delayTime+0.6))
		arr:addObject(CCScaleTo:create(0.3, 1, 1))
		local function finish()
			fly(function () end)
		end
		arr:addObject(CCCallFunc:create(finish))
		self.rose:runAction(CCSequence:create(arr))
	end
end


--
-- TimebackAnimation ---------------------------------------------------------
--
TimebackAnimation = class(CocosObject)

function TimebackAnimation:create()
	local container = CocosObject:create()
	
	local hole = ParticleSystemQuad:create("particle/time_back_hole.plist")
	hole:setAutoRemoveOnFinish(true)
	hole:setPosition(ccp(0,0))
	container:addChild(hole)

	local t = GamePlayConfig_Back_Animation_CD/GamePlayConfig_Action_FPS

	FrameLoader:loadArmature( "skeleton/timeback_animation" )
	local node = PropsAnimation:createArmature("back_clock_anime") --ArmatureNode:create("back_clock_anime")
	node:playByIndex(0,1,t)
	-- node:setAnimationScale(0.75)

	node:addEventListener(ArmatureEvents.COMPLETE,function( ... )
		container:removeFromParentAndCleanup(true)
	end)

	container:addChild(node)
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/timeback_animation/texture.png"))

	local function onAnimationFinish()

	end 

	local spawn = CCArray:create()
	spawn:addObject(CCFadeIn:create(0.5))
	spawn:addObject(CCEaseElasticOut:create(CCMoveTo:create(0.5, ccp(0, 120))))

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.3))
	array:addObject(CCSpawn:create(spawn)) 
	array:addObject(CCDelayTime:create(1.5))
	array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.25), CCScaleTo:create(0.25, 1.5)))
	array:addObject(CCDelayTime:create(0.3))
	array:addObject(CCCallFunc:create(onAnimationFinish))

	local fntFile = "fnt/backward.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/backward.fnt" end
	local label = BitmapText:create(Localization:getInstance():getText("button.timeback"), fntFile)
	label:setOpacity(0)
	label:runAction(CCSequence:create(array))
	container:addChild(label)

	return container
end


--
-- AddEnergyAnimation ---------------------------------------------------------
--
AddEnergyAnimation = class(CocosObject)
function AddEnergyAnimation:create()
	local container = CocosObject:create()
	local node = ArmatureNode:create("huanxiong_sad_loop_anime")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	container:addChild(node)
	return container
end

WeeklyRaceAddEnergyAnimation = class(CocosObject)
function WeeklyRaceAddEnergyAnimation:create()
	local container = CocosObject:create()
	local node = ArmatureNode:create("tutorial_upzhousai")
	node:playByIndex(0)
	node:setScale(0.8)
	container:addChild(node)
	container:setScaleX(-1)
	node:setAnchorPoint(ccp(0.5, 0.5))
	return container
end

AddFiveStepAnimation = class(CocosObject)
function AddFiveStepAnimation:create()
	local container = CocosObject:create()
	local node = ArmatureNode:create("huanxiong_point_to_anime_new")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	container.animNode = node
	container:addChild(node)
	return container
end
--
-- CommonSkeletonAnimation ---------------------------------------------------------
--
CommonSkeletonAnimation = class()
function CommonSkeletonAnimation:createTutorialUp()
	local node = ArmatureNode:create("tutorial_up")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	return node
end
function CommonSkeletonAnimation:createTutorialDown()
	local node = ArmatureNode:create("tutorial_down")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	return node
end
function CommonSkeletonAnimation:createTutorialNormal()
	local node = ArmatureNode:create("tutorial_normal")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	return node
end
function CommonSkeletonAnimation:createTutorialMoveIn2()
	local node = ArmatureNode:create("movein_tutorial_2")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	return node
end
function CommonSkeletonAnimation:createTutorialMoveIn()
	local node = ArmatureNode:create("movein_tutorial")
	node:playByIndex(0)
	node:setAnimationScale(1.25)
	return node
end
function CommonSkeletonAnimation:createFailAnimation()
	local container = CocosObject:create()
	local character = ArmatureNode:create("fail_animation")
	character:playByIndex(0)
	character:setAnimationScale(1.25)
	container:addChild(character:wrapWithBatchNode())

	local function createBird()
		local bird = ArmatureNode:create("bird_fly_animation")
		bird:playByIndex(0)
		bird:setAnimationScale(1.25)
		container:addChild(bird:wrapWithBatchNode())
	end
	createBird()

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(createBird))
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(createBird))
	container:runAction(CCSequence:create(array))
	return container
end

function CommonSkeletonAnimation:createNewFailAnimation()
	local container = CocosObject:create()
	local character = ArmatureNode:create("fail_new/fail")
	character:playByIndex(0)
	character:setAnimationScale(1.25)
	container:addChild(character:wrapWithBatchNode())
	return container
end

kTutorialPropAnimation = {}
kTutorialPropAnimation["10001"] = "output/reflash_anime"
kTutorialPropAnimation["10015"] = "output/reflash_anime"

kTutorialPropAnimation["10005"] = "output/magic_anime"
kTutorialPropAnimation["10019"] = "output/magic_anime"

kTutorialPropAnimation["10010"] = "output/hammer_anime"
kTutorialPropAnimation["10026"] = "output/hammer_anime"

kTutorialPropAnimation["10002"] = "output/back_anime"
kTutorialPropAnimation["10003"] = "output/change_anime"
kTutorialPropAnimation["10004"] = "output/add5_anime"
kTutorialPropAnimation["10018"] = "output/add3_anime"
kTutorialPropAnimation["10007"] = "output/line_boomb_anime"
kTutorialPropAnimation["10052"] = "output/octopus_anime"
kTutorialPropAnimation["10053"] = "output/octopus_anime"
kTutorialPropAnimation["10055"] = "output/random_bird_anime"
kTutorialPropAnimation["10056"] = "output/broom_anime"
kTutorialPropAnimation["10040"] = "output/bon_anime"
kTutorialPropAnimation["16"] = "output/add15_anime"
kTutorialPropAnimation["10081"] = "output/line_boomb_anime2"
kTutorialPropAnimation["10082"] = "output/line_boomb_anime3"
kTutorialPropAnimation["10078"] = {"output/boomb_add5_anime","output/boomb_add5_anime2"}
kTutorialPropAnimation["10089"] = "output/skeleton_prop_gudie_animation_10089"
kTutorialPropAnimation["10087"] = "output/skeleton_prop_gudie_animation_10087"
kTutorialPropAnimation["10099"] = "output/skeleton_prop_gudie_animation_10099"
kTutorialPropAnimation["10105"] = "output/skeleton_prop_gudie_animation_10105"
kTutorialPropAnimation["10109"] = "output/skeleton_prop_gudie_animation_10109"

if __IOS_FB then
	kTutorialPropAnimation["10004"] = "output/add5_anime_zh_TW"
	kTutorialPropAnimation["10018"] = "output/add3_anime_zh_TW"
end

function CommonSkeletonAnimation:creatTutorialAnimation(propId, levelType) 
	local propName = kTutorialPropAnimation[tostring(propId)]

    --add by jermy.niu
    if propId == 10078 then
        if levelType == GameLevelType.kMoleWeekly then
            propName = propName[2]
        else
            propName = propName[1]
        end
    end

	if propName then
		local node = ArmatureNode:create(propName)
		node:setAnimationScale(1.25)
		node:playByIndex(0)
		node.playAnimation = function( self )
			node:playByIndex(0, 0)
		end
		node.stopAnimation = function ( self )
			node:gotoAndStopByIndex(0, 0)
		end
		node:update(0.001)
		node:stop()
		return node
	else return nil end
end

kPropsTutorialPropAnimation = {}
kPropsTutorialPropAnimation["10010"] = "anim_hammer"
kPropsTutorialPropAnimation["10005"] = "anim_brush"
kPropsTutorialPropAnimation["10003"] = "anim_swap"
kPropsTutorialPropAnimation["10056"] = "anim_broom"
kPropsTutorialPropAnimation["10105"] = "anim_row_effect"
kPropsTutorialPropAnimation["10109"] = "anim_colum_effect"
function CommonSkeletonAnimation:createPropsTutorialAnimation( propId )
	local propName = kPropsTutorialPropAnimation[tostring(propId)]
	if propName then
		local node = ArmatureNode:create(propName)
		node:setAnimationScale(1)
		node:playByIndex(0)
		node.playAnimation = function( self )
			node:playByIndex(0)
			node.isPlay = true
		end
		node:addEventListener(ArmatureEvents.COMPLETE,function( ... )			
			node:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(1),
				CCCallFunc:create(function( ... ) 
					if node.isPlay then
						node:gotoAndStopByIndex(0, 0)
						node:playByIndex(0)
					end
				end)
			))
		end)
		node.stopAnimation = function ( self )
			node.isPlay = false
			node:gotoAndStopByIndex(0, 0)
		end
		node:update(0.001)
		node:stop()
		return node
	else return nil end
end