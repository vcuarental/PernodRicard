@isTest
public class EUR_CRM_DE_TestBQSTargetMgmtCtrlr{

    @isTest
    public static void testEmptyCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('testDE_OFF_ALT_Leaflet_Campaign','DE_OFF_ALT_Leaflet_Campaign' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today().addDays(1);
            insert objPromo;
            
            List<EUR_CRM_ObjPromo_Target__c> opTargetList = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(10, 'Objective Volume Target', objPromo.Id, null);
            for (EUR_CRM_ObjPromo_Target__c opTarget:opTargetList){
                opTarget.EUR_CRM_BQS__c = EUR_CRM_DE_TestClassUtilityHelper.bqs.Id;
                opTarget.EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.Id;
            }
            
            insert opTargetList;
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c noAccountCustTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            noAccountCustTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy6.id;
            noAccountCustTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert noAccountCustTax;
            
            Test.startTest();
            
            PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_BQSTargetManagementController exCon = new EUR_CRM_BQSTargetManagementController(sc); 
       
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeBQS();
            exCon.saveBQS();
            exCon.getIsSelectByBQS();
            exCon.getIsSelectBySKU();
            exCon.dummy();
                 // STOP TEST ---            
            Test.stopTest(); 
            /*
            PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_BQSTargetManagementController exCon = new EUR_CRM_BQSTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeBQS();
            exCon.save();
            Test.stopTest();
            */
        }
    }    
}