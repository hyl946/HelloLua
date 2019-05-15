LevelModeProcessor = class()

function LevelModeProcessor:create( mainlogic , modeInfo )
	local levelModeProcessor = LevelModeProcessor.new()
	levelModeProcessor:init( mainlogic , modeInfo )
	return levelModeProcessor
end

function LevelModeProcessor:init( mainlogic , modeInfo )
	self.mainlogic = mainlogic
	self.modeInfo = modeInfo
end

function LevelModeProcessor:doProcessorOnSwapFinish()
	-- printx( 1 , "LevelModeProcessor:doProcessorOnSwapFinish")
	-- if true then return end
	
	if not self.modeInfo then
		return
	end

	local gameItemMap = self.mainlogic.gameItemMap
	local gameBoardmap = self.mainlogic.boardmap
	local playContext = GamePlayContext:getInstance()

	if self.modeInfo.changeGlobalGravityBySwap then

		local lastSwapInfo = playContext.lastSwapInfo
		
		if lastSwapInfo then

			local tarGravity = nil

			if lastSwapInfo.direction == DirectionType.kUp then
				tarGravity = BoardGravityDirection.kUp
			elseif lastSwapInfo.direction == DirectionType.kDown then
				tarGravity = BoardGravityDirection.kDown
			elseif lastSwapInfo.direction == DirectionType.kLeft then
				tarGravity = BoardGravityDirection.kLeft
			elseif lastSwapInfo.direction == DirectionType.kRight then
				tarGravity = BoardGravityDirection.kRight
			end

			if tarGravity then
				for r = 1, #gameBoardmap do
					for c = 1, #gameBoardmap[r] do
						local board = gameBoardmap[r][c]
						if board and board.isUsed then
							board:setGravity( tarGravity )
						end
					end
				end
			end
		end
		
	end
end

function LevelModeProcessor:doProcessorOnEnterWaitingState()

	if not self.modeInfo then
		return
	end

	local gameItemMap = self.mainlogic.gameItemMap
	local gameBoardmap = self.mainlogic.boardmap
	local playContext = GamePlayContext:getInstance()

	if self.modeInfo.changeGlobalGravityBySwap then

		local lastSwapInfo = playContext.lastSwapInfo
		
		if lastSwapInfo then

			local tarGravity = nil

			if lastSwapInfo.direction == DirectionType.kUp then
				tarGravity = BoardGravityDirection.kUp
			elseif lastSwapInfo.direction == DirectionType.kDown then
				tarGravity = BoardGravityDirection.kDown
			elseif lastSwapInfo.direction == DirectionType.kLeft then
				tarGravity = BoardGravityDirection.kLeft
			else
				tarGravity = BoardGravityDirection.kRight
			end

			for r = 1, #gameBoardmap do
				for c = 1, #gameBoardmap[r] do
					local board = gameBoardmap[r][c]
					if board and board.isUsed then
						board:setGravity( tarGravity )
					end
				end
			end
		end
		
	end

end