/*************************************************************************************
*                                 Company: ValueNet 
*-------------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto LAT_BR_TPL_TerritoryPlanning__c
*************************************************************************************/
public with sharing class LAT_AP01_TerritoryPlanning {
	
	/*****************************************************************************************
    * Nombre del metodo: noDuplicateTerritoryPlanning
    * Descripcion: Verifies that no duplicate Territory Planning for each Planejamiento
    * Desarrollador: Denis Aranda
    * Fecha: 19/03/2014
    * Modo: Before Insert
    *****************************************************************************************/
    public static void noDuplicateTerritoryPlanning(List<LAT_BR_TPL_TerritoryPlanning__c> triggerNew){
    	
    	Set<Id> setPlanId = new Set<Id>();
    	Map<String, LAT_BR_TPL_TerritoryPlanning__c> mapToCheckDuplicates = new Map<String, LAT_BR_TPL_TerritoryPlanning__c>(); 
    	for(LAT_BR_TPL_TerritoryPlanning__c ter: triggerNew){
    		setPlanId.add(ter.LAT_BR_VisitPlanning__c);
    		String key = ter.LAT_BR_VisitPlanning__c +'-'+ ter.LAT_BR_TerritoryPlanning__c;
    		if(!mapToCheckDuplicates.containsKey(key)){
    			mapToCheckDuplicates.put(key, ter);
    		}else{
    			ter.addError( Label.LAT_AP01_TPL_01 + ' ' + Label.LAT_AP01_TPL_02 + ' "' + ter.LAT_BR_TerritoryPlanning__c + '"');
    			//Custom Label LAT_AP01_TPL_01 = "Planejamento de Visita"
    			//Custom Label LAT_AP01_TPL_02 = "can only contain one Territory planning with "
    		}
    	}
    	
		for(LAT_BR_TPL_TerritoryPlanning__c ter: [SELECT Id, Name, LAT_BR_TerritoryPlanning__c, LAT_BR_VisitPlanning__c, LAT_BR_VisitPlanning__r.Name FROM LAT_BR_TPL_TerritoryPlanning__c WHERE LAT_BR_VisitPlanning__c IN: setPlanId]){
			String key = ter.LAT_BR_VisitPlanning__c +'-'+ ter.LAT_BR_TerritoryPlanning__c;
			mapToCheckDuplicates.put(key, ter);
		}
		if(!mapToCheckDuplicates.isEmpty()){
			for(LAT_BR_TPL_TerritoryPlanning__c ter: triggerNew){
				String key = ter.LAT_BR_VisitPlanning__c +'-'+ ter.LAT_BR_TerritoryPlanning__c;
				if(mapToCheckDuplicates.containsKey(key) && ter.Id != mapToCheckDuplicates.get(key).Id){
					ter.addError(Label.LAT_AP01_TPL_01 + ' "' + mapToCheckDuplicates.get(key).LAT_BR_VisitPlanning__r.Name + '" ' + Label.LAT_AP01_TPL_02 + ' "' + ter.LAT_BR_TerritoryPlanning__c + '"');
					//Custom Label LAT_AP01_TPL_01 = "Planejamento de Visita"
    				//Custom Label LAT_AP01_TPL_02 = "can only contain one Territory planning with "
				}
			}
    	}
    }
}