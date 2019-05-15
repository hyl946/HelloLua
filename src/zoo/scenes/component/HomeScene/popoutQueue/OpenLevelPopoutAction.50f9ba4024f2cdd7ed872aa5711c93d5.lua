
OpenLevelPopoutAction = class(HomeScenePopoutAction)

function OpenLevelPopoutAction:ctor(levelId)
    self.levelId = levelId
end

function OpenLevelPopoutAction:popout( ... )
    if not self.levelId then
        self:placeholder()
        self:next()
        return
    end

    local worldScene = HomeScene:sharedInstance().worldScene        
    if not worldScene.levelToNode[self.levelId] then
        -- local tip = "您需要更新到最新版本才能看到该关卡哦~快去更新吧！"
        local tip = Localization:getInstance():getText("forcepop.tip2")
        local function callback( ... )
            self:next()
        end
        local panel = NewVersionTipPanel:create(tip,callback)
        panel:popout()
    else
        local function callback( ... )
            worldScene.levelToNode[self.levelId]:playParticle()
            HomeScene:sharedInstance():runAction(CCSequence:createWithTwoActions(
                CCDelayTime:create(2),
                CCCallFunc:create(function( ... ) self:next() end)
            ))
        end
        worldScene:moveNodeToCenter(self.levelId,callback)
    end
end



function OpenLevelPopoutAction:getConditions( ... )
    return {"enter","enterForground","preActionNext"}
end