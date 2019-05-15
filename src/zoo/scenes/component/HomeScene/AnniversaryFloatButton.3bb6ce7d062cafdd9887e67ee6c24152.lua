require "zoo.scenes.component.HomeScene.iconButtons.FloatIconButton"
require "zoo.scenes.component.HomeScene.FriendPicture"

local HeadPictureType = {
	kLeft = 1,
	kRight = 2,
}

local RankFirstType = {
	kFriends = 1,
	kAll = 2,
}

local kAnniversaryTopUserChanged = "anniversary2_top_user_changed"

local kRewardColdTime = 300 -- 60 * 5
local kDailyRewardLimit = 5

_G.AnniversaryFloatIconTimeConfig = {
	beginTime 	= os.time({year = 2016, month=4, day=22, hour=10, min=0, sec=0}),
	endTime 	= os.time({year = 2016, month=5, day=6, hour=23, min=59, sec=59}),
	rewardBeginTime = os.time({year = 2016, month=4, day=25, hour=10, min=0, sec=0}),
	rewardEndTime 	= os.time({year = 2016, month=5, day=4, hour=23, min=59, sec=59}),
}

local function saveLocalActivityData(uid, data)
	local fileName = tostring(uid).."_activity_60_1_data.ds"
	Localhost.getInstance():writeToStorage(data, fileName)
end

local function readLocalActivityData(uid)
	local fileName = tostring(uid).."_activity_60_1_data.ds"
	local data = Localhost.getInstance():readFromStorage(fileName)
	if not data then data = {} end

	data.lastGetDailyRewardTime = data.lastGetDailyRewardTime or 0
	data.getDailyRewardNum = data.getDailyRewardNum or 0

	if compareDate(os.date("*t", Localhost:timeInSec()), os.date("*t", data.lastGetDailyRewardTime)) ~= 0 then
		-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>>>>> diff day reset data ~") end
		data.getDailyRewardNum = 0
		saveLocalActivityData(uid, data)
	end
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>>>>>>>readLocalActivityData:", table.tostring(data)) end
	return data
end

AnniversaryFloatButton = class(FloatIconButton)

function AnniversaryFloatButton:isInAcitivtyTime()
	local curTime = Localhost:timeInSec()
	return curTime >= AnniversaryFloatIconTimeConfig.beginTime and curTime <= AnniversaryFloatIconTimeConfig.endTime
end

function AnniversaryFloatButton:isSupport()
	if __WIN32 then
		return true
	end
	local ver = _G.bundleVersion:split(".")
    if tonumber(ver[2]) < 31 then
    	return false
    end
	if _G.isPrePackage or __WP8
		or PlatformConfig:isPlatform(PlatformNameEnum.kJJ)
		or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk)
		or PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then
		return false
	end
	return true
end

function AnniversaryFloatButton:ctor()
	self.hasReward = false
	self.scheduleId = nil
end

function AnniversaryFloatButton:create(floatType, posType)
	local ret = AnniversaryFloatButton.new(CCNode:create())
	ret:init(floatType, posType)
	return ret
end

function AnniversaryFloatButton:init(floatType, posType)
	FloatIconButton.init(self, floatType, posType)

	self.builder = InterfaceBuilder:createWithContentsOfFile("ui/anniversary2/anniversary_float_icon.json")
	local ui = self.builder:buildGroup("Anniversary2Level_Icon/float_icon")
	ui:setPosition(ccp(-380, 450))
	self:addChild(ui)
	self.ui = ui

	local iconBody = ui:getChildByName("icon_body")
	iconBody:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(1, ccp(0, -10)), CCMoveBy:create(1, ccp(0, 10)))))
	self.iconBody = iconBody
	self.iconBody.rankUserPictures = {}

	self.firstOfFriendsNode = iconBody:getChildByName("head_pic1")
	self.firstOfAllNode = iconBody:getChildByName("head_pic2")

	self.mountainNode = iconBody:getChildByName("mountain")

	local function onMountainTapped()
		self:onMountainTapped()
	end

	self.mountainNode:setTouchEnabled(true)
	self.mountainNode:addEventListener(DisplayEvents.kTouchTap, onMountainTapped)

	self:initData()
