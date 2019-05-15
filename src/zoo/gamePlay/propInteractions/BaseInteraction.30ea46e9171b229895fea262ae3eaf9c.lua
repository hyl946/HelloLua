BaseInteractionState = class()
function BaseInteractionState:ctor(name)
    self.name = name
end
BaseInteraction = class()
function BaseInteraction:ctor(boardView, controller)
    self.boardView = boardView
    self.controller = controller
end

function BaseInteraction:onEnter()
    assert(false, 'please implement')
end

function BaseInteraction:onExit()
    assert(false, 'please implement')
end

function BaseInteraction:handleComplete()
    assert(false, 'please implement')
end

function BaseInteraction:setCurrentState(state)
    self.currentState = state
    if isLocalDevelopMode and state.name then
        if _G.isLocalDevelopMode then printx(0, 'in '..state.name) end
    end
end

function BaseInteraction:handleTouchBegin(x, y)
    assert(false, 'please implement')
end

function BaseInteraction:handleTouchMove(x, y)
    assert(false, 'please implement')
end

function BaseInteraction:handleTouchEnd(x, y)
    assert(false, 'please implement')
end

function BaseInteraction.isEqualPos(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y
end
