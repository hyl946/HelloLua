--[[
	腾讯应用宝积分墙
--]]

yybAdWallHttp = class(HttpBase)
function yybAdWallHttp:load(requestData)
	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp("yybAdWall", requestData)
		
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

		context:onLoadingComplete() 
		
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
			context:onLoadingComplete(data)
	    end
	end

	self.transponder:call("yybAdWall", requestData, loadCallback, rpc.SendingPriority.kHigh, false)
end

local SurePanel = class(BasePanel)

function SurePanel:create(goldNum)
	local instance = SurePanel.new()
	instance:loadRequiredResource("ui/supper_sure_panel.json")
	instance:init(goldNum)
	return instance
end

function SurePanel:init( goldNum )
	self.ui = self:buildInterfaceGroup('supper_sure_panel')
	BasePanel.init(self, self.ui)

	self.okBtn = GroupButtonBase:create(self.ui:getChildByName('sure'))
	self.okBtn:setEnabled(true)
	self.okBtn:setString(Localization:getInstance():getText('button.ok'))
	local function onTab( ... )
		local anim = FlyItemsAnimation:create({{itemId = ItemType.GOLD, num = goldNum}})
		local bounds = self.ui:getChildByName("gold"):getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()
        
		self:onCloseBtnTapped()
	end
	self.okBtn:addEventListener(DisplayEvents.kTouchTap, onTab)

	self.title = self.ui:getChildByName('title')
	self.title:setText(Localization:getInstance():getText('yingyongbao.task.title'))

	self.title = self.ui:getChildByName('tips')
	self.title:setString(Localization:getInstance():getText('yingyongbao.task.text'))

	local num = self.ui:getChildByName('num')
	local position = num:getPosition()
	self.num = BitmapText:create("x" .. tostring(goldNum),"fnt/target_amount.fnt")
 	self.num:setAnchorPoint(ccp(0,1))
 	self.num:setPosition(ccp(position.x - 5, position.y - 10))
 	self.num:setScale(1.4)
 	self.ui:addChild(self.num)
end

function SurePanel:popout()
	self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
end

function SurePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
end

local function getQuotaData()
	local quotaData = UserManager:getInstance().yybAdWallLimit
	if _G.isLocalDevelopMode then printx(0, "QuotaData:" .. table.tostring(quotaData)) end

	local quotaDirt = false
	local curDate = os.date("*t", Localhost:timeInSec())
	local mruDate = os.date("*t", quotaData[1])

	if _G.isLocalDevelopMode then printx(0, "[----]", curDate.month, curDate.day, mruDate.month, mruDate.day) end
	if mruDate.month ~= curDate.month then
		-- new month
		quotaData[4] = 0
		quotaData[2] = 0
		quotaDirt = true
	end

	if mruDate.day ~= curDate.day then
		-- new day
		quotaData[2] = 0
		quotaDirt = true
	end

	-- flush
	if quotaDirt and NetworkConfig.writeLocalDataStorage then
		quotaData[1] = Localhost:timeInSec()
		UserService:getInstance().yybAdWallLimit = quotaData
        Localhost:getInstance():flushCurrentUserData()
	else 
		if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
	end

	if _G.isLocalDevelopMode then printx(0, "NewQuotaData:" .. table.tostring(quotaData)) end
	return quotaData
end

SupperAppManager = {}

