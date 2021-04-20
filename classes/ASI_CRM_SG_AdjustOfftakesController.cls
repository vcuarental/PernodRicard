/*********************************************************************************
 * Name: ASI_CRM_SG_AdjustOfftakesController
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-12-11       Tony/Billy              Created
 * 2018-06-15		Vincent Lam				[VL 1.0] Check promotion / wholesaler rebate before changing quantity
 */
public class ASI_CRM_SG_AdjustOfftakesController {

    public ASI_CRM_SG_AdjustOfftakesHelper Helper {
        get;
        set;
    } {
        Helper = new ASI_CRM_SG_AdjustOfftakesHelper();
    }
    public List < ASI_TH_CRM_Actual_Offtake__c > searchResult {
        get;
        set;
    } {
        searchResult = new List < ASI_TH_CRM_Actual_Offtake__c > ();
    }
    public ASI_TH_CRM_Actual_Offtake__c filterWrapper {
        get;
        set;
    } {
        filterWrapper = new ASI_TH_CRM_Actual_Offtake__c();
    }
    public Boolean showMsg {
        get;
        set;
    } {
        showMsg = false;
    }
    public Date actualMonth {
        get;
        set;
    }
    public Date filterDateFrom {
        get;
        set;
    }
    public Date filterDateTo {
        get;
        set;
    }
    public Integer counter {
        get;
        set;
    } {
        counter = 0;
    }
    public Integer list_size {
        get;
        set;
    } {
        list_size = 10;
    }
    public Integer total_size {
        get;
        set;
    } {
        total_size = 0;
    }

    public String myMsg {
        get;
        set;
    } {
        myMsg = '';
    }

    //SQL
    public String QuerySQL {
        get;
        set;
    } {
        QuerySQL = '';
    }
    public String CountSQL {
        get;
        set;
    } {
        CountSQL = '';
    }
    public String FilterSQL {
        get;
        set;
    } {
        FilterSQL = '';
    }
    public String LimitSQL {
        get;
        set;
    } {
        LimitSQL = '';
    }

    public Map < string, string > map_offtakeId_oldContractId = new Map < string, string > ();

    public void init() {

        actualMonth = Helper.getActualMonth();

        QuerySQL = 'SELECT Name, ASI_CRM_Temp_Checkbox__c, ASI_CRM_Contract__c, ASI_CRM_Contract__r.Name, ASI_CRM_Adjustment_Quantity__c, ASI_TH_CRM_Offtake_G_L_Date__c, ' +
            'ASI_CRM_SKU__c, ASI_CRM_SKU__r.Name, ASI_CRM_FromWS__c, ASI_CRM_FromWS__r.Name, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Customer__r.Name, ' +
			/* [VL 1.0] BEGIN */
			'ASI_CRM_SG_Customer__r.ASI_CRM_Outlet_Type__c, ASI_CRM_Promotion__c, ASI_CRM_Promotion__r.Name, ASI_CRM_Promotion__r.ASI_CRM_Promotion_Plan__c, ' +
			/* [VL 1.0] END */
            'ASI_CRM_InvoiceNumber__c, ASI_TH_CRM_Quantity__c, ASI_CRM_Original_Quantity__c FROM ASI_TH_CRM_Actual_Offtake__c ';

        CountSQL = 'SELECT COUNT() FROM ASI_TH_CRM_Actual_Offtake__c ';

        FilterSQL = ' WHERE RecordType.DeveloperName  = \'ASI_CRM_SG_Actual_offtake\' and ASI_CRM_Mass_Uploaded__c = true ';

    }

    public void runSearch() {
        counter = 0;
        searchResult = new List < ASI_TH_CRM_Actual_Offtake__c > ();
        FilterSQL = Helper.getFilterSQL(filterWrapper, filterDateFrom, filterDateTo);
		if (FilterSQL == ''){
			showMsg = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please at least filter the search with Customer.'));
		} else {
			countSearch();
			refleshSearch();
		}
    }

