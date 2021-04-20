global class ASI_MFM_CN_WebServiceForEMarket {
    
    private static Final Id G_RTID_BATCH_LOG = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    Private Static Final Id G_RTID_PO = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
    Private Static Final Id G_RTID_POLine = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');
    Private Static Final Id G_RTID_POSMLine = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
    Private Static Final Id G_RTID_ACCode = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');
    
    private static string G_STR_ERROR_LINE {get;set;}
    private static Id G_ID_BATCH_LOG {get;set;}
        
    global ASI_MFM_CN_WebServiceForEMarket (){
    }       
    
    global class Plan{
        webservice String Id {get;set;}
        webservice String Name {get;set;}
    }
    
    global class GetMFMPlansIdResult{
        webservice List<Plan> Plans {get;set;}
        webservice String CompletionCode {get;set;} // S = Success, F = Fail
        webservice String FailMsg {get;set;} // Filled when Completion Code = F
    }
    
    global class PPCategoryAC{
        webservice String Code {get;set;}
        webservice String Description {get;set;}
    }
    
    global class EventPP{
        webservice String Code {get;set;}
        webservice String Description {get;set;}
    }
    
    global class GetMFMPlanDetailsResult{
        webservice String Name {get;set;}
        webservice Double Amount {get;set;}
        webservice Double TtlPoAmount {get;set;}
        webservice Boolean DummyInd {get;set;}
        webservice List<PPCategoryAC> PPCategoryACs {get;set;}
        webservice List<EventPP> EventPPs {get;set;}
        webservice String CompletionCode {get;set;} // S = Success, F = Fail
        webservice String FailMsg {get;set;} // Filled when Completion Code = F
    }
    
    global class POInfo{
        webservice String Id {get;set;}
        webservice Double Amount {get;set;}
        webservice Double AmountInLocalCurrency {get;set;}
    }
    
    global class GetMFMPlanBalanceResult{
        webservice String Id {get;set;}
        webservice String Name {get;set;}
        webservice Double Amount {get;set;}
        webservice List<POInfo> POInfos {get;set;}
        webservice Boolean DummyInd {get;set;}              
        webservice String CompletionCode {get;set;} // S = Success, F = Fail
        webservice String FailMsg {get;set;} // Filled when Completion Code = F
    }
    
    global class PODetail{
        webservice String AccountCode {get;set;}
        webservice Double Amount {get;set;}
        webservice String SkuCode {get;set;}
        webservice String Description {get;set;}
        webservice Double Quantity {get;set;}
        webservice Double UnitPrice {get;set;}
        webservice String POSMSKUCode {get;set;}//20180713 Introv, it should be POSM Item Group Code
        webservice Boolean deliveryFee {get;set;}//20180713 Introv
//        webservice String UnitPrice {get;set;}
    }
    
    global class CreatePORequestArgs{
        webservice String eMarketBuyerEmail {get;set;}//20160427 Ben @ Elufa
        webservice String PlanId {get;set;}
        webservice String PrDept {get;set;}
        webservice Boolean BudgetControlReqInd {get;set;}
        webservice String Bu {get;set;}
        webservice String SubBrand {get;set;}
        webservice String ResponsibleBy {get;set;}
        webservice String EventId {get;set;}
        webservice String SupplierNo {get;set;}
        webservice String PrNo {get;set;}
        webservice String Vat {get;set;}
        webservice String DeemSalesApplies {get;set;}
        webservice Boolean CreatePoDetails {get;set;}
        webservice List<PoDetail> PoDetails {get;set;}
        webservice String TaskID {get;set;} 
        webservice String poChannel {get;set;} //20180713 Introv
    }
    
    global class CreatePOResult{                        
        webservice String CompletionCode {get;set;} // S = Success, F = Fail
        webservice String FailMsg {get;set;} // Filled when Completion Code = F
        webservice String PoId {get;set;}
        webservice String POLookupId {get;set;}		//20191217:AM@introv - emarket portal requested
    }
    
    global class CompletePOResult{                      
        webservice String CompletionCode {get;set;} // S = Success, F = Fail
        webservice String FailMsg {get;set;} // Filled when Completion Code = F     
    }
    
    Webservice static GetMFMPlansIdResult GetMFMPlansIdRequest(String prDept, String fiscalYear, String subBrand){
        GetMFMPlansIdResult result = new GetMFMPlansIdResult();         
        result.CompletionCode = 'S';
        result.Plans = new List<Plan>();                
        
        if (prDept.equals('') || prDept.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department cannot be empty.';          
            return result;
        }
        
        if (!prDept.equals('22') && !prDept.equals('25')){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department must be 22 or 25.';         
            return result;
        }
        
        if (fiscalYear == ''){
            result.CompletionCode = 'F';
            result.FailMsg = 'Fiscal Year cannot be empty.';            
            return result;
        }
        
        if (fiscalYear.left(2) != 'FY' || fiscalYear.length() !=  4){
            result.CompletionCode = 'F';
            result.FailMsg = 'Fiscal Year pattern must be prefixed with FY with 2 digits.';         
            return result;
        }
        
        try {
            Integer x = Integer.valueOf(fiscalYear.right(2));
        }
        Catch (exception e) {
            result.CompletionCode = 'F';
            result.FailMsg = 'Fiscal Year pattern must be prefixed with FY with 2 digits.';         
            return result;
        }
        
                                
        fiscalYear += '%';
        try{
            if (prDept.equals('22') ){
                prDept = 'CNB%';
            }else if (prDept.equals('25') ){
                prDept = 'CNT%';
            }
            
            List<ASI_MFM_Plan_Line_Item__c> plans = [SELECT ASI_MFM_Plan__r.Name, 
                ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, 
                ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c  FROM ASI_MFM_Plan_Line_Item__c 
//            WHERE ASI_MFM_Plan__r.ASI_MFM_Fiscal_Year_look_up__r.Name like :fiscalYear 
              WHERE ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c like :fiscalYear
            AND ASI_MFM_Plan__r.ASI_MFM_Prefix__r.name like :prDept
            AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c = :subBrand];
            
            for (ASI_MFM_Plan_Line_Item__c plan : plans){
                Plan p = new Plan();
                //p.id = plan.ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c;
                p.Id = plan.ASI_MFM_Plan__r.Name;  //Edited by Michael Yip (Introv) 23Jun2014 to replace plan name with description
                //p.Name = plan.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c;
                p.Name = plan.ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c;
                result.Plans.add(p);
            }
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
        }
        
        return result; 
    }   
    
    Webservice static GetMFMPlanDetailsResult GetMFMPlanDetailsRequest(String planId){
        GetMFMPlanDetailsResult result = new GetMFMPlanDetailsResult();         
        result.CompletionCode = 'S';
        result.PPCategoryACs = new List<PPCategoryAC>();
        result.EventPPs = new List<EventPP>();
        
        if (planId.equals('') || planId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Plan ID cannot be empty.';            
            return result;
        }
        
        try{
            List<ASI_MFM_Plan__c> plans = [SELECT Id, ASI_MFM_Plan_Name__c, ASI_MFM_Plan_Amount__c, 
                ASI_MFM_CN_Total_PO_Amount__c, ASI_MFM_CN_Dummy__c, ASI_MFM_PP_Category__c, ASI_MFM_Plan_Description__c  
                FROM ASI_MFM_Plan__c 
                WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :planId ];
            
            System.debug('planId:'+planId);
                
            if (plans.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Plan ID.';            
                return result;
            }               
            
            ASI_MFM_Plan__c plan = plans[0];
            result.Name = plan.ASI_MFM_Plan_Description__c;
            //result.Name = plan.ASI_MFM_Plan_Name__c; //Edited by Michael Yip (Introv) 23Jun2014 to replace plan name with description
            result.Amount = plan.ASI_MFM_Plan_Amount__c;
            result.TtlPoAmount = plan.ASI_MFM_CN_Total_PO_Amount__c;
            result.DummyInd = plan.ASI_MFM_CN_Dummy__c;
            
            List<ASI_MFM_PP_Category_A_C__c> ppCategorys = [SELECT ASI_MFM_A_C_Code__r.Name, ASI_MFM_A_C_Name__c  FROM ASI_MFM_PP_Category_A_C__c 
            WHERE ASI_MFM_PP_Category__c = :plan.ASI_MFM_PP_Category__c];
            
            for (ASI_MFM_PP_Category_A_C__c ppCategory : ppCategorys){
                PPCategoryAC p = new PPCategoryAC();
                
                p.Code = ppCategory.ASI_MFM_A_C_Code__r.Name;
                p.Description = ppCategory.ASI_MFM_A_C_Name__c;
                result.PPCategoryACs.add(p);
            }
            
          List<ASI_MFM_Event_PP__c> eventPPs = [SELECT id, ASI_MFM_Event__r.Name, ASI_MFM_Event__r.ASI_MFM_Event_ID__c FROM ASI_MFM_Event_PP__c 
            WHERE ASI_MFM_Plan__c = :plan.Id];
            
            for (ASI_MFM_Event_PP__c eventPP : eventPPs){
                EventPP p = new EventPP();
                
                p.Code = eventPP.id;
//              p.Description = eventPP.ASI_MFM_Event__r.ASI_MFM_Event_ID__c;
                p.Description = eventPP.ASI_MFM_Event__r.Name;
                result.EventPPs.add(p);

            }
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
        }       
        
        return result;
    }
    
    Webservice static GetMFMPlanBalanceResult GetMFMPlanBalanceRequest(String planId){
        GetMFMPlanBalanceResult result = new GetMFMPlanBalanceResult();         
        result.CompletionCode = 'S';
        result.POInfos = new List<POInfo>();        
        
        if (planId.equals('') || planId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Plan ID cannot be empty.';            
            return result;
        }
        
        try{
            List<ASI_MFM_Plan__c> plans = [SELECT Id, Name, ASI_MFM_Plan_Name__c, ASI_MFM_Plan_Amount__c, ASI_MFM_CN_Total_PO_Amount__c, ASI_MFM_CN_Dummy__c, ASI_MFM_PP_Category__c 
                FROM ASI_MFM_Plan__c 
                WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :planId ];
                
            if (plans.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Plan ID.';            
                return result;
            }               
            
            ASI_MFM_Plan__c plan = plans[0];
            
            result.Id = plan.name;
            result.Name = plan.ASI_MFM_Plan_Name__c;
            //result.Amount = plan.ASI_MFM_Plan_Amount__c;
            result.Amount = plan.ASI_MFM_CN_Total_PO_Amount__c;
            result.DummyInd = plan.ASI_MFM_CN_Dummy__c;
            
            List<ASI_MFM_PO__c> pos = [SELECT Name, ASI_MFM_PO_Amount__c, ASI_MFM_Base_Currency_Amount__c  FROM ASI_MFM_PO__c 
            WHERE ASI_MFM_Plan__c = :plan.Id];
            
            for (ASI_MFM_PO__c po : pos){
                POInfo p = new POInfo();
                
                p.Id = po.Name;
                p.Amount = po.ASI_MFM_PO_Amount__c;
                p.AmountInLocalCurrency = po.ASI_MFM_Base_Currency_Amount__c;
                
                result.POInfos.add(p);
            }
                        
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
        }       
        
        return result;
    }
    
    private static string assignDebugMsg(string sLabel, string sValue) {
        string sTmpValue = '';
        sTmpValue = sLabel + ':' + (sValue==NULL ? 'NULL' : sValue) + ';';
        return sTmpValue;
    }
    
    /*
    Webservice static CreatePOResult CreatePORequest(CreatePORequestArgs oArgs){
        G_STR_ERROR_LINE = '';
        
        Datetime dtTime = Datetime.now();
        string sDatetime = dtTime.format('yyyyMMddhhmmss');
        
        if (oArgs == NULL) {
            InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';Missing CreatePORequestArgs');
            CreatePOResult oFailResult = new CreatePOResult();           
            oFailResult.CompletionCode = 'F';
            oFailResult.FailMsg = 'Missing CreatePORequestArgs';
            return oFailResult;
        }
        oArgs.CreatePoDetails = TRUE;
        InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';' +
                       	assignDebugMsg('eMarketBuyerEmail',oArgs.eMarketBuyerEmail) +
                        assignDebugMsg('PlanId',oArgs.PlanId) +
                        assignDebugMsg('PrDept',oArgs.PrDept) +
                        assignDebugMsg('BudgetControlReqInd',''+oArgs.BudgetControlReqInd) +
                        assignDebugMsg('Bu',oArgs.Bu) +
                        assignDebugMsg('SubBrand',oArgs.SubBrand) +
                        assignDebugMsg('ResponsibleBy',oArgs.ResponsibleBy) +
                        assignDebugMsg('EventId',oArgs.EventId) +
                        assignDebugMsg('SupplierNo',oArgs.SupplierNo) +
                        assignDebugMsg('PrNo',oArgs.PrNo) +
                        assignDebugMsg('Vat',oArgs.Vat) +
                        assignDebugMsg('DeemSalesApplies',oArgs.DeemSalesApplies) +
                       	assignDebugMsg('CreatePoDetails',''+oArgs.CreatePoDetails) +
                        assignDebugMsg('PoDetails',oArgs.PoDetails==NULL ? NULL : ''+oArgs.PoDetails.size()) +
                        assignDebugMsg('TaskID',oArgs.TaskID) +
                        assignDebugMsg('poChannel',oArgs.poChannel)
                      );
        
        CreatePOResult oResult = CreatePORequestCore(oArgs);
        InsertDebugMsg(sDatetime, G_STR_ERROR_LINE + ';' + oResult.CompletionCode + ';' + oResult.FailMsg);
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_MFM_CN_PO_SetPlan_TriggerClass')) {
            //run batch job
            if (G_ID_BATCH_LOG != NULL) {
                ASI_MFM_CN_EMarket_Batch objbatch = new ASI_MFM_CN_EMarket_Batch(G_ID_BATCH_LOG);
        		Id oBatchId = Database.executebatch(objbatch);
            }
        }
        
        return oResult;
    }
    */
    
    //private static CreatePOResult CreatePORequestCore(CreatePORequestArgs args){
    Webservice static CreatePOResult CreatePORequest(CreatePORequestArgs args){
        //start
        G_STR_ERROR_LINE = '';
        
        Datetime dtTime = Datetime.now();
        string sDatetime = dtTime.format('yyyyMMddhhmmss');
        
        if (args == NULL) {
            InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';Missing CreatePORequestArgs');
            CreatePOResult oFailResult = new CreatePOResult();           
            oFailResult.CompletionCode = 'F';
            oFailResult.FailMsg = 'Missing CreatePORequestArgs';
            return oFailResult;
        }
        args.CreatePoDetails = TRUE;
        InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';' +
                       	assignDebugMsg('eMarketBuyerEmail',args.eMarketBuyerEmail) +
                        assignDebugMsg('PlanId',args.PlanId) +
                        assignDebugMsg('PrDept',args.PrDept) +
                        assignDebugMsg('BudgetControlReqInd',''+args.BudgetControlReqInd) +
                        assignDebugMsg('Bu',args.Bu) +
                        assignDebugMsg('SubBrand',args.SubBrand) +
                        assignDebugMsg('ResponsibleBy',args.ResponsibleBy) +
                        assignDebugMsg('EventId',args.EventId) +
                        assignDebugMsg('SupplierNo',args.SupplierNo) +
                        assignDebugMsg('PrNo',args.PrNo) +
                        assignDebugMsg('Vat',args.Vat) +
                        assignDebugMsg('DeemSalesApplies',args.DeemSalesApplies) +
                       	assignDebugMsg('CreatePoDetails',''+args.CreatePoDetails) +
                        assignDebugMsg('PoDetails',args.PoDetails==NULL ? NULL : ''+args.PoDetails.size()) +
                        assignDebugMsg('TaskID',args.TaskID) +
                        assignDebugMsg('poChannel',args.poChannel)
                      );
        //end
        
        CreatePOResult result = new CreatePOResult();           
        result.CompletionCode = 'S';
        RecordType cnPOrecordType = Global_RecordTypeCache.getRtRec('ASI_MFM_PO__cASI_MFM_CN_PO');//[SELECT Id FROM RecordType WHERE Name = 'CN PO'];

        if (args.PrDept.equals('') || args.PrDept.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department cannot be empty.';          
            return result;
        }
        
        if (!args.PrDept.equals('22') && !args.PrDept.equals('25')){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department must be 22 or 25.';         
            return result;
        }   
        system.debug('e001: ' + args.PrDept);
        G_STR_ERROR_LINE = 'e001: ' + args.PrDept;
        if (args.PlanId.equals('') || args.PlanId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Plan ID cannot be empty.';            
            return result;
        }
        system.debug('e002: ' + args.PlanId);
        G_STR_ERROR_LINE = 'e002: ' + args.PlanId;
        /*
        if (args.BudgetControlReqInd == null){
            result.CompletionCode = 'F';
            result.FailMsg = 'Budget Control Required Indicator cannot be empty.';          
            return result;
        }       */
        
        if (args.Bu.equals('') || args.Bu.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'BU cannot be empty.';         
            return result;
        }
        system.debug('e003: ' + args.Bu);
        G_STR_ERROR_LINE = 'e003: ' + args.Bu;
        if (args.SubBrand.equals('') || args.SubBrand.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Sub-Brand cannot be empty.';          
            return result;
        }
        system.debug('e004: ' + args.SubBrand);
        G_STR_ERROR_LINE = 'e004: ' + args.SubBrand;
        if (args.ResponsibleBy.equals('') || args.ResponsibleBy.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Responsible By cannot be empty.';         
            return result;
        }
        //System.debug(args);
        /*if (args.PrDept == '25' && (args.EventId.equals('') || args.EventId.equals(null))){
            result.CompletionCode = 'F';
            result.FailMsg = 'Event ID cannot be empty.';           
            return result;
        }*/
        
        if (args.SupplierNo.equals('') || args.SupplierNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Supplier cannot be empty.';           
            return result;
        }
        system.debug('e005: ' + args.SupplierNo);
        G_STR_ERROR_LINE = 'e005: ' + args.SupplierNo;
        if (args.PrNo.equals('') || args.PrNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Number cannot be empty.';          
            return result;
        }   
        system.debug('e006: ' + args.PrNo);
        G_STR_ERROR_LINE = 'e006: ' + args.PrNo;
        if (args.Vat.equals('') || args.Vat.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'VAT Savings cannot be empty.';            
            return result;
        }   
        system.debug('e007: ' + args.Vat);
       	G_STR_ERROR_LINE = 'e007: ' + args.Vat;
        if (args.TaskID.equals('') || args.TaskID.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Task ID cannot be empty.';            
            return result;
        }  
        system.debug('e008: ' + args.TaskID);
		G_STR_ERROR_LINE = 'e008: ' + args.TaskID;
        if (args.PoDetails == null){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        
        if (args.PoDetails.size() == 0){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        system.debug('e009: ' + args.PoDetails);
        G_STR_ERROR_LINE = 'e009';
        Integer currentLineNumber = 1;
        for (PODetail poDetail : args.PoDetails){
            if (poDetail.AccountCode.equals('') || poDetail.AccountCode.equals(null)){
                result.CompletionCode = 'F';
                result.FailMsg = 'Account Code cannot be empty (line ' + currentLineNumber + ').';          
                return result;
            }
            currentLineNumber++;
            system.debug('e0010: ' + poDetail.AccountCode);
        }
        G_STR_ERROR_LINE = 'e0010: PASS ALL VALIDATIONS';
        Date startDate = Date.today();
        Date endDate = Date.today();
        
        try{
            ASI_MFM_PO__c po = new ASI_MFM_PO__c();
            
            //List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_Year_look_up__r.name FROM ASI_MFM_Plan__c WHERE name = :args.PlanId];
            //20200707:AM@Introv - get subbrand code from plan line item start
            //List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];
            List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, (SELECT ID, ASI_MFM_Sub_brand_Code__c FROM Plan_Line_Items__r) FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];
            Set<Id> oPlanLine_Subbrand = new Set<Id>();
            if (plan.size() > 0) {
                List<ASI_MFM_Plan_Line_Item__c> ltPlanItem = plan[0].Plan_Line_Items__r;
                if (ltPlanItem.size() > 0) {
                    for(ASI_MFM_Plan_Line_Item__c oPlanItem : ltPlanItem) {
                        oPlanLine_Subbrand.add(oPlanItem.ASI_MFM_Sub_brand_Code__c);
                    }
                }
            }
            if (oPlanLine_Subbrand.size() == 0) {
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Sub-brand for Plan Line.';            
                return result;
            }
            //20200707:AM@Introv - get subbrand code from plan line item end
            if (plan.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Plan ID.';            
                return result;
            }
            if (plan.size() > 0){
                if(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != null){ 
                    startDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4))),7,1);
                    endDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(4,6))),6,30);
            	}
            }
            system.debug('e0011: ' + plan[0].id);
            G_STR_ERROR_LINE = 'e0011: ' + plan[0].id;
                                    
            po.ASI_MFM_Plan__c = plan[0].id;
            po.ASI_MFM_PO_Type__c = 'eMarket';
            po.ASI_MFM_BudgetControlReqInd__c = false;
            
            RecordType cnPOReadOnlyrecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');//[SELECT Id FROM RecordType WHERE Name = 'CN PO Read-Only'];
            po.RecordTypeId = cnPOReadOnlyrecordType.Id;
            
            // Added by Alan Wong(Elufa) 20150428 Block user from creating duplicated PO
            if (args.TaskID != '00000000-0000-0000-0000-000000000000'){
                List<ASI_MFM_PO__c> existing_po = [SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :args.TaskID AND RecordTypeId =:cnPOReadOnlyrecordType.Id];
                system.debug('f001: SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = '+ args.TaskID + ' AND RecordTypeId = ' + cnPOReadOnlyrecordType.Id);
                system.debug('f003: ' + existing_po);
                if (!existing_po.isEmpty()){
                    result.CompletionCode = 'F';
                    result.FailMsg = 'PO existed. PO ID: ' + existing_po[0].Name;         
                    return result;
                }    
            }
            po.ASI_MFM_Task_ID__c = args.TaskID;
            //args.PrDept += '%';
            
            string sFilterPRDept = '';
            if (args.prDept.equals('22') ){
                //args.prDept = '22%';
                sFilterPRDept = '22%';
            }else if (args.prDept.equals('25') ){
                //args.prDept = '25%';
                sFilterPRDept = '25%';
            }
            
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like :sFilterPRDept and ASI_MFM_Fiscal_year__c = :plan[0].ASI_MFM_Fiscal_year__c limit 1];
            //20160503 Ben @ Elufa
            if(prefix.size() > 0){
            	po.ASI_MFM_Prefix__c = prefix[0].Id;
            }else{
                result.CompletionCode = 'F';
                result.FailMsg = 'Prefix can not be found';
                return result;
            }
            //20160503 End
            
            system.debug('d002: prefix id: ' + po.ASI_MFM_Prefix__c + 'prDept: ' + args.PrDept);
            system.debug('d003: soql- SELECT Id FROM ASI_MFM_Prefix__c WHERE Name like '+args.PrDept+' and ASI_MFM_Fiscal_year__c = ' + plan[0].ASI_MFM_Fiscal_year__c + ' limit 1');
            List<ASI_MFM_BU__c> bu = [SELECT Id, Name FROM ASI_MFM_BU__c WHERE ASI_MFM_CN_Country__c = 'CN' and ASI_MFM_BU_Code__c = :args.Bu];
            if (bu.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid BU.';         
                return result;
            }               
            po.ASI_MFM_BU_Code__c = bu[0].Id;                                                               
            po.ASI_MFM_CN_BU_Picklist__c = bu[0].Name;
            
            List<User> user = [SELECT Id FROM User WHERE CompanyName = 'Pernod Ricard China' and ASI_MFM_CN_Staff_No__c = :args.ResponsibleBy];
            if (user.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Responsible By.';         
                return result;
            }
            po.ASI_MFM_Budget_Owner__c = user[0].Id;    
            po.OwnerID = user[0].Id;    
            
            //20191212:AM@introv - check prefix (copy from ASI_MFM_PO_TriggerClass) start
            set<id> owner_set = new set<id>();
        	set<id> prefix_set = new set<id>();
            
            owner_set.add(po.OwnerID);
            prefix_set.add(po.ASI_MFM_Prefix__c);
            
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'PO']);
            
            string owner_role = owner_map.get(po.OwnerID).userRole.DeveloperName;
            boolean valid_prefix = false;               
            for (ASI_MFM_Role_Prefix_Relationship__c pr:prefix_map.get(po.ASI_MFM_Prefix__c).ASI_MFM_Role_Prefix_Relationships__r) {
                if (pr.ASI_MFM_Role_Name__c == owner_role) {
                    valid_prefix = true;
                    break;
                }
            }
            if (!valid_prefix) {
                result.CompletionCode = 'F';
                result.FailMsg = 'The prefix is not valid for the owner.';         
                return result;                
            }
            //20191212:AM@introv - check prefix (copy from ASI_MFM_PO_TriggerClass) end
            
            List<ASI_MFM_Event_PP__c> eventPP = [SELECT Id FROM ASI_MFM_Event_PP__c WHERE id = :args.EventId];
            if (args.PrDept == '25' && eventPP.size() == 0){
                /*result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Event ID.';           
                return result;*/
            }else if (eventPP.size() > 0 ){
                po.ASI_MFM_Event_ID__c = eventPP[0].Id;
            }
            
            List<Account> supplier = [SELECT Id, ASI_LUX_Email_Business__c
                                      	, ASI_MFM_Address_Line_1__c, ASI_MFM_Address_Line_2__c, ASI_MFM_Address_Line_3__c, ASI_MFM_Address_Line_4__c
                                      	, Fax, ASI_MFM_Payment_Terms__c, Phone
                                      FROM Account 
                                      WHERE recordtype.developername = 'ASI_MFM_CN_Supplier' and ASI_MFM_Customer_Supplier_Number__c = :args.SupplierNo];
            if (supplier.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Supplier No.';            
                return result;
            }
            po.ASI_MFM_Supplier_Name__c = supplier[0].Id;
            //20191112: fix soql 101 - exclude workflow
            po.ASI_MFM_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
            po.ASI_MFM_TR_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
            po.ASI_MFM_Supplier_Address_Line_1__c = supplier[0].ASI_MFM_Address_Line_1__c;
            po.ASI_MFM_Supplier_Address_Line_2__c = supplier[0].ASI_MFM_Address_Line_2__c;
            po.ASI_MFM_Supplier_Address_Line_3__c = supplier[0].ASI_MFM_Address_Line_3__c;
            po.ASI_MFM_Supplier_Address_Line_4__c = supplier[0].ASI_MFM_Address_Line_4__c;
            po.ASI_MFM_Supplier_Fax_Number__c = supplier[0].Fax;
            po.ASI_MFM_Supplier_Phone_Number__c = supplier[0].Phone;
            po.ASI_MFM_Payment_Terms__c = supplier[0].ASI_MFM_Payment_Terms__c;

            //20160427 Ben @ Elufa
            
            if(args.eMarketBuyerEmail != NULL && args.eMarketBuyerEmail != ''){
                List<User> user2 = new List<User>([SELECT Id FROM User WHERE email = :args.eMarketBuyerEmail AND isActive = TRUE]);
                if(user2.size() > 0){
                    po.ASI_MFM_eMarket_Buyer__c = user2[0].id;
                }
            }
            //20160427 End
            
            po.ASI_MFM_Remarks__c = args.PrNo;
            po.ASI_MFM_CN_VAT_Savings__c = args.Vat;
            po.ASI_MFM_CN_Deem_Sales_Applies__c = args.DeemSalesApplies;
            po.ASI_MFM_Status__c = 'Draft';		//20191125:Andy@introv - email notification with missing amount //po.ASI_MFM_Status__c = 'Final';
            // Added by Michael Yip (Introv) 12Sep2014 for copy final date to G\L Date
            po.ASI_MFM_PO_Final_Date__c = date.today();
            po.ASI_MFM_GL_Date__c = date.today();
            po.ASI_MFM_PO_Start_Date__c = startDate;
            po.ASI_MFM_PO_End_Date__c = endDate;
            
            //20180802 Introv add PO Channel
            po.ASI_MFM_PO_Channel__c = args.poChannel;
            
            //AM@Introv 20190718 - fix sfdc limitation
            po.ASI_MFM_From_eMarket__c = true;
            
            system.debug('PO Header: ' + po);
            System.debug('Task ID: ' + args.TaskID);
            //G_STR_ERROR_LINE = 'before insert PO';
            //insert po;
            //G_STR_ERROR_LINE = 'after insert PO';
            
            //ASI_MFM_PO__c createdPO = [SELECT Name FROM ASI_MFM_PO__c WHERE Id = :po.Id];
            //result.PoId = createdPO.Name;
            //System.debug(args.PlanId);
            //System.debug(args.PrDept);
            //System.debug(args.BudgetControlReqInd);
            //System.debug(args.Bu);
            //System.debug(args.SubBrand);
            //System.debug(args.ResponsibleBy);
            //System.debug(args.EventId);
            //System.debug(args.SupplierNo);
            //System.debug(args.PrNo);
            //System.debug(args.Vat);
            //System.debug(args.DeemSalesApplies);
            //System.debug(args.PoDetails);
            //System.debug(args.TaskID);
            
            
            //20191112: fix soql 101
            //PrepareLineDetails(po.Id, supplier[0].ASI_LUX_Email_Business__c, args.SubBrand, args.PoDetails);
            
            result.PoId = po.ASI_MFM_Task_ID__c;
            string sJSONData = System.JSON.serialize(args);
            InsertOperationMsg(sJSONData);
            
            //20191213:AM@introv - handle empty task ID start
            if ((args.TaskID == '00000000-0000-0000-0000-000000000000') && (G_ID_BATCH_LOG != NULL)) {
                string sNewTaskID = args.TaskID + G_ID_BATCH_LOG;
                
                args.TaskID = sNewTaskID;
                po.ASI_MFM_Task_ID__c = sNewTaskID;
                result.PoId = sNewTaskID;
                
                ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c();
                oLog.Id = G_ID_BATCH_LOG;
                oLog.ASI_MFM_Log_Detail__c = System.JSON.serialize(args);
                update oLog;
            }            
            //20191213:AM@introv - handle empty task ID end

            result.POLookupId = result.PoId;	//20191217:AM@introv - emarket portal requested
            
 /*
            //Added by William Yang 20140806 to assign PO Line Item record type
            RecordType cnPOLineItemRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');//[SELECT Id FROM RecordType WHERE Name = 'CN PO Line Item']; 
            //End
            
            //Edited by Michael Yip (Introv) 21Aug2014 for bulk insert po line item reducing soql
            List<ASI_MFM_PO_Line_Item__c> LPOLine = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO_POSM_Line__c> LPOSMLine = new List<ASI_MFM_PO_POSM_Line__c>();//20180815 Introv
            
            Set<string> SSubBrandID = new Set<String>();
            Set<string> SAccodeID = new Set<String>();
            Set<String> itemGroupCodeSet = new Set<String>();//20180814 Introv
            Map<String, ASI_MFM_Item_Group__c> mapItemGroupByCode = new Map<String, ASI_MFM_Item_Group__c>();
            
            for (PODetail poDetail : args.PoDetails){
                SSubBrandID.add(args.SubBrand);
                SAccodeID.add(poDetail.AccountCode);
                itemGroupCodeSet.add(poDetail.POSMSKUCode);//20180814 Introv
            }
            
            //20180814 Introv
            for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Item_Group_Code__c, ASI_MFM_Reference_Unit_Price__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN : itemGroupCodeSet]){
                mapItemGroupByCode.put(obj.ASI_MFM_Item_Group_Code__c, obj);
            }
            
            List<ASI_MFM_Sub_brand__c> LsubBrand = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c 
                    WHERE ASI_MFM_Sub_brand_Code__c IN :SSubBrandID 
                    and recordtype.developername = 'ASI_FOC_CN_Sub_brand'
                    and ASI_MFM_Active_for_MFM__c = true ];
            //poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                
            RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
                
            List<ASI_MFM_A_C_Code__c> LacCode = [SELECT Id, name FROM ASI_MFM_A_C_Code__c 
                    WHERE Name IN :SAccodeID AND RecordTypeId = :cnACRecordType.Id];
            
            for (PODetail poDetail : args.PoDetails){
                ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
                ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();//20180815 Introv
                
                System.debug(PODetail);
                System.debug(PODetail.Amount);
                System.debug(PODetail.AccountCode);
                System.debug(PODetail.SkuCode);
                System.debug(PODetail.Description);
                System.debug(PODetail.Quantity);
                System.debug(PODetail.UnitPrice);
                
                //Added by William Yang 20140806 to assign PO Line Item record type
                poLineItem.RecordTypeId = cnPOLineItemRecordType.id;
                //End
                
                //AM@Introv 20190620 - fix sfdc limitation
                poLineItem.ASI_MFM_From_eMarket__c = true;
                
                poLineItem.ASI_MFM_PO__c = po.Id;
                
                //20180802 Introv added Delivery Fee and POSM Item Group Code
                poLineItem.ASI_MFM_Delivery_Fee__c = PODetail.deliveryFee != Null ? PODetail.deliveryFee : False;
                poLineItem.ASI_MFM_Item_Group_Code__c = PODetail.POSMSKUCode;
                
                //20180815 Introv
                if(mapItemGroupByCode.containsKey(PODetail.POSMSKUCode) && !poLineItem.ASI_MFM_Delivery_Fee__c){
                    poPOSMLine.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
                    poPOSMLine.ASI_MFM_Item_Group__c = mapItemGroupByCode.get(PODetail.POSMSKUCode).id;
                    poPOSMLine.ASI_MFM_Quantity__c = PODetail.Quantity;
                    poPOSMLine.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                    poPOSMLine.ASI_MFM_PO__c = po.Id;
                    poPOSMLine.ASI_MFM_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
                    LPOSMLine.add(poPOSMLine);
                }
                //20180815 End
                
                //modeify by Eric Tsang 20150108 to change amount round up to 2 decimal places
                poLineItem.ASI_MFM_Amount__c = Decimal.valueof(poDetail.Amount).setScale(2, RoundingMode.HALF_UP);
                System.debug(poDetail.Quantity);                
                if (poDetail.SkuCode != null)
                    poLineItem.ASI_MFM_List_Item_Description__c = PODetail.Description + '\nSku Code : ' + poDetail.SkuCode;
                if (poDetail.Quantity != null)
                    poLineItem.ASI_MFM_Quantity__c = poDetail.Quantity;
                if (poDetail.UnitPrice != null)
                    poLineItem.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                System.debug(poDetail.UnitPrice);
                for(ASI_MFM_Sub_brand__c subBrand : LsubBrand){
                    if(subBrand.ASI_MFM_Sub_brand_Code__c == args.SubBrand )
                        poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                }

                for(ASI_MFM_A_C_Code__c acCode : LacCode){
                    if(acCode.Name == poDetail.AccountCode)
                        poLineItem.ASI_MFM_A_C_Code__c = acCode.Id;
                }
                
                LPOLine.add(poLineItem);
                //insert poLineItem; 
            }
            
            if(LPOLine != null && LPOLine.size()>0){
                G_STR_ERROR_LINE = 'before insert PO LINE';
                insert LPOLine;
                G_STR_ERROR_LINE = 'after insert PO LINE';
            }
            
            //20180815 Introv
            if(LPOSMLine != null && LPOSMLine.size()>0){
                G_STR_ERROR_LINE = 'before insert POSM LINE';
                insert LPOSMLine;
                G_STR_ERROR_LINE = 'after insert POSM LINE';
            }
            //20180815 End
*/

            G_STR_ERROR_LINE = '(PASS ALL LOGIC)';
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                System.debug(string.valueof(e));
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
                System.debug(result.FailMsg);
        }

        //start
        InsertDebugMsg(sDatetime, G_STR_ERROR_LINE + ';' + result.CompletionCode + ';' + result.FailMsg);
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger('ASI_MFM_CN_PO_SetPlan_TriggerClass')) {
            //run batch job
            if (G_ID_BATCH_LOG != NULL) {
                ASI_MFM_CN_EMarket_Batch objbatch = new ASI_MFM_CN_EMarket_Batch(G_ID_BATCH_LOG);
        		Id oBatchId = Database.executebatch(objbatch);
            }
        }
        //end

        return result;
    }
    /*
    private static void PrepareLineDetails(Id idPOHeader, string sSupplierEmail, string sSubBrandCode, List<PoDetail> ltDetails) {
        List<String> ltAccountCode = new List<String>();
        List<Double> ltAmount = new List<Double>();
        List<String> ltSkuCode = new List<String>();
        List<String> ltDescription = new List<String>();
        List<Double> ltQuantity = new List<Double>();
        List<Double> ltUnitPrice = new List<Double>();
        List<String> ltPOSMSKUCode = new List<String>();
        List<Boolean> ltdeliveryFee = new List<Boolean>();
        
        for(PoDetail oDetails : ltDetails) {
            ltAccountCode.add(oDetails.AccountCode);
            ltAmount.add(oDetails.Amount);
            ltSkuCode.add(oDetails.SkuCode);
            ltDescription.add(oDetails.Description);
            ltQuantity.add(oDetails.Quantity);
            ltUnitPrice.add(oDetails.UnitPrice);
            ltPOSMSKUCode.add(oDetails.POSMSKUCode);
            ltdeliveryFee.add(oDetails.deliveryFee);
        }
        
        CreateLineDetails(idPOHeader, sSupplierEmail, sSubBrandCode,
        					ltAccountCode, ltAmount, ltSkuCode, ltDescription,
                            ltQuantity, ltUnitPrice, ltPOSMSKUCode, ltdeliveryFee);
    }
    
    //@future
    private static void CreateLineDetails(Id idPOHeader, string sSupplierEmail, string sSubBrandCode,
        List<String> ltAccountCode, List<Double> ltAmount, List<String> ltSkuCode, List<String> ltDescription,
        List<Double> ltQuantity, List<Double> ltUnitPrice, List<String> ltPOSMSKUCode, List<Boolean> ltdeliveryFee) 
    {
        integer iTotalDetails = ltAccountCode.size();

        string sRTID_POLine = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');
        string sRTID_POSMLine = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
        string sRTID_ACCode = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');
        
        List<ASI_MFM_PO_Line_Item__c> LPOLine = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO_POSM_Line__c> LPOSMLine = new List<ASI_MFM_PO_POSM_Line__c>();//20180815 Introv
        
        //Set<string> SAccodeID = new Set<String>();
        //Set<String> itemGroupCodeSet = new Set<String>();//20180814 Introv
        Map<String, ASI_MFM_Item_Group__c> mapItemGroupByCode = new Map<String, ASI_MFM_Item_Group__c>();

        //20180814 Introv
        for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Item_Group_Code__c, ASI_MFM_Reference_Unit_Price__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN : ltPOSMSKUCode]){
            mapItemGroupByCode.put(obj.ASI_MFM_Item_Group_Code__c, obj);
        }
        
        List<ASI_MFM_Sub_brand__c> LsubBrand = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c 
                                                WHERE ASI_MFM_Sub_brand_Code__c = :sSubBrandCode 
                                                and recordtype.developername = 'ASI_FOC_CN_Sub_brand'
                                                and ASI_MFM_Active_for_MFM__c = true];
        //poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
        
        //RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
        
        List<ASI_MFM_A_C_Code__c> LacCode = [SELECT Id, name FROM ASI_MFM_A_C_Code__c 
                                             WHERE Name IN :ltAccountCode AND RecordTypeId = :sRTID_ACCode];
        
        for (integer i=0 ; i<iTotalDetails ; i++) {
        //for (PODetail poDetail : args.PoDetails){
            PODetail poDetail = new PODetail();
            poDetail.AccountCode = ltAccountCode[i];
            poDetail.Amount = ltAmount[i];
            poDetail.SkuCode = ltSkuCode[i];
            poDetail.Description = ltDescription[i];
            poDetail.Quantity = ltQuantity[i];
            poDetail.UnitPrice = ltUnitPrice[i];
            poDetail.POSMSKUCode = ltPOSMSKUCode[i];
            poDetail.deliveryFee = ltdeliveryFee[i];
            
            ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
            ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();//20180815 Introv
            
            //Added by William Yang 20140806 to assign PO Line Item record type
            poLineItem.RecordTypeId = sRTID_POLine;
            //End
            
            //AM@Introv 20190620 - fix sfdc limitation
            poLineItem.ASI_MFM_From_eMarket__c = true;
            
            poLineItem.ASI_MFM_PO__c = idPOHeader;
            
            //20180802 Introv added Delivery Fee and POSM Item Group Code
            poLineItem.ASI_MFM_Delivery_Fee__c = PODetail.deliveryFee != Null ? PODetail.deliveryFee : False;
            poLineItem.ASI_MFM_Item_Group_Code__c = PODetail.POSMSKUCode;
            
            //20180815 Introv
            if(mapItemGroupByCode.containsKey(PODetail.POSMSKUCode) && !poLineItem.ASI_MFM_Delivery_Fee__c){
                poPOSMLine.recordTypeId = sRTID_POSMLine;
                poPOSMLine.ASI_MFM_Item_Group__c = mapItemGroupByCode.get(PODetail.POSMSKUCode).id;
                poPOSMLine.ASI_MFM_Quantity__c = PODetail.Quantity;
                poPOSMLine.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                poPOSMLine.ASI_MFM_PO__c = idPOHeader;
                poPOSMLine.ASI_MFM_Supplier_Email__c = sSupplierEmail;
                LPOSMLine.add(poPOSMLine);
            }
            //20180815 End
            
            //modeify by Eric Tsang 20150108 to change amount round up to 2 decimal places
            poLineItem.ASI_MFM_Amount__c = Decimal.valueof(poDetail.Amount).setScale(2, RoundingMode.HALF_UP);
            System.debug(poDetail.Quantity);                
            if (poDetail.SkuCode != null)
                poLineItem.ASI_MFM_List_Item_Description__c = PODetail.Description + '\nSku Code : ' + poDetail.SkuCode;
            if (poDetail.Quantity != null)
                poLineItem.ASI_MFM_Quantity__c = poDetail.Quantity;
            if (poDetail.UnitPrice != null)
                poLineItem.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
            System.debug(poDetail.UnitPrice); 

            if (LsubBrand.size()>0)
                poLineItem.ASI_MFM_Sub_brand_Code__c = LsubBrand[0].Id; 
            
            for(ASI_MFM_A_C_Code__c acCode : LacCode){
                if(acCode.Name == poDetail.AccountCode)
                    poLineItem.ASI_MFM_A_C_Code__c = acCode.Id;
            }
            
            LPOLine.add(poLineItem);
        }
        
        if(LPOLine != null && LPOLine.size()>0){
            G_STR_ERROR_LINE = 'before insert PO LINE';
            insert LPOLine;
            G_STR_ERROR_LINE = 'after insert PO LINE';
        }
        
        //20180815 Introv
        if(LPOSMLine != null && LPOSMLine.size()>0){
            G_STR_ERROR_LINE = 'before insert POSM LINE';
            insert LPOSMLine;
            G_STR_ERROR_LINE = 'after insert POSM LINE';
        }
        //20180815 End
        
    }
    */
    Webservice static CompletePoResult CompletePoRequest(String poId){
        CompletePoResult result = new CompletePoResult();           
        result.CompletionCode = 'S';    
        
        if (poId.equals('') || poId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PO Id cannot be empty.';          
            return result;
        }
        
        try{
            //ASI_MFM_PO__c po = [SELECT id,ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE Name = :poId];
            //po.ASI_MFM_Status__c = 'Complete';
            //update po;
            
            string sRTID_PO = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
            List<ASI_MFM_PO__c> ltPOExisting = [SELECT Id, Name, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :poId AND RecordTypeId =:sRTID_PO];
            
            if (ltPOExisting.size()>0) {
                for(ASI_MFM_PO__c oPO : ltPOExisting) {
                    oPO.ASI_MFM_Status__c = 'Complete';
                }
                update ltPOExisting;
            } else {
                result.CompletionCode = 'F';
                result.FailMsg = 'System runtime exception error (Missing PO[' + poId + '])';
            }
        } catch (Exception e) {
            // Process exception here                   
            result.CompletionCode = 'F';
            result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
        }   
        
        return result;
    }
    
    Webservice static CreatePOResult GetFinalPOID(String poLookupId){
        CreatePOResult result = new CreatePOResult();           
        result.CompletionCode = 'F';
        result.FailMsg = 'System runtime exception error';
        
        if (poLookupId.equals('') || poLookupId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PO Lookup Id cannot be empty.';          
            return result;
        }
        
        try{
            string sRTID_PO = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
            List<ASI_MFM_PO__c> ltPOExisting = [SELECT Id, Name, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :poLookupId AND RecordTypeId =:sRTID_PO];
            
            if (ltPOExisting.size()>0) {
                result.CompletionCode = 'S';
                result.PoId = ltPOExisting[0].Name;
                result.FailMsg = '';
            } else {
                result.CompletionCode = 'F';
                result.FailMsg = 'System runtime exception error (Missing PO[' + poLookupId + '])';
            }
        } catch (Exception e) {
            // Process exception here                   
            result.CompletionCode = 'F';
            result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
        }   
        
        return result;
    }
    
    Webservice static CreatePOResult CreatePORequestRaw(CreatePORequestArgs args){
        CreatePOResult result = new CreatePOResult();           
        result.CompletionCode = 'S';
        //RecordType cnPOrecordType = Global_RecordTypeCache.getRtRec('ASI_MFM_PO__cASI_MFM_CN_PO');//[SELECT Id FROM RecordType WHERE Name = 'CN PO'];

        if (args.PrDept.equals('') || args.PrDept.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department cannot be empty.';          
            return result;
        }
        
        if (!args.PrDept.equals('22') && !args.PrDept.equals('25')){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department must be 22 or 25.';         
            return result;
        }   
        system.debug('e001: ' + args.PrDept);
        G_STR_ERROR_LINE = 'e001: ' + args.PrDept;
        if (args.PlanId.equals('') || args.PlanId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Plan ID cannot be empty.';            
            return result;
        }
        system.debug('e002: ' + args.PlanId);
        G_STR_ERROR_LINE = 'e002: ' + args.PlanId;
        /*
        if (args.BudgetControlReqInd == null){
            result.CompletionCode = 'F';
            result.FailMsg = 'Budget Control Required Indicator cannot be empty.';          
            return result;
        }       */
        
        if (args.Bu.equals('') || args.Bu.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'BU cannot be empty.';         
            return result;
        }
        system.debug('e003: ' + args.Bu);
        G_STR_ERROR_LINE = 'e003: ' + args.Bu;
        if (args.SubBrand.equals('') || args.SubBrand.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Sub-Brand cannot be empty.';          
            return result;
        }
        system.debug('e004: ' + args.SubBrand);
        G_STR_ERROR_LINE = 'e004: ' + args.SubBrand;
        if (args.ResponsibleBy.equals('') || args.ResponsibleBy.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Responsible By cannot be empty.';         
            return result;
        }
        //System.debug(args);
        /*if (args.PrDept == '25' && (args.EventId.equals('') || args.EventId.equals(null))){
            result.CompletionCode = 'F';
            result.FailMsg = 'Event ID cannot be empty.';           
            return result;
        }*/
        
        if (args.SupplierNo.equals('') || args.SupplierNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Supplier cannot be empty.';           
            return result;
        }
        system.debug('e005: ' + args.SupplierNo);
        G_STR_ERROR_LINE = 'e005: ' + args.SupplierNo;
        if (args.PrNo.equals('') || args.PrNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Number cannot be empty.';          
            return result;
        }   
        system.debug('e006: ' + args.PrNo);
        G_STR_ERROR_LINE = 'e006: ' + args.PrNo;
        if (args.Vat.equals('') || args.Vat.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'VAT Savings cannot be empty.';            
            return result;
        }   
        system.debug('e007: ' + args.Vat);
       	G_STR_ERROR_LINE = 'e007: ' + args.Vat;
        if (args.TaskID.equals('') || args.TaskID.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Task ID cannot be empty.';            
            return result;
        }  
        system.debug('e008: ' + args.TaskID);
		G_STR_ERROR_LINE = 'e008: ' + args.TaskID;
        if (args.PoDetails == null){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        
        if (args.PoDetails.size() == 0){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        system.debug('e009: ' + args.PoDetails);
        G_STR_ERROR_LINE = 'e009';
        Integer currentLineNumber = 1;
        for (PODetail poDetail : args.PoDetails){
            if (poDetail.AccountCode.equals('') || poDetail.AccountCode.equals(null)){
                result.CompletionCode = 'F';
                result.FailMsg = 'Account Code cannot be empty (line ' + currentLineNumber + ').';          
                return result;
            }
            currentLineNumber++;
            system.debug('e0010: ' + poDetail.AccountCode);
        }
        G_STR_ERROR_LINE = 'e0010: PASS ALL VALIDATIONS';
        Date startDate = Date.today();
        Date endDate = Date.today();
        
        try{
            ASI_MFM_PO__c po = new ASI_MFM_PO__c();
                                
            //List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_Year_look_up__r.name FROM ASI_MFM_Plan__c WHERE name = :args.PlanId];
            //List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];                      
            //20200707:AM@Introv - get subbrand code from plan line item start
            //List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];
            List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, (SELECT ID, ASI_MFM_Sub_brand_Code__c FROM Plan_Line_Items__r) FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];
            List<Id> oPlanLine_Subbrand = new List<Id>();
            if (plan.size() > 0) {
                List<ASI_MFM_Plan_Line_Item__c> ltPlanItem = plan[0].Plan_Line_Items__r;
                if (ltPlanItem.size() > 0) {
                    for(ASI_MFM_Plan_Line_Item__c oPlanItem : ltPlanItem) {
                        oPlanLine_Subbrand.add(oPlanItem.ASI_MFM_Sub_brand_Code__c);
                    }
                }
            }
            if (oPlanLine_Subbrand.size() == 0) {
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Sub-brand for Plan Line.';            
                return result;
            }
            //20200707:AM@Introv - get subbrand code from plan line item end
            if (plan.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Plan ID.';            
                return result;
            }
            if (plan.size() > 0){
                if(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != null){ 
                    startDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4))),7,1);
                    endDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(4,6))),6,30);
            	}
            }
            system.debug('e0011: ' + plan[0].id);
            G_STR_ERROR_LINE = 'e0011: ' + plan[0].id;
                                    
            po.ASI_MFM_Plan__c = plan[0].id;
            po.ASI_MFM_PO_Type__c = 'eMarket';
            po.ASI_MFM_BudgetControlReqInd__c = false;

            po.RecordTypeId = G_RTID_PO;
            
            // Added by Alan Wong(Elufa) 20150428 Block user from creating duplicated PO
            if (args.TaskID != '00000000-0000-0000-0000-000000000000'){
                List<ASI_MFM_PO__c> existing_po = [SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :args.TaskID AND RecordTypeId =:G_RTID_PO];
                system.debug('f001: SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = '+ args.TaskID + ' AND RecordTypeId = ' + G_RTID_PO);
                system.debug('f003: ' + existing_po);
                if (!existing_po.isEmpty()){
                    result.CompletionCode = 'F';
                    result.FailMsg = 'PO existed. PO ID: ' + existing_po[0].Name;         
                    return result;
                }    
            }
            po.ASI_MFM_Task_ID__c = args.TaskID;
            //args.PrDept += '%';
            
            string sFilterPRDept = '';
            if (args.prDept.equals('22') ){
                //args.prDept = '22%';
                sFilterPRDept = '22%';
            }else if (args.prDept.equals('25') ){
                //args.prDept = '25%';
                sFilterPRDept = '25%';
            }
            
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like :sFilterPRDept and ASI_MFM_Fiscal_year__c = :plan[0].ASI_MFM_Fiscal_year__c limit 1];
            //20160503 Ben @ Elufa
            if(prefix.size() > 0){
            	po.ASI_MFM_Prefix__c = prefix[0].Id;
            }else{
                result.CompletionCode = 'F';
                result.FailMsg = 'Prefix can not be found';
                return result;
            }
            //20160503 End
            
            system.debug('d002: prefix id: ' + po.ASI_MFM_Prefix__c + 'prDept: ' + args.PrDept);
            system.debug('d003: soql- SELECT Id FROM ASI_MFM_Prefix__c WHERE Name like '+args.PrDept+' and ASI_MFM_Fiscal_year__c = ' + plan[0].ASI_MFM_Fiscal_year__c + ' limit 1');
            List<ASI_MFM_BU__c> bu = [SELECT Id, Name FROM ASI_MFM_BU__c WHERE ASI_MFM_CN_Country__c = 'CN' and ASI_MFM_BU_Code__c = :args.Bu];
            if (bu.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid BU.';         
                return result;
            }               
            po.ASI_MFM_BU_Code__c = bu[0].Id;                                                               
            po.ASI_MFM_CN_BU_Picklist__c = bu[0].Name;
            
            List<User> user = [SELECT Id FROM User WHERE CompanyName = 'Pernod Ricard China' and ASI_MFM_CN_Staff_No__c = :args.ResponsibleBy];
            if (user.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Responsible By.';         
                return result;
            }
            po.ASI_MFM_Budget_Owner__c = user[0].Id;    
            po.OwnerID = user[0].Id;    
            
            List<ASI_MFM_Event_PP__c> eventPP = [SELECT Id FROM ASI_MFM_Event_PP__c WHERE id = :args.EventId];
            if (args.PrDept == '25' && eventPP.size() == 0){
                /*result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Event ID.';           
                return result;*/
            }else if (eventPP.size() > 0 ){
                po.ASI_MFM_Event_ID__c = eventPP[0].Id;
            }
            
            List<Account> supplier = [SELECT Id, ASI_LUX_Email_Business__c
                                      	, ASI_MFM_Address_Line_1__c, ASI_MFM_Address_Line_2__c, ASI_MFM_Address_Line_3__c, ASI_MFM_Address_Line_4__c
                                      	, Fax, ASI_MFM_Payment_Terms__c, Phone
                                      FROM Account 
                                      WHERE recordtype.developername = 'ASI_MFM_CN_Supplier' and ASI_MFM_Customer_Supplier_Number__c = :args.SupplierNo];
            if (supplier.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Supplier No.';            
                return result;
            }
            po.ASI_MFM_Supplier_Name__c = supplier[0].Id;
            //20191112: fix soql 101 - exclude workflow
            po.ASI_MFM_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
            po.ASI_MFM_TR_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
            po.ASI_MFM_Supplier_Address_Line_1__c = supplier[0].ASI_MFM_Address_Line_1__c;
            po.ASI_MFM_Supplier_Address_Line_2__c = supplier[0].ASI_MFM_Address_Line_2__c;
            po.ASI_MFM_Supplier_Address_Line_3__c = supplier[0].ASI_MFM_Address_Line_3__c;
            po.ASI_MFM_Supplier_Address_Line_4__c = supplier[0].ASI_MFM_Address_Line_4__c;
            po.ASI_MFM_Supplier_Fax_Number__c = supplier[0].Fax;
            po.ASI_MFM_Supplier_Phone_Number__c = supplier[0].Phone;
            po.ASI_MFM_Payment_Terms__c = supplier[0].ASI_MFM_Payment_Terms__c;

            //20160427 Ben @ Elufa
            
            if(args.eMarketBuyerEmail != NULL && args.eMarketBuyerEmail != ''){
                List<User> user2 = new List<User>([SELECT Id FROM User WHERE email = :args.eMarketBuyerEmail AND isActive = TRUE]);
                if(user2.size() > 0){
                    po.ASI_MFM_eMarket_Buyer__c = user2[0].id;
                }
            }
            //20160427 End
            
            po.ASI_MFM_Remarks__c = args.PrNo;
            po.ASI_MFM_CN_VAT_Savings__c = args.Vat;
            po.ASI_MFM_CN_Deem_Sales_Applies__c = args.DeemSalesApplies;
            po.ASI_MFM_Status__c = 'Draft';		//20191202:Andy@introv - email notification with missing amount //po.ASI_MFM_Status__c = 'Final';
            // Added by Michael Yip (Introv) 12Sep2014 for copy final date to G\L Date
            po.ASI_MFM_PO_Final_Date__c = date.today();
            po.ASI_MFM_GL_Date__c = date.today();
            po.ASI_MFM_PO_Start_Date__c = startDate;
            po.ASI_MFM_PO_End_Date__c = endDate;
            
            //20180802 Introv add PO Channel
            po.ASI_MFM_PO_Channel__c = args.poChannel;
            
            //AM@Introv 20190718 - fix sfdc limitation
            po.ASI_MFM_From_eMarket__c = true;
            
            system.debug('PO Header: ' + po);
            System.debug('Task ID: ' + args.TaskID);
            G_STR_ERROR_LINE = 'before insert PO';
            insert po;
            G_STR_ERROR_LINE = 'after insert PO';
            
            //ASI_MFM_PO__c createdPO = [SELECT Name FROM ASI_MFM_PO__c WHERE Id = :po.Id];
            //result.PoId = createdPO.Name;
            //System.debug(args.PlanId);
            //System.debug(args.PrDept);
            //System.debug(args.BudgetControlReqInd);
            //System.debug(args.Bu);
            //System.debug(args.SubBrand);
            //System.debug(args.ResponsibleBy);
            //System.debug(args.EventId);
            //System.debug(args.SupplierNo);
            //System.debug(args.PrNo);
            //System.debug(args.Vat);
            //System.debug(args.DeemSalesApplies);
            //System.debug(args.PoDetails);
            //System.debug(args.TaskID);
            
            
            //20191112: fix soql 101
            if (args.CreatePoDetails)
            	CreateLineDetails(po.Id, supplier[0].ASI_LUX_Email_Business__c, args.SubBrand, args.PoDetails, oPlanLine_Subbrand);
            /*
            result.PoId = po.ASI_MFM_Task_ID__c;
            string sJSONData = System.JSON.serialize(args);
            InsertOperationMsg(sJSONData);
            */
 /*
            //Added by William Yang 20140806 to assign PO Line Item record type
            RecordType cnPOLineItemRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');//[SELECT Id FROM RecordType WHERE Name = 'CN PO Line Item']; 
            //End
            
            //Edited by Michael Yip (Introv) 21Aug2014 for bulk insert po line item reducing soql
            List<ASI_MFM_PO_Line_Item__c> LPOLine = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO_POSM_Line__c> LPOSMLine = new List<ASI_MFM_PO_POSM_Line__c>();//20180815 Introv
            
            Set<string> SSubBrandID = new Set<String>();
            Set<string> SAccodeID = new Set<String>();
            Set<String> itemGroupCodeSet = new Set<String>();//20180814 Introv
            Map<String, ASI_MFM_Item_Group__c> mapItemGroupByCode = new Map<String, ASI_MFM_Item_Group__c>();
            
            for (PODetail poDetail : args.PoDetails){
                SSubBrandID.add(args.SubBrand);
                SAccodeID.add(poDetail.AccountCode);
                itemGroupCodeSet.add(poDetail.POSMSKUCode);//20180814 Introv
            }
            
            //20180814 Introv
            for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Item_Group_Code__c, ASI_MFM_Reference_Unit_Price__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN : itemGroupCodeSet]){
                mapItemGroupByCode.put(obj.ASI_MFM_Item_Group_Code__c, obj);
            }
            
            List<ASI_MFM_Sub_brand__c> LsubBrand = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c 
                    WHERE ASI_MFM_Sub_brand_Code__c IN :SSubBrandID 
                    and recordtype.developername = 'ASI_FOC_CN_Sub_brand'
                    and ASI_MFM_Active_for_MFM__c = true ];
            //poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                
            RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
                
            List<ASI_MFM_A_C_Code__c> LacCode = [SELECT Id, name FROM ASI_MFM_A_C_Code__c 
                    WHERE Name IN :SAccodeID AND RecordTypeId = :cnACRecordType.Id];
            
            for (PODetail poDetail : args.PoDetails){
                ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
                ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();//20180815 Introv
                
                System.debug(PODetail);
                System.debug(PODetail.Amount);
                System.debug(PODetail.AccountCode);
                System.debug(PODetail.SkuCode);
                System.debug(PODetail.Description);
                System.debug(PODetail.Quantity);
                System.debug(PODetail.UnitPrice);
                
                //Added by William Yang 20140806 to assign PO Line Item record type
                poLineItem.RecordTypeId = cnPOLineItemRecordType.id;
                //End
                
                //AM@Introv 20190620 - fix sfdc limitation
                poLineItem.ASI_MFM_From_eMarket__c = true;
                
                poLineItem.ASI_MFM_PO__c = po.Id;
                
                //20180802 Introv added Delivery Fee and POSM Item Group Code
                poLineItem.ASI_MFM_Delivery_Fee__c = PODetail.deliveryFee != Null ? PODetail.deliveryFee : False;
                poLineItem.ASI_MFM_Item_Group_Code__c = PODetail.POSMSKUCode;
                
                //20180815 Introv
                if(mapItemGroupByCode.containsKey(PODetail.POSMSKUCode) && !poLineItem.ASI_MFM_Delivery_Fee__c){
                    poPOSMLine.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
                    poPOSMLine.ASI_MFM_Item_Group__c = mapItemGroupByCode.get(PODetail.POSMSKUCode).id;
                    poPOSMLine.ASI_MFM_Quantity__c = PODetail.Quantity;
                    poPOSMLine.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                    poPOSMLine.ASI_MFM_PO__c = po.Id;
                    poPOSMLine.ASI_MFM_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
                    LPOSMLine.add(poPOSMLine);
                }
                //20180815 End
                
                //modeify by Eric Tsang 20150108 to change amount round up to 2 decimal places
                poLineItem.ASI_MFM_Amount__c = Decimal.valueof(poDetail.Amount).setScale(2, RoundingMode.HALF_UP);
                System.debug(poDetail.Quantity);                
                if (poDetail.SkuCode != null)
                    poLineItem.ASI_MFM_List_Item_Description__c = PODetail.Description + '\nSku Code : ' + poDetail.SkuCode;
                if (poDetail.Quantity != null)
                    poLineItem.ASI_MFM_Quantity__c = poDetail.Quantity;
                if (poDetail.UnitPrice != null)
                    poLineItem.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                System.debug(poDetail.UnitPrice);
                for(ASI_MFM_Sub_brand__c subBrand : LsubBrand){
                    if(subBrand.ASI_MFM_Sub_brand_Code__c == args.SubBrand )
                        poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                }

                for(ASI_MFM_A_C_Code__c acCode : LacCode){
                    if(acCode.Name == poDetail.AccountCode)
                        poLineItem.ASI_MFM_A_C_Code__c = acCode.Id;
                }
                
                LPOLine.add(poLineItem);
                //insert poLineItem; 
            }
            
            if(LPOLine != null && LPOLine.size()>0){
                G_STR_ERROR_LINE = 'before insert PO LINE';
                insert LPOLine;
                G_STR_ERROR_LINE = 'after insert PO LINE';
            }
            
            //20180815 Introv
            if(LPOSMLine != null && LPOSMLine.size()>0){
                G_STR_ERROR_LINE = 'before insert POSM LINE';
                insert LPOSMLine;
                G_STR_ERROR_LINE = 'after insert POSM LINE';
            }
            //20180815 End
*/

            G_STR_ERROR_LINE = '(PASS ALL LOGIC)';
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                System.debug(string.valueof(e));
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
                System.debug(result.FailMsg);
        }       
        
        return result;
    }
    
    Webservice static void CreateLineDetails(Id idPOHeader, string sSupplierEmail, string sSubBrandCode,
        List<PoDetail> ltDetails, List<Id> oPlanLine_Subbrand)
    {
        List<ASI_MFM_PO_Line_Item__c> LPOLine = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO_POSM_Line__c> LPOSMLine = new List<ASI_MFM_PO_POSM_Line__c>();//20180815 Introv
        
        //Set<string> SAccodeID = new Set<String>();
        //Set<String> itemGroupCodeSet = new Set<String>();//20180814 Introv
        Map<String, ASI_MFM_Item_Group__c> mapItemGroupByCode = new Map<String, ASI_MFM_Item_Group__c>();

        Set<string> ltAccountCode = new Set<string>();
        Set<string> ltPOSMSKUCode = new Set<string>();
        for (PODetail poDetail : ltDetails){
            ltAccountCode.add(poDetail.AccountCode);
            ltPOSMSKUCode.add(poDetail.POSMSKUCode);
        }
        
        //20200811:AM@introv - fix item group with wrong record type
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        //20180814 Introv
        for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Item_Group_Code__c, ASI_MFM_Reference_Unit_Price__c FROM ASI_MFM_Item_Group__c WHERE RecordTypeId = :posmitemRTID AND ASI_MFM_Item_Group_Code__c IN :ltPOSMSKUCode]){
            mapItemGroupByCode.put(obj.ASI_MFM_Item_Group_Code__c, obj);
        }
        
        List<ASI_MFM_Sub_brand__c> LsubBrand = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c 
                                                WHERE ASI_MFM_Sub_brand_Code__c = :sSubBrandCode AND ID IN :oPlanLine_Subbrand
                                                and recordtype.developername = 'ASI_FOC_CN_Sub_brand'
                                                and ASI_MFM_Active_for_MFM__c = true];
        //poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
        
        //RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
        
        List<ASI_MFM_A_C_Code__c> LacCode = [SELECT Id, name FROM ASI_MFM_A_C_Code__c 
                                             WHERE Name IN :ltAccountCode AND RecordTypeId = :G_RTID_ACCode];
        
        for (PODetail poDetail : ltDetails){
            ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
            ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();//20180815 Introv
            
            //Added by William Yang 20140806 to assign PO Line Item record type
            poLineItem.RecordTypeId = G_RTID_POLine;
            //End
            
            //AM@Introv 20190620 - fix sfdc limitation
            poLineItem.ASI_MFM_From_eMarket__c = true;
            
            poLineItem.ASI_MFM_PO__c = idPOHeader;
            
            //20180802 Introv added Delivery Fee and POSM Item Group Code
            poLineItem.ASI_MFM_Delivery_Fee__c = PODetail.deliveryFee != Null ? PODetail.deliveryFee : False;
            poLineItem.ASI_MFM_Item_Group_Code__c = PODetail.POSMSKUCode;
            
            //20180815 Introv
            if(mapItemGroupByCode.containsKey(PODetail.POSMSKUCode) && !poLineItem.ASI_MFM_Delivery_Fee__c){
                poPOSMLine.recordTypeId = G_RTID_POSMLine;
                poPOSMLine.ASI_MFM_Item_Group__c = mapItemGroupByCode.get(PODetail.POSMSKUCode).id;
                poPOSMLine.ASI_MFM_Quantity__c = PODetail.Quantity;
                poPOSMLine.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                poPOSMLine.ASI_MFM_PO__c = idPOHeader;
                poPOSMLine.ASI_MFM_Supplier_Email__c = sSupplierEmail;
                LPOSMLine.add(poPOSMLine);
            }
            //20180815 End
            
            //modeify by Eric Tsang 20150108 to change amount round up to 2 decimal places
            poLineItem.ASI_MFM_Amount__c = Decimal.valueof(poDetail.Amount).setScale(2, RoundingMode.HALF_UP);
            System.debug(poDetail.Quantity);                
            if (poDetail.SkuCode != null)
                poLineItem.ASI_MFM_List_Item_Description__c = PODetail.Description + '\nSku Code : ' + poDetail.SkuCode;
            if (poDetail.Quantity != null)
                poLineItem.ASI_MFM_Quantity__c = poDetail.Quantity;
            if (poDetail.UnitPrice != null)
                poLineItem.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
            System.debug(poDetail.UnitPrice); 

            if (LsubBrand.size()>0)
                poLineItem.ASI_MFM_Sub_brand_Code__c = LsubBrand[0].Id; 
            
            for(ASI_MFM_A_C_Code__c acCode : LacCode){
                if(acCode.Name == poDetail.AccountCode)
                    poLineItem.ASI_MFM_A_C_Code__c = acCode.Id;
            }
            
            LPOLine.add(poLineItem);
        }
        
        if(LPOLine != null && LPOLine.size()>0){
            G_STR_ERROR_LINE = 'before insert PO LINE';
            insert LPOLine;
            G_STR_ERROR_LINE = 'after insert PO LINE';
        }
        
        //20180815 Introv
        if(LPOSMLine != null && LPOSMLine.size()>0){
            G_STR_ERROR_LINE = 'before insert POSM LINE';
            insert LPOSMLine;
            G_STR_ERROR_LINE = 'after insert POSM LINE';
        }
        //20180815 End
        
    }
    
    private static void InsertDebugMsg(string sDateTime, string sMsg) {
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c(
            RecordTypeId = G_RTID_BATCH_LOG
            , ASI_MFM_Log_Detail__c  = '[' + sDateTime + ']:{' + sMsg + '}'
            , ASI_MFM_LogType__c = 'eMarket'
        );
        insert oLog;
    }
    
    private static void InsertOperationMsg(string sMsg) {
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c(
            RecordTypeId = G_RTID_BATCH_LOG
            , ASI_MFM_Log_Detail__c  = sMsg
            , ASI_MFM_Need_Operation__c = TRUE
            , ASI_MFM_LogType__c = 'eMarket'
        );
        insert oLog;
        
        G_ID_BATCH_LOG = oLog.Id;
    }
    
    //20191112: for backup - fix soql 101
