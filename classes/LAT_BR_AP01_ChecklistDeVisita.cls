/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto Checklist de Visitas
*******************************************************************************/

public with sharing class LAT_BR_AP01_ChecklistDeVisita{

    /*********************************************************************************************************
    * Nombre del metodo: updatesPPCKey
    * Descripcion: Method that calls the method that updates the field Produto_Concorr_ncia__c.LAT_Key__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 07/05/2013
    * Modo: after update
    ********************************************************************************************************/
    public static void updatesPPCKey(List<Checklist_de_visita__c> triggerNew, Map<Id,Checklist_de_visita__c> oldMap){
        
        Set<Id> setIds = new Set<Id>();
        for(Checklist_de_visita__c check: triggerNew){
            if(check.LAT_BR_ValidOnTradeChecklist__c != oldMap.get(check.Id).LAT_BR_ValidOnTradeChecklist__c){
                setIds.add(check.Id); 
            }
        }
        
        Map<Id,Produto_Concorr_ncia__c> mapPPC = new Map<Id,Produto_Concorr_ncia__c>([SELECT Id FROM Produto_Concorr_ncia__c WHERE Checklist_de_Visita__c IN: setIds]);
        
        if(!mapPPC.isEmpty()){
            LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(mapPPC.keySet());     
        }        
    }    
}