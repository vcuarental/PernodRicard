@isTest
public class ASI_GnH_KR_Request_checkAplicatEptyTest{

    static testMethod void ASI_GnH_KR_Request_checkAplicatEptyTest(){

        List<User> testUserList = ASI_GnH_KR_TestClassHelper.createTestUser();
        User testUser = testUserList.get(0);
        system.runAs(testUser){
            Test.startTest();
            Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
            ASI_GnH_Request__c gnhRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                                   OwnerId = testUser.Id,
                                                                   ASI_GnH_Amount_per_Recipient__c = 25000,
                                                                   ASI_GnH_PAX__c = 1,
                                                                   ASI_GnH_Type__c = 'Gifts',
                                                                   ASI_GnH_Recipient_Type__c = 'Others');
            insert gnhRequest;
            
             Test.stopTest();
        }
    }
}