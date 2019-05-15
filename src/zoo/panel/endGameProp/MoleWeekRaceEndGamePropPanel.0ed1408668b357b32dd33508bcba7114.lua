require "zoo.panel.MoleWeekly.MoleWeeklyRaceManager"
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local CommonLogic = class()

function CommonLogic:create(ui)
	local logic = CommonLogic.new()
	logic.ui = ui
	logic:initData()
	logic:initUI()
end

function CommonLogic:initData()
--	self.maxKeyCount = 4
	self.ui.manager = MoleWeeklyRaceManager:getInstance()
    self.ui.manager:init()
end

function CommonLogic:initUI()
	self.ui.bar = self.ui.ui:getChildByName("bar")
	self.ui.tip1_tf = self.ui.ui:getChildByName("tip1_tf")
	self.ui.tip2_tf = self.ui.ui:getChildByName("tip2_tf")
	self.ui.tip3_tf = self.ui.ui:getChildByName("tip3_tf")
	self.ui.tip5 = self.ui.ui:getChildByName("_bubble")
	self.ui.moneyBar = self.ui.ui:getChildByName("moneyBar")
	self.ui.bg = self.ui.ui:getChildByName("bg")
    self.ui.all_btn = self.ui.ui:getChildByName("all_btn")
    self.ui.mole_bg = self.ui.ui:getChildByName("mole_bg")
    self.ui.mole_bg_down = self.ui.ui:getChildByName("mole_bg_down")
    self.ui.moleText2 = self.ui.ui:getChildByName("moleText2")

    self.ui.freeBtn = self.ui.ui:getChildByName("freeBtn")
    self.ui.buyBtn = self.ui.ui:getChildByName("buyBtn")
    self.ui.useBtn = self.ui.ui:getChildByName("useBtn")
    
    self.ui.freeBtn_group = GroupButtonBase:create( self.ui.freeBtn )
    self.ui.freeBtn_group:setString("免费")

    self.ui.bg:setVisible(false)
    self.ui.mole_bg:setVisible(false)
    self.ui.mole_bg_down:setVisible(false)
	self.ui.bar:setVisible(false)
	self.ui.tip5:setVisible(false)
	self.ui.all_btn:setVisible(false)
	self.ui.msgLabel_new1:setVisible(false)
	self.ui.msgLabel_new2:setVisible(false)
	self.ui.msgLabel:setVisible(false)
	self.ui.countdownLabel:setVisible(false)
	self.ui.buyButtonUI:setVisible(false)
	self.ui.useButtonUI:setVisible(false)
	self.ui.cryingAnimation:setVisible(false)
--	self.ui.moneyBar:setVisible(false) --当前拥有的金币数
	self.ui.closeBtn:setVisible(false)
	self.ui.tip1_tf:setVisible(false)
	self.ui.tip2_tf:setVisible(false)
	self.ui.tip3_tf:setVisible(false)
    self.ui.moleText2:setVisible(false)
    self.ui.freeBtn_group:setVisible(false)

--    self.ui.bg:setScaleX(500)
--	self.ui.bg:setScaleY(500)
--	self.ui.bg:setPosition(ccp(-1000, 1000))

    --背景选择
    local bBossAlive = self.ui.manager:getIsBossAlive()

--    if bBossAlive then

        self.ui.mole_bg:setVisible(true) 
        self.ui.mole_bg_down:setVisible(true) 
        self.ui.mole_bg_down:setOpacity(0)

        local winSize = Director:sharedDirector():getVisibleSize()
        local greyCover = LayerColor:create()
        greyCover:setColor(ccc3(0,0,0))
        greyCover:setOpacity(255*0.85)
        greyCover:setContentSize(CCSizeMake(10,10))
        greyCover:setPosition( ccp(5,0) )
        greyCover:setAnchorPoint( ccp(0.5,1) )
        greyCover:setScaleX(120)
	    greyCover:setScaleY(120)
        self.ui.mole_bg_down:addChild(greyCover)

        self.ui.bg:setVisible(false) 
--    else
--        self.ui.bg:setVisible(true) 
--        self.ui.bg:setOpacity(255*0.85)

