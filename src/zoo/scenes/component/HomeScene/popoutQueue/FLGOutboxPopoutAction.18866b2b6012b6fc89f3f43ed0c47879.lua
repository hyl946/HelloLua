FLGOutboxPopoutAction = class(HomeScenePopoutAction)

function FLGOutboxPopoutAction:ctor()
	self.name = "FLGOutboxPopoutAction"
    self:setSource(AutoPopoutSource.kSceneEnter
    	,AutoPopoutSource.kEnterForeground
    	,AutoPopoutSource.kInitEnter
    	,AutoPopoutSource.kTriggerPop
    	,AutoPopoutSource.kGamePlayQuit
    )
end

function FLGOutboxPopoutAction:checkCanPop()
    if self.debug then
        return self:onCheckPopResult(true)
    end
	local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
	self:onCheckPopResult(FLGLogic:canSend())
end

function FLGOutboxPopoutAction:popout(next_action)
	local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
	FLGLogic:popoutOutbox(next_action)
end