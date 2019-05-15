--检查字体映射
--flash中字体的映射是靠 addGlobalDynamicFontMap 方法添加。这里检查是否所有动态字体已全部添加映射
--[boyang.liu]

caseFontResource = class(UnittestTask)

local WIN32_RECREATE_FILE_LIST = false
local fileCount = 0

local showLog = false

function caseFontResource:ctor()
	
end

function caseFontResource:run( finished_cb )
	require "zoo.config.ResourceConfig"
	require "zoo.ResourceManager"

	local target = globalFontMap

	local ret = {}

	local function checkConfigFonts(config)
		local name = config.config
		for groupName,group in pairs(config.groups) do
			for index,node in pairs(group) do
				if node.face and node.textType == "dynamic" then
					if not ret[node.face] then
						ret[node.face]={}
						-- print("new face" .. node.face)
					end
					local key = table.concat({name,groupName,index,node.id}," - ")
					table.insert(ret[node.face],key)
				end
			end
		end
	end

	local list = self:lfs()

	local isFileNoti = CCFileUtils:sharedFileUtils():isPopupNotify()
	CCFileUtils:sharedFileUtils():setPopupNotify(false)

	local function checkPath(path)
		local f = io.open(path,"r")
		local t,size = nil,nil
		if f then
			t,size = lua_read_file(path)
		end
		if not t or size==0 then -- 解析失败
			if showLog then print("load json fail, preloadJson: "..v) end
		else
			local config = table.deserialize(t) --simplejson.decode(t)
		    checkConfigFonts(config)
	    end
	end

	ResourceManager:sharedInstance()

	fileCount = 0
	if list then
		fileCount = #list
		for k,v in ipairs(list) do
			checkPath(v)
		end
	else
		fileCount = #PanelConfigFiles
		for k,v in pairs(PanelConfigFiles) do
			local filePath = ResourceManager:sharedInstance():getMappingFilePath(v)
			local path = HeResPathUtils:getResCachePath()
			if __WIN32 then
				path = path .. "/resource"
			end
			path =  path .. '/' .. filePath
			if __WIN32 then
				path = string.gsub(path,"/" , '\\')
			end
			-- local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath) 

			checkPath(path)
		end
	end

	CCFileUtils:sharedFileUtils():setPopupNotify(isFileNoti)

	self:validate(ret, target)

	finished_cb(true,"check dynamic Font Resource success in " .. fileCount .." ui json files!")
end

--列出所有 ui 配置文件
function caseFontResource:lfs()
	--HeLuaLoader 重写加载导致无法 require dll 文件
	local path = HeResPathUtils:getResCachePath() .. '/ui'
	local fileList = nil
	if __WIN32 then
		local urlRes = HeResPathUtils:getResCachePath()
		local urlTmp = HeResPathUtils:getTmpDataPath()
		-- url = url .. '\\..\\..\\..\\ide\\ZeroBraneStudio\\bin\\clibs\\?.dll'
		-- package.cpath = package.cpath .. ";" .. url .. "?.dll"
		-- print("package.path:"..tostring(package.cpath))
		-- require("lfs")
		local target = urlRes .. "\\jsonList.tmp"
		local fileTarget = io.open(target,"r")

		if not fileTarget or WIN32_RECREATE_FILE_LIST then
			local cmd = "for /r " .. urlRes .. "\\resource\\ui %%i in (*.json) do @echo %%i >> " .. target
			local cmdFile = target .. ".cmd"

			local file = io.open(target,"w")
			file:write("")
			io.close(file)

			local file = io.open(cmdFile,"w")
			file:write(cmd)
			io.close(file)

			os.execute(cmdFile)

			if fileTarget then
				io.close(fileTarget)
			end
			fileTarget = io.open(target,"r")
		end

		fileList = fileTarget:read("*all")
	else
		--暂时不再非win机器上运行
		-- local cmd = 'find  .  -type f -regex ".*\.json" > ' .. target
		-- os.execute(cmd)

		-- io.close(fileTarget)
		-- fileTarget = io.open(target,"r")
		-- fileList = fileTarget:read("*all")
	end

	if not fileList then return nil end

	local arr = string.split(fileList,"\r\n")
	return arr
end

function caseFontResource:validate(ret, target)
	print("-----",table.tostring(ret))
	local missingFont = {}
	local msg = ""
	for k,v in pairs(ret) do
		if not target[k] then
			table.insert(missingFont,k)
			local s = "missing font:[ "..tostring(k).." ] in "..table.tostring(v) .. '\n'
			msg = msg  .. s
			if showLog then print(msg) end
		end
	end
	msg = "\n\n\n" .. msg.."ERROR >>> caseFontResource:check missing font:" .. #missingFont .. "\nin ".. fileCount .." json files.\n"

	assert(#missingFont==0,msg)
	-- table.compare(ret, target)
end
