/**********************************************************************************
* Name : ASI_KOR_BMPaymentSettlementController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-02-17       Laputa: Vincent         [VL 1.0] add new column Total Basic, Prepayment and Final Total; 
* 											if the payment is not in proposal, not allow to change pay option
* 2017-02-22		Laputa: Vincent			[VL 2.0] create new section (class) for CA brand grouping
* 2017-05-05		Laputa: Vincent			[VL 3.0] P4.2
* 2017-08-01		Laputa: Vincent			[VL 4.0] P4.2, retuns the report id
* 2017-09-08		Laputa: Vincent			[VL 5.0] check SR status before submit
**********************************************************************************/
global without sharing class ASI_KOR_BMPaymentSettlementController { 
    
    public ASI_KOR_BM_Payment_Settlement_Header__c bmPaymentSettlementHeader { get; set; }
    public ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeader { get; set; }
    private Map<String, Decimal> brandBudget = new Map<String,Decimal>();
    public Map<Id,Id> userToSR;
    public Boolean renderProposal {get; set;}
    public List<User> salesReps {get; set ;}
    public User salesRep {get; set;}
    public Id selectedSR {get; set;}
    public Boolean renderApprove {get; set;}
    public Boolean disabledApprove {get; set;}
    public Boolean renderReject {get; set;}
    public Boolean disabledReject {get; set;}
    
	/* [VL 1.0] BEGIN */
	public Decimal 	GrandTotal_volume {get;set;}
	public Decimal 	GrandTotal_VI {get;set;}
	public Decimal 	GrandTotal_prepayment {get;set;}
	public Decimal 	GrandTotal_prepaymentVolume {get;set;}
	public Decimal 	GrandTotal_finaltotal {get;set;}
	public Decimal 	GrandTotal_incentive {get;set;}
	public String 	getGrandBudgetStatus(){
		return GrandTotal_VI > GrandTotal_incentive ? 'Exceed Scheme' : 'Within Scheme';
	}
	public Decimal 	getGrandTotal_UC(){
		return GrandTotal_VI / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
	} 
	public Decimal 	GrandTotal_noOfTransaction {get;set;}
	/* [VL 1.0] END */
	
    public ASI_KOR_BMPaymentSettlementController (ApexPages.StandardController standardController){
        renderApprove = true;
        renderReject = true;
        disabledReject = false;
        disabledApprove = false;
        
		/* [VL 3.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_VI = 0;
		GrandTotal_prepayment = 0;
		GrandTotal_prepaymentVolume = 0;
		GrandTotal_finaltotal = 0;
		GrandTotal_incentive = 0;
		GrandTotal_noOfTransaction = 0;
		/* [VL 3.0] END */
        
        Id  headerId  =  ((ASI_KOR_BM_Payment_Settlement_Header__c) standardController.getRecord()).id;
        bmPaymentSettlementHeader  = [select id, ownerId,
                                      ASI_KOR_Status__c,        
                                      ASI_KOR_Month__c,
                                      ASI_KOR_Year__c,     
                                      ASI_KOR_CA_Amount_excl_Basic__c,
                                      ASI_KOR_CA_Amount_Pending__c,
                                      ASI_KOR_No_of_Submitted_Sales_Rep__c,
                                      ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                      ASI_KOR_RSD_Payment_Settlement__c,
                                      ASI_KOR_Comments__c     
                                      /* [VL 1.0] BEGIN */
                                      , ASI_KOR_Final_Basic_Amount__c
                                      , ASI_KOR_Pre_Payment_Amount__c
                                      , ASI_KOR_Final_Total_Amount__c
                                      /* [VL 1.0] END */
									 /* [VL 3.0] BEGIN */
									 , ASI_KOR_Total_VI_Pending__c
									 /* [VL 3.0] END */
                                      from ASI_KOR_BM_Payment_Settlement_Header__c
                                      where id =: headerId];
        renderProposal = false;
        disabledApprove = true;
        disabledReject  = true;
        User bmOwner = [select ASI_KOR_User_Branch_Code__c from User where id =: bmPaymentSettlementHeader.ownerId];
        userToSR = new Map<Id,Id>();
        List<ASI_KOR_SR_Payment_Settlement_Header__c> headerList = [select 
                                                                    id, ownerid, Owner.name, 
                                                                    ASI_KOR_Year__c, 
                                                                    ASI_KOR_Month__c,
                                                                    ASI_KOR_Status__c
                                                                    from ASI_KOR_SR_Payment_Settlement_Header__c 
                                                                    where
                                                                    ASI_KOR_BM_Payment_Settlement_Header__c =:bmPaymentSettlementHeader.id
                                                                    and (ASI_KOR_Status__c ='Submitted' OR ASI_KOR_Status__c ='Approved by BM')
                                                                    order by ASI_KOR_Year__c desc, ASI_KOR_Month__c desc];
        
        for(ASI_KOR_SR_Payment_Settlement_Header__c header : headerList ){
            
            if(userToSR.get(header.ownerid) == null){
                userToSR.put(header.ownerid, header.id);
            }
            
        }
        
        salesReps = [select id, name from User where id in : userToSR.keySet()];
        //brandBudget = ASI_KOR_BMApprovalController.populateBrandBudget(bmPaymentSettlementHeader.ASI_KOR_Month__c,bmPaymentSettlementHeader.ASI_KOR_Year__c,bmOwner.ASI_KOR_User_Branch_Code__c);
        populateBMPaymentBranch();     
    }
    
    public List<SelectOption> getSalesRepsOptions(){
        List<SelectOption> options = new List<SelectOption>();
        for(User u: salesReps){
            options.add(new SelectOption(u.id,u.name));
        }
        return options;
    }
    
    private void populatePaymentSettlementHeader(Id headerId)
    {
		/* [VL 3.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_VI = 0;
		GrandTotal_prepayment = 0;
		GrandTotal_prepaymentVolume = 0;
		GrandTotal_finaltotal = 0;
		GrandTotal_incentive = 0;
		/* [VL 3.0] END */
        
        srPaymentSettlementHeader = [SELECT Id , 
                                     ASI_KOR_CA_Amount_excl_Basic__c, 
                                     ASI_KOR_Final_CA_Amount_excl_Basic__c, 
                                     ASI_KOR_Status__c, 
                                     ASI_KOR_Approval_Comments__c 
                                    /* [VL 1.0] BEGIN */
                                    , ASI_KOR_Final_Basic_Amount__c
                                    , ASI_KOR_Pre_Payment_Amount__c
                                    , ASI_KOR_Final_Total_Amount__c
                                    /* [VL 1.0] END */
                                     from ASI_KOR_SR_Payment_Settlement_Header__c
                                     where Id =: headerId];
        
        //ASI_KOR_SR_Payment_Settlement_Detail__c    
        paymentSettlementDetailsByVenueList = new List<PaymentSettlementDetailsByVenue>();
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> existingPaymentDetails = [
            select id, ASI_KOR_Actual_Volume__c,ASI_KOR_Approved_Unit_Cost_Basic_CA__c, ASI_KOR_Target_Volume__c,
			ASI_KOR_Brand__c, ASI_KOR_Brand__r.name,
		   /* [VL 3.0] BGEIN */
		   /*
			ASI_KOR_Approved_Basic_Unit_Cost__c, ASI_KOR_Approved_Unit_Cost_CA_Only__c, 
            ASI_KOR_Category__c, ASI_KOR_Channel__c, ASI_KOR_CA_Amount_excl_Basic__c,
            ASI_KOR_Progression__c,  ASI_KOR_SR_Payment_Settlement__c,ASI_KOR_Grade__c,ASI_KOR_Pay_Option__c,
            ASI_KOR_Total_Cost_Cap__c,ASI_KOR_UOM__c,ASI_KOR_Keyman_Name__c,
            ASI_KOR_Final_CA_Amount_excl_Basic__c ,ASI_KOR_Keyman_Code__c ,
            ASI_KOR_Random_Reason__c,
            ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c 
			*/
		   /* [VL 3.0] END */
            ASI_KOR_Venue_Name__c,ASI_KOR_Venue_Code__c,ASI_KOR_Venue_Name__r.Name,ASI_KOR_Unit_Cost_Cap_Actual_Volume__c,
															   /* [VL 3.0] BGEIN */
                                                               ASI_KOR_Venue_Name__r.ASI_KOR_Venue_Type__c,
															   ASI_KOR_Remarks__c,
															   ASI_KOR_Budget_Status__c,
															   ASI_KOR_Settlement_Unit_Cost__c,
															   ASI_KOR_Actual_Pre_payment_Volume__c
															   /* [VL 3.0] END */
            /* [VL 1.0] BEGIN */
            , ASI_KOR_Final_Basic_Amount__c
            , ASI_KOR_Pre_Payment_Amount__c
            , ASI_KOR_Final_Total_Amount__c
            //, ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c
            , ASI_KOR_System_Generated_Proposal__c
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            //, ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name
            /* [VL 2.0] END */
            from ASI_KOR_SR_Payment_Settlement_Detail__c
            where ASI_KOR_SR_Payment_Settlement__c =: headerId
			/* [VL 3.0] BEGIN */
			order by ASI_KOR_Venue_Name__r.name, ASI_KOR_Budget_Status__c, ASI_KOR_Final_Basic_Amount__c desc, ASI_KOR_Brand__r.name
			/* [VL 3.0] END */
			];
        
		/* [VL 3.0] BEGIN */
		GrandTotal_noOfTransaction = existingPaymentDetails.size();
		/* [VL 3.0] END */
		
        Map<Id,List<ASI_KOR_SR_Payment_Settlement_Detail__c>> venueDetailsMap = new Map<Id,List<ASI_KOR_SR_Payment_Settlement_Detail__c>>();
        for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : existingPaymentDetails ){        
            if(venueDetailsMap .get(detail.ASI_KOR_Venue_Name__c) == null){
                List<ASI_KOR_SR_Payment_Settlement_Detail__c> detailList = new List<ASI_KOR_SR_Payment_Settlement_Detail__c>();
                detailList.add(detail);
                venueDetailsMap.put(detail.ASI_KOR_Venue_Name__c,detailList);
            }else{
                venueDetailsMap.get(detail.ASI_KOR_Venue_Name__c).add(detail);
            }    
			
			/* [VL 3.0] BEGIN */
			GrandTotal_volume += detail.ASI_KOR_Actual_Volume__c == null ? 0 : detail.ASI_KOR_Actual_Volume__c;
			GrandTotal_VI += detail.ASI_KOR_Final_Basic_Amount__c == null ? 0 : detail.ASI_KOR_Final_Basic_Amount__c;
			GrandTotal_prepayment += detail.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : detail.ASI_KOR_Pre_Payment_Amount__c;
			GrandTotal_finaltotal += detail.ASI_KOR_Final_Total_Amount__c == null ? 0 : detail.ASI_KOR_Final_Total_Amount__c;
			GrandTotal_incentive += (detail.ASI_KOR_Actual_Volume__c == null ? 0 : detail.ASI_KOR_Actual_Volume__c) * (detail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c == null ? 0 : detail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c);
			GrandTotal_prepaymentVolume += detail.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : detail.ASI_KOR_Actual_Pre_payment_Volume__c;
			/* [VL 3.0] END */
        }
        
        List<Contact> allContacts = [select id, name, accountId from contact where accountid in :venueDetailsMap.keySet()];
        
        Map<String,List<SelectOption>> venueContactListOptions = new Map<String,List<SelectOption>>();
        
        for(Contact contact : allContacts){        
            if(venueContactListOptions.get(contact.accountId) == null){
                List<SelectOption> detailList = new List<SelectOption>();
                detailList.add(new SelectOption(contact.id,contact.name));
                venueContactListOptions.put(contact.accountId,detailList);
            }else{
                venueContactListOptions.get(contact.accountId).add(new SelectOption(contact.id,contact.name));
            }    
        }
        
        
        
        List<Account> venues = [select 
								/* [VL 3.0] BEGIN */
								/*
								ASI_KOR_Grade__c,ASI_KOR_Venue_Channel__c, ASI_KOR_Contract_Type__c,
								*/
								/* [VL 3.0] END */
								id, Name, ASI_KOR_Customer_Code__c from Account 
                                where id in:venueDetailsMap.keySet()];
        system.debug('EXISTING VENUE Size: ' + venues.size());
        for(Account venue : venues){
            PaymentSettlementDetailsByVenue paymentSettlementDetailsByVenue = new PaymentSettlementDetailsByVenue(venue,venueDetailsMap.get(venue.id));
			/* [VL 3.0] BEGIN */
			/*
            paymentSettlementDetailsByVenue.currentContacts = venueContactListOptions.get(venue.Id);
			*/
			/* [VL 3.0] END */
            paymentSettlementDetailsByVenueList.add(paymentSettlementDetailsByVenue ); 
        }
        
		/* [VL 3.0] BEGIN */
		paymentSettlementDetailsByVenueList.sort();
		/* [VL 3.0] END */
    }
    
    public void save()
    {
        savePaymentSettlement();
        saveBMPaymentSettlementHeader();      
        saveSRPaymentSettlementHeader();            
        
        ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeaderToUpdate = [select id, ASI_KOR_CA_Amount_excl_Basic__c,        
                                                                                     ASI_KOR_Final_CA_Amount_excl_Basic__c,      
                                                                                     ASI_KOR_Status__c       
                                                                                     from ASI_KOR_SR_Payment_Settlement_Header__c        
                                                                                     where id =: srPaymentSettlementHeader.Id limit 1];      
        
		/* [VL 3.0] BEGIN */
		/*
        ASI_KOR_SRPaymentSettlementController.rollUp(srPaymentSettlementHeaderToUpdate.id);
		*/
		/* [VL 3.0] END */
    }
    
    public /* [VL 3.0] BEGIN *//*void*/PageReference/* [VL 3.0] BEGIN */ quickSave()
    {
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
        try{
            save();
            populatePaymentSettlementHeader(userToSR.get(selectedSR));
            populateBMPaymentBranch();
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }     
		/* [VL 3.0] BEGIN */
        return null;
		/* [VL 3.0] END */
    }
    
    /* [VL 3.0] BEGIN */
    public string checkUnitCostThreshold(){
		if (paymentSettlementDetailsByVenueList == null) {
			return '';
		}
        ASI_CRM_KR_Unit_Cost_Threshold__c unitCostThresholdObj = ASI_CRM_KR_Unit_Cost_Threshold__c.getInstance(bmPaymentSettlementHeader.ASI_KOR_Year__c+'-'+bmPaymentSettlementHeader.ASI_KOR_Month__c);
		Decimal threshold = unitCostThresholdObj.ASI_CRM_KR_Threshold__c;
		string msg = '';
        for (PaymentSettlementDetailsByVenue  paymentSettlementDetailsByVenue : paymentSettlementDetailsByVenueList){
			for (PaymentSettlementDetailsByVenueByCAbrand caBrandDetail : paymentSettlementDetailsByVenue.paymentSettlementDetailsByCAbrand){
                for (ASI_KOR_SR_Payment_Settlement_Detail__c sr: caBrandDetail.paymentSettlementDetails){
					if (sr.ASI_KOR_Actual_Volume__c != null && 
					   sr.ASI_KOR_Actual_Volume__c != 0 &&
					   sr.ASI_KOR_Settlement_Unit_Cost__c != null &&
					   sr.ASI_KOR_Settlement_Unit_Cost__c != 0 &&
					   sr.ASI_KOR_Settlement_Unit_Cost__c >= threshold){
						msg += 'For Venue: <b>'+sr.ASI_KOR_Venue_Name__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Unit Cost가 너무 높게 입력되었습니다. 수정 바랍니다.<br/>';
					   }
				}
            }
        }
        return msg;
    }
    /* [VL 3.0] END */
    
    public /* [VL 3.0] BEGIN *//*void*/PageReference/* [VL 3.0] BEGIN */ savePaymentSettlement()
    {
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementToBeUpdate = new List<ASI_KOR_SR_Payment_Settlement_Detail__c>();
        //Decimal finalCAAmountexclBasic  = 0;
        for (PaymentSettlementDetailsByVenue  paymentSettlementDetailsByVenue : paymentSettlementDetailsByVenueList )
        {
			/* [VL 3.0] BEGIN */
			/*
            String keyManCode = paymentSettlementDetailsByVenue.contactId;
			*/
			/* [VL 3.0] END */ 	
            
            /* [VL 2.0] BEGIN */
            /*
            for (ASI_KOR_SR_Payment_Settlement_Detail__c psd: paymentSettlementDetailsByVenue.paymentSettlementDetails)
            {
                Decimal randomCAFinal = 0;
                
                if(psd.ASI_KOR_Pay_Option__c == 'Random' && psd.ASI_KOR_Random_Reason__c == null) {
                    psd.ASI_KOR_Random_Reason__c.adderror('Must select Random Reason');
                    return;
                }
                
                if(psd.ASI_KOR_Pay_Option__c == 'Random') {
                    randomCAFinal = psd.ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c;
                }
                paymentSettlementToBeUpdate.add(new ASI_KOR_SR_Payment_Settlement_Detail__c(Id=psd.Id,ASI_KOR_Pay_Option__c=psd.ASI_KOR_Pay_Option__c,ASI_KOR_Keyman_Code__c=keyManCode, ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c = randomCAFinal, ASI_KOR_Random_Reason__c = psd.ASI_KOR_Random_Reason__c));        
            }
            */
            for (PaymentSettlementDetailsByVenueByCAbrand caBrandDetail : paymentSettlementDetailsByVenue.paymentSettlementDetailsByCAbrand){
                for (ASI_KOR_SR_Payment_Settlement_Detail__c psd: caBrandDetail.paymentSettlementDetails)
                {   
					/* [VL 3.0] BEGIN */
					/*
                    if(psd.ASI_KOR_Pay_Option__c == 'Random' && psd.ASI_KOR_Random_Reason__c == null) {
                        psd.ASI_KOR_Random_Reason__c.adderror('Must select Random Reason');
                        return;
                    }
                    
                    Decimal randomCAFinal = 0;
                    if(psd.ASI_KOR_Pay_Option__c == 'Random') {
                        randomCAFinal = psd.ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c;
                    }
                    
                    paymentSettlementToBeUpdate.add(new ASI_KOR_SR_Payment_Settlement_Detail__c(Id=psd.Id,ASI_KOR_Pay_Option__c=psd.ASI_KOR_Pay_Option__c,ASI_KOR_Keyman_Code__c=keyManCode, ASI_KOR_Final_CA_Amount_excl_Bsic_Random__c = randomCAFinal, ASI_KOR_Random_Reason__c = psd.ASI_KOR_Random_Reason__c));     
					*/
					/* [VL 3.0] END */ 			
					paymentSettlementToBeUpdate.add(psd);		
                } 
            }
            /* [VL 2.0] END */
            //finalCAAmountexclBasic += paymentSettlementDetailsByVenue.finalCAAmountexclBasic;
        }
        update paymentSettlementToBeUpdate;
        
        Decimal finalCAAmountExclBasic = 0;
        Decimal caAmountPending = 0;
        /* [VL 1.0] BEGIN */
        decimal finalBasic = 0;
        decimal finalPrepayment = 0;
        /* [VL 1.0] BEGIN */
        
        List<ASI_KOR_SR_Payment_Settlement_Header__c> headerList = [select 
                                                                    ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                                                    ASI_KOR_Status__c 
                                                                    /* [VL 1.0] BEGIN */
                                                                    , ASI_KOR_Final_Basic_Amount__c
                                                                    , ASI_KOR_Pre_Payment_Amount__c
                                                                    /* [VL 1.0] END */
                                                                    from ASI_KOR_SR_Payment_Settlement_Header__c 
                                                                    where
                                                                    ASI_KOR_BM_Payment_Settlement_Header__c =:bmPaymentSettlementHeader.id
                                                                    and (ASI_KOR_Status__c ='Submitted' OR ASI_KOR_Status__c ='Approved by BM')];
        
        for(ASI_KOR_SR_Payment_Settlement_Header__c header : headerList ){
            if (header.ASI_KOR_Status__c=='Submitted')
            {
                caAmountPending  += header.ASI_KOR_Final_CA_Amount_excl_Basic__c;
            } else if (header.ASI_KOR_Status__c=='Approved by BM')
            {
                finalCAAmountExclBasic += header.ASI_KOR_Final_CA_Amount_excl_Basic__c;
                /* [VL 1.0] BEGIN */
                finalBasic += header.ASI_KOR_Final_Basic_Amount__c;
                finalPrepayment += header.ASI_KOR_Pre_Payment_Amount__c;
                /* [VL 1.0] BEGIN */
            }
        }
        
        bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c = finalCAAmountExclBasic;
        bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending  ;
        /* [VL 1.0] BEGIN */
        bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c = finalBasic;
        bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c = finalPrepayment;
        /* [VL 1.0] BEGIN */
        //update bmPaymentSettlementHeader;
		
		/* [VL 3.0] BEGIN */
        return null;
		/* [VL 3.0] END */
        
    }
    
    public void saveBMPaymentSettlementHeader()
    {
        if (bmPaymentSettlementHeader != null)
        {
            update bmPaymentSettlementHeader;
        } 
    }
    
    public void saveSRPaymentSettlementHeader()
    {
        if (srPaymentSettlementHeader != null)
        {
            update srPaymentSettlementHeader ;
        } 
    }
    
    public PageReference handleApprove()
    {
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
        try{
            savePaymentSettlement();
            ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeaderToUpdate = [select id, ASI_KOR_CA_Amount_excl_Basic__c,
                                                                                         ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                                                                         ASI_KOR_Status__c 
                                                                                         /* [VL 1.0] BEGIN */
                                                                                         , ASI_KOR_Final_Basic_Amount__c
                                                                                         , ASI_KOR_Pre_Payment_Amount__c
                                                                                         /* [VL 1.0] END */
                                                                                         /* [VL 3.0] BEGIN */
                                                                                         , ASI_KOR_Total_VI_Pending__c
                                                                                         /* [VL 3.0] END */
                                                                                         from ASI_KOR_SR_Payment_Settlement_Header__c  
                                                                                         where id =: srPaymentSettlementHeader.Id limit 1];
            
            if(srPaymentSettlementHeaderToUpdate != null){  
                
                if (srPaymentSettlementHeaderToUpdate.ASI_KOR_Status__c == 'Submitted'){  
                    ASI_KOR_SRPaymentSettlementController.submitted(srPaymentSettlementHeaderToUpdate.id , true);      
                    srPaymentSettlementHeaderToUpdate.ASI_KOR_Status__c='Approved by BM';
                    Decimal caAmountexclBasic = (bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c==null)?0:bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c;
                    bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c = caAmountexclBasic + srPaymentSettlementHeaderToUpdate.ASI_KOR_CA_Amount_excl_Basic__c;
                    Decimal  finalCAAmountexclBasic =(bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c ==null)?0:bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c;
                    bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c = finalCAAmountexclBasic + srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_CA_Amount_excl_Basic__c ;
                    Decimal caAmountPending = bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c == null?0:bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
                    bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending  - srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_CA_Amount_excl_Basic__c;
                    /* [VL 1.0] BEGIN */
                    Decimal finalBasic = bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c = finalBasic + srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_Basic_Amount__c;
                    Decimal finalPrepayment = bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c = finalPrepayment + srPaymentSettlementHeaderToUpdate.ASI_KOR_Pre_Payment_Amount__c;
                    /* [VL 1.0] END */
                    /* [VL 3.0] BEGIN */
                    Decimal totalVIPending = bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = totalVIPending - srPaymentSettlementHeaderToUpdate.ASI_KOR_Total_VI_Pending__c;
                    /* [VL 3.0] END */
                }        
                
                
                update srPaymentSettlementHeaderToUpdate;
                ASI_KOR_SRPaymentSettlementController.rollUp(srPaymentSettlementHeaderToUpdate.id);
                saveBMPaymentSettlementHeader();
                
                
            }
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }     
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMPaymentSettlement?id='+bmPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference handleReject()
    {
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
        try{
            savePaymentSettlement();
            ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeaderToUpdate = [select id, ASI_KOR_CA_Amount_excl_Basic__c,
                                                                                         ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                                                                         ASI_KOR_Status__c 
                                                                                         /* [VL 1.0] BEGIN */
                                                                                         , ASI_KOR_Final_Basic_Amount__c
                                                                                         , ASI_KOR_Pre_Payment_Amount__c
                                                                                         /* [VL 1.0] END */
                                                                                         /* [VL 3.0] BEGIN */
                                                                                         , ASI_KOR_Total_VI_Pending__c
                                                                                         /* [VL 3.0] END */
                                                                                         from ASI_KOR_SR_Payment_Settlement_Header__c  
                                                                                         where id =: srPaymentSettlementHeader.Id limit 1];
            
            if(srPaymentSettlementHeaderToUpdate != null){    
                
                if (srPaymentSettlementHeaderToUpdate.ASI_KOR_Status__c == 'Approved by BM'){        
                    
                    Decimal caAmountexclBasic = (bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c==   null)?0:bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c;
                    bmPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c = caAmountexclBasic - srPaymentSettlementHeaderToUpdate.ASI_KOR_CA_Amount_excl_Basic__c;
                    Decimal  finalCAAmountexclBasic =(bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c ==null)?0:bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c;
                    bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c = finalCAAmountexclBasic - srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_CA_Amount_excl_Basic__c ;            
                    Decimal noofSubmittedSalesRepresentative = bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c == null ? 0 : bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c;
                    bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c = noofSubmittedSalesRepresentative  - 1; 
                    /* [VL 1.0] BEGIN */
                    Decimal finalBasic = bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c = finalBasic - srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_Basic_Amount__c;
                    Decimal finalPrepayment = bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c = finalPrepayment - srPaymentSettlementHeaderToUpdate.ASI_KOR_Pre_Payment_Amount__c;
                    /* [VL 1.0] END */
					system.debug('reject');
					system.debug(finalBasic);
					system.debug(srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_Basic_Amount__c);
					system.debug(bmPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c);
                    
                } else {
                    Decimal  finalCAAmountexclBasic =(srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_CA_Amount_excl_Basic__c ==null)?0:srPaymentSettlementHeaderToUpdate.ASI_KOR_Final_CA_Amount_excl_Basic__c;
                    Decimal caAmountPending = bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c == null?0:bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
                    bmPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending  - finalCAAmountexclBasic;
                    Decimal noofSubmittedSalesRepresentative = bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c == null ? 0 : bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c;
                    bmPaymentSettlementHeader.ASI_KOR_No_of_Submitted_Sales_Rep__c = noofSubmittedSalesRepresentative  - 1; 
                    /* [VL 3.0] BEGIN */
                    Decimal totalVIPending = bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null?0:bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c; 
                    bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = totalVIPending - srPaymentSettlementHeaderToUpdate.ASI_KOR_Total_VI_Pending__c;
                    /* [VL 3.0] END */
                    
                }
                ASI_KOR_SRPaymentSettlementController.submitted(srPaymentSettlementHeaderToUpdate.id , false);
                srPaymentSettlementHeaderToUpdate.ASI_KOR_Status__c='Rejected';
                update srPaymentSettlementHeaderToUpdate;
                ASI_KOR_SRPaymentSettlementController.rollDown(srPaymentSettlementHeaderToUpdate.id);
                ASI_KOR_SRPaymentSettlementController.rollDownDetails(srPaymentSettlementHeaderToUpdate.id);
                saveBMPaymentSettlementHeader();
                
                
            }
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }     
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMPaymentSettlement?id='+bmPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference normalSave()
    {
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
        save();
        PageReference pageRef   = new PageReference('/'+bmPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public static void submitted(Id headerId, Boolean flag){
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmPaymentSettlementByBrandList = [select id, ASI_KOR_Submitted__c from 
                                                                                          ASI_KOR_BM_Payment_Settlement_By_Brand__c where ASI_KOR_BM_Payment_Settlement__c = :headerId];
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c s : bmPaymentSettlementByBrandList){
            s.ASI_KOR_Submitted__c = flag;
        }
        
        try{
            update bmPaymentSettlementByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    public PageReference handleSubmit(){
        
		/* [VL 3.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 3.0] END */
        
		/* [VL 5.0] BEGIN */
		if (getSubmittedSR()>0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please approve or reject all SR Payment Settlement before submit.'));
			return null;    
		}
		/* [VL 5.0] END */
		
        if (paymentSettlementDetailsByVenueList !=null && paymentSettlementDetailsByVenueList.size() >0)
        {
            savePaymentSettlement();
        }
        submitted(bmPaymentSettlementHeader.id,true);
        ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader = [SELECT ASI_KOR_CA_Amount_Pending__c, 
																				ASI_KOR_No_of_Sumitted_Branches__c
																				/* [VL 3.0] BEGIN */
																				, ASI_KOR_Total_VI_Pending__c
																				/* [VL 3.0] END */
                                                                               from ASI_KOR_RSD_Payment_Settlement_Header__c 
																			   WHERE Id = :bmPaymentSettlementHeader.ASI_KOR_RSD_Payment_Settlement__c];
        
        Decimal caAmountPending = rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c == null?0:rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
        rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c  = caAmountPending  + bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c;
        Decimal noOfSubmittedBranches = rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c== null?0:rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c;
        rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c= noOfSubmittedBranches + 1;
		/* [VL 3.0] BEGIN */
        rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = (rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c) + getBMTotalBasic();
		/* [VL 3.0] END */
        
        
        bmPaymentSettlementHeader.ASI_KOR_Status__c = 'Submitted';
        bmPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c= getBMCABudget();
        //rollUp(bmPaymentSettlementHeader.Id);
        
        
        try{
            update bmPaymentSettlementHeader;
            update rsdPaymentSettlementHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/'+bmPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference handleRecall(){
        bmPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
        //rollDown(bmPaymentSettlementHeader.id);
        submitted(bmPaymentSettlementHeader.id,false);
        ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader = [SELECT  ASI_KOR_CA_Amount_Pending__c, 
																				ASI_KOR_No_of_Sumitted_Branches__c
																				/* [VL 3.0] BEGIN */
																				, ASI_KOR_Total_VI_Pending__c
																				/* [VL 3.0] END */
                                                                               from ASI_KOR_RSD_Payment_Settlement_Header__c 
																			   WHERE Id = :bmPaymentSettlementHeader.ASI_KOR_RSD_Payment_Settlement__c];
        
        Decimal caAmountPending = rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c == null?0:rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
        rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c  = caAmountPending  - bmPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c;
        
        Decimal noOfSubmittedBranches = rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c== null?0:rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c;
        rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c= noOfSubmittedBranches - 1;
        
        /* [VL 3.0] BEGIN */
        rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : (rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c - getBMTotalBasic());
		/* [VL 3.0] END */
		
        try{
            update bmPaymentSettlementHeader;
            update rsdPaymentSettlementHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMPaymentSettlement?id='+bmPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    public static void rollUp(Id headerId){
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> paymentSettlementByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                                        ASI_KOR_BM_Payment_Settlement_By_Brand__c where ASI_KOR_BM_Payment_Settlement__c = :headerId];
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c s : paymentSettlementByBrandList){
            s.ASI_KOR_Roll_up__c = true;
        }
        try{
            update paymentSettlementByBrandList;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    public static void rollUp(Id headerId,Boolean flag){
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> paymentSettlementByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                                        ASI_KOR_BM_Payment_Settlement_By_Brand__c where ASI_KOR_BM_Payment_Settlement__c = :headerId];
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c s : paymentSettlementByBrandList){
            s.ASI_KOR_Roll_up__c = flag;
        }
        try{
            update paymentSettlementByBrandList;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    public static void rollDown(Id headerId){
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> paymentSettlementByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                                        ASI_KOR_BM_Payment_Settlement_By_Brand__c where ASI_KOR_BM_Payment_Settlement__c = :headerId];
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c s : paymentSettlementByBrandList){
            s.ASI_KOR_Roll_up__c = false;
        }
        try{
            update paymentSettlementByBrandList;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    /* [VL 2.0] BEGIN */
    public class PaymentSettlementDetailsByVenueByCAbrand {
		/* [VL 3.0] BEGIN */
		/*
        public Decimal caAmountexclBasic {get;set;}
        public Decimal finalCAAmountexclBasic {get;set;}
        public Decimal finalBasic {get;set;}
        public Decimal finalPrepayment {get;set;}
        public Decimal finalTotal {get;set;}
        public Decimal actualVolume {get;set;}
        public String caBrand {get;set;}
		*/
        /* [VL 3.0] END */
        
        public List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails {get;set;}
        
        public PaymentSettlementDetailsByVenueByCAbrand(string caBrand, List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails){
			/* [VL 3.0] BEGIN */
			/*
            caAmountexclBasic = 0;
            finalCAAmountexclBasic  = 0;
            finalBasic = 0;
            finalPrepayment = 0;
            finalTotal = 0;
            actualVolume = 0;
            this.caBrand = caBrand;
			*/
			/* [VL 3.0] END */
            this.paymentSettlementDetails = paymentSettlementDetails ;
            if (paymentSettlementDetails.size() > 0)
            {
                for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : paymentSettlementDetails ){
					/* [VL 3.0] BEGIN */
					/*
                    if(detail.ASI_KOR_CA_Amount_excl_Basic__c!= null)
                    {
                        caAmountexclBasic += detail.ASI_KOR_CA_Amount_excl_Basic__c;
                    }
                    if(detail.ASI_KOR_Final_CA_Amount_excl_Basic__c!= null)
                    {
                        finalCAAmountexclBasic  += detail.ASI_KOR_Final_CA_Amount_excl_Basic__c;     
                    }
                    if(detail.ASI_KOR_Final_Basic_Amount__c!= null)
                    {
                        finalBasic  += detail.ASI_KOR_Final_Basic_Amount__c;     
                    }
                    if(detail.ASI_KOR_Pre_Payment_Amount__c!= null)
                    {
                        finalPrepayment  += detail.ASI_KOR_Pre_Payment_Amount__c;     
                    }
                    if(detail.ASI_KOR_Final_Total_Amount__c!= null)
                    {
                        finalTotal  += detail.ASI_KOR_Final_Total_Amount__c;     
                    }
                    if(detail.ASI_KOR_Actual_Volume__c!= null)
                    {
                        actualVolume  += detail.ASI_KOR_Actual_Volume__c;     
                    }
					*/
					/* [VL 3.0] END */
                }    
            }
        }
    }
    /* [VL 2.0] END */
    
    
    public class PaymentSettlementDetailsByVenue /* [VL 3.0] BEGIN */ implements Comparable /* [VL 3.0] END */ {
        public Account venue {get;set;}
		/* [VL 3.0] BEGIN */
		/*
        public List<SelectOption> currentContacts {get;set;}
        public Decimal caAmountexclBasic {get;set;}
        public Decimal finalCAAmountexclBasic {get;set;} 
		*/
        /* [VL 3.0] END */
        /* [VL 1.0] BEGIN */
        public Decimal finalBasic {get;set;}
        public Decimal finalPrepayment {get;set;}
        public Decimal finalTotal {get;set;}
        /* [VL 1.0] END */
        /* [VL 3.0] BEGIN */
        public Decimal actualVolume {get;set;}
        public Decimal prepaymentVolume {get;set;}
        public Decimal totalIncentive {get;set;}
        /* [VL 3.0] END */
        /* [VL 2.0] BEGIN */
        /*
        public List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails {get;set;}
        */
        public List<PaymentSettlementDetailsByVenueByCAbrand> paymentSettlementDetailsByCAbrand {get;set;}
        /* [VL 2.0] END */
		/* [VL 3.0] BEGIN */
		/*
        public String contactId {get;set;}  
		*/
        /* [VL 3.0] END */
        
        /* [VL 3.0] BEGIN */
        public Decimal getTotalSettlementUC(){
			return finalBasic / (actualVolume == 0 ? 1 : actualVolume);
		}
        public Decimal getTotalIncentiveUC(){
			return totalIncentive / (actualVolume == 0 ? 1 : actualVolume);
		}
		public string getVenueBudgetStatus(){
			return getTotalSettlementUC() > getTotalIncentiveUC() ? 'Exceed Scheme' : 'Within Scheme';
		}
		public Integer compareTo(Object compareTo){
			PaymentSettlementDetailsByVenue compareToWrap = (PaymentSettlementDetailsByVenue)compareTo;
			Integer returnValue = 0;
			if (finalBasic>compareToWrap.finalBasic) {
				returnValue = -1;
			} else
			if (finalBasic<compareToWrap.finalBasic) {
				returnValue = 1;
			} 
			return returnValue;
		}
        /* [VL 3.0] END */
		
        public PaymentSettlementDetailsByVenue(Account venue,  List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails){    
			/* [VL 3.0] BEGIN */
			/*
            caAmountexclBasic = 0;
            finalCAAmountexclBasic  = 0;  
			*/
			/* [VL 3.0] END */
            /* [VL 1.0] BEGIN */
            finalBasic = 0;
            finalPrepayment  = 0;
            finalTotal = 0;
            /* [VL 1.0] END */ 
            /* [VL 3.0] BEGIN */
            actualVolume = 0;
            totalIncentive  = 0;
			prepaymentVolume = 0;
            /* [VL 3.0] END */
            this.venue = venue;
            /* [VL 2.0] BEGIN */
            /*
            this.paymentSettlementDetails = paymentSettlementDetails ;
            */
            map<string, list<ASI_KOR_SR_Payment_Settlement_Detail__c>> map_caBrand_detail = new map<string, list<ASI_KOR_SR_Payment_Settlement_Detail__c>>();
            /* [VL 2.0] END */
            if (paymentSettlementDetails.size() > 0)
            {
				/* [VL 3.0] BEGIN */
				/*
                contactId = paymentSettlementDetails.get(0).ASI_KOR_Keyman_Code__c;
				*/
				/* [VL 3.0] END */
                for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : paymentSettlementDetails ){
					/* [VL 3.0] BEGIN */
					/*
                    if(detail.ASI_KOR_CA_Amount_excl_Basic__c!= null)
                    {
                        caAmountexclBasic += detail.ASI_KOR_CA_Amount_excl_Basic__c;
                    }
                    if(detail.ASI_KOR_Final_CA_Amount_excl_Basic__c!= null)
                    {
                        finalCAAmountexclBasic  += detail.ASI_KOR_Final_CA_Amount_excl_Basic__c;     
                    } 
					*/
					/* [VL 3.0] END */
                    /* [VL 1.0] BEGIN */
                    if(detail.ASI_KOR_Final_Basic_Amount__c!= null)
                    {
                        finalBasic += detail.ASI_KOR_Final_Basic_Amount__c;
                    }
                    if(detail.ASI_KOR_Pre_Payment_Amount__c!= null)
                    {
                        finalPrepayment  += detail.ASI_KOR_Pre_Payment_Amount__c;     
                    }
                    if(detail.ASI_KOR_Final_Total_Amount__c!= null)
                    {
                        finalTotal  += detail.ASI_KOR_Final_Total_Amount__c;     
                    }
                    /* [VL 1.0] END */
                    /* [VL 3.0] BEGIN */
                    if(detail.ASI_KOR_Actual_Volume__c!= null)
                    {
                        actualVolume += detail.ASI_KOR_Actual_Volume__c;
                    }
                    if(detail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c!= null)
                    {
                        totalIncentive  += detail.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c * (detail.ASI_KOR_Actual_Volume__c!= null ? detail.ASI_KOR_Actual_Volume__c : 0);     
                    }
                    if(detail.ASI_KOR_Actual_Pre_payment_Volume__c!= null)
                    {
                        prepaymentVolume += detail.ASI_KOR_Actual_Pre_payment_Volume__c;
                    }
                    /* [VL 3.0] END */
                    /* [VL 2.0] BEGIN */
					/*
                    string caBrand = detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c != null ? detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name : detail.ASI_KOR_Brand__r.name;
                    if (map_caBrand_detail == null || !map_caBrand_detail.containsKey(caBrand)){
                        list<ASI_KOR_SR_Payment_Settlement_Detail__c> temp_list_detail = new list<ASI_KOR_SR_Payment_Settlement_Detail__c>();
                        temp_list_detail.add(detail);
                        map_caBrand_detail.put(caBrand, temp_list_detail);
                    } else {
                        map_caBrand_detail.get(caBrand).add(detail);
                    }
					*/
                    /* [VL 2.0] END */
                }        
                /* [VL 2.0] BEGIN */
                this.paymentSettlementDetailsByCAbrand = new List<PaymentSettlementDetailsByVenueByCAbrand>();
				/* [VL 3.0] BEGIN */
				/*
                for (string caBrand : map_caBrand_detail.keySet()){
                    PaymentSettlementDetailsByVenueByCAbrand detail_byCAbrand = new PaymentSettlementDetailsByVenueByCAbrand(
                    	caBrand,
                        map_caBrand_detail.get(caBrand)
                    );
                    this.paymentSettlementDetailsByCAbrand.add(detail_byCAbrand);
                }
				*/
				PaymentSettlementDetailsByVenueByCAbrand detail_byCAbrand = new PaymentSettlementDetailsByVenueByCAbrand(
					'noCA',
					paymentSettlementDetails
				);
				this.paymentSettlementDetailsByCAbrand.add(detail_byCAbrand);
				/* [VL 3.0] END */
                /* [VL 2.0] END */
            } 
        }
        
        
    }
    
    
    public class BMSettlementByBrandByCategory {
        public String category {get; set; }
        public List<BMPaymentSettlementByBrand> bmPaymentSettlementByBrands {get; set; }
        
        public Decimal getTotalVolume(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Target_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Target_Volume__c;
            }
            return temp;
        }
        
        public Decimal getCABudget(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand  paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_CA_Budget__c != null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_CA_Budget__c;
            }
            return temp;
        } 
        
        public Decimal getTotalCAAmountexclBasic(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            }
            return temp;
        }
        
        /* [VL 1.0] BEGIN */
        public Decimal getTotalFinalBasic(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c;
            }
            return temp;
        }
        
        public Decimal getTotalPrepayment(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c;
            }
            return temp;
        }
        
        public Decimal getTotalFinal(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c;
            }
            return temp;
        }
        /* [VL 1.0] END */
        
        public Decimal getTotalPendingCAAmount(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c;
            }
            return temp;
        }
        
        public Decimal getNFTotalPendingCAAmount(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c;
            }
            return temp;
        }
        
        public Decimal getTotalFinalCAAmountexclBasic(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands  ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c;
            }
            return temp;
        }      
        
        public String getStatus(){
            if(getTotalFinalCAAmountexclBasic()>getCABudget()){
                return 'Exceed Budget';
            }else
                return 'Within Budget';
        }
        
        /* [VL 3.0] BEGIN */
        public Decimal getTotalNormalVolume(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands   ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c;
            }
            return temp;
        }  
        public Decimal getTotalPrepaymentVolume(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands   ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c;
            }
            return temp;
        }  
        public Decimal getTotalVolumeAll(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands   ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c;
            }
            return temp;
        }  
        public Decimal getActualUnitCost(){
            return getTotalFinalBasic()/(getTotalNormalVolume() == 0 ? 1 : getTotalNormalVolume());
        }  
        public Decimal getTotalBudgetVI(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands   ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Budget_Target_VI__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Budget_Target_VI__c;
            }
            return temp;
        }  
        public Decimal getTotalBudgetVolume(){
            Decimal temp = 0;
            for(BMPaymentSettlementByBrand paymentSettlementBrand : bmPaymentSettlementByBrands   ){
                if(paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Budget_Target_Volume__c!= null)
                    temp += paymentSettlementBrand.paymentSettlementByBrand.ASI_KOR_Budget_Target_Volume__c;
            }
            return temp;
        }  
        public Decimal getBudgetUnitCost(){
            return getTotalBudgetVI()/(getTotalBudgetVolume() == 0 ? 1 : getTotalBudgetVolume());
        }  
		public string getBudgetStatus(){
			return getActualUnitCost() > getBudgetUnitCost() ? 'Exceed Target' : 'Within Target';
		}
        /* [VL 3.0] END */
    }
    
    // Added Wrapper Class for ASI_KOR_BM_Payment_Settlement_By_Brand__c to cater formula field
    public class BMPaymentSettlementByBrand {
        
        public ASI_KOR_BM_Payment_Settlement_By_Brand__c paymentSettlementByBrand {get;set;}
        public decimal settlementUnitCost {get;set;}
        
		/* [VL 3.0] BEGIN */
		public boolean getDisplay(){
			if (
				this.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c == 0
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 3.0] END */
        
    } 
    
    public Decimal getBMTotalCAAmountexclBasic()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalCAAmountexclBasic();    
        }
        return temp;
    }
    
    /* [VL 1.0] BEGIN */
    public Decimal getBMTotalBasic()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalFinalBasic();    
        }
        return temp;
    }
    
    public Decimal getBMTotalPrepayment()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalPrepayment();    
        }
        return temp;
    }
    
    public Decimal getBMTotalFinal() 
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalFinal();    
        }
        return temp;
    }
    /* [VL 1.0] END */
    
    public Decimal getBMTotalPendingCAAmount()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalPendingCAAmount();    
        }
        return temp;
    }
    
    public Decimal getBMNFTotalPendingCAAmount()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getNFTotalPendingCAAmount();    
        }
        return temp;
    }
    
    
    public Decimal getBMCABudget()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getCABudget();    
        }
        return temp;
    }
    
    public Decimal getBMTotalFinalCAAmountexclBasic()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalFinalCAAmountexclBasic();    
        }
        return temp;
    }
    
    public String getBranchBudgetStatus(){
        if(getBMTotalFinalCAAmountexclBasic()>getBMCABudget()){
            return 'Exceed Budget';
        }else
            return 'Within Budget';
    }
    
    /* [VL 3.0] BEGIN */
    public Decimal getBMTotalTargetVolume()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalVolume();    
        }
        return temp;
    }
    public Decimal getBMTotalNormalVolume()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalNormalVolume();    
        }
        return temp;
    }
    public Decimal getBMTotalPrepaymentVolume()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalPrepaymentVolume();    
        }
        return temp;
    }
    public Decimal getBMTotalVolumeAll()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalVolumeAll();    
        }
        return temp;
    }
    public Decimal getBMTotalUnitCost()
    {
        return getBMTotalBasic() / (getBMTotalNormalVolume() == 0 ? 1 : getBMTotalNormalVolume());
    }
    public Decimal getBMBudgetVI()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalBudgetVI();    
        }
        return temp;
    }
    public Decimal getBMBudgetVolume()
    {
        Decimal temp = 0;
        for(BMSettlementByBrandByCategory bmSettlementByBrandByCategory:bmSettlementByBrandCategoryList)
        {
            temp += bmSettlementByBrandByCategory.getTotalBudgetVolume();    
        }
        return temp;
    }
    public Decimal getBMTotalUnitCost_budget()
    {
        return getBMBudgetVI() / (getBMBudgetVolume() == 0 ? 1 : getBMBudgetVolume());
    }
		public string getBMBudgetStatus(){
			return getBMTotalUnitCost() > getBMTotalUnitCost_budget() ? 'Exceed Target' : 'Within Target';
		}
    /* [VL 3.0] END */
	
    public List<PaymentSettlementDetailsByVenue> paymentSettlementDetailsByVenueList {get;set;}
    public List<Account> venues {get;set;}
    public String selectedVenues {get; set;}
    public List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrand { get; set;} 
    public List<BMSettlementByBrandByCategory> bmSettlementByBrandCategoryList { get; set; }
    
    public void selectSalesRep(){
        if (selectedSR !=null && !''.equals(selectedSR)){
            populatePaymentSettlementHeader(userToSR.get(selectedSR));
            populateBMPaymentBranch();
            if(userToSR.get(selectedSR)!= null){
                disabledApprove = false;
                disabledReject  = false;
            }
            if(budgetUpdate!=null && budgetUpdate.size() >0)
                try{
                    update budgetUpdate;
                    budgetUpdate.clear();
                }catch(DmlException e){
                    ApexPages.addMessages(e);
                }
        }   
    }
    
    public void handleSummary(){
        
    }
    private List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> budgetUpdate;
    private void populateBMPaymentBranch()
    {
        budgetUpdate = new List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>();
        bmSettlementByBrandCategoryList = new List<BMSettlementByBrandByCategory>();
        
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> paymentSettlementByBrands1 = [SELECT ID, 
                                                                                      ASI_KOR_Approved_Basic_Unit_Cost_Ave__c,
                                                                                      ASI_KOR_CA_Amount_Pending__c,ASI_KOR_Approved_CA_Unit_Cost_Ave__c,ASI_KOR_Total_CA_Amount_Pending__c,
                                                                                      Name, ASI_KOR_Brand__c,  ASI_KOR_Category__c, ASI_KOR_Target_Volume__c, ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                      //ASI_KOR_Approved_Unit_Cost_Basic_CA__c,
                                                                                      ASI_KOR_Actual_Unit_Cost_CA_Only__c,ASI_KOR_Actual_Volume__c,ASI_KOR_Progression__c,
                                                                                      ASI_KOR_Approved_Basic_Unit_Cost__c,ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                      ASI_KOR_CA_Budget__c,ASI_KOR_UOM__c 
                                                                                      /* [VL 1.0] BEGIN */
                                                                                      , ASI_KOR_Total_Final_Basic__c
                                                                                      , ASI_KOR_Pre_Payment_Amount__c
                                                                                      , ASI_KOR_Final_Total_Amount__c
                                                                                      /* [VL 1.0] END */
																						/* [VL 3.0] BEGIN */
                                                                                        , ASI_KOR_Actual_Pre_payment_Volume__c
																						, ASI_KOR_Actual_Volume_Total__c
																						, ASI_KOR_Budget_Target_VI__c
																						, ASI_KOR_Budget_Target_Volume__c
																						, ASI_KOR_Budget_Status__c
                                                                                        /* [VL 3.0] END */
                                                                                      from ASI_KOR_BM_Payment_Settlement_By_Brand__c where ASI_KOR_BM_Payment_Settlement__c =:bmPaymentSettlementHeader.Id];
        
        List<BMPaymentSettlementByBrand> paymentSettlementByBrands = new List<BMPaymentSettlementByBrand>();
        
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c paymentSettlement : paymentSettlementByBrands1) {
            BMPaymentSettlementByBrand paymentWrapper = new BMPaymentSettlementByBrand();
            paymentWrapper.paymentSettlementByBrand = paymentSettlement;
            Decimal totalFinalCa = paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c != null ? paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c : 0;
            Decimal actVolume = paymentSettlement.ASI_KOR_Actual_Volume__c != null ? paymentSettlement.ASI_KOR_Actual_Volume__c : 0;
            paymentWrapper.settlementUnitCost = actVolume == 0 ? 0 : totalFinalCa/actVolume;
            paymentSettlementByBrands.add(paymentWrapper);
        }
        
        Map<String, List<BMPaymentSettlementByBrand>> branchCategoryMap = new Map<String, List<BMPaymentSettlementByBrand>>();
        
        for(BMPaymentSettlementByBrand paymentSettlement : paymentSettlementByBrands){
            if(branchCategoryMap.get(paymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c) == null){
                List<BMPaymentSettlementByBrand> l = new List<BMPaymentSettlementByBrand >();
                l.add(paymentSettlement );
                branchCategoryMap.put(paymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c,l);
            }else{ 
                branchCategoryMap.get(paymentSettlement.paymentSettlementByBrand.ASI_KOR_Category__c).add(paymentSettlement);
            }
            
            /*
if(paymentSettlement .ASI_KOR_CA_Budget__c == null){
paymentSettlement .ASI_KOR_CA_Budget__c = brandBudget.get(paymentSettlement.ASI_KOR_Brand__c);
budgetUpdate.add(paymentSettlement );
}*/
        }
        
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor�s brands'};
            
			/* [VL 3.0] BEGIN */
			/*
			for(String category:  categories){
			*/
			for(String category:  branchCategoryMap.keySet()){
			/* [VL 3.0] END */
                if(branchCategoryMap.get(category) == null)
                    continue;
                BMSettlementByBrandByCategory bm= new BMSettlementByBrandByCategory();
                bm.category = category;
                bm.bmPaymentSettlementByBrands  = branchCategoryMap.get(category);
                bmSettlementByBrandCategoryList.add(bm);
            }
        
        
        
    }
	
	/* [VL 4.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_UC' limit 1];
		return report.id;
	}
	public string getExceptionalReport_notPlanned(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_XPlan' limit 1];
		return report.id;
	}
	public string getYear(){
		return bmPaymentSettlementHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return bmPaymentSettlementHeader.ASI_KOR_Month__c;
	}
	/* [VL 4.0] BEGIN */
    
    /* [VL 5.0] BEGIN */
	private decimal getSubmittedSR(){
		list<ASI_KOR_SR_Payment_Settlement_Header__c> header = [select id,ASI_KOR_Status__c from ASI_KOR_SR_Payment_Settlement_Header__c where ASI_KOR_BM_Payment_Settlement_Header__c =:bmPaymentSettlementHeader.id and ASI_KOR_Status__c = 'Submitted'];
		return header.size();
	}
    /* [VL 5.0] END */
        
    
}