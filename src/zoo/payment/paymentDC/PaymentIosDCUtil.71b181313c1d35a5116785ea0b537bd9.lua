
PaymentIosDCUtil = class()
local instance = nil
function PaymentIosDCUtil.getInstance()
	if not instance then
		instance = PaymentIosDCUtil.new()
		instance:init()
	end
	return instance
end

function PaymentIosDCUtil:init()

end

--唯一支付ID
function PaymentIosDCUtil:getNewIosPayID()
	local userId = UserManager:getInstance().user.uid
	if not userId then
		userId = "12345" 
	end
	local timeStamp = os.time()
	local payId = userId.."_"..timeStamp
	return payId
end

function PaymentIosDCUtil:setIosRmbPayStart(dcIosInfo)
	if not __IOS then return end
	DcUtil:UserTrack({category = "payment",
						sub_category = "start_ios",
						pay_id = dcIosInfo.payId,
						goods_id = dcIosInfo.goodsId,
						goods_type = dcIosInfo.goodsType,
						goods_num = dcIosInfo.goodsNum,
						price = dcIosInfo.price,
						current_stage = dcIosInfo.currentStage,
						meta_level_id = dcIosInfo.metaLevelId,
						level = dcIosInfo.topLevel,
						province = dcIosInfo.province,
						playId = dcIosInfo.playId,
						version = dcIosInfo.version})
end

--result：支付结果 DCIosRmbObject
function PaymentIosDCUtil:sendIosRmbPayEnd(dcIosInfo)
	if not __IOS then return end

	local authentication = RealNameManager:isTriggered()
	local srcPayId = self.srcPayId

	DcUtil:UserTrack({category = "payment",
						sub_category = "end_ios",
						result = dcIosInfo.result,
						error_code = dcIosInfo.errorCode,
						error_msg = dcIosInfo.errorMsg,
						pay_id = dcIosInfo.payId,
						pay_id_src = srcPayId,
						goods_id = dcIosInfo.goodsId,
						goods_type = dcIosInfo.goodsType,
						goods_num = dcIosInfo.goodsNum,
						price = dcIosInfo.price,
						current_stage = dcIosInfo.currentStage,
						meta_level_id = dcIosInfo.metaLevelId,
						level = dcIosInfo.topLevel,
						province = dcIosInfo.province,
						version = dcIosInfo.version,
						playId = dcIosInfo.playId,
						authentication = authentication})
end

function PaymentIosDCUtil:sendIosProductIdChange(dcIosInfo, newProductId)
	if not __IOS then return end
	DcUtil:UserTrack({category = "payment",
						sub_category = "ios_product_change",
						pay_id = dcIosInfo.payId,
						goods_id = dcIosInfo.goodsId,
						goods_type = dcIosInfo.goodsType,
						goods_num = dcIosInfo.goodsNum,
						price = dcIosInfo.price,
						new_goods_id = newProductId,
						level = dcIosInfo.topLevel,
						version = dcIosInfo.version})
end

--result：支付结果 详见DCWindmillPayResult
function PaymentIosDCUtil:sendIosWindmillPayEnd(dcWindmillInfo)
	if not __IOS then return end
	local curHappyCoin = UserManager:getInstance().user:getCash()

	local authentication = RealNameManager:isTriggered()
	local doSampling = dcWindmillInfo.result and dcWindmillInfo.result == DCWindmillPayResult.kCloseDirectly
	DcUtil:UserTrack({category = "payment",
						sub_category = "end_wm",
						result = dcWindmillInfo.result,
						error_code = dcWindmillInfo.errorCode,
						type_choose = dcWindmillInfo.typeChoose,
						pay_id = dcWindmillInfo.payId,
						goods_id = dcWindmillInfo.goodsId,
						goods_type = dcWindmillInfo.goodsType,
						goods_num = dcWindmillInfo.goodsNum,
						price = dcWindmillInfo.price,
						surplus = curHappyCoin,
						current_stage = dcWindmillInfo.currentStage,
						meta_level_id = dcWindmillInfo.metaLevelId,
						level = dcWindmillInfo.topLevel,
						playId = dcWindmillInfo.playId,
						authentication = authentication
						}, doSampling)
end

function PaymentIosDCUtil:setSrcPayId(srcPayId)
	self.srcPayId = srcPayId
end