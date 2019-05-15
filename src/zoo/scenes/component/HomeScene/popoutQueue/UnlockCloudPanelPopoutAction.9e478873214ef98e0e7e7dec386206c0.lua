UnlockCloudPanelPopoutAction = class(HomeScenePopoutAction)

function UnlockCloudPanelPopoutAction:ctor( ... )
    self.name = "UnlockCloudPanelPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function UnlockCloudPanelPopoutAction:checkCanPop()
    local popout = false
    local cloud
    local worldScene = HomeScene:sharedInstance().worldScene
    for k, v in pairs(worldScene.lockedClouds) do
        if v.state == LockedCloudState.WAIT_TO_OPEN then
            local friends = UserManager:getInstance():getUnlockFriendUidsWithNPC(v.id)
            if #friends >= 3 then
                popout = true
                cloud = v
                break
            end
        end
    end

    if self.debug then
        self.cloud = worldScene.lockedClouds[1]
        return self:onCheckPopResult(true)
    end

    if popout then
        self.cloud = cloud
    end
    self:onCheckPopResult(popout)
end

function UnlockCloudPanelPopoutAction:popout( next_action )
    AreaUnlockPanelPopoutLogic:checkPopoutPanel(self.cloud, next_action)
end