require 'zoo.account.AccountBindingLogic'
local Input = require "zoo.panel.phone.Input"
local Title = require "zoo.panel.phone.Title"
local Button = require "zoo.panel.phone.Button"

SelectLoginPanel = class(BasePanel)

function SelectLoginPanel:create(phoneLoginInfo, context)
	local panel = SelectLoginPanel.new()
	panel:loadRequiredResource("ui/login.json")	
	panel:init(phoneLoginInfo, context)
	return panel
end


function SelectLoginPanel:init(phoneLoginInfo, context)
	self.phoneLoginInfo = phoneLoginInfo
	self.context = context

	self.ui = self:buildInterfaceGroup("SelectLoginPanel")
	BasePanel.init(self, self.ui)

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()
	self.size = bounds.size

	local title = Title:create(self.ui:getChildByName("title"),false)
	title:setTextMode(phoneLoginInfo.mode,true)--"账号登陆"
	-- title:addEventListener(Title.Events.kBackTap,function( ... )
	-- 	self:onKeyBackClicked()
	-- end)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	local icons = {}
	-- 
	local authConfigs = {}
	for _,v in pairs(PlatformConfig:getAuthConfigs()) do
		if v ~= PlatformAuthEnum.kGuest then
			table.insert(authConfigs,v) 
		end
	end


	for _,v in pairs(PlatformConfig:getExtraLoginAuthConfigs()) do
		if v ~= PlatformAuthEnum.kGuest then
			table.insertIfNotExist(authConfigs,v) 
		end
	end

	if PlatformConfig:isQQPlatform() and MaintenanceManager:getInstance():isEnabled("DisableForbidPhoneLogin", true) then
		table.removeValue(authConfigs, PlatformAuthEnum.kPhone)
	end

	local wechatIndex = table.indexOf(authConfigs, PlatformAuthEnum.kWechat)
	if wechatIndex and not (SnsProxy:isWXAppInstalled() and SnsProxy:isOSSupportWXLogin()) then
		table.remove(authConfigs, wechatIndex)
	end

    table.sort(authConfigs,function(a,b) return SelectLoginPriority[a] < SelectLoginPriority[b] end)

	local bigIconContainer = self.ui:getChildByName("bigIconContainer")
	local oneMiniIconContainer = self.ui:getChildByName("oneMiniIconContainer")
	local twoMiniIconContainer = self.ui:getChildByName("twoMiniIconContainer")
	local threeMiniIconContainer = self.ui:getChildByName("threeMiniIconContainer")

	bigIconContainer:setChildrenVisible(false,false)
	oneMiniIconContainer:setChildrenVisible(false,false)
	twoMiniIconContainer:setChildrenVisible(false,false)
	threeMiniIconContainer:setChildrenVisible(false,false)

	local function buildIcon( isBig,authorType,boundingBox )
		local icon = nil
		if isBig then
			if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) and
				authorType == PlatformAuthEnum.kMI then
				icon = self:buildInterfaceGroup("login/icon/icon_" .. PlatformAuthDetail[authorType].name .. "_2")
			else
				icon = self:buildInterfaceGroup("login/icon/icon_" .. PlatformAuthDetail[authorType].name)
			end
		else
			icon = self:buildInterfaceGroup("login/icon/mini_icon_" .. PlatformAuthDetail[authorType].name)
		end
		icon:setPositionX(boundingBox:getMidX())
		icon:setPositionY(boundingBox:getMidY())
		if isBig then
			icon.rightX = boundingBox:getMaxX() - 36
			icon.topY = boundingBox:getMaxY()
		else
			icon.rightX = boundingBox:getMaxX() - 57
			icon.topY = boundingBox:getMaxY() + 40
			icon.isSmall = true
		end

		icon:setTouchEnabled(true)
		icon:setButtonMode(true)
		icon:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:onLoginIconTap(authorType)
		end)
		if authorType == PlatformAuthEnum.kPhone then self.phoneAuthIcon = icon end
		if authorType == PlatformAuthEnum.kQQ then self.qqAuthIcon = icon end
		if authorType == PlatformAuthEnum.k360 then self.qihooAuthIcon = icon end
		if authorType == PlatformAuthEnum.kWechat then self.wechatAuthIcon = icon end
		icons[authorType] = icon
		if isBig then
			self.bigAuthIcon = icon
		end
		self.ui:addChild(icon)
	end
	
	local boundingBox = bigIconContainer:getChildByName("1"):boundingBox()
	buildIcon(true,authConfigs[1],boundingBox)

	if #authConfigs == 2 then
		local boundingBox = oneMiniIconContainer:getChildByName("1"):boundingBox()
		buildIcon(false,authConfigs[2],boundingBox)
	elseif #authConfigs == 3 then
		for i=2,3 do
			local boundingBox = twoMiniIconContainer:getChildByName(tostring(i-1)):boundingBox()
			buildIcon(false,authConfigs[i],boundingBox)
		end
	elseif #authConfigs > 3 then
		for i=2,4 do
			local boundingBox = threeMiniIconContainer:getChildByName(tostring(i-1)):boundingBox()
			buildIcon(false,authConfigs[i],boundingBox)
		end
	end

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	self.position = ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	)
	self:setPositionX(self.position.x)
	self:setPositionY(self.position.y)

	self:hideRewardTip()
	self:hideRecommandTip()
	self:hideRecommandTopLevelTip()

	if AccountBindingLogic:isQQNotRecommand() and not PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		local loginInfos = DeviceLoginInfos:getCurrentServerLoginInfos()
		local loginTypes = loginInfos and loginInfos.otherSnsPlatforms or {}
		if table.size(loginTypes) > 0 then
			local rmdAuthType = nil
			for i, authType in ipairs(authConfigs) do
				local authName = PlatformConfig:getPlatformAuthName( authType )
				if authName and table.includes(loginTypes, authName) then
					rmdAuthType = authType
					break
				end
			end
			if rmdAuthType and icons[rmdAuthType] then
				local authIcon = icons[rmdAuthType]
				local topLevelId = loginInfos.topLevelId
				local pos = authIcon:getPosition()
				local size = authIcon:getGroupBounds(self.ui).size
				if authIcon == self.bigAuthIcon then
					self:showRecommandTopLevelTip(topLevelId, ccp(pos.x + 50, pos.y + 67), 1)
				else
					self:showRecommandTopLevelTip(topLevelId, ccp(pos.x + 20, pos.y + 20), 0.75)
				end
			end
		else
			if self.wechatAuthIcon and self.bigAuthIcon ~= self.wechatAuthIcon then
				local pos = self.wechatAuthIcon:getPosition()
				local size = self.wechatAuthIcon:getGroupBounds(self.ui).size
				self:showRecommandTip(ccp(pos.x + 15, pos.y + 20))
			end
		end
	elseif not self.context.isChangingAccount then
		if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
			if BindQihooBonus:loginRewardEnabled(true) and self.qihooAuthIcon ~= nil then 
				self.rewardAuthIcon = self.qihooAuthIcon
				self:showRewardTip()
			end
		else
			if BindPhoneBonus:loginRewardEnabled(true) and self.phoneAuthIcon ~= nil then
				self.rewardAuthIcon = self.phoneAuthIcon
				self:showRewardTip()
			elseif BindQQBonus:loginRewardEnabled(true) and self.qqAuthIcon ~= nil then 
				self.rewardAuthIcon = self.qqAuthIcon
				self:showRewardTip()
			end
		end
	end
