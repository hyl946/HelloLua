LogicUtil = class()

function LogicUtil.decodeUrlName(name, maxLen)
	local decodeName
	if name ~= nil then 
		local nAry = string.split(name, ":")
		if nAry[1] == "ID" then
			decodeName = "消消乐玩家"
		else
			decodeName = HeDisplayUtil:urlDecode(name)
		end
	else
		decodeName = "消消乐玩家"
	end

	local nameCharSet = {}
	local count = 0
	for uchar in string.gfind(decodeName, "[%z\1-\127\194-\244][\128-\191]*") do
		if count >= maxLen then break end
		if uchar ~= '\n' and uchar ~= '\r' then
			nameCharSet[#nameCharSet + 1] = uchar
			count = count + 1
		end
	end

	decodeName = table.concat(nameCharSet)
	return decodeName
end

function LogicUtil.loadUserHeadIcon(uid, headIcon, headUrl )
	if headUrl == nil or type(headUrl) ~= "string" or #headUrl < 1 then
		headUrl = "ID:nil"
	end

	local function onImageLoadFinishCallback(image)
		if headIcon.isDisposed then 
			return 
		end
		image:ignoreAnchorPointForPosition(false)
		image:setAnchorPoint(ccp(0, 0))
		local size = headIcon:getContentSize()
		local scaleX = size.width / image:getContentSize().width * image:getScaleX()
		local scaleY = size.height / image:getContentSize().height * image:getScaleY()
		image:setScaleX(scaleX)
		image:setScaleY(scaleY)
		image:setPositionX(size.width/2)
		image:setPositionY(size.height/2)		
		headIcon:addChild(image)
	end
	local head = HeadImageLoader:createWithDesignatedFrame(uid, headUrl, nil, HeadFrameType.kNormal, HeadFrameStyle.k1)
	onImageLoadFinishCallback(head)
end

function LogicUtil.loadUserHeadIconWithFrame(uid, headIcon, headUrl, _profile)
	if headUrl == nil or type(headUrl) ~= "string" or #headUrl < 1 then
		headUrl = "ID:nil"
	end

	local function onImageLoadFinishCallback(image)
		if headIcon.isDisposed then 
			return 
		end
		image:ignoreAnchorPointForPosition(false)
		image:setAnchorPoint(ccp(0, 0))
		local size = headIcon:getContentSize()
		local scaleX = size.width / image:getContentSize().width * image:getScaleX()
		local scaleY = size.height / image:getContentSize().height * image:getScaleY()
		image:setScaleX(scaleX)
		image:setScaleY(scaleY)
		image:setPositionX(size.width/2)
		image:setPositionY(size.height/2)		
		headIcon:addChild(image)
	end

	local head = HeadImageLoader:createWithFrame(uid, headUrl, nil, HeadFrameStyle.k1, _profile)

	onImageLoadFinishCallback(head)
end


function LogicUtil.getPointString(point)
	return " ( " .. point.x .. " , " .. point.y .. " ) "
end

function LogicUtil.isNodeVisible(node)
	if node:isVisible() then
		if node:getParent() ~= nil then
			return LogicUtil.isNodeVisible(node:getParent())
		else
			return true
		end
	else
		return false
	end
end

function LogicUtil.setLayerAlpha(ui, alpha)
	if ui.setAlpha ~= nil and ui.refCocosObj ~= nil and ui.refCocosObj.setOpacity ~= nil then ui:setAlpha(alpha) end
	local childern = ui:getChildrenList()
    if childern ~= nil and #childern > 0 then
        for i = 1, #childern do
            LogicUtil.setLayerAlpha(childern[i], alpha)
        end
    end
end

function LogicUtil.getFullScreenUIPosXYScale( ... )
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
	local contentPosX = visibleOrigin.x + (visibleSize.width - 720 * scale) / 2
	local contentPosY = visibleOrigin.y + 1280 * scale
	return contentPosX, contentPosY, scale
end

function LogicUtil.getRandomIntAry(lower, upper, num)
	local ary = {}
	if upper <= lower then return nil end

	if num >= upper - lower + 1 then
		for i = lower, upper do
			ary[#ary + 1] = i
		end 
	else
		for i = 1, num do
			while true do
				local r = math.random(lower, upper)
				if table.indexOf(ary, r) == nil then
					ary[#ary + 1] = r
					break
				end
			end
		end
	end

	return ary
end


function LogicUtil.getRandomHitIndex(weightAry, weightTotal)
	local rInt = math.random(1, weightTotal)
	local rIndex = #weightAry
	for i = 1, #weightAry do
		if rInt <= weightAry[i] then rIndex = i break 
		else rInt = rInt - weightAry[i] end
	end
	
	return rIndex
end

-------------------------------------未调试
function LogicUtil.playIconFlyToEditBtnAnim(flyUI, toUI, callback)
    local function finalCb()
        flyUI.isPlayingFlyToEditAnim = false
        if callback then
            callback()
        end
    end
    local scene = HomeScene:sharedInstance()
    local function buttonOpenCb()
        if not scene.settingButtonUI or scene.settingButtonUI.isDisposed then 
            finalCb()
            return
        end
        local btn = toUI or scene.settingButtonUI.accountBtn
        if not btn or btn.isDisposed or not btn:getParent() or not flyUI:getParent() then 
            finalCb()
            return
        end

        local function actionCb()
            if scene.settingButtonUI and not scene.settingButtonUI.isDisposed then 
                scene.settingButtonUI:hideButtons()
            end
            finalCb()
            return
        end

        local pos = flyUI:getParent():convertToNodeSpace(btn:getParent():convertToWorldSpace(btn:getPosition()))
        local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 0), CCMoveTo:create(0.3, pos))
        local seq = CCSequence:createWithTwoActions(spawn, CCCallFunc:create(actionCb))
        flyUI:runAction(seq)
    end
    if flyUI.isPlayingFlyToEditAnim then return end
    flyUI.isPlayingFlyToEditAnim = true
    scene:showSettingButton(buttonOpenCb)
end