require 'zoo.gamePlay.trigger.TriggerHandler'

GamePlayEventTrigger = class()


function GamePlayEventTrigger:create()
    local _instance = GamePlayEventTrigger.new()
    _instance:init()
    return _instance
end

function GamePlayEventTrigger:ctor()
    self.handlers = {}
end

function GamePlayEventTrigger:init()
    self:registerHandler(VenomTargetHightlightHandler.new())
end

function GamePlayEventTrigger:chechMatch(mainLogic)
    for k, v in pairs(self.handlers) do 
        v:handle(mainLogic, v:tryMatch(mainLogic))
    end
end

function GamePlayEventTrigger:registerHandler(handler)
    self.handlers[handler] = handler
end