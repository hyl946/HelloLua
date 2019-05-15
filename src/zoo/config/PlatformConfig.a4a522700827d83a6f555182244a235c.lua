PlatformNameEnum = {
    kIOS        = "apple",
    kWP8        = "windowsphone",
    kHE         = "he",   
    kHE_CLOUDTEST         = "he_cloudtest",   
    kQQ         = "yingyongbao",
    kYYB_CENTER = "yybcenter",
    kYYB_MARKET = "yybmarket",
    kYYB_JINSHAN = "yybjinshan",
    kYYB_BROWSER = "yybbrowser",
    kYYB_ZONE   = "yybzone",
    kYYB_VIDEO  = "yybvideo",
    kYYB_NEWS   = "yybnews",
    kYYB_QQ     = "yybqq",
    kYYB_PC     = "yybpc",
    kYYB_CORE   = "yybcore",
    kYYB_SHOP   = "yybshop",
    KYYB_MANAGER = "yybmanager",
    kYYB_TMS_CENTER     = "yybtmscenter",
    kYYB_TMS_SHOP     = "yybtmsshop",
    k360        = "360",
    k360_WS     = "360_ws",
    kDuoku      = "duoku",
    kWDJ        = "wandoujia",
    kMI         = "mi",
    kMiTalk     = "mitalk",
    kBaiDuApp   = "baiduapp",
    kBaiDuTieBa = "tieba",
    k91         = "91",
    kHao123     = "hao123",
    kOppo       = "oppo",
    kBBK        = "bbk",
    kTYD        = "tianyida",
    kJinShan    = "jinshan",
    kLenovo     = "lenovo",
    kHuaWei     = "huawei",
    kMiPad      = "mipad",
    kCMCCMM     = "cmccmm",
    kCMCCMM_JS  = "cmccmm_js",
    kCMCCMM_ZJ  = "cmccmm_zj",
    kCUCCWO     = "cuccwo",
    kCoolpad    = "coolpad",
    kAnZhi      = "anzhi",
    kUUCun      = "uucun",
    k4399       = "4399",
    kCooou      = "cooou",
    kCMGame     = "cmgame",
    kYouKu      = "youku",
    kJinli      = "jinli",
    kHEMM       = "hemm",
    kJinliPre   = "jinli_pre",
    kLenovoPre  = "lenovo_pre",
    kDoovPre    = "doov_pre",
    kCoolpadPre = "coolpad_pre",
    k189Store   = "189store",
    kLanYue     = "lanyue",
    kLiQu       = "liqu",
    kPaoJiao    = "paojiao",
    k3533       = "3533",
    kWeiYunJiQu = "weiyunjiqu",
    k3GRoad     = "3groad",
    kSj         = "sj",
    kUC         = "uc",
    kLenovoGame = "lenovogame",
    kSina       = "sina",
    kMobileMM   = "mobilemm",
    kAndroidMM  = "androidmm",
    kSpringMM   = "springmm",
    kSogou      = "sogou",
    kSogouYysc  = "sogouyysc",
    kSogouYxdt  = "sogouyxdt",
    kSogouSs    = "sogouss",
    kSogouSrf   = "sogousrf",
    kSogouLlq   = "sogoullq",
    kSogouRC    = "sogourc",
    kLetv       = "letv",
    kVivo       = "vivo",
    kLvAn       = "lvan",
    kHTC        = "htc",
    kMT         = "mt",
    kZY         = "zy",
    kLemon      = "lemon",
    kMZ         = "mz",
    kFeiLiu     = "feiliu",
    k9Bang      = "9bang",
    kDangLe     = "dangle",
    kJJ         = "jj",
    kLeshop     = "leshop",
    kBaidule    = "baidule",
    kSamsung    = "samsung",
    kZm         = "zm",
    kAoruan     = "aoruan",
    kSohu       = "sohu",
    kYiwan      = "yiwan",
    kDK         = "dk",
    kALI        = "ali",
    kBaiduLemon = "baidulemon",
    kBaiduWifi  = "baiduwifi",
    kPP         = "pp",
    kTF         = "tf",
    kWTWDPre    = "wtwd_pre",
    kZTEMINIPre = "zte_mini_pre",
    kZTEPre     = "zte_pre",
    kAsusPre    = "asus_pre",
    kIQiYi      = "iqiyi",
    kIQiYiSpgg  = "iqiyispgg",
    kIQiYiSpgl  = "iqiyispgl",
    kIQiYiSpjc  = "iqiyispjc",
    kALIPre     = "ali_pre",
    k2345       = "2345",
    kHaiXin     = "haixin",
    kNubiya     = "nubiya",
    kZte        = "zte",
    kWechatAndroid = "wechat_android",
    kHewxz      = "hewxz",
    kHE_AD       = "he_ad",
    kHE_AD_TT    = "he_ad_tt",
    kPlayDemo   = "play_demo",
}

PlatformAuthEnum = {
    kGuest  = 0,
    kWeibo  = 1,
    kQQ     = 2,
    kWDJ    = 3,
    kMI     = 4,
    k360    = 5,
    kPhone  = 6,
    kJPQQ   = 7,
    kJPWX   = 8,
    -- kUnionQQ = 9, 后台数据互通专用
    kWechat = 10,
}
function _getPlatformAuthName(loginType)
    local method = "unknown"
    if loginType == PlatformAuthEnum.kGuest then method = "kGuest" end
    if loginType == PlatformAuthEnum.kWeibo then method = "kWeibo" end
    if loginType == PlatformAuthEnum.kQQ then method = "kQQ" end
    if loginType == PlatformAuthEnum.kWDJ then method = "kWDJ" end
    if loginType == PlatformAuthEnum.kMI then method = "kMI" end
    if loginType == PlatformAuthEnum.k360 then method = "k360" end
    if loginType == PlatformAuthEnum.kPhone then method = "kPhone" end
    if loginType == PlatformAuthEnum.kJPQQ then method = "kJPQQ" end
    if loginType == PlatformAuthEnum.kJPWX then method = "kJPWX" end
    if loginType == PlatformAuthEnum.kWechat then method = "kWechat" end
    return method
