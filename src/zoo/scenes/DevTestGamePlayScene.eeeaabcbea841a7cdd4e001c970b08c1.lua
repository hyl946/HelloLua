DevTestGamePlayScene = class(NewGamePlaySceneUI)

function DevTestGamePlayScene:create(levelConfig , selectedItemsData)
	local scene = DevTestGamePlayScene.new()
	scene:init(levelConfig , selectedItemsData)
	return scene
end

function DevTestGamePlayScene:init( levelConfig , selectedItemsData, gamePlaySceneUiType )
	-- body
	NewGamePlaySceneUI.init(self, levelConfig , selectedItemsData , GamePlaySceneUIType.kDev)
	self:addTmpPropNum()
end

function DevTestGamePlayScene:addTmpPropNum( ... )
	-- body
	self.propList:addFakeAllProp(999)
end

function DevTestGamePlayScene:usePropCallback(propId, usePropType,expireTime, isRequireConfirm, ...)
	self.propId = propId
	self.usePropType = usePropType
	self.expireTime = expireTime

	local realItemId = propId
	if self.usePropType == UsePropsType.EXPIRE then  realItemId = ItemType:getRealIdByTimePropId(propId) end
	
	if not isRequireConfirm then -- use directly
		local function sendUseMsgSuccessCallback()
			self.propList:confirm(propId)
			self.gameBoardView:useProp(realItemId, isRequireConfirm)
			self.useItem = true
		end
		sendUseMsgSuccessCallback()
		return true
	else -- can be canceled, must kill the process before use
		
		if self:checkPropEnough(usePropType, propId) then
			self.needConfirmPropId = propId
			-- self.needConfirmPropIsTempProperty = true
			self.gameBoardView:useProp(realItemId, isRequireConfirm)
			return true
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(730311)))
			return false
		end
	end
end

function DevTestGamePlayScene:confirmPropUsed(pos, successCallback)

	-- Previous Must Recorded The Used Prop
	assert(self.needConfirmPropId)

	-- Send Server User This Prop Message
	local function onUsePropSuccess()
		self.propList:confirm(self.needConfirmPropId, pos)
		self.needConfirmPropId 			= false
		self.useItem = true
		if successCallback and type(successCallback) == 'function' then
			successCallback()
		end
	end
	onUsePropSuccess()
end

function DevTestGamePlayScene:checkPropEnough(usePropType, propId)
	-- 临时道具
	if usePropType == UsePropsType.TEMP then
		return true
	end
	-- 限时道具
	if usePropType == UsePropsType.EXPIRE then
		local uNum = UserManager:getInstance():getUserTimePropNumber(propId)
		local sNum = UserService:getInstance():getUserTimePropNumber(propId)
		if uNum > 0 and sNum > 0 then
			return true
		end
		return false
	end
	-- 普通道具
	if usePropType == UsePropsType.NORMAL then 
		return true
	end

	return false
end

