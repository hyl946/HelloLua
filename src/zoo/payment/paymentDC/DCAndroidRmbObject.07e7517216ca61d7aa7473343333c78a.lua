
DCAndroidRmbObject = class()

AndroidRmbPayResult = table.const{
	kSuccess = 0,
	kNoPaymentAvailable = 1,
	kNoNet = 2,
	kDoOrderFail = 3,
	kSmsPermission = 4,
	kSdkInitFail = 5,
	kSdkFail = 6,
	kSdkCancel = 7,
	kCloseDirectly = 8,
	kCloseAfterNoNet = 9,					--有二次确认框弹出 因未联网导致支付失败 没有弹重买面板 玩家直接关闭二次确认
	kCloseAfterNoPaymentAvailable = 10,		--仅用于最终阶段加五步面板
	kCloseRepayPanel = 11,
	kAndroidPayConfirmCancel = 12,			--失败：游戏中二次确认支付面板点击取消按钮。
	kCloseAfterNoNetWithoutSec = 13,		--没有二次确认框弹出 因为未联网 导致支付直接失败的
	kNoRealNameAuthed = 14,
	kCloseAfterNoRealNameAuthed = 15
}

--针对PayPanelSingleThird面板上 打点区别免密非免密的几种情况
SignPayChooseType = table.const{
	kNikeBuy = 1,						--签约并支付
	kNikeClose = 2,						--勾选但直接关闭
	kNoNikeBuy = 3,						--未勾选免密然后支付
	kNoNikeClose = 4,					--未勾选免密并关闭
}


WechatFriendResult = table.const{
	kSuccess = 0,
	kCancel = 1,
	kFail = 2,
}

function DCAndroidRmbObject:ctor()
	self.payId = nil				--
	self.result = nil
	self.errorCode = nil
	self.errorMsg = nil
	self.typeDefault = nil			--
	self.typeList1 = nil
	self.typeListCat1 = nil
	self.typeList2 = nil
	self.typeListCat2 = nil 
	self.typeStatus = nil			--
	self.typeChoose = nil
	self.goodsId = nil				--
	self.goodsType = nil			--
	self.goodsNum = nil				--
	self.price = nil							
	self.times = nil				--
	self.currentStage = nil			--
	self.topLevel = nil				--
	self.province = nil				--
	self.typeDisplay = nil
	self.signChooseType = nil 		--
	self.channelId = nil
	self.tradeId = nil
	self.playId = nil
end

function DCAndroidRmbObject:init()
	self.payId = PaymentDCUtil.getInstance():getNewPayID()
	self.typeDefault = PaymentManager:getInstance():getDefaultPayment()
	self.times = 0
	self.topLevel = UserManager.getInstance().user:getTopLevelId()
	local scene = Director.sharedDirector():getRunningScene()
	if scene and scene:is(GamePlaySceneUI) then 
		self.currentStage = scene.levelId
		self.metaLevelId = LevelMapManager.getInstance():getMetaLevelId(self.currentStage)
	else
		self.currentStage = -1
		self.metaLevelId = -1
	end
	self.province = Cookie.getInstance():read(CookieKey.kLocationProvince)
	self.playId = GamePlayContext:getInstance():getIdStr()

	return true	
end

function DCAndroidRmbObject:getUniquePayId()
	return self.payId
end

function DCAndroidRmbObject:setTypeDisplay( typeDisplay )
	self.typeDisplay = typeDisplay
end

function DCAndroidRmbObject:setResult(result, errorCode, errorMsg)
	self.result = result
	self.errorCode = errorCode	
	self.errorMsg = errorMsg
end

function DCAndroidRmbObject:getResult()
	return self.result
end

function DCAndroidRmbObject:setChannelId(channelId)
	self.channelId = channelId
end

function DCAndroidRmbObject:getChannelId()
	return self.channelId
end

function DCAndroidRmbObject:setInitialTypeList(paymentTypeTable, singlePaymentType)
	local finalTable = {}
	if paymentTypeTable then 
		if type(paymentTypeTable) == "number" then 
			table.insert(finalTable, paymentTypeTable)
		elseif type(paymentTypeTable) == "table" then 
			finalTable = table.clone(paymentTypeTable)
		end
	end
	if singlePaymentType and type(singlePaymentType) == "number" and not table.includes(finalTable, singlePaymentType) then 
		table.insert(finalTable, singlePaymentType)
	end

	finalTable = self:filterRepayTypeList(finalTable)
	
	self.typeList1 = PaymentDCUtil.getInstance():getAlterPaymentList(finalTable)
	self.typeListCat1 = table.concat(finalTable, "_")
end

