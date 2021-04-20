/**********************************************************************************
* Name : ASI_KOR_BMApprovalController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-05-04		Laputa: Vincent			[VL 1.0] P4.2 logic
* 2017-08-09		Laputa: Vincent			[VL 2.0] P4.2 report
* 2017-09-08		Laputa: Vincent			[VL 3.0] check SR status before submit
**********************************************************************************/
public class ASI_KOR_BMApprovalController{
    
    public ASI_KOR_BM_Proposal_Header__c bmProposalHeader {get; set;}
    public ASI_KOR_SR_Proposal_Header__c srProposalHeader {get; set;}
    public Map<Id,Id> userToSR;
    public Boolean renderProposal {get; set;}
    public List<User> salesReps {get; set ;}
    public User salesRep {get; set;}
    public Id selectedSR {get; set;}
    public Boolean renderRecall {get; set;}
    public Boolean disabledApprove {get; set;}
    public Boolean renderSubmit {get; set;}
    public Boolean disabledReject {get; set;}
    private Boolean updateBMProopsalByBrand = false;
    public List<DetailsByVenue> detailsByVenueList {get;set;}
    public List<DetailsByVenue> filteredDetailsByVenueList {get;set;}
    public List<Account> venues {get;set;}
    public String selectedVenues {get; set;}
    public List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrand { get; set;} 
    public Map<String,DetailsByVenue> detailsByVenueMap {get;set;}
    public List<BMProposalByBrandByCategory> bmProposalByBrandCateogryList { get; set; }
    public Map<Id,String> srHeaderStat;
	
    public Boolean renderApprove {get; set;}
    public Boolean renderReject {get; set;}
        
	/* [VL 1.0] BEGIN */
    public String srMonth {get;set;}
    public String srYear {get;set;} 
    public Decimal GrandTotalByBrand_volume_2M {get;set;}
    public Decimal GrandTotalByBrand_volume_1M {get;set;}
    public Decimal GrandTotalByBrand_volume_TM {get;set;}
    public Decimal GrandTotalByBrand_vi_2M     {get;set;}
    public Decimal GrandTotalByBrand_vi_1M     {get;set;}
    public Decimal GrandTotalByBrand_vi_TM     {get;set;}
    public Decimal GrandTotalByBrand_volume_budget {get;set;}
    public Decimal GrandTotalByBrand_vi_budget     {get;set;}
	public Decimal getGrandTotalByBrand_uc_2M() {
		return GrandTotalByBrand_vi_2M / (GrandTotalByBrand_volume_2M == 0 ? 1 : GrandTotalByBrand_volume_2M);
	}
	public Decimal getGrandTotalByBrand_uc_1M() {
		return GrandTotalByBrand_vi_1M / (GrandTotalByBrand_volume_1M == 0 ? 1 : GrandTotalByBrand_volume_1M);
	}
	public Decimal getGrandTotalByBrand_uc_TM() {
		return GrandTotalByBrand_vi_TM / (GrandTotalByBrand_volume_TM == 0 ? 1 : GrandTotalByBrand_volume_TM);
	}
	public Decimal getGrandTotalByBrand_uc_budget() {
		return GrandTotalByBrand_vi_budget / (GrandTotalByBrand_volume_budget == 0 ? 1 : GrandTotalByBrand_volume_budget);
	}
	public String getGrandTotalByBrandBudgetStatus(){
		return getGrandTotalByBrand_uc_TM() > getGrandTotalByBrand_uc_budget() ? 'Exceed Target' : 'Within Target';
	}
	
