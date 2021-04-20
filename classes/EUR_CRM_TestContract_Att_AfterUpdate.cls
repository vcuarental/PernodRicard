@isTest
public class EUR_CRM_TestContract_Att_AfterUpdate{

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c contrac2;

    static testmethod void testCreateAndUpdateAttachment(){

        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){

            //Create account
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;

            test.StartTest();

            //Create Contract
            contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(180))[0];
            contract.EUR_CRM_Contract_Approved_Date__c = null;
            contract.EUR_CRM_Contract_Uploaded__c = false;
            insert contract;

            contrac2 = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(180))[0];
            contrac2.EUR_CRM_Contract_Approved_Date__c = null;
            contrac2.EUR_CRM_Contract_Uploaded__c = false;
            insert contrac2;

            Attachment attach=new Attachment(); 
            attach.Name='Unit Test Attachment'; 
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
            attach.body=bodyBlob; 
            attach.parentId=contract.id;
            insert attach;

            // Update Contract 
            attach.Name='Unit Test Attachment 2'; 
            update attach;

            Attachment attach2=new Attachment(); 
            attach2.Name='Unit Test Attachment'; 
            Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body'); 
            attach2.body=bodyBlob2; 
            attach2.parentId=contract.id;
            insert attach2;

            delete attach;
        }
        
            test.StopTest();
    }
}