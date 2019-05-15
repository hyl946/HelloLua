---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-29 14:07:03
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-05 14:48:15
---------------------------------------------------------------------------------------
TileOlympicBlocker = class(CocosObject)

function TileOlympicBlocker:ctor()
end

function TileOlympicBlocker:create(level)
	local node = TileOlympicBlocker.new(CCNode:create())
	node:init(level)
	return node
end

function TileOlympicBlocker:init(level)

	self.decAnimation = ArmatureNode:create("autumn_2018_bomb/bomb")
	self:addChild(self.decAnimation)

	--self:playDecAnimation(1 , "levelupto")
	----[[
	if level and level > 0 then
		self:playDecAnimation(level , "wait")
	else
		self:playDecAnimation(0 , "levelto")
	end
	--]]
end

function TileOlympicBlocker:getPosOffset(level)
	if level == 3 then
		return 0, -4
	elseif level == 2 then
		return 0, -4
	elseif level == 1 then
		return 1, -5
	elseif level == 0 then
		return 1, -5
	end
	return 0, 0
end

function TileOlympicBlocker:playBoomAnimation()
	self.decAnimation:play("boom" , 1)
	self.decAnimation:update(0.001)
end

function TileOlympicBlocker:playDecAnimation(curLevel, animeType)

	--printx( 1 , "   TileOlympicBlocker:playDecAnimation   " , curLevel, animeType)
	if not animeType then animeType = "levelto" end

	local animation = nil
	local playTimes = 1
	local animeName = animeType .. tostring(curLevel)
	local needPlay = true

	if animeType == "wait" then
		if curLevel == 1 then
			animeName = "wait1"
			needPlay = true
			playTimes = 0
		elseif curLevel == 2 then
			animeName = "wait2"
			needPlay = true
			playTimes = 0
		elseif curLevel == 3 then
			animeName = "levelto2"
			needPlay = false
			playTimes = 0
		end
	elseif animeType == "levelto" then
		if curLevel == 1 then
			return
		elseif curLevel == 2 then
			animeName = "levelto1"
			needPlay = true
			playTimes = 1
			
		elseif curLevel == 3 then
			animeName = "levelto2"
			needPlay = true
			playTimes = 1
		end
	end

	local function onAnimationComplete()
		self:playDecAnimation(curLevel - 1 , "wait")
		if onAnimFinished then onAnimFinished() end
	end

	--animation:playByIndex(0, 1)

	self.decAnimation:play(animeName , playTimes)
	self.decAnimation:update(0.001)
	self.decAnimation:stop()

	if playTimes > 0 and animeType == "levelto" then
		self.decAnimation:ad(ArmatureEvents.COMPLETE, onAnimationComplete)
	end

	if needPlay then
		self.decAnimation:play(animeName , playTimes)
	else
		self.decAnimation:stop()
	end
	--self.decAnimation = animation
	--self:addChild(animation)-
end
