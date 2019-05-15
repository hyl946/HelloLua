require 'hecore.class'

UnittestTask = class()

function UnittestTask:ctor()
	local info = debug.getinfo(self.run)
	self._name_ = tostring(info.source)
end

function UnittestTask:run(callback_success_message)
end

-- function UnittestTask.compareTable(s, d, path)
-- 	path = path or ''
-- 	if not s then
-- 		local m = '\nfailed\nkey: ' .. path .. '\ngot nil'
-- 		assert(false, m)
-- 	end
-- 	for k, v in pairs(d) do
-- 		if k then
-- 			local v_ = s[k]
-- 			if type(v) == "table" then
-- 				path = path .. k .. '.'
-- 				UnittestTask.compareTable(v, v_, path)
-- 			else
-- 				if v ~= v_ then
-- 					local m = '\nfailed\nkey: ' .. path .. tostring(k) .. '\nexpect ' .. tostring(v) .. '\ngot ' .. tostring(v_)
-- 					assert(false, m)
-- 				end
-- 			end
-- 		end
-- 	end
-- end
