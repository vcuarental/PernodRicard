/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Client Work Hour
*******************************************************************************/

public with sharing class LAT_BR_AP01_ClientWorkHours {

    public static set<Id> accountsInInterface;
       
    /*****************************************************************************************
    * Nombre del metodo: clientWorkHourDaysMissingUpdate
    * Descripcion: Updates Account when Orders Days change
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/02/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    
    public static void clientWorkHourDaysMissingUpdate (List<LAT_CWH_ClientWorkHour__c> triggerNew, map<Id,LAT_CWH_ClientWorkHour__c> oldMap){              
        
        List<Account> listAccountUpdate = new List<Account>();
        for(LAT_CWH_ClientWorkHour__c cwh: triggerNew){
            if(oldMap == null || (cwh.Monday_order__c != oldMap.get(cwh.Id).Monday_order__c || cwh.Tuesday_order__c != oldMap.get(cwh.Id).Tuesday_order__c || cwh.Wednesday_Order__c != oldMap.get(cwh.Id).Wednesday_Order__c || cwh.Thursday_Order__c != oldMap.get(cwh.Id).Thursday_Order__c || cwh.Friday_order__c != oldMap.get(cwh.Id).Friday_order__c || cwh.Saturday_order__c != oldMap.get(cwh.Id).Saturday_order__c || cwh.Sunday_Order__c != oldMap.get(cwh.Id).Sunday_Order__c)){
                listAccountUpdate.add(new Account(Id = cwh.Account__c));
            }
        }
        try{
            update listAccountUpdate;
        }catch (DMLException e){
            for(LAT_CWH_ClientWorkHour__c cwh: triggerNew){
                cwh.addError('No se puede actualizar el campo Informaciones Faltantes del cliente.');
            }  
        }          
    }
}