local BuyGoodsBtnLogic = require('zoo.payment.buyProp.BuyGoodsBtnLogic')

local UIHelper = require 'zoo.panel.UIHelper'

local vs = Director:sharedDirector():getVisibleSize()
local vo = Director:sharedDirector():getVisibleOrigin()

local BuyPropPanel = class(BasePanel)

function BuyPropPanel:create()
    local panel = BuyPropPanel.new()
    panel:init()
    return panel
end

function BuyPropPanel:dispose( ... )
	BasePanel.dispose(self, ...)
	FrameLoader:unloadArmature("skeleton/tutorial_animation", true)
end

function BuyPropPanel:init()

	FrameLoader:loadArmature( "skeleton/tutorial_animation" )

    local ui = UIHelper:createUI("ui/buy_prop.json", "buy_prop/panel")
	BasePanel.init(self, ui)

	self.vbox = self.ui:getChildByPath('vbox')

	self.tutorialPart = self.vbox:findChildByName('item5')
	self.goldLabel = self.vbox:findChildByName('item4')

	self.item3 = self.vbox:findChildByName('item3')
	self.item2 = self.vbox:findChildByName('item2')
	self.item1 = self.vbox:findChildByName('item1')

	self.buyBtnGroup = {self.item1:getChildByPath('buyBtn'), self.item2:getChildByPath('buyBtn'), self.item3:getChildByPath('buyBtn')}
	self.itemGroup = {self.item1, self.item2, self.item3}

	self.vbox:setItemVisible(5, false)
	self.vbox:setItemVisible(1, false)
	self.vbox:setItemVisible(2, false)
	self.vbox:setItemVisible(3, false)

	self.ui:getChildByPath('propIcon/desc'):setCDTime(0.2)

	self:refreshGoldLabel()

	self.showingTutorialPart = false
end

function BuyPropPanel:hideForBuying( ... )
	if self.isDisposed then return end
	self:setVisible(false)
end

function BuyPropPanel:refreshGoldLabel( ... )
	if self.isDisposed then return end
	self.goldLabel:getChildByPath('content/1'):setDimensions(CCSizeMake(0, 0))
	self.goldLabel:getChildByPath('content/3'):setDimensions(CCSizeMake(0, 0))

	self.goldLabel:getChildByPath('content/1'):setString('您拥有')
	self.goldLabel:getChildByPath('content/3'):setString(tostring(UserManager:getInstance().user:getCash()))

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.horizontalLayoutItems({
		{node = self.goldLabel:getChildByPath('content/1')},
		{node = self.goldLabel:getChildByPath('content/2')},
		{node = self.goldLabel:getChildByPath('content/3')},
	})

	if not self._init_refreshGoldLabel then
		self._init_refreshGoldLabel = true
		UIHelper:move(self.goldLabel:getChildByPath('content/1'), 0, -4)
		UIHelper:move(self.goldLabel:getChildByPath('content/3'), 0, -4)
	end
end

function BuyPropPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function BuyPropPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self:refreshLayout()
	self.allowBackKeyTap = true
end

function BuyPropPanel:onCloseBtnTapped( ... )
	if self.isDisposed then return end

	for _, v in ipairs(self.buyBtnContexts or {}) do
		v:onCloseBtnTapped()
	end


    self:payCancelCallback()
    self:_close()
end


function BuyPropPanel:playTutorial()
	if self.tutorial then
		self.curtain:setVisible(false)
		self.btnPlay:setVisible(false)
		self.tutorial:playAnimation()
	end
end

function BuyPropPanel:stopTutorial()
	if self.tutorial then
		self.tutorial:stopAnimation()
		self.curtain:setVisible(true)
		self.btnPlay:setVisible(true)
	end
end