end

function AnniversaryFloatButton:onMountainTapped()
	local scene = Director:sharedDirector():getRunningScene()
	if scene and scene:is(HomeScene) then
		if scene.worldScene and scene.worldScene.scrollHorizontalState ~= WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
			self:onGetRewardButtonTapped()
		end
	end
end

function AnniversaryFloatButton:dispose()
	CocosObject.dispose(self)

	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end

	self.iconBody = nil
	self.ui = nil

	self.builder:unloadAsset("ui/anniversary2/anniversary_float_icon.json")
	self.builder = nil

	GlobalEventDispatcher:getInstance():removeEventListenerByName(kAnniversaryTopUserChanged)
end

function AnniversaryFloatButton:hitTestPoint(worldPosition, useGroupTest)
	if self.ui and self.ui.refCocosObj then
		self:hideUserInfo(RankFirstType.kFriends)
		self:hideUserInfo(RankFirstType.kAll)

		return self.ui:hitTestPoint(worldPosition, useGroupTest)
	end
	return false
end

function AnniversaryFloatButton:getRankUserHeaderNode(rankType)
	assert(type(rankType) == "number")
	local node = nil
	local nodeName = "head_pic"..tostring(rankType)
	if self.iconBody and not self.iconBody.isDisposed then
		node = self.iconBody:getChildByName(nodeName)
	end
	return node
end

function AnniversaryFloatButton:updateUserHeadPicture(picType, rankType, userInfo)
	assert(type(rankType) == "number")

	local node = self:getRankUserHeaderNode(rankType)
	if node and not node.isDisposed and userInfo then
		node:setVisible(true)

		local originPic = node:getChildByName("header")
		local zIndex = originPic:getZOrder()
		local position = originPic:getPosition()

		local picGroup = self.builder:buildGroup("Anniversary2Level_Icon/head_pic"..tostring(rankType))
		local userPicture = FriendPicture:createWithGroup(picGroup, userInfo.uid, userInfo)
		userPicture:setRecalcMaskPosition(true)
		
		if picType == HeadPictureType.kRight then
			userPicture.curResDirection = userPicture.ANIM_DIRECTION_LEFT
		elseif picType == HeadPictureType.kLeft then
			userPicture.curResDirection = userPicture.ANIM_DIRECTION_RIGHT
		end

		local friendIcon = userPicture.friendIcon
		if friendIcon then
			local function onFriendIconTapped()
				if userPicture.showState == userPicture.SHOW_STATE_HIDDED then
					if picType == HeadPictureType.kRight then
						userPicture:playShowNameAndStarAnim(FriendPictureAnimDirection.RIGHT, false)
					elseif picType == HeadPictureType.kLeft then
						userPicture:playShowNameAndStarAnim(FriendPictureAnimDirection.LEFT, false)
					end
				elseif userPicture.showState == userPicture.SHOW_STATE_SHOWED then
					userPicture:playHideNameAndStarAnim(false)
				end
			end

			friendIcon:setTouchEnabled(true, 0, true)
			friendIcon:addEventListener(DisplayEvents.kTouchTap, onFriendIconTapped)
		end

		userPicture:setPosition(ccp(position.x, position.y))
		userPicture.name = "header"
		node:addChildAt(userPicture, zIndex)

		node.userPicture = userPicture

		originPic:removeFromParentAndCleanup(true)
	end
end

function AnniversaryFloatButton:hideUserInfo(rankType)
	assert(type(rankType) == "number")

	local node = self:getRankUserHeaderNode(rankType)
	if node and node.userPicture then
		local userPic = node.userPicture
		if not userPic.isDisposed and userPic.showState ~= 1 and type(userPic.playHideNameAndStarAnim) == "function" then
			userPic:playHideNameAndStarAnim(function() end)
		end
	end
