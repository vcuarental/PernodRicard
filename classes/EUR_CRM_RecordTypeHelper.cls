/**
* Class: EUR_CRM_RecordTypeHelper
* Global class that refactors recordtypes into a single point of control.
* 
* Usage in other classes/controllers:
* EUR_CRM_EU_AccountCreateProsSegHandler
* EUR_CRM_ProsSegmentationPage
* EUR_CRM_ProsSegmentationExt
* EUR_CRM_ProsSegmentationExtCombined
* EUR_CRM_MassDistrObjectiveCtrller
* EUR_CRM_TerritoryOwnerChanged
* EUR_CRM_ListingTemplateHandler
* EUR_CRM_ListingTemplateAssignmentHandler
* EUR_CRM_AssignAccountOwnerHandler
* EUR_CRM_GroupOutletControllerExt
* EUR_CRM_OutletToSupplierHandler
* EUR_CRM_SurveyControllerExt
* EUR_CRM_ForceImageLevelHandler
* EUR_CRM_StockUpdateFromSO
* EUR_CRM_StockUpdateFromSRO
* EUR_CRM_RouteTemplate_SetDefaultValues
* EUR_CRM_MassUpdateOPAcctMap batch classes
* EUR_CRM_AccountAssignAutoNumber
* EUR_CRM_EnablePriceCheckBatch
**/
global without sharing class EUR_CRM_RecordTypeHelper {

	private static final String CURRENT_CLASS_NAME = EUR_CRM_RecordTypeHelper.class.getName();

	private static Set<String> MassUpdateOPAcctMap_validRecordTypesForTest = new Set<String>{
        'EUR_RU_O_P_Account_Mapping',
        'EUR_DK_OP_Account_Mapping',
        'EUR_PT_Account_Mapping',
        'EUR_ZA_OP_Account_Mapping',
        'EUR_SE_O_P_Account_Mapping'
    };

	private static Set<String> ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet_ForTest = new Set<String>{
		// RU Off Trade and Distributor accounts
		'EUR_RU_Direct_Off_Trade',
		'EUR_RU_Direct_Type_2_Off_Trade',
		'EUR_RU_Distribution_Center',
		'EUR_RU_Distributor',
		'EUR_RU_Indirect_Off_Trade',

		// MA Off Trade and Distributor accounts
		'EUR_MA_Distributor',
		'EUR_MA_Off_Trade',

		// DK Off Trade
		'EUR_DK_OFF_Trade',

		// BG OFF Trade
		'EUR_BG_Modern_Off_Trade',
		'EUR_BG_Traditional_Off_Trade',
		'EUR_BG_Wholesaler',
		'EUR_MA_Off_Trade',

		// PT recordtypes
		'EUR_PT_CandCs',
		'EUR_PT_Off_Trade',
		'EUR_PT_Wholesaler',

		// BE RecordTypes
		'EUR_BE_Off_Trade',
		//NL ON Trade
		'EUR_NL_Wholesaler',
		'EUR_NL_Off_Trade_Independent',
		'EUR_NL_Off_Trade_Chains'
	};

    private static Set<String> ListingTemplateHandler_templateCriteriaAccountRecordTypeSet_ForTest = new Set<String>{
        // RU ON Trade
        'EUR_RU_On_Trade',

        // MA ON Trade
        'EUR_MA_On_Trade',

        // CH ON Trade
        'EUR_CH_Horeca_Direct',
        'EUR_CH_Horeca_Indirect',

        // DK ON Trade
        'EUR_DK_On_Trade',

        // BG ON Trade
        'EUR_BG_On_Trade'
    };

    private static Set<String> ListingTemplateAssignmentHandler_segmentationRecordTypes_ForTest = new Set<String>{
        'EUR_AO_On_Trade',
        'EUR_KE_On_Trade',
        'EUR_FI_Direct_On_Trade',
        'EUR_FI_Indirect_On_Trade',
        'EUR_NG_On_Trade',
        'EUR_ZA_On_Trade_Direct',
        'EUR_ZA_On_Trade_Indirect',
        'EUR_ZA_On_Trade_Informal',
        'EUR_PT_On_Trade'
    };

    private static Set<String> SegmentationRecordtypesWithoutOutletTypes_ForTest = new Set<String>{
//            'EUR_IDL_On_Trade_Account',
//            'EUR_DB_On_Trade_Account',
        'EUR_IT_On_Trade_Account'
    };

    private static Set<String> ListingTemplateAssignmentHandler_classificationRecordTypes_ForTest = new Set<String>{
        'EUR_AO_Off_Trade',
        'EUR_KE_Off_Trade',
        'EUR_AO_Distributor',
        'EUR_KE_Distributor',
        'EUR_NG_Off_Trade_Traditional',
        'EUR_NG_Off_Trade_Modern',
        'EUR_NG_Off_Trade_Bulk_Breaker',
        'EUR_ZA_Off_Trade',
        'EUR_ZA_Distributor'
    };

	private static Set<String> AT_Action_Trigger_validRT_ForTest = new Set<String>{
		'EUR_AT_Central_Objective',
		'EUR_AO_Central_Objective_Action',
		'EUR_KE_Central_Objective_Action',
		'EUR_FI_Central_Objective_Action',
		'EUR_NG_Central_Objective_Action',
		'EUR_MA_Central_Objective_Action',
		'EUR_CH_Central_Objective_Action',
		'EUR_RU_Central_Objective_Action',
		'EUR_BG_Central_Objective_Action'
	};

	private static Set<String> SalesRepOrderAssignAutoNumber_validRecordTypes_ForTest = new Set<String>{
		'EUR_DK_Free_Goods_Order_to_SR_Stock',
		'EUR_DE_Free_Goods_Order_to_SR_Stock',
		//SE RecordType
		'EUR_SE_Free_Goods_Order_to_SR_Stock',
		'EUR_SE_Free_Goods_Order_from_SR_Stock'
	};

	private static Set<String> AccountAssignAutoNumber_validRecordTypes_ForTest = new Set<String>{
		'EUR_RU_Direct_Off_Trade',
		'EUR_RU_Direct_Type_2_Off_Trade',
		'EUR_RU_Distribution_Center',
		'EUR_RU_Distributor',
		'EUR_RU_Indirect_Off_Trade',
		'EUR_RU_On_Trade'
	};

	private static Set<String> OutletToSupplierHandler_validRecordTypes_ForTest = new Set<String>{
		// AO/KE recordtypes
		'EUR_AO_On_Trade',
		'EUR_KE_On_Trade',
		'EUR_AO_Off_Trade',
		'EUR_KE_Off_Trade',
		'EUR_AO_Distributor',
		'EUR_KE_Distributor',

		// MA recordtypes
		'EUR_MA_On_Trade',
		'EUR_MA_Off_Trade',
		'EUR_MA_Distributor',

		// CH recordtypes
		'EUR_CH_C_C_Indirect',
		'EUR_CH_C_C_and_WHS_Direct',
		'EUR_CH_Horeca_Direct',
		'EUR_CH_Horeca_Indirect',
		'EUR_CH_Off_Trade_Direct',
		'EUR_CH_Off_Trade_Indirect',

		// BG recordtypesEUR_CRM_TerritoryOwnerChanged
		'EUR_BG_Modern_Off_Trade',
		'EUR_BG_On_Trade',
		'EUR_BG_Traditional_Off_Trade',
		'EUR_BG_Wholesaler',

		// PT Recordtypes
		'EUR_PT_CandCs',
		'EUR_PT_Off_Trade',
		'EUR_PT_Wholesaler',
		'EUR_PT_On_Trade',

		// BE Recordtypes
		'EUR_BE_Wholesaler',

		//DE Recordtype
		'EUR_DE_ON_Wholesaler',
		//NL Recordtype,
		'EUR_NL_Wholesaler'
	};

	private static Set<String> ForceImageLevelHandler_validRecordTypes_ForTest = new Set<String>{
		'EUR_DK_On_Trade',
		'EUR_NL_On_Trade',
		'EUR_RU_On_Trade'
	};

	private static Set<String> ForcePRSegDimensionsHandler_validRecordTypes_ForTest = new Set<String>{
		// BG RecordTypes
		'EUR_BG_Modern_Off_Trade',
		'EUR_BG_Traditional_Off_Trade',

		// BE RecordTypes
		'EUR_BE_On_Trade',
		'EUR_BE_Off_Trade',
		// SE RecordTypes
		'EUR_SE_On_Trade',
		// NL RecordTypes
		'EUR_NL_On_Trade'
	};

	private static Set<String> StockUpdate_validRecordTypes_ForTest = new Set<String>{
		'EUR_DK_Free_Goods_Order_from_SR_Stock',
		'EUR_DK_Free_Goods_Order_to_SR_Stock',
		'EUR_DE_OFF_Free_Goods_from_SR_Stock_to_Customer_Sales_Order',
		'EUR_DE_ON_Free_Goods_from_SR_Stock_to_Customer_Sales_Order',
		'EUR_DE_Free_Goods_Order_to_SR_Stock',
		'EUR_SE_Free_Goods_Order_to_SR_Stock',
		'EUR_SE_Free_Goods_Order_from_SR_Stock'
	};

    private static Map<String, String> SurveyControllerExt_recordTypeMappingForTest = new Map<String, String>{
        'EUR_DE_ON_Trade_Survey_Header' => 'EUR_DE_Question',
        'EUR_DE_OFF_Trade_Survey_Header' => 'EUR_DE_Question',
        'EUR_FI_OFF_Trade_Survey_Header' => 'EUR_FI_Question',
        'EUR_FI_ON_Trade_Survey_Header' => 'EUR_FI_Question',
        'EUR_ZA_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_OFF_Trade_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_ON_Trade_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_Sales_Manager_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_Regional_Sales_Manager_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_General_Manager_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_Capability_Manager_Survey_Header' => 'EUR_ZA_Question',
        'EUR_ZA_Admin_Survey_Header' => 'EUR_ZA_Question',
        'EUR_CZ_Survey_Header' => 'EUR_CZ_Question',
        'EUR_GB_Survey_Header' => 'EUR_GB_Question',
        'EUR_SK_Survey_Header' => 'EUR_SK_Question',
        'EUR_RU_ON_Trade_Survey_Header' => 'EUR_RU_Question',
        'EUR_RU_OFF_Trade_Survey_Header' => 'EUR_RU_Question',
        'EUR_DK_OFF_Trade_Survey_Header' => 'EUR_DK_Question',
        'EUR_DK_ON_Trade_Survey_Header' => 'EUR_DK_Question',
        'EUR_BG_OFF_Trade_Survey_Header' => 'EUR_BG_Question',
        'EUR_BG_ON_Trade_Survey_Header' => 'EUR_BG_Question',
        'EUR_BE_OFF_Trade_Survey_Header' => 'EUR_BE_Question',
        'EUR_BE_ON_Trade_Survey_Header' => 'EUR_BE_Question',
        'EUR_SE_ON_Trade_Survey_Header' => 'EUR_SE_Question',
        'EUR_NL_On_Trade_Survey_Header' => 'EUR_NL_Question',
        'EUR_NL_Off_Trade_Survey_Header' => 'EUR_NL_Question'
    };

    private static Map<String, String> SurveyControllerExt_surveyHeaderRecordTypeMapping_ForTest = new Map<String, String>{
        'EUR_DE_ON_Trade_Survey_Header' => 'EUR_DE_Survey',
        'EUR_DE_OFF_Trade_Survey_Header' => 'EUR_DE_Survey',
        'EUR_FI_OFF_Trade_Survey_Header' => 'EUR_FI_Survey',
        'EUR_FI_ON_Trade_Survey_Header' => 'EUR_FI_Survey',
        'EUR_ZA_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_OFF_Trade_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_ON_Trade_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_Sales_Manager_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_Regional_Sales_Manager_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_General_Manager_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_Capability_Manager_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_ZA_Admin_Survey_Header' => 'EUR_ZA_Survey',
        'EUR_CZ_Survey_Header' => 'EUR_JB_Survey',
        'EUR_GB_Survey_Header' => 'EUR_GB_Survey',
        'EUR_SK_Survey_Header' => 'EUR_JB_Survey',
        'EUR_RU_ON_Trade_Survey_Header' => 'EUR_RU_Survey',
        'EUR_RU_OFF_Trade_Survey_Header' => 'EUR_RU_Survey',
        'EUR_DK_ON_Trade_Survey_Header' => 'EUR_DK_Survey',
        'EUR_DK_OFF_Trade_Survey_Header' => 'EUR_DK_Survey',
        'EUR_BG_OFF_Trade_Survey_Header' => 'EUR_BG_Survey',
        'EUR_BG_ON_Trade_Survey_Header' => 'EUR_BG_Survey',
        'EUR_BE_OFF_Trade_Survey_Header' => 'EUR_BE_Survey',
        'EUR_BE_ON_Trade_Survey_Header' => 'EUR_BE_Survey',
        'EUR_SE_ON_Trade_Survey_Header' => 'EUR_SE_Survey',
        'EUR_NL_On_Trade_Survey_Header' => 'EUR_NL_Survey',
        'EUR_NL_Off_Trade_Survey_Header' => 'EUR_NL_Survey',
        'EUR_DE_WS_Survey_Header' => 'EUR_DE_Survey'
    };

    private static Map<String, String> SurveyControllerExt_surveyQuestionRecordTypeMapping_ForTest = new Map<String, String>{
        'EUR_DE_ON_Trade_Survey_Header' => 'EUR_CRM_DE_Survey_Question',
        'EUR_DE_OFF_Trade_Survey_Header' => 'EUR_CRM_DE_Survey_Question',
        'EUR_FI_OFF_Trade_Survey_Header' => 'EUR_FI_Survey_Question',
        'EUR_FI_ON_Trade_Survey_Header' => 'EUR_FI_Survey_Question',
        'EUR_ZA_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_OFF_Trade_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_ON_Trade_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_Regional_Sales_Manager_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_General_Manager_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_Capability_Manager_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_Sales_Manager_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_ZA_Admin_Survey_Header' => 'EUR_ZA_Survey_Question',
        'EUR_RU_ON_Trade_Survey_Header' => 'EUR_RU_Survey_Question',
        'EUR_RU_OFF_Trade_Survey_Header' => 'EUR_RU_Survey_Question',
        'EUR_DK_ON_Trade_Survey_Header' => 'EUR_DK_Survey_Question',
        'EUR_DK_OFF_Trade_Survey_Header' => 'EUR_DK_Survey_Question',
        'EUR_BG_OFF_Trade_Survey_Header' => 'EUR_BG_Survey_Question',
        'EUR_BG_ON_Trade_Survey_Header' => 'EUR_BG_Survey_Question',
        'EUR_BE_OFF_Trade_Survey_Header' => 'EUR_BE_Survey_Question',
        'EUR_BE_ON_Trade_Survey_Header' => 'EUR_BE_Survey_Question',
        'EUR_SE_ON_Trade_Survey_Header' => 'EUR_SE_Survey_Question',
        'EUR_NL_On_Trade_Survey_Header' => 'EUR_NL_Survey_Question',
        'EUR_NL_Off_Trade_Survey_Header' => 'EUR_NL_Survey_Question'
    };

	private static Map<String, String> ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap_ForTest = new Map<String, String>{
		'EUR_AO_Off_Trade' => 'EUR_AO_Off_Trade_Template_Criteria',
		'EUR_AO_On_Trade' => 'EUR_AO_On_Trade_Template_Criteria',
		'EUR_AO_Distributor' => 'EUR_AO_Off_Trade_Template_Criteria',
		'EUR_KE_Distributor' => 'EUR_KE_Off_Trade_Template_Criteria',
		'EUR_KE_Off_Trade' => 'EUR_KE_Off_Trade_Template_Criteria',
		'EUR_KE_On_Trade' => 'EUR_KE_On_Trade_Template_Criteria',
		'EUR_FI_Indirect_On_Trade' => 'EUR_FI_On_Trade_Template_Criteria',
		'EUR_FI_Direct_On_Trade' => 'EUR_FI_On_Trade_Template_Criteria',
		'EUR_NG_On_Trade' => 'EUR_NG_On_Trade_Template_Criteria',
		'EUR_NG_Off_Trade_Traditional' => 'EUR_NG_Off_Trade_Template_Criteria',
		'EUR_NG_Off_Trade_Modern' => 'EUR_NG_Off_Trade_Template_Criteria',
		'EUR_NG_Off_Trade_Bulk_Breaker' => 'EUR_NG_Off_Trade_Template_Criteria',
		'EUR_ZA_Off_Trade' => 'EUR_ZA_Off_Trade_Template_Criteria',
		'EUR_ZA_On_Trade_Direct' => 'EUR_ZA_On_Trade_Template_Criteria',
		'EUR_ZA_On_Trade_Indirect' => 'EUR_ZA_On_Trade_Template_Criteria',
		'EUR_ZA_On_Trade_Informal' => 'EUR_ZA_On_Trade_Template_Criteria',
		'EUR_ZA_Distributor' => 'EUR_ZA_Off_Trade_Template_Criteria',
		'EUR_PT_On_Trade' => 'EUR_PT_On_Trade_Template_Criteria'
	};

    private static Map<String, String> MassDistrObjectiveCtrller_rtMapping_ForTest = new Map<String, String>{
        'EUR_AT_Central_Objective' => 'EUR_AT_Central_Objective',
        'EUR_KE_Central_Objective' => 'EUR_KE_Central_Objective_Action',
        'EUR_AO_Central_Objective' => 'EUR_AO_Central_Objective_Action',
        'EUR_GB_Central_Objective' => 'EUR_GB_Central_Objective',
        'EUR_FI_Central_Objective' => 'EUR_FI_Central_Objective_Action',
        'EUR_NG_Central_Objective' => 'EUR_NG_Central_Objective_Action',
        'EUR_MA_Central_Objective' => 'EUR_MA_Central_Objective_Action',
        'EUR_CH_Central_Objective' => 'EUR_CH_Central_Objective_Action',
        'EUR_RU_Central_Objective' => 'EUR_RU_Central_Objective_Action',
        'EUR_BG_Central_Objective' => 'EUR_BG_Central_Objective_Action',
        'EUR_PT_On_Trade_Central_Promotion' => 'EUR_PT_On_Trade_Central_Promotion',
        'EUR_PT_Off_Trade_Central_Promotion' => 'EUR_PT_Off_Trade_Central_Promotion'
    };

    private static Map<String, String> MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping_ForTest = new Map<String, String>{
        'EUR_BG_Central_Promotion' => 'EUR_BG_Modern_Off_Trade_SR_To_Check_Promotion',
        'EUR_PT_Off_Trade_Central_Promotion' => 'EUR_PT_Off_Trade_SR_To_Check_Promotion',
        'EUR_PT_On_Trade_Central_Promotion' => 'EUR_PT_On_Trade_SR_To_Check_Promotion'
    };



    private static Map<Object, Map<Object, Object>> euAccounts_PRS_SegmentationTypeMapForTest = new Map<Object, Map<Object, Object>>{
        // BG RecordTypes
        'EUR_BG_Modern_Off_Trade' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => true },
        'EUR_BG_Traditional_Off_Trade' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => true },
        'EUR_BG_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // BE RecordTypes
        'EUR_BE_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_BE_Off_Trade' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => true },
        //SE RecordType
        'EUR_SE_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        //NL RecordType
        'EUR_NL_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        //IDL RecordTypes
        'EUR_IDL_On_Trade_Account' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_IDL_Off_Trade_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        'EUR_IDL_Wholesaler_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        //DB RecordTypes
        'EUR_DB_On_Trade_Account' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_DB_Off_Trade_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        'EUR_DB_Wholesaler_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        // IT RecordTypes
        'EUR_IT_On_Trade_Account' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_IT_Off_Trade_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => true },
        'EUR_IT_Wholesaler_Account' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        // DE Record Types
        'EUR_DE_On_Trade_Hotel' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_DE_On_Trade_Gastronomy' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_DE_On_Trade_System_Gastronomy' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // DK Record Types
        'EUR_DK_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // AT Record Types
        'EUR_AT_ON_Gastronomy' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_AT_ON_System_Gastronomy' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_AT_ON_Hotel' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // FI Record Types
        'EUR_FI_Direct_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_FI_Direct_Off_Trade' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        'EUR_FI_Indirect_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_FI_Indirect_Off_Trade' => new Map<Object, Object>{ 'isPROS' => false, 'isPROFS' => false },
        // CH Record Types
        'EUR_CH_ON_HORECA' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        'EUR_CH_ON_Hotel' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // RU Record Types
        'EUR_RU_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false },
        // MA Record Types
        'EUR_MA_On_Trade' => new Map<Object, Object>{ 'isPROS' => true, 'isPROFS' => false }
    };

	private static Map<Object, Map<Object, Object>> groupOutletTypeToOutletType_ForTest = new Map<Object, Map<Object, Object>>{
		'EUR_LT_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_LT_Outlet_Type',
			'countrycode' => 'LT'
		},
		'EUR_LV_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_LV_Outlet_Type',
			'countrycode' => 'LV'
		},
		'EUR_CZ_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_CZ_Outlet_Type',
			'countrycode' => 'CZ'
		},
		'EUR_SK_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_SK_Outlet_Type',
			'countrycode' => 'SK'
		},
		'EUR_GB_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_GB_Outlet_Type',
			'countrycode' => 'GB'
		},
		'EUR_PRT_GroupOutletType' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_PRT_OutletType',
			'countrycode' => 'PRT'
		},
		'EUR_PRT_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_PRT_OutletType',
			'countrycode' => 'PRT'
		},
		'EUR_EE_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_EE_Outlet_Type',
			'countrycode' => 'EE'
		},
		'EUR_AT_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_AT_Outlet_Type',
			'countrycode' => 'AT'
		},
		'EUR_DE_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_DE_Outlet_Type',
			'countrycode' => 'DE'
		},
		'EUR_E1_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_E1_Outlet_Type',
			'countrycode' => 'E1'
		},
		'EUR_AO_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_AO_Outlet_Type',
			'countrycode' => 'AO'
		},
		'EUR_KE_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_KE_Outlet_Type',
			'countrycode' => 'KE'
		},
		'EUR_FI_Group_Outlet' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_FI_Outlet_Type',
			'countrycode' => 'FI'
		},
		'EUR_NG_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_NG_Outlet_Type',
			'countrycode' => 'FI'
		},
		'EUR_MA_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_MA_Outlet_Type',
			'countrycode' => 'MA'
		},
		'EUR_RU_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_RU_Outlet_Type',
			'countrycode' => 'RU'
		},
		'EUR_CH_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_CH_Outlet_Type',
			'countrycode' => 'CH'
		},
		'EUR_ZA_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_ZA_Outlet_Type',
			'countrycode' => 'ZA'
		},
		'EUR_DK_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_DK_Outlet_Type',
			'countrycode' => 'DK'
		},
		'EUR_BG_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_BG_Outlet_Type',
			'countrycode' => 'BG'
		},
		'EUR_PT_Group_Outlet_Type' => new Map<Object, Object>{
			'DeveloperName' => 'EUR_PT_Outlet_Type',
			'countrycode' => 'PT'
		}
	};

	private static Map<Object, Map<Object, Object>> countryCodeToRenderInfoMap_ForTest = new Map<Object, Map<Object, Object>>{
		'RU' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'MA' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'ZA' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'NG' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'AO' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true
		}, 'KE' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true
		}, 'E1' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true
		}, 'DE' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isNumberedAccountPlanRendered' => true
		}, 'AT' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isNumberedAccountPlanRendered' => true
		}, 'EE' => new Map<Object, Object>{
			'isSetImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true,
			'isProsWeightRendered' => true
		}, 'FI' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isProsWeightRendered' => true
		}, 'SK' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isNumberedAccountPlanRendered' => true
		}, 'GB' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isNumberedAccountPlanRendered' => true,
			'isProsWeightRendered' => true
		}, 'CZ' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isNumberedAccountPlanRendered' => true
		}, 'LV' => new Map<Object, Object>{
			'isSetImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true,
			'isProsWeightRendered' => true
		}, 'LT' => new Map<Object, Object>{
			'isSetImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isAccountPlanRendered' => true,
			'isProsWeightRendered' => true
		}, 'CH' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'DK' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true
		}, 'BG' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isProsWeightRendered' => true
		}, 'PRT' => new Map<Object, Object>{
			'isVolumePotentialRendered' => true
		}, 'PT' => new Map<Object, Object>{
			'isImageLevelRendered' => true,
			'isVolumePotentialRendered' => true,
			'isProsWeightRendered' => true
		}
	};
	
	private static Map<Object, Map<Object, Object>> countryCodeToFlowRenderInfoMap_ForTest = new Map<Object, Map<Object, Object>>{
		'RU' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Russia',
			'isFlowRendered' => true
		}, 'ZA' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard South Africa(ZA)',
			'isFlowRendered' => true
		}, 'NG' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Nigeria(NG)',
			'isFlowRendered' => true
		}, 'FI' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Finland(FI)',
			'isFlowRendered' => true
		}, 'KE' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Kenya (KE)',
			'isFlowRendered' => true
		}, 'AO' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Angola(AO)',
			'isFlowRendered' => true
		}, 'DE' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Germany',
			'isFlowRendered' => true
		}, 'EE' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Estonia',
			'isFlowRendered' => true
		}, 'GB' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Great Britain',
			'isFlowRendered' => true
		}, 'LV' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Latvia',
			'isFlowRendered' => true
		}, 'LT' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Lithuania',
			'isFlowRendered' => true
		}, 'PRT' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Portugal',
			'isFlowRendered' => true
		}, 'MA' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Morocco',
			'isFlowRendered' => true
		}, 'CH' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Switzerland',
			'isFlowRendered' => true
		}, 'DK' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Denmark',
			'isFlowRendered' => true
		}, 'BG' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Bulgaria',
			'isFlowRendered' => true
		}, 'PT' => new Map<Object, Object>{
			'countryName' => 'Pernod Ricard Portugal',
			'isFlowRendered' => true
		}
	};

	private static Map<Object, Map<Object, Object>> RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues_ForTest = new Map<Object, Map<Object, Object>>{
		'EUR_DK_Route_Template' => new Map<Object, Object>{
			'EUR_CRM_Max_Planning_Period_Week__c' => 12, 'EUR_CRM_Planning_Period__c' => 12, 'EUR_CRM_Reminder_Day__c' => 5
		},
		'EUR_PT_Route_Template' => new Map<Object, Object>{
			'EUR_CRM_Max_Planning_Period_Week__c' => 52, 'EUR_CRM_Planning_Period__c' => 4, 'EUR_CRM_Reminder_Day__c' => 5
		}
	};

    static {
        if (Test.isRunningTest()) {

            //Create EUR_CRM_RecordTypeMultilevelMap__mdt for tests
            EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(
                CURRENT_CLASS_NAME, 'euAccounts_PRS_SegmentationTypeMap', euAccounts_PRS_SegmentationTypeMapForTest));

			EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(
                CURRENT_CLASS_NAME, 'groupOutletTypeToOutletType', groupOutletTypeToOutletType_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(
                CURRENT_CLASS_NAME, 'countryCodeToRenderInfoMap', countryCodeToRenderInfoMap_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(
                CURRENT_CLASS_NAME, 'countryCodeToFlowRenderInfoMap', countryCodeToFlowRenderInfoMap_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(
                CURRENT_CLASS_NAME, 'RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues', RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues_ForTest));

            //Create EUR_CRM_Record_Type_List_mdt for tests
            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'MassUpdateOPAcctMap_validRecordTypes', MassUpdateOPAcctMap_validRecordTypesForTest));

            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet', ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ListingTemplateHandler_templateCriteriaAccountRecordTypeSet', ListingTemplateHandler_templateCriteriaAccountRecordTypeSet_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_segmentationRecordTypes', ListingTemplateAssignmentHandler_segmentationRecordTypes_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'SegmentationRecordtypesWithoutOutletTypes', SegmentationRecordtypesWithoutOutletTypes_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_classificationRecordTypes', ListingTemplateAssignmentHandler_classificationRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'AT_Action_Trigger_validRT', AT_Action_Trigger_validRT_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'SalesRepOrderAssignAutoNumber_validRecordTypes', SalesRepOrderAssignAutoNumber_validRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'AccountAssignAutoNumber_validRecordTypes', AccountAssignAutoNumber_validRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'OutletToSupplierHandler_validRecordTypes', OutletToSupplierHandler_validRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ForceImageLevelHandler_validRecordTypes', ForceImageLevelHandler_validRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'ForcePRSegDimensionsHandler_validRecordTypes', ForcePRSegDimensionsHandler_validRecordTypes_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(
                CURRENT_CLASS_NAME, 'StockUpdate_validRecordTypes', StockUpdate_validRecordTypes_ForTest));


            //Create EUR_CRM_Record_Type_Map__mdt for tests
            EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
                CURRENT_CLASS_NAME, 'SurveyControllerExt_recordTypeMapping', SurveyControllerExt_recordTypeMappingForTest));

            EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
                CURRENT_CLASS_NAME, 'SurveyControllerExt_surveyHeaderRecordTypeMapping', SurveyControllerExt_surveyHeaderRecordTypeMapping_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
                CURRENT_CLASS_NAME, 'SurveyControllerExt_surveyQuestionRecordTypeMapping', SurveyControllerExt_surveyQuestionRecordTypeMapping_ForTest));

			EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
				CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap', ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
                CURRENT_CLASS_NAME, 'MassDistrObjectiveCtrller_rtMapping', MassDistrObjectiveCtrller_rtMapping_ForTest));

            EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(
                CURRENT_CLASS_NAME, 'MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping', MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping_ForTest));


        }
    }

    // Maps Pros Segmentation Record type developer name and its Id
    global static Map<String, Id> prosSegmentationRecordTypeMap;
    // Maps PR Segmentation Record type developer name and its Id
    global static Map<String, Id> prSegmentationRecordTypeMap;
    // Maps Country code to another map to determine whether to render image level button and/or volume potential button
    global static Map<String, Map<String, Boolean>> countryCodeToRenderInfoMap;
    // Maps Country code to another map to determine which workflow a particular affiliate needs to render
    global static Map<String, Map<String, Object>> countryCodeToFlowRenderInfoMap;
    // Maps Territory Ids to its corresponding territory
    global static Map<Id, EUR_CRM_Territory__c> territoryMap;
    // Maps Group Outlet Type recordtype with Outlet Type recordtypes and country codes
    global static Map<String, Map<String, String>> groupOutletTypeToOutletType;


    /**
    *   Map: ObjectivePromoHandler_opActionMap
    *   Maps valid O/P Record Type Names to its Actions List Templates
    *   Used in EUR_CRM_ObjectivePromoHandler
    **/
    //Todo: this variable only used in tests, EUR_CRM_ObjectivePromoHandler used itself variable
    global static Map<String, String> ObjectivePromoHandler_opActionMap = new Map<String, String>{
            'EUR_RU_Off_Trade_Discount_Campaign' => 'RU_OFF_Discount_Campaign',
            'EUR_RU_Off_Trade_InStore_Media_POSM_Control' => 'RU_OFF_Instore_Media_POSM_Control',
            'EUR_RU_Off_Trade_Leaflet_Campaign' => 'RU_OFF_Leaflet_Campaign',
            'EUR_RU_Off_Trade_Loyalty_POSM_Placement' => 'RU_OFF_Loyalty_POSM_Placement',
            'EUR_RU_Off_Trade_Model_Store' => 'RU_OFF_Model_Store',
            'EUR_RU_Off_Trade_On_Site_Promo_Activities' => 'RU_OFF_On_Site_Promo_Activities',
            'EUR_RU_Off_Trade_Outlet_Staff_Incentive' => 'RU_OFF_Outlet_Staff_Incentive',
            'EUR_RU_Off_Trade_POSM_Placement' => 'RU_OFF_POSM_Placement',
            'EUR_RU_Off_Trade_Sales_Rep_Competition' => 'RU_OFF_Sales_Rep_Competition',
            'EUR_RU_Off_Trade_Stop_Rayon' => 'RU_OFF_Stop_Rayon',
            'EUR_RU_ON_Trade_Phase_1' => 'RU_ON_Promo_Phase_1',
            'EUR_RU_ON_Trade_Phase_2' => 'RU_ON_Promo_Phase_2',

            // DK Record Types
            'EUR_DK_Off_Trade_Leaflet_Campaign' => 'DK_OFF_LeafletCampaign',
            'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays' => 'DK_OFF_SalesDrive_SKU_Displays',
            'EUR_DK_Off_2nd_Placement_Sell_In_Qty_Promo_Display' => 'DK_OFF_2ndPlacement_PromoDisplay',
            'EUR_DK_Off_Trade_Distribution_Drive' => 'DK_OFF_DistributionDrive',
            'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons' => 'DK_OFF_SalesDrive_SKU_Cartons',
            'EUR_DK_Off_Trade_Secondary_Placement_Standard' => 'DK_OFF_2ndPlacement_Standard',
            'EUR_DK_Off_Trade_Secondary_Placement_Carton' => 'DK_OFF_2ndPlacement_Carton',
            'EUR_DK_Off_Trade_Secondary_Placement_Gondola_End' => 'DK_OFF_2ndPlacement_Gondola',
            'EUR_DK_Off_Trade_Secondary_Placement_Theme' => 'DK_OFF_2ndPlacement_Theme',
            'EUR_DK_Off_Trade_Tasting_Campaign' => 'DK_OFF_Tasting_Campaign',
            'EUR_DK_Off_Trade_EM_Price_Promotion' => 'DK_OFF_EffectsManager_Price_Promotion',
            'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles' => 'DK_OFF_SalesDrive_SKU_Bottles',

            'EUR_BE_Off_Trade_Sales_Drive' => 'BE_Off_Trade_Sales_Drive',
            'EUR_BE_Off_Trade_Secondary_placement_Spyder_display' => 'BE_Off_Trade_Secondary_placement_Spyder_display',
            'EUR_BE_On_Trade_Promo_Kit_Activation' => 'BE_On_Trade_Promo_Kit_Activation',
            'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist' => 'BE_On_Trade_Display_Placement_For_Special_Cavist'

    };

    /**
    *   Set: MassUpdateOPAcctMap_validRecordTypes
    *   Lists valid record types for mass update OP Account Mapping Scheduled Batch jobs
    *   Used in multiple EUR_CRM_MassUpdateOPAcctMap classes
    **/
    global static Set<String> MassUpdateOPAcctMap_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'MassUpdateOPAcctMap_validRecordTypes');


    /**
    *   Map: SurveyControllerExt_recordTypeMapping
    *   Maps Survey Header to Questions
    *   Used in EUR_CRM_SurveyControllerExt
    *    'EUR_ZA_OFF_Trade_Survey_Header'                =>'EUR_ZA_OFF_Trade_Sales_Rep_Question',
    *    'EUR_ZA_ON_Trade_Survey_Header'                 =>'EUR_ZA_ON_Trade_Sales_Rep_Question',
    *    'EUR_ZA_Sales_Manager_Survey_Header'            =>'EUR_ZA_Sales_Manager_Question',
    *    'EUR_ZA_Regional_Sales_Manager_Survey_Header'   =>'EUR_ZA_Regional_Sales_Manager_Question',
    *    'EUR_ZA_General_Manager_Survey_Header'          =>'EUR_ZA_General_Manager_Question',
    *    'EUR_ZA_Capability_Manager_Survey_Header'       =>'EUR_ZA_Capability_Manager_Question',
    *    'EUR_ZA_Admin_Survey_Header'                    =>'EUR_ZA_Admin_Question',
    **/
    global static Map<String, String> SurveyControllerExt_recordTypeMapping = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        CURRENT_CLASS_NAME, 'SurveyControllerExt_recordTypeMapping');


    /**
    *   Map: SurveyControllerExt_surveyHeaderRecordTypeMapping
    *   Maps survey headers to survey
    *   Used in EUR_CRM_SurveyControllerExt
    *    'EUR_ZA_OFF_Trade_Survey_Header'                =>'EUR_ZA_OFF_Trade_Sales_Rep_Survey',
    *    'EUR_ZA_ON_Trade_Survey_Header'                 =>'EUR_ZA_ON_Trade_Sales_Rep_Survey',
    *    'EUR_ZA_Sales_Manager_Survey_Header'            =>'EUR_ZA_Sales_Manager_Survey',
    *    'EUR_ZA_Regional_Sales_Manager_Survey_Header'   =>'EUR_ZA_Regional_Sales_Manager_Survey',
    *    'EUR_ZA_General_Manager_Survey_Header'          =>'EUR_ZA_General_Manager_Survey',
    *    'EUR_ZA_Capability_Manager_Survey_Header'       =>'EUR_ZA_Capability_Manager_Survey',
    *    'EUR_ZA_Admin_Survey_Header'                    =>'EUR_ZA_Admin_Survey',
    **/
    global static Map<String, String> SurveyControllerExt_surveyHeaderRecordTypeMapping = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        CURRENT_CLASS_NAME, 'SurveyControllerExt_surveyHeaderRecordTypeMapping');


    /**
    *   Map: SurveyControllerExt_surveyQuestionRecordTypeMapping
    *   Maps survey headers to survey questions
    *   Used in EUR_CRM_SurveyControllerExt
    *    'EUR_ZA_OFF_Trade_Survey_Header'                =>'EUR_ZA_OFF_Trade_Sales_Rep_Survey_Question',
    *    'EUR_ZA_ON_Trade_Survey_Header'                 =>'EUR_ZA_ON_Trade_Sales_Rep_Survey_Question',
    *    'EUR_ZA_Regional_Sales_Manager_Survey_Header'   =>'EUR_ZA_Regional_Sales_Manager_Question',
    *    'EUR_ZA_General_Manager_Survey_Header'          =>'EUR_ZA_General_Manager_Survey_Question',
    *    'EUR_ZA_Capability_Manager_Survey_Header'       =>'EUR_ZA_Capability_Manager_Survey_Question',
    *    'EUR_ZA_Sales_Manager_Survey_Header'            =>'EUR_ZA_Sales_Manager_Survey_Question',
    *    'EUR_ZA_Admin_Survey_Header'                    =>'EUR_ZA_Admin_Survey_Question',
    **/
    global static Map<String, String> SurveyControllerExt_surveyQuestionRecordTypeMapping = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        CURRENT_CLASS_NAME, 'SurveyControllerExt_surveyQuestionRecordTypeMapping');


    /**
    *   Set: ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet
    *   Lists all account record types that will process listing template through customer taxonomy
    *   Used in EUR_CRM_ListingTemplateHandler
    **/
    global static Set<String> ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet');


    /**
    *   Set: ListingTemplateHandler_templateCriteriaAccountRecordTypeSet
    *   Lists all account record types that will process listing template through template criteria
    *   Used in EUR_CRM_ListingTemplateHandler
    **/
    global static Set<String> ListingTemplateHandler_templateCriteriaAccountRecordTypeSet = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'ListingTemplateHandler_templateCriteriaAccountRecordTypeSet');


    /**
    *   Map: ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap
    *   Maps Account record types to its corresponding Template Criteria Record type
    *   Affiliates: AO, KE, FI, NG, ZA
    *   Used in EUR_CRM_ListingTemplateAssignmentHandler
    **/
    global static Map<String, String> ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
		CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_templateCriteriaRecordTypeMap');


    /**
    *   Set: ListingTemplateAssignmentHandler_segmentationRecordTypes
    *   Lists Account record types that use PROS Segmentation
    *   Used in EUR_CRM_ListingTemplateAssignmentHandler
    **/
    global static Set<String> ListingTemplateAssignmentHandler_segmentationRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_segmentationRecordTypes');


    global static Set<String> SegmentationRecordtypesWithoutOutletTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'SegmentationRecordtypesWithoutOutletTypes');


    /**
    *   Set: ListingTemplateAssignmentHandler_classificationRecordTypes
    *   Lists Account record types that use classifications
    *   Used in EUR_CRM_ListingTemplateAssignmentHandler
    **/
    global static Set<String> ListingTemplateAssignmentHandler_classificationRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME, 'ListingTemplateAssignmentHandler_classificationRecordTypes');


    /**
    *   Map: MassDistrObjectiveCtrller_rtMapping
    *   Maps Central Objective Record types to Central Objective Actions Record types
    *   Used in EUR_CRM_MassDistrObjectiveCtrller controller
    **/
    global static Map<String, String> MassDistrObjectiveCtrller_rtMapping = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        CURRENT_CLASS_NAME, 'MassDistrObjectiveCtrller_rtMapping');


    /**
    * Map: MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping
    * Maps Central Objective Record types to Visit Action Record Types
    * For special cases where publishing Central objectives yields Visit Actions instead
    * Used in EUR_CRM_MassDistrObjectiveCtrller controller
    **/
    global static Map<String, String> MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        CURRENT_CLASS_NAME, 'MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping');


    /**
    *   Set: AT_Action_Trigger_validRT
    *   Lists valid central objective action record types
    *   Used in EUR_CRM_AT_Action_Trigger trigger
    **/
    global static Set<String> AT_Action_Trigger_validRT = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'AT_Action_Trigger_validRT');


