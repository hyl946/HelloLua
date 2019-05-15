local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

Mark2019FullMarkShare = class(BasePanel)
function Mark2019FullMarkShare:create( closeCall )
    local panel = Mark2019FullMarkShare.new()
    panel:init(closeCall)
    return panel
end

function Mark2019FullMarkShare:init(closeCall)

    self.closeCall = closeCall

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/FullMarkSharePanel")
    BasePanel.init(self, ui)

    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local gCenterPos = IntCoord:create(vOrigin.x + vSize.width / 2, vOrigin.y + vSize.height / 2)
    self.gCenterPos = gCenterPos

    self.ShowWXBtn = true
    local eShareType = SnsUtil.getShareType()
    if eShareType == PlatformShareEnum.kJPQQ then
        self.ShowWXBtn = false
    end

    ---1
    local okbtn = self.ui:getChildByName('okbtn')
    self.ok_btn = ButtonIconsetBase:create(okbtn)

    if self.ShowWXBtn then
        self.ok_btn:setIconByFrameName('common_icon/sns/icon_wechat0000')
        self.ok_btn:setString("分享给好友")
    else
        self.ok_btn:setIconByFrameName('common_icon/sns/icon_qq0000')
        self.ok_btn:setString("分享给好友")
        self.ok_btn:setPositionX( 960/2 )
    end
    
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        local function shareEndCall()
            self:onCloseBtnTapped()
        end
        self:share( shareEndCall, false )

        Mark2019Manager.getInstance():DC( 'share_sendOut', 2, Mark2019Manager.getInstance().month  )
    end) 
    self.ok_btn:setVisible(false)
    self.ok_btn:setScale(0.7)

    ---2
    local okbtn2 = self.ui:getChildByName('okbtn2')
    self.okbtn2 = ButtonIconsetBase:create(okbtn2)
    self.okbtn2:setIconByFrameName('common_icon/sns/icon_timeline0000')
    self.okbtn2:setString("分享朋友圈")

    self.okbtn2:setColorMode(kGroupButtonColorMode.green)
    self.okbtn2:ad(DisplayEvents.kTouchTap, function( )
        local function shareEndCall()
            self:onCloseBtnTapped()
        end
        self:share( shareEndCall, true )

        Mark2019Manager.getInstance():DC( 'share_sendOut', 1, Mark2019Manager.getInstance().month )
    end) 
    self.okbtn2:setVisible(false)
    self.okbtn2:setScale(0.7)
end

function Mark2019FullMarkShare:_close()
    Mark2019Manager.getInstance():removeObserver(self)
    if self.closeCall then self.closeCall() end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019FullMarkShare:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 220)
    self.allowBackKeyTap = true
    self:popoutShowTransition()

    Mark2019Manager.getInstance():DC( 'share_popUp', Mark2019Manager.getInstance().month )
end

function Mark2019FullMarkShare:popoutShowTransition()

    self.bCanClickBtn = false

    Mark2019Manager.getInstance():addObserver(self)

    --适配
    local wSize = CCDirector:sharedDirector():getWinSize()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local realVisibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local worldPos = ccp( vOrigin.x+vSize.width-90, vOrigin.y+vSize.height-50 )

    local newPos = self.ui:convertToNodeSpace( worldPos)
    local cloeseBtn = self.ui:getChildByName('cloese')
    cloeseBtn:setPosition( newPos )
    cloeseBtn:setVisible(false)

    --动作
    local asyncRunner = Misc.AsyncFuncRunner:create()

    asyncRunner:add(function ( done )
        if self.isDisposed then return end
        
        self:ShareShowOut( done )
    end)

    asyncRunner:run()
end

function Mark2019FullMarkShare:buildQRCode( node, url, width, pos, angle)
	local sprite = CocosObject.new(QRManager:generatorQRNode(url, width, 1, ccc4(0, 0, 0, 255)))
	sprite:setAnchorPoint(ccp(0.5, 0.5))
	sprite:setPosition(ccp(0, 0))
	sprite:setRotation(angle or 0)
	local container = Layer:create()
	container:addChild(sprite)

	container:setPosition(ccp(pos.x, pos.y))
	container:setScale(width / container:getGroupBounds().size.width)
	node:addChild(container.refCocosObj)

	local iconPath = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local icon = Sprite:create(iconPath)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setRotation(angle or 0)
	container:addChild(icon)

	icon:setScale(width*0.16 / icon:getContentSize().width)

    container:dispose()
