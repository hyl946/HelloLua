DiffAdjustQAToolPanel = class(BasePanel)

local maxUnit = 10

function DiffAdjustQAToolPanel:create(closeCallback)
	local panel = DiffAdjustQAToolPanel.new()
	panel:loadRequiredResource("ui/QATools.json")
	panel.closeCallback = closeCallback
	panel:init()
	return panel
end

function DiffAdjustQAToolPanel:init()

	self.ui = self:buildInterfaceGroup("QATools/DiffAdjustTestTool")
	BasePanel.init(self, self.ui)

	local function onBtnTapped(evnet)
		self:onBaseButtonTapped( evnet.target )
	end

	self.parameterMap = {}
	self.tabViews = {}

	self.bg = self.ui:getChildByName("bg")
	-- self.bg:setTouchEnabled(true)
	self.bg:setTouchEnabled(true, 0, true)
	self.bg:addEventListener(DisplayEvents.kTouchTap, function () 
			-- printx( 1 , "RRRRRRRRRRRRRRRRRRRRRRRRRRR!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		end )

	self.btn_close_res = self.ui:getChildByName("btn_close")
	self.btn_close	= GroupButtonBase:create( self.btn_close_res )
	self.btn_close:useStaticLabel( 20 , "微软雅黑" , ccc3(0,0,0) )
	self.btn_close:setString( "X" )
	self.btn_close:addEventListener(DisplayEvents.kTouchTap, function () self:onCloseButtonTapped() end )

	self.btn_replay_res = self.ui:getChildByName("btn_replay")
	self.btn_replay	= GroupButtonBase:create( self.btn_replay_res )
	self.btn_replay:useStaticLabel( 20 , "微软雅黑" , ccc3(0,0,0) )
	self.btn_replay:setString( "CODE" )
	self.btn_replay:addEventListener(DisplayEvents.kTouchTap, function () self:onCode() end )


	self.txt_tip1 = self.ui:getChildByName("txt_tip1")
	self.txt_tip1:setString("【UserExtend】 'testInfo':'dummyUid_2300;DiffAdjustQATool'  或者  'testInfo':'DiffAdjustQATool'   Maintenance开关：QAInLevelTools id 225")


	local function initBtn( btnIndex , uiname , btnname)
		self["btn_" .. uiname .. "_res"] = self.ui:getChildByName("btn_" .. uiname)
		self["btn_" .. uiname ]	= GroupButtonBase:create( self["btn_" .. uiname .. "_res"] )
		self["btn_" .. uiname ]:useStaticLabel( 14 , "微软雅黑" , ccc3(0,0,0) )
		self["btn_" .. uiname ]:setString( btnname )
		self["btn_" .. uiname ].uiName = uiname
		self["btn_" .. uiname ].btnName = btnname
		self["btn_" .. uiname ].btnIndex = btnIndex

		self["btn_" .. uiname ]:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
	end

	initBtn( 1 , "log" , "输出" )
	initBtn( 2 , "groupInfo" , "分组" )
	initBtn( 3 , "diffadjust_plan" , "策略决策" )
	initBtn( 4 , "diffadjust_do" , "策略执行" )
	initBtn( 5 , "userTag" , "用户标签" )
	initBtn( 6 , "others" , "其它" )
	initBtn( 7 , "test" , "TEST" )

	self:changeTab( 1 )
	--[[
	
	for i = 1 , 3 do

		self["label_tile_" .. tostring(i)] = self.ui:getChildByName("label_tile_" .. tostring(i))
		
		self["baseColorRect_" .. tostring(i)]	= self:buildEditBox("baseColorRect_" .. tostring(i))
		self["baseColorRect_" .. tostring(i)]:setInputMode(kEditBoxInputModePhoneNumber)
	end
	]]
	
	-- self.label_tile_1:setString("起始关卡")
	-- self.label_tile_2:setString("结束关卡")
	-- self.label_tile_3:setString("随机次数")

	-- self.baseColorRect_1:setText("1")
	-- self.baseColorRect_2:setText("1200")
	-- self.baseColorRect_3:setText("200")

	-- self.base_button_1:setString("前置道具")
	-- self.base_button_2:setString("Buff")
	-- self.base_button_3:setString("掉落颜色")
	-- self.base_button_4:setString("使用道具")
	-- self.base_button_5:setString("检测Replay")
	-- self.base_button_6:setString("随机触发")
	-- self.base_button_7:setString("是否加速")
	-- self.base_button_8:setString("囧TL")


	--GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSectionResume, function (evt) self:onSectionResumeEvent(evt.data) end )
end

function DiffAdjustQAToolPanel:changeTab( tabIndex )

	printx( 1 , "DiffAdjustQAToolPanel:changeTab ~~~~~~~~~~~~~~~~  " , tabIndex)
	for i = 1 , 7 do
		if i == tabIndex then
			printx( 1 , "kGroupButtonColorMode.blue " , i) 
			self:getTabBtnByIndex(i):setColorMode( kGroupButtonColorMode.blue , true )
			self:showTabView( i )
		else
			printx( 1 , "kGroupButtonColorMode.grey " , i) 
			self:getTabBtnByIndex(i):setColorMode( kGroupButtonColorMode.grey , true )
			self:hideTabView( i )
		end
	end
end

function DiffAdjustQAToolPanel:showTabView( tabIndex )

	if self.tabViews[tabIndex] then
		local view = self.tabViews[tabIndex]
		self.ui:addChild( view )
	else

		if tabIndex == 1 then
			local scroll = VerticalScrollable:create( 600, 350, false, false)
			local layout = VerticalTileLayout:create( 600 )
			-- layout:setItemHorizontalMargin(1)

			self.logDatas = DiffAdjustQAToolManager:getLogs()

			if self.logDatas and self.logDatas.logs then
				for k,v in ipairs(self.logDatas.logs) do
					local item= ItemInLayout:create()

					local str = tostring(v.txt)

					--DiffAdjustTestTool_LogUnit
					local txtView = self.builder:buildGroup( "QATools/DiffAdjustTestTool_LogUnit" )
					txtView:setAnchorPoint( ccp(0,1) )

					local idText = txtView:getChildByName("text_1")
					idText:setString( tostring(v.id) )

					local txt = txtView:getChildByName("text_2")
					txt:setDimensions( CCSizeMake( 610 , 0 ) )
					txt:setString( str )

					local bg = txtView:getChildByName("bg")
					bg:setAnchorPoint( ccp(0,1) )

					local bgSize = bg:getGroupBounds().size
					local bgSizeHeight = bgSize.height

					local txtSize = txt:getContentSize()

					local newHeight = txtSize.height + 22

					bg:setScaleY( newHeight / bgSizeHeight )

					-- txtView:getChildByName("bg"):setVisible(false)

					-- local txt = TextField:create(str , "Helvetica" , 18)
					-- txt:setAnchorPoint( ccp(0,0) )
					-- txt:setPreferredSize( 150 , 150 )

					item:setContent( txtView )

					layout:addItem(item)
				end
			end

			scroll:setContent(layout)
			scroll:setIgnoreHorizontalMove( true )
			scroll:setPositionXY( 30 ,  -80 )
			self.ui:addChild(scroll)

			self.tabViews[tabIndex] = scroll

		elseif tabIndex == 2 then
			
			local groupInfo = DiffAdjustQAToolManager:getUserGroup()

			local tabView_2 = self.builder:buildGroup( "QATools/DiffAdjustTestTool_Tab2" )
			tabView_2:getChildByName("title_1"):setString( "LevelDifficultyAdjust MainSwitch（主开关）:" )
			tabView_2:getChildByName("txt_1"):setString( tostring( groupInfo.mainSwitch ) )

			tabView_2:getChildByName("title_2"):setString( "LevelDifficultyAdjustV2（难度调整八期）:" )
			tabView_2:getChildByName("txt_2"):setString( tostring( groupInfo.diffV2 ) )

			tabView_2:getChildByName("title_3"):setString( "ReturnUsersRetentionTest（回流用户测试）:" )
			tabView_2:getChildByName("txt_3"):setString( tostring( groupInfo.retention ) )

			tabView_2:getChildByName("title_4"):setString( "forbidByAI（AI测试）:" )
			tabView_2:getChildByName("txt_4"):setString( tostring( groupInfo.forbidByAI ) )

			tabView_2:setPositionXY( 25 ,  -80 )

			self.ui:addChild(tabView_2)

			self.tabViews[tabIndex] = tabView_2

		elseif tabIndex == 3 then

			local strategyDataList = LevelDifficultyAdjustManager:getStrategyDataList()

			local strategyData = strategyDataList[ #strategyDataList ]

			local tabView_3 = self.builder:buildGroup( "QATools/DiffAdjustTestTool_Tab3" )
			
			tabView_3:getChildByName("title_1"):setString( "FUUU策略调整 :" )
			tabView_3:getChildByName("title_2"):setString( "回流用户策略调整:" )
			tabView_3:getChildByName("title_3"):setString( "关卡内实时策略调整 :" )
			tabView_3:getChildByName("title_4"):setString( "用户标签策略调整:" )

			if strategyData then

				

				if strategyData.reason == "NewFuuuV2" or strategyData.reason == "FarmFuuu" then
					tabView_3:getChildByName("txt_1"):setString( "激活" )
				else
					tabView_3:getChildByName("txt_1"):setString( "不满足激活条件" )
				end
				

				
				
				if strategyData.reason == "ReturnBack1" then
					tabView_3:getChildByName("txt_2"):setString( "激活默认回流逻辑，且不超过5关" )
				elseif strategyData.reason == "ReturnBack2" then
					tabView_3:getChildByName("txt_2"):setString( "激活默认回流逻辑，且超过5关但不超过12关" )
				elseif strategyData.reason == "ReturnBack601" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 1-5" )
				elseif strategyData.reason == "ReturnBack602" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 6-10" )
				elseif strategyData.reason == "ReturnBack603" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 11-15" )
				elseif strategyData.reason == "ReturnBack604" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 16-20" )
				elseif strategyData.reason == "ReturnBack605" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 21-25" )
				elseif strategyData.reason == "ReturnBack501" then
					tabView_3:getChildByName("txt_2"):setString( "激活第6分组回流逻辑，topLevel 21-25" )
				else
					tabView_3:getChildByName("txt_2"):setString( "不满足激活条件" )
				end

				if true then
					tabView_3:getChildByName("txt_3"):setString( "已废弃" )
				else
					tabView_3:getChildByName("txt_3"):setString( "不满足激活条件" )
				end

				if strategyData.reason == "NewFuuuV2" or strategyData.reason == "FarmFuuu" then
					tabView_3:getChildByName("txt_4"):setString( "激活" )
				else
					tabView_3:getChildByName("txt_4"):setString( "不满足激活条件" )
				end
				
			else

				tabView_3:getChildByName("txt_1"):setString( "不满足激活条件" )
				tabView_3:getChildByName("txt_2"):setString( "不满足激活条件" )
				tabView_3:getChildByName("txt_3"):setString( "不满足激活条件" )
				tabView_3:getChildByName("txt_4"):setString( "不满足激活条件" )

			end

			tabView_3:setPositionXY( 25 ,  -80 )
			self.ui:addChild(tabView_3)
			self.tabViews[tabIndex] = tabView_3

		elseif tabIndex == 5 then

			local fixedActivationTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kActivation )
			local activationTag , activationTagTopLevelId , activationTagTopLevelIdLength , activationTagEndTime , activationTagUpdateTime = 
					UserTagManager:getUserTagBySeries( UserTagNameKeyFullMap.kActivation )

			local tabView_5 = self.builder:buildGroup( "QATools/DiffAdjustTestTool_Tab5" )

			tabView_5:getChildByName("title_1"):setString( "activationTag（前端值/后端值） :" )
			tabView_5:getChildByName("txt_1"):setString( tostring( fixedActivationTag ) .. " / " .. tostring(activationTag) )

			tabView_5:getChildByName("title_2"):setString( "activationTagTopLevelId：" )
			tabView_5:getChildByName("txt_2"):setString( tostring( activationTagTopLevelId ) )

			tabView_5:getChildByName("title_3"):setString( "activationTagEndTime：" )
			tabView_5:getChildByName("txt_3"):setString( tostring( os.date("%c", activationTagEndTime) ) )

			tabView_5:getChildByName("title_4"):setString( "activationTagTopLevelLength：" )
			tabView_5:getChildByName("txt_4"):setString( tostring( activationTagTopLevelIdLength ) )

			local fixedTopLevelDiffTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kTopLevelDiff )
			local topLevelDiffTag , topLevelDiffTagTopLevelId , topLevelDiffTagTopLevelIdLength , topLevelDiffTagEndTime , topLevelDiffTagUpdateTime = 
					UserTagManager:getUserTagBySeries( UserTagNameKeyFullMap.kTopLevelDiff )

			tabView_5:getChildByName("title_5"):setString( "topLevelDiffTag（前端值/后端值） :" )
			tabView_5:getChildByName("txt_5"):setString( tostring( fixedTopLevelDiffTag ) .. " / " .. tostring(topLevelDiffTag) )

			tabView_5:getChildByName("title_6"):setString( "topLevelDiffTagTopLevelId：" )
			tabView_5:getChildByName("txt_6"):setString( tostring( topLevelDiffTagTopLevelId ) )

			tabView_5:getChildByName("title_7"):setString( "topLevelDiffTagEndTime：" )
			tabView_5:getChildByName("txt_7"):setString( tostring( os.date("%c", topLevelDiffTagEndTime) ) )

			tabView_5:getChildByName("title_8"):setString( "topLevelDiffTagTopLevelIdLength：" )
			tabView_5:getChildByName("txt_8"):setString( tostring( topLevelDiffTagTopLevelIdLength ) )

			tabView_5:getChildByName("title_9"):setString( "topLevelFailCount：" )
			tabView_5:getChildByName("txt_9"):setString( tostring( UserTagManager:getTopLevelLogicalFailCounts() ) )

			tabView_5:getChildByName("title_10"):setString( "topLevelPropUsedCount：" )
			tabView_5:getChildByName("txt_10"):setString( tostring( UserTagManager:getTopLevelPropUsedCount() ) )


			tabView_5:setPositionXY( 25 ,  -80 )

			self.ui:addChild(tabView_5)

			self.tabViews[tabIndex] = tabView_5

		end
	end
