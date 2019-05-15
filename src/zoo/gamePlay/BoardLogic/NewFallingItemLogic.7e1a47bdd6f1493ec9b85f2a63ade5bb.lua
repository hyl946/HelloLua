NewFallingItemLogic = class{}

--判断上下相邻的两个格子之间，是否有阻挡   r1，c1为上方，r2，c2为下方
--为什么不自动判断？因为调用的地方知道上下，性能能省点就省点
function NewFallingItemLogic:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r1, c1 , r2 , c2 )

	if not mainLogic:isPosValid(r1, c1) then return false end
	if not mainLogic:isPosValid(r2, c2) then return false end

	local boardUp = mainLogic.boardmap[r1][c1]
	local boardBottom = mainLogic.boardmap[r2][c2]
	if boardUp:hasBottomRope() or boardBottom:hasTopRope() then
		return true
	end

	local function __doCheck()
		if UseNewFallingLogic == 1 then
			if self:isGridCanBeFallingIn( mainLogic , boardUp.passExitPoint_x , boardUp.passExitPoint_y )  then
				return true
			end
		else
			return true
		end
		return false
	end

	if boardUp:isGravityDown() then
		if boardBottom:isGravityUp() and boardUp.isUsed then
			return true
		end
		if boardUp:hasEnterPortal() then
			if __doCheck() then
				return true
			end
		end
	elseif boardUp:isGravityUp() then
		if boardUp:hasExitPortal() then
			if __doCheck() then
				return true
			end
		end
	end

	if boardBottom:isGravityDown() then
		if boardBottom:hasExitPortal() then
			if __doCheck() then
				return true
			end
		end
	elseif boardBottom:isGravityUp() then
		if boardBottom:hasEnterPortal() then
			if __doCheck() then
				return true
			end
		end
	end
	return false
end

--判断左右相邻的两个格子之间，是否有阻挡   r1，c1为左侧，r2，c2为右侧
--为什么不自动判断？因为调用的地方知道左右，性能能省点就省点
function NewFallingItemLogic:hasRopeLikeBetweenTwoHorizontalGrids( mainLogic, r1, c1 , r2 , c2 )
	if not mainLogic:isPosValid(r1, c1) then return false end
	if not mainLogic:isPosValid(r2, c2) then return false end

	local boardLeft = mainLogic.boardmap[r1][c1]
	local boardRight = mainLogic.boardmap[r2][c2]
	if boardLeft:hasRightRope() or boardRight:hasLeftRope() then
		return true
	end

	local function __doCheck()
		if UseNewFallingLogic == 1 then
			if self:isGridCanBeFallingIn( mainLogic , boardUp.passExitPoint_x , boardUp.passExitPoint_y )  then
				return true
			end
		else
			return true
		end
		return false
	end

	if boardLeft:isGravityLeft() then
		if boardLeft:hasExitPortal() then
			if __doCheck() then
				return true
			end
		end
	elseif boardLeft:isGravityRight() then
		if boardRight:isGravityLeft() then
			return true
		end
		if boardLeft:hasEnterPortal() then
			if __doCheck() then
				return true
			end
		end
	end


	if boardRight:isGravityLeft() then
		if boardRight:hasEnterPortal() then
			if __doCheck() then
				return true
			end
		end
	elseif boardRight:isGravityRight() then
		if boardRight:hasExitPortal() then
			if __doCheck() then
				return true
			end
		end
	end

	return false
end

function NewFallingItemLogic:hasRopeLikeBetweenTwoObliqueVerticalGrids( mainLogic, r1, c1 , r2 , c2 , fx)
	if not mainLogic:isPosValid(r1, c1) then return false end
	if not mainLogic:isPosValid(r2, c2) then return false end

	local board1 = mainLogic.boardmap[r1][c1] --顶点位置
	local board2 = mainLogic.boardmap[r2][c2] --底部位置

	if board1:isGravityDown() then
		local board3 = nil
		if mainLogic:isPosValid(r1 + 1, c1) then 
			board3 = mainLogic.boardmap[r1 + 1][c1]
		end
		if fx == 1 then
			--右上至左下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityUp() or board2:isGravityRight() then
				return true
			end
			if board2:hasRightRope() or board3:hasLeftRope() then
				return true
			end
		else
			--左上至右下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityUp() or board2:isGravityLeft() then
				return true
			end
			if board2:hasLeftRope() or board3:hasRightRope() then
				return true
			end
		end
	elseif board1:isGravityUp() then
		local board3 = nil
		if mainLogic:isPosValid(r1 - 1, c1) then 
			board3 = mainLogic.boardmap[r1 - 1][c1]
		end
		if fx == 1 then
			--右上至左下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityDown() or board2:isGravityLeft() then
				return true
			end
			if board2:hasLeftRope() or board3:hasRightRope() then
				return true
			end
		else
			--左上至右下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityDown() or board2:isGravityRight() then
				return true
			end
			if board2:hasRightRope() or board3:hasLeftRope() then
				return true
			end
		end
	elseif board1:isGravityLeft() then
		local board3 = nil
		if mainLogic:isPosValid(r1, c1 - 1) then 
			board3 = mainLogic.boardmap[r1][c1 - 1]
		end
		if fx == 1 then
			--右上至左下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityDown() or board2:isGravityRight() then
				return true
			end
			if board2:hasBottomRope() or board3:hasTopRope() then
				return true
			end
		else
			--左上至右下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityUp() or board2:isGravityRight() then
				return true
			end
			if board2:hasTopRope() or board3:hasBottomRope() then
				return true
			end
		end
	else
		local board3 = nil
		if mainLogic:isPosValid(r1, c1 + 1) then 
			board3 = mainLogic.boardmap[r1][c1 + 1]
		end
		if fx == 1 then
			--右上至左下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityUp() or board2:isGravityLeft() then
				return true
			end
			if board2:hasTopRope() or board3:hasBottomRope() then
				return true
			end
		else
			--左上至右下(注意，这里的方向指的是相对方向，即重力为下时的方向)
			if board2:isGravityDown() or board2:isGravityLeft() then
				return true
			end
			if board2:hasBottomRope() or board3:hasTopRope() then
				return true
			end
		end
	end

	return false
end

function NewFallingItemLogic:isGridCanBeFallingOut( mainLogic, r, c )
	if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c]
	local board= mainLogic.boardmap[r][c]

	if item and item.isUsed and not item.isEmpty and not item.isBlock then
		return true
	end

	return false
end

function NewFallingItemLogic:isGridCanBeFallingIn( mainLogic, r, c )

	if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c]

	if item and item.isUsed and not item.comePos and not item.isBlock then

		if item.isEmpty then
			return true
		elseif item.ItemStatus == GameItemStatusType.kIsFalling then
			return true
		end
	end
	return false
end

function NewFallingItemLogic:hasBottomRopeOrChain( board )
	return board:hasBottomRope() --同时判断绳子和冰柱
end

function NewFallingItemLogic:hasTopRopeOrChain( board )
	return board:hasTopRope() --同时判断绳子和冰柱
end

function NewFallingItemLogic:hasLeftRopeOrChain( board )
	return board:hasLeftRope() --同时判断绳子和冰柱
end

function NewFallingItemLogic:hasRightRopeOrChain( board )
	return board:hasRightRope() --同时判断绳子和冰柱
end

function NewFallingItemLogic:hasTopChain( board )
	return board:hasChainInDirection(ChainDirConfig.kUp) --只判断冰柱
end

function NewFallingItemLogic:hasBottomChain( board )
	return board:hasChainInDirection(ChainDirConfig.kDown) --只判断冰柱
end

