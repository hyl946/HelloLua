require "zoo.panel.basePanel.BasePanel"

local function getModAndGameName( ... )
    return 1, 'week_match_2018_spring'
end


local SelectShareWayPanel = require "zoo.panel.seasonWeekly.SelectShareWayPanel"


SeasonWeeklyRaceResultPanel = class(BasePanel)
function SeasonWeeklyRaceResultPanel:create(starCount, score, rewards, scrollRows , replayMode)
	local panel = SeasonWeeklyRaceResultPanel.new()
	panel:init(starCount, score, rewards, scrollRows , replayMode)
	return panel
end

function SeasonWeeklyRaceResultPanel:init(starCount, score, rewards, scrollRows , replayMode)
	self.scrollRows = scrollRows
	self.replayMode = replayMode

	local ts = Localhost:time()
	rewards = self:mergeRewards(rewards)
	self:loadRequiredResource("ui/panel_summer_weekly_share2.json")
	local ui = self:buildInterfaceGroup('SummerWeeklyRacePanel/ResultPanel')
	BasePanel.init(self, ui)

	local arr = {1, 2, 3, 4, 5, 6}

	local index = CCUserDefault:sharedUserDefault():getIntegerForKey("season.weekly.result.index")
	arr = table.filter(arr, function(v) return v ~= index end)
	index = arr[math.random(#arr)]
	CCUserDefault:sharedUserDefault():setIntegerForKey("season.weekly.result.index", index)

	local itemId = nil
	local count = 0

	local propIndex = 1

	self.items = {}
	for i,v in ipairs(rewards) do
		if v.itemId == ItemType.KWATER_MELON then
			local item = {}
			item.itemId = ItemType.KWATER_MELON
			item.num = v.num
			table.insert(self.items, item)
			self.itemNum = v.num
			count = v.num
		elseif v.itemId == ItemType.COIN then
			local item = {}
			item.itemId = ItemType.COIN
			item.num = v.num
			self.coinNum = v.num
		else
			self['prop'..propIndex] = v
			propIndex = propIndex + 1
		end
	end

	local button = GroupButtonBase:create(ui:getChildByName("shareBtn"))
	button:setColorMode(kGroupButtonColorMode.green)
	button:setString(Localization:getInstance():getText("share.feed.button.achive"..tostring(index)))
	button:addEventListener(DisplayEvents.kTouchTap, function() 


		DcUtil:clickShareQrCodeBtn(index, self.t1, self.t2)


		--一个分享按钮
		local function dcFunc_1( ... ) 
			DcUtil:doShareQrCodeSuccess(index, 'weeklyrace_winter_2017_show_succsse', self.t1, self.t2)
		end

		--二个分享按钮 点了 微信好友
		local function dcFunc_2( ... ) 
			DcUtil:doShareQrCodeSuccess(index, 'weeklyrace_spring_2018_show_wxfriend_succsse', self.t1, self.t2)
		end

		--二个分享按钮 点了 朋友圈
		local function dcFunc_3( ... ) 
			DcUtil:doShareQrCodeSuccess(index, 'weeklyrace_spring_2018_show_pyq_succsse', self.t1, self.t2)
		end


		if __WIN32 or (__ANDROID and (not WXJPPackageUtil.getInstance():isWXJPPackage())) then


			SelectShareWayPanel:create():popout(function ( ... )
				if __WIN32 then
					CommonTip:showTip('friend')
				end
				self:onBtnTapped(index, count, ts, false, dcFunc_2) 
				DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_spring_2018_show_wxfriend', t1 = self.t1, t2 = self.t2})
			end, function ( ... )
				if __WIN32 then
					CommonTip:showTip('feeds')
				end
				self:onBtnTapped(index, count, ts, true, dcFunc_3) 
				DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_spring_2018_show_pyq', t1 = self.t1, t2 = self.t2})
			end)


		else	
			self:onBtnTapped(index, count, ts, false, dcFunc_1) 
		end

	end)

	button:useBubbleAnimation(0.05)
	self.button = button
	self.button:setPositionY(-1062 + self:getPositionY()/2)

	local btnTip = self.ui:getChildByName("shareTip")
	btnTip:setPositionY(-930 + self:getPositionY()/2)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local vSize = Director:sharedDirector():getVisibleSize()

	local close = ui:getChildByName("closeBtn")
	close:setPositionX((vSize.width - self:getPositionX()) / self:getScale() - 60)
	close:setPositionY(-self:getPositionY() / self:getScale() - 60)
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	self.close = close

	local bgSp = Sprite:create('ui/weeklyMatch/shareBg.jpg')
	

	bgSp:setAnchorPoint(ccp(0, 1))
	bgSp:setPositionXY(-120, 200)

	self.ui:getChildByName("bg"):setVisible(false)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg"))
	self.ui:addChildAt(bgSp, childIndex + 1)

	local config = {
		[1] = "Hippo",
		[2] = "Frog",
		[3] = "Bear",
		[4] = "Owl",
		[5] = "Fox",
		[6] = "Chicken"
	}

	self.t1 = 1
	local titleKey = "weeklyrace.2017.summer.showoff.a."
	if count >= 100 then
		titleKey = "weeklyrace.2017.summer.showoff.b."
		self.t1 = 2
	end
	self.t2 = math.random(1, 3)
	titleKey = titleKey ..tostring(self.t2)
	local titleStr = Localization:getInstance():getText(titleKey)
	local offset = ccp(45, -150)

	local pRewards = {}
	pRewards.coin = self.coinNum
	pRewards.dropItem = self.itemNum
	pRewards.prop1 = self.prop1
	pRewards.prop2 = self.prop2
	pRewards.prop3 = self.prop3
	pRewards.prop4 = self.prop4

	local function onAnimationPlayFinished()
		-- guide
		if (not SeasonWeeklyRaceManager:isFlagSet("guides.ShowOff")) and self.replayMode ~= ReplayMode.kResume then
			SeasonWeeklyRaceManager:setFlag("guides.ShowOff", true)
			local ShowOffGuide = require "zoo.panel.seasonWeekly.guides.ShowOff"
			local wPos = self.ui:convertToWorldSpace(ccp(self.button:getPositionX(), self.button:getPositionY()))
			local guide = ShowOffGuide:create(wPos)
			self.ui:addChildAt(guide, self.button.groupNode:getZOrder())

			local vSize = Director:sharedDirector():getWinSize()
			local pos = self.ui:convertToNodeSpace(ccp(0, vSize.height))
			guide:setAnchorPoint(ccp(0,1))
			guide:setPosition(ccp(pos.x, pos.y))
		end
	end

	local canvas = Layer:create()
	self.ui:addChildAt(canvas, self.button.groupNode:getZOrder())
	local light = ui:getChildByName("light")
	if light then
		light:setVisible(false)
	end
	self:showShareRewardBubbleAnimation(canvas, config[index], pRewards, titleStr, offset, onAnimationPlayFinished)
end

function SeasonWeeklyRaceResultPanel:setAnimationBobbleNumberView( solt , num, offset)
	if not solt then return end
	local fntFile = "fnt/event_default_digits.fnt"
	local s = Sprite:createEmpty()

	local newLabel = BitmapText:create("x"..(num or 1), fntFile, -1, kCCTextAlignmentCenter)
	s:setContentSize(newLabel:getContentSize())
	s:setAnchorPoint(ccp(0.5, 1))
	newLabel:setPosition(ccp( offset.x , offset.y ))
	s:addChild(newLabel)

	solt:setDisplayImage(s.refCocosObj)
end

function SeasonWeeklyRaceResultPanel:dispose( ... )
	BasePanel.dispose(self, ...)
	CCTextureCache:sharedTextureCache():removeTextureForKey('ui/weeklyMatch/shareBg.jpg')
end

function SeasonWeeklyRaceResultPanel:setAnimationBobbleContainerView( solt , num, offset)
	if not solt then return end

	local s = TileRandomProp:buildPropSprite(num) --Sprite:createWithSpriteFrameName(TileRandomProp:mapLimitId2CommonPropertyId(num) )
	solt:setDisplayImage(s.refCocosObj)
end

function SeasonWeeklyRaceResultPanel:showShareRewardBubbleAnimation(ui, animName, rewards , titleStr, offset, onAnimationPlayFinished, avatarOffset)
	local coinNumber = rewards.coin
	local dropItemNumber = rewards.dropItem
	local rankRewardNumber = rewards.rankRewardNum		 --扫把
	local totalRankRewardNumber = rewards.totalRankRewardNum --魔力鸟

	if self.replayMode == ReplayMode.kResume then
		rewards.prop1 = nil
		rewards.prop2 = nil
		rewards.prop3 = nil
		rewards.prop4 = nil
	end

	local prop1 = rewards.prop1
	local prop2 = rewards.prop2
	local prop3 = rewards.prop3
	local prop4 = rewards.prop4

	if animName == nil then return end

	local light = ui:getChildByName("light")
	if light then
		light:setVisible(false)
	end

	FrameLoader:loadArmature("skeleton/season_weekly_result_animation/animal_2018_s1", "animal_2018_s1", "animal_2018_s1")

	if avatarOffset then
		avatarOffset.x = offset.x + avatarOffset.x
		avatarOffset.y = offset.y + avatarOffset.y
	end

	local avatarOffset = avatarOffset or ccp(372, -900)
	local anim = ArmatureNode:create("weekly.2018.s1.anim/"..animName, true)
	if not anim then
		anim = ArmatureNode:create("2017_s3_season_result_anim_20170904/"..animName, true)
	end	
	anim:playByIndex(0)
	anim:setPosition(avatarOffset)
	ui:addChild(anim)

	local animIndex = ui:getChildIndex(anim)

	local function animfinish()
		anim:rma()
		if type(onAnimationPlayFinished) == "function" then
			onAnimationPlayFinished()
		end
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, animfinish)

	FrameLoader:loadArmature("skeleton/season_weekly_result_animation/season_bg_all", "season_bg_all", "season_bg_all")
	local animAll = ArmatureNode:create("season_weekly_result_animation/all", true)

	local function updateBubbles( soltName , value , offset)
		local solt_number = animAll:getSlot("number_" .. soltName)
		local solt_icon = animAll:getSlot("icon_" .. soltName)
		local solt_bubble = animAll:getSlot("bubble_" .. soltName)

		if value then
			if type(value) == "table" then
				-- self:processProps(animAll,animName,prop1,prop2)
				self:setAnimationBobbleContainerView(solt_icon , value.itemId , offset)
				self:setAnimationBobbleNumberView(solt_number , value.num , offset)
			else
				self:setAnimationBobbleNumberView( solt_number , value , offset )
			end
		else
			if solt_number then solt_number:setDisplayImage(nil) end
			if solt_icon then solt_icon:setDisplayImage(nil) end
			if solt_bubble then solt_bubble:setDisplayImage(nil) end
		end
	end

	updateBubbles("coin" , coinNumber , ccp(122, -85))
	updateBubbles("drop_item" , dropItemNumber , ccp(162, -130))
	updateBubbles("rank_reward" , rankRewardNumber , ccp(110, - 70))
	updateBubbles("prop1" , prop1 , ccp(45, 30))
	updateBubbles("prop2" , prop2 , ccp(28, 30))
	updateBubbles("prop3" , prop3 , ccp(28, 30))
	updateBubbles("prop4" , prop4 , ccp(28, 30))
	updateBubbles('rank_reward_2', totalRankRewardNumber, ccp(177, -130))

	local function finish()
		animAll:rma()
		animAll:play("loop", 0)
	end

	animAll:addEventListener(ArmatureEvents.COMPLETE, finish)
	animAll:setPosition(offset)
	animAll:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(function ( ... )
		if animAll.isDisposed then
			return
		end
		animAll:setVisible(true)
		animAll:playByIndex(0)
	end)))

	ui:addChild(animAll)
	animAll:setVisible(false)

	if self and self.isDisposed == false then
		animAll:setPositionY(offset.y + 115 - self:getPositionY()/2)
	end

	local bottomTitle = ArmatureNode:create("season_weekly_result_animation/all2", true)
	local title = bottomTitle:getSlot("title")
	if title then
		local charWidth = 35
		local charHeight = 35
		local charInterval = 32
		local fntFile = "fnt/share.fnt"

		local newCaptain = BitmapText:create(titleStr, fntFile, -1, kCCTextAlignmentCenter)
		newCaptain:setPosition(ccp(240, -41))
		local s = Sprite:createEmpty()
		s:addChild(newCaptain)
		title:setDisplayImage(s.refCocosObj)
	end

	local dx = 320
	local dy = -770

	ui:addChild(bottomTitle)
	bottomTitle:setPosition(offset)
	bottomTitle:addEventListener(ArmatureEvents.COMPLETE, function ( ... )
		bottomTitle:rma()
		bottomTitle:play("loop", 0)
	end)
	bottomTitle:play('fadein', 1)

	return animAll, bottomTitle
