/*********************************************************************************
 * Name: ASI_CRM_SG_ManageSalesOrder_Ctrl_WS
 * Description: Controller class
 * Related Test Class: ASI_CRM_SG_SalesOrder_WS_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-23       Laputa: Conrad          Created
 * 2016-03-23       Laputa: Vincent         [VL 1.0] Cater Sales order for SG wholesaler
 * 2016-04-27       Laputa: Vincent         [VL 2.0] Auto-generate packaging size of SKU to cater new approval logic
 * 2016-06-09       Laputa: Vincent         [VL 3.0] for SG wholesaler, ignore all isPOSproduct SKU
 * 2016-06-13       Laputa: Hugo            [HC 1.0] Get the PRS-WS Price and assign to line item
 * 2016-07-20       Laputa: Hugo            [HC 2.0] Change SKU to SKU Name field
 * 2016-07-25       Laputa: Vincent         [VL 4.0] in search SKU, only return those Short Description <> "."
 * 2017-05-24       Wilken Lee		        [WL 1.0] Add [Selectable In Order] checkbox on SKU master to allow certain POS item to be available in WS SO and TBCN
 * 2018-01-03       Wilken Lee		        [WL 2.0] Change WS SO pricing to use ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle
 * 2018-02-20       Wilken Lee		        [WL 3.0] Revert SKU display using SKU Description instead of JDE Search Text
 */


