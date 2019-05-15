require "zoo.panel.QRCodePanel"
require "zoo.PersonalCenter.AchievementManager"
require "zoo.panel.AccountPanel"
require "zoo.PersonalCenter.AutoAddFriendManager"

PersonalCenterManager = {}

local index = 0
local function nextIndex()
	index = index + 1
	return index
end

local medalConfig = {
		{
			id = 1,
			score = 200,
			fastLevel = 8,
		},
		{
			id = 2,
			score = 500,
			fastLevel = 8,
		},
		{
			id = 3,
			score = 800,
			fastLevel = 38,
		},
		{
			id = 4,
			score = 1100,
			fastLevel = 91,
		},
		{
			id = 5,
			score = 1400,
			fastLevel = 136,
		},
		{
			id = 6,
			score = 1700,
			fastLevel = 211,
		},
		{
			id = 7,
			score = 2000,
			fastLevel = 271,
		},
		{
			id = 8,
			score = 2300,
			fastLevel = 360,
		},
		{
			id = 9,
			score = 2600,
			fastLevel = 480,
		},
		{
			id = 10,
			score = 2900,
			fastLevel = 555,
		},
		{
			id = 11,
			score = 3200,
			fastLevel = 634,
		},
		{
			id = 12,
			score = 3500,
			fastLevel = nil,
		},
	}

function PersonalCenterManager:init()
	--个人信息数据索引
	self.AGE 					= nextIndex() --年龄
	self.SEX 					= nextIndex() --性别
	self.CONSTELLATION 			= nextIndex() --星座
	self.HEAD_URL 				= nextIndex() --头像
	self.INVITE_CODE 			= nextIndex() --消消乐号
	self.QR_CODE 				= nextIndex() --二维码内容
	self.STAR 					= nextIndex() --星级
	self.NAME 					= nextIndex() --昵称
	self.PROFILE 				= nextIndex() --用户信息

	self.HEAD_MODIFIABLE 		= nextIndex() --是否允许修改头像
	self.NAME_MODIFIABLE 		= nextIndex() --是否允许修改昵称

	self.POINTS 				= nextIndex() --成就积分
	self.PERCENT_RANK			= nextIndex() --percent 超越全村百分之XX小伙伴
	self.ACHIEVEMENTS			= nextIndex() --成就信息{id, level}
	self.STAR_FRIEND_RANK		= nextIndex() --好友中星级排名
	self.SHOULD_SHOW_ACCBTN		= nextIndex() --是否显示账号按钮
	self.SHOW_ACCBTN_REDDOT		= nextIndex() --是否显示账号按钮的红点
	self.SHOULD_SHOW_CARD_BTN 	= nextIndex() --是否显示发送名片btn

	self.TOTAL_ACHI_LEVEL		= nextIndex() --总的成就等级
	self.ENABLE_CUSTOM_HEAD		= nextIndex() --是否开启自定义头像
	self.SELF_INFO_VISIBLE		= nextIndex() --自身信息是否对好友的可见

	self.IS_TAKE_PHOTO			= nextIndex() --是否在拍照界面

	self.STAR_GLOBAL_RANK 		= nextIndex() --全国星星数排名
	self.SHOW_ACCBTN_OUTSIDE_REDDOT = nextIndex() -- 是否显示外面设置按钮和个人中心icon上的小红点

	self.ADDRESS = nextIndex()
	self.LOCATION = self.ADDRESS

	self.BIRTHDATE = nextIndex()

	--存储个人等数据信息
	self.data = {}

	self.constellationType = {
		ARIES 			= 1, --白羊座
		TAURUS 			= 2, --金牛座
		GEMINI			= 3, --双子座
		CANCER			= 4, --巨蟹座
		LEO 			= 5, --狮子座
		VIRGO 			= 6, --处女座
		LIBRA    		= 7, --天秤座
		SCORPIO 		= 8, --天蝎座
		SAGITTARIUS 	= 9, --射手座
		CAPRICORNUS 	= 10, --摩羯座
		AQUARIUS 		= 11, --水瓶座
		PISCES 			= 12, --双鱼座
		INVALID			= 0, --无效
	}

	self.sexType = {
		MAN = 1,
		WOMAN = 2,
		INVALID = 0, --无效
	}

	self.medalConfig = medalConfig

	AchievementManager:registerAchievementNotify(AchievementManager.notifyEvent.ACHIEVEMENT, self, self.updateAchievement)
	AutoAddFriendManager.setPersonalCenterManager(self)

	self.dataEventFunc = {}
end

