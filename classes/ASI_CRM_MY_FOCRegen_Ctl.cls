/*********************************************************************************
 * Name: ASI_CRM_MY_FOCRegen_Ctl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-10-19       Daniel                  Initial
 *********************************************************************************/
 
public with sharing class ASI_CRM_MY_FOCRegen_Ctl{

    public ASI_CRM_ActualOfftakeHeader__c AOH1 {get; set;} {AOH1 = new ASI_CRM_ActualOfftakeHeader__c();}
    public ASI_CRM_ActualOfftakeHeader__c AOH2 {get; set;} {AOH2 = new ASI_CRM_ActualOfftakeHeader__c();}
    public ASI_CRM_ActualOfftakeHeader__c AOH3 {get; set;} {AOH3 = new ASI_CRM_ActualOfftakeHeader__c();}
    public ASI_CRM_ActualOfftakeHeader__c AOH4 {get; set;} {AOH4 = new ASI_CRM_ActualOfftakeHeader__c();}
    public ASI_CRM_ActualOfftakeHeader__c AOH5 {get; set;} {AOH5 = new ASI_CRM_ActualOfftakeHeader__c();}
    public SelectOption[] yearOptions { public get; private set; }
    public SelectOption[] monthOptions { public get; private set; }
    public String strYear { public get; public set; }
    public String strMonth { public get; public set; }
    public set<id> setCustomer = new set<id>();
    public boolean changeSubmit {get; set;} { changeSubmit = TRUE;}
    
    private ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
    public Date today{get; private set;}{today =my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();}
    public Integer intCutOffDay {get; private set;}{intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : 26;}
    
    public list<ASI_CRM_ActualOfftakeHeader__c> lstResults {get; set;} { lstResults = new list<ASI_CRM_ActualOfftakeHeader__c >(); }
    public list<ASI_TH_CRM_Actual_Offtake__c> lstOfftake {get; set;} { lstOfftake = new list<ASI_TH_CRM_Actual_Offtake__c>(); }
    
    public ASI_CRM_MY_FOCRegen_Ctl() {
        this.yearOptions = new SelectOption[]{};
        this.monthOptions = new SelectOption[]{};
        //date dteToday = date.today();
       	date dteToday = today;
        for (integer i = dteToday.addYears(-1).year(); i < dteToday.addYears(2).year(); i++) {
            this.yearOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        for (integer i = 1; i <= 12; i++) {
            this.monthOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        /*
        List<AsyncApexJob> apexJobs = 
            [SELECT 
             	TotalJobItems, 
             	Status, 
             	NumberOfErrors, 
             	ExtendedStatus, 
             	JobItemsProcessed, 
             	Id, 
             	JobType,
             	ApexClassId, 
             	CreatedDate 
             FROM AsyncApexJob 
             WHERE ApexClassId =: batchClassId 
             Order by CreatedDate DESC];
        */
        
        checkBatch();
        
    }
    
    public boolean checkBatch(){
        //Date cutDate = today.addDays(-2);
        Datetime cutDatetime = system.now();
        cutDatetime = cutDatetime.addHours(-24);
        system.debug('@@@cutDatetime@@@: '+cutDatetime);
            
        List<AsyncApexJob> apexJobs = 
            [SELECT 
             	TotalJobItems, 
             	Status, 
             	NumberOfErrors, 
             	ExtendedStatus, 
             	JobItemsProcessed, 
             	Id, 
             	JobType,
             	ApexClassId, 
             	CreatedDate
             FROM AsyncApexJob 
             WHERE CreatedDate >= :cutDatetime
             AND Status != 'Completed'
             AND (ApexClass.Name='ASI_CRM_MY_ReGenCalculatedFOC_Batch'
             OR ApexClass.Name='ASI_CRM_MY_ReGenCalculatedPayment_Batch')
             Order by CreatedDate DESC];
        
        boolean isBatch;
        if(apexJobs.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch is running.'));  
            isBatch = true;
        } 
        else{
            isBatch = false;
        }
        
        system.debug('@@@apexJobs@@@: '+apexJobs);
        
        return isBatch;
    }
    
    public void doSearch(){
        changeSubmit = TRUE;
        setCustomer.clear();
        
        if(AOH1.ASI_CRM_ToOutlet__c != null){
            setCustomer.add(AOH1.ASI_CRM_ToOutlet__c);
        }
        
        if(AOH2.ASI_CRM_ToOutlet__c != null){
            setCustomer.add(AOH2.ASI_CRM_ToOutlet__c);
        }
        
        if(AOH3.ASI_CRM_ToOutlet__c != null){
            setCustomer.add(AOH3.ASI_CRM_ToOutlet__c);
        }
        
        if(AOH4.ASI_CRM_ToOutlet__c != null){
            setCustomer.add(AOH4.ASI_CRM_ToOutlet__c);
        }
        
        if(AOH5.ASI_CRM_ToOutlet__c != null){
            setCustomer.add(AOH5.ASI_CRM_ToOutlet__c);
        }
         
        Boolean includeAdditionalOutlet =false;
        for(ASI_CRM_AccountsAdditionalField__c parent : 
            [
                SELECT Id, ASI_CRM_CN_Parent_Outlet__c
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE id in :setCustomer 
                AND ASI_CRM_CN_Parent_Outlet__c != null
            ]){ 
                includeAdditionalOutlet = true;
                setCustomer.add(parent.ASI_CRM_CN_Parent_Outlet__c);
        }
        
        for(ASI_CRM_AccountsAdditionalField__c child : 
            [
                SELECT Id
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Parent_Outlet__c in :setCustomer 
            ]){ 
                includeAdditionalOutlet = true;
                setCustomer.add(child.Id);
        }
        
        
         if(includeAdditionalOutlet){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parent or child outlet\'s offtake is included for regen.'));  
         }
        /*
        if(Test.isrunningTest()){
            strYear = '2015';
            strMonth = '1';
        }
        */
        //integer intRunningDay = 31;
        //integer intCutOffDay = 26;
        //date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        /*
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        dteStart = date.newInstance(dteStart.addMonths(-1).Year(), dteStart.addMonths(-1).Month(), intCutOffDay);
        date dteEnd = today;
        date dteRunDate = today;
        */
       
        
        
        
        
        /*
        List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        if(lstMYSetting != null && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
		*/
    
        
        /*
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
		*/
        
        date dteRunDate = today;
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        dteStart = date.newInstance(dteStart.addMonths(-1).Year(), dteStart.addMonths(-1).Month(), intCutOffDay);
        date dteEnd;
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        
        system.debug('doSearch: Date Start: ' + String.valueOf(dteStart) + ', Date End: ' + String.valueOf(dteEnd));
        
        lstResults = [
            SELECT 
            	Id, 
            	Name, 
            	ASI_CRM_ToOutlet__c, 
            	ASI_CRM_OfftakeDate__c, 
            	ASI_CRM_Status__c, 
            	ASI_CRM_Calculated_Payment_Status__c,
            	ASI_CRM_Invoice_Month__c,
            	ASI_CRM_MY_Unlock_Trail__c
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE ASI_CRM_ToOutlet__c IN :setCustomer
            AND ASI_CRM_OfftakeDate__c >= :dteStart 
            AND ASI_CRM_OfftakeDate__c <= :dteEnd
            ORDER BY ASI_CRM_OfftakeDate__c ASC
        ];
        
        
        boolean isBatch = checkBatch();
        changeSubmit = isBatch ? true : false;
        
        if(lstResults != null && lstResults.size() > 0){
           // changeSubmit = FALSE;
        }
        
    } 
    
    public void doChange(){
        
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        date dteEnd = today;
        date dteRunDate = today;
        
        String startYear = String.valueOf(dteStart.year());
        String startMonth = String.valueOf(dteStart.month());
        startMonth = startMonth.length() == 1 ? '0' + startMonth : startMonth;
        String start_year_month = startYear+''+startMonth;
        Decimal start_year_month_num = Decimal.valueOf(start_year_month);
        
        
        String endYear = String.valueOf(dteEnd.year());
        String endMonth = String.valueOf(dteEnd.month());
        endMonth = endMonth.length() == 1 ? '0' + endMonth : endMonth;
        String end_year_month = endYear+''+endMonth;
        Decimal end_year_month_num = Decimal.valueOf(end_year_month);	
        
        list<ASI_CRM_Calculated_FOC__c> lstToCheckUsedForFoc = new list<ASI_CRM_Calculated_FOC__c>();
        lstToCheckUsedForFoc = 
            [SELECT id 
             FROM ASI_CRM_Calculated_FOC__c 
             WHERE ASI_CRM_Date_Number__c >= :start_year_month_num
             AND ASI_CRM_Date_Number__c <= :end_year_month_num
             AND ASI_CRM_Customer__c IN :setCustomer 
             AND ASI_CRM_Used_For_FOC__c = true
             LIMIT 1000];
       	system.debug('@@@lstToCheckUsedForFoc@@@: '+lstToCheckUsedForFoc);
        if(lstToCheckUsedForFoc.size() > 0){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please delete Free Goods Request Firstly!'));
        }
        else{
            list<ASI_CRM_ActualOfftakeHeader__c> lstUpdateList = new list<ASI_CRM_ActualOfftakeHeader__c>();
            for(ASI_CRM_ActualOfftakeHeader__c itm : lstResults){
                //if (itm.ASI_CRM_Status__c == 'Draft') {
                  //  continue;
                //}
                itm.ASI_CRM_MY_Unlock_Trail__c = (itm.ASI_CRM_MY_Unlock_Trail__c != null ? itm.ASI_CRM_MY_Unlock_Trail__c : '') + '\r\n' + system.now().addHours(8) + ' ' + UserInfo.getName() + ' ';
                itm.ASI_CRM_Status__c = 'Draft';
                itm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
                lstUpdateList.add(itm);
            }
            update lstUpdateList;
            doSearch();
        }
    }
    
   	public void doUnlockCalculatePayment(){
        
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        date dteEnd = today;
        date dteRunDate = today;
        
        String startYear = String.valueOf(dteStart.year());
        String startMonth = String.valueOf(dteStart.month());
        startMonth = startMonth.length() == 1 ? '0' + startMonth : startMonth;
        String start_year_month = startYear+''+startMonth;
        Decimal start_year_month_num = Decimal.valueOf(start_year_month);
        
        
        String endYear = String.valueOf(dteEnd.year());
        String endMonth = String.valueOf(dteEnd.month());
        endMonth = endMonth.length() == 1 ? '0' + endMonth : endMonth;
        String end_year_month = endYear+''+endMonth;
        Decimal end_year_month_num = Decimal.valueOf(end_year_month);	
        
        list<ASI_CRM_Calculated_Payment__c > lstToCheckUsedForPayment = new list<ASI_CRM_Calculated_Payment__c >();
        lstToCheckUsedForPayment = 
            [SELECT id 
             FROM ASI_CRM_Calculated_Payment__c  
             WHERE ASI_CRM_Date_Number__c >= :start_year_month_num
             AND ASI_CRM_Date_Number__c <= :end_year_month_num
             AND ASI_CRM_Customer__c IN :setCustomer 
             AND ASI_CRM_Used_for_Payment__c = true
             LIMIT 1000];
       	system.debug('@@@lstToCheckUsedForPayment@@@: '+lstToCheckUsedForPayment);
       
        if(lstToCheckUsedForPayment.size() > 0){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please delete Calculated Payment Firstly!'));
        }
        else{
            list<ASI_CRM_ActualOfftakeHeader__c> lstUpdateList = new list<ASI_CRM_ActualOfftakeHeader__c>();
            for(ASI_CRM_ActualOfftakeHeader__c itm : lstResults){
                //if (itm.ASI_CRM_Calculated_Payment_Status__c  == 'Draft') {
                  //  continue;
                //}
                itm.ASI_CRM_MY_Unlock_Trail__c = (itm.ASI_CRM_MY_Unlock_Trail__c != null ? itm.ASI_CRM_MY_Unlock_Trail__c : '') + '\r\n' + system.now().addHours(8) + ' ' + UserInfo.getName() + ' ';
                itm.ASI_CRM_Calculated_Payment_Status__c  = 'Draft';
                itm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
                lstUpdateList.add(itm);
            }
            update lstUpdateList;
            doSearch();
        }
    }
    
    public void doRegenFOC() {
        doSearch();
        
        // Declaration
        set<id> setOutlet = new set<id>();
        integer intRunningDay = 31;
        //ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        Map<id, date> mapMinDate = new Map<id, date>();
        Map<date, set<id>> mapRegen = new Map<date, set<id>>();
        // Declaration

        // integer intCutOffDay = 26;
        
        
        /*
        List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        if(lstMYSetting != null && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
		*/
        
        
        /*
        lstOfftake = [
            SELECT 
            	Id, 
            	ASI_CRM_ActualOfftakeHeader__r.Name, 
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, 
	            ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c, 
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c,
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c,
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Invoice_Month__c, 
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_MY_Unlock_Trail__c,
	            ASI_CRM_InvoiceDate__c 
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setCustomer
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteRunDate 
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd
            ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c ASC
        ];
        
        for (ASI_TH_CRM_Actual_Offtake__c itm : lstOfftake){
            if (itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c != 'Draft') {
                continue;
            }
            if (mapMinDate.get(itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c) != null) {
                if (mapMinDate.get(itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c) > itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c) {
                    mapMinDate.put(itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c);
                }
            } else {
                mapMinDate.put(itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c);
            }
            setOutlet.add(itm.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c);
        }
        
        for (Id idCustomer : setOutlet) {
            if (mapMinDate.get(idCustomer) == null) {
                mapMinDate.put(idCustomer, dteRunDate);
                setOutlet.add(idCustomer);
            }
        }
		*/

		/*        
        date dteEnd = today;
        date dteRunDate = date.newInstance(today.year(), today.month(), 1);
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        else{
            dteEnd = date.newinstance(dteRunDate.addMonths(0).Year(), dteRunDate.addMonths(0).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
		dteRunDate = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);

        */
        
        date dteRunDate = today;
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        dteStart = date.newInstance(dteStart.addMonths(-1).Year(), dteStart.addMonths(-1).Month(), intCutOffDay);
        date dteEnd;
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        system.debug('doRegenFOC.lstOfftake From: ' + String.valueOf(dteStart) + ', End: ' + String.valueOf(dteEnd));
        
        
        AggregateResult[] results = [
            SELECT 
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c customerId, 
            	MIN(ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c) minDate
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setCustomer
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = 'Draft'
            GROUP BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c
        ];
        
        
        system.debug('@@@results@@@: '+results);
        
        for(AggregateResult result : results){
            Id customerId = (Id)result.get('customerId');
            Date minDate = (Date)result.get('minDate');
            mapMinDate.put(customerId, minDate);
            setOutlet.add(customerId);
        }
        
        for (Id idCustomer : setOutlet) {
            if (mapMinDate.get(idCustomer) == null) {
                mapMinDate.put(idCustomer, dteStart);
                setOutlet.add(idCustomer);
            }
        }
        
        /*
        for (Id idCustomer : setOutlet) {
            for (Date dteR = mapMinDate.get(idCustomer); (dteR.year() <= dteEnd.year() && dteR.month() < dteEnd.month()) || (dteR.year() < dteEnd.year()); dteR = dteR) {
                
            }
        }
		*/

        //for (Id idCustomer : setOutlet) {
            //Date dteR = mapMinDate.get(idCustomer);
            //Date dteR = dteRunDate;
            //Date dteD = date.newinstance(dteR.Year(), dteR.Month(), 1);
            //date startDate;
            //date endDate;
            integer intBatchLimit = 1800;
            boolean blnTodayCutoff = false;
            integer intOfftakeCount = 0;
            integer intBatch = 1;
            boolean haveData = false;
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
                endDate = date.newinstance(dteEnd.addMonths(1).Year(), dteEnd.addMonths(1).Month(), intCutOffDay);
                endDate = endDate.addDays(-1);
            }
            else{
            
                startDate = date.newinstance(dteD.addMonths(-1).Year(), dteD.addMonths(-1).Month(), intCutOffDay);
                endDate = date.newinstance(dteEnd.Year(), dteEnd.Month(), intCutOffDay);
                endDate = endDate.addDays(-1);
            }
        	*/
        	
        	//startDate = date.newinstance(dteD.addMonths(-1).Year(), dteD.addMonths(-1).Month(), intCutOffDay);
            //endDate = date.newinstance(dteEnd.Year(), dteEnd.Month(), intCutOffDay);
            //endDate = endDate.addDays(-1);
        	
            //if (dteD.addDays(1).Day() == intCutoffDay) {
            //    blnTodayCutoff = true;
            //}
            
            //system.debug('@@@startDate@@@: '+startDate);
            //system.debug('@@@endDate@@@: '+endDate);
            lstAO = [
                SELECT 
                	ASI_CRM_ActualOfftakeHeader__r.id,
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, 
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c,
                    ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd 
                AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = 'Draft'
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c = :setOutlet
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c, ASI_CRM_ActualOfftakeHeader__r.id
            ];
            
            system.debug('@@@lstAO@@@ '+lstAO);
            map<Date, List<ASI_TH_CRM_Actual_Offtake__c>> map_date_offtake = new map<Date, List<ASI_TH_CRM_Actual_Offtake__c>>();
            for(ASI_TH_CRM_Actual_Offtake__c i : lstAO) {
                Date offtake_date = i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c;
                Date min_date;
                if(offtake_date.Day() >= intCutOffDay) {
                    min_date = date.newinstance(offtake_date.Year(), offtake_date.Month(), intCutOffDay);
                    //if (dteD.Day() == intCutOffDay) {
                        //min_date.addDays(-1);
                    //}
                }
                else{
                    min_date = date.newinstance(offtake_date.addMonths(-1).Year(), offtake_date.addMonths(-1).Month(), intCutOffDay);
                }
                
                List<ASI_TH_CRM_Actual_Offtake__c> list_offtake = map_date_offtake.containsKey(min_date) ? map_date_offtake.get(min_date) : new List<ASI_TH_CRM_Actual_Offtake__c>();
                list_offtake.add(i);
                map_date_offtake.put(min_date, list_offtake);
                
                intOfftakeCount++;
                setOTHeader.add(i.ASI_CRM_ActualOfftakeHeader__r.id);
                if (intOfftakeCount < intBatchLimit) {
                    mapIDBatch.put(i.ASI_CRM_ActualOfftakeHeader__r.id, intBatch);
                } 
                else {
                    intOfftakeCount = 0;
                    intBatch++;
                    mapIDBatch.put(i.ASI_CRM_ActualOfftakeHeader__r.id, intBatch);
                }
               
            }
            
            system.debug('@@@map_date_offtake@@@: '+map_date_offtake);
          
            
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
            
            haveData = map_date_offtake.containsKey(dteStart) ? true : false;
            /*
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                i.ASI_CRM_Status__c = 'Draft-Processing' + String.valueOf(mapIDBatch.get(i.id));
            }
            */
            
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                //if (!blnTodayCutoff) {
                i.ASI_CRM_Status__c = 'Draft-Processing';
                //}
            }
            update lstAOHeader;
            
            //set<id> customer_set = new set<id>();
            //customer_set.add(idCustomer);
            /*
            for (integer i = 1; i <= intBatch; i++) {
                Database.executeBatch(new ASI_CRM_MY_CalculatedFOC_Batch(dteD, i, haveData, setOutlet), 10000);
            }
            */
            
            Database.executeBatch(new ASI_CRM_MY_ReGenCalculatedFOC_Batch(dteStart, haveData, setOutlet, map_date_offtake, true), 10000);
            
            //clsFOC.regenFOCData(dteD, new set<id>{idCustomer});
            //dteR = dteR.addMonths(1);
        //}
        
        doSearch();
        
    }
    
    public void doRegenCalculatedPayment(){
        doSearch();
        
        // Declaration
        set<id> setOutlet = new set<id>();
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        Map<id, date> mapMinDate = new Map<id, date>();
        Map<date, set<id>> mapRegen = new Map<date, set<id>>();
        // Declaration

		/*        
        date dteEnd = today;
        date dteRunDate = date.newInstance(today.year(), today.month(), 1);
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteEnd = date.newinstance(dteRunDate.addMonths(0).Year(), dteRunDate.addMonths(0).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
		dteRunDate = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        system.debug('doRegenFOC.lstOfftake From: ' + String.valueOf(dteRunDate) + ', End: ' + String.valueOf(dteEnd));
        */
        
        date dteRunDate = today;
        date dteStart = date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
        dteStart = date.newInstance(dteStart.addMonths(-1).Year(), dteStart.addMonths(-1).Month(), intCutOffDay);
        date dteEnd;
        if(dteRunDate.Day() >= intCutOffDay) {
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        system.debug('doRegenFOC.lstOfftake From: ' + String.valueOf(dteStart) + ', End: ' + String.valueOf(dteEnd));
        
        AggregateResult[] results = [
            SELECT 
            	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c customerId, 
            	MIN(ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c) minDate
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setCustomer
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c = 'Draft'
            GROUP BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c
        ];
        
        
        system.debug('@@@results@@@: '+results);
        
        for(AggregateResult result : results){
            Id customerId = (Id)result.get('customerId');
            Date minDate = (Date)result.get('minDate');
            mapMinDate.put(customerId, minDate);
            setOutlet.add(customerId);
        }
        
        for (Id idCustomer : setOutlet) {
            if (mapMinDate.get(idCustomer) == null) {
                mapMinDate.put(idCustomer, dteRunDate);
                setOutlet.add(idCustomer);
            }
        }
       
        //for (Id idCustomer : setOutlet) {
            //Date dteR = mapMinDate.get(idCustomer);
            //Date dteR = dteRunDate;
            //Date dteD = date.newinstance(dteR.Year(), dteR.Month(), 1);
            //date startDate;
            //date endDate;
            boolean blnTodayCutoff = false;
            boolean haveData = false;
            List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
            List<ASI_TH_CRM_Actual_Offtake__c> lstAO = new List<ASI_TH_CRM_Actual_Offtake__c>();
            set<id> setOTHeader = new set<id>();
            map<id, integer> mapIDBatch = new map<id, integer>();
            id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
            
            //startDate = date.newinstance(dteD.addMonths(-1).Year(), dteD.addMonths(-1).Month(), intCutOffDay);
            //endDate = date.newinstance(dteEnd.Year(), dteEnd.Month(), intCutOffDay);
            //endDate = endDate.addDays(-1);
        	
            //if (dteD.addDays(1).Day() == intCutoffDay) {
            //    blnTodayCutoff = true;
            //}
            
            //system.debug('@@@startDate@@@: '+startDate);
            //system.debug('@@@endDate@@@: '+endDate);
            
            lstAO = [
                SELECT 
                	ASI_CRM_ActualOfftakeHeader__r.id, 
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, 
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                	ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c,
                    ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd 
                AND ASI_CRM_ActualOfftakeHeader__r.RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c = 'Draft'
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c = :setOutlet
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c, ASI_CRM_ActualOfftakeHeader__r.id
            ];
            
         

            
            system.debug('@@@lstAO@@@ '+lstAO);
            
            map<Date, List<ASI_TH_CRM_Actual_Offtake__c>> map_date_offtake = new map<Date, List<ASI_TH_CRM_Actual_Offtake__c>>();
            for(ASI_TH_CRM_Actual_Offtake__c i : lstAO) {
                Date offtake_date = i.ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c;
                Date min_date;
                if(offtake_date.Day() >= intCutOffDay) {
                    min_date = date.newinstance(offtake_date.Year(), offtake_date.Month(), intCutOffDay);
                    //if (dteD.Day() == intCutOffDay) {
                    //    min_date.addDays(-1);
                    //}
                }
                else{
                    min_date = date.newinstance(offtake_date.addMonths(-1).Year(), offtake_date.addMonths(-1).Month(), intCutOffDay);
                }
                
                List<ASI_TH_CRM_Actual_Offtake__c> list_offtake = map_date_offtake.containsKey(min_date) ? map_date_offtake.get(min_date) : new List<ASI_TH_CRM_Actual_Offtake__c>();
                list_offtake.add(i);
                map_date_offtake.put(min_date, list_offtake);
                setOTHeader.add(i.ASI_CRM_ActualOfftakeHeader__r.id);

            }
            
            lstAOHeader = [
                SELECT 
                    id, 
                    ASI_CRM_ToOutlet__c, 
                    ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                    ASI_CRM_Calculated_Payment_Status__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE id IN :setOTHeader 
                AND ASI_CRM_Calculated_Payment_Status__c = 'Draft'
            ];
            system.debug('@@@lstAOHeader@@@ '+lstAOHeader);
            
            haveData = map_date_offtake.containsKey(dteStart) ? true : false;
  
            
            for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
                i.ASI_CRM_Calculated_Payment_Status__c = 'Draft-Processing';
            }
            update lstAOHeader;
        
            
            Database.executeBatch(new ASI_CRM_MY_ReGenCalculatedPayment_Batch(dteStart, haveData, setOutlet, map_date_offtake, true), 10000);
            
        //}  
        
        doSearch();
        
    }
    
    
    
}