require "zoo.panel.component.levelTarget.LevelTargetItem"

MoleWeeklyTargetItem =  class(LevelTargetItem)

function MoleWeeklyTargetItem:init()

    self.IfNeedShowTarget = true
    local instance = RankRaceMgr:getExistedInstance()
    if instance then
        self.IfNeedShowTarget = instance:needShowTargetInfoInGamePlay()
    end

    local mainLogic = GameBoardLogic:getCurrentLogic()

    local bgScale = 1
    if mainLogic and mainLogic.PlayUIDelegate then
        bgScale = mainLogic.PlayUIDelegate.gameBgNode.upBg:getScale()
    end
    self.sprite:setScale( bgScale )

	local spriteSize = self.sprite:getGroupBounds().size
	self.sprite:setContentSize(CCSizeMake(spriteSize.width*bgScale, spriteSize.height*bgScale))
	self.shadowSprite:setContentSize(CCSizeMake(spriteSize.width*bgScale, spriteSize.height*bgScale))
	self.sprite:setAnchorPoint(ccp(0,0))
	self.shadowSprite:setAnchorPoint(ccp(0,0))
    self.shadowSprite:setScale( bgScale )
	local pos = self.sprite:getPosition()
	self.shadowSprite:setPosition(ccp(pos.x,pos.y))
	self.context.attachSprite:addChild(self.shadowSprite)
	self:initContent()

	local fntFile	= "fnt/animal_num.fnt"
	local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentCenter)
	text.fntFile 	= fntFile
	text.hAlignment = kCCTextAlignmentCenter
	text:setPosition( ccp( -39-8, -94.45-8 ) )
	text.offsetX = text:getPosition().x
	text:setAnchorPoint(ccp(0,1))
	text:setPreferredSize(100, 38)
	text:setAlignment(kCCTextAlignmentCenter)
	text:setString("0")
	text:setScale(2*bgScale)
	text:setOpacity(0)
	self.shadowSprite:addChild(text)
	self.label = text

	local finished = self:initFinishedIcon(self.sprite:getChildByName("finished"))
	self.finishedIcon = finished
	finished:removeFromParentAndCleanup(false)
	self.shadowSprite:addChild(finished)

    local pos = finished:getPosition()
    finished:setPosition( ccp(pos.x-22/0.7, pos.y+26/0.7-6))

    local highlight = self.sprite:getChildByName('highlight')
    highlight:setVisible(false)

	self.isFinished = false

    self.newisFinished = false

    local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene then
        local energyIconPosInWorld = self.label:getPositionInWorldSpace()

        local winSize = CCDirector:sharedDirector():getWinSize()
        local layer = Layer:create()
        runningScene:addChild( layer, SceneLayerShowKey.TOP_LAYER )

		local sp = Sprite:createWithSpriteFrameName("MoleWeekly_targetComplete.png")
        sp:setPosition( ccp(energyIconPosInWorld.x-54/0.7*bgScale,energyIconPosInWorld.y-24/0.7*bgScale) )
        sp.savePos = sp:getPosition()
        layer:addChild( sp )

        self.CompleteLabel = sp
        self.CompleteLabel:setVisible(false)
	end
end

function MoleWeeklyTargetItem:finish()
	if self.newisFinished then return end
	self.newisFinished = true
	local finished = self.finishedIcon
	finished:setVisible(true)

    function callend()
        self.CompleteLabel:setVisible(false)
    end

    function TargetLabel()
        if self.CompleteLabel then
            self.CompleteLabel:setVisible(true)
            self.CompleteLabel:setPosition( ccp(self.CompleteLabel.savePos.x, self.CompleteLabel.savePos.y) )
            self.CompleteLabel:setOpacity( 150 )

            local array1 = CCArray:create()
            array1:addObject( CCFadeIn:create(0.2)  )
            array1:addObject( CCMoveBy:create(0.2, ccp(0, -15 )) )

            local array3 = CCArray:create()
            array3:addObject( CCMoveBy:create(0.2, ccp(0, -15 )) )
            array3:addObject( CCFadeOut:create(0.2) )
    
            local array = CCArray:create()
            array:addObject( CCSpawn:create(array1)  )
            array:addObject( CCMoveBy:create(0.2, ccp(0,5))  )
            array:addObject( CCSpawn:create(array3)  )
            array:addObject(CCCallFunc:create(callend))

            self.CompleteLabel:runAction( CCSequence:create( array ) )
        end
    end

	local function onPlayShake()
		self:shake()

        TargetLabel()
	end
	self:playFinishAnim(self.finishedIcon, onPlayShake)
