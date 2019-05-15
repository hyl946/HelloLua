QAToolTestCodePanel = class(BasePanel)

function QAToolTestCodePanel:create(closeCallback)
	local panel = QAToolTestCodePanel.new()
	panel:loadRequiredResource("ui/QATools.json")
	panel.closeCallback = closeCallback
	panel:init()
	return panel
end

function QAToolTestCodePanel:init()

	self.ui = self:buildInterfaceGroup("QATools/QAToolTestCodePanel_RES")
	BasePanel.init(self, self.ui)

	self.bg = self.ui:getChildByName("baseColorRect")
	-- self.bg:setTouchEnabled(true)
	self.bg:setTouchEnabled(true, 0, true)
	self.bg:addEventListener(DisplayEvents.kTouchTap, function () 
			-- printx( 1 , "RRRRRRRRRRRRRRRRRRRRRRRRRRR!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		end )

	self.btn_do_res = self.ui:getChildByName("base_button_1")
	self.btn_do	= GroupButtonBase:create( self.btn_do_res )
	self.btn_do:useStaticLabel( 20 , "微软雅黑" , ccc3(0,0,0) )
	self.btn_do:setString( "执行" )
	self.btn_do:addEventListener(DisplayEvents.kTouchTap, function () self:onDo() end )

	self.btn_close_res = self.ui:getChildByName("base_button_2")
	self.btn_close	= GroupButtonBase:create( self.btn_close_res )
	self.btn_close:useStaticLabel( 20 , "微软雅黑" , ccc3(0,0,0) )
	self.btn_close:setString( "退出" )
	self.btn_close:addEventListener(DisplayEvents.kTouchTap, function () self:onCloseButtonTapped() end )

	self.inputBox = self:buildEditBox("baseColorRect_1")
	--
--
--
--
--
--

end

function QAToolTestCodePanel:onCloseButtonTapped()
	PopoutManager:sharedInstance():remove(self, true)
	if self.closeCallback then self.closeCallback() end
end

function QAToolTestCodePanel:onDo()
	local str = self.inputBox:getText()
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

	self:onCloseButtonTapped()
end


function QAToolTestCodePanel:buildEditBox(name)

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

function QAToolTestCodePanel:popout()

	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end


	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= 812

	local deltaHeight	= visibleSize.height - selfHeight

	self:setPosition(ccp(self:getHCenterInScreenX() + 0 , deltaHeight * -1 ))
	PopoutManager:sharedInstance():add(self, false, true)
end
