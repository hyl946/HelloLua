--
-- ShareManager ---------------------------------------------------------
--
require "zoo.PersonalCenter.AchievementManager"

ShareManager = {}

function ShareManager:canShowShareUi()
	local enabled = self.disableShow
	self.disableShow = false
	return not enabled
end

function ShareManager:disableShareUi()
	self.disableShow = true
end

function ShareManager:showShareUI( shareIdTab )
	local shareId
	for _,id in ipairs(shareIdTab) do

        local bCanTrigger = true
        --新签到不触发炫耀
        if id == 140 and UserManager.getInstance().markV2Active then 
            bCanTrigger = false
        end

		if bCanTrigger and not self:isTrigger(id) then
			shareId = id
			break
		end
	end

	if not shareId or not self:canShowShareUi() then
		return
	end

	--记录触发次数
    self:increaseTriggerTime(shareId)
	--show share UI
	local achi = Achievement:getAchi( shareId )
	if not achi then return end

	local panel = achi:createSharePanel()
	if panel then
		local http = RewardMetalHttp.new()
		http:load(shareId)
		panel:popout()
	end
end


function ShareManager:evaluateAndGameCenter()
	local level = self.level or 0

	local user = UserService.getInstance().user
	if user then
		GameCenterSDK:getInstance():reportScore(user:getStar(), kGameCenterLeaderboards.all_star_leaderboard)
	end
	local rated = CCUserDefault:sharedUserDefault():getBoolForKey("game.local.review")
	if __WP8 and not rated and level % 5 == 3 then
		local _msg = Localization:getInstance():getText("ratings.and.review.body")
		local _title = Localization:getInstance():getText("ratings.and.review.title")
		local function _callback(r)
			if not r then return end
			Wp8Utils:RunRateReview()
			CCUserDefault:sharedUserDefault():setBoolForKey("game.local.review", true)
			CCUserDefault:sharedUserDefault():flush()
		end
		Wp8Utils:ShowMessageBox(_msg, _title, _callback)
	end
	if __IOS and level == 14 and not rated then
		-- 
		-- local function onUIAlertViewCallback( alertView, buttonIndex )
		-- 	if buttonIndex == 1 then
		-- 		local nsURL = NSURL:URLWithString(NetworkConfig.appstoreURL)
		-- 		UIApplication:sharedApplication():openURL(nsURL)
		-- 	end
		-- end
		-- local title = Localization:getInstance():getText("ratings.and.review.title")
		-- local okLabel = Localization:getInstance():getText("ratings.and.review.cancel")
		-- local UIAlertViewClass = require "zoo.util.UIAlertViewDelegateImpl"
		-- local alert = UIAlertViewClass:buildUI(title, Localization:getInstance():getText("ratings.and.review.body"), okLabel, onUIAlertViewCallback)
		-- alert:addButtonWithTitle(Localization:getInstance():getText("ratings.and.review.confirm"))
		-- alert:show()

		-- CCUserDefault:sharedUserDefault():setBoolForKey("game.local.review", true)
		-- CCUserDefault:sharedUserDefault():flush()
	end
end

-- function ShareManager.onScreeenshot()
-- 	-- 在大藤蔓界面截屏时触发分享
-- 	if 
-- 	not PopoutManager:haveWindowOnScreen() 
-- 	and Director:sharedDirector():getRunningScene():is(HomeScene) 
-- 	and UserManager.getInstance().user:getTopLevelId() >= 20
-- 		then
-- 		require "zoo.panel.share.sharePanelVerB.SharePanel_B" --todo
-- 		SharePanel_B:create(30):popout()  --todo: 改成截屏炫耀
-- 		CommonTip:showTip("原截图已保存~", "positive")
-- 	end
-- end

function ShareManager:onPassLevel(level, totalScore, levelType, star, nation_level_config, nation_score_config)
	self:checkShareTime()
	self.level = level
	self.totalScore = totalScore
	self.levelType = levelType

	UserService.getInstance():onLevelUpdate(1, level, totalScore)

	Notify:dispatch("AchiEventPassLevel", level, levelType, nation_level_config, nation_score_config)

	self:evaluateAndGameCenter()
