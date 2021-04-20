/*********************************************************************************
 * Name:ASI_CRM_SG_DailyRollUp_Batch
 * Description: Rollup T&E Amount and Marketing FOC Amount to Contract Header
 * Test Class: ASI_CRM_SG_TestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-06-05       Wilken Lee              [WL 1.0] CHM114601609: Add MKT FOC Type and aggregate to Brand Event Held amount
 * 2017-11-15       Wilken Lee              [WL 2.0] Add checking when adding SKU Cost, as POSM Item cost might be null
 * 2018-02-01       Wilken Lee              [WL 3.0] Add criteria to recalculate if Contract ASI_CRM_Recalculate_Actual_ROI__c checkbox is selected
*********************************************************************************/
global class ASI_CRM_SG_DailyRollUp_Batch implements Database.Batchable<sObject>,  Schedulable{
    /*[WL 1.0 Begin]*/
    private final Set<String> marketingAGCode = new Set<String>{
        '0009',
        '0003',
        '0041',
        '0042',
        '0043',
        '0044',
        '0026',
        '0027',
        '0029'};    
		
	private final String soOrderType = 'Singapore DF & DP Free Issue - F1';
    /*[WL 1.0 End]*/

    global void execute(SchedulableContext contextInstance) {}
    
    global Database.QueryLocator start(Database.BatchableContext contextInstance){
		Set<ID> custIDSet = new Set<ID>();
		
		List<ASI_CRM_AccountsAdditionalField__c> outletFromTnE = [select id from ASI_CRM_AccountsAdditionalField__c where 
            id in (select ASI_TnE_Outlet__c from ASI_TnE_ClaimDetail__c where lastModifiedDate >= LAST_N_DAYS:7 and recordType.DeveloperName = 'ASI_TnE_SG_Claim_Detail' 
                and ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c in ('Final','Complete') and ASI_TnE_Account_Code__c like '%5559.ONPRE%')];
		
		for (ASI_CRM_AccountsAdditionalField__c outlet:outletFromTnE){
			custIDSet.add(outlet.id);
		}
		
		List<ASI_CRM_AccountsAdditionalField__c> outletFromPayment = [select id from ASI_CRM_AccountsAdditionalField__c where 
            id in (select ASI_MFM_Outlet__c from ASI_MFM_Payment__c where lastModifiedDate >= LAST_N_DAYS:7 and recordType.DeveloperName = 'ASI_MFM_SG_Payment_Read_Only' 
                and ASI_MFM_Status__c in ('Final','Complete'))];
		
		for (ASI_CRM_AccountsAdditionalField__c outlet:outletFromPayment){
			custIDSet.add(outlet.id);
		}

        /*[WL 1.0 Begin]*/
        /*List<ASI_FOC_Request_Item__c> focItemList = [select ASI_FOC_Request_Order__r.ASI_CRM_Outlet__c from ASI_FOC_Request_Item__c where recordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items') 
                and ASI_CRM_SG_A_G_Code__c in :marketingAGCode and ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Approved' and LastModifiedDate >= LAST_N_DAYS:7];

        		
        for (ASI_FOC_Request_Item__c focItem:focItemList){
            custIDSet.add(focItem.ASI_FOC_Request_Order__r.ASI_CRM_Outlet__c);
        }*/
		List<ASI_HK_CRM_Sales_Order_History_Detail__c> soHDetailList = [select id , ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c from ASI_HK_CRM_Sales_Order_History_Detail__c where recordTypeId = :Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail')
			and ASI_CRM_AG_Code__c in :marketingAGCode and ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c = :soOrderType and (ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c >= LAST_N_DAYS:7 OR ASI_CRM_Recalculate_Brand_Event_Held__c = true)];
        /*[WL 1.0 End]*/
		for (ASI_HK_CRM_Sales_Order_History_Detail__c soHDetail:soHDetailList){
			custIDSet.add(soHDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c);
		}
		
		/*[WL 3.0 Begin]*/
		List<ASI_TH_CRM_Contract__c> contractList = [select id, ASI_CRM_CN_Outlet_WS__c from  ASI_TH_CRM_Contract__c where ASI_CRM_Recalculate_Actual_ROI__c = true and recordType.DeveloperName = 'ASI_CRM_SG_Contract_Read_Only'];

		for (ASI_TH_CRM_Contract__c contract:contractList){
			custIDSet.add(contract.ASI_CRM_CN_Outlet_WS__c);
		}
		/*[WL 3.0 End]*/
		
		system.debug('custIDSet: ' + custIDSet);
		
		String finalQuery = null;
		
		if (custIDSet.size() > 0){
			//Only execute batch if there are T&E or MFM Payment which has been modified and is linked to outlet
			string Query = 'select id, Name from ASI_CRM_AccountsAdditionalField__c where id in (';
			integer counter = 0;
			
			for (ID cusID:custIDSet){
					Query += '\'' + cusID + '\',';
			}
			
			integer querylength = Query.Length();
			
			finalQuery = Query.substring(0,querylength-1) + ')';
		}
		else {
			//Query that return no result if no outlet need to be calculated
			finalQuery = 'select id, Name from ASI_CRM_AccountsAdditionalField__c where id = null';
		}
        system.debug('finalQuery: ' + finalQuery);
        return Database.getQueryLocator(finalQuery);
    }

    global void execute(Database.BatchableContext contextInstance, List<sObject> listsObject){
        system.debug('Debug: execute');     
        
        //Roll-up T&E Claim Amount and PO Amount into Contract Header T&E Market Visit & Brand Event Held for OBI Data Direct Report #9
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomerId_Record = new Map<Id, ASI_CRM_AccountsAdditionalField__c>( (List<ASI_CRM_AccountsAdditionalField__c>) listsObject );   
        
        List<ASI_TnE_ClaimDetail__c> claimDetailList = [select id, ASI_TnE_ClaimHeader__r.OwnerID, ASI_TnE_HK_Payment_Amount__c, ASI_TnE_Receipt_Date__c, 
            ASI_TnE_Outlet__c, ASI_TnE_Outlet__r.Name from ASI_TnE_ClaimDetail__c where ASI_TnE_Outlet__c in :mapCustomerId_Record.keySet() and recordType.DeveloperName = 'ASI_TnE_SG_Claim_Detail' 
                and ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c in ('Final','Complete') and ASI_TnE_Account_Code__c like '%5559.ONPRE%'];
        
        system.debug('Claim Detail List size: ' + claimDetailList.size());
        
        List<ASI_TH_CRM_Contract__c> contractList = [select id, OwnerID, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Outlet_WS__r.Name, ASI_TH_CRM_Start_Date__c, 
            ASI_TH_CRM_End_Date__c, ASI_CRM_T_E_Market_Visit_Outlet_Owner__c, ASI_CRM_T_E_Market_Visit_Others__c
                from ASI_TH_CRM_Contract__c where ASI_CRM_CN_Outlet_WS__c in :mapCustomerId_Record.keySet() and ASI_TH_CRM_Contract_Status__c = 'Contract Approved'];
        
        system.debug('Contract List size: ' + contractList.size());
        
        List<ASI_MFM_Payment__c> paymentList = [select id, ASI_MFM_G_L_Date__c,ASI_MFM_Outlet__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Payment_Amount__c 
            from ASI_MFM_Payment__c where ASI_MFM_Outlet__c in :mapCustomerId_Record.keySet() and ASI_MFM_Status__c in ('Final', 'Complete')];

        /*[WL 1.0 Begin]*/
		List<ASI_HK_CRM_Sales_Order_History_Detail__c> soHDetailList = [select id, ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c, ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c,
			ASI_CRM_Duty_Cost__c, ASI_CRM_FOB_Cost__c, ASI_CRM_Handling_Cost__c, ASI_HK_CRM_Quantity_in_Bottles__c 
				from ASI_HK_CRM_Sales_Order_History_Detail__c where recordTypeId = :Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail')
					and ASI_CRM_AG_Code__c in :marketingAGCode and ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c = :soOrderType and ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c in :mapCustomerId_Record.keySet()];
        /*[WL 1.0 End]*/ 

        for (ASI_TH_CRM_Contract__c contract: contractList){
            system.debug('Contract Outlet Name: ' + contract.ASI_CRM_CN_Outlet_WS__r.Name);
            decimal ownerTnE = 0;
            decimal otherTnE = 0;
            decimal brandEventHeld = 0;
            
            for (ASI_TnE_ClaimDetail__c claim:claimDetailList){
                system.debug('Claim Detail Outlet Name: ' + claim.ASI_TnE_Outlet__r.Name + ' Receipt Date: ' + claim.ASI_TnE_Receipt_Date__c + ' Payment Amount: ' + claim.ASI_TnE_HK_Payment_Amount__c);
                if (claim.ASI_TnE_Outlet__c == contract.ASI_CRM_CN_Outlet_WS__c && claim.ASI_TnE_Receipt_Date__c >= contract.ASI_TH_CRM_Start_Date__c && claim.ASI_TnE_Receipt_Date__c <= contract.ASI_TH_CRM_End_Date__c){
                    if (claim.ASI_TnE_HK_Payment_Amount__c != null){
                        if (claim.ASI_TnE_ClaimHeader__r.OwnerID == contract.OwnerID)
                            ownerTnE += claim.ASI_TnE_HK_Payment_Amount__c;
                        else 
                            otherTnE += claim.ASI_TnE_HK_Payment_Amount__c;
                    }
                }
            }
            
            for (ASI_MFM_Payment__c payment:paymentList){
                if (payment.ASI_MFM_Outlet__c == contract.ASI_CRM_CN_Outlet_WS__c && payment.ASI_MFM_G_L_Date__c >= contract.ASI_TH_CRM_Start_Date__c && payment.ASI_MFM_G_L_Date__c <= contract.ASI_TH_CRM_End_Date__c){
                    if (payment.ASI_MFM_Payment_Amount__c != null && payment.ASI_MFM_Exchange_Rate__c != null){
						Decimal basePaymentAmount = payment.ASI_MFM_Payment_Amount__c * payment.ASI_MFM_Exchange_Rate__c;
                        brandEventHeld += basePaymentAmount;
					}
                }
            }

            /*[WL 1.0 Begin]*/
			for (ASI_HK_CRM_Sales_Order_History_Detail__c soHDetail:soHDetailList){
				if (soHDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_CRM_AccountAdditionalField__c == contract.ASI_CRM_CN_Outlet_WS__c 
					&& soHDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c >= contract.ASI_TH_CRM_Start_Date__c+30
						&& soHDetail.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c <= contract.ASI_TH_CRM_End_Date__c+30){
					/*[WL 2.0 Begin]*/
					//brandEventHeld += (soHDetail.ASI_CRM_Duty_Cost__c + soHDetail.ASI_CRM_FOB_Cost__c + soHDetail.ASI_CRM_Handling_Cost__c) * soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
					if (soHDetail.ASI_CRM_Duty_Cost__c != null && soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c != null)
						brandEventHeld += soHDetail.ASI_CRM_Duty_Cost__c * soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
						
					if (soHDetail.ASI_CRM_FOB_Cost__c != null && soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c != null)
						brandEventHeld += soHDetail.ASI_CRM_FOB_Cost__c * soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
					
					if (soHDetail.ASI_CRM_Handling_Cost__c != null && soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c != null)
						brandEventHeld += soHDetail.ASI_CRM_Handling_Cost__c * soHDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
					/*[WL 2.0 End]*/
				}
			}
            /*[WL 1.0 End]*/

            contract.ASI_CRM_T_E_Market_Visit_Outlet_Owner__c = ownerTnE;
            contract.ASI_CRM_T_E_Market_Visit_Others__c = otherTnE;
            contract.ASI_CRM_Brand_Event_Held__c = brandEventHeld;
        }
        
        update contractList;
    }
    
   global void finish(Database.BatchableContext contextInstance){
   }
}