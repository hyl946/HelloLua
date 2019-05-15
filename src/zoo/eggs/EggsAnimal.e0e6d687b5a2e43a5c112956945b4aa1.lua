EggsAnimal = class(BasePanel)

-- EggsAnimal
function EggsAnimal:create( animalType,worldScene )
	local animal = EggsAnimal.new()
	animal:init(animalType,worldScene)
	return animal
end

function EggsAnimal:dispose( ... )
	BasePanel.dispose(self)

	if self.extraTip then
		self.extraTip:removeFromParentAndCleanup(true)
	end
end

function EggsAnimal:init( animalType,worldScene )
	self.animalType = animalType
	self.worldScene = worldScene

	self.ui = Layer:create()
	BasePanel.init(self,self.ui)

	FrameLoader:loadArmature("skeleton/eggs_animation")
	local tipPosX,tipPosY
	if animalType == EggsAnimalType.kChicken then
		self.animal = ArmatureNode:create("eggs_animation/littlechicken")
		tipPosX,tipPosY = 170,75
	elseif animalType == EggsAnimalType.kFrog then
		self.animal = ArmatureNode:create("eggs_animation/DUFrogB")
		tipPosX,tipPosY = 170,62
	elseif animalType == EggsAnimalType.kHorse then
		self.animal = ArmatureNode:create("eggs_animation/hemadong")
		tipPosX,tipPosY = 170,75
	elseif animalType == EggsAnimalType.kBear then
		self.animal = ArmatureNode:create("eggs_animation/xiong caidan ")
		tipPosX,tipPosY = 180,75
	elseif animalType == EggsAnimalType.kCat then
		self.animal = ArmatureNode:create("eggs_animation/猫头鹰彩蛋")
		tipPosX,tipPosY = 180,75
	elseif animalType == EggsAnimalType.kFox then
		self.animal = ArmatureNode:create("eggs_animation/foxres01")
		tipPosX,tipPosY = 180,78
	end
	self.ui:addChild(self.animal)

	self.tipLabel = CCLabelTTF:create("","微软雅黑",28)
	self.tipLabel:setColor(ccc3(0x66,0xCC,0xFF))
	self.tipLabel:setAnchorPoint(ccp(0.5,0.5))
	self.tipLabel:setPositionX(tipPosX)
	self.tipLabel:setPositionY(tipPosY)

	local tipSlot = self.animal:getSlot("sgt")
	local tipDisplay = tolua.cast(tipSlot:getCCDisplay(),"CCSprite")
	if __IOS then
		self.tipLabel:setDimensions(tipDisplay:getContentSize())
		self.tipLabel:setHorizontalAlignment(kCCTextAlignmentCenter)
		self.tipLabel:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	end

	if self.animalType == EggsAnimalType.kFrog and self.worldScene then
		self.extraTip = ArmatureNode:create("eggs_animation/DUFrogBTip")
		self.worldScene.scaleTreeLayer2:addChild(self.extraTip)

		tipDisplay:setTextureRect(CCRectMake(0,0,0,0))
		local tipSlot = self.extraTip:getSlot("sgt")
	 	tipDisplay = tolua.cast(tipSlot:getCCDisplay(),"CCSprite")
	end
	tipDisplay:addChild(self.tipLabel)

	self.ui:setTouchEnabled(true,0,true)

	if self.animalType == EggsAnimalType.kHorse then
		function self.ui:hitTestPoint( worldPosition, useGroupTest )
			local pos = self:convertToWorldSpace(ccp(0,-220))
			return CCRectMake(pos.x,pos.y,180,220):containsPoint(worldPosition)
		end
	end
	if self.animalType == EggsAnimalType.kCat then
		function self.ui:hitTestPoint( worldPosition, useGroupTest )
			local pos = self:convertToWorldSpace(ccp(0,-180))
			return CCRectMake(pos.x,pos.y,180,180):containsPoint(worldPosition)
		end
	end
	if self.animalType == EggsAnimalType.kChicken then
		function self.ui:hitTestPoint( worldPosition, useGroupTest )
			if worldScene and worldScene.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
				return false
			end
			return Layer.hitTestPoint(self,worldPosition,useGroupTest)
		end
	end
	self.ui:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onCicked() end)

	self:playNormalAnimation()
end

