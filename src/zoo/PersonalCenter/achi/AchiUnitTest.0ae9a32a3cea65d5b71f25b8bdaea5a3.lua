--[[
 * AchiUnitTest
 * @date    2018-03-30 14:46:05
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AchiUnitTest = {}

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
	bg:setTouchEnabled(true, 0, true)
	bg:setAnchorPoint(ccp(0, 1))
	bg:ignoreAnchorPointForPosition(false)
	self:addChild(bg)

	local label = TextField:create("achi", nil, 20)
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2+200)
	label:setPositionY(-height/2)
	self.label = label
	self:addChild(label)
end

function TestPanel:showText(text)
	self.label:setString(text)
end

function AchiUnitTest:showTest()
	if self.panel then
		return
	end

	local size = Director:sharedDirector():getVisibleSize()
	local pos = Director:sharedDirector():getVisibleOrigin()
	local panel = TestPanel:create(size.width, size.height)
	panel:setPositionY(size.height)
	self.panel = panel
	Director:sharedDirector():run():addChild(self.panel, "popoutLayer")
	self:addTestButton("close", function ( ... )
		self.panel:removeFromParentAndCleanup(true)
		self.panel = nil
		self.testButtonLayer = nil
	end)

	local function showAchi( ... )
		local d = {}
		for id,node in pairs(Achievement.nodes) do
			local data = node:dump()
			table.insert(d, data)
		end
		panel:showText(table.tostring(d))
	end

	self:addTestButton("achi", function ( ... )
		showAchi()
	end)

	self:addTestButton("level", function ( ... )
		panel:showText(table.tostring(Achievement.levelRights:dump()))
	end)

	local c = {"SendReceiveEnergyNum", "MarkCoinIncomeTimes", "FriendLevelCount", "FruitGetCount", "EnergyRecoveryUpperLimit"}
	local index = 1
	self:addTestButton("rights", function ( ... )
		if index + 1 > 6 then
			index = 1
		end
		panel:showText(c[index]..":"..Achievement:getRightsExtra(c[index]))

		index = index + 1
	end)

	self:addTestButton("rightsConfig", function ( ... )
		panel:showText(table.tostring(Achievement:getRightsConfig()))
	end)

	local broadcastId = 0
	local function showBroadcast()
		broadcastId = broadcastId + 10

		if broadcastId > 510 then
			broadcastId = 10
		end

		local achi = Achievement:getAchi(broadcastId)
		if achi and achi.type ~= AchiType.SHARE then
			Notify:dispatch("AchiEventReachedNewAchi", {broadcastId})
		else
			showBroadcast()
		end
	end
	self:addTestButton("broadcast", function ( ... )
		showBroadcast()
	end)

	self:addTestButton("+", function ( ... )
		Achievement.levelRights:test__addLevel()
	end)

	self:addTestButton("-", function ( ... )
		Achievement.levelRights:test__reduceLevel()
	end)

	self:addTestButton("recive", function ( ... )
		local achis = Achievement:getAchis()
		local function onSuccess( info )
			Achievement:print("成功领取成就:"..AchiId.name(info.id)..">>>"..table.tostring(info))
			CommonTip:showTip("成功领取成就:"..AchiId.name(info.id))
		end
		local function onFail( info )
			Achievement:print("领取成就失败:"..AchiId.name(info.id)..">>>"..info.id)
			CommonTip:showTip("领取成就失败:"..AchiId.name(info.id))
		end
		for id,achi in pairs(achis) do
			if achi:canReceive() then
				Achievement:receive(id, onSuccess, onFail)
				return
			end
		end
		
	end)

	self:addTestButton("trigger10", function ( ... )
		Notify:dispatch("AchiEventDataUpdate", AchiDataType.kGetFinalMarkChest, true)
	end)

	local achis = Achievement:getAchis()
	local nAchis = {}
	for k,v in pairs(achis) do
		table.insert(nAchis, v)
	end

	table.sort( nAchis, function ( p, n )
		return p.id < n.id
	end )
	for _,achi in ipairs(nAchis) do
		if achi.type ~= AchiType.SHARE then
			self:addTestButton(tostring(achi.id), function ( ... )
				panel:showText("reachCount : "..achi.reachCount.. "\n" ..table.tostring(achi.ladder) .. "\n" .. table.tostring(achi:dump()))

				-- Notify:dispatch("AchiEventDataUpdate", achi.id, 10)
				-- if achi:isPassLevelCheck() then
				-- 	local levelId = 136
				-- 	Achievement:onStartLevel(levelId, GameLevelType.kMainLevel)
				-- 	Achievement:onPassLevel(levelId, GameLevelType.kMainLevel)
				-- end
			end)
		end

		if achi:canShared() then
			self:addTestButton(tostring(achi.id).."share", function ( ... )
				Achievement:set(AchiDataType.kLevelId, 75)
				local panel = achi:createSharePanel()
				panel:popout()
			end)
		end
	end
end

function AchiUnitTest:addTestButton(text, handler)
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

function AchiUnitTest:_createTestButton(text, color, fntSize, width, height)
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