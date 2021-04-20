/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_MassOwnerTransferTest
 * Description: Test class for ASI_CRM_VN_MassOwnerTransfer
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-24       Jeffrey Cheung          Created
 * 2019-01-05       Andy Zhang              Revise contract expenditure item
 * 2019-01-11		Calvin Chiu				Added User Company Code
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_MassOwnerTransferTest {
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        User user = ASI_CRM_VN_TestClassHelper.createUser(profileId);
		User.ASI_Company_Code__c = '780';
        insert user;


        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.OwnerId = user.Id;
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;

        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        insert actualOfftake;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.OwnerId = user.Id;
        contract.ASI_CRM_Area_Code__c = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;

        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c = 'Promotion';
        contractExpenditure.ASI_CRM_VN_Payment_Times__c = '3';
        contractExpenditure.ASI_CRM_VN_Achieved_Target_for_2nd_Pmt__c = 10;
        contractExpenditure.ASI_CRM_VN_Achieved_Target_for_3rd_Pmt__c = 40;
        insert contractExpenditure;
    }

    @IsTest static void selectOptionsTest778() {
        User user = [select id from User where ASI_Company_Code__c = '780' Limit 1];
        user.ASI_Company_Code__c = '778';
        update user;
        
        system.runAs(user){            
            ASI_CRM_VN_MassOwnerTransferController controller = new ASI_CRM_VN_MassOwnerTransferController();
            controller.getOutletTypes();
            controller.getOutletSubtypes();
            controller.getPROSImages();
            controller.getOutletOwners();
            controller.getAreas();
            controller.getProvinces();
            controller.getDistricts();
            controller.getNewOutletOwners();
        }
    }
    
    @IsTest static void selectOptionsTest780() {
        User user = [select id from User where ASI_Company_Code__c = '780' Limit 1];
        
        system.runAs(user){
            ASI_CRM_VN_MassOwnerTransferController controller = new ASI_CRM_VN_MassOwnerTransferController();
            controller.getOutletTypes();
            controller.getOutletSubtypes();
            controller.getPROSImages();
            controller.getOutletOwners();
            controller.getAreas();
            controller.getProvinces();
            controller.getDistricts();
            controller.getNewOutletOwners();
        }
    }


    @IsTest static void searchOutletTest() {
        ASI_CRM_VN_MassOwnerTransferController controller = new ASI_CRM_VN_MassOwnerTransferController();
        controller.searchOutlet();

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = [SELECT Id, ASI_CRM_VN_OutletType__c FROM ASI_CRM_AccountsAdditionalField__c];

        System.assertEquals(controller.filteredOutletsJSON, '[]');

        controller.selectedOutletType = onTradeCustomer.ASI_CRM_VN_OutletType__c;
        controller.searchOutlet();
        System.assertEquals(controller.filteredOutletsJSON, '[]');

        controller.selectedOutletType = 'random outlet type';
        controller.searchOutlet();
        System.assertEquals(controller.filteredOutletsJSON, '[]');

        controller.resetFilter();
        System.assertEquals(controller.selectedOutletType, '');


    }

    @IsTest static void changeOwnerTest() {
        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User oldUser = [SELECT Id FROM User WHERE Username = 'prvtesting@laputatech.com' LIMIT 1];
        List<ASI_CRM_AccountsAdditionalField__c> outletsByOldUser = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE OwnerId = :oldUser.Id];
        List<ASI_CRM_VN_Contract__c> contractsByOldUser = [SELECT Id FROM ASI_CRM_VN_Contract__c WHERE OwnerId = :oldUser.Id];

        //        create new user with contract permission
        User newUser = ASI_CRM_VN_TestClassHelper.createUser(profileId);
        newUser.Username = 'newuserandy@test.com';
        insert newUser;


        System.assertEquals(1, outletsByOldUser.size());
        System.assertEquals(1, contractsByOldUser.size());

        ASI_CRM_VN_MassOwnerTransferController.changeOwner(newUser.Id, JSON.serialize(outletsByOldUser));

        List<ASI_CRM_AccountsAdditionalField__c> outletsByNewUser = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE OwnerId = :newUser.Id];
        List<ASI_CRM_VN_Contract__c> contractsByNewUser = [SELECT Id FROM ASI_CRM_VN_Contract__c WHERE OwnerId = :newUser.Id];
        System.assertEquals(outletsByNewUser.size(), 1);
        System.assertEquals(contractsByNewUser.size(), 1);

    }
}