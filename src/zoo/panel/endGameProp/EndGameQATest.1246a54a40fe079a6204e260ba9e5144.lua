require "zoo.data.LocalNotificationUtil"

EndGameQATest = {}
local defaultBtnWidth = 80
local defaultBtnHeight = 80

local quickAddFivePanel = false

local function createButton(text)
	text = text or ""
	local label = TextField:create(text, nil, 30)
	label:setColor(ccc3(255, 255, 255))
	label:setHorizontalAlignment(kCCTextAlignmentCenter)
	label:setAnchorPoint(ccp(0.5, 0.5))
	local labelSize = label:getContentSize()
	local labelWidth = labelSize.width 
	if labelWidth < defaultBtnWidth then 
		labelWidth = defaultBtnWidth
	end

	local layer = LayerColor:create()
	layer:setOpacity(255)
	layer:setAnchorPoint(ccp(0.5, 0.5))
	layer:ignoreAnchorPointForPosition(false)
	layer:setContentSize(CCSizeMake(labelWidth+10, defaultBtnHeight))
	layer:setTouchEnabled(true, 0, true)

	layer:addChild(label)
	label:setPosition(ccp(labelWidth/2+5, 40))

	return layer
end

local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
function EndGameQATest:showButtons(scene)
	local mainButton = createButton("zhijiantest")
	scene:addChild(mainButton)
	mainButton:setPosition(ccp(visibleOrigin.x + 200, visibleOrigin.y + 70))
	mainButton:addEventListener(DisplayEvents.kTouchTap, function ()
		if __ANDROID then 
			self:createAndroidTest(scene)
		else
			self:createIosTest(scene)
		end
	end)

	--我就是这么厚颜无耻-。-  Reast

	self.testAchievementConfig = {
		8,12,15,19,30,76,91,106,121,136,151,166,181,196,211,241,271,331,376,406,436,466,496,526,556,586,631,676,736,796,841,871,916
	}
	self.testAchievementConfigIndex = 0

	local mainButton2 = createButton("-。-")
	scene:addChild(mainButton2)
	mainButton2:setPosition(ccp(visibleOrigin.x + 40, visibleOrigin.y + 250))
	mainButton2:addEventListener(DisplayEvents.kTouchTap, function ()
		self:showTestAchievement(scene)
	end)

	
end

function EndGameQATest:showTestAchievement(scene)
	self.testAchievementConfigIndex = self.testAchievementConfigIndex + 1
	local levelid = self.testAchievementConfig[self.testAchievementConfigIndex]
	Achievement:set(AchiDataType.kLevelId, levelid)
	local achi = Achievement:getAchi(50)
	if achi then
		local panel = achi:createSharePanel()
		panel:popout()
	end

	if self.testAchievementConfigIndex == #self.testAchievementConfig then
		self.testAchievementConfigIndex = 0
	end
end

function EndGameQATest:createAndroidTest(scene)
	local panelWidth = 300
	local panelHeight = 600
	local layer = LayerColor:create()
	layer:setOpacity(255)
	layer:setColor((ccc3(255,0,0)))
	layer:setContentSize(CCSizeMake(panelWidth, panelHeight))
	layer:setTouchEnabled(true, 0, true)

	local winsize = CCDirector:sharedDirector():getWinSize()
	scene:addChild(layer) 
	layer:setPosition(ccp((winsize.width-panelWidth)/2, (winsize.height-panelHeight)/2))

	btnLabel = {
		"正常",
		"无倒计时",
		"假倒计时",	
		"快速出加五步",
		"推送测试",
		"关闭",
	}

	local yDelta = 100 
	local btnNum = #btnLabel
	local yHeight = yDelta * (btnNum - 1)
	local yOri = (panelHeight - yHeight) / 2
	for i=1,btnNum do
		local btn = createButton(btnLabel[i])
		btn:setPosition(ccp(panelWidth/2, yOri+yDelta*(btnNum-i)))
		layer:addChild(btn)
		btn:addEventListener(DisplayEvents.kTouchTap, function ()
			if i > 0 and i < 4 then 
				AddFiveStepABCTestLogic.testType = tostring(i)
			elseif i == 4 then 
				quickAddFivePanel = true
				CommonTip:showTip(Localization:getInstance():getText("快速出加五步"), "negative")
			elseif i == 5 then 
				self:createNotiSelect(scene)
			else
				layer:removeFromParentAndCleanup(true)
			end
		end)
	end

end

function EndGameQATest:createIosTest(scene)
	local panelWidth = 300
	local panelHeight = 800
	local layer = LayerColor:create()
	layer:setOpacity(255)
	layer:setColor((ccc3(255,0,0)))
	layer:setContentSize(CCSizeMake(panelWidth, panelHeight))
	layer:setTouchEnabled(true, 0, true)

	local winsize = CCDirector:sharedDirector():getWinSize()
	scene:addChild(layer) 
	layer:setPosition(ccp((winsize.width-panelWidth)/2, (winsize.height-panelHeight)/2))

	btnLabel = {
		"组1:正常7折",
		"组2:付费7折",
		"组3:非付费7折",	
		"组4:首次送额外道具",	
		"强制展示FUUU",
		"快速出加五步",
		"推送测试",
		"关闭",
	}

	local yDelta = 100 
	local btnNum = #btnLabel
	local yHeight = yDelta * (btnNum - 1)
	local yOri = (panelHeight - yHeight) / 2
	for i=1,btnNum do
		local btn = createButton(btnLabel[i])
		btn:setPosition(ccp(panelWidth/2, yOri+yDelta*(btnNum-i)))
		layer:addChild(btn)
		btn:addEventListener(DisplayEvents.kTouchTap, function ()
			if i > 0 and i < 5 then 
				EndGamePropABCTest.getInstance().userGroup = EndGameUserGrop["kGroup"..i]
				if i == 4 then 
					self:createExtraRewardSelect(scene)
				else
					CommonTip:showTip(Localization:getInstance():getText(btnLabel[i]), "negative")
				end
			elseif i == 5 then 
				EndGamePropABCTest.getInstance().fuuuShow = true
				FUUUManager.lastGameIsFUUU = function ()
					return true
				end
				CommonTip:showTip(Localization:getInstance():getText("强制展示FUUU"), "negative")
			elseif i == 6 then 
				quickAddFivePanel = true
				CommonTip:showTip(Localization:getInstance():getText("快速出加五步"), "negative")
			elseif i == 7 then 
				self:createNotiSelect(scene)
			else
				layer:removeFromParentAndCleanup(true)
			end
		end)
	end
