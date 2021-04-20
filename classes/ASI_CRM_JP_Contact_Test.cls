/*********************************************************************************
 * Name:ASI_CRM_JP_Contact_Test
 * Description: Test Class for ASI CRM Contact CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 7/1/2015       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_Contact_Test {
    static testMethod void ASI_CRM_JP_ContactTgrHdlr_Test() {
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Customer_Code', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 12, ASI_HK_CRM_Format__c = '900{00000}', ASI_HK_CRM_Running_Number__c = 2);
        ASI_TH_CRM_OutletType__c outletType1 = new ASI_TH_CRM_OutletType__c(Name = 'Test1');
        ASI_CRM_Postal_Code__c postalCode1 = new ASI_CRM_Postal_Code__c(Name ='1111111');
        insert outletType1;
        insert postalCode1;
        ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType1.Id, ASI_CRM_PostalCode__c= postalCode1.Name);
        test.startTest();
        insert customer1;
        Contact con = new Contact(LastName = 'Test', RecordTypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_JP_Contact'), ASI_CRM_AccountAdditionalField__c = customer1.Id);
        insert con;
        update con;
        test.stopTest();
    }
}