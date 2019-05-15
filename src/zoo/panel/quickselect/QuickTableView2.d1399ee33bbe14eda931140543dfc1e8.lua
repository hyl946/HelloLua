QuickTableView = class(Layer)
local ADD_SPEED = 6000
QuickTableViewEventType = {
	kTapTableView = "tapTableView",
}

QuickSelectAnimation = {
	{id = 3, frameNum = 10},
	{id = 8, frameNum = 10},
	{id = 13, frameNum = 10},
	{id = 17, frameNum = 10},
	{id = 19, frameNum = 10},
	{id = 23, frameNum = 10},
	{id = 30, frameNum = 10},
	{id = 43, frameNum = 14},
	{id = 46, frameNum = 20},
	{id = 50, frameNum = 16},
	{id = 57, frameNum = 10},
}
function QuickTableView:create( width, height, renderClass)
	-- body
	local s = QuickTableView.new()
	s:init(width, height, renderClass)
	return s
end

function QuickTableView:ctor( )
	-- body
	Layer.initLayer(self)
	self.name = "QuickTableView"
	self.displayList = {}

	self.lastY = 0
	self.lastX = 0

	self.moveStartX = 0
	self.moveStarty = 0

	self.renderWidth = 0
	self.renderHeight = 0

	self.isTouching = false

	self.isAutoMoving = false --自由滑动
	self.isAutoMovingBegin = false --自由滑动状态的touchbegin

	self.minY  = 0
	self.maxY  = 0

	self.animationPos = nil --动画的位置

	self.offsetY = 0
end

function QuickTableView:init( width, height, renderClass )
	-- body
	
	self.width = width
	self.height = height
	self.renderClass = renderClass
	self:changeWidthAndHeight(width, height)

	-- local touchLayer = LayerColor:create()
	local touchLayer = LayerColor:createWithColor(ccc3(255, 0, 0),self.width,self.height)
	touchLayer:changeWidthAndHeight(width, height)
	touchLayer:setOpacity(0)	
	touchLayer:setTouchEnabled(true, 0, true)
	self:addChild(touchLayer)

	local view_content = LayerColor:createWithColor(ccc3(0, 255, 0))
	view_content:setOpacity(0)	
	view_content:changeWidthAndHeight(200, 200)
	self.view_content = view_content
	self:addChild(view_content)

	local function onTouchEvent( evt )
		if evt.name == DisplayEvents.kTouchBegin then
			self:onTouchBegin(evt)
		elseif evt.name == DisplayEvents.kTouchMove then
			self:onTouchMove(evt)
		elseif evt.name == DisplayEvents.kTouchEnd then
			self:onTouchEnd(evt)
		elseif evt.name == DisplayEvents.kTouchTap then
			self:onTouchTap(evt)
		end
	end
	
	touchLayer:ad(DisplayEvents.kTouchBegin, onTouchEvent)
	touchLayer:ad(DisplayEvents.kTouchMove, onTouchEvent)
	touchLayer:ad(DisplayEvents.kTouchEnd, onTouchEvent)
	touchLayer:ad(DisplayEvents.kTouchTap, onTouchEvent)


	local function __getPosition( ... )
		return ccp(self.lastX, self.lastY)
	end
	self.speedometers = {}
	self.speedometers[1] = VelocityMeasurer:create(1/60, __getPosition)
	self.speedometers[2] = VelocityMeasurer:create(2/60, __getPosition)
	self.speedometers[3] = VelocityMeasurer:create(4/60, __getPosition)

end

function QuickTableView:updateData( dataList )
	-- body
	if dataList ~= self.dataList then
		self.dataList = dataList
		for k, v in pairs(dataList) do 
			self:updateViewByIndex(k, v)
		end
	end

	self:checkVisible()
end

function QuickTableView:updateViewByIndex( index, data )
	-- body
	if not self.displayList[index] then
		local wSize = Director:sharedDirector():getWinSize()
		local height = 106	-- TablevelArea.height / 5 = 106
		local width = 585
		self.renderHeight = height
		self.renderWidth = width
		local render = self.renderClass:create(width, height, data)
		self.displayList[index] = render
		self.view_content:addChild(render)
		local y = (index - 1) * height
		if self.maxY < -y then self.maxY = -y end
		if self.minY > -y then self.minY = -y end

		local x = wSize.width/2
		render:setPositionXY(self.width/2 + 4,y)
	end
