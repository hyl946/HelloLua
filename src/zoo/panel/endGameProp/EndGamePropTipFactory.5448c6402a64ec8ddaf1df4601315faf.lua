local UIHelper = require 'zoo.panel.UIHelper'


local EndGamePropTipFactory = class()

local TipType = {
	kDropACT = 1,
	kPreBuff = 2,
	kFUUU = 3,
	kNormal = 4,

	--特殊活动 优先级无条件最高
	kSpecACT1 = 5,
	kSpecACT2 = 6,

	kScoreBuff = 7,

    kDropACT2 = 8,
}

EndGamePropTipFactory.TipType = TipType

-- EndGamePropTipFactory.__debug_act = true
-- EndGamePropTipFactory.__debug_prebuff = true
-- EndGamePropTipFactory.__debug_fuuu = true

local validLevelType = {
	GameLevelType.kMainLevel, 
	GameLevelType.kHiddenLevel,
	GameLevelType.kFourYears,
    GameLevelType.kSummerFish,
    GameLevelType.kSpring2019,
}

function EndGamePropTipFactory:debugAct()
	self.__debug_act = not self.__debug_act
	return self.__debug_act
end

function EndGamePropTipFactory:debugPrebuff()
	self.__debug_prebuff = not self.__debug_prebuff
	return self.__debug_prebuff
end

function EndGamePropTipFactory:debugFUUU()
	self.__debug_fuuu = not self.__debug_fuuu
	return self.__debug_fuuu
end


function EndGamePropTipFactory:getData( panel )

	local data = {}

	local drapActData = self:checkDropActData(panel)
	if drapActData then
		drapActData.type = TipType.kDropACT
		table.insert(data, drapActData)
	end

    local drapActData2 = self:checkDropActData2(panel)
	if drapActData2 then
		drapActData2.type = TipType.kDropACT2
		table.insert(data, drapActData2)
	end

	local preBuffData = self:checkPreBuffData(panel)
	if preBuffData then
		preBuffData.type = TipType.kPreBuff
		table.insert(data, preBuffData)
	end

	local scoreBuffData = self:checkScoreBuffData(panel)
	if scoreBuffData then
		scoreBuffData.type = TipType.kScoreBuff
		table.insert(data, scoreBuffData)
	end

	local fuuuData = self:checkFUUUData(panel)
	if fuuuData then
		fuuuData.type = TipType.kFUUU
		table.insert(data, fuuuData)
	end

	local normalData = self:checkNormalData(panel)
	if normalData then
		normalData.type = TipType.kNormal
		table.insert(data, normalData)
	end

	local specACT1Data = self:checkSpecACT1Data(panel)
	if specACT1Data then
		specACT1Data.type = TipType.kSpecACT1
		table.insert(data, specACT1Data)
	end

	local specACT2Data = self:checkSpecACT2Data(panel)
	if specACT2Data then
		specACT2Data.type = TipType.kSpecACT2
		table.insert(data, specACT2Data)
	end

	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end

    local limit = 1
    local priority = {}

    if specACT2Data then
		table.insert(priority, TipType.kSpecACT2)
    end

    if specACT1Data then
		table.insert(priority, TipType.kSpecACT1)
    end

	-- 产品保证：preBuffData 和 scoreBuffData 的活动不会同时开启
    local hasBuffData = preBuffData or scoreBuffData

	if (not drapActData) and hasBuffData then
		if fuuuData then
			table.insert(priority, TipType.kDropACT)
			table.insert(priority, TipType.kFUUU)
			table.insert(priority, TipType.kPreBuff)
			-- table.insert(priority, TipType.kScoreBuff)
			table.insert(priority, TipType.kNormal)
		else
			table.insert(priority, TipType.kDropACT)
			table.insert(priority, TipType.kNormal)
			table.insert(priority, TipType.kPreBuff)
			-- table.insert(priority, TipType.kScoreBuff)
			table.insert(priority, TipType.kFUUU)
		end
	else
		table.insert(priority, TipType.kDropACT)
        table.insert(priority, TipType.kDropACT2)
		table.insert(priority, TipType.kPreBuff)
		-- table.insert(priority, TipType.kScoreBuff)
		table.insert(priority, TipType.kFUUU)
		table.insert(priority, TipType.kNormal)
	end

	if specACT1Data or specACT2Data then
		limit = 2
	elseif (not drapActData) and (not hasBuffData) then
		limit = 1
    elseif drapActData and drapActData2 then
        limit = 2
	elseif drapActData and (not hasBuffData) then
		limit = 1
	elseif (not drapActData) and hasBuffData then
		limit = 2
	elseif drapActData and hasBuffData then
		limit = 2
    
	end

	-- limit = 10
	
	table.sort(data, function ( a, b )
		-- body
		local pa = table.indexOf(priority, a.type) or 0
		local pb = table.indexOf(priority, b.type) or 0

		return pa < pb 
	end)
	if _G.isLocalDevelopMode  then printx(103 , "EndGamePropTipFactory:getData() data = " , table.tostring(data[1].type) ) end
	if _G.isLocalDevelopMode  then printx(103 , "EndGamePropTipFactory:getData() limit = " , limit ) end
	local ret = {}
	for i = 1, limit do
		ret[i] = data[i]
	end

	return ret

