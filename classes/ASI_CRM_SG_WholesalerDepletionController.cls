/**********************************************************************************
 * Name : ASI_CRM_SG_WholesalerDepletionController
 * Created : DC @03/03/2016 2:18 PM
 * Revision History:
 * 1. 03/03/2016 - [DC 1.0] Created
 * 2. 03/15/2016 - [DC 2.0] Changed logic for allowing user to edit "Opening Stock" value.
 * 3. 18 Apr 2016 - [VL 1.0] Allow editing beginning stock for all records
 * 4. 04/19/2016 - [DC 2.1] Removed debug statements
 * 5. 08 Nov 2016 - [VL 2.0] Removed the calculation of beginning stock
 **********************************************************************************/

public with sharing class ASI_CRM_SG_WholesalerDepletionController {
    
    private final static String JANUARY = 'Jan';
    private final static String FEBRUARY = 'Feb';
    private final static String MARCH = 'Mar';
    private final static String APRIL = 'Apr';
    private final static String MAY = 'May';
    private final static String JUNE = 'Jun';
    private final static String JULY = 'Jul';
    private final static String AUGUST = 'Aug';
    private final static String SEPTEMBER = 'Sep';
    private final static String OCTOBER = 'Oct';
    private final static String NOVEMBER = 'Nov';
    private final static String DECEMBER = 'Dec';

    private Id customerId;
    private Map<String, Integer> mapMonthName_Index;

    public String SEPARATOR {get; set;} {SEPARATOR = '##';}
    public Boolean isEdit {get; set;} {isEdit = false;}
    public String selectedYear {get; set;}
    public String selectedMonth {get; set;}
    public List<SelectOption> lstYearOptions {get; set;}
    public List<SelectOption> lstMonthOptions {get; set;}
    public List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstStockDetails {get; set;}
    public List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstTotalStockDetails {get; set;}
    public List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstFilteredStockDetails {get; set;}
    public List<DetailWrapper> lstStockDetailWrapper {get; set;}
    public map<String,string> mapMonths;
    
    protected Integer totalNumOfRecord;
    
    public Integer numOfRowInTable;
    public Integer limitFrom;
    public String newPageNum { get; set; }
    
    public Integer maxPageNum {
        get {
            return maxNumOfPage();
        }
        private set;
    }

    public Integer currentPageNum { 
        get; 
        protected set {
            currentPageNum = value;
            newPageNum = String.valueOf(value);
        } 
    }

    public ASI_CRM_SG_WholesalerDepletionController(ApexPages.StandardController con) {
        customerId = con.getId(); 

        mapMonths =  new map<String, String>();
        mapMonths.put(JANUARY, DECEMBER);
        mapMonths.put(FEBRUARY, JANUARY);
        mapMonths.put(MARCH ,FEBRUARY);
        mapMonths.put(APRIL,MARCH );
        mapMonths.put(MAY,APRIL);
        mapMonths.put(JUNE ,MAY);
        mapMonths.put(JULY ,JUNE );
        mapMonths.put(AUGUST ,JULY );
        mapMonths.put(SEPTEMBER ,AUGUST );
        mapMonths.put(OCTOBER ,SEPTEMBER );
        mapMonths.put(NOVEMBER ,OCTOBER );
        mapMonths.put(DECEMBER,NOVEMBER );
        
        //this.numOfRowInTable = 100;
        this.totalNumOfRecord = 0;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
      
    }

    public PageReference initData() {

        if(String.isBlank(customerId)) {
            return NULL;
        }

        lstStockDetailWrapper = new List<DetailWrapper>();

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
        isEdit = (String.isBlank(isEditStr)) ? false : Boolean.valueOf(isEditStr);
        String rowNo = params.get('Row');
        this.numOfRowInTable = (String.isBlank(rowNo)) ? 50 : Integer.valueOf(rowNo);
        
        Map<String, Schema.SObjectField> stockDetailFieldMap =
            Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.fields.getMap();
        String theQuery = 'SELECT ';
        for(String fields  : stockDetailFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += 'FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c' 
                 +  ' WHERE ASI_CRM_Customer__c =' 
                 +  ' \'' + customerId + '\'' 
                 +  ' AND RecordType.DeveloperName = \'ASI_CRM_SG_WS_Depletion\''
                 +  ' ORDER BY ASI_TH_CRM_Year__c LIMIT 1';

        lstStockDetails = (List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>) Database.query(thequery);
        if(lstStockDetails.isEmpty()) {
            return null;
        }
        
        generateYearOptions(Integer.valueOf(lstStockDetails[0].ASI_TH_CRM_Year__c));
        generateMonthOptions();

        selectedMonth = lstMonthOptions.get(Date.today().month() - 1).getValue();
        selectedYear = String.valueOf(Date.today().year());
        go();
        return null;
    }

    public void generateYearOptions(Integer pStartYear) {

        lstYearOptions = new List<SelectOption>();
        Integer currentYear = Date.today().year();

        for(Integer counter = pStartYear; counter <= currentYear; counter++) {
            lstYearOptions.add(
                new SelectOption(String.valueOf(counter), String.valueOf(counter))
            );
        }
    }

    public void generateMonthOptions() {

        lstMonthOptions = new List<SelectOption> {
            new SelectOption(JANUARY, JANUARY),
            new SelectOption(FEBRUARY, FEBRUARY),
            new SelectOption(MARCH, MARCH),
            new SelectOption(APRIL, APRIL),
            new SelectOption(MAY, MAY),
            new SelectOption(JUNE, JUNE),
            new SelectOption(JULY, JULY),
            new SelectOption(AUGUST, AUGUST),
            new SelectOption(SEPTEMBER, SEPTEMBER),
            new SelectOption(OCTOBER, OCTOBER),
            new SelectOption(NOVEMBER, NOVEMBER),
            new SelectOption(DECEMBER, DECEMBER)
        };
    }

    // cancelBtn action attribute method.
    public PageReference cancelAndRedirect() {

        if(String.isBlank(customerId)) {
            return null;
        }

        PageReference pageRef = new PageReference('/' + customerId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    // goBtn action attribute method.
    public PageReference go() {

        lstFilteredStockDetails = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        lstStockDetailWrapper = new List<DetailWrapper>();
        
        // to get current month record
        Map<String, Schema.SObjectField> stockDetailFieldMap =
            Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.fields.getMap();
        String theQuery = 'SELECT ';
        for(String fields  : stockDetailFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += 'FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c' 
                 +  ' WHERE ASI_CRM_Customer__c =' 
                 +  ' \'' + customerId + '\'' 
                 +  ' AND RecordType.DeveloperName = \'ASI_CRM_SG_WS_Depletion\'';

        //if(String.isNotBlank(selectedMonth)) {
           
            thequery += ' AND ASI_TH_CRM_Month__c = \'' + selectedMonth+ '\'';
        //}
        //if(String.isNotBlank(selectedYear)) {
            thequery += ' AND ASI_TH_CRM_Year__c = \'' + selectedYear+ '\'';
        //}

        //Wilken 20161111, hide record if ending stock is 0 or no movement in the month (Sell-in, FOC and offtake are blank)
        thequery += ' AND (ASI_TH_CRM_Ending_Stock_Final__c != 0 OR ASI_TH_CRM_Sell_In__c != null OR ASI_TH_CRM_FOC__c != null OR ASI_TH_CRM_Total_Offtake_Final__c != null OR ASI_CRM_Adjusted_Quantity__c != null) ';
        
        thequery += ' ORDER BY ASI_TH_CRM_Year__c, ASI_CRM_SKU__r.ASI_TH_CRM_Brand_Code__c, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU_Code__c ';

        // SOQL can't have offset > 2000, so have to cut
        thequery += (LimitFrom<=2000) ? ' Limit ' + this.numOfRowInTable + ' OFFSET ' + LimitFrom : ' Limit 150 OFFSET 2000';
        Boolean offset2000 = (LimitFrom<=2000) ? false : true;

        lstFilteredStockDetails = (List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>) Database.query(thequery);
        
        String thequeryTotal = 'select count() FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c' 
                 +  ' WHERE ASI_CRM_Customer__c =' 
                 +  ' \'' + customerId + '\'' 
                 +  ' AND RecordType.DeveloperName = \'ASI_CRM_SG_WS_Depletion\''
                 +  ' AND ASI_TH_CRM_Month__c = \'' + selectedMonth+ '\''
                 +  ' AND ASI_TH_CRM_Year__c = \'' + selectedYear+ '\''
                 +  ' AND (ASI_TH_CRM_Ending_Stock_Final__c != 0 OR ASI_TH_CRM_Sell_In__c != null OR ASI_TH_CRM_FOC__c != null OR ASI_TH_CRM_Total_Offtake_Final__c != null OR ASI_CRM_Adjusted_Quantity__c != null) ';
        
        this.totalNumOfRecord = Database.countQuery(thequeryTotal);
        
        /* [VL 2.0] BEGIN */
        /* no need to recalculate beginning stock
        // to get last month record
        theQuery = 'SELECT ';
        for(String fields  : stockDetailFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += 'FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c' 
                 +  ' WHERE ASI_CRM_Customer__c =' 
                 +  ' \'' + customerId + '\'' 
                 +  ' AND RecordType.DeveloperName = \'ASI_CRM_SG_WS_Depletion\'';

        thequery += ' AND ASI_TH_CRM_Month__c = \'' + mapMonths.get(selectedMonth)+ '\'';
        String lastYear = mapMonths.get(selectedMonth) != DECEMBER ? selectedYear : String.valueOf(integer.valueof(selectedYear)-1);
        thequery += ' AND ASI_TH_CRM_Year__c = \'' + lastYear + '\'';
        thequery += ' ORDER BY ASI_TH_CRM_Year__c, ASI_CRM_SKU__r.ASI_TH_CRM_Brand_Code__c, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU_Code__c ';

        lstStockDetails = (List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>) Database.query(thequery);
        
        Boolean isNoRecord = true, isBlankRecord = true;
        String detailId, skuId, mapKey;
        Integer i = 0;
        */
        /* [VL 2.0] END */
        Integer i = 1999;
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c outerIterator : lstFilteredStockDetails ) {
            
            if (offset2000) {
                i++;
                if (i<LimitFrom || i>(LimitFrom+this.numOfRowInTable)) continue;
            }
            
            /* [VL 2.0] BEGIN */
            /* no need to recalculate beginning stock
            detailId = outerIterator.Id;
           
            for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c innerIterator : lstStockDetails ) {

                if( outerIterator.ASI_CRM_SKU__c == innerIterator.ASI_CRM_SKU__c
                 && outerIterator.ASI_TH_CRM_Year__c == innerIterator.ASI_TH_CRM_Year__c 
                 && innerIterator.ASI_TH_CRM_Month__c == mapMonths.get(outerIterator.ASI_TH_CRM_Month__c )) {
                    // No record for this SKU in last month
                    * [VL 1.0] BEGIN *
                     *
                    isNoRecord = false;
                     *
                    * [VL 1.0] END *
                   
                    // Blank record for this SKU in last month
                    if((innerIterator.ASI_TH_CRM_Beginning_Stock__c == NULL || innerIterator.ASI_TH_CRM_Beginning_Stock__c == 0)
                    && (innerIterator.ASI_TH_CRM_Sell_In__c == NULL || innerIterator.ASI_TH_CRM_Sell_In__c == 0)
                    && (innerIterator.ASI_TH_CRM_FOC__c == NULL || innerIterator.ASI_TH_CRM_FOC__c == 0)
                    && (innerIterator.ASI_TH_CRM_Total_Offtake_Final__c == NULL || innerIterator.ASI_TH_CRM_Total_Offtake_Final__c == 0)
                    && (innerIterator.ASI_CRM_Adjusted_Quantity__c == NULL || innerIterator.ASI_CRM_Adjusted_Quantity__c == 0)
                    && (innerIterator.ASI_TH_CRM_Ending_Stock_Final__c == NULL || innerIterator.ASI_TH_CRM_Ending_Stock_Final__c == 0)) {

                    * [VL 1.0] BEGIN *
                     *
                        isBlankRecord = false;
                     *
                    * [VL 1.0] END *
                    }
                    else {

                        outerIterator.ASI_TH_CRM_Beginning_Stock__c = innerIterator.ASI_TH_CRM_Ending_Stock_Final__c ;

                        if(outerIterator.ASI_CRM_Adjusted_Quantity__c == NULL) {
                            outerIterator.ASI_CRM_Adjusted_Quantity__c = 0;
                        }

                        if(outerIterator.ASI_TH_CRM_Sell_In__c == NULL) {
                            outerIterator.ASI_TH_CRM_Sell_In__c = 0;
                        }

                        if(outerIterator.ASI_TH_CRM_FOC__c == NULL) {
                            outerIterator.ASI_TH_CRM_FOC__c = 0;
                        }                        

                        if(outerIterator.ASI_TH_CRM_Total_Offtake_Final__c == NULL) {
                            outerIterator.ASI_TH_CRM_Total_Offtake_Final__c = 0;
                        }
                        
                        outerIterator.ASI_TH_CRM_Ending_Stock_Final__c = ((outerIterator.ASI_TH_CRM_Beginning_Stock__c != null ? outerIterator.ASI_TH_CRM_Beginning_Stock__c : 0)
                                                                       +  (outerIterator.ASI_CRM_Adjusted_Quantity__c != null ? outerIterator.ASI_CRM_Adjusted_Quantity__c : 0)
                                                                       +  (outerIterator.ASI_TH_CRM_Sell_In__c != null ? outerIterator.ASI_TH_CRM_Sell_In__c : 0)
                                                                       +  (outerIterator.ASI_TH_CRM_FOC__c != null ? outerIterator.ASI_TH_CRM_FOC__c : 0)
                                                                       -  (outerIterator.ASI_TH_CRM_Total_Offtake_Final__c != null ? outerIterator.ASI_TH_CRM_Total_Offtake_Final__c : 0));
                    }
                }
            }
            
            if(isNoRecord == true
            || (isNoRecord == false && isBlankRecord == false)) {
                lstStockDetailWrapper.add(new DetailWrapper(outerIterator, true));
            } else {
                lstStockDetailWrapper.add(new DetailWrapper(outerIterator, false));
            }
            */
            /* [VL 2.0] END */
            lstStockDetailWrapper.add(new DetailWrapper(outerIterator, true));
        }

        return NULL;
    }

    // saveBtn and quickSaveBtn action attribute method.
    public PageReference saveOfftakeDetails() {
       
        PageReference pageRef = null;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        Boolean isQuickSave = (isQuickSaveStr == null) ? false : Boolean.valueOf(isQuickSaveStr);

        Boolean isError = false;

        for(DetailWrapper detailIterator : lstStockDetailWrapper) {

            if( detailIterator.detailRecord.ASI_CRM_Adjusted_Quantity__c != NULL
            &&  detailIterator.detailRecord.ASI_CRM_Adjusted_Quantity__c != 0
            &&  String.isBlank(detailIterator.detailRecord.ASI_CRM_Adjusted_Reason__c)) {
                detailIterator.detailRecord.ASI_CRM_Adjusted_Reason__c.addError('Please input Reason if you try to Adjust Quantity.');
                isError = true;
            }
        }

        if(isError == true) {
            return NULL;
        }

        System.Savepoint pSavepoint = Database.setSavepoint();

        try {

            List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstDetailsToUpdate =
                new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
            for(DetailWrapper detailIterator : lstStockDetailWrapper) {
                lstDetailsToUpdate.add(detailIterator.detailRecord);
            }

            update lstDetailsToUpdate;


        } catch(DmlException exceptionInstance) {

            if(pSavepoint != NULL) {
                Database.rollback(pSavepoint);
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exceptionInstance.getMessage()));
            return NULL;
        }

        if (!isQuickSave) {

            pageRef = new PageReference('/' + customerId);
            pageRef.setRedirect(true);
            // go();
        }
        else {
            
            pageRef = new PageReference('/apex/ASI_CRM_SG_WholesalerDepletion?id=' + customerId +'&IS_EDIT=true');
            pageRef.setRedirect(false);
            go();
        }
        return pageRef;
    }

    /* [DC 2.0] START */
    // Wrapper for displaying records on page and controlling enable / disable of "Opening Stock"
    public class DetailWrapper {

        public ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c detailRecord {get; set;}
        public Boolean isOpeningStockEnabled {get; set;}

        public DetailWrapper(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c pDetailRecord, Boolean pIsEnabled) {
            detailRecord = pDetailRecord;
            isOpeningStockEnabled = pIsEnabled;
        }

    }
    /* [DC 2.0] END */
    
     // change page function
    public void firstPage() {
        this.currentPageNum=1;
        implChangePage(1);
        this.LimitFrom = 0;
        go();
    }
    
    public void lastPage() {
        this.currentPageNum=this.maxNumOfPage();
        implChangePage(this.maxNumOfPage());
        this.LimitFrom = this.maxPageNum*this.numOfRowInTable-this.numOfRowInTable;
        go();
    }
    
    public void prevPage() {
        if(this.currentPageNum>0){
            this.currentPageNum = this.currentPageNum -1;
            implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom-this.numOfRowInTable;
            go();
        }
    }
    
    public void nextPage() {
        if(this.currentPageNum<this.maxPageNum){
            this.currentPageNum=this.currentPageNum + 1;
            implChangePage(this.currentPageNum);
        //this.numOfRowInTable=this.numOfRowInTable+2;
            this.LimitFrom=this.LimitFrom+this.numOfRowInTable;
            go();
        //implChangePage(this.currentPageNum + 1); 
        }
        
    }
    
    public void implChangePage(Integer pageNum) {
        Integer maxPNum = this.maxNumOfPage();
        if (pageNum <= 0) this.currentPageNum = 1;
        else if (pageNum > maxPNum) this.currentPageNum = maxPNum;
    }
    
    private Integer maxNumOfPage() {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            return 1;
        return ((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1;
    }
}