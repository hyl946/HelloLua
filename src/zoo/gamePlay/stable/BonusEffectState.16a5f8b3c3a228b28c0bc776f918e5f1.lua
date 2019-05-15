---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-01-18 17:54:19
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-01-16 16:31:33
---------------------------------------------------------------------------------------
BonusEffectState = class(BaseStableState)

function BonusEffectState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function BonusEffectState:create(context)
	local v = BonusEffectState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BonusEffectState:onEnter()
	BaseStableState.onEnter(self)
	-- 计算实际使用棋盘大小
	local boardMap = self.mainLogic:getBoardMap();
	self.boardUseRect = self.mainLogic.boardView:getUsedBoardMapRect(boardMap)
	self.bonusEffectCount = 0
	self.totalBonusEffectCount = 99
	self.effectDuringCount = 0
	self.effectLifeCount = 0
	self.centerPos = nil

	self.isPlayingBonusAnime = true

	local function onAnimationFinished()
		self.isPlayingBonusAnime = false
	end

	if _G.dev_kxxxl then
		GamePlayMusicPlayer:playEffect(GameMusicType.kXXLBonusTime)
	else
		GamePlayMusicPlayer:playEffect(GameMusicType.kBonusTime)
	end
	
	local PlayUIDelegate = self.mainLogic.PlayUIDelegate
	if PlayUIDelegate and PlayUIDelegate.topEffectLayer and not PlayUIDelegate.topEffectLayer.isDisposed then
		PlayUIDelegate.topEffectLayer:removeChildren(true)

		local isJamMode = GameBoardLogic:getCurrentLogic().gameMode:is(JamSperadMode)
		if not isJamMode then
			PlayUIDelegate.topEffectLayer:addChild(CommonEffect:buildBonusEffect(onAnimationFinished))
		else
			local jamNode = PlayUIDelegate.gameBoardView.showPanel[ItemSpriteType.kJamSperad]
			if jamNode then
				local size = jamNode:getGroupBounds().size
				jamNode:setContentSize(size)
				jamNode:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))

				local time = 0.4

				local runFadeOut
				runFadeOut = function ( parent )
					for _,c in ipairs(parent.list) do
						runFadeOut(c)
					end
					if parent.refCocosObj.setOpacity then
						parent:runAction(CCFadeOut:create(time))
					end
				end

				pcall(runFadeOut, jamNode)
				jamNode:runAction(CCScaleTo:create(time, 0.78))

				PlayUIDelegate.topEffectLayer:addChild(CommonEffect:buildBonusEffect(onAnimationFinished))
			end
		end
	else
		onAnimationFinished()
	end
end

function BonusEffectState:onExit()
	BaseStableState.onExit(self)

	self.isPlayingBonusAnime = false
	self.bonusEffectCount = 0
	self.totalBonusEffectCount = 99
	self.effectDuringCount = 0
	self.effectLifeCount = 0
	self.boardUseRect = nil
	self.centerPos = nil
end

function BonusEffectState:playEffectAtPos(r, c)
	local board = self.mainLogic.boardmap[r] and self.mainLogic.boardmap[r][c]
	if board and board.isUsed then
		local itemView = self.mainLogic.boardView.baseMap[r][c]
		itemView:playBonusTimeEffcet()
	end
end

function BonusEffectState:playEffects(pos1_r, pos1_c, centerPos, excludePosFlags)
	excludePosFlags = excludePosFlags or {}
	-- 计算相对中心对称的位置
	for dr = 1, -1, -2 do
		for dc = 1, -1, -2 do
			local pr = centerPos.r + (pos1_r - centerPos.r) * dr
			local pc = centerPos.c + (pos1_c - centerPos.c) * dc
			if not excludePosFlags[pr.."_"..pc] then
				excludePosFlags[pr.."_"..pc] = true
				self:playEffectAtPos(pr, pc)
			end
		end
	end
end

function BonusEffectState:playBonusEffect()
	if self.effectLifeCount > 0 then
		self.effectLifeCount = self.effectLifeCount - 1
	end
	-- 释放特效间隔时间
	if self.effectDuringCount > 0 then 
		self.effectDuringCount = self.effectDuringCount - 1
		return true 
	end
	-- 全部释放完毕
	if self.bonusEffectCount >= self.totalBonusEffectCount then  
		if self.effectLifeCount > 0 then 
			return true
		else 
			return false 
		end
	end

	if self.bonusEffectCount == 0 then
		local c = self.boardUseRect.origin.x + (self.boardUseRect.size.width - 1) / 2.0
		local r = self.boardUseRect.origin.y + (self.boardUseRect.size.height - 1) / 2.0
		self.centerPos = {r = r, c = c}
		local pos1_r = math.floor(r)
		local pos1_c = math.ceil(c)

		local maxC = self.boardUseRect.origin.x + self.boardUseRect.size.width
		local maxR = self.boardUseRect.origin.y + self.boardUseRect.size.height
		self.totalBonusEffectCount = maxC - pos1_c + maxR - pos1_r

		self:playEffects(pos1_r, pos1_c, self.centerPos)
	else
		local pos1_r = math.floor(self.centerPos.r)
		local pos1_c = math.ceil(self.centerPos.c)
		local excludePosFlags = {}
		for i = 0, self.bonusEffectCount do
			local pr = pos1_r + i
			local pc = pos1_c + self.bonusEffectCount - i
			self:playEffects(pr, pc, self.centerPos, excludePosFlags)
		end
	end

	self.effectDuringCount = 2
	self.effectLifeCount = 14
	self.bonusEffectCount = self.bonusEffectCount + 1

	return true
end

function BonusEffectState:update(dt)
	if self.isUpdateStopped then return end
	if self.isPlayingBonusAnime then return end
	if self:playBonusEffect() then return end

	self.nextState = self:getNextState()
	self.context:onEnter()
end

function BonusEffectState:checkTransition()
	return self.nextState
end

function BonusEffectState:getClassName( ... )
	return "BonusEffectState"
end

function BonusEffectState:getNextState( ... )
	return self.context.bonusAutoBombState
end