/*********************************************************************************
* Name:ASI_eForm_HK_VendorForm_TriggerTest
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 27/06/2018       Wilken        			[WL 1.0] Increase code coverage for Attachment controller
*********************************************************************************/
@isTest
public class ASI_eForm_HK_VendorForm_TriggerTest {
    
    Private Static Final String STATUS_BU_APPROVED_PENDING_MASTER_CREATION = 'BU Approved, Pending Master Creation';
    Private Static Final String STATUS_COMPLETED_MASTER_CREATION = 'Completed Master Creation';
    Private Static Final String STATUS_ARCHIVED = 'Archived';
    Private Static Final String STATUS_DRAFT = 'Draft';
    Private Static Final String SEARCH_TYPE_A = 'A';
    Private Static Final String FIX_APPROVAL_TYPE_NEW = 'Vendor Form - New';
    Private Static Final String FIX_APPROVAL_TYPE_REVISE = 'Vendor Form - Revise';
    
    Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New');
    Private Static Final Id NEW_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New_RO');
    Private Static Final Id REVISE_VENDOR_FORM_STEP_ONE_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise_Step_1');
    Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise');
    Private Static Final Id ARCHIVED_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Archived');
    Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank');
    Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank_RO');
    Private Static Final Id VENDOR_FORM_LINE_OTHER_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Other_Bank');
    Private Static Final Id VENDOR_FORM_LINE_OTHER_BANK_RT_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Other_Bank_RO');
    Private Static Final Id FIX_APPROVAL_RT = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_eForm_HK_Fix_Approval');
    
    Private Static List<ASI_CRM_Fix_Approval_Route__c> appList = new List<ASI_CRM_Fix_Approval_Route__c>();
    
    static testmethod void triggerTest() {
        
        //
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev0.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev0.pra@introv.com', CompanyName ='prhk', Department = 'IT');
        listUser.add(user);
        insert listUser;
        
        createApproval();
        
        System.runAs(user) {
            String newroRTId = ASI_MFM_Function.checkRecordType('ASI_eForm_Vendor_Form__c','ASI_eForm_HK_Vendor_Form_New_RO');
            
            ASI_eForm_Vendor_Form__c form1 = defaultForm();
            ASI_eForm_Vendor_Form__c form2 = defaultForm2();
            //insert new List<ASI_eForm_Vendor_Form__c>{form1,form2};
            insert new List<ASI_eForm_Vendor_Form__c>{form1, form2};
                
                List<ASI_eForm_Vendor_Form_Line_Item__c> tmpline = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
            tmpline.add(new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT
                                                               , ASI_eForm_Vendor_Form__c = form1.id
                                                              ));
            
            tmpline.add(new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT
                                                               , ASI_eForm_Vendor_Form__c = form1.id
                                                               , ASI_eForm_Currency__c = 'test'
                                                              ));
            
            Insert tmpline;
            
