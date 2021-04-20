@isTest
private class LAT2_VPC10_StatusIndicatorTest {
	


    static testMethod void myUnitTest2() { 
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        admin.ProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        insert admin;
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
            lg.Name = 'LAT_MX_OPP_Integrada_JDE';
            lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
            insert lg;

         
        
        
        system.runas(admin){ 
            Utils.setMigrationDoneTest(true);         
            UDC__c udc = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
                Internal_Id__c = '123456789012',
                CodUs__c = 'PT',
                CodProd__c = 'CRM'
            );
            insert udc;
        
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

            opp.LAT_StageName__c = 'Pedido enviado para o JDE';
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
            Utils.setMigrationDoneTest(true);   
            LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
                LAT_Remover__c = false,
                LAT_Quantity__c = 200,
                LAT_AR_UOM__c = 'CA',
                LAT_SkuText__c = '100',
                LAT_Product__c = prod1.Id,
                LAT_UnitPrice__c = 10,
                LAT_Opportunity__c = opp.Id,
                LAT_MX_KAMPromisedDate__c = date.today(),
                LAT_MX_RealDeliveryDate__c = date.today()
            );
            insert oli;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            LAT2_VPC10_StatusIndicator cl = new LAT2_VPC10_StatusIndicator(sc);
            test.stopTest();   
        }
    }
	
    static testMethod void myUnitTest3() { 
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        admin.ProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        insert admin;
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
            lg.Name = 'LAT_MX_OPP_Integrada_JDE';
            lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
            insert lg;

         
        
        
        system.runas(admin){ 
            Utils.setMigrationDoneTest(true);         
            UDC__c udc = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
                Internal_Id__c = '123456789012',
                CodUs__c = 'PT',
                CodProd__c = 'CRM'
            );
            insert udc;
        
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

            opp.LAT_StageName__c = 'Pedido con descuento en aprobación';
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
            Utils.setMigrationDoneTest(true);   
            LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
                LAT_Remover__c = false,
                LAT_Quantity__c = 200,
                LAT_AR_UOM__c = 'CA',
                LAT_SkuText__c = '100',
                LAT_Product__c = prod1.Id,
                LAT_UnitPrice__c = 10,
                LAT_Opportunity__c = opp.Id,
                LAT_MX_KAMPromisedDate__c = date.today(),
                LAT_MX_RealDeliveryDate__c = date.today()
            );
            insert oli;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            LAT2_VPC10_StatusIndicator cl = new LAT2_VPC10_StatusIndicator(sc);
            test.stopTest();   
        }
    }
}