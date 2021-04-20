/*
* LAT_MecanicaTrigger
* Author: Martin Prado (martin@zimmic.com)
* Date: 07/04/2017
*/
trigger LAT_MecanicaTrigger on LAT_Mecanica__c (before insert, before update, after insert, after update) {


	if(trigger.isAfter){

		// We must have only one selected by default on mechanic per AP
		Set<Id> mechIds = new Set<Id>();
		Set<Id> ap = new Set<Id>();

		for(LAT_Mecanica__c mech : trigger.new) {
			system.debug(mech);
			system.debug(mech.LAT_Default__c);
			if(mech.LAT_Default__c == true) {
				mechIds.add(mech.Id);
				ap.add(mech.LAT_PromotionalAction__c);
			}
		}
		List<LAT_Mecanica__c> currentMech = [Select Name, Id, LAT_PromotionalAction__c from LAT_Mecanica__c where LAT_PromotionalAction__c IN:ap AND  Id NOT IN:mechIds ];
		for(LAT_Mecanica__c mech : currentMech) {
			mech.LAT_Default__c = false;
		}
		if(currentMech.size() >0 ){
			update currentMech;
		}
	}
	else if(trigger.isBefore){

		// By default if we dont have any default, we set the last as default
		Set<Id> promotionalActions = new Set<Id>();
		
		for(LAT_Mecanica__c mech : trigger.new) {
			promotionalActions.add(mech.LAT_PromotionalAction__c);
		}
		List<LAT_Mecanica__c> currentMech = [Select Name, Id, LAT_PromotionalAction__c from LAT_Mecanica__c where LAT_Default__c = true and LAT_PromotionalAction__c  IN:promotionalActions ];
		List<LAT_Mecanica__c> toUpdate = new List<LAT_Mecanica__c>();
		if(currentMech.size() == 0) {
			for(LAT_Mecanica__c mech : trigger.new) {
				mech.LAT_Default__c = true;
			}
		}

	}
}