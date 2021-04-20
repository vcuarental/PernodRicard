@isTest
private class ASI_eForm_PrTrpApprvlItemsControllerTest
{

@isTest
public static void preTripApprovalItemsControllerTest()
{
    User currentUser = ASI_eForm_TestClassHelper.createUser();
    Map<String,User> userMap = new Map<String,User>();
    userMap.put('owner',currentUser);
    
    ASI_eForm_Pre_Trip_Approval__c preTripApproval = ASI_eForm_TestClassHelper.createPreTripApproval(userMap);
    
    List<ASI_eForm_Pre_Trip_Approval_Item__c> preTripApprovalItems =  ASI_eForm_TestClassHelper.createPreTripApprovalItems(preTripApproval);
    
    ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(preTripApprovalItems);
      
      PageReference preTripApprovalItemPage = Page.ASI_eForm_InputPreTripApprovalItemPage;
      Map<String, String> pageParams = preTripApprovalItemPage.getParameters();
        pageParams.put('id', preTripApproval.Id);
      
      Test.setCurrentPageReference(preTripApprovalItemPage);
      
      ASI_eForm_PreTripApprovalItemsController preTripApprovalController = new
         ASI_eForm_PreTripApprovalItemsController(standardSetController);        
}


}