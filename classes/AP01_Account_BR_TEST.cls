/******************************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck-Tomás Etchegaray  Date:21/03/2013    *
*******************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/


@istest
public with sharing class AP01_Account_BR_TEST {

    @testSetup
    public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];       
    }

    @istest
    private static void createAccountTest() {
        Profile objProfile = null;
        User objManager = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Account__c objLATAccount = null;
 
        System.debug('createAccountTest [] ->');
 
        createRegionalUDC();

        objProfile = retrieveProfile();
        objManager = retrieveUser(null, objProfile);
        insert objManager;

        objUser = retrieveUser(objManager, objProfile);
        objAccount = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        objAccount.Type = 'COM PAGAMENTO';

        System.runas(objUser) { 
            Test.startTest();
            objAccount.Regional__C = [SELECT Id FROM Udc__c LIMIT 1].Id;
            insert objAccount;

            objLATAccount = asociateLATAccount(objAccount,'LAT_BR_ACC_AccountConFaturamento');
            update objLATAccount;

            objAccount.overdue__c = true;
            objAccount.Client_code_AN8__c = '0';
            objAccount.Status__c = 'Em aprovação - Financeiro';

            update objAccount; 

            //System.assertEquals(true, Approval.isLocked(objAccount), 'El registro no entro en el proceso de aprobacion');

            Test.stopTest();
        }

        System.debug('createAccountTest [] <-');
    }

    @istest
    static void contaAutomatizaEnvioAprovacaoTest() {
        Profile objProfile = null;
        User objManager = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Account__c objLATAccount = null;
        Map<Id, Account> mapAccount = null;

        System.debug('contaAutomatizaEnvioAprovacaoTest [] ->');
        objProfile = retrieveProfile();
        objManager = retrieveUser(null, objProfile);
        insert objManager;

        objUser = retrieveUser(objManager, objProfile);
        objAccount = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        objAccount.Type = 'COM PAGAMENTO';

        System.runas(objUser) { 
            Test.startTest();
            insert objAccount;
            System.assertEquals(false, Approval.isLocked(objAccount), 'El registro no debio entrar en el proceso de aprobacion');

            objLATAccount = asociateLATAccount(objAccount,'LAT_BR_ACC_AccountConFaturamento');
            update objLATAccount;

            objAccount.Checked_over_Sales_Administration__c = true;
            objAccount.Checked_over_Credit_and_collection__c = true;
            try {
                update objAccount;
            } catch (Exception Ex) {
                System.debug('contaAutomatizaEnvioAprovacaoTest [Ex : ' + Ex + ']');   
            }
            //System.assertEquals(true, Approval.isLocked(objAccount), 'El registro no entro en el proceso de aprobacion');
            Test.stopTest();
        }

        System.debug('contaAutomatizaEnvioAprovacaoTest [] <-');        
    }

    @istest
    private static void contaCriaDemandaCustomerServiceTest() {
        System.debug('contaCriaDemandaCustomerServiceTest [] ->');

        createDemandaTest('Em análise - Customer Service');

        System.debug('contaCriaDemandaCustomerServiceTest [] <-');
    }
    @istest
    private static void contaCriaDemandaCreditoCobranzaTest() {
        System.debug('contaCriaDemandaCreditoCobranzaTest [] ->');

        createDemandaTest('Em análise - Crédito e Cobrança');

        System.debug('contaCriaDemandaCreditoCobranzaTest [] <-');
    }

    @istest
    private static void contaCriaDemandaControladoriaTest() {
        System.debug('contaCriaDemandaControladoriaTest [] ->');

        createDemandaTest('Em análise - Controladoria');

        System.debug('contaCriaDemandaControladoriaTest [] <-');
    }

    @istest
    private static void contaCriaDemandaAdminVendasTest() {
        System.debug('contaCriaDemandaAdminVendasTest [] ->');

        createDemandaTest('Em análise - ADM Vendas');

        System.debug('contaCriaDemandaAdminVendasTest [] <-');
    }

    private static void createDemandaTest(String strStatus) {
        Profile objProfile = null;
        User objManager = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Account__c objLATAccount = null;
        Map<Id, Account> mapAccount = null;

        System.debug('createDemandaTest [strStatus : ' + strStatus + '] ->');
        objProfile = retrieveProfile();
        objManager = retrieveUser(null, objProfile);
        insert objManager;

        objUser = retrieveUser(objManager, objProfile); 
        objAccount = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        objAccount.Type = 'COM PAGAMENTO';

        System.runas(objUser) { 
            Test.startTest();
            insert objAccount;

            objLATAccount = asociateLATAccount(objAccount,'LAT_BR_ACC_AccountConFaturamento');
            update objLATAccount;
            
            objAccount.Status__c = strStatus;

            update objAccount;

            //System.assertEquals(1, [SELECT Id FROM LAT_Case__c].size(), 'No se crearon las demandas');

            Test.stopTest();
        }

        System.debug('createDemandaTest [] <-');  
    }

    public static Profile retrieveProfile() {
        Profile objProfile = null;

        objProfile = [SELECT Id FROM Profile WHERE Name = 'LAT_BR2_Vendas']; 

        return objProfile;
    }

    public static User retrieveUser(User objManager, Profile objProfile) {
        User objUser = null;

        System.debug('retrieveUser [objProfile : ' + objProfile + '] ->');
        
        objUser = new User();
        objUser.Alias = 'standt';
        objUser.Email = 'testudc@zimmic.com';
        objUser.EmailEncodingKey = 'UTF-8'; 
        objUser.LastName = 'Testing';
        objUser.LanguageLocaleKey = 'en_US'; 
        objUser.LocaleSidKey = 'en_US'; 
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName =  generateRandomString(10) + '@zimmic.com';
        objUser.c_digo_jde__c = 'TT';
        if(objManager != NULL) {
            objUser.ManagerId = objManager.Id;
            objUser.Gerente_Regional__c = objManager.Id;
            objUser.gerente_de_area__c = objManager.Id;
        }

        System.debug('retrieveUser [' + objUser + '] <-');

        return objUser;
    }

    public static Udc__c createRegionalUDC() {
        Udc__c objUDC = null;

        System.debug('createRegionalUDC [] ->');

        objUDC = new Udc__c();

        objUDC.CodDefUsuario__c = 'TT';
        objUDC.CodProd__c = '01';
        objUDC.CodUs__c = '01';
        objUDC.Internal_Id__c='1-TT-01-01';
    
        insert objUDC;

        System.debug('createRegionalUDC [' + objUDC + '] <-');

        return objUDC;
    }

    private static LAT_Account__c asociateLATAccount(Account objAccount, String strObteinedApproval) {
        Lat_Account__c objLATAccount = null;

        System.debug('asociateLATAccount[objAccount : ' + objAccount + ' - strObteinedApproval : ' + strObteinedApproval + '] ->');
        
        objLATAccount = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: objAccount.Id];
        objLATAccount.Obtained_Approval__c = strObteinedApproval;

        System.debug('asociateLATAccount[' + objLATAccount + '] <-');
        return objLATAccount;         
    }

    public static String generateRandomString(Integer intLength) {
        final String arrChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String strRandomString = '';
        Integer intIndex = null;

        System.debug('generateRandomString [intLength : ' + intLength + '] ->');
        
        while (strRandomString.length() < intLength) {
            intIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), arrChars.length());
            strRandomString += arrChars.substring(intIndex, intIndex+1);
        }

        System.debug('generateRandomString [' + strRandomString + '] <-');

        return strRandomString; 
    }

   @istest
    static void unitTest() {

        system.Test.startTest();
        try{   

        Utils.setMigrationDoneTest(false);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

           system.runas(u){
               Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '58815921000192',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test ',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test', 
                Billing_Country__c ='test',
                Status__c = 'Em análise - Crédito e Cobrança'
            );
            
            //insert acc;
            insert acc;//}catch(Exception e){}
            
            acc.overdue__c = true;
            acc.Client_code_AN8__c = '0';
            acc.Status__c = 'Em aprovação - Financeiro';
            
            //update acc;
            //update acc;//}catch(Exception e){}
        }
       } catch (Exception e) {

       }                         
        
        
        system.Test.stopTest();                
        
    }
    
    public static User getVendasUser(){
        return [select id from user WHERE isActive = true and profile.name = 'LAT_BR2_Vendas'  and c_digo_jde__c<> null  LIMIT 1];
    }
    
    @istest
    static void unitTest22() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Checked_over_Sales_Administration__c=true,
            Checked_over_Credit_and_collection__c =true,
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        AP01_Account_BR.isRunning = true;
        Map<Id, Account> mapa = new  Map<Id, Account>();
        mapa.put(acc2.Id, acc2);
        try{AP01_Account_BR.ContaAutomatizaEnvioAprovacao(new List<Account>{acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }
        @istest
    static void unitTest23() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Checked_over_Sales_Administration__c=true,
            Checked_over_Credit_and_collection__c =true,
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        AP01_Account_BR.isRunning = true;
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - Customer Service';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }        @istest
    static void unitTest24() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Checked_over_Sales_Administration__c=true,
            Checked_over_Credit_and_collection__c =true,
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        AP01_Account_BR.isRunning = true;
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - Crédito e Cobrança';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }
       static void unitTest26() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Checked_over_Sales_Administration__c=true,
            Checked_over_Credit_and_collection__c =true,
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        AP01_Account_BR.isRunning = true;
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - ADM Vendas';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }
    
       static void unitTest27() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Checked_over_Sales_Administration__c=true,
            Checked_over_Credit_and_collection__c =true,
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        AP01_Account_BR.isRunning = true;
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - Controladoria';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }
    
    
    @istest
    static void unitTest2() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        
        system.Test.stopTest();
        
    }

        @istest
    static void unitTest202() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - Controladoria';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }

    @istest
    static void unitTest201() {
    

        system.Test.startTest(); 

        

        Account acc2 = new Account(
            CNPJ__c = '92157751000134',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        Map<Id, Account> mapa = new  Map<Id, Account>();
        
        Account acc3 = acc2.clone(true);
        acc2.Status__c = 'Em análise - ADM Vendas';
        mapa.put(acc2.Id, acc3);
        try{AP01_Account_BR.ContaCriaDemanda(new List<Account> {acc2}, mapa);}catch(Exception e){}
        system.Test.stopTest();
        
    }
    
    @istest
    static void unitTest2C() {
   
        system.Test.startTest(); 
      
        Account acc2 = new Account(
            CNPJ__c = '66328430000145',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Eventos'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}

        Map<Id,Account> mapIdAccount = new Map<Id,Account>();
        mapIdAccount.put(acc2.Id, acc2);
        List<Account> accts = new List<Account>();
        accts.add(acc2);

        system.Test.stopTest();
        
    }
   @istest
    static void unitTestB() {
            
        Utils.setMigrationDoneTest(true);
        try{
        
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

           system.runas(u){
                                             
            Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '91370573000162',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test',
                Billing_Country__c ='test',
                Status__c = 'Em análise - Crédito e Cobrança'
            );
            
            //insert acc;
            insert acc;//}catch(Exception e){}
                
            Utils.setMigrationDoneTest(true);
            
            acc.overdue__c = true;
            acc.Client_code_AN8__c = '0';
            acc.Status__c = 'Em aprovação - Financeiro';
            system.Test.startTest();            
            update acc;
            system.Test.stopTest(); 
            //update acc;//}catch(Exception e){}
        }

       }  catch (Exception e) {

       }     
               
        
    }

    @istest
    static void unitTestC() {
            
        
        try{
            Utils.setMigrationDoneTest(true);
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');

        system.runas(u){

        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Eventos'), 
            CNPJ__c = '48665312000140',
            Name = 'testAccount',
            Overdue__c = false,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Status__c = 'Novo cadastro'
        );
        
        //insert acc;
        try { insert acc;}catch(Exception e){}
            
        system.Test.startTest();            
        Utils.setMigrationDoneTest(true);
        
        //acc.overdue__c = true;
        //acc.Client_code_AN8__c = '0';
        acc.Status__c = 'Em aprovação - Financeiro';
        
        //update acc;
        try{update acc;}catch(Exception e){}

    }
        
        system.Test.stopTest();                
        }  catch (Exception e) {}
    }
    
    @istest
    static void unitTest2B() {
   
        system.Test.startTest(); 
        Utils.setMigrationDoneTest(true);     
        
     
        
        Account acc2 = new Account(
            CNPJ__c = '77637903000102',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
           
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = getVendasUser().Id
        );       
        
        insert acc2;//}catch(Exception e){}
        
        system.Test.stopTest();
        
    }

    @istest
    static void unitTest4() {
        User usuario = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name ='LAT_BR2_Vendas'  and c_digo_jde__c<> null  LIMIT 1];        
        Account acc2 = new Account(
            CNPJ__c = '77637903000102',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = usuario.Id
        );       
        
        insert acc2;
        system.Test.startTest(); 
        Utils.setMigrationDoneTest(true); 
        Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'BRA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc2.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        insert titulo;
        Map<Id, Account> mapa = new Map<Id, Account> ();
        List<Account> lista = new List<Account>();
        lista.add(acc2);
        mapa.put(acc2.Id, acc2);
        AP01_Account_BR.ContaCriaDemanda(lista, mapa );
        AP01_Account_BR.Conta_valida_Inscricao_Estadual(lista, mapa );
        AP01_Account_BR.ContaAutomatizaEnvioAprovacao(lista, mapa );
        
        system.Test.stopTest();
        
    }

    @istest
    static void unitTest5() {
        
        User usuario = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name ='LAT_BR2_Vendas'  and c_digo_jde__c<> null  LIMIT 1];     
        
        Account acc2 = new Account(
            CNPJ__c = '77637903000102',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Eventos'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            OwnerId = usuario.Id
        );       
        
        insert acc2;
        system.Test.startTest(); 
        Utils.setMigrationDoneTest(true);     
        
        Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'BRA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc2.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        insert titulo;
        Map<Id, Account> mapa = new Map<Id, Account> ();
        List<Account> lista = new List<Account>();
        lista.add(acc2);
        mapa.put(acc2.Id, acc2);
        AP01_Account_BR.ContaCriaDemanda(lista, mapa );
        AP01_Account_BR.Conta_valida_Inscricao_Estadual(lista, mapa );
        AP01_Account_BR.ContaAutomatizaEnvioAprovacao(lista, mapa );
        
        system.Test.stopTest();
        
    }

    @istest
    static void unitEnvioAprovacao() {
            
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
        system.runas(u){
                                                 
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
            
            Account acc = createAccountFromScratch();    
            system.Test.startTest();         
                   
            AP01_Account_BR.runInterface = true;
            //acc.Area_Manager__c = u.Id;
            //acc.overdue__c = true;
            //acc.Client_code_AN8__c = '0';
            acc.Type = 'COM PAGAMENTO';
            acc.Checked_over_Sales_Administration__c = true;
            acc.Checked_over_Credit_and_collection__c = true;
            acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
            acc.CNPJ__c = '58815921000192';
            acc.TriggerRun__c = false;
            
            
            try{update acc;}catch(Exception e){}
        }
        system.Test.stopTest();                
        
    }

    @istest
    static void unitEnvioAprovacao2() {
            
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
        system.runas(u){
                                                 
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
            
            Account acc = createAccountFromScratch();    
            system.Test.startTest();         
                   
            AP01_Account_BR.runInterface = true;
            //acc.Area_Manager__c = u.Id;
            //acc.overdue__c = true;
            //acc.Client_code_AN8__c = '0';
            acc.Type = 'SEM PAGAMENTO';
            acc.Checked_over_Sales_Administration__c = true;
            acc.Checked_over_Credit_and_collection__c = true;
            acc.Status__c = 'Em análise - Customer Service';
            acc.Rating = 'Cliente';
            acc.CNPJ__c = '58815921000192';
            acc.TriggerRun__c = false;
            //acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
            

            try{update acc;}catch(Exception e){}
        }
        system.Test.stopTest();                
        
    }
    @istest
    static void unitEnvioAprovacao3() {
            
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
        system.runas(u){
                                                 
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
            
            Account acc = createAccountFromScratch();    
            system.Test.startTest();         
                   
            AP01_Account_BR.runInterface = true;
            //acc.Area_Manager__c = u.Id;
            //acc.overdue__c = true;
            //acc.Client_code_AN8__c = '0';
            acc.Type = 'SEM PAGAMENTO';
            acc.Checked_over_Sales_Administration__c = true;
            acc.Checked_over_Credit_and_collection__c = true;
            acc.Status__c = 'Não Aprovado';
            acc.Rating = 'Cliente';
            acc.CNPJ__c = '58815921000192';
            acc.TriggerRun__c = false;
            //acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
            

            try{update acc;}catch(Exception e){}
        }
        system.Test.stopTest();                
        
    }
    @istest
    static void unitTestCustomerInterace() {
        try{
            User u = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
            system.runas(u){
                                                 
                LAT_WS_CustomerHandlerInterface_Test.testSetup();
                
                Account acc = createAccountFromScratch();    
                system.Test.startTest();     
                AP01_Account_BR.runInterface = true;
                //acc.Area_Manager__c = u.Id;
                //acc.overdue__c = true;
                //acc.Client_code_AN8__c = '0';
                acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
                acc.TriggerRun__c = false;
                //update acc;
                try{update acc;}catch(Exception e){}
                system.Test.stopTest();   
                AP01_Account_BR.customerInterfaceCall(new List<Account>{acc});
            }
        } catch (Exception e){}                 
        
    }
    
    @istest
    static void unitTestCustomerInterace2() {
        try{
            User u = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
            system.runas(u){
                                                 
                LAT_WS_CustomerHandlerInterface_Test.testSetup();
                
                Account acc = createAccountFromScratch();    
                system.Test.startTest();     
                AP01_Account_BR.runInterface = true;
                //acc.Area_Manager__c = u.Id;
                //acc.overdue__c = true;
                //acc.Client_code_AN8__c = '0';
                acc.Status__c = 'Cliente cadastrado no JDE';
                acc.TriggerRun__c = true;
                //update acc;
                try{update acc;}catch(Exception e){}
                system.Test.stopTest();   
                AP01_Account_BR.customerInterfaceCall(new List<Account>{acc});
            }
        } catch (Exception e){}                 
        
    }

    @istest
    static void unitTestUpdatesAreaManager() {
            
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true  and c_digo_jde__c<> null  LIMIT 2];
        User u = users[0];
        system.runas(u){
                                                 
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
                
            Account acc = createAccountFromScratch();    
            Test.startTest();         
            Utils.setMigrationDoneTest(true);
            //AP01_Account_BR.runInterface = true;
            acc.Area_Manager__c = users[1].Id;
            acc.Regional_Manager__c = users[1].Id;
            acc.overdue__c = true;
            acc.TriggerRun__c = false;
            acc.Type = 'SEM PAGAMENTO';
            //acc.Client_code_AN8__c = '0';
            //acc.Status__c = 'Cadastrado CRM';
            
            update acc;
            //try{update acc;}catch(Exception e){}
            Test.stopTest();                
        
        }
       
    }


    @istest
    static void unitTestUpdatesAreaManager2() {
            
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 2];
        User u = users[0];
        system.runas(u){
                                                 
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
                
            Account acc = createAccountFromScratch();   
            Account accClone = acc.clone(false, false, false, false);
            accClone.Area_Manager__c = users[1].Id;
            accClone.Regional_Manager__c = users[1].Id;
            Map<Id, Account> mapa = new Map<Id, Account>();
            mapa.put(acc.Id, accClone);
            Test.startTest();         
            
            AP01_Account_BR.updatesAreaRegionalManager(new List<Account>{acc}, mapa);
            //try{update acc;}catch(Exception e){}
            Test.stopTest();                
        
        }
       
    } 

    @istest
    static void unitTestUpdatesRegional() {
            
        Utils.setMigrationDoneTest(true);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, C_digo_JDE__c = 'TT',
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc@yahoo.com');
        Udc__c tabela = new Udc__c(CodDefUsuario__c = 'TT',CodProd__c = '01',CodUs__c = '01',Internal_Id__c='1-TT-01-01');
        insert tabela;

           system.runas(u){
                                             
            Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '91370573000162',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test',
                Billing_Country__c ='test',
                Status__c = 'Novo cadastro'
            );
            
           try { //insert acc;
            insert acc;//}catch(Exception e){}
                
            system.Test.startTest();            
            Utils.setMigrationDoneTest(true);
            //AP01_Account_BR.runInterface = true;
            acc.Regional__C = tabela.Id;
            acc.overdue__c = true;
            acc.Client_code_AN8__c = '0';
            acc.Area_Manager__c = u.Id;
            //acc.Status__c = 'Cadastrado CRM';
            
            update acc;
               
            //try{update acc;}catch(Exception e){}
            system.Test.stopTest();                

            } catch (Exception e) {}
               
        
        }

     
    }

    @isTest
    public static void segmentationTests() {
        LAT_WS_CustomerHandlerInterface_Test.testSetup();
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.isNew = true;
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.Revenue_UF__c         = 'SP';
        controllerNew.brAcc.State_registration__c = '110.042.490.114';
        controllerNew.CreateClient();
        Test.startTest();
        Lat_Account__c latdata = [select Id,Beneficio_Fiscal_revert__c, Channel_revert__c, Client_type_revert__c, Estrategia_comercial_revert__c, FORMATO_revert__c,
                                    Sub_channel_revert__c, PRIOR_DE_INVESTIMENTO_revert__c, Perfil_revert__c, Segment_revert__c, TBCI_revert__c, Obtained_POLiTICA_DE_PRECO_Udc_revert__c,
                                    Politica_Preco_Origin_revert__c  from Lat_Account__c where LAT_Accountid__c  = :controllerNew.brAcc.Id];
        AP01_Account_BR.revertSegmentation(controllerNew.segmentResult, latdata);
        AP01_Account_BR.revertSegmentationTBCIReprovado(controllerNew.segmentResult, latdata);
        AP01_Account_BR.activateSegmentation(controllerNew.newSegmentation, controllerNew.segmentResult,controllerNew.newSegmentation);
        Test.stopTest();

      }


    public static Account createAccountFromScratch() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.isNew = true;
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.Revenue_UF__c         = 'SP';
        controllerNew.brAcc.State_registration__c = '110.042.490.114';
        controllerNew.CreateClient();
        System.debug('%%%%% RecordTypeId de la controllerNew.brAcc: ' + controllerNew.brAcc.RecordTypeId);
        return controllerNew.brAcc;

      } 
    
    
}