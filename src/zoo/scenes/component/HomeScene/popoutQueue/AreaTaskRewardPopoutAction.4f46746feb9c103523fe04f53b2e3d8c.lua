--[[
 * AreaTaskRewardPopoutAction
 * @date    2018-08-09 10:42:34
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require "zoo.panel.component.friendsRecommend.FriendRecommendManager"

AreaTaskRewardPopoutAction = class(HomeScenePopoutAction)

function AreaTaskRewardPopoutAction:ctor()
    self.ignorePopCount = true
    self.name = "AreaTaskRewardPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function AreaTaskRewardPopoutAction:checkCanPop()
	self:onCheckPopResult(true)
end

function AreaTaskRewardPopoutAction:popout(next_action)
    AreaTaskMgr:getInstance():onPopoutAction()
    --这不应该在强弹里面，弹的是广播
    next_action()
end
