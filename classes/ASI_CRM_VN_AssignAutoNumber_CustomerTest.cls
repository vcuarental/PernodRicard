/*
*********************************************************************************
     * Name: ASI_CRM_VN_AssignAutoNumberCustomerTest 
     * Description: Test Class for ASI_CRM_VN_AssignAutoNumber_Customer controller 
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    ---------------------------------
     * 30/10/2015       Laputa: Neha             Created
*********************************************************************************
*/

@isTest
public class ASI_CRM_VN_AssignAutoNumber_CustomerTest {
    static testMethod void ASI_CRM_VN_AutoAssignmentCustomer_TEST() {
    //RecordType Id for 'Outlet (VN)' Customer
     
    String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
                                     
    ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
    insert runningInstance;      
    test.startTest();
    ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
    insert customerInstance;
    
    test.stopTest();  
    
    list<ASI_CRM_AccountsAdditionalField__c> customerList = [select Id, ASI_CRM_CN_CRM_Code__c
                                                            from ASI_CRM_AccountsAdditionalField__c
                                                            where Id =: customerInstance.Id];
    
    
   
        
    }   
    
    static testMethod void ASI_CRM_NonVN_AutoAssignmentCustomer_TEST() {
    //RecordType Id for 'Modern Trade (TH)' Customer
    String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Modern Trade (TH)').getRecordTypeId();
                                     
    ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
    insert runningInstance;      
    test.startTest();
    ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
    insert customerInstance;
    
    test.stopTest();  
    
    list<ASI_CRM_AccountsAdditionalField__c> customerList = [select Id, ASI_CRM_CN_CRM_Code__c
                                                            from ASI_CRM_AccountsAdditionalField__c
                                                            where Id =: customerInstance.Id]; 
    }
}