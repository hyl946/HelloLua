-- Wiki   http://wiki.happyelements.net/pages/viewpage.action?pageId=23541154

GameInitBuffLogic = {}

AddGameInitBuffAnimeType = {
	
	kDefault = 1 ,
	kPreBuffActivity2017 = 2 ,
	kPreProp = 3,
    kDragonBuff2018 = 4,
	kPreBuffActivity2018 = 5 ,
}

InitBuffType = {
	RANDOM_BIRD = 1,   --在棋盘上释放一个魔力鸟
	LINE = 2,          --在棋盘上释放一个直线特效（方向随机）
	WRAP = 3,          --在棋盘上释放一个爆炸特效
	BUFF_BOOM = 4,     --在棋盘上释放一个Buff炸弹
	ADD_3_STEP = 5,    --增加3步
	LINE_WRAP = 6,     --在棋盘上释放一个直线特效（方向随机）和一个爆炸特效
	REFRESH = 7,       --在道具栏里添加一个临时刷新道具
	FIRECRACKER = 8,	-- 释放爆竹（产品名：前置导弹）
}

InitBuffCreateType = {
	DEFAULT = 0,
	BUFF_ACTIVITY = 1,      --buff活动，已废弃
	INGAME_STATE = 2, 		--每走x步 自动创建buff
	PRE_PROP = 3, 			--前置道具
	REMIND_PRE_PROP = 4, 	--开局引导前置道具
	PRE_BUFF_ACTIVITY = 5, 	--加个类型 专门给前置Buff活动用, 后面逻辑要根据有没有这种类型的buff，来确定是否展示前置buff相应的提示ui
	PRIVILEGE_PRE_PROP = 6, --召回特权加的前置道具（无实体 buff形式）
}

Prop2BuffMapping = {
	[GamePropsType.kBuffBoom_b] 	= InitBuffType.BUFF_BOOM,
	[GamePropsType.kRandomBird_b] 	= InitBuffType.RANDOM_BIRD,
	[GamePropsType.kLineBomb_b] 	= InitBuffType.LINE,
	[GamePropsType.kWrapBomb_b] 	= InitBuffType.WRAP,
	[GamePropsType.kWrap_b] 		= InitBuffType.LINE_WRAP,
	[GamePropsType.kRefresh_b] 		= InitBuffType.REFRESH,
	[GamePropsType.kAdd3_b] 		= InitBuffType.ADD_3_STEP,
	[GamePropsType.kFirecracker_b] 	= InitBuffType.FIRECRACKER,		-- 其实所有引用都已失效…………
}

local InitBuffTypeSort = {
	InitBuffType.WRAP, 
	InitBuffType.LINE, 
	InitBuffType.LINE_WRAP, 
	InitBuffType.RANDOM_BIRD, 
	InitBuffType.BUFF_BOOM,
	InitBuffType.ADD_3_STEP,
	InitBuffType.REFRESH,
	InitBuffType.FIRECRACKER,
}
-- 前置和buff，不需要考虑INGAME_STATE
local InitBuffCreateTypeSort = {
	InitBuffCreateType.DEFAULT,
	InitBuffCreateType.BUFF_ACTIVITY, 
	InitBuffCreateType.PRE_PROP,
	InitBuffCreateType.PRIVILEGE_PRE_PROP,
	InitBuffCreateType.REMIND_PRE_PROP,
}

function GameInitBuffLogic:addBuffByTestFlag()

	if not self.gameInitBuffLogicTest then return end

	if self.gameInitBuffLogicTest > 17 then self.gameInitBuffLogicTest = 0 end
	--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~self.gameInitBuffLogicTest",self.gameInitBuffLogicTest)
	if self.gameInitBuffLogicTest == 1 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 2 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 3 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 4 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 4 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 5 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 6 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 7 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 8 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 9 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 10 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 11 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 12 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 13 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 14 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 4 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 15 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 4 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 16 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 4 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	elseif self.gameInitBuffLogicTest == 17 then
		GameInitBuffLogic:clearInitBuff()
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 3 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 2 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 1 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		GameInitBuffLogic:addInitBuff( {buffType = 4 , createType = InitBuffCreateType.BUFF_ACTIVITY } )
		--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~1")
	else
		GameInitBuffLogic:clearInitBuff()
	end

	GameInitBuffLogic:setAddBuffAnimeType( AddGameInitBuffAnimeType.kPreBuffActivity2017 , 5 )
end