end

local function split( str, sep )
	local t = {}
	for s in string.gmatch(str, "([^"..sep.."]+)") do
    	table.insert(t, tonumber(s))
	end
	return t
end

local runOnce = 0

function ShareManager:isTrigger( shareId )
	if _G.isLocalDevelopMode then printx(0, table.tostring(self.shareData)) end
	self:checkShareTime()

	local topLevel = 0
	local user = UserManager:getInstance().user
	if user then
		topLevel = user:getTopLevelId() 
	end
	if topLevel <= 30 then return true end

	if #self.shareData >= self.MAX_SHARE_TIME then
		return true
	end

	-- for _,id in ipairs(self.shareData) do
	-- 	if id == shareId then
	-- 		return true
	-- 	end
	-- end

	return false
end

-- http://wiki.happyelements.net/pages/viewpage.action?pageId=36700449
-- function ShareManager:isTrigger( shareId ) --实际为"返回shareId是否<不>能被触发，和名字刚好相反……"
-- 	if _G.isLocalDevelopMode then printx(0, table.tostring(self.shareData)) end
-- 	self:checkShareTime()

-- 	-- printx(0,"Level:::::::",self.level)  --debug

-- 	if (self.level >= 1 and self.level <= 50)
-- 	   or (LevelType:isHideLevel(self.level) and MetaModel:getHiddenBranchDataByHiddenLevelId(self.level).endNormalLevel <= 50)
-- 	then  --通过的关卡低于50不触发炫耀
-- 		return true
-- 	end

-- 	-- printx(0,"Not Below 50:::::::OK")  --debug

-- 	-- if #self.shareData >= self.MAX_SHARE_TIME then -- 炫耀次数达到上限则不炫耀
-- 	-- 	return true
-- 	-- end

-- 	for _,id in ipairs(self.shareData) do --今日已经炫耀过同种则不炫耀
-- 		-- printx(0,"ShareDataId:::::::"..tostring(id))
-- 		if id == shareId then
-- 			return true
-- 		end
-- 	end

-- 	-- printx(0,"Not Already Show:::::::OK")  --debug

-- 	if not UserManager:getInstance().justPassedTopLevel then -- 补星只能触发某些指定炫耀，其他不触发
-- 		local listCanTriggerAtAlreadyPassedLevel = {10, 30, 40, 70, 80, 90, 110, 250, 260, 270} --补星只能触发这些炫耀
-- 		local flagCanTrigger = false
-- 		for _,i in ipairs(listCanTriggerAtAlreadyPassedLevel) do
-- 			if shareId == i then 
-- 				flagCanTrigger = true
-- 				break 
-- 			end
-- 		end
-- 		if not flagCanTrigger then return true end
-- 	end

-- 	-- printx(0,"Can Hit Range:::::::OK")  --debug

-- 	return false
-- end

