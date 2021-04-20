/*********************************************************************************
 * Name:ASI_BRD_Generic_CalcAttendedEvents_Test
 * Description: Test Class for ASI_BRD_Generic_CalcAttendedEvents
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/26/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_CalcAttendedEvents_Test{
    static testMethod void ASI_BRD_Generic_CalcAttendedEvents_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        Account acc = ASI_BRD_Generic_TestClassHelper.createAcc();
        
        Contact con = [Select Id From Contact Where accountId = :acc.Id];
        
        Test.startTest();
        CampaignMember cm = ASI_BRD_Generic_TestClassHelper.newCampaignMember(con.Id);
        cm.Status = 'Attended';
        insert cm;
        
        cm.Status = 'not Attended';
        update cm;
        Test.stopTest();
    }
}