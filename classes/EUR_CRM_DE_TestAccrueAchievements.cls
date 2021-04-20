/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_AccrueAchievements Class.
  @Author:      IPC
  @History:     JUL.31.2014 - Created
*/
@isTest (SeeAllData = false) 
private with sharing class EUR_CRM_DE_TestAccrueAchievements{
    private static final String postalCode = '12345';
     
    @TestSetup
    public static void dataInsert1(){
        User onTradeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        System.runAs(onTradeUser) {
            EUR_CRM_Region__c testRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', onTradeUser.Id, 'DE Region');
            EUR_CRM_Territory__c offTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory', onTradeUser.Id, testRegion.Id, 'DE Territory');
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', postalCode, offTradeTerritory.id, 'DE Off Trade Postal Code - Territory Mapping');

            EUR_CRM_Account__c accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode, 'DE OFF STD', null);

            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323', 'DE_OFF_ALT_Sales_Drive', EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE);
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                    1, EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE, 'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = System.today();//date.parse('1/1/2100');
            objPromo.EUR_CRM_Active_End_Date__c = System.today();//date.parse('1/30/2100');
            objPromo.eur_crm_status__c = 'Ended';
            insert objPromo;
            EUR_CRM_ObjPromo_Target__c objPromoTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'SR Volume Target', objPromo.Id, null)[0];
            insert objPromoTarget;

            EUR_CRM_Visit__c visit = EUR_CRM_DE_TestClassUtilityHelper.createVisit(1, 'DE Off Trade Visit', accountEU.id)[0];
            visit.EUR_CRM_End_Datetime__c = System.today();//DateTime.parse('1/15/2100 12:00 AM');
            insert visit;

            EUR_CRM_Visit_Action__c visitAction = EUR_CRM_DE_TestClassUtilityHelper.createVisitAction(1, 'DE OFF Sales Drive SKU Bottles Sell-In Qty', objPromo.Id, objPromoTarget.Id)[0];
            visitAction.EUR_CRM_Entitle_Achievement__c = true;
            visitAction.EUR_CRM_Is_Accrued__c = false;
            visitAction.EUR_CRM_Visit_ID__c = visit.Id;
            visitAction.EUR_CRM_ObjPromo_Target__c = objPromoTarget.id;
            visitAction.EUR_CRM_Account__c = accountEU.Id;
            insert visitAction;

            EUR_CRM_Visit_Action__c visitAction2 = EUR_CRM_DE_TestClassUtilityHelper.createVisitAction(1, 'DE OFF Ad hoc Agreement To Buy', objPromo.Id, objPromoTarget.Id)[0];
            visitAction2.EUR_CRM_Entitle_Achievement__c = true;
            visitAction2.EUR_CRM_Is_Accrued__c = false;
            visitAction2.EUR_CRM_Visit_ID__c = visit.Id;
            visitAction2.EUR_CRM_Status__c = 'Yes';
            visitAction2.EUR_CRM_ObjPromo_Target__c = objPromoTarget.id;
            visitAction2.EUR_CRM_Account__c = accountEU.Id;
            insert visitAction2;

            EUR_CRM_Visit_Action__c visitAction3 = EUR_CRM_DE_TestClassUtilityHelper.createVisitAction(1, 'DE OFF 2nd Placement Sell In Qty - Theme', objPromo.Id, objPromoTarget.Id)[0];
            visitAction3.EUR_CRM_Entitle_Achievement__c = true;
            visitAction3.EUR_CRM_Is_Accrued__c = false;
            visitAction3.EUR_CRM_Visit_ID__c = visit.Id;
            visitAction3.EUR_CRM_Status__c = 'Yes';
            visitAction3.EUR_CRM_ObjPromo_Target__c = objPromoTarget.id;
            visitAction3.EUR_CRM_Account__c = accountEU.Id;
            insert visitAction3;
        }
    }
    
    static testMethod void testAccrueAchievements(){
        Test.startTest();
            EUR_CRM_DE_AccrueAchievements controller = new EUR_CRM_DE_AccrueAchievements();
            Database.executeBatch(controller);
        Test.stopTest();
    }
}