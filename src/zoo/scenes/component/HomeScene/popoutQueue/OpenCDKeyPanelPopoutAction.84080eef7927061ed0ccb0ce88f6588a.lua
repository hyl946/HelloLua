
OpenCDKeyPanelPopoutAction = class(HomeScenePopoutAction)

function OpenCDKeyPanelPopoutAction:ctor()

end

function OpenCDKeyPanelPopoutAction:popout( ... )
    local function closeCallback( ... )
        self:next()
    end

    local function showNoNetworkTip( ... )
		local tip = Localization:getInstance():getText("forcepop.tip3")
		CommonTip:showTip(tip,"negative",closeCallback,3)
    end

    if __IOS and not ReachabilityUtil.getInstance():isNetworkAvailable() then
		showNoNetworkTip()
		return    	
    end

	RequireNetworkAlert:callFuncWithLogged(function( ... )
		local panel = CDKeyPanel:create(ccp(0,0))
		panel:registerCloseCallback(closeCallback)
		panel:popout()

	end,function ( ... )
		showNoNetworkTip()

	end, kRequireNetworkAlertAnimation.kDefault,kRequireNetworkAlertTipType.kNoTip)

end


function OpenCDKeyPanelPopoutAction:getConditions( ... )
    return {"enter","enterForground","preActionNext"}
end