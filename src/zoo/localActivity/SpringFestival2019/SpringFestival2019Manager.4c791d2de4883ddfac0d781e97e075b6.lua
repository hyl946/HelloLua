
--add no use line

local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"

SpringFestival2019Manager = class()

local instance = nil

local MAX_COUNT_ATTACK = 4
local PriorityInit = 0.1;  --初始状态
local Priority1Weight = 100; 
local Priority2Weight = 10;
local Priority3Weight = 1;
local PriorityBlackPoint = 0; --被雪怪踩中的区域的左上角的点
local PriorityNoSelectPoint = -1;

local luckyBagType = {
    None = 0,
    SilverBag = 1,
    GoldBag = 2,
}

local PlayLevelType = {
    TopLevel = 1,
    StarLevel = 2,
    ActivityLevel = 3,
}

function SpringFestival2019Manager.getInstance()
	if not instance then
		instance = SpringFestival2019Manager.new()
		instance:init()
	end
	return instance
end

function SpringFestival2019Manager:init()
    self.levelID = 0
    self.levelStar = 0
--    self.lastLevelStar = 0 --当前活动关的星级 prestartLevel的时候赋值的。这里不清空
    self.scoreAddPercent = 0--当前分数加成
    self.useMove = 0
    self.EndMoveStep = 0
    self.EndMoveSkillID = {}

    self.GemNumList = {0,0,0,0}
    self.FlyPigLeftNum = 0 --飞10个猪
    self.curLevelCanGetInfo = {} --当前关可以获得
    self.LevelPlayType = 0
    self.SpeedCardNum = 0
    self.UseSkillList = {false,false,false,false}
   
    self.CurIsAct = false --当前关是否激活了活动
    self.CurIsActSkill = false--当前关是否激活了技能

    self.CurCreateRightPropList = false
    self.CurRightPropListIsOpen = false

    self.isShowSkillTip = false

    if not PigYearLogic:bInitLogic() then
        PigYearLogic:resetData()
	    PigYearLogic:read()
        PigYearLogic:initLogic()
    end
end

-----------------------------活动部分
function SpringFestival2019Manager:beforeInGame( levelID, startLevelType )

    local bAskForHelp = false
    if startLevelType == StartLevelType.kAskForHelp then
        bAskForHelp = true
    end

    self:init()
    self.levelID = levelID

    if LevelType:isMainLevel(levelID) or LevelType:isHideLevel(levelID) then
        local curStar = 0
        local scores = UserManager:getInstance():getScoreRef()
	    for k, v in pairs(scores) do
		    if v.levelId == levelID then 
			    self.levelStar = tonumber(v.star)
                break
		    end
        end
    end

    self.CurIsActSkill = true
    self.CurIsAct = self:GetLevelIsCanActiveSkill(levelID, bAskForHelp)
    self.LevelPlayType = self:getLevelPlayType(self.levelID)
    self.curLevelCanGetInfo = self:curLevelCanGet(self.levelID)
    self.GemNumList = table.clone( PigYearLogic:getGemNums() )

    self.levelPlayCount = 0
    if PigYearLogic:bInitLogic() then
        self.levelPlayCount = PigYearLogic:getLevelPlayedCount(self.levelID)
    end

    self:DC( "stage", "5years_click_new_stage",  self.levelID )
end

function SpringFestival2019Manager:reset()
    self:init()
end

--关卡是否支持活动 
function SpringFestival2019Manager:isActivitySupportShowSkill( levelID, replayMode )
    if replayMode == nil then replayMode = false end 

    if replayMode then 
--        printx(12,"replayMode", replayMode )
        return true 
    end 

    if not PigYearLogic:bInitLogic() then return false end

    local bEnabled = PigYearLogic:isActInMain_ClientTime()
    local hasInitedInServer = PigYearLogic:hasInitedInServer()

--    printx(12,"levelID", levelID )
--    printx(12,"bEnabled", bEnabled )
--    printx(12,"hasInitedInServer", hasInitedInServer )
--    printx(12,"isCanActiveSkill", isCanActiveSkill )
    if bEnabled and hasInitedInServer then
        return true
    end
    return false
end

--关卡是否支持 打福袋 银劵金劵
function SpringFestival2019Manager:isActivitySupport( levelID, replayMode )
    if replayMode == nil then replayMode = false end 

    if replayMode then 
--        printx(12,"replayMode", replayMode )
        return true 
    end 

    --代打不支持
    if AskForHelpManager:getInstance():isInMode() then return false end

    if not PigYearLogic:bInitLogic() then return false end

    local bEnabled = PigYearLogic:isActInMain_ClientTime()
    local hasInitedInServer = PigYearLogic:hasInitedInServer()
    local isCanActiveSkill = self:GetLevelIsCanActiveSkill(levelID)

--    printx(12,"levelID", levelID )
--    printx(12,"bEnabled", bEnabled )
--    printx(12,"hasInitedInServer", hasInitedInServer )
--    printx(12,"isCanActiveSkill", isCanActiveSkill )
    if bEnabled and hasInitedInServer and isCanActiveSkill then
        return true
    end
    return false
end

function SpringFestival2019Manager:getCurIsAct()
    return self.CurIsAct
end

function SpringFestival2019Manager:getCurIsActSkill()
    return self.CurIsActSkill
end

-------------------------活动部分2
function SpringFestival2019Manager:getBuyAddFiveAddNum()
    return PicYearMeta.ADDFIVE_ADD_GETNUM
end

