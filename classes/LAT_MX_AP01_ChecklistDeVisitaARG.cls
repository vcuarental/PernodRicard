/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto CLV_ChecklistVisita_ARG__c
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_ChecklistDeVisitaARG{
       
    /*****************************************************************************************
    * Nombre del metodo: updatesChecklistName
    * Descripcion: Method that updates the field LAT_MX_ChecklistName__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 28/10/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    
    public static void updatesChecklistName (List<CLV_ChecklistVisita_ARG__c> triggerNew){
    
        //este query se realiza porque se necesita la traduccion del campo Name del RecordType
        Map<Id,RecordType> mapRt = new Map<Id,RecordType>([SELECT Id, DeveloperName,tolabel(Recordtype.Name) FROM RecordType WHERE SobjectType = 'CLV_ChecklistVisita_ARG__c']);

        for(CLV_ChecklistVisita_ARG__c check: triggerNew){
            check.LAT_MX_ChecklistName__c = mapRt.get(check.RecordTypeId).Name;
        }
    
    }
    
    /***************************************************************************************************************************
    * Nombre del metodo: deleteValidation
    * Descripcion: Metodo que prohibe borrar Checklist, si el Planeamiento de Visitas tiene Status_do_Planejamento__c = 'Approved'
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 18/02/2014
    * Modo: Before delete
    ****************************************************************************************************************************/
    public static void deleteValidation (List<CLV_ChecklistVisita_ARG__c> triggerOld){

        Id IdProfileUser = userinfo.getProfileid();
                
        if(IdProfileUser != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            IdProfileUser != LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_System Administrator')&& 
            IdProfileUser != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator')){
                
            Set<Id> setVisitas = new Set<Id>();
            for(CLV_ChecklistVisita_ARG__c check: triggerOld){
                setVisitas.add(check.Visit_AR__c);
            }  
            
            Map<Id,Visitas__c> mapVisitas = new Map<Id,Visitas__c>([SELECT Id, Planejamento__r.Status_do_Planejamento__c FROM Visitas__c WHERE Id IN: setVisitas AND Planejamento__r.Status_do_Planejamento__c = 'Approved']);                  

            for(CLV_ChecklistVisita_ARG__c check: triggerOld){
                if(mapVisitas.containsKey(check.Visit_AR__c)){
                    check.addError(label.LAT_MX_AP01_00024);
                    //LAT_MX_AP01_00024: No se pueden eliminar Checklists de Planeamiento ya aprobados.
                }
            }          
        
        }
         
    } 
    
}