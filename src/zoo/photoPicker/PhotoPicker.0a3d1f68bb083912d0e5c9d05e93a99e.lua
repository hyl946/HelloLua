local PhotoPicker = class()



function PhotoPicker:create( ... )
	if __ANDROID then
		local AndroidPhotoImp = require 'zoo.photoPicker.AndroidPhotoImp'
		local instance = AndroidPhotoImp.new()
		return instance
	else
		return PhotoPicker.new()
	end
end

function PhotoPicker:ctor( ... )
	-- body
end

function PhotoPicker:takePhoto( width, height, onSuccess, onFail, onCancel )
	-- body
end

function PhotoPicker:selectPhoto( width, height, onSuccess, onFail, onCancel )
	-- body
end

function PhotoPicker:onSuccess( pathname )
	-- body
	if self.onSuccessCallback then
		self.onSuccessCallback(pathname)
	end
	self:clearCallback()
end

function PhotoPicker:onFail( errCode, errMsg )
	-- body
	if self.onFailCallback then
		self.onFailCallback(errCode, errMsg)
	end
	self:clearCallback()

	CommonTip:showTip('拍照错误 ' .. errCode .. ' ' .. errMsg)

end

function PhotoPicker:onCancel( ... )
	-- body
	if self.onCancelCallback then
		self.onCancelCallback()
	end
	self:clearCallback()

	CommonTip:showTip('取消拍照')
end


function PhotoPicker:clearCallback()
	self.onSuccessCallback = nil
    self.onFailCallback = nil
    self.onCancelCallback = nil
end

function PhotoPicker:setCallback( s, f, c )
	self.onSuccessCallback = s
	self.onFailCallback = f
	self.onCancelCallback = c
end


return PhotoPicker