function NewFallingItemLogic:hasLeftChain( board )
	return board:hasChainInDirection(ChainDirConfig.kLeft) --只判断冰柱
end

function NewFallingItemLogic:hasRightChain( board )
	return board:hasChainInDirection(ChainDirConfig.kRight) --只判断冰柱
end


function NewFallingItemLogic:hasTopRope( board )
	return board:hasTopRopeProperty() --只判断绳子
end

function NewFallingItemLogic:hasBottomRope( board )
	return board:hasBottomRopeProperty() --只判断绳子
end

function NewFallingItemLogic:hasLeftRope( board )
	return board:hasLeftRopeProperty() --只判断绳子
end

function NewFallingItemLogic:hasRightRope( board )
	return board:hasRightRopeProperty() --只判断绳子
end

function NewFallingItemLogic:checkFallingByPortal(mainLogic , r , c)

	local item1 = mainLogic.gameItemMap[r][c]
	local board1 = mainLogic.boardmap[r][c] --入口格子
	-- printx( 1 , "checkFallingByPortal " , r , c , "board1.passExitPoint_x" , board1.passExitPoint_x , "board1.passExitPoint_y" , board1.passExitPoint_y ,board1:hasBottomRope())

	if board1.passExitPoint_x > 0 and board1.passExitPoint_y > 0 then

		local enterHasChain = false
		if board1:isGravityDown() then
			enterHasChain = self:hasBottomChain(board1)
		elseif board1:isGravityUp() then
			enterHasChain = self:hasTopChain(board1)
		elseif board1:isGravityLeft() then
			enterHasChain = self:hasLeftChain(board1)
		else
			enterHasChain = self:hasRightChain(board1)
		end

		if not enterHasChain then
			local tr = board1.passExitPoint_x
			local tc = board1.passExitPoint_y

			local board2 = mainLogic.boardmap[tr][tc]		----出口格子
			local item2 = mainLogic.gameItemMap[tr][tc]

			local exitHasChain = false
			if board2:isGravityDown() then
				exitHasChain = self:hasTopChain(board2)
			elseif board2:isGravityUp() then
				exitHasChain = self:hasBottomChain(board2)
			elseif board2:isGravityLeft() then
				exitHasChain = self:hasRightChain(board2)
			else
				exitHasChain = self:hasLeftChain(board2)
			end
			-- printx( 1 , "checkFallingByPortal -------------- 1  " ,board2:hasTopRope(),self:isGridCanBeFallingOut( mainLogic, r, c ),self:isGridCanBeFallingIn(mainLogic, tr , tc) )
			if not exitHasChain
				and self:isGridCanBeFallingOut( mainLogic, r, c ) 
				and self:isGridCanBeFallingIn(mainLogic, tr , tc) then

				return true
			end
		end
	end

	return false
end

function NewFallingItemLogic:doFallingByPortal(mainLogic , r , c)
	local item1 = mainLogic.gameItemMap[r][c]
	local board1 = mainLogic.boardmap[r][c]

	local tr = board1.passExitPoint_x
	local tc = board1.passExitPoint_y

	local board2 = mainLogic.boardmap[tr][tc]		----出口格子
	local item2 = mainLogic.gameItemMap[tr][tc]

	item2.gotoPos = IntCoord:create(tr, tc)
	item2.comePos = IntCoord:create(r, c)

	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 								----数据未到
	item2:AddItemStatus( GameItemStatusType.kIsFalling )		----正在下落
	item2.itemSpeed = GamePlayConfig_FallingSpeed_Pass_Start

	if board2:isGravityDown() then
		item2.itemPosAdd.x = 0
		item2.itemPosAdd.y = GamePlayConfig_Tile_Height			----从上方而来
		item2.ClippingPosAdd.x = 0
		item2.ClippingPosAdd.y = GamePlayConfig_Tile_Height		----从上方而来
	elseif board2:isGravityUp() then
		item2.itemPosAdd.x = 0
		item2.itemPosAdd.y = GamePlayConfig_Tile_Height	* -1		
		item2.ClippingPosAdd.x = 0
		item2.ClippingPosAdd.y = GamePlayConfig_Tile_Height	* -1	
	elseif board2:isGravityLeft() then
		item2.itemPosAdd.x = GamePlayConfig_Tile_Width
		item2.itemPosAdd.y = 0			
		item2.ClippingPosAdd.x = GamePlayConfig_Tile_Width
		item2.ClippingPosAdd.y = 0		
	else
		item2.itemPosAdd.x = GamePlayConfig_Tile_Width * -1
		item2.itemPosAdd.y = 0			
		item2.ClippingPosAdd.x = GamePlayConfig_Tile_Width * -1
		item2.ClippingPosAdd.y = 0
	end

	item2.isEmpty = false

	item1:cleanAnimalLikeData()
	item1.EnterClippingPosAdd.x = 0
	item1.EnterClippingPosAdd.y = 0
	--[[
	if board1:isGravityDown() then
		item1.EnterClippingPosAdd.y = 0
	elseif board1:isGravityUp() then
		item1.EnterClippingPosAdd.y = 0
	elseif board1:isGravityLeft() then
		item1.EnterClippingPosAdd.y = 0
	else
		item1.EnterClippingPosAdd.y = 0
	end
	]]

	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_Pass,
		IntCoord:create(r,c),	 		----上面那个
		IntCoord:create(tr,tc),			----
		GamePlayConfig_Falling_MaxTime)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

	self:updateVerticalFallingPlan( mainLogic , tr , tc , true )
end

function NewFallingItemLogic:checkFallingByBottomEmpty(mainLogic , r , c)
	-- printx( 1 , "NewFallingItemLogic:checkFallingByBottomEmpty  r" , r , "c" , c ) 

	local board1 = mainLogic.boardmap[r][c]

	local function targetGridCanCross()
		-- printx( 1 , "NewFallingItemLogic:targetGridCanCross  r" , r , "c" , c , "board1.gravity =" , board1.gravity ) 

		if board1:isGravityDown() then 
			--下
			return self:isGridCanBeFallingIn(mainLogic, r+1, c) and not self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r, c , r+1 , c )
		elseif board1:isGravityUp() then
			--上
			
			-- printx( 1 , "self:isGridCanBeFallingIn(mainLogic, r-1, c)" ,self:isGridCanBeFallingIn(mainLogic, r-1, c) ) 
			-- printx( 1 , "self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r-1, c , r , c )" , self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r-1, c , r , c ) ) 
			return self:isGridCanBeFallingIn(mainLogic, r-1, c) and not self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r-1, c , r , c )
		elseif board1:isGravityLeft() then
			--左
			return self:isGridCanBeFallingIn(mainLogic, r, c-1) and not self:hasRopeLikeBetweenTwoHorizontalGrids( mainLogic, r, c-1 , r , c )
		else
			--右
			return self:isGridCanBeFallingIn(mainLogic, r, c+1) and not self:hasRopeLikeBetweenTwoHorizontalGrids( mainLogic, r, c , r , c+1 )
		end
	end

	if targetGridCanCross() then 	----正下方的格子可以被掉落进去
		return true
	else
		local item1 = mainLogic.gameItemMap[r][c] 	----上面那个

		if item1.ItemStatus == GameItemStatusType.kJustArrived then
			item1:AddItemStatus( GameItemStatusType.kItemHalfStable )		----结束掉落，检测三消

			-- printx( 1 , "NewFallingItemLogic:checkFallingByBottomEmpty  kItemHalfStable !!!!!!!!!!!!" , r,c ) 
			item1.itemPosAdd.x = 0;
			item1.itemPosAdd.y = 0;
			item1.itemSpeed = 0;
			item1.isNeedUpdate = true;
			--self:updateVerticalFallingPlan( mainLogic , r + 1 , c )
		end
	end

	return false
