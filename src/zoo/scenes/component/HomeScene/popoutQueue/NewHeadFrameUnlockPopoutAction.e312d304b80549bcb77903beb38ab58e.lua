require "zoo.data.UserManager"
-- local NewHeadFrameUnlockPanel = require("zoo.PersonalCenter.NewHeadFrameUnlockPanel")

require("zoo.PersonalCenter.HeadFrameGotPanel")

NewHeadFrameUnlockPopoutAction = class(HomeScenePopoutAction)

local function isHomeScene()
    return Director:sharedDirector():getRunningScene():is(HomeScene)
end

function NewHeadFrameUnlockPopoutAction:ctor()
    self.name = "NewHeadFrameUnlockPopoutAction"
    
    self.ignorePopCount = true
    self:setSource( AutoPopoutSource.kTriggerPop )
end

function NewHeadFrameUnlockPopoutAction:checkCache(cache)
    if _G.isLocalDevelopMode then printx(100, " popout popoutHeadFrameID =  " ,cache and cache.para) end
    self.popoutHeadFrameID = cache.para
    self:onCheckCacheResult( self.popoutHeadFrameID ~= nil)
end

function NewHeadFrameUnlockPopoutAction:popout( next_Action )
    local function closeCallBack( ... )
        local _ = next_Action and next_Action()
    end 

    HeadFrameGotPanel:create(closeCallBack)

    -- local newHeadFrameUnlockPanel = NewHeadFrameUnlockPanel:create( closeCallBack )
    -- newHeadFrameUnlockPanel:popout(  )    
    --这个板子出来了 就算你做完引导了
    if UserManager:getInstance():hasGuideFlag( kGuideFlags.NewHeadFrame ) == false then
        UserLocalLogic:setGuideFlag( kGuideFlags.NewHeadFrame )
    end
    
end