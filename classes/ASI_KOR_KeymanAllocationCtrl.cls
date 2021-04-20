/**********************************************************************************
* Name : ASI_KOR_KeymanAllocationCtrl
* Created : Kevin Choi
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    ----------------------------------------
* 31-07-2017		[Laputa]Kevin			Created
* 2018-04-24		Laputa: Vincent Lam		[VL 1.0] ICM117658976 bug fix for changing VMS Sync flag after finalize
* 2018-07-17		Laputa: Vincent Lam		[VL 2.0] ICM118553853 check VI amount exceed approved before finalize
* 2018-08-30		Laputa: Vincent Lam		[VL 3.0] ICM119024800 fix wrong checking if venue name is the same
**********************************************************************************/
public class ASI_KOR_KeymanAllocationCtrl {
    
    public String monthAllocation{get;set;}
    public String yearAllocation{get;set;}
    public String regionAllocation{get;set;}
    public String branchAllocation{get;set;}
    
    public String selectedRegion {get; set;}
    public Boolean syncFlag {get; set;}
    
    public SelectOption[] monthOptions{get;set;} 	//Month picklist val
    public SelectOption[] yearOptions{get;set;}		//Year picklist val
    public SelectOption[] regionOptions{get;set;}	//Region picklist val
    public SelectOption[] branchOptions{get;set;}	//Branch picklist val
    public SelectOption[] keymanOptions{get;set;}	//Keyman picklist val
    //public List<ASI_KOR_VMS_Interface_File__c> keymanDetailList  {get; set;}
    public List<wrapper_keymanDetail> keymanDetailList  {get; set;}
    
    public Map<String,String> keymanCodeMap {get;set;}
    public String keymanCodeMapJson  {get {return toJsonString(keymanCodeMap);}}
	
	public User user {get; set;}
    public boolean isSR;
    
    public List<VenueSummary> venueSummaryList = new List<VenueSummary>();
    Transient map<string, decimal> venue_FinalVI;
    
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
    
	public List<ASI_KOR_VMS_Interface_File__c> list_deleteVMS;
    
    public ASI_KOR_KeymanAllocationCtrl(){
        
        List<String> regionCodeList = new List<String>();
        List<String> branchCodeList = new List<String>();
        keymanCodeMap = new Map<String,String>();
        
		this.user = getUser(UserInfo.getUserId());
		
        Integer year = Integer.valueOf(DateTime.now().year());
        Integer month = Integer.valueOf(DateTime.now().month());
        
        yearOptions = new SelectOption[]{};
		for(integer i = 0 ; i < 5; i++){
			yearOptions.add(new SelectOption(String.valueOf(year-1),String.valueOf(year-1)));
			year++;
		}
        monthOptions=new SelectOption[]{};
		for(integer i = 1 ; i < 13; i++){
			monthOptions.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
		}
        
        this.yearAllocation = String.valueOf(DateTime.now().year());
        this.monthAllocation = String.valueOf(DateTime.now().month());
        
        regionOptions = new SelectOption[]{};
            
		Map <String,ASI_KOR_Regions__c> regionMap = ASI_KOR_Regions__c.getall();
        
        for(string s : regionMap.keySet()){
            regionOptions.add(new SelectOption(regionMap.get(s).ASI_KOR_Region_Code__c, regionMap.get(s).name));
            regionOptions.sort();
            regionCodeList.add(regionMap.get(s).ASI_KOR_Region_Code__c);
        }
        
        this.regionAllocation =regionCodeList[0];
        if (user.ASI_KOR_User_Region_Code__c != null){
			this.regionAllocation = user.ASI_KOR_User_Region_Code__c;
		}
		
        filterBranchOption();
		
        if (user.ASI_KOR_User_Branch_Code__c != null){
			this.branchAllocation = user.ASI_KOR_User_Branch_Code__c;
		}
		
        this.isSR = determineIsSR();
        filterVenues(); 
        filterRecordByVenueId();
    }
	
	public user getUser(id userId){
		return [
			select id, 
			profile.name, 
			ASI_KOR_User_Branch_Code__c, 
			ASI_KOR_User_Branch_Name__c, 
			ASI_KOR_User_Region_Code__c, 
			ASI_KOR_User_Region_Name__c,
            managerid
			from user 
			where id = :userId 
			limit 1
		];
	}
    
