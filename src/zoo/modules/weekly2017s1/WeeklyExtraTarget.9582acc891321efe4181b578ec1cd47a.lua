local WeeklyExtraTarget = class(BaseUI)
-- targetInfo = {
-- 	itemNum = 10,
-- }
function WeeklyExtraTarget:create(targetInfo)
	local target = WeeklyExtraTarget.new()
	target.targetInfo = targetInfo
	target:init()
	return target
end

function WeeklyExtraTarget:init()
	self.ui = ResourceManager:sharedInstance():buildGroup("2017_weekly_s2_target/weekly_extra_target")
	BaseUI.init(self, self.ui)

   	self.need_dispose = {}

	self.targetDecoration = ArmatureNode:create('2018_s1_target_anim/ani_extra_target')
	self.targetDecoration:update(0.001)

	local bubbleIndex = self.ui:getChildIndex(self.ui:getChildByName("bubble"))
	self.ui:addChildAt(self.targetDecoration, bubbleIndex)
	self.targetDecoration:setPosition(ccp(-20, -25))
	self.targetDecoration:playByIndex(0, 0)

	--label
	local fntFile	= "fnt/target_amount.fnt"
	local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentRight)
	text:setText(self.targetInfo.itemNum)
	text:setAnchorPoint(ccp(0.5, 0))
	if self.targetInfo.itemNum >=100 then 
		text:setScale(0.85)
		text:setPositionY(4)
	end
	text:setPositionX(54/2+1)
	table.insert(self.need_dispose, text)
	self.targetDecoration:getCon('label'):addChild(text.refCocosObj)
	
	--bubble tip
	self.canShowBubble = true
	self.bubbleUI = self.ui:getChildByName("bubble")
	local bubbleLabel = self.bubbleUI:getChildByName("label")
	local bubbleBg = self.bubbleUI:getChildByName("bg")
	-- if self.targetInfo.isGlobal then
	-- 	if self.targetInfo.globalRank > 0 then 
	-- 		bubbleLabel:setString(localize("2017_weeklyrace.summer.quanguo.tip", {num=self.targetInfo.globalRank}))
	-- 	else
	-- 		self.canShowBubble = false
	-- 	end
	-- else
		bubbleLabel:setString(localize("2017_weeklyrace.summer.key.tip"))
	-- end 

	bubbleLabel:setOpacity(0)
	bubbleBg:setOpacity(0)
	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, function ()
		if self.canShowBubble then 
			self.canShowBubble = false
			local parent = self:getParent()
			if parent then 
				parent:addChild(self.bubbleUI)
				local pos = self:getPosition()
				if self.bubbleUI then 
					self.bubbleUI:setPosition(ccp(pos.x, pos.y))
				end
				local arr1 = CCArray:create()
				arr1:addObject(CCFadeTo:create(0.5, 255))
				arr1:addObject(CCDelayTime:create(2))
				arr1:addObject(CCFadeTo:create(0.5, 0))
				bubbleLabel:stopAllActions()
				bubbleLabel:runAction(CCSequence:create(arr1))

				local arr2 = CCArray:create()
				arr2:addObject(CCFadeTo:create(0.5, 255))
				arr2:addObject(CCDelayTime:create(2))
				arr2:addObject(CCFadeTo:create(0.5, 0)) 
				arr2:addObject(CCCallFunc:create(function ()
					if self.bubbleUI then 
						self.bubbleUI:removeFromParentAndCleanup(false)
					end
					self.canShowBubble = true
				end))
				bubbleBg:runAction(CCSequence:create(arr2))
			end
		end
	end)
	self.bubbleUI:removeFromParentAndCleanup(false)
end

function WeeklyExtraTarget:dispose()
	BaseUI.dispose(self)
	for _, head in ipairs(self.need_dispose or {}) do
		head:dispose()
	end
	if self.bubbleUI and not self.bubbleUI.isDisposed then
		self.bubbleUI:dispose()
	end
end

function WeeklyExtraTarget:getTargetNum()
	return self.targetInfo.itemNum or 0
end

function WeeklyExtraTarget:setBubbleTipVisible(isVisible)
	if self.bubbleUI then 
		self.bubbleUI:setVisible(isVisible)
	end
	if isVisible == false then 
		self.ui:setTouchEnabled(false)
	end
end

function WeeklyExtraTarget:playAnim()
	self.targetDecoration:playByIndex(0, 0)
end

return WeeklyExtraTarget



