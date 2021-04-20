/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:24/06/2014    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

@istest
public with sharing class LAT_AR_BTN02_ValidatesCancelReceipt_TEST{

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

               
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert u;  
        
        System.runAs(u){      
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
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

       
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AR_Vendedor' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }

    static testMethod void unitTest2B(){

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
         
         
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Vendedor' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
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
            Account_AR__c = accAR.id
        );
        insert receipt;

         
           
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    static testMethod void unitTest3B(){

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

         

         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    
    static testMethod void unitTest4() {

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
             


             DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
                tipoDocumento_AR__c = '00',
                Name = 'TEST',
                Amounttoapply_AR__c = 100,
                ReceiptNo_AR__c = receipt.id,
                RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
            );
            insert document;   
            
            User u = new User();
            u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert u;  
            
            System.runAs(u){      
                LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
                LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            }
        
    }
    
    static testMethod void unitTest5(){

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
         
         

         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AR_Vendedor' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
        }
        
    }
    
    static testMethod void unitTest5B(){

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

         
         

         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Vendedor' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
        }
        
    }
    static testMethod void unitTest6(){

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
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
         

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
        }
        
    }

    static testMethod void unitTest6B(){

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
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
         

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
        }
        
    }
    
    static testMethod void unitTest7(){

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
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;

         

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }

    static testMethod void unitTest7B(){

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
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;

         
        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_BR2_Vendas' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    
    static testMethod void unitTest8(){

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
        
        receipt.Status_AR__c = 'Receipt Sent to Treasury';
        update receipt;    
         VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    static testMethod void unitTest8B(){

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
         
     
        receipt.Status_AR__c = 'Receipt Sent to Treasury';
        update receipt; 
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1];  
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    static testMethod void unitTest9(){

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
        
        receipt.Status_AR__c = 'Receipt Verified';
        update receipt;    
         VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    static testMethod void unitTest9B(){

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
         
     
        receipt.Status_AR__c = 'Receipt Verified';
        update receipt; 
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1];  
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }

    static testMethod void unitTest10(){

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
         
         VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;

        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
    static testMethod void unitTest10B(){

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
         
     
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            Name = '000',
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 20,
            ValueType_AR__c = 'E'
        );
        insert value;
        
         DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert document;   
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1];  
            
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
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipts(new List<String>{receipt.Id});
            LAT_AR_BTN02_ValidatesCancelReceipts.ValidatesCancelReceipt(receipt.Id);
        }
        
    }
}