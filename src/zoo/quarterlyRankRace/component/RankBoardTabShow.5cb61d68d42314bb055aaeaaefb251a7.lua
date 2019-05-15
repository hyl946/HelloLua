
local RankBoardTabShow = class()

function RankBoardTabShow:ctor()
	self.className = "RankBoardTabShow"
	self.rankData = nil
	self.rankView = nil
	self.rankViewRender = nil
	self.cellItems = {}
end

function RankBoardTabShow:init(ui, showWidth, showHeight)
	self.ui = ui
	self.tableViewWidth = showWidth
	self.tableViewHeight = showHeight

    self.rankView = VerticalScrollable:create(showWidth, showHeight, true, nil, 2/60)
    self.rankView.name = "list"
    self.rankView:setIgnoreHorizontalMove(false)
	self.rankView:ignoreAnchorPointForPosition(false)
	self.rankView:setAnchorPoint(ccp(0,1))
    self.rankView:setPosition(ccp(0, 0))
    self.ui:addChild(self.rankView)

	self.itemContainer = self:buildItemContainer(showWidth, showHeight)
	self.rankView:setContent(self.itemContainer)
end

function RankBoardTabShow:setTabShowIndex(tabIndex)
	self.tabIndex = tabIndex
end

function RankBoardTabShow:getTabShowIndex()
	return self.tabIndex
end

function RankBoardTabShow:setSelect(isSelected)
	self.ui:setVisible(isSelected)
	self.rankView:setScrollEnabled(isSelected)
end

function RankBoardTabShow:getRankData()	
	return self.rankData
end

function RankBoardTabShow:scrollToIndex(idx, duration, deltaIdx)
	local posY = -self.itemContainer:getPosYByIndex(idx, deltaIdx)
	self.rankView:gotoPositionY(posY, duration)
end

function RankBoardTabShow:playSurpassAni(oldData, oldIndex, newIndex, onFinished)
	local function invokeCbk()
		if self.isDisposed then return end
		if onFinished then onFinished() end
	end
	--用超越动画前的数据创建条目
	self.itemContainer:removeAllItems()
	self:refresh(true, oldData)
	local oldMaxNum = #oldData
	local oldItemPosDelta = math.max(oldIndex - oldMaxNum - 1, -2)  					--超越的条目 老位置从下往上偏移几条 	
	local newItemPosDelta = math.min(newIndex, 2) 	--超越的条目 新位置从上往下偏移几条 
	local shouldIgnore = self.itemContainer:shouldIgnorePosDelta(newIndex)

	--滚到老的位置
	if shouldIgnore then 
		self:scrollToIndex(oldIndex, 0)
	else
		self:scrollToIndex(oldIndex, 0, oldItemPosDelta)
	end

	local oldItem = self.itemContainer:getItemView(oldIndex)
	oldItem:setVisible(false)
	local oldItemPos = self.itemContainer:getItemViewWorldPos(oldIndex)
	oldItemPos = self.ui:convertToNodeSpace(oldItemPos)

	--创建超越动画条目
	local surpassItem = self:buildFakeItem(newIndex)
	local sz = surpassItem:getGroupBounds().size
	local wraper = LayerColor:create()
	-- wraper:setColor(ccc3(255, 0, 0))
    wraper:setOpacity(0)
    wraper:setContentSize(CCSizeMake(sz.width, sz.height))
	wraper:setAnchorPoint(ccp(0.5 ,0.5))
	wraper:addChild(surpassItem)
	surpassItem:setPosition(ccp(0, sz.height))
	self.ui:addChild(wraper)
	wraper:setPosition(ccp(oldItemPos.x, oldItemPos.y - sz.height))

	local shouldIgnore = self.itemContainer:shouldIgnorePosDelta(newIndex)
	local posYDelta
	if shouldIgnore then
		local posY1 = -self.itemContainer:getPosYByIndex(newIndex)
		local posY2 = -self.itemContainer:getPosYByIndex(oldIndex)
		posYDelta = posY2 - posY1
	else
		local posY1 = -self.itemContainer:getPosYByIndex(oldIndex, newItemPosDelta)
		local posY2 = -self.itemContainer:getPosYByIndex(oldIndex, oldItemPosDelta)
		posYDelta = posY1 - posY2
	end

	--动起来
	local oneFrameTime = 1/24
	local moveStartDeltaY = 20
	local indexDelta = oldIndex - newIndex
	local scrollTime = oneFrameTime * indexDelta * 3
	scrollTime = math.min(scrollTime, oneFrameTime * 30)
	local moveTime = math.min(math.max(5, indexDelta), 7) * 2 * oneFrameTime
	local moveTime1 = oneFrameTime * 6
	local scaleTime1 = oneFrameTime * 4
	local scaleTime2 = oneFrameTime * 2
	local scaleTime3 = oneFrameTime * 3
	local scaleTime4 = oneFrameTime * 3
	local delayTime = oneFrameTime * 3
	local arr = CCArray:create()
	local arr1 = CCArray:create()
	local arr2 = CCArray:create()
	local arr3 = CCArray:create()
	local arr4 = CCArray:create()
	local arr5 = CCArray:create()
	arr:addObject(CCDelayTime:create(delayTime))
	arr4:addObject(CCMoveBy:create(oneFrameTime * 2, ccp(0, moveStartDeltaY)))
	arr4:addObject(CCScaleTo:create(oneFrameTime * 3, 1.16))
	arr1:addObject(CCSequence:create(arr4))
	arr1:addObject(CCDelayTime:create(scrollTime))
	arr1:addObject(CCCallFunc:create(function ()
		self:scrollToIndex(newIndex, scrollTime, newItemPosDelta)
		local startIdx = oldIndex + 1
		self.itemContainer:fakeMoveTo(startIdx, -1, oneFrameTime * 5)
	end))
	arr:addObject(CCSpawn:create(arr1))

	local moveAdd = 30
	arr:addObject(CCEaseSineOut:create(CCMoveBy:create(moveTime, ccp(0, posYDelta - moveStartDeltaY + moveAdd))))
	arr:addObject(CCEaseSineOut:create(CCMoveBy:create(moveTime1, ccp(0, - moveAdd))))

	arr:addObject(CCCallFunc:create(function ()
		local num = oldIndex - newIndex
		local itemPos = wraper:getPosition()
		local oriPos = {x = itemPos.x, y = itemPos.y}
		self:showProNumLabel(num, oriPos)
	end))
	arr:addObject(CCScaleTo:create(scaleTime1, 1.39))
	arr:addObject(CCScaleTo:create(scaleTime2, 0.8, 1.27))

	arr5:addObject(CCScaleTo:create(scaleTime3, 1.09, 0.95))
	arr5:addObject(CCScaleTo:create(scaleTime4, 1))

	arr3:addObject(CCSequence:create(arr5))
	arr3:addObject(CCCallFunc:create(function ()
		self.itemContainer:fakeMoveTo(newIndex, 1, scaleTime3 + scaleTime4)
	end))
	arr:addObject(CCSpawn:create(arr3))

	arr:addObject(CCDelayTime:create(oneFrameTime))
	arr:addObject(CCCallFunc:create(function ()
		self.itemContainer:removeAllItems()
		invokeCbk()
		wraper:removeFromParentAndCleanup(true)
	end))
	wraper:runAction(CCSequence:create(arr))

	if surpassItem.light1 then 
		local lightFadeTime1 = oneFrameTime * 3
		local lightDelayTime = delayTime + scrollTime + moveTime + moveTime1 + scaleTime1 + scaleTime2 - lightFadeTime1
		local lightScaleTime1 = oneFrameTime * 6
		surpassItem.light1:setOpacity(0)
		surpassItem.light1:setVisible(true)

		local arrLight = CCArray:create()
		arrLight:addObject(CCFadeTo:create(lightFadeTime1, 150))
		arrLight:addObject(CCDelayTime:create(lightDelayTime))
		arrLight:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(lightScaleTime1, 1.27, 1.30), CCFadeTo:create(lightScaleTime1, 0)))
	
		surpassItem.light1:runAction(CCSequence:create(arrLight))
	end

	if surpassItem.light2 then 
		local lightFadeTime1 = oneFrameTime * 3
		local lightDelayTime = delayTime + scrollTime + moveTime + moveTime1 + scaleTime1 + scaleTime2 - lightFadeTime1
		local lightScaleTime1 = oneFrameTime * 5
		surpassItem.light2:setOpacity(0)
		surpassItem.light2:setVisible(true)

		local arrLight = CCArray:create()
		arrLight:addObject(CCFadeTo:create(lightFadeTime1, 150))
		arrLight:addObject(CCDelayTime:create(lightDelayTime))
		arrLight:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(lightScaleTime1, 1.17, 1.43), CCFadeTo:create(lightScaleTime1, 0)))
	
		surpassItem.light2:runAction(CCSequence:create(arrLight))
	end	