    public void countSearch() {
        total_size = Database.countQuery(CountSQL + FilterSQL);
    }

    public void refleshSearch() {

        map_offtakeId_oldContractId = new Map < string, string > ();
        showMsg = false;
        LimitSQL = ' LIMIT ' + list_size + ' OFFSET ' + counter;
        searchResult = Database.query(QuerySQL + FilterSQL + LimitSQL);

        for (ASI_TH_CRM_Actual_Offtake__c offtake: searchResult) {
            if (Helper.isPreviousMonth(offtake, actualMonth))
                offtake.ASI_CRM_Is_Previous_Month__c = true;
            else
                offtake.ASI_CRM_Is_Previous_Month__c = false;
            offtake.ASI_CRM_Temp_Checkbox__c = false;
            offtake.ASI_CRM_Original_Quantity__c = offtake.ASI_CRM_Original_Quantity__c != null ? offtake.ASI_CRM_Original_Quantity__c : 0;
            offtake.ASI_TH_CRM_Quantity__c = offtake.ASI_TH_CRM_Quantity__c != null ? offtake.ASI_TH_CRM_Quantity__c : 0;
            offtake.ASI_CRM_Adjustment_Quantity__c = offtake.ASI_TH_CRM_Quantity__c - offtake.ASI_CRM_Original_Quantity__c;
            map_offtakeId_oldContractId.put(offtake.Id, offtake.ASI_CRM_Contract__c);
        }
    }

