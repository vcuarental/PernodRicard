/* Filename:   ASI_CRM_SG_PaymentRequest_TriggerCls.cls
* Author:     Laputa
* Purpose:    CRM SG Payment Request Trigger Class
*
*
* History
* -----------------------------------------------------------------------------
* 2017-11-15       Tony       Created
* 2018-10-11       Vincent Lam             [VL 1.0] CHM118869563
*/
public without sharing  class ASI_CRM_SG_PaymentRequest_TriggerCls {

	public static final String SG_WSBACKREBATE_REMARK = 'Wholesaler Back Rebate Payment';
    
    //Function : Allow delete generated back rebates payments, but have to delete from the latest achievement
    //Example :  If both 25% and 50% achievement back rebates payments have been generated and Sales Rep wants to remove the 25% one, then 50% one has to be removed first
    public static void routineBeforeDelete(list<ASI_TH_CRM_PaymentRequest__c> trigger_old){
        //Looping Old List
        Boolean IsBackRebatesPayment=false;
        
        Boolean FoundBackRebatesPayment=false;
        set<Id> SystemGenerated_PaymentIdSet = new set<Id>();// to be delete
        set<Id> OldPaymentIdSet = new set<Id>();
        set<Id> CurrentContractIdSet = new set<Id>();
        set<Id> SKUIdSet = new set<Id>();
        
        //String PaymentId='';
        ASI_TH_CRM_PaymentRequest__c OldPayment = new ASI_TH_CRM_PaymentRequest__c();
        for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : trigger_old) {
            if(PaymentRequest.ASI_CRM_System_Generated__c && PaymentRequest.ASI_CRM_System_Remark__c != SG_WSBACKREBATE_REMARK){
                FoundBackRebatesPayment=true; //PaymentId=PaymentRequest.Id;
                OldPayment=PaymentRequest;
                SystemGenerated_PaymentIdSet.add(PaymentRequest.Id);
            }
        }
        
        system.debug('Old Payment Id :  '+OldPayment.Id);
        
        if(OldPayment!=Null && FoundBackRebatesPayment){//&& OldPayment.Id!=''
            
             List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineList = [select Id,ASI_TH_CRM_Payment_Request__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                                                                                         WHERE ASI_TH_CRM_Payment_Request__c in :SystemGenerated_PaymentIdSet 
                                                                                         and ASI_CRM_SG_Type__c='Back Rebates' 
                                                                                         and RecordType.DeveloperName='ASI_CRM_SG_Payment_Request_Detail'];
            if(PaymentRequestLineList.size()>0){
                IsBackRebatesPayment=true;
            }
            
            
            if(PaymentRequestLineList.size()>0){
                for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine:PaymentRequestLineList){
                    OldPaymentIdSet.add(PaymentLine.ASI_TH_CRM_Payment_Request__c);
                    if(PaymentLine.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c!=null){
                        CurrentContractIdSet.add(PaymentLine.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c);
                    }
                }
            }
            
            
        }
        
        
        
        
        
        //Have found Back Rebates Payment ? 
        if(IsBackRebatesPayment){ //ASI_TH_CRM_Contract_No__c =:OldPayment.ASI_TH_CRM_Contract_No__c 
            system.debug('Now IsBackRebatesPayment '+IsBackRebatesPayment );
            List<ASI_TH_CRM_PaymentRequest__c> AllOtherPaymentList= [select Id,Name,ASI_TH_CRM_Status__c,CreatedDate,
                                                                     (select Id from ASI_TH_CRM_PRLI_PaymentRequest__r where ASI_CRM_SG_Type__c='Back Rebates'  )
                                                                     from ASI_TH_CRM_PaymentRequest__c 
                                                                     where ASI_TH_CRM_Contract__c =:OldPayment.ASI_TH_CRM_Contract__c and Id!=: OldPayment.Id 
                                                                     and (RecordType.DeveloperName='ASI_CRM_SG_Payment_Request_Read_Only' or RecordType.DeveloperName='ASI_CRM_SG_Payment_Request')
                                                                     order by Createddate ASC];//desc
            
            Boolean ShowApprovedError=false;
            Boolean ShowDraftError=false;
            String OtherPaymentName='';
            
            if(AllOtherPaymentList.size()>0){
                for(ASI_TH_CRM_PaymentRequest__c Payment:AllOtherPaymentList){
                    system.debug('Payment.ASI_TH_CRM_PRLI_PaymentRequest__r.size '+Payment.ASI_TH_CRM_PRLI_PaymentRequest__r.size() );
                    system.debug(Payment.Name+'Payment.CreatedDate'+Payment.CreatedDate);
                    system.debug('OldPayment.CreatedDate'+OldPayment.CreatedDate);
                    
                    
                    if(Payment.ASI_TH_CRM_PRLI_PaymentRequest__r.size()>0 && Payment.CreatedDate>OldPayment.CreatedDate && (!ShowApprovedError || !ShowDraftError) ){
                         system.debug('enter *&&*ShowApprovedError: ');
                        if(Payment.ASI_TH_CRM_Status__c=='Approved' || Payment.ASI_TH_CRM_Status__c=='Submitted'){
                            ShowApprovedError=true;
                            OtherPaymentName=Payment.Name;
                        }
                        if(Payment.ASI_TH_CRM_Status__c=='Draft' || Payment.ASI_TH_CRM_Status__c=='Rejected'){
                            ShowDraftError=true;
                            OtherPaymentName=Payment.Name;
                        }
                        
                    }
                }
                
                
                system.debug(ShowDraftError+'**************************ShowApprovedError: '+ShowApprovedError);
            }
            
            if((ShowDraftError || ShowApprovedError) && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_SG_AllowDeletePayment3') ){
                for(ASI_TH_CRM_PaymentRequest__c PaymentRequest : trigger_old) {
                    if(ShowDraftError){
                        PaymentRequest.addError('Please remove the Back Rebates payment '+OtherPaymentName+' before remove this one');
                    }
                    if(ShowApprovedError){
                        PaymentRequest.addError('You cannot remove this Back Rebates payment '+OtherPaymentName+' because the latest payment has been submitted / approved.’');
                    }
                }
            }
            
            
            
            if(!ShowApprovedError && !ShowDraftError){
             
                
                if(SystemGenerated_PaymentIdSet.size()>0){
                   
                    List<ASI_CRM_ContractTarget__c> ContractTargetList= [select id,ASI_CRM_SKU__c,ASI_CRM_Back_Rebates_Issued_Total__c from ASI_CRM_ContractTarget__c 
                                                                         where ASI_CRM_Contract__c in : CurrentContractIdSet and ASI_CRM_SKU__c!=null 
                                                                         and (RecordType.DeveloperName='ASI_CRM_SG_Contract_Target' or RecordType.DeveloperName='ASI_CRM_SG_Contract_Target')];   //Test : select id,Name,ASI_CRM_SKU__c,ASI_CRM_SKU__r.Name,ASI_CRM_Back_Rebates_Issued_Total__c from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c='a8cM00000004YUhIAM'
                    system.debug('ContractTargetList :  '+ContractTargetList);
                    for(ASI_CRM_ContractTarget__c ContractTarget:ContractTargetList){
                        ContractTarget.ASI_CRM_Back_Rebates_Issued_Total__c=0;
						/* [VL 1.0] BEGIN */
						ContractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c=0;
						/* [VL 1.0] END */
                        if(ContractTarget.ASI_CRM_SKU__c!=null){
                            SKUIdSet.add(ContractTarget.ASI_CRM_SKU__c);
                        }
                    }
                    Map<String,Decimal> PaymentIssuedMap=new Map<String,Decimal>();
					/* [VL 1.0] BEGIN */
					Map<String,Decimal> BottleIssuedMap=new Map<String,Decimal>();
					/* [VL 1.0] END */
                    List<ASI_TH_CRM_PaymentRequestLineItem__c> AllPaymentRequestLineList = [select Id,ASI_CRM_SKU__c,ASI_TH_CRM_Amount__c,ASI_TH_CRM_Payment_Request__c,ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c 
																							/* [VL 1.0] BEGIN */
																							, ASI_CRM_CN_Offtake_Vol__c
																							/* [VL 1.0] END */
																							FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                                                                                            WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c in :CurrentContractIdSet 
                                                                                            and ASI_TH_CRM_Payment_Request__c not in :SystemGenerated_PaymentIdSet 
                                                                                            and ASI_TH_CRM_Payment_Request__r.ASI_CRM_System_Generated__c=true
                                                                                            and ASI_CRM_SG_Type__c='Back Rebates' and ASI_CRM_SKU__c !=null  and ASI_TH_CRM_Amount__c !=null
                                                                                            and RecordType.DeveloperName='ASI_CRM_SG_Payment_Request_Detail'];
                    system.debug('AllPaymentRequestLineList :  '+AllPaymentRequestLineList);
                    for(ASI_TH_CRM_PaymentRequestLineItem__c PaymentLine: AllPaymentRequestLineList){
                        if(PaymentIssuedMap.containsKey(PaymentLine.ASI_CRM_SKU__c)){
                            Decimal PaymentAmount = PaymentIssuedMap.get(PaymentLine.ASI_CRM_SKU__c) +PaymentLine.ASI_TH_CRM_Amount__c;
                            PaymentIssuedMap.remove(PaymentLine.ASI_CRM_SKU__c);
                            PaymentIssuedMap.put(PaymentLine.ASI_CRM_SKU__c,PaymentAmount);
                        }else{
                            PaymentIssuedMap.put(PaymentLine.ASI_CRM_SKU__c,PaymentLine.ASI_TH_CRM_Amount__c);
                        }
						/* [VL 1.0] BEGIN */
						if(BottleIssuedMap.containsKey(PaymentLine.ASI_CRM_SKU__c)){
                            Decimal bottle = BottleIssuedMap.get(PaymentLine.ASI_CRM_SKU__c) +PaymentLine.ASI_CRM_CN_Offtake_Vol__c;
                            BottleIssuedMap.remove(PaymentLine.ASI_CRM_SKU__c);
                            BottleIssuedMap.put(PaymentLine.ASI_CRM_SKU__c,bottle);
                        }else{
                            BottleIssuedMap.put(PaymentLine.ASI_CRM_SKU__c,PaymentLine.ASI_CRM_CN_Offtake_Vol__c);
                        }
						/* [VL 1.0] END */
                    }
                    
                    for(ASI_CRM_ContractTarget__c ContractTarget:ContractTargetList){
                        if(PaymentIssuedMap.containsKey(ContractTarget.ASI_CRM_SKU__c)){
                            ContractTarget.ASI_CRM_Back_Rebates_Issued_Total__c= ContractTarget.ASI_CRM_Back_Rebates_Issued_Total__c+ PaymentIssuedMap.get(ContractTarget.ASI_CRM_SKU__c);
                        }
						/* [VL 1.0] BEGIN */
                        if(BottleIssuedMap.containsKey(ContractTarget.ASI_CRM_SKU__c)){
                            ContractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c= ContractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c+ BottleIssuedMap.get(ContractTarget.ASI_CRM_SKU__c);
                        }
						/* [VL 1.0] END */
                    }
                    
                    if(ContractTargetList.size()>0 ){
                        update ContractTargetList;
                    }
                }
                
            }
        }
    }
    
    
    
    
}