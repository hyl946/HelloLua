---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-11-15 11:00:51
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-11-15 15:58:03
---------------------------------------------------------------------------------------
local Panel = class(CocosObject)

local kTimePerFrame = 1 / 30

function Panel:create(firendId, name, headUrl)
	local panel = Panel.new(CCNode:create())
	return panel:init(firendId, name, headUrl)
end

function Panel:init(firendId, name, headUrl)
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/weekly_ingame_2016S4.json")
	if builder then
		local ui = builder:buildGroup("weekly_2016s4/pass_friend_tip")
		self.builder = builder
		self.ui = ui
		self.ui:setVisible(false)
		self:addChild(ui)

		local header = self.ui:getChildByName("header")
		local ph = header:getChildByName("ph")
		local phGb = ph:getGroupBounds(header)
		local posX, posY = phGb.origin.x, phGb.origin.y
		local width, height = phGb.size.width, phGb.size.height
		local phZOrder = ph:getZOrder()
		ph:removeFromParentAndCleanup(true)

		local function onImageLoadFinishCallback(clipping)
			if not header or header.isDisposed then return end
			local clippingSize = clipping:getContentSize()
            local scale = width/clippingSize.width
            clipping:setScale(scale)
            clipping:setPosition(ccp(posX+width/2,posY+height/2))
            header:addChildAt(clipping, phZOrder)
		end
		HeadImageLoader:create(friendId, headUrl, onImageLoadFinishCallback)

		if not name or string.len(name) < 1 then
			name = "ID:"..tostring(firendId)
		end
		local nameLabel = self.ui:getChildByName("name")
		local displayName = TextUtil:ensureTextWidth( name, nameLabel:getFontSize(), CCSizeMake(65, 0), "")
		if displayName and string.len(displayName) < string.len(name) then
			local remainStr = string.sub(name, string.len(displayName)+1)
			local line2 = TextUtil:ensureTextWidth(remainStr, nameLabel:getFontSize(), CCSizeMake(60, 0), "...")
			displayName = displayName.."\n"..line2
		else
			nameLabel:setPositionY(nameLabel:getPositionY() - 10)
		end
		if displayName and string.len(displayName)>0 then
			nameLabel:setString(displayName)
		end
	else
		return nil
	end
	return self
end

function Panel:show(delay, duration, onDismissCallback)
	self.ui:setScale(0.356)

	duration = duration or 1.5

	local actionSeq = CCArray:create()
	if delay and delay > 0 then
		actionSeq:addObject(CCDelayTime:create(delay))
	end
	actionSeq:addObject(CCShow:create())
	actionSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(kTimePerFrame*7, ccp(30, 0)), CCScaleTo:create(kTimePerFrame*7, 1.10)))
	actionSeq:addObject(CCScaleTo:create(kTimePerFrame*3, 1))
	actionSeq:addObject(CCDelayTime:create(duration))
	local function callDismiss()
		self:dismiss(onDismissCallback)
	end
	actionSeq:addObject(CCCallFunc:create(callDismiss))
	self.ui:runAction(CCSequence:create(actionSeq))	
end

function Panel:dismiss(onDismissCallback)
	local function onDismissed()
		if onDismissCallback then onDismissCallback() end
	end
	if self.ui and not self.ui.isDisposed then
		local actionSeq = CCArray:create()
		actionSeq:addObject(CCFadeOut:create(kTimePerFrame*3))
		actionSeq:addObject(CCHide:create())
		actionSeq:addObject(CCCallFunc:create(onDismissed))
		
		local bg = self.ui:getChildByName("bg")
		if bg then
			bg:runAction(CCSequence:create(actionSeq))		
		else
			self.ui:runAction(CCSequence:create(actionSeq))		
		end
	else
		onDismissed()
	end
end

return Panel