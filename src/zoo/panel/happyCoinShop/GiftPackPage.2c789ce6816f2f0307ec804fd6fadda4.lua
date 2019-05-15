--[[
 * GiftPackPage
 * @date    2019-01-03 17:13:18
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local GiftPackPage = class(Layer)

local UIHelper = require 'zoo.panel.UIHelper'

function GiftPackPage:create(config, main_panel)
    local instance = GiftPackPage.new()
    instance.config = config
    instance.main_panel = main_panel
    instance:init()
    return instance
end

function GiftPackPage:init()
    Layer.initLayer(self)

    self:initTop()
    self:initItems()

    self:layout()
end

function GiftPackPage:initTop()
	local item_top = UIHelper:createUI('ui/MarketGiftPackPanel.json', 'MarketGiftPack/group/item_top')
    self.item_top = item_top
    self:addChild(item_top)

    local cd = BitmapText:create('领奖时间', 'fnt/register2.fnt')
    local cdph = item_top:getChildByName('cd')
    cdph:setVisible(false)
    local size = cdph:getGroupBounds().size
    local pos = cdph:getPosition()
    cd:setAnchorPoint(ccp(0, 0.5))
    cd:setColor(ccc3(204, 51, 0))
    cd:setPosition(ccp(pos.x, pos.y - size.height/2 - 5))
    cd:setScale(1.1)
    item_top:addChild(cd)

    self.top_cd = cd
end

function GiftPackPage:closeCdSchedule()
	if self.cdId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cdId)
        self.cdId = nil
    end

    if self.isDisposed then return end

    if self.top_cd then
        self.top_cd:setText('')
    end
end

function GiftPackPage:timeEnd()
	-- for _,item in ipairs(self.items) do
	-- 	self:setBtnState(item, true)
	-- end

	if self.top_cd then
        self.top_cd:setText('00:00:00')
    end
end

function GiftPackPage:updatet()
	if self.isDisposed then
        self:closeCdSchedule()
        return
    end
    local now = Localhost:timeInSec()
    local deadline = self.deadline or 0
    local endTime = math.floor(deadline / 1000)
    local last = endTime - now

    local time = convertSecondToHHMMSSFormat(last)
    local hasone = GiftPack:hasActNewerPackOne()

    local goodsIds = GiftPack:getNewerPackOneGoodsIds()
    local showStatic = not hasone and GiftPack:hasAnyRewardNotExp()
    self.item_top:getChildByName('rewardtime'):setVisible(showStatic)
    self.top_cd:setText(time)
    self.top_cd:setVisible(not showStatic)

    if last <= 0 then
    	self:timeEnd()
    end

    endTime = math.floor(Localhost:getDayStartTimeByTS(Localhost:timeInSec() + 24*3600))
    last = endTime - now
    time = convertSecondToHHMMSSFormat(last) .. '后可领'

    for _,item in ipairs(self.items) do
    	local cd = item.cd
    	if cd then
    		local infos = GiftPack:getGoodsInfo(item.goodsId)
	    	if item and GiftPack:checkPack(item.goodsId) and infos.info.seeCount ~= -1 then
	    		local btn = item.btn
	    		if btn and not btn.isDisposed then
	    			btn:setVisible(true)
	    			btn:setEnabled(true)
	    		else
	    			btn = GroupButtonBase:createNewStyle( item:getChildByName('btn') )
				    btn:ad(DisplayEvents.kTouchTap, function ( ... )
				    	self:getReward(item)
				    	btn:setEnabled(false)
				    end)
				    item.btn = btn
				    btn:setString('领取')
	    		end
	    		cd:setVisible(false)
	    	else
	    		cd:setVisible(true)
	    	end

	    	if not cd.isDisposed then
	    		cd:setText(time)
	    		if last == 3600*24 then
	    			cd:setText('00:00:00后可领')
	    		end
	    	end
	    end

	    if item.refreshItem then
	    	item.refreshItem()
	    end
    end
end

function GiftPackPage:createCdSchedule()
	if self.cdId then
		self:updatet()
		return
	end

	local function update()
        self:updatet()
    end

    update()

    self.cdId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
end

function GiftPackPage:initItems()
	local infos = GiftPack:getActNewerPackOne()
	local rewardInfos = GiftPack:getRewardGoods()

	self.items = {}
	local cd = false
	for index,info in ipairs(infos) do
		local item = self:createItem(info, rewardInfos[index])
		local hasBought = GiftPack:hasBought(info.goodsId)
		if item then
			table.insert(self.items, item)
			self:addChild(item)
		end

		if not hasBought and GiftPack:checkPack(info.goodsId) then
			cd = true
		end
	end

	self.item_top:getChildByName('rewardtime'):setVisible(not cd)
	if cd then
		self:createCdSchedule()
	else
		self.top_cd:setText('')
	end

	if self.cdId then
		self:updatet()
	end
end

function GiftPackPage:createItem( infos, rewardInfos )
	local config = infos.config
	local info = infos.info
	local goodsId = infos.goodsId

	self.deadline = GiftPack:getPackDeadline(goodsId) or 0

	local item
	if config.reward then
		if GiftPack:checkPack(rewardInfos.goodsId) or GiftPack:hasBought(goodsId) then
			item = self:createNewerOneReward(rewardInfos, goodsId)
		else
			item = self:createNewerOne(goodsId, rewardInfos.goodsId)
		end
	else
		item = self:createNormal(goodsId)
	end

	return item
end

function GiftPackPage:removeItem( item )
	table.removeValue(self.items, item)
	item:removeFromParentAndCleanup(true)
end

function GiftPackPage:onBuySuccess( item )
	if self.isDisposed then return end
	local goodsId = item.goodsId
	local rewardGoodsId = GiftPack:getRewardGoodsId(goodsId)
	if rewardGoodsId then
		--remove and create reward item
		self:removeItem(item)

		item = self:createNewerOneReward(GiftPack:getGoodsInfo( rewardGoodsId ), goodsId)
		table.insert(self.items, item)
		self:addChild(item)
	else
		--remove
		-- self:removeItem(item)
		self:setBtnState(item)
		item.buyed = true
		local goodsIds = {}
		for _,it in ipairs(self.items) do
			table.insert(goodsIds, it.goodsId)
		end
		local hasAllBought = GiftPack:hasAllBought(goodsIds)
		if hasAllBought then
			self.main_panel:onCloseBtnTapped()
		end
	end
	self:layout()
end

function GiftPackPage:buy( item )
	local flyCount = 0
    local flymax = #item.icons

    if item.goldicon then flymax = flymax + 1 end

    local meta = MetaManager.getInstance():getGoodMeta(item.goodsId)
    local bottle = table.find(meta.items, function (it)
        return it.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
    end)

    local function finished()
        flyCount = flyCount + 1
        if flyCount >= flymax then
        	if bottle then
        		GiftPack:showEnergyAlert(bottle.num, function ()
        			self:onBuySuccess(item)
                end)
        	else
	            self:onBuySuccess(item)
	        end
        end
    end

	
    local function fly( icon )
        local itemInfo = icon.itemInfo
        if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
            itemInfo = {itemId = itemInfo.itemId, num = 1}
        end
        local anim = FlyItemsAnimation:create({itemInfo})
        local pos = icon:getPosition()
        pos = icon:getParent():convertToWorldSpace(pos)
        local bounds = icon:getGroupBounds()
        local x,y = 0,0
        if icon == item.goldicon then
        	x = bounds.size.width / 2
        	y = - bounds.size.height / 2
        end
        anim:setWorldPosition(ccp(pos.x + x, pos.y + y))
        anim:setScaleX(icon:getScaleX())
        anim:setScaleY(icon:getScaleY())
        anim:setFinishCallback(finished)
        anim:play()
    end

    local function dc( info )
    	local list_id = ''
    	for _,it in ipairs(self.items) do
    		list_id = list_id .. it.goodsId
    		if #self.items ~= _ then
    			list_id = list_id .. ','
    		end
    	end
    	info.list_id = list_id
    	GiftPack:dc('buy', 'pay_stage_shop', info)
    end

	local function onSuccess(dcInfo)
		if self.isDisposed then return end
        for k, icon in ipairs(item.icons) do
	        fly(icon)
	    end
	    if item.goldicon then
	    	fly(item.goldicon)
	    end

	    dc(dcInfo or {})

	    if item.btn and not item.btn.isDisposed then
        	item.btn:setEnabled(false)
        end
    end

    local function onFail(dcInfo)
        dc(dcInfo or {})
        if item.btn and not item.btn.isDisposed then
        	item.btn:setEnabled(true)
        end
    end

    local function onCancel(dcInfo)
        dc(dcInfo or {})
        if item.btn and not item.btn.isDisposed then
        	item.btn:setEnabled(true)
        end
    end

    GiftPack:buy(item.goodsId, onSuccess, onFail, onCancel)
end

function GiftPackPage:createNormal( goodsId )
	local item = UIHelper:createUI('ui/MarketGiftPackPanel.json', 'MarketGiftPack/group/item_normal')

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100
	local bg = item:getChildByName('bg2')
	local bgsize = bg:getPreferredSize()
	local marge = 10

	item.goodsId = goodsId

	local items = table.filter(meta.items, function ( itemInfo )
		return itemInfo.itemId ~= 14
	end)

	local gold = table.find(meta.items, function ( itemInfo )
		return itemInfo.itemId == 14
	end)

	local w = (bgsize.width - 2*marge)/2
	local h = (bgsize.height - 2*marge)/(#items > 4 and 3 or 2)

	item.icons = {}

	for index,itemInfo in ipairs(items) do
		local icon = GiftPack:createIcon(itemInfo)
        bg:addChild(icon)

        if #items <= 4 then
        	icon:setScale(0.65)
        else
        	icon:setScale(0.6)
        end

        local size = icon:getGroupBounds().size
        icon:setPosition(ccp(w / 2 + marge + (index-1)%2*w - 20, bgsize.height - marge - h/2 - math.floor((index-1)/2)*h))

        item.icons[index] = icon
	end

	local goldicon = item:getChildByName('gold_icon')
	local size = goldicon:getContentSize()
	local num = BitmapText:create(gold.num, 'fnt/zhifuyouhua1.fnt')
	num:setAnchorPoint(ccp(0, 0.5))
	num:setPosition(ccp(size.width, size.height/2))
	goldicon:addChild(num)

	item:getChildByName('gold'):setVisible(price > 6)
	item:getChildByName('goldl'):setVisible(price <= 6)

	item.goldicon = goldicon
	goldicon.itemInfo = gold

	local btnui = item:getChildByName('btn')
	local btn = ButtonIconNumberBase:createNewStyle( btnui )
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:buy(item)
    	btn:setEnabled(false)
    end)
    btn:setDelNumber(string.format('￥%0.2f', ori_price))
    btn:setNumber(string.format('￥%0.2f', price))
    btn:setColorMode(kGroupButtonColorMode.blue)
    item.btn = btn

    self:setBtnState(item)

    self:setDiscount(item, goodsId)

	return item
end

function GiftPackPage:getDiscountNum( goodsId )
	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100

	local discountNum = price * 10 / ori_price
	local num = math.ceil(discountNum)
	local distance = num - discountNum
	return distance > 0.5 and math.floor(discountNum) or num
end

function GiftPackPage:setDiscount(item, goodsId)
	local discountNum = self:getDiscountNum(goodsId)

	if not item.discountUI then
		local discountContainerUI = item:getChildByName('zhe')
		local discountUI = discountContainerUI:getChildByName('discount')

		item.discountUI = discountUI
		item.discountContainerUI = discountContainerUI
		self.playDiscountAnim = function ()
            if self.isDisposed then return end
            local array = CCArray:create()
            array:addObject(CCRotateTo:create(2/24.0, -9.2))
            array:addObject(CCRotateTo:create(3/24.0, 14.7))
            array:addObject(CCRotateTo:create(2/24.0, -11.2))
            array:addObject(CCRotateTo:create(2/24.0, 0))
            array:addObject(CCDelayTime:create(65/24.0))
            local scaleAction = CCSequence:create(array)
            discountContainerUI:runAction(CCRepeatForever:create(scaleAction))
        end

        self:playDiscountAnim()
	end

	if discountNum == 10 then
		item.discountUI:setVisible(false)
	else
		local discountNumUI = item.discountUI:getChildByName("num")
		discountNumUI:setText(discountNum)
		if not self.dx then
			self.dx = discountNumUI:getPositionX()
			self.dy = discountNumUI:getPositionY()
		end
		discountNumUI:setRotation(35)

		discountNumUI:setPositionX(self.dx +15)
		discountNumUI:setPositionY(self.dy -8)

		if discountNum == 1 then
			discountNumUI:setPositionX(self.dx +18)
			discountNumUI:setPositionY(self.dy -10)
		end

		discountNumUI:setScale(2)
		local discountTextUI = item.discountUI:getChildByName("text")
		if not self.dxx then
			self.dxx = discountTextUI:getPositionX()
			self.dyy = discountTextUI:getPositionY()
		end
		discountTextUI:setPosition(ccp(self.dxx + 5, self.dyy - 5))
		discountTextUI:setScale(1.7)
		discountTextUI:setRotation(35)
		discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))
	end
