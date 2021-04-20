@isTest
public class ASI_CRM_RecordTypeUtilTest {

	@isTest
	static void testRecordTypesEnums() {
		System.assertNotEquals(null, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap);
		System.assertNotEquals(0, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap.keySet().size());
		System.assertNotEquals(0, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap.values().size());
	}

	@isTest
	static void testStaticVariables() {
		System.assertNotEquals(null, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap);
		System.assertNotEquals(0, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap.keySet().size());
		System.assertNotEquals(0, ASI_CRM_RecordTypeUtil.purchaseContractRecordTypeMap.values().size());
	}

	@isTest
	static void testGetRecordTypeInfoByApiName() {
		final RecordTypeInfo recordTypeInfo = ASI_CRM_RecordTypeUtil.getRecordTypeInfoByApiName(
				ASI_CRM_Payment_Invoice__c.sObjectType,
				ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Cash_Invoice.name()
		);

		System.assertNotEquals(
				null, recordTypeInfo.getName()
		);
	}

	@isTest
	static void testGetRecordTypeInfoByApiNameMap() {
		final Map<String, String> recordTypeNameApiNameMap = ASI_CRM_RecordTypeUtil.getRecordTypeNameApiNameMap(
				ASI_CRM_Payment_Invoice__c.sObjectType,
				new Set<String> {ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Cash_Invoice.name()}
		);

		System.assertNotEquals(null, recordTypeNameApiNameMap);
	}

	@isTest
	static void testGetRecordTypeInfoByApiNameInfoMap() {
		Map<String, RecordTypeInfo> recordTypeApiNameInfoMap = ASI_CRM_RecordTypeUtil.getRecordTypeApiNameInfoMap(
				ASI_CRM_Payment_Invoice__c.sObjectType
		);

		System.assertNotEquals(null, recordTypeApiNameInfoMap);
	}
    
    @isTest
    static void testGetRecordTypeIdApiNameMap() {
        final Map<Id, String> recordTypeIdApiNameMap = ASI_CRM_RecordTypeUtil.getRecordTypeIdApiNameMap(
            ASI_CRM_Payment_Invoice__c.sObjectType
        );
        
        System.assertNotEquals(null, recordTypeIdApiNameMap);
    }
    
    @isTest
    static void testGetRecordTypeIdByApiName() {
        final Id recordTyepId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
            ASI_CRM_Payment_Invoice__c.sObjectType,
            ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Cash_Invoice.name()
        );
        
        System.assertNotEquals(null, recordTyepId);
    }

}