end

function AnniversaryFloatButton:updateFirstOfFriends(userInfo)
	if type(userInfo) == "table" then
		self:updateUserHeadPicture(HeadPictureType.kRight, RankFirstType.kFriends, userInfo)
	end
end

function AnniversaryFloatButton:hideFirstOfFriends()
	local node = self:getRankUserHeaderNode(RankFirstType.kFriends)
	if node then
		node:setVisible(false)
	end
end

function AnniversaryFloatButton:updateFirstOfAll(userInfo)
	if type(userInfo) == "table" then
		self:updateUserHeadPicture(HeadPictureType.kLeft, RankFirstType.kAll, userInfo)
	end
end

function AnniversaryFloatButton:hideFirstOfAll()
	local node = self:getRankUserHeaderNode(RankFirstType.kAll)
	if node then
		node:setVisible(false)
	end
end

function AnniversaryFloatButton:getDailyRewardNumFromServer()
	local actInfo = table.find(UserManager:getInstance().actInfos or {},function(v)
		return v.actId == 60
	end)
	if actInfo and actInfo.extra then
		local extras = actInfo.extra:split(",")
		if #extras >= 3 then
			return tonumber(extras[3])
		end
	end
	return nil
end

function AnniversaryFloatButton:sendGetRewardRequest(onSuccessCallback, onFailCallback)
	local uid = UserManager.getInstance().user.uid

	local function onSuccess(evt)
		local rewardItems = evt.data.rewardItems or {}

		UserManager:getInstance():addRewards(rewardItems)
		UserService:getInstance():addRewards(rewardItems)
		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kActivityInner, rewardItems, DcSourceType.kActPre.."anniversary")
		Localhost.getInstance():flushCurrentUserData()

		local data = readLocalActivityData(uid)
		data.lastGetDailyRewardTime = Localhost:timeInSec()
		data.getDailyRewardNum = data.getDailyRewardNum + 1
		saveLocalActivityData(uid, data)

		table.insert(rewardItems, {itemId=11, num=5}) -- 加5个宝石，后端直接加了，前端飞动画就好了，打开活动面板时从后端取回来的是最新的数据
		if onSuccessCallback then onSuccessCallback(rewardItems) end
	end

	local function onError(evt)
 		local errcode = evt and evt.data or nil
		if onFailCallback then onFailCallback(errcode) end
	end

	local http = GetUserCommonRewardsHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onError)
	http:syncLoad(22)
end

function AnniversaryFloatButton:getActivityIconButtonPos()
	local scene = Director:sharedDirector():getRunningScene()
	if scene:is(HomeScene) then
		if scene.activityIconButtons then
			for _, v in pairs(scene.activityIconButtons) do
				if v.source == "Anniversary2Level/Config.lua" then
					local gb = CocosObject.getGroupBounds(v)
					local pos = ccp(gb:getMidX(), gb:getMidY()) --v:getPositionInScreen() --ccp(v:getHCenterInScreenX(), v:getVCenterInScreenY())
					return pos
				end
			end
		end
	end
	return nil
end

local function playRewardsFlyAnim(rewards, pos, activityIconPos, callback)
	if not rewards or not pos then return end

	local c = 0
	for _,itemConfig in pairs(rewards) do
		c = c + 1 
		if itemConfig.itemId ~= ItemType.XMAS_BELL then 
	        local anim = FlyItemsAnimation:create({itemConfig})
	        anim:setWorldPosition(ccp(pos.x, pos.y))
	        if c >= #rewards then
	        	anim:setFinishCallback(callback)
	        end
	        anim:play()
		end
	end
end

