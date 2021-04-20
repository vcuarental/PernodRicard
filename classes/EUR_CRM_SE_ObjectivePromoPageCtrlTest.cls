@IsTest(IsParallel = true)
private class EUR_CRM_SE_ObjectivePromoPageCtrlTest {

    @IsTest
    static void test() {
        EUR_CRM_OP_Action_List_Template__c actionListTemp = makeTemplate();
        insert actionListTemp;

        EUR_CRM_ObjPromo__c objAndProm = makeObjPromo();
        insert objAndProm;

        EUR_CRM_ObjPromo_Target__c testTargetParent = makeObjPromoParentTarget(objAndProm);
        insert testTargetParent;

        EUR_CRM_ObjPromo_Target__c testTarget = makeObjPromoTarget(objAndProm, testTargetParent);
        insert testTarget;

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objAndProm);
        EUR_CRM_SE_ObjectivePromoPageController controller = new EUR_CRM_SE_ObjectivePromoPageController(stdCtrl);

        List<EUR_CRM_ObjPromo_Action__c> actions = controller.getActions();
        String opStatus = controller.getOPStatus();
        Boolean testBool = controller.getIsProductSectionRendered();
        testBool = controller.getIsVolumnTargetRendered();
        testBool = controller.getIsTargetsRendered();
        testBool = controller.getIsSize();
        testBool = controller.getIsSKU();
        testBool = controller.getIsQuality();
        PageReference pageRef = controller.publishOP();
        System.assertNotEquals(null, pageRef);
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */

    private static EUR_CRM_OP_Action_List_Template__c makeTemplate() {
        return new EUR_CRM_OP_Action_List_Template__c(
            name = 'Promo Action List Template 1'
        ,   EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation'
        );
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(){
        return new EUR_CRM_ObjPromo__c(
            Name = 'test ObjPromo'
        ,   RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_On_Trade_Promo_Kit_Activation')
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1)
        ,   EUR_CRM_Active_End_Date__c = Date.Today().addDays(360)
        ,   EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20)
        ,   EUR_CRM_Status__c = 'Active'
        );
    }

    private static EUR_CRM_ObjPromo_Target__c makeObjPromoParentTarget(EUR_CRM_ObjPromo__c objPromo) {
        return new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_Objective_Volume_Target').Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        );
    }

    private static EUR_CRM_ObjPromo_Target__c makeObjPromoTarget(EUR_CRM_ObjPromo__c objPromo, EUR_CRM_ObjPromo_Target__c parentTarget) {
        return new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_SR_Volume_Target').Id
        ,   EUR_CRM_ObjPromo__c = objPromo.Id
        ,   EUR_CRM_O_P_Target__c = parentTarget.Id
        ,   EUR_CRM_Target_Owner__c = UserInfo.getUserId()
        );
    }

}