local KEY = {
	ENTER_ACTIVITY = 'qixi.ENTER_ACTIVITY.',
}

local WATER_LIMIT_PER_DAY = 30

local SOURCE = 'Qixi2017/Config.lua'


local QixiManager = class()

local instance 

function QixiManager:getInstance( ... )
	if not instance then
		instance = QixiManager.new()
	end
	return instance
end

function QixiManager:shouldSeeRose( ... )
	return self:isActivitySupport() and self:hadEnterActivityByCached()
end

function QixiManager:isActivitySupport( ... )
	if __WIN32 then 
		return true
	end
	local ret = table.find(ActivityUtil:getActivitys() or {},function( v )
		return v.source == SOURCE
	end)
	return ret
end

function QixiManager:shouldSeeFlyRoseAnimation( ... )
	return self:shouldSeeRose()
end

function QixiManager:hadEnterActivityByCached( ... )

	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)

	local ts = CCUserDefault:sharedUserDefault():getIntegerForKey(KEY.ENTER_ACTIVITY..uid)
	return Localhost:timeInSec() < ts
end

function QixiManager:setEnterActivityFlag(ts)

	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)

	CCUserDefault:sharedUserDefault():setIntegerForKey(KEY.ENTER_ACTIVITY..uid, ts)
end

function QixiManager:getTodayRoseNum( ... )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) == 'table' and userDailyData.__activity_qixi2017 then
		return userDailyData.__activity_qixi2017.roseNumber or 0
	else
		return 0
	end
end

function QixiManager:incTodayRoseNum( ... )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if not userDailyData.__activity_qixi2017 then
		userDailyData.__activity_qixi2017 = {}
	end

	if not userDailyData.__activity_qixi2017.roseNumber then
		userDailyData.__activity_qixi2017.roseNumber = 0
	end

	userDailyData.__activity_qixi2017.roseNumber = userDailyData.__activity_qixi2017.roseNumber + 1

	Localhost:writeLocalDailyData(nil, userDailyData)
end


function QixiManager:setTodayRoseNum( num )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if not userDailyData.__activity_qixi2017 then
		userDailyData.__activity_qixi2017 = {}
	end

	if not userDailyData.__activity_qixi2017.roseNumber then
		userDailyData.__activity_qixi2017.roseNumber = 0
	end

	userDailyData.__activity_qixi2017.roseNumber = num

	Localhost:writeLocalDailyData(nil, userDailyData)
end

function QixiManager:getActivityIcon( ... )
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == SOURCE then
			return v
		end
	end
end

function QixiManager:playFlyRoseAnimation( startPos )
	local icon = self:getActivityIcon()
	if icon then
		require "zoo.scenes.component.HomeScene.flyToAnimation.FlyItemToIconAnimation"

		local anim = FlyItemToIconAnimation:create(1, "qixi_2017/small_rose0000", icon, startPos)
		anim:play()

	end
end

function QixiManager:tryPlayFlyRoseAnimation( startPos )
	if self:shouldSeeFlyRoseAnimation() then
		self:playFlyRoseAnimation(startPos)
	end
end

function QixiManager:onSeasonWeeklyEnd( ... )
	if self:shouldSeeRose() then
		self:buildLightPropAnim()
	end
end

function QixiManager:buildLightPropAnim( ... )
	local QixiRosePanel = require 'zoo.eggs.QixiRosePanel'
	QixiRosePanel:create():popout()
end

function QixiManager:popoutTip(passed)
	local Qixi2017TipPanel = require 'zoo.eggs.Qixi2017TipPanel'
	Qixi2017TipPanel:create(passed):popout()
end

function QixiManager:loadSkeletonAssert( ... )
	-- FrameLoader:loadArmature('skeleton/qixi_2017_animation', 'qixi_2017_animation', 'qixi_2017_animation')
end

function QixiManager:unloadSkeletonAssert( ... )
    -- ArmatureFactory:remove('qixi_2017_animation', 'qixi_2017_animation')
end

return QixiManager