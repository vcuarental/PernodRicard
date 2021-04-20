/*********************************************************************************
 * Name:ASI_CRM_6AM_Schd_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2018-07-27       Calvin Chiu (LAPUTA)    Created
*********************************************************************************/
@isTest
public class ASI_CRM_6AM_Schd_Test {
	static testMethod void TestSchedulableClass() {
        
        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testCustomer1 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcompany',
            RecordTypeId = customerRecTypeId
        );

        ASI_CRM_AccountsAdditionalField__c testCustomer2 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcustomer',
            RecordTypeId = customerRecTypeId
        );
        
        ASI_CRM_AccountsAdditionalField__c testCustomer3 =  new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testcustomer',
            RecordTypeId = customerRecTypeId
        );

        insert new List<ASI_CRM_AccountsAdditionalField__c> {testCustomer1, testCustomer2, testCustomer3};

        Id subBrandRecTypeId = Schema.SObjectType.ASI_MFM_Sub_brand__c
                                     .getRecordTypeInfosByName()
                                     .get('SG Sub-brand').getRecordTypeId();

        ASI_MFM_Sub_brand__c testSubBrand1 = new ASI_MFM_Sub_brand__c(
            RecordTypeId = subBrandRecTypeId,
            Name = 'TestSubBrand1'
        );
        
        ASI_MFM_Sub_brand__c testSubBrand2 = new ASI_MFM_Sub_brand__c(
            RecordTypeId = subBrandRecTypeId,
            Name = 'TestSubBrand2'
        );

        insert new List<ASI_MFM_Sub_brand__c> {testSubBrand1, testSubBrand2};

        Id skuRecTypeId = Schema.SObjectType.ASI_MFM_SKU_Code__c
                                .getRecordTypeInfosByName()
                                .get('SG SKU').getRecordTypeId();

        ASI_MFM_SKU_Code__c testSku1 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-123'
        );
        
        ASI_MFM_SKU_Code__c testSku2 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456'
        );
        
        ASI_MFM_SKU_Code__c testSku3 = new ASI_MFM_SKU_Code__c(
            RecordTypeId = skuRecTypeId,
            Name = 'Test-Sku-456'
        );

        insert new List<ASI_MFM_SKU_Code__c> {testSku1, testSku2, testSku3};

        Id wsDepletionRecTypeId = Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
                                        .getRecordTypeInfosByName()
                                        .get('ASI_CRM_SG_WS_Depletion').getRecordTypeId();

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion1 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku1.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-2)
            );
            
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion2 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku2.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion3 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer2.Id,
                ASI_CRM_SKU__c = testSku2.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c testWsDepletion4 =
            new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(
                RecordTypeId = wsDepletionRecTypeId,
                ASI_CRM_Customer__c = testCustomer1.Id,
                ASI_CRM_SKU__c = testSku3.Id,
                ASI_TH_CRM_Date__c = Date.today().addMonths(-1)
            );

        insert new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> {
            testWsDepletion1, testWsDepletion2, testWsDepletion3, testWsDepletion4};

        String CNEventRecID = Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event');
        List<ASI_MFM_Event__c> evt_list = [Select id, name, ASI_MFM_CN_Completed_Outlet__c, 
            	(select id, name, ASI_MFM_Completed__c from ASI_MFM_Event__c.Event_Outlets__r) 
            	from ASI_MFM_Event__c where recordtypeid = :CNEventRecID];
        
        Test.startTest(); // Start Test
    	// Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_6AM_Schd());
        
        // To track the progress of the scheduled job.
        CronTrigger ct = [SELECT TimesTriggered
                               , NextFireTime
                               , CronExpression
                            FROM CronTrigger 
                           WHERE Id = :jobId];

        ASI_MFM_EventCompleteCalculation cb = New ASI_MFM_EventCompleteCalculation();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,evt_list);
        //cb.Finish(null);
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
      	Test.stopTest(); // End Test
    }
}