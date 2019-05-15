TileWukongEff = class(CocosObject)

function TileWukongEff:create()
    local node = TileWukongEff.new(CCNode:create())
    node:init()
    return node
end


function TileWukongEff:init()
    
    --[[
    local node = CocosObject.new(CCNode:create())
	local lockrect = LayerColor:create()
	--node:addChild(lockrect)
	
	lockrect:setColor( ccc3(0,0,0) )
	lockrect:setOpacity(150)
	lockrect:changeWidthAndHeight(500 , 300)
	lockrect:setPosition(ccp(100,100) )
	lockrect:setTouchEnabled(true , 0 , true)
	self.itemSprite[ItemSpriteType.kItemDestroy] = node
	--self.getContainer(ItemSpriteType.kItemDestroy):addChild(destroySprite)
	--ItemSpriteType.kItemDestroy
	]]

    FrameLoader:loadArmature("skeleton/wukong_animation")
	--local lockrect = Sprite:createWithSpriteFrameName("wukong_target_bg")
	--lockrect:setScaleX(9)
	--lockrect:setScaleY(9)
	--lockrect:setOpacity(150)


	local lockrect = LayerColor:create()
	local maxCol = GamePlayConfig_Max_Item_Y - 1
	local fixNumber = 2
	--node:addChild(lockrect)
	
	lockrect:setColor( ccc3(0,0,0) )
	lockrect:setOpacity(150)
	lockrect:changeWidthAndHeight( GamePlayConfig_Tile_Width * maxCol + fixNumber  , GamePlayConfig_Tile_Width * maxCol + fixNumber )
	lockrect:setPosition(
		ccp(0 - (GamePlayConfig_Tile_Width/2) - fixNumber , 
			-1*GamePlayConfig_Tile_Width*maxCol + (GamePlayConfig_Tile_Width/2) + fixNumber) 
		)
	lockrect:setTouchEnabled(true , 0 , true)

	self:addChild(lockrect)
	
end