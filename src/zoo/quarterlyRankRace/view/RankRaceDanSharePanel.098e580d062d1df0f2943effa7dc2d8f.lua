
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local rrMgr


local RankRaceDanSharePanel = class(BasePanel)

function RankRaceDanSharePanel:create(rewards, keyParams)

	if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()


    local panel = RankRaceDanSharePanel.new()
    panel:init(rewards, keyParams)
    return panel
end

function RankRaceDanSharePanel:init(rewards, keyParams)
    local ui = UIHelper:createUI("ui/RankRace/showoff.json", "rank.race.showoff/panel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)

	BasePanel.init(self, ui)

	ui:getChildByPath('label2'):setVisible(false)

	local animalAnim = UIHelper:createArmature2('skeleton/RankRaceDan', 'rank.race.sk/animal')
	self.ui:addChild(animalAnim)
	animalAnim:setPosition(ccp(480, -1100))

    self.bIsOldSaiji = RankRaceMgr.getInstance():lastWeekIsOldUISeason()
    
    if self.bIsOldSaiji then
        local LaseWeekAfterDan = RankRaceMgr.getInstance().LaseWeekAfterDan or 1
        local DanName = localize('rank.race.dan.panel.title.'..LaseWeekAfterDan )
	    UIHelper:setAnimTitle( animalAnim, localize('rank.race.share.title.kuasaiji', {n=DanName}) )
    else
        local oldLv = tonumber(keyParams[1])
        local newLv = tonumber(keyParams[2])
        local shareStr = '晋级成功！'
        if oldLv and newLv and newLv <= 10 then
            if newLv - oldLv > 2 then
                oldLv = newLv - 1  
            end
            shareStr = localize('rank.race.share.title.' .. oldLv .. '.' .. newLv)
        end
        UIHelper:setAnimTitle(animalAnim, shareStr)
    end

	local resName = 'rank.race.sk/pao3'
	if #rewards > 3 then
		resName = 'rank.race.sk/pao6'		
	end

	local paoAnim = UIHelper:createArmature2('skeleton/RankRaceDan', resName)
	self.ui:addChild(paoAnim)
	paoAnim:setPosition(ccp(480, -540))

	self.refNodes = {}

	local scale = 1.08
	for i = 1, 6 do
		local con = UIHelper:getCon(paoAnim, 'pao' .. i)
		if con then
			if rewards[i] then
				local rewardItem = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/@RewardItem')
				rewardItem:setScale(scale)
				table.insert(self.refNodes, rewardItem)
				rewardItem:setPositionX((247 - 176 * scale)/2 + 21.85/2)
				rewardItem:setPositionY((243 + 178 * scale)/2 - 21.65/2)
				rewardItem:setRewardItem(rewards[i])
				con:addChild(rewardItem.refCocosObj)

				rewardItem.userData = {
					itemId = rewards[i].itemId,
					num = rewards[i].num,
				}
			end
		end
	end

	animalAnim:playByIndex(0, 1)
	paoAnim:playByIndex(0, 1)

	local btn = 	GroupButtonBase:create(self.ui:getChildByPath('btn'))

    if self.bIsOldSaiji then
        btn:setString('领取')
    else
	    if Misc:isSupportShare() then
		    btn:setString('领取并炫耀')
	    else
		    btn:setString('领取')
	    end
    end

	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end

        local bShare = true
        if self.bIsOldSaiji then
            bShare = false
        end

		self:onCloseBtnTapped(bShare)
	end)

    local function createTitleLabel( str )
        local label = TextField:create(str, nil, 36)
        label:setAnchorPoint(ccp(0, 0))
        return label
    end

    local lastRank = rrMgr:getData():getLastRank() or 0


    if lastRank > 0 then

        local label1 = createTitleLabel('第  ')
        local label2 = createTitleLabel('  名')
        local rankLabel = BitmapText:create(tostring(lastRank), "fnt/race_rank.fnt")
        rankLabel:setAnchorPoint(ccp(0, 0))

        local titleLayer = Layer:create()
        titleLayer:addChild(label1)
        titleLayer:addChild(rankLabel)
        titleLayer:addChild(label2)

        local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
        layoutUtils.horizontalLayoutItems({
            {node = label1},
            {node = rankLabel},
            {node = label2},
        })

        UIHelper:move(rankLabel, 0, -12)

        self.ui:addChild(titleLayer)

        titleLayer:setPositionX(480 - titleLayer:getGroupBounds(self.ui).size.width/2)
        titleLayer:setPositionY(-360)

        UIHelper:move(paoAnim, 0, -50)
        UIHelper:move(animalAnim, 0, -50)
        UIHelper:move(self.ui:getChildByPath('btn'), 0, -50)

    end
end


