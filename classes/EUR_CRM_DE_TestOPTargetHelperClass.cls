@isTest
public class EUR_CRM_DE_TestOPTargetHelperClass {

    @isTest
    public static void testRetrieveTargets() {
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
        //System.debug('### EUR_CRM_DE_TestOPTargetHelperClass SOQL Limits 1:'+Limits.getQueries());
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser) {

            EUR_CRM_DE_TestClassUtilityHelper.initData();
            //System.debug('### SOQL EUR_CRM_DE_TestOPTargetHelperClass Limits 2:'+Limits.getQueries());
            Id customerTaxonomyId = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            Id regionalManager = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id;
            EUR_CRM_Account__c euAccount = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
            List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
            accounts.add(euAccount);
            List<Id> accountOwnerIds = new List<Id>();
            accountOwnerIds.add(EUR_CRM_DE_TestClassUtilityHelper.regionalUser.Id);
//              EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );

            EUR_CRM_SKU__c sku = EUR_CRM_DE_TestClassUtilityHelper.createSKU('Absolut', '70351300', EUR_CRM_DE_TestClassUtilityHelper.DE_SKU);
            sku.EUR_CRM_Unit_Type__c = 'Bottle';
            update sku;

            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                    1, EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE, 'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            Id opTargetId = null;
            EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', objPromo.Id, opTargetId).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            insert objTarget;
            EUR_CRM_ObjPromo_Target__c objRegionalTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Regional Volume Target', objPromo.Id, objTarget.id).get(0);
            objRegionalTarget.EUR_CRM_SKU__c = sku.id;
            objRegionalTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objRegionalTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objRegionalTarget.EUR_CRM_Target_Owner__c = regionalManager;
            objRegionalTarget.EUR_CRM_Target_Owner__r = EUR_CRM_DE_TestClassUtilityHelper.regionalUser;
            insert objRegionalTarget;

            String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
            String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
            String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
            String SALES_AGENCY_TARGET = 'EUR_DE_Sales_Agency_Managed_Target'; //
            Map<String, Id> rtMap = new Map<String, Id>();
            for (RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET, :SR_VOL_TARGET, :OBJ_VOL_TARGET, :SALES_AGENCY_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']) {
                rtMap.put(rt.developername, rt.id);
            }
            List<User> regionalManagers = new List<User>();
            regionalManagers.add(EUR_CRM_DE_TestClassUtilityHelper.regionalUser);
            //List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(objPromo.EUR_CRM_Customer_Taxonomy__c);
            List<EUR_CRM_ObjPromo_Target__c > regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            regionalTargets.add(objTarget);
            //regionalTargets.add(objRegionalTarget);
            Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
            String targetField = 'EUR_CRM_SKU';
            Id rManager = null;//regionalManager;
            List<String> additionalFields = new List<String>{
                    'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ',
                    'EUR_CRM_SKU__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Article_no__c',
                    'EUR_CRM_SKU__r.name',
                    'EUR_CRM_Promotion_Type__c ',
                    'EUR_CRM_Unit_of_Measure__c ',
                    'EUR_CRM_Grouping_Type__c, EUR_CRM_Target_Quantity_Promo_Kits__c ',
                    'EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c',
                    'EUR_CRM_BQS__c',
                    'EUR_CRM_Target_Quantity_Spyders__c',
                    'EUR_CRM_Qty_Sell_in_Amount_Display__c',
                    'EUR_CRM_Visit_Targets__c',
                    'EUR_CRM_Target_Quantity_Listing__c',
                    'EUR_CRM_Target_Quantity_People__c'
            };

            Test.startTest();
            EUR_CRM_OPTargetHelperClass.retrieveAccountsByOPAccountMapping(objPromo.Id);
            EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id, regionalTargets, parentRecordTypeId, subTargetRecordTypeId, targetField, regionalManagers
                    , rManager, additionalFields);


            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(customerTaxonomyId, regionalManager);
            Set<Id> customerTaxonomyIdSet = new Set<Id>();
            customerTaxonomyIdSet.add(customerTaxonomyId);
            try {
                EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(new List<EUR_CRM_Account__c>{
                        euAccount
                }, regionalManager);
            } catch (Exception e) {

            }
            try {
                EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerManagerLevel(new List<EUR_CRM_Account__c>{
                        euAccount
                });
            } catch (Exception e) {

            }
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(customerTaxonomyIdSet, regionalManager);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(customerTaxonomyId);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(customerTaxonomyIdSet);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(accounts);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(customerTaxonomyId);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(customerTaxonomyIdSet);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerLevel(accounts);
            EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.Id);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(accountOwnerIds);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(accounts);

            List<EUR_CRM_OPTargetHelperClass.TargetWrap> targetWraps = EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id, regionalTargets, parentRecordTypeId, subTargetRecordTypeId, targetField, regionalManagers
                    , rManager, additionalFields);
            EUR_CRM_OPTargetHelperClass.retrieveTargetsSKUnBQS(objPromo.Id, regionalTargets, parentRecordTypeId, subTargetRecordTypeId, regionalManagers, null, additionalFields);
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            EUR_CRM_OPTargetHelperClass.retrieveTargetSpyder(objPromo.Id, regionalTargets, parentRecordTypeId, subTargetRecordTypeId, regionalManagers, null, additionalFields);

            for (EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap : targetWraps) {
                targetWrap.getVolumeBottleAchieved();
                targetWrap.getVolumeDisplayAchieved();
                targetWrap.getSubTargetBottleTotal();
                targetWrap.getSubTargetDisplayTotal();
                targetWrap.getSubTargetQuantityTotal();
                targetWrap.getVolumeBottleMatched();
                targetWrap.getVolumeDisplayMatched();
                targetWrap.getQuantityMatched();
                targetWrap.getQuantityAchieved();
                targetWrap.getisBottle();
                targetWrap.getISBQS();
                targetWrap.getIsCarton();
                targetWrap.getIsDisplay();
                targetWrap.getIsSKU();
                targetWrap.getQtyPromoKitMatched();
                targetWrap.getQtyPromoKitMatchedExactly();
                targetWrap.getVolumeSpyderMatched();
                targetWrap.getVolumeSpyderMatchedExactly();
                targetWrap.getVolumeBottleMatchedexactly();
                targetWrap.getVolumeDisplayMatchedExactly();
                targetWrap.getTargetListingMatched();
                targetWrap.getTargetVisitMatched();
                targetWrap.getTargetPeopleMatched();
                targetWrap.getEverythingMatched();
                targetWrap.getVolumeBottleNotOverlimit();
                targetWrap.getVolumeDisplayNotOverlimit();
                targetWrap.getSubTargetListingTotal();
                targetWrap.getSubTargetVisitTotal();
                targetWrap.getSubTargetPeopleTotal();
                targetWrap.getSubTargetSpyderTotal();
                targetWrap.getSubTargetPromoKitTotal();

            }
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            regionalTargets.add(objTarget);
            EUR_CRM_OPTargetHelperClass.deleteTargets(regionalTargets);
            Test.stopTest();
        }
    }
    static void createUser() {
        EUR_CRM_DE_TestClassUtilityHelper.regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.REGIONAL_ON_TRADE_MANAGER_ROLE, 'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');
        EUR_CRM_DE_TestClassUtilityHelper.salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE, 'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }

}