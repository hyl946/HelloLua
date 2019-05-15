--=====================================================
-- ColorFilterLogic 
-- by zhijian.li
-- (c) copyright 2009 - 2017, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  ColorFilterLogic.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2017/06/15
-- descrip:   色彩过滤器逻辑处理 GameExtandPlayLogic太特么长了
--=====================================================

ColorFilterLogic = {}

function ColorFilterLogic:init(mainLogic)
	self.mainLogic = mainLogic	

	self.logLabel = {}			
	self.logFilterNum = {}
	for i=1,6 do
		self.logLabel[i] = nil
	end
	self.logInit = false
end

function ColorFilterLogic:handleFilter(r, c, callback)
	local gameItemMap = self.mainLogic.gameItemMap
    local gameBoardMap = self.mainLogic.boardmap

    local shouldFilter = false
	local boardData = gameBoardMap[r][c] 
	if boardData and boardData.colorFilterState == ColorFilterState.kStateA and boardData.colorFilterColor ~= 0 then 
    	local itemData = gameItemMap[r][c]
    	local color = AnimalTypeConfig.colorTypeList[boardData.colorFilterColor]
    	if itemData and 
    		color and 
    		itemData.lockLevel == 0 and
    		itemData._encrypt.ItemColorType == color and 
    		ColorFilterLogic:canBeEffectByFilter(itemData.ItemType) and
    		boardData.lotusLevel < 3 and 
    		not (itemData.ItemType == GameItemType.kMagicLamp and itemData.lampLevel >= 5) and
    		not (itemData.ItemType == GameItemType.kTotems and itemData.totemsState ~= GameItemTotemsState.kNone) and
    		not itemData:hasAnyFurball() and not itemData:seizedByGhost() then 
    		shouldFilter = true
    		self:doFilter(r, c, boardData.colorFilterColor, callback)
    	end
    end

    return shouldFilter
end

--可以被过滤器影响的类型 新加障碍 若可以被影响 应加如此处
function ColorFilterLogic:canBeEffectByFilter(itemType)
	if itemType == GameItemType.kAnimal or 			--小动物
		itemType == GameItemType.kCrystal or 		--水晶球
		itemType == GameItemType.kGift or			--礼盒
		itemType == GameItemType.kNewGift or 		--礼盒
		itemType == GameItemType.kBalloon or 		--气球
		itemType == GameItemType.kMagicLamp or 		--大眼仔
		itemType == GameItemType.kBottleBlocker or 	--萌豆
		itemType == GameItemType.kBlocker199 or		--水母宝宝
		itemType == GameItemType.kTotems or  		--闪电鸟
		itemType == GameItemType.kScoreBuffBottle or	--刷星瓶
		itemType == GameItemType.kFirecracker		--爆竹
		then
		return true
	end
	return false
end

function ColorFilterLogic:doFilter(r, c, colorIndex, callback)
	local itemData = self.mainLogic.gameItemMap[r][c]
	local boardData = self.mainLogic.boardmap[r][c]
	
	self:addFilterAction(r, c, callback)
	--牢笼
	if itemData.cageLevel > 0 then 
		------1.牢笼变化------
		----1-1.数据变化
		itemData.cageLevel = itemData.cageLevel - 1

		-----1-2.分数变化
		local scoreScale = 1
		local addScore = GamePlayConfigScore.MatchAtLock * scoreScale
		self.mainLogic:addScoreToTotal(r, c, addScore)

		----1-3.播放特效
		local LockAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_LockDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_GameItemSnowDeleteAction_CD)
		self.mainLogic:addDestroyAction(LockAction)
	end

	--荷塘
	if boardData.lotusLevel > 0 and itemData:canEffectLotus(boardData.lotusLevel) then
		GameExtandPlayLogic:decreaseLotus(self.mainLogic, r, c , 1 , false)
	end

	--蜂蜜
	if itemData.honeyLevel > 0 then
		GameExtandPlayLogic:honeyDestroy(self.mainLogic, r, c, 1)
	end

	--大眼仔
	if itemData.ItemType == GameItemType.kMagicLamp then 
		GameExtandPlayLogic:onChargeMagicLamp(self.mainLogic, r, c, 5)
	end

	--影响荷塘 蜂蜜
	boardData.isJustEffectByFilter = true
	--闪电鸟
	GameExtandPlayLogic:changeTotemsToWattingActive(self.mainLogic, r, c, 1, true)
	--消除小木桩/冰块/流沙
	SpecialCoverLogic:SpecialCoverLightUpAtPos(self.mainLogic, r, c, 1, true)
	--消除普通的
	BombItemLogic:tryCoverByBombForFilter(self.mainLogic, r, c, 1)
	--消除障碍
	SpecialCoverLogic:SpecialCoverAtPos(self.mainLogic, r, c, 3) 
	SpecialCoverLogic:specialCoverChainsAroundPos(self.mainLogic, r, c)
	boardData.isJustEffectByFilter = false
	self.mainLogic:setNeedCheckFalling()
end

function ColorFilterLogic:addFilterAction(r, c, callback)
	local filterAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_ColorFilter_Filter,
			IntCoord:create(r, c),
			nil,				
			GamePlayConfig_MaxAction_time)	
	if callback then 
		filterAction.completeCallback = function () callback() end
	end

	self.mainLogic:addGameAction(filterAction)
end

function ColorFilterLogic:dcreaseColorFilterB(row, column, decNum)
	local gameItemMap =  self.mainLogic.gameItemMap
	local gameBoardMap = self.mainLogic.boardmap
	--一次交换多次匹配导致被削掉多层 影响动画的显示
	local decreaseNum = decNum or 1
	-- local item = gameItemMap[row][column]
	local board = gameBoardMap[row][column]
	
	if board.colorFilterBLevel <= 0 then
		return
	end

	local rawOldLevel = board.colorFilterBLevel
	local colorIndex = board.colorFilterColor
	local oldLevel = board.colorFilterBLevel - decreaseNum + 1
	board.colorFilterBLevel = board.colorFilterBLevel - decreaseNum
	local newLevel = board.colorFilterBLevel

	local action = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_ColorFilterB_Dec,
		IntCoord:create(row,column),				
		nil,				
		GamePlayConfig_MaxAction_time)
	action.oldLevel = oldLevel
	action.newLevel = newLevel
	action.addInt = colorIndex
	self.mainLogic:addDestroyAction(action)

	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_ColorFilter, ObstacleFootprintAction.k_Hit, math.min(rawOldLevel, decreaseNum))
end

function ColorFilterLogic:checkItemBlock(r, c)
	self.mainLogic:checkItemBlock(r, c)
end

function ColorFilterLogic:checkColorMatch(r, c, color)
	local gameBoardMap = self.mainLogic.boardmap
	if gameBoardMap and gameBoardMap[r][c] then 
		local colorByIndex = AnimalTypeConfig.colorTypeList[gameBoardMap[r][c].colorFilterColor]
		if colorByIndex then 
			return colorByIndex == color
		end
	end
	return false
end

function ColorFilterLogic:getFilterColor(r, c)
	local gameBoardMap = self.mainLogic.boardmap
	if gameBoardMap and gameBoardMap[r][c] then 
		if gameBoardMap[r][c].colorFilterColor ~= 0 then 
			return AnimalTypeConfig.colorTypeList[gameBoardMap[r][c].colorFilterColor]
		end
	end
end

