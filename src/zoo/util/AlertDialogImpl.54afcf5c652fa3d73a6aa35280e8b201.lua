if __ANDROID then 
	AlertDialogImpl = class()
	function AlertDialogImpl:alert( title, message, button1label, button2label, button1func, button2func, cancelfunc )
		local onButton1Click = function()
			if button1func ~= nil then button1func() end
		end
		local onButton2Click = function()
			if button2func ~= nil then button2func() end
		end
		local onCancel = function()
			if cancelfunc ~= nil then cancelfunc() end
		end
		local onTextInput = function (input) end
		local buttonCallfunc = luajava.createProxy("com.happyelements.hellolua.share.IDialogCallback", 
			{onButton1Click=onButton1Click,onButton2Click=onButton2Click,onTextInput=onTextInput,onCancel=onCancel})

		local builder = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")

		if button2label == nil or button2label == "" then builder:build1ButtonDialog(title, message, button1label, buttonCallfunc)
		else builder:build2ButtonDialog(title, message, button1label, button2label, buttonCallfunc) end
	end

	function AlertDialogImpl:input( title, message, inputDefault, button1label, button2label, button1func, button2func, cancelfunc )
		local userInput = inputDefault
		local onButton1Click = function()
			if button1func ~= nil then button1func(userInput) end
		end
		local onButton2Click = function()
			if button2func ~= nil then button2func() end
		end
		local onTextInput = function (input) 
			if input ~= nil then userInput = input end
		end
		local onCancel = function()
			if cancelfunc ~= nil then cancelfunc() end
		end
		local buttonCallfunc = luajava.createProxy("com.happyelements.hellolua.share.IDialogCallback", 
			{onButton1Click=onButton1Click,onButton2Click=onButton2Click,onTextInput=onTextInput,onCancel=onCancel})

		local builder = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")

		builder:buildInputDialog(title, message, inputDefault, button1label, button2label, buttonCallfunc)
	end

	function AlertDialogImpl:toast( message )
		local builder = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
		builder:toast(message)
	end
end
return nil
