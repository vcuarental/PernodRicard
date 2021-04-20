/********************************************************************
* Company: Zimmic 
* Desarrollador: Bruno Vuono

* Nombre del pagina: LAT_BR_VFP12_CreditoDisponivel
* Descripcion: controlador de la pagina LAT_BR_VFP12_CreditoDisponivel.
* Fecha: 26/08/2014 
*********************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
* 
********************************************************************************/

global with sharing class LAT_BR_VFC12_CreditoDisponivelController {

    public LAT_ACCOUNT__c acc{get;set;}
    public limiteCreditoWrapper wrapper{get;set;}
    public String msgError{get;set;}
    public String formatDate;


    public String getformatDate(){
        if(acc != null && acc.LAT_Cred_UpdatedDate__c != null){
            return acc.LAT_Cred_UpdatedDate__c.format();
        }else{
            return '';
        }
    }
   
    public  static LAT_CreditStatusHandler_1.getCreditStatusResponse_element requestCreditoDisponible(LAT_ACCOUNT__c latAcc){
            String idAccount = latAcc.LAT_Accountid__c;
            Account acc = null;
            LAT_CreditStatusHandler_1.getCreditStatusResponse_element  response;
            if(idAccount != null){
                List<Account> tmpAccounts = [Select id,Parent.Client_code_AN8__c,Client_code_AN8__c,Name, Client_country_an8__c from Account where id =: idAccount limit 1];
                if(tmpAccounts != null && tmpAccounts.size() > 0){
                    acc = tmpAccounts[0];
                    LAT_CreditStatusHandler_1.GetCustomerCreditStatusSFDCReqSOAP request = new LAT_CreditStatusHandler_1.GetCustomerCreditStatusSFDCReqSOAP();
                    request.timeout_x = 120000;  
                    String an8 = acc.Parent.Client_code_AN8__c != null && acc.Parent.Client_code_AN8__c != '' ? acc.Parent.Client_code_AN8__c : acc.Client_code_AN8__c;
                    LAT_CreditStatusHandler_1.ClientInfoType clientInfo = new LAT_CreditStatusHandler_1.ClientInfoType();
                    clientInfo.country = acc.Client_country_an8__c.split('-')[0];//'1';
                    response = request.getCreditStatus(an8,clientInfo);
                }
            }
            return response;        
    }

    @future (callout = true)
    public static void setInitCreditoDisponible(String AccId){
        List<LAT_ACCOUNT__c> tmpLatAcc = [Select id,LAT_Accountid__c from LAT_ACCOUNT__c where LAT_Accountid__c =: AccId];
        if(!tmpLatAcc.isEmpty()){
            try{
                LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(tmpLatAcc[0]);
            }catch(exception ex){
                LAT_DebugUtil debugUtil = new LAT_DebugUtil();
                debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
                debugUtil.setOrigin('Credito Disponible');
                debugUtil.insertDebug();
            }
        }
    }

    public static String updateCreditoDisponible(LAT_ACCOUNT__c latAcc){
        DateTime now = Datetime.now();
        LAT_CreditStatusHandler_1.getCreditStatusResponse_element response;      
        try {
            response = LAT_BR_VFC12_CreditoDisponivelController.requestCreditoDisponible(latAcc);
        } catch (exception e) {
            if(!LAT_Utils.isRunningTest()){
                return Label.LAT_BR_VFP12_00013 + ' - ' + e.getMessage();
            } else {
                response = new LAT_CreditStatusHandler_1.getCreditStatusResponse_element();
                response.errorCode = '0';
                response.result = new LAT_CreditStatusHandler_1.result_element();
                response.result.dept = '10.00';
                response.result.creditLimit = '12.00';
                response.result.pendingOrders = '10.00';
                response.result.approvedOrders = '10.00';
                response.result.aboveCreditLimit = '10.00';

            }
        }
        system.debug('111111 ' + response);
        if(response.errorCode == '0'){
            //wrapper = new limiteCreditoWrapper(1.98,2,3,4,5);
            latAcc.LAT_Cred_Debt__c = Decimal.valueOf(response.result.dept);
            latAcc.LAT_Cred_Limit__c = Decimal.valueOf(response.result.creditLimit);
            latAcc.LAT_Cred_OrderPending__c = Decimal.valueOf(response.result.pendingOrders);
            latAcc.LAT_Cred_UpdatedDate__c = DateTime.now();
            latAcc.LAT_Cred_OrderAppr__c = Decimal.valueOf(response.result.approvedOrders);
            latAcc.LAT_Cred_AboveLimit__c = Decimal.valueOf(response.result.aboveCreditLimit);
            latAcc.LAT_Cred_RequestDate__c = now;
            update latAcc;
        }else{
            //for test
            
            
            //latAcc.LAT_Cred_UpdatedDate__c = DateTime.now();
            //latAcc.LAT_Cred_RequestDate__c = now;
            //update latAcc;

            //Errors: -1, -2, -9

            //return response.errorMsg;
            return Label.LAT_BR_VFP12_00013;
        }
        return '';
    }

    public void actionCreditoDisponible(){
        String idAccount = Apexpages.currentPage().getParameters().get('accId');
        String updateA = Apexpages.currentPage().getParameters().get('update');
        wrapper = new limiteCreditoWrapper();
        if(idAccount != null){
            List<LAT_ACCOUNT__c> tmpAccounts = [Select id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,LAT_Cred_AboveLimit__c,LAT_Accountid__c,LAT_Cred_Limit_Available__c,LAT_Accountid__r.Name,LAT_Accountid__r.Client_code_AN8__c from LAT_ACCOUNT__c where LAT_Accountid__c =: idAccount];
            if(tmpAccounts != null && tmpAccounts.size() > 0){
                acc = tmpAccounts[0];
                checkLastUpdated(acc,(updateA == 'Y'));
            }
        }
    }

    public void updateValores(){
        String[] minsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_AVAILABLE', ' ');

        Integer mins = minsArray != null ? Integer.valueOf(minsArray[0]) : 10;
        if(acc != null){
            if((acc.LAT_Cred_UpdatedDate__c == null) || acc.LAT_Cred_UpdatedDate__c < Datetime.now().addMinutes(-mins)){
                String msgError = LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(acc);
                if(msgError == ''){
                    List<LAT_ACCOUNT__c> tmpAccounts = [Select id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,LAT_Cred_AboveLimit__c,LAT_Accountid__c,LAT_Cred_Limit_Available__c,LAT_Accountid__r.Name,LAT_Accountid__r.Client_code_AN8__c from LAT_ACCOUNT__c where id =: acc.id];
                    if(tmpAccounts != null && tmpAccounts.size() > 0){
                        acc = tmpAccounts[0];
                    }else{                 
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.LAT_BR_VFP12_00012));

                    }
                }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,msgError));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.LAT_BR_VFP12_00014));
            }
        }
    }

    public void checkLastUpdated(LAT_ACCOUNT__c lacc, boolean toupdate){
        if(lacc.LAT_Cred_RequestDate__c > lacc.LAT_Cred_UpdatedDate__c || (lacc.LAT_Cred_UpdatedDate__c == null)){
            if(lacc.LAT_Cred_RequestDate__c > Datetime.now().addMinutes(-2)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.LAT_BR_VFP12_00010));
                return;
            }
        }
        if(toupdate){
            String[] minsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_AVAILABLE', ' ');

            Integer mins = minsArray != null ? Integer.valueOf(minsArray[0]) : 10;
            if((lacc.LAT_Cred_UpdatedDate__c == null) || lacc.LAT_Cred_UpdatedDate__c < Datetime.now().addMinutes(-mins)){
                String msgError = LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(lacc);
                if(msgError == ''){
                    List<LAT_ACCOUNT__c> tmpAccounts = [Select id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,LAT_Cred_AboveLimit__c,LAT_Accountid__c,LAT_Cred_Limit_Available__c,LAT_Accountid__r.Name,LAT_Accountid__r.Client_code_AN8__c from LAT_ACCOUNT__c where id =: acc.id];
                    if(tmpAccounts != null && tmpAccounts.size() > 0){
                        acc = tmpAccounts[0];
                    }
                }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,msgError));
                }
            }
        }
    }

    Webservice static String validateCreditoDisponible(String opptyId, String accId){
        System.debug('%%%%%%%%% validateCreditoDisponible opptyId : '+opptyId+' , accId : '+ accId);
        LAT_ACCOUNT__c latAcc;
        List<LAT_ACCOUNT__c> tmpLatAcc = [Select id,LAT_Accountid__c,LAT_Cred_Limit_Available__c from LAT_ACCOUNT__c where LAT_Accountid__c =: AccId];
        if(!tmpLatAcc.IsEmpty()){
            latAcc = tmpLatAcc[0];
        }

        if(!Utils.wasMigrationDone('1')){
            Opportunity opp;
             List<Opportunity> oppL = [SELECT Valor_total__c
                                          FROM Opportunity WHERE Id =: opptyId limit 1];
                
            if(!oppL.IsEmpty()){
                opp = oppL[0];
            }

            if(opp != null && latAcc != null){
                if(opp.Valor_total__c > latAcc.LAT_Cred_Limit_Available__c){
                    List<String> parameters = new List<String>{(opp.Valor_total__c == null? '' : opp.Valor_total__c.format() ) ,(latAcc.LAT_Cred_Limit_Available__c == null? '' : latAcc.LAT_Cred_Limit_Available__c.format() )};
                    return String.format(Label.LAT_BR_VFP12_00011, parameters);
                }
            }
            return '';
        } 
        //MIGRATED 03/11/2016
        else {
            LAT_Opportunity__c opp;
             List<LAT_Opportunity__c> oppL = [SELECT LAT_TotalValue__c
                                          FROM LAT_Opportunity__c WHERE Id =: opptyId limit 1];
                
            if(!oppL.IsEmpty()){
                opp = oppL[0];
            }
            System.debug('%%%%%%%%% opp seleccionada : '+opp);
       
            if(opp != null && latAcc != null){
                if(opp.LAT_TotalValue__c > latAcc.LAT_Cred_Limit_Available__c){
                    List<String> parameters = new List<String>{(opp.LAT_TotalValue__c == null? '' : opp.LAT_TotalValue__c.format() ) ,(latAcc.LAT_Cred_Limit_Available__c == null? '' : latAcc.LAT_Cred_Limit_Available__c.format() )};
                    return String.format(Label.LAT_BR_VFP12_00011, parameters);
                }
            }
            return '';            
        }
    }
    
    
    public LAT_BR_VFC12_CreditoDisponivelController(){
    }


    public static void updateRequestDate(List<Opportunity> lstOpp){
        List<String> accIds = new List<String>();
        for(Opportunity opp: lstOpp){
            accIds.add(opp.accountId);
        }
        List<LAT_ACCOUNT__c> toUpdate = [Select id from LAT_ACCOUNT__c where LAT_Accountid__c in :accIds];
        for(LAT_ACCOUNT__c latAcc : toUpdate){
            latAcc.LAT_Cred_RequestDate__c = Datetime.now();
        }
        update toUpdate;
    }
    //MIGRATED 03/11/2016
    public static void updateRequestDate(List<LAT_Opportunity__c> lstOpp){
        List<String> accIds = new List<String>();
        for(LAT_Opportunity__c opp: lstOpp){
            accIds.add(opp.LAT_Account__c);
        }
        List<LAT_ACCOUNT__c> toUpdate = [Select id from LAT_ACCOUNT__c where LAT_Accountid__c in :accIds];
        for(LAT_ACCOUNT__c latAcc : toUpdate){
            latAcc.LAT_Cred_RequestDate__c = Datetime.now();
        }
        update toUpdate;
    }
    
    public class limiteCreditoWrapper{
        public Decimal limiteCredito{get;set;}
        public Decimal pedidoPendente{get;set;}
        public Decimal valorDevido{get;set;}
        public Decimal pedidosAprovados{get;set;}
        public Decimal acimaLimiteCredito{get;set;}
        
        public limiteCreditoWrapper(){
            limiteCredito = 0;
            pedidoPendente = 0;
            valorDevido = 0;
            pedidosAprovados = 0;
            acimaLimiteCredito = 0;
        }
        
        public limiteCreditoWrapper(Decimal plimiteCredito, Decimal ppedidoPendente,Decimal pvalorDevido,Decimal ppedidosAprovados,Decimal pacimaLimiteCredito ){
            limiteCredito = plimiteCredito;
            pedidoPendente = ppedidoPendente;
            valorDevido = pvalorDevido;
            pedidosAprovados = ppedidosAprovados;
            acimaLimiteCredito = pacimaLimiteCredito;
        }
        
        public Double getLimiteDisponivel(){
            return limiteCredito - valorDevido - pedidosAprovados - pedidoPendente;
        }
        
        
        
    }

}