local EditProfilePanel = class(BasePanel)
local SelectTableView = class(Layer)
local ConfirmEditPanel = class(BasePanel)

-- local print = function ( str )
-- 	oldPrint("[EditProfilePanel] "..str)
-- end

local function constellationDate( index )
    local date = {
        {
            month1 = 3,
            day1 = 21,
            month2 = 4,
            day2 = 19
        },
        {
            month1 = 4,
            day1 = 20,
            month2 = 5,
            day2 = 20
        },
        {
            month1 = 5,
            day1 = 21,
            month2 = 6,
            day2 = 21
        },
        {
            month1 = 6,
            day1 = 22,
            month2 = 7,
            day2 = 22
        },
        {
            month1 = 7,
            day1 = 23,
            month2 = 8,
            day2 = 22
        },
        {
            month1 = 8,
            day1 = 23,
            month2 = 9,
            day2 = 22
        },
        {
            month1 = 9,
            day1 = 23,
            month2 = 10,
            day2 = 23
        },
        {
            month1 = 10,
            day1 = 24,
            month2 = 11,
            day2 = 22
        },
        {
            month1 = 11,
            day1 = 23,
            month2 = 12,
            day2 = 21
        },
        {
            month1 = 12,
            day1 = 22,
            month2 = 1,
            day2 = 19
        },
        {
            month1 = 1,
            day1 = 20,
            month2 = 2,
            day2 = 18
        },
        {
            month1 = 2,
            day1 = 19,
            month2 = 3,
            day2 = 20
        }
    }

    local d = date[index]

    return "("..d.month1 .. "." .. d.day1  .. "-" ..
            d.month2 .. "." .. d.day2 .. ")"
end

function ConfirmEditPanel:create(cancelCallback)
    local confirmEditPanel = ConfirmEditPanel.new()
    confirmEditPanel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    confirmEditPanel:init(cancelCallback)
    return confirmEditPanel
end

function ConfirmEditPanel:init( cancelCallback )
    self.ui = self:buildInterfaceGroup("personal_center_confirm_edit_panel")
    BasePanel.init(self, self.ui)

    self.editBtn = GroupButtonBase:create(self.ui:getChildByName('editBtn'))
    self.editBtn:setString(localize("my.card.btn4"))
    self.editBtn:ad(DisplayEvents.kTouchTap, function()
        self:onRemoveSelf()
    end)

    self.cancel = GroupButtonBase:create(self.ui:getChildByName('cancel'))
    self.cancel:setString(localize("my.card.btn5"))
    self.cancel:setColorMode(kGroupButtonColorMode.blue)
    self.cancel:ad(DisplayEvents.kTouchTap, function()
        self:onRemoveSelf()
        if cancelCallback then cancelCallback() end
    end)

    self.ui:getChildByName('text'):setString(localize("my.card.edit.alert.text1"))
end

function ConfirmEditPanel:onRemoveSelf()
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false
end

function ConfirmEditPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
    self:setPosition(ccp(centerPosX, centerPosY))
end

local ITEM_HEIGHT = 60
local ITEM_WIDTH  = 344
local SelectType
local configs

function SelectTableView:create(width, height, itemHeight, visibleItemNum)
    local tableView = SelectTableView.new()
    tableView:init(width, height, itemHeight, visibleItemNum)

    return tableView
end

