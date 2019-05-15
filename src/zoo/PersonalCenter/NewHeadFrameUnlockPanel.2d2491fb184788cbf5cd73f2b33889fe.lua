local UIHelper = require 'zoo.panel.UIHelper'

local NewHeadFrameUnlockPanel = class(BasePanel)

function NewHeadFrameUnlockPanel:create( closeCallBack )
    local panel = NewHeadFrameUnlockPanel.new()
    panel:loadRequiredResource("ui/NewHeadFrameUnlockPanel.json")
    panel:init()
    panel.closeCallBack = closeCallBack
    if _G.isLocalDevelopMode then
    end

    return panel
end

function NewHeadFrameUnlockPanel:init()
    local ui = UIHelper:createUI("ui/NewHeadFrameUnlockPanel.json", "NewHeadFrameUnlockPanel/mainPanel")
    BasePanel.init(self, ui)

    self.showYesBtn = false
    self:updateYesBtn()


    UIUtils:setTouchHandler(self.ui:getChildByPath('closebtn'), function()
        self:onCloseBtnTapped()
    end)


    UIUtils:setTouchHandler(self.ui:getChildByPath('yesbg'), function()
        self:onNorMoreBtnTapped()
    end)


    self.mainbtn = GroupButtonBase:create(self.ui:getChildByPath('mainbtn'))
    self.mainbtn:setString( "去替换" )
    self.mainbtn:ad(DisplayEvents.kTouchTap,     preventContinuousClick(function ( ... )
        self:onMainBtnClick()
    end))
    self.mainbtn:useBubbleAnimation()


    -- self.nomoredesc = self.ui:getChildByPath('nomoredesc')
    -- self.nomoredesc:setString("不再提醒")

    local sortHeadFrameType = {}

    for k, value in pairs( HeadFrameType ) do
        if type( value ) == "number" then
            if HeadFrameType:setProfileContext():isNew( value ) then
                self.newFrameID = value
            end
        end
    end

    -- if not self.newFrameID and _G.isLocalDevelopMode then
    --     self.newFrameID = 14 
    -- end

    if self.newFrameID then
        self.iconpoint = self.ui:getChildByPath("iconpoint")
        self.iconpoint:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
        local userId = nil
        if UserManager:getInstance().user then
            userId = UserManager:getInstance().user.uid or 0
        end
        local frameUI = HeadFrameType:buildUI( self.newFrameID , 1, userId )

        frameUI:setAnchorPoint( ccp(0.5,0.5))
        local holder = frameUI:getChildByName('head')
        holder:removeFromParentAndCleanup(true)

        frameUI:setScale(1.3)
        self.ui:addChild( frameUI )
        frameUI:setPositionX( self.iconpoint:getPositionX() )
        frameUI:setPositionY( self.iconpoint:getPositionY() )

        self.iconpoint:setVisible( false )

        local labelString = "获得"..localize('headframe.title.' .. self.newFrameID).."！快换上试试吧~"

        self.maindesc = self.ui:getChildByPath("maindesc")

        self.maindesc:setDimensions(CCSizeMake( 580 , 0) )

        self.maindesc:setString( labelString )

    end

    
    
end

function NewHeadFrameUnlockPanel:updateYesBtn(  )

    self.yesbtn = self.ui:getChildByPath('yesbtn')
    self.yesbtn:setVisible( self.showYesBtn )

end

function NewHeadFrameUnlockPanel:onNorMoreBtnTapped( ... )
    if self.isDisposed then return end

    self.showYesBtn  = not self.showYesBtn 

    self:updateYesBtn()

end

function NewHeadFrameUnlockPanel:onMainBtnClick( ... )
    if self.isDisposed then return end

    local function closeCallBack(  )
        if self.isDisposed then return end
         self:_close()
    end 

    PersonalCenterManager:showPersonalCenterPanel()
    local panel = require("zoo.PersonalCenter.PersonalInfoPanel"):create(false)
    panel:popoutAndEditHeadFram( closeCallBack )

    self:setVisible(false)
   
end


function NewHeadFrameUnlockPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end
    self:_close()

    

end


function NewHeadFrameUnlockPanel:saveData( ... )

    if self.isDisposed then return end
    if not self.showYesBtn then
        return
    end

    local userId = nil
    if UserManager:getInstance().user then
        userId = UserManager:getInstance().user.uid or 0
    end
    if not userId then
        return 
    end  

    local config = CCUserDefault:sharedUserDefault()
    config:setBoolForKey("NewHeadFrameUnlockPanel.nomore"..userId, true )
    CCUserDefault:sharedUserDefault():flush()

end

function NewHeadFrameUnlockPanel:_close()
    if self.isDisposed then return end
    
    self:saveData()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)

    if self.closeCallBack then
        self.closeCallBack()
    end
end



function NewHeadFrameUnlockPanel:dispose( ... )



    BasePanel.dispose(self, ...)

end


function NewHeadFrameUnlockPanel:buildInviteCode( ... )
	if self.isDisposed then return end
	


end



function NewHeadFrameUnlockPanel:popout()


    self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self, true)

	self.allowBackKeyTap = true
    self:popoutShowTransition()

end

function NewHeadFrameUnlockPanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	-- local PersonalInfoGuide = require "zoo.PersonalCenter.PersonalInfoGuide"
	-- if PersonalInfoGuide.shouldShowGuideTwo then
	-- 	PersonalInfoGuide.panel = self
	-- 	PersonalInfoGuide:popGuideTwo()
	-- end
end

return NewHeadFrameUnlockPanel
