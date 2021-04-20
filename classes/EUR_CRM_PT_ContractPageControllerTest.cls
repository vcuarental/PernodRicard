@isTest
private class EUR_CRM_PT_ContractPageControllerTest {
    //
    static testMethod void test1(){
        Id PTOnMechanicTypeRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Mechanic_Type__c' ,'EUR_PT_Lump_Sum_Mechanic_Type');
        EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c(name='Lump Sum',recordtypeId=PTOnMechanicTypeRecordTypeId);
        insert mechType;
        Id ptOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c' ,'EUR_PT_On_Trade');
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = ptOnAccountRecordTypeId,
                name = 'test', eur_crm_business_type__c = 'Outlet');
        insert account;
        Id PTOnContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c' ,'EUR_PT_Outlet_Contract');
        EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
             recordtypeid = PTOnContractRecordTypeId,
             EUR_CRM_Account__c = account.id,   
             EUR_CRM_Start_Date__c = System.today(),
             EUR_CRM_End_Date__c = System.today(),
             EUR_CRM_Status__c = 'Draft', 
             EUR_CRM_Is_this_contract_material__c = 60000,
             EUR_CRM_Is_this_contract_profitable__c = 60
        );
        insert contract;
         //mechanic type
        Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap;
        Id PTMechanicTypeRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Mechanic_Type__c' ,'EUR_PT_Lump_Sum_Mechanic_Type');
        mechanicTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();

        List<String> mechTypeNames = new List<String>{'EUR PT Lump Sum Mechanic Type'};
        
        for(String mechTypeName : mechTypeNames){
            EUR_CRM_Mechanic_Type__c mechTypex = new EUR_CRM_Mechanic_Type__c(
                recordtypeid = PTMechanicTypeRecordTypeId,
                Name = mechTypeName,
                EUR_CRM_Mechanic_Type_Name_English__c = mechTypeName
            ); 
            mechanicTypeMap.put(mechTypeName, mechTypex);
        }
        insert mechanicTypeMap.values();
        EUR_CRM_Contract_Activity_Item__c activityItem = new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Mechanic_Type__c=mechanicTypeMap.values()[0].Id,EUR_CRM_Contract__c=contract.Id);
        Insert activityItem;
        
        EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c(EUR_CRM_Contract_Activity_Item__c=activityItem.Id);
        insert productItem;
        
        PageReference aPage = Page.EUR_CRM_FI_ContractBuilderPage;
        test.setCurrentPage(aPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
            
        EUR_CRM_PT_ContractPageController ptContractPageController = new EUR_CRM_PT_ContractPageController(sc); 
        String m1 = ptContractPageController.mechanicTypesIdsString;
        String m2 = ptContractPageController.mechanicTypesNameString;
        String m3 = ptContractPageController.mechanicTypesNameIdString;
        Map<id, List<EUR_CRM_Contract_Product_Item__c>> map1= ptContractPageController.contractProductItemMap; 
        Set<String> set1 = ptContractPageController.getMechanicTypes();
        
    }   
    
    
    
}