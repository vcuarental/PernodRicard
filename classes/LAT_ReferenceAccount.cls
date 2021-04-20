public class LAT_ReferenceAccount {

	// Assigns the related account name to the Reference Account obj
	public static void AssignAccountName (List<LAT_ReferenceAccount__c> raList) {
		for (LAT_ReferenceAccount__c ra: raList) {
			if (ra.AccountName__c != null) {
				ra.Name = ra.AccountName__c;
			}
		}
	}
	public static void UniqueAccount (List<LAT_ReferenceAccount__c> raList, Map<id, LAT_ReferenceAccount__c> oldMap, Boolean isUpdate) {
		Set<String> accIdList = new Set<String>();
		List<LAT_ReferenceAccount__c> rfList =[SELECT id, externalId__c, RecordTypeId, Account__c
                FROM LAT_ReferenceAccount__c];

	    for(LAT_ReferenceAccount__c rfSet: rfList){
			     accIdList.add(rfSet.Account__c);
	    }

	    for(LAT_ReferenceAccount__c objRf: raList){
	    	if(accIdList.contains(objRf.Account__c)
	    	   && (!isUpdate || (isUpdate && objRf.Account__c != oldMap.get(objRf.id).Account__c))){
           for(LAT_ReferenceAccount__c rfSet: rfList){
              if(objRf.Account__c == rfSet.Account__c && objRf.RecordTypeId == rfSet.RecordTypeId){
                objRf.addError(Label.LAT_DuplicateReferenceAccount);
              }
     	     }

	    	}
	    }
	}
	public static void AssignValues(List<LAT_ReferenceAccount__c> raList){
		for(LAT_ReferenceAccount__c ra : raList){
			ra.externalId__c = '1-'+ra.RecordTypeId+'-'+ra.AN8__c;

		}
}
}