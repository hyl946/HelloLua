
require "zoo.panel.basePanel.BasePanel"
require "hecore.ui.PopoutManager"
require "zoo.data.MetaManager"
require "zoo.panelBusLogic.BuyLogic"
require "zoo.net.Http"
require "zoo.baseUI.ButtonWithShadow"
require "zoo.baseUI.BuyAndContinueButton"
require "zoo.panel.RequireNetworkAlert"
require "zoo.panel.basePanel.panelAnim.IconPanelShowHideAnim"
 require "zoo.panel.mark.PayPanelMarkPrise"
require "zoo.panel.MarkEnergyNotiPanel"
require "zoo.panel.MarkEnergyRemindPanel"
require "zoo.panel.MarkPanelMinshengPlugin"

MarkPanel = class(BasePanel)

function MarkPanel:create(scaleOriginPosInWorld, ...)
	assert(scaleOriginPosInWorld)
	assert(#{...} == 0)

	local panel = MarkPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_mark)
	if panel:init(scaleOriginPosInWorld) then
		if _G.isLocalDevelopMode then printx(0, "return true, panel should been shown") end
		return panel
	else
		if _G.isLocalDevelopMode then printx(0, "return false, panel's been destroyed") end
		panel = nil
		return nil
	end
end

function MarkPanel:dispose()
	self.markCallback = nil
	self:removeListeners()
	BasePanel.dispose(self)
	ModuleNoticeButton:tryPopoutStartGamePanel()
	
end