end

function SeasonWeeklyRaceResultPanel:onBtnTapped(index, count, timeStamp, isSysShare, dcFunc)

	local function onSuccess(isAddCount)
		if dcFunc then
			dcFunc()
		end


		if self.isDisposed then return end
		local scene = HomeScene:sharedInstance()
		if scene then
			local function showTip(tip)
				local scene = Director:sharedDirector():getRunningScene()
				if scene then
					local panel = CommonTip:create(tip, 2, nil, 4)
					if not panel then
						return
					end
					function panel:removeSelf()
						if not scene.isDisposed then
							scene:superRemoveChild(self,true)
						end
					end
					local winSize = Director:sharedDirector():getVisibleSize()
					while panel:getPositionY() < 0 or panel:getPositionY() > winSize.height do
						if panel:getPositionY() < 0 then
							panel:setPositionY(panel:getPositionY() + winSize.height)
						end
						if panel:getPositionY() > winSize.height then
							panel:setPositionY(panel:getPositionY() - winSize.height)
						end
					end
					scene:superAddChild(panel)
				end
			end
			scene:runAction(CCCallFunc:create(function()
				if isAddCount then
					showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip4"))
				else
					if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
						showTip(Localization:getInstance():getText("share.feed.success.tips.mitalk"))
					else
						showTip(Localization:getInstance():getText("weekly.race.winter.share.success"))
					end
				end
			end))
		end
		self:playAnim()
		self:onCloseBtnTapped()
	end
	local function onFail(evt, _, noInstall)
		if self.isDisposed then return end
		if noInstall then
			CommonTip:showTip(Localization:getInstance():getText('social.network.follow.panel.wechat.no.install'), "negative")
		elseif type(evt) == 'number' and evt == 0 then
			
		elseif evt and type(evt) == 'table' and evt.data then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		else
			if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
				CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips.mitalk"), "negative")
			else
				CommonTip:showTip(Localization:getInstance():getText("weekly.race.winter.share.fail"), "negative")
			end
		end
		self:setButtonEnabled(true)
	end
	local function onCancel()
		if self.isDisposed then return end
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips.mitalk"), "negative")
		else
			CommonTip:showTip(Localization:getInstance():getText("weekly.race.winter.share.cancle"), "negative")
		end
		self:setButtonEnabled(true)
	end
	self:setButtonEnabled(false)
	setTimeOut(function()
		if self.isDisposed then return end
		self:setButtonEnabled(true)
	end, 2)

	if isSysShare then 
		self:sysShare(index, count, timeStamp, onSuccess, onFail, onCancel)
	else
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			self:shareMessage(index, count, timeStamp, onSuccess, onFail, onCancel)
		else
			self:shareMessageForFeed(index, count, timeStamp, onSuccess, onFail, onCancel)
		end
	end