end

function NewFallingItemLogic:doFallingByBottomEmpty(mainLogic , r , c)
	local item1 = mainLogic.gameItemMap[r][c] 	----上面那个
	local board1 = mainLogic.boardmap[r][c] 	----上面那个
	local item2 = nil
	
	if board1:isGravityDown() then
		item2 = mainLogic.gameItemMap[r+1][c]		----下面空位
		item2.gotoPos = IntCoord:create( r+1 ,  c )
	elseif board1:isGravityUp() then
		item2 = mainLogic.gameItemMap[r-1][c]		----上面空位
		item2.gotoPos = IntCoord:create( r-1 ,  c )
	elseif board1:isGravityLeft() then
		item2 = mainLogic.gameItemMap[r][c-1]		----左边空位
		item2.gotoPos = IntCoord:create( r ,  c-1 )
	else
		item2 = mainLogic.gameItemMap[r][c+1]		----右边空位
		item2.gotoPos = IntCoord:create( r ,  c+1 )
	end

	
	item2.comePos = IntCoord:create( r , c )

	----直接放入----
	item2:getAnimalLikeDataFrom(item1)	----获取物品信息
	item2.dataReach = false 								----数据未到
	item2:AddItemStatus( GameItemStatusType.kIsFalling )		----正在下落

	if board1:isGravityDown() then
		item2.itemPosAdd.x = 0
		item2.itemPosAdd.y = item2.itemPosAdd.y + GamePlayConfig_Tile_Height		----从上方而来
	elseif board1:isGravityUp() then
		item2.itemPosAdd.x = 0
		item2.itemPosAdd.y = item2.itemPosAdd.y - GamePlayConfig_Tile_Height		----从下方而来
	elseif board1:isGravityLeft() then
		item2.itemPosAdd.x = item2.itemPosAdd.x + GamePlayConfig_Tile_Width        ----从右方而来
		item2.itemPosAdd.y = 0		
	else
		item2.itemPosAdd.x = item2.itemPosAdd.x - GamePlayConfig_Tile_Width        ----从左方而来
		item2.itemPosAdd.y = 0
	end

	item2.isEmpty = false;

	item1:cleanAnimalLikeData()

	----开始动作----

	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_UpDown,
		IntCoord:create(r,c),
		IntCoord:create( item2.gotoPos.x , item2.gotoPos.y ),
		GamePlayConfig_Falling_MaxTime)
	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

end

