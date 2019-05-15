
local UIHelper = require 'zoo.panel.UIHelper'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'

local XFPreheatPanel = class(BasePanel)

function XFPreheatPanel:create()
    local panel = XFPreheatPanel.new()
    panel:init()
    return panel
end

function XFPreheatPanel:init()
    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/preheat")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724, nil)

	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    local jpgBG = Sprite:create('materials/xf_preheat_bg.jpg')
	jpgBG:setAnchorPoint(ccp(0, 1))
	ui:addChildAt(jpgBG, 0)

	self.tickTaskMgr = TickTaskMgr.new()
	local TASK_ID = 1
	self.tickTaskMgr:setTickTask(TASK_ID, function ( ... )
		self:refresh()
	end)
	self.tickTaskMgr:step()

end

function XFPreheatPanel:refresh( ... )
	if self.isDisposed then return end

	local mainBeginTime = XFLogic:getMainBeginTime()
	local now = Localhost:timeInSec()
	local delta = mainBeginTime - now
	local hh, mm, ss = math.floor(delta / 3600), math.floor(delta % 3600 / 60), delta % 60

	local txt = string.format('开启倒计时 %02d:%02d:%02d', hh, mm, ss)

	UIHelper:setCenterText(
		self.ui:getChildByPath('bottom/timer'), 
		txt,
		'fnt/newzhousai_title.fnt',
		true,
		true
	)

	if delta <= 0 then
		self:onCloseBtnTapped()
		return
	end
end

function XFPreheatPanel:dispose( ... )
	if self.tickTaskMgr then
		self.tickTaskMgr:stop()
	end
	BasePanel.dispose(self, ...)
end

function XFPreheatPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function XFPreheatPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(self.ui:getChildByPath('title'), layoutUtils.MarginType.kTOP, 19)
	layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, -6)

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(self.ui:getChildByPath('bottom'), layoutUtils.MarginType.kBOTTOM, 10)

	self.tickTaskMgr:start()
end

function XFPreheatPanel:onCloseBtnTapped( ... )
    self:_close()
end

function XFPreheatPanel:onButtonTap( buttonName )
	if buttonName == 'descBtn' then
		require('zoo.panel.xfRank.XFDescPanel'):create():popout()
	end
end


return XFPreheatPanel
