--region NewFile_1.lua
--Author : Administrator
--Date   : 2018/5/17
--此文件由[BabeLua]插件自动生成


local FlyLightLine = {}

function FlyLightLine:GetLightAngleByPos( srcPos, dstPos )

    local pi = 3.1415926
    local x = math.abs( srcPos.x - dstPos.x )
    local y = math.abs( srcPos.y - dstPos.y )

    local angle = 0
    if srcPos.x == dstPos.x and srcPos.y ~= dstPos.y then
        if srcPos.y > dstPos.y then
            angle = -90
        elseif srcPos.y < dstPos.y then
            angle = 90
        end
    elseif srcPos.y == dstPos.y and srcPos.x ~= dstPos.x  then
        if srcPos.x > dstPos.x then
            angle = -90
        elseif srcPos.x < dstPos.x then
            angle = 90
        end
    elseif srcPos.y == dstPos.y and srcPos.x == dstPos.x  then
        angle = 0
    elseif srcPos.x > dstPos.x then

        angle = math.atan( y/x )*180/pi

        if srcPos.y > dstPos.y then
            angle = angle * (-1)
        end

    elseif srcPos.x < dstPos.x then

        angle = 180 - math.atan( y/x )*180/pi

        if srcPos.y > dstPos.y then
            angle = angle * (-1)
        end
    end

    return angle
end

function FlyLightLine:createLine( parent, flyTime, SelfPos, EndPos, CallBack, callBackParam )

    FrameLoader:loadArmature('skeleton/week_bossSkill')

    local function getDistance(pos1,pos2)
        return math.sqrt(math.pow((pos2.y-pos1.y),2)+math.pow((pos2.x-pos1.x),2))
    end

    local length = getDistance( SelfPos, EndPos )

    --流光
    local animLine = nil
    if length < 200 then
        animLine = ArmatureNode:create('bossSkill/flyanime2')
    else
        animLine = ArmatureNode:create('bossSkill/flyanime')
    end
    
    animLine:playByIndex(0)
    animLine:update(0.001)
    animLine:stop()
    animLine:setPosition( SelfPos )
    parent:addChildAt(animLine,11)

    local Angle = FlyLightLine:GetLightAngleByPos( SelfPos, EndPos )
    animLine:setRotation( Angle )

    function FlyEnd()

        animLine:removeAllEventListeners()
        animLine:addEventListener(ArmatureEvents.COMPLETE, function()
    	    animLine:removeAllEventListeners()
    	    animLine:removeFromParentAndCleanup(true)
        end)
        animLine:play("flyend", 1)
        if CallBack then CallBack( callBackParam ) end
    end

    local array = CCArray:create()
    array:addObject(CCMoveTo:create( flyTime, ccp( EndPos.x, EndPos.y ) ) )
    array:addObject(CCCallFunc:create(FlyEnd))

    animLine:addEventListener(ArmatureEvents.COMPLETE, function()
    	animLine:removeAllEventListeners()
        animLine:play("flying", 0)
    end)

    animLine:play("fly", 1)
    animLine:runAction(CCSequence:create(array))
end

return FlyLightLine
--endregion