function NewFallingItemLogic:checkFallingByCannon(mainLogic , r , c)

	-- local textPrint = false
	-- if r == 9 and c == 1 then
	-- 	textPrint = true
	-- end

	if self:isGridCanBeFallingIn( mainLogic , r , c ) then --这个格子首先要支持能有东西掉进来
		
		-- local textPrint = false
		-- if r == 4 and c == 3 then
		-- 	textPrint = true
		-- end
		-- if textPrint then printx( 1 , "checkFallingByCannon ---------- "  , r , c , "UseNewFallingLogic =" , UseNewFallingLogic , type(UseNewFallingLogic) ) end

		local firstBoard = nil
		local temBoard = nil

		local function checkHasOtherCannon( _r , _c , isFirstGrid , isPortalEnterMode )

			local function checkByPortal( enterR , enterC )

				-- if textPrint then printx( 1 , "checkByPortal enterR:"  , enterR , "enterC:" , enterC   ) end

				local itemPassEnter = mainLogic.gameItemMap[enterR][enterC]
				local boardPassEnter = mainLogic.boardmap[enterR][enterC]

				if boardPassEnter:isGravityDown() then
					if self:hasBottomChain( boardPassEnter ) then
						return true
					end
				elseif boardPassEnter:isGravityUp() then
					if self:hasTopChain( boardPassEnter ) then
						return true
					end
				elseif boardPassEnter:isGravityLeft() then
					if self:hasLeftChain( boardPassEnter ) then
						return true
					end
				else
					if self:hasRightChain( boardPassEnter ) then
						return true
					end
				end
				

				if not boardPassEnter.isUsed or itemPassEnter.isBlock or boardPassEnter.isBlock then
					-- if textPrint then printx( 1 , "checkByPortal ~~~~~  return B true"  ) end
					return true
				end

				if boardPassEnter.isProducer then
					-- if textPrint then printx( 1 , "checkByPortal ~~~~~  return C false"  ) end
					return false
				end

				-- if textPrint then printx( 1 , "checkByPortal --> checkHasOtherCannon enterR:"  , enterR , "enterC:" , enterC   ) end
				temBoard = nil
				return checkHasOtherCannon( enterR , enterC , false , true )
			end

			-- if textPrint then printx( 1 , "checkHasOtherCannon  _r"  , _r , "_c" , _c , "isFirstGrid =" , isFirstGrid ) end

			local item = mainLogic.gameItemMap[_r][_c] 
			local board = mainLogic.boardmap[_r][_c] 

			if isFirstGrid then
				firstBoard = board
				temBoard = firstBoard
				if board:isGravityDown() then
					if self:hasTopChain( board ) then
						--isFirstGrid意味着这个格子就是检测链最开始的那个生成口，而生成口被冰柱拦住一律不生成
						-- if textPrint then printx( 1 , "isFirstGrid ~~~~~  return false  isGravityDown 1"  ) end
						return false
					elseif self:hasTopRope( board ) then
						if board:hasExitPortal() then
							-- if textPrint then printx( 1 , "isFirstGrid ~~~~~  return false  isGravityDown 2"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							-- if textPrint then printx( 1 , "isFirstGrid ~~~~~  return false  isGravityDown 3"  ) end
							return true
						end
					else
						if board:hasExitPortal() then
							-- if textPrint then printx( 1 , "isFirstGrid ~~~~~  return false  isGravityDown 4"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						end
					end
				elseif board:isGravityUp() then
					if self:hasBottomChain( board ) then
						--isFirstGrid意味着这个格子就是检测链最开始的那个生成口，而生成口被冰柱拦住一律不生成
						return false
					elseif self:hasBottomRope( board ) then
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							return true
						end
					else
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						end
					end
				elseif board:isGravityLeft() then
					if self:hasRightChain( board ) then
						--isFirstGrid意味着这个格子就是检测链最开始的那个生成口，而生成口被冰柱拦住一律不生成
						return false
					elseif self:hasRightRope( board ) then
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							return true
						end
					else
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						end
					end
				else
					if self:hasLeftChain( board ) then
						--isFirstGrid意味着这个格子就是检测链最开始的那个生成口，而生成口被冰柱拦住一律不生成
						return false
					elseif self:hasLeftRope( board ) then
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							return true
						end
					else
						if board:hasExitPortal() then
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						end
					end
				end

			else

				if not temBoard then
					temBoard = board
				end

				if temBoard and board:getGravity() ~= temBoard:getGravity() then
					-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  gravity Diff"  ) end
					return true
				end

				if board:isGravityDown() then
					if not isPortalEnterMode then
						if not board.isUsed or item.isBlock or board.isBlock then --如果格子本身是block
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 1"  ) end
							return true
						end

						if self:hasBottomRopeOrChain( board ) or board:hasEnterPortal() then --格子底部有绳子、冰柱、传送门入口
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 2"  ) end
							return true
						end
					end

					if self:hasTopChain( board ) then --顶部有冰柱（会阻挡传送门和生成口）
						-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 3"  ) end
						return true
					else
						if board.isProducer then --有生成口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 4"  ) end
							return false
						end

						if board:hasExitPortal() then --有传送门出口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 5"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							if self:hasTopRope( board ) then --顶部有绳子
								-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 6"  ) end
								return true
							end
						end
					end
				elseif board:isGravityUp() then
					if not isPortalEnterMode then
						if not board.isUsed or item.isBlock or board.isBlock then --如果格子本身是block
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 1"  ) end
							return true
						end

						if self:hasTopRopeOrChain( board ) or board:hasEnterPortal() then --格子顶部有绳子、冰柱、传送门入口
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 2"  ) end
							return true
						end
					end

					if self:hasBottomChain( board ) then --底部有冰柱（会阻挡传送门和生成口）
						-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 3"  ) end
						return true
					else
						if board.isProducer then --有生成口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 4"  ) end
							return false
						end

						if board:hasExitPortal() then --有传送门出口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 5"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							if self:hasBottomRope( board ) then --底部有绳子
								-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 6"  ) end
								return true
							end
						end
					end
				elseif board:isGravityLeft() then
					if not isPortalEnterMode then
						if not board.isUsed or item.isBlock or board.isBlock then --如果格子本身是block
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 1"  ) end
							return true
						end

						if self:hasLeftRopeOrChain( board ) or board:hasEnterPortal() then --格子左侧有绳子、冰柱、传送门入口
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 2"  ) end
							return true
						end
					end

					if self:hasRightChain( board ) then --右侧有冰柱（会阻挡传送门和生成口）
						-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 3"  ) end
						return true
					else
						if board.isProducer then --有生成口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 4"  ) end
							return false
						end

						if board:hasExitPortal() then --有传送门出口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 5"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							if self:hasRightRope( board ) then --右侧有绳子
								-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 6"  ) end
								return true
							end
						end
					end
				else
					if not isPortalEnterMode then
						if not board.isUsed or item.isBlock or board.isBlock then --如果格子本身是block
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 1"  ) end
							return true
						end

						if self:hasRightRopeOrChain( board ) or board:hasEnterPortal() then --格子右侧有绳子、冰柱、传送门入口
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 2"  ) end
							return true
						end
					end

					if self:hasLeftChain( board ) then --左侧有冰柱（会阻挡传送门和生成口）
						-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 3"  ) end
						return true
					else
						if board.isProducer then --有生成口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 4"  ) end
							return false
						end

						if board:hasExitPortal() then --有传送门出口，不会被阻挡
							-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 5"  ) end
							return checkByPortal( board.passEnterPoint_x , board.passEnterPoint_y )
						else
							if self:hasLeftRope( board ) then --左侧有绳子
								-- if textPrint then printx( 1 , "Not isFirstGrid ~~~~~  return false  isGravityDown 6"  ) end
								return true
							end
						end
					end
				end
			end

			local prevR = 0
			local prevC = 0
			if board:isGravityDown() then
				prevR = _r - 1
				prevC = _c
			elseif board:isGravityUp() then
				prevR = _r + 1
				prevC = _c
			elseif board:isGravityLeft() then
				prevR = _r
				prevC = _c + 1
			else
				prevR = _r
				prevC = _c - 1
			end

			if not mainLogic:isPosValid( prevR , prevC ) then 
				-- if textPrint then printx( 1 , "checkByPortal ~~~~~  return false  prev isPosValid"  ) end
				return true 
			end

			return checkHasOtherCannon( prevR , prevC , false , false )
		end	

		-- 当前r,c的位置一定有个生成口，返回结果为r,c位置的生成口的上游路径里是否还有别的可用生成口
		-- 即返回当前r,c位置的生成口是否应该屏蔽 , true为不屏蔽 , false为屏蔽
		local result = checkHasOtherCannon( r , c , true , false)

		-- if textPrint then printx( 1 , "checkFallingByCannon ---------- result ="  , result  ) end

		return result
	end

	-- if textPrint then printx( 1 , "checkFallingByCannon  return 1" ) end

	return false
end

function NewFallingItemLogic:doFallingByCannon(mainLogic , r , c)

	local item1 = mainLogic.gameItemMap[r][c]		----生成位置
	local board1 = mainLogic.boardmap[r][c]		----生成位置
	item1.gotoPos = IntCoord:create(r,c)
	item1.comePos = IntCoord:create(0,0)

	----直接放入------随机生成-----
	local data1 = mainLogic:randomANewItemFallingData(r,c)		----随机一个数据
	item1:getAnimalLikeDataFrom(data1) 							----获取物品信息
	item1.dataReach = false 									----数据未到
	item1:AddItemStatus( GameItemStatusType.kIsFalling )		----正在下落
	
	local rfix = 0
	local cfix = 0

	if board1:isGravityDown() then
		item1.ClippingPosAdd.y = GamePlayConfig_Tile_Height
		rfix = 1
	elseif board1:isGravityUp() then
		item1.ClippingPosAdd.y = GamePlayConfig_Tile_Height * -1
		rfix = -1
	elseif board1:isGravityLeft() then
		item1.ClippingPosAdd.x = GamePlayConfig_Tile_Width
		cfix = -1
	else
		item1.ClippingPosAdd.x = GamePlayConfig_Tile_Width * -1
		cfix = 1
	end
	
	if mainLogic:isPosValid(r + rfix, c + cfix) then
		local item2 = mainLogic.gameItemMap[r + rfix][c + cfix]
		local board2 = mainLogic.boardmap[r + rfix][c + cfix]

		if board1:getGravity() == board2:getGravity() then
			if board2:isGravityDown() then
				if item2.itemPosAdd.y ~= 0 then
					item1.ClippingPosAdd.y = item2.itemPosAdd.y	
				end
			elseif board2:isGravityUp() then
				if item2.itemPosAdd.y ~= 0 then
					item1.ClippingPosAdd.y = item2.itemPosAdd.y	
				end
			elseif board2:isGravityLeft() then
				if item2.itemPosAdd.x ~= 0 then
					item1.ClippingPosAdd.x = item2.itemPosAdd.x	
				end
			else
				if item2.itemPosAdd.x ~= 0 then
					item1.ClippingPosAdd.x = item2.itemPosAdd.x	
				end
			end
		end
	end

	item1.itemPosAdd.x = item1.ClippingPosAdd.x
	item1.itemPosAdd.y = item1.ClippingPosAdd.y
	item1.isEmpty = false;

	item1.isProduct = true;
	----开始动作----
	local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemFalling_Product,
		IntCoord:create(r,c),
		IntCoord:create(r + rfix, c + cfix),
		GamePlayConfig_Falling_MaxTime)

	mainLogic:addFallingAction(FallingAction)
	FallingAction.addInfo = "Pass"

end

function NewFallingItemLogic:checkFallingBySideBottomEmpty(mainLogic , r , c)

	-- local needPrint = false
	-- if r == 8 and c == 5 then
	-- 	needPrint = true
	-- end
	-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty 111.132456798 r" , r , "c" , c) end

	local board1 = mainLogic.boardmap[r][c]
	local nr = 0
	local nc = 0

	local fixr_right = 0
	local fixc_right = 0

	local fixr_left = 0
	local fixc_left = 0

	local posX_right = 0
	local posY_right = 0

	local posX_left = 0
	local posY_left = 0

	if board1:isGravityDown() then
		nr = r+1
		nc = c

		fixr_right = 1
		fixc_right = 1
		fixr_left = 1
		fixc_left = -1

		posX_right = GamePlayConfig_Tile_Width * -1
		posY_right = GamePlayConfig_Tile_Height
		posX_left = GamePlayConfig_Tile_Width
		posY_left = GamePlayConfig_Tile_Height

		if self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r, c , nr , nc ) then
			-- if needPrint then printx( 1 , "hasRopeLikeBetweenTwoVerticalGrids !!!" , r, c , nr , nc ) end
			-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty return  1" ) end
			return false
		end
	elseif board1:isGravityUp() then
		nr = r-1
		nc = c
		fixr_right = -1
		fixc_right = -1
		fixr_left = -1
		fixc_left = 1

		posX_right = GamePlayConfig_Tile_Width
		posY_right = GamePlayConfig_Tile_Height * -1
		posX_left = GamePlayConfig_Tile_Width * -1
		posY_left = GamePlayConfig_Tile_Height * -1

		if self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic,  nr , nc , r, c ) then
			return false
		end
	elseif board1:isGravityLeft() then 
		nr = r
		nc = c-1
		fixr_right = 1
		fixc_right = -1
		fixr_left = -1
		fixc_left = -1

		posX_right = GamePlayConfig_Tile_Width
		posY_right = GamePlayConfig_Tile_Height
		posX_left = GamePlayConfig_Tile_Width
		posY_left = GamePlayConfig_Tile_Height * -1
		if self:hasRopeLikeBetweenTwoHorizontalGrids( mainLogic,  nr , nc , r , c ) then
			return false
		end
	else
		nr = r
		nc = c+1
		fixr_right = -1
		fixc_right = 1
		fixr_left = 1
		fixc_left = 1

		posX_right = GamePlayConfig_Tile_Width * -1
		posY_right = GamePlayConfig_Tile_Height * -1
		posX_left = GamePlayConfig_Tile_Width * -1
		posY_left = GamePlayConfig_Tile_Height
		if self:hasRopeLikeBetweenTwoHorizontalGrids( mainLogic , r , c , nr , nc ) then
			-- if needPrint then printx( 1 , "hasRopeLikeBetweenTwoHorizontalGrids !!!" , r, c , nr , nc ) end
			-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty return  4" ) end
			return false
		end
	end

	-- if self:hasRopeLikeBetweenTwoVerticalGrids( mainLogic, r, c , nr , nc ) then
	-- 	if needPrint then printx( 1 , "hasRopeLikeBetweenTwoVerticalGrids !!!" , r, c , nr , nc ) end
	-- 	if needPrint then printx( 1 , "checkFallingBySideBottomEmpty return  1" ) end
	-- 	return false
	-- end

	local vfPlan = self.fallingPlanMap.verticalFallingPlan
	--printx( 1 , "NewFallingItemLogic:checkFallingBySideBottomEmpty   vfPlan   ------------- " , table.tostring(vfPlan) )

	local randomNum = mainLogic.fallingLogicRandFactory:rand( 1 , 2 )

	local tr = 0
	local tc = 0
	local fx = 0  

	if randomNum == 1 then
		--先右下再左下(注意，这里的方向指的是相对方向，即重力为下时的方向)

		if not vfPlan[tostring(r + fixr_right) .. "_" .. tostring(c + fixc_right) ] 
			and NewFallingItemLogic:isGridCanBeFallingIn( mainLogic , r + fixr_right , c + fixc_right )
			and not self:hasRopeLikeBetweenTwoObliqueVerticalGrids( mainLogic, r, c , r + fixr_right , c + fixc_right  , 2) then 	----右下方的格子可以被掉落进去
			tr = r + fixr_right
			tc = c + fixc_right
			fx = 2
		elseif not vfPlan[tostring(r + fixr_left) .. "_" .. tostring(c + fixc_left) ] 
			and NewFallingItemLogic:isGridCanBeFallingIn( mainLogic , r + fixr_left , c + fixc_left )
			and not self:hasRopeLikeBetweenTwoObliqueVerticalGrids( mainLogic, r, c , r + fixr_left , c + fixc_left  , 1) then 	----左下方的格子可以被掉落进去
			tr = r + fixr_left
			tc = c + fixc_left
			fx = 1
		end
	else
		--先左下再右下(注意，这里的方向指的是相对方向，即重力为下时的方向)

		if not vfPlan[tostring(r + fixr_left) .. "_" .. tostring(c + fixc_left) ] 
			and NewFallingItemLogic:isGridCanBeFallingIn( mainLogic , r + fixr_left , c + fixc_left )
			and not self:hasRopeLikeBetweenTwoObliqueVerticalGrids( mainLogic, r, c , r + fixr_left , c + fixc_left  , 1) then 	----左下方的格子可以被掉落进去
			tr = r + fixr_left
			tc = c + fixc_left
			fx = 1
		elseif not vfPlan[tostring(r + fixr_right) .. "_" .. tostring(c + fixc_right) ] 
			and NewFallingItemLogic:isGridCanBeFallingIn( mainLogic , r + fixr_right , c + fixc_right ) 
			and not self:hasRopeLikeBetweenTwoObliqueVerticalGrids( mainLogic, r, c , r + fixr_right , c + fixc_right  , 2) then 	----右下方的格子可以被掉落进去
			tr = r + fixr_right
			tc = c + fixc_right
			fx = 2
		end
	end

	-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty 222  tr" , tr , "tc" , tc ) end
	if tr > 0 and tc > 0 then
		local item1 = mainLogic.gameItemMap[r][c] 	----上面那个
		local item2 = mainLogic.gameItemMap[tr][tc]		----下面空位

		--printx( 1 , "NewFallingItemLogic:checkFallingBySideBottomEmpty   r",r,"c",c,"tr" , tr , "tc" , tc)

		item2.gotoPos = IntCoord:create( tr ,  tc )
		item2.comePos = IntCoord:create( r , c )

		----直接放入----
		item2:getAnimalLikeDataFrom(item1)	----获取物品信息
		item2.dataReach = false 								----数据未到
		item2:AddItemStatus( GameItemStatusType.kIsFalling )		----正在下落

		if fx == 1 then 
			-- printx( 1 , "[checkFallingBySideBottomEmpty] fx 1111111111111111  posX =" , posX_left , "posY =" , posY_left )
			item2.itemPosAdd.x = posX_left        --左
			item2.itemPosAdd.y = posY_left		
		else
			-- printx( 1 , "[checkFallingBySideBottomEmpty] fx 2222222222222222  posX =" , posX_right , "posY =" , posY_right )
			item2.itemPosAdd.x = posX_right       --右
			item2.itemPosAdd.y = posY_right		
		end
		
		item2.isEmpty = false;
		item2.itemSpeed = 0;

		item1:cleanAnimalLikeData()

		----开始动作----

		local FallingAction = GameBoardActionDataSet:createAs(		------下落动作
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemFalling_LeftRight,
			IntCoord:create( r , c ),
			IntCoord:create( tr , tc ),
			GamePlayConfig_Falling_LeftRight_Time)
		mainLogic:addFallingAction(FallingAction)
		FallingAction.addInfo = "Pass"
