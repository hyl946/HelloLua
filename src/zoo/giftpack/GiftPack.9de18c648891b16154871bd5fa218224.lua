--[[
 * GiftPack
 * @date    2018-12-28 10:13:21
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local OLD_PACK = GiftPack

GiftPack = {}

GiftPackType = {
	kNewer1 = 1, --新手包1
	kGuide = 2, --引导包
	kNewer2 = 3, --新手包2，限时包
	kNewerUpper = 4, --新手包1升级包(礼包1，礼包2)
	kPersonalise = 5, --个性化礼包
}

local RecommendType = {
	kLoop = 1, --循环推荐
	kAlways = 2, --在有效期内，一直推荐
}

local GPTestGroupType = {
	
}

local PackTypeConfigs = {
	[GiftPackType.kNewer1] = {
		recommendType = RecommendType.kLoop,
		goodsIds = {559, 560, 561, 562},
		rewardGoodsIds = {567, 568},
	},
	[GiftPackType.kGuide] = {
		recommendType = RecommendType.kLoop,
		goodsIds = {566},
	},
	[GiftPackType.kNewer2] = {
		recommendType = RecommendType.kAlways,
		goodsIds = {563},
	},
	[GiftPackType.kNewerUpper] = {
		recommendType = RecommendType.kAlways,
		goodsIds = {564, 565},
	},
	[GiftPackType.kPersonalise] = {
		recommendType = RecommendType.kAlways,
		goodsIds = {},
	}
}

local hours72 = 72*3600*1000
local day7 = 7*3600*24*1000
local hours24 = 24*3600*1000

local PackConfigs = {
	[559] = {
		cooltime = day7,
		duration = hours72,
		reward = 567,
		upper_cooltime = day7,
	},
	[560] = {
		cooltime = day7,
		duration = hours72,
		reward = 568,
		upper_cooltime = hours24 * 20,
	},
	[561] = {
		cooltime = day7,
		duration = hours72,
		upper_cooltime = day7,
	},
	[562] = {
		cooltime = day7,
		duration = hours72,
		upper_cooltime = hours24 * 20,
	},
	[563] = {
		cooltime = 1000,
		duration = hours24,
		cooltimes = {7,10,12,15},
		nextLoopCon = {107, 167, 209, 258, 303},
		upper_cooltime = day7,
	},
	[564] = {
		cooltime = 7*3600*24,
		duration = hours24,
	},
	[565] = {
		cooltime = 7*3600*24,
		duration = hours24,
	},
	[566] = {
		cooltime = 7*3600*24,
		duration = hours24,
	},
	[567] = {
		cooltime = 7*3600*24,
		duration = hours24 * 7,
		isReward = true,
	},
	[568] = {
		cooltime = 7*3600*24,
		duration = hours24 * 15,
		isReward = true,
	},
}

function GiftPack:init()
	if self.isInited then return end
	self.isInited = true
	self:syncInfo()
	self:checkGroupConfig()
	self:tryCreateBuildHomeIcons()
	self:createSchedule()

	self:createNoti()

	self:tryResumeRewardGift()

	Notify:register('AchiEventUserDataUpdate', self.postLogin, self)
end

function GiftPack:tryResumeRewardGift()
	if not _G.kUserLogin and self:isEnabled() then
		if self:hasAnyRewardNotExp() then
			local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
			for _,goodsId in ipairs(goodsIds) do
				local info = self.info[goodsId]
				local rd = self:getRewardDay(goodsId)
				if info.rewardDay and info.seeCount == -1 and rd > info.rewardDay then
					info.seeCount = 0
				end
			end
		end
	end
end

function GiftPack:postLogin()
	self:syncInfo()
	self:tryCreateBuildHomeIcons()
end

function GiftPack:testTime()
	local utc8TimeOffset = 57600 * 1000
	local dayInSec = 86400*1000
	local time = 1547654400000
	local now = Localhost:time() + dayInSec
	local start = Localhost:getDayStartTimeByTS(now/1000)
	local t = time - start*1000
	self:print(start, t / dayInSec)
end

function GiftPack:createSchedule()
	if self.cdId then return end

	local function update()
        self:updateOneSecond()
    end

    update()

    self.cdId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
end

function GiftPack:getLeftDay( goodsId, isReal )
	local deadline = GiftPack:getPackDeadline(goodsId)
	local dayt = 86400*1000
	local now = Localhost:time()
	local start = Localhost:getDayStartTimeByTS(now/1000)

	local isPassDay = (Localhost:timeInSec()-57600) % 86400 == 0

	local info = self.info[goodsId]
	local offset = 0
	if info.seeCount == -1 and not isPassDay and not isReal then
		offset = 1
	end
	return math.floor((deadline - start*1000)/dayt) - offset
end

function GiftPack:getRewardDay( goodsId )
	local deadline = self:getPackDeadline(goodsId) or 0
	local leftday = self:getLeftDay(goodsId, true)
	local total = PackConfigs[goodsId].duration/3600/24/1000
	local day = total - leftday + 1
	return day <= 0 and 1 or day
end

function GiftPack:updateOneSecond()
	local scene = HomeScene:sharedInstance()
	if scene then
		if scene.gpdiscountBtn and not scene.gpdiscountBtn.isDisposed then
			scene.gpdiscountBtn:update()
		end
		if scene.gpyouhuiBtn and not scene.gpyouhuiBtn.isDisposed then
			scene.gpyouhuiBtn:update()
		end
	end

	self:updateRewardState()
end

function GiftPack:updateRewardState()
	local utc8TimeOffset = 57600
	local now = Localhost:timeInSec() - utc8TimeOffset
	if now % 86400 == 0 then
		local goods = self:getRewardGoods()
		for _,infos in ipairs(goods) do
			if self:checkPack(infos.goodsId) then
				infos.info.seeCount = 0
			end
		end
	end
end

function GiftPack:closeSchedule()
	if self.cdId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cdId)
        self.cdId = nil
    end
end

function GiftPack:checkGroupConfig(isRefresh)
	if not self:isEnabled() then return end

	local key = 'GiftPackTestGroup'

	local groupInfo = UserManager:getInstance().groupInfo
	local group = table.find(groupInfo, function ( g )
		return g.key == key
	end)

	local tgroup = {}

	for _,name in ipairs({'A1', 'A2', 'A3', 'A4', 'B1', 'C1', 'D1'}) do
		local isEnabled = self:isEnabledInGroupM(name)
		if isEnabled then
			table.insert(tgroup, name)
		end
	end

	if not group or isRefresh then
		HttpBase:syncPost('syncGroupInfo', {key = key, tags = tgroup, refresh = isRefresh})
		if isRefresh then
			for _,g in ipairs(groupInfo) do
				if g.key == key then
					g.tags = tgroup
				end
			end
		else
			table.insert(groupInfo, {key = key, tags = tgroup})
		end
	end

	self:print('groupInfo : ',table.tostring(groupInfo))

	if group and self:isDebug() then
		group.tags = self:getDebugGroup()
	end
end

function GiftPack:getDebugGroup()
	if self:isDebug() then
		return {'A1', 'A2', 'A3', 'A4', 'B1', 'C1', 'D1'}
	end
end

function GiftPack:isEnabledInGroup( name )
	if not self:isEnabled() then return false end

	local groupInfo = UserManager:getInstance().groupInfo
	local group = table.find(groupInfo, function ( g )
		return g.key == 'GiftPackTestGroup'
	end)

	if group then
		return table.indexOf(group.tags, name) ~= nil
	end

	return self:isEnabledInGroupM(name)
end

function GiftPack:isEnabledInGroupMustNewer( name )
	return UserManager:getInstance().giftPackNewUser and self:isEnabledInGroupM(name)
end

function GiftPack:isEnabledInGroupM( name )
	local uid = UserManager:getInstance():getUID() or "12345"
	return MaintenanceManager:getInstance():isEnabledInGroup("GiftPackTestGroup" , name, uid)
end

function GiftPack:isDebug()
	return false
end

function GiftPack:getDebugInfo()
	if not self:isDebug() then
		return
	end

	local now = Localhost:time() + 7*3600*24*1000
	local pre = Localhost:time() + 3600*24*1000

	local info = {
		{goodsId = 559, seeCount = 0, activateCount = 1, buyCount = 0, expTime = now},
		{goodsId = 560, seeCount = 0, activateCount = 1, buyCount = 0, expTime = now},
		{goodsId = 561, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 562, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 563, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 564, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 565, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 566, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 567, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
		{goodsId = 568, seeCount = 0, activateCount = 0, buyCount = 0, expTime = 0},
	}

	UserManager:getInstance().giftPackInfo = info

	return info
end

function GiftPack:syncInfo(info)
	local giftPackInfos = info or UserManager:getInstance().giftPackInfos

	self.info = self.info or {}
	giftPackInfos = giftPackInfos or {}

	-- self:print(table.tostring(giftPackInfos))

	for _,t in ipairs(giftPackInfos) do
		self.info[t.goodsId] = t
		t.expTime = tonumber(t.expTime)
		if info then
			for _,tt in ipairs(UserManager:getInstance().giftPackInfos) do
				if tt.goodsId == t.goodsId then
					for k,v in pairs(tt) do
						tt[k] = v
					end
				end
				tt.expTime = tonumber(tt.expTime)
			end
		end
	end
end

function GiftPack:isEnabled()
	local gpinfos = UserManager:getInstance().giftPackInfos
	if not gpinfos or #gpinfos <= 0 then return false end

	if __WIN32 or self:isDebug() then return true end

	if __ANDROID then
		if PlatformConfig:isPlatform(PlatformNameEnum.kCUCCWO) or 
			PlatformConfig:isPlatform(PlatformNameEnum.k189Store)
		then
			return false
		end
		return PaymentManager.getInstance():checkThirdPartPaymentEabled(true)
	end

	return true
end

function GiftPack:isEnabledNewerPackOne()
	if not self:isEnabled() then return false end
	if not self.isInited then return false end
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local rewardGoodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
	for _,goodsId in ipairs(table.union(goodsIds, rewardGoodsIds)) do
		if self:checkPack(goodsId) then
			return true
		end
	end
	return false
end

function GiftPack:createIcon( itemInfo )
	local icon
	if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		icon = ResourceManager:sharedInstance():buildItemSprite(ItemType.INFINITE_ENERGY_BOTTLE)
	else
		icon = ResourceManager:sharedInstance():buildItemSprite(itemInfo.itemId)
	end
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon.itemInfo = itemInfo

    local size = icon:getContentSize()

    local num_str = 'x'..itemInfo.num
    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
    	num_str = itemInfo.num / 60
    	if num_str < 1 then
    		num_str = itemInfo.num
    	end
    end

    local offset = 0
    if itemInfo.itemId == 10087 or itemInfo.itemId == 10088 then
    	offset = 10
    end

    local num = BitmapText:create(num_str, 'fnt/autumn2017.fnt')
    num:setAnchorPoint(ccp(0, 0.5))
    num:setScale(1.3)
    local tx = 80 + offset
    num:setPosition(ccp(tx, size.height/2 - 10))
    icon:addChild(num)

    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
    	local u = '小时'
    	if itemInfo.num / 60 < 1 then
    		u = '分钟'
    	end
    	local unit = BitmapText:create(u, 'fnt/autumn2017.fnt')
        unit:setAnchorPoint(ccp(0, 0.5))
        unit:setScale(0.7)
        icon.unit = unit
        local nsize = num:getContentSize()
        unit:setPosition(ccp(tx + nsize.width +10, size.height/2 - 10))
        icon:addChild(unit)
    end

    if ItemType:isTimeProp(itemInfo.itemId )  then
        local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemInfo.itemId, true)
        icon:addChild(time_prop_flag)
        time_prop_flag:setAnchorPoint(ccp(0.5,0.5))
        local size = icon:getContentSize()
        time_prop_flag:setPosition( ccp( size.width/2, 20 ) )
    end

    icon:setScale(0.5)

    return icon
end

function GiftPack:getPackType( goodsId )
	for t,config in pairs(PackTypeConfigs) do
		if table.indexOf(config.goodsIds, goodsId) then
			return t
		end

		if config.rewardGoodsIds then
			if table.indexOf(config.rewardGoodsIds, goodsId) then
				return t
			end
		end
	end
	return GiftPackType.kNewer1
end

function GiftPack:getRewardGoodsId( goodsId )
	return (PackConfigs[goodsId] or {}).reward
end

function GiftPack:createNoti()
	self:cancelNoti()

	if not self:isEnabled() then return false end

	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
	local goodsId = nil
	local deadline = 0

	for _,gd in ipairs(goodsIds) do
		if self:checkPack(gd) then
			local time = self:getPackDeadline(gd)
			if time > deadline then
				goodsId = gd
				deadline = time
			end
		end
	end

	if not goodsId then return end

	local leftday = self:getLeftDay(goodsId)
	local info = self.info[goodsId]
	local isTodayReward = info.seeCount == -1

	--12:00
	local now = Localhost:timeInSec()
	local todayTime = Localhost:getDayStartTimeByTS(now)

	local leftday_notoday = isTodayReward and leftday or (leftday - 1)
	for day = 1,leftday_notoday do
		local notiTime = todayTime + 3600*24*day + 3600*12
		LocalNotificationManager:getInstance():setGiftPackNoti(notiTime, LocalNotificationType.kGiftPack1,'今日礼包奖励已送达，点击领取>>')
	
		notiTime = todayTime + 3600*24*day + 3600*20
		LocalNotificationManager:getInstance():setGiftPackNoti(notiTime, LocalNotificationType.kGiftPack2, '今日礼包奖励即将过期，快来领取吧>>')
	end
	
	--today 20:00
	local notiTime = todayTime + 3600*20
	if now < notiTime then
		LocalNotificationManager:getInstance():setGiftPackNoti(notiTime, LocalNotificationType.kGiftPack2, '今日礼包奖励即将过期，快来领取吧>>')
	end
end

function GiftPack:cancelNoti()
	LocalNotificationManager:getInstance():cancelGiftPackNoti(LocalNotificationType.kGiftPack1)
	LocalNotificationManager:getInstance():cancelGiftPackNoti(LocalNotificationType.kGiftPack2)
end

function GiftPack:onBuySuccess( goodsId )
	local infos = self:getGoodsInfo(goodsId)
	local info = infos.info

	if not info then return end

	local now = Localhost:time()
	local rewardGoodsId = self:getRewardGoodsId(goodsId)
	if rewardGoodsId then
		local rinfos = self:getGoodsInfo(rewardGoodsId)
		local rinfo = rinfos.info
		local rconfig = rinfos.config
		rinfo.activateCount = 1
		rinfo.expTime = now + rconfig.duration

		self:createNoti()
	end

	info.buyCount = info.buyCount + 1
	info.boughtTime = Localhost:time()

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local bottle = table.find(meta.items, function (item)
		return item.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	end)

	if bottle then
		local logic = UseEnergyBottleLogic:create(bottle.itemId, DcFeatureType.kActivityInner, DcSourceType.kActPre.."2018_double11")
		logic:setUsedNum(bottle.num)
		logic:setSuccessCallback(function ( ... )
			HomeScene:sharedInstance():checkDataChange()
			HomeScene:sharedInstance().energyButton:updateView()
		end)
		logic:setFailCallback(function ( evt )
		end)
		logic:start(true)
	end

	HomeScene:sharedInstance():checkDataChange()
    HomeScene:sharedInstance().goldButton:updateView()
    BuyObserver:sharedInstance():onBuySuccess()

    local scene = HomeScene:sharedInstance()
    if scene.gpdiscountBtn and not scene.gpdiscountBtn.isDisposed then
		scene.gpdiscountBtn:update()
	end

	local pt = self:getPackType(goodsId)
	if pt ~= GiftPackType.kNewer1 then
		self:removeHomeIcon(goodsId)
	else
		self:tryCreateBuildHomeIcons()
	end
end

function GiftPack:buy( goodsId, scb, fcb, ccb )
	local function dcInfo()
		local info = {}
		if __IOS then
			info.pay_type = Payments.IOS_RMB
			if self.buylogic then
				info.result = self.buylogic.dcIosInfo:getResult()
			end
		elseif __ANDROID and self.buylogic then
			info.pay_type = self.buylogic.paymentType
			info.result = self.buylogic.dcAndroidInfo:getResult()
		end

		info.toplevel = UserManager:getInstance().user:getTopLevelId()
		info.currentlevel = self.currentlevel
		info.goods_id = goodsId

		self.buylogic = nil
		return info
	end

	local function onSuccess()
		self:onBuySuccess(goodsId)
		CommonTip:showTip('购买成功！', 'positive')
        if scb then scb(dcInfo()) end
    end

    local function onFail(errCode, errMsg, noTip)
        if fcb then fcb(dcInfo()) end
        if not noTip then 
        	CommonTip:showTip('购买失败！')
        end
    end

    local function onCancel()
        if ccb then ccb(dcInfo()) end
        CommonTip:showTip('购买取消！')
    end

    if __IOS then
        self.buylogic = IapBuyPropLogic:create(goodsId, 'payment_Pack', 'payment_Pack_'..goodsId)
        if self.buylogic then 
            self.buylogic:buy(onSuccess, onFail)
        end
    elseif __WIN32 then
    	local logic = IngamePaymentLogic:create(goodsId)
        logic:deliverItems(goodsId, 1)
        onSuccess()
    elseif __ANDROID then
        self:androidBuy(goodsId, onSuccess, onFail, onCancel)
    end
end

function GiftPack:androidBuy( goodsId, onSuccess, onFail, onCancel )
    local M = PaymentManager.getInstance()
    local ThirdPayWithoutNetCheck = {
		Payments.WO3PAY,
		Payments.TELECOM3PAY,
	}

    local repayChooseTable

    local function handlePayment( decision, payType )
        self.buylogic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, 'payment_Pack', 'payment_Pack_'..goodsId)
        self.buylogic:specialBuy(decision, payType, onSuccess, onFail, onCancel, repayChooseTable, nil, true)
    end

    if PrepackageUtil:isPreNoNetWork() then
        PrepackageUtil:showInGameDialog(onCancel)
        return 
    end

    local defaultThirdPartyPayment = M:getDefaultThirdPartPayment()
    local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment

    if table.includes(ThirdPayWithoutNetCheck, defaultThirdPartyPayment) then 
		repayChooseTable = M:filterRepayPayment(thirdPartPaymentTable)
		handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment) 
	else
	    PaymentNetworkCheck.getInstance():check(function ()  
	        repayChooseTable = M:filterRepayPayment(thirdPartPaymentTable)
	        handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment) 
	    end, function ()
	        CommonTip:showTip(Localization:getInstance():getText("payment_repay_txt4"), "negative")
	    end)
	end
