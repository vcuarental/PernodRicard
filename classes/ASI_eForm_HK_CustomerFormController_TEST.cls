@isTest
public class ASI_eForm_HK_CustomerFormController_TEST {
    
    public static testMethod void CustomerFormController_TEST(){
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name1');           
        insert acc1;
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc2; 
        String SoqlStatment = 'select id, name from Account where Name Like \'Name%\'';
        
        
        ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',
                                                             ASI_eform_HK_Token_Url__c = 'https://test.salesforce.com/services/oauth2/token',
                                                             ASI_eForm_HK_Refresh_Token__c='5Aep8611MDY00mymq7tQ9aPb_I73xvp656mYxHJoM4U17dn73zUw5Et04E34FdZ4vLf1prX3goCXcvfSYc.jLOF',
                                                             ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), 
                                                             ASI_eForm_HK_Client_Id__c='3MVG9A2kN3Bn17huybPDZzyv26ck8kBCvNRX_g2ejejCnoiZhS7EOISZbaKV8cORCfOBSprhWNuqaTCwuhPVy',
                                                             ASI_eForm_HK_Client_Secret__c='5520405440568465845',
                                                             ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 , 
                                                             ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,
                                                             ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1,
                                                             ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
        insert setting;
        
        List<Account> acclist = new List<Account>();
        acclist = ASI_eForm_HK_CustomerFormController.fetchsObjectData(SoqlStatment);
        Test.StartTest();
        
