require "zoo.animation.TileCharacter"
require "zoo.animation.TileBird"
require "zoo.animation.GamePropsAnimation"
require "zoo.animation.LinkedItemAnimation"
require "zoo.animation.TileCuteBall"
require "zoo.animation.CommonEffect"

require "zoo.itemView.ItemView"
require "zoo.gamePlay.GamePlayConfig"
-- require "zoo.gamePlay.GameBoardLogic"
require "zoo.gamePlay.BoardView.BoardViewAction"
require "zoo.gamePlay.BoardView.BoardViewPass"
require "zoo.gamePlay.propInteractions.InteractionController"
require "zoo.gamePlay.GravitySkinViewLogic"
require "zoo.animation.TileDragonBoss"
require "zoo.animation.TileGravitySkin_Water"


GameBoardView = class(Layer)

local SCROLL_V = 278
local DIG_SCROLL_SCALE = 2.3

local needCopyLayers = {
	ItemSpriteType.kScrollBackground,
	ItemSpriteType.kMoveTileBackground,
	ItemSpriteType.kTileBlocker,
	ItemSpriteType.kColorFilterA,
	ItemSpriteType.kColorFilterB,
	ItemSpriteType.kSuperCuteLowLevel,
	ItemSpriteType.kTileHighLightEffect,
	ItemSpriteType.kTileHighLightEffectWithoutTexture,
	ItemSpriteType.kLight,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kBlockerCoverMaterial,
	ItemSpriteType.kItem, 
	ItemSpriteType.kItemShow,
	ItemSpriteType.kMagicTileWater,
	ItemSpriteType.kRope,
	ItemSpriteType.kOlympicLock,
	ItemSpriteType.kLock,
	ItemSpriteType.kFurBall,
	ItemSpriteType.kSnail,
	ItemSpriteType.kHoney,
	ItemSpriteType.kNormalEffect,
	ItemSpriteType.kBigMonster,
	ItemSpriteType.kBigMonsterIce,
	ItemSpriteType.kWeeklyBoss,
	ItemSpriteType.kChestSquare,
	ItemSpriteType.kChestSquarePart,
	ItemSpriteType.kDigBlocker,
	ItemSpriteType.kRandomProp,
	ItemSpriteType.kSnailRoad,
	ItemSpriteType.kHedgehogRoad,
	ItemSpriteType.kPass,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kSuperCuteHighLevel,
	ItemSpriteType.kBlockerCover,
	ItemSpriteType.kTopLevelHighLightEffect,
	ItemSpriteType.kChain,
	ItemSpriteType.kPacmanShow,
	ItemSpriteType.kSquidShow,
    ItemSpriteType.kMoleBossCloud,
	ItemSpriteType.kMoleWeeklyItemShow,
}

local DefaultVisibleLayers = {
	ItemSpriteType.kBackground,
	ItemSpriteType.kMoveTileBackground,
	ItemSpriteType.kSuperCuteLowLevel,
	ItemSpriteType.kGameGuideEffect,
	ItemSpriteType.kItemBack,
	ItemSpriteType.kLotus_bottom,
	ItemSpriteType.kItemLowLevel,
	ItemSpriteType.kItem,
	ItemSpriteType.kItemShow,
	ItemSpriteType.kMoleWeeklyItemShow,
	ItemSpriteType.kItemDestroy,
	ItemSpriteType.kClipping,
	ItemSpriteType.kEnterClipping,
	ItemSpriteType.kRope,
	ItemSpriteType.kOlympicLock,
	ItemSpriteType.kLock,
	ItemSpriteType.kSnail,
	ItemSpriteType.kNormalEffect,
	ItemSpriteType.kItemHighLevel,
	ItemSpriteType.kLotus_top,
	ItemSpriteType.kSuperCuteHighLevel,
	ItemSpriteType.kChain,
	ItemSpriteType.kSpecial,
}


function GameBoardView:ctor()
	self.baseMap = nil;			--地格--落稳的东西
	self.ItemFalling = nil;		--下落中的东西
	self.showPanel = nil;

	self.baseLocation = nil;
	self.PosStart = nil;		--游戏面板的起始位置--用来计算点击到哪个方块上了
	self.ItemW = GamePlayConfig_Tile_Width;
	self.ItemH = GamePlayConfig_Tile_Height;

	self.gameBoardLogic = nil;

	self.isTouchReigister = false;
	self.isRegisterUpdate = false;
	self.updateScheduler = nil;

	self.IngredientActionPos = ccp(50,800) 			----豆荚收集之后 飞向的位置
	self.moveCountPos = ccp(90, 80)				----移动步数所在位置，bonus时会飞出特效

	self.PlayUIDelegate = nil;
	self.isPaused = false;
	-- Init Base
	Layer.initLayer(self)

	-- 震动计数器
	self.viberateCounter = 0
	self.viberateDelay = 0
	self.originPos = nil

	-- 道具使用状态
	self.gamePropsType = GamePropsType.kNone
	self.debugCounter = 0

	self.startRowIndex = 1
	self.rowCount = 9
	self.startColIndex = 1
	self.colCount = 9
	self.scrollScale = 1
end

function GameBoardView:dispose()
	self:unRegisterAll()
	self.updateScheduler = nil;

	self.ItemFalling = nil;

	self:cleanAllItemSprite()
	self.baseMap = nil

	if self.showPanel then
		for i, _ in pairs(self.showPanel) do
			if self.showPanel[i] and not self.showPanel[i].isDisposed then
				if self.showPanel[i]:getParent() then 
					self.showPanel[i]:removeFromParentAndCleanup(true);
				else
					self.showPanel[i]:dispose()
				end
			end
		end
	end
	self.showPanel = nil

	self:removeDigScrollView()

	self.gameBoardLogic = nil;
	self.baseLocation = nil;
	self.PosStart = nil;
	self.gravitySkinViewLogic = nil

	Layer.dispose(self)

	self.originPos = nil
end


function GameBoardView:create(boardRect, gamePlayType, isHalloween , replayMode)
	local v = GameBoardView.new()
	if boardRect then
		v.startRowIndex = boardRect.origin.y
		v.startColIndex = boardRect.origin.x
		v.rowCount = boardRect.size.height
		v.colCount = boardRect.size.width
	end
	v.gamePlayType = gamePlayType
	v.clippingDelta = 0 
	v.replayMode = replayMode
	v:initView(v, v, isHalloween)
	return v
end

function GameBoardView:getUsedBoardMapRect(boardMap, digBoardMap, digType)
	local startRowIndex = 1
	local startColIndex = 1
	local rowCount = 9
	local colCount = 9
	if boardMap then
		local firstRowUsed, firstColUsed = 0, 0
		local lastRowUsed, lastColUsed = -1, -1
		for r = 1, #boardMap do
			for c = 1, #boardMap[r] do
				local board = boardMap[r] and boardMap[r][c] or nil
				if board and board.isUsed then
					if firstRowUsed == 0 or r < firstRowUsed then firstRowUsed = r end
					if firstColUsed == 0 or c < firstColUsed then firstColUsed = c end
					if r > lastRowUsed then lastRowUsed = r end
					if c > lastColUsed then lastColUsed = c end
					-- break
				end
			end
		end
		if digType == 1 and digBoardMap then -- 垂直滚动, 貌似没这个需求
			-- for r = 1, #digBoardMap do
			-- 	for c = 1, #digBoardMap[r] do
			-- 		local board = digBoardMap[r] and digBoardMap[r][c] or nil
			-- 		if board and board.isUsed then
			-- 			if firstColUsed == 0 or c < firstColUsed then firstColUsed = c end
			-- 			if c > lastColUsed then lastColUsed = c end
			-- 		end
			-- 	end
			-- end
		elseif digType == 2 and digBoardMap then -- 横版滚动
			for r = 1, #digBoardMap do
				for c = 1, #digBoardMap[r] do
					local board = digBoardMap[r] and digBoardMap[r][c] or nil
					if board and board.isUsed then
						if firstRowUsed == 0 or r < firstRowUsed then firstRowUsed = r end
						if r > lastRowUsed then lastRowUsed = r end
					end
				end
			end
		end
		startRowIndex = firstRowUsed
		startColIndex = firstColUsed
		rowCount = lastRowUsed - firstRowUsed + 1
		colCount = lastColUsed - firstColUsed + 1
	end
	return CCRectMake(startColIndex, startRowIndex, colCount, rowCount)
end

function GameBoardView:setGameBoardLogic( gameBoardLogic )
	self.gameBoardLogic = gameBoardLogic
	self.gravitySkinViewLogic = GravitySkinViewLogic:create( self )
end

function GameBoardView:createByGameBoardLogic(gameBoardLogic , replayMode)
	local boardMap = gameBoardLogic:getBoardMap();
	local digType = nil
	if gameBoardLogic:isHorizontalEndless() then
		digType = 2											
	end
	local boardRect = self:getUsedBoardMapRect(boardMap, gameBoardLogic.digBoardMap, digType)

	local isHalloween = gameBoardLogic.gameMode:is(MoleWeeklyRaceMode)
	local theview = GameBoardView:create(boardRect, gameBoardLogic.theGamePlayType, isHalloween , replayMode)
	theview:setGameBoardLogic( gameBoardLogic )   --记录逻辑来源
	gameBoardLogic.boardView = theview

	theview:initBaseMapByData(boardMap)					--加载地图信息
	
	local itemMap = gameBoardLogic:getItemMap()
	theview:initBaseMapByItemData(itemMap)				--加载GameItem信息

	theview:initBaseMapView()												-- 初始化显示

	if gameBoardLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID or 
		gameBoardLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID or 
		gameBoardLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then   -- 绘制棋盘边缘
		-- 周赛改为棋盘背景可滚动 不走统一背景绘制了
	else
		theview:paintBorder(boardMap)											
	end

	local offset, sizeWidth, sizeHeight = theview:resizeToFitScreen(boardMap)
	theview.bgOffset = offset
	theview.bgSizeWidth = sizeWidth
	theview.bgSizeHeight = sizeHeight

	theview:RegisterAll()

	theview:initInteractionController()

	return theview, offset													-- 棋盘适配屏幕大小并放到屏幕中央
end

function GameBoardView:initInteractionController()
	if not self.interactionController then
		self.interactionController = InteractionController:create(self)
	end
	self.interactionController:init()
end