end

function EndGamePropTipFactory:checkSpecACT2Data( panel )
	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)
	if not isSupportedLevelType then
		return
	end

	if not DragonBuffManager then
		return
	end

	if not DragonBuffManager.getInstance():isActivitySupport() then
		return
	end

	local triggeredDragonBuff = DragonBuffManager.getInstance():getCurBuffLevelInGame()

	if triggeredDragonBuff then

		return {
			creator = function ( panel )

				local gameLogic = GameBoardLogic:getCurrentLogic() or {}
				local targetCount = gameLogic.actCollectionNum or 0
				-- ui会被加到 574x57的一个区域里
				local ui = UIHelper:createUI("ui/temp/dragon_buff_add_step.json", "dragon.buff.add.step.res/specACT2")
				ui = UIHelper:replaceLayer2LayerColor(ui)


				local nextPoints = 0

				for i = 1, triggeredDragonBuff[2] + triggeredDragonBuff[1] do
					nextPoints = nextPoints + DragonBuffManager.getInstance():getNextPoints(i)
				end

				local dist = nextPoints - triggeredDragonBuff[3]

				local label1 = BitmapText:create(tostring(dist), "fnt/dragon2018_5steps.fnt", -1, kCCTextAlignmentLeft)
				local tip = ui:getChildByPath('tip')
				tip:addChild(label1)
				local numHolder1 = ui:getChildByPath('tip/num')
				local dimension1 = numHolder1:getDimensions()
				label1:setAnchorPoint(ccp(0.5, 0.5))
				label1:setPositionX(numHolder1:getPositionX() + dimension1.width/2)
				label1:setPositionY(numHolder1:getPositionY() - dimension1.height/2)

				local buffIconIndex = math.clamp(triggeredDragonBuff[1] + 1, 2, 5)
				for i = 2, 5 do
					local icon = ui:getChildByPath('tip/buffs/' .. i)
					icon:setVisible(i == buffIconIndex)

					if i == buffIconIndex then
						ui.icons = {icon}
					end

				end

				local buffs = ui:getChildByPath('tip/buffs')
				local l1 = ui:getChildByPath('tip/l1')
				local l2 = ui:getChildByPath('tip/l2')
				local l3 = ui:getChildByPath('tip/l3')
				local l4 = ui:getChildByPath('tip/l4')

				buffs:setVisible(false)
				l1:setVisible(false)
				l2:setVisible(false)
				l3:setVisible(false)
				l4:setVisible(false)




				local timerLabel = ui:getChildByPath('tip/timer')

				local expireTime = triggeredDragonBuff[5]
				local time = expireTime - Localhost:time()

				if triggeredDragonBuff[1] > 1 and time > 0 then

					if triggeredDragonBuff[1] >= 5 then
						l4:setVisible(true)
						l2:setVisible(true)
					else
						l1:setVisible(true)
						l2:setVisible(true)
						buffs:setVisible(true)
					end

					local timerLabel = BitmapText:create(tostring(dist), "fnt/tutorial_white.fnt", -1, kCCTextAlignmentLeft)
					tip:addChild(timerLabel)
					local numHolder1 = ui:getChildByPath('tip/timer')
					local dimension1 = numHolder1:getDimensions()
					timerLabel:setAnchorPoint(ccp(1.0, 0.5))
					timerLabel:setPositionX(numHolder1:getPositionX() + dimension1.width)
					timerLabel:setPositionY(numHolder1:getPositionY() - dimension1.height/2)

					local expireTime = triggeredDragonBuff[5]

					local function __refreshTimer( ... )

						if ui.isDisposed then return end

						local time = math.max(expireTime - Localhost:time(), 0)
						time = math.floor(time / 1000)
						local hh = math.floor(time / 3600)
						local mm = math.floor(time % 3600 / 60)
						local ss = math.floor(time % 60)

						timerLabel:setText(string.format('%02d:%02d:%02d', hh, mm, ss))

					end

					ui.oneSecondTimer	= OneSecondTimer:create()
					ui.oneSecondTimer:setOneSecondCallback(__refreshTimer)

					local __dispose = ui.dispose

					function ui:dispose( ... )
						__dispose(self, ...)
						self.oneSecondTimer:stop()
					end

					__refreshTimer()

					ui.oneSecondTimer:start()
				else
					l3:setVisible(true)
					l1:setVisible(true)
					buffs:setVisible(true)
				end

				UIHelper:setCascadeOpacityEnabled(ui)
				ui:setPositionY(57)
				return ui
			end,
			param = panel
		}
	end

end

