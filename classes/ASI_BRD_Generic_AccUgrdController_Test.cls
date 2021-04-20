/*********************************************************************************
 * Name:ASI_BRD_Generic_AccUpgradeController_Test
 * Description: Test Class for ASI_BRD_Generic_AccountUpgradeController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/26/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccUgrdController_Test{
    //Also for running number test 
    static testMethod void ASI_BRD_Generic_AccUpgradeController_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        ASI_BRD_Generic_TestClassHelper.createUser();
        
        Account acc = ASI_BRD_Generic_TestClassHelper.newAcc();
        acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc = 'ASI_BRD_Generic_CRM_Account';
        acc.ASI_BRD_Change_Account_Owner_To__pc = 'test(test1_brd_generic@laputa.com)';
        acc.ASI_BRD_Converted_Lead_Record_Type__pc = null;
        insert acc;
        
        Test.startTest();
        PageReference pageRef = Page.ASI_BRD_Generic_AccountUpgradePage;
        pageRef.getParameters().put('Id', acc.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ASI_BRD_Generic_AccountUpgradeController controller = new ASI_BRD_Generic_AccountUpgradeController(sc);
        controller.cancelUpgrade();
        controller.confirmUpgrade();
        Test.stopTest();
    }
}