end

PlatformAuthDetail = {
    [PlatformAuthEnum.kWeibo]   = {
        name="weibo", 
        localization=Localization:getInstance():getText("platform.weibo"),
        },
    [PlatformAuthEnum.kQQ]      = {
        name="qq", 
        localization=Localization:getInstance():getText("platform.qq"),
        },
    [PlatformAuthEnum.kWDJ]     = {
        name="wandoujia", 
        localization=Localization:getInstance():getText("platform.wdj"),
        },
    [PlatformAuthEnum.kMI]      = {
        name="migame", 
        localization=Localization:getInstance():getText("platform.mi"),
        },
    [PlatformAuthEnum.k360]     = {
        name="360", 
        localization=Localization:getInstance():getText("platform.360"),
        },
    [PlatformAuthEnum.kPhone]   = {
        name="phone",
        localization=Localization:getInstance():getText("platform.phone"),
        },
    [PlatformAuthEnum.kJPQQ]   = {
        name="jpqq",
        localization=Localization:getInstance():getText("platform.qq"),
        },
    [PlatformAuthEnum.kJPWX]   = {
        name="jpwx",
        localization=Localization:getInstance():getText("platform.jpwx"),
        },
    [PlatformAuthEnum.kWechat]   = {
        name="wechat",
        localization=Localization:getInstance():getText("platform.wechat"),
        },
}

-- account binding 用
PlatformAuthPriority = {
    [PlatformAuthEnum.kQQ]    = 1,
    [PlatformAuthEnum.k360]   = 2,
    [PlatformAuthEnum.kPhone] = 3,
    [PlatformAuthEnum.kWechat]= 4,
    [PlatformAuthEnum.kWeibo] = 5,
    [PlatformAuthEnum.kWDJ]   = 6,
    [PlatformAuthEnum.kMI]    = 7,
    [PlatformAuthEnum.kJPQQ]  = 8,
    [PlatformAuthEnum.kJPWX]  = 9,
}

-- 登录时显示优先级用
SelectLoginPriority = {
    [PlatformAuthEnum.kQQ]    = 1,
    [PlatformAuthEnum.k360]   = 2,
    [PlatformAuthEnum.kWDJ]   = 3,
    [PlatformAuthEnum.kMI]    = 4,
    [PlatformAuthEnum.kPhone] = 5,
    [PlatformAuthEnum.kWechat]= 6,
    [PlatformAuthEnum.kWeibo] = 7,
    [PlatformAuthEnum.kJPWX]  = 8,
    [PlatformAuthEnum.kJPQQ]  = 9,
}

TelecomOperators = { 
    NO_SIM          = -1, -- 未插卡
    UNKNOWN         = 0, -- 未知
    CHINA_MOBILE    = 1, -- 中国移动
    CHINA_UNICOM    = 2, -- 中国联通
    CHINA_TELECOM   = 3, -- 中国电信
}

PaymentMode = {
    kUnknown = 0, --未知
    kSms = 1, --短代
    kThirdParty = 2, --第3方支付
}

--新加的支付方式 请同步到 http://wiki.happyelements.net/pages/viewpage.action?pageId=20275462 这个文档里
Payments = {
    UNSUPPORT       = 0,
    CHINA_MOBILE    = 1,        -- 移动mm
    CHINA_UNICOM    = 2,
    CHINA_TELECOM   = 3,
    WDJ             = 4,
    QQ              = 5,
    MI              = 6,
    QIHOO           = 7,
    -- MDO             = 8,        -- 已废弃
    MIDAS            = 8,
    CHINA_MOBILE_GAME = 9,      -- 移动游戏基地
    DUOKU             = 10,
    WECHAT          = 11,
    ALIPAY          = 12,
    WO3PAY          = 13,       --联通CUCCWO 3网计费
    VIVO          = 14,         --VIVO的SDK，默认短代。超限额、或无sim卡则使用第三方支付（包括支付宝，财付通，网银和充值卡）
    WIND_MILL       = 15,       --代表风车币支付(打点需求)
    IOS_RMB         = 16,       --代表IOS的RMB支付(打点需求)
    TELECOM3PAY     = 17,       --电信三网 计费
    ALI_QUICK_PAY   = 18,       --支付宝免密支付
    ALI_SIGN_PAY    = 19,
    WECHAT_QUICK_PAY = 20,
    HUAWEI          = 21,       --华为支付
    QQ_WALLET       = 22,       --qq 钱包
    MI_ALIPAY       = 23,       --小米支付宝
    MI_WXPAY        = 24,       --小米微信
    WX_FRIEND       = 25,       --微信代付 和别的支付方式 迥然不同
    QIHOO_WX        = 26,       --360微信
    QIHOO_ALI       = 27,       --360支付宝
    UMPAY           = 28,       --联动优势话费支付
}

WechatLikePayments = {

    Payments.WECHAT,
    Payments.MI_WXPAY,
    Payments.QIHOO_WX,
    Payments.QQ
}


AlipayLikePayments = {

    Payments.ALIPAY,
    Payments.MI_ALIPAY,
    Payments.QIHOO_ALI,
    Payments.HUAWEI,
    Payments.WDJ
}

PlatformShareEnum = {
    kWechat = 1,
    kMiTalk = 2,
    kWeibo = 3,
    k360 = 4,
    kQQ = 5,
    kJPQQ = 6,
    kJPWX = 7,
    kSYS_WECHAT = 8,
    kSYS_QQ = 9,
}