function AnniversaryFloatButton:getCenterPosInWorld()
	if self.mountainNode and not self.mountainNode.isDisposed then
		local bounds = self.mountainNode:getGroupBounds()
		return ccp(bounds.origin.x + bounds.size.width/2, bounds.origin.y + bounds.size.height/2)
	else
		local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
		local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
		return ccp(visibleOrigin.x + visibleSize.width/2, visibleOrigin.y + visibleSize.height / 2)
	end
end

function AnniversaryFloatButton:onGetRewardButtonTapped()
	local context = self
	local curTime = Localhost:timeInSec()

	if curTime < AnniversaryFloatIconTimeConfig.rewardBeginTime then
		CommonTip:showTip(Localization:getInstance():getText("click.island.activity.preheat"), "positive", nil, 2)
	elseif curTime >= AnniversaryFloatIconTimeConfig.rewardEndTime then
		CommonTip:showTip(Localization:getInstance():getText("click.island.activity.over"), "negative")
	else
		local activityIconPos = context:getActivityIconButtonPos()
		if activityIconPos and self.hasReward then
			local function onSuccessCallback(rewardItems)
				if not rewardItems then
					-- CommonTip:showTip(Localization:getInstance():getText("领取成功，但是没有奖励~QAQ"), "positive")
				else
					playRewardsFlyAnim(rewardItems, self:getCenterPosInWorld(), activityIconPos)
				end
				self:recalcRewardState()
				local dcData = {game_type="stage", game_name="two_year_anniversary", category="other", sub_category="two_year_anniversary_click_island", t2=1}
				DcUtil:log(109, dcData)
			end

			local function onFailCallback(errcode)
				if errcode then
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
				end
				self:recalcRewardState()
			end
			self:sendGetRewardRequest(onSuccessCallback, onFailCallback)
		else
			CommonTip:showTip(Localization:getInstance():getText("click.island.frequently"), "positive")
		end
	end

	local dcData = {game_type="stage", game_name="two_year_anniversary", category="other", sub_category="two_year_anniversary_click_island", t1=1}
	DcUtil:log(109, dcData)
end

function AnniversaryFloatButton:updateHasRewardState(hasReward)
	if self.isDisposed then return end

	if hasReward then
		self.hasReward = true
		local highlightLayer = self.mountainNode:getChildByName("highlight")
		highlightLayer:setVisible(true)
		highlightLayer:setOpacity(0)

		highlightLayer:stopAllActions()
		local hilightAction = CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1)))
		highlightLayer:runAction(hilightAction)
	else
		self.hasReward = false
		local highlightLayer = self.mountainNode:getChildByName("highlight")
		highlightLayer:setVisible(false)
		highlightLayer:stopAllActions()
	end
end

function AnniversaryFloatButton:addScheduleUpdateTask(timeInSec)
	local curTime = Localhost:timeInSec()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end
	if timeInSec > curTime then
		local function updateHasRewardState()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
			self:recalcRewardState()
		end
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateHasRewardState, timeInSec - curTime, false)
	end
end

