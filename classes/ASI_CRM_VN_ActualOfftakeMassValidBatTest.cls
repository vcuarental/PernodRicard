/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassValidBatTest
 * Description: Test class for ASI_CRM_VN_ActualOfftakeMassValidBat
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-06       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_ActualOfftakeMassValidBatTest {
    @IsTest static void badStringTest() {
        ASI_CRM_VN_ActualOfftakeMassUploadBatch controller = new ASI_CRM_VN_ActualOfftakeMassUploadBatch();
        System.assert(controller.badString(''));
        System.assert(controller.badString(','));
        System.assert(controller.badString(',,,,,,,'));
        System.assert(controller.badString('a,b,,d,e'));
        System.assertEquals(controller.badString('a,b,c,d,e'), false);
    }

    @IsTest static void batchTest(){

        User user = ASI_CRM_VN_TestClassHelper.createUserByProfileName('System Administrator');
        insert user;

        // last line is a bad string
        String csv = 'Sub Brand Code,Customer Code,Year,Month,Depletion Volume\n' +
                'BAFIN,VN000584,999,99,abc\n';


        ASI_CRM_VN_ActualOfftakeMassValidBatch controller = new ASI_CRM_VN_ActualOfftakeMassValidBatch(Blob.valueOf(csv), user.Id);

        Test.startTest();

        Database.executeBatch(controller);

        Test.stopTest();

        System.assertEquals(1, ASI_CRM_VN_ActualOfftakeMassValidBatch.testBadLines.size());
        System.assertEquals(5, ASI_CRM_VN_ActualOfftakeMassValidBatch.testBadLines[0].reasons.size());

    }
}