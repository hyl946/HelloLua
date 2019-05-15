local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'
local PrivateStrategy = require 'zoo.data.PrivateStrategy'
local BottomInfo = require 'zoo.PersonalCenter.PersonalBottomInfo'
local UIHelper = require 'zoo.panel.UIHelper'
local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

local SuperCls = BasePanel
local MainPanel = class(SuperCls)

local isLoading

function MainPanel:create(data,params)
    print("--FriendInfoPanel:create(data)",data,isLoading,table.tostring(params))
    if isLoading then
        return
    end
    local curScene = Director:sharedDirector():run()


    isLoading = true

    local function resetLoading()
        isLoading = false
    end

    setTimeOut(resetLoading,5)

    if not data then
        data = UserManager:getInstance().uid
    end
    uid = tonumber(data)

    if not uid then
        local msg = "FriendInfoPanel_no_uid:["..tostring(data).."]\n"..tostring(debug.traceback())
        print(msg)

        CommonTip:showTip("玩家信息获取失败，请稍后再试~")
        resetLoading()

        he_log_error(msg)
        return
    end

    local function doCreate(data)
        local scene = Director:sharedDirector():run()
        print("doCreate()",curScene == scene)

        if not curScene or not scene or curScene ~= scene then
            resetLoading()
            return
        end

        local panel = MainPanel.new()
        panel.uid = uid
        panel.isSelf = uid<=0 or uid == tonumber(UserManager:getInstance().uid)
        if panel.isSelf then
            panel.uid = UserManager:getInstance().uid
        end

        if params then
            panel.delCallback = params.delCallback
            panel.strRank = params.strRank
            panel.isFromAchiRank = params.isFromAchiRank

        end

        panel:init()
        panel:onPersonalInfoChange(data)
        panel:popout()

        setTimeOut(resetLoading,0.1)
        return panel
    end

    local function showNoNetwork()
        CommonTip:showTip("网络连接失败，请联网重试~")
        resetLoading()
    end

    local function getDataError()
        CommonTip:showTip("玩家名片信息获取失败，请稍后再试~")
        resetLoading()
    end

    local function reqData()
        print("reqData()")
        FriendInfoUtil:req_friendData(uid,doCreate,getDataError,resetLoading)
    end

    RequireNetworkAlert:callFuncWithLogged(function( ... )
        print("preventContinuousClick()")
        reqData()
        end,showNoNetwork,kRequireNetworkAlertAnimation.kSync)
end

function MainPanel:init()
    self.isFriend = not self.isSelf and FriendManager.getInstance():getFriendInfo(self.uid)
    self:initUI()
end

function MainPanel:initUI()
    -- local ui = UIHelper:createUI('ui/personal_center_panel.json', 'friend_info')
    
    local builder = InterfaceBuilder:createWithContentsOfFile('ui/personal_center_panel.json')
    local ui = builder:buildGroup('friend_info')
    self.ui = ui

    SuperCls.init(self,ui)

    local function formatChild(parent,childs,owner)
        owner = owner or parent
        for i,v in ipairs(childs) do
            owner[v] = parent:getChildByName(v)
            -- print(v,parent[v])
            -- assert(owner[v],"NO CHILD:"..tostring(v))
        end
    end

    local function setText(label,str)
        str = str or ""
        if not label or not label.setString then 
            print("NO LABEL:" .. debug.traceback())
            do return end
        end
        label:setString(tostring(str))
    end

    local function setBtnOnClick(key,callback)
        local item = self[key]
        if not item then
            printx(0,"ERR!Can not find ui by key:"..tostring(key).."---"..debug.traceback())
            return
        end
        item:setTouchEnabled(true,0, false)
        item:setButtonMode(true)
        item:addEventListener(DisplayEvents.kTouchTap, callback)
    end

    formatChild(self.ui,{
"hit_area",
"bg",
"bg3",
"imgFreeGift",
"btnFreeGift",
"btnDelete",
"_btnDelete",
"btnEdit",
"_btnLike",
"btnLike",
"name",
"closeBtn",
"bottomInfo",
"bgTxt1",
"bgTxt0",
"txt0",
"txt1",
"line",
"txtWeekRace",
"btnWeekRace",
"avatarPlaceholder",
"likeIcon",
},self)

    formatChild(self.likeIcon,{
"icon",
"txt",
"bg",
})

    setBtnOnClick("btnFreeGift",handler(self,self.onFreeGift))
