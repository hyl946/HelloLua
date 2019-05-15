---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2019-03-06 15:50:31
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-03-11 15:55:17
---------------------------------------------------------------------------------------
-- 同步数据前记录本地用户数据，同步时cache关键请求数据，User同步完成后清除数据
SyncDataHelper = {}
 
-- 记录打点要用的数据
function SyncDataHelper:initCacheData()
    self.cacheData = {
        id = Localhost:timeInSec(), -- 作为数据和请求打点的联查字段
        userData = nil, -- 本地用户数据
        httpDatas = {} -- 关键离线请求数据
    }
end

function SyncDataHelper:cacheUserData(userData)
	if self.cacheData and userData then
		local userBean = userData.user
		-- 需要对比的数据
		local localUserData = {}
		local user = {}
		user.uid = userBean.uid
		user.topLevelId = userBean.topLevelId
		user.star = userBean.star
		user.hideStar = userBean.hideStar
		user.coin = userBean.coin
		user.cash = userBean.cash
		user.energy = userBean.energy
		localUserData.user = user

		if userData.props then
			local props = {}
			for i, prop in ipairs(userData.props) do
				props[i] = {itemId = prop.itemId, num = prop.num}
			end
			localUserData.props = props
		end

		if userData.timeProps then
			local props = {}
			for i, prop in ipairs(userData.timeProps) do
				props[i] = {itemId = prop.itemId, num = prop.num, expireTime = prop.expireTime}
			end
			localUserData.timeProps = props
		end
		self.cacheData.userData = localUserData
	end
end
 
-- sync时记录离线请求数据
function SyncDataHelper:addHttpData(httpData)
    if self.cacheData and httpData then
		local cacheHttp = {}
		local httpBody = httpData.body or {}
		cacheHttp.m_endPoint = httpData.endpoint
		cacheHttp.m_requestTime = httpBody.__offlineRequestTime
    	if httpData.endpoint == kHttpEndPoints.startLevel then -- 只记录特定请求和字段
			cacheHttp.m_levelId = httpBody.levelId
			cacheHttp.m_energyBuff = httpBody.energyBuff
			cacheHttp.m_prebuffGrade = httpBody.prebuffGrade
			cacheHttp.m_itemList = httpBody.itemList and table.concat(httpBody.itemList, "_") or nil
		elseif httpData.endpoint == kHttpEndPoints.passLevel then
			cacheHttp.m_levelId = httpBody.levelId
			cacheHttp.m_score = httpBody.score
			cacheHttp.m_star = httpBody.star
			cacheHttp.m_coin = httpBody.coin
			cacheHttp.m_targetCount = httpBody.targetCount
			cacheHttp.m_strategy = httpBody.strategy
			cacheHttp.m_giveUp = httpBody.giveUp
			local usePropList = nil
			if httpBody.usedProps then
				usePropList = ""
				for i, v in ipairs(httpBody.usedProps) do
					if i == 1 then
						usePropList = string.format("%d_%d",v.itemId, v.num)
					else
						usePropList = string.format("%s;%d_%d", usePropList, v.itemId, v.num)
					end
				end
				cacheHttp.m_usedProps = usePropList
			end
		-- elseif httpData.endpoint == kHttpEndPoints.useProps then
		-- 	cacheHttp.m_levelId = httpBody.levelId
		-- 	cacheHttp.m_type = httpBody.type
		-- 	local itemList = nil
		-- 	cacheHttp.m_itemList = httpBody.itemList and table.concat(httpBody.itemList, "_") or nil
		-- 	cacheHttp.m_returnType = httpBody.returnType
		-- 	cacheHttp.m_returnItemId = httpBody.returnItemId
		-- 	cacheHttp.m_returnExpireTime = httpBody.returnExpireTime
		-- elseif httpData.endpoint == kHttpEndPoints.buy then
		-- 	cacheHttp.m_goodsId = httpBody.goodsId
		-- 	cacheHttp.m_num = httpBody.num
		-- 	cacheHttp.m_moneyType = httpBody.moneyType
		-- 	cacheHttp.m_targetId = httpBody.targetId
		else
			-- 其他的不保存
			return
	    end
        table.insert(self.cacheData.httpDatas, cacheHttp)
    end
