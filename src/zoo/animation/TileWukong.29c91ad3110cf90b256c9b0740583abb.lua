TileWukong = class(CocosObject)
TileWukongState = {
	
	kNormal = 1,
	kOnHit = 2,
	kOnActive = 3,
	kReadyToJump = 4,
	kJumping = 5,
	kReadyToCasting = 6,
	kCasting = 7,
	kReadyToChangeColor = 8,
	kChangeColor = 9,
	kGift = 10,
}

function TileWukong:create(data)
    local node = TileWukong.new(CCNode:create())
    node:init(data)
    return node
end

function TileWukong:createByAnimation()
	local node = TileWukong.new(CCNode:create())
	node:init({
		wukongProgressCurr = 100,
		wukongProgressTotal = 100,
		ItemColorType = AnimalTypeConfig.kBlue,
		wukongIsReadyToJump = true,
		})
	return node
end

function TileWukong:init(data)

	--self.state = TileWukongState.kNormal
	self.progressCurr = data.wukongProgressCurr
	self.progressTotal = data.wukongProgressTotal
	self.colorIndex = AnimalTypeConfig.convertColorTypeToIndex(data._encrypt.ItemColorType) 
    self.ItemColorType = data._encrypt.ItemColorType
    
    FrameLoader:loadArmature("skeleton/wukong_animation")

	--createProgressBar(self.colorIndex)
	--self:setColor( self.ItemColorType )

	--local progressBG = SpriteColorAdjust:createWithSpriteFrameName("wukong_progress_bg")
	--local progressMask = SpriteColorAdjust:createWithSpriteFrameName("wukong_progress_bg")

	
	self:changeState(data.wukongState)

	if _G.isLocalDevelopMode then printx(0, "TileWukong:init    needHideMoneyBar = " , data.needHideMoneyBar) end
	if data.needHideMoneyBar then
		self:hideMonkeyBar()
	end
	
end

function TileWukong:createProgressBar(colorIndex)
	local oldX = nil
	if self.progressFG then self.progressFG:removeFromParentAndCleanup(true) end
	if self.progressBG then self.progressBG:removeFromParentAndCleanup(true) end
	if self.progressMask then 
		oldX = self.progressMask:getPositionX()
		self.progressMask:removeFromParentAndCleanup(true) end
	if self.progress then self.progress:removeFromParentAndCleanup(true) end

	local progressBG = Sprite:createWithSpriteFrameName("wukong_progress_bg_" .. tostring(colorIndex) )
	local progressFG = Sprite:createWithSpriteFrameName("wukong_progress_fg")
	local progressMask = Sprite:createWithSpriteFrameName("wukong_progress_bg_" .. tostring(colorIndex) )
	local progress = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
	progress:addChild(progressBG)

	self.progress = progress
	self.progressFG = progressFG
	self.progressBG = progressBG
	self.progressMask = progressMask

	progress:setPositionY(-35 + 10 )
	self:addChild(progress)
	progressFG:setPositionY(-35 + 10 )
	self:addChild(progressFG)

	--progressFG:setScale(0.85)
	--progress:setScale(0.85)

	self.progressDefaultPosition = progressBG:getGroupBounds().size.width * -1

	self:setProgress(self.progressCurr , self.progressTotal)

	if self.progressCurr >= self.progressTotal then
		self:hideMonkeyBar()
	end

end

function TileWukong:showMonkeyBar()
	if self.progress then self.progress:setVisible(true) end
	if self.progressFG then self.progressFG:setVisible(true) end
end

function TileWukong:hideMonkeyBar()
	if self.progress then self.progress:setVisible(false) end
	if self.progressFG then self.progressFG:setVisible(false) end
end

function TileWukong:playOnce(time)
	if self.body then
		self.body:playByIndex(0 , 1)

		local delay = CCDelayTime:create(time)
	    local callfunc = CCCallFunc:create(function () 
	    	if self.body then
	    		self.body:stopAllActions()
	    		self:playOnce(time)
	    	end
	    end)
	    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
	    local action = CCRepeatForever:create(sequence)
		self.body:runAction(action)
	end
end

