LadybugFourStarAnimation = class(CocosObject)

LadyBugFourStarAnimationType = {
	kWithBtn = 1,
	kWithoutBtn = 2,
	kScaleWithoutBtn = 3
}
local function createTip( builder, str,animationType, finishCallback)
	-- body
	local function onBtnTap( evt )
		-- body
		if finishCallback then
			finishCallback()
		end
	end
	local ui = builder:buildGroup("Ladybug_dialogue")
	local dot_1 = ui:getChildByName("dot_for_tip_1")
	local dot_2 = ui:getChildByName("dot_for_tip_2")
	local dot_3 = ui:getChildByName("dot_for_tip_3")

	local txt = dot_3:getChildByName("txt"):setString(str)
	local btn_txt = dot_3:getChildByName("btn_txt")
	txt:setVisible(false)
	btn_txt:setVisible(false)
	if animationType == LadyBugFourStarAnimationType.kWithBtn then
		btn_txt:setVisible(true)
		ui.btn = GroupButtonBase:create(btn_txt:getChildByName("btn"))
		ui.btn:addEventListener(DisplayEvents.kTouchTap, onBtnTap)
		ui.btn:setString(Localization:getInstance():getText("fourstar_see_see"))
		btn_txt:getChildByName("txt"):setString(str)
		dot_3:getChildByName("bg_small"):setVisible(false)
	elseif animationType == LadyBugFourStarAnimationType.kWithoutBtn then
		txt:setVisible(true)
		txt:setString(str)
		dot_3:getChildByName("bg_small"):setVisible(false)
	elseif animationType == LadyBugFourStarAnimationType.kScaleWithoutBtn then
		txt:setVisible(true)
		txt:setString(str)
		dot_3:getChildByName("bg"):setVisible(false)
		-- ui:setScale(0.6)

	end

	ui.visible = false
	dot_1:setVisible(false)
	dot_2:setVisible(false)
	dot_3:setVisible(false)

	ui.setVisible = function( self, value )
		-- body
		if value == ui.visible then
			return 
		end

		ui.visible = value
		local function func_1( ... )
			-- body
			dot_1:setVisible(value)
		end
		local function func_2( ... )
			-- body
			dot_2:setVisible(value)
		end
		local function func_3( ... )
			-- body
			dot_3:setVisible(value)
		end
		local arr = CCArray:create()
		arr:addObject(CCCallFunc:create(func_1))
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(func_2))
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(func_3))

		ui:runAction(CCSequence:create(arr))
	end

	local function onUITap( ... )
		-- body
		if ui.visible == true then
			ui:setVisible(false)
		end
	end 
	ui:setTouchEnabled(true, 0, false)
	ui:addEventListener(DisplayEvents.kTouchTap, onUITap)

	return ui
end

------------------------
--toPos 最终停的位置
--r     飞的半径
--finishCallback 需要回调
--animationType 类型
--txt tip显示的内容
-------------------
function LadybugFourStarAnimation:create(toPos, r, animationType, txt, finishCallback)
	
	local s = LadybugFourStarAnimation.new(CCNode:create())
	s:init(toPos, r, animationType, txt, finishCallback)
	return s
end

function LadybugFourStarAnimation:init( toPos, r, animationType, txt, finishCallback)
	self.builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.four_star_guid)

	local tip = createTip(self.builder, txt,animationType, finishCallback)
	self:addChild(tip)
	self.tip = tip

	local ladybug_layer = Layer:create()
	local sprite = Sprite:createWithSpriteFrameName("ladybug_fly_0000")
	local frames = SpriteUtil:buildFrames("ladybug_fly_%04d", 0 , 2)
	local animate = SpriteUtil:buildAnimate(frames, 1/30)
	sprite:play(animate)
	ladybug_layer:addChild(sprite)
	self.ladybug_layer = ladybug_layer
	self:addChild(ladybug_layer)
	self.ladybug = sprite
	self:setPosition(toPos)
	self:addActionFly(toPos, r)
end