//    /**
//    *   Set: TerritoryOwnerChanged_validRecordTypes
//    *   Lists all valid Territory Record Types to be processed
//    *   Used in EUR_CRM_TerritoryOwnerChanged Trigger Class
//    **/
//    global static Set<String> TerritoryOwnerChanged_validRecordTypes = new Set<String>{
//            'EUR_FI_Territory',
//            'EUR_MA_Territory',
//            'EUR_RU_OFF_Trade_Territory',
//            'EUR_RU_ON_Trade_Territory',
//            'EUR_RU_ON_OFF_Trade_Territory',
//            'EUR_CH_Territory',
//            'EUR_DK_Territory',
//            'EUR_BG_Territory',
//            'EUR_PT_Territory',
//            'EUR_BE_Territory',
//            'EUR_DE_Territory',
//            'EUR_SE_Territory',
//            'EUR_NL_Territory',
//            'EUR_NL_Wholesaler',
//            'EUR_NL_Off_Trade_Independent',
//            'EUR_NL_Off_Trade_Chains'
//    };

    /**
    *   Set: SalesRepOrderAssignAutoNumber_validRecordTypes
    *   Lists valid Sales Rep Order record types to be processed
    *   Used in EUR_CRM_SalesRepOrderAssignAutoNumber trigger class
    **/
    global static Set<String> SalesRepOrderAssignAutoNumber_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'SalesRepOrderAssignAutoNumber_validRecordTypes');


    /**
    *   Set: AccountAssignAutoNumber_validRecordTypes
    *   Lists valid EU Account record types to be processed
    *   Used in EUR_CRM_AccountAssignAutoNumber trigger class
    **/
    global static Set<String> AccountAssignAutoNumber_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'AccountAssignAutoNumber_validRecordTypes');


    /**
    *   Set: SalesOrderAssignAutoNumber_validRecordTypes
    *   Lists valid Sales Order record types to be processed
    *   Used in EUR_CRM_SalesOrderAssignAutoNumber trigger class
    **/
	//Todo: this variable used in EUR_CRM_SalesOrderAssignAutoNumber but class commented out in the EUR_CRM_Sales_Order_BeforeInsert.trigger
    global static Set<String> SalesOrderAssignAutoNumber_validRecordTypes = new Set<String>{
            'EUR_DE_OFF_Free_Goods_Directly_to_Customer_Sales_Order',
            'EUR_DE_OFF_Free_Goods_from_SR_Stock_to_Customer_Sales_Order',
            'EUR_DE_OFF_Standard_Goods_Sales_Order',
            'EUR_DE_ON_Free_Goods_Directly_to_Customer_Sales_Order',
            'EUR_DE_ON_Free_Goods_from_SR_Stock_to_Customer_Sales_Order',
            'EUR_DE_ON_Standard_Goods_Sales_Order',
            'EUR_GB_Indies_Sales_Order',
            'EUR_JB_Sales_Order',
            'EUR_AO_Direct_Sales_Order',
            'EUR_AO_Indirect_Sales_Order',
            'EUR_AO_Order_Reminder',
            'EUR_KE_Direct_Sales_Order',
            'EUR_KE_Indirect_Sales_Order',
            'EUR_KE_Order_Reminder',
            'EUR_NG_Off_Trade_Modern_Sales_Order',
            'EUR_NG_Off_Trade_Traditional_Sales_Order',
            'EUR_NG_On_Trade_Sales_Order',
            'EUR_NG_On_Trade_Reminder',
            'EUR_ZA_Direct_Sales_Order',
            'EUR_ZA_Free_Goods_Order',
            'EUR_MA_Direct_On_Trade_Reminder',
            'EUR_MA_Direct_On_Trade_Sales_Order',
            'EUR_MA_Indirect_Off_Trade_Sales_Order',
            'EUR_MA_Indirect_On_Trade_Reminder',
            'EUR_MA_Indirect_On_Trade_Sales_Order',
            'EUR_MA_Indirect_Regional_WS_Sales_Order',
            'EUR_CH_Reminder',
            'EUR_CH_Indirect_Sales_Order',
            'EUR_CH_Direct_Sales_Order',
            'EUR_RU_On_Trade_Sales_Order',
            'EUR_NG_Off_Trade_Bulk_Breaker_Sales_Order',
            'EUR_DK_Direct_Sales_Order',
            'EUR_DK_Free_Goods_Order_to_Customer',
            'EUR_DK_Free_Goods_Order_from_SR_Stock',
            'EUR_DK_Reminder',

            // BG RecordTypes
            'EUR_BG_Direct_Sales_Order',
            'EUR_BG_Indirect_Sales_Order',
            'EUR_BG_Marketing_Product_Sales_Order',
            'EUR_BG_Order_Reminder',

            // PT RecordTypes
            'EUR_PT_Indirect_On_Trade_Sales_Order',

            //SE RecordTypes
            'EUR_SE_Direct_Sales_Order',
            'EUR_SE_Free_Goods_Order_from_SR_Stock',
            'EUR_SE_Free_Goods_Order_to_Customer',
            'EUR_SE_Indirect_Sales_Order',

            //NL RecordTypes
            'EUR_NL_Direct_Sales_Order',
            'EUR_NL_Indirect_Off_Trade_Sales_Order',
            'EUR_NL_Indirect_Off_Trade_Sales_Order_Item_PR_Delivery',
            'EUR_NL_Indirect_On_Trade_Sales_Order'
    };

    /**
    *   Set: OutletToSupplierHandler_validRecordTypes
    *   Lists valid account record types to be processed by outlet supplier handler
    *   Used in EUR_CRM_OutletToSupplierHandler trigger class
    **/
    global static Set<String> OutletToSupplierHandler_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'OutletToSupplierHandler_validRecordTypes');


    /**
    *   Set: AssignAccountOwnerHandler_accountRecordTypeSet
    *   Lists valid account record types to be processed by account owner territory
    *   Used in EUR_CRM_AssignAccountOwnerHandler trigger class
    **/
	//Todo: EUR_CRM_AssignAccountOwnerHandler don't used in EUR_CRM_AccountTriggerhandler.cls
    global static Set<String> AssignAccountOwnerHandler_accountRecordTypeSet = new Set<String>{
            'EUR_RU_On_Trade',
            'EUR_RU_Direct_Off_Trade',
            'EUR_RU_Direct_Type_2_Off_Trade',
            'EUR_RU_Distribution_Center',
            'EUR_RU_Distributor',
            'EUR_RU_Indirect_Off_Trade',
            'EUR_MA_On_Trade',
            'EUR_MA_Off_Trade',
            'EUR_MA_Distributor',
            'EUR_CH_C_C_Indirect',
            'EUR_CH_C_C_and_WHS_Direct',
            'EUR_CH_Horeca_Direct',
            'EUR_CH_Horeca_Indirect',
            'EUR_CH_Off_Trade_Direct',
            'EUR_CH_Off_Trade_Indirect',
            'EUR_DK_OFF_Trade',
            'EUR_DK_On_Trade',
            'EUR_DK_Wholesaler',
            'EUR_BG_Modern_Off_Trade',
            'EUR_BG_Traditional_Off_Trade',
            'EUR_BG_Wholesaler',
            'EUR_BG_On_Trade',

            // PT Recordtypes
            'EUR_PT_CandCs',
            'EUR_PT_Off_Trade',
            'EUR_PT_Wholesaler',
            'EUR_PT_On_Trade',

            // BE RecordTypes
            'EUR_BE_On_Trade',
            'EUR_BE_Off_Trade',
            'EUR_BE_B2B',
            'EUR_BE_Wholesaler'
    };


    /**
    *   Map: euAccounts_PRS_SegmentationTypeMap
    *   Maps EU Account's RecordTypes to the type of segmentation to be used by the PRS module
    *   Used in EUR_CRM_EUAccountCreatePRSegHandler for creating PRS Segmentation records
    *   Also used in EUR_CRM_PRSegmentationPageController and EUR_CRM_PRS_QuestionsSheetController controllers to determine type of segmentation
    **/
    global static Map<String, Map<String, Boolean>> euAccounts_PRS_SegmentationTypeMap =
		EUR_CRM_RecordTypeHelper_v2.getBooleanByStringByString(EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(
        CURRENT_CLASS_NAME, 'euAccounts_PRS_SegmentationTypeMap'));


    /**
    *   Set: ForceImageLevelHandler_validRecordTypes
    *   Lists valid account record types to be processed for the Force Image Level feature
    *   Used in EUR_CRM_ForceImageLevelHandler trigger class
    **/
    global static Set<String> ForceImageLevelHandler_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'ForceImageLevelHandler_validRecordTypes');



    /**
    *   Set: ForcePRSegDimensionsHandler_validRecordTypes
    *   Lists valid account record types to be processed for the Force PRS Dimension handler
    *   Used in EUR_CRM_ForcePRSegDimensionsHandler trigger class
    **/
    global static Set<String> ForcePRSegDimensionsHandler_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'ForcePRSegDimensionsHandler_validRecordTypes');


    /**
    *   Set: StockUpdate_validRecordTypes
    *   Lists valid stock record types to be processed for creating Stock line items from sales order line item and salesRep order line items
    *   Used in EUR_CRM_StockUpdateFromSO and EUR_CRM_StockUpdateFromSRO trigger classes
    *   Remove:'EUR_DE_Free_Goods_Order_from_SR_Stock'
    *   Remove:'EUR_DE_Free_Goods_Order_to_SR_Stock'
    *
    **/
    global static Set<String> StockUpdate_validRecordTypes = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		CURRENT_CLASS_NAME, 'StockUpdate_validRecordTypes');


    /**
    *   Set: RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues
    *   Lists valid route template record types to be processed for setting default values
    *   Used in EUR_CRM_RouteTemplate_SetDefaultValues trigger classes
    **/
    global static Map<String, Map<String, Integer>> RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues = EUR_CRM_RecordTypeHelper_v2.getIntegerByStringByString(
		EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(CURRENT_CLASS_NAME, 'RouteTemplate_SetDefaultValues_ValidRecordTypesAndDefaultValues'));
    


