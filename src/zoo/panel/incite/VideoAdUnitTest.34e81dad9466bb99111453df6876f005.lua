--[[
 * VideoAdUnitTest
 * @date    2018-09-06 15:50:04
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

VideoAdUnitTest = {}

local TestPanel = class(CocosObject)
local itemh = 50

function TestPanel:create(width, height)
	local panel = TestPanel.new(CCNode:create())
	panel:init(width, height)
	return panel
end

function TestPanel:init(width, height)
	self.width = width
	self.height = height or 320
	local bg = LayerColor:createWithColor(ccc3(0, 0, 0), self.width, self.height)
	-- bg:setOpacity(255*0.6)
	-- bg:setTouchEnabled(true, 0, true)
	bg:setAnchorPoint(ccp(0, 1))
	bg:ignoreAnchorPointForPosition(false)
	-- self:addChild(bg)
end

function VideoAdUnitTest:showTest()
	if self.panel then
		return
	end

	local size = Director:sharedDirector():getVisibleSize()
	local pos = Director:sharedDirector():getVisibleOrigin()
	local panel = TestPanel:create(size.width, size.height)
	panel:setPositionY(size.height)
	self.panel = panel
	Director:sharedDirector():run():addChild(self.panel, "topLayer")

	self:addTestButton("close", function ( ... )
		self.panel:removeFromParentAndCleanup(true)
		self.panel = nil
		self.testButtonLayer = nil
	end)

	local function refrash()
		if InciteManager.panel then
			InciteManager.panel:refrash()
		end
	end

	local function printBtn()
		-- InciteManager:print(InciteManager.groups[AdsTestGroupType.kOldUi] and "1:use old ui" or "1:use new ui")
		-- InciteManager:print(InciteManager.groups[AdsTestGroupType.kStartLevel] and "2:start level enabled" or "2:start level disabled")
		-- InciteManager:print(InciteManager.groups[AdsTestGroupType.kTree] and "3:tree enabled" or "3:tree disabled")
	end

	self:addTestButton("new/oldui", function ()
		-- InciteManager.groups[AdsTestGroupType.kOldUi] = not InciteManager.groups[AdsTestGroupType.kOldUi]
		-- InciteManager.groups[AdsTestGroupType.kNewUi] = not InciteManager.groups[AdsTestGroupType.kNewUi]
		refrash()
		printBtn()
	end)

	self:addTestButton("kStartLevel", function ()
		-- InciteManager.groups[AdsTestGroupType.kStartLevel] = not InciteManager.groups[AdsTestGroupType.kStartLevel]
		refrash()
		printBtn()
	end)

	self:addTestButton("kTree", function ()
		-- InciteManager.groups[AdsTestGroupType.kTree] = not InciteManager.groups[AdsTestGroupType.kTree]
		refrash()
		printBtn()
	end)

	local rd =  {{
			      second = 1,
			      first = "Win32Ad",
			  }}

	self:addTestButton("BtnTest", function ()
		local openSdk = math.random(0,1) == 0
		if openSdk then
			InciteManager.info.enableSDKs = rd
		else
			InciteManager.info.enableSDKs = nil
		end

		InciteManager.info.timesLimit = math.random(0,1)

		local nrt = math.random(0, 1) == 1
		if nrt then
			InciteManager.info.nextRewardTime = Localhost:time() + 200000
		else
			InciteManager.info.nextRewardTime = Localhost:time()
		end

		InciteManager:print(openSdk and "has ad" or "no ad", InciteManager.info.timesLimit, nrt)
		refrash()
	end)

	self:addTestButton("PreCondition", function ()
		local toplevelId = UserManager.getInstance().user:getTopLevelId()
		local levelDataInfo = UserService.getInstance().levelDataInfo
		local levelInfo = levelDataInfo:getLevelInfo(toplevelId)
		local failTimes = 0
		local quitTimes = 0

		if levelInfo then
			failTimes = levelInfo.failTimes or 0
			quitTimes = levelInfo.quitTimes or 0
		end

		local items = {10087}
		local has = false
		for _,itemId in ipairs(items) do
			if itemId == InciteManager.info.prePropId then
				has = true break
			end
		end

		InciteManager.info.enableScenes = {2,3,4}

		InciteManager:print("failTimes:",failTimes,
							"quitTimes:",quitTimes,
							"isStartLevelOpen:",InciteManager:isStartLevelOpen(items),
							"hasItem:", has,
							"isEntryEnable:",InciteManager:isEntryEnable(EntranceType.kStartLevel),
							"ReadySdk:",InciteManager:getReadySdk(nil, EntranceType.kStartLevel),
							"count:",InciteManager:getCount(EntranceType.kStartLevel),
							"enableScenes:",table.tostring(InciteManager.info.enableScenes),
							"guide:",(GameGuideData:sharedInstance():containInGuidedIndex(211)
						or UserManager:getInstance():hasGuideFlag(kGuideFlags.PreProps_MagicBird))
			)

	end)
end

function VideoAdUnitTest:init()
	self.testInfo = true
	self.testGroup = true
	self.restartPanel = false
	self.testPlay = false
	self.testDirect = false
	self.testPanelBtn = false

	if self.testInfo and UserManager:getInstance().videoSDKInfo then
		UserManager:getInstance().videoSDKInfo.enableSDKs = {
			  {
			      second = 1,
			      -- first = "360",--"SigmobAndroid",

			      -- first = "SigmobAndroid",
			      first = "Win32Ad"

			  },
			}
			UserManager:getInstance().videoSDKInfo.enableScenes = {2,3,4}
	end


	-- if self.testGroup then
	-- 	InciteManager.groups = {
	-- 		[AdsTestGroupType.kOldUi] = false,
	-- 		[AdsTestGroupType.kNewUi] = true,
	-- 		[AdsTestGroupType.kStartLevel] = true,
	-- 		[AdsTestGroupType.kTree] = true,
	-- 	}
	-- end
end

function VideoAdUnitTest:addTestButton(text, handler)
	if not self.testButtonLayer then
		self.testButtonLayer = Layer:create()
		self.testButtonLayer:setPosition(ccp(20, -120))
		self.panel:addChild(self.testButtonLayer)
		self.testButtonLayer.buttons = {}

		self.testButtonCtrl = self:_createTestButton("收起(0)", ccc3(0,0,139))
		local function onTapped()
			local isVisible = self.testButtonLayer:isVisible()
			self.testButtonLayer:setVisible(not isVisible)
			self.testButtonLayer:setChildrenVisible(not isVisible, false)
			self.testButtonCtrl.updateLabel()
		end
		self.testButtonCtrl.onTapped = onTapped
		self.testButtonCtrl:addEventListener(DisplayEvents.kTouchTap, onTapped)
		self.testButtonCtrl.updateLabel = function()
			if self.testButtonLayer:isVisible() then
				self.testButtonCtrl.label:setString(string.format("收起(%d)", #self.testButtonLayer.buttons))
			else
				self.testButtonCtrl.label:setString(string.format("展开(%d)", #self.testButtonLayer.buttons))
			end
		end
		self.testButtonCtrl:setPosition(ccp(20, -60))

		self.panel:addChild(self.testButtonCtrl)
	end
	local btn = self:_createTestButton(text)
	table.insert(self.testButtonLayer.buttons, btn)
	btn:addEventListener(DisplayEvents.kTouchTap, function()
			if type(handler) == "function" then handler() end
			end)

	local btnNum = #self.testButtonLayer.buttons
	local posX = (math.floor((btnNum-1)/18)) * 160
	local posY = (btnNum-1)%18 * 60
	btn:setPositionXY(posX, -posY)

	self.testButtonLayer:addChild(btn)
	self.testButtonCtrl.updateLabel()

	return btn
end

function VideoAdUnitTest:_createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	width = width or 150
	height = height or 56
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	btn:setOpacity(255 * 0.75)
	btn:addEventListener(DisplayEvents.kTouchBegin, function(evt)
		local action = CCSequence:createWithTwoActions(CCTintTo:create(0.1, 0, 255, 0), CCTintTo:create(0.2, 64, 64, 64))
		action.tag = 11114
		btn:stopActionByTag(11114)
		btn:runAction(action)
	end)

	fntSize = fntSize or 26
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)

	return btn
end

--[[
function AdNode:onAdsReady( placementId )
	InciteManager:onAdsReady( self.name, placementId )
end

function AdNode:onAdsPlayed( placementId )
	InciteManager:onAdsPlayed( self.name, placementId )
end

function AdNode:onAdsFinished( placementId, state )
	InciteManager:onAdsFinished( self.name, placementId, state )
end

function AdNode:onAdsError( code, msg )
	if code == AdsError.kInitializedFailed then
		self.isInit = false
	end
	InciteManager:onAdsError( self.name, code, msg )
end

AdsError = {
	kUnknow = 0,
	kNotInitialized = 1,
	kInitializedFailed = 2,
	kNotSupported = 3,
	kPlayError = 4,
	kSDKInternalError = 5,
	kVideoNotReady = 6,
	kVideoRequestError = 7,
	kNetError = 8,
}

]]

function VideoAdUnitTest:canDirectShowAd( can )
	if self.testDirect then
		return false
	end
	return can
end

function VideoAdUnitTest:play(cb, placementId )
	if self.testPlay then
		local playerror = math.random(0,1) == 0
		local completed = math.random(3,4) == 3
		if __WIN32 then
			if playerror then
				local err = math.random(0,1) == 0 and AdsError.kPlayError or AdsError.kVideoNotReady
				cb:onAdsError(AdsError.kPlayError, "play error")
			else
				cb:onAdsFinished(placementId, completed and AdsFinishState.kCompleted or AdsFinishState.kNotCompleted)
			end
		end
	else
		cb:onAdsFinished(placementId, AdsFinishState.kCompleted)
	end
end