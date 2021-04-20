/*********************************************************************************
 * Name:ASI_BRD_Generic_LeadConversion_Test
 * Description: Test Class for ASI_BRD_Generic_LeadConversion
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/26/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_LeadConversion_Test{
    static testMethod void ASI_BRD_Generic_LeadConversion_Test(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        Lead l = ASI_BRD_Generic_TestClassHelper.createLead();
        l.ASI_BRD_Sys_Lead_Auto_Convert__c = true;
        Test.startTest();
        try{
            update l;
        }catch(Exception e){
        
        }
        Test.stopTest();
    }
}