end

function DiffAdjustQAToolPanel:onCode()
	local panel = QAToolTestCodePanel:create()
	panel:popout()
end

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


function DiffAdjustQAToolPanel:hideTabView( tabIndex )
	if self.tabViews[tabIndex] then
		local view = self.tabViews[tabIndex]
		self.ui:removeChild( view , false )
	end
end

function DiffAdjustQAToolPanel:getTabBtnByIndex( tabIndex )

	local maplist = {
		[1] = self.btn_log ,
		[2] = self.btn_groupInfo ,
		[3] = self.btn_diffadjust_plan ,
		[4] = self.btn_diffadjust_do ,
		[5] = self.btn_userTag ,
		[6] = self.btn_others ,
		[7] = self.btn_test ,
	}

	return maplist[tabIndex]
end

function DiffAdjustQAToolPanel:onCloseButtonTapped()
	PopoutManager:sharedInstance():remove(self, true)
	if self.closeCallback then self.closeCallback() end
end

function DiffAdjustQAToolPanel:popout()

	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end


	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	-- local selfHeight	= self:getGroupBounds().size.height
	local selfHeight	= 612
	-- printx( 1 , "selfHeight ===================" , selfHeight)

	local deltaHeight	= visibleSize.height - selfHeight

	-- self:setPosition(ccp(self:getHCenterInScreenX() + 0 , deltaHeight / -2 ))
	self:setPosition(ccp(self:getHCenterInScreenX() + 0 , deltaHeight * -1 ))
	PopoutManager:sharedInstance():add(self, false, true)
