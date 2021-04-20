/*********************************************************************************
 * Name:ASI_BRD_Generic_AccDowngrade_Test
 * Description: Test Class for ASI_BRD_Generic_AccDowngradeController
 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 06/13/2016       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccDowngrade_Test{

    static testMethod void ASI_BRD_Generic_AccDowngrade_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        
        System.runAs(u){
        Account acc = ASI_BRD_Generic_TestClassHelper.newAcc();
        acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc = 'ASI_BRD_Generic_CRM_Account';
        acc.ASI_BRD_Change_Account_Owner_To__pc = 'test(test1_brd_generic@laputa.com)';
        acc.ASI_BRD_Converted_Lead_Record_Type__pc = null;
        acc.ASI_BRD_Brands_Engaged__pc = 'Absolut,Ballantine,Beefeater,Chivas,Mumm,Havana Club,Jameson,Kahlua,Malibu,Martell,Perrier-Jouet,Ricard,Royal Salute,The Glenlivet';
        acc.ASI_LUX_Remarks__c = 'test';
        acc.ASI_LUX_EDM_Opt_in_Email__pc = 'Yes';
        insert acc;
        
        Test.startTest();
        PageReference pageRef = Page.ASI_BRD_Generic_AccDowngradePage;
        pageRef.getParameters().put('Id', acc.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ASI_BRD_Generic_AccDowngradeController controller = new ASI_BRD_Generic_AccDowngradeController(sc);
        controller.cancelDowngrade();
        controller.confirmDowngrade();
        Test.stopTest();
        }
    }
}