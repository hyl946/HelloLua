
EndlessTargetItem = class(LevelTargetItem)

function EndlessTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition)
    if not self.sprite.refCocosObj then return end
    if itemNum ~= nil then
        self.itemNum = itemNum

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
            local moveOut = CCSpawn:createWithTwoActions(moveTo, CCSequence:createWithTwoActions(CCFadeIn:create(0.2), CCFadeTo:create(0.3, 150)))
            cloned:setPosition(targetPos)
            cloned:runAction(CCSequence:createWithTwoActions(moveOut, CCCallFunc:create(onIconMoveFinished)))
            self.animNode = cloned
        else
            self.label:setString(tostring(itemNum or 0))
        end
    end
end