function GameInitBuffLogic:test()

	if not self.gameInitBuffLogicTest then self.gameInitBuffLogicTest = 0 end
	--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~ 222~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	self.gameInitBuffLogicTest = self.gameInitBuffLogicTest + 1
	--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~3333~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if self.gameInitBuffLogicTest > 17 then self.gameInitBuffLogicTest = 0 end
	--printx(1,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~self.gameInitBuffLogicTest",self.gameInitBuffLogicTest)
	if self.gameInitBuffLogicTest == 1 then
		CommonTip:showTip("Init Buff A Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 2 then
		CommonTip:showTip("Init Buff B Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 3 then
		CommonTip:showTip("Init Buff C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 4 then
		CommonTip:showTip("Init Buff D Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 5 then
		CommonTip:showTip("Init Buff A + B Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 6 then
		CommonTip:showTip("Init Buff A + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 7 then
		CommonTip:showTip("Init Buff B + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 8 then
		CommonTip:showTip("Init Buff A + B + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 9 then
		CommonTip:showTip("Init Buff B + C + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 10 then
		CommonTip:showTip("Init Buff B + B + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 11 then
		CommonTip:showTip("Init Buff A + B + B + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 12 then
		CommonTip:showTip("Init Buff A + B + B + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 13 then
		CommonTip:showTip("Init Buff A + B + C + C Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 14 then
		CommonTip:showTip("Init Buff A + B + C + D Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 15 then
		CommonTip:showTip("Init Buff A + A + B + C + D Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 16 then
		CommonTip:showTip("Init Buff A + B + B + C + D Enabled !" , "negative", nil , 1.5)
	elseif self.gameInitBuffLogicTest == 17 then
		CommonTip:showTip("Init Buff A + B + C + C + D Enabled !" , "negative", nil , 1.5)
	else
		CommonTip:showTip("Init Buff Unenabled !" , "negative", nil , 3)
	end

	GameInitBuffLogic:setAddBuffAnimeType( AddGameInitBuffAnimeType.kPreBuffActivity2017 , 5 )

end

-- startLevel在GamePlaySceneUI:onInit方法中调用，在此之前有添加过buff
function GameInitBuffLogic:startLevel( mainLogic )
	self.mainLogic = mainLogic
	if not self.initBuff then self.initBuff = {} end
	if not self.initBuffResult then self.initBuffResult = {} end
	if not self.remindPrePropBuffs then self.remindPrePropBuffs = {} end
	if not self.initBuffPassedPlanList then self.initBuffPassedPlanList = {} end
	if not self.prePropsPassedPlanList then self.prePropsPassedPlanList = {} end
	
	if not self.animeType then self.animeType = AddGameInitBuffAnimeType.kDefault end
end

function GameInitBuffLogic:endLevel()
	self.initBuff = {}
	self.initBuffResult = {}
	self.remindPrePropBuffs = {}
	self.initBuffPassedPlanList = {}
	self.prePropsPassedPlanList = {}
	self.hasInitedBuffPos = false
	self.gameInitBuffLogicTest = 0
	self.flag_isReplayAndHasBuff = false
	GameInitBuffLogic:setAddBuffAnimeType( AddGameInitBuffAnimeType.kDefault )
end

----------------------------- pre props --------------------------
function GameInitBuffLogic:getPrePropsPassedPlanList()
	return self.prePropsPassedPlanList or {}
end

function GameInitBuffLogic:setPrePropsPassedPlanList(list)
	self.prePropsPassedPlanList = list or {}
end

function GameInitBuffLogic:clearPrePropsPassedPlanList()
	self.prePropsPassedPlanList = {}
end

--------------------------- buff ----------------------------
function GameInitBuffLogic:getInitBuffPassedPlanList()
	return self.initBuffPassedPlanList
end

function GameInitBuffLogic:setInitBuffPassedPlanList(list)
	self.initBuffPassedPlanList = list or {}
end

function GameInitBuffLogic:updateInitBuffPassedPlanListByReplayData(replayData)

	if replayData and #replayData > 0 then
		local list = {}
		for k,v in ipairs(replayData) do
			local d = {}
			d.buffType = d.bt
			d.createType = d.ct
			d.propId = d.pid
			table.insert( list , d )
		end

		self.initBuffPassedPlanList = list
	end
end

function GameInitBuffLogic:clearInitBuffPassedPlanList()
	self.initBuffPassedPlanList = {}
end

--------------------------------------------------------------
function GameInitBuffLogic:setFlag_isReplayAndHasBuff(flag)
	self.flag_isReplayAndHasBuff = flag
end

function GameInitBuffLogic:setAddBuffAnimeType( animeType , parameter )
	if animeType and parameter then
		self.animeType = animeType
		self.animeTypeParameter = parameter
	end
end

function GameInitBuffLogic:getAddBuffAnimeType()
	return self.animeType , self.animeTypeParameter
end

function GameInitBuffLogic:addInitBuff( buff )
	if not self.initBuff then self.initBuff = {} end
	table.insert( self.initBuff , buff )
	GameInitBuffLogic:sortInitBuffs()
	return buff
end

function GameInitBuffLogic:createBuffData(buffType, createType, propId)
	return {buffType = buffType, createType = createType, propId = propId}
end

function GameInitBuffLogic:addInitBuffByType(buffType, createType, propId)
	local buffData = GameInitBuffLogic:createBuffData(buffType, createType, propId)
	return GameInitBuffLogic:addInitBuff( buffData )
end

function GameInitBuffLogic:sortInitBuffs()
	if self.initBuff and #self.initBuff > 1 then
		local sortList = {}
		for _, ct in ipairs(InitBuffCreateTypeSort) do
			sortList[ct] = {}
			for _, bt in ipairs(InitBuffTypeSort) do
				sortList[ct][bt] = {}
			end
		end
		for k,buff in ipairs(self.initBuff) do
			if buff.createType and sortList[buff.createType] then
				if sortList[buff.createType][buff.buffType] then
					table.insert( sortList[buff.createType][buff.buffType] , buff )
				end
			elseif sortList[InitBuffCreateType.DEFAULT][buff.buffType] then
				table.insert( sortList[InitBuffCreateType.DEFAULT][buff.buffType] , buff )
			end
		end
		local sortedBuff = {}
		for _, ct in ipairs(InitBuffCreateTypeSort) do
			for _, bt in ipairs(InitBuffTypeSort) do
				for _,v1 in ipairs(sortList[ct][bt]) do
					table.insert(sortedBuff, v1 )
				end
			end
		end
		self.initBuff = sortedBuff
	end	
end

function GameInitBuffLogic:addInitBuffs( buffs )
	if not self.initBuff then self.initBuff = {} end
	for k,v in ipairs(buffs) do
		table.insert( self.initBuff , v )
	end
	GameInitBuffLogic:sortInitBuffs()
end

function GameInitBuffLogic:getInitBuffs()
	return self.initBuff
end

function GameInitBuffLogic:removeInitBuff( buff )
	self.mode = mode
end

function GameInitBuffLogic:clearInitBuff()
	--printx(1 , "GameInitBuffLogic:clearInitBuff!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" , debug.traceback() )
	self.initBuff = {}
	self.initBuffResult = {}
	self.remindPrePropBuffs = {}
	self.hasInitedBuffPos = false
end

function GameInitBuffLogic:filterBuffs(filter)
	local ret = {}
	if type(filter) == "function" and self.initBuff and #self.initBuff > 0 then
		for _, v in ipairs(self.initBuff) do
			if filter(v) then
				table.insert(ret, v)
			end
		end
	end
	return ret 
end

function GameInitBuffLogic:getCurrInitBuffResult()
	return self.initBuffResult
end

function GameInitBuffLogic:hasAnyInitBuff()
	if ( self.initBuff and #self.initBuff > 0 ) --[[ or self.flag_isReplayAndHasBuff ]] then
		return true
	end
end

function GameInitBuffLogic:hasAnyInitBuffIncludedReplay()
	-- printx( 1 , "GameInitBuffLogic:hasAnyInitBuffIncludedReplay ===============================")
	if (self.initBuff and #self.initBuff > 0) or self.flag_isReplayAndHasBuff or ( self.mainLogic and self.mainLogic.buffsForReplay and #self.mainLogic.buffsForReplay > 0 ) then
		return true
	end
	--printx( 1 , "false")
end

function GameInitBuffLogic:hasBuffTypeD()
	return self:hasBuffOfTypeInLevel(InitBuffType.BUFF_BOOM)
end

function GameInitBuffLogic:hasBuffOfTypeInLevel(buffType, createTypeList)

	--[[
	不再判断initBuffResult的结果，而是改为判断self.initBuff
	因为新版本中，buff一定会被释放出来，如果开局是没有释放成功（即initBuffResult数量小于self.initBuff数量），则会在每移动一步后重新检测并尝试释放
	if self.initBuffResult and #self.initBuffResult > 0 then
		for k,v in ipairs(self.initBuffResult) do
			if v.buffType == InitBuffType.BUFF_BOOM then
				return true
			end
		end
	end
	]]

	local function hasValidCreateType( v )
		return (not createTypeList) or table.indexOf(createTypeList, v.createType) ~= nil
	end

	if self.initBuff and #self.initBuff > 0 then
		for k,v in ipairs(self.initBuff) do
			if v.buffType == buffType and hasValidCreateType(v) then
				return true
			end
		end
	end

	local mainLogic = self.mainLogic
	if mainLogic and mainLogic.replayMode ~= ReplayMode.kNone then
		if mainLogic and mainLogic.buffsForReplay and #mainLogic.buffsForReplay > 0 then
			for k,v in ipairs(mainLogic.buffsForReplay) do
				if v.buffType == buffType and hasValidCreateType(v) then
					return true
				end
			end
		end
	end

	return false
end

function GameInitBuffLogic:_needLoadResOfType(targetType)
	if self.flag_isReplayAndHasBuff then return true end

	if self.initBuff and #self.initBuff > 0 then
		for k,v in ipairs(self.initBuff) do
			if v.buffType == targetType then
				return true
			end
		end
	end
	local mainLogic = self.mainLogic
	if mainLogic and mainLogic.replayMode ~= ReplayMode.kNone then
		if mainLogic and mainLogic.buffsForReplay and #mainLogic.buffsForReplay > 0 then
			for k,v in ipairs(mainLogic.buffsForReplay) do
				if v.buffType == targetType then
					return true
				end
			end
		end
	end
	return false
end

function GameInitBuffLogic:needLoadBuffBoomRes()
	local flag = self:_needLoadResOfType(InitBuffType.BUFF_BOOM)
	return flag
end

function GameInitBuffLogic:needLoadFirecrackerRes()
	local flag = self:_needLoadResOfType(InitBuffType.FIRECRACKER)
	return flag
end

function GameInitBuffLogic:hasAnyInitBuffResult()

	-- printx( 1 , "GameInitBuffLogic:hasAnyInitBuffResult  self.initBuffResult =" , table.tostring( self.initBuffResult ) )
	if self.initBuffResult and #self.initBuffResult > 0 then
		return true
	end
end

function GameInitBuffLogic:hasAnyInitBuffResult_notPreProp()
	local ret = GameInitBuffLogic:getResult(function(v) 
			return v.createType ~= InitBuffCreateType.PRE_PROP and v.createType ~= InitBuffCreateType.PRIVILEGE_PRE_PROP
		end)
	return #ret > 0
end

function GameInitBuffLogic:hasInitBuffFromPreBuffAct( ... )
	-- local ret = GameInitBuffLogic:getResult(function(v) return v.createType == InitBuffCreateType.PRE_BUFF_ACTIVITY end)

	-- return #ret > 0
	local mainLogic = self.mainLogic
	
	if mainLogic.replayMode and
		mainLogic.replayMode ~= ReplayMode.kNone 
		and mainLogic.replayMode ~= ReplayMode.kConsistencyCheck_Step1 
		and mainLogic.replayMode ~= ReplayMode.kAutoPlayCheck 
		and mainLogic.replayMode ~= ReplayMode.kMcts 
		then

		if mainLogic.buffsForReplay and #mainLogic.buffsForReplay > 0 then
			self.initBuff = mainLogic.buffsForReplay
		end
	end

	local ret = {}
	if self.initBuff and #self.initBuff > 0 then
		for _, v in ipairs(self.initBuff) do
			if v.createType == InitBuffCreateType.PRE_BUFF_ACTIVITY or v.createType == InitBuffCreateType.BUFF_ACTIVITY then
				table.insert(ret, v)
			end
		end
	end
	return #ret > 0
	
end

function GameInitBuffLogic:getResult(filter)
	local ret = {}
	if type(filter) == "function" and self.initBuffResult and #self.initBuffResult > 0 then
		for _, v in ipairs(self.initBuffResult) do
			if filter(v) then
				table.insert(ret, v)
			end
		end
	end
	return ret 
end

function GameInitBuffLogic:__checkMapAndFindCreatePosition( priorityTable , planList , resultList, isInGame )
	if not priorityTable then
		priorityTable = {
			PossibleSwapPriority.kNone,		
			PossibleSwapPriority.kNormal4,      --普通动物 --横或者竖三连
			PossibleSwapPriority.kNormal3, 		--普通动物 --横或者竖四连以上
			PossibleSwapPriority.kNormal2, 		--普通动物 --横竖同时三连以上
			PossibleSwapPriority.kNormal1, 		--普通动物 --横或者竖五连以上
		}
	end

	local mainLogic = self.mainLogic
	local randFactory = mainLogic.prePropRandFactory
	if isInGame then
		randFactory = mainLogic.randFactory
	end

	if priorityTable then 
		assert(type(priorityTable) == "table", "param 2 must be a table")
	end
	local mainPriorityTable = {}
	if priorityTable and #priorityTable > 0 then 
		for k,v in pairs(priorityTable) do
			if table.keyOf(PossibleSwapPriority, v) then 
				table.insert(mainPriorityTable, v)
			end
		end
	end
	if #mainPriorityTable == 0 then 
		for k,v in pairs(PossibleSwapPriority) do
			table.insert(mainPriorityTable, v)
		end
	end

	local result = {}
	--值越小 优先级越高
	local maxPriority = nil
	local function insertPossibleMoves(priority, possbileMoves)
		if not table.includes(mainPriorityTable, priority) then return end
		if not maxPriority then 
			maxPriority = priority
		elseif maxPriority > priority then 
			maxPriority = priority
		end
		if maxPriority == priority then 
			if not result[maxPriority] then 
				result[maxPriority] = {}
			end
			result[maxPriority] = table.union(result[maxPriority], possbileMoves)
		end
	end
	-- Commet:完整保存下来的只有优先级最高的Moves？

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local r1 = r
			local c1 = c
			local r2 = r
			local c2 = c + 1
			local r3 = r + 1
			local c3 = c

			if c2 <= #mainLogic.gameItemMap[r] and SwapItemLogic:canBeSwaped(mainLogic, r1, c1, r2, c2) == 1 then
				local st1, possbileMoves, pLv = SwapItemLogic:SwapedItemAndMatch(mainLogic, r1, c1, r2, c2, false) 
				if st1 then
					insertPossibleMoves(pLv, possbileMoves)
				end
			end
			if r3 <= #mainLogic.gameItemMap and SwapItemLogic:canBeSwaped(mainLogic, r1, c1, r3, c3) == 1 then
				local st2, possbileMoves, pLv = SwapItemLogic:SwapedItemAndMatch(mainLogic, r1, c1, r3, c3, false)
				if st2 then
					insertPossibleMoves(pLv, possbileMoves)
				end
			end
		end
	end

	--printx( 1, "GameInitBuffLogic:tryFindBuffPos  ==============================================")
	--printx( 1, "GameInitBuffLogic:tryFindBuffPos  ==============================================")
	--printx( 1, "GameInitBuffLogic:tryFindBuffPos  ==============================================")
	--printx( 1, table.tostring(result))


	local swapPassMap = {}

	for k,v in pairs(result) do
		
		if not swapPassMap[k] then
			swapPassMap[k] = {}
		end

		for k2,v2 in ipairs(v) do

			for k3,v3 in ipairs(v2) do
				swapPassMap[k][ tostring(v3.r) .. "_" .. tostring(v3.c) ] = true
			end
			
		end
		--swapPassMap[k][ tostring(v[1].r) .. "_" .. tostring(v[1].c) ] = v[1]

	end
	-- Commet:swapPassMap[priority][location]

	--printx( 1 , "GameInitBuffLogic:tryFindBuffPos  swapPassMap =" , table.tostring(swapPassMap) )

	local function notInPassMap(r,c)
		for k,v in pairs(swapPassMap) do
			if v and v[tostring(r) .. "_" .. tostring(c)] then
				return false
			end
		end

		return true
	end

	-- Commet:（应该是）获取本次关卡可能的过关关键目标
	local fuuuResult , fuuuLogID , progressData = FUUUManager:lastGameIsFUUU(false , false)

	local animalTargetList = {}
	local animalCountMap = {}	--某种颜色剩余的可能产出个数（如果有生成口或者鸡窝这种值就会很大啦）
	local defaultColorMap = {}
	local singleDropColorMap = {}
	if progressData then

		for k1 , v1 in ipairs(progressData) do
			if v1.orderTargetId and v1.orderTargetId == 1 then
				--目标为Animal
				if v1.cld and #v1.cld > 0 then
					for k2 , v2 in ipairs(v1.cld) do
						-- local colorIndex = v2.k2
						-- local currNum = v2.cv
						-- local targetNum = v2.tv

						table.insert( animalTargetList , 
							{colorIndex = v2.k2 , currNum = v2.cv , targetNum = v2.tv} )
					end
				end
			end
		end

		if #animalTargetList > 0 then

			for i = 1 , #mainLogic.mapColorList do
				defaultColorMap[ AnimalTypeConfig.convertColorTypeToIndex( mainLogic.mapColorList[i] ) ] = true
			end

			--printx(1 , "RRRRRRRRRRRRRRRRRRRRRRRRRR  mainLogic.singleDropCfg = " , table.tostring(mainLogic.singleDropCfg))
			local singleDropLimitedList = mainLogic:getSingleDropLimitedColors( TileConst.kCannonCandyColouredAnimal , 0 , 0 )
			if singleDropLimitedList and #singleDropLimitedList > 0 then
				for i = 1 , #singleDropLimitedList do
					singleDropColorMap[ AnimalTypeConfig.convertColorTypeToIndex( singleDropLimitedList[i] ) ] = true
				end
			end
			

			local function countAnimal(itemColorIndex , addCount)
				if not animalCountMap[itemColorIndex] then
					animalCountMap[itemColorIndex] = 0
				end
				--printx(1 , "???????????????????????? itemColorIndex " , itemColorIndex , "animalCountMap[itemColorIndex]" , animalCountMap[itemColorIndex] , "addCount" , addCount)
				animalCountMap[itemColorIndex] = animalCountMap[itemColorIndex] + addCount
			end

			local function checkGrid( item , board )
				if item then
					if item.ItemType == GameItemType.kAnimal then
						--printx(1 , "WTFFFF  111")
						local itemColorIndex = AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType )
						countAnimal(itemColorIndex , 1)
					elseif item.ItemType == GameItemType.kRoost then
						countAnimal( 6 , 1000000 )
					elseif item.ItemType == GameItemType.kCrystalStone then
						local itemColorIndex = AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType )
						countAnimal( itemColorIndex , 1000000 )
					end

					local hasNormalCannon = false
					local hasColorCannon = false

					if board.theGameBoardFallType and #board.theGameBoardFallType > 0 then

						if table.exist(board.theGameBoardFallType , TileConst.kCannonCandyColouredAnimal) then
							
							hasColorCannon = true

						elseif table.exist(board.theGameBoardFallType , TileConst.kCannon)
							or table.exist(board.theGameBoardFallType , TileConst.kCannonAnimal)
							or table.exist(board.theGameBoardFallType , TileConst.kCannonGreyCuteBall)
							or table.exist(board.theGameBoardFallType , TileConst.kCannonBrownCuteBall)
						then
							hasNormalCannon = true
						end
					end

					if hasNormalCannon then
						for kc,vc in pairs(defaultColorMap) do
							countAnimal(kc , 1000000 )
						end
					end

					if hasColorCannon then
						for kc,vc in pairs(singleDropColorMap) do
							countAnimal(kc , 1000000 )
						end
					end
					
				end
			end

			--棋盘正面
			for r = 1, #mainLogic.gameItemMap do
				for c = 1, #mainLogic.gameItemMap[r] do
					local item = mainLogic.gameItemMap[r][c]
					local board = mainLogic.boardmap[r][c]

					checkGrid( item , board )
				end
			end

			--棋盘背面
			for r = 1 , 9 do
				if mainLogic.backItemMap[r] and mainLogic.backBoardMap[r] then
					for c = 1 , 9 do
						local item = mainLogic.backItemMap[r][c]
						local board = mainLogic.backBoardMap[r][c]

						checkGrid( item , board )
					end
				end
			end
		end
		
	end

	-- 总索引： 0:没有有效交换的格子  1:交换后有匹配的格子
	-- 格子上的对象 {0:{{r1, c1, item1},..}, 1:{{r3, c3, item3},..}}
	local candidateListCollection = {}
	-- 位置 {0:{{r1, c1},..}, 1:{{r3, c3},..}}
	local candidateIndex_boom = {} 			-- 可投放 buff/前置炸弹
	local candidateIndex_magicBird = {} 	-- 可投放 魔力鸟
	local candidateIndex_firework = {}		-- 可投放 前置/buff爆竹
	local candidateIndex_lineAndWrap = {} 	-- 可投放 特效动物


	local animalAndCrystalCount = 0

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			if item and board then

				if (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal) 
					and item.ItemSpecialType == 0
					and not item:hasActiveSuperCuteBall()
					and not item:hasBlocker206()
					and item.beEffectByMimosa == 0
					and board.colorFilterBLevel == 0
					and board.lotusLevel <= 1
					and not board.isReverseSide
					and not item:seizedByGhost()
					and not item:hasSquidLock()
					then

					local cannotReplaceColour = false -- 不能被其他颜色替换（包括无色）
					local itemColorIndex = AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType )
					
					for k1 , v1 in ipairs(animalTargetList) do

						if v1.colorIndex == itemColorIndex then--当前Item是某个搜集目标
							local count = animalCountMap[itemColorIndex] or 0

							if count <= v1.targetNum then
								--printx( 1 , "WTFFFFFFFFFFFFFFFFFF>>>>>>>>>>>>>>>>>>>> count" , count , "targetNum" , v1.targetNum , "   At ", r,c)
								-- printx( 1 , "---- cannotReplaceColour" , count , "targetNum" , v1.targetNum , "   At ", r,c)
								cannotReplaceColour = true
							else
								if not animalCountMap[itemColorIndex] then animalCountMap[itemColorIndex] = 0 end
								animalCountMap[itemColorIndex] = animalCountMap[itemColorIndex] - 1
							end
							break
						end
					end

					animalAndCrystalCount = animalAndCrystalCount + 1

					---------------------------------------------------------------
					local function insertWithSwapIndex(swapIndex, targetList, targetData)
						if not targetList[swapIndex] then
							targetList[swapIndex] = {}
						end
						table.insert(targetList[swapIndex], targetData)
					end

					local currSwapIndex = 1
					if notInPassMap(r, c) then 	-- 没有可消除的交换
						currSwapIndex = 0
					end
					insertWithSwapIndex(currSwapIndex, candidateListCollection, {r = r, c = c, item = item})

					local currPos = {r = r, c = c}
					-- 无色或替换颜色
					if not item:hasLock() and not item.hasActCollection and not cannotReplaceColour then
						if not board.preAndBuffMagicBirdPassSelect and not board.buffBoomPassSelect then
							insertWithSwapIndex(currSwapIndex, candidateIndex_magicBird, currPos)
						end

						if not board.buffBoomPassSelect then
							insertWithSwapIndex(currSwapIndex, candidateIndex_boom, currPos)
						end
					end

					if not board.preAndBuffFirecrackerPassSelect then
						insertWithSwapIndex(currSwapIndex, candidateIndex_firework, currPos)
					end

					if not board.preAndBuffLineWrapPassSelect then
						insertWithSwapIndex(currSwapIndex, candidateIndex_lineAndWrap, currPos)
					end
				end
			end
		end
	end

	local positionUsedCount = 0

	for k,v in ipairs( planList ) do
		-- printx(11, "= = = check create buff of ", v.buffType)
		local checkCount = false --会被替换为无色物，所以需要检测剩余数量

		local tarItemSpecialType = nil
		local tarItemType = nil
		if v.buffType == InitBuffType.RANDOM_BIRD then
			tarItemSpecialType = AnimalTypeConfig.kColor
			checkCount = true
		elseif v.buffType == InitBuffType.LINE then
			if randFactory:rand(1,2) == 1 then
				tarItemSpecialType = AnimalTypeConfig.kLine
			else
				tarItemSpecialType = AnimalTypeConfig.kColumn
			end
		elseif v.buffType == InitBuffType.WRAP then
			tarItemSpecialType = AnimalTypeConfig.kWrap
		elseif v.buffType == InitBuffType.BUFF_BOOM then
			checkCount = true
		elseif v.buffType == InitBuffType.FIRECRACKER then
			tarItemType = GameItemType.kFirecracker
		end

		local needContinue = false

		if checkCount then
			if animalAndCrystalCount - positionUsedCount < 5 then
				needContinue = true
			end
		end

		if not needContinue then
			local function randomFindPos(indexList)
				for swapIndex = 0, 1 do
					local currIndexList = indexList[swapIndex]
					local currCandidateList = candidateListCollection[swapIndex]
					if currIndexList and #currIndexList > 0 and currCandidateList and #currCandidateList > 0 then
						while table.maxn(currIndexList) > 0 do --位置可能已被其他index使用，所以需重复遍历
							local randIndex = randFactory:rand(1, #currIndexList)
							local IndexPos = currIndexList[randIndex]
							table.remove(currIndexList, randIndex)
							-- printx(11, "+ + + IndexPos", IndexPos.r, IndexPos.c)

							local targetFond
							for i = 1 , #currCandidateList do
								local p = currCandidateList[i]
								-- printx(11, "++++++++++ scan currCandidateList:("..p.r..","..p.c..")")
								if p.r == IndexPos.r and p.c == IndexPos.c then
									-- printx(11, "Target Gotten!:("..p.r..","..p.c..")", p.item)
									targetFond = p
									table.remove( currCandidateList , i )
									break
								end
							end

							if targetFond then
								return targetFond
							end
						end
					end
				end

				return nil
			end

			local function randomFind(indexList)
				local fondData
				local pos = randomFindPos(indexList)
				-- printx(11, "=== randomFind pos ===", pos)
				if pos then
					fondData = {}
					fondData.item = pos.item
					fondData.r = pos.r
					fondData.c = pos.c
					fondData.tarItemSpecialType = tarItemSpecialType
					fondData.tarItemType = tarItemType
					fondData.buffType = v.buffType
					fondData.createType = v.createType
					fondData.propId = v.propId
					table.insert( resultList , fondData )
					positionUsedCount = positionUsedCount + 1
					-- printx(11, "checkMapAndFindCreatePosition  --------------  buffType:" , v.buffType , "createType:" , v.createType , "propId:",v.propId, "tarItemType", tarItemType)
				end
				return fondData
			end

			if v.buffType == InitBuffType.RANDOM_BIRD then
				randomFind(candidateIndex_magicBird)
			elseif v.buffType == InitBuffType.BUFF_BOOM then
				randomFind(candidateIndex_boom)
			elseif v.buffType == InitBuffType.FIRECRACKER then
				randomFind(candidateIndex_firework)
			elseif v.buffType == InitBuffType.LINE_WRAP then
				local noSwapPosCount = 0
				if candidateIndex_lineAndWrap[0] then noSwapPosCount = #candidateIndex_lineAndWrap[0] end
				local swapPosCount = 0
				if candidateIndex_lineAndWrap[1] then swapPosCount = #candidateIndex_lineAndWrap[1] end
				if noSwapPosCount + swapPosCount >= 2 then
					local pos = {}
					for i = 1, 2 do
						local pickedPos = randomFindPos(candidateIndex_lineAndWrap)
						if pickedPos then table.insert(pos, pickedPos) end
					end
					if #pos >= 2 then
						sucessFind = true
						local datas = {}
						datas.item = pos[1].item
						datas.r = pos[1].r
						datas.c = pos[1].c
						if randFactory:rand(1,2) == 1 then
							datas.tarItemSpecialType = AnimalTypeConfig.kLine
						else
							datas.tarItemSpecialType = AnimalTypeConfig.kColumn
						end

						datas.item2 = pos[2].item
						datas.r2 = pos[2].r
						datas.c2 = pos[2].c
						datas.tarItemSpecialType2 = AnimalTypeConfig.kWrap

						datas.propId = v.propId
						datas.buffType = v.buffType
						datas.createType = v.createType
						table.insert( resultList , datas )
						positionUsedCount = positionUsedCount + 2
						--printx( 1 , "checkMapAndFindCreatePosition  --------------  buffType:" , v.buffType , "createType:" , v.createType , "propId:",v.propId)
					end
				end
			elseif v.buffType == InitBuffType.LINE or v.buffType == InitBuffType.WRAP then
				randomFind(candidateIndex_lineAndWrap)
			else
				local datas2 = {}
				datas2.item = nil
				datas2.r = 0
				datas2.c = 0
				datas2.propId = v.propId
				datas2.buffType = v.buffType
				datas2.createType = v.createType
				table.insert( resultList , datas2 )
				--printx( 1 , "checkMapAndFindCreatePosition  --------------  buffType:" , v.buffType , "createType:" , v.createType , "propId:",v.propId)
			end
		end
	end

end

function GameInitBuffLogic:tryFindBuffPos( priorityTable )
	-- printx(11, "GameInitBuffLogic:tryFindBuffPos   self.hasInitedBuffPos =" , self.hasInitedBuffPos , debug.traceback())

	if self.hasInitedBuffPos then
		return
	end
	self.hasInitedBuffPos = true
	self.initBuffResult = {}

	local mainLogic = self.mainLogic

	if mainLogic.replayMode ~= ReplayMode.kNone 
		and mainLogic.replayMode ~= ReplayMode.kConsistencyCheck_Step1 
		and mainLogic.replayMode ~= ReplayMode.kAutoPlayCheck 
		and mainLogic.replayMode ~= ReplayMode.kMcts 
		then

		if mainLogic.buffsForReplay and #mainLogic.buffsForReplay > 0 then
			self.initBuff = mainLogic.buffsForReplay
			local buffs = self:filterBuffs(function(v) return v.createType ~= InitBuffCreateType.REMIND_PRE_PROP end)
			self:__checkMapAndFindCreatePosition( priorityTable , buffs , self.initBuffResult )
		end

	else
		self:__checkMapAndFindCreatePosition( priorityTable , self.initBuff , self.initBuffResult )
	end
end

function GameInitBuffLogic:tryCreateNewBuffBoomAndReturnPositon()
	local buffs = {}
	table.insert( buffs , GameInitBuffLogic:createBuffData(InitBuffType.BUFF_BOOM, InitBuffCreateType.INGAME_STATE) )

	local resultList = {}

	self:__checkMapAndFindCreatePosition( nil , buffs , resultList, true )

	return resultList
end

function GameInitBuffLogic:tryCreateBuffPositonByInitBuffPassedPlanList()

	local mainLogic = self.mainLogic
	if mainLogic and mainLogic.theGamePlayType == GameModeType.CLASSIC_MOVES then
		self:clearInitBuffPassedPlanList()
		return nil --时间关只尝试创建一次，之后不再创建
	end

	local passedPlanList = self:getInitBuffPassedPlanList()

	if not passedPlanList or #passedPlanList == 0 then
		return nil
	end

	local resultList = {}

	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()
	local lastGuideStep = guideContext.lastGuideStep

	local function docheck()

		self:__checkMapAndFindCreatePosition( nil , passedPlanList , resultList, true )

		if #passedPlanList == #resultList then --必须能够全部释放出来，才释放
			self:clearInitBuffPassedPlanList()

			for k,v in ipairs(resultList) do
				SnapshotManager:releaseBuffOrPreProp( v )
			end

			return resultList
		end
	end

	if guideContext.allowRepeatGuide then
		return docheck()
	elseif self.mainLogic.realCostMoveWithoutBackProp > lastGuideStep then
		return docheck()
	end

	return nil
end

function GameInitBuffLogic:tryCreatePrePropPositionsByPassedPlanList()
	local mainLogic = self.mainLogic
	if mainLogic and mainLogic.theGamePlayType == GameModeType.CLASSIC_MOVES then
		self:clearPrePropsPassedPlanList()
		return nil --时间关只尝试创建一次，之后不再创建
	end

	local passedPlanList = self:getPrePropsPassedPlanList()
	if not passedPlanList or #passedPlanList == 0 then
		return nil
	end

	local resultList = {}
	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()
	local lastGuideStep = guideContext.lastGuideStep

	local function docheck()
		self:__checkMapAndFindCreatePosition(nil, passedPlanList, resultList, true)

		if #passedPlanList == #resultList then --必须能够全部释放出来，才释放
			self:clearPrePropsPassedPlanList()

			for k,v in ipairs(resultList) do
				SnapshotManager:releaseBuffOrPreProp( v )
			end
			
			return resultList
		end
	end

	if guideContext.allowRepeatGuide then
		return docheck()
	elseif self.mainLogic.realCostMoveWithoutBackProp > lastGuideStep then
		return docheck()
	end

	return nil
end

function GameInitBuffLogic:tryCreateNewFirecrackerAndReturnPositon(createAmount, propId)
	local buffs = {}
	for i = 1, createAmount do
		table.insert(buffs, GameInitBuffLogic:createBuffData(
			InitBuffType.FIRECRACKER, InitBuffCreateType.INGAME_STATE, propId))
	end

	local resultList = {}
	self:__checkMapAndFindCreatePosition(nil, buffs, resultList, true)

	return resultList
end

function GameInitBuffLogic:doChangeBoardByGameInitBuff( callback )
	local mainLogic = self.mainLogic

	--非前置道具，即Buff的可成功释放的位置的集合
	local notPrePropResult = GameInitBuffLogic:getResult(function(v) return not self:isPrePropBuff(v.createType) end)

	local buffPlan = self:getInitBuffs()
	local passedPlanList = {}
	local resultList = {}

	for k,v in pairs(notPrePropResult) do
		table.insert( resultList , v ) 
	end

	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()
	local passLogic = false

	-- printx( 1 , "GameInitBuffLogic:doChangeBoardByGameInitBuff  guideContext =" , table.tostring(guideContext) )
	if not guideContext.allowRepeatGuide and guideContext.lastGuideStep >= 0 then
		passLogic = true --关卡内有可启动的引导，初始化时不放Buff
	end

	-- printx( 1 , "GameInitBuffLogic:doChangeBoardByGameInitBuff  passLogic =" , passLogic )

	if passLogic then
		notPrePropResult = {} --初始化棋盘时一个buff也不丢，全加入passedPlanList列表，留到后面再丢
	end

	if notPrePropResult and #notPrePropResult> 0 then

		-- printx( 1 , "GameInitBuffLogic:doChangeBoardByGameInitBuff  111 " )
		for k,v in pairs( buffPlan ) do
			--buffType = 3 , createType
			if v.createType == InitBuffCreateType.BUFF_ACTIVITY or v.createType == InitBuffCreateType.PRE_BUFF_ACTIVITY then

				local check = false
				for k1 , v1 in pairs(resultList) do
					if v.buffType == v1.buffType 
						and ( v1.createType == InitBuffCreateType.BUFF_ACTIVITY or v1.createType == InitBuffCreateType.PRE_BUFF_ACTIVITY ) 
						then
						resultList[k1] = nil
						check = true
						break
					end
				end

				if not check then
					table.insert( passedPlanList , v )
				end
			end
		end
	else
		
		-- printx( 1 , "GameInitBuffLogic:doChangeBoardByGameInitBuff  222  buffPlan =" , table.tostring(buffPlan) )

		for k,v in pairs( buffPlan ) do
			if v.createType == InitBuffCreateType.BUFF_ACTIVITY or v.createType == InitBuffCreateType.PRE_BUFF_ACTIVITY then
				table.insert( passedPlanList , v )
			end
		end
	end

	-- printx( 1 , "GameInitBuffLogic:doChangeBoardByGameInitBuff  passedPlanList =" , table.tostring(passedPlanList) )
	self.initBuffPassedPlanList = passedPlanList

	if notPrePropResult and #notPrePropResult > 0 then

		for k,v in ipairs(notPrePropResult) do
			SnapshotManager:releaseBuffOrPreProp( v )
		end
		

		local action =  GameBoardActionDataSet:createAs(
			GameActionTargetType.kPropsAction,
			GameItemActionType.kAddBuffItemToBoard,
			nil,
			nil,
			GamePlayConfig_MaxAction_time)
		action.completeCallback = callback
		action.initBuffResult = notPrePropResult

		local animeType , datas = GameInitBuffLogic:getAddBuffAnimeType()
		action.animeType = animeType
		action.animeTypeParameter = datas

		mainLogic:addGlobalCoreAction(action)
		SnapshotManager:stop()
	else
		if callback then callback() end
	end
end

function GameInitBuffLogic:useRemindPreItems(preItems, callback)
	local buffs = self:addInitBuffByItems(preItems, InitBuffCreateType.REMIND_PRE_PROP)
	
	ReplayDataManager:updateBuffsData(buffs , 1)

	self.remindPrePropBuffs = buffs
	if self.mainLogic.isWaitingOperation then
		self:doUseRemindPreProps(callback)
	else
		if type(callback) == "function" then -- delay callback
			setTimeOut(callback, 0)
		end
	end
end

function GameInitBuffLogic:doUseRemindPreProps(callback)
	if #self.remindPrePropBuffs > 0 then
		local buffs = self.remindPrePropBuffs
		local resultList = {}
		self:__checkMapAndFindCreatePosition( nil , buffs , resultList )
		self.remindPrePropBuffs = {}

		local function useRemindPropCallback()
			SectionResumeManager:addSection()
			if type(callback) == "function" then callback() end
		end
		self:useBuffWithResults(resultList, useRemindPropCallback)
		return true
	end
	return false
end

function GameInitBuffLogic:useBuffWithResults(prePropResult, callback)
	if prePropResult and #prePropResult > 0 then
		local mainLogic = self.mainLogic

		for k,v in ipairs( prePropResult ) do
			SnapshotManager:releaseBuffOrPreProp( v )
		end

		local totalAction = #prePropResult
		local function completeCallback( fromGuide )
			totalAction = totalAction - 1
			if totalAction == 0 then
				if callback then callback() end
			end
		end
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		local destYInWorldSpace = visibleOrigin.y + visibleSize.height / 2 + 100
		local itemIndex = 0
		local totalSelected = #prePropResult
		local centerPosX = visibleOrigin.x + visibleSize.width / 2
		local itemPadding = 190 - 10 * totalSelected
		for _, data in ipairs(prePropResult) do
			itemIndex = itemIndex + 1
			local itemData = {}
			itemData.id = ItemType:getRealIdByTimePropId(data.propId)
			itemData.destXInWorldSpace = centerPosX + (itemIndex - (totalSelected+1) / 2) * itemPadding
			itemData.destYInWorldSpace = destYInWorldSpace
			local action = nil
			if data.shouldGiveBack then 	--此分支应已关闭
				action =  GameBoardActionDataSet:createAs(
						GameActionTargetType.kPropsAction,
						GameItemActionType.kItemGiveBack,
						nil,
						nil,
						GamePlayConfig_MaxAction_time)
			else
				if data.buffType == InitBuffType.ADD_3_STEP then
					action =  GameBoardActionDataSet:createAs(
						GameActionTargetType.kPropsAction,
						GameItemActionType.kAddBuffAdd3Step,
						nil,
						nil,
						GamePlayConfig_MaxAction_time)
				elseif data.buffType == InitBuffType.REFRESH then
					action =  GameBoardActionDataSet:createAs(
						GameActionTargetType.kPropsAction,
						GameItemActionType.kAddBuffRefresh,
						nil,
						nil,
						GamePlayConfig_MaxAction_time)
				else
					action =  GameBoardActionDataSet:createAs(
						GameActionTargetType.kPropsAction,
						GameItemActionType.kAddBuffSpecialAnimal,
						nil,
						nil,
						GamePlayConfig_MaxAction_time)
					action.pos = {r = data.r, c = data.c}
					if data.buffType == InitBuffType.RANDOM_BIRD then
						action.tarItemColorType = 0
					else
						action.tarItemColorType = data.item._encrypt.ItemColorType
					end
					action.tarItemSpecialType = data.tarItemSpecialType

					if data.buffType == InitBuffType.LINE_WRAP then
						action.pos2 = {r = data.r2, c = data.c2}
						action.tarItemColorType2 = data.item2._encrypt.ItemColorType
						action.tarItemSpecialType2 = data.tarItemSpecialType2
					end
					if data.buffType == InitBuffType.FIRECRACKER then
						action.tarItemType = data.tarItemType
					end
					mainLogic:preGameProp(itemData.id)
				end

				action.fromGuide = (data.createType == InitBuffCreateType.REMIND_PRE_PROP)
				action.buffType = data.buffType
			end
			action.data = itemData
			action.completeCallback = completeCallback
			mainLogic:addGlobalCoreAction(action)
			SnapshotManager:stop()
		end
	else
		local mainLogic = self.mainLogic
		local function delayCallback()
			if not mainLogic.isDisposed then
				if callback then callback() end
			else
				assert(false, "noPreProp callback - mainLogic isDisposed")
			end
		end
		setTimeOut(delayCallback, 0.1) 
	end
end

function GameInitBuffLogic:isPrePropBuff(createType)
	if self.mainLogic.replayMode == ReplayMode.kNone then
		return createType == InitBuffCreateType.PRE_PROP or createType == InitBuffCreateType.PRIVILEGE_PRE_PROP
	else
		return createType == InitBuffCreateType.PRE_PROP or createType == InitBuffCreateType.PRIVILEGE_PRE_PROP or createType == InitBuffCreateType.REMIND_PRE_PROP
	end
end

function GameInitBuffLogic:doUsePreProps(selectedItemsData, callback)
	-- printx(11, "* * * GameInitBuffLogic:doUsePreProps,", debug.traceback())
	local prePropResult = GameInitBuffLogic:getResult(function(v) 
			return v.createType == InitBuffCreateType.PRE_PROP or v.createType == InitBuffCreateType.PRIVILEGE_PRE_PROP
			end)
	local usePrePropResult = {}
	local passedPrePropPlanList = {}

	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()
	local passLogic = false
	if not guideContext.allowRepeatGuide and guideContext.lastGuideStep >= 0 then
		passLogic = true --关卡内有可启动的引导，初始化时不放前置道具
	end

	local function appearsInPreItemResult(id)
		for _, v in ipairs(prePropResult) do
			if v.propId == id then
				-- +3步可以不管有无引导，直接释放
				if not passLogic or v.buffType == InitBuffType.ADD_3_STEP then
					return v
				end
			end
		end
		return nil
	end

	local function addToPassedPlanList(targetBuff)
		local initAllBuffPlan = self:getInitBuffs()

		if not targetBuff.isPrivilegeFree then 
			-- printx(11, "=========== Can't release this pre prop! ============")
			-- printx(11, "data", targetBuff.propId, targetBuff.buffType)

			----- 每轮检测释放，不回背包了
			-- 正常玩耍的时候需要返还用不了的道具
			-- table.insert(usePrePropResult, {propId = targetBuff.propId, shouldGiveBack = true})
			-- table.insert(giveBackPropIds, targetBuff.propId)
			for _, origPlan in pairs(initAllBuffPlan) do
				if origPlan.createType == InitBuffCreateType.PRE_PROP 
					or origPlan.createType == InitBuffCreateType.PRIVILEGE_PRE_PROP 
					then
					if origPlan.propId == targetBuff.propId then
						table.insert(passedPrePropPlanList , origPlan)
						-- printx(11, "+ + + add to prePropsPassedPlanList! + + + ")
					end
				end
			end
		end
	end

	local function checkAddToPassedPlanList(targetList)
		targetList = targetList or {}
		for _, v in ipairs(targetList) do
			local ret = appearsInPreItemResult(v.propId)
			if ret then
				table.insert(usePrePropResult, ret)
			else
				addToPassedPlanList(v)
			end
		end

		self.prePropsPassedPlanList = passedPrePropPlanList
		-- if #giveBackPropIds > 0 then
		-- 	GameInitBuffLogic:giveBackPreProps(giveBackPropIds)
		-- end
	end

	if self.mainLogic.replayMode == ReplayMode.kNone then
		checkAddToPassedPlanList(selectedItemsData)
	else
		checkAddToPassedPlanList(self:getInitBuffs())
		self.remindPrePropBuffs = self:filterBuffs(function(v) return v.createType == InitBuffCreateType.REMIND_PRE_PROP end)
	end
	
	self:useBuffWithResults(usePrePropResult, callback)
end

function GameInitBuffLogic:addInitBuffByItems(items, createType)
	local buffs = {}
	for k,v in pairs(items) do
		local realPropId = ItemType:getRealIdByTimePropId(v.id)
		local buffType = Prop2BuffMapping[realPropId]
		if buffType then
			local buff = GameInitBuffLogic:addInitBuffByType(buffType, createType, v.id)
			table.insert(buffs, buff)
		end
	end
	return buffs
end

function GameInitBuffLogic:initWithSelectedPreItems(preItems)
	self:addInitBuffByItems(preItems, InitBuffCreateType.PRE_PROP)
end

function GameInitBuffLogic:initWithPrivilegePreItems(preItems)
	self:addInitBuffByItems(preItems, InitBuffCreateType.PRIVILEGE_PRE_PROP)
end

function GameInitBuffLogic:giveBackPreProps(propList)
	local stageInfo = StageInfoLocalLogic:getStageInfo( UserManager.getInstance().uid )
	local preProps = stageInfo and stageInfo.preProps or {}
	local giveBackProps = {}
	for _, prop in ipairs(preProps) do
		if table.exist(propList, prop.propId) then
			table.insert(giveBackProps, {propId = prop.propId, expireTime = prop.expireTime})
		end
	end
	if #giveBackProps < 1 then return end

	local function onSuccess()
		for _, prop in ipairs(giveBackProps) do
			if ItemType:isTimeProp(prop.propId) then
				UserManager.getInstance():addTimeProp(prop.propId , 1, prop.expireTime)
				UserService.getInstance():addTimeProp(prop.propId , 1, prop.expireTime)
			else
				UserManager.getInstance():addUserPropNumber(prop.propId, 1)
				UserService.getInstance():addUserPropNumber(prop.propId, 1)
			end
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStagePlay, prop.propId, 1, DcSourceType.kReturnPreProp, stageInfo.levelId)
		end
		Localhost:getInstance():flushCurrentUserData()
	end
	local function onFail()
	end
	local http = ReturnPrePropsHttp.new()
	http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
	http:load(giveBackProps)
end