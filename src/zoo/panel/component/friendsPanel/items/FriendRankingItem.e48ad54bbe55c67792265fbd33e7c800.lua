local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"
local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

FriendRankingItem = class(ItemInClippingNode)

local COLOR_LABLE_BLUE = ccc3(0,102,153)
local COLOR_LABLE_YELLOW = ccc3(127,77,7)

function FriendRankingItem:create()
	local instance = FriendRankingItem.new()
	instance:loadRequiredResource(PanelConfigFiles.friends_panel)
	instance:init()
	return instance
end

function FriendRankingItem:ctor()
	self.name = 'FriendRankingItem'
	self.debugTag = 0
	self.itemFoldHeight = 119
	self.itemExtendHeight = nil --之后初始化这个值
	self.starPosXOffset = 55
end

function FriendRankingItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function FriendRankingItem:unloadRequiredResource()
end

function FriendRankingItem:init()
	local ui = self.builder:buildGroup('interface/friendRankingPanelItem')

	VerticalTileItem.init(self,ui)

	self.golden = ui:getChildByName('goldenCrown')
	self.silver  = ui:getChildByName('silverCrown')
	self.bronze = ui:getChildByName('bronzeCrown')
	self.normal = ui:getChildByName('normal')

	self.selectedIcon = ui:getChildByName('selectedIcon')
	self.selectedIcon:setVisible(false)
	self.selectedBtn = ui:getChildByName('selectedBtn')
	self.selectedBtn:setVisible(false)
	self.selectedBtn.setSelected = function(isSelected)
		self.selectedIcon:setVisible(isSelected)
		self.selectedBtn:getChildByName("disableBox"):setVisible(not isSelected)
		self.selectedBtn:getChildByName("enableBox"):setVisible(isSelected)
	end
	self.selectedBtn:setTouchEnabled(true,0,true)
	self.selectedBtn:ad(DisplayEvents.kTouchTap, function(event)
		if self.isDelState then
			-- 多选删除模式
			local isEnable = not self.selectedIcon:isVisible()
			self.selectedBtn.setSelected(isEnable)
			local _ = self.selectDelCallback and self.selectDelCallback(isEnable,self.profile.uid)
			return
		end
	end)
	self.selectedBtn.setSelected(false)
	-- self.selectedBtn:setTouchEnabled(true, 0, true)
	-- self.selectedBtn:ad(DisplayEvents.kTouchTap, function(event)
	-- end)

	self.conRight = CocosObject:create()
	ui:addChild(self.conRight)

	local function changeParent(item,newParent)
		local zOrder = item:getZOrder()
		item:removeFromParentAndCleanup(false)
		newParent:addChildAt(item,zOrder)
	end
	self.friendSource = ui:getChildByName('friendSource')

	self.homeBtn = ui:getChildByName('homeBtn')
	self.homeBtn.redDot = self.homeBtn:getChildByName('redDot')
	self.homeBtn.imgMine = self.homeBtn:getChildByName('imgMine')
	self.homeBtn.imgFriend = self.homeBtn:getChildByName('imgFriend')
	self.homeBtn.redDot:setVisible(false)
	self.homeBtn:setTouchEnabled(true, 0, true,nil,true)
	self.homeBtn:ad(DisplayEvents.kTouchTap, function(event)
			-- UserManager:getInstance().inviteCode
			FAQ:openFAQPersonalCenter(not self:isOwner() and self.user.inviteCode)

			local params = {}
			params.category = "add_friend"
			params.sub_category = self:isOwner() and "G_comment_myself" or "G_comment"
			DcUtil:UserTrack(params)

			if self.homeBtn.redDot:isVisible() and self:isOwner() then
				self.homeBtn.redDot:setVisible(false)
				local item = self.friendRankingPanel.itemSelf

				local _ = item and item.homeBtn and item.homeBtn.redDot:setVisible(false)
			    UserManager:getInstance():updateCommunityMessageVersion()
			end
		end)
	changeParent(self.homeBtn,self.conRight)

	self.star = ui:getChildByName('star')
	self.labelStar = ui:getChildByName("labelStar")
	self.labelStar:setAnchorPoint(ccp(0.5, 1))
	local xPos = self.labelStar:getPositionX()
	self.labelStar:setPositionX(xPos + 36)

	self.labelRank = ui:getChildByName("labelRank")

	self.levelLabel = ui:getChildByName('levelLabel')
	self.levelLabel:setAnchorPoint(ccp(0.5, 0.5))
	local pos = self.levelLabel:getPosition()
	self.levelLabel:setPosition(ccp(pos.x + 60, pos.y - 19))

	self.bgLevelNormal = ui:getChildByName('bgLevelNormal')
	self.bgLevelOwner = ui:getChildByName('bgLevelOwner')

	self.rankLabel = ui:getChildByName("rankLabel")
	self.rankLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- self.rankLabel:setPosition(ccp(30, -26))

	self.bgNormal = ui:getChildByName('bgNormal')
	self.bgSelected = ui:getChildByName('bgSelected')
	self.bgMyself = ui:getChildByName('bgMyself')

	self.avatar = ui:getChildByName('avatar')
	-- self.avatar:getChildByName('bg'):removeFromParentAndCleanup(true)
	self.nameLabel = ui:getChildByName('labelName')

	self.normalSend = ui:getChildByName('normalSendBtn')
	self.normalSend:ad(DisplayEvents.kTouchTap, function(event) self:onSendBtnTap(event) end)

	self.greySend = ui:getChildByName('greySendBtn')
	self.greySend:ad(DisplayEvents.kTouchTap, function(event) self:onGreyBtnTap(event) end)

	self.lbAlreadySend = self.ui:getChildByName('lbAlreadySend')
	self.lbAlreadySend:setVisible(false)

	changeParent(self.normalSend,self.conRight)
	changeParent(self.greySend,self.conRight)
	changeParent(self.lbAlreadySend,self.conRight)

	self:setContent(ui)

	local touchArea = self.ui:getChildByName("title_touch_area")
	touchArea:setTouchEnabled(true, 0, true)
	touchArea:ad(DisplayEvents.kTouchTap, function(event) 
		self:onItemTapped(event) 
	end)
	self.touchArea = touchArea
	self.touchAreaScaleX = self.touchArea:getScaleX()

	self:showSendButton(false)

	if MaintenanceManager:getInstance():isEnabled("FriendDebug", false) then
		local text = TextField:create("--", nil, 20, CCSizeMake( 200 , 0), nil, kCCVerticalTextAlignmentLeft)
		text:setColor(ccc3(0,0,0))
		text:setPositionXY(550,-30)
		self.ui:addChild(text)
		self.txtDebug = text
	end