function MarkPanel:init(scaleOriginPosInWorld, ...)
	-- 数据初始化
	self.panelLuaName = "MarkPanel"
	self.uid = 0
	self.addNum = 0
	self.markNum = 0
	self.markTime = 0
	self.createTime = 0
	self.tipTarget = nil
	self.signDay = 0
	self.canSign = false
	self.resignCount = 0
	self.signedDay = 0

	self.scaleOriginPosInWorld = scaleOriginPosInWorld

	-- 获取数据
	self.markRewards = table.copyValues(MetaManager:getInstance().mark)
	for _,markData in ipairs(self.markRewards) do
		for _,reward in ipairs(markData.rewards) do
			if reward.itemId == 2 then
				if Achievement:getRightsExtra("MarkCoinIncomeTimes") > 0 then
					reward.color = ccc3(255,102,0)
				end
				reward.num = reward.num + self:getAchiExtraRights(reward.num)
			end
		end
	end

	self.userMark = UserManager:getInstance().mark
	self.fillSign = MetaManager:getInstance().global.fillSign

	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kMarkPanel)
	self.uncommonSkin = uncommonSkin
	self.ui = self:buildInterfaceGroup(skinName)

	BasePanel.init(self, self.ui)
	self.ui:setTouchEnabled(true, 0, true)

	-- 获取控件
	self.captain = self.ui:getChildByName("captain")
	self.remark = self.ui:getChildByName("remark")
	self.remarkLable = self.ui:getChildByName("remarkLable")
	self.mark = self.ui:getChildByName("mark")
	self.leave = self.ui:getChildByName("leave")
	self.countDown = self.ui:getChildByName("countDown")
	self.clear = self.ui:getChildByName("clear")
	self.clear:setDimensions(CCSizeMake(0,0))
	self.clear.originPosX = self.clear:getPositionX()
	self.backgroud = self.ui:getChildByName("_bg")

	self.notSigned = {}
	self.tnos = self.ui:getChildByName("notSigned")
	for i = 1, 30 do
		local node = self.tnos:getChildByName("node"..#self.notSigned)
		table.insert(self.notSigned, node)
		node.name = #self.notSigned
	end
	self.signed = {}
	self.ts = self.ui:getChildByName("signed")
	for i = 1, 30 do
		local node = self.ts:getChildByName("node"..#self.signed)
		table.insert(self.signed, node)
		node.name = #self.signed
	end
	self.position = {}
	self.pos = self.ui:getChildByName("position")
	for i = 1, 31 do
		local node = self.pos:getChildByName("day"..#self.position)
		table.insert(self.position, node)
		node.name = #self.position
	end
	self.paths = {}
	self._path = self.ui:getChildByName('_path')
	for i = 1, 31 do
		local node = self._path:getChildByName('Layer '..i)
		table.insert(self.paths, node)
	end

	self.pos:setVisible(false)
	self.nodeOrigin = self.ts:getChildByName("nodeOrigin")
	self.now = self.ui:getChildByName("now")
	self.head = self.now:getChildByName("sprite"):getChildByName("head")
	self.now:getChildByName("sprite"):getChildByName('bg'):setVisible(false)
	self.close = self.ui:getChildByName("close")
	self.priseButton = self.ui:getChildByName("priseButton")
	self.priseButtonImg = self.priseButton:getChildByName("img")
	self.priseButtonTimer = self.priseButton:getChildByName("timer")
	self.mark = GroupButtonBase:create(self.mark)
	self.leave = GroupButtonBase:create(self.leave)
	self.remark = ButtonIconNumberBase:create(self.remark)
	self.remark:setIconByFrameName("common_icon/item/icon_coin_small0000", true)
	self.remark:setColorMode(kGroupButtonColorMode.blue)
	self.head:setVisible(false)


	-- 设置文字、占位符（需要更新本地化文件）
	self.remark:setString(Localization:getInstance():getText("mark.panel.remark.btn.text"))
	self.mark:setString(Localization:getInstance():getText("mark.panel.mark.btn.text"))
	self.clear:setString(Localization:getInstance():getText("mark.panel.clear.label"))
	self.mark:setString(Localization:getInstance():getText("mark.panel.mark.btn.text"))
	self.leave:setString(Localization:getInstance():getText("mark.panel.close.btn.text"))
	if not self.uncommonSkin then 
		-- 替换标题
		local charWidth = 65
		local charHeight = 65
		local charInterval = 57
		local fntFile = "fnt/caption.fnt"
		if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/caption.fnt" end
		local position = self.captain:getPosition()
		self.newCaptain = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
		self.newCaptain:setAnchorPoint(ccp(0,1))
		self.newCaptain:setString(Localization:getInstance():getText("mark.panel.title"))
		self.newCaptain:setPosition(ccp(position.x, position.y))
		self.ui:addChildAt(self.newCaptain, 3)
		self.newCaptain:setToParentCenterHorizontal()
		self.captain:removeFromParentAndCleanup(true)
	end

	-- 设置互动事件监听
	local function onExitTouch()
		self:onCloseBtnTapped()
	end
	local function onMarkTouch()
		self:markNew()
	end
	self.mark:ad(DisplayEvents.kTouchTap, onMarkTouch)
	self.mark:useBubbleAnimation()

	self.leave:ad(DisplayEvents.kTouchTap, onExitTouch)
	self.leave:useBubbleAnimation()

	self.leave:setVisible(false)
	self.close:setTouchEnabled(true)
	self.close:setButtonMode(true)
	self.close:ad(DisplayEvents.kTouchTap, onExitTouch)

	local function onRemarkTouch()
		if self.remarkTip and not self.remarkTip.isDisposed then
			self.remarkTip:clear()
			self.remarkTip = nil
		end
		if self:remarkNew() then
		end
	end
	if self.remark then self.remark:ad(DisplayEvents.kTouchTap, onRemarkTouch) end

	local function getTouchedNode(globalPos)
		local childrenList = self.tnos:getChildrenList()
		for __, v in pairs(childrenList) do
			if v:hitTestPoint(globalPos, true) and v:isVisible() then return v end
		end
	end
	local function onNodeTouch(evt)
		local node = getTouchedNode(evt.globalPosition)
		local posAdd = self.tnos:getPosition()
		if not node then return end
		local rest = tonumber(node.name) - self.signedDay
		local text = Localization:getInstance():getText("mark.panel.tip.title", {mark_number = rest})
		local found = false
		for k, v in ipairs(self.markRewards[node.name].rewards) do
			if v.itemId == 10039 then found = true break end
		end
		local tipPanel
		if found then tipPanel = BoxRewardTipPanel:create(self.markRewards[node.name],
			Localization:getInstance():getText("mark.panel.tip.bottom", {n = '\n'}))
		else tipPanel = BoxRewardTipPanel:create(self.markRewards[node.name]) end
		tipPanel:setTipString(text)
		self:addChild(tipPanel)

		local originSize = node:getContentSize()
		local enlargeRestoreAction = EnlargeRestore:create(node, originSize, 1.25, 0.1, 0.1)
		if node:numberOfRunningActions() == 0 then
			node:runAction(enlargeRestoreAction)
		end

		local tappedBoxPos = node:getPosition()
		local tappedBoxPosInWorldPos = self.ui:convertToWorldSpace(ccp(tappedBoxPos.x, tappedBoxPos.y))

		local tappedBoxSize = node:getGroupBounds().size
		tappedBoxPosInWorldPos.x 	= tappedBoxPosInWorldPos.x + tappedBoxSize.width / 2
		tappedBoxPosInWorldPos.y	= tappedBoxPosInWorldPos.y - tappedBoxSize.height / 2

		tipPanel:setArrowPointPositionInWorldSpace(tappedBoxSize.width/2, tappedBoxPosInWorldPos.x + posAdd.x, tappedBoxPosInWorldPos.y + posAdd.y)
	end
	self.tnos:setTouchEnabled(true)
	self.tnos:ad(DisplayEvents.kTouchTap, onNodeTouch)

	local function onPriseTimer(evt)
		if self.isDisposed then return end
		local time = evt.data
		if type(time) ~= "number" or time <= 0 then
			self.priseButton:setVisible(false)
		else
			self.priseButton:setVisible(true)
			self.priseButtonTimer:setText(string.format("%02d:%02d:%02d", tostring(math.floor(time / 3600)), tostring(math.floor(time % 3600 / 60)), tostring(math.floor(time % 60))))
			local size = self.priseButtonTimer:getContentSize()
			self.priseButtonTimer:setPositionX((self.priseButtonSize.width - size.width) / 2)
		end
	end
	self.priseButtonSize = self.priseButtonImg:getGroupBounds().size
	self.priseButtonSize = {width = self.priseButtonSize.width, height = self.priseButtonSize.height}
	MarkModel:getInstance():addEventListener(kMarkEvents.kPriseTimer, onPriseTimer)
	self.removeListeners = function(self)
		MarkModel:getInstance():removeEventListener(kMarkEvents.kPriseTimer, onPriseTimer)
	end
	local index, time = MarkModel:getInstance():getCurrentIndexAndTime()
	if index ~= 0 then
		self.priseButtonTimer:setText(string.format("%02d:%02d:%02d", tostring(math.floor(time / 3600)), tostring(math.floor(time % 3600 / 60)), tostring(math.floor(time % 60))))
		local size = self.priseButtonTimer:getContentSize()
		self.priseButtonTimer:setPositionX((self.priseButtonSize.width - size.width) / 2)
	else
		self.priseButton:setVisible(false)
	end
	local function onPriseTapped(evt)
		-- close remark tip
		if self.remarkTip and not self.remarkTip.isDisposed then
			self.remarkTip:clear()
			self.remarkTip = nil
		end
		-- show mark prise panel
		local index = MarkModel:getInstance():getCurrentIndexAndTime()
		if index and index ~= 0 then
			local function onReleasePrise()
				self.markPriseShown = false
			end
			self.markPriseShown = true
			PayPanelMarkPrise:create(tonumber(index), onReleasePrise)
		end
	end
	self.priseButton:setTouchEnabled(true)
	self.priseButton:addEventListener(DisplayEvents.kTouchTap, onPriseTapped)


	-- 刷新数据
	self:updateProfile()
	self:refreshData(true)
	self:playNearestBoxAnimation()
	self:scaleAccordingToResolutionConfig()
	self.showHideAnim = IconPanelShowHideAnim:create(self, self.scaleOriginPosInWorld)

	self.ui:getChildByName("ogcBtn"):setVisible(false)

	MarkPanelMinshengPlugin:init(self)

	return true
end

function MarkPanel:onCloseBtnTapped()
	local function onHideAnimFinished()
		if MarkModel:getInstance().needNotifyGuide then
			MarkModel:getInstance().needNotifyGuide = false
			NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kMarkChest)
		end

		--PopoutManager:sharedInstance():remove(self)
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, true)
		if self.closeCallback then
			self.closeCallback()
		end
	end
	-- fix
	if GameGuide then
		GameGuide:sharedInstance():onPopdown(self)
	end
	-- end fix
	self.allowBackKeyTap = false
	self.showHideAnim:playHideAnim(onHideAnimFinished)
	if self.remarkTip and not self.remarkTip.isDisposed then
		self.remarkTip:clear()
		self.remarkTip = nil
	end
end

function MarkPanel:updateProfile()
	local profile = UserManager.getInstance().profile
	if profile and profile.headUrl ~= self.headUrl then
		if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
		local framePos = self.head:getPosition()
		local frameSize = self.head:getGroupBounds().size
		frameSize = {width = frameSize.width, height = frameSize.height}
		local function onImageLoadFinishCallback(clipping)
			if self.isDisposed then return end
			local clippingSize = clipping:getContentSize()
			clipping:setScaleX(frameSize.width / clippingSize.width)
			clipping:setScaleY(frameSize.height / clippingSize.height)
			clipping:setPosition(ccp(framePos.x + frameSize.width / 2 , framePos.y - frameSize.height / 2))
			self.now:getChildByName("sprite"):addChild(clipping)
			self.clipping = clipping
			self.headUrl = profile.headUrl
			-- clipping:setPosition(ccp(6, 23))
			-- clipping:setScale(0.83)
			-- clipping:setAnchorPoint(ccp(-0.5, -0.5))
			-- self.now:addChild(clipping)
			-- self.clipping = clipping
			-- self.headUrl = profile.headUrl
		end
		local head = HeadImageLoader:createWithFrame(profile.uid, profile.headUrl,nil, 2)
		onImageLoadFinishCallback(head)
	end
end

function MarkPanel:refreshData(firstTime)
	self:setSignInfo()
	for i = 1, self.signedDay do
		self.notSigned[i]:setVisible(false)
		self.signed[i]:setVisible(true)
	end
	for i = self.signedDay + 1, #self.signed do
		self.signed[i]:setVisible(false)
		self.notSigned[i]:setVisible(true)
	end
	local target
	target = self.position[self.signedDay + 1]
	local nodePos = target:getPosition()
	local pos = ccp(nodePos.x, nodePos.y)
	local posAdd = self.pos:getPosition()
	pos.x, pos.y = pos.x + posAdd.x, pos.y + posAdd.y
	self.now:setPosition(ccp(pos.x, pos.y))

	local leftDay = 31 - self.signDay
	if leftDay == 2 then
		self.countDown:setString("")
		self.clear:setString("明日24点清除签到信息")
		self.clear:setPositionX(self.clear.originPosX - 50)
	elseif leftDay == 1 then
		self.countDown:setString("")	
		self.clear:setString("今日24点清除签到信息")
		self.clear:setPositionX(self.clear.originPosX - 50)
	else
		self.countDown:setString(tostring(leftDay))
		self.clear:setString(Localization:getInstance():getText("mark.panel.clear.label"))
		self.clear:setPositionX(self.clear.originPosX)
	end
	self.remark:setNumber(self.fillSign[self.addNum + 1])
	if self.resignCount <= 0 then 
		self.remark:setVisible(false) 
		self.remarkLable:setVisible(false)
	else
		self.remarkLable:setVisible(true)
		self.remarkLable:setString(localize("mark.panel.remark.tip", {n = self.resignCount}))
	end
	self.mark:setVisible(true)
	self.leave:setVisible(false)

	if self.canSign then
		self.remark:setVisible(false)
		self.remarkLable:setVisible(false)
	else
		self:btnSignToExit()
	end
end

function MarkPanel:setMarkCallback(callback)
	self.markCallback = callback
end

function MarkPanel:setCloseCallback(callback)
	self.closeCallback = callback
end

function MarkPanel:btnSignToExit()
	self.mark:setVisible(false)
	self.leave:setVisible(true)
end

function MarkPanel:markNew()
	if _G.isLocalDevelopMode then printx(0, 'markNew') end
	if self.markPriseShown then return end
	self:refreshData()
	if not self.canSign then
		CommonTip:showTip(Localization:getInstance():getText("mark.panel.cant.mark"), "negative")
		return
	end
	local function onSuccess(evt)
		if self.isDisposed then return end
		self.mark:setEnabled(false)
		self.remark:setEnabled(false)
		self.signedDay = self.signedDay + 1
		if self.resignCount > 0 then
			self.remark:setVisible(true)
			self.remarkLable:setVisible(true)
			self.remarkLable:setString(localize("mark.panel.remark.tip", {n = self.resignCount}))
		end
		local function onAnimOver()
			self.remark:setEnabled(true)
			self.mark:setEnabled(true)
			self:playNearestBoxAnimation()
		end
		self:updateANewMark(onAnimOver)
		self:btnSignToExit()		
		self:checkAndPlayRemarkTip()
		if self.markCallback then
			self.markCallback()
		end
		MarkModel:getInstance():setGetRewardNotification(self.signDay, self.signedDay)
	end
	local function onFail(evt)

        local key = "error.tip."..evt.data
        if evt.data == 730654 and _G.bundleVersion >= "1.65" then
            key = "error.tip."..evt.data..".1"
        end 
		CommonTip:showTip(Localization:getInstance():getText(key), "negative")
	end

	local function onProc()
		if self.isDisposed then return end
		local function sendMarkRequest()
			local http = MarkHttp.new(true)
			http:ad(Events.kComplete, onSuccess)
			http:ad(Events.kError, onFail)
			http:load()
		end
		RequireNetworkAlert:callFuncWithLogged(sendMarkRequest)
	end

	if self.markRewards[self.signedDay + 1] and self.markRewards[self.signedDay + 1].rewards then
		local found = false
		for i, v in ipairs(self.markRewards[self.signedDay + 1].rewards) do
			if v.itemId == 10039 then
				found = true
				break
			end
		end
		if found then
			MarkEnergyRemindPanel:create(onProc):popout()
		else
			onProc()
		end
	else
		return
	end
end

function MarkPanel:updateANewMark(finishCallback)
	if _G.isLocalDevelopMode then printx(0, 'updateANewMark') end
	self:getReward()
	if self.isDisposed then return end
	self:playRewardAnim()
	local nodePos = self.position[self.signedDay + 1]:getPosition()
	local pos = ccp(nodePos.x, nodePos.y)
	local posAdd = self.pos:getPosition()
	pos.x, pos.y = pos.x + posAdd.x, pos.y + posAdd.y
	
	local function onFinish()
		if finishCallback then
			finishCallback()
		end
	end
	self.now:stopAllActions()
	self.now:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.3, ccp(pos.x, pos.y)),
		CCCallFunc:create(onFinish)))
	if self.markRewards[self.signedDay].type == 2 then
		self:playBoxOpen(self.signedDay)
	else
		self.signed[self.signedDay]:setVisible(true)
		self.notSigned[self.signedDay]:setVisible(false)
	end

	MarkPanelMinshengPlugin:onNewMark(self,self.signedDay)
