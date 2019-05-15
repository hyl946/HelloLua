require "hecore.display.CocosObject"
ResUtils = class()

function ResUtils:ctor( ... )
	-- body
end

function ResUtils:getResFromUrls(urls , callback)
	local function loadThirdPartyResCallback(eventName, data)
		if eventName == ResCallbackEvent.onError then
			he_log_info("load third party res error, errorCode: " .. data.errorCode .. ", item: " .. data.item)
		elseif eventName == ResCallbackEvent.onSuccess then
			callback(data)
		end
	end

	ResourceLoader.loadThirdPartyRes(urls, loadThirdPartyResCallback)
end

function ResUtils:getDropRuleItemId(itemID)
	if type(itemID) == 'number' then
		return itemID
	else
		local ids = string.split(itemID, '_')
		return tonumber(ids[1]), ids[2]
	end
end

function ResUtils:getAnimationActions(sprite, animationData, framerate)
	if framerate == nil then framerate = 24 end
	local actions = CCArray:create()
	local rotation = sprite:getRotation()
	local x, y = sprite:getPositionX(), sprite:getPositionY()

	if animationData[1].startFrame ~= 0 then
		sprite:setVisible(false)
		actions:addObject(CCDelayTime:create(animationData[1].startFrame / framerate))
		actions:addObject(CCShow:create())
	end

	if animationData[1].x and animationData[1].y then
		sprite:setPositionX(animationData[1].x + x)
		sprite:setPositionY(y - animationData[1].y)
	end
	if animationData[1].scaleX and animationData[1].scaleY then
		sprite:setScaleX(animationData[1].scaleX)
		sprite:setScaleY(animationData[1].scaleY)
	end
	if animationData[1].opacity then
		sprite:setOpacity(animationData[1].opacity)
	end
	if animationData[1].rotation then
		sprite:setRotation(rotation + animationData[1].rotation)
	end

	if #animationData == 1 then
		actions:addObject(CCDelayTime:create(animationData[1].duration / framerate))
	end

	for i=2,#animationData do
		local d = animationData[i - 1].duration / framerate
		local t = {}
		if animationData[i].x and animationData[i].y then
			table.insert(t,CCMoveTo:create(d,ccp(animationData[i].x + x, y - animationData[i].y)))
		end
		if animationData[i].scaleX and animationData[i].scaleY then
			table.insert(t,CCScaleTo:create(d,animationData[i].scaleX,animationData[i].scaleY))
		end
		if animationData[i].opacity then
			table.insert(t,CCFadeTo:create(d,animationData[i].opacity))
		end
		if animationData[i].rotation then
			if animationData[i].rotateBy then
				table.insert(t,CCRotateBy:create(d, animationData[i].rotation))
			else
				table.insert(t,CCRotateTo:create(d, rotation + animationData[i].rotation))
			end
		end

		if #t == 1 then
			actions:addObject(t[1])
		else
			local spawnActions = CCArray:create()
			for k,v in pairs(t) do
				spawnActions:addObject(v)
			end
			actions:addObject(CCSpawn:create(spawnActions))
		end
	end

	return CCSequence:create(actions)
end