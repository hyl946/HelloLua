
local UIHelper = require 'zoo.panel.UIHelper'

local XFHistoryPanel = class(BasePanel)
local XFLogic = require 'zoo.panel.xfRank.XFLogic'

function XFHistoryPanel:create(xfData)
    local panel = XFHistoryPanel.new()
    panel:init(xfData)
    return panel
end

function XFHistoryPanel:init(xfData)

    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/history")
    BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    local nothing = true

    local vscroll = self.ui:getChildByPath('content')

    for _, v in ipairs(xfData.fullstar_rank_history or {}) do
        local sz1 = string.format('    满星榜全国第%d名', v.fullstar_rank)
        local sz2 = string.format('%s', os.date('%Y-%m-%d %H:%M:%S', v.fullstar_ts/1000))

        local t1 = TextField:create(sz1, nil, 24)
        t1:setAnchorPoint(ccp(0, 1))
        t1:setColor(hex2ccc3('A14A0E'))

        local t2 = TextField:create(sz2, nil, 24)
        t2:setAnchorPoint(ccp(1, 1))
        t2:setColor(hex2ccc3('A14A0E'))


        local t = CocosObject:create()
        t:addChild(t1)
        t:addChild(t2)

        t1:setPosition(ccp(0, 0))
        t2:setPosition(ccp(485, 0))




        vscroll:addItem(t)
        nothing = false
    end

    if nothing then
        local sz = string.format('    暂无记录 静候佳音！')
        local t = TextField:create(sz, nil, 24)
        t:setAnchorPoint(ccp(0, 1))
        t:setColor(hex2ccc3('A14A0E'))
        vscroll:addItem(t)
        nothing = false
    end
end

function XFHistoryPanel:_close()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function XFHistoryPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function XFHistoryPanel:onCloseBtnTapped( ... )
    self:_close()
end


-- XFHistoryPanel:create():popout()


return XFHistoryPanel

