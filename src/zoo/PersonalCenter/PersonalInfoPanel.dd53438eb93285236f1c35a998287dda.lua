require 'zoo.account.AccountBindingLogic'
local PrivateStrategy = require 'zoo.data.PrivateStrategy'
local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'
local BottomInfo = require 'zoo.PersonalCenter.PersonalBottomInfo'
local SelectShareWayPanel_Copy = require "zoo.panel.seasonWeekly.SelectShareWayPanel_Copy"

local function move( ui, dx, dy )
    if not ui then return end
    if ui.isDisposed then return end

    ui:setPositionX(ui:getPositionX() + (dx or 0))
    ui:setPositionY(ui:getPositionY() + (dy or 0))
end



-- local function positionNode( holder, icon, isUniformScale)
--     if (not holder) or holder.isDisposed then return end
--     if (not icon) or icon.isDisposed then return end
--     if holder.____icon then
--     	holder.____icon:removeFromParentAndCleanup(true)
--     	holder.____icon = nil
--     end
--     holder.____icon = icon
--     local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
--     local parent = holder:getParent()
--     if (not parent) or parent.isDisposed then return end
--     local iconIndex = parent:getChildIndex(holder)
--     parent:addChildAt(icon, iconIndex)
--     local size = holder:getContentSize()
--     local sx, sy = holder:getScaleX(), holder:getScaleY()
--     local realSize = {
--         width = sx * size.width,
--         height = sy * size.height,
--     }
--     layoutUtils.scaleNodeToSize(icon, realSize, parent, isUniformScale)
--     layoutUtils.verticalCenterAlignNodes({icon}, holder, parent)
--     layoutUtils.horizontalCenterAlignNodes({icon}, holder, parent)
--     holder:setVisible(false)
-- end


local PersonalInfoPanel = class(BasePanel)

function PersonalInfoPanel:create(showGuide)
    local panel = PersonalInfoPanel.new()
    panel:loadRequiredResource("ui/personal_center_panel.json")
    panel:init(showGuide)

    if _G.isLocalDevelopMode then
    end

    return panel
end

function PersonalInfoPanel:init(showGuide)
    self.showGuide = showGuide
    local ui 
    if WXJPPackageUtil.getInstance():isWXJPPackage() then
    	ui = self:buildInterfaceGroup("person_info_wx")
    else
    	ui = self:buildInterfaceGroup("person_info")
    end
	BasePanel.init(self, ui)
    self.bottomInfo = BottomInfo:create(ui:getChildByPath("bottomInfo"))
    self.bottomInfo:onPersonalInfoChange()
    self.closeBtn = self.ui:getChildByPath('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
    self.ui:getChildByPath('info/l1'):setString(localize('my.card.content1'))
    if not (WXJPPackageUtil.getInstance():isWXJPPackage()) then
    	self.ui:getChildByPath('info/l2'):setString(localize('my.card.content2'))
    end
    for _, v in ipairs({
    	self.ui:getChildByPath('info/l1'),
    	self.ui:getChildByPath('info/l2'),
    	self.ui:getChildByPath('info/l3'),
    	self.ui:getChildByPath('info/l4'),
    }) do
        if __IOS then
    	   move(v, 0, -4)
        else
           move(v, 0, -1)
        end
    end
    self.head = self.ui:getChildByPath("head")

    self.headBtn = self.ui:getChildByPath("head/btn")
    self.headBtn = GroupButtonBase:create( self.headBtn )
    self.headBtn:setString("点击更换")
    self.headBtn.groupNode:setTouchEnabled(false, 0, true)
    
    self:buildInviteCode()
    self:buildAccounts()
    self:buildEditBtn()
    self:buildStarRankFlag()
    self:onPersonalInfoChange()
    if self.showGuide then
        local UIHelper = require 'zoo.panel.UIHelper'
        local guideDialog = UIHelper:createUI("ui/xf_share.json", "xf_share_panel/guide")
        self:addChildAt(guideDialog, 0)
        guideDialog:setPosition(ccp(0, 190))
        self.guideDialog = guideDialog
    end
    self.__enterBackListener = function ( ... )
        if self.isDisposed then return end
        self.avatarSelectGroup:closeNativePhotoView()
    end
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterBackground, self.__enterBackListener)
end

