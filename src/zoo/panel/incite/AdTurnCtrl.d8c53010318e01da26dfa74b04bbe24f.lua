--[[
 * AdTurnCtrl
 * @date    2018-09-04 17:02:26
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
local TurnCtrl = require 'zoo.quarterlyRankRace.view.TurnCtrl'
AdTurnCtrl = class(TurnCtrl)

local function SetEnabled(btn, isEnabled, notChangeColor)
	if btn.isEnabled ~= isEnabled then
		btn.isEnabled = isEnabled

		if isEnabled then
			btn:clearAdjustColorShader()
		else
			btn:applyAdjustColorShader()
			btn:adjustColor(0,-1, 0, 0)
		end
	end
end

function AdTurnCtrl:setEnabled(enabled)
	self.enabled = enabled

	SetEnabled(self.ui:getChildByPath('startBtn'), enabled)
	self:refreshLight()

	if not self.numTip then
		self.numTip = getRedNumTip()
  	 	self.numTip:setPositionXY(148, 140)
  	 	self.numTip:setNum(1)
  	 	self.ui:getChildByPath('startBtn'):addChild(self.numTip)
  	end
  	self.numTip:setVisible(enabled)

  	if enabled and not self.timeoutId then
	  	self.timeoutId = setTimeOut(function ()
	  		self:showHand()
	  		self.timeoutId = nil
	  	end, 10)
	end

	if not enabled and self.timeoutId then
		cancelTimeOut(self.timeoutId)
		self.timeoutId = nil
	end
end

function AdTurnCtrl:autoStart()
	if self.isBusy then
		return
	end

	if self.timeoutId then
		cancelTimeOut(self.timeoutId)
		self.timeoutId = nil
	end

	if self.enabled == true then
		local p1 = ccp(0, 100)
		local p2 = ccp(180, 100)
		local p3 = ccp(360, 100)

		p1 = self.ui:convertToWorldSpace(p1)
		p2 = self.ui:convertToWorldSpace(p2)
		p3 = self.ui:convertToWorldSpace(p3)

		self:onTouchBegin({globalPosition = p1})
		self:onTouchMove({globalPosition = p2})
		self:onTouchEnd({globalPosition = p3}, true)

		DcUtil:adsIOSClick({
			sub_category = "rotate",
			entry = InciteManager.entranceType,
			adver = InciteManager.readyAd,
		})
	else
		CommonTip:showTip(localize("watch_ad_btn_no_playad"), "negative")
	end
end

function AdTurnCtrl:showHand()
	if self.ui.isDisposed then return end

	local pos = ccp(400, -580)

    local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
    local layer = Layer:create()
    hand:setPosition(pos)
    layer:addChild(hand)
    self.ui:getParent():addChild(layer)

    local function onTouchCurrentLayer(eventType, x, y)
        if layer and (not layer.isDisposed) then
            layer:removeFromParentAndCleanup(true)
        end
    end
    layer:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    layer.refCocosObj:setTouchEnabled(true)

    self.handLayer = layer
end

function AdTurnCtrl:onDragEnd(speed)
	self:playCostAnim()

	local function onSuccess(index, itemId, num)
		if self.ui.isDisposed then return end
		self:setTargetAngle(45 * (index - 1), 20)
		self.rewardItem = {
			itemId = itemId,
			num = num,
		}
		self:calcStopping(speed)
	end

	local function onFail(event)
		if self.ui.isDisposed then return end

		local err = event and tonumber(event.data)
		if err == 731239 or err == 731240 then
			CommonTip:showTip(localize("error.tip."..tostring(err)), "negative")
		else
			CommonTip:showTip("网络出现问题了哦~再试试吧~", "negative")
		end

		self:setTargetAngle(22.5, 0)
		self:notCalcStopping(speed * 8, true)
	end
	
	local function onCancel()
		if self.ui.isDisposed then return end
		self:setTargetAngle(22.5, 0)
		self:notCalcStopping(speed* 4, true)
	end
	
	self.isBusy = true
	self:setEnabled(false)

	self:stayRotate(speed)

	self:sendRewardHttp(onSuccess, onFail, onCancel)
end

function AdTurnCtrl:onTurnFinish()
	if self.ui.isDisposed then
		return
	end

	local rewardItem = self.rewardItem

	local done = function ()
		if self.ui.isDisposed then
			return
		end

		self.isBusy = false
		self:refresh()
		self:refreshLight()
	end

	if rewardItem and self.adPanel then
		self.adPanel:createRewardPanel(rewardItem, done)
	else
		done()
	end
end

return AdTurnCtrl