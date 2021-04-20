@isTest
private class ASI_CRM_CN_VA_VendorForm_TriggerTest {
    static testMethod void vendorFormInsertOrUpdate() {
      Test.startTest();

      Map <String,Schema.RecordTypeInfo> recordTypeVFMap = ASI_eForm_Vendor_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id cnVendor1NewRtId = recordTypeVFMap.get('CN Vendor Form - 1 - New').getRecordTypeId();
      Map <String,Schema.RecordTypeInfo> recordTypeAccMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id accRtId = recordTypeAccMap.get('CN Structure Cost Supplier').getRecordTypeId();
      
      Account accInstance= new Account();
      accInstance.recordtypeId = accRtId;
      accInstance.Name = '湖北有限公司';
      accInstance.ASI_MFM_Customer_Supplier_Number__c = '111';
      accInstance.ASI_TH_CRM_Supplier__c = '四川保利';
      accInstance.ASI_LUX_Email_Business__c = '1234@qq.com';
      insert accInstance;

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

      ASI_eForm_VendorFileAttachmentController fileAttachCon = new ASI_eForm_VendorFileAttachmentController();
            
      Blob attachData = Blob.toPdf('Test');
      fileAttachCon.sObjParentId = vendorFromInstance.Id;
      fileAttachCon.attachmentObjType = 'ASI_eForm_Vendor_Form_Attachment__c';
      fileAttachCon.contentData = attachData;
      fileAttachCon.fileSize = attachData.size();
      fileAttachCon.contentFileName = 'Test.pdf';
      fileAttachCon.contentCategory = 'Others';

      PageReference returnPage = fileAttachCon.uploadAction();

      String nextPage = fileAttachCon.cancel().getUrl();

      Boolean hasCategoryField = fileAttachCon.hasCategoryField;
      Integer uploadStepCount = fileAttachCon.getUploadStepCount();
      List<SelectOption> categories = fileAttachCon.categories;

      Test.stopTest();

      Id cnVendor1NewRtId_Revise = recordTypeVFMap.get('CN Vendor Form - 2 - Revise').getRecordTypeId();
      
      ASI_eForm_Vendor_Form__c vendorFromInstance_Revise = new ASI_eForm_Vendor_Form__c();
      vendorFromInstance_Revise.recordtypeid = cnVendor1NewRtId_Revise;
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Related_Vendor_Form__c = vendorFromInstance.Id;
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Requestor_Region__c = 'HQ';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Vendor_Code__c = '222';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Department__c = 'sales';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Company_Name__c = '湖南制造有限公司_Revise';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Postal_Code__c = '4353';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Address__c = '湖南';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Phone_Number__c = '17345678765';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Contact_Person__c = '张三';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Vendor_Form_A1__c = '1234@qq.com';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Payment_Term__c = '60';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Invoice_Category__c = 'VAT special invoices 增值税专用发票';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Vendor_Form_A2__c = '123456789098765432_Revise';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Vendor_Form_A3__c = Date.today();
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Trans_Bank_Name__c = '上海银行';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Region__c = 'All';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Expense_Type__c = 'Both(Trade & Consumer A&P)';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Category__c = 'PR';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Vendor_Form_A5__c = 'Yes';
      vendorFromInstance_Revise.ASI_CRM_CN_VA_Tax_rate__c = '1%';
      insert vendorFromInstance_Revise;

      ASI_eForm_VendorFileAttachmentController fileAttachCon_Revise = new ASI_eForm_VendorFileAttachmentController();
            
      Blob attachData_Revise = Blob.toPdf('Test');
      fileAttachCon_Revise.sObjParentId = vendorFromInstance_Revise.Id;
      fileAttachCon_Revise.attachmentObjType = 'ASI_eForm_Vendor_Form_Attachment__c';
      fileAttachCon_Revise.contentData = attachData_Revise;
      fileAttachCon_Revise.fileSize = attachData_Revise.size();
      fileAttachCon_Revise.contentFileName = 'Test.pdf';
      fileAttachCon_Revise.contentCategory = 'Others';

      PageReference returnPage_Revise = fileAttachCon_Revise.uploadAction();

      String nextPage_Revise = fileAttachCon_Revise.cancel().getUrl();

      Boolean hasCategoryField_Revise = fileAttachCon_Revise.hasCategoryField;
      Integer uploadStepCount_Revise = fileAttachCon_Revise.getUploadStepCount();
      List<SelectOption> categories_Revise = fileAttachCon_Revise.categories;

      Id keyDataRtId = recordTypeVFMap.get('CN Vendor Form - 3 - BP Key Data').getRecordTypeId();
      ASI_eForm_Vendor_Form__c vendorFromKeyDataInstance = new ASI_eForm_Vendor_Form__c();
      vendorFromKeyDataInstance.recordtypeId = keyDataRtId;
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_BP_A3__c = '>= RMB 2 million';
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Specific_Instructions__c = 'Reason';
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Related_Vendor_Form__c = vendorFromInstance.id;
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Category__c = 'PR';
      insert vendorFromKeyDataInstance;

      Id annex1RtId = recordTypeVFMap.get('CN Vendor Form - 4 - Annex 1-Vendor').getRecordTypeId();
      ASI_eForm_Vendor_Form__c vendorFromAnnex1Instance = new ASI_eForm_Vendor_Form__c();
      vendorFromAnnex1Instance.recordtypeId = annex1RtId;
      vendorFromAnnex1Instance.ASI_CRM_CN_VA_Related_Vendor_Form__c = vendorFromInstance.id;
      vendorFromAnnex1Instance.ASI_CRM_CN_VA_Category__c = 'PR';
      insert vendorFromAnnex1Instance;
      List<ASI_eForm_Vendor_Form__c> keyDataOrAnnex1List = new List<ASI_eForm_Vendor_Form__c>();
      
      keyDataOrAnnex1List.add(vendorFromKeyDataInstance);
      keyDataOrAnnex1List.add(vendorFromAnnex1Instance);

      delete keyDataOrAnnex1List;

    }


