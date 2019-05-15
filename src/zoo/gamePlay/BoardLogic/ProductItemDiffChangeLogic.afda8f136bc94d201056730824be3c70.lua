ProductItemDiffChangeLogic = {}

ProductItemDiffChangeMode = {
	kNone = 0 ,
	kDropEff = 1 ,
	kDropEffAndBird = 2 ,
	kAddColor = 3 ,
	kAIAddColor = 4 ,
	kAICoreAddColor = 5,
}

local testConfig = {

				--ruleA 每次掉落一个有颜色的元素时，如果本回合已经掉落的目标色（C色）小于等于n，则有m的概率将其强行变为目标色（C色）
				ruleA_n1 = 3,
				ruleA_m1 = 70,
				ruleA_n2 = 5,
				ruleA_m2 = 65,
				ruleA_n3 = 10,
				ruleA_m3 = 60,
				ruleA_n4 = 9999,
				ruleA_m4 = 50,

				--ruleB 单个掉落口，每掉落n个元素，目标色（C色）的数量不超过m个
				ruleB_n1 = 5,
				ruleB_m1 = 5,
				ruleB_n2 = 10,
				ruleB_m2 = 7,
				ruleB_n3 = 15,
				ruleB_m3 = 10,
				ruleB_n4 = 20,
				ruleB_m4 = 15,

				--ruleC 全局掉落口，最近n步之内，目标色（C色）的干预次数不超过m个
				ruleC_n1 = 1,
				ruleC_m1 = 20,
				ruleC_n2 = 2,
				ruleC_m2 = 30,
				ruleC_n3 = 3,
				ruleC_m3 = 40,
				ruleC_n4 = 5,
				ruleC_m4 = 9999,
			}

require "zoo.gamePlay.config.ProductItemDiffChangeFalsifyConfig"
local FalsifyConfig = nil
local defaultLevelLeftMovesAdjust = 5
local AIColorAdjustRate_firstStep = 0.2
local AIColorAdjustRate_secondStep = 0.3
local AIColorAdjustRate_thirdStep = 0.55
local AIColorAdjustRate_default = 0.55

ProductItemDiffChangeLogic.modes = {}

function ProductItemDiffChangeLogic:getModeName(mode)

	local nameStr = "未知"
	if mode == 0 then
		nameStr = "默认不修正"
	elseif mode == 1 then
		nameStr = "全局随机掉落特效"
	elseif mode == 2 then
		nameStr = "全局随机掉落特效和魔力鸟"
	elseif mode == 3 then
		nameStr = "全局增加单色概率"
	elseif mode == 4 then
		nameStr = "智能增加单色概率"
	end

	return nameStr
end

function ProductItemDiffChangeLogic:getDataVerName(dataVer)

	local nameStr = ""
	if dataVer == 0 then
		nameStr = ""
	elseif dataVer == 1 then
		nameStr = "（弱）"
	elseif dataVer == 2 then
		nameStr = "（普通）"
	elseif dataVer == 3 then
		nameStr = "（强）"
	end

	return nameStr
end

function ProductItemDiffChangeLogic:testUseOldVersion()

	--[[
	if self.useOldVersion then
		self.useOldVersion = false
	else
		self.useOldVersion = true
	end
	
	CommonTip:showTip( "使用旧版addColor逻辑 " .. tostring(self.useOldVersion) , "negative", nil, 3)
	]]
end

function ProductItemDiffChangeLogic:testChangeMode()

	if not __WIN32 then
		return
	end

	if not self.modes[1] then self.modes[1] = {} end

	local modeData = self.modes[1]

	if not modeData.mode then modeData.mode = 0 end

	if not modeData.dataVer then modeData.dataVer = 0 end

	if modeData.mode == 0 then
		modeData.dataVer = modeData.dataVer + 3
	else
		modeData.dataVer = modeData.dataVer + 1
	end

	if modeData.dataVer > 3 then

		modeData.dataVer = 1

		if modeData.mode == 0 then
			modeData.mode = 3
		else
			modeData.mode = modeData.mode + 1
		end
		

		if modeData.mode > 4 then
			modeData.mode = 0
			modeData.dataVer = 3
		end
	end

	local str = self:getDataVerName(modeData.dataVer) 
	if modeData.mode == 0 then
		str = ""
	end

	CommonTip:showTip( self:getModeName(modeData.mode) .. str .. " Actived" , "negative", nil, 3)

	LevelDifficultyAdjustManager:updateCurrStrategyID( {mode = modeData.mode , ds = modeData.dataVer} , nil )

end

function ProductItemDiffChangeLogic:addMode( mode , dataVer )

	for k,v in ipairs(self.modes) do
		if v.mode == mode then
			return
		end
	end

	local modeData = {}
	modeData.mode = mode
	modeData.dataVer = dataVer

	table.insert( self.modes , modeData )

end

function ProductItemDiffChangeLogic:getCurrDS()
	return self.currds
end

function ProductItemDiffChangeLogic:setCurrDS(value)
	self.currds = value
end

