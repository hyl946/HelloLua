local UIHelper = require 'zoo.panel.UIHelper'

local EndGamePropGoodsPlate = class()

function EndGamePropGoodsPlate.createPlate(panel, goodsPackID, useHappyCoin, tapCallBack)
	-- printx(11, "EndGamePropGoodsPlate.createPlate", goodsPackID)

	local plateAssetName = "newAddStepPanel_newDrak_new_goodsPlate"
	if goodsPackID == 612 then
		plateAssetName = plateAssetName.."2"
	end
	-- printx(11, ".. plateAssetName", plateAssetName)

	local ui = panel:buildInterfaceGroup(plateAssetName)
	if not ui then
		UIHelper:loadJson('ui/panel_add_step.json')
		ui = UIHelper:getBuilder('ui/panel_add_step.json'):buildGroup(plateAssetName)
		UIHelper:unloadJson('ui/panel_add_step.json')
	end

	if not ui then
		return nil
	end

    ui = UIHelper:replaceLayer2LayerColor(ui,true)
	UIHelper:setCascadeOpacityEnabled(ui)

	ui.buyCallBack = tapCallBack

	local goodsData = MetaManager.getInstance():getGoodMeta(goodsPackID)
	assert(goodsData)

	local goodsNumSize = ui:getChildByName("goodsNum")
	goodsNumSize:setVisible(false)
	local goodsItems = goodsData.items
	if goodsData and goodsData.items and goodsData.items[1] then
		local item = goodsData.items[1]
		local pos2 = goodsNumSize:getPosition()
		local size2 = goodsNumSize:getContentSize()
		local goodsNumLabel = BitmapText:create("x"..item.num, "fnt/jiawubuceshi.fnt")
		goodsNumLabel:setScale(1.3)
		goodsNumLabel:setPosition(ccp(pos2.x + size2.width/2, pos2.y - size2.height/2 - 5))
		local goodsNumIndex = ui:getChildIndex(goodsNumSize)
		ui:addChildAt(goodsNumLabel, goodsNumIndex)
	end
	local goodsNumSize2 = ui:getChildByName("goodsNum2")
	if goodsNumSize2 then
		goodsNumSize2:setVisible(false)
		local pos3 = goodsNumSize2:getPosition()
		local size3 = goodsNumSize2:getContentSize()
		local goodsNumLabel2 = BitmapText:create("x1", "fnt/jiawubuceshi.fnt")
		goodsNumLabel2:setScale(1.1)
		goodsNumLabel2:setPosition(ccp(pos3.x + size3.width/2, pos3.y - size3.height/2 - 5))
		local goodsNumIndex2 = ui:getChildIndex(goodsNumSize2)
		ui:addChildAt(goodsNumLabel2, goodsNumIndex2)
	end

	local ownHPCoinPlate = ui:getChildByName("goodsPlateOwnHPCoin")

	local hpCoinBuyButtonUI = ui:getChildByName("hpCoinBuyButton")
    local hpCoinBuyButton = ButtonIconsetBase:createNewStyle(hpCoinBuyButtonUI)
    hpCoinBuyButton:setIconByFrameName("common_icon/item/icon_coin_small0000")
    hpCoinBuyButton:setColorMode(kGroupButtonColorMode.blue)
    hpCoinBuyButton:addEventListener(DisplayEvents.kTouchTap, function ()
        hpCoinBuyButton:setEnabled(false)
		if ui.buyCallBack and type(ui.buyCallBack) == 'function' then
			ui.buyCallBack()
		end
    end)

    local cashBuyButtonUI = ui:getChildByName("cashBuyButton")
    local cashBuyButton = GroupButtonBase:createNewStyle(cashBuyButtonUI)
	cashBuyButton:setColorMode(kGroupButtonColorMode.blue)
    cashBuyButton:addEventListener(DisplayEvents.kTouchTap, function ()
        cashBuyButton:setEnabled(false)
	    if ui.buyCallBack and type(ui.buyCallBack) == 'function' then
			ui.buyCallBack()
		end
    end)

	local discountPop = ui:getChildByName("discountPop")

	-- 初始化完成，存储一些可能需要刷新的内容
	ui.dynamicContent = {}
	ui.dynamicContent.ownHPCoinPlate = ownHPCoinPlate
	ui.dynamicContent.hpCoinBuyButton = hpCoinBuyButton
	ui.dynamicContent.cashBuyButton = cashBuyButton
	ui.dynamicContent.discountPop = discountPop

	EndGamePropGoodsPlate.refreshPlateView(ui, useHappyCoin, goodsPackID)
	return ui
end

