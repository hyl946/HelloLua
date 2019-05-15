FreeFCashPanel = class(BasePanel)


local instance = nil
local function getPanelInstance()
    if not instance or instance.isDisposed then
        instance = FreeFCashPanel.new()
        instance:loadRequiredResource(PanelConfigFiles.free_fcash_panel)
        instance:init()
    end
    return instance
end

local function shouldShow()
	if __WP8 then return false end
    if not __IOS then return false end
    local domobEnabled = MaintenanceManager:getInstance():isEnabled("FreeCash_1")
    local limeiEnabled = MaintenanceManager:getInstance():isEnabled("FreeCash_2")
    return domobEnabled or limeiEnabled
    -- return true -- test
end

function FreeFCashPanel:showWithOwnerCheck(ownerRef)
    if not shouldShow() then return end

    local instance = getPanelInstance()
    -- if this is owned by another different panel
    if instance.ownerRef ~= nil and instance.ownerRef ~= ownerRef then return end

    if instance and not instance.isPoppedOut then
        if _G.isLocalDevelopMode then printx(0, 'pop out') end
        instance.isPoppedOut = true
        instance.ownerRef = ownerRef
        local vs = Director:sharedDirector():getVisibleSize()
        PopoutManager:sharedInstance():add(instance, false, true)
        instance:setPositionForPopoutManager()
        instance:setPositionY(-vs.height + 200)
    end
end

function FreeFCashPanel:hideWithOwnerCheck(ownerRef)
    if not shouldShow() then return end
    
    if _G.isLocalDevelopMode then printx(0, 'FreeFCashPanel:hideWithOwnerCheck') end
    local instance = getPanelInstance()

    -- the ownerRef is not the actual owner
    if instance.ownerRef ~= ownerRef then return end

    if instance and instance.isPoppedOut then
        if _G.isLocalDevelopMode then printx(0, 'hide') end
        instance.isPoppedOut = false
        instance.ownerRef = nil
        PopoutManager:sharedInstance():remove(instance, true)
        instance = nil
    end
end

function FreeFCashPanel:init()
    local ui = self:buildInterfaceGroup('FreeFCashPanel')
    BasePanel.init(self, ui)
    self.button = GroupButtonBase:create(ui:getChildByName('button'))
    self.button:setColorMode(kGroupButtonColorMode.green)
    self.button:ad(DisplayEvents.kTouchTap, function() self:onButtonTapped() end)
    self.button:setString(Localization:getInstance():getText('buy.gold.panel.btn.free.text'))
    self.txt = ui:getChildByName('txt')
    self.txt:setString(Localization:getInstance():getText('你也可以免费获取风车币哟~'))
    self.options = {}
    if MaintenanceManager:getInstance():isEnabled("FreeCash_1") then
        table.insert(self.options, 'Domob')
    end
    if MaintenanceManager:getInstance():isEnabled("FreeCash_2") then
        table.insert(self.options, 'Limei')
    end
end
    
function FreeFCashPanel:onButtonTapped()
    local choice = nil
    if #self.options == 1 then
        choice = self.options[1]
    elseif #self.options == 2 then
        local selector = math.random(1, 10) % 2 -- selector = 0 or 1
        choice = self.options[selector + 1]
    else 
        return -- no options
    end
    local advertiseSDK = AdvertiseSDK.new()
    if choice == 'Domob' then
        -- if _G.isLocalDevelopMode then printx(0, 'Domob selected') end
        advertiseSDK:presentDomobListOfferWall()
    elseif choice == 'Limei' then
        -- if _G.isLocalDevelopMode then printx(0, 'Limei selected') end
        advertiseSDK:presentLimeiListOfferWall()
    end
end
