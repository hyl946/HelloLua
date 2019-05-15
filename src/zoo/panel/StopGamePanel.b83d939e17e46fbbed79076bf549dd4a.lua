--------------------------------------------------------------------------------
--暂停/停止游戏
--------------------------------------------------------------------------------
require "hecore.display.Director"
require "hecore.ui.LayoutBuilder"
require "hecore.ui.Button"
require "hecore.display.Layer"

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
StopGamePanel = class(Layer)

function StopGamePanel:ctor()
	self.container = nil
end

function StopGamePanel:create( container )
	self.container = container
	local s = StopGamePanel.new()
	s:initLayer()
	return s
end

function StopGamePanel:palyEnterAction()
    local panelSize = self.panelUI:getGroupBounds().size
    self.panelUI:setPosition(ccp((visibleSize.width-panelSize.width)/2,panelSize.height))
    local moveToAction	= CCMoveTo:create(1, ccp((visibleSize.width-panelSize.width)/2,-(visibleSize.height-panelSize.height)/2))
    local action	= CCEaseElasticOut:create(moveToAction, 0.9)    
    self.panelUI:runAction(action)
end

function StopGamePanel:palyExitAction()
    local panelSize = self.panelUI:getGroupBounds().size
    local moveToAction	= CCMoveTo:create(1, ccp((visibleSize.width-panelSize.width)/2,panelSize.height))
    local action	= CCEaseElasticOut:create(moveToAction, 0.9)        
    local function onRemovePanel()
		PopoutManager:sharedInstance():remove(self.container.targetInfoPanel )
		self.container.targetInfoPanel = nil
    end
    local array = CCArray:create()
    array:addObject(action)
    array:addObject(CCCallFunc:create(onRemovePanel))
    self.panelUI:runAction(CCSequence:create(array))
end

function StopGamePanel:initLayer()

	StopGamePanel.super.initLayer(self)
    local builder = LayoutBuilder:createWithContentsOfFile("flash/scenes/game/GameUIScene.json")
    self.panelUI = builder:build("stopPanel")	
    
    self.panelUI:getChildByName("btn_item1"):getChildByName("text"):setString("退出")
    self.panelUI:getChildByName("btn_item2"):getChildByName("text"):setString("帮助")
    self.panelUI:getChildByName("btn_item3"):getChildByName("text"):setString("音效")
    self.panelUI:getChildByName("btn_item4"):getChildByName("text"):setString("重玩")

    local function onReloadGame( e )
        self.container:reloadGame()
        self:palyExitAction()
    end
    local function onReturnMainUI( e )
        self.container:returnMainUI()
    end
    
    local btnReloadGame = Button:create(self.panelUI:getChildByName("btn_item4"))
    local btnReturnMainUI = Button:create(self.panelUI:getChildByName("btn_item1"))
    btnReloadGame:addEventListener(Events.kStart,onReloadGame)
    btnReturnMainUI:addEventListener(Events.kStart,onReturnMainUI)
	--关闭
	local function onClosePanel(evt)    
        self:palyExitAction()
	end
	local bt_panel_close = Button:create(self.panelUI:getChildByName("btn_return"))
	bt_panel_close:addEventListener(Events.kStart, onClosePanel)
    self.panelUI:setPosition(ccp((visibleSize.width-self.panelUI:getGroupBounds().size.width)/2,-480))
	self:addChild(self.panelUI)
    
    self:palyEnterAction()
end