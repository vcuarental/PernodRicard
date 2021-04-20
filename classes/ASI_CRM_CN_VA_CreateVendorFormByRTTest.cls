@isTest
private class ASI_CRM_CN_VA_CreateVendorFormByRTTest {
    static testMethod void addKeydataInstance() {
      Map <String,Schema.RecordTypeInfo> recordTypeVFMap = ASI_eForm_Vendor_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id cnVendor1NewRtId = recordTypeVFMap.get('CN Vendor Form - 1 - New').getRecordTypeId();
      ASI_eForm_Vendor_Form__c vendorFromInstance = new ASI_eForm_Vendor_Form__c();
      vendorFromInstance.recordtypeid = cnVendor1NewRtId;
      vendorFromInstance.ASI_CRM_CN_VA_Requestor_Region__c = 'HQ';
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Code__c = '222';
      vendorFromInstance.ASI_CRM_CN_VA_Department__c = 'sales';
      vendorFromInstance.ASI_CRM_CN_VA_Company_Name__c = '湖南制造有限公司';
      vendorFromInstance.ASI_CRM_CN_VA_Postal_Code__c = '4353';
      vendorFromInstance.ASI_CRM_CN_VA_Address__c = '湖南';
      vendorFromInstance.ASI_CRM_CN_VA_Phone_Number__c = '17345678765';
      vendorFromInstance.ASI_CRM_CN_VA_Contact_Person__c = '张三';
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Form_A1__c = '1234@qq.com';
      vendorFromInstance.ASI_CRM_CN_VA_Payment_Term__c = '60';
      vendorFromInstance.ASI_CRM_CN_VA_Invoice_Category__c = 'VAT special invoices 增值税专用发票';
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Form_A2__c = '123456789098765432';
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Form_A3__c = Date.today();
      vendorFromInstance.ASI_CRM_CN_VA_Trans_Bank_Name__c = '上海银行';
      vendorFromInstance.ASI_CRM_CN_VA_Region__c = 'All';
      vendorFromInstance.ASI_CRM_CN_VA_Expense_Type__c = 'Both(Trade & Consumer A&P)';
      vendorFromInstance.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance.ASI_CRM_CN_VA_Category__c = 'PR';
      vendorFromInstance.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Form_A5__c = 'Yes';
      vendorFromInstance.ASI_CRM_CN_VA_Tax_rate__c = '1%';
      insert vendorFromInstance;
      ASI_CRM_CN_VA_CreateVendorFormByRT.CreateVendorFormByRT(vendorFromInstance.id,vendorFromInstance.Name,'ASI_CRM_CN_VA_Vendor_Form_BP_Key_Data');
      ASI_CRM_CN_VA_CreateVendorFormByRT.CreateVendorFormByRT(vendorFromInstance.id,vendorFromInstance.Name,'ASI_CRM_CN_VA_Vendor_Form_Annex_1_Vendor');
      ASI_CRM_CN_VA_CreateVendorFormByRT.CreateVendorFormByRT(vendorFromInstance.id,vendorFromInstance.Name,'ASI_CRM_CN_VA_Vendor_Form_Revise');
    }
    
    static testMethod void addAnnix1Instance() {
        
    }
}