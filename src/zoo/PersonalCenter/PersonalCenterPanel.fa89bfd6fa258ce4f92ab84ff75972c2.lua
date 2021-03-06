require "zoo.account.AccountBindingLogic"

local PersonalCenterPanel = class(BasePanel)

-- local print = function ( str )
-- 	oldPrint("[PersonalCenterPanel] "..str)
-- end

function PersonalCenterPanel:create(manager)
    local panel = PersonalCenterPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    panel:init(manager)
    return panel
end

function PersonalCenterPanel:init(manager)
	self.manager = manager

	self.moreAvatarList = {}

	self.ui = self:buildInterfaceGroup("personal_center_panel")
    BasePanel.init(self, self.ui)


    self.closeBtn = self.ui:getChildByName('closeBtn')
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onCloseBtnTapped(event) 
	                               end)

    local myInviteCode = manager:getData(manager.INVITE_CODE)

    self.copyBtn = self.ui:getChildByName("copyBtn")
    if myInviteCode ~= nil and #myInviteCode >= 9 and #myInviteCode <= 11 and tonumber(myInviteCode) ~= nil then
        self.copyBtn:setTouchEnabled(true, 0, true)
        self.copyBtn:getChildByName("evtLayer"):setVisible(false)
        self.copyBtn:addEventListener(DisplayEvents.kTouchTap, function (event)
            if not self.copyBtn.inClk then
                self.copyBtn.inClk = true
                setTimeOut(function( ... ) if self.copyBtn ~= nil and not self.copyBtn.isDisposed then self.copyBtn.inClk = false end end, 0.5)
                local preStr = localize("addfriend_copy_sms_pre")
                local tagStr = localize("addfriend_copy_sms_tag")
                ClipBoardUtil.copyText(preStr .. myInviteCode .. tagStr)
                CommonTip:showTip(localize("addfriend_auto_add_copy_sucess"), "positive")
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "copyID"
                dcData.t1 = 1
                DcUtil:log(AcType.kUserTrack, dcData, true)
            end
        end)
    else
        self.copyBtn:setVisible(false)
    end

    --self.name = self.ui:getChildByName("name")
    --self.name:setString(nameDecode(manager:getData(manager.NAME)))

    self.editBtn = GroupButtonBase:create(self.ui:getChildByName('editBtn'))
    self.editBtn:setString(localize("my.card.btn1"))
    self.editBtn.redDot = self.editBtn.groupNode:getChildByName('redDot')
    local redDotKey = 'personel.center.edit.btn.reddot.clicked'
    local function onTapEditBtn()
        if not kUserLogin then
            CommonTip:showTip(localize("my.card.panel.warning.tip3"))
        else
            local EditProfilePanel = require "zoo.PersonalCenter.EditProfilePanel"
            local panel = EditProfilePanel:create(manager)
            panel.parentPanel = self
            panel:popout()
            self.editPanel = panel
            DcUtil:UserTrack({category='my_card', sub_category="my_card_click_edit_profile"}, true)
        end
    end

    self.onTapEditBtn = onTapEditBtn
    self.editBtn:ad(DisplayEvents.kTouchTap, onTapEditBtn)
    if self.manager:getData(self.manager.SHOW_ACCBTN_REDDOT) then
        self.editBtn.redDot:setVisible(false)
    else
        self.editBtn.redDot:setVisible(self.manager:showEditInfoRedDot())
    end

    local finishedEdit = self.ui:getChildByName('finishedEdit')

    self.editBtn1 = finishedEdit:getChildByName("editBtn")
    self.editBtn1:setTouchEnabled(true)
    self.editBtn1:ad(DisplayEvents.kTouchTap, onTapEditBtn)

    self.bubleEdit =  self.ui:getChildByName("bubleEdit")
    self.bubleEdit:setTouchEnabled(true)

    local function updateBubleEdit()
        self:updateBubleEdit()
    end
    updateBubleEdit()

    local function onTapBubleEdit() 
        local panel = AccountSettingPanel:create()
        panel.bindCallBack = updateBubleEdit 
        panel:popout()
        DcUtil:UserTrack({category='my_card', sub_category="my_card_click_setting"}, true)

        if __WIN32 then return end
        if self:hasAccountBinded() then return end

        local authConfig = PlatformConfig.authConfig
    
        if _G.isLocalDevelopMode then printx(0, table.tostring(authConfig)) end
        local singleAuth
        if type(authConfig) == 'table' and #authConfig == 1 and authConfig[1] ~= PlatformAuthEnum.kGuest
        then
            singleAuth = authConfig[1]
        elseif type(authConfig) ~= 'table' and authConfig ~= PlatformAuthEnum.kGuest then
            singleAuth = authConfig
        end
        if singleAuth then
            if singleAuth == PlatformAuthEnum.kPhone then
                panel:bindNewPhone()
            else
                panel:bindNewSns(singleAuth, panel:hasRewardTip(singleAuth))
            end
        end
    end

    self.bubleEdit:ad(DisplayEvents.kTouchTap, onTapBubleEdit)

    if not self.manager:getData(self.manager.SHOULD_SHOW_ACCBTN) then
        self.bubleEdit:setVisible(false)
    end

    self.starNum = self.ui:getChildByName("starNum")
    self.starNum:setScale(0.7)
    self.starNum:setAnchorPoint(ccp(0.5, 0.5))
    local pos = self.starNum:getPosition()
    self.starNum:setPosition(ccp(pos.x + 40 , pos.y - 25))
    self.starNum:setText(manager:getData(manager.STAR))
   
    if manager:getData(manager.STAR) == 0 then
        self.ui:getChildByName("starTip"):setString(localize("my.card.panel.text1.1"))
        self.ui:getChildByName("starTip1"):setVisible(false)
        self.ui:getChildByName("starTip2"):setVisible(false)
        self.ui:getChildByName("starTip3"):setVisible(false)
    else
        self.ui:getChildByName("starTip"):setVisible(false)

        local tip = self.ui:getChildByName("starTip1")
        local starTipBg = self.ui:getChildByName("starTipBg")
        local starTipBgBounds = starTipBg:boundingBox()
        tip:setAnchorPoint(ccp(0.5,0.5))
        tip:setPositionX(starTipBgBounds:getMidX() - 5)
        tip:setPositionY(starTipBgBounds:getMinY() + 38)

        local tipBgWidth = starTipBgBounds.size.width

        local pctRank = manager:getData(manager.PERCENT_RANK)
        local starGlobalRank = manager:getData(manager.STAR_GLOBAL_RANK)
        local function updatePercentRank()
            if starGlobalRank and starGlobalRank > 0 then
                if starGlobalRank == 1 then
                    pctRank = 10000
                end
                tip:setRichText(
                    "总星级位列全国第" .. 
                    string.format("[#FF0000]%d[/#]",starGlobalRank) ..
                    "名,超越" ..
                    string.format("[#FF0000]%.2f[/#]",pctRank / 100) .. 
                    "%的小伙伴！",
                    "D79F1F"
                )
            else                
                tip:setRichText(
                    "总星级超越了全村" ..
                    string.format("[#FF0000]%.2f[/#]",pctRank / 100) ..
                    "%的小伙伴！",
                    "D79F1F"
                )
            end

            tip:setScale(tipBgWidth/tip:getContentSize().width * 0.9)
        end
        updatePercentRank()
        manager:reigsterDataEvent(manager.PERCENT_RANK, function( value )
            pctRank = value
            updatePercentRank()
        end)
        manager:reigsterDataEvent(manager.STAR_GLOBAL_RANK,function( value )
            starGlobalRank = value
            updatePercentRank()
        end)
    end

    if (not kUserLogin) and manager:getData(manager.STAR) ~= 0 then
        self.ui:getChildByName("starTip"):setString(localize("my.card.panel.text1.2"))
        self.ui:getChildByName("starTip1"):setVisible(false)
        self.ui:getChildByName("starTip2"):setVisible(false)
        self.ui:getChildByName("starTip3"):setVisible(false)
        self.ui:getChildByName("starTip"):setVisible(true)
    end

    local code = self.ui:getChildByName("qrcode")
	code:setVisible(false)

	local size = code:getGroupBounds().size
	local qrcode = CocosObject.new(QRManager:generatorQRNode(manager:getData(manager.QR_CODE), size.width, 1, ccc4(74, 175, 23, 255)))
	local sSize = qrcode:getContentSize()
	qrcode:setAnchorPoint(ccp(0, 1))
	qrcode:setScaleX(size.width / sSize.width)
	qrcode:setScaleY(-size.height / sSize.height) -- original and correct scaleY of image is smaller than zero.
	qrcode:setPositionXY(code:getPositionX(), code:getPositionY() - sSize.height * math.abs(qrcode:getScaleY()))
	self.ui:addChildAt(qrcode, 11)

    local idPos = self.ui:getChildByName("idPos")
    idPos:setVisible(false)
    local idSize = idPos:getGroupBounds().size
    local posIdLabelNum = idPos:getPosition()

    local idLabelUi = self.ui:getChildByName("idLabel")
    local posx = idLabelUi:getPositionX()
	idLabelUi:setVisible(false)
    local idLabel = LabelBMMonospaceFont:create(36, 36, 25, "fnt/nametag.fnt")
    idLabel:setAnchorPoint(ccp(0, 0.5))
    idLabel:setPosition(ccp(posx, posIdLabelNum.y - idSize.height / 2 - 3))
    idLabel:setString(localize("my.card.panel.text2").."：")
    self.ui:addChildAt(idLabel, 11)
	local idLabelNum = self.ui:getChildByName("idLabelNum")
    
	idLabelNum:setAnchorPoint(ccp(0.5, 0.5))
    idLabelNum:setScale(1.2)
	idLabelNum:setPosition(ccp(posIdLabelNum.x + idSize.width / 2, posIdLabelNum.y - idSize.height / 2 - 3))
	idLabelNum:setText(myInviteCode)

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

    local sendBtnUi = self.ui:getChildByName('sendBtn')
    self.sendBtn = ButtonIconsetBase:create(self.ui:getChildByName('sendBtn'))

    local shareType = SnsUtil.getShareType()
    local icon = ShareShowUtil.getInstance():getBtnIconByType(shareType)
    icon:setAnchorPoint(ccp(0, 1))
    self.sendBtn:setIcon(icon, true)

    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        self.sendBtn:setString("米聊邀请")
        self.sendBtn.label:setPositionX(-45)
    else
        self.sendBtn:setString(localize("my.card.btn2"))
    end

    self.sendBtn:setColorMode(kGroupButtonColorMode.blue)
    local function onTapSendBtn()
        local function cb()
            self.sendBtn:setEnabled(true)
        end

        setTimeOut(cb, 3)
        self.sendBtn:setEnabled(false)
        self.manager:sendBusinessCard(cb, cb, cb)
    end
    self.sendBtn:ad(DisplayEvents.kTouchTap, onTapSendBtn)

    if not self.manager:getData(self.manager.SHOULD_SHOW_CARD_BTN) then
        self.sendBtn:setVisible(false)
    end

    local rank = manager:getData(manager.STAR_FRIEND_RANK)

    self.starRankTip = self.ui:getChildByName("starRankTip")
    self.starRankTip:getChildByName("text"):setString("当前所获星星数在好友中排名：第"..rank.."名")
    self.starRankTip:setVisible(false)

    local function timeout()
    	self.starRankTip:setVisible(false)
    end

    self.starRankImg = self.ui:getChildByName("starRankImg")
    self.starRankImg:setTouchEnabled(true, 0, true)
    self.starRankImg:ad(DisplayEvents.kTouchTap, function ()
    	if not self.starRankTip.isDisposed and not self.starRankTip:isVisible() then
    		self.starRankTip:setVisible(true)
    		setTimeOut(timeout, 3)
    	end
    end)

    local silver = self.starRankImg:getChildByName("silver")
    silver:setPositionX(silver:getPositionX() + 4)
    self.starRankImg:getChildByName("golden"):setVisible(rank == 1)
    silver:setVisible(rank == 2)
    self.starRankImg:getChildByName("bronze"):setVisible(rank == 3)
    self.starRankImg:getChildByName("other"):setVisible(rank > 3)
    local starRank = self.ui:getChildByName("starRank")
    starRank:setAnchorPoint(ccp(0.5, 0.5))
    local otherBounds = self.starRankImg:getChildByName("other"):boundingBox()
    starRank:setPositionX(self.starRankImg:getPositionX() + otherBounds:getMidX())
    starRank:setPositionY(self.starRankImg:getPositionY() + otherBounds:getMidY())
    starRank:setText(rank)
    starRank:setVisible(rank >= 4)

    local image = self.ui:getChildByName("image")
    image:setVisible(false)
    image:setAnchorPointCenterWhileStayOrigianlPosition()
    local posImage = image:getPosition()
    local sprite = Sprite:createEmpty()
    sprite:setPosition(ccp(posImage.x, posImage.y))
    local imageSize = image:getGroupBounds().size
    local imageWidth = imageSize.width
    local imageHeight = imageSize.height
    local layer = LayerColor:create()
    layer:setColor(ccc3(255,255,255))
    layer:setContentSize(CCSizeMake(imageWidth, imageHeight))
    layer:setAnchorPoint(ccp(0.5,0.5))
    layer:ignoreAnchorPointForPosition(false)
    layer:setPosition(ccp(posImage.x, posImage.y))
    self.ui:addChildAt(layer, 13)
    self.ui:addChildAt(sprite, 14)

    --------------- UC 平台 ---------------------
    if PlatformConfig:isPlatform(PlatformNameEnum.kUC) then
        self.sendBtn:setVisible(false)
        qrcode:setVisible(false)
        sprite:setVisible(false)
        layer:setVisible(false)
        self.ui:getChildByName('bg3'):setVisible(false)
    end
    --------------- end UC 平台 ---------------------

    local function changePlayer( clipping, headUrl )
        if clipping.headSprite.refCocosObj == nil then return end
        local texture, rect = clipping:getHeadTextureAndRect()
        sprite:setTexture(texture)
        sprite:setTextureRect(rect, false, CCSizeMake(imageWidth, imageHeight))
        sprite:setScale(imageWidth * 2 / rect.size.width / 3)
        layer:setScale(2/3)

        if tostring(self.manager:getData(self.manager.HEAD_URL)) ~= tostring(headUrl) then
            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=1}, true)
            self.manager:setData(self.manager.HEAD_URL, tostring(headUrl))
            local isCustomHeadUrl = (tonumber(headUrl) == nil)
            self.manager:uploadUserProfile(isCustomHeadUrl)
        end
    end

    local AvatarSelectGroup = require "zoo.PersonalCenter.AvatarSelectGroup"
    self.avatarSelectGroup = AvatarSelectGroup:buildGroup(manager, 
                                self.ui:getChildByName("moreAvatars"),
                                self.ui:getChildByName("avatar"),
                                self.ui:getChildByName("nameLabel"),
                                changePlayer
                                )
    self.avatarSelectGroup.parent = self
    --打点用
    self.avatarSelectGroup.originalPlace = 0

    self.achiBtn = self.ui:getChildByName("starImg")
    self.achiBtn:setTouchEnabled(true)

    local function onTapAchiBtn()
        local AchievementPanel = require "zoo.PersonalCenter.AchievementPanel"
        local achievementPanel = AchievementPanel:create(manager)
        achievementPanel.parentPanel = self
        achievementPanel:popout()
        DcUtil:UserTrack({category='my_card', sub_category="my_card_click_achievement"}, true)
    end
    self.achiBtn:ad(DisplayEvents.kTouchTap, onTapAchiBtn)

    local totalAchiLevel = self.manager:getData(self.manager.TOTAL_ACHI_LEVEL)

    --根据成就等级，显示不同的勋章，使用不同的字体
    local fntFile = nil
    local charWidth     = 30
    local charHeight    = 30
    local charInterval  = 15
    
    local medalType = AchievementManager:getMedalType(totalAchiLevel)
    self.achiBtn:getChildByName("_bg"):setVisible(false)
    local isCopper = medalType == AchievementManager.medalType.Copper
    local isSilver = medalType == AchievementManager.medalType.Silver
    local isGolden = medalType == AchievementManager.medalType.Gold
    if isGolden then
        fntFile = 'fnt/race_rank.fnt'
    elseif isSilver then
        fntFile = 'fnt/race_rank_silver.fnt'
    elseif isCopper then
        fntFile = 'fnt/race_rank_copper.fnt'
    end

    self.achiBtn:getChildByName("default"):setVisible(medalType == AchievementManager.medalType.None)
    self.achiBtn:getChildByName("copper"):setVisible(isCopper)
    self.achiBtn:getChildByName("silver"):setVisible(isSilver)
    self.achiBtn:getChildByName("golden"):setVisible(isGolden)

    if medalType ~= AchievementManager.medalType.None then
        -- local achiLevelLabel  = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
        local labelText = tostring(totalAchiLevel)
        local starImageSize = CCSizeMake(88, 88)
        -- achiLevelLabel:setString(labelText)

        -- --拙劣的调整字体位置，是一位数还是两位数区别对待
        -- achiLevelLabel:setAnchorPoint(ccp(0.5, 0.5))

        -- if __ANDROID then
        --     if totalAchiLevel < 10 then
        --         achiLevelLabel:setPositionXY(starImageSize.width/2-3, -starImageSize.height/2-10)
        --     else
        --         achiLevelLabel:setPositionXY(starImageSize.width/2-5, -starImageSize.height/2-10)
        --     end
        -- else
        --     if totalAchiLevel < 10 then
        --         achiLevelLabel:setPositionXY(starImageSize.width/2-4, -starImageSize.height/2-10)
        --     else
        --         achiLevelLabel:setPositionXY(starImageSize.width/2-6, -starImageSize.height/2-10)
        --     end
        -- end

        -- self.achiBtn:addChild(achiLevelLabel)

        local achiLevelLabel = BitmapText:create(labelText, fntFile)
        achiLevelLabel:setAnchorPoint(ccp(0.5, 0.5))
        achiLevelLabel:setScale(charHeight/achiLevelLabel:getContentSize().height)
        achiLevelLabel:setPositionXY(starImageSize.width/2-2, -starImageSize.height/2-10)
        self.achiBtn:addChild(achiLevelLabel)
    end

    self:updateProfile(true)

    --guide
    -- local PersonalCenterGuide = require "zoo.PersonalCenter.PersonalCenterGuide"
    -- local para = {
    --     achiBtn = {self.achiBtn, onTapAchiBtn},
    --     editBtn = {self.editBtn, onTapEditBtn},
    --     bubleEdit = {self.bubleEdit, onTapBubleEdit},
    --     sendBtn = {self.sendBtn, onTapSendBtn},
    --     panel = self
    -- }
    -- self.guide = PersonalCenterGuide:create(para) 
    -- if _G.isLocalDevelopMode then printx(0, "init >>>>>") end