end

function MarkPanel:getAchiExtraRights( num )
	return num * Achievement:getRightsExtra( "MarkCoinIncomeTimes" )
end

function MarkPanel:getReward()
	local reward = self.markRewards[self.signedDay].rewards
	local rType = self.markRewards[self.signedDay].type
	local rGoods = self.markRewards[self.signedDay].goodsId

	if rType == 1 then
		UserManager:getInstance():addCoin(reward[1].num)
		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kSignIn, ItemType.COIN, reward[1].num, DcSourceType.kSignReward)
	elseif rType == 2 then
		for __, v in ipairs(reward) do
			if v.itemId == ItemType.INFINITE_ENERGY_BOTTLE then
				local logic = UseEnergyBottleLogic:create(ItemType.INFINITE_ENERGY_BOTTLE, DcFeatureType.kSignIn, DcSourceType.kSignReward)
				local function successCallback()
					SyncManager.getInstance():sync()
				end
				logic:setSuccessCallback(successCallback)
				logic:start(true)
			else
				UserManager:getInstance():addReward(v)
			end
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kSignIn, v.itemId, v.num, DcSourceType.kSignReward)
		end
	end

	if type(rGoods) == "number" then MarkModel:getInstance():addIndex(self.signedDay) end
end

function MarkPanel:playRewardAnim()
	local sSize = self.signed[self.signedDay]:getGroupBounds().size
	local home = HomeScene:sharedInstance()
	local reward = self.markRewards[self.signedDay].rewards
	local rType = self.markRewards[self.signedDay].type
	local rGoods = self.markRewards[self.signedDay].goodsId
	local pos = self.signed[self.signedDay]:getPosition()
	pos = self.signed[self.signedDay]:getParent():convertToWorldSpace(ccp(pos.x + sSize.width/2, pos.y - sSize.width/2))
	if _G.isLocalDevelopMode then printx(0, pos.x, pos.y) end
	local vSize = Director:sharedDirector():getVisibleSize()
	home:checkDataChange()
	local function checkMarkPrise()
		if self.hasCreatedMarkPriseShown then return end
		if type(rGoods) == "number" then
			local function onReleasePrise()
				self.markPriseShown = false
			end
			self.markPriseShown = true
			self.hasCreatedMarkPriseShown = true
			PayPanelMarkPrise:create(self.signedDay, onReleasePrise)
		end
	end
	local callback = false
	if rType == 2 then
		local count = 0
		local width, spare = 60, 30
		local fullWidth = #reward * (width + spare) - spare
		local startPosX = pos.x - fullWidth / 2
		if startPosX < 0 then 
			startPosX = 0
		elseif startPosX + fullWidth >= vSize.width then
			startPosX = pos.x - fullWidth
		end
		if _G.isLocalDevelopMode then printx(0, startPosX, fullWidth, vSize.width, startPosX + fullWidth) end
		local isFinalChest = false

		local toBoxRewards = {} 
		for __, v in ipairs(reward) do
			if v.itemId == 10039 then
				local x, y = self.position[29]:getPositionX(), self.position[29]:getPositionY()
				local position = self.pos:convertToWorldSpace(ccp(x, y))
				local panel = MarkGetEnergyNotiPanel:create(position, function( ... )
					checkMarkPrise()
					
					local anim = OpenBoxAnimation:create(toBoxRewards)
					anim:play()
				end)
				panel:popout()

				--只有最后一个宝箱里会有无限精力瓶 所以把领完最后一个宝箱里的炫耀调起逻辑加在这里
				ShareManager:checkShareTime()
				isFinalChest = true
			else
				count = count + 1
				if MarkPanelMinshengPlugin:checkReward(v) then
					table.insert(toBoxRewards,v)
				end
			end

		end

		if not isFinalChest then
			self:runAction(CCCallFunc:create(function( ... )
				local anim = OpenBoxAnimation:create(toBoxRewards)
				anim:play()
			end))
		end
		
		Notify:dispatch("AchiEventDataUpdate", AchiDataType.kGetFinalMarkChest, isFinalChest)
	else
		local anim = FlyItemsAnimation:create(reward)
		anim:setWorldPosition(pos)
		anim:play()
	end
	if not callback then checkMarkPrise() end
