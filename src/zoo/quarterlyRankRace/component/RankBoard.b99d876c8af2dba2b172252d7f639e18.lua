

local RankBoard = class()

function RankBoard:ctor()
	self.tabBtns = {}
	self.tabShows = {}

	self.curTabIndex = nil
end

function RankBoard:init(config, tabUpdateCallback)
	self.tabUpdateCallback = tabUpdateCallback
	for i,v in ipairs(config) do
		local BtnClazz = v.tabBtnClass
		local btn = BtnClazz:create(v.tabBtnUI)
		btn:setTouchEnabled(true)
		btn:setTabBtnIndex(i)
		self.tabBtns[i] = btn
		btn:ad(DisplayEvents.kTouchTap, function ()
			self:onTabBtnTap(i)
		end)

		local ShowClazz = v.tabShowClass
		local show = ShowClazz:create(v.tabShowUI, v.tabShowWidth, v.tabShowHeight)
		show:setTabShowIndex(i)
		self.tabShows[i] = show
	end

	local calStatus = tonumber(RankRaceMgr.getInstance():getData():getStatus())
    if calStatus and (calStatus == 2 or calStatus == 3) then 
    	if self.tabUpdateCallback then self.tabUpdateCallback(1, "rank_bar_calculate") end
    else 
		self:onTabBtnTap(1)
	end
end

function RankBoard:onTabBtnTap(tabIndex)
	if self.curTabIndex and self.curTabIndex == tabIndex then return end

	self:showBoard(tabIndex)
	local tabShow = self.tabShows[tabIndex]
	if tabShow then 
		tabShow:requestRankData(true, function (spState)
			tabShow:refresh(true)
			if self.tabUpdateCallback then self.tabUpdateCallback(tabIndex, spState) end
		end)
	end
end

function RankBoard:updateBtnFlag(tabIndex)
	local tabBtn = self.tabBtns[tabIndex]
	if tabBtn then 
		tabBtn:updateFlagShow()
	end
end

function RankBoard:update(tabIndex, withSurpass)
	self:setLock(true)
	local function getRankIndex()
		local rankIndex 
		if tabIndex == 1 then 
			rankIndex = RankRaceMgr.getInstance().rankIndexGroup or 0
		elseif tabIndex == 2 then 
			rankIndex = RankRaceMgr.getInstance().rankIndexFriend or 0
		end
		return rankIndex
	end

	local tabShow = self.tabShows[tabIndex]
	if tabShow then 
		local oldRankIndex = getRankIndex()
		local oldRankData 
		if tabShow.rankData then
			oldRankData = table.clone(tabShow.rankData) 
		end
		local function onAniFinish(spState)
			if self.isDisposed then return end
			tabShow:refresh(true)
			if self.tabUpdateCallback then self.tabUpdateCallback(tabIndex, spState) end
			self:setLock(false)
		end
		local function onDataGot(spState)
			if self.isDisposed then return end
			self.curTabIndex = tabIndex
			self:showBoard(tabIndex)
			local newRankIndex = getRankIndex()
			if withSurpass and 
				(oldRankData and #oldRankData > 0) and
				(newRankIndex > 0 and oldRankIndex > 0 and newRankIndex < oldRankIndex) then 
				self:boardUnfold(false)
				tabShow:playSurpassAni(oldRankData, oldRankIndex, newRankIndex, function ()
					onAniFinish(spState)
				end)
			else
				onAniFinish(spState)
			end
		end
		tabShow:requestRankData(false, onDataGot)
	else
		self:setLock(false)
	end
end

function RankBoard:showBoard(tabIndex)
	self.curTabIndex = tabIndex

	for i,v in ipairs(self.tabBtns) do
		local tabShow = self.tabShows[i]
		if i == tabIndex then 	
			v:setSelect(true)
			tabShow:setSelect(true)
		else
			v:setSelect(false)
			tabShow:setSelect(false)
		end
	end
end

function RankBoard:setLock(isLock)
	if self.lockCallback then self.lockCallback(isLock) end
end

function RankBoard:setLockCallback(lockCallback)
	self.lockCallback = lockCallback
end

function RankBoard:setUnfoldCallback(unfoldCallback)
	self.boardUnfoldCallback = unfoldCallback
end

function RankBoard:boardUnfold(withAni)
	if self.boardUnfoldCallback then self.boardUnfoldCallback(withAni) end
end

function RankBoard:dispose()
	if self.tabShows then 
		for i,v in ipairs(self.tabShows) do
			v:dispose()
		end
		self.tabShows = nil
	end
	self.isDisposed = true
end

function RankBoard:create(config, onTabUpdateCallback)
	local board = RankBoard.new()
	board:init(config, onTabUpdateCallback)
	return board
end

return RankBoard