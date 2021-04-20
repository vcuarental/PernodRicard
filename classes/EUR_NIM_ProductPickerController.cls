public with sharing class EUR_NIM_ProductPickerController 
{
    public EUR_NIM_ProductPickerController() {

    }

    @AuraEnabled
    public static List<EUR_NIM_Service.LineItemWrapper> getFilteredProducts(String filter, String accId)
    {
        System.debug(filter);
        Map<String, Object> filterHeaderMap = (Map<String, Object>)JSON.deserializeUntyped(filter);
        System.debug(filterHeaderMap);

        Map<String, Object> filterMap = (Map<String, Object> )filterHeaderMap.get('filter');

        for (String dd : filterMap.keySet())
        {
            System.debug(dd);
            Map<String, Object> meta;
            if(Test.isRunningTest())
            {
                meta = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(filterMap.get(dd)));
            }
            else
            {
            	meta = (Map<String, Object>) JSON.deserializeUntyped((string)filterMap.get(dd));    
            }
            //system.debug(meta);
        }

       // System.debug('accId' + accId);
        List<EUR_NIM_Service.Criteria> cList = new List<EUR_NIM_Service.Criteria>();
        EUR_NIM_Service.Criteria crit;
        String productNumberValue = '';
        for(String apiFieldName: filterMap.keyset())
        {
            System.debug('apiFieldName' + apiFieldName);
            if (filterMap.get(apiFieldName) != null)
            {
                //String m = (String)mm.get(apiFieldName);

				Map<String, Object> meta;
                if(Test.isRunningTest())
                {
                	meta = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(filterMap.get(apiFieldName)));
                }
                else
                {
                    meta = (Map<String, Object>) JSON.deserializeUntyped((string)filterMap.get(apiFieldName));
                }
                //Map<String, Object> meta = (Map<String, Object>)mm.get(apiFieldName);
                system.debug('system.debug(meta);' + meta);
                for (String con: meta.keySet())
                {
                    System.debug('meta.keySet()' + con +  ' / '+ meta);
                    if (con == 'Label' && (String)meta.get('Label') != null && (String)meta.get('Label') != '')
                    {
                        System.debug('meta' + meta.get('Label') );
                        system.debug('apiFieldName: ' + apiFieldName);
                        if(apiFieldName != 'EUR_CRM_SKU__r.EUR_CRM_Article_no__c')
                        {
                            crit = new EUR_NIM_Service.Criteria(apiFieldName, (String)meta.get('Label'), (String)meta.get('operator'));
                            cList.add(crit);
                        }
                        else
                        {
                            productNumberValue = (String)meta.get('Label');
                        }
                    }
                }
                System.debug(cList);                
            }
        }
            String priceBook_where_cond = EUR_NIM_Service.generateWhereQuery(cList);
            String priceBookQueryString = 'Select EUR_CRM_SKU__r.EUR_CRM_Category_Name__c, EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name, ' +
                                         'EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Id, EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c, '+
                                         'EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c '+
                                         'From EUR_CRM_ProductCatalogItem__c ';
            EUR_NIM_Sales_Order_Setting__mdt salesOrderSettings = EUR_COMMON_Utils.getSalesOrderMetadataValues(accId);
            String catalogName = salesOrderSettings.EUR_NIM_Catalog_Name__c;
            String catalogFilter = ' EUR_CRM_PriceBookID__r.Name =: catalogName and EUR_CRM_Is_Active__c = true';
            if(String.isNotBlank(productNumberValue))
            {
                priceBookQueryString = priceBookQueryString + 
                                         'Where (EUR_CRM_SKU__r.EUR_CRM_Article_no__c like \'%' + productNumberValue + '%\' AND ' + catalogFilter + ')';
                if (String.isNotBlank(priceBook_where_cond))
                {                    
                    priceBookQueryString = priceBookQueryString + ' OR ('+ priceBook_where_cond + ' AND ' + catalogFilter + ')';
                }
            }
            else
            {
                if (String.isNotBlank(priceBook_where_cond))
                {
                    priceBookQueryString = priceBookQueryString +
                                         'Where '+ priceBook_where_cond + ' AND ' + catalogFilter;
                }
                else
                {
                    priceBookQueryString = priceBookQueryString +
                                         'Where '+ catalogFilter;
                }
            }
            system.debug('queryString: ' + priceBookQueryString);
            List<EUR_CRM_ProductCatalogItem__c> pList = Database.query(priceBookQueryString);

            List<EUR_NIM_Service.LineItemWrapper> lineItemWrappers = new List<EUR_NIM_Service.LineItemWrapper>();

            for (EUR_CRM_ProductCatalogItem__c p : pList)
            {
                EUR_NIM_Service.LineItemWrapper li = new EUR_NIM_Service.LineItemWrapper();
                li.priceBook = p.Id;
                li.productName = p.EUR_CRM_SKU__r.Name;
                li.productCode = p.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
                // Agreed to removed mapping
                //li.productUnitType = p.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c;
                li.productStockInfo = p.EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c; 
                li.isDeal = false;
                li.productCodeIsDeal = li.productCode + li.isDeal;
                lineItemWrappers.add(li);
            }
        return lineItemWrappers;
    }

    @AuraEnabled(cacheable=true)
    public static List<EUR_NIM_Service.LineItemWrapper> getAllProducts()
    {
        String priceBookQueryString = 'Select EUR_CRM_SKU__r.EUR_CRM_Category_Name__c, EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name, ' +
                                        'EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Id, EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c, '+
                                        'EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c '+
                                        'From EUR_CRM_ProductCatalogItem__c ';

        system.debug('queryString: ' + priceBookQueryString);
        List<EUR_CRM_ProductCatalogItem__c> pList = Database.query(priceBookQueryString);

        List<EUR_NIM_Service.LineItemWrapper> lineItemWrappers = new List<EUR_NIM_Service.LineItemWrapper>();

        for (EUR_CRM_ProductCatalogItem__c p : pList)
        {
            EUR_NIM_Service.LineItemWrapper li = new EUR_NIM_Service.LineItemWrapper();
            li.priceBook = p.Id;
            li.productName = p.EUR_CRM_SKU__r.Name;
            li.productCode = p.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
            li.productUnitType = p.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c;
            li.productStockInfo = p.EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c; 
            li.isDeal = false;
            li.productCodeIsDeal = li.productCode + li.isDeal;
            lineItemWrappers.add(li);
        }
        return lineItemWrappers;
    }



    @AuraEnabled
    public static List<EUR_NIM_Service.LineItemWrapper> addLineItems(List<EUR_NIM_Service.LineItemWrapper> items)
    {
  /*      System.debug(items);
        List<SObject> lineItems = new List<SObject>();
        for (LineItemWrapper line : items)
        {
            lineItems.add(line.lineItem);
        }
        System.debug(lineItems);
        try {
            //insert lineItems;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return new List<LineItemWrapper>();*/
        return new List<EUR_NIM_Service.LineItemWrapper>();
    }

}