end

function SeasonWeeklyRaceResultPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function SeasonWeeklyRaceResultPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	HomeScene:sharedInstance():checkDataChange()
	PopoutManager:sharedInstance():remove(self)
	Director:sharedDirector():popScene()

	if self.replayMode == ReplayMode.kResume then
		setTimeOut( function () 
			GamePlayEvents.dispatchPassLevelEvent({levelType=GameLevelType.kSummerWeekly, scrollRowNum = self.scrollRows})
		end , 2 )
	else
		GamePlayEvents.dispatchPassLevelEvent({levelType=GameLevelType.kSummerWeekly, scrollRowNum = self.scrollRows})
	end
	

	if self.closeCallBack ~= nil then self.closeCallBack() end

	--RemoteDebug:uploadLog("SeasonWeeklyRaceResultPanel:onCloseBtnTapped " , self.replayMode )
	
end

function SeasonWeeklyRaceResultPanel:playAnim()
	if self.isDisposed then return end
	local scene = HomeScene:sharedInstance()
	for _,v in pairs(self.items) do
		local posX = 20
		local posY = 50
		scene:runAction(CCCallFunc:create(function( ... )
			if v.itemId == ItemType.KWATER_MELON then
				-- 没图标暂不处理
			else
				local anim = FlyItemsAnimation:create({v})
				anim:setWorldPosition(ccp(posX,posY))
				anim:play()
			end
		end))
	end
