

SummerFishMoveCounter = class(MoveOrTimeCounter)

function SummerFishMoveCounter:create( panelStyle, levelId, counterType, count )
	local counter = SummerFishMoveCounter.new()
	counter:init(panelStyle, levelId, counterType, count)
	return counter
end

function SummerFishMoveCounter:init(panelStyle, levelId, counterType, count)
	self.oldString = ''

	-- Get UI Resource
--	self.ui = Layer:create()
	
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(
	-- 	SpriteUtil:getRealResourceName("flash/spring2017/in_game.plist")
	-- )

    self.ui = ResourceManager:sharedInstance():buildGroup(panelStyle)

--	self.bg = Sprite:createWithSpriteFrameName("nationday2017_movecounter_bg")
--	self.bg:setAnchorPoint(ccp(0,1))
--	-- self.bg:setPositionX(-self.bg:getContentSize().width/2)
--	self.bg:setPositionY(-30)
--	self.ui:addChild(self.bg)

	local function onTouchBegin(evt) 
		self:shake()
	end
	local uisize = self.ui:getGroupBounds().size
	local uipos = self.ui:getPosition()
	self.ui:setPosition(ccp(uipos.x-uisize.width/2, uipos.y))
	self.ui:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.ui:setTouchEnabled(true)

	-- Init Base Class
	BaseUI.init(self, self.ui)


	self.counterType	= counterType
	self.count		= count
	self.levelId		= levelId
	self.fntFile		= "fnt/summer18_steps_cd.fnt"
	
	-- Center MonospaceBMLabel
	self.label	= LabelBMMonospaceFont:create(60, 70, 36, self.fntFile)
    self.label:setAnchorPoint(ccp(0,1))
    self.label:setPositionX( 23/0.7)
	self.label:setPositionY(- 17/0.7)

    local bgWidth = 190
	function self.label:setToParentCenterHorizontal( ... )
		local labelWidth = self:getContentSize().width
		self:setPositionX(bgWidth/2 - labelWidth/2 - 10 )
	end

	self.ui:addChild(self.label)
	self:setCount(self.count)
end


function SummerFishMoveCounter:setStageNumber(stageNumber)

end

function SummerFishMoveCounter:shake()
    self:stopAllActions()
    self:setRotation(0)
    return true
end

function SummerFishMoveCounter:stopShaking()
	self.isShaking = false
end