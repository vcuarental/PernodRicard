/*********************************************************************************
 * Name: ASI_CRM_VN_TestClassHelper
 * Description: Class for creating the Testing Record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/07/2017       Hugo Cheung             Created 
 * 3/01/2019        Andy Zhang              Test class error fix         
*/
@isTest
public class ASI_CRM_VN_TestClassHelper {
    
    private static final List<String> MONTH_STR_LIST = new List<String> {
    	'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
    };

    public static void createCustomSettings(){
        ASI_CRM_VN_Settings__c settings = ASI_CRM_VN_Settings__c.getInstance();
        settings.ASI_CRM_VN_Visitation_Plan_Factor__c = 123;
        settings.ASI_CRM_VN_Min_Contract_AchieveTarget__c = 123;
        settings.ASI_CRM_VN_Expired_Contract_Valid_Month__c = 2;
        insert settings;
    }

    public static void createRunningNumber() {
    	ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
        runningNumber.ASI_HK_CRM_Object_Name__c = Label.ASI_CRM_VN_Customer_Code; 
        runningNumber.ASI_HK_CRM_Running_Number__c = 1;
        runningNumber.ASI_HK_CRM_Format__c = 'VN-{YYYY}';
        runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = Date.today().month() + 2;
        runningNumber.ASI_HK_CRM_Fiscal_Year__c = Date.today().year();
        insert runningNumber;
    }
    
    public static void createExchangeRate() {
    	List<ASI_MFM_Exchange_Rate__c> exchangeRateList = new List<ASI_MFM_Exchange_Rate__c>();
        
        ASI_MFM_Exchange_Rate__c exchangeRate1 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate1.ASI_MFM_Country__c = 'VN';
        exchangeRate1.ASI_MFM_Base_Currency__c = 'VND';
        exchangeRate1.ASI_MFM_Counter_Currency__c = 'USD';
        exchangeRate1.ASI_MFM_Exchange_Rate__c = 0.000044;
        exchangeRate1.ASI_MFM_Effective_Date__c = Date.today().addYears(-2);
        
        ASI_MFM_Exchange_Rate__c exchangeRate2 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate2.ASI_MFM_Country__c = 'VN';
        exchangeRate2.ASI_MFM_Base_Currency__c = 'USD';
        exchangeRate2.ASI_MFM_Counter_Currency__c = 'VND';
        exchangeRate2.ASI_MFM_Exchange_Rate__c = 22726.5;
        exchangeRate2.ASI_MFM_Effective_Date__c = Date.today().addYears(-2);
        
        exchangeRateList.add(exchangeRate1);
        exchangeRateList.add(exchangeRate2);
        
        insert exchangeRateList;
    }    
    
    public static User createUser(Id profileId) {
    	User u = new User();
        u.Alias = 'prvtest';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = profileId;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.UserName = 'prvtesting@laputatech.com';
        return u;
    }

    public static User createUserByProfileName(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        User u = new User();
        u.Alias = 'prvtest';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = profileId;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.UserName = 'prvtesting@laputatech.com';
        return u;
    }

    public static ASI_MFM_Sub_brand__c createSubBrand() {
    	ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c();
        subBrand.Name                             = 'Testing Sub-brand';
        subBrand.ASI_MFM_Sub_brand_Code__c        = 'TEST';
        subBrand.ASI_MFM_Sub_brand_Description__c = 'Testing Sub-brand';
        subBrand.ASI_CRM_SG_Competitor__c         = true;
        subBrand.ASI_CRM_BottleSize__c            = 2;
        subBrand.RecordTypeId                     = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__c' + 'ASI_CRM_VN_SubBrand');
        return subBrand;
    }
    
