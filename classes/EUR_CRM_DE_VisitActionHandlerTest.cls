@isTest
private class EUR_CRM_DE_VisitActionHandlerTest {
    private static final String POSTALCODE = '12345';
    private static final String YES = 'Yes';
    private static final String QTY_CONFIRMED = 'Qty Confirmed';
    private static final String PRESENTED = 'Presented';
    private static User 							onTradeUser;
    private static List<EUR_CRM_Visit_Action__c> 	lstVisitAction;

    public static void dataInsert(){
        onTradeUser = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        insert onTradeUser;
        System.runAs(onTradeUser) {
            EUR_CRM_Region__c testRegion = EUR_CRM_TestClassUtilityHelper.createRegion('region 1', onTradeUser.Id, 'EUR_DE_Region');
            insert testRegion;
            EUR_CRM_Territory__c offTradeTerritory = EUR_CRM_TestClassUtilityHelper.createTerritory('offTradeTerritory', onTradeUser.Id, testRegion.Id, 'EUR_DE_Territory');
            insert offTradeTerritory;
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', POSTALCODE, offTradeTerritory.id, 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping');
            insert offTradeTerritoryMapping;

            EUR_CRM_Account__c accountEU = EUR_CRM_TestClassUtilityHelper.createAccountEU('euAccount', POSTALCODE, 'EUR_DE_OFF_STD');
            insert accountEU;

            EUR_CRM_OP_Action_List_Template__c opalt = EUR_CRM_TestClassUtilityHelper.creaActionListTemplate('test323', 'DE_OFF_ALT_Sales_Drive', EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE);
            insert opalt;
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_TestClassUtilityHelper.createObjPromo(EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE, 'test', 'Ended');
            insert objPromo;
            EUR_CRM_ObjPromo_Target__c objPromoTarget = EUR_CRM_TestClassUtilityHelper.createOPTarget('EUR_DE_SR_Volume_Target', objPromo.Id, null);
            insert objPromoTarget;
            insert EUR_CRM_TestClassUtilityHelper.createobjPromoAccMapping('EUR_CRM_DE_O_P_Account_Mapping', accountEU.Id, objPromo.Id);

            EUR_CRM_Visit__c visit = EUR_CRM_TestClassUtilityHelper.createVisit('EUR_DE_Off_Trade_Visit', accountEU.id);
            insert visit;

            lstVisitAction = new List<EUR_CRM_Visit_Action__c>();
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, QTY_CONFIRMED));
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, YES));
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('EUR_DE_ON_TMKT_Promo_Presentation', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, PRESENTED));            
        }
    }
    
    static testMethod void testAccrueAchievements(){
        dataInsert();
        Database.SaveResult[] srList;

        Test.startTest();
        	System.runAs(onTradeUser){
        		srList = Database.insert(lstVisitAction, false);
        	}
        Test.stopTest();

		System.assertEquals(3, srList.size());
		for (Database.SaveResult sr : srList){
    		System.assert(sr.isSuccess());
		}
    }
	
}