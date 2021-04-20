/*********************************************************************************
 * Name:ASI_CRM_JP_AccountsAdditionalField_Test
 * Description: Test Class for AccountsAdditionalField of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/12/2014       Laputa: Hank          Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_AccountsAdditionalField_Test {
    
    //Test Method for Class ASI_CRM_JP_CustomerTgrHdlr
    //Can also handle Class ASI_CRM_JP_Insert_CustomerDir and Class ASI_CRM_JP_DeleteAccCusDirAfterCus
    static testMethod void ASI_CRM_JP_CustomerTgrHdlr_Test(){
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
        ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test1');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('1234567');
        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_JP_TestClassHelper.createCustomer();
        customer.ASI_TH_CRM_OutletType__c = outletType.Id;
        customer.ASI_CRM_PostalCode__c= postalCode.Name;
        customer.Name = 'Test1';
        
        test.startTest();
        //test upadte
        update customer;
        //test delete
        delete customer;
        test.stopTest();
    }
    
    //Test for ASI_CRM_JP_CheckPrimarySupplier
    static testMethod void ASI_CRM_JP_CheckPrimarySupplier_Test(){
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_JP_TestClassHelper.createCustomer();
        ASI_CRM_Regular_Supplier__c sup = new ASI_CRM_Regular_Supplier__c(ASI_CRM_Customer__c = customer.Id, ASI_CRM_Primary__c = true);
        ASI_CRM_Regular_Supplier__c sup2 = new ASI_CRM_Regular_Supplier__c(ASI_CRM_Customer__c = customer.Id, ASI_CRM_Primary__c = false);
        List<ASI_CRM_Regular_Supplier__c> supList = new List<ASI_CRM_Regular_Supplier__c>();
        supList.add(sup);
        supList.add(sup2);
        
        test.startTest();
        insert supList;
        sup2.ASI_CRM_Primary__c = true;
        update sup2;
        test.stopTest();
    }
    
    //Test for ASI_CRM_JP_PostalCodeValidation
    static testMethod void ASI_CRM_JP_PostalCodeValidation_Test(){
        ASI_CRM_Postal_Code__c postal1 = new ASI_CRM_Postal_Code__c(Name = '1234567', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'));
        ASI_CRM_Postal_Code__c postal2 = new ASI_CRM_Postal_Code__c(Name = '1234567', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'));
        ASI_CRM_Postal_Code__c postal3 = new ASI_CRM_Postal_Code__c(Name = '12345671', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'));
        ASI_CRM_Postal_Code__c postal4 = new ASI_CRM_Postal_Code__c(Name = '1235678', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Postal_Code__cASI_CRM_JP_Postal_Code'));
        
        test.startTest();
        insert postal1;
        insert postal4;
        try{
            insert postal2;
        }catch(Exception e){
            
        }
        try{
            insert postal3;
        }catch(Exception e){
            
        }
        try{
            postal4.name = '1234567';
            update postal4;
        }catch(Exception e){
            
        }
        try{
            postal4.name = '12345678';
            update postal4;
        }catch(Exception e){
            
        }
        test.stopTest();
    }
}