    public static ASI_MFM_SKU_Code__c createSKU(Id subBrandId) {
    	ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c();
        sku.Name                          = 'Testing SKU';
        sku.ASI_MFM_Sub_brand__c          = subBrandId;
        sku.ASI_MFM_SKU_Code__c           = 'T123';
        sku.ASI_HK_CRM_Std_Bottle_Size__c = 5;
        sku.ASI_HK_CRM_Active__c          = true;
        sku.RecordTypeId                  = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__c' + 'ASI_CRM_VN_SKU');
        return sku;
    }
    
    public static ASI_CRM_Customer_Sub_Brand__c createKeyCustomerSubBrand(Id customerId, Id subBrandId) {
   		ASI_CRM_Customer_Sub_Brand__c customerSubBrand = new ASI_CRM_Customer_Sub_Brand__c();
        customerSubBrand.ASI_CRM_Customer_Key_Brand__c = customerId;
        customerSubBrand.ASI_CRM_Sub_Brand__c          = subBrandId;
        customerSubBrand.RecordTypeId                  = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Sub_Brand__c' + 'ASI_CRM_PRA_Key_Brand');
        return customerSubBrand;
    }
    
	public static ASI_CRM_Customer_Sub_Brand__c createCompetitorCustomerSubBrand(Id customerId, Id subBrandId) {
   		ASI_CRM_Customer_Sub_Brand__c customerSubBrand = new ASI_CRM_Customer_Sub_Brand__c();
        customerSubBrand.ASI_CRM_Customer_Competitor_Brand__c = customerId;
        customerSubBrand.ASI_CRM_Sub_Brand__c                 = subBrandId;
        customerSubBrand.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_CRM_Customer_Sub_Brand__c' + 'ASI_CRM_Competitor_Key_Brand');
        return customerSubBrand;
    }
    
    public static ASI_CRM_ServicePack__c createServicePack() {
    	ASI_CRM_ServicePack__c servicePack = new ASI_CRM_ServicePack__c();
        servicePack.Name                                        = 'Testing Service Pack';
        servicePack.ASI_CRM_No_of_PG_in_one_outlet__c           = 3;
        servicePack.ASI_CRM_No_of_Signage_per_outlet__c         = 3;
        servicePack.ASI_CRM_No_of_VIP_room__c                   = 2;
        servicePack.ASI_CRM_No_of_Podium_stand__c               = 2;
        servicePack.ASI_CRM_No_of_Glorifier__c                  = 10;
        servicePack.ASI_CRM_No_of_Dummy_Bots__c                 = 0;
        servicePack.ASI_CRM_No_of_PG_uniform__c                 = 9;
        servicePack.ASI_CRM_No_of_Glassware__c                  = 200;
        servicePack.ASI_CRM_No_of_Dice_Dice_Cup__c              = 100;
        servicePack.ASI_CRM_No_of_Drink_menus__c                = 50;
        servicePack.ASI_CRM_No_of_Promotion_activiti_per_yr__c  = 3;
        servicePack.ASI_CRM_Incentives_US_year__c               = 0;
        servicePack.ASI_CRM_Display_Listing_Fees__c             = 1500;
        servicePack.ASI_CRM_Cash_Sponsorship_US_Year__c         = 0;
        servicePack.ASI_CRM_Average_Salary_of_1_PG_per_Year__c  = 3300;
        servicePack.ASI_CRM_Cost_p_Signage_p_Year_p_Outlet__c   = 500;
        servicePack.ASI_CRM_Cost_per_VIP_Room_Investment__c     = 5000;
        servicePack.ASI_CRM_Cost_per_Podium_Stand_per_Year__c   = 500;
        servicePack.ASI_CRM_Cost_per_Glorifier_per_Year__c      = 200;
        servicePack.ASI_CRM_Cost_per_Dummy_Bottle_per_Year__c   = 0;
        servicePack.ASI_CRM_Cost_per_PG_Uniform_Investment__c   = 100;
        servicePack.ASI_CRM_Cost_per_Glassware_per_Year__c      = 2;
        servicePack.ASI_CRM_Cost_per_Dice_Dice_Cup_per_Year__c  = 4;
        servicePack.ASI_CRM_Cost_per_Drink_menus_per_year__c    = 7;
        servicePack.ASI_CRM_Average_Cost_PromotionActivities__c = 2600;
        servicePack.RecordTypeId                                = Global_RecordTypeCache.getRtId('ASI_CRM_ServicePack__c' + 'ASI_CRM_VN_ServicePack');
        return servicePack;
    }
    
