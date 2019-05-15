PushActivity = class()

local instance = nil
function PushActivity:sharedInstance()
	if not instance then
		instance = PushActivity.new()
		instance:_init()
	end
	return instance
end

function PushActivity:setPushActivityEnabled(enabled)
	self.enabled = enabled
end

function PushActivity:getPushActivityEnabled( ... )
	if type(self.enabled) == "boolean" then
		return self.enabled
	else
		return true
	end
end

function PushActivity:onEnergyNotEnough(callback)
	if type(self.enabled) == "boolean" and not self.enabled then return end
	local function onGetList(list)
		list = self:_getPushList(list)
		list = self:_filterPopNum(list)
		list = self:_filterPopCount(list) --活动中强弹上限
		list = self:_filterEnergyNotEnough(list)
		list = self:_filterMinLevel(list)
		list = self:_sortPushList(list)
		for _,act in pairs(list) do
			self:incActivityPopNum(act.actId)
			self:incActivityPopCount(act.actId)
			if callback then callback(act) end
		end
	end
	self:getActivityListAsync(onGetList)
end

function PushActivity:setForeGroundTimeStamp( ... )
	if type(self.enabled) == "boolean" and not self.enabled then 
		return 
	end
	self.foreGroundTimeStamp = Localhost:time()
end

function PushActivity:onComeToFront(callback, notRecode)

--	if NewVersionUtil:hasUpdateReward() then 
--		callback()
--		return
--	end

	-- local home = HomeScene:sharedInstance()
	-- if home.updateVersionButton and not home.updateVersionButton.isDisposed then 
	-- 	if not home.updateVersionButton.wrapper:isTouchEnabled() then 
	-- 		callback()
	-- 		return
	--  	end
	-- end

	self:_verifyPushRec()
	if type(self.enabled) == "boolean" and not self.enabled then 
		callback()
		return 
	end

	local function jsmaPrintx( ... )
		-- if _G.isLocalDevelopMode  then printx(103 , ... ) end

		-- RemoteDebug:uploadLog(...)
	end 

	local function onGetList(l)
		
		-- 优先处理queue = true,每天弹一次的情况
		local list = self:_getPushList(l)
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 1 = " , table.tostring(list)  ) end
		list = self:_filterPopCount(list) --活动中强弹上限
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 2 = " , table.tostring(list)  ) end
		list = self:_filterPopNum(list)
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 3 = " , table.tostring(list)  ) end
		list = self:_filterQueue(list)
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 4 = " , table.tostring(list)  ) end
		list = self:_filterMinLevel(list)
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 5 = " , table.tostring(list)  ) end
		list = self:_sortPushList(list)
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 6 = " , table.tostring(list)  ) end
		list = self:_filterPopCondition(list) --马俊松添加 判断config中的 popCondition 方法
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 7 = " , table.tostring(list)  ) end
		list = self:_filterPopOne(list) --每次只强弹一个
		-- if _G.isLocalDevelopMode  then jsmaPrintx( " list 8 = " , table.tostring(list)  ) end


		if #list > 0 then
			local act = list[1]
			if not notRecode then
				self:incActivityPopNum(act.actId)
				self:incActivityPopCount(act.actId)
			end
			if callback then callback({act}) end
			return
		end

		local list = self:_getPushList(l)
		list = self:_filterPopCount(list)
		list = self:_filterPopNum(list)

		if not notRecode then
			self.recList.comeToFrontRecord = self.recList.comeToFrontRecord + 1
		end

		list = self:_filterPopSeq(list, self.recList.comeToFrontRecord)
		list = self:_filterMinLevel(list)
		list = self:_sortPushList(list)
		list = self:_filterPopCondition(list) 
		list = self:_filterPopOne(list)

		if #list > 0 then
			if not notRecode then
				for _,act in pairs(list) do
					self:incActivityPopNum(act.actId)
					self:incActivityPopCount(act.actId)

					if act.popImmediately then 
						self:_setPopImmediately(act.actId)
					end
				end
			end
			if callback then callback(list) end
		else
			self:_writeToFile()
			if callback then callback() end
		end

	end
	self:getActivityListAsync(onGetList)
end


function PushActivity:onEnterHomeScene(callback)
	self:_verifyPushRec()
	if type(self.enabled) == "boolean" and not self.enabled then return end
	local function onGetList(list)
		list = self:_getPushList(list)
		list = self:_filterPopCount(list)
		list = self:_filterPopNum(list)
		list = self:_filterTimePush(list)
		list = self:_filterTimeList(list, Localhost:time() - self.foreGroundTimeStamp)
		list = self:_filterMinLevel(list)
		list = self:_sortPushList(list)
		local act = list[1]
		if act then
			self:incTimePush(act.actId)
			self:incActivityPopNum(act.actId)
			self:incActivityPopCount(act.actId)
			if callback then callback(act) end
			return
		end
		if callback then callback() end
	end
	self:getActivityListAsync(onGetList)
