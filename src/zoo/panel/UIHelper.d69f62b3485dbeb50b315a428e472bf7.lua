
local UIHelper = {}

function UIHelper:safeCreateSpriteByFrameName( frameName, default)
	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName) then
		return Sprite:createWithSpriteFrameName(frameName)
	else
		return Sprite:createEmpty()
	end
end

function UIHelper:safeCreateSpriteByFrameNameOrNil( frameName)
	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName) then
		return Sprite:createWithSpriteFrameName(frameName)
	end
end

function UIHelper:centerAnchor( node )
    node:setAnchorPoint(ccp(0.5, 0.5))
    local sx, sy = node:getScaleX(), node:getScaleY()
    UIHelper:move(node, sx * node:getContentSize().width/2, -sy * node:getContentSize().height/2)
end

function UIHelper:move( ui, dx, dy )
    if not ui then return end
    if ui.isDisposed then return end

    ui:setPositionX(ui:getPositionX() + (dx or 0))
    ui:setPositionY(ui:getPositionY() + (dy or 0))
end


local armatures = {}
function UIHelper:loadArmature(resourceSrc, skeletonName, textureName)
    if not armatures[resourceSrc] then
        armatures[resourceSrc] = 0
    end
    armatures[resourceSrc] = armatures[resourceSrc] + 1
    if armatures[resourceSrc] == 1 then
        FrameLoader:loadArmature( resourceSrc, skeletonName, textureName )
    end
end

function UIHelper:unloadArmature(resourceSrc, cleanup)
    if armatures[resourceSrc] then
        armatures[resourceSrc] = armatures[resourceSrc] - 1
        if armatures[resourceSrc] <= 0 then
            FrameLoader:unloadArmature( resourceSrc, cleanup )
        end
    end
end

function UIHelper:createArmature2( resourceSrc, name )
    UIHelper:loadArmature(resourceSrc)

    local animNode = UIHelper:createArmature(name)

    local oldDispose = animNode.dispose

    function animNode:dispose( ... )
        oldDispose(self, ...)
        UIHelper:unloadArmature(resourceSrc, true)
    end

    return animNode
end

function UIHelper:createArmature3( resourceSrc, skeletonName, textureName, name )
    UIHelper:loadArmature(resourceSrc, skeletonName, textureName)
    local animNode = UIHelper:createArmature(name)
    local oldDispose = animNode.dispose
    function animNode:dispose( ... )
        oldDispose(self, ...)
        UIHelper:unloadArmature(resourceSrc, true)
    end
    return animNode
end

local objectPool = {}

function UIHelper:_poolPush( poolId, objecct )
    if objectPool[poolId] then
        table.insert(objectPool[poolId], objecct)
    else
        objecct._poolObj = false
        objecct:_dispose()
    end
end

function UIHelper:clearPool( poolId )
    if objectPool[poolId] then
        for _, v in ipairs(objectPool[poolId]) do 
            v._poolObj = false
            v:_dispose()
        end
        objectPool[poolId] = nil
    end
end

function UIHelper:initPool( poolId )
    if not objectPool[poolId] then
        objectPool[poolId] = {}
    end
end

function UIHelper:_poolPop( poolId, objectKey )
    -- body
    if objectPool[poolId] then 
        local index
        for i, v in ipairs(objectPool[poolId]) do 
            if v._objectKey == objectKey then
                index = i
                break
            end
        end

        if index then
            local obj = objectPool[poolId][index]
            table.remove(objectPool[poolId], index)
            return obj
        end
    end
end

function UIHelper:poolCreateArmature3( poolId, resourceSrc, skeletonName, textureName, name )


    local objectKey = resourceSrc .. '#' .. skeletonName .. '#' .. textureName .. '#' .. name

    local obj = UIHelper:_poolPop(poolId, objectKey)
    if obj then
        return obj
    end

    local obj = UIHelper:createArmature3( resourceSrc, skeletonName, textureName, name)
    obj._objectKey = objectKey
    obj._poolObj = true
    obj._dispose = obj.dispose
    obj.dispose = function ( self )
        if self.onPushToPool then
            self.onPushToPool()
        end
        self:rma()
        UIHelper:_poolPush(poolId, self)
    end
    return obj
