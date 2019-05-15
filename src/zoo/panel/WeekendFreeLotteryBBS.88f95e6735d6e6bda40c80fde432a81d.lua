local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'

local function getUserKey( key )
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    return key .. tostring(uid) .. '.' .. '.by.Misc.getUserKey'
end

local nextKey = 1

local function getKey( ... )
	local key = 'user.key.free.lottery.bbs.' .. nextKey
	nextKey = nextKey + 1
	return key
end

local KEY = {
	IS_SILENT = getKey(),
	POPOUT_RECORD = getKey(),
}

local DALIY_LIMIT = 2
local WEEKLY_LIMIT = 3
local SILENT_DAYS = 7

local WeekendFreeLotterBBS = {}

function WeekendFreeLotterBBS:canPopout( ... )
	
	if not LotteryLogic:isFreeEnable() then
		return false
	end

	if not LotteryLogic:shouldShowBBSPanel() then
		return false
	end

	local topLevel = 0
	if UserManager.getInstance().user then
		topLevel = UserManager.getInstance().user:getTopLevelId() or 0
	end

	if topLevel <= 20 then
		return false
	end

	local record = CCUserDefault:sharedUserDefault():getStringForKey(getUserKey(KEY.POPOUT_RECORD), '') or ''
	if (not record) or record == '' then 
		record = {}
	else
		record = table.deserialize(record) or {}
	end

	local function tonumberOr0( n )
		return tonumber(n or 0) or 0
	end

	record = table.map(tonumberOr0, record)
	table.sort(record)

	if #record <= 0 then
		return true
	end

	local now = Localhost:timeInSec()

	if self:isSilentIn7Days() then
		local lastPopoutTime = record[#record]
		if now - lastPopoutTime <= SILENT_DAYS * 24 * 3600 then
			return false
		end
	end

	local function getDayStartTimeByTS(ts)
		if ts ~= nil then
			local utc8TimeOffset = 57600
			local dayInSec = 86400
			return ts - ((ts - utc8TimeOffset) % dayInSec)
		end
		return 0
	end

	local record_days = table.map(getDayStartTimeByTS, record)
	local todays = getDayStartTimeByTS(now)
	local today_popout_count = #(table.filter(record_days, function ( t )
		return t == todays
	end))

	if today_popout_count >= DALIY_LIMIT then
		return false
	end


	-- 自定义方法
	-- 计算几天是第几周
	-- 1970-01-05 是星期一 这一周叫做第一周
	local function getWeekIndex( timeInSec )
		return math.floor((timeInSec - 4 * 24 * 3600 + 8*3600 ) / (7 *24 * 3600)) + 1
	end

	local toweek_index= getWeekIndex(now)
	local recore_weeks = table.map(getWeekIndex, record)
	local toweek_popout_count = #(table.filter(recore_weeks, function ( t )
		return t == toweek_index
	end))

	if toweek_popout_count >= WEEKLY_LIMIT then
		return false
	end

	return true
end

function WeekendFreeLotterBBS:onPopout( ... )
	local record = CCUserDefault:sharedUserDefault():getStringForKey(getUserKey(KEY.POPOUT_RECORD), '') or ''
	if (not record) or record == '' then 
		record = {}
	else
		record = table.deserialize(record) or {}
	end
	local function tonumberOr0( n )
		return tonumber(n or 0) or 0
	end
	record = table.map(tonumberOr0, record)
	table.sort(record)
	if #record >= math.max(DALIY_LIMIT, WEEKLY_LIMIT) + 1 then
		table.remove(record, 1)
	end
	local now = Localhost:timeInSec()
	table.insert(record, now)
	CCUserDefault:sharedUserDefault():setStringForKey(getUserKey(KEY.POPOUT_RECORD), table.serialize(record))
end

function WeekendFreeLotterBBS:isSilentIn7Days( ... )
	return CCUserDefault:sharedUserDefault():getBoolForKey(getUserKey(KEY.IS_SILENT), false)
end

function WeekendFreeLotterBBS:setSilentIn7Days( bFlag )
	CCUserDefault:sharedUserDefault():setBoolForKey(getUserKey(KEY.IS_SILENT), bFlag)
end


local WeekendFreeLotteryPanel = class(BasePanel)

function WeekendFreeLotteryPanel:create(dcReason)
    local panel = WeekendFreeLotteryPanel.new()
    panel.dcReason = dcReason
    panel:loadRequiredResource("ui/weekend_free_lottery.json")
    panel:init()
    return panel
end

function WeekendFreeLotteryPanel:init()
    local ui = self:buildInterfaceGroup("week_free_lottery/panel")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
    self.ui:getChildByPath('check/label'):setString(localize('five.steps.lottery.free.cancel'))
    
    local function refreshIcon( ... )
    	if self.isDisposed then return end
    	self.ui:getChildByPath('check/icon'):setVisible(WeekendFreeLotterBBS:isSilentIn7Days())
    	self.dcCancel = WeekendFreeLotterBBS:isSilentIn7Days()
    end

    UIUtils:setTouchHandler(self.ui:getChildByPath('check/bg'), function ( ... )
    	local isSilent = not WeekendFreeLotterBBS:isSilentIn7Days()
    	WeekendFreeLotterBBS:setSilentIn7Days(isSilent)
    	refreshIcon()
    end)

    refreshIcon()
end

function WeekendFreeLotteryPanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)

	DcUtil:UserTrack({category='add_5steps', sub_category='lottery_info', t1 = self.dcReason, cancel = self.dcCancel})
end

function WeekendFreeLotteryPanel:popout()
    if self.isDisposed then return end
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	-- PopoutManager:sharedInstance():add(self, true)
	PopoutQueue:sharedInstance():push(self, true, false)
	self.allowBackKeyTap = true

end

function WeekendFreeLotteryPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end
    self:_close()
end

function WeekendFreeLotteryPanel:tryPopout( dcReason )
	
	-- if WeekendFreeLotterBBS:canPopout() then
		-- WeekendFreeLotteryPanel:create(dcReason):popout()
		-- WeekendFreeLotterBBS:onPopout()
	-- end

end

return WeekendFreeLotteryPanel
