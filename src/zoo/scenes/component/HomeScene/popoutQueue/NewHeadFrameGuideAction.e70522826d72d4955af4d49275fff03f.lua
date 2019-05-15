--[[
 * NewHeadFrameGuideAction
 * @date    2018-08-09 16:27:20
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require "zoo.gameGuide.Guides"

local function isHomeScene()
    return Director:sharedDirector():getRunningScene():is(HomeScene)
end

NewHeadFrameGuideAction = class(HomeScenePopoutAction)

function NewHeadFrameGuideAction:ctor()
	self.name = "NewHeadFrameGuideAction"
	self.guideFlag = false
    self:setSource( AutoPopoutSource.kInitEnter , AutoPopoutSource.kSceneEnter )

end

function NewHeadFrameGuideAction:checkCanPop()

	

	if HomeSceneButtonsManager:getInstance().hasGuideOnScreen or GameGuideData:sharedInstance():getRunningGuide() then
		return self:onCheckPopResult(false)
	end

	if UserManager:getInstance().user then
        userId = UserManager:getInstance().user.uid or 0
    end

    local config = CCUserDefault:sharedUserDefault()
    local hasNew = HeadFrameType:setProfileContext():hasNewHeadFrame()
    local isHomeScene = isHomeScene()

    local isFinishGuide = UserManager:getInstance():hasGuideFlag(kGuideFlags.NewHeadFrame)

    local frames = HeadFrameType:setProfileContext(nil):getAvaiHeadFrame()
    local sortHeadFrameType = {}
    for k, value in pairs( HeadFrameType ) do
        if type( value ) == "number" then
            table.insert(sortHeadFrameType , value)
        end
    end
    table.sort( sortHeadFrameType, function ( a , b  )

        local hasIt_a = table.find( frames ,function ( frameNode )
            return frameNode.id == a
        end)
        local hasIt_b = table.find( frames ,function ( frameNode )
            return frameNode.id == b
        end)
        if hasIt_a and not hasIt_b then
            return true
        end
        if not hasIt_a and  hasIt_b then
            return false
        end
        if hasIt_a and hasIt_b then
            return a < b
        end 
        return a < b
    end )

    local myHeadFramID =  HeadFrameType:setProfileContext():getCurHeadFrame()
    local firstNewHeadFramdID = nil
    for k, value in pairs( sortHeadFrameType ) do
        if HeadFrameType:setProfileContext():isNew( value ) and myHeadFramID~= value then
            firstNewHeadFramdID = value
            break
        end
    end

	if not isFinishGuide and hasNew and isHomeScene and firstNewHeadFramdID~=nil then
		self.guideFlag = true
	end
	
	if _G.isLocalDevelopMode then printx(100, " NewHeadFrameGuideAction:checkCanPop() self.guideFlag  =" , self.guideFlag  ) end
	if _G.isLocalDevelopMode then printx(100, " isFinishGuide " , isFinishGuide  ) end
	if _G.isLocalDevelopMode then printx(100, " hasNew " , hasNew  ) end
	if _G.isLocalDevelopMode then printx(100, " isHomeScene " , isHomeScene  ) end
	
	self:onCheckPopResult( self.guideFlag )

end

function NewHeadFrameGuideAction:popout(next_action)

	local function closeCallBack( ... )
        if next_Action then
            next_Action()
        end
    end

	if _G.isLocalDevelopMode then printx(100, " NewHeadFrameGuideAction:popout()") end
    local newHeadFrameGuide = require "zoo.PersonalCenter.NewHeadFrameGuide"
	newHeadFrameGuide:popGuide( closeCallBack , true )

	if UserManager:getInstance():hasGuideFlag( kGuideFlags.NewHeadFrame ) == false then
        UserLocalLogic:setGuideFlag( kGuideFlags.NewHeadFrame )
    end


    
end