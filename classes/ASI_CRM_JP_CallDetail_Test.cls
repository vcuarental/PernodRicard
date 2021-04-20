/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetail_Test
 * Description: Test Class for Call Detail of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/12/2014       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_CallDetail_Test {
    //Test for ASI_CRM_JP_CallDetailTgrHdlr
    static testMethod void ASI_CRM_JP_CallDetailTgrHdlr_Test() {
        User u1 = ASI_CRM_JP_TestClassHelper.createUser();
        
        System.runAs(u1){
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(1), ASI_CRM_Visit_Date_To__c = system.now().addDays(1));
            ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            
            detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            insert detailList;
            
            test.startTest();
            detail1.ASI_CRM_Reminder__c = true;
            detail1.ASI_CRM_Reminder_Id__c = '00UM00000041kRL';
            detail1.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail');
            detail1.ASI_CRM_Status__c = 'Cancelled';
            
            detail2.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat_Settings');
            detail2.ASI_CRM_Pattern__c = 'Weekly';
            detail2.ASI_CRM_Repeat_End_Date__c = system.today().addMonths(10);
            detail2.ASI_CRM_Frequency__c = '1';
            
            detail3.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat_Settings');
            detail3.ASI_CRM_Pattern__c = 'Monthly';
            detail3.ASI_CRM_Repeat_End_Date__c = system.today().addMonths(10);
            detail3.ASI_CRM_Frequency__c = '1';
            update detailList;
        }
        test.stopTest();
    }
    
    
    //Test for ASI_CRM_JP_CallDetailPrintController
    static testMethod void ASI_CRM_JP_CallDetailPrintController_Test(){
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(1), ASI_CRM_Visit_Date_To__c = system.now().addDays(1));
            ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            
            detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            insert detailList;
            
            PageReference pageRef = Page.ASI_CRM_JP_CallDetailUpdatePrintPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(plan);
            ASI_CRM_JP_CallDetailUdPrintController crl = new ASI_CRM_JP_CallDetailUdPrintController(sc);
            crl.updatePara();
            test.startTest();
            pageRef = Page.ASI_CRM_JP_CallDetailPrintPage;
            pageRef.getParameters().put('Id', detail1.Id);
            pageRef.getParameters().put('recs', detail1.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(detailList);
            ssc.setSelected(detailList);
            ASI_CRM_JP_CallDetailPrintController controller = new ASI_CRM_JP_CallDetailPrintController(ssc);
            test.stopTest();
    }
    
    //Test for ASI_CRM_JP_ReviseCallDetailController
    static testMethod void ASI_CRM_JP_ReviseCallDetailController_Test() {
        User u1 = ASI_CRM_JP_TestClassHelper.createUser();
        
        System.runAs(u1){
            ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan'), Name = 'Test', OwnerId = u1.Id, ASI_CRM_Approved__c = false, ASI_CRM_Period_From__c = system.today(), ASI_CRM_Period_To__c = system.today().addDays(60));
            insert plan;
            List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
            ASI_CRM_Call_Detail__c detail1 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Planned', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Result_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now(), ASI_CRM_Visit_Date_To__c = system.now());
            ASI_CRM_Call_Detail__c detail2 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(1), ASI_CRM_Visit_Date_To__c = system.now().addDays(1));
            ASI_CRM_Call_Detail__c detail3 = new ASI_CRM_Call_Detail__c(ASI_CRM_Status__c = 'Draft', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail'), ASI_CRM_Call_Plan__c = plan.Id, ASI_CRM_Visit_Date_From__c = system.now().addDays(2), ASI_CRM_Visit_Date_To__c = system.now().addDays(2));
            
            detailList.add(detail1);
            detailList.add(detail2);
            detailList.add(detail3);
            insert detailList;
            
            test.startTest();
            
            ApexPages.currentPage().getParameters().put('userid', u1.id);
            ASI_CRM_JP_ReviseCallDetailController ctrl = new ASI_CRM_JP_ReviseCallDetailController(new ApexPages.StandardController(detail1));            
            ctrl.init();
            ctrl.save();
        }
        test.stopTest();
    }
}