function SelectTableView:init(width, height, itemHeight, visibleItemNum)
    self:initLayer()

    self.width = width
    self.height = height
    self.visibleItemNum = visibleItemNum

    self.normalTextColor = ccc3(239, 198, 120)
    self.selectedTextColor = ccc3(255, 255, 255)
    self.normalBgColor = self.selectedTextColor
    self.selectedBgColor = self.normalTextColor

    -- Stencil
    local stencil   = LayerColor:create()
    stencil:setColor(ccc3(255,0,0))
    stencil:changeWidthAndHeight(width, height)
    stencil:setPosition(ccp(0, -height))
    
    -- Clipping
    local cppClipping = CCClippingNode:create(stencil.refCocosObj)
    local luaClipping = ClippingNode.new(cppClipping)
    self:addChild(luaClipping)
    self.contentLayer = Layer:create()
    luaClipping:addChild(self.contentLayer)

    local function onTouchBegin(event)
        self:onTouchBegin(event)
    end

    local function onTouchMove(event)
        self:onTouchMove(event)
    end

    local function onTouchEnd(event)
        self:onTouchEnd(event)
    end

    self.itemHeight = itemHeight

    local touchTapLayer   = LayerColor:create()
    touchTapLayer:setColor(ccc3(255,0,0))
    touchTapLayer:setOpacity(0)
    touchTapLayer:changeWidthAndHeight(width, height)
    touchTapLayer:setPosition(ccp(0, -height))
    self.touchTapLayer = touchTapLayer
    self:addChild(touchTapLayer)

    touchTapLayer:setTouchEnabled(true, 0, true)
    touchTapLayer:addEventListener(DisplayEvents.kTouchBegin, onTouchBegin)
    touchTapLayer:addEventListener(DisplayEvents.kTouchMove, onTouchMove)
    touchTapLayer:addEventListener(DisplayEvents.kTouchEnd, onTouchEnd)
    touchTapLayer:addEventListener(DisplayEvents.kTouchTap, function ( event )
        self:touchTap(event)
    end)
end

function SelectTableView:touchTap( event )
    local pos = event.globalPosition
    local npos = self.contentLayer:convertToNodeSpace(pos)
    for index,item in ipairs(self.contentLayer.list) do
        local size = item:getGroupBounds().size
        local position = item:getPosition()
        local rect = CCRectMake(position.x, position.y, size.width, size.height)
        if rect:containsPoint(npos) then
            if self.selectedNotify then
                self.selectedNotify(item:getTag())
                self:removeSelf()
            end
            break
        end
    end
end

function SelectTableView:onTouchBegin( event )
    self.lastY = event.globalPosition.y
    self.beginPosY = self.contentLayer:getPosition().y
    self.beginEventPos = event.globalPosition
end

function SelectTableView:onTouchMove( event )
    local newPos    = self.contentLayer:getPosition()
    local deltaY    = event.globalPosition.y - self.lastY

    local y = newPos.y + deltaY

    self.contentLayer:setPosition(ccp(newPos.x, y))
    self.lastY  = event.globalPosition.y
end

function SelectTableView:onTouchEnd( event )
    local endPos = event.globalPosition

    local deltaY = endPos.y - self.beginEventPos.y
    local step = deltaY / self.itemHeight
    step = deltaY > 0 and math.floor(step) or math.ceil(step)
    self:move(step)
end

function SelectTableView:updateCurItemState(curItemIndex)
    local itemNum = #self.contentLayer.list
    local index = math.ceil(self.visibleItemNum / 2)
    local posy = self.contentLayer:getPositionY()
    local num = math.floor(posy / ITEM_HEIGHT)
    local curIndex = index + num

    if curItemIndex then
        curIndex = curItemIndex
    end

    if self.curItem then
        if self.curItem.selectedLayer then
            self.curItem.text:setVisible(true)
            self.curItem.selectedLayer:setVisible(false)
        else
            self.curItem.text:setColor(self.normalTextColor)
            self.curItem.text:setScale(1.0)
        end

        self.curItem:setColor(self.normalBgColor)
    end

    local item = self.contentLayer.list[curIndex]
    item:setColor(self.selectedBgColor)

    if item.selectedLayer then
        item.text:setVisible(false)
        item.selectedLayer:setVisible(true)
    else
        item.text:setColor(self.selectedTextColor)
        item.text:setScale(1.3)
    end
    
    self.curItem = item
end