end

function DiffAdjustQAToolPanel:onBaseButtonTapped( btn )

	printx( 1 , "DiffAdjustQAToolPanel:onBaseButtonTapped  btnName " , btn.btnName )

	self:changeTab( btn.btnIndex )

	--[[
	if index == 8 then
		
		local context = self
		local startLevel = tonumber( self.baseColorRect_1:getText() )
		local endLevel = tonumber( self.baseColorRect_2:getText() )
		local repeatCount = tonumber( self.baseColorRect_3:getText() )

		local checkList = nil

		if endLevel >= startLevel then
			checkList = {}

			for i = startLevel , endLevel do
				local dataV = {}
				dataV.levelId = i
				dataV.maxCounts = repeatCount
				dataV.finCallback = nil
				dataV.errorCallback = nil

				table.insert( checkList , dataV )
			end
		end

		local checkParameter = {}
		checkParameter.preProp = self.parameterMap[1]
		checkParameter.buffs = self.parameterMap[2]
		checkParameter.dropColorAdjust = self.parameterMap[3]
		checkParameter.useProp = self.parameterMap[4]
		checkParameter.useReplay = self.parameterMap[5]
		checkParameter.randomTrigger = self.parameterMap[6]
		checkParameter.addSpeed = self.parameterMap[7]

		PopoutManager:sharedInstance():remove(context, true)

		CommonTip:showTip( "双手远离键盘和屏幕，表动！！！" , 'positive' , function ()
				--ReplayAutoCheckManager:check( 4 , 200 , nil , nil )
				
				if checkParameter.useReplay and false then

					if checkList then
						ReplayAutoCheckManager:deleteLocalData()
						ReplayAutoCheckManager:checkByList( checkList , checkParameter , function () 
								setTimeOut( function () self:showSuccess() end , 3 )
							end , 

							function (failedLevels) 
								setTimeOut( function () self:showError(failedLevels) end , 3 )
							end
						)

					end

				else

					--CommonTip:showTip( "还没开发完，玩个蛋丫囧TL" )
					AutoCheckLevelManager:check( startLevel , endLevel , repeatCount , checkParameter , nil , nil )
				end
				

			end , 5)
	else
		local buttonLabel = self["base_button_" .. tostring(index)]:getString()

		if self.parameterMap[index] then
			self.parameterMap[index] = false

			self["base_button_" .. tostring(index)]:useStaticLabel( 16 , "Helvetica" , ccc3(0,0,0) )
			self["base_button_" .. tostring(index)]:setString(buttonLabel)
		else
			self.parameterMap[index] = true

			self["base_button_" .. tostring(index)]:useStaticLabel( 16 , "Helvetica" , ccc3(255,0,0) )
			self["base_button_" .. tostring(index)]:setString(buttonLabel)
		end
	end
	]]
