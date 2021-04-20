/*********************************************************************************
 * Name: ASI_CRM_SG_TBCN_ManageAll_Controller
 * Description: Controller class
 * Test Class: ASI_CRM_SG_TBCN_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-05-30       Laputa: Hugo Cheung     Created
 * 2016-07-25       Laputa: Vincent         [VL 1.0] in search SKU, only return those Short Description <> "."
 * 2017-06-20       Wilken Lee              [WL 1.0] All filter to limit SO History Order Date with 30 days before Return Order's Order Date to be shown
 * 2017-07-11       Wilken Lee              [WL 2.0] Due to change in WS User default Customer to Outlet SG record type, SO History search need to change from Sold To to Customer Name
 * 2018-02-26       Wilken Lee              [WL 3.0] Change TBCN Order to show SKU Name instead of JDE Search Text
 * 2018-05-18       Wilken Lee              [WL 4.0] CHM118094871 Remove 30 day order date filter
 */

public without sharing class ASI_CRM_SG_TBCN_ManageAll_Controller extends ASI_CRM_SG_PageControllerBase {

    private static String SALES_ORDER_REQUEST_RECORD_TYPE        = 'ASI_CRM_SG_TBCN';
    private static String SALES_ORDER_HISTORY_ORDER_TYPE         = 'Singapore DF & DP Sales Order - SO';
    private static String SKU_RECORD_TYPE                        = 'ASI_CRM_SG_SKU';
    private static String SALES_ORDER_HISTORY_DETAIL_RECORD_TYPE = 'ASI_CRM_SG_Sales_Order_History_Detail';

    public static String LINE_ITEM_NEW_RECORD_PREFIX {get {return 'zzzzzITEMLINEZ'; }}
    public Integer LINE_ITEM_NEW_REOCRD_COUNTER {get; set;} {
        LINE_ITEM_NEW_REOCRD_COUNTER = 0;
    }

    private ApexPages.StandardController standardController {get; set;}

    public ASI_KOR_Sales_Order_Request__c tbcnHeader {get; set;}
    public Map<String, TBCNLineItemWrapper> tbcnLineItemWrapperMap {get; set;} { 
        tbcnLineItemWrapperMap = new Map<String, TBCNLineItemWrapper>();
    }

    public Map<String, ASI_MFM_SKU_Code__c> skuMap {get; set;} {
        skuMap = new Map<String, ASI_MFM_SKU_Code__c>();
    }

    public Map<String, ASI_MFM_SKU_Code__c> addedSKUMap {get; set;} {
        addedSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();
    }

    public Map<String, ASI_HK_CRM_Sales_Order_History_Detail__c> salesOrderHistoryDetailMap {get; set;} {
        salesOrderHistoryDetailMap = new Map<String, ASI_HK_CRM_Sales_Order_History_Detail__c>();
    }

    public Map<String, ASI_HK_CRM_Sales_Order_History_Detail__c> addedSalesOrderHistoryDetailMap {get; set;} {
        addedSalesOrderHistoryDetailMap = new Map<String, ASI_HK_CRM_Sales_Order_History_Detail__c>();
    }

    private List<ASI_KOR_Sales_Order_Transaction__c> deleteSalesOrderLineList {get; set;} {
        deleteSalesOrderLineList = new List<ASI_KOR_Sales_Order_Transaction__c>();
    }

    public String skuCodeFilter {get; set;}
    public String skuNameFilter {get; set;}
    public String salesOrderHistorySKUCodeFilter {get; set;}
    public String salesOrderHistorySKUNameFilter {get; set;}
    public String salesOrderHistoryOrderNoFilter {get; set;}
    public String salesOrderHistoryJDEInvoiceNoFilter {get; set;}
    public String salesOrderHistoryLotNoFilter {get; set;}
    public String salesOrderHistoryCustomerPO {get; set;}

    public ASI_CRM_SG_TBCN_ManageAll_Controller(ApexPages.StandardController standardController) {
        this.standardController = standardController;

        Id tbcnId = ((ASI_KOR_Sales_Order_Request__c)standardController.getRecord()).id;

		/*[WL 1.0 Begin]*/
        //tbcnHeader = [SELECT Id, 
		tbcnHeader = [SELECT Id, ASI_CRM_SG_Order_Date__c, 
		/*[WL 1.0 End]*/
                      Name,
                      ASI_CRM_SG_Customer__c 
                      FROM ASI_KOR_Sales_Order_Request__c
                      WHERE Id = :tbcnId
                      ];

        List<ASI_KOR_Sales_Order_Transaction__c> tbcnOrderLineItemList = [SELECT Id,
                                                                          ASI_CRM_SG_SKU__c,
                                                                          ASI_CRM_SG_SKU__r.Name,
                                                                          ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c,
                                                                          ASI_CRM_Sales_Order_History_Detail__c,
                                                                          ASI_CRM_Sales_Order_History_Detail__r.Name,
                                                                          ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c,
                                                                          ASI_CRM_SG_Request_Quantity_Bottle__c
                                                                          FROM ASI_KOR_Sales_Order_Transaction__c
                                                                          WHERE ASI_KOR_Sales_Order_Request__c = :tbcnHeader.id
                                                                          ];

        for(ASI_KOR_Sales_Order_Transaction__c tbcnOrderLineItem : tbcnOrderLineItemList) {
			/*[WL 3.0] BEGIN*/
            /*tbcnLineItemWrapperMap.put(tbcnOrderLineItem.Id, new TBCNLineItemWrapper(tbcnOrderLineItem, 
                                                                                     tbcnOrderLineItem.ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c,
                                                                                     tbcnOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.Name, 
                                                                                     tbcnOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c));*/
			tbcnLineItemWrapperMap.put(tbcnOrderLineItem.Id, new TBCNLineItemWrapper(tbcnOrderLineItem, 
                                                                                     tbcnOrderLineItem.ASI_CRM_SG_SKU__r.Name,
                                                                                     tbcnOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.Name, 
                                                                                     tbcnOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c));
			/*[WL 3.0] END*/
        }                                                                  
    }

    public void retrieveSKU() {
        
        skuMap = new Map<String, ASI_MFM_SKU_Code__c>();
        List<String> currentSalesOrderLineSKUList = new List<String>();
        for(TBCNLineItemWrapper tbcnLineItemWrapper : tbcnLineItemWrapperMap.values()) {

            if(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_Sales_Order_History_Detail__c == null) {

                currentSalesOrderLineSKUList.add(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_SG_SKU__c);

            }

        }

        String query = 'SELECT Id,' +
                       'Name,' +
                       'ASI_MFM_SKU_Code__c,' + 
                       'ASI_MFM_SKU_Description__c,' + 
                       'ASI_CRM_Short_Description__c,' + 
                       'ASI_HK_CRM_Pack_Factor__c,' + 
                       'ASI_HK_CRM_UOM1__c,' + 
                       'ASI_HK_CRM_UOM2__c,' + 
                       'ASI_HK_CRM_Std_Bottle_Size__c,' + 
                       'ASI_HK_CRM_Packaging_Size__c ' + 
                       'FROM ASI_MFM_SKU_Code__c ' + 
                       'WHERE RecordType.DeveloperName = :SKU_RECORD_TYPE AND ' + 
                       'ASI_HK_CRM_Active__c = TRUE AND ' + 
                       'Id not in :currentSalesOrderLineSKUList';

        if(String.isNotBlank(skuCodeFilter)) {
            query += ' AND ASI_MFM_SKU_Code__c LIKE \'%' + String.escapeSingleQuotes(skuCodeFilter.trim()) + '%\'';
        }

        if(String.isNotBlank(skuNameFilter)) {
            query += ' AND ASI_CRM_Short_Description__c LIKE \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
        }
        
        /* [VL 1.0] BEGIN */
        query += ' and ASI_CRM_Short_Description__c <> \'.\' ';
        /* [VL 1.0] END */
            
        query += ' ORDER BY ASI_MFM_SKU_Code__c ASC LIMIT 100 ';

        List<ASI_MFM_SKU_Code__c> skuList = Database.query(query);
        for(ASI_MFM_SKU_Code__c sku : skuList) {
            skuMap.put(sku.Id, sku);
        }

    }

    public void retrieveSalesOrderHistoryDetail() {
        if(!String.isNotBlank(tbcnHeader.ASI_CRM_SG_Customer__c)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal, 'TBCN record do not contain customer'));
            return;
        }

        salesOrderHistoryDetailMap = new Map<String, ASI_HK_CRM_Sales_Order_History_Detail__c>();

        List<String> currentSalesOrderHistoryDetailList = new List<String>();
        for(TBCNLineItemWrapper tbcnLineItemWrapper : tbcnLineItemWrapperMap.values()) {

            if(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_Sales_Order_History_Detail__c != null) {

                currentSalesOrderHistoryDetailList.add(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_Sales_Order_History_Detail__c);

            }

        }

        String tbcnHeaderCustomer = tbcnHeader.ASI_CRM_SG_Customer__c;
		Date soHistoryOrderDate = tbcnHeader.ASI_CRM_SG_Order_Date__c.addDays(-30);

        String query = 'SELECT Id,' + 
                       'Name,' + 
                       'ASI_HK_CRM_Sales_Order_History__c,' + 
                       'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c,' + 
                       'ASI_CRM_Lot_Number__c,' + 
                       'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c,' + 
                       'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Customer_PO__c,' + 
                       'ASI_HK_CRM_Product_SKU__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.Name,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_CRM_Short_Description__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Pack_Factor__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_UOM1__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_UOM2__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,' + 
                       'ASI_HK_CRM_Product_SKU__r.ASI_HK_CRM_Packaging_Size__c,' + 
                       'ASI_HK_CRM_Quantity_in_Bottles__c ' + 
                       'FROM ASI_HK_CRM_Sales_Order_History_Detail__c ' + 
                       'WHERE RecordType.DeveloperName = :SALES_ORDER_HISTORY_DETAIL_RECORD_TYPE AND ' + 
					   /*[WL 1.0 Begin]*/
					   /*[WL 4.0 Begin]*/
					   //'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c >= :soHistoryOrderDate AND ' + 
					   /*[WL 4.0 End]*/
					   /*[WL 1.0 End]*/
                       'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c = :SALES_ORDER_HISTORY_ORDER_TYPE AND ' + 
                       /*[WL 2.0 Begin]*/
					   //'ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_Sold_To__c = :tbcnHeaderCustomer AND ' + 
					   'ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c = :tbcnHeaderCustomer AND ' + 
					   /*[WL 2.0 End]*/
                       'Id not in :currentSalesOrderHistoryDetailList';

        if(String.isNotBlank(salesOrderHistorySKUCodeFilter)) {
            query += ' AND ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistorySKUCodeFilter.trim()) + '%\'';
        }

        if(String.isNotBlank(salesOrderHistorySKUNameFilter)) {
            query += ' AND ASI_HK_CRM_Product_SKU__r.ASI_CRM_Short_Description__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistorySKUNameFilter.trim()) + '%\'';
        }

        if(String.isNotBlank(salesOrderHistoryOrderNoFilter)) {
            query += ' AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistoryOrderNoFilter.trim()) + '%\'';
        }

        if(String.isNotBlank(salesOrderHistoryJDEInvoiceNoFilter)) {
            query += ' AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistoryJDEInvoiceNoFilter.trim()) + '%\'';
        }
        
        if(String.isNotBlank(salesOrderHistoryLotNoFilter)) {
            query += ' AND ASI_CRM_Lot_Number__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistoryLotNoFilter.trim()) + '%\'';
        }

        if(String.isNotBlank(salesOrderHistoryCustomerPO)) {
            query += ' AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Customer_PO__c LIKE \'%' + String.escapeSingleQuotes(salesOrderHistoryCustomerPO.trim()) + '%\'';
        }
        
        /* [VL 1.0] BEGIN */
        query += ' and ASI_HK_CRM_Product_SKU__r.ASI_CRM_Short_Description__c <> \'.\' ';
        /* [VL 1.0] END */
          
        query += ' ORDER BY ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c ASC LIMIT 100 ';
        
        system.debug('---salesOrderHistorySKUCodeFilter---'+salesOrderHistorySKUCodeFilter);
        system.debug('---salesOrderHistorySKUNameFilter---'+salesOrderHistorySKUNameFilter);
        system.debug('---salesOrderHistoryOrderNoFilter---'+salesOrderHistoryOrderNoFilter);
        system.debug('---salesOrderHistoryLotNoFilter---'+salesOrderHistoryLotNoFilter);
        system.debug('---salesOrderHistoryJDEInvoiceNoFilter---'+salesOrderHistoryJDEInvoiceNoFilter);
        system.debug('---query ---'+query );

        List<ASI_HK_CRM_Sales_Order_History_Detail__c> salesOrderHistoryDetailList = Database.query(query);
        for(ASI_HK_CRM_Sales_Order_History_Detail__c salesOrderHistoryDetail : salesOrderHistoryDetailList) {
            salesOrderHistoryDetailMap.put(salesOrderHistoryDetail.Id, salesOrderHistoryDetail);
        }

    }

    public void addSalesOrderLineItem() {
        Map<String, String> params                     = ApexPages.currentPage().getParameters();
        String param_SKU_Id                            = params.get('PARAM_SKU_ID');
        String param_SalesOrderHistoryDetail_Id        = params.get('PARAM_SALES_ORDER_HISTORY_DETAIL_ID');

        if(String.isNotBlank(param_SKU_Id) && 
            skuMap.containsKey(param_SKU_Id)) {

            ASI_MFM_SKU_Code__c tempSKU = skuMap.get(param_SKU_Id);

            ASI_KOR_Sales_Order_Transaction__c tempSalesOrderLineItem = new ASI_KOR_Sales_Order_Transaction__c(ASI_KOR_Sales_Order_Request__c   = tbcnHeader.Id,
                                                                                                               RecordTypeId                     = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_TBCN'),
                                                                                                               ASI_CRM_SG_SKU__c                = tempSKU.Id
                                                                                                              );
			/*[WL 3.0] BEGIN*/
            //tbcnLineItemWrapperMap.put(LINE_ITEM_NEW_RECORD_PREFIX + LINE_ITEM_NEW_REOCRD_COUNTER, new TBCNLineItemWrapper(tempSalesOrderLineItem, tempSKU.ASI_CRM_Short_Description__c));
			tbcnLineItemWrapperMap.put(LINE_ITEM_NEW_RECORD_PREFIX + LINE_ITEM_NEW_REOCRD_COUNTER, new TBCNLineItemWrapper(tempSalesOrderLineItem, tempSKU.Name));
			/*[WL 3.0] END*/
            skuMap.remove(tempSKU.Id);
            addedSKUMap.put(tempSKU.Id, tempSKU);

        } 

        if(String.isNotBlank(param_SalesOrderHistoryDetail_Id) && 
            salesOrderHistoryDetailMap.containsKey(param_SalesOrderHistoryDetail_Id)) {

            ASI_HK_CRM_Sales_Order_History_Detail__c tempSalesOrderHistoryDetail = salesOrderHistoryDetailMap.get(param_SalesOrderHistoryDetail_Id);

            ASI_KOR_Sales_Order_Transaction__c tempSalesOrderLineItem = new ASI_KOR_Sales_Order_Transaction__c(ASI_KOR_Sales_Order_Request__c        = tbcnHeader.Id,
                                                                                                               RecordTypeId                          = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_TBCN'),
                                                                                                               ASI_CRM_Sales_Order_History_Detail__c = tempSalesOrderHistoryDetail.Id,
                                                                                                               ASI_CRM_SG_SKU__c                     = tempSalesOrderHistoryDetail.ASI_HK_CRM_Product_SKU__c
                                                                                                              );
			/*[WL 3.0] BEGIN*/
            /*tbcnLineItemWrapperMap.put(LINE_ITEM_NEW_RECORD_PREFIX + LINE_ITEM_NEW_REOCRD_COUNTER, new TBCNLineItemWrapper(tempSalesOrderLineItem, 
                                                                                                                           tempSalesOrderHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_CRM_Short_Description__c,
                                                                                                                           tempSalesOrderHistoryDetail.Name, 
                                                                                                                           tempSalesOrderHistoryDetail.ASI_HK_CRM_Quantity_in_Bottles__c));*/
			tbcnLineItemWrapperMap.put(LINE_ITEM_NEW_RECORD_PREFIX + LINE_ITEM_NEW_REOCRD_COUNTER, new TBCNLineItemWrapper(tempSalesOrderLineItem, 
                                                                                                                           tempSalesOrderHistoryDetail.ASI_HK_CRM_Product_SKU__r.Name,
                                                                                                                           tempSalesOrderHistoryDetail.Name, 
                                                                                                                           tempSalesOrderHistoryDetail.ASI_HK_CRM_Quantity_in_Bottles__c));																														   
			/*[WL 3.0] END*/
            salesOrderHistoryDetailMap.remove(tempSalesOrderHistoryDetail.Id);
            addedSalesOrderHistoryDetailMap.put(tempSalesOrderHistoryDetail.Id, tempSalesOrderHistoryDetail);

        }

        LINE_ITEM_NEW_REOCRD_COUNTER++;
    }

    public void removeSalesOrderLineItem() {
        Map<String, String> params                     = ApexPages.currentPage().getParameters();
        String salesOrderLineItemId                    = params.get('PARAM_SALES_ORDER_LINE_ITEM_ID');

        ASI_KOR_Sales_Order_Transaction__c delTBCNLineItem = tbcnLineItemWrapperMap.get(salesOrderLineItemId).tbcnLineItem;

        if(delTBCNLineItem.Id != null) {

            deleteSalesOrderLineList.add(delTBCNLineItem);

        } else {

            if(delTBCNLineItem.ASI_CRM_Sales_Order_History_Detail__c != null && 
                addedSalesOrderHistoryDetailMap.containsKey(delTBCNLineItem.ASI_CRM_Sales_Order_History_Detail__c)) {

                ASI_HK_CRM_Sales_Order_History_Detail__c tempSalesOrderHistoryDetail = addedSalesOrderHistoryDetailMap.get(delTBCNLineItem.ASI_CRM_Sales_Order_History_Detail__c);

                salesOrderHistoryDetailMap.put(tempSalesOrderHistoryDetail.Id, tempSalesOrderHistoryDetail);
                addedSalesOrderHistoryDetailMap.remove(tempSalesOrderHistoryDetail.Id);

            } else if(addedSKUMap.containsKey(delTBCNLineItem.ASI_CRM_SG_SKU__c)) {

                ASI_MFM_SKU_Code__c tempSKU = addedSKUMap.get(delTBCNLineItem.ASI_CRM_SG_SKU__c);

                skuMap.put(tempSKU.Id, tempSKU);
                addedSKUMap.remove(tempSKU.Id);

            }

        }

        tbcnLineItemWrapperMap.remove(salesOrderLineItemId);
    }

    public PageReference saveSalesOrderLineItem() {
        Map<String, String> params                     = ApexPages.currentPage().getParameters();
        String isQuickSaveStr                          = params.get('IS_QUICK_SAVE');

        Boolean isQuickSave = !String.isNotBlank(isQuickSaveStr) ? false : Boolean.valueOf(isQuickSaveStr);

        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {

            if(tbcnLineItemWrapperMap.size() > 0) {

                Set<String> overSalesOrderHistoryRecordNameSet = checkSalesOrder(tbcnLineItemWrapperMap.values());

                if(!overSalesOrderHistoryRecordNameSet.isEmpty()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal, 'Request quantity is over the order quantity![' + overSalesOrderHistoryRecordNameSet + ']'));
                    return null;
                }

                List<ASI_KOR_Sales_Order_Transaction__c> tbcnLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();

                for(TBCNLineItemWrapper tbcnLineItemWrapper : tbcnLineItemWrapperMap.values()) {
                    tbcnLineItemList.add(tbcnLineItemWrapper.tbcnLineItem);
                }

                Database.upsert(tbcnLineItemList);

            }

            if(deleteSalesOrderLineList.size() > 0) {

                Database.delete(deleteSalesOrderLineList);

            }

        } catch(Exception ex){

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal, ex.getDmlMessage(0)));
            Database.rollback(databaseSavepoint);      
            return null;

        }

        PageReference pageRef = null;

        if(!isQuickSave) {

            pageRef = new PageReference('/'+tbcnHeader.Id);
            pageRef.setRedirect(true);

        }

        return pageRef;
    }

    public PageReference cancel() {
        Pagereference pageRef;
        pageRef = new PageReference('/'+tbcnHeader.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }

    public Set<String> checkSalesOrder(List<TBCNLineItemWrapper> tbcnLineItemWrapperList) {
        Set<String> overSalesOrderHistoryRecordNameSet = new Set<String>(); 

        Map<Id, Decimal> salesOrderHistoryIdQuantityMap = new Map<Id, Decimal>();
        List<Id> currentTransactionIdList = new List<Id>();

        for(TBCNLineItemWrapper tbcnLineItemWrapper : tbcnLineItemWrapperList) {

            if(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_Sales_Order_History_Detail__c != null) {

                currentTransactionIdList.add(tbcnLineItemWrapper.tbcnLineItem.Id);

                if(tbcnLineItemWrapper.salesOrderHistoryQuantity < tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_SG_Request_Quantity_Bottle__c) {

                    overSalesOrderHistoryRecordNameSet.add(tbcnLineItemWrapper.salesOrderHistoryName);

                } else {

                    salesOrderHistoryIdQuantityMap.put(tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_Sales_Order_History_Detail__c, tbcnLineItemWrapper.tbcnLineItem.ASI_CRM_SG_Request_Quantity_Bottle__c);

                }

            }

        }
        
        if(salesOrderHistoryIdQuantityMap.size() != 0) {

            List<ASI_KOR_Sales_Order_Transaction__c> existingSalesOrderLineItemList = [SELECT Id,
                                                                                       ASI_CRM_SG_SKU__c,
                                                                                       ASI_CRM_SG_SKU__r.Name,
                                                                                       ASI_CRM_Sales_Order_History_Detail__c,
                                                                                       ASI_CRM_Sales_Order_History_Detail__r.Name,
                                                                                       ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c,
                                                                                       ASI_CRM_SG_Request_Quantity_Bottle__c
                                                                                       FROM ASI_KOR_Sales_Order_Transaction__c
                                                                                       WHERE RecordType.DeveloperName = :SALES_ORDER_REQUEST_RECORD_TYPE AND
                                                                                       Id not in :currentTransactionIdList AND 
                                                                                       ASI_CRM_Sales_Order_History_Detail__c in :salesOrderHistoryIdQuantityMap.keySet()
                                                                                       ];                                                                   
        
            for(ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem : existingSalesOrderLineItemList) {

                if(salesOrderHistoryIdQuantityMap.containsKey(salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__c) && 
                   !overSalesOrderHistoryRecordNameSet.contains(salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.Name)) {

                    Decimal currentNumberOfRequestQuantityBottle = salesOrderLineItem.ASI_CRM_SG_Request_Quantity_Bottle__c + salesOrderHistoryIdQuantityMap.get(salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__c);

                    if(currentNumberOfRequestQuantityBottle > salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c) {

                        overSalesOrderHistoryRecordNameSet.add(salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__r.Name);

                    } else {

                        salesOrderHistoryIdQuantityMap.put(salesOrderLineItem.ASI_CRM_Sales_Order_History_Detail__c, currentNumberOfRequestQuantityBottle);

                    }

                }

            }

        }
        

        return overSalesOrderHistoryRecordNameSet;
    }

    private class TBCNLineItemWrapper {

        public ASI_KOR_Sales_Order_Transaction__c tbcnLineItem {get; set;}
        public String skuName {get; set; }
        public String salesOrderHistoryName {get; set;}
        public Decimal salesOrderHistoryQuantity {get; set;}

        public TBCNLineItemWrapper(ASI_KOR_Sales_Order_Transaction__c tbcnLineItem, String skuName) {
            this.tbcnLineItem = tbcnLineItem;
            this.skuName = skuName;

            salesOrderHistoryName = '';
            salesOrderHistoryQuantity = null;
        }

        public TBCNLineItemWrapper(ASI_KOR_Sales_Order_Transaction__c tbcnLineItem, String skuName, String salesOrderHistoryName, Decimal salesOrderHistoryQuantity) {
            this.tbcnLineItem = tbcnLineItem;
            this.skuName = skuName;
            
            this.salesOrderHistoryName = salesOrderHistoryName;
            this.salesOrderHistoryQuantity = salesOrderHistoryQuantity;
        }

    }

}