end

function RankBoardTabShow:showProNumLabel(num, oriPos)
	local bg = Sprite:create("ui/RankRace/proNumBg.png")
	self.ui:addChild(bg)
	bg:setPosition(ccp(oriPos.x + 120, oriPos.y + 35))

	local numLabel = BitmapText:create(num.."", 'fnt/newzhousai_rubynum.fnt')
	numLabel:setScale(0.85)
    numLabel:setAnchorPoint(ccp(0, 0.5))
    self.ui:addChild(numLabel)
    numLabel:setPosition(ccp(oriPos.x + 190, oriPos.y + 40))

	local oneFrameTime = 1/24
	for i,v in ipairs({bg, numLabel}) do
		v:setOpacity(0)
		local arr = CCArray:create()
		local arr1 = CCArray:create()
		arr:addObject(CCMoveBy:create(oneFrameTime * 30, ccp(0, 56)))
		arr1:addObject(CCFadeTo:create(oneFrameTime * 10, 255))
		arr1:addObject(CCDelayTime:create(oneFrameTime * 10))
		arr1:addObject(CCFadeTo:create(oneFrameTime * 10, 0))
		arr1:addObject(CCCallFunc:create(function ()
			v:removeFromParentAndCleanup(true)
		end))
		arr:addObject(CCSequence:create(arr1))
		v:stopAllActions()
		v:runAction(CCSpawn:create(arr))
	end
end

--override
function RankBoardTabShow:buildFakeItem()
	assert(false, "must be overrided")
end

function RankBoardTabShow:refresh(keepOffset, data)
	if self.rankView and self.itemContainer then
		data = data or self.rankData
		self.itemContainer:initWithDatas(data)
		self.rankView:updateScrollableHeight()
		if keepOffset then 
			self.itemContainer.preTop = self.rankView.bottomMostOffset
			self.rankView:updateContentViewArea()
		else
			self.rankView:scrollToTop(0)
		end
	end
end

function RankBoardTabShow:dispose()
	self.isDisposed = true
end

--override
function RankBoardTabShow:buildItemContainer(viewWidth, viewHeight)
	assert(false, "must be overrided")
end

--override
function RankBoardTabShow:requestRankData(callback)
	assert(false, "must be overrided")
end

--override
function RankBoardTabShow:create(ui)
	assert(false, "must be overrided")
end

return RankBoardTabShow