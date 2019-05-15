require "zoo.panel.basePanel.BasePanel"
require "zoo.data.dataDesc.GoodsDesc"

local countToPushNotification = 3
local levelBlackList = {
	
}

PrePropRemindPanel = class(BasePanel)

-- finishCallback() called while panel closed (no matter use prop or not)
-- useCallback(itemId) called while use btn tapped
function PrePropRemindPanel:create(levelId, finishCallback, useCallback)
	local panel = PrePropRemindPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_preprop_remind)
	if panel:_init(levelId, finishCallback, useCallback) then return panel
	else panel = nil return nil end
end

function PrePropRemindPanel:dispose()
	-- release anim
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/tutorial_animation/texture.png"))

	-- base dispose
	BasePanel.dispose(self)
end

function PrePropRemindPanel:_init(levelId, finishCallback, useCallback)
	-- preload anim
	FrameLoader:loadArmature( "skeleton/tutorial_animation" )

	-- data
	self.useCallback = useCallback
	self.finishCallback = finishCallback
	self.goodsDesc = GoodsDesc:create(PrePropRemindPanelModel:getRemindItemId(levelId))
	if not self.goodsDesc then return false end
	self.prePropRemindPanelLogic = PrePropRemindPanelLogic.new()

	-- init panel
	self.panel = self:buildInterfaceGroup("PrePropRemindPanel")
	BasePanel.init(self, self.panel)
	self:setPositionForPopoutManager()

	-- get & create controls
	self.bubbleItem = self.panel:getChildByName("bubbleItem")
	self.greenBtn = self.panel:getChildByName("greenBtn")
	self.blueBtn = self.panel:getChildByName("blueBtn")
	self.item = self.panel:getChildByName("item")
	self.anim = self.panel:getChildByName("anim")
	self.priceLabel = self.panel:getChildByName("priceLabel")
	self.descLabel = self.panel:getChildByName("descLabel")
	self.greenBtn = GroupButtonBase:create(self.greenBtn)
	self.blueBtn = GroupButtonBase:create(self.blueBtn)
	self.animation = CommonSkeletonAnimation:creatTutorialAnimation(self.goodsDesc.items[1].itemId)

	-- set state
	if self.goodsDesc.icon then
		local pos = self.item:getPosition()
		self.goodsDesc.icon:setAnchorPoint(ccp(0.5, 0.5))
		self.goodsDesc.icon:setPosition(ccp(pos.x, pos.y))
		self.bubbleItem = self.panel:addChild(self.goodsDesc.icon)
	end
	self.item:setVisible(false)
	self.blueBtn:setColorMode(kGroupButtonColorMode.blue)
	self.animation:setAnchorPoint(ccp(0, 1))
	local pos = self.anim:getPosition()
	local zOrder = self.anim:getZOrder()
	self.animation:setPosition(ccp(pos.x, pos.y))
	self.panel:addChildAt(self.animation, zOrder)
	self.anim:removeFromParentAndCleanup(true)
	local function delayAnimation()
		if self.isDisposed then return end
		self.animation:playAnimation()
	end
	setTimeOut(delayAnimation, 0.2)

	-- set text
	self.greenBtn:setString(Localization:getInstance():getText("preprop.remind.panel.usebtn"))
	self.blueBtn:setString(Localization:getInstance():getText("preprop.remind.panel.cancelbtn"))
	if self.goodsDesc.coin then self.priceLabel:setString(tostring(self.goodsDesc.coin)) end
	self.descLabel:setString(Localization:getInstance():getText("preprop.remind.panel.desc"))

	-- add event listener
	local function onUseBtnTapped()
		self:onUseBtnTapped()
	end
	self.greenBtn:addEventListener(DisplayEvents.kTouchTap, onUseBtnTapped)

	local function onCancelBtnTapped()
		self:onCloseBtnTapped()
	end
	self.blueBtn:addEventListener(DisplayEvents.kTouchTap, onCancelBtnTapped)

	return true
end

function PrePropRemindPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self.allowBackKeyTap = true
end

