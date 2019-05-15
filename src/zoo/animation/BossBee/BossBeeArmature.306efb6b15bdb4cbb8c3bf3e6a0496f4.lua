--已废弃 BOSS动画更换 zhigang.niu

BossBeeArmature = class()

function BossBeeArmature:createGeneratorBottleIcon()
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeA')
    node:playByIndex(0, 0)
    return node
end

function BossBeeArmature:createComeOutAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeB')
    node:setAnimationScale(1)
    node:playByIndex(0, 1)
    node:setScale(1.1)
    local function animationCallback()
        if _G.isLocalDevelopMode then printx(0, 'createComeOutAnimation callback') end
        if finishCallback then
            finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createFlyupAnimation()
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeC')
    node:playByIndex(0, 0)
    node:setScale(1.1)
    return node
end

function BossBeeArmature:createLandingAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeD')
    node:playByIndex(0, 1)
    node:setScale(1.1)
    node.finishCallback = finishCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createIdleAnimation()
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeE')
    node:playByIndex(0, 0)
    node:setScale(1.1)
    return node
end

function BossBeeArmature:createPlayCuteAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeF')
    node:playByIndex(0, 1)
    node:setScale(1.1)
    node.finishCallback = finishCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createHitAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeG')
    node:playByIndex(0, 1)
    node:setScale(1.1)
    node.finishCallback = finishCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createCastAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeH')
    node:playByIndex(0, 1)
    node:setScale(1.1)
    node.finishCallback = finishCallback
    node.castEventCallback = castEventCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createCastleAnimation()
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('castle')
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    node:playByIndex(1, 0)
    node:update(0.001)
    node:stop()
    return node
end

-- 大招蜜蜂 Big Action
function BossBeeArmature:createBigActionBeeAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('beeI')
    node:playByIndex(0, 1)
    node.finishCallback = finishCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end

function BossBeeArmature:createBigActionCloudAnimation(finishCallback)
    if __WIN32 then
        FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')
    end
    local node = ArmatureNode:create('cloudN')
    node:playByIndex(0, 1)
    node.finishCallback = finishCallback
    local function animationCallback()
        if node.finishCallback then
            node.finishCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    return node
end