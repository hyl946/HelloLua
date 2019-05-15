local FlowerIconPriority = require 'zoo.data.FlowerIconPriority'

local ActivityStubData = class()
function ActivityStubData:ctor()
	self.source = ""
	self.actId = 0
	self.endTime = 0
	self.res = ""


	self.levels = {}
end

function ActivityStubData:expired()
	print(Localhost:timeInSec(), self.endTime)
	if Localhost:timeInSec() > self.endTime then
		return true
	end
	return false
end

function ActivityStubData:time2Expire()
	local dif = self.endTime - Localhost:timeInSec()
	return math.max(0, dif)
end

function ActivityStubData:fromLua(src)
	if src then
		self.source = src.source or ""
		self.actId = src.actId or 0
		self.endTime = src.endTime or 0
		self.res = src.res or ""
		self.levels = src.levels or {}
	end
end

function ActivityStubData:encode()
	local data = {}
	for k, v in pairs(self) do
		if k ~= "class" and v ~= nil and type(v) ~= "function" then data[k] = v end
	end
	return data
end

ActivityLevelFlourManager = {}

function ActivityLevelFlourManager:createFileKey()
	if not self.fileKey then

		local platform = UserManager.getInstance().platform
		local uid = UserManager.getInstance().uid or "12345"
		self.fileKey = "ActivityLevelFlour_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"

	end
end

function ActivityLevelFlourManager:initData(worldScene)
	self.flours = {}
	self.activityData = nil
	self.worldScene = worldScene

	self:createFileKey()

	local data = Localhost.getInstance():readFromStorage( self.fileKey )
	local activityData = ActivityStubData.new()
	if data then
		activityData:fromLua(data)
	end

	self.activityData = activityData
end

function ActivityLevelFlourManager:updateFlourVisible()
	if self.flours then
		for _,v in pairs(self.flours) do
			if not v.isDisposed then
				v:setVisible(FlowerIconPriority:canShow(FlowerIconPriority.PRIORITY.kNDJ, v.level))
			end
		end
	end
end

function ActivityLevelFlourManager:showFlour()
	if not self.activityData or self.activityData:expired() then return end

	self:removeFlours()

	-- 加载关卡花
	local LevelFlourButton = require "zoo.scenes.component.HomeScene.item.LevelFlourButton"
	for i=1, #self.activityData.levels do
		local lev = self.activityData.levels[i]
		local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
		
		if lev > topLevelId then
			local node = self.worldScene.levelToNode[lev]

			if node then
				local flourButton = LevelFlourButton:create(self.activityData , lev)
				self.worldScene.chestLayer:addChild(flourButton)
				
				local pos = node:getPosition()
				flourButton:setPosition(ccp(pos.x, pos.y))

				self.flours[lev] = flourButton
			end
		end
	end

	-- 超时移除
	if self.timmer ~= nil then
		cancelTimeOut(self.timmer)
        self.timmer = nil
	end

	self.timmer = setTimeOut(function ( ... )
		self:removeFlours()
    end, self.activityData:time2Expire())

	FlowerIconPriority:refresh()
end

function ActivityLevelFlourManager:removeFlours()
	if self.worldScene.chestLayer.isDisposed then
		self.flours = {}
		return
	end
    for _,v in pairs(self.flours) do
		v:removeFromParentAndCleanup()
	end
	self.flours = {}

	FlowerIconPriority:refresh()
end

function ActivityLevelFlourManager:updateFloursStateByTopLevel( showType )

	if not showType then showType = 1 end

	if showType == 1 then
		-- 更新状态
	    local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
	    local begLevel = table.find( self.activityData.levels , function( v )
	    	return v >= topLevelId end
	    )
	    local begIdx = table.indexOf( self.activityData.levels , begLevel)
	    if begIdx then
	        for i= begIdx, math.min(begIdx + 3, table.size( self.activityData.levels )) do
	            local lev = self.activityData.levels[i]
	            if (lev - topLevelId) <=3 then
	                -- 激活状态
	                local item = ActivityLevelFlourManager:getFlour(lev)
	                if item and item.activeState then
	                    item:activeState()
	                end
	            else
	                break
	            end
	        end
	    end
	end
	
end

function ActivityLevelFlourManager:hasActivityInfo(source)
	if self.activityData and self.activityData.source == source then
		return true
	end
	return false
end

function ActivityLevelFlourManager:setActivityInfo(source, actId, endTime, res, levels)
	local activityData = ActivityStubData.new()
	activityData.source = source
	activityData.actId = actId
	activityData.endTime = endTime
	activityData.res = res
	activityData.levels = levels or {}

	self.activityData = activityData

	self:createFileKey()

	Localhost.getInstance():writeToStorage(activityData:encode(), self.fileKey )
end

function ActivityLevelFlourManager:getFlour(key)
	return self.flours[key]
end

function ActivityLevelFlourManager:removeFlour(key)
	local flour =  self.flours[key]
	if flour then
		self.flours[key] = nil
		flour:removeFromParentAndCleanup()
		FlowerIconPriority:refresh()
	end
end

function ActivityLevelFlourManager:findFlourByLevelId( levelId )
	if self.flours then
		return self.flours[levelId]
	end
end


FlowerIconPriority:setCheckFunc(FlowerIconPriority.PRIORITY.kNDJ, function ( levelId )
	return ActivityLevelFlourManager:findFlourByLevelId(levelId) ~= nil
end)

FlowerIconPriority:setRefreshFunc(FlowerIconPriority.PRIORITY.kNDJ, function ( levelId )
	return ActivityLevelFlourManager:updateFlourVisible()
end)

return ActivityLevelFlourManager