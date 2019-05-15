FLGInboxPopoutAction = class(HomeScenePopoutAction)

function FLGInboxPopoutAction:ctor()
	self.name = "FLGInboxPopoutAction"
    self:setSource(AutoPopoutSource.kSceneEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kInitEnter)
end

function FLGInboxPopoutAction:checkCanPop()
	-- self:onCheckPopResult( true )

	-- local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
	-- FLGLogic:hasGift()
	self:onCheckPopResult( false )

	-- if _G.isLocalDevelopMode  then printx(101 , "FLGInboxPopoutAction checkCanPop "  ) end
	-- if _G.isLocalDevelopMode  then printx(101 , "FLGInboxPopoutAction checkCanPop "  ) end
	-- if _G.isLocalDevelopMode  then printx(101 , "FLGInboxPopoutAction checkCanPop "  ) end
	-- if _G.isLocalDevelopMode  then printx(101 , "FLGInboxPopoutAction checkCanPop "  ) end

	
	
end

function FLGInboxPopoutAction:popout(next_action)
	-- local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
	-- FLGLogic:popoutGifts(next_action)
	if next_action then next_action() end
end