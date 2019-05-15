
WeeklyMoveOrTimeCounter = class(MoveOrTimeCounter)

function WeeklyMoveOrTimeCounter:create(panelStyle, levelId, counterType, count)
	local newCounter = WeeklyMoveOrTimeCounter.new()
	newCounter:init(panelStyle, levelId, counterType, count)
	return newCounter
end

function WeeklyMoveOrTimeCounter:init(panelStyle, levelId, counterType, count)
	self.oldString = ''
	self.ui = ResourceManager:sharedInstance():buildGroup(panelStyle)
	local function onTouchBegin(evt) 
		self:shake()
	end
	local uisize = self.ui:getGroupBounds().size
	local uipos = self.ui:getPosition()
	self.ui:setPosition(ccp(uipos.x-uisize.width/2, uipos.y))
	self.ui:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.ui:setTouchEnabled(true)
	BaseUI.init(self, self.ui)
	self.msgLabel = self.ui:getChildByName("msgLabel")
	self.msgLabel:setVisible(false)
	self.bgHighlight = self.ui:getChildByName("bgHighlight")
	if self.bgHighlight then
		self.bgHighlight:setVisible(false)
	end
	self.bg = self.ui:getChildByName('bg')

	self.counterType = counterType
	self.count = count
	self.levelId = levelId
	self.fntFile = "fnt/steps_cd.fnt"

	self.label = nil
	if self.counterType == MoveOrTimeCounterType.MOVE_COUNT then
		self.label	= LabelBMMonospaceFont:create(60, 70, 36, self.fntFile)
		self.label:setPositionY(-22)
	else
		assert(false)
	end

	self.label.setToParentCenterHorizontal = function (context)
		local parentSize = self.bg:getGroupBounds().size
		local selfSize = context:getGroupBounds().size
		local deltaWidth = parentSize.width - selfSize.width
		local halfDeltaWidth = deltaWidth / 2
		local oldAnchorPoint = context:getAnchorPoint()
		context:setAnchorPointWhileStayOriginalPosition(ccp(0,0))
		context:setPositionX(halfDeltaWidth)
		context:setAnchorPointWhileStayOriginalPosition(ccp(oldAnchorPoint.x, oldAnchorPoint.y))
	end

	self.ui:addChild(self.label)
	self.label:setAnchorPoint(ccp(0,1))

	if self.counterType == MoveOrTimeCounterType.MOVE_COUNT then
		if LevelMapManager:getInstance():getLevelGameMode(self.levelId) == GameModeTypeId.RABBIT_WEEKLY_ID then
			self:setStageNumber(1)
			self:setCount(self.count)
		else
			local msgLabelTxtKey 	= "move.or.time.counter.step.txt"
			local msgLabelTxtValue	= Localization:getInstance():getText(msgLabelTxtKey, {})
			self.msgLabel:setString(msgLabelTxtValue)
			self:setCount(self.count)
		end
	end
end
