local MauNumberOnePanel = require "zoo.localActivity.mauNumberOne.MauNumberOnePanel"

MauNumberOneManager = class()
local instance = nil
local kLastPopTime = "mau_No.1_last_pop_time"

local function parseTime( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

local beginTime = parseTime("2019-01-24 10:00:00")
local endTime = parseTime("2019-02-28 23:59:59")

function MauNumberOneManager.getInstance()
	if not instance then
		instance = MauNumberOneManager.new()
		instance:init()
	end
	return instance
end

function MauNumberOneManager:init()
	self.rewardId = 22

	self.userDefault = CCUserDefault:sharedUserDefault()
	self.lastPopTime = tonumber(self.userDefault:getStringForKey(kLastPopTime)) or 0

	self.rightGameVersion = false
	local gameVersion = string.split(_G.bundleVersion, '.')
	if gameVersion and gameVersion[1] and gameVersion[1] == '1' and gameVersion[2] and gameVersion[2] == '64' then
		self.rightGameVersion = true
	end
end

function MauNumberOneManager:getRewards()
	return MetaManager.getInstance():getRewards(self.rewardId)
end

function MauNumberOneManager:updateLastPoptime()
	self.lastPopTime = tostring(Localhost:timeInSec())
	self.userDefault:setStringForKey(kLastPopTime, self.lastPopTime)
   	self.userDefault:flush()
end

function MauNumberOneManager:shouldShowIconBtn()
	--version
	if not self.rightGameVersion then
		return false
	end
	--rewarded
	if UserManager:getInstance():isUserRewardBitSet(self.rewardId) then 
		return false
	end
	--time
	local now = Localhost:timeInSec()
	if now < os.time(beginTime) or now > os.time(endTime) then
		return false
	end

	return true
end

function MauNumberOneManager:removeIconBtn()
	local scene = HomeScene:sharedInstance()
	if scene then
		scene:removeMauNumberOneButton() 
	end
end

function MauNumberOneManager:checkPanelCanPop()
	if not self:shouldShowIconBtn() then 
		return false 
	end
	return compareDate(os.date('*t', Localhost:timeInSec()), os.date('*t', self.lastPopTime or 0)) ~= 0
end

function MauNumberOneManager:popoutPanel(endCallback)
	local panel = MauNumberOnePanel:create(endCallback)
	panel:popout()
end

function MauNumberOneManager:addInfiniteEnergy(rewards, onSuccess, onFail)
	local http = GetRewardsHttp.new(true)
	http:ad(Events.kComplete, function (evt)
		UserManager:getInstance():addRewards(rewards)
        UserService:getInstance():addRewards(rewards)
        GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kActivity, rewards, DcSourceType.kActPre.."Mau_No_1")

		UserManager:getInstance():setUserRewardBit(self.rewardId, true)
		UserService:getInstance():setUserRewardBit(self.rewardId, true)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		end

		if onSuccess then onSuccess() end
	end)
	http:addEventListener(Events.kError, function (evt)
		local errCode = evt and evt.data or 0
		if onFail then onFail(errCode) end
	end)
	http:load(self.rewardId)
end

function MauNumberOneManager:useInfiniteEnergy(rewards, endCallback)
	for _, v in pairs(rewards) do
		if v.itemId == ItemType.INFINITE_ENERGY_BOTTLE then
			local logic = UseEnergyBottleLogic:create(v.itemId, DcFeatureType.kActivity, DcSourceType.kActPre.."Mau_No_1")
			logic:setUsedNum(v.num)
			logic:setSuccessCallback(endCallback)
			logic:start(true)			
			break 
		end
	end
end

function MauNumberOneManager:shareLink(onShareSuccess, onShareFail, onShareCancel)
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local title = localize('荣耀与你共享，登录游戏即可领取【24小时无限精力】，闯关闯不停~')
	local message = ''
	local shareUrl = 'https://mp.weixin.qq.com/s?__biz=MzA5MjA0NDQxMA==&mid=2695637686&idx=1&sn=48ddacc9d531363965fa8dcafd1fe766&chksm=b52ba7a3825c2eb5876440f79af97605f6895dcc0ed2c800d33532581d3deea8db7e694f7a9e&token=1392981328&lang=zh_CN#rd'
	local shareCallback = {
		onSuccess = function(result)
			CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
			if onShareSuccess then onShareSuccess() end
		end,
		onError = function(errCode, errMsg)
			CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
			if onShareFail then onShareFail() end
		end,
		onCancel = function()
			CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
			if onShareCancel then onShareCancel() end
		end
	}
	
	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	local shareType = SnsUtil.getShareType()
	SnsUtil.sendLinkMessage(shareType, title, message, thumb, shareUrl, true, shareCallback)
end