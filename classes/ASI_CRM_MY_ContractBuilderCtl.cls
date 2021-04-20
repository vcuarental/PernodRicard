/*********************************************************************************
* Name: ASI_CRM_MY_ContractBuilderCtl
* Description: Controller class for ASI_CRM_MY_ContractBuilderPage
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2014-11-25       Daniel WONG             Copy contract builder from SG
* 2014-11-25       Daniel WONG             Implement SKU historical cost mapping
* 2014-12-02       Daniel WONG             Implement New Object insertion with Sales & Staff Incentives, Volume Incentives, Other Incentives, Promoter Placements. 
* 2018-01			Introv					Allow Sales & Staff Incentives to input cross-brand SKU & implement the "Clone" funtion for Other Incenives.
* 2020-07			Ceterna					Add KH, Make MY as Default
*/

public with sharing class ASI_CRM_MY_ContractBuilderCtl extends ASI_CRM_MY_PageControllerBase{
    public List<SelectOption> ContractSetupCodeValue {get; set;} {ContractSetupCodeValue = ASI_CRM_MY_Function.getContractSetupCodeValue();}
    
    private ApexPages.StandardController standardController {get;set;}
    private Id contractId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    public string strPageID {get; set;} {strPageID = 'ERROR';}
    public boolean VFdisable {get; set;} {VFdisable = FALSE;}
    public ASI_TH_CRM_Contract__c contractObj {get;set;}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    
    public Map<String, ASI_CRM_ContractTarget__c> allContractTargetMap {get;set;}{allContractTargetMap = new Map<String, ASI_CRM_ContractTarget__c>();}
    public Map<String, ASI_CRM_ContractTarget__c> allMerchandiseContractTargetMap {get;set;}{allMerchandiseContractTargetMap = new Map<String, ASI_CRM_ContractTarget__c>();}
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMap {get;set;}{allSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    public Map<String, ASI_CRM_ContractTarget__c> allSKUKHMap {get;set;}{allSKUKHMap = new Map<String, ASI_CRM_ContractTarget__c>();}
    
    public Boolean isEdit {get;set;} {isEdit = false;}
    public String subBrandSelected {get;set;}{subBrandSelected = '';}
    public String skuNameFilter {get;set;}{skuNameFilter = '';}
    public String skuNameFilterOther {get;set;}{skuNameFilterOther = '';}
    public String skuNameFilterPP {get;set;}{skuNameFilterPP = '';}
    public String skuNameFilterSS {get;set;}{skuNameFilterSS = '';}
    public String skuIDForChangeSS {get;set;}{skuIDForChangeSS='';}
    
    
    public Map<String, ASI_CRM_ContractSalesStaffIncentive__c> allSSIncentivesMap {get;set;}{allSSIncentivesMap = new Map<String, ASI_CRM_ContractSalesStaffIncentive__c>();}
    public Map<String, ASI_CRM_ContractVolumeIncentive__c> allVolumeIncentivesMap {get;set;}{allVolumeIncentivesMap = new Map<String, ASI_CRM_ContractVolumeIncentive__c>();}
    public Map<String, ASI_CRM_ContractOtherIncentive__c> allOtherIncentivesMap {get;set;}{allOtherIncentivesMap = new Map<String, ASI_CRM_ContractOtherIncentive__c>();}
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMapOther {get;set;}{allSKUMapOther = new Map<String, ASI_MFM_SKU_Code__c>();}
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMapSS {get;set;}{allSKUMapSS = new Map<String, ASI_MFM_SKU_Code__c>();}
    public String subBrandSelectedOther {get;set;}{subBrandSelectedOther = '';}
    public String subBrandSelectedPP {get; set;}{subBrandSelectedPP = '';}
    public String subBrandSelectedSS {get; set;}{subBrandSelectedSS = '';}
    public Map<String, ASI_CRM_PromoterPlacement__c> allPromoterPlacementsMap {get;set;}{allPromoterPlacementsMap = new Map<String, ASI_CRM_PromoterPlacement__c>();}
    
    private Map<String, Schema.SObjectField> contractTargetFieldMap {get;set;}
    private List<ASI_CRM_ContractTarget__c> deleteContractTargetList {get;set;}{deleteContractTargetList = new List<ASI_CRM_ContractTarget__c>();}
    private List<ASI_CRM_ContractSalesStaffIncentive__c> SSIncentivesToDelete {get;set;}{SSIncentivesToDelete= new List<ASI_CRM_ContractSalesStaffIncentive__c>();}
    private List<ASI_CRM_ContractVolumeIncentive__c> VolumeIncentivesToDelete {get;set;}{VolumeIncentivesToDelete= new List<ASI_CRM_ContractVolumeIncentive__c>();}
    private List<ASI_CRM_ContractOtherIncentive__c> deleteOtherIncentivesList {get;set;}{deleteOtherIncentivesList = new List<ASI_CRM_ContractOtherIncentive__c>();}
    private List<ASI_CRM_PromoterPlacement__c> deletePromoterPlacementList {get;set;}{deletePromoterPlacementList = new List<ASI_CRM_PromoterPlacement__c>();}
    private Map<String, ASI_MFM_SKU_Code__c> addedSKUMap {get;set;}{addedSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    
    //for Record Type
    public ID ContractTargetRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget');
    public ID SSIncentivesRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive');
    public ID VolumeIncentivesRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive');
    public ID OtherIncentivesRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive');
    public ID PromoterPlacementRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement');
    // KH - Merchandising
    public ID MerchandisingSupportRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_KH_Merchandising_Support');
    public ID MerchandisingRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_KH_Merchandising');
    
    // Regional
    public String region {get; set;} {region = 'MY';}
    
    // ------------------------------------------------------------------------------------------------------
    public ASI_CRM_MY_ContractBuilderCtl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        /*Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType contractTargetSchema = schemaMap.get('ASI_CRM_ContractTarget__c');
        contractTargetFieldMap = contractTargetSchema.getDescribe().fields.getMap();
        */
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
        //isEdit = (isEditStr ==null)?false:true;
        isEdit = true;
        
        //Set Contract
        contractObj = (ASI_TH_CRM_Contract__c)standardController.getRecord();
        System.debug ('contractObj: '+contractObj);
        // Determine Region By Record Type
        System.debug ('contractObj: '+contractObj.Id);
        System.debug ('RecordTypeId: '+contractObj.RecordTypeId);
        List<RecordType> recordType = [SELECT Id, DeveloperName 
                                       FROM RecordType 
                                       WHERE Id =: contractObj.RecordTypeId];
        String recordTypeName = recordType.get(0).DeveloperName;
        if (recordTypeName == 'ASI_CRM_KH_Contract' || recordTypeName == 'ASI_CRM_KH_Contract_Read_Only') {
            region = 'KH';
        }
        
        if(contractObj.ASI_TH_CRM_Contract_Status__c == 'Final'){
            isEdit = FALSE;
        }    
        if (region == 'KH'){
            if(contractObj.ASI_TH_CRM_Contract_Status__c == 'Draft' 
               || contractObj.ASI_TH_CRM_Contract_Status__c == 'Contract Rejected'){
                   isEdit = true;
               }else{
                   isEdit = false;
               }
        }
        
        
        //Retrieve all existing Contract Target
        allContractTargetMap = retrieveContractTarget(contractObj);
        allMerchandiseContractTargetMap = retrieveMerchandiseContractTarget(contractObj);
        
        //Retrieve all MY SKU
        //allSKUMap = retrieveSKU(allContractTargetMap, skuNameFilter, skuNameFilter);
        //allSKUMapOther = retrieveSKU(allContractTargetMap, skuNameFilterOther, skuNameFilterOther);
        
        //Retrieve all existing Contract Sales & Staff Incentive
        allSSIncentivesMap = retrieveSSIncentives(contractObj);
        
        //Retrieve all existing Contract Volume Incentive
        allVolumeIncentivesMap = retrieveVolumeIncentives(contractObj);
        
        //Retrieve all existing Contract Other Incentive
        allOtherIncentivesMap = retrieveOtherIncentives(contractObj);
        
        //Retrieve all existing Promoter Placement
        allPromoterPlacementsMap = retrievePromoterPlacements(contractObj);
    }
    
    // ------------------------------------------------------------------------------------------------------
    private Map<String, ASI_CRM_ContractTarget__c > retrieveContractTarget(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_ContractTarget__c > contractTargetMap = new Map <String, ASI_CRM_ContractTarget__c >();
        if (contractObj != null){
            for(ASI_CRM_ContractTarget__c c :
                [SELECT Id, Name, ASI_CRM_SKU__c, ASI_CRM_PackFactor__c,
                         ASI_CRM_TargetCase__c, ASI_CRM_MinSPCase__c, ASI_CRM_Total__c, ASI_CRM_KH_Total_Price__c,
                         ASI_CRM_KH_Value_per_Unit__c, ASI_CRM_KH_FOC_Support_in_actual_Bottle__c,
                         ASI_CRM_KH_FOC_Support_in_actual_case__c,
                         ASI_CRM_KH_Merchandise_Name__c,
                 		 ASI_CRM_PackagingSize__c
                 FROM ASI_CRM_ContractTarget__c 
                 WHERE ASI_CRM_Contract__c =: contractObj.id 
                 AND recordtype.developername != 'ASI_CRM_KH_Merchandising'
                 //AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
                 //ORDER BY ASI_CRM_SKU__r.name
                 LIMIT 1000
                ]){ 
                    contractTargetMap.put(c.ASI_CRM_SKU__c, c);
                }
        } 
        System.debug('FLAG - retrieveContractTarget'+ '--' +contractTargetMap);
        return contractTargetMap;
    }
    
    private Map<String, ASI_CRM_ContractTarget__c> retrieveMerchandiseContractTarget(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_ContractTarget__c > contractTargetMap = new Map <String, ASI_CRM_ContractTarget__c >();
        if (contractObj != null){
            for(ASI_CRM_ContractTarget__c c :
                [SELECT Id, Name, ASI_CRM_SKU__c, ASI_CRM_PackFactor__c,
                         ASI_CRM_TargetCase__c, ASI_CRM_MinSPCase__c, ASI_CRM_Total__c, ASI_CRM_KH_Total_Price__c,
                         ASI_CRM_KH_Value_per_Unit__c, ASI_CRM_KH_FOC_Support_in_actual_Bottle__c,
                         ASI_CRM_KH_FOC_Support_in_actual_case__c,
                         ASI_CRM_KH_Merchandise_Name__c,
                         ASI_CRM_KH_Merchandising_Size__c,
                         ASI_CRM_KH_Merchandising_Quantity__c 
                 FROM ASI_CRM_ContractTarget__c 
                 WHERE ASI_CRM_Contract__c =: contractObj.id 
                 AND recordtype.developername = 'ASI_CRM_KH_Merchandising'
                 AND recordtype.SobjectType = 'ASI_CRM_ContractTarget__c'
                 LIMIT 1000
                ]){ 
                    contractTargetMap.put(c.Id, c);
                }
        } 
        System.debug('FLAG - retrieveMerchandiseContract'+ '--' +contractTargetMap);
        return contractTargetMap;
    }
    
    public void retrieveSKUbySubBrand(){
        allSKUMap = retrieveSKU(allContractTargetMap, subBrandSelected, skuNameFilter, TRUE);
    }
    
    public void retrieveSKUbySubBrandSS(){
        allSKUMapSS = retrieveSKU(allContractTargetMap, subBrandSelected, skuNameFilterSS, FALSE);
    }
    
    public void retrieveSKUbySubBrandOther(){
        allSKUMapOther = retrieveSKU(allContractTargetMap, subBrandSelectedOther, skuNameFilterOther, FALSE);
    }
    
    public void retrieveSKUbySubBrandPP(){
        allSKUMapOther = retrieveSKU(allContractTargetMap, subBrandSelectedPP, skuNameFilterPP, FALSE);
    }
    
    private Map<String, ASI_MFM_SKU_Code__c> retrieveSKU(Map<String, ASI_CRM_ContractTarget__c> contractTargetMap, 
                                                         String subBrandSelected, 
                                                         String strSKU, 
                                                         Boolean isTarget)
    {
        // Region
        String skuRecordTypeRegion = 'ASI_CRM_MY_SKU';
        if (region == 'KH') {
            skuRecordTypeRegion = 'ASI_KH_SKU';
        }
        
        Map<String, ASI_MFM_SKU_Code__c> contractSKUMap = new Map <String, ASI_MFM_SKU_Code__c>();
        
        String query = '';
        
        if (contractObj != null && (subBrandSelected == '' || subBrandSelected == null) && (strSKU == '' || strSKU == null)){
            // Do Nothing
        } else if (contractObj != null && subBrandSelected != '' && subBrandSelected != null && subBrandSelected != 'ALL'){
            
            query += 'SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Pack_Factor__c, ASI_HK_CRM_Packaging_Size__c ';
            query += ' FROM ASI_MFM_SKU_Code__c ';
            query += ' WHERE recordtype.developername =: skuRecordTypeRegion ';
            query += ' AND ASI_MFM_Sub_Brand__c =: subBrandSelected ';
            if (region == 'KH') {
            	query += ' AND ASI_HK_CRM_Active__c = true ';
            }
            if (strSKU == null || strSKU == '') {
            	query += ' AND Name LIKE \'%\'';
            } else {
            	query += ' AND Name LIKE \''+strSKU.trim()+'%\'';
            }
            query += ' ORDER BY Name ';
            
            /*
            for(ASI_MFM_SKU_Code__c sku :
                [SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Pack_Factor__c, ASI_HK_CRM_Packaging_Size__c
                 FROM ASI_MFM_SKU_Code__c
                 WHERE recordtype.developername =: skuRecordTypeRegion
                 AND ASI_MFM_Sub_Brand__c =: subBrandSelected
                 AND Name LIKE :(strSKU == null || strSKU == '' ? '%' : strSKU.trim() + '%')
                 //LIMIT 10
                ]){
                    if(isTarget){
                        if(!contractTargetMap.containsKey(sku.id))
                            contractSKUMap.put(sku.id, sku);
                    } else {
                        contractSKUMap.put(sku.id, sku);
                    }
                }
			*/
        } else if (contractObj != null && (subBrandSelected == null || subBrandSelected == '')){
            
            query += 'SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Pack_Factor__c, ASI_HK_CRM_Packaging_Size__c ';
            query += ' FROM ASI_MFM_SKU_Code__c ';
            query += ' WHERE recordtype.developername =: skuRecordTypeRegion ';
            if (region == 'KH') {
            	query += ' AND ASI_HK_CRM_Active__c = true ';
            }
            if (strSKU == null || strSKU == '') {
            	query += ' AND Name LIKE \'%\'';
            } else {
            	query += ' AND Name LIKE \''+strSKU.trim()+'%\'';
            }
            query += ' ORDER BY Name ';
            /*
            for(ASI_MFM_SKU_Code__c sku :
                [SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Pack_Factor__c, ASI_HK_CRM_Packaging_Size__c 
                 FROM ASI_MFM_SKU_Code__c
                 WHERE recordtype.developername =: skuRecordTypeRegion
                 //AND ASI_MFM_Sub_Brand__c =: subBrandSelected
                 AND Name LIKE :(strSKU == null || strSKU == '' ? '%' : strSKU.trim() + '%')
                 ORDER BY Name 
                 //LIMIT 10
                ]){
                    if(isTarget){
                        if(!contractTargetMap.containsKey(sku.id))
                            contractSKUMap.put(sku.id, sku);
                    } else {
                        contractSKUMap.put(sku.id, sku);
                    }
                }
            */
        } /*else if(contractObj != null && subBrandSelected == 'ALL'){
            for(ASI_MFM_SKU_Code__c sku :
            [SELECT Id, Name, ASI_MFM_Sub_brand__c
            FROM ASI_MFM_SKU_Code__c
            WHERE recordtype.developername = 'ASI_CRM_MY_SKU'
            AND Name LIKE :(strSKU == null || strSKU == '' ? '%' : strSKU.trim() + '%')
            //AND ASI_MFM_Sub_Brand__c =: subBrandSelected
            ORDER BY Name 
            //LIMIT 10
            ]){
            if(!contractTargetMap.containsKey(sku.id))
            contractSKUMap.put(sku.id, sku);    
            }
            } */
        
        
        if (query != '') {
            System.debug ('query: '+query);
            List<ASI_MFM_SKU_Code__c> skuList = Database.query(query);        
            for (ASI_MFM_SKU_Code__c sku : skuList) {
                if(isTarget){
                    if(!contractTargetMap.containsKey(sku.id)) {
                        contractSKUMap.put(sku.id, sku);
                    }
                } else {
                    contractSKUMap.put(sku.id, sku);
                }
            }
        }    
        
        System.debug('FLAG - retrieveSKU'+ '--' +contractSKUMap );
        return contractSKUMap ;
    }
    
    private Map<String, ASI_CRM_ContractSalesStaffIncentive__c> retrieveSSIncentives(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_ContractSalesStaffIncentive__c> SSIncentivesMap = new Map <String, ASI_CRM_ContractSalesStaffIncentive__c>();
        if (contractObj != null){
            for(ASI_CRM_ContractSalesStaffIncentive__c c :
                [SELECT Id, Name, ASI_CRM_SKU__c,ASI_CRM_CrossBrandSKU__c ,
                 ASI_CRM_MinSPBtl__c, ASI_CRM_AchievedBtl__c, ASI_CRM_FOCWS__c, ASI_CRM_FOCPRM__c,
                 ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c
                 FROM  ASI_CRM_ContractSalesStaffIncentive__c
                 WHERE ASI_CRM_Contract__c = :contractObj.id 
                 //AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
                 //ORDER BY ASI_CRM_SKU__r.name
                 LIMIT 1000
                ]){
                    if(c.ASI_CRM_SKU__c!=null && c.ASI_CRM_CrossBrandSKU__c==null){
                        c.ASI_CRM_CrossBrandSKU__c =c.ASI_CRM_SKU__c;
                    }
                    SSIncentivesMap.put(c.ASI_CRM_SKU__c, c);
                }
        } 
        System.debug('FLAG - retrieveSSIncentives' + '--' + SSIncentivesMap);
        return SSIncentivesMap;
    }
    
    private Map<String, ASI_CRM_ContractVolumeIncentive__c> retrieveVolumeIncentives(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_ContractVolumeIncentive__c> VolumeIncentivesMap = new Map <String, ASI_CRM_ContractVolumeIncentive__c>();
        if (contractObj != null){
            for(ASI_CRM_ContractVolumeIncentive__c c :
                [SELECT Id, Name, ASI_CRM_Description__c, ASI_CRM_SKU__c,
                 ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c, ASI_CRM_CashInc__c,
                 ASI_CRM_SetupCode__c, ASI_CRM_Total__c, ASI_CRM_FOC__c, ASI_CRM_AchievedBtl__c
                 FROM  ASI_CRM_ContractVolumeIncentive__c
                 WHERE ASI_CRM_Contract__c = :contractObj.id 
                 //AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
                 //ORDER BY ASI_CRM_SKU__r.name
                 LIMIT 1000
                ]){ 
                    VolumeIncentivesMap.put(c.ASI_CRM_SKU__c, c);
                }
        } 
        System.debug('FLAG - retrieveVolumeIncentives' + '--' + VolumeIncentivesMap);
        return VolumeIncentivesMap;
    }
    
    private Map<String, ASI_CRM_ContractOtherIncentive__c> retrieveOtherIncentives(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_ContractOtherIncentive__c> OtherIncentivesMap = new Map <String, ASI_CRM_ContractOtherIncentive__c>();
        String Key ;
        if (contractObj != null){
            for(ASI_CRM_ContractOtherIncentive__c c :
                [SELECT Id, Name, ASI_CRM_Type__c, ASI_CRM_Description__c,
                 ASI_CRM_SKU__c, ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c,ASI_CRM_AchievedBtl__c, 
                 ASI_CRM_FOC__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c, ASI_CRM_Total__c
                 FROM  ASI_CRM_ContractOtherIncentive__c
                 WHERE ASI_CRM_Contract__c = :contractObj.id 
                 //AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
                 //ORDER BY ASI_CRM_SKU__r.name
                 LIMIT 1000
                ]){ 
                    String ranStr = string.valueof(math.random() * 99999);
                    Key = c.ASI_CRM_SKU__c + '_' + c.ASI_CRM_Description__c + '_' + ranStr;
                    OtherIncentivesMap.put(Key , c);
                }
        } 
        System.debug('FLAG - retrieveOtherIncentives' + '--' + OtherIncentivesMap);
        return OtherIncentivesMap;
    }
    
    private Map<String, ASI_CRM_PromoterPlacement__c> retrievePromoterPlacements(ASI_TH_CRM_Contract__c contractObj){
        Map<String, ASI_CRM_PromoterPlacement__c> PromoterPlacementsMap = new Map <String, ASI_CRM_PromoterPlacement__c>();
        if (contractObj != null){
            for(ASI_CRM_PromoterPlacement__c c :
                [SELECT Id, Name, ASI_CRM_SKU__c, ASI_CRM_SetupCode__c,
                 ASI_CRM_DailySalary__c, ASI_CRM_PromoterCount__c, ASI_CRM_WorkingDay__c, 
                 ASI_CRM_WorkingMonth__c, ASI_CRM_TotalFx__c
                 FROM  ASI_CRM_PromoterPlacement__c
                 WHERE ASI_CRM_Contract__c = :contractObj.id 
                 //AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
                 //ORDER BY ASI_CRM_SKU__r.name
                 LIMIT 1000
                ]){ 
                    PromoterPlacementsMap.put(c.ASI_CRM_SKU__c, c);
                }
        } 
        System.debug('FLAG - retrievePromoterPlacements' + '--' + PromoterPlacementsMap);
        return PromoterPlacementsMap;
    }
    
    // ------------------------------------------------------------------------------------------------------
	public PageReference saveContract(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        //String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        //System.debug('Flag - Save Contract - isQuickSave:' + isQuickSaveStr);
        //Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        //System.debug('Flag - Save Contract - Mode:' + isQuickSave);
        
        Database.upsertResult[] upsertContractTarget;
        Database.deleteResult[] deleteContractTarget;
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        Map<String, ASI_CRM_ContractTarget__c> map_newContractTarget = new Map<String, ASI_CRM_ContractTarget__c>();
        Map<String, ASI_CRM_ContractSalesStaffIncentive__c> map_newSSIncentives = new Map<String, ASI_CRM_ContractSalesStaffIncentive__c>();
        Map<String, ASI_CRM_ContractVolumeIncentive__c> map_newVolIncentives = new Map<String, ASI_CRM_ContractVolumeIncentive__c>();
        Map<String, ASI_CRM_ContractOtherIncentive__c> map_newOtherIncentives = new Map<String, ASI_CRM_ContractOtherIncentive__c>();
        Map<String, ASI_CRM_PromoterPlacement__c> map_newPromoterPlacement = new Map<String, ASI_CRM_PromoterPlacement__c>();
        try {
            
            // UPSERT & DELECT Contract Target
            if(deleteContractTargetList.size()>0){
                deleteContractTarget = Database.delete(deleteContractTargetList);
                System.debug('Flag - Save Contract - Deleted Contract Target:' + deleteContractTarget);
                deleteContractTargetList.clear();
            }
            
            List<ASI_CRM_ContractTarget__c> upsertContractTargetList = new List<ASI_CRM_ContractTarget__c>();
            for(String key : allContractTargetMap.keySet()){
                if(allContractTargetMap.get(key).id == null){
                    allContractTargetMap.get(key).ASI_CRM_Contract__c = contractId;
                    map_newContractTarget.put(key, allContractTargetMap.get(key));
                }
                if (region == 'KH') {
                	allContractTargetMap.get(key).recordtypeid = MerchandisingSupportRecTypeID;
                    allContractTargetMap.get(key).ASI_CRM_KH_FOC_Support_in_actual_Bottle__c 
                        = allContractTargetMap.get(key).ASI_CRM_KH_FOC_Support_in_actual_case__c *
                          allContractTargetMap.get(key).ASI_CRM_PackagingSize__c;
                    allContractTargetMap.get(key).ASI_CRM_KH_Total_Price__c 
                        = allContractTargetMap.get(key).ASI_CRM_KH_FOC_Support_in_actual_case__c *
                          allContractTargetMap.get(key).ASI_CRM_PackagingSize__c * 
                          allContractTargetMap.get(key).ASI_CRM_KH_Value_per_Unit__c;
                } else {
                	allContractTargetMap.get(key).recordtypeid = ContractTargetRecTypeID;
                }
                System.debug ('Saving ... '+allContractTargetMap.get(key));
                
                upsertContractTargetList.add(allContractTargetMap.get(key));
            }
            
            List<ASI_CRM_ContractTarget__c> upsertMerchandiseContractList = new List<ASI_CRM_ContractTarget__c>();
            for(String key : allMerchandiseContractTargetMap.keySet()){
                if (allMerchandiseContractTargetMap.get(key).ASI_CRM_KH_Merchandise_Name__c == null 
                    || allMerchandiseContractTargetMap.get(key).ASI_CRM_KH_Merchandising_Size__c == null
                    || allMerchandiseContractTargetMap.get(key).ASI_CRM_KH_Merchandising_Quantity__c == null) 
                {
                    continue;    
                }
                
                
                if(allMerchandiseContractTargetMap.get(key).Id == null){
                    allMerchandiseContractTargetMap.get(key).ASI_CRM_Contract__c = contractId;
                    System.debug ('dd' + contractObj.ASI_CRM_CN_Outlet_WS__c);
                    
                    allMerchandiseContractTargetMap.get(key).ASI_CRM_KH_Outlet_Name__c = contractObj.ASI_CRM_CN_Outlet_WS__c;
                    map_newContractTarget.put(key, allMerchandiseContractTargetMap.get(key));
                } 
                allMerchandiseContractTargetMap.get(key).recordtypeid = MerchandisingRecTypeID;
                upsertContractTargetList.add(allMerchandiseContractTargetMap.get(key));
            }
            
            System.debug('Flag - Save Contract - To Insert New Contract Target:' + map_newContractTarget);
            System.debug('Flag - Save Contract - Upsert Contract Target:' + upsertContractTargetList);
            if(upsertContractTargetList.size() > 0)
                upsertContractTarget = Database.upsert(upsertContractTargetList);
            System.debug('Flag - Save Contract - Upsert Contract Target:' + upsertContractTargetList);
            
            
            
            // UPSERT & DELECT SSIncentives
            if (region != 'KH') {
                List<ASI_CRM_ContractSalesStaffIncentive__c> SSIncentivesToUpsert = new List<ASI_CRM_ContractSalesStaffIncentive__c>();
                
                /**for(ASI_CRM_ContractSalesStaffIncentive__c item: allSSIncentivesMap.values()){
                if(item.id == null){
                item.ASI_CRM_Contract__c = contractId;
                }
                item.recordtypeid = SSIncentivesRecTypeID;
                SSIncentivesToUpsert.add(item);
                }**/
                for(String key: allSSIncentivesMap.keySet()){
                    if(allSSIncentivesMap.get(key).id == null){
                        allSSIncentivesMap.get(key).ASI_CRM_Contract__c = contractId;
                        map_newSSIncentives.put(key,allSSIncentivesMap.get(key));
                    }
                    allSSIncentivesMap.get(key).recordtypeid = SSIncentivesRecTypeID;
                    SSIncentivesToUpsert.add(allSSIncentivesMap.get(key));
                }
                if(SSIncentivesToUpsert.size() > 0){
                    upsert SSIncentivesToUpsert;
                }
                if(SSIncentivesToDelete.size() > 0){
                    delete SSIncentivesToDelete;
                    SSIncentivesToDelete.clear();
                }
            }
            
            if (region != 'KH') {
                // UPSERT & DELECT VolumeIncentives
                List<ASI_CRM_ContractVolumeIncentive__c> VolumeIncentivesToUpsert = new List<ASI_CRM_ContractVolumeIncentive__c>();
                /**for(ASI_CRM_ContractVolumeIncentive__c item: allVolumeIncentivesMap.values()){
                if(item.id == null){
                item.ASI_CRM_Contract__c = contractId;
                }
                item.recordtypeid = VolumeIncentivesRecTypeID;
                VolumeIncentivesToUpsert.add(item);
                }**/
                for(String key: allVolumeIncentivesMap.keySet()){
                    if(allVolumeIncentivesMap.get(key).id == null){
                        allVolumeIncentivesMap.get(key).ASI_CRM_Contract__c = contractId;
                        map_newVolIncentives.put(key, allVolumeIncentivesMap.get(key));
                    }
                    allVolumeIncentivesMap.get(key).recordtypeid = VolumeIncentivesRecTypeID;
                    VolumeIncentivesToUpsert.add(allVolumeIncentivesMap.get(key));
                }
                if(VolumeIncentivesToUpsert.size() > 0){
                    upsert VolumeIncentivesToUpsert;
                }
                if(VolumeIncentivesToDelete.size() > 0){
                    delete VolumeIncentivesToDelete;
                    VolumeIncentivesToDelete.clear();
                }
            }     
            
            if (region != 'KH') {
                // UPSERT & DELECT ASI_CRM_ContractOtherIncentive__c
                if(deleteOtherIncentivesList.size()>0){
                    Database.delete(deleteOtherIncentivesList);
                    deleteOtherIncentivesList.clear();
                }
                
                List<ASI_CRM_ContractOtherIncentive__c> upsertOtherIncentivesList = new List<ASI_CRM_ContractOtherIncentive__c>();
                for(String key : allOtherIncentivesMap.keySet()){
                    if(allOtherIncentivesMap.get(key).id == null){
                        allOtherIncentivesMap.get(key).ASI_CRM_Contract__c = contractId;
                        map_newOtherIncentives.put(key, allOtherIncentivesMap.get(key));
                    } 
                    allOtherIncentivesMap.get(key).recordtypeid = OtherIncentivesRecTypeID;
                    upsertOtherIncentivesList.add(allOtherIncentivesMap.get(key));
                }
                if(upsertOtherIncentivesList.size()>0)
                    Database.upsert(upsertOtherIncentivesList);
            }
            
            if (region != 'KH') {
                // UPSERT & DELECT ASI_CRM_PromoterPlacement__c
                if(deletePromoterPlacementList.size()>0){
                    Database.delete(deletePromoterPlacementList);
                    deletePromoterPlacementList.clear();
                }    
                
                List<ASI_CRM_PromoterPlacement__c> upsertPromoterPlacementList = new List<ASI_CRM_PromoterPlacement__c>();
                for(String key : allPromoterPlacementsMap.keySet()){
                    if(allPromoterPlacementsMap.get(key).id == null){
                        allPromoterPlacementsMap.get(key).ASI_CRM_Contract__c = contractId;
                        map_newPromoterPlacement.put(key, allPromoterPlacementsMap.get(key));
                    } 
                    allPromoterPlacementsMap.get(key).recordtypeid = PromoterPlacementRecTypeID;
                    upsertPromoterPlacementList.add(allPromoterPlacementsMap.get(key));
                }
                if(upsertPromoterPlacementList.size()>0)
                    Database.upsert(upsertPromoterPlacementList );
            }
            strPageID = (String)contractObj.Id;
        } catch (Exception e) {
            System.debug('Upsert Error: ' + e);
            Database.rollback(pSavepoint);      
            //Need to clear the temp Id for next insert:
            
            for(String ctKey: map_newContractTarget.KeySet() ){
                if(allContractTargetMap.get(ctKey)!=null && allContractTargetMap.get(ctKey).Id!=null){
                    allContractTargetMap.get(ctKey).Id = null;
                }
            }
            for(String ssKey: map_newSSIncentives.KeySet() ){
                if(allSSIncentivesMap.get(ssKey)!=null && allSSIncentivesMap.get(ssKey).Id!=null){
                    allSSIncentivesMap.get(ssKey).Id = null;
                }
            }
            for(String vlKey: map_newVolIncentives.KeySet() ){
                if(allVolumeIncentivesMap.get(vlKey)!=null && allVolumeIncentivesMap.get(vlKey).Id!=null){
                    allVolumeIncentivesMap.get(vlKey).Id = null;
                }
            }
            for(String otherKey: map_newOtherIncentives.KeySet() ){
                if(allOtherIncentivesMap.get(otherKey)!=null && allOtherIncentivesMap.get(otherKey).Id!=null){
                    allOtherIncentivesMap.get(otherKey).Id = null;
                }
            }
            for(String ppKey: map_newPromoterPlacement.KeySet() ){
                if(allPromoterPlacementsMap.get(ppKey)!=null && allPromoterPlacementsMap.get(ppKey).Id!=null){
                    allPromoterPlacementsMap.get(ppKey).Id = null;
                }
            }
            
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
            {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            }else if(e.getTypeName().contains('System.DmlException') && e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
            }else{       
                strError = 'The record cannot be saved, Please try again.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
        }
        
        /*if(!isQuickSave){
        pageRef = new PageReference('/'+contractObj.Id);
        pageRef.setRedirect(true);
        }*/
        
        return pageRef;
    } 
    
    // Tab - Contract Target or Merchandising Support
    // Add Contract Product Item
    public void addContractProductItem(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID');
        
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        
        if(allSKUMap.containsKey(param_contractSourceItemId)){
            
            if (region == 'KH') {
                ASI_CRM_ContractTarget__c asiCrmCT = new ASI_CRM_ContractTarget__c (
                                                         ASI_CRM_Contract__c = contractId,
                                                         //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_Contract_Target'),
                                                         ASI_CRM_SKU__c = param_contractSourceItemId,
                    									 ASI_CRM_KH_FOC_Support_in_actual_Bottle__c = 0
                                         			);
                
                List<ASI_CRM_ContractTarget__c> asiCrmCTList = new List<ASI_CRM_ContractTarget__c>();
                asiCrmCTList.add(asiCrmCT);
                List<FormulaRecalcResult> results = Formula.recalculateFormulas(asiCrmCTList);
				allContractTargetMap.put(param_contractSourceItemId,asiCrmCT);
                
            } else {
                allContractTargetMap.put(param_contractSourceItemId, 
                                         new ASI_CRM_ContractTarget__c(
                                             ASI_CRM_Contract__c = contractId,
                                             //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_Contract_Target'),
                                             ASI_CRM_SKU__c = param_contractSourceItemId
                                             //ASI_CRM_PackFactor__c = allSKUMap.get(param_contractSourceItemId).ASI_HK_CRM_Pack_Factor__c
                                         )
                                        );
                
                allSSIncentivesMap.put(param_contractSourceItemId, 
                                       new ASI_CRM_ContractSalesStaffIncentive__c(
                                           ASI_CRM_Contract__c = contractId,
                                           //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                           ASI_CRM_SKU__c = param_contractSourceItemId,
                                           ASI_CRM_CrossBrandSKU__c =param_contractSourceItemId,
                                           ASI_CRM_SetupCode__c ='SAVR',
                                           ASI_CRM_AchievedBtl__c = allSKUMap.get(param_contractSourceItemId).ASI_HK_CRM_Packaging_Size__c 
                                       )
                                      );
                
                allVolumeIncentivesMap.put(param_contractSourceItemId, 
                                           new ASI_CRM_ContractVolumeIncentive__c(
                                               ASI_CRM_Contract__c = contractId,
                                               //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                               ASI_CRM_SKU__c = param_contractSourceItemId,
                                               ASI_CRM_SetupCode__c ='VOLC'
                                           )
                                          );
                
                //Need to copy to other incentives as well; Updated 2018-02 by Introv:
                //Other Incentives SKU can be duplicate, key should be different:
                String otherIncKey = '';
                if(allOtherIncentivesMap.containsKey(param_contractSourceItemId)){
                    otherIncKey = param_contractSourceItemId + generateRandomString(5);
                } else {
                    otherIncKey = param_contractSourceItemId;
                }
                allOtherIncentivesMap.put(otherIncKey, 
                                          new ASI_CRM_ContractOtherIncentive__c(
                                              ASI_CRM_Contract__c = contractId,
                                              ASI_CRM_SKU__c = param_contractSourceItemId
                                          )
                                         );
            }
            
            addedSKUMap.put(param_contractSourceItemId, allSKUMap.get(param_contractSourceItemId));
            allSKUMap.remove(param_contractSourceItemId);
        }
        //return pageRef;
    }
    
    // Tab - Merchandising Contract
    public void addMerchandisingContract(){
        PageReference pageRef = null;
        Integer currentMerchandiseContractTarget = allMerchandiseContractTargetMap.size()+1;
        String merchandisingContractTableId = 'merchandising_'+currentMerchandiseContractTarget;
        
        allMerchandiseContractTargetMap.put(merchandisingContractTableId, 
                                     new ASI_CRM_ContractTarget__c (
                                         ASI_CRM_Contract__c = contractId,
                                         recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_KH_Merchandising')
                                     )
                                    );
        System.debug ('allMerchandiseContractTargetMap: '+allMerchandiseContractTargetMap);
        
    }
    
    // Tab - Sales & Staff Incentives
    public void selectContractSKUForChangeSS(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID_TO_CHANGE_SS');
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        skuIDForChangeSS=param_contractSourceItemId;
    }
    
    public void cancelContractSKUChangeSS(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID_TO_CHANGE_SS');
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        if (skuIDForChangeSS==param_contractSourceItemId) {
            skuIDForChangeSS='';
        }
    }
    
    public void changeContractCrossBrandSKUSS(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID_SS');
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        if (String.isEmpty(skuIDForChangeSS)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select SKU (Sales & Staff Incentive) to change by clicking "Edit". '));
        } else if ((!String.isEmpty(param_contractSourceItemId)) && allSSIncentivesMap.containsKey(skuIDForChangeSS)) {
            allSSIncentivesMap.get(skuIDForChangeSS).ASI_CRM_CrossBrandSKU__c =param_contractSourceItemId;
        }
    }
    
    public void removeContractSKU(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSKUId = params.get('PARAM_CONTRACT_SKU_ID');
        System.debug ('Deleting: '+param_contractSKUId);
        
        if(allContractTargetMap.containsKey(param_contractSKUId)){
            ASI_CRM_ContractTarget__c delContractTarget = allContractTargetMap.get(param_contractSKUId);
            
            if(delContractTarget.id != null){
                deleteContractTargetList.add(delContractTarget);
                
                if(allSSIncentivesMap.get(param_contractSKUId)!=null && allSSIncentivesMap.get(param_contractSKUId).Id!=null)
                    SSIncentivesToDelete.add(allSSIncentivesMap.get(param_contractSKUId));
                if(allVolumeIncentivesMap.get(param_contractSKUId)!=null && allVolumeIncentivesMap.get(param_contractSKUId).Id!=null)
                    VolumeIncentivesToDelete.add(allVolumeIncentivesMap.get(param_contractSKUId));
            }else{
                allSKUMap.put(param_contractSKUId, addedSKUMap.get(param_contractSKUId));
                addedSKUMap.remove(param_contractSKUId);
            }
            allContractTargetMap.remove(param_contractSKUId);
            allSSIncentivesMap.remove(param_contractSKUId);
            allVolumeIncentivesMap.remove(param_contractSKUId);
        }
        
        
        if(allMerchandiseContractTargetMap.containsKey(param_contractSKUId)){
            ASI_CRM_ContractTarget__c delContractTarget = allMerchandiseContractTargetMap.get(param_contractSKUId);
            System.debug ('delContractTarget : '+ delContractTarget);
            
            if(delContractTarget.id != null){
                deleteContractTargetList.add(delContractTarget);
                allMerchandiseContractTargetMap.remove(param_contractSKUId);
            } else {
                allMerchandiseContractTargetMap.remove(param_contractSKUId);
            }
         }
        		
        
        
        
        //return pageRef;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public void addContractProductItemOther(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID_OTHER');
        String Key;
        
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        
        if(allSKUMapOther.containsKey(param_contractSourceItemId)){
            Key = param_contractSourceItemId + generateRandomString(5);
            allOtherIncentivesMap.put(Key, 
                                      new ASI_CRM_ContractOtherIncentive__c(
                                          ASI_CRM_Contract__c = contractId,
                                          //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                          ASI_CRM_SKU__c = param_contractSourceItemId
                                      )
                                     );
        }
    }
    
    public void removeContractSKUOther(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSKUId = params.get('PARAM_CONTRACT_SKU_ID_OTHER');
        
        if(allOtherIncentivesMap.containsKey(param_contractSKUId)){
            ASI_CRM_ContractOtherIncentive__c delOtherIncentive = allOtherIncentivesMap.get(param_contractSKUId);
            if(delOtherIncentive.id != null){
                deleteOtherIncentivesList.add(delOtherIncentive);
            }
            allOtherIncentivesMap.remove(param_contractSKUId);
        }
    }
    
    public void cloneContractSKUOther(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSKUId = params.get('PARAM_CONTRACT_SKU_ID_OTHER');
        String Key;
        if(!String.isEmpty(param_contractSKUId) && allOtherIncentivesMap.containsKey(param_contractSKUId)){
            Key = param_contractSKUId + generateRandomString(5);
            ASI_CRM_ContractOtherIncentive__c clonedSKU = allOtherIncentivesMap.get(param_contractSKUId).clone(false,true,false,false);
            allOtherIncentivesMap.put(Key, clonedSKU);
        }
    }
    
    public void addContractProductItemPromoterPlacements(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID_PromoterPlacements');
        String Key;
        
        system.debug('in add function --- params : ' + params );
        system.debug('in add function --- SKU / param_contractSourceItemId : ' + param_contractSourceItemId);
        
        if(allSKUMapOther.containsKey(param_contractSourceItemId)){
            Key = param_contractSourceItemId + generateRandomString(5);
            allPromoterPlacementsMap.put(Key, 
                                         new ASI_CRM_PromoterPlacement__c(
                                             ASI_CRM_Contract__c = contractId,
                                             //recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                                             ASI_CRM_SKU__c = param_contractSourceItemId
                                         )
                                        );
        }
        //return pageRef;
    }
    
    public void removeContractSKUPromoterPlacements(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSKUId = params.get('PARAM_CONTRACT_SKU_ID_PromoterPlacements');
        
        if(allPromoterPlacementsMap.containsKey(param_contractSKUId)){
            ASI_CRM_PromoterPlacement__c delPromoterPlacement = allPromoterPlacementsMap.get(param_contractSKUId);
            if(delPromoterPlacement.id != null){
                deletePromoterPlacementList.add(delPromoterPlacement);
            }
            allPromoterPlacementsMap.remove(param_contractSKUId);
        }
        //return pageRef;
    }
    
    public List<SelectOption> getSubBrandSelectOptions(){
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('',''));
        //result.add(new SelectOption('ALL','ALL'));
        String subBrand = 'ASI_MFM_MY_Sub_brand';
        if (region == 'KH') {
            subBrand = 'ASI_KH_Sub_brand';
        }
        
        for(ASI_MFM_Sub_Brand__c sb : [SELECT Id, Name FROM ASI_MFM_Sub_Brand__c 
                                       WHERE recordtype.developername =: subBrand 
                                       ORDER BY name]){
            result.add(new SelectOption(sb.id, sb.name));
        }
        return result;
    }   
}