    // Save
    public void saveOfftakes() {

        // if validation is pass, return true;
        Boolean isPass = true;
        String msg = '';
        showMsg = true;
		String outletName = null;

        List < ASI_TH_CRM_Actual_Offtake__c > saveList = Helper.getSaveList(searchResult);

        if (saveList.size() > 0) {
            Set < String > set_contractId = Helper.getContractIdSet(saveList, map_offtakeId_oldContractId);
			/* [VL 1.0] BEGIN */
			set<string> set_promotionId = Helper.getPromotionIdSet(saveList);
			set<string> set_promotionPlanId = Helper.getPromotionPlanIdSet(saveList);
			/* [VL 1.0] END */
            Integer count = saveList.size();
			
			// To avoid for loop inside SOQL, get the maps in advance. 
			Map < String, ASI_FOC_Free_Goods_Request__c > focMap = Helper.getFocMap(set_contractId);
			Map < String, ASI_TH_CRM_PaymentRequest__c > prMap = Helper.getPaymentRequestMap(set_contractId);
			Map < String, ASI_CRM_Credit_Debit_Note__c > cdnMap = Helper.getCreditDebitNoteMap(set_contractId);
			Map < Id, ASI_TH_CRM_Contract__c > outletMap = Helper.getOutletMap(set_contractId);

			/* [VL 1.0] BEGIN */
			set<string> set_promotionIdHasIncentive = Helper.getPromotionIncentive(set_promotionId);
			/* [VL 1.0] END */

            for (ASI_TH_CRM_Actual_Offtake__c o: saveList) {
                //if (o.ASI_CRM_Contract__c != null) {
				
				outletName = o.ASI_CRM_SG_Customer__r.Name;
				Set<string> list_contractId = new Set<string>();
				if(map_offtakeId_oldContractId.containsKey(o.Id)){
					list_contractId.add(map_offtakeId_oldContractId.get(o.Id));
				}
				if(o.ASI_CRM_Contract__c!=null){
					list_contractId.add(o.ASI_CRM_Contract__c);
					
                    // Check if the contract does not contain the offtake customer in either Outlet or Child Outlet, or G/L Date not in contract period.    
                    ASI_TH_CRM_Contract__c outlet = outletMap.get(o.ASI_CRM_Contract__c);
                    if (outlet != null) {
                        boolean matchOutlet = Helper.isMatchOutlet(o, outlet);

                        if (!matchOutlet) {
                            msg += o.name + ': Cannot be linked to contract [' + outlet.Name + '] due to Outlet not match. Offtake Outlet: '+o.ASI_CRM_SG_Customer__r.Name+'; Contract Outlet(s): '+Helper.getOutletMismatchMessage(outlet)+'<br/>';
                        }
                        if (o.ASI_TH_CRM_Offtake_G_L_Date__c < outlet.ASI_TH_CRM_Start_Date__c || o.ASI_TH_CRM_Offtake_G_L_Date__c > outlet.ASI_TH_CRM_End_Date__c) {
                            msg += o.name + ': Cannot be linked to contract [' + outlet.Name + '] due to contract period.<br/>';
                        }
                    } else {
                        msg += o.name + ': Cannot be linked to contract because it is not a valid / approved contract.<br/>';
                    }

				}
				for(string contractId : list_contractId){
                    // Check if there are generated trade deals of the month of offtake G/L date.
                    //String contractId = map_offtakeId_oldContractId.get(o.Id) == null ? o.ASI_CRM_Contract__c : map_offtakeId_oldContractId.get(o.Id);
                    String customKey = contractId + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.month()) + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.year());

                    ASI_FOC_Free_Goods_Request__c foc = focMap.get(customKey);
                    if (foc != null)
                        msg += o.name + ': There are generated FOC for contract [' + foc.ASI_CRM_Contract__r.Name + '] in the month of G/L date. Please remove those FOC before adjusting the offtakes.<br/>';

                    // Check if the adjusted offtake has Payment Request
                    ASI_TH_CRM_PaymentRequest__c pr = prMap.get(customKey);
                    if (pr != null)
                        msg += o.name + ': There are generated Payment Requests for contract [' + pr.ASI_TH_CRM_Contract__r.Name + '] in the +1 month of G/L date. Please remove those Payments before adjusting the offtakes.<br/>';

                    // Check if the adjusted offtake has contract margin credit/debit note
                    ASI_CRM_Credit_Debit_Note__c cdn = cdnMap.get(customKey);
                    if (cdn != null)
                        msg += o.name + ': There are generated Credit/Debit Notes for contract [' + cdn.ASI_CRM_Contract__r.Name + '] in the month of G/L date. Please remove them before adjusting the offtakes.<br/>';

				}
				
				/* [VL 1.0] BEGIN */
				if(o.ASI_CRM_Promotion__c != null){
					String customKey = o.ASI_CRM_Promotion__c + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.month()) + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.year());
					if(set_promotionIdHasIncentive.contains(customKey)){
						msg += o.name + ': There are generated Promotion Incentive (FOC/Payment/Voucher) for promotion [' + o.ASI_CRM_Promotion__r.Name + '] in the +1 month of G/L date. Please remove them before adjusting the offtakes.<br/>';
					}
				}
				/* [VL 1.0] END */
                //}
            }

            if (!String.isEmpty(msg)) isPass = false;

            if (isPass) {
                update(saveList);
                msg = saveList.size() + ' offtakes have been saved and being linked to contracts. ';
                msg += 'You will received an email notification once it is completed.';
                Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(set_contractId/*, count, count*/, true, outletName), 200);
				/* [VL 1.0] BEGIN */
				
               //if(set_promotionPlanId.size()>0) Database.executeBatch(new ASI_CRM_SG_YTDPromotionAchieved_Batch(set_promotionPlanId, 'Outlet'), 200);
				/* [VL 1.0] END */
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, msg));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            }

        } else {
            msg = 'Please select at least 1 offtake.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, msg));
        }
    }

    // Delete
    public void deleteOfftakes() {

        // if validation is pass, return true;
        Boolean isPass = true;
        String msg = '';
        showMsg = true;
		String outletName = null;

        List < ASI_TH_CRM_Actual_Offtake__c > deleteList = Helper.getDeleteList(searchResult, map_offtakeId_oldContractId);

        if (deleteList.size() > 0) {

            Set < String > set_contractId = Helper.getContractIdSet(deleteList, map_offtakeId_oldContractId);
			/* [VL 1.0] BEGIN */
			set<string> set_promotionId = Helper.getPromotionIdSet(deleteList);
			set<string> set_promotionPlanId = Helper.getPromotionPlanIdSet(deleteList);
			/* [VL 1.0] END */
            Integer count = deleteList.size();

			// To avoid for loop inside SOQL, get the maps in advance. 
			Map < String, ASI_FOC_Free_Goods_Request__c > focMap = Helper.getFocMap(set_contractId);
			Map < String, ASI_TH_CRM_PaymentRequest__c > prMap = Helper.getPaymentRequestMap(set_contractId);
			Map < String, ASI_CRM_Credit_Debit_Note__c > cdnMap = Helper.getCreditDebitNoteMap(set_contractId);

			/* [VL 1.0] BEGIN */
			set<string> set_promotionIdHasIncentive = Helper.getPromotionIncentive(set_promotionId);
			/* [VL 1.0] END */


            for (ASI_TH_CRM_Actual_Offtake__c o: deleteList) {

                //if (o.ASI_CRM_Contract__c != null) {
				outletName = o.ASI_CRM_SG_Customer__r.Name;
				Set<string> list_contractId = new Set<string>();
				if(map_offtakeId_oldContractId.containsKey(o.Id)){
					list_contractId.add(map_offtakeId_oldContractId.get(o.Id));
				}
				if(o.ASI_CRM_Contract__c!=null){
					list_contractId.add(o.ASI_CRM_Contract__c);
				}
				for(string contractId : list_contractId){

                    // Check if there are generated trade deals of the month of offtake G/L date.
                    //String contractId = map_offtakeId_oldContractId.get(o.Id) == null ? o.ASI_CRM_Contract__c : map_offtakeId_oldContractId.get(o.Id);
                    String customKey = contractId + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.month()) + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.year());
                    ASI_FOC_Free_Goods_Request__c foc = focMap.get(customKey);
                    if (foc != null)
                        msg += o.name + ': There are generated FOC for contract [' + foc.ASI_CRM_Contract__r.Name + '] in the month of G/L date. Please remove those FOC before adjusting the offtakes.<br/>';

                    // Check if the adjusted offtake has Payment Request
                    ASI_TH_CRM_PaymentRequest__c pr = prMap.get(customKey);
                    if (pr != null)
                        msg += o.name + ': There are generated Payment Requests for contract [' + pr.ASI_TH_CRM_Contract__r.Name + '] in the +1 month of G/L date. Please remove those Payments before adjusting the offtakes.<br/>';

                    // Check if the adjusted offtake has contract margin credit/debit note
                    ASI_CRM_Credit_Debit_Note__c cdn = cdnMap.get(customKey);
                    if (cdn != null)
                        msg += o.name + ': There are generated Credit/Debit Notes for contract [' + cdn.ASI_CRM_Contract__r.Name + '] in the +1 month of G/L date. Please remove them before adjusting the offtakes.<br/>';

				}
				/* [VL 1.0] BEGIN */
				if(o.ASI_CRM_Promotion__c != null){
					String customKey = o.ASI_CRM_Promotion__c + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.month()) + String.valueOf(o.ASI_TH_CRM_Offtake_G_L_Date__c.year());
					if(set_promotionIdHasIncentive.contains(customKey)){
						msg += o.name + ': There are generated Promotion Incentive (FOC/Payment/Voucher) for promotion [' + o.ASI_CRM_Promotion__r.Name + '] in the +1 month of G/L date. Please remove them before adjusting the offtakes.<br/>';
					}
				}
				/* [VL 1.0] END */
                //}


            }

            if (!String.isEmpty(msg)) isPass = false;

            if (isPass) {
                update(deleteList);
                msg = deleteList.size() + ' offtakes have been removed. You will received an email notification once it is completed.';
                Database.executeBatch(new ASI_CRM_SG_YtdAchievementNotif_Batch(set_contractId/*, count, count*/, true, outletName), 200);
				/* [VL 1.0] BEGIN */
				//if(set_promotionPlanId.size()>0) Database.executeBatch(new ASI_CRM_SG_YTDPromotionAchieved_Batch(set_promotionPlanId, 'Outlet'), 200);
				/* [VL 1.0] END */
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, msg));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            }
        } else {
            msg = 'Please select at least 1 offtake.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, msg));
        }
    }

    // Confirm 
    public void confirmOfftakes() {

        String msg = '';

        showMsg = true;

        // A validation that can only confirm once in each month
        if (!Helper.isDuplicateConfirm(thisYear, thisMonth)) {

            // Check if all Wholesalers have uploaded offtakes before confirm all offtakes of that month
            List < ASI_CRM_AccountsAdditionalField__c > wsList = Helper.getWsList(thisYear, thisMonth);

            msg = Helper.getConfirmOfftakesMessage(wsList, thisYear, thisMonth);

            if (wsList.size() > 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            } else {
                Helper.updateConfirmedOfftakeHeader(thisMonth, thisYear);
                Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch(String.valueOf(thisYear), String.valueOf(thisMonth)), 200);
				/* [VL 1.0] BEGIN */
				//Database.executeBatch(new ASI_CRM_SG_YTDPromotionAchieved_Batch(String.valueOf(thisYear), String.valueOf(thisMonth)), 200);
				/* [VL 1.0] END */
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, msg));
            }

        } else {
            msg = 'Offtakes of '+thisMonth + '/' + thisYear + ' had been confirmed before. Please select other month to confirm.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
        }

    }


    // Year Selection
    public Integer thisYear {
        set;
        get;
    } {
        thisYear = System.Today().year();
    }

    public List < SelectOption > years {
        set;
        get;
    } {

        years = new List < SelectOption > ();

        Integer thisYear = System.Today().year();

        for (Integer i = -1; i < 9; i++) {

            String year = String.valueOf(thisYear + i);

            years.add(new SelectOption(year, year));
        }
    }

    // Month Selection
    public Integer thisMonth {
        set;
        get;
    } {
        thisMonth = System.Today().month();

        if (thisMonth == 1) {
            thisMonth = 12;
            thisYear = thisYear - 1;
        }

    }

    public List < SelectOption > months {
        set;
        get;
    } {

        months = new List < SelectOption > ();

        for (Integer i = 1; i <= 12; i++) {

            String month = String.valueOf(i);

            months.add(new SelectOption(month, month));
        }
    }

    // Pagination Method 
    public void Beginning() { //user clicked beginning
        counter = 0;
        refleshSearch();
    }

    public void End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        refleshSearch();
    }


    public void Previous() { //user clicked previous button
        counter -= list_size;
        refleshSearch();
    }

    public void Next() { //user clicked next button
        counter += list_size;
        refleshSearch();
    }

    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter > 0) return false;
        else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false;
        else return true;
    }

    public Integer getPageNumber() {

        if (searchResult.size() > 0)
            return counter / list_size + 1;
        else
            return 0;
    }

    public Integer getTotalPages() {
            if (math.mod(total_size, list_size) > 0) {
                return total_size / list_size + 1;
            } else {
                return (total_size / list_size);
            }
        }
        // End of Pagination Method
		
	public string getActualMonthString(){
		return 'Actual Month: ' + actualMonth.month() + '/' + actualMonth.year();
	}
	public string getActualMonthConfirmed(){
		if (Helper.isActualMonthConfirmed(actualMonth.year(), actualMonth.month())){
			return ' (Confirmed)';
		} else {
			return ' (Not yet confirmed)';
		}
	}
}