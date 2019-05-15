local PhotoPicker = require 'zoo.photoPicker.PhotoPicker'

local AndroidPhotoImp = class(PhotoPicker)

function AndroidPhotoImp:ctor( ... )
	local photoCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = function (result)
            local ret = luaJavaConvert.map2Table(result)
            local pathname = ret.pathname
            if pathname then
            	self:onSuccess(pathname)
            else
            	self:onCancel()
            end
        end,
        onError = function (code, errMsg)
            
            self:onFail(code, errMsg)

        end,
        onCancel = function ()
            self:onCancel()
        end
    });

    
    local PhotoUtils = luajava.bindClass("com.happyelements.android.photo.v2.PhotoUtils")
    PhotoUtils:setCallback(photoCallback)
end

function AndroidPhotoImp:takePhoto( width, height, onSuccess, onFail, onCancel )
    local function doTakePhoto()
        local PhotoUtils = luajava.bindClass("com.happyelements.android.photo.v2.PhotoUtils")
        PhotoUtils:setCropSize(width, height)
        self:setCallback(onSuccess, onFail, onCancel)
        PhotoUtils:takePhoto() 
    end

    PermissionManager.getInstance():requestEach(PermissionsConfig.CAMERA, doTakePhoto, onFail)
end

function AndroidPhotoImp:selectPhoto( width, height, onSuccess, onFail, onCancel )
    local function doSelectPhoto()
        local PhotoUtils = luajava.bindClass("com.happyelements.android.photo.v2.PhotoUtils")
        PhotoUtils:setCropSize(width, height)
        self:setCallback(onSuccess, onFail, onCancel)
        PhotoUtils:selectPhoto()    
    end
    
    PermissionManager.getInstance():requestEach(PermissionsConfig.READ_EXTERNAL_STORAGE, doSelectPhoto, onFail)
end

return AndroidPhotoImp