function EndGamePropTipFactory:checkSpecACT1Data( panel )
	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)
	if not isSupportedLevelType then
		return
	end

	if not DragonBuffManager then
		return
	end

	if not DragonBuffManager.getInstance():isActivitySupport() then
		return
	end

	local triggeredDragonBuff = DragonBuffManager.getInstance():getCurBuffLevelInGame()

	if triggeredDragonBuff then
		return {
			creator = function ( panel )

				local gameLogic = GameBoardLogic:getCurrentLogic() or {}
				local targetCount = gameLogic.actCollectionNum or 0
				-- targetCount = 3

				-- ui会被加到 574x57的一个区域里
				local ui = UIHelper:createUI("ui/temp/dragon_buff_add_step.json", "dragon.buff.add.step.res/specACT1")
				ui = UIHelper:replaceLayer2LayerColor(ui)

				local label1 = BitmapText:create(tostring(targetCount * 10), "fnt/dragon2018_5steps.fnt", -1, kCCTextAlignmentLeft)
				local label2 = BitmapText:create(tostring(targetCount), "fnt/dragon2018_5steps.fnt", -1, kCCTextAlignmentLeft)

				local tip = ui:getChildByPath('tip')

				tip:addChild(label1)
				tip:addChild(label2)

				local numHolder1 = ui:getChildByPath('tip/numHolder1')
				local numHolder2 = ui:getChildByPath('tip/numHolder2')

				local dimension1 = numHolder1:getDimensions()
				local dimension2 = numHolder2:getDimensions()

				label1:setAnchorPoint(ccp(0.5, 0.5))
				label2:setAnchorPoint(ccp(0.5, 0.5))

				label1:setPositionX(numHolder1:getPositionX() + dimension1.width/2)
				label1:setPositionY(numHolder1:getPositionY() - dimension1.height/2)

				label2:setPositionX(numHolder2:getPositionX() + dimension2.width/2)
				label2:setPositionY(numHolder2:getPositionY() - dimension2.height/2)

				UIHelper:setCascadeOpacityEnabled(ui)
				ui:setPositionY(57)

				local icon1 = ui:getChildByPath('tip/icon1')
				local icon2 = ui:getChildByPath('tip/icon2')

				icon1:setAnchorPointCenterWhileStayOrigianlPosition()
				icon2:setAnchorPointCenterWhileStayOrigianlPosition()

				ui.icons = {icon1, icon2}

				return ui
			end,
			param = panel
		}
	end
end

