
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local rrMgr

local SelectShareWayPanel = require "zoo.panel.seasonWeekly.SelectShareWayPanel"

local RankRacePassLevelSharePanel = class(BasePanel)

function RankRacePassLevelSharePanel:create(rewards, star)

	if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()

    local panel = RankRacePassLevelSharePanel.new()
    panel:init(rewards, star)
    return panel
end

function RankRacePassLevelSharePanel:init(rewards, star)
    local ui = UIHelper:createUI("ui/RankRace/showoff.json", "rank.race.showoff/panel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)

	BasePanel.init(self, ui)

	local animalAnim = UIHelper:createArmature2('skeleton/RankRacePassLevel', 'rank.race.passlevel.share/animal')
	self.ui:addChild(animalAnim)
	animalAnim:setPosition(ccp(480, -1100))

	local key = 'rank.race.passlevel.share.title.' .. (function ( ... )
		if star > 1 then
			return '1'
		else
			return '2'
		end
	end)()

	UIHelper:setAnimTitle(animalAnim, localize(key))
	animalAnim:playByIndex(0, 1)
	animalAnim:setScale(1.1)

	local t0Data = table.find(rewards, function ( v )
		return v.itemId == ItemType.RACE_TARGET_0
	end)

	local t1Data = table.find(rewards, function ( v )
		return v.itemId == ItemType.RACE_TARGET_1
	end)

	self.refNodes = {}

	--代码重复为哪般

	local finalNum
	local baseNum

	if t0Data and t0Data.num > 0 then
		finalNum = t0Data.num
		baseNum = rrMgr:getBaseTarget_0() or 0
		t0Data.num = baseNum
		local scale = 1
		local rewardItem = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/@RewardItem')
		rewardItem:setRewardItem(t0Data)
		UIHelper:addChildInAnim(animalAnim, 'pao1', rewardItem.refCocosObj)
		rewardItem:setPositionX((263 - 176 * scale)/2 + 29.2/2)
		rewardItem:setPositionY((259 + 178 * scale)/2 - 29.3/2)

		table.insert(self.refNodes, rewardItem)

		rewardItem.num:setText('x')

		local anim = self:createNumberFlipAnimation(baseNum, finalNum, 'fnt/event_default_digits.fnt', 1.5)
		anim:setAnchorPoint(ccp(0, 0))
		rewardItem:addChild(anim)
		anim:setPosition(ccp(140, -155))
	end

	if t1Data and t1Data.num > 0 then
		local scale = 1
		local rewardItem = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/@RewardItem')
		rewardItem:setRewardItem(t1Data)
		UIHelper:addChildInAnim(animalAnim, 'pao2', rewardItem.refCocosObj)
		rewardItem:setPositionX((263 - 176 * scale)/2 + 29.2/2)
		rewardItem:setPositionY((259 + 178 * scale)/2 - 29.3/2)
		rewardItem:dispose()
	end

	local function playNumAnim( ... )
		if self.isDisposed then return end
		if not finalNum then return end
		if not baseNum then return end
		if finalNum - baseNum > 0 then

			local origin = ccp(399, -533.4) --不要问我从哪里来

			local flyAnim = UIHelper:createArmature2('skeleton/RankRacePassLevel', 'rank.race.passlevel.share/flyNum')
			local bmp = BitmapText:create('+' .. tostring(finalNum - baseNum), 'fnt/newzhousai_rubyend.fnt')
			bmp:setScale(1.6)
			UIHelper:addChildInAnim(flyAnim, 'num', bmp.refCocosObj)
			self.ui:addChild(flyAnim)
			flyAnim:setScale(1.1)
			flyAnim:setPosition(ccp(origin.x - 140.65, origin.y + 230))
			flyAnim:playByIndex(0, 1)
			bmp:dispose()
		end
		self:handlePrivilegeAdd(t1Data and t1Data.num > 0)
	end

	setTimeOut(playNumAnim, 1.2)

	local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))

	if Misc:isSupportShare() then
		btn:setString('炫耀一下')
	else
		btn:setString('确定')

		self.ui:getChildByPath('label2'):setVisible(false)

	end

	btn:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(function ( ... )
		if self.isDisposed then return end

		if not Misc:isSupportShare() then
			self:onCloseBtnTapped()
			return
		end

		DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_share'})

		PaymentNetworkCheck:getInstance():check( function ( ... )
			if __WIN32 or (__ANDROID and (not WXJPPackageUtil.getInstance():isWXJPPackage())) then
				SelectShareWayPanel:create():popout(function ( ... )
					self:onBtnTapped(false) 
					DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_share_wx'})
				end, function ( ... )
					self:onBtnTapped(true) 
					DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_share_pyq'})
				end)
			else	
				self:onBtnTapped(false) 
				DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_share_wx'})
			end
		end , function ( ... )
			CommonTip:showNetworkAlert()
		end )

	end))

	-- self.ui:getChildByPath('label'):setString(localize('rank.race.passlevel.share.guide.share'))