function ShareManager:checkShareTime( ... )
	--check online data,just run once
	local count = nil

	if runOnce == 0 then
		local dailyData = UserManager:getInstance():getDailyData()
		count = dailyData["dailyShowOffReward"]
		runOnce = 1
	end

	local userDefault = CCUserDefault:sharedUserDefault()
	local shareTime = userDefault:getStringForKey("game.share.all.time")
	local time = Localhost:time() / 1000
	local share_all_time = 0
	self.shareData = {}

	--data,time,share...
	if shareTime == nil then
		share_all_time = 0
		self.share_all_time = share_all_time
		return
	end

	local share_data = split(shareTime, ",")
	if #share_data ~= 0 then
   		local pre_day = math.ceil((share_data[1] + 28800) / 86400)
		local day = math.ceil((time + 28800) / 86400)
		share_all_time = share_data[2]

		if pre_day ~= day then
			share_all_time = 0
			userDefault:setStringForKey("game.share.all.time", tostring(time .. "," .. share_all_time))
	   		userDefault:flush()
	   		for i,v in ipairs(share_data) do
	   			if i > 2 then
	   				share_data[i] = nil
	   			end
	   		end
		end
	end

    if count ~= nil then
    	share_all_time = tonumber(count)
    end

    if #share_data > 2 then
    	for index=3,#share_data do
    		table.insert(self.shareData, share_data[index])
    	end
    elseif #share_data == 0 then
    	userDefault:setStringForKey("game.share.all.time", tostring(time .. "," .. share_all_time))
   		userDefault:flush()
    end

  	self.share_all_time = share_all_time

    if count ~= nil then
    	local str = ""

		for i,shareid in ipairs(self.shareData) do
			str = str .. "," .. shareid
		end

		userDefault:setStringForKey("game.share.all.time", tostring(time .. "," .. share_all_time .. str))
	   	userDefault:flush()
    end
end

function ShareManager:increaseTriggerTime( shareID )
	local userDefault = CCUserDefault:sharedUserDefault()
	local shareTime = userDefault:getStringForKey("game.share.all.time")
	local time = Localhost:time() / 1000
	if shareTime == nil then
		userDefault:setStringForKey("game.share.all.time", tostring(time .. "," .. 0))
   		userDefault:flush()
	end

	table.insert(self.shareData, shareID)

	shareTime = shareTime .. "," .. shareID
	userDefault:setStringForKey("game.share.all.time", tostring(shareTime))
   	userDefault:flush()
end

function ShareManager:increaseShareAllTime()
	self:checkShareTime()
	local share_all_time = self.share_all_time

	if share_all_time == nil then share_all_time = 0 end

	share_all_time = share_all_time + 1
	local time = Localhost:time() / 1000

	local str = ""

	for i,shareid in ipairs(self.shareData) do
		str = str .. "," .. shareid
	end

	local userDefault = CCUserDefault:sharedUserDefault()
	userDefault:setStringForKey("game.share.all.time", tostring(time .. "," .. share_all_time .. str))
   	userDefault:flush()
end

function ShareManager:getShareReward()
	-- 需求，去掉所有分享中的分享奖励（包括推送消息奖励）
	return nil
	
	-- local shareReward = nil
	-- self:checkShareTime()
	-- local share_all_time = self.share_all_time

	-- if share_all_time == nil then
	-- 	return nil
	-- end

	-- if share_all_time >= self.MAX_SHARE_TIME then
	-- 	return nil
	-- end

	-- local id = 2
	-- local num = (share_all_time+1)*100 
	-- shareReward = {rewardId = id, rewardNum = num}
	-- return shareReward
end

function ShareManager:onFailLevel( level, totalScore )
	UserService.getInstance():onLevelUpdate(0, level, totalScore)
	Notify:dispatch("AchiEventFailLevel", level, totalScore)
end

function ShareManager:openAppBar( sub )
	sub = sub or 2
	local AppbarAgent = luajava.bindClass("com.tencent.open.yyb.AppbarAgent")
	local cat = nil
	if sub == 0 then cat = AppbarAgent.TO_APPBAR_NEWS
	elseif sub == 1 then cat = AppbarAgent.TO_APPBAR_SEND_BLOG
	else cat = AppbarAgent.TO_APPBAR_DETAIL end
	
	local tencentOpenSdk = luajava.bindClass("com.happyelements.android.sns.tencent.TencentOpenSdk"):getInstance()
	tencentOpenSdk:startAppBar(cat)
end

