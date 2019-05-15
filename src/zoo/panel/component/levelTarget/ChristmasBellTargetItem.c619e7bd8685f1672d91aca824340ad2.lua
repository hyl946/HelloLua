ChristmasBellTargetItem = class(LevelTargetItem)

function ChristmasBellTargetItem:init()
    LevelTargetItem.init(self)

    local bg = self.sprite:getChildByName("bg")
    bg:setVisible(false)

    local bellBg = ResourceManager:sharedInstance():buildBatchGroup("sprite", "yuanxiao_target_board_ui")
    --[[
    ResourceManager:sharedInstance():addJsonFile("activity/Lantern2017/res/levelPlayRes.json")
    local bellBg = ResourceManager:sharedInstance():buildGroup("yuanxiao_target_board_ui")
    ]]

    bellBg:setPositionXY(bg:getPositionX(),bg:getPositionY())
    self.sprite:addChildAt(bellBg,0)
end

function ChristmasBellTargetItem:setContentIcon(icon, number )
    LevelTargetItem.setContentIcon(self,icon,number)

    if self.icon and self.iconSize then
        self.icon:setPositionX(self.icon:getPositionX() + 5)
        self.icon:setPositionY(self.icon:getPositionY() + 3)
    end
end

function ChristmasBellTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition, rotation )
	if self.isFinished then return end
	if not self.sprite.refCocosObj then return end
	if itemNum ~= nil then
		self.itemNum = itemNum
		if itemNum <= 0 then self:finish() end

		if animate and globalPosition and self.icon then
            local cloned = self.icon:clone(true)
            local targetPos = self.sprite:getParent():convertToNodeSpace(globalPosition)
            local position = cloned:getPosition()
            local tx, ty = position.x, position.y
            local function onIconScaleFinished()
                cloned:removeFromParentAndCleanup(true)
                self.animNode = nil
            end 
            local function onIconMoveFinished()         
                self.label:setString(tostring(itemNum or 0))
                self.context:playLeafAnimation(true)
                self.context:playLeafAnimation(false)
                self:shakeObject()
                local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                cloned:setOpacity(255)
                cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
            end 
            local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
            local moveOut = CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150))
            cloned:setPosition(targetPos)

            local actions = CCArray:create()
            actions:addObject(CCDelayTime:create(0.6))
            actions:addObject(CCShow:create())
            actions:addObject(moveOut)
            actions:addObject(CCCallFunc:create(onIconMoveFinished))

            cloned:setVisible(false)
            cloned:runAction(CCSequence:create(actions))

            -- cloned:runAction(CCSequence:createWithTwoActions(moveOut, CCCallFunc:create(onIconMoveFinished)))
            self.animNode = cloned
		else
			self.label:setString(tostring(itemNum or 0))
		end
	end
end