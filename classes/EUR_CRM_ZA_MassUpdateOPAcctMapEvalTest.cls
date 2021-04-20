/*
*    Description : Test class for EUR_CRM_ZA_MassUpdateOPAcctMapEval
*
*/
@isTest
private class EUR_CRM_ZA_MassUpdateOPAcctMapEvalTest {

    //Test method for executing Batch Test for PromoAccount Mapping
    static testMethod void executeBatchTest() {
        
        //Create test data for Action List Template        
        EUR_CRM_OP_Action_List_Template__c objActionTemplate = new EUR_CRM_OP_Action_List_Template__c(); 
        objActionTemplate.EUR_CRM_External_ID__c = 'ZA_OFF_ALT_Promo';
        objActionTemplate.recordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__cEUR_ZA_OP_Action_List_Template');
        insert objActionTemplate;
        
        //Create test data for Object Promo
        List<EUR_CRM_ObjPromo__c> objPromoList = EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, 'EUR_ZA_Off_Trade_Promotion');
        EUR_CRM_ObjPromo__c objPromo = objPromoList[0];
        objPromo.EUR_CRM_Status__c = 'test';
        objPromo.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today() - 7;
        objPromo.EUR_CRM_Active_End_Date__c = Date.today();
        objPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.today() + 1;
        insert objPromo;
        
        //Create test data for Account(EU)
        List<EUR_CRM_Account__c> crmAccountList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'test', 'EUR_ZA_Off_Trade');
        EUR_CRM_Account__c crmAccountObj = crmAccountList[0];
        insert crmAccountObj;
        
        //Create test data for EUR_CRM_Visit_Action__c
        EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
        visitAction.EUR_CRM_Account__c = crmAccountObj.Id;
        visitAction.EUR_CRM_Status__c = 'Evaluation: Successful';
        visitAction.EUR_CRM_ObjPromo__c = objPromo.Id;
        visitAction.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Action__cEUR_ZA_ON_Follow_Up');
        insert visitAction;
        
        //Create test data for O/P Account Mapping (EU)
        EUR_CRM_ObjPromo_Account_Mapping__c promoAccMappingObj = new EUR_CRM_ObjPromo_Account_Mapping__c();
        promoAccMappingObj.EUR_CRM_Is_Active__c = false;
        promoAccMappingObj.EUR_CRM_Evaluation_Required__c = true;
        promoAccMappingObj.EUR_CRM_Account__c = crmAccountObj.Id;
        promoAccMappingObj.EUR_CRM_ObjPromo__c = objPromo.Id;
        promoAccMappingObj.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__cEUR_ZA_OP_Account_Mapping');   
        insert promoAccMappingObj;
        
        test.startTest();
            EUR_CRM_ZA_MassUpdateOPAcctMapEval massUpdateBatch = new EUR_CRM_ZA_MassUpdateOPAcctMapEval();
            Database.executeBatch(massUpdateBatch);
        test.stopTest();                                        
            System.assertEquals(false, [SELECT Id, EUR_CRM_Evaluation_Required__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE Id =: promoAccMappingObj.Id].EUR_CRM_Evaluation_Required__c);
    }
}