function SelectTableView:setCurItem( itemNum )
    local index = math.ceil(self.visibleItemNum / 2)
    if itemNum <= self.visibleItemNum or itemNum <= index then
        self:updateCurItemState(itemNum)
    else
        self:move(itemNum - index)
    end
   
end

function SelectTableView:move( step )
    local pos = self.contentLayer:getPosition()
    local beginPosY = self.beginPosY or 0

    local deltaY = step * self.itemHeight + beginPosY

    local itemNum = #self.contentLayer.list

    local maxY = itemNum * self.itemHeight - self.height
    if deltaY > maxY  then 
        deltaY = maxY
    end

    if itemNum * self.itemHeight < self.height then deltaY = 0 end

    if deltaY < 0 then deltaY = 0 end

    local function aniEnd()
        self:updateCurItemState()
    end
    local seq = CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(pos.x, deltaY)), CCCallFunc:create(aniEnd))
    self.contentLayer:runAction(seq)
end

function SelectTableView:addItem( item, index )
    local size = item:getGroupBounds().size
    local layerItem = LayerColor:createWithColor(self.normalBgColor, ITEM_WIDTH, ITEM_HEIGHT)
    layerItem:addChild(item)
    layerItem.text = item.text
    layerItem.selectedLayer = item.selectedLayer
    self.contentLayer:addChild(layerItem)
    layerItem:setTag(index)
    layerItem:setPosition(ccp(0, -self.itemHeight * #self.contentLayer.list))
end

function SelectTableView:removeSelf()
    self:removeFromParentAndCleanup(true)
    if self.removeNotify then
        self.removeNotify()
    end
end

function EditProfilePanel:create(manager)
    local panel = EditProfilePanel.new()
    panel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    panel:init(manager)
    return panel
end

function EditProfilePanel:init(manager)
	self.manager = manager

	self.ui = self:buildInterfaceGroup("personal_center_edit_panel")
    BasePanel.init(self, self.ui)


    self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName('cancelBtn'))
	self.cancelBtn:setString(localize("my.card.edit.panel.text4"))
    self.cancelBtn:setColorMode(kGroupButtonColorMode.orange)
	self.cancelBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
                                     if _G.isLocalDevelopMode then printx(0, self.headUrl, "\n", self.finishData[HEAD_URL]) end
                                     if self.finishData ~= nil and 
                                        (self.finishData[HEAD_URL] == nil or
                                        self.headUrl == self.finishData[HEAD_URL]) then
                                            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=2}, true)
                                            -- local dcData = {}
                                            -- dcData.category = "edit_data"
                                            -- dcData.sub_category = "edit_photo"
                                            -- dcData.t3 = 2
                                            -- DcUtil:log(AcType.kUserTrack, dcData, true)
                                      end
	                               	  self:removeSelf()
	                               end)

    -- self.name = self.ui:getChildByName("name")
    -- self.name:setString(nameDecode(manager:getData(manager.NAME)))

    local sexText = self.ui:getChildByName("sexText")
    local sexPos = sexText:getPosition()
    sexText:setAnchorPoint(ccp(0.5, 0.5))
    sexText:setScale(1.5)
    sexText:setPosition(ccp(sexPos.x + 80, sexPos.y - 30))
    sexText:setText(localize("my.card.edit.panel.tag.gender"))

    local consText = self.ui:getChildByName("consText")
    local consPos = consText:getPosition()
    consText:setAnchorPoint(ccp(0.5, 0.5))
    consText:setScale(1.5)
    consText:setPosition(ccp(consPos.x + 80, consPos.y - 30))
    consText:setText(localize("my.card.edit.panel.tag.constellation"))

    local ageText = self.ui:getChildByName("ageText")
    local agePos = ageText:getPosition()
    ageText:setAnchorPoint(ccp(0.5, 0.5))
    ageText:setScale(1.5)
    ageText:setPosition(ccp(agePos.x + 80, agePos.y - 30))
    ageText:setText(localize("my.card.edit.panel.tag.age"))

    self.finishBtn = GroupButtonBase:create(self.ui:getChildByName('finishBtn'))
    self.finishBtn:setString(localize("my.card.btn6"))
    self.finishBtn:ad(DisplayEvents.kTouchTap, function()
        self:saveData()
    end)

    local function buildSelectTouch( touchName, func )
        local touch = self.ui:getChildByName(touchName)
        touch:getChildByName("touch"):setOpacity(0)
        touch:setTouchEnabled(true)
        touch:ad(DisplayEvents.kTouchTap,func)

        return touch
    end

    self.tableView = {}

    SelectType = {
        SEX = manager.SEX,
        CONS = manager.CONSTELLATION,
        AGE = manager.AGE,
    }

    configs = {
        [SelectType.SEX] = {
            visibleItemNum = 2,
            itemNum = 2,
            defaultIndex = 2,
            str = function ( index )
                if index == 1 then
                    return localize("my.card.edit.panel.content.male")
                elseif index == 2 then
                    return localize("my.card.edit.panel.content.female")
                end
            end,
            name = "sex",
            pos = "sexLayer",
            upBtn = "sexUp",
            bgLayer = "sexLayer",
        },
        [SelectType.CONS] = {
            visibleItemNum = 5,
            itemNum = 12,
            defaultIndex = 1,
            str = function ( index )
                return localize("my.card.edit.panel.content.constellation"..index)
            end,
            dateStr = constellationDate,
            name = "cons",
            pos = "consLayer",
            upBtn = "consUp",
            bgLayer = "consLayer",
        },
        [SelectType.AGE] = {
            visibleItemNum = 5,
            itemNum = 100,
            defaultIndex = 20,
            str = function ( index )
                if index == 100 then return "99+" end
               return tostring(index)
            end,
            name = "age",
            pos = "ageLayer",
            upBtn = "ageUp",
            bgLayer = "ageLayer",
        },
    }

    self.sexTouch = buildSelectTouch("sexTouch", function ()
        if _G.isLocalDevelopMode then printx(0, "sexTouch ...") end
        self:selectTableView(SelectType.SEX)
    end)

    self.consTouch = buildSelectTouch("consTouch", function ()
        if _G.isLocalDevelopMode then printx(0, "consTouch...") end
        self:selectTableView(SelectType.CONS)
    end)

    self.ageTouch = buildSelectTouch("ageTouch", function ()
        if _G.isLocalDevelopMode then printx(0, "ageTouch...") end
        self:selectTableView(SelectType.AGE)
    end)

    self.ui:getChildByName("sexUp"):setVisible(false)
    self.ui:getChildByName("consUp"):setVisible(false)
    self.ui:getChildByName("ageUp"):setVisible(false)

    self.ui:getChildByName("sexLayer"):setVisible(false)
    self.ui:getChildByName("consLayer"):setVisible(false)
    self.ui:getChildByName("ageLayer"):setVisible(false)
    
    self.finishData = {}

    for _type,config in pairs(configs) do
        local value = manager:getData(_type)
        local str = config.str(value)
        if value == 0 then
            str = localize("my.card.edit.panel.text5")
        end
        self.ui:getChildByName(config.name):setString(str)
    end

    self.headUrl = manager:getData(manager.HEAD_URL)
    self.nameText = manager:getData(manager.NAME)

    local function changePlayer( clipping, headUrl )
        self.finishData[manager.HEAD_URL] = tostring(headUrl)
    end

    local function changeName( name )
        self.finishData[manager.NAME] = name
    end

    local AvatarSelectGroup = require "zoo.PersonalCenter.AvatarSelectGroup"
    self.avatarSelectGroup = AvatarSelectGroup:buildGroup(manager, 
                                self.ui:getChildByName("moreAvatars"),
                                self.ui:getChildByName("avatar"),
                                self.ui:getChildByName("nameLabel"),
                                changePlayer
                                )
    self.avatarSelectGroup.changeName = changeName

    self.avatarSelectGroup.closeOtherPanel = function ()
        for _type,tv in pairs(self.tableView) do
            local _config = configs[_type]
            self.ui:getChildByName(_config.upBtn):setVisible(false)
            self.ui:getChildByName(_config.bgLayer):setVisible(false)
            tv:setVisible(false)
            tv.bg:setVisible(false)
        end
    end

    self.avatarSelectGroup.parent = self

    self.ui:getChildByName("title"):setText(localize("my.card.btn1"))

    self.infoVisible = self.manager:getData(self.manager.SELF_INFO_VISIBLE)
    local visibleText = self.ui:getChildByName("visibleText")
    local invisible = self.ui:getChildByName("invisible")
    visibleText:setVisible(false)

    if self.infoVisible then
        invisible:setVisible(false)
    else
        invisible:setVisible(true)
    end

    local function timeout()
        if self.scheduleVisibleId ~= nil then 
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleVisibleId)
            self.scheduleVisibleId = nil
        end
        visibleText:setVisible(false)
    end

    local function changeVisibleState()
        if self.infoVisible then
            local dcData = {}
            dcData.category = "edit_data"
            dcData.sub_category = "edit_anonymity"
            DcUtil:log(AcType.kUserTrack, dcData, true)
            visibleText:setString(localize("my.card.edit.tip2"))
        else
            visibleText:setString(localize("my.card.edit.tip1"))
        end
        self.infoVisible = not self.infoVisible

        self.manager:setData(self.manager.SELF_INFO_VISIBLE, self.infoVisible)

        invisible:setVisible(not self.infoVisible)
        visibleText:setVisible(true)

        if self.scheduleVisibleId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleVisibleId)
        end

        self.scheduleVisibleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeout,3,false)
    end

    local function checkNetwork()
        PaymentNetworkCheck.getInstance():check(function ()
            changeVisibleState()
        end, function ()
            CommonTip:showTip(localize("forcepop.tip3"))
        end)
    end

    self.visible = self.ui:getChildByName('visible')
    self.visible:setTouchEnabled(true, 0, false)
    self.visible:setButtonMode(true)
    self.visible:addEventListener(DisplayEvents.kTouchTap, checkNetwork)

    if _G.isLocalDevelopMode then printx(0, "init >>>>>") end