end

function SelectLoginPanel:showRecommandTip(pos)
	local tipNode = self:buildInterfaceGroup("login/rmd_login_type")
	if tipNode then
		self.rmdLoginTypeTip = tipNode
		if pos then
			tipNode:setPosition(pos)
		end
		self.ui:addChild(tipNode)
	end
end

function SelectLoginPanel:hideRecommandTip()
	if self.rmdLoginTypeTip then 
		self.rmdLoginTypeTip:removeFromParentAndCleanup(true)
		self.rmdLoginTypeTip = nil
	end
end

function SelectLoginPanel:showRecommandTopLevelTip(topLevel, pos, scale)
	local tipNode = self:buildInterfaceGroup("login/rmd_login_type_toplevel")
	if tipNode then
		tipNode:setScale(scale or 1)
		self.rmdLoginTypeTopLevelTip = tipNode
		if pos then
			tipNode:setPosition(pos)
		end
		local textLabel = tipNode:getChildByName("text")
		textLabel:changeFntFile("fnt/register2.fnt")
		textLabel:setText(topLevel.."关")
		textLabel:setScale(0.9)
		textSize = textLabel:getGroupBounds(tipNode).size
		textLabel:setPositionXY((117-textSize.width)/2, textLabel:getPositionY() - 5)
		self.ui:addChild(tipNode)
	end
