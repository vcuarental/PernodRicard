/**
* @Description: Service class for the functionality on Account like population of Brands, Category, Search product,
                Calculate price (get price from external system) etc.
* @Author: Minakshi
* @Copyright: PARX
*/
public with sharing class EUR_NIM_Service 
{
    private static final Set<String> ALLOWED_REGION_SET = new Set<String>{'DB', 'IDL', 'SA'};
    private static final String SA_REGION = 'SA';
    private static final String SA_ISO_CODE = 'ZA';

    public EUR_NIM_Service() 
    {
    }
    
    /**
    * @Description: Class to form where clause field of SOQL and value dynamically
    */
    public class Criteria implements EUR_NIM_Attributable
    {
        public String fieldName;
        public String operator;
        public String fieldValue;
        
        public Criteria(String f_name, String f_value, String f_operator) 
        {
            fieldName = f_name;
            fieldValue = f_value;
            operator = f_operator;
        }
        public String getSOQLCriteria() 
        {
            if(operator == '=')
            {
                return fieldName + ' '  + operator + '\'' + fieldValue + '\'';
            }
            else
            {
                return fieldName + ' '  + operator + ' \'%' + fieldValue + '%\'';
            }
            
        }

        public boolean isFieldValueGiven() 
        {
            return fieldValue != null && fieldValue != '';
        }
    }

    /**
    * @Description: Method to form where clause dynamically
    * @return: String presentation of where clause
    */    
    public static String generateWhereQuery(List<Criteria> criterias) 
    {
        List<String> and_conditions = new List<String>();
        for(Criteria single_criteria : criterias) 
        {
            if (single_criteria.isFieldValueGiven()) 
            {
                and_conditions.add(single_criteria.getSOQLCriteria());
            }
        }
        return String.join(and_conditions, ' AND ');
    }

    /**
    * @Description: get an Id of a Contact with 'Contact Position' = 'Main Telesales' to prepopulate 'Contact Person'
    * @return: Id - of a Contact 
    */
    @AuraEnabled
    public static Id getContactPersonIs(Id accId) 
    { 
        Id contId;
        List<Contact> contList = [SELECT Id FROM Contact 
            WHERE EUR_CRM_Account__c = :accId AND EUR_JB_Position_of_Contact__c = 'Main Telesales'];
            System.debug('contList: ' + contList);
        
        if (!contList.isEmpty()) 
        {
            contId = contList[0].Id;

        }
        return contId;
    }

    /**
    * @Description: Get the list of brands based on the accountId
    * @return: List<OptionWrapper> - List for picklist with Key-Value pair
    */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getBrandValues(String accountId) 
    {
        Set<String> brand = new Set<String>();
        List<OptionWrapper> brandList = new List<OptionWrapper>();
        brandList.add(new OptionWrapper(Label.EUR_NIM_None, ''));
        EUR_NIM_Sales_Order_Setting__mdt productCatalogName = EUR_COMMON_Utils.getSalesOrderMetadataValues(accountId);
        for (EUR_CRM_ProductCatalogItem__c productCatalogItem : [select EUR_CRM_SKU__r.EUR_CRM_Brand__c, EUR_CRM_SKU__c 
                                                from EUR_CRM_ProductCatalogItem__c
                                                where EUR_CRM_PriceBookID__r.Name =: productCatalogName.EUR_NIM_Catalog_Name__c and EUR_CRM_Is_Active__c = true ])
        {
            if (productCatalogItem.EUR_CRM_SKU__c != null && !brand.contains(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Brand__c))
            {
                brandList.add(new OptionWrapper(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Brand__c, productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Brand__c));
                brand.add(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Brand__c);
            }
        }  
        return brandList;
    }

    /**
    * @Description: Get the list of Category based on the accountId
    * @return: List<OptionWrapper> - List for picklist with Key-Value pair
    */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getCategoryValues(String accountId) 
    { 
        Set<String> category = new Set<String>();
        List<OptionWrapper> categoryList = new List<OptionWrapper>();
        categoryList.add(new OptionWrapper(Label.EUR_NIM_None, ''));
        EUR_NIM_Sales_Order_Setting__mdt productCatalogName = EUR_COMMON_Utils.getSalesOrderMetadataValues(accountId);
        for (EUR_CRM_ProductCatalogItem__c productCatalogItem : [Select EUR_CRM_SKU__r.EUR_CRM_Category_Name__c, EUR_CRM_SKU__c  
                                                From EUR_CRM_ProductCatalogItem__c
                                                where EUR_CRM_PriceBookID__r.Name =: productCatalogName.EUR_NIM_Catalog_Name__c and EUR_CRM_Is_Active__c = true ])
        {
            if (productCatalogItem.EUR_CRM_SKU__c != null && !category.contains(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Category_Name__c))
            {
                categoryList.add(new OptionWrapper(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Category_Name__c, productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Category_Name__c));
                category.add(productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Category_Name__c);
            }
        }
        return categoryList;
    }

    /**
    * @Description: Generic method to get picklist values based on the object name and picklist field name
    * @return: List<OptionWrapper> - List for picklist with Key-Value pair
    */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getPicklistVals(String objectName, String fieldName) 
    { 
        List<OptionWrapper> resultList = new List<OptionWrapper>();
        resultList.add(new OptionWrapper(Label.EUR_NIM_None, ''));
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) 
        {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) 
            {
                if (entry.isActive()) 
                {
                    resultList.add(new OptionWrapper(entry.getLabel(), entry.getValue()));
                }
            }
        }
        return resultList;
    }

    /**
    * @Description: Method to create Sales order and Line items
    * @return: Void
    */
    @AuraEnabled
    public static void createSalesOrder(Map<String,String> recInsert, String status, String accId, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        Savepoint sp = Database.setSavepoint();
        EUR_CRM_Sales_Order__c salesOrderRec = createSalesOrderRecord(recInsert, status, accId, salesOrderLineItemList);
        Boolean isSalesOrderItemCreated = createSalesOrderItem(salesOrderRec, salesOrderLineItemList);
        Boolean isSalesOrderCaseCreated = createSalesOrderCase(salesOrderRec, accId);    
        if(!isSalesOrderItemCreated || !isSalesOrderCaseCreated)
        {
            Database.rollback(sp);
        }
    }

    /**
    * @Description: Method to create case as a part of Sales order creation for NOT DE regions
    * @return: Void
    */
    public static Boolean createSalesOrderCase(EUR_CRM_Sales_Order__c salesOrderRec, String accId)
    {
        List<EUR_CRM_Sales_Order__c> salesOrders = [SELECT Name from EUR_CRM_Sales_Order__c 
        WHERE Id = :salesOrderRec.Id AND EUR_CRM_Country_Code__c IN :ALLOWED_REGION_SET];
        
        //skip is there is no Non-DE orders found
        if (salesOrders.isEmpty()) return true;
        
        Case newCase = new Case();
        newCase.Subject = salesOrders[0].Name;
        newCase.Status = 'Closed';
        newCase.Type = 'New Sales Order';
        newCase.EUR_CRM_Account__c = accId;
        newCase.ContactId = salesOrderRec.EUR_CRM_Contact_Person__c;

        String countryCode = [SELECT id,recordType.DeveloperName, EUR_CRM_Country_Code__c 
        FROM EUR_CRM_Account__c WHERE Id=:accId].EUR_CRM_Country_Code__c;

        newCase.RecordTypeId = EUR_COMMON_Utils.recordTypes.get('Case:EUR_NIM_' + countryCode.replace(SA_REGION, SA_ISO_CODE) + '_Case');

        newCase.EUR_NIM_SalesOrderEU__c = salesOrderRec.Id;
        
        Database.SaveResult newCaseResult = Database.insert(newCase,false);
        if(newCaseResult!= null)
        {
            if(newCaseResult.isSuccess())
            {
                System.debug(LoggingLevel.ERROR, 'New Case Inserted');
                return true;
            }
            else
            {
                for(Database.Error err : newCaseResult.getErrors()) 
                {
                    System.debug(LoggingLevel.ERROR, err.getMessage());
                }
                System.debug(LoggingLevel.ERROR,'Rollbacked');
                return false;
            }
        }
        return true;
    }

    /**
    * @Description: Method to create Sales order items as a part of Sales order creation
    * @return: EUR_CRM_Sales_Order__c
    */
    public static EUR_CRM_Sales_Order__c createSalesOrderRecord(Map<String,String> recInsert, String status, String accId, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        EUR_CRM_Sales_Order__c insertRecord = new EUR_CRM_Sales_Order__c();
        insertRecord.EUR_NIM_IsServiceCloud__c = true; 
        insertRecord.EUR_CRM_Delivery_Date__c = Date.valueOf(recInsert.containsKey('EUR_CRM_Delivery_Date__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Delivery_Date__c')) : '');

        insertRecord.EUR_CRM_Contact_Person__c = recInsert.containsKey('EUR_CRM_Contact_Person__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Contact_Person__c')) : null;
        //insertRecord.EUR_CRM_Delivery_Contact__c = insertRecord.EUR_CRM_Contact_Person__c != null ? insertRecord.EUR_CRM_Contact_Person__c : null;

        insertRecord.EUR_CRM_CustomerPurchaseOrder__c = recInsert.containsKey('EUR_CRM_CustomerPurchaseOrder__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_CustomerPurchaseOrder__c')) : '';

        insertRecord.EUR_NIM_ERP_OrderType__c = '';
        if (recInsert.containsKey('EUR_NIM_ERP_OrderType__c'))
        {
            insertRecord.EUR_NIM_ERP_OrderType__c = getFieldValue(recInsert.get('EUR_NIM_ERP_OrderType__c'));

            if (insertRecord.EUR_NIM_ERP_OrderType__c == 'S7')
            {
                insertRecord.EUR_NIM_DepartmentCode__c = recInsert.containsKey('EUR_NIM_DepartmentCode__c') ? 
                getFieldValue(recInsert.get('EUR_NIM_DepartmentCode__c')) : '';
        
                insertRecord.EUR_NIM_ProjectCode__c = recInsert.containsKey('EUR_NIM_ProjectCode__c') ? 
                getFieldValue(recInsert.get('EUR_NIM_ProjectCode__c')) : '';
        
                insertRecord.EUR_NIM_ReasonCode__c = recInsert.containsKey('EUR_NIM_ReasonCode__c') ? 
                getFieldValue(recInsert.get('EUR_NIM_ReasonCode__c')) : '';
            } 
        }

        insertRecord.EUR_NIM_ERP_OrderType__c = recInsert.containsKey('EUR_NIM_ERP_OrderType__c') ? 
        getFieldValue(recInsert.get('EUR_NIM_ERP_OrderType__c')) : '';

        insertRecord.EUR_NIM_OrderHoldCode__c = recInsert.containsKey('EUR_NIM_OrderHoldCode__c') ? 
        getFieldValue(recInsert.get('EUR_NIM_OrderHoldCode__c')) : '';
        
        insertRecord.EUR_CRM_Delivery_Postal_Code__c = recInsert.containsKey('EUR_CRM_Delivery_details_Postal_code__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Delivery_details_Postal_code__c')) : '';
        // used in SAP 
        //insertRecord.EUR_CRM_Post_code__c = insertRecord.EUR_CRM_Delivery_Postal_Code__c;
		
        insertRecord.EUR_CRM_Delivery_City__c = recInsert.containsKey('EUR_CRM_Delivery_details_City__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Delivery_details_City__c')) : '';
		// used in SAP 
        //insertRecord.EUR_CRM_City__c = insertRecord.EUR_CRM_Delivery_City__c;

		insertRecord.EUR_CRM_Delivery_Street__c = recInsert.containsKey('EUR_CRM_Delivery_details_Street__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Delivery_details_Street__c')) : '';
        // used in SAP 
        //insertRecord.EUR_CRM_Street__c = insertRecord.EUR_CRM_Delivery_Street__c;

        insertRecord.EUR_NIM_DeliveryTimeCode__c = recInsert.containsKey('EUR_NIM_DeliveryTimeCode__c') ? 
        getFieldValue(recInsert.get('EUR_NIM_DeliveryTimeCode__c')) : '';

        insertRecord.EUR_CRM_DeliveryInstruction__c = recInsert.containsKey('EUR_CRM_DeliveryInstruction__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_DeliveryInstruction__c')) : '';

        insertRecord.EUR_NIM_AdditionalAddressInformation__c = recInsert.containsKey('EUR_NIM_AdditionalAddressInformation__c') ? 
        getFieldValue(recInsert.get('EUR_NIM_AdditionalAddressInformation__c')) : '';

        insertRecord.EUR_CRM_Status__c = status;
        insertRecord.EUR_CRM_Order_Status__c = status;
        if (status == 'Send To ERP')
        {
            insertRecord.EUR_CRM_Status__c = 'Instant validation';  
        }
              

        insertRecord.RecordTypeId = EUR_COMMON_Utils.recordTypes.get('EUR_CRM_Sales_Order__c:EUR_Direct');
        insertRecord.EUR_CRM_Account__c = accId;
        
        insertRecord.EUR_NIM_POType__c = recInsert.containsKey('EUR_NIM_POType__c') ? 
        getFieldValue(recInsert.get('EUR_NIM_POType__c')) : '';
		
        insertRecord.EUR_CRM_Notes__c = recInsert.containsKey('EUR_CRM_Notes__c') ? 
        getFieldValue(recInsert.get('EUR_CRM_Notes__c')) : '';

        // assign total price 
        insertRecord.EUR_CRM_Total_Value_of_Order__c = 0;
        for(EUR_NIM_Service.LineItemWrapper lineItem : salesOrderLineItemList)
        {
            if (lineItem.productTotalPrice != null)
            {
                insertRecord.EUR_CRM_Total_Value_of_Order__c += lineItem.productTotalPrice;
            }
        }

        try 
        {
            insert insertRecord;
        } 
        catch (DmlException ex) 
        {
            throw new AurahandledException(ex.getDmlMessage(0));
        } 
        catch (Exception ex) 
        {
            throw new AurahandledException(ex.getMessage());
        }
        return insertRecord;
    }

    /**
    * @Description: Method to create Sales order items as a part of Sales order creation
    * @return: Boolean
    */
    public static Boolean createSalesOrderItem(EUR_CRM_Sales_Order__c salesOrderRec, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        List<EUR_CRM_Sales_Order_Items__c> salesOrderItems = new List<EUR_CRM_Sales_Order_Items__c>();
        for(EUR_NIM_Service.LineItemWrapper lineItem : salesOrderLineItemList)
        {
            EUR_CRM_Sales_Order_Items__c item = new EUR_CRM_Sales_Order_Items__c();
            item.EUR_CRM_PriceBookEntryID__c = lineItem.priceBook;
            item.EUR_CRM_Quantity__c = lineItem.quantity;
            item.EUR_CRM_Sales_Order__c = salesOrderRec.Id;
            // Agreed to removed
            //item.EUR_CRM_Unit_Type__c = lineItem.productUnitType;
            item.EUR_CRM_ItemCategory__c = 'Chargable';
            item.EUR_NIM_PalletTypeCode__c = lineItem.palletTypeCode;
            item.EUR_CRM_DeliveryDate__c = salesOrderRec.EUR_CRM_Delivery_Date__c;
            item.EUR_CRM_Totallineamount__c = lineItem.productTotalPrice;
            item.EUR_CRM_Unit_Price__c = lineItem.productPrice; 
            if (lineItem.isDeal != null && lineItem.isDeal)
            { 
                assignDealsMapping(item,lineItem);
            }
            salesOrderItems.add(item);
        }
        if(salesOrderItems.size() > 0)
        {
            List<Database.SaveResult> salesOrderItemsResult = Database.insert(salesOrderItems,false);
            for(Database.SaveResult sr : salesOrderItemsResult)
            {
                if (sr.isSuccess())
                {
                    System.debug(LoggingLevel.ERROR, 'Sales Order Item Inserted');
                }
                else
                {
                    // DML operation failed
                    Database.Error error = sr.getErrors().get(0);
                    System.debug(LoggingLevel.ERROR, error.getMessage());
                    return false;
                }
            }
            return true;
        }
        return true;
    } 

    /*
    * @Description: Method to assign values which are relevant for deals
    */
    private static void assignDealsMapping(EUR_CRM_Sales_Order_Items__c item, EUR_NIM_Service.LineItemWrapper lineItem)
    {
            item.EUR_CRM_ItemCategory__c = 'Free';
            item.EUR_CRM_FreeQuantity__c = lineItem.productFreeQuantity;
            item.EUR_CRM_Deal__c = lineItem.productDealMap.containsKey((lineItem.productCode)) ? lineItem.productDealMap.get(lineItem.productCode).dealId : null;
    }

    public static String getFieldValue(String value)
    {
        system.debug('value:'+value);
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(value);
        String fieldValue = '';
        for (String val: meta.keySet())
        {
            if (val == 'Value' && (String)meta.get('Value') != null && (String)meta.get('Value') != '')
            {
                fieldValue = (String)meta.get('Value');
            }
        }
        return fieldValue;
    }

    /**
    * @Description: Method to get EUR_NIM_InventoryService_Endpoint__c Endpoint name from
    *   custom metadata EUR_NIM_Sales_Order_Setting__mdt
    * @return: String - value of EUR_NIM_InventoryService_Endpoint__c
    */    
    @AuraEnabled(cacheable=true)
    public static String getInvServiceEndpoint(String recordId)
    {
        EUR_NIM_Sales_Order_Setting__mdt getEnpointName = EUR_COMMON_Utils.getSalesOrderMetadataValues(recordId);
        String endpointName = getEnpointName.EUR_NIM_InventoryService_Type__c;
        return endpointName;
    }

    /**
    * @Description: Method to get price of the product based on the quantity using callout from external service. 
        Update the line item list again for the product price and the total price to display on UI
    * @return: List<EUR_NIM_Service.LineItemWrapper> - Updated list of line item with price
    */ 
    @AuraEnabled
    public static List<EUR_NIM_Service.LineItemWrapper> calculatePrice(String recordId, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList) 
    {
        RequestResponseWrapper priceResultList;

        //Get EUR_CRM_Customer_No_ERP__c, EUR_CRM_Sales_Organization__c

        EUR_CRM_Account__c account = EUR_COMMON_Utils.getAccountById(recordId);

        // Query setting based on the account country code
        EUR_NIM_Sales_Order_Setting__mdt settings = EUR_COMMON_Utils.getSalesOrderMetadataValues(account);

        String urlPath = '';
        Type t = Type.forName(settings.EUR_NIM_PriceService_Type__c);
        EUR_NIM_ERPHandler v = (EUR_NIM_ERPHandler)t.newInstance();
        priceResultList = v.calculatePrice(account,urlPath,salesOrderLineItemList);
		system.debug('priceResultList: ' + priceResultList);
        if(priceResultList.lines != null)
        {
            //Form a map based on the product id
            Map<String, Lines> lineMap = new Map<String, Lines>();
            List<Lines> lineList = priceResultList.lines;
            for(Lines line : lineList)
            {
                lineMap.put((String)line.material , line);                
            }
            for(EUR_NIM_Service.LineItemWrapper lineItemWrapper : salesOrderLineItemList)
            {
                system.debug('lineItemWrapper: ' + lineItemWrapper);
                if(lineMap.containsKey(lineItemWrapper.productCode))
                {
                    Lines line = lineMap.get(lineItemWrapper.productCode);
                    lineItemWrapper.productPrice = Decimal.valueOf(line.netPrice);
                    lineItemWrapper.productTotalPrice = Decimal.valueOf(line.itemTotalPrice);
                    system.debug('line: ' + line);
                }
            }
        }
        return salesOrderLineItemList;
    }

    /**
    * @Description: Method to get price of the product based on the quantity using callout from external service. 
    Update the line item list again for the product price and the total price to display on UI
    * @return: List<EUR_NIM_Service.LineItemWrapper> - Updated list of line item with price
    */
    @AuraEnabled
    public static List<EUR_NIM_Service.LineItemWrapper> calculateInventory(String recordId, List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList)
    {
        //Get EUR_CRM_Customer_No_ERP__c, EUR_CRM_Sales_Organization__c
        EUR_CRM_Account__c account = EUR_COMMON_Utils.getAccountById(recordId);

        // Query setting based on the account country code
        EUR_NIM_Sales_Order_Setting__mdt settings = EUR_COMMON_Utils.getSalesOrderMetadataValues(account);

        String urlPath = '';
        Type t = Type.forName(settings.EUR_NIM_InventoryService_Type__c);
        EUR_NIM_ERPHandler v = (EUR_NIM_ERPHandler)t.newInstance();
        system.debug(account+':'+urlPath+':'+salesOrderLineItemList);
        salesOrderLineItemList = v.calculateInventory(account,urlPath,salesOrderLineItemList);
		system.debug('salesOrderLineItemList:'+salesOrderLineItemList);
        return salesOrderLineItemList;
    }

    /**
    * @Description: Wrapper class to collect result from webservice call to get price and other details
    */ 
    public class RequestResponseWrapper
	{
        public String account { get; set; } //EUR_CRM_Customer_No_ERP__c
        public String salesorg { get; set; } //EUR_CRM_Sales_Organization__c
        public String orderTotalPrice { get; set; }
        public List<Lines> lines { get; set; }        
    }

    public class Lines
    {
        public String material { get; set;} //EUR_CRM_Article_no__c i.e. Product Code
        public String quantity { get; set;} //From UI
        public String netPrice { get; set; }
        public String itemTotalPrice { get; set; }
    }

    public class GroupedDeals
    {
        @AuraEnabled
        public String header {get; set;}
        @AuraEnabled
        public List<OptionWrapper> deals {get; set;}

        public GroupedDeals(String header, List<OptionWrapper> deals) 
        {
            this.header = header;
            this.deals = deals;
        }
    }

    public class OptionWrapper 
    {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class LineItemWrapper implements Comparable
    {
        @AuraEnabled
        public Integer quantity{get;set;}
        @AuraEnabled
        public Integer productFreeQuantity{get;set;}
        @AuraEnabled
        public Integer posnr{get;set;}
        @AuraEnabled
        public String priceBook { get; set; }
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public String productName { get; set; }
        @AuraEnabled
        public String productUnitType { get; set; }
        @AuraEnabled
        public Decimal productPrice { get; set; }
        @AuraEnabled
        public Decimal productTotalPrice { get; set; }  
        @AuraEnabled
        public String productStockInfo { get; set; }        
        @AuraEnabled
        public String productDescription { get; set; }   
        @AuraEnabled
        public Boolean isDeal{get;set;}     
        @AuraEnabled
        public String deliveryTimeCode { get; set; }   
        @AuraEnabled
        public String palletTypeCode { get; set; }
        @AuraEnabled
        public String productCodeIsDeal { get; set; }
        @AuraEnabled
        public Map<String, EUR_NIM_DealService.DealWrapper> priceBookMap { get; set; }
        @AuraEnabled
        public Map<String, EUR_NIM_DealService.DealWrapper> productDealMap { get; set; }
        @AuraEnabled
        public String dealName{get;set;} 
        @AuraEnabled
        public Integer productRequiredQuantity{get;set;}

        public Integer compareTo(Object compareTo) 
        {
            LineItemWrapper compareToWrapper = (LineItemWrapper)compareTo;
            if (this.isDeal == compareToWrapper.isDeal) return 0;
            if (!this.isDeal && compareToWrapper.isDeal) return 1;
            return -1;
        }
    }

    //Wrapper class to return search result in Account and Contact format
    public class AccountContactResult
    {
        @AuraEnabled
        public EUR_CRM_Account__c acc {get; set;}
        @AuraEnabled
        public Contact con {get; set;}
        @AuraEnabled
        public String accountId {get; set;}
        @AuraEnabled
        public String accountName {get; set;}
        
        public AccountContactResult(EUR_CRM_Account__c acc, Contact con, String accountId, String accountName)
        {
            this.acc = acc;
            this.con = con;
            this.accountId = accountId;
            this.accountName = accountName;
        }
    }
}