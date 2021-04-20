/*********************************************************************************
 * Name: ASI_CRM_SG_Payment_ValidationHelper
 * Description: Validation Helper for Amount Exceed between Payment and Contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-02-16       Laputa: Conrad          Created
 */
public class ASI_CRM_SG_Payment_ValidationHelper {
    
    private boolean isPaymentObject {get;set;}
    
    private List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentItemList {get;set;}
    private List<ASI_TH_CRM_PaymentRequest__c> paymentHeaderList {get;set;}
    
    private List<ASI_CRM_ContractTarget__c> contractTargetItemList {get;set;}
    
    private sObject headerObject {get;set;}
    private List<sObject> sObjList {get;set;}

    private Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>> subBrand_PaymentListMap {get;set;}
    private Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap {get;set;}
    
    private Set<ID> contractSubrandIDSet {get;set;}
    private Set<ID> paymentSubBRandIDSet {get;set;}
    
    private boolean isGST{get;set;}

    public ASI_CRM_SG_Payment_ValidationHelper (boolean isPayment, sObject header, List<sObject> sObList) {
        this.contractSubrandIDSet = new Set<ID>();
        this.paymentSubBRandIDSet = new Set<ID>();
        this.isPaymentObject = isPayment;
        this.paymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        this.contractTargetItemList = new List<ASI_CRM_ContractTarget__c>();
        this.headerObject = header;
        this.sObjList = sObList;
        this.isGST = false;
        
        if(isPayment) {
            ASI_TH_CRM_PaymentRequest__c headerPayment = (ASI_TH_CRM_PaymentRequest__c)header;
            this.isGST = headerPayment.ASI_CRM_SG_GST_Inclusive__c;
        }
        
        if(isPayment != null && header != null && sObList != null) {
            if(sObList.size() > 0 && isPayment) {
                initData();
                System.debug('Initialize data');
            }
        }
    }
    