end

function EditProfilePanel:setTableViewVisible( config, tableview, visible )
    self.ui:getChildByName(config.upBtn):setVisible(visible)
    self.ui:getChildByName(config.bgLayer):setVisible(visible)
    tableview:setVisible(visible)
    tableview.bg:setVisible(visible)
end

function EditProfilePanel:selectTableView(selectType)
    local needReturn = false
    for _type,tv in pairs(self.tableView) do
        local _config = configs[_type]
        if _type == selectType then
            if self.ui:getChildByName("moreAvatars"):isVisible() then
                return
            end
            if tv:isVisible() then
                self:setTableViewVisible(_config, tv, false)
            else
                self:setTableViewVisible(_config, tv, true)
            end

            needReturn = true
        else
            self:setTableViewVisible(_config, tv, false)
        end
    end

    if needReturn then
        return
    end

    if self.ui:getChildByName("moreAvatars"):isVisible() then
        return
    end

    local config = configs[selectType]
    self.ui:getChildByName(config.upBtn):setVisible(true)
    self.ui:getChildByName(config.bgLayer):setVisible(true)
    local visibleItemNum = config.visibleItemNum
    local itemNum = config.itemNum
    local line = self.ui:getChildByName(config.pos)
    local pos = ccp(line:getPositionX(), line:getPositionY())
    pos.y = pos.y - 75
    pos.x = pos.x + 165

    local w = ITEM_WIDTH
    local h = visibleItemNum * (ITEM_HEIGHT + 2)

    local bg = LayerColor:createWithColor(ccc3(255, 186, 72), w, h)
    bg:ignoreAnchorPointForPosition(false)
    bg:setTouchEnabled(true, 0 ,true)
    bg:setAnchorPoint(ccp(0,1))
    bg:setPosition(ccp(pos.x, pos.y))
    self.ui:addChild(bg)

    local scrollable = VerticalScrollable:create(w, h, true, false)
    local layout = VerticalTileLayout:create(w)
    layout:setItemVerticalMargin(2)
    scrollable:setPosition(ccp(pos.x, pos.y))
    scrollable.bg = bg
    local normalTextColor = ccc3(255, 153, 0)

    local function buildItem( index )
        local str = config.str(index)
        local content

        if selectType == SelectType.CONS then
            content = LayerColor:createWithColor(ccc3(255,255,255), ITEM_WIDTH, ITEM_HEIGHT)
            content:ignoreAnchorPointForPosition(false)
            content:setAnchorPoint(ccp(0,1))
            local t = TextField:create(str, nil, 30, nil, hAlignment, kCCVerticalTextAlignmentCenter)
            t:setColor(normalTextColor)
            t:setPosition(ccp(ITEM_WIDTH / 2 - 85, ITEM_HEIGHT / 2))

            local data = TextField:create(config.dateStr(index), nil, 28, nil, hAlignment, kCCVerticalTextAlignmentCenter)
            data:setColor(normalTextColor)
            data:setPosition(ccp(ITEM_WIDTH / 2 + 75, ITEM_HEIGHT / 2))

            content:addChild(t)
            content:addChild(data)
            content.text = t
            content.text1 = data
        else
            content = LayerColor:createWithColor(ccc3(255,255,255), ITEM_WIDTH, ITEM_HEIGHT)
            content:ignoreAnchorPointForPosition(false)
            content:setAnchorPoint(ccp(0,1))
            local text = TextField:create(str, nil, 30, nil, hAlignment, kCCVerticalTextAlignmentCenter)
            text:setColor(normalTextColor)
            text:setPosition(ccp(ITEM_WIDTH / 2 - 20, ITEM_HEIGHT / 2))
            content:addChild(text)
            content.text = text
        end

        content:setTouchEnabled(true)
        local item = ItemInClippingNode:create()

        local function onTouchBegin(event)
            local pos = event.globalPosition
            local npos = item:convertToNodeSpace(ccp(pos.x, pos.y))
            local cpos = content:getPosition()
            local size = content:getGroupBounds().size
            local rect = CCRectMake(cpos.x, cpos.y - size.height, size.width, size.height)
            if rect:containsPoint(npos) then
                if content.text then
                    content.text:setScale(1.2)
                    content.text:setColor(ccc3(255,255,255))
                end

                if content.text1 then
                    content.text1:setScale(1.2)
                    content.text1:setColor(ccc3(255,255,255))
                end

                content:setColor(ccc3(255, 186, 72))

                content.isChanged = true
            end
        end

        local function onTouchEnd( event )
            if content.isChanged == true then
                if content.text then
                    content.text:setScale(1)
                    content.text:setColor(normalTextColor)
                end

                if content.text1 then
                    content.text1:setScale(1)
                    content.text1:setColor(normalTextColor)
                end

                content:setColor(ccc3(255,255,255))
            end
        end

        content:ad(DisplayEvents.kTouchTap, 
                                   function (event)
                                        if scrollable:isVisible() then
                                            scrollable:setVisible(false)
                                            scrollable.bg:setVisible(false)
                                            self.ui:getChildByName(config.upBtn):setVisible(false)
                                            self.ui:getChildByName(config.bgLayer):setVisible(false)
                                            self:setData(selectType, index)
                                        end
                                   end)

        content:addEventListener(DisplayEvents.kTouchBegin, onTouchBegin)
        content:addEventListener(DisplayEvents.kTouchEnd, onTouchEnd)

        item:setParentView(scrollable)
        item:setContent(content)
        return item
    end

    for index = 1, itemNum do
        local item = buildItem(index)
        layout:addItem(item)
    end

    local defaultIndex = self.manager:getData(selectType)
    if defaultIndex == nil or defaultIndex == 0 then
        defaultIndex = config.defaultIndex
    end

    if defaultIndex >= 96 then
        defaultIndex = 96
    end

    if selectType == SelectType.CONS and defaultIndex >= 8 then
        defaultIndex = 8
    end

    scrollable:setContent(layout)
    self.tableView[selectType] = scrollable
    self.ui:addChild(scrollable)

    if selectType ~= SelectType.SEX then
        local y = (defaultIndex-1) * (ITEM_HEIGHT + 2)
        scrollable.container:stopAllActions()
        scrollable:__moveTo(y, 0.2)
    end

    -- tableView.removeNotify = function ()
    --     self.tableView[selectType] = nil
    -- end

    -- tableView.selectedNotify = function (index)
    --     self:setData(selectType, index)
    -- end