    public boolean determineIsSR(){
        boolean isSR = false;
        list<string> list_bmID = new list<string>();
        for (ASI_KOR_Branches__c b : [select ASI_KOR_Branch_Manager__c from ASI_KOR_Branches__c]){
            list_bmID.add(b.ASI_KOR_Branch_Manager__c);
        }
        for (user u : [select id from user where id in :list_bmID]){
            if (this.user.managerid == u.id){
                isSR = true;
            }
        }
        return isSR;
    }
    
    public void filterBranchOption(){
        system.debug('Start get the Branch setting');
        List<String> branchCodeList = new List<String>();
        
        branchOptions = new SelectOption[]{};
            List<ASI_KOR_Branches__c> branchList = [select Id, Name, ASI_KOR_Branch_Code__c, ASI_KOR_Region_Code__c from ASI_KOR_Branches__c where ASI_KOR_Region_Code__c =: regionAllocation];
        
        for (ASI_KOR_Branches__c branch : branchList){
            branchOptions.add(new SelectOption(branch.ASI_KOR_Branch_Code__c, branch.name));
            branchOptions.sort();    
            
            branchCodeList.add(branch.ASI_KOR_Branch_Code__c);
        }
        this.branchAllocation = branchCodeList[0];
        system.debug('Selected Region:'+regionAllocation);
        system.debug('Selected Branch:'+branchAllocation);
        
    }
    
    public void filterVenues(){
        List<ASI_KOR_VMS_Interface_File__c> filteredVenues = new List<ASI_KOR_VMS_Interface_File__c>();
        if (isSR){
            filteredVenues = [select Id, ASI_KOR_Venue__r.Id, ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c, ASI_KOR_Venue__r.name, ASI_KOR_Venue__r.OwnerId, ASI_KOR_CA_Amount__c,
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Name__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Code__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Name__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Code__c, ASI_KOR_Venue__r.Owner.name
                          from ASI_KOR_VMS_Interface_File__c
                          where ASI_KOR_Promotion_Year__c =: yearAllocation AND
                          ASI_KOR_Promotion_Month__c =: monthAllocation AND
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Code__c =: regionAllocation AND
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Code__c =: branchAllocation AND
                          ASI_KOR_Venue__r.Ownerid = :this.user.id   ];
        } else {
            filteredVenues = [select Id, ASI_KOR_Venue__r.Id, ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c, ASI_KOR_Venue__r.name, ASI_KOR_Venue__r.OwnerId,  ASI_KOR_CA_Amount__c,
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Name__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Code__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Name__c, ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Code__c, ASI_KOR_Venue__r.Owner.name
                          from ASI_KOR_VMS_Interface_File__c
                          where ASI_KOR_Promotion_Year__c =: yearAllocation AND
                          ASI_KOR_Promotion_Month__c =: monthAllocation AND
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Code__c =: regionAllocation AND
                          ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Code__c =: branchAllocation];
        }
        
        
        
        venue_FinalVI = new map<string, decimal>();
        for (AggregateResult ar : [
            select ASI_KOR_Venue_Name__c venue, sum(ASI_KOR_Total_VI_Number__c) finalVI
            from ASI_KOR_SR_Payment_Settlement_Detail__c
            where ASI_KOR_SR_Payment_Settlement__r.ASI_KOR_Year__c = :yearAllocation AND
            ASI_KOR_SR_Payment_Settlement__r.ASI_KOR_Month__c = :monthAllocation AND
            ASI_KOR_Venue_Name__r.Owner.ASI_KOR_User_Region_Code__c =: regionAllocation AND
            ASI_KOR_Venue_Name__r.Owner.ASI_KOR_User_Branch_Code__c =: branchAllocation
            group by ASI_KOR_Venue_Name__c
        ]){
            venue_FinalVI.put(string.valueOf(ar.get('venue')),(decimal)ar.get('finalVI'));
        }
        
        /*
        List<Contact> keymanContactList = [select Id, Name, ASI_KOR_Keyman_Code__c	
                                           from Contact];
        for (Contact con:keymanContactList){ 
            keymanCodeMap.put(con.Id, con.ASI_KOR_Keyman_Code__c);                  
        } 
		*/
        
        if(filteredVenues.size()>0){
            this.selectedRegion = filteredVenues[0].ASI_KOR_Venue__r.Id;
        }else{
             this.selectedRegion = null;
        }
        
        map<string, decimal> map_venue_actualVI = new map<string, decimal>();
        for (ASI_KOR_VMS_Interface_File__c venue: filteredVenues){
            string venueID = venue.ASI_KOR_Venue__r.Id;
            decimal actualVI = map_venue_actualVI.containsKey(venueID) ? map_venue_actualVI.get(venueID) : 0;
            actualVI += venue.ASI_KOR_CA_Amount__c == null ? 0 : venue.ASI_KOR_CA_Amount__c;
            map_venue_actualVI.put(venueID, actualVI);
        }
        
        Set<String> venueCodeSet = new Set<String>();
        venueSummaryList = new List<VenueSummary>(); 
        
        for (ASI_KOR_VMS_Interface_File__c venue: filteredVenues){
            if (!venueCodeSet.contains(venue.ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c)){
                venueCodeSet.add(venue.ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c);
                
                VenueSummary venSum = new VenueSummary();
                venSum.venueId = venue.ASI_KOR_Venue__r.Id;
                venSum.venueCode = venue.ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c;
                venSum.venueName = venue.ASI_KOR_Venue__r.name;
                venSum.venueRegion = venue.ASI_KOR_Venue__r.Owner.ASI_KOR_User_Region_Name__c;
                venSum.venueBranch = venue.ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Name__c;
                venSum.salesmanName = venue.ASI_KOR_Venue__r.Owner.name;
                if (venue_FinalVI.containsKey(venue.ASI_KOR_Venue__r.Id)){
                    venSum.finalVI = venue_FinalVI.get(venue.ASI_KOR_Venue__r.Id);
                } else {
                    venSum.finalVI = 0;
                }
                if (map_venue_actualVI.containsKey(venue.ASI_KOR_Venue__r.Id)){
                    venSum.actualVI = map_venue_actualVI.get(venue.ASI_KOR_Venue__r.Id);
                } else {
                    venSum.actualVI = 0;
                }
                venueSummaryList.add(venSum); 
                /*
                if (!isSR || (isSR && venue.ASI_KOR_Venue__r.ownerid == this.user.id)){
                    
                    if (this.selectedRegion == null){
                        this.selectedRegion = venue.ASI_KOR_Venue__r.id;
                    }
                }
				*/
                 
            }
        }
        system.debug('Size of venueSummaryList: '+venueSummaryList.size());
        filterRecordByVenueId();
        
    }
    