function GameBoardView:playMonkeyBar(row , colorIndex)
	local layer = self.showPanel[ ItemSpriteType.kNormalEffect] 

	if layer then
		local container = Layer:create()
		local gridWid = GamePlayConfig_Tile_Width
		local halfGridWid = gridWid/2


		local eff1 = ArmatureNode:create("wukong_monkeybar_animation/monkeyBar_light_eff")
		local eff2 = ArmatureNode:create("wukong_monkeybar_animation/monkeyBar_light_eff")
		local eff3 = ArmatureNode:create("wukong_monkeybar_animation/monkeyBar_light_eff")

		eff1:setPosition( ccp( 0 , 0 ) )
		eff2:setPosition( ccp( 0 , GamePlayConfig_Tile_Width * -1 ) )
		eff3:setPosition( ccp( 0 , GamePlayConfig_Tile_Width ) )

		eff1:playByIndex(0,0)
		eff2:playByIndex(0,0)
		eff3:playByIndex(0,0)

		container:addChild(eff1)
		container:addChild(eff2)
		container:addChild(eff3)

		local rotationeSprite = Sprite:createEmpty()

		local rotationeff = Sprite:createWithSpriteFrameName("wukong_monkeybar_rotationeff_bg")
		rotationeff:setAnchorPoint(ccp(0.5,0.5))

		rotationeSprite:addChild(rotationeff)

		local rotationBar = Sprite:createWithSpriteFrameName("wukong_monkeybar_rotationeff_" .. tostring(colorIndex) ) 
		rotationBar:setAnchorPoint(ccp(0.5,0.5))

		rotationeSprite:addChild(rotationBar)

		rotationeSprite:setPosition( ccp(0,halfGridWid*-1) )

		local actArr = CCArray:create()
	
		--actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( 1, math.pi ) ) )
		actArr:addObject( CCRotateTo:create( 0.1, 90 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 180 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 270 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 359 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 90 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 180 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 270 ) )
		actArr:addObject( CCRotateTo:create( 0.1, 359 ) )

		--actArr:addObject( CCCallFunc:create( function ()  end ) )
		rotationeSprite:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
		--rotationeff:runAction( CCRotateTo:create( 0.5, 360 ) )


		container:addChild(rotationeSprite)

		container:setPosition(
			ccp(  
				( gridWid * (GamePlayConfig_Max_Item_Y - 1) ) + (0 * 3) , 
				( gridWid * (GamePlayConfig_Max_Item_Y - row) ) 
				)
			)

		local actArr2 = CCArray:create()
		actArr2:addObject( CCMoveTo:create( 2 , ccp( (0 * 3) , ( gridWid * (GamePlayConfig_Max_Item_Y - row) ) ) ) )
		actArr2:addObject( CCCallFunc:create( function () 
				if container and not container.isDisposed then
					container:stopAllActions()
					rotationeff:stopAllActions()
					container:removeFromParentAndCleanup(true)
				end
			end ) )

		container:runAction( CCSequence:create(actArr2) )

		--convertToNodeSpace
		--convertToWorldSpace

		layer:addChild( container )
	end
end

function GameBoardView:updateWukongTargetBoard()

	--setWukongTargetLightVisible(direction , visible)
	local hasNoBlockTarget = false
	for r=1,#self.baseMap do
		for c=1,#self.baseMap[r] do

			local itemview = self.baseMap[r][c]
			if itemview and itemview.oldBoard and itemview.oldBoard.isWukongTarget then
				local topBoard = nil
				if self.baseMap[r - 1] then
					topBoard = self.baseMap[r - 1][c]
				end
				
				local bottomBoard = nil
				if self.baseMap[r + 1] then
					bottomBoard = self.baseMap[r + 1][c]
				end
				
				local leftBoard = nil
				if self.baseMap[r] then
					leftBoard = self.baseMap[r][c - 1]
				end
				
				local rightBoard = nil
				if self.baseMap[r] then
					rightBoard = self.baseMap[r][c + 1]
				end

				itemview:setWukongTargetLightVisible("top" , not( topBoard and topBoard.oldBoard and topBoard.oldBoard.isWukongTarget ) )
				itemview:setWukongTargetLightVisible("bottom" , not( bottomBoard and bottomBoard.oldBoard and bottomBoard.oldBoard.isWukongTarget ) )
				itemview:setWukongTargetLightVisible("left" , not( leftBoard and leftBoard.oldBoard and leftBoard.oldBoard.isWukongTarget ) )
				itemview:setWukongTargetLightVisible("right" , not( rightBoard and rightBoard.oldBoard and rightBoard.oldBoard.isWukongTarget ) )

				if itemview.oldData and not itemview.oldData.isBlock then
					hasNoBlockTarget = true
				end
			end
		end
	end

	for r=1,#self.baseMap do
		for c=1,#self.baseMap[r] do
			local itemview = self.baseMap[r][c]
			if itemview and itemview.oldBoard and itemview.oldBoard.isWukongTarget then
				if hasNoBlockTarget then
					itemview:playWukongTargetLoopAnimation("slow")
				else
					itemview:playWukongTargetLoopAnimation("default")
				end
			end
		end
	end
end


