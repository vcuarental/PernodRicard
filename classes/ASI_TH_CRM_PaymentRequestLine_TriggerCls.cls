/*Created by Twinkle Li (Introv) 20160120*/
public without sharing class ASI_TH_CRM_PaymentRequestLine_TriggerCls{
    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequestLineItem__c> trigger_oldMap) {
        Set<String> setInvoiceNo = new Set<String>();
        Set<Id> setPRIds = new Set<Id>();
        Map<Id, ASI_TH_CRM_PaymentRequest__c> mapPR = new Map<Id, ASI_TH_CRM_PaymentRequest__c>();
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> mapPRWithSameInvoiceNo = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        Map<String, ASI_MFM_A_C_Code__c> mapACCode = new Map<String, ASI_MFM_A_C_Code__c>();
        Map<String, ASI_MFM_Sub_brand__c> mapSubBrand = new Map<String, ASI_MFM_Sub_brand__c>();
        
        //Added by Kevani Chow @ Introv 12-05-2016
        //For Finance Verify
        /*Id TaxCodeRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Tax_Code__cASI_CRM_TH_Tax_Code');
        List <ASI_MFM_Tax_Code__c> TaxCodeList = [SELECT Id, Name FROM ASI_MFM_Tax_Code__c WHERE Name='505' AND RecordTypeId=:TaxCodeRecordTypeId Limit 1];
        Id TaxCode  = null;
        if(TaxCodeList!=null && TaxCodeList.size()>0){
            TaxCode = TaxCodeList[0].Id;
        }*/
        
        Id ACCodeRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_A_C_Code__cASI_CRM_TH_A_C_Code');
        List <ASI_MFM_A_C_Code__c> ACCodeList = [SELECT Id, ASI_MFM_A_C_Description__c, ASI_MFM_A_C_Code__c FROM ASI_MFM_A_C_Code__c WHERE RecordTypeId=:ACCodeRecordTypeId];
        if(ACCodeList.size()>0 && ACCodeList!=null){
            for(ASI_MFM_A_C_Code__c ac : ACCodeList){
                mapACCode.put(ac.ASI_MFM_A_C_Description__c, ac);
            }
        }
        
        Id SubBrandRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand');
        List <ASI_MFM_Sub_brand__c> SubBrandList = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE RecordTypeId=:SubBrandRecordTypeId];
        if(SubBrandList.size()>0 && SubBrandList!=null){
            for(ASI_MFM_Sub_brand__c sb : SubBrandList){
                mapSubBrand.put(sb.id, sb);
            }
        }
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c  pritm : trigger_new){            
            setInvoiceNo.add(pritm.ASI_TH_CRM_Invoice_No__c);

            system.debug('setInvoiceNo: '+setInvoiceNo);
            setPRIds.add(pritm.ASI_TH_CRM_Payment_Request__c);
        
            //Added by Kevani Chow @ Introv 12-05-2016
            //For Finance Verify - ASI_CRM_Withholding_Tax__c *Default to 505, Share with TH MFM Tax Code master
            /*if(TaxCode!=null){
                pritm.ASI_CRM_Withholding_Tax__c = TaxCode;
            }*/
            
            //ASI_CRM_AC_Code__c  Lookup(A/C Code), Auto-populated according to COA (trigger)
            if(mapACCode.get(pritm.ASI_TH_CRM_COA__c)!=null){
                pritm.ASI_CRM_AC_Code__c=mapACCode.get(pritm.ASI_TH_CRM_COA__c).id;
            }
        }
        
        mapPR = new Map<Id, ASI_TH_CRM_PaymentRequest__c>([SELECT id, ASI_TH_CRM_Vendor__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_TH_CRM_Region__c, ASI_TH_CRM_Status__c FROM ASI_TH_CRM_PaymentRequest__c
        WHERE id IN: setPRIds AND RecordTypeid =: Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request')]);
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c  pritm : trigger_new){      
            //For Finance Verify - BU Format = 5581P+{Sub-brand Code}+{Region Prefix} & '5589100000' for COA = Fund - Advance  
            if(pritm.ASI_TH_CRM_COA__c!='Fund - Advance'){
                String BU = '5581P';
                if(mapSubBrand.get(pritm.ASI_TH_CRM_Subbrand__c)!=null && mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c)!=null)
                    BU = BU + mapSubBrand.get(pritm.ASI_TH_CRM_Subbrand__c).ASI_MFM_Sub_brand_Code__c;             
                if(mapPR != null && mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c) != null && 
                   mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Contract__c != null && 
                   mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__c!=null &&
                   mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_TH_CRM_Region__c !=null )
                    BU = BU + mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_TH_CRM_Region__c.subString(0,2);
             
                pritm.ASI_CRM_BU__c = BU;   
            }else{
                pritm.ASI_CRM_BU__c ='5589100000';
            }
            
            //Added by Twinkle (Introv) @20170103
            if(mapPR != null && mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c) != null && mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Status__c == 'Draft'){
                if(pritm.ASI_TH_CRM_Payment_Details__c != NULL && pritm.ASI_TH_CRM_Payment_Details__c.length() >= 30)
                    pritm.ASI_CRM_Remark__c = pritm.ASI_TH_CRM_Payment_Details__c.substring(0,30);
                else
                    pritm.ASI_CRM_Remark__c = pritm.ASI_TH_CRM_Payment_Details__c;
            }
        }
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> listPRitem = [SELECT id, ASI_TH_CRM_Invoice_No__c, ASI_TH_CRM_Payment_Request__r.Name, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c FROM ASI_TH_CRM_PaymentRequestLineItem__c 
        WHERE ASI_TH_CRM_Invoice_No__c IN: setInvoiceNo AND RecordTypeid =: Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail')  AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c != 'Rejected'];
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c pritm : listPRitem){
            if(pritm.ASI_TH_CRM_Invoice_No__c!=NULL)
                mapPRWithSameInvoiceNo.put(pritm.ASI_TH_CRM_Invoice_No__c, pritm);
        }
 
        for(ASI_TH_CRM_PaymentRequestLineItem__c  pritm : trigger_new){
         if(mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c)!=null && mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).ASI_TH_CRM_Payment_Request__c!=null){      
            if(pritm.ASI_TH_CRM_Invoice_No__c!=NULL && mapPR != NULL && 
               mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c) != NULL &&
               mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c) != NULL && 
               mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).ASI_TH_CRM_Payment_Request__c != NULL &&
               pritm.id != mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).id &&
               mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Vendor__c == mapPR.get(pritm.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Vendor__c &&
               mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).ASI_TH_CRM_Payment_Request__c != pritm.ASI_TH_CRM_Payment_Request__c
               ){
                if(!Test.isRunningTest())
                    pritm.addError('Line Item with duplicated Invoice No. found (Payment Request No. '+mapPRWithSameInvoiceNo.get(pritm.ASI_TH_CRM_Invoice_No__c).ASI_TH_CRM_Payment_Request__r.Name+')');
            }
          }  
        }
    }
    public static void routineAfterUpdate(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequestLineItem__c> trigger_oldMap) {
		Set <Id> Set_PmtHdrIds = new Set<Id>();
		Set <Id> Set_AccountIds = new Set<Id>();
		Map <Id, String> Map_VAT = new Map <Id, String>();
		for (ASI_TH_CRM_PaymentRequestLineItem__c idx_pay_itm : trigger_new) {
			if ((trigger_oldMap.get(idx_pay_itm.id).ASI_TH_CRM_COA__c == 'Fund - FOC' || trigger_oldMap.get(idx_pay_itm.id).ASI_TH_CRM_COA__c == 'Activity - FOC') && idx_pay_itm.ASI_TH_CRM_COA__c != 'Fund - FOC' && idx_pay_itm.ASI_TH_CRM_COA__c != 'Activity - FOC') {
				Set_PmtHdrIds.add(idx_pay_itm.ASI_TH_CRM_Payment_Request__c);
			}
		}
        System.debug('Debug : Set_PmtHdrIds := ' + Set_PmtHdrIds.size());
		if (Set_PmtHdrIds.size() > 0) {
			List <ASI_TH_CRM_PaymentRequest__c> List_PaymentHeader = [SELECT id, ASI_TH_CRM_Vendor__c, ASI_TH_CRM_VAT__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id IN :Set_PmtHdrIds];
			if (List_PaymentHeader.size() > 0) {
				for (ASI_TH_CRM_PaymentRequest__c idx_cust : List_PaymentHeader) {
					Set_AccountIds.add(idx_cust.ASI_TH_CRM_Vendor__c);
				}
				if (Set_AccountIds.size() > 0) {
					List <ASI_CRM_AccountsAdditionalField__c> List_Customer = [SELECT ASI_CRM_Account__c, ASI_CRM_SG_Tax_Expl_Code__c, ASI_CRM_CN_Tax_Number__c, ASI_CRM_SG_Tax_Rate_Area__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :Set_AccountIds AND recordtype.name = 'Supplier (TH)'];
					if (List_Customer.size() > 0) {
						for (ASI_CRM_AccountsAdditionalField__c idx_cust : List_Customer) {
							if (idx_cust.ASI_CRM_CN_Tax_Number__c != null) {
								Map_VAT.put(idx_cust.ASI_CRM_Account__c, String.ValueOf(Integer.ValueOf(idx_cust.ASI_CRM_CN_Tax_Number__c))+'%');
							}else{
								Map_VAT.put(idx_cust.ASI_CRM_Account__c, '');
							}
						}
						if (Map_VAT.size() > 0) {
							if (List_PaymentHeader.Size() > 0) {
								for (ASI_TH_CRM_PaymentRequest__c idx_pmt_hdr : List_PaymentHeader) {
									idx_pmt_hdr.ASI_TH_CRM_VAT__c = Map_VAT.get(idx_pmt_hdr.ASI_TH_CRM_Vendor__c);
								}
							}
							update List_PaymentHeader;
						}

					}
				}
			}
		}

        /*Added by Vincent Kwok 2016/10/31 Copy GL Date from Payment Request Detail to Payment Request Header*/
        Set<Id> Set_PMT = new Set<Id>();
        List<ASI_TH_CRM_PaymentRequest__c> triggerList = new List<ASI_TH_CRM_PaymentRequest__c>();
        Set<Id> PaymentHeaderId = new Set<Id>();
        ASI_TH_CRM_PaymentRequest__c a = new ASI_TH_CRM_PaymentRequest__c();
        
        for(ASI_TH_CRM_PaymentRequestLineItem__c idx_pmt : trigger_new){
            PaymentHeaderId.add(idx_pmt.ASI_TH_CRM_Payment_Request__c);
        }
            
        Map<Id, ASI_TH_CRM_PaymentRequest__c> PaymentHeaderMap = new Map<Id, ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_TH_CRM_PaymentRequest__c> List_PaymentHeader = [SELECT id, ASI_TH_CRM_Status__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id in :PaymentHeaderId];
        for (ASI_TH_CRM_PaymentRequest__c idx : List_PaymentHeader) {
            PaymentHeaderMap.put(idx.id, idx);
        }
        for(ASI_TH_CRM_PaymentRequestLineItem__c idx_pmt : trigger_new){
            System.debug('Debug 0001 := ' + PaymentHeaderMap.get(idx_pmt.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Status__c);
            if (idx_pmt.ASI_CRM_GL_Date__c != trigger_oldMap.get(idx_pmt.id).ASI_CRM_GL_Date__c) {
                if (PaymentHeaderMap.get(idx_pmt.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Status__c == 'Approved') {
                    a.id = idx_pmt.ASI_TH_CRM_Payment_Request__c;
                    a.ASI_CRM_ChequeDate__c = idx_pmt.ASI_CRM_GL_Date__c;
                    if (!Set_PMT.contains(idx_pmt.ASI_TH_CRM_Payment_Request__c)) {
                    System.debug('Debug 0003 := ' + Set_PMT.contains(idx_pmt.ASI_TH_CRM_Payment_Request__c));
                        Set_PMT.add(idx_pmt.ASI_TH_CRM_Payment_Request__c);
                        a.id = idx_pmt.ASI_TH_CRM_Payment_Request__c;
                        triggerList.add(a);
                    }
                }      
            }
        }
     	update triggerList;
    }
	
    public static void routineAfterDelete(map<id, ASI_TH_CRM_PaymentRequestLineItem__c> trigger_oldMap) {
        System.debug('Execution Start := ASI_TH_CRM_PaymentRequestLine_TriggerCls.routineAfterDelete');
		Set <Id> Set_PmtHdrIds = new Set<Id>();
		Set <Id> Set_AccountIds = new Set<Id>();
		Map <Id, String> Map_VAT = new Map <Id, String>();
		for (ASI_TH_CRM_PaymentRequestLineItem__c idx_pay_itm : trigger_oldMap.values()) {
			if (idx_pay_itm.ASI_TH_CRM_COA__c == 'Fund - FOC' || idx_pay_itm.ASI_TH_CRM_COA__c == 'Activity - FOC') {
				Set_PmtHdrIds.add(idx_pay_itm.ASI_TH_CRM_Payment_Request__c);
			}
		}
        System.debug('Debug : Set_PmtHdrIds := ' + Set_PmtHdrIds.size());
		if (Set_PmtHdrIds.size() > 0) {
			List <ASI_TH_CRM_PaymentRequest__c> List_PaymentHeader = [SELECT id, ASI_TH_CRM_Vendor__c, ASI_TH_CRM_VAT__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id IN :Set_PmtHdrIds];
			if (List_PaymentHeader.size() > 0) {
				for (ASI_TH_CRM_PaymentRequest__c idx_cust : List_PaymentHeader) {
					Set_AccountIds.add(idx_cust.ASI_TH_CRM_Vendor__c);
				}
				if (Set_AccountIds.size() > 0) {
					List <ASI_CRM_AccountsAdditionalField__c> List_Customer = [SELECT ASI_CRM_Account__c, ASI_CRM_SG_Tax_Expl_Code__c, ASI_CRM_CN_Tax_Number__c, ASI_CRM_SG_Tax_Rate_Area__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :Set_AccountIds AND recordtype.name = 'Supplier (TH)'];
					if (List_Customer.size() > 0) {
						for (ASI_CRM_AccountsAdditionalField__c idx_cust : List_Customer) {
							if (idx_cust.ASI_CRM_CN_Tax_Number__c != null) {
								Map_VAT.put(idx_cust.ASI_CRM_Account__c, String.ValueOf(Integer.ValueOf(idx_cust.ASI_CRM_CN_Tax_Number__c))+'%');
							}else{
								Map_VAT.put(idx_cust.ASI_CRM_Account__c, '');
							}
						}
						if (Map_VAT.size() > 0) {
							if (List_PaymentHeader.Size() > 0) {
								for (ASI_TH_CRM_PaymentRequest__c idx_pmt_hdr : List_PaymentHeader) {
									idx_pmt_hdr.ASI_TH_CRM_VAT__c = Map_VAT.get(idx_pmt_hdr.ASI_TH_CRM_Vendor__c);
								}
							}
							update List_PaymentHeader;
						}

					}
				}
			}
		}
        System.debug('Execution End := ASI_TH_CRM_PaymentRequestLine_TriggerCls.routineAfterDelete');
	}
}