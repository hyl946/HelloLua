local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end
    return plistPath
end

AlertNewLevelPanel = class(BasePanel)

function AlertNewLevelPanel:create(level)
	local instance = AlertNewLevelPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.update_new_version_panel)
	instance:init(level)
	return instance
end

function AlertNewLevelPanel:init(level)

	self.name = 'AlertNewLevelPanel'

	local ui = self:buildInterfaceGroup('new/alertNewLevel')
	
	BasePanel.init(self, ui)

	local topLevelId = MetaManager:getInstance():getMaxNormalLevelByLevelArea()

	self.label = self.ui:getChildByName("label")
	self.label:setDimensions(CCSizeMake(self.label:getDimensions().width, 0))
	self.label:setString(localize('update_level_text', {level = topLevelId}))

	local height = self.label:getContentSize().height


	self.confirm = GroupButtonBase:create(self.ui:getChildByName("confirm"))
	self.confirm:setString(localize('update_level_text_button'))
	self.confirm:ad(DisplayEvents.kTouchTap, function()
		self:buildSharePicture(function(shareImagePath, thumbPath)
			self:shareAndClose(shareImagePath, thumbPath)
		end)
	end)

	self.closeBtn = self.ui:getChildByName('closeBtn')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function ()
		self:gotoUserMaxLevelAndClosePanel()
	end)

	self.ui:getChildByName('paopao'):setVisible(false)


	self:replaceObstacleIcon(level)
end

function AlertNewLevelPanel:replaceObstacleIcon(level)

	local oldAnimalIcon = self.ui:getChildByName('animal')
	local newAnimalIcon = self:createAreaIcon(level)

	if not newAnimalIcon then
		return
	end

	self.ui:getChildByName('paopao'):setVisible(true)

	local bounds = oldAnimalIcon:getGroupBounds(self.ui)
	local size = bounds.size
	-- local scale = size.width / newAnimalIcon:getContentSize().width * 0.90
	newAnimalIcon:setScale(0.75)

	newAnimalIcon:setAnchorPoint(ccp(0.5, 0.5))
	newAnimalIcon:setPosition(ccp(222, -340))

	local index = self.ui:getChildIndex(oldAnimalIcon)
	self.ui:addChildAt(newAnimalIcon, index)
	oldAnimalIcon:removeFromParentAndCleanup(true)

end

function AlertNewLevelPanel:gotoUserMaxLevelAndClosePanel()
	self:close()
	HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter()
end

function AlertNewLevelPanel:buildSharePicture(callback)
	local function onBuild(userHeadImageAndName)
		if self.isDisposed then
			return
		end
		local bg = Sprite:create("share/newLevelAd.png")
		if _G.__use_small_res == true then
			bg:setScale(0.625)
		end
		local panel = Layer:create()
		bg:setAnchorPoint(ccp(0, 1))
		panel:addChild(bg)

		userHeadImageAndName:setPosition(ccp(109, -146))

		local animal = self:createAreaIcon() or Sprite:createWithSpriteFrameName('xiaoji0000')

		animal:setAnchorPoint(ccp(0.5, 0.5))
		animal:setScale(1.15)
		animal:setPosition(ccp(320, -550))
		panel:addChild(animal)

		panel:addChild(userHeadImageAndName)

		local size = bg:getContentSize()

		if _G.__use_small_res == true then
			size.width = size.width*0.625
			size.height = size.height*0.625
		end

		local shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
		panel:setPosition(ccp(0, size.height))
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
		panel:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(shareImagePath)

		local thumbScale = 256 / size.height
		local thumbPath = HeResPathUtils:getResCachePath() .. "/share_image_thumb.jpg"
		panel:setPosition(ccp(0, size.height * thumbScale))
		local renderTexture = CCRenderTexture:create(size.width*thumbScale , size.height*thumbScale)
		renderTexture:begin()
		panel:setScale(thumbScale)
		panel:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(thumbPath)

		callback(shareImagePath, thumbPath)
	end
	self:buildUserHeadImageAndName(onBuild)
end

function AlertNewLevelPanel:buildUserHeadImageAndName(callback)
	self:loadRequiredResource(PanelConfigFiles.update_new_version_panel)
	local ui = self:buildInterfaceGroup('head222')
	local nameLabel = ui:getChildByName('name')
	nameLabel:setDimensions(CCSizeMake(0, nameLabel:getDimensions().height))
	nameLabel:setString(nameDecode(UserManager:getInstance().profile.name))
	nameLabel:setPositionX((114-nameLabel:getContentSize().width)/2)

	local profile = UserManager.getInstance().profile
	local uid = UserManager.getInstance().uid
	local headUrl = profile and profile.headUrl or 1
	local function onImageLoadFinishCallback(headImage)
		if self.isDisposed then
			return
		end
		local placeHolder = ui:getChildByName('headImage')
		local scale = placeHolder:getContentSize().width / headImage:getContentSize().width
		headImage:setScale(scale)
		headImage:setAnchorPoint(ccp(-0.5, 0.5))
		headImage:setPosition(ccp(placeHolder:getPositionX(), placeHolder:getPositionY()))
		placeHolder:removeFromParentAndCleanup(true)
		ui:addChild(headImage)
		callback(ui)
	end
	HeadImageLoader:create(uid, headUrl, onImageLoadFinishCallback)