end


function UIHelper:createArmature( name )
    local anim = ArmatureNode:create(name)
    anim:unscheduleUpdate()
    local scheduleNode = CocosObject:create()
    anim:addChild(scheduleNode)
    scheduleNode:scheduleUpdateWithPriority(function( dt )
        if anim and (not anim.isDisposed) then
            anim.refCocosObj:advanceTime(math.min(1/30,dt))
        end
    end,0)

    function scheduleNode:dispose( ... )
       self:unscheduleUpdate()
       CocosObject.dispose(self, ...)
    end

    local playByIndex = anim.playByIndex
    local function wrapPlayByIndex( ctx, ... )
        playByIndex(ctx, ...)
        if ctx and (not ctx.isDisposed) then
            ctx:update(0.01)
        end
    end
    anim.playByIndex = wrapPlayByIndex
    
    return anim
end


function UIHelper:setAnimTitle( animNode , str)
    local txt = BitmapText:create(str, "fnt/share.fnt", -1, kCCTextAlignmentLeft)
    txt:setAnchorPoint(ccp(0.5, 0.5))
    txt:setScale(1)
    UIHelper:addChildInAnim(animNode, 'tile', txt.refCocosObj)
    txt:dispose()
end

function UIHelper:addChildInAnim( animNode, nodeName, child )
    -- body
    local container = UIHelper:getCon(animNode, nodeName)
    container:addChild(child)
    local size = container:getContentSize()
    -- container:setOpacity(0)
    child:setPosition(ccp(size.width/2, size.height/2))
end

function UIHelper:getCon(armature, name)

    local itemSlot = armature.refCocosObj:getCCSlot(name)
    if not itemSlot then
        return 
    end
    return tolua.cast(itemSlot:getCCDisplay(), "CCSprite")
    
end

function UIHelper:autoProperty(ui)
    local function _create(ui)
        if ui and ui.list then
            for k, v in pairs(ui.list) do
                if v.name and type(v.name) == 'string' and string.len(v.name) > 0 then
                    ui[tostring(v.name)] = v
                    -- print(ui.name, v.name)
                end
                _create(v)
            end
        end
    end
    _create(ui)
end



local function copyList( list )
    local ret = {}
    for _, v in ipairs(list) do
        table.insert(ret, v)
    end
    return ret
end

local function replaceLayer2LayerColor( layer,autoReplace )

    if #(layer:getChildrenList()) <= 0 then
        -- layer:setCascadeOpacityEnabled(true)
        return layer
    end

    if layer.class == Layer then

        local pos = layer:getPosition()
        local sx, sy = layer:getScaleX(), layer:getScaleY()
        local rotation = layer:getRotation()

        local new_layer = LayerColor:create()
        new_layer:setPosition(ccp(pos.x, pos.y))
        new_layer:setScaleX(sx)
        new_layer:setScaleY(sy)
        new_layer:setRotation(rotation)
        -- new_layer:setCascadeOpacityEnabled(true)

        new_layer.name = layer.name
        new_layer.symbolName = layer.symbolName

        local childList = copyList(layer:getChildrenList())
        for _, v in ipairs(childList) do
            v:removeFromParentAndCleanup(false)
            new_layer:addChild(replaceLayer2LayerColor(v))
        end

        if autoReplace then
            local parent = layer:getParent()
            if parent then
                local order = layer:getZOrder()
                layer:removeFromParentAndCleanup(true)
                parent:addChildAt(new_layer,order)
            end
        end

        layer:dispose()

        return new_layer
    else
        local childList = copyList(layer:getChildrenList())
        for _, v in ipairs(childList) do
            v:removeFromParentAndCleanup(false)
            layer:addChild(replaceLayer2LayerColor(v))
        end
        return layer
    end
end





function UIHelper:replaceLayer2LayerColor( layer,autoReplace )
    return replaceLayer2LayerColor(layer,autoReplace)
end