--        self.ui.mole_bg:setVisible(false) 
--        self.ui.mole_bg_down:setVisible(false) 
--    end
    
    ----新添部分
    self.ui.moletarget = self.ui.ui:getChildByName("moletarget")
    self.ui.moleText = self.ui.ui:getChildByName("moleText")
    self.ui.moleText:changeFntFile('fnt/register2.fnt')
    self.ui.moleText:setAnchorPoint(ccp(0.5,0.5))
    local pos = self.ui.moleText:getPosition()
    self.ui.moleText:setPosition( ccp(pos.x+200/0.7, pos.y-10/0.7))

    --存按钮位置
    self.SaveMoleTextPos = self.ui.moleText:getPosition()
    self.SavefreeBtnPos = self.ui.freeBtn_group:getPosition()
    self.SavebuyBtnBtnPos = self.ui.buyBtn:getPosition()
    self.SaveuseBtnBtnPos = self.ui.useBtn:getPosition()
    self.SavemoneyBarPos = self.ui.moneyBar:getPosition()
    


    --目标
    self.ui.moletargetNum = self.ui.moletarget:getChildByName("num")
    self.ui.moletargetNum:changeFntFile('fnt/target_amount.fnt')
    self.ui.moletargetNum:setAnchorPoint(ccp(0.5,0.5))
    local pos = self.ui.moletargetNum:getPosition()
    self.ui.moletargetNum:setPosition( ccp(pos.x+38/0.7, pos.y-15/0.7))

    self.ui.closeBtn:setVisible(true)

    --
    local haveNum = EndGamePropManager.getInstance():getItemNum(self.ui.propId)

    local instance = RankRaceMgr:getExistedInstance()
    if instance then
        local bPlayAdd5 = instance.data:getIsPlayAdd5Anim()
        bPlayAdd5 = false
        if bPlayAdd5 then
            FrameLoader:loadArmature( "skeleton/tutorial_animation" )
            local node = ArmatureNode:create("boomb_add5_anime2")
	        node:setAnimationScale(1.25)
	        node:playByIndex(0)
	        node.playAnimation = function( self )
		        node:playByIndex(0, 0)
	        end
	        node.stopAnimation = function ( self )
		        node:gotoAndStopByIndex(0, 0)
	        end
	        node:update(0.001)
	        node:stop()
            node:playAnimation()
            self.ui.moletarget:getParent():addChild( node)
            self.ui.BombAnim = node

            instance.data:setIsPlayAdd5Anim( false )
        end
    end


    --可领取宝箱
    local bCanGetBoxReward = false
    local GetBoxParam = {}

    --可晋级
    local bCanLevelUp = false
    local LevelUpParem = {}

    local instance = RankRaceMgr:getExistedInstance()
    if instance then
        local CanGetNum = 0 --胜利可获得数量
        local mainLogic = GameBoardLogic:getCurrentLogic()
        local CurGetNum = mainLogic.digJewelCount:getValue()
        CanGetNum = CanGetNum + CurGetNum
        if bBossAlive then
            local bossData = mainLogic:getMoleWeeklyBossData()
            if bossData  then
                CanGetNum = CanGetNum + bossData.dropItemsOnDie
            end
        else
            local NextbossData = MoleWeeklyRaceConfig.genNewBoss(mainLogic) --获取新BOSS属性。但是不走创建BOSS
            if NextbossData  then
                CanGetNum = CanGetNum + NextbossData.demolishReward
            end
        end

        --宝箱判断 
        local ret1, boxIndex1 = instance:HasBoxCanRewards( CurGetNum )
        local ret, boxIndex = instance:HasBoxCanRewards( CanGetNum )

        --没有BOSS数量的宝箱 与 带上BOSS数量的宝箱比较 是新的才行
        if ret and boxIndex ~= boxIndex1 then
            bCanGetBoxReward = true
            GetBoxIndex = boxIndex

            GetBoxParam = { boxIndex, CanGetNum }
        end

        --升段判断
        local CurHaveNoBoss = instance.data:getTC0() + CurGetNum
        local CurHave = instance.data:getTC0() + CanGetNum

        local paramNoBoss1, paramNoBoss2, paramNoBoss3, paramNoBoss4, paramNoBoss5 = instance:getFakeGroupRankIndex( CurHaveNoBoss )
        local param1, param2, param3, param4, param5 = instance:getFakeGroupRankIndex( CurHave )

        if param1 ~= 3 and param5 and param3 ~= param4 and  paramNoBoss3 ~= param3 then
            bCanLevelUp = true
            LevelUpParem = { param1, param2, param3, param4, param5 }
        end
    end

