local _PLATFORM = 1 --【1】安卓【2】苹果【3】Win32
local _maxLevelId = 2000
local _top15 = _maxLevelId - 14
local _top60 = _maxLevelId - 59
local _nottop = _maxLevelId - 60
local _last60Pay47 = 48
local _last60Pay240 = 241



local example = {
	mockData = {
		uid = "50093",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 				--玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配和topLevel一样，触发刷星fuuu才配成和topLevel不一样
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				--难度调整分组，表示A12
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},

		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138", --活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = 2040,					--活跃标签激活时的topLevelId		
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 1, ds = 1},
}




local AdjustConfig = {
["levelDiff_A9_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A9_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A9_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A9_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A9_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A9_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A9_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A9_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A9_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A9_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A9_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A9_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A9_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A9_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A9_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A9_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A9_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A9_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A9_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A9_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A9_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A9_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A9_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A9_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A9_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A9_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A9_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A9_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},


















["levelDiff_None_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_None_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_None_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_None_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_None_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_None_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_None_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】  非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_None_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】  非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_None_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】  非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_None_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】  非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_None_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】  非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_None_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】  非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_None_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】  非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_None_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】  非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_None_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】  非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_None_nottop_pay_lost_1"] = {
		--（玩家等级≤满级-60】  付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_nottop_pay_lost_4"] = {
		--（玩家等级≤满级-60】  付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
	["levelDiff_None_nottop_pay_tag3_3"] = {
		--（玩家等级≤满级-60】  付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_top60_nopay_1"] = {
		--（满级-60，满级】  非付费用户，空白对照组    用例关键字段：diffTag，activationTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_top60_nopay_2"] = {
		--（满级-60，满级】  非付费用户，空白对照组    用例关键字段：diffTag，activationTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_top60_nopay_3"] = {
		--（满级-60，满级】  非付费用户，空白对照组    用例关键字段：diffTag，activationTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_top60_nopay_4"] = {
		--（满级-60，满级】  非付费用户，空白对照组    用例关键字段：diffTag，activationTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_None_top60_pay_1"] = {
		--（满级-60，满级】  非付费用户，空白对照组    用例关键字段：diffTag，activationTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},























["levelDiff_A12_pay47_1"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A12_pay47_2"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A12_pay47_3"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_pay47_3"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 92,							--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_pay47_4"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 91,							--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},






















["levelDiff_A13_pay47_1"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_pay47_2"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_pay47_3"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_pay47_4"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_pay47_5"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_pay47_6"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 4,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_pay47_7"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 5,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 4,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},





























["levelDiff_A14_pay47_1"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A14_pay47_2"] = {
		--60天付费大于47      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},





























["levelDiff_A15_pay240_1"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},






































["levelDiff_A16_pay240_1"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_pay240_2"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			    --玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_pay240_3"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_pay240_4"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_pay240_5"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_pay240_6"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 4,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_pay240_7"] = {
		--60天付费大于240      用例关键字段：isPayUser，last60DayPayAmount, todayPlayCount, diffTag, failCount, activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 5,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 4,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagToplevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},





























["levelDiff_A10_nottop_pay_fuuu_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_nottop_pay_fuuu_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_nottop_pay_fuuu_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A10_nottop_pay_fuuu_4"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_nottop_pay_nofuuu_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_nottop_pay_nofuuu_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_pay_fuuu_1"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_pay_fuuu_2"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_pay_fuuu_3"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A10_top60_pay_fuuu_4"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_pay_nofuuu_1"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_pay_nofuuu_2"] = {
		--（满级-60，满级-15】 付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_nopay_fuuu_1"] = {
		--（满级-60，满级-15】 非付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_nopay_fuuu_2"] = {
		--（满级-60，满级-15】 非付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_nopay_fuuu_3"] = {
		--（满级-60，满级-15】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A10_top60_nopay_fuuu_4"] = {
		--（满级-60，满级-15】 非付费用户 		用例关键字段：isPayUser, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 0,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_1"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_2"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_3"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_4"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_5"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_7"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A10_top60_nopay_nofuuu_lost_8"] = {
		--（满级-60，满级-15】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top60_nopay_nofuuu_tag1_1"] = {
		--（满级-60，满级-15】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A10_top60_nopay_nofuuu_tag2_1"] = {
		--（满级-60，满级-15】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top60_nopay_nofuuu_tag2_2"] = {
		--（满级-60，满级-15】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top60_nopay_nofuuu_tag2_3"] = {
		--（满级-60，满级-15】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A10_top60_nopay_nofuuu_tag3_2"] = {
		--（满级-60，满级-15】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A10_top60_nopay_nofuuu_tag3_3"] = {
		--（满级-60，满级-15】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top60_nopay_nofuuu_tag4"] = {
		--（满级-60，满级-15】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A10_top60_nopay_nofuuu_tag5"] = {
		--（满级-60，满级-15】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A10_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A10_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A10_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A10_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A10_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A10_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A10_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A10_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A10_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A10_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 12,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A10_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A10_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 10,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},































["farmStar_1"] = {
		--刷星开fuuu 	用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop-1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 1, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = {mode = 4, ds = 1},
	},
["farmStar_2"] = {
		--刷星开fuuu 	用例关键字段：activationTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop-1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 3, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = {mode = 4, ds = 1},
	},
["farmStar_3"] = {
		--刷星开fuuu 	用例关键字段：levelId,  isPayUser
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = 1,			        --当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 3, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = {mode = 4, ds = 1},
	},
["farmStar_4"] = {
		--刷星开fuuu 	topLevel
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60 + 15, 		--玩家最高关卡
		levelId = _top60 + 14,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 1, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _top60,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = {mode = 4, ds = 1},
	},
["farmStar_unactive_1"] = {
		--刷星开fuuu,不满足条件不触发 	用例关键字段：userTotalStar，totalStar
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop-1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 1, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4941,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = nil,
	},

["farmStar_unactive_2"] = {
		--刷星开fuuu,不满足条件不触发 	用例关键字段：userGroupInfo
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop - 1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 1, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = false,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = nil,
	},
["farmStar_unactive_3"] = {
		--刷星开fuuu，读不到关卡数据不触发  	   用例关键字段：hasLevelTargetProgressData
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop-1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 3, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = false
	},
	result = nil,
	},
["farmStar_unactive_4"] = {
		--刷星开fuuu，卡区也不触发   	用例关键字段：levelId,  isPayUser
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,			    --当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 3, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = nil,
	},
["farmStar_unactive_5"] = {
		--刷星开fuuu，代打不触发   	用例关键字段：askForHelpIsInMode
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop-1,			--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 1, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = true,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
		hasLevelTargetProgressData = true
	},
	result = nil,
	},

["AI_1"] = {
		--AI触发调整 	用例关键字段：levelId,  isPayUser
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,			    --当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = true,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）3
		seedFromAIServer = {seed=1,   colorProbs={1}},

		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 5, ds = 1},
	},
