require 'zoo.panel.share.ShareBasePanel'

ShareHiddenLevelPanel = class(ShareBasePanel)

function ShareHiddenLevelPanel:ctor()

end

local function getFirstAndLastLevel(currentLevel)
	local firstLevel = 1
	local lastLevel = 15
	if currentLevel then 
		if currentLevel%15 == 0 then
			firstLevel = currentLevel - 15
			lastLevel = currentLevel
		else
			firstLevel = currentLevel - (currentLevel%15)
			lastLevel = firstLevel + 15
		end
		firstLevel = firstLevel + 1
	end
	return firstLevel, lastLevel
end

function ShareHiddenLevelPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self)

	self:runAnimalAction()
	self:runLightAction()
	self:runCircleLightAction()
	self:runStarParticle()
	self:runAllLightStarAction()

	local function vineAction()
		self:runVineAction()
	end

	self.ui:runAction(CCCallFunc:create(vineAction))
end

function ShareHiddenLevelPanel:getShareTitleName()
	local achi = self.achiManager:getAchievementWithId(self.shareId)
	return Localization:getInstance():getText(self.shareTitleKey,{num = achi.achiLevel})
end


function ShareHiddenLevelPanel:runLightAction( ... )
	local function lightAction( light_index )
		local light = self.ui:getChildByName("light" .. light_index)

		self:runStarGroupAction(light)

		light:setVisible(true)

		local bglight = light:getChildByName("bglight")

		bglight:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))

		bglight:setScale(0.265, 0.248)
		bglight:setVisible(false)

		local arr = CCArray:create()

		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(function ( ... )
			bglight:setVisible(true)
		end))
		arr:addObject(CCScaleTo:create(0.1, 1.702, 1.588))
		arr:addObject(CCScaleTo:create(0.2, 1.183, 1.464))

		local arr1 = CCArray:create()
		arr1:addObject(CCScaleTo:create(0.3, 0.716, 1.056))
		arr1:addObject(CCFadeOut:create(0.3))

		arr:addObject(CCSpawn:create(arr1))

		bglight:runAction(CCSequence:create(arr))

		--lantern
		local lantern = light:getChildByName("lantern")
		lantern:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		lantern:setScale(0.915)

		local lantern_arr = CCArray:create()
		lantern_arr:addObject(CCScaleTo:create(0.1, 1.1, 0.735))
		lantern_arr:addObject(CCScaleTo:create(0.1, 1.55, 0.884))
		lantern_arr:addObject(CCScaleTo:create(0.2, 0.85, 0.95))
		lantern_arr:addObject(CCScaleTo:create(0.3, 1))
		lantern:runAction(CCSequence:create(lantern_arr))

		--bglight1
		local bglight1 = light:getChildByName("bglight1")
		bglight1:setOpacity(200)
		--bglight1:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		local light_arr = CCArray:create()
		light_arr:addObject(CCScaleTo:create(0.1, 3.7, 3.66))
		light_arr:addObject(CCScaleTo:create(0.1, 4, 2))
		light_arr:addObject(CCScaleTo:create(0.2, 3.7, 3.66))
		light_arr:addObject(CCFadeTo:create(0.5, 255))
		light_arr:addObject(CCFadeTo:create(1, 100))
		--light_arr:addObject(CCFadeOut:create(0.3))

		bglight1:runAction(CCSequence:create(light_arr))

	end

	for index=1,3 do
		local light = self.ui:getChildByName("light" .. index)
		light:setVisible(false)
	end

	local all_arr = CCArray:create()
	all_arr:addObject(CCCallFunc:create(function ( ... )
		lightAction(1)
	end))

	all_arr:addObject(CCDelayTime:create(0.2))
	all_arr:addObject(CCCallFunc:create(function ( ... )
		lightAction(2)
	end))

	all_arr:addObject(CCDelayTime:create(0.2))
	all_arr:addObject(CCCallFunc:create(function ( ... )
		lightAction(3)
	end))

	self.ui:runAction(CCSequence:create(all_arr))
end

