public class EUR_CRM_PostalCodeTerrMapChangedHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_PostalCodeTerrMapChangedHandler (){
        super('EUR_CRM_PostalCodeTerrMapChangedHandler');
    }        
    Set<String> validRecordTypes = new Set<String>{
        'EUR_DE_On_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping',
        'EUR_DE_On_Trade_Prestige_Postal_Code_Territory_Mapping'
    };
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> postalCodeTerrMapRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Postal_Code_Territory_Mapping__c');
        Map<Id,Recordtype> postalCodeTerrMapRecordTypesMap= new Map<Id,Recordtype>();
        
        for(Recordtype rt : postalCodeTerrMapRecordTypes){
           postalCodeTerrMapRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_Postal_Code_Territory_Mapping__c> validRecords = new List<EUR_CRM_Postal_Code_Territory_Mapping__c>();
        Map<String,Id> newTerritoryMap = new Map<String, Id>();
        Set<Id> oldTerritories = new Set<Id>();
        Set<Id> newTerritories = new Set<Id>();
        Set<String> postalCodes = new Set<String>();
        //key = oldterritory + postalcode. 
        
        for(EUR_CRM_Postal_Code_Territory_Mapping__c record: (List<EUR_CRM_Postal_Code_Territory_Mapping__c>) sObjList){
            String rtDevName = postalCodeTerrMapRecordTypesMap.get(record.recordTypeId).developername;
            EUR_CRM_Postal_Code_Territory_Mapping__c oldRecord = (EUR_CRM_Postal_Code_Territory_Mapping__c ) oldMap.get(record.id);            
            if(validRecordTypes.contains(rtDevName ) && oldRecord.EUR_CRM_Territory__c != record.EUR_CRM_Territory__c){
                String key = oldRecord.EUR_CRM_Territory__c + record.EUR_CRM_Postal_Code__c;
                newTerritoryMap.put(key, record.EUR_CRM_Territory__c);
                oldTerritories.add(oldRecord.EUR_CRM_Territory__c);
                newTerritories.add(record.EUR_CRM_Territory__c);
                postalCodes.add(record.EUR_CRM_Postal_Code__c);
            }
        }
        system.debug('@@ : newTerritoryMap' + newTerritoryMap);
        system.debug('@@ : oldTerritories' + oldTerritories);
        system.debug('@@ : newTerritories' + newTerritories);
        system.debug('@@ : postalCodes' + postalCodes);
        
        if(newTerritories.size() > 0){
            List<EUR_CRM_Territory__c> territories = new List<EUR_CRM_Territory__c>();
            for(Id territoryId : newTerritories){
                territories.add(new EUR_CRM_Territory__c(id = territoryId, EUR_CRM_IsOwnerChanged__c = true));
            }
            update territories;
        }
        
        if(oldTerritories.size() > 0 && postalCodes.size() > 0){
            List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();
            
            for(EUR_CRM_Account__c euAccount : [select id,EUR_CRM_Territory__c,EUR_CRM_Prestige_Territory__c, EUR_CRM_Postal_Code__c  from EUR_CRM_Account__c where (EUR_CRM_Territory__c in:oldTerritories OR EUR_CRM_Prestige_Territory__c in:oldTerritories) AND
             EUR_CRM_Postal_Code__c in: postalCodes]){
                 String key = euAccount.EUR_CRM_Territory__c  +  euAccount.EUR_CRM_Postal_Code__c ;
                 String prestigeKey = euAccount.EUR_CRM_Prestige_Territory__c  +  euAccount.EUR_CRM_Postal_Code__c ;
                 Id newTerritory = newTerritoryMap.get(key);
                 Id newPrestigeTerritory = newTerritoryMap.get(prestigeKey);
                 Boolean changed = false;
                if(newTerritory != null){
                    euAccount.EUR_CRM_Territory__c = newTerritory ;
                    changed = true; 
                }   
                if(newPrestigeTerritory != null){
                    euAccount.EUR_CRM_Prestige_Territory__c = newPrestigeTerritory ;
                    changed = true;
                }                
                if(changed)
                    euAccounts.add(euAccount);
                    
            }
            if(euAccounts.size() > 0 )
                update euAccounts;
        system.debug('@@ : euAccounts' + euAccounts);
        }
        
    }
}