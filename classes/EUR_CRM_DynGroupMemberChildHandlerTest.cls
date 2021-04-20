@IsTest (IsParallel = true)
private class EUR_CRM_DynGroupMemberChildHandlerTest {

    @IsTest
    private static void firstTest() {
        Test.startTest();
        new EUR_CRM_DynGroupMemberChildHandler().onAfterInsert(null);
        new EUR_CRM_DynGroupMemberChildHandler().onAfterUpdate(null, null);
        new EUR_CRM_DynGroupMemberChildHandler().onAfterUpdate(null, null);
        new EUR_CRM_DynGroupMemberChildHandler().onAfterDelete(null);
        new EUR_CRM_DynGroupMemberChildHandler().onAfterUndelete(null);
        Test.stopTest();
    }

}