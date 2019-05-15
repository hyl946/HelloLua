local Track = class()

function Track:ctor( ... )
	self.name = ''
	self.target_path = nil
	self.target = nil

	self.data = {}
	self.min_frame_index = nil
	self.max_frame_index = nil
end

function Track:setName( p_name )
	self.name = p_name
end

function Track:getName( ... )
	return self.name
end

function Track:update( frame_index )
	if frame_index < self.min_frame_index then
		-- frame_index = self.min_frame_index
	elseif frame_index > self.max_frame_index then
		-- frame_index = self.max_frame_index
	else
		self:__update(frame_index)
	end

	return frame_index >= self.max_frame_index
end

function Track:setTargetPath( p_target_path )
	self.target_path = p_target_path
end

function Track:setFrameData( index, data )
	self.data[index] = data

	if not self.min_frame_index then
		self.min_frame_index = index
	end

	if not self.max_frame_index then
		self.max_frame_index = index
	end

	self.min_frame_index = math.min(index, self.min_frame_index)
	self.max_frame_index = math.max(index, self.max_frame_index)
end

function Track:setFrameDataConfig( config )
	for _, c in pairs(config) do
		self:setFrameData(c.index, c.data)
	end
end

-- function Track:clearFrameData( index )
-- 	self.data[index] = nil
-- end

function Track:getFrameData( p_index )
	return self.data[p_index]
end

function Track:getFrameDataBefore( p_index )
	for frame_index = p_index-1, self.min_frame_index, -1 do
		if self.data[frame_index] then
			return self.data[frame_index], frame_index
		end
	end
end

function Track:getFrameDataAfter( p_index )
	for frame_index = p_index+1, self.max_frame_index, 1 do
		if self.data[frame_index] then
			return self.data[frame_index], frame_index
		end
	end
end

function Track:setTarget( p_target )
	self.target = p_target
end

function Track:getTargetPath( ... )
	return self.target_path
end

function Track:dispose( ... )
	self.name = nil
	self.target_path = nil
	self.data = nil
end

function Track:copyFrom( other )

	self.name = other.name
	self.target_path = other.target_path
	self.data = table.clone(other.data)
	self.min_frame_index = other.min_frame_index
	self.max_frame_index = other.max_frame_index

end

return Track