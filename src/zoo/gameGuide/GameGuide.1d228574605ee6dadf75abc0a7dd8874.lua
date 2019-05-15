require "hecore.utils"
require "zoo.data.UserManager"
require "zoo.gameGuide.Guides"
require "zoo.gameGuide.GameGuideData"
require "zoo.gameGuide.GameGuideCheck"
require "zoo.gameGuide.GameGuideRunner"

if PublishActUtil:isGroundPublish() then return end
GameGuide = class{}

local UsePropGuideKeys = {500010401,500010402,500010403,500010404, 500010405, 500010406}

local guide = nil
function GameGuide:sharedInstance()
	if not guide then
		guide = GameGuide.new()
		if guide:init() then
			return guide
		end
		return nil
	end
	return guide
end

function GameGuide:isPreBuffBoomAndBirdLevel(levelId)
    if levelId <= 20 then return false end
    local levelIds = {17,28,36,49,66,84,97,103, 19, 26, 46, 406, 736, 796, 841, 849, 10009}
    if table.exist(levelIds, levelId) then
    	return false
    end
    
    if GameGuide:isNoPreBuffLevel(levelId) then return false end
    return true
end

function GameGuide:isNoPreBuffLevel(levelId)
	local timeLevels = { 17,28,36,49,66,84,97,103, 
						19, 26, 46, 406, 736, 796, 841, 849, 10009}
	local hasSeed = (GuideSeeds[levelId] ~= nil)
	-- local isTopLevel = UserManager:getInstance().user:getTopLevelId() == levelId
	-- local notPassed = not UserManager:getInstance():hasPassedLevelEx(levelId)
	local timeLevel = table.exist(timeLevels, levelId)
	-- 应用种子的关卡
	-- 或者时间关
	-- 不能使用前置buff
	return hasSeed or timeLevel
end

function GameGuide:ctor()
	GameGuideData:sharedInstance()
end

function GameGuide:init()

	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_panels.strings')
	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_panels_2.strings')
	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_panels_3.strings')
	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_panels_4.strings')
	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_panels_act.strings')
	Localization:getInstance():loadFile('guideText/GameGuideDialogues_game_guide_prop.strings')
	local data = GameGuideData:sharedInstance()
	if __WIN32 then GameGuideCheck:verifyGuideConditions(Guides) end
	data:setGuides(Guides)
	data:setGuideSeed(GuideSeeds)
	data:readFromFile()

	GameGuide.isInited = true
	return true
end

function GameGuide:currentGuideType()
	local action = GameGuideData:sharedInstance():getRunningAction()
	if not action then return nil end
	return action.type
end

-- 进入藤蔓界面
function GameGuide:onEnterWorldMap()
	local data = GameGuideData:sharedInstance()
	data:setScene("worldMap")
	data:resetLevelId()
	data:resetNumMoves()
	data:resetSkipLevel()
	data:resetGameFlags()
	data:resetCurLevelGuide()
	data:resetContinuousFailedNum()
	data:setGameStable(false)
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

-- 强行停止现有引导
function GameGuide:forceStopGuide()
	GameGuideData:sharedInstance():setForceStop(true)
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

-- 尝试开始一个新引导
function GameGuide:tryStartGuide()
	GameGuideData:sharedInstance():resetForceStop()
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

function GameGuide:onClickReplay()
	local data = GameGuideData:sharedInstance()
	data:resetNumMoves()
end

-- 弹出窗口
function GameGuide:onPopup(panel)
	local data = GameGuideData:sharedInstance()
	if panel.panelName ~= "noName" then
		data.currPopPanel = panel
	end
	data:setPopups(data:getPopups() + 1)
	local para = {actWin = panel}
	self:tryEndCurrentGuide(para)
	return self:tryRunNewGuide(para)
end

-- 窗口消失
function GameGuide:onPopdown(panel)
	local data = GameGuideData:sharedInstance()
	data.currPopPanel = nil
	data:setPopups(data:getPopups() - 1)
	local para = {actWin = panel}
	self:tryEndCurrentGuide(para)
	return self:tryRunNewGuide(para)
end

function GameGuide:setRepeatGuide(value)
	self._allowRepeat = value
end

function GameGuide:isRepeatGuide()
	return self._allowRepeat
end

