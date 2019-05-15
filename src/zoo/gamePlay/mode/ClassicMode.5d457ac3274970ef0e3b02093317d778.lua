ClassicMode = class(GameMode)

function ClassicMode:initModeSpecial(config)
  self.mainLogic.timeTotalLimit = config.timeLimit;
end

function ClassicMode:update(dt)

  local curScene = Director:sharedDirector():getRunningScene()
  if curScene and not curScene:is(GamePlaySceneUI) then
    return
  end

  local mainLogic = self.mainLogic
  if mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then
    if mainLogic.isGamePaused == false then 
      if mainLogic.timeTotalLimit > 0 then
        local totalTime = mainLogic:getTotalLimitTime()
        if mainLogic.timeTotalUsed >= totalTime then
          return
        end

        mainLogic.timeTotalUsed = mainLogic.timeTotalUsed + dt;
        local timeleft = totalTime - mainLogic.timeTotalUsed
        if timeleft <= 0 then timeleft = 0 end -- 修正-0的结果

        if timeleft <= 0 and mainLogic.flyingAddTime <= 0 then
          if mainLogic.isWaitingOperation then
            mainLogic:setGamePlayStatus(GamePlayStatus.kEnd)
          end
        end

        timeleft = math.ceil(timeleft) 
        if not self.lastTimeLeft or self.lastTimeLeft ~= timeleft then
          if mainLogic.PlayUIDelegate then
            mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(timeleft, false)
          end
          self.lastTimeLeft = timeleft
        end
      end
    end
  end
end

function ClassicMode:reachEndCondition()
  local mainLogic = self.mainLogic
  return  mainLogic.timeTotalUsed >= mainLogic:getTotalLimitTime() and mainLogic.flyingAddTime <= 0
end
--[[
function ClassicMode:reachTarget()
  return true
end
]]--

function ClassicMode:canChangeMoveToStripe()
  return false
end

function ClassicMode:revertUIFromBackProp()
  local mainLogic = self.mainLogic
  if mainLogic.PlayUIDelegate then
    mainLogic.PlayUIDelegate.scoreProgressBar:revertScoreTo(mainLogic.totalScore)
  end
end

function ClassicMode:afterFail()
  --FUUUManager:update(self)
  GameExtandPlayLogic:showAddTimePanel(self)
end

function ClassicMode:addTime(addTime)
  local mainLogic = self.mainLogic
  mainLogic:addExtraTime(addTime)
  if mainLogic.PlayUIDelegate then
    local timeleft = mainLogic:getTotalLimitTime() - mainLogic.timeTotalUsed
    if timeleft <= 0 then timeleft = 0 end
    mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(math.ceil(timeleft), false)
  end
end