
local UIHelper = require 'zoo.panel.UIHelper'

require 'zoo.panel.store.StoreConfig'
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'

local StorePanel = class(BasePanel)

function StorePanel:create()


    local panel = StorePanel.new()
    panel:init()
    return panel
end

function StorePanel:init()
    local ui = UIHelper:createUI("ui/store.json", "com.niu2x.store/store-panel")
	BasePanel.init(self, ui)
	UIUtils:adjustUI(ui, 0, nil, nil, 1764)

	self.panelName = 'StorePanel'

	self.goldLabel = self.ui:getChildByPath('fg/goldLabel')
	self:refreshGoldLabel()

	self.readyWait = 0

	self.enterFlags = {}

	self:ad(PopoutEvents.kBecomeSecondPanel, function ( ... )
		if self.isDisposed then return end
		self:disableAllItems()
	end)


	self:ad(PopoutEvents.kReBecomeTopPanel, function ( ... )
		if self.isDisposed then return end
		self:enableAllItems()
	end)

	self.networkError = self.ui:getChildByPath('network-error')
	self.networkError:setVisible(false)
end

function StorePanel:disableAllItems( ... )
	if self.isDisposed then return end

	for _, v in ipairs(self.bodyLayout:getItems()) do
		local itemView = v:getContent():findChildByName('store-item')
		if itemView.setEnabled then
			itemView:setEnabled(false)
		end
	end
end

function StorePanel:enableAllItems( ... )
	if self.isDisposed then return end

	for _, v in ipairs(self.bodyLayout:getItems()) do
		local itemView = v:getContent():findChildByName('store-item')
		if itemView.setEnabled then
			itemView:setEnabled(true)
		end
	end
end


function StorePanel:hadEnterFlag( flag )
	return table.includes(self.enterFlags, flag)
end

function StorePanel:createBodyView( ... )
	if self.isDisposed then return end

	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	local bodyBottom = vo.y
	local bodyTop = vo.y + vs.height

	local contentHeight = UIHelper:convert2NodeSpace(self.ui, bodyTop - bodyBottom)
	local contentWidth = 960

	local bodyLayout = VerticalTileLayout:create(contentWidth)
	local bodyContainer = VerticalScrollable:create(contentWidth, contentHeight, true, true)
	bodyContainer:setContent(bodyLayout)
	self.bodyContainer = bodyContainer
	self.bodyLayout = bodyLayout

	local fgIndex = self.ui:getChildIndex(self.ui:getChildByPath('fg'))

	self.ui:addChildAt(self.bodyContainer, fgIndex)
	layoutUtils.setNodeRelativePos(self.bodyContainer, layoutUtils.MarginType.kBOTTOM, 0)


	RealNameManager:addConsumptionLabelToVerticalPage(bodyContainer, ccp(0, 0))


	local nullContent = Layer:create()
	nullContent:changeWidthAndHeight(960, 70)
	self:addItemView(nullContent, -1)

	--商店里显示的购买项  需要异步加载
	self.config = {}


	if (__IOS or __WIN32) and MaintenanceManager:getInstance():isInReview() then

		self:addConfig(
			StoreConfig.SGType.kGift,
			require 'zoo.panel.store.modules.AppReviewLogic',
			require 'zoo.panel.store.views.GiftView'
		)
		
	else
		self:addConfig(
			StoreConfig.SGType.kStarBank,
			require 'zoo.panel.store.modules.StarBankLogic',
			require 'zoo.panel.store.views.StarBankView'
		)


		self:addConfig(StoreConfig.SGType.kPromotion,
			require 'zoo.panel.store.modules.PromotionLogic',
			require 'zoo.panel.store.views.PromitionView',
			self.source
		)

		if self:hadEnterFlag(_G.StoreManager.EnterFlag.kEndGamePanelDiscount5Step) then
			self:addConfig(
				StoreConfig.SGType.kGold, 
				require 'zoo.panel.store.modules.HiddenItemLogic', 
				require 'zoo.panel.store.views.GoldView',
				_G.StoreManager.EnterFlag.kEndGamePanelDiscount5Step
			)
		end

		if self:hadEnterFlag(_G.StoreManager.EnterFlag.kEndGamePanel2Step) then
			self:addConfig(
				StoreConfig.SGType.kGold, 
				require 'zoo.panel.store.modules.HiddenItemLogic', 
				require 'zoo.panel.store.views.GoldView',
				_G.StoreManager.EnterFlag.kEndGamePanel2Step
			)
		end
	

		self:addConfig(StoreConfig.SGType.kServerConfig,
			require('zoo.panel.store.modules.ServerConfigGiftManager'):getInstance(),
			require 'zoo.panel.store.views.ServerConfigGiftView',
			self.source
		)
	end

	self:addConfig(
		StoreConfig.SGType.kGift, 
		require 'zoo.panel.store.modules.GiftLogic', 
		require 'zoo.panel.store.views.GiftView'
	)

	self:addConfig(
		StoreConfig.SGType.kGold, 
		require 'zoo.panel.store.modules.GoldLogic', 
		require 'zoo.panel.store.views.GoldView'
	)

	self:preLoad(function ( ... )
		if self.isDisposed then return end
		self:load()
	end, function ( ... )
		if self.isDisposed then return end
		self:afterPreLoadError()
	end)