end

function GiftPack:getActNewerPackOne()
	if not self:isEnabled() then return {} end

	local goodsIds = self:getNewerPackOneGoodsIds()

	local ret = {}
	for _,goodsId in ipairs(goodsIds) do
		table.insert(ret, self:getGoodsInfo(goodsId))
	end
	return ret
end

function GiftPack:hasActNewerPackOne()
	if not self:isEnabled() then return false end

	local goodsIds = self:getNewerPackOneGoodsIds()
	for _,goodsId in ipairs(goodsIds) do
		if self:checkPack(goodsId) then
			return true
		end
	end
	return false
end

function GiftPack:getDiscountNum( goodsId )
	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100

	local discountNum = price * 10 / ori_price
	local num = math.ceil(discountNum)
	local distance = num - discountNum
	return distance > 0.5 and math.floor(discountNum) or num
end

function GiftPack:getMinDiscountPackOne()
	local goodsIds = self:getNewerPackOneGoodsIds()
	local dis = 11
	for _,goodsId in ipairs(goodsIds) do
		if self:checkPack(goodsId) then
			local dist = self:getDiscountNum(goodsId)
			if dist < dis then
				dis = dist
			end
		end
	end
	return dis
end

function GiftPack:getRewardGoods()
	local A3 = self:isEnabledInGroup('A3')
	if not self:isEnabled() or A3 then return {} end

	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds

	local ret = {}
	for _,goodsId in ipairs(goodsIds) do
		table.insert(ret, self:getGoodsInfo(goodsId))
	end
	return ret
