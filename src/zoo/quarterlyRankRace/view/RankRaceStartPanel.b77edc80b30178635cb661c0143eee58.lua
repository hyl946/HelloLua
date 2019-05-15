--[[
 * RankRaceStartPanel
 * @date    2018-05-17 14:24:14
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local DEBUG = false

RankRaceStartPanel = class(BasePanel)

function RankRaceStartPanel:create( levelIndex, isDebug, mainPanel )
	DEBUG = isDebug
	local panel = RankRaceStartPanel.new()
	panel:loadRequiredResource("ui/RankRace/StartPanel.json")
	panel:init(levelIndex, mainPanel)
	return panel
end

function RankRaceStartPanel:getInputData(levelIndex)
	local goodsId = 496
	self.buylogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kRankRace, DcSourceType.kRankRacePlayCount)
	local price, buyLimit = self.buylogic:getPrice()

	local isWindmillEnough = self:isWindmillEnough()
	local isRmbBuy = not isWindmillEnough and __ANDROID

	if not DEBUG then
		return {
			levelIndex = levelIndex,
			unlockNextNum = RankRaceMgr.getInstance():getUnlockTarget(levelIndex),
			leftFreePlay = RankRaceMgr.getInstance():getData().leftFreePlay or 0,
			bonus = RankRaceMgr.getInstance():getTargetBuff( levelIndex ),
			goodsId = goodsId,
			isLimit = buyLimit == 0,
			isRmbBuy = isRmbBuy,
			unlockIndex = RankRaceMgr.getInstance():getData():getUnlockIndex(),
		}
	else
		require "zoo.quarterlyRankRace.view.RankRaceStartUnitTest"
		return RankRaceStartUnitTest:getTestData()
	end 
end

function RankRaceStartPanel:getStrConfig(levelIndex)
	if levelIndex < 6 then
		return {tstr = string.format("第%d关", levelIndex), tip1 = "本关单次收集"}
	else
		return {tstr = "第6关", tip1 = "本关宝石加成"}
	end
end

function RankRaceStartPanel:checkBtnState()
	--"rmbBuy","windBuy","free","limit"
	local data = self.data
	if data.leftFreePlay > 0 then
		self.btnState = "free"
	elseif data.isLimit then
		self.btnState = "limit"
	else
		--buy
		if not data.isRmbBuy then
			self.btnState = "windBuy"
		else
			self.btnState = "rmbBuy"
		end
	end
end

function RankRaceStartPanel:onNotify( key )
	if key == RankRaceOBKey.kPassDay then
		if self.isDisposed then return end
		self.data.leftFreePlay = RankRaceMgr.getInstance():getData().leftFreePlay or 0
		self:refresh()
	end
end

function RankRaceStartPanel:initJiaoBiao(visible)
	local ui = self.ui
	local data = self.data

	if visible then
		local label2 = self.jiaobiaoLabel
		if not label2 then
		    local jiachengUI = ui:getChildByName("jiacheng")
		    local text = jiachengUI:getChildByName('text')
		    local size = jiachengUI:getChildByName('size')

		    text.fntFile = "fnt/newzhousai_rubyincrease.fnt"
		    label2 = TextField:createWithUIAdjustment(size, text)
		    jiachengUI:addChild(label2)
		    self.jiaobiaoLabel = label2
		end
	    label2:setString(string.format("+%d%%", data.bonus))
	else
		ui:getChildByName("jiacheng"):setVisible(false)
		ui:getChildByName("jiaobiao"):setVisible(false)
	end
end

function RankRaceStartPanel:initMid( state )
	local ui = self.ui
	local data = self.data
	local numPh = ui:getChildByName("numPh")
	local npos = numPh:getPosition()
	local nsize = numPh:getGroupBounds().size
	numPh:setVisible(false)

	local config = self:getStrConfig(data.levelIndex)

	local label1 = self.midLabelUp
	if not label1 then
		local tip1UI = ui:getChildByName("tip1")
	    local text = tip1UI:getChildByName('text')
	    local size = tip1UI:getChildByName('size')

	    text.fntFile = "fnt/register.fnt"
	    label1 = TextField:createWithUIAdjustment(size, text)
	    tip1UI:addChild(label1)
	    label1:setColor(ccc3(102, 51, 0))
	    self.midLabelUp = label1
	end
    label1:setString(config.tip1)

    local label2 = self.midLabelDown
    if not label2 then
	    local tip2UI = ui:getChildByName("tip2")
	    local text = tip2UI:getChildByName('text')
	    local size = tip2UI:getChildByName('size')

	    text.fntFile = "fnt/register.fnt"
	    label2 = TextField:createWithUIAdjustment(size, text)
	    tip2UI:addChild(label2)
	    label2:setColor(ccc3(102, 51, 0))
	    self.midLabelDown= label2
	end

    label2:setString(string.format("即可提前解锁第%d关", data.levelIndex+1))

    local numVisible = false
    local numStr = string.format("x%d", data.unlockNextNum)
    local numFnt = "fnt/newzhousai_rubynum.fnt"
    local xoffset = 0
    local yoffset = 0

    local baos = ui:getChildByName("baos")
    local baos2 = ui:getChildByName("baos2")

	if state == 1 then
	    label1:setString("闯关可收集：")
	    label2:setVisible(false)
	    numVisible = false
	    baos:setPositionY(baos:getPositionY() - 20)
	elseif state == 2 then
		numVisible = true
		xoffset = 10
	elseif state == 3 then
		numStr = string.format("+%d%%", data.bonus)
		numFnt = "fnt/newzhousai_rubynum.fnt"
		numVisible = true
		label1:setString("本关宝石加成：")
		label2:setVisible(false)
    elseif state == 4 then
        local addNum = RankRaceMgr.getInstance().data:getMetaValue('first_pass_gold_'..data.levelIndex) or 0
        numStr = "x"..addNum
		numFnt = "fnt/newzhousai_rubynum.fnt"
        numVisible = true
        xoffset = 10
        yoffset = -20/0.7
        label1:setString("今日通过本关可获得：")
        label2:setVisible(false)
	end

	baos:setVisible(state ~= 3 and state ~= 4 )
    baos2:setVisible( state == 4 )
	ui:getChildByName("baos1"):setVisible(state == 3)

	baos:setScale(1.2)
	local posX = self.SaveBaosPos.x
	local posY = self.SaveBaosPos.y + 10
	if data.levelIndex ~= 1 then
		posX = posX - 50
	end
	baos:setPositionXY(posX, posY)

    baos2:setScale(1)
	local posX2 = self.SaveBaos2Pos.x
	local posY2 = self.SaveBaos2Pos.y
	baos2:setPositionXY(posX2, posY2+yoffset)

	if self.midLabelMid then
		self.midLabelMid:removeFromParentAndCleanup(true)
	end

    local num = BitmapText:create(numStr, numFnt)
	num:setAnchorPoint(ccp(0, 0.5))
	num:setPosition(ccp(npos.x+xoffset, npos.y - nsize.height/2 - 10 + yoffset ))
	num:setScale(0.9)
	ui:addChild(num)
	num:setVisible(numVisible)

	self.midLabelMid = num
end

function RankRaceStartPanel:refresh()
	if self.isDisposed then return end

	local calStatus = tonumber(RankRaceMgr.getInstance():getData():getStatus())
    if calStatus and (calStatus == 2 or calStatus == 3) then
    	self:onCloseBtnTapped()
    	return
    end

	local data = self.data
	local ui = self.ui
	local unlockIndex = data.unlockIndex
	if data.levelIndex < 6 and data.levelIndex > 1 then
		self:initJiaoBiao(unlockIndex == data.levelIndex)
	else
		self:initJiaoBiao(false)
	end

    --是否有首次通关奖励
    local ExtraGoldExcludeIndexes = RankRaceMgr.getInstance().data:getExtraGoldExcludeIndexes()

    local function bIsInGoldExcludeIndexes( num )
        if ExtraGoldExcludeIndexes and type(ExtraGoldExcludeIndexes) == 'table'  then
            for i,v in pairs(ExtraGoldExcludeIndexes) do
                if v == num then
                    return true
                end
            end
        end

        return false
    end
    --
    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()

	local mstate = 2
    local bIsInGoldExcludeIndexes = bIsInGoldExcludeIndexes( data.levelIndex )
    if not bIsInGoldExcludeIndexes and SaijiIndex ~= 1 and data.levelIndex ~= 6 then
        mstate = 4 --倒计时关卡
    else
	    if data.levelIndex == 1 then
		    if unlockIndex > 1 then
			    mstate = 1
		    else
			    mstate = 2
		    end
	    elseif data.levelIndex < 6 then
		    if unlockIndex > data.levelIndex then
			    mstate = 3
		    else
			    mstate = 2
		    end
	    else
		    mstate = 3
	    end
    end

	self:initMid(mstate)

    local btn = self.startBtn
    btn:setIcon(nil)
    btn:setNumber("")

    self:checkBtnState()
    if self.btnState == "limit" then
    	btn:setColorMode(kGroupButtonColorMode.grey)
    	btn:setString("明日再来")
    elseif self.btnState == "free" then
    	btn:setColorMode(kGroupButtonColorMode.green)
    	
    	btn:setString("闯关")

    	if self.freeNum then
    		self.freeNum:removeFromParentAndCleanup(true)
    	end

    	local dot = ui:getChildByName("dot")
    	local ph = dot:getChildByName("ph")

    	local size = self.dotSize
    	if not self.dotSize then
    		local s = ph:getGroupBounds().size
    		self.dotSize = {width =s.width, height = s.height}
    		size = self.dotSize
    	end

    	local num = BitmapText:create(tostring(data.leftFreePlay), "fnt/prop_amount.fnt")

    	local numsize = num:getGroupBounds().size
    	local rh = size.height / numsize.height - 0.3
    	local rw = size.width / numsize.width - 0.3
    	local r = rh < rw and rh or rw

    	num:setScale(r)
		num:setPosition(ccp(size.width/2, -size.height/2))

		ph:setVisible(false)
		self.freeNum = num
		dot:addChild(num)
	elseif self.btnState == "windBuy" or self.btnState == "rmbBuy" then
		btn:setColorMode(kGroupButtonColorMode.blue)
    	btn:setString("闯关")
		if self.btnState == "rmbBuy" then
			btn:setNumber("￥5")
		else
	    	btn:setIconByFrameName("common_icon/item/icon_coin_small0000")
			btn:setNumber("50")
		end
    end

    ui:getChildByName("dot"):setVisible(self.btnState == "free")
end

function RankRaceStartPanel:init(levelIndex, mainPanel)
	self.ui = self:buildInterfaceGroup("zhou.rank.race/startpanel")
	BasePanel.init(self, self.ui)

	RankRaceMgr.getInstance():addObserver(self)

	local ui = self.ui

	local data = self:getInputData(levelIndex)

	self.data = data
	self.mainPanel = mainPanel

	self:genLevelId()

	DcUtil:UserTrack({
        category='weeklyrace2018', 
        sub_category='weeklyrace2018_click_stage',
        t1 = self.levelId,
    })

	local titlePh = ui:getChildByName("titlePh")
	local tpos = titlePh:getPosition()
	local tsize = titlePh:getGroupBounds().size
	titlePh:setVisible(false)

	local config = self:getStrConfig(data.levelIndex)
	local tstr = config.tstr

	local title = BitmapText:create(tstr, "fnt/newzhousai_title.fnt")
	title:setPosition(ccp(tpos.x + tsize.width/2, tpos.y - tsize.height/2))
	ui:addChild(title)

	self.closeBtn = self.ui:getChildByName('close')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)


    local baos = self.ui:getChildByName("baos")
    local baos2 = self.ui:getChildByName("baos2")
    self.SaveBaosPos = ccp( baos:getPositionX(), baos:getPositionY() )
    self.SaveBaos2Pos = ccp( baos2:getPositionX(), baos2:getPositionY() )

    self.startBtn = ButtonIconNumberBase:create(ui:getChildByName('btn'))
    
    self:refresh()

    -- btn:setTouchEnabled(true)
	self.startBtn:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(function ()
		self:onTouchBtn()
	end))
	