function GameBoardView:useHedgehogCrazy( item1Pos )
	-- body
	if self.gameBoardLogic:useProps(self.gamePropsType, item1Pos.x, item1Pos.y) then
		self:focusOnItem(nil)
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useWukongJump( item1Pos )
	-- body
	if self.gameBoardLogic:useProps(self.gamePropsType, item1Pos.x, item1Pos.y) then
		self:focusOnItem(nil)
	end
	self.gameBoardLogic.gameMode.useWukongJump = true
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useForceSwap(item1Pos, item2Pos)
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, item1Pos.x, item1Pos.y, item2Pos.x, item2Pos.y) then
        self:focusOnItem(nil)
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
        self.PlayUIDelegate:confirmPropUsed(nil, function() 
        	self.gameBoardLogic:useProps(gamePropsType, item1Pos.x, item1Pos.y, item2Pos.x, item2Pos.y , gamePropsUseType)
        	IngamePropGuideManager:getInstance():onForceSwaped()
        end)
    else
    	self:focusOnItem(nil)
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
    end
    self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useHammer(itemPos)
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, itemPos.x, itemPos.y) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
		self.PlayUIDelegate:confirmPropUsed(nil, function()
			self.gameBoardLogic:useProps(gamePropsType, itemPos.x, itemPos.y , nil , nil , gamePropsUseType)
		end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useBrush(itemPos, direction)
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, itemPos.x, itemPos.y, direction.x, direction.y) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
        self.PlayUIDelegate:confirmPropUsed(nil, function()
			self.gameBoardLogic:useProps(gamePropsType, itemPos.x, itemPos.y, direction.x, direction.y , gamePropsUseType)
        end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
    end
    self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useRandomBird()
	local pos = self.gameBoardLogic:getPositionForRandomBird()
	if pos and self.gameBoardLogic:isUsePropsValid(self.gamePropsType, pos.r, pos.c) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
		self.PlayUIDelegate:confirmPropUsed(self.gameBoardLogic:getGameItemPosInView(pos.r, pos.c), function()
			self.gameBoardLogic:useProps(gamePropsType, pos.r, pos.c , nil ,nil , gamePropsUseType)
		end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useBroom(itemPos)
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, itemPos.r, itemPos.c) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
		self.PlayUIDelegate:confirmPropUsed(self.gameBoardLogic:getGameItemPosInView(itemPos.r, itemPos.c), function()
			self.gameBoardLogic:useProps(gamePropsType, itemPos.r, itemPos.c , nil ,nil , gamePropsUseType)
		end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useJamSpeardHammer(itemPos)
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, itemPos.x, itemPos.y) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
		self.PlayUIDelegate:confirmPropUsed(nil, function()
			self.gameBoardLogic:useProps(gamePropsType, itemPos.x, itemPos.y , nil , nil , gamePropsUseType)
		end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:useLineEffectProps(itemPos)
	local r, c = itemPos.x, itemPos.y
	if self.gameBoardLogic:isUsePropsValid(self.gamePropsType, r, c) then
		local gamePropsType = self.gamePropsType
		local gamePropsUseType = self.gamePropsUseType
		-- printx(11, "=== useLineEffectProps. gamePropsType, gamePropsUseType:", gamePropsType, gamePropsUseType, r, c)
		self.PlayUIDelegate:confirmPropUsed(nil, function()
			self.gameBoardLogic:useProps(gamePropsType, r, c, nil, nil, gamePropsUseType)
		end)
    else
    	if self.PlayUIDelegate.propList then self.PlayUIDelegate.propList:cancelFocus() end
	end
	self.gamePropsType = GamePropsType.kNone
end

function GameBoardView:reInitByGameBoardLogic(gameBoardLogic)
	gameBoardLogic = gameBoardLogic or self.gameBoardLogic
	self:cleanAllItemSprite();
	local boardMap = gameBoardLogic:getBoardMap();
	self:initBaseMapByData(boardMap)					--加载地图信息
	local itemMap = gameBoardLogic:getItemMap()
	self:initBaseMapByItemData(itemMap)				--加载GameItem信息
	self:initBaseMapView()		--初始化显示
end

function GameBoardView:cleanAllItemSprite()
	for r=1,#self.baseMap do
		for c=1,#self.baseMap[r] do
			for i=ItemSpriteType.kBackground, ItemSpriteType.kLast do
				local sprite1 = self.baseMap[r][c].itemSprite[i]
				if sprite1 then 
					if sprite1:getParent() then
						sprite1:removeFromParentAndCleanup(true);
					end
					self.baseMap[r][c].itemSprite[i] = nil;
				end
			end
			self.showPanel[ItemSpriteType.kClipping]:removeChild(self.baseMap[r][c].clippingnode, true)
			self.showPanel[ItemSpriteType.kEnterClipping]:removeChild(self.baseMap[r][c].enterClippingNode, true)
			self.baseMap[r][c] = nil
		end
	end
end

function GameBoardView:TouchAt(x,y)	----返回点击的Item的xy
	----------面板偏移量
	if self.baseLocation == nil then --初始化一些东西
		self.PosStart = ccp(0,0);
		local selfpos_x = self:getPositionX();
		local selfpos_y = self:getPositionY();
		self.PosStart.x = self.PosStart.x + self:getPositionX()
		self.PosStart.y = self.PosStart.y + self:getPositionY()

		self.ItemW = GamePlayConfig_Tile_Width
		self.ItemH = GamePlayConfig_Tile_Height
	end
	if self.PosStart then 			----修正偏移量
		x = x - self.PosStart.x;
		y = y - self.PosStart.y;
	end

	local temp_x = math.ceil(x / self.ItemW / GamePlayConfig_Tile_ScaleX)
	local temp_y = math.ceil(GamePlayConfig_Max_Item_Y -1 - y / self.ItemH / GamePlayConfig_Tile_ScaleY)

	local offsetXInGrid = (x / GamePlayConfig_Tile_ScaleX) % self.ItemW
	local offsetYInGrid = (y / GamePlayConfig_Tile_ScaleY) % self.ItemH

	if temp_x >= 1 and temp_x <= #self.baseMap[1] 
		and temp_y >= 1 and temp_y <= #self.baseMap
		then
		return ccp(temp_y, temp_x) , ccp(offsetXInGrid , offsetYInGrid)
	end
	return ccp(temp_y, temp_x) , ccp(offsetXInGrid , offsetYInGrid)
end

function GameBoardView:onTouchBegan(x, y)
	if not (self.gameBoardLogic.isWaitingOperation and not self.gameBoardLogic.isPaused) then
		ReplayDataManager:onTrySwapFailedInStableState()
		return 
	end
	if self.gameBoardLogic.replayMode == ReplayMode.kReview then return end
	self.interactionController:getCurrentInteraction():handleTouchBegin(x, y)
	return true
end
function GameBoardView:onTouchMoved(x, y)
	if not (self.gameBoardLogic.isWaitingOperation and not self.gameBoardLogic.isPaused) then return end
	if self.gameBoardLogic.replayMode == ReplayMode.kReview then return end
	self.interactionController:getCurrentInteraction():handleTouchMove(x, y)
	return true
end
function GameBoardView:onTouchEnded(x, y)
	if not (self.gameBoardLogic.isWaitingOperation and not self.gameBoardLogic.isPaused) then return end
	if self.gameBoardLogic.replayMode == ReplayMode.kReview then return end
	self.interactionController:getCurrentInteraction():handleTouchEnd(x, y)
	return true
end


function GameBoardView:trySwapItem(x1,y1,x2,y2)
    local ret1 = self.gameBoardLogic:canBeSwaped(x1, y1, x2, y2);
	--可以交换的两个块
	if ret1 == 1 then
		self.gameBoardLogic:startTrySwapedItem(x1, y1, x2, y2)
		self:focusOnItem(nil)
		IngamePropGuideManager:getInstance():onSwaped()
		return true;
	elseif ret1 == 2 then
		self.gameBoardLogic:startTrySwapedItemFun(x1,y1,x2,y2)
		self:focusOnItem(nil)
		return true;
	else
		return false;
	end
end

-- isHalloween 为了兼容magic tile障碍加入一个clippingNode
function GameBoardView:initView(container, context, isHalloween)
	local showPanel = {}
	self.isHalloween = isHalloween

	for _, i in ipairs(DefaultVisibleLayers) do
		if not showPanel[i] then
			showPanel[i] = self:buildSingleLayerByType(i)
			container:addChild(showPanel[i])
		end
	end

	context.showPanel = showPanel
	
	local function getFntName(color)
		local namestr = "score_yellow"

		if color == 1 then
			namestr = "score_blue"
		elseif color == 2 then
			namestr = "score_green"
		elseif color == 3 then
			namestr = "score_brown"
		elseif color == 4 then
			namestr = "score_purple"
		elseif color == 5 then
			namestr = "score_red"
		elseif color == 6 then
			namestr = "score_yellow"
		end

		return namestr
	end

	if self.labelBatchs == nil then
		self.labelBatchs = {}
		for i = 1 , 6 do
			local labelBatch = BMFontLabelBatch:create("fnt/" .. getFntName(i) .. ".png",
								"fnt/" .. getFntName(i) .. ".fnt",
								100)
			table.insert( self.labelBatchs , labelBatch )
			self:addChild(labelBatch);
		end
	end

	if self.specialEffectBatch == nil then
		--直线特效显示层
		self.specialEffectBatch = CocosObject:create()
		self.specialEffectBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/explode.png"),100))
		self:addChild(self.specialEffectBatch)
	end

	if self.specialEffectHighNode == nil then
		-- 特效上层
		self.specialEffectHighNode = CocosObject:create(CCNode:create())
		self:addChild(self.specialEffectHighNode)
	end
	-- 两周年活动特效使用，其他地方未使用
	-- if self.isHalloween and self.rainbowBatch == nil then
	-- 	self.rainbowBatch = CocosObject:create()
	-- 	self.rainbowBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/two_year_line_effect.png"),100))
	-- 	self:addChild(self.rainbowBatch)
	-- end

end

function GameBoardView:buildSingleLayerByType(layerType)
	local result 
	if layerType == ItemSpriteType.kBackground then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapTiles.png"), 200));--100表示预计有100个物体
	elseif layerType == ItemSpriteType.kScrollBackground then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapTiles.png"), 200));--100表示预计有100个物体
	elseif layerType == ItemSpriteType.kMoveTileBackground then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/map_move_tile.png"), 81));--100表示预计有100个物体
	elseif layerType == ItemSpriteType.kColorFilterB then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/color_filter_b.png"), 100));--100表示预计有100个物体
	elseif layerType == ItemSpriteType.kLock or layerType == ItemSpriteType.kItem then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapBaseItem.png"), 200));--100表示预计有100个物体
	elseif layerType == ItemSpriteType.kLight then
		result = CocosObject:create()
		if self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
			result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/autumn2018/mid_autumn_res.png"), 90));
		else
			result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapLight.png"), 200));
		end
	elseif layerType == ItemSpriteType.kPass then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/link_item.png"), 200));
	elseif layerType == ItemSpriteType.kLockShow then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapLock.png"), 100));
	elseif layerType == ItemSpriteType.kSnowShow then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapSnow.png"), 100));
	elseif layerType == ItemSpriteType.kItemDestroy then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/board_effects.png"), 100));
	elseif layerType == ItemSpriteType.kSnailRoad then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/snail_road.png"), 100));
	elseif layerType == ItemSpriteType.kHedgehogRoad then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/hedgehog_road.png"), 100));
	elseif layerType == ItemSpriteType.kDigBlocker then
        result = CocosObject:create()
		if self.gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
			result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/week_gress.png"), 200));
		else
			result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/dig_block.png"), 200));
		end
	elseif layerType == ItemSpriteType.kDigBlockerBomb then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/dig_block.png"), 200));
	elseif self.isHalloween and (layerType == ItemSpriteType.kTileBlocker or layerType == ItemSpriteType.kRope) then
		result = SimpleClippingNode:create()
		result:setContentSize(CCSizeMake(GamePlayConfig_Tile_Width * 9, GamePlayConfig_Tile_Height * self.rowCount))
	elseif layerType == ItemSpriteType.kSand then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/sand_idle_clean.png"), 100));
	elseif layerType == ItemSpriteType.kSandMove then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/sand_move.png"), 100));
	elseif layerType == ItemSpriteType.kChain then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/ice_chain.png"), 100));
	elseif layerType == ItemSpriteType.kMagicStoneFire then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/magic_stone.png"), 100));
	elseif layerType == ItemSpriteType.kCrystalStoneEffect then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/crystal_stone.png"), 100));
	elseif layerType == ItemSpriteType.kSeaAnimal then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/sea_animal.png"), 25));
	elseif layerType == ItemSpriteType.kGameGuideEffect then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mapTiles.png"), 100));
	elseif layerType == ItemSpriteType.kTileHighLightEffect then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/tile_high_lights.png"), 81));
	elseif layerType == ItemSpriteType.kTopLevelHighLightEffect then
		result = CocosObject:create()
		if self.gamePlayType ~= GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
			result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/tile_high_lights.png"), 81));
		end
	elseif layerType == ItemSpriteType.kBlocker199Effect then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/blocker199.png"), 81))
	elseif layerType == ItemSpriteType.kBlocker211Effect then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/blocker211.png"), 200))
	elseif layerType == ItemSpriteType.kOlympicLock then
		result = CocosObject:create()
	elseif layerType == ItemSpriteType.kPacmanShow then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/pacman.png"), 81))
	elseif layerType == ItemSpriteType.kMoleWeeklyItemShow then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/mole_weeklyRace_seed.png"), 24))	--产品预计是有8个，多点余量
    elseif layerType == ItemSpriteType.kJamSperad then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/JamSperad.png"), 81))
	elseif layerType == ItemSpriteType.kSquidShow then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/squidBlocker.png"), 40))
	elseif layerType == ItemSpriteType.kBiscuit then
		result = CocosObject:create()
		result:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/biscuit_sp.png"), 40))
	else
		result = CocosObject:create()
	end
	return result
end

function GameBoardView:insertNewLayer(container, showPanel, layerType)
	local existLayerIndexList = {}
	local childIdx = 0

	for idx, _ in pairs(showPanel) do
		table.insert(existLayerIndexList, idx)
	end

	table.sort(existLayerIndexList)

	for _, idx in ipairs(existLayerIndexList) do
		if layerType < idx then
			break
		end
		childIdx = childIdx + 1
	end

	showPanel[layerType] = self:buildSingleLayerByType(layerType)
	container:addChildAt(showPanel[layerType], childIdx)
end

function GameBoardView:RegisterAll()
	if _G.isLocalDevelopMode then printx(0, "GameBoardView:RegisterAll()") end
	------注册点击函数----
	local  context = self
	local function onTouch(eventType, x, y)
		local offsetY = _G.clickOffsetY or 0
		y = y + offsetY
		if eventType == "began" then   
			return context:onTouchBegan(x, y)
		elseif eventType == "moved" then
			return context:onTouchMoved(x, y)
		else
			return context:onTouchEnded(x, y)
		end
	end

	if self.isTouchReigister == false then
		self.isTouchReigister = true
		self.refCocosObj:setTouchEnabled(true) 
		self:registerScriptTouchHandler(onTouch)
	end

	--注册响应函数，按帧响应
	local _execute_frames = 0
	local _execute_time = 0
--	local performance = require("hecore.performance"):new()
	local function _updateGame(dt)
--		performance:start()
		
		if not self.replayMode or self.replayMode == ReplayMode.kNone then
			-- 不是录像回放
			context:updateGame(dt)
		elseif self.replayMode and self.replayMode == ReplayMode.kResume then
			-- 闪退恢复中

			if CrashResumeGamePlaySpeedUp and self.gameBoardLogic.replaying --[[and not self.gameBoardLogic.isCrashResumeDone]] then
				context:updateGame(dt)
			else
				context:updateGame(dt)
			end
			--context:updateGame(dt)
		else
			context:updateGame(dt)
		end
		
		--context:updateGame(dt)
    -- wp8需要补帧
		if __WP8 then
			_execute_frames = _execute_frames + 1
			_execute_time = _execute_time + dt
			if _execute_time > 0 and (_execute_frames + 1) / _execute_time < 60 then
				context:updateGame(0)
				_execute_frames = _execute_time * 60
			end
		end

--		performance:finish("GameBoardView:_updateGame")
	end
	self.___updateGame = _updateGame
	if self.isRegisterUpdate == false then
		local time_cd = 1.0 / GamePlayConfig_Action_FPS    
		if __WIN32 then
			self.updateScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(_updateGame, 0, false)
		else
			self.updateScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(_updateGame, time_cd, false)
		end
		
		self.isRegisterUpdate = true
		if __WP8 then
			if _G.isLocalDevelopMode then printx(0, "clear for wp8 when begin game") end
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
			collectgarbage("collect")
		end
	end

end

function GameBoardView:onVirtualFrameDone(dt)

end

-- 改变游戏速度
-- multiple 倍数
function GameBoardView:changeGameSpeed(multiple)
	local time_cd = 1.0 / (GamePlayConfig_Action_FPS*multiple)
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>time_cd>>>>>>>>>>>>>>>"..tostring(time_cd)) end
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateScheduler)
	self.updateScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.___updateGame, time_cd, false)
end


function GameBoardView:unRegisterAll()
	if self.isTouchReigister == true then
		self.isTouchReigister = false
		self.refCocosObj:setTouchEnabled(false) 
		self:unregisterScriptTouchHandler()
	end

	if self.isRegisterUpdate == true then
		self.isRegisterUpdate =false
		Director:getScheduler():unscheduleScriptEntry(self.updateScheduler)
		self.updateScheduler = nil;
		if __WP8 then
			if _G.isLocalDevelopMode then printx(0, "clear for wp8 when end game") end
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
			collectgarbage("collect")
		end
	end
end

----游戏逻辑更新循环
function GameBoardView:updateGame(dt)
	if self.isPaused == false then 
		self.gameBoardLogic:updateGame(dt) 		----游戏逻辑推进---1.runAction---2.检测掉落
		self:updateItemViewByLogic()			----界面展示刷新
		BoardViewAction:runAllAction(self)		----对应动作变化

		local changedGravityMap = {}
		local hasGravityChanged = false

		local gravitySkinMap = self.gravitySkinViewLogic:getNeedBuildGravitySkinMap()
		if gravitySkinMap then
			for k , v in pairs(gravitySkinMap) do
				if v.update then
					self.gravitySkinViewLogic:buildGravitySkinAt( v.r , v.c ) ----计算单个格子的新的重力方向特效
					local board = self.gameBoardLogic.boardmap[v.r][v.c]
					changedGravityMap[ board:getGravitySkinType() ] = true
					hasGravityChanged = true
				end
			end

			if hasGravityChanged then
				for k , v in pairs( changedGravityMap ) do
					--有些重力皮肤不是单个格子独立更新的，而是一旦更新，所有的同类型格子都要重绘（比如有复杂的拼接效果）
					--这样的逻辑都放到 buildMultipleGravitySkinBySkinType 里处理
					self.gravitySkinViewLogic:buildMultipleGravitySkinBySkinType( k )
				end
			end
		end                                   
		self:updateItemViewSelf()				----界面自我刷新
		PropsAnimation:updateAnimation()		----道具骨骼动画
	end
end

function GameBoardView:getViewContext()
	if not self.itemViewContext then
		self.itemViewContext = {}
		self.itemViewContext.levelType = self.gameBoardLogic.levelType
		self.itemViewContext.theGamePlayType = self.gameBoardLogic.theGamePlayType
		self.itemViewContext.startRowIndex = self.startRowIndex
		self.itemViewContext.startColIndex = self.startColIndex
	end
	return self.itemViewContext
end

