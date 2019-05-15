require 'zoo.gamePlay.propInteractions.ForceSwapInteraction'
require 'zoo.gamePlay.propInteractions.NormalSwapInteraction'
require 'zoo.gamePlay.propInteractions.HammerInteraction'
require 'zoo.gamePlay.propInteractions.BrushInteraction'
require 'zoo.gamePlay.propInteractions.RandomBirdInteraction'
require 'zoo.gamePlay.propInteractions.BroomInteraction'
require 'zoo.gamePlay.propInteractions.LineEffectInteraction'

InteractionController = class()

function InteractionController:create(boardView)
    local instance = InteractionController.new(boardView)
    return instance
end

function InteractionController:ctor(boardView)
    self.currentState = nil
    self.boardView = boardView
    self.normalSwapInteraction = NormalSwapInteraction.new(boardView, self)
    self.forceSwapInteraction = ForceSwapInteraction.new(boardView, self)
    self.hammerInteraction = HammerInteraction.new(boardView, self)
    self.brushInteraction = BrushInteraction.new(boardView, self)
    self.randomBirdInteraction = RandomBirdInteraction.new(boardView, self)
    self.broomInteraction = BroomInteraction.new(boardView, self)
    self.lineEffectInteraction = LineEffectInteraction.new(boardView, self)
end

function InteractionController:init()
    if _G.isLocalDevelopMode then printx(0, 'InteractionController:init') end
    self:setInteraction(self.normalSwapInteraction)
end

function InteractionController:onUseProp(propId , usePropType)
    if propId == GamePropsType.kHammer 
        or propId == GamePropsType.kHammer_l 
        or propId == GamePropsType.kHammer_b 
        or propId == GamePropsType.kJamSpeardHummer 
        then
        self:setInteraction(self.hammerInteraction)

    elseif propId == GamePropsType.kSwap 
        or propId == GamePropsType.kSwap_l 
        or propId == GamePropsType.kSwap_b 
        then
        self:setInteraction(self.forceSwapInteraction)

    elseif propId == GamePropsType.kLineBrush 
        or propId == GamePropsType.kLineBrush_l 
        or propId == GamePropsType.kLineBrush_b 
        then
        self:setInteraction(self.brushInteraction)
    elseif propId == GamePropsType.kRandomBird then
        self:setInteraction(self.randomBirdInteraction)

    elseif propId == GamePropsType.kBroom or propId == GamePropsType.kBroom_l then
        self:setInteraction(self.broomInteraction)

    elseif propId == GamePropsType.kRowEffect 
        or propId == GamePropsType.kRowEffect_l 
        or propId == GamePropsType.kColumnEffect 
        or propId == GamePropsType.kColumnEffect_l
        then
        self:setInteraction(self.lineEffectInteraction)
    end
end

function InteractionController:onInteractionComplete(result)
    if self.boardView.gamePropsType == GamePropsType.kHammer 
        or self.boardView.gamePropsType == GamePropsType.kHammer_l 
        or self.boardView.gamePropsType == GamePropsType.kHammer_b  then
        assert(result.itemPos)
        self.boardView:useHammer(result.itemPos)

    elseif self.boardView.gamePropsType == GamePropsType.kSwap 
        or self.boardView.gamePropsType == GamePropsType.kSwap_l 
        or self.boardView.gamePropsType == GamePropsType.kSwap_b  then
        assert(result.item1Pos and result.item2Pos)
        self.boardView:useForceSwap(result.item1Pos, result.item2Pos)

    elseif self.boardView.gamePropsType == GamePropsType.kLineBrush 
        or self.boardView.gamePropsType == GamePropsType.kLineBrush_l 
        or self.boardView.gamePropsType == GamePropsType.kLineBrush_b  then
        assert(result.itemPos and result.direction)
        self.boardView:useBrush(result.itemPos, result.direction)

    elseif self.boardView.gamePropsType == GamePropsType.kRandomBird then
        self.boardView:useRandomBird() 

    elseif self.boardView.gamePropsType == GamePropsType.kBroom or self.boardView.gamePropsType == GamePropsType.kBroom_l then
        self.boardView:useBroom(result.itemPos)
    elseif self.boardView.gamePropsType == GamePropsType.kHedgehogCrazy then
        self.boardView:useHedgehogCrazy(result.item1Pos)
    elseif self.boardView.gamePropsType == GamePropsType.kWukongJump then
        self.boardView:useWukongJump(result.item1Pos)
    elseif self.boardView.gamePropsType == GamePropsType.kNone then
        assert(result.item1Pos and result.item2Pos)
        self.boardView:trySwapItem(result.item1Pos.x, result.item1Pos.y, result.item2Pos.x, result.item2Pos.y)
    elseif self.boardView.gamePropsType == GamePropsType.kJamSpeardHummer then
        assert(result.itemPos)
        self.boardView:useJamSpeardHammer(result.itemPos)
    elseif self.boardView.gamePropsType == GamePropsType.kRowEffect 
        or self.boardView.gamePropsType == GamePropsType.kRowEffect_l 
        or self.boardView.gamePropsType == GamePropsType.kColumnEffect 
        or self.boardView.gamePropsType == GamePropsType.kColumnEffect_l
        then
        self.boardView:useLineEffectProps(result.itemPos, isColumn)
    end
    self:setInteraction(self.normalSwapInteraction)
end

function InteractionController:onCancelUsingProp()
    if _G.isLocalDevelopMode then printx(0, 'onCancelUsingProp') end
    self:setInteraction(self.normalSwapInteraction)
end

function InteractionController:setInteraction(interaction)
    if self.currentState then
        self.currentState:onExit()
    end
    self.currentState = interaction
    if self.currentState then
        self.currentState:onEnter()
    end
end

function InteractionController:getCurrentInteraction()
    return self.currentState
end

function InteractionController:dispose()
    self.normalSwapInteraction = nil
    self.forceSwapInteraction = nil
    self.hammerInteraction = nil
    self.brushInteraction = nil
    self.lineEffectInteraction = nil
    self.boardView = nil
    self.currentState = nil
end