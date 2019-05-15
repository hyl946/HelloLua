Blocker206Logic = class()

local transList = nil
function Blocker206Logic:init(mainLogic)
	transList = nil
	local boardmap = mainLogic.boardmap
	local gameItemMap = mainLogic.gameItemMap
 	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do 
			local board = boardmap[r][c]
			local item = gameItemMap[r][c]
			local group = item.lockLevel
			if board.transType > 0 and item:hasBlocker206() and (not board.isTransLock) then
				local trans = {}
				board.isTransLock = true
				--printx(1 , "Blocker206Logic:init  insert" , r,c )
				table.insert(trans, board)

				local bFind = true
				while (bFind) do
					local to_r, to_c = board.transLink.x, board.transLink.y
					if (to_r == r and to_c == c) then
						bFind = false
					else 
						board = boardmap[to_r][to_c]
						board.isTransLock = true
						--printx(1 , "Blocker206Logic:init  insert" , to_r,to_c )
						table.insert(trans, board)
					end
				end

				if not transList then transList = {} end
				table.insert(transList, trans)
			end
		end
	end
end

function Blocker206Logic:cancelEffectByLock(mainLogic)
	--printx(1 , "Blocker206Logic:cancelEffectByLock  1 " )
	if transList then 
		--printx(1 , "Blocker206Logic:cancelEffectByLock  2 " )
		local function check(trans)
			for k, v in pairs(trans) do
				local item = mainLogic.gameItemMap[v.y][v.x] 
				if item:hasBlocker206() then 
					--printx(1 , "Blocker206Logic:cancelEffectByLock  !!!!!!!!!" ,  v.y , v.x , "item.lockLevel" , item.lockLevel )
					return false
				end
			end

			return true
		end

		for _, v in pairs(transList) do
			--printx(1 , "Blocker206Logic:cancelEffectByLock  3 " ,_, v)
			if check(v) then 
				--printx(1 , "Blocker206Logic:cancelEffectByLock  4 " )
				for _k, v1 in pairs(v) do 
					--printx(1 , "Blocker206Logic:cancelEffectByLock  5 " )
					v1.isTransLock = false
				end
			end
		end
	end
end