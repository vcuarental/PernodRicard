/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *                                                                                      *
*   Date:01/10/2013     Descripcion: Clona un Análisis de Crédito exeptuando algunos campos que se los paso por un custom setting *                                  *
***********************************************************************************************************************************/

global without sharing class LAT_MX_BTN04_CreditAnalysisClone {
   
    webService static String CloneCreditAnalysis(String idcra){
        try{
            CRA_CredAnalysis_ARG__c cra = [SELECT Id, SalesmanComments_ARG__c, CreditAnalystComment_ARG__c, LastFinancialPresentedDate_ARG__c, Account_ARG__c, CommercialGuarantee_ARG__c, CommercialGuarantExpDate_ARG__c, CreditRiskIndex_ARG__c, RevisionDate_ARG__c, LastCreditReview_ARG__c, LAT_MX_PromissoryNoteNumber__c, LAT_MX_Deposit__c, LAT_MX_Mortgage__c FROM CRA_CredAnalysis_ARG__c WHERE Id =: idcra];             
            
            Account acc = [SELECT Id, Type, Name, Channel__c FROM Account WHERE Id =: cra.Account_ARG__c];
            
            list<LAT_MX_PMN_PromissoryNote__c> pagare = [SELECT Id, Name FROM LAT_MX_PMN_PromissoryNote__c WHERE Id =: cra.LAT_MX_PromissoryNoteNumber__c LIMIT 1];
                        
            String rtId = Global_RecordTypeCache.getRtId('CRA_CredAnalysis_ARG__cLAT_MX_CRA_Standard');
            
            map<String, CS002_FIeldsIds__c> mapAPINameFieldIds = new map<String, CS002_FIeldsIds__c>();    
            
            for(CS002_FIeldsIds__c fieldId: [SELECT Id, FieldId__c, FieldApiName__c FROM CS002_FIeldsIds__c WHERE ObjectApiName__c='CRA_CredAnalysis_ARG__c']){
                mapAPINameFieldIds.put(fieldid.FieldApiName__c, fieldId);
            }
            
            String prefixObj = CRA_CredAnalysis_ARG__c.SObjectType.getDescribe().getKeyPrefix();    
            String accName = acc.Name;
            String accId = acc.Id;
            String fecha;
            
            string CommercialGuarantee = '0';
            
            if(cra.CommercialGuarantee_ARG__c == true){
                CommercialGuarantee = '1';
            }
            
            String urlReturn = prefixObj + '/e?';
            urlReturn += '&RecordType=' + rtId;
            urlReturn += '&ent=CRA_CredAnalysis_ARG__c';
            urlReturn += '&nooverride=1';            
            urlReturn += '&' + mapAPINameFieldIds.get('Account_ARG__c').FieldId__c + '=' + EncodingUtil.urlEncode(acc.Name,'UTF-8');
            urlReturn += '&' + mapAPINameFieldIds.get('Account_ARG__c').FieldId__c + '_lkid' + '=' + acc.Id;            
            if(cra.SalesmanComments_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('SalesmanComments_ARG__c').FieldId__c + '=' +  EncodingUtil.urlEncode(cra.SalesmanComments_ARG__c,'UTF-8');
            if(cra.CreditAnalystComment_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('CreditAnalystComment_ARG__c').FieldId__c + '=' +  EncodingUtil.urlEncode(cra.CreditAnalystComment_ARG__c,'UTF-8');
            if(cra.LastFinancialPresentedDate_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('LastFinancialPresentedDate_ARG__c').FieldId__c + '=' +  cra.LastFinancialPresentedDate_ARG__c.format();
            urlReturn += '&' + mapAPINameFieldIds.get('CommercialGuarantee_ARG__c').FieldId__c + '=' + CommercialGuarantee;
            if(cra.CommercialGuarantExpDate_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('CommercialGuarantExpDate_ARG__c').FieldId__c + '=' +  cra.CommercialGuarantExpDate_ARG__c.format();            
            if(cra.CreditRiskIndex_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('CreditRiskIndex_ARG__c').FieldId__c + '=' +  EncodingUtil.urlEncode(cra.CreditRiskIndex_ARG__c,'UTF-8');
            if(cra.RevisionDate_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('RevisionDate_ARG__c').FieldId__c + '=' +  cra.RevisionDate_ARG__c.format();
            if(cra.LastCreditReview_ARG__c != null) urlReturn += '&' + mapAPINameFieldIds.get('LastCreditReview_ARG__c').FieldId__c + '=' +  cra.LastCreditReview_ARG__c.format();
            if(cra.LAT_MX_PromissoryNoteNumber__c != null){ 
                urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_PromissoryNoteNumber__c').FieldId__c + '=' +  EncodingUtil.urlEncode(pagare[0].Name,'UTF-8');
                urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_PromissoryNoteNumber__c').FieldId__c + '_lkid' + '=' + pagare[0].Id;
            }
            if(cra.LAT_MX_Deposit__c != null) urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_Deposit__c').FieldId__c + '=' +  cra.LAT_MX_Deposit__c;
            if(cra.LAT_MX_Mortgage__c != null) urlReturn += '&' + mapAPINameFieldIds.get('LAT_MX_Mortgage__c').FieldId__c + '=' +  cra.LAT_MX_Mortgage__c;            
            urlReturn += '&retURL=' + idcra;
                        
            return urlReturn;
            
        } catch(Exception e) {
            String error;
            if(e.getMessage().contains('List has no rows')){
                error = 'Error: '  + label.LAT_MX_BTN03_00002;
                //LAT_MX_BTN03_00002: La 'Configuración personalizada' CS002_FIeldsIds no ha sido cargada.
            } else {
                error = 'Error: '+e.getMessage();
            }
            return error;
        }
    
    }
    
}