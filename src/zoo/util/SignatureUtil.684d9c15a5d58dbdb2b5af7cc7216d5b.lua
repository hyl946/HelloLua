SignatureUtil = {}

local validHashList = {
	he = "5dcb784f6910bc0b60c99b39da7ff8e4", -- AndroidGame.keystore
	cmgame = "99edee65c6504e7576627b5cf9974daa",	-- CMGame 
	debug = "8e0871a4e699510903e17f0fa396bf87",	-- debug.keystore
	mi = "93e96101aa668b672382e621b2696729", -- mi pad
	cmgame_backup = "7fe545503fd02f2ac5861924e1c7156a",	-- CMGame back up 
}

if __ANDROID then 
	local _arr_class = luajava.bindClass("java.lang.reflect.Array")
	local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	local PackageManager = luajava.bindClass("android.content.pm.PackageManager")

	function SignatureUtil:array2Table(arr)
    	local result = {}
      	local len = _arr_class:getLength(arr)
      	for i = 1, len do
        	result[#result + 1] = _arr_class:get(arr, i - 1)
      	end
      	return result
    end

	function SignatureUtil:getDefaultCmPayment( packageName )
		local list = {}
		local function safeGetSignature()
			local context = MainActivityHolder.ACTIVITY
			local packageManager = context:getPackageManager()
			local info = packageManager:getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
			if info ~= nil then
				local signatures = SignatureUtil:array2Table(info.signatures) 
				--if _G.isLocalDevelopMode then printx(0, "Signature1:"..table.tostring(signatures)) end
				for i, v in ipairs(signatures) do
					local signature = v:toCharsString()
					local md5 = HeMathUtils:md5(signature)
					table.insert(list, md5)
					--if _G.isLocalDevelopMode then printx(0, "Signature2:"..signature) end
					if _G.isLocalDevelopMode then printx(0, "Signature3:"..md5) end
				end
			end
		end
		pcall(safeGetSignature)
		for i,signature in ipairs(list) do
			for j,hash in pairs(validHashList) do
				if signature == hash then
					if j == "cmgame" then
						return 9
					elseif j == "he" then
						local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
						local mmiapUrl = MainActivityHolder.ACTIVITY:getClassLoader():getResource("mmiap.xml")
						local sDataUrl = MainActivityHolder.ACTIVITY:getClassLoader():getResource("assets/libmegbpp_02.02.16_00.so")
						if not mmiapUrl and not sDataUrl then
							return 1
						end
					end
					return nil 
				end
			end
		end
		return nil
	end
else
	function SignatureUtil:getDefaultCmPayment( packageName )
	end
end