/***************************************************************************************************
 * Name : ASI_CRM_SG_YtdAchievementNotif_Batch
 * Created : DC @03/16/2016 12:46 PM
 * Test Class: ASI_CRM_SG_AdjustOfftakesControllerTest, ASI_CRM_SG_YtdAchievementNotif_BatchTest
 * Revision History:
 * 1. 03/16/2016 - [DC 1.0] Created
 * 2. 03/18/2016 - [VL 1.0] Contract End Date checking should from past 90 days - any day in the future
 * 3. 03/18/2016 - [DC 1.1] Added wrapper for holding email data
 * 4. 03/18/2016 - [DC 1.2] Changed email body generation logic and moved it to execute() method
 * 5. 04/06/2016 - [DC 2.0] Added logic for updating "Gross Sales" value on the contract records
 * 6. 08 Apr 2016 - [VL 2.1] Cater duty / fob / handling cost
 * 7. 11 Apr 2016 - [VL 2.2] check compensation to wholesaler
 * 8. 14 Apr 2016 - [VL 3.0] Fix bug about duplicate email content, may be due to the batch
 * 9. 18 Apr 2016 - [VL 4.0] Only send email to contract with actual volume achieved >= 90%
 * 10. 10 Jun 2016 - [HC 1.0] Update the payment schedule sort order
 * 11 18 Jul 2016 - [HC 2.0] Update the URL port number
 * 12. 07 Apr 2017 - [VL 5.0] P3 enhancement: calculate contract margin from credit note, so remove the calculation here
 * 13. 28 Apr 2017 - [VL 6.0] P3 enhancement: for contract comparison report, calculate blind bonus and prompt payment
 * 14. 26 Jun 2017 - [VL 7.0] P3 enhancement: calculate Sales Revenue in original contract period, for time bound bonus
 * 15. 7 Jul 2017 -  [WL 1.0] Add Re-calculate Actual ROI checkbox to allow ad-hoc re-cal for completed or expired contracts
 * 16. 13 Nov 2017 -  [VL 8.0] Phase 4.1: calculate contract target bottle achievement
 * 17. 06 Dec 2017 - [VL 9.0] Phase 4.1: Split Wholesaler Margin from price overwrite
 * 18. 19 Dec 2017 - [VL 10.0] Phase 4.1: try to fix Apex: CPU Time Limit Exceeded in Production - by only retrieve price/cost >= 2010-01-01
 *               [VL 10.1] Phase 4.1: get RTM price for RTM contract
 * 19. 21 Jan 2018 - [VL 11.0] Phase 4.1B: save CPU time
 *           [VL 11.1] Phase 4.1B logic, pass contract ID to recalculate ROI%
 *           [VL 11.2] Phase 4.1B logic, enable back rebate for regular size
 * 20. 27 Mar 2018 - [VL 12.0] Fix: payment schedule can input decimal as achieved %
 * 21. 21 Aug 2018 - [WL 13.0] Set OrgWideEmail as From Address after contract is approved
 **************************************************************************************************/