	public string getLast2Month_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-2);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getLast2Month_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-2);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public string getLast1Month_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-1);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getLast1Month_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-1);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public string getThisMonth_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Datetime lastDateTime = Datetime.newInstance(thisProposalDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getThisMonth_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Datetime lastDateTime = Datetime.newInstance(thisProposalDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public Decimal 	GrandTotal_volume {get;set;}
	public Decimal 	GrandTotal_UC {get;set;}
	public Decimal 	GrandTotal_VI {get;set;}
	public Decimal 	GrandTotal_volume_lastMonth {get;set;}
	public Decimal 	GrandTotal_UC_lastMonth {get;set;}
	public Decimal 	GrandTotal_VI_lastMonth {get;set;}
	public Decimal 	GrandTotal_incentive {get;set;}
	public String 	getGrandBudgetStatus(){
		return GrandTotal_VI > GrandTotal_incentive ? 'Exceed Scheme' : 'Within Scheme';
	}
	public Decimal 	GrandTotal_noOfTransaction {get;set;}
	/* [VL 1.0] END */
	
    /**

*/
    public ASI_KOR_BMApprovalController(ApexPages.StandardController standardController){
        renderSubmit = false;
        renderRecall = false;
        disabledReject = false;
        disabledApprove = false;
		renderApprove = false;
		renderReject = false;
        Id headerId = ((ASI_KOR_BM_Proposal_Header__c)standardController.getRecord()).id;
        srHeaderStat = new Map<Id,String>();
        
        bmProposalHeader= [select id, ownerId,
                           ASI_KOR_RSD_Proposal_Header__c,
                           ASI_KOR_Status__c,
                           ASI_KOR_Total_Incentive_Amount_Proposal__c,
                           ASI_KOR_Branch_Manager_Comments__c, ASI_KOR_Year__c,
                           ASI_KOR_Month__c,
                           ASI_KOR_Total_CA_Amount_excl_Basic__c,
                           ASI_KOR_Branch_Total_CA_Budget__c,
                           ASI_KOR_NoofSubmittedSalesRepresentative__c,
                           ASI_KOR_CA_Amount_Pending__c,
                           ASI_KOR_Branch__c
						   /* [VL 1.0] BEGIN */
						   , ASI_KOR_Total_VI_Pending__c
						   /* [VL 1.0] END */
                           from ASI_KOR_BM_Proposal_Header__c
                           where id =: headerId];
		
		/* [VL 1.0] BEGIN */
		srYear = bmProposalHeader.ASI_KOR_Year__c;
		srMonth = bmProposalHeader.ASI_KOR_Month__c;
		/* [VL 1.0] END */
        
        User bmOwner = [select ASI_KOR_User_Branch_Code__c from User where id =: bmProposalHeader.ownerId];
        
        if(bmProposalHeader.ASI_KOR_Status__c == 'Draft' || bmProposalHeader.ASI_KOR_Status__c == 'Rejected'){
            renderSubmit = true;
            renderRecall = false;
			renderApprove = true;
			renderReject = true;
        } else 
		if(bmProposalHeader.ASI_KOR_Status__c == 'Submitted'){
            renderSubmit = false;
            renderRecall = true;
			renderApprove = false;
			renderReject = false;
        } else 
		if(bmProposalHeader.ASI_KOR_Status__c == 'Approved by RSD' || bmProposalHeader.ASI_KOR_Status__c == 'Approved by TMKT'){
            renderSubmit = false;
            renderRecall = false;
			renderApprove = false;
			renderReject = false;
        }
        userToSR = new Map<Id,Id>();
        List<ASI_KOR_SR_Proposal_Header__c > srHeaderList = [select 
                                                             id, ownerid, Owner.name, ASI_KOR_Year__c, ASI_KOR_Month__c,
                                                             ASI_KOR_Status__c
                                                             from ASI_KOR_SR_Proposal_Header__c 
                                                             where
                                                             ASI_KOR_BM_Proposal_Header__c =:bmProposalHeader.id
                                                             and (ASI_KOR_Status__c ='Submitted' OR ASI_KOR_Status__c ='Approved by BM')
                                                             order by ASI_KOR_Year__c desc, ASI_KOR_Month__c desc ];
        
        for(ASI_KOR_SR_Proposal_Header__c header : srHeaderList ){
            
            if(userToSR.get(header.ownerid) == null){
                userToSR.put(header.ownerid, header.id);
            }
            srHeaderStat.put(header.id,header.ASI_KOR_Status__c);
        }
        
        salesReps = [select id, name from User where id in : userToSR.keySet()];
        renderProposal = false;
        // String headerID = ApexPages.currentPage().getParameters().get('SRHeader');
        // if(headerID!= null)
        // populate(headerID);
        // populate(userToSR.get(salesReps.get(0).id));
        disabledApprove = true;
        disabledReject  = true;
        //---
        // brandBudget =  populateBrandBudget(bmProposalHeader.ASI_KOR_Month__c,bmProposalHeader.ASI_KOR_Year__c,bmOwner.ASI_KOR_User_Branch_Code__c);
        //---
        
        populateBranchTotal();
    }
    
    
    public Boolean getReadyToSubmit(){
        Set<String> temp = new Set<String>();
        for(Id id : srHeaderStat.keySet()){
            temp.add(srHeaderStat.get(id));
        }
        if(temp.contains('Submitted')){
            return false;
        }else{
            return true;
        }
    }
    public void setReadyToSubmit(Boolean x){
    }
    
    public List<SelectOption> getSalesRepsOptions(){
        List<SelectOption> options = new List<SelectOption>();
        for(User u: salesReps){
            options.add(new SelectOption(u.id,u.name));
        }
        return options;
    }
    
    
    public PageReference handleSelection(){
        system.debug('XXX Chosen SalesRep: '+salesRep.name+ '  id: ' + salesRep.Id);
        Id headerId = userToSR.get(salesRep.id);
        populate(headerId);
        renderProposal = true;
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_SalesRepProposal?id=' + bmProposalHeader.id);
        pageRef.getParameters().put('SRHeader',headerId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    private void populate(Id headerId){
        srProposalHeader = [select id, ASI_KOR_Approval_Comments__c,ASI_KOR_Total_Incentive_Amount_Proposal__c, ASI_KOR_Total_CA_Amount_excl_Basic__c, ASI_KOR_Status__c from ASI_KOR_SR_Proposal_Header__c where id=:headerId];
        system.debug('HHH Header ID: ' + headerId);
        
        //enable or disable buttons
        
        if(srProposalHeader.ASI_KOR_Status__c == 'Approved by BM'){
            disabledReject = false;
            disabledApprove = true;
        }else if('Rejected' == srProposalHeader.ASI_KOR_Status__c){
            disabledApprove = false;
            disabledReject = true;
        }
		
		/* [VL 1.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_UC = 0;
		GrandTotal_VI = 0;
		GrandTotal_volume_lastMonth = 0;
		GrandTotal_UC_lastMonth = 0;
		GrandTotal_VI_lastMonth = 0;
		GrandTotal_incentive = 0;
		GrandTotal_noOfTransaction = 0;
		/* [VL 1.0] END */
        
        detailsByVenueList = new  List<DetailsByVenue>();
        List<ASI_KOR_SR_Proposal_Detail__c> existingDetails = [
            select id,
			/* [VL 1.0] BEGIN */
			/*
            ASI_KOR_Proposal_Unit_Cost_CA_Only__c ,
            ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.name,
            ASI_KOR_SR_Proposal_By_Brand__c ,
            name,
            ASI_KOR_Cap_Total_Basic_CA__c,
            ASI_KOR_UOM__c,ASI_KOR_Growth__c
            ,ASI_KOR_Category__c ,
            ASI_KOR_Last_3_month_Actual_average_UC__c,
            ASI_KOR_Last_3_month_Actual_Average_Volu__c,ASI_KOR_Grade__c,ASI_KOR_Channel__c,ASI_KOR_Cap_Unit_Cost_CA__c,ASI_KOR_Incentive_Scheme__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,
            ASI_KOR_Incentive_Scheme__r.ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
            ASI_KOR_Individual_Venue_Status__c 
			*/
			/* [VL 1.0] END */			
            ASI_KOR_Brand__c, ASI_KOR_Target_Volume__c,ASI_KOR_Business_Rationale__c,ASI_KOR_Venue__c,ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
            ASI_KOR_Total_Incentive_Amount_Proposal__c,ASI_KOR_Cap_Unit_Cost_Basic__c
			/* [VL 1.0] BEGIN */
            /*, ASI_KOR_Brand__r.ASI_KOR_UOM__c*/
			, ASI_KOR_Is_Pre_payment__c
			, ASI_KOR_Actual_Volume_1_Month_Ago__c
			, ASI_KOR_Total_VI_1_Month_Ago__c
			, ASI_KOR_Unit_Cost_1_Month_Ago__c
            , ASI_KOR_Budget_Status__c
			/* [VL 1.0] END */
            from ASI_KOR_SR_Proposal_Detail__c where ASI_KOR_SR_Proposal_ID__c =: headerId
            order by 
			/* [VL 1.0] BEGIN */
			/*
			ASI_KOR_Venue__c, ASI_KOR_Brand__r.name
			*/
			ASI_KOR_Venue__c, ASI_KOR_Budget_Status__c, ASI_KOR_Total_Incentive_Amount_Proposal__c desc, ASI_KOR_Brand__r.name
			/* [VL 1.0] END */];
        system.debug('XXX size of exisiting List : ' + existingDetails.size());
		
		/* [VL 3.0] BEGIN */
		GrandTotal_noOfTransaction = existingDetails.size();
		/* [VL 3.0] END */
        
        Map<Id,List<ASI_KOR_SR_Proposal_Detail__c>> venueDetailsMap = new Map<Id,List<ASI_KOR_SR_Proposal_Detail__c>>();
        
        for(ASI_KOR_SR_Proposal_Detail__c detail : existingDetails ){
            
            if(venueDetailsMap.get(detail.ASI_KOR_Venue__c) == null){
                system.debug('XXX creating new Listfor : ' +detail.ASI_KOR_Venue__c );
                List<ASI_KOR_SR_Proposal_Detail__c> detailList = new List<ASI_KOR_SR_Proposal_Detail__c>();
                detailList.add(detail);
                venueDetailsMap.put(detail.ASI_KOR_Venue__c,detailList);
            }else{
                system.debug('XXX adding new Listfor : ' +detail.ASI_KOR_Venue__c );
                venueDetailsMap.get(detail.ASI_KOR_Venue__c).add(detail);
            }   

			/* [VL 1.0] BEGIN */
			decimal targetVolume = detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
			decimal incentiveUC = detail.ASI_KOR_Cap_Unit_Cost_Basic__c == null ? 0 : detail.ASI_KOR_Cap_Unit_Cost_Basic__c;
			GrandTotal_volume += targetVolume;
			GrandTotal_VI += detail.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : detail.ASI_KOR_Total_Incentive_Amount_Proposal__c;
			GrandTotal_volume_lastMonth += detail.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Actual_Volume_1_Month_Ago__c;
			GrandTotal_VI_lastMonth += detail.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Total_VI_1_Month_Ago__c;
			GrandTotal_incentive += targetVolume * incentiveUC;
			/* [VL 1.0] END */
			
        }
		
			/* [VL 1.0] BEGIN */
			GrandTotal_UC = GrandTotal_VI / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
			GrandTotal_UC_lastMonth = GrandTotal_VI_lastMonth / (GrandTotal_volume_lastMonth == 0 ? 1 : GrandTotal_volume_lastMonth);
			/* [VL 1.0] END */
        
        List<Account> venues = [select id, Name, ASI_KOR_Customer_Code__c,
								/* [VL 1.0] BEGIN */
								/*
								ASI_KOR_Grade__c, ASI_KOR_Contract_Type__c 
								*/
								ASI_KOR_Venue_Type__c
								/* [VL 1.0] END */
								from Account 
                                where id in:venueDetailsMap.keySet()];
        system.debug('EXISTING VENUE Size: ' + venues.size());
        for(Account venue : venues){
            DetailsByVenue detailsByVenue = new DetailsByVenue(venue,venueDetailsMap.get(venue.id));
            detailsByVenueList.add(detailsByVenue); 
        }
		/* [VL 1.0] BEGIN */
		detailsByVenueList.sort();
		/* [VL 1.0] END */
        
    }
    
    public Decimal srTotalLast3Months{get;set;}
    public Decimal getSrTotalIncentive()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {
                temp += bmProposalByBrandByCategory.getTotalIncentiveAmount();    
            }
        }
        return temp;
    }
    
    //-- need to be replace by bm header budget.
    public Decimal getBranchTotalBudget()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {  
                temp += bmProposalByBrandByCategory.getBranchBudget();    
            }
        }
        return temp;
    }
    //--
    
    
    public String getBranchTotalStatus(){
        return getSrTotalCAAmount() > getBranchTotalBudget () ?'Exceed Scheme' : 'Within Scheme';
    }
    
    public void setBranchTotalStatus(String stat){
    }
    
    public Decimal getSrTotalCAAmount()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {
                temp += bmProposalByBrandByCategory.getTotalCAAmount();    
            }
        }
        return temp;
    }
    
    
    public Decimal getSrPendingCAAmount()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {
                temp += bmProposalByBrandByCategory.getPendingCAAmount();    
            }
        }
        return temp;
    }
    
    
    public Decimal getSrTotalPendingIncentiveAmount()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {
                temp += bmProposalByBrandByCategory.getTotalPendingIncentiveAmount();    
            }
        }
        return temp;
    }
    
    public Decimal getSrCAAmount()
    {
        Decimal temp = 0;
        if (bmProposalByBrandCateogryList != null) {
            for (BMProposalByBrandByCategory bmProposalByBrandByCategory: bmProposalByBrandCateogryList)
            {
                temp += bmProposalByBrandByCategory.getPendingCAAmount();    
            }
        }
        return temp;
    }
    
    public class DetailsByVenue /* [VL 1.0] BEGIN */ implements Comparable /* [VL 1.0] END */{
		/* [VL 1.0] BEGIN */
		/*
        public Decimal totalIncentive = 0;
        public Decimal totalCAAmount = 0;
        public Decimal last3monthAveVol = 0;
        public Decimal last3monthAveUnitCost = 0;
		*/
		/* [VL 1.0] END */
        public Account venue {get;set;}
        public List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails {get;set;}
        public DetailsByVenue(Account venue,  List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails){
            this.venue = venue;
            this.proposalDetails = proposalDetails;
        }
        
        public Decimal getTotalIncentive(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                if(detail.ASI_KOR_Total_Incentive_Amount_Proposal__c != null)
                    temp += detail.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : detail.ASI_KOR_Total_Incentive_Amount_Proposal__c;
            }
            return temp;
        } 
        public Decimal getTotalCAAmount(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                if(detail.ASI_KOR_Total_CA_Amount_excl_Basic__c!= null)
                    temp += detail.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : detail.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            }
            return temp;
        } 
		/* [VL 1.0] BEGIN */
        public Decimal getTotalTargetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                temp += detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
            }
            return temp;
        } 
        public Decimal getTotalUC(){
            return getTotalIncentive()/ (getTotalTargetVolume() == 0 ? 1 : getTotalTargetVolume());
        } 
        public Decimal getTotalVI_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                temp += detail.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Total_VI_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalActualVolume_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                temp += detail.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Actual_Volume_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalUC_lastMonth(){
            return getTotalVI_lastMonth()/ (getTotalActualVolume_lastMonth() == 0 ? 1 : getTotalActualVolume_lastMonth());
        } 
        public Decimal getTotalIncentiveCost(){
            Decimal temp = 0;
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
                decimal incentiveUC = detail.ASI_KOR_Cap_Unit_Cost_Basic__c == null ? 0 : detail.ASI_KOR_Cap_Unit_Cost_Basic__c;
                decimal targetVolume = detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
				temp += incentiveUC * targetVolume;
            }
            return temp;
        } 
        public String getVenueStatus(){
            return getTotalIncentive() > getTotalIncentiveCost() ? 'Exceed Scheme' : 'Within Scheme';
        } 
		
		public Integer compareTo(Object compareTo){
			DetailsByVenue compareToWrap = (DetailsByVenue)compareTo;
			Integer returnValue = 0;
			if (getTotalIncentive()>compareToWrap.getTotalIncentive()) {
				returnValue = -1;
			} else
			if (getTotalIncentive()<compareToWrap.getTotalIncentive()) {
				returnValue = 1;
			} 
			return returnValue;
		}
		/* [VL 1.0] END */
        
    }
    
    
    public class SRProposalByBrandByCategory{
        public String category {get; set; }
        public Decimal totalCAAmount {get; set; }
        public Decimal totalIncentiveAmount {get; set; }
        public Decimal last3months {get; set; }
        public List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrands {get; set; }
    }
    
    public class BMProposalByBrandByUnitCap {
        public Decimal unitCostCap {get; set; }
        
        public ASI_KOR_BM_Proposal_By_Brand__c BMProposalByBrandItem {get; set;}
        
        public String getUnitCostStatus(){
            //Decimal x = this.BMProposalByBrandItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            Decimal x = this.unitCostCap != null ? this.unitCostCap : 0;
            //Decimal z = this.BMProposalByBrandItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c;
            Decimal z = this.BMProposalByBrandItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            if(z>x)
                return 'Exceed Recommendation'; 
            else
                return 'Within Recommendation';
        }
		
		/* [VL 1.0] BEGIN */
		public boolean getDisplay(){
			if (
				this.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c == 0 &&
				this.BMProposalByBrandItem.ASI_KOR_Target_Volume_Pending__c == 0 &&
				this.BMProposalByBrandItem.ASI_KOR_Total_VI_1_Month_Ago__c == 0 &&
				this.BMProposalByBrandItem.ASI_KOR_Actual_Volume_1_Month_Ago__c == 0 &&
				this.BMProposalByBrandItem.ASI_KOR_Total_VI_2_Months_Ago__c == 0 &&
				this.BMProposalByBrandItem.ASI_KOR_Actual_Volume_2_Months_Ago__c == 0
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 1.0] END */
    }
    
    public class BMProposalByBrandByCategory{
        public String category {get; set; }
        public Decimal last3months {get; set; }
        public List<BMProposalByBrandByUnitCap> bmProposalByBrands {get; set; }
        
        public Decimal getTotalLast3months (){
            Decimal temp = 0;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands ){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c != null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c == null ? 0 : proposalBrand.BMProposalByBrandItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c;
            }
            return temp;
        } 
        
        public Decimal getTotalIncentiveAmount(){
            Decimal temp = 0;
            if(bmProposalByBrands == null)
                return temp;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands ){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c != null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c;
            }
            return temp;
        } 
        
        public Decimal getTotalPendingIncentiveAmount(){
            Decimal temp = 0;
            if(bmProposalByBrands == null)
                return temp;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands ){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c != null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c== null ? 0 : proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c;
            }
            return temp;
        } 
        public Decimal getPendingCAAmount(){
            Decimal temp = 0;
            if(bmProposalByBrands == null)
                return temp;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands ){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Amount_Pending__c != null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Amount_Pending__c== null ? 0 : proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Amount_Pending__c;
            }
            return temp;
        } 
        public Decimal getBranchBudget(){
            Decimal temp = 0;
            if(bmProposalByBrands == null)
                return temp;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands ){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Budget__c!= null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Budget__c == null ? 0 : proposalBrand.BMProposalByBrandItem.ASI_KOR_CA_Budget__c;
            }
            return temp;
        } 
        public Decimal getTotalCAAmount(){
            Decimal temp = 0;
            if(bmProposalByBrands == null)
                return temp;
            for(BMProposalByBrandByUnitCap proposalBrand : bmProposalByBrands){
                if(proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_CA_Amount_excl_Basic__c!= null)
                    temp += proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 :  proposalBrand.BMProposalByBrandItem.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            }
            return temp;
        }
        
        public String getBranchStatus(){
            Decimal x = getBranchBudget(); 
            Decimal z = getTotalCAAmount();
            if(z>x)
                return 'Exceed Budget'; 
            else
                return 'Within Budget';
        }
		
		/* [VL 1.0] BEGIN */
        public Decimal ASI_KOR_Total_Incentive_Amount_Proposal {get; set; }
        public Decimal ASI_KOR_Target_Volume {get; set; }
        public Decimal ASI_KOR_Total_VI_1M_Ago {get; set; }
        public Decimal ASI_KOR_Actual_Volume_1M_Ago {get; set; }
        public Decimal ASI_KOR_Total_VI_2M_Ago {get; set; }
        public Decimal ASI_KOR_Actual_Volume_2M_Ago {get; set; }
		public Decimal ASI_KOR_Budget_Target_VI {get; set; }
		public Decimal ASI_KOR_Budget_Target_Volume {get; set; }
		public Decimal getUnitCost_thisMonth(){
			return this.ASI_KOR_Total_Incentive_Amount_Proposal/(this.ASI_KOR_Target_Volume == 0 ? 1 : this.ASI_KOR_Target_Volume);
		}
		public Decimal getUnitCost_1MonthAgo(){
			return this.ASI_KOR_Total_VI_1M_Ago/(this.ASI_KOR_Actual_Volume_1M_Ago == 0 ? 1 : this.ASI_KOR_Actual_Volume_1M_Ago);
		}
		public Decimal getUnitCost_2MonthAgo(){
			return this.ASI_KOR_Total_VI_2M_Ago/(this.ASI_KOR_Actual_Volume_2M_Ago == 0 ? 1 : this.ASI_KOR_Actual_Volume_2M_Ago);
		}
		public Decimal getUnitCost_budget(){
			return this.ASI_KOR_Budget_Target_VI/(this.ASI_KOR_Budget_Target_Volume == 0 ? 1 : this.ASI_KOR_Budget_Target_Volume);
		}
		public string getBudgetStatus(){
			return getUnitCost_thisMonth() > getUnitCost_budget() ? 'Exceed Target' : 'Within Target';
		}
		public BMProposalByBrandByCategory(){
			this.ASI_KOR_Total_Incentive_Amount_Proposal = 0;
			this.ASI_KOR_Target_Volume = 0;
			this.ASI_KOR_Total_VI_1M_Ago = 0;
			this.ASI_KOR_Actual_Volume_1M_Ago = 0;
			this.ASI_KOR_Total_VI_2M_Ago = 0;
			this.ASI_KOR_Actual_Volume_2M_Ago = 0;
			this.ASI_KOR_Budget_Target_VI = 0;
			this.ASI_KOR_Budget_Target_Volume = 0;
		}
		/* [VL 1.0] END */
        
    }
    
    
    
    
    public void selectSalesRep(){
        populate(userToSR.get(selectedSR));
        if(budgetUpdate.size()>0){
            update budgetUpdate;
        }
        populateBranchTotal();
        if(userToSR.get(selectedSR)!= null){
            disabledApprove = false;
            disabledReject  = false;
        }
    }
    
    public void handleSummary(){
        
    }
    
    private Map<String, Decimal> brandBudget = new Map<String,Decimal>();
    private List<ASI_KOR_BM_Proposal_By_Brand__c > budgetUpdate;
    
    /**
Populate CA budget amount
*/
    public static Map<String,Decimal> populateBrandBudget(String month, String year, String branchCode){
        Map<String,Decimal> brandBudget = new Map<String,Decimal>();
        List<ASI_KOR_Budget__c> l = [select ASI_KOR_Brand__c,ASI_KOR_CA_Budget_Amount__c from ASI_KOR_Budget__c
                                     where ASI_KOR_Month__c =:month
                                     and ASI_KOR_Year__c =:year
                                     and ASI_KOR_Branch_Code__c =:branchCode];
        
        for(ASI_KOR_Budget__c budget : l){
            brandBudget.put(budget.ASI_KOR_Brand__c, (budget.ASI_KOR_CA_Budget_Amount__c == null ? 0 : budget.ASI_KOR_CA_Budget_Amount__c));
        }
        
        return brandBudget;
    }
    private void populateBranchTotal(){
        budgetUpdate = new List<ASI_KOR_BM_Proposal_By_Brand__c >();
        bmProposalByBrandCateogryList = new List<BMProposalByBrandByCategory>();
        
		/* [VL 1.0] BEGIN */
		GrandTotalByBrand_volume_2M = 0;
		GrandTotalByBrand_volume_1M = 0;
		GrandTotalByBrand_volume_TM = 0;
		GrandTotalByBrand_vi_2M     = 0;
		GrandTotalByBrand_vi_1M     = 0;
		GrandTotalByBrand_vi_TM     = 0;
		GrandTotalByBrand_volume_budget = 0;
		GrandTotalByBrand_vi_budget     = 0;
		/* [VL 1.0] END */
		
        List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrandsTemp =[select
                                                                       ID,Name, 
                                                                       ASI_KOR_Brand__r.name,
                                                                       ASI_KOR_Brand__c,
                                                                       ASI_KOR_CA_Budget__c,
                                                                       ASI_KOR_CA_Budget_Status__c,
                                                                       ASI_KOR_Category__c,
                                                                       ASI_KOR_Growth__c,
                                                                       ASI_KOR_UOM__c,
                                                                       ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                                       ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                                       ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                       ASI_KOR_CA_Amount_Pending__c,
                                                                       ASI_KOR_Target_Volume__c,
                                                                       ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                       ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                       ASI_KOR_Total_Incentive_Amount_Pending__c
																	  /* [VL 1.0] BEGIN */
																	  , ASI_KOR_Actual_Volume_1_Month_Ago__c
																	  , ASI_KOR_Actual_Volume_2_Months_Ago__c
																	  , ASI_KOR_Total_VI_1_Month_Ago__c
																	  , ASI_KOR_Total_VI_2_Months_Ago__c
																	  , ASI_KOR_Target_Volume_Pending__c
																	  , ASI_KOR_Budget_Target_VI__c
																	  , ASI_KOR_Budget_Target_Volume__c
																	  /* [VL 1.0] END */
                                                                       from ASI_KOR_BM_Proposal_By_Brand__c
                                                                       where ASI_KOR_BM_Proposal_Header__c =: bmProposalHeader.id];
        
        List<BMProposalByBrandByUnitCap> BMProposalByBrandByUnitCapList = new List<BMProposalByBrandByUnitCap>();
        Set<ID> brandIDSet = new Set<ID>();
        
        List<ASI_KOR_Budget__c> budgetList = new List<ASI_KOR_Budget__c>();
        Map<String, ASI_KOR_Budget__c> budgetMap = new Map<String, ASI_KOR_Budget__c>();
        
        for(ASI_KOR_BM_Proposal_By_Brand__c bmPerBrand : bmProposalByBrandsTemp) {
            if(bmPerBrand.ASI_KOR_Brand__c != null) {
                brandIDSet.add(bmPerBrand.ASI_KOR_Brand__c);
            }
        }
        
        if(brandIDSet.size() > 0) {
            
            budgetList = [SELECT ID, Name, ASI_KOR_Brand__c, ASI_KOR_Unit_Cost_Cap__c, ASI_KOR_Month__c, ASI_KOR_Year__c,  ASI_KOR_Branch_Name__c
                          FROM ASI_KOR_Budget__c
                          WHERE ASI_KOR_Brand__c IN : brandIDSet 
                          AND ASI_KOR_Month__c = : bmProposalHeader.ASI_KOR_Month__c 
                          AND ASI_KOR_Year__c = : bmProposalHeader.ASI_KOR_Year__c 
                          AND ASI_KOR_Branch_Name__c = : bmProposalHeader.ASI_KOR_Branch__c ];
            
            if(budgetList.size() > 0) {
                for(ASI_KOR_Budget__c budget : budgetList) {
                    budgetMap.put((String)budget.ASI_KOR_Brand__c, budget);
                }
            }
        }
        
        
        for(ASI_KOR_BM_Proposal_By_Brand__c bmProposal : bmProposalByBrandsTemp) {
            BMProposalByBrandByUnitCap bmProposalByUnitCapTemp = new BMProposalByBrandByUnitCap();
            bmProposalByUnitCapTemp.BMProposalByBrandItem = bmProposal;
            
            if(budgetMap.containsKey(bmProposal.ASI_KOR_Brand__c)) {
                bmProposalByUnitCapTemp.unitCostCap = budgetMap.get(bmProposal.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
            }
            
            BMProposalByBrandByUnitCapList.add(bmProposalByUnitCapTemp);
        }
        
        List<BMProposalByBrandByUnitCap> bmProposalByBrands = BMProposalByBrandByUnitCapList;
        
        Map<String, List<BMProposalByBrandByUnitCap>> branchCategoryMap = new Map<String, List<BMProposalByBrandByUnitCap>>();
        
        for(BMProposalByBrandByUnitCap bm: bmProposalByBrands){
            if(branchCategoryMap.get(bm.BMProposalByBrandItem.ASI_KOR_Category__c) == null){
                List<BMProposalByBrandByUnitCap> l = new List<BMProposalByBrandByUnitCap>();
                l.add(bm);
                branchCategoryMap.put(bm.BMProposalByBrandItem.ASI_KOR_Category__c,l);
            }else{ 
                branchCategoryMap.get(bm.BMProposalByBrandItem.ASI_KOR_Category__c).add(bm);
            }
            
            /*
if(bm.ASI_KOR_CA_Budget__c == null){
bm.ASI_KOR_CA_Budget__c = brandBudget.get(bm.ASI_KOR_Brand__c);
budgetUpdate.add(bm);
}
*/
        }
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor’s brands'};
            
			/* [VL 1.0] BEGIN */
			/*
			for(String category:  categories){
			*/
			for(String category:  branchCategoryMap.keySet()){
			/* [VL 1.0] END */
                BMProposalByBrandByCategory b = new BMProposalByBrandByCategory();
                b.category = category;
                b.bmProposalByBrands = branchCategoryMap.get(category);
                bmProposalByBrandCateogryList.add(b);
				
				/* [VL 1.0] BEGIN */
				for (BMProposalByBrandByUnitCap bmByBrandWrap : branchCategoryMap.get(category)){
						ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = bmByBrandWrap.BMProposalByBrandItem;
						b.ASI_KOR_Total_Incentive_Amount_Proposal += bmByBrand.ASI_KOR_Total_Incentive_Amount_Pending__c == null ? 0 : bmByBrand.ASI_KOR_Total_Incentive_Amount_Pending__c;
						b.ASI_KOR_Target_Volume                   += bmByBrand.ASI_KOR_Target_Volume_Pending__c == null ? 0 : bmByBrand.ASI_KOR_Target_Volume_Pending__c;
						b.ASI_KOR_Total_VI_1M_Ago                 += bmByBrand.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Total_VI_1_Month_Ago__c;
						b.ASI_KOR_Actual_Volume_1M_Ago            += bmByBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c;
						b.ASI_KOR_Total_VI_2M_Ago                 += bmByBrand.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Total_VI_2_Months_Ago__c;
						b.ASI_KOR_Actual_Volume_2M_Ago            += bmByBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c;
						b.ASI_KOR_Budget_Target_VI                += bmByBrand.ASI_KOR_Budget_Target_VI__c == null ? 0 : bmByBrand.ASI_KOR_Budget_Target_VI__c;
						b.ASI_KOR_Budget_Target_Volume            += bmByBrand.ASI_KOR_Budget_Target_Volume__c == null ? 0 : bmByBrand.ASI_KOR_Budget_Target_Volume__c;
				}
				GrandTotalByBrand_vi_TM     += b.ASI_KOR_Total_Incentive_Amount_Proposal;
				GrandTotalByBrand_volume_TM += b.ASI_KOR_Target_Volume;
				GrandTotalByBrand_vi_1M     += b.ASI_KOR_Total_VI_1M_Ago;
				GrandTotalByBrand_volume_1M += b.ASI_KOR_Actual_Volume_1M_Ago;
				GrandTotalByBrand_vi_2M     += b.ASI_KOR_Total_VI_2M_Ago;
				GrandTotalByBrand_volume_2M += b.ASI_KOR_Actual_Volume_2M_Ago;
				GrandTotalByBrand_vi_budget     += b.ASI_KOR_Budget_Target_VI;
				GrandTotalByBrand_volume_budget += b.ASI_KOR_Budget_Target_Volume;
				/* [VL 1.0] END */
            }
        
    }
    
    
    public PageReference handleApprove(){
        Id headerId = userToSR.get(selectedSR);
        system.debug('YYY HeaderID: ' + headerId);
        ASI_KOR_SR_Proposal_Header__c header = [select id,ASI_KOR_Status__c,ASI_KOR_Total_CA_Amount_excl_Basic__c, ASI_KOR_Total_Incentive_Amount_Proposal__c from ASI_KOR_SR_Proposal_Header__c where id =: headerId limit 1];
        
        if(header != null){    
            if (header.ASI_KOR_Status__c == 'Submitted'){
                
                header.ASI_KOR_Status__c='Approved by BM';
                srHeaderStat.put(headerId,'Approved by BM');
                Decimal asiBasicAmount = (bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c==null)?0:bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c = asiBasicAmount + header.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                Decimal asiIncentiveAmount =(bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c ==null)?0:bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c = asiIncentiveAmount + header.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                ASI_KOR_SalesRepProposalDetailController.rollUp(headerId,true);
                bmProposalHeader.ASI_KOR_CA_Amount_Pending__c = ( bmProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : bmProposalHeader.ASI_KOR_CA_Amount_Pending__c ) - (header.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : header.ASI_KOR_Total_CA_Amount_excl_Basic__c);
				/* [VL 1.0] BEGIN */
                bmProposalHeader.ASI_KOR_Total_VI_Pending__c = bmProposalHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : bmProposalHeader.ASI_KOR_Total_VI_Pending__c  - (header.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : header.ASI_KOR_Total_Incentive_Amount_Proposal__c);
				/* [VL 1.0] END */
            }        
            
            try{
                update header;
                update bmProposalHeader;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            }
            
            PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMApproval?id=' + bmProposalHeader.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public PageReference handleReject(){
        
        Id headerId = userToSR.get(selectedSR);
        ASI_KOR_SR_Proposal_Header__c header = [select id,
												ASI_KOR_Status__c,
												ASI_KOR_Total_CA_Amount_excl_Basic__c, 
												ASI_KOR_Total_Incentive_Amount_Proposal__c 
												from ASI_KOR_SR_Proposal_Header__c 
												where id =: headerId limit 1];
        
        if(header != null){
            if (header.ASI_KOR_Status__c == 'Approved by BM'){
                
                
                
                bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c -= header.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c -= header.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                //updateBranchTotalBudget();
                ASI_KOR_SalesRepProposalDetailController.rollUp(headerId,false);
                //bmProposalHeader.ASI_KOR_CA_Amount_Pending__c = ( bmProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : bmProposalHeader.ASI_KOR_CA_Amount_Pending__c ) + (header.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : header.ASI_KOR_Total_CA_Amount_excl_Basic__c);
            }
            else { 
                bmProposalHeader.ASI_KOR_CA_Amount_Pending__c = ( bmProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : bmProposalHeader.ASI_KOR_CA_Amount_Pending__c ) - (header.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : header.ASI_KOR_Total_CA_Amount_excl_Basic__c);
				/* [VL 1.0] BEGIN */
                bmProposalHeader.ASI_KOR_Total_VI_Pending__c = ( bmProposalHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : bmProposalHeader.ASI_KOR_Total_VI_Pending__c ) - (header.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : header.ASI_KOR_Total_Incentive_Amount_Proposal__c);
				/* [VL 1.0] END */
            }  
            header.ASI_KOR_Status__c= 'Rejected';
            
            srHeaderStat.put(headerId,'Rejected');
            bmProposalHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c = bmProposalHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c == null ? 0 : (bmProposalHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c - 1);
                header.ASI_KOR_Approval_Comments__c = srProposalHeader.ASI_KOR_Approval_Comments__c;
            ASI_KOR_SalesRepProposalDetailController.submitted(srProposalHeader.id,false);
            try{
                update header;
                update bmProposalHeader;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            }
            
            PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMApproval?id=' + bmProposalHeader.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        return null;
    }
    
    /*
Action method when the submit button is clicked.
Updates the CA BM proposal header status to submitted. and updates the
total branch budget
*/
    public PageReference handleSubmit(){
		
		/* [VL 3.0] BEGIN */
		if (getSubmittedSR()>0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please approve or reject all SR Sales Planning before submit.'));
			return null;    
		}
		/* [VL 3.0] END */
		
        /*
ASI_KOR_RSD_Proposal_Header__c rsdHeader =[select ASI_KOR_No_of_Sumitted_Branches__c,ASI_KOR_CA_Amount_Pending__c
from ASI_KOR_RSD_Proposal_Header__c where id =:bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c];
*/
        submitted(bmProposalHeader.id,true); 
        bmProposalHeader.ASI_KOR_Status__c = 'Submitted';
        bmProposalHeader.ASI_KOR_Branch_Total_CA_Budget__c = getBranchTotalBudget();
        bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c = bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c;
        
        Decimal branchTotalCAAmount = bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c == null? 0 : bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
        bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c = branchTotalCAAmount;
        
        /*
rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c = rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c == null ? 1 : (rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c + 1);
rsdHeader.ASI_KOR_CA_Amount_Pending__c = rsdHeader.ASI_KOR_CA_Amount_Pending__c == null ? branchTotalCAAmount  : (rsdHeader.ASI_KOR_CA_Amount_Pending__c + branchTotalCAAmount);
*/
        
		/* [VL 1.0] BEGIN */
		ASI_KOR_RSD_Proposal_Header__c rsdHeader = [
			select id, ASI_KOR_Total_VI_Pending__c 
			from ASI_KOR_RSD_Proposal_Header__c
			where id =:bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c
			limit 1
		];
		decimal rsdTotalPendingVI = rsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : rsdHeader.ASI_KOR_Total_VI_Pending__c;
		rsdHeader.ASI_KOR_Total_VI_Pending__c = rsdTotalPendingVI + getSrTotalIncentive();
		/* [VL 1.0] END */
		
        try{
            //update rsdHeader;
			/* [VL 1.0] BEGIN */
			update rsdHeader;
			/* [VL 1.0] END */
            update bmProposalHeader;
            //rollUp(bmProposalHeader.id); //set the roll up status flags of bm proposal by brands objects;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMApproval?id=' + bmProposalHeader.id);
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public static void submitted(Id headerId, Boolean flag){
        List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrandList = [select id, ASI_KOR_Submitted__c from 
                                                                       ASI_KOR_BM_Proposal_By_Brand__c where ASI_KOR_BM_Proposal_Header__c = :headerId];
        for(ASI_KOR_BM_Proposal_By_Brand__c s : bmProposalByBrandList){
            s.ASI_KOR_Submitted__c = flag;
        }
        
        try{
            update bmProposalByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    /*
Action method when the recall button is clicked.
Updates the CA BM proposal header status to 'Draft'.
*/
    public PageReference handleRecall(){
        /*
ASI_KOR_RSD_Proposal_Header__c rsdHeader =[select ASI_KOR_No_of_Sumitted_Branches__c,ASI_KOR_CA_Amount_Pending__c
from ASI_KOR_RSD_Proposal_Header__c where id =:bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c];
*/

		/* [VL 1.0] BEGIN */
		ASI_KOR_RSD_Proposal_Header__c rsdHeader = [
			select id, ASI_KOR_Total_VI_Pending__c 
			from ASI_KOR_RSD_Proposal_Header__c
			where id =:bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c
			limit 1
		];
		rsdHeader.ASI_KOR_Total_VI_Pending__c = rsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : (rsdHeader.ASI_KOR_Total_VI_Pending__c - getSrTotalIncentive());
		/* [VL 1.0] END */
		
        
        try{
            
            bmProposalHeader.ASI_KOR_Status__c = 'Draft';
            submitted(bmProposalHeader.id,false);
            Decimal branchTotalCAAmount = bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c == null? 0 : bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            //rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c = rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c == null ? 0 : (rsdHeader.ASI_KOR_No_of_Sumitted_Branches__c - 1);
            //rsdHeader.ASI_KOR_CA_Amount_Pending__c = rsdHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0  : (rsdHeader.ASI_KOR_CA_Amount_Pending__c - branchTotalCAAmount);
            
            update bmProposalHeader;
            //update rsdHeader;
			/* [VL 1.0] BEGIN */
			update rsdHeader;
			/* [VL 1.0] END */
            //rollDown(bmProposalHeader.id);
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_BMApproval?id=' + bmProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    
    
    public static void rollUp(Id headerId, Boolean flag){
        
        List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                       ASI_KOR_BM_Proposal_By_Brand__c where ASI_KOR_BM_Proposal_Header__c = :headerId];
        
        for(ASI_KOR_BM_Proposal_By_Brand__c s : bmProposalByBrandList ){
            s.ASI_KOR_Roll_up__c = flag;
        }
        
        try{
            update bmProposalByBrandList ;    
        }catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
	/* [VL 2.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Sales_Planning_Report_UC' limit 1];
		return report.id;
	}
	public string getYear(){
		return bmProposalHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return bmProposalHeader.ASI_KOR_Month__c;
	}
	/* [VL 2.0] BEGIN */
    
    /* [VL 3.0] BEGIN */
	private decimal getSubmittedSR(){
		list<ASI_KOR_SR_Proposal_Header__c> header = [select id,ASI_KOR_Status__c from ASI_KOR_SR_Proposal_Header__c where ASI_KOR_BM_Proposal_Header__c =:bmProposalHeader.id and ASI_KOR_Status__c = 'Submitted'];
		return header.size();
	}
    /* [VL 3.0] END */
        
}