function UIHelper:setCascadeOpacityEnabled( nodeTree, modifyRGB )
    if modifyRGB == nil then
        modifyRGB = true
    end

    if nodeTree and (not nodeTree.isDisposed) then
        nodeTree:setCascadeOpacityEnabled(true)
        if modifyRGB and nodeTree.setOpacityModifyRGB then
            nodeTree:setOpacityModifyRGB(true)
        end
    end

    local childlist = nodeTree:getChildrenList()
    for _, v in ipairs(childlist) do
        UIHelper:setCascadeOpacityEnabled(v, modifyRGB)
    end

    return nodeTree
end



local builderCache = {}

local jsonCache = {}

function UIHelper:loadJson( jsonPathname )

    -- body
    if not jsonCache[jsonPathname] then
        builderCache[jsonPathname] = InterfaceBuilder:createWithContentsOfFile(jsonPathname)
        jsonCache[jsonPathname] = 0
    end

    jsonCache[jsonPathname] = jsonCache[jsonPathname] + 1
end

function UIHelper:unloadJson( jsonPathname )
    if not jsonCache[jsonPathname] then 
        return 
    end

    jsonCache[jsonPathname] = jsonCache[jsonPathname] - 1

    if jsonCache[jsonPathname] <= 0 then
        InterfaceBuilder:unloadAsset(jsonPathname)

        if __WIN32 then
            InterfaceBuilder:removeLoadedJson(jsonPathname)
        end

        jsonCache[jsonPathname] = nil
        builderCache[jsonPathname] = nil
    end
end


function UIHelper:setRightText( bitmapText, txt ,fnt, ignoreW, ignoreH)
    if (not bitmapText.UIHelper_init_flag) then
        if fnt then
            bitmapText:changeFntFile(fnt)
        elseif bitmapText.name == 'title' then
            bitmapText:changeFntFile('activity/SummerVacation2018/fnt/summer18_leveltitle.fnt')
        end
        bitmapText.UIHelper_init_flag = true
    end
    bitmapText:setText(txt)
    bitmapText:setAnchorPointWhileStayOriginalPosition(ccp(0, 1))

    local sh = bitmapText.height / bitmapText:getContentSize().height
    local sw = bitmapText.width / bitmapText:getContentSize().width

    bitmapText:setScale(math.min(ignoreW and 1 or sw, ignoreH and 1 or sh))

    if not bitmapText.ori_pos_x then
        bitmapText.ori_pos_x = bitmapText:getPositionX()
    end

    if not bitmapText.ori_pos_y then
        bitmapText.ori_pos_y = bitmapText:getPositionY()
    end

    bitmapText:setPositionX( bitmapText.ori_pos_x +  (bitmapText.width  - bitmapText:getContentSize().width * bitmapText:getScaleX()))
    bitmapText:setPositionY( bitmapText.ori_pos_y -  (bitmapText.height  - bitmapText:getContentSize().height * bitmapText:getScaleY())/2)

    return bitmapText
end

function UIHelper:getBuilder( jsonPathname )
    return builderCache[jsonPathname]
end

function UIHelper:createSpriteFrame( json, spriteFrameByName )
    UIHelper:loadJson(json)
    local builder = UIHelper:getBuilder(json)
    if builder then
        if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameByName) then
            local sp = Sprite:createWithSpriteFrameName(spriteFrameByName)
            if sp then
                local oldDispose = sp.dispose
                function sp:dispose( ... )
                    oldDispose(self, ...)
                    UIHelper:unloadJson(json)
                end
                return sp
            end
        end
    end
    UIHelper:unloadJson(json)         
end

function UIHelper:createUI(json, symbol)
    if json and symbol then
        UIHelper:loadJson(json)
        local builder = UIHelper:getBuilder(json)
        if builder then
            local ui = builder:buildGroup(symbol, nil, true)
            if ui then
                local oldDispose = ui.dispose
                function ui:dispose( ... )
                    oldDispose(self, ...)
                    UIHelper:unloadJson(json)
                end
                return ui
            end
        end
        UIHelper:unloadJson(json)            
    end
end



function UIHelper:setText( bitmapText, txt )
    bitmapText:setText(txt)
    bitmapText:setScale(bitmapText.height / bitmapText:getContentSize().height)
    return bitmapText