end

function GiftPackPage:setBtnState( item )
	if not GiftPack:checkPack(item.goodsId) and item.btn and not item.btn.isDisposed then
		item.btn:setEnabled(false)
		if item.btn.setDelNumber then
			item.btn:setDelNumber('')
		end
		if item.btn.setNumber then
			item.btn:setNumber('')
		end
		local infos = GiftPack:getGoodsInfo(item.goodsId)
		if infos.info and infos.info.buyCount > 0 then
			item.btn:setString('已购买')
		else
			item.btn:setString('已过期')
		end

		if item:getChildByName('zhe') then
			item:getChildByName('zhe'):setVisible(false)
		end
	end
end

function GiftPackPage:createNewerOne(goodsId, rewardGoodsId)
	local item = UIHelper:createUI('ui/MarketGiftPackPanel.json', 'MarketGiftPack/group/item_newer1')

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	local price = meta.thirdRmb / 100
	local ori_price = meta.rmb / 100
	local bg = item:getChildByName('bg2')
	local bgsize = bg:getPreferredSize()
	local marge = 10
	local w = (bgsize.width - 2*marge)/(#meta.items > 4 and 3 or 2)
	local h = (bgsize.height - 2*marge)/2
	item.goodsId = goodsId

	item.icons = {}
	for index,itemInfo in ipairs(meta.items) do
		local icon = GiftPack:createIcon(itemInfo)
        bg:addChild(icon)

        if #meta.items > 4 then
        	icon:setScale(0.45)
        else
        	icon:setScale(0.6)
        end

        local size = icon:getGroupBounds().size
        icon:setPosition(ccp(
        	w / 2 + marge + math.floor((index-1)/2)*w - 15,
        	bgsize.height - marge - h/2 - (index-1)%2*h))

        item.icons[index] = icon
	end

	--btn
	local btnui = item:getChildByName('btn')
	local btn = ButtonIconNumberBase:createNewStyle( btnui )
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:buy(item)
    	btn:setEnabled(false)
    end)
    btn:setDelNumber(string.format('￥%0.2f', ori_price))
    btn:setNumber(string.format('￥%0.2f', price))
    btn:setColorMode(kGroupButtonColorMode.blue)

    item:getChildByName('gold_less'):setVisible(price <= 6)
    item:getChildByName('gold_more'):setVisible(price > 6)

    item.btn = btn

    self:setBtnState(item)

	--saving
	local savingph = item:getChildByName('saving')
	savingph:setVisible(false)
	local snum = ori_price - price
	local saving = BitmapText:create('￥'..snum, 'fnt/timelimit_gift.fnt')
    saving:setAnchorPoint(ccp(0, 0.5))
    local savingsize = savingph:getGroupBounds().size
    local savingpos = savingph:getPosition()
    saving:setPosition(ccp(savingpos.x + 10, savingpos.y - savingsize.height/2))
    item:addChild(saving)

    local infos = GiftPack:getGoodsInfo( rewardGoodsId )
    local day = infos.config.duration / 3600 / 24 / 1000
	local tip2 = item:getChildByName('tip2')
	tip2:setString(string.format('购买后%d天内，每日登录可领', day))
	tip2:setPositionY(tip2:getPositionY() - 10)

	local tip1 = item:getChildByName('tip1')
	tip1:setString('购买立刻获得')
	tip1:setPositionY(tip1:getPositionY() - 5)

	bg = item:getChildByName('bg3')
	bgsize = bg:getPreferredSize()
	marge = 10
	w = (bgsize.width - 2*marge)/2
	h = (bgsize.height - 2*marge)/2

	meta = MetaManager.getInstance():getGoodMeta(rewardGoodsId)
	if meta then
		for index,itemInfo in ipairs(meta.items) do
			local icon = GiftPack:createIcon(itemInfo)
	        bg:addChild(icon)

	        local size = icon:getGroupBounds().size
	        icon:setPosition(ccp(
	        	w / 2 + marge + (index-1)%2*w - 20,
	        	bgsize.height - 13 - marge - h/2 - math.floor((index-1)/2)*h))
		
	        if #meta.items == 1 then
	        	icon:setScale(0.7)
	        	icon:setPosition(ccp(bgsize.width/2 - 20, bgsize.height/2))
			end
		end
	end

	return item
