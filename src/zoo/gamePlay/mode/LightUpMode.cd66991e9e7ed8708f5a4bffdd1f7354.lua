LightUpMode = class(MoveMode)

function LightUpMode:initModeSpecial(config)
  local _tileMap = config.tileMap
  for r = 1, #_tileMap do
    if self.mainLogic.boardmap[r] == nil then self.mainLogic.boardmap[r] = {} end        --地形
    for c = 1, #_tileMap[r] do
      local tileDef = _tileMap[r][c]
      self.mainLogic.boardmap[r][c]:initLightUp(tileDef)              
    end
  end
   _G.TestFlag_lockLightUpLeftCount = false
	self.mainLogic.kLightUpTotal = self:checkAllLightCount()
  self.mainLogic.kLightUpLeftCount = self.mainLogic.kLightUpTotal
end

function LightUpMode:reachEndCondition()
  self.mainLogic.kLightUpLeftCount = self:checkAllLightCount();
  return  MoveMode.reachEndCondition(self) or self.mainLogic.kLightUpLeftCount <= 0
end

function LightUpMode:reachTarget()
  return self.mainLogic.kLightUpLeftCount <= 0
end

----统计所有的冰
function LightUpMode:checkAllLightCount()
  local mainLogic = self.mainLogic
	local countsum = 0
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local board1 = mainLogic.boardmap[r][c]
			if board1.isUsed == true then
				countsum = countsum + board1.iceLevel
			end
		end
	end

  if mainLogic.backBoardMap then
    for r = 1, 9 do
      for c = 1, 9 do
        if mainLogic.backBoardMap[r] then
          local board2 = mainLogic.backBoardMap[r][c]
          if board2 and board2.isUsed == true then
            countsum = countsum + board2.iceLevel
          end
        end
      end
    end
  end
  
  -- --
--
--
--


	--printx( 1 , "   ----------------  checkAllIngredientCount", countsum)
	--debug.debug()
  if _G.TestFlag_lockLightUpLeftCount then
    -- _G.TestFlag_lockLightUpLeftCount = false
    return 0
  end
	return countsum;
end

function LightUpMode:saveDataForRevert(saveRevertData)
  local mainLogic = self.mainLogic
  saveRevertData.kLightUpLeftCount = mainLogic.kLightUpLeftCount
  MoveMode.saveDataForRevert(self,saveRevertData)
end

function LightUpMode:revertDataFromBackProp()
  local mainLogic = self.mainLogic
  mainLogic.kLightUpLeftCount = mainLogic.saveRevertData.kLightUpLeftCount
  MoveMode.revertDataFromBackProp(self)
end

function LightUpMode:revertUIFromBackProp()
  local mainLogic = self.mainLogic
  if mainLogic.PlayUIDelegate then
    mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.kLightUpLeftCount)
  end
  MoveMode.revertUIFromBackProp(self)
end