function EndGamePropTipFactory:checkDropActData( panel )
	-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'

	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)

	if not isSupportedLevelType then
		return
	end

	local levelType = panel.levelType

	-- example

	-- if MyActManager:shouldShowTargetIcon() then
	if self.__debug_act then
		return {
			creator = function ( panel )
				-- ui会被加到 574x57的一个区域里
				local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_1')

				if not ui then
					UIHelper:loadJson('ui/panel_add_step.json')
					ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_1')
					UIHelper:unloadJson('ui/panel_add_step.json')
				end

				ui = UIHelper:replaceLayer2LayerColor(ui)
				local targetIcon = ResourceManager:sharedInstance():buildItemSprite(10004)
				targetIcon:setAnchorPoint(ccp(0.5, 0.5))
				UIUtils:positionNode(ui:getChildByName('holder'), targetIcon)
				targetIcon:setScale(1.1)
				ui.icons = {targetIcon}
				UIHelper:setCascadeOpacityEnabled(ui)
				ui:getChildByName("msgLabel"):setString('关卡活动专属tips')
				ui:setPositionY(57)
				return ui
			end,
			param = panel,
			bubbleRes = {[1] = 'bubble_a3'},
		}
	
	elseif CountdownPartyManager.getInstance():isActivitySupport() then
		local effLv = CountdownPartyManager.getInstance():getEffectLevelId()
		if effLv and panel.levelId and effLv == panel.levelId then 
			local mainLogic = GameBoardLogic:getCurrentLogic()
			if mainLogic then 
				local actCollectionNum = mainLogic.actCollectionNum 
				if actCollectionNum and actCollectionNum > 0 then
					return {
						creator = function (panel)
							local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_5')
							
							local collectIcon1 = ui:getChildByName("collect1")
							local iconSize = collectIcon1:getContentSize()
							local pos1 = collectIcon1:getPosition()
							local numToShow1 = actCollectionNum * 10
							local numLabel1 = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
							ui:addChild(numLabel1)
							numLabel1:setAnchorPoint(ccp(0, 0.5))
							numLabel1:setText(numToShow1)
							numLabel1:setScale(1.1)
							local labelSize1 = numLabel1:getGroupBounds().size
							numLabel1:setPosition(ccp(pos1.x, pos1.y - iconSize.height/2 - 3))
							collectIcon1:setPositionX(pos1.x + labelSize1.width)

							local collectIcon2 = ui:getChildByName("collect2")
							local pos2 = collectIcon2:getPosition()
							local numToShow2 = actCollectionNum 
							local numLabel2 = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
							ui:addChild(numLabel2)
							numLabel2:setAnchorPoint(ccp(0, 0.5))
							numLabel2:setText(numToShow2)
							numLabel2:setScale(1.1)
							local labelSize2 = numLabel2:getGroupBounds().size
							numLabel2:setPosition(ccp(pos2.x, pos2.y - iconSize.height/2 - 3))
							collectIcon2:setPositionX(pos2.x + labelSize2.width)

							ui = UIHelper:replaceLayer2LayerColor(ui)
							UIHelper:setCascadeOpacityEnabled(ui)
							ui:setPositionY(57)

							return ui
						end,
						param = panel,
					}
				end
			end
		end 
	-- elseif FTWLocalLogic:isFTWEnabled() 
	-- 	and ( 
	-- 			( FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kAddStarMode 
	-- 				and FTWLocalLogic:getDeltaPropNum() > 0)  
	-- 			or (FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kFullStarMode ) 
	-- 		) then

		
	-- 	return {
	-- 		creator = function ( panel )
	-- 			local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_8')

	-- 			if not ui then
	-- 				UIHelper:loadJson('ui/panel_add_step.json')
	-- 				ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_1')
	-- 				UIHelper:unloadJson('ui/panel_add_step.json')
	-- 			end
	-- 			local num = 0
	-- 			if FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kAddStarMode then
	-- 				num = FTWLocalLogic:getDeltaPropNum() or 0
	-- 			elseif FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kFullStarMode then
	-- 				num = FTWLocalLogic:getFunnyPropNum(panel.levelId) or 0
	-- 			end


	-- 			local text = ui:getChildByPath('text')
	-- 			text:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5))
	-- 			local numUI = BitmapText:create('x' .. num, 'fnt/18thxgiving_left.fnt')
	-- 			local icon = ui:getChildByPath('icon')
	-- 			ui:addChild(numUI)
	-- 			numUI:setAnchorPoint(ccp(0, 0.5))
	-- 			icon:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))
	-- 			numUI:setPositionX(text:getPositionX())
	-- 			numUI:setPositionY(text:getPositionY() - 3)
	-- 			icon:setPositionX(numUI:getPositionX() + numUI:getContentSize().width * numUI:getScaleX() - 4)
	-- 			local totalWidth = icon:getPositionX() + icon:getContentSize().width * icon:getScaleX() - text:getPositionX() + text:getContentSize().width * text:getScaleX()

	-- 			local offsetX = (580-totalWidth)/2
	-- 			text:setPositionX(offsetX + text:getContentSize().width * text:getScaleX())
	-- 			numUI:setPositionX(text:getPositionX())
	-- 			icon:setPositionX(numUI:getPositionX() + numUI:getContentSize().width * numUI:getScaleX() - 4)

	-- 			ui = UIHelper:replaceLayer2LayerColor(ui)
	-- 			UIHelper:setCascadeOpacityEnabled(ui)
	-- 			ui:setPositionY(57)
	-- 			return ui
	-- 		end,
	-- 		param = panel,
	-- 	}
    elseif Thanksgiving2018CollectManager.getInstance():isActivitySupport() then
    	local actMgr = Thanksgiving2018CollectManager.getInstance()
    	if actMgr:getCurLevelIsCanCollect(panel.levelId) then
			local ret = {
				creator = function (panel)

					local num1 = actMgr:getNum1() or 4
					local num2 = actMgr:getNum2(panel.levelId) or 999


					local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_7')

					-- local label1 = ui:getChildByPath('detail/label1')
					-- local label2 = ui:getChildByPath('detail/label2')

					local icon1 = ui:getChildByPath('detail/icon1')
					local icon2 = ui:getChildByPath('detail/icon2')

					local label1 = BitmapText:create('如果现在退出,将只得', 'fnt/tutorial_white.fnt')
					local label2 = BitmapText:create(',失去', 'fnt/tutorial_white.fnt')
					ui:getChildByPath('detail'):addChild(label1)
					ui:getChildByPath('detail'):addChild(label2)
					label1:setAnchorPoint(ccp(0, 1))
					label2:setAnchorPoint(ccp(0, 1))
					label1:setPositionY(-5)
					label2:setPositionY(-5)

					-- label1:setDimensions(CCSizeMake(0, 0))
					-- label2:setDimensions(CCSizeMake(0, 0))
					
					local numText1 = BitmapText:create(tostring(num1), "fnt/18thxgiving_left.fnt")
					local numText2 = BitmapText:create(tostring(num2), "fnt/18thxgiving_left.fnt")

					-- label1:setAnchorPoint(ccp(0, 0.5))
					-- label2:setAnchorPoint(ccp(0, 0.5))
					numText1:setAnchorPoint(ccp(0, 0.5))
					numText2:setAnchorPoint(ccp(0, 0.5))
					-- icon1:setAnchorPoint(ccp(0, 0.5))
					-- icon2:setAnchorPoint(ccp(0, 0.5))

					numText1:setPositionY(-25)
					numText2:setPositionY(-25)

					UIHelper:move(label1, 0, -5)
					UIHelper:move(label2, 0, -5)
					UIHelper:move(numText1, 0, -10)
					UIHelper:move(numText2, 0, -10)

					ui:getChildByPath('detail'):addChild(numText1)
					ui:getChildByPath('detail'):addChild(numText2)

					-- label1:setString('如果现在退出,将只得')
					-- label2:setString(',失去')



					local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

					layoutUtils.horizontalLayoutItems({
						{node = label1,},
						{node = numText1, padding = {left = 0,},},
						{node = icon1, padding = {left = -6, right = -15,}, },
						{node = label2,},
						{node = numText2, padding = {left = 0,},},
						{node = icon2, padding = {left = -6,}, },
					})

					local width = ui:getChildByPath('detail'):getGroupBounds(ui).size.width
					ui:getChildByPath('detail'):setPositionX( (574 - width)/2 )

					ui = UIHelper:replaceLayer2LayerColor(ui)
					UIHelper:setCascadeOpacityEnabled(ui)
					ui:setPositionY(57)
					ui.numText2 = numText2


					function ui:setNum( n )
						if self.isDisposed then return end
						self.numText2:setText(tostring(n))
					end

					function ui:getNum( ... )
						if self.isDisposed then return end
						return self.numText2:getString()
					end

					function ui:getNumPos( ... )
						if self.isDisposed then return end
						local bounds = self.numText2:getGroupBounds()
						return ccp(bounds:getMidX(), bounds:getMidY())
					end

					function ui:setNumWithAnim( n )
						if self.isDisposed then return end
						self.numText2:setNumWithAnim(tostring(n), 0.6)
					end

			

					return ui
				end,
				param = panel,
			}

			if actMgr:isFirstTime(panel.levelId) then
				ret.bubbleRes = {[1] = 'bubble_a3'}
			end
			return ret
		end
    elseif SpringFestival2019Manager.getInstance():getCurIsAct() and (panel.propId == ItemType.ADD_FIVE_STEP or panel.propId == ItemType.RABBIT_MISSILE ) then
        local ret = {
			creator = function (panel)
				local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_9')

                local canGetCaiPiaoNum = SpringFestival2019Manager.getInstance():getBuyAddFiveAddNum()
                local numText = BitmapText:create("x"..canGetCaiPiaoNum, "fnt/profile2018.fnt")
                numText:setAnchorPoint(ccp(0, 0.5))
                numText:setScale(2)
                UIHelper:move(numText, 10+36/0.7, 10+10/0.7)
				ui:getChildByPath('icon'):addChild(numText)

                ui = UIHelper:replaceLayer2LayerColor(ui)
				UIHelper:setCascadeOpacityEnabled(ui)
				ui:setPositionY(54)

				return ui
			end,
			param = panel,
		}

		ret.bubbleRes = {[1] = 'bubble_a'}
		return ret

     elseif TurnTable2019Manager.getInstance():isActivitySupport(panel.levelId) and (panel.propId == ItemType.ADD_FIVE_STEP or panel.propId == ItemType.RABBIT_MISSILE ) then
        local ret = {
			creator = function (panel)
				local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_12')

                local levelPlayedCount = TurnTable2019Manager.getInstance().levelPlayedCount
                local canGetInfo = TurnTable2019Manager.getInstance():curLevelCanGet( panel.levelId, levelPlayedCount )

                local ticketNum = canGetInfo.ticketNum

                local icon1 = ui:getChildByPath('icon1')
                local icon2 = ui:getChildByPath('icon2')

                icon1:setVisible(false)
                icon2:setVisible(false)

                if canGetInfo.TicketType == 1 then
                    --银
                    icon2:setVisible(true)

                    local numText = BitmapText:create("x"..ticketNum, "fnt/profile2018.fnt")
                    numText:setAnchorPoint(ccp(0, 0.5))
                    numText:setScale(2)
                    UIHelper:move(numText, 10+36/0.7, 10+10/0.7)
				    icon2:addChild(numText)
                else
                    --金
                    icon1:setVisible(true)

                    local numText = BitmapText:create("x"..ticketNum, "fnt/profile2018.fnt")
                    numText:setAnchorPoint(ccp(0, 0.5))
                    numText:setScale(2)
                    UIHelper:move(numText, 10+36/0.7, 10+10/0.7)
				    icon1:addChild(numText)
                end

                ui = UIHelper:replaceLayer2LayerColor(ui)
				UIHelper:setCascadeOpacityEnabled(ui)
				ui:setPositionY(54)

				return ui
			end,
			param = panel,
		}

		ret.bubbleRes = {[1] = 'bubble_a'}
		return ret

	end
