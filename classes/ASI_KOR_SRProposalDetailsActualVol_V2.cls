/**********************************************************************************
 * Name : ASI_KOR_SRProposalDetailsActualVol_V2 
 * Created : Vincent Lam
 * Revision History:
 * 1. 2017-02-08 - [VL] Created; clone from ASI_KOR_SRProposalDetailsActualVolJob, 
 * 					initial query change from SR proposal detail to venue depletion detail
 * 					in order to popolate actual volume to those venue not in the proposal
 * 2. 2017-05-31 - [VL 1.0] KR CRM P4.2: Split volume into normal-pay and pre-pay
 * 3. 2018-03-27 - [VL 2.0] Send email after complete
 **********************************************************************************/

global class ASI_KOR_SRProposalDetailsActualVol_V2 
    implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

    global static final Map<String,String> MAP_MONTH = new Map<String,String>{
        '1'=>'January',
        '2'=>'February',
        '3'=>'March',
        '4'=>'April',
        '5'=>'May',
        '6'=>'June',
        '7'=>'July',
        '8'=>'August',
        '9'=>'September',
        '10'=>'October',
        '11'=>'November',
        '12'=>'December'
    };
        
        public string yearStr;  
        public string monthStr;  
        public date cutOffDate;  
        public date srStartDate;  
        public date srLastDate;  
        public list<string> list_regionVenue = new list<string>();
        public map<string, account> map_account = new map<string, account>();
        public map<string, string> map_owner_proposal = new map<string, string>();
        public map<string, string> map_account_proposal = new map<string, string>();
        
        public map<string, ASI_KOR_SR_Proposal_Detail__c> map_srProposalDetailToUpdate = new map<string, ASI_KOR_SR_Proposal_Detail__c>();
        list<ASI_KOR_SR_Proposal_Detail__c> list_srProposalDetailToUpdate = new list<ASI_KOR_SR_Proposal_Detail__c>();
        list<ASI_KOR_SR_Proposal_Detail__c> list_srProposalDetailToInsert = new list<ASI_KOR_SR_Proposal_Detail__c>();
        
        // store the final grouped records
        // key = venue_CAbrand
        public map<string, wrapper> map_final_wrapper = new map<string, wrapper>();
        // store all keys of the retrieved incentive
        // key = brand_branch_grade_contractType_channel
        public map<string, boolean> retrievedIncentive = new map<string, boolean>();
        // store all retrieved incentive
        // first key = brand_branch_grade_contractType
        // second key = sales bracket
        public map<string, map<decimal, ASI_KOR_Incentive_Scheme__c>> map_retrievedIncentive = new map<string, map<decimal, ASI_KOR_Incentive_Scheme__c>>();
        // store all keys of proposal by brand
        // key = proposalID_brand
        public map<string, boolean> retrievedProposalByBrand = new map<string, boolean>();
        // store all proposal by brand
        // key = proposalID_brand
        // if there exist the proposal by brand in system, put the proposal by brand
        public map<string, ASI_KOR_SR_Proposal_By_Brand__c> map_retrievedProposalByBrand = new map<string, ASI_KOR_SR_Proposal_By_Brand__c>();
		
		/* [2.0] BEGIN */
		public string region;
		/* [2.0] END */
    
    public ASI_KOR_SRProposalDetailsActualVol_V2 (string yearStr, string monthStr, date cutOffDate, string region) {
        this.yearStr = yearStr;
        this.monthStr = monthStr;
        this.cutOffDate= cutOffDate+1;
		/* [2.0] BEGIN */
		this.region = region;
		/* [2.0] END */
        
        this.srStartDate = Date.newInstance(Integer.valueOf(yearStr), Integer.valueOf(monthStr), 1);
    	this.srLastDate = srStartDate.addMonths(1).addDays(-1);
        
        list<string> list_owner = new list<string>();
        for (ASI_KOR_SR_Proposal_Header__c sr : [
            select id, ownerid from ASI_KOR_SR_Proposal_Header__c
            where ASI_KOR_Year__c = :yearStr
            and ASI_KOR_Month__c = :monthStr
            and ASI_KOR_Region__c = :region
            and ASI_KOR_Status__c = 'Approved by BM'
        ]){
            this.map_owner_proposal.put(sr.ownerid, sr.id);
            list_owner.add(sr.ownerid);
        }
        
        for(account a : [
            select id, ASI_KOR_Grade__c, ASI_KOR_Contract_Type__c, ASI_KOR_Venue_Pillar__c, ownerid from account
            where ASI_KOR_Venue_Status__c = 'Active'
            and ownerid in :list_owner
            and recordtype.developername = 'ASI_KOR_Venue'
        ]){
            this.list_regionVenue.add(a.id);
            this.map_account.put(a.id, a);
            this.map_account_proposal.put(a.id, this.map_owner_proposal.get(a.ownerid));
        }
            
        
    }                                            
    
    global class AggregateResultIterable implements Iterable<AggregateResult> {
        public string yearStr;  
        public string monthStr;  
        public date cutOffDate;  
        public list<string> list_regionVenue;
        global AggregateResultIterable (string yearStr, string monthStr, date cutOffDate, list<string> list_regionVenue){
             this.yearStr = yearStr;
             this.monthStr = monthStr;
             this.cutOffDate= cutOffDate;
             this.list_regionVenue= list_regionVenue;
         }
        global Iterator<AggregateResult> Iterator(){
            return new AggregateResultIterator(yearStr, monthStr, cutOffDate, list_regionVenue);
       }
    }
 
    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
 
        global AggregateResultIterator(string yearStr, string monthStr, date cutOffDate, list<string> list_regionVenue) {
            index = 0;
            results = [Select 
                         sum(ASI_KOR_Venue_Depl_Actual_Volume__c) bottleAmount,
                         sum(ASI_KOR_Venue_Depl_Actual_Case__c) caseAmount,
                       sum(ASI_KOR_Venue_Depl_Promotion_Number__c) prePayAmount,
                       ASI_KOR_Pay_Type__c payType,
                       ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c venue,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c brand,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c caBrand
                     From 
                         ASI_KOR_Venue_Depletion_Detail__c 
                     where 
                       ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c = :monthStr 
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c = :yearStr 
                       AND ASI_KOR_Venue_Depletion__r.createdDate  < :cutOffDate
                       AND ASI_KOR_Pay_Type__c in ('Pre-Pay','Normal-Pay')
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c in :list_regionVenue
                     group by ASI_KOR_Pay_Type__c ,
                       ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c ,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c ,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c 
                      ];     
        } 
 
        global boolean hasNext(){ 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
 
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }    
 
    global Iterable<AggregateResult> start(Database.batchableContext info){
        // just instantiate the new iterable here and return
        return new AggregateResultIterable(yearStr, MAP_MONTH.get(monthStr), cutOffDate, list_regionVenue);
    }
 
    global void execute(Database.BatchableContext contextInstance, list<AggregateResult> pLstFetchedRecords) {
        
        set<String> set_venue = new set<String>();
        set<String> set_brand = new set<String>();
        
        for (AggregateResult ar : pLstFetchedRecords){
            string brandID = String.valueOf(ar.get('brand'));
            set_brand.add(brandID);
        	string venueID = String.valueOf(ar.get('venue'));
            set_venue.add(venueID);
            system.debug(ar);
        }
        
        map<string, string> map_user_branchCode = new map<string, string>();
        for (user u : [select id, ASI_KOR_User_Branch_Code__c from user where id in (select ownerid from account where id in :set_venue)]){
            map_user_branchCode.put(u.id, u.ASI_KOR_User_Branch_Code__c);
        }
        
        list<ASI_KOR_SR_Proposal_Detail__c> list_srProposalDetail = [
            select id, 
            ASI_KOR_Venue__c,
            ASI_KOR_Brand__c,
            ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c,
            ASI_KOR_SR_Proposal_ID__c,
            ASI_KOR_SR_Proposal_ID__r.ownerid,
            ASI_KOR_System_Generated__c
            from ASI_KOR_SR_Proposal_Detail__c
            where ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c = :monthStr
            and ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c = :yearStr
            and ASI_KOR_Brand__c in :set_brand
            and ASI_KOR_Venue__c in :set_venue
        ];
        
        // store those new venue + brand need to be retrieve incentive scheme in this execution / iteration
        list<wrap_searchIncentive> list_searchIncentive = new list<wrap_searchIncentive>();
        // store those new proposalID + brand need to be retrieve Proposal By Brand in this execution / iteration
        list<string> list_searchProposalByBrand = new list<string>();
        
        // map ar with proposal detail
        for (AggregateResult ar : pLstFetchedRecords){
            string brandID = String.valueOf(ar.get('brand'));
            string venueID = String.valueOf(ar.get('venue'));
            string caBrandID = String.isBlank(String.valueOf(ar.get('caBrand'))) ? brandID : String.valueOf(ar.get('caBrand'));
            string venue_cabrand = venueID+'_'+caBrandID;
            string venue_brand = venueID+'_'+BrandID;
            
            string payType = String.valueOf(ar.get('payType'));
            decimal actualCaseWithoutPrepayment = payType=='Normal-Pay' ? (Decimal)(ar.get('caseAmount')) : 0;
            decimal actualBottleWithoutPrepayment = payType=='Normal-Pay' ? (Decimal)(ar.get('bottleAmount')) : 0;
            decimal actualCase = (Decimal)(ar.get('caseAmount'));
            decimal actualBottle = (Decimal)(ar.get('bottleAmount'));
            decimal actualPrepayment = payType=='Pre-Pay' ? (Decimal)(ar.get('prePayAmount')) : 0;
            ASI_KOR_SR_Proposal_Detail__c srToUpdate = new ASI_KOR_SR_Proposal_Detail__c();
            string finalKey = venue_brand;
            
            account acc = map_account.get(venueID);
            string branchCode = map_user_branchCode.get(map_account.get(venueID).ownerid);
            
            // get data from the final wrapper
            wrapper temp_wrapper;
            if (map_final_wrapper.containsKey(venue_cabrand)){
                temp_wrapper = map_final_wrapper.get(venue_cabrand);
            } else {
                temp_wrapper = new wrapper(acc, branchCode, caBrandID);
                // going to retrieve specific incentive scheme
				/* [VL 1.0] BEGIN */
				/*
                string incentiveKey = caBrandID+'_'+branchCode+'_'+acc.ASI_KOR_Grade__c+'_'+acc.ASI_KOR_Contract_Type__c+'_'+acc.ASI_KOR_Venue_Pillar__c;
				*/
                string incentiveKey = caBrandID+'_'+acc.ASI_KOR_Venue_Pillar__c;
				/* [VL 1.0] END */
                if (!retrievedIncentive.containsKey(incentiveKey)) {
                    wrap_searchIncentive temp_searchIncentive = new wrap_searchIncentive(
                        caBrandID, branchCode, acc.ASI_KOR_Grade__c, acc.ASI_KOR_Contract_Type__c, acc.ASI_KOR_Venue_Pillar__c
                    );
                    list_searchIncentive.add(temp_searchIncentive);
                    retrievedIncentive.put(incentiveKey, true);
                }
            }
            map<string, wrap_proposal> temp_map_proposalDetail = temp_wrapper.map_proposalDetail != null ?
                temp_wrapper.map_proposalDetail :
                new map<string, wrap_proposal>();
            
            boolean noMatchProposal = true;
            string uom = '';
            
            for (ASI_KOR_SR_Proposal_Detail__c sr : list_srProposalDetail){
                if (brandID==sr.ASI_KOR_Brand__c && venueID==sr.ASI_KOR_Venue__c){
                    noMatchProposal = false;
                    finalKey = sr.id;
                    srToUpdate = sr;
                    // skip to next ar once this ar has mapped a proposal detail
                    continue;
                }
            }
            
            wrap_proposal temp_wrap_proposal;
            // sr exists in final map
            if (temp_map_proposalDetail != null && temp_map_proposalDetail.containsKey(finalKey)){
                temp_wrap_proposal = temp_map_proposalDetail.get(finalKey);
                temp_wrap_proposal.actualBottle += actualBottle;
                 temp_wrap_proposal.actualCase += actualCase;
                temp_wrap_proposal.actualBottleWithoutPrepayment += actualBottleWithoutPrepayment;
                 temp_wrap_proposal.actualCaseWithoutPrepayment += actualCaseWithoutPrepayment;
                 temp_wrap_proposal.actualPrepayment += actualPrepayment;
            } else
            // no match proposal and not exist in final map
            if (noMatchProposal) {
                srToUpdate = new ASI_KOR_SR_Proposal_Detail__c(
                	ASI_KOR_SR_Proposal_ID__c = this.map_account_proposal.get(venueID),
                    ASI_KOR_Venue__c = venueID,
            		ASI_KOR_Brand__c = brandID,
                    ASI_KOR_System_Generated__c = true
                );
                temp_wrap_proposal = new wrap_proposal(
                	srToUpdate,
                    actualBottle,
                     actualCase,
                     actualPrepayment,
                    actualBottleWithoutPrepayment,
                     actualCaseWithoutPrepayment
                );
                // going to retrieve specific incentive scheme, because has to populate the incentive scheme and basic cost to new create proposal detail
				/* [VL 1.0] BEGIN */
				/*
                string incentiveKey = brandID+'_'+branchCode+'_'+acc.ASI_KOR_Grade__c+'_'+acc.ASI_KOR_Contract_Type__c+'_'+acc.ASI_KOR_Venue_Pillar__c;
				*/
                string incentiveKey = brandID+'_'+acc.ASI_KOR_Venue_Pillar__c;
				/* [VL 1.0] END */
                if (!retrievedIncentive.containsKey(incentiveKey)) {
                    wrap_searchIncentive temp_searchIncentive = new wrap_searchIncentive(
                        brandID, branchCode, acc.ASI_KOR_Grade__c, acc.ASI_KOR_Contract_Type__c, acc.ASI_KOR_Venue_Pillar__c
                    );
                    list_searchIncentive.add(temp_searchIncentive);
                    retrievedIncentive.put(incentiveKey, true);
                }
                // check if there exist a proposal by brand
                string proposalByBrandKey = this.map_account_proposal.get(venueID)+'_'+brandID;
                if (!retrievedProposalByBrand.containsKey(proposalByBrandKey)) {
                    list_searchProposalByBrand.add(proposalByBrandKey);
                    retrievedProposalByBrand.put(proposalByBrandKey, true);
                }
            } else 
            // has match proposal and not exist in final map
            {
                temp_wrap_proposal = new wrap_proposal(
                	srToUpdate,
                    actualBottle,
                     actualCase,
                     actualPrepayment,
                    actualBottleWithoutPrepayment,
                     actualCaseWithoutPrepayment
                );
            } 
            // put the proposal detail to the final wrapper
            temp_map_proposalDetail.put(finalKey, temp_wrap_proposal);
            temp_wrapper.map_proposalDetail = temp_map_proposalDetail;
            map_final_wrapper.put(venue_cabrand, temp_wrapper);
        }
        
        system.debug('map_final_wrapper');
        system.debug(map_final_wrapper);
        
        system.debug('list_searchIncentive');
        system.debug(list_searchIncentive);
        
        // retrieve incentive scheme, if required
        if (list_searchIncentive.size()>0){
            string query = 'select id, ASI_KOR_CA_Unit_Cost__c, '+
                'ASI_KOR_UOM__c, '+
                'ASI_KOR_Basic_Unit_Cost__c, '+
                'ASI_KOR_Sales_Bracket__c, '+
                'ASI_KOR_Brand__c, '+
                'ASI_KOR_Branch_Code__c, '+
                'ASI_KOR_Grade__c, '+
                'ASI_KOR_Contract__c, '+
                'ASI_KOR_Channel__c '+
                'from ASI_KOR_Incentive_Scheme__c '+
                'where ASI_KOR_Effective_Start_Date__c <= :srStartDate '+
                'and ASI_KOR_Effective_End_Date__c >= :srLastDate '+
                'and (';
            for (wrap_searchIncentive s : list_searchIncentive){
                string q = '(';
                q += 'ASI_KOR_Brand__c = \'' + s.brandID + '\'' +
					/* [VL 1.0] BEGIN */
					/*
                    'and ASI_KOR_Branch_Code__c = \'' + s.branchCode + '\'' +
                    'and ASI_KOR_Grade__c = \'' + s.grade + '\'' +
                    'and ASI_KOR_Contract__c = \'' + s.contractType + '\'' +
					*/
					/* [VL 1.0] END */
                    'and ASI_KOR_Channel__c = \'' + s.channel + '\'';
                q += ') or ';
                query += q;
            }
            query = query.subString(0,query.length()-4);
            query += ') ';
            
            for (ASI_KOR_Incentive_Scheme__c ic : (List<ASI_KOR_Incentive_Scheme__c>)Database.query(query)){
				/* [VL 1.0] BEGIN */
				/*
                string incentiveKey = ic.ASI_KOR_Brand__c+'_'+ic.ASI_KOR_Branch_Code__c+'_'+ic.ASI_KOR_Grade__c+'_'+ic.ASI_KOR_Contract__c+'_'+ic.ASI_KOR_Channel__c;
				*/
                string incentiveKey = ic.ASI_KOR_Brand__c+'_'+ic.ASI_KOR_Channel__c;
				/* [VL 1.0] END */
                map<decimal, ASI_KOR_Incentive_Scheme__c> temp_map_retrievedIncentive = map_retrievedIncentive.containskey(incentiveKey) ? 
                    map_retrievedIncentive.get(incentiveKey) :
                	new map<decimal, ASI_KOR_Incentive_Scheme__c>();
                temp_map_retrievedIncentive.put(ic.ASI_KOR_Sales_Bracket__c, ic);
                map_retrievedIncentive.put(incentiveKey,temp_map_retrievedIncentive);
            }
        }
        
        system.debug('map_retrievedIncentive');
        system.debug(map_retrievedIncentive);
        
        // retrieve proposal by brand, if required
        if (list_searchProposalByBrand.size()>0){
            string query = 'select id, '+
                'ASI_KOR_SR_Proposal_Header__c, '+
                'ASI_KOR_Brand__c '+
                'from ASI_KOR_SR_Proposal_By_Brand__c '+
                'where ';
            for (string s : list_searchProposalByBrand){
                string proposalID = s.split('_')[0];
                string brandID = s.split('_')[1];
                string q = '(';
                q += 'ASI_KOR_SR_Proposal_Header__c = \'' + proposalID + '\'' +
                    'and ASI_KOR_Brand__c = \'' + brandID + '\'';
                q += ') or ';
                query += q;
            }
            query = query.subString(0,query.length()-4);
            
            for (ASI_KOR_SR_Proposal_By_Brand__c r : (List<ASI_KOR_SR_Proposal_By_Brand__c>)Database.query(query)){
                string proposalByBrandKey = r.ASI_KOR_SR_Proposal_Header__c+'_'+r.ASI_KOR_Brand__c;
                map_retrievedProposalByBrand.put(proposalByBrandKey,r);
            }
        }

    }
    
    public class wrapper {
        public account acc;  
        public string branchCode;  
        public string brand;   
        public string uom;  
        public decimal totalVolume;
        public decimal totalVolumeWithoutPrepayment;
        public decimal caCapCost;
        // if it exists in proposal, use id as key
        // else use venue_brand as key
        public map<string, wrap_proposal> map_proposalDetail;
        
        public wrapper (account acc, string branchCode, string brand){
             this.acc = acc;
             this.branchCode = branchCode;
             this.brand = brand;
             this.totalVolume = 0;
             this.totalVolumeWithoutPrepayment = 0;
             this.caCapCost = 0;
         }
    }    
        
        public class wrap_proposal {
            public ASI_KOR_SR_Proposal_Detail__c sr;
            public decimal actualBottle;
            public decimal actualCase;
            public decimal actualPrepayment;
            public decimal actualBottleWithoutPrepayment;
            public decimal actualCaseWithoutPrepayment;
            public wrap_proposal (ASI_KOR_SR_Proposal_Detail__c sr, decimal actualBottle, decimal actualCase, decimal actualPrepayment, decimal actualBottleWithoutPrepayment, decimal actualCaseWithoutPrepayment){
                 this.sr = sr;
                 this.actualBottle = actualBottle;
                 this.actualCase = actualCase;
                 this.actualPrepayment = actualPrepayment;
                 this.actualBottleWithoutPrepayment = actualBottleWithoutPrepayment;
                 this.actualCaseWithoutPrepayment = actualCaseWithoutPrepayment;
             }
        }
        
        public class wrap_searchIncentive {
            public string brandID;
            public string branchCode;
            public string grade;
            public string contractType;
            public string channel;
            public wrap_searchIncentive (string brandID, string branchCode, string grade, string contractType, string channel){
                 this.brandID = brandID;
                 this.branchCode = branchCode;
                 this.grade = grade;
                 this.contractType = contractType;
                 this.channel = channel;
             }
        }
        
        
    /* [DC 3.1] BEGIN */
    public void execute(SchedulableContext contextInstance) {}
    /* [DC 3.1] END */

    // do the final proposal data update / insert in finish
    global void finish(Database.BatchableContext contextInstance) {
        if (map_final_wrapper!=null) {
            
            list<ASI_KOR_SR_Proposal_Detail__c> list_srProposalDetailToUpsert = new list<ASI_KOR_SR_Proposal_Detail__c>();
            list<ASI_KOR_SR_Proposal_By_Brand__c> list_proposalByBrandToInsert = new list<ASI_KOR_SR_Proposal_By_Brand__c>();
            
            for(string venue_caBrand : map_final_wrapper.keySet()){
                wrapper wrap = map_final_wrapper.get(venue_caBrand);
                string caBrand = wrap.brand;
                string branchCode = wrap.branchCode;
                account acc = wrap.acc;
                string grade = acc.ASI_KOR_Grade__c;
                string contractType = acc.ASI_KOR_Contract_Type__c;
                string channel = acc.ASI_KOR_Venue_Pillar__c;
				/* [VL 1.0] BEGIN */
				/*
                string incentiveKey = caBrand+'_'+branchCode+'_'+grade+'_'+contractType+'_'+channel;
				*/
                string incentiveKey = caBrand+'_'+channel;
				/* [VL 1.0] END */
                
                // if there is no match incentive, skip
                if (!map_retrievedIncentive.containsKey(incentiveKey)) continue;
                // get uom from incentive, assume all brands under the same CA brand having the same uom
                map<decimal, ASI_KOR_Incentive_Scheme__c> retrievedIncentive = map_retrievedIncentive.get(incentiveKey);
                string uom = retrievedIncentive.values()[0].ASI_KOR_UOM__c;
                
                // sum the actual volume based on uom
                decimal actualVolume = 0;
                decimal actualVolumeWithoutPrepayment = 0;
                for (wrap_proposal wrap_proposal : wrap.map_proposalDetail.values()){
                    if (uom=='Actual Case') {
                        actualVolume += wrap_proposal.actualCase;
                        actualVolumeWithoutPrepayment += wrap_proposal.actualCaseWithoutPrepayment;
                    } else
                    if (uom=='Bottle'){
                        actualVolume += wrap_proposal.actualBottle;
                        actualVolumeWithoutPrepayment += wrap_proposal.actualBottleWithoutPrepayment;
                    }
                }
                wrap.totalVolume = actualVolume;
                wrap.totalVolumeWithoutPrepayment = actualVolumeWithoutPrepayment;
                
                // retrieve CA Cap Unit Cost based on the CA total volume
                list<decimal> list_salesBracket = new list<decimal>(retrievedIncentive.keySet());
                list_salesBracket.sort();
                if (list_salesBracket.size()==1){
                    ASI_KOR_Incentive_Scheme__c ic = retrievedIncentive.get(list_salesBracket[0]);
					/* [VL 1.0] BEGIN */
					/*
                    wrap.caCapCost = ic.ASI_KOR_CA_Unit_Cost__c;
					*/
                    wrap.caCapCost = ic.ASI_KOR_Basic_Unit_Cost__c;
					/* [VL 1.0] END */
                } else {
                    for (Integer i = list_salesBracket.size()-1; i > 0; i--){
                        if (i==(list_salesBracket.size()-1) && list_salesBracket[i]<=actualVolumeWithoutPrepayment){
                            ASI_KOR_Incentive_Scheme__c ic = retrievedIncentive.get(list_salesBracket[i]);
							/* [VL 1.0] BEGIN */
							/*
							wrap.caCapCost = ic.ASI_KOR_CA_Unit_Cost__c;
							*/
							wrap.caCapCost = ic.ASI_KOR_Basic_Unit_Cost__c;
							/* [VL 1.0] END */
                            break;
                        }
                        if (list_salesBracket[i]>actualVolumeWithoutPrepayment && list_salesBracket[i-1]<=actualVolumeWithoutPrepayment){
                            ASI_KOR_Incentive_Scheme__c ic = retrievedIncentive.get(list_salesBracket[i-1]);
							/* [VL 1.0] BEGIN */
							/*
							wrap.caCapCost = ic.ASI_KOR_CA_Unit_Cost__c;
							*/
							wrap.caCapCost = ic.ASI_KOR_Basic_Unit_Cost__c;
							/* [VL 1.0] END */
                            break;
                        }
                    }
                }
                
                
                // populate actual volume and CA Cap Unit Cost to each proposal detail
                for (string key : wrap.map_proposalDetail.keySet()){
                    wrap_proposal wrap_proposal = wrap.map_proposalDetail.get(key);
                    ASI_KOR_SR_Proposal_Detail__c sr = wrap_proposal.sr;
                    if (uom=='Actual Case') {
						/* [VL 1.0] BEGIN */
						/*
                        sr.ASI_KOR_Actual_Volume__c = wrap_proposal.actualCase;
                        sr.ASI_KOR_Actual_Volume_wo_Pre_payment__c = wrap_proposal.actualCaseWithoutPrepayment;
						*/
                        sr.ASI_KOR_Actual_Volume__c = wrap_proposal.actualCaseWithoutPrepayment;
                        sr.ASI_KOR_Actual_Pre_payment_Volume__c = wrap_proposal.actualCase - wrap_proposal.actualCaseWithoutPrepayment;
						/* [VL 1.0] END */
                    } else
                    if (uom=='Bottle'){
						/* [VL 1.0] BEGIN */
						/*
                        sr.ASI_KOR_Actual_Volume__c = wrap_proposal.actualBottle;
                        sr.ASI_KOR_Actual_Volume_wo_Pre_payment__c = wrap_proposal.actualBottleWithoutPrepayment;
						*/
                        sr.ASI_KOR_Actual_Volume__c = wrap_proposal.actualBottleWithoutPrepayment;
                        sr.ASI_KOR_Actual_Pre_payment_Volume__c = wrap_proposal.actualBottle - wrap_proposal.actualBottleWithoutPrepayment;
						/* [VL 1.0] END */
                    }
                    sr.ASI_KOR_Actual_Pre_Payment_Amount__c = wrap_proposal.actualPrepayment;
                    
                    // for those new proposal, also populate the basic cost
                    if (sr.ASI_KOR_System_Generated__c){
                        /* [VL 1.0] BEGIN */
						/*
						string brandIncentiveKey = sr.ASI_KOR_Brand__c+'_'+branchCode+'_'+grade+'_'+contractType+'_'+channel;
						*/
						string brandIncentiveKey = sr.ASI_KOR_Brand__c+'_'+channel;
                        /* [VL 1.0] END */
                        if (map_retrievedIncentive.containsKey(brandIncentiveKey)) {
                            map<decimal, ASI_KOR_Incentive_Scheme__c> brandRetrievedIncentive = map_retrievedIncentive.get(brandIncentiveKey);
                            list<decimal> list_salesBracket_brand = new list<decimal>(brandRetrievedIncentive.keySet());
                            list_salesBracket_brand.sort();
                            ASI_KOR_Incentive_Scheme__c ic_brand = brandRetrievedIncentive.get(list_salesBracket_brand[0]);
                            sr.ASI_KOR_Incentive_Scheme__c = ic_brand.id;
                            /*
                            sr.ASI_KOR_Cap_Unit_Cost_Basic__c = ic_brand.ASI_KOR_Basic_Unit_Cost__c;
                            sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = wrap.caCapCost + ic_brand.ASI_KOR_Basic_Unit_Cost__c;
                            */
                            sr.ASI_KOR_Actual_Basic_Cost__c = ic_brand.ASI_KOR_Basic_Unit_Cost__c;
                        }
                        // check if there is Proposal By Brand
                        string proposalByBrandKey = sr.ASI_KOR_SR_Proposal_ID__c+'_'+sr.ASI_KOR_Brand__c;
                        if (!map_retrievedProposalByBrand.containsKey(proposalByBrandKey)){
                            ASI_KOR_SR_Proposal_By_Brand__c temp_proposalByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
                            	ASI_KOR_Brand__c = sr.ASI_KOR_Brand__c,
                                ASI_KOR_SR_Proposal_Header__c = sr.ASI_KOR_SR_Proposal_ID__c,
                                ASI_KOR_UOM__c = uom
                            );
                            list_proposalByBrandToInsert.add(temp_proposalByBrand);
                            map_retrievedProposalByBrand.put(proposalByBrandKey,temp_proposalByBrand);
                        }
						/* [VL 1.0] BEGIN */
						/*
                        sr.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = 0;
						*/
                        sr.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = wrap.caCapCost;
						/* [VL 1.0] END */
                    } else {
                        sr.ASI_KOR_Unit_Cost_Cap_Actual_Volume__c = wrap.caCapCost;
                    }
                    
                    // add the finalized proposal detail to upsert list
                    list_srProposalDetailToUpsert.add(sr);
                }
            }
            
            system.debug(list_srProposalDetailToUpsert);
                                   
            if (list_proposalByBrandToInsert.size()>0) {
        
                list_proposalByBrandToInsert = proposalByBrandWithBMheader(list_proposalByBrandToInsert);
                
                system.debug(list_proposalByBrandToInsert);
                
                try {
                    insert list_proposalByBrandToInsert;
                } catch(Exception exceptionInstance) {
                    // DC - TODO : Nothing
					/* [VL 2.0] BEGIN */
					sendErrorEmail(exceptionInstance.getMessage());
					/* [VL 2.0] END */
                }
            }       
            if (list_srProposalDetailToUpsert.size()>0) {
        
                // put Proposal By Brand into new create proposal detail
                for (ASI_KOR_SR_Proposal_Detail__c sr : list_srProposalDetailToUpsert){
                    if (sr.id == null){
                        /*
                        for (ASI_KOR_SR_Proposal_By_Brand__c srB : list_proposalByBrandToInsert){
                            if (
                            	sr.ASI_KOR_SR_Proposal_ID__c == srB.ASI_KOR_SR_Proposal_Header__c &&
                                sr.ASI_KOR_Brand__c == srB.ASI_KOR_Brand__c
                            ) {
                                sr.ASI_KOR_SR_Proposal_By_Brand__c = srB.id;
                                break;
                            }
                        }
                        */
                        string proposalByBrandKey = sr.ASI_KOR_SR_Proposal_ID__c+'_'+sr.ASI_KOR_Brand__c;
                        sr.ASI_KOR_SR_Proposal_By_Brand__c = map_retrievedProposalByBrand.get(proposalByBrandKey).id;
                    }
                }
                
                try {
                    upsert list_srProposalDetailToUpsert;
					/* [VL 2.0] BEGIN */
                    for(List<String> mailUser : getMailUser()){
                        sendPaymentSettlementNotificationEmail(mailUser, this.region);
                    }				    
					/* [VL 2.0] END */
                } catch(Exception exceptionInstance) {
                    // DC - TODO : Nothing
					/* [VL 2.0] BEGIN */
					sendErrorEmail(exceptionInstance.getMessage());
					/* [VL 2.0] END */
                }
            }                           
        }
            
    }
        
        public list<ASI_KOR_SR_Proposal_By_Brand__c> proposalByBrandWithBMheader(list<ASI_KOR_SR_Proposal_By_Brand__c> list_prepare){
            map<string, string> map_srProposalID_bmProposalID = new map<string, string>();
            map<string, string> map_bmProposalID_bmProposalByBrandID = new map<string, string>();
            map<string, string> map_key_bmProposalByBrandID = new map<string, string>();
            list<ASI_KOR_BM_Proposal_By_Brand__c> list_bmProposalByBrandToInsert = new list<ASI_KOR_BM_Proposal_By_Brand__c>();
            
            set<string> list_proposalID = new set<string>();
            for (ASI_KOR_SR_Proposal_By_Brand__c sr : list_prepare){
                list_proposalID.add(sr.ASI_KOR_SR_Proposal_Header__c);
            }     
            for (ASI_KOR_SR_Proposal_Header__c sr : [
                select id, ASI_KOR_BM_Proposal_Header__c from ASI_KOR_SR_Proposal_Header__c where id in :list_proposalID
            ]) {
                map_srProposalID_bmProposalID.put(sr.id, sr.ASI_KOR_BM_Proposal_Header__c);
            }
            
            string query = 'select id, '+
                'ASI_KOR_BM_Proposal_Header__c, '+
                'ASI_KOR_Brand__c, '+
                'ASI_KOR_UOM__c '+
                'from ASI_KOR_BM_Proposal_By_Brand__c '+
                'where ';
            for (ASI_KOR_SR_Proposal_By_Brand__c sr : list_prepare){
                string q = '(';
                q += 'ASI_KOR_BM_Proposal_Header__c = \'' + map_srProposalID_bmProposalID.get(sr.ASI_KOR_SR_Proposal_Header__c) + '\'' +
                    'and ASI_KOR_Brand__c = \'' + sr.ASI_KOR_Brand__c + '\''+
                    'and ASI_KOR_UOM__c = \'' + sr.ASI_KOR_UOM__c + '\'';
                q += ') or ';
                query += q;
            }
            query = query.subString(0,query.length()-4);
            for (ASI_KOR_BM_Proposal_By_Brand__c bm : (List<ASI_KOR_BM_Proposal_By_Brand__c>)Database.query(query)){
                string key = bm.ASI_KOR_BM_Proposal_Header__c+'_'+bm.ASI_KOR_Brand__c+'_'+bm.ASI_KOR_UOM__c;
                map_key_bmProposalByBrandID.put(key, bm.id);
            }
            
            // put BM Proposal By Brand id to the SR Proposal By Brand, else insert the BM Proposal By Brand
            for (ASI_KOR_SR_Proposal_By_Brand__c sr : list_prepare){
                string bmProposalID = map_srProposalID_bmProposalID.get(sr.ASI_KOR_SR_Proposal_Header__c);
                string key = bmProposalID+'_'+sr.ASI_KOR_Brand__c+'_'+sr.ASI_KOR_UOM__c;
                if (map_key_bmProposalByBrandID != null && map_key_bmProposalByBrandID.containsKey(key)){
                    sr.ASI_KOR_BM_Proposal_By_Brand__c = map_key_bmProposalByBrandID.get(key);
                } else {
                    ASI_KOR_BM_Proposal_By_Brand__c bm = new ASI_KOR_BM_Proposal_By_Brand__c(
                    	ASI_KOR_BM_Proposal_Header__c = bmProposalID,
                        ASI_KOR_Brand__c = sr.ASI_KOR_Brand__c,
                        ASI_KOR_UOM__c = sr.ASI_KOR_UOM__c
                    );
                    list_bmProposalByBrandToInsert.add(bm);
                }
            } 
            
            if (list_bmProposalByBrandToInsert.size()>0) {
        
                list_bmProposalByBrandToInsert = srProposalByBrandWithRSDheader(list_bmProposalByBrandToInsert);
                
                try {
                    insert list_bmProposalByBrandToInsert;
                } catch(Exception exceptionInstance) {
                    // DC - TODO : Nothing
					/* [VL 2.0] BEGIN */
					sendErrorEmail(exceptionInstance.getMessage());
					/* [VL 2.0] END */
                }
                
                
                for (ASI_KOR_SR_Proposal_By_Brand__c sr : list_prepare){
                    string bmProposalID = map_srProposalID_bmProposalID.get(sr.ASI_KOR_SR_Proposal_Header__c);
                	string key = bmProposalID+'_'+sr.ASI_KOR_Brand__c;
                    if (sr.ASI_KOR_BM_Proposal_By_Brand__c == null) {
                        for (ASI_KOR_BM_Proposal_By_Brand__c bm : list_bmProposalByBrandToInsert){
                            if ((bm.ASI_KOR_BM_Proposal_Header__c+'_'+bm.ASI_KOR_Brand__c)==key){
                                sr.ASI_KOR_BM_Proposal_By_Brand__c = bm.id;
                                break;
                            }
                        }
                    }
                }
            }
            
            return list_prepare;
        }
        
        public list<ASI_KOR_BM_Proposal_By_Brand__c> srProposalByBrandWithRSDheader(list<ASI_KOR_BM_Proposal_By_Brand__c> list_prepare){
            map<string, string> map_bmProposalID_rsdProposalID = new map<string, string>();
            map<string, string> map_rsdProposalID_rsdProposalByBrandID = new map<string, string>();
            map<string, string> map_key_rsdProposalByBrandID = new map<string, string>();
            list<ASI_KOR_RSD_Proposal_By_Brand__c> list_rsdProposalByBrandToInsert = new list<ASI_KOR_RSD_Proposal_By_Brand__c>();
            
            set<string> list_proposalID = new set<string>();
            for (ASI_KOR_BM_Proposal_By_Brand__c bm : list_prepare){
                list_proposalID.add(bm.ASI_KOR_BM_Proposal_Header__c);
            }     
            for (ASI_KOR_BM_Proposal_Header__c bm : [
                select id, ASI_KOR_RSD_Proposal_Header__c from ASI_KOR_BM_Proposal_Header__c where id in :list_proposalID
            ]) {
                map_bmProposalID_rsdProposalID.put(bm.id, bm.ASI_KOR_RSD_Proposal_Header__c);
            }
            
            string query = 'select id, '+
                'ASI_KOR_RSD_Proposal_Header__c, '+
                'ASI_KOR_Brand__c ' +
                'from ASI_KOR_RSD_Proposal_By_Brand__c '+
                'where ';
            for (ASI_KOR_BM_Proposal_By_Brand__c bm : list_prepare){
                string q = '(';
                q += 'ASI_KOR_RSD_Proposal_Header__c = \'' + map_bmProposalID_rsdProposalID.get(bm.ASI_KOR_BM_Proposal_Header__c) + '\'' +
                    'and ASI_KOR_Brand__c = \'' + bm.ASI_KOR_Brand__c + '\'';
                q += ') or ';
                query += q;
            }
            query = query.subString(0,query.length()-4);
            for (ASI_KOR_RSD_Proposal_By_Brand__c rsd : (List<ASI_KOR_RSD_Proposal_By_Brand__c>)Database.query(query)){
                string key = rsd.ASI_KOR_RSD_Proposal_Header__c+'_'+rsd.ASI_KOR_Brand__c;
                map_key_rsdProposalByBrandID.put(key, rsd.id);
            }
            
            // put BM Proposal By Brand id to the SR Proposal By Brand, else insert the BM Proposal By Brand
            for (ASI_KOR_BM_Proposal_By_Brand__c bm : list_prepare){
                string rsdProposalID = map_bmProposalID_rsdProposalID.get(bm.ASI_KOR_BM_Proposal_Header__c);
                string key = rsdProposalID+'_'+bm.ASI_KOR_Brand__c;
                if (map_key_rsdProposalByBrandID != null && map_key_rsdProposalByBrandID.containsKey(key)){
                    bm.ASI_KOR_RSD_Proposal_By_Brand__c = map_key_rsdProposalByBrandID.get(key);
                } else {
                    ASI_KOR_RSD_Proposal_By_Brand__c rsd = new ASI_KOR_RSD_Proposal_By_Brand__c(
                    	ASI_KOR_RSD_Proposal_Header__c = rsdProposalID,
                        ASI_KOR_Brand__c = bm.ASI_KOR_Brand__c
                    );
                    list_rsdProposalByBrandToInsert.add(rsd);
                }
            } 
            
            if (list_rsdProposalByBrandToInsert.size()>0) {
                try {
                    insert list_rsdProposalByBrandToInsert;
                } catch(Exception exceptionInstance) {
                    // DC - TODO : Nothing
					/* [VL 2.0] BEGIN */
					sendErrorEmail(exceptionInstance.getMessage());
					/* [VL 2.0] END */
                }
                
                for (ASI_KOR_BM_Proposal_By_Brand__c bm : list_prepare){
                    string rsdProposalID = map_bmProposalID_rsdProposalID.get(bm.ASI_KOR_BM_Proposal_Header__c);
                	string key = rsdProposalID+'_'+bm.ASI_KOR_Brand__c;
                    if (bm.ASI_KOR_RSD_Proposal_By_Brand__c == null) {
                        for (ASI_KOR_RSD_Proposal_By_Brand__c rsd : list_rsdProposalByBrandToInsert){
                            if ((rsd.ASI_KOR_RSD_Proposal_Header__c+'_'+rsd.ASI_KOR_Brand__c)==key){
                                bm.ASI_KOR_RSD_Proposal_By_Brand__c = rsd.id;
                                break;
                            }
                        }
                    }
                }
            }
            
            return list_prepare;
        }
        
    
	/* [VL 2.0] BEGIN */
	public List<List<String>> getMailUser(){
		Set<string> users = new Set<string>();
		
		//put user information into a list to send notification email                    
		for(ASI_KOR_NSD_Payment_Settlement_Header__c user : [Select 
			 ASI_KOR_Delegated_Approver__c 
			 From 
			 ASI_KOR_NSD_Payment_Settlement_Header__c 
			 Where 
			 ASI_KOR_Month__c= :this.monthStr AND 
			 ASI_KOR_Year__c = :this.yearStr 
			 Limit 1
			]
		){ 
			users.add(user.ASI_KOR_Delegated_Approver__c);
			//status = status + '   ' + user.OwnerID;
		}
		
		List<ASI_KOR_RSD_Payment_Settlement_Header__c> RSDPaySet = new List<ASI_KOR_RSD_Payment_Settlement_Header__c>();
		for(ASI_KOR_RSD_Payment_Settlement_Header__c user : [Select 
			 id, OwnerId
			 From 
			 ASI_KOR_RSD_Payment_Settlement_Header__c 
			 Where 
			 ASI_KOR_Month__c= :this.monthStr AND 
			 ASI_KOR_Year__c = :this.yearStr  AND
			 ASI_KOR_Region__c = :this.region 
			 limit 1
        ]){ 
			users.add(user.OwnerID);
			RSDPaySet.add(user);
			//status = status + '   ' + user.OwnerID;
		}
		
		List<string> bms = new List<string>();
		for(ASI_KOR_BM_Payment_Settlement_Header__c user : [Select 
			 OwnerId
			 From 
			 ASI_KOR_BM_Payment_Settlement_Header__c 
			 Where 
			 ASI_KOR_Month__c= :this.monthStr AND 
			 ASI_KOR_Year__c = :this.yearStr AND
			 ASI_KOR_RSD_Payment_Settlement__c = :RSDPaySet.get(0).id
		]){ 
			users.add(user.OwnerID);
			bms.add(user.OwnerID);
		}
		
		for(ASI_KOR_SR_Proposal_Header__c sr : [Select 
			 OwnerId
			 From 
			 ASI_KOR_SR_Proposal_Header__c 
			 Where 
			 ASI_KOR_Month__c= :this.monthStr AND 
			 ASI_KOR_Year__c = :this.yearStr AND
			 ASI_KOR_BM_Proposal_Header__r.ownerid in :bms  AND
			 ASI_KOR_Status__c = 'Approved by BM'
        ]){                
			users.add(sr.OwnerID);  
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
		
		return usersList;
	}
	
    //Sending alert Email after PaymentSettlement kickstart
    public void sendPaymentSettlementNotificationEmail(List<String> UserIDs, string region){
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
        String mailingSubject = 'Trade Spend Cycle Start Notification – Payment Settlement - '+region;
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Payment Settlement'+'\r\n\r\n';
        
        mailingMessage  += 'Region: '  + region+ '\r\n';
        mailingMessage  += 'Year: '  + this.yearStr+ '\r\n';
        mailingMessage  += 'Month: '  + this.monthStr +  '\r\n';
        mailingMessage  += 'Cut-off Date: '  + (this.cutOffDate-1).year()+ '-' + (this.cutOffDate-1).month() + '-' + (this.cutOffDate-1).day()+  '\r\n\r\n';
        //          mailingMessage  += 'Monthly CA budget have been uploaded into the system for each Sales branch.'+  '\r\n';
        mailingMessage  += 'Now you can start your process for CA Payment Settlement.'+  '\r\n\r\n';
        mailingMessage  += 'Thanks.'+  '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
        
    }
	
	public void sendErrorEmail(string errorMsg){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add(UserInfo.getUserEmail());
        toAddresses.add('prasia.mobile@pernod-ricard.com');
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = 'FAILED: Trade Spend Cycle Start Notification – Payment Settlement - '+region;
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        
        String mailingMessage  = 'Trade Spend Cycle Start Notification – Payment Settlement'+'\r\n\r\n';
        
        mailingMessage  += 'Error: '  + errorMsg+ '\r\n\r\n';
        mailingMessage  += 'Region: '  + region+ '\r\n';
        mailingMessage  += 'Year: '  + this.yearStr+ '\r\n';
        mailingMessage  += 'Month: '  + this.monthStr +  '\r\n';
        mailingMessage  += 'Cut-off Date: '  + (this.cutOffDate-1).year()+ '-' + (this.cutOffDate-1).month() + '-' + (this.cutOffDate-1).day()+  '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
	}
	/* [VL 2.0] END */
    
}