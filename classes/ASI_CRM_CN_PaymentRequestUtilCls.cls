/* Filename:    ASI_CRM_CN_PaymentRequestUtilCls.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Payment Request Util Class for CN CRM
 *              - Generation BRSF item
 *              - Payment Summary
 *              
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-06-29   michael.yip@introv.com      Created
 * 2014-06-30   michael.yip@introv.com      Add Payment Summary method for payment request page table
 * 2014-07-29   michael.yip@introv.com      Extend Payment Summary method for PO modification
 * 2014-12-08   twinkle.li@introv.com       Combine BRSF with 日店合同奖励(other) in PR Summary
 */
public without sharing class ASI_CRM_CN_PaymentRequestUtilCls {
    public class PaymentSummary{
        public string feeName {get;set;}
        public string feeChiName {get;set;}
        public Decimal POEstimateAmt {get;set;}
        public Decimal PORemainAmt {get;set;}
        public Decimal PaymentRequestAmount {get;set;}
        public Decimal PaidAmt {get;set;}
        public Decimal LastPOEstimateAmt {get;set;}
        public Decimal PODeltaAmt {get;set;}
        //20160725 Ben @ Elufa
        public Decimal cnyEst {get;set;}
        public Decimal mafEst {get;set;}
        public Decimal othersEst {get;set;}
        
        public Decimal cnyEstLast {get;set;}
        public Decimal mafEstLast {get;set;}
        public Decimal othersEstLast {get;set;}
        
        public Decimal cnyRequest {get;set;}
        public Decimal mafRequest {get;set;}
        public Decimal othersRequest {get;set;}
        
        public Decimal cnyPaid {get;set;}
        public Decimal mafPaid {get;set;}
        public Decimal othersPaid {get;set;}
        
        public Decimal cnyRemaining {get;set;}
        public Decimal mafRemaining {get;set;}
        public Decimal othersRemaining {get;set;}
        //20160725 End
        
        public paymentSummary(String fName, String fCName, Decimal EstAmt, Decimal RemainAmt, Decimal RequestAmt){
            feeName = fName;
            feeChiName = fCName;
            POEstimateAmt = EstAmt;
            PORemainAmt = RemainAmt;
            PaymentRequestAmount = RequestAmt;
            if(POEstimateAmt == null)
                POEstimateAmt  = 0;
            if(PORemainAmt == null)
                PORemainAmt = 0;
            if(PaymentRequestAmount == null)
                PaymentRequestAmount = 0;
            PaidAmt  = 0;
            LastPOEstimateAmt = 0;
            PODeltaAmt = 0;
            
            //20160725 Ben @ Elufa
            cnyEst = 0;
            mafEst = 0;
            othersEst = 0;
            
            cnyEstLast = 0;
            mafEstLast = 0;
            othersEstLast = 0;
            
            cnyRequest = 0;
            mafRequest = 0;
            othersRequest = 0;
            
            cnyPaid = 0;
            mafPaid = 0;
            othersPaid = 0;
            
            cnyRemaining = 0;
            mafRemaining = 0;
            othersRemaining = 0;
            //20160725 End
        }
        public void addEstAmt(Decimal input){
            if(input != null)
                POEstimateAmt += input;
        }
        public void addremainAmt(Decimal input){
            if(input != null)
                PORemainAmt += input;
        }
        public void addRequestAmt(Decimal input){
            if(input != null)
                PaymentRequestAmount += input;
        }
        public void addPaidAmt(Decimal input){
            if(input != null)
                PaidAmt += input;
        }
        public void addLastPOEstimateAmt(Decimal input){
            if(input != null)
                LastPOEstimateAmt += input;
        }
        //20160725 Ben @ Elufa
        //add Est
        Public void addCNYEst(Decimal input){
            if(input != null)
                cnyEst += input;
        }
        Public void addMAFEst(Decimal input){
            if(input != null)
                mafEst += input;
        }
        Public void addOthersEst(Decimal input){
            if(input != null)
                othersEst += input;
        }
        //add Last Est
        Public void addLastCNYEst(Decimal input){
            if(input != null)
                cnyEstLast += input;
        }
        Public void addLastMAFEst(Decimal input){
            if(input != null)
                mafEstLast += input;
        }
        Public void addLastOthersEst(Decimal input){
            if(input != null)
                othersEstLast += input;
        }
        //add Request
        Public void addCNYRequest(Decimal input){
            if(input != null)
                cnyRequest += input;
        }
        Public void addMAFRequest(Decimal input){
            if(input != null)
                mafRequest += input;
        }
        Public void addOthersRequest(Decimal input){
            if(input != null)
                othersRequest += input;
        }
        //add Remaining
        Public void addCNYRemaining(Decimal input){
            if(input != null)
                cnyRemaining += input;
        }
        Public void addMAFRemaining(Decimal input){
            if(input != null)
                mafRemaining += input;
        }
        Public void addOthersRemaining(Decimal input){
            if(input != null)
                othersRemaining += input;
        }
        //add Paid
        Public void addCNYPaid(Decimal input){
            if(input != null)
                cnyPaid += input;
        }
        Public void addMAFPaid(Decimal input){
            if(input != null)
                mafPaid += input;
        }
        Public void addOthersPaid(Decimal input){
            if(input != null)
                othersPaid += input;
        }
        //Calc Remaining
        public void calcRemaining(boolean isPOMod){
            
            if(isPOMod){
                cnyRemaining = cnyEstLast - cnyPaid;
                mafRemaining = mafEstLast - mafPaid;
                othersRemaining = othersEstLast - othersPaid;
            }
            else{
                cnyRemaining = cnyEst - cnyPaid;
                mafRemaining = mafEst - mafPaid;
                othersRemaining = othersEst - othersPaid;
            }
        }
        //20160725 End
        public void calc(boolean isPOMod){
            PODeltaAmt = POEstimateAmt - LastPOEstimateAmt ;
            if(isPOMod){
                PORemainAmt = LastPOEstimateAmt - PaidAmt;
            }
            else{
                PORemainAmt = POEstimateAmt - PaidAmt;
            }
        }
    }
    
    public static List<PaymentSummary> genPaymentSummary(ASI_TH_CRM_PaymentRequest__c p, ASI_TH_CRM_Contract__c contract){
        List<PaymentSummary> LResult = new List<PaymentSummary>();
        
        id contractID;
        id paymentID;
        id lastContractID;
        if(p != null){
            contractID = p.ASI_TH_CRM_Contract__c;
            paymentID = p.id;           
        }
        else if(contract != null){
            contractID = contract.id;
            lastContractID = contract.ASI_CRM_CN_Last_PO_version__c;
        }
        
        // Modified by Michael 01Aug2014 to get new & old BRSF in 1 soql
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSFAll = [Select id, name, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,
            ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Activity_Code__c  
            from ASI_CRM_CN_Contract_BRSF_Line_Item__c 
            where ASI_CRM_CN_Contract__c = :contractID or ASI_CRM_CN_Contract__c = :lastContractID];
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSFOld = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();    
		
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c b : LBRSFAll){
            if(b.ASI_CRM_CN_Contract__c == contractID)
                LBRSF.add(b);
            else if(b.ASI_CRM_CN_Contract__c == lastContractID)
                LBRSFOld.add(b);
        }
        
        // Modified by Michael 01Aug2014 to get new & old contract cost in 1 soql
        List<ASI_CRM_Contract_Cost__c> LContractCostAll = [Select id, name, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c,
            ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c, 
            ASI_CRM_CN_Activity_Code__r.name, ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,
            ASI_CRM_CN_Contract__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c//20160725 Ben @ Elufa
            from ASI_CRM_Contract_Cost__c
            where ASI_CRM_CN_Contract__c = :contractID or ASI_CRM_CN_Contract__c = :lastContractID
            order by ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Cost_Type__c];
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_Contract_Cost__c> LContractCostOld = new List<ASI_CRM_Contract_Cost__c>();
        for(ASI_CRM_Contract_Cost__c c : LContractCostAll){
            if(c.ASI_CRM_CN_Contract__c == contractID)
                LContractCost.add(c);
            else if(c.ASI_CRM_CN_Contract__c == lastContractID)
                LContractCostOld.add(c);
        }
        
        // Modified by Michael 01Aug2014 to get payment BRSF, PSF, Other in 1 soql
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentLineAll = [Select id, name, ASI_CRM_CN_Total_Payable__c, ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c,
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c,
            ASI_CRM_CN_Sub_Brand__c, ASI_TH_CRM_Payment_Request__c, ASI_CRM_CN_AC_Code__c, ASI_CRM_CN_Payment_Description__c,
            ASI_CRM_CN_Period_Start__c, ASI_CRM_CN_Period_End__c, ASI_CRM_CN_Supporting_Document__c, 
            ASI_TH_CRM_Amount__c,ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_CRM_CN_Remaining_Amount__c, 
            ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Contract_Cost__c, recordtypeid,
            ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c//20160725 Ben @ Elufa
            from ASI_TH_CRM_PaymentRequestLineItem__c 
            where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contractID  and 
            (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' or 
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Submitted' or
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Paid' or 
            ASI_TH_CRM_Payment_Request__c = :paymentID) and
            (Recordtypeid = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF') or
            RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF') or
            RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other')
            )]; 
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentBRSF = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPSF = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LOther = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequestLineItem__c line : LPaymentLineAll){
            if(line.recordtypeid == Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'))
                LPaymentBRSF.add(line);
            else if(line.recordtypeid == Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'))
                LPSF.add(line);
            else if(line.recordtypeid == Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'))
                LOther.add(line);
        }
            LResult = genPaymentSummaryByInput(p, contract, LBRSF, LBRSFOld, LContractCost, LContractCostOld, LPaymentBRSF, LPSF, LOther);
            System.debug(LResult);
        
        return LResult;
    }
    
    public static List<PaymentSummary> genPaymentSummaryByInput(ASI_TH_CRM_PaymentRequest__c p, ASI_TH_CRM_Contract__c contract, 
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF,
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSFOld,
        List<ASI_CRM_Contract_Cost__c> LContractCost,
        List<ASI_CRM_Contract_Cost__c> LContractCostOld,
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentBRSF,
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPSF, 
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LOther){
            
            //20160628 Ben @ Elufa
            Boolean isNewFY = FALSE;
            Boolean isOFFneCom = FALSE;
            String specialHandlingChi = '日店合同奖励';
            String specialHandlingEng = 'Trading term - Off Premise';
            String PSFName = '空瓶回收服务费';
			String PSFNameEng = 'Promotion Service Fee';
            
            if(p != NULL){
                isNewFY = p.ASI_CRM_New_FY_Payment__c;
                isOFFneCom = p.ASI_CRM_CN_Promotion_Type__c == 'Contract OFF' || p.ASI_CRM_CN_Promotion_Type__c == 'Contract E-Commerce' ? TRUE : FALSE;
            }
            if(contract != NULL){
                isNewFY = contract.ASI_CRM_New_FY_PO__c;
            }
            
            if(isNewFY){
                specialHandlingChi = '合同奖励';
                specialHandlingEng = 'PRC - PSF & Trading Term Incentives';
                PSFName = '合同奖励';
                PSFNameEng = 'Trading Term Incentives';
            }
            //20160628 End
            
            List<PaymentSummary> LResult = new List<PaymentSummary>();
            //BRSF
            PaymentSummary BRSFPaymentSummary = new PaymentSummary('BRSF','空瓶回收费',0,0,0);
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c CBRSF : LBRSF){
                BRSFPaymentSummary.addEstAmt(CBRSF.ASI_CRM_CN_Est_Total__c);
            }
            
            // Added by Michael Yip (Introv) 30Jul2014 for last version PO estimate amt
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c CBRSF : LBRSFOld){
                BRSFPaymentSummary.addLastPOEstimateAmt(CBRSF.ASI_CRM_CN_Est_Total__c);
            }
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c PBRSF : LPaymentBRSF){                               
                // PO remaining amount excluding current payment
                if(p != null && PBRSF.ASI_TH_CRM_Payment_Request__c == p.id){
                    if (PBRSF.ASI_CRM_CN_Total_Payable__c != null && PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c != null)
                        BRSFPaymentSummary.addRequestAmt(PBRSF.ASI_CRM_CN_Total_Payable__c*PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c/100);
                }else if(PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Approved' || 
                    PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Submitted' || 
                    PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Paid'){
                    if (PBRSF.ASI_CRM_CN_Total_Payable__c != null && PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c != null)
                        BRSFPaymentSummary.addPaidAmt(PBRSF.ASI_CRM_CN_Total_Payable__c*PBRSF.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Adjustment__c/100);
                }                
            }
            
            // Modified by Michael Yip (Introv) 30Jul2014 for calculating remaining amount of PO modification/payment request
            if(p==null)
                BRSFPaymentSummary.calc(true);
            else
                BRSFPaymentSummary.calc(false);
            
            /*if(LBRSF.size()>0 || LPaymentBRSF.size()>0)
                LResult.add(BRSFPaymentSummary);
            */
            
            //Promotion Service Fee & other fee
            PaymentSummary PSFPaymentSummary = new PaymentSummary('PSF',PSFName,0,0,0);//20160628 Ben @ Elufa '空瓶回收服务费'
            Boolean addPSF = false;
            Map<String,PaymentSummary> MOtherPayment = new Map<string,PaymentSummary>();
            
            for(ASI_CRM_Contract_Cost__c c : LContractCost){
                if(c.Name.contains(PSFNameEng) && !isOFFneCom){//if(c.Name.contains('Promotion Service Fee')){//20160628 Ben @ Elufa
                    addPSF = true;
                    PSFPaymentSummary.addEstAmt(c.ASI_CRM_CN_Estimate_Amount__c);
                    //20160725 Ben @ Elufa
                    PSFPaymentSummary.addCNYEst(c.ASI_CRM_CNY_Est__c);
                    PSFPaymentSummary.addMAFEst(c.ASI_CRM_MAF_Est__c);
                    PSFPaymentSummary.addOthersEst(c.ASI_CRM_Other_Est__c);
                    //20160725 End
                }
                else{
                    //MOtherPayment.put(c.ASI_CRM_CN_Chinese_Description__c,new PaymentSummary(c.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,c.ASI_CRM_CN_Chinese_Description__c,c.ASI_CRM_CN_Estimate_Amount__c,0,0)); 20160725 Ben @ Elufa
                    //20160725 Ben @ Elufa
					PaymentSummary tmpPS = new PaymentSummary(c.ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c,c.ASI_CRM_CN_Chinese_Description__c,c.ASI_CRM_CN_Estimate_Amount__c,0,0);
                    tmpPS.addCNYEst(c.ASI_CRM_CNY_Est__c);
                    tmpPS.addMAFEst(c.ASI_CRM_MAF_Est__c);
                    tmpPS.addOthersEst(c.ASI_CRM_Other_Est__c);
                    MOtherPayment.put(c.ASI_CRM_CN_Chinese_Description__c, tmpPS);
                    //20160725 End
                }
            }
            
            // Added by Michael Yip (Introv) 30Jul2014 
            for(ASI_CRM_Contract_Cost__c c : LContractCostOld){
                if(c.Name.contains(PSFNameEng) && !isOFFneCom){//if(c.Name.contains('Promotion Service Fee')){//20160628 Ben @ Elufa
                    PSFPaymentSummary.addLastPOEstimateAmt(c.ASI_CRM_CN_Estimate_Amount__c);
                    //20160725 Ben @ Elufa
                    PSFPaymentSummary.addLastCNYEst(c.ASI_CRM_CNY_Est__c);
                    PSFPaymentSummary.addLastMAFEst(c.ASI_CRM_MAF_Est__c);
                    PSFPaymentSummary.addLastOthersEst(c.ASI_CRM_Other_Est__c);
                    //20160725 End
                }
                else{
                    if(MOtherPayment.containsKey(c.ASI_CRM_CN_Chinese_Description__c)){
                        PaymentSummary tempSummary = MOtherPayment.get(c.ASI_CRM_CN_Chinese_Description__c);
                        tempSummary.addLastPOEstimateAmt(c.ASI_CRM_CN_Estimate_Amount__c);
                        //20160725 Ben @ Elufa
                        tempSummary.addLastCNYEst(c.ASI_CRM_CNY_Est__c);
                        tempSummary.addLastMAFEst(c.ASI_CRM_MAF_Est__c);
                        tempSummary.addLastOthersEst(c.ASI_CRM_Other_Est__c);
                        //20160725 End
                        MOtherPayment.put(c.ASI_CRM_CN_Chinese_Description__c,tempSummary);
                    }
                }
            }
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c PSF : LPSF){
                addPSF = true;
                
                // PO remaining amount excluding current payment
                if(p != null && PSF.ASI_TH_CRM_Payment_Request__c == p.id){
                    PSFPaymentSummary.addRequestAmt(PSF.ASI_TH_CRM_Amount__c);
                    //20160726 Ben @ Elufa
                    PSFPaymentSummary.addCNYRequest(PSF.ASI_CRM_CNY_Est__c);
                    PSFPaymentSummary.addMAFRequest(PSF.ASI_CRM_MAF_Est__c);
                    PSFPaymentSummary.addOthersRequest(PSF.ASI_CRM_Other_Est__c);
                    
                }else if(PSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Approved' || PSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Submitted' || PSF.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Paid'){
                    PSFPaymentSummary.addPaidAmt(PSF.ASI_TH_CRM_Amount__c);
                    //20160726 Ben @ Elufa
                    PSFPaymentSummary.addCNYPaid(PSF.ASI_CRM_CNY_Est__c);
                    PSFPaymentSummary.addMAFPaid(PSF.ASI_CRM_MAF_Est__c);
                    PSFPaymentSummary.addOthersPaid(PSF.ASI_CRM_Other_Est__c);
                }   
            }
                        
            if(p==null){
                PSFPaymentSummary.calc(true);
                PSFPaymentSummary.calcRemaining(TRUE);
            }else{
                PSFPaymentSummary.calc(false);
                PSFPaymentSummary.calcRemaining(FALSE);
            }
            
            //20160628 Ben @ Elufa
            if(isNewFY){
                
                if(MOtherPayment.containsKey(PSFName)){
                    MOtherPayment.get(PSFName).addEstAmt(PSFPaymentSummary.POEstimateAmt);
                    MOtherPayment.get(PSFName).addLastPOEstimateAmt(PSFPaymentSummary.LastPOEstimateAmt);
                    MOtherPayment.get(PSFName).addRequestAmt(PSFPaymentSummary.PaymentRequestAmount);
                    MOtherPayment.get(PSFName).addPaidAmt(PSFPaymentSummary.PaidAmt);
                    //20160726 Ben @ Elufa
                    MOtherPayment.get(PSFName).addCNYEst(PSFPaymentSummary.cnyEst);
                    MOtherPayment.get(PSFName).addLastCNYEst(PSFPaymentSummary.cnyEstLast);
                    MOtherPayment.get(PSFName).addCNYRequest(PSFPaymentSummary.cnyRequest);
                    MOtherPayment.get(PSFName).addCNYPaid(PSFPaymentSummary.cnyPaid);
                    
                    MOtherPayment.get(PSFName).addMAFEst(PSFPaymentSummary.mafEst);
                    MOtherPayment.get(PSFName).addLastMAFEst(PSFPaymentSummary.mafEstLast);
                    MOtherPayment.get(PSFName).addMAFRequest(PSFPaymentSummary.mafRequest);
                    MOtherPayment.get(PSFName).addMAFPaid(PSFPaymentSummary.mafPaid);
                    
                    MOtherPayment.get(PSFName).addOthersEst(PSFPaymentSummary.othersEst);
                    MOtherPayment.get(PSFName).addLastOthersEst(PSFPaymentSummary.othersEstLast);
                    MOtherPayment.get(PSFName).addOthersRequest(PSFPaymentSummary.othersRequest);
                    MOtherPayment.get(PSFName).addOthersPaid(PSFPaymentSummary.othersPaid);
                    
                }else if(addPSF || isOFFneCom){
                    MOtherPayment.put(PSFName, PSFPaymentSummary);
                }
                addPSF = FALSE;
            }
            //20160628 End
            
            if(addPSF){
                LResult.add(PSFPaymentSummary);
            }
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c other : LOther){               
                if(MOtherPayment.containsKey(other.ASI_CRM_CN_Expense_Type__c)){
                    PaymentSummary ps = MOtherPayment.get(other.ASI_CRM_CN_Expense_Type__c);
                    
                    if(p != null && other.ASI_TH_CRM_Payment_Request__c == p.id){
                        ps.addRequestAmt(other.ASI_TH_CRM_Amount__c);
                        //20160726 Ben @ Elufa
                        ps.addCNYRequest(other.ASI_CRM_CNY_Est__c);
                        ps.addMAFRequest(other.ASI_CRM_MAF_Est__c);
                        ps.addOthersRequest(other.ASI_CRM_Other_Est__c);
                    }
                    else if(other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Approved' ||
                            other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Submitted' ||
                            other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Paid'){
                                
                                ps.addPaidAmt(other.ASI_TH_CRM_Amount__c);
                                //20160726 Ben @ Elufa
                                ps.addCNYPaid(other.ASI_CRM_CNY_Est__c);
                                ps.addMAFPaid(other.ASI_CRM_MAF_Est__c);
                                ps.addOthersPaid(other.ASI_CRM_Other_Est__c);
                            }
                    MOtherPayment.put(other.ASI_CRM_CN_Expense_Type__c,ps);
                }
                else{
                    // Added by Michael Yip (Introv) 15Aug2014 for handling unmatched other payment
                    PaymentSummary ps= new PaymentSummary(other.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c,other.ASI_CRM_CN_Expense_Type__c,0,0,0);
                    if(p != null && other.ASI_TH_CRM_Payment_Request__c == p.id){
                        
                        ps.addRequestAmt(other.ASI_TH_CRM_Amount__c);
                        //20160726 Ben @ Elufa
                        ps.addCNYRequest(other.ASI_CRM_CNY_Est__c);
                        ps.addMAFRequest(other.ASI_CRM_MAF_Est__c);
                        ps.addOthersRequest(other.ASI_CRM_Other_Est__c);
                    }
                    else if(other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Approved' || 
                            other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Submitted' ||
                            other.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Paid'){
                                
                                ps.addPaidAmt(other.ASI_TH_CRM_Amount__c);
                                //20160726 Ben @ Elufa
                                ps.addCNYPaid(other.ASI_CRM_CNY_Est__c);
                                ps.addMAFPaid(other.ASI_CRM_MAF_Est__c);
                                ps.addOthersPaid(other.ASI_CRM_Other_Est__c);
                    }
                    MOtherPayment.put(other.ASI_CRM_CN_Expense_Type__c,ps);
                }       
            }
            
            //Added by Twinkle 20141208
            boolean boolExist = false;
            //20160624 Ben @ Elufa
            
            if((p != null && p.ASI_TH_CRM_Contract__c !=null && (p.ASI_CRM_CN_Promotion_Type__c == 'New Contract OFF' || p.ASI_CRM_CN_Promotion_Type__c == 'Contract OFF' || p.ASI_CRM_CN_Promotion_Type__c == 'Contract E-Commerce') ) || (contract != null && (contract.ASI_TH_CRM_Promotion_Type__c == 'New Contract OFF' || contract.ASI_TH_CRM_Promotion_Type__c == 'Contract OFF' || contract.ASI_TH_CRM_Promotion_Type__c == 'Contract E-Commerce') )){//20160622 Ben @ Elufa added  || contract.ASI_TH_CRM_Promotion_Type__c == 'Contract OFF'
                for(string key : MOtherPayment.keySet()){
                    if(key == specialHandlingChi){//if(key == '日店合同奖励'){ 20160624 Ben @ Elufa
                        MOtherPayment.get(key).addEstAmt(BRSFPaymentSummary.POEstimateAmt);
                        MOtherPayment.get(key).addLastPOEstimateAmt(BRSFPaymentSummary.LastPOEstimateAmt);
                        MOtherPayment.get(key).addRequestAmt(BRSFPaymentSummary.PaymentRequestAmount);
                        MOtherPayment.get(key).addPaidAmt(BRSFPaymentSummary.PaidAmt);
                        
                        //20160726 Ben @ Elufa
                        MOtherPayment.get(key).addCNYEst(BRSFPaymentSummary.cnyEst);
                        MOtherPayment.get(key).addLastCNYEst(BRSFPaymentSummary.cnyEstLast);
                        MOtherPayment.get(key).addCNYRequest(BRSFPaymentSummary.cnyRequest);
                        MOtherPayment.get(key).addCNYPaid(BRSFPaymentSummary.cnyPaid);
                        
                        MOtherPayment.get(key).addMAFEst(BRSFPaymentSummary.mafEst);
                        MOtherPayment.get(key).addLastMAFEst(BRSFPaymentSummary.mafEstLast);
                        MOtherPayment.get(key).addMAFRequest(BRSFPaymentSummary.mafRequest);
                        MOtherPayment.get(key).addMAFPaid(BRSFPaymentSummary.mafPaid);
                        
                        MOtherPayment.get(key).addOthersEst(BRSFPaymentSummary.othersEst);
                        MOtherPayment.get(key).addLastOthersEst(BRSFPaymentSummary.othersEstLast);
                        MOtherPayment.get(key).addOthersRequest(BRSFPaymentSummary.othersRequest);
                        MOtherPayment.get(key).addOthersPaid(BRSFPaymentSummary.othersPaid);
                        
                        boolExist = true;
                    }
                }
                if(boolExist == false){
                    PaymentSummary objOther = new PaymentSummary(specialHandlingEng,specialHandlingChi,0,0,0); //PaymentSummary objOther = new PaymentSummary('Trading term - Off Premise','日店合同奖励',0,0,0);  20160624 Ben @ Elufa
                    objOther.addEstAmt(BRSFPaymentSummary.POEstimateAmt);
                    objOther.addLastPOEstimateAmt(BRSFPaymentSummary.LastPOEstimateAmt);
                    objOther.addRequestAmt(BRSFPaymentSummary.PaymentRequestAmount);
                    objOther.addPaidAmt(BRSFPaymentSummary.PaidAmt);
                    
                    //20160726 Ben @ Elufa
                    objOther.addCNYEst(BRSFPaymentSummary.cnyEst);
                    objOther.addLastCNYEst(BRSFPaymentSummary.cnyEstLast);
                    objOther.addCNYRequest(BRSFPaymentSummary.cnyRequest);
                    objOther.addCNYPaid(BRSFPaymentSummary.cnyPaid);
                    
                    objOther.addMAFEst(BRSFPaymentSummary.mafEst);
                    objOther.addLastMAFEst(BRSFPaymentSummary.mafEstLast);
                    objOther.addMAFRequest(BRSFPaymentSummary.mafRequest);
                    objOther.addMAFPaid(BRSFPaymentSummary.mafPaid);
                    
                    objOther.addOthersEst(BRSFPaymentSummary.othersEst);
                    objOther.addLastOthersEst(BRSFPaymentSummary.othersEstLast);
                    objOther.addOthersRequest(BRSFPaymentSummary.othersRequest);
                    objOther.addOthersPaid(BRSFPaymentSummary.othersPaid);
                    
                    MOtherPayment.put(specialHandlingChi,objOther); //MOtherPayment.put('日店合同奖励',objOther); 20160624 Ben @ Elufa
                }
            }//20160722 Ben @ Elufa
            else if(isNewFY && ((p != null && p.ASI_TH_CRM_Contract__c !=null && (p.ASI_CRM_CN_Promotion_Type__c == 'NCO Off' || p.ASI_CRM_CN_Promotion_Type__c == 'NCO On')) || (contract != null && (contract.ASI_TH_CRM_Promotion_Type__c == 'NCO Off' || contract.ASI_TH_CRM_Promotion_Type__c == 'NCO On')))){
				
                Boolean boolExist2 = FALSE;
                
                for(string key : MOtherPayment.keySet()){
                    if(key == '其他变动费用'){//if(key == '日店合同奖励'){ 20160624 Ben @ Elufa
                        MOtherPayment.get(key).addEstAmt(BRSFPaymentSummary.POEstimateAmt);
                        MOtherPayment.get(key).addLastPOEstimateAmt(BRSFPaymentSummary.LastPOEstimateAmt);
                        MOtherPayment.get(key).addRequestAmt(BRSFPaymentSummary.PaymentRequestAmount);
                        MOtherPayment.get(key).addPaidAmt(BRSFPaymentSummary.PaidAmt);
                        
                        //20160726 Ben @ Elufa
                        MOtherPayment.get(key).addCNYEst(BRSFPaymentSummary.cnyEst);
                        MOtherPayment.get(key).addLastCNYEst(BRSFPaymentSummary.cnyEstLast);
                        MOtherPayment.get(key).addCNYRequest(BRSFPaymentSummary.cnyRequest);
                        MOtherPayment.get(key).addCNYPaid(BRSFPaymentSummary.cnyPaid);
                        
                        MOtherPayment.get(key).addMAFEst(BRSFPaymentSummary.mafEst);
                        MOtherPayment.get(key).addLastMAFEst(BRSFPaymentSummary.mafEstLast);
                        MOtherPayment.get(key).addMAFRequest(BRSFPaymentSummary.mafRequest);
                        MOtherPayment.get(key).addMAFPaid(BRSFPaymentSummary.mafPaid);
                        
                        MOtherPayment.get(key).addOthersEst(BRSFPaymentSummary.othersEst);
                        MOtherPayment.get(key).addLastOthersEst(BRSFPaymentSummary.othersEstLast);
                        MOtherPayment.get(key).addOthersRequest(BRSFPaymentSummary.othersRequest);
                        MOtherPayment.get(key).addOthersPaid(BRSFPaymentSummary.othersPaid);
                        
                        boolExist2 = true;
                    }
                }
                if(!boolExist2){
                    PaymentSummary objOther = new PaymentSummary('PRC - Other Variable Cost','其他变动费用',0,0,0); //PaymentSummary objOther = new PaymentSummary('Trading term - Off Premise','日店合同奖励',0,0,0);  20160624 Ben @ Elufa
                    objOther.addEstAmt(BRSFPaymentSummary.POEstimateAmt);
                    objOther.addLastPOEstimateAmt(BRSFPaymentSummary.LastPOEstimateAmt);
                    objOther.addRequestAmt(BRSFPaymentSummary.PaymentRequestAmount);
                    objOther.addPaidAmt(BRSFPaymentSummary.PaidAmt);
                    
                    //20160726 Ben @ Elufa
                    objOther.addCNYEst(BRSFPaymentSummary.cnyEst);
                    objOther.addLastCNYEst(BRSFPaymentSummary.cnyEstLast);
                    objOther.addCNYRequest(BRSFPaymentSummary.cnyRequest);
                    objOther.addCNYPaid(BRSFPaymentSummary.cnyPaid);
                    
                    objOther.addMAFEst(BRSFPaymentSummary.mafEst);
                    objOther.addLastMAFEst(BRSFPaymentSummary.mafEstLast);
                    objOther.addMAFRequest(BRSFPaymentSummary.mafRequest);
                    objOther.addMAFPaid(BRSFPaymentSummary.mafPaid);
                    
                    objOther.addOthersEst(BRSFPaymentSummary.othersEst);
                    objOther.addLastOthersEst(BRSFPaymentSummary.othersEstLast);
                    objOther.addOthersRequest(BRSFPaymentSummary.othersRequest);
                    objOther.addOthersPaid(BRSFPaymentSummary.othersPaid);
                    
                    MOtherPayment.put('其他变动费用',objOther); //MOtherPayment.put('日店合同奖励',objOther); 20160624 Ben @ Elufa
                }
            }
            //20160722 Ben @ Elufa
            else{
                if(LBRSF.size()>0 || LPaymentBRSF.size()>0)
                    LResult.add(BRSFPaymentSummary);
            }
            
            if(MOtherPayment.containsKey(specialHandlingChi)){ //if(MOtherPayment.containsKey('日店合同奖励')){ 20160624 Ben @ Elufa
                PaymentSummary ps = MOtherPayment.get(specialHandlingChi);  //PaymentSummary ps = MOtherPayment.get('日店合同奖励');  20160624 Ben @ Elufa
                if(p==null){
                    ps.calc(true);
                    //20160726 Ben @ Elufa
                    ps.calcRemaining(TRUE);
                }
                else{
                    ps.calc(false);
                    //20160726 Ben @ Elufa
                    ps.calcRemaining(FALSE);
                }
                LResult.add(ps);
            }
            //End By Twinkle 20141208
            
            //20160722 Ben @ Elufa
            
            if(MOtherPayment.containsKey('其他变动费用')){ //if(MOtherPayment.containsKey('日店合同奖励')){ 20160624 Ben @ Elufa
                PaymentSummary ps = MOtherPayment.get('其他变动费用');  //PaymentSummary ps = MOtherPayment.get('日店合同奖励');  20160624 Ben @ Elufa
                if(p==null){
                    ps.calc(true);
                    //20160726 Ben @ Elufa
                    ps.calcRemaining(TRUE);
                }
                else{
                    ps.calc(false);
                    //20160726 Ben @ Elufa
                    ps.calcRemaining(FALSE);
                }
                LResult.add(ps);
            }
            
            //20160722 End
            
            // Sorting by sequence of contract number
            Set<String> SKeyMapped = new Set<String>();
            for(ASI_CRM_Contract_Cost__c c : LContractCost ){
                string acode = c.ASI_CRM_CN_Chinese_Description__c;
                if(MOtherPayment.containsKey(acode) && acode != specialHandlingChi && ( ( acode != '其他变动费用' && isNewFY ) || !isNewFY )){ //if(MOtherPayment.containsKey(acode) && acode != '日店合同奖励'){ 20160624 Ben @ Elufa
                    PaymentSummary ps = MOtherPayment.get(acode);        
                    system.debug(acode);
                    if(p==null){
                        ps.calc(true);
                        //20160726 Ben @ Elufa
                        ps.calcRemaining(TRUE);
                    }
                    else{
                        ps.calc(false);
                        //20160726 Ben @ Elufa
                        ps.calcRemaining(FALSE);
                    }
                    LResult.add(ps);
                }
                SKeyMapped.add(acode);
            }
            for(string acode : MOtherPayment.keySet()){
                if(!SKeyMapped.contains(acode) && acode != specialHandlingChi && ( ( acode != '其他变动费用' && isNewFY ) || !isNewFY )){ //if(!SKeyMapped.contains(acode) && acode != '日店合同奖励'){ 20160624 Ben @ Elufa
                    LResult.add(MOtherPayment.get(acode));
                }
            }
            return LResult;
    }
    
    
    
    public static void genBRSF(ASI_TH_CRM_PaymentRequest__c p, Date StartDate, Date EndDate){
        
        //Added by Twinkle 11/12/2014 
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lstContractSubBrand = [SELECT id, ASI_CRM_CN_Sub_Brand__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c=: p.ASI_TH_CRM_Contract__c];
        system.debug(lstContractSubBrand);
        Map<id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> mapContractSubBrand = new Map<id, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c csb : lstContractSubBrand){
            mapContractSubBrand.put(csb.ASI_CRM_CN_Sub_Brand__c, csb);
            system.debug(csb.ASI_CRM_CN_Sub_Brand__c);
        }                       
        List<ASI_TH_CRM_PaymentRequestLineItem__c> lstPaymentSubBrand = [SELECT id, ASI_CRM_CN_Sub_Brand__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c =: p.ASI_TH_CRM_Contract__c and ASI_TH_CRM_Payment_Request__c !=: p.id];
        system.debug(lstPaymentSubBrand);
        Map<id, ASI_TH_CRM_PaymentRequestLineItem__c> mapPaymentSubBrand = new Map<id, ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequestLineItem__c psb : lstPaymentSubBrand){
            mapPaymentSubBrand.put(psb.ASI_CRM_CN_Sub_Brand__c, psb);
            system.debug(psb.ASI_CRM_CN_Sub_Brand__c);
        }            
        //End by Twinkle 11/12/2014
            
        // Added by Michael Yip 01Aug2014 for setting BRSF ac code
        List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList = 
            [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,
            ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, 
            ASI_CRM_CN_Other_Cost_Payment_Request__c 
            FROM ASI_CRM_Contract_Cost_Setting__c
            where ASI_CRM_CN_Promotion_Type__c = :p.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
            and ASI_CRM_CN_BRSF_Activity_Code_Default__c = true];
        id BRSFActivityCode; 
        System.debug(BRSFActivityCode);   
        if(LContractCostSettingList != null && LContractCostSettingList.size()==1){
            BRSFActivityCode = LContractCostSettingList[0].ASI_CRM_CN_Activity_Code__c;
        }
        
        // Delete existing BRSF item
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LBRSFDelete = [Select id from ASI_TH_CRM_PaymentRequestLineItem__c 
            where ASI_TH_CRM_Payment_Request__c = :p.id
            and recordtypeid =:Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF')];
        if(LBRSFDelete != null && LBRSFDelete.size()>0)
            Delete LBRSFDelete;

        if((StartDate!= null) && (EndDate != null)) {
        
        // Check if there is first payment, over-ride incentive/btl with first payment's BRSF value
        Boolean FirstPaymentExist = FirstPaymentExist(p);
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LFirstPaymentBRSF = [Select id, name, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Incentive_BT__c  
            from ASI_TH_CRM_PaymentRequestLineItem__c 
            where recordtypeid =:Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF')
            and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :p.ASI_TH_CRM_Contract__c 
            and ASI_TH_CRM_Payment_Request__c != :p.id];
            //and ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_First_Payment__c = true];
            
        Boolean isNewContractONOFF = p.ASI_CRM_CN_Promotion_Type__c == 'Contract ON' || p.ASI_CRM_CN_Promotion_Type__c == 'Contract OFF' || p.ASI_CRM_CN_Promotion_Type__c == 'New Contract ON' || p.ASI_CRM_CN_Promotion_Type__c == 'New Contract OFF' ? true : false;//20160628 Ben @ Elufa
        
        // Assume BRSF start/end date are filled
        Date PRSFStartDate = p.ASI_CRM_CN_BRSF_Start_Date__c;
        Date PRSFEndDate = p.ASI_CRM_CN_BRSF_End_Date__c;
		Date CutOffDay = CutOffDate(16);
            
        if(PRSFStartDate != null){
            PRSFStartDate = PRSFStartDate.toStartOfMonth(); 
        }
        if(PRSFEndDate != null){
            PRSFEndDate = PRSFEndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        
        // Get covered outlet
        // Added by Alan Wong (Elufa) 20150630
        Set<id> SOutletID = new Set<id>();
        if (p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null) {
        	SOutletID = returnCoveredOuteletID(p);
        }
        if (p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null) {
        	SOutletID.add(p.ASI_CRM_CN_OutletWS__c);
        }
        // Set<id> SOutletID = returnCoveredOuteletID(p);
        // SOutletID.add(p.ASI_CRM_CN_OutletWS__c);
        // -- End --//
            // Get Sub-Vol according brsf Start/End Date excluding competitor volume
            List<ASI_CRM_Subbrand_Volume__c> LVol = [Select ASI_CRM_T1_Depletion_BTL__c, ASI_CRM_Actual_Vol__c, ASI_CRM_Bottle_Collected__c, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                                     ASI_CRM_Subbrand__c, ASI_CRM_Offtake_Btl__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_Brand_Grade_Incentive__c, ASI_CRM_CN_Payment_Request_Line_Item__c,
                                                     ASI_CRM_Offtake_Std_Billing__c 
                                                     from ASI_CRM_Subbrand_Volume__c 
                                                     where ASI_CRM_Account__c IN :SOutletID //ASI_CRM_Account__c = :p.ASI_CRM_CN_OutletWS__c 
                                                     and ASI_CRM_End_Date__c <= :PRSFEndDate and ASI_CRM_End_Date__c >= :PRSFStartDate
                                                     and ASI_CRM_CN_Competitor_Sub_brand__c = false
                                                     AND ASI_CRM_End_Date__c <= :CutOffDay //2014-08-01 Stella Sing Add Cut Off Day
                                                     AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE //20161003 Ben @ Elufa
                                                     order by ASI_CRM_Account__c, ASI_CRM_Subbrand__c, ASI_CRM_End_Date__c];
        
        //Updated by William Yang(Introv)20141212 to generate suggest amount by total BC% instead of BC% per sub-brand
        Decimal TotalActualVol = 0;
        Decimal TotalBottleCollected = 0;
        
        for(ASI_CRM_Subbrand_Volume__c vol:LVol)
        {
            if(vol.ASI_CRM_Actual_Vol__c != null)
                TotalActualVol += vol.ASI_CRM_Actual_Vol__c;
            if(vol.ASI_CRM_Bottle_Collected__c != null)
                TotalBottleCollected += vol.ASI_CRM_Bottle_Collected__c; 
        }   
        
        System.debug('TotalActualVol = ' + TotalActualVol);
        System.debug('TotalBottleCollected = ' + TotalBottleCollected);
        
        if(isNewContractOnOFF && p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c != 'Covered Outlet Only'){
            List<ASI_CRM_Subbrand_Volume__c> LVolTemp = new List<ASI_CRM_Subbrand_Volume__c>();
            for(ASI_CRM_Subbrand_Volume__c v : LVol){
                if(v.ASI_CRM_CN_Payment_Request_Line_Item__c == null)
                    LVolTemp.add(v);
            }
            LVol = LVolTemp;
        }
        System.debug(LVol);
        
        
        // Prepare mapping for generating by contract BRSF/actual vol
        Map<id,String> SubGradeName_Map= new Map<id,String>();  
        Set<id> SSubBrandWithVolID = new Set<id>();
        Map<id, Decimal> MSubBrandWithIncentive = new Map<id,Decimal>();
        for(ASI_CRM_Subbrand_Volume__c v : LVol){
            SSubBrandWithVolID.add(v.ASI_CRM_Subbrand__c);
            MSubBrandWithIncentive.put(v.ASI_CRM_Subbrand__c, v.ASI_CRM_Sub_Brand_Grade_Incentive__c);
            SubGradeName_Map.put(v.ASI_CRM_Subbrand__c,v.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name);
        }
        
        // Looping contract BRSF to create payment line item
        List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentLineInsert = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        Set<id> SAddedSubBrandId = new Set<id>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = [Select id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                            ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                            ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                            ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,
                            ASI_CRM_CN_Activity_Code__c
                            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c  
                            WHERE ASI_CRM_CN_Contract__c = :p.ASI_TH_CRM_Contract__c order by ASI_CRM_CN_Contract__c];
        
        id v0ContractID;
        if(p.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null)
            v0ContractID = p.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        else
            v0ContractID = p.ASI_TH_CRM_Contract__c;
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> lstBRSF_V0 = [Select ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, 
							ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                            ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                            ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,
                            ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Incentive__c 
                            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c  
                            WHERE ASI_CRM_CN_Contract__c = :v0ContractID];
        
        Map<String,Decimal> mapBRSF_V0 = new Map<String,Decimal>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfv0 : lstBRSF_V0){
            mapBRSF_V0.put(brsfv0.ASI_CRM_CN_Sub_Brand__r.Name, brsfv0.ASI_CRM_CN_Contract_Monthly_Qty__c);
        }       
        
        // Use estimate qty and incentive/btl
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSF : LBRSF){
            if(p.ASI_TH_CRM_Contract__c == BRSF.ASI_CRM_CN_Contract__c){
                List<Decimal> LVolResult = calcActVolPerItem(BRSF.ASI_CRM_CN_Sub_Brand__c,LVol,p,SOutletID);
                System.debug(LVolResult);
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c = BRSF.id,
                    recordtypeid = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),
                    ASI_CRM_CN_Standard__c = BRSF.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,//
                    ASI_CRM_CN_Sub_Brand__c = BRSF.ASI_CRM_CN_Sub_Brand__c,//
                    ASI_CRM_CN_Incentive_BT__c = BRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c == null ? 0 : BRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c,//
                    //ASI_CRM_CN_Target_BT__c = BRSF.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 :BRSF.ASI_CRM_CN_Est_Monthly_Qty__c * p.ASI_CRM_CN_No_of_Month__c,//    
                    ASI_CRM_CN_Actual_Vol__c = LVolResult[0],
                    ASI_CRM_CN_Completion_Rate__c = 0,//
                    ASI_CRM_CN_Total_Payable__c = BRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c==null?0:BRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c*LVolResult[1],//                    
                    ASI_CRM_CN_Payable_Vol__c = LVolResult[1],
                    ASI_CRM_CN_Bottle_Collected__c = LVolResult[1],
                    ASI_CRM_CN_Collection_Rate__c = 0,//
                    ASI_CRM_CN_Offtake_Vol__c = LVolResult[2],
                    ASI_TH_CRM_Payment_Request__c = p.id,
                    ASI_CRM_CN_Suggested_Amount__c = 0,
                    ASI_CRM_Suggested_Volume__c = 0,
                    // Added by Michael Yip 01Aug2014
                    ASI_CRM_CN_AC_Code__c = BRSF.ASI_CRM_CN_Activity_Code__c==null?BRSFActivityCode:BRSF.ASI_CRM_CN_Activity_Code__c,
                    ASI_CRM_CN_Allow_Changing_Incentive__c = true,
                    //Updated by Twinkle 20141230 - Use v0 Contract Monthly Vol. to calculate BRSF Target
                    ASI_CRM_CN_Target_BT__c = mapBRSF_V0.get(BRSF.ASI_CRM_CN_Sub_Brand__r.Name) == null ? 0 :mapBRSF_V0.get(BRSF.ASI_CRM_CN_Sub_Brand__r.Name) * p.ASI_CRM_CN_No_of_Month__c
                );
                
                //Added by Twinkle 11/12/2014 
                if(mapContractSubBrand.containsKey(BRSF.ASI_CRM_CN_Sub_Brand__c)){
                    PaymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                }
                //End by Twinkle 11/12/2014
                
                if(PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Completion_Rate__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c/PaymentRequestLine.ASI_CRM_CN_Target_BT__c*100;
                }                   
                if(PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c != null && PaymentRequestLine.ASI_CRM_CN_Offtake_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c/PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c*100;
                }
                
                //Default Collection for suggested amount
                System.debug(paymentRequestline);
                system.debug(PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c);
                system.debug(PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c);
                PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
				PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c;
                
                //Updated by William Yang(Introv)20141212 to generate suggest amount by total BC% instead of BC% per sub-brand
                //if(PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c)
                if(TotalActualVol != 0 && TotalBottleCollected/TotalActualVol * 100 >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c){
                    PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
					PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c;
                }
                
                SAddedSubBrandId.add(BRSF.ASI_CRM_CN_Sub_Brand__c);
                LPaymentLineInsert.add(PaymentRequestLine);
            }
        }
        
		for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSF : lstBRSF_V0){
            if(!SAddedSubBrandId.contains(BRSF.ASI_CRM_CN_Sub_Brand__c)){
                List<Decimal> LVolResult = calcActVolPerItem(BRSF.ASI_CRM_CN_Sub_Brand__c,LVol,p,SOutletID);
                System.debug(LVolResult);
				Decimal incentive = BRSF.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Incentive__c == null ? 0 : BRSF.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Incentive__c;
                //20151126 Ben @ Elufa System
                //20160601 Ben @ Elufa change LVolResult[0] > 0 to LVolResult[0] != 0
                if( ( LVolResult[0] != 0 && LVolResult[0] != NULL ) || ( LVolResult[1] != 0 && LVolResult[1] != NULL ) || ( LVolResult[2] != 0 && LVolResult[2] != NULL ) ){
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                    recordtypeid = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),
                    ASI_CRM_CN_Standard__c = BRSF.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,//
                    ASI_CRM_CN_Sub_Brand__c = BRSF.ASI_CRM_CN_Sub_Brand__c,//
                    ASI_CRM_CN_Incentive_BT__c = incentive,//
                    //ASI_CRM_CN_Target_BT__c = BRSF.ASI_CRM_CN_Est_Monthly_Qty__c == null ? 0 :BRSF.ASI_CRM_CN_Est_Monthly_Qty__c * p.ASI_CRM_CN_No_of_Month__c,//    
                    ASI_CRM_CN_Actual_Vol__c = LVolResult[0],
                    ASI_CRM_CN_Completion_Rate__c = 0,//
                    ASI_CRM_CN_Total_Payable__c = incentive*LVolResult[1],//                    
                    ASI_CRM_CN_Payable_Vol__c = LVolResult[1],
                    ASI_CRM_CN_Bottle_Collected__c = LVolResult[1],
                    ASI_CRM_CN_Collection_Rate__c = 0,//
                    ASI_CRM_CN_Offtake_Vol__c = LVolResult[2],
                    ASI_TH_CRM_Payment_Request__c = p.id,
                    ASI_CRM_CN_Suggested_Amount__c = 0,
                    ASI_CRM_Suggested_Volume__c = 0,
                    // Added by Michael Yip 01Aug2014
                    ASI_CRM_CN_AC_Code__c = BRSF.ASI_CRM_CN_Activity_Code__c==null?BRSFActivityCode:BRSF.ASI_CRM_CN_Activity_Code__c,
                    ASI_CRM_CN_Allow_Changing_Incentive__c = true,
                    //Updated by Twinkle 20141230 - Use v0 Contract Monthly Vol. to calculate BRSF Target
                    ASI_CRM_CN_Target_BT__c = mapBRSF_V0.get(BRSF.ASI_CRM_CN_Sub_Brand__r.Name) == null ? 0 :mapBRSF_V0.get(BRSF.ASI_CRM_CN_Sub_Brand__r.Name) * p.ASI_CRM_CN_No_of_Month__c
                );
				                
                //Added by Twinkle 11/12/2014 
                if(mapContractSubBrand.containsKey(BRSF.ASI_CRM_CN_Sub_Brand__c) || mapPaymentSubBrand.containsKey(BRSF.ASI_CRM_CN_Sub_Brand__c)){
                    PaymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                }
                //End by Twinkle 11/12/2014
                
                if(PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Completion_Rate__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c/PaymentRequestLine.ASI_CRM_CN_Target_BT__c*100;
                }                   
                if(PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c != null && PaymentRequestLine.ASI_CRM_CN_Offtake_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c/PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c*100;
                }
                
                //Default Collection for suggested amount
                System.debug(paymentRequestline);
                system.debug(PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c);
                system.debug(PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c);
                PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
                PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c;
                //Updated by William Yang(Introv)20141212 to generate suggest amount by total BC% instead of BC% per sub-brand
                //if(PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c)
                if(TotalActualVol != 0 && TotalBottleCollected/TotalActualVol * 100 >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c){
                    PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
                    PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c;
                }
                
                SAddedSubBrandId.add(BRSF.ASI_CRM_CN_Sub_Brand__c);
                LPaymentLineInsert.add(PaymentRequestLine);
                }
            }
        }
		
        // Add Payment Request BRSF by actual vol
        for(id sbid : SSubBrandWithVolID){
            if(!SAddedSubBrandId.contains(sbid)){
                List<Decimal> LVolResult = calcActVolPerItem(sbid,LVol,p,SOutletID);
                System.debug(LVolResult);
                String Standard_Name='';
                if(SubGradeName_Map.containsKey(sbid))
                {
                    Standard_Name=SubGradeName_Map.get(sbid);
                }
                //20151126 Ben @ Elufa System
                //20160601 Ben @ Elufa change LVolResult[0] > 0 to LVolResult[0] != 0
                if( ( LVolResult[0] != 0 && LVolResult[0] != NULL ) || ( LVolResult[1] != 0 && LVolResult[1] != NULL ) || ( LVolResult[2] != 0 && LVolResult[2] != NULL ) ){
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                    recordtypeid = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),                                           
                    ASI_CRM_CN_Standard__c = Standard_Name,
                    ASI_CRM_CN_Sub_Brand__c = sbid,
                    ASI_CRM_CN_Incentive_BT__c = MSubBrandWithIncentive.get(sbid),
                    ASI_CRM_CN_Target_BT__c = 0,                    
                    ASI_CRM_CN_Actual_Vol__c = LVolResult[0],
                    ASI_CRM_CN_Completion_Rate__c = 0,
                    ASI_CRM_CN_Total_Payable__c = MSubBrandWithIncentive.get(sbid)*LVolResult[1],                   
                    ASI_CRM_CN_Payable_Vol__c = LVolResult[1],
                    ASI_CRM_CN_Bottle_Collected__c = LVolResult[1],
                    ASI_CRM_CN_Collection_Rate__c = 0,
                    ASI_CRM_CN_Offtake_Vol__c = LVolResult[2],
                    ASI_TH_CRM_Payment_Request__c = p.id,
                    ASI_CRM_CN_Suggested_Amount__c = 0,
                    ASI_CRM_Suggested_Volume__c = 0,
                    // Added by Michael Yip (Introv) 01Aug2014
                    ASI_CRM_CN_AC_Code__c = BRSFActivityCode,
                    //ASI_CRM_CN_Allow_Changing_Incentive__c = FirstPaymentExist?false:true
                    ASI_CRM_CN_Allow_Changing_Incentive__c = true
                );
                
                //Added by Twinkle 11/12/2014 
                if(mapContractSubBrand.containsKey(sbid) || mapPaymentSubBrand.containsKey(sbid)){
                    PaymentRequestLine.ASI_CRM_CN_Allow_Changing_Incentive__c = false;
                }
                //End by Twinkle 11/12/2014
                
                if(PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != null && PaymentRequestLine.ASI_CRM_CN_Target_BT__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Completion_Rate__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c/PaymentRequestLine.ASI_CRM_CN_Target_BT__c*100;
                }                   
                if(PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c != null && PaymentRequestLine.ASI_CRM_CN_Offtake_Vol__c != null && PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c != 0){
                    PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c/PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c*100;
                }
                
                //Default Collection for suggested amount
                PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
                PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Bottle_Collected__c;
                //Updated by William Yang(Introv)20141212 to generate suggest amount by total BC% instead of BC% per sub-brand
                //if(PaymentRequestLine.ASI_CRM_CN_Collection_Rate__c >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c)
                if(TotalActualVol != 0 && TotalBottleCollected/TotalActualVol * 100 >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c){
                    PaymentRequestLine.ASI_CRM_CN_Suggested_Amount__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c * PaymentRequestLine.ASI_CRM_CN_Incentive_BT__c;
                    PaymentRequestLine.ASI_CRM_Suggested_Volume__c = PaymentRequestLine.ASI_CRM_CN_Actual_Vol__c;
                }
                SAddedSubBrandId.add(sbid);
                LPaymentLineInsert.add(PaymentRequestLine);
                }
            }
        }
        
        // Override incentive/BTL by first payment
        for(ASI_TH_CRM_PaymentRequestLineItem__c pl : LPaymentLineInsert){
            // Only item not generated by contract
            if(pl.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null){
                for(ASI_TH_CRM_PaymentRequestLineItem__c pf : LFirstPaymentBRSF){
                    if(pl.ASI_CRM_CN_Sub_Brand__c == pf.ASI_CRM_CN_Sub_Brand__c){
                        pl.ASI_CRM_CN_Incentive_BT__c = pf.ASI_CRM_CN_Incentive_BT__c == null ? 0 : pf.ASI_CRM_CN_Incentive_BT__c;
                        pl.ASI_CRM_CN_Payable_Vol__c = pl.ASI_CRM_CN_Payable_Vol__c == null ? 0 : pl.ASI_CRM_CN_Payable_Vol__c;
                        pl.ASI_CRM_CN_Total_Payable__c = pl.ASI_CRM_CN_Incentive_BT__c * pl.ASI_CRM_CN_Payable_Vol__c;

                        if(pl.ASI_CRM_CN_Actual_Vol__c != null && pl.ASI_CRM_CN_Target_BT__c != null && pl.ASI_CRM_CN_Target_BT__c != 0){
                            pl.ASI_CRM_CN_Completion_Rate__c = pl.ASI_CRM_CN_Actual_Vol__c/pl.ASI_CRM_CN_Target_BT__c*100;
                        }                   
                        if(pl.ASI_CRM_CN_Bottle_Collected__c != null && pl.ASI_CRM_CN_Offtake_Vol__c != null && pl.ASI_CRM_CN_Actual_Vol__c != 0){
                            pl.ASI_CRM_CN_Collection_Rate__c = pl.ASI_CRM_CN_Bottle_Collected__c/pl.ASI_CRM_CN_Actual_Vol__c*100;
                        }
                        
                        //Default Collection for suggested amount
                        pl.ASI_CRM_CN_Suggested_Amount__c = pl.ASI_CRM_CN_Bottle_Collected__c * pl.ASI_CRM_CN_Incentive_BT__c;
                        pl.ASI_CRM_Suggested_Volume__c = pl.ASI_CRM_CN_Bottle_Collected__c;
                        
                        //Updated by William Yang(Introv)20141212 to generate suggest amount by total BC% instead of BC% per sub-brand
                        //if(pl.ASI_CRM_CN_Collection_Rate__c >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c)
                        if(TotalActualVol != 0 && TotalBottleCollected/TotalActualVol * 100 >=  p.ASI_CRM_CN_Bottle_Collection_Rate__c){
                            pl.ASI_CRM_CN_Suggested_Amount__c = pl.ASI_CRM_CN_Actual_Vol__c * pl.ASI_CRM_CN_Incentive_BT__c;
                            pl.ASI_CRM_Suggested_Volume__c = pl.ASI_CRM_CN_Actual_Vol__c;
                        }
                        break;
                    }
                }
            }
        }
        
        if(LPaymentLineInsert != null && LPaymentLineInsert.size()>0){
            insert LPaymentLineInsert;
        }
        
        // update actual vol lookup if new contract on/off
        if(isNewContractOnOFF && p.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c != 'Covered Outlet Only'){ // Updated by Alan Wong (Elufa) 20150630
            for(ASI_CRM_Subbrand_Volume__c v : LVol){
                for(ASI_TH_CRM_PaymentRequestLineItem__c pl : LPaymentLineInsert){
                    if(pl.ASI_CRM_CN_Sub_Brand__c == v.ASI_CRM_Subbrand__c){
                        v.ASI_CRM_CN_Payment_Request_Line_Item__c = pl.id;
                        system.debug('ASI_CRM_CN_Payment_Request_Line_Item__c:::' + v.ASI_CRM_CN_Payment_Request_Line_Item__c);
                        break;
                    }
                }
            }
            system.debug('LVol.size:::' + LVol.size());
            if(LVol != null && LVol.size()>0){
                update LVol;
            }
        }
        }
    }
    
    public static List<Decimal> calcActVolPerItem(id subBrandID, List<ASI_CRM_Subbrand_Volume__c> LVol, ASI_TH_CRM_PaymentRequest__c p, Set<id> SOutletID){
        System.debug(subBrandID);
        System.debug(LVol);
        System.debug(p);
        System.debug(SoutletID);
        List<Decimal> result = new List<Decimal>{0,0,0};        
        Date StartDate  = p.ASI_CRM_CN_BRSF_Start_Date__c;
        Date EndDate        = p.ASI_CRM_CN_BRSF_End_Date__c;
        if(StartDate != null){
            StartDate = StartDate.toStartOfMonth(); 
        }
        if(EndDate != null){
            EndDate = EndDate.toStartOfMonth().addMonths(1).addDays(-1); 
        }
        System.debug(SOutletID);
        for(ASI_CRM_Subbrand_Volume__c v : LVol){
            System.debug(v.ASI_CRM_Account__c);
            if(SOutletID.contains(v.ASI_CRM_Account__c) && subBrandID == v.ASI_CRM_Subbrand__c){
                if(v.ASI_CRM_End_Date__c <= EndDate && v.ASI_CRM_End_Date__c >= StartDate){
                    if(v.ASI_CRM_Actual_Vol__c != null)
                        result[0] += v.ASI_CRM_Actual_Vol__c;
                    if(v.ASI_CRM_Bottle_Collected__c != null)
                        result[1] += v.ASI_CRM_Bottle_Collected__c;
                    if(v.ASI_CRM_Offtake_Std_Billing__c != null)
                        Result[2] += v.ASI_CRM_Offtake_Std_Billing__c;
                }
            }
        }
        
		//Added by William Yang(Introv) 20150309, for the request to remove decimal on ASI_CRM_CN_Payable_Vol__c 
        if(result != null && result.size() > 0 ){
            //20151217 Ben @ Elufa System change RoundingMode.HALFUP tp FLOOR
            result[0] = result[0].round(System.RoundingMode.FLOOR);
			result[1] = result[1].round(System.RoundingMode.FLOOR);
        }
        //End 20150309
		
        return result;
    }
        
    public static Set<id> returnCoveredOuteletID(ASI_TH_CRM_PaymentRequest__c p){
        Set<id> SResult = new Set<id>();
        for(ASI_CRM_CN_Covered_Outlet__c o : [Select id, ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :p.ASI_TH_CRM_Contract__c]){
            SResult.add(o.ASI_CRM_CN_Outlet__c);
        }       
        return SResult;
    }
    
    public static boolean FirstPaymentExist(ASI_TH_CRM_PaymentRequest__c p){
        boolean result = false;
        if([Select id, name from ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c = :p.ASI_TH_CRM_Contract__c and ASI_CRM_CN_First_Payment__c = true].size()>0)
            result = true;
        System.debug(result);
        return result;
    }
    //2014-08-01 Stella Sing Add Cut Off Date
     public static date CutOffDate(integer strDay){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
         Integer strYear;
        if (strDay != 0){
            if (strDate >= strDay){
                strMonth = Date.Today().addMonths(-1).Month();
                strYear = Date.Today().addMonths(-1).year();
            }
            if (strDate < strDay){
                strMonth = Date.Today().addMonths(-2).Month();
                strYear = Date.Today().addMonths(-2).year();
            }
            strEndDay = Date.daysInMonth(strYear, strMonth);//strEndDay = Date.daysInMonth(Date.Today().Year(), strMonth);
            returnDate = Date.newinstance(strYear,strMonth,strEndDay);//returnDate = Date.newinstance(Date.Today().Year(),strMonth,strEndDay);
        }else{
            returnDate = Date.Today();
        }
        return returnDate;
    }
    
}