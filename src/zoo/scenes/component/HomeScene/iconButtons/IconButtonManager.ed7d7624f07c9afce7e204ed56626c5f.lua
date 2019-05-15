
--icontip优化优先级规则
	--活动相关的
		--活动 			1--999
		--活动中心 		1000
		--周赛 			1010
	--主界面按钮相关的
		--道具商店		10
		--风车币商店	20
		--瓢虫			30
		--签到			40
-----------------------
IconTipState = table.const{
	kNormal = "_1",	
	kExtend = "_2", 
	kReward = "_3",
	kExtend1 = "_4",
	kExtend2 = "_5",
}

local priority = 0
local function GetPriority()
	priority = priority + 1
	return priority
end

local FeatureIconTipShowPriority = {
	["GoldButton"] = GetPriority(),
	["LadybugButton"] = GetPriority(),
	["StarButton"] = GetPriority(),
	["MarkButton"] = GetPriority(),
}

IconButtonManager = class()

local instance = nil
local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local configPath = HeResPathUtils:getUserDataPath() .. "/IconButtonManager" 

local function readConfig()
	local file = io.open(configPath, "r")
	if file then
		local data = file:read("*a") 
		file:close()
		if data then
			return table.deserialize(data) or {}
		end
	end
	return {}
end

local function writeConfig(data)
	local file = io.open(configPath,"w")
	if file then 
		file:write(table.serialize(data or {}))
		file:close()
	end
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

function IconButtonManager:getInstance()
	if not instance then 
		instance = IconButtonManager.new()
		instance:init()
	end

	return instance
end

function IconButtonManager:ctor()
	--活动和周赛按钮
	self.playTipActivityIcons = {}
	--普通主界面按钮
	self.playTipNormalIcons = {}

	self.clickReplaceScene = false
end

function IconButtonManager:init()
	local function removeTips()
		local activityIcons = {}
		for _,v in pairs(self.playTipActivityIcons) do
			if v.playTipPriority == self.playTipActivityIcons[1].playTipPriority and not self:isActivityButton(v) then
				table.insert(activityIcons,v)
			end
		end
		for _,v in pairs(activityIcons) do
			self:removePlayTipActivityIcon(v)
		end

		local normalIcons = {}
		for _,v in pairs(self.playTipNormalIcons) do
			if v.playTipPriority == self.playTipNormalIcons[1].playTipPriority then
				table.insert(normalIcons,v)
			end
		end
		for _,v in pairs(normalIcons) do
			self:removePlayTipNormalIcon(v)
		end
	end

	local eventNode = CocosObject:create()
	HomeScene:sharedInstance():addChild(eventNode)
	eventNode:addEventListener(Events.kRemoveFromStage,function()
		if not self.clickReplaceScene then
			-- removeTips()
		end
		self.clickReplaceScene = false
	end)

	HomeScene:sharedInstance():addEventListener(SceneEvents.kEnterForeground,function()
		if not HomeScene:sharedInstance().exitDialog then 
			removeTips()
		end
	end)
end

function IconButtonManager:onRemoveActivityUnusedRes( usedActivity )
	local config = readConfig()
	local nc = {}

	for id,v in pairs(config) do
		if string.find(id, "ActivityIconButton_") then
			local has = false
			for _,name in ipairs(usedActivity) do
				if string.find(id, name) then
					has = true
					break
				end
			end
			if has then
				nc[id] = v
			end
		else
			nc[id] = v
		end
	end
	
	writeConfig(nc)
end

function IconButtonManager:todayIsShow(icon)
	if icon:is(MessageButton) then 
		return false
	end

	local config = readConfig()

	if icon:is(RankRaceButton) and icon:hasRewards() then
		return false
	end

	if not config[icon.id] then 
		return false
	end

	if IconButtonManager:getInstance():isActivityButton(icon) then 
		if icon.tips and icon.tips ~= config[icon.id].tips then 
			return false
		end
	end

	local lastShowTime = getDayStartTimeByTS(config[icon.id].time or 0)
	local todayTime = getDayStartTimeByTS(now())
	return lastShowTime >= todayTime
end

function IconButtonManager:clearShowTime(icon)
	local config = readConfig()

	if not config[icon.id] then 
		config[icon.id] = {}
	end

	config[icon.id].time = 0

	writeConfig(config)
end

function IconButtonManager:writeShowTime(icon, noCount)
	if icon:is(MessageButton) then 
		return
	end

	local config = readConfig()

	if not config[icon.id] then 
		config[icon.id] = {}
	end
	if IconButtonManager:getInstance():isActivityButton(icon) then 
		config[icon.id].revertTips = config[icon.id].tips
		config[icon.id].revertCount = config[icon.id].count

		if icon.tips then 
			config[icon.id].tips = icon.tips
		end

		if not noCount then
			config[icon.id].count = (config[icon.id].count or 0) + 1
		end
	end

	config[icon.id].revertTime = config[icon.id].time
	config[icon.id].time = now()
	writeConfig(config)
end

function IconButtonManager:revertShowTime(icon)
	if icon:is(MessageButton) then 
		return
	end

	local config = readConfig()

	if not config[icon.id] then 
		return
	end

	config[icon.id].tips = config[icon.id].revertTips
	config[icon.id].count = config[icon.id].revertCount
	config[icon.id].time = config[icon.id].revertTime

	config[icon.id].revertTips = nil
	config[icon.id].revertCount = nil
	config[icon.id].revertTime = nil
	writeConfig(config)
