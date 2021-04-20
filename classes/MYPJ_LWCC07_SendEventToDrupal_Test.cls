/******************************************************************************
*   @author Simon Gourreau
*   @date 15/02/2021
*   @description MYPJ_LWCC07_SendEventToDrupal test class
*
*/
@isTest
public with sharing class MYPJ_LWCC07_SendEventToDrupal_Test {

    /* CONSTANTS */
    private final static String USER_NAME = 'test@sendDrupal.com';
    private final static String CAMPAIGN_NAME = 'test@sendDrupal.com';
    
    @testSetup 
    static void dataCreation() {
        User vUs = MMPJ_XRM_TestDataFactory.getStandardUser(USER_NAME);
        Database.insert(vUs);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :MYPJ_Constants.STANDARD_USER_MYPJ];
        insert new PermissionSetAssignment(AssigneeId = vUs.id, PermissionSetId = ps.Id);
    }

    @isTest
    public static void sendToDrupalSuccess(){
        User vUs = [Select Id From User Where Username = :USER_NAME];
        System.runAs(vUs) {

            Campaign vCamp = MMPJ_XRM_TestDataFactory.getCampaign(CAMPAIGN_NAME, MYPJ_Constants.CAMPAIGN_RT_MYPJ);
            Database.insert(vCamp);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MYPJ_LWCC07_SendEventToDrupal_Mock());
            MYPJ_LWCC07_SendEventToDrupal.returnValuesClass vRet = MYPJ_LWCC07_SendEventToDrupal.sendToDrupal(vCamp.Id);
            Test.stopTest();

            System.assert(!vRet.isError);
        }
    }

    @isTest
    public static void sendToDrupalError(){
        User vUs = [Select Id From User Where Username = :USER_NAME];
        System.runAs(vUs) {

            Campaign vCamp = MMPJ_XRM_TestDataFactory.getCampaign(CAMPAIGN_NAME, MYPJ_Constants.CAMPAIGN_RT_MYPJ);
            Database.insert(vCamp);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MYPJ_LWCC07_SendEventToDrupal_MockError());
            MYPJ_LWCC07_SendEventToDrupal.returnValuesClass vRet = MYPJ_LWCC07_SendEventToDrupal.sendToDrupal(vCamp.Id);
            Test.stopTest();

            System.assert(vRet.isError);
        }
    }
}