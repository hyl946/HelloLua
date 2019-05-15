VerticalTileItem = class(BaseUI)

function VerticalTileItem:ctor()
	-- BaseUI.init(self, ui)
	self.name = 'VerticalTileItem'
	self.debugTag = 1
end

function VerticalTileItem:init( ui)
	-- self.width = width
	-- self.height = height
	self.arrayIndex = 1

	self.content = nil
	BaseUI.init(self, ui)
end

function VerticalTileItem:setArrayIndex(arrayIndex)
	assert(arrayIndex > 0)
	self.arrayIndex = arrayIndex
end

function VerticalTileItem:getArrayIndex()
	return self.arrayIndex
end

function VerticalTileItem:setContent(uiContent)
	if uiContent then
		self.content = uiContent
		self:addChild(uiContent)
		self:setHeight(uiContent:getGroupBounds().size.height)
	end
end

function VerticalTileItem:removeContent()
	if self.content and self:getParent() then
		self.content:removeFromParentAndCleanup(true)
		self.content = nil
	end
end

function VerticalTileItem:setHeight(height)
	self.height = height
end

function VerticalTileItem:getHeight()
	return self.height or self:getGroupBounds().size.height
end

function VerticalTileItem:dispose()
	self.arrayIndex = nil
	self.content = nil
	CocosObject.dispose(self)
end
