
local LevelStrategyListItem = class(BaseUI)

function LevelStrategyListItem:init(ui)
	BaseUI.init(self, ui)

	self.userNameLabel	= self.ui:getChildByName("userNameLabel")
	self.goldCrown		= self.ui:getChildByName("goldCrown")
	self.userIconPlaceholder = self.ui:getChildByName("userIconPlaceholder")

	self.playBtn = self.ui:getChildByName("playBtn")
	self.playBtn:setTouchEnabled(true, 0, true)
	self.playBtn:setButtonMode(true)
	self.playBtn:addEventListener(DisplayEvents.kTouchTap,function()
		self:onPlayBtnTap()
	end)
end

function LevelStrategyListItem:update(userName, headUrl, btnTapCB)
	self.btnTapCB = btnTapCB
	local name = "村长"
	self.userNameLabel:setString(nameDecode(name))

	if self.headUrl ~= headUrl then
		self.headUrl = headUrl
		if headUrl ~= nil then
			if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
			local function onImageLoadFinishCallback(clipping)
				if not self.userIconPlaceholder or self.userIconPlaceholder.isDisposed then return end
				if self.headDisposed then return end
				-- local holderSize = self.userIconPlaceholder:getContentSize()
				local holderSize = CCSizeMake(50, 50)
				local clippSize = clipping:getContentSize()
				local scale = holderSize.width / clippSize.width

				local percent = 0.98
				local offsetX = 0

				clipping:setScale(scale*percent)
				clipping:setPosition(ccp(holderSize.width*0.5+offsetX , holderSize.height*0.5))
				self.clipping = clipping

				self.userIconPlaceholder:addChild(self.clipping)
			end
			HeadImageLoader:create(nil, headUrl, onImageLoadFinishCallback)
		else
			if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
			self.clipping = nil
		end
	end
end

function LevelStrategyListItem:onPlayBtnTap()
	if self.playBtn then self.playBtn:setTouchEnabled(false) end
	if self.btnTapCB then self.btnTapCB() end
end

function LevelStrategyListItem:create(ui)
	local item = LevelStrategyListItem.new()
	item:init(ui)
	return item
end

return LevelStrategyListItem
