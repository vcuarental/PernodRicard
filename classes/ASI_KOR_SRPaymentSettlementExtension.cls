/*********************************************************************************
 * Name: ASI_KOR_SRPaymentSettlementExtension
 * Description: Create SR Payment Settlement header and details 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??										Created
 * 2017-02-06       Laputa: Vincent         [VL 1.0] SR Payment settlement details, default Pay Option as Full;
 * 											also populate pre-payment
 * 2017-03-05		Laputa: Vincent			[VL 2.0] Populate new Basic Cost value from SR proposal
 * 2017-03-28		Laputa: Vincent			[VL 3.0] Actual Volume Without Prepayment from SR proposal
 * 2017-05-31		Laputa: Vincent			[VL 4.0] Actual Prepayment Volume from SR proposal
 * 2017-06-27		Laputa: Vincent			[VL 5.0] Business Rationale from SR proposal
 */
public without sharing class ASI_KOR_SRPaymentSettlementExtension { 
    
    
    public static void createSRPaymentSettlementDetails(ASI_KOR_SR_Payment_Settlement_Header__c paymentSettlementHeader)
    {
        
        List<ASI_KOR_SR_Proposal_Header__c> proposalHeaders = [SELECT Id, ASI_KOR_Status__c from ASI_KOR_SR_Proposal_Header__c
                                                               Where ASI_KOR_Month__c =:paymentSettlementHeader.ASI_KOR_Month__c 
                                                               and ASI_KOR_Year__c =:paymentSettlementHeader.ASI_KOR_Year__c 
                                                               and OwnerID =:paymentSettlementHeader.OwnerId LIMIT 1];
        
        if (proposalHeaders.size() >  0 && proposalHeaders.get(0).ASI_KOR_Status__c == 'Approved By BM')
        {
            ASI_KOR_SR_Proposal_Header__c proposalHeader = proposalHeaders.get(0);
            
            
            User owner = [select Id, name, ManagerId from user where id =:paymentSettlementHeader.OwnerId];
            
            ASI_KOR_BM_Payment_Settlement_Header__c  bmPaymentSettlementHeader = [SELECT Id from ASI_KOR_BM_Payment_Settlement_Header__c
                                                                                  Where ASI_KOR_Month__c=:paymentSettlementHeader.ASI_KOR_Month__c 
                                                                                  and ASI_KOR_Year__c=:paymentSettlementHeader.ASI_KOR_Year__c 
                                                                                  and OwnerID =:owner.ManagerId LIMIT 1];
            
            if (bmPaymentSettlementHeader != null)
            {
                List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> paymentSettlementByBrands = [select Id,ASI_KOR_Brand__c,
                                                                                             ASI_KOR_UOM__c from ASI_KOR_BM_Payment_Settlement_By_Brand__c
                                                                                             where ASI_KOR_BM_Payment_Settlement__c = :bmPaymentSettlementHeader.Id];
                
                Map<String,Id> paymentSettlementByBrandsMap = new Map<String,Id>();
                
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c paymentSettlementByBrand :paymentSettlementByBrands)
                {
                    paymentSettlementByBrandsMap.put(paymentSettlementByBrand.ASI_KOR_Brand__c+paymentSettlementByBrand.ASI_KOR_UOM__c,paymentSettlementByBrand.id);
                }
                
                System.debug('Flag 1xx: ' + paymentSettlementByBrandsMap);
                
                List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrands = [select
                                                                            ASI_KOR_Brand__c,
                                                                            ASI_KOR_Brand__r.Name,
                                                                            ASI_KOR_UOM__c
                                                                            from ASI_KOR_SR_Proposal_By_Brand__c
                                                                            where
                                                                            ASI_KOR_SR_Proposal_Header__c = :proposalHeader.Id
                                                                           and ASI_KOR_Brand__c <> null
                                                                           and ASI_KOR_UOM__c <> null];
                
                System.debug('Flag 2xx: ' + srProposalByBrands );
                
                Map<String,ASI_KOR_SR_Payment_Settlement_By_Brand__c> newPaymentSettlementByBrands = new Map<String,ASI_KOR_SR_Payment_Settlement_By_Brand__c>();
                
                for (ASI_KOR_SR_Proposal_By_Brand__c proposalByBrand : srProposalByBrands )
                {
                    ASI_KOR_SR_Payment_Settlement_By_Brand__c paymentSettlementByBrand = createPaymentSettlementByBrand(proposalByBrand);    
                    paymentSettlementByBrand.ASI_KOR_SR_Payment_Settlement__c = paymentSettlementHeader.id;
                    Id paymentSettlementByBrandId =  paymentSettlementByBrandsMap.get(paymentSettlementByBrand.ASI_KOR_Brand__c+paymentSettlementByBrand.ASI_KOR_UOM__c);
                    
                    if (paymentSettlementByBrandId == null && !Test.isRunningTest())
                    {
                        paymentSettlementHeader.addError('Please check that Brand: ' + proposalByBrand.ASI_KOR_Brand__r.Name + ' and UOM:  ' + paymentSettlementByBrand.ASI_KOR_UOM__c + ' exists in BM Payment Setttlement Header with Year: ' + paymentSettlementHeader.ASI_KOR_Year__c + ' and Month:  ' + paymentSettlementHeader.ASI_KOR_Month__c);      
                        return;
                    }
                    
                    paymentSettlementByBrand.ASI_KOR_BM_Payment_Settlement_By_Brand__c  = paymentSettlementByBrandId;
                    newPaymentSettlementByBrands.put(paymentSettlementByBrand.ASI_KOR_Brand__c/*+paymentSettlementByBrand.ASI_KOR_UOM__c*/,paymentSettlementByBrand);
                    
                    
                }
                
                System.debug('Flag 2.5xx: ' + newPaymentSettlementByBrands );
                
                Database.insert(newPaymentSettlementByBrands.values());
                
                System.debug('Flag 3xx: ' + newPaymentSettlementByBrands );
                
                List<ASI_KOR_SR_Proposal_Detail__c> srProposalDetails = [select id,
                                                                         ASI_KOR_Target_Volume__c, ASI_KOR_Brand__c, ASI_KOR_Cap_Unit_Cost_Basic__c,
                                                                         ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                         ASI_KOR_Venue__c,ASI_KOR_UOM__c,ASI_KOR_Incentive_Scheme__c,
                                                                         ASI_KOR_Actual_Volume__c,ASI_KOR_Unit_Cost_Cap_Actual_Volume__c
                                                                         /* [VL 1.0] BEGIN */
                                                                         , ASI_KOR_Actual_Pre_Payment_Amount__c
                                                                         /* [VL 1.0] END */
                                                                         /* [VL 2.0] BEGIN */
                                                                         , ASI_KOR_Final_Basic_Cost__c
                                                                         /* [VL 2.0] END */
                                                                         /* [VL 3.0] BEGIN */
                                                                         , ASI_KOR_Actual_Volume_wo_Pre_payment__c
                                                                         /* [VL 3.0] END */
                                                                         /* [VL 4.0] BEGIN */
                                                                         , ASI_KOR_Actual_Pre_payment_Volume__c
																		 , ASI_KOR_Is_Pre_Payment__c
                                                                         /* [VL 4.0] END */
																		/* [VL 5.0] BEGIN */
																		, ASI_KOR_Business_Rationale__c
																		/* [VL 5.0] END */
                                                                         from ASI_KOR_SR_Proposal_Detail__c 
                                                                         where 
                                                                         ASI_KOR_SR_Proposal_ID__c = :proposalHeader.Id];
                
                List<ASI_KOR_SR_Payment_Settlement_Detail__c> newPaymentSettlementDetails = new List<ASI_KOR_SR_Payment_Settlement_Detail__c>();
                
                for (ASI_KOR_SR_Proposal_Detail__c srProposal : srProposalDetails)
                {
					/* [VL 4.0] BEGIN */
					if (srProposal.ASI_KOR_Is_Pre_Payment__c && 
                        (srProposal.ASI_KOR_Actual_Volume__c == null || srProposal.ASI_KOR_Actual_Volume__c == 0) &&
                        (srProposal.ASI_KOR_Actual_Pre_payment_Volume__c == null || srProposal.ASI_KOR_Actual_Pre_payment_Volume__c == 0)
                    ) continue;
					/* [VL 4.0] BEGIN */
                    ASI_KOR_SR_Payment_Settlement_Detail__c  paymentSettlementDetail = createPaymentSettlementDetails(srProposal);
                    paymentSettlementDetail.ASI_KOR_SR_Payment_Settlement__c = paymentSettlementHeader.Id;    
                    System.debug('Flag 4xx: ' + paymentSettlementDetail );
                    ASI_KOR_SR_Payment_Settlement_By_Brand__c paymentSettlementByBrand = newPaymentSettlementByBrands.get(paymentSettlementDetail .ASI_KOR_Brand__c/*+paymentSettlementDetail.ASI_KOR_SR_Proposal_Detail__r.ASI_KOR_UOM__c*/);
                    if (paymentSettlementByBrand !=null)
                    {
                        System.debug('Flag 5xx: ' + paymentSettlementByBrand.Id);
                        paymentSettlementDetail.ASI_KOR_SR_Payment_Settlement_By_Brand__c = paymentSettlementByBrand.Id;
                        paymentSettlementDetail.ASI_KOR_SR_Proposal_Detail__r = null;
                        newPaymentSettlementDetails.add(paymentSettlementDetail);
                    }
                    
                }
                Database.insert(newPaymentSettlementDetails);
                ASI_KOR_SR_Payment_Settlement_Header__c newPaymentSettlementHeader = new ASI_KOR_SR_Payment_Settlement_Header__c(Id=paymentSettlementHeader.Id,ASI_KOR_BM_Payment_Settlement_Header__c=bmPaymentSettlementHeader.id);
                update newPaymentSettlementHeader;
            }
        } else
        {
            paymentSettlementHeader.addError('Please check that SR Proposal Header for Year: ' + paymentSettlementHeader.ASI_KOR_Year__c + ' and Month:  ' + paymentSettlementHeader.ASI_KOR_Month__c + ' record exists and record must be Approved by BM');
        }
        
    }
    
    
    public static ASI_KOR_SR_Payment_Settlement_Detail__c createPaymentSettlementDetails(ASI_KOR_SR_Proposal_Detail__c proposalDetail){
        
        ASI_KOR_SR_Payment_Settlement_Detail__c paymentSettlementDetail = new ASI_KOR_SR_Payment_Settlement_Detail__c();
        paymentSettlementDetail.ASI_KOR_Target_Volume__c= proposalDetail.ASI_KOR_Target_Volume__c;
        paymentSettlementDetail.ASI_KOR_Actual_Volume__c =proposalDetail.ASI_KOR_Actual_Volume__c;
        paymentSettlementDetail.ASI_KOR_Brand__c= proposalDetail.ASI_KOR_Brand__c;        
        /* [VL 2.0] BEGIN */
        /*
        paymentSettlementDetail.ASI_KOR_Approved_Basic_Unit_Cost__c= proposalDetail.ASI_KOR_Cap_Unit_Cost_Basic__c;
        */
        paymentSettlementDetail.ASI_KOR_Approved_Basic_Unit_Cost__c = proposalDetail.ASI_KOR_Final_Basic_Cost__c;
        /* [VL 2.0] END */
        paymentSettlementDetail.ASI_KOR_Approved_Unit_Cost_Basic_CA__c= proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
        paymentSettlementDetail.ASI_KOR_Approved_Unit_Cost_CA_Only__c= proposalDetail.ASI_KOR_Proposal_Unit_Cost_CA_Only__c;
        paymentSettlementDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = proposalDetail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c;
        //paymentSettlementDetail.ASI_KOR_SR_Payment_Settlement_By_Brand__c
        paymentSettlementDetail.ASI_KOR_SR_Proposal_Detail__c = proposalDetail.Id;
        paymentSettlementDetail.ASI_KOR_SR_Proposal_Detail__r = proposalDetail;
        paymentSettlementDetail.ASI_KOR_Venue_Name__c = proposalDetail.ASI_KOR_Venue__c;
        /* [VL 1.0] BEGIN */
        paymentSettlementDetail.ASI_KOR_Pay_Option__c = 'Full';
        paymentSettlementDetail.ASI_KOR_Pre_Payment_Amount__c = proposalDetail.ASI_KOR_Actual_Pre_Payment_Amount__c;
        /* [VL 1.0] END */
        /* [VL 3.0] BEGIN */
        paymentSettlementDetail.ASI_KOR_Actual_Volume_wo_Pre_payment__c = proposalDetail.ASI_KOR_Actual_Volume_wo_Pre_payment__c;
        /* [VL 3.0] END */
        /* [VL 4.0] BEGIN */
        paymentSettlementDetail.ASI_KOR_Actual_Pre_payment_Volume__c = proposalDetail.ASI_KOR_Actual_Pre_payment_Volume__c;
        paymentSettlementDetail.ASI_KOR_Settlement_Unit_Cost__c = (proposalDetail.ASI_KOR_Actual_Volume__c==null || proposalDetail.ASI_KOR_Actual_Volume__c==0) ? 0 : (proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c != null ? proposalDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c : 0);
        /* [VL 4.0] END */
        /* [VL 5.0] BEGIN */
        paymentSettlementDetail.ASI_KOR_Remarks__c = proposalDetail.ASI_KOR_Business_Rationale__c;
        /* [VL 5.0] END */
        return paymentSettlementDetail;
    }
    
    public static ASI_KOR_SR_Payment_Settlement_By_Brand__c createPaymentSettlementByBrand(ASI_KOR_SR_Proposal_By_Brand__c proposalByBrand)
    {
        ASI_KOR_SR_Payment_Settlement_By_Brand__c paymentSettlementByBrand = new ASI_KOR_SR_Payment_Settlement_By_Brand__c();
        paymentSettlementByBrand.ASI_KOR_Brand__c = proposalByBrand.ASI_KOR_Brand__c;
        paymentSettlementByBrand.ASI_KOR_UOM__c = proposalByBrand.ASI_KOR_UOM__c ;
        //paymentSettlementByBrand.ASI_KOR_BM_Payment_Settlement_By_Brand__c = 
        //paymentSettlementByBrand.ASI_KOR_SR_Payment_Settlement__c
        return paymentSettlementByBrand; 
    }
    
    
}