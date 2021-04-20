/*********************************************************************************
* Name:ASI_SOA_Vouchers
* Test class : ASI_SOA_Vouchers_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 26/09/2019       Wilken Lee              Created
* 20/06/2020       PRA COE                 Change updateVoucherNumber to accept two format
* 02/10/2020       Wilken Lee              [WL 1.0] Substring Description field to 30 characters to match JDE column size
* 07/10/2020       Wilken Lee              [WL 2.0] HttpPatch response body need to be in JSON format
* 03/12/2020       PRA COE                 [COE 1.0]  Avoid duplicate Payment exist in PaymentList
*********************************************************************************/
@RestResource(urlMapping='/ASI_SOA_Vouchers/*')
global class ASI_SOA_Vouchers{
    /**
* @Description: handle response for GET method, list all necessary fields for inserting sales order and line items for JDE
*/
    @HttpGet
    global static void getPaymentRequestByID(){
        
        RestRequest  req = RestContext.request;
        String paymentRequestID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('### Payment Request ID: ###' + paymentRequestID);
        
        handleResponse(paymentRequestID);
    }
    
    private static void handleExceptions(RestResponse res, Integer statusCode, String message){
        res.statusCode = statusCode;
        String jsonResponse = '{"response": {"status": "Failure", "message": "'+ message + '"}}';
        res.responseBody = blob.valueOf(jsonResponse);
        return;
    }
    
    private static void handleResponse(String paymentRequestID){
        RestResponse res;
        if(Test.isRunningTest()){
            res = new RestResponse();  
        }
        else {
            res = RestContext.response;    
        }
        
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';       
        List<ASI_TH_CRM_PaymentRequest__c> paymentRequests = [SELECT Id, Name, ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c,
                                                              CurrencyIsoCode, ASI_CRM_CN_Currency__c, ASI_CRM_JDEPVNum__c,ASI_TH_CRM_PaymentDate__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_JDE_Code__c, ASI_CRM_PVRaiseDate__c, ASI_CRM_CN_Description__c, ASI_CRM_MY_Total_Adjusted_Payment__c, 
                                                              ASI_CRM_GSTTaxAmount__c, ASI_CRM_TotalPayment__c, ASI_CRM_SG_Invoice_No__c, ASI_CRM_SG_Invoice_Date__c, 
                                                              (SELECT Id, Name, ASI_TH_CRM_Amount__c, ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Code__c,ASI_CRM_Remark__c,ASI_CRM_SetupCode__c, ASI_CRM_CN_AC_Code__r.ASI_MFM_GL_Class__c, ASI_CRM_Business_Unit__c FROM ASI_TH_CRM_PRLI_PaymentRequest__r)
                                                              FROM ASI_TH_CRM_PaymentRequest__c WHERE ID = :paymentRequestID];
        
        if (paymentRequests.isEmpty()){
            handleExceptions(res, 400, 'Payment Request Id: ' + paymentRequestID + ' was not found');
        }
        
        ASI_TH_CRM_PaymentRequest__c paymentRequest = paymentRequests[0];
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestItemList = paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r; // Causes an error
        Integer count = paymentRequestItemList.size();
        
        // At least 1 account was found, JSON serialize it and send it back.
        try {
            res.statusCode = 200;
            jsonResponse = buildSalesOrderJSONResponse(paymentRequest);
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        }  catch ( Exception ex ) {
            handleExceptions(res, 500, ex.getStackTraceString());
        }
    }
    
    private static String buildSalesOrderJSONResponse(ASI_TH_CRM_PaymentRequest__c paymentRequests) {
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        gen.writeStringField('Id', paymentRequests.ID);
        gen.writeStringField('Name', paymentRequests.Name);
        gen.writeStringField('VoucherNumber', paymentRequests.ASI_CRM_JDEPVNum__c != null ? paymentRequests.ASI_CRM_JDEPVNum__c : '');
        
        //WL 2019-11-08 Temporarily change to current date for testing purpose
        gen.writeDateField('AccountingDate', System.Today());

        gen.writeStringField('InvoiceNumber', paymentRequests.ASI_CRM_SG_Invoice_No__c != null ? paymentRequests.ASI_CRM_SG_Invoice_No__c : '');
        
        if (paymentRequests.ASI_CRM_SG_Invoice_Date__c != null) {
            gen.writeDateField('InvoiceDate', paymentRequests.ASI_CRM_SG_Invoice_Date__c);
        }  else {
            gen.writeNullField('InvoiceDate');
        }
        
        if (paymentRequests.ASI_TH_CRM_PaymentDate__c != null) {
            gen.writeDateField('PaymentDate', paymentRequests.ASI_TH_CRM_PaymentDate__c);
        } else {
            gen.writeNullField('PaymentDate');
        }       
        
        
        gen.writeStringField('VendorNumber', paymentRequests.ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c != null ? paymentRequests.ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c : '');//gen.writeStringField('VendorNumber', '506024');
        gen.writeStringField('ActionCode', 'ADD');
        gen.writeStringField('CompanyNumber', '00828'); // 00828 for MY use only
        gen.writeStringField('CurrencyCode', paymentRequests.CurrencyIsoCode);
        gen.writeStringField('CurrencyISOCode', paymentRequests.CurrencyIsoCode);
        gen.writeStringField('Remark', paymentRequests.ASI_CRM_CN_Description__c != null ? paymentRequests.ASI_CRM_CN_Description__c.left(30) : ''); //[WL 1.0]
        gen.writeFieldName('PaymentRequestLines');
        gen.writeStartArray();
        for (ASI_TH_CRM_PaymentRequestLineItem__c item : paymentRequests.ASI_TH_CRM_PRLI_PaymentRequest__r){
            gen.writeStartObject();            
            gen.writeStringField('CustomerNumber', paymentRequests.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_JDE_Code__c != null ? paymentRequests.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_JDE_Code__c : '' );    
            gen.writeStringField('CostCenter', item.ASI_CRM_Business_Unit__c);
            gen.writeStringField('Category', item.ASI_CRM_SetupCode__c );      //  ===>Setup Code  '5280'    Temporarily Hard Code because SFDC does not have this field ready yet
            gen.writeStringField('ProjectOrCommodity', '');          //Optional because changed to use Expense Category Code
            gen.writeNumberField('Amount', item.ASI_TH_CRM_Amount__c != null ? item.ASI_TH_CRM_Amount__c : 0);
            gen.writeStringField('Remark', paymentRequests.ASI_CRM_CN_Description__c != null ? paymentRequests.ASI_CRM_CN_Description__c.left(30) : ''); //[WL 1.0]
            gen.writeStringField('PurchaseOrderNumber', '');         //  string poNum = '';  //This field support numeric only in JDE  
            gen.writeEndObject(); 
        }
        
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    @HttpPatch
    global static void  updateVoucherNumber(){//string resultMsg = '';
        List<ASI_TH_CRM_PaymentRequest__c> PaymentList = new List<ASI_TH_CRM_PaymentRequest__c>();
        set<string> paymentID = new set<string>();// [COE 1.0]
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestBody = body.toString();
        
        if(requestBody.contains('[')){ // List, RemitanceAdvice.OUT call from JDE to update Payment Date
            List<Object> InputList =new List<Object>();
            Map<String,string> PYIdMap = NEW Map <String, string >(); // <Request ID, SFDC ID>
            Set<String>  JDEPVNumSet = new Set<String>();
            InputList =(List<Object>)JSON.deserializeUntyped(req.requestbody.tostring().replace('\\', '').replaceAll('  ',''));
            for(Object obj: InputList){
                Map<String, Object> record = (Map<String, Object>)obj;
                for(String fieldName : record.keySet()) {
                    if(fieldName=='Id' && record.get(fieldName)!=null && record.get(fieldName)!='' ){
                        string IDstr= String.valueOf(record.get(fieldName));
                        if(IDstr.length() == 18){//Record Id
                            PYIdMap.put(IDstr,IDstr);
                        }else{
                            JDEPVNumSet.add(IDstr);
                        }
                    }
                }
            }
            
            if(JDEPVNumSet.size()>0){
                for(ASI_TH_CRM_PaymentRequest__c py : [SELECT Id,ASI_CRM_JDEPVNum__c from ASI_TH_CRM_PaymentRequest__c WHERE recordType.DeveloperName =  'ASI_CRM_MY_Payment_Request_Read_Only' AND ASI_CRM_JDEPVNum__c in :JDEPVNumSet] ){
                      PYIdMap.put(py.ASI_CRM_JDEPVNum__c,py.Id);
                } 
                       
            }
            
            for(Object obj: InputList){
                Map<String, Object> record = (Map<String, Object>)obj;
                ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c( );
                for(String fieldName : record.keySet()) {
                    system.debug('fieldName : '+fieldName);
                    system.debug('value : '+record.get(fieldName));
                    
                    if(fieldName=='Id' && record.get(fieldName)!=null && record.get(fieldName)!='' ){// payment record id  
                        string IDstr=  String.valueOf(record.get(fieldName));
                        if(IDstr.length() == 18){
                            payment.Id = IDstr; 
                        }else if(PYIdMap.containsKey(IDstr) ){
                            payment.Id = PYIdMap.get(IDstr); 
                        }
                    } 
                    
                    if(fieldName=='PaymentDate' && record.get(fieldName)!=null && record.get(fieldName)!='' ){
                        payment.ASI_TH_CRM_PaymentDate__c = (Date)JSON.deserialize('"' + record.get(fieldName) + '"', Date.class);
                    }
                     
                }
               
                if(payment.Id !=null && !paymentID.contains(payment.Id)){// [COE 1.0]
                    PaymentList.add(payment);
                    paymentID.add(payment.Id);
                }
            }
        }else{//Map
            ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c( );
             Map<String, Object> requestMapping =   (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            for (String erpFieldName : requestMapping.keySet()){
                system.debug('erpFieldName: ' + erpFieldName + ' String.ValueOf(requestMapping.get(erpFieldName)): ' + String.ValueOf(requestMapping.get(erpFieldName)));
                
                if (erpFieldName == 'Id'){                  
                    if (String.ValueOf(requestMapping.get(erpFieldName)).length() == 18){
                        payment.Id = String.ValueOf(requestMapping.get(erpFieldName));
                    }
                    else {
                        String voucherNumber = String.ValueOf(requestMapping.get(erpFieldName));
                        system.debug('voucherNumber: ' + voucherNumber);
                        List<ASI_TH_CRM_PaymentRequest__c> paymentToUpdate = [SELECT Id from ASI_TH_CRM_PaymentRequest__c WHERE recordType.DeveloperName =  'ASI_CRM_MY_Payment_Request_Read_Only' AND ASI_CRM_JDEPVNum__c = :voucherNumber];
                        
                        system.debug('paymentToUpdate: ' + paymentToUpdate);
                        
                        if (paymentToUpdate.size() == 1)
                            payment.Id = paymentToUpdate.get(0).Id;
                    }
                }
                else if (erpFieldName == 'VoucherNumber' && String.ValueOf(requestMapping.get(erpFieldName)).contains('PV')){
                    payment.ASI_CRM_JDEPVNum__c = String.ValueOf(requestMapping.get(erpFieldName));
                }
                else if (erpFieldName == 'PaymentDate'){
                    payment.ASI_TH_CRM_PaymentDate__c = (Date)JSON.deserialize('"' + requestMapping.get(erpFieldName) + '"', Date.class);
                }
            }
            if(payment.Id !=null && !paymentID.contains(payment.Id)){// [COE 1.0]
                PaymentList.add(payment);
                paymentID.add(payment.Id);
            }
            
        }  
        
        if(PaymentList.size()>0){
            //try { //Do not Try & Catch Exception in order to let iTrack to display integraiton as Failed when error occurs
            Database.SaveResult[] srList = Database.update(PaymentList, false);     // resultMsg =  String.valueOf(srList);
            Boolean isSuccess = true;
            string resultMsg = ' ';
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    isSuccess= true;
                    resultMsg += 'Updated successfully with Id: ' + sr.getId()+'\n';
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Updated successfully with Id: ' + sr.getId());
                }
                else {
                    isSuccess = false;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        resultMsg += 'Updated failed with Id: ' + err.getStatusCode() + ': ' + err.getMessage() +err.getFields()+'\n';
                       
                    }
                }
            }
            
            
            if(isSuccess){
                RestResponse res= RestContext.response;
                res.addHeader('Content-Type', 'application/json');
                res.statusCode = 200;
                //res.responseBody = blob.valueOf(resultMsg); //WL 2.0
                res.responseBody = blob.valueOf('{ "Result" : "' + resultMsg + '" }');    //WL 2.0
                
                return;
            }else{ // failed
                handleExceptions(RestContext.response, 500, resultMsg);
            }
            
            /*} catch (Exception e)  {
                resultMsg= e.getStackTraceString() + e.getMessage();
                handleExceptions(RestContext.response, 500, e.getStackTraceString() + e.getMessage());
            }*/
        }
                
        //return resultMsg;                
    }    
}