end

function EndGamePropTipFactory:checkDropActData2( panel )
    local isSupportedLevelType = table.exist(validLevelType, panel.levelType)

	if not isSupportedLevelType then
		return
	end

	local levelType = panel.levelType

    if SpringFestival2019Manager.getInstance():getCurIsAct() and (panel.propId == ItemType.ADD_FIVE_STEP or panel.propId == ItemType.RABBIT_MISSILE ) then

        local star = 0
        if SpringFestival2019Manager.getInstance().LevelPlayType == 2 then
            local mainLogic = GameBoardLogic:getCurrentLogic()
            local oldStar =  SpringFestival2019Manager.getInstance().levelStar
            if mainLogic then
                star = mainLogic.gameMode:getScoreStarLevel()
            end

            if oldStar >= star then return end
        end

        local ret = {
			creator = function (panel)

                local tipStr = ""
                if SpringFestival2019Manager.getInstance().LevelPlayType ~= 2 then
                    tipStr = 'newAddStepPanel_tip_10'
                else
                    tipStr = 'newAddStepPanel_tip_11'
                end
				local ui = panel:buildInterfaceGroup(tipStr)
                local msgLabel = ui:getChildByName('text')
--	            local dimensions = msgLabel:getDimensions()
--	            msgLabel:setDimensions(CCSizeMake(dimensions.width, 0))

                local CanGetInfo = SpringFestival2019Manager.getInstance():getPassLevelCanGetInfo( true, star )
                local doubleNum = CanGetInfo.luckyBagDoubleNum or 1
                local bagLevel = CanGetInfo.luckyBagLevel

                local function GetBagSprite( bagLevel, doubleNum )
                    local bag_sprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/bag"..bagLevel.."0000")

                    local DoubleLabel = BitmapText:create( doubleNum.."倍" ,"fnt/peg_year_chunjiejineng.fnt")
                    DoubleLabel:setAnchorPoint(ccp(0.5, 0.5))
                    DoubleLabel:setPosition(ccp(27-2/0.7,32-12/0.7))
                    DoubleLabel:setScale(0.5)
                    bag_sprite:addChild(DoubleLabel)

                    if doubleNum == 1 then
                        DoubleLabel:setVisible(false)
                    end

                    return bag_sprite
                end

                local icon1 = ui:getChildByName('icon1')
                local icon2 = ui:getChildByName('icon2')

                local PassSprite = GetBagSprite( bagLevel,doubleNum )
                local FailSprite = GetBagSprite( bagLevel,1 )

                PassSprite:setPosition(ccp(15-18/0.7,-15+25/0.7))
                icon1:addChild( PassSprite )
                
                FailSprite:setPosition(ccp(15-18/0.7,-15+25/0.7))
                icon2:addChild( FailSprite )

                ui = UIHelper:replaceLayer2LayerColor(ui)
				UIHelper:setCascadeOpacityEnabled(ui)
                ui:setPositionX(23/0.7)
				ui:setPositionY(54)
                ui.msgLabel = msgLabel

                function ui:setTextColor( color )
		            if self.isDisposed then return end
		            self.msgLabel:setColor(color)
	            end

				return ui
			end,
			param = panel,
		}

		ret.bubbleRes = {[1] = 'bubble_a'}
		return ret
	end
