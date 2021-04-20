public with sharing class ASI_MFM_TR_CompletionPOController {
	public Id planRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan');
	public Id poRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO');
	public Id poRTID2 = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO_Read_Only');
	public Id cpoLineRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item_Capex__cASI_MFM_TR_PO_Line_Item');
	
	public List<ASI_MFM_Plan__c> plans { get; set; }
	public List<ASI_MFM_PO__c> pos { get; set; }
	public Id planID { get; set; }
	public Id poID { get; set; }

	public Boolean canComplete { get; set; }

	public ASI_MFM_TR_CompletionPOController() {
		canComplete = true;
		planID = Apexpages.currentPage().getParameters().get('pID');
		poID = Apexpages.currentPage().getParameters().get('poID');

		if (planID != null) {
			plans = [select 
					Id, Name, ASI_MFM_Status__c, ASI_MFM_Reference_1_List__c,
					ASI_MFM_Start_Date__c, ASI_MFM_End_Date__c, 
					ASI_MFM_Plan_Amount__c, ASI_MFM_Total_PO_Amount__c,
					ASI_MFM_TR_Duration_Month__c, ASI_MFM_TR_PlanCompletionDate__c,
                    ASI_MFM_Actual_Depreciation_Start_Date__c                 // [SH] 2019-03-29
					from ASI_MFM_Plan__c 
					where Id = :planID and recordtypeid = :planRTID];

			if (plans.size() == 0 || plans[0].ASI_MFM_Reference_1_List__c != 'CAPEX Plan') {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Only Capex Plan can be completed with depreciation'));
            	canComplete = false;
			}
			else if (plans[0].ASI_MFM_Status__c == 'Complete') {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Capex Plan has already been completed'));
            	canComplete = false;
			}
			else if (plans.size() > 0 && plans[0].ASI_MFM_TR_PlanCompletionDate__c == null) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please fill in Plan Completion date before complete'));
				canComplete = false;
			}

			pos = [select 
					Id, Name, ASI_MFM_Invoice_Amount_from_JDE__c, ASI_MFM_TR_POCompletionDate__c,
					ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c, ASI_MFM_Reference_2__c, ASI_MFM_Status__c,
					ASI_MFM_Exchange_Rate__c
					from ASI_MFM_PO__c 
					where ASI_MFM_Plan__c = :planID
					and ASI_MFM_TR_POCompletionDate__c = null
					and ASI_MFM_Reference_2__c = 'Capex'
					and recordtypeid in (:poRTID, :poRTID2)];
		}

		if (plans.size() > 0 && pos.size() == 0) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'No Capex POs can be completed found in this Capex Plan'));
            canComplete = false;
		}

		if (pos.size() > 0) {
			for (ASI_MFM_PO__c po : pos) {
				if (po.ASI_MFM_Status__c == 'Draft' || po.ASI_MFM_Status__c == 'Submitted' || po.ASI_MFM_Status__c == 'Final') {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Capex Plan cannot be completed because there are existing POs not approved'));
            		canComplete = false;
					break;
				}
			}
		}
	}

	public PageReference doComplete() {
		List<ASI_MFM_PO_Line_Item__c> pList = new List<ASI_MFM_PO_Line_Item__c>();
		List<ASI_MFM_PO_Line_Item_Capex__c> cList = new List<ASI_MFM_PO_Line_Item_Capex__c>();

		Integer period = Integer.valueOf(plans[0].ASI_MFM_TR_Duration_Month__c);

		for (ASI_MFM_PO__c po : pos) {
			if (po.ASI_MFM_Status__c == 'Final' || po.ASI_MFM_Status__c == 'Partial Paid' || po.ASI_MFM_Status__c == 'Complete') {
				Decimal balanceAmount = po.ASI_MFM_PO_Balance__c / po.ASI_MFM_Exchange_Rate__c;
				Decimal totalBalanceAmount = po.ASI_MFM_PO_Balance__c / po.ASI_MFM_Exchange_Rate__c;
				Decimal invoicedAmount = po.ASI_MFM_Invoice_Amount_from_JDE__c;
				Decimal totalInvoicedAmount = po.ASI_MFM_Invoice_Amount_from_JDE__c;
				Decimal totalAmount = po.ASI_MFM_PO_Amount__c;

				for (ASI_MFM_PO_Line_Item__c line : [select id, recordtypeid, name, asi_mfm_po__c, asi_mfm_sub_brand_code__c, 
					asi_mfm_a_c_code__c, asi_mfm_ap_code__c, asi_mfm_list_item_description__c, asi_mfm_sg_ba_verify__c, 
					asi_mfm_complete__c, asi_mfm_posm_deposit__c, asi_mfm_posm_balance__c, 
					asi_mfm_sg_unit__c, asi_mfm_quantity__c, 
					asi_mfm_unit_price__c, asi_mfm_g_l_date__c, 
					asi_mfm_customer_name__c, asi_mfm_sku_code__c, asi_mfm_pay_acc__c, asi_mfm_amount__c
					from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :po.Id]) {

					Date glDate = plans[0].ASI_MFM_Actual_Depreciation_Start_Date__c ;
					Double percentage = line.asi_mfm_amount__c / totalAmount;
					Decimal bAmount = balanceAmount * percentage;
					bAmount = bAmount.setScale(2, RoundingMode.FLOOR);
				
					if (balanceAmount != 0) {
						ASI_MFM_PO_Line_Item__c pLine = new ASI_MFM_PO_Line_Item__c(
							recordtypeid = line.recordtypeid, asi_mfm_po__c = line.asi_mfm_po__c, asi_mfm_sub_brand_code__c = line.asi_mfm_sub_brand_code__c, asi_mfm_a_c_code__c = line.asi_mfm_a_c_code__c, asi_mfm_ap_code__c = line.asi_mfm_ap_code__c, asi_mfm_list_item_description__c = line.asi_mfm_list_item_description__c,asi_mfm_sg_ba_verify__c = line.asi_mfm_sg_ba_verify__c, asi_mfm_complete__c = line.asi_mfm_complete__c, asi_mfm_posm_deposit__c = line.asi_mfm_posm_deposit__c,asi_mfm_posm_balance__c = line.asi_mfm_posm_balance__c, asi_mfm_sg_unit__c = line.asi_mfm_sg_unit__c, asi_mfm_quantity__c = line.asi_mfm_quantity__c, asi_mfm_unit_price__c = line.asi_mfm_unit_price__c,asi_mfm_g_l_date__c = line.asi_mfm_g_l_date__c, asi_mfm_customer_name__c = line.asi_mfm_customer_name__c, asi_mfm_sku_code__c = line.asi_mfm_sku_code__c, asi_mfm_pay_acc__c = 'C', asi_mfm_amount__c = (bAmount < 0 ? bAmount * -1 : -bAmount)
						);

						if (bAmount < 0) {
							totalBalanceAmount += (bAmount * -1);
						}
						else {
							totalBalanceAmount -= bAmount;
						}

						pList.add(pLine);
					}

					if (po.ASI_MFM_Invoice_Amount_from_JDE__c > 0) {
						Decimal totalAmountToSplit = invoicedAmount * percentage;
						Decimal amount = totalAmountToSplit / period;
						amount = amount.setScale(2, RoundingMode.FLOOR);

						for (Integer i = 0; i < period; i++) {
							ASI_MFM_PO_Line_Item_Capex__c cLine = new ASI_MFM_PO_Line_Item_Capex__c(
								recordtypeid = cpoLineRTID,
								asi_mfm_po__c = line.asi_mfm_po__c,
								asi_mfm_sub_brand_code__c = line.asi_mfm_sub_brand_code__c, 
								asi_mfm_a_c_code__c = line.asi_mfm_a_c_code__c, 
								asi_mfm_ap_code__c = line.asi_mfm_ap_code__c, 
								asi_mfm_list_item_description__c = line.asi_mfm_list_item_description__c,
								asi_mfm_sg_ba_verify__c = line.asi_mfm_sg_ba_verify__c, 
								asi_mfm_complete__c = line.asi_mfm_complete__c, 
								asi_mfm_posm_deposit__c = line.asi_mfm_posm_deposit__c,
								asi_mfm_posm_balance__c = line.asi_mfm_posm_balance__c, 
								asi_mfm_sg_unit__c = line.asi_mfm_sg_unit__c, 
								asi_mfm_quantity__c = line.asi_mfm_quantity__c, 
								asi_mfm_unit_price__c = line.asi_mfm_unit_price__c,
								asi_mfm_g_l_date__c = glDate, 
								asi_mfm_customer_name__c = line.asi_mfm_customer_name__c, 
								asi_mfm_sku_code__c = line.asi_mfm_sku_code__c, 
								asi_mfm_pay_acc__c = 'D',
								asi_mfm_amount__c = amount
							);

							totalAmountToSplit -= amount;
							totalInvoicedAmount -= amount;
							glDate = glDate.addMonths(1);

							cList.add(cLine);
						}

						if (totalAmountToSplit > 0) {
							cList[cList.size() - 1].asi_mfm_amount__c += totalAmountToSplit;
							totalInvoicedAmount -= totalAmountToSplit;
						}
					}
				}

				if (totalInvoicedAmount != 0) {
					cList[cList.size() - 1].asi_mfm_amount__c += totalInvoicedAmount;
				}

				if (totalBalanceAmount < 0) {
					pList[pList.size() - 1].asi_mfm_amount__c += (totalBalanceAmount * -1);
				}
				else if (totalBalanceAmount > 0) {
					pList[pList.size() - 1].asi_mfm_amount__c -= totalBalanceAmount;
				}

				po.ASI_MFM_Status__c = 'Complete';
			}

			//po.ASI_MFM_PO_Start_Date__c = plans[0].ASI_MFM_TR_PlanCompletionDate__c;
			//po.ASI_MFM_PO_End_Date__c = plans[0].ASI_MFM_TR_PlanCompletionDate__c.addMonths(period).addDays(-1);
			po.ASI_MFM_TR_POCompletionDate__c = plans[0].ASI_MFM_Actual_Depreciation_Start_Date__c ;
		}

		if (pList.size() > 0) {
			insert pList;	
		}
		
		if (cList.size() > 0) {
			insert cList;
		}

		update pos;

		//plans[0].ASI_MFM_Start_Date__c = plans[0].ASI_MFM_TR_PlanCompletionDate__c;
		//plans[0].ASI_MFM_End_Date__c = plans[0].ASI_MFM_TR_PlanCompletionDate__c.addMonths(period).addDays(-1);
		plans[0].ASI_MFM_Status__c = 'Complete (CAPEX)';
		update plans;
		
		return redirect();
	}

	public PageReference cancel() {
		return redirect();
	}

	public PageReference redirect() {
		PageReference redirectPage = new PageReference('/' + planID);
		redirectPage.setRedirect(true);
		return redirectPage;
	}
}