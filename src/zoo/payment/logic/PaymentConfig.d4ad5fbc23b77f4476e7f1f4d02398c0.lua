local PaymentConfigs = {
    [Payments.UNSUPPORT] = {
        name = "UNSUPPORT",
        mode = "kUnknown",
        productName = "",
        iconName = nil,         --设置面板上的icon
        iconTip = nil,          --与设置面板上的icon相对应的tip
        serverCheck = false,
        delegate = "",
        payLevel = PaymentLevel.kLvNone,
    },
    [Payments.CHINA_MOBILE] = {
        name = "CHINA_MOBILE",
        mode = "kSms",
        productName = "ingame",
        iconName = 'china_mobile_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        operator = "CHINA_MOBILE",
        serverCheck = true, --ingame check
        delegate = "com.happyelements.android.operatorpayment.iap.IAPPayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.CHINA_UNICOM] = {
        name = "CHINA_UNICOM",
        mode = "kSms",
        productName = "ingame",
        iconName = 'china_union_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        operator = "CHINA_UNICOM",
        serverCheck = true,--ingame check
        delegate = "com.happyelements.android.operatorpayment.uni.UniPayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.CHINA_TELECOM] = {
        name = "CHINA_TELECOM",
        mode = "kSms",
        productName = "ingame",
        iconName = 'china_telecom_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        operator = "CHINA_TELECOM",
        serverCheck = true,--ingame check
        delegate = "com.happyelements.android.operatorpayment.telecom.TelecomPayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.WDJ] = {
        name = "WDJ",
        mode = "kThirdParty",
        productName = "wandoujia_3",
        iconName = 'wdj_pay_icon',
        iconTip = 'game.setting.panel.pay.wdj.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.platform.wandoujia.WandoujiaPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.QQ] = {
        name = "QQ",
        mode = "kThirdParty",
        productName = "msdk_3",
        iconName = 'qqwallet_pay_icon', --qq_pay_icon
        iconTip = 'game.setting.panel.pay.tencent.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.platform.tencent.YYBMidasPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.MI] = {
        name = "MI",
        mode = "kThirdParty",
        productName = "mi_3",
        iconName = 'mi_pay_icon',
        iconTip = 'game.setting.panel.pay.mi.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.platform.xiaomi.MiGamePaymentDelegate",
        payLevel = PaymentLevel.kLvTwo,
    },
    [Payments.QIHOO] = {
        name = "QIHOO",
        mode = "kThirdParty",
        productName = "qihoo_3",
        iconName = '360_pay_icon',
        iconTip = 'game.setting.panel.pay.360.open.tip',
        serverCheck = true, --third check
        delegate = "com.happyelements.android.platform.qihoo.QihooPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    -- [Payments.MDO] = {
    --     name = "MDO",
    --     mode = "kSms",
    --     productName = "ingame",
    --     operator = "CHINA_MOBILE",
    --     serverCheck = true, --ingame check
    --     deprecated = true,
    --     delegate = "com.happyelements.android.operatorpayment.chinamobile.MdoPaymentDelegate",
    --     payLevel = PaymentLevel.kLvOne,
    -- },
    [Payments.CHINA_MOBILE_GAME] = {
        name = "CHINA_MOBILE_GAME",
        mode = "kSms",
        productName = "ingame",
        iconName = 'china_mobile_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        operator = "CHINA_MOBILE",
        serverCheck = true, --ingame check
        delegate = "com.happyelements.android.operatorpayment.cmgame.CMGamePayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.DUOKU] = {
        name = "DUOKU",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = false,
        deprecated = true,
        delegate = "com.happyelements.hellolua.duoku.DuokuPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.WECHAT] = {
        name = "WECHAT",
        mode = "kThirdParty",
        productName = "wechat_3",
        iconName = 'wechat_pay_icon',
        iconTip = 'game.setting.panel.pay.wechat.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.wechat.WechatPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
        subPayments = {
            Payments.WECHAT_QUICK_PAY,
        },
    },
    [Payments.ALIPAY] = {
        name = "ALIPAY",
        mode = "kThirdParty",
        productName = "alipay_3",
        iconName = 'ali_pay_icon',
        iconTip = 'game.setting.panel.pay.alipay.open.tip',
        serverCheck = true,
        delegate = "com.happyelements.android.alipay.AliPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
        subPayments = {
            Payments.ALI_SIGN_PAY,
            Payments.ALI_QUICK_PAY,
        },
    },
    [Payments.WO3PAY] = {
        name = "WO3PAY",
        mode = "kThirdParty",
        productName = "ingame",
        iconName = 'cuccwo_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        serverCheck = true, --ingame check
        delegate = "com.happyelements.android.operatorpayment.uni.UniMultiPayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.VIVO] = {
        name = "VIVO",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = false,
        deprecated = true,
        delegate = "com.happyelements.android.vivosdk.VivoPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.WIND_MILL] = {
        name = "WIND_MILL",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = false,
        deprecated = true,
        delegate = "",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.IOS_RMB] = {
        name = "IOS_RMB",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = false,
        deprecated = true,
        delegate = "",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.TELECOM3PAY] = {
        name = "TELECOM3PAY",
        mode = "kThirdParty",
        productName = "ingame",
        iconName = 'cuccwo_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        serverCheck = true, --ingame check
        delegate = "com.happyelements.android.operatorpayment.telecom.TelecomPayment",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.ALI_QUICK_PAY] = {
        name = "ALI_QUICK_PAY",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = true,
        isSubPayment = true,
        isNoSDK = true, --不使用SDK支付
        delegate = "",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.ALI_SIGN_PAY] = {
        name = "ALI_SIGN_PAY",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = true, --third check
        isSubPayment = true,
        delegate = "",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.WECHAT_QUICK_PAY] = {
        name = "WECHAT_QUICK_PAY",
        mode = "kThirdParty",
        productName = "",
        iconName = nil,
        iconTip = nil,
        serverCheck = true,
        isSubPayment = true,
        isNoSDK = true,
        delegate = "",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.HUAWEI] = {
        name = "HUAWEI",
        mode = "kThirdParty",
        productName = "huawei_3",
        iconName = 'huawei_pay_icon',
        iconTip = 'game.setting.panel.pay.huawei.open.tip',
        serverCheck = true, --third check
        delegate = "com.happyelements.android.platform.huawei.HuaweiPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.QQ_WALLET] = {
        name = "QQ_WALLET",
        mode = "kThirdParty",
        productName = "qqwallet_3",
        iconName = 'qqwallet_pay_icon',
        iconTip = 'game.setting.panel.pay.qqwallet.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.qq.QQWalletPaymentDelegate",
        payLevel = PaymentLevel.kLvTwo,
    },
    [Payments.MI_ALIPAY] = {
        name = "MI_ALIPAY",
        mode = "kThirdParty",
        productName = "mialipay_3",
        iconName = 'ali_pay_icon',
        iconTip = 'game.setting.panel.pay.alipay.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.mi.MIAlipayDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.MI_WXPAY] = {
        name = "MI_WXPAY",
        mode = "kThirdParty",
        productName = "miwxpay_3",
        iconName = 'wechat_pay_icon',
        iconTip = 'game.setting.panel.pay.wechat.open.tip',
        serverCheck = false,
        delegate = "com.happyelements.android.mi.MIWxpayDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.QIHOO_WX] = {
        name = "QIHOO_WX",
        mode = "kThirdParty",
        productName = "qihoo_wx_3",
        iconName = 'wechat_pay_icon',
        iconTip = 'game.setting.panel.pay.wechat.open.tip',
        serverCheck = true, --third check
        delegate = "com.happyelements.android.platform.qihoo.QihooPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.QIHOO_ALI] = {
        name = "QIHOO_ALI",
        mode = "kThirdParty",
        productName = "qihoo_ali_3",
        iconName = 'ali_pay_icon',
        iconTip = 'game.setting.panel.pay.alipay.open.tip',
        serverCheck = true, --third check
        delegate = "com.happyelements.android.platform.qihoo.QihooPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.UMPAY] = {
        name = "UMPAY",
        mode = "kSms",
        productName = "ingame",
        iconName = 'china_mobile_pay_icon',
        iconTip = 'game.setting.panel.pay.close.tip',
        operator = "CHINA_MOBILE",
        serverCheck = true, --third check
        delegate = nil,
        payLevel = PaymentLevel.kLvOne,
    },
    [Payments.MIDAS] = {
        name = "MIDAS",
        mode = "kThirdParty",
        productName = "msdk_3",
        iconName = 'qqwallet_pay_icon',
        iconTip = 'game.setting.panel.pay.jp_msdk.open.tip',
        serverCheck = false,
        delegate = "com.tencent.tmgp.AndroidAnimal.midas.JPMidasPaymentDelegate",
        payLevel = PaymentLevel.kLvOne,
    },
}

return PaymentConfigs