end

function FriendRankingItem:initContent()
	if self:isOwner() then
		return
	end
	local friend_item_content = self.builder:buildGroup('interface/friend_item_content')
	self.itemContent = friend_item_content
	self.ui:addChildAt(self.itemContent, 1)
	self.itemContent:setPositionY(self.ui:getChildByName('bgNormal'):getPositionY() - 100)

	self.labelACG = self.itemContent:getChildByName('lbDesc')
	self.labelACG:setString(localize("friends.panel.unknow.acg"))

	self.itemExtendHeight = self.itemFoldHeight + self.itemContent:getGroupBounds().size.height - 20

	self.btnDel = self.itemContent:getChildByName('btnDel')
	self.btnDel:setTouchEnabled(true, 0, true)
	self.btnDel:ad(DisplayEvents.kTouchTap, function(event) self:onDelBtnTap(event) end)

	local function shouldShowBtnDel()
		if WXJPPackageUtil.getInstance():isWXJPPackage() then return true end
	end
	if shouldShowBtnDel() then
		self.btnDel:setTouchEnabled(false)
		self.btnDel:setVisible(false)
	end

	self:initAchievement()
	self:initAchievementIcon(self.user)
end

function FriendRankingItem:playStarAnim1to2()
	if self.ui == nil or self.ui.isDisposed then return end
end

function FriendRankingItem:playStarAnim2to1()
	if self.ui == nil or self.ui.isDisposed then return end
end

function FriendRankingItem:changeTimeSort(isTimeSort)
	local function time2day(ts)
		ts = ts * 0.001
		local utc8TimeOffset = 57600 -- (24 - 8) * 3600
		local oneDaySeconds = 86400 -- 24 * 3600
		local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
		return (dayStart + 8*3600)/24/3600
	end

	if isTimeSort then
		local str = "最后登录 999日前"
		local currentDay = time2day(Localhost:time())
		local fDay = time2day(self.profile.lastLoginTime or 0)
		-- print("fDay",fDay,currentDay,Localhost:time(),(self.profile.lastLoginTime or 0)*0.001,os.date("%y-%m月%d日 %H:%M:%S", (self.profile.lastLoginTime or 0)*0.001 ))
        day = currentDay-fDay

		if day<1 then
			str = "最后登录 今日"

		elseif day<30 then
			str = "最后登录 "..day .."日前"

		elseif day<365 then
			str = "最后登录 ".. math.max(math.floor(day/30),1) .."个月前"
		else
			str = "最后登录 1年前"
		end
		self.labelRank:setString(str)
	else
		self:initRanking()
	end
