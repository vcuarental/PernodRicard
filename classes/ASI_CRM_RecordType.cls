public class ASI_CRM_RecordType {

	public enum ASI_CRM_Payment_Invoice {
			ASI_CRM_JP_SPTD_Cash_Invoice,
			ASI_CRM_JP_SPTD_FOC_Invoice,
			ASI_CRM_JP_Indirect_Rebate_Invoice,
			ASI_CRM_JP_SPTD_FOC_Invoice_Read_Only,
			ASI_CRM_JP_SPTD_Cash_Invoice_Read_Only,
			ASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only,
			ASI_CRM_JP_Cash_Invoice,
			ASI_CRM_JP_Cash_Invoice_Read_Only
	}

	public enum ASI_CRM_Purchase_Contract_Line_Item {
			ASI_CRM_JP_SPTD_Contract_Line_Item,
			ASI_CRM_JP_Direct_Rebate_Contract_Line_Item,
			ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item
	}

	public enum ASI_CRM_Payment_Invoice_Line_Item {
			ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item,
			ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item,
			ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item
	}

	public enum ASI_CRM_Purchase_Contract {
			ASI_CRM_JP_SPTD_Contract,
			ASI_CRM_JP_Indirect_Rebate_Contract,
			ASI_CRM_JP_Direct_Rebate_Contract,
			ASI_CRM_JP_Direct_Rebate_Contract_Read_Only,
			ASI_CRM_JP_Indirect_Rebate_Contract_Read_Only,
			ASI_CRM_JP_SPTD_Contract_Read_Only
	}

	public enum ASI_CRM_JP_Item_Availability {
			ASI_JP_CRM_DF_Item_Availability,
			ASI_JP_CRM_DP_Item_Availability
	}

	public enum ASI_MFM_SKU_Code {
			ASI_HK_CRM_SKU,
			ASI_FOC_CN_SKU,
			ASI_MFM_TW_SKU_Code,
			ASI_MFM_GF_SKU,
			ASI_TH_CRM_SKU,
			ASI_CRM_SG_SKU,
			ASI_CRM_MY_SKU,
			ASI_CRM_JP_SKU,
			ASI_CRM_SG_SO_CA,
			ASI_CRM_SG_SO_LA,
			ASI_CRM_SG_SO_MY,
			ASI_CRM_SG_SO_MM,
			ASI_CRM_SG_SO_PH,
			ASI_CRM_SG_SO_VI,
			ASI_CRM_SG_SO_VIDF,
			ASI_CRM_MO_SKU,
			ASI_FOC_CN_POSM_SKU,
			ASI_CRM_JP_CRM_DF_SKU,
			ASI_CRM_SG_SO_IN,
			ASI_CRM_SG_Gift_Voucher
	}

	public ASI_CRM_RecordType() {

	}

}