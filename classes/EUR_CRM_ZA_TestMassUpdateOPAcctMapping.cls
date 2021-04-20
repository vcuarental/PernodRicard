/*
*    Description : Test class for EUR_CRM_ZA_MassUpdateOPAccountMapping
*
*/
@isTest
private class EUR_CRM_ZA_TestMassUpdateOPAcctMapping {

    static testMethod void executeBatchTest() {
    	
        //Create test data for Action List Template        
        EUR_CRM_OP_Action_List_Template__c objActionTemplate = new EUR_CRM_OP_Action_List_Template__c(); 
        objActionTemplate.EUR_CRM_External_ID__c = 'ZA_OFF_ALT_Promo';
        objActionTemplate.recordTypeId = [SELECT Id FROM RecordType WHERE Developername =: 'EUR_ZA_OP_Action_List_Template'][0].Id;
        insert objActionTemplate;
    
        //Create test data for Object Promo
        List<EUR_CRM_ObjPromo__c> objPromoList = EUR_CRM_ZA_Deactivate_O_P_ControllerTest.createObjPromo(1);
        EUR_CRM_ObjPromo__c objPromo = objPromoList[0];
        objPromo.EUR_CRM_Status__c = 'test';
        objPromo.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        objPromo.EUR_CRM_Active_End_Date__c = Date.Today();
        objPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(3);
        objPromo.recordTypeId = [SELECT Id FROM RecordType WHERE Developername =: 'EUR_ZA_Off_Trade_Promotion'][0].Id;
        insert objPromo;        
        
        //Create test data for Account(EU)
        List<EUR_CRM_Account__c> crmAccountList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'test', 'EUR_ZA_Off_Trade');
        EUR_CRM_Account__c crmAccountObj = crmAccountList[0];
        insert crmAccountObj;
        
        //Create test data for EUR_CRM_ObjPromo_Action__c
        List<EUR_CRM_ObjPromo_Action__c> promoActionList = new List<EUR_CRM_ObjPromo_Action__c>(); 
        EUR_CRM_ObjPromo_Action__c promoAction1 = new EUR_CRM_ObjPromo_Action__c();
        promoAction1.EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_ZA_ON_Follow_Up';
        promoAction1.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        promoActionList.add(promoAction1);
        
        EUR_CRM_ObjPromo_Action__c promoAction2 = new EUR_CRM_ObjPromo_Action__c();
        promoAction2.EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_ZA_OFF_Follow_Up';
        promoAction2.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        promoActionList.add(promoAction2);
        
        insert promoActionList;
        
        //Create test data for EUR_CRM_Visit_Action__c
        List<EUR_CRM_Visit_Action__c> visitActionList = new List<EUR_CRM_Visit_Action__c>(); 
        for(Integer i = 0; i < 2; i++){
            EUR_CRM_Visit_Action__c objVisitAction = new EUR_CRM_Visit_Action__c();
            objVisitAction.EUR_CRM_Account__c = crmAccountObj.Id;
            objVisitAction.EUR_CRM_Status__c = 'Yes';
            objVisitAction.EUR_CRM_Stage__c = 'Execution';
            objVisitAction.EUR_CRM_ObjPromo__c = objPromo.Id;            
            visitActionList.add(objVisitAction);
        }
        visitActionList[0].recordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Action__cEUR_ZA_OFF_Define_Participation_Conditions');
        visitActionList[1].recordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Action__cEUR_ZA_ON_Define_Participation_Conditions');
        insert visitActionList;
        
        //Create test data for O/P Account Mapping (EU)
        EUR_CRM_ObjPromo_Account_Mapping__c promoAccMappingObj = new EUR_CRM_ObjPromo_Account_Mapping__c();
        promoAccMappingObj.EUR_CRM_Is_Active__c = true;
        promoAccMappingObj.EUR_CRM_Evaluation_Required__c = false;
        promoAccMappingObj.EUR_CRM_Account__c = crmAccountObj.Id;
        promoAccMappingObj.EUR_CRM_ObjPromo__c = objPromo.Id;
        promoAccMappingObj.recordTypeId = [SELECT Id FROM RecordType WHERE Developername =: 'EUR_ZA_OP_Account_Mapping'][0].Id;
        insert promoAccMappingObj;
        
        EUR_CRM_ZA_MassUpdateOPAccountMapping updateBatch = new EUR_CRM_ZA_MassUpdateOPAccountMapping();
        test.startTest();
            Database.executeBatch(updateBatch);
        test.stopTest();
    }
}