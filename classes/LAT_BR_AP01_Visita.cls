/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto Visitas
*******************************************************************************/

public with sharing class LAT_BR_AP01_Visita {
    
    /*********************************************************************************************************
    * Nombre del metodo: fieldsCreater
    * Descripcion: fills a lookup in visita to Client Work Hours and Name
    * Desarrollador: Denis Aranda
    * Fecha Creado: 11/10/2013
    * Fecha Modificado: 21/03/2013
    * Ultima Modificacion por: Denis Aranda
    * Modo: before insert, before update
    ********************************************************************************************************/
    public static void fieldsCreater(List<Visitas__c> triggerNew){
        List<id> listIdAcc = new List<id>();
        Set<Id> idOfPlan = new Set<Id>();
        
        for(Visitas__c vis: triggerNew){
            listIdAcc.add(vis.Conta__c);
            idOfPlan.add(vis.Planejamento__c);
        }
        
        Map<Id, LAT_CWH_ClientWorkHour__c> mapAccIdCWH = new Map<Id, LAT_CWH_ClientWorkHour__c>();
        for(LAT_CWH_ClientWorkHour__c listCWH: [SELECT id, Name, Account__c, Account__r.Name, AccountId__c FROM LAT_CWH_ClientWorkHour__c WHERE Account__c IN: listIdAcc ]){
            mapAccIdCWH.put(listCWH.Account__c, listCWH);
        }
        
        Map<Id, Planejamento__c> mapVisIdToDate = new Map<Id, Planejamento__c>([SELECT Id, Name, LAT_MonthYear__c FROM Planejamento__c WHERE Id IN: idOfPlan]);
        for(Visitas__c vis: triggerNew){
            if(mapAccIdCWH.containsKey(vis.Conta__c)){
                vis.Client_Work_Hour__c = mapAccIdCWH.get(vis.Conta__c).Id;
            }
            if(trigger.isInsert || trigger.isUpdate){//triggerNew.isInsert 
                if(mapVisIdToDate.containsKey(vis.Planejamento__c)){
                    if(mapAccIdCWH.containsKey(vis.Conta__c)){
                        Date theDate = mapVisIdToDate.get(vis.Planejamento__c).LAT_MonthYear__c;
                        String theMonth = String.valueOf(theDate.month()).length() == 1?'0'+String.valueOf(theDate.month()):String.valueOf(theDate.month());
                        Integer theYear = theDate.year();
                        vis.Name = theMonth + theYear +'-'+ mapAccIdCWH.get(vis.Conta__c).Account__r.Name;
                    }
                }
            }
        }
    } 
    public static void updateEvent(List<Visitas__c> triggerNew, Map<Id,Visitas__c> oldMap){
        List <Id> listVis = new  List <Id>();
        Set <Id> planId = new Set <Id>();
        Set <Id> accId = new Set <Id>();

        for(Visitas__c vis: triggerNew){
            listVis.add(vis.id);
            planId.add(vis.Planejamento__c);
            accId.add(vis.Conta__c);
        }
        Map<id, Planejamento__c> mapIdPlan = new Map<id, Planejamento__c>([SELECT Id, Name, OwnerId FROM Planejamento__c WHERE id IN: planId]);
        Map<id, Account> mapIdAcc = new Map<id, Account>([SELECT Id, Name, OwnerId FROM Account WHERE id IN: accId]);
        List <Event> eventList = [SELECT WhatId FROM Event WHERE WhatID in: listVis];

        Map <String, Event> eventMap = new Map <String, Event>();
        for(Event eve: eventList){
            eventMap.put(eve.WhatId,eve);
        }

        List<Event> eventToUpdate = new List<Event>();
        Id rtCheckIn = Global_RecordTypeCache.getRtId('Visitas__c'+'LAT_MX_CheckIn');
        for(Visitas__c vis: triggerNew){
            Event eveToUpdate = eventMap.get(vis.id);
            if (eveToUpdate != null) {
                String ldate = String.valueOf( System.today() );
                Datetime ltime = ( vis.Data_da_Visita__c == null || vis.Hora_da_Visita__c == null) 
                                    ? system.now()//datetime.valueof(string.valueof(ldate+' '+ '10:00:00')) 
                                    : datetime.valueof(string.valueof(vis.Data_da_Visita__c) + ' ' + vis.Hora_da_Visita__c+ ':00');
                eveToUpdate.ActivityDatetime = ltime;
                eveToUpdate.Description  = vis.Resumo_da_Visita__c;
                if(vis.RecordTypeId != rtCheckIn){
                    eveToUpdate.Subject = mapIdAcc.get(vis.Conta__c) != null ? 'Visita a cliente - ' + mapIdAcc.get(vis.Conta__c).Name : 'Visita a cliente - '; 
                }else{
                    eveToUpdate.Subject = mapIdAcc.get(vis.Conta__c) != null ? mapIdAcc.get(vis.Conta__c).Name : 'Visita a cliente';
                }
                
                eveToUpdate.OwnerId = mapIdPlan.get(vis.Planejamento__c).OwnerId;
                eventToUpdate.add(eveToUpdate);
            }
        }

        if (!eventToUpdate.isEmpty()) { 
            update eventToUpdate;
        }
    }    
    /*TEST CODE IN LAT_BR_AP01_Visita_TEST CLASS*/
    
    /*********************************************************************************************************
    * Nombre del metodo: updatesPPCKey
    * Descripcion: Method that calls the method that updates the field Produto_Concorr_ncia__c.LAT_Key__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 07/05/2013
    * Modo: after update
    ********************************************************************************************************/
    public static void updatesPPCKey(List<Visitas__c> triggerNew, Map<Id,Visitas__c> oldMap){
        
        Set<Id> setIds = new Set<Id>();
        for(Visitas__c vis: triggerNew){
            if(vis.RecordTypeId != oldMap.get(vis.Id).RecordTypeId || vis.Conta__c != oldMap.get(vis.Id).Conta__c){
                setIds.add(vis.Id);           
            }
        }
        Map<Id,Produto_Concorr_ncia__c> mapPPC = new Map<Id,Produto_Concorr_ncia__c>([SELECT Id FROM Produto_Concorr_ncia__c WHERE Checklist_de_Visita__r.Visita__c IN: setIds AND Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c = true]);
        
        if(!mapPPC.isEmpty()){
            LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(mapPPC.keySet());     
        }
        
    }

    public static void sendTAAIfClosed(List<Visitas__c> triggerNew, Map<Id,Visitas__c> oldMap) {

        List<Id> visIds = new List<Id>();
        for(Visitas__c vis: triggerNew){
            if(vis.Status__c == 'Encerrada' && oldMap.get(vis.id).Status__c != 'Encerrada'){
                visIds.add(vis.Id);           
            }
        }

        List<LAT_BR_TAA__c> taaList = [SELECT Visit__c, PRBObjectives__c, LastVisit__c, External_Id__c, 
                                              Date__c, CurrentVisit__c, Contact__c, ClientObjectives__c, 
                                              ClientCorporateName__c, ClientAN8__c, DoNotSendEmail__c
                                        FROM LAT_BR_TAA__c WHERE Visit__c IN: visIds];
        
        if(!taaList.isEmpty()){
            LAT_BR_TAAActions.TAAsendConfirmationEmail(taaList);     
        }

    }

}