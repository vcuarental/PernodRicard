/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @12/30/2015 3:54 PM
 * Related Test Class: ASI_CRM_SG_ContractCloneController_Test, ASI_CRM_SG_ContractCloneCtrl_Test

 * 
 * Revision History:
 * 1.   12/30/2015 - [DC 1.0] Created
 * 2.   01/04/2016 - [DC 1.0] Added Revision History
 * 3.   01/04/2016 - [DC 2.0] Cleared value in ASI_CRM_CN_Outlet_WS__c for copy contract
 * 4.   01/05/2016 - [DC 3.0] Set the contract record type to "ASI CRM SG Contract"
 * 5.   01/08/2016 - [DC 4.0] Clone Contract Outlets related to the Contract
 * 6.  29 Jan 2016 - [VL 6.0] Patched by Vincent Lam; Set Contract Period Extended checkbox to FALSE for new contract
 *                 - [VL 6.1] Patched by Vincent Lam; Set End Date (Original) field to NULL for new contract
 * 7.  02 Feb 2016 - [VL 7.0] Patched by Vincent Lam; Set Version to NULL for new contract
 * 8.  12 Feb 2016 - [VL 8.0] Patched by Vincent Lam; Set Contract Period Extended Before checkbox to FALSE for new contract
 * 9.  17 Feb 2016 - [VL 9.0] Patched by Vincent Lam; Update Contract Period Extended Before to Contract Period Requesting To Extend
 * 10. 18 Feb 2016 - [VL 10.0] Patched by Vincent Lam; For SG CRM P2, set some fields of Payment Schedule to NULL for new contract
 * 11. 19 Feb 2016 - [VL 11.0] Patched by Vincent Lam; For SG CRM P2, set Inflation Rate and Distribution Rate to NULL for new contract
 * 12. 03 Mar 2016 - [VL 12.0] Patched by Vincent Lam; For SG CRM P2, actually SG users don't have access to ASI_CRM_SG_AdhocOthers object
 * 13. 04 Mar 2016 - [VL 13.0] Patched by Vincent Lam; For SG CRM P2, snap a full copy for revising contract
 * 14. 14 Mar 2016 - [VL 14.0] Patched by Vincent Lam; For SG CRM P2, set Till Date Sales Volume (9L) to NULL for new contract
 *                   [VL 14.1] Patched by Vincent Lam; Do not clone Contract Outlet if it is COPY
 * 15. 23 Mar 2016 - [VL 15.0] Patched by Vincent Lam; For SG CRM P2, revise the logic for revising contract
 * 16. 11 Apr 2016 - [VL 16.0] Patched by Vincent Lam; Cater proposal
 * 17. 12 Apr 2016 - [VL 17.0] Patched by Vincent Lam; for revising, put the original contract no. to created FOC/Payment request
 * 18. 13 Apr 2016 - [VL 18.0] Patched by Vincent Lam; cater converting proposal to contract
 * 19. 14 Apr 2016 - [VL 19.0] Patched by Vincent Lam; cater revising for both proposal and contract
 * 20. 15 Apr 2016 - [VL 20.0] Patched by Vincent Lam; since there is additional digits for proposal no., when convert to convert, cut them
 * 21. 18 Apr 2016 - [VL 21.0] Patched by Vincent Lam; on all clone, change Alerted (30/60 days) to false
 * 22. 16 May 2016 - [VL 22.0] Patched by Vincent Lam; Use PR's Global_RecordTypeCache to get the record type ID
 * 23. 19 May 2016 - [VL 23.0] Patched by Vincent Lam; Clear all actual performance fields for Copy / Renew contract
 * 24. 23 May 2016 - [HC 1.0] Roll back the database when error occur
 * 25. 28 Dec 2016 - [HC 2.0] SG CRM P3 Change Request #A5 (Old contract status must be Approved)
 * 26. 30 Dec 2016 - [VL 24.0] Since new logic in P3 (revised original contract as Approved status), update Revision No. calculation
 * 27. 18 Jan 2017 - [VL 25.0] P3 logic, move all offtake, payment, FOC to original contract
 * 28. 04 May 2017 - [VL 26.0] Bug fix to correct proposal approved status
 * 28. 18 May 2017 - [VL 27.0] Clone Sales Agreement detail
 * 29. 07 Jul 2017 - [VL 28.0] When user click Renew / Copy, it will become Proposal even the original one is contract
 * 29. 31 Oct 2017 - [WL 29.0] Modify Convert Proposal to Contract to be Approved Contract
 * 30. 23 Feb 2018 - [WL 30.0] Clone Proposal Attachment to Contract when converted
 **********************************************************************************/