-------============================================================================================
		-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty return  3" ) end
		return true , fx , tr , tc
	else
		local item1 = mainLogic.gameItemMap[r][c] 	----上面那个

		if item1.ItemStatus == GameItemStatusType.kJustArrived then
			item1:AddItemStatus( GameItemStatusType.kItemHalfStable )		----结束掉落，检测三消
		end
	end

	-- if needPrint then printx( 1 , "checkFallingBySideBottomEmpty return  2" ) end
	return false
end

function NewFallingItemLogic:updateVerticalFallingPlan( mainLogic , r , c , isFirstGrid )

	if not mainLogic:isPosValid(r, c) then return end

	if self.fallingPlanMap and self.fallingPlanMap.verticalFallingPlan then
		local vfPlan = self.fallingPlanMap.verticalFallingPlan

		local tr = r
		local tc = c

		if UseNewFallingLogic == 1.1 then

			if vfPlan[tostring(tr) .. "_" .. tostring(tc) ] then
				return
			end

			local board1 = mainLogic.boardmap[r][c]
			
			if not board1.isUsed then 
				return 
			end

			local function doCheck( _r , _c , isPortalExitMode )
				local maxRowCount = #mainLogic.gameItemMap

				if vfPlan[tostring(_r) .. "_" .. tostring(_c)] then
					return
				end

				local _item = mainLogic.gameItemMap[_r][_c]
				local _board = mainLogic.boardmap[_r][_c]

				local startPointHasRopeLike = false
				local endPointHasRopeLike = false
				local nextR = 0
				local nextC = 0

				if _board:isGravityDown() then
					if self:hasTopRopeOrChain( _board ) then
						startPointHasRopeLike = true
					end
					if self:hasBottomRopeOrChain( _board ) then
						endPointHasRopeLike = true
					end
					nextR = _r + 1
					nextC = _c
				elseif _board:isGravityUp() then
					if self:hasBottomRopeOrChain( _board ) then
						startPointHasRopeLike = true
					end
					if self:hasTopRopeOrChain( _board ) then
						endPointHasRopeLike = true
					end
					nextR = _r - 1
					nextC = _c
				elseif _board:isGravityLeft() then
					if self:hasRightRopeOrChain( _board ) then
						startPointHasRopeLike = true
					end
					if self:hasLeftRopeOrChain( _board ) then
						endPointHasRopeLike = true
					end
					nextR = _r
					nextC = _c - 1
				else
					if self:hasLeftRopeOrChain( _board ) then
						startPointHasRopeLike = true
					end
					if self:hasRightRopeOrChain( _board ) then
						endPointHasRopeLike = true
					end
					nextR = _r
					nextC = _c + 1
				end

				if isFirstGrid then
					if not _board.isUsed or _item.isBlock or _board.isBlock then
						return
					end

					vfPlan[tostring(_r) .. "_" .. tostring(_c)] = true

					if endPointHasRopeLike then
						return
					end
				else
					if not _board.isUsed or _item.isBlock or _board.isBlock 
						or ( not isPortalExitMode and _board:hasExitPortal() ) then
						return
					end

					if startPointHasRopeLike then
						return
					end

					vfPlan[tostring(_r) .. "_" .. tostring(_c)] = true

					if endPointHasRopeLike then
						return
					end
				end

				isFirstGrid = false
				local needBreak = false

				if _board:hasEnterPortal() then
					-- checkByPortal( _board.passExitPoint_x , _board.passExitPoint_y )
					doCheck( _board.passExitPoint_x , _board.passExitPoint_y , true )
					needBreak = true
					return
				end

				if not needBreak then
					if mainLogic:isPosValid(nextR, nextC) then 
						local nextBoard = mainLogic.boardmap[nextR][nextC]

						if nextBoard:getGravity() == _board:getGravity() then
							doCheck( nextR , nextC , false )
						end
					end
				end
			end
			doCheck( tr , tc , false )
		else

			if vfPlan[tostring(tr) .. "_" .. tostring(tc) ] then
				return
			end

			local board1 = mainLogic.boardmap[r][c]
			
			if not board1.isUsed then return end

			if board1.passExitPoint_x > 0 and board1.passExitPoint_y > 0 then

				if self:checkFallingByPortal( mainLogic , tr , tc ) then
					vfPlan[tostring(tr) .. "_" .. tostring(tc) ] = true
					vfPlan[tostring(board1.passExitPoint_x) .. "_" .. tostring(board1.passExitPoint_y) ] = true
					self:updateVerticalFallingPlan( mainLogic , board1.passExitPoint_x , board1.passExitPoint_y )
					return
				end

			else
				for i = tr , #mainLogic.gameItemMap do

					local cr = i
					local board2 = mainLogic.boardmap[cr][tc]
					if not board2.isUsed then return end

					if self:checkFallingByBottomEmpty( mainLogic , cr , tc ) then
						vfPlan[tostring(cr) .. "_" .. tostring(tc) ] = true
						vfPlan[tostring(cr + 1) .. "_" .. tostring(tc) ] = true
					else
						return
					end
				end
			end
		end
	end
