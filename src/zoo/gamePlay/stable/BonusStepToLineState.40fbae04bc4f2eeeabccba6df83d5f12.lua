
BonusStepToLineState = class(BaseStableState)

function BonusStepToLineState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function BonusStepToLineState:create(context)
	local v = BonusStepToLineState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BonusStepToLineState:onEnter()
	BaseStableState.onEnter(self)

	self.nextState = nil
	self.timeCount = 0

	if self.mainLogic.gameMode:canChangeMoveToStripe() then
		BombItemLogic:initRandomAnimalChangeList(self.mainLogic)					----初始化随机列表
		self.numStepToLine = math.min(#self.mainLogic.randomAnimalHelpList, self.mainLogic.theCurMoves)
        
        if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
            SpringFestival2019Manager.getInstance():initFlyPigLeftNum( self.mainLogic.theCurMoves )
        end

		if self.numStepToLine > 0 then
			self.hasItemToHandle = true
		else
			-- self.nextState = self.context.gameOverState
			self.nextState = self.context.moleWeeklyBossStateInBonus
		end
	else
		-- self.nextState = self.context.gameOverState
		self.nextState = self.context.moleWeeklyBossStateInBonus
	end
end

function BonusStepToLineState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
end

function BonusStepToLineState:update(dt)
	if not self.hasItemToHandle then return end
	self.timeCount = self.timeCount + 1
	local mainLogic = self.mainLogic
	if self.timeCount > GamePlayConfig_BonusTime_ItemFlying_CD then
		self.timeCount = 0
		local pos = nil						----随机到一个需要变成特效的东西
		if mainLogic.theCurMoves > 0 then 															----每次随机一个特效，减少一个步数
			pos = BombItemLogic:getRandomAnimalChangeToLineSpecial(mainLogic)		
			mainLogic.theCurMoves = mainLogic.theCurMoves - 1 
			if mainLogic.PlayUIDelegate then --------调用UI界面函数显示移动步数
				mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, true, true)
			end
		else
			pos = nil
		end
		if pos then
			local specialTypes = { AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn }
			local specialType = specialTypes[mainLogic.randFactory:rand(1, 2)]

			if mainLogic.PlayUIDelegate then
				local theAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kBonus_Step_To_Line,
					pos, nil, GamePlayConfig_MaxAction_time)
				theAction.addInt = specialType
				theAction.completeCallback = function()
					self.numStepToLine = self.numStepToLine - 1

					if self.addInfo == "flyend" and self.numStepToLine == 0 then
						self.nextState = self.context.bonusLastBombState
						self.context:onEnter()
					end
				end
				mainLogic:addGameAction(theAction)
			else
				mainLogic.gameItemMap[pos.x][pos.y]:changeItemType(mainLogic.gameItemMap[pos.x][pos.y]._encrypt.ItemColorType, specialType)
			end
		else
			self.addInfo = "flyend"
			if mainLogic.theCurMoves > 0 then
				if mainLogic.PlayUIDelegate then 
					mainLogic.theCurMoves = 0
					mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(0, true, true)
				end
			end
			if self.numStepToLine == 0 then
				self.nextState = self.context.bonusLastBombState
				self.context:onEnter()
			end
		end
	end
end

function BonusStepToLineState:checkTransition()
	return self.nextState
end

function BonusStepToLineState:getClassName( ... )
	-- body
	return "BonusStepToLineState"
end
