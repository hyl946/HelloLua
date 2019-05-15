local PlistManager = class()

function PlistManager:ctor( ... )
    self.loaded = {}
end

function PlistManager:load( pathname )
    if self.loaded[pathname] then
        return
    end
    FrameLoader:loadImageWithPlist(pathname)
    self.loaded[pathname] = true
end

function PlistManager:unloadAll()
    FrameLoader:unloadImageWithPlists(self.loaded)
    self.loaded = {}
end



local PAGE_NUM = 3
local NEXT_PAGE_TIME = 5

IosAliCartoonPanel = class(BasePanel)
function IosAliCartoonPanel:create(cartoonCloseCallback)
    local instance = IosAliCartoonPanel.new()
    instance:loadRequiredResource('ui/ios_ali_pay_guide.json')
    instance:init(cartoonCloseCallback)
    return instance
end

function IosAliCartoonPanel:init(cartoonCloseCallback)


    self.plistManager = PlistManager.new()

    local vs = Director:sharedDirector():getVisibleSize()
    local ui = self:buildInterfaceGroup('ios_ali_pay_guide_new/interface/main')
    self.targetScale = vs.height / ui:getGroupBounds().size.height * 0.9
    ui:setScale(self.targetScale)

    BasePanel.init(self, ui)
    self.pager = ui:getChildByName('pager')
    self.selected = self.pager:getChildByName('selected')

    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.blue)
    self.btn:addEventListener(DisplayEvents.kTouchTap,function( ... )
        self:onBtnTapped()
    end)

    self.closeBtn = ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
        self:onCloseBtnTapped()
    end)

    self.curSchema = 1

    local btnSwitcher = ui:getChildByName('btnSwitcher')


    for i = 1, PAGE_NUM do
        local btn = btnSwitcher:getChildByName(tostring(i))
        btn:setTouchEnabled(true)

        local clickIndex = i

        btn:ad(DisplayEvents.kTouchTap, function ( ... )
            if self.curSchema ~= clickIndex then
                self:initSchema(clickIndex)
                self.curSchema = clickIndex
            end
        end)
    end

    self.btnSwitcher = btnSwitcher


    self.title = ui:getChildByName('title')

    self.maxPage = 4
    for i=1, self.maxPage do 
        self['dot'..i] = self.pager:getChildByName('dot'..i)
    end
    
    self.pageCon = self.ui:getChildByName('pageCon')
    self:initSchema(1)

    self.cartoonCloseCallback = cartoonCloseCallback

    self.cdSeconds = NEXT_PAGE_TIME
    self.curIndex = 1
    self.playTime = 0

    local function onTick()
        if self.isDisposed then return end
        self.playTime = self.playTime + 1
        if self.isPaused then return false end
        self.cdSeconds = self.cdSeconds - 1
        if self.cdSeconds <= 0 then
            self:nextPage()
        end
    end
    self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
end

function IosAliCartoonPanel:onMaskTapped()
end

function IosAliCartoonPanel:onCloseBtnTapped()
    if not CCUserDefault:sharedUserDefault():getBoolForKey("ios.pay.guide.cartoon.played", false)
    and self.playTime < 10 then
        CommonTip:showTip('先看看小浣熊为您准备的教程吧', 'positive')
        return
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("ios.pay.guide.cartoon.played", true)
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
    if self.cartoonCloseCallback then
        self.cartoonCloseCallback()
    end
end

function IosAliCartoonPanel:popout()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
    self.allowBackKeyTap = true

    self:initPlay()
end

function IosAliCartoonPanel:initPlay()
    self.curIndex = 1
    self:gotoPage(1)
    self.cdSeconds = NEXT_PAGE_TIME
    self.isPaused = false
    self:updateButton()
end

