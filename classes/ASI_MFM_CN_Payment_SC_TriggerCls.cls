public Without Sharing class ASI_MFM_CN_Payment_SC_TriggerCls {
    //20170219 Elufa Function for Structure Cost
    
    Private Final Static Map<String, Schema.SObjectField> RentalRequestDetail_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment__c.fields.getMap();
    Private Final Static Map<String, Schema.SObjectField> FixApproval_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    
    Public Static void structureCostAfterUpdate(List<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap){
        
        List<ASI_MFM_Payment_Detail__c> upsertPaymentDetails = new List<ASI_MFM_Payment_Detail__c>();
        List<ASI_MFM_Payment_Detail__c> deletePaymentDetails = new List<ASI_MFM_Payment_Detail__c>();
        Map<String, ASI_MFM_Payment_Detail__c> existingPrepaymentLine = new Map<String, ASI_MFM_Payment_Detail__c>();
        Set<id> prePaymentSet = new Set<id>();
        
        //20190324-Andy: CR#88-trigger on after update instead of before update
        //Rental Contract Update
        Set<Id> rentalContractSet = new Set<Id>();
        
        for(ASI_MFM_Payment__c pay : trigger_new){
            
            //Prepayment
            if(trigger_oldMap != null && (((trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Pending For Finance') && pay.ASI_MFM_Status__c == 'Final' ))){
                
                if(pay.ASI_MFM_Total_Payment_Detail_Lines__c == 0 && pay.ASI_MFM_Pre_payment__c ){
                    
                    upsertPaymentDetails.addAll(calculatePrePaymentPeriod(pay, pay.ASI_MFM_Expense_Date_From__c, pay.ASI_MFM_Expense_Date_To__c, existingPrepaymentLine).get('upsert'));
                    //deletePaymentDetails.addAll(calculatePrePaymentPeriod(pay, pay.ASI_MFM_Expense_Date_From__c, pay.ASI_MFM_Expense_Date_To__c, existingPrepaymentLine).get('delete'));
                }
            }
            
            //20190324-Andy: CR#88-trigger on after update instead of before update
            if(pay.ASI_MFM_Contract__c != Null){
                rentalContractSet.add(pay.ASI_MFM_Contract__c);
            }
        }
        
        if(upsertPaymentDetails.size() > 0){
            try{
                
                Upsert upsertPaymentDetails;
                
            }catch(dmlException dmle){
                trigger_new[0].addError(dmle.getMessage());
            }
        }
        
        //20190324-Andy: CR#88-trigger on after update instead of before update
        if(rentalContractSet.size() > 0 && !system.isBatch() && !system.isFuture())
            updateContractLine(rentalContractSet);
    }
    
    Public Static void structureCostBeforeUpsert(List<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap){
        
        Set<id> prefixSet = new Set<id>();
        Set<id> taxCode = new Set<id>();
        //Set<id> prePaymentSet = new Set<id>();
        
        //Budget Update
        Set<Id> paymentSet = new Set<Id>();
        Set<Id> relatedBudget = new Set<Id>();
        Set<String> fySet = new Set<String>();
        Set<String> expenseTypeSet = new Set<String>();
        Map<String, Map<String, Double>> budgetRemainingMap = new Map<String, Map<String, Double>>();
        Map<Id, ASI_MFM_PO__c> updatebudget = new Map<Id, ASI_MFM_PO__c>();
        
        //Rental Contract Update
        Set<Id> rentalContractSet = new Set<Id>();
        
        //Fix Approval
        Map<Id, ASI_CRM_Fix_Approval_Route__c> mapFixRoute = new Map<Id, ASI_CRM_Fix_Approval_Route__c>();
        
        String whereClause = ' Where ASI_CRM_CN_Type__c Like \'Structure Cost Payment\' AND RecordType.DeveloperName Like \'ASI_CRM_CN_Fix_Approval_Route\'';
        
        for(ASI_CRM_Fix_Approval_Route__c fa : ASI_MFM_CN_StructureCostHelperClass.RetrieveFixApprovalInfo(FixApproval_FIELD_MAP, whereClause)){
            
            mapFixRoute.put(fa.ASI_MFM_Expense_Control_Form__c, fa);
        }
        
        //exchange Rate
        Set<id> pay_set = new Set<id>();
        Set<String> ccy_set = new Set<String>();
        Date last_effective_date;
        Date effective_date_From;
        string country = 'CN';
        string base_ccy = 'RMB';
        list<ASI_MFM_Exchange_Rate__c> xr_list = new List<ASI_MFM_Exchange_Rate__c>();
        
        List<ASI_MFM_Payment_Detail__c> upsertPaymentDetails = new List<ASI_MFM_Payment_Detail__c>();
        List<ASI_MFM_Payment_Detail__c> deletePaymentDetails = new List<ASI_MFM_Payment_Detail__c>();
        Map<String, ASI_MFM_Payment_Detail__c> existingPrepaymentLine = new Map<String, ASI_MFM_Payment_Detail__c>();
        Set<String> groupmemberSet = new Set<String>();
        
        for(GroupMember gm : [SELECT id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName Like '%ASI_MFM_CN_SC_Finance_Group%']){
            
            groupmemberSet.add(gm.UserOrGroupId);
        }
        
        for(ASI_MFM_Payment__c pay : trigger_new){
            
            if(((pay.ASI_MFM_Accrual_Voucher__c != Null || pay.ASI_MFM_Accrual_Date__c != Null) && (pay.ASI_MFM_Accrual_Voucher__c == Null || pay.ASI_MFM_Accrual_Date__c == Null)) || ((pay.ASI_MFM_Receipt_No__c != Null || pay.ASI_MFM_Receipt_Date__c != Null) && (pay.ASI_MFM_Receipt_No__c == Null || pay.ASI_MFM_Receipt_Date__c == Null))){
                
                //pay.addError('Please input both Accrual Voucher and Accrual Date OR both Receipt Voucher and Receipt Date');
                //break;
            }
            
            /*if(trigger_oldMap != null && pay.ASI_MFM_Type__c != 'Structure Cost Accrual' && (((trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Pending For Finance') && pay.ASI_MFM_Status__c == 'Final' ))){
                if(pay.ASI_MFM_G_L_Date__c == Null || pay.ASI_MFM_Invoice_Number__c == Null){
                    pay.addError('Please input G/L date and Invoice Number before Final');
                    break;
                }
            }*/
            
            //Change Status if current approver is Finance
            if(pay.ASI_MFM_Status__c == 'Submitted' && groupmemberSet.contains(String.valueOf(pay.get('ASI_MFM_Sys_Approver_' + pay.ASI_MFM_Approval_Count__c + '__c')))){
                
                pay.ASI_MFM_Status__c = 'Pending For Finance';
            }
            
            if(trigger_oldMap != null && ( (trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Pending For Finance' ) && pay.ASI_MFM_Status__c == 'Draft' /*|| trigger_oldMap.get(pay.id).ASI_MFM_Total_JDE_Adjustment_Amount__c != pay.ASI_MFM_Total_JDE_Adjustment_Amount__c*/) ){
                paymentSet.add(pay.id);
                relatedBudget.add(pay.ASI_MFM_PO__c);
                fySet.add(pay.ASI_MFM_CN_Fiscal_Year__c);
            }
            
            //Prepayment
            /*if(trigger_oldMap != null && pay.ASI_MFM_Pre_payment__c && ((trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' && pay.ASI_MFM_Status__c == 'Final' )
                                                                        //|| (pay.ASI_MFM_Expense_Date_From__c != trigger_oldMap.get(pay.id).ASI_MFM_Expense_Date_From__c && pay.ASI_MFM_Status__c == 'Final')
                                                                        //|| (pay.ASI_MFM_Expense_Date_To__c != trigger_oldMap.get(pay.id).ASI_MFM_Expense_Date_To__c && pay.ASI_MFM_Status__c == 'Final')
                                                                       )){
                                                                           prePaymentSet.add(pay.id);
                                                                       }*/
            
            //Tax Code
            if(pay.ASI_MFM_Tax_Code__c != Null)
                taxCode.add(pay.ASI_MFM_Tax_Code__c);
            
            //Prefix Payment Number
            if(pay.ASI_MFM_Prefix__c != Null)
                prefixSet.add(pay.ASI_MFM_Prefix__c);
            
            //Exchange Rate
            if(pay.ASI_MFM_Status__c == 'Draft' && (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null && (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c)))){//20180222 Intrvo added Status = Draft
                
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
                
                if (last_effective_date == null || (!pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Period_From__c > last_effective_date) || (pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Expense_Date_From__c > last_effective_date)){//20171211 Introv
                    last_effective_date = !pay.ASI_MFM_Pre_payment__c ? pay.ASI_MFM_Period_From__c : pay.ASI_MFM_Expense_Date_From__c;
                }
                
                if(effective_date_From == Null || (!pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Period_From__c < effective_date_From) || (pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Expense_Date_From__c < effective_date_From)){//20171211 Introv
                    effective_date_From = !pay.ASI_MFM_Pre_payment__c ? pay.ASI_MFM_Period_From__c : pay.ASI_MFM_Expense_Date_From__c;
                }
            }
        }
        
        //budgetchecking
        if(paymentSet.size() > 0){
            budgetRemainingMap = ASI_MFM_CN_StructureCostHelperClass.calculateBudgetRemaining(paymentSet, relatedBudget, fySet, false, expenseTypeSet);
        }
        
        /*if(prePaymentSet.size() > 0){
            for(ASI_MFM_Payment_Detail__c pl : [SELECT id, ASI_MFM_GL_date__c, ASI_MFM_ETL__c, ASI_MFM_Payment__c FROM ASI_MFM_Payment_Detail__c WHERE ASI_MFM_Payment__c IN : prePaymentSet AND recordType.DeveloperName = 'ASI_MFM_CAP_CN_Payment_Detail']){
                
                existingPrepaymentLine.put('' + pl.ASI_MFM_Payment__c + pl.ASI_MFM_GL_date__c, pl);
            }
        }*/
        
        //Tax
        Map<Id, ASI_MFM_Tax_Code__c> TaxCode_List = new Map<id, ASI_MFM_Tax_Code__c>([Select id, Name, ASI_MFM_VAT_Rate__c, ASI_MFM_Manual_Input__c from ASI_MFM_Tax_Code__c WHERE id IN : taxCode]);
        
        //Only Insert
        if(trigger.isInsert){
            generatePaymentId(trigger_new, prefixSet);
        }
        
        if (pay_set.size() > 0) {
            
            xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                       where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                       and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                       //AND ASI_MFM_Effective_Date__c >= : effective_date_From 20171211 Commented Introv
                       order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
        }
        
        for(ASI_MFM_Payment__c pay : trigger_new){
            
            exchangeRate(pay, xr_list, pay_set);
            
            pay.ASI_MFM_Invoice_Amount__c = pay.ASI_MFM_Invoice_Amount__c == Null ? 0 : pay.ASI_MFM_Invoice_Amount__c;
            pay.ASI_MFM_No_Invoice_Amount__c = pay.ASI_MFM_No_Invoice_Amount__c == Null ? 0 : pay.ASI_MFM_No_Invoice_Amount__c;
            pay.ASI_MFM_Normal_Invoice_Amount__c = pay.ASI_MFM_Normal_Invoice_Amount__c == Null ? 0 : pay.ASI_MFM_Normal_Invoice_Amount__c;
            pay.ASI_MFM_Rental_Deposit__c = pay.ASI_MFM_Rental_Deposit__c == Null ? 0 : pay.ASI_MFM_Rental_Deposit__c;
            
            if(TaxCode_List.containsKey(pay.ASI_MFM_Tax_Code__c) && !TaxCode_List.get(pay.ASI_MFM_Tax_Code__c).ASI_MFM_Manual_Input__c){
                
                pay.ASI_MFM_VAT_Amount__c = pay.ASI_MFM_Invoice_Amount__c - (pay.ASI_MFM_Invoice_Amount__c / (1 + (TaxCode_List.get(pay.ASI_MFM_Tax_Code__c).ASI_MFM_VAT_Rate__c/100)));
                
            }else if(TaxCode_List.containsKey(pay.ASI_MFM_Tax_Code__c) && TaxCode_List.get(pay.ASI_MFM_Tax_Code__c).ASI_MFM_Manual_Input__c){
                
                /*if(pay.ASI_MFM_VAT_Amount__c > pay.ASI_MFM_Invoice_Amount__c){
                    pay.addError('Tax Amount cannot be greater than Invoice Amount.');
                }*/
                
            }else if(pay.ASI_MFM_Tax_Code__c == Null){
                pay.ASI_MFM_VAT_Amount__c = 0;
            }
            
            pay.ASI_MFM_Payment_Amount__c = pay.ASI_MFM_Invoice_Amount__c + pay.ASI_MFM_No_Invoice_Amount__c + pay.ASI_MFM_Normal_Invoice_Amount__c + pay.ASI_MFM_Rental_Deposit__c;
            pay.ASI_MFM_Total_Amount_Without_Tax__c = pay.ASI_MFM_Payment_Amount__c - pay.ASI_MFM_VAT_Amount__c - pay.ASI_MFM_Rental_Deposit__c;
            
            //Set Fix Approver
            //approval route
            if(pay.ASI_MFM_Status__c == 'Draft'){
                
                setApproverToNull(pay);
                
                if(mapFixRoute.containsKey(pay.ASI_MFM_Expense_Type__c))
                    setFixApprover(pay, mapFixRoute.get(pay.ASI_MFM_Expense_Type__c));
            }
            
            //prepayment line generation
            /*if(prePaymentSet.contains(pay.id) && pay.ASI_MFM_Total_Payment_Detail_Lines__c == 0){
                
                upsertPaymentDetails.addAll(calculatePrePaymentPeriod(pay, pay.ASI_MFM_Expense_Date_From__c, pay.ASI_MFM_Expense_Date_To__c, existingPrepaymentLine).get('upsert'));
                //deletePaymentDetails.addAll(calculatePrePaymentPeriod(pay, pay.ASI_MFM_Expense_Date_From__c, pay.ASI_MFM_Expense_Date_To__c, existingPrepaymentLine).get('delete'));
            }*/
            
            //budgetchecking
            if(paymentSet.contains(pay.id)
               && (pay.ASI_MFM_Accrual_Type__c == Null || pay.ASI_MFM_Accrual_Type__c == '' 
                   || (pay.ASI_MFM_Accrual_Type__c != Null && pay.ASI_MFM_Accrual_Type__c != '' && !pay.ASI_MFM_Accrual_Type__c.toLowerCase().contains('monthly accrual'))
                  )){
                      
                      //Rental Contract Update
                      if(pay.ASI_MFM_Contract__c != Null){
                          rentalContractSet.add(pay.ASI_MFM_Contract__c);
                      }
                      
                      //if(!pay.ASI_MFM_Apply_CIP_Logic__c || (pay.ASI_MFM_Apply_CIP_Logic__c && !pay.ASI_MFM_Completion__c)){
                          
                          ASI_MFM_PO__c tmp = new ASI_MFM_PO__c();
                          
                          if(updatebudget.containsKey(pay.ASI_MFM_PO__c))
                              tmp = updatebudget.get(pay.ASI_MFM_PO__c);
                          
                          tmp.id = pay.ASI_MFM_PO__c;
                          tmp.ASI_MFM_Actual_Paid_Amount__c = budgetRemainingMap.containsKey(pay.ASI_MFM_PO__c) ? budgetRemainingMap.get(pay.ASI_MFM_PO__c).get('ActualAmount') : 0;
                          tmp.ASI_MFM_JDE_Adjustment__c = budgetRemainingMap.containsKey(pay.ASI_MFM_PO__c) ? budgetRemainingMap.get(pay.ASI_MFM_PO__c).get('JDEAmount') : 0;
                          //tmp.ASI_MFM_Remaining_Budget__c = budgetRemainingMap.containsKey(pay.ASI_MFM_PO__c) ? budgetRemainingMap.get(pay.ASI_MFM_PO__c).get('Budget') - tmp.ASI_MFM_Actual_Paid_Amount__c - budgetRemainingMap.get(pay.ASI_MFM_PO__c).get('JDEAmount') : 0;
                          
                          updatebudget.put(pay.ASI_MFM_PO__c, tmp);
                      //}
                  }
            //End Budget Checking
        }
        
        /*if(deletePaymentDetails.size() > 0){
            
            try{
                
                delete deletePaymentDetails;
                
            }catch(dmlException dmle){
                
            }
        }*/
        
        /*if(upsertPaymentDetails.size() > 0){
            try{
                
                Upsert upsertPaymentDetails;
                
            }catch(dmlException dmle){
                trigger_new[0].addError(dmle.getMessage());
            }
        }*/
        
        if(updatebudget.keySet().size() > 0){
            try{
                
                Update updatebudget.values();
                
            }catch(dmlException dmle){
                
                trigger_new[0].addError(dmle.getMessage());
            }
        }
        
        //20190324-Andy: CR#88-trigger on after update instead of before update
        /*
        if(rentalContractSet.size() > 0 && !system.isBatch() && !system.isFuture())
            updateContractLine(rentalContractSet);
		*/
        
        //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
        setFinanceLastUpdated(trigger_new, trigger_oldMap);

    }
    
    @future
    Private Static void updateContractLine(Set<Id> rentalContractSet){
            
        List<ASI_MFM_Rental_Request_Line__c> rentalContract = new List<ASI_MFM_Rental_Request_Line__c>();
        
        try{
            for(Id key : rentalContractSet){
                rentalContract.add(new ASI_MFM_Rental_Request_Line__c(id = key));
            }
            
            Update rentalContract;
            
        }catch(dmlException dmle){
            
        }
    }
    
    Private Static Map<String, List<ASI_MFM_Payment_Detail__c>> calculatePrePaymentPeriod(ASI_MFM_Payment__c pay, date periodFrom, date periodTo, Map<String, ASI_MFM_Payment_Detail__c> existingPrepaymentLine){
        
        Map<String, List<ASI_MFM_Payment_Detail__c>> mapTotalList = new Map<String, List<ASI_MFM_Payment_Detail__c>>();
        List<ASI_MFM_Payment_Detail__c> insertList = new List<ASI_MFM_Payment_Detail__c>();
        List<ASI_MFM_Payment_Detail__c> deleteList = new List<ASI_MFM_Payment_Detail__c>();
        Set<String> hasLine = new Set<String>();
        
        integer months = periodFrom.monthsBetween(periodTo) + 1;
        decimal averageAmount = (pay.ASI_MFM_Payment_Amount__c/(months)).setScale(2, System.RoundingMode.CEILING);
        decimal averageNonVATAmount = (pay.ASI_MFM_Non_VAT_Amount_RMB__c/(months)).setScale(2, System.RoundingMode.CEILING);
        decimal averageAmountWithoutTax = (pay.ASI_MFM_Total_Amount_Without_Tax__c/(months)).setScale(2, System.RoundingMode.CEILING);
        decimal salesPercent = (pay.ASI_MFM_Total_Sales_Allocated_Amount__c/pay.ASI_MFM_Payment_Amount__c).setScale(4);
        decimal nonSalesPercent = (pay.ASI_MFM_Total_Non_Sales_Allocated_Amount__c/pay.ASI_MFM_Payment_Amount__c).setScale(4);

        double remaining = (pay.ASI_MFM_Payment_Amount__c - (averageAmount * (months))).setScale(2);
        double remainingWithoutTax = (pay.ASI_MFM_Total_Amount_Without_Tax__c - (averageAmountWithoutTax * (months))).setScale(2);
        double nonVATRemaining = (pay.ASI_MFM_Non_VAT_Amount_RMB__c - (averageNonVATAmount * (months))).setScale(2);
        
        String thisFY = fyconversion(date.today());
        double totalsalesNnonSalesAmount = 0;
        
        for(integer i = 0 ; i < months ; i++){
            
            Date tmpDate = date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), date.daysInMonth(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month()));
            Date glDate = tmpDate >= date.today() ? tmpDate : date.newInstance(date.today().year(), date.today().month(), date.daysInMonth(date.today().year(), date.today().month()));
            totalsalesNnonSalesAmount += (salesPercent * averageAmountWithoutTax).setScale(2) + (nonSalesPercent * averageAmountWithoutTax).setScale(2);
            
            insertList.add(new ASI_MFM_Payment_Detail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Payment_Detail')
                                                         , ASI_MFM_Fiscal_Year__c = fyconversion(glDate)
                                                         , ASI_MFM_Amount__c = (i == (months - 1)) ? averageAmount + remaining : averageAmount
                                                         , ASI_MFM_GL_date__c = glDate
                                                         , ASI_MFM_Payment__c = pay.id
                                                         , ASI_MFM_Amount_ETL__c = (i == (months - 1)) ? averageAmountWithoutTax + remainingWithoutTax : averageAmountWithoutTax
                                                         , ASI_MFM_Sales_Allocated_Amount_ETL__c = (i == (months - 1)) ? ((salesPercent * averageAmountWithoutTax) + (pay.ASI_MFM_Total_Amount_Without_Tax__c - totalsalesNnonSalesAmount).setScale(2)) : (salesPercent * averageAmountWithoutTax)
                                                         , ASI_MFM_Non_Sales_Allocated_Amount_ETL__c = (nonSalesPercent * averageAmountWithoutTax)
                                                         , ASI_MFM_Remark__c = pay.ASI_MFM_Remarks__c
                                                         //, ASI_MFM_A_C_Code__c = pay.ASI_MFM_A_C_Code__c
                                                         //, ASI_MFM_Accrual_Reverse_Budget__c = fyconversion(glDate) == thisFY ? True : False
                                                         , ASI_MFM_Non_VAT_Amount_RMB__c = (i == (months - 1)) ? averageNonVATAmount + nonVATRemaining : averageNonVATAmount
                                                         //, id = (existingPrepaymentLine.containsKey('' + pay.id + date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), 1)) ? 
                                                                 //existingPrepaymentLine.get('' + pay.id + date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), 1)).id : Null)
                                                        ));
            
            /*if(existingPrepaymentLine.containsKey('' + pay.id + date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), 1))){
                hasLine.add('' + pay.id + date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), 1));
            }*/
        }
        
        /*for(String key : existingPrepaymentLine.keySet()){
            //if(!hasLine.contains(key)){
                deleteList.add(new ASI_MFM_Payment_Detail__c(id = existingPrepaymentLine.get(key).id));
            //}
        }*/
        
        mapTotalList.put('upsert', insertList);
        //mapTotalList.put('delete', deleteList);
        
        return mapTotalList;
    }
    
    Private Static String fyconversion(date d){
        
        string fy = 'FY';
        
        if(d.month() >= 7){
            fy += ('' + d.year()).subString(2) + ('' + d.addYears(1).year()).subString(2);
        }else{
            fy += ('' + d.addYears(-1).year()).subString(2) + ('' + d.year()).subString(2);
        }
        
        return fy;
    }
    
    Public Static void setFixApprover(ASI_MFM_Payment__c p, ASI_CRM_Fix_Approval_Route__c fixApproval){
        
        Integer i = 1;
        Integer j = 1;
        String fieldname = 'asi_mfm_sys_approver_' + i + '__c';
        String fixApprover = 'asi_crm_cn_approver_' + j + '__c';
        String fixApprovalLimits = 'asi_crm_cn_approval_limit_' + j + '__c';
        
        while(RentalRequestDetail_FIELD_MAP.containsKey(fieldname) && FixApproval_FIELD_MAP.containsKey(fixApprover)){
            
            if(p.get(fieldname) != Null){
                i++;
                fieldname = 'asi_mfm_sys_approver_' + i + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) == Null || fixApproval.get(fixApprover) == p.OwnerId){
                j++;
                fixApprover = 'asi_crm_cn_approver_' + j + '__c';
                fixApprovalLimits = 'asi_crm_cn_approval_limit_' + j + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) != Null && ( fixApproval.get(fixApprovalLimits) == Null || p.ASI_MFM_Payment_Amount__c > Double.valueOf(fixApproval.get(fixApprovalLimits)))){
            	p.put(fieldname, fixApproval.get(fixApprover));
            }else{
                p.put(fieldname, fixApproval.get(fixApprover));
                break;
            }
            
            i++;
            j++;
            
            fieldname = 'asi_mfm_sys_approver_' + i + '__c';
            fixApprover = 'asi_crm_cn_approver_' + j + '__c';
            fixApprovalLimits = 'asi_crm_cn_approval_limit_' + j + '__c';
        }
        
        i = 1;
        j = 1;
        fieldname = 'asi_mfm_sys_approver_' + i + '__c';
        fixApprover = 'asi_crm_sys_approver_' + j + '__c';
        fixApprovalLimits = 'asi_crm_sys_approval_limit_' + j + '__c';
        
        while(RentalRequestDetail_FIELD_MAP.containsKey(fieldname) && FixApproval_FIELD_MAP.containsKey(fixApprover)){
            
            if(p.get(fieldname) != Null){
                i++;
                fieldname = 'asi_mfm_sys_approver_' + i + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) == Null){
                j++;
                fixApprover = 'asi_crm_sys_approver_' + j + '__c';
                fixApprovalLimits = 'asi_crm_sys_approval_limit_' + j + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) != Null && ( fixApproval.get(fixApprovalLimits) == Null || p.ASI_MFM_Payment_Amount__c > Double.valueOf(fixApproval.get(fixApprovalLimits)))){
            	p.put(fieldname, fixApproval.get(fixApprover));
            }else{
                p.put(fieldname, fixApproval.get(fixApprover));
                break;
            }
            
            i++;
            j++;
            
            fieldname = 'asi_mfm_sys_approver_' + i + '__c';
            fixApprover = 'asi_crm_sys_approver_' + j + '__c';
            fixApprovalLimits = 'asi_crm_sys_approval_limit_' + j + '__c';
        }
        
        /*while(RentalRequestDetail_FIELD_MAP.containsKey(fieldname)){
            fieldname = 'asi_mfm_sys_approver_' + i + '__c';
            
            if(p.get(fieldname) != Null){
                i++;
                fieldname = 'asi_mfm_sys_approver_' + i + '__c';
                continue;
            }else{
                p.put(fieldname, fixApproval.ASI_CRM_CN_Alternative_Approver__c);
                break;
            }
        }*/
    }
    
    Public Static void generatePaymentId(List<ASI_MFM_Payment__c> trigger_new, Set<Id> prefixSet){
        Map<Id, ASI_MFM_Prefix__c> px = new Map<Id, ASI_MFM_Prefix__c>([select id, Name, ASI_MFM_Fiscal_year__c, ASI_MFM_Next_Number__c
                                                                        from asi_mfm_prefix__c 
                                                                        where ASI_MFM_Inactive__c = false
                                                                        AND id IN : prefixSet
                                                                        and recordtype.developerName like 'ASI_MFM_CN_Prefix' 
                                                                        FOR UPDATE]);
        
        //setup payment Name
        for(ASI_MFM_Payment__c pay : trigger_new){
            
            if(px.containsKey(pay.ASI_MFM_Prefix__c)){
                pay.Name = px.get(pay.ASI_MFM_Prefix__c).Name + px.get(pay.ASI_MFM_Prefix__c).ASI_MFM_Fiscal_year__c.subString(2, 4);
                
                pay.Name += ('' + (10000 + px.get(pay.ASI_MFM_Prefix__c).ASI_MFM_Next_Number__c)).subString(1);
                
                px.get(pay.ASI_MFM_Prefix__c).ASI_MFM_Next_Number__c = px.get(pay.ASI_MFM_Prefix__c).ASI_MFM_Next_Number__c + 1;
            }
        }
        try{
            
            ASI_MFM_Function.updatePrefix(px.values());
            
        }catch(dmlException dmle){
            
        }
    }
    
    Public Static void exchangeRate(ASI_MFM_Payment__c pay, List<ASI_MFM_Exchange_Rate__c> xr_list, Set<Id> pay_set){
        //exchange Rate
        if (pay_set.contains(pay.id)) {
            
            if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                
                pay.ASI_MFM_Exchange_Rate__c = 1;
            }else {
                
                pay.ASI_MFM_Exchange_Rate__c = null;    
                if (pay.ASI_MFM_Currency__c != null && ((!pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Period_From__c != Null) || (pay.ASI_MFM_Pre_payment__c && pay.ASI_MFM_Expense_Date_From__c != Null))){//20180222 Introv
                    Date effeDate = !pay.ASI_MFM_Pre_payment__c ? pay.ASI_MFM_Period_From__c : pay.ASI_MFM_Expense_Date_From__c;//20180222 Introv
                    for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                        if (xr.ASI_MFM_Counter_Currency__c == pay.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= effeDate) {
                            pay.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                            break;
                        }else if (xr.ASI_MFM_Counter_Currency__c > pay.ASI_MFM_Currency__c) {
                            break;
                        }
                    }
                }
            }
        }
        //exchange rate end
    }
    
    public static void setApproverToNull(ASI_MFM_Payment__c p)
    {   
        p.ASI_MFM_Sys_Approver_1__c = null;
        p.ASI_MFM_Sys_Approver_2__c = null;
        p.ASI_MFM_Sys_Approver_3__c = null;
        p.ASI_MFM_Sys_Approver_4__c = null;
        p.ASI_MFM_Sys_Approver_5__c = null;
        p.ASI_MFM_Sys_Approver_6__c = null;
        p.ASI_MFM_Sys_Approver_7__c = null;
        p.ASI_MFM_Sys_Approver_8__c = null;
        p.ASI_MFM_Sys_Approver_9__c = null;
        p.ASI_MFM_Sys_Approver_10__c = null;
        p.ASI_MFM_Sys_Approver_11__c = null;
        p.ASI_MFM_Sys_Approver_12__c = null;
        p.ASI_MFM_Sys_Approver_13__c = null;
    }
    
    //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
    private static void setFinanceLastUpdated(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        for (ASI_MFM_Payment__c p : trigger_new) {
            if (trigger_oldMap == NULL) {
                if ((p.ASI_MFM_G_L_Date__c != NULL) || (p.ASI_MFM_Invoice_Number__c != NULL)) p.ASI_MFM_Submitter__c = UserInfo.getUserId();
            } else {
                if ((p.ASI_MFM_G_L_Date__c != trigger_oldMap.get(p.Id).ASI_MFM_G_L_Date__c) || (p.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(p.Id).ASI_MFM_Invoice_Number__c)) p.ASI_MFM_Submitter__c = UserInfo.getUserId();
            }
        }
    }
    
}