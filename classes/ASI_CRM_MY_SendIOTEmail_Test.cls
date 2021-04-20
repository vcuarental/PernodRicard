@isTest 
public class ASI_CRM_MY_SendIOTEmail_Test 
{
    static testMethod void SendIOTEmailTest() 
    {
        Id headerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader');
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
	
        ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
        ASI_MFM_SKU_Code__c sku = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
        
        ASI_CRM_IOTHeader__c header = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = headerRecTypeID
        );
        insert header;
        
        ASI_CRM_IOTLine__c line = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = header.Id,
            ASI_CRM_SKU__c = sku.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1
        );
        insert line;

        Test.startTest();
        
        ASI_CRM_MY_SendIOTEmailScheduler sh1 = new ASI_CRM_MY_SendIOTEmailScheduler();
        String sch = '0 0 * * * ?'; 
        system.schedule('Send IOT Email Scheduler Check', sch, sh1); 
        
        ASI_CRM_MY_WebService.sendIOTEmail(header.Id);
    
        Test.stopTest();
    }
}