end

function FriendRankingItem:onItemTapped(event, notUserTap)
	local panel = require("zoo.PersonalCenter.FriendInfoPanel"):create(self.user.uid,{
		delCallback = self.afterDeleteFriendCallback,
		strRank = self.labelRank:getString()
		})
    DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="1",t2=(self:isOwner() and 0 or 1)}, true)
	do return end

	if self:isOwner() then
		return
	end

	if self.beforeToggleCallback then
		self.beforeToggleCallback(self, notUserTap)
	end
	
	if self.itemContent then
		self:foldItem()
		self.friendRankingPanel:fold()
	else
		self:initContent()

		self:setHeight(self.itemExtendHeight)


	    local winSize = Director:sharedDirector():getWinSize()

		local offsetY = -self:getPositionY() - self.itemFoldHeight*(winSize.height>=1280 and 3 or 1) - 50
		local function updatePos()
			if self.friendRankingPanel.expandItemIndex == nil or self.friendRankingPanel.expandItemIndex > self.itemIndex then
				if self:getPositionInWorldSpace().y < 700 then
					offsetY = math.max(0, offsetY)
					self.view:gotoPositionY(offsetY)
				end
			else
				if self:getPositionInWorldSpace().y < 700 then
					offsetY = offsetY - self.itemExtendHeight + self.itemFoldHeight
					offsetY = math.max(0, offsetY)
					self.view:gotoPositionY(offsetY)
				end
			end
		end

		local n = 0
		if self.friendRankingPanel.friendList then
			n=#self.friendRankingPanel.friendList
		end
		if self.itemIndex>=n-1 then
			offsetY = offsetY+self.itemExtendHeight
			setTimeOut(updatePos,0.1)
		else
			updatePos()
		end

		-- debug
		self:refreshProfile(self.profile)
		self.friendRankingPanel:expandItem(self.itemIndex)
	end

	if self.afterToggleCallback then
		self.afterToggleCallback(notUserTap)
	end
end

function FriendRankingItem:foldItem()
	if self.itemContent then
		self.itemContent:removeFromParentAndCleanup(true)
		self.itemContent:dispose()
		self.itemContent = nil
		self:setHeight(119)
	end
end

function FriendRankingItem:setAfterToggleCallback(callback)
	self.afterToggleCallback = callback
end

function FriendRankingItem:setBeforeToggleCallback(callback)
	self.beforeToggleCallback = callback
end

--好友栏删除（已废弃）
function FriendRankingItem:setDelFriendCallback(callback)
	self.deleteFriendCallback = callback
end

--好友面板删除
function FriendRankingItem:setAfterDelFriendCallback(callback)
	self.afterDeleteFriendCallback = callback
end

function FriendRankingItem:setData(data)
	if self.txtDebug then
		local list = {
			tostring(data.uid).."--"..tostring(data.topLevelId),
			data.lastLoginTime and os.date("%c",data.lastLoginTime*0.001) or "----",
			"friendSource:" .. tostring(data.friendSource) .. ":" .. AskForHelpManager:getPlatformEnum(data.friendSource or 0),
		}
		self.txtDebug:setString(table.concat(list,"\n"))
	end

	self.user = data
	self.profile = data

	if data.achievement and data.achievement.achievements then
		table.sort(data.achievement.achievements, 
			function(ach1, ach2) 
				return ach1.id > ach2.id 
			end)
	end

	self:initRanking()
	self:refreshUserInfo(data)
	self:refreshProfile(data)

	if self:isOwner() then
		self.homeBtn.imgMine:setVisible(true)
		self.homeBtn.imgFriend:setVisible(false)

		self.bgMyself:setVisible(true)
		self.bgSelected:setVisible(false)
		self.bgNormal:setVisible(false)

		self.bgLevelNormal:setVisible(false)
		self.bgLevelOwner:setVisible(true)

		self.friendRankingPanel.itemSelf = self

	else 
		self.homeBtn.imgMine:setVisible(false)
		self.homeBtn.imgFriend:setVisible(true)

		self.bgLevelNormal:setVisible(true)
		self.bgLevelOwner:setVisible(false)
	end

	self:refresh()
end