--    bCanLevelUp = true --test
--    LevelUpParem = { 1, 1, 3, 4, {} }

    self.ui.state = 0
    self.ui.stateParam = {}

    if self.ui.manager:getIsTargetComplete() == false then
        if bBossAlive then
            self.ui.state = 1
        else
            self.ui.state = 4
        end
    else
        if bCanGetBoxReward then
            self.ui.state = 5
            self.ui.stateParam = GetBoxParam
        elseif bCanLevelUp then
            self.ui.state = 6
            self.ui.stateParam = LevelUpParem
        else
            if bBossAlive then
                self.ui.state = 2
            else
                self.ui.state = 3
            end
        end
    end

    self:setState( self.ui.state, self.ui.stateParam, bBossAlive )

    self:updateBtn()
    self:updateTargetNum()
end

function CommonLogic:setState(state,stateParam, bBossAlive)

--    {platform=platform, n="\n"}

--    printx( 12, table.tostring(stateParam).."   " )

    local CanGetNum = 0 --打死BOSS可以获得的数
    local NextCanGetNum = 0 --下个BOSS可以获得的数
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local CurGetNum = 0--当前关卡内已经获得的数

    if mainLogic then
        CurGetNum = mainLogic.digJewelCount:getValue()

        local bossData = mainLogic:getMoleWeeklyBossData()
        if bossData  then
            CanGetNum = bossData.dropItemsOnDie

            local NextbossData = MoleWeeklyRaceConfig.genNewBoss(mainLogic) --获取新BOSS属性。但是不走创建BOSS
            if NextbossData  then
                NextCanGetNum = NextbossData.demolishReward
            end
        end
    end

    if state == 1 then
        self.ui.moleText:setRichText(  Localization:getInstance():getText("rank.race.fail.add.five.1", { molereward=CanGetNum } ) )
        self.ui.moletarget:setVisible(true)
    elseif state == 2 then
        self.ui.moleText:setRichText( Localization:getInstance():getText("rank.race.fail.add.five.2", { molereward=CanGetNum } ) )
        self.ui.moletarget:setVisible(false)
    elseif state == 3 then
        self.ui.moleText:setRichText( Localization:getInstance():getText("rank.race.fail.add.five.3") )
        self.ui.moletarget:setVisible(false)
    elseif state == 4 then
        self.ui.moleText:setRichText( Localization:getInstance():getText("rank.race.fail.add.five.4") )
        self.ui.moletarget:setVisible(true)
    elseif state == 5 then
        local boxIndex = stateParam[1] or 1
        local getNum = stateParam[2] or 0

        local TipText= ""
        if bBossAlive then
            TipText = Localization:getInstance():getText("rank.race.fail.add.five.5", { molereward=CanGetNum })
        else
            TipText = Localization:getInstance():getText("rank.race.fail.add.five.6")
        end