--    setBtnOnClick("btnLike",handler(self,self.onLike))
    setBtnOnClick("btnWeekRace",handler(self,self.onWeekRaceHistory))
    setBtnOnClick("closeBtn",handler(self,self.onClose))
    setBtnOnClick("btnDelete",handler(self,self.onDelBtnTap))

    self.btnEdit = GroupButtonBase:create(self.btnEdit)
    self.btnEdit:setString("编辑资料")
    self.btnEdit:ad(DisplayEvents.kTouchTap, function() 
        self:onEdit()
    end)

    -- self._btnLike = self.ui:getChildByName("_btnLike")

    self._btnLike = ButtonIconsetBase:create(self.ui:getChildByName("_btnLike"))
    self._btnLike:addEventListener(DisplayEvents.kTouchTap,function( ... )
        self:onLike() 
    end)
    self._btnLike:setString("赞")
    self._btnLike:setIconByFrameName("common_icon/sns/icon_zan0000")

    --bottom
    self.bottomInfo = BottomInfo:create(ui:getChildByPath("bottomInfo"))
    self.bottomInfo.notSelf = not self.isSelf

    local touch = self.name:getChildByName("touch")
    touch:setVisible(false)
    self.name:getChildByName("label"):setColor(hex2ccc3('A14A0E'))
    self.name:getChildByName("inputBegin"):setVisible(false)
    self.name:getChildByName("label"):setString("消消乐玩家")

    self.btnLike:setVisible(false)
    self._btnLike:setVisible(false)
    self.likeIcon:setVisible(false)
    self.btnLike:setVisible(false)
    self._btnLike:setVisible(false)
    self.btnFreeGift:setVisible(false)
    self.imgFreeGift:setVisible(false)
    self.btnEdit:setVisible(false)

    self.avatarPlaceholder:setVisible(false)
    self.txtWeekRace:setVisible(false)
    self.btnWeekRace:setVisible(false)

    self.likeNum = 0

    self.likeIcon.txt:setPositionY(self.likeIcon.txt:getPositionY()-2)
    self.likeIcon.txt:setPositionX(self.likeIcon.txt:getPositionX()-2)
    self.likeIcon.baseX=self.likeIcon:getPositionX()+85

    self.likeIconWidth = 0
end

function MainPanel:setLikeNum( num )
    print("setNum",num)
    self.likeIcon:setVisible(true)

    local numStr = tostring(num)
    if num >= 100000000 then
        numStr = math.floor(num*10*0.00000001)*0.1 .. "亿"
    elseif num >= 10000 then
        numStr = math.floor(num*10*0.0001)*0.1 .. "万"
    end
    self.likeIcon.txt:setString(numStr)
    -- UIHelper:setCenterText(self.likeIcon.txt, numStr, 'fnt/hud.fnt')

    local n = utfstrlen(numStr)
    local w = n*15+40
    self.likeIcon:setPositionX(self.likeIcon.baseX-w)
    self.likeIcon.bg:setContentSize(CCSizeMake(w,38))
    self.likeIcon.txt:setDimensions(CCSizeMake(w-20,30))
    self.likeIconWidth = w
end