    public void filterRecordByVenueId(){
        
        //keymanDetailList = new List<ASI_KOR_VMS_Interface_File__c>();
        keymanDetailList = new List<wrapper_keymanDetail>();
		list_deleteVMS = new List<ASI_KOR_VMS_Interface_File__c>();
        
        if (selectedRegion != null){
            //List<ASI_KOR_VMS_Interface_File__c> filteredVMSFile = new List<ASI_KOR_VMS_Interface_File__c>();
			map<string, List<ASI_KOR_VMS_Interface_File__c>> map_brand_vms = new map<string, List<ASI_KOR_VMS_Interface_File__c>>();
            
            for (ASI_KOR_VMS_Interface_File__c vms : [select Id, ASI_KOR_Venue__r.Id
                               , ASI_KOR_Venue__r.Owner.ASI_KOR_User_Branch_Name__c
                               , ASI_KOR_Venue__r.ASI_KOR_Customer_Code__c
                               , ASI_KOR_Venue__r.name
                               , ASI_KOR_Venue__r.owner.name
                               , ASI_KOR_Item_Group__r.ASI_KOR_Item_Group_Name__c
                               , ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c
                               , ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name
                               , ASI_KOR_Final_VI__c
                               , ASI_KOR_Keyman__r.name
                               , ASI_KOR_Keyman__r.ASI_KOR_Keyman_Code__c
                               , ASI_KOR_Actual_Volume__c
                               , ASI_KOR_CA_Amount__c
                               , ASI_KOR_Comment__c
                               , ASI_KOR_Promotion_Year__c
                               , ASI_KOR_Promotion_Month__c
                               , ASI_KOR_VMS_Sync__c
							   , ASI_KOR_Keyman_Original__c
							   , ASI_KOR_VI_Amount_Original__c
							   , ASI_KOR_Is_Cloned__c
							   , ASI_KOR_SYS_External_ID__c
							   , ASI_KOR_SR_Code__c
							   , ASI_KOR_UOM__c
							   , ASI_KOR_WS_Code__c
                               from ASI_KOR_VMS_Interface_File__c
                               where ASI_KOR_Venue__r.Id =: selectedRegion AND
                               ASI_KOR_Promotion_Year__c = :yearAllocation AND 
                               ASI_KOR_Promotion_Month__c =: monthAllocation
							   order by ASI_KOR_SYS_External_ID__c]
			){
				string brand = vms.ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name;
				List<ASI_KOR_VMS_Interface_File__c> tempList = map_brand_vms.containsKey(brand) ? map_brand_vms.get(brand) : new List<ASI_KOR_VMS_Interface_File__c>();
				tempList.add(vms);
				map_brand_vms.put(brand, tempList);
			}
            
            //keymanDetailList.addAll(filteredVMSFile);
			
			for (string brand : map_brand_vms.keySet()){
				keymanDetailList.add(
					new wrapper_keymanDetail(brand, map_brand_vms.get(brand))
				);
			}
            
            List<Contact> keymanContactList = [select Id, Name, ASI_KOR_Keyman_Code__c	
                                               from Contact where AccountId =:selectedRegion and recordtype.developername = 'ASI_KOR_Keyman'
                                               AND ASI_KOR_Active__c = true];
            
            keymanOptions = new SelectOption[]{};
            keymanCodeMap = new map<string, string>();
                
			for (Contact con:keymanContactList){                 
				keymanOptions.add(new SelectOption(con.Id,con.Name));  
            	keymanCodeMap.put(con.Id, con.ASI_KOR_Keyman_Code__c);                  
			} 
			
        }        
    }
    
