require "zoo.net.Localhost"
require 'zoo.common.FAQ'
require "zoo.panel.UserBanPanel"

UserBanLogic = class()

local localData = nil
local localDataKey = nil


local function checkByLocalData( datas , callback  )
	if datas and datas.reason and datas.type then
    	if callback then
			callback( true , datas )
		end
    	return true
    else
    	if callback then
			callback( false )
		end
    	return false
    end
end

function UserBanLogic:getUserBanData()
	return localData
end

function UserBanLogic:onContact()
	if PrepackageUtil:isPreNoNetWork() then
        PrepackageUtil:showInGameDialog()
    else
        if __WP8 then
            Wp8Utils:ShowMessageBox("QQ群: 114278702(满) 313502987\n联系客服: xiaoxiaole@happyelements.com", "开心消消乐沟通渠道")
        else
            -- FAQ:openFAQClientIfLogin() -- http://ff.happyelements.com/index.php/topic/view/675437
            FAQ:openFAQClient('http://fansclub.happyelements.com/fans/faq.php?first=ask&index1=4', 3, true)
        end
    end
end

function UserBanLogic:onCloseGame()
	if __ANDROID then
		require "zoo.platform.VivoPlatform"
		VivoPlatform:onEnd()
	end
	CCDirector:sharedDirector():endToLua()
end

function UserBanLogic:checkBan( errorCode , callback)
	-- printx( 1 , "    BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB   " , errorCode , type(errorCode) )

	if not errorCode or tostring(errorCode) ~= "109" then
		if callback then
			callback( false )
		end
		return false
	end

	local uid = UserManager.getInstance().uid or "12345"

	if not localData then
		local platform = UserManager.getInstance().platform
		localDataKey = "userBanData_" .. tostring(platform) .. "_u_".. tostring(uid) .. ".ds"

		printx( 1 , "     localDataKey " , localDataKey)

		localData = Localhost:readFromStorage(localDataKey)
		if not localData then
			localData = {}
		end
	end

	local sign = HeMathUtils:md5( tostring(uid) .. "fdkslaj18928y3hf8cnYsjflejafeiurwMfVGw75ynPFafearware" )

    --local url = "http://10.130.136.61/" .. "getRecentValidUserBan?"
	local url = NetworkConfig.dynamicHost .. "getRecentValidUserBan?"

	--url = url .. "uid=16&sign=32da15b3e4bcd13f8745206d82615d0c"
	url = url .. "uid=" .. tostring(uid) .. "&sign=" .. tostring(sign)
	printx( 1 , "   sign " , sign)

    local request = HttpRequest:createPost(url)
    request:setConnectionTimeoutMs(4 * 1000)
    request:setTimeoutMs(8 * 1000)

    request:addHeader("Content-Type:application/octet-stream")
    --local bytes = "uid=102546812"
    --request:setPostData(bytes, bytes:len())

    local callbackHanler       -- 必须前置声明，否则在闭包本身内访问为nil
    callbackHanler = function(response)

    	-- printx( 1 , "   WTFWTWFTWFTWFWTFWTFW   " , response.httpCode)
    	-- printx( 1 , "   WTFWTWFTWFTWFWTFWTFW   " , response.body)

    	local datas = UserBanLogic:getUserBanData()

    	if response.httpCode == 200 then
    		if response.body then
    			local responseData = table.deserialize(response.body)
    			printx( 1 , "    response.body = " , table.tostring( responseData ))

    			datas.reason = responseData.reason
    			datas.type = responseData.type
    			datas.day = responseData.day
    			datas.endTime = responseData.endTime
    			datas.valid = responseData.valid

    			Localhost:writeToStorage( datas , localDataKey )

    			return checkByLocalData( datas , callback )
    		end
    	else
    		return checkByLocalData( datas , callback )
    	end
    end
    
    if PrepackageUtil:isPreNoNetWork() then

        return checkByLocalData( UserBanLogic:getUserBanData() , callback )
        
    else
        HttpClient:getInstance():sendRequest(callbackHanler, request)
    end
end

function UserBanLogic:banSmsPay()
    local smsPayTypeTable = {
        Payments.CHINA_MOBILE,
        Payments.CHINA_MOBILE_GAME,
        Payments.CHINA_UNICOM,
        Payments.CHINA_TELECOM,
        Payments.UMPAY,
    }
    for i,v in ipairs(smsPayTypeTable) do
        local payment = PaymentBase:getPayment(v)
        if payment then 
            payment:setEnabled(false)
        end
    end
end