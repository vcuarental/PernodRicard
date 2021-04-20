/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_OPActionHandler Class.
  @Author:      IPC
  @History:     AUG.1.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_DE_TestOPActionHandler{
    private static EUR_CRM_ObjPromo_Action__c pAction;
    private static EUR_CRM_OP_Action_List_Template__c actListTemp;
    
    static void dataInsert1(){
        actListTemp = EUR_CRM_DE_TestClassUtilityHelper.createActionTemplate(1, 'DE O/P Action List Template', 'DE_OFF_ALT_Act_Temp')[0];
        insert actListTemp;
        system.assertNotEquals(actListTemp, null);
        
        pAction = EUR_CRM_DE_TestClassUtilityHelper.createPromoAction(1, 'DE OFF Confirm Agreement to Buy', actListTemp.Id)[0];
        pAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_DE_OFF_Confirm_Agreement_To_Buy';
        insert pAction;
        system.assertNotEquals(pAction, null);
    }
    
    static testMethod void testActions(){
        Test.startTest();
            dataInsert1();
            
            update pAction;
        Test.stopTest();
    }
}