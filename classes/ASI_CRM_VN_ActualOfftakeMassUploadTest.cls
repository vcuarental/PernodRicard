/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassUploadTest
 * Description: Test class for ASI_CRM_VN_ActualOfftakeMassUploadTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-29       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_ActualOfftakeMassUploadTest {
    @IsTest public static void uploadCSVTest() {
        String csv = 'Sub Brand Code,Customer Code,Year,Month,Depletion Volume\n' +
                'BAFIN,VN000584,999,99,abc\n';
        
        ASI_CRM_VN_ActualOfftakeMassUploadCtrl controller = new ASI_CRM_VN_ActualOfftakeMassUploadCtrl();
        controller.nameFile = 'Testing.csv';
        controller.contentFile = Blob.valueOf(csv);
        controller.uploadCSV();
    }

    @IsTest public static void genActualOfftakeTest() {
        ASI_CRM_VN_ActualOfftakeMassUploadCtrl controller = new ASI_CRM_VN_ActualOfftakeMassUploadCtrl();
        controller.genActualOfftake();
    }

    @IsTest public static void deleteTempOfftakeTest() {
        ASI_CRM_VN_ActualOfftakeMassUploadCtrl controller = new ASI_CRM_VN_ActualOfftakeMassUploadCtrl();
        controller.deleteTempOfftake();
    }
}