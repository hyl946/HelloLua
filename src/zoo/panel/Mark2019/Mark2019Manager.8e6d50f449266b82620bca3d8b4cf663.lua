
Mark2019Manager = class()

local instance = nil

Mark2019Manager.MarkGiftDay = {7,14,21,28}
Mark2019Manager.BuQianCostList = { 10,16,19,22,25,27,29,30,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31}

local function getEventName( name )
	return name
end

Mark2019Manager.Events = {
	kPassDay = getEventName('PassDay'), }

function Mark2019Manager.getInstance()
	if not instance then
		instance = Mark2019Manager.new()
		instance:init()
	end
	return instance
end

function Mark2019Manager:showMark2019Panel(MarkCallback, CloseCallback, dcLocation)
    local startTime = os.time()
    local function sendErrorLog(key)
        local timeDelta = os.time() - startTime
        he_log_error(string.format("Mark2019Panel%s_%d_%d ", key, dcLocation, timeDelta))
    end

    if _G.bundleVersion >= "1.65" then
        local function SucessCall()
            PaymentNetworkCheck.getInstance():check(function ()
                local function getSucess()
                    local currentScene = Director:sharedDirector():getRunningSceneLua()
                    if not currentScene:is(HomeScene) then
                        sendErrorLog('scene')
                        return 
                    end
                    if PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip() then 
                        sendErrorLog('window')
                        return 
                    end

                    self.observers = {}

                    local panel = Mark2019Panel:create()
                    panel:setMarkCallback(MarkCallback)
			        panel:setCloseCallback(CloseCallback)
	                panel:popout() 
                end
                self:getMarkInfo(getSucess)
            end, function ()
                CommonTip:showTip("该功能需要联网，请检查网络状态")
            end)
            return true
        end

        local function failt()
            CommonTip:showTip("该功能需要联网，请检查网络状态")
        end
		RequireNetworkAlert:callFuncWithLogged(SucessCall,failt)
    else
        CommonTip:showTip("您已激活新签到，请更新客户端~")
    end
end

function Mark2019Manager:init()
    --调试模式 开了走假数据
	self.debugMode = false

    self.year = 1970
    self.month = 1 --当前月份
    self.MarkDay = 1
    self.giftPackInfo = {}
    self.markedDate = {} --签到天数
    self.complementedDate = {} --补签天数
    self.giftPack = {} --礼包领取
    self.todayIsMark = false


    --签到结果
    self.markReward = {}
    self.giftPack = {}
    self.showMarkDay = 1
    self.showGiftBoxList = {}

    --事件
    self.observers = {}

    --跨天监听
    self.__passDayListener = function ( ... )
        self:onPassDay()
    end
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.__passDayListener)
end

--跨天
function Mark2019Manager:onPassDay()
    self:notify(Mark2019Manager.Events.kPassDay)
end

function Mark2019Manager:getMarkAllDay()
    return #self.markedDate + #self.complementedDate
end

function Mark2019Manager:getMarkAllDayWithoutToDay()
    local MardDay = 0
    for i,v in pairs(self.markedDate) do
        if v ~= self.MarkDay then
            MardDay = MardDay + 1
        end
    end
    return MardDay + #self.complementedDate
end

--获取签到信息
function Mark2019Manager:getMarkInfo( getSucess )
	local function onSucess(evt)
        local nowDay = evt.data.nowDay --今天的日期
        local DayData = os.date('!*t', nowDay/1000 + 8*3600)
        self.year = DayData.year
        self.month = DayData.month
        self.MarkDay = DayData.day

        self.giftPack = evt.data.giftPack --礼包已领取信息
        self.giftPackInfo = evt.data.giftPackInfo --礼包包含的内容信息
        self.markedDate = evt.data.markedDate --签到信息
        self.complementedDate = evt.data.complementedDate --补签信息
        self.canReward = evt.data.canReward --是否有可以领的奖励 bool
        self.newUser = evt.data.newUser --是否是旧签到转换的玩家
        if self.newUser == nil then self.newUser = true end

        self.complementCache = table.clone(evt.data.complementCache) --播补签动画列表

        if getSucess then getSucess() end
    end

    local function onFail(evt)
		Mark2019Manager.getInstance():showErrorTip(evt)
	end

	local function onCancel( ... )
		-- body
	end

    HttpBase:syncPost('markV2GetInfo', {
		}, onSucess, onFail, onCancel)
end

--获取签到信息 混合起来的
function Mark2019Manager:getMarkDataAllInfo()
    local data = {}
   
    for i,v in ipairs(self.markedDate) do
        data[v] = true
    end

    for i,v in ipairs(self.complementedDate) do
        data[v] = true
    end

    return data
end

