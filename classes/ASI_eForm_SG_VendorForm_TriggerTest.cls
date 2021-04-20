/*********************************************************************************
 * Name:ASI_eForm_SG_VendorForm_TriggerTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2018       Wilken                  Created
*********************************************************************************/
@isTest
public class ASI_eForm_SG_VendorForm_TriggerTest {
    Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_SG_Vendor_Form_New');
    Private Static Final Id NEW_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_SG_Vendor_Form_New_Read_Only');
    Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_SG_Vendor_Form_Revise');
    Private Static Final Id REVISE_VENDOR_FORM_ALL_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_SG_Vendor_Form_Revise_All');
    Private Static Final Id REVISE_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_SG_Vendor_Form_Revise_All_Read_Only');
    
    static testmethod void triggerTest_Main() {
        ASI_MFM_Exchange_Rate__c exRate = defaultExchangeRate();
        insert exRate;
        
        User user = defaultUser();
        
        test.startTest();
        System.runAs(user) {
            ASI_eForm_Vendor_Form__c vForm = defaultForm();
            insert vForm;
            
            vForm.ASI_eForm_Company_Name_Text__c = 'Test 2';
            update vForm;
            
            vForm.ASI_eForm_Initial_Purchase_Value__c = 100000;
            vForm.recordTypeId = NEW_VENDOR_FORM_READONLY_RT;
            vForm.ASI_eForm_Status__c = 'Completed';
            update vForm;
            
            ASI_eForm_Vendor_Form__c revisedForm = defaultForm();
            revisedForm.recordTypeId = REVISE_VENDOR_FORM_RT;
            revisedForm.ASI_eForm_Original_Vendor_Form__c = vForm.Id;
            insert revisedForm;
            
            revisedForm.recordTypeId = REVISE_VENDOR_FORM_ALL_RT;
            update revisedForm;
            
            try {
                delete vForm;
            }
            catch (Exception e){
            }
        }
        
        test.stopTest();
    }
    
    static testmethod void triggerTest_NegativeCase() {
        ASI_MFM_Exchange_Rate__c exRate = defaultExchangeRate();
        insert exRate;
        
        User user = defaultUser();
        
        test.startTest();
        System.runAs(user) {
            ASI_eForm_Vendor_Form__c vForm = defaultForm();
            vForm.ASI_eForm_Requires_HOD_Approval__c = true;
            insert vForm;
            
            update vForm;
            
            try {
                vForm.ASI_eForm_Supplier_Country_of_Operation__c = 'B';
                vForm.ASI_eForm_Status__c = 'Submitted';
                update vForm;
            }
            catch (Exception e){
            }
        }
        
        test.stopTest();
    }
    static ASI_eForm_Vendor_Form__c defaultForm() {
        return new ASI_eForm_Vendor_Form__c(RecordTypeId=NEW_VENDOR_FORM_RT,
                                            ASI_eForm_Company_Name_Text__c = 'Test',
                                            ASI_eForm_Payee_Name__c = 'Test',
                                            ASI_eForm_Address_Line_1__c = 'Test',
                                            ASI_eForm_Contact_Person__c = 'Test',
                                            ASI_eForm_Tel_Number__c = '123',
                                            ASI_eForm_Email__c = 'test@test.com',
                                            ASI_eForm_Biz_Registration_No__c = '123456789',
                                            ASI_eForm_Business_Type__c = 'Sole Prioprietor',
                                            ASI_eForm_Payment_Term__c = '0-Direct Payment',
                                            ASI_eForm_Supplier_Country_of_Operation__c = 'V',
                                            ASI_eForm_GST_Registered__c = 'Yes',
                                            ASI_eForm_Market_Created_For__c = 'SG',
                                            ASI_eForm_Payment_Instrument__c = 'N-Payment Transfer',
                                            ASI_eForm_Bankers_1__c = 'Test',
                                            ASI_eForm_Bank_Branch_1__c = 'ABC',
                                            ASI_eForm_SWIFT_Code_1__c = 'Test',
                                            ASI_eForm_Bank_Account_Number_1__c = 'Test',
                                            ASI_eForm_Initial_Purchase_Value__c = 100,
                                            ASI_eForm_Currency__c = 'SGD',
                                            ASI_eForm_Supplier_Identification__c = 'Individual',
                                            ASI_eForm_Type_Of_Goods__c = 'Admin',
                                            
                                            ASI_eForm_Company_Name_Latest__c = 'Test',
                                            ASI_eForm_Biz_Registration_No_Latest__c = '123456789',
                                            ASI_eForm_Contact_Person_Latest__c = 'Test',
                                            ASI_eForm_Fax_Number_Latest__c = '123',
                                            ASI_eForm_Tel_Number_Latest__c = '123',
                                            ASI_eForm_Bank_Branch_1_Latest__c = 'ABC',
                                            ASI_eForm_Bank_Account_Number_1_Latest__c = 'Test',
                                            ASI_eForm_SWIFT_Code_1_Latest__c = 'Test'
                                            );
    }
    
    static  ASI_MFM_Exchange_Rate__c defaultExchangeRate() {
        return new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c = 'SG',
                                            ASI_MFM_Effective_Date__c = System.Today(),
                                            ASI_MFM_Application__c = 'MFM',
                                            ASI_MFM_Base_Currency__c = 'SGD',
                                            ASI_MFM_Counter_Currency__c = 'SGD',
                                            ASI_MFM_Exchange_Rate__c = 1
                                            );
    } 
    
    static User defaultUser(){
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='sg.vForm@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Department = 'Administration',
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='tammy.cai@pernod-ricard.com.sgVFormTest', CompanyName ='Pernod Ricard Singapore');
        listUser.add(user);
        insert listUser;
        
        return user;
    }
}