global class ASI_CRM_SG_YtdAchievementNotif_Batch implements
    Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private static final String SUBJECT_PREFIX = 'YTD Achievement - ';
    private static final String SUBJECT_DATE_FORMAT = 'MMM YYYY';
    private static final String HI = 'Hi ';
    private static final String COMMA = ',';
    private static final String BLANK_SPACE = ' ';
    private static final String GREETING = 'Here is the YTD Achievement of your contract(s).';
    private static final String YTD_SALES_VOLUME = 'YTD Sales Volume (9L): ';
    private static final String YTD_PERCENT_ACHIEVED = 'YTD % Achieved: ';
    private static final String REPORT_LINK = 'Report Link: ';
    private static final String REPORT_LINK_VALUE = 'http://www.google.com'; // Actual variable to hold link to report
    private static final String PAYMENT_SCHEDULES_TO_ISSUE = 'Payment Schedule(s) ready to be issued:';
    private static final String PERCENT = ' %';
    private static final String BODY_DATE_FORMAT = 'd MMM YYYY';
    private static final String S_DOLLAR_SIGN = ' : S$ ';
    private static final String PERIOD = '. ';
    private static final String NA = 'N/A';
    private static final String THANKS = 'Thanks';
    private static final String LINE_BREAK = '<br />';
    private static final String ANCHOR_START = '<a href="';
    private static final String ANCHOR_END = '"> ';
    private static final String ANCHOR_CLOSING_TAG = '</a>';
    /* [HC 2.0] BEGIN */
    private static final String YTD_REPORT_LINK_START = 'https://obiee.pernod-ricard-asia.com:{0}/analytics/saw.dll?GO&Action=Extract&Path=/shared/PRSG/Report/Till%20Date%20Performance%20Summary%20Report&P0=1&P1=eq&P2=%22ASI_TH_CRM_CONTRACT%22.%22ROWID%22&P3=%22';
    /* [HC 2.0] END */
    private static final String YTD_REPORT_LINK_END = '%22';
    private static final String YTD_REPORT_LINK_CLICK_HERE = 'Click Here';
    private static final String OUTLET = 'Outlet: ';
    private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

    private static final String PRICE_RECTYPE_DEVNAME =
        'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler';
    
    private static final Set<String> SET_PRICE_RECTYPE_DEVNAME = new Set<String>{
        'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
    /* [VL 10.1] BEGIN */
    , 'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'
    /* [VL 10.1] END */
    };

    private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';
    private static final String PAYMENTSCHEDULE_RECORD_TYPE = 'ASI_CRM_SG_Payment_Schedule';

    private String emailSubject = SUBJECT_PREFIX + DateTime.now().format(SUBJECT_DATE_FORMAT).toUpperCase();
    private Map<Id, Decimal> mapContractId_Sum9L = new Map<Id, Decimal>();
        /* [VL 6.0] BEGIN */
    private Map<Id, Decimal> mapContractId_blindBonus = new Map<Id, Decimal>();
    private Map<Id, Decimal> mapContractId_promptPayment = new Map<Id, Decimal>();
        /* [VL 6.0] END */
    private List<ASI_TH_CRM_Contract__c> lstPlaceHolders;
    private Map<string, decimal> map_ContractIdSKU_sumCompensation = new Map<string, decimal>();
    private Map<string, decimal> map_ContractId_sumCompensation = new Map<string, decimal>();
    /* [VL 9.0] BEGIN */
    private Map<string, decimal> map_ContractIdSKU_sumWSMargin = new Map<string, decimal>();
    private Map<string, decimal> map_ContractId_sumWSMargin = new Map<string, decimal>();
    /* [VL 9.0] END */
        
    
    private Map<Id, Set<ASI_TH_CRM_Contract__c>> mapOwnerId_OwnedContracts =
        new Map<Id, Set<ASI_TH_CRM_Contract__c>>();

    private Map<Id, EmailWrapper> mapOwnerId_EmailMessage = new Map<Id, EmailWrapper>();

    /* [VL 3.0] BEGIN */
    // add the set of contract ID to prevent the content of this contract is repeated in the email 
    private Set<Id> isInEmail = new Set<Id>();
    /* [VL 3.0] END */
  
  /* [VL 8.0] BEGIN */
  private Map<Id, Id> skuMappingMap;
  /* [VL 8.0] END */

  /* [VL 11.1] BEGIN */
  /*
    private String query = '  SELECT Id'
                         + '       , ASI_TH_CRM_Contract_Status__c'
                         + '       , ASI_TH_CRM_End_Date__c'
                         + '       , ASI_TH_CRM_Start_Date__c'
             /* [VL 8.0] BEGIN *
             + '       , ASI_CRM_Contract_Exist_Before_RTM__c'
             /* [VL 8.0] END *
                         + '    FROM ASI_TH_CRM_Contract__c'
                         // use this line to limit the functionality to test record provided.
                         //+ '   WHERE Id = \'a8cM00000000IuB\''
                         //+ '      OR Id = \'a8cM00000000IowIAE\'' ;
                         // DC - There is no provision for last 3 months from today in SOQL, so using LAST_90_DAYS literal
                         /* [VL 1.0] BEGIN *
                         /*
                         + '   WHERE ASI_TH_CRM_End_Date__c = LAST_90_DAYS' 
                         *
                         + '   WHERE '
             /* [WL 1.0 BEGIN] *
                         + ' ((ASI_TH_CRM_End_Date__c >= LAST_90_DAYS AND ' 
                         /* [VL 1.0] END *
             //+ '     ASI_TH_CRM_Contract_Status__c = \'Contract Approved\''
                         + '     ASI_TH_CRM_Contract_Status__c = \'Contract Approved\') OR (ASI_CRM_Recalculate_Actual_ROI__c = true))'
             /* [WL 1.0 END] *
                         + '     AND RecordType.DeveloperName = \'ASI_CRM_SG_Contract_Read_Only\''
                         + 'ORDER BY ASI_TH_CRM_Start_Date__c DESC';
  */
  private String query = '';
  
  private Set<string> entrySet_contractId = new Set<string>();
  private static final String YTD_RTID = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_SG_Contract_YTD_Achievement');
  //private integer totalOfftakeProceed = 0;
  //private integer totalOfftakeAdjusted = 0;
  private boolean isOfftakeAdjustment = false;
  private map<string, list<ASI_TH_CRM_Contract__c>> map_ownerId_contracts = new map<string, list<ASI_TH_CRM_Contract__c>>();
  private string specificOutletName = null;
  /* [VL 11.1] END */
    
    private Datetime monthlyNotificationDate = Datetime.newInstance(2000, 1, 1);

  /* [VL 11.1] BEGIN */
    global ASI_CRM_SG_YtdAchievementNotif_Batch(){
    this.query = '  SELECT Id'
                         + '       , ASI_TH_CRM_Contract_Status__c'
                         + '       , ASI_TH_CRM_End_Date__c'
                         + '       , ASI_TH_CRM_Start_Date__c'
             + '       , ASI_CRM_Contract_Exist_Before_RTM__c'
             + '       , OwnerId'
             + '       , Owner.Name'
             + '       , Owner.Email'
                         + '    FROM ASI_TH_CRM_Contract__c'
                         + '   WHERE '
                         + ' ((ASI_TH_CRM_End_Date__c >= LAST_90_DAYS AND ' 
                         + '     ASI_TH_CRM_Contract_Status__c = \'Contract Approved\') OR (ASI_CRM_Recalculate_Actual_ROI__c = true))'
                         + '     AND RecordType.DeveloperName = \'ASI_CRM_SG_Contract_Read_Only\''
                         + 'ORDER BY ASI_TH_CRM_Start_Date__c DESC';
  }
  
    global ASI_CRM_SG_YtdAchievementNotif_Batch(Set<string> set_contractId){
    this.entrySet_contractId = set_contractId;
    this.query = '  SELECT Id'
                         + '       , ASI_TH_CRM_Contract_Status__c'
                         + '       , ASI_TH_CRM_End_Date__c'
                         + '       , ASI_TH_CRM_Start_Date__c'
             + '       , ASI_CRM_Contract_Exist_Before_RTM__c'
             + '       , OwnerId'
             + '       , Owner.Name'
             + '       , Owner.Email'
                         + '    FROM ASI_TH_CRM_Contract__c'
                         + '   WHERE '
                         + '   Id in :entrySet_contractId ' 
                         + '  ORDER BY ASI_TH_CRM_Start_Date__c DESC';
  }
    global ASI_CRM_SG_YtdAchievementNotif_Batch(Set<string> set_contractId/*, integer totalOfftakeProceed, integer totalOfftakeAdjusted*/, boolean isOfftakeAdjustment){
    this(set_contractId);
    //this.totalOfftakeProceed = totalOfftakeProceed;
    //this.totalOfftakeAdjusted = totalOfftakeAdjusted;
    this.isOfftakeAdjustment = isOfftakeAdjustment;
  }
    global ASI_CRM_SG_YtdAchievementNotif_Batch(Set<string> set_contractId/*, integer totalOfftakeProceed, integer totalOfftakeAdjusted*/, boolean isOfftakeAdjustment, string specificOutletName){
    this(set_contractId, isOfftakeAdjustment);
    this.specificOutletName = specificOutletName;
  }
  /* [VL 11.1] END */
  
  
    // Getting the records matching the criteria.
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        /* [VL 8.0] BEGIN */
        skuMappingMap = new Map<Id, Id>();
        skuMappingMap = getSKUMapping();
        /* [VL 8.0] END */
    
    system.debug(this.entrySet_contractId);
    
    return Database.getQueryLocator(this.query);
    }
    
    // Processing records and generating email body.
    global void execute(Database.BatchableContext contextInstance, list<Sobject> pLstContracts) {
    
        //Wilken 20160902 Check if current date  requires sending email notification on final
        List<CronJobDetail> scheduleJobID = [select ID from CronJobDetail where name = 'ASI_CRM_SG_YtdAchievementNotif_Scheduler'];
    
        
        
        if (scheduleJobID != null && scheduleJobID.size() == 1){
            List<CronTrigger> scheduleJobDetail = [select CronExpression, CronJobDetailId , EndTime, NextFireTime from CronTrigger where CronJobDetailId = :scheduleJobID.get(0).Id];
            
            if (scheduleJobDetail != null && scheduleJobDetail.size() == 1)
                monthlyNotificationDate = scheduleJobDetail.get(0).NextFireTime;
        }
        

        /* [DC 2.0] BEGIN */
        Date recentStartDate;

        Set<Id> setSkuIds = new Set<Id>();
        
        List<ASI_CRM_MY_SKUPriceCost__c> lstPrices = new List<ASI_CRM_MY_SKUPriceCost__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> lstActualOfftakes;

        Map<ASI_TH_CRM_Actual_Offtake__c, ASI_CRM_MY_SKUPriceCost__c> mapActualOfftake_SkuPrice =
            new Map<ASI_TH_CRM_Actual_Offtake__c, ASI_CRM_MY_SKUPriceCost__c>();
        
        Map<ASI_TH_CRM_Actual_Offtake__c, Map<string, ASI_CRM_MY_SKUPriceCost__c>> map_ActualOfftake_type_SkuPrice =
            new Map<ASI_TH_CRM_Actual_Offtake__c, Map<string, ASI_CRM_MY_SKUPriceCost__c>>();

        Map<Id, Decimal> mapContractId_GrossSales = new Map<Id, Decimal>();
        Map<Id, Map<string, Decimal>> map_ContractId_type_Sales = new Map<Id, Map<string, Decimal>>();

        List<ASI_TH_CRM_Contract__c> lstFetchedContracts = (List<ASI_TH_CRM_Contract__c>) pLstContracts;
        /* [DC 2.0] END */

        Map<Id, ASI_TH_CRM_Contract__c> mapContractId_Record = 
            new Map<Id, ASI_TH_CRM_Contract__c>( (List<ASI_TH_CRM_Contract__c>) pLstContracts );
      
    /* [VL 11.0] BEGIN */
    Map<string, ASI_TH_CRM_Contract__c> map_ContractId_contractToUpdate = new Map<string, ASI_TH_CRM_Contract__c>();
    /* [VL 11.0] END */
    /* [VL 11.1] BEGIN */
    Map<string, Map<string, ASI_CRM_ContractSalesStaffIncentive__c>> map_ContractId_YTDbyMonth = new Map<string, Map<string, ASI_CRM_ContractSalesStaffIncentive__c>>();
    /* [VL 11.1] END */
    
    for (String c : mapContractId_Record.keySet()){
      mapContractId_Sum9L.put(c, 0);
      map_ContractId_sumCompensation.put(c, 0);
      mapContractId_blindBonus.put(c, 0);
      mapContractId_promptPayment.put(c, 0);
      map_ContractId_type_Sales.put(c,new Map<string, Decimal>{
      'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'=>0,
      'ASI_CRM_SG_CRM_Duty_Per_Bottle'=>0,
      'ASI_CRM_SG_CRM_FOB_Per_Bottle'=>0,
      'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'=>0,
      'Sales_Revenue_Original_Period'=>0
      });
      
      /* [VL 11.0] BEGIN */
      map_ContractId_contractToUpdate.put(c, new ASI_TH_CRM_Contract__c(
        id = c,
        ASI_CRM_Till_Date_Sales_Volume_9L__c = 0,
        ASI_CRM_ContractMarginPriceOverwrite_Act__c = 0,
        ASI_CRM_Blind_Bonus_Actual__c = 0,
        ASI_CRM_Prompt_Payment_Actual__c = 0,
        ASI_CRM_Sales_Revenue__c = 0,
        ASI_CRM_Total_Duty_Actual__c = 0,
        ASI_CRM_Total_FOB_Actual__c = 0,
        ASI_CRM_Total_Handling_Cost_Actual__c = 0,
        ASI_CRM_Wholesaler_Margin_Actual__c = 0,
        ASI_CRM_Sales_Revenue_In_Original_Period__c = 0,
        ASI_CRM_Recalculate_Actual_ROI__c = false
      ));
      /* [VL 11.0] END */
      
      /* [VL 11.1] BEGIN */
      ASI_TH_CRM_Contract__c r = mapContractId_Record.get(c);
      String ownerId = r.OwnerId;
      List<ASI_TH_CRM_Contract__c> list_c = map_ownerId_contracts.containsKey(ownerId) ? map_ownerId_contracts.get(ownerId) : new list<ASI_TH_CRM_Contract__c>();
      list_c.add(r);
      map_ownerId_contracts.put(ownerId, list_c);
      /* [VL 11.1] END */
      
      
    }
      
        Decimal sum9L = 0.0;
        Decimal sum9L_old = 0.0;
        Decimal sumBottle = 0.0;
        Decimal sumBottle_old = 0.0;
        Decimal sumCompensation = 0.0;
        Decimal sumCompensation_old = 0.0;
        /* [VL 9.0] BEGIN */
        Decimal sumWSMargin = 0.0;
        Decimal sumWSMargin_old = 0.0;
        /* [VL 9.0] END */
        /* [VL 6.0] BEGIN */
        Decimal blindBonus = 0.0;
        Decimal blindBonus_old = 0.0;
        Decimal promptPaymentRate = 0.0;
        Decimal grossSales = 0.0;
        Decimal promptPayment = 0.0;
        Decimal promptPayment_old = 0.0;
        /* [VL 6.0] END */

    /* [VL 8.0] BEGIN */
    Map<string, decimal> map_ContractIdSKU_sumBottle = new Map<string, decimal>();
    Map<string, ASI_CRM_ContractTarget__c> map_ContractIdSKU_contractTarget = new Map<string, ASI_CRM_ContractTarget__c>();
    /* [VL 8.0] END */
    
    /* [VL 11.0] BEGIN */
    /*
        lstActualOfftakes = [SELECT ASI_CRM_Converted_Qty_9L__c,
                                    ASI_TH_CRM_Offtake_G_L_Date__c,
                                    ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
                                    ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c,
                  * [VL 7.0] BEGIN *
                  ASI_CRM_Contract__r.ASI_CRM_End_Date_Original__c,
                  * [VL 7.0] END *
                                    ASI_TH_CRM_Quantity__c,
                                    ASI_CRM_Contract__c,
                                    ASI_CRM_SKU__c
                                 * [VL 6.0] BEGIN *
                                 , ASI_CRM_Gross_Sales__c, ASI_CRM_Prompt_Payment_Rate__c, ASI_CRM_Blind_Bonus_Amount_per_9L__c
                                 * [VL 6.0] END *
                  * [VL 10.1] BEGIN *
                  ,ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
                  * [VL 10.1] END *
                               FROM ASI_TH_CRM_Actual_Offtake__c
                              WHERE ASI_CRM_Contract__c IN : mapContractId_Record.keySet()
                           ORDER BY ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c DESC];
        //System.debug('**** lstActualOfftakes ***'+lstActualOfftakes+'\n');
        if( !lstActualOfftakes.isEmpty()) {
            recentStartDate = lstActualOfftakes.get(0).ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
        }
    */
    List<AggregateResult> lstActualOfftakes_ar = [
      select 
        ASI_CRM_Contract__c c,
        ASI_CRM_SKU__c sku,
		ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c subBrand,
		ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c isRegularSize,
        calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) year,
        calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c) month,
        sum(ASI_CRM_Converted_Qty_9L__c) sumQty9L,
        sum(ASI_TH_CRM_Quantity__c) sumQty,
        sum(ASI_CRM_Gross_Sales__c) sumGrossSales,
        sum(ASI_CRM_Total_Duty__c) sumDuty,
        sum(ASI_CRM_Total_FOB__c) sumFOB,
        sum(ASI_CRM_Total_Handling__c) sumHandling,
        sum(ASI_CRM_Gross_Sales_Within_Orig_Period__c) sumGrossSales_OriginalContractPeriod,
        sum(ASI_CRM_Total_Blind_Bonus__c) sumBlindBonus,
        sum(ASI_CRM_Total_Prompt_Payment__c) sumPromptPayment
      from 
        ASI_TH_CRM_Actual_Offtake__c
      where 
        ASI_CRM_Contract__c IN : mapContractId_Record.keySet()
        and ASI_CRM_Within_Contract_Period__c = true
        and ASI_CRM_SKU__c <> null
      group by
        ASI_CRM_Contract__c,
        ASI_CRM_SKU__c,
		ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, 
		ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c,
        calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c),
        calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)
      order by 
        ASI_CRM_Contract__c,
        ASI_CRM_SKU__c,
        calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c),
        calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)
    ];
    /* [VL 11.0] END */

        /* [VL 2.2] BEGIN */
        for (ASI_CRM_ContractTarget__c contractTarget : 
             [SELECT 
              ASI_CRM_Contract__c,
              ASI_CRM_SKU__c,
              ASI_CRM_SG_Consumer_Price_Offer__c,
              ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c
        /* [VL 8.0] BEGIN */
        , ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
        /* [VL 8.0] END */
        /* [VL 9.0] BEGIN */
        , ASI_CRM_SG_Wholesaler_Margin__c
        /* [VL 9.0] END */
        /* [VL 11.2] BEGIN */
        , ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c
        /* [VL 11.2] END */
              FROM ASI_CRM_ContractTarget__c
              WHERE ASI_CRM_Contract__c IN : mapContractId_Record.keySet()
        and recordtype.developername = :CONTRACTTARGET_RECORD_TYPE
        /* [VL 8.0] BEGIN */
        /*
              and ASI_CRM_SKU__c <> null
              and ASI_CRM_SG_Consumer_Price_Offer__c <> null
              and ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null
        */
        /* [VL 8.0] END */
		Order by ASI_CRM_Contract__c, ASI_CRM_Sequence_No__c asc
		]) {
        string lastestSkuId = skuMappingMap.containsKey(contractTarget.ASI_CRM_SKU__c) ? skuMappingMap.get(contractTarget.ASI_CRM_SKU__c) : contractTarget.ASI_CRM_SKU__c;
                  if (
          /* [VL 8.0] BEGIN */  
          contractTarget.ASI_CRM_SKU__c != null &&
          contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c != null &&
          contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null &&
          /* [VL 8.0] END */
          contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c < contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c
          ){
                      map_ContractIdSKU_sumCompensation.put(
                          contractTarget.ASI_CRM_Contract__c+'_'+lastestSkuId, 
                          (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c)
                      );
                  }
          /* [VL 8.0] BEGIN */
          if (!contractTarget.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c){
            map_ContractIdSKU_sumBottle.put(contractTarget.ASI_CRM_Contract__c+'_'+lastestSkuId, 0);
            map_ContractIdSKU_contractTarget.put(contractTarget.ASI_CRM_Contract__c+'_'+lastestSkuId, contractTarget);
			/* [VL 11.2] BEGIN */
			if(contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
				String subBrandId = contractTarget.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
				if(!map_ContractIdSKU_sumBottle.containsKey(contractTarget.ASI_CRM_Contract__c+'_'+subBrandId)){
					map_ContractIdSKU_sumBottle.put(contractTarget.ASI_CRM_Contract__c+'_'+subBrandId, 0);
					map_ContractIdSKU_contractTarget.put(contractTarget.ASI_CRM_Contract__c+'_'+subBrandId, contractTarget);
				}
			}
			/* [VL 11.2] BEGIN */
          }
          /* [VL 8.0] END */
          /* [VL 9.0] BEGIN */
          if (contractTarget.ASI_CRM_SG_Wholesaler_Margin__c != null && contractTarget.ASI_CRM_SG_Wholesaler_Margin__c > 0){
            map_ContractIdSKU_sumWSMargin.put(
            contractTarget.ASI_CRM_Contract__c+'_'+lastestSkuId, 
            contractTarget.ASI_CRM_SG_Wholesaler_Margin__c
            );
          }
          /* [VL 9.0] END */
              }
        
        system.debug('----------map_ContractIdSKU_sumCompensation----------'+map_ContractIdSKU_sumCompensation);
        /* [VL 2.2] END */
    
    /* [VL 11.1] BEGIN */
    for (ASI_CRM_ContractSalesStaffIncentive__c ytd : [
      select 
        id, ASI_CRM_Contract__c, ASI_CRM_Year__c, ASI_CRM_Month__c 
      from 
        ASI_CRM_ContractSalesStaffIncentive__c
      where
        recordtypeid = :YTD_RTID
        and ASI_CRM_Contract__c IN : mapContractId_Record.keySet()
    ]){
      String contractId = ytd.ASI_CRM_Contract__c;
      Map<string, ASI_CRM_ContractSalesStaffIncentive__c> map_month_YTD = map_ContractId_YTDbyMonth.containsKey(contractId) ? map_ContractId_YTDbyMonth.get(contractId) : new Map<string, ASI_CRM_ContractSalesStaffIncentive__c>();
      String key = ytd.ASI_CRM_Year__c + '_' + ytd.ASI_CRM_Month__c;
      ytd.ASI_CRM_Sales_Revenue__c = 0;
      map_month_YTD.put(key, ytd);
      map_ContractId_YTDbyMonth.put(ytd.ASI_CRM_Contract__c, map_month_YTD);
    }
    
    /* [VL 11.1] END */

    /* [VL 11.0] BEGIN */
    /*
        for(ASI_TH_CRM_Actual_Offtake__c offtakeIterator : lstActualOfftakes) {

            if(offtakeIterator.ASI_TH_CRM_Offtake_G_L_Date__c > offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c
            || offtakeIterator.ASI_TH_CRM_Offtake_G_L_Date__c < offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c) {
                continue;
            }

            /* [DC 2.0] BEGIN *
            if(offtakeIterator.ASI_CRM_SKU__c != NULL) {
                setSkuIds.add(offtakeIterator.ASI_CRM_SKU__c);
            }
            /* [DC 2.0] END *

            /* [VL 2.2] BEGIN *
            /*
            sum9L = (offtakeIterator.ASI_CRM_Converted_Qty_9L__c != NULL) ? offtakeIterator.ASI_CRM_Converted_Qty_9L__c : 0.0;

            if(!mapContractId_Sum9L.containsKey(offtakeIterator.ASI_CRM_Contract__c)) {

                mapContractId_Sum9L.put(offtakeIterator.ASI_CRM_Contract__c, sum9L);

            } else if(mapContractId_Sum9L.containsKey(offtakeIterator.ASI_CRM_Contract__c)) {

                mapContractId_Sum9L.put(
                    offtakeIterator.ASI_CRM_Contract__c,
                    mapContractId_Sum9L.get(offtakeIterator.ASI_CRM_Contract__c) + sum9L
                );
            }
            *
      string lastestSkuId = skuMappingMap.containsKey(offtakeIterator.ASI_CRM_SKU__c) ? skuMappingMap.get(offtakeIterator.ASI_CRM_SKU__c) : offtakeIterator.ASI_CRM_SKU__c;
            sum9L = (offtakeIterator.ASI_CRM_Converted_Qty_9L__c != NULL) ? offtakeIterator.ASI_CRM_Converted_Qty_9L__c : 0.0;
            sum9L_old = (mapContractId_Sum9L.containsKey(offtakeIterator.ASI_CRM_Contract__c)) ? mapContractId_Sum9L.get(offtakeIterator.ASI_CRM_Contract__c) : 0.0;
            sumBottle = (offtakeIterator.ASI_TH_CRM_Quantity__c != NULL) ? offtakeIterator.ASI_TH_CRM_Quantity__c : 0.0;
            sumCompensation = (map_ContractIdSKU_sumCompensation.containsKey(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId)) ? (map_ContractIdSKU_sumCompensation.get(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId) * sumBottle) : 0.0;
            sumCompensation_old = (map_ContractId_sumCompensation.containsKey(offtakeIterator.ASI_CRM_Contract__c)) ? map_ContractId_sumCompensation.get(offtakeIterator.ASI_CRM_Contract__c) : 0.0;
      /* [VL 9.0] BEGIN *
            sumWSMargin = (map_ContractIdSKU_sumWSMargin.containsKey(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId)) ? (map_ContractIdSKU_sumWSMargin.get(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId) * sumBottle) : 0.0;
            sumWSMargin_old = (map_ContractId_sumWSMargin.containsKey(offtakeIterator.ASI_CRM_Contract__c)) ? map_ContractId_sumWSMargin.get(offtakeIterator.ASI_CRM_Contract__c) : 0.0;
      /* [VL 9.0] END *
      
            /* [VL 6.0] BEGIN *
            blindBonus = (offtakeIterator.ASI_CRM_Blind_Bonus_Amount_per_9L__c != NULL) ? (offtakeIterator.ASI_CRM_Blind_Bonus_Amount_per_9L__c * sum9L) : 0.0;
            blindBonus_old = (mapContractId_blindBonus.containsKey(offtakeIterator.ASI_CRM_Contract__c)) ? mapContractId_blindBonus.get(offtakeIterator.ASI_CRM_Contract__c) : 0.0;
            promptPaymentRate = (offtakeIterator.ASI_CRM_Prompt_Payment_Rate__c != NULL) ? offtakeIterator.ASI_CRM_Prompt_Payment_Rate__c : 0.0;
            grossSales = (offtakeIterator.ASI_CRM_Gross_Sales__c != NULL) ? offtakeIterator.ASI_CRM_Gross_Sales__c : 0.0;
            promptPayment = grossSales * promptPaymentRate;
            promptPayment_old = (mapContractId_promptPayment.containsKey(offtakeIterator.ASI_CRM_Contract__c)) ? mapContractId_promptPayment.get(offtakeIterator.ASI_CRM_Contract__c) : 0.0;
            /* [VL 6.0] END *
            
            //system.debug('----------sumBottle----------'+sumBottle);
            //system.debug('----------sumCompensation----------'+sumCompensation);
            //system.debug('----------sumCompensation_old----------'+sumCompensation_old);
            
            mapContractId_Sum9L.put(
                offtakeIterator.ASI_CRM_Contract__c,
                sum9L_old + sum9L
            );
            
            map_ContractId_sumCompensation.put(
                offtakeIterator.ASI_CRM_Contract__c,
                sumCompensation_old + sumCompensation
            );            
            
            /* [VL 9.0] BEGIN *
            map_ContractId_sumWSMargin.put(
                offtakeIterator.ASI_CRM_Contract__c,
                sumWSMargin_old + sumWSMargin
            );
            /* [VL 9.0] END *
      
            /* [VL 6.0] BEGIN *
            mapContractId_blindBonus.put(
                offtakeIterator.ASI_CRM_Contract__c,
                promptPayment_old + promptPayment
            );
            mapContractId_promptPayment.put(
                offtakeIterator.ASI_CRM_Contract__c,
                promptPayment_old + promptPayment
            );
            /* [VL 6.0] END *
            
            /* [VL 2.2] END *
      
        /* [VL 8.0] BEGIN *
        if (map_ContractIdSKU_sumBottle.containskey(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId)){
        decimal sumOfftakeBottle = map_ContractIdSKU_sumBottle.get(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId);
        sumOfftakeBottle += offtakeIterator.ASI_TH_CRM_Quantity__c;
        map_ContractIdSKU_sumBottle.put(offtakeIterator.ASI_CRM_Contract__c+'_'+lastestSkuId, sumOfftakeBottle);
        
        }
        /* [VL 8.0] END *
        }
    */
    for(AggregateResult ar : lstActualOfftakes_ar) {

      String contractId = String.valueOf(ar.get('c'));
      String sku = String.valueOf(ar.get('sku'));
      String yearStr = String.valueOf(ar.get('year'));
      String monthStr = String.valueOf(ar.get('month'));
	  /* [VL 11.2] BEGIN */
      String subBrandId = String.valueOf(ar.get('subBrand'));
      Boolean isRegularSize = Boolean.valueOf(ar.get('isRegularSize'));
	  /* [VL 11.2] BEGIN */
      
      string lastestSkuId = skuMappingMap.containsKey(sku) ? skuMappingMap.get(sku) : sku;
      
      Decimal sumQty9L = (Decimal)ar.get('sumQty9L') != null ? (Decimal)ar.get('sumQty9L') : 0;
      Decimal sumQty = (Decimal)ar.get('sumQty') != null ? (Decimal)ar.get('sumQty') : 0;
      Decimal sumGrossSales = (Decimal)ar.get('sumGrossSales') != null ? (Decimal)ar.get('sumGrossSales') : 0;
      Decimal sumDuty = (Decimal)ar.get('sumDuty') != null ? (Decimal)ar.get('sumDuty') : 0;
      Decimal sumFOB = (Decimal)ar.get('sumFOB') != null ? (Decimal)ar.get('sumFOB') : 0;
      Decimal sumHandling = (Decimal)ar.get('sumHandling') != null ? (Decimal)ar.get('sumHandling') : 0;
      Decimal sumGrossSales_OriginalContractPeriod = (Decimal)ar.get('sumGrossSales_OriginalContractPeriod') != null ? (Decimal)ar.get('sumGrossSales_OriginalContractPeriod') : 0;
      Decimal sumBlindBonus = (Decimal)ar.get('sumBlindBonus') != null ? (Decimal)ar.get('sumBlindBonus') : 0;
      Decimal sumPromptPayment = (Decimal)ar.get('sumPromptPayment') != null ? (Decimal)ar.get('sumPromptPayment') : 0;
      sumCompensation = (map_ContractIdSKU_sumCompensation.containsKey(contractId+'_'+lastestSkuId)) ? (map_ContractIdSKU_sumCompensation.get(contractId+'_'+lastestSkuId) * sumQty) : 0.0;
      sumWSMargin = (map_ContractIdSKU_sumWSMargin.containsKey(contractId+'_'+lastestSkuId)) ? (map_ContractIdSKU_sumWSMargin.get(contractId+'_'+lastestSkuId) * sumQty) : 0.0;
    
      // roll up to contract level
      ASI_TH_CRM_Contract__c c = map_ContractId_contractToUpdate.get(contractId);
      c.ASI_CRM_Till_Date_Sales_Volume_9L__c += sumQty9L;
      c.ASI_CRM_ContractMarginPriceOverwrite_Act__c += sumCompensation;
      c.ASI_CRM_Blind_Bonus_Actual__c += sumBlindBonus;
      c.ASI_CRM_Prompt_Payment_Actual__c += sumPromptPayment;
      c.ASI_CRM_Sales_Revenue__c += sumGrossSales;
      c.ASI_CRM_Total_Duty_Actual__c += sumDuty;
      c.ASI_CRM_Total_FOB_Actual__c += sumFOB;
      c.ASI_CRM_Total_Handling_Cost_Actual__c += sumHandling;
      c.ASI_CRM_Wholesaler_Margin_Actual__c += sumWSMargin;
      c.ASI_CRM_Sales_Revenue_In_Original_Period__c += sumGrossSales_OriginalContractPeriod;
      map_ContractId_contractToUpdate.put(contractId, c);
    
        if (map_ContractIdSKU_sumBottle.containskey(contractId+'_'+lastestSkuId)){
        decimal sumOfftakeBottle = map_ContractIdSKU_sumBottle.get(contractId+'_'+lastestSkuId);
        sumOfftakeBottle += sumQty;
        map_ContractIdSKU_sumBottle.put(contractId+'_'+lastestSkuId, sumOfftakeBottle);
        
        }
		/* [VL 11.2] BEGIN */
		else
		if(isRegularSize && map_ContractIdSKU_sumBottle.containskey(contractId+'_'+subBrandId)){
			decimal sumOfftakeBottle = map_ContractIdSKU_sumBottle.get(contractId+'_'+subBrandId);
			sumOfftakeBottle += sumQty;
			map_ContractIdSKU_sumBottle.put(contractId+'_'+subBrandId, sumOfftakeBottle);
		}
		/* [VL 11.2] BEGIN */
      
      // roll up to contract level by month
      string key = yearStr + '_' + monthStr;
      Map<string, ASI_CRM_ContractSalesStaffIncentive__c> map_month_YTD = map_ContractId_YTDbyMonth.containsKey(contractId) ? map_ContractId_YTDbyMonth.get(contractId) : new Map<string, ASI_CRM_ContractSalesStaffIncentive__c>();
      ASI_CRM_ContractSalesStaffIncentive__c ytd = map_month_YTD.containsKey(key) ? map_month_YTD.get(key) : new ASI_CRM_ContractSalesStaffIncentive__c(
        recordtypeid = YTD_RTID,
        ASI_CRM_Contract__c = contractId,
        ASI_CRM_Year__c = yearStr,
        ASI_CRM_Month__c = monthStr,
        ASI_CRM_Sales_Revenue__c = 0
      );
      ytd.ASI_CRM_Sales_Revenue__c += sumGrossSales;
      map_month_YTD.put(key, ytd);
      map_ContractId_YTDbyMonth.put(contractId, map_month_YTD);
      
        }
    /* [VL 11.0] END */
            system.debug('----------map_ContractId_sumCompensation----------'+map_ContractId_sumCompensation);
    
        
    /* [VL 11.0] BEGIN */
    /*
        /* [DC 2.0] BEGIN *
        if( !setSkuIds.isEmpty() && recentStartDate != NULL) {
            lstPrices = [SELECT ASI_CRM_Price__c
                              , ASI_CRM_SKU__c
                                , ASI_CRM_Cost__c
                              , ASI_CRM_EffectiveDate__c
                                , RecordType.DeveloperName
                           FROM ASI_CRM_MY_SKUPriceCost__c
                          WHERE ASI_CRM_SKU__c IN : setSkuIds
              /* [VL 10.0] BEGIN *
                            AND ASI_CRM_EffectiveDate__c >= 2010-01-01
              /* [VL 10.0] END *
                            AND ASI_CRM_EffectiveDate__c <= : recentStartDate
                            //AND ASI_CRM_EffectiveDate__c != NULL
                            AND RecordType.DeveloperName IN : SET_PRICE_RECTYPE_DEVNAME
                       ORDER BY ASI_CRM_EffectiveDate__c DESC];
                        //System.debug('**** ASI_CRM_MY_SKUPriceCost__c ***'+lstPrices+'\n');
            
            for(ASI_TH_CRM_Actual_Offtake__c offtakeIterator : lstActualOfftakes) {

                for(ASI_CRM_MY_SKUPriceCost__c skuPriceIterator : lstPrices) {

                    /* [VL 2.1] BEGIN */
                    /*
                    if( offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c != NULL
                    &&  offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= skuPriceIterator.ASI_CRM_EffectiveDate__c
                    &&  !mapActualOfftake_SkuPrice.containsKey(offtakeIterator)
                    &&  offtakeIterator.ASI_CRM_SKU__c == skuPriceIterator.ASI_CRM_SKU__c) {
                        mapActualOfftake_SkuPrice.put(offtakeIterator, skuPriceIterator);
                    }
                    *
                    
                    if( offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c != NULL
                    &&  offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= skuPriceIterator.ASI_CRM_EffectiveDate__c
                    &&  offtakeIterator.ASI_CRM_SKU__c == skuPriceIterator.ASI_CRM_SKU__c) {
                       
                        Map<string, ASI_CRM_MY_SKUPriceCost__c> map_type_skuPrice = map_ActualOfftake_type_SkuPrice.containsKey(offtakeIterator) ? map_ActualOfftake_type_SkuPrice.get(offtakeIterator) : new Map<string, ASI_CRM_MY_SKUPriceCost__c>();
                        if (map_type_skuPrice.keySet()==SET_PRICE_RECTYPE_DEVNAME) {
                            continue;
                        } else
            /* [VL 10.1] BEGIN *
            /*
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') && skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'){
                            map_type_skuPrice.put('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        } else
            *
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') && 
              skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler' && 
              offtakeIterator.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
            ){
                            map_type_skuPrice.put('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        } else
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') && 
              skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle' && 
              !offtakeIterator.ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c
            ){
                            map_type_skuPrice.put('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        } else
            /* [VL 10.1] END *
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') && skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_CRM_Duty_Per_Bottle'){
                            map_type_skuPrice.put('ASI_CRM_SG_CRM_Duty_Per_Bottle',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        } else
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') && skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_CRM_FOB_Per_Bottle'){
                            map_type_skuPrice.put('ASI_CRM_SG_CRM_FOB_Per_Bottle',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        } else
                        if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') && skuPriceIterator.RecordType.DeveloperName=='ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'){
                            map_type_skuPrice.put('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',skuPriceIterator);
                            map_ActualOfftake_type_SkuPrice.put(offtakeIterator, map_type_skuPrice);
                        }
                    }
                    /* [VL 2.1] END *
                }
            }

            Decimal currentPrice;
            Decimal newPrice;

            /* [VL 2.1] BEGIN *
            /*
            for( ASI_TH_CRM_Actual_Offtake__c offtakeIterator : mapActualOfftake_SkuPrice.keySet()) {

                currentPrice = mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c != NULL
                             ? mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c
                             : 0.0;
                currentPrice = mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c != NULL
                             ? (offtakeIterator.ASI_TH_CRM_Quantity__c != NULL ? (offtakeIterator.ASI_TH_CRM_Quantity__c * mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c) : 0.0)
                             : 0.0;

                System.debug('------ mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c ------ : ' + mapActualOfftake_SkuPrice.get(offtakeIterator).ASI_CRM_Price__c);
                System.debug('------ currentPrice ------ : ' + currentPrice);

                if( !mapContractId_GrossSales.containsKey(offtakeIterator.ASI_CRM_Contract__c) ) {
                    mapContractId_GrossSales.put(
                        offtakeIterator.ASI_CRM_Contract__c,
                        currentPrice
                    );
                } else {
                    mapContractId_GrossSales.put(
                        offtakeIterator.ASI_CRM_Contract__c,
                        mapContractId_GrossSales.get(offtakeIterator.ASI_CRM_Contract__c) + currentPrice
                    );
                }

            }
            *
            for( ASI_TH_CRM_Actual_Offtake__c offtakeIterator : map_ActualOfftake_type_SkuPrice.keySet()) {
                Map<string, decimal> map_type_Sales = map_ContractId_type_Sales.containsKey(offtakeIterator.ASI_CRM_Contract__c) ? map_ContractId_type_Sales.get(offtakeIterator.ASI_CRM_Contract__c) : new Map<string, decimal>();

                for (string priceType : map_ActualOfftake_type_SkuPrice.get(offtakeIterator).keySet()) {
                    if (priceType=='ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') {
                        currentPrice = map_ActualOfftake_type_SkuPrice.get(offtakeIterator).get(priceType).ASI_CRM_Price__c != NULL
                             ? (offtakeIterator.ASI_TH_CRM_Quantity__c != NULL ? (offtakeIterator.ASI_TH_CRM_Quantity__c * map_ActualOfftake_type_SkuPrice.get(offtakeIterator).get(priceType).ASI_CRM_Price__c) : 0.0)
                             : 0.0;
                    } else {
                        currentPrice = map_ActualOfftake_type_SkuPrice.get(offtakeIterator).get(priceType).ASI_CRM_Cost__c != NULL
                             ? (offtakeIterator.ASI_TH_CRM_Quantity__c != NULL ? (offtakeIterator.ASI_TH_CRM_Quantity__c * map_ActualOfftake_type_SkuPrice.get(offtakeIterator).get(priceType).ASI_CRM_Cost__c) : 0.0)
                             : 0.0;
                    }
                    
                    newPrice = map_type_Sales.containskey(priceType) ? map_type_Sales.get(priceType) : 0.0;
                    newPrice += currentPrice;
                    map_type_Sales.put(priceType, newPrice);
                }
        
        /* [VL 7.0] BEGIN *
        Date orginalContractEndDate = offtakeIterator.ASI_CRM_Contract__r.ASI_CRM_End_Date_Original__c != null ? offtakeIterator.ASI_CRM_Contract__r.ASI_CRM_End_Date_Original__c : offtakeIterator.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c;
        if (offtakeIterator.ASI_TH_CRM_Offtake_G_L_Date__c <= orginalContractEndDate){
          if (map_ActualOfftake_type_SkuPrice.get(offtakeIterator).containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler')) {
          decimal price_PRS_WS = map_ActualOfftake_type_SkuPrice.get(offtakeIterator).get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler').ASI_CRM_Price__c;
          currentPrice = price_PRS_WS != NULL
                   ? (offtakeIterator.ASI_TH_CRM_Quantity__c != NULL ? (offtakeIterator.ASI_TH_CRM_Quantity__c * price_PRS_WS) : 0.0)
                   : 0.0;
          }
          newPrice = map_type_Sales.containskey('Sales_Revenue_Original_Period') ? map_type_Sales.get('Sales_Revenue_Original_Period') : 0.0;
          newPrice += currentPrice;
          map_type_Sales.put('Sales_Revenue_Original_Period', newPrice);
          
        }
        /* [VL 7.0] END *
        
                map_ContractId_type_Sales.put(offtakeIterator.ASI_CRM_Contract__c, map_type_Sales);

            }
            /* [VL 2.1] END *
        }
    */
    /* [VL 11.0] END */

        /* [DC 1.2] BEGIN */
        // List<ASI_TH_CRM_Contract__c> lstContracts_ToUpdate = new List<ASI_TH_CRM_Contract__c>();
        Map<String, ASI_TH_CRM_Contract__c> mapContractId_RecordToUpdate =
            new Map<String, ASI_TH_CRM_Contract__c>();

    /* [VL 11.0] BEGIN */
    /*
        for(Id contractId : mapContractId_Sum9L.keySet()) {
            mapContractId_RecordToUpdate.put( 
                contractId,
                new ASI_TH_CRM_Contract__c(
                    Id = contractId,
                    ASI_CRM_Till_Date_Sales_Volume_9L__c = mapContractId_Sum9L.get(contractId)
                    /* [VL 2.2] BEGIN *
                    /* [VL 5.0] BEGIN *
                    , ASI_CRM_ContractMarginPriceOverwrite_Act__c = map_ContractId_sumCompensation.containsKey(contractId) ? map_ContractId_sumCompensation.get(contractId) : 0.0
                    /* [VL 5.0] END *
                    /* [VL 2.2] END *
                    /* [VL 6.0] BEGIN *
                    , ASI_CRM_Blind_Bonus_Actual__c = mapContractId_blindBonus.get(contractId)
                    , ASI_CRM_Prompt_Payment_Actual__c = mapContractId_promptPayment.get(contractId)
                    /* [VL 6.0] END *
          /* [WL 1.0 ] BEGIN *
          , ASI_CRM_Recalculate_Actual_ROI__c = false
          /* [WL 1.0 ] END *
          /* [VL 9.0 ] BEGIN *
          , ASI_CRM_Wholesaler_Margin_Actual__c = map_ContractId_sumWSMargin.containsKey(contractId) ? map_ContractId_sumWSMargin.get(contractId) : 0.0
          /* [VL 9.0 ] END *
                )
            );
        }
    */
    mapContractId_RecordToUpdate = map_ContractId_contractToUpdate;
    /* [VL 11.0] END */

        /* [VL 2.1] BEGIN */
        /*
        for(Id contractId : mapContractId_GrossSales.keySet()) {

            if( !mapContractId_RecordToUpdate.containsKey(contractId) ) {
                mapContractId_RecordToUpdate.put( 
                    contractId,
                    new ASI_TH_CRM_Contract__c(
                        Id = contractId,
                        ASI_CRM_Gross_Sales__c = mapContractId_GrossSales.get(contractId)
                    )
                );
            } else {
                ASI_TH_CRM_Contract__c contractInstance = mapContractId_RecordToUpdate.get(contractId);
                contractInstance.ASI_CRM_Gross_Sales__c = mapContractId_GrossSales.get(contractId);
                mapContractId_RecordToUpdate.put( 
                    contractId,
                    contractInstance
                );
            }
        }
        */
        System.debug('------ map_ContractId_type_Sales ------ : ' + map_ContractId_type_Sales);
        
        System.debug('------ map_ActualOfftake_type_SkuPrice ------ : ' + map_ActualOfftake_type_SkuPrice);
    
    /* [VL 11.0] BEGIN */
    /*
        for(Id contractId : map_ContractId_type_Sales.keySet()) {
            Map<string, decimal> map_type_Sales = map_ContractId_type_Sales.containsKey(contractId) ? map_ContractId_type_Sales.get(contractId) : new Map<string, decimal>();
            
            if( !mapContractId_RecordToUpdate.containsKey(contractId) ) {
                mapContractId_RecordToUpdate.put( 
                    contractId,
                    new ASI_TH_CRM_Contract__c(
                        Id = contractId,
                        ASI_CRM_Sales_Revenue__c = map_type_Sales.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') ? map_type_Sales.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') : 0.0,
                        ASI_CRM_Total_Duty_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_Duty_Per_Bottle') : 0.0,
                        ASI_CRM_Total_FOB_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_FOB_Per_Bottle') : 0.0,
                        ASI_CRM_Total_Handling_Cost_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') : 0.0
            /* [VL 7.0] BEGIN *
            , ASI_CRM_Sales_Revenue_In_Original_Period__c = map_type_Sales.containsKey('Sales_Revenue_Original_Period') ? map_type_Sales.get('Sales_Revenue_Original_Period') : 0.0
            /* [VL 7.0] END *
                    )
                );
            } else {
                ASI_TH_CRM_Contract__c contractInstance = mapContractId_RecordToUpdate.get(contractId);
                contractInstance.ASI_CRM_Sales_Revenue__c = map_type_Sales.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') ? map_type_Sales.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') : 0.0;
                contractInstance.ASI_CRM_Total_Duty_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_Duty_Per_Bottle') : 0.0;
                contractInstance.ASI_CRM_Total_FOB_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_FOB_Per_Bottle') : 0.0;
                contractInstance.ASI_CRM_Total_Handling_Cost_Actual__c = map_type_Sales.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') ? map_type_Sales.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') : 0.0;
        /* [VL 7.0] BEGIN *
        contractInstance.ASI_CRM_Sales_Revenue_In_Original_Period__c = map_type_Sales.containsKey('Sales_Revenue_Original_Period') ? map_type_Sales.get('Sales_Revenue_Original_Period') : 0.0;
        /* [VL 7.0] END *
                mapContractId_RecordToUpdate.put( 
                    contractId,
                    contractInstance
                );
            }
        }
        /* [VL 2.1] END *
    */
    /* [VL 11.0] END */
    
    /* [VL 8.0] BEGIN */
    List<ASI_CRM_ContractTarget__c> list_ctToUpdate = new List<ASI_CRM_ContractTarget__c>();
	/* [VL 11.2] BEGIN */
	/*
    for (string key : map_ContractIdSKU_sumBottle.keySet()){
      decimal sumOfftakeBottle = map_ContractIdSKU_sumBottle.get(key);
      if (sumOfftakeBottle > 0){
      ASI_CRM_ContractTarget__c ct = map_ContractIdSKU_contractTarget.get(key);
      ct.ASI_CRM_Till_Date_Sales_Bottle__c = sumOfftakeBottle;
      list_ctToUpdate.add(ct);
      }
    }
	*/
	Map<string, ASI_CRM_ContractTarget__c> map_ctPrepare = new Map<string, ASI_CRM_ContractTarget__c>();
	for(string key : map_ContractIdSKU_contractTarget.keySet()){
		ASI_CRM_ContractTarget__c ct = map_ContractIdSKU_contractTarget.get(key);
		ct.ASI_CRM_Till_Date_Sales_Bottle__c = 0;
		map_ctPrepare.put(ct.Id, ct);
	}
    for (string key : map_ContractIdSKU_sumBottle.keySet()){
      decimal sumOfftakeBottle = map_ContractIdSKU_sumBottle.get(key);
      if (sumOfftakeBottle > 0){
      String ctId = map_ContractIdSKU_contractTarget.get(key).Id;
      ASI_CRM_ContractTarget__c ct = map_ctPrepare.get(ctId);
      ct.ASI_CRM_Till_Date_Sales_Bottle__c += sumOfftakeBottle;
      map_ctPrepare.put(ct.Id, ct);
      }
    }
	list_ctToUpdate = map_ctPrepare.values();
	/* [VL 11.2] END */
    /* [VL 8.0] END */
    
    /* [VL 11.1] BEGIN */
    List<ASI_CRM_ContractSalesStaffIncentive__c> list_ytdToUpsert = new List<ASI_CRM_ContractSalesStaffIncentive__c>();
    for (string contractId : map_ContractId_YTDbyMonth.keySet()){
      list_ytdToUpsert.addAll(map_ContractId_YTDbyMonth.get(contractId).values());
    }
    /* [VL 11.1] END */

        try {

            System.debug('------ mapContractId_RecordToUpdate.values() ------ : ' + mapContractId_RecordToUpdate.values());
            
            if( !mapContractId_RecordToUpdate.values().isEmpty() ) {
                update mapContractId_RecordToUpdate.values();
            }
      
        /* [VL 8.0] BEGIN */
        if (list_ctToUpdate.size()>0){
        update list_ctToUpdate;
        }
        /* [VL 8.0] END */
        
        /* [VL 11.1] BEGIN */
        if (list_ytdToUpsert.size()>0){
        upsert list_ytdToUpsert;
        }
        /* [VL 11.1] END */

        } catch(DmlException exceptionInstance) {}
        /* [DC 2.0] END */

    /* [VL 11.0] BEGIN */
    /*
        if(mapContractId_Sum9L.keySet().isEmpty()) {
            return;
        }
    */
        if(mapContractId_RecordToUpdate.keySet().isEmpty()) {
            return;
        }
    /* [VL 11.0] END */

        List<ASI_TH_CRM_Contract__c> lstUpdatedContracts =
            [SELECT Id,
                    Name,
                    OwnerId,
                    Owner.Name,
                    Owner.Email,
                    ASI_CRM_CN_Outlet_WS__r.name,
                    ASI_CRM_CN_Sys_Approver_2__c,
                    ASI_CRM_CN_Sys_Approver_2__r.Email,
                    ASI_CRM_Till_Date_Sales_Volume_9L__c,
                    ASI_CRM_Till_Date_Sales_Percent_Achieved__c,
                    (SELECT Id,
                            ASI_CRM_Sponsorship__c,
                            ASI_CRM_Schedule_Date__c,
                            ASI_CRM_Percentof_achieved_Sales_Target__c
                       FROM Payment_Schedules__r
                       WHERE ASI_CRM_Type__c = 'Cash Sponsorship'
                        AND ASI_CRM_Achieved__c = TRUE
                        AND ASI_CRM_Payment_Issued__c = FALSE
            AND recordtype.developername = :PAYMENTSCHEDULE_RECORD_TYPE
          )
               FROM ASI_TH_CRM_Contract__c
              WHERE 
        /* [VL 11.0] BEGIN */
        /*
        Id IN : mapContractId_Sum9L.keySet()
        */
        Id IN : mapContractId_RecordToUpdate.keySet()
        /* [VL 11.0] END */
                /* [VL 4.0] BEGIN */
             AND ASI_CRM_Till_Date_Sales_Percent_Achieved__c >= 90
                /* [VL 4.0] END */
            ];

        /* [HC 2.0] BEGIN */
        Set<Id> userIdSet = new Set<Id>();
        /* [HC 2.0] END */

        for(ASI_TH_CRM_Contract__c contractIterator : lstUpdatedContracts) {

            //lstPlaceHolders = new List<ASI_TH_CRM_Contract__c>();

            /* [HC 2.0] BEGIN */
            userIdSet.add(contractIterator.OwnerId);
            /* [HC 2.0] END */

            if( !mapOwnerId_OwnedContracts.containsKey(contractIterator.OwnerId) ) {
                mapOwnerId_OwnedContracts.put(
                    contractIterator.OwnerId,
                    new Set<ASI_TH_CRM_Contract__c> {
                        contractIterator
                    }
                );
            } else {
                mapOwnerId_OwnedContracts.get(contractIterator.OwnerId).add(contractIterator);
            }

        }

        /* [HC 2.0] BEGIN */
        Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id, ASI_OBIEE_Domain__c
                                                        FROM User
                                                            WHERE Id in :userIdSet]);
        /* [HC 2.0] END */

        System.debug('------ mapOwnerId_OwnedContracts ------ : ' + mapOwnerId_OwnedContracts);

        Messaging.SingleEmailMessage emailPlaceHolder;
        EmailWrapper wrapperPlaceHolder;
        String emailHtmlBody;
        String recordLink;
        DateTime datePlaceHolder;

        for(Id ownerIdIterator : mapOwnerId_OwnedContracts.keySet()) {

            if( !mapOwnerId_EmailMessage.containsKey(ownerIdIterator) ) {
                
                /*mapOwnerId_EmailMessage.put(ownerIdIterator, new EmailWrapper(
                    mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).Owner.Email,
                    mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).ASI_CRM_CN_Sys_Approver_2__r.Email,
                    HI
                ));*/

                wrapperPlaceHolder = new EmailWrapper();
                /*
                wrapperPlaceHolder.toEmailAddress = mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).Owner.Email;
                wrapperPlaceHolder.ccEmailAddress =
                    mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).ASI_CRM_CN_Sys_Approver_2__r.Email;
                */
                ASI_TH_CRM_Contract__c firstElement = new List<ASI_TH_CRM_Contract__c>(mapOwnerId_OwnedContracts.get(ownerIdIterator)).get(0);
                wrapperPlaceHolder.toEmailAddress = firstElement.Owner.Email;
                wrapperPlaceHolder.ccEmailAddress =
                    firstElement.ASI_CRM_CN_Sys_Approver_2__r.Email;

                emailHtmlBody = HI;

                // Setting "To" recepient to contract owner
                /*emailPlaceHolder.setToAddresses( new List<String>{
                    mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).Owner.Email
                });

                // Setting "CC" recepient to contract Sys Approver 2
                if(String.isNotBlank(mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).ASI_CRM_CN_Sys_Approver_2__r.Email)) {
                    emailPlaceHolder.setCcAddresses( new List<String>{
                        mapOwnerId_OwnedContracts.get(ownerIdIterator).get(0).ASI_CRM_CN_Sys_Approver_2__r.Email
                    });
                }*/

                // Setting "Subject" of email
                // emailPlaceHolder.setSubject(emailSubject);

                // Generating email body
                emailHtmlBody += firstElement.Owner.Name
                               + COMMA
                               + LINE_BREAK
                               + LINE_BREAK
                               + GREETING
                               + LINE_BREAK
                               + LINE_BREAK;

            } else {
                wrapperPlaceHolder = mapOwnerId_EmailMessage.get(ownerIdIterator);
                emailHtmlBody = wrapperPlaceHolder.emailBody;
            }

            for(ASI_TH_CRM_Contract__c contractIterator : mapOwnerId_OwnedContracts.get(ownerIdIterator)) {

                /* [VL 3.0] BEGIN */
                if (isInEmail.contains(contractIterator.Id)) continue;
                isInEmail.add(contractIterator.Id);
                /* [VL 3.0] END */
                
                recordLink = BASE_URL + contractIterator.Id;
                
                emailHtmlBody += contractIterator.Name
                               + BLANK_SPACE
                               + ANCHOR_START
                               + recordLink
                               + ANCHOR_END
                               + recordLink
                               + ANCHOR_CLOSING_TAG
                               + LINE_BREAK
                               + OUTLET
                               + contractIterator.ASI_CRM_CN_Outlet_WS__r.name
                               + LINE_BREAK
                               + YTD_SALES_VOLUME
                               + contractIterator.ASI_CRM_Till_Date_Sales_Volume_9L__c
                               + LINE_BREAK
                               + YTD_PERCENT_ACHIEVED
                               + contractIterator.ASI_CRM_Till_Date_Sales_Percent_Achieved__c
                               + LINE_BREAK
                               + REPORT_LINK
                               + ANCHOR_START
                               /* [HC 2.0] BEGIN */
                               + String.format(YTD_REPORT_LINK_START, new String[]{userIdMap.get(contractIterator.OwnerId).ASI_OBIEE_Domain__c})
                               /* [HC 2.0] END */
                               + contractIterator.Id
                               + YTD_REPORT_LINK_END
                               + ANCHOR_END
                               + YTD_REPORT_LINK_CLICK_HERE
                               + ANCHOR_CLOSING_TAG
                               + LINE_BREAK
                               + PAYMENT_SCHEDULES_TO_ISSUE
                               + LINE_BREAK;

                if(contractIterator.Payment_Schedules__r != NULL
                && !contractIterator.Payment_Schedules__r.isEmpty()) {

                    /* [HC 1.0] BEGIN */
                    List<ASI_CRM_Payment_Schedule__c> sortedPaymentScheduleList = contractIterator.Payment_Schedules__r;

                    Boolean swapped = true;
                    Integer currentRunTime = 0;
                    ASI_CRM_Payment_Schedule__c tempPaymentSchedule;

                    while(swapped) {

                        swapped = false;
                        currentRunTime += 1;

                        for(Integer i = 0; i < sortedPaymentScheduleList.size() - currentRunTime ; i++) {

              /* [VL 12.0] BEGIN */
              /*
                            Integer percentOfAchievedSalesTarget = 0;
                            Integer nextPercentOfAchievedSalesTarget = 0;
              */
                            Decimal percentOfAchievedSalesTarget = 0;
                            Decimal nextPercentOfAchievedSalesTarget = 0;
              /* [VL 12.0] END */
                            if(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {
                /* [VL 12.0] BEGIN */
                /*
                                percentOfAchievedSalesTarget = Integer.valueOf(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c);
                */
                                percentOfAchievedSalesTarget = Decimal.valueOf(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c);
                /* [VL 12.0] END */

                            }

                            if(sortedPaymentScheduleList[i + 1].ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {

                /* [VL 12.0] BEGIN */
                /*
                                nextPercentOfAchievedSalesTarget = Integer.valueOf(sortedPaymentScheduleList[i + 1].ASI_CRM_Percentof_achieved_Sales_Target__c);
                */
                                nextPercentOfAchievedSalesTarget = Decimal.valueOf(sortedPaymentScheduleList[i + 1].ASI_CRM_Percentof_achieved_Sales_Target__c);
                /* [VL 12.0] END */

                            }

                            if(percentOfAchievedSalesTarget > nextPercentOfAchievedSalesTarget) {

                                tempPaymentSchedule = sortedPaymentScheduleList[i];
                                sortedPaymentScheduleList[i] = sortedPaymentScheduleList[i + 1];
                                sortedPaymentScheduleList[i + 1] = tempPaymentSchedule;
                                swapped = true;

                            }

                        }

                    }

                    for(Integer i = 0; i < sortedPaymentScheduleList.size(); i++) {
                        emailHtmlBody += (i + 1)
                                       + PERIOD;

                        if(sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {

                            emailHtmlBody += sortedPaymentScheduleList[i].ASI_CRM_Percentof_achieved_Sales_Target__c
                                           + PERCENT;

                        } else if(sortedPaymentScheduleList[i].ASI_CRM_Schedule_Date__c != NULL) {

                            Date temp = sortedPaymentScheduleList[i].ASI_CRM_Schedule_Date__c;

                            datePlaceHolder =
                                DateTime.newInstance(temp.year(), temp.month(), temp.day());

                            emailHtmlBody += datePlaceHolder.format(BODY_DATE_FORMAT).toUpperCase()
                                           + S_DOLLAR_SIGN
                                           + sortedPaymentScheduleList[i].ASI_CRM_Sponsorship__c;
                        }
                        emailHtmlBody += LINE_BREAK;
                    }

                    /* [HC 1.0] END */

                } else {
                    emailHtmlBody += NA
                                   + LINE_BREAK;
                }
                emailHtmlBody += LINE_BREAK;
            }
            // emailHtmlBody += THANKS;

            // Setting email body
            // emailPlaceHolder.setHtmlBody(emailHtmlBody);
            wrapperPlaceHolder.emailBody = emailHtmlBody;

            mapOwnerId_EmailMessage.put(ownerIdIterator, wrapperPlaceHolder);
            /* [DC 1.2] END */
        }
    }

    //-4/13/16
    global void execute(SchedulableContext contextInstance) {}

    // Sending out notification emails.
    global void finish(Database.BatchableContext contextInstance) {
        //Wilken 20160902 Check current date requires sending email notification
        
        Boolean sentNotificationAlready = false;
        
        for (ASI_CRM_SG_Notification_Log__c Setting : ASI_CRM_SG_Notification_Log__c.getAll().values()) {
            if (Setting.Name == String.ValueOf(System.Today()) && Setting.ASI_CRM_Sent_Notification__c){
                sentNotificationAlready = true;
            }
        }
        
        if (sentNotificationAlready == false && System.today().day() == monthlyNotificationDate.day()){
            ASI_CRM_SG_Notification_Log__c log = new ASI_CRM_SG_Notification_Log__c(Name = String.ValueOf(System.Today()), ASI_CRM_Sent_Date__c = System.Now(), ASI_CRM_Sent_Notification__c = true);
            insert log;
            
            List<Messaging.SingleEmailMessage> lstEmails_ToSend = new List<Messaging.SingleEmailMessage>();

           // DC - commented out for running test class
           // System.debug('------ HTML BODY ------ : \n\n' + mapOwnerId_EmailMessage.values()[0].emailBody);

            System.debug('------ mapOwnerId_EmailMessage ------ : \n\n' + mapOwnerId_EmailMessage);
			
            try {
                /* [DC 1.2] BEGIN */
                if( !mapOwnerId_EmailMessage.isEmpty() ) {
                    
                    for(Id ownerId : mapOwnerId_EmailMessage.keySet()) {

                        Messaging.SingleEmailMessage emailPlaceHolder = new Messaging.SingleEmailMessage();
                        						
                        emailPlaceHolder.setToAddresses( new List<String> {
                            mapOwnerId_EmailMessage.get(ownerId).toEmailAddress
                        });

                        emailPlaceHolder.setCcAddresses( new List<String> {
                            mapOwnerId_EmailMessage.get(ownerId).ccEmailAddress
                        });

                        emailPlaceHolder.setSubject(emailSubject);

                        emailPlaceHolder.setHtmlBody(
                            mapOwnerId_EmailMessage.get(ownerId).emailBody + THANKS
                        );

                        lstEmails_ToSend.add(emailPlaceHolder);

                    }

                    Messaging.sendEmail(lstEmails_ToSend);
                    system.debug('Email sent!');
                    /* [DC 1.2] END */
                }
            } catch(Exception exceptionInstance) {
                System.debug('------ exceptionInstance ------ : ' + exceptionInstance.getMessage());

                // TODO : Nothing
            }
        }
    
    /* [VL 11.1] BEGIN */
    if (isOfftakeAdjustment){
      sendEmail_offtakeAdjustment(map_ownerId_contracts);
    }
    
    /* [VL 11.1] END */
    }

    /* [DC 1.1] BEGIN */
    /* Wrapper class for holding email related data */
    private class EmailWrapper {
        public String toEmailAddress;
        public String ccEmailAddress;
        public String emailBody;

        public EmailWrapper() {
            toEmailAddress = '';
            ccEmailAddress = '';
            emailBody = '';
        }
    }
    /* [DC 1.1] END */
  
  /* [VL 11.1] BEGIN */
  private void sendEmail_offtakeAdjustment(Map<string, list<ASI_TH_CRM_Contract__c>> map_ownerId_contracts){
    List<string> list_userId = new List<string>();
    List<string> list_email_cc = new List<string>();
    List<Messaging.SingleEmailMessage> lstEmails_ToSend = new List<Messaging.SingleEmailMessage>();
    
    List<GroupMember> viewGroupList = [SELECT groupID, userOrGroupID FROM groupMember 
      WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_CRM_SG_Offtake_Notification_Group')];
      
	/*[WL 13.0] BEGIN*/
		string fromAddressId;
		list<OrgWideEmailAddress> fromAddress = [select Id from OrgWideEmailAddress where Address = 'pra.sfdcitsupport@pernod-ricard.com' limit 1];
	/*[WL 13.0] END*/ 
	
	if(fromAddress.size()>0){
		fromAddressId = fromAddress[0].Id;
	}
			
    for (GroupMember u:viewGroupList){
      list_userId.add(u.userOrGroupID);
    }
    
    for (user u : [select email from user where id in :list_userId]){
      list_email_cc.add(u.email);
    }
    
    for (string ownerId : map_ownerId_contracts.keySet()){
		List<ASI_TH_CRM_Contract__c> list_c = map_ownerId_contracts.get(ownerId);
		String contractIds = '';
		String ownerEmail = list_c[0].owner.email;
		String ownerName = list_c[0].owner.name;
		for (ASI_TH_CRM_Contract__c c : list_c){
			contractIds += c.Id + ',';
		}
			contractIds = contractIds.subString(0, contractIds.length()-1);
		  
			PageReference pdf = Page.ASI_CRM_SG_OfftakeChangeEmailPage;
			pdf.getParameters().put('id',contractIds);
			blob b ;
				if (!Test.isRunningTest()) b = pdf.getContentAsPdf();
					else b = null;
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
			efa1.setFileName('Offtake Adjustment.pdf');
			efa1.setContentType('application/pdf');
			efa1.setBody(b);
			String addresses;
			String subject = this.specificOutletName == null ? 
						'Completed SG Offtakes link to outlets'/* +String.valueOf(DateTime.now().format())*/ :
						'Completed SG Offtakes link to outlet ' +this.specificOutletName/* + ' at ' +String.valueOf(DateTime.now().format())*/;
			email.setSubject(subject);
			email.setToAddresses( new List<String> {
						ownerEmail 
					  } );
			email.setCCAddresses(list_email_cc);
			  
			/*[WL 13.0] BEGIN*/
			if(fromAddressId != null) email.setOrgWideEmailAddressId(fromAddressId);
			/*[WL 13.0] END*/
			  
			string htmlBody = 'Hi ' + ownerName + ',<br/><br/>';
			htmlBody += /*totalOfftakeAdjusted + ' out of ' + totalOfftakeProceed + */' Offtakes have been linked to your outlets. Please be ready to issue FOC / Payment.';
			email.setHtmlBody(htmlBody);
			email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
			lstEmails_ToSend.add(email);
		}
		if (!Test.isRunningTest()) Messaging.sendEmail(lstEmails_ToSend);
    
  }
  /* [VL 11.1] END */
  
  /* [VL 8.0] BEGIN */
  /*********************************************************************************
     * Description: Get the mapping of sku
     *
     * Return: SKU Mapping contain the SKU Id and the newest SKU Id
    *********************************************************************************/
    private Map<Id, Id> getSKUMapping() {
        Map<Id, Id> skuMappingMap = new Map<Id, Id>();

        Id sgSKUMappingRecordType = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping');

        for(ASI_CRM_SKU_Mapping__c skuMapping : [SELECT ASI_CRM_SKU__c, ASI_CRM_New_SKU__c 
                                                 FROM ASI_CRM_SKU_Mapping__c
                                                 WHERE RecordTypeId = :sgSKUMappingRecordType]) {

            skuMappingMap.put(skuMapping.ASI_CRM_SKU__c, skuMapping.ASI_CRM_New_SKU__c);

        }

        for(Id skuId : skuMappingMap.keySet()) {

            Id tempSKUId = skuMappingMap.get(skuId);

            while(skuMappingMap.containsKey(tempSKUId)) {

                tempSKUId = skuMappingMap.get(tempSKUId);

            }

            skuMappingMap.put(skuId, tempSKUId);

        }
    
    for(Id skuId : skuMappingMap.values()) {
            skuMappingMap.put(skuId, skuId);
        }

        return skuMappingMap;
    }
  /* [VL 8.0] END */
}