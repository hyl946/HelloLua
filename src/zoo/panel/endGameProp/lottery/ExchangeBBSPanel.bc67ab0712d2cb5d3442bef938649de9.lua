
local UIHelper = require 'zoo.panel.UIHelper'

local ExchangeBBSPanel = class(BasePanel)

function ExchangeBBSPanel:create(diamondNum, voucherNum)
    local panel = ExchangeBBSPanel.new()
    panel:init(diamondNum, voucherNum)
    return panel
end

function ExchangeBBSPanel:init(diamondNum, voucherNum)
    local ui = UIHelper:createUI("ui/lottery.json", "add.step.lottery/exchange_bbs")
	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    local desc_label = self.ui:getChildByPath('desc_label')
    desc_label:setString('全新的步数转盘使用金券进行抽奖。\n已经自动帮您把拥有的钻石兑换成金券啦！')

    local num_1 = self.ui:getChildByPath('bubble_fg/num_1')
    local num_2 = self.ui:getChildByPath('bubble_fg/num_2')

    diamondNum = diamondNum or 1
    voucherNum = voucherNum or 4

    UIHelper:setCenterText(num_1, tostring(diamondNum), 'fnt/xingxingchui_countDown.fnt')
    UIHelper:setCenterText(num_2, tostring(voucherNum), 'fnt/xingxingchui_countDown.fnt')

    local diamondIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.DIAMONDS)
    local voucherIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.VOUCHER)

    self.ui:getChildByPath('bubble_fg'):addChild(diamondIcon, 0)
    self.ui:getChildByPath('bubble_fg'):addChild(voucherIcon, 0)

    local bubble_1 = self.ui:getChildByPath('bubble_fg/bubble_1')
    local bubble_2 = self.ui:getChildByPath('bubble_fg/bubble_2')

    local function get_rect( bubble )
    	bubble:setAnchorPointCenterWhileStayOrigianlPosition()

    	local size = bubble:getContentSize()
    	local sx, sy = bubble:getScaleX(), bubble:getScaleY()

    	local width = size.width * sx
    	local height = size.height * sy

    	local pos = bubble:getPosition()

    	return {
    		center = ccp(pos.x - 7, pos.y + 6),
    		width = width,
    		height = height,
    	}
    end

    local function fitIconInRect( icon, rect )
    	icon:setAnchorPoint(ccp(0.5, 0.5))
    	icon:setPosition(rect.center)
    end

    fitIconInRect(diamondIcon, get_rect(bubble_1))
    fitIconInRect(voucherIcon, get_rect(bubble_2))


end

function ExchangeBBSPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function ExchangeBBSPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function ExchangeBBSPanel:onCloseBtnTapped( ... )
    self:_close()
end


return ExchangeBBSPanel
