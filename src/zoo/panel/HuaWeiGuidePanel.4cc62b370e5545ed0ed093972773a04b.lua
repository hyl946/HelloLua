local PlistManagerHuaWei = class()

function PlistManagerHuaWei:ctor( ... )
    self.loaded = {}
end

function PlistManagerHuaWei:load( pathname )
    if self.loaded[pathname] then
        return
    end
    FrameLoader:loadImageWithPlist(pathname)
    self.loaded[pathname] = true
end

function PlistManagerHuaWei:unloadAll()
    FrameLoader:unloadImageWithPlists(self.loaded)
    self.loaded = {}
end



local PAGE_NUM = 3
local NEXT_PAGE_TIME = 6

HuaWeiGuidePanel = class( BasePanel )
function HuaWeiGuidePanel:create(cartoonCloseCallback)
    local instance = HuaWeiGuidePanel.new()
    instance:loadRequiredResource('ui/huawei_ali_pay_guide.json')
    instance:init( cartoonCloseCallback )
    return instance
end

function HuaWeiGuidePanel:init(cartoonCloseCallback)

    self.PlistManagerHuaWei = PlistManagerHuaWei.new()

    local vs = Director:sharedDirector():getVisibleSize()
    local ui = self:buildInterfaceGroup('huawei_ali_pay_guide_new/interface/main')
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


    self.title = ui:getChildByName('title')

    self.maxPage = 6
    for i=1, self.maxPage do 
        self['dot'..i] = self.pager:getChildByName('dot'..i)
    end
    
    self.pageConhuawei = self.ui:getChildByName('pageConhuawei')
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

function HuaWeiGuidePanel:onMaskTapped()
end

function HuaWeiGuidePanel:onCloseBtnTapped()
    if not CCUserDefault:sharedUserDefault():getBoolForKey("huawei.pay.guide.cartoon.played", false) and self.playTime < 10 then
        CommonTip:showTip('先看看小浣熊为您准备的教程吧', 'positive')
        return
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("huawei.pay.guide.cartoon.played", true)
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
    if self.cartoonCloseCallback then
        self.cartoonCloseCallback()
    end
end

function HuaWeiGuidePanel:popout()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
    self.allowBackKeyTap = true

    self:initPlay()
end

function HuaWeiGuidePanel:initPlay()
    self.curIndex = 1
    self:gotoPage(1)
    self.cdSeconds = NEXT_PAGE_TIME
    self.isPaused = false
    self:updateButton()
end

-- 重新初始化内容页
function HuaWeiGuidePanel:initSchema(schemaIdx)

    if self.isDisposed then return end

    -- local payNameMap = {
    --     [1] = 'wechat',
    --     [2] = 'alipay',
    --     [3] = 'unionpay'
    -- }

    local function getPlistPathName(index)
        return string.format('ui/huawei_ali_pay_guide.plist' )
    end

    local function getSpriteFrameName(index, pageNum)
        return string.format('huawei_ali_pay_guide_new/page_%d0000', pageNum)
    end

    self.PlistManagerHuaWei:load(getPlistPathName(schemaIdx))

    self.curSchema = schemaIdx
    -- for i=1, PAGE_NUM do 
    --     local flag = self.btnSwitcher:getChildByName(tostring(i)..'_h')
    --     flag:setVisible(i == self.curSchema)

    --     local titleLabel = self.title:getChildByName(tostring(i))
    --     titleLabel:setVisible(i == self.curSchema)
    -- end

    self['pageConhuawei'] = self.ui:getChildByName('pageConhuawei')
    self['pageConhuawei']:removeChildren(true)

    for i=1, 6 do 
        local pageUrl = getSpriteFrameName(schemaIdx, i)
        self['page'..i] = Sprite:createWithSpriteFrameName(pageUrl)
	    self['page'..i]:setAnchorPoint(ccp(0, 1))
        self['page'..i]:setPosition(ccp(0, 144/2))
	    self['pageConhuawei']:addChild(self['page'..i])
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
    self.pageConhuawei:addChild(self.touchMask)

    self:initPlay()
end

function HuaWeiGuidePanel:onBtnTapped()
    if self.curIndex < self.maxPage then
        if self.isPaused then
            self:resume()
            self:updateButton()
        else
            self:pause()
            self:updateButton()
        end
    else
        DcUtil:UserTrack({ category='huaweipayguide', sub_category='review_guide' })
        self:replay()
    end
end

function HuaWeiGuidePanel:updateButton()
    if self.isDisposed then return end
    
    if self.curIndex == self.maxPage then
        self.btn:setString('再看一遍')
        DcUtil:UserTrack({ category='huaweipayguide', sub_category='view_all' })
    else
        if self.isPaused then
            self.btn:setString('开始')
        else
            self.btn:setString('暂停')
        end
    end
end

function HuaWeiGuidePanel:pause()
    DcUtil:UserTrack({ category='huaweipayguide', sub_category='pause_guide' ,t1 = self.curIndex  })
    self.isPaused = true
end

function HuaWeiGuidePanel:resume()
    self.isPaused = false
end

function HuaWeiGuidePanel:replay()
    self.curIndex = 1
    self:gotoPage(1)
    self.isPaused = false
    self.cdSeconds = NEXT_PAGE_TIME
    self:updateButton()
end

function HuaWeiGuidePanel:gotoPage(index)

    if self.isDisposed then return end


    for i=1, self.maxPage do 
        self['page'..i]:setVisible(i == index)
    end
    self.selected:setPositionX(self['dot'..index]:getPositionX())
end

function HuaWeiGuidePanel:nextPage()

    if self.curIndex < self.maxPage then
        self.curIndex = self.curIndex + 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function HuaWeiGuidePanel:prevPage()

    if self.curIndex > 1 then
        self.curIndex = self.curIndex - 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function HuaWeiGuidePanel:dispose()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    BasePanel.dispose(self)

    self.PlistManagerHuaWei:unloadAll()
    self.PlistManagerHuaWei = nil
end