end

function GiftPack:showErrorTip(evt)
	local errcode = evt and evt.data or nil
	if errcode then
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
	end
end

function GiftPack:showEnergyAlert( num, finish )
	local EnergyAlertPanel = require 'zoo.giftpack.EnergyAlertPanel'
	local panel = EnergyAlertPanel:create(num, finish)
	panel:popout()
end

function GiftPack:reciveReward( goodsId, scb, fcb, ccb )
	local function onSuccess(evt)
		local rinfos = self:getGoodsInfo(goodsId)
		
		local rinfo = rinfos.info
		rinfo.seeCount = -1
		rinfo.rewardDay = self:getRewardDay(goodsId)

		local data = evt.data
		local rewards = data.rewardItems
		for _,reward in ipairs(rewards) do
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, reward.itemId, reward.num, 'rewardPack'..goodsId)
			UserManager:getInstance():addReward(reward, true)
		end
		
		UserService:getInstance():addRewards(rewards)
		Localhost:getInstance():flushCurrentUserData()
		self:onBuySuccess(goodsId)

		self:dc('reward', 'reward_collect', {list_id = goodsId, collect_num = rinfo.buyCount})

		self:createNoti()

		if scb then scb(rewards) end
	end

	local function onFail(evt)
		self:showErrorTip(evt)
		if fcb then fcb(evt and evt.data) end
	end

	local function onCancel()
		if ccb then return ccb() end
	end

	local function noNetwork()
		if fcb then fcb() end
		CommonTip:showTip(localize('dis.connect.warning.tips'))
	end

	local function hasNetwork()
		-- local meta = MetaManager.getInstance():getGoodMeta(goodsId)
		-- onSuccess({data = {rewardItems = meta.items}})
		HttpBase:syncPost('getFreeGiftPack', {packId = goodsId}, onSuccess, onFail, onCancel)
	end

	RequireNetworkAlert:callFuncWithLogged(hasNetwork, noNetwork, nil, kRequireNetworkAlertTipType.kNoTip)