function AnniversaryFloatButton:initData()
	-- self:updateFirstOfFriends({uid=1234, name="Name1", headUrl="http://qlogo2.store.qq.com/qzone/512775545/512775545/100", star=90, hideStar=0})
	-- self:updateFirstOfAll({uid=1235, name="Name2", headUrl="http://qlogo2.store.qq.com/qzone/32346579/32346579/50", star=120, hideStar=0})
	
	self:hideFirstOfFriends()
	self:hideFirstOfAll()

	local function onMaRankInfoSuccess(evt)
		if evt and evt.data then
			local topOneFriends = evt.data.topOneFriends
			local topOneWorld = evt.data.topOneWorld
			local profiles = evt.data.profiles
			if profiles then
				for _, p in pairs(profiles) do
					if topOneFriends and tostring(p.uid) == tostring(topOneFriends.uid) then
						local userInfo = {uid = tonumber(p.uid), name = p.name, headUrl = p.headUrl, star = topOneFriends.score, hideStar=0}
						self:updateFirstOfFriends(userInfo)
					end
					if topOneWorld and tostring(p.uid) == tostring(topOneWorld.uid) then
						local userInfo = {uid = tonumber(p.uid), name = p.name, headUrl = p.headUrl, star = topOneWorld.score, hideStar=0}
						self:updateFirstOfAll(userInfo)
					end
				end
			end
		end
	end

	local function onMaRankInfoFail(evt)
		
	end

	if Localhost:timeInSec() >= AnniversaryFloatIconTimeConfig.rewardBeginTime then
		local http = MaRankInfoHttp.new()
		http:ad(Events.kComplete, onMaRankInfoSuccess)
		http:ad(Events.kError, onMaRankInfoFail)
		http:load()
	end

	local function updateTopOneInfo(evt)
		if Localhost:timeInSec() < AnniversaryFloatIconTimeConfig.rewardBeginTime then
			return
		end
		if not self.isDisposed and evt and evt.data then
			local rankType = evt.data.rankType
			local rankData = evt.data.rankData
			-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>>>updateTopOneInfo", rankType, table.tostring(rankData)) end
			if rankType == RankFirstType.kFriends and type(rankData) == "table" then
				local userInfo = {uid = tonumber(rankData.uid), name = rankData.name, headUrl = rankData.headUrl, star = rankData.score, hideStar=0}
				self:updateFirstOfFriends(userInfo)
			elseif rankType == RankFirstType.kAll and type(rankData) == "table" then
				local userInfo = {uid = tonumber(rankData.uid), name = rankData.name, headUrl = rankData.headUrl, star = rankData.score, hideStar=0}
				self:updateFirstOfAll(userInfo)
			end
		end
	end
	GlobalEventDispatcher:getInstance():removeEventListenerByName(kAnniversaryTopUserChanged)
	GlobalEventDispatcher:getInstance():ad(kAnniversaryTopUserChanged, updateTopOneInfo)

	local uid = UserManager.getInstance().user.uid
	local data = readLocalActivityData(uid)

	local dailyRewardNumFromServer = self:getDailyRewardNumFromServer()
	if type(dailyRewardNumFromServer) == "number" then
		data.getDailyRewardNum = dailyRewardNumFromServer
		saveLocalActivityData(uid, data)
	end

	self:recalcRewardState()
end

function AnniversaryFloatButton:recalcRewardState()
	local uid = UserManager.getInstance().user.uid
	local data = readLocalActivityData(uid)
	local curTime = Localhost:timeInSec()

	if curTime < AnniversaryFloatIconTimeConfig.rewardBeginTime then
		self:updateHasRewardState(false)
		self:addScheduleUpdateTask(AnniversaryFloatIconTimeConfig.rewardBeginTime)
	elseif curTime >= AnniversaryFloatIconTimeConfig.rewardEndTime then
		self:updateHasRewardState(false)
	else
		if data.getDailyRewardNum < kDailyRewardLimit then
			local nextTime = data.lastGetDailyRewardTime + kRewardColdTime
			nextTime = math.min(nextTime, AnniversaryFloatIconTimeConfig.rewardEndTime)
			if nextTime > curTime then
				self:updateHasRewardState(false)
				self:addScheduleUpdateTask(nextTime)
			else
				self:updateHasRewardState(true)
			end
		else -- 第二天的
			self:updateHasRewardState(false)

			local today = os.date("*t", curTime)
			today.hour = 0
			today.min = 0
			today.sec = 0
			local nextTime = math.max(os.time(today)+86400, data.lastGetDailyRewardTime + kRewardColdTime)
			nextTime = math.min(nextTime, AnniversaryFloatIconTimeConfig.rewardEndTime)
			self:addScheduleUpdateTask(nextTime)
		end
	end
end

function AnniversaryFloatButton:checkVisible(checks)
	if type(checks) == "table" and type(checks.topLevelId) == "number" then
		return checks.topLevelId >= 20
	end
	return false
end