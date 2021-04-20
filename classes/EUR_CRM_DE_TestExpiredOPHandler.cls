@isTest
public class EUR_CRM_DE_TestExpiredOPHandler{
    @isTest
    public static void testAll(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
		System.debug('### SOQL Limits 1:'+Limits.getQueries());
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            System.debug('### SOQL Limits 2:'+Limits.getQueries());
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02); 
            objPromo.EUR_CRM_Status__c = 'Active'; 
            insert objPromo;
            EUR_CRM_Account__c euAccount = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            List<EUR_CRM_ObjPromo_Account_Mapping__c> mappings = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            Integer rLimit = 100;
            
            Test.startTest();
            for(Integer i = 0 ; i < rLimit ; i++){
                mappings.add(new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = euAccount.id, EUR_CRM_Is_Active__c = true,
                EUR_CRM_ObjPromo__c = objPromo.id));
            }
            insert mappings;
            System.debug('### SOQL Limits 3:'+Limits.getQueries());
                objPromo.EUR_CRM_Status__c = 'Ended';
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