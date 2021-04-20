@isTest
public class ASI_CRM_MO_ContractEmailCtrl_Test {
  public static testMethod void test_ASI_CRM_MO_ContractEmailCtrl() {
      ASI_CRM_MO_ContractEmailCtrl ctl = new ASI_CRM_MO_ContractEmailCtrl();
      list<ASI_CRM_Contract_Cost__c> lst = new list<ASI_CRM_Contract_Cost__c>();
      lst = ctl.getcontractCost();
  }

}