function GameBoardView:initBaseMapByData(boardmap)--初始化基本地图
	if not self.baseMap then
		self.baseMap = {}
		for i=1,9 do
			self.baseMap[i] = {}
		end
	end

	local function getContainer(layerType)
		if not self.showPanel[layerType] then
			self:insertNewLayer(self, self.showPanel, layerType)
		end
		return self.showPanel[layerType]
	end

	--创建地图显示用格子
	local boderInfo = self:getBoderInfo(boardmap)

	self.gravitySkinViewLogic:initByBoardMap( boardmap )

	for i=1, #boardmap do
		if self.baseMap[i] == nil then self.baseMap[i] = {} end		--地图显示
		if boderInfo[i] == nil then boderInfo[i] = {} end

		for j=1,#boardmap[i] do
			self.baseMap[i][j] = ItemView:create(self:getViewContext())
			self.baseMap[i][j].getContainer = getContainer
			self.baseMap[i][j]:initByBoardData(boardmap[i][j], boderInfo[i][j])
			self.baseMap[i][j]:initPosBoardDataPos(boardmap[i][j])
		end
	end

	self.gravitySkinViewLogic:buildAllGravitySkin()
end

function GameBoardView:initBaseMapByItemData(ItemMap)--初始化基本地图
	for i=1, #ItemMap do
		if self.baseMap[i] == nil then self.baseMap[i] = {} end		--地图显示
		for j=1,#ItemMap[i] do
			if self.baseMap[i][j] == nil then self.baseMap[i][j] = ItemView:create(self:getViewContext()) end
			self.baseMap[i][j]:initByItemData(ItemMap[i][j])
			self.baseMap[i][j]:initPosBoardDataPos(ItemMap[i][j], true)
		end
	end
end

function GameBoardView:updateItemViewByLogic() 			--------因为Logic的变化导致界面变化
	local boardmap = self.gameBoardLogic:getBoardMap();
	local itemMap = self.gameBoardLogic:getItemMap()
	local baseMap = self.baseMap

	local m = #boardmap

	for i = 1, m do
		local boardmapI = boardmap[i]  --GameBoardData实例，棋盘格数据
		local itemMapI = itemMap[i]    --GameItemData实例，棋盘Item实例
		local baseMapI = baseMap[i]    --ItemView实例，棋盘格子视图（包括Item和底板）

		local n = #boardmapI
		for j = 1, n do 
			local boardmapIJ = boardmapI[j]
			local baseMapIJ = baseMapI[j]
			local itemMapIJ = itemMapI[j]

			local ts = 0
			if boardmapIJ.isNeedUpdate == true then 			----地图数据发生变化
				ts = 1
				local resultInfo = baseMapIJ:updateByNewBoardData(boardmapIJ)
				if resultInfo then
					-- printx( 1 , "resultInfo " , i , j ,  resultInfo.gravityInfo.gravityChanged , resultInfo.gravityInfo.gravitySkinChanged )
					if resultInfo.gravityInfo and (resultInfo.gravityInfo.gravityChanged or resultInfo.gravityInfo.gravitySkinChanged) then
						self.gravitySkinViewLogic:setNeedBuildGravitySkinAt( true , i , j )
					end
				end
			end

			if itemMapIJ.isNeedUpdate == true then 				----地图上的Item发生变化
				baseMapIJ:updateByNewItemData(itemMapIJ)	-----更新Item的显示数据------
				ts = 2
			end

			if ts ~= 0 then
				self:updateBaseMapViewItem(i,j)							-----更新Item的Layer从属关系------
				if ts == 2 then 
					baseMapIJ:upDatePosBoardDataPos(itemMapIJ, true)----------更新Item的显示位置-------
				end
			end
		end
	end
end

function GameBoardView:updateItemViewSelf()
	for i= 1, #self.baseMap do
		for j = 1, #self.baseMap[i] do

			if self.baseMap[i][j].isNeedUpdate == true then
				self.baseMap[i][j].isNeedUpdate = false
				self:updateBaseMapViewItem(i,j)
			end
		end
	end

	-- 棋盘震动更新
	self:viberateUpdate()
end

----更新节点从属关系
function GameBoardView:updateBaseMapViewItem(r,c)
	-- printx( 1 , "GameBoardView:updateBaseMapViewItem " , r,c )
	local fuck = false
	
	for k = ItemSpriteType.kBackground, ItemSpriteType.kLast do

		-- if r == 4 and c == 1 and k == ItemSpriteType.kGravitySkinBottom then
		-- 	fuck = true
		-- 	printx( 1 , "GameBoardView:updateBaseMapViewItem " , r,c )
		-- else
		-- 	fuck = false
		-- end
		
		local itemSprite = self.baseMap[r][c]:getItemSprite(k);
		-- if fuck then printx(1 , "FFFFF 111 " , k  ,itemSprite) end
		if itemSprite then
			-- if fuck then printx(1 , "FFFFF 222 " , itemSprite:getParent()) end
			if itemSprite:getParent() == nil then
				-- if fuck then printx(1 , "FFFFF 333 " , itemSprite.refCocosObj) end
				if (itemSprite.refCocosObj ~= nil) then
					if not self.showPanel[k] then 
						self:insertNewLayer(self, self.showPanel, k)
					end
					-- if fuck then printx(1 , "FFFFF 444 " ) end
					self.showPanel[k]:addChild(itemSprite)
				else
					if _G.isLocalDevelopMode then printx(0, "itemSprite.refCocosObj == nil  r, c, k", r, c, k) end
					self.baseMap[r][c].itemSprite[k] = nil;
				end
			end
		end
	end
end

function GameBoardView:initBaseMapView()
	for i=1, #self.baseMap do
		for j=1, #self.baseMap[i] do
			if self.baseMap[i][j] then
				for k = ItemSpriteType.kBackground, ItemSpriteType.kLast do
					local itemSprite = self.baseMap[i][j]:getItemSprite(k);
					if itemSprite then
						if not itemSprite:getParent() then
							if (itemSprite.refCocosObj ~= nil) then
								if not self.showPanel[k] then 
									self:insertNewLayer(self, self.showPanel, k)
								end
								self.showPanel[k]:addChild(itemSprite)
							else
								if _G.isLocalDevelopMode then printx(0, "itemSprite.refCocosObj == nil  r, c, k", r, c, k) end
								self.baseMap[i][j].itemSprite[k] = nil;
							end
						end
					end
				end
			end
		end
	end
end

function GameBoardView:initDigScrollView(gameItemMap, boardMap)
	self:createDigScrollView(gameItemMap, boardMap)
	self.digViewContainer:setPosition(ccp(self.clippingDelta/2, self.digViewContainer.numExtraRow * GamePlayConfig_Tile_Height))
end

function GameBoardView:scrollMoreDigView(gameItemMap, boardMap, completeCallback)
	self:createDigScrollView(gameItemMap, boardMap)
	self.digViewContainer:setPositionX(self.clippingDelta/2)
	local actionList = CCArray:create()
	local time = self.digViewContainer.numExtraRow * 0.3
	actionList:addObject(CCMoveTo:create(time, ccp(self.clippingDelta/2, self.digViewContainer.numExtraRow * GamePlayConfig_Tile_Height)))
	actionList:addObject(CCCallFunc:create(completeCallback))
	local sequenceAction = CCSequence:create(actionList)
	self.digViewContainer:runAction(sequenceAction)
	return time, self.digViewContainer.numExtraRow
end

function GameBoardView:createDigScrollView(gameItemMap, boardMap)
	local startRowIndex = self.startRowIndex
	local rowCount = self.rowCount

	if self.gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID or self.gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
		self.clippingDelta = GamePlayConfig_Tile_BorderWidth * 2 + 2
	end
	local clippingnode = SimpleClippingNode:create()
	clippingnode:setContentSize(CCSizeMake(GamePlayConfig_Tile_Width * 9 + self.clippingDelta, GamePlayConfig_Tile_Height * rowCount + self.clippingDelta/2))
	self:addChild(clippingnode)
	clippingnode:setPositionX(-self.clippingDelta/2)

	local digViewContainer = CocosObject:create()
	clippingnode:addChild(digViewContainer)

	self.digClippingNode = clippingnode
	self.digViewContainer = digViewContainer
	self.digContext = {}

	local function getItemContainer(layerType)
		if not self.digContext.showPanel[layerType] then
			self:insertNewLayer(self.digViewContainer, self.digContext.showPanel, layerType)
		end
		return self.digContext.showPanel[layerType]
	end

	local boderInfo = self:getBoderInfo(boardMap)

	local function initItemViewByData()
		for i = startRowIndex, #gameItemMap do
			if self.digBaseMap[i] == nil then self.digBaseMap[i] = {} end
			if boderInfo[i] == nil then boderInfo[i] = {} end
			for j = 1, #gameItemMap[i] do
				if self.digBaseMap[i][j] == nil then self.digBaseMap[i][j] = ItemView:create(self:getViewContext()) end
				self.digBaseMap[i][j].getContainer = getItemContainer
				self.digBaseMap[i][j]:initByBoardData(boardMap[i][j], boderInfo[i][j])
				self.digBaseMap[i][j]:initByItemData(gameItemMap[i][j])
				self.digBaseMap[i][j]:initPosBoardDataPos(gameItemMap[i][j], true)
			end
		end
	end

	local function addItemViewToContainer()
		for i = startRowIndex, #self.digBaseMap do
			for j = 1, #self.digBaseMap[i] do
				if self.digBaseMap[i][j] then
					for idx, layerIdx in ipairs(needCopyLayers) do
						local itemSprite = self.digBaseMap[i][j]:getItemSprite(layerIdx)
						if itemSprite then
							if not itemSprite:getParent() then
								if (itemSprite.refCocosObj ~= nil) then
									if not self.digContext.showPanel[layerIdx] then
										self:insertNewLayer(self.digViewContainer, self.digContext.showPanel, layerIdx)
									end
									self.digContext.showPanel[layerIdx]:addChild(itemSprite)
								else
									self.baseMap[i][j].itemSprite[layerIdx] = nil
								end
							end
						end
					end
				end
			end
		end
	end

	self:initView(digViewContainer, self.digContext)
	self.digBaseMap = {}
	initItemViewByData()
	addItemViewToContainer()

	self.digViewContainer.numExtraRow = #gameItemMap - 9
end

function GameBoardView:removeDigScrollView()
	if self.digContext then
		for idx, layerIdx in ipairs(needCopyLayers) do
			if self.digContext.showPanel[layerIdx] and self.digContext.showPanel[layerIdx]:getParent() then
				self.digContext.showPanel[layerIdx]:removeFromParentAndCleanup(true)
				self.digContext.showPanel[layerIdx] = nil
			end
		end
		self.digContext = nil
	end

	if self.digViewContainer then
		self.digViewContainer:stopAllActions()
		self.digViewContainer:removeFromParentAndCleanup(true)
		self.digViewContainer = nil
	end

	if self.digClippingNode then
		self.digClippingNode:removeFromParentAndCleanup(true)
		self.digClippingNode = nil
	end

	if self.digBaseMap then
		self.digBaseMap = nil
	end

	if self.digContext then
		self.digContext = nil
	end
end

local kClippingnodeTopBottomPadding = 8

function GameBoardView:__initDigScrollLayer(completeCallback)
	self.scrollEndCallBack = completeCallback
	self.canSpeedUpFlag = true
	self.touchEvtLayer = Layer:create()
	local origin = Director:sharedDirector():getVisibleOrigin()
	self.touchEvtLayer:setPosition(ccp(origin.x, origin.y))
	self.touchEvtLayer.hitTestPoint = function()
		return true
	end
	
	self.touchEvtLayer:ad(DisplayEvents.kTouchBegin, function(evt)
		self:speedUpScrollDigView()
	end)
	self.touchEvtLayer:setTouchEnabled(true, -10000, true)
	self:addChild(self.touchEvtLayer)
end

