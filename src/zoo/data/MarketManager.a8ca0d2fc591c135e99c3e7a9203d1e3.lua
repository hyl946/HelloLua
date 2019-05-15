require "zoo.panelBusLogic.BuyGoldLogic"

MarketManager = class()

local instance = nil

-- TABID_HAPPY_COINS = 100;   --风车币

TabsIdConst = table.const{
    
    kHappyeCoin = 100,   --风车币
    kPackage = 0,         --礼包
    KPropSingle = 1,     --游戏内道具
    kGiftPack = 102, --新手礼包
}

-- goods 表 tag 为 1的项 插入 KPropSingle 页
-- shouldUseNewPackageGoods==true,  则根据abtest，goods 表 tag 为 5的项 也可能插入KPropSingle 页 , 要么 1 插进去 , 要么 5 插进去, 他俩 abtest

-- goods 表 tag 为 0的项 插入 kPackage 页
-- kHappyeCoin 页 和 kVip 页 规则不一样，不是根据goods表 tag插入的

function MarketManager:sharedInstance()
    if not instance then
        instance = MarketManager.new()
    end
    return instance
end

function MarketManager:ctor()
    self.observers = {}
    self.gotRemoteList = false
end

function MarketManager:loadConfig(tabConfig)
    tabConfig = tabConfig or TabsIdConst
    local goods = MetaManager:getInstance().goods
    
    local distinctTags = {}
    -- first iteration: find distinct distinctTags
    for _, goodsItem in pairs(goods) do 
        if goodsItem.tag then
            if type(goodsItem.tag) == 'number' then
                distinctTags[goodsItem.tag] = goodsItem.tag
            else
                for _, tag in pairs(goodsItem.tag) do
                    distinctTags[tag] = tag
                end
            end
        end
    end

    local function filterTabTag( tag )            ---判断是否是可以显示的tagID
        -- body
        for k,v in pairs(tabConfig) do
            if v == tag then
                return true
            end
        end
        return false
    end

    --  build config structure
    local tabConfig = {}
    for _, tagValue in pairs(distinctTags) do
        -- for facebook ver, ignore tag 0,1,2
        if (not __IOS_FB) or (__IOS_FB and tagValue >= 3) then 
            if filterTabTag(tagValue) then
                local tmp = {tabId = tagValue, pageIndex = 0, key = 'market.tabs.'..tagValue, goodsIds = {}}
                table.insert(tabConfig, tmp)
            end
        end
    end

    --insert the tag for happyelements coins.
    if filterTabTag(TabsIdConst.kHappyeCoin) then
        local happycoin_ids = {};
        local coins_tag = {tabId = TabsIdConst.kHappyeCoin, pageIndex = 0, key = "market.tabs."..TabsIdConst.kHappyeCoin, goodsIds = happycoin_ids, isTimeLimited = true};
        coins_tag.isTimeLimited = MaintenanceManager:getInstance():isEnabled("showGoldLimitIcon");
        table.insert(tabConfig, coins_tag);
    end

    if GiftPack:isEnabledNewerPackOne() and filterTabTag(TabsIdConst.kGiftPack) then
        local coins_tag = {tabId = TabsIdConst.kGiftPack, pageIndex = 0, key = "market.tabs."..TabsIdConst.kGiftPack, goodsIds = {}}
        table.insert(tabConfig, coins_tag)
    end

    -- sort
    table.sort(tabConfig, function(tab1, tab2) return tab1.tabId < tab2.tabId end)

    -- set page index
    for i=1, #tabConfig do 
        tabConfig[i].pageIndex = i
    end

    -- set goodsId to according tabs
    for _, goodsItem in pairs(goods) do
        if goodsItem.tag then
            local targetTags = {}
            if type(goodsItem.tag) == 'number' then
                table.insert(targetTags, goodsItem.tag)
            else
                targetTags = goodsItem.tag
            end
            for _, targetTag in pairs(targetTags) do
                for _, tabConfigItem in pairs(tabConfig) do 
                    if self:shouldUseNewPackageGoods() and tabConfigItem.tabId == TabsIdConst.kPackage then
                        if targetTag == 5 then
                            table.insert(tabConfigItem.goodsIds, goodsItem.id)
                        end
                    else
                        if tabConfigItem.tabId == targetTag then
                            table.insert(tabConfigItem.goodsIds, goodsItem.id)
                        end
                    end
                end
            end
        end
    end

    -- when 31 is available, hide 17
    local showGoods17 = false
    local goods31 = self:getGoodsById(31)
    if goods31.buyLimit <= 0 then
        showGoods17 = true
    end
    for k1, tabConfigItem in pairs(tabConfig) do 
        for k2, goodsId in pairs(tabConfigItem.goodsIds) do
            if showGoods17 then
                if goodsId == 31 then
                    table.remove(tabConfigItem.goodsIds, k2)
                end
            else 
                if goodsId == 17 then
                    table.remove(tabConfigItem.goodsIds, k2)
                end
            end
        end
    end


    -- sort goodsIds
    local function less(goodsId1, goodsId2)
        local goods1 =  MetaManager:getInstance():getGoodMeta(goodsId1)
        local goods2 =  MetaManager:getInstance():getGoodMeta(goodsId2)
        local sort1 = goods1 and tonumber(goods1.sort) or 0;
        local sort2 = goods2 and tonumber(goods2.sort) or 0;
        if __IOS_FB then
            return sort1 > sort2 -- facebook sorting is reversed
        else
            return sort1 < sort2
        end
    end
    for _, tabItem in pairs(tabConfig) do 
        table.sort(tabItem.goodsIds, less)
    end

    if self:shouldUseNewLogic() then
        
        local newTabConfig

        if filterTabTag(TabsIdConst.KPropSingle) then

            local item1 = {
                tabId = TabsIdConst.KPropSingle, 
                pageIndex = 1,
                key = "market.tabs.1",
                goodsIds = {},
            }

            for k, v in pairs(tabConfig) do
                if v.tabId == TabsIdConst.kPackage or v.tabId == TabsIdConst.KPropSingle then
                    for x, y in pairs(v.goodsIds) do
                        table.insert(item1.goodsIds, y)
                    end
                end
            end

            newTabConfig = {item1}
        else
            newTabConfig = {}
        end

        for _, v in pairs(tabConfig) do
            if v.tabId ~= TabsIdConst.kPackage and v.tabId ~= TabsIdConst.KPropSingle then
                table.insert(newTabConfig, v)
            end
        end

        table.sort(newTabConfig, function(tab1, tab2) return tab1.tabId < tab2.tabId end)

        -- set page index
        for i=1, #newTabConfig do 
            newTabConfig[i].pageIndex = i
        end

        self.tabConfig = {tabs = newTabConfig}
    else
        self.tabConfig = {tabs = tabConfig}
    end

    return self.tabConfig;