function RankRaceDanSharePanel:createSharePicture( url )

    local sharePicture = SharePicture.new()
    sharePicture:setBackgroundByPathname('share/rank_race_dan.jpg')
    local dan = RankRaceMgr:getInstance():getData():getDan()
    local text = localize('rank.race.img.share.title.' .. dan)
    local label = BitmapText:create(text, 'fnt/newzhousai_share.fnt')
    label:setAnchorPoint(ccp(0.5, 0.5))
    sharePicture:addChild(label)
    label:setPosition(ccp(360, -60))
    label:setRotation(-4.7)

    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    sharePicture:buildQRCode(url, 170, ccp(25+179/2, -497-179/2 + 2), 0)
    local path, thumb = sharePicture:capture()
    sharePicture:dispose()
    return path, thumb
end


function RankRaceDanSharePanel:share( ... )
	if self.isDisposed then return end


	DcUtil:UserTrack({
        category='weeklyrace2018', 
        sub_category='weeklyrace2018_get_rank_reward',
        t1 = rrMgr:getData():getDan(),
    })


	local shareCallback = {
        onSuccess = function(result)
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享成功', 'positive')
            end
        end,
        onError = function(errCode, errMsg)
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享失败')
            end
        end,
        onCancel = function()
            if callback then
                callback()
            end
            if __IOS or WXJPPackageUtil.getInstance():isWXJPPackage() then
                CommonTip:showTip('分享取消')
            end
        end,
    }


    local uid = UserManager.getInstance().user.uid

    local url = Misc:buildURL(NetworkConfig:getShareHost(), 'week_upgrade.jsp', {
        pid = StartupConfig:getInstance():getPlatformName() or '',
        game_name = 'Rank_race_share',
        aaf = 5,
        uid = uid,
        index = rrMgr:getData():getDan()
    })

    RankRaceHttp:getShortUrl(url, function ( url )

    	if __WIN32 or (__ANDROID and (not WXJPPackageUtil.getInstance():isWXJPPackage())) then
    	    local path, thumbPath = self:createSharePicture(url)

    	    local title = localize('rank.race.danshare.share.title')
            local message = localize('rank.race.danshare.share.message')
    	    message = message .. url

    		if __WIN32 then
        	    shareCallback.onSuccess()
            	return
        	end
            if not SnsProxy:isWXAppInstalled() then
                setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
                return
            end
        	local androidShareType = 8
    		AndroidShare.getInstance():registerShare(androidShareType)
    	    SnsUtil.sendImageMessage(androidShareType, title, message, thumbPath, path, shareCallback, true, gShareSource.WEEKLY_MATCH)
    	else
            if not SnsProxy:isWXAppInstalled() then
                setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
                return
            end
    	    local eShareType = SnsUtil.getShareType()
    	    local title = localize('rank.race.danshare.share.title')
            local message = localize('rank.race.danshare.share.message')
            local thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/rank_race_dan.jpg")
    	    local isSend2FriendCircle = false
    	    SnsUtil.sendLinkMessage(eShareType, title, message, thumbUrl, url, isSend2FriendCircle, shareCallback)
    	end
    end)

end

function RankRaceDanSharePanel:fly( callback )
	if self.isDisposed then return end
	-- body

	if self.flying then
		return
	end

	self.flying = true

	local counter = #self.refNodes + 1

	local function onEnd( ... )
		counter = counter - 1
		if counter <= 0 then
			if callback then
				callback()
				callback = nil
			end
		end
	end

	for i = 1, 6 do

		if self.refNodes[i]  then
			if ItemType:isHeadFrame(self.refNodes[i].userData.itemId) then
				onEnd()
			else
				local bounds = self.refNodes[i]:getGroupBounds()
				local anim = FlyItemsAnimation:create(
					Misc:clampRewardsNum(
						{{itemId = self.refNodes[i].userData.itemId, num = self.refNodes[i].userData.num}}
					)
				)

				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:setFinishCallback(onEnd)
				anim:play()
			end
		end
	end

	onEnd()

end

function RankRaceDanSharePanel:dispose( ... )
	-- body
	BasePanel.dispose(self, ...)

	for _, v in ipairs(self.refNodes or {}) do
		v:dispose()
	end
end

function RankRaceDanSharePanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)

    HeadFrameType:checkShowHeadFrameGotPanel()
end

function RankRaceDanSharePanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
	self:popoutShowTransition()
end

function RankRaceDanSharePanel:onCloseBtnTapped( needShare )
	if self.isDisposed then return end


	self:fly(function ( ... )
    	if self.isDisposed then return end
    	if Misc:isSupportShare() then
    		if needShare then
        		self:share()
        	end
        end
        self:_close()
    end)
end

function RankRaceDanSharePanel:popoutShowTransition( ... )
    if self.isDisposed then return end

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, 5)
end

return RankRaceDanSharePanel
