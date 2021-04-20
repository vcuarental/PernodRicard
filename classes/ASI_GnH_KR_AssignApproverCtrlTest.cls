@isTest
public class ASI_GnH_KR_AssignApproverCtrlTest{

    @testSetUp static void initData(){
        List<User> user = ASI_GnH_KR_TestClassHelper.createTestUser();

        Id gnhRouteTypeRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Route_Type__c' + 'ASI_GnH_KR_Route_Type');
        ASI_GnH_Route_Type__c gnhRouteType = new ASI_GnH_Route_Type__c(recordTypeId = gnhRouteTypeRtId,
                                                                       ASI_GnH_Company__c = 'Test Company',
                                                                       ASI_GnH_Department__c = 'Kyunggi WS',
                                                                       ASI_GnH_External_Party_Type__c = 'Others',
                                                                       ASI_GnH_GnH_Type__c = 'Gifts',
                                                                       ASI_GnH_Type__c = 'Offer'
                                                                       //ASI_GnH_User__c = user[0].Id
                                                                      );
        insert gnhRouteType;

        Id thresholdRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Threshold__c' + 'ASI_GnH_KR_GnH_Offer_Threshold');
        ASI_GnH_Threshold__c gnhThresholdAmt = new ASI_GnH_Threshold__c(recordTypeId = thresholdRtId,
                                                                        ASI_GnH_GnH_Type__c = 'Gifts',
                                                                        ASI_GnH_Recipient_Type__c = 'Others',
                                                                        ASI_GnH_Threshold_Amount__c = 15000);
        insert gnhThresholdAmt;

        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Route_Rule_Detail__c' + 'ASI_GnH_KR_Route_Rule_Detail');
        ASI_GnH_Route_Rule_Detail__c routeTypeDetail = new ASI_GnH_Route_Rule_Detail__c(recordTypeId = routeTypeDetailRtId,
                                                                                        ASI_GnH_Approver_Name__c = user[1].Id,
                                                                                        ASI_GnH_Approver_Type__c = 'User',
                                                                                        ASI_GnH_Route_Type__c = gnhRouteType.Id,
                                                                                        ASI_GnH_Threshold__c = gnhThresholdAmt.Id);        
        insert routeTypeDetail;

    }

    static testMethod void testAssignApprover(){

        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id requestRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = requestRtId,
                                                               ASI_GnH_Applicant__c = appliciant.Id,
                                                               ASI_GnH_Amount_per_Recipient__c = 25000,
                                                               ASI_GnH_Type__c = 'Gifts',
                                                               ASI_GnH_Recipient_Type__c = 'Others');
        insert gnhRequest;
        
        Test.startTest();
        Test.setCurrentPage(Page.ASI_GnH_KR_AssignApproverPage);
        Apexpages.currentPage().getParameters().put('id', gnhRequest.id);
        ASI_GnH_KR_AssignApproverCtrl cx1 = new ASI_GnH_KR_AssignApproverCtrl();
        cx1.reAssignApprover();
        Test.stopTest();

    }
}