require "hecore.ui.TableView"

SeasonWeeklyRankingListRender = class(TableViewRenderer)
SeasonWeeklyRankingListRender.RankTypeEnum = {
	kAllRank = 1,
	kOnceRank = 2
}

local function getFriendName( uid )
	local friendRef = nil
	if tostring(UserManager:getInstance().uid) == tostring(uid) then 
		-- friendRef = UserManager.getInstance().profile
		return "我"
	else
		friendRef = FriendManager.getInstance().friends[tostring(uid)]
	end
	if friendRef and friendRef.name and string.len(friendRef.name) > 0 then 
		return nameDecode(friendRef.name)
	else
		return "ID:"..tostring(uid)
	end
end

local function attachHead( head , uid )
	local friendRef = nil
	if tostring(UserManager:getInstance().uid) == tostring(uid) then 
		friendRef = UserManager.getInstance().profile
	else
		friendRef = FriendManager.getInstance().friends[tostring(uid)]
	end
	-- friendRef.headUrl = "http://cdnq.duitang.com/uploads/item/201407/07/20140707014508_JxAY2.jpeg"

	local headUrl
	if friendRef then
		headUrl = friendRef.headUrl
	end

	local image = HeadImageLoader:createWithFrame(uid, headUrl, nil, 3)
	image:setScaleX((head:getContentSize().width+1.5)/100)
	image:setScaleY((head:getContentSize().height)/100)
	image:setPositionX(head:getContentSize().width/2-0.45)
	image:setPositionY(head:getContentSize().height/2)

	-- 加个背景，避免透明头像显示出底图案
	local bg = LayerColor:createWithColor(hex2ccc3("FFFFFF"), 100, 100)
	bg:setPosition(ccp(-49, -50))
	image:addChildAt(bg, -1)

	head:addChild(image)

end

function SeasonWeeklyRankingListRender:create(rankType)
	local render = SeasonWeeklyRankingListRender.new()
	render:init(rankType)
    return render
end

function SeasonWeeklyRankingListRender:init(rankType)
	self.rankType = rankType
	self.isDisposed = false

	self.id2Items = {}
end

function SeasonWeeklyRankingListRender:setResBuilder( basePanel , resGroupName )
	self.basePanel = basePanel
	self.resGroupName = resGroupName
end

function SeasonWeeklyRankingListRender:buildCellRes(clone)
	local res = nil
	if clone then
		res = self.basePanel:buildInterfaceGroup("2017SummerWeekly/interface/ResRankingUnitRenderForEffect")
	else
		res = self.basePanel:buildInterfaceGroup(self.resGroupName)
	end
	return res
end

function SeasonWeeklyRankingListRender:getRankData()
	local ret = nil
	if self.rankType == SeasonWeeklyRankingListRender.RankTypeEnum.kOnceRank then
		ret = SeasonWeeklyRaceManager:getInstance().onceRankData
	else
		ret = SeasonWeeklyRaceManager:getInstance().allRankData
	end
	return ret
end

function SeasonWeeklyRankingListRender:createCell( view )

	view.globalRankLabel = view:getChildByName("globalRankLabel")
	view.globalRankBG = view:getChildByName("globalRankBG")
	view.pos1 = view:getChildByName("pos1")
	view.pos2 = view:getChildByName("pos2")
	view.pos3 = view:getChildByName("pos3")
	view.pos4 = view:getChildByName("pos4")
	view.pos4Num = view:getChildByName("pos4Num")
	local numPos = view.pos4Num:getPosition()
	view.pos4NumXY = {x=numPos.x , y=numPos.y}
	view.head = view:getChildByName("head")
	view.name = view:getChildByName("name")
	view.icon = view:getChildByName("icon")
	view.num = view:getChildByName("num")
	view.bg = view:getChildByName("bg")
	view.bg2 = view:getChildByName('bg2')
	view:getChildByName('图层 3'):removeFromParentAndCleanup(true)

	local cellItemSize = view:getGroupBounds().size
	if self.listSize then
		view:setPositionX( self.listSize.width/2 - cellItemSize.width/2)
	end
	view:setPositionY(cellItemSize.height/2 + self:getContentSize(nil,idx).height/2)
	--view:setPositionY(0)
	--print("cell:", self.listSize.width/2 - cellItemSize.width/2, cellItemSize.height/2 + self:getContentSize(nil,idx).height/2)
end

function SeasonWeeklyRankingListRender:setListSize( size )
	self.listSize = size
end

function SeasonWeeklyRankingListRender:setData()
	--
end

function SeasonWeeklyRankingListRender:getContentSize( tableView , idx )
	return CCSizeMake(695 , 102)
end

function SeasonWeeklyRankingListRender:numberOfCells()
	if not self:getRankData() then 
		return 0
	else
		return #self:getRankData():getRankList()
	end
end

