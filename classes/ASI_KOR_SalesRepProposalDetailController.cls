/**********************************************************************************
 * Name : ASI_KOR_SalesRepProposalDetailController 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??										Created
 * 2017-02-14       Laputa: Vincent         [VL 1.0] check channel when linking incentive scheme to proposal detail
 * 2017-03-01       Laputa: Vincent         [VL 2.0] indicate the proposal detail is not saved by upload
 * 2017-03-06		Laputa: Vincent			[VL 3.0] if uploaded detail has to be input the Business Rationale, check on before submit
 * 2017-05-04		Laputa: Vincent			[VL 4.0] P4.2 logic
 * 2017-08-09		Laputa: Vincent			[VL 5.0] P4.2 logic, handle prepayment
 * 2017-08-09		Laputa: Vincent			[VL 6.0] P4.2 logic, get report
 * 2017-08-09		Laputa: Vincent			[VL 7.0] P4.2 logic, show >1000 venue summary
 * 2017-08-14		Laputa: Vincent			[VL 8.0] P4.2 stop quick save refreshing venue summary
 * 2017-09-08		Laputa: Vincent			[VL 9.0] P4.2 add function to refreshing venue summary only
 **********************************************************************************/
global class ASI_KOR_SalesRepProposalDetailController{ 
    
    public Boolean renderSave {get;set;}
    public Boolean renderSubmit {get;set;} 
    public Boolean renderRecall {get;set;}
    
    public ASI_KOR_SR_Proposal_Header__c srProposalHeader{get;set;} 
    private Date srHeaderDate {get; set;}
    private Date srHeaderLastDate {get; set;}
    public String srMonth {get;set;}
    public String srYear {get;set;} 
    private Map<String,ASI_KOR_SR_Proposal_By_Brand__c > srProposalByBrandMap = new Map<String,ASI_KOR_SR_Proposal_By_Brand__c >();
    private Map<String,Id> bmProposalByBrandMap;
    private Map<String,Id> rsdProposalByBrandMap;
    private Map<String,Id> nsdProposalByBrandMap;
    private Id bmHeader;
    private Id rsdHeader;
    private Id nsdHeader;
    
    public Decimal srTotalLast3Months{get;set;}
    public Decimal srTotalIncentive{get;set;}
    public Decimal srTotalCAAmount{get;set;} 
	
	/* [VL 4.0] BEGIN */
    public Decimal GrandTotalByBrand_volume_2M {get;set;}
    public Decimal GrandTotalByBrand_volume_1M {get;set;}
    public Decimal GrandTotalByBrand_volume_TM {get;set;}
    public Decimal GrandTotalByBrand_vi_2M     {get;set;}
    public Decimal GrandTotalByBrand_vi_1M     {get;set;}
    public Decimal GrandTotalByBrand_vi_TM     {get;set;}
    public Decimal GrandTotalByBrand_venue_2M     {get;set;}
    public Decimal GrandTotalByBrand_venue_1M     {get;set;}
    public Decimal GrandTotalByBrand_venue_TM     {get;set;}
	public Decimal getGrandTotalByBrand_uc_2M() {
		return GrandTotalByBrand_vi_2M / (GrandTotalByBrand_volume_2M == 0 ? 1 : GrandTotalByBrand_volume_2M);
	}
	public Decimal getGrandTotalByBrand_uc_1M() {
		return GrandTotalByBrand_vi_1M / (GrandTotalByBrand_volume_1M == 0 ? 1 : GrandTotalByBrand_volume_1M);
	}
	public Decimal getGrandTotalByBrand_uc_TM() {
		return GrandTotalByBrand_vi_TM / (GrandTotalByBrand_volume_TM == 0 ? 1 : GrandTotalByBrand_volume_TM);
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
	public decimal getTotalVenueOwnedBySR(){
		return venueSummaryList.size();
	}
	/* [VL 4.0] END */
    
    public User srOwner;
    public String ownerBranch {get;set;}
    public List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails {get;set;}
    public String selectedVenues {get; set;}
    public List<SRProposalByBrandByCategory> srProposalByBrandByCategoryList { get; set;}
    private Map<Id,ASI_KOR_Brand__c> brandsMap;
    private Date cutOffDate;
    
	/* [VL 7.0] BEGIN */
	/*
    public List<Account> venues {get;set;}
    public List<VenueSummary> venueSummaryList {get;set;}
    public Map<Id,VenueSummary> venueSummaryMap {get;set;}
	*/
	
    public List<Account> venues = new List<Account>();
    public List<VenueSummary> venueSummaryList = new List<VenueSummary>();
    public Map<Id,VenueSummary> venueSummaryMap = new Map<Id,VenueSummary>();
    
    public List<List<VenueSummary>> getVenueSummaryList_split(){
		List<List<VenueSummary>> VenueSummaryList_split = new List<List<VenueSummary>>();
		integer count = 0;
		List<VenueSummary> tempList = new List<VenueSummary>();
		for (VenueSummary vs : venueSummaryList){
			if (count>=500){
				VenueSummaryList_split.add(tempList);
				tempList = new List<VenueSummary>();
				count = 0;
			}
			tempList.add(vs);
			count++;
		}
		if (tempList.size()>0) VenueSummaryList_split.add(tempList);
		return VenueSummaryList_split;
	}
    
    public List<List<Account>> getVenues_split(){
		List<List<Account>> Venues_split = new List<List<Account>>();
		integer count = 0;
		List<Account> tempList = new List<Account>();
		for (Account v : venues){
			if (count>=500){
				Venues_split.add(tempList);
				tempList = new List<Account>();
				count = 0;
			}
			tempList.add(v);
			count++;
		}
		if (tempList.size()>0) Venues_split.add(tempList);
		return Venues_split;
	}
	/* [VL 7.0] END */
    
    /**
Controller constructor,
Upon loading of the page ff fields are initialized.
srProposalHeader
srOwner: neccesary fields,
ownerBranch : branch code
srMonth
srYear
srHeaderDate
srHeaderLastDate
bmHeader
brandsMap
Then it calls the init() method to further initialize.
*/
    public ASI_KOR_SalesRepProposalDetailController(ApexPages.StandardController standardController){   
        selectedVenues = '';
        proposalDetails = new List<ASI_KOR_SR_Proposal_Detail__c>(); 
        Id headerId = ((ASI_KOR_SR_Proposal_Header__c )standardController.getRecord()).id;
        //this.srProposalHeader= (ASI_KOR_SR_Proposal_Header__c )standardController.getRecord();
        this.srProposalHeader = [select id
                                 , Name
                                 , ownerId 
                                 , ASI_KOR_Month__c
                                 , ASI_KOR_Year__c
                                 , ASI_KOR_Status__c
                                 , ASI_KOR_BM_Proposal_Header__c 
                                 , ASI_KOR_Branch__c
                                 from ASI_KOR_SR_Proposal_Header__c where id =: headerId];
        srOwner = [select  id,Name, ASI_KOR_User_Branch_Name__c,ASI_KOR_User_Branch_Code__c from User where id =: srProposalHeader.ownerId];
        ownerBranch = srOwner.ASI_KOR_User_Branch_Code__c;
        srMonth = srProposalHeader.ASI_KOR_Month__c;
        srYear = srProposalHeader.ASI_KOR_Year__c;
        srHeaderDate = Date.newInstance(Integer.valueOf(srProposalHeader.ASI_KOR_Year__c), Integer.valueOf(srProposalHeader.ASI_KOR_Month__c), 1);
        srHeaderLastDate = srHEaderDate.addMonths(1).addDays(-1);
        
        bmHeader  = srProposalHeader.ASI_KOR_BM_Proposal_Header__c;
        handleButtons(srProposalHeader.ASI_KOR_Status__c);    
        
        Id rsdH = ([select ASI_KOR_RSD_Proposal_Header__c from ASI_KOR_BM_Proposal_Header__c where id =: bmHeader]).ASI_KOR_RSD_Proposal_Header__c;
        Id nsdH =  ([select ASI_KOR_NSD_Proposal_Header__c from ASI_KOR_RSD_Proposal_Header__c where id =:rsdH]).ASI_KOR_NSD_Proposal_Header__c;
        
        //cutOffDate=Date.newInstance(integer.valueOf(srYear), 
        //integer.valueOf(srMonth), 
        //integer.valueOf('15'));
        ASI_KOR_NSD_Proposal_Header__c nsdHeader = [select ASI_KOR_SYS_Cut_off_Date__c from ASI_KOR_NSD_Proposal_Header__c where id=:nsdH];
        
        cutOffDate = nsdHeader.ASI_KOR_SYS_Cut_off_Date__c;
        
        System.debug('test laaaaauuu ' + cutoffdate);
        brandsMap = new Map<Id,ASI_KOR_Brand__c>([
			select id, name, ASI_KOR_Product_Categoray__r.name 
			/* [VL 4.0] BEGIN */
			, ASI_KOR_UOM__c, ASI_KOR_Sequence__c
			/* [VL 4.0] END */
			from ASI_KOR_Brand__c
		]);
        init();
    }
    
    
    
    private void handleButtons(String status){
        
        if('Draft'.equals(status)  || 'Rejected'.equals(status)){
            renderSave = true; 
            renderSubmit = true; 
            renderRecall = false;
        } else if('Submitted'.equals(status)){ 
            renderSave = false; 
            renderSubmit = false; 
            renderRecall = true;
        } else if('Approved by BM'.equals(status)){ 
            renderSave = false; 
            renderSubmit = false; 
            renderRecall = false;
        }
        
    }
    
    public void doNothing(){
        
    }
    public PageReference handleSave(){    
        handleQuickSave();
        PageReference pageRef   = new PageReference('/'+srProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /* [VL 4.0] BEGIN */
    public string checkUnitCostThreshold(){
        ASI_CRM_KR_Unit_Cost_Threshold__c unitCostThresholdObj = ASI_CRM_KR_Unit_Cost_Threshold__c.getInstance(srYear+'-'+srMonth);
		Decimal threshold = unitCostThresholdObj.ASI_CRM_KR_Threshold__c;
		string msg = '';
        for (ASI_KOR_SR_Proposal_Detail__c sr : proposalDetails){
            if (sr.ASI_KOR_Target_Volume__c != null && 
			   sr.ASI_KOR_Target_Volume__c != 0 &&
			   sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c != null &&
			   sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c != 0 &&
			   sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c >= threshold){
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Unit Cost가 너무 높게 입력되었습니다. 수정 바랍니다.<br/>';
            }
        }
        return msg;
    }
    /* [VL 4.0] END */
    
    public PageReference handleQuickSave(){
        System.debug('Test enter save : ' + proposalDetails);
        List<ASI_KOR_SR_Proposal_Detail__c>   details = new LIst<ASI_KOR_SR_Proposal_Detail__c>();
        List<ASI_KOR_SR_Proposal_Detail__c>  deleteDetails = new LIst<ASI_KOR_SR_Proposal_Detail__c>();
		
		/* [VL 4.0] BEGIN */
        string uploadMessage = checkUnitCostThreshold();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
		/* [VL 4.0] END */
        
        if(proposalDetails != null){ 
            for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
				/* [VL 5.0] BEGIN */
				if (detail.ASI_KOR_Is_Pre_payment__c){
					detail.ASI_KOR_Target_Volume__c = detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
					detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c == null ? 0 : detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;              
				   if(detail.ASI_KOR_SR_Proposal_By_Brand__c == null){
					   detail.ASI_KOR_SR_Proposal_By_Brand__c = generateSRProposalByBrand(detail.ASI_KOR_Brand__c,detail.ASI_KOR_Incentive_Scheme__r.ASI_KOR_UOM__c);
				   }
                    detail.ASI_KOR_Saved__c = true;
					details.add(detail);
				} else
				/* [VL 5.0] End */
                if(
					detail.ASI_KOR_Target_Volume__c != null && 
                   detail.ASI_KOR_Target_Volume__c != 0 &&
                   detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c != null &&
                   detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c != 0){                
                       if(detail.ASI_KOR_SR_Proposal_By_Brand__c == null){
                           detail.ASI_KOR_SR_Proposal_By_Brand__c = generateSRProposalByBrand(detail.ASI_KOR_Brand__c,detail.ASI_KOR_Incentive_Scheme__r.ASI_KOR_UOM__c);
                       }
                       /* [VL 2.0] BEGIN */
                       detail.ASI_KOR_Saved__c = true;
                       /* [VL 2.0] END */
                       details.add(detail);
                   }else if((detail.ASI_KOR_Target_Volume__c == null || 
                             detail.ASI_KOR_Target_Volume__c == 0) &&(
                                 detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c == null ||
                                 detail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c == 0)
                            && detail.id != null){ 
                                deleteDetails.add(detail);
                                
                            }
            }
            try{
                System.debug('Test size :' + details.size());
                if(details.size() > 0)
                    upsert details;
                if(deleteDetails.size() > 0)
                    delete deleteDetails;
            }catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                System.debug('Test error : ' + exc.getMessage());
            }
        }
        updateVenueSummary();
		
        /* [VL 8.0] BEGIN */
		/*
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_SalesRepProposal?id='+srProposalHeader.id);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('vid',selectedVenues);
        return pageRef;
		*/
		return null;
        /* [VL 8.0] END */
    }
    
    
    /**
init method, to initialize the venue summary table,
populate the sales rep details table,
and initialize the summary table.
*/
    public void init(){
        populateVenueSummary();
        if(venues.size()> 0 && venues.get(0)!=null){
            String vid= ApexPages.currentPage().getParameters().get('vid');
            if(vid != null && vid != ''){
                populateDetails(vid);
            }else{
                populateDetails(venueSummaryList.get(0).venue.id);
            }
            selectedVenues = venueSummaryList.get(0).venue.id;
        }
        handleSummary();
    }
    
/**
filterVenues method handles the filtering of diplayed venues in the venue table
on the vf page.
*/
    public void filterVenues(){
        venueSummaryList.clear();
        List<String> venueIds = selectedVenues.split('\\|');
        for(Id venue : venueIds){
            venueSummaryList.add(venueSummaryMap.get(venue));
        }
		/* [VL 4.0] BEGIN */
		venueSummaryList.sort();
		/* [VL 4.0] END */
        // rollDown(venueIds);
        // rollUp(venueIds);
    } 
    
    /**
selectVenue method
this is called when a user clicks a particular venue.
it calls the populateDetails method that populates the SR Proposal
detail table. it passes the venue id as an argument.
*/
    public void selectVenue(){
        if(!''.equals(selectedVenues)){
            populateDetails(selectedVenues);
        }
        else{
            proposalDetails.clear();}
    }
    
    /**
handleSummary method
is called to contruct the summary table of sr proposal by brands object,
which is group by category.

*/
    public void handleSummary(){
        srTotalIncentive = 0;
        srTotalCAAmount  = 0;
		/* [VL 4.0] BEGIN */
		GrandTotalByBrand_volume_2M = 0;
		GrandTotalByBrand_volume_1M = 0;
		GrandTotalByBrand_volume_TM = 0;
		GrandTotalByBrand_vi_2M     = 0;
		GrandTotalByBrand_vi_1M     = 0;
		GrandTotalByBrand_vi_TM     = 0;
		GrandTotalByBrand_venue_2M     = 0;
		GrandTotalByBrand_venue_1M     = 0;
		GrandTotalByBrand_venue_TM     = 0;
		/* [VL 4.0] END */
        List< ASI_KOR_SR_Proposal_By_Brand__c> summaryList = [select
                                                              id, name,
                                                              ASI_KOR_BM_Proposal_By_Brand__c,
                                                              ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                              ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                              ASI_KOR_Target_Volume__c,
                                                              ASI_KOR_Growth__c ,
                                                              ASI_KOR_Brand__r.name,
                                                              ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
                                                              ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                              ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                              ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                              ASI_KOR_UOM__c
															  /* [VL 4.0] BEGIN */
															  , ASI_KOR_Actual_Volume_1M_Ago_All_Venue__c
															  , ASI_KOR_Actual_Volume_2M_Ago_All_Venue__c
															  , ASI_KOR_Total_VI_1M_Ago_All_Venue__c
															  , ASI_KOR_Total_VI_2M_Ago_All_Venue__c
															  , ASI_KOR_No_of_Records_Planned__c
															  , ASI_KOR_No_of_Venues_1_Month_Ago__c
															  , ASI_KOR_No_of_Venues_2_Months_Ago__c
															  /* [VL 4.0] END */
                                                              from ASI_KOR_SR_Proposal_By_Brand__c
                                                              where
                                                              ASI_KOR_SR_Proposal_Header__c = : srProposalHeader.id
															  /* [VL 4.0] BEGIN */
															  AND (
																  ASI_KOR_Total_Incentive_Amount_Proposal__c != 0
																  OR ASI_KOR_Target_Volume__c != 0
																  OR ASI_KOR_Actual_Volume_1M_Ago_All_Venue__c != null
																  OR ASI_KOR_Actual_Volume_2M_Ago_All_Venue__c != null
																  OR ASI_KOR_Total_VI_1M_Ago_All_Venue__c != null
																  OR ASI_KOR_Total_VI_2M_Ago_All_Venue__c != null
																  OR ASI_KOR_No_of_Records_Planned__c != 0
																  OR ASI_KOR_No_of_Venues_1_Month_Ago__c != null
																  OR ASI_KOR_No_of_Venues_2_Months_Ago__c != null
															  )
															  /* [VL 4.0] END */ ];
        
        system.debug('ZZZ summary size:' +summaryList.size());
        
        Map<String, List< ASI_KOR_SR_Proposal_By_Brand__c>> summaryMap = new Map<String, List< ASI_KOR_SR_Proposal_By_Brand__c>>();
        
        for(ASI_KOR_SR_Proposal_By_Brand__c summary : summaryList ){
            srProposalByBrandMap.put((summary.ASI_KOR_Brand__c+summary.ASI_KOR_UOM__c),summary);
            if(summaryMap.get(summary.ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name) == null){
                List< ASI_KOR_SR_Proposal_By_Brand__c> l = new List< ASI_KOR_SR_Proposal_By_Brand__c>();
                l.add(summary);
                summaryMap.put(summary.ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,l);
            }else{
                summaryMap.get(summary.ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name).add(summary);
                
            }
        }
        srProposalByBrandByCategoryList = new List<SRProposalByBrandByCategory>();
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor’s brands'};
            
            //CA Change request: retrieve the Budget
            List<ASI_KOR_Budget__c> budgetList = new List<ASI_KOR_Budget__c>();
        Map<ID, ASI_KOR_Budget__c> budgetMap = new Map<ID, ASI_KOR_Budget__c>();
        Set<ID> brandIDs = new Set<ID>();
        
		/* [VL 4.0] BEGIN */
		/*
        for(String category:  categories){
		*/
        for(String category:  summaryMap.keySet()){
		/* [VL 4.0] END */
            if(summaryMap.get(category) == null)
                continue;
            
            for(ASI_KOR_SR_Proposal_By_Brand__c b : summaryMap.get(category)){
                if(b.ASI_KOR_Brand__c != null) {
                    brandIDs.add(b.ASI_KOR_Brand__c);
                }
            }
        }
        
        if(brandIDs.size() > 0) {
            budgetList = [SELECT ID, Name, ASI_KOR_Brand__c, ASI_KOR_Unit_Cost_Cap__c, ASI_KOR_Month__c, ASI_KOR_Year__c,  ASI_KOR_Branch_Name__c
                          FROM ASI_KOR_Budget__c
                          WHERE ASI_KOR_Brand__c IN : brandIDs 
                          AND ASI_KOR_Month__c = : srProposalHeader.ASI_KOR_Month__c 
                          AND ASI_KOR_Year__c = : srProposalHeader.ASI_KOR_Year__c 
                          AND ASI_KOR_Branch_Name__c = : srProposalHeader.ASI_KOR_Branch__c ];
            
            if(budgetList.size() > 0) {
                for(ASI_KOR_Budget__c budget : budgetList) {
                    budgetMap.put(budget.ASI_KOR_Brand__c, budget);
                }
            }
        }
        
		/* [VL 4.0] BEGIN */
		/*
        for(String category:  categories){
		*/
        for(String category:  summaryMap.keySet()){
		/* [VL 4.0] END */
            if(summaryMap.get(category) == null)
                continue;
            
            SRProposalByBrandByCategory sbc = new SRProposalByBrandByCategory();
            List<SRProposalByBrandByUnitCost> SRProposalByBrandByUnitCostList = new List<SRProposalByBrandByUnitCost>();
            
            List<ASI_KOR_SR_Proposal_By_Brand__c> proposalByBrandrecList = summaryMap.get(category);
            
            for(ASI_KOR_SR_Proposal_By_Brand__c propBrand : proposalByBrandrecList) {
                SRProposalByBrandByUnitCost proposalByBrand = new SRProposalByBrandByUnitCost();
                proposalByBrand.srProposalByBrandsItem = propBrand;
                
                if(budgetMap.containsKey(propBrand.ASI_KOR_Brand__c)) {
                    proposalByBrand.unitCostCap = budgetMap.get(propBrand.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
                } else {
                    proposalByBrand.unitCostCap = null;
                }
                
                SRProposalByBrandByUnitCostList.add(proposalByBrand);
            }
            
            //sbc.srProposalByBrands = summaryMap.get(category);
            sbc.srProposalByBrands = SRProposalByBrandByUnitCostList;
            
            sbc.category = category;
            sbc.totalCAAmount =0;
            sbc.totalIncentiveAmount = 0;
            sbc.last3months = 0;
            for(ASI_KOR_SR_Proposal_By_Brand__c b : summaryMap.get(category)){
                sbc.totalCAAmount += b.ASI_KOR_Total_CA_Amount_excl_Basic__c==null?0:b.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                sbc.totalIncentiveAmount += b.ASI_KOR_Total_Incentive_Amount_Proposal__c==null?0:b.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                sbc.last3months += b.ASI_KOR_Last_3_month_Actual_Average_Volu__c==null?0:b.ASI_KOR_Last_3_month_Actual_Average_Volu__c;
				/* [VL 4.0] BEGIN */
				sbc.ASI_KOR_Total_Incentive_Amount_Proposal += b.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : b.ASI_KOR_Total_Incentive_Amount_Proposal__c;
				sbc.ASI_KOR_Target_Volume += b.ASI_KOR_Target_Volume__c == null ? 0 : b.ASI_KOR_Target_Volume__c;
				sbc.ASI_KOR_Total_VI_1M_Ago_All_Venue += b.ASI_KOR_Total_VI_1M_Ago_All_Venue__c == null ? 0 : b.ASI_KOR_Total_VI_1M_Ago_All_Venue__c;
				sbc.ASI_KOR_Actual_Volume_1M_Ago_All_Venue += b.ASI_KOR_Actual_Volume_1M_Ago_All_Venue__c == null ? 0 : b.ASI_KOR_Actual_Volume_1M_Ago_All_Venue__c;
				sbc.ASI_KOR_Total_VI_2M_Ago_All_Venue += b.ASI_KOR_Total_VI_2M_Ago_All_Venue__c == null ? 0 : b.ASI_KOR_Total_VI_2M_Ago_All_Venue__c;
				sbc.ASI_KOR_Actual_Volume_2M_Ago_All_Venue += b.ASI_KOR_Actual_Volume_2M_Ago_All_Venue__c == null ? 0 : b.ASI_KOR_Actual_Volume_2M_Ago_All_Venue__c;
				sbc.ASI_KOR_No_of_Records_Planned += b.ASI_KOR_No_of_Records_Planned__c == null ? 0 : b.ASI_KOR_No_of_Records_Planned__c;
				sbc.ASI_KOR_No_of_Venues_1_Month_Ago += b.ASI_KOR_No_of_Venues_1_Month_Ago__c == null ? 0 : b.ASI_KOR_No_of_Venues_1_Month_Ago__c;
				sbc.ASI_KOR_No_of_Venues_2_Months_Ago += b.ASI_KOR_No_of_Venues_2_Months_Ago__c == null ? 0 : b.ASI_KOR_No_of_Venues_2_Months_Ago__c;
				/* [VL 4.0] END */
            }
            srTotalIncentive += sbc.totalIncentiveAmount ;
            srTotalCAAmount +=sbc.totalCAAmount;
			/* [VL 4.0] BEGIN */
			GrandTotalByBrand_volume_2M += sbc.ASI_KOR_Actual_Volume_2M_Ago_All_Venue;
			GrandTotalByBrand_volume_1M += sbc.ASI_KOR_Actual_Volume_1M_Ago_All_Venue;
			GrandTotalByBrand_volume_TM += sbc.ASI_KOR_Target_Volume;
			GrandTotalByBrand_vi_2M     += sbc.ASI_KOR_Total_VI_2M_Ago_All_Venue;
			GrandTotalByBrand_vi_1M     += sbc.ASI_KOR_Total_VI_1M_Ago_All_Venue;
			GrandTotalByBrand_vi_TM     += sbc.ASI_KOR_Total_Incentive_Amount_Proposal;
			GrandTotalByBrand_venue_2M     += sbc.ASI_KOR_No_of_Venues_2_Months_Ago;
			GrandTotalByBrand_venue_1M     += sbc.ASI_KOR_No_of_Venues_1_Month_Ago;
			GrandTotalByBrand_venue_TM     += sbc.ASI_KOR_No_of_Records_Planned;
			/* [VL 4.0] END */
            if(summaryMap.get(category).size()>0){
                srProposalByBrandByCategoryList.add(sbc);
            }
            
        }
    }
    
    public Id generateSRProposalByBrand(Id brandId,String uom){
        
        if(srProposalByBrandMap.get(brandId+uom) == null){
            ASI_KOR_SR_Proposal_By_Brand__c srProposalByBrand = new ASI_KOR_SR_Proposal_By_Brand__c();
            srProposalByBrand.ASI_KOR_BM_Proposal_By_Brand__c = generateBMProposalByBrand(brandId,uom);
            srProposalByBrand.ASI_KOR_Brand__c = brandId;
            srProposalByBrand.ASI_KOR_SR_Proposal_Header__c = srProposalHeader.id;
            srProposalByBrand.ASI_KOR_UOM__c = uom;
            try{
                insert srProposalByBrand;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            } 
            srProposalByBrandMap.put(srProposalByBrand.ASI_KOR_Brand__c+uom,srProposalByBrand);
        }
        return srProposalByBrandMap.get(brandId+uom).id;
    }
    
    public Id  generateBMProposalByBrand(Id brandId, String uom){
        if(bmProposalByBrandMap == null){
            bmProposalByBrandMap = new Map<String,Id>();
            List<ASI_KOR_BM_Proposal_By_Brand__c> bmbrands = [select ASI_KOR_Brand__c, ASI_KOR_UOM__c,id from ASI_KOR_BM_Proposal_By_Brand__c
                                                              where ASI_KOR_BM_Proposal_Header__c =: bmHeader];
            for(ASI_KOR_BM_Proposal_By_Brand__c x: bmbrands){
                bmProposalByBrandMap.put(x.ASI_KOR_Brand__c+x.ASI_KOR_UOM__c,x.id);
            }
        }
        Id bmProposalByBrandId = bmProposalByBrandMap.get(brandId+uom);
        if(bmProposalByBrandId == null){
            ASI_KOR_BM_Proposal_By_Brand__c bmProposalByBrand = new ASI_KOR_BM_Proposal_By_Brand__c();
            bmProposalByBrand.ASI_KOR_RSD_Proposal_By_Brand__c = generateRSDProposalByBrand(brandId);
            bmProposalByBrand.ASI_KOR_BM_Proposal_Header__c = bmHeader;
            bmProposalByBrand.ASI_KOR_Brand__c = brandId;
            bmProposalByBrand.ASI_KOR_UOM__c = uom;
            // bmProposalByBrand.ASI_KOR_CA_Budget__c = brandBudget.get(brandId);
            try{
                insert bmProposalByBrand;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            } 
            bmProposalByBrandId = bmProposalByBrand.id;
            bmProposalByBrandMap.put(brandId+uom,bmProposalByBrandId);
            
        }
        return bmProposalByBrandId;
    }
    public Id  generateRSDProposalByBrand(Id brandId){
        if(rsdHeader == null){
            ASI_KOR_BM_Proposal_Header__c bmProposalHeader  = [select ASI_KOR_RSD_Proposal_Header__c from ASI_KOR_BM_Proposal_Header__c where id =:bmHeader limit 1 ];
            rsdHeader = bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c;    
        }
        
        if(rsdProposalByBrandMap == null){
            rsdProposalByBrandMap = new Map<String,Id>();
            List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdBrands = [select ASI_KOR_Brand__c, id from ASI_KOR_RSD_Proposal_By_Brand__c
                                                                where ASI_KOR_RSD_Proposal_Header__c =:rsdHeader];
            for(ASI_KOR_RSD_Proposal_By_Brand__c x: rsdBrands){
                rsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
            }
        }
        Id rsdProposalByBrandId = rsdProposalByBrandMap.get(brandId);
        if(rsdProposalByBrandId == null){
            ASI_KOR_RSD_Proposal_By_Brand__c rsdProposalByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c();
            rsdProposalByBrand.ASI_KOR_NSD_Proposal_By_Brand__c = generateNSDProposalByBrand(brandId);
            rsdProposalByBrand.ASI_KOR_RSD_Proposal_Header__c = rsdHeader;
            rsdProposalByBrand.ASI_KOR_Brand__c = brandId;
            //rsdProposalByBrand.ASI_KOR_UOM__c = uom;
            try{
                insert rsdProposalByBrand;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            } 
            rsdProposalByBrandId = rsdProposalByBrand.id;
            rsdProposalByBrandMap.put(brandId,rsdProposalByBrandId );
        }
        return rsdProposalByBrandId ;
    }
    public Id  generateNSDProposalByBrand(Id brandId){
        if(nsdHeader == null){
            ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader = [select ASI_KOR_NSD_Proposal_Header__c from ASI_KOR_RSD_Proposal_Header__c where id =:rsdHeader limit 1 ];
            nsdHeader = rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c;
        }
        
        if(nsdProposalByBrandMap == null){
            nsdProposalByBrandMap = new Map<String,Id>();
            List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdBrands = [select ASI_KOR_Brand__c, id from ASI_KOR_NSD_Proposal_By_Brand__c
                                                                where ASI_KOR_NSD_Proposal_Header__c =:nsdHeader];
            
            for(ASI_KOR_NSD_Proposal_By_Brand__c x: nsdBrands ){
                nsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
            }
        }
        Id nsdProposalByBrandId = nsdProposalByBrandMap.get(brandId);
        if(nsdProposalByBrandId == null){
            ASI_KOR_NSD_Proposal_By_Brand__c nsdProposalByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c ();
            nsdProposalByBrand.ASI_KOR_NSD_Proposal_Header__c = nsdHeader;
            nsdProposalByBrand.ASI_KOR_Brand__c = brandId;
            //nsdProposalByBrand.ASI_KOR_UOM__c = uom;
            try{
                insert nsdProposalByBrand;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            } 
            nsdProposalByBrandId = nsdProposalByBrand.id;
            nsdProposalByBrandMap.put(brandId,nsdProposalByBrandId);
            
        }
        return nsdProposalByBrandId ;
    }
    
    /* [VL 3.0] BEGIN */
    public string checkUploadMessage(){
        string msg = '';
		/* [VL 4.0] BEGIN */
		/*
        for (ASI_KOR_SR_Proposal_Detail__c sr : [
            select id, ASI_KOR_Brand__r.name, ASI_KOR_Venue__r.name, 
            ASI_KOR_Individual_Venue_Status__c, ASI_KOR_Business_Rationale__c
            from ASI_KOR_SR_Proposal_Detail__c
            where ASI_KOR_SR_Proposal_ID__c = :srProposalHeader.id and
            ((ASI_KOR_Individual_Venue_Status__c = 'Exceed Budget' and ASI_KOR_Business_Rationale__c = null) or 
             ASI_KOR_Individual_Venue_Status__c = 'Too Small')            
        ]){
            if (sr.ASI_KOR_Individual_Venue_Status__c == 'Exceed Budget' && sr.ASI_KOR_Business_Rationale__c == null){
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Business Rationale Required<br/>';
            } else
            if (sr.ASI_KOR_Individual_Venue_Status__c == 'Too Small'){
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Proposal Unit Cost is too low<br/>';
            } 
        }
		*/
        for (ASI_KOR_SR_Proposal_Detail__c sr : [
            select id, ASI_KOR_Brand__r.name, ASI_KOR_Venue__r.name, 
            ASI_KOR_Individual_Venue_Status__c, ASI_KOR_Business_Rationale__c, ASI_KOR_Is_Pre_payment__c
            from ASI_KOR_SR_Proposal_Detail__c
            where ASI_KOR_SR_Proposal_ID__c = :srProposalHeader.id and
            ((ASI_KOR_Individual_Venue_Status__c = 'Exceed Budget' and ASI_KOR_Business_Rationale__c = null) or 
             ASI_KOR_Individual_Venue_Status__c = 'Too Small')            
        ]){
            if (sr.ASI_KOR_Individual_Venue_Status__c == 'Exceed Budget' && !sr.ASI_KOR_Is_Pre_payment__c && sr.ASI_KOR_Business_Rationale__c == null){
                msg += 'For Venue: <b>'+sr.ASI_KOR_Venue__r.name+'</b>, Brand: <b>'+sr.ASI_KOR_Brand__r.name+'</b>, Business Rationale을 입력해주세요.<br/>';
            } 
        }
		/* [VL 4.0] END */
        return msg;
    }
    /* [VL 3.0] END */
    
    public PageReference handleSubmit(){
        
        handleQuickSave();
        /* [VL 3.0] BEGIN */
        string uploadMessage = checkUploadMessage();
        system.debug('uploadMessage: '+uploadMessage);
        if(uploadMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uploadMessage));
            return null;
        }
        srProposalHeader.ASI_KOR_Status__c = 'Submitted';
        /* [VL 3.0] END */
        handleButtons('Submitted');
        submitted(srProposalHeader.id,true);
        /* [VL 3.0] BEGIN */
        /*
        handleQuickSave();
        */
        /* [VL 3.0] END */
        handleSummary();
        /*
ASI_KOR_BM_Proposal_Header__c bmHeader = [select id, ASI_KOR_NoofSubmittedSalesRepresentative__c,ASI_KOR_CA_Amount_Pending__c from ASI_KOR_BM_Proposal_Header__c
where id =:
srProposalHeader.ASI_KOR_BM_Proposal_Header__c ];
bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c = bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c == null ? 1 : (bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c + 1); 
bmHeader.ASI_KOR_CA_Amount_Pending__c = bmHeader.ASI_KOR_CA_Amount_Pending__c == null ? srTotalCAAmount : (bmHeader.ASI_KOR_CA_Amount_Pending__c + srTotalCAAmount);
*/
        
		/* [VL 1.0] BEGIN */
		ASI_KOR_BM_Proposal_Header__c bmHeader = [
			select id, ASI_KOR_Total_VI_Pending__c 
			from ASI_KOR_BM_Proposal_Header__c
			where id =:srProposalHeader.ASI_KOR_BM_Proposal_Header__c 
			limit 1
		];
		decimal bmTotalPendingVI = bmHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : bmHeader.ASI_KOR_Total_VI_Pending__c;
		bmHeader.ASI_KOR_Total_VI_Pending__c = bmTotalPendingVI + srTotalIncentive;
		/* [VL 1.0] END */
		
        system.debug('pending sr ca amount!! ' + srTotalCAAmount);
        try{
            //update bmHeader;
			/* [VL 1.0] BEGIN */
			update bmHeader;
			/* [VL 1.0] END */
            update srProposalHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_SalesRepProposal?id=' + srProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public PageReference handleRecall(){
        
        srProposalHeader.ASI_KOR_Status__c = 'Draft';
        handleButtons('Draft');
        submitted(srProposalHeader.id,false);
        /*
ASI_KOR_BM_Proposal_Header__c bmHeader = [select id, ASI_KOR_NoofSubmittedSalesRepresentative__c,ASI_KOR_CA_Amount_Pending__c from ASI_KOR_BM_Proposal_Header__c
where id =:
srProposalHeader.ASI_KOR_BM_Proposal_Header__c ];
bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c = bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c == null ? 0 : (bmHeader.ASI_KOR_NoofSubmittedSalesRepresentative__c - 1); 
bmHeader.ASI_KOR_CA_Amount_Pending__c = bmHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : (bmHeader.ASI_KOR_CA_Amount_Pending__c - srTotalCAAmount);
*/
        
        try{
            update srProposalHeader;
            //update bmHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_SalesRepProposal?id=' + srProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public static void submitted(Id headerId, Boolean flag){
        List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrandList = [select id, ASI_KOR_Submitted__c from 
                                                                       ASI_KOR_SR_Proposal_By_Brand__c where ASI_KOR_SR_Proposal_Header__c = :headerId];
        for(ASI_KOR_SR_Proposal_By_Brand__c s : srProposalByBrandList){
            s.ASI_KOR_Submitted__c = flag;
        }
        
        try{
            update srProposalByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    
    public static void rollUp(Id headerId, Boolean flag){
        List<ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrandList = [select id, ASI_KOR_Roll_up__c from 
                                                                       ASI_KOR_SR_Proposal_By_Brand__c where ASI_KOR_SR_Proposal_Header__c = :headerId];
        for(ASI_KOR_SR_Proposal_By_Brand__c s : srProposalByBrandList){
            s.ASI_KOR_Roll_up__c = flag;
        }
        
        try{
            update srProposalByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    /**
Inner class to hold the SR Proposal By Brands Object by Category.
*/
    public class SRProposalByBrandByCategory{
        public String category {get; set; }
        public Decimal totalCAAmount {get; set; }
        public Decimal totalIncentiveAmount {get; set; }
        public Decimal last3months {get; set; }
		/* [VL 4.0] BEGIN */
        public Decimal ASI_KOR_Total_Incentive_Amount_Proposal {get; set; }
        public Decimal ASI_KOR_Target_Volume {get; set; }
        public Decimal ASI_KOR_Total_VI_1M_Ago_All_Venue {get; set; }
        public Decimal ASI_KOR_Actual_Volume_1M_Ago_All_Venue {get; set; }
        public Decimal ASI_KOR_Total_VI_2M_Ago_All_Venue {get; set; }
        public Decimal ASI_KOR_Actual_Volume_2M_Ago_All_Venue {get; set; }
		public Decimal ASI_KOR_No_of_Venues_2_Months_Ago {get; set; }
		public Decimal ASI_KOR_No_of_Venues_1_Month_Ago {get; set; }
		public Decimal ASI_KOR_No_of_Records_Planned {get; set; }
		public Decimal getUnitCost_thisMonth(){
			return this.ASI_KOR_Total_Incentive_Amount_Proposal/(this.ASI_KOR_Target_Volume == 0 ? 1 : this.ASI_KOR_Target_Volume);
		}
		public Decimal getUnitCost_1MonthAgo(){
			return this.ASI_KOR_Total_VI_1M_Ago_All_Venue/(this.ASI_KOR_Actual_Volume_1M_Ago_All_Venue == 0 ? 1 : this.ASI_KOR_Actual_Volume_1M_Ago_All_Venue);
		}
		public Decimal getUnitCost_2MonthAgo(){
			return this.ASI_KOR_Total_VI_2M_Ago_All_Venue/(this.ASI_KOR_Actual_Volume_2M_Ago_All_Venue == 0 ? 1 : this.ASI_KOR_Actual_Volume_2M_Ago_All_Venue);
		}
		/* [VL 4.0] END */
        public List<SRProposalByBrandByUnitCost> srProposalByBrands {get; set; }
		/* [VL 4.0] BEGIN */
		public SRProposalByBrandByCategory(){
			this.ASI_KOR_Total_Incentive_Amount_Proposal = 0;
			this.ASI_KOR_Target_Volume = 0;
			this.ASI_KOR_Total_VI_1M_Ago_All_Venue = 0;
			this.ASI_KOR_Actual_Volume_1M_Ago_All_Venue = 0;
			this.ASI_KOR_Total_VI_2M_Ago_All_Venue = 0;
			this.ASI_KOR_Actual_Volume_2M_Ago_All_Venue = 0;
			this.ASI_KOR_No_of_Venues_2_Months_Ago = 0;
			this.ASI_KOR_No_of_Venues_1_Month_Ago = 0;
			this.ASI_KOR_No_of_Records_Planned = 0;
		}
		/* [VL 4.0] END */
    }
    
    /**
Inner class to hold Proposal By Brand records with Unit Cos Cap
*/
    public class SRProposalByBrandByUnitCost{
        public Decimal unitCostCap {get; set; }
        public ASI_KOR_SR_Proposal_By_Brand__c srProposalByBrandsItem {get; set; }
        public String getUnitCostStatus(){
            //Decimal x = this.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            Decimal x = this.unitCostCap != null ? this.unitCostCap : 0;
            //Decimal z = this.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c;
            Decimal z = this.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            if(z>x)
                return 'Exceed Recommendation'; 
            else
                return 'Within Recommendation';
        }
    }
    
    @RemoteAction
    global static String getCA(String param){
		/*
        List<String> a = param.split('\\|');    
        String brand = a.get(0);
        String branch= a.get(1);
        Decimal targetVolume = Decimal.valueOf(a.get(2));
        String uom = a.get(3);
        String contractType = a.get(4);
        String srMonth = a.get(5);
        String srYear = a.get(6);
        String srCutOffDate = a.get(7);
        String srGrade = a.get(8);
        * [VL 1.0] BEGIN *
        String srChannel = a.get(9);
        * [VL 1.0] END *
        Date srStartDate = Date.newInstance(Integer.valueOf(srYear), Integer.valueOf(srMonth), Integer.valueOf(srCutOffDate));
        Date srLastDate = srStartDate.addMonths(1).addDays(-1);
        
        System.debug('XXXX Flag Param ' + param);
        
        List<ASI_KOR_Incentive_Scheme__c> icList = null;
        try{
            icList = [select ASI_KOR_UOM__c, ASI_KOR_Sales_Bracket__c,ASI_KOR_CA_Unit_Cost__c,ASI_KOR_Basic_Unit_Cost__c from ASI_KOR_Incentive_Scheme__c
                      where 
                      ASI_KOR_Brand__c =:brand
                      and
                      ASI_KOR_Branch_Code__c=:branch
                      and
                      ASI_KOR_UOM__c=:uom
                      // and
                      // ASI_KOR_Sales_Bracket__c <=:targetVolume
                      and
                      ASI_KOR_Effective_Start_Date__c <= :srStartDate
                      and
                      ASI_KOR_Effective_End_Date__c >=:srLastDate 
                      and
                      ASI_KOR_Contract__c =:contractType
                      and
                      ASI_KOR_Grade__c =:srGrade 
                      * [VL 1.0] BEGIN *
                      and
                      ASI_KOR_Channel__c =:srChannel 
                      * [VL 1.0] END *
                      order by ASI_KOR_Sales_Bracket__c ASC];
        }catch(DmlException exc){
            ApexPages.addMessages(exc);
        }
        
        Decimal ca = 0;
        Decimal cabasic = 0;
        
        
        
        if(icList !=null && icList.size() > 0){
            
            ASI_KOR_Incentive_Scheme__c ic = null;
            
            for(ASI_KOR_Incentive_Scheme__c temp : icList){
                if(temp.ASI_KOR_Sales_Bracket__c <= targetVolume ){
                    ic = temp;
                }else if(temp.ASI_KOR_Sales_Bracket__c > targetVolume ){
                    break;
                }
            }
            
            if(ic == null){
                ic = icList.get(0);
                return ca+'|'+cabasic + '|' + ic.id +  '|' + uom + '|'+ srYear + '|'+ srMonth + '|' + srCutOffDate +srStartDate.format()+srLastDate;
                
            }
            ca = ic.ASI_KOR_CA_Unit_Cost__c;
            cabasic = ic.ASI_KOR_Basic_Unit_Cost__c;
            
            return ca+'|'+cabasic + '|' + ic.id + '|' + ic.ASI_KOR_UOM__c + '|'+ srYear + '|'+ srMonth + '|' + srCutOffDate +srStartDate.format()+srLastDate;
            
        }else{
            
            return ca+'|'+cabasic + '|' + '|' + uom + '|'+ srYear + '|'+ srMonth + '|' + srCutOffDate +srStartDate.format()+srLastDate;
            
        }
		*/  
        List<String> a = param.split('\\|');    
		system.debug(a);
        String brand = a.get(0);
        String srChannel = a.get(1);
        Decimal targetVolume = Decimal.valueOf(a.get(2));
        String srMonth = a.get(3);
        String srYear = a.get(4);
        Date srStartDate = Date.newInstance(Integer.valueOf(srYear), Integer.valueOf(srMonth), 1);
        Date srLastDate = srStartDate.addMonths(1).addDays(-1);
        
        List<ASI_KOR_Incentive_Scheme__c> icList = null;
        try{
            icList = [select ASI_KOR_UOM__c, ASI_KOR_Sales_Bracket__c,ASI_KOR_Basic_Unit_Cost__c from ASI_KOR_Incentive_Scheme__c
                      where 
                      ASI_KOR_Brand__c =:brand
                      and
                      ASI_KOR_Channel__c=:srChannel
                      and
                      ASI_KOR_Effective_Start_Date__c <= :srStartDate
                      and
                      ASI_KOR_Effective_End_Date__c >=:srLastDate 
                      order by ASI_KOR_Sales_Bracket__c ASC];
        }catch(DmlException exc){
            ApexPages.addMessages(exc);
        }
        
        Decimal cabasic = 0;
        
        
        
        if(icList !=null && icList.size() > 0){
            
            ASI_KOR_Incentive_Scheme__c ic = null;
            
            for(ASI_KOR_Incentive_Scheme__c temp : icList){
                if(temp.ASI_KOR_Sales_Bracket__c <= targetVolume ){
                    ic = temp;
                }else if(temp.ASI_KOR_Sales_Bracket__c > targetVolume ){
                    break;
                }
            }
            
            if(ic == null){
                ic = icList.get(0);
                return cabasic + '|' + ic.id;
                
            }
            cabasic = ic.ASI_KOR_Basic_Unit_Cost__c;
            
            return cabasic + '|' + ic.id;
            
        }else{
            
            return cabasic + '|';
            
        }
    }
    /**
Inner class to hold a summary of proposal details of each venue.
*/
    public class VenueSummary /* [VL 4.0] BEGIN */implements Comparable/* [VL 4.0] END */{
        public Id venueId {get; set;}
        public String venueCode {get; set;}
        public String venueName {get; set;}
        public Decimal totalIncentive {get; set;}
		/* [VL 4.0] BEGIN */
		/*
        public Decimal totalCAAmount {get; set;}
        public Decimal last3monthAveVol {get; set;}
		*/
		/* [VL 4.0] END */
        public Account venue {get;set;}    
        
		/* [VL 4.0] BEGIN */
        public Integer compareTo(Object compareTo) 
        {
            VenueSummary compareToWrap = (VenueSummary)compareTo;
			Integer returnValue = 0;
			if (venueName<compareToWrap.venueName) {
				returnValue = -1;
			} else
			if (venueName>compareToWrap.venueName) {
				returnValue = 1;
			} 
			return returnValue;      
        }
		/* [VL 4.0] END */
    }
    
    private void updateVenueSummary(){
        Id venueId = selectedVenues;
        List<ASI_KOR_SR_Proposal_Detail__c > tempD = [select ASI_KOR_Venue__c, ASI_KOR_Total_CA_Amount_excl_Basic__c, ASI_KOR_Total_Incentive_Amount_Proposal__c, ASI_KOR_Last_3_month_Actual_Average_Volu__c, ASI_KOR_Last_3_month_Actual_average_UC__c from ASI_KOR_SR_Proposal_Detail__c 
                                                      where ASI_KOR_SR_Proposal_ID__c =: srProposalHeader.id 
                                                      and ASI_KOR_Venue__c =:venueId order by ASI_KOR_Venue__c];
        VenueSummary vs = venueSummaryMap.get(venueId);
        vs.totalIncentive = 0;
		/*
        vs.totalCAAmount = 0;
        vs.last3monthAveVol = 0;
		*/
        for(ASI_KOR_SR_Proposal_Detail__c ts: tempD){
            vs.totalIncentive += ts.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : ts.ASI_KOR_Total_Incentive_Amount_Proposal__c;
			/* [VL 4.0] BEGIN */
			/*
            vs.totalCAAmount += ts.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : ts.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            vs.last3monthAveVol += ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c == null ? 0 : ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c;
			*/
			/* [VL 4.0] END */
        }
    }
    
    private void populateVenueSummary(){
        
        venueSummaryMap = new Map<Id,VenueSummary>();
        venueSummaryList = new List<VenueSummary>();
        Set<String> contractSet = new Set<String>();
        Set<String> gradeSet = new Set<String>();
        AggregateResult[] icList = [select ASI_KOR_Contract__c contract, ASI_KOR_Grade__c grade from ASI_KOR_Incentive_Scheme__c 
                                    where 
									/* [VL 4.0] BEGIN */
									/*
									ASI_KOR_Branch_Code__c =:ownerBranch
                                    and 
									*/
									/* [VL 4.0] END */
									ASI_KOR_Effective_Start_Date__c <= :srHeaderDate
                                    and ASI_KOR_Effective_End_Date__c >= :srHeaderLastDate 
                                    group by ASI_KOR_Contract__c, ASI_KOR_Grade__c];
        
        for(AggregateResult ic: icList){
            contractSet.add((String)ic.get('contract'));
            gradeSet.add((String)ic.get('grade'));
        }
        
        
        venues =  [select 
					id, Name, ASI_KOR_Customer_Code__c,ASI_KOR_Venue_Pillar__c
					/* [VL 4.0] BEGIN */
					/*
					,IsPersonAccount, ASI_KOR_Grade__c,ASI_KOR_Venue_Channel__c, ASI_KOR_Contract_Type__c 
					*/
					, ASI_KOR_Venue_Type__c
					/* [VL 4.0] END */
					from Account 
                   where 
                   ownerId =: srProposalHeader.ownerId 
                   and RecordTypeId in (select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account')
				   /* [VL 4.0] BEGIN */
				   /*
                   and ASI_KOR_Contract_Type__c in: contractSet
                   and ASI_KOR_Grade__c in: gradeSet
				   */
				   /* [VL 4.0] END */
                   and ASI_KOR_Venue_Status__c = 'Active'
                   order by Name];
        
        List<ASI_KOR_SR_Proposal_Detail__c > tempD = [select ASI_KOR_Venue__c, ASI_KOR_Total_CA_Amount_excl_Basic__c, ASI_KOR_Total_Incentive_Amount_Proposal__c, ASI_KOR_Last_3_month_Actual_Average_Volu__c, ASI_KOR_Last_3_month_Actual_average_UC__c from ASI_KOR_SR_Proposal_Detail__c 
                                                      where ASI_KOR_SR_Proposal_ID__c =: srProposalHeader.id order by ASI_KOR_Venue__c];
        
        Map<String,VenueSummary> tempSummaryMap = new Map<String,VenueSummary>();
        Id tempVenueId;
        for(ASI_KOR_SR_Proposal_Detail__c ts: tempD){
            if(tempVenueId!=ts.ASI_KOR_Venue__c){
                VenueSummary vs = new VenueSummary();
                vs.venueId = ts.ASI_KOR_Venue__c;
                vs.totalIncentive = ts.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 :ts.ASI_KOR_Total_Incentive_Amount_Proposal__c;
				/* [VL 4.0] BEGIN */
				/*
                vs.totalCAAmount = ts.ASI_KOR_Total_CA_Amount_excl_Basic__c == null? 0 : ts.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                vs.last3monthAveVol = ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c == null? 0 : ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c; 
				*/
				/* [VL 4.0] END */
                tempSummaryMap.put(vs.venueId,vs);
                tempVenueId=ts.ASI_KOR_Venue__c;
            }else{
                VenueSummary vs = tempSummaryMap.get(ts.ASI_KOR_Venue__c);
                vs.venueId = ts.ASI_KOR_Venue__c;
                vs.totalIncentive += ts.ASI_KOR_Total_Incentive_Amount_Proposal__c == null? 0: ts.ASI_KOR_Total_Incentive_Amount_Proposal__c;
				/* [VL 4.0] BEGIN */
				/*
                vs.totalCAAmount += ts.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 :ts.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                vs.last3monthAveVol +=  ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c == null ? 0 :ts.ASI_KOR_Last_3_month_Actual_Average_Volu__c;
				*/
				/* [VL 4.0] END */
                
                
            }
        }
        
        if(venues.size() > 0 ){
            for(Account venue: venues){
                if(tempSummaryMap.get(venue.id)==null){
                    VenueSummary vs = new VenueSummary();
                    vs.venueId = venue.id;
                    vs.totalIncentive = 0;
					/* [VL 4.0] BEGIN */
					/*
                    vs.totalCAAmount = 0;
                    vs.last3monthAveVol = 0; 
					*/
					/* [VL 4.0] END */
                    vs.venueCode = venue.ASI_KOR_Customer_Code__c;
                    vs.venueName = venue.name;
                    vs.venue = venue;
                    
                    venueSummaryMap.put(venue.id,vs);
                }else{
                    
                    tempSummaryMap.get(venue.id).venueCode = venue.ASI_KOR_Customer_Code__c;
                    tempSummaryMap.get(venue.id).venueName = venue.name;
                    tempSummaryMap.get(venue.id).venue = venue;
                    venueSummaryMap.put(venue.id,tempSummaryMap.get(venue.id));
                }
            }
        }
        
        for(Id i: venueSummaryMap.keySet()){
            venueSummaryList.add(venueSummaryMap.get(i));
        }
		/* [VL 4.0] BEGIN */
		venueSummaryList.sort();
		/* [VL 4.0] END */
    }
    
    private void populateDetails(Id venueId){
        
        proposalDetails.clear(); 
        Map<Id,Set<String>> brandUomCombo = new Map<Id,Set<String>>();
        List<ASI_KOR_SR_Proposal_Detail__c> temp= [
            select id,
            ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.name,
            ASI_KOR_SR_Proposal_By_Brand__c ,
            ASI_KOR_Brand__c, name,
            ASI_KOR_Cap_Total_Basic_CA__c,
            ASI_KOR_Brand__r.name,
            ASI_KOR_UOM__c,ASI_KOR_Growth__c,
            ASI_KOR_Venue__r.ASI_KOR_Venue_Channel__c,
            ASI_KOR_Venue__r.ASI_KOR_Venue_Pillar__c, 
            ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c,
            ASI_KOR_Venue__r.ASI_KOR_Grade__c,
            ASI_KOR_Venue__r.ASI_KOR_Contract_Type__c,
            ASI_KOR_Venue__r.Name,
            ASI_KOR_Category__c,
            ASI_KOR_Roll_up__c,
            ASI_KOR_Last_3_month_Actual_average_UC__c,
            ASI_KOR_Last_3_month_Actual_Average_Volu__c,
            ASI_KOR_Incentive_Scheme__r.ASI_KOR_UOM__c,
            ASI_KOR_Target_Volume__c,ASI_KOR_Business_Rationale__c,ASI_KOR_Grade__c,ASI_KOR_Channel__c,ASI_KOR_Cap_Unit_Cost_Basic__c,ASI_KOR_Cap_Unit_Cost_CA__c,ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,ASI_KOR_Venue__c,ASI_KOR_Incentive_Scheme__c,
            ASI_KOR_Total_Incentive_Amount_Proposal__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,
            ASI_KOR_Incentive_Scheme__r.ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name
			/* [VL 4.0] BEGIN */
			, ASI_KOR_Venue__r.ASI_KOR_Venue_Type__c, ASI_KOR_Brand__r.ASI_KOR_UOM__c
			, ASI_KOR_Is_Pre_payment__c
			, ASI_KOR_Actual_Volume_1_Month_Ago__c, ASI_KOR_Actual_Volume_2_Months_Ago__c
			, ASI_KOR_Total_VI_1_Month_Ago__c, ASI_KOR_Total_VI_2_Months_Ago__c
			, ASI_KOR_Unit_Cost_1_Month_Ago__c
			, ASI_KOR_Brand__r.ASI_KOR_Sequence__c
			/* [VL 4.0] END */
            from ASI_KOR_SR_Proposal_Detail__c 
            where 
            ASI_KOR_SR_Proposal_ID__c =: srProposalHeader.id
            and ASI_KOR_Venue__c=:venueId
            order by ASI_KOR_Brand__r.name];
        //Set<Id> existingBR = new Set<Id>();
        
        VenueSummary vs = venueSummaryMap.get(venueId);
        for(ASI_KOR_SR_Proposal_Detail__c b: temp){
            //existingBR.add(b.ASI_KOR_Brand__c);        
            if(brandUomCombo.get(b.ASI_KOR_Brand__c) == null){
                Set<String> tempSet = new Set<String>();
                tempSet.add(b.ASI_KOR_UOM__c);
                brandUomCombo.put(b.ASI_KOR_Brand__c,tempSet);
            }else{
                brandUomCombo.get(b.ASI_KOR_Brand__c).add(b.ASI_KOR_UOM__c);
            }
            
        }
        proposalDetails.addAll(temp);
        
        List<ASI_KOR_Incentive_Scheme__c> incentiveSchemes = [select ASI_KOR_Effective_Start_Date__c ,id, 
                                                              ASI_KOR_Grade__c,ASI_KOR_Contract__c,
                                                              /* [VL 1.0] BEGIN */
                                                              ASI_KOR_Channel__c,
                                                              /* [VL 1.0] END */
                                                              ASI_KOR_Brand__c,ASI_KOR_UOM__c 
                                                              /* [VL 4.0] BEGIN */
                                                              ,ASI_KOR_Brand__r.ASI_KOR_UOM__c
                                                              /* [VL 4.0] END */
                                                              from ASI_KOR_Incentive_Scheme__c
                                                              where 
																/* [VL 4.0] BEGIN */
																/*
																ASI_KOR_Branch_Code__c =:ownerBranch
																and
																*/
																/* [VL 4.0] END */
                                                              ASI_KOR_Effective_Start_Date__c <= :srHeaderDate
                                                              and ASI_KOR_Effective_End_Date__c >= :srHeaderLastDate 
                                                              order by ASI_KOR_Brand__c, ASI_KOR_UOM__c,ASI_KOR_Sales_Bracket__c];
        
        system.debug('DDDD: ' + incentiveSchemes.size());
        
        Id prevBrand = null;
        String prevUom ='';
		/*
        system.debug('SSS Venue id: ' + venueId + 'contractype : ' + venueSummaryMap.get(venueID).venue.ASI_KOR_Contract_Type__c
                     + 'contrct grade: ' + venueSummaryMap.get(venueID).venue.ASI_KOR_Grade__c  );
		*/

		/* [VL 4.0] BEGIN */
		// Get actual volume of all brands in this venue
		Map<integer, Map<string, AggregateResult>> map_month_brand_actual = new Map<integer, Map<string, AggregateResult>>();
		map_month_brand_actual = retrieveVenueActual(venueId, 2);
		/* [VL 4.0] END */
        
        for(ASI_KOR_Incentive_Scheme__c ic: incentiveSchemes){
            system.debug('QQQQ: ' + ic.id + ' ' +ic.ASI_KOR_Contract__c + ' ' + ic.ASI_KOR_Grade__c  );
            if((
                brandUomCombo.containsKey(ic.ASI_KOR_Brand__c) &&
                brandUomCombo.get(ic.ASI_KOR_Brand__c).contains(ic.ASI_KOR_UOM__c)
            )
               /* [VL 4.0] BEGIN */
               /*
               ||
               venueSummaryMap.get(venueID).venue.ASI_KOR_Contract_Type__c != ic.ASI_KOR_Contract__c  ||
               venueSummaryMap.get(venueID).venue.ASI_KOR_Grade__c != ic.ASI_KOR_Grade__c
			   */
               /* [VL 4.0] BEGIN */
               /* [VL 1.0] BEGIN */
               || venueSummaryMap.get(venueID).venue.ASI_KOR_Venue_Pillar__c != ic.ASI_KOR_Channel__c
               /* [VL 1.0] BEGIN */
              ){
                  continue;
              }
            if(ic.ASI_KOR_Brand__c != prevBrand || ic.ASI_KOR_UOM__c != prevUom ){
                system.debug('AAAA: ' + ic.id);
                prevBrand = ic.ASI_KOR_Brand__c;
			    /* [VL 4.0] BEGIN */
				/*
                prevUom = ic.ASI_KOR_UOM__c;
				*/
			    prevUom = ic.ASI_KOR_Brand__r.ASI_KOR_UOM__c;
			    /* [VL 4.0] END */
                ASI_KOR_SR_Proposal_Detail__c detail = new ASI_KOR_SR_Proposal_Detail__c();
                detail.ASI_KOR_Brand__c = ic.ASI_KOR_Brand__c;
                detail.ASI_KOR_Brand__r = brandsMap.get(ic.ASI_KOR_Brand__c);
                // detail.ASI_KOR_Brand__r = br;
                //  Account venue =   new Account(id=venueId,name=venueSummaryMap.get(venueID).venueName,ASI_KOR_Customer_Code__c =venueSummaryMap.get(venueID).venueCode);
                detail.ASI_KOR_Venue__r = venueSummaryMap.get(venueID).venue;
                detail.ASI_KOR_Venue__r.name = venueSummaryMap.get(venueID).venueName;
                detail.ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c  = venueSummaryMap.get(venueID).venueCode;
                detail.ASI_KOR_Venue__c = venueId;
                detail.ASI_KOR_SR_Proposal_ID__c = srProposalHeader.id;
                detail.ASI_KOR_Incentive_Scheme__r = ic;
                detail.ASI_KOR_Incentive_Scheme__c = ic.id;
                detail.ASI_KOR_Roll_up__c = true;
                //detail.ASI_KOR_Last_3_month_Actual_average_UC__c = ASI_KOR_Last_3_Month_Average_Calculation.averageUnitCost((String)ic.ASI_KOR_Brand__c,(String)venueID,cutOffDate);
                /* [VL 4.0] BEGIN */
				/*
				if( prevUom == 'Actual Case'){
                    detail.ASI_KOR_Last_3_month_Actual_Average_Volu__c = ASI_KOR_Last_3_Month_Average_Calculation.averageCases((String)ic.ASI_KOR_Brand__c,(String)venueID,cutOffDate);
                    detail.ASI_KOR_Last_3_month_Actual_average_UC__c = ASI_KOR_Last_3_Month_Average_Calculation.averageUnitCostByCases((String)ic.ASI_KOR_Brand__c,(String)venueID,cutOffDate);
                }else{
                    detail.ASI_KOR_Last_3_month_Actual_Average_Volu__c = ASI_KOR_Last_3_Month_Average_Calculation.averageBottles((String)ic.ASI_KOR_Brand__c,(String)venueID,cutOffDate);
                    detail.ASI_KOR_Last_3_month_Actual_average_UC__c = ASI_KOR_Last_3_Month_Average_Calculation.averageUnitCostByBottles((String)ic.ASI_KOR_Brand__c,(String)venueID,cutOffDate);
                }   
				*/
				for (integer i : map_month_brand_actual.keySet()){
					Map<string, AggregateResult> map_brand_actual = map_month_brand_actual.get(i);
					if (map_brand_actual.containsKey(detail.ASI_KOR_Brand__c)){
						AggregateResult actualResult = map_brand_actual.get(detail.ASI_KOR_Brand__c);
						Decimal actualVolume = prevUom == 'Actual Case' ? (Decimal)actualResult.get('caseAmount') : (Decimal)actualResult.get('bottleAmount');
						actualVolume = actualVolume.setScale(0);
						Decimal actualAmount = (Decimal)actualResult.get('prePayAmount');
						actualAmount = actualAmount.setScale(0);
						if (i==1){
							detail.ASI_KOR_Actual_Volume_1_Month_Ago__c = actualVolume;
							detail.ASI_KOR_Total_VI_1_Month_Ago__c = actualAmount;
						} else
						if (i==2){
							detail.ASI_KOR_Actual_Volume_2_Months_Ago__c = actualVolume;
							detail.ASI_KOR_Total_VI_2_Months_Ago__c = actualAmount;
						}
					}
				}
				/* [VL 4.0] END */
                proposalDetails.add(detail);  
                
            }
        }
        if(proposalDetails.size() > 0){
            sortDetails();
            
        }
    }
	
	/* [VL 4.0] BEGIN */
	private Map<integer, Map<string, AggregateResult>> retrieveVenueActual(string venueId, integer uptoXmonth){
		Map<integer, Map<string, AggregateResult>> map_month_brand_actual = new Map<integer, Map<string, AggregateResult>>();
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		
		for (integer i=1; i<=uptoXmonth; i++){
			Date lastDate = thisProposalDate.addMonths(-i);
			Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
			string lastYear = lastDateTime.format('yyyy');
			string lastMonth = lastDateTime.format('MMMM');
			
			Map<string, AggregateResult> map_brand_actual = new Map<string, AggregateResult>();
			for (AggregateResult result : [Select 
                         sum(ASI_KOR_Venue_Depl_Actual_Volume__c) bottleAmount,
                         sum(ASI_KOR_Venue_Depl_Actual_Case__c) caseAmount,
                       sum(ASI_KOR_Venue_Depl_Promotion_Number__c) prePayAmount,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c brand
                     From 
                         ASI_KOR_Venue_Depletion_Detail__c 
                     where 
                       ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c = :lastMonth 
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c = :lastYear 
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c = :venueId
                     group by 
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c
			]){
				map_brand_actual.put(String.valueOf(result.get('brand')), result);
			}
			
			map_month_brand_actual.put(i, map_brand_actual);
		}
		
		return map_month_brand_actual;
		
	}
	/* [VL 4.0] END */
    
    private void sortDetails(){ 
        List<DetailWrapper> detailWrapperList = new List<DetailWrapper>();
        
        for(ASI_KOR_SR_Proposal_Detail__c detail : proposalDetails){
            detailWrapperList.add(new DetailWrapper(detail));
        }
        
        detailWrapperList.sort();
        proposalDetails.clear();
        for(DetailWrapper detailW :  detailWrapperList ){ 
            proposalDetails.add(detailW.detail);
        }
    }
    
    global class DetailWrapper implements Comparable{
        public ASI_KOR_SR_Proposal_Detail__c detail {get; set;}
        public DetailWrapper(ASI_KOR_SR_Proposal_Detail__c detail){
            this.detail = detail;
        }
        global Integer compareTo(Object compareTo) 
        {
            DetailWrapper detailW= (DetailWrapper) compareTo;
			/* [VL 4.0] BEGIN */
			/*
            if (detail.ASI_KOR_Brand__r.Name == detailW.detail.ASI_KOR_Brand__r.Name) return 0;
            if (detail.ASI_KOR_Brand__r.Name >detailW.detail.ASI_KOR_Brand__r.Name) return 1;
			*/
            if ((detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c == null ? 0 : detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c) == (detailW.detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c == null ? 0 : detailW.detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c)) {
				if (detail.ASI_KOR_Brand__r.name > detailW.detail.ASI_KOR_Brand__r.name) return 1;
				else return -1;
			}
            if ((detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c == null ? 0 : detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c) >  (detailW.detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c == null ? 0 : detailW.detail.ASI_KOR_Brand__r.ASI_KOR_Sequence__c)) return 1;
			/* [VL 4.0] END */
            return -1;        
        }
    }
	
	/* [VL 6.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Sales_Planning_Report_UC' limit 1];
		return report.id;
	}
	public string getYear(){
		return srProposalHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return srProposalHeader.ASI_KOR_Month__c;
	}
	/* [VL 6.0] BEGIN */
    
	/* [VL 9.0] BEGIN */
	public PageReference refreshVenueSummary(){    
        updateVenueSummary();
        return null;
    }
	/* [VL 9.0] BEGIN */
	
}