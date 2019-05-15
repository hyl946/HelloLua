require "zoo.panel.basePanel.BasePanel"
require "hecore.ui.PopoutManager"

SoftwareKeyboardInput = class(Layer)

function SoftwareKeyboardInput:create(input, config)
	local panel = SoftwareKeyboardInput.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_with_keypad)
	if panel:init(input, config) then
		return panel
	else
		return nil
	end
end


function SoftwareKeyboardInput:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end
	
-- config = {						-- 所有选项为空即不设置
-- 	changeCallback = function		-- 文本内容有变化
-- 	enterCallback = function		-- 点击确认
-- 	emptyCallback = function		-- 文本变为空
--  outsideCallback = function		-- 点击到键盘外
-- 	max = number					-- 输入长度限制
-- 	replaceOnMax = boolean			-- 达到输入长度后输入是否替换最后一个字符
-- }
function SoftwareKeyboardInput:init(input, config)
	if not input then return false end
	config = config or {}

	self:initLayer()

	-- 属性
	self.input = input
	self.content = ""
	self.config = config

	-- 初始化视图
	self.ui = self.builder:buildGroup("Keyboard") --ResourceManager:sharedInstance():buildGroup("Keyboard")
	local wSize = CCDirector:sharedDirector():getWinSize()
	self:addChild(self.ui)

	-- 控件
	self.numbers = {}
	for i = 1, 10 do
		local key = self.ui:getChildByName("num"..i)
		key.name = i
		table.insert(self.numbers, key)
	end
	self.backspace = self.ui:getChildByName("backspace")
	self.enter = self.ui:getChildByName("enter")
	self.background = self.ui:getChildByName("background")
	self.height = self:getGroupBounds().size.height

	-- 设置文字（需要本地化文件）
	for i = 1, 9 do
		self.numbers[i]:getChildByName("text"):setString(i)
	end
	self.numbers[10]:getChildByName("text"):setString("0")
	self.backspace:getChildByName("text"):setString(Localization:getInstance():getText("soft.keyboard.backspace"))
	self.enter:getChildByName("text"):setString(Localization:getInstance():getText("soft.keyboard.enter"))

	-- 添加监听器
	local function onBackspaceTapped()
		if string.len(self.content) == 0 or not self.backspace.canTriggerTapEvent then 
			if self.scheduleScriptFuncID then 
				Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
			end
			self.scheduleScriptFuncID = nil;
			return 
		end

		self.content = string.sub(self.content, 1, -2)
		self.input:setString(self.content)
		if self.config.changeCallback then
			self.config.changeCallback(self.content, string.len(self.content))
		end
		if string.len(self.content) == 0 and self.config.emptyCallback then
			self.config.emptyCallback()
		end
	end
	self.backspace:setButtonMode(true)
	--self.backspace:ad(DisplayEvents.kTouchTap, onBackspaceTapped)

	local function onBackspaceTouchBegin()
		if not self.scheduleScriptFuncID then 
			self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onBackspaceTapped,0.2,false)
		end
	end
	local function onBackspaceTouchEnd()
		onBackspaceTapped();
		if self.scheduleScriptFuncID then 
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
		end
		self.scheduleScriptFuncID = nil;
	end
	self.backspace:ad(DisplayEvents.kTouchBegin,onBackspaceTouchBegin)
	self.backspace:ad(DisplayEvents.kTouchEnd,onBackspaceTouchEnd)

	local function onEnterTapped()
		if self.config.enterCallback then
			self.config.enterCallback(self.content, string.len(self.content))
		end
	end
	self.enter:setButtonMode(true)
	self.enter:ad(DisplayEvents.kTouchTap, onEnterTapped)
	local function onNumTapped(evt)
		if config.max and string.len(self.content) >= config.max then
			if self.config.replaceOnMax then
				self.content = string.sub(self.content, 1, -2)
				self.content = self.content..evt.context
				self.input:setString(self.content)
				if self.config.changeCallback then
					self.config.changeCallback(self.content, string.len(self.content))
				end
			end
		else
			self.content = self.content..evt.context
			self.input:setString(self.content)
			if self.config.changeCallback then
				self.config.changeCallback(self.content, string.len(self.content))
			end
		end
	end
	for i = 1, 9 do
		self.numbers[i]:setButtonMode(true)
		self.numbers[i]:ad(DisplayEvents.kTouchTap, onNumTapped, i)
	end
	self.numbers[10]:setButtonMode(true)
	self.numbers[10]:ad(DisplayEvents.kTouchTap, onNumTapped, 0)
	
	self:setTouchEnabledWithMoveInOut(true, 0, true)
	-- self:ad(DisplayEvents.kTouchBeginOutSide, onTouchOutSideSoftkeyboard)

	self.background:setTouchEnabled(true, 0, true)
	return true