function BuyPropPanel:initTutorialPart( ... )
	local extendedPanel = self.tutorialPart:getChildByPath('content')
	local curtain = extendedPanel:getChildByName("curtain")
	local btnPlay = extendedPanel:getChildByName("btnPlay")
	btnPlay:getChildByName('text'):setString(Localization:getInstance():getText("prop.info.panel.anim.play"))

	self.curtain = curtain
	self.btnPlay = btnPlay

	local tutorialAnimation = CommonSkeletonAnimation:creatTutorialAnimation(tostring(self.propId))
	if tutorialAnimation then 

		self.tutorial = tutorialAnimation

		tutorialAnimation:setAnchorPoint(ccp(0, 1))
		local animePlaceHolder = curtain

		local pos = animePlaceHolder:getPosition()
		tutorialAnimation:setPosition(ccp(pos.x, pos.y))
		local zOrder = animePlaceHolder:getZOrder()
		animePlaceHolder:getParent():addChildAt(tutorialAnimation, zOrder)
		--animePlaceHolder:removeFromParentAndCleanup(true)
		extendedPanel:getChildByName('animePlaceHolder'):removeFromParentAndCleanup(true)

		btnPlay:setTouchEnabled(true)
		btnPlay:setButtonMode(true)
		btnPlay:addEventListener(DisplayEvents.kTouchTap, function ()
			self:playTutorial()
		end)		
	end	
end

function BuyPropPanel:onButtonTap( buttonName )
	if self.isDisposed then return end
	lua_switch(buttonName){
		desc = function ( ... )
			if self.showingTutorialPart then
				self.showingTutorialPart = false
				self.vbox:setItemVisible(5, false)
				self:refreshLayout(true)

				self.vbox:setItemVisible(5, true)
				local tutorialContent = self.tutorialPart:getChildByPath('content')
				tutorialContent:runAction(UIHelper:sequence{
					CCScaleTo:create(8/30, 1, 0),
					CCCallFunc:create(function ( ... )
						if self.isDisposed then return end
						self.vbox:setItemVisible(5, false)
						tutorialContent:setScale(1)
					end)	
				})
			else
				self.showingTutorialPart = true
				self.vbox:setItemVisible(5, true)
				-- self.tutorialPart:getChildByPath('content'):setVisible(false)
				local tutorialContent = self.tutorialPart:getChildByPath('content')
				local pos = tutorialContent:getPosition()
				pos = ccp(pos.x, pos.y)
				self:refreshLayout(true, function ( ... )
					if self.isDisposed then return end
					
				end)

				tutorialContent:setScaleY(0)
				tutorialContent:runAction(UIHelper:sequence{
					CCScaleTo:create(8/30, 1, 1),
					CCCallFunc:create(function ( ... )
						if self.isDisposed then return end
					end)	
				})
			end

			self:stopTutorial()
		end,
	}
end