function PersonalCenterManager:getFullAchiScore( ... )
	return medalConfig[#medalConfig].score or 0
end

function PersonalCenterManager:getMaxAchiLevel( ... )
	return #medalConfig
end

function PersonalCenterManager:updateAchievement(achiTable)
	local achiManager = AchievementManager
	
	for id, achi in pairs(achiTable) do
		if achi.achievementType == achiManager.achievementType.TRIGGER then
			local http = TriggerAchievement.new()
            local function onRequestFinish( evt )
            	SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNoAnimation)
            end
            http:addEventListener(Events.kComplete, onRequestFinish)
			http:load(achi.id)
		end
	end
end

--不能设置在别处取的数据
function PersonalCenterManager:setData( key, value )
	if key == nil or value == nil then 
		if _G.isLocalDevelopMode then printx(0, "[PersonalCenter] error setData nil") end
		return 
	end

	if _G.isLocalDevelopMode then printx(0, "setData key >>> ", key, " value >>> ", value) end

	local fs = self.dataEventFunc[key]
	if fs ~= nil then
		for _,func in ipairs(fs) do
			func(value)
		end
	end

	if key == self.AGE then
		-- UserManager:getInstance().profile.age = value
		return
	elseif key == self.SEX then
		UserManager:getInstance().profile.gender = value
		return
	elseif key == self.NAME then
		UserManager:getInstance().profile:setDisplayName(value)
		return
	elseif key == self.CONSTELLATION then
 		-- UserManager:getInstance().profile.constellation = value
 		return
 	elseif key == self.HEAD_URL then
		UserManager:getInstance().profile.headUrl = value
		return
	elseif key == self.PERCENT_RANK then
		UserManager:getInstance().achievement.pctOfRank = value
		return
	elseif key == self.STAR_GLOBAL_RANK then
		UserManager:getInstance().achievement.starGlobalRank = value
		return
	elseif key == self.SELF_INFO_VISIBLE then
		UserManager:getInstance().profile.secret = not value
		self:uploadUserProfile(false)
	elseif key == self.ADDRESS then
		UserManager:getInstance().profile:setProfile(nil, nil, nil, nil, value)
	elseif key == self.BIRTHDATE then
		UserManager:getInstance().profile:setProfile(nil, nil, nil, value, nil)
		return
	end

	self.data[key] = value
end

--需要的实时数据这里不会存储，而是实时调用方法获取
function PersonalCenterManager:getData( key )
	if self.data[key] then return self.data[key] end

	local value = nil
	if key == self.INVITE_CODE then

		if __IOS_FB then 
			return UserManager.getInstance().user.uid 
		else
			return UserManager:getInstance().inviteCode
		end

	elseif key == self.QR_CODE then
		if UserManager:getInstance().inviteCode == nil then
			if __ANDROID and PlatformConfig:isQQPlatform() then 
				return NetworkConfig.qqDownloadURL
			else
				return "http://xxl.happyelements.com/?source=spread_profile"
			end
		end
		return QRCodePostPanel:getQRCodeURL()

	elseif key == self.NAME_MODIFIABLE then

		return self:isNicknameUnmodifiable()

	elseif key == self.HEAD_MODIFIABLE then

		return self:isAvatarUnmodifiable()

	elseif key == self.STAR then
		--这里不能存储实时获取的数据，直接返回，每次实时获取
		return UserManager:getInstance():getUserRef():getTotalStar()

	elseif key == self.ACHIEVEMENTS then

		return UserManager:getInstance().achievement.achievements

	elseif key == self.POINTS then

		return UserManager:getInstance().achievement.points

	elseif key == self.PERCENT_RANK then

		return UserManager:getInstance().achievement.pctOfRank

	elseif key == self.STAR_GLOBAL_RANK then
		return UserManager:getInstance().achievement.starGlobalRank
		
	elseif key == self.PROFILE then

		return UserManager:getInstance().profile

	elseif key == self.AGE then

		return UserManager:getInstance().profile.age

	elseif key == self.SEX then

		return UserManager:getInstance().profile.gender

	elseif key == self.NAME then

		return UserManager:getInstance().profile:getDisplayName()

	elseif key == self.CONSTELLATION then

		return UserManager:getInstance().profile.constellation

	elseif key == self.HEAD_URL then

		return UserManager:getInstance().profile.headUrl

	elseif key == self.SHOULD_SHOW_ACCBTN then

		return self:shouldShowAccountBtn()

	elseif key == self.SHOW_ACCBTN_REDDOT then

		return self:hasRcmdAccountNotBinded()

	elseif key == self.SHOULD_SHOW_CARD_BTN then

		return self:shouldShowBusinessCardBtn()

	elseif key == self.TOTAL_ACHI_LEVEL then

		return self:getTotalAchiLevel()

	elseif key == self.ENABLE_CUSTOM_HEAD then

		return self:isEnbaleCustonHead()

	elseif key == self.SELF_INFO_VISIBLE then

		return not UserManager:getInstance().profile.secret

	elseif key == self.SHOW_ACCBTN_OUTSIDE_REDDOT then
		return self:shouldShowAccountOutSideRedDot()
	elseif key == self.ADDRESS then
		return nameDecode(UserManager:getInstance().profile.location)
	elseif key == self.BIRTHDATE then
		return nameDecode(UserManager:getInstance().profile.birthDate)
	end

	self.data[key] = value

	return value
