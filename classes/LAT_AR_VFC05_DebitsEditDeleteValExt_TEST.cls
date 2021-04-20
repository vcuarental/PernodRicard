/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:23/06/2014    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

@istest
public with sharing class LAT_AR_VFC05_DebitsEditDeleteValExt_TEST{

    static testMethod void unitTest1(){

        Account accAR = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c = 'test4',
            Revenue_Country__c = 'test5',
            Billing_Country__c = 'test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            Client_code_AN8__c = '0'
        );
        insert accAR;
        
        test.startTest();   
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = accAR.id
        );
        insert receipt;
        
        DBT_Debit_ARG__c debit = new DBT_Debit_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('DBT_Debit_ARG__c' + 'DPT_Standard_AR'),
            ReceiptNo_AR__c = receipt.id,
            Name = '123',
            DebitAmount_AR__c = 1000,
            DebitNo_AR__c = 100,
            Serial_AR__c = 100,
            DebitNoteType_AR__c = 'A',
            IssueDate_AR__c = date.today()
        );
        insert debit;      
        
        ApexPages.StandardController controller = new ApexPages.StandardController(debit);

        Apexpages.currentPage().getParameters().put('id', debit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', receipt.Id);

        LAT_AR_VFC05_DebitsEditDeleteValExt pagina = new LAT_AR_VFC05_DebitsEditDeleteValExt(controller);
        
        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert u;  
        
        System.runAs(u){               
            pagina.doValidationDelete();
            pagina.doValidationEdit();
        }
        
        test.stopTest();

    }
    
    static testMethod void unitTest2(){

        Account accAR = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c = 'test4',
            Revenue_Country__c = 'test5',
            Billing_Country__c = 'test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            Client_code_AN8__c = '0'
        );
        insert accAR;
        
        test.startTest();   
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = accAR.id
        );
        insert receipt;
        
        DBT_Debit_ARG__c debit = new DBT_Debit_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('DBT_Debit_ARG__c' + 'DPT_Standard_AR'),
            ReceiptNo_AR__c = receipt.id,
            Name = '123',
            DebitAmount_AR__c = 1000,
            DebitNo_AR__c = 100,
            Serial_AR__c = 100,
            DebitNoteType_AR__c = 'A',
            IssueDate_AR__c = date.today()
        );
        insert debit;      
        
        ApexPages.StandardController controller = new ApexPages.StandardController(debit);

        Apexpages.currentPage().getParameters().put('id', debit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', receipt.Id);

        LAT_AR_VFC05_DebitsEditDeleteValExt pagina = new LAT_AR_VFC05_DebitsEditDeleteValExt(controller);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AR_Vendedor' OR Name = 'LAT_AR2_Vendedor' LIMIT 1]; 
            
        User u = new User(
            Alias = 'testB', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser1', 
            FirstName = 'TestUser1',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com'
        );      
        insert u;
        
        System.runAs(u){               
            pagina.doValidationDelete();
            pagina.doValidationEdit();
        }
        
        test.stopTest();

    }
    
    static testMethod void unitTest3(){

        Account accAR = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c = 'test4',
            Revenue_Country__c = 'test5',
            Billing_Country__c = 'test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            Client_code_AN8__c = '0'
        );
        insert accAR;
        
        test.startTest();   
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = accAR.id,
            Status_AR__c = 'Receipt cancelled'
        );
        insert receipt;
        
        DBT_Debit_ARG__c debit = new DBT_Debit_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('DBT_Debit_ARG__c' + 'DPT_Standard_AR'),
            ReceiptNo_AR__c = receipt.id,
            Name = '123',
            DebitAmount_AR__c = 1000,
            DebitNo_AR__c = 100,
            Serial_AR__c = 100,
            DebitNoteType_AR__c = 'A',
            IssueDate_AR__c = date.today()
        );
        insert debit;      
        
        ApexPages.StandardController controller = new ApexPages.StandardController(debit);

        Apexpages.currentPage().getParameters().put('id', debit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', receipt.Id);

        LAT_AR_VFC05_DebitsEditDeleteValExt pagina = new LAT_AR_VFC05_DebitsEditDeleteValExt(controller);

        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert u;  
        
        System.runAs(u){               
            pagina.doValidationDelete();
            pagina.doValidationEdit();
        }
        
        test.stopTest();

    }
    
    static testMethod void unitTest4(){

        Account accAR = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c = 'test4',
            Revenue_Country__c = 'test5',
            Billing_Country__c = 'test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            Client_code_AN8__c = '0'
        );
        insert accAR;
        
        test.startTest();   
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = accAR.id,
            Status_AR__c = 'Receipt cancelled'
        );
        insert receipt;
        
        DBT_Debit_ARG__c debit = new DBT_Debit_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('DBT_Debit_ARG__c' + 'DPT_Standard_AR'),
            ReceiptNo_AR__c = receipt.id,
            Name = '123',
            DebitAmount_AR__c = 1000,
            DebitNo_AR__c = 100,
            Serial_AR__c = 100,
            DebitNoteType_AR__c = 'A',
            IssueDate_AR__c = date.today()
        );
        insert debit;      
        
        ApexPages.StandardController controller = new ApexPages.StandardController(debit);

        Apexpages.currentPage().getParameters().put('id', debit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', receipt.Id);

        LAT_AR_VFC05_DebitsEditDeleteValExt pagina = new LAT_AR_VFC05_DebitsEditDeleteValExt(controller);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AR_Vendedor' OR Name = 'LAT_AR2_Vendedor' LIMIT 1]; 
            
        User u = new User(
            Alias = 'testB', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser1', 
            FirstName = 'TestUser1',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com'
        );      
        insert u;
        
        System.runAs(u){               
            pagina.doValidationDelete();
            pagina.doValidationEdit();
        }
        
        test.stopTest();

    }
}