-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionAction

	
	MissionAction用来描述一个动作，
	这个条件可以是玩家点击“做任务”按钮后，游戏应执行的默认操作（比如打开关卡开始面板，打开周赛面板，打开金银果树等等），
	也可以是任务完成后，点击领奖按钮后游戏应该执行的操作（比如修改玩家道具数量，修改玩家银币数量，修改周赛次数等等）

	任务一个业务层的任务都会被CMF_DataConverter转化为一个sourceData，而sourceData最后会被创建为一个MissionData实例。
	每个MissionData的doActions列表和resultActions列表里都的数据类型都是MissionAction

	一个MissionAction主要由以下几部分构成：
		id                动作类型，枚举在 MissionFrameConfig.conditionsMap 里
		parameters        该动作的参数列表。

]]
---------------------------------------------------

MissionAction = class()

function MissionAction:create(id  ,  parameters)
	local action = MissionAction.new()
	action:init(id  , parameters)
	return action
end

function MissionAction:init(id  , parameters)
	self.id = id
	self.parameters = parameters
end

function MissionAction:getId()
	return self.id
end

function MissionAction:getParameters()
	return self.parameters
end