function EggsAnimal:getRandomTipText( ... )
	local key 
	if self.animalType == EggsAnimalType.kChicken then
		key = "children.day.click.chicken" .. math.random(1,3)
	elseif self.animalType == EggsAnimalType.kFrog then
		key = "children.day.click.frog" .. math.random(1,2)
	elseif self.animalType == EggsAnimalType.kHorse then
		key = "children.day.click.hippo" .. math.random(1,3)
	elseif self.animalType == EggsAnimalType.kBear then
		key = "children.day.click.bear" .. math.random(1,3)
	elseif self.animalType == EggsAnimalType.kCat then
		key = "children.day.click.owl." .. math.random(1,3)
	elseif self.animalType == EggsAnimalType.kFox then
		key = "children.day.click.fox." .. math.random(1,3)
	end

	return Localization:getInstance():getText(key,{n="\n"})
end

function EggsAnimal:onCicked( ... )
	if self.isDisposed then
		return
	end
	if self.isRequesting then
		return
	end

	local function onSuccess( evt )
		self.isRequesting = false

		local reward 
		if evt and evt.data and evt.data.reward then
			if evt.data.reward.num > 0 then
				reward = evt.data.reward
			end
		end

		EggsManager:setClicked(self.animalType)

		if not reward then
			DcUtil:UserTrack({ 
				category="activity",
				sub_category="children_day_click_animal",
				t1=2,
				t2=self.animalType 
			})

			self:playTipAnimation(self:getRandomTipText())
		else
			DcUtil:UserTrack({ 
				category="activity",
				sub_category="children_day_click_animal",
				t1=1,
				t2=self.animalType 
			})

			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addReward(reward)
			-- UserService:getInstance():addReward(reward)


			if self.isDisposed then
				if EggsManager:hasAllClicked() then
				end
				return
			end

			local bounds = self:getGroupBounds()
			local anim = FlyItemsAnimation:create({reward})
			anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
			anim:play()

			self:playTipAnimation(Localization:getInstance():getText("children.day.click.animal",{n="\n"}))

			local delayTime = 1
			if self.animalType == EggsAnimalType.kChicken then
				delayTime = 110 / 24
			elseif self.animalType == EggsAnimalType.kFrog then
				delayTime = 110 / 24
			elseif self.animalType == EggsAnimalType.kHorse then
				delayTime = 90 / 24
			elseif self.animalType == EggsAnimalType.kBear then
				delayTime = 105 / 24
			elseif self.animalType == EggsAnimalType.kCat then
				delayTime = 90 / 24
			elseif self.animalType == EggsAnimalType.kFox then
				delayTime = 75 / 24
			end
			self:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(delayTime),
				CCCallFunc:create(function( ... )
					if EggsManager:hasAllClicked() then
					end
				end)
			))
		end
	end
    local function onFail(evt)
    	-- CommonTip:showTip(Localization:getInstance():getText("error.tip."..evt.data), "negative")
  		self.isRequesting = false

		self:playTipAnimation(Localization:getInstance():getText("children.day.click.offline",{n="\n"}))
	end

	if EggsManager:hasClicked(self.animalType) then
		onSuccess({})
	else
		self.isRequesting = true
		RequireNetworkAlert:callFuncWithLogged(function( ... )
			if EggsManager:hasClicked(self.animalType) then
				onSuccess({})
			else
				local http = getEasterEggReward.new(true)
				http:addEventListener(Events.kComplete, onSuccess)
				http:addEventListener(Events.kError, onFail)
				http:load(self.animalType)
			end
		end,function( ... )
			onFail({ data=-2 })
		end)
	end
end

function EggsAnimal:playNormalAnimation( ... )
	if self.isDisposed then
		return
	end
	self.state = "playNormal"

	self.animal:playByIndex(0)
	self.animal:removeAllEventListeners()
	self.animal:stopAllActions()
	self.animal:addEventListener(ArmatureEvents.COMPLETE,function( ... )
		self.animal:removeAllEventListeners()
		self.state = "playNormalEnd"

		self.animal:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(1.5),
			CCCallFunc:create(function( ... )
				self:playNormalAnimation()
			end)
		))
	end)

end

function EggsAnimal:playTipAnimation( text )
	if self.isDisposed then
		return
	end

	if self.state == "playTip" then
		return
	end

	self.tipLabel:setString(text)

	local function play( ... )
		
		self.animal:playByIndex(1)
		self.animal:removeAllEventListeners()
		self.animal:stopAllActions()
		self.animal:addEventListener(ArmatureEvents.COMPLETE,function( ... )
			self.animal:removeAllEventListeners()
			self:playNormalAnimation()

			if cb then cb() end
		end)

		if self.extraTip and self.worldScene then
			self.extraTip:setPosition(self.worldScene.scaleTreeLayer2:convertToNodeSpace(
				self:convertToWorldSpace(ccp(0,0))
			))
			self.extraTip:playByIndex(1)
		end
	end

	play()

	self.state = "playTip"
end


function EggsAnimal:isPlayTip( ... )
	return self.state == "playTip"
end
