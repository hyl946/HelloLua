

local defaultChannelIds = { "0" , "-1" , "-2" , "-3" , "-4" , "-6","-99"}


local printxUserData = {	
	
	["-99"] = { headStr = "[LuaCrash] " , level = "normal" } ,			--LuaCrash
    ["-98"] = { headStr = "[DC] ", level = "normal" },		--boyang
    ["-97"] = { headStr = "[RESO] ", level = "normal" },		--boyang
	["-8"] = { headStr = "[Region] " , level = "normal" } ,            	--touch region collect
	["-7"] = { headStr = "[ActivityFrame] " , level = "normal" } ,            	--活动框架打印
	["-6"] = { headStr = "[TestTools] " , level = "normal" } ,            	--测试工具打印
	["-5"] = { headStr = "[Guides] " , level = "normal" } ,            	--引导框架	
	["-4"] = { headStr = "" , level = "normal" } ,            			 --同步打印RemoteDebug	
	["-3"] = { headStr = "[Payment] " , level = "normal" } ,             --通用支付相关
	["-2"] = { headStr = "[UI] " , level = "normal" } ,					--底层UI框架相关
	["-1"] = { headStr = "[GamePlay] " , level = "normal" } ,			--关卡内核心逻辑相关

	["0"] = { headStr = "" , level = "normal" } ,						--默认，原print方法将输出到此channel

	["1"] = { headStr = "[Reast] " , level = "normal" } ,				--reast.li
	["2"] = { headStr = "[Dan] " , level = "normal" } ,					--dan.liang
	["3"] = { headStr = "[WenKan] " , level = "normal" } ,				--wenkan.zhou
	["4"] = { headStr = "[LHL] " , level = "normal" } ,					--honglin.liu
	["5"] = { headStr = "[jinghui.hu] " , level = "normal" } ,			--jinghui.hu
	["7"] = { headStr = "[Zhijian] " , level = "normal" } ,				--zhijian.li
	["8"] = { headStr = "[niu2x] " , level = "normal" } ,				--xiaorong.niu
	["9"] = { headStr = "[DN] " , level = "normal" } ,					--ding.ning
	["10"] = { headStr = "[DZHOU] " , level = "normal" } ,					--zhou.ding
	["11"] = { headStr = "[+ + + Jing + + +] ", level = "normal" },		--jing.shao
    ["12"] = { headStr = "[zhigang] ", level = "normal" },		--zhigang
    ["13"] = { headStr = "[---BY] ", level = "normal" },		--boyang
    ["14"] = { headStr = "[--CY--] ", level = "normal" },		--caoyuan

}

if not printxContext then
	printxContext = {}
	printxContext.oringinPrint = nil
	printxContext.currChannelIds = defaultChannelIds
end

--[[
	初始化printx
	oringinPrintFuc		 ：  系统原有的print函数
	channelId    		 ：  通道id，可为number，也可以table，最后都会被转为table，包含在table中的channel才会被输出。
	openAllSystemPrint	 ：  默认带上系统输出，此参数为true的话，无论channelId传入什么，最后都会自动带上defaultChannelIds里的channelId
]]
initPrintx = function ( oringinPrintFuc , channelId , openAllSystemPrint )

	printxContext.oringinPrint = oringinPrintFuc

	if type(channelId) == "table" then

		local arr = channelId
		channelId = {}
		for k,v in pairs(arr) do
			table.insert( channelId , tostring(v) )
		end

	elseif type(channelId) == "string" or type(channelId) == "number"  then
		local str = tostring(channelId)
		channelId = {}
		table.insert( channelId , str )
	end

	printxContext.currChannelIds = channelId

	if openAllSystemPrint then
		for k,v in pairs(defaultChannelIds) do
			if not table.indexOf( printxContext.currChannelIds , tostring(v) ) then
				table.insert( printxContext.currChannelIds , tostring(v) )
			end
		end
	end
end

printx = function ( channel , ...)
		
	if table.indexOf( printxContext.currChannelIds , tostring(channel) ) then

		local pd = printxUserData[tostring(channel)]
		local hstr = nil

		local tmp = {}
		local tmpLen = select( "#", ...)

		if pd then
			hstr = pd.headStr
		else
			hstr = " "
		end

		for i = 1 , tmpLen do
			local v = select( i , ...)

			if i == 1 then
				v = hstr .. tostring(v)
			else
				if v == nil then
					v = "nil"
				end
			end
			
			tmp[i] = tostring(v)
		end

		if(printxContext.oringinPrint) then
			if __WIN32 then
				local path = HeResPathUtils:getUserDataPath() .. '/console.txt'
				local file = io.open(path, 'a')
				if file then
					file:write( unpack(tmp) )
					file:write( "\n" )
					file:close()
				end
			end


			printxContext.oringinPrint( unpack(tmp) )
		else
			print( unpack(tmp) )
		end
	end
	
	if _G.printForGameConsole then
		_G.printForGameConsole(channel,...)
	end
end

if __WIN32 then
	local path = HeResPathUtils:getUserDataPath() .. '/console.txt'
	local file = io.open(path, 'w')
	file:write( "\n" )
	file:close()
end

if _G.isLocalDevelopMode then
	local G_traceback_file = HeResPathUtils:getUserDataPath() .. '/log_'..os.date("%Y%m%d")..'.log'
	function log_file(tag, msg)
	  	local file = io.open(G_traceback_file, 'a')
		if file then
			local text = string.format("%s [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S "), tag or "info", msg)
			file:write(text)
			file:close()
		end
	end

	__ORIGIN_G__TRACKBACK__ = __ORIGIN_G__TRACKBACK__ or __G__TRACKBACK__
	function __G__TRACKBACK__(errMsg)
		log_file("error", (errMsg or "") .. "\n" .. debug.traceback())
	  	return __ORIGIN_G__TRACKBACK__(errMsg)
	end
else
	function log_file(tag, msg)
	end
end


