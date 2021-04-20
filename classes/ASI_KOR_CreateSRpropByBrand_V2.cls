/**********************************************************************************
 * Name : ASI_KOR_createSRpropByBrand 
 * Created : Kevin Choi
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??										Created
 * 2017-03-02       Laputa: Kevin           [KC] Created; trigger class to fill incentive scheme and P3M volume, create proposal by brand if no current proposal found
 * 2017-06-16		Laputa: Vincent			[VL 1.0] P4.2 logic
 **********************************************************************************/


public class ASI_KOR_CreateSRpropByBrand_V2 extends ASI_KOR_TriggerAbstract{
    
    public ASI_KOR_CreateSRpropByBrand_V2() {
        super('ASI_KOR_CreateSRpropByBrand_V2');
    }
    private Id rsdHeader;
    private Id nsdHeader;
    private Map<String,Id> bmProposalByBrandMap;
    private Map<String,Id> rsdProposalByBrandMap;
    private Map<String,Id> nsdProposalByBrandMap;
    private Map<String,ASI_KOR_SR_Proposal_By_Brand__c > srProposalByBrandMap = new Map<String,ASI_KOR_SR_Proposal_By_Brand__c >();
    private List<ASI_KOR_SR_Proposal_By_Brand__c> srInsert = new List<ASI_KOR_SR_Proposal_By_Brand__c>();
    private List<ASI_KOR_BM_Proposal_By_Brand__c> bmInsert = new List<ASI_KOR_BM_Proposal_By_Brand__c>();
    private List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdInsert = new List<ASI_KOR_RSD_Proposal_By_Brand__c>();
    private List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdInsert = new List<ASI_KOR_NSD_Proposal_By_Brand__c>();
    
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        if (tAction == TriggerAction.BEFORE_INSERT && sObjList.size()>0){            
            
            List<ASI_KOR_SR_Proposal_Detail__c> srPropDetail = new List<ASI_KOR_SR_Proposal_Detail__c>();
          
            for (ASI_KOR_SR_Proposal_Detail__c sr : (List<ASI_KOR_SR_Proposal_Detail__c>) sObjList){
                if (!sr.ASI_KOR_Saved__c && !sr.ASI_KOR_System_Generated__c){
                    srPropDetail.add(sr);
                }
            }
            
            if (srPropDetail.size()>0){
            
                //init param for SOQL query
                List<String> srPropHeaderId = new List<String>();
                List<String> propCustomerCode = new List<String>();
                List<String> propOwnerId = new List<String>();
                List<String> venue = new List<String>();
                List<ASI_KOR_SR_Proposal_Detail__c> currentPropDetail = new List<ASI_KOR_SR_Proposal_Detail__c>();
				List<ASI_KOR_SR_Proposal_Detail__c> filteredSRList = new List<ASI_KOR_SR_Proposal_Detail__c>();
                Set<ID> brandIdSet = new Set<Id>();
                String currentUser = Userinfo.getUserId();
                set<string> set_duplicationKey = new set<string>();
                
                Map<Id,ASI_KOR_Brand__c> brandIdMap = new Map<Id,ASI_KOR_Brand__c>([SELECT id, Name FROM ASI_KOR_Brand__c ]);
                
                for (ASI_KOR_SR_Proposal_Detail__c srProp : srPropDetail){
                    srPropHeaderId.add(srProp.ASI_KOR_SR_Proposal_ID__c);
                    propCustomerCode.add(srProp.ASI_KOR_Venue_Code__c);
                    venue.add(srProp.ASI_KOR_Venue__c);
                    brandIdSet.add(srProp.ASI_KOR_Brand__c);
                    string duplicationKey = srProp.ASI_KOR_Venue__c+'_'+srProp.ASI_KOR_Brand__c;
                    if (!set_duplicationKey.contains(duplicationKey)){
                        filteredSRList.add(srProp); 
                        set_duplicationKey.add(duplicationKey);
                    } else {
                        if(!Test.isRunningTest()) srProp.adderror('Duplication on Venue: '+srProp.ASI_KOR_Venue_Code__c+' and Brand: '+brandIdMap.get(srProp.ASI_KOR_Brand__c).name);
                    }
                }

				/* [VL 1.0] BEGIN */
				/*
                currentPropDetail = [SELECT Name,ASI_KOR_SR_Proposal_ID__c FROM ASI_KOR_SR_Proposal_Detail__c WHERE ASI_KOR_SR_Proposal_ID__c IN :srPropHeaderId AND ASI_KOR_Saved__c = true];
                */
				/* [VL 1.0] END */
				
                List<ASI_KOR_SR_Proposal_By_Brand__c> currentSRPropByBrand = [SELECT Name, ASI_KOR_SR_Proposal_Header__c, ASI_KOR_UOM__c, ASI_KOR_Brand__c FROM ASI_KOR_SR_Proposal_By_Brand__c WHERE ASI_KOR_SR_Proposal_Header__c IN :srPropHeaderId];
                //system.debug('By Brand Proposal :'+currentSRPropByBrand);
                Map<String,ASI_KOR_SR_Proposal_By_Brand__c> srPropHeadBrandMap = new Map<String,ASI_KOR_SR_Proposal_By_Brand__c>();
                
                for (ASI_KOR_SR_Proposal_By_Brand__c srProp:currentSRPropByBrand){
                    srPropHeadBrandMap.put(srProp.ASI_KOR_Brand__c+srProp.ASI_KOR_UOM__c, srProp);
                }
                //system.debug('Proposal Mapping :'+srPropHeadBrandMap);
                //
                //Create a lookup relationship of ID, SR Proposal and Map of SR Proposal ID, BM Proposal ID
                List<ASI_KOR_SR_Proposal_Header__c> srProposalHeader = [SELECT Name, ownerId, ASI_KOR_Month__c, ASI_KOR_Year__c, ASI_KOR_Cut_off_Date__c, ASI_KOR_BM_Proposal_Header__c 
                                                                        FROM ASI_KOR_SR_Proposal_Header__c WHERE id IN :srPropHeaderId]; 
                Map<id,ASI_KOR_SR_Proposal_Header__c> srProposalHeaderMap =new Map <id,ASI_KOR_SR_Proposal_Header__c>(); 
                Map<String,String>srToBmMap = new Map<String,String>();
                List<Date> srCutOffDateList = new List<Date>();
                
                Date proposalCycleStart;
                Date proposalCycleEnd;
                
                for (ASI_KOR_SR_Proposal_Header__c srProposal : srProposalHeader){
                    propOwnerId.add(srProposal.ownerId);
                    srToBmMap.put(srProposal.id, srProposal.ASI_KOR_BM_Proposal_Header__c);
                    srProposalHeaderMap.put(srProposal.id,srProposal);
                    proposalCycleStart = Date.newInstance(Integer.valueOf(srProposal.ASI_KOR_Year__c), Integer.valueOf(srProposal.ASI_KOR_Month__c), 1);
                    proposalCycleEnd = proposalCycleStart.addMonths(1).addDays(-1);
                }
				
				/* [VL 1.0] BEGIN */
				/*
                //Query ASI_KOR_BM_Proposal_By_Brand__c at initial, expect null 
                bmProposalByBrandMap = new Map<String,Id>();
                List<ASI_KOR_BM_Proposal_By_Brand__c> bmbrands = [SELECT ASI_KOR_Brand__c, ASI_KOR_UOM__c,id FROM ASI_KOR_BM_Proposal_By_Brand__c
                                                                  WHERE ASI_KOR_BM_Proposal_Header__c =: srToBmMap.values()];
                for(ASI_KOR_BM_Proposal_By_Brand__c x: bmbrands){
                    bmProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
                }
                //Create a lookup relationship of BM Proposal ID, RSD Proposal ID
                Map<String,String>bmToRsdMap = new Map<String,String>();
                List<ASI_KOR_BM_Proposal_Header__c> bmProposalHeader  = [SELECT id, ASI_KOR_RSD_Proposal_Header__c FROM ASI_KOR_BM_Proposal_Header__c WHERE id =: srToBmMap.values()];
                for (ASI_KOR_BM_Proposal_Header__c bmProposal : bmProposalHeader){
                    bmToRsdMap.put(bmProposal.id,bmProposal.ASI_KOR_RSD_Proposal_Header__c);
                }    
                //Query ASI_KOR_RSD_Proposal_By_Brand__c at initial, expect null 
                rsdProposalByBrandMap = new Map<String,Id>();
                List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdBrands = [SELECT ASI_KOR_Brand__c, id FROM ASI_KOR_RSD_Proposal_By_Brand__c
                                                                    where ASI_KOR_RSD_Proposal_Header__c =:bmToRsdMap.values()];
                for(ASI_KOR_RSD_Proposal_By_Brand__c x: rsdBrands){
                    rsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
                }
                
                //Create a lookup relationship of RSD Proposal ID, NSD Proposal ID
                Map<String,String>rsdToNsdMap = new Map<String,String>();
                List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeader = [SELECT id,ASI_KOR_NSD_Proposal_Header__c FROM ASI_KOR_RSD_Proposal_Header__c WHERE id =: bmToRsdMap.values()];                
                for (ASI_KOR_RSD_Proposal_Header__c rsdProposal:rsdProposalHeader){                   
                    rsdToNsdMap.put(rsdProposal.id,rsdProposal.ASI_KOR_NSD_Proposal_Header__c);      	 
                }
                //Query ASI_KOR_NSD_Proposal_By_Brand__c at initial, expect null 
                if(nsdProposalByBrandMap == null){
                    nsdProposalByBrandMap = new Map<String,Id>();
                    List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdBrands = [SELECT ASI_KOR_Brand__c, id FROM ASI_KOR_NSD_Proposal_By_Brand__c
                                                                        WHERE ASI_KOR_NSD_Proposal_Header__c =:rsdToNsdMap.values()];            
                    for(ASI_KOR_NSD_Proposal_By_Brand__c x: nsdBrands){
                        nsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
                    }
                }
                List<ASI_KOR_NSD_Proposal_Header__c> nsdProposalHeader = [SELECT id,ASI_KOR_SYS_Cut_off_Date__c FROM ASI_KOR_NSD_Proposal_Header__c WHERE id =: rsdToNsdMap.values() LIMIT 1]; 
                List<Date> nsdCutOffDate = new List<Date>();
                for(ASI_KOR_NSD_Proposal_Header__c nsd :nsdProposalHeader){
                    nsdCutOffDate.add(nsd.ASI_KOR_SYS_Cut_off_Date__c);
                }
				*/
				/* [VL 1.0] END */
				
				
                //Create lookup relationship of account customer code, account object
                Map<String, account> accMap = new Map<String, account>();
                List <Account> businessAccList = [SELECT Name, OwnerId, ASI_KOR_Contract_Type__c, ASI_KOR_Venue_Pillar__c, ASI_KOR_Grade__c, ASI_KOR_Customer_Code__c 
                                                  FROM Account WHERE 
                                                  recordtype.developername = 'ASI_KOR_Venue' and
                                                  ASI_KOR_Customer_Code__c IN :propCustomerCode];            
                for (Account acc: businessAccList){
                    accMap.put(acc.ASI_KOR_Customer_Code__c,acc);                
                }
                
                //Create lookup relationship of User Name, Branch Code
                List<User> userList = [SELECT id,name, ASI_KOR_User_Branch_Name__c,ASI_KOR_User_Branch_Code__c FROM User WHERE id IN :propOwnerId];
                Map<String,String> userBranchCodeMap = new Map<String,String>();
                 Map<String,String> userBranchNameMap = new Map<String,String>();
                for (User user: userList){
                    userBranchCodeMap.put(user.id, user.ASI_KOR_User_Branch_Code__c);
                    userBranchNameMap.put(user.id, user.ASI_KOR_User_Branch_Name__c);
                }
                //system.debug('Branch Code Map :' +userBranchCodeMap);
                
                //given String brandID ,String venueID,Date cut_off_date
                List<AggregateResult> depletionDetailsByBrand;
                List<Datetime> cutOfftime = new List<Datetime>();
                List<String> oneMonth = new List<String>();
                List<String> oneYear = new List<String>();
                List<String> twoMonth = new List<String>();
                List<String> twoYear = new List<String>();
                List<String> threeMonth = new List<String>();
                List<String> threeYear = new List<String>();
                
				/* [VL 1.0] BEGIN */
				/*
                for (Date srCutOff: nsdCutOffDate){
                    Datetime cutoff =Datetime.newInstance(srCutOff, Time.newInstance(12, 0, 0, 0));            
                    cutOfftime.add(cutoff);
                    
                    String month1 = cutoff.addMonths(-1).format('MMMM');
                    oneMonth.add(month1);   
                
                    String year1 = cutoff.addMonths(-1).format('yyyy');
                    oneYear.add(year1);
                
                    String month2 = cutoff.addMonths(-2).format('MMMM');
                    twoMonth.add(month2);
                    
                    String year2 = cutoff.addMonths(-2).format('yyyy');
                    twoYear.add(year2);   
                    
                    String month3 = cutoff.addMonths(-3).format('MMMM');
                    threeMonth.add(month3); 
                    
                    String year3 = cutoff.addMonths(-3).format('yyyy');
                    threeYear.add(year3);
                }
                
                if(venue != null){
                    depletionDetailsByBrand = [Select sum(ASI_KOR_Venue_Depl_Info_Depletion_Volume__c) deplVol,
                                                      count(ASI_KOR_Venue_Depl_Info_Depletion_Volume__c) countVol,
                                                      sum(ASI_KOR_Venue_Depl_Info_Depletion_Case__c) deplCase,
                                                      count(ASI_KOR_Venue_Depl_Info_Depletion_Case__c) countCase,
                                                      sum(ASI_KOR_Unit_Cost_Per_Bottle_Number__c) bottleCost,
                                                      sum(ASI_KOR_Unit_Cost_Per_Case_Number__c) caseCost, 
                                                      ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c venue ,
                                                      ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c brand
                                               From ASI_KOR_Venue_Depletion_Detail__c 
                                               where ASI_KOR_Venue_Depletion__c IN  (Select  Id  from ASI_KOR_Venue_Depletion__c 
                                                                                     where  
                                                                                     ((ASI_KOR_Month__c IN :oneMonth AND ASI_KOR_Year__c IN :oneYear) OR 
                                                                                     (ASI_KOR_Month__c IN :twoMonth AND ASI_KOR_Year__c IN :twoYear) OR 
                                                                                     (ASI_KOR_Month__c IN :threeMonth AND ASI_KOR_Year__c IN :threeYear))AND 
                                                                                      ASI_KOR_Venue__c IN :venue)
                                                                                AND ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c IN :brandIdMap.keyset()
                                              GROUP BY ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c ,
                                                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c]; 
                    
                    system.debug('AggregateResult for Depletion Detail By Brand :'+ depletionDetailsByBrand);
                } 
                Map<String, AggregateResult> depletionDetailsByBrandMap = new Map<String, AggregateResult>();
                
                for (AggregateResult result : depletionDetailsByBrand){
                    String deplVenue = (String)result.get('venue');
                    String deplBrand = (String)result.get('brand');
                    
                    system.debug('AggregateResult: '+result);
                    depletionDetailsByBrandMap.put(deplBrand+deplVenue,result);
                }
				*/
				Date thisMonthYear = Date.newInstance(Integer.valueOf(srProposalHeader[0].ASI_KOR_Year__c), Integer.valueOf(srProposalHeader[0].ASI_KOR_Month__c), 1);
				Map<String, Map<integer, Map<string, AggregateResult>>> map_venue_month_brand_actual = retrieveVenueActual(thisMonthYear, venue, 2);
                system.debug('map_venue_month_brand_actual');
                system.debug(map_venue_month_brand_actual);
				/* [VL 1.0] END */
                
                List<ASI_KOR_Incentive_Scheme__c> incnetiveSchemeList = [SELECT 
																			ASI_KOR_UOM__c, ASI_KOR_Sales_Bracket__c,ASI_KOR_Basic_Unit_Cost__c, ASI_KOR_Brand__c, ASI_KOR_Channel__c, 
																		 /* [VL 1.0] BEGIN */
																		 /*ASI_KOR_Contract__c, ASI_KOR_Grade__c,
																		 */
																		 /* [VL 1.0] END */
                                                                         ASI_KOR_CA_Unit_Cost__c,ASI_KOR_Branch_Code__c, 
																		 ASI_KOR_Effective_Start_Date__c, ASI_KOR_Effective_End_Date__c  
																		 FROM ASI_KOR_Incentive_Scheme__c
                                                                         WHERE  
                                                                         ASI_KOR_Brand__c IN :brandIdMap.keyset() and
																		 /* [VL 1.0] BEGIN */
																		 /*
                                                                         ASI_KOR_Branch_Code__c IN :userBranchCodeMap.values() and
																		 */
																		 /* [VL 1.0] END */
                                                                         ASI_KOR_Effective_Start_Date__c <= :proposalCycleStart and
                                                                         ASI_KOR_Effective_End_Date__c >= :proposalCycleEnd
                                                                         ORDER BY ASI_KOR_Sales_Bracket__c ASC];
                Map <String,String> incnetiveSchemeMap = new  Map <String,String>();
                Map <string, list<ASI_KOR_Incentive_Scheme__c>> map_incentiveScheme = new Map <string, list<ASI_KOR_Incentive_Scheme__c>>();
                for (ASI_KOR_Incentive_Scheme__c ic :incnetiveSchemeList ){
					/* [VL 1.0] BEGIN */
					/*
                    String key = ic.ASI_KOR_Brand__c+ ic.ASI_KOR_Contract__c+ ic.ASI_KOR_Grade__c+ ic.ASI_KOR_Channel__c+ ic.ASI_KOR_Branch_Code__c;
					*/
                    String key = ic.ASI_KOR_Brand__c+ ic.ASI_KOR_Channel__c;
					/* [VL 1.0] END */
                    incnetiveSchemeMap.put(key,ic.ASI_KOR_UOM__c);
                    list<ASI_KOR_Incentive_Scheme__c> tempIC = map_incentiveScheme.containsKey(key) ? map_incentiveScheme.get(key) : new list<ASI_KOR_Incentive_Scheme__c>();
                    tempIC.add(ic);
                    map_incentiveScheme.put(key,tempIC);
                }
                
                
				/* [VL 1.0] BEGIN */
				/*
                for (ASI_KOR_SR_Proposal_Detail__c srProp : filteredSRList){
					Id brandId = srProp.ASI_KOR_Brand__c;
                    String bmPropHeader = srToBmMap.get(srProp.ASI_KOR_SR_Proposal_ID__c);
                    String rsdPropHeader = bmToRsdMap.get(bmPropHeader);
                    Id nsdProposalByBrandId = nsdProposalByBrandMap.get(brandId);
                    system.debug('nsdProposalByBrandId: '+nsdProposalByBrandId);
                    
                    if(nsdProposalByBrandId == null){
                        ASI_KOR_NSD_Proposal_By_Brand__c nsdProposalByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c();
                        nsdProposalByBrand.ASI_KOR_NSD_Proposal_Header__c = rsdToNsdMap.get(rsdPropHeader);
                        nsdProposalByBrand.ASI_KOR_Brand__c = brandId;
                        
                        nsdInsert.add(nsdProposalByBrand);   
                    }
                }
                insert nsdInsert;
                
                for (ASI_KOR_NSD_Proposal_By_Brand__c nsd : nsdInsert){
                    nsdProposalByBrandMap.put(nsd.ASI_KOR_Brand__c,nsd.id);            
                }
 
                
                for (ASI_KOR_SR_Proposal_Detail__c srProp : filteredSRList){
                    Id brandId = srProp.ASI_KOR_Brand__c;
                    String bmPropHeader = srToBmMap.get(srProp.ASI_KOR_SR_Proposal_ID__c);
                    String rsdPropHeader = bmToRsdMap.get(bmPropHeader);
                    Id rsdProposalByBrandId = rsdProposalByBrandMap.get(brandId);
                    system.debug('rsdProposalByBrandId: '+rsdProposalByBrandId);
                    
                    if(rsdProposalByBrandId == null){
                        ASI_KOR_RSD_Proposal_By_Brand__c rsdProposalByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c();
                        rsdProposalByBrand.ASI_KOR_NSD_Proposal_By_Brand__c = nsdProposalByBrandMap.get(brandId);
                        rsdProposalByBrand.ASI_KOR_RSD_Proposal_Header__c = rsdPropHeader;
                        rsdProposalByBrand.ASI_KOR_Brand__c = brandId;            
                        
                        rsdInsert.add(rsdProposalByBrand);

                    }
                }
                insert rsdInsert;
                
                for (ASI_KOR_RSD_Proposal_By_Brand__c rsd : rsdInsert){
                     rsdProposalByBrandMap.put(rsd.ASI_KOR_Brand__c,rsd.id);
                }
                
                for (ASI_KOR_SR_Proposal_Detail__c srProp : filteredSRList){
                    String srPropHeader = srProp.ASI_KOR_SR_Proposal_ID__c;
                    String bmPropHeader = srToBmMap.get(srProp.ASI_KOR_SR_Proposal_ID__c);
                    Id brandId = srProp.ASI_KOR_Brand__c;
                    String branchCode = userBranchCodeMap.get(currentUser);
                    String ownerId = srProposalHeaderMap.get(srPropHeader).ownerId;
                    String contractType = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Contract_Type__c;
                    String srGrade = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Grade__c;
                    String srChannel = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Venue_Pillar__c;
                    
                    String key = (String)brandId+ contractType+ srGrade+ srChannel+ branchCode; 
                    String uom = incnetiveSchemeMap.get(key);
                    Id bmProposalByBrandId = bmProposalByBrandMap.get(brandId);
                    
                    if(bmProposalByBrandId == null){
                        ASI_KOR_BM_Proposal_By_Brand__c bmProposalByBrand = new ASI_KOR_BM_Proposal_By_Brand__c();
                        bmProposalByBrand.ASI_KOR_RSD_Proposal_By_Brand__c = rsdProposalByBrandMap.get(brandId);
                        bmProposalByBrand.ASI_KOR_BM_Proposal_Header__c = bmPropHeader;
                        bmProposalByBrand.ASI_KOR_Brand__c = brandId;
                        bmProposalByBrand.ASI_KOR_UOM__c = uom; 
                        
                        bmInsert.add(bmProposalByBrand);

                    }  
                }
                insert bmInsert;
                for(ASI_KOR_BM_Proposal_By_Brand__c bm : bmInsert){
                    bmProposalByBrandMap.put(bm.ASI_KOR_Brand__c,bm.id); 
                }
                
                for (ASI_KOR_SR_Proposal_Detail__c srProp : filteredSRList){
                    String srPropHeader = srProp.ASI_KOR_SR_Proposal_ID__c;
                    Id brandId = srProp.ASI_KOR_Brand__c;
                    String branchCode = userBranchCodeMap.get(currentUser);
                    String ownerId = srProposalHeaderMap.get(srPropHeader).ownerId;
                    String contractType = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Contract_Type__c;
                    String srGrade = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Grade__c;
                    String srChannel = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Venue_Pillar__c;
                    
                    String key = (String)brandId+ contractType+ srGrade+ srChannel+ branchCode; 
                    String uom = incnetiveSchemeMap.get(key);
                    
                    ASI_KOR_SR_Proposal_By_Brand__c propByBrand = srPropHeadBrandMap.get(brandId+uom);
                    if (propByBrand == null){  
                        
                        ASI_KOR_SR_Proposal_By_Brand__c srProposalByBrand = new ASI_KOR_SR_Proposal_By_Brand__c();
                        srProposalByBrand.ASI_KOR_BM_Proposal_By_Brand__c = bmProposalByBrandMap.get(brandId);
                        srProposalByBrand.ASI_KOR_Brand__c = brandId;
                        srProposalByBrand.ASI_KOR_SR_Proposal_Header__c = srPropHeader;
                        srProposalByBrand.ASI_KOR_UOM__c = uom;
                        
                        
                        srInsert.add(srProposalByBrand);
                        srPropHeadBrandMap.put(brandId+uom,srProposalByBrand); 
                    }
                }
                insert srInsert;
				*/
				/* [VL 1.0] END */
                
                for (ASI_KOR_SR_Proposal_By_Brand__c sr:srInsert){
                   srProposalByBrandMap.put(sr.ASI_KOR_Brand__c+sr.ASI_KOR_UOM__c,sr); 
                }
                
                for (ASI_KOR_SR_Proposal_Detail__c srProp : filteredSRList){                           
                    if(!srProp.ASI_KOR_Saved__c){
                        //Initialise all parameters
                        String srPropHeader = srProp.ASI_KOR_SR_Proposal_ID__c;
                        String bmPropHeader = srToBmMap.get(srProp.ASI_KOR_SR_Proposal_ID__c);
                        Id brandId = srProp.ASI_KOR_Brand__c;
                        String uom = srProp.ASI_KOR_UOM__c;
                        String accOwner = accMap.get(srProp.ASI_KOR_Venue_Code__c).OwnerId; 
                        //parameters for incentive scheme
                        String branchCode = userBranchCodeMap.get(currentUser);
                        String ownerId = srProposalHeaderMap.get(srPropHeader).ownerId;
                        Decimal targetVol =srProp.ASI_KOR_Target_Volume__c;
                        String contractType = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Contract_Type__c;
                        String srMonth = srProposalHeaderMap.get(srPropHeader).ASI_KOR_Month__c;
                        String srYear = srProposalHeaderMap.get(srPropHeader).ASI_KOR_Year__c;
                        Date srCutOffDate = srProposalHeaderMap.get(srPropHeader).ASI_KOR_Cut_off_Date__c;
                        String srGrade = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Grade__c;
                        String srChannel = accMap.get(srProp.ASI_KOR_Venue_Code__c).ASI_KOR_Venue_Pillar__c;
                        //parameters for P3M values
                        String venueID = srProp.ASI_KOR_Venue__c;
                        system.debug(currentUser);
                        system.debug(accOwner);
                        system.debug(ownerId);
                        if (currentUser == accOwner && currentUser == ownerId){
                            // Find Incentive Scheme for the SR Proposal 
                            if (srProp.ASI_KOR_Incentive_Scheme__c == null){
								/* [VL 1.0] BEGIN */
								/*
                                String ickey = brandId+ contractType+ srGrade+ srChannel+ branchCode;
								*/
                                String ickey = brandId+ srChannel;
								/* [VL 1.0] END */
                                if (!map_incentiveScheme.containsKey(ickey)){
									/* [VL 1.0] BEGIN */
									/*
                                    if(!Test.isRunningTest()) srProp.addError('No Incentive Scheme found for Venue: '+srProp.ASI_KOR_Venue_Code__c+' and brand ' +brandIdMap.get(brandId).Name+ ' (Branch Name: ' + userBranchNameMap.get(currentUser)+ ', Branch Code: '+ userBranchCodeMap.get(currentUser)+ ')' +'. Please modify your proposal details.');
									*/
                                    if(!Test.isRunningTest()) srProp.addError('No Incentive Scheme found for Venue: '+srProp.ASI_KOR_Venue_Code__c+' and brand ' +brandIdMap.get(brandId).Name+ ' (Branch Name: ' + userBranchNameMap.get(currentUser)+ ', Branch Code: '+ userBranchCodeMap.get(currentUser)+ ')' +'. Please modify your Sales Planning details.');
									/* [VL 1.0] END */ 
                                } else{       
									/* [VL 1.0] BEGIN */
									/*
                                	ASI_KOR_Incentive_Scheme__c ic = getCA(brandId,branchCode,targetVol,contractType,srMonth,srYear,srCutOffDate,srGrade,srChannel,map_incentiveScheme.get(ickey));  
									*/
                                	ASI_KOR_Incentive_Scheme__c ic = getCA(brandId,targetVol,srMonth,srYear,srChannel,map_incentiveScheme.get(ickey));  
									/* [VL 1.0] BEGIN */                   
                                    Decimal caCostpBasic = ic.ASI_KOR_Basic_Unit_Cost__c; 
                                    Decimal capCostCA = ic.ASI_KOR_CA_Unit_Cost__c;
                                    system.debug('Incentive Scheme for brand :'+brandIdMap.get(brandId).Name + '(Branch Name: ' + userBranchNameMap.get(currentUser)+ ',Branch Code: '+ userBranchCodeMap.get(currentUser)+ ')' +' found, Here is the incentive scheme details :'+ ic);
                                    srProp.ASI_KOR_Incentive_Scheme__c = ic.id;
									/* [VL 1.0] BEGIN */
									/*
                                    srProp.ASI_KOR_Cap_Unit_Cost_Basic__c = caCostpBasic;
									*/
									/* [VL 1.0] END */ 
									/* [VL 1.0] BEGIN */
									/*
									srProp.ASI_KOR_Cap_Unit_Cost_CA__c = capCostCA;
									*/
									srProp.ASI_KOR_Cap_Unit_Cost_Basic__c = caCostpBasic;
									/* [VL 1.0] END */ 
									uom = ic.ASI_KOR_UOM__c;
									
									ASI_KOR_SR_Proposal_By_Brand__c propByBrand = srPropHeadBrandMap.get(brandId+uom);
									//Generate SR_Proposal_By_Brand for the Proposal Detail
									if (srPropHeader != null && propByBrand != null){  
										//system.debug('Same found :'+ propByBrand.ASI_KOR_Brand__c +'|'+ brandId);
										srProp.ASI_KOR_SR_Proposal_By_Brand__c = propByBrand.Id;                     
									}
									else{
										srProp.ASI_KOR_SR_Proposal_By_Brand__c = srProposalByBrandMap.get(brandId+uom).id;
									}

									/* [VL 1.0] BEGIN */
									/*
									//Calculate P3M Act. Volume and P3M Act. Unit Cost for the Proposal 
									if (depletionDetailsByBrandMap != null && srProp.ASI_KOR_Last_3_month_Actual_average_UC__c == null && srProp.ASI_KOR_Last_3_month_Actual_Average_Volu__c == null){
										//system.debug('UOM :'+uom);
										if(uom == 'Actual Case'){
											system.debug('Start calculating P3M values for actual case');
											string key = brandId+venueID;
											if (depletionDetailsByBrandMap.containsKey(key)){
												srProp.ASI_KOR_Last_3_month_Actual_average_UC__c = averageUnitCostByCases(depletionDetailsByBrandMap.get(key));
												srProp.ASI_KOR_Last_3_month_Actual_Average_Volu__c = averageCases(depletionDetailsByBrandMap.get(key));
											} else {
												srProp.ASI_KOR_Last_3_month_Actual_average_UC__c = 0;
												srProp.ASI_KOR_Last_3_month_Actual_Average_Volu__c = 0;
											}
										}
										else{
											system.debug('Start calculating P3M values for others');
											string key = brandId+venueID;
											if (depletionDetailsByBrandMap.containsKey(key)){
												srProp.ASI_KOR_Last_3_month_Actual_average_UC__c = averageUnitCostByBottles(depletionDetailsByBrandMap.get(key));
												srProp.ASI_KOR_Last_3_month_Actual_Average_Volu__c = averageBottles(depletionDetailsByBrandMap.get(key));
											} else {
												srProp.ASI_KOR_Last_3_month_Actual_average_UC__c = 0;
												srProp.ASI_KOR_Last_3_month_Actual_Average_Volu__c = 0;
											}
										}
									}   
									*/
									srProp.ASI_KOR_Actual_Volume_1_Month_Ago__c = 0;
									srProp.ASI_KOR_Total_VI_1_Month_Ago__c = 0;
									srProp.ASI_KOR_Actual_Volume_2_Months_Ago__c = 0;
									srProp.ASI_KOR_Total_VI_2_Months_Ago__c = 0;
									if (map_venue_month_brand_actual.containsKey(venueID)){
										Map<integer, Map<string, AggregateResult>> map_month_brand_actual = map_venue_month_brand_actual.get(venueID);
										for (integer i : map_month_brand_actual.keySet()){
											Map<string, AggregateResult> map_brand_actual = map_month_brand_actual.get(i);
											if (map_brand_actual.containsKey(srProp.ASI_KOR_Brand__c)){
												AggregateResult actualResult = map_brand_actual.get(srProp.ASI_KOR_Brand__c);
												Decimal actualVolume = uom == 'Actual Case' ? (Decimal)actualResult.get('caseAmount') : (Decimal)actualResult.get('bottleAmount');
												actualVolume = actualVolume.setScale(0);
												Decimal actualAmount = (Decimal)actualResult.get('prePayAmount');
												actualAmount = actualAmount.setScale(0);
												if (i==1){
													srProp.ASI_KOR_Actual_Volume_1_Month_Ago__c = actualVolume;
													srProp.ASI_KOR_Total_VI_1_Month_Ago__c = actualAmount;
												} else
												if (i==2){
													srProp.ASI_KOR_Actual_Volume_2_Months_Ago__c = actualVolume;
													srProp.ASI_KOR_Total_VI_2_Months_Ago__c = actualAmount;
												}
											}
										}
									}
									/* [VL 1.0] END */     
								}
                            }	
                        } else {
							/* [VL 1.0] BEGIN */
							/*
                            if(!Test.isRunningTest()) srProp.addError('You have no permission to upload this proposal, please check if you are the owner of this proposal or the venue you input.');   
							*/
                            if(!Test.isRunningTest()) srProp.addError('You have no permission to upload this Sales Planning, please check if you are the owner of this Sales Planning or the venue you input.');  
							/* [VL 1.0] BEGIN */
                        }
                        srProp.ASI_KOR_Saved__c = true;
                    }
                    system.debug('Final srProp: '+srProp);
                }
				/* [VL 1.0] BEGIN */
				/*
                if (currentPropDetail != null && currentPropDetail.size()> 0){
                    //delete currentPropDetail;
                }
                */
				/* [VL 1.0] END */
                
                system.debug(srPropDetail);
                system.debug('-----------Before Insert Trigger Done -----------');    
            }
        }
    }
	
	/* [VL 1.0] BEGIN */
	/*
    public ASI_KOR_Incentive_Scheme__c getCA(String brand, String branch, Decimal targetVolume, String contractType, String srMonth, String srYear, Date srCutOffDate, String srGrade, String srChannel, List<ASI_KOR_Incentive_Scheme__c> incnetiveSchemeList){  
        String cutOffDate = '1'; 
        
        Date srStartDate = Date.newInstance(Integer.valueOf(srYear), Integer.valueOf(srMonth), Integer.valueOf(cutOffDate));
        Date srLastDate = srStartDate.addMonths(1).addDays(-1);
		
        system.debug('Incentive Scheme found :'+incnetiveSchemeList);
        Decimal ca = 0;
        Decimal cabasic = 0;        
        if(incnetiveSchemeList !=null && incnetiveSchemeList.size() > 0){
            
            ASI_KOR_Incentive_Scheme__c ic;
            
            for(ASI_KOR_Incentive_Scheme__c temp : incnetiveSchemeList){
                String icBrand = temp.ASI_KOR_Brand__c;
                String icBranch = temp.ASI_KOR_Branch_Code__c;
                Decimal icTargetVolume = temp.ASI_KOR_Sales_Bracket__c;
                String icContractType = temp.ASI_KOR_Contract__c;
                String icGrade = temp.ASI_KOR_Grade__c;
                String icChannel = temp.ASI_KOR_Channel__c;
                
                system.debug('ic.id: '+temp.id);
                if (icBrand=='a6S8E0000004HdsUAE'&&icBranch=='570'&&icContractType=='non-Contracted'&&icGrade=='B'&&icChannel=='Local TOT') system.debug('here!!!');
                
                system.debug('icBrand:'+icBrand);
                system.debug('brand:'+brand);
                system.debug('icBranch:'+icBranch);
                system.debug('branch:'+branch);
                system.debug('icContractType:'+icContractType);
                system.debug('contractType:'+contractType);
                system.debug('icGrade:'+icGrade);
                system.debug('srGrade:'+srGrade);
                system.debug('icChannel:'+icChannel);
                system.debug('srChannel:'+srChannel);
                if (icBrand == brand && icBranch == branch && icContractType == contractType && icGrade == srGrade && icChannel == srChannel) system.debug('ic:'+(ic==null));
                
                // check if there is incentive scheme first
                if (ic==null && icBrand == brand && icBranch == branch && icContractType == contractType && icGrade == srGrade && icChannel == srChannel){
                    ic = temp;
                    if(icTargetVolume > targetVolume){
                        break;
                    }
                } else
                // check by sales bracket
                if(icBrand == brand && icBranch == branch && icContractType == contractType && icGrade == srGrade && icChannel == srChannel && icTargetVolume <= targetVolume){
                    ic = temp;
                }else if(icTargetVolume > targetVolume){
                    break;
                }
            }
            
            if(ic == null){
                return null;           
            }
            String icId = ic.id;
            ca = ic.ASI_KOR_CA_Unit_Cost__c;
            cabasic = ic.ASI_KOR_Basic_Unit_Cost__c;
            return ic;
            
        }else{
            return null;            
        }
    }
	*/
    public ASI_KOR_Incentive_Scheme__c getCA(String brand, Decimal targetVolume, String srMonth, String srYear, String srChannel, List<ASI_KOR_Incentive_Scheme__c> incnetiveSchemeList){  
        String cutOffDate = '1'; 
        
        Date srStartDate = Date.newInstance(Integer.valueOf(srYear), Integer.valueOf(srMonth), Integer.valueOf(cutOffDate));
        Date srLastDate = srStartDate.addMonths(1).addDays(-1);
		
        system.debug('Incentive Scheme found :'+incnetiveSchemeList);
        Decimal ca = 0;
        Decimal cabasic = 0;        
        if(incnetiveSchemeList !=null && incnetiveSchemeList.size() > 0){
            
            ASI_KOR_Incentive_Scheme__c ic;
            
            for(ASI_KOR_Incentive_Scheme__c temp : incnetiveSchemeList){
                String icBrand = temp.ASI_KOR_Brand__c;
                Decimal icTargetVolume = temp.ASI_KOR_Sales_Bracket__c;
                String icChannel = temp.ASI_KOR_Channel__c;
                
                system.debug('ic.id: '+temp.id);
                
                system.debug('icBrand:'+icBrand);
                system.debug('brand:'+brand);
                system.debug('icChannel:'+icChannel);
                system.debug('srChannel:'+srChannel);
                
                // check if there is incentive scheme first
                if (ic==null && icBrand == brand && icChannel == srChannel){
                    ic = temp;
                    if(icTargetVolume > targetVolume){
                        break;
                    }
                } else
                // check by sales bracket
                if(icBrand == brand && icChannel == srChannel && icTargetVolume <= targetVolume){
                    ic = temp;
                }else if(icTargetVolume > targetVolume){
                    break;
                }
            }
            
            if(ic == null){
                return null;           
            }
            String icId = ic.id;
            return ic;
            
        }else{
            return null;            
        }
    }
	/* [VL 1.0] END */
    
    //No need String brandID ,String venueID,Date cut_off_date,
    public static Decimal averageCases(AggregateResult deplDetailByBrand){
        Decimal cases = (Decimal)deplDetailByBrand.get('deplCase');
        Decimal caseSize = (Decimal)deplDetailByBrand.get('countCase'); 
        return  cases;
    }
    
    //calculate and return the Last3-month Actual Average Volume   
    public static Decimal averageBottles(AggregateResult deplDetailByBrand){
        Decimal bottles = (Decimal)deplDetailByBrand.get('deplVol');
        Decimal caseSize = (Decimal)deplDetailByBrand.get('countVol'); 
        return  bottles;
    }
    
    public static Integer averageUnitCostByBottles(AggregateResult deplDetailByBrand){
        Decimal cost = (Decimal)deplDetailByBrand.get('bottleCost');
        return cost.intValue();
    }
    
    public static Integer averageUnitCostByCases(AggregateResult deplDetailByBrand){       
		Decimal cost = (Decimal)deplDetailByBrand.get('caseCost');    
        return cost.intValue();
    }    
	
	/* [VL 1.0] BEGIN */
	private Map<String,Map<integer, Map<string, AggregateResult>>> retrieveVenueActual(date srCutOff, list<string> venueIdList, integer uptoXmonth){
		Map<String,Map<integer, Map<string, AggregateResult>>> map_venue_month_brand_actual = new Map<String,Map<integer, Map<string, AggregateResult>>>();
		Date thisProposalDate = Date.newInstance(srCutOff.year(), srCutOff.month(), 1);
		
		for (integer i=1; i<=uptoXmonth; i++){
			Date lastDate = thisProposalDate.addMonths(-i);
			Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
			string lastYear = lastDateTime.format('yyyy');
			string lastMonth = lastDateTime.format('MMMM');
			
			for (AggregateResult result : [Select 
                         sum(ASI_KOR_Venue_Depl_Actual_Volume__c) bottleAmount,
                         sum(ASI_KOR_Venue_Depl_Actual_Case__c) caseAmount,
                       sum(ASI_KOR_Venue_Depl_Promotion_Number__c) prePayAmount,
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c brand,
					   ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c venue
                     From 
                         ASI_KOR_Venue_Depletion_Detail__c 
                     where 
                       ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c = :lastMonth 
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c = :lastYear 
                       AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c in :venueIdList
                     group by 
                       ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c,
					   ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c
			]){
				string venue = String.valueOf(result.get('venue'));
				Map<integer,Map<string, AggregateResult>> map_month_brand_actual = map_venue_month_brand_actual.containsKey(venue) ? map_venue_month_brand_actual.get(venue) : new Map<integer,Map<string, AggregateResult>>();
				Map<string, AggregateResult> map_brand_actual = map_month_brand_actual.containsKey(i) ? map_month_brand_actual.get(i) : new Map<string, AggregateResult>();
				map_brand_actual.put(String.valueOf(result.get('brand')), result);
				map_month_brand_actual.put(i, map_brand_actual);
				map_venue_month_brand_actual.put(venue, map_month_brand_actual);
			}
			
		}
		
		return map_venue_month_brand_actual;
		
	}
	/* [VL 1.0] END */
}