            List<ASI_eForm_Vendor_Form_Attachment__c> attList = new List<ASI_eForm_Vendor_Form_Attachment__c>();
            attList.add(new ASI_eForm_Vendor_Form_Attachment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_eForm_HK_Vendor_Form_Attachment')
                                                                , ASI_eForm_Vendor_Form__c = form1.id
                                                               ));
            
            Insert attList;
            Delete attList;
            
            ASI_eForm_Vendor_Form__c form3 = defaultForm3();
            form3.ASI_eForm_Alternate_Payee_Lookup__c = form2.id;
            ASI_eForm_Vendor_Form__c form4 = defaultForm4();
            insert new List<ASI_eForm_Vendor_Form__c>{form3,form4};
                
                form1.ASI_eForm_Phone_Fax_Number_1__c='22222';
            form1.ASI_eForm_Status__c = STATUS_DRAFT;
            update form1;
            form1.ASI_eForm_Status__c = STATUS_COMPLETED_MASTER_CREATION;
            form1.ASI_eForm_JDE_AB_Code__c = '19664';
            update form1;
            
            ASI_eForm_Vendor_Form__c form5 = defaultForm2();
            insert form5;
            form3.ASI_eForm_Prefix_1__c = '222';
            form3.ASI_eForm_Alternate_Payee_Lookup__c = form5.id;
            update form3;
            
            ASI_eForm_Vendor_Form__c form6 = defaultForm5();
            ASI_eForm_Vendor_Form__c form7 = defaultForm6();
            ASI_eForm_Vendor_Form__c form8 = defaultForm7();
            insert new List<ASI_eForm_Vendor_Form__c>{form6,form7, form8};
                
                form7.ASI_eForm_Related_Vendor_From__c = form1.id;
            
            Update form7;
            
            List<ASI_eForm_Vendor_Form_Line_Item__c> tmpline2 = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
            tmpline2.add(new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT
                                                                , ASI_eForm_Vendor_Form__c = form8.id
                                                                , ASI_eForm_Currency__c = 'test22'
                                                                , ASI_eForm_Bank__c = 'Other Bank'
                                                                , ASI_eForm_Bank_Name__c = 'test'
                                                                , ASI_eForm_SWIFT_Code__c = 'Test'
                                                                , ASI_eForm_Bank_Code__c = 'Test'
                                                                , ASI_eForm_Email_Address_1__c = null
                                                                , ASI_eForm_Bank_A_C_Number__c = 'Test'
                                                               ));
            
            tmpline2.add(new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT
                                                                , ASI_eForm_Vendor_Form__c = form8.id
                                                                , ASI_eForm_Currency__c = 'test'
                                                               ));
            
            
            
            
            List<ASI_eForm_Vendor_Form_Line_Item__c> aLineNonA =  new List<ASI_eForm_Vendor_Form_Line_Item__c>();
            aLineNonA.add( new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_OTHER_BANK_RT
                                                                  , ASI_eForm_Vendor_Form__c = form8.id
                                                                  , ASI_eForm_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar'
                                                                  , ASI_eForm_Bank__c = 'Other Bank'
                                                                  , ASI_eForm_Bank_Name__c = 'test'
                                                                  , ASI_eForm_SWIFT_Code__c = 'Test'
                                                                  , ASI_eForm_Bank_Code__c = 'Test'
                                                                  , ASI_eForm_Email_Address_1__c = null
                                                                  , ASI_eForm_Bank_A_C_Number__c = 'Test'
                                                                  , ASI_eForm_Bank_Country_Code__c = 'HK-HONG KONG'
                                                                 ));
            
            List<ASI_eForm_Vendor_Form_Line_Item__c> aLineNonB =  new List<ASI_eForm_Vendor_Form_Line_Item__c>();
            aLineNonB.add( new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT
                                                                  , ASI_eForm_Vendor_Form__c = form8.id
                                                                  //, ASI_eForm_Currency__c = 'test22'
                                                                  , ASI_eForm_Bank__c = 'Other Bank'
                                                                  , ASI_eForm_Bank_Name__c = 'Bank Name'
                                                                  , ASI_eForm_SWIFT_Code__c = '123456789012345'
                                                                  , ASI_eForm_Bank_Code__c = '123'
                                                                  , ASI_eForm_Email_Address_1__c = null
                                                                  , ASI_eForm_Bank_A_C_Number__c = '121212121'
                                                                  , ASI_eForm_Bank_Country_Code__c = 'US-U.S.A.'
                                                                  , ASI_eForm_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar'
                                                                  , ASI_eForm_IBAN_Code__c = '112'
                                                                 ));
            
            
            List<ASI_eForm_Vendor_Form_Line_Item__c> aLineNonC =  new List<ASI_eForm_Vendor_Form_Line_Item__c>();
            aLineNonC.add( new ASI_eForm_Vendor_Form_Line_Item__c(recordTypeId = VENDOR_FORM_LINE_KEY_BANK_RT
                                                                  , ASI_eForm_Vendor_Form__c = form8.id
                                                                  , ASI_eForm_Bank__c = 'DAH SING BANK LTD.'
                                                                  , ASI_eForm_Bank_Name__c = 'DAH SING BANK LTD.'
                                                                  , ASI_eForm_SWIFT_Code__c = '123456789012345'
                                                                  , ASI_eForm_Bank_Code__c = '040'
                                                                  , ASI_eForm_Email_Address_1__c = null
                                                                  , ASI_eForm_Bank_A_C_Number__c = ''
                                                                  , ASI_eForm_Bank_Country_Code__c = 'US-U.S.A.'
                                                                  , ASI_eForm_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar'
                                                                  , ASI_eForm_IBAN_Code__c = '040'
                                                                 ));
            
            
            
            
            test.startTest();
            
            
            try {
                insert aLineNonA; 
                delete aLineNonA;
            } catch (Exception e) {
            }
            try {
                insert aLineNonB;
                delete aLineNonB;
            } catch (Exception e) { 
            }
            try {
                insert aLineNonC;
                delete aLineNonC;
            } catch (Exception e) { 
            }
            
            Insert tmpline2;
            
            // ASI_eForm_HK_VendorFormLinesTriggerClass.beforeInsertFunction(aLineNonA);
            //  ASI_eForm_HK_VendorFormLinesTriggerClass.beforeInsertFunction(aLineNonB);
            //  ASI_eForm_HK_VendorFormLinesTriggerClass.beforeInsertFunction(aLineNonC);
            
            tmpline2[0].ASI_eForm_Bank__c = 'AUSTRALIA AND NEW ZEALAND BANKING GROUP LTD';
            tmpline2[0].ASI_eForm_Bank_Name__c = 'test2';
            tmpline2[0].ASI_eForm_SWIFT_Code__c = 'Test2';
            tmpline2[0].ASI_eForm_Bank_Code__c = 'Test2';
            
            update tmpline2;
            
            tmpline2[0].ASI_eForm_Bank__c = 'Other Bank';
            tmpline2[0].ASI_eForm_Bank_Name__c = 'test1';
            tmpline2[0].ASI_eForm_SWIFT_Code__c = 'Test1';
            tmpline2[0].ASI_eForm_Bank_Code__c = 'Test1';
            tmpline2[0].ASI_eForm_Currency__c = 'USD-U.S.A. - Dollar';
            
            update tmpline2;
            
            
            
            tmpline2[0].ASI_eForm_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar';
            //tmpline2[0].ASI_eForm_Bank_Name__c = '';
            tmpline2[0].ASI_eForm_SWIFT_Code__c = '';
            tmpline2[0].ASI_eForm_Bank_Code__c = 'TEST';
            tmpline2[0].ASI_eForm_Bank_A_C_Number__c = '';
            tmpline2[0].ASI_eForm_Bank_Country_Code__c = 'HK-HONG KONG';
            tmpline2[0].ASI_eForm_Bank__c = 'Other Bank';
            
            tmpline2[1].ASI_eForm_Currency__c = '';
            tmpline2[1].ASI_eForm_IBAN_Code__c = '';
            tmpline2[1].ASI_eForm_Bank_Code__c = 'TEST';
            tmpline2[1].ASI_eForm_Bank_A_C_Number__c = '';
            tmpline2[1].ASI_eForm_Bank_Country_Code__c = 'HK-HONG KONG';
            tmpline2[1].ASI_eForm_Bank__c = 'Other Bank';
            
            try{
                update tmpline2;
            } catch (Exception e) {
                
            }
            
            tmpline2[0].ASI_eForm_Bank__c =  'DAH SING BANK LTD.';
            //tmpline2[0].ASI_eForm_Bank_Name__c = '';
            tmpline2[0].ASI_eForm_SWIFT_Code__c = '';
            tmpline2[0].ASI_eForm_Bank_Code__c = '040';
            tmpline2[0].ASI_eForm_Bank_A_C_Number__c = '101010';
            tmpline2[0].ASI_eForm_Bank_Country_Code__c = 'HK-HONG KONG';
            
            try{
                update tmpline2;
            } catch (Exception e) {
                
            }
            
            delete tmpline2;
            delete form6;
            
            ASI_eForm_HK_VendorForm_PDF_PageCtrler tmpPDFctrl = new ASI_eForm_HK_VendorForm_PDF_PageCtrler(new ApexPages.StandardController(form1));
            ASI_eForm_HK_VendorForm_PDF_PageCtrler tmpPDFctrl2 = new ASI_eForm_HK_VendorForm_PDF_PageCtrler();
            tmpPDFctrl.dummyVar = false;
            tmpPDFctrl.formID = form1.id;
            tmpPDFctrl.init();
            tmpPDFctrl.getapprovalDetails();
            
            ASI_eForm_HK_VendorForm_PDF_PageCtrler.approvalDetail tmpAppDet = new ASI_eForm_HK_VendorForm_PDF_PageCtrler.approvalDetail();
            
            tmpAppDet.history = null;
            tmpAppDet.title = '';
            tmpAppDet.status = '';
            tmpAppDet.approvalDateTime = null;
            
            ASI_eForm_HK_VendorForm_TriggerClass.setApproverToNull(form1);
            ASI_eForm_HK_VendorForm_TriggerClass.setApprover(form1, appList[0], user);
            ASI_eForm_HK_VendorForm_TriggerClass.checkFieldModification(form1, new Map<Id, ASI_eForm_Vendor_Form__c>{form1.id => form1}, form2, new Map<Id, ASI_eForm_Vendor_Form_Line_Item__c>{tmpline[0].id => tmpline[0]});
            
            PageReference pageRef = Page.ASI_eForm_VendorFileAttachmentPage;
            
            pageRef.getParameters().put('id', form1.Id);
            
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(form1);
            
            ASI_eForm_VendorFileAttachmentController fileAttachCon = new ASI_eForm_VendorFileAttachmentController();
            
            Blob attachData = Blob.toPdf('Test');
            fileAttachCon.sObjParentId = form1.Id;
            fileAttachCon.attachmentObjType = 'ASI_eForm_Vendor_Form_Attachment__c';
            fileAttachCon.contentData = attachData;
            fileAttachCon.fileSize = attachData.size();
            fileAttachCon.contentFileName = 'Test.pdf';
            fileAttachCon.contentCategory = 'Others';
            //fileAttachCon.recordTypeName = 'ASI_eForm_HK_Vendor_Form_Attachment';
            
            PageReference returnPage = fileAttachCon.uploadAction();
            
            
            String nextPage = fileAttachCon.cancel().getUrl();
            
            //Test for class properties
            Boolean hasCategoryField = fileAttachCon.hasCategoryField;
            Integer uploadStepCount = fileAttachCon.getUploadStepCount();
            List<SelectOption> categories = fileAttachCon.categories;
            
            PageReference pageRef2 = Page.ASI_eForm_VendorFileAttachmentPage;
            
            pageRef2.getParameters().put('id', form1.Id);
            
            Test.setCurrentPage(pageRef2);
            
            ApexPages.StandardController stdCon2 = new ApexPages.StandardController(form1);
            
            ASI_eForm_VendorFileAttachmentController fileAttachCon2 = new ASI_eForm_VendorFileAttachmentController();
            
            Blob attachData2 = Blob.toPdf('Test');
            fileAttachCon2.sObjParentId = form1.Id;
            fileAttachCon2.attachmentObjType = 'ASI_eForm_Vendor_Form_Attachment__c';
            fileAttachCon2.contentData = attachData2;
            fileAttachCon2.fileSize = attachData2.size();
            fileAttachCon2.contentFileName = 'Test.pdf';
            fileAttachCon2.contentCategory = 'Others';
            
            PageReference returnPage2 = fileAttachCon2.uploadAction();
            
            /*[WL 1.0] BEGIN*/
            String label = fileAttachCon2.attachmentObjLabel;
            String type = fileAttachCon2.contentType;
            fileAttachCon2.market = 'SG';
            categories = fileAttachCon2.categories;
            
            PageReference returnPage3 = fileAttachCon2.uploadAction();
            /*[WL 1.0] END*/
            
        }
        test.stopTest();
        
    }
    
    static ASI_eForm_Vendor_Form__c defaultForm() {
        //VF-000288
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_JDE_AB_Code__c = '',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='Elaine Test V01',
                                            ASI_eForm_Address_Line_1__c='line1',
                                            ASI_eForm_Address_Line_2__c='line2',
                                            ASI_eForm_Address_Line_3__c='line3',
                                            ASI_eForm_Status__c='Draft',
                                            ASI_eForm_Country__c='AA-ARUBA',
                                            ASI_eForm_Prefix_1__c='852',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='11111',
                                            ASI_eForm_Payment_Term__c='095-Open A/C 95 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='NO',
                                            ASI_eForm_MFM_Access__c='YES',
                                            //ASI_eForm_Freight_Handling_Code__c='U-Delivered, Duty UnPaid',
                                            ASI_eForm_Payment_Method__c='Autopaid',
                                            ASI_eForm_Default_Currency__c='DZD-Algeria - Dinar',
                                            ASI_eForm_Class_Code__c='ADVP',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V');
    }
    static ASI_eForm_Vendor_Form__c defaultForm2() {
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_Vendor_Account_Number__c='',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='JF',
                                            ASI_eForm_Address_Line_1__c='singapore',
                                            ASI_eForm_Address_Line_2__c='sg',
                                            ASI_eForm_Address_Line_3__c='sg',
                                            ASI_eForm_Status__c='Completed Master Creation',
                                            ASI_eForm_Country__c='SG-SINGAPORE',
                                            ASI_eForm_Prefix_1__c='853',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='DFAD',
                                            ASI_eForm_Payment_Term__c='030-Open A/C 30 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='NO',
                                            ASI_eForm_MFM_Access__c='YES',
                                            ASI_eForm_Freight_Handling_Code__c='',
                                            ASI_eForm_Payment_Method__c='Autopaid',
                                            ASI_eForm_Default_Currency__c='SGD-Singapore - Singapore Dollar',
                                            ASI_eForm_Class_Code__c='ADVP',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V');
    }
    static ASI_eForm_Vendor_Form__c defaultForm3() {
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_Vendor_Account_Number__c='',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='toll global',
                                            ASI_eForm_Address_Line_1__c='singapore',
                                            ASI_eForm_Address_Line_2__c='sg',
                                            ASI_eForm_Address_Line_3__c='',
                                            ASI_eForm_Status__c='Completed Master Creation',
                                            ASI_eForm_Country__c='SG-SINGAPORE',
                                            ASI_eForm_Prefix_1__c='2222',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='2222',
                                            ASI_eForm_Payment_Term__c='030-Open A/C 30 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='YES',
                                            ASI_eForm_MFM_Access__c='YES',
                                            ASI_eForm_Freight_Handling_Code__c='',
                                            ASI_eForm_Payment_Method__c='Cheque',
                                            ASI_eForm_Default_Currency__c='SGD-Singapore - Singapore Dollar',
                                            ASI_eForm_Class_Code__c='ADVP',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V');
    }
    static ASI_eForm_Vendor_Form__c defaultForm4() {
        // copy from b6 VF-000525
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_Vendor_Account_Number__c='',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='123 ltd',
                                            ASI_eForm_Address_Line_1__c='hk',
                                            ASI_eForm_Address_Line_2__c='',
                                            ASI_eForm_Address_Line_3__c='',
                                            ASI_eForm_Status__c='BU Approved, Pending Master Creation',
                                            ASI_eForm_Country__c='HK-HONG KONG',
                                            ASI_eForm_Prefix_1__c='999',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='999',
                                            ASI_eForm_Payment_Term__c='060-Open A/C 60 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='NO',
                                            ASI_eForm_MFM_Access__c='YES',
                                            ASI_eForm_Freight_Handling_Code__c='',
                                            ASI_eForm_Payment_Method__c='Cheque',
                                            ASI_eForm_Default_Currency__c='HKD-Hong Kong - Hong Kong Dollar',
                                            ASI_eForm_Class_Code__c='TRHK',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V'
                                           );
    }
    
    static ASI_eForm_Vendor_Form__c defaultForm5() {
        
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=REVISE_VENDOR_FORM_STEP_ONE_RT,
                                            ASI_eForm_JDE_AB_Code__c = '19664'
                                           );
    }
    
    static ASI_eForm_Vendor_Form__c defaultForm6() {
        // copy from b6 VF-000525
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=ARCHIVED_VENDOR_FORM_RT,
                                            ASI_eForm_Vendor_Account_Number__c='',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='123 ltd',
                                            ASI_eForm_Address_Line_1__c='hk',
                                            ASI_eForm_Address_Line_2__c='',
                                            ASI_eForm_Address_Line_3__c='',
                                            ASI_eForm_Status__c='BU Approved, Pending Master Creation',
                                            ASI_eForm_Country__c='HK-HONG KONG',
                                            ASI_eForm_Prefix_1__c='999',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='999',
                                            ASI_eForm_Payment_Term__c='060-Open A/C 60 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='NO',
                                            ASI_eForm_MFM_Access__c='YES',
                                            ASI_eForm_Freight_Handling_Code__c='',
                                            ASI_eForm_Payment_Method__c='Cheque',
                                            ASI_eForm_Default_Currency__c='HKD-Hong Kong - Hong Kong Dollar',
                                            ASI_eForm_Class_Code__c='TRHK',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V',
                                            ASI_eForm_Clone_From_Orginal__c = true
                                           );
    }
    
    static ASI_eForm_Vendor_Form__c defaultForm7() {
        // copy from b6 VF-000525
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_Vendor_Account_Number__c='',
                                            ASI_eForm_Vendor_Master__c=false,
                                            ASI_eForm_Vendor_Name__c='123 ltd',
                                            ASI_eForm_Address_Line_1__c='hk',
                                            ASI_eForm_Address_Line_2__c='',
                                            ASI_eForm_Address_Line_3__c='',
                                            ASI_eForm_Status__c='Draft',
                                            ASI_eForm_Country__c='HK-HONG KONG',
                                            ASI_eForm_Prefix_1__c='999',
                                            ASI_eForm_Phone_Fax_1__c='Phone',
                                            ASI_eForm_Phone_Fax_Number_1__c='999',
                                            ASI_eForm_Payment_Term__c='060-Open A/C 60 Days',
                                            ASI_eForm_Bank_Charges__c='S',
                                            ASI_eForm_Alternate_Payee__c='NO',
                                            ASI_eForm_MFM_Access__c='YES',
                                            ASI_eForm_Freight_Handling_Code__c='',
                                            ASI_eForm_Payment_Method__c='Cheque',
                                            ASI_eForm_Default_Currency__c='HKD-Hong Kong - Hong Kong Dollar',
                                            ASI_eForm_Class_Code__c='TRHK',
                                            ASI_eForm_CAT_Code_15__c='901',
                                            ASI_eForm_Synced_to_JDE__c=true,
                                            ASI_eForm_Search_Type__c='V',
                                            ASI_eForm_Clone_From_Orginal__c = true
                                           );
    }
    
    static void createApproval() {
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user1 = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com', CompanyName ='prhk', Department = 'IT');
        listUser.add(user1);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com', CompanyName ='prhk', Department = 'IT');
        listUser.add(user2);
        User user3 = new User(Alias = 'standt', Email='dev3.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev3.pra@introv.com', CompanyName ='prhk', Department = 'IT');
        listUser.add(user3);
        insert listUser;
        
        id rtid = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_eForm_HK_Fix_Approval');
        
        ASI_CRM_Fix_Approval_Route__c aRoute = new ASI_CRM_Fix_Approval_Route__c (RecordTypeId=rtid, ASI_CRM_CN_Approver_1__c=user1.id,ASI_CRM_CN_Type__c='Vendor Form - New',ASI_CRM_Company__c='prhk');
        ASI_CRM_Fix_Approval_Route__c bRoute = new ASI_CRM_Fix_Approval_Route__c (RecordTypeId=rtid, ASI_CRM_CN_Approver_1__c=user2.id,ASI_CRM_CN_Approver_2__c=user3.id,ASI_CRM_CN_Type__c='Vendor Form - New',ASI_CRM_Company__c='prhk');
        ASI_CRM_Fix_Approval_Route__c cRoute = new ASI_CRM_Fix_Approval_Route__c (RecordTypeId=rtid, ASI_CRM_CN_Approver_1__c=user3.id,ASI_CRM_CN_Type__c='Vendor Form - Revise',ASI_CRM_Company__c='prhk');
        appList.add(aRoute);
        appList.add(bRoute);
        appList.add(cRoute);
        insert appList;        
    }
}