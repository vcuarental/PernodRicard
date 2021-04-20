/*********************************************************************************
 * Name:ASI_CRM_SG_RevisedContract_ApproveTest
 * Description: Test class for ASI_CRM_SG_RevisedContract_Approve
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-24       Laputa: Vincent Lam     Created
*********************************************************************************/
@isTest
public class ASI_CRM_SG_RevisedContract_ApproveTest {

  private static final String OFFTAKE_RECORD_TYPE = 'ASI_CRM_SG_Actual_offtake';
  
    private static final String DRAFT_STATUS    = 'Draft';
    private static final String APPROVED_STATUS = 'Contract Approved';
    private static final String REJECTED_STATUS = 'Contract Rejected';
    public static final String SUBMITTED_STATUS = 'Submitted';

  @TestSetup
  public static void setupTestData() {
    ASI_CRM_SG_TestClassHelper.createDataSettings();
    List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
    List<ASI_MFM_SKU_Code__c> skuList       = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);

    ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true, 'Testing');
    ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer, 'isApproved');
    insert contractData.contract;

    ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contractData.contract);

    List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
    List<ASI_TH_CRM_Actual_Offtake__c> offtakeList     = new List<ASI_TH_CRM_Actual_Offtake__c>();
    for(ASI_MFM_SKU_Code__c sku : skuList) {
      ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractData.contract, sku);
      ASI_CRM_SG_TestClassHelper.offtakeData offtakeData               = new ASI_CRM_SG_TestClassHelper.offtakeData(false, OFFTAKE_RECORD_TYPE, contractData.contract.Id, customerData.customer.Id, sku.Id);
      contractTargetList.add(contractTargetData.contractTarget);
      offtakeList.add(offtakeData.offtake);
    }
    insert contractTargetList;
    insert offtakeList;
  }

  public static testMethod void testApprovedRevisedContract() {
    ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = :APPROVED_STATUS LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
        pageRef.getParameters().put('id',contract.id);
        pageRef.getParameters().put('copy', '2');
        System.Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController = new ApexPages.StandardController(contract);
        ASI_CRM_SG_ContractCloneController controller = new ASI_CRM_SG_ContractCloneController(stdController);
        controller.cloneContracts();

    contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = :DRAFT_STATUS LIMIT 1];
      
      Test.startTest(); // Start Test
    contract.ASI_TH_CRM_Contract_Status__c = SUBMITTED_STATUS;
    update contract;
    contract.ASI_TH_CRM_Contract_Status__c = APPROVED_STATUS;
    update contract;
      Test.stopTest(); // End Test
  }


}