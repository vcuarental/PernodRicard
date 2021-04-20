//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_LATCase_Before {
	
	public static void execute(){
		
	    //Filtrado de RecordTypes
	    LAT_Trigger trigger_MX = new LAT_Trigger('LAT_Case__c', new set<String>{'LAT_MX_CSE_AccountAlterationStatistical','LAT_MX_CSE_AccountAlterationCreditAndCollections','LAT_MX_CSE_AccountAlterationLegal','LAT_MX_CSE_AccountAlterationLogistics','LAT_MX_CSE_CaseClosed'});


	    //Ejecucion de metodos especificos para MX
	    if(!trigger_MX.getNew().IsEmpty()){
	        LAT_MX_AP01_Case.UpdatesCaseFields((List<LAT_Case__c>)trigger_MX.getNew());
	        LAT_MX_AP01_Case.UpdateAccountOwnerAndManagerOwner((List<LAT_Case__c>)trigger_MX.getNew());
	    }
	}

}