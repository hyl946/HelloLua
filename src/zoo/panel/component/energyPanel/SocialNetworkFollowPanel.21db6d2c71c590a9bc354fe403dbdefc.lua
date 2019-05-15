require "zoo.util.WeChatSDK"

SocialNetworkFollowPanel = class(BaseUI)

-- social network logo
kSocialType = {
	kWeChat = 1,
	kWeibo = 2,
	kMitalk = 3,
}
-- reward shown on panel
local reward = {
	itemId = 10013,
	num = 2
}

function SocialNetworkFollowPanel:create(energyPanel, socialType)
	local panel = SocialNetworkFollowPanel.new()
	panel:init(energyPanel, socialType)
	panel.panelPluginType = "Pendant"
	return panel
end

function SocialNetworkFollowPanel:init(energyPanel, socialType)
	-- data
	self.energyPanel = energyPanel

	-- init panel
	self.ui	= ResourceManager:sharedInstance():buildGroup("energy_social_network_panel")
	BaseUI.init(self, self.ui)

	self.desc_weibo = self.ui:getChildByName('desc_weibo')
	self.desc_wechat = self.ui:getChildByName('desc_wechat')

	self.gotoButton = ButtonIconsetBase:create(self.ui:getChildByName('btn'))
	self.gotoButton.icon_weibo = self.gotoButton.groupNode:getChildByName('icon_weibo')
	self.gotoButton.icon_wechat = self.gotoButton.groupNode:getChildByName('icon_wechat')
	self.gotoButton.icon_mi = self.gotoButton.groupNode:getChildByName('icon_mi')

	if socialType == kSocialType.kWeChat then
		self.desc_wechat:setVisible(true)
		self.desc_weibo:setVisible(false)
		
		self.gotoButton:setIconByFrameName("common_icon/sns/icon_wechat0000")
		self.gotoButton:setString(localize("social.network.follow.panel.btn"))
	elseif socialType == kSocialType.kWeibo then
		self.desc_wechat:setVisible(false)
		self.desc_weibo:setVisible(true)
		self.gotoButton:setIconByFrameName("common_icon/sns/icon_weibo0000")
		
		self.gotoButton:setString(localize("social.network.follow.panel.btn"))
	elseif socialType == kSocialType.kMitalk then
		self.desc_wechat:setVisible(false)
		self.desc_weibo:setVisible(false)

		self.gotoButton:setIconByFrameName("common_icon/sns/icon_mi0000")
		self.gotoButton:setString(localize("social.network.follow.panel.btn"))
	end

	-- add event listener
	local function onButtonTapped()
		-- TODO: goto specific social network
		self:_gotoSocialNetwork(socialType)
	end
	self.gotoButton:addEventListener(DisplayEvents.kTouchTap, onButtonTapped)

end

function SocialNetworkFollowPanel:_gotoSocialNetwork(social)
	-- local dest = "about:blank"
	-- if social == kSocialType.kWeChat then
	-- 	dest = "http://weixin.com/qr/tHXFyjHEJg9ZhyCpnyCQ"
	-- elseif social == kSocialType.kWeibo then
	-- 	dest = "http://weibo.com/kaixinxiaoxiaole"
	-- end
	-- if __IOS then
	-- 	local nsURL = NSURL:URLWithString(dest)
	-- 	UIApplication:sharedApplication():openURL(nsURL)
	-- elseif __ANDROID then
	-- 	luajava.bindClass("com.happyelements.android.utils.HttpUtil"):openUri(dest)
	-- else
	-- 	CommonTip:showTip("on PC open your browser by yourself!")
	-- end

	if social == kSocialType.kWeChat then
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_wx"}, true)
		if __IOS or __ANDROID or __WP8 then
			if not PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then 
				local sdk = WeChatSDK.new()
				if not sdk:openWechat() then
					CommonTip:showTip(Localization:getInstance():getText("social.network.follow.panel.wechat.no.install"))
				end
			end
		else
			CommonTip:showTip("on PC open your browser by yourself!")
		end
	elseif social == kSocialType.kWeibo then
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_wb"}, true)
	    local url1 = "sinaweibo://userinfo?uid=3653487227"
	    local url2 = "http://weibo.com/kaixinxiaoxiaole"
	    if __ANDROID then

	        local httputils = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
	        if httputils:openUri(url1) then
	            if _G.isLocalDevelopMode then printx(0, "sinaweibo---------1") end
	        else
	            if httputils:openUri(url2) then
	                if _G.isLocalDevelopMode then printx(0, "sinaweibo---------2") end
	            else
	                if _G.isLocalDevelopMode then printx(0, "sinaweibo---------3") end
	                return
	            end
	        end
	    elseif __IOS then
	        url1 = NSURL:URLWithString(url1)
	        url2 = NSURL:URLWithString(url2)
	        UIApplication:sharedApplication():openURL(url1)
	        if _G.isLocalDevelopMode then printx(0, "sinaweibo---------4") end
	        if UIApplication:sharedApplication():canOpenURL(url1) then
	            if _G.isLocalDevelopMode then printx(0, "sinaweibo---------5") end
	        else
	            UIApplication:sharedApplication():openURL(url2)
	            if _G.isLocalDevelopMode then printx(0, "sinaweibo---------6") end
	        end
		elseif __WP8 then
			Wp8Utils:OpenUrl(url2)
		else
			CommonTip:showTip("on PC open your browser by yourself!")
	    end

		-- if __IOS then
		-- 	--4005501098873163
		-- 	UIApplication:sharedApplication():openURL(NSURL:URLWithString("http://weibo.com/kaixinxiaoxiaole"))
		-- elseif __ANDROID then
		-- 	luajava.bindClass("com.happyelements.android.utils.HttpUtil"):openUri("http://weibo.com/kaixinxiaoxiaole")
		-- elseif __WP8 then
		-- 	Wp8Utils:OpenUrl("http://weibo.com/kaixinxiaoxiaole")
		-- else
		-- 	CommonTip:showTip("on PC open your browser by yourself!")
		-- end
	elseif social == kSocialType.kMitalk then
		if __ANDROID then
			local openMitalkSuccess = luajava.bindClass("com.happyelements.android.platform.xiaomi.MiGameShareDelegate"):openMitalkApp()
			if not openMitalkSuccess then
				CommonTip:showTip(Localization:getInstance():getText("social.network.follow.panel.mitalk.no.install"))
			end
		else
			CommonTip:showTip("on PC open your browser by yourself!")
		end
	end
end
