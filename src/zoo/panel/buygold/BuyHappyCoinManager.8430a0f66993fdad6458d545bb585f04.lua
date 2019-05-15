BuyHappyCoinManager = {}

function BuyHappyCoinManager:getShowConfig(grade, cash)
	local itemIndex = 1
	if grade and type(grade) == "number" and grade >=10 and grade <= 50 then 
		itemIndex = grade/10
	elseif cash then 
		if cash <= 100 then 
			itemIndex = 1
		elseif cash > 100 and cash <= 250 then 
			itemIndex = 2
		elseif cash > 250 and cash <= 650 then 
			itemIndex = 3
		elseif cash > 650 and cash <= 1000 then 
			itemIndex = 4
		elseif cash > 1000 then 
			itemIndex = 5
		end
	end
	return itemIndex
end

function BuyHappyCoinManager:getCurrencySymbol(locale)
	local currencySymbolLabel = ""  --CNY
	if __ANDROID or __WIN32 then 
		currencySymbolLabel = "buy.gold.panel.money.mark" --CNY
	end
	local isLongSymbol = false
	if locale and type(locale) == "string" then 
		locale = string.lower(locale)
		if locale == "cny" then  
			currencySymbolLabel = "buy.gold.panel.money.mark" --CNY
		elseif locale == "usd" then 			--(United States Dollar)美元
			currencySymbolLabel = "$" 		
		elseif locale == "gbp" then  		--(GreatBritain Pound)英镑
			currencySymbolLabel = "£" 
		elseif locale == "hkd" then 		--(HongKong Dollar)港元
			currencySymbolLabel = "HK$" 
			isLongSymbol = true
		elseif locale == "twd" then 
			currencySymbolLabel = "NT$" 
			isLongSymbol = true
		elseif locale  == "eur" then 
			currencySymbolLabel = "€" 
		elseif locale == "jpy" then 		--JPY(Japanese Yen)日元
			currencySymbolLabel = "buy.gold.panel.money.mark" 
		end
	end
	return Localization:getInstance():getText(currencySymbolLabel) , isLongSymbol
end