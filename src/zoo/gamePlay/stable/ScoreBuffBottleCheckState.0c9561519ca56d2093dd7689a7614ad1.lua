ScoreBuffBottleCheckState = class()

function ScoreBuffBottleCheckState:create( context )
	local v = ScoreBuffBottleCheckState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function ScoreBuffBottleCheckState:update( ... )
end

function ScoreBuffBottleCheckState:check()
	local function callback( ... )
		self:handScoreBuffBottleBlastComplete()
	end

	if not ScoreBuffBottleLogic:needCheckScoreBuffBottle(self.mainLogic) then return 0 end

	self.hasItemToHandle = false
	-- self.completeItem = 0
	local allBottles = ScoreBuffBottleLogic:getAllToBlastScoreBuffBottleOnBoard(self.mainLogic)

	if #allBottles > 0 then
		self.hasItemToHandle = true
		self:handleBottleBlast(allBottles)
	else
		self:handScoreBuffBottleBlastComplete()
	end

	return #allBottles
end

function ScoreBuffBottleCheckState:handScoreBuffBottleBlastComplete( ... )
	-- self.completeItem = self.completeItem + 1 
	-- if self.completeItem >= self.totalItem then 
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling()
		end
	-- end
end

function ScoreBuffBottleCheckState:handleBottleBlast(allBottles)
	local function blastCallback( ... )
		self:handScoreBuffBottleBlastComplete()
	end

	local action =  GameBoardActionDataSet:createAs(
        GameActionTargetType.kGameItemAction,
        GameItemActionType.kItem_ScoreBuffBottle_Blast,
        nil,
        nil,
        GamePlayConfig_MaxAction_time)
    action.targetItems = allBottles
    action.completeCallback = blastCallback
    self.mainLogic:addGlobalCoreAction(action)
end

