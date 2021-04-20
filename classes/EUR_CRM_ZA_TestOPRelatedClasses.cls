@isTest
public class EUR_CRM_ZA_TestOPRelatedClasses {
    
    /****************************************************************************************************************************
    *
    ****************************************************************************************************************************/   
    static testMethod void TestOP() {
        // Create Za Obj Promo Action List Template
        EUR_CRM_OP_Action_List_Template__c actionListTemp1 = new EUR_CRM_OP_Action_List_Template__c(name='Promo Action List 1', EUR_CRM_External_ID__c='ZA_OFF_ALT_Promo');
        EUR_CRM_OP_Action_List_Template__c  actionListTemp2 = new EUR_CRM_OP_Action_List_Template__c(name='Promo Action List 2', EUR_CRM_External_ID__c='ZA_ON_ALT_Promo');
        List<EUR_CRM_OP_Action_List_Template__c> actionListTempList = new List<EUR_CRM_OP_Action_List_Template__c>{actionListTemp1, actionListTemp2};
        insert actionListTempList;

        EUR_CRM_ZA_TestClassHelper.getRecordAccountTypeIds();
        Map<String, Id> zaAccsRtMap = EUR_CRM_ZA_TestClassHelper.zaAccountRecordTypeIdsMap;
        EUR_CRM_ZA_TestClassHelper.getObjPromoRecordTypeIds();
        Map<String, Id> zaObjPromoRtMap = EUR_CRM_ZA_TestClassHelper.zaObjPromoRecordTypeIdsMap;
        
        List<EUR_CRM_Account__c> accList = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(string key : zaObjPromoRtMap.KeySet()){
            objPromoList.add(EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, key)[0]);
        }
        insert objPromoList;

        for(String key : zaAccsRtMap.KeySet()){
            accList.add(EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'TestOPRelatedClasses_' + key, key)[0]);
        }
        insert accList;

        for(EUR_CRM_Account__c acc : accList){
            objPromoAccMappingList.add(EUR_CRM_ZA_TestClassHelper.createAccMap(1, acc, objPromoList[0])[0]);
        }
        insert objPromoAccMappingList;


        // Test OP Schedules and batches
        Datetime dt= Datetime.now() + (0.00138);
        String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 
        EUR_CRM_ZA_ScheduledMassUpdateOPAcct  scMassUpdateOP = new EUR_CRM_ZA_ScheduledMassUpdateOPAcct(); 
        Id schedId = System.Schedule('EUR_CRM_ZA_ScheduledMassUpdateOPAcct'+timeForScheduler,timeForScheduler,scMassUpdateOP);

        EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping  scMassUpdateMapping = new EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping(); 
        schedId = System.Schedule('EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping'+timeForScheduler,timeForScheduler,scMassUpdateMapping);
        
        EUR_CRM_ZA_ScheduledMassUpdOPAcctTerm  scMassUpdateTerm = new EUR_CRM_ZA_ScheduledMassUpdOPAcctTerm(); 
        schedId = System.Schedule('EUR_CRM_ZA_ScheduledMassUpdOPAcctTerm'+timeForScheduler,timeForScheduler,scMassUpdateTerm);        
    }	

    static testMethod void testBudget(){
        
    }
}