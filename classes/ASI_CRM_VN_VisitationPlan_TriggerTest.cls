/*********************************************************************************
 * Name: ASI_CRM_VN_VisitationPlan_TriggerTest
 * Description: Test Class for ASI_CRM_VN_VisitationPlan_TriggerClass
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 11/1/2018          Vincent         Created      
 * 
*********************************************************************************/
@isTest
public class ASI_CRM_VN_VisitationPlan_TriggerTest {
    @testSetup
    public static void setupTestData(){
    }
    public static testmethod void testForASI_CRM_VN_VisitationPlan_TriggerTest(){
        Profile p = [select id from profile where name='System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole');
        insert ur;
        System.debug('-----------------------------'+ur.id);
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = p.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',
                          userroleID=ur.id, ASI_CRM_User_Group__c = 'Test');
        System.runAs(u) {
            Id vpRecordTypeId = Schema.SObjectType.ASI_CRM_Visitation_Plan_Setup__c.getRecordTypeInfosByName().
                                                                                       get('ASI CRM VN Visitation Plan Setup').getRecordTypeId();        
            ASI_CRM_Visitation_Plan_Setup__c vp_setup = new ASI_CRM_Visitation_Plan_Setup__c (RecordTypeId = vpRecordTypeId, ASI_CRM_Effective_Date__c = Date.newInstance(2000, 01, 01),
                                                                                             ASI_CRM_VN_Expiry_Date__c = Date.newInstance(2099, 12, 31), Name = 'Test', ASI_CRM_VN_Sales_Target_Factor__c = 5);
            insert vp_setup;
            
            Test.startTest();
            Id devRecordTypeIdVisit = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName().
                                                                                       get('VN Visitation Plan').getRecordTypeId();
            ASI_HK_CRM_Visitation_Plan__c visitationInstance = ASI_CRM_VN_TestDataFactory.getVisitationPlan('TestVisitation_Plan',
                                                                                                             devRecordTypeIdVisit);
            insert visitationInstance;
            
            Id devRecordTypeId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.getRecordTypeInfosByName().
                                                                                         get('VN Visitation Plan Detail').getRecordTypeId();
            ASI_HK_CRM_Visitation_Plan_Detail__c instance = ASI_CRM_VN_TestDataFactory.getPlanDetail('customer',
                                                                                                     'outletName',
                                                                                                     devRecordTypeId,
                                                                                                     visitationInstance.id);
            insert instance;
            Test.stopTest();
        }
    }      
}