ElephantBossState = class(BaseStableState)

function ElephantBossState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function ElephantBossState:create(context)
    local v = ElephantBossState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ElephantBossState:useFireWorkProp()
    BombItemLogic:springFestivalBombScreen(self.mainLogic)
    self.mainLogic:setNeedCheckFalling()
end

function ElephantBossState:onEnter()

    self.hasItemToHandle = false
    self.nextState = nil
    BaseStableState.onEnter(self)

    local function forceUseCallback()
    	self.nextState = self:getNextState()
        self:useFireWorkProp()
    	--self.mainLogic:setNeedCheckFalling()
    end

    if self.mainLogic.PlayUIDelegate and self.mainLogic.gameMode:is(MaydayEndlessMode) then
		if self.mainLogic.isFullFirework then
            local winSize = Director:sharedDirector():getWinSize()
            local propList =  self.mainLogic.PlayUIDelegate.propList

            local pos = propList:getSpringItemGlobalPosition()
            local hasGuide = GameGuide:sharedInstance():onShowForceUse(pos)
            
            local function forceUse()
                local scene = Director:sharedDirector():getRunningScene()
                if scene:is(GamePlaySceneUI) or scene:is(EditorGameScene) then
                    if GameGuide:sharedInstance():getHasCurrentGuide() then
                        GameGuide:sharedInstance():onGuideComplete()
                    end
                    self.mainLogic.PlayUIDelegate.propList:forceUseSpringItem(forceUseCallback)
                end
            end

            if hasGuide then
                setTimeOut(forceUse, 3)
            else
                forceUse()
            end

            -- local icon = propList:findSpringItemIcon()
            -- if icon then
            --     local worldPoint = icon:convertToWorldSpace(ccp(0, icon:getGroupBounds().size.height))
            --                         --updated the worldPoint
            --     worldPoint = icon:convertToWorldSpace(ccp(icon:getGroupBounds().size.width, icon:getGroupBounds().size.height))

            --     self:playTips(function()
            --         propList:forceUseSpringItem(forceUseCallback)
            --     end, worldPoint)


            --     if _G.isLocalDevelopMode then printx(0, "offset: ", worldPoint.x - winSize.width/2) end
            --     --move the icon to the center of the screen
            --     -- local moveAct = CCMoveBy:create(0.3, ccp(winSize.width/2-worldPoint.x, 0))
            --     -- local complete = CCCallFunc:create(function()

            --     --     --updated the worldPoint
            --     --     worldPoint = icon:convertToWorldSpace(ccp(icon:getGroupBounds().size.width, icon:getGroupBounds().size.height))

            --     --     self:playTips(function()
            --     --         propList:forceUseSpringItem(forceUseCallback)
            --     --     end, worldPoint)

            --     --  end)
            --     -- propList.content:runAction(CCSequence:createWithTwoActions(moveAct, complete))
            --     --propList.content:setPositionXY(propList.content:getPositionX() +  winSize.width/2-worldPoint.x, propList.content:getPositionY())
            -- end
		else
			self:handleComplete()
		end
	else
		self:handleComplete()
	end
end

function ElephantBossState:playTips(completeCallback, worldPoint)
    local winSize = Director:sharedDirector():getWinSize()
    local scene = Director:sharedDirector():getRunningScene()
    --local tip = CocosObject:create()

    -- local tipPanel = GameGuideUI:panelMini("tutorial.game.text230005")
    local tipPanel = GameGuideUI:panelMini("tutorial.game.text230010")
    tipPanel:setPositionXY((winSize.width - tipPanel:getGroupBounds().size.width)/2, tipPanel:getGroupBounds().size.height*2+30)
    scene:addChild(tipPanel)

    local armature = CommonSkeletonAnimation:createTutorialMoveIn2()

    armature:setScale(0.65)
    armature:setPositionXY(worldPoint.x, worldPoint.y)
    scene:addChild(armature)

    setTimeOut(function()
            armature:removeFromParentAndCleanup(true)
            tipPanel:removeFromParentAndCleanup(true)
            if completeCallback then
                completeCallback()
            end
        end, 3)
end

function ElephantBossState:handleComplete()
    self.nextState = self:getNextState()
    self.context:onEnter()
end

function ElephantBossState:getNextState()
    return self.context.hedgehogCrazyInBonus
end

function ElephantBossState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.bossHandled = false
    self.hasItemToHandle = false
end

function ElephantBossState:checkTransition()
    return self.nextState
end

function ElephantBossState:getClassName()
    return "ElephantBossState"
end