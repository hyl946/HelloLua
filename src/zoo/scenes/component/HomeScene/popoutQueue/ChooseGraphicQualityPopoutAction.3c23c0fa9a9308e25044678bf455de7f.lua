require "zoo.common.FAQ"
require 'zoo.panel.AlertNewLevelPanel'
require "zoo.panel.CommonTip"
local DisplayQualityManager = require "zoo.panel.customDisplayQuality.DisplayQualityManager"
local SelectQualityPanel = require "zoo.panel.customDisplayQuality.SelectQualityPanel"

ChooseGraphicQualityPopoutAction = class(HomeScenePopoutAction)

function ChooseGraphicQualityPopoutAction:ctor()
    self.name = "ChooseGraphicQualityPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function ChooseGraphicQualityPopoutAction:checkCanPop()
    if self.debug then
        return self:onCheckPopResult(true)
    end
    self:onCheckPopResult(DisplayQualityManager:canForcePopout())
end

function ChooseGraphicQualityPopoutAction:popout( next_action )
	local panel = SelectQualityPanel:create(next_action)
    panel:popout()
    DcUtil:startChooseGraphicQuality(0)
    DisplayQualityManager:markHasForcePopout()
end