require "zoo.panel.basePanel.BasePanel"
require "zoo.baseUI.ButtonWithShadow"
local UIHelper = require 'zoo.panel.UIHelper'

local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"
local PigYearView = require "zoo.localActivity.PigYear.PigYearView"

local SpringFestival2019SkillPanel = class(BasePanel)

local SkillNameList = {
    "投掷特效","分数加成","四连爆炸","魔力特效"
}

local SkillPosOffset = {
    ccp(5,0), ccp(5,0),ccp(3,-4),ccp(0,0)
}

local SkillShowList = {1,3,4}

function SpringFestival2019SkillPanel:create(gameBoardLogic)
	local panel = SpringFestival2019SkillPanel.new()
	if panel:init() then
		return panel
	else
		panel = nil
		return nil
	end
end

function SpringFestival2019SkillPanel:init()

	-- 初始化面板
    local ui = UIHelper:createUI("flash/SpringFestival_2019/SpringFestival_2019.json", "SpringFestival_2019/SkillBaseCtrl")
    BasePanel.init(self, ui)

    self.panelName = "SpringFestival2019SkillPanel"

    self.bHidding = false
    self.bUseSkilling = false
	-- 获取控件
	self.skillCtrl = self.ui:getChildByName("skillCtrl")
--    UIUtils:setTouchHandler(self.skillCtrl, function ( ... )
--        --点技能区域不关闭
--    end)

    self.useSkillBusy = false
    self.SkillList = {}
    for i=1, #SkillShowList do 
        local SkillId = SkillShowList[i]

        self.SkillList[SkillId] = self.skillCtrl:getChildByName("skill"..i)

        self.SkillList[SkillId].Title = self.SkillList[SkillId]:getChildByName("title")
        self.SkillList[SkillId].bubble = self.SkillList[SkillId]:getChildByName("bubble")

        --title
        self.SkillList[SkillId].Title:setString( SkillNameList[SkillId] )

        --skillicon
        local icon_sprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/Skill"..SkillId.."0000")
        icon_sprite:setPosition( ccp(101/2+SkillPosOffset[i].x,101/2+SkillPosOffset[i].y) )
        self.SkillList[SkillId].bubble:addChild( icon_sprite )

        --redPoint
        local redPoint_sprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/redPoint0000")
        redPoint_sprite:setPosition( ccp(101/2+41-6,101/2+41-8) )
        self.SkillList[SkillId].bubble:addChild( redPoint_sprite )
        redPoint_sprite:setVisible(false)
        self.SkillList[SkillId].redPoint_sprite = redPoint_sprite

        local poingNumLabel = BitmapText:create( "" ,"fnt/prop_name.fnt")
        poingNumLabel:setPosition( ccp(16,20) )
        poingNumLabel:setScale(0.6)
        poingNumLabel:setAnchorPoint(ccp(0.5, 0.5))
        redPoint_sprite:addChildAt(poingNumLabel,1)
        self.SkillList[SkillId].poingNumLabel = poingNumLabel

        --bubble click
        UIUtils:setTouchHandler( self.SkillList[SkillId], function ( ... )
            --点bubble也释放技能
            if not self.useSkillBusy then
                self:useSkill( SkillId )
            end
        end)

        --skillbtn
        local btn = ButtonIconsetBase:create( self.SkillList[SkillId]:getChildByName("btn")  )
        btn:setColorMode(kGroupButtonColorMode.green)
        btn:setIconByFrameName("SpringFestival_2019res/piggyi_"..SkillId.."0000")
        btn:setString( "" )
        btn:addEventListener(DisplayEvents.kTouchTap, function ()
--            btn:setEnabled(false)
            if not self.useSkillBusy then
    	        self:useSkill( SkillId )
            end
	    end)
        self.SkillList[SkillId].btn = btn
    end

    --遮罩
    local wSize = CCDirector:sharedDirector():getWinSize()
    local trueMaskLayer = Layer:create()
    local width = wSize.width*2
    local height = wSize.height*2
--    local trueMaskLayer = LayerColor:createWithColor(ccc3(255,0,0), width, height)
    trueMaskLayer:setContentSize(CCSizeMake( width, height ))
    trueMaskLayer:setPosition(ccp(550/2-width/2,-220/2-height/2))
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch() 
        if self.bUseSkilling then return end
        --任意位置关闭
        self:HideSkillCtrl() 
    end
    trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) 
    self.ui:addChildAt( trueMaskLayer, 1 )

    --显示更新
    self:updateSkillInfo()

	return true
end