end


function StorePanel:preLoad(onSuccess, onFail)
	-- body
	if __IOS or __WIN32 then
		_G.StoreManager:getInstance():loadIosProductInfo(onSuccess, onFail)
	else
		if onSuccess then onSuccess() end
	end
end

function StorePanel:load()

	local function needWait( c )
		-- return table.includes({_G.StoreConfig.SGType.kGift, _G.StoreConfig.SGType.kGold}, c.type)
		return true
	end

	local configsNeededWait = table.filter(self.config, needWait)

	local counter = #(configsNeededWait)

	local function callback( config )
		if needWait(config) then
			counter = counter - 1
			
		end

		if counter <= 0 then
			self.readyWait = self.readyWait + 1
			self:playItemAppearAnim()
		end
	end

	for index, v in ipairs(self.config) do
		v.mod:loadData(function ( itemDataList )
			if self.isDisposed then return end

			v.itemDataList = itemDataList


			for _, itemData in ipairs(itemDataList) do
				local itemView = v.ViewClass:create(itemData)
				itemView._type = v.type
				self:addItemView(itemView, v.priority)
			end

			self:afterModReady(index)

			callback(v)

		end, function ( ... )
			CommonTip:showTip('error load mod ' .. index)

			callback(v)

		end, v.modParam)
	end
end

function StorePanel:afterModReady( index )
	if self.isDisposed then return end

end

function StorePanel:addItemView( itemView, priority )
	if self.isDisposed then return end

	itemView:ad('AfterBuySuccess', function ( evt )
		self:afterBuySuccess(evt)
	end)

	itemView.name = 'store-item'

	local itemViewWrapper = Layer:create()
	itemViewWrapper:addChild(itemView)
	local bounds = itemView:getGroupBounds()
	itemView:setPositionX(-bounds.size.width/2)
	itemView:setPositionY(bounds.size.height/2)

	itemViewWrapper:setPositionY(-bounds.size.height/2)

	local layoutItem = ItemInClippingNode:create()
	layoutItem:setContent(itemViewWrapper)
	layoutItem:setParentView(self.bodyContainer)

	itemViewWrapper._priority = priority

	local index = #(self.bodyLayout:getItems()) + 1
	for i, v in ipairs(self.bodyLayout:getItems()) do
		if v:getContent()._priority > itemViewWrapper._priority then
			index = i
			break
		end
	end

	itemViewWrapper:setPositionX((960)/2)
	self.bodyLayout:addItemAt(layoutItem, index, true)
	itemViewWrapper:setVisible(false)
	self.bodyContainer:updateScrollableHeight()

end