    public static ASI_GiftBox_Inventory_Master__c createInventoryItem() {
		ASI_GiftBox_Inventory_Master__c inventoryItem = new ASI_GiftBox_Inventory_Master__c();
        inventoryItem.Name                      = 'Testing';
        inventoryItem.ASI_CRM_Category__c       = 'Glassware';
        inventoryItem.ASI_GiftBox_Unit_Price__c = 100;
        return inventoryItem;
    }
    
    public static ASI_GiftBox_Inventory_Detail__c createInventoryItemDetail(Id inventoryItemId) {
        ASI_GiftBox_Inventory_Detail__c inventoryItemDetail = new ASI_GiftBox_Inventory_Detail__c();
        inventoryItemDetail.ASI_GiftBox_Item_Id__c                 = inventoryItemId;
        inventoryItemDetail.ASI_GiftBox_Item_Received_Quantity__c  = 1000;
        inventoryItemDetail.ASI_GiftBox_Item_Requested_Quantity__c = 50;
        inventoryItemDetail.ASI_GiftBox_Item_Warehouse__c          = 'Testing';
        return inventoryItemDetail;
    }
    
    public static ASI_CRM_AccountsAdditionalField__c createOnTradeCustomer() {
        ASI_CRM_AccountsAdditionalField__c offtradeCust = new ASI_CRM_AccountsAdditionalField__c();
        offtradeCust.Name                     = 'Testing';
        offtradeCust.ASI_CRM_VN_Region__c     = 'South';
        offtradeCust.ASI_CRM_Area__c          = 'HCMC';
        offtradeCust.ASI_CRM_VN_OutletType__c = 'Wholesaler';
        offtradeCust.ASI_CRM_Active__c        = true;
        offtradeCust.RecordTypeId             = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__c' + 'ASI_CRM_VN_Outlet');
        return offtradeCust;
    }
    
    public static ASI_CRM_AccountsAdditionalField__c createOffTradeCustomer() {
        ASI_CRM_AccountsAdditionalField__c offtradeCust = new ASI_CRM_AccountsAdditionalField__c();
        offtradeCust.Name                     = 'Testing';
        offtradeCust.ASI_CRM_VN_Region__c     = 'South';
        offtradeCust.ASI_CRM_Area__c          = 'HCMC';
        offtradeCust.ASI_CRM_VN_OutletType__c = 'Wholesaler';
        offtradeCust.ASI_CRM_Active__c        = true;
        offtradeCust.RecordTypeId             = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__c' + 'ASI_CRM_VN_Off_Trade_Outlet');
        return offtradeCust;
    }
    
    public static ASI_HK_CRM_Visitation_Plan__c createVisitationPlan() {
    	ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c();
        visitationPlan.Name                = 'Testing Visitation Plan';
        visitationPlan.ASI_HK_CRM_Year__c  = String.valueOf(Date.today().year());
        visitationPlan.ASI_HK_CRM_Month__c = MONTH_STR_LIST.get(Date.today().month() - 1);
        return visitationPlan;
    }
    