end

function PushActivity:onFailLevel(levelId)
	self:_verifyPushRec()
	if type(self.enabled) == "boolean" and not self.enabled then return end
	self:_incFailTime(levelId)
	if self:_verifyFailTime(levelId) then
		local list = self:getActivityList()
		list = self:_getPushList(list)
		list = self:_filterPopCount(list)
		list = self:_filterPopNum(list)
		list = self:_filterLevelFailPush(list)
		list = self:_filterFailLevel(list)
		list = self:_filterMinLevel(list)
		list = self:_sortPushList(list)
		local act = list[1]
		if act then
			self:incLevelFailPush(act.actId)
			self:incActivityPopNum(act.actId)
			self:incActivityPopCount(act.actId)
			return act
		end
	end
end

function PushActivity:onEnergyPanel()
	self:_verifyPushRec()
	if type(self.enabled) == "boolean" and not self.enabled then return end
	local list = self:getActivityList()
	list = self:_getPushList(list)
	list = self:_filterPopCount(list)
	list = self:_filterPopNum(list)
	list = self:_fileterEnergyPush(list)
	list = self:_filterEnergyPanel(list)
	list = self:_filterMinLevel(list)
	list = self:_sortPushList(list)
	local act = list[1]
	if act then
		self:incEnergyPush(act.actId)
		self:incActivityPopNum(act.actId)
		self:incActivityPopCount(act.actId)
		return act
	end
end

--重置某活动id的弹出计数
function PushActivity:setActivityPopNumWithActId(actId , num)

	if _G.isLocalDevelopMode  then printx(103 , "PushActivity  setActivityPopNumWithActId actId = " , actId ) end

	if self.recList then
		for k, v in ipairs(self.recList.activityRecord) do
			if v.actId == actId then
				v.num = num
				if _G.isLocalDevelopMode  then printx(103 , "PushActivity  setActivityPopNumWithActId v = " ,table.tostring(v)) end
				self:_writeToFile()
				return
			end
		end
	end
end

function PushActivity:incActivityPopNum(actId)
	for k, v in ipairs(self.recList.activityRecord) do
		if v.actId == actId then
			v.num = v.num + 1
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.activityRecord, {actId = actId, num = 1})
	self:_writeToFile()
end

function PushActivity:incActivityPopCount(actId)
	for k, v in ipairs(self.foreverList.activityRecord) do
		if v.actId == actId then
			v.popCount = (v.popCount or 0) + 1
			self:_writeForeverToFile()
			return
		end
	end
	table.insert(self.foreverList.activityRecord, {actId = actId, popCount = 1})
	self:_writeForeverToFile()
end

function PushActivity:incLevelFailPush(actId)
	for k, v in ipairs(self.recList.levelFailPush) do
		if v.actId == actId then
			v.num = v.num + 1
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.levelFailPush, {actId = actId, num = 1})
	self:_writeToFile()
end

function PushActivity:incEnergyPush(actId)
	for k, v in ipairs(self.recList.energyPush) do
		if v.actId == actId then
			v.num = v.num + 1
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.energyPush, {actId = actId, num = 1})
	self:_writeToFile()
end

function PushActivity:incTimePush(actId)
	for k, v in ipairs(self.recList.timePush) do
		if v.actId == actId then
			v.num = v.num + 1
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.timePush, {actId = actId, num = 1})
	self:_writeToFile()
end

function PushActivity:fillActivityPopNum(actId)
	for k, v in ipairs(self.recList.activityRecord) do
		if v.actId == actId then
			v.num = 1000000
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.activityRecord, {actId = actId, num = 1000000})
	self:_writeToFile()
end

function PushActivity:_setPopImmediately(actId)
	for k,v in pairs(self.recList.popImmediatelyRecord) do
		if v.actId == actId then 
			v.hasPopImmediately = true
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.popImmediatelyRecord,{actId = actId,hasPopImmediately = true})
	self:_writeToFile()
end

function PushActivity:_init()
	self:_resetPushRec()
	self:_readFromFile()
	self:_readForeverFromFile()
end