end

function QuickTableView:onTouchBegin( evt )
	-- body

	self.touchBeginTime = os.clock()
	if self.animation then
		self.animation:removeFromParentAndCleanup(true)
		self.animation = nil
	end

	local pos = evt.globalPosition
	self.view_content:stopAllActions()
	self.moveStartX = pos.x 
	self.moveStartY = pos.y

	self.lastX = pos.x
	self.lastY = pos.y

	self.isTouching = true

	for k, v in pairs(self.speedometers) do 
		v:setInitialPos(self.lastX, self.lastY)
		v:startMeasure()
	end

	if self.isAutoMoving then 
		self.isAutoMovingBegin = true
	else
		self.isAutoMovingBegin = false
	end

	local function _update( )
		self:checkVisible()
	end

	self:unscheduleUpdate()
	self:scheduleUpdateWithPriority(_update, 0)
end

function QuickTableView:onTouchMove( evt )
	-- body
	self.isTouching = true
	local pos = evt.globalPosition

	local pos_view = self.view_content:getPosition()
	local detY = pos.y - self.lastY
	self:MoveTo(ccp(pos_view.x, pos_view.y + detY))

	self.lastX = pos.x
	self.lastY = pos.y
end

function QuickTableView:onTouchEnd( evt )
	-- body
	local pos = evt.globalPosition
	self.touchEndTime = os.clock()
	self.isTouching = false
	local pos_view = self.view_content:getPosition()
	local detY = pos.y - self.lastY
	if detY > 0 then 
		self.isUP = true
	elseif detY < 0 then 
		self.isUP = false
	end

	self.speed = 0
	for k, v in pairs(self.speedometers) do 
		v:stopMeasure()
		local speedY = v:getMeasuredVelocityY()
		if speedY and speedY~= 0 then
			-- if _G.isLocalDevelopMode then printx(0, speedY) end
			if math.abs(speedY) > self.speed then 
				self.speed = speedY
			end
		end
	end

	self:MoveTo(ccp(pos_view.x, pos_view.y + detY))

	self.lastX = 0
	self.lastY = 0
end

function QuickTableView:getIndexByGlobalPos( globalPosition )
	-- body
	local pos_view = self.view_content:getPosition()
	local node_pos = self.view_content:convertToNodeSpace(globalPosition)

	local p = ccp(node_pos.x , node_pos.y)
	local index = math.floor(p.y / self.renderHeight) + 1

	-- 调到这里快哭了，终于对了。。。
	if index > #self.displayList or index < 0 then
	else
		local render
		--检查下限
		if index > 0 then
			render = self.displayList[index]
			local _height = render:getGroupBounds().size.height / 2 
			if p.y - (index - 1) * self.renderHeight <= _height then
				local _width = render:getGroupBounds().size.width
				local x_o = render:getPositionX()
				if p.x >= x_o - _width / 2 and p.x <= x_o + _width / 2 then
					return index
				end
			end
		end

		--检查上限
		if index + 1 <= #self.displayList then
			render = self.displayList[index + 1]
			local _height = render:getGroupBounds().size.height / 2
			if index * self.renderHeight - p.y <= _height  then
			 	local _width = render:getGroupBounds().size.width
				local x_o = render:getPositionX()
				if p.x >= x_o - _width / 2 and p.x <= x_o + _width / 2 then
					return index + 1
				end
			end
		end

	end
	return nil
end

function QuickTableView:onTouchTap( evt )
	-- body
	local del_time = self.touchEndTime - self.touchBeginTime
	if del_time >= 0.8 or self.isAutoMovingBegin then
		return 
	end

	local pos = evt.globalPosition
	local index = self:getIndexByGlobalPos(pos)

	local data = {index = index}
	local evt = Event.new(QuickTableViewEventType.kTapTableView, data, self)
	self:dispatchEvent(evt)
end

