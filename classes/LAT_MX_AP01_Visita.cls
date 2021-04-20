/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Visitas__c
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_Visita{
       
    /*****************************************************************************************
    * Nombre del metodo: TypeMxValidation
    * Descripcion: Metodo que valida el campo LAT_MX_Type__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 15/10/2013
    * Modo: Before Insert, Before Update
    *****************************************************************************************/
    public static void TypeMxValidation (List<Visitas__c> triggerNew, Map<Id, Visitas__c> OldMap){
 
        Id IdProfileUser = userinfo.getProfileid();
        Boolean ContainsCollections;
        
        Id AdminProfileId;
        if(!Utils.wasMigrationDone('12')) { 
            AdminProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Creditos y Cobranzas');
        }
        //MIGRATED 05/12/2016
        else {
            AdminProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_CreditosyCobranzas');    
        }
        for(Visitas__c visita: triggerNew){
            ContainsCollections = false;
            if(OldMap == null || (OldMap.containsKey(visita.Id) && visita.LAT_MX_Type__c != OldMap.get(visita.Id).LAT_MX_Type__c)){
                if(IdProfileUser == AdminProfileId){
                    String[] Values = visita.LAT_MX_Type__c.split(';');
                    for(String s : Values){
                        if(s == 'Collections'){
                            ContainsCollections = true;
                        } else {
                            visita.LAT_MX_Type__c.addError(label.LAT_MX_AP01_00013);
                            //LAT_MX_AP01_00013: Usuarios con perfil Creditos y Cobranzas solo podran seleccionar el valor 'Cobranza'.
                        }
                    }
                    if (!ContainsCollections){
                        visita.LAT_MX_Type__c.addError(label.LAT_MX_AP01_00013);
                        //LAT_MX_AP01_00013: Usuarios con perfil Creditos y Cobranzas solo podran seleccionar el valor 'Cobranza'.
                    }
                }
            }
        }                            
    } 
    
    /*****************************************************************************************
    * Nombre del metodo: completesVisitNameAndChannel
    * Descripcion: Metodo que eveleta el campo Name y LAT_MX_ClienteChannel__c de la visita
    * Desarrollador: Denis Aranda
    * Fecha: 28/10/2013
    * Modo: Before Insert, Before Update
    *****************************************************************************************/
    public static void completesVisitNameAndChannel (List<Visitas__c> triggerNew){
        
        
        set<id> setIdsPlane = new Set<id>();
        set<id> setIdsAcc = new Set<id>();
        for(Visitas__c visit:triggerNew){
            if(visit.Conta__c != null){
                setIdsAcc.add(visit.Conta__c);
            }
            if(visit.Planejamento__c != null){
                setIdsPlane.add(visit.Planejamento__c);
            }
        }
        
        map<Id, Planejamento__c> mapIdPlane = new map<Id, Planejamento__c>([SELECT Id, M_s_de_Ref_rencia__c, Ano_de_Referencia__c, Owner.FirstName, Owner.LastName, Owner.Alias FROM  Planejamento__c WHERE id IN : setIdsPlane]);
        map<Id, Account> mapIdAcc= new map<Id, Account>([SELECT Id, Name, Client_code_AN8__c, Channel__c, LAT_MX_CRMClientCode__c, RecordTypeId FROM  Account WHERE id IN : setIdsAcc]);
        
        map<String, String> mapValueLabel = new map<String, String>();
        for(Schema.PicklistEntry entry: Planejamento__c.M_s_de_Ref_rencia__c.getDescribe().getPicklistValues()){
            mapValueLabel.put(entry.getValue(), entry.getLabel());
        }
        
        for(Visitas__c visit: triggerNew){
            if(visit.RecordtypeId != Global_RecordTypeCache.getRtId('Visitas__c'+'LAT_MX_CheckIn')){
                if(visit.Conta__c != null && visit.Planejamento__c != null && mapIdAcc.containsKey(visit.Conta__c) && mapIdPlane.containsKey(visit.Planejamento__c)){
                    String visName = '';
                    visName += mapValueLabel.get(mapIdPlane.get(visit.Planejamento__c).M_s_de_Ref_rencia__c);
                    visName += '/';
                    visName += mapIdPlane.get(visit.Planejamento__c).Ano_de_Referencia__c;
                    visName += mapIdAcc.get(visit.Conta__c).Client_code_AN8__c != null ? + ' - '+(mapIdAcc.get(visit.Conta__c).Client_code_AN8__c): ' - '+mapIdAcc.get(visit.Conta__c).LAT_MX_CRMClientCode__c ;
                    visName += ' - ';
                    visName += mapIdPlane.get(visit.Planejamento__c).Owner.Alias;
                    
                    if(visName.length()>80){
                        visName = visName.substring(0, 80);
                    }
                    
                    visit.Name = visName;
                    
                    if(mapIdAcc.get(visit.Conta__c).RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')){
                        visit.LAT_MX_ClienteChannel__c = 'Off Trade';
                    }
                    if(mapIdAcc.get(visit.Conta__c).RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')){
                        visit.LAT_MX_ClienteChannel__c = 'On Trade';
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: createsEventForEachVisit
    * Descripcion: Creates an event for every visit inserted.
    * Desarrollador: Denis Aranda
    * Fecha: 29/10/2013
    * Modo: After Insert
    *****************************************************************************************/
    public static void createsEventForEachVisit (List<Visitas__c> triggerNew){
        
        List<Event> listEvents = new List<Event>();
        SET<Id> planId = new SET<Id>();
        SET<Id> accId = new SET<Id>();
        
        for(Visitas__c vis: triggerNew){
            planId.add(vis.Planejamento__c);
            accId.add(vis.Conta__c);
        }
        Map<id, Planejamento__c> mapIdPlan = new Map<id, Planejamento__c>([SELECT Id, Name, OwnerId FROM Planejamento__c WHERE id IN: planId]);
        Map<id, Account> mapIdAcc = new Map<id, Account>([SELECT Id, Name, OwnerId FROM Account WHERE id IN: accId]);
        
        for(Visitas__c vis: triggerNew){
            if(!vis.Visita_n_o_realizada__c){
                String ldate = String.valueOf(System.today());
                Datetime ltime = ( vis.Data_da_Visita__c == null || vis.Hora_da_Visita__c == null) ? datetime.valueof(string.valueof(ldate+' '+ '10:00:00')) : datetime.valueof(string.valueof(vis.Data_da_Visita__c) + ' ' + vis.Hora_da_Visita__c+ ':00');
                Event eve = new Event();
                eve.RecordTypeId = Global_RecordTypeCache.getRtId('Event'+'LAT_MX_EVT_Standard');
                eve.WhatId = vis.Id;
                if(vis.Conta__c != null){
                    eve.Subject = mapIdAcc.get(vis.Conta__c).Name; 
                } else {
                    eve.Subject = vis.Name; 
                }
                //eve.Subject = 'Visita a cliente';
                /*
                if(vis.Conta__c != null){
                    eve.Subject = 'Visita a cliente - ' + mapIdAcc.get(vis.Conta__c).Name; 
                } else {
                    eve.Subject = 'Visita a cliente - ' + vis.Name; 
                }*/
                
                eve.ActivityDatetime = ltime;
                eve.DurationInMinutes = 60;
                eve.Description = vis.Resumo_da_Visita__c;
                eve.OwnerId = mapIdPlan.get(vis.Planejamento__c).OwnerId;
                listEvents.add(eve);
            }
        }
        insert listEvents;
    }
    
    /***************************************************************************************************************************
    * Nombre del metodo: deleteValidation
    * Descripcion: Metodo que prohibe borrar Visitas, si el Planeamiento de Visitas tiene Status_do_Planejamento__c = 'Approved'
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 18/02/2014
    * Modo: Before delete
    ****************************************************************************************************************************/
    public static void deleteValidation (List<Visitas__c> triggerOld){
        
        Id IdProfileUser = userinfo.getProfileid();
 
        if(IdProfileUser != LAT_GlobalProfileCache.getStandardAdminProfileId() && IdProfileUser != LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_System Administrator') && IdProfileUser != LAT_GlobalProfileCache.getProfileIdByName('LAT_System Administrator')){
        
            Set<Id> setPlanIds = new Set<Id>();
            for(Visitas__c visita: triggerOld){
                setPlanIds.add(visita.Planejamento__c);
            }                               
            
            Map<Id,Planejamento__c> mapPlans = new Map<Id,Planejamento__c>([SELECT Id, Status_do_Planejamento__c FROM Planejamento__c WHERE Id IN: setPlanIds AND Status_do_Planejamento__c = 'Approved']);
            
            for(Visitas__c visita: triggerOld){
                if(mapPlans.containsKey(visita.Planejamento__c)){
                    visita.addError(label.LAT_MX_AP01_00023);
                    //LAT_MX_AP01_00023: No se pueden eliminar Visitas de Planeamiento ya aprobados.
                }
            } 
        }         
    }
    
    /*****************************************************************************************
    * Nombre del metodo: TypesAddValidation
    * Descripcion: Metodo que evita que se quiten Types de Visitas de Planeamientos aprobados
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 19/03/2014
    * Modo: Before Update
    *****************************************************************************************/
    public static void typesAddValidation(List<Visitas__c> triggerNew, Map<Id,Visitas__c> OldMap, List<Visitas__c> triggerOld){
                
        Map<Id, Set<String>> mapIdVisitTypes = new Map<Id, Set<String>>();
        Set<Id> setIdsPlan = new Set<Id>();
             
        for(Visitas__c visita: triggerNew){
            if(visita.LAT_MX_Type__c != null){
                System.debug('%%%% visita : '  + visita);
                System.debug('%%%% OldMap.get(visita.Id) : '  + OldMap.get(visita.Id));
                if(visita.LAT_MX_Type__c != OldMap.get(visita.Id).LAT_MX_Type__c){
                    if(visita.LAT_MX_Type__c != null){
                        Set<String> setTypes = new Set<String>();
                        String[] ValuesNew = visita.LAT_MX_Type__c.split(';');
                        for(String s : ValuesNew){
                            setTypes.add(s);
                        }
                        mapIdVisitTypes.put(visita.Id, setTypes);
                        setIdsPlan.add(visita.Planejamento__c);
                    }else{
                        visita.addError(label.LAT_MX_AP01_00026);
                        //LAT_MX_AP01_00026: No se puede quitar tipos de visita para planeamientos aprobados.                
                    }                                     
                }
            }
        }
        
        if(!setIdsPlan.isEmpty()){
            Map<Id, Planejamento__c> mapPlansApprove = new Map<Id, Planejamento__c>([SELECT Id FROM Planejamento__c WHERE Id IN: setIdsPlan AND Status_do_Planejamento__c = 'Approved']);
            
            if(!mapPlansApprove.isEmpty()){
                Map<Id,Boolean> mapIdVisitaError = new Map<Id, Boolean>();
                Boolean isError = false;
                for(Visitas__c visita: triggerOld){
                    if(mapIdVisitTypes.containsKey(visita.Id)){
                        if(visita.LAT_MX_Type__c != null){
                            String[] ValuesOld = visita.LAT_MX_Type__c.split(';');
                            for(String s : ValuesOld){
                                if(!mapIdVisitTypes.get(visita.Id).contains(s)){
                                    mapIdVisitaError.put(visita.Id,true);
                                }
                            }
                        }
                    }
                }
                for(Visitas__c visita: triggerNew){
                    if(mapIdVisitaError.containsKey(visita.Id) && mapIdVisitaError.get(visita.Id)){
                        visita.addError(label.LAT_MX_AP01_00026);
                        //LAT_MX_AP01_00026: No se puede quitar tipos de visita para planeamientos aprobados.
                    }
                }               
            }
        }                            
    }  

    /*****************************************************************************************
    * Nombre del metodo: validatesVisitEdition
    * Descripcion: Valida que solo el manager del Owner del planeamiento pueda crear o modificar visitas de planeamientos aprobados
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 21/03/2014
    * Modo: Before Update
    *****************************************************************************************/
    public static void validatesVisitEdition(List<Visitas__c> triggerNew, Map<Id,Visitas__c> OldMap){
        
        Set<Id> setPlanIds = new Set<Id>();
        Set<Id> setVisitaIds = new Set<Id>();
        
        for(Visitas__c visita: triggerNew){
            if(visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit') 
                || visita != OldMap.get(visita.Id) || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisitON') ){
                setPlanIds.add(visita.Planejamento__c);
                setVisitaIds.add(visita.Id);
            }
        
        }
        if(!setPlanIds.isEmpty()){
        
            Map<Id,Planejamento__c> mapPlans = new Map<Id,Planejamento__c>([SELECT Id, Status_do_Planejamento__c, OwnerId FROM Planejamento__c WHERE Id IN: setPlanIds]);
            
            Set<Id> setOwnerIds = new Set<Id>();
            
            for(Planejamento__c plan: mapPlans.values()){
                setOwnerIds.add(plan.OwnerId);            
            }
            
            List<User> listUsers = [SELECT Id, ManagerId FROM User WHERE Id IN: setOwnerIds];
            
            Map<Id,Id> mapUserIdManager = new Map<Id,Id>();
            
            for(User us: listUsers){
                mapUserIdManager.put(us.Id, us.ManagerId);           
            }
            
            Id userId = UserInfo.getUserId();
            
            for(Visitas__c visita: triggerNew){
                if(mapPlans.get(visita.Planejamento__c) != null && mapPlans.get(visita.Planejamento__c).Status_do_Planejamento__c == 'Aguardando Aprovação' && setVisitaIds.contains(visita.Id)){
                    if(userId != mapUserIdManager.get(mapPlans.get(visita.Planejamento__c).OwnerId)){
                        visita.addError(label.LAT_MX_VFP05_00004);
                        //LAT_MX_VFP05_00004: No se pueden modificar Visitas si el planeamiento esta pendiente de aprobación.
                    }
                    
                }
            
            }            
        
        }
    
    }

    public static void calculateMinutes(List<Visitas__c> triggerNew, Map<Id,Visitas__c> OldMap){

        Id rtCheckIn = Global_RecordTypeCache.getRtId('Visitas__c'+'LAT_MX_CheckIn');
        for(Visitas__c visita: triggerNew){
            if(visita.RecordTypeId == rtCheckIn){ 
                if(visita.status__c.equalsIgnoreCase('Encerrada') && !OldMap.get(visita.Id).status__c.equalsIgnoreCase('Encerrada')){

                    system.debug('hora visita: ' + visita.Hora_da_Visita__c.split(':')[0]);
                    system.debug('min visita: ' + visita.Hora_da_Visita__c.split(':')[1]);

                    Time myTime = Time.newInstance(Integer.valueOf(visita.Hora_da_Visita__c.split(':')[0]), Integer.valueOf(visita.Hora_da_Visita__c.split(':')[1]), 0, 0);

                    system.debug('myTime visita: ' + myTime);

                    DateTime startDate = DateTime.newInstance(visita.Data_da_Visita__c, myTime);

                    system.debug('startDate: ' + startDate);
                    system.debug('now: ' + DateTime.now());

                    Long dif = DateTime.now().getTime() - startDate.getTime();

                    system.debug('diferencia: ' + dif);

                    visita.lat_mx_minutes_open__c = dif/60000;
                    visita.lat_mx_close_date__c = Datetime.now();
                    
                }
            }
        }   
    }
   
}