/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountTerritory_Test
 * Description: Test Class for ASI_BRD_Generic_AccountTerritory
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccountTerritory_Test{
    static testMethod void ASI_BRD_Generic_AccountTerritory_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        Test.startTest();
        Account acc = ASI_BRD_Generic_TestClassHelper.newAcc();
        acc.ASI_BRD_Absolut_Engaged__pc = 'Yes';
        acc.ASI_BRD_Ballantines_Engaged__pc = 'Yes';
        acc.ASI_BRD_GHMumm_Engaged__pc = 'Yes';
        acc.ASI_BRD_Martell_Engaged__pc = 'Yes';
        acc.ASI_BRD_PerrierJouet_Engaged__pc = 'Yes';
        acc.ASI_BRD_RoyalSalute_Engaged__pc = 'Yes';
        acc.ASI_BRD_TheGlenlivet_Engaged__pc = 'Yes';
        acc.ASI_BRD_Name_of_OtherBrand1__pc = 'Test1';
        acc.ASI_BRD_Name_of_OtherBrand2__pc = 'Test2';
        acc.ASI_BRD_Name_of_OtherBrand3__pc = 'Test3';
        acc.ASI_BRD_OtherBrand1_Engaged__pc = 'Yes';
        acc.ASI_BRD_OtherBrand2_Engaged__pc = 'Yes';
        acc.ASI_BRD_OtherBrand3_Engaged__pc = 'Yes';
        insert acc;
        acc.ASI_BRD_Absolut_Engaged__pc = 'No';
        acc.ASI_BRD_Ballantines_Engaged__pc = 'No';
        acc.ASI_BRD_GHMumm_Engaged__pc = 'No';
        acc.ASI_BRD_Martell_Engaged__pc = 'No';
        acc.ASI_BRD_PerrierJouet_Engaged__pc = 'No';
        acc.ASI_BRD_RoyalSalute_Engaged__pc = 'No';
        acc.ASI_BRD_TheGlenlivet_Engaged__pc = 'No';
        acc.ASI_BRD_OtherBrand1_Engaged__pc = 'No';
        acc.ASI_BRD_OtherBrand2_Engaged__pc = 'No';
        acc.ASI_BRD_OtherBrand3_Engaged__pc = 'No';
        update acc;
        Test.stopTest();
    }
}