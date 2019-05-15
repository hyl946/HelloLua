
DCAndroidStatus = class()

DecisionJudgeType = table.const{
	kDefaultPaymentType = {
		YES = "defaultSmsYes_",
		NO = "defaultSmsNo_",
	},
	kSmsEnabled = {
		YES = "smsEnable_",
		LIMIT_NO = "smsLimit_",
		CLOSE_NO = "smsClose_",
		CARD_NO = "smsCard_",
		INIT_NO = "smsInit_",
		NO_PAYCODE_NO = "smsNoPaycode_",
	},
	kThirdPayEnable = {
		YES = "thirdEnable_",
		NO = "thirdDisable_",
	},
	kNetEnable = {
		YES = "netEnable_",
		NO = "netDisable_",
	},
	kOneYuanEnable = {
		YES = "oneYuanEnable_",
		NO = "oneYuanDisable_",		
	}
}	

local statusTable = table.const{
	--默认短代 短代可用 触发一元 联网 										---->	短代原价 + 全部三方一元限购
	[1] = "defaultSmsYes_smsEnable_oneYuanEnable_netEnable_",
	--默认短代 短代可用 触发一元 未联网										----> 	短代原价 
	[2] = "defaultSmsYes_smsEnable_oneYuanEnable_netDisable_",
	--默认短代 短代可用 未触发一元											----> 	短代原价
	[3] = "defaultSmsYes_smsEnable_oneYuanDisable_",

	--默认短代 短代不可用（限额）三方可用 触发一元							---->	全部三方一元限购
	[4] = "defaultSmsYes_smsLimit_thirdEnable_oneYuanEnable_",
	--默认短代 短代不可用（关停）三方可用 触发一元							---->	全部三方一元限购
	[5] = "defaultSmsYes_smsClose_thirdEnable_oneYuanEnable_",
	--默认短代 短代不可用（没卡）三方可用 触发一元							---->	全部三方一元限购
	[6] = "defaultSmsYes_smsCard_thirdEnable_oneYuanEnable_",
	--默认短代 短代不可用（未初始化）三方可用 触发一元						---->	全部三方一元限购
	[19] = "defaultSmsYes_smsInit_thirdEnable_oneYuanEnable_",

	--默认短代 短代不可用（限额）三方可用 未触发一元						---->	全部三方原价
	[7] = "defaultSmsYes_smsLimit_thirdEnable_oneYuanDisable_",
	--默认短代 短代不可用（关停）三方可用 未触发一元						---->	全部三方原价
	[8] = "defaultSmsYes_smsClose_thirdEnable_oneYuanDisable_",
	--默认短代 短代不可用（没卡）三方可用 未触发一元						---->	全部三方原价
	[9] = "defaultSmsYes_smsCard_thirdEnable_oneYuanDisable_",
	--默认短代 短代不可用（未初始化）三方可用 未触发一元					---->	全部三方原价
	[20] = "defaultSmsYes_smsInit_thirdEnable_oneYuanDisable_",

	--默认短代 短代不可用（限额）三方不可用 								---->	没有合适的支付方式 支付失败
	[10] = "defaultSmsYes_smsLimit_thirdDisable_",
	--默认短代 短代不可用（关停）三方不可用 								---->	没有合适的支付方式 支付失败
	[11] = "defaultSmsYes_smsClose_thirdDisable_",
	--默认短代 短代不可用（没卡）三方不可用 								---->	没有合适的支付方式 支付失败
	[12] = "defaultSmsYes_smsCard_thirdDisable_",
	--默认短代 短代不可用（未初始化）三方不可用 							---->	没有合适的支付方式 支付失败
	[21] = "defaultSmsYes_smsInit_thirdDisable_",

	--默认三方 三方可用 联网												---->	一种优先三方原价
	[13] = "defaultSmsNo_thirdEnable_netEnable_",
	--默认三方 三方可用 未联网 短代可用 									---->	短代原价
	[14] = "defaultSmsNo_thirdEnable_netDisable_smsEnable_",

	--默认三方 三方可用 未联网 短代不可用（限额） 							---->	去联网 支付失败
	[15] = "defaultSmsNo_thirdEnable_netDisable_smsLimit_",
	--默认三方 三方可用 未联网 短代不可用（关停） 							---->	去联网 支付失败
	[16] = "defaultSmsNo_thirdEnable_netDisable_smsClose_",
	--默认三方 三方可用 未联网 短代不可用（没卡） 							---->	去联网 支付失败
	[17] = "defaultSmsNo_thirdEnable_netDisable_smsCard_",
	--默认三方 三方可用 未联网 短代不可用（未初始化） 						---->	去联网 支付失败
	[22] = "defaultSmsNo_thirdEnable_netDisable_smsInit_",

	--默认三方 三方不可用 													----> 	没有合适的支付方式 直接支付失败
	[18] = "defaultSmsNo_thirdDisable_",											
}

function DCAndroidStatus:ctor()
	
end

function DCAndroidStatus:init()
	self.status = ""
end

function DCAndroidStatus:push(judgeType)
	self.status = self.status .. judgeType
end

function DCAndroidStatus:pushWithSmsEnableCheck(disableReason)
	if disableReason == SmsDisableReason.kSmsLimit then
		self:push(DecisionJudgeType.kSmsEnabled.LIMIT_NO)
	elseif disableReason == SmsDisableReason.kSmsClose then 
		self:push(DecisionJudgeType.kSmsEnabled.CLOSE_NO)
	elseif disableReason == SmsDisableReason.kSimCardError then 
		self:push(DecisionJudgeType.kSmsEnabled.CARD_NO)
	elseif disableReason == SmsDisableReason.kSdkStartError then 
		self:push(DecisionJudgeType.kSmsEnabled.INIT_NO)
	elseif disableReason == SmsDisableReason.kPaycodeNotExist then 
		self:push(DecisionJudgeType.kSmsEnabled.NO_PAYCODE_NO)
	else
		self:push(DecisionJudgeType.kSmsEnabled.YES)
	end
end

function DCAndroidStatus:getStatus()
	local finalStatus = 0
	for k,v in pairs(statusTable) do
		if self.status == v then 
			finalStatus = k
		end
	end
	return finalStatus
end

function DCAndroidStatus:create()
	local statusObj = DCAndroidStatus.new()
	statusObj:init()
	return statusObj
end