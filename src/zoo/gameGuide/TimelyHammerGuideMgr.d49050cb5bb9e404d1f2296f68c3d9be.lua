require "zoo.gameGuide.Guides"
require "zoo.gamePlay.GameItemOrderData"
local UIHelper = require 'zoo.panel.UIHelper'

TimelyHammerGuideMgr = class()

local instance 
local TargetType = {
	kCommon = 0,
	kIce = 1,
	kSeaAnimal = 2,
	kLotus = 3,
	kSand = 4,
	kBlockerCoverMaterial = 5,
	kCuteBall = 6,
	kHoney = 7,
	kBlockerCover = 8,
    kJamSperad = 13,
    kBiscuit = 14,
}
local AnimalTarget = {
	kBlue = 1,
	kGreen = 2,
	kOrange = 3, 
	kPurple = 4, 
	kRed = 5, 
	kYellow = 6, 
}
local KeySourceType = {
	kItem = "item",
	kBoard = "board",	
}
local TargetConfig = {
	-------------------------GameItemOrderType.kAnimal-------------------------
	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kBlue, 							  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},

	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kGreen, 							  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},

	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kOrange, 						  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},

	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kPurple, 						  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},

	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kRed, 							  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},

	-- {keyMain = GameItemOrderType.kAnimal, 		 keySub = AnimalTarget.kYellow, 						  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = 0}, {key = "ItemSpecialType", value = 0}}},


	-------------------------GameItemOrderType.kSpecialBomb-------------------------
	{keyMain = GameItemOrderType.kSpecialBomb, 	 keySub = GameItemOrderType_SB.kLine, 					  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = AnimalTypeConfig.kLine}}},

	{keyMain = GameItemOrderType.kSpecialBomb, 	 keySub = GameItemOrderType_SB.kLine, 					  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = AnimalTypeConfig.kColumn}}},

	{keyMain = GameItemOrderType.kSpecialBomb, 	 keySub = GameItemOrderType_SB.kWrap, 					  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "ItemType", value = GameItemType.kAnimal}, {key = "ItemSpecialType", value = AnimalTypeConfig.kWrap}}},


	-------------------------GameItemOrderType.kSpecialTarget-------------------------
	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kSnowFlower, 			  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 
	condition = {{key = "snowLevel", value = 1}}},	

	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kCoin, 					  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "ItemType", value = GameItemType.kCoin}}},

	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kVenom, 					  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "venomLevel", value = 1}}},

	-- {keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kSnail, 						--蜗牛special	  
	-- keySource = KeySourceType.kItem, targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kGreyCuteBall, 			  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCuteBall, 	
	condition = {{key = "furballLevel", value = 1}, {key = "furballType", value = GameItemFurballType.kGrey}}},

	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kBrownCuteBall, 			  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCuteBall, 	
	condition = {{key = "furballLevel", value = 1}, {key = "furballType", value = GameItemFurballType.kBrown}}},

	{keyMain = GameItemOrderType.kSpecialTarget, keySub = GameItemOrderType_ST.kBottleBlocker, 			  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 
	condition = {{key = "bottleLevel", value = 1}}},	


	-------------------------GameItemOrderType.kOthers-------------------------
	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBalloon, 			    --没有气球这种目标的素材资源
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBlackCuteBall, 		  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "ItemType", value = GameItemType.kBlackCuteBall}, {key = "blackCuteStrength", value = 1}}},

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kHoney, 				  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kHoney, 	
	condition = {{key = "honeyLevel", value = 1}}},

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kSand, 				  
	keySource = KeySourceType.kBoard, 	targetType = TargetType.kSand,   
	condition = {{key = "sandLevel", value = 1}}},

	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kMagicStone, 			--魔法石special 	  
	-- keySource = KeySourceType.kItem, targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBoomPuffer, 		  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	condition = {{key = "pufferState", 	value = PufferState.kActivated}}}, 	

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBlockerCoverMaterial, 
	keySource = KeySourceType.kBoard, 	targetType = TargetType.kBlockerCoverMaterial, 	
	condition = {{key = "blockerCoverMaterialLevel", value = 1}}},

	{keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBlockerCover, 		  
	keySource = KeySourceType.kItem, 	targetType = TargetType.kBlockerCover, 				
	condition = {{key = "blockerCoverLevel", value = 1}}},

	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kBlocker195, 			--星星瓶 小木槌 增加百分比	  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kChameleon, 				--变色龙 锤不了	  
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kPacman, 				--吃豆人 小木槌 增加百分比
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

	-- {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kGhost, 		    		--幽灵 往上面的口跳 special
	-- keySource = KeySourceType.kItem, 	targetType = TargetType.kCommon, 	
	-- condition = {{key = "", value = ""}}},

    {keyMain = GameItemOrderType.kOthers, 		 keySub = GameItemOrderType_Others.kJamSperad, 		  
	keySource = KeySourceType.kBoard, 	targetType = TargetType.kJamSperad, 				
	condition = {{key = "isJamSperad", value = false}}},


	{keyMain = GameItemOrderType.kOthers, keySub = GameItemOrderType_Others.kBiscuit, 			  
	keySource = KeySourceType.kBoard, 	targetType = TargetType.kBiscuit, 
	condition = {{key = "", value = 0}}},
}

