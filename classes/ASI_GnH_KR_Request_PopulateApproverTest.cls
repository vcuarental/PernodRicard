@isTest
public class ASI_GnH_KR_Request_PopulateApproverTest{
    @testSetUp static void setUpData(){        
        List<User> user = ASI_GnH_KR_TestClassHelper.createTestUser();
        List<ASI_GnH_Route_Type__c> gnhRouteTypeList = new List<ASI_GnH_Route_Type__c>();
        
        Id gnhRouteTypeRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Route_Type__c' + 'ASI_GnH_KR_Route_Type');
        ASI_GnH_Route_Type__c gnhRouteType = new ASI_GnH_Route_Type__c(recordTypeId = gnhRouteTypeRtId,
                                                                       ASI_GnH_Company__c = 'Test Company',
                                                                       ASI_GnH_Department__c = 'Kyunggi WS',
                                                                       ASI_GnH_External_Party_Type__c = 'Others',
                                                                       ASI_GnH_GnH_Type__c = 'Gifts',
                                                                       ASI_GnH_Type__c = 'Offer'
                                                                       //ASI_GnH_User__c = user[0].Id
                                                                      );
        gnhRouteTypeList.add(gnhRouteType);
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        ASI_GnH_Route_Type__c gnhRouteType2 = new ASI_GnH_Route_Type__c(recordTypeId = gnhRouteTypeRtId,
                                                                        ASI_GnH_Company__c = 'Test Company',
                                                                        ASI_GnH_Department__c = 'Kyunggi WS',
                                                                        ASI_GnH_External_Party_Type__c = 'Others',
                                                                        ASI_GnH_GnH_Type__c = 'Gifts',
                                                                        ASI_GnH_Type__c = 'Receive',
                                                                        ASI_GnH_User__c = appliciant.Id
                                                                       );
        gnhRouteTypeList.add(gnhRouteType2);
        insert gnhRouteTypeList;
        
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
    
    public static void createGnHRequest(){
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                               ASI_GnH_Applicant__c = appliciant.Id,
                                                               ASI_GnH_Amount_per_Recipient__c = 25000,
                                                               ASI_GnH_PAX__c = 1,
                                                               ASI_GnH_Type__c = 'Gifts',
                                                               ASI_GnH_Recipient_Type__c = 'Others');
        insert gnhRequest;
        
        
    } 
    
    //Test Case 1 - Insert Offer Request with Appliciant
    static testMethod void assignApproverWithoutUser(){
        Test.startTest();
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                               ASI_GnH_Applicant__c = appliciant.Id,
                                                               ASI_GnH_Amount_per_Recipient__c = 25000,
                                                               ASI_GnH_Type__c = 'Gifts',
                                                               ASI_GnH_Recipient_Type__c = 'Others');
        insert gnhRequest;
        Test.stopTest();
    }
    
    //Test Case 2 - Insert Offer Request without Appliciant, but have OwnerId
    static testMethod void assignApproverWithoutAppliciant(){
        Test.startTest();
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                               OwnerId = appliciant.Id,
                                                               ASI_GnH_Amount_per_Recipient__c = 25000,
                                                               ASI_GnH_Type__c = 'Gifts',
                                                               ASI_GnH_Recipient_Type__c = 'Others');
        insert gnhRequest;
        Test.stopTest();
    }
    
    //Test Case 3 - Insert Receive Request with Appliciant
    static testMethod void assignApproverWithUser(){
        Test.startTest();
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Receive_Request');
        ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                               ASI_GnH_Applicant__c = appliciant.Id,
                                                               ASI_GnH_Amount_per_Recipient__c = 25000,
                                                               ASI_GnH_Type__c = 'Gifts',
                                                               ASI_GnH_Recipient_Type__c = 'Others');
        insert gnhRequest;
        Test.stopTest();
    }
    
    //Test Case 4 - Update Request
    static testMethod void updateRequest(){
        Test.startTest();
        createGnHRequest();
        ASI_GnH_Request__c gnhRequest = [select id,ASI_GnH_PAX__c from ASI_GnH_Request__c where ASI_GnH_Type__c = 'Gifts' and ASI_GnH_Recipient_Type__c = 'Others'];
        gnhRequest.ASI_GnH_PAX__c = 2;
        update gnhRequest;
        Test.stopTest();
    }
}