end

function MarketManager:getCoinsTab()
    for i,v in ipairs(self.tabConfig.tabs) do
        if v.tabId == TabsIdConst.kHappyeCoin then
            return v;
        end
    end

    return nil;
end

local isRequestingProductInfo = false;
function MarketManager:getGoldProductInfo(uicallback)
    self.buyLogic = BuyGoldLogic:create()
    self.productMeta = self.buyLogic:getMeta()
    local localGoldInfo = {}
    local function onAndroidGetLocalListFinish(iapConfig)
        localGoldInfo = {}
        local i = 0
        while true do
            if iapConfig[tostring(i)] then
                table.insert(localGoldInfo, iapConfig[tostring(i)])
                i = i + 1
            else break end
        end
    end
    local function androidGetGoldListFinish(data)
        if type(data) ~= "string" or string.len(data) <= 0 then
            self:onGetAndroidGoldListFinish(localGoldInfo)
            self.gotRemoteList = true
            if uicallback then uicallback(); end
            isRequestingProductInfo = false;
            return
        end
        local retXml = xml.eval(data)
        local node = xml.find(retXml, "product_android")
        if not node then
            self:onGetAndroidGoldListFinish(localGoldInfo)
        else
            local tmp, final = {}, {}
            for k, v in ipairs(node) do
                v.sort = tonumber(v.sort)
                v.newSort = tonumber(v.newSort)
                v.id = tonumber(v.id)
                v.cash = tonumber(v.cash)
                v.rmb = tonumber(v.rmb)
                v.extraCash = tonumber(v.extraCash)
                v.discount = tonumber(v.discount)
                v.iapPrice = v.rmb and v.rmb / 100
                if not v.tag or type(v.tag) ~= "string" then 
                    v.tag = "ingame" 
                end
                if not tmp[v.tag] then
                    tmp[v.tag] = {}
                    table.insert(tmp[v.tag], v)
                    final[v.tag] = {name = v.tag}
                else 
                    table.insert(tmp[v.tag], v) 
                end
            end
            for k, v in pairs(final) do
                for i, j in ipairs(tmp[v.name]) do 
                    table.insert(v, j)
                    --1.65版本内某次动更后改为以后端同步product_android为准
                    if not MetaManager:getInstance():getProductAndroidMeta(j.id) then 
                        MetaManager:getInstance():updateProductAndroidByServer(j)
                    end
                end
            end
            self:onGetAndroidGoldListFinish(localGoldInfo, final)
        end
        self.gotRemoteList = true
        if uicallback then uicallback(); end
        isRequestingProductInfo = false;
    end
    local function androidGetGoldListFail(evt)
        local info = self.buyLogic:getMeta()
        local fakeRemote = {}
        for k, v in pairs(info) do
            if v.id ~= 18 then
                if not v.tag or type(v.tag) ~= "string" then v.tag = "ingame" end
                if not fakeRemote[v.tag] then
                    fakeRemote[v.tag] = {name = v.tag}
                end
                table.insert(fakeRemote[v.tag], v)
            end
        end
        self:onGetAndroidGoldListFinish(localGoldInfo, fakeRemote)
        if uicallback then uicallback(); end
        isRequestingProductInfo = false;
    end
    local function iosGetGoldListFinish(iapConfig)
        self:onGetIOSGoldListFinish(iapConfig)
        self.gotRemoteList = true
        if uicallback then uicallback(); end
        isRequestingProductInfo = false;
    end
    local function getGoldListFail(evt)
        CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.get.list.fail"), "negative")
        isRequestingProductInfo = false;
    end
    local function getGoldListTimeout()
        CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.get.list.timeout"), "negative")
        isRequestingProductInfo = false;
    end
    local function getGoldListCanceled()
        isRequestingProductInfo = false;
    end

    if not isRequestingProductInfo then        
        isRequestingProductInfo = true
        if __ANDROID then
            -- local list
            self.buyLogic:getProductInfo(onAndroidGetLocalListFinish, getGoldListFail, getGoldListTimeout, getGoldListCanceled)
            -- remote list
            if PaymentBase:checkThirdPartyPaymentEabled() then
                local animation, listening = nil, true
                local function onCloseButtonTap()
                    if animation then
                        listening = false
                        animation:removeFromParentAndCleanup(true)
                        androidGetGoldListFail()
                        animation = nil
                    end
                end
                local scene = Director:sharedDirector():getRunningScene()
                animation = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap)
                local function onCallback(response)
                    if not listening then return end
                    if animation then
                        animation:removeFromParentAndCleanup(true)
                        animation = nil
                    end
                    if response.httpCode ~= 200 then androidGetGoldListFail()
                    else androidGetGoldListFinish(response.body) end
                end
                local url = NetworkConfig.maintenanceURL
                local uid = UserManager.getInstance().uid
                local params = string.format("?name=product_android&uid=%s&_v=%s", uid, _G.bundleVersion)
                url = url .. params
                local request = HttpRequest:createGet(url)
                local connection_timeout = 2

                if __WP8 then 
                    connection_timeout = 5
                end

                request:setConnectionTimeoutMs(connection_timeout * 1000)
                request:setTimeoutMs(30 * 1000)
                HttpClient:getInstance():sendRequest(onCallback, request)
            else
                androidGetGoldListFinish()
            end
        else
            self.buyLogic:getProductInfo(iosGetGoldListFinish, getGoldListFail, getGoldListTimeout, getGoldListCanceled)
        end
    end
    
