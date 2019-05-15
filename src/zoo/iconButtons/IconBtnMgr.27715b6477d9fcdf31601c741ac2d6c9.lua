
IconBtnMgr = class()
local instance = nil
function IconBtnMgr.getInstance()
	if not instance then
        instance = IconBtnMgr.new()
        instance:init()
    end
    return instance
end

local LocalTriggerKey = "is_old_icon"
function IconBtnMgr:init()
	if _G.isLocalDevelopMode then
		self.showNewIcon = self:getLocalTrigger()
	else	
		self.showNewIcon = true
	end
end

function IconBtnMgr:getLocalTrigger()
	return not CCUserDefault:sharedUserDefault():getBoolForKey(LocalTriggerKey, false)
end

function IconBtnMgr:setLocalTrigger()
	CCUserDefault:sharedUserDefault():setBoolForKey(LocalTriggerKey, self.showNewIcon)
	CCUserDefault:sharedUserDefault():flush()
end

function IconBtnMgr:isNewIconShow()
	return self.showNewIcon
end

function IconBtnMgr:updateTopBarBtnPos(startPosX, endPosX, startPosY, btns)
	local posXDelta = 10
	local posYDelta = -15
	local btnNum = #btns
	local allWidth = endPosX - startPosX - posXDelta * 2
	local allBtnWith = 0
	local btnWidths = {}

	for i,v in ipairs(btns) do
		local btnSize = v:getGroupSize()
		allBtnWith = allBtnWith + btnSize.width
		btnWidths[i] = btnSize.width
	end

	local gap = 0
	local gapNum = btnNum - 1
	if gapNum > 0 then
		gap = (allWidth - allBtnWith) / gapNum 
	end 
	gap = math.min(gap, 50)
	
	local halfBtnNum = btnNum / 2
	local btnPosXLtoR = {}
	for i=1, halfBtnNum do
		if i == 1 then
			btnPosXLtoR[i] = posXDelta + startPosX
		else
			local lastBtnPosX = btnPosXLtoR[i-1]
			local lastBtnWidth = btnWidths[i-1]
			btnPosXLtoR[i] = lastBtnPosX + lastBtnWidth + gap
		end
		btns[i]:setPosition(ccp(btnPosXLtoR[i], startPosY + posYDelta))
	end

	local btnPosXRtoL = {}
	for i=btnNum, halfBtnNum + 1, -1 do
		local thisBtnWidth = btnWidths[i]
		if i == btnNum then
			btnPosXRtoL[i] = endPosX - posXDelta - thisBtnWidth
		else
			local lastBtnPosX = btnPosXRtoL[i+1]
			btnPosXRtoL[i] = lastBtnPosX - thisBtnWidth - gap
		end
		btns[i]:setPosition(ccp(btnPosXRtoL[i], startPosY + posYDelta))
	end
end