function TileWukong:createAnimation(stateString , playTimes , intervalTime)

	if not playTimes then playTimes = 0 end
	if not intervalTime then intervalTime = 0 end

	if self.stateString ~= stateString then

		self.stateString = stateString

		if self.body then
			self.body:gotoAndStopByIndex(0, 0)
			self.body:stopAllActions()
			self.body:removeFromParentAndCleanup(true)
		end

		local eff = ArmatureNode:create("wukong_animation/" .. stateString)
		local effSize = eff:getGroupBounds().size
		--eff:setAnchorPoint(ccp(0,0))
		--eff:setPosition( ccp( effSize.width / -2 , (effSize.height / 2) ) )
		--eff:playByIndex(0 , 0)
		
		eff:playByIndex(0)
		eff:update(0.001) -- 此处的参数含义为时间
		eff:stop()
		self.body = eff

		if playTimes > 0 then
			self.body:playByIndex(0 , playTimes)
		else
			if intervalTime == 0 then
				self.body:playByIndex(0 , 0)
			else
				self:playOnce(intervalTime)
			end
		end
		
		self:addChildAt(self.body , 1)
		self.body:setScale(0.85)
		self.body:setPositionY( self.body:getPositionY() + 8 )

		self:setColor( self.ItemColorType )
	end
end

function TileWukong:changeState(state , callback)
	if self.state ~= state then
		--self.state = state
		if state == TileWukongState.kNormal then
			self:createAnimation("default" , 0 , 6)
		elseif state == TileWukongState.kOnHit then
			self:createAnimation("onHIt" , 1)
		elseif state == TileWukongState.kOnActive then
			self:createAnimation("onActive" , 0 , 4)
			self:hideMonkeyBar()
		elseif state == TileWukongState.kReadyToJump then
			self:createAnimation("readyToJump" , 0 , 3)
			self:hideMonkeyBar()
		elseif state == TileWukongState.kJumping then
			self:createAnimation("casting" , 1)
			self:hideMonkeyBar()
		elseif state == TileWukongState.kReadyToCasting then
			self:createAnimation("casting" , 1)
			self:hideMonkeyBar()
		elseif state == TileWukongState.kCasting then

		elseif state == TileWukongState.kReadyToChangeColor then
			self:createAnimation("default" , 0 , 6)
			self:hideMonkeyBar()
		elseif state == TileWukongState.kChangeColor then
			
		elseif state == TileWukongState.kLock then

		end

		self.state = state
	end

	if callback then callback() end
end

function TileWukong:setProgress(curr , total)
	if curr > total then curr = total end
	if curr > self.progressCurr then
		self.progressCurr = curr
	end
	if not self.progressCurr or self.progressCurr <= 0 then
		self.progressCurr = 0
	end
	self.progressTotal = total
	
	--self.progressDefaultPosition = self.progressBG:getGroupBounds().size.width * -1
	local textW = self.progressBG:getGroupBounds().size.width
	self.progressDefaultPosition = -58
	local tarX = self.progressDefaultPosition * ( 1 - self.progressCurr/self.progressTotal )
	--CommonTip:showTip( tostring(self.progressDefaultPosition) .. "_" .. tostring(tarX) , nil , nil , 10)
	self.progressMask:setPositionX( tarX ) 

	--[[
	if not self.textInfo then
		self.textInfo = TextField:create("0/0" , nil , 22)
		self.textInfo:setPosition( ccp(0 , 15) )
		self:addChild(self.textInfo)
	end
	self.textInfo:setString(self.progressCurr.."/"..self.progressTotal)
	]]
end

function TileWukong:setColor(color , callback)
	self.ItemColorType = color

	local colorString = ""

	if color == AnimalTypeConfig.kBlue then 
		colorString = "2"
    elseif color == AnimalTypeConfig.kGreen then 
    	colorString = "4"
    elseif color == AnimalTypeConfig.kOrange then 
    	colorString = "5"
    elseif color == AnimalTypeConfig.kPurple then 
    	colorString = "3"
    elseif color == AnimalTypeConfig.kRed then 
    	colorString = "1"
    elseif color == AnimalTypeConfig.kYellow then 
    	colorString = ""
    end

	

	local clothes = self.body:getSlot("laohu maozi")
	local replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/laohu maozi" .. colorString)
	clothes:setDisplayImage(replaceSprite)

	----[[
	clothes = self.body:getSlot("laohu bizi1")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/laohu bizi" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("laohu erduo")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/laohu erduo" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("laohu erduo_0")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/laohu erduo" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("hou geb")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/hou geb" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("hou geb_0")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/hou geb" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("nabangzi")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/nabangzi" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end

	clothes = self.body:getSlot("nabangzi_0")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/nabangzi" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end

	clothes = self.body:getSlot("hou shen")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/hou shen" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	
	clothes = self.body:getSlot("huibangzi")
	if clothes then
		replaceSprite = ArmatureFactory:getTextureDisplay("wukong_animation/bangzi" .. colorString)
		clothes:setDisplayImage(replaceSprite)
	end
	


	--]]

	self:createProgressBar(self.colorIndex)


	if callback then
		callback() 
	end
	
