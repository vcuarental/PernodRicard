@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_Contact_TriggerClass
****************************************/
public class ASI_CRM_MY_Contact_TEST{

    static testMethod void insertContact_TEST() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
        Account acc = new Account(Name = 'TEST', RecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_MFM_MY_Customer'));
        insert acc;
        
        customer1.ASI_CRM_Account__c = acc.id;
        update customer1;
        
        Contact con = new Contact(ASI_CRM_AccountAdditionalField__c = customer1.id, LastName = 'LN', RecordTypeId = Global_RecordTypeCache.getRTId('ContactASI_CRM_MY_Contact'));
        insert con;
    }
}