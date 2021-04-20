public with sharing class EUR_NIM_SAPHandler implements EUR_NIM_ERPHandler
{
    public EUR_NIM_SAPHandler() 
    {

    }
    
    public EUR_NIM_Service.RequestResponseWrapper doCalllout(EUR_CRM_Account__c account, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList, String serviceName)
    {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('account', account.EUR_CRM_Customer_No_ERP__c);
        gen.writeStringField('salesorg', account.EUR_CRM_Sales_Organization__c);
        gen.writeFieldName('lines');
        List<Map<String,String>> listLineItems = new List<Map<String,String>>();
        for(EUR_NIM_Service.LineItemWrapper lineItemWrapper : salesOrderLineItemList)
        {
            Map<String,String> lineItem = new Map<String,String>();
            lineItem.put('quantity', String.valueOf(lineItemWrapper.quantity));
            lineItem.put('productId', lineItemWrapper.productCode);//EUR_CRM_Article_no__c
            listLineItems.add(lineItem);
        }
        gen.writeObject(listLineItems);
        gen.writeEndObject();
        String paramString = gen.getAsString();
        system.debug('paramString: ' + paramString);
        String namedCredential = EUR_COMMON_Utils.getNamedCredential(account.EUR_CRM_Country_Code__c, serviceName);
        HttpRequest request = EUR_NIM_HttpClientService.generateRequest('POST', namedCredential, 'application/json', paramString);
        System.debug(request);

        HttpResponse response = EUR_NIM_HttpClientService.getResponse(request);
        EUR_NIM_Service.RequestResponseWrapper priceResultList = new EUR_NIM_Service.RequestResponseWrapper();
        
        //if request is successful, parse the JSON response.
        if (response.getStatusCode() == 200)
        {
            //Depending on the response we can Deserializes the JSON string
            priceResultList = (EUR_NIM_Service.RequestResponseWrapper) JSON.deserialize(String.valueOf(response.getBody()).deleteWhitespace(), EUR_NIM_Service.RequestResponseWrapper.class);             
        }
        return priceResultList;
    }

    public EUR_NIM_Service.RequestResponseWrapper calculatePrice(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        
        EUR_NIM_Service.RequestResponseWrapper result = doCalllout(account, salesOrderLineItemList, EUR_COMMON_Utils.PRICE_SERVICE);
		return result;
    }

    public List<EUR_NIM_Service.LineItemWrapper> calculateInventory(EUR_CRM_Account__c account, String urlPath, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        
        EUR_NIM_Service.RequestResponseWrapper priceResultList = doCalllout(account, salesOrderLineItemList, EUR_COMMON_Utils.INVENTORY_SERVICE);
		//if request is successful, parse the JSON response.
        if (priceResultList != null)
        {
            //Form a map based on the product id
            Map<String, EUR_NIM_Service.Lines> lineMap = new Map<String, EUR_NIM_Service.Lines>();
            List<EUR_NIM_Service.Lines> lineList = priceResultList.lines;
            for(EUR_NIM_Service.Lines line : lineList)
            {
                lineMap.put((String)line.material , line);                
            }
            for(EUR_NIM_Service.LineItemWrapper lineItemWrapper : salesOrderLineItemList)
            {
                system.debug('lineItemWrapper: ' + lineItemWrapper);
                if(lineMap.containsKey(lineItemWrapper.productCode))
                {
                    EUR_NIM_Service.Lines line = lineMap.get(lineItemWrapper.productCode);
                    lineItemWrapper.productStockInfo = line.quantity;
                    system.debug('line: ' + line);
                }
            }
        }
        return salesOrderLineItemList;
    }
}