--获取关卡最高可得奖励
function SpringFestival2019Manager:curLevelCanGet( levelID )
    local curLevelCanGet = {}

    local LevelPlayType = self:getLevelPlayType( levelID )

    if LevelPlayType == PlayLevelType.TopLevel 
        or LevelPlayType == PlayLevelType.ActivityLevel then

        local doubleNum, ticketNum = PigYearLogic:getTicketDoubleNum( levelID )

        local levelPlayCount = 0
        if PigYearLogic:bInitLogic() then
            levelPlayCount = PigYearLogic:getLevelPlayedCount(levelID)
        end

        --首次关卡 得金卡
        if levelPlayCount == 0 then
            curLevelCanGet.TicketType = luckyBagType.GoldBag
        else
            curLevelCanGet.TicketType = luckyBagType.None
        end
        curLevelCanGet.ticketNum = ticketNum

        --福袋 等级 倍数
        local luckyBagLevel = PigYearLogic:getLuckyBagLevel()
        curLevelCanGet.luckyBagLevel = luckyBagLevel
        local luckyBagDoubleNum = doubleNum
        curLevelCanGet.luckyBagDoubleNum = luckyBagDoubleNum

    elseif LevelPlayType == PlayLevelType.StarLevel then
        --隐藏关最高得金券
        curLevelCanGet.TicketType = luckyBagType.GoldBag
        curLevelCanGet.ticketNum = 3

        local luckyBagLevel = PigYearLogic:getLuckyBagLevel()
        curLevelCanGet.luckyBagLevel = luckyBagLevel
        curLevelCanGet.luckyBagDoubleNum = 4
    end

--    printx(12,"11111111111111111 curLevelCanGet="..table.tostring(curLevelCanGet))
--    printx(12,""..debug.traceback())
    return curLevelCanGet
end

--真实过关获取的奖励
function SpringFestival2019Manager:getPassLevelCanGet( bSucess, newStar )
    
    local curLevelCanGet = self:getPassLevelCanGetInfo(bSucess, newStar )
    self.passLevelCanGet = curLevelCanGet

--    printx(12,"2222222222222222 passLevelCanGet="..table.tostring(self.passLevelCanGet))
--    printx(12,""..debug.traceback())
end

function SpringFestival2019Manager:getPassLevelCanGetInfo( bSucess, newStar )
    local curLevelCanGet = {}

    if self.LevelPlayType == PlayLevelType.TopLevel
        or self.LevelPlayType == PlayLevelType.ActivityLevel then
        if bSucess then
            curLevelCanGet.TicketType = self.curLevelCanGetInfo.TicketType
            curLevelCanGet.ticketNum = self.curLevelCanGetInfo.ticketNum
            curLevelCanGet.luckyBagLevel = self.curLevelCanGetInfo.luckyBagLevel
            curLevelCanGet.luckyBagDoubleNum = self.curLevelCanGetInfo.luckyBagDoubleNum
        else
            curLevelCanGet.TicketType = luckyBagType.None
            curLevelCanGet.ticketNum = 0

            curLevelCanGet.luckyBagLevel = self.curLevelCanGetInfo.luckyBagLevel
            curLevelCanGet.luckyBagDoubleNum = 1
        end
    elseif self.LevelPlayType == PlayLevelType.StarLevel then
        if bSucess then
            if newStar > self.levelStar then
                if newStar >= 3 then
                    curLevelCanGet.TicketType = luckyBagType.GoldBag
                else
                    curLevelCanGet.TicketType = luckyBagType.None
                end
                curLevelCanGet.ticketNum = self.curLevelCanGetInfo.ticketNum

                curLevelCanGet.luckyBagLevel = self.curLevelCanGetInfo.luckyBagLevel
                curLevelCanGet.luckyBagDoubleNum = self.curLevelCanGetInfo.luckyBagDoubleNum
            else
                curLevelCanGet.TicketType = luckyBagType.None
                curLevelCanGet.ticketNum = 0

                curLevelCanGet.luckyBagLevel = self.curLevelCanGetInfo.luckyBagLevel
                curLevelCanGet.luckyBagDoubleNum = 1
            end
        else
            curLevelCanGet.TicketType = luckyBagType.None
            curLevelCanGet.ticketNum = 0

            curLevelCanGet.luckyBagLevel = self.curLevelCanGetInfo.luckyBagLevel
            curLevelCanGet.luckyBagDoubleNum = 1
        end
    end

    return curLevelCanGet
end

function SpringFestival2019Manager:getCurLevelPassCanGetInfo( bAddSpeed )
    if bAddSpeed == nil then bAddSpeed = true end 

--    printx(12,"33333333333333333333 passLevelCanGet="..table.tostring(self.passLevelCanGet))
--    printx(12,""..debug.traceback())

    --福袋开启界面
    local passLevelCanGet = self.passLevelCanGet

    local rewardInfo = {}
    if passLevelCanGet.TicketType == luckyBagType.SilverBag and passLevelCanGet.ticketNum then
        table.insert( rewardInfo, {itemId = PicYearMeta.ItemIDs.SILVER, num = passLevelCanGet.ticketNum})
    elseif passLevelCanGet.TicketType == luckyBagType.GoldBag and passLevelCanGet.ticketNum then
        table.insert( rewardInfo, {itemId = PicYearMeta.ItemIDs.GOLD, num = passLevelCanGet.ticketNum})
    end

    local luckyBagDoubleNum = passLevelCanGet.luckyBagDoubleNum
    table.insert( rewardInfo, {itemId = PicYearMeta.ItemIDs["LUCKY_BAG_M_"..luckyBagDoubleNum], num = 1})

    if bAddSpeed and self.SpeedCardNum > 0 then
        table.insert( rewardInfo, {itemId = PicYearMeta.ItemIDs.SPEEDUP_CARD, num = self.SpeedCardNum})
    end

    return rewardInfo
end

function SpringFestival2019Manager:addSpeedCardNum( num )
    self.SpeedCardNum = self.SpeedCardNum + num

    SpringFestival2019Manager.getInstance():DC( "stage","SpringFestival2019_get_skip_card" )
end

function SpringFestival2019Manager:getCurLevelCanGetInfo()
    return self.curLevelCanGetInfo
end

function SpringFestival2019Manager:getGemNumList()
    return self.GemNumList
end

function SpringFestival2019Manager:costGemNum( SkillId, num )
    if SkillId < 1 or SkillId > 4 then return end 

    self.GemNumList[SkillId] = self.GemNumList[SkillId] - num
    if self.GemNumList[SkillId] < 0 then
        self.GemNumList[SkillId] = 0
    end

    PigYearLogic:addGemByIndex( SkillId, num*(-1) )
end

function SpringFestival2019Manager:addGemNum( SkillId, num )
    if SkillId < 1 or SkillId > 4 then return end 

    self.GemNumList[SkillId] = self.GemNumList[SkillId] + num
    if self.GemNumList[SkillId] < 0 then
        self.GemNumList[SkillId] = 0
    end