function PushActivity:getActivityList()
	local list = ActivityUtil:getNetworkActivitys()
	local ret = {}
	for k, v in ipairs(list) do
		local config = require("activity/"..tostring(v.source))
		if type(config.actId) == "number" then
			local item = {actId = config.actId, source = v.source, version = v.version}
			item.popCount = config.popCount
			item.popNum, item.popTime = config.popNum, config.popTime
			item.popPriority, item.failPop = config.popPriority, config.failPop
			item.energyPop, item.pushText = config.energyPop, config.pushText
			item.pushButton = config.pushButton
			if type(config.popSeq) == "table" then
				item.popSeq = {}
				for k, v in ipairs(config.popSeq) do item.popSeq[v] = true end
			end
			if type(config.rewards) == "table" then
				item.rewards = {}
				for k, v in ipairs(config.rewards) do
					item.rewards[k] = {itemId = v.itemId, num = v.num}
				end
			end
			item.popEnergyNotEnough = config.popEnergyNotEnough
			item.popImmediately = config.popImmediately
			item.popEveryTime = config.popEveryTime
			item.popMinLevel = config.popMinLevel
			item.queue = config.queue
			item.pushText1 = config.pushText1
			item.pushText2 = config.pushText2
			item.pushButton1 = config.pushButton1
			item.pushButton2 = config.pushButton2
			table.insert(ret, item)
		end
	end
	return ret
end

--活动强弹数据，win环境下没有，封装在ci自动生成的活动框架里
function PushActivity:getActivityListAsync(callback)
	local function onGetList(list)
		local ret = {}
		for k, v in ipairs(list) do
			local config = require("activity/"..tostring(v.source))
			if type(config.actId) == "number" then
				local item = {actId = config.actId, source = v.source, version = v.version}
				item.popCount = config.popCount
				item.popNum, item.popTime = config.popNum, config.popTime
				item.popPriority, item.failPop = config.popPriority, config.failPop
				item.energyPop, item.pushText = config.energyPop, config.pushText
				item.pushButton = config.pushButton
				if type(config.popSeq) == "table" then
					item.popSeq = {}
					for k, v in ipairs(config.popSeq) do item.popSeq[v] = true end
				end
				if type(config.rewards) == "table" then
					item.rewards = {}
					for k, v in ipairs(config.rewards) do
						item.rewards[k] = {itemId = v.itemId, num = v.num}
					end
				end
				item.popEnergyNotEnough = config.popEnergyNotEnough
				item.popImmediately = config.popImmediately
				item.popEveryTime = config.popEveryTime
				item.popMinLevel = config.popMinLevel
				item.queue = config.queue
				item.pushText1 = config.pushText1
				item.pushText2 = config.pushText2
				item.pushButton1 = config.pushButton1
				item.pushButton2 = config.pushButton2
				table.insert(ret, item)
			end
		end
		if callback then callback(ret) end
	end
	ActivityUtil:getNetworkActivitys(onGetList)
end

function PushActivity:_getPushList(list)
	local ret = {}
	for k, v in ipairs(list) do
		if type(v.popCount) ~= "number" then v.popCount = 999 end
		if type(v.popNum) ~= "number" then v.popNum = 2 end
		if type(v.popSeq) ~= "table" then v.popSeq = {} end
		if type(v.popTime) ~= "number" then v.popTime = 0 end
		if type(v.popPriority) ~= "number" then v.popPriority = 0 end
		if type(v.failPop) ~= "boolean" then v.failPop = false end
		if type(v.energyPop) ~= "boolean" then v.energyPop = false end
		if type(v.pushText1) ~= "string" then v.pushText1 = Localization:getInstance():getText("activity.scene.push.text1") end
		if type(v.pushButton1) ~= "string" then v.pushButton1 = Localization:getInstance():getText("activity.scene.push.button1") end
		if type(v.pushText2) ~= "string" then v.pushText2 = Localization:getInstance():getText("activity.scene.push.text2") end
		if type(v.pushButton2) ~= "string" then v.pushButton2 = Localization:getInstance():getText("activity.scene.push.button2") end
		if type(v.rewards) == "table" then
			local count = 0
			for k, v in ipairs(v.rewards) do
				if type(v) ~= "table" or type(v.itemId) ~= "number" or type(v.num) ~= "number" then
					v.rewards = {}
					break
				end
				count = count + 1
				if count > 3 then break end
			end
		else v.rewards = {} end

		if type(v.popEnergyNotEnough) ~= "boolean" then 
			v.popEnergyNotEnough = false
		end
		if type(v.popImmediately) ~= "boolean" then
			v.popImmediately = false
		end
		if type(v.popEveryTime) ~= "boolean" then
			v.popEveryTime = false
		end
		if type(v.popMinLevel) ~= "number" then
			v.popMinLevel = 0
		end
		if type(v.queue) ~= "boolean" then
			v.queue = false
		end

		table.insert(ret, v)
	end
	return ret