-- 重新初始化内容页
function IosAliCartoonPanel:initSchema(schemaIdx)

    if self.isDisposed then return end

    local payNameMap = {
        [1] = 'wechat',
        [2] = 'alipay',
        [3] = 'unionpay'
    }

    local function getPlistPathName(index)
        return string.format('ui/%s_ios_pay_guide.plist', payNameMap[index])
    end

    local function getSpriteFrameName(index, pageNum)
        return string.format('ios_pay_guide_res_%s_20170927/%d.jpg', payNameMap[index], pageNum)
    end

    self.plistManager:load(getPlistPathName(schemaIdx))

    self.curSchema = schemaIdx
    for i=1, PAGE_NUM do 
        local flag = self.btnSwitcher:getChildByName(tostring(i)..'_h')
        flag:setVisible(i == self.curSchema)

        local titleLabel = self.title:getChildByName(tostring(i))
        titleLabel:setVisible(i == self.curSchema)
    end

    self['pageCon'] = self.ui:getChildByName('pageCon')
    self['pageCon']:removeChildren(true)

    for i=1, 4 do 
        local pageUrl = getSpriteFrameName(schemaIdx, i)
        self['page'..i] = Sprite:createWithSpriteFrameName(pageUrl)
	    self['page'..i]:setAnchorPoint(ccp(0, 0))
        self['page'..i]:setPosition(ccp(0, 90))
	    self['pageCon']:addChild(self['page'..i])
    end

    self.touchMask = Layer:create()
    local function onTouchTap(event)
        self:onMaskTapped()
    end
    local function onTouchBegin(event)
        self.beginX = event.globalPosition.x
        self.beginY = event.globalPosition.y
    end
    local function onTouchMove(event)
    end
    local function onTouchEnd(event)
        local distanceX = event.globalPosition.x - self.beginX
        local distanceY = event.globalPosition.y - self.beginY
        if math.abs(distanceX) > math.abs(distanceY) then
            if distanceX > 10 then
                self:prevPage()
            elseif distanceX < -10 then
                self:nextPage()
            end
        end
    end
    self.touchMask.hitTestPoint = function (_self, worldPosition, useGroupTest)
        return true
    end
    self.touchMask:ad(DisplayEvents.kTouchTap, onTouchTap)
    self.touchMask:ad(DisplayEvents.kTouchBegin, onTouchBegin)
    self.touchMask:ad(DisplayEvents.kTouchMove, onTouchMove)
    self.touchMask:ad(DisplayEvents.kTouchEnd, onTouchEnd)
    self.touchMask:setTouchEnabled(true, 0, true)
    self.pageCon:addChild(self.touchMask)

    self:initPlay()
end

function IosAliCartoonPanel:onBtnTapped()
    if self.curIndex < self.maxPage then
        if self.isPaused then
            self:resume()
            self:updateButton()
        else
            self:pause()
            self:updateButton()
        end
    else
        self:replay()
    end
end

function IosAliCartoonPanel:updateButton()
    if self.isDisposed then return end
    
    if self.curIndex == self.maxPage then
        self.btn:setString('再看一遍')
    else
        if self.isPaused then
            self.btn:setString('开始')
        else
            self.btn:setString('暂停')
        end
    end
end

function IosAliCartoonPanel:pause()
    self.isPaused = true
end

function IosAliCartoonPanel:resume()
    self.isPaused = false
end

function IosAliCartoonPanel:replay()
    self.curIndex = 1
    self:gotoPage(1)
    self.isPaused = false
    self.cdSeconds = NEXT_PAGE_TIME
    self:updateButton()
end

function IosAliCartoonPanel:gotoPage(index)

    if self.isDisposed then return end


    for i=1, self.maxPage do 
        self['page'..i]:setVisible(i == index)
    end
    self.selected:setPositionX(self['dot'..index]:getPositionX())
end

function IosAliCartoonPanel:nextPage()

    if self.curIndex < self.maxPage then
        self.curIndex = self.curIndex + 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function IosAliCartoonPanel:prevPage()

    if self.curIndex > 1 then
        self.curIndex = self.curIndex - 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function IosAliCartoonPanel:dispose()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    BasePanel.dispose(self)

    self.plistManager:unloadAll()
    self.plistManager = nil
end


IosAliGuideUtils = {}

function IosAliGuideUtils:isIOSAliGuideEnable()
    return MaintenanceManager:getInstance():isEnabled("iOSAliGuideEnable", false)
end

function IosAliGuideUtils:shouldShowIOSAliGuide()
    if not __IOS then
        return false
    end

    if not IosAliGuideUtils:isIOSAliGuideEnable() then
        return false
    end

    local systemVersion = AppController:getSystemVersion() or 7
    if systemVersion <= 10.29999 then
        return false
    end

    return true
end