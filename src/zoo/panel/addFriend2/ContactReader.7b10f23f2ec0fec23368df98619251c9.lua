local IOSContactReaderDelegate = class()

function IOSContactReaderDelegate:readContact(callback)

	waxClass{"ReadContactCallback",NSObject,protocols={"ContactReaderCallback"}}
	function ReadContactCallback:onSuccess(result)
		if _G.isLocalDevelopMode then printx(0, "type of result: "..tostring(type(result))) end
		if _G.isLocalDevelopMode then printx(0, "contact list: "..tostring(result)) end
		assert(type(result) == "string", "contact list must be a jsonstring!!!!!!!!" )

		--local resultStr = string.format("type of result: %s, contact list: %s", tostring(type(result)), tostring(result))

		--CommonTip:showTip(resultStr,"negative", nil, 10)

		local resultContacts = table.deserialize(result) or {}
		if _G.isLocalDevelopMode then printx(0, "contactList from json: "..table.tostring(resultContacts)) end

		local contactMap = {}

		if result then
			for k,v in pairs(resultContacts) do
				local formatedPhone = k:gsub("-", "")
				formatedPhone = formatedPhone:gsub(" ", "")
	        	formatedPhone = formatedPhone:gsub("+86", "")
				if tonumber(formatedPhone) then
					contactMap[formatedPhone] = v
				end
			end
		end
		if _G.isLocalDevelopMode then printx(0, "ReadContactCallback:onSuccess, result: ", table.tostring(contactMap)) end
		if self.callback then self.callback.onSuccess(contactMap) end
	end

	function ReadContactCallback:onFailed(result)
		assert(type(result) == "string", "contact list must be a jsonstring!!!!!!!!" )
		local errResult = table.deserialize(result) or {}
		if _G.isLocalDevelopMode then printx(0, "ReadContactCallback:onFailed: ", errResult.errorCode) end
		if self.callback then self.callback.onFailed(errResult.errorCode) end
	end
	
	function ReadContactCallback:onCancel()
		if _G.isLocalDevelopMode then printx(0, "ReadContactCallback:onCancel") end
		if self.callback then self.callback.onCancel() end
	end

	local readContactCallback = ReadContactCallback:init()
	readContactCallback.callback = callback

	ContactReader:readContact(readContactCallback)
end

local AndroidContactReaderDelegate = class()

function AndroidContactReaderDelegate:readContact(callback)
	    local javaCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function(data) 
	        	local phoneNumber2NameMap = luaJavaConvert.map2Table(data)

	        	local filteredMap = {}
	        	for k,v in pairs(phoneNumber2NameMap) do
	        		if _G.isLocalDevelopMode then printx(0, "contactList retrived2, phoneNO: "..tostring(k)..", name:"..tostring(v)) end
	        		local phoneNumber = k:gsub("-", "")
	        		phoneNumber = phoneNumber:gsub(" ", "")
	        		phoneNumber = phoneNumber:gsub("+86", "")
	        		if tonumber(phoneNumber) then
	        			filteredMap[phoneNumber] = v
	        		end
	        	end
	        	if _G.isLocalDevelopMode then printx(0, "contactList filtered, : "..table.tostring(filteredMap)) end
	        	if callback.onSuccess then
	        		callback.onSuccess(filteredMap)
	        	end
	        end,
	        onError = function()
	        	if callback.onError then
	        		callback.onError(100)
	        	end
	        	--CommonTip:showTip("读取联系人信息失败！","negative")
	        end,
	        onCancel = function()
	        	if callback.onCancel then
	        		callback.onCancel()
	        	end
	    	end
	    })

		local contactReader = luajava.newInstance("com.happyelements.hellolua.ContactReader")
		contactReader:registerCallback(javaCallback)
		contactReader:readContact()
end

local Wp8ContactReaderDelegate = class()

function Wp8ContactReaderDelegate:readContact(callback)
	local n = ""
	local function findAll( i )
		n = n .. i
	end

	local contactlistInPhone = {}
	local function wp_callback( err, data )
		for k,v in pairs(data) do
			n = ""
			v:gsub("%d+", findAll)
			contactlistInPhone[n] = k
		end

		if callback.onSuccess then
			callback.onSuccess(contactlistInPhone)
		end
	end

	Wp8Utils:ReadContacts(wp_callback)
end

local Win32ContactReaderDelegate = class()

function Win32ContactReaderDelegate:readContact(callback)
			--fake data for win32 debug display
		local fakePhoneList = {
								"15311419018",
								"15001058075",
								"15311419016",
								"15101092222",
								"18600464043",
								"18612708905",
								"15101094555",
								"15101094529",
								"15201484763",
								"13581780194",
								"13345678901",
								"15101094528",
								"13581780184",
								"18401211967",
								"13581780144",
								"15101094523",
								"15101094522",
								"15201484765",
								"18600786044",
								"15811198371",
								"18310059425",
								"18611974951",
								"15101094521",
								"15200000000",
								"15201484764",
								"18627741955",
								"16388888888",
								"15311419017",
								}

		local contactlistInPhone = {}
		for i,v in ipairs(fakePhoneList) do
			contactlistInPhone[v] = "tao.zeng"..i
		end

		if callback.onSuccess then
			callback.onSuccess(contactlistInPhone)
		end
end

if __IOS then
	return IOSContactReaderDelegate
elseif __ANDROID then
	return AndroidContactReaderDelegate
elseif __WP8 then
	return Wp8ContactReaderDelegate
else
	return Win32ContactReaderDelegate
end