function BuyPropPanel:refreshLayout( playAnim, callback )
	if self.isDisposed then return end

	if not self._inited then
		self._inited = true
		self.oriBGHeight = self.ui:getChildByPath('bg'):getPreferredSize().height
		self.oriHitAreaHeight = self.ui:getChildByPath('hit_area'):getScaleY() * self.ui:getChildByPath('hit_area'):getContentSize().height
		self.oriBottomPosY = self.ui:getChildByPath('bottom'):getPositionY()
	end

	local vBoxHeight = self.vbox.layout:getHeight()


	self.lastBGHeight = self.ui:getChildByPath('bg'):getPreferredSize().height
	self.ui:getChildByPath('bg'):setPreferredHeight(self.oriBGHeight + vBoxHeight)

	self.lastHitAreaHeight = self.ui:getChildByPath('hit_area'):getScaleY() * self.ui:getChildByPath('hit_area'):getContentSize().height
	self.ui:getChildByPath('hit_area'):setScaleY((self.oriHitAreaHeight + vBoxHeight) / (self.ui:getChildByPath('hit_area'):getContentSize().height))

	self.lastBottomPosY = self.ui:getChildByPath('bottom'):getPositionY()
	self.ui:getChildByPath('bottom'):setPositionY(self.oriBottomPosY - vBoxHeight)

	self:setScale(1)
	local scale = vs.width / self:getGroupBounds().size.width
	self:setScale(scale)
	self:setPositionX(0)

	self.lastPanelPosY = self:getPositionY()
	local panelHeight = self:getGroupBounds().size.height
	self:setPositionY(- (vs.height - panelHeight)/2)

	if playAnim then

		if self.animPlayer then
			self.animPlayer:stop()
			self.animPlayer:removeFromParentAndCleanup(true)
			self.animPlayer = nil
		end

		if not self.animPlayer then

			local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
			local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
			local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'

			self.animPlayer = AnimationPlayer:create()
			self.animPlayer:setTarget(self.ui)
			self:addChild(self.animPlayer)

			local endIndex = 8

			local pt1 = PropertyTrack.new()
			pt1:setName('BGHeight')
			pt1:setPropertyAccessor(nil, function ( context, v )
				context:setPreferredHeight(v)
			end)
			pt1:setTargetPath('./bg')
			pt1:setFrameDataConfig({
				{index = 0, data = self.lastBGHeight},
				{index = endIndex, data = self.ui:getChildByPath('bg'):getPreferredSize().height},
			})
			self.animPlayer:addTrack(pt1)

			local pt2 = PropertyTrack.new()
			pt2:setName('HitAreaHeight')
			pt2:setPropertyAccessor(nil, function ( context, v )
				context:setScaleY(v)
			end)
			pt2:setTargetPath('./hit_area')
			pt2:setFrameDataConfig({
				{index = 0, data = self.lastHitAreaHeight / self.ui:getChildByPath('hit_area'):getContentSize().height},
				{index = endIndex, data = self.ui:getChildByPath('hit_area'):getScaleY()},
			})
			self.animPlayer:addTrack(pt2)

			local pt3 = PropertyTrack.new()
			pt3:setName('BottomPosY')
			pt3:setPropertyAccessor(nil, function ( context, v )
				context:setPositionY(v)
			end)
			pt3:setTargetPath('./bottom')
			pt3:setFrameDataConfig({
				{index = 0, data = self.lastBottomPosY},
				{index = endIndex, data = self.ui:getChildByPath('bottom'):getPositionY()},
			})
			self.animPlayer:addTrack(pt3)

			local pt4 = PropertyTrack.new()
			pt4:setName('PanelPosY')
			pt4:setPropertyAccessor(nil, function ( context, v )
				context:setPositionY(v)
			end)
			pt4:setTargetPath('./..')
			pt4:setFrameDataConfig({
				{index = 0, data = self.lastPanelPosY},
				{index = endIndex, data = self:getPositionY()},
			})
			self.animPlayer:addTrack(pt4)

			local pt5 = FuncTrack.new()
			pt5:setName('FuncTrack')
			pt5:setTargetPath('.')
			pt5:setFrameDataConfig({
				{index = endIndex + 1, data = function ( ... )
					self:runAction(CCCallFunc:create(function ( ... )
						self.animPlayer:removeFromParentAndCleanup(true)
						self.animPlayer = nil
						if callback then callback() end
					end))
				end},
			})
			self.animPlayer:addTrack(pt5)

			self.animPlayer:start()
			self.animPlayer:update(0)
		end
	end
end

function BuyPropPanel:setPropId( propId )
	if self.isDisposed then return end
	self.propId = propId
	self.goodsIdList = require('zoo.payment.buyProp.PropIdMapGoodsId'):getGoodsIdList(self.propId, self:isMultiPropsEnabled())

	local propNameKey = "prop.name."..tostring(propId)
	local title = string.format('购买 ' .. localize(propNameKey))
	self.ui:getChildByPath('title'):setString(title)
	self.ui:getChildByPath('descLabel'):setString(localize('level.prop.tip.' .. self.propId))

	self:setPropIcon(self.ui:getChildByPath('propIcon/holder'), self.propId)

	self:initTutorialPart()

	self.buyBtnContexts = {}


	for index = 1, 3 do
		local goodsId = self.goodsIdList[index]
		local btns = self.buyBtnGroup[index]

		if goodsId then
			self:initBuyItem(index, goodsId, btns)
			self.vbox:setItemVisible(index, true)
		else
			self.vbox:setItemVisible(index, false)
		end

	end
end

function BuyPropPanel:getBuyBtnContextByGoodsId( goodsId )
	if self.isDisposed then return end
	local context = table.find(self.buyBtnContexts or {}, function ( v )
		return v.goodsId == goodsId
	end)
	return context
end

local function handler( obj, method )
	return function ( ... )
		method(obj, ...)
	end
end


function BuyPropPanel:getPanelParent( ... )
	if self.isDisposed then return end
	return self:getParent()
end

