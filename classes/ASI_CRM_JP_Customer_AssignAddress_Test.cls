/*********************************************************************************
 * Name:ASI_CRM_JP_Customer_AssignAddress_Test
 * Description: Test Class for ASI_CRM_JP_Customer_AssignAddress_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/05/2019        Rutuja Bardapurkar           Created
*********************************************************************************/

@isTest
public class ASI_CRM_JP_Customer_AssignAddress_Test {
    @TestSetup
    public static void setupData() {
        
        ASI_CRM_JP_TestHelper.createRunningNumber();
    }
    
    public static testMethod void testController() {
        Map<Id, ASI_CRM_AccountsAdditionalField__c> AddFieldMap = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
        Map<String, ASI_CRM_Postal_Code__c> postalCodeMap = new map<String, ASI_CRM_Postal_Code__c>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> customerIdSet = new Set<Id>();
        Set<String> postalCodeNameSet = new Set<String>();
        
        
        
        ID userid =  UserInfo.getUserId();
        Id RecordTypeId1 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('JP Direct Sales Ship To').getRecordTypeId();
        List<ASI_CRM_AccountsAdditionalField__c> AddFieldlst = new list<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c AddField = new ASI_CRM_AccountsAdditionalField__c();
        AddField.OwnerId = userid;
        AddField.ASI_CRM_PostalCode__c = '01231';
        AddField.ASI_CRM_KR_Salesman__c = '';
        AddField.RecordTypeId = RecordTypeId1;
        AddFieldlst.add(AddField);
        insert AddFieldlst;
        AddFieldMap.put(AddFieldlst[0].id,AddFieldlst[0]);
        
        
        update AddFieldlst;
        
        
        List<ASI_CRM_AccountsAdditionalField__c> AddFieldOldlst = new list<ASI_CRM_AccountsAdditionalField__c>();

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                .getRecordTypeInfosByName()
                .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c AddFieldOld =
                new ASI_CRM_AccountsAdditionalField__c(
                        Name = 'TestCustomer',
                        RecordTypeId = customerRecTypeId,
                        ASI_CRM_PostalCode__c = '56978',
                        OwnerId = userid);

        AddFieldOldlst.add(AddFieldOld);
        insert AddFieldOldlst;
        
        
        ASI_CRM_JP_Customer_AssignAddress AssignAdd = new ASI_CRM_JP_Customer_AssignAddress();
        AssignAdd.needToAssignAddress(AddField);
        AssignAdd.retrieveCustomerMap(customerIdSet);
        AssignAdd.retrievePostalCodeMap(postalCodeNameSet);
        AssignAdd.retrieveUserMap(userIdSet);
        AssignAdd.processSalesmanCode(AddFieldlst);
        AssignAdd.processAutoNumber(AddFieldlst);
        AssignAdd.processPostalCode(AddFieldlst, AddFieldMap);
        AssignAdd.needToAssignAddress(AddField, AddFieldOld);
        
        
    }
    
    
}