public without sharing class ASI_CRM_SG_ContractCloneController {

    public static final String DRAFT_STATUS = 'Draft';
    public static final String APPROVED_STATUS = 'Contract Approved';
    public static final String ARCHIVED_STATUS = 'Archived';
    public static final String CONVERTED_STATUS = 'Proposal Converted';
    
    public List<ASI_TH_CRM_Contract__c> contractList;
    public List<ASI_TH_CRM_Contract__c> contractList_ToInsert = new List<ASI_TH_CRM_Contract__c>();
    public List<ASI_TH_CRM_Contract__c> contractList_ToUpdate = new List<ASI_TH_CRM_Contract__c>();
    public List<ASI_CRM_Payment_Schedule__c> paymentScheduleList;
    public List<ASI_CRM_Payment_Schedule__c> paymentScheduleList_ToInsert = new List<ASI_CRM_Payment_Schedule__c>();
    public List<ASI_CRM_ContractTarget__c> contractTargetList;
    public List<ASI_CRM_ContractTarget__c> contractTargetList_ToInsert = new List<ASI_CRM_ContractTarget__c>();
    /* [VL 12.0] BEGIN */
    /*
    public List<ASI_CRM_SG_AdhocOther__c> adhocList;
    public List<ASI_CRM_SG_AdhocOther__c> adhocList_ToInsert = new List<ASI_CRM_SG_AdhocOther__c>();
    */
    /* [VL 12.0] END */
    public List<ASI_CRM_Contract_Outlets__c> contractOutletList;
    public List<ASI_CRM_Contract_Outlets__c> contractOutletList_ToInsert = new List<ASI_CRM_Contract_Outlets__c>();

    public ASI_TH_CRM_Contract__c tempContract;
    public ASI_CRM_Payment_Schedule__c tempPaymentSchedule;
    public ASI_CRM_ContractTarget__c tempContractTarget;
    /* [VL 12.0] BEGIN */
    /*
    public ASI_CRM_SG_AdhocOther__c tempAdhoc;
    */
    /* [VL 12.0] END */
    public ASI_CRM_Contract_Outlets__c tempContractOutlet;
    
    /* [VL 16.0] BEGIN */
    Map<id, id> map_readOnly_archived = new Map<id, id>();
    Map<id, id> map_readOnly_draft = new Map<id, id>();
    /* [VL 16.0] END */
    /* [VL 26.0] BEGIN */
    Map<id, string> map_readOnly_approved = new Map<id, string>();
    /* [VL 26.0] END */

    /* [VL 19.0] BEGIN */
    Map<id, string> map_recordTypeId_recordType = new Map<id, string>();
    /* [VL 19.0] END */

    public Id headerId = ApexPages.currentPage().getParameters().get('id');
    public Integer checkCopy = Integer.valueOf(ApexPages.currentPage().getParameters().get('copy'));
    // Switch (checkCopy):
    // case 0 = Renew contract
    // case 1 = copy contract
    // case 2 = revise contract
    // case 3 = convert proposal to contract
    

    public ASI_CRM_SG_ContractCloneController(ApexPages.StandardController controller) {
        
    }

    public pageReference cloneContracts() {
    
        /* [VL 16.0] BEGIN */
        /* [VL 22.0] BEGIN */
        /*
        id contractReadOnly = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Contract (Read-Only)').getRecordTypeId();
        id proposalReadOnly = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Proposal (Read-Only)').getRecordTypeId();
        id contractDraft = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Contract').getRecordTypeId();
        id proposalDraft = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Proposal').getRecordTypeId();
        */
        id contractReadOnly = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
        id proposalReadOnly = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');
        id contractDraft = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract');
        id proposalDraft = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        /* [VL 22.0] END */
        
        map_readOnly_archived.put(
            contractReadOnly,
            /* [VL 22.0] BEGIN */
            /*
            Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Contract (Snapshot)').getRecordTypeId()
            */
            Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Archived')
            /* [VL 22.0] END */
        );
        map_readOnly_archived.put(
            proposalReadOnly,
            /* [VL 22.0] BEGIN */
            /*
            Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Proposal (Snapshot)').getRecordTypeId()
            */
            Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Archived')
            /* [VL 22.0] END */
        );
        map_readOnly_draft.put(
            contractReadOnly,
            contractDraft
        );
        map_readOnly_draft.put(
            proposalReadOnly,
            proposalDraft
        );
        map_readOnly_draft.put(
            contractDraft,
            contractDraft
        );
        map_readOnly_draft.put(
            proposalDraft,
            proposalDraft
        );
        /* [VL 16.0] END */
        /* [VL 26.0] BEGIN */
		map_readOnly_approved.put(
			proposalReadOnly, 'Proposal Approved'
		);
		map_readOnly_approved.put(
			contractReadOnly, 'Contract Approved'
		);
        /* [VL 26.0] END */
        
        /* [VL 19.0] BEGIN */
        map_recordTypeId_recordType.put(
            proposalReadOnly,
            'ASI_CRM_SG_Proposal'
        );
        map_recordTypeId_recordType.put(
            contractReadOnly,
            'ASI_CRM_SG_Contract'
        );
        /* [VL 19.0] END */
        
        /*** Contract Data Start ***/
        String contractQuery = buildQuery('ASI_TH_CRM_Contract__c');
        contractQuery += ' WHERE Id = :headerId';
        contractList = database.query(contractQuery);
        
        System.debug('------ contractList ------ : ' + contractList);
        
        ID originalContractID = NULL;
        String originalContractName = '';
        
        /* [VL 17.0] BEGIN */
        List<ASI_TH_CRM_PaymentRequest__c> list_paymentHeader = new List<ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_FOC_Free_Goods_Request__c> list_focHeader = new List<ASI_FOC_Free_Goods_Request__c>();
        List<ASI_TH_CRM_PaymentRequest__c> list_paymentHeader_toUpdate = new List<ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_FOC_Free_Goods_Request__c> list_focHeader_toUpdate = new List<ASI_FOC_Free_Goods_Request__c>();
        /* [VL 25.0] BEGIN */
        List<ASI_TH_CRM_Actual_Offtake__c> list_offtake = new List<ASI_TH_CRM_Actual_Offtake__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> list_offtake_toUpdate = new List<ASI_TH_CRM_Actual_Offtake__c>();
        /* [VL 25.0] END */
        
        if (checkCopy == 2){
            list_paymentHeader = [select id, ASI_CRM_Contract_No_Original__c   from ASI_TH_CRM_PaymentRequest__c 
                            where ASI_TH_CRM_Contract__c = :contractList[0].id
            /* [VL 25.0] BEGIN */
                            //AND ASI_CRM_Contract_No_Original__c = null
            /* [VL 25.0] END */
                                 ];
            list_focHeader = [select id, ASI_CRM_Contract_No_Original__c   from ASI_FOC_Free_Goods_Request__c 
                            where ASI_CRM_Contract__c = :contractList[0].id
            /* [VL 25.0] BEGIN */
                            //AND ASI_CRM_Contract_No_Original__c = null
            /* [VL 25.0] END */
                             ];
            /* [VL 25.0] BEGIN */
            list_offtake = [select id  from ASI_TH_CRM_Actual_Offtake__c 
                            where ASI_CRM_Contract__c = :contractList[0].id];
            /* [VL 25.0] END */
            system.debug('####### list_paymentHeader'+list_paymentHeader);
            system.debug('####### list_focHeader'+list_focHeader);
        }
        
        for(ASI_TH_CRM_Contract__c contractIterator : contractList) {
            tempContract = contractIterator.clone(false, true, false, false);
            
            // setup the contract
            /* VL 9.0 BEGIN */
            /*
            tempContract.ASI_CRM_Contract_Period_Extended_Before__c = false;
            */
            tempContract.ASI_CRM_Contract_Period_Req_To_Extend__c = false;
            /* VL 9.0 END */
            
            /* VL 13.0 BEGIN - add this big IF for revising contract operation */
            if (checkCopy == 2) {
                // hide this part for CR deployment
                // VL 13.0 - revise the Contract No. with new version
                if (contractIterator.ASI_CRM_Original_Version__c == NULL) {
                    tempContract.name = contractIterator.name;
                } else {
                    originalContractID = contractIterator.ASI_CRM_Original_Version__c;
                    originalContractName = [select name from ASI_TH_CRM_Contract__c where id = :originalContractID limit 1].get(0).name;
                    List<ASI_TH_CRM_Contract__c> contract_previousVersion_list = 
                        Database.query('Select Name from ASI_TH_CRM_Contract__c where name like \'' + originalContractName + 
                                       '%\' and ASI_TH_CRM_Contract_Status__c = \'Archived\'' 
                                       /* [VL 19.0] BEGIN */                                       
                                       + ' AND recordtype.developerName like \'' + map_recordTypeId_recordType.get(tempContract.RecordTypeId) + '%\''
                                       + ' AND id <> \'' + contractIterator.id + '\''
                                       /* [VL 19.0] END */                                   
                                      );
                    tempContract.name = originalContractName + ' Rev. ' + contract_previousVersion_list.size();
                    tempContract.ASI_CRM_Version__c = string.valueof(contract_previousVersion_list.size());
                }
                /* [VL 16.0] BEGIN */
                /*
                tempContract.RecordTypeId =
                    Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Contract (Archived)').getRecordTypeId();
                */
                /* [VL 25.0] BEGIN */
                /*
                tempContract.RecordTypeId = map_readOnly_archived.get(tempContract.RecordTypeId);
				*
                /* [VL 25.0] END */
                /* [VL 16.0] END */

                /* [HC 2.0] BEGIN */
                /* [VL 26.0] BEGIN */
				/*
                tempContract.ASI_TH_CRM_Contract_Status__c = APPROVED_STATUS;
				*/
				tempContract.ASI_TH_CRM_Contract_Status__c = map_readOnly_approved.get(tempContract.RecordTypeId);
                /* [VL 26.0] END */
                /* [HC 2.0] END */
                
                /* [VL 17.0] BEGIN */
                if (list_paymentHeader.size()>0){
                    for (ASI_TH_CRM_PaymentRequest__c paymentHeader : list_paymentHeader) {
                        if (paymentHeader.ASI_CRM_Contract_No_Original__c == null){
                            paymentHeader.ASI_CRM_Contract_No_Original__c = tempContract.name;
                        	list_paymentHeader_toUpdate.add(paymentHeader);
                        }
                        
                    }
                }
                if (list_focHeader.size()>0){
                    for (ASI_FOC_Free_Goods_Request__c focHeader : list_focHeader) {
                        if (focHeader.ASI_CRM_Contract_No_Original__c == null) {
                            focHeader.ASI_CRM_Contract_No_Original__c = tempContract.name;
                        	list_focHeader_toUpdate.add(focHeader);
                        }
                        
                    }
                }
                /* [VL 17.0] END */
            } else
            /* [VL 18.0] BEGIN */
            if (checkCopy == 3) {
                string newContractNo = '';
                if (contractIterator.ASI_CRM_Original_Version__c == NULL) {
                    newContractNo = contractIterator.name;
                } else {
                    originalContractID = contractIterator.ASI_CRM_Original_Version__c;
                    newContractNo = [select name from ASI_TH_CRM_Contract__c where id = :originalContractID limit 1].get(0).name;
                }
                /* [VL 20.0] BEGIN */
                tempContract.name = newContractNo.substring(0,15);
                /* [VL 20.0] BEGIN */
                tempContract.ASI_CRM_Original_Version__c = null;
                tempContract.ASI_CRM_Version__c = NULL;
				
				/* [WL 29.0] BEGIN */
                //tempContract.RecordTypeId = contractDraft;
				//tempContract.ASI_TH_CRM_Contract_Status__c = DRAFT_STATUS;
				tempContract.RecordTypeId = contractReadOnly;
				tempContract.ASI_TH_CRM_Contract_Status__c = APPROVED_STATUS;				
				/*[WL 29.0] END */
				
                tempContract.ASI_CRM_Converted_From__c = contractIterator.id;
                /* [VL 21.0] BEGIN */
                tempContract.ASI_CRM_Alerted_30_Days_Before_End__c = false;
                tempContract.ASI_CRM_Alerted_60_Days_Before_End__c = false;
                /* [VL 21.0] BEGIN */
                tempContract.ASI_CRM_ROI_of_Original_Version__c = null;
            } else
            /* [VL 18.0] END */ 
            {
                tempContract.ASI_TH_CRM_Contract_Status__c = DRAFT_STATUS;
                tempContract.ASI_TH_CRM_End_Date__c = NULL;
                tempContract.ASI_TH_CRM_Start_Date__c = NULL;
                /* VL 6.0 BEGIN */
                tempContract.ASI_CRM_Contract_Period_Extended__c = false;
                /* VL 6.0 END */
                /* VL 6.1 BEGIN */
                tempContract.ASI_CRM_End_Date_Original__c = NULL;
                /* VL 6.1 END */
                /* VL 7.0 BEGIN */
                tempContract.ASI_CRM_Version__c = NULL;
                /* VL 7.0 END */
                /* VL 8.0 BEGIN */
                /* VL 8.0 END */
                /* VL 11.0 BEGIN */
                tempContract.ASI_CRM_Distribution_Rate__c = NULL;
                tempContract.ASI_CRM_Inflation_Rate__c = NULL;
                /* VL 11.0 END */
                /* VL 13.0 BEGIN */
                tempContract.ASI_CRM_Original_Version__c = NULL;
                /* VL 13.0 END */
                /* VL 14.0 BEGIN */
                tempContract.ASI_CRM_Till_Date_Sales_Volume_9L__c = NULL;
                /* VL 14.0 END */
                /* VL 18.0 BEGIN */
                tempContract.ASI_CRM_Converted_From__c = NULL;
                /* VL 18.0 END */
                tempContract.OwnerId = UserInfo.getUserId();
                if(checkCopy == 1) {
                    tempContract.ASI_TH_CRM_Outlet__c = NULL;
                    tempContract.ASI_CRM_CN_Outlet_WS__c = NULL; // DC 2.0
                }
                /* [VL 21.0] BEGIN */
                tempContract.ASI_CRM_Alerted_30_Days_Before_End__c = false;
                tempContract.ASI_CRM_Alerted_60_Days_Before_End__c = false;
                /* [VL 21.0] BEGIN */
                /* [VL 23.0] BEGIN */
                tempContract.ASI_CRM_Sales_Revenue__c = NULL;
                tempContract.ASI_CRM_ContractMarginPriceOverwrite_Act__c = NULL;
                //tempContract.ASI_CRM_ContractMarginPriceOverwrite_Rev__c = NULL;
                tempContract.ASI_CRM_Total_Duty_Actual__c = NULL;
                tempContract.ASI_CRM_Total_FOB_Actual__c = NULL;
                tempContract.ASI_CRM_Total_Handling_Cost_Actual__c = NULL;
                tempContract.ASI_CRM_Free_Goods_Actual__c = NULL;
                tempContract.ASI_CRM_Free_Goods_Revised__c = NULL;
                tempContract.ASI_CRM_Free_Goods_Ad_hoc_Actual__c = NULL;
                tempContract.ASI_CRM_Free_Goods_Ad_hoc_Revised__c = NULL;
                tempContract.ASI_CRM_Cash_Sponsorship_Actual__c = NULL;
                tempContract.ASI_CRM_Cash_Sponsorship_Revised__c = NULL;
                tempContract.ASI_CRM_Bottle_Incentive_Actual__c = NULL;
                tempContract.ASI_CRM_Bottle_Incentive_Revised__c = NULL;
                tempContract.ASI_CRM_Trade_A_P_Expenses_Actual__c = NULL;
                tempContract.ASI_CRM_Trade_A_P_Expenses_Revised__c = NULL;
                tempContract.ASI_CRM_Sales_Support_Actual__c = NULL;
                tempContract.ASI_CRM_Sales_Support_Revised__c = NULL;
				tempContract.ASI_CRM_A_P_Free_Goods_Actual__c = NULL;
				tempContract.ASI_CRM_A_P_Payment_Actual__c = NULL;
				tempContract.ASI_CRM_Blind_Bonus_Actual__c = NULL;
				tempContract.ASI_CRM_Free_Goods_9L_Actual__c = NULL;
				tempContract.ASI_CRM_Prompt_Payment_Actual__c = NULL;
				tempContract.ASI_CRM_Total_FOB_Free_Goods_Actual__c = NULL;
				tempContract.ASI_CRM_Total_Handling_Cost_FOC_Actual__c = NULL;
				tempContract.ASI_CRM_Brand_Event_Held__c = NULL;
				tempContract.ASI_CRM_T_E_Market_Visit_Others__c = NULL;
				tempContract.ASI_CRM_T_E_Market_Visit_Outlet_Owner__c = NULL;
                /* [VL 23.0] BEGIN */
                tempContract.ASI_CRM_ROI_of_Original_Version__c = null;
                // DC 3.0
                /* [VL 16.0] BEGIN */
                /*
                tempContract.RecordTypeId =
                    Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Contract').getRecordTypeId();
                */
				/* [VL 28.0] BEGIN */
				/*
                tempContract.RecordTypeId = map_readOnly_draft.get(tempContract.RecordTypeId);
				*/
                tempContract.RecordTypeId = proposalDraft;
				/* [VL 28.0] END */
                /* [VL 16.0] END */
            }  
            /* VL 13.0 END */
            
            contractList_ToInsert.add(tempContract);
        }
        
        /* [HC 1.0] BEGIN */
        Savepoint savepointInsertContract = Database.setSavepoint();
        try {
            system.debug(contractList_ToInsert);
            database.insert(contractList_ToInsert);
            system.debug(contractList_ToInsert);
        } catch(Exception e) {
            Database.rollback(savepointInsertContract);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            //ApexPages.addMessage(myMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        /* [HC 1.0] END */
		
		/*[WL 30.0] BEGIN*/
		if (checkCopy == 3) {
			Attachment[] attList = [select id, name, body from Attachment where ParentId = :headerId];
			Attachment[] insertAttList = new Attachment[]{}; 

			for(Attachment a: attList){
               Attachment att = new Attachment(name = a.name, body = a.body, parentid = contractList_ToInsert.get(0).id);
               insertAttList.add(att);
			}
			
			if(insertAttList.size() > 0){
				insert insertAttList;
			}			
		}
		/*[WL 30.0] BEGIN*/

        /* [HC 1.0] BEGIN */
        Savepoint savepointUpdateContract = Database.setSavepoint();
        try {
            /* [VL 15.0] BEGIN */
            if (checkCopy == 2) {
                for(ASI_TH_CRM_Contract__c contractIterator : contractList) {
                    contractIterator.ASI_TH_CRM_Contract_Status__c = DRAFT_STATUS;
                    contractIterator.ASI_CRM_Original_Version__c = contractIterator.ASI_CRM_Original_Version__c == NULL ? contractList_ToInsert[0].Id : contractIterator.ASI_CRM_Original_Version__c;
                    originalContractID = contractIterator.ASI_CRM_Original_Version__c;
                    ASI_TH_CRM_Contract__c originalContractObject = [select name, ASI_CRM_ROI__c from ASI_TH_CRM_Contract__c where id = :originalContractID limit 1].get(0);
                    originalContractName = originalContractObject.name;
                    List<ASI_TH_CRM_Contract__c> contract_previousVersion_list = 
                        Database.query('Select Name from ASI_TH_CRM_Contract__c where name like \'' + originalContractName + 
                                       '%\' and ASI_TH_CRM_Contract_Status__c = \'Archived\''
                                       /* [VL 19.0] BEGIN */                                       
                                       + ' AND recordtype.developerName like \'' + map_recordTypeId_recordType.get(contractIterator.RecordTypeId) + '%\''
                                       + ' AND id <> \'' + contractIterator.id + '\''
                                       /* [VL 19.0] END */                                   
                                      );
                    /* [VL 24.0] BEGIN */
                    /*
                    contractIterator.name = originalContractName + ' Rev. ' + contract_previousVersion_list.size();
                    contractIterator.ASI_CRM_Version__c = string.valueof(contract_previousVersion_list.size());
                    */
                    contractIterator.name = originalContractName + ' Rev. ' + (contract_previousVersion_list.size() + 1) ;
                    contractIterator.ASI_CRM_Version__c = string.valueof(contract_previousVersion_list.size()+1);
                    /* [VL 24.0] END */
                    contractIterator.ASI_CRM_ROI_of_Original_Version__c = originalContractObject.ASI_CRM_ROI__c;
                    /* [VL 16.0] BEGIN */
                    contractIterator.RecordTypeId = map_readOnly_draft.get(contractIterator.RecordTypeId);
                    /* [VL 16.0] END */
                    contractIterator.ASI_CRM_Revising__c = true;
                    /* [VL 21.0] BEGIN */
                    contractIterator.ASI_CRM_Alerted_30_Days_Before_End__c = false;
                    contractIterator.ASI_CRM_Alerted_60_Days_Before_End__c = false;
                    /* [VL 21.0] BEGIN */
                    contractList_ToUpdate.add(contractIterator);
                    system.debug(contractIterator);
                }
                system.debug(contractList_ToUpdate);
                database.update(contractList_ToUpdate);
                
                system.debug('------------list_paymentHeader_toUpdate------------'+list_paymentHeader_toUpdate);
                system.debug('------------list_focHeader_toUpdate------------'+list_focHeader_toUpdate);
                /* [VL 17.0] BEGIN */
                if (list_paymentHeader_toUpdate.size()>0){
                     database.update(list_paymentHeader_toUpdate);
                }
                if (list_focHeader_toUpdate.size()>0){
                     database.update(list_focHeader_toUpdate);
                }
                /* [VL 17.0] END */
                
                contractList_ToUpdate = new List<ASI_TH_CRM_Contract__c>();
                for(ASI_TH_CRM_Contract__c contractIterator : contractList) {
                    //contractIterator.ASI_CRM_Revising__c = false;
                    //contractList_ToUpdate.add(contractIterator);
                    contractList_ToUpdate.add(new ASI_TH_CRM_Contract__c(
                        id = contractIterator.id,
                        ASI_CRM_Revising__c = false
                    ));
                    system.debug(contractIterator);
                }
                system.debug(contractList_ToUpdate);
                database.update(contractList_ToUpdate);
                
            }
            /* [VL 15.0] END */
            /* [VL 18.0] BEGIN */
            else if (checkCopy == 3) {
                for(ASI_TH_CRM_Contract__c contractIterator : contractList) {
                    contractIterator.ASI_TH_CRM_Contract_Status__c = CONVERTED_STATUS;
                    contractList_ToUpdate.add(contractIterator);
                    system.debug(contractIterator);
                }
                system.debug(contractList_ToUpdate);
                database.update(contractList_ToUpdate);
            }
            /* [VL 18.0] END */

        } catch(Exception e) {  
            //Database.rollback(savepointUpdateContract);
            Database.rollback(savepointInsertContract);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            //ApexPages.addMessage(myMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        /* [HC 1.0] END */

        /*** Contract Data End ***/

        // DC 4.0
        /*** Contract Outlet Data Start ***/
        /* VL 14.1 BEGIN */
        if (checkCopy != 1) {
        /* VL 14.1 END */
            String contractOutletQuery = buildQuery('ASI_CRM_Contract_Outlets__c');
            contractOutletQuery += ' WHERE ASI_CRM_SG_Contract__c = :headerId AND recordtype.developername = \'ASI_CRM_SG_Contract_Outlet\'';
            contractOutletList = database.query(contractOutletQuery);
            
            for(ASI_CRM_Contract_Outlets__c contractOutletIterator : contractOutletList) {
                tempContractOutlet = contractOutletIterator.clone(false, true, false, false);
                tempContractOutlet.ASI_CRM_SG_Contract__c = contractList_ToInsert[0].Id;
                contractOutletList_ToInsert.add(tempContractOutlet);
            }
            
            /* [HC 1.0] BEGIN */
            Savepoint savepointOutlet = Database.setSavepoint();
            try {
                database.insert(contractOutletList_ToInsert);
            }  catch(Exception e) {  
                //Database.rollback(savepointOutlet);
                Database.rollback(savepointInsertContract);
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                //ApexPages.addMessage(myMsg);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }
            /* [HC 1.0] END */
        /* VL 14.1 BEGIN */
        }
        /* VL 14.1 END */
        /*** Contract Outlet Data End ***/
        
        /*** Payment Schedule Data Start ***/
        String paymentScheduleQuery = buildQuery('ASI_CRM_Payment_Schedule__c');
        paymentScheduleQuery += ' WHERE ASI_CRM_Contract__c = :headerId AND recordtype.developername = \'ASI_CRM_SG_Payment_Schedule\'';
        paymentScheduleList = database.query(paymentScheduleQuery);
        
        for(ASI_CRM_Payment_Schedule__c paymentIterator : paymentScheduleList) {
            tempPaymentSchedule = paymentIterator.clone(false, true, false, false);
            tempPaymentSchedule.ASI_CRM_Contract__c = contractList_ToInsert[0].Id;
            /* VL 10.0 BEGIN */
            // for backup archived contract, no need to update the payment schedule status
            /*
            tempPaymentSchedule.ASI_CRM_Payment_Issued__c = false;
            tempPaymentSchedule.ASI_CRM_Alerted__c = false;
            */
            /* VL 10.0 END */
            paymentScheduleList_ToInsert.add(tempPaymentSchedule);
        }
        
        /* [HC 1.0] BEGIN */
        Savepoint savepointSchedule = Database.setSavepoint();
        try {
            database.insert(paymentScheduleList_ToInsert);
        }  catch(Exception e) {  
            //Database.rollback(savepointSchedule);
            Database.rollback(savepointInsertContract);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
           // ApexPages.addMessage(myMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        /* [HC 1.0] END */
        /*** Payment Schedule Data End ***/
		
		
        /* [VL 27.0] BEGIN */
        /*** Sales Agreement Data Start ***/
		List<ASI_CRM_Contract_Printout_Setting__c> salesAgreementList_ToInsert = new List<ASI_CRM_Contract_Printout_Setting__c>();
		List<ASI_CRM_Contract_Printout_Setting__c> salesAgreementList = new List<ASI_CRM_Contract_Printout_Setting__c>();
        String salesAgreementQuery = buildQuery('ASI_CRM_Contract_Printout_Setting__c');
        salesAgreementQuery += ' WHERE ASI_CRM_Contract__c = :headerId';
        salesAgreementList = database.query(salesAgreementQuery);
        
        for(ASI_CRM_Contract_Printout_Setting__c paymentIterator : salesAgreementList) {
            ASI_CRM_Contract_Printout_Setting__c tempSalesAgreement = paymentIterator.clone(false, true, false, false);
            tempSalesAgreement.ASI_CRM_Contract__c = contractList_ToInsert[0].Id;
            salesAgreementList_ToInsert.add(tempSalesAgreement);
        }
        
        try {
            database.insert(salesAgreementList_ToInsert);
        }  catch(Exception e) {  
            Database.rollback(savepointInsertContract);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        /*** Payment Schedule Data End ***/
        /* [VL 27.0] END */
        
        /*** Contract Target Data Start ***/
        String contractTargetQuery = buildQuery('ASI_CRM_ContractTarget__c');
        contractTargetQuery += ' WHERE ASI_CRM_Contract__c = :headerId AND recordtype.developername = \'ASI_CRM_SG_Contract_Target\'';
        contractTargetList = database.query(contractTargetQuery);
        
        Set<Id> set_ContractTargetIds = new Set<Id>();
        
        for(ASI_CRM_ContractTarget__c targetIterator : contractTargetList) {
            set_ContractTargetIds.add(targetIterator.Id);
            tempContractTarget = targetIterator.clone(false, true, false, false);
            tempContractTarget.ASI_CRM_Contract__c = contractList_ToInsert[0].Id;
            contractTargetList_ToInsert.add(tempContractTarget);
        }
        
        /* [HC 1.0] BEGIN */
        Savepoint savepointTarget = Database.setSavepoint();
        try {
            database.insert(contractTargetList_ToInsert);
        }  catch(Exception e) {  
            //Database.rollback(savepointTarget);
            Database.rollback(savepointInsertContract);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            //ApexPages.addMessage(myMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        /* [HC 1.0] END */
        
        Map<Id, Id> mapSourceId_ClonedId = new Map<Id, Id>();
        
        for(ASI_CRM_ContractTarget__c targetIterator : contractTargetList_ToInsert) {
            if(set_ContractTargetIds.contains(targetIterator.getCloneSourceId())) {
                mapSourceId_ClonedId.put(targetIterator.getCloneSourceId(), targetIterator.Id);
            }
        }
        /*** Contract Target Data End ***/
        
        /* [VL 12.0] BEGIN */
        /*** Adhoc Data Start ***/
        /*
        String adhocQuery = buildQuery('ASI_CRM_SG_AdhocOther__c');
        adhocQuery += ' WHERE ASI_CRM_SG_Contract_Target__c = :set_ContractTargetIds';
        adhocList = database.query(adhocQuery);
        
        for(ASI_CRM_SG_AdhocOther__c adhocIterator : adhocList) {
            tempAdhoc = adhocIterator.clone(false, true, false, false);
            tempAdhoc.ASI_CRM_SG_Contract_Target__c = mapSourceId_ClonedId.get(adhocIterator.ASI_CRM_SG_Contract_Target__c);
            adhocList_ToInsert.add(tempAdhoc);
        }
        
        database.insert(adhocList_ToInsert, false);
        */
        /*** Adhoc Data End ***/
        /* [VL 12.0] END */
        
        if (checkCopy == 2) {
            /* [VL 25.0] BEGIN */
            if (list_paymentHeader.size()>0){
                for (ASI_TH_CRM_PaymentRequest__c paymentHeader : list_paymentHeader) {
                    paymentHeader.ASI_TH_CRM_Contract__c = contractList_ToInsert[0].Id;
                }
                update list_paymentHeader;
            }
            if (list_focHeader.size()>0){
                for (ASI_FOC_Free_Goods_Request__c focHeader : list_focHeader) {
                    focHeader.ASI_CRM_Contract__c = contractList_ToInsert[0].Id;
                }
                update list_focHeader;
            }
            if (list_offtake.size()>0){
                for (ASI_TH_CRM_Actual_Offtake__c offtakeHeader : list_offtake) {
                    offtakeHeader.ASI_CRM_Contract__c = contractList_ToInsert[0].Id;
                }
                update list_offtake;
            }
            /* [VL 25.0] END */
            return new PageReference('/'+contractList_ToUpdate[0].Id);   
        } else {
            return new PageReference('/'+contractList_ToInsert[0].Id);   
        }
              
    }
    
    // Method to build query dynamically. pass sobject API name as parameter (e.g. Custom_Object__c)
    public String buildQuery(String sObjectName) {
        String query = 'SELECT ';
        Schema.SObjectType selectedObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> fieldResult = selectedObjectType.getDescribe()
                                                                         .fields
                                                                         .getMap();

        for(String fieldName : fieldResult.keySet()) {
            //if(fieldResult.get(fieldName).getDescribe().isCreateable() == true) {
                query += fieldName + ', ';
            //}
        }
        
        query = query.removeEnd(', ');
        
        query += ' FROM ' + sObjectName;
        
        System.debug(' ---- query ---- : ' + query);
        return query;
    }
    
}