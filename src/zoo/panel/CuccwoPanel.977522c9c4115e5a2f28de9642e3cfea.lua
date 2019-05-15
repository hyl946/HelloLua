require "hecore.display.TextField"
require "hecore.display.ArmatureNode"
require "hecore.ui.PopoutManager"
require "hecore.ui.ProgressBar"
require "hecore.debug.AdvancedLogger"

require "zoo.config.ResourceConfig"
require "zoo.ui.InterfaceBuilder"
require "zoo.ui.ButtonBuilder"
require "zoo.ResourceManager"
require "zoo.ui.InterfaceBuilder"

local Button = require "zoo.panel.phone.Button"

local CuccwoPanel = class(BasePanel)

function CuccwoPanel:ctor( ... )
	-- body
end

function CuccwoPanel:create(cb)
    local panel = CuccwoPanel.new()
    panel:loadRequiredResource("ui/cuccwo_panel.json")
    panel:init(cb)
    return panel
end

function CuccwoPanel:init(cb)
	self.ui = self:buildInterfaceGroup("cuccwo_c/panel")
    BasePanel.init(self, self.ui)

    local txts = {
    	"抵制不良游戏  拒绝盗版游戏  注意自我保护  谨防受骗上当",
    	"适度游戏益脑  沉迷游戏伤身  合理安排时间  享受健康生活",
    	"批准文号：新广出审[2014]1407号   出版物号：ISBN 978-7-900801-88-3",
    	"游戏著作权人：乐元素科技（北京）股份有限公司    出版服务单位：华东理工大学电子音像出版社",
	}

	for i=1,4 do
		self.ui:getChildByName("t"..i):setString(txts[i])
	end

    local button = Button:create(self.ui:getChildByName("btn"))
	button:setText("确 定")
	button:setTouchEnabled(true)
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:onCloseBtnTapped()
		if cb then cb() end
	end)
end

function CuccwoPanel:onCloseBtnTapped()
	self.refCocosObj:removeFromParentAndCleanup(true)
	self:dispose()
end

function CuccwoPanel:popout()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(self.refCocosObj)

    local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	local w = size.width
	local h	= size.height

	local x = (visibleSize.width - w)/2 + visibleOrigin.x
	local y = (visibleSize.height + h)/2 + visibleOrigin.y

	self:setPosition(ccp(x, y))
end

return CuccwoPanel