end


function UIHelper:setCenterText( bitmapText, txt ,fnt, ignoreW, ignoreH)
    if (not bitmapText.UIHelper_init_flag) then
        if fnt then
            bitmapText:changeFntFile(fnt)
        elseif bitmapText.name == 'title' then
            bitmapText:changeFntFile('activity/SummerVacation2018/fnt/summer18_leveltitle.fnt')
        end
        bitmapText.UIHelper_init_flag = true
    end

    bitmapText:setText(txt)
    bitmapText:setAnchorPointWhileStayOriginalPosition(ccp(0, 1))

    local sh = bitmapText.height / bitmapText:getContentSize().height
    local sw = bitmapText.width / bitmapText:getContentSize().width

    bitmapText:setScale(math.min(ignoreW and 1 or sw, ignoreH and 1 or sh))

    if not bitmapText.ori_pos_x then
        bitmapText.ori_pos_x = bitmapText:getPositionX()
    end

    if not bitmapText.ori_pos_y then
        bitmapText.ori_pos_y = bitmapText:getPositionY()
    end

    bitmapText:setPositionX( bitmapText.ori_pos_x +  (bitmapText.width  - bitmapText:getContentSize().width * bitmapText:getScaleX())/2)
    bitmapText:setPositionY( bitmapText.ori_pos_y -  (bitmapText.height  - bitmapText:getContentSize().height * bitmapText:getScaleY())/2)

    -- if not bitmapText.xxxxx then


    --     local layer = LayerColor:create()
    --     layer:setOpacity(100)
    --     layer:setColor((ccc3(255,0,0)))
    --     layer:setContentSize(CCSizeMake( bitmapText.width , bitmapText.height ))
    --     layer:ignoreAnchorPointForPosition(false)
    --     layer:setAnchorPoint(ccp(0, 1))

    --     local parent = bitmapText:getParent()
    --     parent:addChild(layer)
    --     layer:setPositionX(bitmapText.ori_pos_x)
    --     layer:setPositionY(bitmapText.ori_pos_y)

    --     bitmapText.xxxxx = 1
    -- end

    return bitmapText
end

function UIHelper:buildGroupBtn( uiNode, buttonText, buttonHandler )
    if not uiNode then return end
    if uiNode.isDisposed then return end
    if uiNode.__ui_helper_btn then return end
    local btn = GroupButtonBase:create(uiNode)
    btn:setString(buttonText or '知道了')
    btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(buttonHandler or function ( ... ) end))
    uiNode.__ui_helper_btn = btn
end

function UIHelper:setLeftText( bitmapText, txt ,fnt, ignoreW, ignoreH)
    if (not bitmapText.UIHelper_init_flag) then
        if fnt then
            bitmapText:changeFntFile(fnt)
        elseif bitmapText.name == 'title' then
            bitmapText:changeFntFile('activity/SummerVacation2018/fnt/summer18_leveltitle.fnt')
        end
        bitmapText.UIHelper_init_flag = true
    end
    bitmapText:setText(txt)
    bitmapText:setAnchorPointWhileStayOriginalPosition(ccp(0, 1))

    local sh = bitmapText.height / bitmapText:getContentSize().height
    local sw = bitmapText.width / bitmapText:getContentSize().width

    bitmapText:setScale(math.min(ignoreW and 1 or sw, ignoreH and 1 or sh))

    if not bitmapText.ori_pos_x then
        bitmapText.ori_pos_x = bitmapText:getPositionX()
    end

    if not bitmapText.ori_pos_y then
        bitmapText.ori_pos_y = bitmapText:getPositionY()
    end

    bitmapText:setPositionX( bitmapText.ori_pos_x)
    bitmapText:setPositionY( bitmapText.ori_pos_y -  (bitmapText.height  - bitmapText:getContentSize().height * bitmapText:getScaleY())/2)

    return bitmapText

end

