/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: DemandaInterna.cls
* AUTHOR:                                               DATE: 
*
* MAINTENANCE
* AUTHOR:                                               DATE: 
* DESC:  
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
public without sharing class DemandaInterna{ 

    private static Set<Id> setAccIds;

    //MIGRATED 02/11/2016 
    public static void CriaDemanda ( String NomeFila, Id IdUsuario, String TipoRegistro, Id ContaId, 
        Id ContatoId, string Tipo, string Motivo, String Assunto, String Descricao, Id ContratoId, Id CaseParentId){
        System.debug('%%%%%  NomeFila '+NomeFila);
        if(!Utils.wasMigrationDone('1')){
            if(setAccIds == null){
                setAccIds = new Set<Id>();
            }
            if(setAccIds.contains(ContaId)){
                return;
            }
            
            setAccIds.add(ContaId);
         
            id tiporegistroid = null;
            Id filaId = null;
            Id Proprietario = null;
            // Se TIPO DE REGISTRO FILA veio preenchido, encontra o ID do record type
            if (TipoRegistro != null) {
                for(RecordType rt: Global_RecordTypeCache.getRtList('Case')){
                    if(rt.Name == TipoRegistro){
                        tiporegistroId = rt.Id;
                    }
                }
            }
            // Se IDUSUARIO VEIO PREENCHIDO, USA O ID USUARIO, SENÂO USA A FILA
            if (IdUsuario != null) { Proprietario = IdUsuario;
            } else if (NomeFila != null) {            
            // Se FILA veio preenchido, encontra o ID da fila
              FilaId = [SELECT Id,queue.Name, QueueId FROM QueueSobject WHERE SobjectType = 'Case'and queue.Name = :NomeFila limit 1].queueid;
                Proprietario = FilaId;
            } 
            Case demanda = new Case();
            demanda.AccountId = contaid;
            if (ContatoId != Null) {demanda.contactid = contatoId;}
            demanda.Type = tipo;
            demanda.reason = motivo;
            demanda.subject = assunto;
            demanda.description = descricao;
            demanda.ownerId = proprietario;
            demanda.recordtypeid = tiporegistroId;
            demanda.Origin = 'Demanda Automática CRM';
            demanda.Priority = 'Médio';
            
            if (CaseParentId != Null) {demanda.ParentId = CaseParentId ;}
            
            if (ContratoId != Null) {demanda.LAT_Contract__c = contratoId;}
            
            insert demanda;
        }else{
            if(setAccIds == null){
                setAccIds = new Set<Id>();
            }
            if(setAccIds.contains(ContaId)){
                return;
            }
            
            setAccIds.add(ContaId);
         
            id tiporegistroid = null;
            Id filaId = null;
            Id Proprietario = null;
            // Se TIPO DE REGISTRO FILA veio preenchido, encontra o ID do record type
            if (TipoRegistro != null) {
                for(RecordType rt: Global_RecordTypeCache.getRtList('LAT_Case__c')){
                    if(rt.Name == TipoRegistro){
                        tiporegistroId = rt.Id;
                    }
                }
            }
            // Se IDUSUARIO VEIO PREENCHIDO, USA O ID USUARIO, SENÂO USA A FILA
            if (IdUsuario != null) { Proprietario = IdUsuario;
            } else if (NomeFila != null) {            
            // Se FILA veio preenchido, encontra o ID da fila
              FilaId = [SELECT Id,queue.Name, QueueId FROM QueueSobject WHERE SobjectType = 'LAT_Case__c'and queue.Name = :NomeFila limit 1].queueid;
                Proprietario = FilaId;
            } 
            LAT_Case__c demanda = new LAT_Case__c();
            demanda.LAT_Account__c = contaid;
            if (ContatoId != Null) {demanda.LAT_Contact__c = contatoId;}
            demanda.LAT_Type__c = tipo;
            demanda.LAT_reason__c = motivo;
            demanda.LAT_subject__c = assunto;
            demanda.LAT_description__c = descricao;
            demanda.ownerId = UserInfo.getUserId();
            demanda.recordtypeid = tiporegistroId;
            demanda.LAT_Origin__c = 'Demanda Automática CRM';
            demanda.LAT_Priority__c = 'Médio';
            
            if (CaseParentId != Null) {demanda.LAT_Parent__c = CaseParentId ;}
            
            if (ContratoId != Null) {demanda.LAT_Contract__c = contratoId;}
            
            insert demanda;
            
            demanda.ownerId = proprietario;
            update demanda;
        }        
    }
}