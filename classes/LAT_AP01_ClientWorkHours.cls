/*******************************************************************************
*                           Company: ValueNet                                  *
*------------------------------------------------------------------------------*
*   Clase que contiene los triggers del objeto ClienteWorkHours                *
*******************************************************************************/

public with sharing class LAT_AP01_ClientWorkHours {
	
	/*********************************************************************************************************
    * Nombre del metodo: relatesCWHToLATAccount                     		Pais: LAT
    * Descripcion: Updates LAT_Account__c to relate it with LAT_CWH_ClientWorkHour__c  
    * Desarrollador: Denis Aranda
    * Fecha: 23/10/2013
    * Modo: After Insert
    *********************************************************************************************************/
	public static void relatesCWHToLATAccount(List<LAT_CWH_ClientWorkHour__c> triggerNew){

		List<LAT_ACCOUNT__c> listUpdateLATacc = new List <LAT_ACCOUNT__c>();
		for(LAT_CWH_ClientWorkHour__c cwh: triggerNew){
			listUpdateLATacc.add(new LAT_ACCOUNT__c(Id = cwh.LATACCOUNT__c, LAT_ClientWorkHour__c = cwh.Id));
		}
		system.debug('Token listUpdateLATacc:' + listUpdateLATacc);
		update listUpdateLATacc;	
    }
    /*TEST CODE IN LAT_AP01_ClientWorkHours_TEST CLASS*/
}