end

function MarketManager:onGetIOSGoldListFinish(iapConfig)
    self.productItems = {};
    local function getMetaInfo(productId)
        for i,v in ipairs(self.productMeta) do
            if v.productId == productId then
                return v;
            end
        end

        return nil;
    end

    for k,v in pairs(iapConfig) do
        local item = getMetaInfo(v.productIdentifier);
        if item then
            item.iapPrice = v.iapPrice;
            item.productIdentifier = v.productIdentifier;
            item.priceLocale = v.priceLocale;
            table.insert(self.productItems, item);
        end
    end

    table.sort(self.productItems, function(a, b) return tonumber(a.cash) < tonumber(b.cash) end)

    local coinsTab = self:getCoinsTab();
    for i,v in ipairs(self.productItems) do table.insert(coinsTab.goodsIds, v) end
end

function MarketManager:onGetAndroidGoldListFinish(localConfig, remoteConfig)
    self.productItems = {}
    local network = true
    if type(remoteConfig) ~= "table" then
        remoteConfig =  {}
        local payments = PaymentBase:getPayments()
        for payType,payment in pairs(payments) do
            if payment:isEnabled() and payment.productName ~= "ingame" then
                table.insert(remoteConfig, {name = payment.productName})
            end
        end
        table.insert(remoteConfig, {name = "ingame"})
        network = false
    end

    local count = 0
    local ingame = nil
    for k, config in pairs(remoteConfig) do
        if config.name == "ingame" then
            while #config > 0 do table.remove(config, 1) end
            for i, j in ipairs(localConfig) do
                if type(j.tag) ~= "string" or j.tag == "ingame" then table.insert(config, j) end
            end
            ingame = config
        end

        local payment = PaymentBase:getPayment(config.name)
        config.enabled = payment:isWindMillEnabled()

        if config.enabled then
            count = count + 1

            for i, j in ipairs(config) do 
                j.payType = payment.type
            end

            config.payType = payment.type

            table.sort(config, function(a, b) return tonumber(a.cash) < tonumber(b.cash) end)
            table.insert(self.productItems, config)
        end
    end

    --无法支付也给显示个普通栏 虽然支付会失败
    if count <= 0 then
        ingame.enabled = true
        local payment = PaymentBase:getPayment(ingame.name)
        for i, j in ipairs(ingame) do 
            j.payType = payment.type
        end

        ingame.payType = payment.type

        table.sort(ingame, function(a, b) return tonumber(a.cash) < tonumber(b.cash) end)
        table.insert(self.productItems, ingame)
    end

    local coinsTab = self:getCoinsTab();
    for i,v in ipairs(self.productItems) do table.insert(coinsTab.goodsIds, v) end
    self:updateLocalPaymentInfo()
