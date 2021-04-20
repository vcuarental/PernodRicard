/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlan_Test
 * Description: Test Class for Call Plan of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/12/2014       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_CallPlan_Test {//Test for Call Plan PDF
    static testMethod void ASI_CRM_JP_CallPlanPDF_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        Date testDate = date.newInstance(2015, 1, 1);
        Datetime testDateTime = Datetime.newInstance(2015, 1, 2);
        ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate, ASI_CRM_Period_To__c = testDate.addDays(10));
        insert plan;
        ASI_CRM_Call_Plan__c plan2 = ([Select ASI_CRM_Sys_Fiscal_Year__c From ASI_CRM_Call_Plan__c Where Id = :plan.Id])[0];
        
        List<ASI_MFM_Brand__c> brandList = new List<ASI_MFM_Brand__c>();
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test', ASI_MFM_Brand_Description__c = 'Test');
        brandList.add(brand1);
        ASI_MFM_Brand__c brand2 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test2', ASI_MFM_Brand_Description__c = 'Test2');
        brandList.add(brand2);
        insert brandList;
        
        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
        subBrandList.add(subBrand1);
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand2.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
        subBrandList.add(subBrand2);
        insert subBrandList;
        
        List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
        ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id);
        ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id);
        ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id);
        detailList.add(detail1);
        detailList.add(detail2);
        detailList.add(detail3);
        insert detailList;
        ASI_MFM_Budget__c budget = new ASI_MFM_Budget__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_CRM_JP_Budget'), ASI_CRM_Salesperson__c = u1.Id, ASI_MFM_Fiscal_year__c = plan2.ASI_CRM_Sys_Fiscal_Year__c, ASI_MFM_Sub_brand_Code__c = subBrand1.Id, ASI_CRM_Amount__c = 10000);
        insert budget;
        
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_JP_CallPlanPDFPage;
        pageRef.getParameters().put('Id', plan.Id);
        Test.setCurrentPage(pageRef);
        ASI_CRM_JP_CallPlanPDFController controller = new ASI_CRM_JP_CallPlanPDFController();
        controller.setcurrentHeaderId(plan.Id);
        controller.setinit(plan.Id);
        controller.Header = null;
        controller.getHeader();
        controller.details = null;
        controller.getDetails();
        controller.getApproverLanguage();
        controller.getapprovalDetails();
        controller.getCheckIfJP();
        controller.getcurrentHeaderId();
        controller.getgroupedDetails();
        controller.getHeader();
        test.stopTest();
    }
    
    //Test for Class ASI_CRM_JP_ConfirmPlanController
    static testMethod void ASI_CRM_JP_ConfirmPlanController_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        Date testDate = date.newInstance(2015, 1, 1);
        Datetime testDateTime = Datetime.newInstance(2015, 1, 2);
        ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = testDate, ASI_CRM_Period_To__c = testDate.addDays(10));
        insert plan;
        
        List<ASI_MFM_Brand__c> brandList = new List<ASI_MFM_Brand__c>();
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test', ASI_MFM_Brand_Description__c = 'Test');
        brandList.add(brand1);
        ASI_MFM_Brand__c brand2 = new ASI_MFM_Brand__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_JP_Brand'), Name = 'Test2', ASI_MFM_Brand_Description__c = 'Test2');
        brandList.add(brand2);
        insert brandList;
        
        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
        subBrandList.add(subBrand1);
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c = brand2.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_JP_Sub_brand'), ASI_MFM_Active_for_CRM__c = true);
        subBrandList.add(subBrand2);
        insert subBrandList;
        
        List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
        ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id);
        ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand1.Id);
        ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Status__c = 'Draft', ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = testDateTime, ASI_CRM_Visit_Date_To__c = testDateTime, ASI_CRM_Activity_Sub_brand_1__c = subBrand2.Id);
        detailList.add(detail1);
        detailList.add(detail2);
        detailList.add(detail3);
        insert detailList;
        
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_JP_ConfirmPlanPage;
        pageRef.getParameters().put('Id', plan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(plan);
        ASI_CRM_JP_ConfirmPlanController controller = new ASI_CRM_JP_ConfirmPlanController(sc);
        controller.save();
        try{
            delete plan;
        }catch(Exception e){
            
        }
        test.stopTest();
    }
   
}