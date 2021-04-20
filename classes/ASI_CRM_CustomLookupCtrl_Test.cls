@isTest
public class ASI_CRM_CustomLookupCtrl_Test {

    @TestSetup
	public static void setup() {
        String ownerId = UserInfo.getUserId();

        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.Name = 'Testing';
        customer.OwnerId = ownerId;
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Potential_Outlet');
        customerList.add(customer);

        insert customerList;
    }

    @isTest
    public static void testCustomLookupCtrl() {
        String objectName             = 'ASI_CRM_AccountsAdditionalField__c';
        String labelField             = 'Name';
        String subLabelField          = 'ASI_CRM_SG_Area__c';
        List<String> filterFieldList  = new List<String> {
            'Name'
        };
        String searchKey              = 'Testing';
        String additionalFilterString = '(RecordType.DeveloperName = \'ASI_CRM_PH_Potential_Outlet\')';
        Integer recordCount           = 5;

        ASI_CRM_CustomLookupCtrl.getRecordList(objectName, 
            labelField, 
            subLabelField,
            filterFieldList,
            searchKey,
            additionalFilterString,
            recordCount
            );
    }

}