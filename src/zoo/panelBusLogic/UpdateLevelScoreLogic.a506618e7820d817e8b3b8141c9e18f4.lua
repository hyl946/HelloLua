
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月13日 13:30:30
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- UpdateLevelScoreLogic
---------------------------------------------------

assert(not UpdateLevelScoreLogic)
UpdateLevelScoreLogic = class()

function UpdateLevelScoreLogic:ctor()
end

function UpdateLevelScoreLogic:init(levelId, levelType, score, star, pawnNum, ...)
	assert(type(levelId)	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(#{...} == 0)

	self.levelId	= levelId
	self.levelType  = levelType
	self.score	= score
	self.star	= star
	-- self.pawnNum = pawnNum
end

function UpdateLevelScoreLogic:start(...)
	assert(#{...} == 0)


	local userManager	= UserManager:getInstance()

	-- Add Cur User Score To Old User Score
	local curUserScore	= userManager:getUserScore(self.levelId)

	if curUserScore then
		-- If Not Large Than Already Score, Return
		-- 如果新的星级更大，那么分数也要覆盖
		if curUserScore.score > self.score and curUserScore.star >= self.star then

			-- Update Old Score
			local oldUserScore 	= ScoreRef.new()
			oldUserScore.levelId	= curUserScore.levelId
			oldUserScore.score	= curUserScore.score
			oldUserScore.star	= curUserScore.star
			oldUserScore.uid	= curUserScore.uid
			oldUserScore.updateTime	= curUserScore.updateTime

			UserManager:getInstance():removeOldUserScore(oldUserScore.levelId)
			UserManager:getInstance():addOldUserScore(oldUserScore)
			return
		end

		userManager:removeUserScore(self.levelId)
		userManager:removeOldUserScore(self.levelId)
		userManager:addOldUserScore(curUserScore)
	end

	-- Add New User Score
	local newUserScore = ScoreRef.new()
	he_log_warning("ScoreRef.uid is ??")
	newUserScore.levelId	= self.levelId
	newUserScore.score	= self.score
	newUserScore.star	= self.star
	newUserScore.uid = userManager.user.uid
	newUserScore.updateTime = Localhost:time()
	-- newUserScore.pawnNum = self.pawnNum or 0
	he_log_warning("ScoreRef.updateTime ??")

	userManager:addUserScore(newUserScore)

	------------------
	-- Check Star Change
	-- ------------------
	
	local deltaStar = false

	if curUserScore then
		deltaStar = newUserScore.star - curUserScore.star
	else
		deltaStar = newUserScore.star
	end

	-- Check If Normal Level Star
	if self.levelType == GameLevelType.kMainLevel then
		local curNormalStar = UserManager:getInstance().user:getStar()
		local newNormalStar = curNormalStar + deltaStar
		UserManager:getInstance().user:setStar(newNormalStar)

		if _G.isLocalDevelopMode then printx(0, "UpdateLevelScoreLogic: Change Normal Star Number To: " .. newNormalStar) end
	elseif self.levelType == GameLevelType.kHiddenLevel then
		-- Is Hidden Level
		local curHideStar = UserManager:getInstance().user:getHideStar()
		local newHideStar = curHideStar + deltaStar
		UserManager:getInstance().user:setHideStar(newHideStar)

		if _G.isLocalDevelopMode then printx(0, "UpdateLevelScoreLogic: Change Hide Star Number To: " .. newHideStar) end
	end
end

function UpdateLevelScoreLogic:create(levelId, levelType, score, star, pawnNum, ...)
	assert(type(levelId)	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(#{...} == 0)

	local newUpdateLevelScore = UpdateLevelScoreLogic.new()
	newUpdateLevelScore:init(levelId, levelType, score, star, pawnNum)
	return newUpdateLevelScore
end
