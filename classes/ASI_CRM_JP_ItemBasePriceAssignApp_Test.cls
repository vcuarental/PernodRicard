/*********************************************************************************
 * Name: ASI_CRM_JP_ItemBasePriceAssignAppTest
 * Description: Test class for ASI_CRM_JP_ItemBasePriceAssignAppTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/05/2019       Rutuja Bardapurkar             Created          
*/
@isTest
public class ASI_CRM_JP_ItemBasePriceAssignApp_Test {
    
     @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createApprovalRoute();
    }
    
    public static testMethod void testController() {
        Map<Id, ASI_CRM_JP_Customer_Product_Price__c> priceMap = new map<Id, ASI_CRM_JP_Customer_Product_Price__c>();
        Id RecordTypeId = Schema.SObjectType.ASI_CRM_JP_Customer_Product_Price__c.getRecordTypeInfosByName().get('JP CRM Promotion Product Price').getRecordTypeId();
        
        ID userid =  UserInfo.getUserId();
        List<ASI_CRM_JP_Customer_Product_Price__c> CustProlist = new list<ASI_CRM_JP_Customer_Product_Price__c>();
        ASI_CRM_JP_Customer_Product_Price__c CustPro = new ASI_CRM_JP_Customer_Product_Price__c();
        CustPro.OwnerId = userid;
        CustPro.RecordTypeId = RecordTypeId;
        CustProlist.add(CustPro);
        insert CustProlist;
        
        
        
        Set<Id> userIdSet = new Set<Id>();
        Id Pl1RecordTypeId = Schema.SObjectType.ASI_CRM_Route_Type__c.getRecordTypeInfosByName().get('JP Price Route Type').getRecordTypeId();
        List<ASI_CRM_Route_Type__c> CustProlist1 = new list<ASI_CRM_Route_Type__c>();
        ASI_CRM_Route_Type__c CustPro1 = new ASI_CRM_Route_Type__c();
        CustPro1.ASI_CRM_Module_Record_Type__c = 'Promotion Product Price';
        CustPro1.ASI_CRM_Module__c = 'Item Base Price';
        CustPro1.RecordTypeId = Pl1RecordTypeId;
        CustProlist1.add(CustPro1);
        insert CustProlist1;
       
        
        ASI_CRM_JP_ItemBasePriceAssignApprover ItemBase = new ASI_CRM_JP_ItemBasePriceAssignApprover();
        ItemBase.ROUTE_TYPE_MODULE_RECORD_TYPE = 'Promotion Product Price';
        ItemBase.assignApprover(CustProlist);
        ItemBase.retrieveUser(userIdSet);
        
    }

}