end

function MarkPanel:playBoxOpen(index)
	local function BoxOpened()
		-- 这一段神奇的会造成坐标偏差，于是暂时把它注释掉了:-(
		-- local pos = self.signed[index]:getPosition()
		-- self.signed[index]:setAnchorPoint(ccp(0.5, -1))
		-- local size = self.signed[index]:getGroupBounds().size
		-- self.signed[index]:setPosition(ccp(pos.x, pos.y - size.height / 2))
		-- self.signed[index]:setSkewX(5)
		-- self.signed[index]:runAction(CCSkewTo:create(0.1, 0, 0))
		self.signed[index]:setVisible(true)
		self.notSigned[index]:setVisible(false)
	end
	local pos = self.notSigned[index]:getPosition()
	self.notSigned[index]:setAnchorPoint(ccp(0.5, -1))
	local size = self.notSigned[index]:getGroupBounds().size
	self.notSigned[index]:setPosition(ccp(pos.x + size.width / 2, pos.y - 2 * size.height))
	self.notSigned[index]:runAction(CCSequence:createWithTwoActions(CCSkewTo:create(0.2, -5, 0), CCCallFunc:create(BoxOpened)))
end

function MarkPanel:remarkNew()
	if self.markPriseShown then return end
	self:refreshData()
	if self.resignCount <= 0 then
		CommonTip:showTip(Localization:getInstance():getText("mark.panel.cant.remark"), "negative")
		return
	end
	local function onSuccess(data)

		local bounds = self.remark:getGroupBounds()
		local pos = ccp(bounds:getMidX(),bounds:getMidY())
		self.remark:playFloatAnimation('-'..tostring(self.remark:getNumber()))

		self.remark:setEnabled(false)
		self.signedDay = self.signedDay + 1
		local function onUpdateFinish() 
			self.remark:setEnabled(true) 
			self:playNearestBoxAnimation()
		end
		self:updateANewMark(onUpdateFinish)
		if self.isDisposed then return end
		self.resignCount = self.resignCount - 1
		if self.resignCount > 0 then
			self.addNum = self.addNum + 1
			self.remark:setNumber(self.fillSign[self.addNum + 1])
			self.remarkLable:setVisible(true)
			self.remarkLable:setString(localize("mark.panel.remark.tip", {n = self.resignCount}))
		else 
			self.remark:setVisible(false) 
			self.remarkLable:setVisible(false)
		end
		local scene = HomeScene:sharedInstance()
		local button = scene.goldButton
		if button then button:updateView() end
		MarkModel:getInstance():setGetRewardNotification(self.signDay, self.signedDay)
	end
	local function onFail(errorCode)
		self.remark:setEnabled(true)
		if errorCode == 730330 then	-- 没钱
			self:goldNotEnough()
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errorCode)), "negative")
		end
	end

	local function onProc()
		if self.isDisposed then return end
		local function startBuyLogic()
			local logic = BuyLogic:create(15, MoneyType.kGold, DcFeatureType.kSignIn, DcSourceType.kSignSupply)
			logic:getPrice()
			logic:start(1, onSuccess, onFail, nil, self.fillSign[self.addNum + 1])
		end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic)
	end
	
	if self.markRewards[self.signedDay + 1] and self.markRewards[self.signedDay + 1].rewards then
		local found = false
		for i, v in ipairs(self.markRewards[self.signedDay + 1].rewards) do
			if v.itemId == 10039 then
				found = true
				break
			end
		end
		if found then
			MarkEnergyRemindPanel:create(onProc):popout()
		else
			onProc()
		end
	else
		return
	end 
