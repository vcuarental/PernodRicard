@isTest
public class EUR_CRM_ZA_TestOPRelatedBatches {

    private static List<EUR_CRM_Account__c> accList;
    private static List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccMappingList;
    private static List<EUR_CRM_ObjPromo__c> objPromoList;

    static void dataSetup(){
        // Create Za Obj Promo Action List Template
        EUR_CRM_OP_Action_List_Template__c actionListTemp1 = new EUR_CRM_OP_Action_List_Template__c(name='Promo Action List 1', EUR_CRM_External_ID__c='ZA_OFF_ALT_Promo');
        EUR_CRM_OP_Action_List_Template__c  actionListTemp2 = new EUR_CRM_OP_Action_List_Template__c(name='Promo Action List 2', EUR_CRM_External_ID__c='ZA_ON_ALT_Promo');
        List<EUR_CRM_OP_Action_List_Template__c> actionListTempList = new List<EUR_CRM_OP_Action_List_Template__c>{actionListTemp1, actionListTemp2};
        insert actionListTempList;

        // Insert master Data EUR_CRM_ObjPromo_Action__c
        EUR_CRM_ObjPromo_Action__c promoAction1 = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c='EUR_ZA_OFF_Follow_Up', EUR_CRM_OP_Action_List_Template__c=actionListTemp1.Id);
        EUR_CRM_ObjPromo_Action__c promoAction2 = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c='EUR_ZA_ON_Follow_Up', EUR_CRM_OP_Action_List_Template__c=actionListTemp2.Id);
        List<EUR_CRM_ObjPromo_Action__c> promoActionList = new List<EUR_CRM_ObjPromo_Action__c>{promoAction1, promoAction2};
        insert promoActionList;

        EUR_CRM_ZA_TestClassHelper.getRecordAccountTypeIds();
        Map<String, Id> zaAccsRtMap = EUR_CRM_ZA_TestClassHelper.zaAccountRecordTypeIdsMap;
        EUR_CRM_ZA_TestClassHelper.getObjPromoRecordTypeIds();
        Map<String, Id> zaObjPromoRtMap = EUR_CRM_ZA_TestClassHelper.zaObjPromoRecordTypeIdsMap;

        accList = new List<EUR_CRM_Account__c>();
        objPromoAccMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(string key : zaObjPromoRtMap.KeySet()){
            EUR_CRM_ObjPromo__c newObjPromo = EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, key)[0];
            newObjPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(-1);
            objPromoList.add(newObjPromo);
        }
        insert objPromoList;

        for(String key : zaAccsRtMap.KeySet()){
            accList.add(EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'TestOPRelatedClasses_' + key, key)[0]);
        }
        insert accList;

        for(EUR_CRM_Account__c acc : accList){
            EUR_CRM_ObjPromo_Account_Mapping__c newMapping = EUR_CRM_ZA_TestClassHelper.createAccMap(1, acc, objPromoList[0])[0];
            newMapping.EUR_CRM_Evaluation_Required__c = true;
            newMapping.EUR_CRM_Is_Active__c = false;
            objPromoAccMappingList.add(newMapping);
        }
        insert objPromoAccMappingList;
    }

    /*
        Test method for EUR_CRM_ZA_MassUpdOPAcctTermination batch class
    */
    static testMethod void testZAMassUpdOPAcctTerminationBatch(){
        dataSetup();
        // Set the required fields in the batch's query
//        for(EUR_CRM_ObjPromo_Account_Mapping__c mapping : objPromoAccMappingList){
//            mapping.EUR_CRM_Is_Active__c = true;
//            mapping.EUR_CRM_Evaluation_Required__c = false;
//        }
//        update objPromoAccMappingList;

        List<EUR_CRM_Visit_Action__c> actionsList = new List<EUR_CRM_Visit_Action__c>();
        RecordType zaVisitRT =  Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__cEUR_ZA_OFF_Define_Participation_Conditions');
        for(EUR_CRM_ObjPromo__c objPromo : objPromoList){
            // Update OP
            objPromo.EUR_CRM_Active_End_Date__c = Date.Today();
            objPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(-1);
            // Create corresponding Visit Action 
            EUR_CRM_Visit_Action__c newVisit = EUR_CRM_ZA_TestClassHelper.createVisitAction(1, objPromo)[0];
            newVisit.EUR_CRM_Stage__c = 'Execution';
            newVisit.EUR_CRM_Status__c = 'Yes';
            newVisit.RecordType = zaVisitRT;
            newVisit.RecordTypeId = zaVisitRT.Id;
            actionsList.add(newVisit);
        }
        insert actionsList;
        update objPromoList;

        Test.startTest();
            EUR_CRM_ZA_MassUpdOPAcctTermination massUpdateBatch = new EUR_CRM_ZA_MassUpdOPAcctTermination();
            Id job = Database.executeBatch(massUpdateBatch,200);
        Test.stopTest();
    }

    /*
        Test method for EUR_CRM_ZA_CreateVisitActionFollowUps batch class
    */
    static testMethod void testZACreateVisitActionFollowUpsBatch(){
        dataSetup();
        // Set the required fields in the batch's query
//        for(EUR_CRM_ObjPromo_Account_Mapping__c mapping : objPromoAccMappingList){
//            mapping.EUR_CRM_Is_Active__c = false;
//            mapping.EUR_CRM_Evaluation_Required__c = true;
//        }
//        update objPromoAccMappingList;

        List<EUR_CRM_Visit_Action__c> actionsList = new List<EUR_CRM_Visit_Action__c>();
        RecordType zaVisitRT =  Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__cEUR_ZA_OFF_Define_Participation_Conditions');
        RecordType zaVisitRT2 = Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__cEUR_ZA_ON_Define_Participation_Conditions');
        for(EUR_CRM_ObjPromo__c objPromo : objPromoList){
            // Update OP
            objPromo.EUR_CRM_Active_End_Date__c = Date.Today();
            objPromo.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(5);
            // Create corresponding Visit Action 
            EUR_CRM_Visit_Action__c newVisit = EUR_CRM_ZA_TestClassHelper.createVisitAction(1, objPromo)[0];
            newVisit.EUR_CRM_Account__c = accList[0].Id;
            newVisit.EUR_CRM_Status__c = 'Yes';
            newVisit.RecordType = zaVisitRT;
            newVisit.RecordTypeId = zaVisitRT.Id;
            actionsList.add(newVisit);

            EUR_CRM_Visit_Action__c newVisit2 = EUR_CRM_ZA_TestClassHelper.createVisitAction(1, objPromo)[0];
            newVisit2.EUR_CRM_Account__c = accList[1].Id;
            newVisit2.EUR_CRM_Status__c = 'Yes';
            newVisit2.RecordType = zaVisitRT2;
            newVisit2.RecordTypeId = zaVisitRT2.Id;
            actionsList.add(newVisit2);
        }
        update objPromoList;
        insert actionsList;

        Test.startTest();
            EUR_CRM_ZA_CreateVisitActionFollowUps visitActionBatch = new EUR_CRM_ZA_CreateVisitActionFollowUps();
            Id job = Database.executeBatch(visitActionBatch,200);
        Test.stopTest();
    }
    
}