--解析签到数据
function Mark2019Manager:decodeMarkData( evt, sucessCall )
    local reward = {}
    local GiftDay = 0
    local giftPack = {}
    local markDay = 1
    local bReMark = false
    local allRewards = {}

    local time = evt.data.time
    local DayData = os.date('!*t', time/1000 + 8*3600)
    markDay = DayData.day
    if markDay ~= self.MarkDay then 
        bReMark = true
    end

    local BuQianCost = Mark2019Manager.getInstance():getReMarkCost()

    reward = evt.data.reward --签到奖励
    allRewards = evt.data.allRewards --全部奖励显示用
    giftPack = evt.data.giftPack --自动领取的宝箱

    self.showGiftBoxList = {}
    for i,v in pairs(evt.data.giftPack) do
        GiftDay = tonumber(i)
        giftPack = table.clone(v)
        self.showGiftBoxList[1] = GiftDay
    end

    self:addMarkDay( markDay, bReMark )
    self:addGiftBox( GiftDay, giftPack )
        
    self:addRewards( {reward}, 1 )

    self:addRewards( giftPack.rewards, 2 )
    self.markReward = table.clone(reward)
    self.showMarkDay = markDay

    if bReMark == false then
        self.todayIsMark = true

        --存储user
        UserManager:getInstance():setTodayMark()
        UserService:getInstance():setTodayMark()
        Localhost:flushCurrentUserData()
    end

    Notify:dispatch("AchiEventDataUpdate",AchiDataType.kMarkAddCount, 1)
    if GiftDay == 28 then
        Notify:dispatch("AchiEventDataUpdate", AchiDataType.kGetFinalMarkChest, true)
    end

    if markDay == self.MarkDay then 
        local MardData = Mark2019Manager.getInstance():getMarkDataAllInfo()
        local allMarkDay = 0
        for i,v in pairs(MardData) do
            allMarkDay= allMarkDay+ 1
        end
        self:DC( 'sign_days', allMarkDay, DayData.month )
    end
        
    local OtherReward = table.clone(allRewards)
    for i,v in ipairs(OtherReward.rewards) do
        if v.itemId == reward.itemId then
            table.remove( OtherReward.rewards, i )
            break
        end
    end
    if sucessCall then sucessCall( OtherReward ) end
end

--补签道具购买结果
function Mark2019Manager:ReMark( evt, sucessCall )
    local evtData = table.deserialize(evt)
    self:decodeMarkData( evtData, sucessCall )
end

--签到  param 是否是补签
function Mark2019Manager:Mark( bRetroactive, day, sucessCall, FailCall, CancelCall )
	local function onSucess(evt)
        self:decodeMarkData( evt, sucessCall )
    end

    local function onFail(evt)
		Mark2019Manager.getInstance():showErrorTip(evt)

        if FailCall then FailCall() end
	end

	local function onCancel( ... )
		-- body
        if CancelCall then CancelCall() end
	end

    local param = {}
    if bRetroactive then
        local curData = os.date("*t")
        curData.day = day
        curData.year = self.year
        curData.month = self.month
        param.dateTime = os.time2( curData )*1000
        param.complement = bRetroactive
    end

    HttpBase:syncPost('markV2', param, onSucess, onFail, onCancel)
end

--有未领礼包补充
function Mark2019Manager:markV2GetGiftPack( sucessCall, FailCall, CancelCall )
    local function onSucess(evt)
        self.showGiftBoxList = {}
        for i,v in pairs(evt.data.giftPack) do
            local GiftDay = tonumber(i)

            self:addGiftBox( GiftDay, v )
            self:addRewards( v.rewards, 2 )

            table.insert( self.showGiftBoxList, GiftDay )
        end

        self.canReward = false

        if sucessCall then sucessCall() end
    end

    local function onFail(evt)
		Mark2019Manager.getInstance():showErrorTip(evt)

        if FailCall then FailCall() end
	end

	local function onCancel( ... )
		-- body
        if CancelCall then CancelCall() end
	end

    HttpBase:syncPost('markV2GetGiftPack', {}, onSucess, onFail, onCancel)
    
end

--添加签到信息
function Mark2019Manager:addMarkDay( markDay, bRetroactive )
    if bRetroactive then
        table.insert( self.complementedDate, markDay )
    else
        table.insert( self.markedDate, markDay )
    end
end

--添加礼包领取信息
function Mark2019Manager:addGiftBox( index, giftPack )
    self.giftPack[tostring(index)] = table.clone(giftPack)
end

--获取可以补签的第一天 也能表示是否可以签到
function Mark2019Manager:getCanBuQian()

    local MarkAllInfo = self:getMarkDataAllInfo()
    local MarkDay = self.MarkDay

    for i=1, MarkDay-1 do
        if not MarkAllInfo[i] then
            return i
        end
    end

    return nil
end

--今日是否签到
function Mark2019Manager:getCurDayIsMark()

    local bMark = false
    local MarkAllInfo = self:getMarkDataAllInfo()
    local MarkDay = self.MarkDay

    if MarkAllInfo[MarkDay] then
        return true
    end

    return false
end

--获取已领礼包数量
function Mark2019Manager:getGiftPackNum()
    local num = 0
    for i,v in pairs( self.giftPack ) do
        num = num + 1
    end

    return num
end

--获取礼包是否已领
function Mark2019Manager:getGiftPackIsOpen( day )
    if self.giftPack[tostring(day)] then 
        return true 
    end

    return false
