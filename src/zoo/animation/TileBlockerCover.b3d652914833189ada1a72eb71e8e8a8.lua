--小叶堆动画
TileBlockerCover = class(CocosObject)

--创建棋盘显示对象
function TileBlockerCover:create(level , passAnimation)
	local node = TileBlockerCover.new(CCNode:create())
	node:init(level , passAnimation)
	return node
end

--播放消除动画
function TileBlockerCover:playDecreaseAnimation(level , callback)
	local length = {20, 19, 26}
	self:buildAnimation(level + 1, 'stake_leaf_',  length[level + 1], true , callback)
end

--播放生长动画
function TileBlockerCover:playGrowupAnimation(level , callback , passAnimation)
	local length = {16, 15, 22}
	self:buildAnimation(level, 'stake_leaf_growup_', length[level], not passAnimation , callback)
end

--播放连接动画
function TileBlockerCover:createJoinAnimation(startPoint, endPoint)
	local layer = Layer:create()
	local resName = 'stake_leaf_join_0000' 
	local sp = Sprite:createWithSpriteFrameName(resName)
	local aniName = 'stake_leaf_join_%04d'
	local frames, animate
	local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
	local function finishCallback()
		layer:removeFromParentAndCleanup(true) 
	end

	frames = SpriteUtil:buildFrames(aniName, 0, 11)
	animate = SpriteUtil:buildAnimate(frames, 1/36)
	sp:play(animate, 0, 0, nil)
	sp:setPosition(startPoint)
	sp:setRotation(angle)
	sp:setAnchorPoint(ccp(1, 0.4))

	local actArr = CCArray:create()
	actArr:addObject( CCMoveTo:create( 0.25 , ccp( endPoint.x , endPoint.y ) ) )
	actArr:addObject( CCCallFunc:create( finishCallback ) )
	sp:runAction( CCSequence:create(actArr) )

	layer:addChild(sp)

	return layer
end

function TileBlockerCover:init(level , passAnimation)
	self:playGrowupAnimation(level , nil , passAnimation)
end

function TileBlockerCover:buildAnimation(level, name, frame, isAnimation , callback)
	if level <= 0 then return nil end

	local resName = name .. tostring(level) .. '_0000'
	if not isAnimation then
		resName = name .. tostring(level) .. '_00'..(frame - 1) 
	end
	local sp = Sprite:createWithSpriteFrameName(resName)

	if isAnimation then
		local frames, animate
		local aniName = name .. tostring(level) .. '_%04d'
	
		frames = SpriteUtil:buildFrames(aniName, 0, frame)
		animate = SpriteUtil:buildAnimate(frames, 1/24)
		sp:play(animate, 0, 1 , function () if callback then callback() end end)
	end

	if sp then 
		self:removeChildren(true)
		self:addChild(sp)
		sp:setPosition(ccp(-3, -8))
	end

	if not isAnimation and callback then
		callback()
	end
end