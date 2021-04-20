/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for DeactivateOPAccountMappings Class.
  @Author:      IPC 
*/
@isTest (SeeAllData = false)
private with sharing class EUR_CRM_DE_TestDeactivateOPAMappings{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_ObjPromo__c objPromo {get;set;}
    private static EUR_CRM_ObjPromo__c objPromo2 {get;set;}
    private static EUR_CRM_ObjPromo_Target__c objPromoTarget {get;set;}
    private static EUR_CRM_Visit__c visit {get;set;}
    private static EUR_CRM_Visit_Action__c visitAction {get;set;}
    private static EUR_CRM_Visit_Action__c visitAction2 {get;set;}
    private static EUR_CRM_Visit_Action__c visitAction3 {get;set;}
    static list<EUR_CRM_ObjPromo_Account_Mapping__c> ops;
    static Set<id> opIds;
    public static void dataInsert1(){
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert accountEU; 
        /*
        objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1,'DE Off Trade Tasting Campaign','objPromoTest')[0];
        objPromo.EUR_CRM_Active_Start_Date__c = System.today();//date.parse('1/1/2100');
        objPromo.EUR_CRM_Active_End_Date__c = System.today();//date.parse('1/30/2100');
        insert objPromo; */
        
          EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
             objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = System.today();
            objPromo.eur_crm_status__c = 'Ended'; 
            insert objPromo;
             objPromo2 = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo2.EUR_CRM_Active_Start_Date__c = System.today();
            objPromo2.eur_crm_status__c = 'Deactivated'; 
            insert objPromo2;
            EUR_CRM_ObjPromo_Account_Mapping__c opmap = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = accountEU.id,EUR_CRM_Is_Active__c = true, EUR_CRM_ObjPromo__c = objPromo.id ); 
            insert opmap;
            EUR_CRM_ObjPromo_Account_Mapping__c opmap2 = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = accountEU.id,EUR_CRM_Is_Active__c = true, EUR_CRM_ObjPromo__c = objPromo2.id ); 
            insert opmap2;
              ops = new list<EUR_CRM_ObjPromo_Account_Mapping__c>() ;
             ops.add(opmap);
             ops.add(opmap2);
             opIds = new Set<Id>();
             opIds.add(opmap.id);
             opIds.add(opmap2.id);
    }
    
    static testMethod void testDeactivate(){
        dataInsert1();
        Test.startTest();
            EUR_CRM_DE_DeactivateOPAccountMappings  controller = new EUR_CRM_DE_DeactivateOPAccountMappings();
            controller.start(null);
            Database.BatchableContext bc = null;
            controller.execute(bc, ops);
            EUR_CRM_DE_DeactivateOPAccountMappings.deactivate( ops);
            for(EUR_CRM_ObjPromo_Account_Mapping__c op : [select EUR_CRM_Is_Active__c  from EUR_CRM_ObjPromo_Account_Mapping__c where id in:opIds ]){
                system.assert(!(op.EUR_CRM_Is_Active__c));
            }
        Test.stopTest();
    }
}