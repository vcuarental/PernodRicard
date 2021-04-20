trigger EUR_CRM_UpdatePostalCodeTerritoryMappingName on EUR_CRM_Postal_Code_Territory_Mapping__c (before insert, before update) {
    Set<Id> territories = new Set<Id>(); 
    for(EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping : trigger.new){
        if(Trigger.IsInsert || (Trigger.IsUpdate&& (postalCodeTerritoryMapping.EUR_CRM_Territory__c!= trigger.oldMap.get(postalCodeTerritoryMapping.id).EUR_CRM_Territory__c)) ) 
        territories.add(postalCodeTerritoryMapping.EUR_CRM_Territory__c);      
    }
   
    Map<Id,EUR_CRM_Territory__c> terrritoryMap = new Map<Id,EUR_CRM_Territory__c>();
    if(territories.size() > 0){
         terrritoryMap = new Map<Id,EUR_CRM_Territory__c>([select id, name from EUR_CRM_Territory__c where id in: territories]);          
        for(EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping : trigger.new){
            if(terrritoryMap.get(postalCodeTerritoryMapping.EUR_CRM_Territory__c) != null)
                postalCodeTerritoryMapping.name = terrritoryMap.get(postalCodeTerritoryMapping.EUR_CRM_Territory__c).name + ' - ' +  postalCodeTerritoryMapping.EUR_CRM_Postal_Code__c;
        } 
    }
}