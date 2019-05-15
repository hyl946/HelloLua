local PrivilegeConfig = require "zoo.privilege.PrivilegeConfig"

PrivilegeMgr = class()

local instance = nil
local VERSION = 1
local kStorageFileName = "privilege_"..VERSION.."_"
local kLocalDataExt = ".ds"

function PrivilegeMgr.getInstance()
	if not instance then
		instance = PrivilegeMgr.new()
		instance:init()
	end
	return instance
end

function PrivilegeMgr:init()
	self.uid = getSafeUid()
	self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt

	self.privilegeInfo = {}
	self:readFromLocal()
end

--更新特权信息 ...中是每种特权对应的参数 注意传入顺序
function PrivilegeMgr:updatePrivilege(_type, level, endTime, isInit, ...)
	local priInfo = self.privilegeInfo[_type]
	if endTime > Localhost:time() then
		if not priInfo then 
			local voClass = PrivilegeConfig:getVOClass(_type)
			if voClass then 
				priInfo = voClass.new()
			end
		end
		if priInfo then 
			priInfo.endTime = endTime
			local otherParams = {...}
			if _type == PrivilegeType.kPreProp then 
				priInfo.level = level
				priInfo.preItemIDs = otherParams[1]
			elseif _type == PrivilegeType.kRankRace then 
				priInfo.level = level
				priInfo.extraNumRed = otherParams[1]
				priInfo.extraNumYellow = otherParams[2]
				if not isInit and priInfo.extraNumYellow > 0 then 
					RankRaceMgr:getInstance():incTC1(priInfo.extraNumYellow)
				end
			elseif _type == PrivilegeType.kDiscountBuy then 
				priInfo.level = level
				priInfo.extraItemId = otherParams[1]
				priInfo.discountGoodsIDs = otherParams[2]
				if not isInit and priInfo.extraItemId then 
					local rewardInfo = {itemId = priInfo.extraItemId, num = 1}
					UserManager:getInstance():addReward(rewardInfo)
					UserService:getInstance():addReward(rewardInfo)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivityInner, rewardInfo.itemId, rewardInfo.num, DcSourceType.kActPre.."privilege_discoutbuy_free")
				end
			end

			self.privilegeInfo[_type] = priInfo

			if not isInit then 
				self:writeToLocal()
			end
		end
	else
		if priInfo then 
			self.privilegeInfo[_type] = nil
			if not isInit then 
				self:writeToLocal()
			end
		end
	end
end

function PrivilegeMgr:isPrivilegeEffctive(_type)
	local priInfo = self.privilegeInfo[_type]
	if priInfo then
		if priInfo.endTime and priInfo.endTime > Localhost:time() then 
			if _type == PrivilegeType.kPreProp then 
				local leftMesc = priInfo.endTime - Localhost:time()
				return true, priInfo.preItemIDs, leftMesc
			elseif _type == PrivilegeType.kRankRace then
				return true, priInfo.extraNumRed
			elseif _type == PrivilegeType.kDiscountBuy then
				return true, priInfo.discountGoodsIDs
			end
		else
			self.privilegeInfo[_type] = nil
			self:writeToLocal()
		end
	end
	return false
end

function PrivilegeMgr:readFromLocal()
	local file, err = io.open(self.filePath, "r")
	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)
		if data and type(data) == "table" then
			for k,v in pairs(data) do
				local key = tonumber(k)
				local voClass = PrivilegeConfig:getVOClass(key)
				if voClass then 
					local vo = voClass.new()
					if vo:decode(v) then 
						local endTime = vo.endTime
						if endTime and endTime > Localhost:time() then 
							self.privilegeInfo[key] = vo
						else
							self.privilegeInfo[key] = nil
						end
					else
						self.privilegeInfo[key] = nil
					end
				end
			end
		end
	end
end

function PrivilegeMgr:writeToLocal()
	local data = {}
	for k,v in pairs(self.privilegeInfo) do
		data[k] = v:toObject()
	end
	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end