end

function TileWukong:setColorByAdjustColorSprite(color , callback)
    local value = {0,0,0,0}
    if color == AnimalTypeConfig.kBlue then value = {0,0,0,0}
    elseif color == AnimalTypeConfig.kGreen then value = {-0.41, 0.23, 0.0, 0.0}
    elseif color == AnimalTypeConfig.kOrange then value = {180/180, -49/100, -10/256, 25/100}
    elseif color == AnimalTypeConfig.kPurple then value = {0.368, 0.1, -0.08, 0}
    elseif color == AnimalTypeConfig.kRed then value = {0.9, 0.12, -0.2, 0}
    elseif color == AnimalTypeConfig.kYellow then value = {-0.86, 1, 0.27, 0.6}
    end
    self.body:adjustColor(value[1],value[2],value[3],value[4])
    self.body:applyAdjustColorShader()
    self.color = color
end

function TileWukong:setGrey()
    local zOrder = self.body:getZOrder()
    if self.body then 
        self.body:removeFromParentAndCleanup(true)
        self.body = nil
    end
    self.body = SpriteColorAdjust:createWithSpriteFrameName('magic_lamp_greying_0000')
    self.body:setAnchorPoint(ccp(0.5, 0.5))
    self.border:setVisible(false)
    self.stars:setVisible(false)
    self:addChildAt(self.body, zOrder)
end

function TileWukong:createStars()
    local es_spx = {-33, -27, -18, -4, 13, 26, 29}
    local es_spy = {-26, 21, -30, -28, 30, -20, 10}

    local es_epx = {-33, -27, -18, -4, 13, 26, 29}
    local es_epy = {-2, 33, -25, -21, 34, 1, 33}

    local es_delay = {0, 0.08, 0.21, 0.13, 0.28, 0.25, 0.19}
    local es_sc = {0.22, 0.25, 0.33, 0.42, 0.36, 0.4, 0.31}
    local node = Sprite:createEmpty()
    for i=1,#es_spx do
        local effectStar_C = Sprite:createWithSpriteFrameName("Wrap_Effect_Star.png");
        effectStar_C:setPosition(ccp(es_spx[i], es_spy[i]));
        effectStar_C:setScale(es_sc[i]);
        node:addChild(effectStar_C);

        local function onTimeout()
            local delayAction = CCDelayTime:create(es_delay[i]);                        ----等待
            local showAction = CCFadeTo:create(0.2, 200 + i * i);                       ----显示
            local movetoAction = CCMoveTo:create(0.5, ccp(es_epx[i], (es_epy[i] + es_spy[i]) / 2));         ----移动
            local sp1 = CCSpawn:createWithTwoActions(showAction, movetoAction); 

            local delayAction2 = CCDelayTime:create(0.1);                       ----等待
            local showAction2 = CCFadeTo:create(0.3, 0);                        ----显示
            local movetoAction2 = CCMoveTo:create(0.4, ccp(es_epx[i], es_epy[i]));          ----移动
            local sq1 = CCSequence:createWithTwoActions(delayAction2, showAction2);
            local sp2 = CCSpawn:createWithTwoActions(sq1, movetoAction2);

            local movetoAction3 = CCMoveTo:create(0.01, ccp(es_spx[i], es_spy[i]));

            local arr = CCArray:create();
            arr:addObject(delayAction)
            arr:addObject(sp1)
            arr:addObject(sp2)
            arr:addObject(movetoAction3);
            effectStar_C:stopAllActions()
            effectStar_C:runAction(CCRepeatForever:create(CCSequence:create(arr)))
        end

        delayTime = delayTime or 0
        effectStar_C:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(onTimeout)))
    end
    return node
end