/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 10/11/2016
*
********************************************************************************/

@istest(seeAllDAta=false)
public with sharing class LAT_MX_AP01_Opportunity_TEST {

    static testMethod void unitTest() {
        Utils.setMigrationDoneTest(false);
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
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc1;
        
        acc1.Client_code_AN8__c = '100';
        
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
            Client_code_AN8__c = '100',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc1;
        
        //update acc1;

        LAT_Account__c latacc = [select id, LAT_ID_Status__c from LAT_Account__c where LAT_Accountid__c = :acc1.id];
        latacc.LAT_ID_Status__c = 'Activo';
        update latacc;

        system.debug('LAT_ID_Status__c: ' + latacc.LAT_ID_Status__c);
                        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc1.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DTDelivery__c = date.today(),
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        test.startTest();

        insert opp;
        
        Utils.setMigrationDoneTest(true);        
        opp.LAT_MX_PaymentPeriodApproved__c = true;
        opp.LAT_DTDelivery__c = date.today().addDays(1);
        
        update opp;
        
        delete opp;
        
        test.stopTest();     

    }

    static testMethod void testFillRate() {
        Utils.setMigrationDoneTest(true);
                
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
            Status__c = 'Cliente cadastrado no JDE',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Client_code_AN8__c = '100',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc1;
         
        LAT_Account__c latacc = [select id, LAT_ID_Status__c from LAT_Account__c where LAT_Accountid__c = :acc1.id];
        latacc.LAT_ID_Status__c = 'Activo';
        update latacc;

        system.debug('LAT_ID_Status__c: ' + latacc.LAT_ID_Status__c);
                        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc1.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DTDelivery__c = date.today(),
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        test.startTest();

        insert opp;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_MX_CDLineStatusFrom__c = '600';
        oli.LAT_CdLineStatus__c = '620';
        oli.LAT_Quantity__c = 2.0;
        oli.LAT_Opportunity__c = opp.id;

        //insert oli;

        insert oli;
        
        test.stopTest();     

    }

    @testSetup
    public static void setup(){

        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];

        Utils.setMigrationDoneTest(true);
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;

        LAT_GeneralConfig__c statusFillrate = new LAT_GeneralConfig__c(Name = 'LAT_MX_Opp_Status_for_Fill_Rate',LAT_Value__c = 'Facturado:560,600;  Timbrado:600,620;Cancelado:980,999;Contabilizado:620,999');
        insert statusFillrate;

        LAT_GeneralConfig__c cancelationsReasons = new LAT_GeneralConfig__c(Name = 'LAT_MX_Cancelation_Reasons',LAT_Value__c = '01, 02, 03, 04, 12, 23, 24, 25, 26, 27, 28, 30, 39, 40');
        insert cancelationsReasons;

        LAT_GeneralConfig__c billedStatus = new LAT_GeneralConfig__c(Name = 'LAT_MX_Opp_Billed_Status',LAT_Value__c = '560600620999');
        insert billedStatus;
    }

}