end

function GiftPack:getGoodsInfo( goodsId )
	return {goodsId = goodsId, config = PackConfigs[goodsId], info = self.info[goodsId]}
end

function GiftPack:hasAnyReward()
	local rewardGoodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
	if #rewardGoodsIds > 0 then
		for _,goodsId in ipairs(rewardGoodsIds) do
			if self:checkPack(goodsId) then
				local info = self.info[goodsId]
				if info.seeCount ~= -1 then
					return true
				end
			end
		end
	end
	return false
end

function GiftPack:hasAnyRewardNotExp()
	local rewardGoodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
	if #rewardGoodsIds > 0 then
		for _,goodsId in ipairs(rewardGoodsIds) do
			if not self:hasExp(goodsId) then
				return true
			end
		end
	end
	return false
end

function GiftPack:isPackOneAllReward()
	local goodsIds = self:getNewerPackOneGoodsIds()
	local all_b = true
	for _,goodsId in ipairs(goodsIds) do
		if not self:hasBought(goodsId) and self:checkPack(goodsId) then
			all_b = false
		end
	end

	if not all_b then
		return false
	end

	return self:hasAnyReward()
end

function GiftPack:canReward( goodsId )
	return self:checkPack(goodsId)
end

function GiftPack:hasBought( goodsId )
	local info = self.info[goodsId]
	return info and info.buyCount and info.buyCount > 0