end

local ExtraReward = table.const{
	{itemId = 10060, num = 1, posAdjust = {x = 0, y = 0}},		-- 75-76,87-89  10060:1  限时小木槌 
	{itemId = 10061, num = 1, posAdjust = {x = 0, y = 0}},		-- 77-79,90-91  10061:1  限时魔法棒 
	{itemId = 10063, num = 1, posAdjust = {x = 0, y = 0}},		-- 80-81,92-94  10063:1  限时强制交换 
	{itemId = 10059, num = 1, posAdjust = {x = 7, y = -5}},		-- 82-84,95-96  10059:1  限时刷新
	{itemId = 10058, num = 1, posAdjust = {x = 0, y = 0}},		-- 85-86,97-99  10058:1  限时后退 
}

function EndGameQATest:createExtraRewardSelect(scene)
	local panelWidth = 400
	local panelHeight = 700
	local layer = LayerColor:create()
	layer:setOpacity(255)
	layer:setColor((ccc3(0,255,0)))
	layer:setContentSize(CCSizeMake(panelWidth, panelHeight))
	layer:setTouchEnabled(true, 0, true)

	local winsize = CCDirector:sharedDirector():getWinSize()
	scene:addChild(layer) 
	layer:setPosition(ccp((winsize.width-panelWidth)/2, (winsize.height-panelHeight)/2))

	btnLabel = {
		"限时小木槌",
		"限时魔法棒",
		"限时强制交换",	
		"限时刷新",
		"限时后退",
		"关闭",
	}

	EndGamePropABCTest.getInstance().extraReward = ExtraReward[1]

	local yDelta = 100 
	local btnNum = #btnLabel
	local yHeight = yDelta * (btnNum - 1)
	local yOri = (panelHeight - yHeight) / 2
	for i=1,btnNum do
		local btn = createButton(btnLabel[i])
		btn:setPosition(ccp(panelWidth/2, yOri+yDelta*(btnNum-i)))
		layer:addChild(btn)
		btn:addEventListener(DisplayEvents.kTouchTap, function ()
			if i > 0 and i < btnNum then 
				CommonTip:showTip(Localization:getInstance():getText(btnLabel[i].."~~注意：此商品限购，重复购买时记得清理本地和后端的数据。"), "negative", nil, 4)
				EndGamePropABCTest.getInstance().extraReward = ExtraReward[i]
				layer:removeFromParentAndCleanup(true)
			else
				layer:removeFromParentAndCleanup(true)
			end
		end)
	end
end

function EndGameQATest:createNotiSelect(scene)
	local panelWidth = 400
	local panelHeight = 600
	local layer = LayerColor:create()
	layer:setOpacity(255)
	layer:setColor((ccc3(0,0,255)))
	layer:setContentSize(CCSizeMake(panelWidth, panelHeight))
	layer:setTouchEnabled(true, 0, true)

	local winsize = CCDirector:sharedDirector():getWinSize()
	scene:addChild(layer) 
	layer:setPosition(ccp((winsize.width-panelWidth)/2, (winsize.height-panelHeight)/2))

	btnLabel = {
		"音效1",
		"音效2",
		"音效3",
		"手机默认音效",
		"关闭",
	}

	local yDelta = 100 
	local btnNum = #btnLabel
	local yHeight = yDelta * (btnNum - 1)
	local yOri = (panelHeight - yHeight) / 2
	local timeStamp = 123456789
	for i=1,btnNum do
		local btn = createButton(btnLabel[i])
		btn:setPosition(ccp(panelWidth/2, yOri+yDelta*(btnNum-i)))
		layer:addChild(btn)
		
		btn:addEventListener(DisplayEvents.kTouchTap, function ()
			if i > 0 and i < btnNum then 
				CommonTip:showTip(Localization:getInstance():getText(btnLabel[i].."~~10秒后推送到达~home键出去等着吧"), "negative", nil, 3)
				local oriStr = "我是*\\u2600*表情*\\u2600*测试啊*\\u2708"
				local pushStr = LocalNotificationUtil:convertStr(oriStr)
				timeStamp = timeStamp + i
				local alertId = "100:"..timeStamp
				if __ANDROID then 
					local notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
					notificationUtil:addLocalNotification(10, pushStr, alertId, i)
				elseif __IOS then 
					WeChatProxy:scheduleLocalNotification_alertBody_alertAction_alertId_voiceId(10, pushStr, "chakan", alertId, i)
				end
				layer:removeFromParentAndCleanup(true)
			else
				layer:removeFromParentAndCleanup(true)
			end
		end)
	end
end

function EndGameQATest:quickAddFivePanel()
	return quickAddFivePanel
end

