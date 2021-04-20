/**********************************************************************************
 * Name : ASI_CRM_SG_GenWholesalerDepletion_Batch
 * Created : DC @03/29/2016 3:03 PM
 * Revision History:
 * 1. 03/29/2016 - [DC 1.0] Created
 * 2. 03/31/2016 - [DC 2.0] Updated class to get Ids from trigger and removed Schedulable logic.
 * 3. 04/07/2016 - [DC 3.0] Applied checking before creating Wholesaler Depletion records.
 * 3. 04/07/2016 - [DC 3.1] Removed code for invoking batch via trigger on SKU.
 * 4. 07 Apr 2016 - [VL 4.0] Fix DC's bugs
 *                  [VL 4.1] Only allow creating depletion data for wholesaler
 *                  [VL 4.2] No need to check FOC request, sales order history contains info. of FOC
 **********************************************************************************/

global class ASI_CRM_SG_GenWholesalerDepletion_Batch 
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private String query;
    // DC - 04/20/2016 - Commented variables as which are not getting used.
    // private Set<Id> setSkuIds; 
    // public Set<Id> setSku;

    List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstWholesalerDepletions =
            new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
            
    /* [DC 3.0] BEGIN */
    
    List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstRecordWholesalerDepletions =
            new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
    
    /* [DC 3.0] END */

    private List<ASI_CRM_AccountsAdditionalField__c> lstFetchedCustomers =
        [SELECT Id
           FROM ASI_CRM_AccountsAdditionalField__c
          WHERE RecordType.DeveloperName = 'ASI_CRM_SG_Wholesaler'];
    
    /* [VL 4.1] BEGIN */
    private Map<id, ASI_CRM_AccountsAdditionalField__c> map_wholesalerID_wholesaler = new Map<id, ASI_CRM_AccountsAdditionalField__c>(lstFetchedCustomers);
    /* [VL 4.1] END */
    
    private Id depletionRecordTypeId = 
        Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.getRecordTypeInfosByName()
              .get('ASI_CRM_SG_WS_Depletion').getRecordTypeId();
        
    private Map<id, id> map_sku_subBrand = new Map<id, id>();
    
    public ASI_CRM_SG_GenWholesalerDepletion_Batch() {

        query = '  SELECT Id'
              + '       , Name'
              + '    FROM ASI_MFM_SKU_Code__c'
              + '   WHERE RecordType.DeveloperName = \'ASI_CRM_SG_SKU\' limit 1';
            /* [VL 4.0] BEGIN */
            /*
            + '     AND CreatedDate = TODAY'; // Added condition as batch is supposed to run daily.
             */
            /* [VL 4.0] BEGIN */
    }

    /* [DC 3.1] BEGIN */
    /* public ASI_CRM_SG_GenWholesalerDepletion_Batch(Set<Id> pSetSkuIds) {

        setSkuIds = pSetSkuIds;

        query = '  SELECT Id'
              + '       , Name'
              + '    FROM ASI_MFM_SKU_Code__c'
              + '   WHERE RecordType.DeveloperName = \'ASI_CRM_SG_SKU\''
              + '     AND Id IN : setSkuIds'; // Added condition if batch is invoked from trigger.
    } */
    /* [DC 3.1] END */

    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext contextInstance, list<Sobject> pLstFetchedRecords) {
        List<ASI_MFM_SKU_Code__c> lstFetchedRecords = (List<ASI_MFM_SKU_Code__c>) pLstFetchedRecords;
        /* [DC 3.0] BEGIN */
        map<Id, Set<Id>> mapCustomerId_SkuIds= new map<Id, Set<Id>>();
        map<Id, Set<Id>> mapCustomerId_ActualOfftakeSkuIds = new map<Id, Set<Id>>();
        /* [VL 4.2] BEGIN */
        /*
        map<Id, Set<Id>> mapCustomerId_FocRequestSkuIds = new map<Id, Set<Id>>();
        */
        /* [VL 4.2] END */
        map<Id, Set<Id>> mapCustomerId_SalesOrderSkuIds = new map<Id, Set<Id>>();
        map<Id, Set<Id>> mapCustomerId_SkuIds_ToGenerate = new map<Id, Set<Id>>();

        // DC - Fetched existing wholesaler depletion records.
        lstRecordWholesalerDepletions = [SELECT ASI_TH_CRM_Date__c
                                              , ASI_CRM_SKU__c
                                              , ASI_CRM_Customer__c
                                           FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
                                          WHERE RecordType.DeveloperName ='ASI_CRM_SG_WS_Depletion'                                         
                                       ORDER BY ASI_TH_CRM_Date__c ASC];
                                            
        Date earliestDate = lstRecordWholesalerDepletions[0].ASI_TH_CRM_Date__c;

        // DC - Created map for mapping SKU Ids to Customers from existing Wholesaler Depletion data.
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c offtakeIterartor : lstRecordWholesalerDepletions) {
            if( offtakeIterartor.ASI_CRM_Customer__c != null &&  offtakeIterartor.ASI_CRM_SKU__c != null) {
                mapCustomerId_SkuIds = mapCustomerIdSkuId(
                                           mapCustomerId_SkuIds, 
                                           offtakeIterartor.ASI_CRM_Customer__c, 
                                           offtakeIterartor.ASI_CRM_SKU__c );
            }
        }
        
        system.debug('------------ mapCustomerId_SkuIds ------------'+mapCustomerId_SkuIds);
            
        
        // DC - Fetched existing Actual Offtake records.
        List<ASI_TH_CRM_Actual_Offtake__c> lstActualOfftake = 
                new List<ASI_TH_CRM_Actual_Offtake__c>([SELECT Id
                                                            /* [VL 4.0] BEGIN */
                                                            /*
                                                             , ASI_CRM_SG_Customer__c
                                                            */
                                                            , ASI_CRM_FromWS__c 
                                                            /* [VL 4.0] END */
                                                             , ASI_CRM_SKU__c
                                                            , ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c
                                                          FROM ASI_TH_CRM_Actual_Offtake__c
                                                         WHERE RecordType.DeveloperName = 'ASI_CRM_SG_Actual_offtake'
                                                            AND ASI_CRM_FromWS__c <> null
                                                            AND ASI_CRM_SKU__c <> null
                                                            /* [VL 4.1] BEGIN */
                                                            AND ASI_CRM_FromWS__c in :map_wholesalerID_wholesaler.keySet()
                                                            /* [VL 4.1] END */
                                                           AND (LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY)]);
                                                           // AND CreatedDate = YESTERDAY]);
        
        // DC - Created map for mapping SKU Ids to Customers from Actual Offtake data
        /* [VL 4.0] BEGIN */
        /*
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftakeIterartor: lstActualOfftake) {
            if( actualOfftakeIterartor.ASI_CRM_SG_Customer__c != null &&  actualOfftakeIterartor.ASI_CRM_SKU__c != null) {
                mapCustomerId_ActualOfftakeSkuIds = mapCustomerIdSkuId(
                                                        mapCustomerId_ActualOfftakeSkuIds, 
                                                        actualOfftakeIterartor.ASI_CRM_SG_Customer__c, 
                                                        actualOfftakeIterartor.ASI_CRM_SKU__c );
            }
        }
        */
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftakeIterartor: lstActualOfftake) {
            if( actualOfftakeIterartor.ASI_CRM_FromWS__c != null &&  actualOfftakeIterartor.ASI_CRM_SKU__c != null) {
                mapCustomerId_ActualOfftakeSkuIds = mapCustomerIdSkuId(
                                                        mapCustomerId_ActualOfftakeSkuIds, 
                                                        actualOfftakeIterartor.ASI_CRM_FromWS__c, 
                                                        actualOfftakeIterartor.ASI_CRM_SKU__c );
                map_sku_subBrand.put(actualOfftakeIterartor.ASI_CRM_SKU__c, actualOfftakeIterartor.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
            }
        }
        /* [VL 4.0] END */
        system.debug('------------ mapCustomerId_ActualOfftakeSkuIds ------------'+mapCustomerId_ActualOfftakeSkuIds);
            
        
        /* [VL 4.2] BEGIN */
        /*
        // DC - Fetched existing FOC Request records.
        List<ASI_FOC_Request_Item__c> lstFocRequestItem = 
                new List<ASI_FOC_Request_Item__c>([SELECT Id
                                                        , ASI_CRM_Wholesaler__c
                                                        , ASI_FOC_SKU__c
                                                     FROM ASI_FOC_Request_Item__c
                                                    WHERE RecordType.DeveloperName = 'ASI_SG_CRM_Request_Items'
                                                      AND (LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY)]);
                                                      // AND CreatedDate = YESTERDAY]);
        
        // DC - Created map for mapping SKU Ids to Customers from FOC Request Item data
        for(ASI_FOC_Request_Item__c focRequestIterator: lstFocRequestItem) {
            if( focRequestIterator.ASI_CRM_Wholesaler__c != null && focRequestIterator.ASI_FOC_SKU__c != null) {
            mapCustomerId_FocRequestSkuIds = mapCustomerIdSkuId(
                                                 mapCustomerId_FocRequestSkuIds, 
                                                 focRequestIterator.ASI_CRM_Wholesaler__c, 
                                                 focRequestIterator.ASI_FOC_SKU__c );
            }
        }
        */
        /* [VL 4.2] END */
        
        // DC - Fetched existing Sales Order History records.
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> lstSalesOrderHistory = 
              new List<ASI_HK_CRM_Sales_Order_History_Detail__c>([SELECT Id
                                                                        /* [VL 4.0] BEGIN */
                                                                        /*
                                                                         , ASI_CRM_Customer_Name__c
                                                                        */
                                                                        , ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c 
                                                                        /* [VL 4.0] END */
                                                                       , ASI_HK_CRM_Product_SKU__c
                                                                        , ASI_HK_CRM_Product_SKU__r.ASI_MFM_Sub_brand__c
                                                                    FROM ASI_HK_CRM_Sales_Order_History_Detail__c
                                                                   WHERE RecordType.DeveloperName = 'ASI_CRM_SG_Sales_Order_History_Detail'
                                                                  AND ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c <> null
                                                                  AND ASI_HK_CRM_Product_SKU__c <> null
                                                                    /* [VL 4.1] BEGIN */
                                                                    AND ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c in :map_wholesalerID_wholesaler.keySet()
                                                                    /* [VL 4.1] END */
                                                                    /* [VL 4.2] BEGIN */
                                                                    AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c in ('Singapore DF & DP Free Issue - F1','Singapore DF & DP Sales Order - SO')
                                                                    /* [VL 4.2] END */
                                                                     AND (LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY)]);

        // DC - Created map for mapping SKU Ids to Customers from Sales Order History data
        /* [VL 4.0] BEGIN */
        /*
        for(ASI_HK_CRM_Sales_Order_History_Detail__c salesOrderIterator: lstSalesOrderHistory) {
            if( salesOrderIterator.ASI_CRM_Customer_Name__c != null && salesOrderIterator.ASI_HK_CRM_Product_SKU__c != null) {
            mapCustomerId_SalesOrderSkuIds = mapCustomerIdSkuId(
                                                 mapCustomerId_SalesOrderSkuIds, 
                                                 salesOrderIterator.ASI_CRM_Customer_Name__c, 
                                                 salesOrderIterator.ASI_HK_CRM_Product_SKU__c );
            }
        }
        */
        for(ASI_HK_CRM_Sales_Order_History_Detail__c salesOrderIterator: lstSalesOrderHistory) {
            if( salesOrderIterator.ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c != null && salesOrderIterator.ASI_HK_CRM_Product_SKU__c != null) {
                mapCustomerId_SalesOrderSkuIds = mapCustomerIdSkuId(
                                                 mapCustomerId_SalesOrderSkuIds, 
                                                 salesOrderIterator.ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c, 
                                                 salesOrderIterator.ASI_HK_CRM_Product_SKU__c );
                map_sku_subBrand.put(salesOrderIterator.ASI_HK_CRM_Product_SKU__c, salesOrderIterator.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Sub_brand__c);
            }
        }
        /* [VL 4.0] END */
        system.debug('------------ mapCustomerId_SalesOrderSkuIds ------------'+mapCustomerId_SalesOrderSkuIds);
            

        // DC - Validating data from Actual Offtake to generate wholesaler depletion records.
        for(Id customerIterator : mapCustomerId_ActualOfftakeSkuIds.keySet()) {
            
            /* [VL 4.1] BEGIN */
            /*
            if( !mapCustomerId_SkuIds.containsKey(customerIterator)
            &&  !mapCustomerId_SkuIds_ToGenerate.containsKey(customerIterator) ) {

                mapCustomerId_SkuIds_ToGenerate.put(
                    customerIterator,
                    mapCustomerId_ActualOfftakeSkuIds.get(customerIterator)
                );
                continue;
            }
            */
            if( !mapCustomerId_SkuIds.containsKey(customerIterator) ) {
                continue;
            }
            /* [VL 4.1] END */

            for(Id skuItereator : mapCustomerId_ActualOfftakeSkuIds.get(customerIterator)) {

                if( !mapCustomerId_SkuIds.get(customerIterator).contains(skuItereator) ) {
                    mapCustomerId_SkuIds_ToGenerate = mapCustomerIdSkuId(
                        mapCustomerId_SkuIds_ToGenerate,
                        customerIterator,
                        skuItereator
                    );
                }

            }
        }

        // DC - Validating data from FOC Request Item to generate wholesaler depletion records.
        /* [VL 4.1] END */
        /*
        for(Id customerIterator : mapCustomerId_FocRequestSkuIds.keySet()) {
            
            if( !mapCustomerId_SkuIds.containsKey(customerIterator)
            &&  !mapCustomerId_SkuIds_ToGenerate.containsKey(customerIterator) ) {

                mapCustomerId_SkuIds_ToGenerate.put(
                    customerIterator,
                    mapCustomerId_FocRequestSkuIds.get(customerIterator)
                );
                continue;
            }

            for(Id skuItereator : mapCustomerId_FocRequestSkuIds.get(customerIterator)) {

                if( !mapCustomerId_SkuIds.get(customerIterator).contains(skuItereator) ) {
                    mapCustomerId_SkuIds_ToGenerate = mapCustomerIdSkuId(
                        mapCustomerId_SkuIds_ToGenerate,
                        customerIterator,
                        skuItereator
                    );
                }

            }
        }
        */
        /* [VL 4.1] END */

        // DC - Validating data from Sales Order History to generate wholesaler depletion records.
        for(Id customerIterator : mapCustomerId_SalesOrderSkuIds.keySet()) {
            
            /* [VL 4.1] BEGIN */
            /*
            if( !mapCustomerId_SkuIds.containsKey(customerIterator)
            &&  !mapCustomerId_SkuIds_ToGenerate.containsKey(customerIterator) ) {

                mapCustomerId_SkuIds_ToGenerate.put(
                    customerIterator,
                    mapCustomerId_SalesOrderSkuIds.get(customerIterator)
                );
                continue;
            }
            */
            if( !mapCustomerId_SkuIds.containsKey(customerIterator) ) {
                continue;
            }
            /* [VL 4.1] END */

            for(Id skuItereator : mapCustomerId_SalesOrderSkuIds.get(customerIterator)) {

                if( !mapCustomerId_SkuIds.get(customerIterator).contains(skuItereator) ) {
                    mapCustomerId_SkuIds_ToGenerate = mapCustomerIdSkuId(
                        mapCustomerId_SkuIds_ToGenerate,
                        customerIterator,
                        skuItereator
                    );
                }

            }
        }
        /* [DC 3.0] END */
        
        earliestDate = earliestDate.toStartOfMonth();
        Date earliestDatePlaceHolder;

        /* [DC 3.0] BEGIN */
        /*for(ASI_MFM_SKU_Code__c skuItereator : lstFetchedRecords) {
            
            for(ASI_CRM_AccountsAdditionalField__c customerIterator : lstFetchedCustomers) {*/
                
        for(Id customerIterator : mapCustomerId_SkuIds_ToGenerate.keySet()) {
            
            for(Id skuItereator : mapCustomerId_SkuIds_ToGenerate.get(customerIterator) ) {
        /* [DC 3.0] END */
                
                earliestDatePlaceHolder = earliestDate;
                
                    while(earliestDatePlaceHolder <= Date.today()) { 
                    lstWholesalerDepletions.add( new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(                       
                                RecordTypeId = depletionRecordTypeId,
                                // ASI_CRM_SKU__c = skuItereator.Id,
                                ASI_CRM_SKU__c = skuItereator, // DC 3.0
                                ASI_TH_CRM_Date__c = earliestDatePlaceHolder,
                                // ASI_CRM_Customer__c = customerIterator.Id,
                                ASI_CRM_Customer__c = customerIterator, // DC 3.0
                                ASI_TH_CRM_Beginning_Stock__c = 0,
                                ASI_TH_CRM_FOC__c = 0,
                                ASI_TH_CRM_Total_Offtake_Final__c = 0,
                                ASI_TH_CRM_Sell_In__c = 0,
                                ASI_TH_CRM_Sub_brand__c = map_sku_subBrand.get(skuItereator)
                            ) );
    
                        earliestDatePlaceHolder = earliestDatePlaceHolder.addMonths(1);
                }
            }
        }

        try {

            system.debug('------------ lstWholesalerDepletions ------------'+lstWholesalerDepletions);
            
            if( !lstWholesalerDepletions.isEmpty() ) {
                insert lstWholesalerDepletions;
            }

        } catch(DmlException exceptionInstance) {
            // DC - TODO : Nothing
        }
    }
    
    /* [DC 3.0] BEGIN */
    global map<Id, Set<Id>> mapCustomerIdSkuId( map<Id, Set<Id>> mapCustomer_Sku, String customerId, String skuId ) {
        if( !mapCustomer_Sku.containsKey(customerId) ) {
            mapCustomer_Sku.put(
                customerId,
                new Set<Id> {skuId}
            );
    
        } else {
            mapCustomer_Sku.get(customerId).add(skuId);
        }
        return mapCustomer_Sku;
    }
    /* [DC 3.0] END */

    /* [DC 3.1] BEGIN */
    public void execute(SchedulableContext contextInstance) {}
    /* [DC 3.1] END */

    global void finish(Database.BatchableContext contextInstance) {
        // DC - TODO : Nothing
    }
}