function MainPanel:onDelBtnTap(event)
    local function onSuccess( ... )
        print("MainPanel:onDelBtnTap()onSuccess()--",self.uid)
        local _ = self.delCallback and self.delCallback(self.uid)
        self:onClose()
    end

    local function onFail( ... )
        print("MainPanel:onDelBtnTap()onFail()--",self.uid)
    end
    
    local function onSelectCallback(isConfirmed)
        if isConfirmed then
            FriendInfoUtil:req_delete({self.uid},onSuccess,onFail)
        else
            DataTracking:delFriend(false)
        end
    end

    local DeleteFriendAlter = require 'zoo.panel.component.friendsPanel.func.DeleteFriendAlter'
    DeleteFriendAlter:create(onSelectCallback):popout()

    local params = {}
    params.category = "ui"
    params.subcategory = "G_my_card_btn"
    params.other = "t5"
    DcUtil:UserTrack(params)
end

function MainPanel:onFreeGift( ... )
    self.btnFreeGift:setVisible(false)
    self.imgFreeGift:setVisible(false)

    local function onSuccess(data)
        CommonTip:showTip("赠送成功","positive")
        if self.isDisposed then return end
    end

    local function onFail(err)
        if self.isDisposed then return end

        self:refreshFreeGift()

        if err and err.data then
            CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err.data)))
        end
    end

    FriendInfoUtil:sendFreeGift(self.uid,onSuccess,onFail,onFail)

    local params = {}
    params.category = "ui"
    params.subcategory = "G_my_card_btn"
    params.other = "t2"
    DcUtil:UserTrack(params)
end

function MainPanel:onWeekRaceHistory( ... )
    local params = {}
    params.category = "ui"
    params.subcategory = "G_my_card_panel_click"
    params.other = "t1"
    DcUtil:UserTrack(params)

    local function showPanel()
        local RankRaceDanHistory = require 'zoo.quarterlyRankRace.view.RankRaceDanHistory'
        local historyPanel = RankRaceDanHistory:create(self.weekMatchSeasonHistories)
        historyPanel:popout()
    end

    showPanel()
end

function MainPanel:onLike( ... )
    self.btnLike:setVisible(false)

    local function onSuccess(data)
        if self.isDisposed then return end

--        self._btnLike.groupNode:runAction(CCFadeOut:create(0.6))
        self._btnLike.groupNode:setVisible(false)

        local anim = gAnimatedObject:createWithFilename('gaf/personalInfo/friend_like.gaf')
        anim:setPosition(ccp(-30, 155))
        anim:start()
        self:addChild(anim)

        self:setLikeNum(self.likeNum)

        local function refreshNum()
            if self.isDisposed then return end
            self:setLikeNum(self.likeNum+1)
        end

        setTimeOut(refreshNum,2.2)
    end

    local function onFail()
        if self.isDisposed then return end

        -- CommonTip:showTip("请求数据失败")
        self.btnLike:setVisible(false)
        self._btnLike:setVisible(false)
    end

    FriendInfoUtil:req_like(self.uid,onSuccess,onFail)

    local params = {}
    params.category = "ui"
    params.subcategory = "G_my_card_btn"
    params.other = "t3"
    DcUtil:UserTrack(params)
end

function MainPanel:onEdit( ... )
    if self.isDisposed then return end
    PersonalCenterManager:showPersonalCenterPanel()

    local params = {}
    params.category = "ui"
    params.subcategory = "G_my_card_btn"
    params.other = "t1"
    DcUtil:UserTrack(params)
end

function MainPanel:refreshFreeGift(  )
    local showFreeGift = false
    if not self.isSelf then
        showFreeGift = FreegiftManager:sharedInstance():canSendTo(tonumber(self.uid))
    end
    self.btnFreeGift:setVisible(showFreeGift)
    self.imgFreeGift:setVisible(showFreeGift)
end

