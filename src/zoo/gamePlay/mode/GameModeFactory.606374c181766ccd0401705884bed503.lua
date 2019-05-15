require "zoo.gamePlay.mode.GameMode"
require "zoo.gamePlay.mode.MoveMode"
require "zoo.gamePlay.mode.ClassicMoveMode"
require "zoo.gamePlay.mode.DigMoveMode"
require "zoo.gamePlay.mode.DropDownMode"
require "zoo.gamePlay.mode.LightUpMode"
require "zoo.gamePlay.mode.OrderMode"
require "zoo.gamePlay.mode.ClassicMode"
require "zoo.gamePlay.mode.DigTimeMode"
require "zoo.gamePlay.mode.DigMoveEndlessMode"
require "zoo.gamePlay.mode.MaydayEndlessMode"
require "zoo.gamePlay.mode.RabbitWeeklyMode"
require "zoo.gamePlay.mode.SeaOrderMode"
require "zoo.gamePlay.mode.MoleWeeklyRaceMode"
require "zoo.gamePlay.mode.WukongMode"
require "zoo.gamePlay.mode.UnlockAreaDropDownMode"
require "zoo.gamePlay.mode.HedgehogDigEndlessMode"
require "zoo.gamePlay.mode.LotusMode"
require "zoo.gamePlay.mode.OlympicHorizontalEndlessMode"
require "zoo.gamePlay.mode.SpringHorizontalEndlessMode"
require "zoo.gamePlay.mode.JamSperadMode"

GameModeFactory = class()

function GameModeFactory:create(mainLogic)
    if _G.isLocalDevelopMode then printx(0, 'mainLogic.theGamePlayType **************', mainLogic.theGamePlayType) end
    local gameMode = mainLogic.theGamePlayType
    if gameMode == GameModeTypeId.CLASSIC_MOVES_ID then		----步数模式==========
        return ClassicMoveMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.DROP_DOWN_ID then		----掉落模式==========
        return DropDownMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.LIGHT_UP_ID then			----冰层消除模式======
        return LightUpMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.DIG_MOVE_ID then			----步数挖地模式======	
        return DigMoveMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.ORDER_ID then  			----订单模式
        return OrderMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.DIG_TIME_ID then     ----时间挖地模式
        return DigTimeMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.CLASSIC_ID then     ----时间模式
        return ClassicMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.DIG_MOVE_ENDLESS_ID then ----无限挖地模式
        return DigMoveEndlessMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.MAYDAY_ENDLESS_ID then
        return MaydayEndlessMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.RABBIT_WEEKLY_ID then
        return RabbitWeeklyMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.SEA_ORDER_ID then
        return SeaOrderMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
        return MoleWeeklyRaceMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
        return UnlockAreaDropDownMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
        return HedgehogDigEndlessMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.WUKONG_DIG_ENDLESS_ID then
        return WukongMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.LOTUS_ID then
        return LotusMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
        return OlympicHorizontalEndlessMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
        return SpringHorizontalEndlessMode.new(mainLogic)
    elseif gameMode == GameModeTypeId.JAMSPREAD_ID then
        return JamSperadMode.new(mainLogic)
    else
        return GameMode.new(mainLogic)
    end
end