--        boxIndex = 1 --test

        self.ui.moleText:setRichText( TipText )
        self.ui.moletarget:setVisible(false)

        local TargetPos = self.ui.moletarget:getPosition()

        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        local boxUI
        if SaijiIndex == 1 then
            boxUI = UIHelper:createUI('flash/MoleWeekly/MoleWeekly.json', 'moleweek_race_end_game/box'..boxIndex )
        else
            if boxIndex == 7 then
                local index = boxIndex
                local Dan = RankRaceMgr.getInstance():getData():getSafeDan()
                local bigDan = math.ceil(Dan/3)
                if bigDan == 1 then
                    index = 8
                elseif bigDan == 2 then
                    index = 9
                elseif bigDan == 3 then
                    index = 10
                end

                boxUI = UIHelper:createUI('flash/MoleWeekly/MoleWeekly.json', 'moleweek_race_end_game/box'..index.."_"..SaijiIndex )
            else
                boxUI = UIHelper:createUI('flash/MoleWeekly/MoleWeekly.json', 'moleweek_race_end_game/box'..boxIndex.."_"..SaijiIndex )
            end
        end

        boxUI:setPosition( ccp(TargetPos.x+41/0.7,TargetPos.y) )
        self.ui.ui:addChild( boxUI )

        local target = boxUI:getChildByName("target")
        local label = target:getChildByName("label")
        label:setVerticalAlignment(kCCVerticalTextAlignmentCenter)

       

        local CurHave = 0
        local NeedNum = 0
        local instance = RankRaceMgr:getExistedInstance()
        if instance then
            local thisBoxConfig = instance.meta:getBoxRewardConfig()[boxIndex]
            CurHave = instance.data:getTC0() + CurGetNum
	        if thisBoxConfig then
                NeedNum = thisBoxConfig.conditions
            end
        end

        if self.ui.targetLabel then self.ui.targetLabel:removeFromParentAndCleanup(true) end

		self.ui.targetLabel = BitmapText:create( CurHave.."/"..NeedNum, 'fnt/newzhousai_rubynum.fnt')
		self.ui.targetLabel:setAnchorPoint(ccp(0.5, 0.5))

		local pos = label:getPosition()
		local dime = label:getDimensions()

		self.ui.targetLabel:setPositionX(pos.x + dime.width/2)
		self.ui.targetLabel:setPositionY(pos.y - dime.height/2-1)
		target:addChild(self.ui.targetLabel)
		self.ui.targetLabel:setScale(math.min(0.6, 110/self.ui.targetLabel:getContentSize().width))

    elseif state == 6 then

        local TipText= ""
        if bBossAlive then
            if stateParam[1] == 2 or stateParam[1] == 1 then
                TipText = Localization:getInstance():getText("rank.race.fail.add.five.7", { molereward=CanGetNum })
            else
                TipText = Localization:getInstance():getText("rank.race.fail.add.five.9", { molereward=CanGetNum })
            end
        else
            TipText = Localization:getInstance():getText("rank.race.fail.add.five.8")
        end

        self.ui.moleText:setRichText( TipText )
        self.ui.moletarget:setVisible(false)

        local TargetPos = self.ui.moletarget:getPosition()

        local boxUI = UIHelper:createUI('flash/MoleWeekly/MoleWeekly.json', 'moleweek_race_end_game/levleup' )
        boxUI:setPosition( ccp(TargetPos.x-119/0.7+31/0.7, TargetPos.y+15/0.7) )
        self.ui.ui:addChild( boxUI )

        local selfinfo = boxUI:getChildByName("selfinfo")
        local enemyinfo = boxUI:getChildByName("enemyinfo")

        local selfrankbg = selfinfo:getChildByName("rankbg")
        selfrankbg:setPosition( ccp( selfrankbg:getPositionX()-10/0.7, selfrankbg:getPositionY()+7/0.7 ) )
        local selfrank = selfinfo:getChildByName("rank")
        selfrank:changeFntFile('fnt/register2.fnt')
        selfrank:setAnchorPoint(ccp(0.5,0.5))
        selfrank:setPosition( ccp( selfrank:getPositionX()+1/0.7, selfrank:getPositionY()-4/0.7 ) )
        local selfhead = selfinfo:getChildByName("head")
        selfhead:setPosition( ccp( selfhead:getPositionX()-10/0.7, selfhead:getPositionY()) )
        local selftargetnum = selfinfo:getChildByName("targetnum")
        selftargetnum:changeFntFile('fnt/register2.fnt')
        selftargetnum:setAnchorPoint(ccp(0.5,0.5))
        selftargetnum:setColor( hex2ccc3('934800') )
        selftargetnum:setPosition( ccp( selftargetnum:getPositionX()+28/0.7, selftargetnum:getPositionY()-17/0.7 ) )

        local selfName = TextField:create("", nil, 30)
	    selfName:setPosition(ccp(190, -37))
        selfName:setColor( hex2ccc3('934800') )
        selfinfo:addChildAt(selfName, 10)

        local enemyrankbg = enemyinfo:getChildByName("rankbg")
        enemyrankbg:setPosition( ccp( enemyrankbg:getPositionX()-4/0.7, enemyrankbg:getPositionY()+7/0.7 ) )

        local enemyrank = enemyinfo:getChildByName("rank")
        enemyrank:changeFntFile('fnt/register2.fnt')
        enemyrank:setAnchorPoint(ccp(0.5,0.5))
        enemyrank:setScale(0.7)
        enemyrank:setPosition( ccp( enemyrank:getPositionX()+6/0.7, enemyrank:getPositionY()-7/0.7 ) )
        local enemyhead = enemyinfo:getChildByName("head")
        local enemytargetnum = enemyinfo:getChildByName("targetnum")
        enemytargetnum:changeFntFile('fnt/register2.fnt')
        enemytargetnum:setAnchorPoint(ccp(0.5,0.5))
        enemytargetnum:setColor( hex2ccc3('934800') )
        enemytargetnum:setPosition( ccp( enemytargetnum:getPositionX()+28/0.7, enemytargetnum:getPositionY()-16/0.7 ) )

        local enemyName = TextField:create("", nil, 25)
	    enemyName:setPosition(ccp(156, -27))
        enemyName:setColor( hex2ccc3('934800') )
        enemyinfo:addChildAt(enemyName, 10)

        local CurHave = 0
        local instance = RankRaceMgr:getExistedInstance()
        if instance then
            CurHave = instance.data:getTC0() + CurGetNum
        end

        local selfLevel = stateParam[4]
        local selfTargetNum = CurHave
        
        local EnemyInfo = stateParam[5]
        local EnemyName = Misc:truncat( nameDecode( EnemyInfo.name or "123456789" ),  5 )
		local EnemyHeadUrl = EnemyInfo.headUrl or "123"
        local EnemyHeadFrame = EnemyInfo.headFrame or "123"
        local EnemyUid = EnemyInfo.uid or "123456"
        local EnemyLevel = stateParam[3]
        local EnemyTargetNum = EnemyInfo.score or 10
        local EnemyheadFrame = EnemyInfo.headFrame

        --自己
        selfrank:setText(""..selfLevel)
        selftargetnum:setText(""..selfTargetNum)
        

        local selfProfile = UserManager:getInstance().profile
        local head = HeadImageLoader:createWithFrame(getSafeUid(), selfProfile.headUrl or tostring((tonumber(userId) or 0) % 11))
        local nameStr =  Misc:truncat( nameDecode(selfProfile.name or ""), 5 )

	    head:setScaleX(0.7)
	    head:setScaleY(0.7)
        head:setPosition( ccp(37,40 ) )
        selfhead:addChild( head )
        selfName:setString(nameStr)


        --敌人
        enemyrank:setText(""..EnemyLevel)
        enemytargetnum:setText(""..EnemyTargetNum)
        enemyName:setString(""..EnemyName)

        local enemyProfile = {}
        if EnemyheadFrame then 
    	    enemyProfile = {headFrame = EnemyheadFrame,
				    headFrames = {
					    {id = EnemyheadFrame, obtainTime = 0, expireTime = 0}
				    }}
        end


        local head = HeadImageLoader:createWithFrame(EnemyUid, EnemyHeadUrl or tostring((tonumber(EnemyUid) or 0) % 11), nil, nil, enemyProfile )

	    head:setScaleX(0.7)
	    head:setScaleY(0.7)
        head:setPosition( ccp(37,40+5/0.7 ) )
        enemyhead:addChild( head )


        self.ui.freeBtn_group:setPosition( ccp(self.SavefreeBtnPos.x, self.SavefreeBtnPos.y-110/0.7) )
        self.ui.buyBtn:setPosition( ccp(self.SavebuyBtnBtnPos.x, self.SavebuyBtnBtnPos.y-110/0.7) )
        self.ui.useBtn:setPosition( ccp(self.SaveuseBtnBtnPos.x, self.SaveuseBtnBtnPos.y-110/0.7) )
        self.ui.moneyBar:setPosition( ccp(self.SavemoneyBarPos.x, self.SavemoneyBarPos.y-110/0.7) )
    end
