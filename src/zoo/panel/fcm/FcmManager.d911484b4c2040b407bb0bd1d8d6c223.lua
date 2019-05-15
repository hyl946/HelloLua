--防沉迷
local FcmPanel = require 'zoo.panel.fcm.FcmPanel'
local FcmTip = require 'zoo.panel.fcm.FcmTip'

FcmManager = class()

local bOpen							--开关是否打开
local time 							--开始时间
local times 						--防沉迷的几档时间配置，单位是分钟
local panelLevel					--弹窗级别
local recoverDiscount = 1 			--回复精力值单位时间系数
local recoverDiscountEndTime = 0    --recoverDiscount启动时的时间戳

FcmConst = table.const{
	step1 = 1,
	step2 = 2,
	step3 = 3,
	step4 = 5,
	discount0 = 0,
	discount50 = 50,
	discount100 = 100,
}

local function isOpen(bAgain)
	if bOpen == nil or bAgain then
		--printx(5, "isOpen")
		local key = "AntiAddictionFeature"
		local switch = MaintenanceManager:getInstance():isEnabled(key, false)
		if switch then
			bOpen = true

			local extra = MaintenanceManager:getInstance():getMaintenanceByKey(key).extra
			if extra then
				local extraArr = string.split(extra, ",")
				times = {}
				for _, v in ipairs(extraArr) do
					table.insert(times, tonumber(v))
				end
			end
		else
			bOpen = false
		end
	end

	return bOpen
end

local function sendOfflineHttp(param)
	local http = OpNotifyOffline.new()
	http:load(OpNotifyOfflineType.kFcm, param)
end

local function setRecoverDiscount(value)
	recoverDiscount = value
	UserManager:getInstance().user.recoverDiscount = value
	UserService:getInstance().user.recoverDiscount = value
end

local function setRecoverDiscountEndTime(value)
	--printx(5, "setRecoverDiscountEndTime", tostring(value))
	recoverDiscountEndTime = value
	UserManager:getInstance().user.recoverDiscountEndTime = value
	UserService:getInstance().user.recoverDiscountEndTime = value
end

function FcmManager:init()
	--printx(5, "FcmManager:init", isOpen())
	if not isOpen(true) then return end
	recoverDiscount = UserManager:getInstance().user.recoverDiscount or 100
	recoverDiscountEndTime = UserManager:getInstance().user.recoverDiscountEndTime or 0

	--printx(5, recoverDiscount, recoverDiscountEndTime)
	if self:getLeftTime() <= 0 then
		self:reset()
	end

	if recoverDiscount == FcmConst.discount50 then 
		self:reset()
		sendOfflineHttp(-1)
	elseif recoverDiscount == FcmConst.discount0 then
		if self:getLeftTime() <= 0 then
			self:reset()
		end
	end
	--printx(5, recoverDiscount, recoverDiscountEndTime)

	panelLevel = 0
	self:start()
end

function FcmManager:start()
	--printx(5, "FcmManager:start", isOpen())
	if not isOpen() then return end
	time = Localhost:timeInSec()
	if panelLevel == nil or panelLevel < FcmConst.step3 then 
		panelLevel = 0
	end
end

function FcmManager:reset()
	--printx(5, "FcmManager:reset", isOpen())
	if not isOpen() then return end
	setRecoverDiscount(FcmConst.discount100)
	setRecoverDiscountEndTime(0)
	Localhost:flushCurrentUserData()
end

function FcmManager:showTip(close_cb)
	--printx(5, "FcmManager:showTip", isOpen())
	if not isOpen() then
		if close_cb then close_cb() end
		return
	end
	
	local function callback()
		Director.sharedDirector():exitGame()
	end

	local panel
	if recoverDiscount == FcmConst.discount0 then
		if self:getLeftTime() > 0 then  
			panel = FcmPanel:create(FcmConst.step4, callback)
		end
	else
		local passMinute = (Localhost:timeInSec() - time) / 60
		if passMinute >= times[4] then
			if panelLevel < FcmConst.step4 then
				UserLocalLogic:refreshEnergy() 
				setRecoverDiscount(FcmConst.discount0)
				setRecoverDiscountEndTime(Localhost:time() + 18000000)
				Localhost:flushCurrentUserData()
				sendOfflineHttp(FcmConst.step4)
				panel = FcmPanel:create(FcmConst.step4, callback)
				panelLevel = FcmConst.step4
			end	
		elseif passMinute >= times[3] then
			if panelLevel < FcmConst.step3 then 
				UserLocalLogic:refreshEnergy()
				setRecoverDiscount(FcmConst.discount50)
				setRecoverDiscountEndTime(Localhost:time() + (times[4] - times[3]) * 60000)
				Localhost:flushCurrentUserData()
				sendOfflineHttp(FcmConst.step3)
				panel = FcmPanel:create(FcmConst.step3)
				panelLevel = FcmConst.step3
			end
		elseif passMinute >= times[2] then
			if panelLevel < FcmConst.step2 then
				panel = FcmPanel:create(FcmConst.step2)
				panelLevel = FcmConst.step2
			end
		elseif passMinute >= times[1] then
			if panelLevel < FcmConst.step1 then
				panel = FcmPanel:create(FcmConst.step1)
				panelLevel = FcmConst.step1
			end
		else
		end
	end

	if panel then
		local scene = Director:sharedDirector():getRunningScene()
		if scene then
			scene:runAction(CCCallFunc:create(function()
				panel:popout(close_cb)
			end))
		end
	end
end

function FcmManager:showLoadingTip()
	--printx(5, "FcmManager:showLoadingTip", isOpen())
	if not isOpen() then return end
	local panel = FcmTip:create()
	panel:popout()
end

function FcmManager:getTimeScale()
	if not isOpen() then 
		return 1
	else
		if recoverDiscount == FcmConst.discount0 then
			return 38.5
		elseif recoverDiscount == FcmConst.discount50 then
			return 2
		else
			return 1
		end
	end
end

function FcmManager:getLeftTime()
	if not isOpen() then 
		return 0
	else
		local leftTime = recoverDiscountEndTime - Localhost:time()
		return leftTime < 0 and 0 or leftTime
	end
end

function FcmManager:showTime()
	local showTime
	if time then
		showtime = Localhost:timeInSec() - time
	else
		showtime = 0
	end 
	return convertSecondToHHMMSSFormat(showtime)
end