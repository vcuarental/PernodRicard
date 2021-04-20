@isTest
public class EUR_CRM_DE_TestDeactivateOPCtrl{
     @isTest
    public static void testDeactivateOP(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
               Test.startTest();  
            objPromo = [select id, RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: objPromo.id];
            
            PageReference aPage = Page.EUR_CRM_Deactivate_O_P;
            test.setCurrentPage(aPage);
            aPage.getParameters().put('id',objPromo.id); 
            EUR_CRM_Deactivate_O_P_Controller exCon = new EUR_CRM_Deactivate_O_P_Controller();
            exCon.deactivateOP();      
            // STOP TEST ---            
            Test.stopTest();
        }
    }
}