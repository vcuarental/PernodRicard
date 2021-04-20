/*********************************************************************************
 * Name: ASI_CRM_MY_ContractSummaryCtl
 * Description: Controller class for ASI_CRM_MY_ContractSummaryPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-02       Daniel WONG             Created 
 * 2015-01-03       Daniel WONG             --
 * 2018-01          Introv                  Added Cross-brand SKU for Sales & Staff display
 */


public with sharing class ASI_CRM_MY_ContractSummaryCtl{
        
    private ApexPages.StandardController standardController {get;set;}
    private Id contractId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    public Boolean isKH {get;set;}
    public Integer NumOfMonth {get; set;}
    public Boolean hasCrossBrandSKUSS {get; private set;} {hasCrossBrandSKUSS = FALSE;}
    public Map<Id, Decimal> mapSKUbtl {get; set;} {mapSKUbtl = new Map<Id, Decimal>();}
    public Map<String, List<customOtherIncentives>> allOtherIncentivesMap {get;set;}{allOtherIncentivesMap = new Map<String, List<customOtherIncentives>>();}
    public list<ASI_CRM_ContractTarget__c> getMerchandisingSupport(){
        return [Select Id,ASI_CRM_SKUCode__c,ASI_CRM_SKU__c,ASI_CRM_SKU__r.name,
               	ASI_CRM_PackFactor__c,ASI_CRM_KH_Value_per_Unit__c,ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
                ASI_CRM_KH_FOC_Support_in_actual_case__c, ASI_CRM_KH_FOC_Support_in_actual_Bottle__c,
                ASI_CRM_KH_Total_Price__c FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = :contractId and recordType.DeveloperName = 'ASI_KH_Merchandising_Support'
            ORDER BY ASI_CRM_SKU__r.name ASC
               ];
    }
        public list<ASI_CRM_ContractTarget__c> getMerchandising(){
        return [Select Id,ASI_CRM_KH_Outlet_Name__c,ASI_CRM_KH_Merchandise_Name__c,ASI_CRM_KH_Merchandising_Size__c,
               	ASI_CRM_KH_Merchandising_Quantity__c FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = :contractId and recordType.DeveloperName = 'ASI_CRM_KH_Merchandising'
            ORDER BY ASI_CRM_KH_Outlet_Name__c ASC
               ];
    }
    public list<ASI_CRM_ContractTarget__c> getSalesTarget(){    
        List<ASI_CRM_ContractTarget__c> lstSalesTarget = [
            SELECT id, ASI_CRM_SKUCode__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.name,
                ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
                ASI_CRM_PackFactor__c, ASI_CRM_TargetCase__c,
                ASI_CRM_MinSPCase__c, ASI_CRM_Total__c,
                ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = :contractId
            ORDER BY ASI_CRM_SKU__r.name ASC
        ];
        
        for(ASI_CRM_ContractTarget__c i : lstSalesTarget){
            Decimal temp = 0;
            
            if(i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != NULL && i.ASI_CRM_TargetCase__c != NULL)
                temp = i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c * i.ASI_CRM_TargetCase__c;
                
            mapSKUbtl.put(i.ASI_CRM_SKU__c, temp);
        }
             
        return lstSalesTarget;
    }
    
    public list<ASI_CRM_ContractSalesStaffIncentive__c> getSSIncentive(){     
        List<ASI_CRM_ContractSalesStaffIncentive__c> lstSSIncentive = [
            SELECT id, ASI_CRM_SKUCode__c, ASI_CRM_SKU__r.name, ASI_CRM_SKU__c,
                ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c, ASI_CRM_AchievedBtl__c,
                ASI_CRM_FOCWS__c, ASI_CRM_FOCPRM__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c,
                ASI_CRM_Total__c, ASI_CRM_JDECOA__c,
                ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ASI_CRM_CrossBrandSKU__c, ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c
            FROM ASI_CRM_ContractSalesStaffIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_Exclude__c = FALSE
            ORDER BY ASI_CRM_SKU__r.name ASC
        ];
        
        for(ASI_CRM_ContractSalesStaffIncentive__c ssInc : lstSSIncentive){
            if(ssInc.ASI_CRM_CrossBrandSKU__c!=null && ssInc.ASI_CRM_SKU__c!=null && ssInc.ASI_CRM_CrossBrandSKU__c!= ssInc.ASI_CRM_SKU__c){
                hasCrossBrandSKUSS =TRUE;
                break;
            }
        }
                    
        return lstSSIncentive;
    }
    
    
    public Class customVolInc{
        public ASI_CRM_ContractVolumeIncentive__c ppl {get; set;}
        public Decimal achievedBtl {get; set;}
    }
    
    public List<customVolInc> results {get; set;} {results = new List<customVolInc>();}

    public void retrieveVolInc(ID contractId){
        customVolInc customObj;
        system.debug('-----------------------------' + mapSKUbtl);
        if(contractId != null){
            for(ASI_CRM_ContractVolumeIncentive__c c :
                [SELECT id, ASI_CRM_SKUCode__c, ASI_CRM_SKU__r.name, ASI_CRM_SKU__c,
                    ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c, ASI_CRM_AchievedBtl__c ,
                    ASI_CRM_FOC__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c,
                    ASI_CRM_Total__c, ASI_CRM_JDECOA__c,
                    ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ASI_CRM_Description__c
                FROM ASI_CRM_ContractVolumeIncentive__c
                WHERE ASI_CRM_Contract__c = :contractId
                AND ASI_CRM_Exclude__c = FALSE
                ORDER BY ASI_CRM_SKU__r.name
                ]){
                    customObj = new customVolInc();
                    customObj.ppl = c;
                    customObj.achievedBtl = 0;
                    if(mapSKUbtl.get(c.ASI_CRM_SKU__c) != NULL)
                        customObj.achievedBtl = mapSKUbtl.get(c.ASI_CRM_SKU__c);
                    results.add(customObj);
                 }
        }
    }
    
    /*public list<ASI_CRM_ContractVolumeIncentive__c> getVolumeIncentive(){     
        List<ASI_CRM_ContractVolumeIncentive__c> lstVolumeIncentive = [
            SELECT id, ASI_CRM_SKUCode__c, ASI_CRM_SKU__r.name,
                ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c, ASI_CRM_AchievedBtl__c ,
                ASI_CRM_FOC__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c,
                ASI_CRM_Total__c, ASI_CRM_JDECOA__c,
                ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ASI_CRM_Description__c
            FROM ASI_CRM_ContractVolumeIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_Exclude__c = FALSE
            ORDER BY ASI_CRM_SKU__r.name
        ];             
        
        return lstVolumeIncentive;
    }*/
        
    public ASI_CRM_MY_ContractSummaryCtl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if(contractId != NULL){
            List <ASI_TH_CRM_Contract__c> c = [SELECT id,RecordType.DeveloperName, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId];
            
            
            isKH = c[0].RecordType.DeveloperName.contains('_KH_');
            NumOfMonth = c[0].ASI_TH_CRM_Start_Date__c.monthsBetween(c[0].ASI_TH_CRM_End_Date__c) + 1;
        }
        getSalesTarget();
        allOtherIncentivesMap = retrieveOtherIncentives(contractId);
        retrieveVolInc(contractId);
    }
    
    public Class customOtherIncentives{
        public String strKey;
        public ASI_CRM_ContractOtherIncentive__c ppl {get; set;}
        public Boolean showSub {get; set;} {showSub = FALSE;}
        public Decimal subTotal {get; set;}
    }
    
    public Map<String, Decimal> mapSubTotal{get; set;} {mapSubTotal = new Map<String, Decimal>();}
    
    public Map<String, List<customOtherIncentives>> retrieveOtherIncentives(ID contractId){
        Map<String, List<customOtherIncentives>> OtherIncentivesMap = new Map <String, List<customOtherIncentives>>();
        customOtherIncentives customObj;
        Decimal tempSubTotal = 0;
        
        if(contractId != null){
            for(ASI_CRM_ContractOtherIncentive__c c :
                [SELECT Id, Name, ASI_CRM_Type__c, ASI_CRM_Description__c,
                        ASI_CRM_SKU__r.name, ASI_CRM_SKUCode__c, ASI_CRM_PackFactor__c, ASI_CRM_MinSPBtl__c,
                        ASI_CRM_FOC__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c, ASI_CRM_Total__c,
                        ASI_CRM_JDECOA__c,
                        ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
                 FROM  ASI_CRM_ContractOtherIncentive__c
                 WHERE ASI_CRM_Contract__c = :contractId
                 AND ASI_CRM_Exclude__c = FALSE 
                 ORDER BY ASI_CRM_Type__c ASC, ASI_CRM_Description__c ASC, ASI_CRM_SKU__r.name
                ]){ 
                    List<customOtherIncentives> lstOfOtherIncentive = new List<customOtherIncentives>();
                    if(OtherIncentivesMap.get(c.ASI_CRM_Type__c) != null){
                        lstOfOtherIncentive = OtherIncentivesMap.get(c.ASI_CRM_Type__c);
                        if(c.ASI_CRM_Total__c != NULL){
                            tempSubTotal = tempSubTotal + c.ASI_CRM_Total__c;
                        }
                    }else{
                        tempSubTotal = c.ASI_CRM_Total__c == null ? 0 : c.ASI_CRM_Total__c;
                    }
                    
                    customObj = new customOtherIncentives();
                    customObj.strKey = c.ASI_CRM_Type__c;
                    customObj.ppl = c;
                    customObj.subtotal = tempSubTotal;
                    
                    lstOfOtherIncentive.add(customObj);
                    Decimal temp = 0;
                    if(c.ASI_CRM_Total__c != NULL) temp = c.ASI_CRM_Total__c;

                    if(mapSubTotal.get(customObj.strKey) != NULL){
                        temp += mapSubTotal.get(customObj.strKey); 
                    }
                    
                    mapSubTotal.put(customObj.strKey, temp);
                    OtherIncentivesMap.put(customObj.strKey, lstOfOtherIncentive);
                 }
        }
        return OtherIncentivesMap;
    }
}