end

function GiftPackPage:refresh()
	for _,item in ipairs(self.items) do
		if item.isReward then

		end
	end
end

function GiftPackPage:onGetRewardSuccess(item)
	if self.isDisposed then return end
	if GiftPack:checkPack(item.goodsId) then
		local cd = BitmapText:create('1', 'fnt/register2.fnt')
		cd:setColor(ccc3(153,51,0))
		local cdph = item:getChildByName('cd')
		local cdpos = cdph:getPosition()
		local cdsize = cdph:getGroupBounds().size
		cd:setPosition(ccp(cdpos.x + cdsize.width/2, cdpos.y - cdsize.height/2))
		item:addChild(cd)
		if item.btn then
			item.btn:setVisible(false)
		end
		if item.cd and not item.cd.isDisposed then
			item.cd:removeFromParentAndCleanup(true)
		end
		item.cd = cd
		self:createCdSchedule()
		self:updatet()

		if item.left then
			local leftday = GiftPack:getLeftDay(item.goodsId)
			if leftday <= 0 then
				item.left:setVisible(false)
			end
			item.left:setString('剩余'..leftday..'天')
		end
	else
		item:getChildByName('reward_tip'):setVisible(false)
		item.btn:setEnabled(false)
		item.btn:setString('已结束')
		if item.left then
			item.left:setVisible(false)
		end

		local allexp = true
		for _,it in ipairs(self.items) do
			if GiftPack:checkPack(it.goodsId) then
				allexp = false
			end
		end
		if allexp then
			self.main_panel:onCloseBtnTapped()
		end
	end
