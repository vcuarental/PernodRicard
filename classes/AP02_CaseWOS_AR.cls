/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto Case
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public without sharing class AP02_CaseWOS_AR {
   
    public static map<Id, RecordType> mapIdRtCase = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('Case'));
    public static map<Id, RecordType> mapIdRtLATCase = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('LAT_Case__c'));
    
    /*****************************************************************************************
    * Nombre del metodo: UpdateStatusCaseClose
    * Descripcion: Cuando cierra el caso se updatea el status.
    * Desarrollador: Tomas Garcia Etchegaray
    * Fecha: 11/03/2013
    * Modo: after insert, after update
    *****************************************************************************************/
    public static void UpdateStatusCaseClose (List<Case> triggerNew){
        set<Id> setParentAcc = new set<Id>();
        set<Id> setParentToCloseAcc = new set<Id>();
        for (Case cas : triggerNew ){
            if ('Solicitação de inativação de cliente'.equals(cas.reason) && 'Fechado e resolvido'.equals(cas.Status) && (mapIdRtCase.get(cas.RecordTypeid).DeveloperName =='CSE_1_AccountAlteration_ARG' || mapIdRtCase.get(cas.RecordTypeid).DeveloperName =='CSE_2_AccountAlteration_URU' )){
                setParentToCloseAcc.add(cas.AccountId);
            }
            if ('Fechado e resolvido'.equals(cas.Status) && (mapIdRtCase.get(cas.RecordTypeid).DeveloperName =='CSE_1_AccountAlteration_ARG' || mapIdRtCase.get(cas.RecordTypeid).DeveloperName =='CSE_2_AccountAlteration_URU' )){
                setParentAcc.add(cas.AccountId);
            }
        }

        if(!setParentToCloseAcc.isEmpty()){
            List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentToCloseAcc];
            for(Account con: Accounts){
                con.Rating = 'Cliente inativo';
                con.Status__c = 'Directed to be registered In JDE';
            }
            update Accounts;
        }

        if(!setParentAcc.isEmpty()){
            List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentAcc AND Type !='Indirect_ARG' AND Type !='Prospect_ARG' AND Type !='Events_ARG' AND RecordTypeId IN : Global_RecordTypeCache.getRtIdSet('Account', new set<String>{'ACC_1_OffTrade_ARG', 'ACC_2_OffTrade_URU', 'ACC_3_OnTrade_ARG', 'ACC_4_OnTrade_URU', 'ACC_5_Events_ARG', 'ACC_6_Events_URU'})];
            for(Account con: Accounts){
                con.triggerRun__c = true;
                con.Status__c = 'Directed to be registered In JDE';
            }
            update Accounts;
        }
        
    }
    
    /*****************************************************************************************
    * Nombre del metodo: ApprovalProcessFlow
    * Descripcion: Metodo que actualiza el campo LAT_APStep__c que controla el proceso de aprobacion 
    *              y valida que en modificación de límite de crédito se complete este campo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 27/12/2013
    * Modo: before update
    *****************************************************************************************/ 

    public static void ApprovalProcessFlow (List<Case> triggerNew, Map<Id,Case> OldMap){

        Set<String> setCrediAnalysis = new Set<String>();
        for(Case caso: triggerNew){
            if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('Case' + 'CSE_1_AccountAlteration_ARG') || caso.RecordTypeId == Global_RecordTypeCache.getRtId('Case' + 'CSE_2_AccountAlteration_URU')){
                if(caso.LAT_APStep__c == 1 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.Credit_Analysis_AR__c == null){
                    caso.addError(label.LAT_AR_AP02_00001);
                    //LAT_AR_AP02_00001: No se puede enviar a aprobar porque no se seleccionó un Análisis de Crédito.
                }
                if((caso.LAT_APStep__c == 1 || caso.LAT_APStep__c == 3) && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.Credit_Analysis_AR__c != null){
                    setCrediAnalysis.add(caso.Credit_Analysis_AR__c);
                }
            }
        }
        if(!setCrediAnalysis.isEmpty()){
            Map<String,CRA_CredAnalysis_ARG__c> mapCreditAnalysis = new Map<String,CRA_CredAnalysis_ARG__c>([SELECT Id, CreditLimitRequested_ARG__c, CreditLimitGranted_ARG__c FROM CRA_CredAnalysis_ARG__c WHERE Id IN: setCrediAnalysis]);
            for(Case caso: triggerNew){
                if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('Case' + 'CSE_1_AccountAlteration_ARG') || caso.RecordTypeId == Global_RecordTypeCache.getRtId('Case' + 'CSE_2_AccountAlteration_URU')){
                    if(caso.LAT_APStep__c == 1 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.Credit_Analysis_AR__c != null && mapCreditAnalysis.get(caso.Credit_Analysis_AR__c).CreditLimitRequested_ARG__c == null){
                        caso.addError(label.LAT_AR_AP02_00002);
                        //LAT_AR_AP02_00002: No se puede enviar a aprobar porque el campo 'Limite Crédito Solicitado' del Análisis de Crédito seleccionado esta vacio.
                    }
                    if(caso.LAT_APStep__c == 3 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.Credit_Analysis_AR__c != null && mapCreditAnalysis.get(caso.Credit_Analysis_AR__c).CreditLimitGranted_ARG__c == null){
                        caso.addError(label.LAT_AR_AP02_00003);
                        //LAT_AR_AP02_00003: Complete el Límite de Crédito Asignado desde el registro de Límite de Crédito para continuar con la aprobación.
                    }
                }
            }
        }
    }       
     

