/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
@istest
public with sharing class LAT_MX_VFC08_AssignQuotaCero_Test {
	static testMethod void testMethod1() {
        Utils.setMigrationDoneTest(false);

        Account acc = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OnTrade');
        acc.CNPJ__c = 'LOZM701213E52';
        acc.Type = 'Payer';
        acc.Name = 'TestAcc1';
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        
        Account acc2 = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OnTrade');
        acc2.CNPJ__c = 'LOZM701213E53';
        acc2.Type = 'Payer';
        acc2.Name = 'TestAcc2';
        acc2.LAT_MX_FiscalEntityType__c = 'Individual';
        
        List <Account> lstAcc = new List <Account>();  
        lstAcc.add(acc);
        //lstAcc.add(acc2);
        insert lstAcc;

        User usuario = TestFactory.createStandardUser('test@test.com');
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

        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 0,
            LAT_MX_ValiditySince__c = Date.newInstance(2015, 3, 10),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2015, 3, 16)
        );    
        insert quota;

        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 0,
            LAT_MX_ValiditySince__c = Date.newInstance(2015, 2, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2015, 2, 28)
        );    
        insert quota2;

        List <LAT_MX_QTA_Quota__c> lstQuotas = new List <LAT_MX_QTA_Quota__c>();
        lstQuotas.add(quota);
        lstQuotas.add(quota2);    
        
        LAT_MX_VFC08_AssignQuotaCeroController controller = new LAT_MX_VFC08_AssignQuotaCeroController();
        controller.Quota.LAT_MX_ValiditySince__c = null;
        controller.Quota.LAT_MX_ValidityUntil__c = null;
        controller.Quota.LAT_MX_Product__c = null;
        ApexPages.currentPage().getParameters().put('listIndex', '0');


        
        Test.startTest();
        Utils.setMigrationDoneTest(false);
        PageReference pageRef = controller.Generate();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_5, pageMessages[0].getSummary());
        
        pageMessages.clear();
        controller.Quota.LAT_MX_Product__c = prod1.Id;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_4, pageMessages[1].getSummary());
        
        controller.Quota.LAT_MX_Product__c = prod1.Id;
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() - 1;
        controller.Quota.LAT_MX_ValidityUntil__c = Date.today() - 2;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_3, pageMessages[2].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.today();
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_2, pageMessages[3].getSummary());
        
        controller.Quota.LAT_MX_ValidityUntil__c = Date.today() + 2;
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() + 1;
        ApexPages.currentPage().getParameters().put('listIndexAjustar', '0');
        controller.Existing = lstQuotas;
        controller.Ajustar();
        
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Confirm_Msg_3, pageMessages[4].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.newInstance(2015, 2, 17);
        controller.Ajustar();
        //pageMessages = ApexPages.getMessages();
        //System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_3, pageMessages[5].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() + 1;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Confirm_Msg_1, pageMessages[5].getSummary());
       
        LAT_MX_QTA_Quota__c quota3 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 1,
            LAT_MX_ValiditySince__c = Date.newInstance(2017, 4, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2017, 4, 28)
        );    
        insert quota3;

        LAT_MX_QTA_Quota__c quota4 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 1,
            LAT_MX_ValiditySince__c = Date.newInstance(2017, 3, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2017, 3, 28)
        );    
        insert quota4;
        controller.Existing.add(quota4);

        controller.Quota = quota3;
        controller.AjustarTodos();

        controller.Quota = quota4;
        controller.Ajustar();

        
        LAT_MX_VFC08_AssignQuotaCeroController controller2 = new LAT_MX_VFC08_AssignQuotaCeroController();
        controller2.Quota.LAT_MX_ValiditySince__c = Date.today();
        controller2.Quota.LAT_MX_ValidityUntil__c = Date.today() + 2;
        controller2.Quota.LAT_MX_Product__c = prod1.Id;
        ApexPages.currentPage().getParameters().put('listIndex', '0');


        controller2.Existing = lstQuotas;
        
        controller2.EliminateOne();
        controller2.EliminarTodos();



        Test.stopTest();

	}
    //MIGRATED 21/11/2016
    static testMethod void testMethod1B() {
        Utils.setMigrationDoneTest(true);

        Account acc = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OnTrade');
        acc.CNPJ__c = 'LOZM701213E52';
        acc.Type = 'Payer';
        acc.Name = 'TestAcc1';
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        
        Account acc2 = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OnTrade');
        acc2.CNPJ__c = 'LOZM701213E53';
        acc2.Type = 'Payer';
        acc2.Name = 'TestAcc2';
        acc2.LAT_MX_FiscalEntityType__c = 'Individual';
        
        List <Account> lstAcc = new List <Account>();  
        lstAcc.add(acc);
        //lstAcc.add(acc2);
        insert lstAcc;

        User usuario = TestFactory.createStandardUser('test@test.com');
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

        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 0,
            LAT_MX_ValiditySince__c = Date.newInstance(2015, 3, 10),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2015, 3, 16)
        );    
        insert quota;

        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 0,
            LAT_MX_ValiditySince__c = Date.newInstance(2015, 2, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2015, 2, 28)
        );    
        insert quota2;

        List <LAT_MX_QTA_Quota__c> lstQuotas = new List <LAT_MX_QTA_Quota__c>();
        lstQuotas.add(quota);
        lstQuotas.add(quota2);    
        
        LAT_MX_VFC08_AssignQuotaCeroController controller = new LAT_MX_VFC08_AssignQuotaCeroController();
        controller.Quota.LAT_MX_ValiditySince__c = null;
        controller.Quota.LAT_MX_ValidityUntil__c = null;
        controller.Quota.LAT_Product__c = null;
        ApexPages.currentPage().getParameters().put('listIndex', '0');


        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        PageReference pageRef = controller.Generate();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_5, pageMessages[0].getSummary());
        
        pageMessages.clear();
        controller.Quota.LAT_Product__c = prod1.Id;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_4, pageMessages[1].getSummary());
        
        controller.Quota.LAT_Product__c = prod1.Id;
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() - 1;
        controller.Quota.LAT_MX_ValidityUntil__c = Date.today() - 2;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_3, pageMessages[2].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.today();
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_2, pageMessages[3].getSummary());
        
        controller.Quota.LAT_MX_ValidityUntil__c = Date.today() + 2;
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() + 1;
        ApexPages.currentPage().getParameters().put('listIndexAjustar', '0');
        controller.Existing = lstQuotas;
        controller.Ajustar();
        
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Confirm_Msg_3, pageMessages[4].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.newInstance(2015, 2, 17);
        controller.Ajustar();
        //pageMessages = ApexPages.getMessages();
        //System.assertEquals(Label.LAT_MX_VFC08_Error_Msg_3, pageMessages[5].getSummary());
        
        controller.Quota.LAT_MX_ValiditySince__c = Date.today() + 1;
        pageRef = controller.Generate();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(Label.LAT_MX_VFC08_Confirm_Msg_1, pageMessages[5].getSummary());
        
        LAT_MX_QTA_Quota__c quota3 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 1,
            LAT_MX_ValiditySince__c = Date.newInstance(2017, 4, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2017, 4, 28)
        );    
        insert quota3;

        controller.Quota = quota3;

        LAT_MX_QTA_Quota__c quota4 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc2.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 1,
            LAT_MX_ValiditySince__c = Date.newInstance(2017, 3, 17),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = Date.newInstance(2017, 3, 28)
        );    
        insert quota4;
        controller.Existing.add(quota4);
        controller.AjustarTodos();
        

        controller.Quota = quota4;
        controller.Ajustar();


        LAT_MX_VFC08_AssignQuotaCeroController controller2 = new LAT_MX_VFC08_AssignQuotaCeroController();
        controller2.Quota.LAT_MX_ValiditySince__c = Date.today();
        controller2.Quota.LAT_MX_ValidityUntil__c = Date.today() + 2;
        controller2.Quota.LAT_Product__c = prod1.Id;
        ApexPages.currentPage().getParameters().put('listIndex', '0');


        controller2.Existing = lstQuotas;
        
        controller2.EliminateOne();
        controller2.EliminarTodos();



        Test.stopTest();

    }
}