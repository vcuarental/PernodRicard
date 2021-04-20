/** 
Before Insert/Update of EU Account;
- Automatically populate the territory field of the account using the POSTAL CODE and the Postal Territory Mapping
- Account owner is always equal the the territory owner
- There are 3 types of territories
1. OFF Trade - Assign off trade territory to Off trade accounts using the postal code
2. ON Trade - Assign on trade territory to On Trade accounts using the postal code
3. ON Trade Prestige - Special Case.   
    If(Current User or Account Owner(for update) is a prestige Sales Rep (Role = 'EUR_DE_GSL_Prestige');
        Find the corresponsing prestige territory using the account postal code
            and assign it to the EUR_CRM_Territory__c field
            and mark the account as EUR_CRM_Is_Prestige_Account__c)
    If( EUR_CRM_Is_Prestige_Account__c is equal to true)
        Find the corresponsing prestige territory using the account postal code
           and assign it to the EUR_CRM_Prestige_Territory__c field.
           also addign EUR_CRM_Prestige_Sales_Rep__c with the prestige territory owner name.
June 24 2015

Before Insert
    if force iconic flag is true, trigger sets the EUR_CRM_Is_Prestige_Account__c to true
Before Update
    if force iconic flag is true, trigger sets the EUR_CRM_Is_Prestige_Account__c flag to true
    if image level is iconic, trigger sets the EUR_CRM_Is_Prestige_Account__c flag to true
    if account is Iconic and the user changed the EUR_CRM_Is_Prestige_Account__c flag to false from being true.
    trigger throws an error.



2017-Jun-08:
Assign territory only for off trade account, On trade will depends on Account Owner's territory

*/
public with sharing class EUR_CRM_DE_TerritoryAccountHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_DE_TerritoryAccountHandler(){
        super('EUR_CRM_DE_TerritoryAccountHandler');
    } 
    
    private static Set<String> allDEAccountRecordTypeSet = new Set<String>{
      //'EUR_DE_ON_Consumers',
      //'EUR_DE_ON_Enquiry_Acquisition',
      //'EUR_DE_ON_Gastronomy',
      //'EUR_DE_ON_Service_agency',
      //'EUR_DE_ON_Wholesaler',
      'EUR_DE_OFF_STD' 
      
    }; 
    private final static String PRESTIGE = 'prestige';
    private static Map<String,String> euAccountRecordTypePostalCodeMapping = new Map<String,String>{
        'EUR_DE_ON_Consumers' => 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_ON_Enquiry_Acquisition'=> 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_ON_Gastronomy'=> 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_ON_Service_agency'=> 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_ON_Wholesaler'=> 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping', 
        'EUR_DE_OFF_STD'=> 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping',
        'prestige'=>'EUR_DE_On_Trade_Prestige_Postal_Code_Territory_Mapping' //special case, there is no prestige on trade eu account record type
    };
    private static Set<String> onTradePrestigeSalesRep = new Set<String>{
        'EUR_DE_GSL_Prestige'
    }; 

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allDEAccountRecordTypeSet);
            return TRt;
        }private set;
    }

    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 
        System.Debug('@@ Execute EUR_CRM_DE_TerritoryAccountHandler');
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        
        Set<String> postalCodeSet = new Set<String>();  
        Set<Id> recordOwner = new Set<Id>(); 
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            if(allDEAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName)){ 
                if(euAccount.eur_crm_postal_code__c != null && euAccount.EUR_CRM_Postal_Code__c != '')
                    postalCodeSet.add(euAccount.eur_crm_postal_code__c); 
                recordOwner.add(euAccount.OwnerId);
            }
        } 
        
        //key Postal Code + RecordType DeveloperName
        Map<String,EUR_CRM_Postal_Code_Territory_Mapping__c> postalCodeMap = new Map<String,EUR_CRM_Postal_Code_Territory_Mapping__c>();
        List<EUR_CRM_Postal_Code_Territory_Mapping__c> postalMapList = new List<EUR_CRM_Postal_Code_Territory_Mapping__c>();
        
        if(postalCodeSet.size() > 0){
            postalMapList = [select id,RecordType.name, RecordType.DeveloperName, EUR_CRM_Postal_Code__c,EUR_CRM_Territory__c, name, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.Name
                            from EUR_CRM_Postal_Code_Territory_Mapping__c  where EUR_CRM_Postal_Code__c in: postalCodeSet
                            AND RecordType.DeveloperName in: euAccountRecordTypePostalCodeMapping.values()];
        }
        
        for(EUR_CRM_Postal_Code_Territory_Mapping__c postalMap :postalMapList){
            String key = postalMap.EUR_CRM_Postal_Code__c + postalMap.RecordType.DeveloperName;
            postalCodeMap.put(key,postalMap);
        }  
        Map<Id, String> userRole = new Map<Id, String>();
        recordOwner.add(UserInfo.getUserId());
        
        for(User usr :[Select Id, UserRole.DeveloperName From User Where Id IN :recordOwner]){
                userRole.put(usr.Id, usr.UserRole.DeveloperName);
        }
        
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            
            String accountRecordTypeDeveloperName = accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName;
            
            if(!allDEAccountRecordTypeSet.contains(accountRecordTypeDeveloperName))
                continue;

            EUR_CRM_Account__c oldEuAccount = tAction == TriggerAction.BEFORE_UPDATE ? ((EUR_CRM_Account__c) oldMap.get(euAccount.id)) : null;
            

            Boolean isIconic = euAccount.EUR_CRM_Force_Iconic_Account__c || (euAccount.EUR_CRM_Image_Level__c != null && euAccount.EUR_CRM_Image_Level_Name__c == 'Iconic');
            
            if(Trigger.IsUpdate && isIconic && !euAccount.EUR_CRM_Is_Prestige_Account__c
                    && oldEuAccount.EUR_CRM_Is_Prestige_Account__c){
                    euAccount.addError('Account is Iconic, cannot uncheck Is Prestige Account field');
                    continue;
            }  

            if(isIconic){
                euAccount.EUR_CRM_Is_Prestige_Account__c = true;
            }
            //check if valid eu account recordtype
            //and if action is insert
            //or update and there is a change on 'postal code' or 'is prestige account' field
            if( tAction == TriggerAction.BEFORE_INSERT || (tAction == TriggerAction.BEFORE_UPDATE && 
               (euAccount.eur_crm_postal_code__c != oldEuAccount.eur_crm_postal_code__c ||
               euAccount.EUR_CRM_Is_Prestige_Account__c != oldEuAccount.EUR_CRM_Is_Prestige_Account__c)
               )){
                String key = '';
                Id territory = null;
                
                
                //insert: check if current user is prestige sales rep or not
                //update: check if ownerid  is prestige sales rep or not
                
                if((tAction == TriggerAction.BEFORE_INSERT && onTradePrestigeSalesRep.contains(userRole.get(UserInfo.getUserId())))// ||
                   //(tAction == TriggerAction.BEFORE_UPDATE && onTradePrestigeSalesRep.contains(userRole.get(euAccount.ownerid))
                   //euAccount.EUR_CRM_Is_Prestige_Account__c 
                  ){
                    //use the PRESTIGE and POSTAL code as key in finding the corresponding prestige territory
                    key = euAccount.eur_crm_postal_code__c + euAccountRecordTypePostalCodeMapping.get(PRESTIGE); 
                    territory = postalCodeMap.get(key) != null ? postalCodeMap.get(key).EUR_CRM_Territory__c : null;
                    euAccount.EUR_CRM_Is_Prestige_Account__c  = true;
                }else{             
                    
                    //use the posal code mapping record type and POSTAL code as key in finding the corresponding territory     
                    key = euAccount.eur_crm_postal_code__c + euAccountRecordTypePostalCodeMapping.get(accountRecordTypeDeveloperName);
                    territory = postalCodeMap.get(key) != null ? postalCodeMap.get(key).EUR_CRM_Territory__c : null;                     
                
                }
                //if no territory found using the postal code throw an error.
                if(territory == null){
                    euAccount.addError('No Matching Postal Code Found');
                    break;
                }
                
                system.debug('######');
                system.debug('key ' + key);
                system.debug('territory' + territory);
                //assign the territory the account territory field         
                euAccount.EUR_CRM_Territory__c = territory;
                
                //assign the territory owner the account owner field 
                euAccount.OwnerId = postalCodeMap.get(key).EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c;
                
                //assign the prestige territory and owner to the account prestige fields
                if(euAccount.EUR_CRM_Is_Prestige_Account__c){
                    key = euAccount.eur_crm_postal_code__c + euAccountRecordTypePostalCodeMapping.get(PRESTIGE);
                    
                    Id prestigeTerritory = postalCodeMap.get(key) != null ? postalCodeMap.get(key).EUR_CRM_Territory__c : null;                    
                    if(prestigeTerritory != null){    
                        euAccount.EUR_CRM_Prestige_Territory__c = prestigeTerritory;
                        euAccount.EUR_CRM_Prestige_Sales_Rep__c = postalCodeMap.get(key).EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.Name;
                        euAccount.EUR_CRM_Prestige_Sales_Rep_ID__c = postalCodeMap.get(key).EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c;
                    }
                }else{
                    //else remove the values from the prestige fields
                    euAccount.EUR_CRM_Prestige_Territory__c = null;
                    euAccount.EUR_CRM_Prestige_Sales_Rep__c = null;
                    euAccount.EUR_CRM_Prestige_Sales_Rep_ID__c = null; 
                }
            }
        
        }
    }
}