end

--获取已领礼包数量
function Mark2019Manager:getReMarkCost()
    local curReMarkNum = #self.complementedDate
    return Mark2019Manager.BuQianCostList[curReMarkNum+1] or 31
end

--获取当月天数
function Mark2019Manager:getDayByYearMonth(_year, _month)
    local _curYear = tonumber(_year)
    local _curMonth = tonumber(_month)
    if not _curYear or _curYear <= 0 or not _curMonth or _curMonth <= 0 then
        return
    end
    local _curDate = {}
    _curDate.year = _curYear
    _curDate.month = _curMonth + 1
    _curDate.day = 0
    local _maxDay = os.date("%d",os.time(_curDate)+ 8*3600)
    return _maxDay
end

--创建个道具图
function Mark2019Manager:createIcon( itemInfo )

    local baseLayer = Layer:create()

	local icon
	if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		icon = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE, itemInfo.num )
	else
		icon = ResourceManager:sharedInstance():buildItemSprite(itemInfo.itemId)
	end
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon.itemInfo = itemInfo

    local size = icon:getContentSize()

    local num_str = 'x'..itemInfo.num
    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
    	num_str = itemInfo.num / 60
    	if num_str < 1 then
    		num_str = itemInfo.num
    	end
    end

    local offset = 0
    if itemInfo.itemId == 10087 or itemInfo.itemId == 10088 then
    	offset = 10
    end

    if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
    	local num = BitmapText:create("x1", 'fnt/autumn2017.fnt')
        num:setAnchorPoint(ccp(0, 0.5))
        num:setScale(1.3)
        local tx = 80 + offset
        num:setPosition(ccp(tx, size.height/2 - 10))
        icon:addChild(num)
    else
        local num = BitmapText:create(num_str, 'fnt/autumn2017.fnt')
        num:setAnchorPoint(ccp(0, 0.5))
        num:setScale(1.3)
        local tx = 80 + offset
        num:setPosition(ccp(tx, size.height/2 - 10))
        icon:addChild(num)
    end

    if ItemType:isTimeProp(itemInfo.itemId )  then
        local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemInfo.itemId, true)
        icon:addChild(time_prop_flag)
        time_prop_flag:setAnchorPoint(ccp(0.5,0.5))
        local size = icon:getContentSize()
        time_prop_flag:setPosition( ccp( size.width/2, 0 ) )
    end

    icon:setScale(0.6)
    
    baseLayer:addChild( icon )
    return baseLayer
end

function Mark2019Manager:addRewards( rewardItems, source )
	for _,reward in pairs(rewardItems or {}) do
		UserManager:getInstance():addReward(reward, true)
		Localhost:getInstance():flushCurrentUserData()
		UserService:getInstance():addRewards({reward})


        --消耗精力瓶
	    if reward.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		    local logic = UseEnergyBottleLogic:create(reward.itemId, DcFeatureType.kSignIn,  DcSourceType.kEnergyUse)
		    logic:setUsedNum(reward.num)
		    logic:setSuccessCallback(function ( ... )
			    HomeScene:sharedInstance():checkDataChange()
			    HomeScene:sharedInstance().energyButton:updateView()
		    end)
		    logic:setFailCallback(function ( evt )
		    end)
		    logic:start(true)
	    end

        --打点
        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kSignIn, reward.itemId, reward.num, 'mark2019_'..source )
--        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kSignIn, reward.itemId, reward.num, DcSourceType.kSignReward)
	end
end

function Mark2019Manager:isSupportShare( ... )
    local fuck_platforms = {
        PlatformNameEnum.kMiTalk,
    }

    for _, platform in ipairs(fuck_platforms) do
        if PlatformConfig:isPlatform(platform) then
            return false
        end
    end

    return true
end

--这个方法不要动
function Mark2019Manager:showErrorTip(evt)
	local errcode = evt and evt.data or nil
	if errcode then
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
	end
end

function Mark2019Manager:goldNotEnough()
	if _G.isLocalDevelopMode then printx(0, "Mark2019Manager:goldNotEnough") end
	local function createGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "createGoldPanel") end
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel = createMarketPanel(index)
			panel:popout()
		end
	end
	local function askForGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "ask for gold panel") end
		GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
	end
	askForGoldPanel()
end

function Mark2019Manager:addObserver(ob)
	self.observers[ob] = ob
end

function Mark2019Manager:removeObserver(ob)
	if self.observers[ob] then
		self.observers[ob] = nil
	end
end

function Mark2019Manager:notify(eventName, ...)
	for _, ob in pairs(self.observers) do
		if ob['on' .. eventName] then
			ob['on' .. eventName](ob, ...)
		end
	end
end

function Mark2019Manager:DC( sub_category, par1,par2 )
    local params = {
		game_type = "stage",
		game_name = "sign_in",
		category = "sign_in",
		sub_category = sub_category,
		t1 = par1,
        t2 = par2,
	}

	DcUtil:dcForUserTrack(params)
end

function Mark2019Manager:time2day( ts )
	ts = ts or Localhost:timeInSec()
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end