
local EditInfoPanel = class(BasePanel)
local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'
local PrivateStrategy = require 'zoo.data.PrivateStrategy'

function EditInfoPanel:create( isClick )
    local panel = EditInfoPanel.new()
    panel:loadRequiredResource("ui/personal_center_panel.json")
    panel:init()
    panel.isClick = isClick 
    return panel
end


local function move( ui, dx, dy )
    if not ui then return end
    if ui.isDisposed then return end

    ui:setPositionX(ui:getPositionX() + (dx or 0))
    ui:setPositionY(ui:getPositionY() + (dy or 0))
end

function EditInfoPanel:onKeyBackClicked(...)
    if self.isDisposed then return end
    if self.avatarSelectGroup:closeMoreAvatars() then
        return
    end
    BasePanel.onKeyBackClicked(self, ...)
end

function EditInfoPanel:init()
    local ui = self:buildInterfaceGroup("edit_info")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByPath('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.finishData = {}


    self.headUrl = PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)
    self.nameText = PersonalCenterManager:getData(PersonalCenterManager.NAME)

    for _, v in ipairs({
    	self.ui:getChildByPath('edit_sex/value'),
    	self.ui:getChildByPath('edit_birth/value'),
    	self.ui:getChildByPath('edit_address/value'),
    }) do
    	move(v, 0, -8)
    end


    self:buildBtn()

    self:buildSecretEditor()

    self:buildAddressEditor()

    self:buildDateEditor()

    self:buildSexEditor()

    -- self:buildRewardTip()

    local moreAvatars = self.ui:getChildByPath('moreAvatars')
    moreAvatars:removeFromParentAndCleanup(false)
    self.ui:addChild(moreAvatars)

    local head = self.ui:getChildByPath('head')
    head:removeFromParentAndCleanup(false)
    self.ui:addChild(head)

    self:buildNameHeadEditor()

    self.closeFunc = {}

    self.__enterBackListener = function ( ... )
        if self.isDisposed then return end
        self.avatarSelectGroup:closeNativePhotoView()
    end
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterBackground, self.__enterBackListener)


    self.headBtn = self.ui:getChildByPath("head/btn")
    self.headBtn = GroupButtonBase:create( self.headBtn )
    self.headBtn:setString("点击更换")
    self.headBtn.groupNode:setTouchEnabled(false, 0, true)

end

-- function EditInfoPanel:buildRewardTip( ... )
-- 	if self.isDisposed then return end
-- 	local RewardTip = require 'zoo.scenes.component.HomeScene.RewardTip'
--     local rewardTip = nil
--     rewardTip = RewardTip:create(ResourceManager:sharedInstance():buildGroup("timer.peron.reward/timer"))
--     rewardTip:setPositionX(150)
--     rewardTip:setPositionY(-40)
--     self.rewardTip = rewardTip

--     self.ui:getChildByPath('btn'):addChild(rewardTip)

--     rewardTip:setScale(1/self.ui:getChildByPath('btn'):getScaleX())
--     rewardTip.onStatusChange = function ( ... )
--     	if self.isDisposed then return end
--     	if PersonalInfoReward:isInRewardTime() then
--             rewardTip:setData(PersonalInfoReward:getReward(), PersonalInfoReward:getEndTimeInSec())
--         end
--         rewardTip:setVisible(PersonalInfoReward:isInRewardTime())
--     end
    
--     rewardTip:setVisible(false)
--     PersonalInfoReward:getInfoAsync(rewardTip.onStatusChange)
--    	rewardTip.onStatusChange()
-- end

