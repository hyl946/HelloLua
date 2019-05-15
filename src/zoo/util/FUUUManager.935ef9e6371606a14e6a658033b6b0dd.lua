require 'zoo.net.Localhost'

FUUUManager = {}
FUUUManager.isGameRunning = false

FUUUConfig = {
	
	oneYuanBuyContinuousFailNum = 1,
}

function FUUUManager:init()

	local platform = UserManager.getInstance().platform
	local uid = UserManager.getInstance().uid
	local fuuuFileKey = "fuuuManagerFileKey_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"

	local localData = Localhost:readFromStorage(fuuuFileKey)

	if not localData then
		localData = {}
		localData.gameFailedLog = {}
		localData.fuuuData = {}
		localData.levelTotalPlayed = {}
	end

	if not localData.gameFailedLog then
		localData.gameFailedLog = {}
	end

	if not localData.fuuuData then
		localData.fuuuData = {}
	end

	if not localData.levelTotalPlayed then
		localData.levelTotalPlayed = {}
	end
	
	self.localData = localData
	self.fuuuFileKey = fuuuFileKey
end

function FUUUManager:onGameStart(levelId)
	local played = self:getLevelTotalPlayed(levelId)
	self.localData.levelTotalPlayed[tostring(levelId)] = played + 1
	
	Localhost:writeToStorage( self.localData , self.fuuuFileKey )
end

function FUUUManager:getLevelTotalPlayed(levelId)
	return tonumber(self.localData.levelTotalPlayed[tostring(levelId)]) or 0
end

function FUUUManager:onGameDefiniteFinish(result , gameBoardLogic)

	self:clearDCTimesInLevel()

	if not gameBoardLogic then
		return
	end

	local originLevelScore = UserManager:getInstance():getUserScore(gameBoardLogic.level)
	local hasFirstPassLevel = true
	if not originLevelScore or not originLevelScore.star or originLevelScore.star <= 1 then
		hasFirstPassLevel = false
	end

	
	if not self.localData.gameFailedLog["level"..gameBoardLogic.level] then
		local failCountBeforPass = {count = 0 , count2 = 0 , lock = false}
		self.localData.gameFailedLog["level"..gameBoardLogic.level] = 
			{	
				continuousFailures=0,
				continuousFailuresForGuide=0,
				historyMaxContinuousFailures=0,
				failCountBeforPass = failCountBeforPass
			}
	end

	local failData = self.localData.gameFailedLog["level"..gameBoardLogic.level]

	if not failData.failCountBeforPass then
		local failCountBeforPass = {count = 0 , count2 = 0 , lock = false}

		if not hasFirstPassLevel then
			failCountBeforPass.count = failData.continuousFailures
		end
		failData.failCountBeforPass = failCountBeforPass
	end

	if result then
		failData.continuousFailures = 0
		for k,v in pairs(self.localData.gameFailedLog) do
			if k ~= "level" .. gameBoardLogic.level then
				local needClearLevel = tonumber( string.sub( k , 6 ) )

				if needClearLevel then
					self:clearContinuousFailuresForGuide( needClearLevel )
				end
			end
		end

		if failData.failCountBeforPass then
			failData.failCountBeforPass.lock = true
		end
	else
		local cf = failData.continuousFailures
		failData.continuousFailures = failData.continuousFailures + 1

		if not failData.continuousFailuresForGuide then
			failData.continuousFailuresForGuide = 0
		end

		if self.mainLogic and not self.mainLogic.passFailedCount then
			failData.continuousFailuresForGuide = failData.continuousFailuresForGuide + 1
		end

		if failData.continuousFailures > failData.historyMaxContinuousFailures then
			failData.historyMaxContinuousFailures = failData.continuousFailures
		end

		if failData.failCountBeforPass and not failData.failCountBeforPass.lock then

			if not hasFirstPassLevel then --没有首次通关
				failData.failCountBeforPass.count = failData.failCountBeforPass.count + 1
				failData.failCountBeforPass.count2 = failData.failCountBeforPass.count2 + 1
			end
		end
	end

	Localhost:writeToStorage( self.localData , self.fuuuFileKey )

	self.isGameRunning = false
	wukongCastingCount = 0 
    wukongLastGuideCastingCount = -1