end

function SpringFestival2019Manager:updateGemNumList()
    self.GemNumList = table.clone( PigYearLogic:getGemNums() )
end

function SpringFestival2019Manager:setCurLevelCreateRightPropList()
    self.CurCreateRightPropList = true
end

function SpringFestival2019Manager:getCurLevelCreateRightPropList()
    return self.CurCreateRightPropList
end

function SpringFestival2019Manager:setRightPropListOpen( bOpen )
    self.CurRightPropListIsOpen = bOpen
end

function SpringFestival2019Manager:getRightPropListOpen()
    return self.CurRightPropListIsOpen
end

function SpringFestival2019Manager:getLevelPlayType( levelId )

    if not PigYearLogic:isFullLevel() then
        --普通打最高关
        return PlayLevelType.TopLevel
    else
        if not PigYearLogic:isFullStar() then
            if LevelType:isMainLevel(levelId) or LevelType:isHideLevel(levelId) then
                --隐藏关
                return PlayLevelType.StarLevel
            elseif LevelType:isSpringFestival2019Level( levelId ) then
                --活动关
                return PlayLevelType.ActivityLevel
            end
        else
            if LevelType:isSpringFestival2019Level( levelId ) then
                --活动关
                return PlayLevelType.ActivityLevel
            end
        end
    end
end

--是否能激活关卡奖励 改需求把函数意义变了。
function SpringFestival2019Manager:GetLevelIsCanActiveSkill( levelId, bAskForHelp )

    --代打无法获得奖励
    if bAskForHelp == nil then bAskForHelp = false end 
    if bAskForHelp then return false end 

--    printx(12,"GetLevelIsCanActiveSkill 1111111")
    if not PigYearLogic:isFullLevel() then
--        printx(12,"GetLevelIsCanActiveSkill 2222222")
        --普通打最高关
        local userTopLevel = UserManager:getInstance().user.topLevelId
        local topPassLevel= UserManager.getInstance():getTopPassedLevel()

        if levelId == userTopLevel and userTopLevel ~= topPassLevel then
            return true
        end

    else
--        printx(12,"GetLevelIsCanActiveSkill 33333333")
        if not PigYearLogic:isFullStar() then
--            printx(12,"GetLevelIsCanActiveSkill 44444444")
            if LevelType:isMainLevel(levelId) or LevelType:isHideLevel(levelId) then
--                printx(12,"GetLevelIsCanActiveSkill 55555555")
                --打主线 隐藏
                local curStar = 0
                local scores = UserManager:getInstance():getScoreRef()
	            for k, v in pairs(scores) do
		            if v.levelId == levelId then 
			            curStar = tonumber(v.star)
                        break
		            end
                end

                local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId)
                local maxStar = #levelConfig.scoreTargets

                if curStar < maxStar then
                    return true
                end
            elseif LevelType:isSpringFestival2019Level( levelId ) then
--                printx(12,"GetLevelIsCanActiveSkill 66666666")
                --活动关
                local nextActLevelIndex = PigYearLogic:getNextActLevelIndex()
                local levelID = nextActLevelIndex + LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_START - 1

                if levelID == levelId then
                    return true
                else
                    return false
                end
            end
        else
            if LevelType:isSpringFestival2019Level( levelId ) then
--                printx(12,"GetLevelIsCanActiveSkill 77777777")
                --活动关
                local nextActLevelIndex = PigYearLogic:getNextActLevelIndex()
                local levelID = nextActLevelIndex + LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_START - 1

                if levelID == levelId then
                    return true
                else
                    return false
                end
            end
        end
    end

    return false
end

function SpringFestival2019Manager:initFlyPigLeftNum( num )
    self.EndMoveStep = num

    self.FlyPigLeftNum = num
    if self.FlyPigLeftNum > PicYearMeta.BonsTimeMaxNum then
        self.FlyPigLeftNum = PicYearMeta.BonsTimeMaxNum
    end

    --计算获得宝石数
    self.EndMoveSkillIndex = {}
    self.EndMoveSkillID = {}
    for i=1, self.FlyPigLeftNum do
        local ranNum = math.random(1,3)
        local Index = 1
        local SkillID = 1
        if ranNum == 1 then
            Index = 1
            SkillID = PicYearMeta.ItemIDs.GEM_1
        elseif ranNum == 2 then
            Index = 3
            SkillID = PicYearMeta.ItemIDs.GEM_3
        else
            Index = 4
            SkillID = PicYearMeta.ItemIDs.GEM_4
        end

        table.insert(self.EndMoveSkillIndex, Index)
        table.insert(self.EndMoveSkillID, SkillID)
    end
end

function SpringFestival2019Manager:getFlyPigLeftNum()
    return self.FlyPigLeftNum
end

function SpringFestival2019Manager:setFlyPigNumChange()
    if self.FlyPigLeftNum <= 0 then return end 

    self.FlyPigLeftNum = self.FlyPigLeftNum - 1 
end

function SpringFestival2019Manager:getUseSkillList()
    return self.UseSkillList
end

function SpringFestival2019Manager:setUseSkill( index )
    self.UseSkillList[index] = true
end


--------------------------------技能部分
function SpringFestival2019Manager:showSkillCanUseTip()
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and  mainLogic.PlayUIDelegate.propList.rightPropList 
            and mainLogic.PlayUIDelegate.propList.rightPropList.springItem then

            if mainLogic.PlayUIDelegate.propList.rightPropList.springItem.PlayFullAnim then
                mainLogic.PlayUIDelegate.propList.rightPropList.springItem:PlayFullAnim()
            end

            if not PigYearLogic:getShowSkillGuideType() then
                if mainLogic.PlayUIDelegate.propList.rightPropList.springItem.playFlyNut then
                    mainLogic.PlayUIDelegate.propList.rightPropList.springItem:playFlyNut()
                    PigYearLogic:setShowSkillGuideType()
                end
            end
        end
    end
end

