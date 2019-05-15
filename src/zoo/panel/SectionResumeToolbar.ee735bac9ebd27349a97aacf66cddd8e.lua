SectionResumeToolbar = class(BasePanel)

local maxUnit = 10

function SectionResumeToolbar:create( panelType ,levelNameStr, yesCallback , noCallback )
	local panel = SectionResumeToolbar.new()
	panel:loadRequiredResource("ui/QATools.json")
	panel:init(panelType , levelNameStr , yesCallback , noCallback)
	return panel
end

function SectionResumeToolbar:init( panelType ,levelNameStr, yesCallback , noCallback )

	self.ui = self:buildInterfaceGroup("QATools/QA_PlayLevel_ToolBar")
	BasePanel.init(self, self.ui)

	local function onCloseBtnTapped(evnet)
		self:onCloseBtnTapped()

		if self.noCallback then self.noCallback() end
	end

	--[[
	self.closeBtn	= self.ui:getChildByName("button_close")
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)
	]]

	local function onBtnTapped(evnet)
		--printx( 1 , "onBtnTapped   stepUnitIndex =" , evnet.target.stepUnitIndex )
		
		self:onStepUnitTapped( evnet.target.stepUnitIndex )
	end

	self.currPage = 1

	for i = 1 , maxUnit do
		self["stepUnit_" .. tostring(i)]	= self.ui:getChildByName("stepUnit_" .. tostring(i))
		self["stepUnit_" .. tostring(i) .. "_buttonRes"] = self["stepUnit_" .. tostring(i)]:getChildByName("base_button_1")
		self["stepUnit_" .. tostring(i) .. "_button"]	= GroupButtonBase:create( self["stepUnit_" .. tostring(i) .. "_buttonRes"] )
		self["stepUnit_" .. tostring(i) .. "_rect"]	= self["stepUnit_" .. tostring(i)]:getChildByName("baseColorRect_1")
		self["stepUnit_" .. tostring(i) .. "_rect"]:setVisible(false)
		
		self["stepUnit_" .. tostring(i) .. "_button"]:setString( tostring(i) )
		self["stepUnit_" .. tostring(i) .. "_button"].stepUnitIndex = i

		self["stepUnit_" .. tostring(i) .. "_button"]:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
	end
	
	self.button_apply_res = self.ui:getChildByName("button_apply")
	self.button_apply = GroupButtonBase:create( self.button_apply_res )
	self.button_apply:useStaticLabel( 16 , "Helvetica" , ccc3(0,0,0) )
	self.button_apply:setString( "Edit" )
	self.button_apply:addEventListener(DisplayEvents.kTouchTap, function () self:onApplyBtnTapped() end )

	self.button_next_res = self.ui:getChildByName("button_next")
	self.button_next = GroupButtonBase:create( self.button_next_res )
	self.button_next:useStaticLabel( 16 , "Helvetica" , ccc3(0,0,0) )
	self.button_next:setString( "Next" )
	self.button_next:addEventListener(DisplayEvents.kTouchTap, function () self:onNextBtnTapped() end )

	self.button_prev_res = self.ui:getChildByName("button_prev")
	self.button_prev = GroupButtonBase:create( self.button_prev_res )
	self.button_prev:useStaticLabel( 16 , "Helvetica" , ccc3(0,0,0) )
	self.button_prev:setString( "Prev" )
	self.button_prev:addEventListener(DisplayEvents.kTouchTap, function () self:onPrevBtnTapped() end )

	self:setCurrStepUnitSelected( SectionResumeManager:getCurrSectionIndex() )
	self.isEditMode = false
	

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSectionResume, function (evt) self:onSectionResumeEvent(evt.data) end )
end

function SectionResumeToolbar:popout()

	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end

	self:setPosition(ccp(self:getHCenterInScreenX() , -10 ))
	PopoutManager:sharedInstance():add(self, false, true)
end

function SectionResumeToolbar:getStepUnit(index)


end

function SectionResumeToolbar:setStepUnitString(index , str)
	self["stepUnit_" .. tostring(index) .. "_button"]:setString( str )
end

function SectionResumeToolbar:setStepUnitSelected(index , selected)
	self["stepUnit_" .. tostring(index) .. "_rect"]:setVisible( selected )
end

