@isTest (SeeAllData=true)
public class EUR_CRM_TestContractTableCompCnts {

    static testMethod void testControllers(){

        Map<String, EUR_CRM_Mechanic_Type__c> mechTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();
        for(EUR_CRM_Mechanic_Type__c mechType : [SELECT Id, Name FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'ZA']){
            mechTypeMap.put(mechType.Name, mechType);
        }

        EUR_CRM_Account__c acc = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'EUR_CRM_TestContractTableCompCntsAccountName', 'EUR_ZA_On_Trade_Direct')[0];
        insert acc;
        System.Debug('@@@@insert acc1:' + acc);
        Contact cont = EUR_CRM_ZA_TestClassHelper.createContact(1, 'EUR_CRM_TestContractTableCompCntsContactNames', acc)[0];
        
        insert cont;
        System.Debug('@@@@insert cont:'+cont);
        EUR_CRM_Contract__c contract = EUR_CRM_ZA_TestClassHelper.createZAContract(1, 'EUR_CRM_TestContractTableCompCntsContractName',acc, cont, '')[0];
        
        insert contract;  
        System.Debug('@@@@insert za contract:'+contract);
        List<EUR_CRM_Contract_Activity_Item__c> activities = new List<EUR_CRM_Contract_Activity_Item__c>();
        for(String mechTypeName : mechTypeMap.KeySet()){
            activities.add(EUR_CRM_ZA_TestClassHelper.createContractActivityItem(1, contract, mechTypeMap.get(mechTypeName))[0]);
        }
        
        insert activities;
		System.Debug('@@@@insert activites:'+activities);
        List<EUR_CRM_Contract_Product_Item__c> products = new List<EUR_CRM_Contract_Product_Item__c>();
        for(EUR_CRM_Contract_Activity_Item__c activity : activities){
            products.add(EUR_CRM_ZA_TestClassHelper.createProductItem(1, activity)[0]);
        }
        
        insert products;
		System.Debug('@@@@insert product:'+products);
        Test.startTest();

        contract.EUR_CRM_Status__c = 'Approved';
        System.Debug('@@@@update contract:' + contract);
        update contract;
        // Call the controllers
        String contractId = String.valueOf(contract.Id);
        EUR_CRM_ContractEventsTableCtrlr eventCnt = new EUR_CRM_ContractEventsTableCtrlr();
        eventCnt.contractId = contractId;
        eventCnt.getContractEvents();

        EUR_CRM_ContractPOSMaterialTableCtrlr posmCnt = new EUR_CRM_ContractPOSMaterialTableCtrlr(); 
        posmCnt.contractId = contractId;
        posmCnt.getContractPOSMaterials();

        EUR_CRM_ContractUniformsTableCtrlr uniformCnt = new EUR_CRM_ContractUniformsTableCtrlr();
        uniformCnt.contractId = contractId;
        uniformCnt.getContractUniforms();

        EUR_CRM_ContractTrainingsTableCtrlr trainingsCnt = new EUR_CRM_ContractTrainingsTableCtrlr();
        trainingsCnt.contractId = contractId;
        trainingsCnt.getContractTrainings();

        Test.stopTest();
    }

    static testMethod void testSalesORderCntrlr(){
        System.Debug('@@@@insert Account');
        EUR_CRM_Account__c acc = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'EUR_CRM_SalesOrderItemTableCtrlrAccountName', 'EUR_ZA_On_Trade_Direct')[0];
        insert acc;
        System.Debug('@@@@insert acc again:'+ acc);
		
        EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c(Name='testSalesORderCntrlrskuTest', EUR_CRM_SKU_Code__c='testSalesORderCntrlr123');
        insert sku;
		System.Debug('@@@@insert SKU:' + sku);
        EUR_CRM_Sales_Order__c so = new EUR_CRM_Sales_Order__c(
            Name='testSalesORderCntrlrSoTest',
            EUR_CRM_Account__c = acc.Id

        );        
        
        insert so;
        System.Debug('@@@@insert SO:'+ so);

        EUR_CRM_Sales_Order_Items__c soItem = new EUR_CRM_Sales_Order_Items__c(
            EUR_CRM_Sales_Order__c = so.Id,
            EUR_CRM_SKU__c = sku.Id,
            EUR_CRM_Quantity__c = 10.0,
            EUR_CRM_Unit__c = '1'
        );
        System.Debug('@@@@insert soItem:' + soItem);
        insert soItem;

        EUR_CRM_SalesOrderItemTableCtrlr cntrlr = new EUR_CRM_SalesOrderItemTableCtrlr();
        cntrlr.salesOrderId = so.Id;
        cntrlr.getSalesOrderItems();
        cntrlr.getSalesOrderItemsWithCustomerCode();
        Boolean displayOldStyle = cntrlr.displayOldStyle;
        String url = cntrlr.getApprovalLink();
        
        System.Debug('@@@@End');
        
        System.assertEquals('', url);
    }
}