end

function MarketManager:updateLocalPaymentInfo()
    -- meta
    local meta = MetaManager:getInstance().product_android
    local function getProductInfo(id)
        for k, v in ipairs(meta) do if v.id == id then return v end end
        return nil
    end
    for k, v in ipairs(self.productItems) do
        if v.name ~= "ingame" then
            for i, j in ipairs(v) do
                local rec = getProductInfo(j.id)
                if rec then
                    rec.id, rec.cash, rec.discount, rec.extraCash = j.id, j.cash, j.discount, j.extraCash
                    rec.rmb, rec.sort, rec.tag, rec.productId = j.rmb, j.sort, j.tag, j.id
                else
                    table.insert(meta, {id = j.id, cash = j.cash, discount = j.discount, extraCash = j.extraCash,
                        rmb = j.rmb, sort = j.sort, tag = v.name, productId = j.id})
                end
            end
        end
    end

    -- paycode
    local list = MetaManager:getInstance().goodsPayCode
    for i = 1, #meta do
        local paycode = MetaManager:getInstance():getGoodPayCodeMeta(meta[i].id + 10000)
        if not paycode then
            local inc = {id = meta[i].id + 10000, price = meta[i].rmb / 100,
                props = tostring(meta[i].cash)..Localization:getInstance():getText("market.tabs.100")}
            MetaManager:getInstance().goodsPayCode[meta[i].id + 10000] = inc
        end
    end
