/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for 
                    EUR_CRM_OnTradePromoMgmtPageController
History
08/04/2014      IPC     Created 
------------------------------------------------------------*/
@isTest
public class EUR_CRM_DE_TestOnTradePromoMgmtPageCtrlr{
    
    @isTest
    public static void test1(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            insertVariationRecords();
            Test.startTest();
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_ON_ALT_ON_PROS_TMKT_Promos' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_ON_TRADE_PROS_TMKT_PROMO,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
             objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
             EUR_CRM_Status__c,EUR_CRM_ObjPromo_OnTrade_Variation__c,//EUR_CRM_Customer_Taxonomy__c,   
          EUR_CRM_PROS_Image_Level__c, 
               EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
             id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
             
            PageReference aPage = Page.EUR_CRM_OnTradePromoManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo); 
            EUR_CRM_OnTradePromoMgmtPageController exCon = new EUR_CRM_OnTradePromoMgmtPageController(sc);
            exCon.getTargets();
            exCon.outletTypeValue = 'Restaurant';
            exCon.imageTypeValue = 'Iconic';
            exCon.retrieveVariationTypeOptions();
            system.assert(exCon.save() != null);
            Test.stopTest();
        }
    }
    
    private static void insertVariationRecords(){
          Id prosSegmentRT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_PROS_Segment__c','DE O/P Promo Activity');
          Id varDetailRT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_OnTrade_Var_Detail__c','DE O/P Promo Variation Detail');
          Id varRT= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_OnTrade_Variation__c','DE O/P Promo Variation');
          Id bqRT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR DE Quality');
  
          EUR_CRM_ObjPromo_PROS_Segment__c prosSegment = new EUR_CRM_ObjPromo_PROS_Segment__c(
          EUR_CRM_Outlet_Image__c = 'Iconic',
          EUR_CRM_Outlet_Type__c = 'Restaurant',
          recordtypeid = prosSegmentRT
          );
          insert prosSegment ;
          EUR_CRM_ObjPromo_OnTrade_Variation__c var = new EUR_CRM_ObjPromo_OnTrade_Variation__c(
          Name = 'test',
          recordtypeid=varRT);
          insert var;
          
          EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c promap = new EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c(
         EUR_CRM_ObjPromo_OnTrade_Variation__c = var.id,
         EUR_CRM_ObjPromo_PROS_Segment__c = prosSegment.id
          );
          insert promap ;
          
          EUR_CRM_Quality__c quality = new EUR_CRM_Quality__c (name='test',recordtypeid = bqRT); 
          insert quality;
          EUR_CRM_ObjPromo_OnTrade_Var_Detail__c detail = new EUR_CRM_ObjPromo_OnTrade_Var_Detail__c(
          EUR_CRM_ObjPromo_OnTrade_Variation__c = var.id,
          recordtypeid=varDetailRT ,
          EUR_CRM_Quality__c = quality.id
          );
          insert detail;
    }
    static void createUser() {
        EUR_CRM_DE_TestClassUtilityHelper.regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.REGIONAL_ON_TRADE_MANAGER_ROLE, 'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');
        EUR_CRM_DE_TestClassUtilityHelper.salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }

}