end

function FUUUManager:clearContinuousFailuresForGuide(level , needFlush)
	if level then level = tostring(level) end
	if self.localData and self.localData.gameFailedLog then
		if not self.localData.gameFailedLog["level"..level] then
			self.localData.gameFailedLog["level"..level] = {continuousFailures=0,continuousFailuresForGuide=0,historyMaxContinuousFailures=0}
		end

		local failData = self.localData.gameFailedLog["level"..level]
		failData.continuousFailuresForGuide = 0

		if needFlush then
			Localhost:writeToStorage( self.localData , self.fuuuFileKey )

			if self.mainLogic then
				self.mainLogic.passFailedCount = true
			end
		end
	end
end

function FUUUManager:update(GameMode)

	self.gameMode = GameMode
	self.mainLogic = self.gameMode.mainLogic

	if self.isGameRunning then
		self:onGameDefiniteFinish(false,self.mainLogic)
		self.isGameRunning = true
	else
		self.isGameRunning = true
	end
end

function FUUUManager:getTargetIconByFuuuType( key1 , key2  )

	--printx( 1 , "   FUUUManager:getTargetIconByFuuuType  " , key1 , key2  )

	if key1 == "order1" or key1 == "order2" or key1 == "order3" 
		or key1 == "order4" or key1 == "order5" or key1 == "order6" then
		return LevelTargetAnimationOrder:createIcon( key1 , key2 )

	elseif key1 == "drop" then
		local fullname = LevelTargetAnimationDrop:getIconFullName( key1 , 0 )
		return LevelTargetAnimationOrder:createIcon( nil , nil , nil , nil , fullname )
	elseif key1 == "order_lotus" then
		return LevelTargetAnimationOrder:createIcon( key1 , 1 )
	elseif key1 == "ice" then
		local fullname = LevelTargetAnimationIce:getIconFullName( key1, 1 )
		return LevelTargetAnimationOrder:createIcon( nil , nil , nil , nil , fullname )
	elseif key1 == "dig_move" then
		local fullname = LevelTargetAnimationDigMove:getIconFullName( key1, 1 )
		return LevelTargetAnimationOrder:createIcon( nil , nil , nil , nil , fullname )
	end
end

