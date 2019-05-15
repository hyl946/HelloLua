AnimationUtil = {}

AnimationUtil.groupFadeOut = function(group, time)
	if group == nil or group.isDisposed then return end
	if group.setAlpha ~= nil and group.refCocosObj ~= nil and group.refCocosObj.setOpacity ~= nil then 
		group:runAction(CCFadeOut:create(time))
	end
	local childern = group:getChildrenList()
    if childern ~= nil and #childern > 0 then
        for i = 1, #childern do
            AnimationUtil.groupFadeOut(childern[i], time)
        end
    end
end

AnimationUtil.groupFadeIn = function(group, time)
	if group == nil or group.isDisposed then return end
	if group.setAlpha ~= nil and group.refCocosObj ~= nil and group.refCocosObj.setOpacity ~= nil then 
		group:runAction(CCFadeIn:create(time))
	end
	local childern = group:getChildrenList()
    if childern ~= nil and #childern > 0 then
        for i = 1, #childern do
            AnimationUtil.groupFadeIn(childern[i], time)
        end
    end
end

AnimationUtil.groupFadeAnimStop = function(group)
	if group == nil or group.isDisposed then return end
	if group.setAlpha ~= nil and group.refCocosObj ~= nil and group.refCocosObj.setOpacity ~= nil then 
		group:stopAllActions()
	end
	local childern = group:getChildrenList()
    if childern ~= nil and #childern > 0 then
        for i = 1, #childern do
            AnimationUtil.groupFadeAnimStop(childern[i])
        end
    end
end

AnimationUtil.getForeverRatate = function(rotateTimeByMS)
	local rotateTime = rotateTimeByMS or 800
	return CCRepeatForever:create(CCRotateBy:create(rotateTime / 1000, 360))
end

AnimationUtil.getStarRandomRotate = function(rotateMinTimeByMS, rotateMaxTimeByMS)
	local rotateMinTime = rotateMinTimeByMS or 500
	local rotateMaxTime = rotateMaxTimeByMS or 1500
	
	local function randomTime()
		return math.random(rotateMinTime, rotateMaxTime) / 1000
	end

	local ary = CCArray:create()
	ary:addObject(CCDelayTime:create(randomTime() * 1.5))
	ary:addObject(CCSpawn:createWithTwoActions(CCSequence:createWithTwoActions(CCFadeIn:create(randomTime() * 0.5),
																			   CCFadeOut:create(randomTime() * 0.5)),
											   CCRotateBy:create(randomTime() * 2, 180)))
	return CCRepeatForever:create(CCSequence:create(ary))
end

AnimationUtil.getForeverShake = function(firstShakeTimeByS, normalShakeTimeByS, lastShakeTimeByS, gapShakeTimeByS)
	local ary = CCArray:create()
	local firstShakeTime = firstShakeTimeByS or 0.17
	local normalShakeTime = normalShakeTimeByS or 0.1
	local lastShakeTime = lastShakeTimeByS or 0.07
	local gapShakeTime = gapShakeTimeByS or 0.5

	ary:addObject(CCRotateTo:create(firstShakeTime, 4.7))
	ary:addObject(CCRotateTo:create(normalShakeTime, -4.2))
	ary:addObject(CCRotateTo:create(normalShakeTime, 2))
	ary:addObject(CCRotateTo:create(normalShakeTime, -1.2))
	ary:addObject(CCRotateTo:create(lastShakeTime, 0))
	ary:addObject(CCDelayTime:create(gapShakeTime))
	return CCRepeatForever:create(CCSequence:create(ary))
end

AnimationUtil.getForeverVerticalFloat = function(floatTimeByMS, floatDistance)
	local floatTime = floatTimeByMS or 2100
	local floatDistance = floatDistance or 25

	floatTime = floatTime / 1000
	local floatDown = CCMoveBy:create(floatTime, ccp(0, -floatDistance))
  	local floatUp = CCMoveBy:create(floatTime, ccp(0, floatDistance))
	return CCRepeatForever:create(CCSequence:createWithTwoActions(floatDown, floatUp))
end

