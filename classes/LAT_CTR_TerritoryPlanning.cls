/********************************************************************************************
*                                  Company: ValueNet
*--------------------------------------------------------------------------------------------
*   Clase que distribuye los registros por pais del objeto LAT_BR_TPL_TerritoryPlanning__c
********************************************************************************************/

public with sharing class LAT_CTR_TerritoryPlanning {
	
	/*ALL TRIGGERS*/
	public static void runTriggers(){
	    LAT_Trigger trigger_BR = new LAT_Trigger('LAT_BR_TPL_TerritoryPlanning__c', new set<String>{'LAT_BR_TPL_Standard'});
	    triggersBR(trigger_BR);
	}
	
	/*TRIGGERS BR*/
	private static void triggersBR(LAT_Trigger trigger_BR){
		//Before
		if(trigger.isBefore){
	    	if(trigger.isInsert){
	    		if(!trigger_BR.getNew().IsEmpty()){
                    LAT_AP01_TerritoryPlanning.noDuplicateTerritoryPlanning(trigger_BR.getNew());
                }
	    	}
	    	if(trigger.isUpdate){
	    		if(!trigger_BR.getNew().IsEmpty()){
                    LAT_AP01_TerritoryPlanning.noDuplicateTerritoryPlanning(trigger_BR.getNew());
                }
	    	}
	    	if(trigger.isDelete){
	    	}
	    }
	    //After
	    if(trigger.isAfter){
	    	if(trigger.isInsert){
	    	}
	    	if(trigger.isUpdate){
	    	}
	    	if(trigger.isDelete){
	    	}
	    }
	}
}