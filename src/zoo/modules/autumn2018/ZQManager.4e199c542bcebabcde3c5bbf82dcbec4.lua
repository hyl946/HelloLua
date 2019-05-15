
ZQManager = class()
local instance = nil
local TargetLimitConfig = {
	50, 90, 120	
}

function ZQManager.getInstance()
	if not instance then
		instance = ZQManager.new()
		instance:init()
	end
	return instance
end

function ZQManager:init()
	self.curScore = 0
end

function ZQManager:setTargets(targetsTable, targetLimits)
	if targetsTable and type(targetsTable) == "table" and #targetsTable > 0 then 
		local targetsNum = #targetsTable 
		self.targetsConfig = {}
		if type(targetLimits) ~= "table" then
			targetLimits = TargetLimitConfig
		end
		for i=1,targetsNum do
			self.targetsConfig[i] = {}
			self.targetsConfig[i].targetIndex = targetsTable[i]
			self.targetsConfig[i].num = targetLimits[i] or 120
		end
	else
		self.targetsConfig = nil
	end
end

function ZQManager:getTargetsConfig()
	return self.targetsConfig
end

function ZQManager:setHasFreeRevive(freeRevive)
	self.freeRevive = freeRevive
end

function ZQManager:getHasFreeRevive()
	return self.freeRevive
end

function ZQManager:setScoreBoard(scoreBoard)
	self.scoreBoard = scoreBoard
end

function ZQManager:setTargetLanterns(targetLanterns)
	self.targetLanterns = targetLanterns
end

function ZQManager:updateScore(score, withAni)
	if score < self.curScore then
		return
	end
	self.curScore = score
	local function updateScoreBoard(showBoard)
		if self.scoreBoard then 
			self.scoreBoard:updateScore(score, withAni)
			if showBoard then
				self.scoreBoard:setVisible(true) 
			end
		end
	end
	if self.targetsConfig then
		if self.targetLanterns then
			self.targetLanterns:updateScore(score, withAni, updateScoreBoard)
		else
			updateScoreBoard(false)
		end
	else
		updateScoreBoard(true)
	end
end

function ZQManager:getFlyEndPos(specifyNodeSpace)
	local flyEndPos 
	if self.targetsConfig and self.targetLanterns then
		flyEndPos = self.targetLanterns:getFlyEndPos(specifyNodeSpace)
	elseif self.scoreBoard then 
		flyEndPos = self.scoreBoard:getFlyEndPos(specifyNodeSpace)
	end
	return flyEndPos
end

function ZQManager:getTargetPieceIndexes()
	local ids = ""
	if self.targetsConfig then 
		for i,v in ipairs(self.targetsConfig) do
			if self.curScore >= v.num then
				if ids == "" then
					ids = ids .. v.targetIndex
				else
					ids = ids .. "," .. v.targetIndex
				end
			end
		end
	end
	return ids
end

function ZQManager:reset()
	self.targetsConfig = nil
	self.scoreBoard = nil
	self.targetLanterns = nil
	self.curScore = 0
end