end

function PersonalCenterPanel:hasAccountBinded()
    return UserManager.getInstance().profile:isPhoneBound() or UserManager.getInstance().profile:isSNSBound()
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

function PersonalCenterPanel:updateBubleEdit()
    if self.isDisposed or not self.bubleEdit then return end

    local userData = Localhost.getInstance():readCurrentUserData()
    local showAuthType = userData and userData.authorType or nil
    if not showAuthType then 
        showAuthType = AccountBindingLogic:getRcmdAccountType()
    end
    if not showAuthType then
        self.bubleEdit:setVisible(false)
        return
    end

    if self.manager:getData(self.manager.SHOW_ACCBTN_REDDOT) then
        self.bubleEdit:getChildByName("resDot"):setVisible(true)
    else
        self.bubleEdit:getChildByName("resDot"):setVisible(false)
        self.editBtn.redDot:setVisible(self.manager:showEditInfoRedDot())
    end


    local showIconName = PlatformAccountIcons[showAuthType] or "setting"
    self.bubleEdit.showIconName = showIconName
    local iconSprite = self.bubleEdit:getChildByName("sprite")
    if iconSprite then
        iconSprite:setChildrenVisible(false, true)
        iconSprite:getChildByName(showIconName):setVisible(true)
    end
end

function PersonalCenterPanel:updateProfile(isInit, isUserModifiy)
    local m = self.manager
    local age = m:getData(m.AGE)
    local cons = m:getData(m.CONSTELLATION)
    local sex = m:getData(m.SEX)

    local finishedEdit = self.ui:getChildByName("finishedEdit")

    local headUrl = m:getData(m.HEAD_URL)

    if not isInit then
        self.avatarSelectGroup:changeAvatarImage(headUrl)
    end

    local name = self.ui:getChildByName("nameLabel"):getChildByName("label")
    local nameText = nameDecode(m:getData(m.NAME))
    if name:isVisible() then
        name:setString(nameText .." ")
    elseif self.avatarSelectGroup.input then
        self.avatarSelectGroup.input:setText(nameText)
    end

    if not isInit then
        self.manager:uploadUserProfile(isUserModifiy)

        if self.manager:getData(self.manager.SHOW_ACCBTN_REDDOT) then
            self.editBtn.redDot:setVisible(false)
        else
            self.editBtn.redDot:setVisible(self.manager:showEditInfoRedDot())
        end
        HomeScene:sharedInstance().settingButton:updateDotTipStatus()
    end

    if  age == 0 and cons == 0 and sex == 0 then
        self.ui:getChildByName('editBtn'):setVisible(true)
        finishedEdit:setVisible(false)
        return
    end

    self.ui:getChildByName('editBtn'):setVisible(false)
    finishedEdit:setVisible(true)

    local labelACG = finishedEdit:getChildByName('labelACG')

    local ageText = ''
    local genderText = ''
    local constellationText = ''

    if tonumber(age) == 100 then
        age = "99+"
    end

    ageText = age == 0 and "" or age.."岁".." "
    
    local genderTextGroup = {'', localize('my.card.edit.panel.content.male'), localize('my.card.edit.panel.content.female')}
    genderText = genderTextGroup[sex + 1]..' '

    if cons > 0 then
        constellationText = localize('my.card.edit.panel.content.constellation'..cons)
    end
    local labelACGText = ageText..genderText..constellationText
    labelACG:setString(labelACGText)

    local offsetX = #labelACGText * (9) - 9
    self.editBtn1:setPositionX(offsetX + labelACG:getPositionX())
end

function PersonalCenterPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function PersonalCenterPanel:createShowAnim()
    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished( )self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function PersonalCenterPanel:onEnterAnimationFinished()
   
end

function PersonalCenterPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
end

function PersonalCenterPanel:onCloseBtnTapped()
    if self.avatarSelectGroup.photoView ~= nil then
        self.avatarSelectGroup:closePhotoView()
        return
    end

	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end

	if self.manager then
		--self.manager:uploadUserProfile()
        self.manager:unreigsterDataEvent(self.manager.PERCENT_RANK)
        self.manager:unreigsterDataEvent(self.manager.STAR_GLOBAL_RANK)
        self.manager.panel = nil
	end
    self.avatarSelectGroup.parent = nil
end

return PersonalCenterPanel