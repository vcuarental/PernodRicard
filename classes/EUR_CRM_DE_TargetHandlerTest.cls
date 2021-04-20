/*
    @Description: Test for EUR_CRM_DE_TargetHandler
 */
@IsTest
public with sharing class EUR_CRM_DE_TargetHandlerTest {

    @IsTest
    public static void testAggregateActualVolume_AIAU() {
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser) {
            Test.startTest();
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            Id customerTaxonomyId = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;

            EUR_CRM_SKU__c eur_sku = EUR_CRM_DE_TestClassUtilityHelper.createSKU('Absolut', '70351300', EUR_CRM_DE_TestClassUtilityHelper.DE_SKU);

            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                    1, EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE, 'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            insert objPromo;

            //CREATE O/P Target
            List<EUR_CRM_ObjPromo_Target__c> opTargets = new List<EUR_CRM_ObjPromo_Target__c>();

            EUR_CRM_ObjPromo_Target__c parentObjTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', objPromo.Id, null).get(0);
            insert parentObjTarget;

            //Regional
            EUR_CRM_ObjPromo_Target__c objTarget0 = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'SR Volume Target', objPromo.Id, parentObjTarget.Id).get(0);
            objTarget0.EUR_CRM_SKU__c = eur_sku.id;
            objTarget0.EUR_CRM_Actual_Volume_Bottles__c = 100;
            opTargets.add(objTarget0);
            //National
            EUR_CRM_ObjPromo_Target__c objTarget1 = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Sales Agency Managed Target', objPromo.Id, parentObjTarget.Id).get(0);
            objTarget1.EUR_CRM_SKU__c = eur_sku.id;
            objTarget1.EUR_CRM_Actual_Volume_Bottles__c = 100;
            opTargets.add(objTarget1);

            EUR_CRM_ObjPromo_Target__c objTarget2 = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Regional Volume Target', objPromo.Id, parentObjTarget.Id).get(0);
            objTarget2.EUR_CRM_SKU__c = eur_sku.id;
            objTarget2.EUR_CRM_Actual_Volume_Bottles__c = 100;
            opTargets.add(objTarget2);

            insert opTargets;
            System.assertEquals(300,[SELECT SUM(EUR_CRM_Actual_Volume_Bottles__c) actVol FROM EUR_CRM_ObjPromo_Target__c WHERE Id=:parentObjTarget.Id].get(0).get('actVol'));
            Test.stopTest();
        }
    }
}