function MainPanel:onPersonalInfoChange( data )
    local profile = UserManager:getInstance().profile
    local starGlobalRank = PersonalCenterManager:getData(PersonalCenterManager.STAR_GLOBAL_RANK)
    local pctRank = PersonalCenterManager:getData(PersonalCenterManager.PERCENT_RANK)

    if data then
        self.weekMatchSeasonHistories = data.weekMatchSeasonHistories
        starGlobalRank = data.starGlobalRank
        pctRank = data.pctOfRank or 0
        
        if not self.isSelf then
            profile = data.profile
        end

        if data.canThumbsUp and not self.isSelf then
            self.btnLike:setVisible(true)
            self._btnLike:setVisible(true)
        end
        self.likeNum = tonumber(data.thumbsUpCount) or 0
        self:setLikeNum(self.likeNum)
    end
    
    if self.weekMatchSeasonHistories and string.len(self.weekMatchSeasonHistories) > 4 then
        self.txtWeekRace:setVisible(true)
        self.btnWeekRace:setVisible(true)
    end

    self.btnEdit:setVisible(self.isSelf)

    local canDelete = FriendManager:getInstance():canDelete() and self.isFriend
    self.btnDelete:setVisible(canDelete)
    self._btnDelete:setVisible(canDelete)

    self.avatarPlaceholder:setVisible(true)
    self.bottomInfo:onPersonalInfoChange(data)

    if self.isFriend then
        self:refreshFreeGift()
    else
        self.btnFreeGift:setVisible(false)
        self.imgFreeGift:setVisible(false)
    end

    --head
    UIHelper:loadUserHeadIcon(self.avatarPlaceholder, profile, true)

    --address
    local address = profile.location or ""
    if address == '' then
        -- address = '未知地区'
    end

    address = string.gsub(address, '#', ' ')

    --sex age
    if profile.secret then
        self.txt0:setString("未知")
        
    else
        local birth = profile.birthDate
        local age = profile.age
        local cons = profile.constellation
        local sex = profile.gender
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
        local str = genderText .. ageText .. constellationText
        if string.gsub(str, ' ', '') == '' then
            if address == "" then
                str = "未知"
            else
                str = address
            end
        else
            str = str .. " " .. address
        end

        str = TextUtil:ensureTextWidth(str, self.txt0:getFontSize(), self.txt0:getDimensions() )
        self.txt0:setString(str)
    end

    --rank

    local function update( ... )
        if self.isDisposed then return end

        local rankStr = self.strRank
        if not self.strRank then
            rankStr = "总星级暂未上榜"

            if starGlobalRank > 0 and starGlobalRank < 100000 then
                rankStr = string.format("总星级全国第%d名", starGlobalRank)
            else
                local pct = pctRank*0.01 or 0
                if pct > 99 or pct <= 0 then
                    rankStr = string.format("总星级暂未上榜")
                else
                    rankStr = string.format("总星级全国前 %.2f%%", 100-pct)
                end
            end
        elseif starGlobalRank==0 and pctRank==0 then
            rankStr = "总星级暂未上榜"
            
        end

        self.txt1:setString(rankStr)
    end

    -- self.txt1:changeFntFile('fnt/profilestar.fnt')
    update()

    --name
    local nameStr = ""
    if self.isSelf then
        nameStr = PersonalCenterManager:getData(PersonalCenterManager.NAME)
    else
        nameStr = profile.name and nameDecode(profile.name) or localize("game.setting.panel.use.device.name.default")
    end

    local label = self.name:getChildByName("label")
    local size = label:getDimensions()
    size.width = size.width - self.likeIconWidth + 30
    nameStr = TextUtil:ensureTextWidth(nameStr, label:getFontSize(),size)
    label:setString(nameStr)

    -- self.isNickNameUnModifiable = PersonalCenterManager:getData(PersonalCenterManager.NAME_MODIFIABLE)
    -- self.name:getChildByName("label"):setVisible(false)
    -- self:initInput()
end

function MainPanel:onKeyBackClicked( ... )
        -- SuperCls.onKeyBackClicked(self, ...)
    self:onClose()
end

function MainPanel:onClkCloseBtn()
    self:onClose()
end

function MainPanel:popout()
    PopoutManager:sharedInstance():add(self, true)

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

    return self
end

function MainPanel:onClose()
    if self.isDisposed then return end
    PopoutManager:sharedInstance():remove(self)
end

function MainPanel:dispose()
    if not self.isFromAchiRank then
        FriendInfoUtil:onPanelDispose()
    end
    BasePanel.dispose(self)
end

return MainPanel