--更新技能数
function SpringFestival2019Manager:ShowRedPointAndUpdate()
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and  mainLogic.PlayUIDelegate.propList.rightPropList 
            and mainLogic.PlayUIDelegate.propList.rightPropList.springItem 
            and mainLogic.PlayUIDelegate.propList.rightPropList.springItem.ShowRedPointAndUpdate then

            local canUseAllNum = 0
            for i,v in ipairs(self.GemNumList) do
                local haveNum = v
                local cost = PicYearMeta.SkillCost[i]

                local canUseNum = math.floor( haveNum/cost )

                canUseAllNum = canUseAllNum + canUseNum
            end

            mainLogic.PlayUIDelegate.propList.rightPropList.springItem:ShowRedPointAndUpdate( canUseAllNum )
        end
    end
end

function SpringFestival2019Manager:setUseMove( )
    if self:getCurLevelCreateRightPropList() then
        self.useMove = self.useMove + 1

        self:updateSkillPanel()

        if self.useMove >= 5 and self:isHaveCanUseSkill() and self.isShowSkillTip == false then
            self:showSkillCanUseTip()
            self.isShowSkillTip = true
        end
    end
end

function SpringFestival2019Manager:getUseMove( )
    return self.useMove
end

function SpringFestival2019Manager:isHaveCanUseSkill( )

    if not self.GemNumList then return false end 

    local bCanUse = false
    for i,v in ipairs(self.GemNumList) do
        if v >= PicYearMeta.SkillCost[i] and self.UseSkillList[i] == false then
            bCanUse = true 
            break
        end
    end

    return bCanUse
end


function SpringFestival2019Manager:updateSkillPanel( )
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and  mainLogic.PlayUIDelegate.propList.rightPropList 
            and mainLogic.PlayUIDelegate.propList.rightPropList.springItem
            and mainLogic.PlayUIDelegate.propList.rightPropList.springItem.SpringFestival2019SkillPanel then

            local SpringFestival2019SkillPanel = mainLogic.PlayUIDelegate.propList.rightPropList.springItem.SpringFestival2019SkillPanel
            if not SpringFestival2019SkillPanel.isDisposed then
                SpringFestival2019SkillPanel:updateSkillInfo()
            end
        end
    end
end