function EditInfoPanel:buildAddressEditor( ... )
	if self.isDisposed then return end

	
	local valueLabel = self.ui:getChildByPath('edit_address/value')
	valueLabel:removeFromParentAndCleanup(false)
    local notiDot = self.ui:getChildByPath('edit_address/dot')

	local EditInterface = require('zoo.ui.edit.BaseEditCtrl')
    local editor = EditInterface:create()
    self.ui:addChild(editor)

    local TextFieldDisplay = require('zoo.ui.edit.TextFieldDisplay')
    local display = TextFieldDisplay:create(valueLabel)

    local setValue = display.setValue

    display.setValue = function ( _, value )
        if self.isDisposed then return end
        if display.isDisposed then return end
    	setValue(display, value)
    	local year, month, day = string.match(value, '(.*)#(.*)#(.*)')

    	if year and month and day then
    		display.__value = value
    		setValue(display, year .. ' ' .. month .. ' ' .. day)
    	end

        if value == '请选择' then
            -- valueLabel:setColor(hex2ccc3('EF9418'))
            valueLabel:setColor(hex2ccc3('FBDF8C'))
            if notiDot and not notiDot.isDisposed then 
                notiDot:setVisible(true) 
            end
        else
            valueLabel:setColor(hex2ccc3('8D4203'))
            if notiDot and not notiDot.isDisposed then 
                notiDot:setVisible(false) 
            end
        end
    end

    display.getValue = function ( _ )
        if self.isDisposed then return end
        if display.isDisposed then return end
    	return display.__value
    end

    editor:setDisplayView(display)

    local itemHeight = 87


    local function createItem( v )
    	local color = hex2ccc3('F2CE96')
    	local color1 = hex2ccc3('FFFFFF')
    	local t = TextField:create(v, nil, 32)
    	t:setColor(color)


    	t.onFocus = function ( _, isFoucs )
    		if isFoucs then
    			t:setColor(color1)
    		else
    			t:setColor(color)
    		end
    	end

    	t:setDimensions(CCSizeMake(517/3, itemHeight))

    	t.v = v
    	v = TextUtil:ensureTextWidth( v, t:getFontSize(), t:getDimensions() )
    	t:setString(v)

    	t:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
    	t:setHorizontalAlignment(kCCTextAlignmentCenter)
    	t.getValue = function ( ... )
    		return t.v or ''
    	end
    	t.setValue = function (_, newV )
            if self.isDisposed then return end
            if t.isDisposed then return end
            t.v = newV
    		local v = TextUtil:ensureTextWidth( t.v, t:getFontSize(), t:getDimensions() )
    		t:setString(v)
    	end
    	return t
    end



    local selecter = require('zoo.ui.edit.AddressSelectEditor'):create(517, itemHeight * 3, itemHeight, createItem, self:buildInterfaceGroup('weiwei_location'))



    editor:setEditView(selecter)
    selecter:setPositionY(-itemHeight * 3)

    editor:setPositionY(-itemHeight/2 + self.ui:getChildByPath('edit_address'):getPositionY())
    editor:setPositionX(0 + self.ui:getChildByPath('edit_address'):getPositionX())

    local icon = self.ui:getChildByPath('edit_address/icon')

    editor.onEditEndCallback = function ( )
    	if self.isDisposed then return end
    	icon:setFlipY(false)
    	self.finishData[PersonalCenterManager.ADDRESS] = editor:getValue()
    end

    editor.onEditBeginCallback = function ( func )
    	if self.isDisposed then return end
    	self.closeFunc[func] = true
    	icon:setFlipY(true)
    end

    local address = PersonalCenterManager:getData(PersonalCenterManager.ADDRESS)

    if address == '' then
        self.noAddress = true
    end

    selecter.onLoadedCallback = function ( ... )
        if self.isDisposed then return end

        if address and address ~= '' then
            editor:setValue(address)
        else
            if display:getValue() == '请选择' then
                editor:setValue('北京#北京市#东城区')
            end
        end
    end

    if address and address ~= '' then
        editor:setValue(address)
    else
        -- editor:setValue('北京#北京市#东城区')
        display:setValue('请选择')
    end


    local iconClickLayer = Layer:create()

    icon:addChild(iconClickLayer)
    iconClickLayer:setTouchEnabled(true, nil, nil, function ( worldPosition )
        if self.isDisposed then return end
        return icon:hitTestPoint(worldPosition, true)
    end)
    iconClickLayer:ad(DisplayEvents.kTouchBegin, function ( ... )
        if self.isDisposed then return end
        editor:openEditor()
    end)

end