function LadybugFourStarAnimation:addActionFly(toPos, r)
	local fromePos = ccp(toPos.x - r, toPos.y)
	self:setPosition(fromePos)

	local timeTotal = 1.6
	local pos_to_1 = ccp(toPos.x + r, toPos.y)

	local bezierConfig_1 = ccBezierConfig:new() 
	bezierConfig_1.controlPoint_1 = ccp(fromePos.x + r/2, fromePos.y +  r * math.sin(math.pi/3))
	bezierConfig_1.controlPoint_2 = ccp(fromePos.x + 3 * r/2, fromePos.y + r * math.sin(math.pi/3))
	bezierConfig_1.endPosition = pos_to_1
	local bezierAction_1 = CCBezierTo:create(2*timeTotal/3, bezierConfig_1)
	local rotation_1 = CCRotateTo:create(2*timeTotal/3, 180)

	local pos_to_2 = ccp(toPos.x, toPos.y)
	local bezierConfig_2 = ccBezierConfig:new()
	bezierConfig_2.controlPoint_1 = ccp(toPos.x + r + r/5 , toPos.y - r/2 * math.sin(math.pi/3))
	bezierConfig_2.controlPoint_2 = ccp(toPos.x , toPos.y - r* math.sin(math.pi/3))
	bezierConfig_2.endPosition = pos_to_2
	local bezierAction_2 = CCBezierTo:create(timeTotal/3, bezierConfig_2)
	local rotation_2 = CCRotateTo:create(timeTotal/3, 300)

	local function onTap( ... )
		-- body
		if self.tip then
			self.tip:setVisible( not self.tip.visible)
		end
	end

	local function flyFinish( ... )
		-- body
		self.ladybug_layer:stopAllActions()
		self.ladybug:stopAllActions()
		local frames = SpriteUtil:buildFrames("ladybug_wait_%04d", 0 , 60)
		local animate = SpriteUtil:buildAnimate(frames, 1/30)
		self.ladybug:play(animate)
		self.ladybug_layer:setTouchEnabled(true, 0, true)
		self.ladybug_layer:addEventListener(DisplayEvents.kTouchTap, onTap)
		onTap()
	end
	local arr = CCArray:create()
	arr:addObject(bezierAction_1)
	arr:addObject(bezierAction_2)
	arr:addObject(CCCallFunc:create(flyFinish))
	self:runAction(CCSequence:create(arr))

	local arr_2 = CCArray:create()
	arr_2:addObject(rotation_1)
	arr_2:addObject(rotation_2)
	self.ladybug_layer:runAction(CCSequence:create(arr_2))
end



LadybugFourStarAnimationInLevelNode = class(LadybugFourStarAnimation)

function LadybugFourStarAnimationInLevelNode:create( toPos, r, animationType, txt, flyAwayCallback )
	-- body
	local s = LadybugFourStarAnimationInLevelNode.new(CCNode:create())
	s:init(toPos, r, animationType, txt, nil)
	s.flyAwayCallback = flyAwayCallback
	return s
end

function LadybugFourStarAnimationInLevelNode:addActionFly( toPos, r )
	-- body
	local fromePos = ccp(toPos.x - r, toPos.y)
	self:setPosition(fromePos)

	local timeTotal = 2
	local pos_to_1 = ccp(toPos.x + r, toPos.y)

	local bezierConfig_1 = ccBezierConfig:new() 
	bezierConfig_1.controlPoint_1 = ccp(fromePos.x + r/2, fromePos.y +  r * math.sin(math.pi/3))
	bezierConfig_1.controlPoint_2 = ccp(fromePos.x + 3 * r/2, fromePos.y + r * math.sin(math.pi/3))
	bezierConfig_1.endPosition = pos_to_1
	local bezierAction_1 = CCBezierTo:create(2*timeTotal/3, bezierConfig_1)
	local rotation_1 = CCRotateTo:create(2*timeTotal/3, 180)

	local pos_to_2 = ccp(toPos.x, toPos.y)
	local bezierConfig_2 = ccBezierConfig:new()
	bezierConfig_2.controlPoint_1 = ccp(toPos.x + 3*r/4, toPos.y - r/2 * math.sin(math.pi/3))
	bezierConfig_2.controlPoint_2 = ccp(toPos.x + 1/4 , toPos.y - r/2 * math.sin(math.pi/3))
	bezierConfig_2.endPosition = pos_to_2
	local bezierAction_2 = CCBezierTo:create(timeTotal/3, bezierConfig_2)
	local rotation_2 = CCRotateTo:create(timeTotal/3, 300)

	local function showFinishCallback( ... )
		-- body
		self.ladybug_layer:setTouchEnabled(false)
		if self.tip then self.tip:removeFromParentAndCleanup(true) end
		self:flyaway()
	end

	local function onTap( ... )
		-- body
		DcUtil:ladybugOnMainTrunkClick()
		self.tip:setVisible( not self.tip.visible)
		setTimeOut(showFinishCallback)
	end

	local function flyFinish( ... )
		-- body
		self.ladybug_layer:stopAllActions()
		self.ladybug:stopAllActions()
		local frames = SpriteUtil:buildFrames("ladybug_wait_%04d", 0 , 60)
		local animate = SpriteUtil:buildAnimate(frames, 1/30)
		self.ladybug:play(animate)

		self.ladybug_layer:setTouchEnabled(true, 0, true)
		self.ladybug_layer:addEventListener(DisplayEvents.kTouchTap, onTap)
	end
	local arr = CCArray:create()
	arr:addObject(bezierAction_1)
	arr:addObject(bezierAction_2)
	arr:addObject(CCCallFunc:create(flyFinish))
	self:runAction(CCSequence:create(arr))

	local arr_2 = CCArray:create()
	arr_2:addObject(rotation_1)
	arr_2:addObject(rotation_2)
	self.ladybug_layer:runAction(CCSequence:create(arr_2))