        string str = ASI_eForm_HK_CustomerFormController.GenerateRefreshToken();
        Test.StopTest();
        
    }
    
    public static testMethod void CustomerFormAPITEST(){
        string requestBody = 'Q2xheSBUZXJyYWNlLDIzLDE0MzUwIENsYXkgVGVycmFjZSBCbHZkLENhcm1lbCxJTiwsVW5pdGVkIFN0YXRlcyw0NjAzMiwzMTctODE4LTM0NjkNCkZhaXJmaWVsZCBDb21tb25zIE1hbGwsMzAsMjcyNyBOb3J0aCBGYWlyZmllbGQgUm9hZCxCZWF2ZXIgQ3JlZWssT0gsLFVuaXRlZCBTdGF0ZXMsNDU0MzEsOTM3LTQyNi0yOTU1DQpUaGUgTm9ydGhlcm4gVHJhaWwgT3V0Zml0dGVycyBTdG9yZSBQYXJpcyBTdCBHZXJtYWluLDQwLDExNSBCb3VsZXZhcmQgU2FpbnQgR2VybWFpbixQYXJpcywsSWxlLWRlLUZyYW5jZSxGcmFuY2UsNzUwMDYsMDAgMzMoMCkgMTQzIDI5OSA1MTkNCkZpcnN0ICYgTWFpbiBUb3duIENlbnRlciw5MSwzMTMzIENpbmVtYSBQb2ludCxHcmFuZCBSYXBpZHMsTUksLFVuaXRlZCBTdGF0ZXMsNjAzMjIsNzE5LTYzOC0zNTAwDQpUaGUgTm9ydGhlcm4gVHJhaWwgT3V0Zml0dGVycyBTdG9yZSBCZXJsaW4gQWxleGEsMzEsIlZJQSBSVUdHRVJPIEdJT1ZBTkVMTEksIDIiLE11bmljaCwsQmF2YXJpYSxHZXJtYW55LDEwMTc4LDAwIDQ5KDApMzAgMzQgMzkgOTAgMTANClRoZSBOb3J0aGVybiBUcmFpbCBPdXRmaXR0ZXJzIFN0b3JlIExvbmRvbiBDYXJuYWJ5LDU1LDggQ2FybmFieSBzdHJlZXQsTG9uZG9uLCwsVW5pdGVkIEtpbmdkb20sVzEgRjlQRCwwMCA0MCgwKTIwIDc3IDM0IDkyIDIzIA0KU3BvcnRzIEFscCw5MywiQXZhZGEgR3VhZGksMzYiLEJhcmNlbG9uYSwsQmFyY2Vsb25hLFNwYWluLDgwMjUsMDAgMzQoMCk5MzQgMzY0IDY0Mw0KU3RyZWV0cyBvZiBXb29kZmllbGQsNjgsNjAxIE5vcnRoIE1hcnRpbmdhbGUsU2NoYXVtYnVyZyxJTCwsVW5pdGVkIFN0YXRlcyw2MDE3Myw4NDctOTk1LTAyMDUNCldpY2tlZCBTUkwsMzUsIlZJQSBSVUdHRVJPIEdJT1ZBTkVMTEksIDIiLFJvbWUsLExhemlvLEl0YWx5LDE5OCwwNiA1NDIyNDYxNjgNCkludGVyc3BvcnQgT3V0ZG9vciBHcmFjaWEsNTMsIkMvIEJvbmF2aXN0YSwgMzUiLEJhcmNlbG9uYSwsQmFyY2Vsb25hLFNwYWluLDgwMTIsMDAgMzQoMCk5MzQgMTU1IDA3NA0KQmxhY2tzLDMyLDM2IC0gMzcgVEhFIFFVQURSQU5ULFJpY2htb25kLCwsVW5pdGVkIEtpbmdkb20sVFc5IDFCUCwwMCA0NCgwKTIwIDg5IDQwIDI4IDA1DQpUcmFuc2EgVHJhdmVsICYgT3V0ZG9vciw0NCxBQVJCRVJHRVJHQVNTRSAyMSxCZXJuLCxCZXJuLFN3aXR6ZXJsYW5kLDMwMTEsMDAgNDEoMCkzMTMgMTIxIDIzNQ0KV2hpdGUgT2FrcyBNYWxsLDYzLDI1MDEgV2VzdCBXYWJhc2ggQXZlbnVlLFNwcmluZ2ZpZWxkLElMLCxVbml0ZWQgU3RhdGVzLDYyNzA0LDg1OS0yODMtMjcyMg0K';
         
        ASI_eForm_Vendor_Form__c form1 = new ASI_eForm_Vendor_Form__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New'),
                                                                      ASI_eForm_JDE_AB_Code__c = '',
                                                                      ASI_eForm_Vendor_Master__c=false,
                                                                      ASI_eForm_Vendor_Name__c='Elaine Test V01',
                                                                      ASI_eForm_Address_Line_1__c='line1',
                                                                      ASI_eForm_Address_Line_2__c='line2',
                                                                      ASI_eForm_Address_Line_3__c='line3',
                                                                      ASI_eForm_Status__c='Draft',
                                                                      ASI_eForm_Country__c='AA-ARUBA',
                                                                      ASI_eForm_Prefix_1__c='852',
                                                                      ASI_eForm_Phone_Fax_1__c='Phone',
                                                                      ASI_eForm_Phone_Fax_Number_1__c='11111',
                                                                      ASI_eForm_Payment_Term__c='095-Open A/C 95 Days',
                                                                      ASI_eForm_Bank_Charges__c='S',
                                                                      ASI_eForm_Alternate_Payee__c='NO',
                                                                      ASI_eForm_MFM_Access__c='YES', 
                                                                      ASI_eForm_Payment_Method__c='Autopaid',
                                                                      ASI_eForm_Default_Currency__c='DZD-Algeria - Dinar',
                                                                      ASI_eForm_Class_Code__c='ADVP',
                                                                      ASI_eForm_CAT_Code_15__c='901',
                                                                      ASI_eForm_Synced_to_JDE__c=true,
                                                                      ASI_eForm_Search_Type__c='V');
        
        insert form1;
        
        
        RestRequest req6 = new RestRequest();
        req6.requestUri ='/services/apexrest/ASI_eForm_HK_eFormAPI/'+form1.Id+':test.jpg';
        req6.httpMethod = 'PATCH';
        req6.requestBody = Blob.valueof(requestBody);
        RestResponse res6 = new RestResponse();
        RestContext.request = req6;
        RestContext.response = res6; 
        ASI_eForm_HK_CustomerFormAPI.InsertContentVersion();
        
    }
}