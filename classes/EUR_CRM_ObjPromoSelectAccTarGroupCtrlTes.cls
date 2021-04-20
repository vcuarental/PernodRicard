@IsTest (IsParallel = true)
private class EUR_CRM_ObjPromoSelectAccTarGroupCtrlTes {

    @IsTest
    private static void getModelTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(Name = 'Name',   EUR_CRM_Postal_Code__c = '1122'
                ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade'));
        insert acc;

        EUR_CRM_Account_Target_Group__c atg = new EUR_CRM_Account_Target_Group__c(Name = 'New ATG');
        insert atg;
        EUR_CRM_Account_in_Target_Group__c aitg = new EUR_CRM_Account_in_Target_Group__c(
            EUR_CRM_Account_Target_Group__c = atg.Id
        ,   EUR_CRM_Account__c = acc.Id
        );
        insert aitg;

        EUR_CRM_Objectives_Promotions__c op = new EUR_CRM_Objectives_Promotions__c(EUR_CRM_Account_Target_Group__c = atg.Id);
        insert op;

        Test.startTest();
        EUR_CRM_ObjPromoSelectAccTarGroupCtrl.getModel(op.Id);
        Test.stopTest();
    }

    @IsTest
    private static void getModelEmptyTest() {
        EUR_CRM_Objectives_Promotions__c op = new EUR_CRM_Objectives_Promotions__c();
        insert op;

        Test.startTest();
        EUR_CRM_ObjPromoSelectAccTarGroupCtrl.getModel(op.Id);
        Test.stopTest();
    }

    @IsTest
    private static void getAccountsByIdsTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(Name = 'Name',   EUR_CRM_Postal_Code__c = '1122'
                ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade'));
        insert acc;

        Test.startTest();
        EUR_CRM_ObjPromoSelectAccTarGroupCtrl.getAccountsByIds(new List<String> { acc.Id });
        Test.stopTest();
    }

    @IsTest
    private static void getAccountsByIdsNullTest() {
        Test.startTest();
        try {
            EUR_CRM_ObjPromoSelectAccTarGroupCtrl.getAccountsByIds(null);
        } catch (AuraHandledException e) {
            System.debug('\n\n e.getMessage() => ' + JSON.serializePretty(e.getMessage()) + '\n');
        }
        Test.stopTest();
    }

}