    public static ASI_HK_CRM_Visitation_Plan_Detail__c createVisitationPlanDetail(Id visitationPlanId, Id customerId) {
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        visitationPlanDetail.ASI_HK_CRM_Visitation_Plan__c = visitationPlanId;
        visitationPlanDetail.ASI_CRM_MY_Customer__c        = customerId;
        visitationPlanDetail.ASI_HK_CRM_Visit_Date__c      = Date.today();
        visitationPlanDetail.ASI_HK_CRM_Status__c          = 'Ad-hoc';
        visitationPlanDetail.ASI_CRM_Purpose_of_Visit__c   = 'Normal Visit';
        visitationPlanDetail.RecordTypeId                  = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__c' + 'ASI_CRM_VN_OffTrade_Visitation_Plan_Detail');
        return visitationPlanDetail;
    }
    
    public static ASI_TH_CRM_Actual_Offtake__c createActualOfftake(Id customerId, Id subBrandId) {
    	ASI_TH_CRM_Actual_Offtake__c actualOfftake = new ASI_TH_CRM_Actual_Offtake__c();
        actualOfftake.ASI_CRM_SG_Customer__c         = customerId;
        actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c = Date.today().addMonths(-6);
        actualOfftake.ASI_TH_CRM_Sub_brand__c        = subBrandId;
        actualOfftake.ASI_TH_CRM_Quantity__c         = 100;
        actualOfftake.RecordTypeId                   = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__c' + 'ASI_CRM_VN_Actual_Offtake');
        return actualOfftake;
    }
    
    public static ASI_CRM_VN_Contract__c createContract(Id customerId, Id keyBrandId) {
        ASI_CRM_VN_Contract__c contract = new ASI_CRM_VN_Contract__c();
        contract.ASI_CRM_Contract_Status__c       = 'Draft';
        contract.ASI_CRM_MCF_Type__c              = 'Local';
        contract.ASI_CRM_Outlet_WS__c             = customerId;
        contract.ASI_CRM_Type__c                  = 'New';
        contract.ASI_CRM_Start_Date__c            = Date.today().addYears(-1).toStartOfMonth();
        contract.ASI_CRM_End_Date__c              = Date.today().toStartOfMonth().addDays(-1);
        contract.ASI_CRM_Key_Brand__c             = keyBrandId;
        contract.ASI_CRM_Objective__c             = 'Testing';
        contract.ASI_CRM_Agreement_with_Outlet__c = 'Testing';
        contract.ASI_CRM_Currency__c              = 'VND';
        contract.RecordTypeId                     = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract__c' + 'ASI_CRM_VN_Contract');
        return contract;
    }
    
    public static ASI_CRM_VN_Contract_Expenditure__c createContractExpenditure(Id contractId) {
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = new ASI_CRM_VN_Contract_Expenditure__c();
        contractExpenditure.ASI_CRM_VN_Item__c     = 'Lump Sum';
        contractExpenditure.ASI_CRM_VN_Quantity__c = 1;
        contractExpenditure.ASI_CRM_VN_Amount__c   = 5000000;
        contractExpenditure.ASI_CRM_VN_Contract__c = contractId;
        contractExpenditure.ASI_CRM_Achieved_Target_for_1st_Pmt__c = 100;
        contractExpenditure.ASI_CRM_Amount_for_1st_Payment__c  = 5000000;
        contractExpenditure.RecordTypeId           = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract_Expenditure__c' + 'ASI_CRM_VN_Contract_Expenditure');
        return contractExpenditure;
    }
    
    public static ASI_CRM_VN_Contract_Expenditure__c createCapsuleContractExpenditure(Id contractId, Id subBrandId) {
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = new ASI_CRM_VN_Contract_Expenditure__c();
        contractExpenditure.ASI_CRM_Sub_Brand__c         = subBrandId;
        contractExpenditure.ASI_CRM_VN_Sales_Target__c   = 500;
        contractExpenditure.ASI_CRM_VN_Unit_Incentive__c = 20000;
        contractExpenditure.ASI_CRM_VN_Contract__c       = contractId;
        contractExpenditure.RecordTypeId                 = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract_Expenditure__c' + 'ASI_CRM_VN_Capsule_Agreement_Contract_Expenditure');
        return contractExpenditure;
    }
    