end

function NewFallingItemLogic:checkGridIsPortalExitAndJustEmpty(mainLogic , r ,c , justEmpty)

	local itemIsEmpty = true

	if not justEmpty then
		local item2 = mainLogic.gameItemMap[r][c] --出口格子
		itemIsEmpty = item2.isEmpty
	end

	if itemIsEmpty then

		local board2 = mainLogic.boardmap[r][c] --出口格子

		if board2.passEnterPoint_x > 0 and board2.passEnterPoint_y > 0 then --当前格子是否是传送门的出口，如果是，取它的入口坐标，把入口的东西尝试拉过来
			
			local item1 = mainLogic.gameItemMap[board2.passEnterPoint_x][board2.passEnterPoint_y] -- 入口格子
			local board1 = mainLogic.boardmap[board2.passEnterPoint_x][board2.passEnterPoint_y] -- 入口格子
			local vfPlan = self.fallingPlanMap.verticalFallingPlan

			if item1.isUsed and not item1.isEmpty and item1:checkCanFallingByItemStatus() and not item1.isBlock then

				if self:checkFallingByPortal( mainLogic , board2.passEnterPoint_x , board2.passEnterPoint_y ) then
					self:doFallingByPortal( mainLogic , board2.passEnterPoint_x , board2.passEnterPoint_y )
					-- vfPlan[ tostring(r) .. "_" .. tostring(c) ] = true --doFallingByPortal内部已经会调用 updateVerticalFallingPlan 
				end
			end

			if UseNewFallingLogic == 1 then
				if not board2.isProducer then
					vfPlan[ tostring(r) .. "_" .. tostring(c) ] = true
				end
			elseif UseNewFallingLogic == 1.1 then

				if item1.isUsed and not item1.isBlock then

					if not self:hasBottomChain(board1) and not self:hasTopChain(board2) then
						vfPlan[ tostring(r) .. "_" .. tostring(c) ] = true  --临时锁定一帧
					end
				end

			else
				vfPlan[ tostring(r) .. "_" .. tostring(c) ] = true
			end
			
		end
	end
end