function SectionResumeToolbar:setCurrStepUnitSelected(index)
	for i = 1 , maxUnit do
		if i == index then
			self:setStepUnitSelected( i , true )
		else
			self:setStepUnitSelected( i , false )
		end

		local sectionIndex = ( (self.currPage - 1) * 10 ) + i
		local section = SectionResumeManager:getSectionByIndex( sectionIndex )
		if section then
			--printx( 1 , "SectionResumeToolbar:setCurrStepUnitSelected  index =" , i , "sectionIndex =" , sectionIndex , "setEnabled:true")
			--self["stepUnit_" .. tostring(i) .. "_button"]:setEnabled(true)
			self["stepUnit_" .. tostring(i) .. "_button"]:setVisible(true)
		else
			--printx( 1 , "SectionResumeToolbar:setCurrStepUnitSelected  index =" , i , "sectionIndex =" , sectionIndex , "setEnabled:false")
			--self["stepUnit_" .. tostring(i) .. "_button"]:setEnabled(false)
			self["stepUnit_" .. tostring(i) .. "_button"]:setVisible(false)
		end
	end
end

function SectionResumeToolbar:tryChangePage(newPage)
	--printx( 1, "SectionResumeToolbar:tryChangePage   " , newPage , self.currPage , debug.traceback())
	if self.currPage ~= newPage then

		for i = 1 , maxUnit do
			self["stepUnit_" .. tostring(i) .. "_button"]:setString( tostring(i + 10 * (newPage - 1) ) )
		end
		

		self.currPage = newPage
	end
end

function SectionResumeToolbar:onStepUnitTapped(index)
	if not self.isEditMode then return end

	SectionResumeManager:doRevertByIndex( index + ( 10 * ( self.currPage - 1 ) ) , 1 ) 
	self:setCurrStepUnitSelected(index)
end

function SectionResumeToolbar:onNextBtnTapped()
	if not self.isEditMode then return end

	SectionResumeManager:doRevertByIndex( SectionResumeManager:getCurrSectionIndex() + 1 , 1 )
	setTimeOut( function () 

			local cs = SectionResumeManager:getCurrSectionIndex()
			local newPage = 1
			if cs > 10 then
				newPage = math.floor( cs / 10 ) + 1
				cs = cs % 10
			end
			self:tryChangePage(newPage)
			self:setCurrStepUnitSelected( cs ) 

		end , 0.1 )
end

function SectionResumeToolbar:onPrevBtnTapped()
	if not self.isEditMode then return end

	SectionResumeManager:doRevertByIndex( SectionResumeManager:getCurrSectionIndex() - 1 , 1 )
	setTimeOut( function () 

			local cs = SectionResumeManager:getCurrSectionIndex()
			local newPage = 1
			if cs > 10 then
				newPage = math.floor( cs / 10 ) + 1
				cs = cs % 10
			end
			self:tryChangePage(newPage)
			self:setCurrStepUnitSelected( cs ) 

		end , 0.1 )
end

function SectionResumeToolbar:onApplyBtnTapped()
	--printx( 1 , "SectionResumeToolbar:onApplyBtnTapped   self.isEditMode " , self.isEditMode )
	if self.isEditMode then
		self.isEditMode = false
		self.button_apply:setString( "Edit" )

		if self.swallowLayer then self.swallowLayer:removeFromParentAndCleanup(true) end
		SectionResumeManager:deleteDatasOverCurrSectionIndex()

		local cs = SectionResumeManager:getCurrSectionIndex()
		local newPage = 1
		if cs > 10 then
			newPage = math.floor( cs / 10 ) + 1
			cs = cs % 10
		end
		self:tryChangePage(newPage)
		self:setCurrStepUnitSelected( cs ) 
	else
		self.isEditMode = true
		self.button_apply:setString( "Apply" )

		local visibleSize =  CCDirector:sharedDirector():ori_getVisibleSize()
		local swallowLayer = Layer:create()
		swallowLayer:setTouchEnabled(true, 0, true)
		swallowLayer:setContentSize(visibleSize)
		swallowLayer:setPositionY( visibleSize.height * -1 )
		self.ui:addChildAt(swallowLayer , 1)
		--self:addChild(swallowLayer)
		self.swallowLayer = swallowLayer
	end
	--PopoutManager:sharedInstance():remove(self, true)
end

function SectionResumeToolbar:onSectionResumeEvent(datas)
	local cs = datas.currSectionIndex
	local newPage = 1
	if cs > 10 then
		newPage = math.floor( cs / 10 ) + 1
		cs = cs % 10
	end
	self:tryChangePage(newPage)
	self:setCurrStepUnitSelected( cs )
end