function FriendRankingItem:refresh()
	if self.isDisposed then return end

	if self:isOwner() then
		self.lbAlreadySend:setVisible(false)
		self.greySend:setVisible(false)
		self.greySend:setTouchEnabled(false)

		self.normalSend:setVisible(false)
		self.normalSend:setTouchEnabled(false)
		self.normalSend:setButtonMode(false)
		return
	end

	local txtList = {
		self.levelLabel,
		self.labelStar,
		self.labelRank,
		self.nameLabel,
	}
	for i,v in ipairs(txtList) do
		v:setColor(COLOR_LABLE_BLUE)
	end

	-- if self:canSend() then
	-- 	self.greySend:setVisible(false)
	-- 	self.greySend:setTouchEnabled(false)

	-- 	self.normalSend:setVisible(true)
	-- 	self.normalSend:setButtonMode(true)
	-- 	self.normalSend:setTouchEnabled(true, -5, true)

	-- elseif self:hasSendTo() then
	-- 	self.lbAlreadySend:setVisible(true)
	-- 	self.greySend:setVisible(false)
	-- 	self.greySend:setTouchEnabled(false)

	-- 	self.normalSend:setVisible(false)
	-- 	self.normalSend:setTouchEnabled(false)
	-- 	self.normalSend:setButtonMode(false)
	-- else
	-- 	self.greySend:setVisible(true)
	-- 	self.greySend:setTouchEnabled(true, -5, true)

	-- 	self.normalSend:setVisible(false)
	-- 	self.normalSend:setTouchEnabled(false)
	-- 	self.normalSend:setButtonMode(false)
	-- end
end

local icon_achievement_ids = {}
local show_level_achievements = {}
local tipCreator = nil

function FriendRankingItem:initAchiConfig()
	if tipCreator ~= nil then return end

	local achis = Achievement:getAchis()
	for id,achi in pairs(achis) do
		if achi.type ~= AchiType.SHARE then
			table.insert(icon_achievement_ids, id)
		end
		if achi.type == AchiType.PROGRESS then
			table.insert(show_level_achievements, id)
		end
	end

	table.insert(icon_achievement_ids, "q")

	tipCreator = {
		[AchiId.kNStarReward] = function(data)
					local achi = Achievement:getAchi(AchiId.kNStarReward)
					return localize("show_off_desc_"..data.id, {num = achi:getCurTarCount(data.level)})
				end,
		[AchiId.kFiveTimesFourStar] = function(data)
					local starNum = data.level * 5
					return localize("show_off_desc_70_1", {num = starNum})
				end,
		[AchiId.kUnlockNewObstacle] = function ( data )
					local achi = Achievement:getAchi(AchiId.kUnlockNewObstacle)
					return localize("show_off_desc_50_1", {num = achi:getCurTarCount(data.level)})
			   end,
		[AchiId.kScorePassThousand] = function(data)
					return localize("show_off_desc_10_1")
				end,
		[AchiId.kTotalGetLikeCount] = function ( data )
				-- local num = data.level * 100
				local achi = Achievement:getAchi(AchiId.kTotalGetLikeCount)
				return localize("show_off_desc_200",{num = achi:getCurTarCount(data.level)})
			end,
		[AchiId.kAreaFullStar] = function ( data )
				return localize("achievement_desc_220_2")
			end,
		[AchiId.kTotalUseCoinCount] = function ( data, item )
				local achi = Achievement:getAchi(AchiId.kTotalUseCoinCount)
				local num = achi:getCurTarCount(data.level) / 10000
				if num > 9999 then
					num = tostring(num).."亿"
				else
					num = tostring(num).."万"
				end
				return localize("show_off_desc_430",{num = num})
			end,
		[AchiId.kTotalGetFruitCount] = function ( data, item )
				local achi = Achievement:getAchi(AchiId.kTotalGetFruitCount)
				return localize("show_off_desc_240",{num = achi:getCurTarCount(data.level)})
			end,
		[AchiId.kTotalEntryWeeklyCount] = function ( data, item )
				local achi = Achievement:getAchi(AchiId.kTotalEntryWeeklyCount)
				return localize("show_off_desc_460",{n = achi:getCurTarDate(data.level),num = achi:getCurTarCount(data.level)})
			end,
	}
end