function SpringFestival2019Manager:GetSkill1Info()
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local canBeInfectItemList = {}
    local subCanBeInfectItemList = {}
    local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap

    for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item then 
				local intCoord = IntCoord:create(r, c)
				if item:canInfectBySpringFestivalSkill1() then
                    if boardMap[r][c].buffBoomPassSelect 
                        or boardMap[r][c].preAndBuffFirecrackerPassSelect 
                        or boardMap[r][c].preAndBuffLineWrapPassSelect 
                        or boardMap[r][c].preAndBuffMagicBirdPassSelect  then 
						table.insert(subCanBeInfectItemList, intCoord)
                    else
					    table.insert(canBeInfectItemList, intCoord)
                    end
				end
			end 
		end
	end

    local infectList = {}
    if #canBeInfectItemList > 0 then
		--todo 
		item = table.remove(canBeInfectItemList, mainLogic.randFactory:rand(1, #canBeInfectItemList))
		table.insert(infectList, item)
	elseif #subCanBeInfectItemList > 0 then 
        --没地了考虑设置不扔的地方
		item = table.remove(subCanBeInfectItemList, mainLogic.randFactory:rand(1, #subCanBeInfectItemList))
		table.insert(infectList, item)
	end

    return infectList
end

function SpringFestival2019Manager:setSkill2Info()
    self.scoreAddPercent = 0.5
end

function SpringFestival2019Manager:getSkill2Info()
    return self.scoreAddPercent or 0
end

function SpringFestival2019Manager:GetSkill3Info()

    mainLogic = GameBoardLogic:getCurrentLogic()

    self:resetHotMap( mainLogic )

    local PosList = {}
    for k = 1, MAX_COUNT_ATTACK do 
		local lucy_p = self:getLuckyPoint( mainLogic )

        local Info = {}
        Info.r_min = lucy_p.x
        Info.c_min = lucy_p.y
        Info.r_max = lucy_p.x + 1
        Info.c_max = lucy_p.y + 1
        Info.delayIndex = 1
        table.insert( PosList, Info )

		self:adjustHotMapAfterAttack(lucy_p)
	end

    return PosList
end

function SpringFestival2019Manager:GetSkill4Info()

    mainLogic = GameBoardLogic:getCurrentLogic()

    local AnimalNumList = {}
    local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap


    local function getColorIndexByColorType( ItemColorType)
        local index = 0
        if ItemColorType == AnimalTypeConfig.kBlue then
            index = 1
        elseif ItemColorType == AnimalTypeConfig.kGreen then
            index = 2
        elseif ItemColorType == AnimalTypeConfig.kOrange then
            index = 3
        elseif ItemColorType == AnimalTypeConfig.kPurple then
            index = 4
        elseif ItemColorType == AnimalTypeConfig.kRed then
            index = 5
        elseif ItemColorType == AnimalTypeConfig.kYellow then
            index = 6
        end

        return index
    end

    for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item and item:canInfectBySpringFestivalSkill4() then 
				local intCoord = IntCoord:create(r, c)

                local colorIndex = getColorIndexByColorType(item._encrypt.ItemColorType)

                if not AnimalNumList[colorIndex] then
                    AnimalNumList[colorIndex] = {}
                    AnimalNumList[colorIndex].num = 1
                    AnimalNumList[colorIndex].posList = {}

                    table.insert( AnimalNumList[colorIndex].posList, intCoord )
                else
                    AnimalNumList[colorIndex].num =  AnimalNumList[colorIndex].num + 1
                    table.insert( AnimalNumList[colorIndex].posList, intCoord )
                end
			end 
		end
	end

    local maxColor = 0
    local maxIndex = 0
    for i,v in pairs( AnimalNumList ) do
        if v.num > maxColor then
            maxColor = v.num
            maxIndex = i
        end
    end

    if maxIndex ~= 0 then
        local posList = {}
        local posList2 = {}
        local posList3 = {}
        local posList4 = {}
        for i,v in ipairs(AnimalNumList[maxIndex].posList) do

            local r = v.x
            local c = v.y

            local itemData = gameItemMap[r][c]
            if itemData then
                if itemData.ItemType == GameItemType.kAnimal  
                    and itemData.ItemSpecialType ~= AnimalTypeConfig.kColor
                    and itemData.ItemSpecialType ~= AnimalTypeConfig.kLine 
                    and itemData.ItemSpecialType ~= AnimalTypeConfig.kColumn 
                    and itemData.ItemSpecialType ~= AnimalTypeConfig.kWrap  then
                    table.insert( posList, v )
                elseif itemData.ItemType == GameItemType.kCrystal then
                    table.insert( posList2, v )
                elseif itemData.ItemType ~= GameItemType.kAnimal then
                    table.insert( posList3, v )
                elseif itemData.ItemType == GameItemType.kAnimal 
                     and itemData.ItemSpecialType ~= AnimalTypeConfig.kColor then
                    table.insert( posList4, v )
                end
            end
        end

        local FinalPosList = {}
        for i=1, 10 do
            local bFind = false

            if #posList > 0 then
                local pos = mainLogic.randFactory:rand(1, #posList)
                table.insert( FinalPosList,posList[pos] )
                table.remove( posList,pos )
                bFind = true
            elseif #posList2 > 0 then
                local pos = mainLogic.randFactory:rand(1, #posList2)
                table.insert( FinalPosList,posList2[pos] )
                table.remove( posList2,pos )
                bFind = true
            elseif #posList3 > 0 then
                local pos = mainLogic.randFactory:rand(1, #posList3)
                table.insert( FinalPosList,posList3[pos] )
                table.remove( posList3,pos )
                bFind = true
            elseif #posList4 > 0 then
                local pos = mainLogic.randFactory:rand(1, #posList4)
                table.insert( FinalPosList,posList4[pos] )
                table.remove( posList4,pos )
                bFind = true
            end

            if bFind == false then break end
        end
        return FinalPosList
    end


    return {}
end

function SpringFestival2019Manager:getLuckyPoint( mainLogic )
	-- body
	local max_priority = 0
	local array_max_priority = {}

	local ss = "";
	for r = 1, #self.hotmap do 
		for c = 1,#self.hotmap[r] do
			ss = ss.."|"..self.hotmap[r][c]
			if self.hotmap[r][c] > max_priority then 
				array_max_priority = {}
				max_priority = self.hotmap[r][c]
				table.insert(array_max_priority, IntCoord:create(r, c))
			elseif self.hotmap[r][c] == max_priority then 
				table.insert(array_max_priority, IntCoord:create(r, c))
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, ss) end
		ss = ""

	end

	local index = mainLogic.randFactory:rand(1,#array_max_priority)
	local p_r = math.min( array_max_priority[index].x, 8)
	local p_c = math.min( array_max_priority[index].y, 8)
	-- if _G.isLocalDevelopMode then printx(0, p_r, p_c) end debug.debug()
	self:caculateHotMap(p_r, p_c)
	self:caculateHotMap(p_r, p_c + 1)
--	self:caculateHotMap(p_r, p_c + 2)
	self:caculateHotMap(p_r + 1, p_c)
	self:caculateHotMap(p_r + 1, p_c + 1)
--	self:caculateHotMap(p_r + 1, p_c + 2)
	return IntCoord:create(p_r, p_c)
end

--影响区域
--算法：当踩踏x时 标注1的位置会被影响
-- 1 1 1 1 1 0 0 0
-- 1 1 x 0 0 0 0 0
-- 1 1 0 0 0 0 0 0
-- 0 0 0 0 0 0 0 0
local effectPList = {
	{r = -1, c = -1}, {r = -1, c = -2}, {r = -1, c = 0}, {r = -1, c = 1}, {r = -1, c = 2},
	{r = 0, c = -1}, {r = 0, c = -2}, 
	{r = 1, c = -1}, {r = 1, c = -2}
}
function SpringFestival2019Manager:adjustHotMapAfterAttack( pt )
	-- body
	if not pt then return end

	local function isValidateTile( r , c )
		-- body
		if r < 1 or r > 9 then return false end
		if c < 1 or c > 9 then return false end

		return true
	end

	for k, v in pairs(effectPList) do 
		local c_r = v.r + pt.x
		local c_c = v.c + pt.y
		if isValidateTile(c_r,c_c) then 
            if self.hotmap[c_r][c_c] ~= PriorityNoSelectPoint then
			    self.hotmap[c_r][c_c] = self.hotmap[c_r][c_c] / 2
            end
		end
	end
end

function SpringFestival2019Manager:resetHotMap( mainLogic )
	-- body
	self.hotmap = {}
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		self.hotmap[r] = {}
		for c = 1, #gameItemMap[r] do 
			self.hotmap[r][c] = self:getPrior( mainLogic, r, c)
		end
	end
end

function SpringFestival2019Manager:caculateHotMap( r, c )
	-- body
    if self.hotmap[r][c] ~= PriorityNoSelectPoint then
	    self.hotmap[r][c] = PriorityBlackPoint
    end
end

function SpringFestival2019Manager:getPrior( mainLogic, r, c )
	-- body
	local itemData = mainLogic.gameItemMap[r][c]
	local boradData = mainLogic.boardmap[r][c]

--	if boradData:isBigMonsterEffectPrior1() and itemData:isColorful() and (not itemData.isBlock) then
--		return Priority1Weight
--	elseif itemData:isBigMonsterEffectPrior1() then 
--		return Priority1Weight
--	elseif itemData:isBigMonsterEffectPrior2() or boradData:isBigMonsterEffectPrior2() then 
--		return Priority2Weight
--	elseif itemData:isBigMonsterEffectPrior3() or boradData:isBigMonsterEffectPrior3() then 
--		return Priority3Weight
--	else
--		return PriorityInit
--	end

    if boradData.isUsed then
        return Priority1Weight
    end

    --改为统一优先级
    return PriorityNoSelectPoint 
end

--------------------

function SpringFestival2019Manager:playSpringFestivalAnim1( WorldSpace, toWorldPos )
    local UIHelper = require 'zoo.panel.UIHelper'
	
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local curScene = Director.sharedDirector():getRunningScene()

    local emptyLayer = Layer:create()
    local emptySprite = Sprite:createEmpty()
    emptyLayer:addChild(emptySprite)
    curScene:addChild( emptyLayer, SceneLayerShowKey.TOP_LAYER )

    local resName = 'SpringFestival2019_anim/ani_2'
	local arrowAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	emptySprite:addChild(arrowAnim)
	arrowAnim:setPosition(ccp(0,0))
    arrowAnim:setVisible(false)


    local function AnimationEnd()
        if emptyLayer and emptyLayer:getParent() then
			emptyLayer:removeFromParentAndCleanup(true)
		end
    end

    local function ActionCall()
        --动作 从技能位置 飞到目标位置
        local NodeSpace = arrowAnim:getParent():convertToNodeSpace( ccp(WorldSpace.x+101/2,WorldSpace.y-101/2) ) -- -172/0.7
        arrowAnim:setPosition( NodeSpace )
    
        local fromPos = NodeSpace

        local wSize = CCDirector:sharedDirector():getWinSize()
        local toPos = arrowAnim:getParent():convertToNodeSpace( ccp(toWorldPos.x,toWorldPos.y) ) 

        local function PlayBoom()

            local BoomPos = emptySprite:convertToNodeSpace( ccp(toWorldPos.x,toWorldPos.y) ) 

            local resName = 'SpringFestival2019_anim/ani_3'
	        local boomAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	        emptySprite:addChild(boomAnim)
	        boomAnim:setPosition(BoomPos)

            boomAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                boomAnim:removeAllEventListeners()
                boomAnim:setVisible(false)
                AnimationEnd()
            end)
            boomAnim:play("a" )
        end

        local function PlayAnim3()
            arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
                arrowAnim:setVisible(false)
    	        PlayBoom()
            end)
            arrowAnim:play("c",1 )
        end

        arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
    	        arrowAnim:play("b")
            end)
        arrowAnim:play("a",1 )

        --旋转
        local rotation = 0
	    if toPos.y - fromPos.y > 0 then
		    rotation = math.deg(math.atan((toPos.x - fromPos.x)/(toPos.y - fromPos.y)))
	    elseif toPos.y -fromPos.y < 0 then
		    rotation = 180 + math.deg(math.atan((toPos.x - fromPos.x) / (toPos.y - fromPos.y)))
	    else
		    if toPos.x - fromPos.x > 0 then rotation = 90
		    else
			    rotation = -90
		    end
	    end
        arrowAnim:setRotation( rotation )

        --动作
        local array = CCArray:create()
        array:addObject( CCMoveTo:create(0.3, toPos ) )
        array:addObject( CCCallFunc:create(PlayAnim3) )
        arrowAnim:setVisible(true)
        arrowAnim:runAction( CCSequence:create(array) )
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create(ActionCall) )
    emptySprite:runAction( CCSequence:create(array) )
end

function SpringFestival2019Manager:playSpringFestivalAnim2( WorldSpace )

    local UIHelper = require 'zoo.panel.UIHelper'
	
    local mainLogic = GameBoardLogic:getCurrentLogic()

    if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.scoreProgressBar and mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation then
    else
        return
    end

    local curScene = Director.sharedDirector():getRunningScene()

    local emptyLayer = Layer:create()
    local emptySprite = Sprite:createEmpty()
    emptyLayer:addChild(emptySprite)
    curScene:addChild( emptyLayer, SceneLayerShowKey.TOP_LAYER )

    local resName = 'SpringFestival2019_anim/ani_2'
	local arrowAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	emptySprite:addChild(arrowAnim)
	arrowAnim:setPosition(ccp(0,0))
    arrowAnim:setVisible(false)


    local function AnimationEnd()
        if emptyLayer and emptyLayer:getParent() then
			emptyLayer:removeFromParentAndCleanup(true)
		end
    end

    local function ActionCall()
        --动作 从技能位置 飞到目标位置
        local NodeSpace = arrowAnim:getParent():convertToNodeSpace( ccp(WorldSpace.x+101/2,WorldSpace.y-101/2) ) -- -172/0.7
        arrowAnim:setPosition( NodeSpace )
    

        local fromPos = NodeSpace

        local background = mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation.background
        local scale = background:getScale()
        local backgroungWorldPos = background:getParent():convertToWorldSpace( background:getPosition() )
        local toPos = arrowAnim:getParent():convertToNodeSpace( ccp(backgroungWorldPos.x+181/0.7,backgroungWorldPos.y-35/0.7) ) 

        local function PlayBoom()
            local BoomPos = arrowAnim:getParent():convertToNodeSpace( ccp(backgroungWorldPos.x-10/0.7,backgroungWorldPos.y-25/0.7) ) 

            local resName = 'SpringFestival2019_anim/ani_4'
	        local boomAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
            boomAnim:setScale( scale ) 
	        emptySprite:addChild(boomAnim)
	        boomAnim:setPosition(ccp(BoomPos.x,BoomPos.y))

            boomAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                boomAnim:removeAllEventListeners()
                boomAnim:setVisible(false)
                AnimationEnd()
            end)
            boomAnim:play("a" )


            --树枝进度背景显示
            if mainLogic then
                if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.scoreProgressBar and mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation then
                    if mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation.addpercentbg then
                        local addpercentBg = mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation.addpercentbg
                        --动作
                        local animationTime = 1
                        local array = CCArray:create()
                        array:addObject( CCFadeIn:create(animationTime)  )
                        array:addObject( CCFadeOut:create(animationTime) )
                        addpercentBg:runAction( CCRepeatForever:create( CCSequence:create(array) ) )
                        addpercentBg:setVisible(true)
                    end


                    if mainLogic.PlayUIDelegate.scoreProgressBar.addPercentSprite then
                        mainLogic.PlayUIDelegate.scoreProgressBar.addPercentSprite:setVisible(true)
                    end
                end
            end
        end

        local function PlayAnim3()
            arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
                arrowAnim:setVisible(false)
    	        PlayBoom()
            end)
            arrowAnim:play("c",1 )
        end

        arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
    	        arrowAnim:play("b")
            end)
        arrowAnim:play("a",1 )

        --旋转
        local rotation = 0
	    if toPos.y - fromPos.y > 0 then
		    rotation = math.deg(math.atan((toPos.x - fromPos.x)/(toPos.y - fromPos.y)))
	    elseif toPos.y -fromPos.y < 0 then
		    rotation = 180 + math.deg(math.atan((toPos.x - fromPos.x) / (toPos.y - fromPos.y)))
	    else
		    if toPos.x - fromPos.x > 0 then rotation = 90
		    else
			    rotation = -90
		    end
	    end
        arrowAnim:setRotation( rotation )

        --动作
        local array = CCArray:create()
        array:addObject( CCMoveTo:create(0.3, toPos ) )
        array:addObject( CCCallFunc:create(PlayAnim3) )
        arrowAnim:setVisible(true)
        arrowAnim:runAction( CCSequence:create(array) )
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create(ActionCall) )
    emptySprite:runAction( CCSequence:create(array) )
