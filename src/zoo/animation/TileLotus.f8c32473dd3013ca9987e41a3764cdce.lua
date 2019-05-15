TileLotus = class(CocosObject)

function TileLotus:create(currLotusLevel , animationType , layer , noAnimation)
    local node = TileLotus.new(CCNode:create())
    node:init(currLotusLevel , animationType , layer , noAnimation)
    return node
end

function TileLotus:createByAnimation(currLotusLevel , animationType , layer , noAnimation)
	local resName = ""
	local animeName = ""
	local animeLength = 10

	local spr = nil
	local spr_frames = nil
	local spr_animate = nil

	

	if layer == "bottom" then
		--构建荷叶底层
		if currLotusLevel == 1 then
			if noAnimation then
				resName = "state_1_in_0010"
				spr = Sprite:createWithSpriteFrameName(resName)
			else
				resName = "state_1_".. tostring(animationType) .. "_0001"
				animeName = "state_1_" .. tostring(animationType) .. "_%04d"
				animeLength = 10

				spr = Sprite:createWithSpriteFrameName(resName)
				spr_frames = SpriteUtil:buildFrames(animeName, 1, animeLength)
				spr_animate = SpriteUtil:buildAnimate(spr_frames, 1/24)
				spr:play(spr_animate, 0, 1, nil, false)
			end
		else
			resName = "state_1_in_0010"
			spr = Sprite:createWithSpriteFrameName(resName)
		end
	elseif layer == "top" then
		--构建荷叶顶层
		if currLotusLevel == 2 then
			resName = "state_2_" .. tostring(animationType) .. "_0001"
			animeName = "state_2_" .. tostring(animationType) .. "_%04d"
			if animationType == "in" then 
				animeLength = 16
			elseif animationType == "out" then
				animeLength = 13
			end
		elseif currLotusLevel == 3 then
			resName = "state_3_" .. tostring(animationType) .. "_0001"
			animeName = "state_3_" .. tostring(animationType) .. "_%04d"
			if animationType == "in" then 
				animeLength = 22
			elseif animationType == "out" then
				animeLength = 17
			end
		end
		
		if currLotusLevel > 1 then
			if noAnimation then
				resName = "state_" .. tostring(currLotusLevel) .. "_" .. tostring(animationType) .. "_00" .. tostring(animeLength)
				spr = Sprite:createWithSpriteFrameName(resName)
			else
				spr = Sprite:createWithSpriteFrameName(resName)
				local spr_frames = SpriteUtil:buildFrames(animeName, 1, animeLength)
				local spr_animate = SpriteUtil:buildAnimate(spr_frames, 1/24)
				spr:play(spr_animate, 0, 1, nil, false)
			end
		end
	end

	return spr
end

function TileLotus:playAnimation(currLotusLevel , animationType , layer , noAnimation)
	if self.body and not self.body.isDisposed then
		self.body:removeFromParentAndCleanup(true)
		self.body = nil
	end

	local spr = TileLotus:createByAnimation(currLotusLevel , animationType , layer , noAnimation)

	if spr then
		self:addChild(spr)
		self.body = spr
	end
	
end

function TileLotus:init(currLotusLevel , animationType , layer , noAnimation)

	local spr = TileLotus:createByAnimation(currLotusLevel , animationType , layer , noAnimation)
	if spr then
		self:addChild(spr)
		self.body = spr
	end
end