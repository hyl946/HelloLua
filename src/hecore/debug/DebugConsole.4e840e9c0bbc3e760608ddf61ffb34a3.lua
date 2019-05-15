DebugConsole = class(CocosObject)

function DebugConsole:ctor()
	self.width = 400
	self.height = 300
	self.bgColor = {r=255, g=255, b=255}
	self.bgOpacity = 255 * 0.6
	self.fontColor = {r=64, g=64, b=64}
	self.fontSize = 24
	self.enabled = false
	self.isShow = false
	self.textNodes = {}
end

function DebugConsole:init(width, height)
	if type(width) == "number" then self.width = width end
	if type(height) == "number" then self.height = height end
	self.bgLayer = LayerColor:createWithColor(ccc3(self.bgColor.r, self.bgColor.g, self.bgColor.b), self.width, self.height)
	self.bgLayer:setOpacity(self.bgOpacity)
	-- self.bgLayer:setTouchEnabled(true, 0, true)
	self:addChild(self.bgLayer)
	
	self.clippingNode = SimpleClippingNode:create()
	self.clippingNode:setContentSize(CCSizeMake(self.width, self.height))
	self:addChild(self.clippingNode)
	
	self.infoLayer =  Layer:create()
	self.infoLayer:changeWidthAndHeight(self.width, self.height)
	self.clippingNode:addChild(self.infoLayer)
end

function DebugConsole:create(width, height)
	local node = DebugConsole.new(CCNode:create())
	node:init(width, height)
	return node
end

function DebugConsole:setBgColor(color, opacity)
	self.bgColor = {r=color.r, g=color.g, b=color.b}
	if opacity then self.bgOpacity = opacity end
	if self.bgLayer then
		self.bgLayer:setColor(ccc3(self.bgColor.r, self.bgColor.g, self.bgColor.b))
		self.bgLayer:setOpacity(self.bgOpacity)
	end
end

function DebugConsole:setFontColor(color)
	self.fontColor = {r=color.r, g=color.g, b=color.b}
	for _, v in ipairs(self.textNodes) do
		v:setColor(ccc3(self.fontColor.r, self.fontColor.g, self.fontColor.b))
	end
end

function DebugConsole:setFontSize(fontSize)
	self.fontSize = fontSize
end

function DebugConsole:updateTextUI()
	local newNodes = {}
	local totalHeight = 0
	for i, v in ipairs(self.textNodes) do
		if v:getParent() then
			v:removeFromParentAndCleanup(false)
		end
		if totalHeight < self.height then
			newNodes[i] = v
			v:setPositionX(5)
			v:setPositionY(totalHeight)
			self.infoLayer:addChild(v)
			totalHeight = totalHeight + v:getContentSize().height
		else
			v:dispose()
		end
	end
	self.textNodes = newNodes
end

function DebugConsole:addLog(info)
	if not self:isEnable() then return end
	local text = TextField:create(tostring(info), nil, self.fontSize, CCSizeMake(self.width - 10, 0))
  	text:ignoreAnchorPointForPosition(false)
  	text:setAnchorPoint(ccp(0,0))
	text:setColor(ccc3(self.fontColor.r, self.fontColor.g, self.fontColor.b))
  	table.insert(self.textNodes, 1, text)
  	self:updateTextUI()
end

function DebugConsole:clear()
	for _, v in ipairs(self.textNodes) do
		v:removeFromParentAndCleanup(true)
	end
	self.textNodes = {}
end

function DebugConsole:show()
	if self:isEnable() then
		self:setVisible(true)
	end
end

function DebugConsole:hide()
	self:setVisible(false)
end

function DebugConsole:isEnable()
	return self.enabled
end

function DebugConsole:setEnable(enabled)
	self.enabled = enabled
end