    static testMethod void vendorFormUpdate(){
      Test.startTest();

      User u2 = TestFactory.createUserWithProfile('admin2', 'System Administrator');
      u2.CompanyName = 'Pernod Ricard China';
      insert u2;
      User u = TestFactory.createUserWithProfile('admin', 'System Administrator');
      u.CompanyName = 'Pernod Ricard China';
      u.ManagerId = u2.id;
      insert u;
      Map <String,Schema.RecordTypeInfo> recordTypeARMap = ASI_CRM_Fix_Approval_Route__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id approvalRouteRtId = recordTypeARMap.get('CN Fix Approval Route').getRecordTypeId();
      
      Map <String,Schema.RecordTypeInfo> recordTypeVFMap = ASI_eForm_Vendor_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id cnVendor1NewRtId = recordTypeVFMap.get('CN Vendor Form - 1 - New').getRecordTypeId();
      Map <String,Schema.RecordTypeInfo> recordTypeAccMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id accRtId = recordTypeAccMap.get('CN Structure Cost Supplier').getRecordTypeId();
      Map <String,Schema.RecordTypeInfo> recordTypeDARMap = ASI_CRM_Dynamic_Approval_Route__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id dArRtId = recordTypeDARMap.get('CN Dynamic Approval Route').getRecordTypeId();

      ASI_CRM_Fix_Approval_Route__c approvalRouteInstance = new ASI_CRM_Fix_Approval_Route__c();
      approvalRouteInstance.recordtypeId = approvalRouteRtId;
      approvalRouteInstance.ASI_CRM_CN_Type__c = 'Vendor Form - New';
      insert approvalRouteInstance;

      ASI_CRM_Dynamic_Approval_Route__c dynamicApprovalRoute = new ASI_CRM_Dynamic_Approval_Route__c();
      dynamicApprovalRoute.ASI_CRM_Type__c = 'Vendor Form';
      //dynamicApprovalRoute.ASI_CRM_End_of_Dynamic_Route__c = ;
      //dynamicApprovalRoute.ASI_CRM_User__c = ;
      //dynamicApprovalRoute.ASI_CRM_Approval_Limit__c = ;
      //dynamicApprovalRoute.ASI_CRM_Manager_ID__c = ;
      dynamicApprovalRoute.RecordTypeId = dArRtId;
      insert dynamicApprovalRoute;

      Account accInstance= new Account();
      accInstance.recordtypeId = accRtId;
      accInstance.Name = '湖北有限公司';
      accInstance.ASI_MFM_Customer_Supplier_Number__c = '111';
      accInstance.ASI_TH_CRM_Supplier__c = '四川保利';
      accInstance.ASI_LUX_Email_Business__c = '1234@qq.com';
      insert accInstance;
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
      vendorFromInstance.ASI_eForm_Status__c = 'Approved';
      vendorFromInstance.ASI_CRM_CN_VA_Vendor_Code__c = '111';
      vendorFromInstance.ownerId = u.id;
      update vendorFromInstance;

      Test.stopTest();
    }
    static testMethod void vendorFormToBpKeyDataUpdate(){
      Test.startTest();

      Map <String,Schema.RecordTypeInfo> recordTypeVFMap = ASI_eForm_Vendor_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id cnVendor1NewRtId = recordTypeVFMap.get('CN Vendor Form - 1 - New').getRecordTypeId();
      Map <String,Schema.RecordTypeInfo> recordTypeAccMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
      Id accRtId = recordTypeAccMap.get('CN Structure Cost Supplier').getRecordTypeId();

      ASI_eForm_Vendor_Form__c vendorFromInstance2 = new ASI_eForm_Vendor_Form__c();
      vendorFromInstance2.recordtypeid = cnVendor1NewRtId;
      vendorFromInstance2.ASI_CRM_CN_VA_Requestor_Region__c = 'HQ';
      vendorFromInstance2.ASI_CRM_CN_VA_Department__c = 'sales';
      vendorFromInstance2.ASI_CRM_CN_VA_Company_Name__c = '湖南制造有限公司';
      vendorFromInstance2.ASI_CRM_CN_VA_Postal_Code__c = '4353';
      vendorFromInstance2.ASI_CRM_CN_VA_Address__c = '湖南';
      vendorFromInstance2.ASI_eForm_Status__c = 'Draft';
      vendorFromInstance2.ASI_CRM_CN_VA_Phone_Number__c = '17345678765';
      vendorFromInstance2.ASI_CRM_CN_VA_Contact_Person__c = '张三';
      vendorFromInstance2.ASI_CRM_CN_VA_Vendor_Form_A1__c = '1234@qq.com';
      vendorFromInstance2.ASI_CRM_CN_VA_Payment_Term__c = '60';
      vendorFromInstance2.ASI_CRM_CN_VA_Invoice_Category__c = 'VAT special invoices 增值税专用发票';
      vendorFromInstance2.ASI_CRM_CN_VA_Vendor_Form_A2__c = '123456789098765432';
      vendorFromInstance2.ASI_CRM_CN_VA_Vendor_Form_A3__c = Date.today();
      vendorFromInstance2.ASI_CRM_CN_VA_Trans_Bank_Name__c = '上海银行';
      vendorFromInstance2.ASI_CRM_CN_VA_Region__c = 'All';
      vendorFromInstance2.ASI_CRM_CN_VA_Expense_Type__c = 'Both(Trade & Consumer A&P)';
      vendorFromInstance2.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance2.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance2.ASI_CRM_CN_VA_Category__c = 'PR';
      vendorFromInstance2.ASI_CRM_CN_VA_Purchase_Description__c = '卖酒';
      vendorFromInstance2.ASI_CRM_CN_VA_Purchase_Amount__c = 75000;
      vendorFromInstance2.ASI_CRM_CN_VA_Vendor_Form_A5__c = 'Yes';
      vendorFromInstance2.ASI_CRM_CN_VA_Tax_rate__c = '1%';
      insert vendorFromInstance2;
      Id keyDataRtId = recordTypeVFMap.get('CN Vendor Form - 3 - BP Key Data').getRecordTypeId();
      ASI_eForm_Vendor_Form__c vendorFromKeyDataInstance = new ASI_eForm_Vendor_Form__c();
      vendorFromKeyDataInstance.recordtypeId = keyDataRtId;
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_BP_A4__c = '';
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Specific_Instructions__c = 'Reason';
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Related_Vendor_Form__c = vendorFromInstance2.id;
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_Category__c = 'PR';
      insert vendorFromKeyDataInstance;
      vendorFromKeyDataInstance.ASI_CRM_CN_VA_BP_A4__c = 'Yes';
      update vendorFromKeyDataInstance;

      Test.stopTest();
    }
}