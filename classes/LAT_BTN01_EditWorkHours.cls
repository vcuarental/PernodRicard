global class LAT_BTN01_EditWorkHours {
	
	webservice static string editHours(string IdAccount){
		
		Account acc = [Select Id, Name, LAT_Account__r.LAT_ClientWorkHour__c FROM Account WHERE id =:idAccount ];
		string cWHId = acc.LAT_Account__r.LAT_ClientWorkHour__c;
		return cWHId;
	}
}