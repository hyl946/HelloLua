GravitySkinLogic_Water = class()

function GravitySkinLogic_Water:create( gravitySkinViewLogic )
	local logic = GravitySkinLogic_Water.new()
	logic:init( gravitySkinViewLogic )

	return logic
end

function GravitySkinLogic_Water:init( gravitySkinViewLogic )
	self.gravitySkinViewLogic = gravitySkinViewLogic

	-- self.viewData = {}
	self.horizontalLineInfo = {}
	-- printx( 1 , "GravitySkinLogic_Water:init ~~~~~~~~~~~~~~~~~~~~~ self.gravitySkinViewLogic" , self.gravitySkinViewLogic )
	-- debug.debug()
end

function GravitySkinLogic_Water:clearItemSprite( itemView )

	local itemSprite = itemView.itemSprite

	if itemSprite[ItemSpriteType.kGravitySkinTop] then
		itemSprite[ItemSpriteType.kGravitySkinTop]:removeFromParentAndCleanup(true)
		itemSprite[ItemSpriteType.kGravitySkinTop] = nil
	end

	if itemSprite[ItemSpriteType.kGravitySkinBottom] then
		itemSprite[ItemSpriteType.kGravitySkinBottom]:removeFromParentAndCleanup(true)
		itemSprite[ItemSpriteType.kGravitySkinBottom] = nil
	end
end

function GravitySkinLogic_Water:updateHorizontalLineInfo( r , c )
	if not self.horizontalLineInfo[c] then
		self.horizontalLineInfo[c] = r
	end

	if r < self.horizontalLineInfo[c] then
		local oldR = self.horizontalLineInfo[c]
		self.horizontalLineInfo[c] = r
		return true , oldR , r --返回值：  水平线是否变化  ，  旧值   ， 新值
	end

	return false
end

function GravitySkinLogic_Water:deleteHorizontalLineInfo( r , c )
	local oldR = self.horizontalLineInfo[c] or 0

	if oldR > 0 then

		if r == oldR then

			local mainLogic = self.gravitySkinViewLogic.gameBoardLogic
			local boardMap = mainLogic:getBoardMap()

			for i = r + 1 , 9 do
				local board = boardMap[i][c]
				if board and board:getGravitySkinType() == BoardGravitySkinType.kWater then
					self.horizontalLineInfo[c] = i
					
					return true , i , oldR
				end
			end
		end
	end

	return false
end

function GravitySkinLogic_Water:changeSkinAt( r , c , mode )

end

function GravitySkinLogic_Water:buildSkinAt( r , c , itemView  )

	self:clearItemSprite( itemView )

	local horizontalLineChanged , oldR , newR = self:updateHorizontalLineInfo( r , c )
	if horizontalLineChanged then
		self:changeSkinAt( oldR , c , "Normal" )
	end

	local itemSprite = itemView.itemSprite

	local horLineR = self.horizontalLineInfo[c]
	local isHorLin = horLineR == r

	local spriteTop = TileGravitySkin_Water:create( "top" , isHorLin )
	local pos = itemView:getBasePosition(itemView.x, itemView.y)
	spriteTop:setPosition(pos)
	itemSprite[ItemSpriteType.kGravitySkinTop] = spriteTop

	local spriteBottom = TileGravitySkin_Water:create( "bottom" , isHorLin )
	local pos = itemView:getBasePosition(itemView.x, itemView.y)
	spriteBottom:setPosition(pos)
	itemSprite[ItemSpriteType.kGravitySkinBottom] = spriteBottom

	
	local itemMap = self.gravitySkinViewLogic.gameBoardLogic:getItemMap()
	local item = itemMap[r][c]

	itemView:upDatePosBoardDataPos( item , true )----------更新Item的显示位置-------

end

function GravitySkinLogic_Water:clearSkinAt( r , c , itemView  )
	self:clearItemSprite( itemView )
	self:deleteHorizontalLineInfo( r , c )
end