    public static ASI_CRM_VN_Bottle_Analysis__c createBottleAnalysis(Id contractId, Id skuId) {
    	ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = new ASI_CRM_VN_Bottle_Analysis__c();
        bottleAnalysis.ASI_CRM_VN_Contract__c      = contractId;
        bottleAnalysis.ASI_CRM_VN_SKU__c           = skuId;
        bottleAnalysis.ASI_CRM_Target_Per_Month__c = 50;
        bottleAnalysis.RecordTypeId                = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Bottle_Analysis__c' + 'ASI_CRM_VN_Bottle_Analysis');
        return bottleAnalysis;
    }

	public static ASI_GiftBox_Request_Header__c createPOSMRequest(Id contractId) {
        ASI_GiftBox_Request_Header__c requestHeader = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c          = contractId;
        requestHeader.ASI_CRM_Order_Date__c           = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c           = 'Open';
        requestHeader.ASI_CRM_Sys_Pending_Approval__c = true;
        requestHeader.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_POSM_VN_Request');
        return requestHeader;
    }
    
    public static ASI_GiftBox_Request_Item__c createPOSMRequestItem(Id requestId, Id inventoryItemId) {
        ASI_GiftBox_Request_Item__c posmRequestItem = new ASI_GiftBox_Request_Item__c();
        posmRequestItem.ASI_GiftBox_Request_Id__c       = requestId;
        posmRequestItem.ASI_GiftBox_Request_Item__c     = inventoryItemId;
        posmRequestItem.ASI_GiftBox_Request_Purpose__c  = 'Display';
        posmRequestItem.ASI_GiftBox_Request_Quantity__c = 100;
        posmRequestItem.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_POSM_Request_Item');
        return posmRequestItem;
    }
    
    public static ASI_GiftBox_Request_Header__c createFOCRequest(Id contractId) {
        ASI_GiftBox_Request_Header__c requestHeader = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c          = contractId;
        requestHeader.ASI_CRM_Order_Date__c           = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c           = 'Open';
        requestHeader.ASI_CRM_Sys_Pending_Approval__c = true;
        requestHeader.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_FOC_Request');
        return requestHeader;
    }
    
    public static ASI_GiftBox_Request_Item__c createFOCRequestItem(Id requestId, Id inventoryItemId) {
        ASI_GiftBox_Request_Item__c requestItem = new ASI_GiftBox_Request_Item__c();
        requestItem.ASI_GiftBox_Request_Id__c       = requestId;
        requestItem.ASI_GiftBox_Request_Item__c     = inventoryItemId;
        requestItem.ASI_GiftBox_Request_Purpose__c  = 'FOC';
        requestItem.ASI_GiftBox_Request_Quantity__c = 100;
        requestItem.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_FOC_Request_Item');
        return requestItem;
    }
    
    public static ASI_GiftBox_Request_Header__c createCSRequest(Id contractId) {
        ASI_GiftBox_Request_Header__c requestHeader = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c               = contractId;
        requestHeader.ASI_CRM_Order_Date__c                = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c                = 'Open';
        requestHeader.ASI_CRM_VN_Cash__c                   = true;
        requestHeader.ASI_CRM_VN_Cash_Payee_Name__c        = 'Testing';
        requestHeader.ASI_CRM_VN_Cash_Payee_ID_Passport__c = '5432112345';
        requestHeader.ASI_CRM_VN_Cash_Payee_Contact__c     = '5432112345';
        requestHeader.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_CS_Request');
        return requestHeader;
    }
    
