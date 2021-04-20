/*********************************************************************************
 * Name: ASI_CRM_JP_PriceListAssignApproverTest
 * Description: Test class for ASI_CRM_JP_PriceListAssignApprover
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/05/2019       Rutuja Bardapurkar             Created          
*/

@isTest
public class ASI_CRM_JP_PriceListAssignApprover_Test {
    
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createApprovalRoute();
    }
    
    public static testMethod void testController() {
        Map<Id, ASI_CRM_Price_List__c> priceMap = new map<Id, ASI_CRM_Price_List__c>();
       
        ID userid =  UserInfo.getUserId();
        List<ASI_CRM_Price_List__c> plist = new list<ASI_CRM_Price_List__c>();
        ASI_CRM_Price_List__c Pl = new ASI_CRM_Price_List__c();
        Pl.OwnerId = userid;
        plist.add(Pl);
        insert plist;
        
        Set<Id> userIdSet = new Set<Id>();
        
        List<ASI_CRM_Route_Type__c> RtList = new list<ASI_CRM_Route_Type__c>();
        ASI_CRM_Route_Type__c Rt = new ASI_CRM_Route_Type__c();
        
        RtList.add(Rt);
        insert RtList;
      
        ASI_CRM_JP_PriceListAssignApprover PriceAssign = new ASI_CRM_JP_PriceListAssignApprover();
        PriceAssign.ROUTE_TYPE_MODULE_RECORD_TYPE = 'Price List';
        PriceAssign.assignApprover(plist);
        PriceAssign.retrieveUser(userIdSet);
    }
    
    
}