end

local function onTouchOutSideSoftkeyboard(event)
	if _G.isLocalDevelopMode then printx(0, "onTouchOutSideSoftkeyboard") end
	if event.target and not event.target.isDisposed then
		local pos = event.target:getPositionY()
		local parent = event.target:getParent()
		local wPos = parent:convertToWorldSpace(ccp(0, pos))
		if event.globalPosition.y > wPos.y or event.globalPosition.y < wPos.y - event.target.height then
			if event.target.config.outsideCallback then
				event.target.config.outsideCallback(event.target.content, string.len(event.target.content), event.globalPosition)
			end
		end
	end
end

-- 位置的 x 值会被忽略掉
function SoftwareKeyboardInput:start(target, position)
	if not target or not position then return end

	self:stopAllActions()
	local wSize = Director:sharedDirector():getWinSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local targetPos = self.input:getPosition()
	targetPos = self.input:getParent():convertToWorldSpace(ccp(targetPos.x, targetPos.y))
	local iSize = self.input:getGroupBounds().size
	local sSize = self:getGroupBounds().size
	position = target:convertToWorldSpace(position)
	local deltaY = 0
	if position.y - sSize.height < vOrigin.y then
		deltaY = vOrigin.y - position.y + sSize.height
		if not target.keepPos then target:runAction(CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, deltaY)))) end
		self.deltaY = deltaY
	end
	self.target = target
	
	if _G.isLocalDevelopMode then printx(0, "self.target", self.target) end
	local function onAnimOver()
		self.backspace:setTouchEnabled(true)
		self.enter:setTouchEnabled(true)
		for i = 1, 10 do self.numbers[i]:setTouchEnabled(true, 0, true) end
		self:ad(DisplayEvents.kTouchBeginOutSide, onTouchOutSideSoftkeyboard)
	end
	self:setPosition(ccp(0, -wSize.height + vOrigin.y))
	self:runAction(CCSequence:createWithTwoActions(CCEaseSineOut:create(CCMoveTo:create(0.2, ccp(0, position.y - wSize.height + vOrigin.y + deltaY))), CCCallFunc:create(onAnimOver)))
	local scene = Director:sharedDirector():getRunningScene()
	-- scene:addChild(self, SceneLayerShowKey.POP_OUT_LAYER)
	PopoutManager:sharedInstance():add(self, false, false)
end

function SoftwareKeyboardInput:cancel(clean, isDeleteSelf)
	if isDeleteSelf == nil then isDeleteSelf = false end
	local wSize = Director:sharedDirector():getWinSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self:stopAllActions()
	if _G.isLocalDevelopMode then printx(0, "self.target", self.target) end
	if self.target and not self.target.isDisposed and not self.target.keepPos then
		self.target:runAction(CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, -self.deltaY))))
		self.deltaY = 0
		self.taget = nil
	end
	local function onAnimOver()
		-- self:removeFromParentAndCleanup(false)
		PopoutManager:sharedInstance():remove(self, isDeleteSelf)
	end
	for i = 1, 10 do self.numbers[i]:setTouchEnabled(false) end
	self.enter:setTouchEnabled(false)
	self.backspace:setTouchEnabled(false)
	self:rm(DisplayEvents.kTouchBeginOutSide, onTouchOutSideSoftkeyboard)
	self:runAction(CCSequence:createWithTwoActions(CCEaseSineIn:create(CCMoveTo:create(0.2, ccp(0, -wSize.height + vOrigin.y))), CCCallFunc:create(onAnimOver)))

	if clean then
		self:cleanText()
	end
end

function SoftwareKeyboardInput:cleanText()
	if self.config.placeholder then self.input:setString(self.config.placeholder)
	else
		self.content = ""
		self.input:setString(self.content)
		if self.config.emptyCallback then
			self.config.emptyCallback()
		end
	end
end

function SoftwareKeyboardInput:onKeyBackClicked()
	onTouchOutSideSoftkeyboard({target = self, globalPosition = ccp(-1, -1)})
end