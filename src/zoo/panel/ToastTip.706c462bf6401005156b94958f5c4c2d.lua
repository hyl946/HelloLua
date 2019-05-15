--安卓Toast样式的纯白泡泡提示

-- ToastTip:create("hello world")

ToastTip = class(BasePanel)

function ToastTip:create(customData)
    printx(0,"ToastTip:create()"..table.tostring(customData))
    if type(customData)=="string" then
        customData={msg = customData}
    end
	local a = ToastTip.new()
	a:init(customData)
    a:popout()
	return a
end

function ToastTip:init( customData )
    self.customData = customData

    self:loadRequiredResource(PanelConfigFiles.common_ui)
    self.ui = self:buildInterfaceGroup("ui_tip/ui_toast_tip")
	BasePanel.init(self, self.ui)

    self.childs = {
        "scale9Bg",
        "label",
    }
    for i,v in ipairs(self.childs) do
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

    setText(self.label,tostring(customData.msg))
    local n = utfstrlen(customData.msg)
    local tw = n*30+70
    tw = math.min(tw,500)
    self.width = tw
    self.scale9Bg:setContentSize(CCSizeMake(tw,61))
    self.scale9Bg:setPosition(ccp(-7,1))
    self.scale9Bg:setAnchorPoint(ccp(0.5,0.5))
    self.label:setPosition(ccp(0,0))
    self.label:setAnchorPoint(ccp(0.5,0.5))

    if utfstrlen(tostring(customData.msg))>16 then
        self.label:setDimensions(CCSizeMake(350,70))
    end

    -- printx(0,"ToastTip:init()"..table.tostring(customData).."-"..n .. "-"..(60+n*20))
end

function ToastTip:onClose()
    -- print("ToastTip:onClose()")
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self,true)
    
    -- local _ = self.customData.closeCallback and xpcall(self.customData.closeCallback, __G__TRACKBACK__)
end

function ToastTip:popout()
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()

    local posAdd = _G.__EDGE_INSETS.top
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local tx,ty = vSize.width*0.5 ,-(vSize.height - self:getVCenterInScreenY()*1.25 + posAdd)
    tx = self.customData.x or tx
    ty = self.customData.y or ty
    self:setPosition(ccp(tx, ty))

    PopoutManager:sharedInstance():add(self, false,true)

    local t0,t1,t2 = 0.4,2.5,0.4
    local list = self.customData and self.customData.times
    if list and #list>=3 then
        t0,t1,t2=list[1],list[2],list[3]
    end

    local rAry = CCArray:create()
    rAry:addObject(CCMoveTo:create(t0,ccp(tx,ty+60)))
    rAry:addObject(CCDelayTime:create(t1))
    rAry:addObject(CCMoveTo:create(t2,ccp(tx,ty+120)))
    rAry:addObject(CCCallFunc:create(handler(self,self.onClose)))
    self:runAction(CCSequence:create(rAry))

    for i,v in ipairs(self.childs) do
        local child = self[v]
        local _ = child.setCascadeOpacityEnabled and child:setCascadeOpacityEnabled(true)
        local _ = child.setOpacity and child:setOpacity(0)
        local r0 = CCArray:create()
        r0:addObject(CCFadeIn:create(t0))
        r0:addObject(CCDelayTime:create(t1))
        r0:addObject(CCFadeOut:create(t2))
        child:runAction(CCSequence:create(r0))
    end
end

function ToastTip:onKeyBackClicked(...)
    if self.allowBackKeyTap then
        self:onClose()
    end
end

return ToastTip