end


function PushActivity:_filterQueue( list )
	local ret = {}

	local function findPopNum(actId)
		if actId == 81 or actId == 3009 then
			local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
			if ver >= 37 then 	--含1.37版本及以上的回流用户连登不走配置的活动强弹
				return 99 
			end
		end

		for k, v in ipairs(self.recList.activityRecord) do
			if v.actId == actId then return v.num end
		end
		return 0
	end
	
	for k,v in pairs(list) do
		if v.queue then
			local popNum = findPopNum(v.actId)
			if popNum == 0 then
				table.insert(ret,v)
			end
		end
	end
	return ret
end

function PushActivity:_filterPopNum(list)
	local ret = {}
	for k, v in ipairs(list) do
		local function findPopNum(actId)
			for k, v in ipairs(self.recList.activityRecord) do
				if v.actId == actId then return v.num end
			end
			return 0
		end
		local poped = findPopNum(v.actId)

		if poped < v.popNum then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_filterPopCount(list)
	local function findPopCount(actId)
		for k, v in ipairs(self.foreverList.activityRecord) do
			if v.actId == actId then return v.popCount end
		end
		return 0
	end

	local ret = {}
	for k, v in ipairs(list) do
		local popCount = findPopCount(v.actId)
		if popCount < v.popCount then table.insert(ret, v) end
	end
	return ret
end

--判断config中的 popCondition 方法
function PushActivity:_filterPopCondition(list)
	local ret = {}
	for k, v in ipairs(list) do
		local config = require("activity/"..v.source)
		if config then
			if config.popCondition  and config.popCondition() then
				table.insert(ret, v)
			elseif not config.popCondition then
				table.insert(ret, v)
			end
		end

	end
	return ret
end

function PushActivity:_filterPopOne(list)
	local ret = {}
	for k, v in ipairs(list) do
		table.insert(ret, v)
		break
	end
	return ret
end

function PushActivity:_filterPopSeq(list, seq)
	local function hasPopImmediately( actId )
		for k, v in ipairs(self.recList.popImmediatelyRecord) do
			if v.actId == actId then return v.hasPopImmediately end
		end
		return false
	end

	local ret = {}
	for k, v in ipairs(list) do
		if v.popImmediately and not hasPopImmediately(v.actId) then
			table.insert(ret, v)
		elseif v.popEveryTime then
			table.insert(ret,v)
		elseif v.popSeq[seq] then
			table.insert(ret, v)
		end
	end
	return ret
end

function PushActivity:_filterTimeList(list, time)
	local ret = {}
	for k, v in ipairs(list) do
		if v.popTime ~= 0 and v.popTime < time then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_filterEnergyNotEnough(list)
	local ret = {}
	for k, v in ipairs(list) do
		if v.popEnergyNotEnough then 
			table.insert(ret, v) 
		end
	end
	return ret
end

function PushActivity:_filterMinLevel( list )
	local ret = {}
	for k, v in ipairs(list) do
		if v.popMinLevel <= UserManager:getInstance().user:getTopLevelId() then 
			table.insert(ret, v) 
		end
	end
	return ret
end

function PushActivity:_verifyFailTime(levelId)
	for k, v in ipairs(self.recList.levelFailRecord) do
		if v.levelId == levelId then return v.num >= 5 end
	end
	return false
end

function PushActivity:_incFailTime(levelId)
	for k, v in ipairs(self.recList.levelFailRecord) do
		if v.levelId == levelId then
			v.num = v.num + 1
			self:_writeToFile()
			return
		end
	end
	table.insert(self.recList.levelFailRecord, {levelId = levelId, num = 1})
	self:_writeToFile()
end



function PushActivity:_filterFailLevel(list)
	local ret = {}
	for k, v in ipairs(list) do
		if v.failPop and #v.rewards >= 1 then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_filterEnergyPanel(list)
	local ret = {}
	for k, v in ipairs(list) do
		if v.energyPop then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_sortPushList(list) -- by ref
	local function sortFunc(a, b)
		return a.popPriority < b.popPriority
	end
	table.sort(list, sortFunc)
	return list

end