function EndGamePropGoodsPlate.refreshPlateView(ui, useHappyCoin, goodsPackID)
	if not ui or ui.isDisposed then return end

	local ownHPCoinPlate = ui.dynamicContent.ownHPCoinPlate
	local hpCoinBuyButton = ui.dynamicContent.hpCoinBuyButton
	local cashBuyButton = ui.dynamicContent.cashBuyButton
	local discountPop = ui.dynamicContent.discountPop

	if not ownHPCoinPlate 
		or not hpCoinBuyButton 
		or not cashBuyButton 
		then
		return
	end

	local goodsData = MetaManager.getInstance():getGoodMeta(goodsPackID)
	assert(goodsData)

	local oldPriceStr
	local disCountRate
	if useHappyCoin then
		assert(goodsData.qCash > 0)

		local price = goodsData.qCash
		disCountRate = 1
		if goodsData.discountQCash > 0 then
			price = goodsData.discountQCash
			disCountRate = goodsData.discountQCash / goodsData.qCash
		end

		cashBuyButton:setVisible(false)
		hpCoinBuyButton:setVisible(true)
		ownHPCoinPlate:setVisible(true)
		if ui:getChildByName("oldPriceHpCoin") then
			ui:getChildByName("oldPriceHpCoin"):setVisible(true)
		end

		hpCoinBuyButton:setString(""..price)

		if ui.dynamicContent.ownNumLabel then
			local formerOwnNumLabel = ui.dynamicContent.ownNumLabel
			formerOwnNumLabel:removeFromParentAndCleanup(true)
			ui.dynamicContent.ownNumLabel = nil
		end
		local ownHPCoinNum = UserManager:getInstance().user:getCash()
		local ownNumSize = ownHPCoinPlate:getChildByName("goldNum")
		if ownNumSize then
			ownNumSize:setVisible(false)
			local pos3 = ownNumSize:getPosition()
			local size3 = ownNumSize:getContentSize()
			local ownNumLabel = BitmapText:create(""..ownHPCoinNum, "fnt/mark_tip.fnt")
			ownNumLabel:setScale(0.9)
			ownNumLabel:setAnchorPoint(ccp(0, 1))
			ownNumLabel:setPosition(ccp(pos3.x, pos3.y - 4))
			local ownNumIndex = ownHPCoinPlate:getChildIndex(ownNumSize)
			ownHPCoinPlate:addChildAt(ownNumLabel, ownNumIndex + 1)
			ui.dynamicContent.ownNumLabel = ownNumLabel --BitmapText
		end

		oldPriceStr = ""..goodsData.qCash
	else
		assert(goodsData.discountRmb > 0)
		assert(goodsData.rmb > 0)

		cashBuyButton:setVisible(true)
		hpCoinBuyButton:setVisible(false)
		ownHPCoinPlate:setVisible(false)
		if ui:getChildByName("oldPriceHpCoin") then
			ui:getChildByName("oldPriceHpCoin"):setVisible(false)
		end

		cashBuyButton:setString(string.format('￥%0.2f', goodsData.discountRmb / 100))

		-- oldPriceStr = string.format('%0.2f', goodsData.rmb)
		oldPriceStr = goodsData.rmb / 100
		disCountRate = goodsData.discountRmb / goodsData.rmb
	end

	if ui.dynamicContent.oldPriceLabel then
		local formerOldPriceLabel = ui.dynamicContent.oldPriceLabel
		formerOldPriceLabel:removeFromParentAndCleanup(true)
		ui.dynamicContent.oldPriceLabel = nil
	end
	local oldPriceSize = ui:getChildByName("oldPrice")
	if oldPriceSize then
	    oldPriceSize:setVisible(false)
		local pos = oldPriceSize:getPosition()
		local size = oldPriceSize:getContentSize()
		local oldPriceLabel = BitmapText:create(oldPriceStr, "fnt/mark_tip.fnt")
		oldPriceLabel:setScale(1.3)
		oldPriceLabel:setAnchorPoint(ccp(0, 1))
		oldPriceLabel:setPosition(ccp(pos.x, pos.y - 1))
		local oldPriceIndex = ui:getChildIndex(oldPriceSize)
		ui:addChildAt(oldPriceLabel, oldPriceIndex)
		ui.dynamicContent.oldPriceLabel = oldPriceLabel --BitmapText
	end
	
	if discountPop then
		-- 因为计费点不是整数折扣，所以RMB情况下不显示折扣Pop
		if not useHappyCoin then
			discountPop:setVisible(false)
		else
			-- calculate discount rate
			disCountRate = disCountRate * 10
			local displayRateNum
			local tailNum = disCountRate - math.floor(disCountRate)
			if tailNum >= 0.5 then
				displayRateNum = math.ceil(disCountRate)
			else
				displayRateNum = math.floor(disCountRate)
			end

			for i = 1, 9 do
				local discountNumView = discountPop:getChildByName("num_"..i)
				if i == displayRateNum then
					discountNumView:setVisible(true)
				else
					discountNumView:setVisible(false)
				end
			end
		end
	end
end

function EndGamePropGoodsPlate.reEnableBtn(ui)
	if ui and ui.dynamicContent and not ui.isDisposed then
		if ui.dynamicContent.hpCoinBuyButton then
			ui.dynamicContent.hpCoinBuyButton:setEnabled(true)
		end

		if ui.dynamicContent.cashBuyButton then
			ui.dynamicContent.cashBuyButton:setEnabled(true)
		end
	end
end

return EndGamePropGoodsPlate
