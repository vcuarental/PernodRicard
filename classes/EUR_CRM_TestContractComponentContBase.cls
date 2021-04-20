/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractComponentControllerBase Class.
  @Author:      IPC
  @History:     JUN.03.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_TestContractComponentContBase{
    static testMethod void testContractClass1(){
        test.startTest();
            EUR_CRM_ContractComponentControllerBase ctrl = new EUR_CRM_ContractComponentControllerBase();
            EUR_CRM_ContractBuilderControllerBase ctrlBase = new EUR_CRM_ContractBuilderControllerBase();
            
            ctrlBase.setComponentController(ctrl);
            ctrlBase.setComponentControllerMap('build', ctrl);
            ctrlBase.getComponentControllerMap();
            ctrlBase.getComponentController();
            ctrlBase.getThis();
        test.stopTest();
    }
}