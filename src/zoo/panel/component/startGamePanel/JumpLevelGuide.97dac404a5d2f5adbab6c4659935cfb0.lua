local JumpLevelGuide = class()

function JumpLevelGuide:create(parentPanel, endCallBack , levelId)
	local guide = JumpLevelGuide.new()
	guide:init(parentPanel, endCallBack , levelId )
	return guide
end

--优化开始面板UI，整合跳关与好友代打icon，去掉原添加好友气泡。
function JumpLevelGuide:shouldShowTwoBtnType(  )

    local num = 0
    local showJump = JumpLevelManager:getInstance():shouldShowJumpLevelIcon(self.levelId)
    local showAsk = AskForHelpManager.getInstance():shouldShowFuncIcon(self.levelId)
    if showJump and showIcon then
        return 3
    elseif showJump then
        return 2
    elseif showAsk then
        return 1
    end
    return num
end
function JumpLevelGuide:init(parentPanel, endCallBack , levelId)
    self.parentPanel = parentPanel
    self.endCallBack = endCallBack
    self.levelId = levelId 
    if self.parentPanel.ui == nil or self.parentPanel.ui.isDisposed then return end
    local winSize = Director:sharedDirector():getWinSize()

    CCUserDefault:sharedUserDefault():setBoolForKey("star.schievement.guide", true)
    CCUserDefault:sharedUserDefault():flush()
    self.ui = Layer:create()
    self.guideBg = LayerColor:createWithColor(ccc3(0, 0, 0), winSize.width, winSize.height)
    self.guideBg:setOpacity(200)
    self.guideBg:setPosition(ccp(0, 0))
    self.guideBg:setTouchEnabled(true, 0, true)
    self.guideBg:addEventListener(DisplayEvents.kTouchTap, function() self:nextGuide() end)
    self.ui:addChild(self.guideBg)

    self.levelFlag  = MetaManager:getInstance():getLevelDifficultFlag_ForStartPanel( levelId )
    if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
        FrameLoader:loadArmature('skeleton/jump_level_btn_animation_purple', 'jump_level_btn_animation_purple')
    elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
        FrameLoader:loadArmature('skeleton/jump_level_btn_animation_blue', 'jump_level_btn_animation_blue')
    else
        FrameLoader:loadArmature('skeleton/jump_level_btn_animation', 'jump_level_btn_animation')
    end

    local armature = ArmatureNode:create('skip')

    local slot = armature:getSlot("skipbubble")
    if slot then
        local spriteBtn = nil
        spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/jump_level_icon_new0000" )
        spriteBtn:setPositionXY(60,-50)
        local sprite = Sprite:createEmpty()
        sprite:addChild(spriteBtn)
        slot:setDisplayImage(sprite.refCocosObj)
    end

    armature:playByIndex(0, 1)
    armature:update(0.001)
    armature:stop()
    local areaPos = self.parentPanel.ui:getChildByName("jump_level_area"):getPosition()
    local pos = self.parentPanel.ui:convertToWorldSpace(areaPos)
    self.jumpLevelAreaPos = {x = pos.x + 4, y = pos.y + 42}  --手动调整
    armature:setPositionXY(self.jumpLevelAreaPos.x,self.jumpLevelAreaPos.y)
    self.ui:addChild(armature)
    armature:playByIndex(0, 1)
    local scene = Director:sharedDirector():run()
    scene:addChild(self.ui, SceneLayerShowKey.POP_OUT_LAYER)
    self.guideStep = 0
    self:nextGuide()

end

local GuideCfg = {{
                    animKey="movein_tutorial_4", 
                    npcPos = ccp(528, 798), 
                    tipKey="jump.level.guide.minLevel.tip", 
                    tipPos = ccp(460, 608),
                    showTime = 4,
                   }
                }

function JumpLevelGuide:nextGuide()

    if self.parentPanel.ui == nil or self.parentPanel.ui.isDisposed then
        if self.ui ~= nil and self.ui:getParent() ~= nil and not self.ui.isDisposed then
            self.ui:removeFromParentAndCleanup(true)
        end
        return 
    end

    if self.curStepTimeOutID ~= nil then
        cancelTimeOut(self.curStepTimeOutID)
        self.curStepTimeOutID = nil
    end

    if self.guideStep > 0 then
        if self.npcGuideAnim ~= nil and self.npcGuideAnim:getParent() ~= nil and not self.npcGuideAnim.isDisposed then
            self.npcGuideAnim:stop()
            self.npcGuideAnim:removeFromParentAndCleanup(true)
        end
    end

    self.guideStep = self.guideStep + 1
    local curStep = self.guideStep
    if self.guideStep > #GuideCfg then
        self:guideEnd()
        return
    end
    local cfg = GuideCfg[self.guideStep]
    self.npcGuideAnim = ArmatureNode:create(cfg.animKey)
    self.npcGuideAnim:playByIndex(0, 1)
    self.npcGuideAnim:update(0.001)
    self.npcGuideAnim:stop()
    self.npcGuideAnim:playByIndex(0, 0)
    if not self.jumpLevelAreaPos then
        self.npcGuideAnim:setPosition(cfg.npcPos)
    else
        self.npcGuideAnim:setPosition(ccp(cfg.npcPos.x, self.jumpLevelAreaPos.y+190))
    end
    self.ui:addChild(self.npcGuideAnim)

    if self.guideTip == nil then
        local builder = InterfaceBuilder:createWithContentsOfFile("ui/common_ui.json")
        self.guideTip = builder:buildGroup("ui_tip/ui_tip_c_1")
        local fntFile = "fnt/tutorial_white.fnt"
        self.guideTipLable = BitmapText:create('', fntFile)
        self.guideTipLable:setPreferredSize(500, 120)
        self.guideTipLable:setPosition(ccp(-172, 110))
        self.guideTip:addChild(self.guideTipLable)
        self.ui:addChild(self.guideTip)
    end

    self.guideTipLable:setString(localize(cfg.tipKey, {n = "\n"}))
    if not self.jumpLevelAreaPos then
      self.guideTip:setPosition(cfg.tipPos)
    else
      self.guideTip:setPosition(ccp(cfg.tipPos.x, self.jumpLevelAreaPos.y+20))
    end

    self.curStepTimeOutID = setTimeOut(function() 
        if curStep == self.guideStep then 
            self:nextGuide() 
        end 
        end, cfg.showTime)
end

function JumpLevelGuide:guideEnd( ... )
    if self.ui ~= nil and self.ui:getParent() ~= nil and not self.ui.isDisposed then
        self.ui:removeFromParentAndCleanup(true)
        if self.endCallBack ~= nil then self.endCallBack() end
    end
end

return JumpLevelGuide