end

function EndGamePropTipFactory:checkPreBuffData( panel )

	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)

	if not isSupportedLevelType then
		return
	end

	if (panel.hasPreBuff and PreBuffLogic:isActOn()) or (self.__debug_prebuff) then
	-- if PreBuffLogic:isActOn() then
		return {creator = self.createPreBuff, param = panel}
	end
end

function EndGamePropTipFactory.createPreBuff( panel )
	local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_2')

	if not ui then
		UIHelper:loadJson('ui/panel_add_step.json')
		ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_2')
		UIHelper:unloadJson('ui/panel_add_step.json')
	end

	ui = UIHelper:replaceLayer2LayerColor(ui)
	UIHelper:setCascadeOpacityEnabled(ui)
	local grade, _, description = PreBuffLogic:getBuffInfos()

	if EndGamePropTipFactory.__debug_prebuff then
		grade = 1
	end


	local style = PreBuffLogic:getStyle() or 1

	local targetIconGroup = 'icon00' .. style
		
	for k = 1, 2 do
		local otherIconGroup = 'icon00' .. k
		if otherIconGroup == targetIconGroup then
			local iconLayer = ui:getChildByName('prebuff'):getChildByName(otherIconGroup)
			for i=1, 5 do
				local icon = iconLayer:getChildByName(tostring(i))
				icon:setAnchorPointCenterWhileStayOrigianlPosition()
				icon:removeFromParentAndCleanup(true)
			end
			local iconSpriteFrame = 'prebuff_icon_res/sp/' .. description .. '0000'
			local icon = UIHelper:createSpriteFrame('ui/prebuff_icons.json', iconSpriteFrame)
			if icon then
				iconLayer:addChild(icon)
				icon:setScale(0.7)
				icon:setPositionX(20)
				icon:setPositionY(5)
			end
		else
			ui:getChildByName('prebuff'):getChildByName(otherIconGroup):removeFromParentAndCleanup(true)
		end
	end
	ui:setPositionY(57)

	function ui:setTextColor( color )
		if self.isDisposed then return end
		self:getChildByPath('prebuff/bg'):setColor(color)
	end

	return ui
end

function EndGamePropTipFactory:checkScoreBuffData( panel )
	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)
	if not isSupportedLevelType then
		return
	end

	-- if panel.hasScoreBuff then
	-- 	return {creator = self.createScoreBuff, param = panel}
	-- end
end

