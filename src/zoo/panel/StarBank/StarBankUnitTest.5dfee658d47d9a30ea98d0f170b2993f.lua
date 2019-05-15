--[[
 * StarBankUnitTest
 * @date    2017-11-29 16:14:39
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

StarBankUnitTest = {}

local TestPanel = class(CocosObject)
local itemh = 50

function TestPanel:create(width, height)
	local panel = TestPanel.new(CCNode:create())
	panel:init(width, height)
	return panel
end

function TestPanel:createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	width = width or 80
	height = height or 50
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	-- btn:setOpacity(255 * 0.9)
	btn:addEventListener(DisplayEvents.kTouchTap, function(evt)
		btn:stopAllActions()
		btn:setOpacity(255)
		btn:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.1, 255*0.5), CCFadeTo:create(0.2, 255)))
		end)

	fntSize = fntSize or 30
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setColor(ccc3(255 - color.r, 255 - color.g, 255 - color.b))
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)

	return btn
end

function TestPanel:init(width, height)
	self.width = width
	self.height = height or 320
	local bg = LayerColor:createWithColor(ccc3(0, 0, 0), self.width, self.height)
	bg:setOpacity(255*0.6)
	bg:setTouchEnabled(true, 0, true)
	bg:setAnchorPoint(ccp(0, 1))
	bg:ignoreAnchorPointForPosition(false)
	self:addChild(bg)

	self.row = 0

	self:addClose()
	self.row = self.row + 1
	self:addBuySuccess()
	self.row = self.row + 1
	self:addChangeTime()

	bg:changeWidthAndHeight(self.width, (self.row+1)*itemh+50)

end

function TestPanel:getPosY()
	return -((self.row+1)*itemh + 1)
end