end

function CommonLogic:updateBtn()

    local bFree = not UserManager.getInstance():hasGuideFlag( kGuideFlags.MoleWeekAdd5Step )
    local bBossAlive = self.ui.manager:getIsBossAlive()
    if bFree and bBossAlive then
        self.ui.closeBtn:setVisible(false)
        self.ui.freeBtn_group:setVisible(true)

        local Instance = self.ui

        local levelID = 0
        local mainLogic = GameBoardLogic:getCurrentLogic()
        if mainLogic then
            levelID = mainLogic.level
        end

        local function ClickCallback( evt )
            
            PopoutManager:sharedInstance():remove(Instance)
            
            --调用+5步回调
            local mainLogic = GameBoardLogic:getCurrentLogic()
            mainLogic.gameMode:addStepSucess()

            --断面处理
            if not noSectionResumeRecord then
			    SectionResumeManager:setNextSectionInfo( 
			            SectionData:create( SectionType.kUseProp , { r = 0, c = 0 } , { r = 0, c = 0 } , GamePropsType.kBombAdd5 )  
			            )
	        end

            mainLogic.PlayUIDelegate:setPauseBtnEnable(true)

             --打点
            local dcData = {
	            game_type = "stage",
	            game_name = "weeklyrace2018",
	            category = "weeklyrace2018",
	            sub_category = "weeklyrace2018_show_5_steps_use_free",
	            t1 = levelID,
            }
            DcUtil:AddFiveForMoleWeek( dcData)

            UserLocalLogic:setGuideFlag( kGuideFlags.MoleWeekAdd5Step )
        end

        self.ui.freeBtn_group:setEnabled(true)
        self.ui.freeBtn_group:ad(DisplayEvents.kTouchTap, ClickCallback)

        self.ui.moneyBar:setVisible(false)

        --打点
        local dcData = {
	        game_type = "stage",
	        game_name = "weeklyrace2018",
	        category = "weeklyrace2018",
	        sub_category = "weeklyrace2018_show_5_steps_open_free",
	        t1 = levelID,
        }
        DcUtil:AddFiveForMoleWeek( dcData)
    else
        local propNum = EndGamePropManager.getInstance():getItemNum(self.ui.propId)
	    if propNum > 0 then
		    self.ui.useButtonUI:setVisible(true)
		    self.ui.useButton:useBubbleAnimation()
	    else
		    self.ui.buyButtonUI:setVisible(true)
	    end 
    end
