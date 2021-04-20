@istest
public class ASI_eForm_KR_Test1 {
    
    //ASI_eForm_KR_Vendor_Form_TriggerClass
    static testMethod void  VendorFormTest1(){
        
        user u = [select userRole.developerName,ASI_MFM_Team__c,username,ManagerId from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Team__c = 'KR1';
        update u;
        
        List<Account> AccountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),Name='Name1',ASI_KOR_Venue_Status__c ='Active',
                                   ASI_MFM_Customer_Supplier_Name__c='Test1231',ASI_KOR_Venue_Business_License_Number__c='123456789012',
                                   ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
        AccountList.add(acc1);
        insert AccountList;
        
        
        
           
        ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                              ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none',  
                                                              ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                              ASI_eForm_Employee_Work_Email__c=u.username, ASI_eForm_Employee_Eligible_PD__c = true,
                                                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM'));
        insert tempMDM;
        
        List<ASI_eForm_Vendor_Form__c> VendorFormList = new  List<ASI_eForm_Vendor_Form__c>();
        ASI_eForm_Vendor_Form__c VendorForm1 = new ASI_eForm_Vendor_Form__c(ASI_eForm_Supplier__c=acc1.Id ,ASI_eForm_Request_Type__c='신규업체 등록에 따른 신규 계좌등록',
                                                                            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_KR_Vendor_Form') );
        VendorFormList.add(VendorForm1);
      
        
        Test.startTest();
        insert VendorFormList;
		
		PageReference pageRef = Page.ASI_eForm_VendorFileAttachmentPage;
        
		pageRef.getParameters().put('id', VendorForm1.Id);
		
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController stdCon = new ApexPages.StandardController(VendorForm1);
		
		ASI_eForm_VendorFileAttachmentController fileAttachCon = new ASI_eForm_VendorFileAttachmentController();
		
		Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = VendorForm1.Id;
		fileAttachCon.attachmentObjType = 'ASI_eForm_Vendor_Form_Attachment__c';
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		fileAttachCon.contentFileName = 'Test.pdf';
		fileAttachCon.contentCategory = '사업자등록증 사본/주민등록증 사본';
		
		PageReference returnPage = fileAttachCon.uploadAction();
		List<SelectOption> categories = fileAttachCon.categories;
		
		delete [select id from ASI_eForm_Vendor_Form_Attachment__c];
            
        
        test.stopTest(); 
    }
    
    
    
    
    //ASI_eForm_KR_CCR_TriggerClass
    static testMethod void  CorpCardRequestTest1(){
        
        user u = [select userRole.developerName,ASI_MFM_Team__c,username,ManagerId,email from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Team__c = 'KR1';
        update u;
        
        
        ASI_MFM_Fix_Approval_Route__c FixApprovalRoute = New ASI_MFM_Fix_Approval_Route__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_KR_Fix_Approval_Route'),
                                                                                           ASI_MFM_Module__c = 'eForm' , ASI_MFM_Team__c='KR1',ASI_MFM_KR_Grand_Category__c ='Corporate Card - New' , 
                                                                                           ASI_MFM_Corporate_Approver_1__c= u.Id,ASI_MFM_Inactive__c = false );
        insert FixApprovalRoute;
        
           
        ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                              ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
                                                               ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                              ASI_eForm_Employee_Work_Email__c=u.username, ASI_eForm_Employee_Eligible_PD__c = true,
                                                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM'));
        insert tempMDM;
        
        
        List<ASI_TnE_Corp_Card_Employee_Mapping__c> CorpCardEmployeeMappingList = new List<ASI_TnE_Corp_Card_Employee_Mapping__c> ();
        ASI_TnE_Corp_Card_Employee_Mapping__c CorpCardEmployeeMapping = new ASI_TnE_Corp_Card_Employee_Mapping__c(ASI_TnE_Employee_Name__c= u.id,ASI_TnE_Card_Number_1__c='Test121');
        CorpCardEmployeeMappingList.add(CorpCardEmployeeMapping);
        Insert CorpCardEmployeeMappingList;      
        
        
        
        
        ASI_MFM_Setting__c Setting = new ASI_MFM_Setting__c(ASI_CRM_KR_CCR_Receiver_CC__c='tonytesting@foxmail.com',
                                                            ASI_CRM_KR_CCR_Receiver_To__c='tonytesting@foxmail.com',
                                                            ASI_CRM_KR_Corporate_Card_Request_Sender__c=u.email );
        insert Setting;
        
        
        List<ASI_eForm_Corp_Card_Request__c> CorpCardRequestList= new List<ASI_eForm_Corp_Card_Request__c> ();
        ASI_eForm_Corp_Card_Request__c CorpCardRequest1 = new ASI_eForm_Corp_Card_Request__c(ASI_eForm_Status__c = 'Submitted',ASI_eForm_Card_Holder__c=u.id,ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMapping.Id,
                                                                                             RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Corp_Card_Request__cASI_eForm_KR_CC_Request_Suspension') );
        CorpCardRequestList.add(CorpCardRequest1);
        ASI_eForm_Corp_Card_Request__c CorpCardRequest2 = new ASI_eForm_Corp_Card_Request__c(ASI_eForm_Status__c = 'Submitted',ASI_eForm_Card_Holder__c=u.id,ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMapping.Id,
                                                                                             RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Corp_Card_Request__cASI_eForm_KR_CC_Request_New') );
        CorpCardRequestList.add(CorpCardRequest2);
        
        ASI_eForm_Corp_Card_Request__c CorpCardRequest3 = new ASI_eForm_Corp_Card_Request__c(ASI_eForm_Status__c = 'Submitted', ASI_eForm_Card_Holder__c=u.id,ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMapping.Id,
                                                                                             RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Corp_Card_Request__cASI_eForm_KR_CC_Request_Reissue'));
        CorpCardRequestList.add(CorpCardRequest3);
        
        ASI_eForm_Corp_Card_Request__c CorpCardRequest4 = new ASI_eForm_Corp_Card_Request__c(ASI_eForm_Status__c = 'Submitted',ASI_eForm_Card_Holder__c=u.id,ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMapping.Id,
                                                                                             RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Corp_Card_Request__cASI_eForm_KR_CC_Request_Cancellation'));
        CorpCardRequestList.add(CorpCardRequest4);
        
        ASI_eForm_Corp_Card_Request__c CorpCardRequest5 = new ASI_eForm_Corp_Card_Request__c(ASI_eForm_Status__c = 'Submitted',ASI_eForm_Card_Holder__c=u.id,ASI_eForm_Corp_Card_Employee_Mapping__c=CorpCardEmployeeMapping.Id,
                                                                                             RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Corp_Card_Request__cASI_eForm_KR_CC_Request_Change'));
        CorpCardRequestList.add(CorpCardRequest5);
        
        
        
        Test.startTest();
        insert CorpCardRequestList;
        
        
        List<ASI_eForm_Corp_Card_Request__c> CorpCardRequestList2= new List<ASI_eForm_Corp_Card_Request__c> ();
        
        CorpCardRequest1.ASI_eForm_Status__c = 'Approved';
        CorpCardRequest2.ASI_eForm_Status__c = 'Approved';
        CorpCardRequest3.ASI_eForm_Status__c = 'Approved';
        CorpCardRequest4.ASI_eForm_Status__c = 'Approved';
        CorpCardRequest5.ASI_eForm_Status__c = 'Approved';
        
        CorpCardRequestList2.add(CorpCardRequest1);
        CorpCardRequestList2.add(CorpCardRequest2);
        CorpCardRequestList2.add(CorpCardRequest3);
        CorpCardRequestList2.add(CorpCardRequest4);
        CorpCardRequestList2.add(CorpCardRequest5);
        
        
        update CorpCardRequestList2;
        
            
        test.stopTest(); 
    }
    
    
    
    
    
    //Test :  ASI_eForm_KR_ReturnOrder_MgtAllCtrl
    //Test : ASI_eForm_KR_ReturnOrderPDFCtrl
    //Test : ASI_eForm_KR_ReturnOrder_TriggerClass
    static testMethod void ReturnOrder_Test1(){
        
        user u = [select userRole.developerName,ASI_MFM_Team__c,username,ManagerId from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Team__c = 'KR1';
        update u;
        
        
        ASI_MFM_Fix_Approval_Route__c FixApprovalRoute = New ASI_MFM_Fix_Approval_Route__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_KR_Fix_Approval_Route'),
                                                                                           ASI_MFM_Module__c = 'eForm' , ASI_MFM_Team__c='KR1',ASI_MFM_KR_Grand_Category__c ='Return Order', ASI_MFM_Corporate_Approver_2__c=u.Id,
                                                                                           ASI_MFM_Corporate_Approver_1__c= u.Id,ASI_MFM_Inactive__c = false );
        insert FixApprovalRoute;
        
        
        ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                              ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none',  
                                                               ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                              ASI_eForm_Employee_Work_Email__c=u.username, ASI_eForm_Employee_Eligible_PD__c = true,
                                                              recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM'));
        insert tempMDM;
        
		/*
        List<Account> AccountList = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Wholesaler'),Name='Name1',ASI_KOR_Venue_Status__c ='Active',ASI_MFM_Customer_Supplier_Name__c='Test1231',
                                   ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
        AccountList.add(acc1);
        insert AccountList;
        
        
        
        ASI_eForm_Return_Order_Request__c ReturnOrder = new ASI_eForm_Return_Order_Request__c(ASI_eForm_Status__c= 'Draft',ASI_eForm_Customer__c =acc1.Id,ASI_eForm_Reason__c='R42',
                                                                                              RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Return_Order_Request__cASI_eForm_KR_Return_Order') );
        */
        List<ASI_CRM_AccountsAdditionalField__c> AccountList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c acc1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Wholesaler'),Name='Name1',ASI_CRM_CN_Inactive_Flag__c =false,
                                   ASI_CRM_MY_CustomerCode__c = 'T111111', ASI_CRM_CN_Grade__c = 'T1',ASI_CRM_CN_Address__c = '2');          
        AccountList.add(acc1);
        insert AccountList;
        
        
        
        ASI_eForm_Return_Order_Request__c ReturnOrder = new ASI_eForm_Return_Order_Request__c(ASI_eForm_Status__c= 'Draft',ASI_eForm_Customer_Wholesaler__c =acc1.Id,ASI_eForm_Reason__c='R42',
                                                                                              RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Return_Order_Request__cASI_eForm_KR_Return_Order') );
		
        Test.startTest();
        insert ReturnOrder;
        List<ASI_eForm_Return_Order_Request_Line_Item__c> ReturnOrderRequestLineList = new List<ASI_eForm_Return_Order_Request_Line_Item__c> ();
        List<ASI_eForm_Return_Order_Request_Line_Item__c> UpdatedLineList = new List<ASI_eForm_Return_Order_Request_Line_Item__c> ();
        
        ASI_eForm_Return_Order_Request_Line_Item__c ReturnOrderRequestLine1= new ASI_eForm_Return_Order_Request_Line_Item__c(ASI_eForm_Quantity_Replace__c=1,ASI_eForm_Return_Order_Request__c=ReturnOrder.Id);
        
        ASI_eForm_Return_Order_Request_Line_Item__c ReturnOrderRequestLine2= new ASI_eForm_Return_Order_Request_Line_Item__c(ASI_eForm_Quantity_Replace__c=2,ASI_eForm_Return_Order_Request__c=ReturnOrder.Id);
        
        UpdatedLineList.add(ReturnOrderRequestLine1);
        ReturnOrderRequestLineList.add(ReturnOrderRequestLine1);
        ReturnOrderRequestLineList.add(ReturnOrderRequestLine2);
        
        insert ReturnOrderRequestLineList;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', ReturnOrder.Id);  
        ASI_eForm_KR_ReturnOrder_MgtAllCtrl ext = new ASI_eForm_KR_ReturnOrder_MgtAllCtrl(new ApexPages.StandardController(ReturnOrder));
        ext.init();
        
        ext.BackHeader();
        
        
        List<string> deleteList = new List<string> ();
        deleteList.add(ReturnOrderRequestLine2.Id);
        
        String TempString = ASI_eForm_KR_ReturnOrder_MgtAllCtrl.UpdateLineItem(System.JSON.serialize(UpdatedLineList),deleteList); 
        ASI_eForm_KR_ReturnOrder_MgtAllCtrl.findList('ASI_eForm_Return_Order_Request_Line_Item__c',' Id ',' ');
        
        
        ASI_eForm_KR_ReturnOrderPDFCtrl ext2 = new ASI_eForm_KR_ReturnOrderPDFCtrl(new ApexPages.StandardController(ReturnOrder));
        ext2.RecordId=ReturnOrder.Id;
        ext2.dummyVar=false;
        ext2.init();
        test.stopTest(); 
    }
    
    
    
    
    
    
    //Test : ASI_eForm_KR_DonationRequestTriggerClass : ASI_eForm_KR_DonationRequestPDFCtrl : ASI_eForm_KR_DonationRequest_MgtAllCtrl
    static testMethod void DonationRequest_Test1(){
        
        user u = [select userRole.developerName,ASI_MFM_Team__c,username from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Team__c = 'KR1';
        update u;
        
        ASI_MFM_Fix_Approval_Route__c FixApprovalRoute = New ASI_MFM_Fix_Approval_Route__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_KR_Fix_Approval_Route'),
                                                                                           ASI_MFM_Module__c = 'eForm' , ASI_MFM_Team__c='KR1',ASI_MFM_KR_Grand_Category__c ='Donation' , 
                                                                                           ASI_MFM_Corporate_Approver_1__c= u.Id,ASI_MFM_Inactive__c = false );
        insert FixApprovalRoute;
        
        ASI_MFM_Setting__c Setting = new ASI_MFM_Setting__c(ASI_eForm_KR_Donation_Handler__c =u.username );
        insert Setting;
        
        ASI_eForm_Donation_Request__c DonationRequest =new ASI_eForm_Donation_Request__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request__cASI_eForm_KR_Donation_Request_RO'), ASI_eForm_Status__c='Draft');
        
        insert DonationRequest;
        
        List<ASI_eForm_Donation_Request_Line_Items__c> DonationRequestLineList = new List<ASI_eForm_Donation_Request_Line_Items__c>();
        ASI_eForm_Donation_Request_Line_Items__c DonationRequestLine1 = new ASI_eForm_Donation_Request_Line_Items__c(ASI_eForm_Donation_Request__c=DonationRequest.Id ,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request_Line_Items__cASI_eForm_KR_Donation_Request_Line') );
        DonationRequestLineList.add(DonationRequestLine1);
        
        ASI_eForm_Donation_Request_Line_Items__c DonationRequestLine2 = new ASI_eForm_Donation_Request_Line_Items__c(ASI_eForm_Donation_Request__c=DonationRequest.Id ,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request_Line_Items__cASI_eForm_KR_Donation_Request_Line') );
        DonationRequestLineList.add(DonationRequestLine2);
        
        ASI_eForm_Donation_Request_Line_Items__c DonationRequestLine3 = new ASI_eForm_Donation_Request_Line_Items__c(ASI_eForm_Donation_Request__c=DonationRequest.Id ,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request_Line_Items__cASI_eForm_KR_Donation_Request_Line') );
        DonationRequestLineList.add(DonationRequestLine3);
        
        insert DonationRequestLineList;
        
        
        Test.startTest();
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', DonationRequest.Id);  
        ASI_eForm_KR_DonationRequest_MgtAllCtrl ext = new ASI_eForm_KR_DonationRequest_MgtAllCtrl(new ApexPages.StandardController(DonationRequest));
        ext.init();
        ext.BackHeader();
        
        
        List<ASI_eForm_Donation_Request_Line_Items__c> UpdatedDRLineList = new List<ASI_eForm_Donation_Request_Line_Items__c>();
        UpdatedDRLineList.add(DonationRequestLine1);
        UpdatedDRLineList.add(DonationRequestLine2);
        
        List<string> deleteList = new List<string> ();
        deleteList.add(DonationRequestLine3.Id);
        
        String TempString = ASI_eForm_KR_DonationRequest_MgtAllCtrl.UpdateLineItem(UpdatedDRLineList,deleteList); 
        ASI_eForm_KR_DonationRequest_MgtAllCtrl.findList('ASI_eForm_Donation_Request_Line_Items__c',' Id ',' ');
        
        
        
        ASI_eForm_KR_DonationRequestPDFCtrl ext2 = new ASI_eForm_KR_DonationRequestPDFCtrl(new ApexPages.StandardController(DonationRequest));
        ext2.DonationRequestId=DonationRequest.Id;
        ext2.dummyVar=false;
        ext2.init();
        test.stopTest(); 
    }
}