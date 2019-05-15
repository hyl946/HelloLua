DynamicLoadLayoutRender= class()

-- const
function DynamicLoadLayoutRender:getColumnNum()
	return 1
end

-- const
function DynamicLoadLayoutRender:getItemSize()
	assert(false)
	return nil
end

function DynamicLoadLayoutRender:getVisibleHeight()
	assert(false)
	return 0
end

function DynamicLoadLayoutRender:getPreloadRow()
	return 2
end

function DynamicLoadLayoutRender:getOriginPosY()
	return 0
end

function DynamicLoadLayoutRender:buildItemView(data, index)
	assert(false)
	return nil
end

function DynamicLoadLayoutRender:onItemViewDidAdd(view, data)
end

function DynamicLoadLayoutRender:onItemViewDidRemove(view, data)
end

function DynamicLoadLayoutRender:buildMoveToAnimation(view, toPos)
	local moveTo = CCMoveTo:create(0.4, toPos)
	local ease = CCEaseSineOut:create(moveTo)
	return ease
end

function DynamicLoadLayoutRender:buildRemoveItemAnimation(view)
	item:setCascadeOpacityEnabled(true)
	local pos = item:getPosition()
	local size = item:getGroupBounds().size
	local destX = pos.x + size.width / 2
	local destY = pos.y
	local moveTo = CCMoveTo:create(0.4 - 0.05, ccp(destX, destY))
	local scaleTo = CCScaleTo:create(0.4 - 0.05, 0)
	local a_actions = CCArray:create()
	a_actions:addObject(moveTo)
	a_actions:addObject(scaleTo)
	local spawn = CCSpawn:create(a_actions)
	local ease = CCEaseSineIn:create(spawn)
	return ease
end

function DynamicLoadLayoutRender:builAddItemAnimation(view)
	local fadeIn = CCFadeIn:create(0.4)
	local scaleTo = CCScaleTo:create(0.4, 1)
	local a_actions = CCArray:create()
	a_actions:addObject(fadeIn)
	a_actions:addObject(scaleTo)
	local spawn = CCSpawn:create(a_actions)
	local ease = CCEaseSineInOut:create(spawn)
	return ease
end

--------------------------------------------------------------------------------------------------

DynamicLoadLayout = class(Layer)

function DynamicLoadLayout:create(layoutRender)
	local node = DynamicLoadLayout.new()
	node:init(layoutRender)
	return node
end

function DynamicLoadLayout:ctor()
	self.dataList = {}
	self.viewList = {}

	self.numOfColumns = 1
	self.numOfRows = 0

	self.rowHeights = {}

	self.visibleMinRow = 1
	self.visibleMaxRow = 1

	self.itemWidth = 100
	self.itemHeight = 100

	self.animationDuration = 0.4

	self.createItemViewFunc = nil

	self.isMRR = false --手动内存管理
end

function DynamicLoadLayout:init(layoutRender)
	assert(layoutRender)
	Layer.initLayer(self)

	self.layoutRender = layoutRender

	self.numOfColumns = self.layoutRender:getColumnNum()
	self:setItemViewSize(self.layoutRender:getItemSize())
end

function DynamicLoadLayout:getVisibleHeight()
	return self.layoutRender:getVisibleHeight()
end

function DynamicLoadLayout:getOriginPosY()
	return self.layoutRender:getOriginPosY()
end

function DynamicLoadLayout:setItemViewSize(itemSize)
	if itemSize then
		self.itemWidth = itemSize.width
		self.itemHeight = itemSize.height
	else
		assert(false, "initial item size should not be nil")
	end
end

