require "zoo.panel.RequestMessagePanel"

MessageCenterScene = class(Scene)
function MessageCenterScene:create()
	local s = MessageCenterScene.new()
	s:initScene()
	return s
end

function MessageCenterScene:onInit()
	local panel = RequestMessagePanel:create()
	self:addChild(panel)
    self.panel = panel
end

function MessageCenterScene:onKeyBackClicked()
	Director:sharedDirector():popScene()
end

function MessageCenterScene:onApplicationHandleOpenURL(launchURL)
    if launchURL and string.len(launchURL) > 0 then
        local res = UrlParser:parseUrlScheme(launchURL)
        if not res.method or string.lower(res.method) ~= "addfriend" then return end
        if res.para and res.para.invitecode and res.para.uid and res.para.pid then
            local function onSuccess()
                local homeScene = HomeScene:sharedInstance()
                homeScene:checkDataChange()
                if homeScene.coinButton and not homeScene.coinButton.isDisposed then
                    homeScene.coinButton:updateView()
                end
                CommonTip:showTip(Localization:getInstance():getText("url.scheme.add.friend"), "positive")
            end
            local function onUserHasLogin()
				local logic = InvitedAndRewardLogic:create(false)
                logic:start(res.para.invitecode, res.para.uid, res.para.pid, res.para.ext, onSuccess)
            end
            RequireNetworkAlert:callFuncWithLogged(onUserHasLogin, nil, kRequireNetworkAlertAnimation.kNoAnimation)
        end
    end
end