end

function GiftPack:hasAllBought( goodsIds )
	for _,goodsId in ipairs(goodsIds) do
		if not self:hasBought(goodsId) then
			return false
		end
	end
	return true
end

function GiftPack:hasExp(goodsId)
	if not self.isInited or not self:isEnabled() then return true end
	local info = self.info[goodsId]
	if not info then return true end

	local deadline = info.expTime
	local now = Localhost:time()

	return now > deadline
end

function GiftPack:hasExpPack( goodsIds )
	for _,goodsId in ipairs(goodsIds) do
		if self:hasExp(goodsId) then
			return true
		end
	end
	return false
end

function GiftPack:getPackDeadline( goodsId )
	local info = self.info[goodsId]
	if info then
		return info.expTime or 0
	end
	return 0
end

function GiftPack:getPackBoughtTime( goodsId )
	local info = self.info[goodsId]
	return info.boughtTime or 0
end

function GiftPack:getNewerPackCycle()
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local cycle = 0
	for _,goodsId in ipairs(goodsIds) do
		local info = self.info[goodsId]
		if info and info.activateCount > cycle then
			cycle = info.activateCount
		end
	end

	return cycle
end

function GiftPack:getPackInfo( goodsId )
	return PackConfigs[goodsId]
end

function GiftPack:getNewerPackUpper(gptype, index)
	if gptype ~= GiftPackType.kNewer1 and gptype ~= GiftPackType.kNewer2 then return end

	if gptype == GiftPackType.kNewer2 then
		index = 1
	end

	if index > 2 then
		index = index - 2
	end

	local upper_goodsId = PackTypeConfigs[GiftPackType.kNewerUpper].goodsIds[index]
	local c = PackConfigs[upper_goodsId]
	c.goodsId = upper_goodsId
	return c
end

function GiftPack:getBoughtPack( gptype )
	local config = PackTypeConfigs[gptype]
	for index,goodsId in ipairs(config.goodsIds) do
		if self:hasBought(goodsId) then
			local info = self:getPackInfo(goodsId)
			info.goodsId = goodsId
			info.upper = self:getNewerPackUpper(gptype, index)
			return info
		end
	end
	return nil
end

function GiftPack:getBoughtNewerOne()
	local goodsIds = self:getNewerPackOneGoodsIds()
	local hasAllBought = self:hasAllBought(goodsIds)
	if hasAllBought then
		local goodsId = goodsIds[2]
		local info = self:getPackInfo(goodsId)
		info.goodsId = goodsId
		info.upper = self:getNewerPackUpper(GiftPackType.kNewer1, 2)
		return info
	end

	return self:getBoughtPack(GiftPackType.kNewer1)
end

function GiftPack:getBoughtNewerPack()
	return self:getBoughtNewerOne()
		or self:getBoughtPack(GiftPackType.kNewer2)
end

function GiftPack:hasBoughtGuidePack()
	return self:getBoughtPack(GiftPackType.kGuide)
end

function GiftPack:hasBoughtNewerUpper()
	return self:getBoughtPack(GiftPackType.kNewerUpper)
end

function GiftPack:checkGuideGift()
	local goodsId = PackTypeConfigs[GiftPackType.kGuide].goodsIds[1]
	return self:checkPack(goodsId)
end

function GiftPack:getDay( time )
	-- body
end

function GiftPack:checkPack( goodsId )
	if not self.isInited or not self:isEnabled() then return nil end
	local info = self.info[goodsId]
	if not info then return nil end

	local deadline = info.expTime
	local now = Localhost:time()

	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].rewardGoodsIds
	if not table.indexOf(goodsIds, goodsId) then
		if info.buyCount > 0 then return nil end
	end

	if deadline > 0 and now < deadline and info.activateCount > 0 then
		if info.seeCount == -1 then
			local leftday = self:getLeftDay(goodsId)
			if leftday < 1 then
				return nil
			end
		end
		return goodsId
	end

	return nil
end

function GiftPack:checkNewerGiftTwo()
	local goodsId = PackTypeConfigs[GiftPackType.kNewer2].goodsIds[1]
	return self:checkPack(goodsId)
end

