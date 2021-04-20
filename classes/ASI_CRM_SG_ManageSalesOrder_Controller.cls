/*********************************************************************************
 * Name: ASI_CRM_SG_ManageSalesOrder_Controller
 * Description: Controller class
 * Test Class: ASI_CRM_SG_SalesOrder_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-23       Laputa: Conrad          Created
 * 2017-03-16       Wilken Lee	            [WL 1.0] Add Indonesia market 
 * 2018-03-28       Wilken Lee	            [WL 2.0] Skip SKU which the Available Quantity is less than 1 case
 * 2018-10-24       Wilken Lee	            [WL 3.0] CHM119352793 Show all active SKU regardless of quantity
 */


public without sharing class ASI_CRM_SG_ManageSalesOrder_Controller extends ASI_CRM_SG_PageControllerBase {
        
    private ApexPages.StandardController standardController {get;set;}
        
    public ASI_KOR_Sales_Order_Request__c salesOrderHeader {get;set;}
    public static String SalesOrder_TABLE {get{ return 'SalesOrderTable_';}}
        
    public Map<String, ASI_KOR_Sales_Order_Transaction__c> allSalesOrderItemMap {get;set;}{allSalesOrderItemMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();}
        
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMap {get;set;}{allSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    private Map<String, ASI_MFM_SKU_Code__c> addedSKUMap {get;set;}{addedSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
        
    //Attributes used for filtering SKU
    public String subBrandSelected {get;set;}{subBrandSelected = '';}
    public String skuNameFilter {get;set;}
    public String skuDescriptionFilter {get;set;}
    public List<SelectOption> SubBrandSelectOptions {get;set;}
    
    // Map of recordtypes to header
    public Map<String, List<ID>> recordtypeMappings {get;set;}

    public Boolean isEdit {get;set;}{isEdit = false;}

    private List<ASI_KOR_Sales_Order_Transaction__c> deleteSalesOrderItemList {get;set;}{deleteSalesOrderItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();}

    // Attributes to keep track of newly added Payment Schedule record
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzITEMLINEZ';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
        
    public ASI_CRM_SG_ManageSalesOrder_Controller(ApexPages.StandardController standardController){
        recordtypeMappings = new Map<String, List<ID>>();
        
        recordtypeMappings.put('ASI_CRM_SG_CA', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_CA'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_CA')});
        recordtypeMappings.put('ASI_CRM_SG_LA', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_LA'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_LA')});
        recordtypeMappings.put('ASI_CRM_SG_MY', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MY'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_MY')});
        recordtypeMappings.put('ASI_CRM_SG_MM', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MM'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_MM')});
        recordtypeMappings.put('ASI_CRM_SG_PH', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_PH'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_PH')});
        recordtypeMappings.put('ASI_CRM_SG_VI', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VI'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_VI')});
        recordtypeMappings.put('ASI_CRM_SG_VIDF', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VIDF'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_VIDF')});
		
		/*[WL 1.0 BEGIN]*/
		recordtypeMappings.put('ASI_CRM_SG_IN', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_IN'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_IN')});
		/*[WL 1.0 END]*/
		
        this.standardController = standardController;
        
        isEdit = true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
        
        List<ASI_KOR_Sales_Order_Request__c> salesOrderList = (List<ASI_KOR_Sales_Order_Request__c>)queryAll(((ASI_KOR_Sales_Order_Request__c)standardController.getRecord()).id, 'ASI_KOR_Sales_Order_Request__c', 'ID', '');
        
        if(salesOrderList.size() > 0) {   
            salesOrderHeader = salesOrderList.get(0);
        }
        
        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList = queryAll(salesOrderHeader.id,'ASI_KOR_Sales_Order_Transaction__c', 'ASI_KOR_Sales_Order_Request__c', '');
        
        for(ASI_KOR_Sales_Order_Transaction__c soItem : salesOrderItemList) {
            allSalesOrderItemMap.put((String)(soItem.ID), soItem);
        }
        
        setSubBrandSelectOptions();
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' , recordtype.developername From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }
    
    private Map<String, ASI_MFM_SKU_Code__c> retrieveSKU(Map<String, ASI_KOR_Sales_Order_Transaction__c> requestItemsTargetMap, String subBrandSelected){
        
        Map<String, ASI_MFM_SKU_Code__c> salesOrderItemSKUMap = new Map <String, ASI_MFM_SKU_Code__c>();
        if (salesOrderHeader != null){
            
            Map<String, Schema.SObjectField> skuFieldsMap = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
            String theQuery = 'Select ';
        
            for(String fields  : skuFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            //thequery +=' From ASI_MFM_SKU_Code__c where recordtypeid = \''+(recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(1)+'\' AND ASI_MFM_Sub_brand__c != NULL ';
            thequery +=' From ASI_MFM_SKU_Code__c where recordtypeid = \''+(recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(1)+'\' AND ASI_HK_CRM_Active__c = TRUE ';
            
			/*[WL 2.0] BEGIN*/
			/*[WL 3.0] BEGIN*/
			//thequery += ' AND ASI_CRM_Is_Stock_out_SKU__c = FALSE ';   
			/*[WL 3.0] END*/
			/*[WL 2.0] END*/
			
            if (skuNameFilter != null && skuNameFilter.trim() != '') {
                thequery += ' and ASI_MFM_SKU_Code__c like \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
            }  
            if (skuDescriptionFilter != null && skuDescriptionFilter.trim() != '') {
                thequery += ' and ASI_MFM_SKU_Description__c like \'%' + String.escapeSingleQuotes(skuDescriptionFilter.trim()) + '%\'';
            } 
                
            thequery += ' ORDER BY ASI_MFM_SKU_Code__c ASC LIMIT 100 ';   
                
            List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)Database.query(theQuery);   
                
            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!requestItemsTargetMap.containsKey(sku.id)) {
                    salesOrderItemSKUMap.put(sku.id, sku);
                }    
            }
                
        }
        return salesOrderItemSKUMap ;
    }
    
    public void retrieveSKUbySubBrand(){
        allSKUMap = retrieveSKU(allSalesOrderItemMap, subBrandSelected);
    }
    
    public PageReference saveSalesOrderItems(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');

        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
            
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
            
        System.Savepoint pSavepoint = Database.setSavepoint();
        try{
            if(deleteSalesOrderItemList.size()>0)
                deleteTarget = Database.delete(deleteSalesOrderItemList);

            List<ASI_KOR_Sales_Order_Transaction__c> upsertTargetList = new List<ASI_KOR_Sales_Order_Transaction__c>();
            for(String key : allSalesOrderItemMap.keySet()){
                upsertTargetList.add(allSalesOrderItemMap.get(key));
            }
            
            if(upsertTargetList.size()>0)
                upsertTarget = Database.upsert(upsertTargetList);
                
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getDmlMessage(0)));
            Database.rollback(pSavepoint);      
            return null;
        }
            
        if (!isQuickSave){
            pageRef = new PageReference('/'+salesOrderHeader.Id);
            pageRef.setRedirect(true);
        }
        return pageRef;
            
    }
    
    public void addSalesOrderItem(){

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_SALESORDER_SOURCE_ITEM_ID');
                
        if(allSKUMap.containsKey(param_SourceItemId)){
        
            ASI_MFM_SKU_Code__c skuTemp = allSKUMap.get(param_SourceItemId);
            
            string newIDCounter = newCounterCreatorLine();

            allSalesOrderItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter,
                new ASI_KOR_Sales_Order_Transaction__c(
                    ASI_KOR_Sales_Order_Request__c = salesOrderHeader.id,
                    recordtypeid = (recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(0),
                    ASI_CRM_SG_SKU__c = param_SourceItemId,
                    ASI_CRM_SG_Available_Quantity__c = skuTemp.ASI_HK_CRM_Available_Quantity__c,
                    ASI_CRM_SG_Unit_Price__c = skuTemp.ASI_FOC_Unit_Cost__c
                )
            );
            
            addedSKUMap.put(param_SourceItemId, allSKUMap.get(param_SourceItemId));
            allSKUMap.remove(param_SourceItemId);
        }
        
    }
    
    public void removeSalesOrderSKU(){
    
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SKUId = params.get('PARAM_SALESORDER_SKU_ID');
            
        if(allSalesOrderItemMap.containsKey(param_SKUId)){

            ASI_KOR_Sales_Order_Transaction__c delTarget = allSalesOrderItemMap.get(param_SKUId);
            String skuID = delTarget.ASI_CRM_SG_SKU__c;

            if(delTarget.id != null){
                deleteSalesOrderItemList.add(delTarget);
            }
            else{
                allSKUMap.put(skuID, addedSKUMap.get(skuID));
                addedSKUMap.remove(skuID);
            }
            allSalesOrderItemMap.remove(param_SKUId);
        }
    
    }
    
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+salesOrderHeader.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public void setSubBrandSelectOptions() 
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('',''));
            
        String query = 'SELECT Id, Name FROM ASI_MFM_Sub_Brand__c WHERE recordtype.developername = \'ASI_CRM_SG_Sub_brand\' ';
            
        query += ' ORDER BY name ';
            
        List<ASI_MFM_Sub_Brand__c> subBrandQuery = (List<ASI_MFM_Sub_Brand__c>)Database.query(query); 
            
        for(ASI_MFM_Sub_Brand__c sb : subBrandQuery){
            result.add(new SelectOption(sb.id, sb.name));
        }
        SubBrandSelectOptions = result;
    }
    
    public String newCounterCreatorLine() {

        String idNew;
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
    
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;
    
        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
    
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
    
    }

}