end
 
-- 清除记录数据
function SyncDataHelper:clearCacheData()
    self.cacheData = nil
end
 
function SyncDataHelper:isWorking()
    return self.cacheData ~= nil
end

function SyncDataHelper:getCachedUserData()
	return self.cacheData and self.cacheData.userData or nil
end

function SyncDataHelper:getCachedHttpData()
	return self.cacheData and self.cacheData.httpDatas or nil
end

function SyncDataHelper:addUserDataForDC(dcData, prefix, userData)
	dcData = dcData or {}
	prefix = prefix or ""
	local user = userData.user
	dcData[prefix.."topLevelId"] = user.topLevelId
	dcData[prefix.."star"] = user.star
	dcData[prefix.."hideStar"] = user.hideStar
	dcData[prefix.."coin"] = user.coin
	dcData[prefix.."gold"] = user.cash
	dcData[prefix.."energy"] = user.energy

	local propsLog = ""
	if userData.props then
		local sp = ""
		for _, v in pairs(userData.props) do
			if v.num > 0 then
				propsLog = string.format("%s%s%d_%d", propsLog, sp, v.itemId, v.num)
				sp = ";"
			end
		end
	end
	dcData[prefix.."props"] = propsLog

	local timePropsLog = ""
	if userData.timeProps then
		local mergeTimeProps = {}
		local key = ""
		for _, v in pairs(userData.timeProps) do
			local expireTime = math.floor(v.expireTime / 1000)
			key = v.itemId.."_"..expireTime
			if mergeTimeProps[key] then
				mergeTimeProps[key].num = mergeTimeProps[key].num + (v.num or 1)
			else
				mergeTimeProps[key] = {itemId = v.itemId, num = (v.num or 1), expireTime = expireTime}
			end
		end
		local sp = ""
		for _, v in pairs(mergeTimeProps) do
			if v.num > 0 then
				timePropsLog = string.format("%s%s%d_%d_%s", timePropsLog, sp, v.itemId, v.num, tostring(v.expireTime))
				sp = ";"
			end
		end
	end
	dcData[prefix.."timeProps"] = timePropsLog
end

function SyncDataHelper:dcUserData(serverUserData)
	-- 用户数据打点
	local dcData = {
		category = "device_change",
		sub_category = "user_data",
		m_id = self.cacheData.id,
		lastDeviceUdid = serverUserData.lastDeviceUdid,
	}
	SyncDataHelper:addUserDataForDC(dcData, "ct_", self.cacheData.userData)
	SyncDataHelper:addUserDataForDC(dcData, "sr_", serverUserData)

	DcUtil:log(AcType.kExpire30Days, dcData)
end

function SyncDataHelper:dcHttpData()
	if table.isEmpty(self.cacheData.httpDatas) then
		return
	end
	-- 离线请求打点, 如果离线请求数量太多会不会卡？
	for _, httpData in ipairs(self.cacheData.httpDatas) do
		local dcData = {
			category = "device_change",
			sub_category = "offline_request",
			m_id = self.cacheData.id,
		}
		for k, v in pairs(httpData) do
			dcData[k] = v
		end
		DcUtil:log(AcType.kExpire30Days, dcData)
	end
end

function SyncDataHelper:clearHttpData()
	if not self.cacheData then return end
	self.cacheData.httpDatas = {}
end

function SyncDataHelper:dcWithServerUserData(serverUserData)
	if not self.cacheData then return end
	SyncDataHelper:dcUserData(serverUserData)
	SyncDataHelper:dcHttpData()
end

function SyncDataHelper:checkUserDeviceChanged(serverUserData)
	if not (self.cacheData and self.cacheData.userData and serverUserData) then
		return false
	end
	-- check device udid
	if (not serverUserData.lastDeviceUdid) or serverUserData.lastDeviceUdid == MetaInfo:getInstance():getUdid() then
		return false
	end
	if serverUserData.user and self.cacheData.userData.user
			and tostring(serverUserData.user.uid) == tostring(self.cacheData.userData.user.uid) then
		return true
	end
	return false 
end