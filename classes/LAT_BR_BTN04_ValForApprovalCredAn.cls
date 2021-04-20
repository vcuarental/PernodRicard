global with sharing class LAT_BR_BTN04_ValForApprovalCredAn {
    /*                                      
*-----------------------------------------------------------------------------------------------------------------------
*   Clase que funciona con el boton "Submit for Approval" en el objeto Analise_de_credito__c
***********************************************************************************************************************/


    
    webService static String validationOfCredAnalisysBeforeAproval(String IdSCreditAnalisys){
    
    System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   IdSCreditAnalisys  ' + IdSCreditAnalisys);
    Analise_de_credito__c anCred = [SELECT id, Name, LAT_BR_Status__c, Conta__r.Name, Conta__r.Client_code_AN8__c, Conta__r.Status__c FROM Analise_de_credito__c WHERE id =: IdSCreditAnalisys];
    
    String strRetunr = '';
    if (anCred.Conta__r.Client_code_AN8__c == '' || anCred.Conta__r.Status__c == 'Novo cadastro' || anCred.LAT_BR_Status__c == 'Ativo') {
      strRetunr = Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage;
    } else {
      
      try {
        Approval.ProcessSubmitRequest aprovalRequest = new Approval.ProcessSubmitRequest();
        aprovalRequest.setObjectId(anCred.id);
        aprovalRequest.setSubmitterId(Userinfo.getUserId());
        Approval.ProcessResult result = Approval.process(aprovalRequest);
        Database.Error[] errors = result.getErrors();
        if (errors != null) {
          if (errors.size() > 0) {
            strRetunr = Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage;
          }               
        } 
      } catch (Exception e) {
          if (e.getMessage().contains('ALREADY_IN_PROCESS')) {
      
          strRetunr = Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage2;
          } else {
              strRetunr = Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg;
          }
      } 
    }
    return strRetunr;
    
  }   
}