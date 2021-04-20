/**
* @Description: custom rest service for JDE integration
* @Author: yle
* @Copyright: PARX
*/
@RestResource(urlMapping='/salesorders/*')
global class EUR_NIM_SalesOrderResource
{
    public static final String NEW_SO_STATUS = 'Order Loaded from ERP';
    /**
    * @Description: handle response for GET method, list all necessary fields for inserting sales order and line items for JDE
    */
    @HttpGet
    global static void getSalesOrderByID()
    {

        RestRequest  req = RestContext.request;
        String salesOrderID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('### Sales Order ID: ###' + salesOrderID);

        handleResponse(salesOrderID);
    }

    private static void handleExceptions(RestResponse res, Integer statusCode, String message)
    {
        res.statusCode = statusCode;
        String jsonResponse = '{"response": {"status": "Failure", "message": "'+ message + '"}}';
        res.responseBody = blob.valueOf(jsonResponse);
        return;
    }

    private static void handleResponse(String salesOrderID)
    {
        RestResponse res;
        if(Test.isRunningTest())
        {
            res = new RestResponse();  
        }
        else
        {
            res = RestContext.response;    
        }
        
        res.addHeader('Content-Type', 'application/json');

        String jsonResponse = '';
        List<EUR_CRM_Sales_Order__c> orders = [SELECT Id, Name, EUR_CRM_Date__c, EUR_CRM_Order_Status__c, EUR_CRM_Invoice_No__c, EUR_CRM_Delivery_Contact__c, 
                                                   EUR_CRM_Delivery_Street__c, EUR_CRM_Delivery_City__c, EUR_CRM_Delivery_Postal_Code__c, EUR_CRM_Country__c, 
                                                   EUR_CRM_Account__r.EUR_CRM_Customer_No__c, EUR_CRM_Account__r.EUR_CRM_Customer_Ship_To_No_ERP__c, 
                                                   EUR_CRM_Account__r.EUR_CRM_Delivery_Instructions__c, EUR_CRM_Delivery_Date__c, EUR_CRM_Country_Code__c,
                                                   EUR_NIM_DepartmentCode__c, EUR_NIM_ProjectCode__c, EUR_NIM_ReasonCode__c,
                                                   EUR_CRM_CustomerPurchaseOrder__c, EUR_CRM_Notes__c, EUR_CRM_Internal_Order_Nr_Customer__c, EUR_CRM_Order_Nr_JDE__c,
                                                   EUR_NIM_ERP_OrderType__c,EUR_NIM_OrderHoldCode__c, EUR_CRM_Contact_Person__r.Name,EUR_NIM_DeliveryTimeCode__c,
                                                   EUR_CRM_DeliveryInstruction__c, EUR_NIM_AdditionalAddressInformation__c,
                                                    (SELECT Id, EUR_CRM_Quantity__c, EUR_CRM_Unit_Type__c, EUR_CRM_Date__c, EUR_CRM_SKU_codeCT__c, EUR_CRM_DeliveryDate__c, EUR_CRM_ERP_Id__c,
                                                        EUR_CRM_FreeQuantity__c, EUR_NIM_Status__c, EUR_NIM_QuantityShipped__c, EUR_NIM_DeliveryTimeCode__c, EUR_NIM_PalletTypeCode__c,
                                                        EUR_CRM_PriceBookEntryID__r.EUR_CRM_Article_Number__c
                                                        FROM   Sales_Order_Items__r) 
                                                    FROM EUR_CRM_Sales_Order__c WHERE Id = :salesOrderID ];

        if (orders.isEmpty()) 
        {
            handleExceptions(res, 400, 'Order Id: ' + salesOrderID + ' was not found');
        }

        EUR_CRM_Sales_Order__c order = orders[0];

        List<EUR_CRM_Sales_Order_Items__c> orderItemList = order.Sales_Order_Items__r; // Causes an error
        Integer count = orderItemList.size();

        // At least 1 account was found, JSON serialize it and send it back.
        try {
            res.statusCode = 200;
            jsonResponse = buildSalesOrderJSONResponse(order);
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        } 
        catch ( Exception ex ) 
        {
            handleExceptions(res, 500, ex.getStackTraceString());
        }
    }

    private static String buildSalesOrderJSONResponse(EUR_CRM_Sales_Order__c order) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();

        gen.writeStringField('Id', order.ID);
        //gen.writeStringField('Supplier', '');
        gen.writeStringField('Affiliate', order.EUR_CRM_Country_Code__c != null ? order.EUR_CRM_Country_Code__c : '');
        //gen.writeStringField('Account', order.EUR_CRM_Account__r.EUR_CRM_Customer_Ship_To_No_ERP__c != null ? order.EUR_CRM_Account__r.EUR_CRM_Customer_Ship_To_No_ERP__c : '');

        if (order.EUR_CRM_Date__c != null) 
        {
            gen.writeDateField('OrderDate', order.EUR_CRM_Date__c);
        } 
        else 
        {
            gen.writeNullField('OrderDate');
        }
        if (order.EUR_CRM_Delivery_Date__c != null) 
        {
            gen.writeDateField('RequestedDeliveryDate', order.EUR_CRM_Delivery_Date__c);
        } 
        else 
        {
            gen.writeNullField('RequestedDeliveryDate');
        }

        gen.writeStringField('DeliveryInstructions', order.EUR_NIM_DeliveryTimeCode__c != null ? order.EUR_NIM_DeliveryTimeCode__c : ''); 
        //gen.writeStringField('ShippingInstructions', ''); // keep blank for the moment

        gen.writeStringField('DepartmentCode', order.EUR_NIM_DepartmentCode__c != null ? order.EUR_NIM_DepartmentCode__c : ''); 
        gen.writeStringField('ProjectCode', order.EUR_NIM_ProjectCode__c != null ? order.EUR_NIM_ProjectCode__c : ''); 
        gen.writeStringField('ReasonCode', order.EUR_NIM_ReasonCode__c != null ? order.EUR_NIM_ReasonCode__c : ''); 

        gen.writeStringField('CustomerOrderNumber', order.EUR_CRM_CustomerPurchaseOrder__c  != null ? order.EUR_CRM_CustomerPurchaseOrder__c : '');
        gen.writeStringField('OrderNumber', order.Name != null ? order.Name : '');
        gen.writeStringField('OrderExternalNumber', order.EUR_CRM_Order_Nr_JDE__c != null ? order.EUR_CRM_Order_Nr_JDE__c : '');
        gen.writeStringField('Status', order.EUR_CRM_Order_Status__c != null ? order.EUR_CRM_Order_Status__c : ''); //   TBD - inform to Tomaz values we expect
        gen.writeStringField('OrderType', order.EUR_NIM_ERP_OrderType__c != null ? order.EUR_NIM_ERP_OrderType__c : ''); 
        gen.writeStringField('InvoiceNumber', order.EUR_CRM_Invoice_No__c != null ? order.EUR_CRM_Invoice_No__c : '');         
        gen.writeStringField('OrderHoldCode', order.EUR_NIM_OrderHoldCode__c != null ? order.EUR_NIM_OrderHoldCode__c : '');        
        
        gen.writeFieldName('ShippingAccount');
        gen.writeStartObject();
        // Agreed to remove mapping
        //gen.writeStringField('ShippingContactName', order.EUR_CRM_Contact_Person__r.Name != null ? order.EUR_CRM_Contact_Person__r.Name : '');
        gen.writeStringField('ShippingContactPhone', ''); // keep blank for the moment
        gen.writeStringField('ShippingCompanyName', '');  // keep blank for the moment 
        gen.writeStringField('ShippingStreet', order.EUR_CRM_Delivery_Street__c != null ? order.EUR_CRM_Delivery_Street__c : '');
        gen.writeStringField('ShippingState', '');
        // gen.writeStringField('ShippingState', order.EUR_CRM_Delivery_City__c != null ? order.EUR_CRM_Delivery_City__c : '');
        gen.writeStringField('ShippingCity', order.EUR_CRM_Delivery_City__c != null ? order.EUR_CRM_Delivery_City__c : '');
        gen.writeStringField('ShippingPostCode', order.EUR_CRM_Delivery_Postal_Code__c != null ? order.EUR_CRM_Delivery_Postal_Code__c : '');
        gen.writeStringField('ShippingCountry', order.EUR_CRM_Country__c != null ? order.EUR_CRM_Country__c : '');
        gen.writeStringField('ShippingCode', order.EUR_CRM_Account__r.EUR_CRM_Customer_Ship_To_No_ERP__c != null ? order.EUR_CRM_Account__r.EUR_CRM_Customer_Ship_To_No_ERP__c : '');
        gen.writeStringField('ShippingInstructions', order.EUR_CRM_DeliveryInstruction__c != null ? order.EUR_CRM_DeliveryInstruction__c : '');
        gen.writeStringField('AdditionalCustomerInformation', order.EUR_NIM_AdditionalAddressInformation__c != null ? order.EUR_NIM_AdditionalAddressInformation__c : '');
        gen.writeEndObject();

        gen.writeFieldName('OrderLines');
        gen.writeStartArray();
        for (EUR_CRM_Sales_Order_Items__c item : order.Sales_Order_Items__r) 
        {
            gen.writeStartObject();
            gen.writeStringField('OrderLineId', item.ID);
            if (item.EUR_CRM_ERP_Id__c != null)
            {
                gen.writeStringField('OrderLineExternalNumber', item.EUR_CRM_ERP_Id__c);
            }
            //gen.writeStringField('TradeItemCode', item.EUR_CRM_SKU_codeCT__c != null ? item.EUR_CRM_SKU_codeCT__c : '');
            gen.writeStringField('TradeItemCode', item.EUR_CRM_PriceBookEntryID__r.EUR_CRM_Article_Number__c != null ? item.EUR_CRM_PriceBookEntryID__r.EUR_CRM_Article_Number__c : '');
            gen.writeStringField('LineOrderStatus', item.EUR_NIM_Status__c != null ? item.EUR_NIM_Status__c : '');         
            gen.writeNumberField('Quantity', item.EUR_CRM_Quantity__c != null ? item.EUR_CRM_Quantity__c : 0);
            gen.writeNumberField('QuantityShipped', item.EUR_NIM_QuantityShipped__c != null ? item.EUR_NIM_QuantityShipped__c : 0);
            gen.writeStringField('UnitOfMeasure', item.EUR_CRM_Unit_Type__c != null ? item.EUR_CRM_Unit_Type__c : '');
            gen.writeStringField('FreeGoods', item.EUR_CRM_FreeQuantity__c != 0 ? 'True' : 'False');
            if (item.EUR_CRM_Date__c != null) 
            {
                gen.writeDateField('OrderDate', item.EUR_CRM_Date__c);
            } 
            else 
            {
                gen.writeNullField('OrderDate');
            }
            
            if (item.EUR_CRM_DeliveryDate__c != null) 
            {
              gen.writeDateField('RequestedDeliveryDate', item.EUR_CRM_DeliveryDate__c);    
            } 
            else 
            {
                gen.writeNullField('RequestedDeliveryDate');
            }
            //gen.writeStringField('SalesOrderLineHoldCode', '');
            gen.writeStringField('DeliveryTimeCode', item.EUR_NIM_DeliveryTimeCode__c != null? item.EUR_NIM_DeliveryTimeCode__c : '');
            gen.writeStringField('PalletTypeCode', item.EUR_NIM_PalletTypeCode__c != null? item.EUR_NIM_PalletTypeCode__c : ''); 

            gen.writeEndObject();
        }

        gen.writeEndArray();

        gen.writeEndObject();

        return gen.getAsString();
    }

    /**
    * @Description: handle insert and update situation when a record is synced from JDE which is only created on JDE side. 
    */
    @HttpPut
    global static void upsertJDESalesOrdersAndItems()
    {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestBody = body.toString();
        Map<String, Object> requestMapping =   (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        String affiliate;
        if (requestMapping.containsKey('Affiliate'))
        {
            affiliate = String.valueOf(requestMapping.get('Affiliate'));
            // query account

            Map<String, Object> sfInternalMapping =  EUR_COMMON_Utils.getUpdateSalesOrderMapping(affiliate);

            EUR_NIM_Sales_Order_Setting__mdt productCatalogName = EUR_COMMON_Utils.getSalesOrderMetadataValuesByCountryCode(affiliate);
            Map<String,String> articleNumberPricebookIdMap = new Map<String,String>();
            for (EUR_CRM_ProductCatalogItem__c p : [select Id, EUR_CRM_Article_Number__c
                                                from EUR_CRM_ProductCatalogItem__c
                                                where EUR_CRM_PriceBookID__r.Name =: productCatalogName.EUR_NIM_Catalog_Name__c])
            {
                articleNumberPricebookIdMap.put(p.EUR_CRM_Article_Number__c, p.Id);
            }

            if (requestMapping.containsKey('Account'))
            {
                String accountERPId = String.valueOf(requestMapping.get('Account'));
                List<EUR_CRM_Account__c> accountList = [select id from 
                                                                EUR_CRM_Account__c where 
                                                                EUR_CRM_Country_Code__c =: affiliate and 
                                                                EUR_CRM_Customer_Ship_To_No_ERP__c =:accountERPId];
                // if account was not found fire an error. 
                if (accountList.IsEmpty())
                {
                    RestResponse res = new RestResponse();
                    handleExceptions(res, 500, 'No matching account was found for the Id :' + accountERPId);
                }
                String jdeOrderId = String.valueOf(requestMapping.get('OrderExternalNumber'));
                // query sales order 
                List<EUR_CRM_Sales_Order__c> salesOrderList = [select id from EUR_CRM_Sales_Order__c 
                                                                            where EUR_CRM_Order_Nr_JDE__c =: jdeOrderId and 
                
                                                                            EUR_CRM_Country__c =: affiliate];
                EUR_CRM_Sales_Order__c salesOrder;                                                                       
                if (!salesOrderList.isEmpty())
                {
                    // handle update
                    salesOrder = handleOrderMapping(salesOrderList.get(0), requestMapping, sfInternalMapping);
                    update salesOrder;
                    List<EUR_CRM_Sales_Order_Items__c> itemList = handleItemMapping(requestMapping, sfInternalMapping, salesOrder, true, articleNumberPricebookIdMap);
                    update itemList;
                }  
                else 
                {
                    // handle insert                         
                    salesOrder = handleOrderMapping(new EUR_CRM_Sales_Order__c(), requestMapping, sfInternalMapping);
                    salesOrder.EUR_CRM_Account__c = accountList.get(0).Id;
                    salesOrder.EUR_CRM_Order_Status__c = NEW_SO_STATUS;

                    insert salesOrder;
                    List<EUR_CRM_Sales_Order_Items__c> itemList = handleItemMapping(requestMapping, sfInternalMapping, salesOrder, true, articleNumberPricebookIdMap);
                    insert itemList;
                }
                handleResponse(salesOrder.Id);
            }
        }
        else 
        {
            handleExceptions(RestContext.response, 500, 'Affiliate is not provided');
        }
    }

    /**
    * @Description: update a record in SF when an update is executed in JDE
    */
    @HttpPatch
    global static void updateSalesOrderNumber()
    {
        RestRequest req = RestContext.request;
        String salesOrderId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        Blob body = req.requestBody;
        String requestBody = body.toString();
        EUR_CRM_Sales_Order__c order = new EUR_CRM_Sales_Order__c(Id = salesOrderId);
        List<EUR_CRM_Sales_Order_Items__c> itemList = new List<EUR_CRM_Sales_Order_Items__c>();
        Map<String, Object> requestMapping =   (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        String affiliate = String.valueOf(requestMapping.get('Affiliate'));
        Map<String, Object> sfInternalMapping =  EUR_COMMON_Utils.getUpdateSalesOrderMapping(affiliate);

        order = handleOrderMapping(order, requestMapping, sfInternalMapping);
        itemList = handleItemMapping(requestMapping, sfInternalMapping, order, false, null);
        
        try 
        {
            update order;
            update itemList;
            handleResponse(salesOrderId);
        } 
        catch (Exception e) 
        {
            handleExceptions(RestContext.response, 500, e.getStackTraceString() + e.getMessage());
        }

    }

    private static EUR_CRM_Sales_Order__c handleOrderMapping(EUR_CRM_Sales_Order__c order, Map<String, Object> requestMapping, Map<String, Object> sfInternalMapping)
    {
        for (String erpFieldName : requestMapping.keySet())
        {
            if (sfInternalMapping.containsKey(erpFieldName))
            {
                String sfAPINameWithType = (String)sfInternalMapping.get(erpFieldName);
                String typeOf = sfAPINameWithType.split(':').get(0);
                String apiName = sfAPINameWithType.split(':').get(1);

                if (typeOf == 'Date')
                {
                    order.put(apiName, Date.valueOf((String)requestMapping.get(erpFieldName)));
                }
                else if (typeOf == 'Decimal')
                {
                    order.put(apiName, Decimal.valueOf(String.valueOf(requestMapping.get(erpFieldName))));
                }
                else 
                {
                    order.put(apiName, requestMapping.get(erpFieldName));
                }
            }
        }
        return order;
    } 

    private static List<EUR_CRM_Sales_Order_Items__c> handleItemMapping( Map<String, Object> requestMapping, 
                                                                            Map<String, Object> sfInternalMapping, EUR_CRM_Sales_Order__c order, boolean isUpsert, Map<String,String> articleNumberPricebookIdMap)
    {
        List<EUR_CRM_Sales_Order_Items__c> itemList = new List<EUR_CRM_Sales_Order_Items__c>();
        Map<String,String> orderlineExternalIdSFIdMap = new Map<String,String>();
        for (EUR_CRM_Sales_Order_Items__c s : [select id,EUR_CRM_ERP_Id__c FROM EUR_CRM_Sales_Order_Items__c 
                                                                                            WHERE EUR_CRM_Sales_Order__c = :order.Id] )
        {
            orderlineExternalIdSFIdMap.put(s.EUR_CRM_ERP_Id__c, s.Id);
        }
        
        
        for (String erpFieldName : requestMapping.keySet())
        {
            if (erpFieldName == 'OrderLines')
            {
                List<Object> requestOrderItemMapping =(List<Object>) JSON.deserializeUntyped(JSON.serialize(requestMapping.get(erpFieldName)));
                for (Object o : requestOrderItemMapping)
                {
                    Map<String, Object> items =   (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                    System.debug(items.keyset());
                    EUR_CRM_Sales_Order_Items__c item = new EUR_CRM_Sales_Order_Items__c();
                    // in case it is an item created only on JDE initate the line item with the sales order otherwise assign the sf id
                    if (isUpsert)
                    {
                        item.EUR_CRM_Sales_Order__c = order.Id;
                    }
                    else 
                    {
                        item = new EUR_CRM_Sales_Order_Items__c(Id=(String)items.get('OrderLineId'));    
                    }
                    
                    // loop mapping for each line items retrieved from ERP
                    for (String erpItemFieldName : items.keySet())
                    {
                        system.debug('erpItemFieldName:'+erpItemFieldName);
                        if (sfInternalMapping.containsKey('OrderLines:'+erpItemFieldName))
                        {
                            if (erpItemFieldName == 'OrderLineExternalNumber')
                            {
                                item.EUR_CRM_ERP_Id__c = String.valueOf(items.get(erpItemFieldName));
                                if (orderlineExternalIdSFIdMap.containsKey(item.EUR_CRM_ERP_Id__c))
                                {
                                    // if an item already exist in SF assign the Id 
                                    item.Id = orderlineExternalIdSFIdMap.get(item.EUR_CRM_ERP_Id__c);
                                }
                                continue;
                            }

                            if (erpItemFieldName == 'TradeItemCode')
                            {
                                // special logic for JDE created records
                                if (isUpsert)
                                {
                                    String articleNumber = (String)items.get(erpItemFieldName);
                                    System.debug('Article Number : ' + articleNumber);
                                    // query product and assign the id to line item. 
                                    if (articleNumberPricebookIdMap != null && articleNumberPricebookIdMap.containsKey(articleNumber))
                                    {
                                        // assign pricebook
                                        item.EUR_CRM_PriceBookEntryID__c = articleNumberPricebookIdMap.get(articleNumber);
                                    }
                                    else 
                                    {
                                        handleExceptions(RestContext.response, 500, 'No matching product was found for the TradeItemCode :' + articleNumber);
                                        break;
                                    }
                                }
                                continue;
                            }
                            String sfAPINameWithType = (String)sfInternalMapping.get('OrderLines:'+erpItemFieldName);
                            String typeOf = sfAPINameWithType.split(':').get(0);
                            String apiName = sfAPINameWithType.split(':').get(1);

                            if (typeOf == 'Date')
                            {
                                item.put(apiName, Date.valueOf((String)items.get(erpItemFieldName)));
                            }
                            else if (typeOf == 'Decimal')
                            {
                                item.put(apiName, Decimal.valueOf(String.valueOf(items.get(erpItemFieldName))));
                            }
                            else 
                            {
                                system.debug('item:'+items.get(erpItemFieldName));
                                system.debug('apiName:'+apiName);
                                item.put(apiName, items.get(erpItemFieldName));
                            }   
                        }             
                    }
                    itemList.add(item);
                }
            }
        }
        return itemList;
    }
}