function QuickTableView:fixPos( pos )
	local tempY = pos.y
	local det_s = 0
	if not self.isTouching then
		--速度导致的位移校正
		local t = self.speed / ADD_SPEED
		-- if _G.isLocalDevelopMode then printx(0, "time = "..t.." self.speed = "..self.speed.." ") end
		det_s = (self.speed * self.speed)/(2*ADD_SPEED)
		if self.speed ~= 0 then
			det_s = det_s*(self.speed/math.abs(self.speed))
		end
		--定位校正
		local index = (self.height /2 - pos.y - det_s) / self.renderHeight
		if index + 0.5 > math.ceil(index) then
			index = math.ceil(index)
		else
			index = math.floor(index)
		end
		tempY = self.height /2  - index * self.renderHeight
		det_s = tempY - pos.y
	end
	--边界校正
	--  上边界
	local offset_det_min = self.isTouching and (self.height/2 -self.renderHeight/2 + 5 )  or (self.height -self.renderHeight/2 + 5)
	-- 下边界
	local offset_det_max = self.isTouching and self.height/2 or self.bottomY-5
	
	if tempY < self.minY + offset_det_min then
		det_s = self.minY + offset_det_min - pos.y
	elseif tempY > self.maxY + offset_det_max then 
		det_s = self.maxY + offset_det_max - pos.y
	end


	--根据最终算出的位移 和加速度 求最终的速度s = at*t／２
	local t = math.sqrt( 2 * math.abs(det_s) /ADD_SPEED )
	self.speed = t * ADD_SPEED
	if det_s < 0 then self.speed = -self.speed end

	pos.y = pos.y + det_s
	
	return pos
end

function QuickTableView:checkVisible( ... )

	if self.isDisposed then return end
	if (not self.view_content) or self.view_content.isDisposed then return end

	local pos = self.view_content:getPosition()
	local index = math.floor((self.height/2 - pos.y) / self.renderHeight + 0.5)

	local visibleRange = {index - 3, index + 5 + 3} --一屏最多显示5个，上下格外再各加3个冗余

	for i, item in ipairs(self.displayList) do
		if item.isDisposed then return end
		item:setVisible(i >= visibleRange[1] and i <= visibleRange[2])
	end
end

function QuickTableView:MoveTo( pos )
	-- body
	pos = self:fixPos(pos)
	local function _moveCallback( ... )
		-- body
		self:unscheduleUpdate()
		self:checkVisible()
		self:playAnimation()
		self.isAutoMoving = false
	end

	if self.isTouching  then 
		self.view_content:setPosition(pos)
	else
		self.isAutoMoving = true
		local action_move = CCMoveTo:create(math.abs(self.speed/ADD_SPEED), pos)
		local action_ease_out = CCEaseOut:create(action_move, 3)
		local action_callback = CCCallFunc:create(_moveCallback)
		self.view_content:runAction(CCSequence:createWithTwoActions(action_ease_out, action_callback))
	end
end

function QuickTableView:initArea( index )
	-- body
	if index > 0 and index <= #self.displayList then
		local posY = self.height /2  - (index - 1) * self.renderHeight
		
		self.bottomY = self.renderHeight/2 
		self.topY = -(#self.displayList - 5) * self.renderHeight + (self.renderHeight/2 )
		-- 下面不能留空
		if ( posY >  self.bottomY) then 
			posY = self.bottomY
		-- 上面不能留空
		elseif ( posY <  self.topY) then 
			posY = self.topY
		end

		self.view_content:setPositionY(posY) 
		if _G.isLocalDevelopMode then printx(0, "initArea view_content y:",posY,"index",index,#self.displayList) end

		self.displayList[index]:changeScale(1)
		self:playAnimation()
		self:checkVisible()
	end
end


--不是准确的 有误差 在+2>x>-2
function QuickTableView:getCurrentIndex( pos )
	-- body
	pos = pos or self.view_content:getPosition()
	local index = math.floor((self.height/2 - pos.y) / self.renderHeight)
	return index
end

local function createAnimationSelect( animateConfig )
	-- body
	local sprite = Sprite:createWithSpriteFrameName("area_animation_"..animateConfig.id.."_0000")
	local frames = SpriteUtil:buildFrames("area_animation_"..animateConfig.id.."_%04d", 0, animateConfig.frameNum)
	local animate = SpriteUtil:buildAnimate(frames, 1/24)
	sprite:play(animate)
	return sprite

end

-- 没有中央render，怎么播放动画。。
function QuickTableView:playAnimation( ... )

end

function QuickTableView:dispose( ... )
	-- body
	for k, v in pairs(self.speedometers) do 
		v:stopMeasure()
	end
	Layer.dispose(self)
end


