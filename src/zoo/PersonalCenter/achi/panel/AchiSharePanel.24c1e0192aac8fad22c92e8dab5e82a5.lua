local SharePicture = class()

function SharePicture:ctor()
    self.panel = Layer:create()
end

function SharePicture:dispose()
    self.panel:dispose()
    self.panel = nil

    self:unloadRequiredResource()

    if self.bgPathname then
        CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(self.bgPathname))
    end
end

function SharePicture:setBackground(bg)
    self.bg = bg
    bg:setAnchorPoint(ccp(0, 1))
    self.panel:addChild(self.bg)
end

function SharePicture:setBackgroundByPathname(bgPathname)
    local bg = Sprite:create(bgPathname)
    if _G.__use_small_res == true then
        bg:setScale(0.625)
    end
    self:setBackground(bg)
    self.bgPathname = bgPathname
end

function SharePicture:capture()
    local shareImagePath = self:captureSharePicture()
    local thumbImagePath = self:captureThumbPicture()
    return shareImagePath, thumbImagePath
end

function SharePicture:captureSharePicture()
    local path = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

    if __ANDROID then
        pcall(function ( ... )
            path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory() .. "/share_image.jpg"
        end)
    end

    local scale = 1

    if _G.__use_small_res == true then
        scale = scale / 0.625
    end

    self.panel:setScale(scale)

    

    self:__capture(path)
    return path
end

function SharePicture:captureThumbPicture()
    local path = HeResPathUtils:getResCachePath() .. "/thumb_image.jpg"

    if __ANDROID then
        pcall(function ( ... )
            path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory() .. "/thumb_image.jpg"
        end)
    end

    self.panel:setScale(1)
    local panelSize = self.panel:getGroupBounds().size
    local scale = 200 / math.max(panelSize.width, panelSize.height)

    if _G.__use_small_res == true then
        scale = scale / 0.625
    end

    if _G.__use_small_res == true then
        scale = scale / 0.625
    end

    self.panel:setScale(scale)
    self:__capture(path)
    return path
end

function SharePicture:__capture(path)
    local panelSize = self.panel:getGroupBounds().size

    local bgSize = self.bg:getGroupBounds().size

    local renderTexture = CCRenderTexture:create(bgSize.width, bgSize.height)
    self.panel:setPosition(ccp(0, bgSize.height))
    renderTexture:begin()
    self.panel:visit()
    renderTexture:endToLua()
    renderTexture:saveToFile(path)
end

function SharePicture:addChild(node)
    self.panel:addChild(node)
end



function SharePicture:share(shareImagePath, thumbPath, isFeeds, onSuccessCallback, onFailCallback, onCancelCallback)
    local shareCallback = {
        onSuccess = function(result)
            if onSuccessCallback then
                onSuccessCallback()
            end
            CommonTip:showTip('分享成功', 'positive')
        end,
        onError = function(errCode, errMsg)
            if onFailCallback then
                onFailCallback()
            end
            CommonTip:showTip('分享失败', 'negative')
        end,
        onCancel = function()
            if onCancelCallback then
                onCancelCallback()
            end
            CommonTip:showTip('分享取消', 'negative')
        end,
    }

    if __WIN32 then
        shareCallback.onSuccess()
        return
    end
    
    local title = ''
    local message = ''
    if shareImagePath then
        if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
            SnsUtil.sendImageMessage(PlatformShareEnum.kMiTalk, title, message, thumbPath, shareImagePath, shareCallback, isFeeds)
        else
            SnsUtil.sendImageMessage(PlatformShareEnum.kWechat, title, message, thumbPath, shareImagePath, shareCallback, isFeeds)
        end
    end
end

--只有 全家福实物奖励 才需要传 eggType
function SharePicture:generateUrl(t, eggType)
    local uid = UserManager.getInstance().user.uid
    local url = string.format(
        '%sspring_2017.jsp?t=%d&uid=%s',
        NetworkConfig.dynamicHost, 
        t,
        tostring(uid)
    )

    if eggType then
        url = url .. '&eggType=' .. tostring(eggType)
    end

    return url
