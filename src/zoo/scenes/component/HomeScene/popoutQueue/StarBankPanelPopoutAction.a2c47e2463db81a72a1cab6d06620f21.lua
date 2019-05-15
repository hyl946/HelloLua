--[[
 * StarBankPanelPopoutAction
 * @date    2017-12-12 17:17:07
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

StarBankPanelPopoutAction = class(HomeScenePopoutAction)

function StarBankPanelPopoutAction:ctor()
    self.name = "StarBankPanelPopoutAction"
    self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function StarBankPanelPopoutAction:checkCanPop()
	if self.debug then
		StarBank.poptime = 0
	end
    self:onCheckPopResult(StarBank:canForcePop())
end

function StarBankPanelPopoutAction:popout( next_action )
    StarBank:tryPopoutStarBankPanel(false, next_action)
end