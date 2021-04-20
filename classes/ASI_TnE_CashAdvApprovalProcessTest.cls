/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @01/13/2016 3:16 PM
 * Revision History:
 * 1. 01/13/2016 - [DC 1.0] Created
 * 1. 01/25/2016 - [DC 1.1] Increased coverage of class from 79% to 85%.
 **********************************************************************************/

@isTest
public with sharing class ASI_TnE_CashAdvApprovalProcessTest {
    
    private static testMethod void testInsertWithoutRouteData() {
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        insert instance;
    }
    
    private static testMethod void testUpdateWithoutRouteData() {
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        insert instance;
        instance.ASI_TnE_Requested_Employee__c = UserInfo.getUserId();
        update instance;
    }
    
    private static testMethod void testInsertWithRouteData() {
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            ASI_TnE_User__c = UserInfo.getUserId()
        );
        
        test.startTest();
        insert routeTypeInstance;

        ASI_TnE_Route_Rule_Detail__c routeDetailInstance1 = new ASI_TnE_Route_Rule_Detail__c(
            ASI_TnE_Approver_Type__c = 'User',
            ASI_TnE_Approver_Name__c = UserInfo.getUserId(),
            ASI_TnE_Amount_Threshold__c = 10.0,
            ASI_TnE_Route_Type__c = routeTypeInstance.Id
        );
        insert routeDetailInstance1;
        
        ASI_TnE_Route_Rule_Detail__c routeDetailInstance2 = new ASI_TnE_Route_Rule_Detail__c(
            ASI_TnE_Approver_Type__c = 'Line Manager',
            ASI_TnE_Approver_Name__c = UserInfo.getUserId(),
            ASI_TnE_Amount_Threshold__c = 10.0,
            ASI_TnE_Route_Type__c = routeTypeInstance.Id
        );
        insert routeDetailInstance2;

        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        insert instance;
        test.stopTest();
    }
    
    private static testMethod void testUpdateWithRouteData() {
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            ASI_TnE_User__c = UserInfo.getUserId()
        );
        insert routeTypeInstance;

        ASI_TnE_Route_Rule_Detail__c routeDetailInstance1 = new ASI_TnE_Route_Rule_Detail__c(
            ASI_TnE_Approver_Type__c = 'User',
            ASI_TnE_Approver_Name__c = UserInfo.getUserId(),
            ASI_TnE_Amount_Threshold__c = 10.0,
            ASI_TnE_Route_Type__c = routeTypeInstance.Id
        );
        insert routeDetailInstance1;
        
        ASI_TnE_Route_Rule_Detail__c routeDetailInstance2 = new ASI_TnE_Route_Rule_Detail__c(
            ASI_TnE_Approver_Type__c = 'Line Manager',
            ASI_TnE_Approver_Name__c = UserInfo.getUserId(),
            ASI_TnE_Amount_Threshold__c = 10.0,
            ASI_TnE_Route_Type__c = routeTypeInstance.Id
        );
        insert routeDetailInstance2;

        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        insert instance;
        update instance;
    }
    
    private static testMethod void testInsertWithUserLessRouteData() {
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department'
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        for(Integer i=0; i<6; i++) {
            User u = new User(Alias = 'user'+i, Email='standarduser' + i + '@testorg' + i +'.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + i + '@testorg' + i +'.com');
            
            detailList.add(createRouteRuleDetails('User', u.Id, routeTypeInstance.Id,UserInfo.getUserId()));
        }

        insert detailList;

        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        insert instance;
    }
    
    private static testMethod void testInsertWithApprover1() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            ASI_TnE_User__c = UserInfo.getUserId()
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        for(Integer i=0; i<6; i++) {
            User u = new User(Alias = 'user'+i, Email='standarduser' + i + '@foo' + i +'.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + i + '@foo' + i +'.com');
            
            System.runAs(u) {
                detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
            }
        }
        detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        system.debug('--detailList- 1' + detailList);
        
        insert detailList;

        User u = new User(Alias = 'user', Email='standarduser123@foo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@foo.com');
        
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        System.runAs(u) {
            insert instance;
        }
        instance.ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId();
        instance.ownerId = UserInfo.getUserId();
        update instance;
    }
    
    private static testMethod void testInsertWithApprover2() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            OwnerId = UserInfo.getUserId()
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        for(Integer i=0; i<6; i++) {
            /*User u = new User(Alias = 'user'+i, Email='standarduser' + i + '@foo' + i +'.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + i + '@foo' + i +'.com');
            
            System.runAs(u) {*/
                detailList.add(createRouteRuleDetails('User', routeTypeInstance.OwnerId, routeTypeInstance.Id, routeTypeInstance.OwnerId));
            // }
        }
        detailList.add(createRouteRuleDetails('User', detailList[0].ASI_TnE_Approver_Name__c, routeTypeInstance.Id,UserInfo.getUserId()));
        
        for(ASI_TnE_Route_Rule_Detail__c detailIterator : detailList) {
            detailIterator.ASI_TnE_Approver_Name__c = UserInfo.getUserId();
        }
        insert detailList;

        User u = new User(Alias = 'user', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId(),
            ASI_TnE_Sys_Approver_1__c = u.Id,
            ASI_TnE_Sys_Approver_2__c = u.Id
        );
        insert Instance;
        instance.ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId();
        instance.ASI_TnE_Sys_Approver_2__c = UserInfo.getUserId();
        instance.ownerId = UserInfo.getUserId();
        update instance;
    }
    
    private static testMethod void testInsertWithApprover3() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department'
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        for(Integer i=0; i<6; i++) {
            User u = new User(Alias = 'user'+i, Email='standarduser' + i + '@testorg' + i +'.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + i + '@testorg' + i +'.com');
            
            detailList.add(createRouteRuleDetails('User', u.Id, routeTypeInstance.Id, UserInfo.getUserId()));
        }

        insert detailList;

        User u = new User(Alias = 'user12', Email='standarduser12@testorg-pernod-ricard.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12@testorg-pernod-ricard.com');
        
        System.runAs(u) {
            System.debug('------ UserInfo.getUserId() ------ : ' + UserInfo.getUserId());
        }
        
        System.debug('------ UserInfo.getUserId() ------ : ' + UserInfo.getUserId());
        
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId(),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId(),
            ASI_TnE_Sys_Approver_2__c = u.Id,
            ASI_TnE_Sys_Approver_3__c = u.Id
        );
        insert instance;
    }
    
    // DC 1.1 - Added method for increasing coverage.
    private static testMethod void testInsertWithSameOwner() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            ASI_TnE_User__c = UserInfo.getUserId()
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        User userInstance = new User(Alias = 'user', Email='standarduser.test@footest.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser.test@footest.com');

        for(Integer i=0; i<6; i++) {            
            System.runAs(userInstance) {
                detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
            }
        }

        User tempUser = new User(Id = UserInfo.getUserId(), ManagerId = NULL);
        update tempUser;

        detailList.add(createRouteRuleDetails('Line Manager', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        system.debug('--detailList- 1' + detailList);
        
        insert detailList;

        User u = new User(Alias = 'user', Email='standarduser123@foo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@foo.com');
        
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        System.runAs(u) {
            insert instance;
        }
        instance.ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId();
        instance.ownerId = UserInfo.getUserId();
        instance.ASI_TnE_Requested_Employee__c = UserInfo.getUserId();
        update instance;
    }

    // DC 1.1 - Added method for increasing coverage.
    private static testMethod void testInsertWithSetOfOwners() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        ASI_TnE_Route_Type__c routeTypeInstance = new ASI_TnE_Route_Type__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type'),
            ASI_TnE_Company__c = 'Singapore',
            ASI_TnE_Department__c = 'Test Department',
            ASI_TnE_User__c = UserInfo.getUserId()
        );
        insert routeTypeInstance;
        
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List<ASI_TnE_Route_Rule_Detail__c>();
        
        User userInstance1 = new User(Alias = 'user1', Email='standarduser.test@footest.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser.test1@footest1.com');

        User userInstance2 = new User(Alias = 'user2', Email='standarduser.test@footest.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser.test2@footest2.com');

        User userInstance3 = new User(Alias = 'user3', Email='standarduser.test@footest.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser.test3@footest3.com');

        System.runAs(userInstance1) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }
        System.runAs(userInstance2) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }
        System.runAs(userInstance3) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }
        System.runAs(userInstance1) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }
        System.runAs(userInstance2) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }
        System.runAs(userInstance3) {
            detailList.add(createRouteRuleDetails('User', UserInfo.getUserId(), routeTypeInstance.Id, UserInfo.getUserId()));
        }

        detailList.add(createRouteRuleDetails('User', NULL, routeTypeInstance.Id, UserInfo.getUserId()));
        system.debug('--detailList- 1' + detailList);
        
        insert detailList;

        User u = new User(Alias = 'user', Email='standarduser123@foo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@foo.com');
        
        ASI_TnE_Cash_Advance_Pre_Approval__c instance = new ASI_TnE_Cash_Advance_Pre_Approval__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
            ASI_TnE_Requested_Employee__c = UserInfo.getUserId()
        );
        System.runAs(u) {
            insert instance;
        }
        instance.ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId();
        instance.ownerId = UserInfo.getUserId();
        update instance;
    }

    private static ASI_TnE_Route_Rule_Detail__c createRouteRuleDetails(String type, Id approverId, Id routeTypeId, Id pOwnerId) {
        
        ASI_TnE_Route_Rule_Detail__c routeDetailInstance1 = new ASI_TnE_Route_Rule_Detail__c(
            ASI_TnE_Approver_Type__c = type,
            ASI_TnE_Amount_Threshold__c = 10.0,
            ASI_TnE_Route_Type__c = routeTypeId,
            ASI_TnE_Approver_Name__c = approverId
        );
        System.debug('------ routeDetailInstance1 ------ : ' + routeDetailInstance1);
        return routeDetailInstance1;
    }
}