end

function RankRaceStartPanel:isWindmillEnough()
	local user = UserManager:getInstance().user
	local money = user:getCash()
	local price, buyLimit = self.buylogic:getPrice()
	return money >= price
end

function RankRaceStartPanel:checkShowTimeWarnPanel( cb )
	if RankRaceMgr.getInstance():isNeedShowTimeWarnPanel() then
        CommonTipWithBtn:showTip({tip = localize("rank.race.main.13"), yes = "知道了"}, "negative", cb, cb, nil, true)
    else
        if cb then cb() end
    end
end

function RankRaceStartPanel:genLevelId()
	local levelIndex = self.data.levelIndex

	self.indexQueue = self.indexQueue or {}
	self:readLocalData()
	if levelIndex == 6 then
		local all = {1,2,3,4,5}
		for _,index in ipairs(self.indexQueue) do
		  table.removeValue(all, index)
		end
		math.randomseed(os.time())
		local ti = math.random(1, #all)
		levelIndex = all[ti] + 5
	end

	if #self.indexQueue > 1 then
		table.remove(self.indexQueue, 1)
	end
	
	local recode = levelIndex
	if levelIndex > 5 then
		recode = recode - 5
	end
	table.insert(self.indexQueue, recode)
	self:writeLocalData()

	local range = RankRaceMgr.getInstance():getLevelIDRange()
    local levelId = range[levelIndex] or 310001
    self.levelId = levelId
end

local dataPath = HeResPathUtils:getUserDataPath() .. '/rank_race_level_index'
function RankRaceStartPanel:readLocalData()
	local file = io.open(dataPath, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            local data = table.deserialize(content) or {}
            for k,v in pairs(data) do
            	self.indexQueue[k] = v
            end
        end
    end
end

function RankRaceStartPanel:writeLocalData()
	local file = io.open(dataPath,"w")
    if file then 
        file:write(table.serialize(self.indexQueue or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(dataPath..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(self.indexQueue or {}))
	        file:close()
	    end
    end
end

function RankRaceStartPanel:onTouchBtn( state )
	if self.isDisposed then return end
	DcUtil:UserTrack({
        category='weeklyrace2018', 
        sub_category='weeklyrace2018_click_start',
        t1 = self.levelId,
    })
	local function __play( ... )
		if self.isDisposed then return end
		if self.btnState == "windBuy" or self.btnState == "rmbBuy" then
			self:checkShowTimeWarnPanel(function ( ... )
				self:buy()
			end)
		elseif self.btnState == "free" then
			self:checkShowTimeWarnPanel(function ( ... )
				self:goToLevel()
			end)
		elseif self.btnState == "limit" then
			CommonTip:showTip("今日次数已用尽，明日再来吧！", "negative")
		end
	end


	RankRaceMgr:getInstance():checkLevelExists(function ( ret )
		if ret then

            local bIsCurWeekLevel = RankRaceMgr:getInstance():checkLevelsIsCurWeekLevel()

            if bIsCurWeekLevel then
			    __play()
            else
                CommonTip:showTip(localize('rank.race.no.stage'))
            end
		else
			CommonTip:showTip(localize('RankRace.invalid.level'))
		end
	end)

	
end

function RankRaceStartPanel:buy()
	local goodsId = self.data.goodsId
	local function onSuccess( ... )
		RankRaceMgr:getInstance():onPaySuccess()
		self:goToLevel(true)
	end

	local function onFail( errCode, errMsg )
		if errCode then
			if __ANDROID then
				CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
			else
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..errCode), "negative")
			end
		else
			CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
		end
	end

	local function onCancel( )
		-- CommonTip:showTip("购买取消", "negative")
	end

	if self.btnState == "windBuy" then
		self.dcAndroidInfo = DCWindmillObject:create()
        self.dcAndroidInfo:setGoodsId(goodsId)
        PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcAndroidInfo)

		local logic = WMBBuyItemLogic:create()
        local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kRankRace, DcSourceType.kRankRacePlayCount)
        buyLogic:getPrice()
        
        if __WIN32 then
        	onSuccess()
        else
        	logic:buy(goodsId, 1, self.dcAndroidInfo, buyLogic, onSuccess, onFail, onFail)
        end
	elseif self.btnState == "rmbBuy" then
		local logic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, DcFeatureType.kRankRace, DcSourceType.kRankRacePlayCount)
		logic:buy(onSuccess, onFail, onCancel)
	else
		printx(10, "[error]!!!")
	end
end

function RankRaceStartPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function RankRaceStartPanel:popout()
	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function RankRaceStartPanel:goToLevel(isBuyed)
	RankRaceMgr.getInstance():setLevelIndex(self.data.levelIndex)

	if not isBuyed and self.data.leftFreePlay <= 0 then
		CommonTip:showTip(localize('rank.race.no.more.time'))
		return
	end

	if self.mainPanel then self.mainPanel:showLoading() end

	self:onCloseBtnTapped()

 	local levelId = self.levelId

    local levelType = LevelType:getLevelTypeByLevelId(levelId)

    printx(10, "RankRace cur index is:", levelIndex, levelId)

    local logic = NewStartLevelLogic:create( self.mainPanel , levelId , {} , true , nil , nil , 207 )
	logic:start(true)
end