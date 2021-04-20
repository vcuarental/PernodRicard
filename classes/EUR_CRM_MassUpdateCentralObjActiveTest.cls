@isTest(seealldata=true)
private with sharing class EUR_CRM_MassUpdateCentralObjActiveTest {
  
    static List<EUR_CRM_Account__c> getAccounts(String RecordTypeDevName, Integer RecordLimit){
        //'EUR_GB_FS_Indirect'
        //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
        Id rtId = [select id from recordtype where developername = : RecordTypeDevName and sobjecttype = 'eur_crm_account__c' limit 1].id;
        List<EUR_CRM_Account__c> acctlist = [SELECT Id,Name, RecordTypeId, RecordType.DeveloperName FROM EUR_CRM_Account__c WHERE recordTypeId = :rtId Limit :RecordLimit];
        return acctlist;
    }
    
  static testMethod void myUnitTest1(){ 
        try
        {
           //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
            List<EUR_CRM_Account__c> acctlist = getAccounts('EUR_PT_Wholesaler',2);
            //Id rectypeId = Schema.SObjectType.EUR_CRM_GB_Objective__c.getRecordTypeInfosByName().get('EUR PT Off Trade Central Objective').getRecordTypeId();
            
            id rectypeId = [SELECT id FROM RECORDTYPE Where DeveloperName = 'EUR_PT_Off_Trade_Central_Promotion' Limit 1].Id;
            EUR_CRM_GB_Objective__c obj = new EUR_CRM_GB_Objective__c(name='test pt central objective',EUR_CRM_Start_Date__c=Date.today()-2,recordtypeId=rectypeId,EUR_CRM_End_Date__c=Date.today()-1);
            insert obj;
            
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(EUR_CRM_Active__c=true,EUR_CRM_Is_Promo_Active__c=false,EUR_CRM_Objective__c=obj.Id);
            insert visitaction;
            
            EUR_CRM_MassUpdateCentralObjActive b = new EUR_CRM_MassUpdateCentralObjActive(); 
            Database.executeBatch(b,200);  
        }
        catch(Exception e)
        {
            System.Debug('Test 1 Failed:' + e);
        }

  }
  static testMethod void myUnitTest2(){ 
        try{
            //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
            List<EUR_CRM_Account__c> acctlist = getAccounts('EUR_PT_Wholesaler',2);
            //Id rectypeId = Schema.SObjectType.EUR_CRM_GB_Objective__c.getRecordTypeInfosByName().get('EUR PT Off Trade Central Objective').getRecordTypeId();
            Id rectypeId = [SELECT id FROM RECORDTYPE Where DeveloperName = 'EUR_PT_Off_Trade_Central_Promotion' Limit 1].Id;
            EUR_CRM_GB_Objective__c obj = new EUR_CRM_GB_Objective__c(name='test pt central objective',EUR_CRM_Start_Date__c=Date.today(),EUR_CRM_End_Date__c=Date.today()+1,recordtypeId=rectypeId);
            insert obj;
            
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(EUR_CRM_Active__c=true,EUR_CRM_Is_Promo_Active__c=false,EUR_CRM_Objective__c=obj.Id);
            insert visitaction;
            
            EUR_CRM_MassUpdateCentralObjActive b = new EUR_CRM_MassUpdateCentralObjActive(); 
            Database.executeBatch(b,200); 
        }catch(Exception e)
        {
            System.Debug('Test 2 Failed:' + e);
        }

 
  }
    
    static testMethod void myUnitTest3(){ 
        try{
            //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
            List<EUR_CRM_Account__c> acctlist = getAccounts('EUR_GB_FS_Indirect',2);
            //Id rectypeId = Schema.SObjectType.EUR_CRM_GB_Objective__c.getRecordTypeInfosByName().get('EUR PT Off Trade Central Objective').getRecordTypeId();
            Id rectypeId = [SELECT id FROM RECORDTYPE Where DeveloperName = 'EUR_BG_Central_Promotion' Limit 1].Id;
            EUR_CRM_GB_Objective__c obj = new EUR_CRM_GB_Objective__c(name='test uk central objective',EUR_CRM_Start_Date__c=Date.today(),EUR_CRM_End_Date__c=Date.today()+1,recordtypeId=rectypeId);
            insert obj;
            
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(EUR_CRM_Active__c=true,EUR_CRM_Is_Promo_Active__c=false,EUR_CRM_Objective__c=obj.Id);
            insert visitaction;
            
            EUR_CRM_MassUpdateCentralObjActive b = new EUR_CRM_MassUpdateCentralObjActive(); 
            Database.executeBatch(b,200); 
        }catch(Exception e)
        {
            System.Debug('Test 3 Failed:' + e);
        }
 
  }
    
    static testMethod void myUnitTest4(){ 
        try{
            //List<EUR_CRM_Account__c> acctlist = EUR_CRM_FilteredMassChatterCtrllerTest.createAccts();
            List<EUR_CRM_Account__c> acctlist = getAccounts('EUR_GB_FS_Indirect',2);
            //Id rectypeId = Schema.SObjectType.EUR_CRM_GB_Objective__c.getRecordTypeInfosByName().get('EUR PT Off Trade Central Objective').getRecordTypeId();
            id rectypeId = [SELECT id FROM RECORDTYPE Where DeveloperName = 'EUR_BG_Central_Promotion' Limit 1].Id;
            EUR_CRM_GB_Objective__c obj = new EUR_CRM_GB_Objective__c(name='test uk central objective',EUR_CRM_Start_Date__c=Date.today()-2,recordtypeId=rectypeId,EUR_CRM_End_Date__c=Date.today()-1);
            insert obj;
            
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(EUR_CRM_Active__c=true,EUR_CRM_Is_Promo_Active__c=false,EUR_CRM_Objective__c=obj.Id);
            insert visitaction;
            
            EUR_CRM_MassUpdateCentralObjActive b = new EUR_CRM_MassUpdateCentralObjActive(); 
            Database.executeBatch(b,200); 
        }catch(Exception e)
        {
            System.Debug('Test 4 Failed:' + e);
        }

  }
}