end

function RankRacePassLevelSharePanel:handlePrivilegeAdd(posLeft)
	local privilegeAddNum = rrMgr:getPrivilegeAddNum() or 0
	if privilegeAddNum > 0 then 
		local layer = Layer:create()
		local sp = Sprite:create("ui/Privilege/privilegeLabel.png")
		local num = BitmapText:create(" +"..privilegeAddNum, "fnt/yueka.fnt", -1, kCCTextAlignmentLeft)
		if sp and num then 
			sp:setAnchorPoint(ccp(1, 0.5))
			layer:addChild(sp)
			
			num:ignoreAnchorPointForPosition(false)
			num:setAnchorPoint(ccp(0, 0.5))
			layer:addChild(num)
			layer:setScale(1.2)

			self.ui:addChild(layer)
			if posLeft then 
				layer:setPosition(ccp(320, -600))
			else
				layer:setPosition(ccp(680, -400))
			end
			layer:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(1, ccp(0, 100)), CCCallFunc:create(function ()
				layer:removeFromParentAndCleanup(true)
			end)))

			sp:runAction(CCFadeTo:create(1, 50))
			num:runAction(CCFadeTo:create(1, 50))
		end
	end
end

function RankRacePassLevelSharePanel:onBtnTapped(isSysShare)

	local function onSuccess(isAddCount)
		if self.isDisposed then return end

		if not isSysShare then
			local scene = HomeScene:sharedInstance()
			if scene then
				scene:runAction(CCCallFunc:create(function()
					if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
						CommonTip:showTip(Localization:getInstance():getText("rank.race.share.success.mitalk"), 'positive')
					else
						CommonTip:showTip(Localization:getInstance():getText("rank.race.share.success"), 'positive')
					end
				end))
			end
		end

		if isSysShare then
			DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_share_pyq_success'})
		else
			DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_share_wx_success'})
		end


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
				CommonTip:showTip(Localization:getInstance():getText("rank.race.share.fail.mitalk"), "negative")
			else
				CommonTip:showTip(Localization:getInstance():getText("rank.race.share.fail"), "negative")
			end
		end
	end

	local function onCancel()
		if self.isDisposed then return end
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			CommonTip:showTip(Localization:getInstance():getText("rank.race.share.cancel.mitalk"), "negative")
		else
			CommonTip:showTip(Localization:getInstance():getText("rank.race.share.cancel"), "negative")
		end
	end

	if isSysShare then 
		self:sysShare(onSuccess, onFail, onCancel)
	else
		if not Misc:isSupportShare() then
			if onFail then onFail() end
		else
			self:shareMessageForFeed(onSuccess, onFail, onCancel)
		end
	end
end


function RankRacePassLevelSharePanel:createSharePicture( url )

    local sharePicture = SharePicture.new()
    sharePicture:setBackgroundByPathname('share/rank_race_passlevel.jpg')

    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    sharePicture:buildQRCode(url, 170, ccp(25.65+179/2, -497-179/2 + 2), 0)
    local path, thumb = sharePicture:capture()
    sharePicture:dispose()
    return path, thumb