function PersonalInfoPanel:buildStarRankFlag( ... )
    if self.isDisposed then return end
    
    local starGlobalRank = PersonalCenterManager:getData(PersonalCenterManager.STAR_GLOBAL_RANK)
    local pctRank = PersonalCenterManager:getData(PersonalCenterManager.PERCENT_RANK)

    local starNum = PersonalCenterManager:getData(PersonalCenterManager.STAR) 

    local flag = self.ui:getChildByPath('flag')
    local l1 = flag:getChildByPath('l1')
    local l2 = flag:getChildByPath('l2')

    l1:changeFntFile('fnt/profilestar.fnt')
    l2:changeFntFile('fnt/profilestar.fnt')

    l1:setScale(1.1)
    l2:setScale(1.1)

    move(l1, -8, -3)
    move(l2, -8, -3)

    l2:setText('总星级')

    local function update( ... )
        if self.isDisposed then return end

        if starNum == 0 or (not kUserLogin) then
            flag:setVisible(false)
        else
            if starGlobalRank and starGlobalRank == 1 then
                pctRank = 10000
            end

            if pctRank >= 10000 then
                pctRank = 9999
            end

            if pctRank and 100 - pctRank / 100 <= 99 then
                l1:setText(string.format("全国前%.2f%%", 100 - pctRank / 100))
            else
                l1:setText('   暂未上榜')
            end
        end

    end

    update()
    PersonalCenterManager:reigsterDataEvent(PersonalCenterManager.PERCENT_RANK, function( value )
        pctRank = value
        update()
    end)
    PersonalCenterManager:reigsterDataEvent(PersonalCenterManager.STAR_GLOBAL_RANK,function( value )
        starGlobalRank = value
        update()
    end)

    self.flag = flag

    -- self.ui:getChildByPath('flag_bg_1'):setVisible(false)
    -- self.ui:getChildByPath('flag_label'):setVisible(false)
    -- self.ui:getChildByPath('flag_bg_2'):setVisible(false)

end

function PersonalInfoPanel:buildEditBtn( ... )
	if self.isDisposed then return end

	self.editBtnUI = self.ui:getChildByPath('edit_btn')
    self.editBtn = GroupButtonBase:create( self.editBtnUI )
    self.editBtn:setString("编辑")
	-- self.editBtn:setTouchEnabled(true)

    local onClickEditBtn = preventContinuousClick(function ( ... )
        if self.isDisposed then return end

        local function finishCallback()
            if self.isDisposed then return end
            local isClick = true
            local panel = require('zoo.PersonalCenter.EditInfoPanel'):create( isClick )
            panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
                if self.isDisposed then return end
                self:onPersonalInfoChange()         
            end)
            panel.onProfileUpdated = function ( ... )
                PersonalCenterManager:uploadUserProfile(true)
            end
            panel.parentPanel = self
            panel:popout()
            self.editPanel = panel
        end
        -- 为什么是Alert_Location呢，因为已经这样写了
        PrivateStrategy:sharedInstance():Alert_Location( finishCallback )

        DcUtil:UserTrack({category='my_card', sub_category="my_card_click_edit_profile"}, true)
    end)

	self.editBtn:ad(DisplayEvents.kTouchTap, onClickEditBtn)

    self.onTapEditBtn = function ( ... )
        if self.isDisposed then return end
        if onClickEditBtn then onClickEditBtn() end
    end


	-- local RewardTip = require 'zoo.scenes.component.HomeScene.RewardTip'
 --    local rewardTip = nil
 --    rewardTip = RewardTip:create(ResourceManager:sharedInstance():buildGroup("timer.peron.reward/timer"))
 --    rewardTip:setPositionX(230)
 --    rewardTip:setPositionY(80)
 --    rewardTip:setScale(2.0)
 --    self.editBtn.rewardTip = rewardTip
 --    self.editBtn.background:addChild(rewardTip)

 --    rewardTip.onStatusChange = function ( ... )
	-- 	if self.isDisposed then return end

	-- 	if PersonalInfoReward:isInRewardTime() then
 --            rewardTip:setData(PersonalInfoReward:getReward(), PersonalInfoReward:getEndTimeInSec())
 --        end
 --        rewardTip:setVisible(PersonalInfoReward:isInRewardTime())

	-- 	self:refreshEditBtn()
 --    end
 --    rewardTip:setVisible(false)
 --    PersonalInfoReward:getInfoAsync(rewardTip.onStatusChange)


    local bg3 = self.ui:getChildByPath('info/bg3')
    local bg4 = self.ui:getChildByPath('info/bg4')

    if bg3 then
        UIUtils:setTouchHandler(bg3, function ( ... )
            if self.isDisposed then return end
            bg3:runAction(CCCallFunc:create(function ( ... )
                if self.onTapEditBtn then
                    self.onTapEditBtn()
                end
            end))
        end)
    end

    if bg4 then
        UIUtils:setTouchHandler(bg4, function ( ... )
            
            if self.isDisposed then return end
            bg4:runAction(CCCallFunc:create(function ( ... )
                if self.onTapEditBtn then
                    self.onTapEditBtn()
                end
            end))

        end)
    end

	self:refreshEditBtn()
