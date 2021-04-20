trigger LAT_SalesAcademyTrigger on LAT_SalesAcademy__c (before insert) {

	if(Trigger.isInsert){
		if(Trigger.isBefore){
			LAT_SalesAcademy.setRecordType(Trigger.new);
		}


	}
}