end

function GiftPackPage:getReward( item )
	local flyCount = 0
    local flymax = #item.icons

    local meta = MetaManager.getInstance():getGoodMeta(item.goodsId)

	local bottle = table.find(meta.items, function (it)
        return it.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
    end)

    local function finished()
        flyCount = flyCount + 1
        if flyCount >= flymax then
        	if bottle then
        		GiftPack:showEnergyAlert(bottle.num, function ()
        			-- self:onGetRewardSuccess(item)
                end)
        	else
	            -- self:onGetRewardSuccess(item)
	        end
        end
    end

    local function fly( icon )
        local itemInfo = icon.itemInfo
        if itemInfo.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
            itemInfo = {itemId = itemInfo.itemId, num = 1}
        end
        local anim = FlyItemsAnimation:create({itemInfo})
        local pos = icon:getPosition()
        pos = icon:getParent():convertToWorldSpace(pos)
        local bounds = icon:getGroupBounds()
        local x,y = 0,0
        if icon == item.goldicon then
        	x = bounds.size.width / 2
        	y = - bounds.size.height / 2
        end
        anim:setWorldPosition(ccp(pos.x + x, pos.y + y))
        anim:setScaleX(icon:getScaleX())
        anim:setScaleY(icon:getScaleY())
        anim:setFinishCallback(finished)
        anim:play()
    end

	local function scb( rewards )
		for _,icon in ipairs(item.icons) do
			fly(icon)
		end
		self:onGetRewardSuccess(item)
	end

	local function onFail(err)
		if item.btn and not item.btn.isDisposed then
			item.btn:setEnabled(true)
		end

		if err == 731925 then
			item.refreshItem()
		end
	end
	GiftPack:reciveReward( item.goodsId, scb, onFail, onFail)
