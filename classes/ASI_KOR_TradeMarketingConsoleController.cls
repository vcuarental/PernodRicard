/**********************************************************************************
 * Name : ASI_KOR_TradeMarketingConsoleController 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??										Created
 * 2017-02-14       Laputa: Vincent         [VL 1.0] use a new controller to calculate actual volume
 * 2017-06-09		Laputa: Vincent			[VL 2.0] change in budget
 * 2017-06-16		Laputa: Vincent			[VL 3.0] Revise wordings for P4.2
 *											[VL 3.1] Restructure start sales planning because there will be no branches in incentive scheme
 * 2017-08-01		Laputa: Vincent			[VL 4.0] Keyman Allocation
 * 2018-03-26		Laputa: Vincent			[VL 5.0] Hide payment start button if the calculation is running
 * 2018-07-12		Laputa: Vincent			[VL 6.0] Add branch picklist in SIT Status Update section
 **********************************************************************************/
/*
Trade Marketing Console
Functions: i) Creation, Deletion of Headers

NSD Header        --> NSD By Brand
|                    |
|----|----|----|----|          |
RSD  RSD  RSD  RSD  RSD  --> RSD By Brand
|    |    |    |    |          |
BM.. BM.. BM.. BM.. BM.. -->  BM By Brand

This class produces headers starting from NSD Proposal & Payment Settlement
and its corresponding headers by brand according the the incentive scheme.
~Daniel.

ii) Prepare VMS Interface data by filtering Payment Settlement Details.                                                        




*/
public class ASI_KOR_TradeMarketingConsoleController {
    
    
    
    
    public String monthSync { get; set; }
    public String yearSync { get; set; }
    public String monthProposal{get;set;} //user input month for proposal kickoff
    public String yearProposal{get;set;} // user input year for proposal kickoff
    public String monthPaymentSettlement{get;set;} // user input month for payment settlement kickoff
    public String yearPaymentSettlement{get;set;}// user input year for payment settlement kickoff
    public String monthSITStatus{get;set;} // user input month for Update SIT Status
    public String yearSITStatus{get;set;}// user input year for Update SIT Status
    public String sitStatus{get;set;}// user input year for Update SIT Status
    public String region {get;set;} // user select region
    public Date cutOffDatePayment {get;set;} // user input cut-off date
    public Date cutOffDate {get;set;} // user input cut-off date
    public SelectOption[] monthOptions{get;set;} //picklist val
    public SelectOption[] yearOptions{get;set;}//picklist val
    public SelectOption[] regionOptions{get;set;}//Region picklist val
    public SelectOption[] statusOptions{get;set;}//Region picklist val
    public Map<String,Set<String>> BranchBrandMap{get;set;} // maps branch - brands (multiple brands in 1 branch)
    // public Map<String,Set<String>> regionMap{get;set;} // branches in names
    public Map<String,Set<String>> regionBranchCodeMap{get;set;} // branches in code
    // public Map<String,String> branchNameCodeMap{get;set;} // branch name - code map
    // public Map<String,String> branchCodeNameMap{get;set;} // branch code - name map
    public Map<String,String> regionDir{get;set;} // regional director map(id) - region code
    public Map<String,String> branchDir{get;set;}// branch manager map(id) - branch code
    public Map<String,String> dirBranch{get;set;}//  branch code map - branch manager 
    public List<ASI_KOR_Regions__c> regions{get;set;} //contains ASI_KOR_Regional_Sales_Director__c, ASI_KOR_Region_Code__c 
    public List<ASI_KOR_Branches__c> branches{get;set;}//contains Name,ASI_KOR_Branch_Code__c,ASI_KOR_Branch_Manager__c,ASI_KOR_Region_Code__c
    //ASI_KOR_Brand__c ,ASI_KOR_UOM__c, ASI_KOR_Branch__c groupped by : ASI_KOR_Brand__c ,ASI_KOR_UOM__c, ASI_KOR_Branch__c
    public String status {get;set;}
    public Boolean showStartButton {get;set;}
	
	/* [VL 6.0] BEGIN */
	public SelectOption[] branchOptions{get;set;}
    public String branch {get;set;}
	/* [VL 6.0] END */
	
	/* [VL 4.0] BEGIN */
    public String monthKeyman{get;set;}
    public String yearKeyman{get;set;}
    public String regionKeyman {get;set;}
    public Date cutOffDateKeyman {get;set;}
	/* [VL 4.0] END */
	
	/* [VL 3.1] BEGIN */
	/*
    public List<AggregateResult> grouppedBranches{get;set;}  
	*/
	public list<Wrapper_brandUOMBranch> grouppedBranches{get;set;}  
	
	private class Wrapper_brandUOMBranch {
		public String brand {get;set;}
		public String UOM {get;set;}
		public String branch {get;set;}
		public Wrapper_brandUOMBranch(String brand, String UOM, String branch){
			this.brand = brand;
			this.UOM = UOM;
			this.branch = branch;
		}
	}
	/* [VL 3.1] END */
    
    
    /*       
Data Storage Classes 
- stores temporary data during transition from higher level
to lower level.
*/
    
    private class National{
        public String NCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;}
        public String ownerID{get;set;}
        
