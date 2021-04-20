/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PurSubmitApprovalCtl       
* Test Class:  ASI_CTY_CN_Vendor_PurLine_TriggerCtlTest
* Description: Submit PurLine
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-11-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
global with sharing class ASI_CTY_CN_Vendor_PurSubmitApprovalCtl {

	webservice static void sendApprovalRequest(String recordId)
	{
       List<ASI_MFM_Purchase_Request_Line__c> lines = [select Id,Name from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Purchase_Request__c =:recordId AND (ASI_CTY_CN_Vendor_Status__c='Draft' OR 
        	ASI_CTY_CN_Vendor_Status__c = 'Recall'  OR ASI_CTY_CN_Vendor_Status__c='Reject') AND ASI_CTY_CN_Vendor_Is_MKT_Submit__c =true];

       for(ASI_MFM_Purchase_Request_Line__c line:lines)
       {
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setComments('Submitting request for approval.');
          req.setObjectId(line.Id);
		      // submit the approval request for processing
          Approval.ProcessResult result = Approval.Process(req);
		      // display if the reqeust was successful
		      System.debug('Submitted for approval successfully: '+result.isSuccess());
       }
	}
    
}