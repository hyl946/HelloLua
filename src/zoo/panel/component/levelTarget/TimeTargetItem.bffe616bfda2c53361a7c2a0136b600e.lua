TimeTargetItem = class(LevelTargetItem)

function TimeTargetItem:init()
	local spriteSize = self.sprite:getGroupBounds().size
	self.sprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
	self.shadowSprite:setContentSize(CCSizeMake(spriteSize.width, spriteSize.height))
	self.sprite:setAnchorPoint(ccp(0,0))
	self.shadowSprite:setAnchorPoint(ccp(0,0))
	local pos = self.sprite:getPosition()
	self.shadowSprite:setPosition(ccp(pos.x,pos.y))
	self.context.attachSprite:addChild(self.shadowSprite)


	local fntFile	= "fnt/score_objectives.fnt"
	local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentCenter)
	text.fntFile 	= fntFile
	text.hAlignment = kCCTextAlignmentCenter
	text:setPosition(ccp(-75, -67.45))
	text:setPreferredSize(150, 38)
	text.offsetX = text:getPosition().x
	text:setAlignment(kCCTextAlignmentCenter)
	text:setAnchorPoint(ccp(0.5, 0.5))
	text:setString("0")
	self.shadowSprite:addChild(text)
	self.label = text

	local finished = self:initFinishedIcon(self.sprite:getChildByName("finished"))
    self.finishedIcon = finished
	finished:removeFromParentAndCleanup(false)
	self.shadowSprite:addChild(finished)

    local highlight = self.sprite:getChildByName('highlight')
    highlight:setVisible(false)
    
    self.highlight = highlight
    self.finished_bg = finished_bg
    self.finished_icon = finished_icon
end

function TimeTargetItem:onTouchBegin(evt)
	self:shakeObject()
	self.context:playLeafAnimation(true)
	self.context:playLeafAnimation(false)
end

function TimeTargetItem:reset()
	local finished = self.finishedIcon
	finished:setVisible(false)
end

function TimeTargetItem:finish()
	if self.isFinished then return end
	self.isFinished = true

	local finished = self.finishedIcon
	finished:setVisible(true)
	local function onPlayShake()
		self:shake()
	end
	self:playFinishAnim(finished, onPlayShake)
end

function TimeTargetItem:shake()
	self:shakeObject()
end

function TimeTargetItem:fadeIn(delayTime )
	delayTime = delayTime or 0
	local position = self.label:getPosition()
	local spawn = CCArray:create()
	spawn:addObject(CCFadeIn:create(0.4))
	spawn:addObject(CCScaleTo:create(0.4, 0.7))
	spawn:addObject(CCMoveTo:create(0.4, ccp(position.x, position.y)))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delayTime))
	array:addObject(CCSpawn:create(spawn))
	array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1.2), CCTintTo:create(0.2, 210, 255, 0)))
	array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 0.7), CCTintTo:create(0.2, 255, 255, 255)))
	
	self.label:setPosition(ccp(position.x+25, position.y-100))
	self.label:setOpacity(0)
	self.label:setScale(0.1)
	self.label:runAction(CCSequence:create(array))
end

function TimeTargetItem:setContentIcon( icon, number )
	-- local label = self.sprite:getChildByName("label")
	local label = self.label
	if number ~= nil and label then
		label:setString(tostring(number or 0))
		label:setOpacity(0)
	end
	self.maxNumber = number
end

function TimeTargetItem:setTargetNumber( itemId, itemNum )
	self.itemNum = itemNum
	if itemNum >= self.maxNumber then self:finish() end
end

function TimeTargetItem:revertTargetNumber( itemId, itemNum )
	self.itemNum = itemNum
	if itemNum < self.maxNumber then 				
		self:reset()
		self.isFinished = false 
	end
end

