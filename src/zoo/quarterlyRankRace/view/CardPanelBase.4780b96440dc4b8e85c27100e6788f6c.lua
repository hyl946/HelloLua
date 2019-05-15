require "zoo.panel.basePanel.BasePanel"
local UIHelper = require 'zoo.panel.UIHelper'
local Thumb = require 'zoo.panel.component.common.Thumb'
local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'

local CardPanelBase = class(BasePanel)

function CardPanelBase:ctor()
end

function CardPanelBase:init()
	BasePanel.init(self, self.ui)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTapped()
	end)

	self:initPartTop()
	self:initPartBottom()
end

function CardPanelBase:initPartTop()
	self.partTopUI = self.ui:getChildByName("partTop")
	local profile = self.data.profile
	--name
    UIHelper:setUserName(self.partTopUI:getChildByName("name"), profile.name)

	--head
    if not self.data.isSelf and profile.headFrame then
        profile.headFrames = {
            {id = profile.headFrame, obtainTime = 0, expireTime = 0}
        }
    end
    UIHelper:loadUserHeadIcon(self.partTopUI:getChildByName("avatarPlaceholder"), profile, true)

    --address sex age constellation
    local barAddrUI = self.partTopUI:getChildByName("barAddr")
    local barAddrLabel = barAddrUI:getChildByName("label")
    if profile.secret then
        barAddrLabel:setString("未知")
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

        local address = profile.location or ""
		address = string.gsub(address, '#', ' ')
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
        str = TextUtil:ensureTextWidth(str, barAddrLabel:getFontSize(), barAddrLabel:getDimensions())
        barAddrLabel:setString(str)
    end

    --level
    local barLevelUI = self.partTopUI:getChildByName("barLevel")
    UIHelper:addBitmapTextByIcon(barLevelUI:getChildByName("icon"), "第"..self.data.level.."关", 'fnt/addfriend4.fnt', 'A14A0E', 1.2, {x = 10})
    --star
    local barStarUI = self.partTopUI:getChildByName("barStar")
	UIHelper:addBitmapTextByIcon(barStarUI:getChildByName("icon"), self.data.star, 'fnt/addfriend4.fnt', 'A14A0E', 1.2, {x = 10})

    --thumb icon
    self.thumb = Thumb:create(nil, nil, nil, nil, 0.8)
    self.partTopUI:addChild(self.thumb)
    self.thumb:setPosition(ccp(545, -30))
    self:setThumbNum(self.data.thumbsUpCount)
end

function CardPanelBase:setThumbNum(num)
    local numStr = tostring(num)
    if num >= 100000000 then
        numStr = math.floor(num*10*0.00000001)*0.1 .. "亿"
    elseif num >= 10000 then
        numStr = math.floor(num*10*0.0001)*0.1 .. "万"
    end
    self.thumb:setText(numStr)
end

function CardPanelBase:initPartBottom()
	self.partBottomUI = self.ui:getChildByName("partBottom")
	UIHelper:addBitmapTextByIcon(self.partBottomUI:getChildByName("iconWeek"), "x"..self.data.weekHighest, 'fnt/addfriend4.fnt', 'A14A0E', 1.2, {x = 10, y = 3})
	UIHelper:addBitmapTextByIcon(self.partBottomUI:getChildByName("iconSingle"), "x"..self.data.singleHighest, 'fnt/addfriend4.fnt', 'A14A0E', 1.2, {x = 10, y = 3})

	local labelDanUI = self.partBottomUI:getChildByName("label3")
	local labelDanPos = labelDanUI:getPosition()
	local labelDanSize = labelDanUI:getContentSize()
    local lvFlagUI = UIHelper:createUI('ui/RankRace/MainPanel.json', '2018_s1_rank_race/rank_level/rankLvBar')
    lvFlagUI:setPosition( ccp(labelDanPos.x + labelDanSize.width + 5, labelDanPos.y + 5) )
    self.partBottomUI:addChild(lvFlagUI)

    local lvFlagLabel = lvFlagUI:getChildByName("label")
    local lvFlagBg = lvFlagUI:getChildByName("bg")
    local dan = math.clamp(self.data.danHighest or 1, 1, 10)
    for i=1,10 do
	    local label = lvFlagLabel:getChildByName(i.."")
	    label:setVisible(i == dan)
    end
    local bgIndex = math.floor((dan - 1) / 3) + 1
    for i=1,4 do
	    local bg = lvFlagBg:getChildByName(i.."")
	    bg:setVisible(i == bgIndex)
    end

    if not self.data.isSelf and self.data.canThumbsUp then
	    self.btnLike = ButtonIconsetBase:create(self.ui:getChildByName("btnLike"))
	    self.btnLike:addEventListener(DisplayEvents.kTouchTap,function()
	        self:onBtnLikeTap()
	    end)
	    self.btnLike:setString("赞")
	    self.btnLike:setIconByFrameName("common_icon/sns/icon_zan0000")
	else
		self.ui:getChildByName("btnLike"):setVisible(false)
    end

    self.likeNum = self.data.thumbsUpCount
end

function CardPanelBase:onBtnLikeTap()
    self.btnLike:setEnabled(false)

    local function refreshThumbNum()
	    if self.isDisposed then return end
        self:setThumbNum(self.data.thumbsUpCount)
    end

    local function onSuccess(data)
        if self.isDisposed then return end
        RankRaceMgr.getInstance():onThumbSuccess(self.data.rankType, self.data.uid, self.data.thumbsUpCount + 1)
        self.btnLike:setVisible(false)

        local anim = gAnimatedObject:createWithFilename('gaf/thumb/friend_like.gaf')
        anim:playSequence("explode", false, true, ASSH_RESTART)
		anim:setSequenceDelegate("explode", refreshThumbNum)
		local pos = self.thumb:getThumbIconPos(self.ui)
		anim:setPosition(ccp(pos.x + 25, pos.y - 5))
		anim:start()
        self.ui:addChild(anim)
    end

    local function onFail()
        if self.isDisposed then return end
        self.btnLike:setVisible(true)
    end

    FriendInfoUtil:req_like(self.data.uid, onSuccess, onFail)
end

function CardPanelBase:popout()
    PopoutManager:sharedInstance():add(self, true)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self.allowBackKeyTap = true
end

function CardPanelBase:onCloseBtnTapped()
    self:removePopout()
end

function CardPanelBase:removePopout()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

return CardPanelBase