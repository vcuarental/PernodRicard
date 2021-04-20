/**
Template (Listing) - Implement Mass Template Update feature (similar to JB) but re-map the handler to update the account field EUR_CRM_Listing_Template__c instead of the one used by JB (EUR_JB_Default_Template__c)
Template (Listing) - Implement Mass Template Update - ensure that when executing tne Mass Update Template function, the handler will filter out INACTIVE Accounts, and INACTIVE Template Criteria
Templates (Listing) - Implement Template Criteria Trigger - will execute on edit - 

IF template criteria changed from Active to Inactive - 
- find all affected accounts and query if there are any other Template Criteria records that have same criteria match (PROS) - technically there should NOT be but do the check anyway
- IF no matching similar Template Criteria found, 
- find all affected accounts and set EUR_CRM_Listing_Template__c to null

IF template criteria changed from Inactive to Active
- find all affected accounts
- look for other Template Criteria records with matching config
- if YES > DO NOTHING
- if NO > assign listing template associated with this Template Criteria

*/
public with sharing class EUR_CRM_DE_TemplateCriteriaHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_DE_TemplateCriteriaHandler(){
        super('EUR_CRM_DE_TemplateCriteriaHandler');
    } 
    
    private static Set<String> onTradeEUAccountRecordTypeSet = new Set<String>{
      //'EUR_DE_ON_Consumers',
      //'EUR_DE_ON_Enquiry_Acquisition',
      'EUR_DE_ON_Gastronomy'
      //'EUR_DE_ON_Service_agency',
      //'EUR_DE_ON_Wholesaler'
      };
 
    
    private static Set<String> validRecordTypeSet = new Set<String>{
        'EUR_CRM_DE_Template_Criteria'
    };  
    private static String ACTIVE = 'Active';
    private static String INACTIVE = 'Inactive';

    /**
    
    */
    private Map<Id,Recordtype> accountRecordTypesMap;
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> templateCriteriaRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_JB_Template_Criteria__c');
        Map<Id,Recordtype> templateCriteriaRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : templateCriteriaRecordTypes ){
           templateCriteriaRecordTypesMap.put(rt.id,rt);
        }
        List<EUR_CRM_JB_Template_Criteria__c> validTemplateCriteriaList = new List<EUR_CRM_JB_Template_Criteria__c>();
        Set<String> groupOutletTypeSet = new Set<String>();
        Set<String> outletTypeSet = new Set<String>();
        Set<String> imageLevelSet = new Set<String>();
        Set<String> volumePotentialSet = new Set<String>();
        Map<String, EUR_CRM_JB_Template_Criteria__c> templateCriteriaMap = new Map<String, EUR_CRM_JB_Template_Criteria__c>();
     
        for(EUR_CRM_JB_Template_Criteria__c templateCriteria: (List<EUR_CRM_JB_Template_Criteria__c>) sObjList){ 
        
            if(validRecordTypeSet.contains(templateCriteriaRecordTypesMap.get(templateCriteria.recordtypeid).developername)
               && templateCriteria.EUR_JB_Active__c
               && (Trigger.isInsert || (Trigger.isUpdate && templateCriteria.EUR_JB_Active__c != ((EUR_CRM_JB_Template_Criteria__c)oldMap.get(templateCriteria.id)).EUR_JB_Active__c ))){
                 String key = createKey(templateCriteria.EUR_JB_Group_Outlet_Type__c,templateCriteria.EUR_JB_Outlet_Type__c,
                                    templateCriteria.EUR_JB_Image_Level__c,templateCriteria.EUR_JB_Volume_Potential__c,
                                     'EUR_DE_ON_TRADE_Template');
                templateCriteriaMap.put(key,templateCriteria);
                groupOutletTypeSet.add(templateCriteria.EUR_JB_Group_Outlet_Type__c);
                outletTypeSet.add(templateCriteria.EUR_JB_Outlet_Type__c);
                imageLevelSet.add(templateCriteria.EUR_JB_Image_Level__c);
                volumePotentialSet.add(templateCriteria.EUR_JB_Volume_Potential__c);
            }
        }
        
        List<EUR_CRM_Account__c> onTradeAccounts = new List<EUR_CRM_Account__c>();
        for(EUR_CRM_Account__c euAccount : [select id,EUR_CRM_Listing_Template__c,EUR_CRM_Status_of_Customer__c,
            EUR_CRM_Group_Outlet_Type__c ,
            EUR_CRM_Outlet_Type__c ,
            EUR_CRM_Image_Level__c ,
            EUR_CRM_Volume_Potential__c 
           from EUR_CRM_Account__c
            where 
            EUR_CRM_Group_Outlet_Type__c in: groupOutletTypeSet
            AND EUR_CRM_Outlet_Type__c in: outletTypeSet
            AND EUR_CRM_Image_Level__c in: imageLevelSet
            AND EUR_CRM_Volume_Potential__c in: volumePotentialSet
            AND RecordType.Developername in: onTradeEUAccountRecordTypeSet]){
            String acctKey = createKey(euAccount.EUR_CRM_Group_Outlet_Type__c,euAccount.EUR_CRM_Outlet_Type__c,
                                        euAccount.EUR_CRM_Image_Level__c,euAccount.EUR_CRM_Volume_Potential__c,
                                        'EUR_DE_ON_TRADE_Template');
            if (templateCriteriaMap.containsKey(acctKey) &&
                euAccount.EUR_CRM_Listing_Template__c == null &&
                euAccount.EUR_CRM_Status_of_Customer__c == ACTIVE){
                    euAccount.EUR_CRM_Listing_Template__c = templateCriteriaMap.get(acctKey).EUR_JB_Template__c;
                    onTradeAccounts.add(euAccount);
            }
        }
        
        update onTradeAccounts;
        
    }
    
    public  String createKey(String g, String o, String i, String v, String recordTypeName){
        return g+'-'+o+'-'+i+'-'+v + recordTypeName;
    }
}