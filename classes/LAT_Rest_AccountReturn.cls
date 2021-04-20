@RestResource(urlMapping='/LAT_Rest_AccountReturn/*')
global with sharing class LAT_Rest_AccountReturn {
    @HttpPut
    global static void doPUT(String crmId, String erpId, String countryCode) {
        System.debug('erpId: ' + erpId);
        System.debug('crmId: ' + crmId);
        System.debug('countryCode: ' + countryCode);

        ServiceResponse res  =  processAccount(crmId, erpId, countryCode);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }

    }

    public static ServiceResponse processAccount(String crmId, String erpId, String countryCode){
        List<Account> accs = [SELECT Id FROM Account WHERE Id = :crmId];
        if(accs.size() > 0){
            Account acc = accs[0];
            acc.Return_JDE_Integration__c = '.';
            acc.Status__c = 'Account to review in JDE';
            acc.Is_Interface_Process_AR__c = true;
            acc.Client_code_AN8__c = erpId;
            acc.Client_country_AN8__c = countryCode + '-' + erpId;
            acc.Billing_Address_Code__c = erpId;
            acc.Shipping_Address_Code__c = erpId;
            try{
                update acc;    
            } catch (Exception e) {
                return new ServiceResponse(crmId, 'Error on update: ' + e.getMessage(), false);
            }
            
        } else {
            return new ServiceResponse(crmId, 'NOT FOUND ACCOUNT', false);
        }

        return new ServiceResponse(crmId, 'Account Updated Successfully', true);
    }

    public class ServiceResponse {
        
        public String Id;
        public Boolean success;
        public String message;

        public ServiceResponse(String idAcc, String msg, Boolean bool) {
            success = bool;
            message = msg;
            Id = idAcc;
        }
    }
}