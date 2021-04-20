@isTest
public class EUR_CRM_PT_ContractVolTrackExtTest {
    
    @testSetUp static void setUpData(){
        
        EUR_CRM_Account__c testAccount = EUR_CRM_PT_TestClassHelper.createEUAccount('Test PT Account');
        insert testAccount;
        
        Contact testContact = EUR_CRM_PT_TestClassHelper.createContact(1,'testContact',testAccount)[0];
        Insert testContact;
        
        EUR_CRM_Contract__c testContract = EUR_CRM_PT_TestClassHelper.createTRContract(1,'Contract',testAccount,testContact,'EUR_PT_Outlet_Contract')[0];
        insert testContract;
        
        List<EUR_CRM_Mechanic_Type__c> mechTypeTestList = EUR_CRM_PT_TestClassHelper.createMechType('EUR_PT_Volume_Targets_and_Rebates_Mechanic_Type');
        Insert mechTypeTestList;
        
        List<EUR_CRM_Contract_Activity_Item__c> testContractActivityItemList = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Mechanic_Type__c mech :mechTypeTestList ){
            EUR_CRM_Contract_Activity_Item__c testContractActivityItem = EUR_CRM_PT_TestClassHelper.createContractActivityItem(1, testContract, mech)[0];
            testContractActivityItemList.add(testContractActivityItem);           
        }        
        insert testContractActivityItemList;
        
        EUR_CRM_Size__c testbrandSize = EUR_CRM_PT_TestClassHelper.createSize('testSize', 'EUR_PT_Size');
        Insert testbrandSize; 
        
        EUR_CRM_GB_Volume_Tracker__c volumeTracker = EUR_CRM_PT_TestClassHelper.createVolumeTracker(1,'EUR_PT_Contract_Volume_Tracker', testContract.Id)[0];
        insert volumeTracker;
        
        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> testVolumeTrackerItemList = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c activityItem:testContractActivityItemList){
            EUR_CRM_GB_Volume_Tracker_Line_Item__c testVolumeTrackerItem = EUR_CRM_PT_TestClassHelper.createVolumeTracker('EUR_PT_Contract_Volume_Tracker_Line_Item',testbrandSize, activityItem, volumeTracker);
            testVolumeTrackerItemList.add(testVolumeTrackerItem);
        }
        Insert testVolumeTrackerItemList;        
    }
    
    static testMethod void testContractVolTrackExt(){
        
       EUR_CRM_Contract__c testContract = [select Id from EUR_CRM_Contract__c where recordType.developerName = 'EUR_PT_Outlet_Contract' limit 1];
        Test.setCurrentPage(Page.EUR_CRM_PT_VolumeTrackerExtended);
        ApexPages.StandardController sc = new ApexPages.StandardController(testContract);
        EUR_CRM_PT_ContractVolTrackExtendedExt controller = new EUR_CRM_PT_ContractVolTrackExtendedExt(sc);
        String test1 = controller.mechanicTypesNameString;
        String test2 = controller.mechanicTypesNameIdString;
        
    }    
}