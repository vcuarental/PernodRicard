/***************************************************************************************************************************
* Name:        ASI_CRM_MY_PaymentInterface_Batch
* Description: call Bridge by batch one by one
* Test Class:   
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-06-22       PRA CoE      Created
****************************************************************************************************************************/
public class ASI_CRM_MY_PaymentInterface_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public  Set<Id> PayIdSet {set;get;}{PayIdSet = new Set<Id>();}
    public ASI_CRM_MY_PaymentInterface_Batch(Set<Id> PaymentIdSet  ){
        this.PayIdSet = PaymentIdSet;
    }
    
    public database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id from ASI_TH_CRM_PaymentRequest__c where Id IN : PayIdSet ]);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_TH_CRM_PaymentRequest__c> PayList=scope;
        if(PayList.size()==1){
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            
            String payId= PayList[0].id;
            // call out
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(my_cs.ASI_CRM_Bridge_Payment_Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/xml');
            request.setHeader('SOAPAction', 'Webhook');
            request.setHeader('ApiKey', my_cs.ASI_CRM_Bridge_Payment_API_Key__c); 
            
            String requestBody ='<?xml version="1.0" encoding="utf-8"?> <Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"> <Body> <notifications xmlns="http://soap.sforce.com/2005/09/outbound">'+
                ' <OrganizationId>'+UserInfo.getOrganizationId()+'</OrganizationId> <ActionId>04kM0000000027V</ActionId>'+
                ' <SessionId xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'+
                ' <EnterpriseUrl>'+ my_cs.ASI_CRM_Enterprise_API_URL__c + UserInfo.getOrganizationId()+'</EnterpriseUrl>'+
                ' <PartnerUrl>'+ my_cs.ASI_CRM_Enterprise_API_URL__c + UserInfo.getOrganizationId()+'</PartnerUrl> <Notification> <Id>04l1l000001pDJvAAM</Id>'+
                ' <sObject xsi:type="sf:ASI_TH_CRM_PaymentRequest__c" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:sobject.enterprise.soap.sforce.com"> <sf:Id>'+
                payId+'</sf:Id> <sf:ASI_CRM_Country_Code__c>MY</sf:ASI_CRM_Country_Code__c> </sObject> </Notification> </notifications> </Body> </Envelope>';
            // Set the body as a JSON object
            request.setBody(requestBody);
            if(!Test.IsRunningTest()){
                 HttpResponse response = http.send(request);
                // Parse the JSON response
                if (response.getStatusCode() != 201) {
                    System.debug(response.getBody() + 'The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus()); 
                } else {
                    System.debug(response.getBody());
                }
            }
           
           
        }
    }
    
    public void finish(Database.BatchableContext BC){ }
}