["AI_2"] = {
		--AI触发调整 	用例关键字段：seedFromAIServer
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,			    --当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = true,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = None,				--难度调整分组，选none对照组是因为这组容易触发颜色干预而非fuuu
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4940,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）3
		seedFromAIServer = {seed=1000,   colorProbs={1}},

		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 5, ds = 1},
	},

["AI_activateOther_1"] = {
		-- AI触发调整，不满足条件，触发回流活动    用例关键字段：seedFromAIServer，diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = true,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 0,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		seedFromAIServer = {seed=-2,   colorProbs=nil},
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["AI_activateOther_2"] = {
		--AI触发调整，不满足条件，触发难度调整 	   用例关键字段：seed，failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = true,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		seedFromAIServer = {seed=-1,   colorProbs=nil},
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},



















["return_1"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 0,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["return_2"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-19,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["return_3"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-20,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["return_4"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-19,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["return_5"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-39,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["return_6"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-40,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["return_7"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-54,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["return_8"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 3,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-39,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["return_9"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 3,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-54,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["return_10"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 3,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-55,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["return_11"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 3,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-69,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["return_12"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 4,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-70,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
["return_13"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 4,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-79,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
["return_13"] = {
		--回流用户 用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 5,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-69,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
["return_unactivate_1"] = {
		--回流用户，调整超关卡范围不触发     用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 4,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-80,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["return_unactivate_2"] = {
		--回流用户，调整超时间范围不触发       用例关键字段：diffTag,topLevel,activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 5,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-79,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},

["return_unactivate_3"] = {
		--回流用户，头部30关不触发回流策略     用例关键字段：topLevel, diffTag, topLevel, activationTagTopLevelId，today，totalDays
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _maxLevelId-14, 		--玩家最高关卡
		levelId = _maxLevelId-14,		--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 0,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["return_reset_1"] = {
		--回流用户，往期回流数据重置掉    用例关键字段：activationTagStartTime， 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 9,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 3,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 2,								--活跃标签的原始值
		fixedActivationTag = 2,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1552879294731,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},


















---------------------------------------------------------------------------------------------------------------------------------------
------以下是其他分组走A9组策略的情况
---------------------------------------------------------------------------------------------------------------------------------------


------------------- A17使用A9策略的部分   标签计算规则不同，触发逻辑相同 -------------------
["levelDiff_A17_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A17_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A17_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A17_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A17_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A17_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A17_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A17_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A17_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A17_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A17_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A17_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A17_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A17_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A17_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A17_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A17_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A17_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A17_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A17_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A17_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A17_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A17_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A17_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A17_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A17_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A17_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 99999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A17_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = 9999,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 17,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},


















------------------- A16使用A9策略的部分   涉及付费的用例金额改为__last60Pay240，其他逻辑与A9相同 -------------------
["levelDiff_A16_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A16_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A16_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A16_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A16_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A16_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A16_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A16_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A16_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A16_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A16_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A16_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A16_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A16_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A16_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A16_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A16_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A16_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A16_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A16_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A16_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A16_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A16_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A16_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A16_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A16_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A16_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A16_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 16,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},



























------------------- A15使用A9策略的部分，   涉及付费的用例金额改为__last60Pay240，其他逻辑与A9相同 -------------------
["levelDiff_A15_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A15_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A15_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A15_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A15_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A15_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A15_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A15_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A15_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A15_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A15_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A15_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A15_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A15_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A15_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A15_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A15_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A15_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A15_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A15_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A15_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A15_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A15_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A15_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A15_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A15_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A15_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A15_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay240 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 15,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},


































------------------- A14使用A9策略的部分，   涉及付费的用例金额改为_last60Pay47，其他逻辑与A9相同 -------------------
["levelDiff_A14_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A14_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A14_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A14_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A14_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A14_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A14_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A14_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A14_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A14_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A14_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A14_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A14_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A14_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A14_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A14_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A14_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A14_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A14_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A14_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A14_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A14_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A14_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A14_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A14_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A14_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A14_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A14_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 14,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},





























------------------- A13使用A9策略的部分，   涉及付费的用例金额改为_last60Pay47，其他逻辑与A9相同 -------------------
["levelDiff_A13_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A13_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A13_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A13_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A13_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A13_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A13_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A13_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A13_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A13_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A13_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A13_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A13_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A13_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A13_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A13_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A13_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A13_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A13_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A13_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A13_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A13_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A13_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A13_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A13_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A13_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A13_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A13_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 13,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
























------------------- A12使用A9策略的部分，   涉及付费的用例金额改为_last60Pay47，其他逻辑与A9相同 -------------------
["levelDiff_A12_nottop_nopay_tag1_1"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
["levelDiff_A12_nottop_nopay_tag1_2"] = {
		--（玩家等级≤满级-60】 非付费用户 一阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 100,				--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
		result = {mode = 4, ds = 1},
	},
	["levelDiff_A12_nottop_nopay_tag2_1"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A12_nottop_nopay_tag2_2"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A12_nottop_nopay_tag2_3"] = {
		--（玩家等级≤满级-60】 非付费用户 二阶 用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A12_nottop_nopay_tag3_2"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A12_nottop_nopay_tag3_3"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
	["levelDiff_A12_nottop_nopay_tag3_4"] = {
		--（玩家等级≤满级-60】 非付费用户 三阶  用例关键字段：failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 3,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_nottop_nopay_tag4"] = {
		--（玩家等级≤满级-60】 非付费用户 四阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A12_nottop_nopay_tag5"] = {
		--（玩家等级≤满级-60】 非付费用户 五阶 
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A12_nottop_nopay_lost_1"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A12_nottop_nopay_lost_2"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A12_nottop_nopay_lost_3"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_nottop_nopay_lost_4"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_nottop_nopay_lost_5"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_nottop_nopay_lost_6"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失，跨关卡段触发逻辑改变 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 			    --玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,			    --活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_nottop_nopay_lost_7"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A12_nottop_nopay_lost_8"] = {
		--（玩家等级≤满级-60】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		        d27 = true,
		        d2 = true,
		        d26 = true,
		        d4 = true,
		        d25 = true,
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1554185981746,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A12_nottop_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_nottop_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_nottop_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _nottop, 			--玩家最高关卡
		levelId = _nottop,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _nottop,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_pay_1"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_pay_2"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_pay_3"] = {
		--（玩家等级≤满级-60】 付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_nopay_1"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 0,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_nopay_2"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 1,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top60_nopay_3"] = {
		--（玩家等级≤满级-60】 非付费用户 		用例关键字段：isPayUser, diffTag, failCount, todayPlayCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top60, 				--玩家最高关卡
		levelId = _top60,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 2,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top60,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 4, ds = 1},
	},
["levelDiff_A12_top15_nopay_lost_1"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A12_top15_nopay_lost_2"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A12_top15_nopay_lost_3"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_top15_nopay_lost_4"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-1,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_top15_nopay_lost_5"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-2,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_top15_nopay_lost_7"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-3,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
["levelDiff_A12_top15_nopay_lost_8"] = {
		--（满级-15，满级】 非付费用户 濒临流失 用例关键字段：diffTag,topLevel,activationTagTopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15-100,			--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A12_top15_nopay_tag1_1"] = {
		--（满级-15，满级】 非付费用户 一阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 1,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 1},
	},
	["levelDiff_A12_top15_nopay_tag2_1"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 0,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A12_top15_nopay_tag2_2"] = {
		--（满级-15，满级】 非付费用户 二阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 2,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d5 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},
	["levelDiff_A12_top15_nopay_tag2_3"] = {
		--（满级-15，满级】 非付费用户 二阶 用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 2,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 2},
	},

	["levelDiff_A12_top15_nopay_tag3_2"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 1,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,			    	--难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
	["levelDiff_A12_top15_nopay_tag3_3"] = {
		--（满级-15，满级】 非付费用户 三阶  用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 2,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 3},
	},
["levelDiff_A12_top15_nopay_tag4"] = {
		--（满级-15，满级】 非付费用户 四阶   用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 4,									--难度标签的值
		activationTag = 4,								--活跃标签的原始值
		fixedActivationTag = 4,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 4},
	},
["levelDiff_A12_top15_nopay_tag5"] = {
		--（满级-15，满级】 非付费用户 五阶    用例关键字段：diffTag, failCount
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = false, 				--是否是付费用户
		last60DayPayAmount = 0,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = {mode = 3, ds = 5},
	},
["levelDiff_A12_top15_pay_1"] = {
		--（满级-15，满级】 付费用户 不触发       用例关键字段：isPayUser, diffTag
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d2 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 5,									--难度标签的值
		activationTag = 3,								--活跃标签的原始值
		fixedActivationTag = 3,							--活跃标签的修正值
		activationTagToplevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},
["levelDiff_A12_top15_pay_2"] = {
		--（满级-15，满级】 付费用户 不触发    用例关键字段：isPayUser，activationTag，TopLevelId
		mockData = {
		uid = "50000",					--玩家uid，现在没什么用
		--必须
		maxLevelId = _maxLevelId,		--当前配置最高关卡（top==true）	
		topLevel = _top15, 			    --玩家最高关卡
		levelId = _top15,				--当前关卡，一般闯topLevel关就配成topLevel，触发刷星fuuu才配成非topLevel
		levelStar = 0, 					--当前关卡星级
		failCount = 22,					--topLevel的合理失败次数，不用于标签判断，diffTag是标签，用于比如每n+1次触发fuuu
		isPayUser = true, 				--是否是付费用户
		last60DayPayAmount = _last60Pay47 - 1,
		
		userGroupInfo = {  				--分组信息
			forbidByAI = false,			--是否启用AI
		    retention = 5,				--回流用户活动分组，线上全都在5
		    mainSwitch = true,			--主开关，永远是true
		    diffV2 = 12,				    --难度调整分组
		    isFarmStarFuuu = true,		--在不在刷星FUUU的分组里
		},
		--回流活动触发条件
		today = 2,						--今天是几号（影响回流用户每间隔一天强度减1的逻辑），见totalDays备注
		dateLogTable = {
		    totalDays = 1,				--回流已经几天，today在log中有对应的则不变，没对应的表示今天首次登录，那么totalDays+1
		    log = {
		        d1 = true,				--d + day，可以不连续，每次会检测d+today是否存在，不存在则强度-1
		    },
		    activationTagStartTime = "1551457391138",   ---活跃标签的生效时间
		  },
		todayPlayCount = 3,								--当前关今天的打关次数，如A12每天前3次闯关不触发fuuu干预
		diffTag = 3,									--难度标签的值
		activationTag = 1,								--活跃标签的原始值
		fixedActivationTag = 1,							--活跃标签的修正值
		activationTagTopLevelId = _top15,				--活跃标签激活时的topLevelId
		--以下几个条件暂时用不到
		activationTagTopLevelIdLength = 1,				--活跃标签在离线时可以激活的关卡范围，目前没用，默认配1
		activationTagStartTime = 1551457391138,			--活跃标签的生效时间
		activationTagChangeTime = 1552879294731,		--活跃标签的更变时间
		activationTagEndTime = 1554293775,				--活跃标签的预期结束时间
		activationTagUpdateTime = 1554207375,			--活动标签的上次更新时间
		hasInitBuffFromPreBuffAct = false,				--是否激活了Buff活动且进关卡应用了Buff
		preBuffLogicCanUseFUUU = false,					--buff活动是否可以使用Fuuu
		askForHelpIsInMode = false,						--是否为好友帮助模式

		userTotalStar = 4000,							--用户当前的总星星数（包含隐藏关）
		totalStar = 5000,								--整个藤蔓的星星总数（包含隐藏关）
		--互斥
		platform = _PLATFORM,							--【1】安卓【2】苹果【3】Win32
		--可选
	},
	result = nil,
	},








}

return AdjustConfig