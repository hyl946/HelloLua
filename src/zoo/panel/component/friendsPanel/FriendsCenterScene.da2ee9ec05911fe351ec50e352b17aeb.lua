require 'zoo.panel.component.friendsPanel.FriendsPanel'

local function unloadThis()
    --[[
    local unload = {
        'zoo.panel.component.friendsPanel.FriendsCenterScene',
        'zoo.panel.component.friendsPanel.FriendsPanel',
        'zoo.panel.component.friendsPanel.FriendsPanelTab',
        'zoo.panel.component.friendsPanel.PanelConfig',
        'zoo.panel.component.friendsPanel.FriendZeroItem',
        'zoo.panel.component.friendsPanel.FriendsPage',
        'zoo.panel.component.friendsPanel.FriendRankingPage',
        'zoo.panel.component.friendsPanel.items.FriendRankingItem',
    }
    for i=1, #unload do
        local modId = unload[i]
        package.loaded[modId] = nil
         _G[modId] = nil
    end
    --]]
end

FriendsCenterScene = class(Scene)
function FriendsCenterScene:create()
    local data = GameGuideData:sharedInstance()
    data:setScene("friendsCenterScene")
    
    unloadThis()

    local s = FriendsCenterScene.new()
    s:initScene()
    return s
end

function FriendsCenterScene:onInit()
	local panel = FriendsPanel:create()
    panel.scene = self
	self:addChild(panel)
    self.panel = panel
    
end

function FriendsCenterScene:onKeyBackClicked()
	-- Director:sharedDirector():popScene()
    self.panel:onKeyBackClicked()
end

function FriendsCenterScene:onApplicationHandleOpenURL(launchURL)
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

local function checkNeedSwithc2Recommend(callback)
    local friends = FriendManager:getInstance().friends or {}
    if table.size(friends) > 0 then
        return callback(false)
    end
    PaymentNetworkCheck.getInstance():check(function ()
        return callback(true)
    end, function ()
        return callback(false)
    end)
end

function createFriendRankingPanel(pageName, callback )

    local panel
    local function onSendFriendSuccess()
        local dcData = {}
        dcData.category = "add_friend"
        dcData.t1 = 1
        dcData.sub_category = "friends_panel_add_button"
        DcUtil:log(AcType.kUserTrack, dcData, true)

        -- invoke add friends panels
        local scene = FriendsCenterScene:create(pageName)
        Director:sharedDirector():pushScene(scene)
        panel = scene.panel
        if pageName then
            panel:gotoPage(pageName)
        else
            local function onFinished(isSwitch)
                if isSwitch then
                    panel:gotoPage("recommend")
                end
            end
            checkNeedSwithc2Recommend(onFinished)
        end

        local function onCloseCbk()
            unloadThis()
        end
        panel.closeCallback = onCloseCbk

        if callback then callback() end
    end
    
    local homescene = HomeScene:sharedInstance()
	if homescene and homescene.worldScene then
        homescene.worldScene:sendGetFriendInfoHttp(onSendFriendSuccess, onSendFriendSuccess, onSendFriendSuccess )
    else
        onSendFriendSuccess()
    end

    return panel
end

-- wxjpb
local wxjpOpened = false
local function onWXJPAddFriends()
	if not wxjpOpened then 
		wxjpOpened = true
		setTimeOut(function ()
			wxjpOpened = false
		end, 2)
	else
		return 
	end
	local shareCallback = {
		onSuccess=function(result)
			wxjpOpened = false
		end,
		onError=function(errCode, msg) 
			wxjpOpened = false
		end,
		onCancel=function()
			wxjpOpened = false
		end
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendInviteMessage(shareType, shareCallback)
end

function createAddFriendPanel(pageName)
    local function openFriendsPanel()
        createFriendRankingPanel(pageName)
    end
    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		onWXJPAddFriends()
	else
        openFriendsPanel()
	end
end