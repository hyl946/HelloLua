

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 2日 10:31:56
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.EventDispatcher"

---------------------------------------------------
-------------- Utility Function
---------------------------------------------------

local previousSettedConfig	= false

-- ------------------------------------------------
-- setConfig Called In Configuration File, 
-- With The Configurations In A Table Parameter.
-- ------------------------------------------------

function setConfig(configTable, ...)
	assert(configTable)
	assert(#{...} == 0)

	assert(not previousSettedConfig, "UIConfigManager: setConfig Already Called !")
	previousSettedConfig = configTable
	if previousSettedConfig then
		local scale = previousSettedConfig.panelScale or 1
		previousSettedConfig.panelScale = math.min(scale, 1)
	end
end

local function loadConfigFile(fileName, ...)
	assert(fileName)
	assert(#{...} == 0)

	require(fileName)

	if not previousSettedConfig then assert(false,"UIConfigManager: Has No Config In File " .. fileName .. " !")	end
	local configTable	= previousSettedConfig
	previousSettedConfig	= false

	return configTable
end

---------------------------------------------------
-------------- UIConfigManager
---------------------------------------------------

local sharedInstance = false

assert(not UIConfigManager)
UIConfigManager = class()

function UIConfigManager:init(...)
	assert(#{...} == 0)

	self.config = loadConfigFile("zoo.config.ui.config")
end

function UIConfigManager:getConfig(...)
	assert(#{...} == 0)

	assert(self.config)
	return self.config
end

function UIConfigManager:sharedInstance(...)
	assert(#{...} == 0)

	if not sharedInstance then
		sharedInstance = UIConfigManager.new()
		sharedInstance:init()
	end

	return sharedInstance
end