function EditInfoPanel:buildDateEditor( ... )
	
	if self.isDisposed then return end

	local function createItem( v )
    	local color = hex2ccc3('F2CE96')
    	local color1 = hex2ccc3('FFFFFF')
    	local t = TextField:create(v, nil, 32)
    	t:setColor(color)


    	t.onFocus = function ( _, isFoucs )
    		if isFoucs then
    			t:setColor(color1)
    		else
    			t:setColor(color)
    		end
    	end
    	t:setDimensions(CCSizeMake(517, itemHeight))
    	t:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
    	t:setHorizontalAlignment(kCCTextAlignmentCenter)
    	t.getValue = t.getString
    	return t
    end



	local valueLabel = self.ui:getChildByPath('edit_birth/value')
	valueLabel:removeFromParentAndCleanup(false)
    local notiDot = self.ui:getChildByPath('edit_birth/dot')

	local EditInterface = require('zoo.ui.edit.BaseEditCtrl')
    local editor = EditInterface:create()
    self.ui:addChild(editor)

    local TextFieldDisplay = require('zoo.ui.edit.TextFieldDisplay')
    local display = TextFieldDisplay:create(valueLabel)

    local setValue = display.setValue

    display.setValue = function ( _, value )
        if self.isDisposed then return end
        if display.isDisposed then return end

    	display.__value = value
    	setValue(display, value)
    	local year, month, day = string.match(value, '(%d%d%d%d)(%d%d)(%d%d)')
    	if year and month and day then
    		setValue(display, year .. '-' .. month .. '-' .. day)
    	end

        if value == '请选择' then
            -- valueLabel:setColor(hex2ccc3('EF9418'))
            valueLabel:setColor(hex2ccc3('FBDF8C'))
            if notiDot and not notiDot.isDisposed then 
                notiDot:setVisible(true) 
            end
        else
            valueLabel:setColor(hex2ccc3('8D4203'))
            if notiDot and not notiDot.isDisposed then 
                notiDot:setVisible(false) 
            end
        end
    end

    display.getValue = function ( _ )
        if self.isDisposed then return end
        if display.isDisposed then return end
    	return display.__value
    end

    editor:setDisplayView(display)

    local itemHeight = 87

    local selector = require('zoo.ui.edit.DateSelectEditor'):create(517, itemHeight * 3, itemHeight, createItem)


    editor:setEditView(selector)
    selector:setPositionY(-itemHeight * 3)

    editor:setPositionY(-itemHeight/2 + self.ui:getChildByPath('edit_birth'):getPositionY())
    editor:setPositionX(0 + self.ui:getChildByPath('edit_birth'):getPositionX())


    local icon = self.ui:getChildByPath('edit_birth/icon')

    editor.onEditEndCallback = function ( )
    	if self.isDisposed then return end
    	icon:setFlipY(false)
    	self.finishData[PersonalCenterManager.BIRTHDATE] = editor:getValue()
    end

    editor.onEditBeginCallback = function ( func )
    	if self.isDisposed then return end
    	self.closeFunc[func] = true
    	icon:setFlipY(true)
    end

    local birth = PersonalCenterManager:getData(PersonalCenterManager.BIRTHDATE)

    selector.onLoadedCallback = function ( ... )
	    if self.isDisposed then return end
	    if birth and birth ~= '' then
	    	editor:setValue(birth)
	    else
	    	if display:getValue() == '请选择' then
	    		editor:setValue('19700101')

                if not editor:isEditing() then
                    display:setValue('请选择')
                end
	    	end
	    end
	end

	if birth and birth ~= '' then
    	display:setValue(birth)
    else
    	display:setValue('请选择')
    end


    local iconClickLayer = Layer:create()

    icon:addChild(iconClickLayer)
    iconClickLayer:setTouchEnabled(true, nil, nil, function ( worldPosition )
        if self.isDisposed then return end
        return icon:hitTestPoint(worldPosition, true)
    end)
    iconClickLayer:ad(DisplayEvents.kTouchBegin, function ( ... )
        if self.isDisposed then return end
        editor:openEditor()
    end)

end

function EditInfoPanel:dispose( ... )
    BasePanel.dispose(self, ...)
    GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterBackground, self.__enterBackListener)
end

