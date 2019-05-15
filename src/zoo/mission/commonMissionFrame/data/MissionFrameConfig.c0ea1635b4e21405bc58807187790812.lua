MissionFrameConfig = {}

MissionFrameConfig.conditionsMap = {
	
	--自接受任务起，通过第 value 关。
	--参数：
	--parameters[1]星星数要求
	--parameters[2]星星数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
	--parameters[3]剩余步数要求。-1为不要求
	--parameters[4]剩余步数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
	k10001 = "MF_PassLevel.lua" ,  

	--检查玩家第value关的是否为过关状态
	--和MF_PassLevel不同，MF_CheckLevelPassed不要求一定要在接到任务后打过这一关。
	--参数：
	--parameters[1]要求的最低星星数，默认是1
	--parameters[2]比较方式【1】大于等于（默认）【2】小于等于【3】等于 
	k10002 = "MF_CheckLevelPassed.lua" ,

	--自接受任务起，在第 value 关闯关失败。参数：parameters[1]限定失败类型，0为不限类型
	k10003 = "MF_FailLevel.lua" ,  

	--自接受任务起，进入第 value 关。
	k10004 = "MF_EnterLevel.lua" ,  

	--自接受任务起，进入任意一关LevelTpye为 value 的关卡。
	k10005 = "MF_EnterLevelTpye.lua" , 

	--自接受任务起，通过第任意一关，且星星数 >= value。
	--参数：parameters[1]比较方式【1】大于等于（默认）【2】小于等于【3】等于 
	k10006 = "MF_PassLevelWithStar.lua" ,   

	--通过第任意一关，且剩余步数 >= value。
	--参数：parameters[1]比较方式【1】大于等于（默认）【2】小于等于【3】等于
	k10007 = "MF_PassLevelRemainSteps.lua" ,  

	--任意一关失败，且 满足（value = true）/不满足（value = false） Fuuu状态
	k10008 = "MF_FailLevelWithFuuu.lua" ,  
	
	--自接受任务起，累计再收集value颗星星。
	k10009 = "MF_GetLevelStar.lua" ,  


	--自接受任务起，连续在线登录value天
	k10021 = "MF_ContinuousLoginGame.lua" ,  

	--历史最高连续在线登录天数 >= value
	k10022 = "MF_HistoryContinuousLoginGame.lua" ,  

	--自接受任务起，累计在线登录value天
	k10023 = "MF_TotalLoginGame.lua" ,  

	--历史最高累计在线登录天数 >= value
	k10024 = "MF_HistoryTotalLoginGame.lua" ,  

	--自接受任务起，连续签到value天
	k10025 = "MF_ContinuousCheckInGame.lua" ,  

	--自接受任务起，累计签到value天
	k10026 = "MF_TotalCheckInGame.lua" ,  

	--自接受任务起，搜集value个关卡内物品。parameters[1]物品类型
	k10031 = "MF_CollectItem",  

	--自接受任务起，采摘value个金银果实。parameters[1]限定果实类型，0为不限制
	k10041 = "MF_HarvestFruit.lua" ,  

	--自接受任务起，向好友请求value点精力值。
	k10051 = "MF_RequestEnergy.lua" ,  
}

MissionFrameConfig.actionsMap = {
	
	k20001 = "MF_AddCoin.lua" ,  --增加value银币
	k20002 = "MF_AddCash.lua" ,  --增加value风车币
	k20003 = "MF_AddPorps.lua" ,  --增加value个道具。parameters[1]道具类型
	k20004 = "MF_AddWeekGameTimes.lua" ,  --增加value周赛次数

	k30001 = "MF_ShowHomeScene.lua" ,  --回到Trunk主场景
	k30002 = "MF_ShowTrunkLevelStartPanel.lua" ,  --弹出主线关卡开始面板
	k30003 = "MF_ShowWeeklyMatchStartPanel.lua" ,  --弹出周赛开始面板
	k30004 = "MF_ShowFriutTreePanel.lua" ,  --进入金银果树面板
	k30005 = "MF_ShowMarkPanel.lua" ,  --弹出签到面板

}

--[[
MissionFrameConfig.missionConfig = {
	k1 = { conditionId = 20000 , conditionValue = 0 , conditionParameters = 1},

	k2 = { conditionId = 20000 , conditionValue = 0 , conditionParameters = 3},

	k3 = { conditionId = 20000 , conditionValue = 0 , conditionParameters = 4},

	k4 = { conditionId = 20001 , conditionValue = 0 , conditionParameters = 0 },

	k5 = { conditionId = 20002 , conditionValue = 0 },

	k6 = { conditionId = 20003 , conditionValue = 50 },

	k7 = { conditionId = 20004 , conditionValue = 1 },
}
]]