function BuyPropPanel:initBuyItem( index, goodsId, btns )
	if self.isDisposed then return end
	if index == 1 then
		if (__IOS) 
			or 
			( 
				MaintenanceManager:getInstance():isEnabledInGroup("LevelPropsBuyTypeCoin" , "ON" , UserManager:getInstance().user.uid or '12345')
			) then

			self.buyBtnContexts[index] = BuyGoodsBtnLogic:init(btns, goodsId, BuyGoodsBtnLogic.Mode.kBuyWithGold, 
				handler(self, self.paySuccessCallback), 
				handler(self, self.payFailCallback), 
				handler(self, self.payCancelCallback), 
				handler(self, self.updateGoldCallback)
			)
		else
			self.buyBtnContexts[index] = BuyGoodsBtnLogic:init(btns, goodsId, BuyGoodsBtnLogic.Mode.kBuyWithGoldIfEnoughOtherwiseRMB, 
				handler(self, self.paySuccessCallback), 
				handler(self, self.payFailCallback), 
				handler(self, self.payCancelCallback), 
				handler(self, self.updateGoldCallback)
			)
		end
	else
		self.buyBtnContexts[index] = BuyGoodsBtnLogic:init(btns, goodsId, BuyGoodsBtnLogic.Mode.kBuyWithGold, 
			handler(self, self.paySuccessCallback), 
			handler(self, self.payFailCallback), 
			handler(self, self.payCancelCallback), 
			handler(self, self.updateGoldCallback)
		)
	end
	self:setPropIcon(self.itemGroup[index]:getChildByPath('prop/holder'), self.propId)
	local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId) or {}
	local goodsItems = goodsMeta.items or {}
	local num = (goodsItems[1] or {}).num or 1
	UIHelper:setCenterText(self.itemGroup[index]:getChildByPath('prop/num'), 'x' .. tostring(num), 'fnt/bzds2.fnt')
	self.itemGroup[index]:getChildByPath('prop/num'):setScale(1)
	self.itemGroup[index]:getChildByPath('prop/bubble'):setVisible(false)
	self.itemGroup[index]:getChildByPath('flag'):setVisible(index > 1)
end


function BuyPropPanel:paySuccessCallback( goodsId )
	if self.isDisposed then return end
	if self.successCallback then
		local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)
		local isVisible = self:isVisible()
		self:setVisible(true)
		local propIcon = self.ui:getChildByPath('propIcon/holder')
		local bounds = propIcon:getGroupBounds()
		local iconWorldPos = ccp(bounds:getMidX(), bounds:getMidY())
		self:setVisible(isVisible)
		self.successCallback(self.propId, goodsMeta.items[1].num, iconWorldPos)
	end
	self:_close()
end

function BuyPropPanel:setCallback( successCallback, failCallback, cancelCallback )
	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
end

function BuyPropPanel:payFailCallback( errCode, errMsg )
	if self.isDisposed then return end
	-- CommonTip:showTip(string.format('支付失败(%s, %s)', errCode, errMsg))
	if self.failCallback then
		self.failCallback(errCode, errMsg)
	end

	self:_close()
end

function BuyPropPanel:payCancelCallback( ... )
	if self.isDisposed then return end
	if self.cancelCallback then
		self.cancelCallback()
	end

	self:_close()
end

function BuyPropPanel:updateGoldCallback( ... )
	if self.isDisposed then return end
	self:refreshGoldLabel()
end

function BuyPropPanel:setPropIcon( holder, propId )
	if self.isDisposed then return end
	local sp = ResourceManager:sharedInstance():buildItemSprite(self.propId)
	UIUtils:positionNode(holder, sp, true)
end

local developerIds = {
	'53260',
	'51031',
}


function BuyPropPanel:isMultiPropsEnabled( ... )
	local uid = UserManager:getInstance():getUID() or "12345"
	return MaintenanceManager:getInstance():isEnabledInGroup("BuyMultiProps", 'ON', uid) or __WIN32 or table.includes(developerIds, tostring(uid))
end

function BuyPropPanel:setActiveIngamePayLogic( ingamePayLogic )
	self.ingamePayLogic = ingamePayLogic
end

function BuyPropPanel:getActiveIngamePayLogic( ... )
	return self.ingamePayLogic
end

return BuyPropPanel
