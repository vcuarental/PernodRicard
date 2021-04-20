/*********************************************************************************
 * Name: ASI_CRM_SG_FreeGoodsItem_Controller
 * Description: Controller class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-05       Laputa: Conrad          Created
 * 2015-01-08       Laputa: Conrad          Dynamic Page: Cater POSM and FOC recordtype for the header
 * 2015-02-10       Laputa: Conrad          Added Committed Quantity Logic (Post-BETA)
 * 2016-03-24       Laputa: Vincent         [VL 1.0] If this FOC request is created by FOC generation (check type = Sales Incentive), block line item from edit
 *                                          [VL 1.1] Give the latest price before contract start date
 * 2016-03-30       Laputa: Vincent         [VL 2.0] Add a validation helper to validate FOC
 * 2016-04-07       Laputa: Vincent         [VL 3.0] Calculate ROI
 *                                          [VL 3.1] Calculate Sampling Level
 * 2016-05-19       Laputa: Vincent         [VL 4.0] Besides PRS - WS, save WS - OT and IGC cost to FOC items
 * 2016-06-10       Laputa: Vincent         [VL 5.0] Only display SKU with all 6 price/cost
 * 2017-01-06		Laputa: Vincent			[VL 6.0] Calculate cost of line items
 * 2017-02-23		Laputa: Vincent			[VL 7.0] P3: Use a new validation logic
 * 2017-10-31		Wilken Lee				[WL 8.0] P4.1: Display different FOC Type to old and RTM contracts
 * 2017-11-23		Wilken Lee				[WL 9.0] P4.1: Validate 3 new SKU Price is needed for RTM Contract FOC
 * 2018-04-15		Laputa: Vincent			[VL 10.0] P4.2: add promotion
 */