end

function AlertNewLevelPanel:shareAndClose(shareImagePath, thumbPath)
	if self.isDisposed then return end

	local shareCallback = {
		onSuccess = function(result)
			self:close()
		end,
		onError = function(errCode, errMsg)
			self:close()
		end,
		onCancel = function()
			self:close()
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
	end

	local title = ''
	local message = ''
	if shareImagePath then
		local shareType, delayResume = SnsUtil.getShareType()
		SnsUtil.sendImageMessage(shareType, title, message, thumbPath, shareImagePath, shareCallback, false)
	end
end

function AlertNewLevelPanel:popout(closeCallback)
	self.closeCallback = closeCallback
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local panelSize = self.ui:getChildByName('bg'):getContentSize()
    self:setPositionY( - (visibleSize.height - panelSize.height) /2 )
    self:setPositionX((visibleSize.width - panelSize.width)/2)
    PopoutQueue:sharedInstance():push(self, true, false)
end

function AlertNewLevelPanel:close()
	if not self.isDisposed then
		PopoutManager:sharedInstance():remove(self, true)
		if self.closeCallback then
			self.closeCallback()
		end
	end
end

function AlertNewLevelPanel:dispose()
	BasePanel.dispose(self)
end

function AlertNewLevelPanel:createAreaIcon( level )
	local level = level or UserManager:getInstance().user:getTopLevelId() + 1
	local index = math.ceil(level /15)

	local UIUtils = require 'zoo.panel.UIHelper'

	return UIUtils:safeCreateSpriteByFrameNameOrNil("area_icon_"..index.."0000")
end

function AlertNewLevelPanel:tryPopout(closeCallback)
	self:popout(closeCallback)
end

function AlertNewLevelPanel:canForcePop()
	local lastMaxLevel = AlertNewLevelPanel.getLastMaxLevel()
	local curMaxLevel = AlertNewLevelPanel.getCurrentMaxLevel()
	local userTopLevel = UserManager:getInstance().user:getTopLevelId()


	local ret = false
	if lastMaxLevel < curMaxLevel and not NewAreaOpenMgr.getInstance():isMaxLevelCountdown(curMaxLevel) then
		if userTopLevel == lastMaxLevel then
			if UserManager:getInstance():hasPassedLevel(userTopLevel) then
				ret = true
			end
			
			if UserManager.getInstance():hasPassedByTrick(userTopLevel) then
				ret = true
			end
		end
	end
	return ret
end

function AlertNewLevelPanel.isNeedPopout()
	local lastMaxLevel = AlertNewLevelPanel.getLastMaxLevel()
	local curMaxLevel = AlertNewLevelPanel.getCurrentMaxLevel()
	local userTopLevel = UserManager:getInstance().user:getTopLevelId()


	local ret = false
	if lastMaxLevel < curMaxLevel and not NewAreaOpenMgr.getInstance():isMaxLevelCountdown(curMaxLevel) then
		if userTopLevel == lastMaxLevel then
			if UserManager:getInstance():hasPassedLevel(userTopLevel) then
				ret = true
			else
			end
			if UserManager.getInstance():hasPassedByTrick(userTopLevel) then
				ret = true
			else
			end
		end
		AlertNewLevelPanel.setLastMaxLevel(curMaxLevel)
	elseif lastMaxLevel > curMaxLevel then
		AlertNewLevelPanel.setLastMaxLevel(curMaxLevel)
	end
	return ret
end

local kLastMaxLevel = 'LastMaxLevel'

function AlertNewLevelPanel.getLastMaxLevel()
	local lastMaxLevel = CCUserDefault:sharedUserDefault():getIntegerForKey(kLastMaxLevel)
	if lastMaxLevel == nil or lastMaxLevel == 0 then
		lastMaxLevel = AlertNewLevelPanel.getCurrentMaxLevel()
		AlertNewLevelPanel.setLastMaxLevel(lastMaxLevel)
	end
	return lastMaxLevel
end

function AlertNewLevelPanel.setLastMaxLevel(lastMaxLevel)
	CCUserDefault:sharedUserDefault():setIntegerForKey(kLastMaxLevel, lastMaxLevel)
end

function AlertNewLevelPanel.getCurrentMaxLevel()
	return kMaxLevels
end

function AlertNewLevelPanel.initCache()
	AlertNewLevelPanel.getLastMaxLevel()
end