end

function IconButtonManager:isActivityButton(icon)
	return icon:is(ActivityIconButton) or icon:is(ActivityButton) or icon:is(ActivityCenterButton)
end

local function delayProcess(callback)
	local funcId = nil
	local function onDelayProcessTick()
		if funcId ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(funcId) end
		funcId = nil
		if callback then callback() end 
	end
	funcId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onDelayProcessTick, 0.1)
end

function IconButtonManager:playActivityHasNotificationAnim()
	local function processFunc()
		for _,v in pairs(self.playTipActivityIcons) do
			if not v.isDisposed then
				IconButtonBase.stopHasNotificationAnim(v)
			end
		end

		local config = readConfig()

		local showTipIcon = self.playTipActivityIcons[1]
		local isShow = false

		for i,v in ipairs(self.playTipActivityIcons) do
			if not v.isDisposed then
				local tipShowCount = v.tipShowCount or 999
				config[v.id] = config[v.id] or {}
				local totalCount = config[v.id].count or 0
				local canShowTip = totalCount < tipShowCount

				local isRankRace = v:is(RankRaceButton) and v:hasRewards()

				if isRankRace or (v.playTipPriority <= showTipIcon.playTipPriority and canShowTip and not isShow) then
					isShow = true
					IconButtonBase.playHasNotificationAnim(v)
					
					if not self:todayIsShow(v) then 
						self:writeShowTime(v)
					end
				else
					v:playOnlyIconAnim()
					if not isShow then
						showTipIcon = self.playTipActivityIcons[i + 1]
					end
				end
			end
		end
	end
	delayProcess(processFunc)
end

function IconButtonManager:playNormalHasNotificationAnim()
	local function processFunc()
		for _,v in pairs(self.playTipNormalIcons) do
			IconButtonBase.stopHasNotificationAnim(v)
		end

		local isShow = false
		for i,v in ipairs(self.playTipNormalIcons) do
			if v.playTipPriority <= self.playTipNormalIcons[1].playTipPriority and not isShow then
				IconButtonBase.playHasNotificationAnim(v)
				self:writeShowTime(v)
			else
				v:playOnlyIconAnim()
			end
		end
	end
	delayProcess(processFunc)
end

function IconButtonManager:addPlayTipActivityIcon(icon)
	if not table.exist(self.playTipActivityIcons,icon) then
		if self:todayIsShow(icon) then 
			return
		end

		table.insert(self.playTipActivityIcons,icon)
		table.sort(self.playTipActivityIcons,function(a,b) return a.playTipPriority < b.playTipPriority end)

		local eventNode = CocosObject:create()
		icon:addChild(eventNode)
		eventNode:addEventListener(Events.kDispose,function()
			self:removePlayTipActivityIcon(icon)
		end)
	end
	
	self:playActivityHasNotificationAnim()
	if _G.isLocalDevelopMode then printx(0, "addPlayTipActivityIcon " .. icon.id) end
end

function IconButtonManager:removePlayTipActivityIcon(icon)
	if not table.exist(self.playTipActivityIcons,icon) then 
		return
	end

	table.removeValue(self.playTipActivityIcons,icon)
	IconButtonBase.stopHasNotificationAnim(icon)

	self:playActivityHasNotificationAnim()

	if icon:is(ActivityCenterButton) then
		Notify:dispatch("ActivityIconShowTipEvent")
	end

	if _G.isLocalDevelopMode then printx(0, "removePlayTipActivityIcon " .. icon.id) end
	-- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
end

function IconButtonManager:addPlayTipNormalIcon(icon)
	if not table.exist(self.playTipNormalIcons,icon) then
		if self:todayIsShow(icon) then 
			return
		end

		icon.playTipPriority = FeatureIconTipShowPriority[icon.idPre] or 999
		table.insert(self.playTipNormalIcons,icon)
		table.sort(self.playTipNormalIcons,function(a,b) return a.playTipPriority < b.playTipPriority end)

		local eventNode = CocosObject:create()
		icon:addChild(eventNode)
		eventNode:addEventListener(Events.kDispose,function()
			self:removePlayTipNormalIcon(icon)
		end)
	else
		--跨天逻辑,如果已经显示tip，则更新time
		local config = readConfig()
		if config[icon.id] then
			local lastShowTime = getDayStartTimeByTS(config[icon.id].time or 0)
			local todayTime = getDayStartTimeByTS(now())
			if lastShowTime < todayTime then
				self:writeShowTime(icon, true)
			end
		end
	end
	
	self:playNormalHasNotificationAnim()
	if _G.isLocalDevelopMode then printx(0, "addPlayTipNormalIcon " .. icon.id) end
end

function IconButtonManager:removePlayTipNormalIcon(icon)
	if not table.exist(self.playTipNormalIcons,icon) then 
		return
	end

	table.removeValue(self.playTipNormalIcons,icon)
	IconButtonBase.stopHasNotificationAnim(icon)

	self:playNormalHasNotificationAnim()

	if _G.isLocalDevelopMode then printx(0, "removePlayTipNormalIcon " .. icon.id) end
	-- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
end

function IconButtonManager:writeShowTimeInQueue(icon)
	if not table.exist(self.playTipActivityIcons, icon) then
		return
	end
	self:writeShowTime(icon)
end

--new icon show logic

function IconButtonManager:showIconTip( icon )
	local isAct = self:isActivityButton(icon)

end