end

function SharePicture:buildQRCode( url, width, pos, angle)
    local sprite = CocosObject.new(QRManager:generatorQRNode(url, width, 1, ccc4(0, 0, 0, 255)))
    sprite:setAnchorPoint(ccp(0.5, 0.5))
    sprite:setPosition(ccp(0, 0))
    sprite:setRotation(angle or 0)
    local container = Layer:create()
    container:addChild(sprite)

    container:setPosition(ccp(pos.x, pos.y))
    container:setScale(width / container:getGroupBounds().size.width)
    self:addChild(container)


    -- local iconPath = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
    -- local icon = Sprite:create(iconPath)
    -- icon:setAnchorPoint(ccp(0.5, 0.5))
    -- icon:setRotation(angle or 0)
    -- container:addChild(icon)

    -- icon:setScale(width*0.16 / icon:getContentSize().width)
end


function SharePicture:build( ui, rewardItem, callback )
    local feedNode = ui
    local profile = UserManager:getInstance().profile
    local headerUi = feedNode:getChildByName("head")
    local nameLabel = headerUi:getChildByName("nick_name")
    local nickName = profile and profile:getDisplayName() or nil
    if nickName and string.len(nickName) > 0 then
        nickName = TextUtil:ensureTextWidth( nickName, nameLabel:getFontSize(), nameLabel:getDimensions())
        nameLabel:setString(nickName)
    end



    local rewardUI = feedNode:getChildByName('reward')
    self:buildReward(rewardUI, rewardItem)

    self:buildHeader(headerUi:getChildByName('header'), profile.uid, profile.headUrl, callback)
end


function SharePicture:buildHeader(ui, friendId, headUrl, callback)
    local header = ui
    local ph = header:getChildByName("ph")
    local phGb = ph:getGroupBounds(header)
    local posX, posY = phGb.origin.x, phGb.origin.y
    local width, height = phGb.size.width, phGb.size.height
    local phZOrder = ph:getZOrder()
    ph:removeFromParentAndCleanup(true)

    local function onImageLoadFinishCallback(clipping)
        if not header or header.isDisposed then return end
        local clippingSize = clipping:getContentSize()
        local scale = width/clippingSize.width
        clipping:setScale(scale)
        clipping:setPosition(ccp(posX+width/2,posY+height/2))
        header:addChildAt(clipping, phZOrder)

        if callback then callback() end
    end
    HeadImageLoader:create(friendId, headUrl, onImageLoadFinishCallback)
end

function SharePicture:buildReward( rewardUI, rewardItem  )

    local itemUI = rewardUI

    local holder = itemUI:getChildByName('holder')
    local num = itemUI:getChildByName('num')
    num:changeFntFile('fnt/target_amount.fnt')
    num:setScale(num:getScale()*1.3)

    local rewardSP = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
    rewardSP:setAnchorPoint(ccp(0.5, 0.5))

    holder:setAnchorPointCenterWhileStayOrigianlPosition()
    local pos = holder:getPosition()
    rewardSP:setPosition(ccp(pos.x, pos.y))

    local holderIndex = itemUI:getChildIndex(holder)
    itemUI:addChildAt(rewardSP, holderIndex)

    local text = tostring('x'..rewardItem.num)

    num:setText(text)
    num:setPositionX(num:getPositionX() + 135 - num:getContentSize().width)
    holder:removeFromParentAndCleanup(true)

end


function SharePicture:loadRequiredResource( panelConfigFile )
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function SharePicture:unloadRequiredResource()
    if self.panelConfigFile then
        InterfaceBuilder:unloadAsset(self.panelConfigFile)
    end
end

function SharePicture:buildInterfaceGroup( groupName )
    if self.builder then return self.builder:buildGroup(groupName)
    else return nil end
end

local AchiSharePanel = class(BasePanel)
function AchiSharePanel:create(grade, builder)
	local panel = AchiSharePanel.new()
	panel:init(grade, builder)
	return panel
