local DisplayQualityManager = require "zoo.panel.customDisplayQuality.DisplayQualityManager"
local ConfirmRestartSelectQualityPanel = require "zoo.panel.customDisplayQuality.ConfirmRestartSelectQualityPanel"

local SelectQualityPanel = class(BasePanel)

function SelectQualityPanel:create(closeCallback)
    local panel = SelectQualityPanel.new()
    panel:loadRequiredResource("ui/customDisplayQuality.json")
    panel:init()
    panel.closeCallback = closeCallback
    return panel
end

function SelectQualityPanel:init()
    local ui = self:buildInterfaceGroup("custom.display.quality/panel")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.label = self.ui:getChildByName('label')

    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:setString('立即更换')
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
        if(self.targetRatioIndex ~= self.originRatioIndex) then
            DcUtil:selectGraphicQuality(1, self.targetRatioIndex)
            PopoutManager:sharedInstance():removeAll()
            DisplayQualityManager:setQuality(self.targetRatioIndex)
            ConfirmRestartSelectQualityPanel:create():popout()
        else
            DcUtil:selectGraphicQuality(0, self.targetRatioIndex)
            self:_close()
        end
    end)

    self.ratios = {
        self.ui:getChildByName('radio_1'),
        self.ui:getChildByName('radio_2'),
        self.ui:getChildByName('radio_3'),
    }
    for i = 1, 3 do
        local ratio = self.ratios[i]
        ratio:setTouchEnabled(true)
		local onClick = function ( ... )
            self.targetRatioIndex = i
            self:updateRatio()

            local flag = ratio:getChildByName('flag')
            local arr_bg = CCArray:create()
            arr_bg:addObject(CCScaleTo:create(0.1, 1.1))  
            arr_bg:addObject(CCScaleTo:create(0.1, 1))
            flag:runAction(CCSequence:create(arr_bg))

        end
        ratio:ad(DisplayEvents.kTouchTap, onClick)
    end

    self.originRatioIndex = DisplayQualityManager:getQuality()
    self.targetRatioIndex = self.originRatioIndex

    self:updateRatio()
end

function SelectQualityPanel:updateTitleInfo()
    if(self.targetRatioIndex == 1) then
        self.label:setString('目前已经是当前性能下最佳画质设置了哦！')
    else
        self.label:setString('建议你选择一般画质进行游戏，以降低意外退出游戏的概率哦！任何时候都可以通过设置面板重新更换画质哦！')
    end
end

SelectQualityPanel.QUALITY_DESCRIPTS = {"一般", "中等", "高清"}

function SelectQualityPanel:updateRatio()
    local ratioIndex = self.targetRatioIndex--DisplayQualityManager:getQuality()

    for i = 1, 3 do
        local ratio = self.ratios[i]
        local flagRecommand = ratio:getChildByName('flag2')
        local flag = ratio:getChildByName('flag')
        local label = ratio:getChildByName('label')

        for j = 1, 3 do
            local bg = ratio:getChildByName('' .. j)
            if(i == j) then
                bg:setVisible(true)
            else
                bg:setVisible(false)
            end
        end

        if(i == 1) then
            flagRecommand:setVisible(true)
        else
            flagRecommand:setVisible(false)
        end

        label:setString(self.QUALITY_DESCRIPTS[i])

        if(ratioIndex == i) then
            flag:setVisible(true)
        else
            flag:setVisible(false)
        end

    end

    self:updateTitleInfo()
end

function SelectQualityPanel:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)

    if(self.closeCallback) then
        self.closeCallback()
    end
end

function SelectQualityPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function SelectQualityPanel:onCloseBtnTapped( ... )
    self:_close()
end

return SelectQualityPanel
