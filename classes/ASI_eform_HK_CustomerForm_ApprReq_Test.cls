@isTest
public class ASI_eform_HK_CustomerForm_ApprReq_Test {
    
    static ASI_eForm_Customer_Form__c defaultForm() {
        
        return new ASI_eForm_Customer_Form__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRATR_Parent_Original'),
											ASI_eForm_Customer_Name__c 		= 'Test',
											ASI_eForm_Address_Line_1__c		= 'add1',
											ASI_eForm_Address_Line_2__c		= 'add2',
											ASI_eForm_Address_Line_3__c		= 'add3',
											ASI_eForm_Contact_Person_1__c	= '12345678',
											ASI_eForm_Country_Code_1__c		= '852',
											ASI_eForm_Country_Code_2__c		= '852',
											ASI_eForm_Country_Code_fax__c	= '852',
											ASI_eForm_Vendor_Payment_Terms__c = '060-Open A/C 60 Days',
											ASI_eForm_Vendor_Search_Type__c='VT',
											ASI_eForm_Account_Type_Requested__c='COD',
											ASI_eForm_Address_Country__c ='AA-ARUBA',
											ASI_eForm_Address_Postal_Code__c='000000',
											ASI_eForm_Email_1__c='test@eee.com',
											ASI_eForm_Phone_Contact_1__c='12345678',
											ASI_eForm_Phone_Contact_2__c='12345678',
											ASI_eForm_Fax_Contact__c='12345678',
											ASI_eForm_Vendor_Payment_Method__c='Cheque',
											ASI_eForm_CC10_Customer_Type__c='1DL',
											ASI_eForm_Vendor_Currency__c='HKD',
											ASI_eForm_Customer_Type_Channel__c='Traditional On',
											ASI_eForm_Vendor_Payment_Class_Code__c='DISC',
											ASI_eForm_Vendor_MFM_Access_CC15__c='901',
											ASI_eForm_BR_Certificate_no__c='1234567890',
											ASI_eForm_Create_Vendor_Account__c=false,
											ASI_eForm_Vendor_Freight_Handling_Code__c='BRR-Bypass Routing and Rating');
    }
    
    public static testMethod void ApprReq_Test(){
        test.startTest();
        ASI_eForm_Customer_Form__c form1 = defaultForm();
        insert form1;
        id headId = form1.id;
        ASI_eform_HK_Customer_Form_ApprReq_CON controller = new ASI_eform_HK_Customer_Form_ApprReq_CON();
        controller.headerId = headId;
        controller.header = form1;
        boolean TestBool = controller.init();
        test.stopTest();

    }

}