global class ASI_CRM_MY_CalculatedPayment_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private Date dteRunDate;
    private String strBatch;
    private ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
    public Date today{get; private set;}{today =my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();}
    public Integer intCutOffDay {get; private set;}{intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;}
	public integer intBatchLimit = 2500;
    private integer min_offtake = 12;
    private id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
    private id idRT_CalFOCPaymentHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type');
    private id idRT_CalFOCPaymentItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type');
    private date dteStart;
   	private date dteEnd;
    private boolean blnTodayCutoff;
    private boolean haveData;
    private integer numOfBatch;
    private integer currentBatchNumber;
    private Set<String> payment_customer_contract_voloumetype_set = new Set<String>();
    private List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
    
    
    global ASI_CRM_MY_CalculatedPayment_Batch(Date dteD, integer intBatch, boolean haveData, integer numOfBatch, Set<String> payment_customer_contract_voloumetype_set_pervious) {
        // Batch Constructor
        dteRunDate = dteD;
        strBatch = 'Draft-Processing' + String.valueOf(intBatch);
        blnTodayCutoff = false;
        this.haveData = haveData;
        this.numOfBatch = numOfBatch;
        currentBatchNumber = intBatch;
        payment_customer_contract_voloumetype_set = payment_customer_contract_voloumetype_set_pervious;
        
        if(Test.isRunningTest()){
            intCutOffDay = 26;
            blnTodayCutoff = true;
        }
        
        if(dteRunDate.Day() >= intCutOffDay) {
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            // To include one more day if this is the start the offtake month
            // To cater the case the the job run at 21:00 on the last cutoff but missed the 2100-2359 offtake
            if (dteRunDate.Day() == intCutOffDay) {
                dteStart.addDays(-1);
            }
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        if (dteRunDate.addDays(1).Day() == intCutoffDay) {
            blnTodayCutoff = true;
        }
        
    }
    
       
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
			SELECT Id
            FROM ASI_TH_CRM_Actual_Offtake__c
            LIMIT 1
        ]);
    }
      
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<ASI_TH_CRM_Actual_Offtake__c> scope) {
      
        set<id> setCustomer = new set<id>();
        set<id> setCustomerDelete = new set<id>();
        set<id> setOTHeader = new set<id>();
        set<id> setContracts = new set<id>();
        set<id> setRTContract = new set<id>();
            
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalculatedFOCPayment = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        list<ASI_CRM_Calculated_Payment__c> lstCalFOCPayment_Header = new list<ASI_CRM_Calculated_Payment__c>();
        list<ASI_CRM_Calculated_Payment__c> previousLstPayment_Header = new list<ASI_CRM_Calculated_Payment__c>();
        list<ASI_CRM_Calculated_Payment_Item__c> lstCalFOCPayment_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        list<ASI_CRM_Calculated_Payment_Item__c> previousLstCalFOCPayment_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalFOCPayment_ALL = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        
        map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>> mapCalculatedFOCPayment = new map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>>();
        map<string, id> mapCalPaymentHeader = new map<string, id>();
        map<string, id> mapPreviousCalPaymentHeader = new map<string, id>();
        
        //List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> lstAO = new List<ASI_TH_CRM_Actual_Offtake__c>();
        // Declaration - End
        /*
        List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        if(lstMYSetting != NULL && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
		*/
        
        if(Test.isRunningTest()){
            intCutOffDay = System.today().day();
            blnTodayCutoff = true;
        }

        // Run 

        
        system.debug('------------------------ASI_CRM_MY_CalculatedFOC_Schedule dteStart : ' + dteStart + ' dteEnd : ' + dteEnd);
                
        lstAO =
        [
            SELECT ASI_CRM_ActualOfftakeHeader__r.id, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd 
            AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c = :strBatch
            ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c
            LIMIT :intBatchLimit
        ];
        
        
        //lstAO = scope != null ? scope : new List<ASI_TH_CRM_Actual_Offtake__c>();
        //system.debug('@@@lstAO@@@: '+lstAO);
        
        integer intOfftakeCount = 0;
        for(ASI_TH_CRM_Actual_Offtake__c i : lstAO) {
            intOfftakeCount++;
            if (intOfftakeCount <= intBatchLimit) {
                if(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c != null){
                    setCustomerDelete.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c);
                }
                setCustomerDelete.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c);
                setCustomer.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c);
                setOTHeader.add(i.ASI_CRM_ActualOfftakeHeader__r.id);
            } 
        }
        
        
        // Switch back the 'Draft-Process1' to 'Draft' before getting the FOC data
        ////////////////////   update on 2018-12-10   ////////////////////
        ////////////////////         before           ////////////////////
        
        lstAOHeader = [
            SELECT id, ASI_CRM_ToOutlet__c, ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Calculated_Payment_Status__c
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE ASI_CRM_OfftakeDate__c >= :dteStart
            AND ASI_CRM_OfftakeDate__c <= :dteEnd
            AND ASI_CRM_Calculated_Payment_Status__c = :strBatch
            AND id IN :setOTHeader
        ];
        for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
            i.ASI_CRM_Calculated_Payment_Status__c = 'Draft';
        }
        update lstAOHeader;
        // End - Switch Back
        
        /*
        if (intOfftakeCount > 0) {
            lstAOHeader = [
                SELECT id, ASI_CRM_ToOutlet__c, ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Calculated_Payment_Status__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE id IN :setOTHeader
            ];
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                if (blnTodayCutoff) {
                    i.ASI_CRM_Calculated_Payment_Status__c = 'Final';
                } 
                else {
                    i.ASI_CRM_Calculated_Payment_Status__c = 'Draft';
                }
            }
        }
        */
        ////////////////////   update on 2018-12-10   ////////////////////
        
        system.debug('@@@setCustomer@@@: '+setCustomer);
       
        if(setCustomer != NULL && setCustomer.size() > 0) {
            lstCalculatedFOCPayment = clsFOC.genFOCPayment_List(setCustomer, dteEnd);
        }
        
        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata j : lstCalculatedFOCPayment){
            lstCalFOCPayment_ALL.add(j);
        }
        
             
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOCPayment_ALL){
            string strTemp = i.CustomerId + '_' + i.ContractId+'_'+i.voloumeType;
            list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstTemp = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
            
            if(mapCalculatedFOCPayment.get(strTemp) != NULL)
                lstTemp = mapCalculatedFOCPayment.get(strTemp);
                
            lstTemp.add(i);
            
            mapCalculatedFOCPayment.put(strTemp, lstTemp);
        }
        
        
        // upsert header
        map<id, ASI_TH_CRM_Contract__c> mapContracts = clsFOC.mapContracts;
        for(string strKey : mapCalculatedFOCPayment.keySet()){
            string[] strTemp = strKey.split('_', 3);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            String voloumeType = strTemp[2];
            system.debug('@@@voloumeType@@@ : '+voloumeType);
            string strY = String.valueOf(dteEnd.year());
            string strM = String.valueOf(dteEnd.month());
            strM = strM.length() == 1 ? '0' + strM : strM;
            
            id idCustomer = (ID) strCustomerId;
            id idContract = (ID) strContractId;
            ASI_TH_CRM_Contract__c contract = mapContracts.get(idContract);  
            Id contract_ownerId = contract.OwnerId;
            //payment_customer_set.add(idCustomer);
            //payment_contract_set.add(idContract);
            
            
            lstCalFOCPayment_Header.add(new ASI_CRM_Calculated_Payment__c(ASI_CRM_Customer__c = idCustomer, 
                                                                              ASI_CRM_Contract__c = idContract, 
                                                                              ASI_CRM_Year__c = strY, 
                                                                              ASI_CRM_Month__c = strM, 
                                                                              ASI_CRM_Incentive_Type__c = voloumeType,
                                                                              OwnerId = contract_ownerId,
                                                                              RecordTypeId = idRT_CalFOCPaymentHeader));
        }
        
        
        if(lstCalFOCPayment_Header != NULL && lstCalFOCPayment_Header.size() > 0) {
            upsert lstCalFOCPayment_Header;
            system.debug('lstCalFOCPayment_Header count: ' + lstCalFOCPayment_Header.size());
        }
        
        
        // upsert item 
        for(ASI_CRM_Calculated_Payment__c i : lstCalFOCPayment_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c)+ '_' + String.valueOf(i.ASI_CRM_Incentive_Type__c);
            mapCalPaymentHeader.put(strId, i.id);
        }
        
		Map<String, Decimal> mapOfPaymentActualPurchase = clsFOC.mapOfPaymentActualPurchase;
        system.debug('@@@mapOfPaymentActualPurchase@@@: '+mapOfPaymentActualPurchase);        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOCPayment_ALL){
            string strId = i.CustomerId + '_' + i.ContractId+'_'+i.voloumeType;
            payment_customer_contract_voloumetype_set.add(strId);
            id idHeader = mapCalPaymentHeader.get(strId);
            system.debug('@@@idHeader: '+i.ContractId+' || '+idHeader);
            
            String key = i.CustomerId + '_' + i.ContractId + '_' + i.voloumeType + '_' + i.OriginalSKUId;
            system.debug('@@@sum_purchasekey@@@: '+key);
            Decimal sum_purchase = mapOfPaymentActualPurchase.get(key) != null ? mapOfPaymentActualPurchase.get(key) : 0;
            system.debug('@@@sum_purchase@@@: '+sum_purchase);
        	
            Decimal achievedBtl = i.AchievedBtl;
            Decimal cash_dozen = achievedBtl > 0 ? ((i.CashInc/achievedBtl) * min_offtake) : 0;
            cash_dozen = cash_dozen.setScale(2);
            system.debug('@@@achievedBtl@@@: '+achievedBtl); 
            system.debug('@@@CashInc@@@: '+i.CashInc);
            system.debug('@@@cash_dozen@@@: '+cash_dozen);
            
	
             if(i.AP_Btl == 0){
                Decimal previous_remain = i.PRMBroughtForward; 
                lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = 0, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain,
                                                                             ASI_CRM_Carried_Forward__c = previous_remain,
                                                                             ASI_CRM_ExcessQuantity__c = false,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                 
                 
            }   
            else if(sum_purchase >= achievedBtl){
                // excess 
                Decimal actual_purchase = i.AP_Btl;
                Decimal previous_remain = i.PRMBroughtForward;
                Decimal entitled_bottle = actual_purchase + previous_remain;   
                
                Decimal cash = Math.floor(entitled_bottle / min_offtake) * cash_dozen;
                cash = cash.setScale(2, System.RoundingMode.FLOOR);
                Decimal current_remain =  Math.Mod((integer)entitled_bottle, min_offtake);
                
                lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                             ASI_CRM_Carried_Forward__c = current_remain,
                                                                             ASI_CRM_ExcessQuantity__c = true,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
            }
            else{
                Decimal new_sum_purchase = sum_purchase + i.AP_Btl;
                if(new_sum_purchase > achievedBtl){
                    
                    //Decimal actual_purchase = i.AP_Btl;
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal current_remain = 0;
                    Decimal not_excess_actual_purchase = achievedBtl - sum_purchase;
                    
                    
                    if(not_excess_actual_purchase >= min_offtake){
                        
                        Decimal previous_excess_remain =  Math.Mod((integer)not_excess_actual_purchase, min_offtake);
                        Decimal actual_purchase = not_excess_actual_purchase - previous_excess_remain;
                        Decimal cash = Math.floor(actual_purchase / min_offtake) * cash_dozen;
                        cash = cash.setScale(2, System.RoundingMode.FLOOR);
                        system.debug('@@@cash@@@: '+cash);
                        // not excess
                        
                        lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                                 ASI_CRM_Actual_Volume__c = actual_purchase, 
                                                                                 ASI_CRM_Cash__c = cash, 
                                                                                 ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                                 ASI_CRM_SetupCode__c = i.SetupCode,
                                                                                 ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                                 ASI_CRM_Carried_Forward__c = current_remain,
                                                                                 ASI_CRM_ExcessQuantity__c = false,
                                                                                 RecordTypeid = idRT_CalFOCPaymentItem));
                        
                        
                        
                        
                        Decimal excess_actual_purchase = i.AP_Btl - not_excess_actual_purchase + previous_excess_remain;
                        Decimal current_excess_remain = Math.Mod((integer)excess_actual_purchase, min_offtake);
                        Decimal excess_cash = Math.floor(excess_actual_purchase / min_offtake) * cash_dozen;
                        excess_cash = excess_cash.setScale(2, System.RoundingMode.FLOOR);
                        
                        system.debug('@@@excess_cash@@@: '+excess_cash);
                        
                        // excess 
                        lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                                 ASI_CRM_Actual_Volume__c = excess_actual_purchase, 
                                                                                 ASI_CRM_Cash__c = excess_cash, 
                                                                                 ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                                 ASI_CRM_SetupCode__c = i.SetupCode,
                                                                                 ASI_CRM_Brought_Forward__c = 0, 
                                                                                 ASI_CRM_Carried_Forward__c = current_excess_remain,
                                                                                 ASI_CRM_ExcessQuantity__c = true,
                                                                                 RecordTypeid = idRT_CalFOCPaymentItem));
                        
                    }
                    else{
                        
                        Decimal excess_actual_purchase = i.AP_Btl;
                        Decimal current_excess_remain = Math.Mod((integer)(excess_actual_purchase + previous_remain), min_offtake);
                        Decimal excess_cash = Math.floor((excess_actual_purchase + previous_remain) / min_offtake) * cash_dozen;
                        excess_cash = excess_cash.setScale(2, System.RoundingMode.FLOOR);
                        
                        system.debug('@@@excess_cash@@@: '+excess_cash);
                        
                        // excess 
                        lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                                 ASI_CRM_Actual_Volume__c = excess_actual_purchase, 
                                                                                 ASI_CRM_Cash__c = excess_cash, 
                                                                                 ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                                 ASI_CRM_SetupCode__c = i.SetupCode,
                                                                                 ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                                 ASI_CRM_Carried_Forward__c = current_excess_remain,
                                                                                 ASI_CRM_ExcessQuantity__c = true,
                                                                                 RecordTypeid = idRT_CalFOCPaymentItem));
                        
                        
                    }

                }
                else{
                    // not excess
                    Decimal actual_purchase = i.AP_Btl;
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal entitled_bottle = actual_purchase + previous_remain;
                    Decimal cash = Math.floor(entitled_bottle / min_offtake) * cash_dozen;
                    
                    cash = cash.setScale(2, System.RoundingMode.FLOOR);
                    Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                    
                    system.debug('@@@not excess actual_purchase@@@: '+actual_purchase);
                    system.debug('@@@not excess previous_remain@@@: '+previous_remain);
                    system.debug('@@@not excess entitled_bottle@@@: '+entitled_bottle);
                    system.debug('@@@not excess entitled_bottle2@@@: '+Math.floor(entitled_bottle / min_offtake));
                    system.debug('@@@not excess cash_dozen@@@: '+cash_dozen);
                    system.debug('@@@not excess cash@@@: '+cash);
                    
                    
                    
                    lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                             ASI_CRM_Carried_Forward__c = current_remain,
                                                                             ASI_CRM_ExcessQuantity__c = false,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                } 
            }
        }
        
        if(lstCalFOCPayment_Item != NULL && lstCalFOCPayment_Item.size() > 0) {
            upsert lstCalFOCPayment_Item;
            system.debug('lstCalFOCPayment_Item count: ' + lstCalFOCPayment_Item.size());
        }
        
        ////////////////////   update on 2018-12-10   ////////////////////
        ////////////////////         before           ////////////////////
        /*
        if (lstAOHeader != null && lstAOHeader.size() > 0) { // && (blnTodayCutoff || blnOverOneBatch)) {
            update lstAOHeader; // to Set the AO status to 'Final' or Mark 'Draft-Processing'
        }
        */
        ////////////////////   update on 2018-12-10   ////////////////////
       
    }
	
     
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
        /*
        if(!haveData){
            Set<Id> payment_contract_set = new Set<Id>(); 
            ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        	clsFOC.calPreviousPaymentRemain(payment_contract_set, dteEnd);
        }
		*/
        currentBatchNumber++;
        if(currentBatchNumber <= numOfBatch){
            Database.executeBatch(new ASI_CRM_MY_CalculatedPayment_Batch(dteRunDate, currentBatchNumber, haveData, numOfBatch, payment_customer_contract_voloumetype_set), 10000);
        }
        else{
            
            ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
            clsFOC.calPreviousPaymentRemain(payment_customer_contract_voloumetype_set, dteEnd);
            
            ////////////////////   update on 2018-12-10   ////////////////////
            ////////////////////         after           ////////////////////
            lstAOHeader = [
                SELECT id, ASI_CRM_ToOutlet__c, ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Calculated_Payment_Status__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE ASI_CRM_OfftakeDate__c >= :dteStart
                AND ASI_CRM_OfftakeDate__c <= :dteEnd
            ];
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                if (blnTodayCutoff) {
                    i.ASI_CRM_Calculated_Payment_Status__c = 'Final';
                } 
                else {
                    i.ASI_CRM_Calculated_Payment_Status__c = 'Draft';
                }
            }
            if (lstAOHeader != null && lstAOHeader.size() > 0) { // && (blnTodayCutoff || blnOverOneBatch)) {
                update lstAOHeader; // to Set the AO status to 'Final' or Mark 'Draft-Processing'
            }
            ////////////////////         after           ////////////////////
            
            
        }
    }
}