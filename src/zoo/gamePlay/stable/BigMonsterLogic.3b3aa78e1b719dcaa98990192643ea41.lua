BigMonsterLogic = class()
local MAX_COUNT_ATTACK = 4
local PriorityInit = 0.1;  --初始状态
local Priority1Weight = 100; 
local Priority2Weight = 10;
local Priority3Weight = 1;
local PriorityBlackPoint = 0; --被雪怪踩中的区域的左上角的点
function BigMonsterLogic:create( context )
	-- body
	local v = BigMonsterLogic.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BigMonsterLogic:update( ... )
	-- body
end

function BigMonsterLogic:check()
	local function callback( ... )
		-- body
		self:handBigMonsterComplete();
	end

	self.hasItemToHandle = false
	self.completeItem = 0
	self.totalItem = self:checkMonsterList(self.mainLogic, callback)

	if self.totalItem == 0 then
		self:handBigMonsterComplete()
	else
		self.hasItemToHandle = true
	end
	return self.totalItem
end

function BigMonsterLogic:handBigMonsterComplete( ... )
	-- body
	self.completeItem = self.completeItem + 1 
	if self.completeItem >= self.totalItem then 
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function BigMonsterLogic:findTheMonster( mainLogic, r, c )
	-- body
	local result_r, result_c
	local item = mainLogic.gameItemMap[r][c]
	if item.bigMonsterFrostingType == 1 then 
		result_r = r
		result_c = c
	elseif item.bigMonsterFrostingType == 2 then
		result_r = r
		result_c = c-1
	elseif item.bigMonsterFrostingType == 3 then
		result_r = r - 1
		result_c = c
	elseif item.bigMonsterFrostingType == 4 then
		result_r = r - 1
		result_c = c - 1
	end
	return result_r, result_c
end

function BigMonsterLogic:checkMonsterList( mainLogic, callback )
	-- body
	local count = 0
	if not mainLogic.bigMonsterMark then
		return count
	end
	
	local SrcPosList = {}
	---------------------雪怪消除
	local hasBigmonster = false
	for r = 1,  #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do 
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kBigMonster then 
				hasBigmonster = true
				local totalStrength = item.bigMonsterFrostingStrength 
									+ mainLogic.gameItemMap[r][c+1].bigMonsterFrostingStrength
									+ mainLogic.gameItemMap[r+1][c].bigMonsterFrostingStrength
									+ mainLogic.gameItemMap[r+1][c+1].bigMonsterFrostingStrength
				if totalStrength <= 0 then
					
					count = count + 1

					mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.BigMonster)

					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItem_Monster_Jump,
						IntCoord:create(r, c),
						nil,
						GamePlayConfig_MaxAction_time
					)

					action.completeCallback = callback
					mainLogic:addDestroyAction(action)

					table.insert(SrcPosList, IntCoord:create(r,c))
				end
			end
		end 
	end

	for r = 1,  9 do
		for c = 1, 9 do 
			if mainLogic.backItemMap[r] then
				local item = mainLogic.backItemMap[r][c]
				if item and item.ItemType == GameItemType.kBigMonster then 
					hasBigmonster = true
				end
			end
		end
	end
 
	if not hasBigmonster then                  --雪怪只会出现在地图配置中
		mainLogic.bigMonsterMark = false
	end
	
	if count == 0 then return 0 end                     ----------------------没有雪怪需要处理

	mainLogic:setNeedCheckFalling()

	---------------------雪怪消除，产生的地震，
	if count > 1 then 
		self:attackBigArea(mainLogic, callback, SrcPosList)
	else
		self:attackSmallArea(mainLogic, callback, SrcPosList)
	end
	return count + 1
end

function BigMonsterLogic:attackArea( mainLogic, r_min, c_min, r_max, c_max, callback, delayIndex, SrcPosList )
	-- body
	delayIndex = delayIndex or 0
	local actionDeleteByMonster = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_Monster_Destroy_Item,
		IntCoord:create(r_min, c_min),
		IntCoord:create(r_max, c_max),
		GamePlayConfig_MaxAction_time
		)
	actionDeleteByMonster.completeCallback = callback
	actionDeleteByMonster.delayIndex = delayIndex
	actionDeleteByMonster.SrcPosList = SrcPosList
	mainLogic:addGameAction(actionDeleteByMonster)
end

function BigMonsterLogic:attackBigArea( mainLogic, callback, SrcPosList )
	-- body
 	self:attackArea(mainLogic, 1, 1, 9, 9, callback, nil, SrcPosList)
 	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BigMonster, ObstacleFootprintAction.k_HugeAttack, 1)
