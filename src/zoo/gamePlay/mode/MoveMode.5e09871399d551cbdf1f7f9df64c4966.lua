require "zoo.util.FUUUManager"

MoveMode = class(GameMode)

function MoveMode:update(dt)
  if self.mainLogic.isGamePaused == false then 
    -- self.mainLogic.timeTotalUsed = self.mainLogic.timeTotalUsed + dt;

    local t = HeTimeUtil:getCurrentTimeMillis() / 1000
    if not self._dt then self._dt = t end
    local passTime = t - self._dt
    self.mainLogic.timeTotalUsed = self.mainLogic.timeTotalUsed + passTime
    self._dt = t
    -- printx(1 , _dt , self.mainLogic.timeTotalUsed ,  math.random() )
  end
end

function MoveMode:reachEndCondition()
  return  self.mainLogic.theCurMoves <= 0
end

function MoveMode:afterFail()
  --FUUUManager:update(self)
  if self.mainLogic.theCurMoves > 0 and self.mainLogic.isUFOWin then
    GameExtandPlayLogic:showUFOReveivePanel(self, false)
  else
    GameExtandPlayLogic:showAddStepPanel(self)
  end
end

function MoveMode:getAddSteps(count)
  local mainLogic = self.mainLogic;
  mainLogic.hasAddMoveStep = { source = "tryAgainWhenFailed" , steps = count }
	mainLogic.theCurMoves = mainLogic.theCurMoves + count
	if mainLogic.PlayUIDelegate then
    mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
	end
  setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd5stepFlyon ) end , 0.15 )
end

function MoveMode:useMove()
  local mainLogic = self.mainLogic;
	mainLogic.theCurMoves = mainLogic.theCurMoves - 1;
  if mainLogic.PlayUIDelegate then --------调用UI界面函数显示移动步数
    mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
	end

    SpringFestival2019Manager.getInstance():setUseMove()
end