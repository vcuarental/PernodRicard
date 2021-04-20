/*********************************************************************************
 * Name:ASI_CRM_SG_PaymentRequestController
 * Description: Class for Payment Request Related Action
 * Test Class: ASI_CRM_SG_Payment_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 20180207       Wilken	         		[WL 1.0] Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_PaymentRequestController{

    public ASI_TH_CRM_PaymentRequest__c payment {get;set;}

    public pageReference setToDraft(){
        Pagereference pageref;
		
		List<GroupMember> gmList = [select UserOrGroupId from GroupMember where GroupId in (select Id from Group where DeveloperName = 'ASI_CRM_SG_Sales_BA')];
		
		Boolean isAdmin = false;
		
		for (GroupMember gm:gmList){
			if (UserInfo.getUserId() == gm.UserOrGroupId)
				isAdmin = true;
		}
		
		if (isAdmin){
			try {
				payment.recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request');
				payment.ASI_CRM_Sync_to_JDE__c = false;
				payment.ASI_CRM_SG_Finance_Verified__c = false;
				payment.ASI_TH_CRM_Status__c = 'Draft';
				payment.ASI_TH_CRM_GL_Date__c = null;
				
				update payment;				
				
				List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineList = [select id, ASI_CRM_JDE_Document_No__c, ASI_CRM_JDE_Document_Type__c, ASI_CRM_GL_Date__c, ASI_CRM_Verified__c
					from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c = :payment.Id];
				
				for (ASI_TH_CRM_PaymentRequestLineItem__c line:paymentLineList){
					line.ASI_CRM_JDE_Document_No__c = null;
					line.ASI_CRM_JDE_Document_Type__c = null;
					line.ASI_CRM_GL_Date__c = null;
					line.ASI_CRM_Verified__c = false;
				}
				update paymentLineList;
				
				pageref = new PageReference('/'+ payment.Id);
			} 
			catch(exception e) {
				pageRef = null;   
				String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
			}
        }
		
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact Sales Business Analyst to update the Payment Request'));
		}
        return pageRef;
    }

    public ASI_CRM_SG_PaymentRequestController (ApexPages.StandardController stdController){
        
        this.payment = (ASI_TH_CRM_PaymentRequest__c)stdController.getRecord();
    }    
}