-- 游戏初始化
function GameGuide:onGameInit(level)
	-- printx( -5 , " ++++++++++++++++++++++ GameGuide:onGameInit +++++++++++++++++++++++++")
	local data = GameGuideData:sharedInstance()
	data:setScene("game")
	data:setLastSwapTime(Localhost:timeInSec())
	data:setLevelId(level)
	data:resetNumMoves()
	data:resetSkipLevel()
	data:resetGameFlags()
	data:resetGuideInLevel()
	data:resetGuideLevelFlag()
	data:resetCurLevelGuide()
	data:resetContinuousFailedNum()
	data:resetUsePropLog(propId)
	data:resetUsePropId()
	data:setGameStable(false)

	local guidedOnToday = data:getGuidedOnToday()
	if not guidedOnToday then
		guidedOnToday = {}
	end

	local today = os.date( "%x" , Localhost:timeInSec() ) 
	-- printx( -5 , " +++++++++++++++++++++++++++++++++++++++++++++++")
	-- printx( -5 , " guidedOnToday" , today )

	if guidedOnToday.today ~= today then
		-- printx( -5 , " NEW DAY   guidedOnToday.today = " , guidedOnToday.today , "  today " , today )
		guidedOnToday = {}
		guidedOnToday.today = today
	end

	data:setGuidedOnToday( guidedOnToday )
	data:writeToFile()

	self:tryEndCurrentGuide()
	-- data:resetRunningGuide()
	-- data:resetRunningAction()
	local rt = self:tryRunNewGuide()
	local seed
	local repeatGuide = self:checkAllowRepeatGuide(level)
	if self:checkHaveGuide(level) or repeatGuide then 
		seed = data:getGuideSeedByLevelId(level)
	else 
		seed = 0
	end
	return seed, repeatGuide
end

-- 游戏进入后动画播放结束
function GameGuide:onGameAnimOver()
	local data = GameGuideData:sharedInstance()
	data:setScene("game")
	data:setNumMoves(0)
	data:setLastSwapTime(Localhost:timeInSec())
	data:setGameStable(true)
	local levelId = data:getLevelId()
	data:setContinuousFailedNum( FUUUManager:getLevelContinuousFailNumForGuide(levelId) )
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

-- 进行了一次交换
function GameGuide:onGameSwap(from, to)
	local data = GameGuideData:sharedInstance()
	data:setLastSwapTime(Localhost:timeInSec())
	data:setScene("game")
	data:setGameStable(false)
	data:setNumMoves(data:getNumMoves() + 1)
	self:tryEndCurrentGuide({from, to})

	if self.hasNoOperationTimer then
		TimerUtil.removeAlarm(self.hasNoOperationTimer)
		self.hasNoOperationTimer = nil
	end

	self.hasNoOperationTimer = TimerUtil.addAlarm(function ()
		local mainLogic = GameBoardLogic:getCurrentLogic()
		if mainLogic and mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then
			GameGuide:sharedInstance():onTimeoutAfterSwap()
		end
	end, 10 , 1)

	return self:tryRunNewGuide({from, to})
end

function GameGuide:onTimeoutAfterSwap()
	--printx( -5 , "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  GameGuide:onTimeoutAfterSwap ")
	local data = GameGuideData:sharedInstance()
	if self.hasNoOperationTimer and not data:getRunningGuide() then
		self:tryEndCurrentGuide()
		--printx( -5 , "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  GameGuide:onTimeoutAfterSwap   self:tryRunNewGuide()")
		return self:tryRunNewGuide()
	end	
end

function GameGuide:onBeforeUseProp( propId )
	local data = GameGuideData:sharedInstance()
	data:setUsePropId(propId)
	return self:tryStartGuide()
end

function GameGuide:onCancelUseProp()
	local data = GameGuideData:sharedInstance()
	data:resetUsePropId()
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

function GameGuide:onUseProp(propsType, r1, c1, r2, c2)
	local data = GameGuideData:sharedInstance()
	data:addToUsePropLog(propsType)
	data:setScene("game")
	if propsType == GamePropsType.kLineBrush 
		or propsType == GamePropsType.kLineBrush_l 
		or propsType == GamePropsType.kLineBrush_b
	then
		-- brush道具不会改变棋盘状态
	else
		data:setGameStable(false)
	end
	data:resetUsePropId()
	self:tryEndCurrentGuide({ propId=propsType })
	return self:tryRunNewGuide()
