/*********************************************************************************
 * Name: ASI_CRM_VN_POSM_ReqHeaderCtrlTestV2
 * Description: Test class for ASI_CRM_VN_POSM_ReqHeaderController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/08/2017       Hugo Cheung             Created       
 * 3/12/2019        Calvin Chiu             Updated contract expenditure item value
 * 01/01/2019       Andy Zhang              Remove test FOC
*/
@isTest
public class ASI_CRM_VN_POSM_ReqHeaderCtrlTestV2 {
    
    @TestSetup
    public static void setupData() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        
        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;
        
        ASI_GiftBox_Inventory_Master__c inventoryItem = ASI_CRM_VN_TestClassHelper.createInventoryItem();
        insert inventoryItem;
        
        ASI_GiftBox_Inventory_Detail__c inventoryItemDetail = ASI_CRM_VN_TestClassHelper.createInventoryItemDetail(inventoryItem.Id);
        insert inventoryItemDetail;
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.OwnerId = u.Id;
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;
       
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        insert actualOfftake;
        
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure1 = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure1.ASI_CRM_VN_Item__c   = 'Glassware (Including Ice Buckets)';
        //contractExpenditure1.ASI_CRM_VN_Item__c   = 'Lump Sum';
        contractExpenditure1.ASI_CRM_VN_Amount__c = 5000000;
        contractExpenditureList.add(contractExpenditure1);

        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure2 = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        //contractExpenditure2.ASI_CRM_VN_Item__c   = 'FOC Bottles';
        contractExpenditure2.ASI_CRM_VN_Item__c   = 'Lump Sum';
        contractExpenditure2.ASI_CRM_VN_Amount__c = 5000000;
        contractExpenditure2.ASI_CRM_VN_Quantity__c = 1;
        contractExpenditureList.add(contractExpenditure2);

        insert contractExpenditureList;

        Approval.ProcessSubmitRequest contractReq = new Approval.ProcessSubmitRequest();
        contractReq.setComments('Approve.');
        contractReq.setNextApproverIds(new Id[] {u.Id});
        contractReq.setObjectId(contract.Id);
        Approval.process(contractReq);

        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        update contract;
    }
    
    public static testMethod void testPOSMCtrl() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];
        
        ASI_GiftBox_Request_Header__c posmRequest = ASI_CRM_VN_TestClassHelper.createPOSMRequest(contract.Id);
        Test.startTest();
        insert posmRequest;
        List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPOSMRequestItem(posmRequest.Id, inventoryItem.Id);
            requestItemList.add(requestItem);
        }
        insert requestItemList;
        Test.stopTest();

            PageReference pageRef = Page.ASI_CRM_VN_POSM_MassUpsertReqDetail;
            pageRef.getParameters().put('id', posmRequest.Id);
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(posmRequest);
            ASI_CRM_VN_POSM_ReqHeaderController posmReqCtrl = new ASI_CRM_VN_POSM_ReqHeaderController(sc);
        
            pageRef.getParameters().put('itemName', 'Testing');
            posmReqCtrl.runSearch();
            posmReqCtrl.checkInventory();
            posmReqCtrl.getGiftBoxList();

    }

    /*FOC will not be used any more*/
    //Andy Zhang
    /*
    public static testMethod void testFOCCtrl() {
        ASI_CRM_VN_Contract__c contract               = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];
        
        ASI_GiftBox_Request_Header__c focRequest = ASI_CRM_VN_TestClassHelper.createFOCRequest(contract.Id);
        insert focRequest;
        
        List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createFOCRequestItem(focRequest.Id, inventoryItem.Id);
            requestItemList.add(requestItem);
        }
        Test.startTest();
        insert requestItemList;
        Test.stopTest();

            PageReference pageRef = Page.ASI_CRM_VN_POSM_MassUpsertReqDetail;
            pageRef.getParameters().put('id', focRequest.Id);
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(focRequest);
            ASI_CRM_VN_POSM_ReqHeaderController posmReqCtrl = new ASI_CRM_VN_POSM_ReqHeaderController(sc);

    }*/

    public static testMethod void testReadOnlyCtrl() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];

        ASI_GiftBox_Request_Header__c posmRequest = ASI_CRM_VN_TestClassHelper.createPOSMRequest(contract.Id);
        posmRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_POSM_VN_Request_Read_Only');
        Test.startTest();
        insert posmRequest;
        List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPOSMRequestItem(posmRequest.Id, inventoryItem.Id);
            requestItemList.add(requestItem);
        }
        insert requestItemList;
        Test.stopTest();

            PageReference pageRef = Page.ASI_CRM_VN_POSM_MassUpsertReqDetail;
            pageRef.getParameters().put('id', posmRequest.Id);
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(posmRequest);
            ASI_CRM_VN_POSM_ReqHeaderController posmReqCtrl = new ASI_CRM_VN_POSM_ReqHeaderController(sc);

    }
}