function ShareHiddenLevelPanel:runStarGroupAction(parent)
	local starGroup = parent:getChildByName("starGroup")
	if starGroup then 
		local starGroupTable = {}
		for i=1,5 do
			local whiteStar = {}
			whiteStar.ui = starGroup:getChildByName("star"..i)
			whiteStar.ui:setAnchorPointCenterWhileStayOrigianlPosition()
			whiteStar.ui:setOpacity(0)
			
			if i==1 then 
				whiteStar.delayTime = 0.6
				whiteStar.oriScale = whiteStar.ui:getScale()
				--whiteStar.
			elseif i==2 then 
				whiteStar.delayTime = 1.0
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==3 then 
				whiteStar.delayTime = 0.6
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==4 then 
				whiteStar.delayTime = 0.8
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==5 then
				whiteStar.delayTime = 1.0
				whiteStar.oriScale = whiteStar.ui:getScale()
			end
			whiteStar.ui:setScale(0)
			table.insert(starGroupTable, whiteStar)
		end

		for i,v in ipairs(starGroupTable) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(v.delayTime - 0.2)
			local spwanArr1 = CCArray:create()
			local spwanArr2 = CCArray:create()
			local tempTime = 0.4
			spwanArr1:addObject(CCFadeTo:create(tempTime, 255))
			spwanArr1:addObject(CCScaleTo:create(tempTime, v.oriScale))
			spwanArr1:addObject(CCRotateBy:create(tempTime, 90))
			spwanArr2:addObject(CCFadeTo:create(tempTime + 0.2, 0))
			spwanArr2:addObject(CCScaleTo:create(tempTime + 0.2, 0))
			spwanArr2:addObject(CCRotateBy:create(tempTime + 0.2, 90))

			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(CCSpawn:create(spwanArr1))
			sequenceArr:addObject(CCSpawn:create(spwanArr2))
			
			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
		end
	end
end

function ShareHiddenLevelPanel:runVineAction()
	local vine = self.ui:getChildByName("vine")
	local parent = vine:getParent()
	vine:removeFromParentAndCleanup(false)

	local time = CCProgressTimer:create(vine.refCocosObj)
	time:setAnchorPoint(ccp(0,1))
	time:setPosition(ccp(vine:getPosition().x - 80, vine:getPosition().y))
	parent:addChild(CocosObject.new(time))

	time:setType(kCCProgressTimerTypeBar)
	time:setMidpoint(ccp(0, 1))
	time:setBarChangeRate(ccp(1, 0))
	time:setPercentage(0)

	time:runAction(CCProgressTo:create(0.4, 100))
	vine:dispose()
end

function ShareHiddenLevelPanel:runAnimalAction()
	local animal = self.ui:getChildByName("npc")
	
	animal:setAnchorPointWhileStayOriginalPosition(ccp(0.5,0))
	animal:setScale(0.5)
	animal:setOpacity(0)
	animal:setPositionX(animal:getPositionX() - 10)

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.3))

	local arr1 = CCArray:create()
	arr1:addObject(CCScaleTo:create(0.2, 1))
	arr1:addObject(CCFadeIn:create(0.2))

	arr:addObject(CCSpawn:create(arr1))

	arr:addObject(CCScaleTo:create(0.2, 1.05, 0.95))
	arr:addObject(CCScaleTo:create(0.08, 1))

	animal:runAction(CCSequence:create(arr))
end