function StorePanel:afterBuySuccess( evt )
	if self.isDisposed then return end




	local goodsIdInfo = evt.data
	local itemView = evt.target	

	if itemView._type == StoreConfig.SGType.kStarBank then


		if self._buyGoldSuccessFunc then
			self._buyGoldSuccessFunc()
		end
		self._buyGoldSuccessFunc = nil

		self:refreshGoldLabel()

		return
	end

	local cash = 0
	local otherItems = {}

	if goodsIdInfo:getGoodsType() == GoodsType.kCurrency then
		if __ANDROID then
			cash = MetaManager:getInstance():getProductAndroidMeta(goodsIdInfo:getGoodsId()).cash
		else
			cash = MetaManager:getInstance():getProductMetaByID(goodsIdInfo:getGoodsId()).cash
		end
	elseif goodsIdInfo:getGoodsType() == GoodsType.kItem then
		local items = MetaManager:getInstance():getGoodMeta(goodsIdInfo:getGoodsId()).items or {}
		otherItems = table.filter(items, function ( v )
			return v.itemId ~= ItemType.GOLD
		end)
		local goldItem = table.find(items, function ( v )
			return v.itemId == ItemType.GOLD
		end)
		if goldItem then
			cash = goldItem.num
		end
	end

	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	local center = ccp(vo.x + vs.width/2, vo.y + vs.height/2)
	if itemView then
		local itemViewBounds = itemView:getGroupBounds()
		center = ccp(itemViewBounds:getMidX(), itemViewBounds:getMidY())
	end


	local onlyInfiniteBottle = table.filter(otherItems, function ( tRewardItem )
		return tRewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	end)

	local tInfiniteRewardItem = onlyInfiniteBottle[1] 


	if cash > 0 then
		local goldLabelBounds = self.goldLabel:getGroupBounds()
		local targetPos = ccp(goldLabelBounds:getMidX(), goldLabelBounds:getMidY())
		local anim = FlyGoldToAnimation:create(cash, targetPos)
		anim:setWorldPosition(center)
		anim:setFinishCallback(function( ... )
			if self.isDisposed then return end

			local scene = Director.sharedDirector():getRunningScene()
			if scene then
				local animLabel = BitmapText:create('+' .. tostring(cash), 'fnt/star_entrance.fnt')
				animLabel:setAnchorPoint(ccp(0.5,0.5))
				animLabel:setPositionXY(targetPos.x + 30, targetPos.y)
				animLabel:setColor(hex2ccc3('FFFFFF'))
				scene:addChild(animLabel, SceneLayerShowKey.TOP_LAYER)
				local actions = CCArray:create()
				actions:addObject(CCMoveBy:create(0.8,ccp(0,42)))
				actions:addObject(CCCallFunc:create(function( ... )
					if animLabel and (not animLabel.isDisposed) then 
						animLabel:removeFromParentAndCleanup(true)
					end
				end))
				animLabel:runAction(CCSequence:create(actions))
				actions = CCArray:create()
				actions:addObject(CCDelayTime:create(0.4))
				actions:addObject(CCFadeOut:create(0.4))
				animLabel:runAction(CCSequence:create(actions))
				animLabel:setScale(0.8)

				self:refreshGoldLabel()

				if tInfiniteRewardItem then
					local anim1 = FlyItemsAnimation:create({{itemId = ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE, num = 1}} )
		        	anim1:setWorldPosition(center)
		        	anim1:play()
		        end

			end
		end)
		anim:play()

		GamePlayMusicPlayer:playEffect(GameMusicType.kGoldFly)

	end

	-- if cash > 0 then
	-- 	table.insert(otherItems, {itemId = ItemType.GOLD, num = cash})
	-- end

	
	if tInfiniteRewardItem then
		local logic = UseEnergyBottleLogic:create(tInfiniteRewardItem.itemId, DcFeatureType.kNewStore, DcSourceType.kNewStore)
		logic:setUsedNum(tInfiniteRewardItem.num)
		logic:setSuccessCallback(function ( ... )
			HomeScene:sharedInstance():checkDataChange()
			HomeScene:sharedInstance().energyButton:updateView()
		end)
		logic:setFailCallback(function ( evt )
		end)
		logic:start(true)
	end

	if #otherItems > 0 then

		local items, duration, delayTime = self:cloneRewardItems(otherItems, true)

		local anim = FlyItemsAnimation:create(table.filter(items, function ( v )
			return v.itemId ~= ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
		end))

        anim:setWorldPosition(center)
        anim:setFinishCallback(function ( ... )

        end)
        anim:play()
	end

	if cash > 0 then
		if self._buyGoldSuccessFunc then
			self._buyGoldSuccessFunc()
		end
		self._buyGoldSuccessFunc = nil
	end

	Localhost:getInstance():flushCurrentUserData()
	HomeScene:sharedInstance():checkDataChange()
	local scene = HomeScene:sharedInstance()
	if scene.coinButton then scene.coinButton:updateView() end
	if scene.goldButton then scene.goldButton:updateView() end
	scene:checkDataChange()
end

