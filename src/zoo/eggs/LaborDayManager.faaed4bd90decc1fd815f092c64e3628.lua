local KEY = {
	ENTER_ACTIVITY = 'labor.day.ENTER_ACTIVITY',
}

local WATER_LIMIT_PER_DAY = 30

local SOURCE = 'LaborDay/Config.lua'


local LaborDayManager = class()

local instance 

function LaborDayManager:getInstance( ... )
	if not instance then
		instance = LaborDayManager.new()
	end
	return instance
end

function LaborDayManager:shouldSeeWaterDrops( ... )
	return self:isActivitySupport() and self:hadEnterActivityByCached() and (not self:hadWaterOverLimit())
end

function LaborDayManager:isActivitySupport( ... )
	return table.find(ActivityUtil:getActivitys() or {},function( v )
		return v.source == SOURCE
	end)
end

function LaborDayManager:shouldSeeFlyWaterDropsAnimation( ... )
	return self:shouldSeeWaterDrops()
end

function LaborDayManager:hadEnterActivityByCached( ... )

	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)

	return CCUserDefault:sharedUserDefault():getBoolForKey(KEY.ENTER_ACTIVITY..uid, false)
end

function LaborDayManager:setEnterActivityFlag( ... )

	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)

	CCUserDefault:sharedUserDefault():setBoolForKey(KEY.ENTER_ACTIVITY..uid, true)
end

function LaborDayManager:hadWaterOverLimit( ... )
	-- return self:getTodayWaterNum() >= WATER_LIMIT_PER_DAY
	--产品后来决定去掉上限
	return false
end

function LaborDayManager:getTodayWaterNum( ... )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) == 'table' and userDailyData.__activity_labor then
		return userDailyData.__activity_labor.waterNumber or 0
	else
		return 0
	end
end

function LaborDayManager:incTodayWaterNum( ... )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if not userDailyData.__activity_labor then
		userDailyData.__activity_labor = {}
	end

	if not userDailyData.__activity_labor.waterNumber then
		userDailyData.__activity_labor.waterNumber = 0
	end

	userDailyData.__activity_labor.waterNumber = userDailyData.__activity_labor.waterNumber + 1

	Localhost:writeLocalDailyData(nil, userDailyData)
end


function LaborDayManager:setTodayWaterNum( num )
	local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if not userDailyData.__activity_labor then
		userDailyData.__activity_labor = {}
	end

	if not userDailyData.__activity_labor.waterNumber then
		userDailyData.__activity_labor.waterNumber = 0
	end

	userDailyData.__activity_labor.waterNumber = num

	Localhost:writeLocalDailyData(nil, userDailyData)
end

function LaborDayManager:getActivityIcon( ... )
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == SOURCE then
			return v
		end
	end
end

function LaborDayManager:playFlyWaterDropAnimation( startPos )
	local icon = self:getActivityIcon()
	if icon then
		require "zoo.scenes.component.HomeScene.flyToAnimation.FlyItemToIconAnimation"

		InterfaceBuilder:createWithContentsOfFile('ui/LaborDay.json')
		local anim = FlyItemToIconAnimation:create(1, "labor.day.package/water0000", icon, startPos)
		anim:setFinishCallback(function ( ... )
			InterfaceBuilder:unloadAsset('ui/LaborDay.json')
		end)
		anim:play()

	end
end

function LaborDayManager:tryPlayFlyWaterDropAnimation( startPos )
	if self:shouldSeeFlyWaterDropsAnimation() then
		self:playFlyWaterDropAnimation(startPos)
	end
end

function LaborDayManager:onSeasonWeeklyEnd( ... )
	if self:shouldSeeWaterDrops() then
		self:buildLightPropAnim()
	end
end

function LaborDayManager:buildLightPropAnim( ... )
	local LaborWaterPanel = require 'zoo.eggs.LaborWaterPanel'
	LaborWaterPanel:create():popout()
end

function LaborDayManager:popoutTip( ... )
	local LaborTipPanel = require 'zoo.eggs.LaborTipPanel'
	LaborTipPanel:create():popout()
end

function LaborDayManager:loadSkeletonAssert( ... )
	FrameLoader:loadArmature('skeleton/labordayAnim', 'labordayAnim', 'labordayAnim')
end

function LaborDayManager:unloadSkeletonAssert( ... )
    ArmatureFactory:remove('labordayAnim', 'labordayAnim')
end

return LaborDayManager