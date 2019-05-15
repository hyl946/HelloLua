
NeedRefreshState = class(BaseStableState)

function NeedRefreshState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function NeedRefreshState:create(context)
	local v = NeedRefreshState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function NeedRefreshState:onEnter()
	BaseStableState.onEnter(self)

	self.nextState = nil
	self.refreshCounterToHandle = 0
	self:tryRefresh()
end

function NeedRefreshState:tryRefresh()
	local needRefresh = RefreshItemLogic:checkNeedRefresh(self.mainLogic)
	local mainLogic = self.mainLogic
	local context = self
	local hasRefreshed = false
	local function refreshComplete()
		if hasRefreshed then 
			mainLogic:setNeedCheckFalling()
			self.nextState = self.context.dripCastingStateInLoop
		else
			context:refreshComplete()
		end
	end
	local function doRefresh()
		hasRefreshed = true
		context.refreshTotalToHandle = RefreshItemLogic:runRefreshAction(mainLogic, false, refreshComplete) 						
	end

	local roostList = GameExtandPlayLogic:filterItemByConditions(mainLogic, { gameItemTypeList = { GameItemType.kRoost } })
	if roostList then
		for i, roost in ipairs(roostList) do
			roost.roostCastCount = 0
		end
	end
	
	if needRefresh then
		if RefreshItemLogic.tryRefresh(self.mainLogic) then
			if self.mainLogic.PlayUIDelegate then
				local winSize = CCDirector:sharedDirector():getWinSize()
				local panel = CommonEffect:buildRequireSwipePanel()
				panel:setPosition(ccp(winSize.width/2, winSize.height/2))
				self.mainLogic.PlayUIDelegate.effectLayer:addChild(panel)
				self.mainLogic.PlayUIDelegate.effectLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(doRefresh)))
			else
				self.mainLogic.boardView:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(doRefresh)))
			end
		else 
			local gameMode = self.mainLogic.gameMode
			-- 仅仅在没有达到胜利条件时才失败
			-- 如果玩家已经达到条件，则不做，于是玩家就会通关
			if gameMode and gameMode:failByRefresh() then
				self.mainLogic.gameMode:setFailReason('refresh')
				self.mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
			else
				self.mainLogic.gameMode.refreshFailedDirectSuccess = true
				self.mainLogic:refreshComplete()
			end
		end
	else
		-- self.mainLogic:refreshComplete()
		
		-- self.mainLogic:setNeedCheckFalling()
		self.nextState = self.context.actCollectionState
	end
end

function NeedRefreshState:refreshComplete()
	if type(self.refreshCounterToHandle) == "number" then
		self.refreshCounterToHandle = self.refreshCounterToHandle + 1
	end

	if self.refreshCounterToHandle >= self.refreshTotalToHandle then
		self.mainLogic:refreshComplete()
	end
end

function NeedRefreshState:onExit()
	BaseStableState.onExit(self)

	self.nextState = nil
	self.refreshCounterToHandle = 0
	self.refreshTotalToHandle = 0
end

function NeedRefreshState:checkTransition()
	return self.nextState
end

function NeedRefreshState:getClassName()
	return "NeedRefreshState"
end