function FriendRankingItem:initAchievementIcon(user)
	local score = Achievement:getFriendScore(user)
	local achiLevel = Achievement:getLevelByScore(score)
	
	local icon = self.itemContent:getChildByName('icon_achivement')
	self.iconAchievement = icon

	local state = Achievement:getState()
	local medalType = achiLevel

    local iconP = icon:getChildByName("icon")
    for i=1,state.maxLevel do
    	iconP:getChildByName(tostring(i-1)):setVisible(achiLevel == i)
    end

    local isNone = achiLevel == 1
    -- 新需求，好友没有任何成就时，不显示任何勋章图标，所以要隐藏默认图标
    if isNone and tonumber(self.user.uid) ~= tonumber(UserManager.getInstance().user.uid) then
	    iconP:getChildByName("0"):setVisible(false)
	    -- 调整 右侧文字位置
	    local widgetsToAdjust = {
	    	-- self.itemContent:getChildByName('lbl_percent'),
	    	self.itemContent:getChildByName('star_tip1'),
	    	-- self.itemContent:getChildByName('star_tip2'),
	    	self.itemContent:getChildByName('star_tip3'),
	    	self.itemContent:getChildByName('rank_tip_bg')
		}

		local offsetX = -45
		table.each(
			widgetsToAdjust,
			function(widget)
				local x = widget:getPositionX()
				x = x + offsetX
				widget:setPositionX(x)
			end
		)
	end
end

function FriendRankingItem:isOwner()
	return self.user.uid == UserManager:getInstance().user.uid
end

function FriendRankingItem:initRanking()
	function onLogined()
		if self.isDisposed then return end
		local starNum = self.user:getTotalStar() or 0
		if starNum <= 0 then --没有星星
			self.labelStar:setText(tostring(0))
			self.labelRank:setString(localize('my.card.panel.text1.1'))
		else
			local rank100 = 0
			local starGlobalRank = 0
			if self.user.achievement then
				rank100 = self.user.achievement.pctOfRank
				starGlobalRank = self.user.achievement.starGlobalRank or starGlobalRank
			end

            if starGlobalRank and starGlobalRank > 0 then
                if starGlobalRank == 1 then
                    rank100 = 10000
                end
			end
			
			if starGlobalRank > 0 and starGlobalRank < 100000 then
				local tips = string.format(" 总星级全国第%d名", starGlobalRank)
				self.labelRank:setString(tips)
			else
				local pctRank = rank100 / 100
				local pct = (100 - math.min(pctRank, 100))
				pct = math.max(0.01, pct)
				pct = math.min(99.99, pct)
				if pct > 99 then
					local tips = string.format(" 总星级暂未上榜")
					self.labelRank:setString(tips)
				else
					local tips = string.format(" 总星级全国前 %.2f", pct)
					self.labelRank:setString(tips .."%")
				end
			end
			self.labelStar:setText(tostring(starNum))
		end
		-- change color
		local color = COLOR_LABLE_BLUE
		if self:isOwner() then
			color = COLOR_LABLE_YELLOW
		end
		self.labelStar:setColor(color)
	end
	function onLoginFail()
		if self.isDisposed then return end
		self.labelStar:setText(tostring(0))
		self.labelRank:setString(localize('my.card.panel.text1.1'))
	end
	RequireNetworkAlert:callFuncWithLogged(onLogined, onLoginFail, nil, kRequireNetworkAlertTipType.kNoTip)
end

