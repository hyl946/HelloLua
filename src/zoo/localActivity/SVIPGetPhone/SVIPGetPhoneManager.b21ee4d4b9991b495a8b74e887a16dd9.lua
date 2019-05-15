

require 'zoo.localActivity.SVIPGetPhone.SVIPGetRewardPanel'

SVIPGetPhoneManager = class()

local instance = nil

local ACT_SOURCE = 'SVIPGetPhone/Config.lua'

local VERSION = "1_"	--本地缓存标识 每次换皮应更改 
local kStorageFileName = "SVIPGetPhoneManager"..VERSION
local kLocalDataExt = ".ds"

local HideTime = 60*60*24*4*1000 --4天后再现

function SVIPGetPhoneManager.getInstance()
	if not instance then
		instance = SVIPGetPhoneManager.new()
		instance:init()
	end
	return instance
end

local function getUid()
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	uid = tostring(uid)
	return uid
end

function SVIPGetPhoneManager:init()

    self.StartTime = 0
    self.EndTime = 0
    self.CDTime = 60*30 --30分钟 单位秒
    self.PhoneCodeCDTime = 0
    self.NeedPopOut = 0
    self.MergeUserID = ""

    self.bGetRewardSucess = false

    self.uid = getUid()
    self.filePath = HeResPathUtils:getUserDataPath() .. "/" .. kStorageFileName .. self.uid .. kLocalDataExt


    self:readFromLocal()
    self:InitSVIPInfo()
end

function SVIPGetPhoneManager:IsCanShowIcon( )

    self:InitSVIPInfo()

    if self.StartTime == 0 then
        return false
    else
        local CurTime =  Localhost:time()

        if CurTime >= self.StartTime and CurTime <= self.StartTime + self.CDTime*1000 then
            return true
        end
    end

    return false
end

--活动发给管理器信息
function SVIPGetPhoneManager:InitSVIPInfo( )

    local userManager = UserManager:getInstance()

    local bFrush = false
    local EndTime = tonumber(userManager.endTimeOfBindPhoneIcon)
    if self.EndTime == 0 or ( self.EndTime ~=0 and EndTime ~= 0 and self.EndTime ~= EndTime )then
        bFrush = true
    end

    if bFrush then
        local OldTime = self.EndTime
        local CurTIme = tonumber(userManager.endTimeOfBindPhoneIcon) or 0
        if CurTIme ~= 0 and OldTime ~= CurTIme then
            self.NeedPopOut = 1
        end

        self.EndTime = tonumber(userManager.endTimeOfBindPhoneIcon) or 0
    --    self.EndTime = Localhost:time() +  self.CDTime*1000
        self.StartTime = self.EndTime - self.CDTime*1000
        if self.StartTime < 0 then self.StartTime = 0 end
        self:writeToLocal()
    end
end

function SVIPGetPhoneManager:setMergeID( uid )
    self.MergeUserID = uid
end

function SVIPGetPhoneManager:getMergeID()
    return self.MergeUserID
end

function SVIPGetPhoneManager:setGetRewardSucess()
    self.bGetRewardSucess = true
end

function SVIPGetPhoneManager:getGetRewardSucess()
    return self.bGetRewardSucess
end

function SVIPGetPhoneManager:getEndTime()
    return self.EndTime
end

function SVIPGetPhoneManager:getCanShowTime()
    local endTime = self.EndTime / 1000
    local CurTime = Localhost:time() / 1000 

    local HaveTime = 0

    if CurTime <= endTime then
        HaveTime = endTime - CurTime
    end

    return HaveTime
end

function SVIPGetPhoneManager:setPhoneCodeCDTime( num )
    self.PhoneCodeCDTime = num
end

function SVIPGetPhoneManager:getPhoneCodeCDTime()
    return self.PhoneCodeCDTime
end

function SVIPGetPhoneManager:setNeedPopOut()
    self.NeedPopOut = 0