end


function RankRacePassLevelSharePanel:sysShare(onSuccessCallback, onFailCallback, onCancelCallback)
	local function onApply(shareKey)
		local inviteCode = UserManager:getInstance().inviteCode or ''
		local uid = UserManager.getInstance().user.uid
	    local url = Misc:buildURL(NetworkConfig:getShareHost(), 'week_match_v2.jsp', {
	        pid = StartupConfig:getInstance():getPlatformName() or '',
	        game_name = 'Rank_race_level',
	        aaf = 5,
	        uid = uid,
	        shareKey = shareKey,
	    })

	    RankRaceHttp:getShortUrl(url, function ( url )
	    	
	    	local path, thumbPath = self:createSharePicture(url)
			local shareCallback = {
				onSuccess = function(result)
					if onSuccessCallback then
						onSuccessCallback(false)
					end
				end,
				onError = function(errCode, errMsg)
					if errCode and errCode == -2 then 
						CommonTip:showTip(localize("social.network.follow.panel.wechat.no.install"), "negative", nil, 2)
						-- self:setButtonEnabled(true)
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

				AndroidShare.getInstance():registerShare(8)
				local message = "点击链接可【免费领取】，你有我也有！"..url
				SnsUtil.sendImageMessage(8, "", message, thumbPath, path, shareCallback, true, gShareSource.WEEKLY_MATCH)
			end

			if __WIN32 then
				onSuccessCallback(false)
			end

	    end)
	end

	if __WIN32 then
		onApply()
	else
		RankRaceHttp:getShareKey(1, function ( evt )
	        if self.isDisposed then return end
	        local shareKey = evt.data.shareKey or ''
			onApply(shareKey)
		end)
	end
	
end


function RankRacePassLevelSharePanel:shareMessageForFeed(successCallback, failCallback, cancelCallback)

	RankRaceHttp:getShareKey(1, function ( evt )
        if self.isDisposed then return end
        local shareKey = evt.data.shareKey or ''


        local function onSuccess(isAddCount)
			if successCallback then successCallback(isAddCount) end
		end
		local function onFail(...)
			if failCallback then failCallback(...) end
		end
		local function onCancel()
			if cancelCallback then cancelCallback() end
		end

		local uid = UserManager:getInstance():getUserRef().uid or '12345'
		local webpageUrl = Misc:buildURL(NetworkConfig:getShareHost(), 'week_match_v2.jsp', {
	        pid = StartupConfig:getInstance():getPlatformName() or '',
	        game_name = 'Rank_race_level',
	        aaf = 5,
	        uid = uid,
	        shareKey = shareKey,
	    })

		local title = Localization:getInstance():getText("rank.race.link.title")
		local text = Localization:getInstance():getText("rank.race.link.message", {name = userName, num = count})
		local thumbAddress = "materials/rank_race_passlevel.jpg"
		self:snsShareForFeed(title, text, webpageUrl, thumbAddress, onSuccess, onFail, onCancel)


	end)

end

function RankRacePassLevelSharePanel:snsShareForFeed(title, text, linkUrl,thumbAddress,successCallback, failCallback, cancelCallback)
	local shareCallback = {
		onSuccess = function(result)
			if successCallback then successCallback(false) end
		end,
		onError = function(errCode, errMsg)
			if failCallback then failCallback() end
		end,
		onCancel = function()
			if cancelCallback then cancelCallback() end
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	if not thumbAddress then 
		thumbAddress = "materials/rank_race_passlevel.jpg"
	end
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbAddress)
	local shareType, delayResume = SnsUtil.getShareType()

	if shareType == PlatformShareEnum.kJPWX or shareType == PlatformShareEnum.kWechat then
		if not OpenUrlUtil:canOpenUrl("weixin://") then
			if failCallback then failCallback(nil, nil, true) end
			return
		end
	end
	SnsUtil.sendLinkMessage(shareType, title, text, thumb, linkUrl, false, shareCallback, gShareSource.WEEKLY_MATCH)
end

function RankRacePassLevelSharePanel:dispose( ... )
	-- body
	BasePanel.dispose(self, ...)

	for _, v in ipairs(self.refNodes or {}) do
		v:dispose()
	end
end

function RankRacePassLevelSharePanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRacePassLevelSharePanel:popout()
	PopoutManager:sharedInstance():add(self, false)
	self.allowBackKeyTap = true
	self:popoutShowTransition()
end

function RankRacePassLevelSharePanel:onCloseBtnTapped( ... )
    self:_close()


    HomeScene:sharedInstance():checkDataChange()

    if HomeScene:sharedInstance() ~= Director:sharedDirector():run() then
		Director:sharedDirector():popScene()
	end

	if self.replayMode == ReplayMode.kResume then
		setTimeOut( function () 
			GamePlayEvents.dispatchPassLevelEvent({levelType=GameLevelType.kMoleWeekly, scrollRowNum = self.scrollRows})
		end , 2 )
	else
		GamePlayEvents.dispatchPassLevelEvent({levelType=GameLevelType.kMoleWeekly, scrollRowNum = self.scrollRows})
	end

	if self._close_callback then
		self._close_callback()
	end
end

function RankRacePassLevelSharePanel:popoutShowTransition( ... )
    if self.isDisposed then return end

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, 5)

    local vSize = Director:sharedDirector():getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local mask = LayerColor:create()
    mask:changeWidthAndHeight(wSize.width/self.ui:getScaleX(), wSize.height/self.ui:getScaleY())
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    self.ui:addChildAt(mask, 0)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
    self.maskLayer = mask