end

function DiffAdjustQAToolPanel:showSuccess()
		CommonTip:showTip("所有关卡测试完毕，没有发现异常。" , "positive" , nil , 9999 )
end

function DiffAdjustQAToolPanel:showError(failedLevels)
	CommonTip:showTip("发现错误以下关卡，详情请查看本地错误日志文件！" , "positive" , nil , 5 )

	local playUI = Director:sharedDirector():getRunningScene()
	local layer = playUI.guideLayer
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true )
	trueMask:setOpacity(200)

	playUI:addChild(trueMask)

	for i = 1 , #failedLevels do
		local fl = failedLevels[i]

		local str = tostring(i) .. "  level " .. tostring(fl.levelId) .. " failed at " .. tostring(fl.counts) .. " count ."
		local txt = TextField:create(str , "Helvetica" , 26)

		txt:setPosition( ccp( 200 , wSize.height - (25 + (i*25)) ) )
		playUI:addChild(txt)
	end
end


function DiffAdjustQAToolPanel:buildEditBox(name)

	local inputBg = self.ui:getChildByName(name)
	local inputBounds = inputBg:getGroupBounds(self.ui)
	local size = inputBg:getGroupBounds().size
	local editBox = TextInputIm:create(size,CCScale9Sprite:create())
	editBox:setFontColor(ccc3(0,0,0))
	editBox:setPositionX(inputBounds:getMidX() - inputBounds:getMidX()*(1-self:getScaleX())/2)
	editBox:setPositionY(inputBounds:getMidY())

	if __IOS then
		editBox.textInput.refCocosObj:setZoomOnTouchDown(false)
		editBox.textInput.refCocosObj:setTouchPriority(0)
	else
		editBox.refCocosObj:setZoomOnTouchDown(false)
		editBox.refCocosObj:setTouchPriority(0)
	end

	self.ui:addChild(editBox) 

	return editBox
end