function StorePanel:cloneRewardItems( rewardItems )
	local ret = {}

	local totalPropNum = 0

	for _, v in ipairs(rewardItems) do
		table.insert(ret, {itemId = v.itemId, num = v.num})
		if v.itemId ~= ItemType.GOLD and v.itemId ~= ItemType.COIN and v.itemId ~= ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
			totalPropNum = v.num + totalPropNum
		end
	end

	if totalPropNum > 15 then
		ret = {}
		for _, v in ipairs(rewardItems) do
			if v.itemId ~= ItemType.GOLD and v.itemId ~= ItemType.COIN and v.itemId ~= ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
				table.insert(ret, {
					itemId = v.itemId, 
					num = math.min(
						3, 
						math.max(
							1, 
							math.ceil(
								v.num * 15 / totalPropNum
							)
						)
					)})
			else
				table.insert(ret, {itemId = v.itemId, num = v.num})
			end
		end
	end

	return ret
end

function StorePanel:afterPreLoadError( ... )
	if self.isDisposed then return end
	self.networkError:setVisible(true)

	local vo = Director:sharedDirector():getVisibleOrigin()
	local vs = Director:sharedDirector():getVisibleSize()
	local screenCenter = ccp(vo.x + vs.width/2, vo.y + vs.height/2)

	layoutUtils.setNodeCenterPos(self.networkError, screenCenter)
end

function StorePanel:addConfig( type, mod, ViewClass, modParam )
	local priority = #(self.config)
	table.insert(self.config, {
		type = type,
		mod = mod,
		ViewClass = ViewClass,
		priority = priority,
		modParam = modParam,
	})
end

function StorePanel:refreshGoldLabel( ... )
	if self.isDisposed then return end
	UIHelper:setCenterText(
		self.goldLabel, 
		tostring(UserManager:getInstance().user:getCash()),
		'fnt/hud.fnt'
	)
	self:dispatchEvent(Event.new(kPanelEvents.kUpdate, nil, self))
end


function StorePanel:_close()
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function StorePanel:popout()
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)

	self:popoutShowTransition()
	self.allowBackKeyTap = true

	local state = StarBank.state or -1
	-- gold button
	if self.source == 2 then 
		DcUtil:UserTrack({category = 'new_store', sub_category = 'entry_way', type = 2, star_bank_state = state})
	elseif self.source == 3 then
		DcUtil:UserTrack({category = 'new_store', sub_category = 'entry_way', type = 1, star_bank_state = state})
	else
		DcUtil:UserTrack({category = 'new_store', sub_category = 'entry_way', type = 3, star_bank_state = state})
	end
	
end

function StorePanel:onCloseBtnTapped( ... )
    self:_close()
end

function StorePanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	self:createBodyView()
	self:playApperaAnimation()
end

function StorePanel:playApperaAnimation( ... )
	if self.isDisposed then return end
	local FPS = 30
	local topBG = self.ui:getChildByPath('fg/bg')
	UIHelper:move(topBG, 0, 200)
	topBG:runAction(CCEaseBackOut:create(CCMoveBy:create(8/FPS, ccp(0, -200))))

	self.readyWait = self.readyWait + 1
	self:playItemAppearAnim()
end

function StorePanel:playItemAppearAnim( ... )
	if self.isDisposed then return end

	if self.readyWait < 2 then return end

	local items = self.bodyLayout:getItems()

	for index, _itemView in ipairs(items) do
		local itemView = _itemView
		if not itemView:getContent()._animed then
			itemView:getContent()._animed = true
			itemView:getContent():runAction(UIHelper:sequence{
				CCDelayTime:create(5/30 + index * 0.06),
				CCCallFunc:create(function ( ... )
					if self.isDisposed then return end
					if itemView.isDisposed then return end
					itemView:getContent():setVisible(true)
					itemView:getContent():setScale(0.4)
				end),
				CCEaseBackOut:create(CCScaleTo:create(10/30, 1, 1))
			})
		end
	end

end


function StorePanel:setBuyGoldSuccessFunc( callback )
	self._buyGoldSuccessFunc = callback
end

function StorePanel:addEnterFlag( flag )
	table.insert(self.enterFlags, flag)
end

function StorePanel:removeStoreItem( itemView )
	if self.isDisposed then return end
	for i, v in ipairs(self.bodyLayout:getItems()) do
		if v:findChildByName('store-item') == itemView then
			self.bodyLayout:removeItemAt(i, true)
			self.bodyContainer:updateScrollableHeight()
			return
		end
	end
end


--just for dc
function StorePanel:setSource( source )
	self.source = source
end

-- implement interface that marketpanel has. do nothing
function StorePanel:setGoldFreeVisible( ... )
end


return StorePanel
