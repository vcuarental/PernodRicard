@isTest
public class ASI_TH_CRM_PaymentStatus_TriggerCls_Test{
    public static testMethod void routineBeforeUpsert_Test() {
        ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        try{
            insert customerCodeRunningNumber;
        } catch (System.DmlException e) {
        }
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        try{
            insert contractRunningNumber;    
        } catch (System.DmlException e) {
        }
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        try{
            insert paymentRequestRunningNumber;                    
        } catch (System.DmlException e) {
        }                
        
		//Wilken 20161017: Should not query production user as test data
        /*List<user> userList = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where profile.Name = 'System Administrator' and isactive = true and Managerid <> null and userroleid <> null Limit 1];*/
        
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User uManager = new User(Alias = 'standt', Email='testUserManager@praTHCRMTest.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
							LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUserManager@praTHCRMTest.com');

		insert uManager;
		
        User u = new User(Alias = 'standt', Email='testUser@praTHCRMTest.com', 
							EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
							LocaleSidKey='en_US', ProfileId = p.Id, Managerid = uManager.id, 
							TimeZoneSidKey='America/Los_Angeles', UserName='testUser@praTHCRMTest.com');
        
        System.runAs(u) {
            String recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Potential_Outlet');
            String supplierRTid = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Supplier');
            id rtIDContract = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract');
            id rtIDPR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request');
            id rtIDPRitm = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail');
            
            
            Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid, ownerid = u.id  );
            insert potentialOutlet ;
            
            Account supplier = new Account(Name='Test Supplier', RecordTypeid = supplierRTid, ownerid = u.id  );
            insert supplier;
        
            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
                ASI_TH_CRM_End_Date__c = date.today().addMonths(12),
                RecordTypeId = rtIDContract
            );
            insert contract; 
            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(
                ASI_TH_CRM_Contract__c = contract.id, RecordTypeID = rtIDPR, ASI_TH_CRM_Vendor__c = supplier.id
            );
            insert paymentRequest;
            
            ASI_TH_CRM_PaymentRequest__c quriedPaymentRequest = [SELECT name FROM ASI_TH_CRM_PaymentRequest__c WHERE id =: paymentRequest.id];
            ASI_TH_CRM_Payment_Status__c paymentStatus = new ASI_TH_CRM_Payment_Status__c(
                ASI_CRM_PO_Number__c = quriedPaymentRequest.name 
            );
            insert paymentStatus;
        }
    }
}