end

function MoleWeeklyTargetItem:initMaxTargetValue()
    self.maxTargetValue = MoleWeeklyRaceConfig:getCollectTargetAmount()
    self:setLabelText(0)
end

function MoleWeeklyTargetItem:setLabelText(currVal)

    if self.IfNeedShowTarget then
        local currValStr = tostring(currVal or 0)
        self.label:setStringEx(currValStr.."/"..self.maxTargetValue)

        if currVal >= self.maxTargetValue  then
            --对勾出现
            self:finish()
        else
            self.finishedIcon:setVisible(false)
        end
    else
        local currValStr = tostring(currVal or 0)
        self.label:setStringEx(currValStr.."")

        --对勾隐藏
        self.finishedIcon:setVisible(false)
    end

    self.label:setVisible(true)
end

function MoleWeeklyTargetItem:setTargetNumber(itemNum, animate, globalPosition )
    if not self.sprite.refCocosObj then return end
    if itemNum ~= nil then
        -- 防止数字回滚
        -- 前提：反正该模式下，数字是单向增加的

        local AddNum = 1

        if itemNum > self.itemNum then
            AddNum = itemNum - self.itemNum
        end

        if itemNum >= self.itemNum then
            self.itemNum = itemNum
        end

        if animate and globalPosition and self.icon then

            if AddNum == 1 then
                local cloned = self.icon:clone(true)
                -- local targetPos = self:convertToNodeSpace(globalPosition)
                local targetPos = self.sprite:getParent():convertToNodeSpace(globalPosition)
                local position = cloned:getPosition()
                local tx, ty = position.x, position.y
                local function onIconScaleFinished()
                    cloned:removeFromParentAndCleanup(true)
                    self.animNode = nil
                end 
                local function onIconMoveFinished()
                    self:setLabelText(self.itemNum)
--                    self.context:playLeafAnimation(true)
--                    self.context:playLeafAnimation(false)
                    self:shakeObject()
                    local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                    cloned:setOpacity(255)
                    cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
                end 
                local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
                local array = CCArray:create()
            
                array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5, 1), CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150))))
                array:addObject(CCCallFunc:create(onIconMoveFinished))
                cloned:setPosition(targetPos)
                cloned:setScale(1.5)
                cloned:runAction(CCSequence:create(array))
                self.animNode = cloned
            elseif AddNum > 1 then
                local TargetFlyNum = math.ceil(AddNum/3)

                for i=1, TargetFlyNum do
                    local cloned = self.icon:clone(true)
                    -- local targetPos = self:convertToNodeSpace(globalPosition)
                    local targetPos = self.sprite:getParent():convertToNodeSpace(globalPosition)
                    local position = cloned:getPosition()
                    local tx, ty = position.x, position.y
                    local function onIconScaleFinished()
                        cloned:removeFromParentAndCleanup(true)
                        cloned = nil
                    end 
                    local function onIconMoveFinished()
                        self:setLabelText(self.itemNum)
--                        self.context:playLeafAnimation(true)
--                        self.context:playLeafAnimation(false)
                        self:shakeObject()
                        local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                        cloned:setOpacity(255)
                        cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
                    end 
                    local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
                    local array = CCArray:create()
            
                    array:addObject(CCDelayTime:create( (i-1)*0.1) )
                    array:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5, 1), CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150))))
                    array:addObject(CCCallFunc:create(onIconMoveFinished))
                    cloned:setPosition(targetPos)
                    cloned:setScale(1.5)
                    cloned:runAction(CCSequence:create(array))
                    
                end
            end
        else
            self:setLabelText(itemNum)
        end
    end
end

function MoleWeeklyTargetItem:revertTargetNumber(itemNum)
    if itemNum >= 0 then
        self:setLabelText(itemNum)
        self.itemNum = itemNum
    end
end
