public class ASI_CRM_PaymentRequest_Submit_Ctrl {
    @AuraEnabled
    public Static String validateRecord(Id recordId){
        system.debug('@#recordId'+recordId);
        ASI_TH_CRM_PaymentRequest__c paymentRequest = [Select id,ASI_CRM_System_Remark__c,ASI_CRM_Achievement__c,ASI_CRM_SG_Invoice_Date__c,ASI_CRM_CN_OutletWS__c,ASI_CRM_Vendor__c, ASI_CRM_Total_No_of_Sales_Support__c,ASI_CRM_System_Generated__c,ASI_TH_CRM_Contract__c from ASI_TH_CRM_PaymentRequest__c where Id =:recordId];
        try{
            if ((paymentRequest.ASI_CRM_System_Remark__c == 'SG Promotion' || paymentRequest.ASI_CRM_System_Remark__c  == 'Wholesaler Back Rebate Payment') &&
                (paymentRequest.ASI_CRM_CN_OutletWS__c == null ||
                 paymentRequest.ASI_CRM_Vendor__c == null ||
                 paymentRequest.ASI_CRM_SG_Invoice_Date__c == null)
               ) {
                   return 'Please input all required fields (Outlet, Vendor and Invoice Date) before submit.';
               } else
                   if ((paymentRequest.ASI_CRM_System_Remark__c  != 'SG Promotion' && paymentRequest.ASI_CRM_System_Remark__c  != 'Wholesaler Back Rebate Payment') &&
                       (paymentRequest.ASI_CRM_CN_OutletWS__c == null ||
                        paymentRequest.ASI_TH_CRM_Contract__c == null ||
                        paymentRequest.ASI_CRM_Vendor__c == null ||
                        paymentRequest.ASI_CRM_SG_Invoice_Date__c == null)
                      ) {
                          return 'Please input all required fields (Outlet, Contract, Vendor and Invoice Date) before submit.';
                      } else
                          if (!validateAchievement(paymentRequest)) {
                              return 'You are not allowed to submit this payment because the sales have not been achieved. Please delete this payment request.';
                          } else
                              if (!validateSalesSupport(paymentRequest)) {
                                  return 'Please upload document for sales support before submit.';
                              } else
                                  if (!validateManualPaymentAttachment(paymentRequest)) {
                                      return 'Please upload document for manual payment requeset before submit.';
                                  } else {
                                      Boolean confirmToSubmit = true;
                                      if (confirmToSubmit) {
                                          ASI_TH_CRM_PaymentRequest__c pr1 = new ASI_TH_CRM_PaymentRequest__c(Id = paymentRequest.Id, ASI_CRM_Sys_Allow_Submit_Approval__c = true);
                                         update pr1;
                                          return 'Success';
                                      }
                                  }
            
        }catch(exception e){
            return 'An error occurred. Details : ' + e.getMessage();
        }
        return null;
    }
    
    public static boolean validateSalesSupport(ASI_TH_CRM_PaymentRequest__c paymentRequest) {
        if (paymentRequest.ASI_CRM_Total_No_of_Sales_Support__c ==0) {
            return true;
        }
        List<Attachment> attchmntList = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :paymentRequest.Id ];
        
        if (attchmntList!= null && attchmntList.size()>0){
            return true;
        }
         List<ContentDocumentLink> documentList = [SELECT Id  FROM ContentDocumentLink where LinkedEntityId = :paymentRequest.Id and LinkedEntity.Type='ASI_TH_CRM_PaymentRequest__c'];
        if (documentList != null && documentList.size()>0){
            return true;
        }
        return false;
    }
    
    public Static boolean validateManualPaymentAttachment(ASI_TH_CRM_PaymentRequest__c paymentRequest) {
        if (paymentRequest.ASI_CRM_System_Generated__c){
            return true;
        }
        
        List<Attachment> attachmentList = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :paymentRequest.Id ];
        if (attachmentList != null && attachmentList.size()>0){
            return true;
        }
        List<ContentDocumentLink> documentList = [SELECT Id  FROM ContentDocumentLink where LinkedEntityId = :paymentRequest.Id and LinkedEntity.Type='ASI_TH_CRM_PaymentRequest__c'];
        if (documentList != null && documentList.size()>0){
            return true;
        }
        
        return false;
    }
    
    
    public Static Boolean validateAchievement(ASI_TH_CRM_PaymentRequest__c paymentRequest){
        if (!paymentRequest.ASI_CRM_System_Generated__c){
            return true;
        }
        if(PaymentRequest.ASI_TH_CRM_Contract__c != null){
            List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id, ASI_CRM_Till_Date_Sales_Percent_Achieved__c FROM ASI_TH_CRM_Contract__c WHERE Id = :PaymentRequest.ASI_TH_CRM_Contract__c limit 1];
            if (contractList != null && contractList.size()>0){
                if(contractList[0].ASI_CRM_Till_Date_Sales_Percent_Achieved__c < (String.valueOf(paymentRequest.ASI_CRM_Achievement__c)== null ?0 : paymentRequest.ASI_CRM_Achievement__c)){
                    return false;
                }
            }
        }
        return true;
    }
    
    
    
}