end

function GiftPackPage:createNewerOneReward(rewardInfo, origoodsId)
	local item = UIHelper:createUI('ui/MarketGiftPackPanel.json', 'MarketGiftPack/group/item_reward')
	item.isReward = true
	local bg = item:getChildByName('bg1')
	local bgsize = bg:getPreferredSize()
	local marge = 10
	local w = (bgsize.width - 2*marge)/2
	local h = (bgsize.height - 2*marge)/2
	local goodsId = rewardInfo.goodsId
	local info = rewardInfo.info

	local btnui = item:getChildByName('btn')
	local cdph = item:getChildByName('cd')
	cdph:setVisible(false)
	local cdsize = cdph:getGroupBounds().size
	local cdpos = cdph:getPosition()
	item.goodsId = goodsId

	item:getChildByName('reward_tip'):setVisible(info.seeCount ~= -1)

	if info.seeCount == -1 and GiftPack:checkPack(goodsId) then
		btnui:setVisible(false)

		local cd = BitmapText:create('1', 'fnt/register2.fnt')
		cd:setColor(ccc3(153,51,0))
		cd:setPosition(ccp(cdpos.x + cdsize.width/2, cdpos.y - cdsize.height/2))
		item:addChild(cd)
		item.cd = cd
		self:createCdSchedule()
	else
		local btn = GroupButtonBase:createNewStyle( btnui )
	    btn:ad(DisplayEvents.kTouchTap, function ( ... )
	    	self:getReward(item)
	    	btn:setEnabled(false)
	    end)
	    item.btn = btn
	    if not GiftPack:checkPack(goodsId) then
	    	btn:setString('已结束')
	    	btn:setEnabled(false)
	    else
		    btn:setString('领取')
		end
	end

	local leftph = item:getChildByName('left')
	leftph:setVisible(false)
	local leftsize = leftph:getGroupBounds().size
	local leftpos = leftph:getPosition()

	local start = Localhost:getTodayStart()
	local leftday = GiftPack:getLeftDay(goodsId)

	local left = TextField:create('剩余'..leftday..'天', '微软雅黑', 20)
	left:setPosition(ccp(leftpos.x + leftsize.width/2, leftpos.y - leftsize.height/2))
	left:setColor(ccc3(255, 0, 0))
	item:addChild(left)
	item.left = left

	if leftday <= 0 then
		item.left:setVisible(false)
	end

	local meta = MetaManager.getInstance():getGoodMeta(goodsId)
	item.icons = {}
	if meta then
		for index,itemInfo in ipairs(meta.items) do
			local icon = GiftPack:createIcon(itemInfo)
	        bg:addChild(icon)
	        icon:setScale(0.7)

	        table.insert(item.icons, icon)

	        local size = icon:getGroupBounds().size
	        icon:setPosition(ccp(
	        	w / 2 + marge + (index-1)%2*w - 20,
	        	bgsize.height - 25 - marge - h/2 - math.floor((index-1)/2)*h)
	        )
		
	        if #meta.items == 1 then
	        	icon:setScale(0.7)
	        	icon:setPosition(ccp(bgsize.width/2 - 20, bgsize.height/2))
			end
		end
	end

	local orimeta = MetaManager.getInstance():getGoodMeta(origoodsId)

	item.oriprice = orimeta.thirdRmb

	local titleph = item:getChildByName('title')
	titleph:setVisible(false)
	local titlepos = titleph:getPosition()
	local titlesize = titleph:getGroupBounds().size

	local day =  GiftPack:getRewardDay( goodsId )

	local title = BitmapText:create(string.format('%d元助力包奖励—第%d天', orimeta.thirdRmb/100, day), 'fnt/register2.fnt')
	title:setColor(ccc3(153,51,0))
	title:setPosition(ccp(titlepos.x + titlesize.width/2, titlepos.y - titlesize.height/2))
	item:addChild(title)

	item.refreshItem = function ()
		if left.isDisposed then return end
		local leftday = GiftPack:getLeftDay(goodsId)
		if leftday <= 0 then
			left:setVisible(false)
		end
		left:setString('剩余'..leftday..'天')

		local day =  GiftPack:getRewardDay( goodsId )
		title:setText(string.format('%d元助力包奖励—第%d天', orimeta.thirdRmb/100, day))
	end

	return item