    public void initData() {
    
        ID contractHeaderID = null;
        ID paymentRequestTempid = null;
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentItemListTemp = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<ASI_CRM_ContractTarget__c> contractTargetListTemp0 = new List<ASI_CRM_ContractTarget__c>();
        
        if(isPaymentObject) {
            paymentItemListTemp = (List<ASI_TH_CRM_PaymentRequestLineItem__c>)sObjList;
            ASI_TH_CRM_PaymentRequest__c paymentRequestTemp = (ASI_TH_CRM_PaymentRequest__c)headerObject;
            paymentRequestTempid = paymentRequestTemp.id;
            contractHeaderID = paymentRequestTemp.ASI_TH_CRM_Contract__c;
            
        } else {
            ASI_CRM_ContractTarget__c contractHeaderTemp = (ASI_CRM_ContractTarget__c)headerObject;
            contractTargetListTemp0 = (List<ASI_CRM_ContractTarget__c>)sObjList;
            contractHeaderID = contractHeaderTemp.id;
        }
            
        if(contractHeaderID != null) {
                
            paymentHeaderList = paymentRequestTempid != null ? 
            [SELECT ID, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = : contractHeaderID AND ID <> : paymentRequestTempid]
            :
            [SELECT ID, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = : contractHeaderID];
                
            Set<ID> paymentHeaderIds = new Set<ID>();
            for(ASI_TH_CRM_PaymentRequest__c paymentReq : paymentHeaderList) {
                paymentHeaderIds.add(paymentReq.id);
            }
            paymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            
            if(paymentHeaderIds.size() > 0) {
                paymentItemList = [SELECT ID, Name, ASI_TH_CRM_Payment_Request__c, ASI_CRM_SG_Sub_brand__c, ASI_TH_CRM_Amount__c, ASI_CRM_SG_Type__c 
                                    FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                    WHERE ASI_TH_CRM_Payment_Request__c IN : paymentHeaderIds
                                    AND ASI_CRM_SG_Sub_brand__c <> null
                                    AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = : 'Approved'
                                    ORDER BY ASI_CRM_SG_Sub_brand__c];
            }
             
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : paymentItemListTemp) {
                paymentItemList.add(paymentItem);
            }
                
            this.subBrand_PaymentListMap = new Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
                
            ID subBrandID = null;
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentReqItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            
            Set<ID> subBrandIDsSet = new Set<ID>();
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : paymentItemList) {
                paymentSubBRandIDSet.add(paymentItem.ASI_CRM_SG_Sub_brand__c);
                if(!subBrandIDsSet.contains(paymentItem.ASI_CRM_SG_Sub_brand__c)) {
                    
                    for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem1 : paymentItemList) {
                        if(paymentItem.ASI_CRM_SG_Sub_brand__c == paymentItem1.ASI_CRM_SG_Sub_brand__c) {
                            paymentReqItemList.add(paymentItem1);
                        }
                    }
                    if(paymentReqItemList.size() > 0) {
                        this.subBrand_PaymentListMap.put(paymentItem.ASI_CRM_SG_Sub_brand__c, paymentReqItemList);
                    }
                }
                subBrandIDsSet.add(paymentItem.ASI_CRM_SG_Sub_brand__c);
                paymentReqItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            }
            subBrandID = null;
            System.debug('this.subBrand_PaymentListMap ' + this.subBrand_PaymentListMap);
            System.debug('this.subBrand_PaymentListMap.size() ' + this.subBrand_PaymentListMap.size());
            System.debug('contractTargetListTemp0.size() ' + contractTargetListTemp0.size());
            
            contractTargetItemList = contractTargetListTemp0.size() > 0 ? contractTargetListTemp0 :
                                        [SELECT ID, Name, ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                                        ASI_CRM_SG_Events_Free_Bottles__c, ASI_CRM_SG_Events__c, 
                                        ASI_CRM_SG_Signages_Advertising_Spot__c, ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,
                                        ASI_CRM_SG_Anniversary__c, ASI_CRM_SG_Anniversary_Free_Bottles__c,
                                        ASI_CRM_SG_Trade_Incentive_Trips__c, ASI_CRM_SG_Product_Branding_Display__c,
                                        ASI_CRM_SG_Ad_hoc_Promotions__c, ASI_CRM_SG_Btls_Per_Case__c,ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c
                                        FROM ASI_CRM_ContractTarget__c
                                        WHERE ASI_CRM_Contract__c = : contractHeaderID
                                        AND ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c != null
                                        AND ASI_CRM_SKU__c != null
                                        ORDER BY ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c];
                
            this.subBrand_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                
            List<ASI_CRM_ContractTarget__c> contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
            
            // retrieve the subbrand according to SKU
            Map<ID, ID> subBrandMap = new Map<ID, ID>();
            
            
            Set<ID> skuIDSet = new Set<ID>();
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetItemList) {
                if(contractTarget.ASI_CRM_SKU__c != null) {
                    skuIDSet.add(contractTarget.ASI_CRM_SKU__c);
                }
            }
                
            if(skuIDSet.size() > 0) {
                List<ASI_MFM_SKU_Code__c> skuListTemp = [SELECT ID, Name, ASI_MFM_Sub_brand__c FROM ASI_MFM_SKU_Code__c
                                                            WHERE ID IN : skuIDSet];
                
                system.debug('skuListTemp ' + skuListTemp);
                    
                for(ASI_MFM_SKU_Code__c sku : skuListTemp) {
                    subBrandMap.put(sku.id, sku.ASI_MFM_Sub_brand__c);
                    contractSubrandIDSet.add(sku.ASI_MFM_Sub_brand__c);
                }
            }
            
            system.debug('subBrandMap.values() ' + subBrandMap.values() + ' subBrandMap.keySet() ' + subBrandMap.keySet());
            
            /*for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetItemList) {
                    
                if(subBrandID == null) {
                    subBrandID = subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c);
                    contractTargetListTemp.add(contractTargetItem);
                } else if(subBrandID != subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c)) {
                    
                    this.subBrand_ContractTargetListMap.put(subBrandID, contractTargetListTemp);
                    subBrandID = subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c);
                    contractTargetListTemp= new List<ASI_CRM_ContractTarget__c>();
                    contractTargetListTemp.add(contractTargetItem);
                } else {
                    contractTargetListTemp.add(contractTargetItem);
                }
                    
            }*/
            
            subBrandIDsSet = new Set<ID>();
            for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetItemList) {
                
                if(!subBrandIDsSet.contains(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c))) {
                    
                    for(ASI_CRM_ContractTarget__c contractTargetItem1 : contractTargetItemList) {
                        if(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c) == subBrandMap.get(contractTargetItem1.ASI_CRM_SKU__c)) {
                            contractTargetListTemp.add(contractTargetItem1);
                        }
                    }
                    if(contractTargetListTemp.size() > 0) {
                        this.subBrand_ContractTargetListMap.put(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c), contractTargetListTemp);
                    }
                }
                subBrandIDsSet.add(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c));
                contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
            }
                
        }
        
    }
    
    public String validateAmountExceed() {
        
        String amountExceed = '';
        
        //Add checking if payment sub brand exist in the related contract
        
        System.debug('Payment Size ' + paymentItemList.size() + ' contract Size ' + contractTargetItemList.size());
        
        if(subBrand_PaymentListMap == null  || subBrand_ContractTargetListMap == null){
            return '';
        }
        
        for(ID subbrandID : paymentSubBRandIDSet) {
            if(!contractSubrandIDSet.contains(subbrandID)) {
                amountExceed += 'Payment sub-brand does not exist in the related Contract. ';
            }
        }
        
        system.debug('subBrand_ContractTargetListMap.values() ' + subBrand_ContractTargetListMap.values() + ' subBrand_PaymentListMap.values() ' + subBrand_PaymentListMap.values() );
        system.debug('subBrand_ContractTargetListMap.keySet() ' + subBrand_ContractTargetListMap.keySet() + ' subBrand_PaymentListMap.keySet() ' + subBrand_PaymentListMap.keySet() );
        
        for (Id subBrandID : subBrand_ContractTargetListMap.keySet()) {
            
            List<ASI_CRM_ContractTarget__c> contractTargetListTemp = subBrand_ContractTargetListMap.get(subBrandID);
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineListTemp = subBrand_PaymentListMap.get(subBrandID) == null ? new List<ASI_TH_CRM_PaymentRequestLineItem__c>() : subBrand_PaymentListMap.get(subBrandID);
            System.debug('contractTargetListTemp  ' + contractTargetListTemp  + ' paymentLineListTemp ' + paymentLineListTemp);
            Decimal totalCash = 0;
            Decimal totalEvents = 0;
            Decimal totalSignages = 0;
            Decimal totalTradeIncentives = 0;
            Decimal totalProductBranding = 0;
            Decimal totalAdhoc = 0;
            Decimal totalAnniversary = 0;
            
            Decimal totalCashPayment = 0;
            Decimal totalEventsPayment = 0;
            Decimal totalSignagesPayment = 0;
            Decimal totalTradeIncentivesPayment = 0;
            Decimal totalProductBrandingPayment = 0;
            Decimal totalAdhocPayment = 0;
            Decimal totalAnniversaryPayment = 0;
            
            Decimal percentage = 0.07;
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : paymentLineListTemp) {
                Decimal amount = paymentLine.ASI_TH_CRM_Amount__c != null ? paymentLine.ASI_TH_CRM_Amount__c : 0;
                if(isGST) {
                    amount = amount - amount*percentage;  
                }
                
                if(paymentLine.ASI_CRM_SG_Type__c == 'Events') {
                    totalEventsPayment += amount;
                } else if(paymentLine.ASI_CRM_SG_Type__c == 'Signages / Advertising Spot') {
                    totalSignagesPayment += amount;
                } else if(paymentLine.ASI_CRM_SG_Type__c == 'Trade Incentive Trips') {
                    totalTradeIncentivesPayment += amount;
                } else if(paymentLine.ASI_CRM_SG_Type__c == 'Product Branding Display') {
                    totalProductBrandingPayment += amount;
                } else if(paymentLine.ASI_CRM_SG_Type__c == 'Ad-hoc Promotions') {
                    totalAdhocPayment += amount;
                } else if(paymentLine.ASI_CRM_SG_Type__c == 'Anniversary') {
                    totalAnniversaryPayment += amount;
                }
            }
            
            for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetListTemp) {
                
                Decimal btlsPerCase = contractTargetItem.ASI_CRM_SG_Btls_Per_Case__c != null ? contractTargetItem.ASI_CRM_SG_Btls_Per_Case__c : 0;
                Decimal priceWsOnTrade = contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
                Decimal eventsCase = contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c : 0;
                Decimal signageCase = contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c : 0;
                Decimal anniversaryCase = contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c : 0;
                
                Decimal eventsCaseConvert = eventsCase * btlsPerCase * priceWsOnTrade;
                Decimal signageCaseConvert = signageCase * btlsPerCase * priceWsOnTrade;
                Decimal anniversaryCaseConvert = anniversaryCase * btlsPerCase * priceWsOnTrade;
                
                totalEvents += eventsCaseConvert + (contractTargetItem.ASI_CRM_SG_Events__c != null ? contractTargetItem.ASI_CRM_SG_Events__c : 0);
                totalSignages += signageCaseConvert + (contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c : 0);
                totalTradeIncentives += contractTargetItem.ASI_CRM_SG_Trade_Incentive_Trips__c != null ? contractTargetItem.ASI_CRM_SG_Trade_Incentive_Trips__c : 0;
                totalProductBranding += contractTargetItem.ASI_CRM_SG_Product_Branding_Display__c != null ? contractTargetItem.ASI_CRM_SG_Product_Branding_Display__c : 0;
                totalAdhoc += contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c != null ? contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c : 0;
                totalAnniversary += anniversaryCase;
            }
            
            System.debug('totalEventsPayment ' + totalEventsPayment + ' totalEvents ' + totalEvents);
            
            if(totalEventsPayment > totalEvents) {
                amountExceed += 'Total events payment of ' + totalEventsPayment + ' is over than the total events of ' + totalEvents + '. ';
            }
            if(totalSignagesPayment > totalSignages) {
                amountExceed += 'Total signage payment of ' + totalSignagesPayment + ' is over than the total signage of ' + totalSignages + '. ';
            }
            if(totalTradeIncentivesPayment > totalTradeIncentives) {
                amountExceed += 'Total trade incentives payment of ' + totalTradeIncentivesPayment + ' is over than the total trade incentives of ' + totalTradeIncentives + '. ';
            }
            if(totalProductBrandingPayment > totalProductBranding) {
                amountExceed += 'Total product branding payment of ' + totalProductBrandingPayment + ' is over than the total product branding of ' + totalProductBranding + '. ';
            }
            if(totalAdhocPayment > totalAdhoc) {
                amountExceed += 'Total ad hoc payment of ' + totalAdhocPayment + ' is over than the total ad hoc of ' + totalAdhoc + '. ';
            }
            if(totalAnniversaryPayment > totalAnniversary) {
                amountExceed += 'Total anniversary payment of ' + totalAnniversaryPayment + ' is over than the total anniversary of ' + totalAnniversary + '. ';
            }
            
            
        }
        
        return amountExceed;
    }

}