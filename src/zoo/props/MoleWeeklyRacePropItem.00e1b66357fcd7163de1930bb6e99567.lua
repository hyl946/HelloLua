require 'zoo.props.PropListItem'
require "zoo.animation.BossAnimation"
local WeeklyDazhaoBuyPanel = require "zoo.modules.weekly2017s1.WeeklyDazhaoBuyPanel"

MoleWeeklyRacePropItem = class(BaseUI)

function MoleWeeklyRacePropItem:create(propListAnimation)
    local instance = MoleWeeklyRacePropItem.new()
    instance:init(propListAnimation)
    return instance
end

function MoleWeeklyRacePropItem:init(propListAnimation)
    self.usedTimes = 0
    self.percent = 0
    self.energy = 0     --需要填充的能量，扣除了预先充能部分
    self.currentConfig = MoleWeeklyRaceConfig:genNewPropSkill()

    self.propListAnimation = propListAnimation
    self.controller = propListAnimation.controller
    self.icon = self:buildItemIcon()
    BaseUI.init(self, self.icon)
    self:setEnergy(0, false, 0)


    --锤子击打
    self.animHummerIsRun = false
    FrameLoader:loadArmature('skeleton/week_bossSkill')
    local animHummer = ArmatureNode:create('bossSkill/shininganime')
    animHummer:playByIndex(0)
    animHummer:update(0.001)
    animHummer:stop()
    animHummer:setPosition( ccp(0,0 ) )
    self:addChildAt(animHummer,11)
    animHummer:setVisible(false)
    self.animHummer = animHummer

    --大招无法使用提示
    local sp = Sprite:createWithSpriteFrameName("MoleWeekly_CanNotUseSkillTip.png")
    sp:setPosition( ccp(0,50) )
    sp:setVisible(false)
    self:addChild( sp )
    self.NotUseTip = sp

    if StartupConfig:getInstance():isLocalDevelopMode() then
        self:addDebugInfo()
    end
end

function MoleWeeklyRacePropItem:buildItemIcon()
    local icon = BossAnimation:buildItemIcon()
    return icon
end

function MoleWeeklyRacePropItem:resetConfig()
    self.currentConfig = MoleWeeklyRaceConfig:genNewPropSkill()
end

function MoleWeeklyRacePropItem:use(forceUsedCallback, dontCallback, forceUse)

--    local mainLogic = GameBoardLogic:getCurrentLogic()
--    if mainLogic and not mainLogic:getMoleWeeklyBossData() then
--        --不可以使用大招
--        self:ShotNotUseTip()
--        return false 
--    end

    local function localCallback( notUseEnergy, noReplayRecord)
        self.animPlayed = false
        if forceUsedCallback then forceUsedCallback() end
        
        if not dontCallback and self.controller and self.controller.springItemCallback then
            self.controller.springItemCallback( notUseEnergy, noReplayRecord)
        end

        self.usedTimes = self.usedTimes + 1
        self:setEnergy(0, true)     --更新加上prefill的部分
    end

    local function playMusic()
      GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyRaceProp)
    end

    local percentage = self.percent or 0

    local function releaseSkill( notUseEnergy, noReplayRecord)
        --setTimeOut(function() playMusic() end, 0.6)
        -- playMusic()
        
        -- -- TODO:打点？
        -- --[[
        -- local operator = 1
        -- if forceUse then 
        --     operator = 3 
        -- elseif noReplayRecord then 
        --     operator = 2
        -- end
        -- DcUtil:UserTrack({ category='weeklyrace', sub_category='weeklyrace_mole_use_special_prop' , level_id = self.propListAnimation.levelId, operator = operator})
        -- ]]--
        -- self:cancelFlyAnim()
        -- BossAnimation:playUseAnimation(function ()
            localCallback( notUseEnergy, noReplayRecord)
        -- end)
        -- self:setEnergy(0, true)
    end

    if percentage >= 1 then
        releaseSkill(false, false)
        return true
    else
        local panel = WeeklyDazhaoBuyPanel:create(percentage, function ()
            --兼容闪退恢复 买成功直接强制加上
            ReplayDataManager:addReplayStep({prop = GamePropsType.kMoleWeeklyRaceSPProp})
            SnapshotManager:catchUseProp( {prop = GamePropsType.kMoleWeeklyRaceSPProp} )
            releaseSkill(false, true)
        end)
        panel:popout()
    end

    return false
end