function ProductItemDiffChangeLogic:changeMode( mode , dataVer )
	-- printx( 1 , "ProductItemDiffChangeLogic:changeMode  ~~~~~~~~~~~~~~~~~~~~~~~  mode , dataVer =" , mode , dataVer )

	local oldMode = nil
	local oldDtaVer = nil

	for k,v in ipairs(self.modes) do
		if v.mode == mode then
			oldMode = mode
			oldDtaVer = v.dataVer
			break
		end
	end

	local dataHasChanged = true

	if mode == oldMode and dataVer == oldDtaVer then
		dataHasChanged = false
	else
		--仅在数据变化时才设置
		self.modes = {} -- 永远清空，不再支持同时激活多mode的情况
		self.aiCareMode = nil
		self:addMode( mode , dataVer )
	end

	return dataHasChanged
	
	--[[
	local modedata = nil

	for k,v in ipairs(self.modes) do
		if v.mode == mode then
			modedata = v
			break
		end
	end

	if modedata then
		modedata.mode = mode
		modedata.dataVer = dataVer
	else
		self:addMode( mode , dataVer )
	end
	]]
end

function ProductItemDiffChangeLogic:removeMode( mode )
	local idx = nil
	for k,v in ipairs(self.modes) do
		if v.mode == mode then
			idx = k
			break
		end
	end

	if idx then
		return table.remove( self.modes , idx )
	end
end

function ProductItemDiffChangeLogic:removeModeByIndex( idx )
	if idx <= #self.modes then
		return table.remove( self.modes , idx )
	end
end

function ProductItemDiffChangeLogic:getMode()
	if not self.mode then self.mode = 0 end

	return self.mode
end