function GameBoardView:__onDigScrollEnd()
	if self.scrollEndCallBack ~= nil then 
		self.scrollEndCallBack()
		self.scrollEndCallBack = nil
		self.touchEvtLayer:removeFromParentAndCleanup(true)
		self.touchEvtLayer = nil
		self.canSpeedUpFlag = false
	end
end

function GameBoardView:createSpeedupTouchlayerForBonusTime( touchCallback )
	self.touchEvtLayer = Layer:create()
	local origin = Director:sharedDirector():getVisibleOrigin()
	self.touchEvtLayer:setPosition(ccp(origin.x, origin.y))
	self.touchEvtLayer.hitTestPoint = function()
		return true
	end
	
	self.touchEvtLayer:ad(DisplayEvents.kTouchBegin, function(evt)
		if touchCallback then touchCallback() end
		self.touchEvtLayer:removeFromParentAndCleanup(true)
		self.touchEvtLayer = nil
	end)
	self.touchEvtLayer:setTouchEnabled(true, -10000, true)
	self:addChild(self.touchEvtLayer)
end

function GameBoardView:removeSpeedupTouchlayerForBonusTime()
	if self.touchEvtLayer then self.touchEvtLayer:removeFromParentAndCleanup(true) end
end

function GameBoardView:startScrollInitDigView(completeCallback)
	self:__initDigScrollLayer(completeCallback)
	self.inVScrollAnim = true
	self:__startScrollDig()
end

function GameBoardView:__startScrollDig()
	local scrollHeight = self.digViewContainer:getPositionY() - kClippingnodeTopBottomPadding
	local actionList = CCArray:create()
	actionList:addObject(CCMoveTo:create(scrollHeight / (SCROLL_V * self.scrollScale), ccp(self.clippingDelta/2, kClippingnodeTopBottomPadding)))
	actionList:addObject(CCCallFunc:create(function()
		self:__onDigScrollEnd()
		self.inVScrollAnim = false
	end))
	local sequenceAction = CCSequence:create(actionList)
	self.digViewContainer:runAction(sequenceAction)
end

function GameBoardView:speedUpScrollDigView()
	if self.canSpeedUpFlag and self.scrollEndCallBack ~= nil then
		self.canSpeedUpFlag = false
		self.scrollScale = DIG_SCROLL_SCALE
		self.digViewContainer:stopAllActions()
		if self.inVScrollAnim then
			self:__startScrollDig()
		elseif self.inHScrollAnim then
			self:__startHorizontalScrollDig()
		end
	end
end

function GameBoardView:initHorizontalScrollView(gameItemMap, boardMap)
	self:createHorizontalScorllView(gameItemMap, boardMap)
	self.digViewContainer:setPosition(ccp(-self.digViewContainer.numExtraCol * GamePlayConfig_Tile_Height, kClippingnodeTopBottomPadding))
end

function GameBoardView:createHorizontalScorllView(gameItemMap, boardMap)
	local clippingnode = SimpleClippingNode:create()

	local x = GamePlayConfig_Tile_Width * (self.startColIndex - 1)
	local y = -kClippingnodeTopBottomPadding
	local width = GamePlayConfig_Tile_Width * self.colCount
	local height = GamePlayConfig_Tile_Height * self.rowCount+ kClippingnodeTopBottomPadding * 2

	clippingnode:setContentSize(CCSizeMake(width,height))
	clippingnode:setPositionX(x)
	clippingnode:setPositionY(y)
	self:addChild(clippingnode)

	local digViewContainer = CocosObject:create()
	clippingnode:addChild(digViewContainer)
	
	self.digClippingNode = clippingnode
	self.digViewContainer = digViewContainer
	self.digContext = {}

	local function getItemContainer(layerType)
		if not self.digContext.showPanel[layerType] then
			self:insertNewLayer(self.digViewContainer, self.digContext.showPanel, layerType)
		end
		return self.digContext.showPanel[layerType]
	end
	
	local boderInfo = self:getBoderInfo(boardMap)

	local function initItemViewByData()
		for i = 1, #gameItemMap do
			if self.digBaseMap[i] == nil then self.digBaseMap[i] = {} end
			for j = self.startColIndex, #gameItemMap[i] do
				if self.digBaseMap[i][j] == nil then self.digBaseMap[i][j] = ItemView:create(self:getViewContext()) end
				self.digBaseMap[i][j].getContainer = getItemContainer
				self.digBaseMap[i][j]:initByBoardData(boardMap[i][j], boderInfo[i][j])
				self.digBaseMap[i][j]:initByItemData(gameItemMap[i][j])
				self.digBaseMap[i][j]:initPosBoardDataPos(gameItemMap[i][j], true)
			end
		end
	end

	local function addItemViewToContainer()
		for i = 1, #self.digBaseMap do
			for j = self.startColIndex, #self.digBaseMap[i] do
				if self.digBaseMap[i][j] then
					for idx, layerIdx in ipairs(needCopyLayers) do
						local itemSprite = self.digBaseMap[i][j]:getItemSprite(layerIdx)
						if itemSprite then
							if not itemSprite:getParent() then
								if (itemSprite.refCocosObj ~= nil) then
									if not self.digContext.showPanel[layerIdx] then
										self:insertNewLayer(self.digViewContainer, self.digContext.showPanel, layerIdx)
									end
									self.digContext.showPanel[layerIdx]:addChild(itemSprite)
								else
									self.baseMap[i][j].itemSprite[layerIdx] = nil
								end
							end
						end
					end
				end
			end
		end
	end

	self:initView(digViewContainer, self.digContext)
	self.digBaseMap = {}
	initItemViewByData()
	addItemViewToContainer()

	-- if _G.isLocalDevelopMode then printx(0, "GameExtandPlayLogic:clacBoardColCount(boardMap)=", GameExtandPlayLogic:clacBoardColCount(boardMap)) end
	self.digViewContainer.numExtraCol = GameExtandPlayLogic:clacBoardColCount(boardMap) - 9
end

function GameBoardView:startHorizontalScrollInitView(completeCallback)
	self:__initDigScrollLayer(completeCallback)
	self.inHScrollAnim = true
	self:__startHorizontalScrollDig()
end

function GameBoardView:__startHorizontalScrollDig()
	local scrollWidth = math.abs(self.digViewContainer:getPositionX() + GamePlayConfig_Tile_Width * (self.startColIndex-1))
	local actionList = CCArray:create()
	actionList:addObject(CCMoveTo:create(scrollWidth / (SCROLL_V * self.scrollScale), ccp(-GamePlayConfig_Tile_Width * (self.startColIndex-1), kClippingnodeTopBottomPadding)))
	actionList:addObject(CCCallFunc:create(function()
		self:__onDigScrollEnd()
		self.inHScrollAnim = false
	end))
	local sequenceAction = CCSequence:create(actionList)
	self.digViewContainer:runAction(sequenceAction)
end

function GameBoardView:horizontalScrollMoreDigView(gameItemMap, boardMap, completeCallback)
	self:createHorizontalScorllView(gameItemMap, boardMap)
	local originPos = ccp(-GamePlayConfig_Tile_Width * (self.startColIndex - 1), kClippingnodeTopBottomPadding)
	self.digViewContainer:setPosition(originPos)
	local actionList = CCArray:create()
	local moveToPos = ccp(-GamePlayConfig_Tile_Width * (self.digViewContainer.numExtraCol + (self.startColIndex - 1)), kClippingnodeTopBottomPadding)
	local time = self.digViewContainer.numExtraCol * 0.5
	actionList:addObject(CCMoveTo:create(time, moveToPos))
	actionList:addObject(CCCallFunc:create(completeCallback))
	local sequenceAction = CCSequence:create(actionList)
	self.digViewContainer:runAction(sequenceAction)
	return time, self.digViewContainer.numExtraCol
end

function GameBoardView:hideItemViewLayer()
	for i, layerIndex in ipairs(needCopyLayers) do
		local layerContainer = self.showPanel[layerIndex]
		if layerContainer then
			layerContainer:setVisible(false)
		end
	end
end

function GameBoardView:showItemViewLayer()
	for i, layerIndex in ipairs(needCopyLayers) do
		local layerContainer = self.showPanel[layerIndex]
		if layerContainer then
			layerContainer:setVisible(true)
		end
	end
end

--焦点转移至Item(x,y)上
function GameBoardView:focusOnItem(target)
	if self.gameBoardLogic.isWaitingOperation and self.gameBoardLogic.theGamePlayStatus == GamePlayStatus.kNormal then
		if target then
			self:playSelectEffect(target.x, target.y)
		else
			self:stopOldSelectEffect()
		end
	end
end

function GameBoardView:playSelectEffect(r, c)
	if self.oldSelectTarget and self.oldSelectTarget.r == r and self.oldSelectTarget.c == c then
		return
	end

	local itemView = self.baseMap[r][c]
	local itemData = self.gameBoardLogic.gameItemMap[r][c]

	-- printx(11, "格子对象状态：", table.tostringByKeyOrder(itemData))
	-- local boardData = self.gameBoardLogic.boardmap[r][c]
	-- printx(11, "格子状态：", table.tostringByKeyOrder(boardData))

	if itemView == nil or itemData == nil 
		or not itemData.isUsed 
		or itemData.isEmpty then
		return
	end

	self:stopOldSelectEffect()
	self.oldSelectTarget = { r = r, c = c }
	itemView:playSelectEffect(itemData)
	GamePlayMusicPlayer:playEffect(GameMusicType.kKeyboard)
end

function GameBoardView:stopOldSelectEffect()
	if self.oldSelectTarget then
		if _G.isLocalDevelopMode then printx(0, "----------stop old select effect") end
		local oldSelectItemView = self.baseMap[self.oldSelectTarget.r][self.oldSelectTarget.c]
		local oldSelectItemData = self.gameBoardLogic.gameItemMap[self.oldSelectTarget.r][self.oldSelectTarget.c]
		oldSelectItemView:stopSelectEffect(oldSelectItemData)
		self.oldSelectTarget = nil
	end
end

function GameBoardView:showSelectRowOrColumnEffect(r, c, isColumn)
	local positionIndex = r
	if isColumn then
		positionIndex = c
	end

	self:removeSelectRowOrColumnEffect()
	if positionIndex and positionIndex > 0 then
		self:_setTargetGridHighlightVisible(positionIndex, isColumn, true)
		self.oldSelectedLineIndex = {positionIndex = positionIndex, isColumn = isColumn}
	end
end

function GameBoardView:removeSelectRowOrColumnEffect()
	if self.oldSelectedLineIndex then
		local positionIndex = self.oldSelectedLineIndex.positionIndex
		local isColumn = self.oldSelectedLineIndex.isColumn
		if positionIndex and positionIndex > 0 then
			self:_setTargetGridHighlightVisible(positionIndex, isColumn, false)
		end
		self.oldSelectedLineIndex = nil
	end
end

function GameBoardView:_setTargetGridHighlightVisible(positionIndex, isColumn, visible)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local targetItem
	local targetView
	if mainLogic and mainLogic.gameItemMap and mainLogic.boardView and mainLogic.boardView.baseMap then
		local gameItemMap = mainLogic.gameItemMap
		if isColumn then
			for r = 1, #gameItemMap do
				if gameItemMap[r] then
					targetItem = gameItemMap[r][positionIndex]
					if targetItem and targetItem.isUsed and mainLogic.boardView.baseMap[r] then
						targetView = mainLogic.boardView.baseMap[r][positionIndex]
						if targetView then
							if visible then
								targetView:showBoardHighlightEffect()
							else
								targetView:removeBoardHighlightEffect()
							end
							targetView.isNeedUpdate = true
						end
					end
				end
			end	
		else
			if gameItemMap[positionIndex] then
				for c = 1, #gameItemMap[positionIndex] do
					targetItem = gameItemMap[positionIndex][c]
					if targetItem and targetItem.isUsed and mainLogic.boardView.baseMap[positionIndex] then
						targetView = mainLogic.boardView.baseMap[positionIndex][c]
						if targetView then
							if visible then
								targetView:showBoardHighlightEffect()
							else
								targetView:removeBoardHighlightEffect()
							end
							targetView.isNeedUpdate = true
						end
					end
				end	
			end
		end
	end