-----从一个圆弧上飞散出去的点动画 生成动画角区间 [-math.pi, math.pi], 以12点方向0度，顺时针为正，逆时针为负
--centerX, centerY 圆弧中心点
--dotRadius 圆弧半径
--flyX, flyY 飞的水平向距离和垂直向距离 距离全按照正值传递，根据angle随机结果改变正负
--flyTime 飞的时间
--withFadeOut 带淡出动画
--blankLeftAngle, blankRightAngle 在圆弧的 (blankLeftAngle, blankRightAngle)内不生成点
AnimationUtil.getCircleFlyOutParam = function(centerX, centerY, dotRadius, flyX, flyY, flyTime, withFadeOut, blankLeftAngle, blankRightAngle, endCallFunc)
	local angle = -math.pi * (0.5 - math.random())
	
	if blankLeftAngle ~= nil and blankRightAngle ~= nil then
		if angle > blankLeftAngle and angle < blankRightAngle then
			local halfAngle = (blankLeftAngle + blankRightAngle) /2
			if angle < halfAngle then
				angle = blankLeftAngle - (halfAngle - angle)
			else
				angle = blankRightAngle + (angle - halfAngle)
			end
		end
	end

	local dotPosX, dotPosY = centerX + dotRadius * math.sin(angle), centerY + dotRadius * math.cos(angle)
	local toX, toY
	if angle < 0 then toX = -toX 
	else toX = flyX end
	if angle >= -math.pi / 2 and angle < math.pi / 2 then toY = -flyY
	else toY = toY end

	local move = CCMoveBy:create(flyTime, ccp(toX, toY))
	local animAction
	if withFadeOut then
		local fadeOut = CCSequence:createWithTwoActions(CCDelayTime:create(flyTime / 3), CCFadeOut:create(flyTime * 2 / 3))
		local spawn = CCSpawn:createWithTwoActions(move, fadeOut)
		local endCallBack = CCCallFunc:create(function() if endCallFunc ~= nil then endCallFunc() end end)
		animAction = CCSequence:createWithTwoActions(spawn, endCallBack)
	else
		local endCallBack = CCCallFunc:create(function() if endCallFunc ~= nil then endCallFunc() end end)
		animAction = CCSequence:createWithTwoActions(move, endCallBack)
	end

	return dotPosX, dotPosY, animAction
end

-- --矩形向后飞去的动画参数
AnimationUtil.getRectFlyBackParam = function(centerX, centerY, rectWidth, rectHeight, flyX, flyY, flyTime, withFadeOut, endCallFunc)
	local dotPosX = centerX - rectWidth + math.random(rectWidth)
	local dotPosY = centerY - rectHeight + math.random(rectHeight)
	local move = CCMoveBy:create(flyTime, ccp(flyX, flyY))
	local animAction
	if withFadeOut then
		local fadeOut = CCSequence:createWithTwoActions(CCDelayTime:create(flyTime / 3), CCFadeOut:create(flyTime * 2 / 3))
		local spawn = CCSpawn:createWithTwoActions(move, fadeOut)
		local endCallBack = CCCallFunc:create(function() if endCallFunc ~= nil then endCallFunc() end end)
		animAction = CCSequence:createWithTwoActions(spawn, endCallBack)
	else
		local endCallBack = CCCallFunc:create(function() if endCallFunc ~= nil then endCallFunc() end end)
		animAction = CCSequence:createWithTwoActions(move, endCallBack)
	end
	return dotPosX, dotPosY, animAction
end

AnimationUtil.getForeverCall = function(gapTimeByS, func, gapAfterFlag)
	local ary = CCArray:create()
	if not gapAfterFlag then
		ary:addObject(CCDelayTime:create(gapTimeByS))
	end
	ary:addObject(CCCallFunc:create(function() func() end))
	if gapAfterFlag then
		ary:addObject(CCDelayTime:create(gapTimeByS))
	end
	return CCRepeatForever:create(CCSequence:create(ary))
end

AnimationUtil.getRectBlinkStarParam = function(leftBottomX, leftBottomY, rectWidth, rectHeight, rotateMinTime, rotateMaxTime, maxDelay, startCallFunc, endCallFunc, rAngle)
	local starPosX = leftBottomX + math.random(math.floor(rectWidth))
	local starPosY = leftBottomY + math.random(math.floor(rectHeight))
	local rotateTime = math.random() * (rotateMaxTime - rotateMinTime) + rotateMinTime
	rAngle = rAngle or 180

	local ary = CCArray:create()
	ary:addObject(CCDelayTime:create(math.random() * maxDelay))
	ary:addObject(CCCallFunc:create(function( ... )
		if startCallFunc ~= nil then startCallFunc() end
	end))
	local rAry = CCArray:create()
	rAry:addObject(CCFadeIn:create(rotateTime * 0.2))
	rAry:addObject(CCDelayTime:create(rotateTime * 0.6))
	rAry:addObject(CCFadeOut:create(rotateTime * 0.2))
	ary:addObject(CCSpawn:createWithTwoActions(CCSequence:create(rAry),
											   CCRotateBy:create(rotateTime * 2, rAngle)))
	ary:addObject(CCCallFunc:create(function( ... )
		if endCallFunc ~= nil then endCallFunc() end
	end))
	return starPosX, starPosY, CCSequence:create(ary)
end