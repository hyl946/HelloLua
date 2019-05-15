--=====================================================
-- ShareShowUtil  
-- by zhijian.li
-- (c) copyright 2009 - 2017, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  ShareShowUtil.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2017/02/15
-- descrip:   分享按钮图标显示
--=====================================================

ShareShowUtil = class()

local instance = nil

function ShareShowUtil.getInstance()
	if not instance then
		instance = ShareShowUtil.new()
		instance:init()
	end
	return instance
end

function ShareShowUtil:init()
	InterfaceBuilder:createWithContentsOfFile("ui/ShareButtonIcon.json")
end

function ShareShowUtil:getBtnIconByType(shareType)
	local iconPath = nil
	if shareType == PlatformShareEnum.kMiTalk then 
		iconPath = "share_btn_icon/sbi_mi0000"
	elseif shareType == PlatformShareEnum.kJPQQ then 
		iconPath = "share_btn_icon/sbi_qq0000"
	elseif shareType == PlatformShareEnum.kJPWX then
		iconPath = "share_btn_icon/sbi_wx0000"
	else
		iconPath = "share_btn_icon/sbi_wx0000"
	end

	return SpriteColorAdjust:createWithSpriteFrameName(iconPath)
end
