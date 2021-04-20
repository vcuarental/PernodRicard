@isTest
private class ASI_eForm_ITChRequestBeforeUpdateTest
{

  @isTest
    public static void testITChangeRequestBeforeUpdateHK()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      user otherUser = ASI_eForm_TestClassHelper.createUser('abcdefgh');
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
      ASI_eForm_Route_Type__c routeType = new ASI_eForm_Route_Type__c(Name = 'ITCRF-PRHK-Finance', ASI_eForm_Company__c = 'Pernod Ricard Asia', ASI_eForm_Department__c = 'Human Resources', ASI_eForm_Form_Type__c = 'IT Change Request');
      insert routeType;
      ASI_eForm_Route_Rule_Details__c routeDetail = new ASI_eForm_Route_Rule_Details__c(ASI_eForm_Approver__c = currentUser.id, ASI_eForm_Route_Type__c = routeType.id, ASI_eForm_Note__c = ASI_eForm_PreFillApproversHandler.CIO);
      insert routeDetail;
      ASI_eForm_Route_Rule_Details__c routeDetail2 = new ASI_eForm_Route_Rule_Details__c(ASI_eForm_Approver__c = currentUser.id, ASI_eForm_Route_Type__c = routeType.id, ASI_eForm_Note__c = ASI_eForm_PreFillApproversHandler.CIO);
      insert routeDetail2;
      ASI_eForm_Route_Rule_Details__c routeDetail3 = new ASI_eForm_Route_Rule_Details__c(ASI_eForm_Approver__c = currentUser.id, ASI_eForm_Route_Type__c = routeType.id, ASI_eForm_Note__c = ASI_eForm_PreFillApproversHandler.CIO);
      insert routeDetail3;
      
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequest(mapUser);  
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeReqItems = ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
      itChangeRequest.ASI_eForm_Status__c = 'Submitted';
      RecordType hkFinalRecordType = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_HK_IT_Change_Request_Submitted'];
      itChangeRequest.RecordTypeId = hkFinalRecordType.Id;
      itChangeRequest.ASI_eForm_FCost_absorbed_by_IT__c = true;
      itChangeRequest.ownerid = otherUser.id;
      
      update itChangeRequest; 
      
      itChangeRequest.ASI_eForm_FCost_absorbed_by_IT__c = true;
      update itChangeRequest; 
    }

}