/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlan_Test2
 * Description: Test Class for Call Plan of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/12/2014       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_CallPlan_Test2 {
    //Test Method for ASI_CRM_JP_CallPlanTgrHdlr
    //Also test Class ASI_CRM_JP_CheckCallPlanOverlap (92% coverage)
    //Also test Class ASI_CRM_JP_CallPlanPdfAttachTgrHdlr
    static testMethod void ASI_CRM_JP_CallPlanTgrHdlr_Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        insert u2;
        Date testDate = date.newInstance(2015, 1, 1);
        Datetime testDateTime = Datetime.newInstance(2015, 1, 2);
        List<ASI_CRM_Call_Plan__c > callPlans = new List<ASI_CRM_Call_Plan__c >();
        ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate, ASI_CRM_Period_To__c = testDate.addDays(10));
        ASI_CRM_Call_Plan__c plan2 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate.addDays(11), ASI_CRM_Period_To__c = testDate.addDays(20));
        ASI_CRM_Call_Plan__c plan3 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u2.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate.addDays(11), ASI_CRM_Period_To__c = testDate.addDays(20));
        callPlans.add(plan);
        callPlans.add(plan2);
        callPlans.add(plan3);
        insert callPlans ;

        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Wholesaler'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
        directSalesCustomer.ASI_CRM_CN_JDE_Code__c = '87654';
        insert directSalesCustomer;

        ASI_CRM_Call_Detail__c detail = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Customer__c = directSalesCustomer.Id);
        insert detail;
        //ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c(ASI_CRM_Call_Detail__c = detail.Id);
        //insert att;
        List<String> planIdList = new List<String>();
        planIdList.add(plan.Id);
        planIdList.add(plan2.Id);
        planIdList.add(plan3.Id);
        test.startTest();
        plan.ASI_CRM_Approved__c = true;
        update plan;
        ASI_CRM_JP_CallPlanPdfAttach.doPost(planIdList);
        plan.OwnerId = u2.Id;
        plan.ASI_CRM_Period_From__c = testDate.addDays(-1);
        update plan;
        detail.ASI_CRM_Status__c = 'Achieved';
        detail.ASI_CRM_Payment_Option__c = 'Invoice';
        try {
            update detail;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Cannot find'));
        }
        PageReference pageRef = Page.ASI_CRM_JP_SetCallPlanDraftPage;
        pageRef.getParameters().put('Id', plan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(plan);
        ASI_CRM_JP_SetCallPlanDraftController controller = new ASI_CRM_JP_SetCallPlanDraftController(sc);
        controller.save();
        test.stopTest();
    }
    
    //Test Method for Class ASI_CRM_JP_InsertRepeatCallDetail & ASI_CRM_JP_StopRepeatController
    static testMethod void ASI_CRM_JP_InsertRepeatCallDetail_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        system.runAs(u1){
            Date testDate = date.newInstance(2015, 1, 1);
            Datetime testDateTime = Datetime.newInstance(2015, 1, 2);
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate, ASI_CRM_Period_To__c = testDate.addDays(10));
            insert plan;
            ASI_CRM_Call_Detail__c repeatDetail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Pattern__c = 'Weekly', ASI_CRM_Repeat_End_Date__c = testDate.addYears(1), ASI_CRM_Frequency__c = '1', ASI_CRM_Original_Call_Detail__c = null);
            ASI_CRM_Call_Detail__c repeatDetail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Pattern__c = 'Monthly', ASI_CRM_Repeat_End_Date__c = testDate.addYears(1), ASI_CRM_Frequency__c = '1', ASI_CRM_Original_Call_Detail__c = null);
            List<ASI_CRM_Call_Detail__c> repeatDetailList = new List<ASI_CRM_Call_Detail__c>();
            repeatDetailList.add(repeatDetail1);
            repeatDetailList.add(repeatDetail2);
            insert repeatDetailList;
            test.startTest();
            ASI_CRM_Call_Plan__c plan2 = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate.addDays(12), ASI_CRM_Period_To__c = testDate.addMonths(1));
            insert plan2;
            plan2.ASI_CRM_Period_To__c = testDate.addMonths(2);
            update plan2;
            ApexPages.StandardController sc = new ApexPages.StandardController(repeatDetail1);
            ASI_CRM_JP_StopRepeatController controller = new ASI_CRM_JP_StopRepeatController(sc);
            controller.save();
            test.stopTest();
        }
    }
}