end

function SeasonWeeklyRaceResultPanel:mergeRewards(rewardTable)
	local rewards = {}
	for i, v in ipairs(rewardTable) do
		local found = false
		for i2, v2 in ipairs(rewards) do
			if v2.itemId == v.itemId then
				found = true
				v2.num = v2.num + v.num
				break
			end
		end
		if not found then
			table.insert(rewards, {itemId = v.itemId, num = v.num})
		end
	end
	return rewards
end

--发送点对点链接 目前非米聊版本在用
function SeasonWeeklyRaceResultPanel:shareMessageForFeed(index, count, timeStamp, successCallback, failCallback, cancelCallback)
	local function onSuccess(isAddCount)
		if successCallback then successCallback(isAddCount) end
	end
	local function onFail(...)
		if failCallback then failCallback(...) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local function onApply(_, qrCodeId)
		local uid = UserManager:getInstance():getUserRef().uid or '12345'
		local inviteCode = UserManager:getInstance().inviteCode or ''
		local platformName = StartupConfig:getInstance():getPlatformName() or ''

		local profile = UserManager:getInstance().profile
		local userName = profile.name
		if type(userName) ~= "string" then
			userName = Localization:getInstance():getText("game.setting.panel.use.device.name.default")
		else
			userName = nameDecode(userName)
		end

		local webpageUrl = ''

		local function finallyShare()
			-- if _G.isLocalDevelopMode then printx(0, webpageUrl) end debug.debug()
			local title = Localization:getInstance():getText("weekly.race.winter.grade.link.title")
			local text = Localization:getInstance():getText("weekly.race.winter.grade.link", {name = userName, num = count})
			local thumbAddress = "materials/sharethumb_weekly.png"
			SeasonWeeklyRaceManager:getInstance():snsShareForFeed(title, text, webpageUrl, thumbAddress, onSuccess, onFail, onCancel)
		end
		if false and MaintenanceManager:getInstance():isEnabled('yingyongbaowxz') and PlatformConfig:isQQPlatform() then
			local function getHealUrl()
				local headUrl = UserManager.getInstance().profile.headUrl or ''
				if tonumber(headUrl) ~= nil then
					return 'http://static.manimal.happyelements.cn/hd/activity/businessCard/'..headUrl..'.png'
				else
					return headUrl
				end
			end
			local params = {
					appid = '100718846',
					openid = '',
					openkey = '',
					timestamp = Localhost:time(),
					tpl = 2,
					rank = '',
					nickname = UserManager.getInstance().profile:getDisplayName(),
					portrait = getHealUrl(),
					scene = '',
				}
			local function onSignSuccess(event)
				local signStr = event.data.sig or ''
				

				local scheme = 'happyanimal3://week_match/redirect?uid='..tostring(uid)..'&invitecode='..tostring(inviteCode).."&pid="..tostring(platformName).."&action=1&index="..index.."&ts="..
						tostring(Localhost:time()).."&qrid="..tostring(string.gsub(qrCodeId, '_', 'X'))..'&inviteCode='..tostring(inviteCode)
				if _G.isLocalDevelopMode then
					webpageUrl = 'http://appicsh.qq.com/share/get_page?'
				else
					webpageUrl = 'http://appicsh.qq.com/share/get_page?'
				end
				for k, v in pairs(params) do
					webpageUrl = webpageUrl .. tostring(k) ..'=' ..HeDisplayUtil:urlEncode(v) .. '&'
				end
				-- if _G.isLocalDevelopMode then printx(0, scheme) end debug.debug()
				webpageUrl = webpageUrl .. 'scheme=' .. HeDisplayUtil:urlEncode(scheme) .. '&'
				webpageUrl = webpageUrl .. 'sig=' .. HeDisplayUtil:urlEncode(signStr)
				finallyShare()

			end
			local httpParams = {}
			for k, v in pairs(params) do
				table.insert(httpParams, {first = tostring(k), second = tostring(v)})
			end
			local http = GetSharePageSignHttp.new(true)
			http:addEventListener(Events.kComplete, onSignSuccess)
			http:addEventListener(Events.kError, onFail)
			http:load(httpParams)
		else

			local mod, game_name = getModAndGameName()
			webpageUrl = NetworkConfig:getShareHost().."week_match_2018_spring.jsp?aaf=6&uid="..tostring(uid)..
			"&invitecode="..tostring(inviteCode).."&pid="..tostring(platformName).."&action=1&index="..index.."&ts="..
			tostring(Localhost:time()).."&qrid="..tostring(string.gsub(qrCodeId, '_', 'X')).."&mod="..tostring(mod)..
			"&game_name="..tostring(game_name)..'&inviteCode='..tostring(inviteCode).."&isFeeds=0"

			finallyShare()
		end
	end

	local weeklyType = SeasonWeeklyRaceConfig:getInstance().weeklyRaceType
	SeasonWeeklyRaceManager:getInstance():applyForNewShareQrCode(count, timeStamp, weeklyType, onApply, onFail, onCancel)