function DevTestGamePlayScene:passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount, ...)
	-- ----------------------------------
	-- Ensure Only Call This Func Once
	-- ----------------------------------
	assert(not self.levelFinished, "only call this function one time !")
	if not self.levelFinished then
		self.levelFinished = true
	end

	local levelType = self.levelType
	------------------------
	--- Success Callback
	------------------------
	local function onSendPassLevelMessageSuccessCallback(levelId, score, rewardItems, ...)
		assert(type(levelId)	== "number")
		assert(type(score)	== "number")
		assert(rewardItems)
		assert(#{...} == 0)

		-- insert digged gems as the first reward
		if levelType == GameLevelType.kDigWeekly then
			local tmp = {}
			table.insert(tmp, {itemId = ItemType.GEM, num = targetCount})
			table.insert(tmp, rewardItems[1])
			table.insert(tmp, rewardItems[2])
			rewardItems = tmp
		elseif levelType == GameLevelType.kMayDay then
			local tmp = {}
			-- table.insert(tmp, {itemId = ItemType.XMAS_BOSS, num = bossCount})
			table.insert(tmp, {itemId = ItemType.XMAS_BELL, num = targetCount})
			table.insert(tmp, rewardItems[1])
			rewardItems = tmp
		elseif levelType == GameLevelType.kRabbitWeekly then
			local tmp = {}
			table.insert(tmp, {itemId = ItemType.WEEKLY_RABBIT, num = targetCount})
			table.insert(tmp, rewardItems[1])
			table.insert(tmp, rewardItems[2])
			rewardItems = tmp
		elseif levelType == GameLevelType.kSummerWeekly then
			local tmp = {}
			table.insert(tmp, {itemId = ItemType.KWATER_MELON, num = targetCount})
			for _, v in pairs(rewardItems) do
				table.insert(tmp, v)
			end
			rewardItems = tmp
		elseif levelType == GameLevelType.kTaskForRecall then
			rewardItems = {}
		end

		-----------------------------
		-- Popout Game Success Panel
		-- --------------------------
		local levelSuccessPanel = LevelSuccessPanel:create(levelId, levelType, score, rewardItems, coin)

		-- Set The Star Pop Position And Star Size
		local bigStarSize	= self.scoreProgressBar:getBigStarSize()
		local bigStarPosTable	= self.scoreProgressBar:getBigStarPosInWorldSpace()

		for index = 1,#bigStarPosTable do
			local posX = bigStarPosTable[index].x
			local posY = bigStarPosTable[index].y
			levelSuccessPanel:setStarInitialPosInWorldSpace(index, ccp(bigStarPosTable[index].x, bigStarPosTable[index].y))
		end

		for index = 1,#bigStarPosTable do
			levelSuccessPanel:setStarInitialSize(index, bigStarSize.width, bigStarSize.height)
		end

		-- Set The Hide Star Callback
		local function hideScoreProgressBarStarCallback(starIndex, ...)
			assert(type(starIndex) == "number")
			assert(#{...} == 0)

			self.scoreProgressBar:setBigStarVisible(starIndex, false)
		end
		levelSuccessPanel:registerHideScoreProgressBarStarCallback(hideScoreProgressBarStarCallback)
		-- levelSuccessPanel:setTestGamePlayScene()
		levelSuccessPanel:popout()
	end


	local function clone( t )
		-- body
		local u = {}
		for i, v in pairs(t) do 
			if type(v) == "table" then 
				u[i] = clone(v)
			else
				u[i] = v
			end
		end
		return u
	end

	local levelReward_1 = MetaManager.getInstance():getLevelRewardByLevelId(1)
	local levelReward = clone(levelReward_1)
	levelReward.levelId  = levelId
	table.insert(MetaManager.getInstance().level_reward, levelReward)
	onSendPassLevelMessageSuccessCallback(levelId, score, {})
end

function DevTestGamePlayScene:failLevel(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
	local levelType = self.levelType
	-- ----------------------------------
	-- Ensure Only Call This Func Once
	-- ----------------------------------
	assert(not self.levelFinished, "only call this function one time !")
	if not self.levelFinished then
		self.levelFinished = true
	end
	local levelFailPanel = LevelFailPanel:create(levelId, levelType, score, star, isTargetReached, failReason, 0)
	levelFailPanel:popout(false)
end

function DevTestGamePlayScene:onPauseBtnTapped(...)


	assert(#{...} == 0)
	
	self:pause()
	local function onQuitCallback()
		self:onQuitLevel()
	end

	local function onClosePanelBtnTappedCallback()
		self.quitDcData = nil
		self:continue()
		if self.quitDcData then self.quitDcData = nil end
	end

	local function onReplayCallback()
		onQuitCallback()
		Director:sharedDirector():pushScene(GameChoiceScene:create())
	end
	local mode = QuitPanelMode.QUIT_LEVEL
	if self.levelType == GameLevelType.kMayDay then
		mode = QuitPanelMode.NO_REPLAY
	end
	local quitPanel = QuitPanel:create(mode, self.gameBoardLogic)
	quitPanel:setOnReplayBtnTappedCallback(onReplayCallback)
	quitPanel:setOnQuitGameBtnTappedCallback(onQuitCallback)
	quitPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback)

	-- -- 请不要随意在代码里面加上测试代码然后提交，如果一定需要提交测试代码，请加上__TEST的判断，然后这个变量可以在launcher的时候设置
	if true then
		--si xing guan ka ce shi
		quitPanel:showDebugButton()
		quitPanel:setOnPassLevelTappedCallback(function()
			local tab = {20, 25, 45, 108, 112, 118, 119, 144, 227}
			local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(self.levelId)
			local starLevel = 3
			local targetCount = 300
			for k, v in ipairs(tab) do if self.levelId == v then starLevel = 4 break end end
			self:passLevel(self.levelId, levelConfig.scoreTargets[starLevel] + 10, starLevel, 100, 0, targetCount, nil, 5)
		end)
		quitPanel:setAddScoreTappedCallback(function(addScoreNum)
			addScoreNum = addScoreNum or 500
			self:addScore(addScoreNum, ccp(0, 0))
		end)
	end
	
	quitPanel:popout()
end

function DevTestGamePlayScene:onQuitLevel()
	if __use_low_effect then 
		FrameLoader:unloadImageWithPlists(self.fileList, true)
	end
	Director:sharedDirector():popScene()
end

-- This Function Is Called By Game Board Locig
function DevTestGamePlayScene:addStep(levelId, score, star, isTargetReached, isAddStepCallback, ...)
	if self.gameBoardLogic.gameMode:is(JamSperadMode) then 
		require "zoo.panel.CommonTipWithBtn"
		local tipConfig = {tip = localize("我就是加五步面板\n我不受道具次数限制\n您今天辛苦了\n按时吃饭\n不要熬夜\n多喝热水"), yes = "加5步", no = "不加", noFadeOut = true}
		CommonTipWithBtn:showTip(tipConfig, "negative", function ()
			self:setPauseBtnEnable(true)
			isAddStepCallback(true)
		end, function ()
			isAddStepCallback(false)
		end)
	else
		isAddStepCallback(false)
	end
end

-------------------------
--显示加时间面板
-------------------------
function DevTestGamePlayScene:showAddTimePanel(levelId, score, star, isTargetReached, addTimeCallback, ...)
	addTimeCallback(false)
end

-------------------------
--显示加兔兔导弹面板
-------------------------
function DevTestGamePlayScene:showAddRabbitMissilePanel( levelId, score, star, isTargetReached, isAddPropCallback )
	-- body
	isAddPropCallback(false)
end

function DevTestGamePlayScene:addTemporaryItem(itemId, itemNum, fromGlobalPosition, ...)

	self.propList:addTemporaryItem(itemId, itemNum, fromGlobalPosition)
end
