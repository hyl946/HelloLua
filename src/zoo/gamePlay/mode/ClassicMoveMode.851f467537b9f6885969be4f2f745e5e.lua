ClassicMoveMode = class(MoveMode)

function ClassicMoveMode:reachEndCondition()
  return  MoveMode.reachEndCondition(self) or self:getScoreStarLevel() >= 3
end