function GiftPack:checkGiftLoop()
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local targets = {}

	local guideId = self:checkGuideGift()
	local count = 0
	if guideId then
		local info = self.info[guideId]
		count = (info.seeCount or 0) + 4
		table.insert(targets, {guideId, count})
	end

	local newer_packs = {}
	for _,goodsId in ipairs(goodsIds) do
		if self:checkPack(goodsId) then
			local info = self.info[goodsId]
			if count and count ~= info.seeCount then
				count = false
			end
			local meta = MetaManager.getInstance():getGoodMeta(goodsId)
			table.insert(newer_packs, {goodsId, info.seeCount, meta.thirdRmb})
		end
	end

	table.sort(newer_packs, function ( a, b )
		return a[3] > b[3]
	end)

	for _,i in ipairs(newer_packs) do
		table.insert(targets, i)
	end

	self:print('loop:', table.tostring(targets))

	--try trigger guide pack
	if not guideId then
		local sc
		for _,gs in ipairs(targets) do
			local seeCount = gs[2]
			if not sc then sc = seeCount end
			if sc ~= seeCount then
				sc = false
				break
			end
		end
		if sc and sc > 0 and sc % 4 == 0 then
			if self:tryTriggerGuidePack() then
				return PackTypeConfigs[GiftPackType.kGuide].goodsIds[1], true
			end
		end
	end

	if #targets > 0 then
		if not count then
			table.sort( targets, function ( a, b )
				return a[2] < b[2]
			end )
		end

		self:print('sort loop:', table.tostring(targets))

		for _,gs in ipairs(targets) do
			if gs[2] % 2 == 1 then
				return gs[1]
			end
		end

		local t1,t2 = targets[1],targets[2]
		if t1 and t2 and t1[3] and t2[3] and t1[3] < t2[3]
			and t1[2] == t2[2]
		then
			return targets[2][1]
		end

		return targets[1][1]
	end
end

function GiftPack:isTriggered()
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local count = 0
	for _,goodsId in ipairs(goodsIds) do
		local info = self.info[goodsId]
		if info and info.activateCount > count then
			count = info.activateCount
		end
	end
	return count > 0
end

function GiftPack:onCloseEndgamePanel()
	if self.endgamePanel then
		if not self.endgamePanel.isDisposed then
			-- self.endgamePanel:remove()
			self.endgamePanel:setVisible(false)
			self.endgamePanel:removeFromParentAndCleanup(true)
		end
		self.endgamePanel = nil
	end
end

function GiftPack:showPack( goodsId )
	local function done( evt )
		local info = self.info[goodsId]
		if info then
			info.seeCount = (info.seeCount or 0) + 1
		end
	end
	if self:isDebug() then
		done()
	else
		if PackConfigs[goodsId] then
			HttpBase:offlinePost('giftPackSync', {showIds = {goodsId}}, done, done, done)
		end
	end

	if not self.addFivePanel or self.addFivePanel.isDisposed then return end
	local EndgamePanel = require 'zoo.giftpack.GiftPackEndgamePanel'
	self.endgamePanel = EndgamePanel:create(goodsId, self.onclose)
	-- self.endgamePanel.addFivePanel = self.addFivePanel
	-- self.endgamePanel:popout()

	self.addFivePanel:addBottomAD(self.endgamePanel)

	GiftPack:dc('canyu', '5steps_push', {list_id = goodsId})
end

function GiftPack:triggerSuccess( goodsIds )
	for _,goodsId in ipairs(goodsIds) do
		local info = self.info[goodsId]
		info.activateCount = (info.activateCount or 0) + 1
		info.seeCount = 0
		info.expTime = Localhost:time() + PackConfigs[goodsId].duration
	end

	self:tryCreateBuildHomeIcons()
end

function GiftPack:hasAnyActPack()
	if not self:isEnabled() then return false end

	for pt,config in pairs(PackTypeConfigs) do
		for _,goodsId in ipairs(config.goodsIds) do
			if self:checkPack(goodsId) then
				return true
			end		
		end
		if config.rewardGoodsIds then
			for _,goodsId in ipairs(config.rewardGoodsIds) do
				if self:checkPack(goodsId) then
					return true
				end		
			end
		end
	end
	return false
end

function GiftPack:tryCreateBuildHomeIcons()
	if not self:isEnabled() then return end
	for pt,config in pairs(PackTypeConfigs) do
		for _,goodsId in ipairs(config.goodsIds) do
			if self:checkPack(goodsId) then
				self:createHomeIcon(pt == GiftPackType.kNewer1, goodsId)
				break
			end
		end

		if pt == GiftPackType.kNewer1 then
			for _,goodsId in ipairs(config.rewardGoodsIds) do
				if self:checkPack(goodsId) then
					self:createHomeIcon(true, goodsId)
					break
				end
			end
		end
	end
end

function GiftPack:createHomeIcon( isNewer1, goodsId )
	require 'zoo.scenes.component.HomeScene.iconButtons.GiftPackButton'
	local scene = HomeScene:sharedInstance()

	if scene then
		if isNewer1 and scene.gpdiscountBtn then return end
		if not isNewer1 and scene.gpyouhuiBtn then return end

		local btn
		if isNewer1 then
			btn = GiftPackDiscountButton:create(goodsId)
			scene.gpdiscountBtn = btn
		else
			btn = GiftPackYouhuiButton:create(goodsId)
			scene.gpyouhuiBtn = btn
		end
		scene:addIcon(btn)

		local function onBtnTapped()
			self:onTapIcon(goodsId)
		end
		btn.wrapper:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
	end
end

function GiftPack:removeHomeIcon( goodsId )
	local pt = self:getPackType(goodsId)
	local scene = HomeScene:sharedInstance()

	if pt == GiftPackType.kNewer1 then
		if scene.gpdiscountBtn and not scene.gpdiscountBtn.isDisposed then
			scene:removeIcon(scene.gpdiscountBtn)
			scene.gpdiscountBtn = nil
		end
	else
		if scene.gpyouhuiBtn and not scene.gpyouhuiBtn.isDisposed then
			scene:removeIcon(scene.gpyouhuiBtn)
			scene.gpyouhuiBtn = nil
		end
	end
