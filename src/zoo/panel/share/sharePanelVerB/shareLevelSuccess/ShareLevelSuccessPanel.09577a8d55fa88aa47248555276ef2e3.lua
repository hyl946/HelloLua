require "zoo.panel.basePanel.BasePanel"
require "zoo.util.HeadImageLoader"
require "zoo.net.LevelType"
require "hecore.utils"

local SelectShareWay = require "zoo.panel.share.sharePanelVerB.components.SelectShareWay"
local UIHelper = require "zoo.panel.UIHelper"

ShareLevelSuccessPanel = class(BasePanel)

local ShareLevelSuccessPassType = 
{
    kFourStar = 1,
    kThreeStarNormal = 2,
    kThreeStarDifficult = 3,
    kThreeStarExtremeDifficult = 4,
    kBelowThreeStarNormal = 5,
    kBelowThreeStarDifficult = 6,
    kBelowThreeStarExtremeDifficult = 7,
    kThreeStarHidden = 8,
    kBelowThreeStarHidden = 9
}

local TitleText1Map = --todo: 文案
{
    [ShareLevelSuccessPassType.kFourStar] = "获得了{num}分",
    [ShareLevelSuccessPassType.kThreeStarNormal] = "获得了{num}分",
    [ShareLevelSuccessPassType.kThreeStarDifficult] = "获得了{num}分",
    [ShareLevelSuccessPassType.kThreeStarExtremeDifficult] = "获得了{num}分",
    [ShareLevelSuccessPassType.kBelowThreeStarNormal] = "太棒了！",
    [ShareLevelSuccessPassType.kBelowThreeStarDifficult] = "太棒了！",
    [ShareLevelSuccessPassType.kBelowThreeStarExtremeDifficult] = "太棒了！",
    [ShareLevelSuccessPassType.kThreeStarHidden] = "获得了{num}分",
    [ShareLevelSuccessPassType.kBelowThreeStarHidden] = "了不起！",
}

local TitleText2Map = --todo：文案
{
    [ShareLevelSuccessPassType.kFourStar] = "分数爆表，四星过关！",
    [ShareLevelSuccessPassType.kThreeStarNormal] = "技术一流，三星过关！",
    [ShareLevelSuccessPassType.kThreeStarDifficult] = "困难关三星过！无与伦比！",
    [ShareLevelSuccessPassType.kThreeStarExtremeDifficult] = "超难关三星过！无人能敌！",
    [ShareLevelSuccessPassType.kBelowThreeStarNormal] = "小菜一碟，轻松过关！",
    [ShareLevelSuccessPassType.kBelowThreeStarDifficult] = "困难关挑战成功！",
    [ShareLevelSuccessPassType.kBelowThreeStarExtremeDifficult] = "超难关也难不倒我！",
    [ShareLevelSuccessPassType.kThreeStarHidden] = "精英关三星过！超级厉害！",
    [ShareLevelSuccessPassType.kBelowThreeStarHidden] = "我发现了精英关的秘密！",
}

local ShareLevelSuccessLevelType = 
{
    kNormal = 1,
    kDiffcult = 2,
    kExceedinglyDifficult = 3,
    kHidden = 4
}

local ButtonActionType = 
{
    kSave = 1,
    kWeixin = 2,
    kFriendCircle = 3,
    kClose = 4
}

local function getShareLevelSuccessLevelTypeId(levelId)
    local levelType = LevelType:getLevelTypeByLevelId(levelId)
    local levelDifficulty = MetaManager:getLevelDifficultFlag(levelId)
    local rv = nil
    if levelType == GameLevelType.kHiddenLevel then rv = ShareLevelSuccessLevelType.kHidden
    elseif levelDifficulty == LevelDiffcultFlag.kExceedinglyDifficult then rv = ShareLevelSuccessLevelType.kExceedinglyDifficult
    elseif levelDifficulty == LevelDiffcultFlag.kDiffcult then rv = ShareLevelSuccessLevelType.kDiffcult
    elseif levelDifficulty == LevelDiffcultFlag.kNormal then rv = ShareLevelSuccessLevelType.kNormal
    end
    return rv
end

