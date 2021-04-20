global class ASI_CRM_MY_ReGenCalculatedFOC_Batch implements Database.Batchable<sObject>, Database.Stateful{

    private Date dteRunDate;
    private String strBatch;
    private ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
    public Date today{get; private set;}{today =my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();}
    public Integer intCutOffDay {get; private set;}{intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;}
    public Date theEndDate {get; private set;} {
        theEndDate = today;
        //date firstDateInMonth = date.newInstance(today.year(), today.month(), 1);
        
        if(today.Day() >= intCutOffDay) {
            theEndDate = date.newinstance(today.addMonths(1).Year(), today.addMonths(1).Month(), intCutOffDay);
            theEndDate = theEndDate.addDays(-1);
        }
        else{
            theEndDate = date.newinstance(today.Year(), today.Month(), intCutOffDay);
            theEndDate = theEndDate.addDays(-1);
        }
    }
	public id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
	public id idRT_CalFOCHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC');
    public id idRT_CalFOCItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item');
    public integer intBatchLimit = 1800;
    private integer min_offtake = 12;
    private date dteStart;
    private date dteEnd;
    private boolean blnTodayCutoff = false;
    private boolean haveData;
    private set<id> setOfCustomer = new set<id>();
    private map<Date, List<ASI_TH_CRM_Actual_Offtake__c>> map_date_offtake = new map<Date, List<ASI_TH_CRM_Actual_Offtake__c>>();
    private boolean isRegen;
    private Set<String> foc_customer_contract_set = new Set<String>();
    
    
    // for regen FOC 
    global ASI_CRM_MY_ReGenCalculatedFOC_Batch(Date dteD, boolean haveData, set<id> setOfCustomer, map<Date, List<ASI_TH_CRM_Actual_Offtake__c>> map_date_offtake, boolean isRegen) {
        // Batch Constructor
        dteRunDate = dteD;
        strBatch = 'Draft-Processing';
        this.haveData = haveData;
        this.setOfCustomer = setOfCustomer;
        this.map_date_offtake = map_date_offtake;
        this.isRegen = isRegen;
        /*
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
        */
        
        if(Test.isRunningTest()){
            intCutOffDay = 26;
            blnTodayCutoff = true;
        }
        
        dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
        dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
        dteEnd = dteEnd.addDays(-1);
        
        
        // Clean the previous generated data
        String strPY = String.valueOf(dteEnd.year());
        String strPM = String.valueOf(dteEnd.month());
        strPM = strPM.length() == 1 ? '0' + strPM : strPM;
       	list<ASI_CRM_Calculated_FOC__c> lstToDelete = 
            [SELECT id FROM ASI_CRM_Calculated_FOC__c 
             WHERE ASI_CRM_Year__c = :strPY 
             AND ASI_CRM_Month__c = :strPM 
             AND ASI_CRM_Customer__c = :setOfCustomer
             LIMIT 1000];
      
        if (lstToDelete != null && lstToDelete.size() > 0) {
            delete lstToDelete;
        }
        // Clean the previous generated data
        
        
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
        
        // Declaration
        //integer intCutOffDay;
        //boolean blnTodayCutoff = false;
        
        set<id> setCustomer = new set<id>();
        set<id> setCustomerDelete = new set<id>();
        set<id> setOTHeader = new set<id>();
        set<id> setContracts = new set<id>();
        set<id> setRTContract = new set<id>();
       
            
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalculatedFOC = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        list<ASI_CRM_Calculated_FOC__c> lstCalFOC_Header = new list<ASI_CRM_Calculated_FOC__c>();
        list<ASI_CRM_Calculated_FOC__c> notIncludedLstCalFOC_Header = new list<ASI_CRM_Calculated_FOC__c>();
        list<ASI_CRM_Calculated_FOC_Line__c> lstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        list<ASI_CRM_Calculated_FOC_Line__c> notIncludedLstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalFOC_ALL = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        
        map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>> mapCalculatedFOC = new map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>>();
        map<string, id> mapCalFOCHeader = new map<string, id>();
        map<string, id> notIncludedMapCalFOCHeader = new map<string, id>();
        
        //List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        
        List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> lstAO = new List<ASI_TH_CRM_Actual_Offtake__c>();
        // Declaration - End
        
        /*
        if(lstMYSetting != NULL && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
		*/
        
        if(Test.isRunningTest()){
            intCutOffDay = System.today().day();
            blnTodayCutoff = true;
        }

		        
        system.debug('------------------------ASI_CRM_MY_CalculatedFOC_Schedule dteStart : ' + dteStart + ' dteEnd : ' + dteEnd);
        
        if(setOfCustomer.size() > 0){
       		lstAO = [
                SELECT ASI_CRM_ActualOfftakeHeader__r.id, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd 
                AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = :strBatch
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c = :setOfCustomer
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c
                LIMIT :intBatchLimit
        	];
        }
        else{
            lstAO = [
                SELECT ASI_CRM_ActualOfftakeHeader__r.id, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd 
                AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = :strBatch
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c
                LIMIT :intBatchLimit
            ];    
        }
        
        //lstAO = scope != null ? scope : new List<ASI_TH_CRM_Actual_Offtake__c>();
        //system.debug('@@@lstAO@@@: '+dteEnd+' || '+lstAO );
        
        
        integer intOfftakeCount = 0;
        for(ASI_TH_CRM_Actual_Offtake__c i : lstAO) {
            intOfftakeCount++;
            if (intOfftakeCount <= intBatchLimit) {
                //if(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c != null){
                  //  setCustomerDelete.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c);
                // }
                
                setCustomerDelete.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c);
                setCustomer.add(i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c);
                setOTHeader.add(i.ASI_CRM_ActualOfftakeHeader__r.id);
            } 
        }
        
        // Switch back the 'Draft-Process1' to 'Draft' before getting the FOC data
        lstAOHeader = [
            SELECT 
            	id, 
            	ASI_CRM_ToOutlet__c,
            	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
            	ASI_CRM_Status__c
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE ASI_CRM_OfftakeDate__c >= :dteStart
            AND ASI_CRM_OfftakeDate__c <= :dteEnd
            AND ASI_CRM_Status__c = :strBatch
            AND id IN :setOTHeader
        ];
        for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
            i.ASI_CRM_Status__c = 'Draft';
        }
        update lstAOHeader;
        // End - Switch Back
        
        if (intOfftakeCount > 0) {
            lstAOHeader = [
                SELECT 
                	id, 
                	ASI_CRM_ToOutlet__c, 
                	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                	ASI_CRM_Status__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE id IN :setOTHeader
            ];
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                if(isRegen){
                    if(today <= dteEnd){
                        i.ASI_CRM_Status__c = 'Draft';
                    }
                    else{
                    	i.ASI_CRM_Status__c = 'Final';    
                    }
                }
                else{
                    if (blnTodayCutoff) {
                    	i.ASI_CRM_Status__c = 'Final';
                    } 
                    else {
                        i.ASI_CRM_Status__c = 'Draft';
                    }
                }
            }
        }
        
        system.debug('----------------------------------ASI_CRM_MY_CalculatedFOC_Schedule setCustomer : ' + setCustomer);
        
        if(setCustomer != NULL && setCustomer.size() > 0) {
            lstCalculatedFOC = clsFOC.genFOC_List(setCustomer, dteEnd);
        }

        for(ASI_CRM_MY_CalculatedFOC.FOCdata j : lstCalculatedFOC){
            lstCalFOC_ALL.add(j);
        }
                
        system.debug('----------------------------------ASI_CRM_MY_CalculatedFOC_Schedule lstCalFOC_ALL : ' + lstCalFOC_ALL);
        
	        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOC_ALL){
            string strTemp = i.CustomerId + '_' + i.ContractId;
            list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstTemp = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
            
            if(mapCalculatedFOC.get(strTemp) != NULL)
                lstTemp = mapCalculatedFOC.get(strTemp);
                
            lstTemp.add(i);
            
            mapCalculatedFOC.put(strTemp, lstTemp);
        }
        
        
        // upsert header
        //foc_customer_set = new Set<Id>();
        Set<Id> foc_contract_set = new Set<Id>();
        map<id, ASI_TH_CRM_Contract__c> mapContracts = clsFOC.mapContracts;
        for(string strKey : mapCalculatedFOC.keySet()){
            string[] strTemp = strKey.split('_', 2);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            string strY = String.valueOf(dteEnd.year());
            string strM = String.valueOf(dteEnd.month());
            strM = strM.length() == 1 ? '0' + strM : strM;
            
          
            id idCustomer = (ID) strCustomerId; 
            id idContract = (ID) strContractId;
            //foc_customer_set.add(idCustomer); 
            foc_contract_set.add(idContract);
            ASI_TH_CRM_Contract__c contract = mapContracts.get(idContract);  
            Id contract_ownerId = contract.OwnerId;
            lstCalFOC_Header.add(new ASI_CRM_Calculated_FOC__c(ASI_CRM_Customer__c = idCustomer, 
                                                               ASI_CRM_Contract__c = idContract, 
                                                               ASI_CRM_Year__c = strY, 
                                                               ASI_CRM_Month__c = strM, 
                                                               OwnerId = contract_ownerId,
                                                               RecordTypeId = idRT_CalFOCHeader));
        }
        if(lstCalFOC_Header != NULL && lstCalFOC_Header.size() > 0) {
            upsert lstCalFOC_Header;
            system.debug('lstCalFOC_Header count: ' + lstCalFOC_Header.size());
        }
        // upsert header
        
    	
        // upsert item 
        for(ASI_CRM_Calculated_FOC__c i : lstCalFOC_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c);
            mapCalFOCHeader.put(strId, i.id);
        }
        
        
        Map<String, Decimal> mapOfFOCActualPurchase = clsFOC.mapOfFOCActualPurchase;
        Map<String, ASI_CRM_Calculated_FOC_Line__c> mapfocLine = clsFOC.mapRemain;
		system.debug('@@@lstAO@@@: '+dteEnd+' || '+lstCalFOC_ALL );
        //system.debug('@@@mapOfFOCActualPurchase@@@: '+mapOfFOCActualPurchase);
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOC_ALL){
            string strId = i.CustomerId + '_' + i.ContractId;
            foc_customer_contract_set.add(strId);
            id idHeader = mapCalFOCHeader.get(strId);
            String key = i.CustomerId + '_' + i.ContractId + '_' +i.OriginalSKUId;
            system.debug('@@@sum_purchasekey@@@: '+key);
            Decimal sum_purchase = mapOfFOCActualPurchase.get(key) != null ? mapOfFOCActualPurchase.get(key) : 0;
            system.debug('@@@sum_purchase@@@: '+sum_purchase);
        	
            Decimal contract_target_achieved_bottle = i.contract_target_achieved_bottle;
            Decimal achievedBtl = i.AchievedBtl;
            Decimal foc_ws_dozen = i.WSFOCFactor > 0 ? ((min_offtake/achievedBtl) * i.WSFOCFactor) : 0;
            foc_ws_dozen = foc_ws_dozen.setScale(2);
            Decimal foc_prm_dozen = i.PRMFOCFactor > 0 ? ((min_offtake/achievedBtl) * i.PRMFOCFactor) : 0;
            foc_prm_dozen = foc_prm_dozen.setScale(2);
            
            system.debug('@@@contract_target_achieved_bottle@@@: '+contract_target_achieved_bottle);
            
            
            
            if(i.AP_Btl == 0){
                Decimal previous_remain = i.PRMBroughtForward;
                lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                  ASI_CRM_Actual_Purchase__c = i.AP_Btl, 
                                                                  ASI_CRM_FOC__c = 0, 
                                                                  ASI_CRM_FOC_WS__c = 0, 
                                                                  ASI_CRM_Remain__c = previous_remain, 
                                                                  ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                  ASI_CRM_SKU__c = i.SKUId,
                                                                  ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                  ASI_CRM_SetupCode__c = i.SetupCode,
                                                                  ASI_CRM_JDECOA__c = i.JDECOA, 
                                                                  ASI_CRM_ExcessQuantity__c = false,
                                                                  RecordTypeid = idRT_CalFOCItem));
            }
            else if(contract_target_achieved_bottle == 0){
                
                // not excess
                Decimal actual_purchase = i.AP_Btl;
                Decimal previous_remain = i.PRMBroughtForward;
                Decimal entitled_bottle = actual_purchase + previous_remain;
                Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                
                
                lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                              ASI_CRM_Actual_Purchase__c = i.AP_Btl,
                                                              ASI_CRM_FOC__c = foc_prm, 
                                                              ASI_CRM_FOC_WS__c = foc_ws, 
                                                              ASI_CRM_Remain__c = current_remain, 
                                                              ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                              ASI_CRM_SKU__c = i.SKUId,
                                                              ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                              ASI_CRM_SetupCode__c = i.SetupCode,
                                                              ASI_CRM_JDECOA__c = i.JDECOA,
                                                              ASI_CRM_ExcessQuantity__c = false,
                                                              RecordTypeid = idRT_CalFOCItem));
            }
            else{
                if(sum_purchase >= contract_target_achieved_bottle){
                    // excess
                    
                    Decimal actual_purchase = i.AP_Btl;
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal entitled_bottle = actual_purchase + previous_remain;
                    Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                    Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                    Decimal current_remain =  Math.Mod((integer)entitled_bottle, min_offtake);
                    
                    lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = i.AP_Btl, 
                                                                      ASI_CRM_FOC__c = foc_prm, 
                                                                      ASI_CRM_FOC_WS__c = foc_ws, 
                                                                      ASI_CRM_Remain__c = current_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA, 
                                                                      ASI_CRM_ExcessQuantity__c = true,
                                                                      RecordTypeid = idRT_CalFOCItem));
                    
                    
                }
                else{
                    Decimal new_sum_purchase = sum_purchase + i.AP_Btl;
                    if(new_sum_purchase > contract_target_achieved_bottle){
                      
                        
                        // Decimal actual_purchase = i.AP_Btl;
                        Decimal previous_remain = i.PRMBroughtForward;
                        Decimal current_remain = 0;
                        Decimal not_excess_actual_purchase = contract_target_achieved_bottle - sum_purchase;
                        
                        if(not_excess_actual_purchase >= min_offtake){
                            	
                            Decimal previous_excess_remain =  Math.Mod((integer)not_excess_actual_purchase, min_offtake);
                            Decimal actual_purchase = not_excess_actual_purchase - previous_excess_remain;
                            Decimal foc_ws = Math.floor(actual_purchase / min_offtake) * foc_ws_dozen;
                            Decimal foc_prm = Math.floor(actual_purchase / min_offtake) * foc_prm_dozen;
                            
                            // not excess
                            lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                          ASI_CRM_Actual_Purchase__c = actual_purchase, 
                                                                          ASI_CRM_FOC__c = foc_prm, 
                                                                          ASI_CRM_FOC_WS__c = foc_ws, 
                                                                          ASI_CRM_Remain__c = current_remain, 
                                                                          ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                          ASI_CRM_SKU__c = i.SKUId,
                                                                          ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                          ASI_CRM_SetupCode__c = i.SetupCode,
                                                                          ASI_CRM_JDECOA__c = i.JDECOA,        
                                                                          ASI_CRM_ExcessQuantity__c = false,
                                                                          RecordTypeid = idRT_CalFOCItem));
                            
                            
                            // excess                    
                            Decimal excess_actual_purchase = i.AP_Btl - not_excess_actual_purchase + previous_excess_remain;
                            Decimal current_excess_remain = Math.Mod((integer)excess_actual_purchase, min_offtake);
                            Decimal excess_foc_prm = Math.floor(excess_actual_purchase / min_offtake) * foc_prm_dozen;                                       
                            Decimal excess_foc_ws = Math.floor(excess_actual_purchase / min_offtake) * foc_ws_dozen;
                            
                            lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                          ASI_CRM_Actual_Purchase__c = excess_actual_purchase, 
                                                                          ASI_CRM_FOC__c = excess_foc_prm, 
                                                                          ASI_CRM_FOC_WS__c = excess_foc_ws, 
                                                                          ASI_CRM_Remain__c = current_excess_remain, 
                                                                          ASI_CRM_Pervious_Remain_PRM__c = 0,
                                                                          ASI_CRM_SKU__c = i.SKUId,
                                                                          ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                          ASI_CRM_SetupCode__c = i.SetupCode,
                                                                          ASI_CRM_JDECOA__c = i.JDECOA,      
                                                                          ASI_CRM_ExcessQuantity__c = true,
                                                                          RecordTypeid = idRT_CalFOCItem));
                                
                        }
                        else{
                            
                            // excess                    
                            Decimal excess_actual_purchase = i.AP_Btl;
                            
                            Decimal current_excess_remain = Math.Mod((integer)(excess_actual_purchase+previous_remain), min_offtake);
                            Decimal excess_foc_prm = Math.floor((excess_actual_purchase+previous_remain) / min_offtake) * foc_prm_dozen;                                       
                            Decimal excess_foc_ws = Math.floor((excess_actual_purchase+previous_remain) / min_offtake) * foc_ws_dozen;
                            
                            lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                          ASI_CRM_Actual_Purchase__c = excess_actual_purchase, 
                                                                          ASI_CRM_FOC__c = excess_foc_prm, 
                                                                          ASI_CRM_FOC_WS__c = excess_foc_ws, 
                                                                          ASI_CRM_Remain__c = current_excess_remain, 
                                                                          ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                          ASI_CRM_SKU__c = i.SKUId,
                                                                          ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                          ASI_CRM_SetupCode__c = i.SetupCode,
                                                                          ASI_CRM_JDECOA__c = i.JDECOA,      
                                                                          ASI_CRM_ExcessQuantity__c = true,
                                                                          RecordTypeid = idRT_CalFOCItem));
                            
                            
                        }
                        
                    }
                    else{
                        
                        // not excess
                        Decimal actual_purchase = i.AP_Btl;
                        Decimal previous_remain = i.PRMBroughtForward;
                        Decimal entitled_bottle = actual_purchase + previous_remain;
                        Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                        Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                        Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                        
                        
                        lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = i.AP_Btl,
                                                                      ASI_CRM_FOC__c = foc_prm, 
                                                                      ASI_CRM_FOC_WS__c = foc_ws, 
                                                                      ASI_CRM_Remain__c = current_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA,
                                                                      ASI_CRM_ExcessQuantity__c = false,
                                                                      RecordTypeid = idRT_CalFOCItem));
                    }
                }
            }
        }
        
        if(lstCalFOC_Item != NULL && lstCalFOC_Item.size() > 0) {
            upsert lstCalFOC_Item;
            system.debug('lstCalFOC_Item count: ' + lstCalFOC_Item.size());
        }
        
        if (lstAOHeader != null && lstAOHeader.size() > 0) { // && (blnTodayCutoff || blnOverOneBatch)) {
            update lstAOHeader; // to Set the AO status to 'Final' or Mark 'Draft-Processing'
        }
        
        //clsFOC.calPreviousFOCRemain(foc_contract_set, dteEnd);
    }
    
     
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
        /*
        if(!haveData){
            Set<Id> foc_contract_set = new Set<Id>();
            ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        	clsFOC.calPreviousFOCRemain(foc_contract_set, dteEnd);    
        }
        */
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        clsFOC.calRegenPreviousFOCRemain(setOfCustomer, foc_customer_contract_set, dteEnd);    
        
		
        //Date dteD = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), 1);
        system.debug('@@@finish@@@'); 
        //system.debug('@@@dteRunDate@@@: '+dteRunDate);
        //system.debug('@@@theEndDate@@@: '+theEndDate);
        dteRunDate = dteRunDate.addMonths(1);
        if(isRegen){
            if((dteRunDate.year() <= theEndDate.year() && dteRunDate.month() < theEndDate.month()) || (dteRunDate.year() < theEndDate.year())){ 
                system.debug('@@@start@@@'); 
                system.debug('@@@dteRunDate@@@: '+dteRunDate);
                //dteD = date.newinstance(dteD.Year(), dteD.Month(), 1);
                date startDate;
                date endDate;
                boolean blnTodayCutoff = false;
                boolean haveData;
                List<ASI_TH_CRM_Actual_Offtake__c> lstAO = new List<ASI_TH_CRM_Actual_Offtake__c>();
                List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
                set<id> setOTHeader = new set<id>();
                map<id, integer> mapIDBatch = new map<id, integer>();
                id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
                /*
                if(dteD.Day() >= intCutOffDay) {
                    startDate = date.newinstance(dteD.Year(), dteD.Month(), intCutOffDay);
                    if (dteD.Day() == intCutOffDay) {
                        startDate.addDays(-1);
                    }
                    endDate = date.newinstance(dteD.addMonths(1).Year(), dteD.addMonths(1).Month(), intCutOffDay);
                    endDate = endDate.addDays(-1);
                }
                else{
                    startDate = date.newinstance(dteD.addMonths(-1).Year(), dteD.addMonths(-1).Month(), intCutOffDay);
                    endDate = date.newinstance(dteD.Year(), dteD.Month(), intCutOffDay);
                    endDate = endDate.addDays(-1);
                }
                */
                /*
                startDate = date.newinstance(dteD.addMonths(-1).Year(), dteD.addMonths(-1).Month(), intCutOffDay);
                endDate = date.newinstance(dteEnd.Year(), dteEnd.Month(), intCutOffDay);
                endDate = endDate.addDays(-1);
                if (dteD.addDays(1).Day() == intCutoffDay) {
                    blnTodayCutoff = true;
                }
                */
                /*
                lstAO = [
                    SELECT ASI_CRM_ActualOfftakeHeader__r.id, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c
                    FROM ASI_TH_CRM_Actual_Offtake__c
                    WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :startDate 
                    AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :endDate 
                    AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
                    AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = 'Draft'
                    AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c = :setOfCustomer
                    ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c, ASI_CRM_ActualOfftakeHeader__r.id
                ];
                
                system.debug('@@@lstAO@@@ '+lstAO);
                for(ASI_TH_CRM_Actual_Offtake__c i : lstAO) {
                    intOfftakeCount++;
                    setOTHeader.add(i.ASI_CRM_ActualOfftakeHeader__r.id);
                    if (intOfftakeCount < intBatchLimit) {
                        mapIDBatch.put(i.ASI_CRM_ActualOfftakeHeader__r.id, intBatch);
                    } else {
                        intOfftakeCount = 0;
                        intBatch++;
                        mapIDBatch.put(i.ASI_CRM_ActualOfftakeHeader__r.id, intBatch);
                    }
                }
                
                lstAOHeader = [
                    SELECT 
                        id, 
                        ASI_CRM_ToOutlet__c, 
                        ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                        ASI_CRM_Status__c
                    FROM ASI_CRM_ActualOfftakeHeader__c
                    WHERE id IN :setOTHeader 
                    AND ASI_CRM_Status__c = 'Draft'
                ];
                system.debug('@@@lstAOHeader@@@ '+lstAOHeader);
                
                haveData = map_date_offtake.containsKey(startDate) ? true : false;
                for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                    i.ASI_CRM_Status__c = 'Draft-Processing' + String.valueOf(mapIDBatch.get(i.id));
                }
                update lstAOHeader;
                */
                
                haveData = map_date_offtake.containsKey(startDate) ? true : false;
                Database.executeBatch(new ASI_CRM_MY_ReGenCalculatedFOC_Batch(dteRunDate, haveData, setOfCustomer, map_date_offtake, true), 10000);
            }
        }
    }
}