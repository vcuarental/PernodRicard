//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_Case_AfterInsert {
	public static void execute(){
		System.debug('%%%%%%%  entro ');
		List<LAT_Case__c> toReview = [SELECT Name, LAT_IsAdmin__c, LAT_CaseNumber__c FROM LAT_Case__c 
										WHERE Id in :LAT_CaseTriggerHandler.mapNew.keySet()];
		List<LAT_Case__c> toUpdate = new List<LAT_Case__c>();
      	
		for( LAT_Case__c c : toReview ){
			
				c.Name = c.LAT_CaseNumber__c;
				toUpdate.add(c); 
			
		}
		update toUpdate;
	}
}