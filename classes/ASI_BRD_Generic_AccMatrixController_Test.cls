/*********************************************************************************
 * Name:ASI_BRD_Generic_AccMatrixController_Test
 * Description: Test Class for ASI_BRD_Generic_AccountMatrixController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccMatrixController_Test{
    static testMethod void ASI_BRD_Generic_AccountMatrixController_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        User testUser = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        
        Test.startTest();
        System.runAs(testUser){
            Account acc = ASI_BRD_Generic_TestClassHelper.createAcc();
            PageReference pageRef = Page.ASI_BRD_Generic_AccountMatrixPage;
            pageRef.getParameters().put('Id', acc.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            ASI_BRD_Generic_AccountMatrixController controller = new ASI_BRD_Generic_AccountMatrixController(sc);
            controller.save();
        }
        Test.stopTest();
    }
}