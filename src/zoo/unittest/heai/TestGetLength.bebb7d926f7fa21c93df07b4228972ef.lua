-- 测试 使用单元测试
-- 计算两点距离
--add bt zhigang.niu
TestGetLength = class(UnittestTask)

local function initPos(x,y) 
    local pos = {}
    pos.x=  x
    pos.y = y
    return pos
end

function TestGetLength:ctor( ... )
	-- body
	UnittestTask.ctor(self, ...)

end

function TestGetLength:run( callback )


	--测试用例
	local dataSets = {
		{initPos(1,1), initPos(2,2), 1.414 },
		{initPos(2,3), initPos(7,4), 5.099 },
		{initPos(3,4), initPos(6,5), 3.162 },
	}

	for _, v in ipairs(dataSets) do
		if self:PosLength(v[1],v[2]) ~= v[3] then
			callback(false, 'failed on ' .. "pos1 x="..v[1].x.." y="..v[1].y.. " pos2 x="..v[2].x.." y="..v[2].y  .."length= ".. self:PosLength(v[1],v[2]))
			return
		end
	end

	callback(true, 'test GetLength successd!')
end


-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看


function TestGetLength:PosLength( p1, p2 )
    local num = math.sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y))
    return tonumber( string.format("%.3f",num) )
end


