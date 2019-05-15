local SelectShareWay = class(BasePanel)

function SelectShareWay:create(shareUi, hideWeixin, hideFriendCircle) --shareUi: 要分享的内容的Layer
	assert(type(shareUi)=="table" or type(shareUi)=="userdata")
	local panel = SelectShareWay.new()
	panel:loadRequiredResource("ui/SelectShareWayPanel2.json")
    panel:init(shareUi, hideWeixin, hideFriendCircle)
    return panel
end

function SelectShareWay:init(shareUi, hideWeixin, hideFriendCircle)
	self.shareUi = shareUi
	self.shareTitleName = ""
	self.shareType = SnsUtil.getShareType()
	self.sharePictureUtil = (require "zoo.panel.share.sharePanelVerB.components.SharePicture").new()
	self:initUi(hideWeixin, hideFriendCircle)
end

function SelectShareWay:initUi(hideWeixin, hideFriendCircle)
	self.ui = self:buildInterfaceGroup("2019_04_share_advance_selectshareway/select")

	self.saveBtn = self.ui:getChildByName("share_save")
	self.weixinBtn = self.ui:getChildByName("share_weixin")
	self.friendCircleBtn = self.ui:getChildByName("share_friendcircle")
	self.ui:getChildByPath("share_save/txt"):setString("保存到手机")
	self.ui:getChildByPath("share_weixin/txt"):setString("微信好友")
	self.ui:getChildByPath("share_friendcircle/txt"):setString("朋友圈")
	self.hideWeixin = hideWeixin
	self.hideFriendCircle = hideFriendCircle

	if hideWeixin or hideFriendCircle then
		local panelSize = self.ui:getGroupBounds().size
		local buttonWidth = self.saveBtn:getGroupBounds().size.width
		local buttonCenterDistance = (panelSize.width - buttonWidth) / 2
		if hideWeixin and hideFriendCircle then
			-- 隐藏两个按钮
			local saveBtnPositionX = self.saveBtn:getPositionX()
			self.saveBtn:setPositionX(saveBtnPositionX + buttonCenterDistance)
			self.weixinBtn:setVisible(false)
			self.friendCircleBtn:setVisible(false)
		else
			-- 隐藏一个按钮
			local saveBtnPositionX = self.saveBtn:getPositionX()
			self.saveBtn:setPositionX(saveBtnPositionX + buttonCenterDistance / 2)
			if hideWeixin then
				local circleBtnPositionX = self.friendCircleBtn:getPositionX()
				self.friendCircleBtn:setPositionX(circleBtnPositionX - buttonCenterDistance / 2)
				self.weixinBtn:setVisible(false)
			else
				local weixinBtnPositionX = self.weixinBtn:getPositionX()
				self.weixinBtn:setPositionX(weixinBtnPositionX + buttonCenterDistance / 2)
				self.friendCircleBtn:setVisible(false)
			end
		end
	end

	UIUtils:setTouchHandler(self.ui:getChildByPath("share_save"), function () self:onSaveBtn() end)
	if not self.hideWeixin then
		UIUtils:setTouchHandler(self.ui:getChildByPath("share_weixin"), function () self:onWeixinBtn() end)
	end
	if not self.hideFriendCircle then
		UIUtils:setTouchHandler(self.ui:getChildByPath("share_friendcircle"), function () self:onFriendCircleBtn() end)
	end
	
	self.allowBackKeyTap = false

	-- local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	-- local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	-- self.ui:setPositionX(visibleOrigin.x + (visibleSize.width - self.panelSize.width)/2)
	-- self.ui:setPositionY(self.panelSize.height - visibleSize.height)
end

function SelectShareWay:setSaveBtnAction(action)
	-- return isExit
	self._onSaveBtn = action
end

function SelectShareWay:setWeixinBtnAction(action)
	-- return isExit
	self._onWeixinBtn = action
end

function SelectShareWay:setFriendCircleBtnAction(action)
	-- return isExit
	self._onFriendCircleBtn = action
end

function SelectShareWay:setSaveBtnCallback(cb)
	--[[
		cb.onSuccess = function (path) ... end
		cb.onError = function (code, msg) ... end
		cb.onCancel = function () ... end
	]]
	self._onSaveBtnCb = cb
end

function SelectShareWay:setWeixinBtnCallback(cb)
	--[[
		cb.onSuccess = function(result) ... end
		cb.onError = function (code, msg) ... end
		cb.onCancel = function () ... end
	]]
	self._onWeixinBtnCb = cb
end

function SelectShareWay:setFriendCircleBtnCallback(cb)
	--[[
		cb.onSuccess = function(result) ... end
		cb.onError = function (code, msg) ... end
		cb.onCancel = function () ... end
	]]
	self._onFriendCircleBtnCb = cb
end

function SelectShareWay:onSaveBtn()
	if self.saveRunning then return end

	if self._onSaveBtn then self:_onSaveBtn() end
	
	local cb = {
		onSuccess = function (path)
			self.saveRunning = false
			local inner = self._onSaveBtnCb
			if inner then inner = inner.onSuccess end
			if inner then inner(path) end
		end,
		onError = function (code, msg)
			self.saveRunning = false
			local inner = self._onSaveBtnCb
			if inner then inner = inner.onError end
			if inner then inner(code, msg) end
		end,
		onCancel = function ()
			self.saveRunning = false
			local inner = self._onSaveBtnCb
			if inner then inner = inner.onCancel end
			if inner then inner() end
		end
	}

    self.saveRunning = true
    self.sharePictureUtil:captureSharePictureAndSaveToAlbum(self.shareUi, cb) 
end

function SelectShareWay:onWeixinBtn()
	if self._onWeixinBtn then self:_onWeixinBtn() end

	local path, thumb = self.sharePictureUtil:captureShareAndThumb(self.shareUi, true)

    local shareType = PlatformShareEnum.kWechat
    if self.shareType == PlatformShareEnum.kJPWX then
        shareType = self.shareType
    end
    if __ANDROID then
        AndroidShare.getInstance():registerShare(shareType)
    end
    SnsUtil.sendImageMessage(shareType, self.shareTitleName, self.shareTitleName, thumb, path, self._onWeixinBtnCb, false)
end

function SelectShareWay:onFriendCircleBtn()
	if self._onFriendCircleBtn then self:_onFriendCircleBtn() end 

	local path, thumb = self.sharePictureUtil:captureShareAndThumb(self.shareUi, true)

    local shareType = PlatformShareEnum.kWechat
    if self.shareType == PlatformShareEnum.kJPWX then
        shareType = self.shareType
    end
    if __ANDROID then
        AndroidShare.getInstance():registerShare(shareType)
    end
    SnsUtil.sendImageMessage(shareType, self.shareTitleName, self.shareTitleName, thumb, path, self._onFriendCircleBtnCb, true)
end


return SelectShareWay