end

local SYNC_OK = 1
local SYNC_FAIL = 2
local SYNC_NO_PERMISSION = 3
local SYNC_REPEAT = 4
local SYNC_CANT_ACTIVATE = 5
local SYNC_UNKNOWERROR = 99

function GiftPack:triggerPack( goodsIds )
	local function onSuccess( evt )
		local data = evt.data
		if data then
			self:print('triggerPack:', unpack(goodsIds))

			local activateResult = data.activateResult or {}
			local info = data.info
			local ret = activateResult[tostring(goodsIds[1])]

			if ret == SYNC_OK or ret == SYNC_REPEAT then
				self:triggerSuccess(goodsIds)
			end

			if ret ~= SYNC_OK and ret ~= SYNC_CANT_ACTIVATE then
				self:syncInfo(info)
			end

			if ret == SYNC_OK or ret == SYNC_REPEAT then
				self:onShowGiftPack()
			end
		end
	end
	local function onFail( evt )
		-- body
	end
	
	local function onCancel( evt )
		-- body
	end

	local toplevelId = UserManager.getInstance().user:getTopLevelId()
	if toplevelId < 36 then
		self:onShowGiftPack()
		return
	end

	if self:isDebug() then
		local data = {activateResult = {}}
		for _, goodsId in ipairs(goodsIds) do
			data.activateResult[goodsId] = SYNC_OK
		end
		onSuccess({data = data})
	else
		HttpBase:syncPost('giftPackSync', {activateIds = goodsIds}, onSuccess, onFail, onCancel)
	end
end

function GiftPack:getNewerPackOneGoodsIds()
	local A3 = self:isEnabledInGroup('A3')
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local offset = A3 and 2 or 0

	return {goodsIds[1 + offset], goodsIds[2 + offset]}
end

function GiftPack:triggerNewerPackOne()
	self:print('triggerNewerPackOne...')
	self:triggerPack(self:getNewerPackOneGoodsIds())
end

function GiftPack:triggerGuidePack()
	self:print('triggerGuidePack...')
	self:triggerPack(PackTypeConfigs[GiftPackType.kGuide].goodsIds)
end

function GiftPack:triggerNewerPackTwo()
	self:print('triggerNewerPackTwo...')
	self:triggerPack(PackTypeConfigs[GiftPackType.kNewer2].goodsIds)
end

function GiftPack:tryTriggerGuidePack()
	self:print('tryTriggerGuidePack...')
	local A2 = self:isEnabledInGroup('A2')
	if A2 then 
		self:print('A2 is true, guide disabled!')
		return false
	end
	local goodsId = PackTypeConfigs[GiftPackType.kGuide].goodsIds[1]
	local info = self.info[goodsId]

	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	for _,gid in ipairs(goodsIds) do
		if self:hasBought(gid) then
			return false
		end
	end

	if not info or (info.activateCount and info.activateCount <= 0) then
		self:triggerGuidePack()
		return true
	end 
end

function GiftPack:tryTriggerNewerPackTwo()
	local goodsIds = PackTypeConfigs[GiftPackType.kNewer1].goodsIds
	local deadline = 0
	local now = Localhost:time()
	local cooltime = -1

	local count = 0
	for _,goodsId in ipairs(goodsIds) do
		local info = self.info[goodsId]
		local config = PackConfigs[goodsId]
		if info.activateCount > 0 then
			if cooltime == -1 or config.cooltime < cooltime then
				count = info.activateCount
				cooltime = config.cooltime
				deadline = self:getPackDeadline(goodsId)
			end
		end
	end

	local goodsId = PackTypeConfigs[GiftPackType.kNewer2].goodsIds[1]
	local info = self.info[goodsId]

	local hasCooltime = cooltime ~= -1
	local isCoolEnd = now >= (deadline + cooltime)
	local needtri = info.activateCount < count

	self:print('tryTriggerNewerPackTwo:', hasCooltime, isCoolEnd, needtri)

	if hasCooltime and isCoolEnd and needtri then
		--trigger 
		self:triggerNewerPackTwo()
		return true
	end
end