end

function PersonalCenterManager:isNicknameUnmodifiable()
	return false
end

function PersonalCenterManager:isAvatarUnmodifiable()
	return false
end

function PersonalCenterManager:shouldShowAccountBtn()
	if PlatformConfig.authConfig == PlatformAuthEnum.kGuest or 
		PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then 	--微信精品包不给绑定
        return false
    end
    return true
end

function PersonalCenterManager:getTotalAchiLevel()
	local state = Achievement:getState()
	return state.maxLevel
end

function PersonalCenterManager:hasAccountBinded()
    return UserManager.getInstance().profile:isPhoneBound() or UserManager.getInstance().profile:isSNSBound()
end

function PersonalCenterManager:hasRcmdAccountNotBinded()
	if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kWechat, true) and not UserManager.getInstance().profile:isWechatBound() then
		return true
	end
	if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone) and not UserManager.getInstance().profile:isPhoneBound() then
		return true
	end
	if PlatformConfig:hasAuthConfig(PlatformAuthEnum.k360) and not UserManager.getInstance().profile:is360Bound() then
		return true
	end
	return false
end

function PersonalCenterManager:shouldShowAccountOutSideRedDot()
	if self:showBindAccountRedDot() then
		return true
	elseif self:showEditInfoRedDot() then
		return true
	end

	return false
end

function PersonalCenterManager:showBindAccountRedDot()
	if self:hasRcmdAccountNotBinded() then
		local userData = Localhost.getInstance():readCurrentUserData()
		if not userData or userData.authorType == nil then -- 游客登录一直显示
			return true
		end
	end
	return false
end

function PersonalCenterManager:showEditInfoRedDot()
	return PlatformConfig.authConfig ~= PlatformAuthEnum.kGuest and (not self:isInfoComplete())
end

function PersonalCenterManager:isInfoComplete( ... )
	local sex = PersonalCenterManager:getData(PersonalCenterManager.SEX)
	local birth = PersonalCenterManager:getData(PersonalCenterManager.BIRTHDATE)
	local address = PersonalCenterManager:getData(PersonalCenterManager.ADDRESS)
	if (not sex) or sex == 0 then return false end
	if (not birth) or birth == '' then return false end
	if (not address) or address == '' then return false end
	return true
end

function PersonalCenterManager:sortDataByRanking(friendList)
	local function rankHigher(u1, u2)
		if u1:getTotalStar() == u2:getTotalStar() then 
			if u1:getTopLevelId() == u2:getTopLevelId() then
				
				if (u1.customProfile and u2.customProfile) or (not u1.customProfile and not u2.customProfile) then
					if u1:getCoin() == u2:getCoin() then
						return u1.uid < u2.uid
					else 
						return u1:getCoin() > u2:getCoin()
					end
				else
					return u1.customProfile
				end
			else 
				return u1:getTopLevelId() > u2:getTopLevelId()
			end
		else
			return u1:getTotalStar() > u2:getTotalStar()
		end
	end
	if friendList and type(friendList) == 'table' then
		table.sort(friendList, rankHigher)
	end
end