end

function PersonalInfoPanel:refreshEditBtn( ... )
	if self.isDisposed then return end

    local rewardTipVisible = false
    -- local rewardTipVisible = PersonalInfoReward:isInRewardTime()
    local dotVisible = not PersonalCenterManager:isInfoComplete()

	self.editBtn.groupNode:getChildByPath('dot'):setVisible(dotVisible and  (not rewardTipVisible))
    -- self.editBtn.rewardTip:setVisible(rewardTipVisible)

end

function PersonalInfoPanel:dispose( ... )
    GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterBackground, self.__enterBackListener)
    BasePanel.dispose(self, ...)
end

function PersonalInfoPanel:isWxShare(eType)
    if eType == PlatformShareEnum.kWechat or
        eType == PlatformShareEnum.kSYS_WECHAT then
            return true
        end
    return false
end

function PersonalInfoPanel:wxInstallAlter(eType)
    if self:isWxShare(eType) and not SnsProxy:isWXAppInstalled() then
        return true
    end
    return false
end

function PersonalInfoPanel:doShare( message , successCallback, failCallback, cancelCallback  )

    if self.shareType == PlatformShareEnum.kWechat then
        if OpenUrlUtil:canOpenUrl("weixin://") then
            if successCallback then successCallback() end
            setTimeOut(function ( ... ) OpenUrlUtil:openUrl("weixin://")end, 0.5)
        else
            if failCallback then failCallback() end
            -- setTimeOut(function ( ... ) CommonTip:showTip('请安装微信后再分享~', 'negative') end, 0.001)
            CommonTip:showTip('请安装微信后再分享~', 'negative')
        end
    elseif self.shareType == PlatformShareEnum.kQQ then
       if OpenUrlUtil:canOpenUrl("mqqapi://") then
            -- if successCallback then successCallback() end
            local shareType = PlatformShareEnum.kSYS_QQ
            if __ANDROID then 
                AndroidShare.getInstance():registerShare(shareType)
                SnsUtil.sendTextMessage( shareType, "", message, false )
            else
                if successCallback then successCallback() end
                setTimeOut(function ( ... ) OpenUrlUtil:openUrl("mqqapi://")end, 0.5)
            end
            
        else

            if failCallback then failCallback() end
            CommonTip:showTip('请安装QQ后再分享~', 'negative')
            -- setTimeOut(function ( ... ) CommonTip:showTip('请安装QQ后再分享~', 'negative') end, 0.001)
        end


    end

end


function PersonalInfoPanel:sendHttpOrder(successCallback, failCallback)
    if successCallback then successCallback() end
end
function PersonalInfoPanel:getShortUrl(url, onSuccess)



    local http = OpNotifyHttp.new(true)
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
        if onSuccess then onSuccess(url) end
    end)
    http:ad(Events.kCancel, function ( ... )
        if onSuccess then onSuccess(url) end
    end)
    http:load(OpNotifyType.kGetShortUrl, url)