end

function EditProfilePanel:setData( selectType, index )
    if _G.isLocalDevelopMode then printx(0, "type : "..selectType.."index : "..index) end
    self.finishData[selectType] = index
    local config = configs[selectType]
    self.ui:getChildByName(config.name):setString(config.str(index))
end

function EditProfilePanel:saveData()
    local hasChange = false
    local isUserModifiy = false

    for _type,value in pairs(self.finishData) do
        if _type == self.manager.HEAD_URL then
            if self.headUrl ~= value then
                hasChange = true
                isUserModifiy = true
                local dcData = {}
                dcData.category = "edit_data"
                dcData.sub_category = "edit_photo"
                dcData.t3 = 1
                DcUtil:log(AcType.kUserTrack, dcData, true)
                self.manager:setData(_type, value)
                --DcUtil:UserTrack({category='my_card', sub_category="my_card_upload_photo"}, true)
            end
        elseif _type == self.manager.NAME then
            if self.nameText ~= value then
                local dcData = {}
                dcData.category = "edit_data"
                dcData.sub_category = "edit_name"
                DcUtil:log(AcType.kUserTrack, dcData, true)
                hasChange = true
                isUserModifiy = true
                self.manager:setData(self.manager.NAME, value)
                -- DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_name"}, true)
            end
        elseif value ~= 0 and self.manager then
            self.manager:setData(_type, value)
            hasChange = true
        end

        if _type == self.manager.AGE then
            DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_age"}, true)
        elseif _type == self.manager.SEX then
            DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_gender"}, true)
        elseif _type == self.manager.CONSTELLATION then
            DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_constellation"}, true)
        end
    end


    if hasChange then
        CommonTip:showTip("您的个人资料编辑成功！", "positive")
        if self.onProfileUpdated then
            self.onProfileUpdated()
        end
    else
        CommonTip:showTip("您没有修改您的个人资料哦~")
    end

    self:removeSelf(isUserModifiy)
end

function EditProfilePanel:onAvatarTouch()
    if self.moreAvatars:isVisible() then 
        self.moreAvatars:setVisible(false)
    else 
        self.moreAvatars:setVisible(true)  
    end
end

function EditProfilePanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function EditProfilePanel:createShowAnim()
    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished( )self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function EditProfilePanel:setProfileUpdatedCallback(onProfileUpdated)
    self.onProfileUpdated = onProfileUpdated
end

function EditProfilePanel:onEnterAnimationFinished()
   
end

function EditProfilePanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
end

function EditProfilePanel:removeSelf(isUserModifiy)
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false

    if self.parentPanel then
        self.parentPanel:updateProfile(false, isUserModifiy)
    end
end

function EditProfilePanel:onCloseBtnTapped()
    self:removeSelf()
end

return EditProfilePanel