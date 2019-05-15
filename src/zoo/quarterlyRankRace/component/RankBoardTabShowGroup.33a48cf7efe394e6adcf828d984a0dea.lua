local RankBoardTabShow = require "zoo.quarterlyRankRace.component.RankBoardTabShow"
local RankRaceRankItemGroup = require "zoo.quarterlyRankRace.component.RankRaceRankItemGroup"

local RankBoardTabShowGroup = class(RankBoardTabShow)

function RankBoardTabShowGroup:ctor()
	self.className = "RankBoardTabShowGroup"
end

function RankBoardTabShowGroup:init(ui, showWidth, showHeight)
	RankBoardTabShow.init(self, ui, showWidth, showHeight)

	self.noNetTipUI = ui:getChildByName("netTip")
    self.noNetTipUI:setVisible(false)

    self.rankView:setStartScrollCallback(function ()
    	if self.isDisposed then return end
    	self:hideAnyInfoPanel()
    	self:onAfterItemTapped()
    end)
end

function RankBoardTabShowGroup:buildItemContainer(viewWidth, viewHeight)
	local context = self

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 1
	end
	function LayoutRender:getItemSize()
		return RankRaceRankItemGroup:getItemOriSize()
	end
	function LayoutRender:getVisibleHeight()
		return viewHeight
	end
	function LayoutRender:buildItemView(itemData, index)
		local item = nil
		item = RankRaceRankItemGroup:create(itemData)
		item:setParentView(context.rankView)
		item:setRankIndex(index)

		local function onBeforeItemTapped(target)
			if context.isDisposed then return end
    		context:hideAnyInfoPanel(target)
		end

		local function onAfterItemTapped(isInfoPanelShow)
			if context.isDisposed then return end
			context:onAfterItemTapped(isInfoPanelShow, index)

			--以下 保证相信信息页 在当前屏显示
			local kMax = 0
			for k,v in pairs(context.itemContainer.viewList) do
				if k > kMax then 
					kMax = k
				end
			end
			local function _move()
				local posY = -context.itemContainer:getPosYByIndex(index, -2)
				context.rankView:gotoPositionY(posY, 0)
			end
			if kMax > 0 then
				local dataMax = #context.itemContainer.dataList
				if dataMax - kMax <= 3 then
					if index == kMax or index == kMax - 1 then
						_move()
					end
				else
					if index == kMax - 2 or index == kMax - 3 then
						_move()
					end
				end 
			end
		end
		-- local function onSelectStateChange(selected)
		-- 	itemData.isSelected = selected
		-- end

		item:setBeforeInfoShowCallback(onBeforeItemTapped)
		item:setAfterInfoShowCallback(onAfterItemTapped)
		-- item:setSelectStateChangeCallback(onSelectStateChange)

		return item
	end

	function LayoutRender:onItemViewDidAdd(itemView, itemData)
		if itemData.isExpand then
			itemView:onItemTapped(nil, true)
		end
		itemView:update()
	end

	local layout = DynamicLoadLayout:create(LayoutRender.new())
  	layout:setPosition(ccp(0, 0))
  	return layout
end

function RankBoardTabShowGroup:buildFakeItem(idx)
	local rankData = self:getRankData()	
	local itemData = rankData[idx]
	local item
	if itemData then 
		item = RankRaceRankItemGroup:create({data = itemData})
		item:setRankIndex(idx)
		item.ui:setTouchEnabled(false)
	end
	return item
end

function RankBoardTabShowGroup:hideAnyInfoPanel(exceptOne)
	for _,v in pairs(self:getRankItems()) do
		if exceptOne then 
			if v ~= exceptOne then
				v:hideInfoPanel() 
			end
		else
			v:hideInfoPanel()
		end
	end
end

function RankBoardTabShowGroup:onAfterItemTapped()
	self.itemContainer:__layout()
	self.rankView:updateScrollableHeight()
	self.rankView:updateContentViewArea()
end

function RankBoardTabShowGroup:getRankItems()
	local items = nil
	if self.itemContainer then
		items = self.itemContainer.viewList
	end
	return items or {}
end

--override
function RankBoardTabShowGroup:requestRankData(considerCD, callback)
	self.itemContainer:removeAllItems()

	local function onSuccess(rankData, myRank)
		if self.isDisposed or self.ui.isDisposed then return end
		self.noNetTipUI:setVisible(false)
        self.rankData = rankData or {}
        -- self:refresh()
        if callback then callback() end
	end

	local function onFail(errorCode)
		if self.isDisposed or self.ui.isDisposed then return end
		if errorCode and errorCode == -1012 then 
			CommonTip:showTip(localize("rank.race.main.3"), "negative")
			if callback then callback() end
		else
            self.noNetTipUI:setVisible(true)
            self.rankData = {}
            -- self:refresh()
            if callback then callback("rank_bar_no_net") end
		end
	end

	local function onCancel()
		if self.isDisposed or self.ui.isDisposed then return end
	end
	RankRaceMgr.getInstance():getRankListGroup(considerCD, onSuccess, onFail, onCancel)
end

function RankBoardTabShowGroup:create(ui, showWidth, showHeight)
	local show = RankBoardTabShowGroup.new()
	show:init(ui, showWidth, showHeight)
	return show
end

return RankBoardTabShowGroup