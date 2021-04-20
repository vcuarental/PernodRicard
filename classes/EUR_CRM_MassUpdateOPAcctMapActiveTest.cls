@isTest
public class EUR_CRM_MassUpdateOPAcctMapActiveTest {
	
    static testmethod void test() {
    	EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
		EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        // The query used by the batch job.
        String query = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' + 
                 ' EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE'+
                 ' Recordtype.DeveloperName = :validRecordTypes AND EUR_CRM_Is_Active__c = FALSE';
       	
       	apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
		insert apexConfig;
		
       	euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT');
       	insert euaccount;
       	
       	EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
       	insert template;
       	// Create Promo
       	List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(1,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
        For(EUR_CRM_ObjPromo__c p : promos){
            
        	p.EUR_CRM_Active_Start_Date__c = System.today();
        	p.EUR_CRM_Active_End_Date__c = System.today().addDays(1);
        }
       	insert promos;
        For(EUR_CRM_ObjPromo__c p : promos){
        	p.EUR_CRM_Status__c = 'Active';
        }
        update promos;
       
		List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping = 	EUR_CRM_RU_TestClassHelper.createOPAccountMapping(1,'EUR_RU_O_P_Account_Mapping',euaccount,promos[0]);
        for(EUR_CRM_ObjPromo_Account_Mapping__c opa :opMapping ){
            opa.EUR_CRM_ObjPromo__c = promos[0].id;
            opa.EUR_CRM_Account__c = euaccount.id;
            opa.EUR_CRM_Is_Active__c = False;
        }
       	insert opMapping;
        
        System.Debug('@@@Promos:' + promos);
        System.Debug('@@@OPMaps:' + opMapping);

       	Test.startTest();
       	EUR_CRM_MassUpdateOPAcctMapActive c = new EUR_CRM_MassUpdateOPAcctMapActive();
        System.Debug('@@@Batch Start');
       	Database.executeBatch(c);
       	Test.stopTest();

    }
}