---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-06-26 10:30:35
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-06-27 15:58:37
---------------------------------------------------------------------------------------
local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"

AlipaySignLogic = class()

AlipaySignRet = {
	Success = 0,
	Fail = 1,
	Cancel = 2,
}

function AlipaySignLogic.getInstance()
	if not AlipaySignLogic._instance then
		AlipaySignLogic._instance = AlipaySignLogic.new()
	end
	return AlipaySignLogic._instance
end

function AlipaySignLogic:isAlipaySigned()
	return UserManager:getInstance().userExtend.aliIngameState == 1
end

function AlipaySignLogic:isAlipayInstall()
	return OpenUrlUtil:canOpenUrl("alipays://platformapi/startapp")
end

function AlipaySignLogic:startSign(entrance, onSignCallback)
	assert(entrance, "sign entrance must not be nil")
	if not self:isAlipayInstall() then
		CommonTip:showTip("请先安装支付宝！", "positive", nil, 2)
		return
	else
		self:dc(entrance)
		self:sendSignRequest(onSignCallback)
	end
end

function AlipaySignLogic:dc(entrance)
    if type(entrance) == "number" and entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL then
    	local dcPopTimes = 0
        if entrance == AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL then -- 这种情况，提前加了
        	dcPopTimes = AliQuickPayGuide.getPopoutTimes()
        else
            dcPopTimes = AliQuickPayGuide.getPopoutTimes()+1
        end

       	local payType = self:getDefaultPayType()
	    local guideFlag = 0
	    if entrance ~= AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL then
	    	guideFlag = AliQuickPayGuide.isGuideTime() and 0 or 1
	    end
	    local t1 = 10*entrance + payType
	    local t2 = (guideFlag == 1) and 4 or popoutTimes
	    local step = 1

	    DcUtil:UserTrack({ category='alipay_mianmi_accredit',
	                       sub_category='accredit_flow_source', 
	                       t1 = t1,
	                       t2 = t2,
	                       -- t3 = popoutTimes,
	                       t4 = guideFlag,
	                       t5 = step,})
    end

    if entrance ~= AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL and
       	entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL
        and entrance ~= AliQuickSignEntranceEnum.PROMO_PANEL then
			if AliQuickPayGuide.isGuideTime() then
				AliQuickPayGuide.updateGuideTimeAndPopCount()
			end
    end
end

function AlipaySignLogic:getDefaultPayType()
    local payType = 4
    local defaultPayment = PaymentManager:getInstance():getDefaultPayment()
    if  defaultPayment == Payments.ALIPAY then
    	payType = 2	
    elseif defaultPayment == Payments.WECHAT then
    	payType = 3
    elseif PaymentManager:checkPaymentTypeIsSms(defaultPayment) then
        payType = 1
    end
    return payType
end

function AlipaySignLogic:sendSignRequest(onSignCallback)
	local function onRequestSuccess(event)
		self:startNewSignProcess(onSignCallback)

    	local paraString = HeDisplayUtil:urlEncode(event.data.url)
    	OpenUrlUtil:openUrl('alipays://platformapi/startapp?appId=20000067&url='..paraString)
    	-- RemoteDebug:uploadLogWithTag("sendSignRequestV2", event.data.url)
    	DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_0", t1 = self.t1, t2 = self.t2})
	end

	local function onRequestFail(event)
		local errMessage = AliQuickPayGuide.getErrorMessage(event.data, "ali.quick.pay.sign.error")
		CommonTip:showTip(errMessage, "negative", nil, 3)
		if tonumber(event.data) == 730242 then --已经签过约
			--按照签约成功来处理
			self:onSignSuccess()
		end
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_1_"..tostring(event.data), t1 = self.t1, t2 = self.t2 })
	end

	local function onRequestCancel(event)
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = 0, t1 = self.t1, t2 = self.t2})
	end

	local function doSend()
		local http = GetAliPaymentSign.new(1)
		http:addEventListener(Events.kComplete, onRequestSuccess)
		http:addEventListener(Events.kError, onRequestFail)
		http:addEventListener(Events.kCancel, onRequestCancel)
		http:syncLoad()
	end

	RequireNetworkAlert:callFuncWithLogged(function()
						doSend()
					end, 
					function() 
					end, 
					kRequireNetworkAlertAnimation.kDefault)
end

function AlipaySignLogic:startNewSignProcess(onSignCallback)
	self:cancelCurrentSignProcess()

	self.signProcessId = os.time()
	self.onSignCallback = onSignCallback
end

function AlipaySignLogic:cancelCurrentSignProcess()
	self.signProcessId = nil
	self.onSignCallback = nil
end

function AlipaySignLogic:isSignCallbackScheme(launchURL)
	if launchURL and string.starts(launchURL, 'happyanimal3://ali/sign') then
		return true
	end
	return false
end

function AlipaySignLogic:onSignSuccess()
	UserManager.getInstance().userExtend.aliIngameState = 1
	UserService.getInstance().userExtend.aliIngameState = 1
	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData() end
end

function AlipaySignLogic:onSignResultCallback(data)
	if data then
		-- https://docs.open.alipay.com/200/105351
		local retCode = tostring(data.code)
		if retCode == "10000" then
			self:onSignSuccess()

			if self.onSignCallback then self.onSignCallback(AlipaySignRet.Success, data) end
		elseif retCode == "60001" then
			if self.onSignCallback then self.onSignCallback(AlipaySignRet.Cancel) end
		else
			DcUtil:log(AcType.kExpire30Days, {category='alipay_mianmi_accredit', sub_category = 'sign_fail', code = data.code, msg = data.msg, sub_code = data.sub_code, sub_msg = data.sub_msg})
			if self.onSignCallback then self.onSignCallback(AlipaySignRet.Fail, data) end
		end
	else
		if self.onSignCallback then self.onSignCallback(AlipaySignRet.Fail) end
	end
end

function AlipaySignLogic:beforeApplicationHandleOpenURL(launchURL)
	if not self:isSignCallbackScheme(launchURL) then
		self:cancelCurrentSignProcess()
	end
end

function AlipaySignLogic:onApplicationHandleOpenURL(launchURL)
	-- RemoteDebug:uploadLogWithTag("onApplicationHandleOpenURL", self.signProcessId, launchURL)
	if self:isSignCallbackScheme(launchURL) and self.signProcessId then
		local params = UrlParser:parseParams(launchURL)
		self:onSignResultCallback(params.para)
		
		self:cancelCurrentSignProcess()
		return true
	end
	return false
end