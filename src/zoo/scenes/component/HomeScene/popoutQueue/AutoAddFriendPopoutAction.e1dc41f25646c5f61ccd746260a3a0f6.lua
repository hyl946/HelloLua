AutoAddFriendPopoutAction = class(HomeScenePopoutAction)

function AutoAddFriendPopoutAction:ctor()
	self.name = "AutoAddFriendPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function AutoAddFriendPopoutAction:checkCanPop()
	-- AutoAddFriendManager:canPop(function ( canPop )
	-- 	self:onCheckPopResult(canPop)
	-- end)
	self:onCheckPopResult(false)
end

function AutoAddFriendPopoutAction:popout( next_action )
--    AutoAddFriendManager.getInstance():autoAddCheck(next_action, next_action)
end