function FriendRankingItem:initAchievement()
	self:initAchiConfig()

	local filterd = self.user.achievement and self.user.achievement.achievements or {}
	filterd = filterd or {}

	local achievements = {}

	for id,achi in pairs(filterd) do
		local node = Achievement:getAchi(achi.id)
		if node == nil then
			node = Achievement:getAchi(tonumber(achi.id))
		end
		if node and achi.level > 0 then
			table.insert(achievements, achi)
		end
	end

	-- if _G.isLocalDevelopMode then printx(0, table.tostring(self.user)) end

	table.sort(
		achievements, 
		function(a, b)
			local achiA = Achievement:getAchi(a.id)
			local achiB = Achievement:getAchi(b.id)
			if configA and configB then
				return configA.priority < configB.priority
			else
				return false
			end
		end
	)

	-- if _G.isLocalDevelopMode then printx(0, table.tostring(achievements)) end
	if #achievements == 0 then
		self.itemContent:getChildByName("label_no_achievement"):setString('')
		local pos = self.itemContent:getChildByName("label_no_achievement"):getPosition()
		local label_no_achievement = LabelBMMonospaceFont:create(36, 36, 36, 'fnt/green_button.fnt')
		self.itemContent:addChild(label_no_achievement)
		label_no_achievement:setString(localize('achievement_panel_no_metal'))
		label_no_achievement:setPositionXY(pos.x, pos.y - 50)
		label_no_achievement:setToParentCenterHorizontal()

		self.itemContent:getChildByName("achivement_rect"):setVisible(false)
		
		for i=1,3 do
			self.itemContent:getChildByName("achivement_bg"..i):setVisible(false)
			self.itemContent:getChildByName("achievement"..i):setVisible(false)
		end
		return
	end
	for i=1, 3 do
		self.itemContent:getChildByName("achivement_rect"):setVisible(true)
		local iconAchievement = self.itemContent:getChildByName("achievement"..i)
		if achievements[i] then
			iconAchievement:setTouchEnabled(true, 0 , true)
			iconAchievement:ad(DisplayEvents.kTouchTap, function() 
					-- if _G.isLocalDevelopMode then printx(0, "onItem touched!!!!!!!!!!!!!!, "..i) end
					local achi = Achievement:getAchi(tonumber(achievements[i].id))
					local config = achi:getShareConfig()
					local builder = InterfaceBuilder:create(PanelConfigFiles.bag_panel_ui)
					local content = builder:buildGroup('bagItemTipContent')
					local desc = content:getChildByName('desc')
					local title = content:getChildByName('title')
					local sellBtn = content:getChildByName('sellButton')
					local useBtn = content:getChildByName('useButton')

					sellBtn:removeFromParentAndCleanup(true)
					sellBtn:dispose()
					useBtn:removeFromParentAndCleanup(true)
					useBtn:dispose()
					title:setString(localize(config.keyName))

					local createFunc = tipCreator[achievements[i].id]
					if createFunc then
						desc:setString(createFunc(achievements[i], self))
					else
						desc:setString(localize(config.shareTitle, {num = achi:getCurTarCount(achievements[i].level)}))
					end
					local tip = BubbleTip:create(content, 105)
					tip:show(iconAchievement:getGroupBounds())
				end)

			for _,achiId in ipairs(icon_achievement_ids) do
				local tarId = achievements[i].id
				iconAchievement:getChildByName("q"):setVisible(tarId == "q")
				if achiId == tarId then
					local level = achievements[i].level
					local icon_id = tarId
					-- if icon_id == 520 then
					-- 	icon_id = 70
					-- end
					local achi_icon = SpriteColorAdjust:createWithSpriteFrameName('achievement/icon/icon_'..icon_id..'0000')
					achi_icon:setPosition(ccp(62, -60))
					iconAchievement:addChild(achi_icon)

					local achi = Achievement:getAchi(tarId)
					level = achi:checkLevel(level)

					if achi.type == AchiType.PROGRES then
						local numText = BitmapText:create(level..'级', "fnt/register2.fnt")
						numText:setScale(0.7)
						numText:setPosition(ccp(70, 32))
						achi_icon:addChild(numText)
					end

					if tarId == AchiId.kUnlockNewObstacle then
						local count = achi:getCurTarCount(level)
						local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
						local name = "area_icon_"..obstacleConfig[count].."0000"
            			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) == nil then
            				FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
            			end
            			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) ~= nil then
	            			local obstacle = Sprite:createWithSpriteFrameName(name)
	            			achi_icon:addChild(obstacle)
	            			obstacle:setScale(0.51)
	            			local size = achi_icon:getContentSize()
	            			obstacle:setAnchorPoint(ccp(0.5, 0.5))
	            			obstacle:setPositionXY(72, 82)
	            		end
					end
				end
			end
		else
			iconAchievement:setVisible(false)
		end
	end
end

function FriendRankingItem:refreshUserInfo(user)
	self.canNotBeDeleted = false
	if WXJPPackageUtil.getInstance():isWXJPPackage() then
		self.canNotBeDeleted = FriendManager.getInstance():isSnsFriend(user.uid)
	end

	local level = user.topLevelId
	if not level or level == '' then 
		level = 1
	end

	local color = COLOR_LABLE_BLUE
	if self:isOwner() then
		color = COLOR_LABLE_YELLOW
	end
	self.levelLabel:setColor(color)
	self.levelLabel:setText(Localization:getInstance():getText('level.number.label.txt', {level_number = level}))
end