end


function SpringFestival2019Manager:playSpringFestivalAnim3( WorldSpace, toWorldPos )

    local UIHelper = require 'zoo.panel.UIHelper'
	
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local curScene = Director.sharedDirector():getRunningScene()

    local emptyLayer = Layer:create()
    local emptySprite = Sprite:createEmpty()
    emptyLayer:addChild(emptySprite)
    curScene:addChild( emptyLayer )

	local arrowAnim = Sprite:createWithSpriteFrameName("SpringFestival_2019res/boom0000")
	emptySprite:addChild(arrowAnim)
	arrowAnim:setPosition(ccp(0,0))
    arrowAnim:setVisible(false)

    local function AnimationEnd()
        if emptyLayer and emptyLayer:getParent() then
			emptyLayer:removeFromParentAndCleanup(true)
		end
    end

    local function ActionCall()

        --动作 从技能位置 飞到目标位置
        local NodeSpace = arrowAnim:getParent():convertToNodeSpace( ccp(WorldSpace.x+101/2,WorldSpace.y-101/2) ) -- -172/0.7
        arrowAnim:setPosition( NodeSpace )
    
        local fromPos = NodeSpace

--        local background = mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation.background
--        local backgroungWorldPos = background:getParent():convertToWorldSpace( background:getPosition() )
        local toPos = arrowAnim:getParent():convertToNodeSpace( ccp(toWorldPos.x+70-22/0.7,toWorldPos.y-70+24/0.7) ) 

        local function PlayBoom()
            arrowAnim:setVisible(false)

            local resName = 'SpringFestival2019_anim/ani_5'
	        local boomAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	        emptySprite:addChild(boomAnim)
	        boomAnim:setPosition(ccp(toPos.x,toPos.y))

            boomAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                boomAnim:removeAllEventListeners()
                boomAnim:setVisible(false)
                AnimationEnd()
            end)
            boomAnim:play("a")
        end

        --动作
        local array = CCArray:create()
        array:addObject( CCMoveTo:create(0.3, toPos ) )
        array:addObject( CCCallFunc:create(PlayBoom) )
        arrowAnim:setVisible(true)
        arrowAnim:stopAllActions()
        arrowAnim:runAction( CCSequence:create(array) )
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create(ActionCall) )
    emptySprite:stopAllActions()
    emptySprite:runAction( CCSequence:create(array) )
