require "zoo.net.OnlineSetterHttp"
require "zoo.net.OnlineGetterHttp"
require "zoo.payment.logic.PaymentBase"

if __ANDROID then
require "zoo.payment.logic.QQWalletPayment"
require "zoo.payment.logic.AliPayment"
require "zoo.payment.logic.AliSignPayment"
require "zoo.payment.logic.AliQuickPayment"
require "zoo.payment.logic.HuaweiPayment"
require "zoo.payment.logic.QQPayment"
require "zoo.payment.logic.WechatPayment"
require "zoo.payment.logic.WechatQuickPayment"
require "zoo.payment.logic.QihooPayment"
require "zoo.payment.logic.UMPayment"
require "zoo.payment.logic.JPMidasPayment"
end