function ProductItemDiffChangeLogic:onBoardStableHandler(mainLogic)
	-- printx( 1 , "ProductItemDiffChangeLogic:onBoardStableHandler  #self.modes =" , #self.modes)
	if mainLogic and self.modes and #self.modes > 0 then

		self.currStepColorNumMap = {}

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if item and item.isUsed and not item.isEmpty and item.ItemType ~= GameItemType.kDrip and item:isColorful() then
					if item._encrypt.ItemColorType ~= AnimalTypeConfig.kNone then

						local colorIndex = AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType )

						if colorIndex and self.context.availableColorList[colorIndex] then

							if not self.currStepColorNumMap[ colorIndex ] then
								self.currStepColorNumMap[ colorIndex ] = 0
							end

							self.currStepColorNumMap[ colorIndex ] = self.currStepColorNumMap[ colorIndex ] + 1
						end
						
					end
				end
			end
		end

		self.currStepColorNumMap[0] = 0

		-- printx( 1 , "ProductItemDiffChangeLogic:onBoardStableHandler --------------  self.currStepColorNumMap =" , table.tostring(self.currStepColorNumMap) )
		LevelDifficultyAdjustManager:getDAManager():setColorCountMap( self.currStepColorNumMap )

		if table.includes(self.modes, ProductItemDiffChangeMode.kAICoreAddColor) then return end

		local result , fuuuLogID , progressData = FUUUManager:lastGameIsFUUU(false , false)

		if progressData then
			--printx( 1 , "AnimalStageInfo:addPropsUsedInLevel  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! propId" , propId )
			--printx( 1 , table.tostring(progressData) )

			local tarMap = {}

			for k,v in ipairs(progressData) do
				if v.orderTargetId then
					if v.cld then
						--printx(1 , "FUCK          v  = " , table.tostring(v))
						for k2,v2 in ipairs(v.cld) do

							local tp = {}

							tp.orderTargetId = v.orderTargetId * 100 + v2.k2
							tp.cv = v2.cv or 0
							tp.tv = v2.tv or 0
							table.insert( tarMap , tp )
						end
					else
						local tp = {}

						tp.orderTargetId = v.orderTargetId * 100
						tp.cv = v.cv or 0
						tp.tv = v.tv or 0
						table.insert( tarMap , tp )
					end
				end
			end

			local levelId = mainLogic.level
			local costMove = mainLogic.realCostMoveWithoutBackProp

			local isReplay = false
			if mainLogic.replayMode == ReplayMode.kNormal 
				or mainLogic.replayMode == ReplayMode.kCheck 
				or mainLogic.replayMode == ReplayMode.kStrategy 
				or mainLogic.replayMode == ReplayMode.kConsistencyCheck_Step2 
				or mainLogic.replayMode == ReplayMode.kResume 
				or mainLogic.replayMode == ReplayMode.kSectionResume 
				or mainLogic.replayMode == ReplayMode.kReview
				then
				isReplay = true
			end
			local staticProgressData , staticTotalSteps = LevelDifficultyAdjustManager:getLevelTargetProgressData( levelId , costMove , isReplay )
			if not staticProgressData then staticProgressData = {} end

			-- printx( 1 , "ProductItemDiffChangeLogic:onBoardStableHandler  costMove =" , costMove)
			-- printx( 1 , "++++++++++++++++++++ " , table.tostring(staticProgressData))

			
			local staticMove = mainLogic.staticLevelMoves
			local stepAdjust = LevelDifficultyAdjustManager:getLevelLeftMoves( levelId ) or defaultLevelLeftMovesAdjust

			--printx( 1 , "ProductItemDiffChangeLogic:onBoardStableHandler  costMove =" , costMove , "staticMove =" , staticMove , "stepAdjust = " ,stepAdjust)

			local tarNum = #tarMap
			local currStepRate = 0
			--local currStepStaticRate = (costMove - stepAdjust ) / (staticMove - stepAdjust)
			local currStepStaticMidRate = 0
			local currStepStaticLowRate = 0
			local currStepStaticMinRate = 0
			local rateDiff = 0
			

			-- printx(1 , "MMP #tarMap = " , #tarMap , table.tostring(tarMap))

			for k,v in ipairs(tarMap) do
				local targetId = v.orderTargetId

				if staticProgressData[ tostring(targetId) ] then
					local tdata = staticProgressData[ tostring(targetId) ]

					local mid = v.tv - tdata.mid --已搜集个数
					local low = v.tv - tdata.low --已搜集个数
					local min = nil
					if tdata.min then
						min = v.tv - tdata.min --已搜集个数
					end

					--[[
					if v.cv <= mid then

						local currv = v.cv - low
						if currv < 0 then currv = 0 end --如果用户的搜集数量连low都没达到，则取0

						local fr = 0
						if mid - low ~= 0 then
							fr = ( currv / (mid - low) ) or 0
						end
						printx(1,"FUCK  aaa   rateDiff =" , rateDiff , fr)
						rateDiff = rateDiff + fr

					else
						printx(1,"FUCK  bbb   rateDiff =" , rateDiff)
						rateDiff = rateDiff + 1
					end
					
					--]]

					local vp = tonumber( v.cv / v.tv )
					if vp > 1 then 
						vp = 1 
					elseif vp < 0 then
						vp = 0
					end
					currStepRate = currStepRate + vp

					local sp = tonumber( mid / v.tv )
					if sp > 1 then 
						sp = 1 
					elseif sp < 0 then
						sp = 0
					end
					currStepStaticMidRate = currStepStaticMidRate + sp

					sp = tonumber( low / v.tv )
					if sp > 1 then 
						sp = 1 
					elseif sp < 0 then
						sp = 0
					end
					currStepStaticLowRate = currStepStaticLowRate + sp

					if min then
						sp = tonumber( min / v.tv )
						if sp > 1 then 
							sp = 1 
						elseif sp < 0 then
							sp = 0
						end
						currStepStaticMinRate = currStepStaticMinRate + sp
					else
						currStepStaticMinRate = currStepStaticLowRate
					end
					
				end

				--[[
				local vp = tonumber( v.cv / v.tv )
				if vp > 1 then vp = 1 end
				currStepRate = currStepRate + vp
				]]
			end

			currStepRate = currStepRate / tarNum
			currStepStaticMidRate = currStepStaticMidRate / tarNum
			currStepStaticLowRate = currStepStaticLowRate / tarNum
			currStepStaticMinRate = currStepStaticMinRate / tarNum
			--rateDiff = rateDiff / tarNum

			self.currStepProgressData = {}
			self.currStepProgressData.currStepRate = currStepRate

			self.currStepProgressData.currStepStaticMidRate = currStepStaticMidRate
			self.currStepProgressData.currStepStaticLowRate = currStepStaticLowRate
			self.currStepProgressData.currStepStaticMinRate = currStepStaticMinRate

			--self.currStepProgressData.currStepStaticRate = self.currStepProgressData.currStepStaticMinRate

			--costMove
			local staticDataSwitchConfig = AIAddColorConfig.staticDataSwitch
			local _staticTotalSteps = staticTotalSteps or 10000

			for k,v in ipairs(staticDataSwitchConfig) do

				local rate = costMove / _staticTotalSteps
				if rate >= v.minMovesRate and rate <= v.maxMovesRate then

					if v.progressData == "mid" then
						self.currStepProgressData.currStepStaticRate = self.currStepProgressData.currStepStaticMidRate
					elseif v.progressData == "min" then
						self.currStepProgressData.currStepStaticRate = self.currStepProgressData.currStepStaticMinRate
					elseif v.progressData == "low" then
						self.currStepProgressData.currStepStaticRate = self.currStepProgressData.currStepStaticLowRate
					end
					
					-- printx( 1, "当前智能调整选择的期望线为：" ,v.progressData)
					break
				end
			end

			if not self.currStepProgressData.currStepStaticRate then
				self.currStepProgressData.currStepStaticRate = self.currStepProgressData.currStepStaticLowRate
			end
			

			if self.currStepProgressData.currStepStaticRate == 0 then
				self.currStepProgressData.rateDiff = 0
			else
				self.currStepProgressData.rateDiff = (self.currStepProgressData.currStepStaticRate - currStepRate) / self.currStepProgressData.currStepStaticRate
			end
			
			if self.currStepProgressData.rateDiff < 0 then self.currStepProgressData.rateDiff = 0 end

			self.currStepProgressData.isFuuu = result
			self.currStepProgressData.staticTotalSteps = staticTotalSteps

			-- printx( 1 , "=======================  ProductItemDiffChangeLogic:onBoardStableHandler =========================="  )
			-- printx( 1 , "realCostMoveWithoutBackProp:" , costMove  )
			-- printx( 1 , "currStepRate:" , currStepRate  )
			-- printx( 1 , "currStepStaticRate:" , self.currStepProgressData.currStepStaticRate  )
			-- printx( 1 , "rateDiff:" , self.currStepProgressData.rateDiff  ) --距离预期的差值，无差距为0，最大为1
			-- printx( 1 , "isFuuu:" , result  )
			-- printx( 1 , "stepAdjust:" , stepAdjust  )
			-- printx( 1 , "==================================================================================================="  )
		end

		--[[
		if _G.isLocalDevelopMode then
			for k,v in ipairs(self.modes) do
				if v.mode == ProductItemDiffChangeMode.kAddColor then
					local cc = self:getCurrStepMaxNumColor()
					local str = ""

					if cc == 1 then
						str = "蓝[1]"
					elseif cc == 2 then
						str = "绿[2]"
					elseif cc == 3 then
						str = "棕[3]"
					elseif cc == 4 then
						str = "紫[4]"
					elseif cc == 5 then
						str = "红[5]"
					elseif cc == 6 then
						str = "黄[6]"
					end

					CommonTip:showTip( "当前最多颜色 " .. tostring(str) .. " 数量：" .. tostring(self.currStepColorNumMap[cc]) , "negative", nil, 2)
					break
				end
			end
		end
		--]]

	end
end

function ProductItemDiffChangeLogic:getCurrStepMaxNumColor()
	
	if self.currStepColorNumMap then

		local maxColor = nil
		local currNum = 0

		for k,v in pairs(self.currStepColorNumMap) do
			if v > currNum then
				currNum = v
				maxColor = k
			end
		end

		return maxColor
	end

	return nil
end

function ProductItemDiffChangeLogic:rand( v1 , v2 )
	if self.mainLogic then
		return self.mainLogic.randFactory:rand( v1 , v2 )
	end
	return 0
end

function ProductItemDiffChangeLogic:setStepColorNumMap(colorMap)
	self.currStepColorNumMap = colorMap
end

function ProductItemDiffChangeLogic:startLevel(mainLogic)
	self.mainLogic = mainLogic
	self.currStepColorNumMap = {}
	self.context = {}

	self.context.realCostMove = self.mainLogic.realCostMove or 0
	self.context.falsifyMap = {}
	self.context.colorLogMap = {}

	self.context.availableColorList = {}
	self.context.defaultColorList = {}
	self.context.singleDropConfig = {}
	--self.context.singleColorList = {}

	local _singleDropConfig = self.mainLogic:getSingleDropConfig( 0 , 0 )

	for k,v in pairs(_singleDropConfig) do
		self.context.singleDropConfig[k] = {}
		local cfg = self.context.singleDropConfig[k]
		for k2,v2 in pairs( v ) do
			local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(v2)
			if colorIndex then
				cfg[colorIndex] = true
				self.context.availableColorList[colorIndex] = true
			end
		end
	end

	for k,v in pairs( self.mainLogic.mapColorList ) do
		local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(v)
		if colorIndex then
			self.context.availableColorList[colorIndex] = true
			self.context.defaultColorList[colorIndex] = true
		end
	end

	self:setCurrDS(0)
end

function ProductItemDiffChangeLogic:getSingleDropConfigOfGrid(r, c)
	if not self.mainLogic then
		return self.context.singleDropConfig  	--如果取不到格子掉落配置，返回原先的默认全局配置，以免出错
	end
	if not r then r = 0 end
	if not c then c = 0 end

	local singleDropConfigOfGrid

	local _singleDropConfigOfGrid = self.mainLogic:getSingleDropConfig(r, c)
	if _singleDropConfigOfGrid then
		singleDropConfigOfGrid = {}
		for k,v in pairs(_singleDropConfigOfGrid) do
			singleDropConfigOfGrid[k] = {}
			local cfg = singleDropConfigOfGrid[k]
			for k2,v2 in pairs( v ) do
				local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(v2)
				if colorIndex then
					cfg[colorIndex] = true
				end
			end
		end
	end

	-- printx(11, "singleDropConfigOfGrid: ", r, c, table.tostring(singleDropConfigOfGrid))
	if singleDropConfigOfGrid then
		return singleDropConfigOfGrid
	else
		return self.context.singleDropConfig 	--如果取不到格子掉落配置，返回原先的默认全局配置，以免出错
	end
end

function ProductItemDiffChangeLogic:onStepEnd()
	self.context.realCostMove = self.mainLogic.realCostMove or 0
end

function ProductItemDiffChangeLogic:endLevel()
	self.modes = {}
	self.aiCareMode = nil
	self:setCurrDS(0)
end

function ProductItemDiffChangeLogic:getContext()
	return self.context
end

function ProductItemDiffChangeLogic:setContext(contextdata)
	self.context = contextdata
end

function ProductItemDiffChangeLogic:getFalsifyStepData(realCostMove)
	--printx( 1 , "ProductItemDiffChangeLogic:getFalsifyStepData  realCostMove" , realCostMove)
	if not self.context.falsifyMap[realCostMove] then
		--printx( 1 , "ProductItemDiffChangeLogic:getFalsifyStepData   !!!!!!!!!!!!!!!!!!!!!!!!")
		local resultColorMap = {}
		resultColorMap[1] = 0
		resultColorMap[2] = 0
		resultColorMap[3] = 0
		resultColorMap[4] = 0
		resultColorMap[5] = 0
		resultColorMap[6] = 0

		self.context.falsifyMap[realCostMove] = {
			dropEff = 0 ,
			dropBird = 0 ,
			changeColorCount = 0 ,
			resultColorMap = resultColorMap ,
			dropNum = 0 ,
		}
	end

	if self.context.falsifyMap[ realCostMove - 10 ] then
		self.context.falsifyMap[ realCostMove - 10 ] = nil
	end

	return self.context.falsifyMap[realCostMove]
end

function ProductItemDiffChangeLogic:falsify(itemdata , cannonType , cannonPos)

	--if true then return end
	--if itemdata and ( itemdata.ItemType == GameItemType.kAnimal or itemdata.ItemType == GameItemType.kCrystal ) then
	if itemdata and itemdata:isColorful() and itemdata.ItemType ~= GameItemType.kDrip then
		self:handleAiDcByMode()

		for k,v in ipairs(self.modes) do
			local data = v
			local fixedCannonType = ProductItemLogic:getProductItemIdByCannonType( cannonType )
			-- printx( 1 , "ProductItemDiffChangeLogic:falsify   mode" ,data.mode , "dataVer" , data.dataVer , "cannonPos" , cannonPos)
			self:__falsify( data.mode , data.dataVer , itemdata , fixedCannonType , cannonPos)
		end
	end
end

local aiCareModes = {
	ProductItemDiffChangeMode.kAddColor,
	ProductItemDiffChangeMode.kAIAddColor,
	ProductItemDiffChangeMode.kAICoreAddColor,
}
function ProductItemDiffChangeLogic:handleAiDcByMode()
	if not LevelType:isMainLevel(self.mainLogic.level) then return end
	if self.mainLogic.theGamePlayStatus ~= GamePlayStatus.kNormal then return end
	if self.aiCareMode == nil then
		self.aiCareMode = false 
		for i,v in ipairs(self.modes) do
			if table.includes(aiCareModes, v.mode) then
				self.aiCareMode = true 
				break 
			end
		end
	end

	if not self.aiCareMode then
		local realCostMove = self.mainLogic.realCostMoveWithoutBackProp
		if GamePlayContext:getInstance():getAIPropUsedIndex() then
			realCostMove = realCostMove + 1  						--道具使用时 所用策略 用下一步的
		end
		GamePlayContext:getInstance():addAIInterveneLog(realCostMove, self.mainLogic.realCostMoveWithoutBackProp, self.mainLogic.theCurMoves, 0)
	end
end

function ProductItemDiffChangeLogic:__falsify( mode , dataVer , itemdata , cannonType , cannonPos)

	if not FalsifyConfig then
		FalsifyConfig = MetaManager.getInstance():getProductItemDiffChangeFalsifyConfig()
	end

	local isSingleDrop = false
	self:setCurrDS( dataVer )
	local stepData = self:getFalsifyStepData( self.context.realCostMove )

	local function falsifyByDropEff( item , dropedNum , dataset )
		local num1 = 100
		local num2 = 0

		if dropedNum == 0 then
			num2 = dataset.n0
		elseif dropedNum <= dataset.m1 then
			num2 = dataset.n1
		elseif dropedNum <= dataset.m2 then
			num2 = dataset.n2
		elseif dropedNum <= dataset.m3 then
			num2 = dataset.n3
		elseif dropedNum <= dataset.m4 then
			num2 = dataset.n4
		end

		--printx( 1 , "falsifyByDropEff   dropedNum =" , dropedNum , " n0:" , dataset.n0 , "m1" , dataset.m1 , "n1" , dataset.n1 , "m2" , dataset.m2 , "n2"  ,dataset.n2)

		if self:rand(1,num1) <= num2 then

			local rn = self:rand(1,3)
			if rn == 1 then
				item.ItemSpecialType = AnimalTypeConfig.kLine
			elseif rn == 2 then
				item.ItemSpecialType = AnimalTypeConfig.kColumn
			elseif rn == 3 then
				item.ItemSpecialType = AnimalTypeConfig.kWrap
			end

			
			return true , item.ItemSpecialType
		end

		return false
	end

	local function falsifyByDropBird( item , dropedNum , dataset )
		local num1 = 100

		if dropedNum < dataset.m1 then
			if self:rand(1,num1) <= dataset.n1 then
				item.ItemSpecialType = AnimalTypeConfig.kColor
				return true
			end
		end

		return false
	end

	if mode == ProductItemDiffChangeMode.kDropEff then

		if itemdata.ItemType ~= GameItemType.kAnimal then
			return
		end

		local dataset = FalsifyConfig[mode].kNormalLevel[dataVer]
		--[[
			[1] = {
				n0 = 15 ,
				m1 = 3 ,
				n1 = 10 ,
				m2 = 8 ,
				n2 = 5 ,
				m3 = 15 ,
				n3 = 2 ,
				m4 = 9999 ,
				n4 = 0 ,
			} ,
		]]

		if falsifyByDropEff( itemdata , stepData.dropNum , dataset ) then
			--printx( 1 , "kDropEff ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   " ,mode , dataVer)
			stepData.dropEff = stepData.dropEff + 1
		end
		stepData.dropNum = stepData.dropNum + 1

	elseif mode == ProductItemDiffChangeMode.kDropEffAndBird then

		if itemdata.ItemType ~= GameItemType.kAnimal then
			return
		end

		local dataset_DropEff = FalsifyConfig[ProductItemDiffChangeMode.kDropEff].kNormalLevel[dataVer]
		local dataset_DropBird = FalsifyConfig[mode].kNormalLevel[dataVer]
		--[[
			[1] = {
				n1 = 20 ,
				m1 = 2 ,
			} ,
		]]
		local dropBird = false

		if falsifyByDropEff( itemdata , stepData.dropNum , dataset_DropEff ) then

			if falsifyByDropBird( itemdata , stepData.dropBird , dataset_DropBird ) then
				stepData.dropBird = stepData.dropBird + 1
			else
				stepData.dropEff = stepData.dropEff + 1
			end
		end

		stepData.dropNum = stepData.dropNum + 1

	elseif mode == ProductItemDiffChangeMode.kAddColor or mode == ProductItemDiffChangeMode.kAIAddColor or mode == ProductItemDiffChangeMode.kAICoreAddColor then

		local dataset = nil

		local uid = UserManager:getInstance():getUID()

		--[[
		if MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "NewColor" , uid) then --使用新版本的颜色掉落算法
			self.useOldVersion = false
		else
			self.useOldVersion = true
		end

		if self.useOldVersion then
			dataset = FalsifyConfig[mode].kOldVersion[dataVer]
		else
			dataset = FalsifyConfig[mode].kNormalLevel[dataVer]
		end
		]]

		if FalsifyConfig[mode] and FalsifyConfig[mode].kNormalLevel then 
			dataset = FalsifyConfig[mode].kNormalLevel[dataVer]
		end

		--[[
		if MaintenanceManager:isEnabledInGroup( "ReturnUsersRetentionTest" , "C" , uid) then
			if dataVer == 3 then
				dataset = testConfig
			end
		end
		]]

		local maxColorIndex = self:getCurrStepMaxNumColor()
		local maxColor = AnimalTypeConfig.convertIndexToColorType( maxColorIndex )

		local oringinColorIndex = AnimalTypeConfig.convertColorTypeToIndex( itemdata._encrypt.ItemColorType )
		local oringinColor = itemdata._encrypt.ItemColorType

		local colorLog = self.context.colorLogMap
		local cannonPosKey = tostring(cannonPos.r) .. "_" .. tostring(cannonPos.c)

		if not colorLog[cannonPosKey] then
			colorLog[cannonPosKey] = {}
		end

		local colorLogList = colorLog[cannonPosKey]


		local function doChangeColor(item , colorIndex , isMaxColor)

			local color = AnimalTypeConfig.convertIndexToColorType( colorIndex )
			item._encrypt.ItemColorType = color

			if isMaxColor then
				stepData.changeColorCount = stepData.changeColorCount + 1
			end
			
			stepData.resultColorMap[colorIndex] = stepData.resultColorMap[colorIndex] + 1

			table.insert( colorLogList , colorIndex )
			if #colorLogList > dataset.ruleB_n4 then
				table.remove( colorLogList , 1 )
			end 

			stepData.dropNum = stepData.dropNum + 1
		end

		local function doPassChangeColor(item , oringinColorIndex)
			stepData.resultColorMap[oringinColorIndex] = stepData.resultColorMap[oringinColorIndex] + 1

			table.insert( colorLogList , oringinColorIndex )
			if #colorLogList > dataset.ruleB_n4 then
				table.remove( colorLogList , 1 )
			end

			stepData.dropNum = stepData.dropNum + 1
		end

		local function doChangeNotMaxColor(item , maxColorIndex , oringinColorIndex , cannonType, r, c)

			local colorIndex = nil

			if maxColorIndex ~= oringinColorIndex then

				local colorList = nil

				local singleDropConfigOfGrid = self:getSingleDropConfigOfGrid(r, c)
				if singleDropConfigOfGrid then
					colorList = singleDropConfigOfGrid[cannonType]
					if not colorList then
						colorList = self.context.defaultColorList
					end
				end

				local randomList = {}
				if colorList and #colorList > 0 then
					for k,v in pairs(colorList) do
						if k ~= maxColorIndex then
							table.insert( randomList , k )
						end
					end
				end

				if #randomList > 0 then
					colorIndex = randomList[ self:rand(1,#randomList) ]
				end
			end
			

			if colorIndex then
				doChangeColor( item , colorIndex , false )
			else
				doPassChangeColor( item , oringinColorIndex )
			end
		end

		if oringinColorIndex < 1 or oringinColorIndex > 6 then
			return --魔力鸟不做任何操作
		end

		-- printx( 1 , "ProductItemDiffChangeLogic ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ mode =" , mode)

		local realCostMove = self.mainLogic.realCostMoveWithoutBackProp
		if GamePlayContext:getInstance():getAIPropUsedIndex() then
			realCostMove = realCostMove + 1  						--道具使用时 所用策略 用下一步的
		end
		if mode == ProductItemDiffChangeMode.kAICoreAddColor then 
			local aiColorProbs = LevelDifficultyAdjustManager:getAIColorProbs()
			local aiColorProbsMaxNum = #aiColorProbs
			local interveneLv 
			if realCostMove > aiColorProbsMaxNum then
				-- if remaining free steps = 0
				-- game client pops the last value from the FIPO list and applies the intervention intensity for all remaining steps (steps that users have purchased)
				interveneLv = tonumber(aiColorProbs[aiColorProbsMaxNum])
			else
				interveneLv = tonumber(aiColorProbs[realCostMove])
			end

			if interveneLv then
				if self.mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then 
					GamePlayContext:getInstance():addAIInterveneLog(realCostMove, self.mainLogic.realCostMoveWithoutBackProp, self.mainLogic.theCurMoves, interveneLv)
			 	end
			 	if interveneLv >= 1 and interveneLv <= 3 then 
					dataset = FalsifyConfig[ProductItemDiffChangeMode.kAIAddColor].kNormalLevel[interveneLv]
					self:setCurrDS(interveneLv)
				else
					return  	-- 0
				end
			else
				return 
			end
		elseif mode == ProductItemDiffChangeMode.kAIAddColor and self.currStepProgressData then 
			local currStepRate = self.currStepProgressData.currStepRate
			local currStepStaticRate = self.currStepProgressData.currStepStaticRate
			local rateDiff = self.currStepProgressData.rateDiff
			local isFuuu = self.currStepProgressData.isFuuu
			local staticTotalSteps = self.currStepProgressData.staticTotalSteps or 10000
			

			local levelId = self.mainLogic.level
			--local stepAdjust = LevelDifficultyAdjustManager:getLevelLeftMoves( levelId ) or defaultLevelLeftMovesAdjust
			local costMove = self.mainLogic.realCostMoveWithoutBackProp

			local rateAdjust = AIColorAdjustRate_default
			local passAdjust = false
			local adjustPoint1 = nil
			local adjustPoint2 = nil
			local adjustPoint3 = nil
			--[[]]----------------------------------

			local rateAdjustConfig = AIAddColorConfig.rateAdjust

			for k,v in ipairs(rateAdjustConfig) do

				local rate = costMove / staticTotalSteps
				if rate >= v.minMovesRate and rate <= v.maxMovesRate then

					adjustPoint1 = v.adjustPoint1
					adjustPoint2 = v.adjustPoint2
					adjustPoint3 = v.adjustPoint3

					-- printx( 1 , "---------- 启用第" .. tostring(k) .. "组rateAdjust配置" , 
					-- 	"adjustPoint1=" .. tostring(adjustPoint1) .. " adjustPoint2=" .. tostring(adjustPoint2) .. " adjustPoint3=" .. tostring(adjustPoint3) )
					
					break
				end
			end

			-------------------------------------------
			local interveneLv = 0
			if not (adjustPoint1 and adjustPoint2 and adjustPoint3) then
				-- printx( 1 , "ProductItemDiffChangeLogic  缺少配置，禁用干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu , adjustPoint1 , adjustPoint2 , adjustPoint3 )
			elseif rateDiff == 0 then
				--禁用干预
				-- printx( 1 , "ProductItemDiffChangeLogic  禁用干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
			elseif adjustPoint1 and rateDiff > 0 and rateDiff <= adjustPoint1 then
				-- printx( 1 , "ProductItemDiffChangeLogic  接近期望，禁用干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
			elseif adjustPoint2 and rateDiff > adjustPoint1 and rateDiff <= adjustPoint2 then
				-- printx( 1 , "ProductItemDiffChangeLogic  开启弱干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
				dataset = FalsifyConfig[mode].kNormalLevel[1]
				self:setCurrDS( 1 )
				interveneLv = 1
			elseif adjustPoint3 and rateDiff > adjustPoint2 and rateDiff <= adjustPoint3 then
				-- printx( 1 , "ProductItemDiffChangeLogic  开启中等干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
				dataset = FalsifyConfig[mode].kNormalLevel[2]
				self:setCurrDS( 3 )
				interveneLv = 2
			elseif rateDiff > adjustPoint3 then
				-- printx( 1 , "ProductItemDiffChangeLogic  开启强干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
				dataset = FalsifyConfig[mode].kNormalLevel[3]
				self:setCurrDS( 4 )
				interveneLv = 3
			else
				-- printx( 1 , "ProductItemDiffChangeLogic  缺少配置，禁用干预" , rateDiff , currStepRate , currStepStaticRate , isFuuu )
			end
			if self.mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then
				GamePlayContext:getInstance():addAIInterveneLog(realCostMove, self.mainLogic.realCostMoveWithoutBackProp, self.mainLogic.theCurMoves, interveneLv)
			end
			if interveneLv == 0 then return end
		end

		local result = self:changeColorRuleA( maxColorIndex , oringinColorIndex , cannonType , stepData , dataset, cannonPos.r, cannonPos.c)
		local isSameColor = false
		if not result.result then

			doPassChangeColor( itemdata , oringinColorIndex )
			
			--[[
			printx( 1 , "ProductItemDiffChangeLogic:__falsify  PASS BY A   oringinColorIndex =" , oringinColorIndex )

			if result.ruleIndex then
				printx( 1 , "ruleIndex:" , result.ruleIndex , "m:" , result.m)
			else
				printx( 1 , "passByUnavailableColors:" , result.maxColorIndex )
			end
			
			printx( 1 , "--------------------------------------")
			--]]
			return
		else
			if result.isSameColor then
				-- printx( 1 , "maxColorIndex == oringinColorIndex , so ignore it")
				isSameColor = true
			end
		end

		if not isSameColor then
			result = self:changeColorRuleB( maxColorIndex , colorLogList , dataset )
			if not result.result then
				
				-- printx( 1 , "ProductItemDiffChangeLogic:__falsify  NOT MAX BY B  at" , cannonPosKey )
				-- printx( 1 , "ruleIndex:" , result.ruleIndex , "maxColorIndex:" , result.maxColorIndex , "maxColorNum:" , result.maxColorNum , "oringinColorIndex:" , oringinColorIndex)
				doChangeNotMaxColor( itemdata , maxColorIndex  , oringinColorIndex , cannonType, cannonPos.r, cannonPos.c)
				-- printx( 1 , "--------------------------------------")
				return
			end

			result = self:changeColorRuleC( maxColorIndex , dataset )
			if not result.result then
				doChangeNotMaxColor( itemdata , maxColorIndex , oringinColorIndex , cannonType, cannonPos.r, cannonPos.c)
				-- printx( 1 , "ProductItemDiffChangeLogic:__falsify  NOT MAX BY C" )
				-- printx( 1 , "ruleIndex:" , result.ruleIndex , "changeColorCountInSomeSteps:" , result.count)
				-- printx( 1 , "--------------------------------------")
				return
			end
		end
		

		if isSameColor then
			-- printx( 1 , "ProductItemDiffChangeLogic:__falsify  PASS BY Same Color Ignore  oringinColorIndex:" , oringinColorIndex , " oringinColorNum:" , stepData.resultColorMap[oringinColorIndex] )
			doPassChangeColor( itemdata , oringinColorIndex)
		else
			-- printx( 1 , "ProductItemDiffChangeLogic:__falsify  doChangeColor  oringinColorIndex" , oringinColorIndex , 
			--   	"  maxColorIndex:" , maxColorIndex , "maxColorNum:"  , stepData.resultColorMap[maxColorIndex] )
			doChangeColor( itemdata , maxColorIndex , true)
		end

		-- printx( 1 , "--------------------------------------")
		-- printx( 1 , table.tostring(stepData.resultColorMap))
		
	end

end


function ProductItemDiffChangeLogic:changeColorRuleA( maxColorIndex , oringinColorIndex , cannonType , currStepData , dataset, r, c)
	local result = {}
	result.result = true
	-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleA  " , maxColorIndex ,oringinColorIndex , cannonType ,  currStepData , dataset)


	if maxColorIndex ~= oringinColorIndex then

		local passByUnavailableColors = false

		local singleDropConfigOfGrid = self:getSingleDropConfigOfGrid(r, c)
		-- printx( 11, "=== singleDropConfigOfGrid ", table.tostring(singleDropConfigOfGrid))
		-- printx( 11, "=== defaultColorList ", table.tostring(self.context.defaultColorList))
		if singleDropConfigOfGrid then
			local colorConfig = singleDropConfigOfGrid[cannonType]
			if not colorConfig then
				-- printx( 11, "set to defaultColorList ")
				colorConfig = self.context.defaultColorList
			end

			if colorConfig then
				if not colorConfig[maxColorIndex] then
					passByUnavailableColors = true
				end
			end
		end

		if not passByUnavailableColors then

			local maxColorCount = currStepData.resultColorMap[maxColorIndex] or 0
			local ruleA_m = 0
			local ri = 0
			
			for i = 1 , 4 do
				--printx( 1, "i" .. tostring(i) , "maxColorIndex = " , maxColorIndex , "maxColorCount = " , maxColorCount )
				--printx( 1 , table.tostring(currStepData.resultColorMap))
				if maxColorCount <= dataset["ruleA_n" .. tostring(i)] then
					ruleA_m = dataset["ruleA_m" .. tostring(i)]
					ri = i
					break
				end
			end
			
			local num1 = 100
			if self:rand(1,num1) <= ruleA_m then
				-- printx( 1 , "RuleA  return 111  ruleA_m =" , ruleA_m , "result.result =" , result.result)
				return result
			else
				result.result = false
				result.ruleIndex = ri
				result.m = ruleA_m
				-- printx( 1 , "RuleA  return 222  ruleA_m =" , ruleA_m , "ruleIndex =" , result.ruleIndex )
				return result
			end

		else
			result.result = false
			result.maxColorIndex = maxColorIndex
			-- printx( 1 , "RuleA  return 333  maxColorIndex =" , result.maxColorIndex )
			return result
		end
	else
		-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleA   maxColorIndex ~= oringinColorIndex !!!!!!!!!!!!!!!!!!!!")
		result.result = true
		result.isSameColor = true
		result.oringinColorIndex = oringinColorIndex
	end

	return result
end

function ProductItemDiffChangeLogic:changeColorRuleB( maxColorIndex , colorLogList , dataset )
	-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleB 1111" )
	local result = {}
	result.result = true

	local startIndex = #colorLogList
	local maxColorCount = 0

	for i = 1 , #colorLogList do
		
		local colorIndex = colorLogList[ startIndex - (i -1) ]
		if colorIndex == maxColorIndex then
			maxColorCount = maxColorCount + 1
		end

		-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleB 222  maxColorCount" , maxColorCount )

		local needBreak = false
		local ri = 0 
		for ia = 1 , 4 do
			--printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleB 333  i" , i ,dataset["ruleB_n" .. tostring(ia)] - 1 )
			if i <= dataset["ruleB_n" .. tostring(ia)] - 1 then
				-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleB 444  maxColorCount" , maxColorCount , dataset["ruleB_m" .. tostring(ia)] - 1 )
				if maxColorCount >= dataset["ruleB_m" .. tostring(ia)] then
					-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleB 333  ruleB_m" .. tostring(ia) .. " =" , dataset["ruleB_m" .. tostring(ia)] , "maxColorCount =" , maxColorCount , "Break !!!" )
					result.result = false --掉落非maxColor
					result.ruleIndex = ia
					result.maxColorIndex = maxColorIndex
					result.maxColorNum = maxColorCount
					needBreak = true
					break
				end
			end
		end

		if needBreak then
			break
		end
	end

	return result
end

function ProductItemDiffChangeLogic:changeColorRuleC( maxColorIndex , dataset )
	local result = {}
	result.result = true

	for i = 1 , 4 do

		local step = dataset["ruleC_n" .. tostring(i)]
		local maxCount = dataset["ruleC_m" .. tostring(i)]
		local maxColorCountInSomeSteps = 0

		for ia = 1 , step do
			local curStepData = self:getFalsifyStepData( self.context.realCostMove - (ia-1) )
			if curStepData then
				maxColorCountInSomeSteps = maxColorCountInSomeSteps + curStepData.changeColorCount
			end
		end
		if maxColorCountInSomeSteps >= maxCount then

			-- printx( 1 , "ProductItemDiffChangeLogic:changeColorRuleC 222  maxCount =" , maxCount , "maxColorCountInSomeSteps =" , maxColorCountInSomeSteps , "  Break!!!" )

			result.result = false --掉落非maxColor
			result.ruleIndex = i
			result.count = maxColorCountInSomeSteps
			return result 
		end
	end

	return result
end