end

function CommonLogic:updateTargetNum()
    local haveNum = self.ui.manager:getGotExtraTargetNum()
    local AllNum = self.ui.manager:getTotolTargetNum()
    self.ui.moletargetNum:setText(haveNum..'/'..AllNum)
end

function updateBgPos( ui )

    --根据BOSS位置加光效
    local BossPosInGameBGNode = ccp(0,0)

    local mainLogic = GameBoardLogic:getCurrentLogic()
    local gameBg = mainLogic.PlayUIDelegate.gameBgNode
	if gameBg then
		BossPosInGameBGNode = gameBg.upBg:convertToWorldSpace(ccp(480, 16))
        local pos = ui.mole_bg:getParent():convertToNodeSpace(ccp(BossPosInGameBGNode.x, BossPosInGameBGNode.y))
        local height = ui.mole_bg:getContentSize().height*2

        ui.mole_bg:setPositionY(  pos.y + height  )
    else
        ui.mole_bg:setPositionY( ui.mole_bg:getPositionY() )
	end

    local molebgPosY = ui.mole_bg:getPositionY()

    local height = ui.mole_bg:getContentSize().height*2
    ui.mole_bg_down:setPositionY( molebgPosY-height )
end


MoleWeekRaceEndGamePropIosPanel = class(EndGamePropIosPanel_VerB_old)

function MoleWeekRaceEndGamePropIosPanel:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
    local panel = MoleWeekRaceEndGamePropIosPanel.new()
    panel:loadRequiredResource("flash/MoleWeekly/MoleWeekly.json")
    panel.isWeekly = true
    panel:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
end

function MoleWeekRaceEndGamePropIosPanel:onCashNumChange( ... )
	-- body
end

function MoleWeekRaceEndGamePropIosPanel:getUIGroupName()
	return "moleweek_race_end_game/panel"
