/*********************************************************************************
 * Name: ASI_CRM_SG_AdjustOfftakesHelper
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-12-11       Tony/Billy              Created
 * 2018-06-15		Vincent Lam				[VL 1.0] Check promotion / wholesaler rebate before changing quantity
 */
public class ASI_CRM_SG_AdjustOfftakesHelper {

    public String getFilterSQL(ASI_TH_CRM_Actual_Offtake__c filterWrapper, Date filterDateFrom, Date filterDateTo) {

		boolean hasFilter = false;
		boolean hasFilter_Customer = false;
	
        String FilterSQL = ' WHERE RecordType.DeveloperName  = \'ASI_CRM_SG_Actual_offtake\' and ASI_CRM_Mass_Uploaded__c = true ';
        if (filterWrapper.ASI_CRM_FromWS__c != null && String.valueOf(filterWrapper.ASI_CRM_FromWS__c).length() > 0) {
            hasFilter = true;
            hasFilter_Customer = true;
			String Idstr = String.valueOf(filterWrapper.ASI_CRM_FromWS__c);
            FilterSQL += ' AND ASI_CRM_FromWS__c =\'' + Idstr + '\'';
        }

        if (filterWrapper.ASI_CRM_SKU__c != null && String.valueOf(filterWrapper.ASI_CRM_SKU__c).length() > 0) {
            hasFilter = true;
            String Idstr = String.valueOf(filterWrapper.ASI_CRM_SKU__c);
            FilterSQL += ' AND ASI_CRM_SKU__c =\'' + Idstr + '\'';
        }

        if (filterWrapper.ASI_CRM_CN_Batch_Id__c != null && filterWrapper.ASI_CRM_CN_Batch_Id__c.length() > 0) {
            hasFilter = true;
            FilterSQL += ' AND ASI_CRM_CN_Batch_Id__c LIKE \'' + String.escapeSingleQuotes(filterWrapper.ASI_CRM_CN_Batch_Id__c) + '%\'';
        }

        //G/L DateFrom
		if (filterDateFrom != null && filterDateTo != null){
            hasFilter = true;
		}
		
        if (filterDateFrom != null) {
            String fromDate = DateTime.newInstance(filterDateFrom.year(), filterDateFrom.month(), filterDateFrom.day(), 0, 0, 0).format('yyyy-MM-dd');
            FilterSQL += ' AND ASI_TH_CRM_Offtake_G_L_Date__c  >= ' + fromDate + ' ';
        }

        //G/L Date To
        if (filterDateTo != null) {
            String toDate = DateTime.newInstance(filterDateTo.year(), filterDateTo.month(), filterDateTo.day(), 0, 0, 0).format('yyyy-MM-dd');
            FilterSQL += ' AND ASI_TH_CRM_Offtake_G_L_Date__c    <= ' + toDate + ' ';
        }

        if (filterWrapper.ASI_CRM_SG_Customer__c != null && String.valueOf(filterWrapper.ASI_CRM_SG_Customer__c).length() > 0) {
            hasFilter = true;
            String Idstr = String.valueOf(filterWrapper.ASI_CRM_SG_Customer__c);
            FilterSQL += ' AND ASI_CRM_SG_Customer__c =\'' + Idstr + '\'';
        } else {
			hasFilter = false;
		}

		if (hasFilter){
			return FilterSQL;
		} else {
			return '';
		}
        

    }

    public List < ASI_TH_CRM_Actual_Offtake__c > getSaveList(List < ASI_TH_CRM_Actual_Offtake__c > searchResult) {

        List < ASI_TH_CRM_Actual_Offtake__c > saveList = new List < ASI_TH_CRM_Actual_Offtake__c > ();

        for (ASI_TH_CRM_Actual_Offtake__c o: searchResult) {

            if (o.ASI_CRM_Temp_Checkbox__c) {
                o.ASI_CRM_Adjustment_Quantity__c = o.ASI_TH_CRM_Quantity__c - o.ASI_CRM_Original_Quantity__c;
                saveList.add(o);
            }
        }
        return saveList;
    }

