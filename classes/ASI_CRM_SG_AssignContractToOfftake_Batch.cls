/*********************************************************************************
 * Name:ASI_CRM_SG_AssignContractToOfftake_Batch
 * Description: Assign contract to offtake
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-12-28       Laputa: Hugo Cheung     Created
 * 2017-01-13		Laputa: Vincent			[VL 1.0] if match update offtake in contract loop, not contract target loop to prevent duplicate
 * 2017-01-17		Laputa: Vincent			[VL 2.0] link if Offtake SKU is a old SKU to contract target
 * 2017-04-12       Wilken Lee              [WL 1.0] linnk offtake to contract by target sub-brand
 * 2017-05-19		Laputa: Vincent			[VL 3.0] Handle P3 enhancement
 * 2017-07-07       Wilken Lee              [WL 2.0] P3 UAT Feedback, non-Contracted SKU should like to main contract. 
                                                     If multiple contracts with same Start Date, then assign to the one with earlier CreatedDate
 * 2017-08-22       Wilken Lee              [WL 3.0] Bug fix on Non-Contracted SKU, should match with contract period before linking to contract
 * 2018-01-17       Laputa: Vincent	        [VL 4.0] P4.1B: Add constructor of offtake module
 * 2018-04-06       Wilken Lee	        	[WL 5.0] Add flag to auto recalculate ROI after link specific outlet offtake
 * 2018-04-06       Laputa: Vincent	        [VL 6.0] Remove entry criteria of lastmodifieddate within 7 days
 * 2018-07-04       Laputa: Vincent	        [VL 7.0] ICM118424039: Fix controller
*********************************************************************************/
global class ASI_CRM_SG_AssignContractToOfftake_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private static final String OFFTAKE_RECORD_TYPE = 'ASI_CRM_SG_Actual_offtake';

    public static final String APPROVED_STATUS = 'Contract Approved';

    public static final String CONTRACT_RECORD_TYPE = 'ASI_CRM_SG_Contract_Read_Only';
	
	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';
	
	
	/* [VL 4.0] BEGIN */
	public String yearStr = '';
	public String monthStr = '';
	public boolean CalculateROI = false;
	public integer TotalOfftakeProceed = 0;
	public integer TotalOfftakeLinked = 0;
	public Set<string> Set_contractId = new Set<string>();
	/* [VL 4.0] END */

    /* [WL 1.0] BEGIN */
    public String outletID = '';
    global ASI_CRM_SG_AssignContractToOfftake_Batch(String outletNumber){
        /* [VL 7.0] BEGIN */
        /*
        List<ASI_CRM_AccountsAdditionalField__c> cust = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_MY_CustomerCode__c = :outletNumber AND RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet')];

        if (cust.size() == 1)
            outletId = cust.get(0).Id;
        */
        outletId = outletNumber;
        /* [VL 7.0] END */
			
		/*[WL 5.0] BEGIN*/
		this.CalculateROI = true;
		/*[WL 5.0] END*/
    }

    global ASI_CRM_SG_AssignContractToOfftake_Batch(){
        
    }
    /* [WL 1.0] END */
	
	/* [VL 4.0] BEGIN */
    global ASI_CRM_SG_AssignContractToOfftake_Batch(String yearStr, String monthStr){
        this.yearStr = yearStr;
        this.monthStr = monthStr;
		this.CalculateROI = true;
    }
	/* [VL 4.0] END */

    //Retrieve the Actual Offtake records
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        String query = 'SELECT Id, Name, ASI_CRM_SG_Customer__c, ASI_CRM_SKU__c, ASI_TH_CRM_Offtake_G_L_Date__c, ASI_TH_CRM_Quantity__c, ASI_CRM_Contract__c, ASI_TH_CRM_Sub_brand__c ';
        query += 'FROM ASI_TH_CRM_Actual_Offtake__c ';
        query += 'WHERE RecordType.DeveloperName = \'' + OFFTAKE_RECORD_TYPE + '\' '; 
        query += 'AND ASI_CRM_Contract__c = null '; 
        /* [WL 1.0] BEGIN */
        /* [VL 6.0] BEGIN */
        /*
        query += 'AND LastModifiedDate = LAST_N_DAYS:7 '; 
        */
        /* [VL 6.0] END */

        if (outletId != '')
            query += 'AND ASI_CRM_SG_Customer__c = \'' + outletId + '\' ';   

        /* [WL 1.0] END */
		
		/* [VL 4.0] BEGIN */
		if (yearStr != ''){
			query += 'AND calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) = ' + yearStr + ' '; 
		}
		if (monthStr != ''){
			query += 'AND calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c) = ' + monthStr + ' '; 
		}
		/* [VL 4.0] END */
        system.debug('Query:' + query);
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext contextInstance, List<Sobject> sObjectList) { 
        //Retrieve sku mapping map
        Map<Id, Id> skuMappingMap = getSKUMappingMap();

        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = (List<ASI_TH_CRM_Actual_Offtake__c>) sObjectList;

		/* [VL 4.0] BEGIN */
		TotalOfftakeProceed += actualOfftakeList.size();
		/* [VL 4.0] END */        

        //Retrieve the customer id from actual offtake
        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
            if(String.isNotBlank(actualOfftake.ASI_CRM_SG_Customer__c)) customerIdSet.add(actualOfftake.ASI_CRM_SG_Customer__c);
        }

        system.debug('actualOfftakeList size: ' + actualOfftakeList.size() + ' customerIdSet size: ' + customerIdSet.size());

        if(customerIdSet.size() > 0) {
            //Retrieve the contract, contract target, contract outlet records
            //Filter the records by customer id and approved status
            List<ASI_CRM_Contract_Outlets__c> contractOutletList = [SELECT ASI_CRM_SG_Contract__c
                                                                    FROM ASI_CRM_Contract_Outlets__c
                                                                    WHERE ASI_CRM_SG_Customer__c in :customerIdSet
                                                                    AND ASI_CRM_SG_Contract__r.recordtype.developername = :CONTRACT_RECORD_TYPE ];
            Set<Id> contractId = new Set<Id>();
            for(ASI_CRM_Contract_Outlets__c contractOutlet : contractOutletList) {
                contractId.add(contractOutlet.ASI_CRM_SG_Contract__c);
            }                                                        

            List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_Outlet_WS__c, 
                                                         (SELECT ASI_CRM_SG_Customer__c 
                                                          FROM Contract_Outlets__r), 
                                                         (SELECT ASI_CRM_SKU__c, ASI_CRM_Subbrand__c, ASI_CRM_Contract__r.Name 
                                                          FROM Contract_Target__r
                                                          /* [WL 1.0] BEGIN */
                                                          //WHERE ASI_CRM_Subbrand__c = null
                                                          /* [WL 1.0] END */
                                                          /* [VL 3.0] BEGIN */
                                                          WHERE recordtype.developername = :CONTRACTTARGET_RECORD_TYPE
                                                          /* [VL 3.0] END */
                                                          ),
                                                          ASI_CRM_Ad_hoc_Contract__c, Name
                                                          /*[WL 2.0 BEGIN]*/
                                                          ,CreatedDate
                                                          /*[WL 2.0 END]*/
                                                         FROM ASI_TH_CRM_Contract__c
                                                         WHERE (Id in :contractId OR ASI_CRM_CN_Outlet_WS__c in: customerIdSet)
                                                         AND ASI_TH_CRM_Contract_Status__c = :APPROVED_STATUS
                                                         AND recordtype.developername = :CONTRACT_RECORD_TYPE 
                                                         /*[WL 2.0 BEGIN]*/
                                                         ORDER BY ASI_TH_CRM_Start_Date__c, CreatedDate ASC
                                                         /*[WL 2.0 END]*/
                                                         ];

            system.debug('contractOutletList size: ' + contractOutletList.size() + ' contractList size: ' + contractList.size());

            //Loop through the contract record list, find out the contract records that under same customer
            Map<Id, List<ASI_TH_CRM_Contract__c>> customerContractMap = new Map<Id, List<ASI_TH_CRM_Contract__c>>();
            for(ASI_TH_CRM_Contract__c contract : contractList) {

                for(ASI_CRM_Contract_Outlets__c contractOutlet : contract.Contract_Outlets__r) {
                    List<ASI_TH_CRM_Contract__c> tempContractList = customerContractMap.get(contractOutlet.ASI_CRM_SG_Customer__c);
                    if(tempContractList == null) tempContractList = new List<ASI_TH_CRM_Contract__c>(); 
                    tempContractList.add(contract);
                    customerContractMap.put(contractOutlet.ASI_CRM_SG_Customer__c, tempContractList);
                }

                List<ASI_TH_CRM_Contract__c> tempContractList = customerContractMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
                if(tempContractList == null) tempContractList = new List<ASI_TH_CRM_Contract__c>(); 
                tempContractList.add(contract);
                customerContractMap.put(contract.ASI_CRM_CN_Outlet_WS__c, tempContractList);

            }

            //Verify the contract records
            //Actual offtake must within the contract period 
            //Actual offtake must match contract target sku/latest sku
            List<ASI_TH_CRM_Actual_Offtake__c> updateActualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
            for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
                if(String.isNotBlank(actualOfftake.ASI_CRM_SG_Customer__c) &&
                   customerContractMap.containsKey(actualOfftake.ASI_CRM_SG_Customer__c)) {
                    List<ASI_TH_CRM_Contract__c> tempContractList = customerContractMap.get(actualOfftake.ASI_CRM_SG_Customer__c);

                    /* [WL 1.0] BEGIN */ 
                    Integer matchedContractTargetCount = 0;
                    Integer matchedContractPeriodCount = 0;
					/* [WL 3.0] BEGIN */ 
					String debugMessage = '';
					/* [WL 3.0] END */ 

                    Map<String, ASI_TH_CRM_Contract__c> contractMatchedTargetMap = new Map<String, ASI_TH_CRM_Contract__c>();
                    Map<String, ASI_TH_CRM_Contract__c> contractMatchedPeriodMap = new Map<String, ASI_TH_CRM_Contract__c>();

                    system.debug('tempContractList: ' + tempContractList);
                    //Check the number of contracts matched this offtake, allocate to ad-hoc if multiple contracts are found
                    for(ASI_TH_CRM_Contract__c contract : tempContractList) {
                        if(contract.ASI_TH_CRM_Start_Date__c <= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c && 
                           contract.ASI_TH_CRM_End_Date__c >= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c) {

                            //Assign counter if offtake matched contract period, to be used if SKU doesn't match target but still need to assign to contract
                            matchedContractPeriodCount++;
                            contractMatchedPeriodMap.put(contract.Id, contract);

                            for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                                system.debug('contractTarget sub-brand:' + contractTarget.ASI_CRM_Subbrand__c + ' offtake sub-brand: ' + actualOfftake.ASI_TH_CRM_Sub_brand__c);
                                if((skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && actualOfftake.ASI_CRM_SKU__c.equals(skuMappingMap.get(contractTarget.ASI_CRM_SKU__c))) ||
                                   (skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && (skuMappingMap.get(contractTarget.ASI_CRM_SKU__c).equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c)))) ||
                                   (skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && contractTarget.ASI_CRM_SKU__c.equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c))) || 
                                   actualOfftake.ASI_CRM_SKU__c.equals(contractTarget.ASI_CRM_SKU__c)) {
                                    matchedContractTargetCount++;
                                    contractMatchedTargetMap.put(contract.Id, contract);
                                }
                                else if (contractTarget.ASI_CRM_Subbrand__c == actualOfftake.ASI_TH_CRM_Sub_brand__c){
                                    matchedContractTargetCount++;
                                    contractMatchedTargetMap.put(contract.Id, contract);
                                }
                            }
                        }
                    }

                    /* [WL 1.0] END */

                       string cid = '';
                    for(ASI_TH_CRM_Contract__c contract : tempContractList) {
                        if(contract.ASI_TH_CRM_Start_Date__c <= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c && 
                           contract.ASI_TH_CRM_End_Date__c >= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c) {

                            /* [WL 1.0] BEGIN */
                            //Only one contract matched the Offtake G/L Date
                            if (matchedContractTargetCount == 1 ){
                            /* [WL 1.0] END */
                                for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                                    if((skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && actualOfftake.ASI_CRM_SKU__c.equals(skuMappingMap.get(contractTarget.ASI_CRM_SKU__c))) ||
                                       /* [VL 2.0] BEGIN */
                                       (skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && (skuMappingMap.get(contractTarget.ASI_CRM_SKU__c).equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c)))) ||
                                       (skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && contractTarget.ASI_CRM_SKU__c.equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c))) || 
                                       /* [VL 2.0] END */
                                       actualOfftake.ASI_CRM_SKU__c.equals(contractTarget.ASI_CRM_SKU__c)) {
                                        /* [VL 1.0] BEGIN */
                                        /*
                                        actualOfftake.ASI_CRM_Contract__c = contract.Id;
                                        updateActualOfftakeList.add(actualOfftake);
    									                   */
                                           cid = contract.Id;
										   debugMessage = 'One Contract Target Matched By SKU';
                                        /* [VL 1.0] END */
                                    }
                                    /* [WL 1.0] BEGIN */
                                    else if (contractTarget.ASI_CRM_Subbrand__c == actualOfftake.ASI_TH_CRM_Sub_brand__c){
                                        cid = contract.Id;
										debugMessage = 'One Contract Target Matched By SubBrand';
									}                                    
                                    /* [WL 1.0] END */
                                }
                            }
                            /* [WL 1.0] BEGIN */
                            //If multiple contracts matched the offtake G/L Date
                            else if (matchedContractTargetCount >1){
                                if (contract.ASI_CRM_Ad_hoc_Contract__c){
                                    for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                                        if((skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && actualOfftake.ASI_CRM_SKU__c.equals(skuMappingMap.get(contractTarget.ASI_CRM_SKU__c))) ||
                                            (skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) && skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && (skuMappingMap.get(contractTarget.ASI_CRM_SKU__c).equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c)))) ||
                                            (skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c) && contractTarget.ASI_CRM_SKU__c.equals(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c))) || 
                                            actualOfftake.ASI_CRM_SKU__c.equals(contractTarget.ASI_CRM_SKU__c)) {
                                           cid = contract.Id;
										   debugMessage = 'Multiple Contract Target Matched By SKU - Assign to Adhoc Contract';
                                        }
                                        else if (contractTarget.ASI_CRM_Subbrand__c == actualOfftake.ASI_TH_CRM_Sub_brand__c){
                                            cid = contract.Id;
											debugMessage = 'Multiple Contract Target Matched By SubBrand - Assign to Adhoc Contract';
                                        }
                                    }
                                }
                            }
                            /* [WL 1.0] END */
                        }
                    }
                       /* [VL 1.0] BEGIN */
                       if (cid!=''){
                           actualOfftake.ASI_CRM_Contract__c = cid;
                           actualOfftake.ASI_CRM_Adjustment_Remarks__c = '';
						   actualOfftake.ASI_CRM_System_Remark__c = debugMessage;
                           updateActualOfftakeList.add(actualOfftake);
                       }
                       /* [VL 1.0] END */
                       /* [WL 1.0] BEGIN */
                       else if (cid=='' && matchedContractTargetCount>1){
                            //Multiple Contract found but none are ad-hoc, assign to earliest start date contract
                            for (String contractIdMultipleMatch:contractMatchedTargetMap.keySet()){
                              if (cid == '')
                                cid = contractIdMultipleMatch;
                              else if (cid != '' && contractMatchedTargetMap.get(contractIdMultipleMatch).ASI_TH_CRM_Start_Date__c < contractMatchedTargetMap.get(cid).ASI_TH_CRM_Start_Date__c)
                                cid = contractIdMultipleMatch;
                            }

                            if (cid != ''){
								debugMessage = 'Multiple Contract Target Matched By SKU - None are Adhoc Contract - Assign to Contract with Earliest Start Date';
								actualOfftake.ASI_CRM_Contract__c = cid;
								actualOfftake.ASI_CRM_Adjustment_Remarks__c = '';
								actualOfftake.ASI_CRM_System_Remark__c = debugMessage;
								updateActualOfftakeList.add(actualOfftake);
                            }
                       }
                       else if (cid=='' && matchedContractTargetCount == 0){
                        //No contract matches SKU, assign to main contract, or if no ad-hoc found, assign to earlier start date contract
                          if (matchedContractPeriodCount == 1)
								for(ASI_TH_CRM_Contract__c contract : tempContractList) {
								if(contract.ASI_TH_CRM_Start_Date__c <= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c && 
									contract.ASI_TH_CRM_End_Date__c >= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c){
									cid = contract.Id;
									debugMessage = 'Non-Contracted SKU - One Contract Matched Period';
							}
                          }                        
                          //If more than one contract matched period, assign to the first main contract
                          else if (matchedContractPeriodCount > 1){
                            Boolean foundMainContract = false;
                            for(ASI_TH_CRM_Contract__c contract : tempContractList) {
                              /*[WL 2.0 BEGIN]*/
                              //if (contract.ASI_CRM_Ad_hoc_Contract__c){
							  /*[WL 3.0 BEGIN]*/
                              //if (contract.ASI_CRM_Ad_hoc_Contract__c == false && cid == ''){
							  if (contract.ASI_CRM_Ad_hoc_Contract__c == false && cid == '' && contract.ASI_TH_CRM_Start_Date__c <= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c && 
                                 contract.ASI_TH_CRM_End_Date__c >= actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c){
							  /*[WL 3.0 END]*/
                              /*[WL 2.0 END]*/
                                cid = contract.Id;
                                foundMainContract = true;
								debugMessage = 'Non-Contracted SKU - Multiple Contract Matched Period - Assign to First Main Contract Sort by Start Date';
                              }
                            }

							//If more than one contract matched period, but all of them are ad-hoc, then assign to the one with earliest Start Date
                            if (!foundMainContract){
								for (String contractIdPeriodMatch:contractMatchedPeriodMap.keySet()){
									if (cid == ''){
										cid = contractIdPeriodMatch;
										debugMessage = 'Non-Contracted SKU - Multiple Contract Matched Period - All Contracts are Adhoc - Assign to Earliest Start Or Earliest Created';
									}
									else if (cid != '' && contractMatchedPeriodMap.get(contractIdPeriodMatch).ASI_TH_CRM_Start_Date__c < contractMatchedPeriodMap.get(cid).ASI_TH_CRM_Start_Date__c){
										cid = contractIdPeriodMatch;
										debugMessage = 'Non-Contracted SKU - Multiple Contract Matched Period - All Contracts are Adhoc - Assign to Earliest Start Or Earliest Created';
									}
									/*[WL 2.0 BEGIN]*/
									//Assign to contract that is created earlier if multiple contracts are found, none are main contract and all start on same day
									else if (cid != '' && contractMatchedPeriodMap.get(contractIdPeriodMatch).ASI_TH_CRM_Start_Date__c == contractMatchedPeriodMap.get(cid).ASI_TH_CRM_Start_Date__c 
										&& contractMatchedPeriodMap.get(contractIdPeriodMatch).CreatedDate < contractMatchedPeriodMap.get(cid).CreatedDate){
										cid = contractIdPeriodMatch;
										debugMessage = 'Non-Contracted SKU - Multiple Contract Matched Period - All Contracts are Adhoc - Assign to Earliest Start Or Earliest Created';
									}
									/*[WL 2.0 END]*/
								}
                            }
                          }

							if (cid != ''){
								actualOfftake.ASI_CRM_Contract__c = cid;
								actualOfftake.ASI_CRM_Adjustment_Remarks__c = '';
								actualOfftake.ASI_CRM_System_Remark__c = debugMessage;
								updateActualOfftakeList.add(actualOfftake);
							}
                        }

                       system.debug('Offtake: ' + actualOfftake.Name + ' matchedContractTargetCount: ' + matchedContractTargetCount + ' cid: ' + cid + ' matchedContractPeriodCount: ' + matchedContractPeriodCount);
                       /* [WL 1.0] END */
                }
            }
            
            update updateActualOfftakeList;
			
			/* [VL 4.0] BEGIN */
			for (ASI_TH_CRM_Actual_Offtake__c a : updateActualOfftakeList){
				Set_contractId.add(a.ASI_CRM_Contract__c);
			}
			TotalOfftakeLinked += updateActualOfftakeList.size();
			/* [VL 4.0] END */
        }
    }

	//Comment by Wilken on 2017-08-04, not used in P3 Offtake linkage
    /*private Boolean validateOfftakeMatchTargetSkuAndSB(ASI_TH_CRM_Actual_Offtake__c offtake, ASI_CRM_ContractTarget__c target){
      Map<Id, Id> skuMappingMap = getSKUMappingMap();
      if (
        (skuMappingMap.containsKey(target.ASI_CRM_SKU__c) && offtake.ASI_CRM_SKU__c.equals(skuMappingMap.get(target.ASI_CRM_SKU__c))) ||
        (skuMappingMap.containsKey(target.ASI_CRM_SKU__c) && skuMappingMap.containsKey(offtake.ASI_CRM_SKU__c) && (skuMappingMap.get(target.ASI_CRM_SKU__c).equals(skuMappingMap.get(offtake.ASI_CRM_SKU__c)))) ||
        (skuMappingMap.containsKey(offtake.ASI_CRM_SKU__c) && target.ASI_CRM_SKU__c.equals(skuMappingMap.get(offtake.ASI_CRM_SKU__c))) || 
        offtake.ASI_CRM_SKU__c.equals(target.ASI_CRM_SKU__c)
      ) {
       return true;
      }
      else if (target.ASI_CRM_Subbrand__c == offtake.ASI_TH_CRM_Sub_brand__c){
        return true;
      }
      else 
        return false;
    }*/

    global void finish(Database.BatchableContext contextInstance) {
		/* [VL 4.0] BEGIN */
		if (CalculateROI){
			Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(set_contractId, true), 200);
		}
		/* [VL 4.0] END */
	}

    //Collect the SKU Mapping Map<Old SKU, New SKU>
    private Map<Id, Id> getSKUMappingMap() {
        Map<Id, Id> skuMappingMap = new Map<Id, Id>();

        Id sgSKUMappingRecordType = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping');

        for(ASI_CRM_SKU_Mapping__c skuMapping : [SELECT ASI_CRM_SKU__c, ASI_CRM_New_SKU__c 
                                                 FROM ASI_CRM_SKU_Mapping__c
                                                 WHERE RecordTypeId = :sgSKUMappingRecordType]) {
            skuMappingMap.put(skuMapping.ASI_CRM_SKU__c, skuMapping.ASI_CRM_New_SKU__c);
        }

        for(Id skuId : skuMappingMap.keySet()) {
            Id tempSKUId = skuMappingMap.get(skuId);
            while(skuMappingMap.containsKey(tempSKUId)) {
                tempSKUId = skuMappingMap.get(tempSKUId);
            }
            skuMappingMap.put(skuId, tempSKUId);
        }

        return skuMappingMap;
    }
}