end

function GameBoardView:getBoderInfo(boardMap)
	local sideH = GamePlayConfig_Tile_Width
	local sideV = GamePlayConfig_Tile_Height
	local sideB = GamePlayConfig_Tile_BorderWidth

	local boderInfo = {}

	local function isBoardWithoutBg(r,c)
		return not boardMap[r][c].isUsed or boardMap[r][c].isMoveTile or boardMap[r][c].isTangChickenBoard
	end

	for i = 1, #boardMap do
		boderInfo[i] = {}
		for j = 1, #boardMap[i] do
			boderInfo[i][j] = {}

			if not isBoardWithoutBg(i,j) then
				if j <= 1 or isBoardWithoutBg(i, j - 1) then -- 左
					boderInfo[i][j].left = {"map_tile_edge_long.png", 0, 0, 1, 1, 270}
				end

				if i <= 1 or isBoardWithoutBg(i-1, j) then -- 上
					local accWidth = side1
					local widthScale = 1
					if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then
						widthScale = (sideH - sideB) / sideH
					end
					boderInfo[i][j].top = {"map_tile_edge_long.png", 0, sideV, widthScale, 1, 0}
				end


				if j >= #boardMap[i] or isBoardWithoutBg(i, j+1) then -- 右
					local finY = sideV / 2
					local finHeight = sideV
					if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then
					 	finY = finY - sideB
					 	finHeight = sideV - sideB
					end
					if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then
						finHeight = finHeight - sideB
					end
					local heightScale = finHeight / sideH

					boderInfo[i][j].right = {"map_tile_edge_long.png", sideH, finY + sideV / 2, heightScale, 1, 90}
				end


				if i >= #boardMap or isBoardWithoutBg(i+1, j) then -- 下
					local finX = sideH / 2
					local widthScale = 1
					if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then
						finX = finX - sideB
						widthScale = (sideH - sideB) / sideH
					end

					boderInfo[i][j].down = {"map_tile_edge_long.png", finX + sideH / 2, 0, widthScale, 1, 180}
				end


				if i <= 1 or j <= 1 or isBoardWithoutBg(i-1, j-1) then -- 左上
					if (i<= 1 or isBoardWithoutBg(i-1,j)) and (j <= 1 or isBoardWithoutBg(i,j-1)) then
						boderInfo[i][j].left_top = {"map_tile_corner.png", - sideB, sideV, 1, 1, 0}
					end
				end


				if i >= #boardMap or j <= 1 or isBoardWithoutBg(i+1, j-1) then -- 左下
					if (i >= #boardMap or isBoardWithoutBg(i+1,j)) and (j <= 1 or isBoardWithoutBg(i, j-1)) then
						boderInfo[i][j].left_down = {"map_tile_corner.png", 0, - sideB, 1, 1, 270}
					end
				end


				if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then -- 右上
					if isBoardWithoutBg(i-1, j) then -- 右上偏上凹角
						boderInfo[i][j].right_top_1 = {"map_tile_in_corner.png", sideH - 2 * sideB, sideH + sideB, 1, 1, 0}
					end
					if isBoardWithoutBg(i, j+1) then -- 右上偏右凹角
						boderInfo[i][j].right_top_2 = {"map_tile_in_corner.png", sideH + 2 * sideB, sideH - sideB, 1, 1, 180}
					end
				else
					if (i <= 1 or isBoardWithoutBg(i-1, j)) and (j >= #boardMap[i] or isBoardWithoutBg(i, j+1)) then
						boderInfo[i][j].right_top_3 = {"map_tile_corner.png", sideH, sideH + sideB, 1, 1, 90}
					end
				end


				if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then -- 右下
					if isBoardWithoutBg(i+1, j) then -- 右下偏下凹角
						boderInfo[i][j].right_down_1 = {"map_tile_in_corner.png", sideH - sideB, - 2 * sideB, 1, 1, 270}
					end
					if isBoardWithoutBg(i, j+1) then -- 右下偏右凹角
						boderInfo[i][j].right_down_2 = {"map_tile_in_corner.png", sideH + sideB, 2 * sideB, 1, 1, 90}
					end
				else
					if (i >= #boardMap or isBoardWithoutBg(i+1, j)) and (j >= #boardMap[i] or isBoardWithoutBg(i, j+1)) then
						boderInfo[i][j].right_down_3 = {"map_tile_corner.png", sideH + sideB, 0, 1, 1, 180}
					end
				end
			end
		end
	end
	return boderInfo
end

function GameBoardView:paintBorder(boardMap)
	-- 豌豆荚收集口
	self.ingrCollects = {}

	local sideH = GamePlayConfig_Tile_Width
	local sideV = GamePlayConfig_Tile_Height
	local sideB = GamePlayConfig_Tile_BorderWidth
	local maxHeight = sideV * (GamePlayConfig_Max_Item_Y - 1)

	local function isBoardWithoutBg(r,c)
		return not boardMap[r][c].isUsed or boardMap[r][c].isMoveTile or boardMap[r][c].isTangChickenBoard
	end

	for i = 1, #boardMap do
		for j = 1, #boardMap[i] do
			local function createSprite(frameName, x, y, scaleX, scaleY, rotation)
				local sprite = Sprite:createWithSpriteFrameName(frameName)
				sprite:setAnchorPoint(ccp(0, 0))
				sprite:setPosition(ccp(x, y))
				sprite:setScaleX(scaleX)
				sprite:setScaleY(scaleY)
				sprite:setRotation(rotation)
				return sprite
			end
			local x, y, w, h
			if not isBoardWithoutBg(i,j) then
				self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("tile_center.png", 
					self.baseMap[i][j].pos_x - sideH / 2, self.baseMap[i][j].pos_y - sideV / 2, 1, 1, 0))

				if j <= 1 or isBoardWithoutBg(i, j - 1) then -- 左
					self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_edge_long.png", self.baseMap[i][j].pos_x -
						sideH / 2, self.baseMap[i][j].pos_y - sideV / 2, 1, 1, 270))
				end
				if i <= 1 or isBoardWithoutBg(i-1, j) then -- 上
					local accWidth = side1
					local widthScale = 1
					if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then
						widthScale = (sideH - sideB) / sideH
					end
					self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_edge_long.png", self.baseMap[i][j].pos_x -
						sideH / 2, self.baseMap[i][j].pos_y + sideV / 2, widthScale, 1, 0))
				end
				if j >= #boardMap[i] or isBoardWithoutBg(i, j+1) then -- 右
					local finY = self.baseMap[i][j].pos_y + sideV / 2
					local finHeight = sideV
					if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then
					 	finY = finY - sideB
					 	finHeight = sideV - sideB
					end
					if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then
						finHeight = finHeight - sideB
					end
					local heightScale = finHeight / sideH
					self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_edge_long.png", self.baseMap[i][j].pos_x +
						sideH / 2, finY, heightScale, 1, 90))
				end
				if i >= #boardMap or isBoardWithoutBg(i+1, j) then -- 下
					local finX = self.baseMap[i][j].pos_x + sideH / 2
					local widthScale = 1
					if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then
						finX = finX - sideB
						widthScale = (sideH - sideB) / sideH
					end
					self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_edge_long.png", finX, self.baseMap[i][j].pos_y -
						sideV / 2,widthScale, 1, 180))
					if boardMap[i][j].isCollector then -- 豆荚收集口标志
						-- local sprite = Sprite:createWithSpriteFrameName("map_tile_ingr_collect.png")
						local sprite
						if boardMap[i][j].showType == IngredientShowType.kAcorn then
							sprite = Sprite:createWithSpriteFrameName("map_tile_acorn_collect.png")
						else
							sprite = Sprite:createWithSpriteFrameName("map_tile_ingr_collect.png")
							table.insert(self.ingrCollects,sprite)
						end
						sprite:setAnchorPoint(ccp(0.5, 0))
						sprite:setPosition(ccp(self.baseMap[i][j].pos_x, self.baseMap[i][j].pos_y - sideV + GamePlayConfig_Tile_Ingr_CollectorY))
						self.showPanel[ItemSpriteType.kBackground]:addChild(sprite)
					end
				end

				if i <= 1 or j <= 1 or isBoardWithoutBg(i-1, j-1) then -- 左上
					if (i<= 1 or isBoardWithoutBg(i-1,j)) and (j <= 1 or isBoardWithoutBg(i,j-1)) then
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_corner.png", self.baseMap[i][j].pos_x -
							sideH / 2 - sideB, self.baseMap[i][j].pos_y + sideV / 2, 1, 1, 0))
					end
				end
				if i >= #boardMap or j <= 1 or isBoardWithoutBg(i+1, j-1) then -- 左下
					if (i >= #boardMap or isBoardWithoutBg(i+1,j)) and (j <= 1 or isBoardWithoutBg(i, j-1)) then
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_corner.png", self.baseMap[i][j].pos_x -
							sideH / 2, self.baseMap[i][j].pos_y - sideH / 2 - sideB, 1, 1, 270))
					end
				end
				if i > 1 and j < #boardMap[i] and not isBoardWithoutBg(i-1, j+1) then -- 右上
					if isBoardWithoutBg(i-1, j) then -- 右上偏上凹角
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_in_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2 - 2 * sideB, self.baseMap[i][j].pos_y + sideH / 2 + sideB, 1, 1, 0))
					end
					if isBoardWithoutBg(i, j+1) then -- 右上偏右凹角
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_in_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2 + 2 * sideB, self.baseMap[i][j].pos_y + sideH / 2 - sideB, 1, 1, 180))
					end
				else
					if (i <= 1 or isBoardWithoutBg(i-1, j)) and (j >= #boardMap[i] or isBoardWithoutBg(i, j+1)) then
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2, self.baseMap[i][j].pos_y + sideH / 2 + sideB, 1, 1, 90))
					end
				end
				if i < #boardMap and j < #boardMap[i] and not isBoardWithoutBg(i+1, j+1) then -- 右下
					if isBoardWithoutBg(i+1, j) then -- 右下偏下凹角
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_in_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2 - sideB, self.baseMap[i][j].pos_y - sideH / 2 - 2 * sideB, 1, 1, 270))
					end
					if isBoardWithoutBg(i, j+1) then -- 右下偏右凹角
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_in_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2 + sideB, self.baseMap[i][j].pos_y - sideH / 2 + 2 * sideB, 1, 1, 90))
					end
				else
					if (i >= #boardMap or isBoardWithoutBg(i+1, j)) and (j >= #boardMap[i] or isBoardWithoutBg(i, j+1)) then
						self.showPanel[ItemSpriteType.kBackground]:addChild(createSprite("map_tile_corner.png", self.baseMap[i][j].pos_x +
							sideH / 2 + sideB, self.baseMap[i][j].pos_y - sideH / 2, 1, 1, 180))
					end
				end
			end
		end
	end
end

function GameBoardView:clacRealUsedMap(boardMap)
	local startRow, startCol = 9, 9
	local endRow, endCol = 1, 1
	for i = 1, #boardMap do
		for j = 1, #boardMap[i] do
			local board = boardMap[i][j]
			if board.isUsed then
				if j > endCol then endCol = j end
				if j < startCol then startCol = j end
				if i > endRow then endRow = i end
				if i < startRow then startRow = i end

				if board.isMoveTile and board.tileMoveMeta then
					for _, meta in pairs(board.tileMoveMeta.routes) do
						local r = meta.endPos.x
						local c = meta.endPos.y
						if c > endCol then endCol = c end
						if c < startCol then startCol = c end
						if r > endRow then endRow = r end
						if r < startRow then startRow = r end
					end
				end
			end
		end
	end
	return startRow, startCol, endRow, endCol
end

function GameBoardView:resizeToFitScreenSnapShot()
	local boardMap = self.gameBoardLogic:getBoardMap()
	local visibleSize = CCSizeMake(720, 1280)
	local visibleOrigin = ccp(0, 0)
	local tWidth, tHeight, bWidth = GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height, GamePlayConfig_Tile_BorderWidth
	local cHeight = GamePlayConfig_Tile_Ingr_Height
	local maxY = GamePlayConfig_Max_Item_Y
	local topHeight = GamePlayConfig_Top_Height * visibleSize.width / GamePlayConfig_Design_Width
	local bottomHeight = GamePlayConfig_Bottom_Height * visibleSize.width / GamePlayConfig_Design_Width
	local scaleX, scaleY = 1, 1
	GamePlayConfig_Tile_ScaleX = scaleX
	GamePlayConfig_Tile_ScaleY = scaleY

	local mapDown, mapLeft, mapHeight, mapWidth = self:clacRealUsedMap(boardMap)
	if self.gameBoardLogic 
			and (self.gameBoardLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID 
			or self.gameBoardLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID) then
		mapLeft = 1
	end
	mapLeft = mapLeft - 1
	mapWidth = mapWidth - mapLeft
	mapDown = mapDown - 1
	mapHeight = mapHeight - mapDown
	local posX = visibleSize.width / 2 - mapWidth * tWidth * scaleX / 2 - mapLeft * tWidth * scaleX + visibleOrigin.x
	local posY = ((visibleSize.height - topHeight - bottomHeight) / 2 - (maxY - mapDown - 1) * tHeight * scaleY / 2) / scaleY + visibleOrigin.y + bottomHeight
	if self.isHalloween then
		posY = ((visibleSize.height - topHeight - bottomHeight) / 2 - (maxY - 1) * tHeight * scaleY / 2) / scaleY + visibleOrigin.y + bottomHeight
	end
	if self.gameBoardLogic 
			and  (self.gameBoardLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID 
			or self.gameBoardLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID) then
		posY = posY - 40
	end
	self.originPos = ccp(posX, posY)
	self:setPosition(self.originPos)
	self:setScaleX(scaleX)
	self:setScaleY(scaleY)
	self.gameBoardLogic.posAdd = self.originPos
	self.moveCountPos.x = visibleOrigin.x + visibleSize.width - self.moveCountPos.x
	self.moveCountPos.y = visibleOrigin.y + visibleSize.height - self.moveCountPos.y

	return ccp(posX + (mapLeft * tWidth - bWidth) * scaleX, posY + ((maxY - mapHeight - mapDown - 1) * tHeight - bWidth - cHeight) * scaleY),
		(mapWidth * tWidth + 2 * bWidth) * scaleX, (mapHeight * tHeight + 2 * bWidth + cHeight) * scaleY
end

function GameBoardView:resizeToFitScreen(boardMap)
	-- 计算比例
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local tWidth, tHeight, bWidth = GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height, GamePlayConfig_Tile_BorderWidth
	local cHeight = GamePlayConfig_Tile_Ingr_Height
	local maxY = GamePlayConfig_Max_Item_Y
	local topHeight = GamePlayConfig_Top_Height * visibleSize.width / GamePlayConfig_Design_Width
	local bottomHeight = GamePlayConfig_Bottom_Height * visibleSize.width / GamePlayConfig_Design_Width
	local scaleX, scaleY = (visibleSize.width - 2 * GamePlayConfig_Tile_PosAddX) / (maxY - 1) / tWidth,
		(visibleSize.height - topHeight - bottomHeight) / (maxY - 1) / tHeight
	if scaleX < scaleY then
		if scaleY > GamePlayConfig_Strengh_Scale * scaleX then scaleY = GamePlayConfig_Strengh_Scale * scaleX end
	else
		if scaleX > GamePlayConfig_Strengh_Scale * scaleY then scaleX = GamePlayConfig_Strengh_Scale * scaleY end
	end
	GamePlayConfig_Tile_ScaleX = scaleX
	GamePlayConfig_Tile_ScaleY = scaleY

	local mapDown, mapLeft, mapHeight, mapWidth = self:clacRealUsedMap(boardMap)
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>> clacRealUsedMap:", mapDown, mapLeft, mapHeight, mapWidth) end
	-- 计算位置
	-- local mapWidth, mapHeight = 0, 0
	-- local mapLeft, mapDown = 9, 9
	-- for i = 1, #boardMap do
	-- 	for j = 1, #boardMap[i] do
	-- 		if boardMap[i][j].isUsed then
	-- 			if j > mapWidth then mapWidth = j end
	-- 			if j < mapLeft then mapLeft = j end
	-- 			if i > mapHeight then mapHeight = i end
	-- 			if i < mapDown then mapDown = i end
	-- 		end
	-- 	end
	-- end
	if self.gameBoardLogic 
			and (self.gameBoardLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID) then
		mapLeft = 1
	end
	mapLeft = mapLeft - 1
	mapWidth = mapWidth - mapLeft
	mapDown = mapDown - 1
	mapHeight = mapHeight - mapDown
	local posX = visibleSize.width / 2 - mapWidth * tWidth * scaleX / 2 - mapLeft * tWidth * scaleX + visibleOrigin.x
	local posY = ((visibleSize.height - topHeight - bottomHeight) / 2 - (maxY - mapDown - 1) * tHeight * scaleY / 2) / scaleY + visibleOrigin.y + bottomHeight
	if self.isHalloween then
		posY = ((visibleSize.height - topHeight - bottomHeight) / 2 - (maxY - 1) * tHeight * scaleY / 2) / scaleY + visibleOrigin.y + bottomHeight
	end
	if self.gameBoardLogic 
			and  (self.gameBoardLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID 
			or self.gameBoardLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID) then
		if __isWildScreen then
			posY = posY - 20
		else
			posY = posY - 40
		end
	end
	self.originPos = ccp(posX, posY)
	self:setPosition(self.originPos)
	self:setScaleX(scaleX)
	self:setScaleY(scaleY)
	self.gameBoardLogic.posAdd = self.originPos
	self.moveCountPos.x = visibleOrigin.x + visibleSize.width - self.moveCountPos.x
	self.moveCountPos.y = visibleOrigin.y + visibleSize.height - self.moveCountPos.y

	return ccp(posX + (mapLeft * tWidth - bWidth) * scaleX, posY + ((maxY - mapHeight - mapDown - 1) * tHeight - bWidth - cHeight) * scaleY),
		(mapWidth * tWidth + 2 * bWidth) * scaleX, (mapHeight * tHeight + 2 * bWidth + cHeight) * scaleY
end

function GameBoardView:viberate()
	self.viberateDelay = GamePlayConfig_Viberate_Delay
	self.viberateCounter = GamePlayConfig_Viberate_Count
end

function GameBoardView:viberateUpdate()
	if self.viberateDelay == 0 and self.viberateCounter == -1 then return end
	
	if self.viberateDelay == 0 then
		if self.viberateCounter == 0 then
			self:setPosition(self.originPos)
			self.viberateCounter = -1
			return
		else
			self.viberateCounter = self.viberateCounter - 1
			local posY = GamePlayConfig_Viberate_InitY * CCDirector:sharedDirector():getWinSize().height / (GamePlayConfig_Viberate_Count - self.viberateCounter)
			local bit = require("bit")
			if bit.band(self.viberateCounter, 0x1) == 0 then posY = -posY end
			self:setPosition(ccp(self.originPos.x, posY + self.originPos.y))
			self.viberateDelay = GamePlayConfig_Viberate_Delay
		end
	else
		self.viberateDelay = self.viberateDelay - 1
	end
end

function GameBoardView:setBrushType(animalType)
	if animalType ~= nil then
		self.forceBrushAnimalType = animalType
	end
end

function GameBoardView:dcUseProp(isCancel, propsType)
	local dcData = {}
	dcData.click = isCancel and 0 or 1

	if propsType == GamePropsType.kRefresh 
		or propsType == GamePropsType.kRefresh_b 
		or propsType == GamePropsType.kRefresh_l
		then
		dcData.category = "goods_fresh"
	elseif propsType == GamePropsType.kSwap 
		or propsType == GamePropsType.kSwap_l 
		or propsType == GamePropsType.kSwap_b
		then
		dcData.category = "goods_exchange"
	elseif propsType == GamePropsType.kLineBrush 
		or propsType == GamePropsType.kLineBrush_l 
		or propsType == GamePropsType.kLineBrush_b
		then
		if not isCancel then
			local t = self.forceBrushAnimalType
			if not t then
				dcData.click = 1
			elseif t == AnimalTypeConfig.kColumn then
				dcData.click = 2
			elseif t == AnimalTypeConfig.kLine then
				dcData.click = 3
			end
			self.forceBrushAnimalType = nil
		end
		dcData.category = "goods_magic"
	elseif propsType == GamePropsType.kHammer 
		or propsType == GamePropsType.kHammer_l 
		or propsType == GamePropsType.kHammer_b
		then
		dcData.category = "goods_hammer"
	elseif propsType == GamePropsType.kBack 
		or propsType == GamePropsType.kBack_b 
		or propsType == GamePropsType.kBack_l
		then
		dcData.category = "goods_back"
    elseif propsType == GamePropsType.kJamSpeardHummer then
        dcData.category = "goods_JamSpeard_hammer"
    elseif propsType == GamePropsType.kRowEffect 
		or propsType == GamePropsType.kRowEffect_l 
		then
		dcData.category = "goods_line_effect_rocket_row"
	elseif propsType == GamePropsType.kColumnEffect 
		or propsType == GamePropsType.kColumnEffect_l
		then
		dcData.category = "goods_line_effect_rocket_column"
	end

	if dcData.category then
		DcUtil:log(AcType.kUserTrack, dcData)
	end
end

function GameBoardView:useProp(propID, needConfirm , usePropType, isGuideRefresh)
	if needConfirm then
		self.gamePropsType = propID
		self.gamePropsUseType = usePropType
	    self.interactionController:onUseProp(propID)
		self:focusOnItem(nil)
	else
		self.gameBoardLogic:useProps(propID , nil,nil,nil,nil, usePropType, isGuideRefresh)
	end
end

function GameBoardView:usePropCancelled(propId, confirm)
	if not confirm then
		self:dcUseProp(true, propId)
	end
	self.gamePropsType = GamePropsType.kNone
	self.interactionController:onCancelUsingProp()
end

function GameBoardView:animalStartTimeScale()
	for r = 1, #self.gameBoardLogic.gameItemMap do
		for c = 1, #self.gameBoardLogic.gameItemMap[r] do
			local gameItem = self.gameBoardLogic.gameItemMap[r][c]
			if gameItem and gameItem.isUsed and 
				gameItem.ItemType == GameItemType.kAnimal 
				or gameItem.ItemType == GameItemType.kGift 
				or gameItem.ItemType == GameItemType.kNewGift
				or gameItem.ItemType == GameItemType.kCrystal 
				or gameItem.ItemType == GameItemType.kAddMove
				or gameItem.ItemType == GameItemType.kAddTime
				then
				self.baseMap[r][c]:animalStartTimeScale()
			end
		end
	end
end

function GameBoardView:maskWithFewTouch(opacity, holeArray, allow, tileScale, violationCallback,useBrushProp)
	tileScale = tileScale or 1
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	local ccpos = self:getPosition()
	local selfPos = {x=ccpos.x, y=ccpos.y}
	local tWidth, tHeight = GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height
	local scaleX, scaleY = GamePlayConfig_Tile_ScaleX, GamePlayConfig_Tile_ScaleY
	local maxY = GamePlayConfig_Max_Item_Y
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))

	local playFocusEffect = true
	if #holeArray == 1 and (holeArray[1].countR == 0 or holeArray[1].countC == 0) then
		playFocusEffect = false
	end

	local x_sum = 0
	local y_sum = 0
	local count = #holeArray
	for __, v in ipairs(holeArray) do
		local hole = LayerColor:create()
		hole:changeWidthAndHeight(v.countC * tWidth * scaleX * tileScale, v.countR * tHeight * scaleY * tileScale)
		local pos = self.gameBoardLogic:getGameItemPosInView(v.r, v.c)
		hole:setPosition(ccp(pos.x - tWidth * scaleX* tileScale / 2, pos.y - tHeight * scaleY * tileScale / 2))
		local midPoint = {r = (v.r + v.r+v.countC)/2, c = (v.c + v.c - v.countR)/2}
		local midPos = self.gameBoardLogic:getGameItemPosInView(midPoint.r, midPoint.c)
		x_sum = x_sum + midPos.x
		y_sum = y_sum + midPos.y
		local blend = ccBlendFunc()
		blend.src = GL_ZERO
		blend.dst = GL_ZERO
		hole:setBlendFunc(blend)
		mask:addChild(hole)
	end



	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	if __WP8 then layer:saveToCache() end

	mask:dispose()
  
  	local touchStopped = true
  	local preValidPos = nil
	local obj = CocosObject.new(layer)
	local function onTouchBegin(evt)
		touchStopped = false
		preValidPos = nil
		local position = evt.globalPosition
		position.x = position.x - selfPos.x
		position.y = position.y - selfPos.y
				
		local offsetY = _G.clickOffsetY or 0
		position.y = position.y + offsetY

		if _G.isLocalDevelopMode then printx(0, "onTouchBegin ", position.x, position.y) end
		if position.x > (allow.c - 1) * tWidth * scaleX and position.y > (maxY - allow.r - 1) * tHeight * scaleY and
			position.x < ((allow.c - 1) + allow.countC) * tWidth * scaleX and position.y < ((maxY - allow.r - 1) + allow.countR) * tHeight * scaleY then
			preValidPos = {x = position.x + selfPos.x, y = position.y + selfPos.y}
			return self:onTouchBegan(position.x + selfPos.x, position.y + selfPos.y)
		else
			touchStopped = true
			if violationCallback then
				violationCallback()
			end
		end
	end
	local function onTouchMove(evt)
		if touchStopped then return end
		local position = evt.globalPosition
		position.x = position.x - selfPos.x
		position.y = position.y - selfPos.y
		
		local offsetY = _G.clickOffsetY or 0
		position.y = position.y + offsetY

		if _G.isLocalDevelopMode then printx(0, "onTouchMove ", position.x, position.y) end
		if useBrushProp and self.PlayUIDelegate.propList and self.PlayUIDelegate.propList.focusItem then
			preValidPos = {x = position.x + selfPos.x, y = position.y + selfPos.y}
			return self:onTouchMoved(position.x + selfPos.x, position.y + selfPos.y)
		elseif position.x > (allow.c - 1) * tWidth * scaleX and position.y > (maxY - allow.r - 1) * tHeight * scaleY and
			position.x < ((allow.c - 1) + allow.countC) * tWidth * scaleX and position.y < ((maxY - allow.r - 1) + allow.countR) * tHeight * scaleY then
			preValidPos = {x = position.x + selfPos.x, y = position.y + selfPos.y}
			return self:onTouchMoved(position.x + selfPos.x, position.y + selfPos.y)
		else
			touchStopped = true
			if preValidPos then
				self:onTouchEnded(preValidPos.x, preValidPos.y)
				preValidPos = nil
			end
			if violationCallback then
				violationCallback()
			end
		end
	end
	local function onTouchEnd(evt)
		if touchStopped then return end
		local position = evt.globalPosition
		position.x = position.x - selfPos.x
		position.y = position.y - selfPos.y

		local offsetY = _G.clickOffsetY or 0
		position.y = position.y + offsetY
		
		if _G.isLocalDevelopMode then printx(0, "onTouchEnd ", position.x, position.y) end
		-- 魔法棒只有格，滑出去也算
		if useBrushProp and self.PlayUIDelegate.propList and self.PlayUIDelegate.propList.focusItem then
			return self:onTouchEnded(position.x + selfPos.x, position.y + selfPos.y)
		elseif position.x > (allow.c - 1) * tWidth * scaleX and position.y > (maxY - allow.r - 1) * tHeight * scaleY and
			position.x < ((allow.c - 1) + allow.countC) * tWidth * scaleX and position.y < ((maxY - allow.r - 1) + allow.countR) * tHeight * scaleY then
			return self:onTouchEnded(position.x + selfPos.x, position.y + selfPos.y)
		else
			if preValidPos then
				self:onTouchEnded(preValidPos.x, preValidPos.y)
				preValidPos = nil
			end
			if violationCallback then
				violationCallback()
			end
		end
	end

	local layerSprite = layer:getSprite()
	local anchor = layerSprite:getAnchorPoint()
	local anchorPos = ccp(anchor.x*layerSprite:getContentSize().width, anchor.y*layerSprite:getContentSize().height)

	-----------------------------------------------------------
	---- 计算缩放中心坐标
	----
	local x_sum = 0
	local y_sum = 0
	local count = #holeArray
	for __, v in ipairs(holeArray) do
		local midPoint = {r = (v.r + v.r-v.countR + 1)/2, c = (v.c + v.c + v.countC - 1)/2}
		local midPos = self.gameBoardLogic:getGameItemPosInView(midPoint.r, midPoint.c)
		local midNodePos = layerSprite:convertToNodeSpace(midPos)

		x_sum = x_sum + midNodePos.x
		y_sum = y_sum + midNodePos.y
	end
	local destPos = {x = x_sum / count, y = y_sum / count}
	----
	------------------------------------------------------------

	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	trueMaskLayer:ad(DisplayEvents.kTouchMove, onTouchMove)
	trueMaskLayer:ad(DisplayEvents.kTouchEnd, onTouchEnd)
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)

		if playFocusEffect then
			local scaleTime = 0.3
			local oScaleX, oScaleY = layerSprite:getScaleX(), layerSprite:getScaleY()
			layerSprite:setScaleX(oScaleX*10)
			layerSprite:setScaleY(oScaleY*10)

			-- 保持在当前anchor下缩放，目标坐标保持静止的补偿向量
			local function getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return ccp(d_to_a.x*(oScaleX-dScaleX), d_to_a.y*(oScaleY-dScaleY))
			end

			local function getCompensateMove(time, oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				local dir = getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return CCMoveBy:create(time, dir)
			end

			-------------------------------------------------------
			---- 计算补偿位移需要的向量
			local d_to_o = destPos
			local a_to_o = anchorPos
			local d_to_a = ccp(d_to_o.x - a_to_o.x, d_to_o.y - a_to_o.y)
			local action = getCompensateMove(scaleTime, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-- if _G.isLocalDevelopMode then printx(0, d_to_o.x, d_to_o.y, d_to_a.x, d_to_a.y, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY) debug.debug() end
			local compensateDir = getCompensateDir(layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-------------------------------------------------------

			-- anchor不变的情况下，将缩放中心放到目标位置
			layerSprite:setPositionX(layerSprite:getPositionX()-compensateDir.x)
			layerSprite:setPositionY(layerSprite:getPositionY()-compensateDir.y)

			local focusAction = CCSpawn:createWithTwoActions(CCScaleTo:create(scaleTime, oScaleX, oScaleY), action)
			local focusFadeIn = CCSpawn:createWithTwoActions(CCFadeIn:create(maskFade), focusAction)

			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), focusFadeIn))
		else
			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
		end
	end	

	return trueMaskLayer