    public List < ASI_TH_CRM_Actual_Offtake__c > getDeleteList(List < ASI_TH_CRM_Actual_Offtake__c > searchResult, Map < string, string > map_offtakeId_oldContractId) {

        List < ASI_TH_CRM_Actual_Offtake__c > deleteList = new List < ASI_TH_CRM_Actual_Offtake__c > ();


        for (ASI_TH_CRM_Actual_Offtake__c o: searchResult) {
            if (o.ASI_CRM_Temp_Checkbox__c) {

                // Roll back to old contract
                o.ASI_CRM_Contract__c = map_offtakeId_oldContractId.get(o.id);
                o.ASI_TH_CRM_Quantity__c = 0;
                o.ASI_CRM_Adjustment_Quantity__c = o.ASI_TH_CRM_Quantity__c - o.ASI_CRM_Original_Quantity__c;
                deleteList.add(o);
            }
        }
        return deleteList;
    }

    public Boolean isMatchOutlet(ASI_TH_CRM_Actual_Offtake__c o, ASI_TH_CRM_Contract__c outlet) {

        boolean matchOutlet = false;
        if (o.ASI_CRM_SG_Customer__c == outlet.ASI_CRM_CN_Outlet_WS__c) {
            matchOutlet = true;
        }
        for (ASI_CRM_Contract_Outlets__c childOutlet: outlet.Contract_Outlets__r) {
            if (o.ASI_CRM_SG_Customer__c == childOutlet.ASI_CRM_SG_Customer__c) {
                matchOutlet = true;
            }
        }
        return matchOutlet;
    }

    public Date getActualMonth() {

        List<ASI_CRM_ActualOfftakeHeader__c> list_actualMonth = [select ASI_CRM_Month__c, ASI_CRM_Year__c from ASI_CRM_ActualOfftakeHeader__c where Recordtype.developername = 'ASI_CRM_SG_Actual_Offtake_Header'
            and ASI_CRM_Month__c != null and ASI_CRM_Year__c != null order by ASI_CRM_Year_Number__c desc, ASI_CRM_Month_Number__c desc limit 1
        ];

		if (list_actualMonth.size()>0){
			ASI_CRM_ActualOfftakeHeader__c actualMonth = list_actualMonth[0];
			Integer year = Integer.valueOf(actualMonth.ASI_CRM_Year__c);

			Integer month = Integer.valueOf(actualMonth.ASI_CRM_Month__c);

			return Date.newInstance(year, month, 1);
			
		} else {
			return system.today();
		}
    }

    public Boolean isPreviousMonth(ASI_TH_CRM_Actual_Offtake__c o, Date actualMonth) {

        Date offtakeDate = Date.newInstance(o.ASI_TH_CRM_Offtake_G_L_Date__c.year(), o.ASI_TH_CRM_Offtake_G_L_Date__c.month(), 1);

        if (actualMonth > offtakeDate)
            return true;
        else
            return false;
    }

    // To avoid for loop inside SOQL, get Payment request List in advance. 
    public Map < String, ASI_TH_CRM_PaymentRequest__c > getPaymentRequestMap(Set < String > set_contractId) {

        Map < String, ASI_TH_CRM_PaymentRequest__c > prMap = new Map < String, ASI_TH_CRM_PaymentRequest__c > ();

        List < ASI_TH_CRM_PaymentRequest__c > prList = [SELECT ASI_TH_CRM_GL_Date__c, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__r.Name FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_GL_Date__c != NULL AND ASI_TH_CRM_Contract__c != NULL AND recordtype.developername in ('ASI_CRM_SG_Payment_Request', 'ASI_CRM_SG_Payment_Request_Read_Only')
			and ASI_TH_CRM_Contract__c in :set_contractId
        ];

        for (ASI_TH_CRM_PaymentRequest__c pr: prList) {

            Date prDate = pr.ASI_TH_CRM_GL_Date__c.addMonths(-1);

            String customKey = pr.ASI_TH_CRM_Contract__c + String.valueOf(prDate.month()) + String.valueOf(prDate.year());

            prMap.put(customKey, pr);

        }

        return prMap;
    }

    // To avoid for loop inside SOQL, get Foc List in advance. 
    public Map < String, ASI_FOC_Free_Goods_Request__c > getFocMap(Set < String > set_contractId) {

        Map < String, ASI_FOC_Free_Goods_Request__c > focMap = new Map < String, ASI_FOC_Free_Goods_Request__c > ();

        List < ASI_FOC_Free_Goods_Request__c > focList = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_Contract__r.Name, ASI_CRM_SG_Month__c, ASI_CRM_SG_Year__c FROM ASI_FOC_Free_Goods_Request__c
            WHERE recordtype.developername in ('ASI_CRM_SG_FOC', 'ASI_CRM_SG_FOC_Read_Only')
            AND ASI_CRM_SG_System_Generated__c = true
            AND ASI_CRM_Contract__c != null
			and ASI_CRM_Contract__c in :set_contractId
        ];