local function getShareLevelPassTypeId(levelTypeId, stars)
    if not levelTypeId then return nil end

    local passTypeId = nil
    if stars == 4 then 
        passTypeId = ShareLevelSuccessPassType.kFourStar
    elseif stars == 3 then
        if levelTypeId == ShareLevelSuccessLevelType.kHidden then 
            passTypeId = ShareLevelSuccessPassType.kThreeStarHidden
        elseif levelTypeId == ShareLevelSuccessLevelType.kExceedinglyDifficult then
            passTypeId = ShareLevelSuccessPassType.kThreeStarExtremeDifficult
        elseif levelTypeId == ShareLevelSuccessLevelType.kDiffcult then
            passTypeId = ShareLevelSuccessPassType.kThreeStarDifficult
        else
            passTypeId = ShareLevelSuccessPassType.kThreeStarNormal
        end
    elseif stars < 3 then
        if levelTypeId == ShareLevelSuccessLevelType.kHidden then 
            passTypeId = ShareLevelSuccessPassType.kBelowThreeStarHidden
        elseif levelTypeId == ShareLevelSuccessLevelType.kExceedinglyDifficult then
            passTypeId = ShareLevelSuccessPassType.kBelowThreeStarExtremeDifficult
        elseif levelTypeId == ShareLevelSuccessLevelType.kDiffcult then
            passTypeId = ShareLevelSuccessPassType.kBelowThreeStarDifficult
        else
            passTypeId = ShareLevelSuccessPassType.kBelowThreeStarNormal
        end
    end
    return passTypeId
end

local function getShareUrl()
    local url
    if PlatformConfig:isQQPlatform() then
        url = NetworkConfig.wxzQQDowanloadURL
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kIOS) or
        PlatformConfig:isPlatform(PlatformNameEnum.kHE) or
        PlatformConfig:isPlatform(PlatformNameEnum.kTF) then
        url = NetworkConfig.wxzHEDowanloadURL
    else
        url = "http://xxl.happyelements.com/?source=ShareLevelSuccessPanel&pf="..StartupConfig:getInstance():getPlatformName()
    end
    return url
end

local function splitChars( text,maxCount,filterFunc )
    local charTab = {}
    local count = 0
    for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do
        if count >= maxCount then
            return charTab,count,true
        end
        if uchar ~= '\n' and uchar ~= '\r' then
            if not filterFunc or filterFunc(uchar) then 
                table.insert(charTab, uchar)
                count = count + 1
            end
        else
            table.insert(charTab, uchar)
        end
    end
    return charTab,count,false
end

local function truncat( str, max )
    local str = '' .. str .. ''
    if #str < 2 then
        str = ' ' .. str .. ' '
        max = max + 1
    end

    local str_table, _, truncated = splitChars(str, max)
    local ret = table.concat(str_table, '')
    if truncated then
        ret = ret .. '...'
    end
    return ret
end

function ShareLevelSuccessPanel:create(levelId, stars, score)
    local levelTypeId = getShareLevelSuccessLevelTypeId(levelId)
    local passTypeId = getShareLevelPassTypeId(levelTypeId, stars)
    if not passTypeId then 
        assert(nil, "ShareLevelSuccessPanel: doesnt support this level!")
        return nil
    end
    local rv = ShareLevelSuccessPanel.new()
    rv:loadRequiredResource("ui/NewShare2019/ShareLevelSuccess.json") --todo, PanelConfigFiles.panel_game_setting
    rv:init(levelId, stars, passTypeId, score)
    return rv
end

function ShareLevelSuccessPanel:init(levelId, stars, passTypeId, score)
    assert(type(levelId)=="number")
    assert(type(stars)=="number")
    assert(passTypeId~=nil)
    assert(score~=nil)

    self.isHiddenLevel = false
    self.levelId = levelId
    self.levelName = tostring(levelId)
    if self.levelId > 10000 then
        self.isHiddenLevel = true
        self.levelName = "+" .. tostring(levelId - 10000)
    end
    self.stars = stars
    self.levelTypeId = getShareLevelSuccessLevelTypeId(levelId)
    self.passTypeId = passTypeId
    self.score = score
    self:initShareData()
    self:initUi()
end

function ShareLevelSuccessPanel:initShareData()
    self.shareUrl = getShareUrl()  --todo
    self.shareTitleName = "" --todo
    self.sharePictureUtil = (require "zoo.panel.share.sharePanelVerB.components.SharePicture").new()
    self.shareType = SnsUtil.getShareType()
