require 'hecore.display.ShapeNode'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'

local UIHelper = require 'zoo.panel.UIHelper'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local XFSharePanel = class(BasePanel)

function XFSharePanel:create(xfData)
    local panel = XFSharePanel.new()
    panel:init(xfData)
    return panel
end


function XFSharePanel:popoutShowTransition( ... )
    if self.isDisposed then return end
    self.allowBackKeyTap = true
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, 5)

    DcUtil:UserTrack({
        category = 'StarRanking',
        sub_category = 'fullStar_popup',
    })

    if self.popoutCallback then
        self.popoutCallback()
    end
end

function XFSharePanel:init(xfData)
    local ui = UIHelper:createUI("ui/xf_share.json", "xf_share_panel/panel")

    UIUtils:adjustUI(ui, 222, nil, nil, 1724)


	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)


    local anim = UIHelper:createArmature2('skeleton/xf_share', 'xf_share/anim')
    self.ui:addChild(anim)

    anim:setPosition(ccp(480, - 720))
    anim:playByIndex(0, 1)

    self.xfData = xfData or XFLogic:getTestIdCardData(500)

    local rankPH = anim:getCon('tile')


    local txt = BitmapText:create(tostring(self.xfData.fullstar_rank), 'fnt/share.fnt')
    txt:setAnchorPoint(ccp(0.5, 0.5))
    txt:setPosition(ccp(0, 0))
    txt:setScale(1.7)

    local txt1 = BitmapText:create(tostring('全国第'), 'fnt/tutorial_white.fnt')
    txt1:setAnchorPoint(ccp(0.5, 0.5))
    txt1:setPosition(ccp(0, 0))
    local txt2 = BitmapText:create(tostring('名'), 'fnt/tutorial_white.fnt')
    txt2:setPosition(ccp(0, 0))
    txt2:setAnchorPoint(ccp(0.5, 0.5))



    local container = Layer:create()
    container:addChild(txt1)
    container:addChild(txt)
    container:addChild(txt2)

    local layoutItems = {
    	{node = txt1},
    	{node = txt},
    	{node = txt2},
	}
	local utils = require 'zoo.panel.happyCoinShop.utils'
	utils.horizontalLayoutItems(layoutItems)

	local size = container:getGroupBounds().size
	container:setContentSize(CCSizeMake(size.width, size.height))
	container:setPosition(ccp((309 - size.width)/2, 58/2 + 5))

	UIHelper:move(txt, 0, -7)

    rankPH:addChild(container.refCocosObj)
    container:dispose()



    local headPH = anim:getCon('headPH')

    local headPart = UIHelper:createUI('ui/xf_share.json', 'xf_share_panel/head')
    headPart:setPosition(ccp(121.05, 120))
    UIHelper:setUserName(headPart:getChildByPath('name'), self.xfData.profile:getDisplayName())
    headPart:getChildByPath('time'):setString(os.date("%Y-%m-%d %H:%M", self.xfData.fullstar_ts / 1000))
    

	local holder = headPart:getChildByPath('holder')
	holder:setVisible(false)

	local holderIndex = headPart:getChildIndex(holder)

	local width = holder:getContentSize().width
	local height = width

	local circleHead = self:createCircleHeadImage(self.xfData, width)
	circleHead:setPosition(ccp(holder:getPositionX() + width /2, holder:getPositionY() - height /2))


	headPart:addChildAt(circleHead, holderIndex)


    headPH:addChild(headPart.refCocosObj)
    headPart:dispose()


    local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    

    if Misc:isSupportShare() then
	    btn:setString('炫耀一下')
	    btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    		self:share()

            DcUtil:UserTrack({
                category = 'StarRanking',
                sub_category = 'fullStar_share',
            })
    	end))



    else
    	btn:setString('知道了')

    	btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    		self:onCloseBtnTapped()
    	end))

    end

end

function XFSharePanel:createCircleHeadImage( xfData, width )
	-- body
	local userHead = HeadImageLoader:create(xfData.profile.uid, xfData.profile.headUrl, function ( headImg )

	end)
	userHead:setScale(width / 100)


	local vertices = CCPointsArray:create()
	local center = ccp(0.0, 0.0)
	local radius = width/2
	local n = 64
	for i = 1, n + 1 do
		local angle = 2 * math.pi / n * (i - 1)
		vertices:add(ccp(
			center.x + radius * math.cos(angle), 
			center.y + radius *math.sin(angle)
		))
	end
	local c = CCPolygonShape:create(vertices)
	c:setFill(true)
	c:setColor(ccc4f(1,1,0,1))


  	local wrapper = CCNode:create()
  	wrapper:addChild(c)

	local clipNode = ClippingNode.new(CCClippingNode:create(wrapper))
	-- local clipNode = Layer:create()
	-- clipNode:addChild(CocosObject.new(wrapper))
	clipNode:addChild(userHead)
	clipNode:setAlphaThreshold(1 - 1/1000000)

	return clipNode

end