end


function SpringFestival2019Manager:playSpringFestivalAnim4( WorldSpace, toWorldPosList )

    local UIHelper = require 'zoo.panel.UIHelper'
	
    local mainLogic = GameBoardLogic:getCurrentLogic()

    local curScene = Director.sharedDirector():getRunningScene()

    local emptyLayer = Layer:create()
    local emptySprite = Sprite:createEmpty()
    emptyLayer:addChild(emptySprite)
    curScene:addChild( emptyLayer, SceneLayerShowKey.TOP_LAYER )

    local resName = 'SpringFestival2019_anim/ani_2'
	local arrowAnim = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
	emptySprite:addChild(arrowAnim)
	arrowAnim:setPosition(ccp(0,0))
    arrowAnim:setVisible(false)


    local function AnimationEnd()
        if emptyLayer and emptyLayer:getParent() then
			emptyLayer:removeFromParentAndCleanup(true)
		end
    end

    local function ActionCall()
        --动作 从技能位置 飞到目标位置
        local NodeSpace = arrowAnim:getParent():convertToNodeSpace( ccp(WorldSpace.x+101/2,WorldSpace.y-101/2) ) -- -172/0.7
        arrowAnim:setPosition( NodeSpace )
    
        local fromPos = NodeSpace

        local wSize = CCDirector:sharedDirector():getWinSize()
        local toPos = arrowAnim:getParent():convertToNodeSpace( ccp(wSize.width/2,wSize.height/2) ) 

        local function BirdShowEnd()
            if emptySprite and emptySprite.BirdAnim then
				emptySprite.BirdAnim.playDisappear()
			end

            if emptySprite and emptySprite.effectSprite then
                emptySprite.effectSprite:setVisible(false)
            end

            if emptySprite and emptySprite.mainSprite then
                emptySprite.mainSprite:setVisible(false)
            end


            local function arriveCallback()
                
            end

            local function onAnimComplete()
                
            end

            for i,v in ipairs(toWorldPosList) do
                local animation = CommonEffect:buildBirdEffectFlyAnim(AnimalTypeConfig.kLine, toPos, v, 0.5, arriveCallback, onAnimComplete)
                emptySprite:addChild(animation)
            end
        end
            
        local function PlayBirdShow()
            
            --动画
            local BirdAnim = TileBird:createBirdDestroyEffectForever(scaleTo)
		    BirdAnim:setPosition(toPos)
            emptySprite:addChild(BirdAnim)
            emptySprite.BirdAnim = BirdAnim

            local array = CCArray:create()
            array:addObject( CCDelayTime:create(0.5 ) )
            array:addObject( CCCallFunc:create(BirdShowEnd) )
            BirdAnim:runAction( CCSequence:create(array))

            --鸟
            local effectSprite = Sprite:createWithSpriteFrameName("bird_bg_effect_0000")
            effectSprite:setPosition(toPos)
            emptySprite.effectSprite = effectSprite
            emptySprite:addChild(effectSprite)

            local frames = SpriteUtil:buildFrames("bird_bg_effect_%04d", 0, 20)
            local animate = SpriteUtil:buildAnimate(frames, 1/30)
            effectSprite:play(animate)

            local mainSprite = Sprite:createWithSpriteFrameName("bird_normal_0000")
            mainSprite:setPosition(toPos)
            emptySprite.mainSprite = mainSprite
            emptySprite:addChild(mainSprite)
        end

        local function PlayAnim3()
            arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
                arrowAnim:setVisible(false)
    	        PlayBirdShow()
            end)
            arrowAnim:play("c",1 )
        end

        arrowAnim:addEventListener(ArmatureEvents.COMPLETE, function()
                arrowAnim:removeAllEventListeners()
    	        arrowAnim:play("b")
            end)
        arrowAnim:play("a",1 )

        --旋转
        local rotation = 0
	    if toPos.y - fromPos.y > 0 then
		    rotation = math.deg(math.atan((toPos.x - fromPos.x)/(toPos.y - fromPos.y)))
	    elseif toPos.y -fromPos.y < 0 then
		    rotation = 180 + math.deg(math.atan((toPos.x - fromPos.x) / (toPos.y - fromPos.y)))
	    else
		    if toPos.x - fromPos.x > 0 then rotation = 90
		    else
			    rotation = -90
		    end
	    end
        arrowAnim:setRotation( rotation )

        --动作
        local array = CCArray:create()
        array:addObject( CCMoveTo:create(0.3, toPos ) )
        array:addObject( CCCallFunc:create(PlayAnim3) )
        arrowAnim:setVisible(true)
        arrowAnim:runAction( CCSequence:create(array) )
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create(ActionCall) )
    emptySprite:runAction( CCSequence:create(array) )
