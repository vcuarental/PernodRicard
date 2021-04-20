/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/

@istest(seeAllDAta=true)
public with sharing class LAT_MX_AP02_OpportunityWOS_TEST {

    static testMethod void unitTest() {
        Utils.setMigrationDoneTest(false); 
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
         
        Account acc1 = new Account(
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
            LAT_MX_APStep__c = 0,
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc1;
        
        acc1.Client_code_AN8__c = '100';
        //acc1.LAT_MX_APStep__c = 5;
        update acc1;
                        
        Opportunity opp = new Opportunity(
            AccountId = acc1.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DT_delivery__c = date.today(),
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(false);         
        opp.LAT_MX_PaymentPeriodApproved__c = true;
        opp.DT_delivery__c = date.today().addDays(1);
        
        update opp;
        
        delete opp;
        
        test.stopTest();     

    }

    static testMethod void unitTest2() {
        Utils.setMigrationDoneTest(true); 
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        

        
        Account acc1 = new Account(
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
        
        insert acc1;
        
        acc1.Client_code_AN8__c = '100';
        //acc1.LAT_MX_APStep__c = 0;
        
        update acc1;

                        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc1.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_DTDelivery__c = date.today(),
            LAT_StageName__C = 'Novo pedido',
            LAT_OrderOrigin__c = 'APP',
            LAT_NROrderJDE__c = null,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        System.debug('%%%% estamos en el TEST2 a');
        insert opp;
        System.debug('%%%% estamos en el TEST2 a1');
        
        test.startTest();
        Utils.setMigrationDoneTest(true);      
        opp.LAT_OrderOrigin__c = 'APP';   
        opp.LAT_NROrderJDE__c = '3333';
        System.debug('%%%% estamos en el TEST2 B');
        
        test.stopTest();     
        LAT_MX_AP02_OpportunityWOS.isProcessing = null;
        update opp;

        //delete opp;        

    }

    static testMethod void unitTest3() {
        Utils.setMigrationDoneTest(true); 
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        

        
        Account acc1 = new Account(
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
        
        insert acc1;
        
        acc1.Client_code_AN8__c = '100';
        //acc1.LAT_MX_APStep__c = 0;
        
        update acc1;

                        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc1.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_DTDelivery__c = date.today(),
            LAT_StageName__C = 'Novo pedido',
            LAT_OrderOrigin__c = 'APP',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);         
        opp.LAT_MX_PaymentPeriodApproved__c = true;
        opp.LAT_DTDelivery__c = date.today().addDays(1);
        update opp;
        
        delete opp;
        
        test.stopTest();     

    }

}