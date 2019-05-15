local function setButtonLabel( label, bounds, text, scale)
    label:changeFntFile("fnt/register.fnt")
   	label:setText(text)
   	label:setScale(scale or 0.8)
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setPosition(ccp(bounds.size.width/2, -bounds.size.height/2))
end


local SelectPanel = class(BasePanel)

SelectPanel.kColor = {
	kBlue = 1,
	kGreen = 2
}

SelectPanel.kResult = {
	kCancel = 'SelectPanel.kResult.kCancel',
	kConfirm = 'SelectPanel.kResult.kConfirm'
}

function SelectPanel:init(ui)
	BasePanel.init(self, ui)

	self.cancelBtn = self.ui:getChildByName('btn_1')
	self.confirmBtn = self.ui:getChildByName('btn_2')


	self.cancelBtn:setTouchEnabled(true)
    self.confirmBtn:setTouchEnabled(true)

    self.cancelBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    	self:onCancel()
    end, 1))

    self.confirmBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    	self:onConfirm()
    end, 1))

    self:setCancelBtnString('取消')
    self:setConfirmBtnString('确定')

    self:setCancelBtnColor(SelectPanel.kColor.kBlue)
    self:setConfirmBtnColor(SelectPanel.kColor.kGreen)

    self.label = self.ui:getChildByName('label')
end

function SelectPanel:_close()

	if self.isDisposed then
		return
	end

	PopoutManager:sharedInstance():remove(self)
end

function SelectPanel:popout()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
end

function SelectPanel:onCancel( ... )
	self:dispatchEvent(Event.new(SelectPanel.kResult.kCancel))
	self:_close()
end

function SelectPanel:onConfirm( ... )
	self:dispatchEvent(Event.new(SelectPanel.kResult.kConfirm))
	self:_close()
end

function SelectPanel:ad( ... )
	BasePanel.ad(self, ...)
end

function SelectPanel:setBtnString(btn, string)
	if self.isDisposed then
		return
	end

	local keys = {
		['快速登录'] = 1,
		['直接使用'] = 2,
		['换个号码'] = 3,
		['账号登录'] = 4,
	}

	local index = keys[string]
	if index then
		btn:getChildByName('label'):setText(' ')
		for v = 1, 4 do
			btn:getChildByName('t'..v):setVisible(v == index)
		end
	else
		for v = 1, 4 do
			btn:getChildByName('t'..v):setVisible(false)
		end
		setButtonLabel(btn:getChildByName('label'), btn:getGroupBounds(self.ui), string, 0.6)
	end
end

function SelectPanel:setCancelBtnString( string )
	self:setBtnString(self.cancelBtn, string)
end

function SelectPanel:setConfirmBtnString( string )
	self:setBtnString(self.confirmBtn, string)
end

function SelectPanel:setConfirmBtnColor( color )
	self:setBtnColor(self.confirmBtn, color)
end

function SelectPanel:setCancelBtnColor( color )
	self:setBtnColor(self.cancelBtn, color)
end

function SelectPanel:setBtnColor( btn, color )
	if self.isDisposed then
		return
	end

	local blue_visible = false
	local green_visible = false
	if color == SelectPanel.kColor.kBlue then
		blue_visible = true
	elseif color == SelectPanel.kColor.kGreen then
		green_visible = true
	end

	btn:getChildByName('m_blue'):setVisible(blue_visible)
	btn:getChildByName('m_green'):setVisible(green_visible)
end

function SelectPanel:setLabel( str )
	if self.isDisposed then
		return
	end
	
	self.label:setString(str)
end

return SelectPanel