function TestPanel:addClose()
	local button1 = TestPanel:createTestButton("星星储蓄罐-查看数据", hex2ccc3("CCFF66"), 18, self.width/2 - 2, itemh - 2)
	button1:setPosition(ccp(1, self:getPosY()))
	local label = nil
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		if label then 
			label:removeFromParentAndCleanup(true) 
			label = nil
		end
		local data = ""
		for k,v in pairs(StarBank.data) do
			if k ~= "config" and k ~= "server_config" then
				data = data .. k .. "=" .. tostring(v)..",\n"
			end
		end
		local config = StarBank:getConfig()
		data = data .. "config="..table.tostring(config)
		label = TextField:create(data.."\nstate:"..StarBankUnitTest.StateName[StarBank.state], nil, 18)
		label:setColor(ccc3(255, 255, 255))
		label:setAnchorPoint(ccp(0.5,1))
		label:setPositionX(self.width/2)
		label:setPositionY(-((self.row+2)*itemh + 1))
		self:addChild(label)
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("关闭", hex2ccc3("CCFF66"), 18, self.width/2 - 2, itemh - 2)
	button1:setPosition(ccp(self.width/2, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		self:removeFromParentAndCleanup(true)
		StarBankUnitTest.panel = nil
	end)
	self:addChild(button1)

	return true
end

function TestPanel:addChangeTime()
	local button1 = TestPanel:createTestButton("+时间1天", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(1, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		__g_utcDiffSeconds = (__g_utcDiffSeconds or 0) + 24*3600
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("-时间1天", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*2 + 4, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		__g_utcDiffSeconds = (__g_utcDiffSeconds or 0) - 24*3600
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("改服务端配置", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*4 + 8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		local ic = {1,2,3,4}
		local count = math.random(0, 4)
		local rc = ""
		local max = 4
		for i=1,count do
			local index = math.random(1, max)
			rc = rc .. ic[index] .. ","
			table.remove(ic, index)
			max = max - 1
		end

		rc = string.sub(rc, 1, string.len(rc) - 1)
		StarBank:print(table.tostring(rc))

		StarBank.data.server_config = {
			levelIndex = rc,
			bank = (require "zoo.panel.StarBank.StarBankConfig"),
		}

		StarBank:checkState()
	end)
	self:addChild(button1)

	local colors = {
	"blue",
	"green",
	"orange",
	"purple",
	"gold",
}
	local index = 1

	local button1 = TestPanel:createTestButton("设置颜色", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*4 + 8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		local config = StarBank:getConfig()
		config.color = colors[index]
		index = index + 1
		if index > #colors then
			index = 1
		end
		Notify:dispatch("StarBankUpdateStateEvent")
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("LevelDown", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*6 + 8+4, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		StarBank:levelDown()
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("SyncData", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*8 + 8+8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		StarBankUnitTest:syncData()
	end)
	self:addChild(button1)
end

function TestPanel:addBuySuccess()
	local button1 = TestPanel:createTestButton("购买", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(1, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		StarBank.state = StarBankState.kFullCanBuy
		StarBank:buy()
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("获得星星", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*2+4, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		-- for i=1,100 do
			local ostar = 0--math.random(0, 4)
			local cstar = 3--math.random(0, 4)
			StarBank.curWm = 60
			-- StarBank.state = StarBankState.kNotFullCanBuy
			-- StarBank.state = StarBankState.kEmpty
			StarBank.state = StarBankState.kFullCanBuy
			StarBank:print("add star:",ostar,cstar)
			StarBank:addStar(ostar, cstar)
			Notify:dispatch("StarBankEventShowAddStarSuccessPanel")
		-- end
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("冷却50s", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*4+8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		local config = StarBank:getConfig()
		config.coolDuration = 50
	end)
	self:addChild(button1)

	local button1 = TestPanel:createTestButton("购买时效50s", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*6+8+4, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		local config = StarBank:getConfig()
		config.buyTimeOut = 50
	end)

	self:addChild(button1)

	local button1 = TestPanel:createTestButton("成功面板", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*8+8+8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		StarBank.curWm = 80
		local successPanel = StarBankBuySuccessPanel:create()
		successPanel.onCloseBtnTapped = function ( ... )
			successPanel.allowBackKeyTap = false
			PopoutManager:sharedInstance():remove(successPanel, true)
		end
	
		successPanel:popout()
	end)

	self:addChild(button1)

	local starc = {
		{0,1},{0,2},{0,3},{0,4},
		{1,2},{1,3},{1,4},
		{2,3},{2,4},
		{3,4},
	}
	local index = 0

	local button1 = TestPanel:createTestButton("星星成功", hex2ccc3("66CCFF"), 18, itemh*2, itemh - 2)
	button1:setPosition(ccp(itemh*10+8+8, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
		-- local ostar = math.random(0, 4)
		-- local cstar = math.random(0, 4)
		-- StarBank:print("show star:",ostar, cstar)
		index = index + 1
		if index > #starc then index = 1 end
		-- index = 3
		printx(10, index)
		StarBank:passLevelShowPanel(1, starc[index][1], starc[index][2], 18)
	end)

	self:addChild(button1)

	return true
end

function StarBankUnitTest:syncData( )
	local errorCode = tonumber(109) or -1
	local function onUseLocalFunc(errCode)
		if errCode then
			_G.kUserLogin = false
		end
	end
	local function onUseServerFunc(data)
		UserManager.getInstance():updateUserData(data)
		UserService.getInstance():updateUserData(data)
		UserService:getInstance():clearCachedHttp()

		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	end
	local logic = SyncExceptionLogic:create(errorCode)
	logic:syncData(onUseServerFunc, onUseLocalFunc)
end

function StarBankUnitTest:init()
	if self.panel then 
		self.panel:removeFromParentAndCleanup(true)
	end

	local size = Director:sharedDirector():getVisibleSize()
	local pos = Director:sharedDirector():getVisibleOrigin()
	local panel = TestPanel:create(size.width, size.height / 3)
	panel:setPositionY(size.height)
	Director:sharedDirector():run():addChild(panel, "popoutLayer")
	self.panel = panel
end

function StarBankUnitTest:createTestButton( ... )
	return TestPanel:createTestButton(...)
end

Notify:register( "StarBankUnitTestEventInit", StarBankUnitTest.init, StarBankUnitTest )