end

function SpringFestival2019Manager:DC( category, sub_category, par1,par2,par3,par4,part5,part6 )
    local params = {
		game_type = "stage",
		game_name = "5years",
		category = category,
		sub_category = sub_category,
		t1 = par1,
        t2 = par2,
        t3 = par3,
        t4 = par4,
        t5 = part5,
        t6 = part6,
	}

	DcUtil:activity(params)
end

function SpringFestival2019Manager:DCAddPlayID( category, sub_category, par1,par2,par3,par4,part5,part6,part7 )
    local params = {
		game_type = "stage",
		game_name = "5years",
		category = category,
		sub_category = sub_category,
        playId = GamePlayContext:getInstance():getIdStr(),
		t1 = par1,
        t2 = par2,
        t3 = par3,
        t4 = par4,
        t5 = part5,
        t6 = part6,
        t7 = part7,
	}

	DcUtil:activity(params)
end

function SpringFestival2019Manager:DCForStageEnd()
    local levelId = SpringFestival2019Manager:getInstance().levelID
    local LevelPlayType = SpringFestival2019Manager:getInstance().LevelPlayType
    local luckyBagDoubleNum = SpringFestival2019Manager.getInstance().passLevelCanGet.luckyBagDoubleNum
    local TicketType = SpringFestival2019Manager.getInstance().passLevelCanGet.TicketType
    local ticketNum = SpringFestival2019Manager.getInstance().passLevelCanGet.ticketNum

    local goldNum = 0
    local stoneNum = 0
    local stoneID = 0

    goldNum = ticketNum

    stoneNum = self.EndMoveStep
    stoneID = self.EndMoveSkillID


    if stoneNum > PicYearMeta.BonsTimeMaxNum then stoneNum = PicYearMeta.BonsTimeMaxNum end

    self:DCAddPlayID( "stage","5years_stage_end", levelId, LevelPlayType, luckyBagDoubleNum, goldNum, stoneNum, stoneID )
end


---------------------------------------------- Revert (后退一步/断面恢复) -----------------------------------------
function SpringFestival2019Manager:getDataForRevert()

	local springFestival2019Data = {}

	springFestival2019Data.scoreAddPercent = self.scoreAddPercent
    springFestival2019Data.useMove = self.useMove
    springFestival2019Data.CurIsAct = self.CurIsAct
    springFestival2019Data.curLevelCanGetInfo = self.curLevelCanGetInfo
    springFestival2019Data.GemNumList = self.GemNumList
    springFestival2019Data.LevelPlayType = self.LevelPlayType
    springFestival2019Data.levelID = self.levelID
    springFestival2019Data.levelStar = self.levelStar
    springFestival2019Data.SpeedCardNum = self.SpeedCardNum
    springFestival2019Data.CurIsActSkill = self.CurIsActSkill
    springFestival2019Data.UseSkillList = self.UseSkillList
    springFestival2019Data.levelPlayCount = self.levelPlayCount
    springFestival2019Data.lastLevelStar = self.lastLevelStar
    springFestival2019Data.isShowSkillTip = self.isShowSkillTip
    

	return springFestival2019Data
end

function SpringFestival2019Manager:setByRevertData(springFestival2019Data)
	if springFestival2019Data then
		self.scoreAddPercent = springFestival2019Data.scoreAddPercent or 0
        self.useMove = springFestival2019Data.useMove or 0
        self.CurIsAct = springFestival2019Data.CurIsAct or false
        self.curLevelCanGetInfo = springFestival2019Data.curLevelCanGetInfo or {}
        self.GemNumList = springFestival2019Data.GemNumList or {0,0,0,0}
        self.LevelPlayType = springFestival2019Data.LevelPlayType or {0,0,0,0}
        self.levelID = springFestival2019Data.levelID or 0
        self.levelStar = springFestival2019Data.levelStar or 0
        self.SpeedCardNum = springFestival2019Data.SpeedCardNum or 0
        self.CurIsActSkill = springFestival2019Data.CurIsActSkill or false
        self.UseSkillList = springFestival2019Data.UseSkillList or {false,false,false,false}
        self.levelPlayCount = springFestival2019Data.levelPlayCount or 0
        self.lastLevelStar = springFestival2019Data.lastLevelStar or 0
        self.isShowSkillTip = springFestival2019Data.isShowSkillTip or false
        
        if self.scoreAddPercent > 0 then
            local mainLogic = GameBoardLogic:getCurrentLogic()
            if mainLogic and mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.scoreProgressBar and mainLogic.PlayUIDelegate.scoreProgressBar.addPercentSprite then
                mainLogic.PlayUIDelegate.scoreProgressBar.addPercentSprite:setVisible(true)
            end
        end
	end
end

-------------------------------------