
StarButtonTip = class(BaseUI)

function StarButtonTip:init()

	self.ui = ResourceManager:sharedInstance():buildGroup("newStarButtonTip")

	BaseUI.init(self, self.ui)

	self.normalStarLabel = self.ui:getChildByName("normalLabel")
	self.hiddenStarLabel = self.ui:getChildByName("hiddenLabel")
	self.bg = self.ui:getChildByName("bg")

	local normalStarLabelPos = self.normalStarLabel:getPosition()
	local hiddenStarLabelPos = self.hiddenStarLabel:getPosition()

	local labelCharWidth = 30
	local labelCharHeight = 30
	local labelCharInterval = 15

	local fntFile = "fnt/target_amount.fnt"
	self.normalStarLabel = LabelBMMonospaceFont:create(labelCharWidth, labelCharHeight, labelCharInterval, fntFile)
	self.normalStarLabel:setAnchorPoint(ccp(0, 1))
	self.normalStarLabel:setPosition(ccp(normalStarLabelPos.x, normalStarLabelPos.y))
	self.ui:addChild(self.normalStarLabel)

	self.hiddenStarLabel = LabelBMMonospaceFont:create(labelCharWidth, labelCharHeight, labelCharInterval, fntFile)
	self.hiddenStarLabel:setAnchorPoint(ccp(0, 1))
	self.hiddenStarLabel:setPosition(ccp(hiddenStarLabelPos.x, hiddenStarLabelPos.y))
	self.ui:addChild(self.hiddenStarLabel)

	self.labelOriginX = normalStarLabelPos.x
	self.maxLabelWidth = self.bg:getContentSize().width - self.labelOriginX - 10
end

function StarButtonTip:setContent(normalStar, hiddenStar, normalTotalStar, hiddenTotalStar)
	self.normalStarLabel:setString(normalStar .. "/" .. normalTotalStar)
	self.hiddenStarLabel:setString(hiddenStar .. "/" .. hiddenTotalStar)

	-- local largerWidth = math.max(self.normalStarLabel:getContentSize().width, self.hiddenStarLabel:getContentSize().width)
	-- local adjustCenterX = self.labelOriginX + (self.maxLabelWidth - largerWidth) / 2
	-- self.normalStarLabel:setPositionX(largerWidth - self.normalStarLabel:getContentSize().width + adjustCenterX)
	-- self.hiddenStarLabel:setPositionX(largerWidth - self.hiddenStarLabel:getContentSize().width + adjustCenterX)
	self.normalStarLabel:setPositionX((self.maxLabelWidth - self.normalStarLabel:getContentSize().width) / 2 + self.labelOriginX)
	self.hiddenStarLabel:setPositionX((self.maxLabelWidth - self.hiddenStarLabel:getContentSize().width) / 2 + self.labelOriginX)
end

function StarButtonTip:create()
	local v = StarButtonTip.new()
	v:init()
	return v
end
