@isTest
private class EUR_CRM_MassUpdateOPAcctMapEndTest {

    @testSetup
    static void setupData(){
        EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
    
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT');
        insert euaccount;
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        // Create Promo
        List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c p: promos){
            p.EUR_CRM_Status__c='Draft';
            promosToInsert.add(p);
        }
        insert promosToInsert;
        for(EUR_CRM_ObjPromo__c p :promosToInsert){
            p.EUR_CRM_Active_End_Date__c = Date.today()-1; 
            p.EUR_CRM_Status__c='Active';
            p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
            promosToUpdate.add(p);
        }
        update promosToUpdate;
       
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount,promos[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping2 = EUR_CRM_RU_TestClassHelper.createOPAccountMapping(1,'EUR_DK_OP_Account_Mapping',euaccount,promos[0]);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
            m.EUR_CRM_Is_Active__c = true;
            m.EUR_CRM_Evaluation_Required__c = false;
            opMappingToInsert.add(m);
        }
        opMappingToInsert.addAll(opMapping2);
        insert opMappingToInsert;
        
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
        insert objPromoAction;
        
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount,promos[0]);
        visitAction.EUR_CRM_Stage__c = 'Execution';
        visitAction.EUR_CRM_Status__c ='Participating';
        insert visitAction;
    }

    static testmethod void testEUR_CRM_MassUpdateOPAcctMapEnd() {
       	Test.startTest();
       	    EUR_CRM_MassUpdateOPAcctMapEnd c = new EUR_CRM_MassUpdateOPAcctMapEnd();
       	    Id jobId = Database.executeBatch(c);
       	Test.stopTest();
    }

    static testmethod void testEUR_CRM_MassUpdateOPEnd() {
        Test.startTest();
            EUR_CRM_MassUpdateOPEnd c = new EUR_CRM_MassUpdateOPEnd();
            Id jobId = Database.executeBatch(c);
        Test.stopTest();
    }

    static testmethod void testProcessErrors(){
        List<String> messageErrors = new List<String>();
        List<EUR_CRM_ObjPromo__c> promos = [SELECT Id FROM EUR_CRM_ObjPromo__c LIMIT 5];
        promos[0].EUR_CRM_MAF_ID__c='AAAAAAAAAAAAAAAAAAAAA';

        Test.startTest();
            EUR_CRM_MassUpdateOPEnd.processErrors(promos, Database.update(promos, false), messageErrors, 'Fatal error');
            EUR_CRM_MassUpdateOPAcctMapEnd.processErrors(promos, Database.update(promos, false), messageErrors, 'Fatal error');
        Test.stopTest();

        System.assertEquals(4, messageErrors.size());
    }

}