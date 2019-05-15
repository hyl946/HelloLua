local SuperCls = require("zoo.panel.addFriend2.TabIcon")
local TabIconQQ = class(SuperCls)

function TabIconQQ:create(ui, tab, clkCallBack)
	local icon = TabIconQQ.new()
	icon.clkCallBack = clkCallBack
	icon:init(ui, tab)
	return icon
end

function TabIconQQ:init(ui, tab)
	SuperCls.init(self, ui, tab)
	self.disableShow = self.ui:getChildByName("disabled")
	self.disableShow:getChildByName("label"):setString(localize("add_friend_qq_snyc1"))
	self.normal:getChildByName("label"):setString(localize("add_friend_qq_snyc2"))
	self.selected:getChildByName("label"):setString(localize("add_friend_qq_snyc2"))
	self:updateBindInfo()
end

function TabIconQQ:updateBindInfo()
	self:setHasBind(self:getHasBind())
end

function TabIconQQ:setHasBind(hasBind)
	self.hasBind = hasBind
	self.tab:setHasBind(hasBind)
	if self.hasBind then
		self.disableShow:setVisible(true)
		self.normal:setVisible(false)
		self.selected:setVisible(false)
	else
		self.disableShow:setVisible(false)
	end
end

function TabIconQQ:getHasBind()
	if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) and --平台为QQ默认登录 and （当前不是QQ或QQ好友未同步）
	   not (SnsProxy:isQQLogin() or FriendManager.getInstance():isQQFriendsSynced()) then
	    return false
	else
		return true
	end
	-- return false
end

return TabIconQQ