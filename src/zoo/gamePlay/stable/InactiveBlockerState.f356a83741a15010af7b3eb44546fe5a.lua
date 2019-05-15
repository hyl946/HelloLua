
InactiveBlockerState = class(BaseStableState)

SpecialHandlerCompleteFlag = table.const
{
	kCrystal = 0,
	kVenom = 1,
	kFurballSplit = 2,
}

function InactiveBlockerState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function InactiveBlockerState:create(context)
	local v = InactiveBlockerState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView

	v.secondPrioritySpecialFlags = { 
		SpecialHandlerCompleteFlag.kCrystal, 
		SpecialHandlerCompleteFlag.kVenom, 
	}
	return v
end

function InactiveBlockerState:update(dt)
	
end

function InactiveBlockerState:onEnter()
	BaseStableState.onEnter(self)

	self.nextState = nil

	self.typeBlockerCompleteFlag = 0
	self.hasItemToHandle = false
	self.venomToHandleCount = 0

	self.counterCrystalToHandle = 0
	self.totalCrystalToHandle = 0

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kCrystal]]) then
        printx(0, '!skip')
		self:handleCrystalInStepComplete()
		self:tryHandleVenom()
        return
    end

	self:tryHandleCrystal()
	self:tryHandleVenom()
end

function InactiveBlockerState:tryHandleCrystal()
	local context = self
	local function crystalCompelte()
		self:handleCrystalInStepComplete()
	end
	self.totalCrystalToHandle = GameExtandPlayLogic:checkCrystalChangeColor(self.mainLogic, crystalCompelte)
	if self.totalCrystalToHandle == 0 then 
		self:handleCrystalInStepComplete()
	else
		self.hasItemToHandle = true
	end
end

function InactiveBlockerState:handleCrystalInStepComplete()
	self.counterCrystalToHandle = self.counterCrystalToHandle + 1
	if self.counterCrystalToHandle >= self.totalCrystalToHandle then
		-- if _G.isLocalDevelopMode then printx(0, "-----------------------------crystall handle complete") end
		self:checkAllTypeBlocker(SpecialHandlerCompleteFlag.kCrystal)
	end
end

function InactiveBlockerState:tryHandleVenom()
	if self.mainLogic.octopusWait and self.mainLogic.octopusWait > 0 then
		if self.mainLogic.PlayUIDelegate then
			self.mainLogic.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid,3, false)
		end
		self.mainLogic.octopusWait = self.mainLogic.octopusWait - 1
	else
		if self.mainLogic.PlayUIDelegate then
			self.mainLogic.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid,nil, true)
		end
	end

	local forbiddenOctopuses = self.mainLogic:getForbiddenOctopus()
	if #forbiddenOctopuses > 0 then
		self:changeOctopusForbiddenLevel(forbiddenOctopuses)
		-- return -- 由于无敌毛球能使章鱼和毒液失效，章鱼冰可能不会同时被消除，需要计算是否能传染
	end
	self.venomToHandleCount = self.venomToHandleCount + 1
	if self.mainLogic.isVenomDestroyedInStep then
		self:handleVenomInStepComplete()
		return
	end

	local context = self
	local function venomComplete()
		context:handleVenomInStepComplete()
	end
	local hasVenomToHandle = GameExtandPlayLogic:checkVenomSpread(self.mainLogic, venomComplete)
	
	if not hasVenomToHandle then
		self:handleVenomInStepComplete()
	else
		self.hasItemToHandle = true
	end
end

function InactiveBlockerState:handleVenomInStepComplete()
	self.venomToHandleCount = self.venomToHandleCount - 1
	-- if _G.isLocalDevelopMode then printx(0, "-----------------------------venom handle complete", self.venomToHandleCount) end
	if self.venomToHandleCount <= 0 then
		self:checkAllTypeBlocker(SpecialHandlerCompleteFlag.kVenom)
	end
end

function InactiveBlockerState:checkAllTypeBlocker(flag)
	local bit = require("bit")
	self.typeBlockerCompleteFlag = bit.bor(self.typeBlockerCompleteFlag, bit.lshift(1, flag))

	local allHandled = true
	for i,v in ipairs(self.secondPrioritySpecialFlags) do
		if bit.band(self.typeBlockerCompleteFlag, bit.lshift(1, v)) == 0 then
			allHandled = false
		end
	end

	if allHandled then
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.context:onEnter()
		end
	end
end

function InactiveBlockerState:getNextState()
	return self.context.lotusUpdateState
	--return self.context.sandTransferState

end

function InactiveBlockerState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil

	self.typeBlockerCompleteFlag = 0
	self.hasItemToHandle = false

	self.counterCrystalToHandle = 0
	self.totalCrystalToHandle = 0

	self.totalFurballSplitToHandle = 0
	self.counterFurballSplitToHandle = 0
end

function InactiveBlockerState:checkTransition()
	return self.nextState
end

function InactiveBlockerState:changeOctopusForbiddenLevel(forbiddenOctopuses)
	if type(forbiddenOctopuses) ~= 'table' then return end
	self.venomToHandleCount = self.venomToHandleCount + 1
	local count = 0
	local function callback()
		count = count + 1
		if count >= #forbiddenOctopuses then
			self.hasItemToHandle = true
			self:handleVenomInStepComplete()
		end
	end

	for k, v in pairs(forbiddenOctopuses) do 
		if v.forbiddenLevel > 0 then
			if v.blockerCoverLevel == 0 and not v.isColorFilterBCover then
				local r, c = v.y, v.x
				local action = GameBoardActionDataSet:createAs(
				                   GameActionTargetType.kGameItemAction,
				                   GameItemActionType.kOctopus_Change_Forbidden_Level,
				                   IntCoord:create(c, r),
				                   nil,
				                   GamePlayConfig_MaxAction_time)
				action.level = v.forbiddenLevel - 1
				action.completeCallback = callback
		        self.mainLogic:addGameAction(action)
			else
				callback()
			end
			
	    end
	end

end

function InactiveBlockerState:getClassName()
	return "InactiveBlockerState"
end