end

function MoleWeekRaceEndGamePropIosPanel:onCountdownComplete()
end

function MoleWeekRaceEndGamePropIosPanel:popout()
	CommonLogic:create(self)
	self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(self, 0)

	self:updateFuuuTargetShow(true)
	self:popoutFinishCallback()

	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	PopoutManager:sharedInstance():add(self, false)

	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local pos = ccp(vo.x + vs.width - 50, vo.y + vs.height - 50)
    self.closeBtn:setPosition(self:convertToNodeSpace(pos))

    if self.BombAnim then
        local pos = ccp(vo.x + vs.width/2 - 325/2+11/0.7 , vo.y + 400 )
        self.BombAnim:setPosition(self:convertToNodeSpace(pos))
    end

    updateBgPos( self )

    if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
		RealNameManager:addConsumptionLabelToPanel(self, false)
	end

    self.panelName = "MoleWeekAddFivePanel"

    GameGuide:sharedInstance():tryStartGuide()
end


MoleWeekRaceEndGamePropAndroidPanel = class(EndGamePropAndroidPanel_VerB_old)

function MoleWeekRaceEndGamePropAndroidPanel:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout)
    local pGoodsId = nil
	local pShowType = nil 
	local animalCreator = nil

	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		local panel = MoleWeekRaceEndGamePropAndroidPanel.new()
    	panel:loadRequiredResource("flash/MoleWeekly/MoleWeekly.json")
		panel.levelId = levelId
		panel.propId = propId
		panel.levelType = levelType
		panel.onUseTappedCallback = onUseCallback
		panel.onCancelTappedCallback = onCancelCallback
		panel.onPanelWillPopout = onPanelWillPopout
		
		panel.adDecision = decision
		panel.adPaymentType = paymentType
		panel.dcAndroidStatus = dcAndroidStatus
		panel.adRepayChooseTable = repayChooseTable

		panel.goodsId = pGoodsId
		panel.showType = pShowType

		local isFUUU , fuuuId , fuuuData = FUUUManager:lastGameIsFUUU(true)
		panel.lastGameIsFUUU = isFUUU
		panel.fuuuLogID = fuuuId
		panel.fuuuData = fuuuData

		panel.animalAnimetionCreator = animalCreator

		panel:init() 
		if type(useTipText) == "string" then
			panel:setUseTipText(useTipText)
			panel:setUseTipVisible(true)
		end

		panel:dcPanelShow()

		self.isFUUU = isFUUU
		self.levelId = levelId

		CommonLogic:create(panel)
		panel:popout() 

	end
 
	pGoodsId, pShowType = EndGamePropManager.getInstance():getAndroidBuyGoodsId(propId, levelId, true)
	PaymentManager.getInstance():getBuyItemDecision(popoutPanel, pGoodsId)
end


function MoleWeekRaceEndGamePropAndroidPanel:onCashNumChange( ... )
	-- body
end

function MoleWeekRaceEndGamePropAndroidPanel:getUIGroupName()
	return "moleweek_race_end_game/panel"
end

function MoleWeekRaceEndGamePropAndroidPanel:onCountdownComplete()
end

function MoleWeekRaceEndGamePropAndroidPanel:popout()
	self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(self, 0)

	self:updateFuuuTargetShow(true)
	self:popoutFinishCallback()
	self.allowBackKeyTap = false

	if type(self.onPanelWillPopout) == "function" then
		self.onPanelWillPopout(self)
	end

	PopoutManager:sharedInstance():add(self, false)

	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local pos = ccp(vo.x + vs.width - 50, vo.y + vs.height - 50)
    self.closeBtn:setPosition(self:convertToNodeSpace(pos))


    if self.BombAnim then
        local pos = ccp(vo.x + vs.width/2 - 325/2 , vo.y + 400 )
        self.BombAnim:setPosition(self:convertToNodeSpace(pos))
    end

    updateBgPos( self )

    if EndGamePropManager.getInstance():getItemNum(self.propId) <= 0 then
		RealNameManager:addConsumptionLabelToPanel(self, false)
	end

    self.panelName = "MoleWeekAddFivePanel"

    GameGuide:sharedInstance():tryStartGuide()
end