/* ------------NEW-------------- PR Migración Licencia ------------NEW--------------*/
    //MIGRATED 02/11/2016 
    public static void UpdateStatusCaseClose (List<LAT_Case__C> triggerNew){
        set<Id> setParentAcc = new set<Id>();
        set<Id> setParentToCloseAcc = new set<Id>();
        for (LAT_Case__C cas : triggerNew ){
            if ('Solicitação de inativação de cliente'.equals(cas.LAT_reason__c) && 'Fechado e resolvido'.equals(cas.LAT_Status__c) && (mapIdRtLATCase.get(cas.RecordTypeid).DeveloperName =='CSE_1_AccountAlteration_ARG' || mapIdRtLATCase.get(cas.RecordTypeid).DeveloperName =='CSE_2_AccountAlteration_URU' )){
                setParentToCloseAcc.add(cas.LAT_Account__c);
            }
            if ('Fechado e resolvido'.equals(cas.LAT_Status__c) && (mapIdRtLATCase.get(cas.RecordTypeid).DeveloperName =='CSE_1_AccountAlteration_ARG' || mapIdRtLATCase.get(cas.RecordTypeid).DeveloperName =='CSE_2_AccountAlteration_URU' )){
                setParentAcc.add(cas.LAT_Account__c);
            }
        }

        if(!setParentToCloseAcc.isEmpty()){
            List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentToCloseAcc];
            for(Account con: Accounts){
                con.Rating = 'Cliente inativo';
                con.Status__c = 'Directed to be registered In JDE';
            }
            update Accounts;
        } 

        if(!setParentAcc.isEmpty()){
            List<Account> Accounts = [SELECT Id, Status__c,Type, RecordTypeId FROM Account WHERE Id IN: setParentAcc AND Type !='Indirect_ARG' AND Type !='Prospect_ARG' AND Type !='Events_ARG' AND RecordTypeId IN : Global_RecordTypeCache.getRtIdSet('Account', new set<String>{'ACC_1_OffTrade_ARG', 'ACC_2_OffTrade_URU', 'ACC_3_OnTrade_ARG', 'ACC_4_OnTrade_URU', 'ACC_5_Events_ARG', 'ACC_6_Events_URU'})];
            for(Account con: Accounts){
                con.triggerRun__c = true;
                con.Status__c = 'Directed to be registered In JDE';
            }
            update Accounts;
        }
        
    }
    
    //MIGRATED 21/11/2016 
    public static void ApprovalProcessFlow (List<LAT_Case__C> triggerNew, Map<Id,LAT_Case__C> OldMap){

        Set<String> setCrediAnalysis = new Set<String>();
        for(LAT_Case__C caso: triggerNew){
            if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_1_AccountAlteration_ARG') || caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_2_AccountAlteration_URU')){
                if(caso.LAT_APStep__c == 1 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.LAT_AR_CreditAnalysis__c == null){
                    caso.addError(label.LAT_AR_AP02_00001);
                    //LAT_AR_AP02_00001: No se puede enviar a aprobar porque no se seleccionó un Análisis de Crédito.
                }
                if((caso.LAT_APStep__c == 1 || caso.LAT_APStep__c == 3) && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.LAT_AR_CreditAnalysis__c != null){
                    setCrediAnalysis.add(caso.LAT_AR_CreditAnalysis__c);
                }
            }
        }
        if(!setCrediAnalysis.isEmpty()){
            Map<String,CRA_CredAnalysis_ARG__c> mapCreditAnalysis = new Map<String,CRA_CredAnalysis_ARG__c>([SELECT Id, CreditLimitRequested_ARG__c, CreditLimitGranted_ARG__c FROM CRA_CredAnalysis_ARG__c WHERE Id IN: setCrediAnalysis]);
            for(LAT_Case__C caso: triggerNew){
                if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_1_AccountAlteration_ARG') || caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_2_AccountAlteration_URU')){
                    if(caso.LAT_APStep__c == 1 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.LAT_AR_CreditAnalysis__c != null && mapCreditAnalysis.get(caso.LAT_AR_CreditAnalysis__c).CreditLimitRequested_ARG__c == null){
                        caso.addError(label.LAT_AR_AP02_00002);
                        //LAT_AR_AP02_00002: No se puede enviar a aprobar porque el campo 'Limite Crédito Solicitado' del Análisis de Crédito seleccionado esta vacio.
                    }
                    if(caso.LAT_APStep__c == 3 && OldMap.get(caso.Id).LAT_APStep__c != caso.LAT_APStep__c && caso.LAT_AR_CreditAnalysis__c != null && mapCreditAnalysis.get(caso.LAT_AR_CreditAnalysis__c).CreditLimitGranted_ARG__c == null){
                        caso.addError(label.LAT_AR_AP02_00003);
                        //LAT_AR_AP02_00003: Complete el Límite de Crédito Asignado desde el registro de Límite de Crédito para continuar con la aprobación.
                    }
                }
            }
        }
    }        
}