public without sharing class ASI_CRM_SG_ManageSalesOrder_Ctrl_WS extends ASI_CRM_SG_PageControllerBase {
        
    private ApexPages.StandardController standardController {get;set;}
        
    public ASI_KOR_Sales_Order_Request__c salesOrderHeader {get;set;}
    public static String SalesOrder_TABLE {get{ return 'SalesOrderTable_';}}
        
    public Map<String, SalesOrderLineWrapper> allSalesOrderItemMap {get;set;}{allSalesOrderItemMap = new Map<String, SalesOrderLineWrapper>();}
        
    public Map<String, SKUWrapper> allSKUMap {get;set;}{allSKUMap = new Map<String, SKUWrapper>();}
    private Map<String, SKUWrapper> addedSKUMap {get;set;}{addedSKUMap = new Map<String, SKUWrapper>();}
        
    //Attributes used for filtering SKU
    public String subBrandSelected {get;set;}{subBrandSelected = '';}
    /* [HC 2.0] BEGIN */
    public String skuCodeFilter {get;set;}
    public String skuNameFilter {get;set;}
    /* [HC 2.0] END */
    public List<SelectOption> SubBrandSelectOptions {get;set;}
    
    // Map of recordtypes to header
    public Map<String, List<ID>> recordtypeMappings {get;set;}

    public Boolean isEdit {get;set;}{isEdit = false;}

    private List<ASI_KOR_Sales_Order_Transaction__c> deleteSalesOrderItemList {get;set;}{deleteSalesOrderItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();}

    private List<ASI_CRM_SG_SO_FOC_Rules__c> soFOCRulesList = new List<ASI_CRM_SG_SO_FOC_Rules__c>();
    
    // Attributes to keep track of newly added Payment Schedule record
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzITEMLINEZ';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
	// Regional
    public String region {get; set;} {region = 'SG';}
    
    public ASI_CRM_SG_ManageSalesOrder_Ctrl_WS(ApexPages.StandardController standardController){
        recordtypeMappings = new Map<String, List<ID>>();
        
        recordtypeMappings.put('ASI_CRM_SG_CA', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_CA'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_CA')});
        recordtypeMappings.put('ASI_CRM_SG_LA', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_LA'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_LA')});
        recordtypeMappings.put('ASI_CRM_SG_MY', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MY'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_MY')});
        recordtypeMappings.put('ASI_CRM_SG_MM', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MM'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_MM')});
        recordtypeMappings.put('ASI_CRM_SG_PH', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_PH'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_PH')});
        recordtypeMappings.put('ASI_CRM_SG_VI', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VI'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_VI')});
        recordtypeMappings.put('ASI_CRM_SG_VIDF', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VIDF'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_VIDF')});
        /* [VL 1.0] BEGIN */
        recordtypeMappings.put('ASI_CRM_SG_Wholesaler', new List<ID>{ Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_Wholesaler'), Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU')});
        /* [VL 1.0] END */
        recordtypeMappings.put('ASI_CRM_KH_Sales_Order', new List<ID>{Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_KH_SO_Item'), 
            														  Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_KH_SKU')});
        
        
        
        this.standardController = standardController;
        
        isEdit = true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
        
        List<ASI_KOR_Sales_Order_Request__c> salesOrderList = (List<ASI_KOR_Sales_Order_Request__c>)queryAll(((ASI_KOR_Sales_Order_Request__c)standardController.getRecord()).id, 'ASI_KOR_Sales_Order_Request__c', 'ID', '');
        if(salesOrderList.size() > 0) {   
            salesOrderHeader = salesOrderList.get(0);
        }
        
        // Determine Region By Record Type
        System.debug ('salesOrderHeader: '+salesOrderHeader);
        System.debug ('salesOrderHeader: '+salesOrderHeader.recordtype.developername);
        
        List<RecordType> recordType = [SELECT Id, DeveloperName 
                                       FROM RecordType 
                                       WHERE Id =: salesOrderHeader.RecordTypeId];
        String recordTypeName = recordType.get(0).DeveloperName;
        System.debug ('recordTypeName: '+recordTypeName);
        if (recordTypeName == 'ASI_CRM_KH_Sales_Order' || recordTypeName == 'ASI_CRM_KH_Sales_Order_Read_Only') {
            region = 'KH';
            isEdit = false;
            System.debug ('status: '+salesOrderHeader.ASI_KOR_Order_Status__c);
            if (salesOrderHeader.ASI_KOR_Order_Status__c == 'Draft' || salesOrderHeader.ASI_KOR_Order_Status__c == 'Cancelled' || salesOrderHeader.ASI_KOR_Order_Status__c == 'Rejected'){
                isEdit = true;
            }
        }
       
        soFOCRulesList = [SELECT Id,
                          ASI_CRM_Effective_Date__c,
                          ASI_CRM_SKU_First_5_Digits__c,
                          ASI_CRM_SG_Get_Free_Bottle__c,
                          ASI_CRM_SG_Buy__c
                          FROM ASI_CRM_SG_SO_FOC_Rules__c
                          WHERE ASI_CRM_SG_Wholesaler__c = :salesOrderHeader.ASI_CRM_SG_Customer__c
                          AND ASI_CRM_Effective_Date__c <= :salesOrderHeader.ASI_CRM_SG_Order_Date__c
                          AND RecordType.DeveloperName = 'ASI_CRM_SG_SO_FOC_Rule_Wholesaler'
                          ORDER BY ASI_CRM_Effective_Date__c DESC];
        
        //List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList = queryAll(salesOrderHeader.id,'ASI_KOR_Sales_Order_Transaction__c', 'ASI_KOR_Sales_Order_Request__c', '');
        
        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList = [SELECT Id,
                                                                       ASI_CRM_SG_SKU__c,
                                                                       ASI_CRM_SG_SKU__r.Name,
                                                                       ASI_CRM_SG_SKU__r.ASI_CRM_Available_Quantity_Carton__c,
                                                                       ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c,
                                                                       ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c,
                                                                       ASI_CRM_SG_Request_Quantity_Bottle__c,
                                                                       ASI_CRM_SG_Request_Quantity_Carton__c,
                                                                       ASI_CRM_SG_FOC__c,
                                                                       ASI_CRM_FOC_Additional__c,
                                                                       ASI_CRM_Packaging_Size__c,
                                                                       ASI_CRM_SG_Unit_Price__c,
                                                                       ASI_CRM_Selling_Price_Per_Bottle_PRS_WS__c,
                                                                       ASI_CRM_SG_Available_Quantity__c
                                                                       FROM ASI_KOR_Sales_Order_Transaction__c
                                                                       WHERE ASI_KOR_Sales_Order_Request__c = :salesOrderHeader.id
                                                                       ];
    
        for(ASI_KOR_Sales_Order_Transaction__c soItem : salesOrderItemList) {
            
            SalesOrderLineWrapper salesOrderLineWrapper;
        
            ASI_CRM_SG_SO_FOC_Rules__c tempSOFOCRule;
    
            for(ASI_CRM_SG_SO_FOC_Rules__c soFOCRule : soFOCRulesList) {
    
                if(((String)soItem.ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c).substring(0, 5).equalsIgnoreCase(soFOCRule.ASI_CRM_SKU_First_5_Digits__c)) {
    
                    tempSOFOCRule = soFOCRule;
                    break;

                }

            }
			/*[WL 4.0] BEGIN*/
            if(tempSOFOCRule != null) {
                //salesOrderLineWrapper = new SalesOrderLineWrapper(soItem, soItem.ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c, tempSOFOCRule);
				salesOrderLineWrapper = new SalesOrderLineWrapper(soItem, soItem.ASI_CRM_SG_SKU__r.Name, tempSOFOCRule, soItem.ASI_CRM_SG_SKU__r);
            } else {
                //salesOrderLineWrapper = new SalesOrderLineWrapper(soItem, soItem.ASI_CRM_SG_SKU__r.ASI_CRM_Short_Description__c);
				salesOrderLineWrapper = new SalesOrderLineWrapper(soItem, soItem.ASI_CRM_SG_SKU__r.Name,soItem.ASI_CRM_SG_SKU__r);
            }
			/*[WL 4.0] END*/
			
            allSalesOrderItemMap.put((String)(soItem.ASI_CRM_SG_SKU__c), salesOrderLineWrapper);
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
    
    private Map<String, SKUWrapper> retrieveSKU(Map<String, SalesOrderLineWrapper> requestItemsTargetMap, String subBrandSelected){
        /* [HC 1.0] BEGIN */
        Map<String, SKUWrapper> salesOrderItemSKUMap = new Map <String, SKUWrapper>();
        /* [HC 1.0] END */
        if (salesOrderHeader != null){
            
            Map<String, Schema.SObjectField> skuFieldsMap = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
            String theQuery = 'Select ';
        
            /*
            for(String fields  : skuFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            */
            thequery += 'Name, ';  
			thequery += 'ASI_CRM_Short_Description__c, ';  
			thequery += 'ASI_MFM_SKU_Code__c, ';  
			thequery += 'ASI_MFM_SKU_Description__c, ';
            thequery += 'ASI_HK_CRM_Pack_Factor__c, ';  
			thequery += 'ASI_HK_CRM_UOM1__c, ';  
			thequery += 'ASI_HK_CRM_UOM2__c, ';     
			thequery += 'ASI_HK_CRM_Std_Bottle_Size__c, ';  
			thequery += 'ASI_HK_CRM_Packaging_Size__c, ';    
			thequery += 'ASI_HK_CRM_Available_Quantity__c, ';
            thequery += 'ASI_CRM_Available_Quantity_Carton__c, ';
			thequery += 'ASI_FOC_Unit_Cost__c, ';        
			thequery += 'ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c ';        
            
            //thequery +=' From ASI_MFM_SKU_Code__c where recordtypeid = \''+(recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(1)+'\' AND ASI_MFM_Sub_brand__c != NULL ';
            thequery +=' From ASI_MFM_SKU_Code__c where recordtypeid = \''+(recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(1)+'\' AND ASI_HK_CRM_Active__c = TRUE ';
                  
            /* [VL 3.0] BEGIN */
			/* [VL 1.0] BEGIN */
            //thequery += ' AND ASI_HK_CRM_IsPOSProduct__c = FALSE ';
			thequery += ' AND (ASI_HK_CRM_IsPOSProduct__c = FALSE OR ASI_CRM_Selectable_In_Order__c = TRUE) ';
			/* [VL 1.0] END */
            /* [VL 3.0] END */
            
            /* [HC 2.0] BEGIN */    
            
            if (skuCodeFilter != null && skuCodeFilter.trim() != '') {
                thequery += ' and ASI_MFM_SKU_Code__c like \'%' + String.escapeSingleQuotes(skuCodeFilter.trim()) + '%\'';
            }  
            if (skuNameFilter != null && skuNameFilter.trim() != '') {
				/*[WL 3.0] BEGIN*/
                //thequery += ' and ASI_CRM_Short_Description__c like \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
				thequery += ' and Name like \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
				/*[WL 3.0] END*/
            } 
            /* [HC 2.0] END */
            
            /* [VL 4.0] BEGIN */
			/* [WL 3.0] BEGIN */
            //thequery += ' and ASI_CRM_Short_Description__c <> \'.\' ';
			/* [WL 3.0] END */
            /* [VL 4.0] END */
                
            thequery += ' ORDER BY ASI_MFM_SKU_Code__c ASC LIMIT 1000 ';   
			
			system.debug('Retrieve SKU Query(Before Further Check of SKU Price): ' + thequery);
                
            List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)Database.query(theQuery);   

            /* [HC 1.0] BEGIN */
            List<Id> skuIdList = new List<Id>();
            for(ASI_MFM_SKU_Code__c sku : skuList) {
                skuIdList.add(sku.Id);
            }
            
            String priceListRecordTypeName = 'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle';
            Date compareDate = salesOrderHeader.ASI_CRM_SG_Order_Date__c;
            if (region == 'KH') {
                priceListRecordTypeName = 'ASI_CRM_KH_List_Price';
                compareDate = Date.newInstance(salesOrderHeader.CreatedDate.year(), 
                                               salesOrderHeader.CreatedDate.month(), 
                                               salesOrderHeader.CreatedDate.day());
            }
            
            List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [SELECT Id, ASI_CRM_SKU__c, ASI_CRM_Price__c
                                                             FROM ASI_CRM_MY_SKUPriceCost__c
                                                             WHERE ASI_CRM_SKU__c in :skuIdList 
                                                             AND ASI_CRM_EffectiveDate__c <= :compareDate
                                                             /*[WL 2.0] BEGIN*/
                                                             //AND RecordType.DeveloperName = 'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'
                                                             AND RecordType.DeveloperName =: priceListRecordTypeName
                                                             /*[WL 2.0] END*/
                                                             ORDER BY ASI_CRM_EffectiveDate__c DESC
                                                             ];
            
            
            
            Map<Id, ASI_CRM_MY_SKUPriceCost__c> skuPriceMap = new Map<Id, ASI_CRM_MY_SKUPriceCost__c>();
            for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
				if(!skuPriceMap.containsKey(skuPrice.ASI_CRM_SKU__c)) {
				    skuPriceMap.put(skuPrice.ASI_CRM_SKU__c, skuPrice);
                }
			}
            
            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!requestItemsTargetMap.containsKey(sku.id)) {
					if(skuPriceMap.get(sku.id) == null) {
						if(sku.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c != null) {
							salesOrderItemSKUMap.put(sku.id, new SKUWrapper(sku, sku.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c));
						}
                    } else {
						salesOrderItemSKUMap.put(sku.id, new SKUWrapper(sku, skuPriceMap.get(sku.id).ASI_CRM_Price__c));
					}
				}    
            }
            /* [HC 1.0] END */
                
        }
        
        System.debug ('SS salesOrderItemSKUMap: '+salesOrderItemSKUMap);
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
            
            List<Id> skuIdList = new List<Id>();

            for(String key : allSalesOrderItemMap.keySet()) {
                skuIdList.add(allSalesOrderItemMap.get(key).salesOrderLineItem.ASI_CRM_SG_SKU__c);
            }

            Map<Id, ASI_MFM_SKU_Code__c> mapRecordId_Skus = new Map<Id, ASI_MFM_SKU_Code__c>(
                [SELECT Id
                      , Name
                      , ASI_HK_CRM_Packaging_Size__c
                 FROM ASI_MFM_SKU_Code__c
                 WHERE Id IN : skuIdList]);

            for(String key : allSalesOrderItemMap.keySet()){
                SalesOrderLineWrapper tempSalesOrderLineWrapper = allSalesOrderItemMap.get(key);

                if (region == 'SG') {
                    if(mapRecordId_Skus.get(tempSalesOrderLineWrapper.salesOrderLineItem.ASI_CRM_SG_SKU__c) != null) {
                        tempSalesOrderLineWrapper.calculateFOC(mapRecordId_Skus.get(tempSalesOrderLineWrapper.salesOrderLineItem.ASI_CRM_SG_SKU__c).ASI_HK_CRM_Packaging_Size__c);
                    } else {
                        tempSalesOrderLineWrapper.salesOrderLineItem.ASI_CRM_SG_FOC__c = 0;
                    }
                }    
                
                upsertTargetList.add(tempSalesOrderLineWrapper.salesOrderLineItem);
            }
            
            System.debug ('upsertTargetList: '+upsertTargetList);
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
        
            ASI_MFM_SKU_Code__c skuTemp = allSKUMap.get(param_SourceItemId).skuCode;
            System.debug ('SS skuTemp: '+skuTemp);
            Decimal skuPrice = allSKUMap.get(param_SourceItemId).skuPrice;

            string newIDCounter = newCounterCreatorLine();

            ASI_CRM_SG_SO_FOC_Rules__c tempSOFOCRule;
            
            ASI_KOR_Sales_Order_Transaction__c tempSalesOrderItem = new ASI_KOR_Sales_Order_Transaction__c(
                                                                            ASI_KOR_Sales_Order_Request__c = salesOrderHeader.id,
                                                                            recordtypeid = (recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(0),
                                                                            ASI_CRM_SG_SKU__c = param_SourceItemId,
                                                                            ASI_CRM_SG_Available_Quantity__c = skuTemp.ASI_HK_CRM_Available_Quantity__c,
                                                                            ASI_CRM_SG_Unit_Price__c = skuTemp.ASI_FOC_Unit_Cost__c
                                                                            /* [VL 2.0] BEGIN */
                                                                            , ASI_CRM_Packaging_Size__c = skuTemp.ASI_HK_CRM_Packaging_Size__c
                                                                            /* [VL 2.0] END */
                                                                            , ASI_CRM_Selling_Price_Per_Bottle_PRS_WS__c = skuPrice
                														);
            
            if (region == 'KH') {
                tempSalesOrderItem = new ASI_KOR_Sales_Order_Transaction__c(
                    					ASI_KOR_Sales_Order_Request__c = salesOrderHeader.id,
                    					recordtypeid = (recordtypeMappings.get(salesOrderHeader.recordtype.developername)).get(0),
                    					ASI_CRM_SG_SKU__c = param_SourceItemId,
                    					ASI_CRM_SG_Request_Quantity_Bottle__c = 0,
                						ASI_CRM_SG_Request_Quantity_Carton__c = 0,
                    					ASI_CRM_Packaging_Size__c = skuTemp.ASI_HK_CRM_Packaging_Size__c,
                    					ASI_CRM_Selling_Price_Per_Bottle_PRS_WS__c = skuPrice,
                						ASI_CRM_SG_Unit_Price__c = skuPrice,
                						ASI_CRM_SG_Available_Quantity__c = skuTemp.ASI_HK_CRM_Available_Quantity__c);
            }
            System.debug ('add: '+tempSalesOrderItem);    
            

            SalesOrderLineWrapper salesOrderLineWrapper;

            for(ASI_CRM_SG_SO_FOC_Rules__c  soFOCRule : soFOCRulesList) {
    			if(((String)skuTemp.ASI_MFM_SKU_Code__c).substring(0, 5).equalsIgnoreCase(soFOCRule.ASI_CRM_SKU_First_5_Digits__c)) {
    				tempSOFOCRule = soFOCRule;
                    break;
    			}
    		}
            
			/*[WL 3.0] BEGIN*/
            if(tempSOFOCRule != null) {
				//salesOrderLineWrapper = new SalesOrderLineWrapper(tempSalesOrderItem, skuTemp.ASI_CRM_Short_Description__c, tempSOFOCRule);
                salesOrderLineWrapper = new SalesOrderLineWrapper(tempSalesOrderItem, skuTemp.Name, tempSOFOCRule, skuTemp);
            } else {
                //salesOrderLineWrapper = new SalesOrderLineWrapper(tempSalesOrderItem, skuTemp.ASI_CRM_Short_Description__c);
				salesOrderLineWrapper = new SalesOrderLineWrapper(tempSalesOrderItem, skuTemp.Name, skuTemp);
            }
			/*[WL 3.0] END*/

            allSalesOrderItemMap.put(param_SourceItemId, salesOrderLineWrapper);
            System.debug('allSalesOrderItemMap: '+allSalesOrderItemMap);
            
            addedSKUMap.put(param_SourceItemId, allSKUMap.get(param_SourceItemId));
            allSKUMap.remove(param_SourceItemId);
        }
        
    }
    
    public void removeSalesOrderSKU(){
    
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SKUId = params.get('PARAM_SALESORDER_SKU_ID');
            
        if(allSalesOrderItemMap.containsKey(param_SKUId)){

            ASI_KOR_Sales_Order_Transaction__c delTarget = allSalesOrderItemMap.get(param_SKUId).salesOrderLineItem;
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

    public class SalesOrderLineWrapper {

        public ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem {get; set;}
        public String skuName {get; set;}
        public ASI_MFM_SKU_Code__c relatedSKU {get; set;}
        public Decimal buySize {get; set;}
        public Decimal getFreeBottle {get; set;}

        public SalesOrderLineWrapper(ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem, String skuName, ASI_MFM_SKU_Code__c relatedSKU) {
            this.salesOrderLineItem = salesOrderLineItem;
            this.skuName = skuName;
			this.relatedSKU = relatedSKU;
            buySize = 0;
            getFreeBottle = 0;
        }

        public SalesOrderLineWrapper(ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem, String skuName, ASI_CRM_SG_SO_FOC_Rules__c soFOCRules,ASI_MFM_SKU_Code__c relatedSKU) {
            this.salesOrderLineItem = salesOrderLineItem;
            this.skuName = skuName;
            this.relatedSKU = relatedSKU;

            buySize = soFOCRules.ASI_CRM_SG_Buy__c != null ? soFOCRules.ASI_CRM_SG_Buy__c : 0.0;
            getFreeBottle = soFOCRules.ASI_CRM_SG_Get_Free_Bottle__c != null ? soFOCRules.ASI_CRM_SG_Get_Free_Bottle__c : 0.0;
        }

        public void calculateFOC(Decimal packagingSize) {
            if(buySize == 0 || getFreeBottle == 0) {
                salesOrderLineItem.ASI_CRM_SG_FOC__c = 0;
                return;
            }

            Decimal bottleQuantity = salesOrderLineItem.ASI_CRM_SG_Request_Quantity_Bottle__c != NULL
                                     ? salesOrderLineItem.ASI_CRM_SG_Request_Quantity_Bottle__c
                                     : 0.0;

            Decimal cartonQuantity = salesOrderLineItem.ASI_CRM_SG_Request_Quantity_Carton__c != NULL
                                     ? salesOrderLineItem.ASI_CRM_SG_Request_Quantity_Carton__c 
                                     : 0.0;

            Decimal totalBottleQuantity = bottleQuantity + (cartonQuantity * packagingSize);

            salesOrderLineItem.ASI_CRM_SG_FOC__c = (totalBottleQuantity * getFreeBottle / buySize).round(System.RoundingMode.DOWN);
        }

    }

    public class SKUWrapper {

        public ASI_MFM_SKU_Code__c skuCode {get; set;}
        public Decimal skuPrice {get; set;}

        public SKUWrapper(ASI_MFM_SKU_Code__c skuCode, Decimal skuPrice) {
            this.skuCode = skuCode;
            this.skuPrice = skuPrice;
        }

    }

}