end

function Mark2019FullMarkShare:ShareShowOut()
    local balloon_anim = ArmatureNode:create('markAnim2019_3/fullMarkAnim' )
    balloon_anim:playByIndex(0)
    balloon_anim:update(0.001)
    balloon_anim:stop()

    local worldPos = ccp(self.gCenterPos.x, self.gCenterPos.y)
    local pos = self.ui:convertToNodeSpace( ccp(worldPos.x,worldPos.y) )
    balloon_anim:setPosition( ccp(pos.x-235/0.7,pos.y+460/0.7) )
    self.ui:addChildAt( balloon_anim, 3 )
    self.balloon_anim = balloon_anim

    local bg = UIHelper:getCon(balloon_anim,"bg")
    local title = UIHelper:getCon(balloon_anim,"title")

    --二维码
    local url = 'http://xxl.happyelements.com'
    self:buildQRCode( bg, url, 140, ccp(448+18/0.7, 52+44/0.7), 0)

    --头像框
    local profile = UserManager.getInstance().profile
	if profile and profile.headUrl then
		local function onImageLoadFinishCallback(clipping)
			if self.isDisposed then return end
			
		end
		local head = HeadImageLoader:createWithFrame(profile.uid, profile.headUrl)
        head:setPosition(ccp(200/0.7,560/0.7))
        bg:addChild(head.refCocosObj)
		onImageLoadFinishCallback(head)

        head:dispose()
	end

    --name
    local UserName = profile.name or "消消乐玩家"
    local namelabel = TextField:create( nameDecode(UserName), nil, 32 )
    namelabel:setPosition( ccp(200/0.7,508/0.7) )
    namelabel:setAnchorPoint(ccp(0.5, 0.5))
    namelabel:setScale(0.8)
    namelabel:setColor( hex2ccc3('D24600') )
    bg:addChild(namelabel.refCocosObj)
    namelabel:dispose()

    --time
    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month
    local YearStr = ""..year.."年"..month.."月"
    local YearLabel = BitmapText:create( YearStr ,"fnt/qiandao3.fnt")
    YearLabel:setPosition( ccp(157/0.7,52/0.7) )
    YearLabel:setScale(1)
--    YearLabel:setColor( hex2ccc3('D24600') )
    YearLabel:setAnchorPoint(ccp(0.5, 0.5))
    title:addChild(YearLabel.refCocosObj)
    namelabel:dispose()

    --天数覆盖
    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month
    local curMonthHasDay = Mark2019Manager.getInstance():getDayByYearMonth( year, month )
    curMonthHasDay = tonumber(curMonthHasDay)

    local DayChangeList = {}
    if curMonthHasDay < 31 then
        if curMonthHasDay == 28 then
            for i=1, 2 do
                local sp = Sprite:createWithSpriteFrameName("Mark2019/noday0000")
                sp:setScale(0.857)
                bg:addChild( sp.refCocosObj )

                table.insert(DayChangeList, 1, sp)
            end
        elseif curMonthHasDay == 29 then
            local sp = Sprite:createWithSpriteFrameName("Mark2019/noday0000")
            sp:setScale(0.857)
            bg:addChild( sp.refCocosObj )

            table.insert(DayChangeList, 1, sp)

        elseif curMonthHasDay == 30 then
            local sp = Sprite:createWithSpriteFrameName("Mark2019/30daySing0000")
            sp:setScale(0.857)
            bg:addChild( sp.refCocosObj )

            table.insert(DayChangeList,sp)
        end
    end

    for i,v in ipairs(DayChangeList) do
        v:setPosition( ccp(489-(i-1)*80,254))

        v:dispose()
    end

    --动作
    balloon_anim:play("a", 1)
    balloon_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	balloon_anim:removeAllEventListeners()
        if done then done() end 
    end)

    local function showOkBtn()
        if self.ShowWXBtn then
            self.ok_btn:setVisible(true)
            self.okbtn2:setVisible(true)
        else
            self.ok_btn:setVisible(true)
        end

        local cloeseBtn = self.ui:getChildByName('cloese')
        cloeseBtn:setVisible(true)
    end
    
    local array = CCArray:create()
    array:addObject( CCDelayTime:create(2)  )
    array:addObject(CCCallFunc:create(showOkBtn))
    self.ok_btn.groupNode:runAction(CCSequence:create(array))