end
function PersonalInfoPanel:buildInviteCode( ... )
	if self.isDisposed then return end
	
    local myInviteCode = PersonalCenterManager:getData(PersonalCenterManager.INVITE_CODE)

	local idLabelNum = self.ui:getChildByPath("info/inviteCode")
	idLabelNum:setAnchorPoint(ccp(0.5, 0.5))
    idLabelNum:setScale(1.2)
	idLabelNum:setText(myInviteCode)

	idLabelNum:setPositionY(-145)
	idLabelNum:setPositionX(300)


	local function update5()
        if self.isDisposed then return end
        local text = idLabelNum
        if not text or text.isDisposed then return end
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1, 1.55))
        arr:addObject(CCScaleTo:create(0.1, 1.05))
        arr:addObject(CCScaleTo:create(0.1, 1.3))
        arr:addObject(CCScaleTo:create(0.1, 1.2))
        text:runAction(CCSequence:create(arr))
    end
    self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update5, 5, false)

    self.copyBtn = self.ui:getChildByPath("info/copy")
    self.copyBtn = GroupButtonBase:create( self.copyBtn )
    -- self.copyBtn:setColorMode(kGroupButtonColorMode.orange)
    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        self.copyBtn:setString(localize("复制"))
    else
        self.copyBtn:setString(localize("复制并分享"))
    end
    
    -- self.copyBtn:addEventListener(DisplayEvents.kTouchTap, function ()
    --     if self.isDisposed then return end
    -- end)
    if WXJPPackageUtil.getInstance():isWXJPPackage()  then
        self.copyBtn:setVisible(false)
    else
        self.copyBtn:setVisible(true)
    end
        
    self.message = nil 
    if (not PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) ) and (myInviteCode ~= nil and #myInviteCode >= 9 and #myInviteCode <= 11 and tonumber(myInviteCode) ~= nil) then
        
        local dcData = {}
        dcData.category = "AddFriend"
        dcData.sub_category = "addfriend_click_share"
        DcUtil:log(AcType.kUserTrack, dcData, true)

        -- self.copyBtn:setTouchEnabled(true)
        self.copyBtn:addEventListener(DisplayEvents.kTouchTap, 	preventContinuousClick(function (event)
            if self.isDisposed then return end
            --复制消消乐号成功
            local preStr = localize("addfriend_copy_sms_pre")
            local tagStr = localize("addfriend_copy_sms_tag")
            local string1 = preStr .. myInviteCode .. tagStr       
            local uid = UserManager:getInstance().user.uid or '12345'
            local function getLinkURL( successCallback )
                if self.isDisposed then return end

                local inviteCode = UserManager.getInstance().inviteCode or ""
                local areaInfo ,numOfFullStar= UserManager:getInstance():getAreaStarInfo()

                -- local url = "happyanimal3://add_friend/redirect"
                local link = NetworkConfig.dynamicHost..'name_card.jsp?'
                link = link ..'&fullStarArea='..numOfFullStar..'&invitecode='..inviteCode.."&aaf=10".."&uid="..uid.."&pid="..PlatformConfig.name
                if _G.isLocalDevelopMode  then printx(103 , " link = " ..link ) end
                self:getShortUrl( link , successCallback )
                -- return link
            end 
            local function copyFinish( ... )
                if self.isDisposed then return end
                --我的消消乐号复制到剪切板
                ClipBoardUtil.copyText( self.message )
                CommonTip:showTip(localize("addfriend_auto_add_copy_sucess"), "positive")
            end 
            local function getStringIncludeURL( successCallback )
                if self.isDisposed then return end
                local function getURLSuccess( link )
                    if self.isDisposed then return end
                    
                    local string2 = string1 .. localize("addfriend_copy_sms_tag2") ..link .. localize("addfriend_copy_sms_tag3")
                    if _G.isLocalDevelopMode  then printx(103 , " string2 = " ..string2 ) end
                    self.message = string2
                    if successCallback then successCallback( string2 ) end
                end 
                getLinkURL( getURLSuccess )
            end 


            local sharePanel =  SelectShareWayPanel_Copy:create()
            self.sharePanel = sharePanel
             local function shareSuccess(  )
                if self.isDisposed then return end
                copyFinish()
                sharePanel:onCloseBtnTapped()
            end 

            local function shareFail(  )
                if self.isDisposed then return end
            end
            local function shareCancel(  )
                if self.isDisposed then return end                    
            end
            sharePanel:popout(function ( ... )
                if self.isDisposed then return end
                --仅复制
                self.shareType = nil
                getStringIncludeURL( function (string2) 
                    copyFinish()
                end)
                
                -- sharePanel:onCloseBtnTapped()
            end, function ( ... )
                if self.isDisposed then return end
                --微信
                self.shareType = PlatformShareEnum.kWechat
                
                getStringIncludeURL( function (string2) 
                    self:doShare( string2 , shareSuccess , shareFail , shareCancel )
                    sharePanel:onCloseBtnTapped()
                end)
            end,function ( ... )
                if self.isDisposed then return end
                --QQ
                self.shareType = PlatformShareEnum.kQQ

                getStringIncludeURL( function (string2) 
                    self:doShare( string2 , shareSuccess , shareFail , shareCancel )
                    sharePanel:onCloseBtnTapped()
                end)


                
            end)



        end))
    else
        self.copyBtn:addEventListener(DisplayEvents.kTouchTap,  preventContinuousClick(function (event)

            local dcData = {}
            dcData.category = "AddFriend"
            dcData.sub_category = "addfriend_click_share"
            DcUtil:log(AcType.kUserTrack, dcData, true)

            local preStr = localize("addfriend_copy_sms_pre")
            local tagStr = localize("addfriend_copy_sms_tag")
            local string1 = preStr .. myInviteCode .. tagStr       
            local uid = UserManager:getInstance().user.uid or '12345'

            local function copyFinish( ... )
                if self.isDisposed then return end
                --我的消消乐号复制到剪切板
                printx(103,"self.message = ",self.message )
                ClipBoardUtil.copyText( self.message )
                CommonTip:showTip(localize("addfriend_auto_add_copy_sucess"), "positive")
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "copyID"
                dcData.t1 = 1
                DcUtil:log(AcType.kUserTrack, dcData, true)
            end 
            local function getLinkURL( successCallback )
                if self.isDisposed then return end

                local inviteCode = UserManager.getInstance().inviteCode or ""
                local areaInfo ,numOfFullStar= UserManager:getInstance():getAreaStarInfo()

                -- local url = "happyanimal3://add_friend/redirect"
                local link = NetworkConfig.dynamicHost..'name_card.jsp?'
                link = link ..'&fullStarArea='..numOfFullStar..'&invitecode='..inviteCode.."&aaf=10".."&uid="..uid.."&pid="..PlatformConfig.name
                if _G.isLocalDevelopMode  then printx(103 , " link = " ..link ) end
                self:getShortUrl( link , successCallback )
                -- return link
            end 

            local function getStringIncludeURL( successCallback )
                if self.isDisposed then return end
                local function getURLSuccess( link )
                    if self.isDisposed then return end
                    
                    local string2 = string1 .. localize("addfriend_copy_sms_tag2") ..link .. localize("addfriend_copy_sms_tag3")
                    if _G.isLocalDevelopMode  then printx(103 , " string2 = " ..string2 ) end
                    self.message = string2
                    if successCallback then successCallback( string2 ) end
                end 
                getLinkURL( getURLSuccess )
            end 

            getStringIncludeURL( function (string2) 
                copyFinish()
            end)

        end))

    end












    local function changePlayer( headUrl )
    	-- body
        if tostring(PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)) ~= tostring(headUrl) then
            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=1}, true)
            PersonalCenterManager:setData(PersonalCenterManager.HEAD_URL, tostring(headUrl))
            local isCustomHeadUrl = (tonumber(headUrl) == nil)
            PersonalCenterManager:uploadUserProfile(isCustomHeadUrl)
        end
    end

    local AvatarSelectGroup = require "zoo.PersonalCenter.AvatarSelectGroup"
    self.avatarSelectGroup = AvatarSelectGroup:buildGroup( PersonalCenterManager, 
                                self.ui:getChildByPath("moreAvatars"),
                                self.ui:getChildByPath("head"),
                                self.ui:getChildByPath("name"),
                                changePlayer, function ( groupName )
                                    self:loadRequiredResource("ui/personal_center_panel.json")
                                    return self:buildInterfaceGroup(groupName)
                                end)
   	self.avatarSelectGroup.parent = self
    --打点用
    self.avatarSelectGroup.originalPlace = 0

    self.avatarSelectGroup.beginEditCallback = function ( ... )
        if self.isDisposed then return end
    end

    self.avatarSelectGroup.endEditCallback = function ( ... )
        if self.isDisposed then return end
    end

    local name = self.ui:getChildByPath("name"):getChildByPath("label")
    self.nameLabel = name

    self:refreshNameHead()

