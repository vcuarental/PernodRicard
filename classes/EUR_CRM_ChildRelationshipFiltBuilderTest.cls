@IsTest (IsParallel = true)
private class EUR_CRM_ChildRelationshipFiltBuilderTest {

    @IsTest
    static void getChildRelationshipsWithNullParamTest() {
        System.assertEquals('[]', EUR_CRM_ChildRelationshipFiltBuilderCtrl.getChildRelationships(null));
    }

    @IsTest
    static void getChildRelationshipsWithNullOrEmptyParamTest() {
        System.assertEquals('[]', EUR_CRM_ChildRelationshipFiltBuilderCtrl.getChildRelationships(''));
    }

    @IsTest
    static void getChildRelationshipsTest() {
        System.assertNotEquals('[]', EUR_CRM_ChildRelationshipFiltBuilderCtrl.getChildRelationships('EUR_CRM_Account__c'));
    }

//    @isTest
//    static void getChildRelationshipsSuccessTest() {
//        List<Custom_List_View_Setting__mdt> cmdt = [
//            SELECT
//                MasterLabel,
//                Child_Relationship__c,
//                Related_List_Label__c,
//                Parent_Object__c
//            FROM Custom_List_View_Setting__mdt
//            LIMIT 1];
//
//        if (!cmdt.isEmpty()) {
//            EUR_CRM_ChildRelationshipFiltBuilderCtrl.getChildRelationships(cmdt[0].Parent_Object__c);
//        }
//    }

}