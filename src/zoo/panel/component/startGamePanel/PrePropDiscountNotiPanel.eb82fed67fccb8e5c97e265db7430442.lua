local UIHelper = require 'zoo.panel.UIHelper'

local PrePropDiscountNotiPanel = class(BasePanel)

function PrePropDiscountNotiPanel:create(discountPercent)
    local panel = PrePropDiscountNotiPanel.new()
    panel:init(discountPercent)
    return panel
end

function PrePropDiscountNotiPanel:init(discountPercent)
    local ui = UIHelper:createUI("ui/pre_prop_discount.json", "prePropDiscountNoti/notiPanel")
	BasePanel.init(self, ui)

    local discountSize = self.ui:getChildByName("discountNum")
    if discountSize then
        discountSize:setVisible(false)
        local pos = discountSize:getPosition()
        local size = discountSize:getContentSize()
        local discountLabel = BitmapText:create(""..discountPercent, "fnt/countdown.fnt")
        discountLabel:setScale(1.3)
        discountLabel:setAnchorPoint(ccp(0, 1))
        discountLabel:setPosition(ccp(pos.x + 7, pos.y + 10))
        self.ui:addChild(discountLabel)
    end

    local closeBtn = ui:getChildByName("closeBtn")
    closeBtn:setTouchEnabled(true, 0, true)
    closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    local btn = GroupButtonBase:create(self.ui:getChildByPath("okBtn"))
    btn:setString(Localization:getInstance():getText("button.ok"))
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onCloseBtnTapped()
    end)
end

function PrePropDiscountNotiPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function PrePropDiscountNotiPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function PrePropDiscountNotiPanel:onCloseBtnTapped( ... )
    self:_close()
end

return PrePropDiscountNotiPanel
