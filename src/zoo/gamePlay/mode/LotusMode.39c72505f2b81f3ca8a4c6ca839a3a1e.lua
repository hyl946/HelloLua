LotusMode = class(MoveMode)

function LotusMode:initModeSpecial(config)
	printx( 1 , "    LotusMode:initModeSpecial     111111111111111111111111111111111111111111111111111111111111111111111111")
	self.mainLogic.currLotusNum = self:checkAllLotusCount()
	self.mainLogic.initLotusNum = self.mainLogic.currLotusNum
end

function LotusMode:reachEndCondition()
  self.mainLogic.currLotusNum = self:checkAllLotusCount();
  return  MoveMode.reachEndCondition(self) or self.mainLogic.currLotusNum <= 0
end

function LotusMode:reachTarget()
  return self.mainLogic.currLotusNum <= 0
end

----统计所有的冰
function LotusMode:checkAllLotusCount()
  local mainLogic = self.mainLogic
	local countsum = 0
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local board1 = mainLogic.boardmap[r][c]
			if board1.isUsed == true and board1.lotusLevel > 0 then
				countsum = countsum + 1
			end
		end
	end

	for r = 1, 9 do
		if mainLogic.backBoardMap[r] then
			for c = 1, 9 do
				local board1 = mainLogic.backBoardMap[r][c]
				if board1 and board1.isUsed == true and board1.lotusLevel > 0 then
					countsum = countsum + 1
				end
			end
		end
	end
	-- --
--
--
--

	--if _G.isLocalDevelopMode then printx(0, "checkAllIngredientCount", countsum) end
	--debug.debug()
	printx( 1 , "    LotusMode:checkAllLotusCount()     " , countsum)
	return countsum;
end

function LotusMode:saveDataForRevert(saveRevertData)
  local mainLogic = self.mainLogic
  saveRevertData.currLotusNum = mainLogic.currLotusNum
  saveRevertData.lotusEliminationNum = mainLogic.lotusEliminationNum
  saveRevertData.lotusPrevStepEliminationNum = mainLogic.lotusPrevStepEliminationNum
  MoveMode.saveDataForRevert(self,saveRevertData)
end

function LotusMode:revertDataFromBackProp()
  local mainLogic = self.mainLogic
  mainLogic.currLotusNum = mainLogic.saveRevertData.currLotusNum
  mainLogic.lotusEliminationNum = mainLogic.saveRevertData.lotusEliminationNum
  mainLogic.lotusPrevStepEliminationNum = mainLogic.saveRevertData.lotusPrevStepEliminationNum
  MoveMode.revertDataFromBackProp(self)
end

function LotusMode:revertUIFromBackProp()
  local mainLogic = self.mainLogic
  if mainLogic.PlayUIDelegate then
    mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.currLotusNum)
  end
  MoveMode.revertUIFromBackProp(self)
end