    /*
    public PageReference finalizedRecord(){
        
        string errorMessage = checkSave();
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
		
        errorMessage = actualSave(true); 
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Finalized!'));
		}
        
		return null;       
    }
	*/
    public PageReference finalizedRecord(){
        
		List<ASI_KOR_RSD_Payment_Settlement_Header__c> rsdHeader = [
			select id, ASI_KOR_Status__c 
			from ASI_KOR_RSD_Payment_Settlement_Header__c 
			where ASI_KOR_Year__c = :yearAllocation
			and ASI_KOR_Month__c = :monthAllocation
			and ASI_KOR_Region__c = :user.ASI_KOR_User_Region_Name__c
			limit 1
		];
		if (rsdHeader.size() == 0 || rsdHeader[0].ASI_KOR_Status__c != 'Approved by NSD'){
			String msg = 'You cannot finalize keyman allocation because the ' + monthAllocation + '/' + yearAllocation + ' payment of your region has NOT been approved by NSD.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
		} else {
		
			try{
				list<ASI_KOR_VMS_Interface_File__c> list_vms = [
					select Id
							/* [VL 2.0] BEGIN */
						   , ASI_KOR_Venue__r.name
						   , ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name
						   , ASI_KOR_Final_VI__c
						   , ASI_KOR_CA_Amount__c
							/* [VL 2.0] END */
					from ASI_KOR_VMS_Interface_File__c
					where ASI_KOR_Promotion_Year__c =: yearAllocation AND
					ASI_KOR_Promotion_Month__c =: monthAllocation AND
					ASI_KOR_Venue__r.Ownerid = :user.id
				];
				
				/* [VL 2.0] BEGIN */
				string message = '';
				// check if the VI exceed the approved
				map<string, map<string, decimal>> map_viLimit = new map<string, map<string, decimal>>();
				map<string, map<string, decimal>> map_viActual = new map<string, map<string, decimal>>();
				/* [VL 2.0] END */
				
				/* [VL 3.0] BEGIN */
				map<string, string> map_venue_name = new map<string, string>();
				/* [VL 3.0] END */
				
				for (ASI_KOR_VMS_Interface_File__c vms : list_vms){
					vms.ASI_KOR_VMS_Sync__c = true;
					
					/* [VL 2.0] BEGIN */
					string venue = vms.ASI_KOR_Venue__r.name;
					/* [VL 3.0] BEGIN */
					string venueId = vms.ASI_KOR_Venue__c;
					if(!map_venue_name.containsKey(venueId)) map_venue_name.put(venueId, venue);
					/* [VL 3.0] END */
					string brand = vms.ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name;
					
					vms.ASI_KOR_CA_Amount__c = vms.ASI_KOR_CA_Amount__c != null ? vms.ASI_KOR_CA_Amount__c : 0;
					if (vms.ASI_KOR_CA_Amount__c < 0){
						message += 'Venue ' + venue + ': For brand ' + brand + ', Negative VI is not allowed.<br/>';
					}
					
					// summarize total vi by brand by venue
					/* [VL 3.0] BEGIN */
					/*
					map<string, decimal> map_brandLimit = map_viLimit.containsKey(venue) ? map_viLimit.get(venue) : new map<string, decimal>();
					if (!map_brandLimit.containsKey(brand)){
						map_brandLimit.put(brand, vms.ASI_KOR_Final_VI__c);
					}
					map_viLimit.put(venue, map_brandLimit);
					
					map<string, decimal> map_brandActual = map_viActual.containsKey(venue) ? map_viActual.get(venue) : new map<string, decimal>();
					decimal actualVI = map_brandActual.containsKey(brand) ? map_brandActual.get(brand) : 0;
					actualVI += vms.ASI_KOR_CA_Amount__c;
					map_brandActual.put(brand, actualVI);
					map_viActual.put(venue, map_brandActual);
					*/
					map<string, decimal> map_brandLimit = map_viLimit.containsKey(venueId) ? map_viLimit.get(venueId) : new map<string, decimal>();
					if (!map_brandLimit.containsKey(brand)){
						map_brandLimit.put(brand, vms.ASI_KOR_Final_VI__c);
					}
					map_viLimit.put(venueId, map_brandLimit);
					
					map<string, decimal> map_brandActual = map_viActual.containsKey(venueId) ? map_viActual.get(venueId) : new map<string, decimal>();
					decimal actualVI = map_brandActual.containsKey(brand) ? map_brandActual.get(brand) : 0;
					actualVI += vms.ASI_KOR_CA_Amount__c;
					map_brandActual.put(brand, actualVI);
					map_viActual.put(venueId, map_brandActual);
					/* [VL 3.0] END */
					/* [VL 2.0] END */
				}
				/* [VL 2.0] BEGIN */								
				for (string venue : map_viLimit.keySet()){
					map<string, decimal> map_brandLimit = map_viLimit.get(venue);
					map<string, decimal> map_brandActual = map_viActual.get(venue);
					for(string brand : map_brandLimit.keySet()){
						decimal limitVI = map_brandLimit.get(brand);
						decimal actualVI = map_brandActual.get(brand);
						if (actualVI > limitVI){
							/* [VL 3.0] BEGIN */
							/*
							message += 'Venue ' + venue + ': For brand ' + brand + ', the actual VI ' + doFormatting(actualVI, 2, ',', '.') + ' exceed the approved VI ' + doFormatting(limitVI, 2, ',', '.') + '.<br/>';
							*/
							message += 'Venue ' + map_venue_name.get(venue) + ': For brand ' + brand + ', the actual VI ' + doFormatting(actualVI, 2, ',', '.') + ' exceed the approved VI ' + doFormatting(limitVI, 2, ',', '.') + '.<br/>';
							/* [VL 3.0] END */
						}
					}
				}
				/* [VL 2.0] END */
				
				/* [VL 2.0] BEGIN */
				if(message != ''){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot finalize!<br/>' + message));
				} else
				/* [VL 2.0] END */
				if (list_vms.size()>0) {
					update list_vms;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Finalized!'));
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have any keyman allocation record.'));
				}
				
			}catch( DmlException dmlError) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlError.getMessage()));
			}
		}
        filterRecordByVenueId();
		return null;       
    }
    
    public PageReference doSave(){
        
        string errorMessage = checkSave();
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
		
		/* [VL 1.0] BEGIN */
		/*
        errorMessage = actualSave(false);
		*/
        errorMessage = actualSave(null);
		/* [VL 1.0] END */
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved!'));
		}
        
		return null;    
    }
    
	/*
    public PageReference doQuickSave(){
        
        string errorMessage = checkSave();
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
		
        errorMessage = actualSave(false); 
        if(errorMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved!'));
		}
        
		return null;
		
        PageReference pageRef = new PageReference('/apex/ASI_KOR_KeymanAllocation');
        pageRef.setRedirect(true);
        return pageRef;        
    }
	*/
	
	public string checkSave(){
		
		string message = '';
		
		// check if the VI exceed the approved
		map<string, decimal> map_viLimit = new map<string, decimal>();
		map<string, decimal> map_viActual = new map<string, decimal>();
		
		set<string> set_itemGroup_keyman = new set<string>();
		
        for (wrapper_keymanDetail wrap : keymanDetailList){
			for (ASI_KOR_VMS_Interface_File__c keymanRecord : wrap.keymanDetailList){
				
				keymanRecord.ASI_KOR_CA_Amount__c = keymanRecord.ASI_KOR_CA_Amount__c != null ? keymanRecord.ASI_KOR_CA_Amount__c : 0;
				if (keymanRecord.ASI_KOR_CA_Amount__c < 0){
					return 'Negative VI is not allowed.<br/>';
				}
				
				// summarize total vi by brand
				string brand = keymanRecord.ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name;
				if (!map_viLimit.containsKey(brand)){
					map_viLimit.put(brand, keymanRecord.ASI_KOR_Final_VI__c);
				}
				decimal actualVI = map_viActual.containsKey(brand) ? map_viActual.get(brand) : 0;
				actualVI += keymanRecord.ASI_KOR_CA_Amount__c;
				map_viActual.put(brand, actualVI);
				
				// check if single item group has same keyman
				/*
				string itemGroup_keyman = keymanRecord.ASI_KOR_Item_Group__c + '_' + keymanRecord.ASI_KOR_Keyman__c;
				if (set_itemGroup_keyman.contains(itemGroup_keyman)){
					return 'For Item Group ' + keymanRecord.ASI_KOR_Item_Group__r.ASI_KOR_Item_Group_Name__c + ', a single keyman has more than one record.';
				}
				set_itemGroup_keyman.add(itemGroup_keyman);
				*/
			}
		}
		
		for (string brand : map_viLimit.keySet()){
			decimal limitVI = map_viLimit.get(brand);
			decimal actualVI = map_viActual.get(brand);
			if (actualVI > limitVI){
				message += 'For brand ' + brand + ', the actual VI ' + doFormatting(actualVI, 2, ',', '.') + ' exceed the approved VI ' + doFormatting(limitVI, 2, ',', '.') + '.<br/>';
			}
		}
		
		return message;
		
	}
    
    public string actualSave(Boolean syncFlag){
        
        //system.debug('Enter Saving:'+keymanDetailList+' VMS syncFlag:'+syncFlag);
        List<ASI_KOR_VMS_Interface_File__c> keymanUpdateList = new List<ASI_KOR_VMS_Interface_File__c>();
		
        for (wrapper_keymanDetail wrap : keymanDetailList){
			for (ASI_KOR_VMS_Interface_File__c keymanRecord : wrap.keymanDetailList){
				/* [VL 1.0] BEGIN */
				/*
				keymanRecord.ASI_KOR_VMS_Sync__c = syncFlag;
				*/
				if(syncFlag != null){
					keymanRecord.ASI_KOR_VMS_Sync__c = syncFlag;
				}				
				/* [VL 1.0] END */
				keymanUpdateList.add(keymanRecord);            
			}
		}
		system.debug(keymanUpdateList);
		try{
			if(keymanUpdateList.size() > 0){
				upsert keymanUpdateList;
				keymanUpdateList.clear();
			}
			if(list_deleteVMS.size() > 0){
				delete list_deleteVMS;
				list_deleteVMS.clear();
			}
		}catch( DmlException dmlError) {
			ApexPages.addMessages(dmlError);
			System.debug('Test error : ' + dmlError.getMessage());
			return dmlError.getMessage();
		}
		return '';
    }
    
    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }
    
    
    //public class VenueSummary implements Comparable
    public class VenueSummary{
        public Id venueId {get; set;}
        public String venueCode {get; set;}
        public String venueName {get; set;}
        public String venueRegion {get; set;}
        public String venueBranch {get; set;}
        public String salesmanName {get; set;}
        public decimal finalVI {get; set;}
        public decimal actualVI {get; set;}
        public decimal getDiff(){
            return finalVI - actualVI;
        }
        
    }  
	
	public class wrapper_keymanDetail{
		public string brand {get; set;}
		public List<ASI_KOR_VMS_Interface_File__c> keymanDetailList {get; set;}
		public decimal getVI_approved(){
			return keymanDetailList[0].ASI_KOR_Final_VI__c == null ? 0 : keymanDetailList[0].ASI_KOR_Final_VI__c;
		}
		public decimal getVI_allocated(){
			decimal vi = 0;
			for (ASI_KOR_VMS_Interface_File__c vms : keymanDetailList){
				vi += vms.ASI_KOR_CA_Amount__c == null ? 0 : vms.ASI_KOR_CA_Amount__c;
			}
			return vi;
		}
		public decimal getActualVolume(){
			decimal vi = 0;
			for (ASI_KOR_VMS_Interface_File__c vms : keymanDetailList){
				vi += vms.ASI_KOR_Actual_Volume__c == null ? 0 : vms.ASI_KOR_Actual_Volume__c;
			}
			return vi;
		}
		
		public wrapper_keymanDetail(string brand, List<ASI_KOR_VMS_Interface_File__c> keymanDetailList){
			this.brand = brand;
			this.keymanDetailList = keymanDetailList;
		}
	}
	
	public string getReportLink(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Keyman_Allocation_Report' limit 1];
		return report.id;
	}
	public string getYear(){
		return yearAllocation;
	}
	public string getMonth(){
		return monthAllocation;
	}
	public string getBranch(){
		return branchAllocation;
	}
	
	public PageReference refreshVenueSummary(){    
        filterVenues();
        return null;
    }
	
	public void vmsClone(){    
        string externalID = ApexPages.currentPage().getParameters().get('externalID');
		
		Datetime cDT = System.now();
		String cDTstring = cDT.format('yyyyMMddHHmmss');
		String brand = '';
		Integer position1 = 0;
		Integer position2 = 0;
		ASI_KOR_VMS_Interface_File__c vms;
		
		Integer count1 = 0;
        for (wrapper_keymanDetail wrap : keymanDetailList){
			integer count2 = 0;
			for (ASI_KOR_VMS_Interface_File__c keymanRecord : wrap.keymanDetailList){
				if (keymanRecord.ASI_KOR_SYS_External_ID__c == externalID){
					brand = wrap.brand;
					position1 = count1;
					position2 = count2;
					vms = keymanRecord.clone(false, true, false, false);
					vms.ASI_KOR_SYS_External_ID__c += '_C' + cDTstring;
					vms.ASI_KOR_Is_Cloned__c = true;
					vms.ASI_KOR_CA_Amount__c = 0;
					vms.ASI_KOR_Actual_Volume__c = 0;
				}
				count2++;
			}
			count1++;
		}
		
		if (brand!=''){
			wrapper_keymanDetail wrap = keymanDetailList[position1];
			if (position2 >= wrap.keymanDetailList.size()-1){
				wrap.keymanDetailList.add(vms);
			} else {
				wrap.keymanDetailList.add(position2+1, vms);
			}
		}
    }
	public void vmsDelete(){       
        string externalID = ApexPages.currentPage().getParameters().get('externalID');
        string recordID = ApexPages.currentPage().getParameters().get('recordID');
		
		Datetime cDT = System.now();
		String cDTstring = cDT.format('yyyyMMddHHmmss');
		String brand = '';
		Integer position1 = 0;
		Integer position2 = 0;
		
		Integer count1 = 0;
        for (wrapper_keymanDetail wrap : keymanDetailList){
			integer count2 = 0;
			for (ASI_KOR_VMS_Interface_File__c keymanRecord : wrap.keymanDetailList){
				if (keymanRecord.ASI_KOR_SYS_External_ID__c == externalID){
					brand = wrap.brand;
					position1 = count1;
					position2 = count2;
					if (recordID != '' && keymanRecord.id == recordID){
						list_deleteVMS.add(keymanRecord);
					}
				}
				count2++;
			}
			count1++;
		}
		
		if (brand!=''){
			wrapper_keymanDetail wrap = keymanDetailList[position1];
			wrap.keymanDetailList.remove(position2);
		}
    }
	
	public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
		String s, tmp;
		Integer i = 4 + dec;
	   
		// If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
		if(dec==0){
		  i--;
		}
	   
		s = val.setScale(dec).toPlainString().replace(tSep, dSep);
		while(s.length() > i) {
		  tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
		  s = tmp;
		  i += 4;
		}
	   
		// If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
		if (s.substring(0,1) == '-') {
		  if (s.substring(1,2) == tSep) {
			s = '-' + s.substring(2);
		  }
		}
	   
		return s;
	}
}