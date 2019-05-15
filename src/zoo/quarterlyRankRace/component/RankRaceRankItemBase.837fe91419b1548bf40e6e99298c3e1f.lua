local RankRaceRankItemBase = class(ItemInClippingNode)

function RankRaceRankItemBase:ctor()
end

function RankRaceRankItemBase:init(itemData)
	ItemInClippingNode.init(self)

	self.builder = InterfaceBuilder:createWithContentsOfFile("ui/RankRace/MainPanel.json")
	self.ui = self.builder:buildGroup(self:getItemGroupName())

	self.itemData = itemData
	local data = itemData.data

	--外发光
	self.light1 = self.ui:getChildByName("light1")
    self.light1:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
    self.light1:setVisible(false)

	self.light2 = self.ui:getChildByName("light2")
    self.light2:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
    self.light2:setVisible(false)

    --头像--名字
    local headUrl = data.headUrl
    local nameStr = data.name
    if tonumber(data.uid) == tonumber(UserManager:getInstance().user.uid) then
        headUrl = UserManager:getInstance().profile.headUrl
        nameStr = UserManager:getInstance().profile.name
    end
    local headIcon = self.ui:getChildByName("head")
    local profile
    if data.headFrame then 
    	profile = {headFrame = data.headFrame,
				headFrames = {
					{id = data.headFrame, obtainTime = 0, expireTime = 0}
				}}
    end
    LogicUtil.loadUserHeadIconWithFrame(data.uid, headIcon, headUrl, profile)

    nameStr = LogicUtil.decodeUrlName(nameStr, 8)
    local userNameUI = self.ui:getChildByName("name")
    local nickName = TextUtil:ensureTextWidth(nameStr, userNameUI:getFontSize(), userNameUI:getDimensions())
	if nickName then 
		userNameUI:setString(nickName) 
	else
		userNameUI:setString(nameStr)
	end

	--分数
    local iconUI = self.ui:getChildByName("icon")
    local collectionPos = iconUI:getPosition()
    local collectionSize = iconUI:getGroupBounds().size
    local collectionNum = BitmapText:create("", 'fnt/mark_tip.fnt')
    collectionNum:setAnchorPoint(ccp(0, 0.5))
    self.ui:addChild(collectionNum)
    collectionNum:setPosition(ccp(collectionPos.x + collectionSize.width, collectionPos.y - collectionSize.height/2 + 2))
    if data.score and data.score > 0 then 
    	collectionNum:setText(data.score)
    else 
        collectionNum:setText(localize("rank.race.main.2"))
    end

    --名次
    local rankUI = self.ui:getChildByName("rank")
    self.golden = rankUI:getChildByName("t1")
    self.silver = rankUI:getChildByName("t2")
    self.bronze = rankUI:getChildByName("t3")
    self.normal = rankUI:getChildByName("t4")
    local normalSize = self.normal:getContentSize()
    self.rankLabel = BitmapText:create("", 'fnt/login_alert_cash_num.fnt')
    self.rankLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.normal:addChild(self.rankLabel)
    self.rankLabel:setPosition(ccp(normalSize.width/2, normalSize.height/2))

    self:setContent(self.ui)

    self.ui:setTouchEnabled(true, 0, true, nil, true)
    self.ui:ad(DisplayEvents.kTouchTap, function(evt) 
        self:onItemTapped(evt) 
    end)
end

function RankRaceRankItemBase:onItemTapped(evt)
    self:showCardPanel()
end

function RankRaceRankItemBase:setRankIndex(rankIndex)
	self.rankIndex = rankIndex

	self.golden:setVisible(rankIndex == 1)
	self.silver:setVisible(rankIndex == 2)
	self.bronze:setVisible(rankIndex == 3)
	self.normal:setVisible(rankIndex > 3)
	if rankIndex > 3 then 
		self.rankLabel:setText(rankIndex)
		-- self.rankLabel:setScale(1)
	end
end

function RankRaceRankItemBase:getItemOriSize()
	return {width = 720, height = 110}
end

function RankRaceRankItemBase:update()
	
end

function RankRaceRankItemBase:getItemGroupName()
	assert(false, "must be overrided")
end

function RankRaceRankItemBase:getHeight()
	assert(false, "must be overrided")
end

return RankRaceRankItemBase