function SeasonWeeklyRankingListRender:initCell( container , idx , cellItem , uid , score , globalRank )
	--idx = idx + 97
	cellItem.pos1:setVisible(idx == 0 and score > 0)
	cellItem.pos2:setVisible(idx == 1 and score > 0)
	cellItem.pos3:setVisible(idx == 2 and score > 0)
	cellItem.pos4:setVisible(idx >= 3 and score > 0)
	cellItem.pos4Num:setVisible(idx >= 3 and score > 0)
	if cellItem.pos4Num:isVisible() then
		cellItem.pos4Num:setString(tostring(idx + 1))

		if idx >= 99 then
			cellItem.pos4Num:setFontSize( 20 )
			cellItem.pos4Num:setPositionY( cellItem.pos4NumXY.y - 8 )
		else
			cellItem.pos4Num:setFontSize( 30 )
			cellItem.pos4Num:setPositionY( cellItem.pos4NumXY.y )
		end
	end
	--cellItem.pos5:setVisible(score == 0)
	--printx( 1 , "   SeasonWeeklyRankingListRender:initCell(  _______________  " , idx , uid , score , globalRank )
	if score == 0 then 
		cellItem.icon:setVisible(false)
		cellItem.num:setString( Localization:getInstance():getText("weeklyrace.winter.panel.desc16") )--"努力闯关中"
	else

		cellItem.icon:setVisible(true)
		cellItem.num:setString( tostring(score) )
	end

	if globalRank and tostring(globalRank) ~= "0" and tonumber(globalRank) < 10000 then
		cellItem.globalRankBG:setVisible(true)
		cellItem.globalRankLabel:setVisible(true)
		cellItem.globalRankLabel:getChildByName("label"):setString( "第" .. tostring(globalRank) .. "名" )
	else
		cellItem.globalRankBG:setVisible(false)
		cellItem.globalRankLabel:setVisible(false)
	end
	
	cellItem.refCocosObj:removeFromParentAndCleanup(false)
	container.refCocosObj:addChild(cellItem.refCocosObj)

	if tostring(UserManager:getInstance().uid) == tostring(uid) then 
		cellItem:setTouchEnabled(true)
		cellItem:addEventListener(DisplayEvents.kTouchTap, function ()
			--_self:showNumberTip()
		end)

		cellItem.bg2:setVisible(false)
	else
		cellItem.bg:setVisible(false)
	end
end

function SeasonWeeklyRankingListRender:buildCell( container , idx )
	if self.isDisposed or container.isDisposed or not self:getRankData() then 
		return
	end

	local rankdata = self:getRankData():getRankList()[idx + 1]
	--print("buildCell:", idx, table.tostring(rankdata))
	local uid = rankdata.uid
	local score = rankdata.score
	local globalRank = rankdata.globalRank

	local key = tostring(uid)

	if not self.cellItems then self.cellItems = {} end
	self.container = container

	local cellItem = self.cellItems[key]
	if not cellItem then
		cellItem = self:buildCellRes()
		self.cellItems[key] = cellItem

		self:createCell( cellItem )

		attachHead( cellItem.head , uid )

		local userName = getFriendName(uid)
		local nickName = TextUtil:ensureTextWidth(userName, cellItem.name:getFontSize(), cellItem.name:getDimensions())
		if nickName then 
			cellItem.name:setString(nickName) 
		else
			cellItem.name:setString(userName)
		end
	end
	self.id2Items[idx] = cellItem

	self:initCell( container , idx , cellItem , uid , score , globalRank )
	cellItem:setVisible(true)
end

function SeasonWeeklyRankingListRender:getCellItem(idx)
	if not idx then
		local key = tostring(UserManager:getInstance().uid)
		return self.cellItems[key]
	end
	local item = self.id2Items[idx-1]
	if not item then
		print("return last item")
		item = table.last(self.id2Items)
	end
	return item
end

function SeasonWeeklyRankingListRender:cloneItem(container, idx, newRank)
	if self.isDisposed or container.isDisposed or not self:getRankData() then 
		return false
	end

	local myIdx = self:getRankData():getMyRank()
	if myIdx == 0 then return false end

	-- 自己的数据
	local rankdata = self:getRankData():getRankList()[myIdx]
	local uid = rankdata.uid
	local score = rankdata.score
	local globalRank = rankdata.globalRank

	local key = tostring(uid)

	local cellItem = self:buildCellRes(true)
	self:createCell(cellItem)

	attachHead(cellItem.head , uid)

	local userName = getFriendName(uid)
	local nickName = TextUtil:ensureTextWidth(userName, cellItem.name:getFontSize(), cellItem.name:getDimensions())
	if nickName then 
		cellItem.name:setString(nickName) 
	else
		cellItem.name:setString(userName)
	end

	self:initCell(container , newRank-1 , cellItem , uid , score , globalRank)
	cellItem:setPositionY(0)

	--
	local size = cellItem:getGroupBounds().size
	size = CCSizeMake(size.width, size.height)

	local contest = self
	function container:playEffect()
		local mask = LayerColor:createWithColor(ccc3(0, 0, 0), size.width, size.height - 25)
		mask:setScale(0.95)
		mask:ignoreAnchorPointForPosition(false)
		mask:setAnchorPoint(ccp(0, 1))
		mask:setPosition(ccp(12, -5))
		local clipNode = ClippingNode.new(CCClippingNode:create(mask.refCocosObj))
		mask:dispose()
		self:addChild(clipNode)

		local animLight = ArmatureNode:create("2017SummerWeekly/interface/RankItemEffect", true)
		if animLight then
			animLight:setScale(0.8)
			animLight:setPosition(ccp(0, -26))

			clipNode:addChild(animLight)
			animLight:playByIndex(0)
		end
	end
	return true
end

function SeasonWeeklyRankingListRender:dispose()
	self.basePanel = nil
	self.resGroupName = nil
	self.isDisposed = true
	
	self.id2Items = nil

	if self.cellItems then
		for k,v in pairs(self.cellItems) do
			v:removeAllEventListeners()
			v:removeFromParentAndCleanup(true)
			v:dispose()
			self.cellItems[k] = nil
		end
	end
	self.cellItems = nil

	if self.container then
		self.container:dispose()
	end
	self.container = nil
end