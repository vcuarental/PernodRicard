public without sharing class ASI_CTY_CN_Vendor_PO_PRInfo_Controller {
	public List<ASI_CRM_Quotation__c> quotations {get; set;}
	public String poId;

    public ASI_CTY_CN_Vendor_PO_PRInfo_Controller(ApexPages.StandardController con) {
        quotations = new List<ASI_CRM_Quotation__c>();
        poId = con.getId();
    }

    public void init() {
    	ASI_MFM_PO__c po = [SELECT ASI_CTY_CN_Vendor_Quotation__c, 
								   ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Result_Status__c 
							FROM ASI_MFM_PO__c
							WHERE Id = :poId];
    	
		if (po.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Result_Status__c == 'Win-Bid') {
			ASI_CRM_Quotation__c subQ = [SELECT ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c,
												ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name,
												ASI_CTY_CN_Purchase_Request_Line__c,
												ASI_CTY_CN_Purchase_Request_Line__r.Name,
												ASI_CTY_CN_Vendor_Unitl_Price__c,
												ASI_CTY_CN_Vendor_Total_Freight__c,
												ASI_CTY_CN_Vendor_Sample__c,
												ASI_CTY_CN_Vendor_Model__c,
												ASI_CTY_CN_Vendor_Confirmed_Price__c,
												ASI_CTY_CN_Purchase_Request_Line__r.CreatedById,
												ASI_CTY_CN_Purchase_Request_Line__r.CreatedBy.Name,
												Name,
												ASI_CTY_CN_Purchase_Request_Line__r.CreatedDate
										 FROM ASI_CRM_Quotation__c
										 WHERE Id = :po.ASI_CTY_CN_Vendor_Quotation__c];
			quotations.add(subQ);
		}
		if (po.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Result_Status__c == 'Fail-Bid') {
			List<ASI_CRM_Quotation__c> subQList = [SELECT  ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c,
															ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name,
															ASI_CTY_CN_Purchase_Request_Line__c,
															ASI_CTY_CN_Purchase_Request_Line__r.Name,
															Name,
															ASI_CTY_CN_Vendor_Unitl_Price__c,
															ASI_CTY_CN_Vendor_Total_Freight__c,
															ASI_CTY_CN_Vendor_Sample__c,
															ASI_CTY_CN_Vendor_Model__c,
															ASI_CTY_CN_Vendor_Confirmed_Price__c,
															ASI_CTY_CN_Purchase_Request_Line__r.CreatedById,
															ASI_CTY_CN_Purchase_Request_Line__r.CreatedBy.Name,
															ASI_CTY_CN_Purchase_Request_Line__r.CreatedDate
													 FROM ASI_CRM_Quotation__c
													 WHERE ASI_CTY_CN_Vendor_Quotation__c = :po.ASI_CTY_CN_Vendor_Quotation__c];
			quotations.addAll(subQList);
		}
    	
    }
}