end


function PersonalInfoPanel:onPersonalInfoChange( ... )
	if self.isDisposed then return end
	
	--性别 年龄 星座
    self:refreshSexAgeXZ()

    --address
    self:refeshAddress()

    --勋章 成就
    -- self:refreshAchi()

    --星星 关卡 etc
    -- self:refreshLevelStars()

    self.bottomInfo:onPersonalInfoChange()


    --姓名 头像 
    self:refreshNameHead()

    self:refreshEditBtn()
end

function PersonalInfoPanel:refreshNameHead( ... )
	if self.isDisposed then return end

	local headUrl = PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)
    self.avatarSelectGroup:changeAvatarImage(headUrl)

    local nameText = nameDecode(PersonalCenterManager:getData(PersonalCenterManager.NAME))
    if self.nameLabel:isVisible() then
        self.nameLabel:setString(nameText .." ")
    elseif self.avatarSelectGroup.input then
        self.avatarSelectGroup.input:setText(nameText)
    end
end

function PersonalInfoPanel:refreshSexAgeXZ( ... )
	-- body
	if self.isDisposed then return end

    local birth = PersonalCenterManager:getData(PersonalCenterManager.BIRTHDATE)


	local age = PersonalCenterManager:getData(PersonalCenterManager.AGE)
    local cons = PersonalCenterManager:getData(PersonalCenterManager.CONSTELLATION)
    local sex = PersonalCenterManager:getData(PersonalCenterManager.SEX)
    local ageText = ''
    local genderText = ''
    local constellationText = ''
    if tonumber(age) >= 100 then
        age = "99+"
    end
    ageText = age .."岁".." "
    if age == 0 and ((not birth) or (birth == '')) then
        ageText = ''
    end

    local genderTextGroup = {'', localize('my.card.edit.panel.content.male'), localize('my.card.edit.panel.content.female')}
    genderText = genderTextGroup[sex + 1]..' '
    if cons > 0 then
        constellationText = localize('my.card.edit.panel.content.constellation'..cons)
    end
    local labelACGText = genderText .. ageText .. constellationText


	if string.gsub(labelACGText, ' ', '') == '' then
		labelACGText = localize('my.card.content9')
	end    

    self.ui:getChildByPath('info/l3'):setString(labelACGText)