end

function GameBoardView:getPositionFromTo(from, to)
	return self.gameBoardLogic:getGameItemPosInView(from.x, from.y), self.gameBoardLogic:getGameItemPosInView(to.x, to.y)
end

function GameBoardView:swapItemView( item1, item2 )
	-- body
	local tempSprite = nil
	local tempType = 0

	local item2Checked = false
	local item1Checked = false
	for i = 1, #ItemSpriteCanSwapLayers do
		local layerType = ItemSpriteCanSwapLayers[i]

		if not item2Checked and item2.itemSprite[layerType] then
			tempType = layerType
			tempSprite = item2.itemSprite[layerType]
			item2.itemSprite[layerType] = nil
			item2Checked = true
		end

		if not item1Checked and item1.itemSprite[layerType] then
			item2.itemSprite[layerType] = item1.itemSprite[layerType]
			item1.itemSprite[layerType] = nil
			item1Checked = true
		end

		if item1Checked and item2Checked then break end
	end
	item1.itemSprite[tempType] = tempSprite

	local coverType = ItemSpriteType.kGhost
	local tempCoverSprite = item2.itemSprite[coverType]
	item2.itemSprite[coverType] = item1.itemSprite[coverType]
	item1.itemSprite[coverType] = tempCoverSprite

	local tempItemType = item1.oldData.ItemType
	local tempItemColorType = item1.oldData._encrypt.ItemColorType
	local tempSpecialType = item1.oldData.ItemSpecialType
	local tempShowType = item1.itemShowType

	item1.oldData.ItemType = item2.oldData.ItemType
	item1.oldData._encrypt.ItemColorType = item2.oldData._encrypt.ItemColorType
	item1.oldData.ItemSpecialType = item2.oldData.ItemSpecialType
	item1.itemShowType = item2.itemShowType

	item2.oldData.ItemType = tempItemType
	item2.oldData._encrypt.ItemColorType = tempItemColorType
	item2.oldData.ItemSpecialType = tempSpecialType
	item2.itemShowType = tempShowType
