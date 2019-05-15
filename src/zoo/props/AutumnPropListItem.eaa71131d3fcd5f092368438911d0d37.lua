require 'zoo.props.PropListItem'
require "zoo.animation.BossAnimation"
local WeeklyDazhaoBuyPanel = require "zoo.modules.weekly2017s1.WeeklyDazhaoBuyPanel"

AutumnPropListItem = class(BaseUI)

function AutumnPropListItem:create(propListAnimation)
    local instance = AutumnPropListItem.new()
    instance:init(propListAnimation)
    return instance
end

function AutumnPropListItem:init(propListAnimation)
    self.usedTimes = 0
    self.percent = 0
    self.energy = 0
    self.propListAnimation = propListAnimation
    self.controller = propListAnimation.controller
    self.icon = self:buildItemIcon()
    BaseUI.init(self, self.icon)
    self:setPercent(0, false, 0)

    if StartupConfig:getInstance():isLocalDevelopMode() then
        self:addDebugInfo()
    end
end

function AutumnPropListItem:buildItemIcon()
    local icon = BossAnimation:buildItemIcon()
    return icon
end

function AutumnPropListItem:use(forceUsedCallback, dontCallback, forceUse)
    local function localCallback(noReplayRecord)

        self.animPlayed = false
        if forceUsedCallback then forceUsedCallback() end
        
        if not dontCallback and self.controller and self.controller.springItemCallback then
            self.controller.springItemCallback(false, noReplayRecord)
        end

        self.usedTimes = self.usedTimes + 1
    end

    local function playMusic()
      GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyRaceProp)
    end

    local percentage = self.percent or 0

    local function releaseDazhao(noReplayRecord)
        -- setTimeOut(function() playMusic() end, 0.6)
        playMusic()
        
        local operator = 1
        if forceUse then 
            operator = 3 
        elseif noReplayRecord then 
            operator = 2
        end
        DcUtil:UserTrack({ category='weeklyrace', sub_category='weeklyrace_spring_2018_use_skill' , level_id = self.propListAnimation.levelId, operator = operator})
        self:cancelFlyAnim()
        BossAnimation:playUseAnimation(function ()
            localCallback(noReplayRecord)
        end)
        self:setEnergy(0, true)
    end
    if percentage >= 1 then
        releaseDazhao(false)
        return true
    else
        local panel = WeeklyDazhaoBuyPanel:create(percentage, function ()
            --兼容闪退恢复 买成功直接强制加上
            ReplayDataManager:addReplayStep({prop = GamePropsType.kSpringFirework})
            SnapshotManager:catchUseProp( {prop = GamePropsType.kSpringFirework} )
            releaseDazhao(true)
        end)
        panel:popout()
    end


    -- local content = ResourceManager:sharedInstance():buildGroup('bagItemTipContent_two')
    -- local desc = content:getChildByName('desc')
    -- local title = content:getChildByName('title')
    -- local desc_two = content:getChildByName('desc_two')

    -- title:setString(Localization:getInstance():getText("2016_weeklyrace.summer.drink.title"))
    -- local originSize = desc:getDimensions()
    -- desc:setDimensions(CCSizeMake(originSize.width, 0))
    -- desc:setString(Localization:getInstance():getText("2016_weeklyrace.summer.drink.desc", {n1 = self:getTotalEnergy() -self.energy, br = '\n'})) -- TODO
    
    -- local newSize = desc:getContentSize()
    -- local oriPos = desc_two:getPosition()
    -- local posDelta = originSize.height - newSize. height - 15
    -- desc_two:setPosition(ccp(oriPos.x, oriPos.y + posDelta))
    -- desc_two:setString(Localization:getInstance():getText("weeklyrace.winter.drink.tip"))

    -- local tip = BubbleTip:create(content, kSpringPropItemID, 5)
    -- tip:show(self.icon.normal_bg:getGroupBounds())
    return false
end

function AutumnPropListItem:setEnergy(energy, playAnim, theCurMoves)
    self.energy = energy
    -- if _G.isLocalDevelopMode then printx(0, "usedTimes: ", self.usedTimes) end
    -- if _G.isLocalDevelopMode then printx(0, "total energy: ", self:getTotalEnergy()) end
    self:updateDebugInfo()
    self:setPercent(self.energy / self:getTotalEnergy(), playAnim, theCurMoves)
end

function AutumnPropListItem:setPercent(percent, playAnim, theCurMoves)
    if percent > 1 then percent = 1 end
    if percent < 0 then percent = 0 end
    self.percent = percent
    if self.icon then
      self.icon:setPercent(percent, playAnim)
    end
    if self.percentChangeCallback then 
        self.percentChangeCallback(percent)
    end
end

function AutumnPropListItem:setPercentChangeCallback(callback)
    self.percentChangeCallback = callback
end

function AutumnPropListItem:playFlyNutAnim(delay)
    if self.percent == 1 and not self.animPlayed then
        self.animPlayed = true
        self.animPlaying = true
        if not delay then delay = 2 end
        local action = CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(
            function() 
                if self.icon then 
                    self.icon:playFlyNut( function () self.animPlaying = false end ) 
                end 
            end))
        action:setTag(999)
        self:runAction(action)
    end
end

function AutumnPropListItem:cancelFlyAnim()
    if self.icon then
        self:stopActionByTag(999)
        self.icon:cancelFlyAnim(function () self.animPlaying = false end )
    end
end

function AutumnPropListItem:getTotalEnergy()
    if self.usedTimes + 1< #SpringFireworkTotal then
        return SpringFireworkTotal[self.usedTimes + 1]
    else
        return SpringFireworkTotal[#SpringFireworkTotal]
    end
end

function AutumnPropListItem:isItemRequireConfirm()
    return false
end

function AutumnPropListItem:getItemCenterPosition()
  -- local item = self.icon.bubble
  -- local itemPos = item:getPosition()
  -- local bounds = item:getGroupBounds()
  -- local x = itemPos.x + bounds.size.width/2
  -- local y = itemPos.y + bounds.size.height/2
  -- local position = ccp(x, y)
  local position = self.icon:convertToWorldSpace(self.icon.bubble:getPosition())
  return position
  -- return self.icon:convertToNodeSpace(position)
end

function AutumnPropListItem:addDebugInfo()
    local label = LayerColor:createWithColor(ccc3(255, 255, 255), 70, 20)

    local text = TextField:create("0/0", nil, 20)
    text:setColor(ccc3(255, 0, 0))
    text:setAnchorPoint(ccp(0.5, 0.5))
    text:ignoreAnchorPointForPosition(false)
    text:setPosition(ccp(35, 10))
    label:addChild(text)

    label.text = text

    label:setPosition(ccp(-35, -35))
    self:addChild(label)
    self.debugInfoLabel = label
    self:updateDebugInfo()
end

function AutumnPropListItem:updateDebugInfo()
    if self.debugInfoLabel and self.debugInfoLabel.text then
        self.debugInfoLabel.text:setString(self.energy.." / "..self:getTotalEnergy())
    end
end
