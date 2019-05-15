require "zoo.panel.basePanel.BasePanel"
require "hecore.ui.PopoutManager"
require "zoo.util.IllegalWordFilterUtil"

NickNamePanel = class(BasePanel)

function NickNamePanel:create(callback)
	local panel = NickNamePanel.new()
	if not panel:_init(callback) then panel = nil end
	return panel
end

function NickNamePanel:_init(callback)
	self:loadRequiredResource(PanelConfigFiles.panel_nick_name)
	ui = self.builder:buildGroup("NickNamePanel")
	self:init(ui)
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local bg = ui:getChildByName("bg")
	local title = ui:getChildByName("title")
	local cnt = ui:getChildByName("cnt")
	local btn = ui:getChildByName("btn")
	local nameLabel = ui:getChildByName("touch")
	local inputSelect = nameLabel:getChildByName("inputBegin")

	btn = GroupButtonBase:create(btn)
	local inputSize = inputSelect:getContentSize()
	local inputPos = inputSelect:getPosition()

	inputSelect:setVisible(true)
	inputSelect:removeFromParentAndCleanup(false)
	local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2)

	local input = TextInput:create(inputSize, Scale9Sprite:createWithSpriteFrameName("NickNamePanel_ui_empty20000"),
		inputSelect.refCocosObj)
	input.originalX_ = position.x
	input.originalY_ = position.y
	input:setText("")
	input:setPosition(position)
	input:setFontColor(ccc3(0, 0, 0))
	input:setMaxLength(15)

	nameLabel:addChild(input)
	inputSelect:dispose()

	title:setText(Localization:getInstance():getText("nick.name.panel.title"))
	local titleSize = title:getContentSize()
	local titleScale = 65 / titleSize.height
	title:setScale(titleScale)
	title:setPositionX((bg:getGroupBounds().size.width / self:getScale() - titleSize.width * titleScale) / 2)
	cnt:setString(Localization:getInstance():getText("nick.name.panel.content"))
	btn:setString(Localization:getInstance():getText("button.ok"))

	local function onTextBegin() end
	input:addEventListener(kTextInputEvents.kBegan, onTextBegin)
	local function onTextEnd() 
		-- 敏感词过滤
		local content = input:getText()
		if IllegalWordFilterUtil.getInstance():isIllegalWord(content) then
			input:setText("")
			CommonTip:showTip(Localization:getInstance():getText("error.tip.illegal.word"), "negative")
		end
	end
	input:addEventListener(kTextInputEvents.kEnded, onTextEnd)
	local function onButton()
		local content = input:getText()
		if callback then callback(content) end
		PopoutManager:sharedInstance():remove(self)
	end
	btn:addEventListener(DisplayEvents.kTouchTap, onButton)

	return true
end

function NickNamePanel:popout()
	PopoutQueue:sharedInstance():push(self)
end