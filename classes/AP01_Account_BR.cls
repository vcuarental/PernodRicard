/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto Account
*******************************************************************************/

public with sharing class AP01_Account_BR {

    public static Boolean isRunning;
    public static Boolean runInterface = false;
        //AP01_Account_BR.BR_RECORDTYPES
    public static final Set<String> BR_RECORDTYPES = new Set<String> {'On_Trade', 
                                                                     'Off_Trade', 
                                                       	              'Eventos',
                                                                    // new segmentations
                                                                    'LAT_Distribucao_Com_Faturamento',
                                                                    'LAT_Off_Trade_Sem_Faturamento',
                                                                    'LAT_Off_Trade_Faturamento',
                                                                    'LAT_On_Line_Com_Faturamento',
                                                                        'LAT_On_Trade_Venda_Directa',
                                                                    'LAT_On_Trade_Sem_Pagamento',
                                                                        'LAT_On_Trade_Com_Pagamento',
                                                                        'LAT_Eventos_VendaDirecta',
                                                                        'LAT_Eventos_com_pagamento',
                                                                    'LAT_Eventos_sem_pagamento'};
                                                                    // 'LAT_Off_Trade_Faturamento', 'LAT_Distribucao_Com_Faturamento','LAT_Off_Trade_Sem_Faturamento','LAT_On_Trade_Venda_Directa', 'LAT_Off_Trade_Faturamento'};


    /*****************************************************************************************
    * Nombre del metodo: UpdateRegionalSalesCodDefUsuario
    * Descripcion: Metodo que completa el campo Regional_Sales_CodDefUsuario__c
    * Desarrollador: Waldemar Mayo
    * Fecha: 15/08/2013
    * Modo:  Before Insert, Before Update
    *****************************************************************************************/
    public static void updateRegionalSalesCodDefUsuario(List<Account> triggerNew, map<Id,Account> oldMap){
        set<Id> setIdRegional = new set<Id>();
        for(Account acc: triggerNew){
            if(oldMap != null){
                if(acc.Regional__c != oldMap.get(acc.Id).Regional__c){
                    if(acc.Regional__c != null){
                        setIdRegional.add(acc.Regional__c);
                    }else{
                        acc.Regional_Sales_CodDefUsuario__c=null;
                    }
                } else if (acc.Regional_Sales_CodDefUsuario__c == null 
                            && acc.Regional__c != null) {
                    setIdRegional.add(acc.Regional__c);
                }
            }else if(acc.Regional__c != null){
                setIdRegional.add(acc.Regional__c);
            }else {
                acc.Regional_Sales_CodDefUsuario__c = null;
            }
        }
        if(!setIdRegional.isEmpty()){
            map<Id, UDC__c> mapIdUdc = new map<Id, UDC__c>([SELECT Id, CodDefUsuario__c FROM UDC__c WHERE Id IN: setIdRegional]);
            for(Account acc: triggerNew){
                if(acc.Regional__c != null){
                    if(oldMap != null){
                        if(acc.Regional__c != oldMap.get(acc.Id).Regional__c){
                            acc.Regional_Sales_CodDefUsuario__c = mapIdUdc.get(acc.Regional__c).CodDefUsuario__c;
                        } else if (acc.Regional_Sales_CodDefUsuario__c == null 
                            && acc.Regional__c != null) {
                            acc.Regional_Sales_CodDefUsuario__c = mapIdUdc.get(acc.Regional__c).CodDefUsuario__c;
                        }
                    } else if (mapIdUdc.get(acc.Regional__c) != null) {
                        acc.Regional_Sales_CodDefUsuario__c = mapIdUdc.get(acc.Regional__c).CodDefUsuario__c;
                    }
                }
            }
        }
    }
    
    /**
     * Migrated from trigger ContaCriaDemanda
     *
     */
    public static void ContaCriaDemanda(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        Map<Id,Account> mapIdAcc = new Map<Id,Account>();
        List<Id> listLatAccount = new List<Id>();
        for (Account acc:triggerNew){
            mapIdAcc.put(acc.Id, acc);
            listLatAccount.add(acc.LAT_Account__c);
        }

        List<Titulos__c>  titulos = [Select Id,Cliente__c from Titulos__c where Cliente__c IN: mapIdAcc.keySet() ];
        Map <String,Titulos__c> mapIdAccTit = new Map <String,Titulos__c>();
        
        for ( Titulos__c tit : titulos ){
            mapIdAccTit.put( tit.Cliente__c , tit );
        }
        
        List<Task> taskToInsert= new list<Task>();
        
        // PROCESSO DE INADIMPLÊNCIA
        // Se cliente ficou inadimplente e tem títulos inadimplentes, abre caso automático
        for( String key:mapIdAccTit.keySet() ){ 
            Task task = new Task();
            task.CallObject = 'Cliente inadimplente';
            task.WhatId = key;
            task.OwnerId = mapIdAcc.get(key).OwnerID;
            task.Subject = 'Cliente inadimplente';
            task.priority= 'Normal';
            task.status = 'Não iniciado';
            task.description = label.descriptionAccTask_BR + '( ' + mapIdAcc.get(key).Client_code_AN8__c + ' - ' + mapIdAcc.get(key).Name + ' )' ;
            task.ActivityDate = Date.Today() + 1;
            taskToInsert.add(task);
        }
        insert taskToInsert;

        Map<Id, LAT_Account__c> mapLatAccounts = new Map<Id, LAT_Account__c>([Select Id, LAT_BR_PurchaseForecast__c From LAT_Account__c Where Id IN :listLatAccount]);
        for(Account a:triggerNew) {
            // PROCESSO DE CLIENTES:
            // Se status foi alterado, abre caso  (demanda) para a área correpondente
            LAT_BR_SegmentationBehaviorHandler.OldAccountTyping oldType = new LAT_BR_SegmentationBehaviorHandler.oldAccountTyping(a);
            System.debug('Case Create oldType+' + oldType.recordTypeDeveName);
            System.debug('Case Create oldType+' + oldType);

            // Sem faturamente cno crea demanda
            if(a.Type == 'Outros' || a.Type == 'SEM PAGAMENTO' || a.Type == 'SEM FATURAMENTO'){ continue;}

            if(a.Status__c == 'Em análise - Customer Service' && triggerOldMap.get(a.id).Status__c <> 'Em análise - Customer Service'){
                System.debug('Case Customer Service creating+++'); 
                DemandaInterna.criademanda('Customer service', null, 'Novo cadastro de cliente', a.id, null,
                    'Cadastro de clientes','Análise/complementação de dados', 
                    'Análise e complementação de dados de novo cadastro de cliente','', null, null);
            } else if (a.Status__c == 'Em análise - Crédito e Cobrança' && triggerOldMap.get(a.Id).Status__c <> 'Em análise - Crédito e Cobrança') { 
                System.debug('Case credito cobranca Service creating+++');
                DemandaInterna.criademanda('Crédito e cobrança', null, 'Novo cadastro de cliente', a.id, null, 'Cadastro de clientes','Análise/complementação de dados', 'Análise e complementação de dados de novo cadastro de cliente','', null, null);
            } else if(a.Status__c == 'Em análise - ADM Vendas' && triggerOldMap.get(a.Id).Status__c <> 'Em análise - ADM Vendas'){
                System.debug('ADM VENDAS creating+++');
                DemandaInterna.criademanda('Administração de Vendas', null, 'Novo cadastro de cliente', a.id, null,
                    'Cadastro de clientes','Análise/complementação de dados', 
                    'Análise e complementação de dados de novo cadastro de cliente','', null, null);
            } else if(a.Status__c == 'Em análise - Controladoria' && triggerOldMap.get(a.Id).Status__c <> 'Em análise - Controladoria'){
                System.debug('Controladoria creating+++');
                DemandaInterna.criademanda('Controladoria', null, 'Novo cadastro de cliente', a.id, null,
                    'Cadastro de clientes','Análise/complementação de dados', 
                    'Análise e complementação de dados de novo cadastro de cliente','', null, null);           
            } else if (a.Status__c == 'Em análise - Legal' && triggerOldMap.get(a.Id).Status__c <> 'Em análise - Legal' && 
                    triggerOldMap.get(a.Id).Status__c <> 'Em análise - ADM Vendas' && mapLatAccounts.get(a.LAT_Account__c).LAT_BR_PurchaseForecast__c >= 700000){
                System.debug('Legal creating+++');
                DemandaInterna.criademanda('Legal', null, 'Novo cadastro de cliente', a.id, null,
                    'Cadastro de clientes', 'Análise/complementação de dados', 
                    'Análise e complementação de dados de novo cadastro de cliente','', null, null);  
            }
        }
    }

    /**
     * Migrated from trigger ContaAutomatizaEnvioAprovacao
     *
     */
    public static void ContaAutomatizaEnvioAprovacao(List<Account> lstAccount, Map<Id, Account> mapOldMap){
        Set<Id> setIdsAccountToProcess = null;
        Approval.ProcessSubmitRequest objProcessSubmitRequest = null;

        System.debug('ContaAutomatizaEnvioAprovacao [] -> ');
        
        setIdsAccountToProcess = new set<Id>();
        for(Account objAccount : lstAccount){
            System.debug('ContaAutomatizaEnvioAprovacao [objAccount.Checked_over_Sales_Administration__c : ' + objAccount.Checked_over_Sales_Administration__c +']');
            System.debug('ContaAutomatizaEnvioAprovacao [objAccount.Checked_over_Sales_Administration__c : ' + objAccount.Checked_over_Credit_and_collection__c +']');

            if(objAccount.Checked_over_Sales_Administration__c && objAccount.Checked_over_Credit_and_collection__c /*&& a.Checked_over_Commercial_Planning__c*/ && ((Trigger.isInsert) || (Trigger.isUpdate && (objAccount.Checked_over_Sales_Administration__c != mapOldMap.get(objAccount.Id).Checked_over_Sales_Administration__c || objAccount.Checked_over_Credit_and_collection__c != mapOldMap.get(objAccount.Id).Checked_over_Credit_and_collection__c /*|| a.Checked_over_Commercial_Planning__c != Trigger.oldMap.get(a.Id).Checked_over_Commercial_Planning__c*/)))){
                setIdsAccountToProcess.add(objAccount.Id);
            }
        }
        
        if(!setIdsAccountToProcess.isEmpty()){ 
            for(ProcessInstance objProcessInstance : [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId IN: setIdsAccountToProcess AND (Status = 'Pendente' OR Status = 'Pending')]){
                setIdsAccountToProcess.remove(objProcessInstance.TargetObjectId);
            }
             
            for (Account objAccount : lstAccount) {
                System.debug('ContaAutomatizaEnvioAprovacao [objAccount : ' + objAccount.Id + ']');

                if(setIdsAccountToProcess.contains(objAccount.Id)){
                    System.debug('ContaAutomatizaEnvioAprovacao [objAccount : ' + objAccount.Id + ']');
                    // create the new approval request to submit
                    //if(a.RecordType.DeveloperName != 'Eventos' && a.Status__c != 'Em análise - Controladoria'){
                    objProcessSubmitRequest = new Approval.ProcessSubmitRequest();
                    objProcessSubmitRequest.setComments('Enviado para aprovação.');
                    objProcessSubmitRequest.setNextApproverIds(new List<Id>{objAccount.OwnerId});
                    objProcessSubmitRequest.setObjectId (objAccount.Id);
                    
                    // submit the approval request for processing
                    Approval.ProcessResult result = Approval.process(objProcessSubmitRequest);                         
                    //}
                }
            }
        }

        System.debug('ContaAutomatizaEnvioAprovacao [] <- ');
    }

    /**
     * Migrated from trigger ContaAutomatizaEnvioAprovacao
     *
     */
    public static void Conta_valida_Inscricao_Estadual(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        for( Account c : triggerNew) {
            if(c.State_registration__c <> null && c.State_registration__c <> 'Isento' && c.Revenue_UF__c != null ){
                   Boolean result = InscricaoEstadual.ValidaIE( c.Revenue_UF__c, c.State_registration__c);
                   if(!result) c.State_registration__c.AddError('Combinação de Inscrição estadual e Estado de faturamento inválida.');
            }
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: UpdateClientCountryAN8
    * Descripcion: Metodo que completa el campo Client_country_AN8__c
    * Desarrollador: Waldemar Mayo
    * Fecha: 30/04/2013
    * Modo:  Before Update
    *****************************************************************************************/
    public static void updateClientCountryAN8(List<Account> triggerNew, map<Id,Account> oldMap){
        for(Account acc: triggerNew){
            if(acc.Client_code_AN8__c!=null && acc.Client_code_AN8__c!=oldMap.get(acc.Id).Client_code_AN8__c){
                acc.Client_country_AN8__c = '1-'+acc.Client_code_AN8__c;
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: InsertClientCountryAN8
    * Descripcion: Metodo que completa el campo Client_country_AN8__c
    * Desarrollador: Tomás García Etchegaray
    * Fecha: 30/04/2013
    * Modo: Before insert
    *****************************************************************************************/
    public static void insertClientCountryAN8(List<Account> triggerNew){
        for(Account acc: triggerNew){
            if(acc.Client_code_AN8__c!=null ){
                acc.Client_country_AN8__c = '1-'+acc.Client_code_AN8__c;
            }
        }
    }
    
    /*********************************************************************************************************
    * Nombre del metodo: LATAccount
    * Descripcion: Creates a LAT_Account__c for Account
    * Desarrollador: Denis Aranda
    * Fecha: 23/10/2013
    * Modo: After Insert
    *********************************************************************************************************/
    public static void LATAccount(List<Account> triggerNew){
        List <LAT_ACCOUNT__c> listLATAccount = new List <LAT_ACCOUNT__c>();
        for(Account acc: triggerNew ){
            listLATAccount.add(new LAT_ACCOUNT__c(LAT_Accountid__c = acc.id, RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_BR_LAC_Standard')));
        }
        insert listLATAccount;
    }
    
    /*********************************************************************************************************
    * Checks if the the owner of a BR account has changed and turns on a flag that a batch will read and do 
    * further processing.
    *********************************************************************************************************/
    public static void OwnerChangedFlagCheck(LAT_AccountOneTriggerHandler handler) {
        Map<Id, LAT_Account__c> latAccByAccId = handler.latAccountByAccountId;
        List<Account> triggerNew = handler.getAccountsForRts(BR_RECORDTYPES);
        Map<Id, Account> triggerOldMap = handler.oldAccountMap;
        List<LAT_Account__c>  lataToUpdate = new List<LAT_Account__c>();

        system.debug('entre metodo OwnerChangedFlagCheck');

         for(Account acc: triggerNew){
            if (acc.OwnerId != triggerOldMap.get(acc.Id).OwnerId){
                system.debug('entre if');
                
                latAccByAccId.get(acc.Id).LAT_Owner_Changed__c = true;
                lataToUpdate.add(latAccByAccId.get(acc.Id));
            }
        }
        
        if(!lataToUpdate.isEmpty()){
            update lataToUpdate;
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: updatesInformationUnfilled
    * Descripcion: Updates field LAT_InformationUnfilled__c and LAT_BR_InformationRequiredOff__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/02/2014
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void updatesInformationUnfilled(LAT_AccountOneTriggerHandler handler) {
        System.debug('%%%%%%% entramos en updatesInformationUnfilled');
        List<Account> triggerNew = handler.getAccountsForRts(BR_RECORDTYPES);
        Map<Id, LAT_Account__c> latAccByAccId = handler.latAccountByAccountId;

        Map<String,Boolean> mapAcccIdClientWorkHourDaysMissing = new Map<String,Boolean>();
        for(Account acc: triggerNew){
            mapAcccIdClientWorkHourDaysMissing.put(acc.Id,null);
        }
        
        if(!mapAcccIdClientWorkHourDaysMissing.isEmpty()){
            List<LAT_CWH_ClientWorkHour__c> listClientWorkHour = [SELECT Id, Monday_order__c, Tuesday_order__c, Wednesday_Order__c, Thursday_Order__c, Friday_order__c, Saturday_order__c, Sunday_Order__c, Account__c FROM LAT_CWH_ClientWorkHour__c WHERE Account__c IN: mapAcccIdClientWorkHourDaysMissing.keySet()];
            if(!listClientWorkHour.isEmpty()){
                for(LAT_CWH_ClientWorkHour__c cwh: listClientWorkHour){
                    if(mapAcccIdClientWorkHourDaysMissing.containsKey(cwh.Account__c)){
                        if(cwh.Monday_order__c == false && cwh.Tuesday_order__c == false && cwh.Wednesday_Order__c == false && cwh.Thursday_Order__c == false && cwh.Friday_order__c == false && cwh.Saturday_order__c == false && cwh.Sunday_Order__c == false){
                            mapAcccIdClientWorkHourDaysMissing.put(cwh.Account__c,true);
                        }else{
                            mapAcccIdClientWorkHourDaysMissing.put(cwh.Account__c,false);
                        }
                    }
                }
            }
        }

        //Load the Lat_account Data
        for(Account acc: triggerNew){
            System.debug('%%%%%%% entramos en el for, type : ' + acc.Type  + ' || acc.Revenue_UF__c' + acc.Revenue_UF__c );
            
            acc.LAT_InformationUnfilled__c = '';
            acc.LAT_BR_InformationRequiredOff__c = '';
            
            LAT_BR_SegmentationBehaviorHandler.OldAccountTyping oldType = new LAT_BR_SegmentationBehaviorHandler.oldAccountTyping(acc);
            system.debug('OLD TYPE: ++ ' + oldType );
            
            if (acc.Type == 'COM PAGAMENTO' || acc.Type == 'COM FATURAMENTO' || acc.Type == 'VENDA DIRETA'){
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.CNPJ__c == null) ? '<b>' + Schema.Account.Field.CNPJ__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Business_Unit__c == null) ? '<b>' + Schema.Account.Field.Business_Unit__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Regional__c == null) ? '<b>' + Schema.Account.Field.Regional__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Customer_Organization__c == null) ? '<b>' + Schema.Account.Field.Customer_Organization__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Customer_Flag__c == null) ? '<b>' + Schema.Account.Field.Customer_Flag__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Revenue_UF__c == null) ? '<b>' + Schema.Account.Field.Revenue_UF__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_City__c == null) ? '<b>' + Schema.Account.Field.Revenue_City__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Agency__c == null) ? '<b>' + Schema.Account.Field.Agency__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Bank__c == null) ? '<b>' + Schema.Account.Field.Bank__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Current_account__c == null) ? '<b>' + Schema.Account.Field.Current_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Checking_account__c == null) ? '<b>' + Schema.Account.Field.Checking_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Payment_Condition__c == null) ? '<b>' + Schema.Account.Field.Payment_Condition__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Payment_instrument__c == null) ? '<b>' + Schema.Account.Field.Payment_instrument__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';                                

                // if (oldType.recordTypeDeveName == 'Off_Trade'){ //acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')){
                if (acc.Type == 'COM FATURAMENTO' || acc.Type == 'VENDA DIRETA'){
                    acc.LAT_InformationUnfilled__c += (acc.Credit_analysis__c <= 0) ? '<b>' + Schema.Account.Field.Credit_analysis__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                    acc.LAT_InformationUnfilled__c += (mapAcccIdClientWorkHourDaysMissing.containsKey(acc.Id) && mapAcccIdClientWorkHourDaysMissing.get(acc.Id) == true) ? '<b>' + label.LAT_AP01_00002_BR + '</b>' + '<br/>' : '';
                }
                
                // Know Your Customer
                // System.debug('PREVISION compra = '+acc.LAT_Account__r.LAT_BR_PurchaseForecast__c);
                // acc.LAT_InformationUnfilled__c += (acc.LAT_Account__r.LAT_BR_PurchaseForecast__c == null) ? '<b>' + Schema.LAT_Account__c.Field.LAT_BR_PurchaseForecast__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                 
                // TIPO = CON PAGOS CON FATURA VENDA DIRETA
                System.debug('ENTER THE MATRIX+++' );
               
                //campos de LAT_InformationUnfilled__c mandatorios para record type Off Trade en el proceso de aprobación: Cliente - Novo cadastro HV
                
                //acc.LAT_InformationUnfilled__c += (acc.Sub_Channel_Rating__c == null) ? '<b>' + Schema.Account.Field.Sub_Channel_Rating__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';                

                //LAT_AP01_00002_BR: Dia de recebimento de carga
                //acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.State_Registration__c == null) ? '<b>' + Schema.Account.Field.State_Registration__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Carriers_Numbers__c == null) ? '<b>' + Schema.Account.Field.Carriers_Numbers__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Receiving_Freight__c == null) ? '<b>' + Schema.Account.Field.Receiving_Freight__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Customer_Geographic_Region__c == null) ? '<b>' + Schema.Account.Field.Customer_Geographic_Region__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                // acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Vehicle_Type__c == null) ? '<b>' + Schema.Account.Field.Vehicle_Type__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                
                //acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Sub_Channel__c == 'Distribuidor' && acc.Count_data_distributor__c < 1) ? '<b>' + label.LAT_AP01_00001_BR + '</b>' + '<br/>' : '';  
                //acc.LAT_InformationUnfilled__c += (acc.LAT_BR_ActingFormat__c == null) ? '<b>' + Schema.Account.Field.LAT_BR_ActingFormat__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';

                // COMMENTED UNTIN NEW SEGMENTATION
                //acc.LAT_InformationUnfilled__c += (acc.Rating_segmentation_targert_market__c == null) ? '<b>' + Schema.Account.Field.Rating_segmentation_targert_market__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';               
                //acc.LAT_InformationUnfilled__c += (acc.Sub_Channel__c == null) ? '<b>' + Schema.Account.Field.Sub_Channel__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.LAT_BR_PriorityLevel__c == null) ? '<b>' + Schema.Account.Field.LAT_BR_PriorityLevel__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                
                if (!LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(acc.Id)){ 
                    System.debug('ENTER THE MATRIX2+++' );
                    acc.LAT_InformationUnfilled__c += '<b>' + 'Seção Segmentação' + '</b>' + '<br/>' ;
                }
                //LAT_AP01_00001_BR: Dados adicionais do distribuidor           
                               
                //campos de LAT_BR_InformationRequiredOff__c que son requeridos
                acc.LAT_BR_InformationRequiredOff__c += (acc.Type != 'Outros' && acc.ParentId == null) ? '<b>' + Schema.Account.Field.ParentId.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_BR_InformationRequiredOff__c += (acc.Phone == null) ? '<b>' + Schema.Account.Field.Phone.getDescribe().getLabel() + '</b>' + '<br/>' : '';           
            }
            // SIN PAGAMENTO SIN FATURAMENTO

            // REMOVEMOS
            if (acc.Type == 'SEM PAGAMENTO' || acc.Type == 'SEM FATURAMENTO'){
                System.debug('%%%%%%% entramos en sem pagamento, type : ' + acc.Type  + ' || acc.Revenue_UF__c' + acc.Revenue_UF__c );
                System.debug('%%%%%%% acc.LAT_InformationUnfilled__c ' + acc.LAT_InformationUnfilled__c );
                //acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade')){ 
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.CNPJ__c == null) ? '<b>' + Schema.Account.Field.CNPJ__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Regional__c == null) ? '<b>' + Schema.Account.Field.Regional__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Revenue_UF__c == null) ? '<b>' + Schema.Account.Field.Revenue_UF__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_City__c == null) ? '<b>' + Schema.Account.Field.Revenue_City__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                  
                if (!LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(acc.Id)){
                    System.debug('ENTER THE MATRIX2+++' );
                    acc.LAT_InformationUnfilled__c += '<b>' + 'Seção Segmentação' + '</b>' + '<br/>' ;
                } 

                /*campos de LAT_InformationUnfilled__c mandatorios para record type On Trade en el proceso de aprobación: Cliente - Novo cadastro HV   
                acc.LAT_InformationUnfilled__c += (acc.Nielsen_Area__c == null) ? '<b>' + Schema.Account.Field.Nielsen_Area__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Agency__c == null) ? '<b>' + Schema.Account.Field.Agency__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Bank__c == null) ? '<b>' + Schema.Account.Field.Bank__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.CNPJ__c == null) ? '<b>' + Schema.Account.Field.CNPJ__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Payment_Condition__c == null) ? '<b>' + Schema.Account.Field.Payment_Condition__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Checking_account__c == null) ? '<b>' + Schema.Account.Field.Checking_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Current_account__c == null) ? '<b>' + Schema.Account.Field.Current_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.State_Registration__c == null) ? '<b>' + Schema.Account.Field.State_Registration__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Payment_instrument__c == null) ? '<b>' + Schema.Account.Field.Payment_instrument__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Customer_Geographic_Region__c == null) ? '<b>' + Schema.Account.Field.Customer_Geographic_Region__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Regional__c == null) ? '<b>' + Schema.Account.Field.Regional__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                
                acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Business_Unit__c == null) ? '<b>' + Schema.Account.Field.Business_Unit__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                
                // COMMENTED UNTIN NEW SEGMENTATION
                //acc.LAT_InformationUnfilled__c += (acc.Rating_segmentation_targert_market__c == null) ? '<b>' + Schema.Account.Field.Rating_segmentation_targert_market__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Segmentation_Type_on_trade__c == null) ? '<b>' + Schema.Account.Field.Segmentation_Type_on_trade__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Subtype__c == null) ? '<b>' + Schema.Account.Field.Subtype__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Sub_Channel_Rating__c == null) ? '<b>' + Schema.Account.Field.Sub_Channel_Rating__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.LAT_BR_BusinessSize__c == null) ? '<b>' + Schema.Account.Field.LAT_BR_BusinessSize__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
               
                if (!LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(acc.Id)){
                    System.debug('ENTER THE MATRIX2+++' );
                    acc.LAT_InformationUnfilled__c += '<b>' + 'Seção Segmentação' + '</b>' + '<br/>' ;
                }*/
                // if the account has a created lat account validate Credit analysis is created when 'DirectSales" is Checked
                if (acc.Type == 'COM FATURAMENTO' || acc.Type == 'VENDA DIRETA'){
                    acc.LAT_InformationUnfilled__c += (acc.Type != 'Outros' && acc.Credit_analysis__c <= 0) ? '<b>' + Schema.Account.Field.Credit_analysis__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                }
            }

            /*EVENTOS
            if (oldType.recordTypeDeveName == 'Eventos'){
            //if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Eventos')){
                
                acc.LAT_InformationUnfilled__c += (acc.Rating == null) ? '<b>' + Schema.Account.Field.Rating.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.CNPJ__c == null) ? '<b>' + Schema.Account.Field.CNPJ__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Status__c == null) ? '<b>' + Schema.Account.Field.Status__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Business_Unit__c == null) ? '<b>' + Schema.Account.Field.Business_Unit__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Corporate_Name__c == null) ? '<b>' + Schema.Account.Field.Corporate_Name__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Name == null) ? '<b>' + Schema.Account.Field.Name.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.Channel__c == null) ? '<b>' + Schema.Account.Field.Channel__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Regional__c == null) ? '<b>' + Schema.Account.Field.Regional__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.LAT_BR_RegionalClientOnPremise__c == null) ? '<b>' + Schema.Account.Field.LAT_BR_RegionalClientOnPremise__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_Address__c == null) ? '<b>' + Schema.Account.Field.Revenue_Address__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_Number__c == null) ? '<b>' + Schema.Account.Field.Revenue_Number__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_Neighbourhood__c == null) ? '<b>' + Schema.Account.Field.Revenue_Neighbourhood__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_City__c == null) ? '<b>' + Schema.Account.Field.Revenue_City__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_UF__c == null) ? '<b>' + Schema.Account.Field.Revenue_UF__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_Country__c == null) ? '<b>' + Schema.Account.Field.Revenue_Country__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Revenue_Postal_Code__c == null) ? '<b>' + Schema.Account.Field.Revenue_Postal_Code__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Bank__c == null) ? '<b>' + Schema.Account.Field.Bank__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Agency__c == null) ? '<b>' + Schema.Account.Field.Agency__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Checking_account__c == null) ? '<b>' + Schema.Account.Field.Checking_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Current_account__c == null) ? '<b>' + Schema.Account.Field.Current_account__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += (acc.State_Registration__c == null) ? '<b>' + Schema.Account.Field.State_Registration__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += (acc.Payment_instrument__c == null) ? '<b>' + Schema.Account.Field.Payment_instrument__c.getDescribe().getLabel() + '</b>' + '<br/>' : '';
                if (!LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(acc.Id)){
                    System.debug('ENTER THE MATRIX2+++' );
                    acc.LAT_InformationUnfilled__c += '<b>' + 'Seção Segmentação' + '</b>' + '<br/>' ;
                }
            }
            if(acc.LAT_InformationUnfilled__c != ''){
                acc.LAT_InformationUnfilled__c = '<span style="color: red;">' + acc.LAT_InformationUnfilled__c + '</span>';
            }  */        
            System.debug('%%%%%%% acc.LAT_InformationUnfilled__c al final ' + acc.LAT_InformationUnfilled__c );           
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: updatesBillingShippingBankFields
    * Descripcion: Updates fields Billing_UF__c / Billing_City_Code__c / Shipping_UF__c / Shipping_City_Code__c / Bank_number__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 19/02/2014
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void updatesBillingShippingBankFields(List<Account> triggerNew, Map<Id,Account> oldMap){
    /*
        Set<Id> setUdcIds = new Set<Id>();
        
        for(Account acc: triggerNew){
            if(trigger.isInsert || (trigger.isUpdate && acc.Billing_City__c != oldMap.get(acc.Id).Billing_City__c)){
                setUdcIds.add(acc.Billing_City__c);
            }
            if(trigger.
             || (trigger.isUpdate && acc.Shipping_City__c != oldMap.get(acc.Id).Shipping_City__c)){
                setUdcIds.add(acc.Shipping_City__c);
            }
            if(trigger.isInsert || (trigger.isUpdate && acc.Bank__c != oldMap.get(acc.Id).Bank__c)){
                setUdcIds.add(acc.Bank__c );
            }
        }
        
        if(!setUdcIds.isEmpty()){
            Map<Id,UDC__c> mapUDC = new Map<Id,UDC__c>([SELECT Id, Descricao2__c , CodDefUsuario__c FROM UDC__c WHERE Id IN: setUdcIds]);
        
            for(Account acc: triggerNew){
                if(mapUDC.containsKey(acc.Billing_City__c)){
                    acc.Billing_UF__c = mapUDC.get(acc.Billing_City__c).Descricao2__c;
                    acc.Billing_City_Code__c = mapUDC.get(acc.Billing_City__c).CodDefUsuario__c;
                }
                if(mapUDC.containsKey(acc.Shipping_City__c)){
                    acc.Shipping_UF__c = mapUDC.get(acc.Shipping_City__c).Descricao2__c;
                    acc.Shipping_City_Code__c = mapUDC.get(acc.Shipping_City__c).CodDefUsuario__c;
                }
                if(mapUDC.containsKey(acc.Bank__c)){
                    acc.Bank_number__c = mapUDC.get(acc.Bank__c).CodDefUsuario__c;
                }
            }
        }*/
    }


    /*********************************************************************************************************
    * Nombre del metodo: updatesAreaRegionalManager
    * Descripcion: Updates fields Area_Manager__c and Regional_Manager__c on Segmentation when they change in Account
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 02/06/2014
    * Modo: After Update
    *********************************************************************************************************/
    public static void updatesAreaRegionalManager(List<Account> triggerNew, Map<Id,Account> oldMap){
       
        Set<Id> setAccountIds = new Set<Id>();
        for(Account acc: triggerNew){
            if(acc.Area_Manager__c != oldMap.get(acc.Id).Area_Manager__c || acc.Regional_Manager__c != oldMap.get(acc.Id).Regional_Manager__c){
                setAccountIds.add(acc.Id);
            }
        }
        if(!setAccountIds.isEmpty()){
            List<LAT_BR_ClientChannelSegmentation__c> listSeg = [SELECT Id, LAT_BR_AreaManager__c, LAT_BR_RegionalManager__c, LAT_BR_Client__c, LAT_BR_ApprovalStatus__c FROM LAT_BR_ClientChannelSegmentation__c WHERE LAT_BR_Client__c IN: setAccountIds AND (LAT_BR_ApprovalStatus__c = 'Rejected' OR LAT_BR_ApprovalStatus__c = 'Draft')];
            Map<Id,List<LAT_BR_ClientChannelSegmentation__c>> mapAccIdSegs = new Map<Id,List<LAT_BR_ClientChannelSegmentation__c>>();
            
            if(!listSeg.isEmpty()){
                for(LAT_BR_ClientChannelSegmentation__c seg: listSeg){
                    if(!mapAccIdSegs.containsKey(seg.LAT_BR_Client__c)){
                        mapAccIdSegs.put(seg.LAT_BR_Client__c,new List<LAT_BR_ClientChannelSegmentation__c> {seg});
                    }else{
                        mapAccIdSegs.get(seg.LAT_BR_Client__c).add(seg);
                    }
                }
            }
            
            List<LAT_BR_ClientChannelSegmentation__c> listSegsToUpdate = new List<LAT_BR_ClientChannelSegmentation__c>();
            
            for(Account acc: triggerNew){
                if(setAccountIds.contains(acc.Id) && mapAccIdSegs.containsKey(acc.Id)){
                    for(LAT_BR_ClientChannelSegmentation__c seg: mapAccIdSegs.get(acc.Id)){
                        seg.LAT_BR_AreaManager__c = acc.Area_Manager__c;
                        seg.LAT_BR_RegionalManager__c = acc.Regional_Manager__c;
                        listSegsToUpdate.add(seg);
                    }
                }
            }
            
            try{
                update listSegsToUpdate;
            }catch(DMLException e){
            
            }
        }
    }

    /*********************************************************************************************************
    * If the account is Not approve go back to the previous status (if rating!=novo cadastro)
    *********************************************************************************************************/
    public static void updateStatusIfReprovado(List<Account> triggerNew, Map<Id,Account> oldMap, Map<Id,Lat_account__c> accountIdToLatAccount,Map<Id,List<LAT_BR_ClientChannelSegmentation2__c>> segmentationsByAccId,Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> segmentationsResultByAccId){
            system.debug(accountIdToLatAccount);
            Set<LAT_BR_ClientChannelSegmentation2__c> segmToUpdate = new Set<LAT_BR_ClientChannelSegmentation2__c>();
            Set<LAT_BR_ClientChannelSegmentation2Result__c> segmResultToUpdate = new Set<LAT_BR_ClientChannelSegmentation2Result__c>();
            List<LAT_ACCOUNT__c> latAccToUpdate = new List<LAT_ACCOUNT__c>();
            for(Account acc: triggerNew){
                Boolean hasDraft = false;
                LAT_BR_ClientChannelSegmentation2__c draftclient;
                LAT_BR_ClientChannelSegmentation2__c activeSegm;
                if(segmentationsByAccId.get(acc.Id) != null){
                    for (LAT_BR_ClientChannelSegmentation2__c seg:segmentationsByAccId.get(acc.Id)){
                        system.debug('segmeent: ' + seg.Id + seg.Status__c);
                        if (seg.Status__c == 'Draft'){
                            system.debug('agarro draft+++');
                            hasDraft = true;
                            draftclient = seg;
                        } else if (seg.Status__c == 'Active'){
                            system.debug('agarro active+++');
                            activeSegm = seg;
                        }
                    }

                    if(draftclient == null && activeSegm != null){
                        draftclient = activeSegm;
                        draftclient.status__c = 'Draft';
                    }
                }
                system.debug('accStattus: '+  acc.Status__c);
                system.debug('accStattus: '+  oldMap.get(acc.Id).Status__c);
                system.debug('hasDraft: '+  hasDraft);
                system.debug(acc.Status__c == 'Em análise - Customer Service' && oldMap.get(acc.Id).Status__c =='Em aprovação  - Comercial');
                system.debug(acc.Status__c == 'Em análise - Customer Service');
                system.debug(oldMap.get(acc.Id).Status__c =='Em aprovação - Comercial');

                if(acc.Status__c != oldMap.get(acc.Id).Status__c){
                    if(segmentationsResultByAccId.get(acc.Id) != null)
                        segmentationsResultByAccId.get(acc.Id).LAT_IsRevert__c = true;//
                    //if this is the case, the client was approve we dont need to send to case generation
                    if(acc.Status__c == 'Em análise - Customer Service' && acc.Rating == 'Cliente Ativo'){
                        acc.Status__c = 'Aprovado - Aguardando retorno do JDE';

                        system.debug('draftclient.Channel__c,draftclient.Client_type__c: ' + draftclient.Channel__c +' <<<>>> '+ draftclient.Client_type__c);

                        acc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(draftclient.Channel__c,draftclient.Client_type__c);
                        acc.Rating = 'Cliente Ativo';
                        activateSegmentation(draftclient, segmentationsResultByAccId.get(acc.Id), activeSegm);
                        segmToUpdate.add(draftclient);
                        if(activeSegm!= null){
                            segmToUpdate.add(activeSegm);
                        }
                        //call handler.after method
                        system.debug('isAfterUpdate++++');
                        
                        segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                        LAT_BR_SegmentationBehaviorHandler.notificateManagers(segmentationsResultByAccId.get(acc.Id));
                    } else if (acc.Status__c == 'Em análise - Customer Service' && oldMap.get(acc.Id).Status__c =='Em aprovação  - Comercial'){
                        system.debug('entronotify+++');
                        LAT_BR_SegmentationBehaviorHandler.notificateManagers(segmentationsResultByAccId.get(acc.Id));
                    }
                    // if sem pagamento aprovado
                    if(acc.Status__c == 'Cliente cadastrado no CRM' && oldMap.get(acc.Id).Status__c =='Em aprovação  - Comercial'){
                        acc.Rating = 'Cliente Ativo';
                        system.debug('entro+++' + draftclient);
                        if(hasDraft){
                            system.debug('entro2');
                            acc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(draftclient.Channel__c,draftclient.Client_type__c);
                            activateSegmentation(draftclient, segmentationsResultByAccId.get(acc.Id), activeSegm);
                            segmToUpdate.add(draftclient);
                            if(activeSegm!= null){
                                segmToUpdate.add(activeSegm);
                            }
                            segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                        }
                    } else if ((acc.Status__c == 'Cliente cadastrado no CRM' && oldMap.get(acc.Id).Status__c =='Cliente cadastrado no CRM') &&
                        (acc.Status__c == 'Cliente Ativo' && oldMap.get(acc.Id).Status__c =='Cliente inativo')){
                        //acc.Rating = 'Cliente';
                        system.debug('entro3');
                        if(hasDraft){
                            acc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(draftclient.Channel__c,draftclient.Client_type__c);
                            activateSegmentation(draftclient, segmentationsResultByAccId.get(acc.Id), activeSegm);
                            segmToUpdate.add(draftclient);
                            if(activeSegm!= null){
                                segmToUpdate.add(activeSegm);
                            }
                            segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                        }
                    } else if (acc.Status__c == 'Não Aprovado' && oldMap.get(acc.Id).Status__c !='Não Aprovado' && hasDraft){
                        system.debug('entro+++' + draftclient);
                        system.debug('STATUSNOWAPPROVE+++  ' + Acc.Status__c);
                        
                        acc.Status__c = accountIdToLatAccount.get(acc.Id).LAT_Status_Before_Approval__c;
                        revertSegmentation(segmentationsResultByAccId.get(acc.Id),accountIdToLatAccount.get(acc.Id));
                        segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                        draftclient.Status__c = 'Inactive';
                        segmToUpdate.add(draftclient);
                        //if (accountIdToLatAccount.get(acc.Id).LAT_Approval_Revert_RecordType__c){
                            
                            acc.Status__c = accountIdToLatAccount.get(acc.Id).LAT_Status_Before_Approval__c;
                            system.debug('STATUSANTESPARACAMBIAR APPROVE+++  ' + acc.Status__c);
                            acc.RecordTypeId = accountIdToLatAccount.get(acc.Id).LAT_RtId_Before_Approval__c;
                            latAccToUpdate.add(new LAT_ACCOUNT__c(Id = accountIdToLatAccount.get(acc.Id).Id, LAT_Approval_Revert_RecordType__c = false));
                            draftclient.Status__c = 'Inactive';
                            segmToUpdate.add(draftclient);
                            
                    // } 
                    } else if(acc.Status__c == 'Aprovado - Aguardando retorno do JDE' && oldMap.get(acc.Id).Status__c !='Aprovado - Aguardando retorno do JDE' && hasDraft){
                        acc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(draftclient.Channel__c,draftclient.Client_type__c);
                        acc.Rating = 'Cliente Ativo';
                        activateSegmentation(draftclient, segmentationsResultByAccId.get(acc.Id), activeSegm);
                        segmToUpdate.add(draftclient);
                        if(activeSegm!= null){
                            segmToUpdate.add(activeSegm);
                        }
                        //call handler.after method
                        system.debug('isAfterUpdate++++');
                        
                        segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                    } else if(acc.Status__c == 'TBCI - Reprovado'){
                        revertSegmentationTBCIReprovado(segmentationsResultByAccId.get(acc.Id),accountIdToLatAccount.get(acc.Id));
                        segmResultToUpdate.add(segmentationsResultByAccId.get(acc.Id));
                        acc.Status__c = accountIdToLatAccount.get(acc.Id).LAT_Status_Before_Approval__c;
                    } else if(acc.Status__c == 'TBCI - Aprovado'){
                        LAT_BR_SegmentationBehaviorHandler.notificateManagers(segmentationsResultByAccId.get(acc.Id));
                        acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
                    }
                }
            }
            if (!latAccToUpdate.isEmpty()){
                update latAccToUpdate;
            }
            if (!segmToUpdate.isEmpty()){
                List<LAT_BR_ClientChannelSegmentation2__c> segmUpdList = new List<LAT_BR_ClientChannelSegmentation2__c>();
                segmUpdList.addAll(segmToUpdate);
                update segmUpdList;
            }

            if (!segmResultToUpdate.isEmpty()){
                List<LAT_BR_ClientChannelSegmentation2Result__c> segmResultUpdList = new List<LAT_BR_ClientChannelSegmentation2Result__c>();
                segmResultUpdList.addAll(segmResultToUpdate);
                update segmResultUpdList;
            }
        }

    // revert segm if not approved
    public static void revertSegmentation(LAT_BR_ClientChannelSegmentation2Result__c segm,Lat_account__c latac){
        segm.Beneficio_Fiscal__c =  latac.Beneficio_Fiscal_revert__c;
        segm.Channel__c = latac.Channel_revert__c;
        segm.Client_type__c = latac.Client_type_revert__c;
        segm.Estrategia_comercial__c = latac.Estrategia_comercial_revert__c;
        segm.FORMATO__c = latac.FORMATO_revert__c;
        segm.Sub_channel__c = latac.Sub_channel_revert__c;
        segm.PRIOR_DE_INVESTIMENTO__c = latac.PRIOR_DE_INVESTIMENTO_revert__c;
        segm.Perfil__c = latac.Perfil_revert__c;
        segm.Segment__c = latac.Segment_revert__c;
        segm.TBCI__c = latac.TBCI_revert__c;
        segm.Obtained_POLiTICA_DE_PRECO_Udc__c = latac.Obtained_POLiTICA_DE_PRECO_Udc_revert__c;
        segm.Politica_Preco_Origin__c = latac.Politica_Preco_Origin_revert__c;
        //res.Politica_Preco_Origin__c = latac.Id;
        segm.LAT_IsRevert__c = true;    
    }

    // activate segm if approved
    public static void revertSegmentationTBCIReprovado(LAT_BR_ClientChannelSegmentation2Result__c segm,Lat_account__c latac){
        segm.TBCI__c = latac.TBCI_revert__c;
        segm.Obtained_POLiTICA_DE_PRECO_Udc__c = latac.Obtained_POLiTICA_DE_PRECO_Udc_revert__c;
        segm.LAT_IsRevert__c = true;
    }

    // activate segm if approved
    public static void activateSegmentation(LAT_BR_ClientChannelSegmentation2__c draftclient, LAT_BR_ClientChannelSegmentation2Result__c segmResult,LAT_BR_ClientChannelSegmentation2__c activeSegm){
        draftclient.Status__c = 'Active';
        segmResult.Client_Segmentation_2__c = draftclient.Id;
        segmResult.sub_channel__c = draftclient.sub_channel__c;
        segmResult.Beneficio_Fiscal__c = draftclient.Beneficio_Fiscal__c;
        segmResult.Channel__c = draftclient.Channel__c;
        segmResult.Client_type__c = draftclient.Client_type__c;
        segmResult.Estrategia_comercial__c = draftclient.Estrategia_comercial__c;
        segmResult.FORMATO__c = draftclient.FORMATO__c;
        segmResult.Perfil__c = draftclient.Perfil__c;
        segmResult.POLiTICA_DE_PRECO__c = draftclient.POLiTICA_DE_PRECO__c;
        segmResult.PRIOR_DE_INVESTIMENTO__c = draftclient.PRIOR_DE_INVESTIMENTO__c;
        segmResult.Segment__c = draftclient.Segment__c;
        segmResult.Obtained_Layout__c =LAT_BR_SegmentationBehaviorHandler.getLayoutSet(draftclient.Channel__c,draftclient.Client_type__c);
        if(activeSegm!= null){
            activeSegm.Status__c = 'Inactive';
        }
    }
    /*****************************************************************************************
    * Nombre del metodo: updateUFFieldsFromUDC
    * Descripcion: This method completes UF and bank fields on account based on UDC and 
    *              deactivate workflow 'Atualiza banco e UF conforme UDC'
    * Desarrollador: Mariano Boezio
    * Fecha: 26/09/2014
    * Modo:  Before Insert, Before Update
    *****************************************************************************************/
    public static void updateUFFieldsFromUDC(List<Account> triggerNew, map<Id,Account> oldMap){
        String Country = [SELECT Country FROM User WHERE id =: userinfo.getUserId() LIMIT 1].Country;
        Set<String> udcIds = new Set<String>();

        for (Account acc:triggerNew) {
            udcIds.add(acc.Revenue_City__c);
            udcIds.add(acc.Bank__c);
        }

        Map<id, UDC__c> udcs = new Map<id, UDC__c>([SELECT id, Descricao2__c, CodDefUsuario__c 
                                                        FROM UDC__c WHERE id IN: udcIds]);

        for (Account acc: triggerNew/*[SELECT id, Revenue_City__r.CodDefUsuario__c, Revenue_City__r.Descricao2__c,
                                     Bank__r.CodDefUsuario__c, Shipping_UF__c, Revenue_UF__c,
                                     Billing_UF__c, Revenue_City_Code__c, Shipping_City_Code__c,
                                     Bank_number__c, Revenue_Country__c, Shipping_Country__c,
                                     Billing_Country__c
                                 FROM Account WHERE id IN: triggerNew]*/) {
            acc.Revenue_UF__c = udcs.get(acc.Revenue_City__c) != null ? udcs.get(acc.Revenue_City__c).Descricao2__c : null; //acc.Revenue_City__r.Descricao2__c;
            acc.Revenue_City_Code__c = udcs.get(acc.Revenue_City__c) != null ? udcs.get(acc.Revenue_City__c).CodDefUsuario__c: null;
            acc.Bank_number__c = udcs.get(acc.Bank__c) != null ? udcs.get(acc.Bank__c).CodDefUsuario__c : null;
            //acc.Revenue_Country__c = Country;
            acc.Shipping_Country__c = acc.Shipping_UF__c != null ? Country : null;
            acc.Billing_Country__c = acc.Shipping_UF__c != null ? Country : null;

            System.debug('acc.Revenue_UF__c++++' + acc.Revenue_UF__c);
            system.debug('acc.Revenue_City_Code__c++++' + acc.Revenue_City_Code__c);
            system.debug('acc.Bank_number__c++++' + acc.Bank_number__c);
            system.debug('acc.Shipping_Country__c++++' + acc.Shipping_Country__c);
            system.debug('acc.Billing_Country__c++++' + acc.Billing_Country__c);
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: customerInterfaceCall
    * Descripcion: 
    * Desarrollador: Nicolas Watroba
    * Fecha: 26/09/2014
    * Modo:  After Insert, After Update
    *****************************************************************************************/
    public static void customerInterfaceCall(List<Account> triggerNew) {
        final String ENVIAR_ACTION = 'Aprovado - Aguardando retorno do JDE';
        final String APROVADO_ACTION = 'Cliente cadastrado no JDE';
        List<String> accIds = new List<String>();

        // Check if this trigger is bypassed by SESAME (data migration Brazil)
        if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
            Set <String> setAN8 = new Set<String>();
            // JDE Integration
            for (Account a : triggerNew) {
                if (ENVIAR_ACTION.equalsIgnoreCase(a.Status__c)) {
                    System.debug(System.LoggingLevel.ERROR,'ERNESTO3++++');
                    if (LAT_WS_Utils.getWSEndpoint('1').startsWith('https')) {
                        System.debug(System.LoggingLevel.ERROR,'ERNESTO4++++');
                        accIds.add(String.valueof(a.Id));
                    } else {
                        System.debug(System.LoggingLevel.ERROR,'ERNESTO5++++');
                        CustomerHandlerInterface.CustomerInterfaceJDE(String.valueof(a.Id));
                    }
                } else if (APROVADO_ACTION.equalsIgnoreCase(a.Status__c)) {
                    System.debug(System.LoggingLevel.ERROR,'ERNESTO66++++');
                    setAN8.add( a.Client_code_AN8__c );
                }
            }

            if(accIds.size() > 0)LAT_WS_CustomerHandlerInterface.updateCustomerStatus(accIds);
            for(String s : accIds){
                System.debug(System.LoggingLevel.ERROR,'ERNESTO7++++' + s );
                LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE(s);  
            }
            
            // Suppliers clean up
            if (!setAN8.isEmpty()) {
                Id recordTypeFornecedor = Global_RecordTypeCache.getRtId('Fornecedor__c'+'BRA_Standard');
                List <Fornecedor__c> listFornecedor = [ SELECT Codigo_do_Fornecedor_AN8__c 
                                                            FROM Fornecedor__c 
                                                            WHERE Codigo_do_Fornecedor_AN8__c =: setAN8 
                                                            AND RecordTypeId =: recordTypeFornecedor];
                for (Fornecedor__c forn : listFornecedor) {
                    setAN8.remove( forn.Codigo_do_Fornecedor_AN8__c );
                }
            
                listFornecedor = new List< Fornecedor__c >();
                
                // Insert separate suppliers
                for (Account a : triggerNew) {
                    if (APROVADO_ACTION.equalsIgnoreCase(a.Status__c) && setAN8.contains(a.Client_code_AN8__c)) {
                        Fornecedor__c forn = new Fornecedor__c();
                        forn.Name = a.Name;
                        forn.Razao_social__c = a.Corporate_Name__c;
                        forn.Codigo_do_Fornecedor_AN8__c = a.Client_code_AN8__c;
                        forn.Telefone__c = a.Phone;
                        forn.CNPJ__c = a.CNPJ__c;
                        forn.RecordTypeId = recordTypeFornecedor;
                        listFornecedor.add(forn);
                    }
                }
                if (!listFornecedor.isEmpty()) insert listFornecedor;
            }
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: setRatingActiveClient
    * Descripcion: Si el cliente es registrado correctamente en JDE, generando un AN8, se setea el Rating para 'Cliente Ativo'
    * Desarrollador: Javier Fagian
    * Fecha: 14/03/2019
    * Modo:  Before Update
    *****************************************************************************************/
    public static void setRatingActiveClient(List<Account> triggerNew, Map<Id,Account> oldMap){
        for(Account acc : triggerNew) {
            if(acc.Client_country_an8__c <> null && oldMap.get(acc.Id).Client_country_an8__c == null) {
                acc.Rating = 'Cliente Ativo';
            }
        }
    }
  
}