end

function ShareLevelSuccessPanel:initUi()
    self.shareUi = self:buildInterfaceGroup("NewShare2019_ShareLevelSuccess/ShareLevelSuccess") 
    self.ui = Layer:create()
    BasePanel.init(self, self.ui, 'ShareLevelSuccessPanel')

    self.ui:addChild(self.shareUi)

    self:initCloseBtn()
    self:initShareBtns()
    self:initDynamicUi()
    self:scaleSelfToVisible()
end

function ShareLevelSuccessPanel:initCloseBtn()
    self.closeBtn = self.shareUi:getChildByName("closeBtn")
    local function onCloseBtnTapped(event)
        self:onCloseBtnTapped(event)
    end
    self.closeBtn:setTouchEnabled(true, 0 ,true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

    self.allowBackKeyTap = false
end

function ShareLevelSuccessPanel:initShareBtns()
    local canShowWeixinBtns = true
    if self.shareType == PlatformShareEnum.kJPQQ or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        canShowWeixinBtns = false
    end
    self.shareBtnPanel = SelectShareWay:create(self.shareUi, not canShowWeixinBtns, not canShowWeixinBtns)
    self.ui:addChild(self.shareBtnPanel.ui)

    local mainUiSize = self.shareUi:getGroupBounds().size

    self.shareBtnPanel.ui:setPositionXY(10, - mainUiSize.height - 100)

    self.shareBtnPanel:setSaveBtnAction(self.onSaveButton)
    self.shareBtnPanel:setWeixinBtnAction(self.onWeixinButton)
    self.shareBtnPanel:setFriendCircleBtnAction(self.onFriendCircleButton)
    self.shareBtnPanel:setSaveBtnCallback(ShareLevelSuccessPanel.onSaveButtonCallback)
    self.shareBtnPanel:setWeixinBtnCallback(ShareLevelSuccessPanel.onWeixinButtonCallback)
    self.shareBtnPanel:setFriendCircleBtnCallback(ShareLevelSuccessPanel.onFriendCircleButtonCallback)
end

function ShareLevelSuccessPanel:initDynamicUi()
    self:initAvatar()
    self:initQr()
    self:initDynamicTexts()
    self:initDynamicVisibles()
end

function ShareLevelSuccessPanel:initAvatar()
    local profile = UserManager.getInstance().profile
    local uid, headUrl
    if profile then
        uid = profile.uid
        headUrl = profile.headUrl
    else
        uid = UserManager.getInstance().user.uid or "00"
        headUrl = tostring((tonumber(uid) or 0) % 11)
    end
    local headHolder = self.shareUi:getChildByName('avatarPlaceHolder')
    local headImageNode = HeadImageLoader:createWithFrame(uid, headUrl)
    if headImageNode then
        headImageNode:setPositionX(headHolder:getContentSize().height/2)
        headImageNode:setPositionY(headHolder:getContentSize().width/2)
        headImageNode:setScaleX(headHolder:getContentSize().width/100)
        headImageNode:setScaleY(headHolder:getContentSize().height/100) 
        headHolder:addChild(headImageNode)
    end
end

function ShareLevelSuccessPanel:initQr()
    local qrHolder = self.shareUi:getChildByName('qrHolder')
    -- local qrHolderWidth = qrHolder:getGroupBounds().size.width
    local qrNode = CocosObject.new(QRManager:generatorQRNode(self.shareUrl, 160, nil, ccc4(0,0,0,255), ccc4(255,255,255,255), ccc4(255,255,255,255) ))
    if qrNode then
        local position = qrHolder:getParent():getNodePosInSelfSpace(qrHolder)
        position.x = position.x + qrHolder:getContentSize().width / 2 + 6
        position.y = position.y - qrHolder:getContentSize().height / 2 - 6
        qrNode:setPosition(position)
        qrNode:setAnchorPoint(ccp(0.5,0.5))
        qrNode:setScale(0.9)
        qrHolder:getParent():addChildAt(qrNode, 2)
        qrHolder:removeFromParentAndCleanup(true)
    end
end

function ShareLevelSuccessPanel:initDynamicTexts()

    --标题文（两行）
    --动态修改文字，由于字符数太多因此缩放，整体的高度会变短
    --需要将高度的腰线移回原处
    local titleTextUi = self.shareUi:getChildByName('titleText')
    local titleText1Ui = titleTextUi:getChildByName('titleText1')
    local titleText2Ui = titleTextUi:getChildByName('titleText2')
    --给一个字符才能测量字块合计的高度
    UIHelper:setLeftText(titleText1Ui,
        "1",
        "fnt/showoff.fnt",
        true,
        true
    )
    UIHelper:setLeftText(titleText2Ui,
        "1",
        "fnt/showoff.fnt",
        true,
        true
    )
    local textHeightBefore = titleTextUi:getGroupBounds().size.height
    local textPositionYBefore = titleTextUi:getPositionY()
    local text1 = Localization:getInstance():getText(TitleText1Map[self.passTypeId])
    local text2 = Localization:getInstance():getText(TitleText2Map[self.passTypeId])
    self.text1 = text1
    self.text2 = text2
    text1 = string.gsub(text1,"{num}",tostring(self.score))
    text2 = string.gsub(text2,"{num}",tostring(self.score))
    UIHelper:setLeftText(titleText1Ui,
        text1,
        nil,
        false,
        true
    )
    UIHelper:setLeftText(titleText2Ui,
        text2,
        nil,
        false,
        true
    )
    local textHeightAfter = titleTextUi:getGroupBounds().size.height
    local textHeightDiff = textHeightBefore - textHeightAfter
    titleTextUi:setPositionY(textPositionYBefore - textHeightDiff / 2)

    --关卡编号
    if #self.levelName >= 3 then
        local levelText = self.shareUi:getChildByName('levelText1000')
        levelText:setAlignment(kCCTextAlignmentCenter)
        UIHelper:setCenterText(levelText,
            self.levelName,
            "fnt/showoff2.fnt",
            false,
            true
        )
        local levelTextPosition = levelText:getPosition()
        levelText:setPositionXY(levelTextPosition.x+10,levelTextPosition.y+10)
    else
        local levelText = self.shareUi:getChildByName('levelText10')
        levelText:setAlignment(kCCTextAlignmentCenter)
        UIHelper:setCenterText(levelText,
            self.levelName,
            "fnt/showoff3.fnt",
            false,
            true
        )
        if #self.levelName >= 2 then
            local levelTextPosition = levelText:getPosition()
            levelText:setPositionXY(levelTextPosition.x + 3,levelTextPosition.y + 8)
        else
            local levelTextPosition = levelText:getPosition()
            levelText:setPositionXY(levelTextPosition.x + 6,levelTextPosition.y + 6)
            local guanText  = self.shareUi:getChildByName('guan10')
            local guanTextPosition = guanText:getPosition()
            guanText:setPositionXY(guanTextPosition.x - 2,guanTextPosition.y + 2)
        end
    end

    --玩家名
    local userNameUI = self.shareUi:getChildByName("playerName")
    local userName = truncat(nameDecode(UserManager:getInstance().profile.name or ""), 5)
    local cropped = TextUtil:ensureTextWidth(userName, userNameUI:getFontSize(), userNameUI:getDimensions())
	if cropped then 
		userNameUI:setString(cropped) 
	else
		userNameUI:setString(userName)
    end
    local userNamePosition = userNameUI:getPosition()
    userNameUI:setHorizontalAlignment(kCCTextAlignmentCenter)
    userNameUI:setPositionXY(userNamePosition.x + 7, userNamePosition.y - 27)

    --长按识别
    local guideText = self.shareUi:getChildByName("qrAppendageTitle")
    guideText:setString("长按识别>>")

end

function ShareLevelSuccessPanel:initDynamicVisibles()
    if #self.levelName >= 3 then
        self.shareUi:getChildByName('levelText10'):setVisible(false)
        self.shareUi:getChildByName('guan10'):setVisible(false)
    else
        self.shareUi:getChildByName('levelText1000'):setVisible(false)
        self.shareUi:getChildByName('guan1000'):setVisible(false)
    end
    for i=1,4 do
        local starLayer = self.shareUi:getChildByName(tostring(i)..'star')
        if starLayer then
            starLayer:setVisible(i==self.stars)
        end
    end
end

function ShareLevelSuccessPanel:scaleSelfToVisible()
    self.ui:setScale(1)
    local vs = Director:sharedDirector():getVisibleSize()
    local ss = self.ui:getGroupBounds().size
    local safeMargin = 50
    local scale = math.min(1, vs.width/(ss.width + safeMargin) , vs.height/(ss.height + safeMargin) )
    self.ui:setScale(scale)
end

function ShareLevelSuccessPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false, nil, nil, 200)
end

function ShareLevelSuccessPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function ShareLevelSuccessPanel:createShowAnim()
    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX = centerPosX
        local initPosY = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut = CCEaseQuarticBackOut :create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished()
        self:onEnterAnimationFinished()
    end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function ShareLevelSuccessPanel:onCloseBtnTapped(event, ...)
    if self.isDisposed then return end
    DcUtil:UserTrack({
		category = "show", 
		sub_category = "show_off_share", 
        t1 = self.levelId,
        t2 = self.stars,
        t3 = self.levelTypeId,
        t4 = ButtonActionType.kClose
    })
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
end

function ShareLevelSuccessPanel:onEnterAnimationFinished()
end

function ShareLevelSuccessPanel:onSaveButton()
    if self.isDisposed then return true end
    DcUtil:UserTrack({
		category = "show", 
		sub_category = "show_off_share", 
        t1 = self.levelId,
        t2 = self.stars,
        t3 = self.levelTypeId,
        t4 = ButtonActionType.kSave
    })
    return nil
end

ShareLevelSuccessPanel.onSaveButtonCallback =
{
    onSuccess = function (path)
        local str = path
        if __IOS then
            str = "图像成功保存到相册"
        else
            do
                local seperator = package.config:sub(1,1)
                local splits = string.split(str, seperator)
                str = string.format("图像已保存至%s%s%s%s%s", splits[#splits - 2], seperator, splits[#splits - 1], seperator, splits[#splits])
            end
        end
        CommonTip:showTip(str, 'positive')
    end,
    onError = function (code, msg)
        if code == -10 then
            local str = "此操作需要获取相册权限,打开设置->隐私->照片->开心消消乐->允许读取和写入即可。快点去设置吧~"  --todo 文案
            CommonTip:showTip(str, "positive")
        else
            CommonTip:showTip('保存到相册失败！')
            RemoteDebug:uploadLogWithTag('ShareLevelSuccessPanel.lua: 保存到相册失败, code:'..tostring(code)..", msg:"..msg)
        end
    end,
    onCancel = function ()
        CommonTip:showTip('取消了……')
    end
}

function ShareLevelSuccessPanel:onWeixinButton()
    if self.isDisposed then return true end
    if not SnsProxy:isWXAppInstalled() then
        setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
        return true
    end

    DcUtil:UserTrack({
		category = "show", 
		sub_category = "show_off_share", 
        t1 = self.levelId,
        t2 = self.stars,
        t3 = self.levelTypeId,
        t4 = ButtonActionType.kWeixin
    })

    return nil
end

ShareLevelSuccessPanel.onWeixinButtonCallback = {
    onSuccess = function(result)
        ShareLevelSuccessPanel.onShareSucceed()
    end,
    onError = function(errCode, errMsg)
        ShareLevelSuccessPanel.onShareFailed()
    end,
    onCancel = function()
        ShareLevelSuccessPanel.onShareFailed()
    end,
}

function ShareLevelSuccessPanel:onFriendCircleButton()
    if self.isDisposed then return true end
    if not SnsProxy:isWXAppInstalled() then
        setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
        return true
    end

    DcUtil:UserTrack({
		category = "show", 
		sub_category = "show_off_share", 
        t1 = self.levelId,
        t2 = self.stars,
        t3 = self.levelTypeId,
        t4 = ButtonActionType.kFriendCircle
    })

    return nil
end

ShareLevelSuccessPanel.onFriendCircleButtonCallback = ShareLevelSuccessPanel.onWeixinButtonCallback

ShareLevelSuccessPanel.onShareSucceed = function ()
    CommonTip:showTip("分享成功~", "positive")
end

ShareLevelSuccessPanel.onShareFailed = function ()
    CommonTip:showTip("分享失败...", "negative")
end