end

function MarkPanel:goldNotEnough()
	if _G.isLocalDevelopMode then printx(0, "MarkPanel:goldNotEnough") end
	local function createGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "createGoldPanel") end
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel = createMarketPanel(index)
			panel:popout()
		end
	end
	local function askForGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "ask for gold panel") end
		GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
	end
	askForGoldPanel()
end

function MarkPanel:setSignInfo()
	local markModel = MarkModel:getInstance()
	markModel:calculateSignInfo()
	self.addNum = markModel.addNum
	self.canSign = markModel.canSign
	self.signDay = markModel.signDay
	self.signedDay = markModel.signedDay
	self.resignCount = markModel.resignCount
end

function MarkPanel:popout()
	-- fix
	if GameGuide then
		GameGuide:sharedInstance():onPopup(self)
	end
	-- end fix
	PopoutQueue.sharedInstance():push(self,true,false,function( ... )end)
	self:setVisible(false)
end

function MarkPanel:popoutShowTransition()
	-- debug.debug()
	local function onAnimOver() 
		self.allowBackKeyTap = true 
	end
	local function onTransFinish()
		if self.signedDay <= 27 then
			if MarkPanelMinshengPlugin:needShowEnergyTip(self.signedDay,MarkModel:getInstance().curCycle) then
				local x, y = self.position[29]:getPositionX(), self.position[29]:getPositionY()
				local position = self.pos:convertToWorldSpace(ccp(x, y))
				MarkEnergyNotiOnceMinshengPanel:create(self, onAnimOver, position)
				return
			end
			local path = HeResPathUtils:getUserDataPath() .. "/marktip"
			local hFile, err = io.open(path, "r")
			if hFile and not err then
				io.close(hFile)
				onAnimOver()
				return
			end
			local x, y = self.position[29]:getPositionX(), self.position[29]:getPositionY()
			local position = self.pos:convertToWorldSpace(ccp(x, y))
			MarkEnergyNotiOncePanel:create(self, onAnimOver, position)
			Localhost:safeWriteStringToFile("", path)
		else 
			onAnimOver() 
		end
	end
	self.showHideAnim:playShowAnim(onTransFinish)
