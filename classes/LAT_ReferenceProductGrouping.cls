public class LAT_ReferenceProductGrouping {
	
	public static void setExternalId(List<LAT_ReferenceProductGrouping__c> rpgList){
		
		for(LAT_ReferenceProductGrouping__c rpg : rpgList){
			RecordType rt = [SELECT id, Name, Developername from RecordType where id =: rpg.RecordTypeId];
			if (rpg.Country__c == null || rpg.Country__c == '1') {
				rpg.ExternalId__c = '1-' + rpg.Name + '-' + rt.Name;
			} else {
				rpg.ExternalId__c = rpg.Country__c + '-' + rpg.Name + '-' + rt.Name;
			}
		}
		
	}


}