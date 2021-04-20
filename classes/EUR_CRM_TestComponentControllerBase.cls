/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ComponentControllerBase and EUR_CRM_PageControllerBaseClass.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_TestComponentControllerBase{
    static testMethod void testMethod1(){
        test.StartTest();
        
        EUR_CRM_ComponentControllerBase compCtrl = new EUR_CRM_ComponentControllerBase();
        system.assertNotEquals(compCtrl, null);
        EUR_CRM_PageControllerBase pageCtrl = new EUR_CRM_PageControllerBase();
        system.assertNotEquals(pageCtrl, null);
        
        pageCtrl.setComponentController(compCtrl);
        pageCtrl.setComponentControllerMap('TEST', compCtrl);
        pageCtrl.getComponentControllerMap();
        pageCtrl.getComponentController();
        pageCtrl.getThis();
        
        String ctrlKey = compCtrl.key;
        EUR_CRM_PageControllerBase pageController = compCtrl.pageController;
        compCtrl.key = 'TEST2';
        compCtrl.pageController = pageCtrl;
        
        test.StopTest();
    }
}