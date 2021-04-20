/*********************************************************************************
 * Name: ASI_CRM_SG_ContractComparisonPDF_ComCtrl
 * Description: Controller class for ASIshowing PDF in approval email
 * Test Class: ASI_CRM_SG_ContractComparison_CtrlTest
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 03/04/2017       Hugo Cheung             Created          
 * 21/08/2018       Wilken Lee              [WL 1.0] Add null checking for Attachment query
*/
public class ASI_CRM_SG_ContractComparisonPDF_ComCtrl {
    
    public Id contractId {get; set;}
    public String body;
    
    public ASI_CRM_SG_ContractComparisonPDF_ComCtrl() {
    }
    
    public String getBody() {
        String bodyStr = '';
        // ASI_CRM_SG_PDF_Attachment__c is string with format: Object:attachmentId;
    	ASI_TH_CRM_Contract__c contract = [SELECT Id, ASI_CRM_SG_PDF_Attachment__c FROM ASI_TH_CRM_Contract__c WHERE Id =: contractId];
        if(String.isNotBlank(contract.ASI_CRM_SG_PDF_Attachment__c)) {
           	List<String> pdfAttachmentList = contract.ASI_CRM_SG_PDF_Attachment__c.split(';');
            
            String contractComparsionAttId;
            for(String pdfAtt : pdfAttachmentList) {
            	if(pdfAtt.contains('ContractComparsionPDF')) {
                    contractComparsionAttId = pdfAtt.split(':')[1];
                }
            }
            if(String.isNotBlank(contractComparsionAttId)) {
            	List<Attachment> tempAttachmentList = [SELECT Body FROM Attachment WHERE Id = :contractComparsionAttId];
				
				/*[WL 1.0] BEGIN*/
				if (tempAttachmentList.size() == 1){
					/*[WL 1.0] END*/
					bodyStr = tempAttachmentList.get(0).Body.toString();
				}
            }
        }
        return bodyStr;
    }
}