    public static ASI_GiftBox_Request_Header__c createCapsuleCSRequest(Id contractId) {
    	ASI_GiftBox_Request_Header__c requestHeader        = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c               = contractId;
        requestHeader.ASI_CRM_Order_Date__c                = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c                = 'Open';
        requestHeader.ASI_CRM_VN_Cash__c                   = true;
        requestHeader.ASI_CRM_VN_Cash_Payee_Name__c        = 'Testing';
        requestHeader.ASI_CRM_VN_Cash_Payee_ID_Passport__c = '5432112345';
        requestHeader.ASI_CRM_VN_Cash_Payee_Contact__c     = '5432112345';
        requestHeader.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_Capsule_CS_Request');
        return requestHeader;
    }

    public static ASI_GiftBox_Request_Header__c createPromotionRequest(Id contractId) {
    	ASI_GiftBox_Request_Header__c requestHeader        = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c               = contractId;
        requestHeader.ASI_CRM_Order_Date__c                = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c                = 'Open';
        requestHeader.ASI_CRM_VN_Amount__c                 = 10;
        requestHeader.ASI_CRM_Sys_Pending_Approval__c = true;
        requestHeader.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_Promotion_Request');
        return requestHeader;
    }

    public static ASI_GiftBox_Request_Item__c createPromotionRequestItem(Id requestId) {
        ASI_GiftBox_Request_Item__c requestItem = new ASI_GiftBox_Request_Item__c();
        requestItem.ASI_GiftBox_Request_Id__c       = requestId;
        requestItem.ASI_GiftBox_Request_Quantity__c = 100;
        requestItem.ASI_CRM_Amount__c = 10;
        requestItem.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_Promotion_Request_Item');
        return requestItem;
    }

    public static ASI_GiftBox_Request_Header__c createDisplayListingRequest(Id contractId) {
    	ASI_GiftBox_Request_Header__c requestHeader        = new ASI_GiftBox_Request_Header__c();
        requestHeader.ASI_CRM_VN_Contract__c               = contractId;
        requestHeader.ASI_CRM_Order_Date__c                = Date.today().addMonths(-6);
        requestHeader.ASI_GiftBox_Status__c                = 'Open';
        requestHeader.ASI_CRM_VN_Amount__c                 = 1000;
        requestHeader.ASI_CRM_Sys_Pending_Approval__c = true;
        requestHeader.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_Display_Listing_Fee_Request');
        return requestHeader;
    }

    public static ASI_GiftBox_Request_Item__c createDisplayListingRequestItem(Id requestId) {
        ASI_GiftBox_Request_Item__c requestItem = new ASI_GiftBox_Request_Item__c();
        requestItem.ASI_GiftBox_Request_Id__c       = requestId;
        requestItem.ASI_GiftBox_Request_Quantity__c = 100;
        requestItem.ASI_CRM_Amount__c = 10;
        requestItem.RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__c' + 'ASI_CRM_VN_Display_Listing_Request_Item');
        return requestItem;
    }

    public static ASI_CRM_Trade_A_P_Plan__c createPromotionPlan() {
        ASI_CRM_Trade_A_P_Plan__c promotionPlan = new ASI_CRM_Trade_A_P_Plan__c();
        promotionPlan.ASI_CRM_Start_Date__c = Date.today();
        promotionPlan.ASI_CRM_End_Date__c = Date.today().addMonths(1);
        promotionPlan.ASI_CRM_Total_Outlet__c = 5;
        promotionPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Trade_A_P_Plan__c' + 'ASI_CRM_VN_Promotion_Plan');
        return promotionPlan;
    }

    public static ASI_CRM_Trade_A_P_Plan_Item__c createPromotionPlanItem(Id planId){
        ASI_CRM_Trade_A_P_Plan_Item__c planItem = new ASI_CRM_Trade_A_P_Plan_Item__c();
        planItem.ASI_CRM_Trade_A_P_Plan__c = planId;
        planItem.ASI_CRM_Quantity__c = 1000;
        planItem.ASI_CRM_Unit_Price__c = 1000;
        planItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Trade_A_P_Plan_Item__c' + 'ASI_CRM_VN_Promotion_Plan_Item');
        return planItem;

    }

}