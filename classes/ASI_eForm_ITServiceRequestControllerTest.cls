@isTest
private class ASI_eForm_ITServiceRequestControllerTest
{
    @isTest
    public static void testASI_eForm_ITServiceRequestController()
    {
        User currentUser = ASI_eForm_TestClassHelper.createUser();
    Map<String,User> userMap = new Map<String,User>();
    userMap.put('owner',currentUser);
    
    ASI_eForm_IT_Procurement_Service_Request__c itpsr = ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
    
    List<ASI_eForm_IT_Procurement_Service_Item__c> itpsrItems =  
     ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);
    
    ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(itpsrItems);
      
    PageReference itpsrItemPage = Page.ASI_eForm_InputITServiceRequestPage;
      Map<String, String> pageParams = itpsrItemPage .getParameters();
        pageParams.put('id', itpsr .Id);
      
      Test.setCurrentPageReference(itpsrItemPage);
      
      ASI_eForm_ITServiceRequestController itpsrController = new
         ASI_eForm_ITServiceRequestController(standardSetController);   
    
    }

}