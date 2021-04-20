/*********************************************************************************
 * Name: ASI_CRM_SG_Submit_Credit_Note_ctrl
 * Description: 
 * Test Class: ASI_CRM_SG_CreditNote_TriggerClass_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/12/2020       Wilken Lee              [WL 1.0] Limit attachment checking to Manual Credit/Debit Note only
*/
public class ASI_CRM_SG_Submit_Credit_Note_ctrl {
	@AuraEnabled
    public static string validateSubmit(string recordId){
		/*[WL 1.0] BEGIN*/
        ASI_CRM_Credit_Debit_Note__c creditNote = [Select Id, name, ASI_CRM_Status__c, recordType.developerName from ASI_CRM_Credit_Debit_Note__c where id = :recordId limit 1];
        if(creditNote.recordType.developerName == 'ASI_CRM_SG_Manual_Credit_Note' || creditNote.recordType.developerName == 'ASI_CRM_SG_Manual_Debit_Note' ){ //WL 1.0: Scenario for Manual Credit/Debit Note
            /*if(creditNote.ASI_CRM_Status__c == 'Draft' || creditNote.ASI_CRM_Status__c == 'Rejected'){
                
            }else{
                return 'Credit/Debit note can be submitted only when it is either Draft/Rejected.';
            }*/
            Integer attachmentcount = [Select count() from attachment where parentId = :recordId];
            if(attachmentcount == null || attachmentcount == 0){
                integer fileCount = [Select count() from contentDocumentLink where linkedEntityId = :recordId];
                if(fileCount == null || fileCount == 0){
                    return 'Please attach files to the credit/debit note before submit for approval.';
                }
				else{
                   return submitForApproval(recordId);
                }
			}
			else{
				return submitForApproval(recordId);
			}
        }
		else{	//WL 1.0: Scenario for Wholesaler Rebate Credit/Debit Note
            //return 'This action is applicable only SG Wholesaler credit/debit Note';
			return submitForApproval(recordId);
        }
    } 
    
    public static string submitForApproval(String recordId){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();     
        req.setObjectId(recordId);
        try{
             Approval.ProcessResult result = Approval.process(req);   
            if(result.isSuccess()){
                return 'Success';
            }else{
                system.debug('@#'+result.getErrors());
                return String.valueOf(result.getErrors()[0]);
            }
        }catch(Exception e){
            return e.getMessage();
        }
        
    }
}