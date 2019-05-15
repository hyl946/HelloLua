local UIHelper = require 'zoo.panel.UIHelper'

TileBiscuit = class(Sprite)

function TileBiscuit:create(biscuitData, w, h)
	if not fireworkInfo then fireworkInfo = {} end
	local s = TileBiscuit.new(CCSprite:createWithSpriteFrameName('biscuit_sp/1_1x2'))
	s:init(biscuitData, w, h)
	return s
end

function TileBiscuit:createAndAddBiscuitSp( _level, spKey, needRotate)
	local cuitSp
	local spriteFrameName = 'biscuit_sp/' .. _level .. '_' .. spKey
	if needRotate then
		local spFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName)
		local texture, rect, rotated = spFrame:getTexture(), spFrame:getRect(), not spFrame:isRotated()
		rect = CCRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width)
		cuitSp = Sprite:createWithTextureRectRotated(texture, rect, rotated)
	else
		cuitSp = Sprite:createWithSpriteFrameName(spriteFrameName)
	end
	-- cuitSp:setPositionXY(self.contentOffsetX, self.contentOffsetY)
	cuitSp:setAnchorPoint(ccp(0, 1))
	cuitSp:setPositionXY(self.contentOffsetX - 2, 2 + self.contentOffsetY)
	self:addChild(cuitSp)

	local decHeight = 4
	if _level > 1 then
		local oriHeight = cuitSp:getContentSize().height
		local targetHeight = oriHeight - decHeight
		cuitSp:setScaleY(targetHeight / oriHeight)

		local pos = cuitSp:getPosition()
		local anchorPoint = cuitSp:getAnchorPoint()

		cuitSp.posInfo = {
			pos = ccp(pos.x, pos.y),
			anchorPoint = ccp(anchorPoint.x, anchorPoint.y),
			scaleY = cuitSp:getScaleY(),
		}
	end
	return cuitSp
end

function TileBiscuit:getBiscuitSpCfg( row, col )
	local spCfg = {'1x2', '2x2', '3x2', '3x3'}
	local spKey = '' .. row .. 'x' .. col
	local needRotate = false
	if not table.includes(spCfg, spKey) then
		spKey = '' .. col .. 'x' .. row
		needRotate = true
	end
	return spKey, needRotate
end

function TileBiscuit:init(biscuitData, w, h)

	self.w = w
	self.h = h

	self.contentOffsetX = - self.w * biscuitData.nCol / 2
	self.contentOffsetY = self.h * biscuitData.nRow / 2

	local spKey, needRotate = self:getBiscuitSpCfg(biscuitData.nRow, biscuitData.nCol)

	local biscuitLevel = biscuitData.level
	biscuitLevel = math.clamp(biscuitLevel, 1, 3)

	self:setOpacity(0)
	self:setAnchorPoint(ccp(0, 0))

	for _level = 1, biscuitLevel do
		self:createAndAddBiscuitSp(_level, spKey, needRotate)
	end

	self.milkSpGrp = {}

	for milkRow = 1, biscuitData.nRow do
		for milkCol = 1, biscuitData.nCol do
			if biscuitData.milks[milkRow][milkCol] >= biscuitLevel then
				self:playAppkyMilkAnim(biscuitData, milkRow, milkCol)
			end
		end
	end
end

function TileBiscuit:playAppkyMilkAnim(biscuitData, milkRow, milkCol)
	local biscuitLevel = biscuitData.level
	biscuitLevel = math.clamp(biscuitLevel, 1, 3)
	local milkSpKey = string.format('biscuit_sp/biscuit_apply_milk_%s_0000', biscuitLevel)
	local milkSp = Sprite:createWithSpriteFrameName(milkSpKey)
	milkSp:setAnchorPoint(ccp(0.5, 0.5))
	local milkX, milkY = milkCol - 0.5, milkRow - 0.5
	local milkPos = ccp(milkX * self.w + self.contentOffsetX, - milkY * self.h + self.contentOffsetY)
	milkSp:setPosition(milkPos)
	self:addChild(milkSp)
	milkSp:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("biscuit_sp/biscuit_apply_milk_" .. biscuitLevel .. "_%04d", 0, 7), kCharacterAnimationTime), 0, 1, nil)

	table.insert(self.milkSpGrp, milkSp)

end

function TileBiscuit:clearMilkSp( ... )
	-- body
	for _, v in ipairs(self.milkSpGrp) do
		if v and (not v.isDisposed) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.milkSpGrp = {}
end

function TileBiscuit:playUpgradeBiscuitAnim(biscuitData, newLevel, container )
	-- container  动画的前半截 在container里调
	local spKey, needRotate = self:getBiscuitSpCfg(biscuitData.nRow, biscuitData.nCol)
	local cuitSp = self:createAndAddBiscuitSp(newLevel, spKey, needRotate)

	cuitSp:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = cuitSp:getPosition()
	pos = ccp(pos.x, pos.y)
	local worldPos = cuitSp:getParent():convertToWorldSpace(pos)
	local posInContainer = container:convertToNodeSpace(worldPos)
	cuitSp:removeFromParentAndCleanup(false)
	container:addChild(cuitSp)
	local offsetY = cuitSp:getContentSize().height / 3
	cuitSp:setPositionXY(posInContainer.x, posInContainer.y + offsetY)
	cuitSp:setScale(1.25)

	local FPS = 30

	cuitSp:runAction(UIHelper:sequence{
		UIHelper:spawn{CCScaleTo:create(6/FPS, 1, 1), CCMoveBy:create(6/FPS, ccp(0, -offsetY))},
		CCCallFunc:create(function ( ... )
			if cuitSp and (not cuitSp.isDisposed) then
				cuitSp:removeFromParentAndCleanup(false)
				self:addChild(cuitSp)
				if cuitSp.posInfo then
					cuitSp:setAnchorPoint(cuitSp.posInfo.anchorPoint)
					cuitSp:setPosition(cuitSp.posInfo.pos)
					cuitSp:setScaleY(cuitSp.posInfo.scaleY)
					cuitSp.posInfo = nil
					self:clearMilkSp()
				end
			end
			self:shake()
		end)
	})
end

function TileBiscuit:shake( ... )
	if self.isDisposed then return end
	self:setScale(0.97)
	self:runAction(CCScaleTo:create(5/30, 1, 1))
end