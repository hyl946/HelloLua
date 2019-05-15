-------------------------------------------------------------------------
--  Class include: TableViewRenderer, TableView
-------------------------------------------------------------------------

require "hecore.display.Director"
require "hecore.display.TextField"

kTableViewVerticalFillOrder = {kCCTableViewFillTopDown, kCCTableViewFillBottomUp}

--
-- TableViewRenderer ---------------------------------------------------------
--
TableViewRenderer = class()
function TableViewRenderer:ctor(width, height)
	self.list = {}
	self.width = width
	self.height = height
end
function TableViewRenderer:getContentSize()
	return CCSizeMake(self.width, self.height)
end
function TableViewRenderer:buildCell(container)
	local label = TextField:create("")
	label:setAnchorPoint(ccp(0,0))
	container:addChild(label)
	label:setTag(-1001)
end
function TableViewRenderer:setData( rawCocosObj, index )
	local label = self:getChildByTag(rawCocosObj, -1001)
	if type(label.setString) == "function" then label:setString("Index:"..index) end
end
function TableViewRenderer:getChildByTag(rawCocosObj, tag)
    return rawCocosObj:getChildByTag(tag)
end
function TableViewRenderer:getDataSource()
	return self.list
end
function TableViewRenderer:numberOfCells()
	return #self.list
end
--
-- TableView ---------------------------------------------------------
--
TableView = class(CocosObject)
--TableView = class(Layer)

function TableView:dispose()
	CocosObject.dispose(self)
end

function TableView:create(tableViewRenderer, width, height)
	
	local view = nil
	local function tableViewDelegate( eventType, tableView, a1, a2 )
		if eventType == "cellSize" then
			return tableViewRenderer:getContentSize(tableView, a1)
		elseif eventType == "cellAtIndex" then
			--Return CCTableViewCell, a1 is cell index, a2 is dequeued cell (maybe nil)
			--Do something to create cell and change the content

			he_log_warning("comment out check a2 !")
			--if not a2 then
				local container = CocosObject.new(CCTableViewCell:create())
				tableViewRenderer:buildCell(container, a1)
				a2 = container.refCocosObj
				container:dispose()
			--end
			tableViewRenderer:setData(a2, a1)
			return a2
		elseif eventType == "numberOfCells" then
			return tableViewRenderer:numberOfCells()
		elseif eventType == "cellTouched" then
			--A cell was touched, a1 is cell that be touched. This is not necessary. 
			local touch = a2
			local point = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
			local cellIndex = a1:getIdx() 
			if view and view:hasEventListenerByName(DisplayEvents.kTouchItem) then
				local evt = DisplayEvent.new(DisplayEvents.kTouchItem, view, point)
				evt.data = cellIndex
				view:dispatchEvent(evt)
			end
		elseif eventType == "cellSelected" then

			if view and view:hasEventListenerByName(DisplayEvents.kSelectItem) then
				local evt = DisplayEvent.new(DisplayEvents.kSelectItem, a1, a2)
				view:dispatchEvent(evt)
			end
		end
		return nil
	end

	local size = CCSizeMake(width, height)
	local luaTableView = LuaTableView:createWithHandler(LuaEventHandler:create(tableViewDelegate), size)

	view = TableView.new(luaTableView)
	--view:setRefCocosObj(luaTableView)

	--view.TableViewRenderer = TableViewRenderer

	--hitarea
	local node = CocosObject:create()
	node.name = kHitAreaObjectName
	node.touchEnabled = false
	node.touchChildren = false

	view.hitArea = node
	view:addChild(node)
	view:setViewSize(size)
	view:setContentSize(size)
	view:setVerticalFillOrder(kCCTableViewFillTopDown)
	return view
end

--kTableViewVerticalFillOrder
function TableView:getVerticalFillOrder() return self.refCocosObj:getVerticalFillOrder() end
function TableView:setVerticalFillOrder(v) self.refCocosObj:setVerticalFillOrder(v) end

function TableView:updateCellAtIndex(v) self.refCocosObj:updateCellAtIndex(v) end
function TableView:insertCellAtIndex(v) self.refCocosObj:insertCellAtIndex(v) end
function TableView:removeCellAtIndex(v) self.refCocosObj:removeCellAtIndex(v) end

function TableView:reloadData(v) self.refCocosObj:reloadData(v) end

function TableView:cellAtIndex(v) return self.refCocosObj:cellAtIndex(v) end
function TableView:dequeueCell(v) self.refCocosObj:dequeueCell(v) end

function TableView:scrollViewDidScroll(view, ...)
	assert(#{...} == 0)

	return self.refCocosObj:scrollViewDidScroll(view)
end

function TableView:isBounceable() return self.refCocosObj:isBounceable() end
function TableView:setBounceable(v) self.refCocosObj:setBounceable(v) end
function TableView:setTouchEnabled(v) self.refCocosObj:setTouchEnabled(v) end
function TableView:setPageEnabled(v) self.refCocosObj:setPageEnabled(v) end

--Sets a new content offset. It ignores max/min offset. It just sets what's given. (just like UIKit's UIScrollView)
--void setContentOffset(CCPoint offset, bool animated = false);
function TableView:getContentOffset() return self.refCocosObj:getContentOffset() end
function TableView:setContentOffset(offset, animated) self.refCocosObj:setContentOffset(offset) end

function TableView:setContentOffsetInDuration(offset, dt) self.refCocosObj:setContentOffsetInDuration(offset, dt) end
function TableView:setScrollViewAnimationParemeter(scrollDeaccelRate, 
													scrollDeaccelDist, 
													bounceDuration, 
													insetRatio, 
													moveInch) 
	self.refCocosObj:setScrollViewAnimationParemeter(scrollDeaccelRate, 
													scrollDeaccelDist, 
													bounceDuration, 
													insetRatio, 
													moveInch) 
end

--CCScrollViewDirection
function TableView:getDirection() return self.refCocosObj:getDirection() end
function TableView:setDirection(v) self.refCocosObj:setDirection(v) end

function TableView:isDragging() return self.refCocosObj:isDragging() end
--Determines if a given node's bounding box is in visible bounds
function TableView:isNodeVisible(node) return self.refCocosObj:isNodeVisible(node) end
function TableView:isTouchMoved() return self.refCocosObj:isTouchMoved() end

--CCSize
--size to clip. CCNode boundingBox uses contentSize directly.
function TableView:getViewSize() return self.refCocosObj:getViewSize() end
function TableView:setViewSize(v) 
	self.refCocosObj:setViewSize(v) 
	if self.hitArea then self.hitArea:setContentSize(CCSizeMake(v.width, v.height)) end
end
