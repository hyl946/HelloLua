
WeeklyPassFriendState = class(BaseStableState)

function WeeklyPassFriendState:create(context)
    local v = WeeklyPassFriendState.new()
    v.context = context
    v.mainLogic = context.mainLogic 
    v.boardView = v.mainLogic.boardView
    return v
end

function WeeklyPassFriendState:update()
end

function WeeklyPassFriendState:onEnter()
    printx( -1 , "---->>>> WeeklyPassFriendState enter")
    self.nextState = nil
    local function callback()
        printx( -1 , 'WeeklyPassFriendState-->MOVE COMPLEPTE')
        self:handleComplete()
    end
    if self.mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID and self.mainLogic.theGamePlayStatus ~= GamePlayStatus.kBonus then 
	    local gamePlaySceneUI = self.mainLogic.PlayUIDelegate
	    if gamePlaySceneUI then 
	    	local levelTargetPanel = gamePlaySceneUI.levelTargetPanel
	    	if levelTargetPanel then 
	    		return levelTargetPanel:handlePassFriendTarget(callback)
	    	end
	    end
	end
    return false
end

function WeeklyPassFriendState:handleComplete()
    self.mainLogic:setNeedCheckFalling()
end

function WeeklyPassFriendState:onExit()
    printx( -1 , "----<<<< WeeklyPassFriendState exit")
    self.nextState = nil
end

function WeeklyPassFriendState:checkTransition()
    printx( -1 , "-------------------------WeeklyPassFriendState checkTransition")
    return self.nextState
end
