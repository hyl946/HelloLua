--[[
 * Double112018
 * @date    2018-10-24 11:51:21
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

DoubleOneOneModel = {
	data = {},
}

local ActId = {
	kOneOne = 3014,
	kThanks = 3015
}

local goodsIdsInfo = {
	{513,514,515},
	{516,517,518},
	{519,520,521},
	{522,523,524},
	{525,526,527},
	{528,529,530},
	{531,532,533},
	{534,535,536},
}

function DoubleOneOneModel:isEnabled(actId)
	local config = self:getActConfigSync(actId)
	if config then
		return config.isEnabled(actId == ActId.kThanks)
	end
	return false
end

function DoubleOneOneModel:getActInfo(actId)
    local actInfo
    for k, v in pairs(UserManager:getInstance().actInfos or {}) do
        if v.actId == actId then
            actInfo = v
            break
        end
    end
    return actInfo
end

function DoubleOneOneModel:getActConfigSync(actId)
	local activitys = ActivityUtil:getAllActivitysSync()
	local activity = table.find(activitys,function( v )
        local c = require("activity/" .. v.source)
        return tostring(c.actId) == tostring(actId)
    end)
    
    if activity  then
    	return (require("activity/" .. activity.source))
    end
end

function DoubleOneOneModel:getData( actId )
	local config = self:getActConfigSync(actId)
	if config then
		return config.getData()
	end
	return {}
end

function DoubleOneOneModel:print( ... )
	if self:isDebug() and RemoteDebug then
		RemoteDebug:uploadLog(10, '[Double112018]', ...)
	end
end

function DoubleOneOneModel:isDebug()
	return MaintenanceManager:getInstance():isEnabled("DoubleOneOneLog")
end

function DoubleOneOneModel:getEndTime( actId )
	local data = self:getData(actId)
	return data.endTime or 0
end

function DoubleOneOneModel:hasBought(boughtGoods)
	if boughtGoods then
		for k,v in pairs(boughtGoods) do
			return true
		end
	end
	return false
end

function DoubleOneOneModel:hasNotBought( goodsIds, boughtGoods )
	goodsIds = goodsIds or {}

	if not boughtGoods then return true end

	for _,goodsId in ipairs(goodsIds) do
		if not boughtGoods[tostring(goodsId)] then
			return true
		end
	end
	return false
end

function DoubleOneOneModel:checkPath()
	self.dataPath = self.dataPath or (HeResPathUtils:getUserDataPath() .. '/d112018_'..(UserManager:getInstance().uid or '0'))
end

function DoubleOneOneModel:getCacheData()
	self:checkPath()
	local file = io.open(self.dataPath, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            return table.deserialize(content) or {}
        end
    end
    return {}
end

function DoubleOneOneModel:saveCacheData( cacheData )
	self:checkPath()

	local file = io.open(self.dataPath,"w")
    if file then 
        file:write(table.serialize(cacheData or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(self.dataPath..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(cacheData or {}))
	        file:close()
	    end
    end
end

function DoubleOneOneModel:getEndgameGoodsId()
	local oneEnable = self:isEnabled(ActId.kOneOne)
	local tksEnable = self:isEnabled(ActId.kThanks)

	if not oneEnable and not tksEnable then
		return
	end

	local data11 = self:getData(ActId.kOneOne)
	local datatks = self:getData(ActId.kThanks)

	local maxLevel = #goodsIdsInfo

	local cacheData = self:getCacheData() or {}

	local shownData11 = table.clone(cacheData.shownData11 or {})

	local dTargetId = nil
	if oneEnable then
		local goodsIds = goodsIdsInfo[data11.level]
		if self:hasNotBought(goodsIds, data11.boughtGoods) then
			local showAll = true
			for _,goodsId in ipairs(goodsIds) do
				local shownCount = shownData11[tostring(goodsId)] or 0
				if shownCount < 2 and not data11.boughtGoods[tostring(goodsId)] then
					showAll = false
					dTargetId = goodsId
					break
				end
			end

			if showAll then
				for k,v in pairs(shownData11) do
					shownData11[k] = 0
				end
			end

			for _,goodsId in ipairs(goodsIds) do
				local shownCount = shownData11[tostring(goodsId)] or 0
				if shownCount < 2 and not data11.boughtGoods[tostring(goodsId)] then
					dTargetId = goodsId
					break
				end
			end

			if dTargetId then
				shownData11[tostring(dTargetId)] = (shownData11[tostring(dTargetId)] or 0) + 1
			end
		end
	end


	local tksTargetId = nil

	if tksEnable then
		local c = self:getActConfigSync(ActId.kThanks)
		if c then
			tksTargetId = c.getTargetId()
		end
	end

	local targetId = nil
	local isDouble11 = true
	
	if tksTargetId then
		targetId = tksTargetId
		isDouble11 = false
		self:print('targetId', targetId, 'trigger by tks!')
	elseif dTargetId then
		targetId = dTargetId
		cacheData.shownData11 = shownData11
		self:print('targetId', targetId, 'trigger by double!')
	end

	self:saveCacheData(cacheData)

	return targetId, isDouble11
end

function DoubleOneOneModel:getActConfig(actId, cb)
	ActivityUtil:getActivitys(function( activitys )
        local activity = table.find(activitys,function( v )
            local c = require("activity/" .. v.source)
            return tostring(c.actId) == tostring(actId)
        end)
        
        if activity and cb then
        	cb(require("activity/" .. activity.source))
        end
    end)
end

function DoubleOneOneModel:onActInfoChange()
	self:getActConfig(ActId.kOneOne, function (c)
		c.parseActInfo()
	end)

	self:getActConfig(ActId.kThanks, function (c)
		c.parseActInfo()
	end)
end

function DoubleOneOneModel:tryCreateEndgamePanel(onclose, addFivePanel, testGoodsId)
	if self.endgamePanel then
		self:onCloseEndgamePanel()
	end

	if not self:isEnabled(ActId.kOneOne) and not self:isEnabled(ActId.kThanks) then
		return false
	end

	local goodsId, isDouble11 = self:getEndgameGoodsId()
	self.isDouble11 = isDouble11

	if not goodsId then return false end

	self.addFivePanel = addFivePanel

	if testGoodsId then
		goodsId = testGoodsId
		printx(10, goodsId)
	end

	local DoubleEEndgamePanel = require 'zoo.localActivity.Double112018.DoubleEEndgamePanel'
	self.endgamePanel = DoubleEEndgamePanel:create(goodsId, isDouble11, onclose)
	-- self.endgamePanel:popout()

	if self.addFivePanel then
		self.addFivePanel:addBottomAD(self.endgamePanel)
	else
		self.endgamePanel:popout()
	end

	return true
end

function DoubleOneOneModel:onBuySuccess( goodsId )
	local function sync( c )
		if not c then return end
		local data = c.getData()
		if data and data.boughtGoods then
			local num = data.boughtGoods[tostring(goodsId)] or 0
			data.boughtGoods[tostring(goodsId)] = num + 1
		end
	end

	sync(self:getActConfigSync(ActId.kOneOne))
	sync(self:getActConfigSync(ActId.kThanks))

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local bottle = table.find(meta.items, function (item)
		return item.itemId == 10098
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
end

function DoubleOneOneModel:buy( goodsId, scb, fcb, ccb )
	local function dcInfo()
		local info = {
			game_type = "stage",
			game_name = "Dblsale2018",
			category = 'canyu',
			sub_category = 'dblsale_add_5_steps',
		}
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
		info.goods_id = goodsId

		self.buylogic = nil
		
		info.list_id = goodsId
		info.short_time = self.isDouble11 and 0 or 1
		info.currentlevel = self.currentlevel

		DcUtil:activity(info)
	end
	local function onSuccess()
		dcInfo()
        if scb then scb() end
    end

    local function onFail()
    	dcInfo()
        if fcb then fcb() end
    end

    local function onCancel()
    	dcInfo()
        if ccb then ccb() end
    end

    if __IOS then
        self.buylogic = IapBuyPropLogic:create(goodsId, DcFeatureType.kActivityInner, DcSourceType.kActPre.."2018_double11")
        if self.buylogic then 
            self.buylogic:buy(onSuccess, onFail)
        end
    elseif __WIN32 then
    	local logic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, DcFeatureType.kActivityInner, DcSourceType.kActPre.."2018_double11")
        logic:deliverItems(goodsId, 1)
        onSuccess()
    elseif __ANDROID then
        self:androidBuy(goodsId, onSuccess, onFail, onCancel)
    end
end


function DoubleOneOneModel:androidBuy( goodsId, onSuccess, onFail, onCancel )
    local M = PaymentManager.getInstance()
    local ThirdPayWithoutNetCheck = {
		Payments.WO3PAY,
		Payments.TELECOM3PAY,
	}

    local repayChooseTable

    local function handlePayment( decision, payType )
        self.buylogic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, DcFeatureType.kActivityInner, DcSourceType.kActPre.."2018_double11")
        self.buylogic:specialBuy(decision, payType, onSuccess, onFail, onCancel, repayChooseTable, nil, true)
    end

    if PrepackageUtil:isPreNoNetWork() then
        PrepackageUtil:showInGameDialog(onCancel)
        return 
    end

    local defaultThirdPartyPayment = M:getDefaultThirdPartPayment()
    local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment

    if table.includes(ThirdPayWithoutNetCheck, defaultThirdPartyPayment) then 
		--这里的三方 不用联网检测 比如TELECOM3PAY
		repayChooseTable = M:filterRepayPayment(thirdPartPaymentTable)
		handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment) 
	else
	    PaymentNetworkCheck.getInstance():check(function ()
	        --一种优先三方 若为支付宝引导快付       
	        repayChooseTable = M:filterRepayPayment(thirdPartPaymentTable)
	        handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment) 
	    end, function ()
	        CommonTip:showTip(Localization:getInstance():getText("payment_repay_txt4"), "negative")
	    end)
	end
end

function DoubleOneOneModel:onCloseEndgamePanel()
	if self.endgamePanel then
		if not self.endgamePanel.isDisposed then
			self.endgamePanel:remove()
		end
		self.endgamePanel = nil
	end
end

Notify:register('CloseDouble112018EndgamePanelEvent', DoubleOneOneModel.onCloseEndgamePanel, DoubleOneOneModel)
Notify:register('ActInfoChange', DoubleOneOneModel.onActInfoChange, DoubleOneOneModel)