function FUUUManager:lastGameIsFUUU(needDCLog , gameDefiniteFinish)

	if not self.mainLogic then
		return false
	end

	local result = false

	local gameModeType = nil
	local progressStr = ""
	local progressData = {}
	local gameModeType = 0

	local fuuu_orderList = {}
	local fuuu_orderMap = {}

	local fuuu_animal = nil--动物	仅剩1-6动物未消除
	local fuuu_snow = nil--雪块	仅剩2个及以下一层/两层雪块未消除
	local fuuu_coin = nil--银币	仅剩5个及以下银币未消除
	local fuuu_blackfurry = nil--黑色毛球	仅剩1个黑色毛球未消除
	local fuuu_venom = nil--毒液	仅剩2个及以下毒液未消除
	local fuuu_specialpower = nil--特效 仅剩2个特效未消除
	local fuuu_swappower = nil--特效交换 仅剩1个特效交换未达成 
	local fuuu_snail = nil--蜗牛	仅剩1只蜗牛未收集
	local fuuu_honey = nil--蜂蜜	蜂蜜距离过关目标差距数量小于等于3
	local fuuu_sand = nil--流沙	仅剩3块及以下流沙未消除 
	local fuuu_greyfurry = nil--灰色毛球	距离目标剩余2个灰色毛球 关卡中有至少2个灰色毛球
	local fuuu_brownfurry = nil--褐色毛球	距离目标剩余1个褐色毛球 关卡中有至少1个褐色毛球
	local fuuu_seaanimal = nil--海洋生物	仅剩1只海洋生物未收集
	local fuuu_magicstone = nil --魔法石	距离目标剩余2个魔法石
	local fuuu_balloon = nil--气球	距离目标剩余2个气球
	local fuuu_cutebean = nil --萌豆  距离目标剩余2个萌豆，层数不限 
	local fuuu_tympaniafish = nil --气鼓鱼  距离目标剩余2个气鼓鱼，1级的数量≤1
	local fuuu_blockerCover = nil --小叶堆  距离目标剩余2个及以下小叶堆未消除
	local fuuu_blockerCoverMaterial = nil --小树桩	距离目标剩余3层及以下小树桩未消除
	local fuuu_blocker195 = nil --星星瓶 仅剩1个星星瓶未收集
	local fuuu_chameleon = nil --变色龙 距离目标剩余3个变色龙未消除
	local fuuu_pacman = nil --吃豆人 距离目标剩余1个吃豆人未消除
	local fuuu_ghost = nil --幽灵 距离目标剩余1个幽灵未消除
	local fuuu_squid = nil --鱿鱼 距离目标剩余1个鱿鱼未消除
	local fuuu_milk = nil --奶油 距离目标剩余3个

	if self.gameMode and self.mainLogic then

		gameModeType = self.mainLogic.theGamePlayType

		local getFuuuData = function(itemType , diff)
			local fuuu = nil

			if itemType == 1 then
				if not fuuu_animal then
					fuuu_animal = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_animal"}
				end
				fuuu = fuuu_animal
			elseif itemType == 2 then
				if not fuuu_snow then
					fuuu_snow = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_snow"}
				end
				fuuu = fuuu_snow
			elseif itemType == 3 then
				if not fuuu_coin then
					fuuu_coin = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_coin"}
				end
				fuuu = fuuu_coin
			elseif itemType == 4 then
				if not fuuu_blackfurry then
					fuuu_blackfurry = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_blackfurry"}
				end
				fuuu = fuuu_blackfurry
			elseif itemType == 5 then
				if not fuuu_venom then
					fuuu_venom = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_venom"}
				end
				fuuu = fuuu_venom
			elseif itemType == 6 then
				if not fuuu_specialpower then
					fuuu_specialpower = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_specialpower"}
				end
				fuuu = fuuu_specialpower
			elseif itemType == 7 then
				if not fuuu_swappower then
					fuuu_swappower = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_swappower"}
				end
				fuuu = fuuu_swappower
			elseif itemType == 8 then
				if not fuuu_snail then
					fuuu_snail = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_snail"}
				end
				fuuu = fuuu_snail
			elseif itemType == 9 then
				if not fuuu_honey then
					fuuu_honey = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_honey"}
				end
				fuuu = fuuu_honey
			elseif itemType == 10 then
				if not fuuu_sand then
					fuuu_sand = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_sand"}
				end
				fuuu = fuuu_sand
			elseif itemType == 11 then
				if not fuuu_greyfurry then
					fuuu_greyfurry = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_greyfurry"}
				end
				fuuu = fuuu_greyfurry
			elseif itemType == 12 then
				if not fuuu_brownfurry then
					fuuu_brownfurry = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_brownfurry"}
				end
				fuuu = fuuu_brownfurry
			elseif itemType == 13 then
				if not fuuu_seaanimal then
					fuuu_seaanimal = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_seaanimal"}
				end
				fuuu = fuuu_seaanimal
			elseif itemType == 14 then
				if not fuuu_magicstone then
					fuuu_magicstone = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_magicstone"}
				end
				fuuu = fuuu_magicstone
			elseif itemType == 15 then
				if not fuuu_balloon then
					fuuu_balloon = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_balloon"}
				end
				fuuu = fuuu_balloon
			elseif itemType == 16 then
				if not fuuu_cutebean then
					fuuu_cutebean = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_bean"}
				end
				fuuu = fuuu_cutebean
			elseif itemType == 17 then
				if not fuuu_tympaniafish then
					fuuu_tympaniafish = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_fish"}
				end
				fuuu = fuuu_tympaniafish
			elseif itemType == 18 then
				if not fuuu_blockerCover then
					fuuu_blockerCover = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_leaf"}
				end
				fuuu = fuuu_blockerCover
			elseif itemType == 19 then
				if not fuuu_blockerCoverMaterial then
					fuuu_blockerCoverMaterial = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_treestunmp"}
				end
				fuuu = fuuu_blockerCoverMaterial
			elseif itemType == 20 then
				if not fuuu_blocker195 then
					fuuu_blocker195 = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_blocker195"}
				end
				fuuu = fuuu_blocker195
			elseif itemType == 21 then
				if not fuuu_chameleon then
					fuuu_chameleon = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_chameleon"}
				end
				fuuu = fuuu_chameleon
			elseif itemType == 22 then
				if not fuuu_pacman then
					fuuu_pacman = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_pacman"}
				end
				fuuu = fuuu_pacman
			elseif itemType == 23 then
				if not fuuu_ghost then
					fuuu_ghost = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_ghost"}
				end
				fuuu = fuuu_ghost
			elseif itemType == 24 then
				if not fuuu_squid then
					fuuu_squid = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_squid"}
				end
				fuuu = fuuu_squid
			elseif itemType == 25 then
				if not fuuu_milk then
					fuuu_milk = {cv=0,tv=0,diff=diff,ty="stage_end_fuuu_milk"}
				end
				fuuu = fuuu_milk
			end

			fuuu.orderTargetId = itemType

			if not fuuu_orderMap[fuuu.ty] then
				table.insert( fuuu_orderList , fuuu )
				fuuu_orderMap[fuuu.ty] = true
			end

			return fuuu
		end

		local updateFuuuData = function(fuuu , orderdata)
			fuuu.tv = fuuu.tv + orderdata.v1
			if orderdata.f1 > orderdata.v1 then
				fuuu.cv = fuuu.cv + orderdata.v1
			else
				fuuu.cv = fuuu.cv + orderdata.f1
			end
		end

		local countOrderFuuu = function(theOrderList)
			
			local i,v

			for i,v in ipairs(theOrderList) do

    			local fuuuData = nil
    			if v.key1 == GameItemOrderType.kAnimal then
    				fuuuData = getFuuuData(1,6)
    				if not fuuuData.childList then
    					fuuuData.childList = {}
    				end
    				table.insert(fuuuData.childList , {k2=v.key2 , cv=v.f1 , tv=v.v1})

    				if fuuuData then
    					fuuuData.okey1 = "order1"
    					--fuuuData.okey2 = v.key2
    				end
    			elseif v.key1 == GameItemOrderType.kSpecialBomb then
    				fuuuData = getFuuuData(6,2)
    				if not fuuuData.childList then
    					fuuuData.childList = {}
    				end
    				table.insert(fuuuData.childList , {k2=v.key2 , cv=v.f1 , tv=v.v1})

    				if fuuuData then
    					fuuuData.okey1 = "order2"
    					--fuuuData.okey2 = v.key2
    				end
    			elseif v.key1 == GameItemOrderType.kSpecialSwap then
    				fuuuData = getFuuuData(7,1)
    				if not fuuuData.childList then
    					fuuuData.childList = {}
    				end
    				table.insert(fuuuData.childList , {k2=v.key2 , cv=v.f1 , tv=v.v1})
    				
    				if fuuuData then
    					fuuuData.okey1 = "order3"
    					--fuuuData.okey2 = v.key2
    				end
    			elseif v.key1 == GameItemOrderType.kSpecialTarget then
    				
    				if v.key2 == GameItemOrderType_ST.kSnowFlower then
    					fuuuData = getFuuuData(2,2)
    				elseif v.key2 == GameItemOrderType_ST.kCoin then
    					fuuuData = getFuuuData(3,5)
    				elseif v.key2 == GameItemOrderType_ST.kVenom then
    					fuuuData = getFuuuData(5,2)
    				elseif v.key2 == GameItemOrderType_ST.kSnail then
    					fuuuData = getFuuuData(8,1)
    				elseif v.key2 == GameItemOrderType_ST.kGreyCuteBall then
    					fuuuData = getFuuuData(11,2)
    				elseif v.key2 == GameItemOrderType_ST.kBrownCuteBall then
    					fuuuData = getFuuuData(12,1)
    				elseif v.key2 == GameItemOrderType_ST.kBottleBlocker then
    					fuuuData = getFuuuData(16,2)
    				end
    				
    				if fuuuData then
    					fuuuData.okey1 = "order4"
    					fuuuData.okey2 = v.key2
    				end
    			elseif v.key1 == GameItemOrderType.kOthers then
    				
    				if v.key2 == GameItemOrderType_Others.kBalloon then
    					fuuuData = getFuuuData(15,2)
    				elseif v.key2 == GameItemOrderType_Others.kBlackCuteBall then
    					fuuuData = getFuuuData(4,1)
    				elseif v.key2 == GameItemOrderType_Others.kHoney then
    					fuuuData = getFuuuData(9,3)
    				elseif v.key2 == GameItemOrderType_Others.kSand then
    					fuuuData = getFuuuData(10,3)
    				elseif v.key2 == GameItemOrderType_Others.kMagicStone then
    					fuuuData = getFuuuData(14,2)
    				elseif v.key2 == GameItemOrderType_Others.kBoomPuffer then
    					fuuuData = getFuuuData(17,2)
    				elseif v.key2 == GameItemOrderType_Others.kBlockerCover then
    					fuuuData = getFuuuData(18,2)
    				elseif v.key2 == GameItemOrderType_Others.kBlockerCoverMaterial then
    					fuuuData = getFuuuData(19,3)
    				elseif v.key2 == GameItemOrderType_Others.kBlocker195 then
    					fuuuData = getFuuuData(20,1)
    				elseif v.key2 == GameItemOrderType_Others.kChameleon then
    					fuuuData = getFuuuData(21,3)
    				elseif v.key2 == GameItemOrderType_Others.kPacman then
    					fuuuData = getFuuuData(22,1)
    				elseif v.key2 == GameItemOrderType_Others.kGhost then
    					fuuuData = getFuuuData(23,1)
    				elseif v.key2 == GameItemOrderType_Others.kSquid then
    					fuuuData = getFuuuData(24,1)
    				elseif v.key2 == GameItemOrderType_Others.kMilks then
    					fuuuData = getFuuuData(25,3)
    				end
    				
    				if fuuuData then
    					fuuuData.okey1 = "order5"
    					fuuuData.okey2 = v.key2
    				end
    			elseif v.key1 == GameItemOrderType.kSeaAnimal then
    				--海洋生物	仅剩1只海洋生物未收集

    				fuuuData = getFuuuData(13,1)
    				if not fuuuData.childList then
    					fuuuData.childList = {}
    				end
    				table.insert(fuuuData.childList , {k2=v.key2 , cv=v.f1 , tv=v.v1})

    				if fuuuData then
    					fuuuData.okey1 = "order6"
    					--fuuuData.okey2 = v.key2
    				end
    			end

    			if fuuuData then
    				updateFuuuData(fuuuData , v)
    			end
    		end

    		local doneNum = 0
    		local fuuuNum = 0
    		local unDoneNum = 0
    		for i,v in ipairs(fuuu_orderList) do
    			-- printx( 1 , "   v.tv = " .. tostring(v.tv) .. "   v.cv = " .. tostring(v.cv))
    			if v.cv >= v.tv then
    				v.isDone = true
    				v.isFuuuDone = true
    				doneNum = doneNum + 1
    			elseif v.cv + v.diff >= v.tv then
    				v.isFuuuDone = true
    				fuuuNum = fuuuNum + 1
    			else
    				v.isFuuuDone = false
    				unDoneNum = unDoneNum + 1
    			end
				
				progressStr = progressStr 
    					.. tostring(v.ty) .. "*" 
    					.. tostring(v.cv) .. "*" 
    					.. tostring(v.tv) .. "*" 
    					.. tostring(v.isFuuuDone)

    			local _data = {}
    			_data.okey1 = v.okey1
    			_data.okey2 = v.okey2
    			_data.ty = v.ty
    			_data.cv = v.cv
    			_data.tv = v.tv
    			_data.isFuuuDone = v.isFuuuDone
    			_data.isDone = v.isDone
    			_data.orderTargetId = v.orderTargetId
    			table.insert( progressData , _data )

    			if v.ty == "stage_end_fuuu_animal" 
    				or v.ty == "stage_end_fuuu_seaanimal" 
    				or v.ty == "stage_end_fuuu_specialpower" 
    				or v.ty == "stage_end_fuuu_swappower" 
    				then
    				if v.childList then
    					_data.cld = {}
    					for j,k in ipairs(v.childList) do
    						progressStr = progressStr .. "*" .. k.k2 .. "_" .. k.cv .. "_" .. k.tv
    						local _data2 = {}
    						_data2.k2 = k.k2
			    			_data2.cv = k.cv
			    			_data2.tv = k.tv
			    			table.insert( _data.cld , _data2 )
    					end
    				end
    				progressStr = progressStr .. ";"
    			else
    				progressStr = progressStr .. ";"
    			end    			
    		end

    		local conutResult = false
    		if unDoneNum <= 0 then

    			if fuuuNum == 1 and doneNum == 0 then
    				conutResult = true
    			elseif fuuuNum <= doneNum then
    				conutResult = true
    			end
    			
    		end

    		return conutResult
		end

		local function buildData(ty , cv , tv)
			local _data = {}
			_data.ty = ty
			_data.cv = cv
			_data.tv = tv
			_data.isFuuuDone = true
			_data.isDone = false

			table.insert( progressData , _data )

			return _data
		end
		

    	if gameModeType == GameModeTypeId.CLASSIC_MOVES_ID then		----步数模式==========

    		if self.mainLogic.scoreTargets then
    			
    			if tonumber(self.mainLogic.totalScore / self.mainLogic.scoreTargets[1]) > 0.95 then
					result = true
				end
				local _data = buildData( "stage_end_fuuu_step" , self.mainLogic.totalScore , self.mainLogic.scoreTargets[1] , result)
				_data.orderTargetId = 100
				progressStr = "stage_end_fuuu_step;" .. tostring(self.mainLogic.totalScore) .. "*" .. tostring(self.mainLogic.scoreTargets[1])
			end

    	elseif gameModeType == GameModeTypeId.DROP_DOWN_ID then		----掉落模式==========
    		
    		if self.mainLogic.ingredientsTotal - self.mainLogic.ingredientsCount <= 1 then
    			result = true
    		end
    		local _data = buildData( "stage_end_fuuu_drop" , self.mainLogic.ingredientsCount , self.mainLogic.ingredientsTotal , result )
			_data.orderTargetId = 101
			_data.okey1 = "drop"
			--_data.okey2 = ""
    		progressStr = "stage_end_fuuu_drop;" .. tostring(self.mainLogic.ingredientsCount) .. "*" .. tostring(self.mainLogic.ingredientsTotal)

    	elseif gameModeType == GameModeTypeId.LIGHT_UP_ID then			----冰层消除模式======
    		--printx( 1 , "    GameModeTypeId.LIGHT_UP_ID   kLightUpLeftCount = " .. tostring(self.mainLogic.kLightUpLeftCount))
    		
    		if self.mainLogic.kLightUpLeftCount <= 2 then
    			result = true
    		end
    		local _data = buildData( "stage_end_fuuu_ice" , self.mainLogic.kLightUpTotal - self.mainLogic.kLightUpLeftCount , self.mainLogic.kLightUpTotal , result)
			_data.orderTargetId = 102
			_data.okey1 = "ice"
    		progressStr = "stage_end_fuuu_ice;" .. tostring(self.mainLogic.kLightUpTotal - self.mainLogic.kLightUpLeftCount) .. "*" .. tostring(self.mainLogic.kLightUpTotal)

    	elseif gameModeType == GameModeTypeId.DIG_MOVE_ID then			----步数挖地模式======
    		
    		if self.mainLogic.digJewelLeftCount <= 3 then
    			result = true
    		end
    		local _data = buildData( "stage_end_fuuu_dig" , self.mainLogic.digJewelTotalCount - self.mainLogic.digJewelLeftCount  , self.mainLogic.digJewelTotalCount , result )
			_data.orderTargetId = 103
			_data.okey1 = "dig_move"
    		progressStr = "stage_end_fuuu_dig;" .. tostring(self.mainLogic.digJewelLeftCount) .. "*" .. tostring(self.mainLogic.digJewelTotalCount)

    	elseif gameModeType == GameModeTypeId.ORDER_ID then  			----订单模式
    		progressStr = "stage_end_fuuu_order;"
    		result = countOrderFuuu(self.mainLogic.theOrderList)

    	elseif gameModeType == GameModeTypeId.DIG_TIME_ID then     ----时间挖地模式
    		result = false
    	elseif gameModeType == GameModeTypeId.CLASSIC_ID then     ----时间模式
    		
    		if self.mainLogic.scoreTargets then
    			if tonumber(self.mainLogic.totalScore / self.mainLogic.scoreTargets[1]) > 0.95 then
					result = true
				end
			end
			local _data = buildData( "stage_end_fuuu_step_time" , self.mainLogic.totalScore  , self.mainLogic.scoreTargets[1] , result)
			_data.orderTargetId = 104
			progressStr = "stage_end_fuuu_step_time;" .. tostring(self.mainLogic.totalScore) .. "*" .. tostring(self.mainLogic.scoreTargets[1])

    	elseif gameModeType == GameModeTypeId.DIG_MOVE_ENDLESS_ID 
    		or gameModeType == GameModeTypeId.MAYDAY_ENDLESS_ID
    		or gameModeType == GameModeTypeId.RABBIT_WEEKLY_ID
    		or gameModeType == GameModeTypeId.HALLOWEEN_ID
    		or gameModeType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
    	then ----无限挖地模式
    		result = false
    	elseif gameModeType == GameModeTypeId.SEA_ORDER_ID then
    		progressStr = "stage_end_fuuu_sea_order;"
    		result = countOrderFuuu(self.mainLogic.theOrderList)
    		
    	elseif gameModeType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
    		
    		if self.mainLogic.ingredientsTotal - self.mainLogic.ingredientsCount <= 1 then
    			result = true
    		end
    		local _data = buildData( "stage_end_fuuu_dig_unlock" , self.mainLogic.ingredientsCount  , self.mainLogic.ingredientsTotal , result )
    		_data.orderTargetId = 105
    		progressStr = "stage_end_fuuu_dig_unlock;" .. tostring(self.mainLogic.ingredientsCount) .. "*" .. tostring(self.mainLogic.ingredientsTotal)
    	elseif gameModeType == GameModeTypeId.LOTUS_ID then
    		if self.mainLogic.currLotusNum <= 2 then
    			result = true
    		end
    		
    		local _data = buildData( "stage_end_fuuu_pond" , self.mainLogic.destroyLotusNum , self.mainLogic.destroyLotusNum + self.mainLogic.currLotusNum , result)
			_data.orderTargetId = 106
			_data.okey1 = kLevelTargetType.order_lotus
    		progressStr = "stage_end_fuuu_pond;".. tostring(self.mainLogic.currLotusNum)
    	end

	end

	local uid = UserManager.getInstance().uid
	local ntime = Localhost:timeInSec()
	local currLevelId = self.mainLogic.level

	if not self.dcTimesInLevel then
		self.dcTimesInLevel = 0
		self.firstDCTime = Localhost:timeInSec()
	end

	local fuuuLogID = tostring(uid) .. "_" .. tostring(self.firstDCTime) .. "_" .. tostring(self.dcTimesInLevel)

	if needDCLog then
		
		self.dcTimesInLevel = self.dcTimesInLevel + 1
		fuuuLogID = tostring(uid) .. "_" .. tostring(self.firstDCTime) .. "_" .. tostring(self.dcTimesInLevel)

		printx( 1 , "   FUUUManager:lastGameIsFUUU   fuuuLogID = " .. tostring(fuuuLogID) .. 
			"   level = " .. tostring(self.mainLogic.level) .. 
			"   gameModeType = "  .. tostring(gameModeType) .. 
			"   result = " .. tostring(result) .. 
			"      progressStr = " .. tostring(progressStr))
		
		DcUtil:gameFailedFuuu( fuuuLogID , self.mainLogic.level , gameModeType , result , progressStr , self.mainLogic.totalScore , gameDefiniteFinish )

		self.lastFuuuLogID = fuuuLogID
		
	end

	if gameDefiniteFinish then
		self:clearDCTimesInLevel()
		self:clearLastFuuuID()
	end

	--printx( 1 , "   FUUUUUUUUUUUUUUUUU  " , table.tostring( progressData ))

	--[[
	if not self.localData.fuuuData[fuuuLogID] then
		local fuuulocaldata = {}
		fuuulocaldata.id = fuuuLogID
		fuuulocaldata.level = self.mainLogic.level
		fuuulocaldata.gameMode = gameModeType
		fuuulocaldata.result = result
		fuuulocaldata.progressStr = progressStr
		fuuulocaldata.score = self.mainLogic.totalScore
		fuuulocaldata.definite_failed = gameDefiniteFinish
		self.localData.fuuuData[fuuuLogID] = fuuulocaldata

		Localhost:writeToStorage( self.localData , self.fuuuFileKey )
	end
	]]
	self.localData.fuuuData = {}

	return result , fuuuLogID , progressData
