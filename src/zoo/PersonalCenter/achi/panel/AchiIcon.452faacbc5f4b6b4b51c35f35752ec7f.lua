require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

local AchiIcon = class(IconButtonBase)

function AchiIcon:create(isGuide)
    local instance = AchiIcon.new()
    instance:init()
    if isGuide then BtnShowHideConf[ManagedIconBtns.ACHIEVE].showPriority = 97.99 end
    instance:initShowHideConfig(ManagedIconBtns.ACHIEVE)
    return instance
end

function AchiIcon:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_achievement')

    IconButtonBase.init(self, self.ui)

	self.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
        DcUtil:UserTrack({ category='ui', sub_category='G_achievement_click_button', other='t1'})
		AchiUIManager:openMainPanel()
	end)

    self.redDot = self:addRedDot()
    self.redDot:setVisible(false) 
    Notify:register("AchiEventReachedNewAchi", self.showAchiBroadcast, self)
end

function AchiIcon:showAchiBroadcast(achis)
    --新达成的成就
     AchiUIManager:setNewAchis(achis)

    self.redDot:setVisible(true)
    self:playOnlyIconAnim() 

    if IconButtonPool:getBtnState(self) ~= IconBtnShowState.ON_HOMESCENE then 
        HomeScene:sharedInstance().hideAndShowBtn.reddot:setVisible(true)
    end   
end

function AchiIcon:stopAnimation()
    self.redDot:setVisible(false)
    self:stopOnlyIconAnim()
    HomeScene:sharedInstance().hideAndShowBtn.reddot:setVisible(false)
end

function AchiIcon:dispose()
    IconButtonBase.dispose(self)
end

return AchiIcon

