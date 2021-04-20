/**
* @Description: Service class for the functionality on Deals
* @Author: yle
* @Copyright: PARX
*/
public without sharing class EUR_NIM_DealService 
{
    /**
    * @Description Method to get active deals by account
    * @return List<EUR_NIM_Service.GroupedDeals>
    */

    private static String COUNTRY_CODE_IDL = 'IDL';
    private static String COUNTRY_CODE_DB = 'DB';

    @AuraEnabled(cacheable=true)
    public static List<EUR_NIM_Service.GroupedDeals> getActiveDealsByAccount(String accountID)
    {
        
        List<id> accountTargetGroups = new List<id>();
        for (EUR_CRM_Account_in_Target_Group__c tg : [select EUR_CRM_Account_Target_Group__c from EUR_CRM_Account_in_Target_Group__c where EUR_CRM_Account__c =: accountID])
        {
            accountTargetGroups.add(tg.EUR_CRM_Account_Target_Group__c);
        }

        System.debug('OPs: ' + accountTargetGroups);
        
        List<EUR_CRM_Deal__c> deals = [SELECT Id, Name, EUR_CRM_Objectives_Promotions__c, EUR_CRM_Objectives_Promotions__r.Name,
                                           (SELECT Id from Products_in_Animation__r),
                                           (SELECT Id from Price_Book_EntryGrouping__r)
                                       FROM   EUR_CRM_Deal__c 
                                       WHERE  EUR_CRM_Objectives_Promotions__r.EUR_CRM_Account_Target_Group__c in : accountTargetGroups and 
                                       EUR_CRM_Objectives_Promotions__r.EUR_CRM_Status__c = 'Active' and
                                       recordTypeId =: EUR_COMMON_Utils.recordTypes.get('EUR_CRM_Deal__c:EUR_Free')
                                       ORDER BY EUR_CRM_Objectives_Promotions__r.Name, Name];
        
        System.debug('Deals: ' + deals.size());
        Map<String, List<EUR_NIM_Service.OptionWrapper>> dealMap = new Map<String, List<EUR_NIM_Service.OptionWrapper>>();
        List<EUR_NIM_Service.GroupedDeals> groupedDeals = new List<EUR_NIM_Service.GroupedDeals>();
        for(EUR_CRM_Deal__c deal: deals) 
        {
            System.debug('### Deal: ' + deal.Name);
            if(dealMap.containsKey(deal.EUR_CRM_Objectives_Promotions__c + ':' + deal.EUR_CRM_Objectives_Promotions__r.Name))
            {
                List<EUR_NIM_Service.OptionWrapper> dealList = dealMap.get(deal.EUR_CRM_Objectives_Promotions__c + ':' + deal.EUR_CRM_Objectives_Promotions__r.Name);
                dealList.add(new EUR_NIM_Service.OptionWrapper(deal.Name,deal.Id));
                dealMap.put(deal.EUR_CRM_Objectives_Promotions__c + ':' + deal.EUR_CRM_Objectives_Promotions__r.Name, dealList);
            }
            else
            {
                List<EUR_NIM_Service.OptionWrapper> dealList = new List<EUR_NIM_Service.OptionWrapper>();
                dealList.add(new EUR_NIM_Service.OptionWrapper(deal.Name,deal.Id));
                dealMap.put(deal.EUR_CRM_Objectives_Promotions__c + ':' + deal.EUR_CRM_Objectives_Promotions__r.Name, dealList);
            }
        }
        for(String key : dealMap.keySet())
        {
            String[] arrTest = key.split(':');
            List<EUR_NIM_Service.OptionWrapper> dealList = dealMap.get(key);
            groupedDeals.add(new EUR_NIM_Service.GroupedDeals(arrTest[1], dealList));
        }
        if(groupedDeals.size() > 0)
        {
            return groupedDeals;
        }
        else 
        {
            return null;    //returning null explicitely as need to hide Deals button if there is no deal.
        }
    }

    /**
    * @Description Method to add products of deal in the selected product line items
    * Removed cacheable from here as it was throwing an error 
    * "'set' on proxy: trap returned falsish for property 'productFreeQuantity'" while setting free quantity
    * @return List<EUR_NIM_Service.LineItemWrapper>
    */
    @AuraEnabled
    public static List<EUR_NIM_Service.LineItemWrapper> addDealProducts(String dealId)
    {
        Map<String, DealWrapper> priceBookMap = new Map<String, DealWrapper>();
        Map<String, DealWrapper> productDealMap = new Map<String, DealWrapper>();

        system.debug('dealId: ' + dealId);
        List<String> selectedIdsList = new List<String>();
        Object[] deserializeUntyped = (Object[])System.JSON.deserializeUntyped(dealId);
        if(deserializeUntyped.size() > 0)
        {        
            for (Object id : deserializeUntyped) 
            {
                system.debug('id:'+id);
                selectedIdsList.add(String.valueof(id));
                /*if(str.startsWith('(') && str.endsWith(')'))
                {
                    selectedIdsList.add(str.substring(1,str.length()-1));
                }*/
            }
        }

        system.debug('selectedIdsList:'+ selectedIdsList);

        //collect deal Product codes
        Set<Id> dealProdSkuCodeSet = new Set<Id>();
        Map<Id, Set<Id>> prodToSetOfDealsMap = new Map<Id, Set<Id>>();

        for (EUR_CRM_ProductCatalogItemGrouping__c freeProd : [SELECT EUR_CRM_SKU__c, EUR_CRM_AnimationID__c  
            FROM EUR_CRM_ProductCatalogItemGrouping__c 
            WHERE EUR_CRM_AnimationID__c in :selectedIdsList]) 
        {
            Set<Id> setOfDeals = new Set<Id>();

            if (prodToSetOfDealsMap.containsKey(freeProd.EUR_CRM_SKU__c)) 
            {
                setOfDeals = prodToSetOfDealsMap.get(freeProd.EUR_CRM_SKU__c);
            }

            setOfDeals.add(freeProd.EUR_CRM_AnimationID__c);
            prodToSetOfDealsMap.put(freeProd.EUR_CRM_SKU__c, setOfDeals);
            
            dealProdSkuCodeSet.add(freeProd.EUR_CRM_SKU__c);
        }

        //collect main product codes
        Set<Id> prodSkuCodeSet = new Set<Id>();

        for (EUR_CRM_Product_in_Deal__c dealProd : [SELECT EUR_CRM_SKU__c, EUR_CRM_AnimationID__c 
            FROM EUR_CRM_Product_in_Deal__c 
            WHERE EUR_CRM_AnimationID__c in :selectedIdsList]) 
        {
            Set<Id> setOfDeals = new Set<Id>();

            if (prodToSetOfDealsMap.containsKey(dealProd.EUR_CRM_SKU__c)) 
            {
                setOfDeals = prodToSetOfDealsMap.get(dealProd.EUR_CRM_SKU__c);
            }

            setOfDeals.add(dealProd.EUR_CRM_AnimationID__c);
            prodToSetOfDealsMap.put(dealProd.EUR_CRM_SKU__c, setOfDeals);

            prodSkuCodeSet.add(dealProd.EUR_CRM_SKU__c);
        }

        //get a set containing IDL and DB catalog names 
        EUR_NIM_Sales_Order_Setting__mdt productCatalogNameIDL = EUR_COMMON_Utils.getSalesOrderMetadataValuesByCountryCode(COUNTRY_CODE_IDL);
        EUR_NIM_Sales_Order_Setting__mdt productCatalogNameDB = EUR_COMMON_Utils.getSalesOrderMetadataValuesByCountryCode(COUNTRY_CODE_DB);
        Set<String> productCatalogSet = new Set<String>{productCatalogNameIDL.EUR_NIM_Catalog_Name__c, productCatalogNameDB.EUR_NIM_Catalog_Name__c};
        
        Map<String, EUR_CRM_ProductCatalogItem__c> articleNumToCatalogItemMap = new Map<String, EUR_CRM_ProductCatalogItem__c>();
        for (EUR_CRM_ProductCatalogItem__c prod : [SELECT EUR_CRM_SKU__r.EUR_CRM_Category_Name__c, EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name,
                EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Id, EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c, 
                EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c 
                FROM EUR_CRM_ProductCatalogItem__c 
                WHERE EUR_CRM_PriceBookID__r.Name IN :productCatalogSet
                AND EUR_CRM_SKU__c IN :prodToSetOfDealsMap.keyset()]) 
        {

            //catalog item
            if (articleNumToCatalogItemMap.containsKey(prod.EUR_CRM_SKU__r.EUR_CRM_Article_no__c)) continue;
            articleNumToCatalogItemMap.put(prod.EUR_CRM_SKU__r.EUR_CRM_Article_no__c, prod);
        }
        
        List<EUR_CRM_Deal__c> deals = [SELECT Id, Name, EUR_CRM_Objectives_Promotions__c, EUR_CRM_Objectives_Promotions__r.Name,
                (SELECT EUR_CRM_AnimationID__c, EUR_CRM_AnimationID__r.Name, 
                EUR_CRM_Quantity__c, EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Name, 
                EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c, EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c 
                FROM Products_in_Animation__r),
                (SELECT  EUR_CRM_AnimationID__c, EUR_CRM_Quantity__c, 
                EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Name, EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c, 
                EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c from Price_Book_EntryGrouping__r)
                FROM EUR_CRM_Deal__c 
                WHERE Id IN :selectedIdsList];        
        
        Map<String, Map<String, String>> dealIdToProdIdMap = new Map<String, Map<String, String>>();
    
        List<EUR_CRM_ProductCatalogItemGrouping__c> priceBookEntryGroupingList = new List<EUR_CRM_ProductCatalogItemGrouping__c>();
        List<EUR_CRM_Product_in_Deal__c> productsInDealList = new List<EUR_CRM_Product_in_Deal__c>();

        for (EUR_CRM_Deal__c deal : deals) 
        {
            productsInDealList.addAll(deal.Products_in_Animation__r);
            priceBookEntryGroupingList.addAll(deal.Price_Book_EntryGrouping__r);

            if (deal.Products_in_Animation__r.isEmpty() || deal.Price_Book_EntryGrouping__r.isEmpty()) continue;
            EUR_CRM_Product_in_Deal__c mainProd = deal.Products_in_Animation__r[0];

            Map<String, String> dealProdToMainProd = new Map<String, String>();
            for (EUR_CRM_ProductCatalogItemGrouping__c pbegProd : deal.Price_Book_EntryGrouping__r) 
            {
                dealProdToMainProd.put(pbegProd.EUR_CRM_SKU__r.EUR_CRM_Article_no__c, mainProd.EUR_CRM_SKU__r.EUR_CRM_Article_no__c);
            }
            dealIdToProdIdMap.put(deal.Id, dealProdToMainProd);
        }
        
        Integer indexOfMainProd = 0;

        List<EUR_NIM_Service.LineItemWrapper> allLineItemWrappers = new List<EUR_NIM_Service.LineItemWrapper>();
        for (String selectedDealId : selectedIdsList) 
        {
            priceBookMap = getPriceBookEntryGrouping(selectedDealId, priceBookEntryGroupingList);
            productDealMap = getProductsInDeal(selectedDealId, productsInDealList);

            Map<String, String> dealProdToMainProd = dealIdToProdIdMap.get(selectedDealId);
            System.debug('dealProdToMainProd: ' + dealProdToMainProd);
            List<EUR_NIM_Service.LineItemWrapper> lineItemWrappers = new List<EUR_NIM_Service.LineItemWrapper>();

            for (EUR_CRM_ProductCatalogItem__c p : articleNumToCatalogItemMap.values())
            {
                Set<Id> setOfDealIdsForThisProd = prodToSetOfDealsMap.get(p.EUR_CRM_SKU__c);
                if(!setOfDealIdsForThisProd.contains(selectedDealId)) continue;

                String mainProdCode = dealProdToMainProd.get(p.EUR_CRM_SKU__r.EUR_CRM_Article_no__c);

                //set deal products
                if (dealProdSkuCodeSet.contains(p.EUR_CRM_SKU__c) && mainProdCode != null) 
                {
                    EUR_NIM_Service.LineItemWrapper li = creteLineItemObj(p, priceBookMap, productDealMap, true);
                    DealWrapper getDealInfo = productDealMap.get(mainProdCode);
                    li.dealName = getDealInfo.dealName;
                    li.productRequiredQuantity = (Integer)getDealInfo.quantity;
                    lineItemWrappers.add(li);
                }

                DealWrapper getDealInfo = productDealMap.get(p.EUR_CRM_SKU__r.EUR_CRM_Article_no__c);
                //set main products
                if (prodSkuCodeSet.contains(p.EUR_CRM_SKU__c) && getDealInfo != null) 
                {
                    EUR_NIM_Service.LineItemWrapper li = creteLineItemObj(p, priceBookMap, productDealMap, false);
                    li.dealName = getDealInfo.dealName;
                    lineItemWrappers.add(li);
                }
                lineItemWrappers.sort();
            }
            allLineItemWrappers.addAll(lineItemWrappers);
        }
        system.debug('allLineItemWrappers: ' + allLineItemWrappers);

        
        return allLineItemWrappers;
    }

    private static EUR_NIM_Service.LineItemWrapper creteLineItemObj(EUR_CRM_ProductCatalogItem__c prod, Map<String, DealWrapper> priceBookMap, Map<String, DealWrapper> productDealMap, Boolean isDeal) 
    {
        EUR_NIM_Service.LineItemWrapper li = new EUR_NIM_Service.LineItemWrapper();
        li.priceBook = prod.Id;
        li.productName = prod.EUR_CRM_SKU__r.Name;
        li.productCode = prod.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
        li.priceBookMap = priceBookMap;
        li.productDealMap = productDealMap;
        li.productStockInfo = prod.EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c; 
        li.isDeal = isDeal;
        li.productCodeIsDeal = li.productCode + li.isDeal;
        return li;
    }

    /**
    * @Description Method to get offers i.e. Price Book Entry Grouping based on the selected deals
    * Product Code i.e. EUR_CRM_SKU__r.EUR_CRM_Article_no__c used as a key here assuming 1 product will be in only 1 deal
    * @return Map<Id,DealWrapper>
    */
    public static Map<String,DealWrapper> getPriceBookEntryGrouping(String dealId, List<EUR_CRM_ProductCatalogItemGrouping__c> allPriceBookEntryGroupingList)
    {
        system.debug('dealId: ' + dealId);

        List<EUR_CRM_ProductCatalogItemGrouping__c> priceBookEntryGroupingList = new List<EUR_CRM_ProductCatalogItemGrouping__c>();
        for (EUR_CRM_ProductCatalogItemGrouping__c pbeg : allPriceBookEntryGroupingList) 
        {
            if (pbeg.EUR_CRM_AnimationID__c == dealId) 
            {
                priceBookEntryGroupingList.add(pbeg);
            }
        }
        /*List<EUR_CRM_ProductCatalogItemGrouping__c> priceBookEntryGroupingList = [SELECT EUR_CRM_AnimationID__c, EUR_CRM_Quantity__c, EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Name, EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c, EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c 
        FROM EUR_CRM_ProductCatalogItemGrouping__c
        WHERE EUR_CRM_AnimationID__c in :dealIds];*/

        Map<String, DealWrapper> priceBookMap = new Map<String, DealWrapper>();
        for(EUR_CRM_ProductCatalogItemGrouping__c priceBookGroup : priceBookEntryGroupingList)
        {
            DealWrapper dealDetails = new DealWrapper();
            dealDetails.dealId = priceBookGroup.EUR_CRM_AnimationID__c;
            dealDetails.dealLogic = priceBookGroup.EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c;
            dealDetails.isMultiply = priceBookGroup.EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c;
            dealDetails.quantity = priceBookGroup.EUR_CRM_Quantity__c;
            dealDetails.productCode = priceBookGroup.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
            priceBookMap.put(priceBookGroup.EUR_CRM_SKU__r.EUR_CRM_Article_no__c, dealDetails);            
        }
        system.debug('priceBookMap:'+priceBookMap);
        return priceBookMap;
    }

    /**
    * @Description Method to products in the selected deals
    * Product Code i.e. EUR_CRM_SKU__r.EUR_CRM_Article_no__c used as a key here assuming 1 product will be in only 1 deal
    * @return Map<Id,DealWrapper> Here Key is EUR_CRM_SKU__r.EUR_CRM_Article_no__c i.e. ProductCode
    */
    public static Map<String,DealWrapper> getProductsInDeal(String dealId, List<EUR_CRM_Product_in_Deal__c> allproductsInDealList)
    {
        /*List<EUR_CRM_Product_in_Deal__c> productsInDealList = [SELECT EUR_CRM_AnimationID__c, EUR_CRM_AnimationID__r.Name, 
                                    EUR_CRM_Quantity__c, EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Name, 
                                    EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c, EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c 
        FROM EUR_CRM_Product_in_Deal__c
        WHERE EUR_CRM_AnimationID__c in :dealIds];*/

        List<EUR_CRM_Product_in_Deal__c> productsInDealList = new List<EUR_CRM_Product_in_Deal__c>();

        for (EUR_CRM_Product_in_Deal__c prodInDeal : allproductsInDealList) 
        {
            if (prodInDeal.EUR_CRM_AnimationID__c == dealId) 
            {
                productsInDealList.add(prodInDeal);
            }
        }

        Map<String, DealWrapper> productDealMap = new Map<String, DealWrapper>();
        for(EUR_CRM_Product_in_Deal__c productInDeal : productsInDealList)
        {
            DealWrapper dealDetails = new DealWrapper();
            dealDetails.dealId = productInDeal.EUR_CRM_AnimationID__c;
            dealDetails.dealLogic = productInDeal.EUR_CRM_AnimationID__r.EUR_CRM_Deal_logic__c;
            dealDetails.isMultiply = productInDeal.EUR_CRM_AnimationID__r.EUR_CRM_Multiply__c;
            dealDetails.quantity = productInDeal.EUR_CRM_Quantity__c;
            dealDetails.productCode = productInDeal.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
            dealDetails.dealName = productInDeal.EUR_CRM_AnimationID__r.Name;
            productDealMap.put(productInDeal.EUR_CRM_SKU__r.EUR_CRM_Article_no__c, dealDetails);            
        }
        return productDealMap;
    }

    public class DealWrapper
    {
        @AuraEnabled
        public String dealId { get; set; }
        @AuraEnabled
        public String dealLogic { get; set; }
        @AuraEnabled
        public Boolean isMultiply{get;set;}
        @AuraEnabled  
        public String productCode { get; set; }	
        @AuraEnabled
        public Decimal quantity{get;set;}   
        @AuraEnabled
        public String dealName{get;set;}   
    }
}