end

local PanelOriWidth = 729
local PanelOriHeight = 942
function MarkPanel:getHCenterInParentX()
	-- Vertical Center In Screen Y
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	-- local selfHeight	= self:getGroupBounds().size.height
	local selfWidth = PanelOriWidth * self:getScale()

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	local vCenterInScreenX	= visibleOrigin.x + halfDeltaWidth

	-- Vertical Center In Parent Y
	local parent 		= self:getParent()
	local posInParent	= parent:convertToNodeSpace(ccp(vCenterInScreenX, 0))

	return posInParent.x
end

function MarkPanel:getVCenterInScreenY()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= PanelOriHeight * self:getScale()

	local deltaHeight	= visibleSize.height - selfHeight
	local halfDeltaHeight	= deltaHeight / 2

	return visibleOrigin.y + halfDeltaHeight + selfHeight
end

function MarkPanel:playNearestBoxAnimation()
	local nearestBox = nil

	local tag = 13579
	-- stop the current
	if self.markRewards[self.signedDay] and self.markRewards[self.signedDay].type == 2 then
		self.notSigned[self.signedDay]:stopActionByTag(tag)
	end

	-- start the nearest
	for i=self.signedDay + 1, #self.signed do 
		if self.markRewards[i].type == 2 then
			nearestBox = self.notSigned[i]
			break
		end		
	end
	if not nearestBox then return end
	if nearestBox:getActionByTag(tag) == nil then
		local originSize = nearestBox:getContentSize()
		local anim = EnlargeRestore:create(nearestBox, originSize, 1.125, 1.5, 1.5)
		local delay = CCDelayTime:create(0.5)
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(anim, delay))
		action:setTag(tag)
		nearestBox:runAction(action)
	end
