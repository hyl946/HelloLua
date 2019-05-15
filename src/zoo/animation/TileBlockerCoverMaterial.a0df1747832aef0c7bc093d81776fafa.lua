--木桩动画
TileBlockerCoverMaterial = class(CocosObject)

--各个消除动画的帧数
local frameLength = {18, 19, 30}
--创建棋盘显示对象
function TileBlockerCoverMaterial:create(level)
	-- if _G.isLocalDevelopMode then printx(0, 'TileBlockerCoverMaterial:create', level) end
	local node = TileBlockerCoverMaterial.new(CCNode:create())
	if level > 0 then
		node:init(level)
	elseif level == -1 then
		node:playWaitAnimation()
	else
		return nil
	end 
	
	return node
end

function TileBlockerCoverMaterial:init(level)
	self:buildAnimation(level)
end

--播放消除动画
function TileBlockerCoverMaterial:playDecreaseAnimation(level , callback)
	if level < 0 then return nil end
	self:buildAnimation(level + 1, frameLength[level + 1], 1, true , callback)
end

--播放等待动画
function TileBlockerCoverMaterial:playWaitAnimation()
	self:buildAnimation(0, 16, 0, true)
end

function TileBlockerCoverMaterial:buildAnimation(level, frame, repeatCount, isAnimation , callback)
	local resName = 'stake_' .. tostring(level) .. '_0000' 
	local sp = Sprite:createWithSpriteFrameName(resName)

	if isAnimation then
		local frames, animate
		local aniName = 'stake_' .. tostring(level) .. '_%04d'

		frames = SpriteUtil:buildFrames(aniName, 0, frame)
		animate = SpriteUtil:buildAnimate(frames, 1/24)
		sp:play(animate, 0, repeatCount , function () if callback then callback() end end)
	end

	if sp then 
		self:removeChildren(true)
		self:addChild(sp)
		if level == 0 then
			sp:setPosition(ccp(4, 4))
		elseif level == 1 then
			sp:setPosition(ccp(0, -1))
		else
			sp:setPosition(ccp(4, -1))
		end
	end

	if not isAnimation and callback then
		callback()
	end
end