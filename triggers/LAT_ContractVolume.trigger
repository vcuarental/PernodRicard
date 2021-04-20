trigger LAT_ContractVolume on LAT_ContractVolume__c (before insert, before update) {
    Set<Id> contIds = new Set<Id>();
    for(LAT_ContractVolume__c vol : trigger.new){
        contIds.add(vol.LAT_Contract__c );
    }
    Map<Id, LAT_Contract2__c> mapConts = new Map<Id, LAT_Contract2__c>([SELECT Id, RecordType.Developername FROM LAT_Contract2__c WHERE Id IN:contIds]);
    for(LAT_ContractVolume__c vol : trigger.new){
        if(mapConts.get(vol.LAT_Contract__c) != null){
            vol.LAT_ContractRTDevName__c = mapConts.get(vol.LAT_Contract__c).RecordType.Developername;
        }
    }
}