end

function SVIPGetPhoneManager:getNeedPopOut()
    return self.NeedPopOut
end

function SVIPGetPhoneManager:CurIsHaveIcon()

    self:InitSVIPInfo()

    local bHaveSVIPActivity = false
    ----SVIP 绑定手机活动 不弹实名认证手机部分
    local isActOn = self:isActOn()

    if isActOn and not PlatformConfig:isPlatform( PlatformNameEnum.kOppo ) then

        local HaveTime = self:getCanShowTime()

        if HaveTime > 0 then
            bHaveSVIPActivity = true 
        end
    end
    ----

    return bHaveSVIPActivity
end

function SVIPGetPhoneManager:openActivity()
    local version = nil
    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
        if v.source == ACT_SOURCE then 
        	version = v.version
        	break
        end
    end

    ActivityData.new({source=ACT_SOURCE,version=version}):start(false, false, nil, nil, nil)
end

function SVIPGetPhoneManager:canForcePop( cb )
    local function needPopCb()
        if cb then cb(true) end
        return false
    end

    local function onError()
        if cb then cb(false) end
    end

    ActivityUtil:getActivitys(function( activitys )
        local activity = table.find(activitys,function( v )
            return tostring(v.source) == ACT_SOURCE
        end)
        
        if activity then
            local data = ActivityData.new(activity)
            data:start(false, false, nil, onError,nil, needPopCb)
        else
            onError()
        end
    end)
end

function SVIPGetPhoneManager:isActOn()
    local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        -- print(v.source)
        if v.source == ACT_SOURCE then
            config = require ('activity/'..v.source)
        end
    end

    return config and config.isSupport()
end

function SVIPGetPhoneManager:newOpNotifyHttp(onRequestSuccess, onRequestFail, onRequestCancel, uid )

    if self:CurIsHaveIcon() == false then
        return
    end

    --打点
    local params = {
		game_type = "stage",
		game_name = "svip",
		category = 'SVIP',
		sub_category = "UI_svipphonenumber_complete",
        t1 = 3,
	}

	DcUtil:dcForUserTrack(params)

	local http = OpNotifyHttp.new(true)
    http:ad(Events.kComplete, onRequestSuccess)
    http:ad(Events.kError, onRequestFail)
    http:ad(Events.kCancel, onRequestCancel)

    local info = uid
	http:syncLoad(OpNotifyType.kSVIPGetPhoneGetReward, info )


end

function SVIPGetPhoneManager:Have101FlagNeedGetReward()

    local bHaveFlag = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kSVIPGetPhoneReward)

    local rewardId = 19

    if bHaveFlag and not UserManager:getInstance():isUserRewardBitSet(rewardId) then

        --获取奖励
        local newSVIPGetRewardPanel = SVIPGetRewardPanel:create()
        newSVIPGetRewardPanel:popout()
    end

end

function SVIPGetPhoneManager:readFromLocal()
	local file, err = io.open(self.filePath, "rb")

	if file and not err then
		local content = file:read("*a")
		io.close(file)

        local data = nil
        local function decodeContent()
            data = amf3.decode(content)
        end
        pcall(decodeContent)

		if data and type(data) == "table" then
			self.StartTime = data.StartTime or 0
            self.EndTime = data.EndTime or 0
--            self.PhoneCodeCDTime = data.PhoneCodeCDTime or 0
		end
	end
end

function SVIPGetPhoneManager:writeToLocal()
	local data = {}
	data.StartTime = self.StartTime
    data.EndTime = self.EndTime
--    data.PhoneCodeCDTime = self.PhoneCodeCDTime

	local content = amf3.encode(data)
    local file = io.open(self.filePath, "wb")
    -- assert(file, "DragonBuffManager persistent file failure " .. kStorageFileName)
    if not file then return end
	local success = file:write(content)
   
    if success then
        file:flush()
        file:close()
    else
        file:close()
    end
end
