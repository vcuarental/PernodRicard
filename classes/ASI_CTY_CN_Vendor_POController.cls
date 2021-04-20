/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_POController       
 * Test Class:  ASI_CTY_CN_Vendor_POControllerTest
 * Description: Vendor Community PO List Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-09-08       BLS-HUJINCHAO           Create AuraEnabled functions
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_POController {
    /*
    * Method Name: getPOInfo
    * Description: get all PO info of current User.
    * Return Type: List<ASI_MFM_PO__c>
    * Parameter  : void
    */
    @AuraEnabled 
    public static List<ASI_MFM_PO__c> getPOInfo(){
    	Id accountId = ASI_CTY_CN_Vendor_Util.getAccountId();
    	List<ASI_MFM_PO__c> results = new List<ASI_MFM_PO__c>();
        Set<String> recordTypes = new Set<String>();
        recordTypes.add('ASI_MFM_CN_PO_Read_Only');
        recordTypes.add('ASI_MFM_CN_PO');
        
        // Check PO info according to the PO ID, and find the SIR info
    	for (ASI_MFM_PO__c po : [SELECT Id, Name, ASI_CTY_CN_Vendor_Fill_Sir__c, ASI_MFM_PO_Final_Date__c, ASI_MFM_PO_Type__c, toLabel(ASI_MFM_Status__c), 
    		ASI_MFM_CN_PO_Amount_RMB__c, RecordType.Name, ASI_MFM_Total_Paid_Amount__c, ASI_MFM_Total_Quantity__c, ASI_CTY_CN_Vendor_Purchase_Request_Line__r.Name,
            ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name, CreatedDate,
    		(SELECT Id, ASI_MFM_Total_Quantity__c, ASI_MFM_Lot_Quantity__c, ASI_MFM_PO_POSM_Line_Number__c 
                FROM Stock_In_Requests__r),
    			(SELECT ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_MFM_Item_Group__r.Name, 
                    ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_MFM_Unit_Price__c, 
    				ASI_MFM_Total_Price_w_VAT__c, ASI_MFM_Quantity__c FROM PO_POSM_Lines__r)
    		FROM ASI_MFM_PO__c 
    		WHERE ASI_MFM_Supplier_Name__c =: accountId 
            AND ASI_MFM_PO_Type__c =: 'eMarket'
    		AND (RecordType.DeveloperName IN: recordTypes) ORDER BY CreatedDate DESC]) {
    			results.add(po);
    	}
        return results;
    }
}