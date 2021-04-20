/*********************************************************************************
 * Name: ASI_CRM_JP_TestHelper
 * Description: Test class helper for PRJ Phase 3 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_TestHelper {
    //User Profile
    public final static Profile SYSTEM_ADMIN_PROFILE = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    
    //Object API Name
    public final static String CUSTOMER_OBJECT_API_NAME        = 'ASI_CRM_AccountsAdditionalField__c';
    public final static String SALES_ORDER_OBJECT_API_NAME     = 'ASI_CRM_JP_Sales_Order__c';
    public final static String POSTAL_CODE_OBJECT_API_NAME     = 'ASI_CRM_Postal_Code__c';
    public final static String PRICE_LIST_OBJECT_API_NAME      = 'ASI_CRM_Price_List__c';
    public final static String ITEM_BASE_PRICE_OBJECT_API_NAME = 'ASI_CRM_JP_Customer_Product_Price__c';
    public final static String BILL_TO_OBJECT_API_NAME         = 'ASI_CRM_Bill_To__c';
    public final static String RUNNING_NUMBER_OBJECT_API_NAME  = 'ASI_HK_CRM_Running_Number__c';
    public final static String ROUTE_TYPE_OBJECT_API_NAME      = 'ASI_CRM_Route_Type__c';
    public final static String ITEM_GROUP_OBJECT_API_NAME      = 'ASI_MFM_Item_Group__c';
    public final static String SKU_OBJECT_API_NAME             = 'ASI_MFM_SKU_Code__c';
    
    //Object Record Type
    public final static Map<String, String> CUSTOMER_RECORD_TYPE_MAP    = new Map<String, String> {
    	'ASI_CRM_JP_Bar_Supplier'                   => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Bar_Supplier'),
        'ASI_CRM_JP_Direct_Sales_Bill_To'           => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Direct_Sales_Bill_To'),
        'ASI_CRM_JP_Direct_Sales_Customer'          => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Direct_Sales_Customer'),
        'ASI_CRM_JP_Inactive_Direct_Sales_Customer' => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Inactive_Direct_Sales_Customer'),
        'ASI_CRM_JP_Direct_Sales_Ship_To'           => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Direct_Sales_Ship_To'),
        'ASI_CRM_JP_Employee'                       => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Employee'),
        'ASI_CRM_JP_Off_Trade_Outlet'               => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Off_Trade_Outlet'),
        'ASI_CRM_JP_On_Trade_Outlet'                => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_On_Trade_Outlet'),
        'ASI_CRM_JP_Wholesaler'                     => Global_RecordTypeCache.getRtId(CUSTOMER_OBJECT_API_NAME + 'ASI_CRM_JP_Wholesaler')
    };
    public final static Map<String, String> SALES_ORDER_RECORD_TYPE_MAP = new Map<String, String> {
    	'ASI_CRM_JP_Direct_Sales'         => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Direct_Sales'),
        'ASI_CRM_JP_Duty_Free_SO'         => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Duty_Free_SO'),
        'ASI_CRM_JP_Employee_Sales'       => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Employee_Sales'),
        'ASI_CRM_JP_Entertainment_Sales'  => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Entertainment_Sales'),
        'ASI_CRM_JP_Marketing_FOC'        => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Marketing_FOC'),
        'ASI_CRM_JP_Normal_SO'            => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Normal_SO'),
        'ASI_CRM_JP_Sample_Sales'         => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Sample_Sales'),
        'ASI_CRM_JP_Inactive_Sales_Order' => Global_RecordTypeCache.getRtId(SALES_ORDER_OBJECT_API_NAME + 'ASI_CRM_JP_Inactive_Sales_Order')
    };
	public final static Map<String, String> ROUTE_TYPE_RECORD_TYPE      = new Map<String, String> {
        'ASI_CRM_JP_Customer_Route_Type'    => Global_RecordTypeCache.getRtId(ROUTE_TYPE_OBJECT_API_NAME + 'ASI_CRM_JP_Customer_Route_Type'),
        'ASI_CRM_JP_Price_Route_Type'       => Global_RecordTypeCache.getRtId(ROUTE_TYPE_OBJECT_API_NAME + 'ASI_CRM_JP_Price_Route_Type'),
        'ASI_CRM_JP_Sales_Order_Route_Type' => Global_RecordTypeCache.getRtId(ROUTE_TYPE_OBJECT_API_NAME + 'ASI_CRM_JP_Sales_Order_Route_Type')
    };
    public final static Map<String, String> ITEM_BASE_PRICE_RECORD_TYPE = new Map<String, String> {
    	'ASI_CRM_JP_Direct_Sales_Product_Price' => Global_RecordTypeCache.getRtId(ITEM_BASE_PRICE_OBJECT_API_NAME + 'ASI_CRM_JP_Direct_Sales_Product_Price'), 
    	'ASI_CRM_JP_Duty_Free_Product_Price'    => Global_RecordTypeCache.getRtId(ITEM_BASE_PRICE_OBJECT_API_NAME + 'ASI_CRM_JP_Duty_Free_Product_Price'), 
    	'ASI_CRM_JP_Duty_Paid_Product_Price'    => Global_RecordTypeCache.getRtId(ITEM_BASE_PRICE_OBJECT_API_NAME + 'ASI_CRM_JP_Duty_Paid_Product_Price'), 
    	'ASI_CRM_JP_Employee_Product_Price'     => Global_RecordTypeCache.getRtId(ITEM_BASE_PRICE_OBJECT_API_NAME + 'ASI_CRM_JP_Employee_Product_Price')
    };
    
    public final static String POSTAL_CODE_RECORD_TYPE    = Global_RecordTypeCache.getRtId(POSTAL_CODE_OBJECT_API_NAME + 'ASI_CRM_JP_Postal_Code');
    public final static String RUNNING_NUMBER_RECORD_TYPE = Global_RecordTypeCache.getRtId(RUNNING_NUMBER_OBJECT_API_NAME + 'ASI_HK_Running_Number');
    public final static String ITEM_GROU_RECORD_TYPE      = Global_RecordTypeCache.getRtId(ITEM_GROUP_OBJECT_API_NAME + 'ASI_CRM_JP_Item_Group');
    public final static String SKU_RECORD_TYPE            = Global_RecordTypeCache.getRtId(SKU_OBJECT_API_NAME + 'ASI_CRM_JP_SKU');
    
  	//Record Default Value
    public final static Map<String, Object> WHOLESALER_CUSTOMER_DEFAULT_VALUE_MAP   = new Map<String, Object> {
    	'Name'                               => 'Testing Wholesaler',
        'ASI_CRM_Customer_Name_Kanji__c'     => 'Testing Wholesaler',
        'ASI_CRM_Customer_Name_Katakana__c'  => 'Testing Wholesaler',
        'ASI_CRM_VN_EnglishName__c'          => 'Testing Wholesaler',
        'ASI_CRM_CN_Phone_Number__c'         => '1234-56-7891',
        'ASI_CRM_SG_Local_Channel__c'        => 'OTH',
        'ASI_CRM_CN_Address__c'              => 'Testing Address',
        'ASI_CRM_Branch__c'                  => 'WS (Whole Seller)',
        'ASI_CRM_VN_Channel__c'              => 'Wholesaler',
        'ASI_CRM_Large_Geographical_Area__c' => 'B-TOHOKU',
        'ASI_CRM_AR_Location__c'             => 'SD (SENDAI)',
        'ASI_CRM_Shipping_Calendar__c'       => 'MS',
        'ASI_CRM_Shipping_Lead_Time__c'      => 1,
        'ASI_CRM_SG_Business_Unit__c'        => '111',
        'ASI_CRM_SG_Tax_Expl_Code__c'        => 'V',
        'ASI_CRM_SG_Tax_Rate_Area__c'        => 'CR8',
        'RecordTypeId'                       => CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Wholesaler')
    };
    
    public final static Map<String, Object> DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP = new Map<String, Object> {
    	'Name'                               => 'Testing Direct Sales',
        'ASI_CRM_Customer_Name_Kanji__c'     => 'Testing Direct Sales',
        'ASI_CRM_PostalCode__c'              => '0000001',
        'ASI_CRM_Branch__c'                  => 'RS',
        'ASI_CRM_Large_Geographical_Area__c' => 'K',
        'ASI_CRM_AR_Location__c'             => 'BD',
        'ASI_CRM_SG_Tax_Rate_Area__c'        => 'CR8',
        'ASI_CRM_SG_Tax_Expl_Code__c'        => 'V',
        'RecordTypeId'                       => CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Inactive_Direct_Sales_Customer')
    };
    
    public final static Map<String, Object> DIRECT_SALES_SHIP_TO_DEFAULT_VALUE_MAP  = new Map<String, Object> {
    	'Name'                               => 'Testing Ship To',
        'ASI_CRM_Customer_Name_Kanji__c'     => 'Testing Ship To',
        'ASI_CRM_PostalCode__c'              => '0000001',
        'ASI_CRM_Shipping_Calendar__c'       => 'MS',
        'ASI_CRM_Shipping_Lead_Time__c'      => 1,
        'ASI_CRM_SG_Business_Unit__c'        => '111',
        'ASI_CRM_KR_Salesman__c'             => '0001',
        'RecordTypeId'                       => CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Ship_To')
    };
    
    public final static Map<String, Object> BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP      = new Map<String, Object> {
    	'Name'                           => 'Testing Bill To',
        'ASI_CRM_Customer_Name_Kanji__c' => 'Testing Bill To',
        'ASI_CRM_PostalCode__c'          => '0000001',
        'RecordTypeId'                   => CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Bill_To')
    };
    
    public final static Map<String, Object> POSTAL_CODE_DEFAULT_VALUE_MAP           = new Map<String, Object> {
    	'Name'                        => '0000001',
        'ASI_CRM_JP_Prefecture__c'    => 'Testing', 
        'ASI_CRM_JP_City__c'          => 'Testing',
        'ASI_CRM_JP_Town__c'          => 'Testing',
        'ASI_CRM_JP_Prefecture_EN__c' => 'Testing',
        'ASI_CRM_JP_Business_Unit__c' => '111'
    }; 
    
    public final static Map<String, Object> USER_ROLE_DEFAULT_VALUE_MAP             = new Map<String, Object> {
    	'Name'          => 'JP Testing Role',
        'DeveloperName' => 'JP_Testing_Role'
    };
    
    public final static Map<String, Object> USER_DEFAULT_VALUE_MAP                  = new Map<String, Object> {
    	'Alias'                       => 'prjtest',
        'Email'                       => 'standarduser@testorg.com',
        'EmailEncodingKey'            => 'UTF-8',
        'LastName'                    => 'Testing',
        'LanguageLocaleKey'           => 'en_US',
        'LocaleSidKey'                => 'en_US',
        'ProfileId'                   => SYSTEM_ADMIN_PROFILE.Id,
        'TimeZoneSidKey'              => 'America/Los_Angeles',
        'UserName'                    => 'prjtesting@laputatech.com',
        'ASI_TnE_Sub_Ledger__c'       => '0001',
        'ASI_KOR_User_Branch_Code__c' => 'JP'
    };
    
    public final static Map<String, Object> ITEM_GROUP_DEFAUL_VALUE_MAP             = new Map<String, Object> {
    	'Name'                       => 'Testing',
        'ASI_MFM_Item_Group_Code__c' => '000001',
        'RecordTypeId'               => ITEM_GROU_RECORD_TYPE
    };
    
    public final static Map<String, Object> SKU_DEFAULT_VALUE_MAP                   = new Map<String, Object> {
    	'Name'                                      => 'Testing SKU', 
        'ASI_CRM_JP_English_Name__c'                => 'Testing SKU',
        'ASI_MFM_SKU_Code__c'                       => '000001',
        'ASI_HK_CRM_Packaging_Size__c'              => 6,
        'ASI_CRM_JP_Active_for_Emp_Rep__c'          => true,
        'ASI_CRM_JP_Active_for_DSS_ETS_NMS_SPS__c'  => true,
        'ASI_CRM_JP_Active_for_JP_Marketing_FOC__c' => true,
        'RecordTypeId'                              => SKU_RECORD_TYPE
    };
    
    public final static Map<String, Object> ITEM_AVAILABILITY_DEFAULT_VALUE_MAP     = new Map<String, Object> {
    	'ASI_Lot_Number__c'       => '1',
        'ASI_Lot_Number_2__c'     => '1',
        'ASI_Quantity_On_hand__c' => 1000
    };
    
    public final static Map<String, Object> PRICE_LIST_DEFAULT_VALUE_MAP            = new Map<String, Object> {
    	'ASI_CRM_JP_Effective_Date__c' => Date.today().addYears(-1)
    };

    public final static Map<String, Object> ITEM_BASE_PRICE_DEFAULT_VALUE_MAP       = new Map<String, Object> {
    	'ASI_Bottle_Price__c'   => 1234,
        'ASI_Effective_Date__c' => Date.today().addYears(-1),
        'ASI_CRM_JP_Active__c'  => true
    };
    
    public final static Map<String, Object> ADVANCED_SEARCH_DEFAULT_VALUE_MAP       = new Map<String, Object> {
    	'ASI_Transaction_Date__c'               => Date.today(),
        'ASI_Business_Unit__c'                  => '111',
        'ASI_Freight_Code__c'                   => 'MS',
        'ASI_Reason_Code__c'                    => '1234',
        'ASI_Route_Code__c'                     => '1',
        'ASI_Ship_To_Customer_Salesman_Code__c' => '0001',
        'ASI_Tax_Area__c'                       => 'CR8',
        'ASI_Tax_Code__c'                       => 'V'
    };
    
    public final static Map<String, Object> SALES_ORDER_DEFAULT_VALUE_MAP           = new Map<String, Object> {
        'ASI_CRM_AP_Code__c'                 => 'SSSS',
        'ASI_CRM_Order_Date__c'              => Date.today(),
        'ASI_CRM_JP_Price_Effective_Date__c' => Date.today(),
        'ASI_CRM_Tax_Area__c'                => 'CR8',
        'ASI_CRM_Tax_Code__c'                => 'V',
        'ASI_CRM_Salesman_Code__c'           => '0001',
        'ASI_CRM_Status__c'                  => 'Draft',
        'ASI_CRM_Branch_Plant__c'            => '111',
        'ASI_CRM_Requested_Date__c'          => Date.today().addDays(15),
        'ASI_CRM_Delivery_Time__c'           => '1200-0000',
        'ASI_CRM_Freight_Code__c'            => 'MS',
        'ASI_CRM_Route_Code__c'              => 15
    };
    
    public final static Map<String, Object> SALES_ORDER_ITEM_DEFAULT_VALUE_MAP      = new Map<String, Object> {
        'ASI_CRM_Sorting_Number__c' => 1,
        'ASI_CRM_UOM__c'            => 'BT',
        'ASI_CRM_Quantity__c'       => 10,
        'ASI_CRM_Status__c'         => '520-Ready'
    };
    
    private ASI_CRM_JP_TestHelper() {
    }
    
    public static void createRunningNumber() {
		ASI_HK_CRM_Running_Number__c shipToCustomerCode = new ASI_HK_CRM_Running_Number__c();
        shipToCustomerCode.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Customer_Code_ShipTo';
        shipToCustomerCode.ASI_HK_CRM_Format__c                     = 'DS{000000}';
        shipToCustomerCode.ASI_HK_CRM_Running_Number__c             = 1;
        shipToCustomerCode.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        shipToCustomerCode.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c billToCustomerCode = new ASI_HK_CRM_Running_Number__c();
        billToCustomerCode.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Customer_Code_BillTo';
        billToCustomerCode.ASI_HK_CRM_Format__c                     = 'DB{000000}';
        billToCustomerCode.ASI_HK_CRM_Running_Number__c             = 1;
        billToCustomerCode.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        billToCustomerCode.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c directSalesCustomerCode = new ASI_HK_CRM_Running_Number__c();
        directSalesCustomerCode.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Customer_Code_Direct_Sales';
        directSalesCustomerCode.ASI_HK_CRM_Format__c                     = 'DC{000000}';
        directSalesCustomerCode.ASI_HK_CRM_Running_Number__c             = 1;
        directSalesCustomerCode.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        directSalesCustomerCode.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c billToName = new ASI_HK_CRM_Running_Number__c();
        billToName.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_BillToName';
        billToName.ASI_HK_CRM_Format__c                     = 'YY{000000}';
        billToName.ASI_HK_CRM_Running_Number__c             = 1;
        billToName.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        billToName.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c sampleSalesSO = new ASI_HK_CRM_Running_Number__c();
        sampleSalesSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Sample_Sales';
        sampleSalesSO.ASI_HK_CRM_Format__c                     = 'SPS{YY}{000000}';
        sampleSalesSO.ASI_HK_CRM_Running_Number__c             = 1;
        sampleSalesSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        sampleSalesSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c normalSO = new ASI_HK_CRM_Running_Number__c();
        normalSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Normal_SO';
        normalSO.ASI_HK_CRM_Format__c                     = 'NMS{YY}{000000}';
        normalSO.ASI_HK_CRM_Running_Number__c             = 1;
        normalSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        normalSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c marketingFOCSO = new ASI_HK_CRM_Running_Number__c();
        marketingFOCSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Marketing_FOC';
        marketingFOCSO.ASI_HK_CRM_Format__c                     = 'MKF{YY}{000000}';
        marketingFOCSO.ASI_HK_CRM_Running_Number__c             = 1;
        marketingFOCSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        marketingFOCSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;

        ASI_HK_CRM_Running_Number__c entertainmentSO = new ASI_HK_CRM_Running_Number__c();
        entertainmentSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Entertainment_Sales';
        entertainmentSO.ASI_HK_CRM_Format__c                     = 'ETS{YY}{000000}';
        entertainmentSO.ASI_HK_CRM_Running_Number__c             = 1;
        entertainmentSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        entertainmentSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c employeeSO = new ASI_HK_CRM_Running_Number__c();
        employeeSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Employee_Sales';
        employeeSO.ASI_HK_CRM_Format__c                     = 'EMS{YY}{000000}';
        employeeSO.ASI_HK_CRM_Running_Number__c             = 1;
        employeeSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        employeeSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c dutyFreeSO = new ASI_HK_CRM_Running_Number__c();
        dutyFreeSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Duty_Free_SO';
        dutyFreeSO.ASI_HK_CRM_Format__c                     = 'DFS{YY}{000000}';
        dutyFreeSO.ASI_HK_CRM_Running_Number__c             = 1;
        dutyFreeSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        dutyFreeSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        ASI_HK_CRM_Running_Number__c directSalesSO = new ASI_HK_CRM_Running_Number__c();
        directSalesSO.ASI_HK_CRM_Object_Name__c                = 'ASI_CRM_JP_Sales_Order__cASI_CRM_JP_Direct_Sales';
        directSalesSO.ASI_HK_CRM_Format__c                     = 'DSS{YY}{000000}';
        directSalesSO.ASI_HK_CRM_Running_Number__c             = 1;
        directSalesSO.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 3;
        directSalesSO.ASI_HK_CRM_Fiscal_Year__c                = 2017;
        
        
        
        List<ASI_HK_CRM_Running_Number__c> runningNumberList = new List<ASI_HK_CRM_Running_Number__c>();
        runningNumberList.add(shipToCustomerCode);
        runningNumberList.add(billToCustomerCode);
        runningNumberList.add(directSalesCustomerCode);
        runningNumberList.add(billToName);
        runningNumberList.add(sampleSalesSO);
        runningNumberList.add(normalSO);
        runningNumberList.add(marketingFOCSO);
        runningNumberList.add(entertainmentSO);
        runningNumberList.add(employeeSO);
        runningNumberList.add(dutyFreeSO);
        runningNumberList.add(directSalesSO);
        
        insert runningNumberList;
    }
    
    public static void createApprovalRoute() {
        ASI_CRM_Route_Type__c directSalesSORouteType = new ASI_CRM_Route_Type__c();
        directSalesSORouteType.Name                          = 'JP Sales Order Direct Sales SO';
        directSalesSORouteType.ASI_CRM_Module__c             = 'Sales Order';
        directSalesSORouteType.ASI_CRM_Module_Record_Type__c = 'Direct Sales SO';
        directSalesSORouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Sales_Order_Route_Type');
        
        ASI_CRM_Route_Type__c entertainmentSORouteType = new ASI_CRM_Route_Type__c();
        entertainmentSORouteType.Name                          = 'JP Sales Order Entertainment SO';
        entertainmentSORouteType.ASI_CRM_Module__c             = 'Sales Order';
        entertainmentSORouteType.ASI_CRM_Module_Record_Type__c = 'Entertainment SO';
        entertainmentSORouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Sales_Order_Route_Type');
        
        ASI_CRM_Route_Type__c marketingFOCRouteType = new ASI_CRM_Route_Type__c();
        marketingFOCRouteType.Name                          = 'JP Sales Order Marketing FOC';
        marketingFOCRouteType.ASI_CRM_Module__c             = 'Sales Order';
        marketingFOCRouteType.ASI_CRM_Module_Record_Type__c = 'Marketing FOC';
        marketingFOCRouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Sales_Order_Route_Type');
        
        ASI_CRM_Route_Type__c sampleSORouteType = new ASI_CRM_Route_Type__c();
        sampleSORouteType.Name                          = 'JP Sales Order Sample SO';
        sampleSORouteType.ASI_CRM_Module__c             = 'Sales Order';
        sampleSORouteType.ASI_CRM_Module_Record_Type__c = 'Sample SO';
        sampleSORouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Sales_Order_Route_Type');
        
        ASI_CRM_Route_Type__c priceRouteType = new ASI_CRM_Route_Type__c();
        priceRouteType.Name                          = 'JP Price List';
        priceRouteType.ASI_CRM_Module__c             = 'Price List';
        priceRouteType.ASI_CRM_Module_Record_Type__c = 'Price List';
        priceRouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Price_Route_Type');
        
        ASI_CRM_Route_Type__c itemBasePriceRouteType = new ASI_CRM_Route_Type__c();
        itemBasePriceRouteType.Name                          = 'JP Item Base Price Direct Sales Product Price';
        itemBasePriceRouteType.ASI_CRM_Module__c             = 'Item Base Price';
        itemBasePriceRouteType.ASI_CRM_Module_Record_Type__c = 'Direct Sales Product Price';
        itemBasePriceRouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Price_Route_Type');
        
        ASI_CRM_Route_Type__c directSalesCustomerRouteType = new ASI_CRM_Route_Type__c();
        directSalesCustomerRouteType.Name                          = 'JP Customer Direct Sales Customer';
        directSalesCustomerRouteType.ASI_CRM_Module__c             = 'Customer';
        directSalesCustomerRouteType.ASI_CRM_Module_Record_Type__c = 'Direct Sales Customer';
        directSalesCustomerRouteType.RecordTypeId                  = ROUTE_TYPE_RECORD_TYPE.get('ASI_CRM_JP_Customer_Route_Type');
        
        List<ASI_CRM_Route_Type__c> routeTypeList = new List<ASI_CRM_Route_Type__c>();
        routeTypeList.add(directSalesSORouteType);
        routeTypeList.add(entertainmentSORouteType);
        routeTypeList.add(marketingFOCRouteType);
        routeTypeList.add(sampleSORouteType);
        routeTypeList.add(priceRouteType);
        routeTypeList.add(itemBasePriceRouteType);
        routeTypeList.add(directSalesCustomerRouteType);
        
        insert routeTypeList;
        
        List<ASI_CRM_Route_Rule_Detail__c> routeTypeDetailList = new List<ASI_CRM_Route_Rule_Detail__c>();
        for(ASI_CRM_Route_Type__c routeType : routeTypeList) {
            ASI_CRM_Route_Rule_Detail__c routeRuleDetail = new ASI_CRM_Route_Rule_Detail__c();
            routeRuleDetail.ASI_CRM_Route_Type__c       = routeType.Id; 
            routeRuleDetail.ASI_CRM_JP_Approver_Type__c = 'Line Manager';
            routeTypeDetailList.add(routeRuleDetail);
        }
        insert routeTypeDetailList;
    }
    
    public static void createBusinessDay() {
        List<ASI_JP_CRM_Business_Day_Calendar__c> businessDayList = new List<ASI_JP_CRM_Business_Day_Calendar__c>();
        for(Integer i = 0 ; i < 50 ; i++) {
    		ASI_JP_CRM_Business_Day_Calendar__c businessDay = new ASI_JP_CRM_Business_Day_Calendar__c();
            businessDay.ASI_Business_Day__c     = Date.today().addDays(i);
            businessDay.ASI_Shipping_Company__c = 'MS';
            if(Math.mod(i, 7) == 0) { 
                businessDay.ASI_PR_Working__c       = false;
           		businessDay.ASI_WS_Working__c       = false;
            } else {
            	businessDay.ASI_PR_Working__c       = true;
           		businessDay.ASI_WS_Working__c       = true;
            }
            businessDayList.add(businessDay);
        }
        
        for(Integer i = 0 ; i < 50 ; i++) {
    		ASI_JP_CRM_Business_Day_Calendar__c businessDay = new ASI_JP_CRM_Business_Day_Calendar__c();
            businessDay.ASI_Business_Day__c     = Date.today().addDays(-i);
            businessDay.ASI_Shipping_Company__c = 'MS';
            if(Math.mod(i, 7) == 0) { 
                businessDay.ASI_PR_Working__c       = false;
           		businessDay.ASI_WS_Working__c       = false;
            } else {
            	businessDay.ASI_PR_Working__c       = true;
           		businessDay.ASI_WS_Working__c       = true;
            }
            businessDayList.add(businessDay);
        }
        insert businessDayList;
    }
    
    public static UserRole createUserRole(Map<String, Object> fieldValueMap) {
    	UserRole uRole = new UserRole();
		uRole = (UserRole) createObject(uRole, fieldValueMap);
        return uRole;
    }
    
    public static User createUser(Map<String, Object> fieldValueMap) {
        User u = new User();
		u = (User) createObject(u, fieldValueMap);
        return u;
    }
    
    public static ASI_MFM_Item_Group__c createItemGroup(Map<String, Object> fieldValueMap) {
    	ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c();
		itemGroup = (ASI_MFM_Item_Group__c) createObject(itemGroup, fieldValueMap);
        return itemGroup;
    }
    
    public static ASI_MFM_SKU_Code__c createSKU(Map<String, Object> fieldValueMap) {
        ASI_MFM_SKU_Code__c skuCode = new ASI_MFM_SKU_Code__c();
        skuCode = (ASI_MFM_SKU_Code__c) createObject(skuCode, fieldValueMap);
        return skuCode;
    }
    
    public static ASI_CRM_JP_Item_Availability__c createItemAvailability(Map<String, Object> fieldValueMap) {
    	ASI_CRM_JP_Item_Availability__c itemAvailability = new ASI_CRM_JP_Item_Availability__c();
        itemAvailability = (ASI_CRM_JP_Item_Availability__c) createObject(itemAvailability, fieldValueMap);
        return itemAvailability;
    }
    
    public static ASI_CRM_Postal_Code__c createPostalCode(Map<String, Object> fieldValueMap) {
        ASI_CRM_Postal_Code__c postalCode = new ASI_CRM_Postal_Code__c();
		postalCode = (ASI_CRM_Postal_Code__c) createObject(postalCode, fieldValueMap);
        return postalCode;
    }
    
    public static ASI_CRM_AccountsAdditionalField__c createCustomer(Map<String, Object> fieldValueMap) {
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
		customer = (ASI_CRM_AccountsAdditionalField__c) createObject(customer, fieldValueMap);
        return customer;
    }
    
    public static ASI_CRM_Bill_To__c createBillTo(String directSalesCustomerId, String billToCustomerId) {
        ASI_CRM_Bill_To__c billTo          = new ASI_CRM_Bill_To__c();
        billTo.ASI_CRM_JP_Active__c        = true;
        billTo.ASI_CRM_Customer__c         = directSalesCustomerId;
        billTo.ASI_CRM_Bill_To_Customer__c = billToCustomerId;
    	return billTo;
    }
    
    public static ASI_CRM_JP_Advanced_Search__c createAdvancedSearch(Map<String, Object> fieldValueMap) {
        ASI_CRM_JP_Advanced_Search__c advancedSearch = new ASI_CRM_JP_Advanced_Search__c();
		advancedSearch = (ASI_CRM_JP_Advanced_Search__c) createObject(advancedSearch, fieldValueMap);
        return advancedSearch;
    }
    
    public static ASI_CRM_JP_Sales_Order__c createSalesOrder(Map<String, Object> fieldValueMap) {
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        
		salesOrder = (ASI_CRM_JP_Sales_Order__c) createObject(salesOrder, fieldValueMap);
        return salesOrder;
    }
    
    public static ASI_CRM_JP_Sales_Order_Item__c createSalesOrderLine(Map<String, Object> fieldValueMap) {
        ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = new ASI_CRM_JP_Sales_Order_Item__c();
        salesOrderItem = (ASI_CRM_JP_Sales_Order_Item__c) createObject(salesOrderItem, fieldValueMap);
        return salesOrderItem;
    }
    
    public static ASI_CRM_Price_List__c createPriceList(Map<String, Object> fieldValueMap) {
        ASI_CRM_Price_List__c priceList = new ASI_CRM_Price_List__c();
		priceList = (ASI_CRM_Price_List__c) createObject(priceList, fieldValueMap);
        return priceList;
    }
    
    public static ASI_CRM_JP_Customer_Product_Price__c createItemBasePrice(Map<String, Object> fieldValueMap) {
    	ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = new ASI_CRM_JP_Customer_Product_Price__c();
		itemBasePrice = (ASI_CRM_JP_Customer_Product_Price__c) createObject(itemBasePrice, fieldValueMap);
        return itemBasePrice;
    }
    
    private static sObject createObject(sObject sObj, Map<String, Object> fieldValueMap) {
        for(String fieldAPIName : fieldValueMap.keySet()) {
        	sObj.put(fieldAPIName, fieldValueMap.get(fieldAPIName));
        }
        return sObj;
    }
}