function EditInfoPanel:buildSexEditor( ... )
	if self.isDisposed then return end

	local valueLabel = self.ui:getChildByPath('edit_sex/value')
	valueLabel:removeFromParentAndCleanup(false)
    local notiDot = self.ui:getChildByPath('edit_sex/dot')

	local EditInterface = require('zoo.ui.edit.BaseEditCtrl')
    local editor = EditInterface:create()
    self.ui:addChild(editor)

    local TextFieldDisplay = require('zoo.ui.edit.TextFieldDisplay')
    local display = TextFieldDisplay:create(valueLabel)
    editor:setDisplayView(display)

    local setValue = display.setValue

    display.setValue = function ( _, value )
        if self.isDisposed then return end
        if display.isDisposed then return end
        display.__value = value
        setValue(display, value)
        if value == '请选择' then
            -- valueLabel:setColor(hex2ccc3('EF9418'))
            valueLabel:setColor(hex2ccc3('FBDF8C'))
            if notiDot and not notiDot.isDisposed then
                notiDot:setVisible(true) 
            end
        else
            valueLabel:setColor(hex2ccc3('8D4203'))
            if notiDot and not notiDot.isDisposed then 
                notiDot:setVisible(false) 
            end
        end
    end

    
    local itemHeight = 87

    local selecter = require('zoo.ui.edit.ValueSelectEditor'):create(517, itemHeight * 2, itemHeight)
    editor:setEditView(selecter)
    selecter:setPositionY(-itemHeight * 2)

    editor:setPositionY(-itemHeight/2 + self.ui:getChildByPath('edit_sex'):getPositionY())
    editor:setPositionX(0 + self.ui:getChildByPath('edit_sex'):getPositionX())

    local function createItem( v )
    	local color = hex2ccc3('F2CE96')
    	local color1 = hex2ccc3('FFFFFF')
    	local t = TextField:create(v, nil, 32)
    	t:setColor(color)

    	local bg = self:buildInterfaceGroup('personal/edit_bg')
    	bg:setPositionY(itemHeight)
    	t:addChild(bg)
    	bg.refCocosObj:setZOrder(-1)

    	t.onFocus = function ( _, isFoucs )
            if self.isDisposed then return end

    		if isFoucs then
    			t:setColor(color1)

    			if display:getValue() == '男' then
    				self.finishData[PersonalCenterManager.SEX] = 1
    			elseif display:getValue() == '女' then
    				self.finishData[PersonalCenterManager.SEX] = 2
    			end

    		else
    			t:setColor(color)
    		end

    		bg:getChildByPath('white'):setVisible( not isFoucs)
			bg:getChildByPath('black'):setVisible( isFoucs)
    	end
    	t:setDimensions(CCSizeMake(517, itemHeight))
    	t:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
    	t:setHorizontalAlignment(kCCTextAlignmentCenter)

    	t.getValue = t.getString

    	return t
    end

    selecter:addItem(createItem('男'))
    selecter:addItem(createItem('女'))

    local sex = PersonalCenterManager:getData(PersonalCenterManager.SEX) or 0

    if sex == 1 then
    	editor:setValue('男')
    elseif sex == 2 then
    	editor:setValue('女')
    else
    	selecter:setValue('男')
    	display:setValue('请选择')
    end

    local icon = self.ui:getChildByPath('edit_sex/icon')

    editor.onEditEndCallback = function ( )
    	if self.isDisposed then return end
    	icon:setFlipY(false)
    end

    editor.onEditBeginCallback = function ( func )
    	if self.isDisposed then return end
    	self.closeFunc[func] = true
    	icon:setFlipY(true)
    end

    local iconClickLayer = Layer:create()

    icon:addChild(iconClickLayer)
    iconClickLayer:setTouchEnabled(true, nil, nil, function ( worldPosition )
        if self.isDisposed then return end
        return icon:hitTestPoint(worldPosition, true)
    end)
    iconClickLayer:ad(DisplayEvents.kTouchBegin, function ( ... )
        if self.isDisposed then return end
        editor:openEditor()
    end)
end