function MoleWeeklyRacePropItem:setEnergy(energy, playAnim, theCurMoves)
    self.energy = math.min(energy, self:getTotalEnergy())
    -- if _G.isLocalDevelopMode then printx(0, "usedTimes: ", self.usedTimes) end
    -- if _G.isLocalDevelopMode then printx(0, "total energy: ", self:getTotalEnergy()) end
    self:updateDebugInfo()
    self:setPercent((self.energy + self:getPrefillEnergyAmount()) / self:getDisplayTotalEnergy(), playAnim, theCurMoves)
end

function MoleWeeklyRacePropItem:setPercent(percent, playAnim, theCurMoves)
    -- printx(11, "++++  +++ propItem, setPercent:", debug.traceback())
    if percent > 1 then percent = 1 end
    if percent < 0 then percent = 0 end
    self.percent = percent
    if self.icon then
        self.icon:setPercent(percent, playAnim)
    end

    if self.percentChangeCallback then 
        self.percentChangeCallback(percent)
    end

    if percent >=1 then
        self:PlayFullAnim()
    else
        self:StopFullAnim()
    end
end

function MoleWeeklyRacePropItem:setPercentChangeCallback(callback)
    self.percentChangeCallback = callback
end

function MoleWeeklyRacePropItem:playFlyNutAnim(delay)
    printx(11, ". . . . .  mole... Fly nut !!!!")
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

function MoleWeeklyRacePropItem:cancelFlyAnim()
    if self.icon then
        self:stopActionByTag(999)
        self.icon:cancelFlyAnim(function () self.animPlaying = false end )
    end
end

--扣除预先充能部分后的总能量，因为外部引用的缘故，不另行改名了
function MoleWeeklyRacePropItem:getTotalEnergy()
    local totalNeedEnergy = self:getDisplayTotalEnergy() - self:getPrefillEnergyAmount()
    return totalNeedEnergy
end

function MoleWeeklyRacePropItem:getPrefillEnergyAmount()
    local displayTotalEnergy = self:getDisplayTotalEnergy()
    local prefillEnergyAmount = displayTotalEnergy * self.currentConfig.preFillPercent
    return prefillEnergyAmount
end

--显示上的总能量（= 预先充能的部分 + 真实需要玩家获得的能量）
function MoleWeeklyRacePropItem:getDisplayTotalEnergy()
    return self.currentConfig.maxVal
end

function MoleWeeklyRacePropItem:isItemRequireConfirm()
    return false
end

function MoleWeeklyRacePropItem:getItemCenterPosition()
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

function MoleWeeklyRacePropItem:addDebugInfo()
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

function MoleWeeklyRacePropItem:updateDebugInfo()
    if self.debugInfoLabel and self.debugInfoLabel.text then
        self.debugInfoLabel.text:setString((self.energy + self:getPrefillEnergyAmount()).." / "..self:getDisplayTotalEnergy())
    end
end

function MoleWeeklyRacePropItem:getPropSkillConfig()
    return self.currentConfig
end


function MoleWeeklyRacePropItem:PlayFullAnim()
    
    if not self.animHummer then
        return
    end

    if self.animHummerIsRun then
        return
    end

    self.animHummerIsRun = true

    local animHummer = self.animHummer
	function PlayAnim()
        animHummer:play("skilleffect", 1)
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create( PlayAnim ) )
    array:addObject( CCDelayTime:create(3) )
	animHummer:runAction( CCRepeatForever:create( CCSequence:create(array) ) )
    animHummer:setVisible(true)
end

function MoleWeeklyRacePropItem:StopFullAnim()
    
    if not self.animHummer then
        return
    end

    self.animHummerIsRun = false

    local animHummer = self.animHummer
    animHummer:setVisible(false)
end

function MoleWeeklyRacePropItem:ShotNotUseTip()

    if self.NotUseTip:isVisible() then
        return
    end
    
    function callend()
        self.NotUseTip:setVisible(false)
    end

    if self.NotUseTip then
        self.NotUseTip:setVisible(true)
        self.NotUseTip:setPosition( ccp(0,50) )
        self.NotUseTip:setOpacity( 150 )

        local array1 = CCArray:create()
        array1:addObject( CCFadeIn:create(0.2)  )
        array1:addObject( CCMoveBy:create(0.2, ccp(0, 15 )) )

        local array3 = CCArray:create()
        array3:addObject( CCMoveBy:create(0.2, ccp(0, 15 )) )
        array3:addObject( CCFadeOut:create(0.2) )
    
        local array = CCArray:create()
        array:addObject( CCSpawn:create(array1)  )
        array:addObject( CCDelayTime:create(0.5)  )
        array:addObject( CCSpawn:create(array3)  )
        array:addObject(CCCallFunc:create(callend))

        self.NotUseTip:runAction( CCSequence:create( array ) )
    end
end