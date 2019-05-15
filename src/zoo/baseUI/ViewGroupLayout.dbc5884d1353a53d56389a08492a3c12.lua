---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-10-27 10:36:36
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-11-18 10:42:27
---------------------------------------------------------------------------------------
--[[
定位点(0,0)的位置
                  ^
                  ^
   kBottomRight   ^	    kBottomLeft
                  ^
< < < < < < < < (0,0) > > > > > > > >
				  v
 	kTopRight	  v   	 kTopLeft
				  v
				  v
]]--
ViewGroupLayout = class(CocosObject)

ViewGroupLayoutOrientation = {
	kHorizontal = 1,
	kVertical = 2,
}

ViewGroupLayoutAlignment = {
	kTopLeft = 1,
	kTopRight = 2,
	kBottomLeft = 3,
	kBottomRight = 4,
}

local vSize = Director.sharedDirector():getVisibleSize()

function ViewGroupLayout:ctor()
	self._orizontal = true

	self._alignment = ViewGroupLayoutAlignment.kTopLeft
	self._alignTop = true
	self._alignLeft = true

	self.maxHeight = vSize.height
	self.maxWidth = vSize.width

	self.viewList = {}

	self.viewItemMargin = ViewGroupLayout:createMargin(0, 0, 0, 0)
	self.fixedViewSize = nil

	self.startPosX = 0
	self.startPoxY = 0

	self.isNeedUpdate = false
end

function ViewGroupLayout:init(orientation, alignment)
	self:setOrientation(orientation)
	self:setAlignment(alignment)
end

function ViewGroupLayout:_updateLayout()
	for _, view in ipairs(self.viewList) do
		if view.isDisposed then 
			self:removeViewItem(view)
		end
	end

	if self.isNeedUpdate then
		if self._orizontal then
			self:_layoutViewAsRow(self.viewList)
		else
			self:_layoutViewAsCol(self.viewList)
		end
		self.isNeedUpdate = false
	end
end

function ViewGroupLayout:_layoutViewAsRow(viewList)
	local offsetPosX = self.startPosX
	local offsetPosY = self.startPoxY
	local rowMaxHeight = 0
	for _, view in ipairs(viewList) do
		local viewSize = self.fixedViewSize or view:getGroupBounds(view).size
		local posX = 0
		local posY = 0
		if math.abs(offsetPosX - self.startPosX) + self.viewItemMargin.left + self.viewItemMargin.right + viewSize.width > self.maxWidth then
			offsetPosX = self.startPosX
			if self._alignTop then
				offsetPosY = offsetPosY - self.viewItemMargin.top - self.viewItemMargin.bottom - rowMaxHeight
			else
				offsetPosY = offsetPosY + self.viewItemMargin.top + self.viewItemMargin.bottom + rowMaxHeight
			end
			rowMaxHeight = 0
		end
		if self._alignLeft then
			posX = offsetPosX + self.viewItemMargin.left + viewSize.width / 2
			offsetPosX = offsetPosX + self.viewItemMargin.left + self.viewItemMargin.right + viewSize.width
		else
			posX = offsetPosX - self.viewItemMargin.right - viewSize.width / 2
			offsetPosX = offsetPosX - self.viewItemMargin.left - self.viewItemMargin.right - viewSize.width
		end
		if self._alignTop then
			posY = offsetPosY - self.viewItemMargin.top - viewSize.height / 2
		else
			posY = offsetPosY + self.viewItemMargin.bottom + viewSize.height / 2
		end
		if rowMaxHeight < viewSize.height then
			rowMaxHeight = viewSize.height
		end

		local adjustX = view._layout_adjustX or 0
		local adjustY = view._layout_adjustY or 0

		view:setPosition(ccp(posX+adjustX, posY+adjustY))
	end
end

