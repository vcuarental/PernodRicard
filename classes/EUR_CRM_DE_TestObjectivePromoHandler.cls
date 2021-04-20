@isTest
public class EUR_CRM_DE_TestObjectivePromoHandler{

    @isTest
    public static void test1(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
		System.debug('### SOQL Limits 1:'+Limits.getQueries());
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();
			System.debug('### SOQL Limits 2:'+Limits.getQueries());
            Test.startTest();
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
			System.debug('### SOQL Limits 3:'+Limits.getQueries());
            
            EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c = 1;
            update EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy;            
			System.debug('### SOQL Limits 4:'+Limits.getQueries());
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,03);
            update objPromo;
            Test.stopTest();
        }
    }
    static void createUser() {
        EUR_CRM_DE_TestClassUtilityHelper.regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.REGIONAL_ON_TRADE_MANAGER_ROLE, 'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');
        EUR_CRM_DE_TestClassUtilityHelper.salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }

}