function PrePropRemindPanel:onUseBtnTapped()
	self.greenBtn:setEnabled(false)
	self.blueBtn:setEnabled(false)
	local function onSuccess(items)
		local scene = HomeScene:sharedInstance()
		if scene and not scene.isDisposed then
			scene:checkDataChange()
			if scene.coinButton and not scene.coinButton.isDisposed then
				scene.coinButton:updateView()
			end
		end
		local pos = self.item:getPosition()
		pos = self.panel:convertToWorldSpace(ccp(pos.x, pos.y))
		for k, v in ipairs(items) do
			v.destXInWorldSpace = pos.x
			v.destYInWorldSpace = pos.y
		end
		if self.useCallback then self.useCallback(items) end
		self:onCloseBtnTapped()
	end
	local function onFail(err)
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)))
		self.greenBtn:setEnabled(true)
		self.blueBtn:setEnabled(true)
	end
	self.prePropRemindPanelLogic:buyPreProp(self.goodsDesc.id, onSuccess, onFail)
end

function PrePropRemindPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
	if self.finishCallback then self.finishCallback() end
end

PrePropRemindPanelLogic = class()
function PrePropRemindPanelLogic:buyPreProp(goodsId, successCallback, failCallback)
	local function onSuccess(data)
		-- reduce item and then callback
		local meta = MetaManager:getInstance():getGoodMeta(goodsId)
		if meta then
			for k, v in ipairs(meta.items) do UserManager:getInstance():addUserPropNumber(v.itemId, -v.num) end
		end
		if successCallback then successCallback(meta.items) end
	end
	local function onFail(errorCode)
		if failCallback then failCallback(errorCode) end
	end
	local logic = BuyLogic:create(goodsId, MoneyType.kCoin, DcFeatureType.kStagePlay, DcSourceType.kPreProp)
	logic:getPrice()
	logic:start(1, onSuccess, onFail)
end

PrePropRemindPanelModel = {
	levelId = 0,
	counter = 0,
}
local instance = nil
function PrePropRemindPanelModel:sharedInstance()
	if not instance then instance = PrePropRemindPanelModel end
	return instance
end

function PrePropRemindPanelModel:increaseCounter(levelId)
	if _G.isLocalDevelopMode then printx(0, "PrePropRemindPanelModel:increaseCounter", levelId, self.levelId, self.counter) end
	self.levelId = self.levelId or 0
	if self.levelId == levelId then self.counter = self.counter + 1
	else
		self.levelId = levelId
		self.counter = 1
	end
end

function PrePropRemindPanelModel:resetCounter()
	self.counter = 0
end

function PrePropRemindPanelModel:checkCounter(levelId)
	self.levelId = self.levelId or 0
	if self.levelId ~= levelId then return false end
	for k, v in ipairs(levelBlackList) do
		if v == levelId then return false end
	end
	return self.counter ~= 0 and self.counter % countToPushNotification == 0 and self:_hasEnoughCoin(levelId)
end

function PrePropRemindPanelModel:_hasEnoughCoin(levelId)
	local user = UserManager:getInstance():getUserRef()
	if not user then return false end
	local goodsDesc = GoodsDesc:create(PrePropRemindPanelModel:getRemindItemId(levelId))
	if not goodsDesc then return false end
	if user:getCoin() >= goodsDesc.coin then return true end
	return false
end

function PrePropRemindPanelModel:getRemindItemId(levelId)
	if _G.isLocalDevelopMode then printx(0, "PrePropRemindPanelModel:getRemindItemId", levelId, self:_getGameMode(levelId), self:_getMoveLimit(levelId)) end
	if self:_getGameMode(levelId) == 2 or self:_getMoveLimit(levelId) >= 20 then return 6
	else return 8 end
end

function PrePropRemindPanelModel:_getGameMode(levelId)
	return LevelMapManager:getInstance():getLevelGameMode(levelId)
end

function PrePropRemindPanelModel:_getMoveLimit(levelId)
	local meta = LevelMapManager:getInstance():getMeta(levelId)
	if meta and meta.gameData and meta.gameData.moveLimit then return meta.gameData.moveLimit end
	return 0
end