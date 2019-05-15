require "zoo.gamePlay.gravitySkinLogics.GravitySkinLogic_Water"

GravitySkinViewLogic = class{}

function GravitySkinViewLogic:create( gameBoardView )
	local logic = GravitySkinViewLogic.new()
	logic:init( gameBoardView )

	return logic
end

function GravitySkinViewLogic:init( gameBoardView )
	self.gameBoardView = gameBoardView
	self.gameBoardLogic = self.gameBoardView.gameBoardLogic

	self.needBuildGravitySkinMap = {}
	self.lastGravitySkinMap = {}
	self.logics = {}

	
	-- self.viewData
end

function GravitySkinViewLogic:initByBoardMap( boardmap )
	
	for r , v1 in ipairs( boardmap ) do

		self.lastGravitySkinMap[r] = {}

		for c , v2 in ipairs( v1 ) do
			local board = boardmap[r][c]
			local info = {}
			info.gravitySkin = board:getGravitySkinType()
			info.gravity = board:getGravity()

			if info.gravitySkin == BoardGravitySkinType.kWater then
				local waterLogic = self:getLogic( BoardGravitySkinType.kWater )
				if waterLogic then
					waterLogic:updateHorizontalLineInfo( r , c )
				end
			end

			self.lastGravitySkinMap[r][c] = info
		end
	end
end


function GravitySkinViewLogic:createLogic( skinType )
	--这个方法返回一个特定的Logic，用来处理一种特定的重力皮肤的视图更新逻辑
	--每种类型的重力皮肤，都应该有一个与之对应的Logic

	if skinType == BoardGravitySkinType.kWater then
		return GravitySkinLogic_Water:create( self )
	elseif skinType == BoardGravitySkinType.kNone then
		return nil
	end
end

function GravitySkinViewLogic:getLogic( skinType )
	--这个方法返回一个特定的Logic，用来处理一种特定的重力皮肤的视图更新逻辑
	--每种类型的重力皮肤，都应该有一个与之对应的Logic

	if not self.logics[ skinType ] then
		self.logics[ skinType ] = self:createLogic( skinType )
	end

	return self.logics[ skinType ]
end

function GravitySkinViewLogic:buildMultipleGravitySkinBySkinType( skinType )
	--有些重力皮肤不是单个格子独立更新的，而是一旦更新，所有的同类型格子都要重绘（比如有复杂的拼接效果）
	--这样的逻辑都放到 buildMultipleGravitySkinBySkinType 里处理

end

function GravitySkinViewLogic:buildGravitySkinAt( r , c )
	--重新创建单个格子的新的重力方向特效，在格子的重力方向发生变化，或者重力皮肤类型发生变化后会调用

	local itemMap = self.gameBoardLogic:getItemMap()
	local boardMap = self.gameBoardLogic:getBoardMap()
	local baseMap = self.gameBoardView.baseMap

	local item = itemMap[r][c]
	local board = boardMap[r][c]
	local itemView = baseMap[r][c]
	local itemSprite = itemView.itemSprite

	--todo 这块逻辑只是个示意，以后要拆到单独的logic里去处理，基于现有数据，目标数据，重新拼接，并处理动画过渡  gravitySkinViewLogic
	local skinType = board:getGravitySkinType()

	if board:getGravitySkinType() > 0 then
		
		local logic = self:getLogic( skinType )
		
		if logic then
			logic:buildSkinAt( r , c , itemView )
		end

	else

		local info = self.lastGravitySkinMap[r][c]
		local lastSkinType = info.gravitySkin

		if lastSkinType == BoardGravitySkinType.kWater then
			local logic = self:getLogic( lastSkinType )
			logic:clearSkinAt( r , c , itemView )	
		end
	end

	self:deleteNeedBuildGravitySkinAt( r , c ) 

	itemView.isNeedUpdate = true
end


function GravitySkinViewLogic:buildAllGravitySkin()
	self:clearNeedBuildGravitySkin()
	-- printx( 1 , "GravitySkinViewLogic:buildGravitySkin ~~~~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	

	local boardMap = self.gameBoardLogic:getBoardMap()
	for i=1, #boardMap do
		for j=1,#boardMap[i] do
			self:buildGravitySkinAt( i , j )
		end
	end
end

function GravitySkinViewLogic:clearNeedBuildGravitySkin()
	self.needBuildGravitySkinMap = {}
end

function GravitySkinViewLogic:setNeedBuildGravitySkinAt( value , r , c )
	if self.needBuildGravitySkinMap then
		self.needBuildGravitySkinMap[ tostring(r) .. "_" .. tostring(c) ] = { update = value , r = r , c = c }
	end
end

function GravitySkinViewLogic:deleteNeedBuildGravitySkinAt( r , c )
	if self.needBuildGravitySkinMap then
		self.needBuildGravitySkinMap[ tostring(r) .. "_" .. tostring(c) ] = nil 
	end
end

function GravitySkinViewLogic:getNeedBuildGravitySkinAt( r , c )
	if self.needBuildGravitySkinMap then
		return self.needBuildGravitySkinMap[ tostring(r) .. "_" .. tostring(c) ]
	end
end

function GravitySkinViewLogic:getNeedBuildGravitySkinMap()
	return self.needBuildGravitySkinMap
end