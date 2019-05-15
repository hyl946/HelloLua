QRManager = {}

-- generatorQRNode
-- str: 被编码的字符串
-- size: QR码的大小
-- frameNum: 边框的宽度 单位是点的大小
-- dotColor: QR码部分点的颜色
-- blankColor: QR码部分没有点的颜色
-- backgroundColor: QR码边缘的颜色，如果QR码是半透明的，底色会被此颜色影响。
function QRManager:generatorQRNode( str, size, frameNum, dotColor, blankColor, backgroundColor )
	if _G.isLocalDevelopMode then printx(0, "QRManager:generatorQRNode") end
	if _G.isLocalDevelopMode then printx(0, str) end
	if _G.isLocalDevelopMode then printx(0, size) end
	if _G.isLocalDevelopMode then printx(0, frameNum) end
	if _G.isLocalDevelopMode then printx(0, dotColor) end
	if _G.isLocalDevelopMode then printx(0, blankColor) end
	if _G.isLocalDevelopMode then printx(0, backgroundColor) end
	dotColor = ccc4FFromccc4B(dotColor or ccc4(0, 0, 0, 255))
	blankColor = ccc4FFromccc4B(blankColor or ccc4(255, 255, 255, 255))
	backgroundColor = ccc4FFromccc4B(backgroundColor or ccc4(255, 255, 255, 255))
	return QRLuaEncode:generatorQRNode(str, size, frameNum or 0, dotColor, blankColor, backgroundColor)
end

function QRManager:startQRScanning( callback, tip1, tip2 )
	if __ANDROID then
		self:androidStartQRScanning(callback, tip1, tip2)
	elseif __IOS then
		self:iosStartQRScanning(callback, tip1, tip2)
	elseif __WP8 then
		self:wp8StartQRScanning(callback, tip1, tip2)
	else
		if _G.isLocalDevelopMode then printx(0, "not support!!!") end
	end
end

function QRManager:getJavaManager( ... )
	if self.qr_java_manager == nil then
		local function GetManager()
			self.qr_java_manager = luajava.bindClass('com.happyelements.android.qrcode.QRCodeManager')
		end
		pcall(GetManager)
	end

	if self.qr_java_manager == nil then
		return {getQRScanning = function ()
			return false
		end}
	end

	return self.qr_java_manager
end

function QRManager:isQRScanning( ... )
	--only android, handle KeyBack click event
	if __ANDROID then
		return self:getJavaManager():getQRScanning()
	else
		return false
	end
end

function QRManager:wp8StartQRScanning( callback, tip1, tip2 )
	local callback_func = function ( code, result )
		if code == 1 then
			callback.onSuccess(result)
		elseif code == 2 then
			callback.onFail()
		elseif code == 3 then
			callback.onCancel()
		else
			callback.onFail()
		end
	end
	QRWP8Utils:getInstance():startQRScanning(callback_func, tip1, tip2)
end

function QRManager:onKeyBackClicked( ... )
	if __ANDROID then
		local QRCodeManager = self:getJavaManager()
		QRCodeManager:get():onKeyBackClicked()
		self.callback.onCancel()
	end
end

function QRManager:androidStartQRScanning( callback, tip1, tip2 )
	if _G.isLocalDevelopMode then printx(0, "androidStartQRScanning....") end
	local QRCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            callback.onSuccess(result)
        end,
        onError = function (code, errMsg)
           callback.onFail(code, errMsg)
        end,
        onCancel = function ()
           callback.onCancel()
        end
    });

    self.callback = callback

	local QRCodeManager = self:getJavaManager()
	QRCodeManager:startQRScanning(QRCallback, tip1, tip2)
end

function QRManager:iosStartQRScanning( callback, tip1, tip2 )
	if _G.isLocalDevelopMode then printx(0, "iosStartQRScanning....") end
	waxClass{"SimpleCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
	SimpleCallbackDelegate.onSuccess = function(self, tab) callback.onSuccess(tab.result) end
	SimpleCallbackDelegate.onFailed = callback.onFail
	SimpleCallbackDelegate.onCancel = callback.onCancel
	QRCodeReader:readQRCode_tip1_tip2(SimpleCallbackDelegate:init(), tip1, tip2)
end