function SpringFestival2019SkillPanel:updateSkillInfo()
    if self.isDisposed then return end

    local GemNumList = SpringFestival2019Manager.getInstance():getGemNumList()
    for i=1, #SkillShowList do 
        local SkillId = SkillShowList[i]

        local curHave = GemNumList[SkillId] or 0
        local cost = PicYearMeta.SkillCost[SkillId] or 50
        local needStep = PicYearMeta.SkillStepNeed[SkillId]
        local curStep = SpringFestival2019Manager.getInstance():getUseMove()

        local maxCanUseNum = math.floor(curHave/cost)

        local ShowCurHave = ""..curHave
        if curHave > 999 then
            curHave = 999

            ShowCurHave = "999+"
        end

        self.SkillList[SkillId].btn:setString( ShowCurHave.."/"..cost  )
        InterfaceBuilder:centerInterfaceInbox2( self.SkillList[SkillId].btn.label, self.SkillList[SkillId].btn.labelRect )
        self.SkillList[SkillId].btn:setEnabled(false)
        self.SkillList[SkillId].bCanUse = false
        self.SkillList[SkillId].bCanOpenBagPanel = false

        if maxCanUseNum > 0 then
            local showStr = ""..maxCanUseNum
            if maxCanUseNum > 99 then showStr = "99+" end

            self.SkillList[SkillId].redPoint_sprite:setVisible(true)
            self.SkillList[SkillId].poingNumLabel:setText(showStr)
        else
            self.SkillList[SkillId].redPoint_sprite:setVisible(false)
        end

        local useSkillList = SpringFestival2019Manager.getInstance():getUseSkillList()
        if not useSkillList[SkillId] then
            if SkillId == 2  then
                if SpringFestival2019Manager.getInstance().scoreAddPercent > 0 then
                elseif curStep>= needStep then
                    if curHave >= cost then
                        self.SkillList[SkillId].bCanUse = true
                    end
                    self.SkillList[SkillId].btn:setEnabled(true)
                    self.SkillList[SkillId].bCanOpenBagPanel = true
                end
            elseif curStep>= needStep then
                if curHave >= cost then
                    self.SkillList[SkillId].bCanUse = true
                end
                self.SkillList[SkillId].btn:setEnabled(true)
                self.SkillList[SkillId].bCanOpenBagPanel = true
            end
        end
    end
end

function SpringFestival2019SkillPanel:_close()
    if self.exitCallback then self.exitCallback() end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true )
end

function SpringFestival2019SkillPanel:onCloseBtnTapped()
    self:_close()
end

function SpringFestival2019SkillPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, false)
	self.allowBackKeyTap = false
    self.panelName = "SpringFestival2019SkillPanel"
    self:popoutShowTransition()

    self:updateSkillInfo()

    GameGuide:sharedInstance():tryStartGuide()
end

function SpringFestival2019SkillPanel:popoutShowTransition()

    self.bHidding = false
    self.useSkillBusy = false
    self.bUseSkilling = false

    --适配位置到技能
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local rightPropList = mainLogic.PlayUIDelegate.propList.rightPropList
    local springItem = rightPropList.springItem
    local SpringPos = springItem:getPosition()
    local WorldSpace = springItem:getParent():convertToWorldSpace( ccp(SpringPos.x-5,SpringPos.y+50) )

    local NodeSpace = self.skillCtrl:getParent():convertToNodeSpace( WorldSpace )
    self.skillCtrl:setPosition( NodeSpace )

    self:updateSkillInfo()
    self:ShowSkillCtrl()
end

function SpringFestival2019SkillPanel:setExitCallback(callback)
	self.exitCallback = callback
end

function SpringFestival2019SkillPanel:ShowSkillCtrl()
    self.skillCtrl:setVisible(true)
	self.skillCtrl:setScale(0.01)

    local array = CCArray:create()
    array:addObject( CCScaleTo:create(0.1,1.1))
    array:addObject( CCScaleTo:create(0.05,0.9))
    array:addObject( CCScaleTo:create(0.05,1.05))
    array:addObject( CCScaleTo:create(0.05,1)  )
    array:addObject(CCCallFunc:create(callend))

    self.skillCtrl:stopAllActions()
    self.skillCtrl:runAction( CCSequence:create(array) )

    SpringFestival2019Manager.getInstance():setRightPropListOpen( true )
end


