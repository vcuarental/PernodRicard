//LAT_OpportunityLineItem__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public with sharing class LAT_OportunidadeVerificaCotaExistente {
	
	public static void execute(){
		
	    //Check if this trigger is bypassed by SESAME (data migration Brazil)
	    if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
	    
	        if(trigger.isDelete){
	            LAT_Cota.deleteOpportunityLine(LAT_OpportunityLineItemTriggerHandler.triggerOld);
	        
	        }
	    }	
	}


}