@isTest
public class EUR_CRM_DE_OP_Test_EmailNotifController {
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_ObjPromo__c objPromo {get;set;}
    private static EUR_CRM_ObjPromo_Target__c objPromoTarget {get;set;}
    public static List<EUR_CRM_ObjPromo_Target__c> objPromoTargetNat= new List<EUR_CRM_ObjPromo_Target__c>();

    static testMethod void testsendNotificationEmail1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            createData();
            EUR_CRM_DE_OP_EmailNotifController emailNotifier = new EUR_CRM_DE_OP_EmailNotifController();
            ApexPages.currentPage().getParameters().put('id',objPromo.id);
            ApexPages.currentPage().getParameters().put('t','1');
            emailNotifier.sendNotificationEmail();
        }   
    }

    static testMethod void testsendNotificationEmail2(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            createData();
            EUR_CRM_DE_OP_EmailNotifController emailNotifier = new EUR_CRM_DE_OP_EmailNotifController();
            ApexPages.currentPage().getParameters().put('id',objPromo.id);
            ApexPages.currentPage().getParameters().put('t','2');
            emailNotifier.sendNotificationEmail();
        }   
    }

    public static void createData(){
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        Id customerTaxonomyId = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
        Id regionalManager = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id;
        EUR_CRM_Account__c euAccount = EUR_CRM_DE_TestClassUtilityHelper.euAccount;    
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );

        EUR_CRM_SKU__c sku = EUR_CRM_DE_TestClassUtilityHelper.createSKU('Absolut', '70351300', EUR_CRM_DE_TestClassUtilityHelper.DE_SKU );

        objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
        1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
        objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
   
        insert objPromo;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        custTax.EUR_CRM_Customer_Taxonomy__c = customerTaxonomyId;
        custTax.EUR_CRM_ObjPromo__c = objPromo.id;
        insert custTax ;

        Id opTargetId = null;
        EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', objPromo.Id, opTargetId ).get(0);
        objTarget.EUR_CRM_SKU__c = sku.id;
        objTarget.EUR_CRM_SKU__r = sku;
        objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
        objTarget.EUR_CRM_Target_Owner__c = regionalManager;
        insert objTarget;
    }
}