function EditInfoPanel:buildSecretEditor( ... )
	if self.isDisposed then return end
	-- body
	self.ui:getChildByPath('secret/label'):setString(localize('my.card.edit.panel.context2'))

	local checked = self.ui:getChildByPath('secret/click/checked')
	local unchecked = self.ui:getChildByPath('secret/click/unchecked')

	local isChecked = PersonalCenterManager:getData(PersonalCenterManager.SELF_INFO_VISIBLE)

	local function refresh( ... )
		if self.isDisposed then return end
		checked:setVisible(isChecked)
		unchecked:setVisible(not isChecked)

		PersonalCenterManager:setData(PersonalCenterManager.SELF_INFO_VISIBLE, isChecked)
	end

	refresh()



	local function timeout()
        if self.scheduleVisibleId ~= nil then 
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleVisibleId)
            self.scheduleVisibleId = nil
        end

        if self.isDisposed then return end
       	refresh()
    end

    local function changeVisibleState()

    	if self.isDisposed then return end

        if isChecked then
            local dcData = {}
            dcData.category = "edit_data"
            dcData.sub_category = "edit_anonymity"
            DcUtil:log(AcType.kUserTrack, dcData, true)
        end
        isChecked = not isChecked

        PersonalCenterManager:setData(PersonalCenterManager.SELF_INFO_VISIBLE, isChecked)

        refresh()

        if self.scheduleVisibleId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleVisibleId)
        end

        self.scheduleVisibleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeout,3,false)
    end

    local function checkNetwork()
        PaymentNetworkCheck.getInstance():check(function ()
            if self.isDisposed then return end
            changeVisibleState()
        end, function ()
            CommonTip:showTip(localize("forcepop.tip3"))
        end)
    end



	local btn = self.ui:getChildByPath('secret/click')
	btn:setTouchEnabled(true)
	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end
		checkNetwork()
	end)
end

function EditInfoPanel:checkInfo( ... )
    if self.isDisposed then return end

   local sex = PersonalCenterManager:getData(PersonalCenterManager.SEX)
   local address = PersonalCenterManager:getData(PersonalCenterManager.ADDRESS)
   local birthDate = PersonalCenterManager:getData(PersonalCenterManager.BIRTHDATE)

   if address == '' then
        self.noAddress = true
    end
   
   local ret = false
   local desc = {}

	if (not self.finishData[PersonalCenterManager.ADDRESS]) and (address == nil or address == '') then
        ret = true
        table.insert(desc, '地址')
	end

	if (not self.finishData[PersonalCenterManager.SEX]) and (sex == nil or sex == 0) then
        ret = true
        table.insert(desc, '性别')
	end

	if (not self.finishData[PersonalCenterManager.BIRTHDATE]) and (birthDate == nil or birthDate == '') then
        ret = true
        table.insert(desc, '生日')
	end


	return ret, table.concat(desc, '、')
end

function EditInfoPanel:buildBtn( ... )
	if self.isDisposed then return end

	self.submitBtn = 	GroupButtonBase:create(self.ui:getChildByPath('btn'))
	self.submitBtn:setString(localize('my.card.edit.panel.btn.save'))
	self.submitBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		
		if self.isDisposed then return end


		local hasChange = false
	    local isUserModifiy = false

        local backup = self.finishData
        self.finishData = {}

        for _type, value in pairs(backup) do
            if PersonalCenterManager:getData(_type) ~= value then
                self.finishData[_type] = value
            end
        end


	    for _type,value in pairs(self.finishData) do
	        if _type == PersonalCenterManager.HEAD_URL then
	            if self.headUrl ~= value then
	                hasChange = true
	                isUserModifiy = true
	                local dcData = {}
	                dcData.category = "edit_data"
	                dcData.sub_category = "edit_photo"
	                dcData.t3 = 1
	                DcUtil:log(AcType.kUserTrack, dcData, true)
	                PersonalCenterManager:setData(_type, value)
	            end
	        elseif _type == PersonalCenterManager.NAME then
	            if self.nameText ~= value then
	                local dcData = {}
	                dcData.category = "edit_data"
	                dcData.sub_category = "edit_name"
	                DcUtil:log(AcType.kUserTrack, dcData, true)
	                hasChange = true
	                isUserModifiy = true
	                PersonalCenterManager:setData(PersonalCenterManager.NAME, value)
	            end
	        elseif value ~= nil and PersonalCenterManager then
	            PersonalCenterManager:setData(_type, value)
	            hasChange = true
	        end

	        if _type == PersonalCenterManager.SEX then
	            DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_gender"}, true)
	        end
	    end


	 --    local needAlert, info = self:checkInfo()
		-- if PersonalInfoReward:isInRewardTime() and needAlert then
		-- 	CommonTip:showTip(localize('my.card.edit.reward.tip1', {info = info}))
		-- else

		-- 	if PersonalInfoReward:isInRewardTime() then
		-- 		local rewards = {PersonalInfoReward:getReward()}
		-- 		PersonalInfoReward:receiveReward(function ( ... )
		-- 			local anim = FlyItemsAnimation:create(rewards)
		-- 			local vs = Director:sharedDirector():getVisibleSize()
		-- 			anim:setWorldPosition(ccp(vs.width/2, vs.height/2))
		-- 			anim:play()
		-- 		end)
		-- 	end

		    if hasChange then
		        CommonTip:showTip("您的个人资料编辑成功！", "positive")
		        if self.onProfileUpdated then
		            self.onProfileUpdated()
		        end
		    else
		        CommonTip:showTip("您没有修改您的个人资料哦~")
		    end
		-- end

        HomeScene:sharedInstance().settingButton:updateDotTipStatus()
	    self:_close()

	end)
