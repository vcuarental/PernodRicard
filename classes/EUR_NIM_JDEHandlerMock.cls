@isTest
global class EUR_NIM_JDEHandlerMock implements HttpCalloutMock 
{
    global static String methodName;

	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String responseSOAP = '';
        if(methodName == 'calculatePrice')
        {
	        responseSOAP = '<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns0:getPriceCatalogueResponse xmlns:ns0="http://oracle.e1.bssv.JP56LA10/"><e1MessageList /><priceCatalogueDetails><quantityOrdered>3</quantityOrdered><secondItemNumber>70509700</secondItemNumber><unitPrice>12.713333333333333333</unitPrice></priceCatalogueDetails></ns0:getPriceCatalogueResponse></S:Body></S:Envelope>';
        }
        else if(methodName == 'calculateInventory')
        {
	        responseSOAP = '<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">  <S:Body><ns0:getCalculatedAvailabilityResponse xmlns:ns0="http://oracle.e1.bssv.JP410000/"><item><itemCatalog>5097</itemCatalog><itemId>70509700</itemId><itemProduct>70509700</itemProduct></item><showCalculatedAvailability><availabilityDetails><availableQuantity><value>99218</value></availableQuantity></availabilityDetails></showCalculatedAvailability></ns0:getCalculatedAvailabilityResponse></S:Body></S:Envelope>';
        }
		res.setBody(responseSOAP);
        return res;
  	}
}