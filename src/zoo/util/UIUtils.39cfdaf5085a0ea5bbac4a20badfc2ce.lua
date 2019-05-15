UIUtils = {}

----  偷懒的函数们 -----------------------------------------------------
-- 把icon塞到ph里面去
function UIUtils:fitIconToPh(parent, ph, icon, size)
    ph:setVisible(false)
    local width, height = ph:getContentSize().width*ph:getScaleX(), ph:getContentSize().height*ph:getScaleY()
    local iconWidth, iconHeight
    if size then
        iconWidth, iconHeight = size.width, size.height
    else
        iconWidth, iconHeight = icon:getGroupBounds().size.width, icon:getGroupBounds().size.height
    end
    local scaleX, scaleY = width/iconWidth, height/iconHeight
    icon:setRotation(ph:getRotation())
    icon:setScale(math.min(scaleX, scaleY))
    parent:addChildAt(icon, ph:getZOrder())
    icon:setPositionX(ph:getPositionX())
    icon:setPositionY(ph:getPositionY())
end

-- 把icon设置到指定的大小
function UIUtils:fitIconToSize(icon, width, height)
    local iconWidth, iconHeight = icon:getGroupBounds().size.width, icon:getGroupBounds().size.height
    local scaleX, scaleY = width/iconWidth, height/iconHeight
    icon:setScale(math.min(scaleX, scaleY))
end

-- 创建一个新的ccp对象
function UIUtils:getPosition(ui)
    return ccp(ui:getPositionX(), ui:getPositionY())
end

-- 偷懒的函数
function UIUtils:getWorldPos(ui)
    if not ui or not ui:getParent() then
        return ccp(0, 0)
    end
    return ui:getParent():convertToWorldSpace(UIUtils:getPosition(ui))
end

-- 偷懒的函数
function UIUtils:getPhWidthHeight(ph)
    local size = ph:getContentSize()
    return ph:getScaleX()*size.width, ph:getScaleY()*size.height
end

-- 省掉你写getChildByName的活
function UIUtils:autoProperty(ui)
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

-- 全屏面板适配
function UIUtils:adjustUI( ui, y, ignoreY, manualAdjustY, totalHeight, ignoreCloseBtn)
    y = y or 100
    local visibleSize =  Director:sharedDirector():getVisibleSize()
    local visibleRatio = visibleSize.height / visibleSize.width
    local ratio = 1280.0/720.0
    local mode
    local Mode = {
        FULL_HEIGHT = 1,
        FULL_WIDTH = 2,
    }
    if visibleRatio >= ratio then 
        mode = Mode.FULL_WIDTH
    else
        mode = Mode.FULL_HEIGHT
    end
    local offsetX = 0
    local scale
    ui:setScale(1)
    if mode == Mode.FULL_HEIGHT then
        scale = visibleSize.height / 1280
        offsetX = (720 - 1280/visibleRatio)/2
    else
        scale = visibleSize.width / 720

        local totalExtraHeight = 200
        if totalHeight then
            totalExtraHeight = totalHeight - 1280
        end

        if not ignoreY then
            y = y - (visibleSize.height/scale - 1280) * y / totalExtraHeight
        end

        if visibleRatio > ratio and manualAdjustY then
            y = y + manualAdjustY
        end

    end
    ui:setScale(scale)
    local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeCenterPos(ui, ccp(visibleSize.width/2, -visibleSize.height/2))
    local posX = ui:getPositionX()
    layoutUtils.setNodeLeftTopPos(ui, ccp(visibleSize.width/2, y*scale))
    ui:setPositionX(posX)

    if not ignoreCloseBtn then

        local closeBtn = ui:getChildByName('closeBtn')
        if closeBtn then
            closeBtn:setPositionX(closeBtn:getPositionX() - offsetX)
        end
    end
end


function UIUtils:positionNode( holder, icon, isUniformScale)
    if (not holder) or holder.isDisposed then return end
    if (not icon) or icon.isDisposed then return end
    if holder.____icon then
        holder.____icon:removeFromParentAndCleanup(true)
        holder.____icon = nil
    end
    holder.____icon = icon
    local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
    local parent = holder:getParent()
    if (not parent) or parent.isDisposed then return end
    local iconIndex = parent:getChildIndex(holder)
    parent:addChildAt(icon, iconIndex)
    local size = holder:getContentSize()
    local sx, sy = holder:getScaleX(), holder:getScaleY()
    local realSize = {
        width = sx * size.width,
        height = sy * size.height,
    }
    layoutUtils.scaleNodeToSize(icon, realSize, parent, isUniformScale)
    layoutUtils.verticalCenterAlignNodes({icon}, holder, parent)
    layoutUtils.horizontalCenterAlignNodes({icon}, holder, parent)
    holder:setVisible(false)
end

--令ui可点击，无论它是不是layer
function UIUtils:setTouchHandler( ui, handler, hitTestFunc ,cdTime)

    if (not ui) or ui.isDisposed then
        return
    end

    if ui._UIUtils_TouchLayer then
        ui._UIUtils_TouchLayer:removeFromParentAndCleanup(true)
        ui._UIUtils_TouchLayer = nil
    end

    if handler then

        local layer = Layer:create()

        layer:setTouchEnabled(true, 0, true, function ( worldPos )
            if ui.isDisposed then return end
            if not hitTestFunc then
                return ui:hitTestPoint(worldPos, true)
            else
                return hitTestFunc(worldPos)
            end
        end, true, true)
        layer:ad(DisplayEvents.kTouchTap, preventContinuousClick(handler,cdTime))
        
        ui.__isGroupButtonBase__ = true
        ui:addChild(layer)
        ui._UIUtils_TouchLayer = layer
    end
end

-----------------------------------------------------------------------------------

function UIUtils:wrapNodeFunc( node, funcName, beforeFunc, afterFunc)
    if not node then return end
    if node.isDisposed then return end
    node['__old__' .. funcName] = node[funcName]
    node[funcName] = function ( ... )
        if not node then return end
        if node.isDisposed then return end
        if beforeFunc then beforeFunc(...) end
        node['__old__' .. funcName](...)
        if afterFunc then afterFunc(...) end
    end
end