local AndroidPlatformConfigs = {
    kHE = {
        name = PlatformNameEnum.kHE,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY}, -- 1.49 停止使用 Payments.QQ_WALLET
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHE_AD = {
        name = PlatformNameEnum.kHE_AD,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHE_AD_TT = {
        name = PlatformNameEnum.kHE_AD_TT,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHE_CLOUDTEST = {
        name = PlatformNameEnum.kHE_CLOUDTEST,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY}, -- 1.49 停止使用 Payments.QQ_WALLET
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHE_2 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHE_3 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithoutWeibo = {
        name = nil,
        authConfig = PlatformAuthEnum.kQQ,
        paymentConfig = {
            thirdPartyPayment = {Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kPreMM = {
        name = nil,
        authConfig = { PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kDoovPre = {
        name = PlatformNameEnum.kDoovPre,
        authConfig = { PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kPreMM_2 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kCMCCMM = {
        name = PlatformNameEnum.kCMCCMM,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.WECHAT, Payments.ALIPAY },
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kCMCCMM_2 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kQQ = {
        name = PlatformNameEnum.kQQ,
        authConfig = PlatformAuthEnum.kQQ,
        extraLoginAuthConfig = {PlatformAuthEnum.kPhone}, 

        paymentConfig = {
            thirdPartyPayment = {Payments.QQ},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kWDJ = {
        name = PlatformNameEnum.kWDJ,
        authConfig = PlatformAuthEnum.kPhone,
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    k360 = {
        name = PlatformNameEnum.k360,
        authConfig = PlatformAuthEnum.k360,
        paymentConfig = {
            thirdPartyPayment = {Payments.QIHOO_WX, Payments.QIHOO_ALI},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        -- shareConfig = { PlatformShareEnum.kWechat, PlatformShareEnum.k360 }
        shareConfig = {PlatformShareEnum.kWechat}
    },
    k360_WS = {
        name = PlatformNameEnum.k360_WS,
        authConfig = PlatformAuthEnum.k360,
        paymentConfig = {
            thirdPartyPayment = {Payments.QIHOO_WX, Payments.QIHOO_ALI},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME},
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        -- shareConfig = { PlatformShareEnum.kWechat, PlatformShareEnum.k360 }
        shareConfig = {PlatformShareEnum.kWechat}
    },
    kMiPad = {
        name = PlatformNameEnum.kMiPad,
        authConfig = PlatformAuthEnum.kMI,
        paymentConfig = {
            thirdPartyPayment = {Payments.MI_WXPAY, Payments.MI},
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kMiTalk = {
        name = PlatformNameEnum.kMiTalk,
        authConfig = PlatformAuthEnum.kPhone,
        paymentConfig = {
            thirdPartyPayment = {Payments.UNSUPPORT},
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kMiTalk }
    },
    kNoNetWorkMode = {
        name = nil,
        authConfig = PlatformAuthEnum.kGuest,
        paymentConfig = {
            thirdPartyPayment = {Payments.UNSUPPORT},
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kUnsupport }
    },
    kCUCCWO = {
        name = PlatformNameEnum.kCUCCWO,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.WO3PAY },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    k3GRoad = {
        name = PlatformNameEnum.k3GRoad,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kCooou = {
        name = PlatformNameEnum.kCooou,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kCMGame = {
        name = PlatformNameEnum.kCMGame,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithCMGame = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithMDO = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithMDO_2 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT},
            chinaMobilePayment = { Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEMM = {
        name = PlatformNameEnum.kHEMM,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithoutCM = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },

    kHEWithoutMM = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },

    kHEWithoutCT = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithoutCT_2 = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo, PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kOppo = {
        name = PlatformNameEnum.kOppo,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },

        --登录入口可见手机登录, 游戏内其他地方不可见(账号绑定、金银果树), 
        --并且登录入口不能绑定新手机了，只有老手机账户可以登陆

        extraLoginAuthConfig = {PlatformAuthEnum.kPhone}, 
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kUC = {
        name = PlatformNameEnum.kUC,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY },
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kSj = {
        name = PlatformNameEnum.kSj,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },

    kLeshop = {
        name = PlatformNameEnum.kLeshop,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kMI = {
        name = PlatformNameEnum.kMI,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.WECHAT,Payments.MI_ALIPAY, Payments.MI},
            chinaMobilePayment = { Payments.CHINA_MOBILE,Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHEWithout3rdPay = {
        name = nil,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.UNSUPPORT},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kHuaWei = {
        name = PlatformNameEnum.kHuaWei,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.HUAWEI},
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kVivo = {
        name = PlatformNameEnum.kVivo,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = {Payments.VIVO},
            chinaMobilePayment = {Payments.UNSUPPORT},
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT,
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kQQWithoutWeibo = {
        name = nil,
        authConfig = PlatformAuthEnum.kQQ,
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY },
            chinaMobilePayment = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kZTEPre = {
        name = PlatformNameEnum.kZTEPre,
        authConfig = PlatformAuthEnum.kQQ,
        paymentConfig = {
            thirdPartyPayment = {Payments.WECHAT, Payments.ALIPAY },
            chinaMobilePayment = { Payments.CHINA_MOBILE },
            chinaUnicomPayment = Payments.CHINA_UNICOM,
            chinaTelecomPayment = Payments.CHINA_TELECOM
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    k189Store = {
        name = PlatformNameEnum.k189Store,
        authConfig = { PlatformAuthEnum.kWeibo,PlatformAuthEnum.kQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.TELECOM3PAY, Payments.WECHAT, Payments.ALIPAY },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    },
    kWechatAndroid = {
        name = PlatformNameEnum.kWechatAndroid,
        authConfig = { PlatformAuthEnum.kJPWX, PlatformAuthEnum.kJPQQ },
        paymentConfig = {
            thirdPartyPayment = { Payments.MIDAS },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kJPQQ, PlatformShareEnum.kJPWX }
    },
    kPlayDemo = {
        name = PlatformNameEnum.kPlayDemo,
        authConfig = PlatformAuthEnum.kGuest,
        paymentConfig = {
            thirdPartyPayment = {}, -- 1.49 停止使用 Payments.QQ_WALLET
            chinaMobilePayment = Payments.UNSUPPORT,
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = {}
    },
}

-- 派生平台定义, key为派生源头平台的名称, 需要在AndroidPlatformConfigs中预定义
-- 凡带_2,_3的 都是与原本的在三方平台配置上有差异的 如kHE包含三方微信支付宝，而kHE_2只包含微信，kHE_3支持微信+支付宝
local ForkPlatformMap = {
    kHE = { 
        PlatformNameEnum.kCoolpad,
        PlatformNameEnum.kUUCun,
        PlatformNameEnum.kJinShan, 
        PlatformNameEnum.kLetv,
        PlatformNameEnum.kBBK,
        PlatformNameEnum.kHTC,
        PlatformNameEnum.kJinli,
        PlatformNameEnum.kYouKu,
        PlatformNameEnum.kSamsung,
        PlatformNameEnum.kZm,
        PlatformNameEnum.kDangLe,
        PlatformNameEnum.kLemon,
        PlatformNameEnum.kALI,
        PlatformNameEnum.kMZ,
        PlatformNameEnum.kCoolpadPre,
        PlatformNameEnum.kTF,
        PlatformNameEnum.kPP,
        PlatformNameEnum.kSogou,
        PlatformNameEnum.kSogouYysc,
        PlatformNameEnum.kSogouYxdt,
        PlatformNameEnum.kSogouSs,
        PlatformNameEnum.kSogouSrf,
        PlatformNameEnum.kSogouLlq,
        PlatformNameEnum.kSogouRC,
        PlatformNameEnum.kMT,
        PlatformNameEnum.kLenovo, 
        PlatformNameEnum.kLenovoGame,
        PlatformNameEnum.k2345,
        PlatformNameEnum.kHaiXin,
        PlatformNameEnum.kNubiya,
        PlatformNameEnum.kAoruan,
        PlatformNameEnum.kHewxz,
    },
    kHE_3 = { 
        PlatformNameEnum.kAnZhi,
        PlatformNameEnum.kZte,
    },
    kHEWithoutWeibo = {
        PlatformNameEnum.kWTWDPre,
    },
    kPreMM = {  
        -- PlatformNameEnum.kDoovPre,
    },
    
    kPreMM_2 = {
         
        PlatformNameEnum.kDK,
    },
    kCMCCMM = {
        PlatformNameEnum.kMobileMM,
        PlatformNameEnum.kCMCCMM_JS,
        PlatformNameEnum.kCMCCMM_ZJ,
    },
    kCMCCMM_2 = {
        PlatformNameEnum.kSina,
        PlatformNameEnum.kSpringMM,
        PlatformNameEnum.kAndroidMM, 
        PlatformNameEnum.kLvAn,
        PlatformNameEnum.kFeiLiu,
        PlatformNameEnum.k9Bang,
        PlatformNameEnum.kYiwan,
    },
    kHEWithCMGame = {
    },
    kHEWithMDO = {
        PlatformNameEnum.kDuoku,
        PlatformNameEnum.k91,
        PlatformNameEnum.kBaiDuApp,
        PlatformNameEnum.kBaiDuTieBa,
        PlatformNameEnum.kJinliPre,
        PlatformNameEnum.kLenovoPre, 
    },
    kHEWithMDO_2 = {
        PlatformNameEnum.kHao123,
    },
    kHEWithoutCT = {
        PlatformNameEnum.kTYD,
        PlatformNameEnum.k4399,
    },
    kHEWithoutCT_2 = {
    },
    kHEWithoutCM = {
        PlatformNameEnum.kLanYue,
        PlatformNameEnum.kPaoJiao,
        PlatformNameEnum.kLiQu,
        PlatformNameEnum.k3533,
        PlatformNameEnum.kWeiYunJiQu,
    },
    kOppo = {
        PlatformNameEnum.kOppo,
    },
    kHEWithout3rdPay = {
        PlatformNameEnum.kJJ,
        PlatformNameEnum.kIQiYi,
        PlatformNameEnum.kIQiYiSpgg,
        PlatformNameEnum.kIQiYiSpgl,
        PlatformNameEnum.kIQiYiSpjc,
    },
    kQQ = {
        PlatformNameEnum.kYYB_CENTER,
        PlatformNameEnum.kYYB_MARKET,
        PlatformNameEnum.kYYB_JINSHAN,
        PlatformNameEnum.kYYB_BROWSER,
        PlatformNameEnum.kYYB_ZONE,
        PlatformNameEnum.kYYB_VIDEO,
        PlatformNameEnum.kYYB_NEWS,
        PlatformNameEnum.kYYB_QQ,
        PlatformNameEnum.kYYB_PC,
        PlatformNameEnum.kYYB_CORE,
        PlatformNameEnum.kYYB_SHOP,
        PlatformNameEnum.kYYB_TMS_CENTER,
        PlatformNameEnum.kYYB_TMS_SHOP,
        PlatformNameEnum.KYYB_MANAGER,
    },
    kHEWithoutMM ={
        PlatformNameEnum.kBaidule,
        -- PlatformNameEnum.kAoruan,
        PlatformNameEnum.kSohu,
        PlatformNameEnum.kBaiduLemon, --没有百度sdk,只是他们的一个渠道
        PlatformNameEnum.kBaiduWifi, --没有百度sdk,只是他们的一个渠道
    },
    kQQWithoutWeibo = {
        PlatformNameEnum.kZTEMINIPre,
        PlatformNameEnum.kAsusPre,
        PlatformNameEnum.kALIPre,
    }
}

local IOSPlatformConfigs = {
    kIOS = {
        name = PlatformNameEnum.kIOS,
        authConfig = PlatformAuthEnum.kQQ,
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = { PlatformShareEnum.kWechat }
    }
}

local WP8PlatformConfigs = {
    kWP8 = {
        name = PlatformNameEnum.kWP8,
        authConfig = PlatformAuthEnum.kGuest,
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = {}
    }
}

local WIN32PlatformConfigs = {
    kHE = {
        name = PlatformNameEnum.kHE,
        authConfig = PlatformAuthEnum.kGuest,--PlatformAuthEnum.kGuest,
        paymentConfig = {
            thirdPartyPayment = { Payments.UNSUPPORT },
            chinaMobilePayment = { Payments.UNSUPPORT },
            chinaUnicomPayment = Payments.UNSUPPORT,
            chinaTelecomPayment = Payments.UNSUPPORT
        },
        shareConfig = {}
    }
}

local function isPlatformLike(pfList, pfName)
    if not pfList or type(pfList) ~= "table" then return false end
    for i,v in ipairs(HE_LIKE) do
        if androidPlatformName == v then
            return true
        end
    end
end

local function initPlatformConfig()
    if __ANDROID then
        local androidPlatformName = StartupConfig:getInstance():getPlatformName()
        printx( 1 , "  initPlatformConfig  androidPlarformName = " .. tostring(androidPlarformName))
        -- 预装包
        if PrepackageUtil:isPreNoNetWork() then 
            PlatformConfig = AndroidPlatformConfigs.kNoNetWorkMode
            PlatformConfig.name = androidPlatformName
            printx( 1 , "  预装包 platform config name: " .. PlatformConfig.name)
            return;
        end
        -- 预定义平台
        for k, v in pairs(AndroidPlatformConfigs) do
            if androidPlatformName == v.name then
                PlatformConfig = v
                printx( 1 , "  预定义平台 platform config name: " .. PlatformConfig.name)
                return
            end
        end
        -- 派生平台, 仅平台名与原始平台不同, 如果存在其他差异则需要在预定义中直接声明平台
        for srcPlatform, forkPlatforms in pairs(ForkPlatformMap) do
            if table.includes(forkPlatforms, androidPlatformName) then
                PlatformConfig = AndroidPlatformConfigs[srcPlatform]
                PlatformConfig.name = androidPlatformName
                printx( 1 , "  派生平台 platform config name: " .. PlatformConfig.name .. " fork from: " .. srcPlatform)
                return
            end
        end
        printx( 1 , "  缺少的默认HE_LIKE platform config name: " .. tostring(androidPlarformName) )
        -- 缺少的默认HE_LIKE
        PlatformConfig = AndroidPlatformConfigs.kHE
        PlatformConfig.name = androidPlatformName
    elseif __IOS then
        PlatformConfig = IOSPlatformConfigs.kIOS
    elseif __WP8 then
        PlatformConfig = WP8PlatformConfigs.kWP8
    else
        PlatformConfig = WIN32PlatformConfigs.kHE
        -- PlatformConfig = AndroidPlatformConfigs.kPlayDemo
    end
end

initPlatformConfig()


function PlatformConfig:loadPayementConfig()
    require "zoo.payment.logic.PaymentRequire"
    
    for _,v in pairs(self.paymentConfig) do
        if type(v) == "table" then
            for _,payType in ipairs(v) do
                PaymentBase:create(payType)
            end
        elseif v ~= Payments.UNSUPPORT then
            PaymentBase:create(v)
        end
    end
end

-- 添加手机登录配置
function PlatformConfig:setPhonePlatformAuth( ... )
    if __ANDROID and PrepackageUtil:isPreNoNetWork() then 
        return 
    end
    if PlatformConfig:isPlayDemo() then
        return
    end
    if type(self.authConfig) == "table" then
        table.insertIfNotExist(self.authConfig,PlatformAuthEnum.kPhone)
    elseif self.authConfig == PlatformAuthEnum.kGuest then
        self.authConfig = { PlatformAuthEnum.kPhone }
        _G.kDeviceID = UdidUtil:getUdid() --这种情况默认会是游客,的重新获取下
    elseif self.authConfig ~= PlatformAuthEnum.kPhone then
        self.authConfig = { self.authConfig,PlatformAuthEnum.kPhone }
    end
end

function PlatformConfig:addAuthType(auth)
    if __ANDROID and PrepackageUtil:isPreNoNetWork() then 
        return 
    end
    if type(self.authConfig) == "table" then
        table.insertIfNotExist(self.authConfig, auth)
    elseif self.authConfig == PlatformAuthEnum.kGuest then
        self.authConfig = { auth }
        _G.kDeviceID = UdidUtil:getUdid() --这种情况默认会是游客,的重新获取下
    elseif self.authConfig ~= auth then
        self.authConfig = { self.authConfig, auth }
    end 
end

function PlatformConfig:isPlatform(platformName)
    assert(platformName)
    if platformName == PlatformNameEnum.k360 and self.name == PlatformNameEnum.k360_WS then
        return true
    end
    return self.name == platformName
end

function PlatformConfig:isAuthConfig(authConfig)
    assert(authConfig)
    return self.authConfig == authConfig
end

function PlatformConfig:hasAuthConfig(authConfig, considerJP)
    assert(authConfig) 
    if considerJP then 
        --精品包 有时qq登录不可被认为是正常qq登录（目前用于触发绑定时）
        if PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) and authConfig == PlatformAuthEnum.kQQ then 
            return false
        end
    end

    if type(self.authConfig) == "table" then
        for _,v in pairs(self.authConfig) do
            if v == authConfig then 
                return true
            end
        end
        return false
    else
       return self.authConfig == authConfig
    end
end

function PlatformConfig:hasExtraLoginAuthConfig( authConfig )

    if self.extraLoginAuthConfig then
        if type(self.extraLoginAuthConfig) == "table" then
            for _,v in pairs(self.extraLoginAuthConfig) do
                if v == authConfig then 
                    return true
                end
            end
            return false
        else
           return self.extraLoginAuthConfig == authConfig
        end
    else
        return false
    end
end
    
function PlatformConfig:hasLoginAuthConfig( authConfig )
    return self:hasAuthConfig(authConfig) or self:hasExtraLoginAuthConfig(authConfig)
end

function PlatformConfig:isMultipleAuthConfig( ... )
    return type(self.authConfig) == "table" and #self.authConfig > 1
end

function PlatformConfig:isMultipleLoginAuthConfig( ... )
    local counter = 0
    if self.authConfig then
        if type(self.authConfig) == "table" then
            counter = counter + #self.authConfig
        else
            counter = counter + 1
        end
    end

    if self.extraLoginAuthConfig then
        if type(self.extraLoginAuthConfig) == "table" then
            counter = counter + #self.extraLoginAuthConfig
        else
            counter = counter + 1
        end
    end

    return counter > 1
end

function PlatformConfig:getAuthConfigs( ... )
    if type(self.authConfig) == "table" then 
        return self.authConfig
    else
        return { self.authConfig }
    end
end

function PlatformConfig:getExtraLoginAuthConfigs( ... )
    if type(self.extraLoginAuthConfig) == "table" then 
        return self.extraLoginAuthConfig
    else
        return { self.extraLoginAuthConfig }
    end
end

function PlatformConfig:isBaiduPlatform()
    return self:isPlatform(PlatformNameEnum.kDuoku) or self:isPlatform(PlatformNameEnum.k91) or self:isPlatform(PlatformNameEnum.kBaiDuApp) or self:isPlatform(PlatformNameEnum.kHao123) or self:isPlatform(PlatformNameEnum.kBaiDuTieBa)
end

function PlatformConfig:isQQPlatform(pf)
    local qqPlatforms = {
        PlatformNameEnum.kQQ,
        PlatformNameEnum.kYYB_CENTER,
        PlatformNameEnum.kYYB_MARKET,
        PlatformNameEnum.kYYB_MARKET, 
        PlatformNameEnum.kYYB_JINSHAN, 
        PlatformNameEnum.kYYB_BROWSER, 
        PlatformNameEnum.kYYB_ZONE, 
        PlatformNameEnum.kYYB_VIDEO, 
        PlatformNameEnum.kYYB_NEWS,
        PlatformNameEnum.kYYB_QQ,
        PlatformNameEnum.kYYB_PC,
        PlatformNameEnum.kYYB_CORE,
        PlatformNameEnum.kYYB_SHOP,
        PlatformNameEnum.kYYB_TMS_CENTER,
        PlatformNameEnum.kYYB_TMS_SHOP,
        PlatformNameEnum.KYYB_MANAGER,
    }

    local _pf
    if pf then
        _pf = pf
    else
        _pf = self.name
    end 

    return table.includes(qqPlatforms, _pf) ~= nil
end

function PlatformConfig:isJJPlatform( )
    -- body
    return self:isPlatform(PlatformNameEnum.kJJ)
    -- return true
end

function PlatformConfig:isCUCCWOPlatform( )
    -- body
    return self:isPlatform(PlatformNameEnum.kCUCCWO)
    -- return true
end

function PlatformConfig:isCmccmmPlatform()
    if self:isPlatform(PlatformNameEnum.kCMCCMM)
        or self:isPlatform(PlatformNameEnum.kCMCCMM_JS)
        or self:isPlatform(PlatformNameEnum.kCMCCMM_ZJ)
        then 
            return true
    end
    return false 
end

function PlatformConfig:isCMPaymentSwitchable()
    if type(self.paymentConfig.chinaMobilePayment) == "table" 
        and table.includes(self.paymentConfig.chinaMobilePayment, Payments.CHINA_MOBILE)
        and table.includes(self.paymentConfig.chinaMobilePayment, Payments.CHINA_MOBILE_GAME) then
        return true
    end
    return false
end

function PlatformConfig:getPlatformAuthDetail( authorType )
    local authDetail = nil
    if authorType then
        authDetail = PlatformAuthDetail[authorType]
    elseif SnsProxy and SnsProxy:getAuthorizeType() then -- use default authorize type
        authDetail = PlatformAuthDetail[SnsProxy:getAuthorizeType()]
    end
    return authDetail
end

function PlatformConfig:getPlatformAuthByName(name)
    for authType, pCfg in pairs(PlatformAuthDetail) do
        if pCfg.name == name then
            return authType
        end
    end
    return nil
end

function PlatformConfig:getPlatformNameLocalization(authorType)
    if self:isPlatform(PlatformNameEnum.kMiTalk) then
        if (authorType or SnsProxy:getAuthorizeType()) == PlatformAuthEnum.kMI then 
            return Localization.getInstance():getText("platform.mitalk")
        end
    end
    
    local authDetail = self:getPlatformAuthDetail(authorType)
    if authDetail and authDetail.localization then 
        return authDetail.localization 
    else return "" end
end

function PlatformConfig:getPlatformAuthName( authorType )
    local authDetail = self:getPlatformAuthDetail(authorType)
    if authDetail and authDetail.name then 
        return authDetail.name 
    else return nil end
end

function PlatformConfig:setCurrentPayType(payType)
    currentPayType = payType
end

function PlatformConfig:getCurrentPayType()
    return currentPayType
end

--是否支持大额支付
function PlatformConfig:isBigPayPlatform()
    if (PlatformConfig:isPlatform(PlatformNameEnum.kMiPad)
        -- or PlatformConfig:isPlatform(PlatformNameEnum.kWDJ)    
        -- or PlatformConfig:isPlatform(PlatformNameEnum.k360) 
        -- or PlatformConfig:isQQPlatform()
        -- or PlatformConfig:isBaiduPlatform()
        or PlatformConfig:isPlatform(PlatformNameEnum.kVivo)
        ) then
        return true
    end
    return false
end

function PlatformConfig:getLastPlatformAuthName()
    local name = nil
    local authorType = PlatformConfig:getLastPlatformAuthType()
    if authorType then
        local authDetail = PlatformAuthDetail[authorType]
        if authDetail then name = authDetail.name end
    end
    return name
end

function PlatformConfig:getLastPlatformAuthType()
    local authorType = WXJPPackageUtil.getInstance():getLastLoginPF()
    if authorType then 
        return authorType
    else
        local lastLoginUserData = Localhost:readLastLoginUserData()
        if lastLoginUserData and lastLoginUserData.authorType then
            return lastLoginUserData.authorType
        end
    end
    return nil
end

function PlatformConfig:getLoginTypeName()
    local lastLoginUserData = Localhost:readLastLoginUserData()
    local name = "guest"
    if lastLoginUserData and lastLoginUserData.authorType then
        local authDetail = PlatformAuthDetail[lastLoginUserData.authorType]
        if authDetail then name = authDetail.name end
    end
    return name
end

DevicePlatformId = table.const {
    kIOS = 1,
    kAndroid = 2,
    kAndroid_YYB = 3,
    kWP8 = 4
}

function PlatformConfig:getDevicePlatformLocalizeById(id)
    local ret = "未知"
    if id then
        id = tonumber(id)
        if id == DevicePlatformId.kIOS then
            ret = Localization:getInstance():getText("login.panel.warning.platform2")
        elseif id == DevicePlatformId.kWP8 then
            ret = Localization:getInstance():getText("login.panel.warning.platform3")
        elseif id == DevicePlatformId.kAndroid or id == DevicePlatformId.kAndroid_YYB then
            ret = Localization:getInstance():getText("login.panel.warning.platform1")
        end
    end
    return ret
end

function PlatformConfig:getDevicePlatformLocalize()
    local ret = "未知"
    if __IOS then 
        ret = Localization:getInstance():getText("login.panel.warning.platform2")
    elseif __ANDROID then 
        ret = Localization:getInstance():getText("login.panel.warning.platform1")
    elseif __WP8 then 
        ret = Localization:getInstance():getText("login.panel.warning.platform3")
    elseif __WIN32 then 
        ret = "PC" 
    end
    return ret
end


function PlatformConfig:getPaymentConfig(pfName)
    local androidPlatformName = pfName
    -- 预装包
    if PrepackageUtil:isPreNoNetWork() then 
        return AndroidPlatformConfigs.kNoNetWorkMode.paymentConfig
    end
    -- 预定义平台
    for k, v in pairs(AndroidPlatformConfigs) do
        if androidPlatformName == v.name then
            return v.paymentConfig
        end
    end
    -- 派生平台, 仅平台名与原始平台不同, 如果存在其他差异则需要在预定义中直接声明平台
    for srcPlatform, forkPlatforms in pairs(ForkPlatformMap) do
        if table.includes(forkPlatforms, androidPlatformName) then
            return AndroidPlatformConfigs[srcPlatform].paymentConfig
        end
    end
    -- 缺少的默认HE_LIKE
    return AndroidPlatformConfigs.kHE.paymentConfig
end

function PlatformConfig:getPhoneLoginLimitPF()
    --这里是手机登录 限制开放平台 依赖后续查询结果动态加入手机登录配置
    return {
        PlatformNameEnum.k360,
        PlatformNameEnum.k360_WS,
        PlatformNameEnum.kOppo,
        PlatformNameEnum.kQQ,
        PlatformNameEnum.kYYB_CENTER,
        PlatformNameEnum.kYYB_MARKET,
        PlatformNameEnum.kYYB_MARKET, 
        PlatformNameEnum.kYYB_JINSHAN, 
        PlatformNameEnum.kYYB_BROWSER, 
        PlatformNameEnum.kYYB_ZONE, 
        PlatformNameEnum.kYYB_VIDEO, 
        PlatformNameEnum.kYYB_NEWS,
        PlatformNameEnum.kYYB_QQ,
        PlatformNameEnum.kYYB_PC,
        PlatformNameEnum.kYYB_CORE,
        PlatformNameEnum.kYYB_SHOP,
        PlatformNameEnum.kYYB_TMS_CENTER,
        PlatformNameEnum.kYYB_TMS_SHOP,
        PlatformNameEnum.KYYB_MANAGER,
        PlatformNameEnum.kPlayDemo,
    }
end

function PlatformConfig:getPlatfromNameStr(platFormNameEnum, defaultTagStr)
    local keyStr = "platform.name." .. platFormNameEnum
    local nameStr = localize(keyStr)
    if nameStr == keyStr then
        if defaultTagStr == nil then defaultTagStr = "common" end
        nameStr = localize("platform.name." .. defaultTagStr)
    end

    return nameStr
end

function PlatformConfig:isPlayDemo()
	return _G.isPlayDemo
    --return PlatformConfig.name == PlatformNameEnum.kPlayDemo
end

--曾经开启, 但已经在所有平台都被删除的登录方式
RemovedAuthConfigs = {
    PlatformAuthEnum.kWDJ,
    PlatformAuthEnum.kMI
}

function PlatformConfig:isRemovedAuthConfigs( authConfig )
    return table.exist(RemovedAuthConfigs, authConfig)
end

--返回某个平台当前支持的登录方式, 现在不具备通用性，只是为了特殊处理豌豆荚删除登录方式的问题
function PlatformConfig:getOtherPlatformAuthConfig( platform )
    if platform == PlatformNameEnum.kWDJ then
        return {PlatformAuthEnum.kPhone}
    elseif platform == PlatformNameEnum.kMiTalk then
        return {PlatformAuthEnum.kPhone}
    else
        return {}
    end
end

--主动调用sdk logout 兼容OAuthLoginWithRequestProcessor中部分平台在login时不再调用logout的情况
function PlatformConfig:snsLogout(successCB, failCB, cancelCB)
    local authorType = SnsProxy:getAuthorizeType()
    if (PlatformConfig:isQQPlatform() and authorType and authorType == PlatformAuthEnum.kQQ) then
            -- --1.55上特殊处理 1.56后直接在java里改
            -- pcall(function ()
            --     local yybysdk = luajava.bindClass("com.happyelements.android.animal.ysdklibrary.YYBYsdkProxy"):getInstance()
            --     local myInfoField = yybysdk:getClass():getDeclaredField("myInfo")
            --     myInfoField:setAccessible(true)
            --     myInfoField:set(yybysdk, nil)
            -- end)

            local logoutCallback = {
                onSuccess = function(result)
                    if successCB then successCB() end
                end,
                onError = function(errCode, msg) 
                    if failCB then failCB() end
                end,
                onCancel = function()
                    if cancelCB then cancelCB() end
                end
            }
            SnsProxy:logout(logoutCallback)
    else
        if successCB then successCB() end
    end
end

if __ANDROID then
    local function hasPhoneLogin( ... )
        local platformNames = {
            PlatformNameEnum.kJJ,
            PlatformNameEnum.kWechatAndroid,
        }
        if table.includes(platformNames,PlatformConfig.name) or 
            table.includes(PlatformConfig:getPhoneLoginLimitPF(), PlatformConfig.name) then
            return false
        end

        -- if PlatformConfig:isPlatform(PlatformNameEnum.kQQ) or 
        --     PlatformConfig:isPlatform(PlatformNameEnum.kYYB_CENTER) or 
        --     PlatformConfig:isPlatform(PlatformNameEnum.kYYB_MARKET) or
        --     PlatformConfig:isPlatform(PlatformNameEnum.kYYB_BROWSER) or 
        --     PlatformConfig:isPlatform(PlatformNameEnum.KYYB_MANAGER)
        --     then
        --     return true
        -- elseif PlatformConfig:isQQPlatform() then
        --     return false
        -- end

        return true
    end

    if hasPhoneLogin() then
        PlatformConfig:setPhonePlatformAuth()
    end

    local function hasWechatLogin()
        local notSupportPF = {
            PlatformNameEnum.kWechatAndroid, 
            PlatformNameEnum.k360,
            PlatformNameEnum.k360_WS,
            PlatformNameEnum.kMiTalk,
            PlatformNameEnum.kMiPad,
        }
        if table.includes(notSupportPF,PlatformConfig.name) then
            return false
        end
        return true
    end
    if hasWechatLogin() then
        PlatformConfig:addAuthType(PlatformAuthEnum.kWechat)
    end

    if __FORCE_GUEST then
        PlatformConfig.authConfig = {PlatformAuthEnum.kGuest}
    end
end

if __WP8 then
    PlatformConfig:setPhonePlatformAuth()
end

if __IOS then
    PlatformConfig:setPhonePlatformAuth()
    PlatformConfig:addAuthType(PlatformAuthEnum.kWechat)
end

if __WIN32 then
    PlatformConfig:setPhonePlatformAuth()
end


-- 小米设备才有小米支付
if __ANDROID and (PlatformConfig:isPlatform(PlatformNameEnum.kMI) or PlatformConfig:isPlatform(PlatformNameEnum.kMiPad)) then
    pcall(function( ... )
        local MainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
        if not MainActivity:isXiaomi() then
            if PlatformConfig:isPlatform(PlatformNameEnum.kMI) then 
                PlatformConfig.paymentConfig.thirdPartyPayment = { Payments.WECHAT }
            else
                PlatformConfig.paymentConfig.thirdPartyPayment = { Payments.UNSUPPORT }
            end
        end
    end)
end

if __ANDROID and (PlatformConfig:isPlatform(PlatformNameEnum.k360)) then 
    local numVersion = tonumber(_G.bundleVersion:split(".")[2])
    if numVersion == 37 or numVersion == 38 then 
        local status, result = pcall(function ()
            local qihooDelegate = luajava.bindClass("com.happyelements.android.platform.qihoo.QihooPaymentDelegate")
            if qihooDelegate then 
                qihooDelegate:isNewQihooSdk() 
            end
        end)

        if status then 
            PlatformConfig.paymentConfig.thirdPartyPayment = { Payments.QIHOO_WX, Payments.QIHOO_ALI }
        else
            PlatformConfig.paymentConfig.thirdPartyPayment = { Payments.QIHOO }
        end
    end
end

--1.41起 android 4.0.3(api15)以下屏蔽支付宝和微信支付
if __ANDROID then 
    local androidSDKVersion = MetaInfo:getInstance():getSdk()
    if androidSDKVersion and type(androidSDKVersion) == "number" and androidSDKVersion <= 15 then 
        local filterPayment = {Payments.WECHAT, Payments.ALIPAY, Payments.QIHOO_WX, Payments.QIHOO_ALI, Payments.QIHOO, 
                                Payments.QQ, Payments.MI_WXPAY, Payments.MI_ALIPAY}
        local newThirdPayment = {}
        for i,v in ipairs(PlatformConfig.paymentConfig.thirdPartyPayment) do
            if not table.includes(filterPayment, v) then 
                table.insert(newThirdPayment, v)
            end
        end
        if #newThirdPayment == 0 then 
           newThirdPayment = {Payments.UNSUPPORT}
        end
        PlatformConfig.paymentConfig.thirdPartyPayment = newThirdPayment
    end
end