function NewFallingItemLogic:__resetSpeedAndPosY( mainLogic , r , c , speedOpr , posOpr , fixSpd )
	if not mainLogic:isPosValid(r, c) then return end
	local item1 = mainLogic.gameItemMap[r][c]
	local board1 = mainLogic.boardmap[r][c]
	if not item1.comePos then
		-- printx( 1 , "__resetSpeedAndPosY  RETURN !!!!!!!!!!!!!!!!!  item1.comePos =" , item1.comePos)
		return
	end
	local comeR = item1.comePos.x
	local comeC = item1.comePos.y

	local function resetByDown()
		if item1.itemPosAdd.y < 0 then 
			if item1.itemPosAdd.y < (GamePlayConfig_Tile_Height / -2) then
				item1.itemPosAdd.y = GamePlayConfig_Tile_Height / -2 
			else
				item1.itemPosAdd.y = 0 
			end
		end
	end

	local function resetByUp()
		if item1.itemPosAdd.y > 0 then 
			if item1.itemPosAdd.y > (GamePlayConfig_Tile_Height / 2) then
				item1.itemPosAdd.y = GamePlayConfig_Tile_Height / 2 
			else
				item1.itemPosAdd.y = 0 
			end
		end
	end

	local function resetByLeft()
		if item1.itemPosAdd.x < 0 then 
			if item1.itemPosAdd.x < (GamePlayConfig_Tile_Width / -2) then
				item1.itemPosAdd.x = GamePlayConfig_Tile_Width / -2 
			else
				item1.itemPosAdd.x = 0 
			end
		end
	end

	local function resetByRight()
		if item1.itemPosAdd.x > 0 then 
			if item1.itemPosAdd.x > (GamePlayConfig_Tile_Width / 2) then
				item1.itemPosAdd.x = GamePlayConfig_Tile_Width / 2 
			else
				item1.itemPosAdd.x = 0 
			end
		end	
	end


	if item1.isUsed and not item1.isEmpty and not item1.isBlock
		and ( item1.ItemStatus == GameItemStatusType.kIsFalling or item1.ItemStatus == GameItemStatusType.kJustArrived )
		then

		if (not posOpr) or posOpr == 1 then

			if board1:isGravityDown() then
				if comeR < r then
					resetByDown()
				elseif comeR > r then
					resetByUp()
				elseif comeC < c then
					resetByRight()
				elseif comeC > c then
					resetByLeft()
				end
			elseif board1:isGravityUp() then
				if comeR < r then
					resetByDown()
				elseif comeR > r then
					resetByUp()
				elseif comeC < c then
					resetByRight()
				elseif comeC > c then
					resetByLeft()
				end
			elseif board1:isGravityLeft() then
				if comeR < r then
					resetByDown()
				elseif comeR > r then
					resetByUp()
				elseif comeC < c then
					resetByRight()
				elseif comeC > c then
					resetByLeft()
				end
			else
				if comeR < r then
					resetByDown()
				elseif comeR > r then
					resetByUp()
				elseif comeC < c then
					resetByRight()
				elseif comeC > c then
					resetByLeft()
				end
			end
		end
		
		if posOpr == 1 then
 			posOpr = 2
		end
		if not speedOpr then 
			item1.itemSpeed = 0 
		elseif speedOpr == 1 then
			if fixSpd then
				if board1:isGravityDown() then
					item1.itemSpeed = math.max( item1.itemPosAdd.y , 0 )
				elseif board1:isGravityUp() then
					item1.itemSpeed = math.max( item1.itemPosAdd.y * -1 , 0 )
				elseif board1:isGravityLeft() then
					item1.itemSpeed = math.max( item1.itemPosAdd.x , 0 )
				else
					item1.itemSpeed = math.max( item1.itemPosAdd.x * -1 , 0 )
				end
			else
				item1.itemSpeed = item1.itemSpeed - GamePlayConfig_FallingSpeed_Add
				if item1.itemSpeed < 0 then item1.itemSpeed = 0 end
			end
		end
		----[[

		local fixSpdToPosZero = false
		if speedOpr == 1 and posOpr == 2 then
			fixSpdToPosZero = true
		end

		if board1:isGravityDown() then
			if mainLogic:isPosValid( r - 1 , c ) then
				local board2 = mainLogic.boardmap[r - 1][c]
				if board2:isGravityDown() then
					self:__resetSpeedAndPosY( mainLogic , r - 1 , c , speedOpr , posOpr , fixSpdToPosZero )
				end
			end
		elseif board1:isGravityUp() then
			if mainLogic:isPosValid( r + 1 , c ) then
				local board2 = mainLogic.boardmap[r + 1][c]
				if board2:isGravityUp() then
					self:__resetSpeedAndPosY( mainLogic , r + 1 , c , speedOpr , posOpr , fixSpdToPosZero )
				end
			end
		elseif board1:isGravityLeft() then
			if mainLogic:isPosValid( r , c + 1 ) then
				local board2 = mainLogic.boardmap[r][c + 1]
				if board2:isGravityLeft() then
					self:__resetSpeedAndPosY( mainLogic , r , c + 1 , speedOpr , posOpr , fixSpdToPosZero )
				end
			end
		else
			if mainLogic:isPosValid( r , c - 1 ) then
				local board2 = mainLogic.boardmap[r][c - 1]
				if board2:isGravityRight() then
					self:__resetSpeedAndPosY( mainLogic , r , c - 1 , speedOpr , posOpr , fixSpdToPosZero )
				end
			end
		end
		--]]
	end
end

function NewFallingItemLogic:checkResetSpeedByPortal( mainLogic , r , c )
	local board1 = mainLogic.boardmap[r][c]
	if board1:hasEnterPortal() and self:checkFallingByPortal( mainLogic , r , c ) then
		-- printx( 1 , "[checkResetSpeedByPortal]  __resetSpeedAndPosY  111" , r , c)
		self:__resetSpeedAndPosY( mainLogic , r , c )
	end
end

function NewFallingItemLogic:checkResetSpeedByFallingGoal( mainLogic , r , c )
	local board1 = mainLogic.boardmap[r][c]
	
	if not board1:hasEnterPortal() then

		local item1 = mainLogic.gameItemMap[r][c]
		local board1 = mainLogic.boardmap[r][c]

		local comeR = item1.comePos.x
		local comeC = item1.comePos.y

		local item2 = nil

		-- printx( 1 ,"checkResetSpeedByFallingGoal ~~~!@@@@  comeR" , comeR , "comeC" , comeC , "r" , r  , "c" , c )

		if board1:isGravityDown() and mainLogic:isPosValid( r + 1 , c ) and comeR < r then
			item2 = mainLogic.gameItemMap[r + 1][c]
		elseif board1:isGravityUp() and mainLogic:isPosValid( r - 1 , c ) and comeR > r then
			item2 = mainLogic.gameItemMap[r - 1][c]
		elseif board1:isGravityLeft() and mainLogic:isPosValid( r , c - 1 ) and comeC > c then
			item2 = mainLogic.gameItemMap[r][c - 1]
		elseif board1:isGravityRight() and mainLogic:isPosValid( r , c + 1 ) and comeC < c then
			item2 = mainLogic.gameItemMap[r][c + 1]
		end

		-- printx( 1 , "[checkResetSpeedByFallingGoal]  r =" , r , "c =" , c , "item2 =" , item2 )

		if not item2 then
			-- printx( 1 , "[checkResetSpeedByFallingGoal]  __resetSpeedAndPosY  111")
			self:__resetSpeedAndPosY( mainLogic , r , c , 1 , 1 )
			return
		else
			if item2.isUsed then
				if not item2.isEmpty then
					if item2.isBlock then
						-- printx( 1 , "[checkResetSpeedByFallingGoal]  __resetSpeedAndPosY  222")
						self:__resetSpeedAndPosY( mainLogic , r , c , 1 , 1 )
					elseif item2.ItemStatus ~= GameItemStatusType.kIsFalling and item2.ItemStatus ~= GameItemStatusType.kJustArrived then
						-- printx( 1 , "[checkResetSpeedByFallingGoal]  __resetSpeedAndPosY  333")
						self:__resetSpeedAndPosY( mainLogic , r , c , 1 , 1 )
					end
				end
			else
				-- printx( 1 , "[checkResetSpeedByFallingGoal]  __resetSpeedAndPosY  444")
				self:__resetSpeedAndPosY( mainLogic , r , c , 1 , 1 )
			end
		end
	end
end