function PushActivity:_filterLevelFailPush(list)
	local ret = {}
	for k, v in ipairs(list) do
		local function findLevelFailPush(actId)
			for k, v in ipairs(self.recList.levelFailPush) do
				if v.actId == actId then return v.num end
			end
			return 0
		end
		local poped = findLevelFailPush(v.actId)
		if poped < 1 then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_fileterEnergyPush(list)
	local ret = {}
	for k, v in ipairs(list) do
		local function findEnergyPush(actId)
			for k, v in ipairs(self.recList.energyPush) do
				if v.actId == actId then return v.num end
			end
			return 0
		end
		local poped = findEnergyPush(v.actId)
		if poped < 1 then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_filterTimePush(list)
	local ret = {}
	for k, v in ipairs(list) do
		local function findTimePush(actId)
			for k, v in ipairs(self.recList.timePush) do
				if v.actId == actId then return v.num end
			end
			return 0
		end
		local poped = findTimePush(v.actId)
		if poped < 1 then table.insert(ret, v) end
	end
	return ret
end

function PushActivity:_verifyPushRec()
	if type(self.recList) ~= "table" or type(self.recList.updateTime) ~= "number" then
		self:_resetPushRec()
		return
	end
	local time = Localhost:time()
	if compareDate(os.date('*t', math.floor(time / 1000)), os.date('*t',
		math.floor(self.recList.updateTime / 1000))) ~= 0 then
		self.recList.activityRecord = {}
		self.recList.levelFailRecord = {}
		self.recList.levelFailPush = {}
		self.recList.energyPush = {}
		self.recList.timePush = {}
		self.recList.comeToFrontRecord = 0
	end
	if type(self.recList.activityRecord) ~= "table" then self.recList.activityRecord = {} end
	if type(self.recList.levelFailRecord) ~= "table" then self.recList.levelFailRecord = {} end
	if type(self.recList.comeToFrontRecord) ~= "number" then self.recList.comeToFrontRecord = 0 end
	if type(self.recList.levelFailPush) ~= "table" then self.recList.levelFailPush = {} end
	if type(self.recList.energyPush) ~= "table" then self.recList.energyPush = {} end
	if type(self.recList.timePush) ~= "table" then self.recList.timePush = {} end
	if type(self.recList.popImmediatelyRecord) ~= "table" then self.recList.popImmediatelyRecord = {} end
	self:_writeToFile()
end

function PushActivity:onRemoveActivityUnusedRes( usedActId )

	-- if not self.foreverList then
	-- 	return
	-- end

	-- if not self.foreverList.activityRecord then
	-- 	return
	-- end

	-- local activityRecord = self.foreverList.activityRecord
	-- local record = {}
	-- for i,v in ipairs(activityRecord) do
	-- 	local has = false
	-- 	for _,actId in ipairs(usedActId) do
	-- 		if actId == v.actId then
	-- 			has = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if has then
	-- 		table.insert(record, v)
	-- 	end
	-- end
	-- self.foreverList.activityRecord = record
	-- self:_writeForeverToFile()
end

function PushActivity:_resetPushRec()
	self.recList = {}
	self.recList.updateTime = 631123200000 -- 1/1/1990
	self.recList.activityRecord = {}
	self.recList.levelFailRecord = {}
	self.recList.comeToFrontRecord = 0
	self.recList.levelFailPush = {}
	self.recList.energyPush = {}
	self.recList.timePush = {}
	self.recList.popImmediatelyRecord = {}

	self.foreverList = {}
	self.foreverList.activityRecord = {}
end

function PushActivity:_readFromFile()
	local path = HeResPathUtils:getUserDataPath() .. "/pushrec"
	local hFile, err = io.open(path, "r")
	local text
	if hFile and not err then
		text = hFile:read("*a")
		io.close(hFile)
		if type(text) == "string" and string.len(text) > 2 then
			self.recList = table.deserialize(text)
		end
	end
end

function PushActivity:_writeToFile()
	self.recList.updateTime = Localhost:time()
	local path = HeResPathUtils:getUserDataPath() .. "/pushrec" 
	Localhost:safeWriteStringToFile(table.serialize(self.recList), path)
end

function PushActivity:_readForeverFromFile()
	local path = HeResPathUtils:getUserDataPath() .. "/pushrecforever"
	local hFile, err = io.open(path, "r")
	if hFile and not err then
		local text = hFile:read("*a")
		io.close(hFile)
		if type(text) == "string" and string.len(text) > 2 then
			self.foreverList = table.deserialize(text) or {}
		end
	end
end

function PushActivity:_writeForeverToFile()
	local path = HeResPathUtils:getUserDataPath() .. "/pushrecforever" 
	Localhost:safeWriteStringToFile(table.serialize(self.foreverList), path)
end