end

function LadybugFourStarAnimationInLevelNode:flyaway( ... )
	-- body
	local winSize = Director:sharedDirector():getWinSize()
	local function endCallback()
		if self.flyAwayCallback then self.flyAwayCallback() end
	end

	local scene_home = HomeScene:sharedInstance()
	local cur_scene = Director.sharedDirector():getRunningScene()
	if scene_home ~= cur_scene then
		endCallback()
		return 
	end

	local pos = self:getPositionInWorldSpace()
	self:removeFromParentAndCleanup(false)
	self:setPosition(ccp(pos.x, pos.y))
	scene_home:addChild(self)

	self.ladybug:stopAllActions()
	local frames = SpriteUtil:buildFrames("ladybug_fly_%04d", 0 , 2)
	local animate = SpriteUtil:buildAnimate(frames, 1/30)
	self.ladybug:play(animate)


	local pos_btn = scene_home.starButton:getPositionInWorldSpace()
	local size_1 = scene_home.starButton:getGroupBounds().size
	local size_2 = self:getGroupBounds().size
	local _x = (size_1.width - size_2.width)/2
	local _y = (size_1.height - size_2.height)/2
	local arr = CCArray:create()
	local arr_2 = CCArray:create()
	arr_2:addObject(CCRotateTo:create(0.1, 90))

	local pos_to = ccp(pos_btn.x + _x, pos_btn.y - _y)
	arr:addObject(CCDelayTime:create(0.1))

	local distance_x = pos_to.x - pos.x
	local distance_y = pos_to.y - pos.y
	local time = 1
	local offset_y = 400
	if pos.y + offset_y + 100 > winSize.height then
		offset_y = -offset_y
		arr_2:addObject(CCRotateTo:create(time/2, 180))
		arr_2:addObject(CCRotateTo:create(time/2, 270))
	else
		arr_2:addObject(CCRotateTo:create(time/2,0 ))
		arr_2:addObject(CCRotateTo:create(time/2, -90))
	end

	local bezierConfig_1 = ccBezierConfig:new() 
	bezierConfig_1.controlPoint_1 = ccp(pos.x + 200, pos.y)
	bezierConfig_1.controlPoint_2 = ccp(pos.x + 200, pos.y + offset_y)
	bezierConfig_1.endPosition = ccp(pos.x , pos.y + offset_y)
	local bezierAction_1 = CCBezierTo:create(time, bezierConfig_1)
	arr:addObject(bezierAction_1)

	local pos_1 = ccp(pos.x, pos.y + offset_y)
	distance_x = pos_to.x - pos_1.x
	distance_y = pos_to.y - pos_1.y
	time = math.abs(distance_x) > math.abs(distance_y) and math.abs(distance_x) / 400 or math.abs(distance_y) / 400
	local bezierConfig_2 = ccBezierConfig:new() 
	bezierConfig_2.controlPoint_1 = ccp(pos_1.x + distance_x/2, pos_1.y)
	bezierConfig_2.controlPoint_2 = ccp(pos_to.x , pos_1.y )
	bezierConfig_2.endPosition = ccp(pos_to.x , pos_to.y)
	local bezierConfig_2 = CCBezierTo:create(time, bezierConfig_2)
	arr:addObject(bezierConfig_2)

	---finish	
	local func_call = CCCallFunc:create(endCallback)
	arr:addObject(func_call)
	self:runAction(CCSequence:create(arr))
	
	if distance_y > 0  then
		arr_2:addObject(CCRotateTo:create(time/2, -65))
		arr_2:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(time/2, -15 ) , CCScaleTo:create(time/4, 0.5)))
	else
		arr_2:addObject(CCRotateTo:create(time/2, -115))
		arr_2:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(time/2, -165), CCScaleTo:create(time/4, 0.5)) )
	end
	
	self.ladybug_layer:runAction(CCSequence:create(arr_2))
end