end

function RankRacePassLevelSharePanel:setCloseCallBack( cb )
	self._close_callback = cb
end

-- function RankRacePassLevelSharePanel:createNumberFlipAnimation(startNum, endNum , font , scale , color , speed , widInterval , heiInterval , align , maskHeight , fixEndY , delayPlay)
		
-- 	delayPlay = delayPlay or 1.2

-- 	if not font then font = "微软雅黑" end
-- 	if not scale then scale = 1 end
-- 	if not color then color = ccc4(255,255,255,255) end
-- 	if not speed then speed = 1 end
-- 	if not widInterval then widInterval = 10 end
-- 	if not heiInterval then heiInterval = 10 end
	
-- 	if not fixEndY then fixEndY = 0 end
-- 	if not align then align = "center" end
-- 	if not delayPlay then delayPlay = 0 end


-- 	local container = Layer:create()

-- 	local numstr1 = tostring(startNum)
-- 	local numlen1 = string.len(numstr1)
-- 	local numList1 = {}
-- 	for i = 1 , numlen1 do
-- 		table.insert( numList1 , string.sub(numstr1, i, i) )
-- 	end

-- 	local numstr2 = tostring(endNum)
-- 	local numlen2 = string.len(numstr2)
-- 	local numList2 = {}
-- 	for i = 1 , numlen2 do
-- 		table.insert( numList2 , string.sub(numstr2, i, i) )
-- 	end

-- 	while #numList1 < #numList2 do
-- 		table.insert(numList1, ' ')
-- 	end


-- 	local textContainer = Layer:create()
-- 	textContainer.partList = {}
-- 	local textList = {}

-- 	for i = 1 , #numList2 do

-- 		local n2 = tonumber( numList2[i] )
-- 		local n1 = tonumber( numList1[i] )

-- 		local textAnimationPart = {}

-- 		if numList1[i] == ' ' then
-- 			table.insert( textAnimationPart , tostring(' ') )
-- 			for ia = 0 , n2 do
-- 				table.insert( textAnimationPart , tostring(ia) )
-- 			end
-- 		elseif n2 >= n1 then
-- 			-- n = 5  [0,1,2,3,4,5]
-- 			for ia = n1 , n2 do
-- 				table.insert( textAnimationPart , tostring(ia) )
-- 			end
-- 		else
-- 			for ia = n1 , 9 do
-- 				table.insert( textAnimationPart , tostring(ia) )
-- 			end