function DCAndroidRmbObject:setRepayTypeList(paymentTypeTable)
	local finalTable = {}
	if paymentTypeTable then 
		if type(paymentTypeTable) == "number" then 
			table.insert(finalTable, paymentTypeTable)
		elseif type(paymentTypeTable) == "table" then 
			finalTable = paymentTypeTable
		end
	end

	finalTable = self:filterRepayTypeList(finalTable)
	self.typeList2 = PaymentDCUtil.getInstance():getAlterPaymentList(finalTable)
	self.typeListCat2 = table.concat(finalTable, "_")
end

--免密支付 打点特殊处理
--原始的重买列表 根据需求会在后续变动 目前用于处理微信和支付宝的免密
function DCAndroidRmbObject:filterRepayTypeList(oriRepayChooseTable)
	assert(oriRepayChooseTable, "DCAndroidRmbObject:filterRepayChooseTable === No oriRepayChooseTable !")
	local finalRepayTable = {}
	for i,v in ipairs(oriRepayChooseTable) do
		if v == Payments.WECHAT then 
			if UserManager:getInstance():isWechatSigned() then 
				table.insert(finalRepayTable, Payments.WECHAT_QUICK_PAY)
			else
				table.insert(finalRepayTable, v)
			end
		elseif v == Payments.ALIPAY then 
			if UserManager.getInstance():isAliSigned() then 
				table.insert(finalRepayTable, Payments.ALI_QUICK_PAY)
			else
				table.insert(finalRepayTable, v)
			end
		else
			table.insert(finalRepayTable, v)
		end
	end
	return finalRepayTable
end

--免密支付 打点特殊处理
function DCAndroidRmbObject:adjustTypeList(adjustPayType, fromRepayPanel)
	assert(adjustPayType, "DCAndroidRmbObject:adjustTypeList === No adjustPayType !")
	local function getChildIndex(tb, cd)
		if not tb or not cd then return end
		for i,v in ipairs(tb) do
			if v == cd then 
				return i
			end
		end
	end

	local function adjustFunc(oriPaytype, newPayType)
		local typeList = self.typeList1
		if fromRepayPanel then 
			typeList = self.typeList2
		end
		local payTypeTable = PaymentDCUtil.getInstance():getPaymentListTable(typeList) or {}
		if table.includes(payTypeTable, newPayType) then return end
		local cdIndex = getChildIndex(payTypeTable, oriPaytype)
		if cdIndex then 
			table.remove(payTypeTable, cdIndex)
		end
		table.insert(payTypeTable, newPayType)
		if fromRepayPanel then 
			self.typeList2 = PaymentDCUtil.getInstance():getAlterPaymentList(payTypeTable)
			self.typeListCat2 = table.concat(payTypeTable, "_")
		else
			self.typeList1 = PaymentDCUtil.getInstance():getAlterPaymentList(payTypeTable)
			self.typeListCat1 = table.concat(payTypeTable, "_")
		end
	end

	if adjustPayType == Payments.ALI_QUICK_PAY then 
		adjustFunc(Payments.ALIPAY, adjustPayType)
	elseif adjustPayType == Payments.ALIPAY then 
		adjustFunc(Payments.ALI_QUICK_PAY, adjustPayType)
	elseif adjustPayType == Payments.WECHAT_QUICK_PAY then
		adjustFunc(Payments.WECHAT, adjustPayType) 
	elseif adjustPayType == Payments.WECHAT then 
		adjustFunc(Payments.WECHAT_QUICK_PAY, adjustPayType) 
	end
end

function DCAndroidRmbObject:setTypeStatus(typeStatus)
	self.typeStatus = typeStatus
end

function DCAndroidRmbObject:setTypeChoose(typeChoose, fromRepayPanel)
	self:adjustTypeList(typeChoose, fromRepayPanel)
	self.typeChoose = typeChoose
end

function DCAndroidRmbObject:setGoodsId(goodsId)
	self.goodsId = goodsId
end

function DCAndroidRmbObject:setGoodsType(goodsType)
	self.goodsType = goodsType
end

function DCAndroidRmbObject:setGoodsNum(goodsNum)
	self.goodsNum = goodsNum
end

function DCAndroidRmbObject:setRmbPrice(price)
	self.price = price
end

function DCAndroidRmbObject:increaseTimes()
	self.times = self.times + 1	
end

function DCAndroidRmbObject:setSignChooseType(signChooseType)
	self.signChooseType = signChooseType
end

function DCAndroidRmbObject:create()
	local dcObj = DCAndroidRmbObject.new()
	if dcObj:init() then 
		return dcObj
	else
		dcObj = nil
	end
end

function DCAndroidRmbObject:setTradeId(tradeId)
	self.tradeId = tradeId
end