end


function Mark2019FullMarkShare:isLowDevice( ... )
    local function isIOSLowDevice()
        local result = false

        pcall(function ( ... )
            local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
            local deviceType = MetaInfo:getInstance():getMachineType() or ""
            local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
            local freeMemory = AppController:getFreeMemory()
            local totalMemory = AppController:getTotalMemory()
            physicalMemory = physicalMemory / (1024 * 1024)
            if physicalMemory < 1100 or frame.width < 400 then result = true end
        end)
        

        return result
    end

    local function isAndroidLowDevice()
        -- android 
        local result = false

        pcall(function ( ... )
            local physicalMemory = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil"):getSysMemory()
            local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
            physicalMemory = physicalMemory / (1024 * 1024)
            if physicalMemory < 1100 or frame.width < 400 then result = true end
            if physicalMemory < 0 then result = false end
        end)
        
        return result
    end

    local function isLowDevice()
        if __IOS then
            return isIOSLowDevice()
        elseif __ANDROID then
            return isAndroidLowDevice()
        end  
        return false
    end

    return isLowDevice()
end

function Mark2019FullMarkShare:share( callback,bTimeLine )

    local amILowDev = self:isLowDevice()

    local shareCallback = {
        onSuccess = function(result)

            if callback then
                callback()
            end
        end,
        onError = function(errCode, errMsg)
            if callback then
                callback()
            end
        end,
        onCancel = function()
            if callback then
                callback()
            end
        end,
    }

    if amILowDev then
        shareCallback.onSuccess()
        return
    end

    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month

    local url = 'http://xxl.happyelements.com'
    local title = localize("newsignin.share.panel.title",{Year = year, Month=month })
    local message = localize("newsignin.share.panel.desc")

    if __WIN32 or (__ANDROID and (not WXJPPackageUtil.getInstance():isWXJPPackage())) then
        local path, thumb = self:createSharePicture(url)
        local title = localize(title)
        local message = localize(message)
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
        SnsUtil.sendImageMessage(androidShareType, title, message, thumb, path, shareCallback, bTimeLine, gShareSource.WEEKLY_MATCH)
    elseif __IOS then

        if not SnsProxy:isWXAppInstalled() then
            setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
            return
        end
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end
        local path, thumb = self:createSharePicture(url)
        local title = localize(title)
        local message = localize(message)
        message = message .. url
        local eShareType = SnsUtil.getShareType()
        SnsUtil.sendImageMessage(eShareType, title, message, thumb, path, shareCallback, bTimeLine, gShareSource.WEEKLY_MATCH)
    else

        local path, thumbPath = self:createSharePicture(url)
        local title = localize(title)
        local message = localize(message)
        message = message .. url
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end
        if not SnsProxy:isWXAppInstalled() then
            setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
            return
        end
        local androidShareType = SnsUtil.getShareType()
        SnsUtil.sendImageMessage(androidShareType, title, message, thumbPath, path, shareCallback, bTimeLine, gShareSource.WEEKLY_MATCH)
    end
end

function Mark2019FullMarkShare:createSharePicture( url )
    local SharePicture = require('zoo.panel.Mark2019.Mark2019SharePicture')
    local sharePicture = SharePicture.new()

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/sharePanel")
    sharePicture.panel:addChild(ui)
    sharePicture.bg = ui

    local path, thumb = sharePicture:capture( self.balloon_anim )
    sharePicture:dispose()
    return path, thumb
end

function Mark2019FullMarkShare:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019FullMarkShare:onCloseBtnTapped( ... )
    self:_close()
end

function Mark2019FullMarkShare:onPassDay()
    self:_close()
end

return Mark2019FullMarkShare