function FriendRankingItem:refreshProfile(profile)
	-- print("profile.uid",profile.uid,profile.communityUser,debug.traceback())
	local profile = profile
	if self:isOwner() then
		profile = UserManager:getInstance().profile

		self.homeBtn:setVisible(true)
		self.homeBtn.redDot:setVisible(UserManager:getInstance():isNewCommunityMessageVersion())
	else
		self.homeBtn:setVisible(profile.communityUser)
		self.homeBtn.redDot:setVisible(false)

		if not self.friendRankingPanel.itemFirstCommunity and profile.communityUser then
			self.friendRankingPanel.itemFirstCommunity = self
		end
	end
    if not FAQ:isPersonalCenterEnabled() then
		self.homeBtn:setVisible(false)
	end

	local username = nameDecode(profile.name or '')
	if string.isEmpty(username) then 
		username = 'ID: '..profile.uid
	end

	local size = self.nameLabel:getDimensions()
	size.width = size.width- 60
	local nickName = TextUtil:ensureTextWidth(username, self.nameLabel:getFontSize(), size)
	if nickName then 
		self.nameLabel:setString(nickName) 
	else
		self.nameLabel:setString(username) 
	end
	
	local headUrl = profile.headUrl
	if string.isEmpty(headUrl) then
		headUrl = 1
	end

	self:changePlayerHead(tonumber(profile.uid), headUrl)
	self.levelLabel:setVisible(true)

	if self.labelACG then
		local info = FriendsUtils:ACGINFO(profile)
		if info == "" then
			info = localize("friends.panel.unknow.acg")
		end
		self.labelACG:setString(info)
	end

	local pf = AskForHelpManager:getPlatformEnum(profile.friendSource or 0)
	local img = nil
	if pf == kAskForHelpSnsEnum.EWX then
		img = "wx"
	elseif pf == kAskForHelpSnsEnum.EQQ then
		img = "qq"
	elseif pf == kAskForHelpSnsEnum.EPHONE then
		img = "contact"
	end
	self.friendSource:setVisible(img~=nil)
	if img~=nil then
		for i,v in ipairs(self.friendSource:getChildrenList()) do
			v:setVisible(v.name == img)
		end
	end
end

function FriendRankingItem:isPersonalInfoEdited()
	if not self.profile then return false end

	local age = self.profile.age or 0
	local gender = self.profile.gender or 0
	local constellation = self.profile.constellation or 0

	return tonumber(age) > 0 or tonumber(gender) > 0 or tonumber(constellation) > 0
end

function FriendRankingItem:changePlayerHead(uid, headUrl)
	local function onImageLoadFinishCallback(head)
		if self.isDisposed then return end ---  prevent from crashes
		local headHolder = self.avatar:getChildByName('holder')
		local pos = headHolder:getPosition()
		local headHolderSize = headHolder:getContentSize()
		local tarWidth = headHolderSize.width * headHolder:getScaleX()
		local realWidth = head:getContentSize().width
		local scale = tarWidth / realWidth
		head:setPositionXY(pos.x + tarWidth/2, pos.y - tarWidth/2)
		head:setScale(scale)
		if self.currentHead then
			self.currentHead:removeFromParentAndCleanup(true)
			self.currentHead:dispose()
			self.currentHead = head
		end
		headHolder:setVisible(false)
		self.avatar:addChildAt(head, 0)
	end
	local head = HeadImageLoader:createWithFrame(uid, headUrl)
	onImageLoadFinishCallback(head)
end

function FriendRankingItem:setRank(rank)
	if self.isDisposed then return end
	assert(type(rank) == 'number')
	assert(rank > 0)

	self.golden:setVisible(rank == 1)
	self.silver:setVisible(rank == 2)
	self.bronze:setVisible(rank == 3)
	self.normal:setVisible(rank > 3)

	self.rankLabel:setText(rank)
	self.rankLabel:setVisible(true)
	self.rankLabel:setScale(1)
	if rank > 99 then
		self.rankLabel:setScale(0.66)
	end
end

function FriendRankingItem:setSelectStateChangeCallback(onSelectStateChangeCallback)
	self.onSelectStateChangeCallback = onSelectStateChangeCallback
end

function FriendRankingItem:setSelected(selected)
	if self.isDisposed then return end
	self.selected = selected

	-- self.bgSelected:setVisible(selected)
	-- self.bgNormal:setVisible(not selected)
	self.bgNormal:setVisible(true)
	if self.onSelectStateChangeCallback then
		self.onSelectStateChangeCallback(selected)
	end
end

function FriendRankingItem:showSendButton(doShow)
	if self.isDisposed then return end

-- temp hack: for hiding the send buttons forever
	doShow = false
	if doShow then
		if self:canSend() then
			self.greySend:setVisible(false)
			self.greySend:setTouchEnabled(false)

			self.normalSend:setVisible(true)
			self.normalSend:setTouchEnabled(true, -5, true)
			self.normalSend:setButtonMode(true)
		else
			self.greySend:setVisible(true)
			self.greySend:setTouchEnabled(true, -5, true)

			self.normalSend:setVisible(false)
			self.normalSend:setTouchEnabled(false)
			self.normalSend:setButtonMode(false)
		end
	else
		self.greySend:setVisible(false)
		self.greySend:setTouchEnabled(false)
		
		self.normalSend:setVisible(false)
		self.normalSend:setTouchEnabled(false)
	end