        for (ASI_FOC_Free_Goods_Request__c foc: focList) {

            // Custom Key format is 'ASI_CRM_Contract__c + ASI_CRM_SG_Month__c + ASI_CRM_SG_Year__c'
            String customKey = foc.ASI_CRM_Contract__c + foc.ASI_CRM_SG_Month__c + foc.ASI_CRM_SG_Year__c;

            focMap.put(customKey, foc);

        }

        return focMap;
    }

    // To avoid for loop inside SOQL, get Payment request List in advance. 
    public Map < String, ASI_CRM_Credit_Debit_Note__c > getCreditDebitNoteMap(Set < String > set_contractId) {

        Map < String, ASI_CRM_Credit_Debit_Note__c > prMap = new Map < String, ASI_CRM_Credit_Debit_Note__c > ();

        List < ASI_CRM_Credit_Debit_Note__c > prList = [SELECT ASI_CRM_GL_Date__c, ASI_CRM_Year__c, ASI_CRM_Month__c, ASI_CRM_Contract__c, ASI_CRM_Contract__r.Name FROM ASI_CRM_Credit_Debit_Note__c
            WHERE 
				ASI_CRM_GL_Date__c != NULL AND 
				ASI_CRM_Contract__c != NULL AND recordtype.developername in 
					('ASI_CRM_SG_Contract_Margin_Credit_Note', 'ASI_CRM_SG_Contract_Margin_Credit_Note_Read_Only', 'ASI_CRM_SG_Contract_Margin_Debit_Note', 'ASI_CRM_SG_Contract_Margin_Debit_Note_Read_Only')
				and ASI_CRM_Contract__c in :set_contractId
        ];

        for (ASI_CRM_Credit_Debit_Note__c pr: prList) {

            //Date prDate = pr.ASI_CRM_GL_Date__c.addMonths(-1);

            //String customKey = pr.ASI_CRM_Contract__c + String.valueOf(prDate.month()) + String.valueOf(prDate.year());
            String customKey = pr.ASI_CRM_Contract__c + pr.ASI_CRM_Month__c + pr.ASI_CRM_Year__c;

            prMap.put(customKey, pr);

        }

        return prMap;
    }
	
	/* [VL 1.0] BEGIN */
    public set<string> getPromotionIncentive(Set < String > set_promotionId) {
		set<string> set_promotionIdHasIncentive = new set<string>();
		
        for( ASI_FOC_Request_Item__c foc : [SELECT ASI_CRM_Promotion__c, ASI_FOC_Request_Order__r.ASI_CRM_SG_Month__c, ASI_FOC_Request_Order__r.ASI_CRM_SG_Year__c FROM ASI_FOC_Request_Item__c
            WHERE recordtype.developername in ('ASI_SG_CRM_Request_Items')
            AND ASI_CRM_Promotion__c in :set_promotionId
        ]){
			String customKey = foc.ASI_CRM_Promotion__c + foc.ASI_FOC_Request_Order__r.ASI_CRM_SG_Month__c + foc.ASI_FOC_Request_Order__r.ASI_CRM_SG_Year__c;
			set_promotionIdHasIncentive.add(customKey);
		}
		
		for( ASI_TH_CRM_PaymentRequestLineItem__c pr : [SELECT ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c, ASI_CRM_Promotion__c FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c != NULL AND recordtype.developername in ('ASI_CRM_SG_Payment_Request_Detail')
			and ASI_CRM_Promotion__c in :set_promotionId
        ]){
			Date prDate = pr.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_GL_Date__c.addMonths(-1);
            String customKey = pr.ASI_CRM_Promotion__c + String.valueOf(prDate.month()) + String.valueOf(prDate.year());
			set_promotionIdHasIncentive.add(customKey);
		}

		for( ASI_CRM_Voucher_Detail__c pr : [SELECT ASI_CRM_Voucher_Header__r.ASI_CRM_GL_Date__c, ASI_CRM_Promotion__c FROM ASI_CRM_Voucher_Detail__c
            WHERE ASI_CRM_Voucher_Header__r.ASI_CRM_GL_Date__c != NULL AND recordtype.developername in ('ASI_CRM_SG_Voucher_Detail')
			and ASI_CRM_Promotion__c in :set_promotionId
        ]){
			Date prDate = pr.ASI_CRM_Voucher_Header__r.ASI_CRM_GL_Date__c.addMonths(-1);
            String customKey = pr.ASI_CRM_Promotion__c + String.valueOf(prDate.month()) + String.valueOf(prDate.year());
			set_promotionIdHasIncentive.add(customKey);
		}

        return set_promotionIdHasIncentive;
    }
	/* [VL 1.0] BEGIN */


    // To avoid for loop inside SOQL, get Outlet List in advance. 
    public Map < Id, ASI_TH_CRM_Contract__c > getOutletMap(Set < String > set_contractId) {

        Map < Id, ASI_TH_CRM_Contract__c > outletMap = new Map < Id, ASI_TH_CRM_Contract__c > ();

        List < ASI_TH_CRM_Contract__c > outletList = [select id, Name, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Outlet_WS__r.name, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c,
            (select id, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Customer__r.name from Contract_Outlets__r)
            from ASI_TH_CRM_Contract__c
            where recordtype.developername = 'ASI_CRM_SG_Contract_Read_Only'
			and Id in :set_contractId
        ];

        for (ASI_TH_CRM_Contract__c outlet: outletList) {

            outletMap.put(outlet.id, outlet);

        }

        return outletMap;

    }

    public Set < string > getContractIdSet(List < ASI_TH_CRM_Actual_Offtake__c > saveList, Map < string, string > map_offtakeId_oldContractId) {

        Set < string > set_contractId = new Set < string > ();

        for (ASI_TH_CRM_Actual_Offtake__c o: saveList) {

            set_contractId.add(o.ASI_CRM_Contract__c);
            set_contractId.add(map_offtakeId_oldContractId.get(o.Id));

        }
        return set_contractId;
    }

	/* [VL 1.0] BEGIN */
    public Set < string > getPromotionIdSet(List < ASI_TH_CRM_Actual_Offtake__c > saveList) {

        Set < string > set_contractId = new Set < string > ();

        for (ASI_TH_CRM_Actual_Offtake__c o: saveList) {

            if(o.ASI_CRM_Promotion__c != null) set_contractId.add(o.ASI_CRM_Promotion__c);

        }
        return set_contractId;
    }
	/* [VL 1.0] END */

	/* [VL 1.0] BEGIN */
    public Set < string > getPromotionPlanIdSet(List < ASI_TH_CRM_Actual_Offtake__c > saveList) {

        Set < string > set_contractId = new Set < string > ();

        for (ASI_TH_CRM_Actual_Offtake__c o: saveList) {

            if(o.ASI_CRM_Promotion__c != null) set_contractId.add(o.ASI_CRM_Promotion__r.ASI_CRM_Promotion_Plan__c);

        }
        return set_contractId;
    }
	/* [VL 1.0] END */

    // A validation that can only confirm once in each month
    public Boolean isDuplicateConfirm(Integer year, Integer month) {

        List < ASI_CRM_ActualOfftakeHeader__c > confirmList = [
            SELECT ID
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE Recordtype.developername = 'ASI_CRM_SG_Actual_Offtake_Header'
            AND ASI_CRM_Month__c =: String.valueOf(month)
            AND ASI_CRM_Year__c =: String.valueOf(year)
            AND ASI_CRM_Confirmed__c = FALSE
        ];

        if (confirmList.size() > 0) return false;
        else return true;
    }

    // Check if all Wholesalers have uploaded offtakes before confirm all offtakes of that month
    public List < ASI_CRM_AccountsAdditionalField__c > getWsList(Integer year, Integer month) {
        List < ASI_CRM_AccountsAdditionalField__c > wsList = [SELECT Name
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE ASI_CRM_Upload_Offtake__c = TRUE
            AND Recordtype.developername = 'ASI_CRM_SG_Wholesaler'
            AND ID NOT IN(
                SELECT ASI_CRM_From_Wholesaler__c FROM ASI_CRM_ActualOfftakeHeader__c WHERE Recordtype.developername = 'ASI_CRM_SG_Actual_Offtake_Header'
                AND ASI_CRM_Month__c =: String.valueOf(month) AND ASI_CRM_Year__c =: String.valueOf(year)
            )
        ];

        return wsList;

    }

    public String getConfirmOfftakesMessage(List < ASI_CRM_AccountsAdditionalField__c > wsList, Integer year, Integer month) {

        if (wsList.size() > 0) {
            String names = '';
            for (Integer i = 0; i < wsList.size(); i++) {
                if (i == 0) names = wsList.get(i).name;
                else names = names + ', ' + wsList.get(i).name;
            }
            return 'Wholesaler ' + names + ' do not have offtake uploaded.';
        } else {
            return 'Offtakes of ' + month + '/' + year + ' have been saved and being linked to contracts. You will received an email notification once it is completed.';
        }

    }

    public String getOutletMismatchMessage(ASI_TH_CRM_Contract__c o) {
		
        if (o != null) {
            String names = o.ASI_CRM_CN_Outlet_WS__r.name;
			for(ASI_CRM_Contract_Outlets__c childOutlet: o.Contract_Outlets__r){
				names += ', ' + childOutlet.ASI_CRM_SG_Customer__r.name;
			}
            return names;
        } else {
            return '';
        }

    }

    public void updateConfirmedOfftakeHeader(Integer month, Integer year) {

        List < ASI_CRM_ActualOfftakeHeader__c > confirmList = [
            SELECT ASI_CRM_Confirmed__c
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE Recordtype.developername = 'ASI_CRM_SG_Actual_Offtake_Header'
            AND ASI_CRM_Month__c =: String.valueOf(month)
            AND ASI_CRM_Year__c =: String.valueOf(year)
            AND ASI_CRM_Confirmed__c = FALSE
        ];

        for (ASI_CRM_ActualOfftakeHeader__c header: confirmList) {
            header.ASI_CRM_Confirmed__c = true;
        }

        upsert(confirmList);

    }

    public void sendOfftakeChangeEmail(List < ASI_TH_CRM_Actual_Offtake__c > offtakes) {

        Set < Id > userId = new Set < Id > ();
        Set < Id > contractId = new Set < Id > ();
        // Set < String > emails = new Set < String > ();

        for (ASI_TH_CRM_Actual_Offtake__c o: offtakes) {
            if (o.ASI_CRM_Contract__c != null)
                contractId.add(o.ASI_CRM_Contract__c);
        }

        List < ASI_TH_CRM_Contract__c > owners = [SELECT ownerid FROM ASI_TH_CRM_Contract__c WHERE ownerid != NULL AND recordtype.developername = 'ASI_CRM_SG_Contract_Read_Only'
            AND ID IN: contractId
        ];
        for (ASI_TH_CRM_Contract__c owner: owners)
            userId.add(owner.ownerid);

        List < GroupMember > members = [SELECT userOrGroupID FROM groupMember WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_CRM_SG_Offtake_Notification_Group')];
        for (GroupMember member: members)
            userId.add(member.userOrGroupID);

        List < User > users = [SELECT name, email FROM User WHERE ID IN: userId];
        
        for (User u: users) {
            String address = u.email;
            String subject = 'Completed SG Offtakes link to contracts';
            String body = 'Hi ' + u.name + '\n' +
                contractId.size() + ' out of ' + offtakes.size() + ' offtakes have been adjusted successfully.';
            sendMail(address, subject, body);
        }
    }

    // Send Email
    public void sendMail(String toAddress, String subject, String body) {

        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {
            toAddress
        });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] {
                mail
            });

        // Call a helper method to inspect the returned results
        inspectResults(results);
    }

    // Helper method
    public Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;

        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results. 
        // In this class, the methods send only one email, 
        // so we should have only one result.
        for (Messaging.SendEmailResult res: results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());
            }
        }

        return sendResult;
    }
	
    public Boolean isActualMonthConfirmed(Integer year, Integer month) {

        List < ASI_CRM_ActualOfftakeHeader__c > confirmList = [
            SELECT ID
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE Recordtype.developername = 'ASI_CRM_SG_Actual_Offtake_Header'
            AND ASI_CRM_Month__c =: String.valueOf(month)
            AND ASI_CRM_Year__c =: String.valueOf(year)
            AND ASI_CRM_Confirmed__c = FALSE
        ];

        if (confirmList.size() > 0) return false;
        else return true;
    }
}