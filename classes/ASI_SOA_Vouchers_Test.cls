/*********************************************************************************
 * Name:ASI_SOA_Vouchers_Test
 * Description: 
 *
 * ref : ASI_SOA_Vouchers_Test
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/10/2020       Wilken Lee              [WL 1.0] Assign JDE Customer to Payment 
*********************************************************************************/
@isTest

public class ASI_SOA_Vouchers_Test {
    
    static testMethod void paymentRequest_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
            
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');//WL 1.0
            
            customer1.ASI_CRM_CN_JDE_Code__c = '504073';    //WL 1.0
            update customer1;   //WL 1.0
            
            ASI_TH_CRM_Contract__c contract = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number', 
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 2, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Final',
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    ASI_CRM_CN_Outlet_WS__c = customer1.id,
                    ASI_CRM_Version__c = '1',
                    ASI_CRM_Obsolete_Version__c = FALSE,
                    RecordTypeId = idRTContractNormal
                );
            
            insert contract;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget'));
            insert ct;
            
            ASI_CRM_ContractSalesStaffIncentive__c ss = new ASI_CRM_ContractSalesStaffIncentive__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id,
                                                                                                   recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive'));
            insert ss;
            
            ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', 
                                                                                           ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive'));
            insert vi;
            
            ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL',
                                                                                         ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', ASI_CRM_Type__c = 'Type', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive'));
            insert oi;
            
            ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement'));
            insert pp;
            
            
            
            ASI_TH_CRM_PaymentRequest__c pr = new ASI_TH_CRM_PaymentRequest__c(Name = 'Auto-generated Number', ASI_CRM_CN_OutletWS__c = customer1.id, 
                                                                               ASI_TH_CRM_Contract__c = contract.id, ASI_CRM_ForAccountOf__c = 'TEST', 
                                                                               ASI_CRM_CN_Description__c = 'TEST',ASI_CRM_A_P_Type__c=true,ASI_TH_CRM_Status__c = 'Final',
                                                                               recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request'));
            insert pr; 
            
            
            
            ASI_TH_CRM_PaymentRequestLineItem__c prl = new ASI_TH_CRM_PaymentRequestLineItem__c();
            prl.ASI_TH_CRM_Payment_Request__c = pr.Id;
            prl.ASI_CRM_SKU__c = sku1.Id;
            prl.ASI_CRM_CN_Actual_Vol__c = 60;
            prl.ASI_CRM_SetupCode__c = 'VOLC';
            prl.ASI_TH_CRM_Amount__c = 24600;
            prl.ASI_CRM_MY_Adjusted_Amount__c = 24600;
            prl.ASI_CRM_Tax_Amount__c = 1476;
            prl.ASI_CRM_Remark__c = '201802';
            insert prl;
            
            
            ASI_CRM_MY_Settings__c my_cs = new ASI_CRM_MY_Settings__c(ASI_CRM_Bridge_Payment_Endpoint__c ='https://e',
                                                                      ASI_CRM_Bridge_Payment_API_Key__c ='TestTest',
                                                                      ASI_CRM_Enterprise_API_URL__c = 'OKok');
            insert my_cs;
            
            
            set<Id> FVPayIdSet = NEW set<Id>();
            FVPayIdSet.add(pr.Id);
            ASI_CRM_MY_PaymentInterface_Batch  obj = new ASI_CRM_MY_PaymentInterface_Batch(FVPayIdSet);
            DataBase.executeBatch(obj);
            
            
            
            Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/ASI_SOA_Vouchers/'+pr.id;  //Request URL
            req.httpMethod = 'Get'; 
            //req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            ASI_SOA_Vouchers.getPaymentRequestByID();
            
            
            /*
[
{
"Id": "a8hM00000001OgKIAU",
"PaymentDate":"2024-01-01"
} 
]
*/
              
                        
            RestRequest req3 = new RestRequest();
            req3.requestUri ='/services/apexrest/ASI_SOA_Vouchers/'+pr.Id;
            req3.httpMethod = 'PATCH';
            req3.requestBody =Blob.valueof('[ { "Id": "'+pr.id+'", "PaymentDate":"2024-01-01" } ]');
            RestResponse res3 = new RestResponse();
            RestContext.request = req3;
            RestContext.response = res3; 
            ASI_SOA_Vouchers.updateVoucherNumber();

            
            RestRequest req4 = new RestRequest();
            req4.requestUri ='/services/apexrest/ASI_SOA_Vouchers/'+pr.Id;
            req4.httpMethod = 'PATCH';
            req4.requestBody =Blob.valueof('{ "Id": "'+pr.id+'", "VoucherNumber":"1234"   }');
            RestResponse res4 = new RestResponse();
            RestContext.request = req4;
            RestContext.response = res4; 
            ASI_SOA_Vouchers.updateVoucherNumber();
            
            
            
            RestRequest req5 = new RestRequest();
            req5.requestUri ='/services/apexrest/ASI_SOA_Vouchers/'+pr.Id;
            req5.httpMethod = 'PATCH';
            req5.requestBody =Blob.valueof('[ {  "VoucherNumber":"61158", "PaymentDate":"2024-01-01" } ]');
            RestResponse res5 = new RestResponse();
            RestContext.request = req5;
            RestContext.response = res5; 
            ASI_SOA_Vouchers.updateVoucherNumber();
            
            
            
            RestRequest req6 = new RestRequest();
            req6.requestUri ='/services/apexrest/ASI_SOA_Vouchers/'+pr.Id;
            req6.httpMethod = 'PATCH';
            req6.requestBody =Blob.valueof('{ "Id": "'+pr.id+'", "VoucherNumber":"61158" , "PaymentDate":"2024-01-01"  }');
            RestResponse res6 = new RestResponse();
            RestContext.request = req6;
            RestContext.response = res6; 
            ASI_SOA_Vouchers.updateVoucherNumber();
             
            list<ASI_TH_CRM_PaymentRequest__c> trigger_new = new list<ASI_TH_CRM_PaymentRequest__c> ();
            
            trigger_new.add(pr);
            ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeInsert(trigger_new);
            
            map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap = new map<id, ASI_TH_CRM_PaymentRequest__c>();
            trigger_oldMap.put(pr.id,pr);   
            
            ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeUpdate(trigger_new,trigger_oldMap);
            ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeDelete(trigger_new);
            
            pr.ASI_TH_CRM_Status__c ='Cancelled';
            update pr;
            Test.stopTest();
            
        }
    }
}