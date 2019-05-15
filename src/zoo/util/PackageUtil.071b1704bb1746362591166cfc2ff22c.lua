PackageUtil = {}

function PackageUtil.isPackageInstalled(pkgName, sucessCallBack, errorCallBack)
	if __ANDROID then
		local tempCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
                                                       onSuccess = function(installFlag) if sucessCallBack ~= nil then sucessCallBack(installFlag) end end,
                                                       onError = function() if errorCallBack ~= nil then errorCallBack() end end,
                                                       onCancel = function() if errorCallBack ~= nil then errorCallBack() end  end
                                                   })
		local pkgUtil = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
		pkgUtil:isPackageInstalled(pkgName, tempCallback)
	else
		sucessCallBack(false)
	end
end

function PackageUtil.openAppByPackage(pkgName, sucessCallBack, errorCallBack)
	-- return "这是我的消消乐号：288116495，复制这条消息，打开【开心消消乐】就能添加我为好友"
	if __ANDROID then
		local tempCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
                                                       onSuccess = function(installFlag) if sucessCallBack ~= nil then sucessCallBack(installFlag) end end,
                                                       onError = function() if errorCallBack ~= nil then errorCallBack() end end,
                                                       onCancel = function() if errorCallBack ~= nil then errorCallBack() end  end
                                                   })
		local pkgUtil = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
        pkgUtil:openAppByPackage(pkgName, tempCallback)
	elseif __IOS then
		if sucessCallBack then
			sucessCallBack(false)
		end
	else
		if sucessCallBack then
			sucessCallBack(false)
		end
	end
end