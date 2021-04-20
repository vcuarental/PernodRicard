/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Attachment
*******************************************************************************/

public with sharing class LAT_BR_AP01_Attachment{
       
    /*****************************************************************************************
    * Nombre del metodo: updateHasAttachment
    * Descripcion: Metodo que actualiza el campo LAT_BR_HasAttachment__c de la Visita a true si 
    *              esta tiene aunque sea un attachment, y a false si no tiene ninguno 
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 25/03/2014
    * Modo: after insert, after delete
    *****************************************************************************************/
    
    public static void updateHasAttachment (list<Attachment> triggerNewOrOLD){
    
        Set<Id> setAttachParentInsert = new Set<Id>(); 
        if(trigger.isInsert){
            for(Attachment attach: triggerNewOrOLD){
                setAttachParentInsert.add(attach.ParentId);
            }
        }
        
        Set<Id> setAttachParentDelete = new Set<Id>();
        if(trigger.isDelete){
            for(Attachment attach: triggerNewOrOLD){
                setAttachParentDelete.add(attach.ParentId);
            }
        }   
        
        List<Visitas__c> listVisitas = new List<Visitas__c>();     
        
        if(!setAttachParentInsert.isEmpty()){
            listVisitas = [SELECT Id, LAT_BR_HasAttachment__c FROM Visitas__c WHERE LAT_BR_HasAttachment__c = false AND Id IN: setAttachParentInsert];
            for(Visitas__c visita: listVisitas){
                visita.LAT_BR_HasAttachment__c = true;
                visita.LAT_isTrigger__c = true;
            }           
        }
        
        if(!setAttachParentDelete.isEmpty()){
            List<Attachment> listAttach = [SELECT Id, ParentId FROM Attachment WHERE ParentId IN: setAttachParentDelete];
            Set<Id> setVisitHasAttach = new Set<Id>();
            for(Attachment attach: listAttach){
                setVisitHasAttach.add(attach.ParentId);
            }
            listVisitas = [SELECT Id, LAT_BR_HasAttachment__c FROM Visitas__c WHERE Id IN: setAttachParentDelete];
            for(Visitas__c visita: listVisitas){
                if(!setVisitHasAttach.contains(visita.Id)){
                    visita.LAT_BR_HasAttachment__c = false;
                }
            }
        }
        
        if(!listVisitas.isEmpty()){
            try{update listVisitas;}catch(DMLException e){}
        }
    }
}