end

function EditInfoPanel:onEnterForeGround( ... )
    if self.isDisposed then return end
    -- self.avatarSelectGroup:closeNativePhotoView()
end

function EditInfoPanel:buildNameHeadEditor( ... )
	if self.isDisposed then return end

	local function changePlayer( headUrl )
    	self.finishData[PersonalCenterManager.HEAD_URL] = tostring(headUrl)
    end

    local function changeName( name )
        self.finishData[PersonalCenterManager.NAME] = name
    end

    local AvatarSelectGroup = require "zoo.PersonalCenter.AvatarSelectGroup"
    self.avatarSelectGroup = AvatarSelectGroup:buildGroup(PersonalCenterManager, 
                                self.ui:getChildByPath("moreAvatars"),
                                self.ui:getChildByPath("head"),
                                self.ui:getChildByPath("name"),
                                changePlayer, function ( groupName )
                                    self:loadRequiredResource("ui/personal_center_panel.json")
                                    return self:buildInterfaceGroup(groupName)
                                end)
   	self.avatarSelectGroup.parent = self
   	self.avatarSelectGroup.changeName = changeName

   	self.avatarSelectGroup.closeOtherPanel = function ()
      	-- CommonTip:showTip('closeOtherPanel')
    end

    local headUrl = PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)
    self.avatarSelectGroup:changeAvatarImage(headUrl)

    -- local name = self.ui:getChildByPath("name"):getChildByPath("label")
    -- local nameText = nameDecode(PersonalCenterManager:getData(PersonalCenterManager.NAME))
    -- if name:isVisible() then
    --     name:setString(nameText .." ")
    -- elseif self.avatarSelectGroup.input then
    --     self.avatarSelectGroup.input:setText(nameText)
    -- end

    self.pencil = self.ui:getChildByPath('pencil')
    self.pencil:setTouchEnabled(true)
    self.pencil:ad(DisplayEvents.kTouchTap, function ( 	 )
    	if self.isDisposed then return end
    	if self.avatarSelectGroup and self.avatarSelectGroup.input then
    		if self.avatarSelectGroup.input.openKeyBoard then
    			self.avatarSelectGroup.input:openKeyBoard()
    		end
    	end
    end)
end

function EditInfoPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function EditInfoPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function EditInfoPanel:onCloseBtnTapped( ... )

    if self.isDisposed then return end
    
	if self.finishData ~= nil and 
        (self.finishData[HEAD_URL] == nil or
        self.headUrl == self.finishData[HEAD_URL]) then
            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=2}, true)
	end


	local needAlert, info = self:checkInfo()

	-- if PersonalInfoReward:isInRewardTime() and needAlert then
	-- 	CommonTip:showTip(localize('my.card.edit.reward.tip1', {info = info}))
 --    	self:_close()
 --    	return
	-- end

	-- if PersonalInfoReward:isInRewardTime() then
	-- 	CommonTip:showTip(localize('my.card.edit.reward.tip2'))
	-- 	self:_close()
 --    	return
	-- end


	self:_close()

end

function EditInfoPanel:onEnterHandler(event, ...)
    BasePanel.onEnterHandler(self , event)
    if event == "enter" then
        -- if self.noAddress  or self.isClick == true then
        --     PrivateStrategy:sharedInstance():Alert_Location(  )
        -- end
    end
end


return EditInfoPanel
