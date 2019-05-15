local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceLotteryLogPanel = class(BasePanel)

function RankRaceLotteryLogPanel:create()

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()


    local panel = RankRaceLotteryLogPanel.new()
    panel:init()
    return panel
end

function RankRaceLotteryLogPanel:init()
    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/lotteryLog')
	BasePanel.init(self, ui)

    self.vscroll = self.ui:getChildByPath('content')


    local rawLog = rrMgr:getData():getLotteryLog()



    local logs = {}
    for i, v in ipairs(rawLog) do
        local infos = Misc:parse(v, ',')
        table.insert(logs, table.map(tonumber, infos))
    end

    table.sort(logs, function ( a, b )
        local ta = a[3] or 0
        local tb = b[3] or 0
        return ta > tb
    end)


    for i, v in ipairs(logs) do
        local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/item2')

        local label = itemUI:getChildByPath('label')
        local dimensions = label:getDimensions()
        label:setDimensions(CCSizeMake(dimensions.width, 0))


        local date = os.date('*t', v[3]/1000)
        itemUI:getChildByPath('label'):setString(localize('rank.race.lottery.log', {
            year = date.year,
            month = date.month,
            day = date.day,
            propname = localize("prop.name."..tostring(v[1])),
            propnum = v[2],
        }))

        local line = itemUI:getChildByPath('line')
        line:setPositionY(line:getPositionY() - math.max(label:getContentSize().height - 30.3, 0))

        self.vscroll:addItem(itemUI)
    end

    if #logs <= 0 then
        local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/item2')
        itemUI:getChildByPath('label'):setString('暂无记录')
        self.vscroll:addItem(itemUI)
    end

end


function RankRaceLotteryLogPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceLotteryLogPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function RankRaceLotteryLogPanel:onCloseBtnTapped( ... )
    self:_close()
end

return RankRaceLotteryLogPanel
