-- 春季周赛小鹿 复制的冬季周赛的鼹鼠
-- 取这个名字的意思是希望以后就叫这个了 你懂的～
SpringFestivalAnimation = class()

local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end

    return plistPath
end

-- 改为使用SimpleClippingNode实现
function SpringFestivalAnimation:buildItemIcon()
--    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/SpringFestival_2019/SpringFestival_2019.plist"))
    local container = Sprite:createEmpty()
    local bubble = Sprite:createWithSpriteFrameName('SpringFestival_2019res/SpringFestival_bubble0000')

    if bubble then
        bubble:setScale(1.01)
        bubble:setPosition(ccp(0, 0))
        container:addChild(bubble)
        container.bubble = bubble

        local size = bubble:getContentSize()
        local SkillIcon = Sprite:createWithSpriteFrameName('SpringFestival_2019res/springFestival_Skill0000')
        SkillIcon:setPosition(ccp(size.width/2, size.height/2+3/0.7))
        bubble:addChild(SkillIcon)


        local skillCircle = Sprite:createWithSpriteFrameName('SpringFestival_2019res/SkillCircle0000')
        skillCircle:setPosition(ccp(size.width/2, size.height/2))
        bubble:addChild(skillCircle)
        skillCircle:setVisible(false)
        container.skillCircle = skillCircle

        local useSkillTip = Sprite:createWithSpriteFrameName('SpringFestival_2019res/useSkillTip0000')
        useSkillTip:setPosition(ccp(size.width/2+250, size.height/2 + 100 ))
        bubble:addChild(useSkillTip)
        useSkillTip:setVisible(false)
        useSkillTip.SavePos = IntCoord:create(size.width/2+250, size.height/2 + 100) 
        container.useSkillTip = useSkillTip

        --redPoint
        local redPoint_sprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/redPoint0000")
        redPoint_sprite:setPosition( ccp(size.width/2+40, size.height/2+48) )
        bubble:addChild( redPoint_sprite )
        redPoint_sprite:setVisible(false)
        container.redPoint_sprite = redPoint_sprite

        local poingNumLabel = BitmapText:create( "" ,"fnt/prop_name.fnt")
        poingNumLabel:setPosition( ccp(16,20) )
        poingNumLabel:setScale(0.6)
        poingNumLabel:setAnchorPoint(ccp(0.5, 0.5))
        redPoint_sprite:addChildAt(poingNumLabel,1)
        container.poingNumLabel = poingNumLabel

        local function ShowNum()
            SpringFestival2019Manager.getInstance():ShowRedPointAndUpdate()
        end
        redPoint_sprite:runAction( CCCallFunc:create(ShowNum) )

        local function skillTipShow( )

            if container.skillCircle:isVisible() then return  end

            local array1 = CCArray:create()
            array1:addObject( CCFadeIn:create(1)  )
            array1:addObject( CCFadeOut:create(1) )

            container.skillCircle:stopAllActions()
            container.skillCircle:runAction( CCRepeatForever:create( CCSequence:create(array1) ) )
            container.skillCircle:setVisible(true)

            --
            local function MoveEnd()

--                if GameSpeedManager:getGameSpeedSwitch() > 0 then
--		            GameSpeedManager:changeSpeedForFastPlay()
--	            end

                container.useSkillTip:setVisible(false)
            end

            local array4 = CCArray:create()
            array4:addObject( CCRotateTo:create(0.1, 5 ) )
            array4:addObject( CCRotateBy:create(0.1, -10 ) )
            array4:addObject( CCRotateBy:create(0.1, 10 ) )
            array4:addObject( CCRotateBy:create(0.1, -10 ) )
            array4:addObject( CCRotateBy:create(0.1, 10 ) )
            array4:addObject( CCRotateBy:create(0.1, -5 ) )

            local array5 = CCArray:create()
            array5:addObject( CCMoveBy:create(0.5, ccp(-350 , 0 ))  )
            array5:addObject( CCDelayTime:create(0.3)  )
            array5:addObject( CCSequence:create(array4)  )
            array5:addObject( CCDelayTime:create(1.5)  )
            array5:addObject( CCMoveBy:create(0.5, ccp(350 , 0 ))  )
            array5:addObject(CCCallFunc:create(MoveEnd))

            container.useSkillTip:setPosition( ccp(container.useSkillTip.SavePos.x, container.useSkillTip.SavePos.y) )
            container.useSkillTip:stopAllActions()
            container.useSkillTip:runAction( CCSequence:create(array5) )
            container.useSkillTip:setVisible(true)

--            if GameSpeedManager:getGameSpeedSwitch() > 0 then
--		        GameSpeedManager:resuleDefaultSpeed()
--	        end
        end

        local function skillTipHide( )
            container.skillCircle:stopAllActions()
            container.useSkillTip:stopAllActions()

            container.skillCircle:setVisible(false)
            container.useSkillTip:setVisible(false)
        end

        container.skillTipShow = skillTipShow
        container.skillTipHide = skillTipHide
        container.SkillIcon = SkillIcon
    end

    return container
end

