local UserCallBackUtil = class()

function UserCallBackUtil.isNodeVisible(node)
	if node:isVisible() then
		if node:getParent() ~= nil then
			return UserCallBackUtil.isNodeVisible(node:getParent())
		else
			return true
		end
	else
		return false
	end
end

function UserCallBackUtil.getFullScreenUIPosXYScale( ... )
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
	local contentPosX = visibleOrigin.x + (visibleSize.width - 720 * scale) / 2
	local contentPosY = visibleOrigin.y + 1280 * scale
	return contentPosX, contentPosY, scale
end


function UserCallBackUtil:getRewardsConfigFromString(configStr)
    local ret = {}
    local rewards = string.split(configStr, ',')
    for k, v in pairs(rewards) do
        local item = string.split(v, ':')
        if #item == 2 then
            table.insert(ret, {itemId = tonumber(item[1]), num = tonumber(item[2])})
        end
    end
    return ret
end

function UserCallBackUtil:setKey(type, key, value, ignoreUid)
    if not ignoreUid then
        key = key .. '.' .. (UserManager:getInstance().user.uid or '12345')
    end
    if type == 'int' then
        CCUserDefault:sharedUserDefault():setIntegerForKey(key, value)
    elseif type == 'bool' then
        CCUserDefault:sharedUserDefault():setBoolForKey(key, value)
    elseif type == 'string' then
        CCUserDefault:sharedUserDefault():setStringForKey(key, value)
    end
end

function UserCallBackUtil:getKey(type, key, defaultValue)
    if not ignoreUid then
        key = key .. '.' .. (UserManager:getInstance().user.uid or '12345')
    end
    if type == 'int' then
        return CCUserDefault:sharedUserDefault():getIntegerForKey(key, defaultValue)
    elseif type == 'bool' then
        return CCUserDefault:sharedUserDefault():getBoolForKey(key, defaultValue)
    elseif type == 'string' then
        return CCUserDefault:sharedUserDefault():getStringForKey(key, defaultValue)
    end
end

function UserCallBackUtil:normalizeNum(num)
    local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
    if num >= 10000 and ver>=43 then
        return tostring(num/10000)..'万'
    else
        return tostring(num)
    end
end

local function isSample(percent)
	if isLocalDevelopMode then return true end
	local uuid = MetaInfo:getInstance():getUdid()
	local tail = string.sub(string.lower(uuid), -4)
	local tailInt = tonumber(tail, 16)
	local fullRange = math.pow(16, 4)
	local sampleRange = math.floor(fullRange * (percent / 100))
	if tailInt and type(tailInt) == "number" and tailInt <= sampleRange then
		return true
	else
		return false
	end
end


local function dc_log_send(acType, data)
	local platformName = StartupConfig:getInstance():getPlatformName()
	if PrepackageUtil:isPreNoNetWork() then return end
	data.platform = platformName
	table.each(data, function (v, k)
	if (type(v) ~= "string") then
		data[k] = tostring(v)
	end
	end)
	HeDCLog:getInstance():send(acType, data)
end

-- doSampling: 是否是概率打点（抽样） 概率10%
local function send(acType, data, doSampling)
	if not doSampling then
		doSampling = false
	end
	if doSampling then
		if isSample(10) then
			if data.sub_category then
				data.sub_category = 'G_'..data.sub_category
			end
			dc_log_send(acType, data)
		else
			return
		end
	else
		dc_log_send(acType, data)
	end
end

--用户获取银币
function UserCallBackUtil:logCreateCoin(module, num, coin, currentStage)
	send(72, {
		module = module,
		num = num,
		coin1 = coin,
		coin2 = coin + num,
		num = num,
		currency = "game coins",
		current_stage = currentStage,
		stage_mode = math.floor(currentStage / 10000),
		high_stage = UserManager:getInstance().user:getTopLevelId(),
		})
end

--用户获取风车币
function UserCallBackUtil:logCreateCash(module, num, cash, currentStage)
	send(72, {
		module = module,
		num = num,
		coin1 = cash,
		coin2 = cash + num,
		num = num,
		currency = "happy coins",
		current_stage = currentStage,
		stage_mode = math.floor(currentStage / 10000),
		high_stage = UserManager:getInstance().user:getTopLevelId(),
		})
end

return UserCallBackUtil