function UIHelper:loadUserHeadIcon(headIcon, profile, profileUIDIsXxlId, frameId)

    local headUrl = profile.headUrl or '0'
    local uid = profile.uid or '12345'

    if profileUIDIsXxlId and profile then
        if tostring(profile.uid) == tostring(UserManager:getInstance():getInviteCode()) then
            uid = UserManager:getInstance():getUID()
            profile = nil
        end
    end


    if headUrl ~= nil and type(headUrl) == "string" and #headUrl > 0 then
        local function onImageLoadFinishCallback(image)
            if headIcon.isDisposed then 
                return 
            end

            if headIcon.__ui_helper_headimage then
                headIcon.__ui_helper_headimage:removeFromParentAndCleanup(true)
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

            headIcon.__ui_helper_headimage = image
        end

        if not frameId then
            onImageLoadFinishCallback(HeadImageLoader:createWithFrame(uid, headUrl, nil, nil, profile))
        else
            onImageLoadFinishCallback(HeadImageLoader:createWithFrameId(uid, headUrl, nil, frameId))
        end
    end
end

function UIHelper:setUserName( label, name )

    name = name or ''
    if name == '' then
        name = '消消乐玩家'
    end

    local labelTxt = LogicUtil.decodeUrlName(name, 1024)
    labelTxt = TextUtil:ensureTextWidth(labelTxt, label:getFontSize(), label:getDimensions() )
    label:setString(labelTxt)
end


