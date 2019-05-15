IconBtnConfig = class()

SHOWDEBUGLINE = false

MAX_LEFT_ICON_COUNT = 7
MAX_RIGHT_ICON_COUNT = 6

-- 这里配置的是按钮初始的状态
-- always hide表示的是按钮从来不会进入左右任何一边
IconButtonBasePos	= {
	LEFT	= 1,
	RIGHT	= 2,
	BOTTOM	= 3, 
	-- 一直隐藏在+号
	ALWAYS_HIDE = 4, 
}


ShowHideOptions = {
    -- 如果本身是显示的，就显示，本身是隐藏就继续隐藏
    -- 通过showPriority>>99控制是不是一直显示
    -- 理论上需求里面不会存在本来隐藏，功能结束后却显示的情况
    DO_NOTHING = 1,
    -- 不管本身是怎样，功能结束后都隐藏
    HIDE = 2,
    -- 结束后消失
    REMOVE = 3,
}

IconBtnShowState = {
    HIDE_N_FOLD = 1,
    ON_HOMESCENE = 2,
    NOT_EXIST = 3,
}

local counter = 0
function NewManagedIconBtnId()
	counter = counter + 1
	return counter
end

ManagedIconBtns = {
    FRIENDS = NewManagedIconBtnId(),
    CDKEY   = NewManagedIconBtnId(),
    BAG     = NewManagedIconBtnId(),
    WEEKLY  = NewManagedIconBtnId(),
    RANK_RACE  = NewManagedIconBtnId(),
    MARK    = NewManagedIconBtnId(),
    ACT_CENTER = NewManagedIconBtnId(),
    LADYBUG = NewManagedIconBtnId(),
    NEW_LADYBUG = NewManagedIconBtnId(),
    MESSAGE = NewManagedIconBtnId(),
    FAQ 	= NewManagedIconBtnId(),
    FRUIT 	= NewManagedIconBtnId(),
    MARKET  = NewManagedIconBtnId(),
    ONEYUANSHOP = NewManagedIconBtnId(),
    REAL_NAME = NewManagedIconBtnId(),
    BIND_ACCOUNT = NewManagedIconBtnId(),
    WDJ_REMOVE = NewManagedIconBtnId(),
    MITALK_REMOVE = NewManagedIconBtnId(),
    STAR_REWARD = NewManagedIconBtnId(),
    WXJP_HUB = NewManagedIconBtnId(),
    WXJP_GROUP = NewManagedIconBtnId(),
    MONTH_PAY_TEST = NewManagedIconBtnId(),
	ASKFORHELP = NewManagedIconBtnId(),
	STAR_BANK = NewManagedIconBtnId(),
	OPPO_LAUNCH = NewManagedIconBtnId(),
	QQ_FORUM = NewManagedIconBtnId(),
	OPPO_FORUM = NewManagedIconBtnId(),
	ACHIEVE = NewManagedIconBtnId(),
	XF_PREHEAT = NewManagedIconBtnId(),
	USER_CALLBACK = NewManagedIconBtnId(),

    GIFT_PACK_DISCOUNT = NewManagedIconBtnId(),
    GIFT_PACK_YOUHUI = NewManagedIconBtnId(),

    MAU_NUMBER_ONE = NewManagedIconBtnId(),
}


-- indexKey: 没有引用的情况下，尝试用indexKey来获得引用
BtnShowHideConf = {}

for i=1,4 do
    ManagedIconBtns["TEST_L_"..i] = NewManagedIconBtnId()
    BtnShowHideConf[ManagedIconBtns["TEST_L_"..i]] = {
        indexKey = 'test_btn_l'..i,
        showPriority = 99.9, 
        homeSceneRegion = IconButtonBasePos.LEFT,  
        showHideOption = ShowHideOptions.DO_NOTHING,
    }

    ManagedIconBtns["TEST_R_"..i] = NewManagedIconBtnId()
    BtnShowHideConf[ManagedIconBtns["TEST_R_"..i]] = {
        indexKey = 'test_btn_r_'..i,
        showPriority = 99.9, 
        homeSceneRegion = IconButtonBasePos.RIGHT,  
        showHideOption = ShowHideOptions.DO_NOTHING,
    }
end

if FriendRecommendManager:friendsButtonOutSide() then 
	BtnShowHideConf[ManagedIconBtns.FRIENDS] = 
	{
	    indexKey = 'friends_btn',
	    showPriority = 99.1, 
	    homeSceneRegion = IconButtonBasePos.BOTTOM,  
	    showHideOption = ShowHideOptions.DO_NOTHING,
	}
else
	BtnShowHideConf[ManagedIconBtns.FRIENDS] = 
	{
	    indexKey = 'friends_btn',
	    showPriority = 99.6, -- 强制收起
	    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE, 
	    showHideOption = ShowHideOptions.DO_NOTHING,
	}
end
BtnShowHideConf[ManagedIconBtns.CDKEY] = 
{
    indexKey = 'cdkey_btn',
    showPriority = 99.5, -- 强制收起
    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE,   
    showHideOption = ShowHideOptions.DO_NOTHING,
}
BtnShowHideConf[ManagedIconBtns.BAG] = 
{
    indexKey = 'bag_btn',
    showPriority = 99.7, -- 强制收起
    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE, 
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.OPPO_LAUNCH] = 
{
    indexKey = 'oppo_launch_btn',
    showPriority = 97, -- 强制收起
    homeSceneRegion = IconButtonBasePos.LEFT, 
    showHideOption = ShowHideOptions.REMOVE,
}

