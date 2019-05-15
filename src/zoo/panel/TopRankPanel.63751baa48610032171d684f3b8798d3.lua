require 'zoo.panel.component.common.VerticalTileItem'

TopRankPanel = class(BasePanel)

function TopRankPanel:create( ranks )
	local panel = TopRankPanel.new()
	panel:loadRequiredResource("ui/top_rank_panel.json")
	panel:init(ranks)
	return panel
end

function TopRankPanel:init( ranks )
	self.ranks = ranks

	if #self.ranks == 1 then
		self.ui = self:buildInterfaceGroup("clearance_rank_panel_1")
	else
		self.ui = self:buildInterfaceGroup("clearance_rank_panel_2")
	end
	BasePanel.init(self,self.ui)

	table.sort(ranks,function( a,b ) 
		local at = tonumber(a.timeStamp) or -1
		local bt = tonumber(b.timeStamp) or -1

		if at <= 0 and bt <= 0 then
			return a.uid < b.uid
		elseif at <= 0 then
			return false
		elseif bt <= 0 then
			return true
		else
			return at < bt
		end
	end)

	local top = self.ui:getChildByName("top")
	local bottom = self.ui:getChildByName("bottom")

	self:initTop(top)
	if bottom then
		self:initBottom(bottom)
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	self.ui:setPositionX(visibleSize.width/2)
	self.ui:setPositionY(-visibleSize.height/2)

	local noCloseArea = self.ui:getChildByName("noCloseArea")
	if noCloseArea then
		noCloseArea:setVisible(false)
		self.ui:setTouchEnabled(true)
		function self.ui:hitTestPoint( worldPosition, useGroupTest )
			return not noCloseArea:hitTestPoint(worldPosition, useGroupTest)
		end
		self.ui:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:onKeyBackClicked()
		end)
	end

	local closeBtn = self.ui:getChildByName("closeBtn")
	if closeBtn then
		closeBtn:setTouchEnabled(true)
		closeBtn:setButtonMode(true)
		closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:onKeyBackClicked()
		end)
	end
end

function TopRankPanel:getName( rank )
	return FriendManager:getInstance():getFriendName( rank.uid )
end

function TopRankPanel:getTime( rank )
	if tonumber(rank.timeStamp) <= 0 then
		return "通关时间未知"
	end

	local t = os.date("*t",tonumber(rank.timeStamp)/1000)
	return string.format(
		"%d-%d-%d %02d:%02d",
		t.year,
		t.month,
		t.day,
		t.hour,
		t.min
	)
end


function TopRankPanel:initTop( top )

	local headPos = top:getChildByName("headPos")
	headPos:setVisible(false)
	local headImage = HeadImageLoader:createWithFrame(
		self.ranks[1].uid,
		FriendManager:getInstance():getFriendHeadUrl(self.ranks[1].uid)
	)
	headImage:setPositionX(headPos:getPositionX())
	headImage:setPositionY(headPos:getPositionY())
	headImage:setScale(150/100)
	top:addChildAt(headImage,1)

	local name = top:getChildByName("name")
	name:setString(self:getName(self.ranks[1]))

	local time = top:getChildByName("time")
	time:setString(self:getTime(self.ranks[1]))

	local rank = top:getChildByName("rank")
	rank:setAnchorPoint(ccp(0.5,1))
	rank:setPositionX(rank:getPositionX() + 267/2)
	if self.ranks[1].rank > 0 then
		rank:setRichText("全国第[#FFFF00]".. self.ranks[1].rank .."[/#]名","FFFFFF")
	else
		rank:setRichText("好友排名第一","FFFFFF")
	end

end

function TopRankPanel:initBottom( bottom )
	local listArea = bottom:getChildByName("listArea")
	listArea:setVisible(false)
	local listBounds = listArea:boundingBox()

	local layout = VerticalTileLayout:create(listBounds.size.width)
	layout:setItemVerticalMargin(5)
	for i=2,#self.ranks do
	-- for i=2,5 do
		-- local i = 2
		local cell = self:buildInterfaceGroup("cell")
		local rankLabel	= cell:getChildByName("rankLabel")
		rankLabel:setFontSize(30)
		rankLabel:setString(tostring(i))


		local headImage = HeadImageLoader:createWithFrame(
			self.ranks[i].uid,
			FriendManager:getInstance():getFriendHeadUrl(self.ranks[i].uid)
		)
		local headContainer = cell:getChildByName("head")
		local size = headContainer:getContentSize()
		headImage:setPositionX(size.width/2)
		headImage:setPositionY(size.height/2)
		headImage:setScaleX(size.width/100)
		headImage:setScaleY(size.height/100)
		headContainer:addChild(headImage)

		local name = cell:getChildByName("name")
		name:setString(self:getName(self.ranks[i]))

		local time = cell:getChildByName("time")
		time:setString(self:getTime(self.ranks[i]))

		local rank = cell:getChildByName('rank')
		if tonumber(self.ranks[i].rank) == 0 then
			rank:setVisible(false)
		else
			local t = rank:getChildByName('t')
			t:setString(string.format('第%d名', tonumber(self.ranks[i].rank)))
		end

		local item = VerticalTileItem.new(CCNode:create())
		item:setContent(cell)
		item:setHeight(95)

		layout:addItem(item)
	end
	local scroll = VerticalScrollable:create(
		listBounds.size.width,
		listBounds.size.height
	)
	scroll:setPositionX(listBounds:getMinX())
	scroll:setPositionY(listBounds:getMaxY())
	scroll:setContent(layout)

	bottom:addChild(scroll)
end


function TopRankPanel:popout( ... )
	PopoutManager:sharedInstance():add(self, true, false)
end
function TopRankPanel:onKeyBackClicked( ... )
	PopoutManager:sharedInstance():remove(self)
end


function TopRankPanel.popoutIfNecessary( friendIdList )
	local function onSuccess( evt )
		if evt.data.ranks and #evt.data.ranks > 0 then
			TopRankPanel:create(evt.data.ranks):popout()
		end
	end

	local function onFail( evt )
        if evt and evt.data then 
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		end
	end

	-- do 
	-- 	onSuccess({data={ranks={
	-- 		{ uid = 1,rank=2,timeStamp=-1 },
	-- 		{ uid = 1,rank=1,timeStamp=1464941823501 }
	-- 	}}})
	-- 	return
	-- end

	local http = getFriendSingleLevelRank.new(true)	
	http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
	http:syncLoad(friendIdList,kMaxLevels)

end