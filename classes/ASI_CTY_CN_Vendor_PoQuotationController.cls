/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_PoQuotationController       
 * Test Class:  ASI_CTY_CN_Vendor_PoPDFCtlTest
 * Description: PO Quotation Email Body Controller When Send PO Generated Email To Vendor
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-12-04       BLS-HUJINCHAO           Create Class
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PoQuotationController {
	public Id POID {get;set;}
	public ASI_MFM_PO__c po {get;set;}
	public ASI_CRM_Quotation__c q {get;set;}
	// a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

    public ASI_CTY_CN_Vendor_PoQuotationController() {}

    public void initDate() {
        POID = ApexPages.currentPage().getParameters().get('po_id');
        dummyVar = Boolean.valueOf(ApexPages.currentPage().getParameters().get('dummyVar'));
    }

    public boolean init() {
    	System.debug(LoggingLevel.INFO, '***POID : ' + POID);
    	po = [SELECT Id, Name, ASI_MFM_Supplier_Name__c, ASI_MFM_Supplier_Name__r.Name, 
    	ASI_CTY_CN_Vendor_Purchase_Request_Line__c FROM ASI_MFM_PO__c WHERE Id =: POID];
    	if (po == null) {
    		return false;
    	}

    	if (po != null && po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c != null) {
            List<ASI_CRM_Quotation__c> qTemp = [SELECT Id, Name, ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_Quotation__r.Name FROM ASI_CRM_Quotation__c 
            WHERE ASI_CTY_CN_Vendor_Supplier__c = :po.ASI_MFM_Supplier_Name__c AND ASI_CTY_CN_Purchase_Request_Line__c = :po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c
            AND RecordTypeId = : ASI_CTY_CN_Vendor_Util.quotationRecordId LIMIT 1];

            if (qTemp != null && qTemp.size() > 0) {
                q = qTemp[0];
            }
        }

        return true;
    }
}