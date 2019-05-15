
local textKeys = {
	'new.ladybug.desc.text.1',
	'new.ladybug.desc.text.2',
	'new.ladybug.desc.text.3',
	'new.ladybug.desc.text.4',
	'new.ladybug.desc.text.5',
}

local NewPanel = class(BasePanel)

function NewPanel:create()
    local panel = NewPanel.new()
    panel:loadRequiredResource("ui/newLadybug.json")
    panel:init()
    return panel
end

function NewPanel:init()
    local ui = self:buildInterfaceGroup("ladybug.new/descPanel")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.content = self.ui:getChildByName('content')
    self.btn = self.ui:getChildByName('btn')
    self.btn = GroupButtonBase:create(self.btn)
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onCloseBtnTapped()
    end)
    self.btn:setString('知道了')

    self.bg1 = self.ui:getChildByName('bg')
    self.bg2 = self.ui:getChildByName('bg2')

    self:initText()
end

function NewPanel:initText( ... )

	local contentWidth = self.content:getContentSize().width * self.content:getScaleX()
	local contentHeight = self.content:getContentSize().height * self.content:getScaleY()
	local contentPos = self.content:getPosition()
	local deltaY = 0
	for index, key in ipairs(textKeys) do
		local label = TextField:create(tostring(index)..'、'..localize(key), nil, 28, CCSizeMake(contentWidth, 0))
		label:setAnchorPoint(ccp(0, 1))
		label:setColor(hex2ccc3('3F8A00'))
		self.ui:addChild(label)
		label:setPosition(ccp(contentPos.x, contentPos.y + deltaY))

		deltaY = deltaY - label:getContentSize().height - 5
	end

	self.content:setOpacity(0)
	local adjustY = contentHeight + deltaY
	self.btn:setPositionY(self.btn:getPositionY() + adjustY)

	local bg1Size = self.bg1:getPreferredSize()
	self.bg1:setPreferredSize(CCSizeMake(bg1Size.width, bg1Size.height - adjustY))

	local bg2Size = self.bg2:getPreferredSize()
	self.bg2:setPreferredSize(CCSizeMake(bg2Size.width, bg2Size.height - adjustY))
end

function NewPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function NewPanel:popout()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function NewPanel:onCloseBtnTapped( ... )
    self:_close()
end

return NewPanel