end

function SelectLoginPanel:hideRecommandTopLevelTip()
	if self.rmdLoginTypeTopLevelTip then 
		self.rmdLoginTypeTopLevelTip:removeFromParentAndCleanup(true)
		self.rmdLoginTypeTopLevelTip = nil
	end
end

function SelectLoginPanel:hideRewardTip()
	local loginRewardTip = self.ui:getChildByName("loginRewardTip")
	if loginRewardTip then
		loginRewardTip:setVisible(false)
	end
end

function SelectLoginPanel:showRewardTip()
	local loginRewardTip = self.ui:getChildByName("loginRewardTip")
	loginRewardTip:setVisible(true)
	if self.rewardAuthIcon.isSmall then
		loginRewardTip:setScale(0.7)
	end
	loginRewardTip:setPositionXY(self.rewardAuthIcon.rightX + 18, self.rewardAuthIcon.topY - 45)
	local icon = loginRewardTip:getChildByName("icon")
	local iconSize = icon:getGroupBounds().size
	local iconPos = icon:getPosition()

	local rewardId, rewardNum
	if self.rewardAuthIcon == self.qqAuthIcon then
		rewardId, rewardNum = BindQQBonus:getBindRewards()
	elseif self.rewardAuthIcon == self.phoneAuthIcon then
		rewardId, rewardNum = BindPhoneBonus:getBindRewards()
	elseif self.rewardAuthIcon == self.qihooAuthIcon then
		rewardId, rewardNum = BindQihooBonus:getBindRewards()
	end

	local itemIcon = ResourceManager:sharedInstance():buildItemGroup(rewardId)
	local itemIconWidth = itemIcon:getGroupBounds().size.width
	if self.rewardAuthIcon.isSmall then
		itemIcon:setScale(0.5)
	else
		itemIcon:setScale(iconSize.width / itemIconWidth)
	end
	itemIcon:setPosition(ccp(iconPos.x, iconPos.y))
	loginRewardTip:addChild(itemIcon)

	local fntFile = "fnt/target_amount.fnt"
    local numTf = BitmapText:create('', fntFile)
    numTf:setAnchorPoint(ccp(0.5, 0.5))
    numTf:setText('x' .. rewardNum)
    numTf:setPreferredSize(40, 12)
    numTf:setPositionXY(iconPos.x + itemIconWidth - 56, iconPos.y - 36)
	loginRewardTip:addChild(numTf)

	icon:removeFromParentAndCleanup(true)
	loginRewardTip:removeFromParentAndCleanup(false)
	self.ui:addChild(loginRewardTip) -- change z index
end

function SelectLoginPanel:onLoginIconTap( authEnum )
	if authEnum == PlatformAuthEnum.kPhone then
		local panel = PhoneLoginPanel:create(self.phoneLoginInfo, AccountBindingSource.FROM_LOGIN)
		panel:setPhoneLoginCompleteCallback(self.phoneLoginCompleteCallback)
		panel:popout()
	else
		PopoutStack:clear()
		if self.selectCallback then 
			self.selectCallback(authEnum)
		end
	end
end

function SelectLoginPanel:popout( ... )
	PopoutStack:push(self,true,false)
end

function SelectLoginPanel:remove( ... )
	if self.backCallback then 
		PopoutStack:clear()
		self.backCallback()
	else
		PopoutStack:pop()
	end
end

function SelectLoginPanel:onKeyBackClicked()
	self:remove()
end

function SelectLoginPanel:setSelectSnsCallback( selectCallback )
	self.selectCallback = selectCallback
end
function SelectLoginPanel:setPhoneLoginCompleteCallback( phoneLoginCompleteCallback )
	self.phoneLoginCompleteCallback = phoneLoginCompleteCallback
end
function SelectLoginPanel:setBackCallback( backCallback )
	self.backCallback = backCallback
end