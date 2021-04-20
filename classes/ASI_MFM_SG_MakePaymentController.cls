/*********************************************************************************
 * Name:ASI_MFM_SG_MakePaymentController
 * Description: 
 * Test Class: ASI_MFM_SG_PaymentTestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/01/2018		Linus					[LH 1.0] Block user to make payment if PO balace is 0
 * 15/08/2018       Linus              		[LH 2.0] Add a filter to exclude PO with [No Payment Request Required] 
 * 01/02/2021       PR COE                  [COE1.0]upgrade to lightning
 *********************************************************************************/
public with sharing class ASI_MFM_SG_MakePaymentController {
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();   
    
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    public boolean initcheck {get; set;}{initcheck=true;}
    public string Msg {get; set;}{Msg='';}
    public ASI_MFM_Payment__c pa {get; set;} 
    public ASI_MFM_SG_MakePaymentController(apexpages.standardController sc){}
    
     public pageReference getPrefixes() {
         pa= new ASI_MFM_Payment__c();
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
         
        // [LH 1.0]        
        String poid = ApexPages.currentPage().getParameters().get('id');
        ASI_MFM_PO__c po =[select id, ASI_MFM_PO_Balance__c, ASI_MFM_SG_No_Payment_Request_Required__c from ASI_MFM_PO__c where id =: poid limit 1];        
         
        if (u.userRole.developerName == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The role of the user is not defined yet');
            apexpages.addmessage(err); 
        }
        else if (u.asi_mfm_country__c == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The country of the user is not defined yet');
            apexpages.addmessage(err); 
        }
        // [LH 1.0]
        else if (po.ASI_MFM_PO_Balance__c == 0) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'PO Balance is equal to 0. Cannot create Payment');
            apexpages.addmessage(err); 
        }
        // End - [LH 1.0]        
        // [LH 2.0]
        else if (po.ASI_MFM_SG_No_Payment_Request_Required__c == true) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'This PO is no needed to create payment.');
            apexpages.addmessage(err); 
        }
        // End - [LH 2.0]
        else {
            list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.ASI_MFM_Location__c from asi_mfm_role_prefix_relationship__c
                                                         where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                                                             px_map.put(px.asi_mfm_prefix__c, px);
                                                             px_list.add(px);    
                                                         }           
            if (px_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err); 
            }
            else if (px_list.size() == 1) {
                selected_prefix = px_list[0].asi_mfm_prefix__c;
                
            }
            else {
                available_prefixes = new list<selectOption>();
                available_prefixes.add(new selectOption('', '-- None --'));
                for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                    available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                }
            }
        }       
        return null;
    }
    
    
    public pageReference proceed() {
        boolean paymentcreated=false;
        if (selected_prefix == null || selected_prefix == '') {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first');
            apexpages.addmessage(err); 
            return null;            
        }
        else {
            String poid = ApexPages.currentPage().getParameters().get('id');
            ASI_MFM_PO__c po =[select id, Name, ASI_MFM_Supplier_Name__c,ASI_MFM_Currency__c from ASI_MFM_PO__c where id =: poid];
            List<ASI_MFM_PO_Line_Item__c> polist=[select id,name,ASI_MFM_Amount__c, ASI_MFM_Requested_Balance__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: poid];
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');  //ASI_MFM_PO_Number__c 
            ASI_MFM_Payment__c insertpayment = new ASI_MFM_Payment__c(ASI_MFM_Prefix__c=selected_prefix,
                                                                      recordTypeId=rt_map.get('ASI_MFM_SG_Payment'),
                                                                      ASI_MFM_PO_Number__c=po.name,
                                                                      ASI_MFM_Invoice_Date__c=pa.ASI_MFM_Invoice_Date__c,
                                                                      ASI_MFM_Invoice_Number__c=pa.ASI_MFM_Invoice_Number__c,
                                                                      ASI_MFM_Currency__c=po.ASI_MFM_Currency__c,
                                                                     ASI_MFM_Supplier_Name__c=po.ASI_MFM_Supplier_Name__c); 
            
            try{
                insert insertpayment;
                paymentcreated=true;
                
                
            } catch (Exception e) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                apexpages.addmessage(err); 
                return null;  
            }
            PageReference pageRef = null;
            
            if(paymentcreated){
                //[COE1.0]//pageRef = new PageReference('/apex/ASI_MFM_SG_InputPaymentItemsPage?&id='+insertpayment.id+'&poName='+po.Name);
                pageRef = new PageReference('/lightning/cmp/c__ASI_MFM_SG_Payment_Manage_All?c__pid='+insertpayment.id+'&poName='+po.Name);
                pageRef.setRedirect(true);
            }
            return pageRef;    
        }
           
        
    }
    
}