public without sharing class ASI_CRM_SG_FreeGoodsItem_Controller extends ASI_CRM_SG_PageControllerBase {
        
    private ApexPages.StandardController standardController {get;set;}
        
    public ASI_FOC_Free_Goods_Request__c freeGoodHeader {get;set;}
    public static String FREEGOODS_TABLE {get{ return 'freeGoodsTable_';}}
        
    public Map<String, requestItem_Wrapper> allRequestItemMap {get;set;}{allRequestItemMap = new Map<String, requestItem_Wrapper>();}
    
    public Final Map<String, requestItem_Wrapper> allRequestItemMapStatic {get;set;}
    
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMap {get;set;}{allSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    private Map<String, ASI_MFM_SKU_Code__c> addedSKUMap {get;set;}{addedSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
	
	private date P3_deploy_date = date.newinstance(2017,8,8);
    
    // Retrieve and map all SKU Historic cost
    /* [VL 4.0] BEGIN */
    /*
    public Map<ID, ASI_CRM_MY_SKUPriceCost__c> allSKUHistoricMap {get;set;}{allSKUHistoricMap = new Map<ID, ASI_CRM_MY_SKUPriceCost__c>();}
    */
    public Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>> allSKUHistoricMap {get;set;}{allSKUHistoricMap = new Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>>();}
    /* [VL 4.0] END */
    
    // Retrieve and map all SKU and its Committed Prices
    public Map<ID, Integer> allSKUCommittedPrice {get;set;}{allSKUCommittedPrice = new Map<ID, Integer> ();}
        
    //Attributes used for filtering SKU
    public String subBrandSelected {get;set;}{subBrandSelected = '';}
    public String skuNameFilter {get;set;}
    public List<SelectOption> SubBrandSelectOptions {get;set;}
	
	/*[WL 8.0] BEGIN*/
	public List<SelectOption> FOCTypeSelectOptions {get;set;}
	/*[WL 8.0] END*/
	
    public Boolean isEdit {get;set;}{isEdit = false;}
    
    /* [VL 1.0] BEGIN */
    public Boolean isSalesIncentive {get;set;}{isSalesIncentive = false;}
    /* [VL 1.0] END */
    /* [VL 10.0] BEGIN */
    public Boolean isPromotionIncentive {get;set;}{isPromotionIncentive = false;}
    /* [VL 10.0] END */

    /* [VL 1.1] BEGIN */
    public Date contractStartDate {get;set;}
    /* [VL 1.1] END */
    
    private List<ASI_FOC_Request_Item__c> deleteRequestItemList {get;set;}{deleteRequestItemList = new List<ASI_FOC_Request_Item__c>();}
    
    // Attributes to keep track of newly added Payment Schedule record
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzITEMLINEZ';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    public ASI_CRM_SG_FreeGoodsItem_Controller(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        isEdit = true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
           
        freeGoodHeader = retrieveFreeGoodsHeader(((ASI_FOC_Free_Goods_Request__c)standardController.getRecord()).id);
                
        allSKUCommittedPrice = retrieveSKUCommittedQty();
        
        allRequestItemMap = retrieveRequestItem(freeGoodHeader);
        
        allRequestItemMapStatic = allRequestItemMap;
            
        //allSKUMap = retrieveSKU(allRequestItemMap, subBrandSelected);
        
        setSubBrandSelectOptions();
		
		/*[WL 8.0] BEGIN*/
		setFOCTypeSelectOptions();
		/*[WL 8.0] END*/
    }
    
    public Map<ID, Integer> retrieveSKUCommittedQty() {
    
        Map<ID, Integer> skuCommittedQty = new Map<ID, Integer>();
        
        Set<ID> skuIDs = new Set<ID>();
        
        List<ASI_FOC_Request_Item__c> tempRequestItemsList = new List<ASI_FOC_Request_Item__c>();
        
        if(allRequestItemMap.size() > 0) {
            for(requestItem_Wrapper requestItemW : allRequestItemMap.values()) {
                if(requestItemW.requestItem.ASI_FOC_SKU__c != null) {
                    tempRequestItemsList.add(requestItemW.requestItem);
                }
            }
        } else {
            tempRequestItemsList = [SELECT ID, Name, ASI_FOC_SKU__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = : freeGoodHeader.id];
        }

        for(ASI_FOC_Request_Item__c requestItemW : tempRequestItemsList) {
            if(requestItemW.ASI_FOC_SKU__c != null) {
                skuIDs.add(requestItemW.ASI_FOC_SKU__c);
            }
        }
        
        List<AggregateResult> allRequestItems = [SELECT ASI_FOC_SKU__c, SUM(ASI_FOC_Request_Quantity_Bottle__c)CommQtySum FROM ASI_FOC_Request_Item__c
                                                            WHERE ASI_FOC_SKU__c IN : skuIDs AND recordtype.developername = 'ASI_SG_CRM_Request_Items'
                                                            AND ASI_FOC_Request_Order__r.recordtype.developername = : freeGoodHeader.recordtype.developername 
                                                            AND (ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Submitted' OR ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Approved') 
                                                            AND ASI_FOC_Request_Order__r.ASI_CRM_Sync_to_JDE__c = false
                                                            GROUP BY ASI_FOC_SKU__c];
        
        System.debug('allRequestItems ' + allRequestItems);                                                    
        for(AggregateResult result : allRequestItems){
            Integer totalCommittedqty =  Integer.valueof((Decimal)result.get('CommQtySum'));
            ID sku = (ID)result.get('ASI_FOC_SKU__c');
            skuCommittedQty.put(sku, totalCommittedqty);
        }
        
        return skuCommittedQty;
    }
    
    private ASI_FOC_Free_Goods_Request__c retrieveFreeGoodsHeader(ID headerID) {
    
        ASI_FOC_Free_Goods_Request__c FreeGoodsHeader = new ASI_FOC_Free_Goods_Request__c();
        
        if (headerID != null){
            
            Map<String, Schema.SObjectField> freeGoodsMap = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
            String theQuery = 'Select ';
        /*
            for(String fields  : freeGoodsMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
*/
            thequery += 'id, name, ASI_CRM_Contract__c, ASI_CRM_SG_FOC_Changed__c, ASI_FOC_Request_Status__c, ASI_CRM_Sync_to_JDE__c, ';
            thequery += 'ASI_CRM_SG_Year__c, ASI_CRM_SG_Month__c';
			/*[WL 8.0] BEGIN */
			thequery += ',ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c, ASI_CRM_SG_System_Generated__c  ';
			/*[WL 8.0] END */
			/*[VL 10.0] BEGIN */
			thequery += ', ASI_CRM_System_Remark__c  ';
			/*[VL 10.0] END */
            /* [VL 1.1] BEGIN */
            /*
            thequery +=', recordtype.developername From ASI_FOC_Free_Goods_Request__c where ID = \''+ headerID + '\' ';
            */
            thequery +=', recordtype.developername, ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, ASI_CRM_Contract__r.name From ASI_FOC_Free_Goods_Request__c where ID = \''+ headerID + '\' ';
            /* [VL 1.1] END */
                
            List<ASI_FOC_Free_Goods_Request__c> freeGoodsList = (List<ASI_FOC_Free_Goods_Request__c>)Database.query(theQuery);
            
            if(freeGoodsList.size() > 0) {
                FreeGoodsHeader = freeGoodsList.get(0);
                /* [VL 1.1] BEGIN */
                contractStartDate = freeGoodsList.get(0).ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
                /* [VL 1.1] END */
                /* [VL 10.0] BEGIN */
                if(FreeGoodsHeader.ASI_CRM_System_Remark__c == 'SG Promotion') isPromotionIncentive = true;
                /* [VL 10.0] END */
            }
        }            
    
        return FreeGoodsHeader;
    }
    
    public Map<String, requestItem_Wrapper> retrieveRequestItem(ASI_FOC_Free_Goods_Request__c freeGoodHeader){
    
        Map<String, requestItem_Wrapper> freeGoodsItemMap = new Map<String, requestItem_Wrapper>();
        
        if (freeGoodHeader != null){
            
            Map<String, Schema.SObjectField> requestItemFieldsMap = Schema.SObjectType.ASI_FOC_Request_Item__c.fields.getMap();
            String theQuery = 'Select ';
        
            for(String fields  : requestItemFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            
            thequery = theQuery.subString(0,theQuery.length()-1);
            /* [VL 6.0] BEGIN */
            thequery += ', ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c';
            /* [VL 6.0] END */
            /* [VL 10.0] BEGIN */
            thequery += ', ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__c ';
            /* [VL 10.0] END */
            thequery +=' From ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__c = \''+ freeGoodHeader.id + '\' ';
                
            List<ASI_FOC_Request_Item__c> requestItemList = (List<ASI_FOC_Request_Item__c>)Database.query(theQuery);
            
            if(requestItemList.size() > 0) {
                for(ASI_FOC_Request_Item__c focRequest : requestItemList) {
                    Integer committedQty = allSKUCommittedPrice.containsKey(focRequest.ASI_FOC_SKU__c) ? allSKUCommittedPrice.get(focRequest.ASI_FOC_SKU__c) : 0;
                    system.debug('focRequest.ASI_FOC_SKU__c ' + focRequest.ASI_FOC_SKU__c + 'committedQty ' + committedQty );
                    /* [VL 6.0] BEGIN */
                    /*
                    requestItem_Wrapper requestItem = new requestItem_Wrapper(focRequest, committedQty);
*/
                    Decimal PackagingSize = focRequest.ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c == null ? 0 : focRequest.ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c;
                    requestItem_Wrapper requestItem = new requestItem_Wrapper(focRequest, committedQty, PackagingSize);
                    /* [VL 6.0] END */
                    freeGoodsItemMap.put(focRequest.id, requestItem);
                    /* [VL 1.0] BEGIN */
                    if (freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC') && 
						(focRequest.ASI_CRM_SG_FOC_Type__c == 'Sales Incentive')) {
                        isSalesIncentive = true;
                    }
                    /* [VL 1.0] END */
                }
            }
        }            
    
        return freeGoodsItemMap;
    }
        
    private Map<String, ASI_MFM_SKU_Code__c> retrieveSKU(Map<String, requestItem_Wrapper> requestItemsTargetMap, String subBrandSelected){
        
        Map<String, ASI_MFM_SKU_Code__c> FreeGoodsSKUMap = new Map <String, ASI_MFM_SKU_Code__c>();
        if (freeGoodHeader != null){
            
            Map<String, Schema.SObjectField> skuFieldsMap = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
            String theQuery = 'Select ';
        
            for(String fields  : skuFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            thequery +=' From ASI_MFM_SKU_Code__c WHERE (recordtype.developername = \'ASI_CRM_SG_FOC\' OR recordtype.developername = \'ASI_CRM_SG_SKU\' OR recordtype.developername = \'ASI_CRM_SG_POSM\') AND ASI_HK_CRM_Available_Quantity__c > 0';
            
            if(freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_POSM')) {
                thequery +=' AND ASI_HK_CRM_IsPOSProduct__c = true ';
            } else if(freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC')){
                thequery +=' AND ASI_HK_CRM_IsPOSProduct__c = false ';
            }
                
            if (subBrandSelected != null && subBrandSelected.trim() != '') {
                thequery += ' and ASI_MFM_Sub_Brand__c = \'' + String.escapeSingleQuotes(subBrandSelected.trim()) + '\'';
            }
                
            if (skuNameFilter != null && skuNameFilter.trim() != '') {
                thequery += ' and name like \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
            }       
                
            thequery += ' ORDER BY Name LIMIT 100 ';   
                
            List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)Database.query(theQuery);   
            Set<ID> skuCodeID = new Set<ID>();

			/*[WL 9.0] BEGIN*/
			Set<String> oldContractRTSet = new Set<String>{'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler', 
															'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',
															'ASI_CRM_SG_IGC',
															'ASI_CRM_SG_CRM_Duty_Per_Bottle',
															'ASI_CRM_SG_CRM_FOB_Per_Bottle',
															'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
															};
			
			Set<String> rtmContractRTSet = new Set<String>{'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle', 
															'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle',
															'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle',
															'ASI_CRM_SG_IGC',
															'ASI_CRM_SG_CRM_Duty_Per_Bottle',
															'ASI_CRM_SG_CRM_FOB_Per_Bottle',
															'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
															};			
			/*[WL 9.0] END*/
            
            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!requestItemsTargetMap.containsKey(sku.id) && freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_POSM')) {
                    FreeGoodsSKUMap.put(sku.id, sku);
                }    

                if(!requestItemsTargetMap.containsKey(sku.id)) {
            
                    skuCodeID.add(sku.id);
                }
            }
            
            Map<String, Schema.SObjectField> skuHistoricFieldsMap = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();
            String theQueryHistoric = 'Select ';
        
            for(String fields  : skuHistoricFieldsMap.keySet()){
                theQueryHistoric += fields + ' ,';
            }
            theQueryHistoric = theQueryHistoric.subString(0,theQueryHistoric.length()-1);
            /* [VL 4.0] BEGIN */
            theQueryHistoric +=' , recordtype.developername ';
            /* [VL 4.0] END */
            theQueryHistoric +=' From ASI_CRM_MY_SKUPriceCost__c ';
            theQueryHistoric +=' where ';
            /* [VL 4.0] BEGIN */
            /*
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler\' ';
            */
            theQueryHistoric +=' (recordtype.developername = \'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler\' ';
            theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade\' ';
            theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_IGC\' ';
            theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_CRM_Duty_Per_Bottle\' ';
            theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_CRM_FOB_Per_Bottle\' ';
            theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle\' ';
            /* [VL 4.0] END */
			
			/* [WL 9.0] BEGIN */
			theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle\' ';
			theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle\' ';
			theQueryHistoric +=' OR recordtype.developername = \'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle\') ';
			/* [WL 9.0] END */
			
            theQueryHistoric +=' AND ASI_CRM_SKU__c IN : skuCodeID ';
            theQueryHistoric +=' AND ASI_CRM_EffectiveDate__c != NULL ';
            /* [VL 1.1] BEGIN */
            if (contractStartDate != NULL) {
                theQueryHistoric +=' AND ASI_CRM_EffectiveDate__c <= :contractStartDate';
            }
            /* [VL 1.1] BEGIN */
            theQueryHistoric += ' ORDER BY ASI_CRM_EffectiveDate__c DESC NULLS LAST ';  
                
            List<ASI_CRM_MY_SKUPriceCost__c> skuHistoricCosts = (List<ASI_CRM_MY_SKUPriceCost__c>)Database.query(theQueryHistoric);
            /* [VL 4.0] BEGIN */
            /*
            Map<ID, ASI_CRM_MY_SKUPriceCost__c> skuHistoricCostMap = new Map<ID, ASI_CRM_MY_SKUPriceCost__c> ();
            */
            Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>> skuHistoricCostMap = new Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>> ();
            /* [VL 4.0] END */
                
            // Query all related SKU Historic Map data by retrieving the latest historical data and mapping them according to the SKU ID.
            for(ASI_CRM_MY_SKUPriceCost__c skuHistoric : skuHistoricCosts) {
                
                /* [VL 4.0] BEGIN */
                /*
                if(!skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                    skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuHistoric);
                }
                    
                if(skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                    ASI_CRM_MY_SKUPriceCost__c skuHistTemp = skuHistoricCostMap.get(skuHistoric.ASI_CRM_SKU__c);
                    if(skuHistTemp.ASI_CRM_EffectiveDate__c < skuHistoric.ASI_CRM_EffectiveDate__c) {
                        skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuHistoric);
                    }
                }
                */
                if(!skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> skuMapRecordtype = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
                    skuMapRecordtype.put(skuHistoric.recordtype.developername, skuHistoric);
                    skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuMapRecordtype);
                }
                
                if(skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceCostRecordTypeMap = skuHistoricCostMap.get(skuHistoric.ASI_CRM_SKU__c);
                    String recordTypeDeveloperName = skuHistoric.recordtype.developername;
                    
                    if(skuPriceCostRecordTypeMap.containsKey(recordTypeDeveloperName)) {
                        ASI_CRM_MY_SKUPriceCost__c skuHistTemp = skuPriceCostRecordTypeMap.get(recordTypeDeveloperName);
                        if(skuHistTemp.ASI_CRM_EffectiveDate__c < skuHistoric.ASI_CRM_EffectiveDate__c) {
                            
                            skuPriceCostRecordTypeMap.put(recordtypeDevelopername, skuHistoric);
                            skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuPriceCostRecordTypeMap);
                        }
                    } else {
                        skuPriceCostRecordTypeMap.put(recordtypeDevelopername, skuHistoric);
                        skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuPriceCostRecordTypeMap);
                    }
                    
                }
                /* [VL 4.0] END */
            }

            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!requestItemsTargetMap.containsKey(sku.id) && skuHistoricCostMap.containsKey(sku.id)) {
                    /* [VL 5.0] BEGIN */
                    /*
                    FreeGoodsSKUMap.put(sku.id, sku);
                    */
                    Map<String,ASI_CRM_MY_SKUPriceCost__c> skuHistoricCostTemp = skuHistoricCostMap.get(sku.id);
					
					/*[WL 9.0] BEGIN*/
					if (freeGoodHeader.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c){
						if (skuHistoricCostTemp.keySet().containsAll(oldContractRTSet))
							FreeGoodsSKUMap.put(sku.id, sku);
                    }
					else {
						if (skuHistoricCostTemp.keySet().containsAll(rtmContractRTSet))
							FreeGoodsSKUMap.put(sku.id, sku);
					}
					/*if(skuHistoricCostTemp.size() == 6) {
                        FreeGoodsSKUMap.put(sku.id, sku);
                    }*/					
					/*[WL 9.0] BEGIN*/
                    /* [VL 5.0] BEGIN */
                }    
            }
                
            allSKUHistoricMap = skuHistoricCostMap;                
        }
        return FreeGoodsSKUMap ;
    }
    
    public PageReference saveRequestItem(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        /* [VL 2.0] BEGIN */
        List<ASI_FOC_Request_Item__c> FOCRequestItemToUpsert = new List<ASI_FOC_Request_Item__c>();
            
        for(requestItem_Wrapper FOCLine : allRequestItemMap.values()) {
            /* [VL 6.0] BEGIN */
            /*
            FOCRequestItemToUpsert.add(FOCLine.requestItem);
*/
            ASI_FOC_Request_Item__c lineItem = FOCLine.requestItem;
            FOCLine.requestItem.ASI_FOC_Request_Quantity_Bottle__c = FOCLine.requestItem.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : FOCLine.requestItem.ASI_FOC_Request_Quantity_Bottle__c;
            Decimal packagingSize = FOCLine.packagingSize;
            if (freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC')) {
system.debug('IGC Cost: ' + lineItem.ASI_CRM_IGC_Cost_Per_case__c + ' packagingSize: ' + packagingSize + ' Actual Qty: ' + lineItem.ASI_FOC_Actual_Quantity_Bottle__c + ' Req Qty: ' + lineItem.ASI_FOC_Request_Quantity_Bottle__c);
                lineItem.ASI_FOC_Free_Good_Cost__c = lineItem.ASI_CRM_IGC_Cost_Per_case__c / packagingSize * (lineItem.ASI_FOC_Actual_Quantity_Bottle__c == null ? lineItem.ASI_FOC_Request_Quantity_Bottle__c : lineItem.ASI_FOC_Actual_Quantity_Bottle__c);
            }
            FOCRequestItemToUpsert.add(lineItem);
            /* [VL 6.0] END */
        }
        
        List<ASI_FOC_Free_Goods_Request__c> updateFocHeaderList = new List<ASI_FOC_Free_Goods_Request__c>();
        if (freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC')) {
			String validateVolume = '';
            /* [VL 7.0] BEGIN */
            /*
            ASI_CRM_SG_FOC_ValidationHelper_V2 validateHelper = new ASI_CRM_SG_FOC_ValidationHelper_V2(true, freeGoodHeader, FOCRequestItemToUpsert);
            validateVolume = validateHelper.validateVolumeExceed();
            if(validateVolume != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateVolume));
                return null;
            }
            updateFocHeaderList = validateHelper.updateSamplingLevel();
            */
			
			date contractCreatedDate = getContractCreatedDate(freeGoodHeader.ASI_CRM_Contract__r.name);
			
			string V2orV3 = 'V2';			
			user u = [select id, BypassTriggers__c from user where id = :UserInfo.getUserId()];
			if (u.BypassTriggers__c != null && u.BypassTriggers__c.contains('ASI_CRM_SG_FOC_ValidationHelper_V3')){
				V2orV3 = 'V2';
			} else 
			if (u.BypassTriggers__c != null && u.BypassTriggers__c.contains('ASI_CRM_SG_FOC_ValidationHelper_V2')){
				V2orV3 = 'V3';
			} else 
			if (contractCreatedDate >= P3_deploy_date){
				V2orV3 = 'V3';
			} else {
				V2orV3 = 'V2';
			}
						
			if (V2orV3 == 'V2'){
				ASI_CRM_SG_FOC_ValidationHelper_V2 validateHelper = new ASI_CRM_SG_FOC_ValidationHelper_V2(true, freeGoodHeader, FOCRequestItemToUpsert);
				validateVolume = validateHelper.validateVolumeExceed();
				if(validateVolume != '') {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateVolume));
					return null;
				}
				updateFocHeaderList = validateHelper.updateSamplingLevel();
			} else {
				ASI_CRM_SG_FOC_ValidationHelper_V3 validateHelper = new ASI_CRM_SG_FOC_ValidationHelper_V3(true, freeGoodHeader, FOCRequestItemToUpsert);
				validateVolume = validateHelper.validateVolumeExceed();
				if(validateVolume != '') {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateVolume));
					return null;
				}
				updateFocHeaderList = validateHelper.updateSamplingLevel();
			}
            
            
            /* [VL 7.0] END */
            system.debug('updateFocHeaderList #########################################');
            system.debug(updateFocHeaderList);
        }
        
        /* [VL 2.0] END */
        
        Savepoint sp = Database.setSavepoint();
        try {
        
            /* [VL 2.0] BEGIN */
            // move the following code to above, out of the TRY
            /*
            List<ASI_FOC_Request_Item__c> FOCRequestItemToUpsert = new List<ASI_FOC_Request_Item__c>();
            
            for(requestItem_Wrapper FOCLine : allRequestItemMap.values()) {
                FOCRequestItemToUpsert.add(FOCLine.requestItem);
            }
            */
            /* [VL 2.0] END */
            
            if (FOCRequestItemToUpsert.size() > 0) {
                upsert FOCRequestItemToUpsert;
            }
            if (deleteRequestItemList.size() > 0) {
                delete deleteRequestItemList;
            }
            
            if(!freeGoodHeader.ASI_CRM_SG_FOC_Changed__c) {
                freeGoodHeader.ASI_CRM_SG_FOC_Changed__c = true;
                update freeGoodHeader;
            }
            
            /* [VL 3.0] BEGIN */
            if (freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC')) {
                List<ASI_FOC_Free_Goods_Request__c> list_header = new List<ASI_FOC_Free_Goods_Request__c>();
                list_header.add(freeGoodHeader);
                ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper(list_header);
                roi.calculateROI();
            }
            /* [VL 3.0] END */
            
            /* [VL 3.1] BEGIN */
            if (freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC') && updateFocHeaderList.size()>0) {
                update updateFocHeaderList;
            }
            /* [VL 3.1] END */
            
        } catch (exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getDmlMessage(0)));
            Database.rollback(sp);
            return null;
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+freeGoodHeader.Id);
            pageRef.setRedirect(true);
        }
        
        return pageRef;
        
       
    } 
        
    public void addRequestItem(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_freegoodSourceItemId = params.get('PARAM_FREEGOOD_SOURCE_ITEM_ID');
        /* [VL 4.0] BEGIN */
        /*
        ASI_CRM_MY_SKUPriceCost__c skuTempHistoricCost;
        */
        Map<String, ASI_CRM_MY_SKUPriceCost__c> skuTempHistoricCost;
        /* [VL 4.0] END */
        
        for(String skuId : allSKUMap.keySet()) {
            System.debug('Debug Message' + skuId);
        }
        
        if(allSKUMap.containsKey(param_freegoodSourceItemId)){
            ASI_MFM_SKU_Code__c skuTemp = allSKUMap.get(param_freegoodSourceItemId);
            
            Decimal unitPrice = null;
            /* [VL 4.0] BEGIN */
            Decimal price_PRS_WS = 0;
            Decimal price_WS_OT = 0;
            Decimal cost_IGC = 0;
            Decimal cost_Duty = 0;
            Decimal cost_FOB = 0;
            Decimal cost_Handling = 0;
            /* [VL 4.0] END */
            String agCodeDefault = null;
            if(freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_FOC')){
            
                // Check if theres any valid SKU historic cost
                if(allSKUHistoricMap.containsKey((ID)param_freegoodSourceItemId)) {
                    skuTempHistoricCost = allSKUHistoricMap.get((ID)param_freegoodSourceItemId);
                }
                    
                /* [VL 4.0] BEGIN */
                /*
                if(skuTempHistoricCost != null) {
                    if(freeGoodHeader.ASI_CRM_SG_Order_Date__c < skuTempHistoricCost.ASI_CRM_EffectiveDate__c) {
                        skuTempHistoricCost = null;
                    }
                }
                
                if(skuTempHistoricCost != null) {
                    unitPrice = skuTempHistoricCost.ASI_CRM_Price__c;
                } else
                {
                    unitPrice = skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c;
                }
                */
                if(skuTempHistoricCost != null) {                    
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS = skuTempHistoricCost.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') ? skuTempHistoricCost.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') : new ASI_CRM_MY_SKUPriceCost__c();
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade = skuTempHistoricCost.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade') ? skuTempHistoricCost.get('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade') : new ASI_CRM_MY_SKUPriceCost__c();
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostIGC = skuTempHistoricCost.containsKey('ASI_CRM_SG_IGC') ? skuTempHistoricCost.get('ASI_CRM_SG_IGC') : new ASI_CRM_MY_SKUPriceCost__c();
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostDuty = skuTempHistoricCost.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') ? skuTempHistoricCost.get('ASI_CRM_SG_CRM_Duty_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostFob = skuTempHistoricCost.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') ? skuTempHistoricCost.get('ASI_CRM_SG_CRM_FOB_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                    ASI_CRM_MY_SKUPriceCost__c skuHistoricCostHandlingCost = skuTempHistoricCost.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') ? skuTempHistoricCost.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                    
                    price_PRS_WS = skuHistoricCostWS.ASI_CRM_Price__c != null ? skuHistoricCostWS.ASI_CRM_Price__c : 0;
                    price_WS_OT = skuHistoricCostWSOnTrade.ASI_CRM_Price__c != null ? skuHistoricCostWSOnTrade.ASI_CRM_Price__c : 0;
                    cost_IGC = skuHistoricCostIGC.ASI_CRM_Cost__c != null ? skuHistoricCostIGC.ASI_CRM_Cost__c : 0;
                    cost_Duty = skuHistoricCostDuty.ASI_CRM_Cost__c != null ? skuHistoricCostDuty.ASI_CRM_Cost__c : 0;
                    cost_FOB = skuHistoricCostFob.ASI_CRM_Cost__c != null ? skuHistoricCostFob.ASI_CRM_Cost__c : 0;
                    cost_Handling = skuHistoricCostHandlingCost.ASI_CRM_Cost__c != null ? skuHistoricCostHandlingCost.ASI_CRM_Cost__c : 0;
                } else {
                    price_PRS_WS = skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c;
                }
                unitPrice = price_PRS_WS;
                
                
                /* [VL 4.0] END */
				
				//2017-12-04 Default different AG Code for RTM Contract's FOC
				if (freeGoodHeader.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c)
					agCodeDefault = '0023';
				else 
					agCodeDefault = '0037';
					
            } else if(freeGoodHeader.recordtype.developername.contains('ASI_CRM_SG_POSM')) {
                agCodeDefault = '0028';
            }
            string newIDCounter = newCounterCreatorLine();
            
            /* [VL 4.0] BEGIN */
            /*
            allRequestItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, new requestItem_Wrapper(new ASI_FOC_Request_Item__c( 
                                    ASI_FOC_Request_Order__c = freeGoodHeader.id,
                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                                    ASI_FOC_SKU__c = param_freegoodSourceItemId,
                                    ASI_CRM_SG_Unit_Price__c = unitPrice,
                                    ASI_CRM_SG_A_G_Code__c = agCodeDefault,
                                    ASI_CRM_SG_Available_Quantity__c = skuTemp.ASI_HK_CRM_Available_Quantity__c
                                    ), 0));
            */
            /* [VL 4.0] END */
            
            //if(freeGoodHeader.recordtype.developername == 'ASI_CRM_SG_POSM') {
                allSKUCommittedPrice = retrieveSKUCommittedQty();
                Integer committedQty = allSKUCommittedPrice.containsKey((ID)param_freegoodSourceItemId) ? allSKUCommittedPrice.get((ID)param_freegoodSourceItemId) : 0;
            /* [VL 6.0] BEGIN */
            Decimal packagingSize = allSKUMap.get(param_freegoodSourceItemId).ASI_HK_CRM_Packaging_Size__c == null ? 0 : allSKUMap.get(param_freegoodSourceItemId).ASI_HK_CRM_Packaging_Size__c;
            /* [VL 6.0] END */
            
                allRequestItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, new requestItem_Wrapper(new ASI_FOC_Request_Item__c( 
                                    ASI_FOC_Request_Order__c = freeGoodHeader.id,
                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                                    ASI_FOC_SKU__c = param_freegoodSourceItemId,
                                    ASI_CRM_SG_Unit_Price__c = unitPrice,
            /* [VL 4.0] BEGIN */
                                    ASI_CRM_Duty_Per_Bottle__c = cost_Duty,
                                    ASI_CRM_FOB_Per_Bottle__c = cost_FOB,
                                    ASI_CRM_Handling_Cost_Per_Bottle__c = cost_Handling,
                                    ASI_CRM_IGC_Cost_Per_case__c = cost_IGC,
                                    ASI_CRM_Selling_Price_Btl_PRS_WS__c = price_PRS_WS,
                                    ASI_CRM_Selling_Price_Btl_WS_On_Trade__c = price_WS_OT,
            /* [VL 4.0] END */
                                    ASI_CRM_SG_A_G_Code__c = agCodeDefault,
                                    ASI_CRM_SG_Available_Quantity__c = skuTemp.ASI_HK_CRM_Available_Quantity__c
                                    ), committedQty/* [VL 6.0] BEGIN */, packagingSize/* [VL 6.0] END */));
            //}
            
            addedSKUMap.put(param_freegoodSourceItemId, allSKUMap.get(param_freegoodSourceItemId));
            allSKUMap.remove(param_freegoodSourceItemId);
        }
    }
        
    public void removeRequestSKU(){
    
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_freeGoodsSKUID = params.get('PARAM_FREEGOODS_SKU_ID');
            
        if(allRequestItemMap.containsKey(param_freeGoodsSKUID)){
        
            ASI_FOC_Request_Item__c delRequestLine = allRequestItemMap.get(param_freeGoodsSKUID).requestItem;
            
            String skuID = (String)delRequestLine.ASI_FOC_SKU__c;

            if(delRequestLine.id != null){
                deleteRequestItemList.add(delRequestLine);
            }
            else {
            
                allSKUMap.put(param_freeGoodsSKUID, addedSKUMap.get(skuID));
                addedSKUMap.remove(skuID);
            }
            allRequestItemMap.remove(param_freeGoodsSKUID);
        }
    }
        
    public void retrieveSKUbySubBrand(){
        allSKUMap = retrieveSKU(allRequestItemMap, subBrandSelected);
    }
        
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+freeGoodHeader.Id);
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
    
	/*[WL 8.0] BEGIN */
	public void setFOCTypeSelectOptions() 
    {
        List<SelectOption> result = new List<SelectOption>();
        
		if (freeGoodHeader.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c){
			//Old contract created before RTM
			
			if (freeGoodHeader.ASI_CRM_SG_System_Generated__c){
				//System FOC, only show Sales Incentive
				result.add(new SelectOption('Sales Incentive', 'Sales Incentive'));
			}
			else {
				//Manual FOC, show a list of FOC Types
				result.add(new SelectOption('Cash Sponsorship', 'Cash Sponsorship'));
				result.add(new SelectOption('Management Incentive', 'Management Incentive'));
				result.add(new SelectOption('Adhoc Promotion/Sponsorship', 'Adhoc Promotion/Sponsorship'));
				result.add(new SelectOption('Signages New - TOT', 'Signages New - TOT'));
				result.add(new SelectOption('Signages New - MOT', 'Signages New - MOT'));
				result.add(new SelectOption('Sampling', 'Sampling'));
				result.add(new SelectOption('Commando Activity', 'Commando Activity'));
				result.add(new SelectOption('Anniversary', 'Anniversary'));
				result.add(new SelectOption('GMA Purchases', 'GMA Purchases'));
				result.add(new SelectOption('Events', 'Events'));
				result.add(new SelectOption('Advertising Spot', 'Advertising Spot'));
				result.add(new SelectOption('Contract Sponsorship/Target Incentive', 'Contract Sponsorship/Target Incentive'));
				result.add(new SelectOption('Replacement Bottle', 'Replacement Bottle'));
				result.add(new SelectOption('Gift for Trade/Business Associate (CNY)', 'Gift for Trade/Business Associate (CNY)'));
				result.add(new SelectOption('Sampling to end consumer (marketing)', 'Sampling to end consumer (marketing)'));
				result.add(new SelectOption('Brand Awareness', 'Brand Awareness'));
				result.add(new SelectOption('Training', 'Training'));
				result.add(new SelectOption('Corporate Public Relation', 'Corporate Public Relation'));
				result.add(new SelectOption('Hospitality', 'Hospitality'));
				result.add(new SelectOption('Company functions (marketing)', 'Company functions (marketing)'));	
			}
		}
		else {
			//New contract created before RTM
			result.add(new SelectOption('A&P Fund', 'A&P Fund'));
			result.add(new SelectOption('Adhoc Promotion/Sponsorship', 'Adhoc Promotion/Sponsorship'));
			result.add(new SelectOption('Replacement Bottle', 'Replacement Bottle'));
		}   
		
        FOCTypeSelectOptions = result;
    }
	/*[WL 8.0] END */
	
    // Wrapper Class to accomodate the Committed Qty
    public class requestItem_Wrapper {
    
        public ASI_FOC_Request_Item__c requestItem {get;set;}
        public Integer committedQty {get;set;}
        public Decimal packagingSize {get;set;}
        
        public requestItem_Wrapper(ASI_FOC_Request_Item__c requestItemC, Integer committedQtyC, Decimal pack ) {
            
            this.requestItem = requestItemC;
            this.committedQty = committedQtyC;
            this.packagingSize = pack;
        }
        
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
	
	public date getContractCreatedDate(string contractNo){
		string originalContractNo = contractNo.substring(0, 15);
		string query = 'select createddate from ASI_TH_CRM_Contract__c where recordtype.developername like \'ASI_CRM_SG_Contract%\' and name like \'';
		query += originalContractNo;
		query += '%\' order by createddate limit 1' ;
		ASI_TH_CRM_Contract__c originalContract = (ASI_TH_CRM_Contract__c)Database.query(query);
		
		date originalCreatedDate = date.newinstance(originalContract.createddate.year(), originalContract.createddate.month(), originalContract.createddate.day());
		return originalCreatedDate;
	}

}