function DynamicLoadLayout:updateRowNum()
	self.numOfRows = math.ceil(#self.dataList / self.numOfColumns)
	-- update visible rows
	if self.visibleMaxRow > self.numOfRows then
		self.visibleMaxRow = self.numOfRows
	end
	if self.visibleMinRow > self.numOfRows then
		self.visibleMinRow = self.numOfRows
	end
	if self.visibleMinRow < 1 then self.visibleMinRow = 1 end
end

function DynamicLoadLayout:_addData(data, index)
	index = index or (#self.dataList + 1)
	table.insert(self.dataList, index, {data = data})
end

function DynamicLoadLayout:_removeData(index)
	if #self.dataList > 0 then
		return table.remove(self.dataList, index)
	end
	return nil
end

function DynamicLoadLayout:initItemViews()
	self.visibleMinRow = 1
	self.visibleMaxRow = 0
	for row = 1, self.numOfRows do
		if self:getRowTopPosY(row) < self:getVisibleBottomY() or self.numOfColumns*row >= #self.dataList then
			break
		end
		self.visibleMaxRow = row
	end
	for row = self:getLoadMinRow(), self:getLoadMaxRow() do
		for col = 1, self.numOfColumns do
			local idx = self.numOfColumns*(row-1)+col
			if idx > #self.dataList then break end
			self:addView(row, col)
		end
	end
end

function DynamicLoadLayout:getVisibleMinRow()
	return self.visibleMinRow
end

function DynamicLoadLayout:getVisibleMaxRow()
	return self.visibleMaxRow
end

function DynamicLoadLayout:getLoadMinRow()
	local loadMinRow = self.visibleMinRow - self.layoutRender:getPreloadRow()
	if loadMinRow < 1 then loadMinRow = 1 end
	return loadMinRow
end

function DynamicLoadLayout:getLoadMaxRow()
	local loadMaxRow = self.visibleMaxRow + self.layoutRender:getPreloadRow()
	if loadMaxRow > self.numOfRows then loadMaxRow = self.numOfRows end
	return loadMaxRow
end

function DynamicLoadLayout:createItemView(data, index)
	return self.layoutRender:buildItemView(data, index)
end

function DynamicLoadLayout:getVisibleTopY()
	local ret = self:getOriginPosY()
	return ret
end

function DynamicLoadLayout:getVisibleBottomY()
	local ret = self:getOriginPosY() - self:getVisibleHeight()
	return ret
end

function DynamicLoadLayout:getRowBottomPosY(row, topOffsetY)
	local totalHeight = 0
	for r = 1, row do
		if not self.rowHeights[r] then
			he_log_error("getRowBottomPosY: row="..tostring(r)..",heights="..table.serialize(self.rowHeights))
		end
		local height = self.rowHeights[r] or 0
		totalHeight = totalHeight + height
	end
	topOffsetY = topOffsetY or 0
	local ret = topOffsetY + self:getOriginPosY() - totalHeight
	return ret
end

function DynamicLoadLayout:getRowTopPosY(row, topOffsetY)
	local totalHeight = 0
	for r = 1, row-1 do
		if not self.rowHeights[r] then
			he_log_error("getRowTopPosY: row="..tostring(r)..",heights="..table.serialize(self.rowHeights))
		end
		local height = self.rowHeights[r] or 0
		totalHeight = totalHeight + height
	end
	topOffsetY = topOffsetY or 0
	local ret = topOffsetY + self:getOriginPosY() - totalHeight
	return ret
end

--param deltaIdx 滚动后的偏移 >0 从顶部数第几个 <0从底部数第几个
function DynamicLoadLayout:getPosYByIndex(idx, deltaIdx)
	local newIdx = idx
	if deltaIdx then 
		local maxRow, _ = self:getMaxRowColNum()
		local visibleRowNum = self:getVisibleRowNum()
		if deltaIdx > 0 then 
			newIdx = idx - deltaIdx + 1
		elseif deltaIdx < 0 then 
			newIdx = idx - (visibleRowNum + deltaIdx)
		end
		newIdx = math.min(math.max(1, newIdx), maxRow)
	end
	local row, col = self:calcRowAndColByIndex(newIdx)
	local posY = self:getRowTopPosY(row, 0)
	return posY
end

--最后一屏的条目 不做上面getPosYByIndex的deltaIdx的调整
function DynamicLoadLayout:shouldIgnorePosDelta(idx)
	local maxRow, _ = self:getMaxRowColNum()
	local visibleRowNum = self:getVisibleRowNum()
	local ignoreStartIndex = maxRow - visibleRowNum + 1
	if idx > ignoreStartIndex then
		return true 
	end
	return false 
end

function DynamicLoadLayout:getMaxRowColNum()
	local maxIdx = #self.dataList
	local row, col = self:calcRowAndColByIndex(maxIdx)
	return row, col
end

function DynamicLoadLayout:getVisibleRowNum()
	return math.floor(self:getVisibleHeight()/self.itemHeight)
end

--只有一列时的视图移动 假的 之后需要主动调用update
function DynamicLoadLayout:fakeMoveTo(startIdx, deltaIdx, duration, callback)
	if self.numOfColumns == 1 then 
		local moveTargets = {}
		for k,v in pairs(self.viewList) do
			if self.viewList[k] and k >= startIdx then 
				local moveConfig = {}
				moveConfig.target = self.viewList[k]
				moveConfig.idx = k
				table.insert(moveTargets, moveConfig) 
			end
		end
		local num = #moveTargets
		if num > 0 then 
			table.sort(moveTargets, function (a, b)
				return a.idx < b.idx
			end)
			
			local firstOneEndIdx = math.max(1, startIdx + deltaIdx)
			if firstOneEndIdx ~= startIdx then 
				for i,v in ipairs(moveTargets) do
					local arr = CCArray:create()
					local endIdx = firstOneEndIdx + i - 1
					local startPosY = self:getPosYByIndex(v.idx)
					local endPosY = self:getPosYByIndex(endIdx)
					arr:addObject(CCEaseSineOut:create(CCMoveBy:create(duration, ccp(0, endPosY - startPosY))))
					if i == num and callback then 
						arr:addObject(CCCallFunc:create(function ()
							callback()
						end))
					end
					v.target:stopAllActions()
					v.target:runAction(CCSequence:create(arr))
				end
			else
				if callback then callback() end
			end
		else
			if callback then callback() end
		end
	else
		assert(false, "only 1 column supported")
	end
end

function DynamicLoadLayout:calcRowAndColByIndex(index)
	local col = index % self.numOfColumns
	if col == 0 then col = self.numOfColumns end
	local row = math.floor((index - col) / self.numOfColumns) + 1
	return row, col
end

function DynamicLoadLayout:updateRowHeights(startRow, endRow)
	startRow = startRow or 1

	local rowHeights = {}
	for row = 1, startRow - 1 do
		rowHeights[row] = self.rowHeights[row]
	end

	local startIndex = (startRow - 1) * self.numOfColumns + 1
	local endIndex = nil
	if endRow then
		endIndex = endRow * self.numOfColumns
	end
	if not endIndex or endIndex > #self.dataList then endIndex = #self.dataList end

	for idx = startIndex, endIndex do
		local data = self.dataList[idx]
		local row, col = self:calcRowAndColByIndex(idx)
		local rowHeight = rowHeights[row] or self.itemHeight
		if data.itemHeight and data.itemHeight > rowHeight then
			rowHeight = data.itemHeight
		end
		rowHeights[row] = rowHeight
	end

	if endRow and endRow < self.numOfRows then
		for row = endRow+1, self.numOfRows do
			rowHeights[row] = self.rowHeights[row]
		end
	end
	self.rowHeights = rowHeights
end

function DynamicLoadLayout:onLayoutPositionChanged(top)
	if not top then return end
	self.preTop = self.preTop or self:getOriginPosY()
	local oldLoadMinRow = self:getLoadMinRow()
	local oldLoadMaxRow = self:getLoadMaxRow()

	if top > self.preTop then
		for row = self.visibleMaxRow, self.numOfRows do
			if row < 1 or self:getRowTopPosY(row, top) < self:getVisibleBottomY() then
				break
			end
			self.visibleMaxRow = row
		end
		for row = self.visibleMinRow, self.visibleMaxRow do
			if row > self.numOfRows or self:getRowBottomPosY(row, top) < self:getVisibleTopY() then
				break
			end
			self.visibleMinRow = row
		end
	elseif top < self.preTop then
		for row = self.visibleMinRow, 1, -1 do
			if row < 1 or self:getRowBottomPosY(row, top) > self:getVisibleTopY() then
				break
			end
			self.visibleMinRow = row
		end
		for row = self.visibleMaxRow, self.visibleMinRow, -1 do
			if row > self.numOfRows or self:getRowTopPosY(row, top) > self:getVisibleBottomY() then
				break
			end
			self.visibleMaxRow = row
		end
	end

	local newLoadMinRow = self:getLoadMinRow()
	local newLoadMaxRow = self:getLoadMaxRow()

	if oldLoadMinRow > newLoadMinRow then
		for row = newLoadMinRow, math.min(oldLoadMinRow-1, newLoadMaxRow) do
			for col = 1, self.numOfColumns do
				self:addView(row, col)
			end
		end
	elseif oldLoadMinRow < newLoadMinRow then
		for row = oldLoadMinRow, newLoadMinRow-1 do
			for col = 1, self.numOfColumns do
				self:removeView(row, col)
			end
		end
	end

	if oldLoadMaxRow > newLoadMaxRow then
		for row = newLoadMaxRow+1, oldLoadMaxRow do
			for col = 1, self.numOfColumns do
				self:removeView(row, col)
			end
		end
	elseif oldLoadMaxRow < newLoadMaxRow then
		for row = math.max(oldLoadMaxRow+1, newLoadMinRow), newLoadMaxRow do
			for col = 1, self.numOfColumns do
				self:addView(row, col)
			end
		end
	end

	self.preTop = top
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function DynamicLoadLayout:initWithDatas(datas)
	if datas then
		for _, data in pairs(datas) do
			self:_addData(data)
		end
	end
	self:updateRowNum()
	self:updateRowHeights()
	self:initItemViews()
end

function DynamicLoadLayout:addItem(data, playAnimation, withoutLayout)
	self:addItemAt(data, #self.dataList+1, playAnimation, withoutLayout)
end

function DynamicLoadLayout:addItemAt(data, index, playAnimation, withoutLayout)
	local row, col = self:calcRowAndColByIndex(index)
	self:_addData(data, index)
	self:updateRowNum()
	self:updateRowHeights(row)

	local viewList = {}
	for idx, view in pairs(self.viewList) do
		if idx >= index then
			viewList[idx+1] = view
		else
			viewList[idx] = view
		end
	end
	self.viewList = viewList

	-- self:addView(row, col, data)

	if not withoutLayout then
		self:__layout(playAnimation)
	end
end

function DynamicLoadLayout:getItemViewIndex(itemView)
	for idx, view in pairs(self.viewList) do
		if view == itemView then
			return idx
		end
	end
	return nil
end

function DynamicLoadLayout:getItemView(index)
	for idx, view in pairs(self.viewList) do
		if idx == index then
			return view
		end
	end
	return nil
end

function DynamicLoadLayout:getItemViewWorldPos(index)
	local pos 
	local view = self:getItemView(index)
	if view then 
		local parent = view:getParent()
		local nodePos = view:getPosition()
		pos = parent:convertToWorldSpace(ccp(nodePos.x, nodePos.y))
	end
	return pos
end

function DynamicLoadLayout:addView(row, col, playAnimation)
	local idx = self.numOfColumns*(row-1)+col
	local itemData = self.dataList[idx]
	if itemData and not self.viewList[idx] then
		local view = self:createItemView(itemData, idx)
		if view then
			view:setPosition(ccp(self.itemWidth*(col-1), self:getRowTopPosY(row)))
			self:addChild(view)
			self.viewList[idx] = view

			self.layoutRender:onItemViewDidAdd(view, itemData)
		end
	end
end

function DynamicLoadLayout:removeView(row, col, playAnimation)
	local idx = self.numOfColumns*(row-1)+col
	local itemView = self.viewList[idx]
	if itemView then
		local function __removeItemUI()
			if itemView and not itemView.isDisposed and itemView:getParent() then 
				itemView:removeFromParentAndCleanup(not self.isMRR) 
			end
		end

		if playAnimation then 
			local shrink = self.layoutRender:buildRemoveItemAnimation(itemView)
			if shrink then
				local cb = CCCallFunc:create(__removeItemUI)
				local se = CCSequence:createWithTwoActions(shrink, cb)
				itemView:runAction(se)
			else
				__removeItemUI()
			end
		else
			__removeItemUI()
		end
		self.viewList[idx] = nil
	end
end

-- Layout height
function DynamicLoadLayout:getHeight()
	local totalHeight = 0
	for row, height in pairs(self.rowHeights) do
		totalHeight = totalHeight + height
	end
	return totalHeight
end

function DynamicLoadLayout:removeItemByData(data, playAnimation, withoutLayout)
	local index = self:getDataIndex(data)
	if index then
		self:removeItemAt(index, playAnimation, withoutLayout)
	end
end

function DynamicLoadLayout:removeLastItem(playAnimation, withoutLayout)
	self:removeItemAt(#self.dataList, playAnimation, withoutLayout)
end

function DynamicLoadLayout:removeItemAt(index, playAnimation, withoutLayout)
	local ret = self:_removeData(index)
	if ret then
		local row, col = self:calcRowAndColByIndex(index)

		self:updateRowNum()
		self:updateRowHeights(row)

		self:removeView(row, col)

		local viewList = {}
		for idx, view in pairs(self.viewList) do
			if idx > index then
				viewList[idx-1] = view
			elseif idx < index then
				viewList[idx] = view
			end
		end
		self.viewList = viewList

		if not withoutLayout then
			self:__layout(playAnimation)
		end
	end
end

function DynamicLoadLayout:removeAllItems()
	for _, view in pairs(self.viewList) do
		view:removeFromParentAndCleanup(not self.isMRR)
	end
	self.dataList = {}
	self.viewList = {}
	self.rowHeights = {}
end

function DynamicLoadLayout:getDataIndex(data)
	return table.indexOf(self.dataList, data)
end

function DynamicLoadLayout:onItemHeightChange(data, newHeight)
	local index = self:getDataIndex(data)
	if index and newHeight then
		data.itemHeight = newHeight
		local row, col = self:calcRowAndColByIndex(index) 
		self:updateRowHeights(row, row)
	end
end

function DynamicLoadLayout:updateViewArea(top, bottom)
	self:onLayoutPositionChanged(top)
end

function DynamicLoadLayout:__layout(playAnimation)
	for row = self:getLoadMinRow(), self:getLoadMaxRow() do
		for col = 1, self.numOfColumns do
			local index = (row - 1) * self.numOfColumns + col
			local view = self.viewList[index]
			if not view then
				self:addView(row, col)
			else
		        local point = ccp((col-1)*self.itemWidth, self:getRowTopPosY(row))
		        if playAnimation then 
		        	local moveAnime = self.layoutRender:buildMoveToAnimation(view, point)
		        	if moveAnime then
			            view:stopAllActions()
			            view:runAction(moveAnime)
			        else
		           		view:setPosition(point)
			        end
		        else
	           		view:setPosition(point)
		        end
			end
		end
	end

	for idx, view in pairs(self.viewList) do
		if idx <= (self:getLoadMinRow() - 1) * self.numOfColumns or idx > self:getLoadMaxRow() * self.numOfColumns then
			local row, col = self:calcRowAndColByIndex(idx)
			self:removeView(row, col)
		end
	end
end
