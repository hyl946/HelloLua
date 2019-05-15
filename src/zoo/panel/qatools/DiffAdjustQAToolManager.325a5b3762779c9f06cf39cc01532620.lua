require "zoo.panel.qatools.QAToolTestCodePanel"
require "zoo.panel.qatools.DiffAdjustQAToolPanel"

DiffAdjustQAToolManager = {}

function DiffAdjustQAToolManager:init(testInfo)	
	self.toolsEnabled = false
	if MaintenanceManager:getInstance():isEnabled("QAInLevelTools") then

		if testInfo then
				
			local pars = string.split( testInfo , ";" )

			for k,v in ipairs(pars) do

				local arr = string.split( v , "_" )

				if arr[1] == "DiffAdjustQATool" then
					self.toolsEnabled = true
				end
			end
		end
	end
end

function DiffAdjustQAToolManager:getToolsEnabled()
	return self.toolsEnabled
end

function DiffAdjustQAToolManager:openPanel()

	if not self.toolsEnabled then return end
	if self.toolPanel then return end

	local toolPanel = DiffAdjustQAToolPanel:create( function () self:onToolPanelClose() end)
	toolPanel:popout()

	self.toolPanel = toolPanel
end

function DiffAdjustQAToolManager:onToolPanelClose()
	self.toolPanel = nil
end

function DiffAdjustQAToolManager:print( channel , ... )

	if not self.toolsEnabled then return end
	
	if not channel or type(channel) ~= "number" then
		assert( false , "DiffAdjustQAToolManager:print  channel must be number !!!!!!!!!!!!!!!!!!")
	end
	printx( channel , ... )

	self:addLogs( channel , ... )
end

function DiffAdjustQAToolManager:addLogs( channel , ... )
	if not self.logData then
		self.logData = {}
		self.logData.logs = {}
	end

	local logs = self.logData.logs
	local lastLog = logs[#logs]
	local lastIndex = 0
	if lastLog then
		lastIndex = lastLog.id
	end

	local dataStrArr = {}
	local dataStr = ""

	local tmpLen = select( "#", ...)

	for i = 1 , tmpLen do
		local v = select( i , ...)

		if v == nil then
			v = "nil"
		end
		
		dataStrArr[i] = tostring(v)
		dataStr = dataStr .. " " .. tostring(v)
	end

	table.insert( logs , { id = tonumber(lastIndex + 1) , channel = channel , txt = dataStr } )
	if #logs > 500 then
		table.remove( logs , 1 )
	end

end

function DiffAdjustQAToolManager:getLogs( channel )
	return self.logData
end

function DiffAdjustQAToolManager:clearLogs( channel )
	self.logData = {}
	self.logData.logs = {}
end

function DiffAdjustQAToolManager:updateUserGroup( groupInfo )

	self.userGroupInfo = groupInfo

end

function DiffAdjustQAToolManager:getUserGroup()
	return self.userGroupInfo
end

-- DiffAdjustQAToolManager:init()