end

-- return 0 means: goods not found
function MarketManager:getPageIndexByGoodsId(goodsId)
    local config = self:loadConfig()
    local pageIndex = 0
    for k, tab in pairs(config.tabs) do 
        local _break = false
        for k, v_goodsId in pairs(tab.goodsIds) do 
            if v_goodsId == goodsId then
                pageIndex = tab.pageIndex
                _break = true
                break
            end
        end
        if _break then break end
    end
    return pageIndex
end

function MarketManager:getHappyCoinPageIndex()
    for i,v in ipairs(self.tabConfig.tabs) do
        if v.tabId == TabsIdConst.kHappyeCoin then
            return i
        end
    end
    return 0
end

function MarketManager:getGiftPackPageIndex()
    for i,v in ipairs(self.tabConfig.tabs) do
        if v.tabId == TabsIdConst.kGiftPack then
            return i
        end
    end
    return 0
end

function MarketManager:getBuyCoinPageIndex()
    local id = MarketManager:sharedInstance():getPageIndexByGoodsId(51)
    if id == 0 then id = MarketManager:sharedInstance():getPageIndexByGoodsId(53) end
    if id == 0 then id = TabsIdConst.KPropSingle end
    return id
end

function MarketManager:getGoodsById(goodsId)
    goodsId = tonumber(goodsId)
    local goods = MetaManager:getInstance():getGoodMeta(goodsId)
    if not goods then return nil end

    local logic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kStore, DcSourceType.kStoreBuyProp)
    goods.currentPrice, goods.buyLimit, goods.originalPrice = logic:getPrice()
    return goods
end

function MarketManager:buy(goodsId, amount, price, successFunc, failFunc)
    local function onSuccess(data)
        -- notify observers of this goods to update interface
        self:notifyByGoodsId(goodsId)
        if successFunc then successFunc(data) end
    end

    local function onFail(errorCode)
        self:notifyByGoodsId(goodsId)
        if failFunc then failFunc(errorCode) end
    end

    local logic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kStore, DcSourceType.kStoreBuyProp)
    logic:getPrice()
    logic:start(amount, onSuccess, onFail, true, price)
end

function MarketManager:observeGoodsById(observer, goodsId)
    goodsId = tonumber(goodsId)
    -- one goodsId -> multiple observers
    if self.observers[goodsId] == nil then
        self.observers[goodsId] = {}
    end
    -- using the reference as both the key and the value
    self.observers[goodsId][observer] = observer
end

function MarketManager:removeObserverByGoodsId(observer, goodsId)
    goodsId = tonumber(goodsId)
    if not self.observers[goodsId] then return end
    self.observers[goodsId][observer] = nil
end

function MarketManager:notifyByGoodsId(goodsId)
    goodsId = tonumber(goodsId)
    if self.observers[goodsId] then
        for key, observer in pairs(self.observers[goodsId]) do
            if observer and not observer.isDisposed then
                observer:update()
            end
        end
    end
end

function MarketManager:shouldShowMarketButtonDiscount()
    local config = self:loadConfig()
    local show = false
    for k, v in pairs(config.tabs) do
        local _break = false
        for k, v in pairs(v.goodsIds) do
            local goods = MetaManager:getInstance():getGoodMeta(v)
            if goods.discountQCash > 0 then
                show = true
                _break = true
                break
            end
        end
        if _break then break end
    end
    return show
end

function MarketManager:shouldShowMarketButtonNew()
    return false
end

function MarketManager:shouldUseNewLogic()
    -- 所有平台都全开了 since 1.53
    return true
end

function MarketManager:shouldUseNewPackageGoods( ... )

    if __WIN32 then
        return true
    end

    if not __IOS then
        return false
    end

    if not self:shouldUseNewLogic() then
        return false
    end

    local uid = UserManager:getInstance().user.uid or '12345'
    local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('NewPropShopPrice', 'C1', uid)
    return isEnabled
end