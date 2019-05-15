local freeItemMap = {}
local targetCount = 0


QixiUtil = class()

function QixiUtil:getFreeItemData()
    if _G.isLocalDevelopMode then printx(0, '&*^*^&%^$$%$^*&*( v QixiUtil:getFreeItemData') end

    local function onSuccess(event)
        if _G.isLocalDevelopMode then printx(0, 'QixiUtil:getFreeItemData ON SUCCESS') end
        if _G.isLocalDevelopMode then printx(0, table.tostring(event.data)) end
        for k, v in pairs(event.data.freeItemMap) do 
            freeItemMap[v.key] = {itemId = v.key, num = v.value}
        end
        targetCount = tonumber(event.data.targetCount)

    end 

    local function onFail(event)
        if _G.isLocalDevelopMode then printx(0, 'QixiUtil:getFreeItemData on fail') end
    end
    local http = CnValentineInfoHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load()
end

function QixiUtil:hasCompeleted()
    local beginTime = os.time({year = 2014, month = 8, day = 1, hour = 0, minute = 0, second = 0})
    local endTime = os.time({year = 2014, month = 8, day = 7, hour = 23, minute = 59, second = 59})
    local curTime = Localhost:time() / 1000
    local isInTime = (curTime <= endTime) and (curTime >= beginTime)

    return targetCount >= 521 and isInTime
end

function QixiUtil:getRemainingFreeItem(itemId)
    local item = freeItemMap[itemId]
    if item then return item.num end
    return 0
end

function QixiUtil:consumeFreeItem(itemId)
    local item = freeItemMap[itemId]
    if item then item.num = item.num - 1 end
end

function QixiUtil:unConsumeFreeItem(itemId)
    local item = freeItemMap[itemId]
    if item then item.num = item.num + 1 end
end

function QixiUtil:playMagpieAnimation(startPos, endPos, itemPos)
    -- once per day
    local date = os.date('*t', Localhost:time() / 1000)
    local dateKey = string.format('%d.%d.%d.qixi_playAnim', date.year, date.month, date.day)
    local hasKey = CCUserDefault:sharedUserDefault():getBoolForKey(dateKey)
    if hasKey then return end
    CCUserDefault:sharedUserDefault():setBoolForKey(dateKey, true)

    FrameLoader:loadArmature("skeleton/qixi_magpie_animation")
    local magpie = ArmatureNode:create('chongzi_xique_modify_0')

    local vo = Director:sharedDirector():getVisibleOrigin()
    local vs = Director:sharedDirector():getVisibleSize()
    local lc = LayerColor:create()
    lc:setColor(ccc3(0,0,0))
    lc:setOpacity(125)
    lc:setContentSize(CCSizeMake(vs.width, vs.height))
    lc:setPositionX(vo.x)
    lc:setPositionY(vo.y)
    lc:setAnchorPoint(ccp(0, 0))
    lc:ignoreAnchorPointForPosition(false)
    lc:setTouchEnabled(true, 0, true)

    magpie:setPosition(startPos)
    magpie:playByIndex(0)
    magpie:setAnimationScale(1.25) 

    local function createShining(scene, pos, delayT)
        for i = 1, 8 do
            local win_star_shine = Sprite:createWithSpriteFrameName("win_star_shine0000")
            local x = math.random(pos.x - 20, pos.x + 70)
            local y = math.random(pos.y - 30, pos.y + 15)
            local fadeArray = CCArray:create()
            fadeArray:addObject(CCDelayTime:create(delayT + 0.3 + math.random() * 0.5))
            fadeArray:addObject(CCFadeIn:create(0.2))
            fadeArray:addObject(CCFadeOut:create(0.3))
            
            win_star_shine:setPosition(ccp(x, y))
            win_star_shine:setOpacity(0)
            win_star_shine:setScale(math.random() * 0.5 + 0.4)
            win_star_shine:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))
            win_star_shine:runAction(CCRepeatForever:create(CCSequence:create(fadeArray)))

            local function remove ()
                if win_star_shine and not win_star_shine.isDisposed then
                    win_star_shine:removeFromParentAndCleanup(true)
                end
            end
            local a = CCArray:create()
            a:addObject(CCDelayTime:create(delayT + 1))
            a:addObject(CCFadeOut:create(0.3))
            a:addObject(CCCallFunc:create(remove))
            local action = CCSequence:create(a)
            win_star_shine:runAction(action)
            scene:addChild(win_star_shine)
        end
    end


    local scene = Director:sharedDirector():getRunningScene()
    local function callback()
        if scene then
            if lc and not lc.isDisposed then
                lc:removeFromParentAndCleanup(true)
            end
            if _G.isLocalDevelopMode then printx(0, 'remove MAGPIE', magpie.isDisposed) end
            if magpie and not magpie.isDisposed then
                magpie:removeFromParentAndCleanup(true)
            end
        end
    end
    local action = CCSequence:createWithTwoActions(CCMoveTo:create(3, endPos), CCCallFunc:create(callback))
    if scene then
        scene:addChild(lc)
        scene:addChild(magpie)
        magpie:runAction(action)
        for k, v in pairs(itemPos) do 
            createShining(scene, v, k - 1)
        end
    end

end

function QixiUtil:setTargetCount(count)
    targetCount = count
end