end

local needRemarkCount = {[0] = 1, [1] = 2, [2] = 3, [3] = 5}
function MarkPanel:checkAndPlayRemarkTip()
	if self.signDay <= 24 then return end
	local leftDay = 31 - self.signDay
	if leftDay > 1 then return end
	
	local index, remarkCount, reward = 0, 0, 0
	local canSignDay = self.signedDay + 30 - self.signDay
	for i = canSignDay + 1, 30 do
		remarkCount = remarkCount + 1
		if self.markRewards[i].type == 2 then
			index = i
			reward = self.markRewards[i].packagePrice
			if type(reward) ~= "number" then reward = 0 end
			break
		end
	end
	if index == 0 then return end
	if not needRemarkCount[math.floor(index / 9)] then return end
	if remarkCount > needRemarkCount[math.floor(index / 9)] then return end
	local prise = 0
	for i = 1, remarkCount do prise = prise + self.fillSign[self.addNum + i] if _G.isLocalDevelopMode then printx(0, "prise", prise) end end
	if prise == 0 then return end
	local layer = MarkRemindRemarkAnim:create(self, prise, reward)
	self.remarkTip = layer
end

MarkModel = class(EventDispatcher)

local instance = nil

function MarkModel:ctor()
	self.signDay = 0
	self.addNum = 0
	self.signedDay = 0
	self.resignCount = 0
	self.canSign = false
	self.needNotifyGuide  = false
end

function MarkModel:getInstance()
	if not instance then
		instance = MarkModel.new()
		instance:init()
	end
	return instance
end

local timeSpan = 3600000
function MarkModel:init()
	self.schedule = nil
	self:readMarkPriseFile()
	if type(self.firstActivePrise) == "number" and self.firstActivePrise ~= 0 then
		local now = Localhost:time()
		local cycle = math.floor((now - self.firstActivePrise) / timeSpan)
		if type(self.priseIndex) == "table" then
			if cycle < 0 or cycle > #self.priseIndex then
				self.firstActivePrise = 0
				self.priseIndex = {}
			else
				self.firstActivePrise = self.firstActivePrise + cycle * timeSpan
				for i = 1, cycle do table.remove(self.priseIndex, 1) end
				local function onTimeout() self:refresh() end
				self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)
			end
		end
	end
	self.firstActivePrise = self.firstActivePrise or 0
	self.priseIndex = self.priseIndex or {}
	self:writeMarkPriseFile()
end

function MarkModel:calculateSignInfo()
	local userMark = UserManager:getInstance().mark
	local dayTime = 3600 * 24
	local cycleTime = 3600 * 24 * 30
	local createTime = userMark.createTime / 1000
	local nowTime = Localhost:time() / 1000
	local curCycle = math.floor((nowTime - createTime) / cycleTime)
	local curCycleBase = math.floor((nowTime - createTime) / cycleTime) * cycleTime + createTime
	self.signDay = math.ceil((nowTime - curCycleBase) / dayTime)
	local lastSignDay = math.floor((userMark.markTime / 1000 - createTime) / dayTime) * dayTime + createTime
	local lastSignCycle = math.floor((lastSignDay - createTime) / cycleTime)
	if curCycle ~= lastSignCycle then
		userMark.addNum = 0
		userMark.markNum = 0
	end
	self.curCycle = curCycle
	self.addNum = userMark.addNum
	self.signedDay = userMark.markNum
	self.resignCount = self.signDay - self.signedDay
	self.canSign = (nowTime - lastSignDay) > dayTime
	if self.canSign then self.resignCount = self.resignCount - 1 end
end

function MarkModel:resetMarkInfo( )
	-- body
	local userMark = UserManager:getInstance().mark
	local dayTime = 1000 * 3600 * 24
	userMark.createTime = math.floor(Localhost:time() /dayTime) * dayTime
	userMark.addNum = 0
	userMark.markNum = 0
