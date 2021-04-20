/***************************************************************************************************************************
 * Name: ASI_eForm_ITChangeRequestAfterUpdateTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-12       Wilken Lee		        [WL 1.0] Increase coverage for ASI_eForm_GenericTriggerClass.reverseCompleteITAction method
 ****************************************************************************************************************************/
@isTest
private class ASI_eForm_ITChangeRequestAfterUpdateTest
{

    @isTest
    public static void testITChangeRequestAfterUpdateError()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      //ASI_eForm_TestClassHelper.createRunningNumbers();
      try {
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequest(mapUser);  
      
      /*
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeReqItems = ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
      itChangeRequest.ASI_eForm_Status__c = 'Final';
      RecordType hkFinalRecordType = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_HK_IT_Change_Request_Final'];
      itChangeRequest.RecordTypeId = hkFinalRecordType.Id;
      update itChangeRequest;
      */
      
      } catch (Exception e)
      {
      
      
      }
      /*
      itChangeReqItems.get(0).ASI_eForm_IT_Action__c = 'Invalid Submission';
      
      update itChangeReqItems;  
      */
    }
    
    @isTest
    public static void testITChangeRequestAfterUpdateHK()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequest(mapUser);  
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeReqItems = ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
      itChangeRequest.ASI_eForm_Status__c = 'Final';
      RecordType hkFinalRecordType = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_HK_IT_Change_Request_Final'];
      itChangeRequest.RecordTypeId = hkFinalRecordType.Id;
      update itChangeRequest;
      
      itChangeReqItems.get(0).ASI_eForm_IT_Action__c = 'Invalid Submission';
      
      update itChangeReqItems;  
    
    }
    
    @isTest
    public static void testITChangeRequestAfterUpdateCN()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
	  /*[WL 1.0] BEGIN*/
	  ASI_eForm_Route_Type__c rt = new ASI_eForm_Route_Type__c(Name='ITC-PRCN-IT', ASI_eForm_Form_Type__c = 'IT Change Request');
	  insert rt;
	  
	  ASI_eForm_Route_Rule_Details__c rd = new ASI_eForm_Route_Rule_Details__c(ASI_eForm_Route_Type__c = rt.Id, ASI_eForm_Approver__c = currentUser.Id, ASI_eForm_Note__c = 'High-Level Authorizer');
	  insert rd;
	  /*[WL 1.0] END*/
	  
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequestCN(mapUser);  
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeReqItems = ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
	  
      itChangeRequest.ASI_eForm_Status__c = 'Final';
	  itChangeRequest.ASI_eForm_IT_Action__c = 'Complete';	//[WL 1.0]
	  
      RecordType hkFinalRecordType = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_CN_IT_Change_Request_Final'];
      itChangeRequest.RecordTypeId = hkFinalRecordType.Id;
      update itChangeRequest;
      
      itChangeReqItems.get(0).ASI_eForm_IT_Action__c = 'IT Acknowledged';
      
      update itChangeReqItems;  
    
    }

}