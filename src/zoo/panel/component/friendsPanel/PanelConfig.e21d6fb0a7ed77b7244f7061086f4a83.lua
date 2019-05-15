local function debug_log(arg)
end

local fmgr = FriendManager:getInstance()

local pages = 
{
    friends = 1,
    recommend = 2,
    addFriend = 3,
}

local panelConfig = {}
panelConfig[pages.friends] = 
{     
    msgType = {
        RequestType.kPassMaxNormalLevel
    },
    pageName = 'friendList',
    pageIndex = 1, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("friends.panel.tab.friends"),
        number = 0,
    },
    pageConfig = 
    {
        pagePadding = {top=10,left=26,bottom=0,right=0},
        class = function(msg) return FriendRequestItem end, 
        zero = function() return RequestMessageZeroFriend end,
        normal = function() return RequestMessageZeroFriend end
    },
    showWhenNotEmpty = function () 
        return true
    end,
    hideWhenEmpty = function () 
        return false 
    end,
}

panelConfig[pages.recommend] = 
{ 
    msgType = {
        RequestType.kPassMaxNormalLevel,
    },
    pageName = 'recommend',
    pageIndex = 2, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("friends.panel.tab.recommand"),
        number = 0,
    },
    pageConfig = 
    {
        pagePadding = {top=10,left=26,bottom=0,right=0},
        itemMargin = {top=8},
        class = function(msg) return AskForHelpItem end, 
        zero = function() return RequestMessageZeroFriend end,
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        return false
    end,
}

panelConfig[pages.addFriend] = 
{ 
    msgType = {
        RequestType.kPassMaxNormalLevel,
    },
    pageName = 'addFriend',
    pageIndex = 3, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("friends.panel.tab.other"),
    },
    pageConfig = 
    {
        pagePadding = {top=10,left=-2,bottom=30,right=0},
        itemMargin = {top=8},
        class = function() return FriendAddItem end, 
        zero = function() return RequestMessageZeroActivity end,
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        return false
    end,
}

local function sortPagesByOrder(pages, order)
    local pageIdxs = {}
    for _, v in pairs(pages) do
        table.insert(pageIdxs, v)
    end
    table.sort(pageIdxs)
    if type(order) == "table" then
        local result = {}
        for _, v in ipairs(order) do
            if table.exist(pageIdxs, v) then
                table.insert(result, v)
            end
        end
        for _, v in ipairs(pageIdxs) do
            if not table.exist(result, v) then
                table.insert(result, v)
            end
        end
        return result
    else
        return pageIdxs
    end
end

function isRecommendPageEnable()
	local uid = UserManager:getInstance().user.uid or '12345'
	local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('FriendsRecommand', 'A1', uid)
	return isEnabled
end

panelConfig.getConfig = function ()
    local tabConfigRet = {}
    local pageConfigRet = {}

    local sortedPages = {1, 2, 3}
    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
        sortedPages = {1}
    end

    if not isRecommendPageEnable() then
        sortedPages = {1, 3}
        if WXJPPackageUtil.getInstance():isWXJPPackage() then 
            sortedPages = {1}
        end
    end

    local index = 1

    for _, i in ipairs(sortedPages) do
        panelConfig[i].tabConfig.msgType = panelConfig[i].msgType
        panelConfig[i].tabConfig.pageName = panelConfig[i].pageName
        panelConfig[i].pageConfig.type = i
        panelConfig[i].pageConfig.msgType = panelConfig[i].msgType
        panelConfig[i].pageConfig.pageName = panelConfig[i].pageName
        panelConfig[i].tabConfig.pageIndex = index
        panelConfig[i].pageConfig.pageIndex = index

        table.insert(tabConfigRet, panelConfig[i].tabConfig)
        table.insert(pageConfigRet, panelConfig[i].pageConfig)
        index = index + 1
    end
    return tabConfigRet, pageConfigRet
end

return panelConfig