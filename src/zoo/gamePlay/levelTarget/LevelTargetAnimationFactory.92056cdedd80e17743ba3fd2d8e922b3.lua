kLevelTargetType = {
     drop = "drop", 
     dig_move = "dig_move", 
     time = "time", 
     ice = "ice", 
     move = "move",
     order1 = "order1", 
     order2 = "order2", 
     order3 = "order3", 
     order4 = "order4", 
     order5 = "order5", 
     dig_move_endless = "dig_move_endless",
     dig_move_endless_qixi = "dig_move_endless_qixi",
     dig_move_endless_mayday = "dig_move_endless_mayday",            
     rabbit_weekly = "rabbit_weekly",
     summer_weekly = "summer_weekly",
     sea_order = "order6",
     acorn = "acorn",
     hedgehog_endless = "hedgehog_endless",
     wukong = "dig_move_endless_wukong",
     order_lotus = "order_lotus",
     olympic_2016 = "olympic_2016",
     spring_2017 = "spring_2017",
     spring_2018 = "spring_2018",
     moleWeekly = "moleWeekly",
     JamSperad = "JamSperad",
}
-- order1: normal,   order2: single props,     order3: compose props, order4: others{snow, coin}, order5:{balloon, blackCuteBall}
kLevelTargetTypeTexts = {
     drop = "level.target.drop.mode", 
     dig_move = "level.target.dig.step.mode",
     dig_time = "level.target.dig.time.mode",
     dig_move_endless = "level.target.dig.endless.mode",
     time = "level.target.time.mode",
     ice = "level.target.ice.mode",
     move = "level.target.step.mode",
     order1 = "level.target.objective.mode",
     order2 = "level.target.eliminate.effect.mode",
     order3 = "level.target.swap.effect.mode",
     order4 = "level.target.objective.mode",
     order5 = "level.target.other.mode", 
     dig_move_endless_qixi =  "level.target.dig.endless.mode.qixi",
     dig_move_endless_mayday = "level.target.TwoYear",
     rabbit_weekly = "level.target.rabbit.weekly.mode",
     sea_order = "level.target.sea.order.mode",
     acorn = "level.start.drop.key.mode",
     summer_weekly = "2016_weeklyrace.summer.target",
     [kLevelTargetType.wukong] = "level.target.wukong.endless",
     [kLevelTargetType.order_lotus] = "level.start.meadow.mode",
     [kLevelTargetType.olympic_2016] = "activity.level.target.olympic2016",
     [kLevelTargetType.spring_2017] = "2017chunjie.goal",
     [kLevelTargetType.spring_2018] = "level.target.objective.mode",
     [kLevelTargetType.moleWeekly] = "moleWeekly.target",
     [kLevelTargetType.JamSperad] = "JamSperad.target",
}

require "zoo.animation.CountDownAnimation"
require "zoo.panel.component.levelTarget.LevelTargetItem"
require "zoo.panel.component.levelTarget.TimeTargetItem"
require "zoo.panel.component.levelTarget.EndlessMayDayTargetItem"
require "zoo.panel.component.levelTarget.SeaOrderTargetItem"
require "zoo.panel.component.levelTarget.EndlessTargetItem"
require "zoo.panel.component.levelTarget.FillTargetItem"
require "zoo.panel.component.levelTarget.MoleWeeklyTargetItem"
require "zoo.panel.component.levelTarget.ChristmasBellTargetItem"
require "zoo.gamePlay.levelTarget.LevelTargetAnimationOrder"
require "zoo.gamePlay.levelTarget.LevelTargetAnimationTime"
require "zoo.gamePlay.levelTarget.LevelTargetAnimationChildClass"
require "zoo.gamePlay.levelTarget.LevelTargetAnimationMaydayEndless"
require "zoo.panel.component.levelTarget.JamSperadTargetItem"

LevelTargetAnimationFactory = {}
function LevelTargetAnimationFactory:createLevelTargetAnimation( gamePlayType, topX, yDelta, levelType)
     local noBatch = false
     local cls = LevelTargetAnimationOrder
     if levelType == GameLevelType.kSpring2018 then
          cls = LevelTargetAnimationSpring2018
     elseif gamePlayType == GameModeTypeId.CLASSIC_MOVES_ID then
          cls = LevelTargetAnimationMove
     elseif gamePlayType == GameModeTypeId.CLASSIC_ID then
          cls = LevelTargetAnimationTime
     elseif gamePlayType == GameModeTypeId.DROP_DOWN_ID or gamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
          cls = LevelTargetAnimationDrop
     elseif gamePlayType == GameModeTypeId.LIGHT_UP_ID then
          cls = LevelTargetAnimationIce
     elseif gamePlayType == GameModeTypeId.SEA_ORDER_ID then
          cls = LevelTargetAnimationSeaOrder
     elseif gamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID then
          cls = _isQixiLevel and LevelTargetAnimationDigMoveEndlessQixi or LevelTargetAnimationDigMoveEndless
     elseif gamePlayType == GameModeTypeId.DIG_MOVE_ID then
          cls = LevelTargetAnimationDigMove
     elseif gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID then
          noBatch = true
          cls = LevelTargetAnimationMaydayEndless
     elseif gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
          cls = LevelTargetAnimationMoleWeekly
     elseif gamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
          cls = LevelTargetAnimationDigMoveEndless
     elseif gamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
          cls = LevelTargetAnimationHedgehogEndless
     elseif gamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID then
          cls = LevelTargetAnimationWukongEndless
     elseif gamePlayType == GameModeTypeId.LOTUS_ID then
          cls = LevelTargetAnimationLotus
     elseif gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
          cls = LevelTargetAnimationOlympicEndless
     elseif gamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
          cls = LevelTargetAnimationSpringEndless
    -- elseif gamePlayType == GameModeTypeId.JAMSPREAD_ID then
    --       cls = LevelTargetAnimationJamSperad
     end

     assert(cls)
     local ret = cls.new()
     ret:buildLevelTargets(topX, yDelta, noBatch)
     ret:buildLevelPanel()
     return ret
end