//    /**
//    *  Set: EnablePriceCheckBatch_validRecordTypes
//    *  Lists the valid account recordtypes to be process by the price check enabler batch file
//    *  User in: EUR_CRM_EnablePriceCheckBatch batch file
//    */

//	// EUR_CRM_EnablePriceCheckBatch use itself variable
//    global static Set<String> EnablePriceCheckBatch_validRecordTypes = new Set<String>{
//            'EUR_DK_Off_Trade',
//
//            // RU RecordTypes
//            'EUR_RU_Direct_Off_Trade',
//            'EUR_RU_Direct_Type_2_Off_Trade',
//            'EUR_RU_Indirect_Off_Trade',
//
//            // BE RecordTypes
//            'EUR_BE_Off_Trade'
//    };

    /**
    *   Function: getAccountCreateProsSegHandler_RecordTypeId
    *   Input: String developername of the particular record type to be retrieved
    *   Initializes a map of EUR_CRM_Pros_Segmentation__c record types and returns the ID of one record type according to the input
    *   Returns: Id of the desired EUR_CRM_Pros_Segmentation__c record type
    **/
    global static Id getAccountCreateProsSegHandler_RecordTypeId(String countryCode) {
        // Initialize prosSegmentationRecordTypeMap if needed
        if (prosSegmentationRecordTypeMap == null) {
            prosSegmentationRecordTypeMap = new Map<String, Id>();
            List<RecordType> prosRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Pros_Segmentation__c');

            for (RecordType rt : prosRecordTypes) {
                prosSegmentationRecordTypeMap.put(rt.DeveloperName, rt.Id);
            }
        }

        // Strict assumption that the record type is in EUR_[ISO]_PROS_Segmentation format
        String developername = 'EUR_' + countryCode + '_PROS_Segmentation';

        return prosSegmentationRecordTypeMap.get(developername);
    }

    /**
    *   Function: getAccountCreatePRSegHandler_RecordTypeId
    *   Input: String developername of the particular record type of the account
    *   Initializes a map of EUR_CRM_PRS_Segmentation__c record types and returns the ID of one record type according to the input
    *   Returns: Id of the desired EUR_CRM_PRS_Segmentation__c record type
    **/
    global static Id getAccountCreatePRSegHandler_RecordTypeId(String accRTDevName) {
        // Initialize prSegmentationRecordTypeMap if needed
        if (prSegmentationRecordTypeMap == null) {
            prSegmentationRecordTypeMap = new Map<String, Id>();
            List<RecordType> prsRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_PRS_Segmentation__c');

            for (RecordType rt : prsRecordTypes) {
                prSegmentationRecordTypeMap.put(rt.DeveloperName, rt.Id);
            }
        }
        String developername = '';
        System.debug(euAccounts_PRS_SegmentationTypeMap);
        System.debug(accRTDevName);
        if (euAccounts_PRS_SegmentationTypeMap.get(accRTDevName) != null) {
            // Strict assumption that the On Trade accounts always use PROS, and Off Trade always use PROFS
            if (euAccounts_PRS_SegmentationTypeMap.get(accRTDevName).get('isPROS')) {
                developername = 'EUR_PRS_Segmentation_On_Trade';
            } else if (euAccounts_PRS_SegmentationTypeMap.get(accRTDevName).get('isPROFS')) {
                developername = 'EUR_PRS_Segmentation_Off_Trade';
            }
        }

        return prSegmentationRecordTypeMap.get(developername);
    }

    /**
    *   Function: getGroupOutletControllerExt_outletRecordType
    *   Params: grpOutletDevName : The recordtype devName of the group outlet type
    *   Initializes a map of outlet type recordtypes, which will be used to determine which
    *   outlet types to be associated with the newly created group outlet type.
    *   Returns: a Map containing information about the corrosponding outlet type record types and country code
    **/
    global static Map<String, String> getGroupOutletControllerExt_outletRecordType(String grpOutletDevName) {
        if (groupOutletTypeToOutletType == null) {
            groupOutletTypeToOutletType = EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(
				CURRENT_CLASS_NAME, 'groupOutletTypeToOutletType');
        }
        return groupOutletTypeToOutletType.get(grpOutletDevName);
    }

    /**
    *   Function: getProsSegmentationExtCombined_RenderInfo
    *   Input: String countryCode. The 2 digit PR affiliate code
    *   Initializes a map of Pros Segmentation Render information, which will be used to determine whether
    *   a particular affiliate needs image level page and/or volume potential page and/or process account plan page.
    *   Returns: a Map containing information whether to render image level and/or volume potential buttons
    **/
    global static Map<String, Boolean> getProsSegmentationExtCombined_RenderInfo(String countryCode) {
        if (countryCodeToRenderInfoMap == null) {
            countryCodeToRenderInfoMap = EUR_CRM_RecordTypeHelper_v2.getBooleanByStringByString(EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(
				CURRENT_CLASS_NAME, 'countryCodeToRenderInfoMap'));
        }

        return countryCodeToRenderInfoMap.get(countryCode);
    }

    /**
    *   Function: getProsSegmentationExt_FlowInfo
    *   Input: String countryCode. The 2 digit PR affiliate code
    *   Initializes a map of PR Group Outlet type workflow render information. Used to determine
    *   which workflow a particular affiliate needs to render dynamically.
    *   Returns: a Map of variables used in EUR_CRM_ProsSegmentationExt
    **/
    global static Map<String, Object> getProsSegmentationExt_FlowInfo(String countryCode) {
        if (countryCodeToFlowRenderInfoMap == null) {
            countryCodeToFlowRenderInfoMap = EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(
				CURRENT_CLASS_NAME, 'countryCodeToFlowRenderInfoMap');
        }
        return countryCodeToFlowRenderInfoMap.get(countryCode);
    }

    /**
    *   Function: getAccountProsSegController_isServicePackRendered
    *   Input: String countryCode. The 2 digit PR affiliate code
    *   Initializes a map that checks if service pack is enabled for a particular affiliate
    *   Returns: Boolean whether service pack is enabled or not
    **/
	//Todo: variable used for old EUR_CRM_Account_ProsSegSectionPageCntry.page
    global static Boolean getAccountProsSegController_isServicePackRendered(String countryCode) {
        Set<String> availableAffiliates = new Set<String>{
                'AO', 'KE', 'DE', 'GB', 'LT', 'LV', 'PRT', 'JB',
                'CZ', 'SK', 'EE', 'AT', 'E1'
        };

        return availableAffiliates.contains(countryCode);
    }

    /**
    *   Function: getAssignAccoutnOwnerHandler_initTerritoryMap
    *   Input: Set territoryIds
    *   Initializes a map of territory Id to territory object, and stores it internally
    *   Used to determine account owner based on the territory
    *   Returns: void
    **/
    global static void getAssignAccountOwnerHandler_initTerritoryMap(Set<Id> territoryIds) {
        System.debug(territoryIds);
        if (territoryMap == null) {
            territoryMap = new Map<Id, EUR_CRM_Territory__c>([
                    SELECT Id, Name, EUR_CRM_Territory_Owner__c, EUR_CRM_Territory_Owner__r.Id,
                            EUR_CRM_Off_Trade_Owner__c, EUR_CRM_On_Trade_Owner__c
                    FROM EUR_CRM_Territory__c
                    WHERE Id IN :territoryIds
            ]);
        }
    }

    /**
    *   Function: getAssignAccountOwnerHandler_ownerId
    *   Input: Account the affected account its RecordType name
    *   Determines account owner based on its affiliate and record types
    *   Returns: Owner Id of the account
    **/

    global static Id getAssignAccountOwnerHandler_ownerId(EUR_CRM_Account__c acc, String recordTypeDeveloperName) {

        Id result;

        if (acc != null && territoryMap != null) {

            Id eurCrmTerritoryOwner;
            EUR_CRM_Territory__c territory = territoryMap.get(acc.EUR_CRM_Territory__c);

            if (acc.EUR_CRM_Territory__c != null && territory != null) {
                eurCrmTerritoryOwner = territory.EUR_CRM_Territory_Owner__c;
            }

            if (acc.EUR_CRM_Country_Code__c == 'RU') {
                result = eurCrmTerritoryOwner;
            } else if (acc.EUR_CRM_Territory__c != null) {

                if (acc.EUR_CRM_Country_Code__c == 'MA') {
                    // Make on Trade Owner of territory the account owner for MA ON Trade RecordTypes
                    if (recordTypeDeveloperName == 'EUR_MA_On_Trade') {
                        result = territory.EUR_CRM_On_Trade_Owner__c;
                    } else if (recordTypeDeveloperName == 'EUR_MA_Off_Trade' || recordTypeDeveloperName == 'EUR_MA_Distributor') {
                        // Else, for OFF Trade accounts, make the OFF Trade owner the owner of this account
                        // For Distributor accounts, make the OFF trade owner the owner
                        result = territory.EUR_CRM_Off_Trade_Owner__c;
                    }
                } else if (new Set<String>{
                        'CH', 'DK', 'BG', 'BE', 'PT'
                }.contains(acc.EUR_CRM_Country_Code__c)) {
                    result = eurCrmTerritoryOwner;
                }

            }
        }

        return result;
    }


	// old code, new one created by Vladimir Davydko

    /*global static Id getAssignAccountOwnerHandler_ownerId(EUR_CRM_Account__c acc, String recordTypeDeveloperName) {
        if(acc.EUR_CRM_Country_Code__c == 'RU') {
            if(acc.EUR_CRM_Territory__c != null && territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__c != null) {
                return territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__r.Id;
            }
        } else if(acc.EUR_CRM_Country_Code__c == 'MA'){
            if(acc.EUR_CRM_Territory__c != null) {
                // Make on Trade Owner of territory the account owner for MA ON Trade RecordTypes
                if(recordTypeDeveloperName == 'EUR_MA_On_Trade') {

                    return territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_On_Trade_Owner__c;
                } else if(recordTypeDeveloperName == 'EUR_MA_Off_Trade') {

                    // Else, for OFF Trade accounts, make the OFF Trade owner the owner of this account
                    return territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Off_Trade_Owner__c;
                } else if(recordTypeDeveloperName == 'EUR_MA_Distributor') {

                    // For Distributor accounts, make the OFF trade owner the owner
                    return territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Off_Trade_Owner__c;
                }
            }
        } else if(acc.EUR_CRM_Country_Code__c == 'CH' ||
                  acc.EUR_CRM_Country_Code__c == 'DK' ||
                  acc.EUR_CRM_Country_Code__c == 'BG' ||
                  acc.EUR_CRM_Country_Code__c == 'BE' ||
                  acc.EUR_CRM_Country_Code__c == 'PT')
        {
            if(acc.EUR_CRM_Territory__c != null && territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__c != null) {
              return territoryMap.get(acc.EUR_CRM_Territory__c).EUR_CRM_Territory_Owner__r.Id;
            }
        }

        return null;
    }*/
}