PaymentEventDispatcher = class(EventDispatcher)

PaymentEvents = {
	kBuyConfirmPanelPay = "kBuyConfirmPanelPay",
	kBuyConfirmPanelClose = "kBuyConfirmPanelClose",
	kIosBuySuccess = "kIosBuySuccess",
	kIosBuyFailed = "kIosBuyFailed",
	kIosProductIdChange = "kIosProductIdChange",

	kBeforePanelPay = "kBeforePanelPay",
	kBeforePanelClose = "kBeforePanelClose",

	kCloseAllAndReBuy = "kCloseAllAndReBuy",
}

function PaymentEventDispatcher:ctor()
	
end

function PaymentEventDispatcher:dispatchPanelPayEvent(default_payment_type)
	self:dispatchEvent(Event.new(PaymentEvents.kBuyConfirmPanelPay, {defaultPaymentType = default_payment_type}, self))
end

function PaymentEventDispatcher:dispatchPanelCloseEvent()
	self:dispatchEvent(Event.new(PaymentEvents.kBuyConfirmPanelClose, {}, self))
end

function PaymentEventDispatcher:dispatchIosBuySuccess()
	self:dispatchEvent(Event.new(PaymentEvents.kIosBuySuccess, {}, self))
end

function PaymentEventDispatcher:dispatchIosBuyFailed(err_code, err_msg)
	self:dispatchEvent(Event.new(PaymentEvents.kIosBuyFailed, {errCode = err_code, errMsg = err_msg}, self))
end

function PaymentEventDispatcher:dispatchIosProductIdChange(new_productId)
	self:dispatchEvent(Event.new(PaymentEvents.kIosProductIdChange, {newProductId = new_productId}, self))
end

function PaymentEventDispatcher:dispatchBeforePanelPayEvent(sign_choose)
	self:dispatchEvent(Event.new(PaymentEvents.kBeforePanelPay, {signChoose = sign_choose}, self))
end

function PaymentEventDispatcher:dispatchBeforePanelCloseEvent(sign_choose, default_payment_type)
	self:dispatchEvent(Event.new(PaymentEvents.kBeforePanelClose, {signChoose = sign_choose, defaultPaymentType = default_payment_type}, self))
end

function PaymentEventDispatcher:dispatchCloseAllAndReBuyEvent()
	self:dispatchEvent(Event.new(PaymentEvents.kCloseAllAndReBuy, {}, self))
end