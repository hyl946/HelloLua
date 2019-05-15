--[[
 * ModuleNoticeAction
 * @date    2018-08-03 15:57:07
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local ModuleNoticeAction = class(HomeScenePopoutAction)

function ModuleNoticeAction:ctor()
    self.name = "ModuleNoticeAction"
    self:setSource(AutoPopoutSource.kTriggerPop)
end

function ModuleNoticeAction:checkCache(cache)
	local para = cache.para
	self.para = para
	self:onCheckCacheResult(para.canForcePop)
end

LadyBugTaskPanelPopoutAction = class(ModuleNoticeAction)

function LadyBugTaskPanelPopoutAction:ctor()
    self.name = "LadyBugTaskPanelPopoutAction"
end

function LadyBugTaskPanelPopoutAction:popout( next_action )
	local LadybugTaskPanel = require 'zoo.panel.newLadybug.LadybugTaskPanel'
	LadybugTaskPanel:create():popout(next_action)
end

StarRewardPanelPopoutAction = class(ModuleNoticeAction)

function StarRewardPanelPopoutAction:ctor()
    self.name = "StarRewardPanelPopoutAction"
end

function StarRewardPanelPopoutAction:popout( next_action )
	local panel = StarAchievenmentPanel_New:create()
	panel:popout(next_action)
end

NewerGiftPanelPopoutAction = class(ModuleNoticeAction)

function NewerGiftPanelPopoutAction:ctor()
    self.name = "NewerGiftPanelPopoutAction"
end

function NewerGiftPanelPopoutAction:popout( next_action )
	local panel = BeginnerPanel:create()
	if panel then
		panel:popout(next_action)
	else
		next_action()
	end
end

MarkNoticePanelPopoutAction = class(ModuleNoticeAction)

function MarkNoticePanelPopoutAction:ctor()
    self.name = "MarkNoticePanelPopoutAction"
end

function MarkNoticePanelPopoutAction:popout( next_action )
	if not self.para or not self.para.x then
		next_action()
		return
	end

	local homeScene = HomeScene:sharedInstance()
	if homeScene.markButton then
		homeScene:tryPopoutMarkPanel(true, next_action, 1)
	else
        if not UserManager:getInstance().markV2Active then
            local panel = MarkPanel:create(ccp(self.para.x , self.para.y))
		    panel:setCloseCallback(next_action)
		    panel:popout()
        else
            Mark2019Manager.getInstance():showMark2019Panel(nil, nil, 5)
        end
	end
end

FruitTreeNoticePanelPopoutAction = class(ModuleNoticeAction)

function FruitTreeNoticePanelPopoutAction:ctor()
    self.name = "FruitTreeNoticePanelPopoutAction"
end

function FruitTreeNoticePanelPopoutAction:popout( next_action )
	local homeScene = HomeScene:sharedInstance()
	local tarBtn = homeScene.fruitTreeBtn
	if tarBtn and tarBtn.onClick then
		tarBtn.onClick(nil, next_action)
	else
		next_action()
	end
end

WeeklyRaceTriggerPopoutAction = class(ModuleNoticeAction)

function WeeklyRaceTriggerPopoutAction:ctor()
    self.name = "WeeklyRaceTriggerPopoutAction"
end

function WeeklyRaceTriggerPopoutAction:popout( next_action )
	RankRaceMgr:getInstance():openMainPanel(nil, nil, nil, next_action)
end

-- function ModuleNoticeAction:popPanel( id, cache, next_action )
-- 	local homeScene = HomeScene:sharedInstance()
-- 	if id == ModuleNoticeID.AREA_TASK then
-- 		local taskInfos = AreaTaskMgr:getInstance():getModel():getCurTaskInfos()
--         if #taskInfos > 0 then
--             local levelId = taskInfos[#taskInfos].levelId
--             local areaId = math.floor((levelId - 1) / 15) + 40001
--             local panel = AreaTaskInfoPanel:create(areaId)
--             panel:popoutPush(next_action)
--         else
--         	next_action()
--         end
-- 	end
-- end