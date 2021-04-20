trigger LAT_MX_UpdateRFC on LAT_MX_RFC__c (before insert, before update) {
	LAT_MX_MetodosRFC.ValidationRFC(Trigger.new);
	LAT_MX_MetodosRFC.ValidationCNPJduplicate(Trigger.new);
}