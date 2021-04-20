@isTest
public class ASI_CRM_SG_DeleteContract_Ctrl_Test {
    public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id, Name from ASI_TH_CRM_Contract__c limit 1];
        System.debug('@#debugcontract'+contract);
        test.startTest();
            ASI_CRM_SG_DeleteContract_Ctrl.validateDelete(contract.Id);
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_CRM_Contract__c =  contract.Id,ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC'));
        insert fr;
         ASI_CRM_SG_DeleteContract_Ctrl.validateDelete(contract.Id);
        ASI_CRM_SG_DeleteContract_Ctrl.deleteAction(contract.Id);
            ASI_CRM_SG_DeleteContract_Ctrl.deleteAction(null);
        test.stopTest();
    }
}