function EndGamePropTipFactory.createScoreBuff( panel )
	local ui = panel:buildInterfaceGroup("newAddStepPanel_tip_6")
	if not ui then
		UIHelper:loadJson("ui/panel_add_step.json")
		ui = UIHelper:getBuilder("ui/panel_add_step.json"):buildGroup("newAddStepPanel_tip_6")
		UIHelper:unloadJson("ui/panel_add_step.json")
	end
	ui = UIHelper:replaceLayer2LayerColor(ui)
	UIHelper:setCascadeOpacityEnabled(ui)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local nowstar = 0 
	if mainLogic then
		nowstar = mainLogic.gameMode:getScoreStarLevel()
	end
	local oldStar = CollectStarsManager.getInstance():getOldStarForStageEnd(levelId  )
	local bottleNum = nowstar - oldStar
	ui.icons = {}
	for i = 1, 5 do
		local icon = ui:getChildByName("scoreBuffTextSet"):getChildByName("num"):getChildByName(tostring(i))
		icon:setAnchorPointCenterWhileStayOrigianlPosition()
		if i ~= bottleNum then
			icon:removeFromParentAndCleanup(true)
		else
			table.insert(ui.icons, icon)
		end
	end
	ui:setPositionY(57)

	function ui:setTextColor( color )
		if self.isDisposed then return end
		self:getChildByPath("scoreBuffTextSet/bg"):setColor(color)
	end

	return ui
end

function EndGamePropTipFactory:checkFUUUData( panel )

	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)

	if not isSupportedLevelType then
		return
	end

	if panel.propId == ItemType.ADD_FIVE_STEP  or self.__debug_fuuu   then
		local uid = UserManager:getInstance().uid
		if panel.lastGameIsFUUU or self.__debug_fuuu then
			if panel.fuuuData or self.__debug_fuuu  then

				local function creator( ... )
					-- body
					local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_3')

					if not ui then
						UIHelper:loadJson('ui/panel_add_step.json')
						ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_3')
						UIHelper:unloadJson('ui/panel_add_step.json')
					end


					ui = UIHelper:replaceLayer2LayerColor(ui)
					UIHelper:setCascadeOpacityEnabled(ui)

					ui.icons = {}

					local msgIcon_label1 = ui:getChildByName('msgIcon_1'):getChildByName('numLabel')
					local msgIcon_label2 = ui:getChildByName('msgIcon_2'):getChildByName('numLabel')
					local msgIcon_1 = ui:getChildByName('msgIcon_1')
					local msgIcon_2 = ui:getChildByName('msgIcon_2')
					local msgLabel_new1 = ui:getChildByName('msgLabel_new1')
					local msgLabel_new2 = ui:getChildByName('msgLabel_new2')

					msgIcon_1:getChildByName("icon"):removeFromParentAndCleanup(true)
					msgIcon_2:getChildByName("icon"):removeFromParentAndCleanup(true)

					msgLabel_new1:setString( Localization:getInstance():getText("add.step.panel.msg.txt.fuuu1") )
					msgLabel_new2:setString( Localization:getInstance():getText("add.step.panel.msg.txt.fuuu2") )

					local uis = {}

					uis.msgIcon_1 = msgIcon_1
					uis.msgIcon_2 = msgIcon_2
					uis.msgIcon_label1 = msgIcon_label1
					uis.msgIcon_label2 = msgIcon_label2
					uis.msgLabel_new1 = msgLabel_new1
					uis.msgLabel_new2 = msgLabel_new2

					ui.msgIcon_label1 = msgIcon_label1
					ui.msgIcon_label2 = msgIcon_label2
					ui.msgLabel_new1 = msgLabel_new1
					ui.msgLabel_new2 = msgLabel_new2

					local iconIndex = 1
					local targetTooMuch = false

					local function buildTargetIcon(k1,k2,k3,diff)

						if iconIndex > 2 then 
							targetTooMuch = true
							return 
						end
						iconIndex = iconIndex + 1



						if not (k1 and k2 and k3) then 
							targetTooMuch = true
							return 
						end

						local targetIcon = FUUUManager:getTargetIconByFuuuType( k2 , k3 )
						if not targetIcon then

							targetTooMuch = true
							return 
						end

						local _baseScale = 1.2
						targetIcon:setScale(_baseScale)

						table.insert(ui.icons, targetIcon)

						uis["msgIcon_" .. tostring(iconIndex - 1)]:addChildAt(targetIcon, 0)
						uis["msgIcon_label" .. tostring(iconIndex - 1)]:setText(tostring(diff))
					end

					if self.__debug_fuuu  then
						buildTargetIcon(1, 'ice' ,1, 1)
						buildTargetIcon(1, 'ice' ,1, 1)
					else
						for ka,va in ipairs(panel.fuuuData) do
							if va.isFuuuDone then
								local _k1 = va.ty
								local _k2 = nil
								local _k3 = nil
								local _diff = nil

								if va.okey1 then _k2 = va.okey1 end
								if va.okey2 then 
									_k3 = va.okey2 
									_diff = va.tv - va.cv
									if _diff > 0 then
										buildTargetIcon(_k1 , _k2 , _k3 , _diff)
									end
								elseif va.cld then
									for kb,vb in ipairs(va.cld) do
										_k3 = vb.k2
										_diff = vb.tv - vb.cv
										if _diff > 0 then
											buildTargetIcon(_k1 , _k2 , _k3 , _diff)
										end
									end
								else
									--printx( 1 , "  !!!!!!!!!!!!!!!!!!!   333.2 " , table.tostring(va)  )
									_k3 = 0
									if va.tv > 0 then
										_diff = va.tv - va.cv
									else
										_diff = va.cv
									end
									
									if _diff > 0 then
										buildTargetIcon(_k1 , _k2 , _k3 , _diff)
									else
										targetTooMuch = true
									end
								end
							end	
						end
					end

					if iconIndex == 2 then
						msgIcon_1:setPositionX( msgIcon_1:getPositionX() + 40 )
						msgLabel_new1:setPositionX( msgLabel_new1:getPositionX() + 40 )
						msgLabel_new2:setPositionX( msgLabel_new2:getPositionX() - 40 )
					end

					ui:setPositionY(57)
					ui:setPositionX(-60)

					function ui:setTextColor( color )
						if self.isDisposed then return end
						if self.msgLabel_new2 then
							self.msgLabel_new2:setColor(color)
						end
						if self.msgLabel_new1 then
							self.msgLabel_new1:setColor(color)
						end
						if self.msgIcon_label1 then
							self.msgIcon_label1:setColor(color)
						end
						if self.msgIcon_label2 then
							self.msgIcon_label2:setColor(color)
						end
					end

					return ui, targetTooMuch
				end

				local ui, targetTooMuch = creator()
				ui:dispose()

				if targetTooMuch then
				else
					return {creator = creator, param = {}}
				end
			end
		end
	end
