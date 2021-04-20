trigger LAT_LATAccountBefore on LAT_ACCOUNT__c (before insert, before update) {

	//Filtrado de RecordTypes
    LAT_Trigger trigger_LAT = new LAT_Trigger('LAT_ACCOUNT__c', new set<String>{'LAT_MX_LAC_Standard'});
    LAT_Trigger trigger_LAT_AR = new LAT_Trigger('LAT_ACCOUNT__c', new set<String>{'LAT_AR_LAC_Standard', 'LAT_UY_LAC_Standard'});
    LAT_Trigger trigger_LAT_BR = new LAT_Trigger('LAT_ACCOUNT__c', new set<String>{'LAT_BR_LAC_Standard'});
    String documentsArgRtId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR');
    Map<Id, LAT_ACCOUNT__c> latAccountOldMap = new Map<Id, LAT_ACCOUNT__c>(); 

    system.debug('%%%%% trigger_LAT_AR : '+trigger_LAT_AR);
    system.debug('%%%%% trigger_LAT : '+trigger_LAT);
    if (!trigger_LAT.getNew().IsEmpty()) {
        // Load old map
        latAccountOldMap = new Map<Id, LAT_ACCOUNT__c>(); 
        if (trigger.isUpdate){
        	for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT.getOld()){
    			latAccountOldMap.put(lata.Id, lata);
    		}
    	}
    	
    	// Load account ids and create a map by owner (need to load as the parent record field values are empty in tgr context)
        Set<Id> accIds = new Set<Id>();
    	for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT.getNew()){
    		accIds.add(lata.LAT_AccountId__c);
    	}

    	// Load accounts by Id to use in the child objs
    	Map<Id, Account> accountsById = new Map<Id, Account>
    			([SELECT Id, OwnerId, RecordType.DeveloperName, Owner.Profile.Name FROM Account WHERE Id In :accIds]);      

    	Map <Id, LAT_ACCOUNT__c> oldMap = (Trigger.isInsert) ? new Map <Id, LAT_ACCOUNT__c>() : new Map<Id, LAT_ACCOUNT__c> ((List<LAT_ACCOUNT__c>)trigger_LAT.getOld());
        LAT_MX_OnTrade_Account.validarZipCode(trigger_LAT.getNew(), oldMap, Trigger.isInsert);
        LAT_MX_OnTrade_Account.calcularValorCalificacion(trigger_LAT.getNew());
        LAT_MX_OnTrade_Account.setAttendingExecutive(trigger_LAT.getNew(),accountsById);
        LAT_MX_OnTrade_Account.shareAccountWithAttendingKam(trigger_LAT.getNew(), latAccountOldMap,accountsById);
        LAT_MX_OnTrade_Account.FieldMissingDocumentsOnTradeNewAccount(trigger_LAT.getNew(), oldMap);
        for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT.getNew()) {
            system.debug('kambeforefinish: +++' + lata.LAT_MX_AttendingKAM__c);
        }
    }
           
    if (!trigger_LAT_AR.getNew().IsEmpty()) {
        latAccountOldMap = new Map<Id, LAT_ACCOUNT__c>(); 
        if (trigger.isUpdate){
            for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_AR.getOld()){
                latAccountOldMap.put(lata.Id, lata);
            }
        }        
        // Load account ids and create a map by owner (need to load as the parent record field values are empty in tgr context)
        Set<Id> accIds = new Set<Id>();
        for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_AR.getNew()){
            accIds.add(lata.LAT_AccountId__c);
        }
        // Load accounts by Id to use in the child objs
        Map<Id, Account> accountsById = new Map<Id, Account>
                ([SELECT Id, OwnerId, RecordType.DeveloperName, Owner.Profile.Name, Owner.C_digo_JDE__c FROM Account WHERE Id In :accIds]);
        Map<Id, UDC__c> udcById = new Map<Id, UDC__c>
            ([SELECT Id, CodDefUsuario__c, CodProd__c, CodUs__c FROM UDC__c WHERE CodProd__c='01' AND CodUs__c = '02']);
    
        for (LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_AR.getNew()) {
            system.debug('%%%%% JDE zone code antes : ' + lata.LAT_JDEZone__c);
            if (lata.LAT_JDEZoneUDC__c != null) {
                lata.LAT_JDEZone__c = udcById.get(lata.LAT_JDEZoneUDC__c).CodDefUsuario__c;
            } else {
                lata.LAT_JDEZone__c = accountsById.get(lata.LAT_AccountId__c).Owner.C_digo_JDE__c;
            }
            system.debug('%%%%% JDE zone code después : ' + lata.LAT_JDEZone__c);
        }
    }

    if (!trigger_LAT_BR.getNew().IsEmpty()) {
        Set<Id> accIds = new Set<Id>();
        for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_BR.getNew()){
            accIds.add(lata.LAT_AccountId__c);
        }
        Map<Id, Account> accountsById = new Map<Id, Account>
                ([SELECT Id, OwnerId, RecordType.DeveloperName, Owner.Profile.Name, Owner.C_digo_JDE__c FROM Account WHERE Id In :accIds]);
        Map<Id, UDC__c> udcById = new Map<Id, UDC__c>
            ([SELECT Id, CodDefUsuario__c, CodProd__c, CodUs__c FROM UDC__c WHERE CodProd__c='01' AND CodUs__c = '02']);
    
        for (LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_BR.getNew()) {
            system.debug('%%%%% JDE zone code antes : ' + lata.LAT_JDEZone__c);
            if (lata.LAT_UDCZonaVendedor__c != null) {
                lata.LAT_JDEZone__c = udcById.get(lata.LAT_UDCZonaVendedor__c).CodDefUsuario__c;
            } else {
                lata.LAT_JDEZone__c = accountsById.get(lata.LAT_AccountId__c).Owner.C_digo_JDE__c;
            }
            system.debug('%%%%% JDE zone code después : ' + lata.LAT_JDEZone__c);
        }
    }
}