function ViewGroupLayout:_layoutViewAsCol(viewList)
	local offsetPosX = self.startPosX
	local offsetPosY = self.startPoxY
	local colMaxWidth = 0
	for _, view in ipairs(viewList) do
		local viewSize = self.fixedViewSize or view:getGroupBounds(view).size
		local posX = 0
		local posY = 0

		if math.abs(offsetPosY - self.startPoxY) + self.viewItemMargin.top + self.viewItemMargin.bottom + viewSize.height > self.maxHeight then
			offsetPosY = self.startPoxY
			if self._alignLeft then
				offsetPosX = offsetPosX + self.viewItemMargin.left + self.viewItemMargin.right + colMaxWidth
			else
				offsetPosX = offsetPosX - self.viewItemMargin.left - self.viewItemMargin.right - colMaxWidth
			end
			colMaxWidth = 0
		end

		if self._alignLeft then
			posX = offsetPosX + self.viewItemMargin.left + viewSize.width / 2
		else
			posX = offsetPosX - self.viewItemMargin.right - viewSize.width / 2
		end
		if self._alignTop then
			posY = offsetPosY - self.viewItemMargin.top - viewSize.height / 2
			offsetPosY = offsetPosY - self.viewItemMargin.top - self.viewItemMargin.bottom - viewSize.height
		else
			posY = offsetPosY + self.viewItemMargin.bottom + viewSize.height / 2
			offsetPosY = offsetPosY + self.viewItemMargin.top + self.viewItemMargin.bottom + viewSize.height
		end

		if colMaxWidth < viewSize.width then
			colMaxWidth = viewSize.width
		end

		local adjustX = view._layout_adjustX or 0
		local adjustY = view._layout_adjustY or 0
		view:setPosition(ccp(posX+adjustX, posY+adjustY))
	end
end

function ViewGroupLayout:_insertViewItem(view, index)
	local oIdx = table.indexOf(self.viewList, view)
	if oIdx then
		table.remove(self.viewList, oIdx)
	end
	if type(index) == "number" then
		if index < 1 then
			index = 1
		end
		if index > #self.viewList + 1 then
			index = #self.viewList + 1
		end
	else
		index = #self.viewList + 1
	end
	index = #self.viewList + 1
	table.insert(self.viewList, index, view)

	if not view:getParent() then
		self:addChild(view)
	end
	self.isNeedUpdate = true
end

function ViewGroupLayout:createMargin(top, left, bottom, right)
	return {top = top or 0, left = left or 0, bottom = bottom or 0, right = right or 0}
end

function ViewGroupLayout:setViewItemMargin(top, left, bottom, right)
	self.viewItemMargin = ViewGroupLayout:createMargin(top, left, bottom, right)
end

function ViewGroupLayout:setFixedViewSize(size)
	if size then
		self.fixedViewSize = {width = size.width, height = size.height}
	else
		self.fixedViewSize = nil
	end
end

function ViewGroupLayout:setOrientation(orientation)
	if orientation == ViewGroupLayoutOrientation.kHorizontal then
		if not self._orizontal then self.isNeedUpdate = true end
		self._orizontal = true
	elseif orientation == ViewGroupLayoutOrientation.kVertical then
		if self._orizontal then self.isNeedUpdate = true end
		self._orizontal = false
	end
end

function ViewGroupLayout:setAlignment(alignment)
	if not table.exist(ViewGroupLayoutAlignment, alignment) then return end

	if alignment ~= self._alignment then self.isNeedUpdate = true end
	self._alignment = alignment

	if alignment == ViewGroupLayoutAlignment.kTopLeft then
		self._alignTop = true
		self._alignLeft = true
	elseif alignment == ViewGroupLayoutAlignment.kTopRight then
		self._alignTop = true
		self._alignLeft = false
	elseif alignment == ViewGroupLayoutAlignment.kBottomLeft then
		self._alignTop = false
		self._alignLeft = true
	elseif alignment == ViewGroupLayoutAlignment.kBottomRight then
		self._alignTop = false
		self._alignLeft = false
	end
end

function ViewGroupLayout:addViewItemList(viewList)
	if not viewList then return end
	for _, view in ipairs(viewList) do
		self:_insertViewItem(view)
	end

	self:_updateLayout()
end

function ViewGroupLayout:addViewItem(view, index)
	if not view then return end
	self:_insertViewItem(view, index)

	self:_updateLayout()
end

function ViewGroupLayout:getViewItemIndex(view)
	return table.indexOf(self.viewList, view)
end

function ViewGroupLayout:removeViewItem(view, cleanup)
	local index = table.indexOf(self.viewList, view)
	if index then
		table.remove(self.viewList, index)
		self.isNeedUpdate = true
	end
	if view and view:getParent() then
		view:removeFromParentAndCleanup(cleanup)
	end

	self:_updateLayout()
end

function ViewGroupLayout:setMaxHeight(maxHeight)
	self.maxHeight = maxHeight
end

function ViewGroupLayout:setMaxWidth(maxWidth)
	self.maxWidth = maxWidth
end

function ViewGroupLayout:create(orientation, alignment)
	local layout = ViewGroupLayout.new(CCNode:create())
	layout:init(orientation, alignment)
	return layout
end