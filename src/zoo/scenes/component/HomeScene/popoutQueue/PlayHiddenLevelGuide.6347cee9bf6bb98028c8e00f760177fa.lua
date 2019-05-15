PlayHiddenLevelGuide = class(HomeScenePopoutAction)

function PlayHiddenLevelGuide:popout()
    local function guideEnd()
        self:next()
    end

    local offDay = UserManager:getInstance():getOffLoginDayNum()
    -- if _G.isLocalDevelopMode then printx(0, ">>>------------------------offDay:", offDay) end
    local ignoreTimeStamp = Cookie.getInstance():read("IgnoreHiddenLevelGuideDay")
    local todayIgnoreGuide = false
    if ignoreTimeStamp ~= nil and type(ignoreTimeStamp) == "number" then
        if Localhost:getDayStartTimeByTS(ignoreTimeStamp) == Localhost:getTodayStart() then
            todayIgnoreGuide = true
        end
    end
    if offDay > 6 or todayIgnoreGuide then
        -- if _G.isLocalDevelopMode then printx(0, ">>>-------------------------0") end
        if offDay > 6 then Cookie.getInstance():write("IgnoreHiddenLevelGuideDay",Localhost:timeInSec()) end
        self:placeholder()
        self:next()
    else
        -- if _G.isLocalDevelopMode then printx(0, ">>>-------------------------1") end
        local guideBranchId = MetaModel:sharedInstance():getNeedGuideHiddenBranchId()
        -- if _G.isLocalDevelopMode then printx(0, ">>>-------------------------1_0:", guideBranchId) end
        if guideBranchId and not UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kHiddenBranchIntroduction) then       
            -- if _G.isLocalDevelopMode then printx(0, ">>>-------------------------2", guideBranchId) end
            HomeScene:sharedInstance().worldScene:scrollToBranch(guideBranchId,function( ... )
            local panel = HiddenBranchIntroductionPanel:create("hide_stage_tips5", guideBranchId, guideEnd)
            PopoutQueue:sharedInstance():push(panel,false)
            end)
            DcUtil:UserTrack({ category="hide", sub_category="remind_hide_stage" })
        else
        -- if _G.isLocalDevelopMode then printx(0, ">>>-------------------------3") end
            self:placeholder()
            self:next()
        end
    end
--//
end


function PlayHiddenLevelGuide:getConditions( ... )
    return {"enter", "enterForground","preActionNext"}
end