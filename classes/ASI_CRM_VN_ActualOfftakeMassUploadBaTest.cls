/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassUploadBaTest
 * Description: Test class for ASI_CRM_VN_ActualOfftakeMassUploadBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-26       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_ActualOfftakeMassUploadBaTest {
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
                'BAFIN,VN000584,2017,7,1 \n' +
        'BAFIN,VN000584,2017,7,2 \n' +
        'BAFIN,VN000584,2017,7,3 \n' +
        'BAFIN,VN000584,2017,7,4, \n';


        ASI_CRM_VN_ActualOfftakeMassUploadBatch controller = new ASI_CRM_VN_ActualOfftakeMassUploadBatch(Blob.valueOf(csv), user.Id);

        Test.startTest();

        Database.executeBatch(controller);

        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM ASI_TH_CRM_Actual_Offtake__c WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Actual_Offtake_Temporary'].size());
    }

}