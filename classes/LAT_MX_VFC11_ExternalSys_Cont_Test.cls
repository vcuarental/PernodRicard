@isTest
public with sharing class LAT_MX_VFC11_ExternalSys_Cont_Test {
        static testMethod void LAT_MX_VFC11_ExternalSys_Cont_Test() {
            Test.startTest();
                LAT_MX_VFP11_ExternalSys_Controller controller = new LAT_MX_VFP11_ExternalSys_Controller();
                controller.getLista();
            Test.stopTest();
        }
}