/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRA del objeto Account
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class AP01_Account_AR {
    public static map<Id, RecordType> mapIdRt = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('Account'));
    public static set<Id> accountsInInterface;
    public static Boolean alreadyUpdated = false;
    public static UDC__c defaultPaymentInstrumentUY;
    public static UDC__c defaultPaymentInstrumentAR;

    /*****************************************************************************************
    * Nombre del metodo: UpdateCNPJChildAccount
    * Descripcion: Si la cuenta tiene padre, se copia el cnpj del padre al hijo
    * Desarrollador: Tomas Garcia Etchegaray
    * Fecha: 11/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void UpdateCNPJChildAccount (List<Account> triggerNew){
        set<Id> setParentIds = new set<Id>();
        for (Account acc: triggerNew){
                setParentIds.add(acc.ParentId);
        }
        map<Id, Account> mapParentAccount = new map<Id, Account>([SELECT Id, CNPJ__c FROM Account WHERE Id IN: setParentIds]);
        for (Account acc: triggerNew){
            if(acc.ParentId != null){
                if(mapParentAccount.containsKey(acc.ParentId)){
                    acc.CNPJ__c = mapParentAccount.get(acc.ParentId).CNPJ__c;
                } else {
                    acc.adderror(label.AP01_00014_AR);
                }
            }
        }
    }


    /*****************************************************************************************
    * Nombre del metodo: ValidationCNPJduplicateARG
    * Descripcion: Valida que no se inserten cnpj duplicados
    * Desarrollador: Tomás Garcia Etchegaray
    * Fecha: 11/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void ValidationCNPJduplicateARG (List<Account> triggerNew, String UpdateOinsert){

        list<account> accSincheckParents = new list<account>();
        list<account> accSincheckSons = new list<account>();
        list<account> accConcheck = new list<account>();
        list<account> accOrdenada = new list<account>();
        set<string> setcnpjRepes = new set<string>();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (Triggernew[i].ParentId == null && Triggernew[i].SaveDuplicatedFiscalID_AR__c == false ){  //(si ES padre y NO tiene el check en true)
                accSincheckParents.add(Triggernew[i]);
            }
            if (Triggernew[i].ParentId != null ){  //(si ES hijo y NO tiene el check en true)
                accSincheckSons.add(Triggernew[i]);
            }
            if (Triggernew[i].SaveDuplicatedFiscalID_AR__c == true && Triggernew[i].ParentId == null  ){  //(SI tiene el check en true)
                accConcheck.add(Triggernew[i]);
            }
        }

        //INSERTO TODAS LAS ACCOUNT EN TRIGGER NEW PERO EN ORDEN.
        for (Account acc : accSincheckParents){
            accOrdenada.add(acc);
        }
        for (Account acc : accSincheckSons){
            accOrdenada.add(acc);
        }
        for (Account acc : accConcheck){
            accOrdenada.add(acc);
        }

        //este es el primer FOR y lo que hace es chequear que no entren cnpj duplicados EN TRIGGER NEW, en el otro for se compara con la base de datos.
        for (Account acc : accOrdenada){
            if ( !setcnpjRepes.Contains(acc.CNPJ__c) ){
                setcnpjRepes.add(acc.CNPJ__c);
            }else{
                //se agrego esta condicion porque el Cliente Hijo tiene el CNPJ del Padre (modificado por Elena Schwarzböck 30/04/13, se agrego la segunda //condicion el 26/06/13)
                if(acc.ParentId == NULL && acc.SaveDuplicatedFiscalID_AR__c == false){
                    acc.adderror(  label.AP01_00002_AR + acc.CNPJ__c );
                }
            }
        }
        set<string> setArg = new set<string>();
        for(Account acc: accOrdenada){
            if(acc.ParentId == null){
                setArg.add(acc.CNPJ__c);
            }
        }

        set<Id> setRTIdsAR = Global_RecordTypeCache.getRtIdSet('Account', new Set<String>{'ACC_1_OffTrade_ARG', 'ACC_3_OnTrade_ARG', 'ACC_5_Events_ARG', 'ACC_2_OffTrade_URU', 'ACC_4_OnTrade_URU', 'ACC_6_Events_URU'});
        list<Account> cuentasBAseDAtosARG = new list<Account>();
        if (UpdateOinsert == 'insert'){
            cuentasBaseDatosARG = ([SELECT Id, CNPJ__c, OwnerId,Client_code_AN8__c FROM Account WHERE (RecordTypeId IN: setRTIdsAR) AND (cnpj__c IN: setArg) AND (ParentId =: null)]);
        }else{
            cuentasBaseDatosARG = ([SELECT Id, CNPJ__c, OwnerId,Client_code_AN8__c FROM Account WHERE (RecordTypeId IN: setRTIdsAR) AND (cnpj__c IN: setArg) AND (ParentId =: null) AND (id NOT IN: triggerNew)]);
        }

        map<String,Account> mapCnpjAcc = new map<String,Account>();
        set<id> setID = new set<id>();
        if (!cuentasBAseDAtosARG.isEmpty()){
            for (Account acc : cuentasBAseDAtosARG){
                mapCnpjAcc.put(acc.CNPJ__c , acc);
                setID.add(acc.OwnerId);
            }
        }

        map< id , User > idOwner = new map<id , User >([SELECT Id, Name FROM User where id IN : setID ]);
        for (Account acc : accOrdenada){
            if(acc.ParentId == null){
                if( mapCnpjAcc.containsKey(acc.CNPJ__c)  && acc.SaveDuplicatedFiscalID_AR__c == false){
                    acc.adderror(label.AP01_00001_AR + idOwner.get(mapCnpjAcc.get(acc.CNPJ__c).OwnerId).Name + ' ' +  label.AP01_00003_AR  + mapCnpjAcc.get(acc.CNPJ__c).Client_code_AN8__c + ' ' + label.AP01_00013_AR );
                }
            }
        }
    }


    /*****************************************************************************************
    * Nombre del metodo: ValidationCreditLine
    * Descripcion: Método que valida datos durante el proceso de aprobación.
    * Desarrollador: Elena Schwarzböck Modificado por Tomás Garcia E.
    * Fecha: 22/03/2013
    * Modo: before updat
    *****************************************************************************************/
    public static void ValidationCreditLine (List<Account> triggerNew, map<Id, Account> triggerOldMap){
        set<Id> setIdsAllAccount =  new set<Id>();

        for (Account acc: triggerNew){
            setIdsAllAccount.add(acc.Id);
        }

        set<Id> setIdAccounts=  new set<Id>();
        for(ProcessInstance pi: [SELECT Id, TargetObjectId, Status, (SELECT Id FROM Workitems) FROM ProcessInstance WHERE TargetObjectId IN: setIdsAllAccount]){
            if (!pi.Workitems.isEmpty() ){
                setIdAccounts.add(pi.TargetObjectId);
            }
        }
        set<Id> setParentId = new set<Id>();
        set<Id> setaccId = new set<Id>();

        for (Account acc: triggerNew){
            if (setIdAccounts.contains(acc.id) ){
                setParentId.add(acc.ParentId);
                setaccId.add(acc.id);
            }
            if( Test.isRunningTest()){
                setIdAccounts.add(acc.Id);
            }
        }

        map<Id, Account> mapIdAccount = new map<Id, Account>([SELECT Id, Client_code_AN8__c FROM Account WHERE Id IN: setParentId]);
        map<id, CRA_CredAnalysis_ARG__c> mapidaccCredit = new map <id, CRA_CredAnalysis_ARG__c>();

        for(Account myacc: [SELECT  Id, (SELECT id, CreditLimitGranted_ARG__c FROM Credits_Analysis__r ORDER BY CreatedDate desc LIMIT 1) FROM Account WHERE Id in: setaccId]){
            for(CRA_CredAnalysis_ARG__c cre: myacc.Credits_Analysis__r){
                mapidaccCredit.put(myacc.Id, cre );
            }
        }

        map<ID,User> usrGali = new map<ID,User>([SELECT Id, FirstName , LastName FROM User WHERE (IsActive = true) AND ((FirstName='Segundo' AND LastName= 'Galiano') OR (FirstName='Sebastian' AND LastName= 'Nasta'))]);
        Set <id> usrIDSSet = new Set<id>();
        usrIDSSet = usrGali.keySet();

        for (Account acc: triggerNew){
            if (setIdAccounts.contains(acc.id) ){
                if (mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_1_OffTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_3_OnTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_2_OffTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_4_OnTrade_URU' ){
                    if (acc.Credit_line__c == NULL && triggerOldMap.get(acc.id).Status__c == 'Em análise - Crédito e Cobrança' && acc.Status__c == 'Em aprovação - Financeiro') {
                        acc.adderror(label.AP01_00004_AR);
                    }
                    if (acc.Credit_line__c != NULL && acc.Credit_line__c < 1 && acc.Type == 'Sale_ARG' && acc.ParentId == NULL && triggerOldMap.get(acc.id).Status__c == 'Em análise - Crédito e Cobrança' && acc.Status__c == 'Em aprovação - Financeiro'){
                        acc.adderror(label.AP01_00006_AR);
                    }
                    if(acc.ParentId != NULL && mapIdAccount.get(acc.ParentId).Client_code_AN8__c == NULL && triggerOldMap.get(acc.id).Status__c == 'Em análise - Crédito e Cobrança' && acc.Status__c == 'Em aprovação - Financeiro'){
                        acc.adderror(label.AP01_00005_AR);
                    }
                    if(acc.ParentId == NULL && acc.type =='Sale_ARG' && triggerOldMap.get(acc.id).Status__c == 'Em análise - Crédito e Cobrança' && acc.Status__c == 'Em aprovação - Financeiro' ){
                         if(mapidaccCredit.containskey(acc.id)){
                            if(mapidaccCredit.get(acc.Id).CreditLimitGranted_ARG__c == 0 || mapidaccCredit.get(acc.Id).CreditLimitGranted_ARG__c == null){
                                acc.adderror(label.AP01_00011_AR);
                            }
                         }
                    }
                    if(usrIDSSet.contains(UserInfo.getUserId()) && (triggerOldMap.get(acc.id).Status__c != 'Account to review in JDE') && (acc.Status__c == 'Cliente cadastrado no JDE')){
                        acc.adderror(label.AP01_00012_AR);
                    }
                }
            }
        }
    }


    /*****************************************************************************************
    * Nombre del metodo: TrueToFalse
    * Descripcion: Si el overdue cambia de falso a verdadero se crea un caso y una tarea.
    * Desarrollador: Tomas Garcia Etchegaray / modificado por Elena J. Schwarzböck 24/05/2013
    * Fecha: 22/03/2013
    * Modo: before update
    *****************************************************************************************/
    //MIGRATED 02/11/2016 
    public static void TrueToFalse ( map<Id, Account> mapOld , List<Account> triggerNew ){
        //Migra wasMigrationDone
        if(!Utils.wasMigrationDone('6')){
            List<Account> accTocreateCase = new list<Account>();
            for (Account acc: triggerNew){
                if( mapOld.get(acc.Id).overdue__c != acc.overdue__c   ){
                    if( mapOld.get(acc.Id).overdue__c  == false){
                        accTocreateCase.add(acc);
                    }
                }
            }
            List<Case> caseToInsert = new List<Case>();
            List<Task> taskToInsert = new List<Task>();

            map<String,id> mapStringIDrt = new map<String,id>();
            mapStringIDrt.put('rtARGcase', Global_RecordTypeCache.getRtId('Case'+'CSE_OverdueAccount_AR'));
            mapStringIDrt.put('rtUYcase', Global_RecordTypeCache.getRtId('Case'+'CSE_OverdueAccount_UY'));
            mapStringIDrt.put('rtARGtask',Global_RecordTypeCache.getRtId('Task'+'TSK_Standard_AR'));
            mapStringIDrt.put('rtUYtask',Global_RecordTypeCache.getRtId('Task'+'TSK_Standard_UY'));

            for (Account acc: accTocreateCase){
                Case cas = new Case();
                cas.OwnerId = acc.OwnerId;
                cas.AccountId = acc.Id;
                cas.Type = 'Inadimplência';
                cas.Reason = 'Cliente inadimplente';
                cas.Subject = 'Cliente posee facturas en mora';
                cas.Description = 'Acción sugerida: entre en contacto con su cliente';
                cas.Priority = 'Medium';
                cas.Status = 'Análise pendente';

                if ( mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_1_OffTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_3_OnTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_5_Events_ARG'){
                    cas.RecordTypeId = mapStringIDrt.get('rtARGcase');
                }
                if (mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_2_OffTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_4_OnTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_6_Events_URU' ){
                     cas.RecordTypeId = mapStringIDrt.get('rtUYcase');
                }
                caseToInsert.add(cas);

                Task MyTask = new Task(
                Subject = 'Cliente con deuda en mora',
                OwnerId =  acc.OwnerId,
                WhatId = acc.Id,
                Status= 'No iniciado',
                ActivityDate = date.today().addDays(2),
                Priority = 'Normal',
                Description = 'El cliente fue identificado como moroso, por favor analice el caso para efectuar una negociación con el mismo.');

                if ( mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_1_OffTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_3_OnTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_5_Events_ARG'){
                       MyTask.RecordTypeId = mapStringIDrt.get('rtARGtask');
                }
                if (mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_2_OffTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_4_OnTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_6_Events_URU' ){
                     MyTask.RecordTypeId = mapStringIDrt.get('rtUYtask');
                }
                taskToInsert.add(MyTask);
            }

            insert caseToInsert;
            insert taskToInsert;
        }   
        else{
            List<Account> accTocreateCase = new list<Account>();
            for (Account acc: triggerNew){
                if( mapOld.get(acc.Id).overdue__c != acc.overdue__c   ){
                    if( mapOld.get(acc.Id).overdue__c  == false){
                        accTocreateCase.add(acc);
                    }
                }
            }
            List<LAT_Case__c> caseToInsert = new List<LAT_Case__c>();
            List<Task> taskToInsert = new List<Task>();

            map<String,id> mapStringIDrt = new map<String,id>();
            mapStringIDrt.put('rtARGcase', Global_RecordTypeCache.getRtId('LAT_Case__c'+'CSE_OverdueAccount_AR'));
            mapStringIDrt.put('rtUYcase', Global_RecordTypeCache.getRtId('LAT_Case__c'+'CSE_OverdueAccount_UY'));
            mapStringIDrt.put('rtARGtask',Global_RecordTypeCache.getRtId('Task'+'TSK_Standard_AR'));
            mapStringIDrt.put('rtUYtask',Global_RecordTypeCache.getRtId('Task'+'TSK_Standard_UY'));

            for (Account acc: accTocreateCase){
                LAT_Case__c cas = new LAT_Case__c();
                cas.OwnerId = acc.OwnerId;
                cas.LAT_Account__c = acc.Id;
                cas.LAT_Type__c = 'Inadimplência';
                cas.LAT_Reason__c = 'Cliente inadimplente';
                cas.LAT_Subject__c = 'Cliente posee facturas en mora';
                cas.LAT_Description__c = 'Acción sugerida: entre en contacto con su cliente';
                cas.LAT_Priority__c = 'Medium';
                cas.LAT_Status__c = 'Análise pendente';

                if ( mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_1_OffTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_3_OnTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_5_Events_ARG'){
                    cas.RecordTypeId = mapStringIDrt.get('rtARGcase');
                }
                if (mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_2_OffTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_4_OnTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_6_Events_URU' ){
                     cas.RecordTypeId = mapStringIDrt.get('rtUYcase');
                }
                caseToInsert.add(cas);

                Task MyTask = new Task(
                Subject = 'Cliente con deuda en mora',
                OwnerId =  acc.OwnerId,
                WhatId = acc.Id,
                Status= 'No iniciado',
                ActivityDate = date.today().addDays(2),
                Priority = 'Normal',
                Description = 'El cliente fue identificado como moroso, por favor analice el caso para efectuar una negociación con el mismo.');

                if ( mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_1_OffTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_3_OnTrade_ARG' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_5_Events_ARG'){
                       MyTask.RecordTypeId = mapStringIDrt.get('rtARGtask');
                }
                if (mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_2_OffTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_4_OnTrade_URU' || mapIdRt.get(acc.RecordTypeId).DeveloperName == 'ACC_6_Events_URU' ){
                     MyTask.RecordTypeId = mapStringIDrt.get('rtUYtask');
                }
                taskToInsert.add(MyTask);
            
            }
            insert caseToInsert;
            insert taskToInsert;
        }            
    }


    /*****************************************************************************************
    * Nombre del metodo: UpdateClientCountryAN8
    * Descripcion: Metodo que completa el campo Client_country_AN8__c
    * Desarrollador: Waldemar Mayo
    * Fecha: 30/04/2013
    * Modo: Before insert, Before Update
    *****************************************************************************************/
    public static void UpdateClientCountryAN8(List<Account> triggerNew, map<Id,Account> oldMap){

        Set<String> rtDevName_UY = new Set<String>{'ACC_4_OnTrade_URU', 'ACC_2_OffTrade_URU', 'ACC_6_Events_URU'};
        Set<String> rtDevName_ARG = new Set<String>{'ACC_3_OnTrade_ARG', 'ACC_1_OffTrade_ARG', 'ACC_5_Events_ARG'};

        for(Account acc: triggerNew){
            if(acc.Client_code_AN8__c!=null && acc.Client_code_AN8__c!=oldMap.get(acc.Id).Client_code_AN8__c){
                if(rtDevName_UY.contains(mapIdRT.get(acc.RecordTypeId).DeveloperName)){
                    acc.Client_country_AN8__c = '5-'+acc.Client_code_AN8__c;
                }
                if(rtDevName_ARG.contains(mapIdRT.get(acc.RecordTypeId).DeveloperName)){
                    acc.Client_country_AN8__c = '6-'+acc.Client_code_AN8__c;
                }
            }
        }
    }


    /*****************************************************************************************
    * Nombre del metodo: GrandSonValidate
    * Descripcion: Valida que no haya cuentas nieto.
    * Desarrollador: Garcia Etchegaray Tomas
    * Fecha: 20/05/2013
    * Modo:  After insert, After Update
    *****************************************************************************************/
    public static void GrandSonValidate(List<Account> triggerNew){

        Set<id> setIdsParent = new Set<id>();
        for (Account acc : triggerNew) {
            if(acc.ParentId!=null){
                setIdsParent.add(acc.ParentId);
            }
        }

        Set<id> setIdsParentWithParent = new Set<id>();
        for(Account accs: [SELECT id, Recordtype.developerName FROM Account where ParentId != null and Id IN: setIdsParent]){
            setIdsParentWithParent.add(accs.Id);
        }

        set<String> rtPermitidos = new set<String>();
        for(String key: mapIdRt.keySet()){
            if(mapIdRt.get(key).DeveloperName=='ACC_1_OffTrade_ARG' || mapIdRt.get(key).DeveloperName=='ACC_3_OnTrade_ARG' ||mapIdRt.get(key).DeveloperName=='ACC_5_Events_ARG' ||mapIdRt.get(key).DeveloperName=='ACC_2_OffTrade_URU' ||mapIdRt.get(key).DeveloperName=='ACC_4_OnTrade_URU' || mapIdRt.get(key).DeveloperName=='ACC_6_Events_URU'){
                rtPermitidos.add(key);
            }
        }

        for (Account acc : triggerNew) {
            if(acc.ParentId!=null && rtPermitidos.contains(acc.recordtypeid)){
                if(setIdsParentWithParent.contains(acc.ParentId)){
                    acc.adderror(label.AP01_00009_AR);
                }
            }
        }
    }


    /*****************************************************************************************
    * Nombre del metodo: customerInterfase
    * Descripcion: Metodo que realiza de envio del cliente para registracion en JDE
    * Desarrollador: Waldemar Mayo
    * Fecha: 30/04/2013
    * Modo: After Update
    *****************************************************************************************/
    public static void customerInterfase (List<Account> triggerNew, map<Id, Account> oldMap, Boolean isBatch){

        Set<String> rtDevName_UY = new Set<String>{'ACC_4_OnTrade_URU', 'ACC_2_OffTrade_URU', 'ACC_6_Events_URU'};
        Set<String> rtDevName_ARG = new Set<String>{'ACC_3_OnTrade_ARG', 'ACC_1_OffTrade_ARG', 'ACC_5_Events_ARG'};
        List<String> accIds = new List<String>();

        for (Account x : triggerNew) {
            if(rtDevName_UY.contains(mapIdRT.get(x.RecordTypeId).DeveloperName) || rtDevName_ARG.contains(mapIdRT.get(x.RecordTypeId).DeveloperName)){
                if(oldMap != null && x.Status__c != oldMap.get(x.Id).Status__c){
                    if( x.Status__c == 'Directed to be registered In JDE' && (x.Rating == 'Cliente' || x.Rating == 'Cliente inativo')){
                        if(accountsInInterface==null){
                            accountsInInterface = new set<Id>();
                        }
                        if(!accountsInInterface.contains(x.Id)){
                            accountsInInterface.add(x.Id);
                            if ((rtDevName_UY.contains(mapIdRT.get(x.RecordTypeId).DeveloperName) && LAT_WS_Utils.getWSEndpoint('5').startsWith('https'))
                                || (rtDevName_ARG.contains(mapIdRT.get(x.RecordTypeId).DeveloperName) && LAT_WS_Utils.getWSEndpoint('6').startsWith('https'))) {
                                    accIds.add(String.valueof(x.Id));

                            } else {
                                if(isBatch){
                                    WS02_CustomerHandlerInterface_AR.CustomerInterfaceJDESync(String.valueof(x.Id));
                                }else{
                                    WS02_CustomerHandlerInterface_AR.CustomerInterfaceJDE(String.valueof(x.Id));        
                                }
                            }
                        }
                    }
                }
            }
        }

        //if(accIds.size() > 0)LAT_WS_CustomerHandlerInterface.updateCustomerStatus(accIds);
        for(String s : accIds){

            LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE(s);        
                        
        }
    }


    /*********************************************************************************************************
    * Nombre del metodo: moneyConvertToUSD
    * Descripcion: Metodo que hace la conversion monetaria a dolares y la carga del campo Credir line USD
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 20/05/2013
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void moneyConvertToUSD (List<Account> triggerNew){

        if(triggerNew[0].LAT_BR_RegionalClientOnPremise__c == 'B2B' && triggerNew[0].Client_country_an8__c != null && triggerNew[0].Client_country_an8__c != '') return;
        String corpoISO;
        map<String, CurrencyType> mapOfCurrency = new map<String, CurrencyType>();

        for(CurrencyType ct :[SELECT IsoCode, ConversionRate, isCorporate FROM CurrencyType]){
            mapOfCurrency.put(ct.IsoCode, ct);
            if(ct.isCorporate){corpoISO = ct.IsoCode;}
        }

        for(Account acc :triggerNew){
            if(acc.Credit_line__c!=null && mapOfCurrency.containsKey('USD')){
                if(acc.CurrencyIsoCode=='USD'){
                    acc.Credit_line_USD_AR__c = acc.Credit_line__c;
                }else if(mapOfCurrency.get(acc.CurrencyIsoCode).isCorporate){
                    acc.Credit_line_USD_AR__c = acc.Credit_line__c*mapOfCurrency.get('USD').ConversionRate;
                }else if(mapOfCurrency.get('USD').isCorporate){
                    acc.Credit_line_USD_AR__c=acc.Credit_line__c/mapOfCurrency.get(acc.CurrencyIsoCode).ConversionRate;
                }else{
                    acc.Credit_line_USD_AR__c=(acc.Credit_line__c/mapOfCurrency.get(acc.CurrencyIsoCode).ConversionRate)*mapOfCurrency.get('USD').ConversionRate;
                }
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
            if((acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_1_OffTrade_ARG')) || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG')) 
                || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_5_Events_ARG')) || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_AR_Prospect'))){
                listLATAccount.add(new LAT_ACCOUNT__c(LAT_Accountid__c = acc.id, RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_AR_LAC_Standard')));
            }else if((acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_2_OffTrade_URU')) || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_4_OnTrade_URU')) || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_6_Events_URU'))){
                listLATAccount.add(new LAT_ACCOUNT__c(LAT_Accountid__c = acc.id, RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_UY_LAC_Standard')));
            }
        }
        insert listLATAccount;
    }

    /*********************************************************************************************************
    * Nombre del metodo: setDefaultPaymentInstrument
    * Descripcion: Setea el payment instrument por defecto si el mismo viene vacío
    * Desarrollador: Javier Fagian
    * Fecha: 21/12/2018
    * Modo: Before Insert / Before Update
    *********************************************************************************************************/
    public static void setDefaultPaymentInstrument(List<Account> triggerNew){
        List <LAT_ACCOUNT__c> listLATAccount = new List <LAT_ACCOUNT__c>();
        for(Account acc: triggerNew ){
            if((acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG')) || (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'ACC_4_OnTrade_URU'))) {
                if(acc.Payment_instrument__c == null){
                    acc.Payment_instrument__c = (getPaymentInstrumentDefaultUDC(acc.RecordTypeId)==null)?null : getPaymentInstrumentDefaultUDC(acc.RecordTypeId).Id;
                }
            }
        }
        insert listLATAccount;
    }

    public static UDC__c getPaymentInstrumentDefaultUDC(String recordtypeid){
        if(recordtypeid == Global_RecordTypeCache.getRtId('Account'+'ACC_4_OnTrade_URU')) {
            if(defaultPaymentInstrumentUY == null) {
                defaultPaymentInstrumentUY = [SELECT Id FROM UDC__c WHERE LAT_MX_FilterKey__c='PY-00-UY' AND Name = 'Blanco' LIMIT 1];
            }
            return defaultPaymentInstrumentUY;
        } else if(recordtypeid == Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG')){
            if(defaultPaymentInstrumentAR == null) {
                defaultPaymentInstrumentAR = [SELECT Id FROM UDC__c WHERE LAT_MX_FilterKey__c='PY-00-AR' AND Name = 'Blanco' LIMIT 1];
            }
            return defaultPaymentInstrumentAR;
        } else {
            return null;
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: updatesInformationUnfilled
    * Descripcion: required fiedls to be completed to be approved
    * Desarrollador: Denis Aranda
    * Fecha: 05/02/2014
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void updatesInformationUnfilled(List<Account> triggerNew){

        string recordTypeArgOn = Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG');
        string recordTypeArgOff = Global_RecordTypeCache.getRtId('Account'+'ACC_1_OffTrade_ARG');
        string recordTypeUruOn = Global_RecordTypeCache.getRtId('Account'+'ACC_4_OnTrade_URU');
        string recordTypeUruOff = Global_RecordTypeCache.getRtId('Account'+'ACC_2_OffTrade_URU');
        Map<String, String> mapAccountToUDC = new Map<String, String>();
        Map<String, String> mapAccountSubChannelToUDC = new Map<String, String>();

        List<String> listRevenueId = new List<String>();
        Set<String> subChannelVentasEspeciales = new Set<String>();

        String[] subcanales = LAT_GeneralConfigDao.getValueAsStringArray('SUB_CHANNEL_UY', ',');
        if(subcanales != null && subcanales.size()>0)subChannelVentasEspeciales.addAll(subcanales);



        for(Account acc: triggerNew){
            listRevenueId.add(acc.Revenue_City__c);
            listRevenueId.add(acc.Sub_Channel_Rating__c);
        }

        List<UDC__c> listAccountWithRevenue = [SELECT Id, Name, Descricao2__c FROM UDC__c WHERE id IN: listRevenueId];

        for(Account acc: triggerNew){
            for(UDC__c udc: listAccountWithRevenue){
                if(acc.Revenue_City__c == udc.id){
                    mapAccountToUDC.put(acc.id, udc.Descricao2__c);
                }
                if(acc.Sub_Channel_Rating__c == udc.id){
                    mapAccountSubChannelToUDC.put(acc.id, udc.Name);
                }
            }
        }

        map<string, Schema.SObjectField> works = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();

        for(Account acc: triggerNew){
            acc.LAT_InformationUnfilled__c = '';

            if(acc.RecordTypeId == recordTypeArgOn || acc.RecordTypeId == recordTypeUruOn){

                //acc.LAT_InformationUnfilled__c += acc.Rating_segmentation_targert_market__c == null && (acc.Segmentation_Type_on_trade__c == 'Bar_ARG' || acc.Segmentation_Type_on_trade__c == 'Restaurant_ARG' || acc.Segmentation_Type_on_trade__c == 'Disco_ARG') ? '- ' + works.get('Rating_segmentation_targert_market__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.State_Registration__c == null && acc.RecordTypeId == recordTypeArgOn && acc.Type == 'Sale_ARG' ? '- ID Fiscal Adicional <br/>' : '';
                acc.LAT_InformationUnfilled__c += acc.Credit_line__c == null ? '- ' + works.get('Credit_line__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.Regional_AR__c == null ? '- ' + works.get('Regional_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.Customer_Organization__c == null && acc.RecordTypeId == recordTypeUruOn ? '- ' + works.get('Customer_Organization__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CurrencyIsoCode == null ? '- ' + works.get('CurrencyIsoCode').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CollectionAgent_AR__c == null ? '- ' + works.get('CollectionAgent_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CustomerPriceGroup_AR__c == null ? '- ' + works.get('CustomerPriceGroup_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.SupRoute_AR__c == null ? '- ' + works.get('SupRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.ManRoute_AR__c == null ? '- ' + works.get('ManRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.DirecRoute_AR__c == null ? '- ' + works.get('DirecRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.TimRoute_AR__c == null ? '- ' + works.get('TimRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += mapAccountToUDC.get(acc.Id) == '1-BUENOS AIRES' && acc.ParentId != null && !acc.IsRebaComplete__c ? '- ' + works.get('IsRebaComplete__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += mapAccountSubChannelToUDC.get(acc.Id) != null && !subChannelVentasEspeciales.contains(mapAccountSubChannelToUDC.get(acc.Id)) && acc.CheckList_AR__c == null ? '- ' + works.get('CheckList_AR__c').getDescribe().getLabel() + '<br/>' :'';

            }else if(acc.RecordTypeId == recordTypeArgOff || acc.RecordTypeId == recordTypeUruOff){

                acc.LAT_InformationUnfilled__c += acc.Segmentation_Type_on_trade__c == 'POS Supermarkets_ARG' && acc.Rating_segmentation_targert_market__c == null ? '- ' + works.get('Rating_segmentation_targert_market__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.State_Registration__c == null && acc.RecordTypeId == recordTypeArgOff && acc.Type == 'Sale_ARG' ? '- ' + works.get('State_Registration__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.Credit_line__c == null ? '- ' + works.get('Credit_line__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.Regional_AR__c == null ? '- ' + works.get('Regional_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.Customer_Organization__c == null && acc.RecordTypeId == recordTypeUruOff ? '- ' + works.get('Customer_Organization__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CurrencyIsoCode == null ? '- ' + works.get('CurrencyIsoCode').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CollectionAgent_AR__c == null ? '- ' + works.get('CollectionAgent_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CustomerPriceGroup_AR__c == null ? '- ' + works.get('CustomerPriceGroup_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.SupRoute_AR__c == null ? '- ' + works.get('SupRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.AsistRoute_AR__c == null ? '- ' + works.get('AsistRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.ManRoute_AR__c == null ? '- ' + works.get('ManRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.DirecRoute_AR__c == null ? '- ' + works.get('DirecRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.TimRoute_AR__c == null ? '- ' + works.get('TimRoute_AR__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += mapAccountToUDC.get(acc.Id) == '1-BUENOS AIRES' && acc.ParentId != null && !acc.IsRebaComplete__c ? '- ' + works.get('IsRebaComplete__c').getDescribe().getLabel() + '<br/>' :'';
                acc.LAT_InformationUnfilled__c += acc.CheckList_AR__c == null ? '- ' + works.get('CheckList_AR__c').getDescribe().getLabel() + '<br/>' :'';

            }
        }
    }
}