end

function PersonalInfoPanel:refeshAddress( ... )
	if self.isDisposed then return end

    local label = self.ui:getChildByPath('info/l4')

	local address = PersonalCenterManager:getData(PersonalCenterManager.ADDRESS)
	if address == '' then
		address = '未知地区'
	end

    address = string.gsub(address, '#', ' ')

    address = TextUtil:ensureTextWidth(address, label:getFontSize(), label:getDimensions() )

	label:setString(address)
end

function PersonalInfoPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function PersonalInfoPanel:popoutAndEditHeadFram( closeCallBack )
    self:popout()
    
    if self.avatarSelectGroup and self.avatarSelectGroup.onAvatarTouch then
        self.avatarSelectGroup:onAvatarTouch()
    end
    self.closeCallBack = closeCallBack
end

function PersonalInfoPanel:popout()
    self:scaleAccordingToResolutionConfig()

    if self.guideDialog then
        local size1 = self:getGroupBounds().size
        local vs = Director:sharedDirector():getVisibleSize()
        self:setScale(math.min(self:getScaleX(), self:getScaleX() * vs.height / (size1.height * (960 + 190) / 960)))
        self.guideDialog:setTag(HeDisplayUtil.kIgnoreGroupBounds)
    end

    self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self, true)

	self.allowBackKeyTap = true
    self:popoutShowTransition()

end

function PersonalInfoPanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	local PersonalInfoGuide = require "zoo.PersonalCenter.PersonalInfoGuide"
    local NewHeadFrameGuide = require "zoo.PersonalCenter.NewHeadFrameGuide"
	if PersonalInfoGuide.shouldShowGuideTwo then
		PersonalInfoGuide.panel = self
		PersonalInfoGuide:popGuideTwo()
    elseif NewHeadFrameGuide.shouldShowGuideTwo then
        NewHeadFrameGuide.panel = self
        NewHeadFrameGuide:popGuideTwo()
	end
