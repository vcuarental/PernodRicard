/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ASI_eForm_CustomerForm_TriggerClassTest {

	private final static String CUSTOMERFORM_RECORD_TYPE_READ_ONLY = 'Read_Only';
    private final static String CUSTOMERFORM_RECORD_TYPE_REVISE = 'Revise';
    private final static String ATTACHMENT_TYPE_BR = 'BR';
    private final static String ATTACHMENT_TYPE_BANK_PROOF = 'Bank Proof';
    private final static String PAYMENT_METHOD = 'Cheque';
    private final static String EFORM_TYPE ='Customer Form';
	private final static String PRHKM = 'PRHKM';
    private final static String PRATR = 'PRATR';
    private final static String PARENT = 'Parent';
    private final static String MASTER_REVISE = 'Completed_Master_Revision';
    private static final Id NEW_CUSTOMER_FORM_ATR = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRATR_Parent_Original');
    private static final Id NEW_CUSTOMER_FORM_HKM = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRHKM_Parent_Original');
    private static final Id NEW_CUSTOMER_FORM_HKM_REVISE = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRHKM_Parent_Revise_Read_Only');
    private static final Id NEW_CUSTOMER_FORM_ATR_REVISE = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRATR_Parent_Revise_Read_Only');
    private static final Id NEW_CUSTOMER_FORM_ATR_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRATR_Parent_Original_Read_Only');
    private static final Id NEW_CUSTOMER_FORM_HKM_RO = Global_RecordTypeCache.getRtId('ASI_eForm_Customer_Form__cASI_eForm_PRHKM_Parent_Original_Read_Only');
    private final static Integer NUMBER_OF_SYS_APPROVER = 8;
    
    
    private static Profile adminP;
    private static List<User> listUser;
    private static User user;
    private static ASI_eForm_Customer_Form__c form1, form2,newReviseCustomerForm,newReviseCustomerForm2;
    private static list<ASI_eForm_Customer_Form__c> trigger_new;
    
    private static void initialize() {

	//------ create users -------
        adminP = [select id from Profile where name = 'System Administrator'];
        listUser = new List<User>();
        user = new User(Alias = 'standt', Email='dev0.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev0.pra@introv.com', CompanyName ='Pernod Ricard Hong Kong');
        listUser.add(user);
        insert listUser;
        
     //   createApproval();
        
        System.runAs(user) {
           
			form1 = defaultForm();
			form2 = defaultForm2();
			form1.OwnerId = user.id;
			form2.OwnerId = user.id;
		
            trigger_new = new List<ASI_eForm_Customer_Form__c>{form1, form2};
            
            insert trigger_new;
     
     //   Test    ASI_eForm_HK_CustomerForm_PDF_PageCtrler
            ASI_eForm_HK_CustomerForm_PDF_PageCtrler tmpPDFctrl = new ASI_eForm_HK_CustomerForm_PDF_PageCtrler(new ApexPages.StandardController(form1));
            ASI_eForm_HK_CustomerForm_PDF_PageCtrler tmpPDFctrl2 = new ASI_eForm_HK_CustomerForm_PDF_PageCtrler();
            tmpPDFctrl.dummyVar = false;
            tmpPDFctrl.formID = form1.id;
            tmpPDFctrl.init();
            
            
     //	  Test    ASI_eForm_HK_CustomerForm_PDF_PageCtrler
            PageReference pageRef = Page.ASI_eForm_CustomerFileAttachmentPage;
            pageRef.getParameters().put('id', form1.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdCon = new ApexPages.StandardController(form1);
            ASI_eForm_CustomerFileAttachmentCtrl fileAttachCon = new ASI_eForm_CustomerFileAttachmentCtrl();
            
            Blob attachData = Blob.toPdf('Test');
            fileAttachCon.sObjParentId = form1.Id;
            fileAttachCon.attachmentObjType = 'ASI_eForm_Customer_Form_Attachment__c';
            fileAttachCon.attachmentContentData = attachData;
            fileAttachCon.fileSize = attachData.size();
            fileAttachCon.attachmentFileName = 'Test.pdf';
            fileAttachCon.contentCategory = 'Others';
         	fileAttachCon.attachmentObjLabel ='';
   
            //Test for class properties
            PageReference uploadPage = fileAttachCon.uploadAction();
             PageReference cancelPage = fileAttachCon.cancel();
            Boolean hasCategoryField = fileAttachCon.hasCategoryField;
            Integer uploadStepCount = fileAttachCon.getUploadStepCount();
           
           
            List<SelectOption> categories = fileAttachCon.categories;
            
            PageReference pageRef2 = Page.ASI_eForm_CustomerFileAttachmentPage;
            
            pageRef2.getParameters().put('id', form1.Id);
            
            Test.setCurrentPage(pageRef2);
            
            ApexPages.StandardController stdCon2 = new ApexPages.StandardController(form1);
            
            ASI_eForm_CustomerFileAttachmentCtrl fileAttachCon2 = new ASI_eForm_CustomerFileAttachmentCtrl();
            
            Blob attachData2 = Blob.toPdf('Test');
            fileAttachCon2.sObjParentId = form1.Id;
            fileAttachCon2.attachmentObjType = 'ASI_eForm_Customer_Form_Attachment__c';
            fileAttachCon2.attachmentContentData = attachData2;
            fileAttachCon2.fileSize = attachData2.size();
            fileAttachCon2.attachmentFileName = 'Test.pdf';
            fileAttachCon2.contentCategory = 'Others';
            
            PageReference returnPage2 = fileAttachCon2.uploadAction();
			
			/*[WL 1.0] BEGIN*/
			String label = fileAttachCon2.attachmentObjLabel;
			String type = fileAttachCon2.contentType;
			categories = fileAttachCon2.categories;
			
			PageReference returnPage3 = fileAttachCon2.uploadAction();
            
            
		}
    }
	       
    
    /****************************************************************************************************************************
 	 * Description:	Test routineBeforeInsert method 
	****************************************************************************************************************************/	
	@isTest static void testRoutineBeforeInsert() {
	initialize();
	ASI_eForm_CustomerForm_TriggerClass.routineBeforeInsert(trigger_new);
	
	}
	
	/****************************************************************************************************************************
 	 * Description:	Test routineBeforeUpdate method 
	****************************************************************************************************************************/	
	@isTest static void testRoutineBeforeUpdate() {
	initialize();
	list<ASI_eForm_Customer_Form__c>trigger_old = trigger_new;
	
	trigger_new[0].RecordTypeId = NEW_CUSTOMER_FORM_ATR_RO;
	trigger_new[0].ASI_eForm_Parent_Customer_Form__c = null;
	trigger_new[0].ASI_eForm_Original_Customer_Form__c = null;
	trigger_new[0].ASI_eForm_Create_Vendor_Account__c = true;
	trigger_new[0].ASI_eForm_Separate_Acc_Regional_AP__c = true;
	
	update trigger_new[0];
	
	ASI_eForm_CustomerForm_TriggerClass.routineBeforeUpdate(trigger_new , new Map<Id, ASI_eForm_Customer_Form__c>{trigger_new[0].id => trigger_old[0],trigger_new[1].id => trigger_old[1] });
	
	}
	
	/****************************************************************************************************************************
 	 * Description:	Test routineAfterUpdate method 
	****************************************************************************************************************************/	
	@isTest static void testRoutineAfterUpdate() {
	initialize();
	list<ASI_eForm_Customer_Form__c>trigger_old = trigger_new;
	
	trigger_old[0].ASI_eForm_Create_Vendor_Account__c	=true;
	
	
	update trigger_old;
	
	ASI_eForm_CustomerForm_TriggerClass.routineAfterUpdate(trigger_new, new Map<Id, ASI_eForm_Customer_Form__c>{trigger_new[0].id => trigger_old[0],trigger_new[1].id => trigger_old[1] });
	
	}
	
	/****************************************************************************************************************************
 	 * Description:	Test updateOriginalCustomerFormField method
	****************************************************************************************************************************/	
	@isTest static void testUpdateOriginalCustomerFormFieldATR() {
	initialize();
	
	ASI_eForm_CustomerForm_TriggerClass.queryOriginalCustomerForm(' where Id = \'' + trigger_new[0].id + '\'');

  	newReviseCustomerForm = trigger_new[0].clone(false, false, false, false);
	newReviseCustomerForm.OwnerId = trigger_new[0].Ownerid;	
	//newReviseCustomerForm.ASI_eForm_Original_Customer_Form__c = trigger_new[0].id;
	newReviseCustomerForm.RecordTypeId = NEW_CUSTOMER_FORM_ATR_REVISE;
	newReviseCustomerForm.ASI_eForm_Status__c = MASTER_REVISE;
	insert newReviseCustomerForm;

	ASI_eForm_CustomerForm_TriggerClass.updateOriginalCustomerFormField(newReviseCustomerForm ,  trigger_new[0]);
	
	}
	
		/****************************************************************************************************************************
 	 * Description:	Test updateOriginalCustomerFormField method
	****************************************************************************************************************************/	
	@isTest static void testUpdateOriginalCustomerFormFieldHKM() {
	initialize();

	newReviseCustomerForm2 = trigger_new[1].clone(false, false, false, false);
	newReviseCustomerForm2.OwnerId = trigger_new[1].Ownerid;	
	//newReviseCustomerForm.ASI_eForm_Original_Customer_Form__c = trigger_new[0].id;
	newReviseCustomerForm2.RecordTypeId = NEW_CUSTOMER_FORM_HKM_REVISE;
	newReviseCustomerForm2.ASI_eForm_Status__c = MASTER_REVISE;
	insert newReviseCustomerForm2;
	
	ASI_eForm_CustomerForm_TriggerClass.updateOriginalCustomerFormField(newReviseCustomerForm2 ,  trigger_new[1]);
	
	}
	
	
	/*static void createApproval() {
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user1 = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com', CompanyName ='comp');
        listUser.add(user1);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com', CompanyName ='comp');
        listUser.add(user2);
        User user3 = new User(Alias = 'standt', Email='dev3.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev3.pra@introv.com', CompanyName ='comp');
        listUser.add(user3);
        insert listUser;
        
       // id rtid = Global_RecordTypeCache.getRtId('ASI_eForm_Route_Type__cASI_eForm_HK_Route_Type');
        
         List<ASI_eForm_Route_Type__c> routeTypes = new List<ASI_eForm_Route_Type__c>();
         ASI_eForm_Route_Type__c aRoute = new ASI_eForm_Route_Type__c (ASI_eForm_CC14_KAM__c ='MCJ',ASI_eForm_CC17_TR_Business_Unit_del__c ='NA',
																         Name ='ATR Customer Form - NA- MCJ',ASI_eForm_Company__c='Pernod Ricard Asia Travel Retail',ASI_eForm_Create_Vendor_Account__c=false,
																         ASI_eForm_Form_Type__c='Customer Form',ASI_eForm_Is_Exceed_Default_Credit_Terms__c=false);
         ASI_eForm_Route_Rule_Details__c aRouteDetail = new ASI_eForm_Route_Rule_Details__c (ASI_eForm_Approver__c = user1.id ,ASI_eForm_Route_Type__c = aRoute.Id);
         ASI_eForm_Route_Rule_Details__c bRouteDetail = new ASI_eForm_Route_Rule_Details__c (ASI_eForm_Approver__c = user2.id ,ASI_eForm_Route_Type__c = aRoute.Id);
         ASI_eForm_Route_Rule_Details__c cRouteDetail = new ASI_eForm_Route_Rule_Details__c (ASI_eForm_Approver__c = user3.id ,ASI_eForm_Route_Type__c = aRoute.Id);

		}*/
		
	static ASI_eForm_Customer_Form__c defaultForm() {
        
        return new ASI_eForm_Customer_Form__c(RecordTypeId=NEW_CUSTOMER_FORM_ATR,
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
    
    static ASI_eForm_Customer_Form__c defaultForm2() {
       
        return new ASI_eForm_Customer_Form__c(RecordTypeId=NEW_CUSTOMER_FORM_HKM,
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
}