function SpringFestival2019SkillPanel:HideSkillCtrl()

    if self.bHidding then return end

    self.bHidding = true
    local function HideEndCall()
        self.bUseSkilling = false
        self.skillCtrl:setVisible(false)
        self:_close()
    end

	local array = CCArray:create()
    array:addObject( CCScaleTo:create(0.1, 0.01 )  )
    array:addObject(CCCallFunc:create(HideEndCall))

    self.skillCtrl:stopAllActions()
    self.skillCtrl:runAction( CCSequence:create(array) )

    SpringFestival2019Manager.getInstance():setRightPropListOpen( false )

    SpringFestival2019Manager.getInstance():ShowRedPointAndUpdate()
end

function SpringFestival2019SkillPanel:useSkill( SkillId )

    if SkillId < 1 or SkillId > 4 then return end 

    local GemNumList = PigYearLogic:getGemNums()
    local curHave = GemNumList[SkillId] or 0
    local cost = PicYearMeta.SkillCost[SkillId] or 50

    if not self.SkillList[SkillId].bCanUse then
--        CommonTip:showTip("宝石不足！")

        --福袋开启界面
        if self.SkillList[SkillId].bCanOpenBagPanel then
            self:ShowBagPanel( SkillId )
        else
            local needStep = PicYearMeta.SkillStepNeed[SkillId]
            local curStep = SpringFestival2019Manager.getInstance():getUseMove()
            local useSkillList = SpringFestival2019Manager.getInstance():getUseSkillList()

            if not useSkillList[SkillId] then
                if curStep < needStep then
                    local step = needStep - curStep
                    CommonTip:showTip("再走"..step.."步可以使用了！")
                elseif curStep > needStep then
                    CommonTip:showTip("宝石不足！")
                end
            else
                CommonTip:showTip("本局已使用")
            end
        end
--        self:HideSkillCtrl()
        return --测试先去掉可以走到技能
    end

    local mainLogic = GameBoardLogic:getCurrentLogic()
    if not mainLogic then return end 

    local bubble = self.SkillList[SkillId].bubble
    local bubblePos = bubble:getPosition()
    local WorldSpace = bubble:getParent():convertToWorldSpace( ccp(bubblePos.x,bubblePos.y) )

    local bUseSucess = false
    if SkillId == 1 then
        bUseSucess = self:useSkill_1( WorldSpace )
    elseif SkillId == 2 then
        bUseSucess = self:useSkill_2( WorldSpace )
    elseif SkillId == 3 then
        bUseSucess = self:useSkill_3( WorldSpace )
    elseif SkillId == 4 then
        bUseSucess = self:useSkill_4( WorldSpace )
    end

    if bUseSucess then
        --使用道具之前记录恢复数据
        mainLogic.saveRevertData = mainLogic:getSaveDataForRevert()

        --禁用回退道具 1回合 
        local item = mainLogic.PlayUIDelegate.propList:findItemByItemID(GamePropsType.kBack)
        if item then
            item:lock(true)
            item.canNotUseThisSkillCD = 2
        end

        --replay
        if mainLogic.replayMode == ReplayMode.kNone or mainLogic.replayMode == ReplayMode.kNormal then
            local skillPropID = GamePropsType.kSpringSkill1 + SkillId -1
            ReplayDataManager:addReplayStep({prop = skillPropID})

        end

        --useskill
        SpringFestival2019Manager.getInstance():setUseSkill( SkillId )

        --cost
        SpringFestival2019Manager.getInstance():costGemNum( SkillId, PicYearMeta.SkillCost[SkillId] )

        local levelID = SpringFestival2019Manager.getInstance().levelID

        local FifthID = SkillId
        if SkillId == 3 then
            FifthID = 2
        elseif SkillId == 4 then
            FifthID = 3
        end
        SpringFestival2019Manager.getInstance():DCAddPlayID( "stage","5years_use_skill", FifthID, 1, levelID )
    else
        CommonTip:showTip("技能无可用位置释放！")
    end

--    self:HideSkillCtrl()
end

function SpringFestival2019SkillPanel:ShowBagPanel(  SkillId )
    --福袋开启界面
    local CurLevelCanGetInfo = SpringFestival2019Manager.getInstance():getCurLevelCanGetInfo()

    --
     local rightPropList = GameBoardLogic:getCurrentLogic().PlayUIDelegate.propList.rightPropList

    local worldPos = ccp(0,0)
    local  rect = CCSize(0,0)
    if rightPropList then
        local rightPropPos = rightPropList:getPosition()
        worldPos = rightPropList:getParent():convertToWorldSpace( ccp(rightPropPos.x+79/0.7,rightPropPos.y+45/0.7) )
    end
    --

    local luckyBagAllNum = PigYearLogic:getLuckyBagNum( nil, true )

    local pannelIndex = 2
    if luckyBagAllNum > 0 then
        pannelIndex = 2
    else
        pannelIndex = 3
    end

    local LuckyBagPanel = PigYearView:create(pannelIndex)
    LuckyBagPanel:setGemTargetPos(worldPos)

    LuckyBagPanel:ad(PopoutEvents.kRemoveOnce, function ( ... )
        SpringFestival2019Manager.getInstance():updateGemNumList()

        self.useSkillBusy = false
        self:updateSkillInfo()
    end)

    LuckyBagPanel:popout()

    local levelID = SpringFestival2019Manager.getInstance().levelID
    SpringFestival2019Manager.getInstance():DCAddPlayID( "stage","5years_use_skill", SkillId, pannelIndex, levelID )
