--[[
 * StarBank
 * @date    2017-11-29 10:13:03
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require "zoo.panel.StarBank.StarBankIcon"
require "zoo.panel.StarBank.StarBankPanel"
require "zoo.panel.StarBank.StarBankCoinItem"
require "zoo.panel.StarBank.StarBankAddStarSuccessPanel"

StarBank = {}

StarBankLevel = {
	kMin = 1,
	kMax = 4,
}

StarBankState = table.const {
	kInvalid = -1,
	kEmpty = 1,  --首次出现的空的储蓄罐
	kNotEnoughBuy = 2, --收集了风车币，但是还不够能购买
	kNotFullCanBuy = 3, --可以购买了，但没有收集满
	kFullCanBuy = 4, --可购买，已收集满
	kNewBank = 5, --购买后出现新的储蓄罐
	kCool = 6, --冷却区
	kTriggleServer = 7, --向后端请求触发阶段
}

local DEBUG = _G.isLocalDevelopMode
local lvlUpBuyCount = 2 --升级的购买次数
local lvlDownCoolCount = 2 --降级的冷却次数
local isInited = false
local panel = nil

local StateName = nil
if DEBUG then
	require "zoo.panel.StarBank.StarBankUnitTest"
	StateName = {
		[StarBankState.kInvalid] = "StarBankState.kInvalid",
		[StarBankState.kEmpty] = "StarBankState.kEmpty",
		[StarBankState.kNotEnoughBuy] = "StarBankState.kNotEnoughBuy",
		[StarBankState.kNotFullCanBuy] = "StarBankState.kNotFullCanBuy",
		[StarBankState.kFullCanBuy] = "StarBankState.kFullCanBuy",
		[StarBankState.kNewBank] = "StarBankState.kNewBank",
		[StarBankState.kCool] = "StarBankState.kCool",
		[StarBankState.kTriggleServer] = "StarBankState.kTriggleServer",
	}
	StarBankUnitTest.StateName = StateName
end

local otherKey = {
	"removeItemCb",
	"schedule",
	"closeFunc",
	"hasPopout",
	"triggerFunc",
	"showAddStarSucPanelPara",
	"needPopPanel",
	"isTriggering",
	"serverShutdown",
	"buyWindMillNumber",
	"buying",
	"closeCallBack",
	'buyDelegate'
}

function StarBank:init()
	if not self:isEnabled() then
		self:print("[warnning] star bank is disabled!")
		return
	end

	if isInited then return end

	local data = {}
	self.data = data

	local otherData = {}
	self.otherData = otherData

	self.dataPath = HeResPathUtils:getUserDataPath() .. '/star_bank_'..(UserManager:getInstance().uid or '0')

	Notify:register("StarBankEventAddStar", self.addStar, self)
	Notify:register("StarBankEventCreateCoinItem", self.onCreateCoinItem, self)
	Notify:register("SceneEventEnterForeground", self.onEnterForground, self)
	Notify:register("StarBankEventShowAddStarSuccessPanel", self.onShowAddStarSuccessPanel, self)
	Notify:register("StarBankEventTryBackLevel", self.tryBackLevel, self)
	Notify:register("StarBankEventSyncData", self.syncData, self)

	local mt = {
		__index = function ( t, k )
			return data[k] or otherData[k]
		end,
		__newindex = function ( t, k, v )
			local index = table.indexOf(otherKey, k)
			if not index then
				data[k] = v
			else
				otherData[k] = v
			end
		end
	}

	setmetatable(self, mt)

	self.state = StarBankState.kInvalid
	self:sync()

	isInited = true
end

local function StringToNumTab( str )
	local t = str:split(",")
	for index,num in ipairs(t) do
		t[index] = tonumber(num)
	end
	return t
end

local function ToSecond( ms )
	return math.floor((tonumber(ms) or 0) / 1000)
end

function StarBank:parseConfig(isInit)
	local _json = require("cjson")
	local server_config = _json.decode(self.data.server_config)

	local version = HeMathUtils:md5(self.data.server_config)
	local metas = server_config.metas

	for _,meta in ipairs(metas) do
		meta.wm = StringToNumTab(meta.starRewardConfig)
		meta.starRewardConfig = nil
		meta.coolDuration = ToSecond(meta.coolDuration)
		meta.buyTimeOut = ToSecond(meta.buyTimeOut)
	end

	self.data.config = metas
end

function StarBank:getConfig()
	if self.jarId then
		local config = self.config and self.config[self.jarId]
		if config then
			local goodsId = config.goodsId
			local metaMgr = MetaManager:getInstance()
			local goodsMeta = metaMgr:getGoodMeta(goodsId)
			if not goodsMeta then
				return nil
			end
		end
		return config
	end
	return nil
end

function StarBank:scheduleUpdate()
	local function update()
		self:update()
	end

	if not self.schedule then
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
	end
end

function StarBank:unscheduleUpdate()
	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end
end

function StarBank:close()
	self:closeStarBankEntry()
	self:removePanel()
end

function StarBank:syncData( data )
	if not isInited or not self:isEnabled() or not data then
		self:close()
		return
	end

	self.serverShutdown = false

	self:readLocalData()

	local cdata = self.data
	local sdata = data

	cdata.curWm = sdata.curWm or 0
	cdata.coolStartTime = ToSecond(sdata.coolStartTime) or 0
	cdata.jarId = sdata.jarId or 0
	cdata.hadBuy = sdata.hadBuy or false
	cdata.buyDeadline = ToSecond(sdata.buyDeadline) or 0
	cdata.server_config = sdata.config
	cdata.triggerUniqueId = sdata.triggerUniqueId
	cdata.previousTriggerUniqueId = sdata.previousTriggerUniqueId

	self:parseConfig()
	self.isSynced = true
	self:checkState()

	if self.state == StarBankState.kCool then
		self:removePanel()
	end

	self:writeLocalData()
end

function StarBank:sync()
	local function syncFail(evt)
		self:print("sync fail:", evt.data)
		if evt.data == -6 then
			self:readLocalData()
			local isOffline = true
			self:checkState(isOffline)
		else
			self.serverShutdown = true
			self:close()
		end
	end

	local function syncSucess( evt )
		if evt.data and evt.data.starJarV2 then
			self:syncData(evt.data.starJarV2)
		else
			syncFail({data = -6})
		end
	end

	local http = StarJarInfoVTwo.new()
	http:addEventListener(Events.kComplete, syncSucess)
	http:addEventListener(Events.kError, syncFail)
	http:syncLoad()
end

function StarBank:isActive()
	return self:isEnabled() 
			and (not self.serverShutdown) 
			and self.isSynced 
			and not self:isCool()
			and self.state ~= StarBankState.kInvalid
			and self.state ~= StarBankState.kCool
end

function StarBank:isEnabled()
	if PlatformConfig:isPlayDemo() then return false end
	local top = UserManager.getInstance().user:getTopLevelId()
	local enabled = __WIN32 or MaintenanceManager:getInstance():isEnabled("StarJarFeature")
	self:print("Maintenance enabled:", enabled)
	return enabled and top > 20
end

function StarBank:isCool()
	return self:isInCool()
end

function StarBank:readLocalData()
	local file = io.open(self.dataPath, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            local data = table.deserialize(content) or {}
            for k,v in pairs(data) do
            	self.data[k] = v
            end
        end
    end
end

function StarBank:writeLocalData()
	local file = io.open(self.dataPath,"w")
    if file then 
        file:write(table.serialize(self.data or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(self.dataPath..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(self.data or {}))
	        file:close()
	    end
    end
end

function StarBank:getTodayStart()
	local t =	Localhost:getTodayStart()
	local utc8TimeOffset = 57600
	local dayInSec = 86400
	return (t - utc8TimeOffset) / dayInSec + 1
end

function StarBank:checkFullShowCount()
	local time = self:getTodayStart()
	if self.fullShowTime ~= time then
		self.fullShowCount = 0
	end
end

function StarBank:addFullShowCount()
	self.fullShowCount = self.fullShowCount + 1
	self.fullShowTime = self:getTodayStart()
end

function StarBank:addStar( preStarNum, starNum )
	--1.add coin
	--2.show ui
	self:print("add star:", preStarNum, starNum)
	if starNum > 4 then
		self:print("[warnning] not support this star number!")
		return
	end

	if not self:isActive() then
		self:print("[warnning] try to add star, but its not active!")
		return
	end

	if starNum <= (preStarNum or 0) then
		return
	end

	local config = self:getConfig()
	if not config then
		self:print("[error] no config for this level:", self.level)
		return
	end

	local realNum = starNum == 4 and 3 or starNum

	if not config.wm[realNum] then
		return
	end

	local gainWm = config.wm[realNum] - (config.wm[preStarNum or 0] or 0)

	self.fullShowCount = self.fullShowCount or 0

	if self.curWm >= config.max then
		self:checkFullShowCount()
		if self.fullShowCount >= 2 then return end
		ShareManager:disableShareUi()
		self.needPopPanel = true
		self.showAddStarSucPanelPara = {preStarNum,starNum,0,self.state,self.state}
		self:addFullShowCount()
		self:writeLocalData()
		return
	end

	if gainWm <= 0 then return end
	
	self.curWm = self.curWm or 0
	local totalNum = self.curWm + gainWm

	self.curWm = totalNum

	if self.curWm >= config.max then
		self.curWm = config.max
		local now = Localhost:timeInSec()
		self.buyDeadline = now + config.buyTimeOut
		self:addFullShowCount()
	end

	local pstate = self.state
	self:checkState()

	local isNewFull = pstate ~= self.state and self.state == StarBankState.kFullCanBuy

	self:print("gain star :", gainWm, "total num:", self.curWm)
	
	Notify:dispatch("StarBankUpdateStateEvent")

	local needPopout = true

	if needPopout then
		--will show(preStarNum, starNum)
		ShareManager:disableShareUi()
		self.showAddStarSucPanelPara = {preStarNum,starNum,gainWm,pstate,self.state}

		if self.curWm >= config.max and not self.hasPopout then
			self.needPopPanel = true
		else
			self.needPopPanel = false
		end
	else
		self.showAddStarSucPanelPara = nil
	end

	self:writeLocalData()
end

function StarBank:onShowAddStarSuccessPanel( closeCallBack )
	if DEBUG then
		-- Notify:dispatch("StarBankUnitTestEventInit")
	end
	self.closeCallBack = closeCallBack
	if self.showAddStarSucPanelPara then
		if self.needPopPanel then
			self.hasPopout = true
		end
		self.closeFunc = function ( ... )
			self.needPopPanel = false
			self.showAddStarSucPanelPara = nil
			self.hasPopout = false
		end
		self:passLevelShowPanel(1, closeCallBack, unpack(self.showAddStarSucPanelPara))
	else
		if closeCallBack and type(closeCallBack) == 'function' then
	    	closeCallBack()
	    end
	end

end

--冷却之后，待触发期
function StarBank:isAfterCool()
	local config = self:getConfig()
	if not config then
		return true
	end
	local now = Localhost:timeInSec()
	return self.coolStartTime ~= 0 
			and now > (self.coolStartTime + config.coolDuration)
end

function StarBank:isInCool()
	local config = self:getConfig()
	if not config then
		return true
	end
	local now = Localhost:timeInSec()
	return now > self.coolStartTime and now <= (self.coolStartTime + config.coolDuration)
end

function StarBank:onEnterForground()
	if not self:isEnabled() 
		or not isInited 
		or self.state == StarBankState.kTriggleServer
		or self.buying
	then return end
	self:sync()
	self:print("StarBank:onEnterForground()")
end

function StarBank:update()
	local config = self:getConfig()
	if not config then
		self:print("no config can used of this level:", self.level)
		self:changeToState(StarBankState.kInvalid)
		return
	end

	if self.state == StarBankState.kCool then
		if self:isAfterCool() then
			self:checkState()
		end
	elseif self.state == StarBankState.kFullCanBuy then
		self:updateLeftTime()
		Notify:dispatch("StarBankUpdateStateEvent")

		if self:isInCool() then
			self:checkState()
		end
	end
end

function StarBank:checkState(isOffline)
	local config = self:getConfig()
	if not config then 
		self:print("no config can used of this level:", self.level)
		self:changeToState(StarBankState.kInvalid)
		return
	end
	
	--check cool
	local starNum = self.curWm

	if  self:isInCool() then
		self:changeToState(StarBankState.kCool, isOffline)
	elseif self:isAfterCool() then
		self:changeToState(StarBankState.kInvalid, isOffline)
	elseif starNum >= config.max then
		self:changeToState(StarBankState.kFullCanBuy, isOffline)
	elseif starNum >= config.min then
		self:changeToState(StarBankState.kNotFullCanBuy, isOffline)
	elseif starNum > 0 then
		self:changeToState(StarBankState.kNotEnoughBuy, isOffline)
	elseif starNum == 0 and self.hadBuy then
		self:changeToState(StarBankState.kNewBank, isOffline)
	elseif starNum == 0 then
		self:changeToState(StarBankState.kEmpty, isOffline)
	end
end

function StarBank:hasGoodsId( goodsId )
	if self.config then
		for _,c in pairs(self.config) do
			if goodsId == c.goodsId then
				return true
			end
		end
	end
	return false
end

function StarBank:syncBeforeBuy(scb, fcb)
	local function syncSucess( evt )
		if evt.data and evt.data.starJarV2 then
			local data = evt.data.starJarV2
			local config = self:getConfig()
			if config and data.curWm and data.curWm < config.min then
				local function onUseLocalFunc(errCode)
					if fcb then fcb() end
				end
				local function onUseServerFunc(data)
					UserManager.getInstance():updateUserData(data)
					UserService.getInstance():updateUserData(data)
					UserService:getInstance():clearCachedHttp()

					if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
					else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

					self:removePanel(-1, 1)
					self:closeStarBankEntry()
				end
				local logic = SyncExceptionLogic:create(730211)
				logic:start(onUseLocalFunc, onUseServerFunc, nil, true)
			else
				if scb then scb() end
			end
		else
			if fcb then fcb() end
		end
	end

	local function syncFail(err)
		if fcb then fcb() end
	end
	local http = StarJarInfoVTwo.new()
	http:addEventListener(Events.kComplete, syncSucess)
	http:addEventListener(Events.kError, syncFail)
	http:syncLoad()
end

function StarBank:buy( isWindmillPanel, payType  )
	local function realbuy()
		self:__buy(isWindmillPanel, payType  )
	end

	local function onCurrentSyncError()
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
	end

	local function onCurrentSyncFinish()
		self:syncBeforeBuy(realbuy, onCurrentSyncError)
	end

	PaymentNetworkCheck.getInstance():check(function ()
		SyncManager.getInstance():sync(onCurrentSyncFinish, onCurrentSyncError)
	end, function ()
		if __IOS then
			onCurrentSyncError()
		else
			realbuy()
		end
	end)
end

function StarBank:getDcSource()
	return DcSourceType.kStarBankBuy.."_"..self.buySource
end

function StarBank:__buy(isWindmillPanel, payType )
	FrameLoader:loadArmature('skeleton/StarBank', 'StarBank', 'StarBank')

	local canBuy = self.state == StarBankState.kFullCanBuy 
				or self.state == StarBankState.kNotFullCanBuy

	local config = self:getConfig()
	if self.state == StarBankState.kCool and self.curWm >= config.max then
		canBuy = true
	end

	if not canBuy or not config then
		self:print("[warnning] can`t buy!")
		return
	end

	local goodsId = config.goodsId
	local curWm = self.curWm
	self.buyWindMillNumber = curWm
	self.buying = true

	local mp = MarketPanel:getCurrentPanel()
	if StoreManager:getInstance():isEnabled() then
		mp = StoreManager:getPanelInstance()
	end

	if isWindmillPanel then
		StarBank.buySource = 4
		if mp and mp.source == 2 then
			--click gold btn
			StarBank.buySource = 5
		elseif mp and mp.source == 3 then
			--click item btn
			StarBank.buySource = 6
		else
			--other revert
			StarBank.buySource = 7
		end
	end

	local payId = nil

	local function dc( dcType )
		if isWindmillPanel then
			local dcObj = BuyGoodsLogic:getInstance():getDcObj()
			if dcObj then
				payId = dcObj.payId
			end
		end
		self.buying = false
		local config = self:getConfig()
		DcUtil:UserTrack({
			category = "star_bank",
			sub_category = "end",
			t1 = dcType,
			t2 = goodsId,
			t3 = curWm,
			t4 = StarBank.buySource or 3,
			pay_id = payId,
			star_bank_id = self.triggerUniqueId
		})
	end

	local function success()
		if isWindmillPanel then
			CommonTip:showTip('购买成功')
		end
		self:buySuccess(goodsId, isWindmillPanel  )
		dc(0)
	end

	local function fail(errCode, errMsg, noTip)
		FrameLoader:unloadArmature( 'skeleton/StarBank', true )
		dc(1)
		if panel then
			panel:setCloseDcType(1)
			panel:updateTime()
		end
		if isWindmillPanel then
			if not noTip then
				local tipStrKey = "buy.gold.panel.err.undefined"
				if errCode and errCode == -6 then 
					--短代支付 支付前联网校验 特殊错误码提示联网
					tipStrKey = "dis.connect.warning.tips"
				end
				CommonTip:showTipWithErrCode(localize(tipStrKey), errCode, "negative", nil, 3)
			end
		end
	end

	local function cancel()
		FrameLoader:unloadArmature( 'skeleton/StarBank', true )
		dc(2)
		if panel then
			panel:setCloseDcType(2)
			panel:updateTime()
		end
		if isWindmillPanel then
			CommonTip:showTip('购买取消')
		end
	end

	if self.buyDelegate then
		self.buyDelegate(goodsId, success, fail, cancel, DcFeatureType.kStarBank, self:getDcSource())
	else
		if __IOS then
			local logic = IapBuyPropLogic:create(goodsId, DcFeatureType.kStarBank, self:getDcSource())
			if logic then
				payId = logic.dcIosInfo and logic.dcIosInfo.payId
				if isWindmillPanel and mp and logic.dcIosInfo and mp.from_level_scene then
					logic.dcIosInfo.currentStage = mp.starbank_level_id
				end
				logic:buy(success, fail)
			end
		elseif __WIN32 then
			local http = IngameHttp.new(false)
			http:ad(Events.kComplete, success)
			http:ad(Events.kError, fail)
			local tradeId = tostring(Localhost:time())
			http:load(goodsId, tradeId, "chinaMobile", 1, nil, tradeId)
		elseif __ANDROID then
			local goodsType = GoodsType.kItem --礼包
			if isWindmillPanel then
				local goodsIdInfo = GoodsIdInfoObject:create(goodsId)
		    	local dcAndroidInfo = DCAndroidRmbObject:create()
		    	dcAndroidInfo:setGoodsId(goodsIdInfo:getGoodsId())
			    dcAndroidInfo:setGoodsType(goodsIdInfo:getGoodsType())
			    dcAndroidInfo:setGoodsNum(1)
			    dcAndroidInfo:setInitialTypeList(payType, payType)
			    PaymentDCUtil.getInstance():sendAndroidRmbPayStart(dcAndroidInfo)
			    payId = dcAndroidInfo.payId
			    if isWindmillPanel and mp and mp.from_level_scene then
					dcAndroidInfo.currentStage = mp.starbank_level_id
				end
			    local logic = IngamePaymentLogic:create(goodsId, goodsType, DcFeatureType.kStarBank, self:getDcSource(), dcAndroidInfo)
				logic:salesBuy(payType, success, fail, cancel)
			else
				local logic = IngamePaymentLogic:create(goodsId, goodsType, DcFeatureType.kStarBank, self:getDcSource())
				payId = logic.dcAndroidInfo and logic.dcAndroidInfo.payId
				if isWindmillPanel and mp and mp.from_level_scene then
					dcAndroidInfo.currentStage = mp.starbank_level_id
				end
				logic:buy(success, fail, cancel)
			end
		end
	end
end

function StarBank:buySuccess(goodsId, isWindmillPanel )
	--1.back state
	--2,check up level
	--3,goto cool
	self:removePanel(0, isWindmillPanel and 2 or 1)

	local successPanel = StarBankBuySuccessPanel:create(isWindmillPanel , self.closeCallBack )
	successPanel.isWindmillPanel = isWindmillPanel
	successPanel:popout()

	local metaMgr = MetaManager:getInstance()
	local goodsMeta = metaMgr:getGoodMeta(goodsId)

	local num = self.buyWindMillNumber or 0
	UserManager:getInstance():addCash(num, true)
    UserService:getInstance():addCash(num)
    GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStarBank, ItemType.GOLD, num, self:getDcSource(), nil, nil, DcPayType.kRmb, goodsMeta.thirdRmb, goodsId)

	
	self.curWm = 0
	self.hadBuy = true
	self.coolStartTime = Localhost:timeInSec()
	self:changeToState(StarBankState.kCool, nil, true)

	BuyObserver:sharedInstance():onBuySuccess()
end

function StarBank:changeToState( state, isOffline, isBuyToCool )
	if DEBUG then
		self:print("try to change state ",StateName[self.state], ">>", StateName[state])
	end

	local pstate = self.state

	if 	(pstate == StarBankState.kInvalid or pstate == StarBankState.kCool) and
		(state ~= StarBankState.kInvalid and state ~= StarBankState.kCool)
	then
		if not isOffline then
			self:sync()
		end
		self.state = StarBankState.kTriggleServer
		self:unscheduleUpdate()
		return
	end

	if DEBUG then
		self:print("change state:from ",StateName[pstate], "to ", StateName[state])
	end

	local reason = 1
	if state == StarBankState.kCool then
		reason = 2
	end
	if isBuyToCool then reason = 3 end

	DcUtil:UserTrack({
		category = "star_bank",
		sub_category = "change_state",
		from = self.state,
		to = state,
		star_bank_id = self.triggerUniqueId,
		old_star_bank_id = self.previousTriggerUniqueId,
		reason = reason,
	})

	self.state = state

	if state == StarBankState.kInvalid then
		self:close()
		self:unscheduleUpdate()
	elseif state ~= StarBankState.kCool then
		self:scheduleUpdate()
		self:createHomeBtn()
	elseif state == StarBankState.kCool then
		self:scheduleUpdate()
		self:close()
	end

	Notify:dispatch("StarBankUpdateStateEvent", pstate, state)
	self:writeLocalData()
end

function StarBank:createHomeBtn()
	if not self:isActive() then
		self:print("[warnning] try to create star bank home btn, but its not active!")
		return
	end

	local scene = HomeScene:sharedInstance()
	if scene and not scene.starBankBtn then
		local starBankBtn = StarBankIcon:create()
		scene:addIcon(starBankBtn)
		scene.starBankBtn = starBankBtn
	end
end

function StarBank:closeStarBankEntry()
	--home btn
	local scene = HomeScene:sharedInstance()
	if scene and scene.starBankBtn then
		scene:removeIcon(scene.starBankBtn, true)
		scene.starBankBtn = nil
	end
	--windmill panel item
	if self.removeItemCb then
		self.removeItemCb()
		self.removeItemCb = nil
	end
end

local dayInSec = 86400
function StarBank:updateLeftTime()
	if self.state == StarBankState.kFullCanBuy then
		local now = Localhost:timeInSec()
		local t = StarBank.buyDeadline - now
		if t < 0 then t = 0 end
		local left = t / dayInSec
		if left > 1.0 then
			self.leftTime = math.ceil(left)
			self.leftTimeStr = string.format("还剩%d天可购买", self.leftTime)
		else
			self.leftTime = left
			local tstr = convertSecondToHHMMSSFormat(t)
			self.leftTimeStr = string.format("还剩%s可购买", tstr)
		end
		-- self.leftTimeInSec = t
	else
		self.leftTime = 0
		self.leftTimeStr = ""
		-- self.leftTimeInSec = 0
	end
end

function StarBank:getLeftTimeStrCol()
	local color = nil
	self.leftTime = self.leftTime or 0
	if self.leftTime > 1.0 then
		color = ccc3(255,255,255)
	else
		color = ccc3(255,0,0)
	end
	return self.leftTimeStr, color
end

function StarBank:showPanel(dcSource, isClick)
	if not self:isActive() or panel then return end

	self.buySource = isClick and 1 or 3

    panel = StarBankPanel:create()
	panel:popout()
	print("function StarBank:showPanel(dcSource) 111 ")

	local config = self:getConfig()

	DcUtil:UserTrack({
		category = "star_bank",
		sub_category = "start",
		t1 = dcSource,
		t2 = config and config.goodsId,
		t3 = self.curWm,
	}, true)
end

function StarBank:passLevelShowPanel(dcSource, closeCallBack, ...)
	if not self:isActive() or panel then return end
	self.buySource = 2
	self.closeCallBack = closeCallBack
    panel = StarBankPanel:create(true, closeCallBack)
	panel:playAnimation(...)

	local config = self:getConfig()
	DcUtil:UserTrack({
		category = "star_bank",
		sub_category = "start",
		t1 = dcSource,
		t2 = config and config.goodsId,
		t3 = self.curWm,
	}, true)
end

function StarBank:removePanel(dcType, panelType)
	if panel then
		if (self.state == StarBankState.kFullCanBuy or self.state == StarBankState.kNotFullCanBuy)
			and dcType == -1
		then
			local config = self:getConfig()
			DcUtil:UserTrack({
				category = "star_bank",
				sub_category = "end",
				t1 = dcType,
				t2 = config and config.goodsId,
				t3 = self.curWm,
				t4 = panelType,
				star_bank_id = self.triggerUniqueId,
			})
		end

		panel:remove()
		panel = nil
		if self.closeFunc then
			self.closeFunc()
			self.closeFunc = nil
		end
	end
end

function StarBank:canForcePop()
	if not self:isActive() or panel or self.hasPopout then
		return false 
	end

	local poptime = self.poptime
	local now = Localhost:timeInSec()

	return compareDate(os.date('*t', now), os.date('*t', poptime or 0)) ~= 0 
		and self.state == StarBankState.kFullCanBuy
end

function StarBank:tryPopoutStarBankPanel( isClick, closeFunc )
	if self:canForcePop() then
		self:showPanel(1, true)
		if panel then
			self.closeFunc = closeFunc
			self.poptime = Localhost:timeInSec()
			self:writeLocalData()
		end
		return panel ~= nil
	end
	return false
end

function StarBank:isShowCoinItem()
	return self:isActive() and self.state == StarBankState.kFullCanBuy
end

function StarBank:onCreateCoinItem( successCb, payType)
	if not self:isActive() or self.state ~= StarBankState.kFullCanBuy then
		return
	end

	local payment = PaymentBase:getPayment(payType)
	local config = self:getConfig()
	if config and (config.goodsId == 485 or config.goodsId == 510 or config.goodsId == 614 or config.goodsId == 615) and payment.mode == PaymentMode.kSms then
		return
	end

	local classObj = StarBankCoinItem
	if self.coinItemClass then
		classObj = self.coinItemClass
	end

	local itemUi = classObj:create(payType)
	if itemUi then
		self.removeItemCb = successCb(itemUi)
	else
		self.removeItemCb = nil
	end
end



function StarBank:print( ... )
	if DEBUG then
		printx(10, "[StarBank]", ...)
		-- require "hecore.debug.remote"
		-- RemoteDebug:uploadLog(...)
	end
end

function StarBank:setCoinItemClass( coinItemClass )
	self.coinItemClass = coinItemClass
end

function StarBank:setBuyDelegate( buyDelegate )
	self.buyDelegate = buyDelegate
end

Notify:register( "StarBankEventInit", StarBank.init, StarBank )