end

function FriendRankingItem:canSend()
	if self.user then
		if self:isOwner() then
			return false
		end 
		return FreegiftManager:sharedInstance():canSendTo(tonumber(self.user.uid))
	else 
		return false
	end
end

function FriendRankingItem:hasSendTo()
	if self.user then
		if self:isOwner() then
			return false
		end 
		return FreegiftManager:sharedInstance():hasSendTo(tonumber(self.user.uid))
	else 
		return false
	end
end

function FriendRankingItem:canRequestFrom(friendId)
	local wantIds = UserManager:getInstance():getWantIds()
	-- if _G.isLocalDevelopMode then printx(0, 'wantIds',table.tostring(wantIds)) end
	return (not table.includes(wantIds, friendId))
end

function FriendRankingItem:getUser()
	return self.user
end

function FriendRankingItem:enableSend()
	if self.isDisposed then return end
	self.greySend:setVisible(false)
	self.greySend:setTouchEnabled(false)

	self.normalSend:setVisible(false)
	self.normalSend:setTouchEnabled(true, -5, true)
	self.normalSend:setButtonMode(true)
end

function FriendRankingItem:disableSend()
	if self.isDisposed then return end

	self.greySend:setVisible(false)
	self.greySend:setTouchEnabled(false)

	self.normalSend:setVisible(false)
	self.normalSend:setTouchEnabled(false)
	self.normalSend:setButtonMode(false)
end

function FriendRankingItem:sendFinished()
	if self.isDisposed then return end

	self.lbAlreadySend:setVisible(true)

	self.greySend:setVisible(false)
	self.greySend:setTouchEnabled(false)

	self.normalSend:setVisible(false)
	self.normalSend:setTouchEnabled(false)
	self.normalSend:setButtonMode(false)
end

function FriendRankingItem:onGreyBtnTap(event)
	CommonTip:showTip(localize('add.friend.panel.energy.send.fail'))
end

function FriendRankingItem:onSendBtnTap(event)
	if not self:canSend() then
		self:disableSend()
		return
	end

	self:disableSend()
	
	local function success(data)
		DataTracking:sendEnergy(true)
		if self.isDisposed then return end
		if self.synchronizer then
			self.synchronizer:onSendSucceeded(self)
		end
		self:sendFinished()
	end

	local function fail(err)
		DataTracking:sendEnergy(false)
		if self.isDisposed then return end
		if self:canSend() then
			self:enableSend()
		end
		if self.synchronizer then
			self.synchronizer:onSendFailed(self)
		end
		local err_code = tonumber(err.data)
		if err_code then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..err.data))
		end
	end
	FreegiftManager:sharedInstance():sendGiftTo(tonumber(self.user.uid), success, fail, true)
	
	if self.synchronizer then
		self.synchronizer:onSendDispatched(self)
	end
end

function FriendRankingItem:onDelBtnTap(event)
	if self.profile then
		self.btnDel:setTouchEnabled(false)
		self.deleteFriendCallback(self.profile.uid)
		self.btnDel:setTouchEnabled(true)
	end
end

function FriendRankingItem:onSelectedIconTap(event)
	self:setSelected(false)
end

function FriendRankingItem:dispose()
	if self.ui ~= nil then self.ui:removeFromParentAndCleanup(true) end
	if self.synchronizer then 
		self.synchronizer:unregister(self) 
		self.synchronizer = nil
	end
	ItemInClippingNode.dispose(self)
	-- print ('FriendRankingItem:dispose', self:getArrayIndex())
end

function FriendRankingItem:setView(view)
	self.view = view
end

function FriendRankingItem:setIndex(index)
	--不能用 index 字段，被底层 CocosObject 已保留
	self.itemIndex = index

end

function FriendRankingItem:setPanel(panel)
	self.panel = panel
end

function FriendRankingItem:setFriendRankingPanel(panel)
	self.friendRankingPanel = panel
end

function FriendRankingItem:changeDelState(isDelState,selectDelCallback,isChoose)
	if self:isOwner() then return end
	self.selectDelCallback = selectDelCallback
	self.isDelState = isDelState
	if isDelState then
		self.conRight:setVisible(false)
		self.selectedIcon:setVisible(false)
		self.selectedBtn:setVisible(true)
		self.selectedBtn.setSelected(isChoose)
	else
		self.conRight:setVisible(true)
		self.selectedIcon:setVisible(false)
		self.selectedBtn:setVisible(false)
	end
end