end

--发送到朋友圈 目前米聊版本在用
function SeasonWeeklyRaceResultPanel:shareMessage(index, count, timeStamp, successCallback, failCallback, cancelCallback)
	local function onSuccess(isAddCount)
		if successCallback then successCallback(isAddCount) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local timer = os.time() or 0
	local datetime = tostring(os.date("%y%m%d", timer))
	-- http://static.manimal.happyelements.cn/feed/autumn_weekly_2016_feed.jpg
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/2017_s4_bg_2.jpg?v="..datetime)
	SeasonWeeklyRaceManager:getInstance():snsShareForResultPanelAndMitalk(imageURL, "", "", onSuccess, onFail, onCancel)
end

function SeasonWeeklyRaceResultPanel:setCloseCallBack(callback)
	self.closeCallBack = callback
end

function SeasonWeeklyRaceResultPanel:sysShare(index, count, timeStamp, onSuccessCallback, onFailCallback, onCancelCallback)
	local function onApply(_, qrCodeId)
		local uid = UserManager:getInstance():getUserRef().uid or '12345'
		local inviteCode = UserManager:getInstance().inviteCode or ''
		local platformName = StartupConfig:getInstance():getPlatformName() or ''

		local mod, game_name = getModAndGameName()
		local webpageUrl = NetworkConfig:getShareHost().."week_match_2018_spring.jsp?aaf=6&uid="..tostring(uid)..
		"&invitecode="..tostring(inviteCode).."&pid="..tostring(platformName).."&action=1&index="..index.."&ts="..
		timeStamp.."&qrid="..tostring(string.gsub(qrCodeId, '_', 'X')).."&mod="..tostring(mod).."&game_name="..tostring(game_name).."&isFeeds=1"

		self:loadRequiredResource("ui/panel_summer_weekly_share2.json")
		local group = self:buildInterfaceGroup("SummerWeeklyRacePanel/ResultPanelFeed2")
		local bg_2d = Sprite:create("materials/weekly_feed000"..index..".jpg")
		bg_2d:setAnchorPoint(ccp(0, 1))
		local bg = group:getChildByName("bg")
		bg:setVisible(false)
		local bgSize = bg:getGroupBounds().size
		local bSize = bg_2d:getGroupBounds().size
		bg_2d:setScaleX(bgSize.width / bSize.width)
		bg_2d:setScaleY(bgSize.height / bSize.height)
		group:addChildAt(bg_2d, group:getChildIndex(bg))

		local uid = UserManager:getInstance():getUserRef().uid
		local inviteCode = UserManager:getInstance().inviteCode
		local platformName = StartupConfig:getInstance():getPlatformName()
		local code = group:getChildByName("qrcode")
		code:setVisible(false)
		local codeIndex = group:getChildIndex(code)

		local function addQrcode(webpageUrl, position, rotation, size )
			return function ( group, codeIndex)
				local qrCode = CocosObject.new(QRManager:generatorQRNode(webpageUrl..'&isQrCode=1', size.width, 1, ccc4(0, 0, 0, 255), ccc4(255, 255, 255, 255)))
				local bSize = qrCode:getGroupBounds().size
				local scale = math.min(size.width / bSize.width, size.height / bSize.height)
				qrCode:setScaleX(scale)
				qrCode:setScaleY(-scale)
				qrCode:setAnchorPoint(ccp(0.5, 0.5))
				qrCode:setPositionXY(position.x, position.y)
				qrCode:setRotation(rotation)
				group:addChildAt(qrCode, codeIndex)
				return qrCode
			end
		end

		local addQrCodeFunc = {
			[1] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
			[2] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
			[3] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
			[4] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
			[5] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
			[6] = addQrcode(webpageUrl, ccp(120, -537), 0, CCSizeMake(160, 160)),
		}

		local qrCode = addQrCodeFunc[index](group, codeIndex)

		local pos = group:getChildByName("logo")
		pos:setVisible(false)

		local size = pos:getGroupBounds().size
		local logo = Sprite:create("materials/wechat_icon.png")
		local bSize = logo:getGroupBounds().size
		local scale = math.min(size.width / bSize.width, size.height / bSize.height)
		logo:setScale(scale)

		local qrBounds = qrCode:getGroupBounds(group)
		logo:setAnchorPoint(ccp(0.5, 0.5))
		logo:setPositionXY(qrBounds:getMidX(), qrBounds:getMidY())
		logo:setRotation(qrCode:getRotation())

		group:addChildAt(logo, group:getChildIndex(pos))
		group:setPositionY(bgSize.height)

		local renderTexture = CCRenderTexture:create(bgSize.width, bgSize.height)
		renderTexture:begin()
		group:visit()
		renderTexture:endToLua()
		local filePath = ""
		-- 系统分享，将截图存储到外部存储中，以防第三方app无法直接读取图片

		if __WIN32 then
			filePath = HeResPathUtils:getResCachePath() .. '/weekly_'..index..'.png'
		else
			local exStorageDir = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
			if exStorageDir then
				filePath = exStorageDir .. "/weeklyresult.jpg"
			end
		end

		renderTexture:saveToFile(filePath)

		local shareCallback = {
			onSuccess = function(result)
				if onSuccessCallback then
					onSuccessCallback(false)
				end
			end,
			onError = function(errCode, errMsg)
				if errCode and errCode == -2 then 
					CommonTip:showTip(localize("social.network.follow.panel.wechat.no.install"), "negative", nil, 2)
					self:setButtonEnabled(true)
				else
					if onFailCallback then
						onFailCallback(errCode, errMsg)
					end
				end
			end,
			onCancel = function()
				if onCancelCallback then
					onCancelCallback()
				end
			end,
		}
		if __ANDROID then 
			local function getShortUrl( url, onSuccess, onFail )
				local http = OpNotifyHttp.new()
				http:ad(Events.kComplete, function ( evt )
					local shortUrl = ''
					if evt and evt.data then
						shortUrl = evt.data.extra or ''
			    	end
			    	if onSuccess then
						onSuccess(shortUrl)
			    	end
			  	end)
			 	http:ad(Events.kError, function ( ... )
			  		if onFail then onFail(...) end
			  	end)
			  	http:ad(Events.kCancel, function ( ... )
			    	if onFail then onFail(...) end
			  	end)
			  	http:load(OpNotifyType.kGetShortUrl, url)
			end

			local function __share( realUrl )
				AndroidShare.getInstance():registerShare(8)
				local message = "点击链接可【免费领取】，你有我也有！"..realUrl
				SnsUtil.sendImageMessage(8, "", message, filePath, filePath, shareCallback, true, gShareSource.WEEKLY_MATCH)
			end

			getShortUrl(webpageUrl, function ( realUrl )
				__share(realUrl)
			end, function ( ... )
				__share(webpageUrl)
			end)
		end
	end

	if __WIN32 then
		index = 1
		onApply(nil, '1')
		index = 2
		onApply(nil, '1')
		index = 3
		onApply(nil, '1')
		index = 4
		onApply(nil, '1')
		index = 5
		onApply(nil, '1')
		index = 6
		onApply(nil, '1')
	else
		local weeklyType = SeasonWeeklyRaceConfig:getInstance().weeklyRaceType
		SeasonWeeklyRaceManager:getInstance():applyForNewShareQrCode(count, timeStamp, weeklyType, onApply, onFail, onCancel)
	end
	
end

function SeasonWeeklyRaceResultPanel:setButtonEnabled( isEnable )
	self.button:setEnabled(isEnable)
end