end

function FUUUManager:clearDCTimesInLevel()
	self.dcTimesInLevel = nil
	self.firstDCTime = nil
end

function FUUUManager:getLastGameFuuuID()
	return self.lastFuuuLogID
end

function FUUUManager:getFuuuDataByID(fuuuId)
	if fuuuId and self.localData and self.localData.fuuuData then
		return self.localData.fuuuData[fuuuId]
	end
	return nil
end

function FUUUManager:clearLastFuuuID()
	self.lastFuuuLogID = nil
end

function FUUUManager:getLevelContinuousFailNum(levelId)
	if self.localData.gameFailedLog["level"..levelId] then
		return self.localData.gameFailedLog["level"..levelId].continuousFailures
	end
	return 0
end

function FUUUManager:getLevelHistoryMaxContinuousFailuresNum(levelId)
	if self.localData.gameFailedLog["level"..levelId] then
		return self.localData.gameFailedLog["level"..levelId].historyMaxContinuousFailures
	end
	return 0
end

function FUUUManager:getLevelContinuousFailNumForGuide(levelId)
	if self.localData.gameFailedLog["level"..levelId] then
		return self.localData.gameFailedLog["level"..levelId].continuousFailuresForGuide
	end
	return 0
end

function FUUUManager:getLevelFailNumBeforeFirstPass(levelId)
	if self.localData.gameFailedLog["level"..levelId] then

		local data = self.localData.gameFailedLog["level"..levelId]

		if data.failCountBeforPass then 
			return data.failCountBeforPass.count , data.failCountBeforPass.count2
		end
	end
	return 0 , 0
end

function FUUUManager:setDailyData(data)
	self.localData.dailyData = data
	Localhost:writeToStorage( self.localData , self.fuuuFileKey )
end

function FUUUManager:getDailyData()
	return self.localData.dailyData
end

FUUUManager:init()