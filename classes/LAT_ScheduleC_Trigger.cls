public with sharing class LAT_ScheduleC_Trigger {
	public LAT_ScheduleC_Trigger() {
		
	}

	public static void validateScheduleObject(map<Id,LAT_ScheduleC__c> beforeMap, map<Id,LAT_ScheduleC__c> newMap ) {
		Set<String> productCountries = LAT_GeneralConfigDao.getValueAsStringSet('PROD_BRAND_OVERRIDE', ',', true);

		for (LAT_ScheduleC__c sch :  newMap.values() ) {
			String country = (sch.ExternalId__c == null) ? '' : sch.ExternalId__c.substring(0, sch.ExternalId__c.indexof('-') + 1);
			if (!sch.LAT_IsAdmin__c && productCountries.contains(country)) {
				sch.KeyBrand__c = beforeMap.get(sch.id).KeyBrand__c;
			}
			sch.LAT_IsAdmin__c = false;
		}
	}


}