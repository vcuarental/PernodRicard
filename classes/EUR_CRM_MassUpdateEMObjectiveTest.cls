/*
*    Description : Test class for EUR_CRM_MassUpdateEMObjective
*
*    Version    Author        Date        Description
*    1.0        Jay           19/10/2016  Initial Draft
*/

@isTest
public class EUR_CRM_MassUpdateEMObjectiveTest {

    //Method to create test data
    public static void insertTestData(){
        //Apply Config     
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        apexConfig = EUR_CRM_DK_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        //Create OP Action List Template
        EUR_CRM_OP_Action_List_Template__c actionTemp = EUR_CRM_DK_TestClassHelper.createActionListTemplate();
        system.Debug('!Debug insert actionTemp');
        actionTemp.EUR_CRM_External_ID__c = 'DK_OFF_EffectsManager_Price_Promotion';
        insert actionTemp;
        system.Debug('!Debug actionTemp:' + actionTemp);
        
        //Add OP action to templale
        EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_DK_TestClassHelper.createObjPromoAction();
        objPromoAction.EUR_CRM_OP_Action_List_Template__c = actionTemp.Id;
        system.Debug('!Debug insert objPromoAction');
        insert objPromoAction;
        system.Debug('!Debug objPromoAction:' + objPromoAction);
        
        
        //Create Customer Taxonomy
        EUR_CRM_Customer_Taxonomy__c ct = EUR_CRM_DK_TestClassHelper.createCustomerTaxonomy('TEST CHAIN',UserInfo.getUserId(),'EUR_DK_Customer_Taxonomy');
        
        //Create Account
        EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
        euaccount = EUR_CRM_DK_TestClassHelper.createEUAccountsDKOFF('Test EU ACCOUNT');
        euaccount.EUR_JB_Customer_Taxonomy__c = ct.Id;
        euaccount.EUR_CRM_Status__c = 'Active';
        system.Debug('!Debug insert account');
        insert euaccount;
        system.Debug('!Debug account:' + euaccount);
                 
        //Create O
        List<EUR_CRM_ObjPromo__c> objPromos =  EUR_CRM_DK_TestClassHelper.createEMObjPromo(3,'EUR_DK_Off_Trade_EM_Price_Promotion','testObjPromo');
        system.Debug('!Debug insert objPromo');
        List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
          for(EUR_CRM_ObjPromo__c p: objPromos){
              //p.EUR_CRM_Status__c='Draft';
              promosToInsert.add(p);
          }
          insert promosToInsert;
          for(EUR_CRM_ObjPromo__c p :promosToInsert){
              //p.EUR_CRM_Active_End_Date__c = Date.today()-1;  
              //p.EUR_CRM_Status__c='Active';
              //p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
              promosToUpdate.add(p);
          }
          //update promosToUpdate;
        system.Debug('!Debug objpromot:' + objPromos);
    }

    //Test Method to test Batch
    static testMethod void executeBatchTest() {
        insertTestData();

        Set<String> validRecordTypes = new Set<String>{
            'EUR_DK_Off_Trade_EM_Price_Promotion'
        };
            
        String query = 'SELECT Id, EUR_CRM_Active_End_Date__c, EUR_CRM_Active_Start_Date__c, EUR_CRM_Preparation_Start_Date__c, ' +
                'EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c ' +
                'FROM EUR_CRM_ObjPromo__c WHERE recordtype.developername = :validRecordTypes';
        
        List<EUR_CRM_ObjPromo__c> targetObj = Database.query(query);
        system.Debug('!Debug[targetObj]:' + targetObj);
        
        test.startTest();
        EUR_CRM_MassUpdateEMObjective oEUR_CRM_MassUpdateEMObjective = new EUR_CRM_MassUpdateEMObjective();
        database.executeBatch(oEUR_CRM_MassUpdateEMObjective);
        test.stopTest();
    }
}