-- 			for ia = 0 , n2 do
-- 				table.insert( textAnimationPart , tostring(ia) )
-- 			end
-- 		end

-- 		table.insert( textList , textAnimationPart )
-- 	end

-- 	local sizeNumText = BitmapText:create( "0" , font , -1, kCCTextAlignmentCenter )
-- 	local size1 = sizeNumText:getGroupBounds().size

-- 	local numTextSize = nil
-- 	for i = 1 , #textList do

-- 		local part = textList[i]
-- 		local partContainer = Layer:create()
		

-- 		for ia = 1 , #part do
-- 			local t = BitmapText:create( part[ia] , font , -1, kCCTextAlignmentCenter)
-- 			t:setAnchorPoint( ccp(0.5,0) )
-- 			-- t:setPositionX(size1.width/2)
-- 			t:setColor(color)
-- 			t:setPosition(  ccp( 0 , ( ( size1.height + heiInterval) * ( ia - 1 ) )   ) )
-- 			partContainer:addChild(t)
-- 		end

-- 		local size2 = partContainer:getGroupBounds().size
-- 		partContainer:setPosition( ccp( ( size1.width + widInterval ) * ( i - 1 ) + size1.width/2, 0 ) )
-- 		textContainer:addChild(partContainer)

-- 		table.insert( textContainer.partList , partContainer )
-- 	end

-- 	local progressMask = LayerColor:create()
-- 	local textContainerWidth = textContainer:getGroupBounds().size.width
-- 	local textContainerHeight = textContainer:getGroupBounds().size.height
-- 	if not maskHeight then maskHeight = size1.height + heiInterval end

-- 	progressMask:changeWidthAndHeight( textContainerWidth + 0 , maskHeight + 0)
-- 	local clippingNode = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
-- 	progressMask:dispose()
-- 	clippingNode:addChild(textContainer)
-- 	for i = 1 , #textContainer.partList do
-- 		local actArr2 = CCArray:create()
-- 		if delayPlay > 0 then
-- 			actArr2:addObject( CCDelayTime:create( delayPlay ) )
-- 		end
-- 		actArr2:addObject( CCDelayTime:create( (speed / 5) * (#textContainer.partList - i) ) )
-- 		local partSize = textContainer.partList[i]:getGroupBounds().size
-- 		actArr2:addObject( CCEaseSineOut:create( 
-- 			CCMoveTo:create( speed , ccp( textContainer.partList[i]:getPositionX() , (partSize.height * -1) + size1.height + fixEndY ) ) ) )
-- 		textContainer.partList[i]:runAction( CCSequence:create(actArr2) )
-- 	end

-- 	clippingNode:setPositionX( textContainerWidth / -2 )
-- 	container:addChild(clippingNode)

-- 	container:setScale(scale)

-- 	sizeNumText:dispose()

-- 	local containerOrigin = container:getGroupBounds().origin

-- 	return container , 
-- 	{
-- 		x = containerOrigin.x , y = containerOrigin.y , 
-- 		width = textContainerWidth * scale , height = size1.height * scale
-- 	}
-- end




function RankRacePassLevelSharePanel:createNumberFlipAnimation(startNum, endNum , font , scale)
		
	local sizeNumText = BitmapText:create( tostring(startNum) , font , -1, kCCTextAlignmentCenter )
	sizeNumText:setScale(scale)

	local total = 0.8
	local time_sum = -1

	sizeNumText:scheduleUpdateWithPriority(function ( dt )
        if self.isDisposed then return end
        if sizeNumText.isDisposed then return end

        time_sum = time_sum + dt
		local n = startNum + (endNum - startNum) * math.clamp((time_sum) / (total), 0, 1)
		n = math.floor(n)
		sizeNumText:setText(tostring(n))
	end)

	function sizeNumText:dispose( ... )
		self:unscheduleUpdate()
		BitmapText.dispose(self, ...)
	end


	return sizeNumText
end


return RankRacePassLevelSharePanel