end

local PlatformAccountIcons = {
    [PlatformAuthEnum.kQQ]    = "qq",
    [PlatformAuthEnum.kPhone] = "phone",
    [PlatformAuthEnum.kWeibo] = "weibo",
    [PlatformAuthEnum.k360]   = "360",
    [PlatformAuthEnum.kWDJ]   = "wdj",
    [PlatformAuthEnum.kMI]    = "mi",
    [PlatformAuthEnum.kWechat]= "wechat",
}


function PersonalInfoPanel:buildAccounts( ... )

    if self.isDisposed then return end

    if  WXJPPackageUtil.getInstance():isWXJPPackage() then
    	return
    end



    self:loadRequiredResource("ui/personal_center_panel.json")

    local readOnlyAuthConfigs = PlatformConfig:getAuthConfigs()
    local authConfigs = {}


    for _, v in ipairs(readOnlyAuthConfigs) do
    	table.insert(authConfigs, v)
    end

    table.sort(authConfigs, function ( a, b )
    	return PlatformAuthPriority[a] < PlatformAuthPriority[b]
    end)

    local icons = {}
    local iconsForLayout = {}

    local layer = Layer:create()

    local profile = UserManager:getInstance().profile

    local function skip( authType )
    	if PlatformAuthEnum.kQQ == authType or PlatformAuthEnum.kWeibo == authType then
    		if not profile:isBound(authType) then
    			return true
    		end
    	end
    	return false
    end

    local function updateBubleEdit( ... )
    	if self.isDisposed then return end
    	self:onAccountInfoChanage()
    end

    for _, v in ipairs(authConfigs) do


    	if PlatformAccountIcons[v] and (not skip(v)) then
    		local icon = self:buildInterfaceGroup('person.info/personal_center_account_btn_new')
    		for _, vv in ipairs(icon:getChildByPath('sprite'):getChildrenList()) do
    			vv:setVisible(PlatformAccountIcons[v] == vv.name)
    		end
    		table.insert(icons, icon)
    		table.insert(iconsForLayout, {node = icon, margin = {right = 26}})
    		layer:addChild(icon)

    		icon.authType = v

    		icon:setTouchEnabled(true)

            local onClickEidtPhone = preventContinuousClick(function ( ... )
                if self.isDisposed then return end
                DcUtil:UserTrack({category='my_card', sub_category="my_card_click_setting"}, true)
                if profile:isBound(icon.authType) then
                    local panel = AccountSettingPanel:create()
                    panel.bindCallBack = updateBubleEdit 
                    panel:popout()
                else
                    local panel = AccountSettingPanel:create()
                    local rewardId = panel.rewardId
                    local hasReward = panel:hasRewardTip(icon.authType)
                    panel:dispose()
                    if icon.authType == PlatformAuthEnum.kPhone then

                        local function privateStrategy_Alert_Phone(  )
                            ----SVIP 绑定手机活动 不弹旧手机绑定ICON
                            local bGoToSvipPanel = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()

                            ----
                            if bGoToSvipPanel then
                                SVIPGetPhoneManager:getInstance():openActivity()
                             else
                                local function onReturnCallback()
                                end
                                local function onSuccess()
                                    if BindPhoneBonus:shouldGetReward() then 
                                        BindPhoneBonus:receiveReward(false, rewardId) 
                                    end
                                    updateBubleEdit()
                                end
                                AccountBindingLogic:bindNewPhone(onReturnCallback, onSuccess, AccountBindingSource.ACCOUNT_SETTING)
                            end
                        end

                        PrivateStrategy:sharedInstance():Alert_Phone( privateStrategy_Alert_Phone )

                    else
                        local function callback()
                            updateBubleEdit()
                        end
                        local function onConnectFinish()
                            if icon.authType == PlatformAuthEnum.kQQ and BindQQBonus:shouldGetReward() then 
                                BindQQBonus:receiveReward(false, self.rewardId) 
                            end

                            if icon.authType == PlatformAuthEnum.k360 and BindQihooBonus:shouldGetReward() then 
                                BindQihooBonus:receiveReward(false, self.rewardId) 
                            end
                            callback()
                        end
                        local function onConnectError()
                            callback()
                        end
                        local function onConnectCancel()
                            callback()
                        end
                        AccountBindingLogic:bindNewSns(icon.authType, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.ACCOUNT_SETTING, hasReward)
                    end
                end
            end)


    		icon:ad(DisplayEvents.kTouchTap,  onClickEidtPhone )

            



    	end
    end

    local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.horizontalLayoutItems(iconsForLayout)

    self.ui:getChildByPath('info'):addChild(layer)

    local l2 = self.ui:getChildByPath('info/l2')

    layer:setPosition(ccp(137, -223))

    self.icons = icons

    self:onAccountInfoChanage()