end

function GameGuide:onHalloweenBossFirstComeout(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("halloweenBossFirstComeout")
	local array = data:getGuideActionById(250007, 1).array[1]
	-- data:getGuides()[250001].appear[6] = nil
	array.r = pos.r + 1
	array.c = pos.c
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

function GameGuide:onHalloweenBossDie()
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("halloweenBossDie")
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

function GameGuide:onHedgehogCrazy( pos )
	-- body
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("hedgehogCrazy")
	self:tryEndCurrentGuide()
	local result = self:tryRunNewGuide(pos)
	data:removeFromGameFlags("hedgehogCrazy")
	return result
end

function GameGuide:onHedgehogCrazyClick( paras)
	-- body
	local data = GameGuideData:sharedInstance()
	self:tryEndCurrentGuide({value = "click"})
end

function GameGuide:onWukongCrazy( pos )
	-- body
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("wukongCrazy")
	self:tryEndCurrentGuide()
	local result = self:tryRunNewGuide(pos)
	data:removeFromGameFlags("wukongCrazy")
	return result
end

function GameGuide:onWukongCrazyClick( paras)
	-- body
	local data = GameGuideData:sharedInstance()
	self:tryEndCurrentGuide({value = "click"})
end

function GameGuide:onWukongGuideJump( pos , flags )
	-- body
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags( flags )
	self:tryEndCurrentGuide()
	local result = self:tryRunNewGuide(pos)
	data:removeFromGameFlags( flags )
	return result
end

function GameGuide:onGoldZongziAppear(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("goldZongziAppear")
	-- local array = data:getGuideActionById(220002, 1).array[1]
	-- data:getGuides()[220002].action[6] = nil
	local array = data:getGuideActionById(250008, 1).array[1]
	array.r = pos.r
	array.c = pos.c
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

function GameGuide:tryFirstQuestionMark(row, col)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstQuestionMark")
	data:getGuideActionById(2303512, 1).array[1].r = row
	data:getGuideActionById(2303512, 1).array[1].c = col
	data:getGuideActionById(2303512, 1).panPosY = row - data:getGuideActionById(2303512, 1).offsetY
	self:tryEndCurrentGuide()
	local guide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstQuestionMark")
	return guide
end

function GameGuide:tryFirstChestSquare(row, col)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstChestSquare")
	data:getGuideActionById(2303516, 1).array[1].r = row + 1
	data:getGuideActionById(2303516, 1).array[1].c = col 
	data:getGuideActionById(2303516, 1).panPosY = row - data:getGuideActionById(2303516, 1).offsetY
	self:tryEndCurrentGuide()
	local guide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstChestSquare")
	return guide
end

function GameGuide:onFirstShowFirework(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstShowFirework")
	-- data:getGuideActionById(210000, 1).position = pos
	data:getGuideActionById(2303510, 1).position = pos
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstShowFirework")
	return newGuide
end

function GameGuide:tryFirstFullFirework(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstFullFirework")
	-- data:getGuideActionById(210002, 1).position = pos
	data:getGuideActionById(2303513, 1).position = pos
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstFullFirework")
	return newGuide
end

function GameGuide:tryFirstBuyFirework(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstBuyFirework")
	data:getGuideActionById(2303517, 1).position = pos
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstBuyFirework")
	return newGuide
end

function GameGuide:tryFirstBuyMoleWeekFirework(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("firstBuyMoleWeekFirework")
	data:getGuideActionById(310000014, 1).position = pos
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("firstBuyMoleWeekFirework")
	return newGuide
end

function GameGuide:trySwapCrystalStonesGuide(pos1, pos2)
	if not pos1 or not pos2 then return end

	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("twoCrystalStones")

	local action = data:getGuideActionById(7300, 1)
	local first, second = pos1, pos2
	if pos2.x < pos1.x or pos2.y < pos1.y then
		first, second = pos2, pos1
	end
	local row = math.abs(second.x - first.x) + 1
	local col = math.abs(second.y - first.y) + 1
	action.array = {{r = first.x, c = first.y, countR = 1, countC = 1}, {r = second.x, c = second.y, countR = 1, countC = 1}}
	if col > 1 then
 		action.allow = {r = first.x, c = first.y, countR = row, countC = col}
 	elseif row > 1 then
 		action.allow = {r = second.x, c = second.y, countR = row, countC = col}
 	end
 	action.from = ccp(first.x, first.y)
 	action.to = ccp(second.x, second.y)
 	local maxR = math.max(first.x, second.x)
 	if maxR <= 5 then
	 	action.panPosY = maxR + 1
	 	action.panType = "up"
 	else
 		local minR = math.min(first.x, second.x)
	 	action.panPosY = minR - 4.5
	 	action.panType = "down"
 	end

 	local guide = data:getGuideById(7300)
 	guide.disappear = nil
 	guide.disappear = {{type = "swap", from = ccp(first.x, first.y), to = ccp(second.x, second.y)}}

	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("twoCrystalStones")
	return newGuide
end

function GameGuide:tryLevelStrategyGuide(pos1, size1, panPosY1, pos2, size2, panPosY2)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("forceLevelStrategyGuide")
	data:getGuideActionById(3000000, 1).position = pos1
	data:getGuideActionById(3000000, 1).width = size1.width 
	data:getGuideActionById(3000000, 1).height = size1.height 
	data:getGuideActionById(3000000, 1).panPosY = panPosY1 

	data:getGuideActionById(3000000, 2).position = pos2
	data:getGuideActionById(3000000, 2).width = size2.width 
	data:getGuideActionById(3000000, 2).height = size2.height 
	data:getGuideActionById(3000000, 2).panPosY = panPosY2 
	self:tryEndCurrentGuide()
	local guide = self:tryRunNewGuide()
	data:removeFromGameFlags("forceLevelStrategyGuide")
	return guide
end


function GameGuide:onShowFullFireworkTip(pos)
	local data = GameGuideData:sharedInstance()
	if not data:containInGuidedIndex(2303514) then -- 将首次引导置为不可用
		data:addToGuidedIndex(2303514)
		data:writeToFile()
	end

	data:addToGameFlags("showFullFireworkTip")
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("showFullFireworkTip")
	return newGuide
end

function GameGuide:onShowForceUse(pos)
	local data = GameGuideData:sharedInstance()
	data:addToGameFlags("forceUseFullFirework")
	data:getGuideActionById(2303515, 1).position = pos
	self:tryEndCurrentGuide()
	local newGuide = self:tryRunNewGuide()
	data:removeFromGameFlags("forceUseFullFirework")
	return newGuide
end

-- 游戏中获得了一个道具
function GameGuide:onGetGameItem(itemType)
	local data = GameGuideData:sharedInstance()
	data:setGameStable(true)
	local para = {item = itemType}
	self:tryEndCurrentGuide(para)
	local res = self:tryRunNewGuide(para)
	return res
end

-- 游戏达到稳定状态
function GameGuide:onGameStable()
	local data = GameGuideData:sharedInstance()
	data:setScene("game")
	data:setGameStable(true)
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

-- 离开游戏
function GameGuide:onExitGame()
	-- if _G.isLocalDevelopMode then printx(0, 'GameGuide:onExitGame()') end
	-- debug.debug()

	if self.hasNoOperationTimer then
		TimerUtil.removeAlarm(self.hasNoOperationTimer)
		self.hasNoOperationTimer = nil
	end

	self:setRepeatGuide(false)
	local data = GameGuideData:sharedInstance()
	data:resetScene()
	data:resetNumMoves()
	data:resetSkipLevel()
	data:resetUsePropLog()
	data:resetContinuousFailedNum()
	data:resetNewPreProp()
	self:tryEndCurrentGuide()
	return self:tryRunNewGuide()
end

-- 尝试进行一个新的引导
function GameGuide:tryRunNewGuide(paras)
	-- print("function GameGuide:tryRunNewGuide(paras)      000")
	-- print("function GameGuide:tryRunNewGuide(paras)      000")
	-- print("function GameGuide:tryRunNewGuide(paras)      000")

	local mainLogic = GameBoardLogic:getCurrentLogic()
	if mainLogic and mainLogic.replayMode and mainLogic.replayMode == ReplayMode.kStrategy then
		-- print("function GameGuide:tryRunNewGuide(paras)      111")
		return 
	end
	local data = GameGuideData:sharedInstance()
	if data:getRunningGuide() then return end

	local firstGuideIndex = self:getFirstGuide(paras)
	data:setGuideIndex( firstGuideIndex )
--	print( -5 , " GameGuide:tryRunNewGuide  " , data:getRunningGuide() )
	if data:getRunningGuide() then
		-- print("function GameGuide:tryRunNewGuide(paras)      333")
		data:setActionIndex(1)
	--	print( -5 , " GameGuide:tryRunNewGuide   GameGuideRunner:runGuide(paras)")
		GameGuideRunner:runGuide(paras)
		if not data:getRunningGuide() or not data:getGuideIndex() then return false end
		data:addToGuideInLevel(data:getGuideIndex())

		if not table.exist(UsePropGuideKeys,data:getGuideIndex()) then
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic and mainLogic.level then
				data:addToGuideLevelFlag(mainLogic.level)
			end
		end
		
		return data:getRunningAction().type ~= "clickFlower" and
			data:getRunningAction().type ~= "startPanel" and
			data:getRunningAction().type ~= "showHint"
	end
	return false
end

-- 尝试结束一个引导
function GameGuide:tryEndCurrentGuide(paras)
	local data = GameGuideData:sharedInstance()
	if not data:getRunningGuide() then return end
	if self:checkDisappear(paras) then
		local rec, success = GameGuideRunner:removeGuide(paras)
		if rec then
			if not data:containInGuidedIndex(data:getGuideIndex()) then
				data:addToGuidedIndex(data:getGuideIndex())
				DcUtil:tutorialStep(data:getGuideIndex())
				if table.size(data:getGuidedIndex()) >= table.size(data:getGuides()) then
					DcUtil:tutorialFinish()
				end
				data:writeToFile()
			end
			data:addToCurLevelGuide(data:getGuideIndex())
		end
		if success then
			data:addToCurSuccessGuide(data:getGuideIndex())
			self:markGuideFlagCompleted(data:getGuideIndex())
		end
		data:resetRunningGuide()
		data:resetRunningAction()
	end
end

-- 检查本关是否有可显示的引导
function GameGuide:checkHaveGuide(level)
	local data = GameGuideData:sharedInstance()
	local scene = data:getScene()
	local levelId = data:getLevelId()
	local gameStable = data:getGameStable()
	data:setScene("game")
	data:setLevelId(level)
	data:setGameStable(true)
	for k, v in pairs(GameGuideData:sharedInstance():getGuides()) do
		local list = {{type="scene", force=true},
			{type="topLevel"},
			{type="onceOnly"},
			{type="curLevelGuided"}}
		if GameGuideCheck:checkFixedAppears(v, list, {forceLevel = true}, k) then
			data:setScene(scene)
			data:setLevelId(levelId)
			data:setGameStable(gameStable)
			return true
		end
	end
	data:setScene(scene)
	data:setLevelId(levelId)
	data:setGameStable(gameStable)
	return false
end

function GameGuide:checkAllowRepeatGuide(level)
	local data = GameGuideData:sharedInstance()
	local scene = data:getScene()
	local levelId = data:getLevelId()
	data:setScene("game")
	data:setLevelId(level)
	data:setNumMoves(0)
	for k, v in pairs(GameGuideData:sharedInstance():getGuides()) do
		if GameGuideCheck:checkFixedAppears(v, {{type='scene', force=true}, {type='numMoves', force=true}}, {forceLevel = true}, k) then
			local topLevel = nil
			for index, appear in pairs(v.appear) do
				if appear.type == 'topLevel' and appear.para ~= nil then
					topLevel = appear
				end
			end
			-- 如果配了topLevel,那只要当前不是topLevel就可以重复引导
			-- 如果没有配topLevel，那就要这关引导从来没有跑过才可以重复引导
			if topLevel and UserManager:getInstance().user:getTopLevelId() > level then
				return true
			elseif not topLevel and data:containInGuidedIndex(k) then
				return true
			end
			
			--2017元宵节
			if LevelType:isYuanxiao2017Level(level) and GameGuideData:sharedInstance():containInGuidedIndex(index) then
				return true
			end
		end
	end
	data:setScene(scene)
	data:setLevelId(levelId)
	data:setNumMoves(-1)
	return false
	-- return true
end

function GameGuide:getUsePropGuides( guides )
	local usePropGuides = {}
	for k,v in pairs(UsePropGuideKeys) do
		usePropGuides[v] = guides[v]
	end
	return usePropGuides
end

-- 获取第一个符合条件的引导，否则返回空，满足所有条件才算通过。
function GameGuide:getFirstGuide(paras)
	local data = GameGuideData:sharedInstance()
	if data:getForceStop() then
		return
	end

	local guides = data:getGuides()

	local speedBtnIndex = 201901301132
	if GameGuideCheck:checkAppear(guides[speedBtnIndex], paras, speedBtnIndex)  then
		-- printx( 10 , "GameGuide:checkAppear : speed btn." )
		return speedBtnIndex
	end

	if data:getSkipLevel() then
		guides = self:getUsePropGuides(guides)

		for k, v in pairs(guides) do
			if GameGuideCheck:checkAppear(v, paras, k) then
				-- printx( -5 , " GameGuide:getFirstGuide ------------------- " , k)
				return k
			end
		end
	else
		if not self.allGuideSortList then
			local sortList = {}
			for k, v in pairs(guides) do
				if #sortList == 0 then
					table.insert( sortList , { k = k , v = v} )
				elseif k < sortList[1].k then
					table.insert( sortList , 1 , { k = k , v = v} )
				elseif k > sortList[#sortList].k then
					table.insert( sortList , { k = k , v = v} )
				else
					for k1, v1 in ipairs(sortList) do
						if k < v1.k then
							table.insert( sortList , k1 , { k = k , v = v} )
							break
						end
					end
				end		
			end

			self.allGuideSortList = sortList
		end

		for k, v in ipairs(self.allGuideSortList) do
			--printx( -5 , " GameGuide:getFirstGuide 2222 check  " , v.k)
			if GameGuideCheck:checkAppear(v.v, paras, v.k) then
				-- printx( -5 , " GameGuide:getFirstGuide ------------------- " , v.k)
				return v.k
			end
		end
	end
	return nil
end

-- 确认是否满足引导的消失条件，满足条件之一即通过
function GameGuide:checkDisappear(paras)
	local data = GameGuideData:sharedInstance()
	if data:getForceStop() then return true end
	return GameGuideCheck:checkDisappear(data:getRunningGuide(), paras, data:getGuideIndex())
end

-- 被通知一个引导结束，进入下一个引导
function GameGuide:onGuideComplete(skipLevel,nextParas)
	local data = GameGuideData:sharedInstance()
	Notify:dispatch("GuideCompleteEvent")
	if not data:getRunningGuide() then
		data:resetRunningGuide()
		return
	end
	local paras = {}
	paras.isSkip = skipLevel

	local guidedOnToday = data:getGuidedOnToday()
	if guidedOnToday then guidedOnToday["k_" .. tostring(data:getGuideIndex())] = true end
	data:writeToFile()
	-- 清除QA测试添加的条件
	GameGuideCheck:cleanIgnoreCheckOnGuideComplete(data:getGuideIndex())

	local rec, success = GameGuideRunner:removeGuide(paras)
	if skipLevel then
		data:setSkipLevel(true)
	end
	local action = data:incRunningAction()
	if skipLevel or not action then
		if rec then
			if not data:containInGuidedIndex(data:getGuideIndex()) then
				data:addToGuidedIndex(data:getGuideIndex())
				
				DcUtil:tutorialStep(data:getGuideIndex())
				if table.size(data:getGuidedIndex()) >= table.size(data:getGuides()) then
					DcUtil:tutorialFinish()
				end
				data:writeToFile()
			end
			data:addToCurLevelGuide(data:getGuideIndex())
		end
		if success then
			data:addToCurSuccessGuide(data:getGuideIndex())
			self:markGuideFlagCompleted(data:getGuideIndex())
		end
		data:resetRunningGuide()
		data:resetRunningAction()
	else
		GameGuideRunner:runGuide(nextParas)
	end
end

function GameGuide:getHasCurrentGuide()
	return GameGuideData:sharedInstance():getRunningGuide() ~= nil
end

function GameGuide:markGuideFlagCompleted(guideId)
	local guide = GameGuideData:sharedInstance():getGuideById(guideId) 
	if not guide or not guide.appear then return end
	local guideFlag = nil
	for k, v in pairs(guide.appear) do
		if v.type == "checkGuideFlag" then
			guideFlag = tonumber(v.para)
			break
		end
	end
	if guideFlag then
		UserLocalLogic:setGuideFlag(guideFlag)
	end
end