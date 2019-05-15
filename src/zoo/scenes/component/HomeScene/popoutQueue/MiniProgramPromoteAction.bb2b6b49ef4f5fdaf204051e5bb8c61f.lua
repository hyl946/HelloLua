--[[
 * MiniProgramPromoteAction
 * @authors zhigang.niu
--]]

MiniProgramPromoteAction = class(HomeScenePopoutAction)

function MiniProgramPromoteAction:ctor()
    self.name = "MiniProgramPromoteAction"
    self.recallUserNotPop = false
    self.isCanPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function MiniProgramPromoteAction:checkCanPop()
    if self.isCanPop then
        local bCanPop = MiniProgramPromoteManager.getInstance():checkCanPopout()
        self:onCheckPopResult(bCanPop)
    else
        self:onCheckPopResult(false)
    end
end

function MiniProgramPromoteAction:popout( next_action )
    MiniProgramPromoteManager.getInstance():popout( next_action )
end