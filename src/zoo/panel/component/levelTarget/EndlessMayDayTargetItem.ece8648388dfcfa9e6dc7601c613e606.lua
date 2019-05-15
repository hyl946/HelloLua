require "zoo.panel.component.levelTarget.LevelTargetItem"


EndlessMayDayTargetItem = class(LevelTargetItem)

function EndlessMayDayTargetItem:setTargetNumber(itemId, itemNum, animate, globalPosition )
    if not self.sprite.refCocosObj then return end
    if itemNum ~= nil then
        -- 防止数字回滚
        -- 前提：反正该模式下，数字是单向增加的
        if itemNum >= self.itemNum then
            self.itemNum = itemNum
        end

        if animate and globalPosition and self.icon then
            local cloned = self.icon:clone(true)
            -- local targetPos = self:convertToNodeSpace(globalPosition)
            local targetPos = self.sprite:getParent():convertToNodeSpace(globalPosition)
            local position = cloned:getPosition()
            local tx, ty = position.x - 20, position.y + 15
            local function onIconScaleFinished()
                cloned:removeFromParentAndCleanup(true)
                self.animNode = nil
            end 
            local function onIconMoveFinished()         
                self.label:setString(tostring(self.itemNum or 0))
                self.context:playLeafAnimation(true)
                self.context:playLeafAnimation(false)
                self:shakeObject()
                local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                cloned:setOpacity(255)
                cloned:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
            end 
            local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
            local array = CCArray:create()

            if itemId == 1 then
            	cloned:setScale(0.3)
            	local scale_action = CCScaleTo:create(0.3, 1.5)
            	local index_x = math.random()
            	local index_y = math.random()
            	local jump_action = CCJumpBy:create(0.5, ccp(index_x * 2 * GamePlayConfig_Tile_Width, -index_y * 2* GamePlayConfig_Tile_Width), (1 + index_y) * GamePlayConfig_Tile_Width, 1)
            	array:addObject(CCSpawn:createWithTwoActions(scale_action, jump_action))
            	array:addObject(CCDelayTime:create(index_y))
            end
            array:addObject(CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150)))
            array:addObject(CCCallFunc:create(onIconMoveFinished))
            cloned:setPosition(targetPos)
            cloned:runAction(CCSequence:create(array))
            self.animNode = cloned
        else
            self.label:setString(tostring(itemNum or 0))
        end
    end
end

function EndlessMayDayTargetItem:onTouchBegin(evt)
end

function EndlessMayDayTargetItem:shakeObject( ... )
    LevelTargetItem.shakeObject(self, ...)
    if self.shakeExtraDelegate then
        self.shakeExtraDelegate()
    end
end

--收集物飞到目标处后 执行一些额外的动作
function EndlessMayDayTargetItem:setShakeExtraDelegate( delegate )
    self.shakeExtraDelegate = delegate
end