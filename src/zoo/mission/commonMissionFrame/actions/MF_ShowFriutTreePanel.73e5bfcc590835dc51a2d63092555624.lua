MF_ShowFriutTreePanel = class()

function MF_ShowFriutTreePanel:doAction(action , context)

	local homeScene = HomeScene:sharedInstance()

	if homeScene and homeScene.fruitTreeBtn and homeScene.fruitTreeBtn.onClick and 
		type(homeScene.fruitTreeBtn.onClick) == "function" then
		homeScene.fruitTreeBtn.onClick()
	end

	--[[
	printx( 1 , "RRRRRRRRRRRR     "  , wtf , wtf.fruitTreeButton)
	local function success()
		HomeScene:sharedInstance().fruitTreeButton.wrapper:setTouchEnabled(false)
		HomeScene:sharedInstance():runAction(CCCallFunc:create(function()
			local scene = FruitTreeScene:create()
			Director:sharedDirector():pushScene(scene)
			HomeScene:sharedInstance().fruitTreeButton.wrapper:setTouchEnabled(true)
		end))
	end
	
	local function fail(err, skipTip)
		if not skipTip then CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err))) end
		if GameGuide and not NewVersionUtil:hasUpdateReward() then
			GameGuide:sharedInstance():onResult("fruitTreeButton", false)
		end
	end

	local ver = _G.bundleVersion:split(".")
	if tonumber(ver[2]) < 22 then
		if RequireNetworkAlert:popout() then
			FruitTreeSceneLogic:sharedInstance():updateInfo(success, fail)
		end
	else
		local function updateInfo()
			FruitTreeSceneLogic:sharedInstance():updateInfo(success, fail)
		end
		local function onLoginFail()
			fail(-2, true)
		end
		RequireNetworkAlert:callFuncWithLogged(updateInfo, onLoginFail)
	end
	]]
end

return MF_ShowFriutTreePanel