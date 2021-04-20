@isTest
public class ASI_HK_CRM_DelButton_Test {
	static testMethod void Del_Test()
    {
        ASI_CRM_EDI_Invoice_Header__c Test = new ASI_CRM_EDI_Invoice_Header__c(
        	ASI_CRM_Invoice_Number__c = 'Test',
            ASI_CRM_Delivery_Date__c = Date.today(),
            ASI_CRM_Invoice_Date__c = Date.today()
        );
        
        insert Test;
        String Result = ASI_HK_CRM_DelButton.DelButton(Test.Id);
    }
}