function PersonalCenterManager:requireData()
	local friends = FriendManager:getInstance().friends
	local friendList = {}
	for k, v in pairs(friends) do
		table.insert(friendList, v)
	end
	local myself = UserManager:getInstance().user
	table.insert(friendList, myself)

	self:sortDataByRanking(friendList)

	local starRank = 0
	for index,friend in ipairs(friendList) do
		if myself == friend then
			starRank = index
			break
		end
	end

	self:setData(self.STAR_FRIEND_RANK, starRank)

	local function onSend()
	end

	local function onErrorTip()
	end
	RequireNetworkAlert:callFuncWithLogged(onSend,onErrorTip,kRequireNetworkAlertAnimation.kNoAnimation, kRequireNetworkAlertTipType.kNoTip)


	--pctOfRank
	local function onRequestError(evt)
    	--do nothing
    end

    local function onRequestFinish(evt)
    	local pctOfRank = evt.data.pctOfRank
    	self:setData(self.PERCENT_RANK, pctOfRank)
    	
    	local starRank = evt.data.starRank
    	self:setData(self.STAR_GLOBAL_RANK,starRank)
    end

    local star = self:getData(self.STAR)

    if self.data.preStar == nil or (self.data.preStar and self.data.preStar < star) then
		local http = GetPctOfRank.new()
		http:addEventListener(Events.kComplete, onRequestFinish)
	    http:addEventListener(Events.kError, onRequestError)
		http:load(star)
	end

	self.data.preStar = star
end

function PersonalCenterManager:uploadUserProfile(isUserModifiy)
	if not isUserModifiy then isUserModifiy = false end
    local profile = UserManager.getInstance().profile

	local adcode = nil
	local location = profile.location or ""
	if not string.isEmpty(location) then
		local locs = string.split(location, '#')
		if locs and table.size(locs) > 0 then
			local db = require 'zoo.ui.edit.db'
			adcode = db:findSimilarAdCodeByStr(locs[1] or "", locs[2] or "", locs[3] or "" )
		end
	end

    local http = UpdateProfileHttpOffline.new()

    if _G.sns_token then
        local authorizeType = SnsProxy:getAuthorizeType()
        local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
        local snsName = HeDisplayUtil:urlEncode(profile:getSnsUsername(authorizeType))
        if profile:getSnsInfo(authorizeType) ~= nil then
        	local snsHeadUrl = profile:getSnsInfo(authorizeType).headUrl
        	http:load(profile.name, profile.headUrl,nil,snsName, isUserModifiy, adcode)
	    	UserService.getInstance().profile:setSnsInfo(authorizeType,HeDisplayUtil:urlDecode(snsName),snsHeadUrl,HeDisplayUtil:urlDecode(profile.name),profile.headUrl)
	    	--if _G.isLocalDevelopMode then printx(0, snsName, profile.name,profile.headUrl) end debug.debug()
		end
	    Localhost.getInstance():flushCurrentUserData()
    else
        http:load(profile.name, profile.headUrl, nil, nil, isUserModifiy, adcode)
    end

    Localhost:flushCurrentUserData()
end

function PersonalCenterManager:shouldShowBusinessCardBtn()
	return not PlatformConfig:isJJPlatform()
end

function PersonalCenterManager:isEnbaleCustonHead()
	if __WIN32 then return true end
	-- local isPhoneLogin = SnsProxy:getAuthorizeType() == PlatformAuthEnum.kPhone
	local isEnabled = (_G.sns_token ~= nil)  -- 所有登陆账号登陆都可以上传头像
	if not isEnabled or __WP8 then return false end
	local selfPhotoFeature = MaintenanceManager:getInstance():isEnabled("SelfPhotoFeature")
	if PlatformConfig:isQQPlatform() then
		selfPhotoFeature = MaintenanceManager:getInstance():isEnabled("SelfPhotoFeatureYYB")
	end
	return selfPhotoFeature or false
end

function PersonalCenterManager:getLinkUrl()
	local profile = UserManager.getInstance().profile
	local uid = UserManager:getInstance().uid
	local inviteCode = UserManager:getInstance().inviteCode
	local platformName = StartupConfig:getInstance():getPlatformName()
	local pctOfRank = self:getData(self.PERCENT_RANK)
	local secret = profile.secret
	local achiString = self:getAchiString()

	local link = NetworkConfig:getShareHost() ..
							"new_card_qr_code.jsp?uid="..tostring(uid)..
							"&invitecode="..tostring(inviteCode)..
							"&name="..profile.name..
							"&headurl="..profile.headUrl..
							"&pct="..pctOfRank..
							"&pid="..tostring(platformName)..
							"&secret="..tostring(secret)..
							"&level="..tostring(UserManager.getInstance().user:getTopLevelId())..
							"&achi="..achiString

	if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		link = link.."&package=android_360"
	end
	if PlatformConfig:isQQPlatform() then
		link = link.."&isyyb=1"
	else
		link = link.."&isyyb=0"
	end
	if PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then 
		local ext = "0"
		local authorType = SnsProxy:getAuthorizeType()
		if authorType == PlatformAuthEnum.kJPQQ or authorType == PlatformAuthEnum.kJPWX then 
			ext = authorType
		end
		link = link.."&ext="..ext
	end

	if _G.isLocalDevelopMode then printx(0, 'link', link) end
	
	return link
