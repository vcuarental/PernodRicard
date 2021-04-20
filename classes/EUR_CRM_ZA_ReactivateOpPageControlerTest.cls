/*
*    Description    :    Apex Test class for EUR_CRM_ZA_ReactivateOpPageController
*
*    Version    Author        Date        Description
*    1.0        Sid           01/04/2016  Initial Draft
*/

@isTest
public class EUR_CRM_ZA_ReactivateOpPageControlerTest { 
   
    //Test method to test Reactivation feature
    public static testMethod void reactivatePositiveDateTest(){
        
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
        
        //Create O/P
        list<EUR_CRM_ObjPromo__c> objPromoList  = EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, 'EUR_ZA_On_Trade_Promotion');
        insert objPromoList;    
     
        //Create Test Data for Account
        List<EUR_CRM_Account__c> accList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'testAccount', 'EUR_ZA_On_Trade_Direct');        
        insert accList;
      
        //Create Test data for O/P Account Mapping
        list<EUR_CRM_ObjPromo_Account_Mapping__c> opAccMapLst = EUR_CRM_ZA_TestClassHelper.createAccMap(5, accList[0], objPromoList[0]); 
        insert opAccMapLst;

        test.startTest(); 
        
            ApexPages.StandardController sc = new ApexPages.standardController(objPromoList[0]);
            EUR_CRM_ZA_ReactivateOpPageController controllerInstance = new EUR_CRM_ZA_ReactivateOpPageController(sc);
            
            controllerInstance.objPromo.EUR_CRM_Active_Start_Date__c = date.today();
            controllerInstance.objPromo.EUR_CRM_Active_End_Date__c = (date.today() + 2);
            controllerInstance.objPromo.EUR_CRM_Evaluation_Period_End_Date__c = (date.today() + 3);
            
            controllerInstance.reactivate();
            
            list<EUR_CRM_ObjPromo_Account_Mapping__c> assertOpAccMapList = [select EUR_CRM_Is_Active__c 
                                                                            from EUR_CRM_ObjPromo_Account_Mapping__c 
                                                                            where EUR_CRM_ObjPromo__c =: objPromoList[0].Id];
            for(EUR_CRM_ObjPromo_Account_Mapping__c objOpAccMap : assertOpAccMapList){
                System.assertEquals(objOpAccMap.EUR_CRM_Is_Active__c, true);
            }
            
            controllerInstance.cancel();
        
        test.stopTest();   
    } 
     public static testMethod void reactivateNegativeDateTest(){
        
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
        
        //Create O/P
        list<EUR_CRM_ObjPromo__c> objPromoList  = EUR_CRM_ZA_TestClassHelper.createObjAndProms(1, 'EUR_ZA_On_Trade_Promotion');
        insert objPromoList;    
     
        //Create Test Data for Account
        List<EUR_CRM_Account__c> accList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'testAccount', 'EUR_ZA_On_Trade_Direct');        
        insert accList;
      
        //Create Test data for O/P Account Mapping
        list<EUR_CRM_ObjPromo_Account_Mapping__c> opAccMapLst = EUR_CRM_ZA_TestClassHelper.createAccMap(5, accList[0], objPromoList[0]); 
        insert opAccMapLst;

        test.startTest(); 
        
            ApexPages.StandardController sc = new ApexPages.standardController(objPromoList[0]);
            EUR_CRM_ZA_ReactivateOpPageController controllerInstance = new EUR_CRM_ZA_ReactivateOpPageController(sc);
            
            controllerInstance.objPromo.EUR_CRM_Active_Start_Date__c = (date.today() - 1);
            controllerInstance.objPromo.EUR_CRM_Active_End_Date__c = (date.today() - 2);
            controllerInstance.objPromo.EUR_CRM_Evaluation_Period_End_Date__c = (date.today() - 3);
            
            controllerInstance.reactivate();
            
            list<EUR_CRM_ObjPromo_Account_Mapping__c> assertOpAccMapList = [select EUR_CRM_Is_Active__c 
                                                                            from EUR_CRM_ObjPromo_Account_Mapping__c 
                                                                            where EUR_CRM_ObjPromo__c =: objPromoList[0].Id];
            for(EUR_CRM_ObjPromo_Account_Mapping__c objOpAccMap : assertOpAccMapList){
                System.assertEquals(objOpAccMap.EUR_CRM_Is_Active__c, false);
            }
            
            controllerInstance.cancel();
        
        test.stopTest();   
    }
}