function SupperAppManager:init( ... )
	self.passDayTimeOutID = nil
	self.entryFunc = {}

	--0sdk初始化失败
	local function sdkFunc( ... )
		return self:isInitSucceeded()
	end

	--1等级要求
	local function levelFunc()
		local level = UserManager.getInstance().user:getTopLevelId()
		return level >= 44
	end

	--2非付费玩家
	local function moneyFunc()
		if self.payUser ~= nil then 
			return not self.payUser 
		end
		local userExtend = UserManager:getInstance().userExtend
		self.payUser = userExtend.payUser
		return not userExtend.payUser
	end

	--3有网
	local function networkFunc( ... )
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local Context = luajava.bindClass("android.content.Context")
		local ConnectivityManager = luajava.bindClass("android.net.ConnectivityManager")

		local connectMgr = MainActivityHolder.ACTIVITY:getContext():getSystemService(Context.CONNECTIVITY_SERVICE)

		local networkInfo = connectMgr:getActiveNetworkInfo()

		if networkInfo == nil then return false end

		return networkInfo:isConnected()
	end

	--4其他：每次开放此条件用户的10%，根据数据结果可能再做放量的调整
	local function streamFunc( ... )
		if MaintenanceManager:getInstance():isEnabled("YYBTaskFreeMoney") ~= true then
			return false
		end

		local num = MaintenanceManager:getInstance():getValue("YYBTaskFreeMoney")
		if num == nil then num = 100 end
		num = tonumber(num)
		local uid = UserManager.getInstance().user.uid
		uid = tonumber(uid)
		if uid ~= nil then
			return (uid % 100) < num
		end
		return false
	end

	--5配额
	local function quotaFunc()
		return self:checkQuota(0)
	end

	-- table.insert(self.entryFunc, sdkFunc)
	table.insert(self.entryFunc, levelFunc)
	table.insert(self.entryFunc, moneyFunc)
	table.insert(self.entryFunc, networkFunc)
	table.insert(self.entryFunc, streamFunc)
	table.insert(self.entryFunc, quotaFunc)

	self.isInit = false

	local function initSupper()
		local manager = luajava.bindClass('com.happyelements.android.platform.tencent.SupperAppManager')
		self.manager = manager:getInstance()

		local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function (result)
	            self:checkData(result)
	        end,
	        onError = function (code, errMsg)
	           self:onError(code, errMsg)
	        end,
	        onCancel = function ()
	           self:onCancel()
	        end
	    });

	    self.manager:registerCallback(callback)
	end

	-- pcall(initSupper)
end

function SupperAppManager:initSDK( success_cb )
	if _G.isLocalDevelopMode then printx(0, "initSupperAppSDK---1") end
	if self.manager then
		local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function (result)
	        	self.isInit = true
	            success_cb()
	            DcUtil:UserTrack({ category='activity', sub_category='request_ad_success'})
	        end,
	        onError = function (code, errMsg)
	           self.isInit = false
	           DcUtil:UserTrack({ category='activity', sub_category='request_ad_fail'})
	        end,
	        onCancel = function ()
	        end
   	 	});
   	 	if _G.isLocalDevelopMode then printx(0, "initSupperAppSDK---2") end
		self.manager:initSupperAppSDK(callback)
	end
end

--检测是否需要显示积分墙入口
function SupperAppManager:checkEntry()
	--[[
	if not __ANDROID then return false end

	local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME)
	if payment:isEnabled() then
		return false
	end
	
	for _,func in ipairs(self.entryFunc) do
		if func() == false then
			return false
		end
	end
	return true
	]]
	return false
end

--显示积分墙
function SupperAppManager:showJiFenView( ... )
	if self:isInitSucceeded() == false then
		--TODO:show init error
		if _G.isLocalDevelopMode then printx(0, "suppersdk-->show init error") end
		return
	end

	if self.manager then
		self.manager:showJiFenView()
	end
end

--查询是否有任务完成
function SupperAppManager:checkData( ... )
	if self:checkEntry() == false then return end

	local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            self:onSuccess(result)
        end,
        onError = function (code, errMsg)
           self:onError(code, errMsg)
        end,
        onCancel = function ()
           self:onCancel()
        end
    });

    if self.manager then
    	local function check()
    		self.manager:checkData(callback)
    	end
    	pcall(check)
    end
end

--检查配额是否还有剩余
function SupperAppManager:checkQuota(delta)
	delta = delta or 0
	local quotaData = getQuotaData()
	if _G.isLocalDevelopMode then printx(0, "checkQuota:" .. table.tostring(quotaData)) end
	if (quotaData[2] + delta) < quotaData[3] and (quotaData[4] + delta) < quotaData[5] then
		return true
	else
		return false
	end
end

function SupperAppManager:showSurePanel( goldNum )
	local panel = SurePanel:create(goldNum)
	if panel then panel:popout() end
end

