local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceDescPanel = class(BasePanel)

function RankRaceDescPanel:create()

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()

    local panel = RankRaceDescPanel.new()
    panel:init()
    return panel
end

function RankRaceDescPanel:init()
    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/rule')
	BasePanel.init(self, ui)

    for i = 1, 3 do
        local page = self.ui:findChildByName('page' .. i)
        page:setItemVerticalMargin(25)
        for j = 1, 999 do

            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            local key = ""
            if SaijiIndex == 1 then
                key = 'rank.race.desc.page' .. i .. '.' .. j
            else
                key = 'rank.race.desc.page' .. i .. '.' .. j .. ".s"..SaijiIndex
            end

            local text = localize2(key)
            if j >= 3 and key == text then
                break
            end

            local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/descItem')
            local label = itemUI:getChildByPath('label')
            label:setString(text .. '\n')
            local dimensions = label:getDimensions()
            label:setDimensions(CCSizeMake(dimensions.width, 0))

            page:addItem(itemUI)
        end
    end

    self.page = self.ui:getChildByPath('page')

    for i = 1, 3 do
        local pageBtn = self.ui:getChildByPath('bar'):findChildByName('item' .. i)
        pageBtn:getChildByPath('label'):setString(tostring(i))
        local pageIndex = i
        pageBtn.onButtonTap = function ( ... )
            if self.isDisposed then return end
            self.page:turnTo(pageIndex)
            return true
        end
    end
    self:onPageTo(1, true)
end

function RankRaceDescPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceDescPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

end

function RankRaceDescPanel:onPageTo( index, noAnim)
    if self.isDisposed then return end
    for i = 1, 999 do
        local btn = self.ui:getChildByPath('bar'):findChildByName('item' .. tostring(i))
        if btn then
            btn:getChildByPath('label'):setVisible(index == i)
            btn:getChildByPath('bg1'):setVisible(index ~= i)
            btn:getChildByPath('bg2'):setVisible(index == i)
        else
            break
        end
    end

    for i = 1, 3 do
        -- self.ui:getChildByPath('title' .. i):setVisible(i == index)
        if i == index then
            if not noAnim then
                if self.ui:getChildByPath('title' .. i):getOpacity() < 1 then
                    self.ui:getChildByPath('title' .. i):runAction(CCFadeIn:create(0.2))
                end
            else
                self.ui:getChildByPath('title' .. i):setOpacity(255)
            end
        else
            if not noAnim then
                if self.ui:getChildByPath('title' .. i):getOpacity() > 250 then
                    self.ui:getChildByPath('title' .. i):runAction(CCFadeOut:create(0.2))
                end
            else
                self.ui:getChildByPath('title' .. i):setOpacity(0)
            end
        end
    end
end


function RankRaceDescPanel:onCloseBtnTapped( ... )
    self:_close()
end

function RankRaceDescPanel:turnTo(pageIndex, duration)
    if self.isDisposed then return end
    self.page:turnTo(pageIndex, duration)
end

return RankRaceDescPanel
