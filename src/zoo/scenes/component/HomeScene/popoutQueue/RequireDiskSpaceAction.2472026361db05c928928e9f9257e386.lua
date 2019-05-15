
RequireDiskSpaceAction = class(HomeScenePopoutAction)

function RequireDiskSpaceAction:ctor()
    self.name = "RequireDiskSpaceAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function RequireDiskSpaceAction:checkCanPop()
    if self.debug then
        return self:onCheckPopResult(true)
    end
    local warning = getDiskFreeSpace() < 16
    self:onCheckPopResult(warning)
end

function RequireDiskSpaceAction:popout( next_action )
    AutoPopout:showNotifyPanel( "发现磁盘空间不足，请退出游戏清理后重新进入游戏", next_action)
end
