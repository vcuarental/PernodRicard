/**********************************************************************************
*                           Company: ValueNet
*----------------------------------------------------------------------------------
*   Clase que distribuye los registros por pais del objeto Gabarito_de_Execucao__c
***********************************************************************************/

public with sharing class LAT_CTR_GabaritodeExecucao {
	
	/*ALL TRIGGERS*/
	public static void runTriggers(){
	    LAT_Trigger trigger_BR = new LAT_Trigger('Gabarito_de_Execucao__c', new set<String>{'BRA_Standard','LAT_BR_GDE_On_Trade'});
	    triggersBR(trigger_BR);
	}
	
	/*TRIGGERS BR*/
	private static void triggersBR(LAT_Trigger trigger_BR){
		//Before
		if(trigger.isBefore){
			LAT_BR_AP01_GabaritodeExecucao.validateMenuSection(trigger_BR.getNew());
	    	if(trigger.isInsert){
	    		if(!trigger_BR.getNew().IsEmpty()){
		            LAT_BR_AP01_GabaritodeExecucao.validateOnlyOneGabarito(trigger_BR.getNew());
		        }
		    }
	    }
	    //After
	    if(trigger.isAfter){
	    	if(trigger.isInsert){
	    		LAT_BR_AP01_GabaritodeExecucao.lastGabaritoValidoInsUpd(trigger_BR.getNew());
	    	}
	    	if(trigger.isUpdate){
	    		LAT_BR_AP01_GabaritodeExecucao.lastGabaritoValidoInsUpd(trigger_BR.getNew());
	    	}
	    	if(trigger.isDelete){
	    		LAT_BR_AP01_GabaritodeExecucao.lastGabaritoValidoDel(trigger_BR.getOld());
	    	}
	    }
	}
	
}