function GiftPack:tryTriggerNewLoop()
	local goodsId = PackTypeConfigs[GiftPackType.kNewer2].goodsIds[1]
	local config = PackConfigs[goodsId]
	local info = self.info[goodsId]
	local cooltime = config.cooltimes[info.activateCount or 1] or config.cooltimes[#config.cooltimes]
	cooltime = cooltime * 3600 * 24 * 1000

	if self:isDebug() then
		cooltime = 0
	end

	config.cooltime = cooltime
	local now = Localhost:time()

	local tar_levelId = config.nextLoopCon[info.activateCount or 1] or config.nextLoopCon[#config.nextLoopCon]
	local toplevelId = UserManager:getInstance().user:getTopLevelId()

	local goodsIds = self:getNewerPackOneGoodsIds()
	local oneInfo = self.info[goodsIds[1]]

	if toplevelId >= tar_levelId and
		(now >= (cooltime + info.expTime)) and
		info.activateCount == oneInfo.activateCount
	then
		self:triggerNewerPackOne()
		return true
	end
end

function GiftPack:print( ... )
	if __WIN32 then
		printx(10, '[GiftPack]', ...)
		RemoteDebug:uploadLog('[GiftPack]', ...)
	end
end

function GiftPack:onNoPack()
	self:print('A4 is true, no pack!')
	self:tryShowWindmill()
end

--触发入口
function GiftPack:onAddFivePanelShow(addFivePanel, onclose)
	require 'zoo.localActivity.Double112018.DoubleOneOneModel'
	if DoubleOneOneModel:tryCreateEndgamePanel(onclose, addFivePanel) then
		return
	end
	self.addFivePanel = addFivePanel
	self.onclose = onclose

	-- self:showPack(-1)
	-- do return end

	if not self:isEnabled() then
		self:print('gift pack feature disabled!')
		self:onNoPack()
		return
	end

	if not self.info then return end

	if not self:hasAnyActPack() then
		self:checkGroupConfig(true)
	end

	local isEnabled = false
	for _,name in ipairs({'A1', 'A2', 'A3', 'A4', 'B1', 'C1', 'D1'}) do
		if self:isEnabledInGroup(name) then
			isEnabled = true
		end
	end

	if not isEnabled then
		self:print('gift pack feature disabled, all close!')
		return
	end

	local A4 = self:isEnabledInGroup('A4')
	if A4 then
		self:onNoPack()
		return
	end

	--check trigger
	if not self:isTriggered() then
		self:triggerNewerPackOne()
	else
		self:onShowGiftPack()
	end
end

function GiftPack:dc( category, subCategory, data )
	local params = {
		game_type = "stage",
		game_name = "paymentPack",
		category = category,
		sub_category = subCategory,
	}

	for name,value in pairs(data or {}) do
		params[name] = value
	end
	DcUtil:activity(params)
end

function GiftPack:onShowGiftPack()
	if not self.addFivePanel or self.addFivePanel.isDisposed then
		self:print('do nothing, add five panel is closed!')
		return
	end

	--guide or upper bought -> gift pack over
	if self:hasBoughtGuidePack() or self:hasBoughtNewerUpper() then
		self:print('guide or newer upper has bought, close gift pack feature!')
		return
	end

	local goodsId = nil

	repeat
		--newer pack has bought -> show newer upper pack
		local packInfo = self:getBoughtNewerPack()
		if packInfo then
			--show newer upper pack,check cool time
			local upper = packInfo.upper
			local boughtTime = self:getPackBoughtTime(packInfo.goodsId)
			local now = Localhost:time()
			local upper_deadline = self:getPackDeadline(upper.goodsId)
			local time = (boughtTime + packInfo.upper_cooltime) - now
			local canTri = time < 0
			if  canTri and upper_deadline == 0 then
				self:triggerPack({upper.goodsId})
				return
			elseif canTri and upper_deadline > now then
				goodsId = upper.goodsId
			end
			self:print('try trigger upper pack,but at cool time:', time/3600/24/1000)
		end

		--pack loop
		local loopId, isTriggerGuide = self:checkGiftLoop()
		if isTriggerGuide then
			return
		end
		if loopId then
			goodsId = loopId
			break
		end

		if packInfo then
			break
		end
		--newer pack 2
		local newer2id = self:checkNewerGiftTwo()
		if newer2id then
			goodsId = newer2id
			break
		end

		--try trigger newer pack 2
		if self:tryTriggerNewerPackTwo() then
			return
		end

		local cycle = self:getNewerPackCycle()
		self:print('cycle:', cycle)
		if cycle % 2 == 0 then
			local toplevelId = UserManager.getInstance().user:getTopLevelId()
			local levelDataInfo = UserService.getInstance().levelDataInfo
			local levelInfo = levelDataInfo:getLevelInfo(self.currentlevel or toplevelId)
			local failTimes = 0

			if levelInfo then
				failTimes = levelInfo.failTimes or 0
			end

			local mgr = PromotionManager:getInstance()
			if mgr:isInPromotion() then
				goodsId = mgr:getGoodsId()
				break
			elseif failTimes >= 4 then
				local function cb(result)
					if result and self.addFivePanel and not self.addFivePanel.isDisposed then
						self:showPack(mgr:getGoodsId())
					end
				end
				mgr:tryTriggerFormGiftPack(cb)
				return
			end
		end

		--try trigger new loop
		if self:tryTriggerNewLoop() then
			return
		end
	until( true )

	self:print('show goodsId:', goodsId)

	if goodsId then
		self:showPack(goodsId)
		return
	end

	self:tryShowWindmill()
end

function GiftPack:tryShowWindmill()
	local D1 = self:isEnabledInGroupMustNewer('D1')
	local toplevelId = UserManager.getInstance().user:getTopLevelId()
	if D1 and toplevelId >= 20 and __ANDROID then
		MarketManager:sharedInstance():getGoldProductInfo(function ()
			self:showPack(-1)
		end)
	end
end

function GiftPack:onTapIcon( goodsId )
	local pt = self:getPackType(goodsId)
	if pt == GiftPackType.kNewer1 then
		MarketManager:sharedInstance():loadConfig()
		local index = MarketManager:sharedInstance():getGiftPackPageIndex()
		if index ~= 0 then
			local panel =  createMarketPanel(index, nil)
			if panel then
				GiftPack:dc('canyu', 'shop_push', {t1 = 0})
				panel:popout()
			end
		end
	else
		local GiftPackPanel = require 'zoo.giftpack.GiftPackPanel'
		local panel = GiftPackPanel:create(goodsId)
		GiftPack:dc('canyu', 'mainpanel_push', {t1 = 0})
		panel:popout()
	end
end

Notify:register('GiftPackInitEvent', GiftPack.init, GiftPack)
Notify:register('CloseGiftPackEndgamePanelEvent', GiftPack.onCloseEndgamePanel, GiftPack)

if __WIN32 then
	if OLD_PACK then
		OLD_PACK:closeSchedule()
		GiftPack:init()
	end
end