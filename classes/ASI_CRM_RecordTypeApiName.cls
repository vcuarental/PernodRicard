public class ASI_CRM_RecordTypeApiName {

	public enum ActualOfftakeHeader {
		ASI_CRM_MY_ActualOfftakeHeader,
		ASI_CRM_MY_Actual_Offtake_Header_Read_Only,
		ASI_CRM_SG_Actual_Offtake_Header,
		ASI_CRM_SG_Actual_Offtake_Header_Upload_Log,
		ASI_CRM_TH_ActualOfftakeHeader,
		ASI_CRM_PH_Actual_Offtake_Header,
		ASI_CRM_PH_Actual_Offtake_Header_Upload_Log
	}

	public enum ActualOfftake {
		ASI_CRM_PH_Actual_Offtake,
		ASI_CRM_VN_Actual_Offtake,
		ASI_CRM_VN_Actual_Offtake_Temporary,
		ASI_TH_CRM_Actual_Offtake,
		ASI_CRM_TW_Actual_Offtake,
		ASI_CRM_TW_Actual_Offtake_Target_Vol
	}

	public enum SkuPriceCost {
		ASI_CRM_PH_Outlet_Selling_Price
	}

	public enum AccountsAdditionalField {
		ASI_TH_CRM_Modern_Trade,
		ASI_TH_CRM_Outlet,
		ASI_TH_CRM_Potential_Outlet,
		ASI_TH_CRM_Wholesaler,
		ASI_CRM_TW_KeyAccount,
		ASI_CRM_TW_Outlet,
		ASI_CRM_TW_Wholesaler,
		ASI_CRM_CN_WS,
		ASI_CRM_Outlet_CN,
		ASI_CRM_VN_Outlet,
		ASI_CRM_VN_PG_Outlets,
		ASI_CRM_VN_Off_Trade_Outlet,
		ASI_CRM_VN_Inactive_Off_Trade_Outlet,
		ASI_MFM_KH_Outlet,
		ASI_CRM_TW_Forecast_Customer,
		ASI_CRM_SG_Outlet,
		ASI_CRM_MY_Outlet,
		ASI_CRM_MY_Wholesaler,
		ASI_CRM_VN_Outlet_Inactive,
		ASI_CRM_KR_Venue,
		ASI_CRM_KR_Wholesaler,
		ASI_CRM_PH_Customer,
		VN_Value_On_Trade_Outlet,
		VN_Value_On_Trade_Outlet_Inactive,
		VN_Value_Off_Trade_Outlet,
		VN_Value_Off_Trade_Outlet_Inactive
	}

	public enum SkuCode {
		ASI_FOC_CN_SKU,
		ASI_MFM_TW_SKU_Code,
		ASI_HK_CRM_SKU,
		ASI_MFM_GF_SKU,
		ASI_TH_CRM_SKU,
		ASI_CRM_VN_SKU,
		ASI_CRM_SG_SKU,
		ASI_CRM_SG_SO_CA,
		ASI_CRM_SG_SO_IN,
		ASI_CRM_SG_SO_LA,
		ASI_CRM_SG_SO_MM,
		ASI_CRM_SG_SO_MY,
		ASI_CRM_SG_SO_PH,
		ASI_CRM_SG_SO_VI,
		ASI_CRM_SG_SO_VIDF,
		ASI_MFM_KR_SKU,
		ASI_CRM_PH_DF_SKU,
		ASI_CRM_PH_DP_SKU
	}

	public enum ASI_CRM_MY_SKUPriceCost {
		ASI_CRM_SG_CRM_FOB_Per_Bottle,
		ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle,
		ASI_CRM_SG_CRM_Duty_Per_Bottle,
		ASI_CRM_SG_IGC,
		ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler,
		ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade,
		ASI_CRM_TW_SKU_Price_Cost,
		ASI_MFM_KR_MFM_SKUPriceCost,
		ASI_KR_CRM_SKUPriceCost,
		ASI_CRM_PH_Outlet_Selling_Price,
		ASI_CRM_PH_List_Price,
		ASI_CRM_PH_Duty_Excise_Tax,
		ASI_CRM_PH_SKU_Handling_Cost,
		ASI_CRM_PH_COGS,
		ASI_CRM_PH_Standard_Cost,
		ASI_CRM_PH_DP_Distribution_Cost
	}

	public enum ASI_TH_CRM_PaymentRequest {
		//ASI_TH_CRM_Payment_Request,
		//ASI_CRM_CN_Payment_Request,
		//ASI_CRM_VN_Payment_Request,
		ASI_CRM_PH_Payment_Request,
		ASI_CRM_PH_Payment_Request_Read_Only
	}

	public enum ASI_CRM_Payment_Schedule {
		ASI_CRM_SG_Payment_Schedule,
		ASI_CRM_SG_Payment_Schedule_Simulation,
		ASI_CRM_PH_Contract_Fund,
		ASI_CRM_PH_Purchase_Incentive
	}

	public enum ASI_TH_CRM_Contract {
		ASI_TH_CRM_Contract,
		ASI_CRM_CN_Contract,
		ASI_CRM_VN_Contract,
		ASI_CRM_VN_Capsule_Contract,
		ASI_CRM_PH_Contract,
		ASI_CRM_PH_Contract_Read_Only
	}

	public enum ASI_TH_CRM_PaymentRequestLineItem {
		ASI_TH_CRM_Payment_Request_Detail,
		ASI_CRM_CN_Payment_Request_Detail_BRSF,
		ASI_CRM_CN_Payment_Request_Detail_Other,
		ASI_CRM_CN_Payment_Request_Detail_PSF,
		ASI_CRM_PH_Payment_Request_Detail
	}

	public enum ASI_CRM_ContractTarget {
		ASI_CRM_MY_ContractTarget,
		ASI_CRM_SG_Contract_Target,
		ASI_CRM_PH_Contract_Target
	}

	public enum ASI_MFM_Budget {
		ASI_MFM_GF_Budget,
		ASI_MFM_HK_Budget,
		ASI_MFM_TW_Budget,
		ASI_MFM_RM_Budget,
		ASI_MFM_JP_Budget,
		ASI_MFM_MY_Budget,
		ASI_MFM_CN_Budget,
		ASI_MFM_TR_Budget,
		ASI_MFM_CAP_Budget,
		ASI_MFM_PH_DF_Budget,
		ASI_MFM_PH_DP_Budget,
		ASI_MFM_KH_Budget,
		ASI_TnE_KH_Budget,
		ASI_MFM_SG_Budget,
		ASI_TnE_PH_Budget,
		ASI_TnE_ID_Budget,
		ASI_TnE_TH_Budget,
		ASI_MFM_TH_Budget,
		ASI_TnE_SG_Budget,
		ASI_TnE_MY_Budget,
		ASI_MFM_KR_Budget,
		ASI_MFM_VN_DF_Budget,
		ASI_MFM_VN_DP_Budget
	}

	public ASI_CRM_RecordTypeApiName() {

	}

}