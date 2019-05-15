
---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-10-13 19:06:36
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-03-27 10:26:25
---------------------------------------------------------------------------------------
require 'zoo.common.FAQ'

FAQButton = class(IconButtonBase)

function FAQButton:init(isSettingBtn)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_community')
    -- Init Base
    IconButtonBase.init(self, self.ui)
    self.numTip = self:addRedDotNum()
    self.redDot = self:addRedDot()
 
    for k, v in pairs(self.ui.list) do
        if _G.isLocalDevelopMode then printx(0, v.name) end
    end
    self.isSettingBtn = isSettingBtn
    if FriendRecommendManager:friendsButtonOutSide() then
        self.hasNoDot = true
    end
  
    self:refresh()
end

function FAQButton:create(isSettingBtn)
    local instance = FAQButton.new()
    instance:init(isSettingBtn)
    instance:initShowHideConfig(ManagedIconBtns.FAQ)
    return instance
end

function FAQButton:refresh()
    local num = 0
    local show = false
    if not self.hasNoDot then
        num = FAQ:readFaqReplayCount()
        show = num > 0
    end
    if self.isSettingBtn then
	    if self.numTip and not self.numTip.isDisposed then self.numTip:setVisible(false) end
	    if self.redDot and not self.redDot.isDisposed then self.redDot:setVisible(show) end
    -- 	HomeScene:sharedInstance().settingButton:updateDotTipStatus()
    else
	    if self.redDot and not self.redDot.isDisposed then self.redDot:setVisible(false) end
	    if self.numTip and not self.numTip.isDisposed then 
            self.numTip:setVisible(show) 
            self.numTip:setNum(num)
        end
    end
end

function FAQButton:hideDot()
    if self.numTip and not self.numTip.isDisposed then self.numTip:setVisible(false) end
    if self.redDot and not self.redDot.isDisposed then self.redDot:setVisible(false) end
end

function FAQButton:createButton(isSettingBtn, onBtnTapped)
    local fcButton = FAQButton:create(isSettingBtn)

	local function onFcBtnTapped()
		if type(onBtnTapped) == "function" and onBtnTapped() then
			return
		end

		-- 防连点
		if fcButton.disableClick then
			return
		end
		fcButton.disableClick = true
		setTimeOut(function()  fcButton.disableClick = false end, 2)

		DcUtil:iconClick("click_service_icon")
		if PrepackageUtil:isPreNoNetWork() then
	        PrepackageUtil:showInGameDialog()
	    else
	        if __WP8 then
	            Wp8Utils:ShowMessageBox("QQ群: 114278702(满) 313502987\n联系客服: xiaoxiaole@happyelements.com", "开心消消乐沟通渠道")
	        else
	        	FAQ:openFAQClientIfLogin(nil, FAQTabTags.kSheQu)
	        end
            -- 点击后重置小红点显示逻辑
            fcButton:hideDot()
	    end
	end

    fcButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
    	if not fcButton or fcButton.isDisposed then return end

        if (PrepackageUtil:isPreNoNetWork()) then
            PrepackageUtil:showSettingNetWorkDialog()
        else
            onFcBtnTapped()
        end
    end)

    return fcButton
end