end

function GiftPackPage:layout()
	if self.isDisposed then return end
	local newViewBg = self.main_panel.newViewBg or self.main_panel.viewBg
	local viewsize = newViewBg:getPreferredSize()
    local top_bg = self.item_top:getChildByName('bg')
    local size = top_bg:getContentSize()
    self.item_top:setPositionX((viewsize.width - size.width)/2)

    local height = 0

    table.sort( self.items, function ( a, b )
    	local ma = MetaManager.getInstance():getGoodMeta(a.goodsId)
    	local mb = MetaManager.getInstance():getGoodMeta(b.goodsId)
    	local infoa = GiftPack:getGoodsInfo(a.goodsId)
    	local infob = GiftPack:getGoodsInfo(b.goodsId)

    	local isAreward = infoa.config and infoa.config.isReward
    	local isBreward = infob.config and infob.config.isReward

    	local priceA,priceB = ma.thirdRmb, mb.thirdRmb
    	if isAreward then
    		priceA = a.oriprice
    	end

    	if isBreward then
    		priceB = b.oriprice
    	end

    	return priceA > priceB
    end )

    local marge = -80
    for index,item in ipairs(self.items) do
    	local isize = item:getGroupBounds().size
    	item:setPositionX((viewsize.width - isize.width)/2 - 10)
    	local y = size.height + (index-1)*marge + (index - 1) * isize.height
    	if index == 1 then
    		y = y - 100
    	end
    	item:setPositionY(-y)

    	height = y + isize.height
    end

    self.height = height
end

function GiftPackPage:getHeight()
    return self.height or 0
end

return GiftPackPage