end

function BigMonsterLogic:attackSmallArea( mainLogic, callback, SrcPosList )
	-- body
	local count = 0
	local max_count = 0
	self:resetHotMap()
	local function local_callback( )
		count = count + 1
		if count >= max_count then 
			if callback then callback() end
		end
	end

	for k = 1, MAX_COUNT_ATTACK do 
		local lucy_p = self:getLuckyPoint()
		max_count = max_count + 1
		self:attackArea(mainLogic, lucy_p.x, lucy_p.y ,lucy_p.x + 1, lucy_p.y + 2, local_callback, k -1, SrcPosList )
		self:adjustHotMapAfterAttack(lucy_p)
 		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BigMonster, ObstacleFootprintAction.k_Attack, 1)
	end
end

function BigMonsterLogic:getLuckyPoint( ... )
	-- body
	local max_priority = 0
	local array_max_priority = {}

	local ss = "";
	for r = 1, #self.hotmap do 
		for c = 1,#self.hotmap[r] do
			ss = ss.."|"..self.hotmap[r][c]
			if self.hotmap[r][c] > max_priority then 
				array_max_priority = {}
				max_priority = self.hotmap[r][c]
				table.insert(array_max_priority, IntCoord:create(r, c))
			elseif self.hotmap[r][c] == max_priority then 
				table.insert(array_max_priority, IntCoord:create(r, c))
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, ss) end
		ss = ""

	end

	local index = self.mainLogic.randFactory:rand(1,#array_max_priority)
	local p_r = math.min( array_max_priority[index].x, 8)
	local p_c = math.min( array_max_priority[index].y, 7)
	-- if _G.isLocalDevelopMode then printx(0, p_r, p_c) end debug.debug()
	self:caculateHotMap(p_r, p_c)
	self:caculateHotMap(p_r, p_c + 1)
	self:caculateHotMap(p_r, p_c + 2)
	self:caculateHotMap(p_r + 1, p_c)
	self:caculateHotMap(p_r + 1, p_c + 1)
	self:caculateHotMap(p_r + 1, p_c + 2)
	return IntCoord:create(p_r, p_c)
end

function BigMonsterLogic:caculateHotMap( r, c )
	-- body
	self.hotmap[r][c] = PriorityBlackPoint
end

function BigMonsterLogic:getPrior( r, c )
	-- body
	local itemData = self.mainLogic.gameItemMap[r][c]
	local boradData = self.mainLogic.boardmap[r][c]

	if boradData:isBigMonsterEffectPrior1() and itemData:isColorful() and (not itemData.isBlock) then
		return Priority1Weight
	elseif itemData:isBigMonsterEffectPrior1() then 
		return Priority1Weight
	elseif itemData:isBigMonsterEffectPrior2() or boradData:isBigMonsterEffectPrior2() then 
		return Priority2Weight
	elseif GameExtandPlayLogic:isEmptyBiscuit(self.mainLogic, r, c) then
		return Priority2Weight
	elseif itemData:isBigMonsterEffectPrior3() or boradData:isBigMonsterEffectPrior3() then 
		return Priority3Weight
	else
		return PriorityInit
	end
end

function BigMonsterLogic:resetHotMap( ... )
	-- body
	self.hotmap = {}
	local gameItemMap = self.mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		self.hotmap[r] = {}
		for c = 1, #gameItemMap[r] do 
			self.hotmap[r][c] = self:getPrior(r, c)
		end
	end
end

--影响区域
--算法：当踩踏x时 标注1的位置会被影响
-- 1 1 1 1 1 0 0 0
-- 1 1 x 0 0 0 0 0
-- 1 1 0 0 0 0 0 0
-- 0 0 0 0 0 0 0 0
local effectPList = {
	{r = -1, c = -1}, {r = -1, c = -2}, {r = -1, c = 0}, {r = -1, c = 1}, {r = -1, c = 2},
	{r = 0, c = -1}, {r = 0, c = -2}, 
	{r = 1, c = -1}, {r = 1, c = -2}
}
function BigMonsterLogic:adjustHotMapAfterAttack( pt )
	-- body
	if not pt then return end

	local function isValidateTile( r , c )
		-- body
		if r < 1 or r > 9 then return false end
		if c < 1 or c > 9 then return false end

		return true
	end

	for k, v in pairs(effectPList) do 
		local c_r = v.r + pt.x
		local c_c = v.c + pt.y
		if isValidateTile(c_r,c_c) then 
			self.hotmap[c_r][c_c] = self.hotmap[c_r][c_c] / 2
		end
	end
end
