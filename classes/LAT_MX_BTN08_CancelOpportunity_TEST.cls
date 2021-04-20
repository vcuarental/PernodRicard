/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/

@istest(seeAllDAta=false)
public with sharing class LAT_MX_BTN08_CancelOpportunity_TEST {

   static testMethod void unitTest1() {
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(false);        
        LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        
        test.stopTest(); 

    }

   static testMethod void unitTest1b() {
        Utils.setMigrationDoneTest(true);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);        
        LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        
        test.stopTest(); 

    }
    
  static testMethod void unitTest2() {
        Utils.setMigrationDoneTest(false);  
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked'),
            StageName = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(false);        
        LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        
        test.stopTest(); 
    }

  static testMethod void unitTest2b() {
        Utils.setMigrationDoneTest(true);  
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked'),
            LAT_StageName__c = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);        
        LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        
        test.stopTest(); 
    }
    
  static testMethod void unitTest3() {
        Utils.setMigrationDoneTest(false);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked'),
            StageName = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(false); 
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;


        system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }
        system.runas(admin){ 
            opp.StageName = 'Pedido processado no JDE';
            
            update opp;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);

        }
        test.stopTest(); 
    }

  static testMethod void unitTest3b() {
        Utils.setMigrationDoneTest(true);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked'),
            LAT_StageName__c = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(true); 
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;


        system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }
        system.runas(admin){ 
            opp.LAT_StageName__c = 'Pedido processado no JDE';
            
            update opp;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);

        }
        test.stopTest(); 
    }
  static testMethod void unitTest4() {
        Utils.setMigrationDoneTest(false);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked'),
            NR_order_JDE__c = '100',
            StageName = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(false);         
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;
         system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }

        system.runas(admin){ 
        
            opp.StageName = 'Pedido processado no JDE';
            
            update opp;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        }
        
        test.stopTest();
    }
    
  static testMethod void unitTest4b() {
        Utils.setMigrationDoneTest(true);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked'),
            LAT_StageName__c = 'Novo pedido'
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);         
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;
         system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }

        system.runas(admin){ 
        
            opp.LAT_StageName__c = 'Pedido processado no JDE';
            
            update opp;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        }
        
        test.stopTest();
    }
    
  static testMethod void unitTest5() {
        Utils.setMigrationDoneTest(false);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked'),
            NR_order_JDE__c = '100',
            CurrencyIsoCode = 'MXN',
            StageName = 'Novo pedido'
        );
        
        insert opp;
        
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;
         system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }

        system.runas(admin){ 
        Utils.setMigrationDoneTest(false);         
            opp.StageName = 'Pedido processado no JDE';
            opp.LAT_MX_OppCancellationReason__c = 'test';
            
            update opp;
            
            Product2 prod1 = new Product2(
                Name = 'TestProd',
                IsActive = true,
                CD_Unit__c = 'CA',
                Internal_id__c = '444',
                QT_lead_time__c = 5,
                SKU__c = '5666',
                RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
            );
            
            insert prod1;
    
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 pricebook = new Pricebook2(
                Name = '1', 
                Description = '1'
            );
            insert pricebook;
            
            PricebookEntry pbe3 = new PricebookEntry(
                Product2Id = prod1.Id,
                UnitPrice = 12,
                Pricebook2Id = pricebookId, 
                IsActive = true,
                CurrencyIsoCode = 'MXN',
                UseStandardPrice = false
            );
    
            insert pbe3;
            
            test.startTest();
                    
            OpportunityLineItem oli = new OpportunityLineItem(
                Remover__c = false,
                Quantity = 200,
                UOM_AR__c = 'CA',
                LAT_SkuText__c = '100',
                PriceBookEntryId = pbe3.Id,
                UnitPrice = 10,
                OpportunityId = opp.Id,
                LAT_MX_KAMPromisedDate__c = date.today()
            );
            
            insert oli;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        }
        
        test.stopTest();
    }
    
  static testMethod void unitTest5b() {
        Utils.setMigrationDoneTest(true);   
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked'),
            LAT_NROrderJDE__c = '100',
            CurrencyIsoCode = 'MXN',
            LAT_StageName__c = 'Novo pedido'
        );
        
        insert opp;
        
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert admin;
         system.runas(admin){ 

            system.debug('bbbbb ' + admin);
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
            
        }

        system.runas(admin){ 
        Utils.setMigrationDoneTest(true);         
            opp.LAT_StageName__c = 'Pedido processado no JDE';
            opp.LAT_MX_OppCancellationReason__c = 'test';
            
            update opp;
            
            LAT_Product__c prod1 = new LAT_Product__c(
                Name = 'TestProd',
                LAT_IsActive__c = true,
                LAT_CDUnit__c = 'CA',
                LAT_ExternalId__c = '444',
                LAT_QTLeadTime__c = 5,
                LAT_Sku__c = '5666',
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
            );
            
            insert prod1;
    
            
            test.startTest();
                    
            LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
                LAT_Remover__c = false,
                LAT_Quantity__c = 200,
                LAT_AR_UOM__c = 'CA',
                LAT_SkuText__c = '100',
                LAT_Product__c = prod1.Id,
                LAT_UnitPrice__c = 10,
                LAT_Opportunity__c = opp.Id,
                LAT_MX_KAMPromisedDate__c = date.today()
            );
            
            insert oli;
            
            LAT_MX_BTN08_CancelOpportunity.CancelsOpportunity(opp.Id);
        }
        
        test.stopTest();
    }
}