end

function GameBoardView:showBombGuideEffect(posArray, duration)
	for k, v in pairs(posArray) do
		local sprite = Sprite:createWithSpriteFrameName('bomb_guide_effect.png')
		local showLayer = self.showPanel[ItemSpriteType.kGameGuideEffect]
		showLayer:addChild(sprite)
		local pos = showLayer:convertToNodeSpace(self.gameBoardLogic:getGameItemPosInView(v.r, v.c))
		sprite:setPosition(ccp(pos.x + 0, pos.y - 0))
		local function remove()
			if sprite then 
				sprite:removeFromParentAndCleanup(true)
				sprite = nil
			end
		end
		local arr = CCArray:create()
		local time = duration / 6
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCCallFunc:create(remove))
		sprite:runAction(CCSequence:create(arr))
	end
end 

function GameBoardView:showIceGuideEffect(posArray, duration)
	for k, v in pairs(posArray) do
		local sprite = Sprite:createWithSpriteFrameName('bomb_guide_effect.png')
		local showLayer = self.showPanel[ItemSpriteType.kGameGuideEffect]
		showLayer:addChild(sprite)
		local pos = showLayer:convertToNodeSpace(self.gameBoardLogic:getGameItemPosInView(v.r, v.c))
		sprite:setPosition(ccp(pos.x + 0, pos.y - 0))
		local function remove()
			if sprite then 
				sprite:removeFromParentAndCleanup(true)
				sprite = nil
			end
		end
		local time = duration / 6
		local arr = CCArray:create()
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCFadeIn:create(time))
		arr:addObject(CCFadeOut:create(time))
		arr:addObject(CCCallFunc:create(remove))
		sprite:runAction(CCSequence:create(arr))
	end
end


function GameBoardView:showUsePropTipGuide( ... )
	for k,v in pairs(self.ingrCollects or {}) do
		if not v.isDisposed then
			v:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("map_tile_ingr_collect2.png"))
		end
	end
end

function GameBoardView:removeUsePropTipGuide( ... )
	for k,v in pairs(self.ingrCollects or {}) do
		if not v.isDisposed then
			v:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("map_tile_ingr_collect.png"))
		end
	end
end