require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRankingListRender"

SeasonWeeklyRankingList = class()

function SeasonWeeklyRankingList:create()
	local panel = SeasonWeeklyRankingList.new()
    return panel
end

function SeasonWeeklyRankingList:initList( listSize , render )
	self.render = render
	self.tableViewSize = listSize

	local tableView = TableView:create( render , listSize.width , listSize.height )
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	--tableView:setPositionX(boundingBox:getMidX())
	--tableView:setPositionY(boundingBox:getMidY())

	--listBgUi:getParent():addChild(tableView)

	self.tableView = tableView
end

function SeasonWeeklyRankingList:setWY(wy)
	self.wy = wy
end

function SeasonWeeklyRankingList:cloneItem(idx, newRank)
	local container = CocosObject.new(CCTableViewCell:create())
	self.render:cloneItem(container, idx, newRank)
	return container
end

function SeasonWeeklyRankingList:getCellItem(idx, safe)
	print("SeasonWeeklyRankingList:getCellItem:", idx, safe, self.render:numberOfCells())
	local val = idx
	if safe then
		val = math.min(idx, self.render:numberOfCells())
		val = math.max(1, val)
	end
	return self.render:getCellItem(val)
end

function SeasonWeeklyRankingList:numberOfCells()
	return self.render:numberOfCells()
end

function SeasonWeeklyRankingList:getTableView()
	return self.tableView
end

function SeasonWeeklyRankingList:setContentTop()
	local y = self.render:numberOfCells() * self.render:getContentSize(nil,1).height - self.tableViewSize.height
	self.tableView:setContentOffset(ccp(0, -y))
end

function SeasonWeeklyRankingList:adjContentOffset(offset)
	local val = self.tableView:getContentOffset()
	self.tableView:setContentOffset(ccp(val.x + offset.x, val.y + offset.y))
	print("tableView:offset:", val.x + offset.x, val.y + offset.y)
end

function SeasonWeeklyRankingList:adjContentOffsetInDuration(offset, dt)
	local val = self.tableView:getContentOffset()
	self.tableView:setContentOffsetInDuration(ccp(val.x + offset.x, val.y + offset.y), dt)
end

-- 在WS空间中需要偏移的位置
function SeasonWeeklyRankingList:getOffsetForItemInView(idx, safe)
	local y = 0
	local parent = self.tableView.refCocosObj:getContainer()
	local hRender = self.render:getContentSize().height
	local hView = self.tableViewSize.height

    -------------------------------------------------------
	local szRender = self.render:getContentSize()
	local ori = parent:convertToWorldSpace(ccp(0, 0))
	local cur = parent:convertToWorldSpace(ccp(0, szRender.height))
	local wRenderHeight = math.abs(math.abs(cur.y) - math.abs(ori.y))
    ------------------------------------------------------
	local hScale = hRender / wRenderHeight
	hRender = wRenderHeight
	hView = self.wy
    -----------------------------------------------------------------
	--print("hRender/hView:", hRender, "--", wRenderHeight, hView, "-----", self.wy)
	local ly = (self.render:numberOfCells() - idx) * self.render:getContentSize().height
	local wPos = self.tableView.refCocosObj:getContainer():convertToWorldSpace(ccp(0, ly))
	local up = wPos.y + hRender

	if up > hView then
		y = hView - up
	elseif wPos.y < 0 then
		y = - wPos.y
	end
	--print("---wUp/wBom/hView:", idx, up, wPos.y, hView, y)
	return y * hScale
end

function SeasonWeeklyRankingList:getWPos(idx)
	local ly = (self.render:numberOfCells() - idx) * self.render:getContentSize().height
	local wPos = self.tableView.refCocosObj:getContainer():convertToWorldSpace(ccp(0, ly))
	return wPos
end

function SeasonWeeklyRankingList:makeItemInView(idx)
	local val = self.tableView:getContentOffset()
	local offY = self:getOffsetForItemInView(idx, true)
	self:adjContentOffset(ccp(0, offY))
end

function SeasonWeeklyRankingList:makeItemInViewInDuration(idx, dt)
	local offY = self:getOffsetForItemInView(idx, true)
	self:adjContentOffsetInDuration(ccp(0, offY), dt)
end

function SeasonWeeklyRankingList:updateSelf(keepOffset)
	if self.tableView then 
		local contentSize1 = self.tableView:getContentSize()
		local offset = self.tableView:getContentOffset()
		self.tableView:reloadData()
		if keepOffset then
			self.tableView:setContentOffset(ccp(offset.x, offset.y))
			local szContent = self.tableView:getContentSize()
			self.tableView:setContentOffset(ccp(
		        offset.x,
		        offset.y  - szContent.height + contentSize1.height
	        ))
		end
	end
end

function SeasonWeeklyRankingList:dispose()
	if self.render then
		if type(self.render.dispose) == "function" then
			self.render:dispose()
		end
		self.render = nil
	end

	if self.tableView then 
		self.tableView:dispose() 
		self.tableView = nil
	end
	self.tableViewSize = nil
end