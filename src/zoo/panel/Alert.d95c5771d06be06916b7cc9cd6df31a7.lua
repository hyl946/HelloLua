--IOS系统样式的纯白确认弹框

-- local params={}
-- params.info = "是否消耗流量下载更新？"
-- params.okCallback = handler(self,self.__startDownload)
-- params.isConfirm = true
-- Alert:create(params)

Alert = class(BasePanel)

function Alert:create(customData)
    if type(customData)=="string" then
        customData={info=customData}
    end
    
    -- printx(0,"Alert:create()"..table.tostring(customData)..debug.traceback())

	local a = Alert.new()
	a:init(customData)
    a:popout()
	return a
end

function Alert:init( customData )
    self.customData = customData

    self:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    self.ui = self:buildInterfaceGroup("whiteAlert")
	BasePanel.init(self, self.ui)

    local childs = {
        "scale9Bg",
        "leftHotArea",
        "rightHotArea",
        "line_spliceBtn",
        "line_hoverBtn",
        "infoLabel",
        "titleLabel",
        "tipLabel",
        "leftBtnLabel",
        "rightBtnLabel",
        "centerBtnLabel",
    }
    for i,v in ipairs(childs) do
        self[v] = self.ui:getChildByName(v)
    end

    local function setText(label,str)
        str = str or ""
        if not label or not label.setString then 
            -- print("NO LABEL:" .. debug.traceback())
            do return end
        end
        label:setString(tostring(str))
    end
    self.infoLabel:setDimensions(CCSizeMake( 600 , 0))
    
    -- self.infoLabel:setContentSize( CCSizeMake(620,0) )
    setText(self.titleLabel,customData.title)
    setText(self.infoLabel,customData.info)
    setText(self.tipLabel,customData.tip)

    local labelConSize = self.infoLabel:getContentSize()

    local mainBG_Width = 690
    local mainBG_Height = 308
    local offsetPosY = 0
    if customData.isLeft then
        self.infoLabel:setHorizontalAlignment( kCCTextAlignmentLeft )
    end
    if customData.isAutoSize then
        offsetPosY = labelConSize.height - 80
    end
    
    mainBG_Height = mainBG_Height + offsetPosY
    self.scale9Bg:setContentSize(CCSizeMake(mainBG_Width,mainBG_Height))

    local child_Offset = {
        "leftHotArea",
        "rightHotArea",
        "line_spliceBtn",
        "line_hoverBtn",
        "leftBtnLabel",
        "rightBtnLabel",
        "centerBtnLabel",
    }

    for i,v in ipairs(child_Offset) do
        local offsetChidNode = self.ui:getChildByName( v )
        if offsetChidNode then
            offsetChidNode:setPositionY( offsetChidNode:getPositionY() - offsetPosY   )
        end
    end

    self.line_spliceBtn:setVisible(customData.isConfirm)
    if customData.isConfirm then
        setText(self.leftBtnLabel,customData.strCancel or "取消")
        setText(self.rightBtnLabel,customData.strOK or "确认")
        setText(self.centerBtnLabel,nil)
    else
        setText(self.centerBtnLabel,customData.strOK or "确认")
        setText(self.leftBtnLabel,nil)
        setText(self.rightBtnLabel,nil)
    end

    local function onTappedLeft(event)
        print("Alert:onTappedLeft()")
        self:onClose()
        if customData.isConfirm then
            local _ = customData.cancelCallback and xpcall(customData.cancelCallback, __G__TRACKBACK__)
        else
            local _ = customData.okCallback and xpcall(customData.okCallback, __G__TRACKBACK__)
        end
    end

    local function onTappedRight(event)
        print("Alert:onTappedRight()")
        self:onClose()
        local _ = customData.okCallback and xpcall(customData.okCallback, __G__TRACKBACK__)
    end

    local function onClose(event)
        print("Alert:onClose()")
        self:onClose()
    end

    if self.test then
        self.test:setTouchEnabled(true,0, false)
        self.test:setButtonMode(true)
        self.test:addEventListener(DisplayEvents.kTouchTap, onClose)
        -- self.test:setOpacity(0)
    end

    self.leftHotArea:setTouchEnabled(true,0, false)
    self.leftHotArea:setButtonMode(true)
    self.leftHotArea:addEventListener(DisplayEvents.kTouchTap, onTappedLeft)

    self.rightHotArea:setTouchEnabled(true,0, false)
    self.rightHotArea:setButtonMode(true)
    self.rightHotArea:addEventListener(DisplayEvents.kTouchTap, onTappedRight)
end

function Alert:onClose()
    print("Alert:onClose()")
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self,true)
    
    local _ = self.customData.closeCallback and xpcall(self.customData.closeCallback, __G__TRACKBACK__)
end

function Alert:closeBackKeyTap()
    self.allowBackKeyTap = false
end

function Alert:popout()
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
   -- if _G.nextLevelModel == true then
        -- PopoutQueue:sharedInstance():push(self, false)
    -- else
        PopoutManager:sharedInstance():add(self, false)
    -- end
    -- self:popoutShowTransition()

    local container = self:getParent() and self:getParent():getParent()
    local _ = container and container.setZOrder and container:setZOrder(99)
end

function Alert:onKeyBackClicked(...)
    print("Alert:onKeyBackClicked()")

    if self.allowBackKeyTap then
        self:onClose()
    end
end

return Alert