end

function AchiSharePanel:init(grade, builder)
	self.grade = grade
	self.ui = Layer:create()
	BasePanel.init(self, self.ui)

	FrameLoader:loadArmature('skeleton/achi_share', 'achi_share', 'achi_share')
	local anim = ArmatureNode:create("grade"..self.grade, true)
	if not anim then return end
    anim:playByIndex(0, 1)
    anim:setPosition(ccp(350,-750))
    self.ui:addChild(anim)

    local titleSlot = anim:getSlot("tile")
    local spcon = tolua.cast(titleSlot:getCCDisplay(), "CCSprite")
    if spcon then
        local charWidth = 35
        local charHeight = 35
        local charInterval = 32
        local fntFile = "fnt/share.fnt"
        local titleStr = localize('achievement.show.off.content', {medal = localize('achievement.medal.title'..grade)})
        local newCaptain = BitmapText:create(titleStr, fntFile, -1, kCCTextAlignmentCenter)
        newCaptain:setScale(1.2)
        newCaptain:setPosition(ccp(180, 18))

        spcon:addChild(newCaptain.refCocosObj)
        newCaptain:dispose()
    end

    local share_mc = builder:buildGroup('achievement/share_btn')
    share_mc:setPosition(ccp(350,-850))
    self.ui:addChild(share_mc)
   	local share_btn = GroupButtonBase:create(share_mc)
    if not self:shareDisabled() then 
        share_btn:setString(localize('share.feed.button.achive'))
    else
        share_btn:setString('确定')
    end
    share_btn:addEventListener(DisplayEvents.kTouchTap, function()
        self:onCloseBtnTapped(true) 
        if not self:shareDisabled() then 
            DcUtil:UserTrack({ category='ui', sub_category='G_achievement_show_off', other='t2'})
            local shareCallback = {
                onSuccess = function(result)
                    CommonTip:showTip('分享成功', 'positive')
                end,
                onError = function(errCode, errMsg)
                    CommonTip:showTip('分享失败')
                end,
                onCancel = function()
                    CommonTip:showTip('分享取消')
                end,
            }
            
            if not SnsProxy:isWXAppInstalled() then
                setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
                return
            end

            local shareType, delayResume = SnsUtil.getShareType()
            local title = localize('achievement.show.off.title')
            local message = localize('achievement.show.off.content', {medal = localize('achievement.medal.title'..self.grade)})
            local path, thumbPath = self:createSharePicture('http://xxl.happyelements.com')
            SnsUtil.sendImageMessage(shareType, title, message, thumbPath, path, shareCallback)
        end
    end)

    local close_btn = ResourceManager:sharedInstance():buildGroup("ui_buttons/ui_button_close_brown")
    close_btn:setTouchEnabled(true, 0, true)
    close_btn:setButtonMode(true)
	close_btn:addEventListener(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped() 
    end)
    close_btn:setPosition(ccp(670,-50))
    self.ui:addChild(close_btn)
end

function AchiSharePanel:createSharePicture( url )
    local sharePicture = SharePicture.new()
    sharePicture:setBackgroundByPathname('share/achi_upgrade_'..self.grade ..'.png')

    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    sharePicture:buildQRCode(url, 180, ccp(12+180/2, -530-180/2), 0)

    local path, thumb = sharePicture:capture()

    sharePicture:dispose()

    return path, thumb

end

function AchiSharePanel:shareDisabled()   -- JJ、mitalk不能微信求助
    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) 
    or PlatformConfig:isPlatform(PlatformNameEnum.kMiPad)
    or __WIN32
    or PlatformConfig:isPlatform(PlatformNameEnum.kJJ) then
        return true
    end
    return false
end

function AchiSharePanel:popout()
    DcUtil:UserTrack({ category='ui', sub_category='G_achievement_show_off', other='t1'})
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function AchiSharePanel:onCloseBtnTapped()
    if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

return AchiSharePanel