function ShareManager:createFourStarShareImg(endCallback, levelId)
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/NewSharePanelEx2.json")
	local group = builder:buildGroup("srnFourStarShare")

	local function callback()
		--levelId
		local levelIdPosUI = group:getChildByName("numPos")
		levelIdPosUI:setOpacity(0)
		if levelId then 
			local levelIdUI = group:getChildByName("num")
			levelIdUI:setText(tostring(levelId))
			levelIdUI:setAnchorPointCenterWhileStayOrigianlPosition()
			local pos = levelIdPosUI:getPosition()
			levelIdUI:setPosition(ccp(pos.x, pos.y))
		end

		--bg
		local bg_2d = Sprite:create("share/four_star_share_bg.png")
		bg_2d:setAnchorPoint(ccp(0, 1))
		local bg = group:getChildByName("bg")
		bg:setVisible(false)
		local size = bg:getGroupBounds().size
		local bSize = bg_2d:getGroupBounds().size
		bg_2d:setScaleX(size.width / bSize.width)
		bg_2d:setScaleY(size.height / bSize.height)
		group:addChildAt(bg_2d, group:getChildIndex(bg))

		--二维码
		local qr = Sprite:create(ShareUtil:getQRCodePath())
		qr:setAnchorPoint(ccp(0, 1))
		local qrBg = group:getChildByName("2d_bg")
		qrBg:setOpacity(0)
		local qrPos = qrBg:getPosition()
		qr:setPositionXY(qrPos.x, qrPos.y)
		group:addChildAt(qr, group:getChildIndex(bg))

		--喊话
		local label1UI = group:getChildByName("label1")
		local label2UI = group:getChildByName("label2")
		local completeFourStarNum = #FourStarManager:getInstance():getAllCompleteFourStarLevels()
		if completeFourStarNum > 5 or not levelId then 
			label2UI:setVisible(false)
			local levelNumPosUI = label1UI:getChildByName("numPos")
			levelNumPosUI:setOpacity(0)
			local levelNumUI = label1UI:getChildByName("num")
			levelNumUI:setText(tostring(completeFourStarNum))
			levelNumUI:setAnchorPointCenterWhileStayOrigianlPosition()
			local numPos = levelNumPosUI:getPosition()
			levelNumUI:setPosition(ccp(numPos.x, numPos.y))
		elseif levelId then 
			label1UI:setVisible(false)
			local levelNumPosUI = label2UI:getChildByName("numPos")
			levelNumPosUI:setOpacity(0)
			local levelNumUI = label2UI:getChildByName("num")
			levelNumUI:setText(tostring(levelId))
			levelNumUI:setAnchorPointCenterWhileStayOrigianlPosition()
			local numPos = levelNumPosUI:getPosition()
			levelNumUI:setPosition(ccp(numPos.x, numPos.y))
		end

		--render
		group:setPositionY(size.height)
		local filePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
		group:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(filePath)

		if endCallback then endCallback() end
	end

	local headUI = group:getChildByName("head")
	local nameLabel = headUI:getChildByName('name')
	nameLabel:setDimensions(CCSizeMake(0, nameLabel:getDimensions().height))
	nameLabel:setString(nameDecode(UserManager:getInstance().profile.name))
	nameLabel:setPositionX((114-nameLabel:getContentSize().width)/2)

	local profile = UserManager.getInstance().profile
	local uid = UserManager.getInstance().uid
	local headUrl = profile and profile.headUrl or 1
	local function onImageLoadFinishCallback(headImage)
		local placeHolder = headUI:getChildByName('headImage')
		local scale = placeHolder:getGroupBounds().size.width / headImage:getContentSize().width
		headImage:setScale(scale)
		headImage:setAnchorPoint(ccp(-0.5, 0.5))
		headImage:setPosition(ccp(placeHolder:getPositionX(), placeHolder:getPositionY()))
		placeHolder:removeFromParentAndCleanup(true)
		headUI:addChild(headImage)
		callback()
	end
	HeadImageLoader:create(uid, headUrl, onImageLoadFinishCallback)
end

function ShareManager:init()
	self.MAX_SHARE_TIME = 5
	self.shareData = {}

	Notify:register("AchiEventShowShare", self.showShareUI, self)
	-- GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserTakeScreenShot, ShareManager.onScreeenshot)
end

ShareManager:init()