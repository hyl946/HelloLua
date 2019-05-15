local Quest = require 'zoo.quest.Quest'

local QIPickFruit = class(Quest)

function QIPickFruit:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPickFruit, self.onPickFruit)
end

function QIPickFruit:onPickFruit( event )
	self.data.num = self.data.num + 1
	self.data.num = math.min(self.data.num, self.data.relTarget)	
	self:afterUpdate()
	self:checkFinish()
end

function QIPickFruit:doAction( ... )
	local fruitTreeBtn = HomeScene:sharedInstance().fruitTreeBtn
	if fruitTreeBtn then
		fruitTreeBtn.wrapper:dp(DisplayEvent.new(DisplayEvents.kTouchTap, {}, ccp(0, 0)))
		return true
	end


	local hiddenFruitTreeBtn = HomeScene:sharedInstance().hiddenFruitTreeBtn
	if hiddenFruitTreeBtn then
		hiddenFruitTreeBtn.wrapper:dp(DisplayEvent.new(DisplayEvents.kTouchTap, {}, ccp(0, 0)))
		return true
	end
	
	return false
end

function QIPickFruit:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/40000')
	icon:setScale(0.8)
	return icon
end



return QIPickFruit