        public National(String NID, String proID, String paymentID, String Owner){
            NCode = NID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = owner;
        } 
    }
    private class NationalByBrand{
        public String NCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;}
        public String ownerID{get;set;}
        public String brandID{get;set;}
        public String UOM{get;set;}
        
        public NationalByBrand( String NID, String proID, String paymentID, String Owner, String Brand, String unit){
            NCode = NID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = owner;
            brandID = brand;
            UOM = unit;
        } 
    }
    
    private class Regional{
        
        public String NCode{get;set;}
        public String RCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;}  
        public String ownerID{get;set;}
        
        public Regional( String NID, String RID, String proID, String paymentID, String Owner){
            
            NCode = NID;
            RCode = RID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = Owner;
        }
    }
    
    private class RegionalByBrand{
        public String NCode{get;set;}
        public String RCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;}  
        public String ownerID{get;set;}
        public String brandID{get;set;}
        public String UOM{get;set;}
        
        public RegionalByBrand( String NID, String RID, String proID, String paymentID, String Owner, String Brand, String unit){
            
            NCode = NID;
            RCode = RID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = Owner;
            brandID = Brand;
            UOM = unit;
        }
    }
    
    private class Branch{
        
        public String RCode{get;set;}
        public String BCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;} 
        public String ownerID{get;set;} 
        
        public Branch( String RID, String BID, String proID, String paymentID, String Owner){
            
            RCode = RID;
            BCode = BID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = Owner;
        }
    }
    
    private class BranchByBrand{
        
        public String RCode{get;set;}
        public String BCode{get;set;}
        public String proposalID{get;set;}
        public String paymentSettlementID{get;set;} 
        public String ownerID{get;set;} 
        public String brandID{get;set;}
        public String UOM{get;set;}
        
        
        public BranchByBrand( String RID, String BID, String proID, String paymentID, String Owner, String Brand, String unit){
            
            RCode = RID;
            BCode = BID;
            proposalID = proID;
            paymentSettlementID = paymentID;
            ownerID = Owner;
            brandID = Brand;
            UOM = unit;
        }
    }
    
    
    
    //Constructor : set up all the picklist values
    public ASI_KOR_TradeMarketingConsoleController(){
        showStartButton = true;
        cutOffDate =null;
        cutOffDatePayment = null;
        Integer year = Integer.valueOf(DateTime.now().year());
        yearOptions = new SelectOption[]{};
            for(integer i = 0 ; i < 5; i++){
                yearOptions.add(new SelectOption(String.valueOf(year-1),String.valueOf(year-1)));
                year++;
            }
        monthOptions=new SelectOption[]{};
            for(integer i = 1 ; i < 13; i++){
                monthOptions.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
            }
        
        regionOptions = new SelectOption[]{};
            Map <String,ASI_KOR_Regions__c> regionMap = ASI_KOR_Regions__c.getall();
        
        for(string s : regionMap.keySet()){
            regionOptions.add(new SelectOption(regionMap.get(s).name, regionMap.get(s).name));
        }
        regionOptions.sort();
		
		/* [VL 6.0] BEGIN */
		branchOptions = new SelectOption[]{};
		SelectOption[] branchOptionsTemp = new SelectOption[]{};
		branchOptions.add(new SelectOption('All', 'All'));
		
            Map <String,ASI_KOR_Branches__c> branchMap = ASI_KOR_Branches__c.getall();
        
        for(string s : branchMap.keySet()){
            branchOptionsTemp.add(new SelectOption(branchMap.get(s).ASI_KOR_Branch_Code__c, branchMap.get(s).name));
        }
        branchOptionsTemp.sort();
		branchOptions.addall(branchOptionsTemp);
		/* [VL 6.0] END */
		


        Schema.DescribeSObjectResult r = Schema.getGlobalDescribe().get('ASI_KOR_Stock_In_Trade__c').getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get('ASI_KOR_Status__c').getDescribe();
        List<Schema.PicklistEntry> ple = f.getPicklistValues();

        statusOptions = new SelectOption[]{};
        for (Schema.PicklistEntry picklistEntry : ple) {
            statusOptions.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }


        Date lastMonth = Date.today().addMonths(-1);
        yearSITStatus = String.valueOf(lastMonth.year());
        monthSITStatus = String.valueOf(lastMonth.month());
    }
    
    // Prepares Payment Settlement Detail records in VMS Interface Files object for synching purpose
    public void startSync() {
        status = '';
        List<AsyncApexJob> processingJobs = [SELECT ID, JobItemsProcessed ,TotalJobItems , ApexClassID FROM AsyncApexJob WHERE Status = 'Processing'];
        for(AsyncApexJob job : processingJobs ){
            List<ApexClass> classes = [SELECT Id, Name FROM ApexClass WHERE Id =: job.ApexClassID];
            for(ApexClass c : classes){
                if(c.Name =='ASI_KOR_VMS_Sync'){
                    apexpages.message err = new apexpages.message
                        (apexpages.severity.error, 'VMS Interface Files for '+ yearSync + '-' + monthSync + 
                         ' is currently being uploaded, currrent status: ' + (job.JobItemsProcessed/job.TotalJobItems)*100 +'% .' );
                    apexpages.addmessage(err);   
                    cutOffDatePayment = null;
                    cutOffDate = null;
                    return ;
                    
                }
            }
            
        }
        String PromotionMonth = yearSync + monthSync;
        Date inputDate = Date.today();
        
        List<ASI_KOR_VMS_Interface_File__c> existingFile = 
            [SELECT ID
             FROM ASI_KOR_VMS_Interface_File__c
             WHERE ASI_KOR_Promotion_Month__c = :PromotionMonth
            ];
        if(existingFile.size()>0){       
            apexpages.message err = new apexpages.message
                (apexpages.severity.error, 'VMS Interface Files for '+ yearSync + '-' + monthSync + ' had already been created.');
            apexpages.addmessage(err);   
            cutOffDatePayment = null;
            cutOffDate = null;
            return ;
        }
        
        Map<String,String> ownerDetailMap = new Map<String,String>();
        List<ASI_KOR_SR_Payment_Settlement_Header__c> SRPayList =
            [SELECT ID , OwnerID
             FROM ASI_KOR_SR_Payment_Settlement_Header__c
             WHERE ASI_KOR_Month__c = :monthSync AND ASI_KOR_Year__c = :yearSync AND ASI_KOR_Status__c = 'Approved by BM'
            ];
        if(SRPayList.size()==0){          
            apexpages.message err = new apexpages.message
                (apexpages.severity.error, 'There are no Payment Settlements for ' + yearSync + '-' + monthSync +' available.' );
            apexpages.addmessage(err);   
            cutOffDatePayment = null;
            cutOffDate = null;
            return ;
            
        }
        List<ASI_KOR_NSD_Payment_Settlement_Header__c> NSDApproved =
            [SELECT ID
             FROM ASI_KOR_NSD_Payment_Settlement_Header__c 
             WHERE ASI_KOR_Year__c = :yearSync
             AND ASI_KOR_Month__c = :monthSync
             AND ASI_KOR_Status__c = 'Final Approved'
            ];
        if(NSDApproved.size()==0){
            apexpages.message err = new apexpages.message
                (apexpages.severity.error, 'Payment Settlement for '+ yearSync + '-' + monthSync + ' has not been approved by NSD.');
            apexpages.addmessage(err);   
            cutOffDatePayment = null;
            cutOffDate = null;
            return ;
        }
        List<User> temp = new List<User>();
        String paymentSettlementID = '(';
        for(ASI_KOR_SR_Payment_Settlement_Header__c SRPay : SRPayList){
            ownerDetailMap.put( SRPay.ownerID,SRPay.ID);
            User tempUser = new User();
            tempUser.ID = SRPay.OwnerID;
            temp.add(tempUser);
            paymentSettlementID = paymentSettlementID +'\'' + SRPay.ID +'\',';
            
        }
        
        paymentSettlementID= paymentSettlementID.removeEnd(',') + ')';
        temp = [SELECT ASI_KOR_User_Branch_Code__c,ID  FROM User WHERE ID IN :temp];
        
        Map<String,String> detailBranchCodeMap = new Map<String,String>();
        for(User userTemp : temp){
            detailBranchCodeMap.put(ownerDetailMap.get(userTemp.ID), userTemp.ASI_KOR_User_Branch_Code__c);
        } 
        
        String sqlQuery=  
            'Select '+ 
            'ASI_KOR_Brand__r.ASI_KOR_Brand_Code__c,'+
            'ASI_KOR_Brand__r.ASI_KOR_VMS_Brand_Code__c,'+
            'ASI_KOR_Venue_Code__c,'+
            'ASI_KOR_Keyman_Name__c,'+
            'ASI_KOR_Final_CA_Amount_excl_Basic__c ,'+
            'ASI_KOR_SR_Payment_Settlement__c,'+
            'ASI_KOR_Venue_Name__r.ASI_KOR_Salesman_Code__c'+        
            ' From '+ 
            'ASI_KOR_SR_Payment_Settlement_Detail__c'+ 
            ' where '+ 
            'ASI_KOR_Final_CA_Amount_excl_Basic__c != 0 AND ' +
            'ASI_KOR_SR_Payment_Settlement__c IN ' + paymentSettlementID   ;
        
        //ASI_KOR_VMS_Sync batchSync = new ASI_KOR_VMS_Sync(sqlQuery,inputDate , promotionMonth, detailBranchCodeMap);
        //ID batchprocessid = Database.executeBatch(batchSync, 200);
        
        //status = String.valueOf('VMS Interface Data preperation for '+yearSync + '-'+ monthSync +' has been requested, a notification email will be sent once ready.');
        
    }
    
    public void deleteProposal() {
        status ='';
        
        List<ASI_KOR_SR_Proposal_Header__c>  SRHeaders =
            [SELECT
             ID 
             FROM
             ASI_KOR_SR_Proposal_Header__c 
             WHERE
             ASI_KOR_Year__c = :yearProposal AND 
             ASI_KOR_Month__c = :monthProposal
            ];
        
        List<ASI_KOR_SR_Payment_Settlement_Header__c>  SRPayment =
            [SELECT
             ID 
             FROM
             ASI_KOR_SR_Payment_Settlement_Header__c 
             WHERE
             ASI_KOR_Year__c = :yearProposal AND 
             ASI_KOR_Month__c = :monthProposal
            ];
        
        if(SRHeaders.size()==0 && SRPayment.size()==0) {    
            
            List<ASI_KOR_NSD_Proposal_Header__c> NSDHeaders =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_NSD_Proposal_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_RSD_Proposal_Header__c> RSDHeaders =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_RSD_Proposal_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_BM_Proposal_Header__c> BMHeaders =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_BM_Proposal_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_NSD_Proposal_By_Brand__c> NSDBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_NSD_Proposal_By_Brand__c
                 WHERE
                 ASI_KOR_NSD_Proposal_Header__c IN :NSDHeaders
                ];
            List<ASI_KOR_RSD_Proposal_By_Brand__c> RSDBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_RSD_Proposal_By_Brand__c 
                 WHERE
                 ASI_KOR_RSD_Proposal_Header__c IN :RSDHeaders
                ];
            List<ASI_KOR_BM_Proposal_By_Brand__c> BMBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_BM_Proposal_By_Brand__c 
                 WHERE
                 ASI_KOR_BM_Proposal_Header__c IN :BMHeaders
                ];
            
            
            
            List<ASI_KOR_NSD_Payment_Settlement_Header__c> NSDPayment =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_NSD_Payment_Settlement_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPayment =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_RSD_Payment_Settlement_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_BM_Payment_Settlement_Header__c> BMPayment =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_BM_Payment_Settlement_Header__c 
                 WHERE
                 ASI_KOR_Year__c = :yearProposal AND 
                 ASI_KOR_Month__c = :monthProposal
                ];
            List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> NSDPaymentBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_NSD_Payment_Settlement_By_Brand__c
                 WHERE
                 ASI_KOR_NSD_Payment_Settlement_Header__c IN :NSDPayment
                ];
            List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> RSDPaymentBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_RSD_Payment_Settlement_By_Brand__c 
                 WHERE
                 ASI_KOR_RSD_Payment_Settlement__c IN :RSDPayment
                ];
            List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> BMPaymentBB =
                [SELECT
                 ID 
                 FROM
                 ASI_KOR_BM_Payment_Settlement_By_Brand__c 
                 WHERE
                 ASI_KOR_BM_Payment_Settlement__c IN :BMPayment
                ];
            
            if(NSDHeaders.size()==0){
				/* [VL 3.0] BEGIN */
				/*
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'CA Proposals are not available for ' + yearProposal + '-' + monthProposal + '.');
				*/
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'Sales Plannings are not available for ' + yearProposal + '-' + monthProposal + '.');
				/* [VL 3.0] END */
                apexpages.addmessage(err);   
                cutOffDatePayment = null;
                cutOffDate = null;
                return;  
            }
            delete BMBB;
            delete BMHeaders;
            delete RSDBB;
            delete RSDHeaders;
            delete NSDBB;
            delete NSDHeaders;
            
            delete BMPaymentBB;
            delete BMPayment;
            delete RSDPaymentBB;
            delete RSDPayment;
            delete NSDPaymentBB;
            delete NSDPayment;
            
			/* [VL 3.0] BEGIN */
			/*
            status ='Trade Spend Cycle (Proposal) for '+ yearProposal + '-'+ monthProposal +' has been retracted.' ;
			*/
            status ='Trade Spend Cycle (Sales Planning) for '+ yearProposal + '-'+ monthProposal +' has been retracted.' ;
			/* [VL 3.0] END */
            
        }else{
			/* [VL 3.0] BEGIN */
			/*
            apexpages.message err = new apexpages.message(apexpages.severity.error, 
                                                          'Unable to delete records which has already been associated to SR Proposals and Payment Settlements.');
			*/
            apexpages.message err = new apexpages.message(apexpages.severity.error, 
                                                          'Unable to delete records which has already been associated to SR Sales Planning and Payment Settlements.');
			/* [VL 3.0] END */
            apexpages.addmessage(err); 
            cutOffDatePayment = null;
            cutOffDate = null;
            return ;
            
            
            
        }
        
    }
    
    
    /*       
Kick-off payment settlement 
- Stores cut-off time for actual volume for
data fetching
- Cut-off time stored in NSD Payment Settlement 
header.  
*/
    public void startSettlementPayment() {
        List<String> users = new List<String>();
        List<String> SRBranchCode = new List<String>();
        
        status = '';
        
        if( cutOffDatePayment != null){
            Date cutOffDate_internal = Date.today();
            //get info to start payment settlement and send notification email
            List<ASI_KOR_NSD_Payment_Settlement_Header__c> NSDPaySet =
                [SELECT
                 ID , ASI_KOR_SYS_Cut_off_Date__c, ASI_KOR_Delegated_Approver__c 
                 FROM
                 ASI_KOR_NSD_Payment_Settlement_Header__c 
                 WHERE
                 ASI_KOR_Month__c= :monthPaymentSettlement AND 
                 ASI_KOR_Year__c = :yearPaymentSettlement 
                 LIMIT 1
                ];
            
            List<ASI_KOR_RSD_Proposal_Header__c> RSDPropSet =
                [SELECT
                 ID , ASI_KOR_Status__c, ASI_KOR_Region__c 
                 FROM
                 ASI_KOR_RSD_Proposal_Header__c 
                 WHERE
                 ASI_KOR_Month__c= :monthPaymentSettlement AND 
                 ASI_KOR_Year__c = :yearPaymentSettlement AND
                 ASI_KOR_Region__c = :region 
                 LIMIT 1
                ];
            
            List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPaySet =
                [SELECT
                 ID , OwnerId , ASI_KOR_SYS_Cut_off_Date__c
                 FROM
                 ASI_KOR_RSD_Payment_Settlement_Header__c 
                 WHERE
                 ASI_KOR_Month__c= :monthPaymentSettlement AND 
                 ASI_KOR_Year__c = :yearPaymentSettlement  AND
                 ASI_KOR_Region__c = :region 
                 LIMIT 1
                ];
                        
            
            
            
            
            if(NSDPaySet != null && NSDPaySet.size()!=0){
               /* 
                if(NSDPaySet.get(0).ASI_KOR_SYS_Cut_off_Date__c != null){
                    apexpages.message err = new apexpages.message
                        (apexpages.severity.error, 'CA Payment Settlement for '+ yearPaymentSettlement + '-' + monthPaymentSettlement + ' exist in database.');
                    apexpages.addmessage(err);   
                    cutOffDatePayment = null;
                    cutOffDate = null;
                    return;                   
                }
                    
                    NSDPaySet.get(0).ASI_KOR_SYS_Cut_off_Date__c  = Date.today();
                    update NSDPaySet.get(0);
				*/
                
                
                
                if(RSDPropSet != null && RSDPropSet.size()!=0){
                    if(RSDPropSet.get(0).ASI_KOR_Status__c != 'Approved by NSD'){
                        apexpages.message err = new apexpages.message
						/* [VL 3.0] BEGIN */
						/*
                            (apexpages.severity.error, ' Proposal is not approved by NSD yet, Please try again later');
						*/
                            (apexpages.severity.error, ' Salse Planning is not approved by NSD yet, Please try again later');
						/* [VL 3.0] END */
                        apexpages.addmessage(err);   
                        cutOffDatePayment = null;
                        cutOffDate = null;
                        return;            
                    }
                    if(RSDPaySet.get(0).ASI_KOR_SYS_Cut_off_Date__c != null){
						/* [VL 3.0] BEGIN */
						/*
                        apexpages.message err = new apexpages.message
						(apexpages.severity.error, 'CA Payment Settlement for '+ yearPaymentSettlement + '-' + monthPaymentSettlement + ' exist in database.');
						*/
                        apexpages.message err = new apexpages.message
						(apexpages.severity.error, 'Payment Settlement for '+ yearPaymentSettlement + '-' + monthPaymentSettlement + ' exist in database.');
						/* [VL 3.0] END */
                        apexpages.addmessage(err);   
                        cutOffDatePayment = null;
                        cutOffDate = null;
                        return;                   
                    }
                    RSDPaySet.get(0).ASI_KOR_SYS_Cut_off_Date__c  = Date.today();
                    update RSDPaySet.get(0);
                    
                    
                    List<ASI_KOR_BM_Payment_Settlement_Header__c> BMPaySet =
                        [SELECT
                         ID , OwnerId, ASI_KOR_Cut_off_Date__c, ASI_KOR_SYS_Branch_Code__c
                         FROM
                         ASI_KOR_BM_Payment_Settlement_Header__c 
                         WHERE
                         ASI_KOR_Month__c= :monthPaymentSettlement AND 
                         ASI_KOR_Year__c = :yearPaymentSettlement AND
                         ASI_KOR_RSD_Payment_Settlement__c = :RSDPaySet.get(0).id
                        ];
                    
                    List<ASI_KOR_BM_Proposal_Header__c> BMProposal =
                        [SELECT
                         ID , OwnerId
                         FROM
                         ASI_KOR_BM_Proposal_Header__c 
                         WHERE
                         ASI_KOR_Month__c= :monthPaymentSettlement AND 
                         ASI_KOR_Year__c = :yearPaymentSettlement AND
                         ASI_KOR_RSD_Proposal_Header__c = :RSDPropSet.get(0).id AND
                         ASI_KOR_Status__c = 'Approved by RSD'
                        ];
                    
                    if (BMProposal.size()>0){
                        set<string> approvedBM = new set<string>();
                        for (ASI_KOR_BM_Proposal_Header__c bm : BMProposal){
                            approvedBM.add(bm.id);
                            users.add(bm.ownerid);
                        }
                        
                        for(ASI_KOR_SR_Proposal_Header__c sr :
                            [SELECT
                             ID , OwnerId
                             FROM
                             ASI_KOR_SR_Proposal_Header__c 
                             WHERE
                             ASI_KOR_Month__c= :monthPaymentSettlement AND 
                             ASI_KOR_Year__c = :yearPaymentSettlement AND
                             ASI_KOR_BM_Proposal_Header__c IN :approvedBM AND
                             ASI_KOR_Status__c = 'Approved by BM'
                            ]){
                                users.add(sr.ownerid);
                            }
                    }
                    
                    
                    if(BMPaySet !=null && BMPaySet.size()!=0){
                        
                        for(ASI_KOR_BM_Payment_Settlement_Header__c BM : BMPaySet){
                            
                            BM.ASI_KOR_Cut_off_Date__c = cutOffDatePayment;
                        }
                        
                        update BMPaySet;
                    }
                    
                    /* [VL 1.0] BEGIN */
                    /*
                    ASI_KOR_SRProposalDetailsActualVolJob srProposalDetailsActualVolJob = 
                        new  ASI_KOR_SRProposalDetailsActualVolJob(yearPaymentSettlement,monthPaymentSettlement, cutOffDatePayment);
                    Database.executeBatch(srProposalDetailsActualVolJob,30);
                    */
                    ASI_KOR_SRProposalDetailsActualVol_V2 srProposalDetailsActualVolJob = 
                        new  ASI_KOR_SRProposalDetailsActualVol_V2(yearPaymentSettlement,monthPaymentSettlement, cutOffDatePayment, region);
                    Database.executeBatch(srProposalDetailsActualVolJob,20);
                    /* [VL 1.0] END */
                    
                    status = 'Trade Spend Cycle (Payment Settlement) for '+ yearPaymentSettlement + '-' + monthPaymentSettlement +' has been started.'+
                        ' Email notifications will be sent once data are ready. ';
                    
                    //put user information into a list to send notification email                    
                    for(ASI_KOR_NSD_Payment_Settlement_Header__c user : NSDPaySet){ 
                        users.add(user.ASI_KOR_Delegated_Approver__c);
                        //status = status + '   ' + user.OwnerID;
                    }
                    for(ASI_KOR_RSD_Payment_Settlement_Header__c user : RSDPaySet){ 
                        users.add(user.OwnerID);
                        //status = status + '   ' + user.OwnerID;
                    }
                    
                    /*
                    for(ASI_KOR_BM_Payment_Settlement_Header__c user : BMPaySet){ 
                        users.add(user.OwnerID);
                        if(user.ASI_KOR_SYS_Branch_Code__c != null)
                            SRBranchCode.add(user.ASI_KOR_SYS_Branch_Code__c); 
                    }
                    
                    //status = status + STring.valueOF(SRBranchCode) ;  
                    List<User> salesRep=
                        [Select ID From User 
                         Where 
                         UserRole.DeveloperName Like 'ASI_KOR_SR%' AND 
                         ASI_KOR_User_Branch_Code__c IN :SRBranchCode
                        ];              							
                    
                    for(User sr : salesRep){                
                        users.add(sr.ID);  
                    }
					*/

                    //get all user id from the profileid - ASI KOR Business Dev Admin (00eD0000001AneO)             
                    List<User> tmktUser = [SELECT firstname, lastname, id FROM user WHERE profileid IN (SELECT id FROM profile WHERE name = 'ASI KOR Business Dev Admin')];
                    
                    system.debug('TMKT');
                    system.debug(tmktUser);
                    
                    for(User tmkt : tmktUser){
                        users.add(tmkt.ID);
                    }
                    
                    List<List<String>> usersList = new List<List<String>>(); 
                    integer count = 0 ;
                    List<String> tempList; 
                    
                    for(String user : users){             
                        if(count == 0){
                            tempList = new List<String>();
                            tempList.add(user);
                            count++;
                        }else if( count <20 && count >0){
                            tempList.add(user);
                            count++;
                        }else{
                            tempList.add(user);
                            usersList.add(tempList);
                            tempList = new list<string>();
                            count=0;
                        }  
                    }
                    
                    if(tempList.size() >0){
                        usersList.add(tempList);
                    }
                    //send notification email to user               
                    for(List<String> mailUser : usersList){
                        try{
							/* [VL 5.0] BEGIN */
							/*
                            sendPaymentSettlementNotificationEmail(mailUser, region);   
							*/
							/* [VL 5.0] BEGIN */   
                        }catch(Exception e){
                            apexpages.message err = 
                                new apexpages.message(apexpages.severity.error, 
                                                      e.getMessage());
                            apexpages.addmessage(err); 
                        }
                    }				                                           
                    cutOffDatePayment = null;
                    cutOffDate=null;
                    return;
                    
                }else{
                    apexpages.message err = new apexpages.message(apexpages.severity.error, 'Invalid Region or Region selected is not ready to be kick-started');
                    apexpages.addmessage(err);   
                    cutOffDatePayment = null;
                    cutOffDate = null;
                    return;  
                }
            }else{
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'Headers for the Month & Year selected is not ready at the mean time.');
                apexpages.addmessage(err);   
                cutOffDatePayment = null;
                cutOffDate = null;
                return;  
            }
        }
        else{
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Cut-Off Date for Payment Settlement Kick-Start cannot be empty.');
            apexpages.addmessage(err);   
            cutOffDatePayment = null;
            cutOffDate = null;
            return;  
            
        }
        
    }
    
    
    /*       
Kick-off Proposal Cycle 
- Creates headers and by brand objects.
*/
    public void startProposal() {
        status = '';
        showStartButton = false;
        
        List<ASI_KOR_NSD_Proposal_Header__c> existing = 
            [SELECT ID FROM ASI_KOR_NSD_Proposal_Header__c WHERE ASI_KOR_Month__c = :monthProposal AND ASI_KOR_Year__c = :yearProposal];
        
        if(existing != null && existing.size()!=0){
			/* [VL 3.0] BEGIN */
			/*
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'CA Proposal for '+ yearProposal + '-'+monthProposal + ' exists in database.' );
			*/
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Sales Planning for '+ yearProposal + '-'+monthProposal + ' exists in database.' );
			/* [VL 3.0] END */
            apexpages.addmessage(err);   
            cutOffDatePayment = null;
            cutOffDate = null;
            showStartButton = true;
            return;  
        }
        if(cutOffDate != null){
            
            ASI_KOR_CustomSettingValidation customSettingValid = new ASI_KOR_CustomSettingValidation();
            if(customSettingValid.isValid()){
                if(init()){
                    
                    
                    List<National> NSDPropHead = createNSDProposalHeader();               
                    List<NationalByBrand> NSDPropHeadBB = createNSDProposalByBrand(NSDPropHead);
                    List<Regional> RSDPropHead = createRSDProposalHeader(NSDPropHead);
                    List<RegionalByBrand> RSDPropHeadBB = createRSDProposalByBrand(RSDPropHead , NSDPropHeadBB);
                    List<Branch> BMPropHead = createBMProposalHeader(RSDPropHead);              
                    List<BranchByBrand> BMPropHeadBB = createBMProposalByBrand(BMPropHead , RSDPropheadBB);
                    
                    List<National> NSDPayHead = createNSDPaymentSettlementHeader();
                    List<NationalByBrand> NSDPayHeadBB = createNSDPaymentSettlementByBrand(NSDPayHead);
                    List<Regional> RSDPayHead = createRSDPaymentSettlementHeader(NSDPayHead);
                    List<RegionalByBrand> RSDPayHeadBB = createRSDPaymentSettlementByBrand(RSDPayHead , NSDPayHeadBB);
                    List<Branch> BMPayHead = createBMPaymentSettlementHeader(RSDPayHead);
                    List<BranchByBrand> BMPayHeadBB = createBMPaymentSettlementByBrand(BMPayHead , RSDPayHeadBB);
                    
                    removeEmpty();
                    calculateTotalCABudget();
                    
                    List<String> users = new List<String>(); 
                    List<ASI_KOR_NSD_Proposal_Header__c> NSDProp = 
                        [SELECT OwnerID, ASI_KOR_Delegated_Approver__c
                         FROM  ASI_KOR_NSD_Proposal_Header__c
                         WHERE ASI_KOR_Year__c = :yearProposal AND
                         ASI_KOR_Month__c = :monthProposal
                        ];
                    List<ASI_KOR_RSD_Proposal_Header__c> RSDProp = 
                        [SELECT OwnerID
                         FROM  ASI_KOR_RSD_Proposal_Header__c
                         WHERE ASI_KOR_Year__c = :yearProposal AND
                         ASI_KOR_Month__c = :monthProposal
                        ];
                    List<ASI_KOR_BM_Proposal_Header__c> BMProp =
                        [SELECT OwnerID, ASI_KOR_SYS_Branch_Code__c
                         FROM  ASI_KOR_BM_Proposal_Header__c
                         WHERE ASI_KOR_Year__c = :yearProposal AND
                         ASI_KOR_Month__c = :monthProposal];
                    
                    List<String> SRBranchCode = new List<String>();
                    
                    
                    for(ASI_KOR_NSD_Proposal_Header__c user : NSDProp){ 
                        users.add(user.ASI_KOR_Delegated_Approver__c);
                        status = status + '   ' + user.OwnerID;
                    }
                    for(ASI_KOR_RSD_Proposal_Header__c user : RSDProp){ 
                        users.add(user.OwnerID);
                        status = status + '   ' + user.OwnerID;
                    }
                    for(ASI_KOR_BM_Proposal_Header__c user : BMProp){ 
                        users.add(user.OwnerID);
                        if(user.ASI_KOR_SYS_Branch_Code__c != null)
                            SRBranchCode.add(user.ASI_KOR_SYS_Branch_Code__c); 
                    }
                    
                    status = status + STring.valueOF(SRBranchCode) ;  
                    List<User> salesRep=
                        [SELECT
                         ID
                         FROM
                         User 
                         WHERE
                         UserRole.DeveloperName LIKE 'ASI_KOR_SR%' AND
                         ASI_KOR_User_Branch_Code__c IN :SRBranchCode
                        ];
                    
                    
                    for(User sr : salesRep){                
                        users.add(sr.ID);  
                    }
                    
                    //get all user id from the profileid - ASI KOR Business Dev Admin (00eD0000001AneO)   
                    List<User> tmktUser = [SELECT id FROM user WHERE profileid IN (SELECT id FROM profile WHERE name = 'ASI KOR Business Dev Admin')];
                    
                    for(User tmkt : tmktUser){
                        users.add(tmkt.ID);
                    }
                    
                    List<List<String>> usersList = new List<List<String>>(); 
                    integer count = 0 ;
                    List<String> tempList; 
                    
                    for(String user : users){             
                        if(count == 0){
                            tempList = new List<String>();
                            tempList.add(user);
                            count++;
                        }else if( count <20 && count >0){
                            tempList.add(user);
                            count++;
                        }else{
                            tempList.add(user);
                            usersList.add(tempList);
                            tempList = new list<string>();
                            count=0;
                        }  
                    }
                    
                    if(tempList.size() >0){
                        usersList.add(tempList);
                    }
                    
                    for(List<String> mailUser : usersList){
                        try{
							sendProposalNotificationEmail(mailUser);
                        }catch(Exception e){
                            apexpages.message err = 
                                new apexpages.message(apexpages.severity.error, 
                                                      e.getMessage());
                            apexpages.addmessage(err); 
                            cutOffDatePayment = null;
                            cutOffDate = null;
                            return;
                            
                        }
                    }
                    
					/* [VL 3.0] BEGIN */
					/*
                    status = 'Trade Spend Cycle (Proposal) for '+ yearProposal + '-' + monthProposal +' has been started.';
					*/
                    status = 'Trade Spend Cycle (Sales Planning) for '+ yearProposal + '-' + monthProposal +' has been started.';
					/* [VL 3.0] END */
                    
                    
                    cutOffDatePayment = null;
                    cutOffDate = null;
                    showStartButton = true;
                    
                }
            }
        }else{
            
			/* [VL 3.0] BEGIN */
			/*
            apexpages.message err = 
                new apexpages.message(apexpages.severity.error, 
                                      'Cut-Off Date for Proposal Kick-Start cannot be empty.');
			*/
            apexpages.message err = 
                new apexpages.message(apexpages.severity.error, 
                                      'Cut-Off Date for Sales Planning Kick-Start cannot be empty.');
			/* [VL 3.0] END */
            apexpages.addmessage(err); 
            cutOffDatePayment = null;
            cutOffDate = null;
            showStartButton = true;
            return;
        }
        
    }
    
    // calculate the total CA Budget according to by brand budgets and aggregate them bottom up
    // populates/adjust the No. of required Branch / Region 
    private void calculateTotalCABudget(){
        
        
        Map<String,Map<String,ASI_KOR_Budget__c>> branchBrandBudget = new Map<String,Map<String,ASI_KOR_Budget__c>>();
        Map<ID,decimal> nationBBBudget = new Map<ID,decimal>();
		/* [VL 2.0] BEGIN */
        Map<ID,decimal> nationBBBudget_volume = new Map<ID,decimal>();
        Map<ID,decimal> nationBBBudget_vi = new Map<ID,decimal>();
		/* [VL 2.0] END */
		
        List<ASI_KOR_Budget__c> l = 
            [SELECT ASI_KOR_Brand__c,ASI_KOR_Branch_Code__c,ASI_KOR_CA_Budget_Amount__c
			/* [VL 2.0] BEGIN */
			, ASI_KOR_Unit_Cost_Cap__c
			, ASI_KOR_Target_Volume__c
			/* [VL 2.0] END */
             FROM ASI_KOR_Budget__c
             WHERE ASI_KOR_Month__c =:monthProposal
             AND ASI_KOR_Year__c =:yearProposal
            ];
        
        for(ASI_KOR_Budget__c budget : l){
            
            if(branchBrandBudget.containsKey(budget.ASI_KOR_Branch_Code__c)){
                Map<String,ASI_KOR_Budget__c> temp = branchBrandBudget.get(budget.ASI_KOR_Branch_Code__c);
                temp.put(budget.ASI_KOR_Brand__c,budget);
                branchBrandBudget.put(budget.ASI_KOR_Branch_Code__c, temp);
            }else{
                Map<String,ASI_KOR_Budget__c> brandBudget = new Map<String,ASI_KOR_Budget__c>();
                brandBudget.put(budget.ASI_KOR_Brand__c, budget);
                branchBrandBudget.put(budget.ASI_KOR_Branch_Code__c,brandBudget );
                
            }
        }
        
        List<ASI_KOR_BM_Proposal_Header__c> BMPropHeaders = 
            [SELECT ID ,OwnerID,ASI_KOR_Branch_Total_CA_Budget__c,ASI_KOR_SYS_Branch_Code__c,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c, ASI_KOR_RSD_Proposal_By_Brand__c FROM ASI_KOR_BM_Proposal_By_Brands__r)
             FROM ASI_KOR_BM_Proposal_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_BM_Proposal_Header__c> updateBMProp = new List<ASI_KOR_BM_Proposal_Header__c>();
        List<ASI_KOR_BM_Proposal_By_Brand__c> updateBMPropBB = new List<ASI_KOR_BM_Proposal_By_Brand__c>();
        
        for(ASI_KOR_BM_Proposal_Header__c prop : BMPropHeaders){
            
            Map<String,ASI_KOR_Budget__c> temp = branchBrandBudget.get(prop.ASI_KOR_SYS_Branch_Code__c);
            List<ASI_KOR_BM_Proposal_By_Brand__c> updateBMPropBBTemp = new List<ASI_KOR_BM_Proposal_By_Brand__c>();
            
            for(ASI_KOR_BM_Proposal_By_Brand__c propBB :prop.ASI_KOR_BM_Proposal_By_Brands__r){
                if(temp!=null && temp.containsKey(propBB.ASI_KOR_Brand__c)){
                    propBB.ASI_KOR_CA_Budget__c  =  temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_CA_Budget_Amount__c == null ? 0 : temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_CA_Budget_Amount__c.round();
					/* [VL 2.0] BEGIN */
					propBB.ASI_KOR_Budget_Target_Unit_Cost__c = temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c == null ? 0 : temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
					propBB.ASI_KOR_Budget_Target_Volume__c = temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_Target_Volume__c == null ? 0 : temp.get(propBB.ASI_KOR_Brand__c).ASI_KOR_Target_Volume__c;
					/* [VL 2.0] END */
                    
                }else{
                    propBB.ASI_KOR_CA_Budget__c =0;
					/* [VL 2.0] BEGIN */
					propBB.ASI_KOR_Budget_Target_Unit_Cost__c = 0;
					propBB.ASI_KOR_Budget_Target_Volume__c = 0;
					/* [VL 2.0] END */
                    
                }    
                updateBMPropBB.add(propBB);
                updateBMPropBBTemp.add(propBB);      
            }
            Decimal sum = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c BB : updateBMPropBBTemp){
                sum = sum + (BB.ASI_KOR_CA_Budget__c == null ? 0 : BB.ASI_KOR_CA_Budget__c.round()) ;
            }
            prop.ASI_KOR_Branch_Total_CA_Budget__c = sum.round();
            updateBMProp.add(prop);
            
        }
        
        
        
        update updateBMPropBB;
        update updateBMProp;
        
        List<ASI_KOR_RSD_Proposal_Header__c> RSDPropHeaders = 
            [SELECT ID , OwnerID ,ASI_KOR_Region_Total_CA_Budget__c,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c,ASI_KOR_NSD_Proposal_By_Brand__c
					/* [VL 2.0] BEGIN */
					, ASI_KOR_Budget_Target_VI__c
					, ASI_KOR_Budget_Target_Volume__c
					/* [VL 2.0] END */
			 FROM ASI_KOR_RSD_ProposRSD_Proposal_By_Brands__r )
             FROM ASI_KOR_RSD_Proposal_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_RSD_Proposal_Header__c> updateRSDProp = new List<ASI_KOR_RSD_Proposal_Header__c>();
        List<ASI_KOR_RSD_Proposal_By_Brand__c> updateRSDPropBB = new List<ASI_KOR_RSD_Proposal_By_Brand__c>();
        System.debug('Debug Log : ' + RSDPropHeaders);
        for(ASI_KOR_RSD_Proposal_Header__c rsdProp : RSDPropHeaders){
            //Used to calculate the number of branch headers in that region
            List<ASI_KOR_BM_Proposal_Header__c> noOfBMHeader =
                [SELECT ID FROM ASI_KOR_BM_Proposal_Header__c WHERE ASI_KOR_RSD_Proposal_Header__r.ID = :rsdProp.id];
            rsdProp.ASI_KOR_No_of_Branches__c = noOfBMHeader.size();
            List<ASI_KOR_RSD_Proposal_By_Brand__c> updateRSDPropBBTemp = new List<ASI_KOR_RSD_Proposal_By_Brand__c>();
            for(ASI_KOR_RSD_Proposal_By_Brand__c rsdPropBB : rsdProp.ASI_KOR_RSD_ProposRSD_Proposal_By_Brands__r){        
                updateRSDPropBBTemp.add(rsdPropBB);
                if(nationBBBudget.containsKey(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget.get(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c).round();
                    tempBudget = tempBudget + rsdPropBB.ASI_KOR_CA_Budget__c;
                    nationBBBudget.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,rsdPropBB.ASI_KOR_CA_Budget__c.round()); 
                }
				/* [VL 2.0] BEGIN */
                if(nationBBBudget_volume.containsKey(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget_volume.get(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c).round();
                    tempBudget = tempBudget + rsdPropBB.ASI_KOR_Budget_Target_Volume__c;
                    nationBBBudget_volume.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget_volume.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,rsdPropBB.ASI_KOR_Budget_Target_Volume__c.round()); 
                }
                if(nationBBBudget_vi.containsKey(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget_vi.get(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c).round();
                    tempBudget = tempBudget + rsdPropBB.ASI_KOR_Budget_Target_VI__c;
                    nationBBBudget_vi.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget_vi.put(rsdPropBB.ASI_KOR_NSD_Proposal_By_Brand__c,rsdPropBB.ASI_KOR_Budget_Target_VI__c.round()); 
                }
				/* [VL 2.0] END */
            }
            Decimal sum = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c rsdPropBBTemp :  updateRSDPropBBTemp){
                sum = sum + rsdPropBBTemp.ASI_KOR_CA_Budget__c;
            }   
            rsdProp.ASI_KOR_Region_Total_CA_Budget__c =sum.round();
            updateRSDProp.add(rsdProp);  
            
        }
        update RSDPropHeaders;   
        update  updateRSDProp;
        
        List<ASI_KOR_NSD_Proposal_Header__c> nsdPropHeaders = 
            [SELECT ID ,ASI_KOR_No_of_Required_Regions__c,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c FROM ASI_KOR_NSD_Proposal_By_Brands__r )
             FROM ASI_KOR_NSD_Proposal_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_NSD_Proposal_By_Brand__c> updateNSDPropBB = new List<ASI_KOR_NSD_Proposal_By_Brand__c>();
        for(ASI_KOR_NSD_Proposal_Header__c nsdProp : NSDPropHeaders){
            //number of required regions
            nsdProp.ASI_KOR_No_of_Required_Regions__c = RSDPropHeaders.size();
            for(ASI_KOR_NSD_Proposal_By_Brand__c nsdPropBB : nsdProp.ASI_KOR_NSD_Proposal_By_Brands__r ){
                nsdPropBB.ASI_KOR_CA_Budget__c = nationBBBudget.get(nsdPropBB.ID).round();
				/* [VL 2.0] BEGIN */
                nsdPropBB.ASI_KOR_Budget_Target_VI__c = nationBBBudget_vi.get(nsdPropBB.ID).round();
                nsdPropBB.ASI_KOR_Budget_Target_Volume__c = nationBBBudget_volume.get(nsdPropBB.ID).round();
				/* [VL 2.0] END */
                updateNSDPropBB.add(nsdPropBB); 
                
            }
        }
        
        update NSDPropHeaders;
        update  updateNSDPropBB;
        
        
        // Payment Settlement
        List<ASI_KOR_BM_Payment_Settlement_Header__c> BMpaysetHeaders = 
            [SELECT ID ,OwnerID,ASI_KOR_Total_Branch_Budget__c,ASI_KOR_SYS_Branch_Code__c,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c, ASI_KOR_RSD_Payment_Settlement_By_Brand__c FROM ASI_KOR_BM_Payment_Settlement_By_Brands__r)
             FROM ASI_KOR_BM_Payment_Settlement_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_BM_Payment_Settlement_Header__c> updateBMpayset = new List<ASI_KOR_BM_Payment_Settlement_Header__c>();
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> updateBMpaysetBB = new List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>();
        
        for(ASI_KOR_BM_Payment_Settlement_Header__c payset : BMpaysetHeaders){
            
            Map<String,ASI_KOR_Budget__c> temp = branchBrandBudget.get(payset.ASI_KOR_SYS_Branch_Code__c);
            List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> updateBMpaysetBBTemp = new List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>();
            
            for(ASI_KOR_BM_Payment_Settlement_By_Brand__c paysetBB :payset.ASI_KOR_BM_Payment_Settlement_By_Brands__r){
                if(temp!=null && temp.containsKey(paysetBB.ASI_KOR_Brand__c)){
                    paysetBB.ASI_KOR_CA_Budget__c  =  temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_CA_Budget_Amount__c == null ? 0 : temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_CA_Budget_Amount__c.round();
					/* [VL 2.0] BEGIN */
					paysetBB.ASI_KOR_Budget_Target_Unit_Cost__c = temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c == null ? 0 : temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
					paysetBB.ASI_KOR_Budget_Target_Volume__c = temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_Target_Volume__c == null ? 0 : temp.get(paysetBB.ASI_KOR_Brand__c).ASI_KOR_Target_Volume__c;
					/* [VL 2.0] END */
                    
                }else{
                    paysetBB.ASI_KOR_CA_Budget__c =0;
					/* [VL 2.0] BEGIN */
					paysetBB.ASI_KOR_Budget_Target_Unit_Cost__c = 0;
					paysetBB.ASI_KOR_Budget_Target_Volume__c = 0;
					/* [VL 2.0] END */
                    
                }    
                updateBMpaysetBB.add(paysetBB);
                updateBMpaysetBBTemp.add(paysetBB);      
            }
            Decimal sum = 0;
            for(ASI_KOR_BM_Payment_Settlement_By_Brand__c BB : updateBMpaysetBBTemp){
                sum = sum + (BB.ASI_KOR_CA_Budget__c == null ? 0 : BB.ASI_KOR_CA_Budget__c.round()) ;
            }
            payset.ASI_KOR_Total_Branch_Budget__c = sum.round();
            updateBMpayset.add(payset);
            
        }
        
        
        
        update updateBMpaysetBB;
        update updateBMpayset;
        
        List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDpaysetHeaders = 
            [SELECT ID , OwnerID ,ASI_KOR_Total_Branch_Budget__c,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c,ASI_KOR_NSD_Payment_Settlement_By_Brand__c
					/* [VL 2.0] BEGIN */
					, ASI_KOR_Budget_Target_VI__c
					, ASI_KOR_Budget_Target_Volume__c
					/* [VL 2.0] END */
			 FROM ASI_KOR_RSD_Payment_Settlement_By_Brands__r )
             FROM ASI_KOR_RSD_Payment_Settlement_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_RSD_Payment_Settlement_Header__c> updateRSDpayset = new List<ASI_KOR_RSD_Payment_Settlement_Header__c>();
        List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> updateRSDpaysetBB = new List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>();
        for(ASI_KOR_RSD_Payment_Settlement_Header__c rsdpayset : RSDpaysetHeaders){
            // used to calculate the number of required branches
            List<ASI_KOR_BM_Payment_Settlement_Header__c> noOfBMPaySet =
                [SELECT ID FROM ASI_KOR_BM_Payment_Settlement_Header__c WHERE ASI_KOR_RSD_Payment_Settlement__r.ID = :rsdPaySet.id];
            rsdPaySet.ASI_KOR_No_of_Branches__c = noOfBMPaySet.size();
            
            List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> updateRSDpaysetBBTemp = new List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>();
            for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdpaysetBB : rsdpayset.ASI_KOR_RSD_Payment_Settlement_By_Brands__r){      
                updateRSDpaysetBBTemp.add(rsdpaysetBB);
                if(nationBBBudget.containsKey(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget.get(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c).round();
                    tempBudget = tempBudget + rsdpaysetBB.ASI_KOR_CA_Budget__c;
                    nationBBBudget.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,rsdpaysetBB.ASI_KOR_CA_Budget__c.round()); 
                }
				/* [VL 2.0] BEGIN */
                if(nationBBBudget_volume.containsKey(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget_volume.get(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c).round();
                    tempBudget = tempBudget + rsdpaysetBB.ASI_KOR_Budget_Target_Volume__c;
                    nationBBBudget_volume.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget_volume.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,rsdpaysetBB.ASI_KOR_Budget_Target_Volume__c.round()); 
                }
                if(nationBBBudget_vi.containsKey(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c)){
                    Decimal tempBudget = nationBBBudget_vi.get(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c).round();
                    tempBudget = tempBudget + rsdpaysetBB.ASI_KOR_Budget_Target_VI__c;
                    nationBBBudget_vi.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,tempBudget);                        
                }else{
                    nationBBBudget_vi.put(rsdpaysetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c,rsdpaysetBB.ASI_KOR_Budget_Target_VI__c.round()); 
                }
				/* [VL 2.0] END */
            }
            Decimal sum = 0;
            for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdpaysetBBTemp :  updateRSDpaysetBBTemp){
                sum = sum + rsdpaysetBBTemp.ASI_KOR_CA_Budget__c;
            }   
            rsdpayset.ASI_KOR_Total_Branch_Budget__c =sum.round();
            updateRSDpayset.add(rsdpayset);  
            
        }
        update RSDPaySetHeaders;   
        update  updateRSDpayset;
        
        List<ASI_KOR_NSD_Payment_Settlement_Header__c> nsdpaysetHeaders = 
            [SELECT ID ,
             (SELECT ID, ASI_KOR_Brand__c, ASI_KOR_CA_Budget__c FROM ASI_KOR_NSD_Payment_Settlement_By_Brands__r )
             FROM ASI_KOR_NSD_Payment_Settlement_Header__c
             WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal
            ];
        List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> updateNSDpaysetBB = new List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c>();
        for(ASI_KOR_NSD_Payment_Settlement_Header__c nsdpayset : NSDpaysetHeaders){
            // calculation for number of required regions
            nsdPaySet.ASI_KOR_No_of_Regions__c = RSDPaySetHeaders.size();
            for(ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdpaysetBB : nsdpayset.ASI_KOR_NSD_Payment_Settlement_By_Brands__r ){   
                nsdpaysetBB.ASI_KOR_CA_Budget__c = nationBBBudget.get(nsdpaysetBB.ID).round();
				/* [VL 2.0] BEGIN */
                nsdpaysetBB.ASI_KOR_Budget_Target_VI__c = nationBBBudget_vi.get(nsdpaysetBB.ID).round();
                nsdpaysetBB.ASI_KOR_Budget_Target_Volume__c = nationBBBudget_volume.get(nsdpaysetBB.ID).round();
				/* [VL 2.0] END */
                updateNSDpaysetBB.add(nsdpaysetBB); 
                
            }
        }
        
        update  updateNSDpaysetBB;
        update NSDPaySetHeaders;
        
        
    }
    
    // Delete headers without any by brand records
    private void removeEmpty(){
        
        List<ASI_KOR_BM_Proposal_Header__c> BMPropHeaders = [SELECT ID ,OwnerID,(SELECT ID FROM ASI_KOR_BM_Proposal_By_Brands__r) FROM ASI_KOR_BM_Proposal_Header__c WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal];
        List<ASI_KOR_BM_Proposal_Header__c> toBeDelBMProp = new List<ASI_KOR_BM_Proposal_Header__c>();
        for(ASI_KOR_BM_Proposal_Header__c del : BMPropHeaders){
            if(del.ASI_KOR_BM_Proposal_By_Brands__r == null || del.ASI_KOR_BM_Proposal_By_Brands__r.size()==0)
                toBeDelBMProp.add(del);          
        }
        delete toBeDelBMProp;
        
        List<ASI_KOR_RSD_Proposal_Header__c> RSDPropHeaders = [SELECT ID , OwnerID ,(SELECT ID FROM ASI_KOR_BM_Proposal_Headers__r) FROM ASI_KOR_RSD_Proposal_Header__c WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal];
        List<ASI_KOR_RSD_Proposal_Header__c> toBeDelRSDProp = new List<ASI_KOR_RSD_Proposal_Header__c>();
        for(ASI_KOR_RSD_Proposal_Header__c del : RSDPropHeaders){
            if(del.ASI_KOR_BM_Proposal_Headers__r == null || del.ASI_KOR_BM_Proposal_Headers__r.size()==0)
                toBeDelRSDProp.add(del);          
        }
        delete toBeDelRSDProp;
        
        
        List<ASI_KOR_BM_Payment_Settlement_Header__c> BMPayHeaders = [SELECT ID , OwnerID, (SELECT ID FROM ASI_KOR_BM_Payment_Settlement_By_Brands__r) FROM ASI_KOR_BM_Payment_Settlement_Header__c WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal];
        List<ASI_KOR_BM_Payment_Settlement_Header__c> toBeDelBMPay = new List<ASI_KOR_BM_Payment_Settlement_Header__c>();
        for(ASI_KOR_BM_Payment_Settlement_Header__c del : BMPayHeaders){
            if(del.ASI_KOR_BM_Payment_Settlement_By_Brands__r == null || del.ASI_KOR_BM_Payment_Settlement_By_Brands__r.size()==0)
                toBeDelBMPay.add(del);          
        }
        delete toBeDelBMPay;
        
        List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPayHeaders = [SELECT ID , OwnerID,(SELECT ID FROM ASI_KOR_BM_Payment_Settlement_Headers__r) FROM ASI_KOR_RSD_Payment_Settlement_Header__c WHERE ASI_KOR_Year__c = :yearProposal AND ASI_KOR_Month__c = :monthProposal];
        List<ASI_KOR_RSD_Payment_Settlement_Header__c> toBeDelRSDPay = new List<ASI_KOR_RSD_Payment_Settlement_Header__c>();
        for(ASI_KOR_RSD_Payment_Settlement_Header__c del : RSDPayHeaders){
            if(del.ASI_KOR_BM_Payment_Settlement_Headers__r == null || del.ASI_KOR_BM_Payment_Settlement_Headers__r.size()==0)
                toBeDelRSDPay.add(del);          
        }
        delete toBeDelRSDPay;
        
        
        
        
    }
    
    
    // initializes all global variables 
    private boolean init(){
        branches =
            [SELECT
             Name,ASI_KOR_Branch_Code__c,ASI_KOR_Branch_Manager__c,ASI_KOR_Region_Code__c
             FROM
             ASI_KOR_Branches__c
            ];
        
        regionBranchCodeMap=new Map<String,Set<String>>();
        // regionMap = new Map<String,Set<String>>();
        for(ASI_KOR_Branches__c branch : branches){
            if(regionBranchCodeMap.containsKey(branch.ASI_KOR_Region_Code__c)){
                // Set<String> temp = regionMap.get(branch.ASI_KOR_Region_Code__c);
                Set<String> temp2 = regionBranchCodeMap.get(branch.ASI_KOR_Region_Code__c);
                // if(!temp.contains(branch.Name)){
                //temp.add(branch.Name);
                // }
                //if(!temp2.contains(branch.ASI_KOR_Branch_Code__c)){
                    temp2.add(branch.ASI_KOR_Branch_Code__c);
                //}
                //regionMap.put(branch.ASI_KOR_Region_Code__c,temp);
                regionBranchCodeMap.put(branch.ASI_KOR_Region_Code__c,temp2);
                
            }else{
                // Set<String> temp = new Set<String>();
                Set<String> temp2 = new Set<String>();
                //temp.add(branch.Name);
                temp2.add(branch.ASI_KOR_Branch_Code__c);
                //regionMap.put(branch.ASI_KOR_Region_Code__c,temp);
                regionBranchCodeMap.put(branch.ASI_KOR_Region_Code__c,temp2);
                
            }
            
        } 
        System.debug('mmaapp:' + String.valueOf(regionBranchCodeMap)); 
        Date selectedDate=Date.newInstance(integer.valueOf(yearProposal), 
                                           integer.valueOf(monthProposal), 
                                           integer.valueOf('01'));
        
		/* [VL 3.1] BEGIN */
		/*
        grouppedBranches = 
            [Select 
             ASI_KOR_Brand__c,ASI_KOR_UOM__c,ASI_KOR_Branch_Code__c
             From 
             ASI_KOR_Incentive_Scheme__c 
             Where 
             ASI_KOR_Effective_End_Date__c >= :selectedDate AND 
             ASI_KOR_Effective_Start_Date__c <= :selectedDate 
             Group By 
             ASI_KOR_Brand__c , ASI_KOR_UOM__c , ASI_KOR_Branch_Code__c
            ];    
        if(grouppedBranches== null || grouppedBranches.size() == 0){
            
            apexpages.message err = 
                new apexpages.message(apexpages.severity.error,
                                      'No valid Incentive Scheme available for the Month & Year chosen.');
            
            apexpages.addmessage(err); 
            
            return false;
            
        }
        
        BranchBrandMap = new Map<String,Set<String>>();
        
        
        for(AggregateResult brand : grouppedBranches){
            if(!BranchBrandMap.containsKey(String.valueOf(brand.get('ASI_KOR_Branch_Code__c')))){
                Set<String> temp = new Set<String>();
                temp.add(String.valueOf(brand.get('ASI_KOR_Brand__c')));  
                BranchBrandMap.put(String.valueOf(brand.get('ASI_KOR_Branch_Code__c')),temp);
                
            }else{
                Set<String> temp = BranchBrandMap.get(String.valueOf(brand.get('ASI_KOR_Branch_Code__c')));
                if(!temp.contains(String.valueOf(brand.get('ASI_KOR_Brand__c')))){
                    temp.add(String.valueOf(brand.get('ASI_KOR_Brand__c')));
                }
                BranchBrandMap.put(String.valueOf(brand.get('ASI_KOR_Branch_Code__c')),temp);
            }
            
        }
		*/
        List<AggregateResult> allICcombination = 
            [SELECT
             ASI_KOR_Brand__c,ASI_KOR_UOM__c
             FROM
             ASI_KOR_Incentive_Scheme__c 
             WHERE
             ASI_KOR_Effective_End_Date__c >= :selectedDate AND 
             ASI_KOR_Effective_Start_Date__c <= :selectedDate 
             GROUP BY
             ASI_KOR_Brand__c , ASI_KOR_UOM__c
            ];    
        if(allICcombination== null || allICcombination.size() == 0){
            
            apexpages.message err = 
                new apexpages.message(apexpages.severity.error,
                                      'No valid Incentive Scheme available for the Month & Year chosen.');
            
            apexpages.addmessage(err); 
            
            return false;
            
        }
        
		grouppedBranches = new List<Wrapper_brandUOMBranch>();
        BranchBrandMap = new Map<String,Set<String>>();
		
		for(AggregateResult brand : allICcombination){
			for (ASI_KOR_Branches__c branch : branches){
				grouppedBranches.add(new Wrapper_brandUOMBranch(String.valueOF(brand.get('ASI_KOR_Brand__c')), String.valueOF(brand.get('ASI_KOR_UOM__c')), branch.ASI_KOR_Branch_Code__c));
			}
		}
        
        
        for(Wrapper_brandUOMBranch brand : grouppedBranches){
            if(!BranchBrandMap.containsKey(brand.branch)){
                Set<String> temp = new Set<String>();
                temp.add(brand.brand);  
                BranchBrandMap.put(brand.branch,temp);
                
            }else{
                Set<String> temp = BranchBrandMap.get(brand.branch);
                if(!temp.contains(brand.brand)){
                    temp.add(brand.brand);
                }
                BranchBrandMap.put(brand.branch,temp);
            }
            
        }
		/* [VL 3.1] END */
        
        System.debug('mmaapp:' + String.valueOf(branchBrandMap)); 
        regionDir = new Map<String,String>(); 
        regions =
            [SELECT
             ASI_KOR_Regional_Sales_Director__c, ASI_KOR_Region_Code__c 
             FROM
             ASI_KOR_Regions__c
            ];
        
        for(ASI_KOR_Regions__c region : regions){
            regionDir.put
                (String.valueOf(region.ASI_KOR_Regional_Sales_Director__c).substring(0,15), region.ASI_KOR_Region_Code__c);
        }
        System.debug('mmaapp:' + String.valueOf(regionDIR)); 
        branchDir = new Map<String,String>(); 
        dirBranch = new Map<String,String>();
        
        
        for(ASI_KOR_Branches__c branch: branches){
            dirBranch.put(branch.ASI_KOR_Branch_Code__c, String.valueOf(branch.ASI_KOR_Branch_Manager__c).substring(0,15));
            branchDir.put( String.valueOf(branch.ASI_KOR_Branch_Manager__c).substring(0,15) ,branch.ASI_KOR_Branch_Code__c);
        }
        System.debug('mmaapp:' + String.valueOf(BranchDIR)); 
        
        // branchNameCodeMap = new Map<String,String>();
        // branchCodeNameMap = new Map<String,String>();
        // for(ASI_KOR_Branches__c branch: branches){
        //branchNameCodeMap.put(branch.Name , branch.ASI_KOR_Branch_Code__c);
        //branchCodeNameMap.put( branch.ASI_KOR_Branch_Code__c ,branch.Name);
        // }
        
        return true;
    }
    
    
    
    /*

Proposal Block


*/
    private List<National> createNSDProposalHeader(){
        List<ASI_KOR_NSD_Proposal_Header__c> headerList = 
            new List<ASI_KOR_NSD_Proposal_Header__c>();
        
        List<ASI_KOR_Nation__c> NSDs = 
            [SELECT 
             ASI_KOR_National_Sales_Director__c 
             FROM 
             ASI_KOR_Nation__c WHERE Name = 'Korea' LIMIT 1
            ];
        
        
        for(ASI_KOR_Nation__c NSD : NSDs){
            List<User> NsdUser= [SELECT DelegatedApproverID FROM User WHERE ID =  :NSD.ASI_KOR_National_Sales_Director__c LIMIT 1];
            ASI_KOR_NSD_Proposal_Header__c NSDPropHead = new ASI_KOR_NSD_Proposal_Header__c();
            NSDPropHead.ASI_KOR_SYS_Cut_off_Date__c = Date.today();
            NSDPropHead.ASI_KOR_Month__c = monthProposal;
            NSDPropHead.ASI_KOR_Year__c = yearProposal;
            NSDPropHead.OwnerID = NSD.ASI_KOR_National_Sales_Director__c;
            NSDPropHead.CurrencyIsoCode = 'KRW';
            NSDPropHead.ASI_KOR_Status__c = 'In Progress';
            //NSDPropHead.ASI_KOR_No_of_Required_Regions__c = regions.size();
            if(NsdUser != null && NsdUser.size()>0){
                NSDPropHead.ASI_KOR_Delegated_Approver__c =  NsdUser.get(0).DelegatedApproverID;
            }
            
            headerList.add(NSDPropHead);
        }
        
        insert headerList;
        List<National> nationalList = new List<National>();
        for(ASI_KOR_NSD_Proposal_Header__c header : headerList){
            National newNation = new National('Korea', header.ID , '' , header.OwnerID);
            nationalList.add(newNation);     
            /* for sharing rule
ASI_KOR_NSD_Proposal_Header__Share shareRecord = new ASI_KOR_NSD_Proposal_Header__Share();
shareRecord.PARENTID = header.ID;    
shareRecord.USERORGROUPID = header.ASI_KOR_Delegated_Approver__c;
shareRecord.AccessLevel = 'Read';

insert shareRecord; */
        }
        
        return nationalList;
    }
    
    private List<Regional> createRSDProposalHeader
        (List<National> NSDProposalHeader){
            /*
List<AggregateResult> branchCount =
[Select
ASI_KOR_Region_Code__c , count(ASI_KOR_Branch_Code__c) BranchCount
From 
ASI_KOR_Branches__c
Group 
By ASI_KOR_Region_Code__c
];

Map<String,Integer> branchSum = new Map<String,Integer>();

for(AggregateResult region : branchCount){     
branchSum.put(String.valueOf(region.get('ASI_KOR_Region_Code__c')),
Integer.valueOf(region.get('BranchCount')));        
}
*/
            
            List<ASI_KOR_RSD_Proposal_Header__c> RSDProposalHeaders = new List<ASI_KOR_RSD_Proposal_Header__c>();
            for(National nation : NSDProposalHeader){
                
                User nsdDelegator = [SELECT email FROM User WHERE ID IN (
                    SELECT ASI_KOR_Delegated_Approver__c FROM ASI_KOR_NSD_Proposal_Header__c WHERE id = :nation.proposalID
                )  LIMIT 1];
                
                for(ASI_KOR_Regions__c region : regions){
                    
                    ASI_KOR_RSD_Proposal_Header__c RSDProp = new ASI_KOR_RSD_Proposal_Header__c();
                    RSDProp.ASI_KOR_Month__c = monthProposal;
                    RSDProp.ASI_KOR_Year__c = yearProposal;
                    /*
if( branchSum.get(region.ASI_KOR_Region_Code__c) == null){
RSDProp.ASI_KOR_No_of_Branches__c = 0;
}else{
RSDProp.ASI_KOR_No_of_Branches__c = branchSum.get(region.ASI_KOR_Region_Code__c);
}
*/
                    RSDProp.ASI_KOR_Status__c = 'Draft'; 
					RSDProp.ASI_KOR_Cut_off_Date__c = cutOffDate; 
                    RSDProp.CurrencyIsoCode  = 'KRW';
                    RSDProp.OwnerID = region.ASI_KOR_Regional_Sales_Director__c;
                    RSDProp.ASI_KOR_NSD_Proposal_Header__c = nation.proposalID;
                    RSDProp.ASI_KOR_SYS_NSD_Delegator_Email__c = nsdDelegator.email;
                    RSDProposalHeaders.add(RSDProp);
                    
                }
            }
            insert RSDProposalHeaders;
            
            List<Regional> regionList = new List<Regional>();
            
            for(ASI_KOR_RSD_Proposal_Header__c RSDProposalHeader : RSDProposalHeaders){
                regionList.add(new Regional('Korea', 
                                            regionDir.get(String.valueOf(RSDProposalHeader.OwnerID).substring(0,15)) , 
                                            RSDProposalHeader.ID ,
                                            '', 
                                            RSDProposalHeader.OwnerID
                                           )
                              );
                System.debug('proposal owner id ' + RSDProposalHeader.OwnerID + '  mapget: '+ regionDir.get(String.valueOf(RSDProposalHeader.OwnerID).substring(0,15))  + ' ' + String.valueOf(RSDProposalHeader.OwnerID).substring(0,15));
            }
            
            return regionList;
        }
    
    private List<Branch> createBMProposalHeader
        (List<Regional> RSDProposalHeader){
            Map<String,Integer> userMap = new Map<String,Integer>();
            List<AggregateResult> userCount = 
                [SELECT
                 ASI_KOR_User_Branch_Code__c, COUNT(ID) countID
                 FROM
                 User 
                 WHERE
                 Title LIKE 'Sales Representative%' AND
                 ASI_KOR_User_Branch_Code__c != NULL
                 GROUP BY ASI_KOR_User_Branch_Code__c
                ];
            for(AggregateResult user : userCount){
                userMap.put(String.valueOf(user.get('ASI_KOR_User_Branch_Code__c')),Integer.valueOf(user.get('countID')));     
            }
            
            List<ASI_KOR_BM_Proposal_Header__c> BMProposalList = new List<ASI_KOR_BM_Proposal_Header__c>();
            for(Regional RSDProp : RSDProposalHeader){
                
                Set<String> branchesSet = regionBranchCodeMap.get(RSDProp.RCode);
                List<String> branchList = new List<String>(branchesSet);
                for(String branch : branchList){
                    ASI_KOR_BM_Proposal_Header__c  BMProposal = new ASI_KOR_BM_Proposal_Header__c();
                    BMProposal.ASI_KOR_RSD_Proposal_Header__c = RSDProp.proposalID;
                    BMProposal.ASI_KOR_Month__c = monthProposal;
                    BMProposal.ASI_KOR_Year__c = yearProposal;
                    BMProposal.ASI_KOR_Status__c = 'Draft';
                    BMProposal.ASI_KOR_No_of_Sales_Representatives__c = userMap.get(branch);
                    BMProposal.ASI_KOR_Cut_off_Date__c = cutOffDate;
                    BMProposal.OwnerID = dirBranch.get(branch);
                    BMProposalList.add(BMProposal);
                } 
                
            }
            insert BMProposalList;
            Map<String,String> branchRegionMap = new Map<String,String>();
            for(ASI_KOR_Branches__c branch : branches){
                branchRegionMap.put(branch.ASI_KOR_Branch_Code__c, branch.ASI_KOR_Region_Code__c);
            }
            List<Branch> branchPropList = new List<Branch>();
            for(ASI_KOR_BM_Proposal_Header__c BMProp : BMProposalList){
                branchPropList.add( 
                    new Branch( 
                        branchRegionMap.get(branchDir.get(String.valueOf(BMProp.OwnerID).substring(0,15))),
                        branchDir.get(String.valueOf(BMProp.OwnerID).substring(0,15)), BMProp.ID , '', BMProp.ownerID)
                );
                
            }
            
            return branchPropList;
        }
    
    private List<NationalByBrand> createNSDProposalByBrand(List<National> NSDProposalHeader){
        
        Date selectedDate=Date.newInstance(integer.valueOf(yearProposal), 
                                           integer.valueOf(monthProposal), 
                                           integer.valueOf('01'));
        
        List<AggregateResult> brands = 
            [SELECT
             ASI_KOR_Brand__c , ASI_KOR_UOM__c
             FROM
             ASI_KOR_Incentive_Scheme__c 
             WHERE
             ASI_KOR_Effective_End_Date__c >= :selectedDate AND 
             ASI_KOR_Effective_Start_Date__c <= :selectedDate 
             GROUP BY
             ASI_KOR_Brand__c , ASI_KOR_UOM__c
            ];
        
        
        List<ASI_KOR_NSD_Proposal_By_Brand__c> byBrandList = new List<ASI_KOR_NSD_Proposal_By_Brand__c>();
        
        
        for(National NSDHeader : NSDProposalHeader){
            for( AggregateResult brand : brands){
                ASI_KOR_NSD_Proposal_By_Brand__c NSDPropByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c();
                NSDPropByBrand.ASI_KOR_Brand__c = String.valueOf(brand.get('ASI_KOR_Brand__c'));
                NSDPropByBrand.ASI_KOR_UOM__c = String.valueOf(brand.get('ASI_KOR_UOM__c'));
                NSDPropByBrand.CreatedByID = NSDHeader.ownerID;
                NSDPropByBrand.ASI_KOR_NSD_Proposal_Header__c = NSDHeader.proposalID;
                byBrandList.add(NSDPropByBrand);
            }
        }
        
        insert byBrandList;
        List<NationalByBrand> nationalList = new List<NationalByBrand>();
        for(ASI_KOR_NSD_Proposal_By_Brand__c byBrand : byBrandList){
            NationalByBrand newNation = new NationalByBrand('Korea', byBrand.ID , '' ,
                                                            byBrand.CreatedByID,byBrand.ASI_KOR_Brand__c, byBrand.ASI_KOR_UOM__c);
            nationalList.add(newNation);     
        }
        
        return nationalList;
        
    }
    
    private List<RegionalByBrand> createRSDProposalByBrand
        (List<Regional> RSDProposal , List <NationalByBrand> NSDProposalByBrand){
            
            List<ASI_KOR_RSD_Proposal_By_Brand__c> RSDPropList = new List<ASI_KOR_RSD_Proposal_By_Brand__c>();
            
            for(Regional RSDProp : RSDProposal){ 
                Set<String> branchSet = regionBranchCodeMap.get(RSDProp.RCode);
                if(branchSet!=null){
                    List<String> branchList = new List<String> (branchSet);
                    
                    for(String branch : branchList){  
                        Set<String> brands = BranchBrandMap.get(branch);
						/* [VL 3.1] BEGIN */
						/*
                        for(AggregateResult ungroupped : grouppedBranches){ 
                            if(brands!=null){
                                if(brands.contains(String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))) && 
                                   branch == String.valueOf(ungroupped.get('ASI_KOR_Branch_Code__c'))){
                                       
                                       ASI_KOR_RSD_Proposal_By_Brand__c  RSDPropBB = new ASI_KOR_RSD_Proposal_By_Brand__c();
                                       RSDPropBB.ASI_KOR_Brand__c = String.valueOf(ungroupped.get('ASI_KOR_Brand__c'));
                                       RSDPropBB.OwnerID =RSDProp.ownerID;
                                       
                                       for(NationalByBrand NSDPropBB : NSDProposalByBrand){
                                           
                                           if(NSDPropBB.brandID == String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))&& 
                                              NSDPropBB.UOM == String.valueOf(ungroupped.get('ASI_KOR_UOM__c'))){
                                                  RSDPropBB.ASI_KOR_NSD_Proposal_By_Brand__c = NSDPropBB.proposalID;
                                              }
                                           
                                       }
                                       //test further later, handled as skip loop if no proper brand found.
                                       if(RSDPropBB.ASI_KOR_NSD_Proposal_By_Brand__c == null) continue;
                                       
                                       RSDPropBB.ASI_KOR_RSD_Proposal_Header__c= RSDProp.proposalID;
                                       RSDPropBB.ASI_KOR_UOM__c = String.valueOf(ungroupped.get('ASI_KOR_UOM__c')); 
                                       
                                       RSDPropList.add(RSDPropBB);   
                                       
                                   }
                            }
                            
                        }
						*/
                        for(Wrapper_brandUOMBranch ungroupped : grouppedBranches){ 
                            if(brands!=null){
                                if(brands.contains(ungroupped.brand) && 
                                   branch == ungroupped.branch){
                                       
                                       ASI_KOR_RSD_Proposal_By_Brand__c  RSDPropBB = new ASI_KOR_RSD_Proposal_By_Brand__c();
                                       RSDPropBB.ASI_KOR_Brand__c = ungroupped.brand;
                                       RSDPropBB.OwnerID =RSDProp.ownerID;
                                       
                                       for(NationalByBrand NSDPropBB : NSDProposalByBrand){
                                           
                                           if(NSDPropBB.brandID == ungroupped.brand && 
                                              NSDPropBB.UOM == ungroupped.UOM){
                                                  RSDPropBB.ASI_KOR_NSD_Proposal_By_Brand__c = NSDPropBB.proposalID;
                                              }
                                           
                                       }
                                       //test further later, handled as skip loop if no proper brand found.
                                       if(RSDPropBB.ASI_KOR_NSD_Proposal_By_Brand__c == null) continue;
                                       
                                       RSDPropBB.ASI_KOR_RSD_Proposal_Header__c= RSDProp.proposalID;
                                       RSDPropBB.ASI_KOR_UOM__c = ungroupped.UOM; 
                                       
                                       RSDPropList.add(RSDPropBB);   
                                       
                                   }
                            }
                            
                        }
						/* [VL 3.1] END */
                    }
                }
                
            }
            
            // removes duplicated records created above
            List<Integer> removeList = new List<Integer>();
            Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
            for(integer i = 0 ; i < RSDPropList.size(); i++){
                
                if(tempMap.containsKey(RSDPropList.get(i).ASI_KOR_RSD_Proposal_Header__c)){
                    
                    Set<String> tempSet =  tempMap.get(RSDPropList.get(i).ASI_KOR_RSD_Proposal_Header__c);
                    String tempString = RSDPropList.get(i).ASI_KOR_Brand__c + RSDPropList.get(i).ASI_KOR_UOM__c;
                    if(tempSet.contains(tempString)){
                        removeList.add(i);
                    }else{
                        tempSet.add(tempString);
                        tempMap.put(RSDPropList.get(i).ASI_KOR_RSD_Proposal_Header__c,tempSet);
                    }
                    
                }else{
                    Set<String> tempSet = new Set<String>();
                    tempSet.add(RSDPropList.get(i).ASI_KOR_Brand__c + RSDPropList.get(i).ASI_KOR_UOM__c);
                    tempMap.put(RSDPropList.get(i).ASI_KOR_RSD_Proposal_Header__c,tempSet);
                }
                
            }
            
            for(integer i = 0 ; i < removeList.size(); i++){
                RSDPropList.remove(removeList.get(i));
                for(integer k = i+1 ; k <removeList.size() ; k++){ 
                    if(removeList.get(k)> removeList.get(i)){
                        integer temp = removeList.get(k)-1;
                        removeList.set(k , temp);
                    }      
                }
            }
            
            System.debug('Debug Log : ' + RSDPropList);
            insert RSDPropList;
            
            List<RegionalByBrand> regionalList = new List<RegionalByBrand>();
            for(ASI_KOR_RSD_Proposal_By_Brand__c RSDProp : RSDPropList){
                regionalList.add(new RegionalByBrand('Korea',
                                                     regionDir.get(String.valueOf(RSDProp.OwnerID).substring(0,15)), 
                                                     RSDProp.ID , 
                                                     '' ,
                                                     RSDProp.OwnerID, 
                                                     RSDProp.ASI_KOR_Brand__c, 
                                                     RSDProp.ASI_KOR_UOM__c
                                                    ));
            }
            
            return regionalList;
        }
    
    
    private List<BranchByBrand> createBMProposalByBrand
        (List<Branch> BMProposal , List<RegionalByBrand> RSDProposalByBrand){
            
            List<ASI_KOR_BM_Proposal_By_Brand__c> BMPropBBList = new List<ASI_KOR_BM_Proposal_By_Brand__c>();
            for(Branch BMProp : BMProposal){
                Set<String> brands = BranchBrandMap.get(BMProp.BCode);
				/* [VL 3.1] BEGIN */
				/*
                for(AggregateResult ungroupped : grouppedBranches){
                    if(brands!=null){
                        if(brands.contains(String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))) && 
                           BMProp.BCode == ungroupped.get('ASI_KOR_Branch_Code__c')){
                               
                               ASI_KOR_BM_Proposal_By_Brand__c  BMPropBB = new ASI_KOR_BM_Proposal_By_Brand__c();
                               BMPropBB.ASI_KOR_Brand__c = String.valueOf(ungroupped.get('ASI_KOR_Brand__c'));
                               BMPropBB.CreatedByID =BMProp.ownerID;
                               
                               for(RegionalByBrand RSDPropBB : RSDProposalByBrand){
                                   
                                   if(RSDPropBB.brandID == String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))&& 
                                      RSDPropBB.UOM == String.valueOf(ungroupped.get('ASI_KOR_UOM__c'))){
                                          
                                          if((regionBranchCodeMap.get(RSDPropBB.RCode)).contains(branchDir.get(String.valueOf(BMProp.OwnerID).substring(0,15)))) 
                                              BMPropBB.ASI_KOR_RSD_Proposal_By_Brand__c = RSDPropBB.proposalID;
                                      }
                                   
                               }
                               
                               BMPropBB.ASI_KOR_BM_Proposal_Header__c= BMProp.proposalID;
                               BMPropBB.ASI_KOR_UOM__c = String.valueOf(ungroupped.get('ASI_KOR_UOM__c')); 
                               
                               BMPropBBList.add(BMPropBB);                              
                           }
                    }
                    
                }  
				*/
                for(Wrapper_brandUOMBranch ungroupped : grouppedBranches){
                    if(brands!=null){
                        if(brands.contains(ungroupped.brand) && 
                           BMProp.BCode == ungroupped.branch){
                               
                               ASI_KOR_BM_Proposal_By_Brand__c  BMPropBB = new ASI_KOR_BM_Proposal_By_Brand__c();
                               BMPropBB.ASI_KOR_Brand__c = ungroupped.brand;
                               BMPropBB.CreatedByID =BMProp.ownerID;
                               
                               for(RegionalByBrand RSDPropBB : RSDProposalByBrand){
                                   
                                   if(RSDPropBB.brandID == ungroupped.brand && 
                                      RSDPropBB.UOM == ungroupped.UOM){
                                          
                                          if((regionBranchCodeMap.get(RSDPropBB.RCode)).contains(branchDir.get(String.valueOf(BMProp.OwnerID).substring(0,15)))) 
                                              BMPropBB.ASI_KOR_RSD_Proposal_By_Brand__c = RSDPropBB.proposalID;
                                      }
                                   
                               }
                               
                               BMPropBB.ASI_KOR_BM_Proposal_Header__c= BMProp.proposalID;
                               BMPropBB.ASI_KOR_UOM__c = ungroupped.UOM; 
                               
                               BMPropBBList.add(BMPropBB);                              
                           }
                    }
                    
                }  
				/* [VL 3.1] END */        
                
            }
            
            insert BMPropBBList;
            
            return null;
            
            
        }
    
    
    /*

Payment Settlement Block


*/     
    private List<National> createNSDPaymentSettlementHeader(){
        
        List<ASI_KOR_NSD_Payment_Settlement_Header__c> headerList = new List<ASI_KOR_NSD_Payment_Settlement_Header__c>();
        List<ASI_KOR_Nation__c> NSDs = [SELECT ASI_KOR_National_Sales_Director__c FROM ASI_KOR_Nation__c WHERE Name = 'Korea' LIMIT 1];
        
        
        for(ASI_KOR_Nation__c NSD : NSDs){
            List<User> NsdUser= [SELECT DelegatedApproverID FROM User WHERE ID =  :NSD.ASI_KOR_National_Sales_Director__c LIMIT 1];
            
            ASI_KOR_NSD_Payment_Settlement_Header__c NSDPayHead = new ASI_KOR_NSD_Payment_Settlement_Header__c(); 
            NSDPayHead.ASI_KOR_Month__c = monthProposal;
            NSDPayHead.ASI_KOR_Year__c = yearProposal;
            NSDPayHead.OwnerID = NSD.ASI_KOR_National_Sales_Director__c;
            NSDPayHead.CurrencyIsoCode = 'KRW';
            NSDPayHead.ASI_KOR_Status__c = 'Draft';
            //NSDPayHead.ASI_KOR_No_of_Regions__c = regions.size();
            if(NsdUser != null && NsdUser.size()>0){
                NSDPayHead.ASI_KOR_Delegated_Approver__c =  NsdUser.get(0).DelegatedApproverID;
            }
            headerList.add(NSDPayHead);
        }
        
        insert headerList;
        List<National> nationalList = new List<National>();
        for(ASI_KOR_NSD_Payment_Settlement_Header__c header : headerList){
            National newNation = new National('Korea','', header.ID , header.OwnerID);
            nationalList.add(newNation);    
            /* for sharing rule
ASI_KOR_NSD_Payment_Settlement_Header__Share shareRecord = new ASI_KOR_NSD_Payment_Settlement_Header__Share();
shareRecord.PARENTID = header.ID;    
shareRecord.USERORGROUPID = header.ASI_KOR_Delegated_Approver__c;
shareRecord.AccessLevel = 'Read';

insert shareRecord;  */
        }
        
        return nationalList;
    }
    
    private List<Regional> createRSDPaymentSettlementHeader
        (List<National> NSDPaymentSettlement){
            /*
List<AggregateResult> branchCount =
[Select
ASI_KOR_Region_Code__c , count(ASI_KOR_Branch_Code__c) BranchCount
From 
ASI_KOR_Branches__c
Group 
By ASI_KOR_Region_Code__c
];

Map<String,Integer> branchSum = new Map<String,Integer>();

for(AggregateResult region : branchCount){     
branchSum.put(String.valueOf(region.get('ASI_KOR_Region_Code__c')), Integer.valueOf(region.get('BranchCount')));        
}
*/
            List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPaySetHeaders = new List<ASI_KOR_RSD_Payment_Settlement_Header__c>();
            System.debug('Debug Log : ' + NSDPaymentSettlement);
            for(National nation : NSDPaymentSettlement){
                
                User nsdDelegator = [SELECT email FROM User WHERE ID IN (
                    SELECT ASI_KOR_Delegated_Approver__c FROM ASI_KOR_NSD_Payment_Settlement_Header__c WHERE id = :nation.paymentSettlementID
                )  LIMIT 1];
                
                for(ASI_KOR_Regions__c region : regions){
                    
                    ASI_KOR_RSD_Payment_Settlement_Header__c RSDPay = new ASI_KOR_RSD_Payment_Settlement_Header__c();
                    RSDPay.ASI_KOR_Month__c = monthProposal;
                    RSDPay.ASI_KOR_Year__c = yearProposal;
                    /*if( branchSum.get(region.ASI_KOR_Region_Code__c) == null){
RSDPay.ASI_KOR_No_of_Branches__c = 0;
}else{
RSDPay.ASI_KOR_No_of_Branches__c = branchSum.get(region.ASI_KOR_Region_Code__c);
}*/
                    RSDPay.ASI_KOR_Status__c = 'Draft'; 
                    RSDPay.CurrencyIsoCode  = 'KRW';
                    RSDPay.OwnerID = region.ASI_KOR_Regional_Sales_Director__c;
                    RSDPay.ASI_KOR_NSD_Payment_Settlement__c = nation.paymentSettlementID;
                    RSDPay.ASI_KOR_SYS_NSD_Delegator_Email__c = nsdDelegator.email;
                    RSDPaySetHeaders.add(RSDPay);
                    
                }
            }
            insert RSDPaySetHeaders;
            
            List<Regional> regionList = new List<Regional>();
            
            for(ASI_KOR_RSD_Payment_Settlement_Header__c RSDPayHeader : RSDPaySetHeaders){
                regionList.add(new Regional('Korea', 
                                            regionDir.get(String.valueOf(RSDPayHeader.OwnerID).substring(0,15)) , 
                                            '' , 
                                            RSDPayHeader.ID, 
                                            RSDPayHeader.OwnerID
                                           ));
                
            }
            return regionList;
            
        }  
    
    private List<Branch> createBMPaymentSettlementHeader
        (List<Regional> RSDPaymentSettlement){
            
            Map<String,Integer> userMap = new Map<String,Integer>();
            List<AggregateResult> userCount = 
                [SELECT
                 ASI_KOR_User_Branch_Code__c, COUNT(ID) countID
                 FROM
                 User 
                 WHERE
                 Title LIKE 'Sales Representative%' AND
                 ASI_KOR_User_Branch_Code__c != NULL
                 GROUP BY ASI_KOR_User_Branch_Code__c
                ];
            for(AggregateResult user : userCount){
                userMap.put(String.valueOf(user.get('ASI_KOR_User_Branch_Code__c')),Integer.valueOf(user.get('countID')));     
            }
            
            List<ASI_KOR_BM_Payment_Settlement_Header__c> BMPaymentSettlementList = new List<ASI_KOR_BM_Payment_Settlement_Header__c>();
            for(Regional RSDPay : RSDPaymentSettlement){
                
                Set<String> branchesSet = regionBranchCodeMap.get(RSDPay.RCode);
                List<String> branchList = new List<String>(branchesSet);
                for(String branch : branchList){
                    ASI_KOR_BM_Payment_Settlement_Header__c  BMPaymentSettlement = new ASI_KOR_BM_Payment_Settlement_Header__c();
                    BMPaymentSettlement.ASI_KOR_RSD_Payment_Settlement__c = RSDPay.paymentSettlementID;
                    BMPaymentSettlement.ASI_KOR_Month__c= monthProposal;
                    BMPaymentSettlement.ASI_KOR_Year__c= yearProposal;
                    BMPaymentSettlement.ASI_KOR_Status__c = 'Draft';
                    BMPaymentSettlement.ASI_KOR_No_of_Sales_Representatives__c = userMap.get(branch);
                    BMPaymentSettlement.OwnerID = dirBranch.get(branch);
                    BMPaymentSettlementList.add(BMPaymentSettlement);
                } 
                
            }
            insert BMPaymentSettlementList;
            Map<String,String> branchRegionMap = new Map<String,String>();
            for(ASI_KOR_Branches__c branch : branches){
                branchRegionMap.put(branch.ASI_KOR_Branch_Code__c, branch.ASI_KOR_Region_Code__c);
            }
            List<Branch> branchPayList = new List<Branch>();
            for(ASI_KOR_BM_Payment_Settlement_Header__c BMPay : BMPaymentSettlementList){
                branchPayList.add( 
                    new Branch( 
                        branchRegionMap.get(branchDir.get(String.valueOf(BMPay.OwnerID).substring(0,15))),
                        branchDir.get(String.valueOf(BMPay.OwnerID).substring(0,15)), '' , BMPay.ID, BMPay.ownerID)
                );
                
            }
            
            return branchPayList;
        } 
    
    
    private List<NationalByBrand> createNSDPaymentSettlementByBrand(List<National> NSDPaymentSettlement){
        
        Date selectedDate=Date.newInstance(integer.valueOf(yearProposal), 
                                           integer.valueOf(monthProposal), 
                                           integer.valueOf('01'));
        
        
        List<AggregateResult> brands = 
            [SELECT
             ASI_KOR_Brand__c , ASI_KOR_UOM__c
             FROM
             ASI_KOR_Incentive_Scheme__c 
             WHERE
             ASI_KOR_Effective_End_Date__c >= :selectedDate AND 
             ASI_KOR_Effective_Start_Date__c <= :selectedDate 
             GROUP BY
             ASI_KOR_Brand__c , ASI_KOR_UOM__c
            ];
        
        List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> byBrandList = new List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c>();
        
        
        for(National NSDPay : NSDPaymentSettlement){
            for( AggregateResult brand : brands){
                ASI_KOR_NSD_Payment_Settlement_By_Brand__c NSDPayByBrand = new ASI_KOR_NSD_Payment_Settlement_By_Brand__c();
                NSDPayByBrand.ASI_KOR_Brand__c = String.valueOf(brand.get('ASI_KOR_Brand__c'));
                NSDPayByBrand.ASI_KOR_UOM__c = String.valueOf(brand.get('ASI_KOR_UOM__c'));
                NSDPayByBrand.CreatedByID = NSDPay.ownerID;
                NSDPayByBrand.ASI_KOR_NSD_Payment_Settlement_Header__c = NSDPay.paymentSettlementID;
                byBrandList.add(NSDPayByBrand);
            }
        }
        
        insert byBrandList;
        List<NationalByBrand> nationalList = new List<NationalByBrand>();
        for(ASI_KOR_NSD_Payment_Settlement_By_Brand__c byBrand : byBrandList){
            NationalByBrand newNation = new NationalByBrand('Korea',
                                                            '' , 
                                                            byBrand.ID , 
                                                            byBrand.CreatedByID, 
                                                            byBrand.ASI_KOR_Brand__c, 
                                                            byBrand.ASI_KOR_UOM__c
                                                           );
            nationalList.add(newNation);     
        }
        
        return nationalList;
    }
    
    private List<RegionalByBrand> createRSDPaymentSettlementByBrand
        (List<Regional> RSDPaymentSettlement, List<NationalByBrand> NSDPaymentSettlementByBrand){
            
            List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> RSDPaySetList = new List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>();
            
            for(Regional RSDPay : RSDPaymentSettlement){
                Set<String> branchSet = regionBranchCodeMap.get(RSDPay.RCode);
                if(branchSet!=null){
                    List<String> branchList = new List<String> (branchSet);
                    for(String branch : branchList){
                        Set<String> brands = BranchBrandMap.get(branch);
						/* [VL 3.1] BEGIN */
						/*
                        for(AggregateResult ungroupped : grouppedBranches){
                            if(brands!=null){
                                if(brands.contains(String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))) && 
                                   branch == String.valueOf(ungroupped.get('ASI_KOR_Branch_Code__c'))){
                                       
                                       ASI_KOR_RSD_Payment_Settlement_By_Brand__c  RSDPaySetBB = new ASI_KOR_RSD_Payment_Settlement_By_Brand__c();
                                       RSDPaySetBB.ASI_KOR_Brand__c = String.valueOf(ungroupped.get('ASI_KOR_Brand__c'));
                                       RSDPaySetBB.OwnerID =RSDPay.ownerID;
                                       
                                       for(NationalByBrand NSDPaySetBB :  NSDPaymentSettlementByBrand){
                                           
                                           if(NSDPaySetBB.brandID == String.valueOf(ungroupped.get('ASI_KOR_Brand__c')) && 
                                              NSDPaySetBB.UOM == String.valueOf(ungroupped.get('ASI_KOR_UOM__c'))){
                                                  RSDPaySetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c = NSDPaySetBB.paymentSettlementID;
                                              }
                                           
                                       }
                                       //test further later, handled as skip loop if no proper brand found.
                                       if(RSDPaySetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c == null) continue;
                                       RSDPaySetBB.ASI_KOR_RSD_Payment_Settlement__c= RSDPay.paymentSettlementID;
                                       RSDPaySetBB.ASI_KOR_UOM__c = String.valueOf(ungroupped.get('ASI_KOR_UOM__c')); 
                                       
                                       RSDPaySetList.add(RSDPaySetBB);                              
                                   }
                            }
                            
                        }
						*/
                        for(Wrapper_brandUOMBranch ungroupped : grouppedBranches){
                            if(brands!=null){
                                if(brands.contains(ungroupped.brand) && 
                                   branch == ungroupped.branch){
                                       
                                       ASI_KOR_RSD_Payment_Settlement_By_Brand__c  RSDPaySetBB = new ASI_KOR_RSD_Payment_Settlement_By_Brand__c();
                                       RSDPaySetBB.ASI_KOR_Brand__c = ungroupped.brand;
                                       RSDPaySetBB.OwnerID =RSDPay.ownerID;
                                       
                                       for(NationalByBrand NSDPaySetBB :  NSDPaymentSettlementByBrand){
                                           
                                           if(NSDPaySetBB.brandID == ungroupped.brand && 
                                              NSDPaySetBB.UOM == ungroupped.UOM){
                                                  RSDPaySetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c = NSDPaySetBB.paymentSettlementID;
                                              }
                                           
                                       }
                                       //test further later, handled as skip loop if no proper brand found.
                                       if(RSDPaySetBB.ASI_KOR_NSD_Payment_Settlement_By_Brand__c == null) continue;
                                       RSDPaySetBB.ASI_KOR_RSD_Payment_Settlement__c= RSDPay.paymentSettlementID;
                                       RSDPaySetBB.ASI_KOR_UOM__c = ungroupped.UOM; 
                                       
                                       RSDPaySetList.add(RSDPaySetBB);                              
                                   }
                            }
                            
                        }
						/* [VL 3.1] END */
                    }
                }
                
            }
            
            //removes duplicated records
            List<Integer> removeList = new List<Integer>();
            Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
            for(integer i = 0 ; i < RSDPaySetList.size(); i++){
                
                if(tempMap.containsKey(RSDPaySetList.get(i).ASI_KOR_RSD_Payment_Settlement__c)){
                    
                    Set<String> tempSet =  tempMap.get(RSDPaySetList.get(i).ASI_KOR_RSD_Payment_Settlement__c);
                    String tempString = RSDPaySetList.get(i).ASI_KOR_Brand__c + RSDPaySetList.get(i).ASI_KOR_UOM__c;
                    if(tempSet.contains(tempString)){
                        removeList.add(i);
                    }else{
                        tempSet.add(tempString);
                        tempMap.put(RSDPaySetList.get(i).ASI_KOR_RSD_Payment_Settlement__c,tempSet);
                    }
                    
                }else{
                    Set<String> tempSet = new Set<String>();
                    tempSet.add(RSDPaySetList.get(i).ASI_KOR_Brand__c + RSDPaySetList.get(i).ASI_KOR_UOM__c);
                    tempMap.put(RSDPaySetList.get(i).ASI_KOR_RSD_Payment_Settlement__c,tempSet);
                }
                
            }
            
            for(integer i = 0 ; i < removeList.size(); i++){
                RSDPaySetList.remove(removeList.get(i));
                for(integer k = i+1 ; k <removeList.size() ; k++){
                    if(removeList.get(k)> removeList.get(i)){
                        integer temp = removeList.get(k)-1;
                        removeList.set(k , temp);
                    }     
                    
                }
            }
            
            
            insert RSDPaySetList;
            
            
            List<RegionalByBrand> regionalList = new List<RegionalByBrand>();
            for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c RSDPay: RSDPaySetList){
                regionalList.add(new RegionalByBrand('Korea',
                                                     regionDir.get(String.valueOf(RSDPay.OwnerID).substring(0,15)), 
                                                     '' , 
                                                     RSDPay.ID ,
                                                     RSDPay.OwnerID, 
                                                     RSDPay.ASI_KOR_Brand__c, 
                                                     RSDPay.ASI_KOR_UOM__c
                                                    ));
            }
            return regionalList;
        }  
    
    private List<BranchByBrand> createBMPaymentSettlementByBrand
        (List<Branch> BMPaymentSettlementList, List<RegionalByBrand> RSDPaymentSettlementByBrand){
            List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> BMPayBBList = new List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>();
            for(Branch BMPay : BMPaymentSettlementList){
                Set<String> brands = BranchBrandMap.get(BMPay.BCode);
				/* [VL 3.1] BEGIN */
				/*
                for(AggregateResult ungroupped : grouppedBranches){
                    if(brands!=null){
                        if(brands.contains(String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))) && 
                           BMPay.BCode == String.valueOf(ungroupped.get('ASI_KOR_Branch_Code__c'))){
                               ASI_KOR_BM_Payment_Settlement_By_Brand__c  BMPayBB = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();
                               BMPayBB.ASI_KOR_Brand__c = String.valueOf(ungroupped.get('ASI_KOR_Brand__c'));
                               BMPayBB.CreatedByID =BMPay.ownerID;
                               for(RegionalByBrand RSDPayBB : RSDPaymentSettlementByBrand){
                                   if(RSDPayBB.brandID == String.valueOf(ungroupped.get('ASI_KOR_Brand__c'))&& 
                                      RSDPayBB.UOM == String.valueOf(ungroupped.get('ASI_KOR_UOM__c'))){
                                          if((regionBranchCodeMap.get(RSDPayBB.RCode)).contains(branchDir.get(String.valueOf(BMPay.OwnerID).substring(0,15))))
                                              BMPayBB.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = RSDPayBB.paymentSettlementID;
                                      }
                                   
                               }
                               
                               BMPayBB.ASI_KOR_BM_Payment_Settlement__c= BMPay.paymentSettlementID;
                               BMPayBB.ASI_KOR_UOM__c = String.valueOf(ungroupped.get('ASI_KOR_UOM__c')); 
                               
                               BMPayBBList.add(BMPayBB);                              
                           }
                    }
                    
                }  
				*/
                for(Wrapper_brandUOMBranch ungroupped : grouppedBranches){
                    if(brands!=null){
                        if(brands.contains(ungroupped.brand) && 
                           BMPay.BCode == ungroupped.branch){
                               ASI_KOR_BM_Payment_Settlement_By_Brand__c  BMPayBB = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();
                               BMPayBB.ASI_KOR_Brand__c = ungroupped.brand;
                               BMPayBB.CreatedByID =BMPay.ownerID;
                               for(RegionalByBrand RSDPayBB : RSDPaymentSettlementByBrand){
                                   if(RSDPayBB.brandID == ungroupped.brand && 
                                      RSDPayBB.UOM == ungroupped.UOM){
                                          if((regionBranchCodeMap.get(RSDPayBB.RCode)).contains(branchDir.get(String.valueOf(BMPay.OwnerID).substring(0,15))))
                                              BMPayBB.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = RSDPayBB.paymentSettlementID;
                                      }
                                   
                               }
                               
                               BMPayBB.ASI_KOR_BM_Payment_Settlement__c= BMPay.paymentSettlementID;
                               BMPayBB.ASI_KOR_UOM__c = ungroupped.UOM; 
                               
                               BMPayBBList.add(BMPayBB);                              
                           }
                    }
                    
                }  
				/* [VL 3.1] END */
                
                
                
            }     
            insert BMPayBBList;
            
            return null;
        } 
    
    
    //Sending alert Email after proposal kickstart
    public void sendProposalNotificationEmail(List<String> UserIDs){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<User> recepients = [SELECT Name , email FROM User WHERE ID IN :UserIDs ];
        List<String> toAddresses = new List<String>();
        for(User recepient : recepients ){
            
            toAddresses.add(recepient.email);
            
        }
        toAddresses.add('prasia.mobile@pernod-ricard.com');
        mail.setToAddresses(toAddresses);
        //Mailing Subject
		/* [VL 3.0] BEGIN */
		/*
        String mailingSubject = 'Trade Spend Cycle Start Notification – Proposal';
		*/
        String mailingSubject = 'Trade Spend Cycle Start Notification – Sales Planning';
		/* [VL 3.0] END */
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        
		/* [VL 3.0] BEGIN */
		/*
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Proposal'+'\r\n\r\n';
		*/
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Sales Planning'+'\r\n\r\n';
		/* [VL 3.0] END */
        
        mailingMessage  += 'Year: '  + yearProposal+ '\r\n';
        mailingMessage  += 'Month: '  + monthProposal +  '\r\n';
        mailingMessage  += 'Cut-off Date: '  + cutOffDate.year()+ '-' + cutOffDate.month() + '-' + cutOffDate.day()+  '\r\n\r\n';
        mailingMessage  += 'Monthly CA budget have been uploaded into the system for each Sales branch.'+  '\r\n';
		/* [VL 3.0] BEGIN */
		/*
        mailingMessage  += 'Now you can start your process for CA proposal.'+  '\r\n\r\n';
		*/
        mailingMessage  += 'Now you can start your process for Sales Planning.'+  '\r\n\r\n';
		/* [VL 3.0] END */
        mailingMessage  += 'Thanks.'+  '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
        
    }
    
    
    //Sending alert Email after PaymentSettlement kickstart
    public void sendPaymentSettlementNotificationEmail(List<String> UserIDs, string region){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //get user email addresss from its ID
        List<User> recepients = [SELECT Name , email FROM User WHERE ID IN :UserIDs ];
        List<String> toAddresses = new List<String>();
        for(User recepient : recepients ){
            
            toAddresses.add(recepient.email);
            
        }
        system.debug('toAddresses');
        system.debug(toAddresses);
        toAddresses.add('prasia.mobile@pernod-ricard.com');
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = 'Trade Spend Cycle Start Notification – Payment Settlement - '+region;
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Payment Settlement'+'\r\n\r\n';
        
        mailingMessage  += 'Region: '  + region+ '\r\n';
        mailingMessage  += 'Year: '  + yearPaymentSettlement+ '\r\n';
        mailingMessage  += 'Month: '  + monthPaymentSettlement +  '\r\n';
        mailingMessage  += 'Cut-off Date: '  + cutOffDatePayment.year()+ '-' + cutOffDatePayment.month() + '-' + cutOffDatePayment.day()+  '\r\n\r\n';
        //          mailingMessage  += 'Monthly CA budget have been uploaded into the system for each Sales branch.'+  '\r\n';
        mailingMessage  += 'Now you can start your process for CA Payment Settlement.'+  '\r\n\r\n';
        mailingMessage  += 'Thanks.'+  '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
        
    }
    
	/* [VL 4.0] BEGIN */
    public void startKeymanAllocation(){
    /*
        List<String> users = new List<String>();
        
		List<ASI_KOR_NSD_Payment_Settlement_Header__c> NSDPaySet =
			[Select 
			 ID , ASI_KOR_SYS_Cut_off_Date__c, ASI_KOR_Delegated_Approver__c 
			 From 
			 ASI_KOR_NSD_Payment_Settlement_Header__c 
			 Where 
			 ASI_KOR_Month__c= :monthKeyman AND 
			 ASI_KOR_Year__c = :yearKeyman 
			 Limit 1
			];
		
		List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPaySet =
			[Select 
			 ID , OwnerId , ASI_KOR_Keyman_Allocation_Date__c, ASI_KOR_Status__c
			 From 
			 ASI_KOR_RSD_Payment_Settlement_Header__c 
			 Where 
			 ASI_KOR_Month__c= :monthKeyman AND 
			 ASI_KOR_Year__c = :yearKeyman  AND
			 ASI_KOR_Region__c = :regionKeyman 
			 limit 1
			];
		
		List<ASI_KOR_VMS_Interface_File__c> vmsInterfaceFile =
			[Select 
			 ID 
			 From 
			 ASI_KOR_VMS_Interface_File__c 
			 Where 
			 ASI_KOR_Promotion_Month__c = :monthKeyman AND 
			 ASI_KOR_Promotion_Year__c = :yearKeyman  
			 limit 1
			];
		
		if(NSDPaySet != null && NSDPaySet.size()!=0){
			
			if(RSDPaySet != null && RSDPaySet.size()!=0){
				if(RSDPaySet.get(0).ASI_KOR_Status__c != 'Approved by NSD'){
					apexpages.message err = new apexpages.message(apexpages.severity.error, ' Payment Settlement is not approved by NSD yet, Please try again later');
					apexpages.addmessage(err);   
					return;            
				}
				if(vmsInterfaceFile.size()==0){
					apexpages.message err = new apexpages.message(apexpages.severity.error, ' The keyman allocation records have not been created by ETL, please contact IT.');
					apexpages.addmessage(err);   
					return;            
				}
				if(RSDPaySet.get(0).ASI_KOR_Keyman_Allocation_Date__c != null){
					apexpages.message err = new apexpages.message(apexpages.severity.error, 'Keyman Allocation for '+ yearKeyman + '-' + monthKeyman + ' exist in database.');
					apexpages.addmessage(err);   
					return;                   
				}
				RSDPaySet.get(0).ASI_KOR_Keyman_Allocation_Date__c  = cutOffDateKeyman;
				update RSDPaySet.get(0);
				
				
				List<ASI_KOR_BM_Payment_Settlement_Header__c> BMPaySet =
					[Select 
					 ID , OwnerId, ASI_KOR_Cut_off_Date__c, ASI_KOR_SYS_Branch_Code__c
					 From 
					 ASI_KOR_BM_Payment_Settlement_Header__c 
					 Where 
					 ASI_KOR_RSD_Payment_Settlement__c = :RSDPaySet.get(0).id
					];
				
				if (BMPaySet.size()>0){
					set<string> approvedBM = new set<string>();
					for (ASI_KOR_BM_Payment_Settlement_Header__c bm : BMPaySet){
						approvedBM.add(bm.id);
						users.add(bm.ownerid);
					}
					
					for(ASI_KOR_SR_Payment_Settlement_Header__c sr :
						[Select 
						 ID , OwnerId
						 From 
						 ASI_KOR_SR_Payment_Settlement_Header__c 
						 Where 
						 ASI_KOR_BM_Payment_Settlement_Header__c in :approvedBM AND
						 ASI_KOR_Status__c = 'Approved by BM'
						]){
							users.add(sr.ownerid);
						}
				}
				
				ASI_KOR_KeymanAllocationBatch keymanAllocationJob = 
					new  ASI_KOR_KeymanAllocationBatch(yearKeyman,monthKeyman, regionKeyman);
				Database.executeBatch(keymanAllocationJob,200);
				
				status = 'Trade Spend Cycle (Keyman Allocation) for '+ yearKeyman + '-' + monthKeyman +' is being calculated.'+
					' Email notifications will be sent once data are ready. ';
				
				//put user information into a list to send notification email                    
				for(ASI_KOR_NSD_Payment_Settlement_Header__c user : NSDPaySet){ 
					users.add(user.ASI_KOR_Delegated_Approver__c);
				}
				for(ASI_KOR_RSD_Payment_Settlement_Header__c user : RSDPaySet){ 
					users.add(user.OwnerID);
				}
				
				//get all user id from the profileid - ASI KOR Business Dev Admin (00eD0000001AneO)             
				List<User> tmktUser = [select firstname, lastname, id from user where profileid in (select id from profile where name = 'ASI KOR Business Dev Admin')];       
				
				system.debug('TMKT');
				system.debug(tmktUser);
				
				for(User tmkt : tmktUser){
					users.add(tmkt.ID);
				}
				
				List<List<String>> usersList = new List<List<String>>(); 
				integer count = 0 ;
				List<String> tempList; 
				
				for(String user : users){             
					if(count == 0){
						tempList = new List<String>();
						tempList.add(user);
						count++;
					}else if( count <20 && count >0){
						tempList.add(user);
						count++;
					}else{
						tempList.add(user);
						usersList.add(tempList);
						tempList = new list<string>();
						count=0;
					}  
				}
				
				if(tempList.size() >0){
					usersList.add(tempList);
				}
				//send notification email to user               
				for(List<String> mailUser : usersList){
					try{
						sendKeymanEmail(mailUser, regionKeyman);      
					}catch(Exception e){
						apexpages.message err = 
							new apexpages.message(apexpages.severity.error, 
												  e.getMessage());
						apexpages.addmessage(err); 
					}
				}				        
				return;
				
			}else{
				apexpages.message err = new apexpages.message(apexpages.severity.error, 'Invalid Region or Region selected is not ready to start Keyman Allocation');
				apexpages.addmessage(err);   
				return;  
			}
		}else{
			apexpages.message err = new apexpages.message(apexpages.severity.error, 'Headers for the Month & Year selected is not ready at the mean time.');
			apexpages.addmessage(err);  
			return;  
		}
*/
	}
	/*
    //Sending alert Email after PaymentSettlement kickstart
    public void sendKeymanEmail(List<String> UserIDs, string region){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //get user email addresss from its ID
        List<User> recepients = [Select Name , email from User where ID IN :UserIDs ];
        List<String> toAddresses = new List<String>();
        for(User recepient : recepients ){
            
            toAddresses.add(recepient.email);
            
        }
        system.debug('toAddresses');
        system.debug(toAddresses);
        toAddresses.add('prasia.mobile@pernod-ricard.com');
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = 'Trade Spend Cycle Start Notification – Keyman Allocation - '+region;
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Keyman Allocation'+'\r\n\r\n';
        
        mailingMessage  += 'Region: '  + region+ '\r\n';
        mailingMessage  += 'Year: '  + yearKeyman+ '\r\n';
        mailingMessage  += 'Month: '  + monthKeyman +  '\r\n';
        mailingMessage  += '\r\n';
        //          mailingMessage  += 'Monthly CA budget have been uploaded into the system for each Sales branch.'+  '\r\n';
        mailingMessage  += 'Now you can start your process for Keyman Allocation.'+  '\r\n\r\n';
        mailingMessage  += 'Thanks.'+  '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
        
    }
    */
	/* [VL 4.0] END */
	
	/* [VL 5.0] BEGIN */
	public boolean getisPaymentCalculating(){
		boolean isPaymentCalculating = false;
		List<AsyncApexJob> job = [
			SELECT Id, Status, ExtendedStatus, completeddate 
			FROM AsyncApexJob 
			WHERE apexclass.name = 'ASI_KOR_SRProposalDetailsActualVol_V2' 
			ORDER BY completeddate DESC
			LIMIT 1
		];
		if(job.size()>0){
			if(job[0].Status != 'Completed'){
				isPaymentCalculating = true;
			}
		}
		return isPaymentCalculating;
	}
	/* [VL 5.0] END */

    public void updateSITStatus(){
        Date selectedDate = Date.valueOf(yearSITStatus + '-' + monthSITStatus + '-01');

		string rtId_locked = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Locked');
		string rtId_editable = Global_RecordTypeCache.getRtId('ASI_KOR_Stock_In_Trade__cASI_KOR_SIT_Editable');
		string query = 'SELECT Id, ASI_KOR_Status__c, RecordTypeId ';
		query += 'FROM ASI_KOR_Stock_In_Trade__c ';
		query += 'WHERE RecordTypeid IN (:rtId_locked, :rtId_editable) AND ';
		query += 'ASI_KOR_SYS_Date__c = :selectedDate ';
		if(branch != 'All'){
			query += 'and ASI_KOR_Wholesaler__r.owner.ASI_KOR_User_Branch_Code__c = :branch ';
		}
		
		/*
        List<ASI_KOR_Stock_In_Trade__c > stockInTrades = [
            SELECT Id, ASI_KOR_Status__c, RecordTypeId
            FROM ASI_KOR_Stock_In_Trade__c
            WHERE RecordType.DeveloperName IN ('ASI_KOR_SIT_Locked','ASI_KOR_SIT_Editable') AND
            ASI_KOR_SYS_Date__c = :selectedDate
        ];
		*/
		List<ASI_KOR_Stock_In_Trade__c > stockInTrades = (List<ASI_KOR_Stock_In_Trade__c >) database.query(query);

        if(stockInTrades.size() == 0){
            string msg = 'There is no SIT record in ' + yearSITStatus + '-' + monthSITStatus;
			if(branch != 'All') msg += ' in the selected branch';
			msg += '.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
        } else{
            for (ASI_KOR_Stock_In_Trade__c stockInTrade : stockInTrades) {
                stockInTrade.ASI_KOR_Status__c = sitStatus;
                if (sitStatus == 'Locked') {
                    stockInTrade.RecordTypeId = rtId_locked;
                }
                if (sitStatus == 'Editable') {
                    stockInTrade.RecordTypeId = rtId_editable;
                }
            }
    
            update stockInTrades;
			
            string msg = 'The SIT status of ' + yearSITStatus + '-' + monthSITStatus + ' has been updated to <b>' + sitStatus + '</b>';
			if(branch != 'All') msg += ' in the selected branch';
			msg += '.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));
        }
        
    }
}