end

function SpringFestival2019SkillPanel:ShowUseEffect( SkillID, AniEndCallback )

    self.bUseSkilling = true

    local bubble = self.SkillList[SkillID].bubble

    if not bubble then 
        if AniEndCallback then AniEndCallback() end  
        return 
    end

    local resName = 'SpringFestival2019_anim/ani_1'
	local arrowAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	bubble:addChild(arrowAnim)
	arrowAnim:setPosition(ccp(101/2,101/2))

    arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
            arrowAnim:removeAllEventListeners()
            arrowAnim:removeFromParentAndCleanup(true)
            if AniEndCallback then AniEndCallback() end 
            self:HideSkillCtrl()
        end)
    arrowAnim:play("a",1 )
end

function SpringFestival2019SkillPanel:useSkill_1( WorldSpace )

    local mainLogic = GameBoardLogic:getCurrentLogic()

    local infectList = SpringFestival2019Manager.getInstance():GetSkill1Info()
    if #infectList > 0 then

        local function RunAction()
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill1,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.canBeInfectItemList = infectList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        mainLogic:addPropAction( action )
	        mainLogic.fsm:changeState(mainLogic.fsm.usePropState)
        end
        self:ShowUseEffect( 1, RunAction )

        local http = OpNotifyOffline.new(false)

        local ID = PicYearMeta.ItemIDs.GEM_1
        local http = OpNotifyOffline.new(false)
        http:load(OpNotifyOfflineType.kFifthAnniversary, ""..ID..":"..PicYearMeta.SkillCost[1] )

        return true
    end

    return false
end

function SpringFestival2019SkillPanel:useSkill_2( WorldSpace ) 

    local function RunAction()
        local mainLogic = GameBoardLogic:getCurrentLogic()

	    local action = GameBoardActionDataSet:createAs(
		            GameActionTargetType.kPropsAction, 
		            GamePropsActionType.kSpringFestival2019_Skill2,
		            nil,
		            nil, 
		            GamePlayConfig_MaxAction_time)
        action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	    mainLogic:addPropAction( action )
	    mainLogic.fsm:changeState(mainLogic.fsm.usePropState)
    end
    self:ShowUseEffect( 2, RunAction )

   local ID = PicYearMeta.ItemIDs.GEM_2
   local http = OpNotifyOffline.new(false)
   http:load(OpNotifyOfflineType.kFifthAnniversary, ""..ID..":"..PicYearMeta.SkillCost[2] )


    return true
end

function SpringFestival2019SkillPanel:useSkill_3( WorldSpace )
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local PosList = SpringFestival2019Manager.getInstance():GetSkill3Info()

    if #PosList > 0 then

        local function RunAction()
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill3,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.PosList = PosList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        mainLogic:addPropAction( action )
	        mainLogic.fsm:changeState(mainLogic.fsm.usePropState)
        end

        self:ShowUseEffect( 3, RunAction )

        local ID = PicYearMeta.ItemIDs.GEM_3
        local http = OpNotifyOffline.new(false)
        http:load(OpNotifyOfflineType.kFifthAnniversary, ""..ID..":"..PicYearMeta.SkillCost[3] )

        return true
    end

    return false
end

function SpringFestival2019SkillPanel:useSkill_4( WorldSpace )
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local PosList = SpringFestival2019Manager.getInstance():GetSkill4Info()

    if #PosList > 0 then
        local function RunAction()
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill4,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.PosList = PosList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        mainLogic:addPropAction( action )
	        mainLogic.fsm:changeState(mainLogic.fsm.usePropState)
        end

        self:ShowUseEffect( 4, RunAction )

        local ID = PicYearMeta.ItemIDs.GEM_4
        local http = OpNotifyOffline.new(false)
        http:load(OpNotifyOfflineType.kFifthAnniversary, ""..ID..":"..PicYearMeta.SkillCost[4] )

        return true
    end

    return false
end

return SpringFestival2019SkillPanel