end

function PersonalInfoPanel:onAccountInfoChanage( ... )
	-- body
	if self.isDisposed then return end


    local profile = UserManager:getInstance().profile

	for _, v in ipairs(self.icons or {}) do
		v:getChildByPath('resDot'):setVisible(not profile:isBound(v.authType) )
	end

    local rcmdAccountType = AccountBindingLogic:getRcmdAccountType()
    local isShowRewardTip = BindQQBonus:loginRewardEnabled() or BindPhoneBonus:loginRewardEnabled() or BindQihooBonus:loginRewardEnabled()

    if _G.sns_token then
        isShowRewardTip = false
    end

    for _, icon in pairs(self.icons or {}) do
        local authType = icon.authType
        if authType == rcmdAccountType then
            if isShowRewardTip then
                local itemID, num, rewardId = PushBindingLogic:getPushBindAward(authType)
                if itemID == nil then
                    if rcmdAccountType == PlatformAuthEnum.kQQ then
                        itemID, num, rewardId = BindQQBonus:getBindRewards()
                    elseif rcmdAccountType == PlatformAuthEnum.kPhone then
                        itemID, num, rewardId = BindPhoneBonus:getBindRewards()
                    elseif rcmdAccountType == PlatformAuthEnum.k360 then
                        itemID, num, rewardId = BindQihooBonus:getBindRewards()
                    end
                end
                if itemID ~= nil then 
                    icon:getChildByPath('resDot'):setVisible(false)
                    UIUtils:positionNode(
                        icon:getChildByPath('tip/icon/holder'), 
                        ResourceManager:sharedInstance():buildItemSprite(itemID), 
                        true)
                else
                    icon:getChildByPath('tip'):setVisible(false) 
                end
            else
                icon:getChildByPath('tip'):setVisible(false) 
            end
        else
           icon:getChildByPath('tip'):setVisible(false) 
        end
    end

end

function PersonalInfoPanel:onKeyBackClicked(...)

    if self.isDisposed then return end

    if self.avatarSelectGroup:closeMoreAvatars() then
        return
    end

    BasePanel.onKeyBackClicked(self, ...)

end

function PersonalInfoPanel:onCloseBtnTapped( ... )
    print("function PersonalInfoPanel:onCloseBtnTapped ")

	if self.isDisposed then return end

	if self.avatarSelectGroup.photoView ~= nil then
        self.avatarSelectGroup:closePhotoView()
        return
    end

    self:_close()

	self.allowBackKeyTap = false
	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end

	if self.manager then
        self.manager:unreigsterDataEvent(self.manager.PERCENT_RANK)
        self.manager:unreigsterDataEvent(self.manager.STAR_GLOBAL_RANK)
        self.manager.panel = nil
	end

    self.avatarSelectGroup.parent = nil

    -- local homeScene = HomeScene:sharedInstance()
    -- homeScene:runAction(CCCallFunc:create(function( ... )
    --     PopoutQueue:sharedInstance():popAgain(true , PopoutLayerPriority.Guide_PersonalInfoPanel)
    -- end))
    
    -- if AchiUIManager:hasGuide() then
    --     GameGuide:sharedInstance():forceStopGuide()
    --     GameGuide:sharedInstance():tryStartGuide()
    -- end
    
    if self.closeCallBack then
        self.closeCallBack()
    end
end

function PersonalInfoPanel:onEnterForeGround( ... )
    if self.isDisposed then return end
    -- self.avatarSelectGroup:closeNativePhotoView()
end


return PersonalInfoPanel