end

function PersonalCenterManager:sendBusinessCard(onSuccess, onError, onCancel)
	local function onErrorTip()
		if self:getData(self.INVITE_CODE) then
			CommonTip:showNetworkAlert()
		else
			CommonTip:showTip(localize("my.card.send.error.tip1"),"negative",nil, 3)
		end
		
		onError()
	end

	local function onSend()
		if self:getData(self.INVITE_CODE) == nil then
			onErrorTip()
			return
		end
		self:_sendBusinessCard(onSuccess, onError, onCancel)
	end

	RequireNetworkAlert:callFuncWithLogged(onSend,onErrorTip, nil, kRequireNetworkAlertTipType.kNoTip)
end

function PersonalCenterManager:_sendBusinessCard(onSuccess, onError, onCancel)
	DcUtil:UserTrack({category='my_card', sub_category="my_card_click_send"}, true)

	local profile = UserManager.getInstance().profile
	local function onImageLoadFinishCallback(clipping)
		local shareLink = self:getLinkUrl()

		local year = os.date("*t").year
		local title = "我的专属名片"
		local message = year.."与你一起~爱上开心消消乐！"

		local thumb
		if clipping.isSns ~= true then
			thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		else
			thumb = CCFileUtils:sharedFileUtils():fullPathForFilename(clipping.headPath)
		end

		local shareCallback = {
			onSuccess = function(result)
				DcUtil:UserTrack({category='my_card', sub_category="my_card_send_success"}, true)
				if onSuccess then onSuccess(result) end
				CommonTip:showTip(localize("my.card.send.success.tips"), "positive")
			end,
			onError = function(errCode, errMsg)
				if onError then onError(errCode, errMsg) end
				CommonTip:showTip(localize("my.card.send.fail.tips"), "negative")
			end,
			onCancel = function()
				if onCancel then onCancel() end
				CommonTip:showTip(localize("my.card.send.cancel.tips"), "negative")
			end,
		}

		local shareType, delayResume = SnsUtil.getShareType()
		if shareType == PlatformShareEnum.kMiTalk then
			SnsUtil.sendInviteMessage(PlatformShareEnum.kMiTalk, shareCallback)
		else
			SnsUtil.sendLinkMessage(shareType, title, message, thumb, shareLink, false, shareCallback)
		end
    end
    HeadImageLoader:create(nil, profile.headUrl, onImageLoadFinishCallback)
end

function PersonalCenterManager:onKeyBackClicked()
	local function onClose()
		local photoManager = luajava.bindClass("com.happyelements.android.photo.PhotoManager"):get()
		if photoManager then
			photoManager:onKeyBackClicked()
		end
		self:setData(self.IS_TAKE_PHOTO, false)
		
		-- if self.panel == nil then
		-- 	self:showPersonalCenterPanel()
		-- 	self.panel.avatarSelectGroup:onAvatarTouch()
		-- else
		-- 	self.panel.avatarSelectGroup:onAvatarTouch()
		-- end
	end

	pcall(onClose)
end

function PersonalCenterManager:reigsterDataEvent(key, func)
	local fs = self.dataEventFunc[key]
	if fs == nil then
		self.dataEventFunc[key] = {}
	end

	table.insert(self.dataEventFunc[key], func)
end

function PersonalCenterManager:unreigsterDataEvent( key )
	--TODO:
	self.dataEventFunc[key] = nil
end

function PersonalCenterManager:showPersonalCenterPanel(showGuide)
	self:requireData()
	-- local PersonalCenterPanel 
	-- if WXJPPackageUtil.getInstance():isWXJPPackage() then 
	-- 	if WXJPPackageUtil.getInstance():isGuestLogin() then 
	-- 		PersonalCenterPanel = require "zoo.PersonalCenter.PersonalCenterPanelSimple"
	-- 	else
	-- 		PersonalCenterPanel = require "zoo.PersonalCenter.PersonalCenterPanelJP"
	-- 	end
	-- else
	-- 	PersonalCenterPanel = require "zoo.PersonalCenter.PersonalCenterPanel"
	-- end
	-- if PersonalCenterPanel then 
	-- 	self.panel = PersonalCenterPanel:create(self)
	-- 	self.panel:popout()
	-- end

	self.panel = require("zoo.PersonalCenter.PersonalInfoPanel"):create(showGuide)
	self.panel:popout()
end

function PersonalCenterManager:getAchiString()
	return Achievement:getProgressString()
end

PersonalCenterManager:init()