end


function EndGamePropTipFactory.createFUUU( panel )

	

end

function EndGamePropTipFactory.createNormal( panel )

	-- if _G.isLocalDevelopMode then printx(101, "  " , debug.traceback() ) end
	
	local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_4')
	
	if not ui then
		UIHelper:loadJson('ui/panel_add_step.json')
		ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_4')
		UIHelper:unloadJson('ui/panel_add_step.json')
	end


	ui = UIHelper:replaceLayer2LayerColor(ui)
	UIHelper:setCascadeOpacityEnabled(ui)

	local msgLabel = ui:getChildByName('msgLabel')
	local dimensions = msgLabel:getDimensions()
	msgLabel:setDimensions(CCSizeMake(dimensions.width, 0))
	if panel.levelType == GameLevelType.kDigWeekly then
		msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.weekly.race'))
	elseif panel.levelType == GameLevelType.kMayDay then
		msgLabel:setString(Localization:getInstance():getText('activity.dragonboat.fail.add.five'))
	elseif panel.levelType == GameLevelType.kRabbitWeekly then
		msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.10040.rabbit'))
	else
		if panel.propId == ItemType.ADD_FIVE_STEP then
			msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt.new"))
		else
			msgLabel:setString(Localization:getInstance():getText("add.step.panel.msg.txt."..panel.propId))
		end
	end
	ui.msgLabel = msgLabel
	ui:setPositionY(57)
	ui:setPositionX(-50)

	function ui:setTextColor( color )
		if self.isDisposed then return end
		self.msgLabel:setColor(color)
	end

	return ui
end


function EndGamePropTipFactory.createQuestNormal( panel, sz )

	local ui = panel:buildInterfaceGroup('newAddStepPanel_tip_4')
	if not ui then
		UIHelper:loadJson('ui/panel_add_step.json')
		ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup('newAddStepPanel_tip_4')
		UIHelper:unloadJson('ui/panel_add_step.json')
	end

	ui = UIHelper:replaceLayer2LayerColor(ui)
	UIHelper:setCascadeOpacityEnabled(ui)

	local msgLabel = ui:getChildByName('msgLabel')
	local dimensions = msgLabel:getDimensions()
	msgLabel:setDimensions(CCSizeMake(dimensions.width, 0))

	UIHelper:move(msgLabel, 9, 0)

	ui.msgLabel = msgLabel
	ui:setPositionY(57)
	ui:setPositionX(-50)

	function ui:setTextColor( color )
		if self.isDisposed then return end
		self.msgLabel:setColor(color)
	end

	function ui:setString( ... )
		if self.isDisposed then return end
		self.msgLabel:setString(...)
	end

	ui:setString(sz)

	return ui
end

function EndGamePropTipFactory:checkNormalData( panel )

	local isSupportedLevelType = table.exist(validLevelType, panel.levelType)

	if not isSupportedLevelType then
		return
	end
	return {creator = self.createNormal, param = panel}
end

function EndGamePropTipFactory:createTip( data )

	if data.creator then
		return data.creator(data.param)
	end

	return self:getDefaultTip()
end

function EndGamePropTipFactory:getDefaultTip( ... )
	local label = TextField:create("12345678", nil, 34)
	label:setColor(ccc3(255, 255, 255))
	label:setAnchorPoint(ccp(0, 0))
	local layer = LayerColor:create()
	layer:setCascadeOpacityEnabled(true)
	layer:addChild(label)

	local icon = ResourceManager:sharedInstance():buildItemSprite(14)
	layer:addChild(icon)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setPositionX(180)
	icon:setPositionY(20)
	-- layer:changeWidthAndHeight(574, 54)
	layer:ignoreAnchorPointForPosition(false)
	label:setCascadeOpacityEnabled(true)
	icon:setCascadeOpacityEnabled(true)

	layer.icons = {} 

	return layer
end

return EndGamePropTipFactory