/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Contact
*******************************************************************************/

public with sharing class LAT_MX_AP01_Contact{

       
    /*****************************************************************************************
    * Nombre del metodo: updatesInformationUnfilled
    * Descripcion: Actualiza los Account On Trade para actualizar el campo Information Unfilled si es insert o cambia el lookup
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/09/2013
    * Modo: after insert, after update, after delete
    *****************************************************************************************/
    
    public static void updatesInformationUnfilled(List<Contact> triggerNew,map<Id,Contact> oldMap){  
        
        Set<Id> setAccountUpdate = new Set<Id>();
        
        if(trigger.isInsert || trigger.isUpdate){
            for(Contact con: triggerNew){
                if(trigger.isInsert){
                    setAccountUpdate.add(con.AccountId);
                }
                if(trigger.isUpdate && (oldMap.containsKey(con.Id) && con.AccountId != oldMap.get(con.Id).AccountId)){
                    setAccountUpdate.add(con.AccountId);
                    setAccountUpdate.add(oldMap.get(con.Id).AccountId);
                }
            }           
        }else{
            for(Id conId: oldMap.keySet()){
                setAccountUpdate.add(oldMap.get(conId).AccountId);
            }      
        }
        
        if(!setAccountUpdate.isEmpty()){
            List<Account> listAccountUpdate = [SELECT Id FROM Account WHERE Id IN: setAccountUpdate AND RecordTypeId =: Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OnTrade')];
            if(!listAccountUpdate.isEmpty()){
                update listAccountUpdate;
            }
        }

    }

    public static void copyDescriptionToCaracteristicas(List<Contact> triggerNew){

        for(Contact c :triggerNew){
        
            c.LAT_MX_Carateristicas__c = c.Description.abbreviate(255);
        }
    }

}