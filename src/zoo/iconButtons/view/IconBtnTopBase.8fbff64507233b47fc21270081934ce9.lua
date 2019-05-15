
IconBtnTopBase = class(BaseUI)

function IconBtnTopBase:ctor()
	self.oriLabelScale = 1
	self.onTapCallback = false
	self.isPlayAni = false
	self.__isGroupButtonBase__ = true
end

function IconBtnTopBase:init(ui)
	BaseUI.init(self, ui)

	self.icon = self.ui:getChildByName("icon")
	self.iconImg = self.icon:getChildByName("bg")
	self.mainUI = self.ui:getChildByName("main")
	self.mask = self.mainUI:getChildByName("mask")

	local label = BitmapText:create("", self:getLabelFntDir())
	label:setAnchorPoint(ccp(0.5, 0.5))
	local iconSize = self.iconImg:getContentSize()
	local maskSize = self.mask:getContentSize()
	self.labelMaxWidth = maskSize.width - iconSize.width/2 - self:getPlusIconWidth() - 8
    self.mask:addChild(label)
    label:setPosition(ccp(iconSize.width/2 + self.labelMaxWidth/2, maskSize.height/2))
    self.label = label

	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, function (evt)
		self:onIconBtnTap()
	end)
end

function IconBtnTopBase:setOnTappedCallback(callback)
	self.onTapCallback = callback
end

function IconBtnTopBase:onIconBtnTap()
	if self.isPlayAni then return end
	if self.onTapCallback then
		self.onTapCallback() 
	end
end

function IconBtnTopBase:setIsPlayAni(isPlay)
	self.isPlayAni = isPlay
end

function IconBtnTopBase:setLabel(label)
	self.label:setText(label)
	local labelSize = self.label:getContentSize()
	local labelScale = math.min(self.labelMaxWidth / labelSize.width * self.oriLabelScale, self.oriLabelScale)
	self.label:setScale(labelScale)
end

function IconBtnTopBase:getIconRes()
	return self.iconImg
end

function IconBtnTopBase:getIconGroup()
	return self.icon
end

function IconBtnTopBase:getBarGroup()
	return self.mainUI
end

function IconBtnTopBase:getFlyToPosition()
	local pos = self.iconImg:getPosition()
	local size = self.iconImg:getContentSize()
	return self.icon:convertToWorldSpace(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
end

function IconBtnTopBase:getFlyToSize()
	local size = self.iconImg:getGroupBounds().size
	return {width = size.width, height = size.height}
end

function IconBtnTopBase:updateView()
end

function IconBtnTopBase:setOriLabelScale(labelScale)
	self.oriLabelScale = labelScale
end

function IconBtnTopBase:getGroupSize()
	return self.ui:getGroupBounds().size
end

function IconBtnTopBase:getLabelFntDir()
	return "fnt/starScoreNumber.fnt"
end

function IconBtnTopBase:getPlusIconWidth()
	return 0
end