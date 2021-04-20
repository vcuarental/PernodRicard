@isTest
private class EUR_CRM_MassActivateOPTest {
    static testMethod void test1(){
        
        //Create EUAccount
        EUR_CRM_Account__c acc = EUR_CRM_BE_TestClassHelper.createEUAccount('Tester1');
        insert acc;
        
        //Create Action List Template
        EUR_CRM_OP_Action_List_Template__c actionListTemp = new EUR_CRM_OP_Action_List_Template__c(name='Promo Action List Template 1', EUR_CRM_External_ID__c='BE_On_Trade_Promo_Kit_Activation');
        insert actionListTemp;
        
        //Create Action List
        EUR_CRM_ObjPromo_Action__c promoAction = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c='EUR_CRM_OFF_Follow_Up', EUR_CRM_OP_Action_List_Template__c=actionListTemp.Id);
        insert promoAction;
        
        //Create AccRtMap
        Map<String,Id> accountRecordTypeIdsMap = new Map<String,Id>();
        for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType where SobjectType='EUR_CRM_Account__c' AND
                                  DeveloperName = 'EUR_BE_On_Trade']){
                                      accountRecordTypeIdsMap.put(recType.DeveloperName, recType.Id);
                                  }
        
        //Create ObjPromoRtMap
        Map<String, Id> objPromoRecordTypeIdsMap = new Map<String, Id>();
        for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='EUR_CRM_ObjPromo__c' AND 
                                  DeveloperName = 'EUR_BE_On_Trade_Promo_Kit_Activation']){
                                      objPromoRecordTypeIdsMap.put(recType.DeveloperName, recType.Id);
                                  }
        
        //Create AccList
        List<EUR_CRM_Account__c> accList = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        //Create objPromoList
        
        EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c();
        objAndProm.RecordTypeId = objPromoRecordTypeIdsMap.values()[0];
        objAndProm.Name = 'TestObjPromo';
        objAndProm.EUR_CRM_Active_Start_Date__c = Date.Today();
        objAndProm.EUR_CRM_Active_End_Date__c = Date.Today().addDays(360);
        objAndProm.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20);
        
        insert objAndProm;
       
        
        // Set the required fields in the batch's query
        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = EUR_CRM_BE_TestClassHelper.createobjPromoAccMapping('EUR_BE_O_P_Account_Mapping', acc.Id, objAndProm.Id);        
        objPromoAccMapping.EUR_CRM_Is_Active__c = true;
        objPromoAccMapping.EUR_CRM_Evaluation_Required__c = false;            
        insert objPromoAccMapping;
        
        Map<String,Id> rtMap = new Map<String,Id>();
        List<String> validRecordType = New List<String>{'EUR_BE_Off_Trade_Sales_Drive',
            'EUR_BE_Off_Trade_Secondary_placement_Spyder_display',
            'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist',
            'EUR_BE_On_Trade_Promo_Kit_Activation'}; 
                for(RecordType rt : [select id, developername from RecordType where developername in :validRecordType]){
                    rtMap.put(rt.developername,rt.id);
                }
        RecordType visitAction =  Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__c'+'EUR_BE_Off_Trade_Sales_Drive');
        
        objAndProm.Name = 'Test1';
        objAndProm.EUR_CRM_Status__c = 'Published';
        objAndProm.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1);
        objAndProm.EUR_CRM_Active_End_Date__c = Date.today().addDays(50);
        
        EUR_CRM_Visit_Action__c newVisit = new EUR_CRM_Visit_Action__c();
        newVisit.EUR_CRM_ObjPromo__c = objAndProm.Id;
        newVisit.EUR_CRM_Account__c = acc.id;
        newVisit.EUR_CRM_Stage__c = 'Execution';
        newVisit.EUR_CRM_Status__c = 'Yes';
        newVisit.RecordType = visitAction;
        
        upsert objAndProm;
        insert newVisit;
        
        Test.startTest();
        EUR_CRM_MassActivateOP batch1 = new EUR_CRM_MassActivateOP();
        Id job = Database.executeBatch(batch1,200);
        Test.stopTest();
    }
}