BtnShowHideConf[ManagedIconBtns.WEEKLY] =
{
    indexKey = 'weekly_btn',
    showPriority = 97,
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.RANK_RACE] =
{
    indexKey = 'rank_race_btn',
    showPriority = 99.9,
    homeSceneRegion = IconButtonBasePos.RIGHT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.MARK] =
{
    indexKey = 'mark_btn',
    showPriority = 99.3, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.HIDE,
}

BtnShowHideConf[ManagedIconBtns.USER_CALLBACK] =
{
    indexKey = 'user_callback',
    showPriority = 99, 
    homeSceneRegion = IconButtonBasePos.RIGHT,  
    showHideOption = ShowHideOptions.HIDE,
}
BtnShowHideConf[ManagedIconBtns.ACT_CENTER] =
{
    indexKey = 'act_center_btn',
    showPriority = 95, 
    homeSceneRegion = IconButtonBasePos.RIGHT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}
BtnShowHideConf[ManagedIconBtns.LADYBUG] =
{
    indexKey = 'ladybug_btn',
    showPriority = 98.1, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.REMOVE,
}

BtnShowHideConf[ManagedIconBtns.NEW_LADYBUG] =
{
    indexKey = 'new_ladybug_btn',
    showPriority = 98, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.REMOVE,
}

BtnShowHideConf[ManagedIconBtns.MESSAGE] =
{
    indexKey = 'message_btn',
    showPriority = 99.4, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.REMOVE,
}
BtnShowHideConf[ManagedIconBtns.FRUIT] = 
{
	indexKey = 'fruit_btn',
    showPriority = 99.2, 
    homeSceneRegion = IconButtonBasePos.BOTTOM,  
    showHideOption = ShowHideOptions.HIDE,
}
BtnShowHideConf[ManagedIconBtns.FAQ] = 
{
	indexKey = 'faq_btn',
    showPriority = 99.1, 
    homeSceneRegion = IconButtonBasePos.BOTTOM,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}
BtnShowHideConf[ManagedIconBtns.MARKET] = 
{
	indexKey = 'market_btn',
    showPriority = 99.8, 
    homeSceneRegion = IconButtonBasePos.BOTTOM,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.ONEYUANSHOP] = 
{
	indexKey = 'oneyuanshop_btn',
    showPriority = 92, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.REAL_NAME] = 
{
	indexKey = 'real_name_btn',
    showPriority = 94.1, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.WDJ_REMOVE] = 
{
	indexKey = 'wdj_remove_btn',
    showPriority = 98.9, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.MITALK_REMOVE] = 
{
	indexKey = 'mitalk_remove_btn',
    showPriority = 98.9, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.BIND_ACCOUNT] = 
{
    indexKey = 'bind_account_btn',
    showPriority = 94, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.STAR_REWARD] = 
{
    indexKey = 'star_reward_btn',
    showPriority = 99.6, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.WXJP_HUB] = 
{
    indexKey = 'wxjp_hub_btn',
    showPriority = 99.51, -- 强制收起
    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE,   
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.ASKFORHELP] =
{
    indexKey = 'ask_for_help_btn',
    showPriority = 9999,
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.WXJP_GROUP] = 
{
    indexKey = 'wxjp_group_btn',
    showPriority = 99.52, -- 强制收起
    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE,   
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.MONTH_PAY_TEST] = 
{
    indexKey = 'month_pay_test',
    showPriority = 99.19, -- 强制收起
    homeSceneRegion = IconButtonBasePos.RIGHT,   
    showHideOption = ShowHideOptions.HIDE,
}

BtnShowHideConf[ManagedIconBtns.STAR_BANK] = 
{
    indexKey = 'star_bank',
    showPriority = 96.5, 
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.QQ_FORUM] = 
{
    indexKey = 'qq_forum',
    showPriority = 99.1, 
    homeSceneRegion = IconButtonBasePos.BOTTOM,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.OPPO_FORUM] = 
{
    indexKey = 'oppo_forum',
    showPriority = 99.1, 
    homeSceneRegion = IconButtonBasePos.BOTTOM,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.ACHIEVE] =
{
    indexKey = 'achieve_btn',
    showPriority = 95.1, 
    homeSceneRegion = IconButtonBasePos.ALWAYS_HIDE,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.XF_PREHEAT] =
{
    indexKey = 'XF_PREHEAT',
    showPriority = 999-0.01,
    homeSceneRegion = IconButtonBasePos.LEFT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.GIFT_PACK_DISCOUNT] = 
{
    indexKey = 'giftpack_discount_btn',
    showPriority = 96.1, -- 强制收起
    homeSceneRegion = IconButtonBasePos.LEFT, 
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.GIFT_PACK_YOUHUI] = 
{
    indexKey = 'giftpack_youhui_btn',
    showPriority = 96, -- 强制收起
    homeSceneRegion = IconButtonBasePos.LEFT, 
    showHideOption = ShowHideOptions.DO_NOTHING,
}

BtnShowHideConf[ManagedIconBtns.MAU_NUMBER_ONE] =
{
    indexKey = 'mau_number_one_btn',
    showPriority = 99.8,
    homeSceneRegion = IconButtonBasePos.RIGHT,  
    showHideOption = ShowHideOptions.DO_NOTHING,
}