/*
	private static CreatePOResult CreatePORequestCore(CreatePORequestArgs args){
        CreatePOResult result = new CreatePOResult();           
        result.CompletionCode = 'S';
        RecordType cnPOrecordType = Global_RecordTypeCache.getRtRec('ASI_MFM_PO__cASI_MFM_CN_PO');//[SELECT Id FROM RecordType WHERE Name = 'CN PO'];

        if (args.PrDept.equals('') || args.PrDept.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department cannot be empty.';          
            return result;
        }
        
        if (!args.PrDept.equals('22') && !args.PrDept.equals('25')){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Department must be 22 or 25.';         
            return result;
        }   
        system.debug('e001: ' + args.PrDept);
        G_STR_ERROR_LINE = 'e001: ' + args.PrDept;
        if (args.PlanId.equals('') || args.PlanId.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Plan ID cannot be empty.';            
            return result;
        }
        system.debug('e002: ' + args.PlanId);
        G_STR_ERROR_LINE = 'e002: ' + args.PlanId;
        
        //if (args.BudgetControlReqInd == null){
        //    result.CompletionCode = 'F';
        //    result.FailMsg = 'Budget Control Required Indicator cannot be empty.';          
        //    return result;
        //}
        
        if (args.Bu.equals('') || args.Bu.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'BU cannot be empty.';         
            return result;
        }
        system.debug('e003: ' + args.Bu);
        G_STR_ERROR_LINE = 'e003: ' + args.Bu;
        if (args.SubBrand.equals('') || args.SubBrand.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Sub-Brand cannot be empty.';          
            return result;
        }
        system.debug('e004: ' + args.SubBrand);
        G_STR_ERROR_LINE = 'e004: ' + args.SubBrand;
        if (args.ResponsibleBy.equals('') || args.ResponsibleBy.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Responsible By cannot be empty.';         
            return result;
        }
        //System.debug(args);
        //if (args.PrDept == '25' && (args.EventId.equals('') || args.EventId.equals(null))){
        //    result.CompletionCode = 'F';
        //    result.FailMsg = 'Event ID cannot be empty.';           
        //    return result;
        //}
        
        if (args.SupplierNo.equals('') || args.SupplierNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Supplier cannot be empty.';           
            return result;
        }
        system.debug('e005: ' + args.SupplierNo);
        G_STR_ERROR_LINE = 'e005: ' + args.SupplierNo;
        if (args.PrNo.equals('') || args.PrNo.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'PR Number cannot be empty.';          
            return result;
        }   
        system.debug('e006: ' + args.PrNo);
        G_STR_ERROR_LINE = 'e006: ' + args.PrNo;
        if (args.Vat.equals('') || args.Vat.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'VAT Savings cannot be empty.';            
            return result;
        }   
        system.debug('e007: ' + args.Vat);
       	G_STR_ERROR_LINE = 'e007: ' + args.Vat;
        if (args.TaskID.equals('') || args.TaskID.equals(null)){
            result.CompletionCode = 'F';
            result.FailMsg = 'Task ID cannot be empty.';            
            return result;
        }  
        system.debug('e008: ' + args.TaskID);
		G_STR_ERROR_LINE = 'e008: ' + args.TaskID;
        if (args.PoDetails == null){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        
        if (args.PoDetails.size() == 0){
            result.CompletionCode = 'F';
            result.FailMsg = 'Provide at least one PO Detail Line.';            
            return result;
        }
        system.debug('e009: ' + args.PoDetails);
        G_STR_ERROR_LINE = 'e009';
        Integer currentLineNumber = 1;
        for (PODetail poDetail : args.PoDetails){
            if (poDetail.AccountCode.equals('') || poDetail.AccountCode.equals(null)){
                result.CompletionCode = 'F';
                result.FailMsg = 'Account Code cannot be empty (line ' + currentLineNumber + ').';          
                return result;
            }
            currentLineNumber++;
            system.debug('e0010: ' + poDetail.AccountCode);
        }
        G_STR_ERROR_LINE = 'e0010: PASS ALL VALIDATIONS';
        Date startDate = Date.today();
        Date endDate = Date.today();
        
        try{
            ASI_MFM_PO__c po = new ASI_MFM_PO__c();
                                
          //  List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_Year_look_up__r.name FROM ASI_MFM_Plan__c WHERE name = :args.PlanId];
            List<ASI_MFM_Plan__c> plan = [SELECT Id, ASI_MFM_Fiscal_year__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE (recordtype.developername = 'ASI_MFM_CN_Plan' OR recordtype.developername = 'ASI_MFM_CN_Plan_Read_Only') and name = :args.PlanId];                      
            system.debug('e0011: ' + plan[0].id);
            G_STR_ERROR_LINE = 'e0011: ' + plan[0].id;
            if (plan.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Plan ID.';            
                return result;
            }
            if (plan.size() > 0){
                if(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != null){ 
                    startDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4))),7,1);
                    endDate = date.newinstance((2000+integer.valueof(plan[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(4,6))),6,30);
            	}
            }
                                    
            po.ASI_MFM_Plan__c = plan[0].id;
            po.ASI_MFM_PO_Type__c = 'eMarket';
            po.ASI_MFM_BudgetControlReqInd__c = false;
            
            RecordType cnPOReadOnlyrecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');//[SELECT Id FROM RecordType WHERE Name = 'CN PO Read-Only'];
            po.RecordTypeId = cnPOReadOnlyrecordType.Id;
            
            // Added by Alan Wong(Elufa) 20150428 Block user from creating duplicated PO
            if (args.TaskID != '00000000-0000-0000-0000-000000000000'){
                List<ASI_MFM_PO__c> existing_po = [SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = :args.TaskID AND RecordTypeId =:cnPOReadOnlyrecordType.Id];
                system.debug('f001: SELECT Id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Task_ID__c = '+ args.TaskID + ' AND RecordTypeId = ' + cnPOReadOnlyrecordType.Id);
                system.debug('f003: ' + existing_po);
                if (!existing_po.isEmpty()){
                    result.CompletionCode = 'F';
                    result.FailMsg = 'PO existed. PO ID: ' + existing_po[0].Name;         
                    return result;
                }    
            }
            po.ASI_MFM_Task_ID__c = args.TaskID;
            //args.PrDept += '%';
            
            if (args.prDept.equals('22') ){
                args.prDept = '22%';
            }else if (args.prDept.equals('25') ){
                args.prDept = '25%';
            }
            
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like :args.PrDept and ASI_MFM_Fiscal_year__c = :plan[0].ASI_MFM_Fiscal_year__c limit 1];
            //20160503 Ben @ Elufa
            if(prefix.size() > 0){
            	po.ASI_MFM_Prefix__c = prefix[0].Id;
            }else{
                result.CompletionCode = 'F';
                result.FailMsg = 'Prefix can not be found';
                return result;
            }
            //20160503 End
            
            system.debug('d002: prefix id: ' + po.ASI_MFM_Prefix__c + 'prDept: ' + args.PrDept);
            system.debug('d003: soql- SELECT Id FROM ASI_MFM_Prefix__c WHERE Name like '+args.PrDept+' and ASI_MFM_Fiscal_year__c = ' + plan[0].ASI_MFM_Fiscal_year__c + ' limit 1');
            List<ASI_MFM_BU__c> bu = [SELECT Id, Name FROM ASI_MFM_BU__c WHERE ASI_MFM_CN_Country__c = 'CN' and ASI_MFM_BU_Code__c = :args.Bu];
            if (bu.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid BU.';         
                return result;
            }               
            po.ASI_MFM_BU_Code__c = bu[0].Id;                                                               
            po.ASI_MFM_CN_BU_Picklist__c = bu[0].Name;
            
            List<User> user = [SELECT Id FROM User WHERE CompanyName = 'Pernod Ricard China' and ASI_MFM_CN_Staff_No__c = :args.ResponsibleBy];
            if (user.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Responsible By.';         
                return result;
            }
            po.ASI_MFM_Budget_Owner__c = user[0].Id;    
            po.OwnerID = user[0].Id;    
            
            List<ASI_MFM_Event_PP__c> eventPP = [SELECT Id FROM ASI_MFM_Event_PP__c WHERE id = :args.EventId];
            if (args.PrDept == '25' && eventPP.size() == 0){
                //result.CompletionCode = 'F';
                //result.FailMsg = 'Invalid Event ID.';           
                //return result;
            }else if (eventPP.size() > 0 ){
                po.ASI_MFM_Event_ID__c = eventPP[0].Id;
            }
            
            List<Account> supplier = [SELECT Id, ASI_LUX_Email_Business__c FROM Account WHERE recordtype.developername = 'ASI_MFM_CN_Supplier' and ASI_MFM_Customer_Supplier_Number__c = :args.SupplierNo];
            if (supplier.size() == 0){
                result.CompletionCode = 'F';
                result.FailMsg = 'Invalid Supplier No.';            
                return result;
            }
            po.ASI_MFM_Supplier_Name__c = supplier[0].Id;
            
            //20160427 Ben @ Elufa
            
            if(args.eMarketBuyerEmail != NULL && args.eMarketBuyerEmail != ''){
                List<User> user2 = new List<User>([SELECT Id FROM User WHERE email = :args.eMarketBuyerEmail AND isActive = TRUE]);
                if(user2.size() > 0){
                    po.ASI_MFM_eMarket_Buyer__c = user2[0].id;
                }
            }
            //20160427 End
            
            po.ASI_MFM_Remarks__c = args.PrNo;
            po.ASI_MFM_CN_VAT_Savings__c = args.Vat;
            po.ASI_MFM_CN_Deem_Sales_Applies__c = args.DeemSalesApplies;
            po.ASI_MFM_Status__c = 'Final';
            // Added by Michael Yip (Introv) 12Sep2014 for copy final date to G\L Date
            po.ASI_MFM_PO_Final_Date__c = date.today();
            po.ASI_MFM_GL_Date__c = date.today();
            po.ASI_MFM_PO_Start_Date__c = startDate;
            po.ASI_MFM_PO_End_Date__c = endDate;
            
            //20180802 Introv add PO Channel
            po.ASI_MFM_PO_Channel__c = args.poChannel;
            
            //AM@Introv 20190718 - fix sfdc limitation
            po.ASI_MFM_From_eMarket__c = true;
            
            system.debug('PO Header: ' + po);
            System.debug('Task ID: ' + args.TaskID);
            G_STR_ERROR_LINE = 'before insert PO';
            insert po;
            G_STR_ERROR_LINE = 'after insert PO';
            
            ASI_MFM_PO__c createdPO = [SELECT Name FROM ASI_MFM_PO__c WHERE Id = :po.Id];
            result.PoId = createdPO.Name;
            System.debug(args.PlanId);
            System.debug(args.PrDept);
            System.debug(args.BudgetControlReqInd);
            System.debug(args.Bu);
            System.debug(args.SubBrand);
            System.debug(args.ResponsibleBy);
            System.debug(args.EventId);
            System.debug(args.SupplierNo);
            System.debug(args.PrNo);
            System.debug(args.Vat);
            System.debug(args.DeemSalesApplies);
            System.debug(args.PoDetails);
            System.debug(args.TaskID);
            
            //Added by William Yang 20140806 to assign PO Line Item record type
            RecordType cnPOLineItemRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');//[SELECT Id FROM RecordType WHERE Name = 'CN PO Line Item']; 
            //End
            
            //Edited by Michael Yip (Introv) 21Aug2014 for bulk insert po line item reducing soql
            List<ASI_MFM_PO_Line_Item__c> LPOLine = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO_POSM_Line__c> LPOSMLine = new List<ASI_MFM_PO_POSM_Line__c>();//20180815 Introv
            
            Set<string> SSubBrandID = new Set<String>();
            Set<string> SAccodeID = new Set<String>();
            Set<String> itemGroupCodeSet = new Set<String>();//20180814 Introv
            Map<String, ASI_MFM_Item_Group__c> mapItemGroupByCode = new Map<String, ASI_MFM_Item_Group__c>();
            
            for (PODetail poDetail : args.PoDetails){
                SSubBrandID.add(args.SubBrand);
                SAccodeID.add(poDetail.AccountCode);
                itemGroupCodeSet.add(poDetail.POSMSKUCode);//20180814 Introv
            }
            
            //20180814 Introv
            for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Item_Group_Code__c, ASI_MFM_Reference_Unit_Price__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN : itemGroupCodeSet]){
                mapItemGroupByCode.put(obj.ASI_MFM_Item_Group_Code__c, obj);
            }
            
            List<ASI_MFM_Sub_brand__c> LsubBrand = [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c 
                    WHERE ASI_MFM_Sub_brand_Code__c IN :SSubBrandID 
                    and recordtype.developername = 'ASI_FOC_CN_Sub_brand'
                    and ASI_MFM_Active_for_MFM__c = true ];
            //poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                
            RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
                
            List<ASI_MFM_A_C_Code__c> LacCode = [SELECT Id, name FROM ASI_MFM_A_C_Code__c 
                    WHERE Name IN :SAccodeID AND RecordTypeId = :cnACRecordType.Id];
            
            for (PODetail poDetail : args.PoDetails){
                ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
                ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();//20180815 Introv
                
                System.debug(PODetail);
                System.debug(PODetail.Amount);
                System.debug(PODetail.AccountCode);
                System.debug(PODetail.SkuCode);
                System.debug(PODetail.Description);
                System.debug(PODetail.Quantity);
                System.debug(PODetail.UnitPrice);
                
                //Added by William Yang 20140806 to assign PO Line Item record type
                poLineItem.RecordTypeId = cnPOLineItemRecordType.id;
                //End
                
                //AM@Introv 20190620 - fix sfdc limitation
                poLineItem.ASI_MFM_From_eMarket__c = true;
                
                poLineItem.ASI_MFM_PO__c = po.Id;
                
                //20180802 Introv added Delivery Fee and POSM Item Group Code
                poLineItem.ASI_MFM_Delivery_Fee__c = PODetail.deliveryFee != Null ? PODetail.deliveryFee : False;
                poLineItem.ASI_MFM_Item_Group_Code__c = PODetail.POSMSKUCode;
                
                //20180815 Introv
                if(mapItemGroupByCode.containsKey(PODetail.POSMSKUCode) && !poLineItem.ASI_MFM_Delivery_Fee__c){
                    poPOSMLine.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
                    poPOSMLine.ASI_MFM_Item_Group__c = mapItemGroupByCode.get(PODetail.POSMSKUCode).id;
                    poPOSMLine.ASI_MFM_Quantity__c = PODetail.Quantity;
                    poPOSMLine.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                    poPOSMLine.ASI_MFM_PO__c = po.Id;
                    poPOSMLine.ASI_MFM_Supplier_Email__c = supplier[0].ASI_LUX_Email_Business__c;
                    LPOSMLine.add(poPOSMLine);
                }
                //20180815 End
                
                //modeify by Eric Tsang 20150108 to change amount round up to 2 decimal places
                poLineItem.ASI_MFM_Amount__c = Decimal.valueof(poDetail.Amount).setScale(2, RoundingMode.HALF_UP);
                System.debug(poDetail.Quantity);                
                if (poDetail.SkuCode != null)
                    poLineItem.ASI_MFM_List_Item_Description__c = PODetail.Description + '\nSku Code : ' + poDetail.SkuCode;
                if (poDetail.Quantity != null)
                    poLineItem.ASI_MFM_Quantity__c = poDetail.Quantity;
                if (poDetail.UnitPrice != null)
                    poLineItem.ASI_MFM_Unit_Price__c = poDetail.UnitPrice;
                System.debug(poDetail.UnitPrice); 
                for(ASI_MFM_Sub_brand__c subBrand : LsubBrand){
                    if(subBrand.ASI_MFM_Sub_brand_Code__c == args.SubBrand )
                        poLineItem.ASI_MFM_Sub_brand_Code__c = subBrand.Id; 
                }
                
                //RecordType cnACRecordType = Global_RecordTypeCache.getRTRec('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code');//[SELECT Id FROM RecordType WHERE Name = 'CN A/C Code'];                         
                
                //ASI_MFM_A_C_Code__c acCode = [SELECT Id FROM ASI_MFM_A_C_Code__c 
                //    WHERE Name = :poDetail.AccountCode AND RecordTypeId = :cnACRecordType.Id];
                for(ASI_MFM_A_C_Code__c acCode : LacCode){
                    if(acCode.Name == poDetail.AccountCode)
                        poLineItem.ASI_MFM_A_C_Code__c = acCode.Id;
                }
                
                LPOLine.add(poLineItem);
                //insert poLineItem; 
            }
            
            if(LPOLine != null && LPOLine.size()>0){
                G_STR_ERROR_LINE = 'before insert PO LINE';
                insert LPOLine;
                G_STR_ERROR_LINE = 'after insert PO LINE';
            }
            
            //20180815 Introv
            if(LPOSMLine != null && LPOSMLine.size()>0){
                G_STR_ERROR_LINE = 'before insert POSM LINE';
                insert LPOSMLine;
                G_STR_ERROR_LINE = 'after insert POSM LINE';
            }
            //20180815 End
            
            G_STR_ERROR_LINE = '(PASS ALL LOGIC)';
        } catch (Exception e) {
                // Process exception here                   
                result.CompletionCode = 'F';
                System.debug(string.valueof(e));
                result.FailMsg = 'System runtime exception error (' + String.valueof(e) + ')';
                System.debug(result.FailMsg);
        }       
        
        return result;
    }
*/
    
}