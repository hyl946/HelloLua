
require "zoo.panel.basePanel.BasePanel"

CoinInfoPanel = class(BasePanel)

function CoinInfoPanel:create()
	local panel = CoinInfoPanel.new()
	panel:init()
	return panel
end

function CoinInfoPanel:init()
	self:loadRequiredResource(PanelConfigFiles.coin_info_panel)
	local ui = self:buildInterfaceGroup("CoinInfoPanel")
	BasePanel.init(self, ui)

	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local keys = {
		"silvercoin_get_desc1",
		"silvercoin_get_desc2",
		"silvercoin_get_desc3",
		"silvercoin_use_desc1",
		"silvercoin_use_desc2",
	}
	for i = 1, 5 do
		local text = ui:getChildByName("text"..tostring(i))
		text:setString(Localization:getInstance():getText(keys[i]))
	end

	local tree = ui:getChildByName("node2")
	tree:setTouchEnabled(true)
	tree:setButtonMode(true)
	tree:addEventListener(DisplayEvents.kTouchTap, function()
		if PlatformConfig:isPlayDemo() then
			CommonTip:showTip(Localization:getInstance():getText("当前版本不支持该功能~"))
			return
		end
		DcUtil:UserTrack({category = "ui", sub_category = "click_silvercoin_intro_tree"})
		local function success()
			HomeScene:sharedInstance():runAction(CCCallFunc:create(function()
				local scene = FruitTreeScene:create()
				Director:sharedDirector():pushScene(scene)
			end))
		end
		local function fail(err, skipTip)
			if not skipTip then CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err))) end
		end
		local function updateInfo()
			FruitTreeSceneLogic:sharedInstance():updateInfo(success, fail)
		end
		local function onLoginFail()
			fail(-2, true)
		end
		local user = UserManager:getInstance():getUserRef()
		if user:getTopLevelId() >= 16 then
			RequireNetworkAlert:callFuncWithLogged(updateInfo, onLoginFail)
			self:onCloseBtnTapped()
		else
			CommonTip:showTip(Localization:getInstance():getText("silvercoin_level_tips", {replace=16}))
		end
	end)

	local coin = ui:getChildByName("node3")
	coin:setTouchEnabled(true)
	coin:setButtonMode(true)
	coin:addEventListener(DisplayEvents.kTouchTap, function()
		DcUtil:UserTrack({category = "ui", sub_category = "click_silvercoin_intro_shop"})
		local id = MarketManager:sharedInstance():getBuyCoinPageIndex()
		local panel =  createMarketPanel(id)
		if panel then panel:popout() end
		self:onCloseBtnTapped()
	end)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local layer = LayerColor:create()
	-- layer:setOpacity(215)
	layer:setOpacity(150)
	layer:setAnchorPoint(ccp(0, 1))
	layer:ignoreAnchorPointForPosition(false)
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():ori_getVisibleOrigin()
	layer:setContentSize(CCSizeMake(wSize.width / self:getScale(), wSize.height / self:getScale()))
	layer:setPositionXY(-self:getPositionX() / self:getScale(), (-self:getPositionY() + vOrigin.y) / self:getScale())
	ui:addChildAt(layer, 0)

	-- close:setPositionX(-self:getPositionX() / self:getScale() + vSize.width / self:getScale() - 60)
	-- close:setPositionY(-self:getPositionY() / self:getScale() - 60 - _G.__EDGE_INSETS.top)
	self.ui:setPositionY(self.ui:getPositionY() + _G.__EDGE_INSETS.top)
end

function CoinInfoPanel:popout()
	PopoutQueue:sharedInstance():push(self, false, false)
end

function CoinInfoPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function CoinInfoPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end