local function splitNodePath(nodePath)
    for i = #nodePath, 1, -1 do
        if string.sub(nodePath, i, i) == '/' then
            return string.sub(nodePath, 1, i - 1), string.sub(nodePath, i + 1, #nodePath)
        end
    end
    return '.', nodePath
end

function UIHelper:moveToTop(container, nodeNames )
    local cacheOldIndex = {}
    table.walk(nodeNames, function ( nodePath, index )
        local parentNodePath, nodeName = splitNodePath(nodePath)
        local parentNode = container:getChildByPath(parentNodePath)
        if not parentNode then
            return
        end
        local node = parentNode:getChildByName(nodeName)
        if not node then
            return
        end
        cacheOldIndex[nodePath] = parentNode:getChildIndex(node) 
        node:removeFromParentAndCleanup(false)
        local pos = node:getPosition()
        pos = parentNode:convertToWorldSpace(ccp(pos.x, pos.y))
        pos = container:convertToNodeSpace(ccp(pos.x, pos.y))
        node:setPosition(ccp(pos.x, pos.y))
        node.name = parentNodePath .. '####' .. nodeName
        container:addChild(node)
    end)

    return function ()
        table.reverse_walk(nodeNames, function ( nodePath, index )
            if container.isDisposed then return end
            local parentNodePath, nodeName = splitNodePath(nodePath)
            if not cacheOldIndex[nodePath] then return end
            local parentNode = container:getChildByPath(parentNodePath)
            local node = container:getChildByName(parentNodePath .. '####' .. nodeName)
            node:removeFromParentAndCleanup(false)
            local pos = node:getPosition()
            pos = container:convertToWorldSpace(ccp(pos.x, pos.y))
            pos = parentNode:convertToNodeSpace(ccp(pos.x, pos.y))
            node:setPosition(ccp(pos.x, pos.y))
            node.name = nodeName
            parentNode:addChildAt(node, cacheOldIndex[nodePath])

        end)
    end
end

function UIHelper:removeChildByPath( parent, childPath )
    if not parent then return end
    if parent.isDisposed then return end
    local child = parent:getChildByPath(childPath)
    if child and (not child.isDisposed) then
        child:removeFromParentAndCleanup(true)
    end
end

function UIHelper:copyLayoutParams( to, from )
    local position = from:getPosition()
    to:setPosition(ccp(position.x, position.y))

    local anchorPoint = from:getAnchorPoint()
    to:setAnchorPoint(ccp(anchorPoint.x, anchorPoint.y))

    local rotation = from:getRotation()
    to:setRotation(rotation)

    local skewY = from:getSkewY()
    to:setSkewY(skewY)

    local skewX = from:getSkewX()
    to:setSkewX(skewX)
end

function UIHelper:renderNode2Sprite( node )
    
    local parent
    local childIndex
    local oriTransform 
    parent = node:getParent()    
    if parent then
        childIndex = parent:getChildIndex(node)
        node:removeFromParentAndCleanup(false)
    end


    oriTransform = {
        posX = node:getPositionX(), 
        posY = node:getPositionY(),
        scaleX = node:getScaleX(),
        scaleY = node:getScaleY(),
        skewX = node:getSkewX(), 
        skewY = node:getSkewY(), 
    }

    node:setPosition(ccp(0, 0))
    node:setSkewX(0)
    node:setSkewY(0)
    node:setScaleX(1)
    node:setScaleY(1)

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeOriginPos(node, ccp(0, 0))


    local size = node:getGroupBounds().size

    local apx = node:getPositionX()
    local apy = node:getPositionY()
    local anchorPoint = ccp(
        apx / size.width,
        1 - apy / size.height
    )



    local layer = CCRenderTexture:create(size.width, size.height)
    -- layer:setPosition(ccp(size.width / 2, size.height / 2))
    layer:begin()
    node:visit()
    layer:endToLua()
    layer:saveToFile(HeResPathUtils:getResCachePath() .. "/share_image1.jpg")


    node:setPositionX(oriTransform.posX)
    node:setPositionY(oriTransform.posY)
    node:setSkewX(oriTransform.skewX)
    node:setSkewY(oriTransform.skewY)
    node:setScaleX(oriTransform.scaleX)
    node:setScaleY(oriTransform.scaleY)

    if parent then
        parent:addChildAt(node, childIndex)
    end


    layer:getSprite():setAnchorPoint(anchorPoint)

    local sp = CocosObject.new(layer)

    --写到这儿 先不管skew了，只考虑rotation

    if node.frameName then
        --未知bug，先这样修一下，其实没算明白
        sp:setPosition(node:convertToWorldSpace(ccp(apx, size.height - apy)))
    else
        sp:setPosition(node:convertToWorldSpace(ccp(0, 0)))
    end

    local p1 = node:convertToWorldSpace(ccp(1, 0))
    local p0 = node:convertToWorldSpace(ccp(0, 0))
    local dx = p1.x - p0.x
    local dy = p1.y - p0.y
    local sx = math.sqrt(dx * dx + dy * dy)

    local angle = math.atan2(dy, dx) * -180/math.pi

    local p1 = node:convertToWorldSpace(ccp(0, 1))
    local p0 = node:convertToWorldSpace(ccp(0, 0))
    local dx = p1.x - p0.x
    local dy = p1.y - p0.y
    local sy = math.sqrt(dx * dx + dy * dy)

    sp:setScaleX(sx)
    sp:setScaleY(sy)

    -- printx(61, sp:getPositionX(), sp:getPositionY(), 'sp')
    sp:setRotation(angle)


    function sp:getSprite( ... )
        return layer:getSprite()
    end

    return sp

end


function UIHelper:convert2NodeSpace(node, n )
    return node:convertToNodeSpace(ccp(0, n)).y - node:convertToNodeSpace(ccp(0, 0)).y
end

function UIHelper:convert2WorldSpace(node, n )
    return node:convertToWorldSpace(ccp(0, n)).y - node:convertToWorldSpace(ccp(0, 0)).y
end

function UIHelper:bezier( startPos, endPos, sideScale, duration, callback )
    local bezierConfig = ccBezierConfig:new()

    local dx = endPos.x - startPos.x
    local dy = endPos.y - startPos.y

    sideScale = sideScale or 0.23
    dy = dy * sideScale
    dx = dx * sideScale

    bezierConfig.controlPoint_1 = ccp(startPos.x/2 + endPos.x/2 + dy, startPos.y/2 + endPos.y/2 - dx)
    bezierConfig.controlPoint_2 = ccp(startPos.x/2 + endPos.x/2 + dy, startPos.y/2 + endPos.y/2 - dx)
    bezierConfig.endPosition = endPos
    local bezierAction_1 = CCSequence:createWithTwoActions(CCBezierTo:create(duration or 13/24, bezierConfig), CCCallFunc:create(function ( ... )
        if callback then callback() end
    end))
    return bezierAction_1
end

function UIHelper:changeParentWhileStayOriPos(child, newParent)
    child:runAction(CCCallFunc:create(function ()
        local oldParent = child:getParent()
        local pos = child:getPosition()
        local worldPos = oldParent:convertToWorldSpace(ccp(pos.x, pos.y))
        pos = newParent:convertToNodeSpace(ccp(worldPos.x, worldPos.y))
        child:removeFromParentAndCleanup(false)
        newParent:addChild(child)
        child:setPosition(ccp(pos.x, pos.y))
    end))
end

function UIHelper:addBitmapTextByIcon(icon, str, fntFile, strColor, strScale, posAdjust)
    local posAdjustX = posAdjust and posAdjust.x or 0
    local posAdjustY = posAdjust and posAdjust.y or 0
    local parentUI = icon:getParent()
    local iconPos = icon:getPosition()
    local iconSize = icon:getGroupBounds().size
    local bitmapText = BitmapText:create(str, fntFile)
    if strScale then bitmapText:setScale(strScale) end
    bitmapText:setAnchorPoint(ccp(0, 0.5))
    if strColor then bitmapText:setColor(hex2ccc3(strColor)) end
    parentUI:addChild(bitmapText)
    bitmapText:setPosition(ccp(iconPos.x + iconSize.width + posAdjustX, iconPos.y - iconSize.height/2 + posAdjustY))

    return bitmapText
end


function UIHelper:buildProgress( progress, fgName)
    -- body
    local pgFG = progress:getChildByName(fgName or 'fg')
    local pgFGIndex = progress:getChildIndex(pgFG)
    local pgFG2 = Sprite:createWithSpriteFrameName(pgFG.frameName)
    pgFG2:setAnchorPoint(ccp(0, 1))
    pgFG:removeFromParentAndCleanup(false)
    local pgFGPos = ccp(pgFG:getPositionX(), pgFG:getPositionY())
    local clipingnode_1 = ClippingNode.new(CCClippingNode:create(pgFG2.refCocosObj))
    clipingnode_1:addChild(pgFG)
    clipingnode_1:setAlphaThreshold(0.1)
    progress:addChildAt(clipingnode_1, pgFGIndex)
    pgFG:setPosition(ccp(0, 0))
    clipingnode_1:setPosition(pgFGPos)
    pgFG2:dispose()


    local originLength = pgFG:getContentSize().width
    local originPosX = pgFG:getPositionX()

    local funcName = 'setProgress'

    while progress[funcName] do
        funcName = funcName .. '1'
    end

    progress[funcName] = function ( _, n, offset)
        if progress.isDisposed then return end
        n = math.clamp(n, 0, 1)
        pgFG:setPositionX(originPosX - originLength * (1-n) + (offset or 0))
    end

    return funcName
end

function UIHelper:buildProgressSP9( progress, fgName)
    -- body
    local pgFG = progress:getChildByName(fgName or 'fg')
    local pgFGIndex = progress:getChildIndex(pgFG)
    local frameName = pgFG.frameName
    pgFG.name = ''

    local h = pgFG:getContentSize().height
    local w = pgFG:getContentSize().width

    local pos = pgFG:getPosition()
    pos = ccp(pos.x, pos.y)

    local sp9 = Scale9Sprite:createWithSpriteFrameName(frameName, CCRectMake(h, 0, w - 2*h, h))
    progress:addChildAt(sp9, pgFGIndex)
    sp9:setAnchorPoint(ccp(0, 1))

    sp9:setPosition(pos)
    sp9.name = 'fg3'

    pgFG:setVisible(false)

    local funcName = 'setProgress'
    while progress[funcName] do
        funcName = funcName .. '1'
    end


    progress[funcName] = function ( _, n, offset)
        if progress.isDisposed then return end
        n = math.clamp(n, 0, 1)
        sp9:setPreferredWidth(n * w)
    end

    return funcName
end

function UIHelper:spawn( actionList )
    -- body
    local array = CCArray:create()
    for _, v in ipairs(actionList) do
        array:addObject(v)
    end
    return CCSpawn:create(array)
end

function UIHelper:sequence( actionList )
    -- body
    local array = CCArray:create()
    for _, v in ipairs(actionList) do
        array:addObject(v)
    end
    return CCSequence:create(array)
end


local function getClassName(obj)
    for k, v in pairs(_G) do
        if v == obj.class then
            return k
        end
    end;
end


local function makeLayerSupportOpacity( layer )

    if #(layer:getChildrenList()) <= 0 then
        return layer
    end

    if not layer.refCocosObj.setOpacity then
        function layer.refCocosObj:setOpacity( o )
            local children = self:getChildren() or {}
            local count = self:getChildrenCount()
            for i = 0, count - 1 do
                local v = children:objectAtIndex(i)
                if v.setOpacity then
                    if __IOS then -- 解决iOS上的诡异崩溃问题
                        pcall(function() v:setOpacity(o) end)
                    else
                        v:setOpacity(o)
                    end
                end
            end
        end
    end

    local childList = copyList(layer:getChildrenList())
    for _, v in ipairs(childList) do
        v:removeFromParentAndCleanup(false)
        layer:addChild(makeLayerSupportOpacity(v))
    end
    return layer
end

function UIHelper:makeLayerSupportOpacity( layer )
    return makeLayerSupportOpacity(layer)
end

local function setNodeOpacityCascade(refCocosObj, o)
    if not refCocosObj then return end
    if refCocosObj.setOpacity then
        if __IOS then -- 解决iOS上的诡异崩溃问题
            pcall(function() refCocosObj:setOpacity(o) end)
        else
            refCocosObj:setOpacity(o)
        end
    end
    if not refCocosObj.getChildrenCount then return end

    local count = refCocosObj:getChildrenCount()
    if count > 0 then
        local children = refCocosObj:getChildren()
        for i = 0, count - 1 do
            local v = children:objectAtIndex(i)
            setNodeOpacityCascade(v, o)
        end
    end
end

function UIHelper:makeNodeOpacityCascade( layer )
    layer.setOpacity = function(ctx, o)
        setNodeOpacityCascade(ctx.refCocosObj, o)
    end
    return layer
end

function UIHelper:createMaskInUI( ui )
    local maskLayer = LayerColor:create()
    maskLayer.name = 'maskLayer'
    maskLayer:setColor(ccc3(0, 0, 0))
    maskLayer:setOpacity(200)
    maskLayer:ignoreAnchorPointForPosition(false)
    maskLayer:setAnchorPoint(ccp(0, 1))
    ui:addChildAt( maskLayer, 0)
    local vSize = Director:sharedDirector():ori_getVisibleSize()
    local vo = Director:sharedDirector():ori_getVisibleOrigin()
    local maskWidth = UIHelper:convert2NodeSpace(ui, vSize.width)
    local maskHeight = UIHelper:convert2NodeSpace(ui, vSize.height)
    maskLayer:changeWidthAndHeight(maskWidth, maskHeight)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeOriginPos(maskLayer, vo)    
end


function UIHelper:skipButton(skipText, onTouch)
    local layer = LayerColor:create()
    layer:setOpacity(0)
    layer:changeWidthAndHeight(200, 80)
    layer:ignoreAnchorPointForPosition(false)
    -- layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
    layer:setTouchEnabled(true, 0, true)
    layer:ad(DisplayEvents.kTouchTap, onTouch)
    layer:setOpacity(0)
    layer:setAnchorPoint(ccp(0, 0))
    layer:setColor(ccc3(136, 255, 136))


    local text = TextField:create(skipText, nil, 32)
    text:setPosition(ccp(50, 25))
    text:setColor(ccc3(136, 255, 136))
    text:setOpacity(0)
    text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0), CCFadeIn:create(0)))
    text:setAnchorPoint(ccp(0, 0))
    layer:addChild(text)

    return layer
end

function UIHelper:getPanelRoot(node)
    if not node then return nil end
    local parent = node:getParent()
    if not parent then return nil end
    
    if parent:is(BasePanel) then
        return parent
    else
        return UIHelper:getPanelRoot(parent)
    end
end

return UIHelper