end

kMarkEvents = {
	kPriseTimer = "kMarkModelEvents.kPriseTimer",
	kPriseTimeOut = "kMarkModelEvents.kPriseTimeOut",
}

function MarkModel:refresh()
	local time = Localhost:time()
	local elapse = time - self.firstActivePrise
	if elapse > timeSpan then
		self:removeFirstIndex()
	end
	self:dispatchEvent(Event.new(kMarkEvents.kPriseTimer, (timeSpan - elapse) / 1000, self))
end

-- modified, only one mark prise exist instead of a list
function MarkModel:addIndex(index)
	self.firstActivePrise = Localhost:time()
	self.priseIndex[1] = index
	self:writeMarkPriseFile()
	if not self.schedule then
		local function onTimeout() self:refresh() end
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)
		self:dispatchEvent(Event.new(kMarkEvents.kPriseTimer, timeSpan / 1000, self))
	end
end

function MarkModel:getCurrentIndexAndTime()
	if self.firstActivePrise == 0 then return 0
	else
		local index = self.priseIndex[1]
		local markReward = MetaManager:getInstance().mark[tonumber(index)]
		local goodsId = markReward and markReward.goodsId or nil
		if not goodsId or UserManager.getInstance().dailyData:getBuyedGoodsById(goodsId) > 0 then -- 解决购买后回调失败的情况下一直显示购买的问题
			self:removeIndex(index)
			return 0
		else
			local time = Localhost:time()
			return index, (timeSpan - time + self.firstActivePrise) / 1000
		end
	end
end

function MarkModel:removeFirstIndex()
	self.firstActivePrise = Localhost:time()
	table.remove(self.priseIndex, 1)
	if #self.priseIndex <= 0 then
		self.firstActivePrise = 0
		if self.schedule then
			self:dispatchEvent(Event.new(kMarkEvents.kPriseTimer, 0, self))
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.schedule = nil
		end
	end
	self:writeMarkPriseFile()
	self:dispatchEvent(Event.new(kMarkEvents.kPriseTimeOut), nil, self)
end

function MarkModel:removeIndex(index)
	for k, v in ipairs(self.priseIndex) do
		if tonumber(v) == tonumber(index) then
			if k == 1 then
				self:removeFirstIndex()
			else
				self.firstActivePrise = Localhost:time()
				table.remove(self.priseIndex, k)
				if #self.priseIndex <= 0 then
					self.firstActivePrise = 0
					if self.schedule then
						self:dispatchEvent(Event.new(kMarkEvents.kPriseTimer, 0, self))
						Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
						self.schedule = nil
					end
				end
				self:writeMarkPriseFile()
				self:dispatchEvent(Event.new(kMarkEvents.kPriseTimeOut), nil, self)
			end
			break
		end
	end
end

function MarkModel:readMarkPriseFile()
	local path = HeResPathUtils:getUserDataPath() .. "/markprise"
	local hFile, err = io.open(path, "r")
	local text
	if hFile and not err then
		text = hFile:read("*a")
		io.close(hFile)
		local function split(str, char)
    		local res = {}
   			string.gsub(str, "[^"..char.."]+", function(w) table.insert(res, w) end)
    		return res
		end
		local res = split(text, ",")
		if res[1] then self.firstActivePrise = tonumber(res[1]) end
		self.priseIndex = self.priseIndex or {}
		for k, v in ipairs(res) do
			if k ~= 1 then table.insert(self.priseIndex, v) end
		end
	end
end

function MarkModel:writeMarkPriseFile()
	local path = HeResPathUtils:getUserDataPath() .. "/markprise"
	local text = ""
	if self.firstActivePrise ~= 0 then
		text = text..tostring(self.firstActivePrise)..','
		for k, v in ipairs(self.priseIndex) do text = text..tostring(v)..','end
		text = string.sub(text, 1, -2)
	end
	Localhost:safeWriteStringToFile(text, path)
end

function MarkModel:setGetRewardNotification(signDay, signedDay)
	if signedDay >= 26 and signedDay < 28 then
		local leftMarkTimesInThisPeriod = 30 - signDay -- 当前周期剩余的可以免费签到的次数
		local timesToGetFinalReward = 28 - signedDay -- 距离28天宝箱还需要签到的次数
		if leftMarkTimesInThisPeriod >= timesToGetFinalReward then
	        LocalNotificationManager.getInstance():setMarkRewardNotification(timesToGetFinalReward)
			--提示开启推送
			self.needNotifyGuide = true
		end
	end

	if signedDay == 27 or signedDay == 28 then
		-- 代表是否清楚明天及后天的推送, [1] = 明天, [2] = 后天
		local dayToCancel = nil
		if signedDay == 28 then
			dayToCancel = {true, true}
		elseif signedDay == 27 then
			dayToCancel = {false, true}
		end
		LocalNotificationManager.getInstance():cancelMarkNotificationToday(dayToCancel)
	end
end

-- fix 
function MarkModel:onEnterHandler(event)
end
-- end fix