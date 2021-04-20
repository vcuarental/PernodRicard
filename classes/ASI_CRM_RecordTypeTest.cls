@isTest
public class ASI_CRM_RecordTypeTest {

	@isTest
	static void testRecordTypeEnums() {

		System.assertNotEquals(null, ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.values());
		System.assertNotEquals(null, ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.values());
		System.assertNotEquals(null, ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.values());
		System.assertNotEquals(null, ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.values());

		final ASI_CRM_RecordType recordType  = new ASI_CRM_RecordType();
	}

}