function XFSharePanel:createSharePicture( url )

    local sharePicture = SharePicture.new()


	function sharePicture:__capture(path)
		local panelSize = self.panel:getGroupBounds().size

		local bgSize = self.bg:getGroupBounds().size

		local GL_DEPTH24_STENCIL8 = 0x88F0  --c++中定义的
		local renderTexture = CCRenderTexture:create(bgSize.width, bgSize.height, kCCTexture2DPixelFormat_RGBA8888, GL_DEPTH24_STENCIL8)
		self.panel:setPosition(ccp(0, bgSize.height))
		renderTexture:begin(0, 0, 0, 0)
		self.panel:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(path)
	end


    sharePicture:setBackgroundByPathname('materials/xf_feed.jpg')

    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    sharePicture:buildQRCode(url, 140, ccp(20+158/2, -521-158/2), 0)

	local width = 120
	local height = 120
	local headImage = self:createCircleHeadImage(self.xfData, 120)
	headImage:setPosition(ccp(309.85 + width /2, -240.5 - height /2))


	sharePicture:addChild(headImage)

	local userNameLabel = TextField:create(self.xfData.profile:getDisplayName(), nil, 28)
	userNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	userNameLabel:setPosition(ccp(373.4, -390))
	sharePicture:addChild(userNameLabel)


	local txt = BitmapText:create(tostring(self.xfData.fullstar_rank), 'fnt/share.fnt')
    txt:setAnchorPoint(ccp(0.5, 0.5))
    txt:setPosition(ccp(390, -482))
    txt:setScale(1.7)
   	sharePicture:addChild(txt)

    local labelUI = UIHelper:createUI("ui/xf_share.json", "xf_share_panel/label")
    sharePicture:addChild(labelUI)
    labelUI:setVisible(false)


    local l1 = Sprite:createWithSpriteFrameName('xf_share_panel/l10000')
    local l2 = Sprite:createWithSpriteFrameName('xf_share_panel/l20000')

    sharePicture:addChild(l1)
    sharePicture:addChild(l2)

    l1:setAnchorPoint(ccp(1, 0.5))
    l2:setAnchorPoint(ccp(0, 0.5))

    l1:setPositionX(txt:getPositionX() - txt:getContentSize().width/2 * 1.7)
    l2:setPositionX(txt:getPositionX() + txt:getContentSize().width/2 * 1.7 + 4)
    l1:setPositionY(txt:getPositionY() + 6)
    l2:setPositionY(txt:getPositionY() + 6)

    local totalWidth = l2:getPositionX() + l2:getContentSize().width - l1:getPositionX() - l1:getContentSize().width
    local targetX = (1025 - totalWidth) / 2

    local delta = targetX - l1:getPositionX() - l1:getContentSize().width
    UIHelper:move(l1, delta, 0)
    UIHelper:move(l2, delta, 0)
    UIHelper:move(txt, delta, 0)




    local path, thumb = sharePicture:capture()

    sharePicture:dispose()

    return path, thumb

end

function XFSharePanel:share( ... )
	if self.isDisposed then return end

	require 'zoo.quarterlyRankRace.RankRaceHttp'



	local shareCallback = {
        onSuccess = function(result)
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享成功', 'positive')
            end
        end,
        onError = function(errCode, errMsg)
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享失败')
            end
        end,
        onCancel = function()
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享取消')
            end
        end,
    }


    local uid = UserManager.getInstance().user.uid

    local url = Misc:buildURL(NetworkConfig.dynamicHost, 'fullStarRank.jsp', {
        pid = StartupConfig:getInstance():getPlatformName() or '',
        game_name = 'xf_rank',
        aaf = 5,
        invitecode = UserManager:getInstance().inviteCode,
        uid = uid,
        star = UserManager:getInstance().curRoundFullStar,
    })

    if PlatformConfig:isQQPlatform() then
        url = NetworkConfig.wxzQQDowanloadURL
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kIOS) or
        PlatformConfig:isPlatform(PlatformNameEnum.kHE) or
        PlatformConfig:isPlatform(PlatformNameEnum.kTF) then
        url = NetworkConfig.wxzHEDowanloadURL
    end

    local title = localize('xf.rank.share.title')
    local message = localize('xf.rank.share.message')

    RankRaceHttp:getShortUrl(url, function ( url )
    	if __WIN32 or (__ANDROID and (not WXJPPackageUtil.getInstance():isWXJPPackage())) then
    	
    	    local path, thumbPath = self:createSharePicture(url)

    	    message = message .. url

    		if __WIN32 then
        	    shareCallback.onSuccess()
            	return
        	end

            if not SnsProxy:isWXAppInstalled() then
                setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
                return
            end

        	local androidShareType = 8
    		AndroidShare.getInstance():registerShare(androidShareType)
    	    SnsUtil.sendImageMessage(androidShareType, title, message, thumbPath, path, shareCallback, true, gShareSource.WEEKLY_MATCH)
    	else

            if not SnsProxy:isWXAppInstalled() then
                setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
                return
            end

    	    local eShareType = SnsUtil.getShareType()

    	    local thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/xf_thumb.jpg")
    	    local isSend2FriendCircle = false
    	    SnsUtil.sendLinkMessage(eShareType, title, message, thumbUrl, url, isSend2FriendCircle, shareCallback)
    	end
    end)

    self:_close()
end

function XFSharePanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)

    XFLogic:popoutMainPanel(true)
end

function XFSharePanel:popout()
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self:popoutShowTransition()
end

function XFSharePanel:popoutPush(popoutCallback)
    self.popoutCallback = popoutCallback
	PopoutQueue:sharedInstance():push(self, true)
end

function XFSharePanel:onCloseBtnTapped( ... )
    self:_close()
end



return XFSharePanel