function ShareHiddenLevelPanel:runCircleLightAction()
	local circleLightUi = self.ui:getChildByName("circleLightBg")
	if circleLightUi then 
		parentUiPos = circleLightUi:getPosition()
		local bg = circleLightUi:getChildByName("bg")
		local posAdjust = circleLightUi:getPosition()
		bg:setAnchorPointCenterWhileStayOrigianlPosition(ccp(posAdjust.x-30,posAdjust.y+230))
		bg:setOpacity(0)
		local sequenceArr = CCArray:create()
		sequenceArr:addObject(CCDelayTime:create(0.5))
		sequenceArr:addObject(CCFadeTo:create(0.1, 255))

		bg:stopAllActions()
		bg:runAction(CCSequence:create(sequenceArr))
		bg:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 6)))

		local light = circleLightUi:getChildByName("bg1")
		light:setAnchorPointCenterWhileStayOrigianlPosition()
		light:setOpacity(0)
		local sequenceArr1 = CCArray:create()
		sequenceArr1:addObject(CCDelayTime:create(0.5))
		local function fadeCallBack()
			light:setOpacity(50)
		end
		sequenceArr1:addObject(CCCallFunc:create(fadeCallBack))
		sequenceArr1:addObject(CCScaleTo:create(0.7, 4.5))
		light:stopAllActions()
		light:runAction(CCSequence:create(sequenceArr1))

		local circle = circleLightUi:getChildByName("bg2")
		circle:setAnchorPointCenterWhileStayOrigianlPosition()
		circle:setOpacity(0)
		local sequenceArr2 = CCArray:create()
		sequenceArr2:addObject(CCDelayTime:create(0.5))
		local function fadeCallBack()
			circle:setOpacity(255)
		end
		sequenceArr2:addObject(CCCallFunc:create(fadeCallBack))
		local spwanArr = CCArray:create()
		spwanArr:addObject(CCScaleTo:create(0.5, 4.5))
		spwanArr:addObject(CCFadeOut:create(0.5))
		sequenceArr2:addObject(CCSpawn:create(spwanArr))
		circle:stopAllActions()
		circle:runAction(CCSequence:create(sequenceArr2))
	end
end

function ShareHiddenLevelPanel:runStarParticle()
	if not _G.__use_low_effect then
		local function addParticle()
			local particle = ParticleSystemQuad:create("share/star1.plist")
			particle:setPosition(ccp(355,-570))
			local childIndex = self.ui:getChildIndex(self.ui:getChildByName("npc"))
			self.ui:addChildAt(particle, childIndex)	
		end 
		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(addParticle)))
	end
end

function ShareHiddenLevelPanel:runAllLightStarAction()
	for i=1,3 do
		local lightStarUi = self.ui:getChildByName("lightStar"..i)
		self:runLightStarAction(lightStarUi)		
	end	
end

function ShareHiddenLevelPanel:runLightStarAction(lightStarUi)
	if lightStarUi then 
		local lightStarTable = {}
		for i=1,5 do
			local whiteStar = {}
			whiteStar.ui = lightStarUi:getChildByName("star"..i)
			whiteStar.ui:setAnchorPointCenterWhileStayOrigianlPosition()
			whiteStar.ui:setOpacity(0)
			
			if i==1 then 
				whiteStar.delayTime = 0.4
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==2 then 
				whiteStar.delayTime = 1.0
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==3 then 
				whiteStar.delayTime = 0.6
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==4 then 
				whiteStar.delayTime = 0.8
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==5 then
				whiteStar.delayTime = 1.2
				whiteStar.oriScale = whiteStar.ui:getScale()
			end
			whiteStar.ui:setScale(0)
			table.insert(lightStarTable, whiteStar)
		end

		for i,v in ipairs(lightStarTable) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(v.delayTime)
			local spwanArr1 = CCArray:create()
			local spwanArr2 = CCArray:create()
			local tempTime = 0.4
			spwanArr1:addObject(CCFadeTo:create(tempTime, 255))
			spwanArr1:addObject(CCScaleTo:create(tempTime, v.oriScale))
			spwanArr1:addObject(CCRotateBy:create(tempTime*3, 270))
			spwanArr2:addObject(CCFadeTo:create(tempTime, 0))
			spwanArr2:addObject(CCScaleTo:create(tempTime, 0))
			spwanArr2:addObject(CCRotateBy:create(tempTime*3, 270))

			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(CCSpawn:create(spwanArr1))
			sequenceArr:addObject(CCSpawn:create(spwanArr2))
			
			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
		end
	end
end

function ShareHiddenLevelPanel:create(shareId)
	local panel = ShareHiddenLevelPanel.new()
	panel:loadRequiredResource("ui/NewSharePanel.json")
	panel.ui = panel:buildInterfaceGroup('ShareHiddenLevelPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end

function ShareHiddenLevelPanel:beforeSrnShot(srnShot, afterSrnShot)
	local function moreAdjust()
		self:loadSpecialBackground()
		if srnShot then
			srnShot()
		end
		if afterSrnShot then
			afterSrnShot()
		end
	end
	ShareBasePanel.beforeSrnShot(self, moreAdjust)
end

function ShareHiddenLevelPanel:afterSrnShot()
   	self:unloadSpecialBackground()
end