function NewFallingItemLogic:FallingGameItemCheck(mainLogic)----全局检测掉落-----to do-----------------------------------------------

	local currHoldrand = mainLogic.randFactory:getCurrHoldrand()
	mainLogic.fallingLogicRandFactory:randSeed(currHoldrand)

	if not self.fallingPlanMap then self.fallingPlanMap = {} end
	self.fallingPlanMap.verticalFallingPlan = {}

	local vfPlan = self.fallingPlanMap.verticalFallingPlan
	-- printx( 1 , "NewFallingItemLogic:FallingGameItemCheck ----全局检测掉落-----")

	local isStillFalling = false

	local arr = {1,2,3,4,5,6,7,8,9}
	local randomArr = {} --每次都重置随机队列

	for i = 1 , 9 do
		local rindex = mainLogic.fallingLogicRandFactory:rand( 1 , #arr )
		table.insert( randomArr , arr[rindex] )
		table.remove( arr , rindex )
	end

	local gravityDownArr = {}
	local gravityUpArr = {}
	local gravityLeftArr = {}
	local gravityRightArr = {}

	for r = 1 , 9 do			----由下至上
		for _k , c in ipairs(randomArr) do              ----横排随机取
			local board = mainLogic.boardmap[r][c]
			if board:isGravityDown() then
				table.insert( gravityDownArr , 1 , board )
			elseif board:isGravityUp() then
				table.insert( gravityUpArr , board )
			end
		end
	end

	for c = 1 , 9 do			----由下至上
		for _k , r in ipairs(randomArr) do              ----横排随机取
			local board = mainLogic.boardmap[r][c]
			if board:isGravityLeft() then
				table.insert( gravityLeftArr , board )
			elseif board:isGravityRight() then
				table.insert( gravityRightArr , 1 , board )
			end
		end
	end

	local maxGravityArrLength = 0
	if #gravityDownArr > maxGravityArrLength then maxGravityArrLength = #gravityDownArr end
	if #gravityUpArr > maxGravityArrLength then maxGravityArrLength = #gravityUpArr end
	if #gravityLeftArr > maxGravityArrLength then maxGravityArrLength = #gravityLeftArr end
	if #gravityRightArr > maxGravityArrLength then maxGravityArrLength = #gravityRightArr end

	local function getRandomGravityArrSortList()
		local _arr = {1,2,3,4}
		local _randomArr = {} --每次都重置随机队列

		for i = 1 , 4 do
			local rindex = mainLogic.fallingLogicRandFactory:rand( 1 , #_arr )
			table.insert( _randomArr , _arr[rindex] )
			table.remove( _arr , rindex )
		end

		local returnArr = {}
		for i = 1 , 4 do
			if _randomArr[i] == 1 then
				table.insert( returnArr , gravityDownArr )
			elseif _randomArr[i] == 2 then
				table.insert( returnArr , gravityUpArr )
			elseif _randomArr[i] == 3 then
				table.insert( returnArr , gravityLeftArr )
			else
				table.insert( returnArr , gravityRightArr )
			end
		end

		return returnArr
	end

	local gravityArrSortList = getRandomGravityArrSortList()

	----传送门
	for i = 1 , maxGravityArrLength do
		for ia = 1 , #gravityArrSortList do
			local gravityArr = gravityArrSortList[ia]
			if gravityArr[i] then
				local board = gravityArr[i]
				local r = board.y
				local c = board.x
				local item = mainLogic.gameItemMap[r][c]

				if item.isUsed and not item.isEmpty and item:checkCanFallingByItemStatus() and not item.isBlock then
					if board:hasEnterPortal() then
						if self:checkFallingByPortal( mainLogic , r , c ) then
							self:doFallingByPortal( mainLogic , r , c )
							isStillFalling = true
						end
					end
				end
			end
		end
	end

	----直线掉落
	for i = 1 , maxGravityArrLength do
		for ia = 1 , #gravityArrSortList do
			local gravityArr = gravityArrSortList[ia]
			if gravityArr[i] then
				local board = gravityArr[i]
				local r = board.y
				local c = board.x
				local item = mainLogic.gameItemMap[r][c]
				local board = mainLogic.boardmap[r][c]

				if item.isUsed and not item.isEmpty and not item.isBlock then
					if item:checkCanFallingByItemStatus() then
						if self:checkFallingByBottomEmpty( mainLogic , r , c ) then
							self:doFallingByBottomEmpty( mainLogic , r , c )
							if board:isGravityDown() then
								self:updateVerticalFallingPlan( mainLogic , r + 1 , c , true )
							elseif board:isGravityUp() then
								self:updateVerticalFallingPlan( mainLogic , r - 1 , c , true )
							elseif board:isGravityLeft() then
								self:updateVerticalFallingPlan( mainLogic , r , c - 1 , true )
							else
								self:updateVerticalFallingPlan( mainLogic , r , c + 1 , true )
							end
							self:checkGridIsPortalExitAndJustEmpty( mainLogic , r , c , true )
							isStillFalling = true
						end
					elseif item.ItemStatus ~= GameItemStatusType.kNone or true then
						self:updateVerticalFallingPlan( mainLogic , r , c , true )
					end
				end
			end
		end
	end

	----生成口决策
	local producers = {}

	for i = 1 , maxGravityArrLength do
		for ia = 1 , #gravityArrSortList do
			local gravityArr = gravityArrSortList[ia]
			if gravityArr[i] then
				local board = gravityArr[i]
				local r = board.y
				local c = board.x
				local item = mainLogic.gameItemMap[r][c]

				if board.isUsed and board.isProducer and not vfPlan[tostring(r) .. "_" .. tostring(c) ] then
					if self:checkFallingByCannon( mainLogic, r, c ) then
						table.insert( producers , IntCoord:create(r, c) )
					end
				end
			end
		end
	end

	-- 生成口实际执行
	if #producers > 0 then
		local sortedProductPortals = mainLogic:sortProductPortals(producers)
		for _, pos in ipairs(sortedProductPortals) do
			self:doFallingByCannon(mainLogic, pos.x, pos.y)
			self:updateVerticalFallingPlan( mainLogic , pos.x, pos.y , true )
		end
		isStillFalling = true
	end

	----斜线掉落
	for i = 1 , maxGravityArrLength do
		for ia = 1 , #gravityArrSortList do
			local gravityArr = gravityArrSortList[ia]
			if gravityArr[i] then
				local board = gravityArr[i]
				local r = board.y
				local c = board.x
				local item = mainLogic.gameItemMap[r][c]

				if item.isUsed and not item.isEmpty and item:checkCanFallingByItemStatus() and not item.isBlock then
					if UseNewFallingLogic >= 1 and UseNewFallingLogic < 2 then
						if self:checkFallingByBottomEmpty( mainLogic , r , c ) then --斜线掉落也要先检查正下方是否能掉落，因为下方的格子发生斜线掉落后，上方格子也许可以执行直线掉落
							self:doFallingByBottomEmpty( mainLogic , r , c )
							isStillFalling = true
						else
							local result , fx , tr ,tc = self:checkFallingBySideBottomEmpty( mainLogic , r , c )
							if result then
								local trboard = mainLogic.boardmap[tr][tc]
								if trboard:isGravityDown() then
									self:updateVerticalFallingPlan( mainLogic , tr + 1 , tc , true )
								elseif trboard:isGravityUp() then
									self:updateVerticalFallingPlan( mainLogic , tr - 1 , tc , true )
								elseif trboard:isGravityLeft() then
									self:updateVerticalFallingPlan( mainLogic , tr , tc - 1 , true )
								else
									self:updateVerticalFallingPlan( mainLogic , tr , tc + 1 , true )
								end
								isStillFalling = true
							end
						end
					elseif UseNewFallingLogic == 2 then
						if not NewFallingItemLogic:isGridCanBeFallingOut( mainLogic , r - 1 , c ) then
							if self:checkFallingBySideBottomEmpty( mainLogic , r , c ) then
								isStillFalling = true
							end
						end
					end
				end
			end
		end
	end

	--[[
	local vfPlan = self.fallingPlanMap.verticalFallingPlan
	local testStr = ""
	for ia = 1 , 9 do

		local str = ""
		for ib = 1 , 9 do
			local f = "0"
			if vfPlan[tostring(ia) .. "_" .. tostring(ib)] then
				f = "1"
			end
			str = str .. "  " .. f
		end
		testStr = testStr .. str .. "\n"
	end
	printx( 1 , "[vfPlan] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n" .. testStr)
	--]]
	
	return isStillFalling
end