function TimelyHammerGuideMgr.getInstance()
    if not instance then
        instance = TimelyHammerGuideMgr.new()
        instance:init()
    end
    return instance
end

function TimelyHammerGuideMgr:init()
	self.targetLimit = 1
	self.resLoaded = false
	self.hasDC = false
	if _G.isLocalDevelopMode then
		self.useNewGuide = true 		--编辑器用这个值
	end
end

function TimelyHammerGuideMgr:checkGuideDecision()
	local uid = UserManager:getInstance():getUID() or "12345"
	self.useNewGuide = MaintenanceManager:getInstance():isEnabledInGroup("NewPropGuide", 'ON', uid)
    if _G.isLocalDevelopMode then
		self.useNewGuide = true 		--编辑器用这个值
	end
	-- if _G.isLocalDevelopMode then
		-- local tipStr = "当前分组: OFF"
		-- if self.useNewGuide then
		-- 	tipStr = "当前分组: ON" 
		-- end
		-- CommonTip:showTip(tipStr, "positive", nil, 10)
	-- end

	--data.do中有个prop_tag这个标签表明了用户使用道具的频率 以此来决定触发强弱引导
	if not self.useNewGuide then 
		Guides[500010101] = {--小木槌 强引导
			appear = {
				{type = "scene", scene = "game"},
				{type = "onceLevel"},
				{type = "staticBoard"},
				{type = "noPopup"},
				{type = "firstGuideOnLevel"},
				{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
				{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
				{type = "minCurrLevel", para = 31},
				{type = "notTimeLevel", para = 1},
				{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
				{type = "hasPropInBar" , para = 10010 },
				{type = "tagetLeft" , para = 2 },
				{type = "numMoveLeft", para = {4,1}},
				{type = "gameModeType", para = { 
												GameModeTypeId.LIGHT_UP_ID , 
												GameModeTypeId.ORDER_ID , 
												GameModeTypeId.DIG_MOVE_ID ,
												GameModeTypeId.DROP_DOWN_ID ,
												GameModeTypeId.SEA_ORDER_ID
											}},
				{type = "hasNoOtherGuide"},
				{type = "triggerHammer"},
				{type = "IngamePropGuideManager", para = {propId=10010,type='strong'}},
			},
			action = {

				[1] = {type = "guidePropStrongHammer", opacity = 0x00, index = 2, 
					array = {propId = 10010}, 
					text = "tutorial.game.text1901", multRadius = 1.3,
					panType = "down", panAlign = "winY", panPosY = 400, 
					maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
					panelName1 = "guide_dialogue_10010_step1",
					panelName2 = "guide_dialogue_10010_step2",
					panelName3 = "guide_dialogue_10010_step3",
				},
			},
			disappear = {}
		}

		Guides[5000101011] = {--小木槌 弱引导
			appear = { 
				{type = "scene", scene = "game"},
				{type = "onceLevel"},
				{type = "staticBoard"},
				{type = "noPopup"},
				{type = "firstGuideOnLevel"},
				{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
				{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
				{type = "minCurrLevel", para = 31},
				{type = "notTimeLevel", para = 1},
				{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
				{type = "hasPropInBar" , para = 10010 },
				{type = "tagetLeft" , para = 2 },
				{type = "numMoveLeft", para = {4,1}},
				{type = "gameModeType", para = { 
												GameModeTypeId.LIGHT_UP_ID , 
												GameModeTypeId.ORDER_ID , 
												GameModeTypeId.DIG_MOVE_ID ,
												GameModeTypeId.DROP_DOWN_ID ,
												GameModeTypeId.SEA_ORDER_ID
											}},
				{type = "hasNoOtherGuide"},
				{type = "IngamePropGuideManager", para = {propId=10010, type='weak'}},
			},
			action = {

				[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
					array = {propId = 10010, type='weak'}, 
					text = "tutorial.game.text1901", multRadius = 1.3,
					panType = "down", panAlign = "winY", panPosY = 400, 
					maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
					panelName = "guide_dialogue_trigger_10010"
				},
			},
			disappear = {}
		}

		Guides[5000101012] = {--小木槌 弱引导
			appear = { 
				{type = "scene", scene = "game"},
				{type = "onceLevel"},
				{type = "staticBoard"},
				{type = "noPopup"},
				{type = "firstGuideOnLevel"},
				{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
				{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
				{type = "minCurrLevel", para = 31},
				{type = "notTimeLevel", para = 1},
				{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
				{type = "hasPropInBar" , para = 10010 },
				{type = "tagetLeft" , para = 2 },
				{type = "numMoveLeft", para = {4,1}},
				{type = "gameModeType", para = { 
												GameModeTypeId.LIGHT_UP_ID , 
												GameModeTypeId.ORDER_ID , 
												GameModeTypeId.DIG_MOVE_ID ,
												GameModeTypeId.DROP_DOWN_ID ,
												GameModeTypeId.SEA_ORDER_ID
											}},
				{type = "hasNoOtherGuide"},
				{type = "IngamePropGuideManager", para = {propId=10010, type='extra'}},
			},
			action = {
				[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
					array = {propId = 10010, type='extra'}, 
					text = "tutorial.game.text1901", multRadius = 1.3,
					panType = "down", panAlign = "winY", panPosY = 400, 
					maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
					panelName = "guide_dialogue_trigger_10010"
				},
			},
			disappear = {}
		}
	end
end

function TimelyHammerGuideMgr:shouldShowGuide( )

    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        local gameMode = mainLogic.theGamePlayType
        if gameMode then
            if gameMode == GameModeTypeId.JAMSPREAD_ID then
                return true
            end
        end
    end

    return self.useNewGuide
end

function TimelyHammerGuideMgr:handleGuide()
	if not self:shouldShowGuide() then return end
	local mainLogic = GameBoardLogic:getCurrentLogic()

	-- -- 游戏模式检测
	-- local replayMode = mainLogic.replayMode 
	-- if replayMode and replayMode ~= ReplayMode.kNone and 
	-- 	replayMode ~= ReplayMode.kResume and 
	-- 	replayMode ~= ReplayMode.kSectionResume then
	-- 	return 
	-- end

	--步数检测
	local stepsLeft = mainLogic.theCurMoves
	if stepsLeft > 3 then 
		self:removeGuide()
		return 
	end

    --果酱模式锤子特殊
    local gameMode = mainLogic.theGamePlayType
    self.HummerID = GamePropsType.kHammer

    if gameMode == GameModeTypeId.JAMSPREAD_ID then
        self.HummerID = GamePropsType.kJamSpeardHummer
    end

	--小木槌使用次数检测
	local findedItem = mainLogic.PlayUIDelegate.propList.leftPropList:findItemByItemID(self.HummerID)
	if findedItem and findedItem.prop then
		if findedItem.prop:isMaxUsed() then 
			self:removeGuide()
			return 
		end
	else
		self:removeGuide()
		return 
	end

	if gameMode == GameModeTypeId.LIGHT_UP_ID then
		self:handleLightUpMode()
	elseif gameMode == GameModeTypeId.SEA_ORDER_ID then
		self:handleSeaOrderMode()
	elseif gameMode == GameModeTypeId.LOTUS_ID then
		self:handleLotusMode()
	elseif gameMode == GameModeTypeId.DIG_MOVE_ID then
		self:handleDigMoveMode()
	elseif gameMode == GameModeTypeId.DROP_DOWN_ID then
		-- self:handleDropDownMode()
	elseif gameMode == GameModeTypeId.ORDER_ID or
        gameMode == GameModeTypeId.JAMSPREAD_ID then
		self:handleOrderMode()
	end
end

function TimelyHammerGuideMgr:handleLightUpMode()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic.kLightUpLeftCount == self.targetLimit then
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local board = mainLogic.boardmap[r][c]
				if board.isUsed == true and board.iceLevel > 0 then
					if self:hammerSelfCheck(r, c, TargetType.kIce) then
						self:showGuide(r, c)
						return 
					end
				end
			end
		end
	end
	self:removeGuide()
end

function TimelyHammerGuideMgr:handleSeaOrderMode()
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local allAnimals = mainLogic.gameMode.allSeaAnimals
    local iceLevel = 0
    local row, column
    if allAnimals then
        for k, v in pairs(allAnimals) do
            for r = v.y, v.yEnd do 
                for c = v.x, v.xEnd do
                	local _iceLevel = mainLogic.boardmap[r][c].iceLevel
                	if _iceLevel then
                		if _iceLevel > 0 then 
                			iceLevel = iceLevel + _iceLevel
                		end
                		if iceLevel > 1 then
                			self:removeGuide()
                			return 
                		end
                		if _iceLevel == 1 then
                			row = r
                			column = c
                		end
                	end
                end
            end
        end
        if iceLevel == 1 then
			if self:hammerSelfCheck(row, column, TargetType.kSeaAnimal) then
				self:showGuide(row, column)
				return 
			end
        end
    end
    self:removeGuide()
end

function TimelyHammerGuideMgr:handleLotusMode()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic.currLotusNum == self.targetLimit then
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local board = mainLogic.boardmap[r][c]
				if board.isUsed == true and board.lotusLevel == 1 then
					if self:hammerSelfCheck(r, c, TargetType.kLotus) then
						self:showGuide(r, c)
						return 
					end
				end
			end
		end
	end
	self:removeGuide()
end

function TimelyHammerGuideMgr:handleDigMoveMode()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic.digJewelLeftCount == self.targetLimit then
		local digJewelsPos = {}
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if item and item.ItemType == GameItemType.kDigJewel and 
					item.digJewelLevel and item.digJewelLevel == 1 and mainLogic:canUseHammer(r, c) then
					table.insert(digJewelsPos, {r=r, c=c})
				end
			end
		end
		if #digJewelsPos > 0 then
			local randomId = mainLogic.randFactory:rand(1, #digJewelsPos)
			local targetPos = digJewelsPos[randomId]
			self:showGuide(targetPos.r, targetPos.c)
			return
		end
	end
	self:removeGuide()
end

function TimelyHammerGuideMgr:handleDropDownMode()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local ingredientsLeft = mainLogic.ingredientsTotal - mainLogic.ingredientsCount
	if ingredientsLeft == self.targetLimit then
		for r = 1, #mainLogic.gameItemMap - 1 do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if item and item.ItemType == GameItemType.kIngredient then
					local columnNextItem = mainLogic.gameItemMap[r+1][c]
					local columnNextBoard = mainLogic.boardmap[r+1][c]
					if columnNextBoard and columnNextBoard.isCollector and columnNextItem and self:hammerEffectCheck(mainLogic, r+1, c, TargetType.kCommon) then 
						self:showGuide(r+1, c)
						return 
					end
				end
			end
		end
	end
	self:removeGuide()
end

function TimelyHammerGuideMgr:handleOrderMode()
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local targetInfo = {num = 0}
	for i,v in ipairs(mainLogic:getViewableOrderList()) do
		local numLeft = v.v1 - v.f1 
		if numLeft > 0 then 
			targetInfo.num = targetInfo.num + numLeft
			if numLeft == 1 then
				targetInfo.target = v
			end
		end
    end
    local guideShow = false
    if targetInfo.num == 1 then
    	local target = targetInfo.target
    	for i,v in ipairs(TargetConfig) do
    		if target.key1 == v.keyMain and target.key2 == v.keySub then
    			if target.key1 == GameItemOrderType.kOthers and target.key2 == GameItemOrderType_Others.kBiscuit then
    				guideShow = self:handleBiscuit(v.targetType)
    			else
    				guideShow = self:handleOrder(v.keySource, v.condition, v.targetType)
    			end
    		end
    	end
    end

    if not guideShow then 
    	self:removeGuide()
    end
end


-- 饼干特殊的逻辑 不通用
function TimelyHammerGuideMgr:handleBiscuit( targetType )
	local mainLogic = GameBoardLogic:getCurrentLogic()

	local allBiscuitBoardData = {}

	for r = 1, #mainLogic.boardmap do
		for c = 1, #mainLogic.boardmap[r] do
			local boardData = mainLogic.boardmap[r][c]
			if boardData and boardData.isUsed then
				if boardData.biscuitData then
					table.insert(allBiscuitBoardData, boardData)
				end
			end
		end
	end

	if #allBiscuitBoardData == 1 then
		local boardData = allBiscuitBoardData[1]
		local biscuitData = boardData.biscuitData
		local curMilks = 0

		local r, c

		for milkRow, v in ipairs(biscuitData.milks) do
			for milkCol, vv in ipairs(v) do
				curMilks = curMilks + vv
				if vv < 3 then
					r = milkRow + boardData.y - 1
					c = milkCol + boardData.x - 1
				end
			end
		end
		local totalMilks = biscuitData.nRow * biscuitData.nCol * 3

		if totalMilks - curMilks == 1 then
			if self:hammerSelfCheck(r, c, targetType) then
				self:showGuide(r, c) 
				return true
			end
		end
	end
end

function TimelyHammerGuideMgr:handleOrder(keySource, condition, targetType)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local dataSource
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			if keySource == KeySourceType.kItem then
				dataSource = mainLogic.gameItemMap[r][c]
			elseif keySource == KeySourceType.kBoard then 
				dataSource = mainLogic.boardmap[r][c]
			end

			if dataSource and dataSource.isUsed then
				local conditionResult = false
				for i,v in ipairs(condition) do
					conditionResult = dataSource[v.key] == v.value
				end
				if conditionResult then
				 	if self:hammerSelfCheck(r, c, targetType) then
						self:showGuide(r, c) 
						return true
					end
				end
			end
		end
	end
end

--敲自己
function TimelyHammerGuideMgr:hammerSelfCheck(row, column, targetType)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic:canUseHammer(row, column) then
		if targetType == TargetType.kCommon or targetType == TargetType.kCuteBall or 
			targetType == TargetType.kHoney or targetType == TargetType.kBlockerCover then
			return self:hammerEffectCheck(mainLogic, row, column, targetType)
		elseif targetType == TargetType.kIce or targetType == TargetType.kSeaAnimal then
			return SpecialCoverLogic:canEffectLightUpAt(mainLogic, row, column, true)
		elseif targetType == TargetType.kSand then 
			return SpecialCoverLogic:canEffectSandAtPos(mainLogic, row, column, false)
		elseif targetType == TargetType.kBlockerCoverMaterial then
			return SpecialCoverLogic:canEffectblockerCoverMaterial(mainLogic, row, column)
		elseif targetType == TargetType.kLotus then
			return SpecialCoverLogic:canEffectLotusAt(mainLogic, row, column)
        elseif targetType == TargetType.kJamSperad then
            local bStop = mainLogic:CheckPosCanStopJamSperad(IntCoord:create(row, column))
			return not bStop
		elseif targetType == TargetType.kBiscuit then
			return SpecialCoverLogic:canApplyMilkAt(mainLogic, row, column)
		end
	end
	return false
end

--判断能否直接锤爆item本身（这里判断的 都是优先于item被锤的）
function TimelyHammerGuideMgr:hammerEffectCheck(mainLogic, r, c, targetType)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	if item.beEffectByMimosa > 0 or 
		board.lotusLevel > 1 or 
		board.colorFilterBLevel > 0 or 
		item:hasActiveSuperCuteBall() or
		item.cageLevel ~= 0 or
		item.olympicLockLevel > 0 or
		item:seizedByGhost() then
		return false 
	end
	if targetType == TargetType.kCommon then
		if item:hasFurball() or
			item.honeyLevel ~= 0 or 
			item.blockerCoverLevel > 0 then
			return false 
		end
	elseif targetType == TargetType.kCuteBall then
		if item.honeyLevel ~= 0 or 
			item.blockerCoverLevel > 0 then
			return false 
		end
	elseif targetType == TargetType.kHoney then
		if item.blockerCoverLevel > 0 then
			return false 
		end
	end
	return true
end

function TimelyHammerGuideMgr:showGuide(row, column)
	if not self:shouldShowGuide() then return end

	if _G.isLocalDevelopMode then print("zhijian=========TimelyHammerGuideMgr:showGuide====", row, column, self.resLoaded) end
	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not self.hasDC then 
		self.hasDC = true
		DcUtil:timelyHammerGuide(mainLogic.level)
	end
	if not self.resLoaded then
		-- UIHelper:loadArmature('skeleton/timely_hammer_guide', "timely_hammer_guide", "timely_hammer_guide")
		FrameLoader:loadArmature('skeleton/timely_hammer_guide', "timely_hammer_guide", "timely_hammer_guide")
		self.resLoaded = true 
	end
	
	if not self.targetAni then
		local container = Layer:create()
		local animation = ArmatureNode:create("timely_hammer_guide/target")
		if not animation then
			if _G.isLocalDevelopMode then print("zhijian=========TimelyHammerGuideMgr:self.resLoaded====", self.resLoaded) end
			self.resLoaded = false
			return 
		end
		animation:update(0.001)
		animation:play("show", 1)

		container:addChild(animation:wrapWithBatchNode())
		container.body = animation

		self.targetAni = container

		local width = mainLogic:getSingleGridWidth(mainLogic.PlayUIDelegate.otherElementsLayer)
		self.targetAni:setScale(width/70)
		mainLogic.PlayUIDelegate.otherElementsLayer:addChild(self.targetAni)
	else
		self.targetAni.body:play("show", 1)
	end
	-- self.targetAni:setVisible(true)
	local pos = mainLogic:getGameItemPosInView(row, column)
	self.targetAni:setPosition(ccp(pos.x, pos.y))
	self.targetAni.isShow = true
	self.targetAni.body:removeAllEventListeners()
	self.targetAni.body:addEventListener(ArmatureEvents.COMPLETE, function ()
		if self.targetAni and self.targetAni.body and not self.targetAni.body.isDisposed then 
			self.targetAni.body:play("blink", 0)
		end
	end)

	if not self.bubbleAni then
        --
        local AnimName = "timely_hammer_guide/bubble"
        local gameMode = mainLogic.theGamePlayType
        if gameMode then
            if gameMode == GameModeTypeId.JAMSPREAD_ID then
                AnimName = "timely_hammer_guide/bubble2"
            end
        end

        --
		local container = Layer:create()
		local animation = ArmatureNode:create(AnimName)
		animation:update(0.001)
		animation:play("show", 1)
		container:addChild(animation:wrapWithBatchNode())
		container.body = animation

		self.bubbleAni = container

		if mainLogic.PlayUIDelegate.propList and mainLogic.PlayUIDelegate.propList.leftPropList then
			local findedItem = mainLogic.PlayUIDelegate.propList.leftPropList:findItemByItemID(self.HummerID)
			if findedItem and findedItem.item then
				findedItem.item:addChildAt(self.bubbleAni, 4) 

                local mainLogic = GameBoardLogic:getCurrentLogic()
                local gameMode = mainLogic.theGamePlayType
                if gameMode == GameModeTypeId.JAMSPREAD_ID then
				    self.bubbleAni:setPosition(ccp(31 ,62))
                else
                    -- self.bubbleAni:setPosition(ccp(-33 ,56))
                    self.bubbleAni:setPosition(ccp(29, 59))
                end
			end
		end
	else 
		if not self.bubbleAni.isShow then 
			self.bubbleAni.body:play("show", 1)
		end
	end
	self.bubbleAni.isShow = true
	self.bubbleAni.body:removeAllEventListeners()
end

function TimelyHammerGuideMgr:removeGuide(clean)
	if not self:shouldShowGuide() then return end
	if _G.isLocalDevelopMode then print("zhijian=========TimelyHammerGuideMgr:removeGuide====") end
	if self.targetAni and self.targetAni.body and self.targetAni.isShow then
		self.targetAni.isShow = false
		self.targetAni.body:removeAllEventListeners()
		if clean then
			self.targetAni:removeFromParentAndCleanup(true) 
			self.targetAni = nil
		else
			self.targetAni.body:play("hide", 1)
			self.targetAni.body:addEventListener(ArmatureEvents.COMPLETE, function ()
				if self.targetAni and self.targetAni.body and not self.targetAni.body.isDisposed then 
					self.targetAni.body:stop()
				end
			end)
		end
	end

	if self.bubbleAni and self.bubbleAni.body and self.bubbleAni.isShow then
		self.bubbleAni.isShow = false
		self.bubbleAni.body:removeAllEventListeners()
		if clean then
		 	self.bubbleAni:removeFromParentAndCleanup(true) 
		 	self.bubbleAni = nil
		else
	 		self.bubbleAni.body:play("hide", 1)
		 	self.bubbleAni.body:addEventListener(ArmatureEvents.COMPLETE, function ()
				if self.bubbleAni and self.bubbleAni.body and not self.bubbleAni.body.isDisposed then 
					self.bubbleAni.body:stop()
				end
			end)
	 	end
	end
end

function TimelyHammerGuideMgr:hideGuide()
	if self.targetAni and self.targetAni.body and self.targetAni.isShow then
		-- self.targetAni:setVisible(false)
		self.targetAni.body:play("hide", 1)
		self.targetAni.body:addEventListener(ArmatureEvents.COMPLETE, function ()
			if self.targetAni and self.targetAni.body and not self.targetAni.body.isDisposed then 
				self.targetAni.body:stop()
			end
		end)
	end
end

function TimelyHammerGuideMgr:clear()
--	if not self:shouldShowGuide() then return end

	self.targetAni = nil
	self.bubbleAni = nil
	self.resLoaded = false
	self.hasDC = false
    self.HummerID = nil
	-- UIHelper:unloadArmature('skeleton/timely_hammer_guide', true)
	FrameLoader:unloadArmature('skeleton/timely_hammer_guide', true)
end

-- local SpecialItemType = {
-- 	kLine = 0,
-- 	kWrap = 1,
-- }
-- --敲特效（敲了某个特效后 可以影响到自己）
-- function TimelyHammerGuideMgr:hammerSpecialCheck(row, column, targetType)
-- 	local mainLogic = GameBoardLogic:getCurrentLogic()
-- 	local item = mainLogic.gameItemMap[r][c]
-- 	if item:canBeEliminateBySpecial() then
-- 		local allCheckPos = self:getSpecialCheckPos(row, column)
-- 	end
-- end

-- --获取不考虑连锁情况下 可以影响到某个格子的所有特效
-- function TimelyHammerGuideMgr:getSpecialCheckPos(centerR, centerC)
-- 	local allCheckPos = {}
-- 	local mainLogic = GameBoardLogic:getCurrentLogic()

-- 	local function insertFourCorner(r, c)
-- 		local item = mainLogic.gameItemMap[r][c]
-- 		if item and item.ItemSpecialType == AnimalTypeConfig.kWrap and item:isVisibleAndFree() then 	--还需要检测是否能敲炸
-- 			local pos = {}
-- 			pos.r = r
-- 			pos.c = c
-- 			table.insert(allCheckPos, pos) 
-- 		end
-- 	end
-- 	insertFourCorner(centerR - 1, centerC - 1)
-- 	insertFourCorner(centerR - 1, centerC + 1)
-- 	insertFourCorner(centerR + 1, centerC + 1)
-- 	insertFourCorner(centerR + 1, centerC - 1)

-- 	local ignoreLeftLineEffect = false 
-- 	local function insertByRow(r)
-- 		local pos = {}
-- 		pos.r = r
-- 		pos.c = centerC
-- 		local item = mainLogic.gameItemMap[r][centerC]
-- 		if item and item:isVisibleAndFree() then
-- 			if r >= centerR - 2 and r <= centerR + 2 and item.ItemSpecialType == AnimalTypeConfig.kWrap then 
-- 				table.insert(allCheckPos, pos) 
-- 			elseif item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kPuffer then
-- 				ignoreLeftLineEffect = true 
-- 			elseif not ignoreLeftLineEffect and (item.ItemSpecialType == AnimalTypeConfig.kLine or item.ItemSpecialType == AnimalTypeConfig.kColumn) then 
-- 				table.insert(allCheckPos, pos) 
-- 			end
-- 		end 
-- 	end

-- 	local function insertByColumn(c)
-- 		local pos = {}
-- 		pos.r = centerR
-- 		pos.c = c
-- 		local item = mainLogic.gameItemMap[centerR][c]
-- 		if item and item:isVisibleAndFree() then
-- 			if c >= centerC - 2 and c <= centerC + 2 and item.ItemSpecialType == AnimalTypeConfig.kWrap then 
-- 				table.insert(allCheckPos, pos) 
-- 			elseif item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kPuffer then
-- 				ignoreLeftLineEffect = true 
-- 			elseif not ignoreLeftLineEffect and (item.ItemSpecialType == AnimalTypeConfig.kLine or item.ItemSpecialType == AnimalTypeConfig.kColumn) then 
-- 				table.insert(allCheckPos, pos) 
-- 			end
-- 		end 
-- 	end

-- 	for r=centerR - 1, 1, -1 do
-- 		insertByRow(r)
-- 	end

-- 	ignoreLeftLineEffect = false
-- 	for r=centerR + 1, 9 do
-- 		insertByRow(r)
-- 	end

-- 	ignoreLeftLineEffect = false
-- 	for c=centerC - 1, 1, -1 do
-- 		insertByColumn(c)
-- 	end

-- 	ignoreLeftLineEffect = false
-- 	for c=centerC + 1, 9 do
-- 		insertByColumn(c)
-- 	end

-- 	return allCheckPos
-- end