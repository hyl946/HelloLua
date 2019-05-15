GravitySkinLogic_None = class()

function GravitySkinLogic_None:create( gravitySkinViewLogic )
	local logic = GravitySkinLogic_None.new()
	logic:init( gravitySkinViewLogic )

	return logic
end

function GravitySkinLogic_None:init( gravitySkinViewLogic )
	self.gravitySkinViewLogic = gravitySkinViewLogic

	-- self.viewData = {}
	self.horizontalLineInfo = {}
	-- printx( 1 , "GravitySkinLogic_None:init ~~~~~~~~~~~~~~~~~~~~~ self.gravitySkinViewLogic" , self.gravitySkinViewLogic )
	-- debug.debug()
end

function GravitySkinLogic_None:clearItemSprite( itemView )

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


function GravitySkinLogic_None:changeSkinAt( r , c , mode )

end

function GravitySkinLogic_None:buildSkinAt( r , c , itemView  )

	self:clearItemSprite( itemView )

	if not self.horizontalLineInfo[c] then
		self.horizontalLineInfo[c] = r
	end

	if r > self.horizontalLineInfo[c] then

		self:changeSkinAt( self.horizontalLineInfo[c] , c , "Normal" )
		self.horizontalLineInfo[c] = r
	end

	local itemSprite = itemView.itemSprite

	local spriteTop = TileGravitySkin_Water:create( "top" , true )
	local pos = itemView:getBasePosition(itemView.x, itemView.y)
	spriteTop:setPosition(pos)
	itemSprite[ItemSpriteType.kGravitySkinTop] = spriteTop

	local spriteBottom = TileGravitySkin_Water:create( "bottom" , true )
	local pos = itemView:getBasePosition(itemView.x, itemView.y)
	spriteBottom:setPosition(pos)
	itemSprite[ItemSpriteType.kGravitySkinBottom] = spriteBottom

	
	local itemMap = self.gravitySkinViewLogic.gameBoardLogic:getItemMap()
	local item = itemMap[r][c]

	itemView:upDatePosBoardDataPos( item , true )----------更新Item的显示位置-------

end

function GravitySkinLogic_None:clearSkinAt( r , c , itemView  )
	self:clearItemSprite( itemView )
end