--任务奖励回调
function SupperAppManager:onSuccess( p )
	if p == nil then return end

	-- quotaCheck
	local tips
	local quotaData = getQuotaData()
	if not self:checkQuota(0) then
		if quotaData[4] >= quotaData[5] then
			-- monthly limit
			tips = Localization:getInstance():getText("yingyongbao.task.limit.tip2", {num = quotaData[5]})
		else
			-- daily limit
			tips = Localization:getInstance():getText("yingyongbao.task.limit.tip1", {num = quotaData[3]})
		end

		local function _showCommonTip( ... )
			CommonTip:showTip(tips, "negative")
		end
		setTimeOut(_showCommonTip, 0.2)
		return
	end

	-- quotaCheck
	local quotaIsOver = false
	local prize = luaJavaConvert.map2Table(p)
	if not self:checkQuota(prize.prizeNum) then
		quotaIsOver = true
		if (quotaData[4] + prize.prizeNum) >= quotaData[5] then
			-- monthly limit
			tips = Localization:getInstance():getText("yingyongbao.task.limit.tip2", {num = quotaData[5]})
		else
			-- daily limit
			tips = Localization:getInstance():getText("yingyongbao.task.limit.tip1", {num = quotaData[3]})
		end
	end

	local dailyQuota = math.max(0, quotaData[3] - quotaData[2])
	local monthQuota = math.max(0, quotaData[5] - quotaData[4])
	local quota = math.min(dailyQuota, monthQuota)
	local coins = math.min(quota, prize.prizeNum)

	local requestData = {
		tradeId = prize.tradeId,
		prizeNum = prize.prizeNum,
		taskIndex = prize.taskIndex,
		issueNum = prize.issueNum,
		taskId = prize.taskId,
		appId = prize.appId,
		taskGroup = prize.taskGroup,
		totalNum = prize.totalNum,
		issueTime = prize.issueTime,
		moneyUnit = prize.moneyUnit,
		signature = prize.signature,
		cashNum = coins
	}

	if _G.isLocalDevelopMode then printx(0, "suppersdk-->lua onSuccess") end
	if _G.isLocalDevelopMode then printx(0, table.tostring(requestData)) end

	local function onSuccess(event)
		if _G.isLocalDevelopMode then printx(0, "suppersdk jifen add coin success !") end
		SyncManager.getInstance():sync()
		UserManager:getInstance():addCash(coins)
        UserService:getInstance():addCash(coins)
        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, ItemType.GOLD, coins, DcSourceType.kQQWallReward)

		-- 修改数量
		quotaData[2] = quotaData[2] + coins
		quotaData[4] = quotaData[4] + coins
		UserService:getInstance().yybAdWallLimit = table.clone(quotaData, true)

        if NetworkConfig.writeLocalDataStorage then
         	Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end

		if _G.isLocalDevelopMode then printx(0, "suppersdk jifen add coin success !") end
		DcUtil:UserTrack({ category='activity', sub_category='push_ad_award1', num = coins})
		
		local function _showSurePanel( ... )
			BuyObserver:sharedInstance():onBuySuccess()
			self:showSurePanel(coins)
			if tips then
				CommonTip:showTip(tips, "negative")
			end

			if quotaIsOver then
				-- 关闭入口 && 开启跨天定时器
				if HappyCoinShopFactory:getInstance():shouldUseNewfeatures() then
					local marketPanel = createMarketPanel(3)
					if marketPanel.androidGoldPage ~= nil then
						marketPanel.androidGoldPage:closeJiFenQiang()
					end
				end

				HomeScene:sharedInstance():shutdownJiFenEntry()
				self:startPassDayCountDown()
			end
		end

		setTimeOut(_showSurePanel, 0.2)
	end
	local function onFailed(event)
		if _G.isLocalDevelopMode then printx(0, "suppersdk jifen add coin failed !") end
	end
	local http = yybAdWallHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:load(requestData)
end

function SupperAppManager:onError(errorCode, errExtra)

end

function SupperAppManager:onCancel()
	-- body
end

--sdk 是否初始化成功
function SupperAppManager:isInitSucceeded()
	return self.isInit
end

-- 跨天逻辑
function SupperAppManager:getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function SupperAppManager:startPassDayCountDown()
	if self.passDayTimeOutID ~= nil then
		cancelTimeOut(self.passDayTimeOutID)
	end

	local nowInSec = Localhost:timeInSec()
	local dayEnd = self:getDayStartTimeByTS(nowInSec + 86400)
	self.passDayTimeOutID = setTimeOut(function()
		self:onPassDay()
	end, dayEnd - nowInSec + 2)
end

function SupperAppManager:onPassDay()
	if self.passDayTimeOutID ~= nil then
		cancelTimeOut(self.passDayTimeOutID)
	end

	-- passDayLogic
	if self:checkEntry() then
		HomeScene:sharedInstance():showJiFenEntry()
	else
		-- 下个时间点再试试
		self:startPassDayCountDown()
	end
end

-- 
if PlatformConfig:isQQPlatform() == true or 
	PlatformConfig:isPlatform(PlatformNameEnum.kHE) 
then
	SupperAppManager:init()
else
	function SupperAppManager:checkEntry()
		return false
	end
end