/*********************************************************************************
* Name:ASI_CRM_SG_CreditNote_TriggerClass 
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2017-07-12       Wilken Lee              Created
* 2020-04-02       Ceterna                 Created : UpdateMonthYearBeforeInsert / ValidatePreviousMonthCreditNote
* 2020-10-16       Wilken Lee              [WL 1.0] Default "Reason" field for JDE Explanation Remark field mapping
* 2020-10-16       Wilken Lee              [WL 2.0] Allow delete credit note if it is void
* 2020-12-07       Wilken Lee              [WL 3.0] Exclude STK2 Item (Free goods from advance pricing) from calculating rebate
* 2020-12-06       Ceterna                 [Ceterna Dec 2020 v1.0] - Change Order by Name to ASI_HK_CRM_Order_No__c
* 2020-12-07       Ceterna                 [Ceterna Dec 2020 V1.0] Commented delete header for debit Note
*********************************************************************************/

public class ASI_CRM_SG_CreditNote_TriggerClass{
    
    public static void retrieveExchangeRate(List<ASI_CRM_Credit_Debit_Note__c> cNoteList , Map<ID, ASI_CRM_Credit_Debit_Note__c> oldMap) {
        List<String> currencyList = new List<String>();
        
        for (ASI_CRM_Credit_Debit_Note__c cNote : cNoteList ){
            currencyList.add(cNote.ASI_CRM_Currency__c);                        
        }
        
        List<ASI_MFM_Exchange_Rate__c> exRateList = [select id, ASI_MFM_Exchange_Rate__c, ASI_MFM_Counter_Currency__c from ASI_MFM_Exchange_Rate__c 
                                                     where ASI_MFM_Country__c = 'SG' and ASI_MFM_Effective_Date__c <= :System.Today() and ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c = 'SGD'
                                                     and ASI_MFM_Counter_Currency__c in :currencyList order by ASI_MFM_Effective_Date__c desc];
        
        for (ASI_CRM_Credit_Debit_Note__c cNote : cNoteList ){
            if (oldMap == null || cNote.ASI_CRM_Currency__c != oldMap.get(cNote.Id).ASI_CRM_Currency__c)
                for (ASI_MFM_Exchange_Rate__c exRate:exRateList){
                    if (exRate.ASI_MFM_Counter_Currency__c == cNote.ASI_CRM_Currency__c){
                        cNote.ASI_CRM_Exchange_Rate__c = exRate.ASI_MFM_Exchange_Rate__c;
                        break;
                    }                   
                }
        }       
    }
    
    public static void calculateGST(List<ASI_CRM_Credit_Debit_Note__c> cNoteList , Map<ID, ASI_CRM_Credit_Debit_Note__c> oldMap) {
        Set<String> taxCodeSet = new Set<String>{'SG3','CA3','IC3','IN3','LA3','MM3','MY3','PH3'};
            
            for (ASI_CRM_Credit_Debit_Note__c cNote : cNoteList ){
                system.debug('Need GST: ' + taxCodeSet.contains(cNote.ASI_CRM_Tax_Rate_Area__c));
                if (taxCodeSet.contains(cNote.ASI_CRM_Tax_Rate_Area__c))
                    cNote.ASI_CRM_GST__c = cNote.ASI_CRM_Total_Actual_Amount__c * 0.07;
                else 
                    cNote.ASI_CRM_GST__c = 0;
            }       
    }
    
    public static void validateGLDateChange(List<ASI_CRM_Credit_Debit_Note__c> cNoteList , Map<ID, ASI_CRM_Credit_Debit_Note__c> oldMap) {
        List<GroupMember> gmList = [SELECT UserOrGroupId From GroupMember where GroupID in (Select ID from Group where DeveloperName = 'ASI_CRM_SG_Finance_Verify_Share')];
        Boolean isFinanceUser = false;
        
        for (GroupMember gm:gmList){
            if (UserInfo.getUserId() == gm.UserOrGroupId)
                isFinanceUser = true;
        }
        
        for (ASI_CRM_Credit_Debit_Note__c cNote : cNoteList ){
            if (oldMap != null && oldMap.get(cNote.Id).ASI_CRM_GL_Date__c != null && cNote.ASI_CRM_GL_Date__c != oldMap.get(cNote.Id).ASI_CRM_GL_Date__c){
                if (cNote.ASI_CRM_Sync_To_JDE__c || !isFinanceUser)
                    cNote.addError('GL Date cannot be changed');
            }
        }       
    }
    
    public static void validationBeforeDelete(List<ASI_CRM_Credit_Debit_Note__c> cNoteList) {
        for (ASI_CRM_Credit_Debit_Note__c cNote : cNoteList ){
            if (cNote.ASI_CRM_Status__c != 'Draft' && cNote.ASI_CRM_Status__c != 'Rejected'
                && cNote.ASI_CRM_Status__c != 'Void')   //WL 2.0
                cNote.addError('Only Draft/Rejected/Void Credit/Debit Note can be deleted. Credit Noe Number: ' + cNote.Name);
        }
    }
    
    //2020-04-17 Ceterna
    public static void UpdateStartEndDateFWOBeforeInsert(list<ASI_CRM_Credit_Debit_Note__c> trigger_new){
        system.debug('@#@#');
        Map<Id,ASI_CRM_Credit_Debit_Note__c> fwoPeriodMap ;
        Set<Id> fwoPeriodId = new Set<Id>();
        for(ASI_CRM_Credit_Debit_Note__c creditNote :trigger_new){
            system.debug('@#@#'+creditNote.ASI_CRM_SG_FWO_Period__c);
            if(creditNote.ASI_CRM_SG_FWO_Period__c != null){
                fwoPeriodId.add(creditNote.ASI_CRM_SG_FWO_Period__c);
            }
        }
        if(fwoPeriodId != null && fwoPeriodId.size()>0){
            fwoPeriodMap = new Map<Id,ASI_CRM_Credit_Debit_Note__c>([Select Id, ASI_CRM_SG_FWO_Start_Date__c, ASI_CRM_SG_FWO_End_Date__c from ASI_CRM_Credit_Debit_Note__c
                                                                     where Id IN : fwoPeriodId]);
        }
        if(fwoPeriodMap != null && fwoPeriodMap.keySet().size()>0){
            for (ASI_CRM_Credit_Debit_Note__c creditNote :trigger_new){
                if(fwoPeriodMap != null && creditNote.ASI_CRM_SG_FWO_Period__c != null && fwoPeriodMap.containsKey(creditNote.ASI_CRM_SG_FWO_Period__c)){
                    creditNote.ASI_CRM_SG_FWO_Start_Date__c = fwoPeriodMap.get(creditNote.ASI_CRM_SG_FWO_Period__c).ASI_CRM_SG_FWO_Start_Date__c ;
                    creditNote.ASI_CRM_SG_FWO_End_Date__c = fwoPeriodMap.get(creditNote.ASI_CRM_SG_FWO_Period__c).ASI_CRM_SG_FWO_End_Date__c ;
                    
                }
            }
        }
        
    }
    
    //2020-0402 Ceterna - Update Month/Year field before insert credit notes for FWO Period Record Type
    public static void UpdateMonthYearBeforeInsert(list<ASI_CRM_Credit_Debit_Note__c> trigger_new) {
        
        for (ASI_CRM_Credit_Debit_Note__c creditNote :trigger_new){
            DateTime d = DateTime.newInstance(creditNote.ASI_CRM_SG_FWO_Start_Date__c, Time.newInstance(0,0,0,0));
            creditNote.ASI_CRM_SG_Month_Year__c = d.format('YYYY-MM');
         //   creditNote.ASI_CRM_SG_Month_Year__c = String.valueOf(creditNote.ASI_CRM_SG_FWO_Start_Date__c.Month())+
           //     String.valueOf(creditNote.ASI_CRM_SG_FWO_Start_Date__c.Year());
        }
    }
    
    //2020-0402 Ceterna - Validate If Previous Month Credit Notes Exist
    public static void ValidatePreviousMonthCreditNote(list<ASI_CRM_Credit_Debit_Note__c> trigger_new) {  
        Set<String> rebateTypeSet = new Set<String>();
        for(ASI_CRM_Credit_Debit_Note__c credit : trigger_new){
            if(credit.ASI_CRM_SG_Rebate_Type__c != null){
                rebateTypeSet.add(credit.ASI_CRM_SG_Rebate_Type__c);
            }
        }
        if(rebateTypeSet.size()>0){
            List<ASI_CRM_Credit_Debit_Note__c> previous_CreditNotesList = [Select id, ASI_CRM_SG_First_Calendar_Day_of_FWO__c,ASI_CRM_SG_Rebate_Type__c , ASI_CRM_SG_Month_Year__c From ASI_CRM_Credit_Debit_Note__c where recordType.developername = 'ASI_CRM_SG_Wholesaler_FWO_Period' and ASI_CRM_SG_Rebate_Type__c in : rebateTypeSet];
            
            If (previous_CreditNotesList.size() !=0){
                Map<String, ASI_CRM_Credit_Debit_Note__c> previous_CreditNotesMap = new Map<String, ASI_CRM_Credit_Debit_Note__c>();
                for (ASI_CRM_Credit_Debit_Note__c prev_CreditNotes : previous_CreditNotesList){
                    String key = prev_CreditNotes.ASI_CRM_SG_First_Calendar_Day_of_FWO__c+'#'+prev_CreditNotes.ASI_CRM_SG_Rebate_Type__c;
                    previous_CreditNotesMap.put(key,prev_CreditNotes);            
                }
                
                for (ASI_CRM_Credit_Debit_Note__c creditNote :trigger_new){
                    if (previous_CreditNotesMap.get(creditNote.ASI_CRM_x1st_Cal_Previous_FWO_Start_Date__c+'#'+creditNote.ASI_CRM_SG_Rebate_Type__c) == null){
                        creditNote.addError('You need to make sure there are no missed months for Credit Note.');
                    } else {
                        creditNote.ASI_CRM_SG_Previous_Month_Exist__c = true;
                    }
                }
            }
            
        }
    }
    //Create Credit Notes Items
    public static void CreateCreditNoteItemDetail (List<ASI_CRM_Credit_Debit_Note__c> trigger_new, Boolean isBatch, Boolean notUseRebateType) {
        
        //Id recordTypeId = Schema.SObjectType.ASI_CRM_SG_Credit_Note_Item_Detail__c.getRecordTypeInfosByName().get('ASI_CRM_SG_Credit_Note_Item_Detail').getRecordTypeId();        
        for (ASI_CRM_Credit_Debit_Note__c creditNote : trigger_new){
            List<ASI_CRM_SG_Credit_Note_Item_Detail__c> allItemDetails = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();
            
            if ((creditNote.ASI_CRM_SG_Rebate_Type__c == 'FWO' 
                 || creditNote.ASI_CRM_SG_Rebate_Type__c == 'Portfolio' 
                 || creditNote.ASI_CRM_SG_Rebate_Type__c == 'Bottle') || notUseRebateType) 
            {
                if (Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')){
                    List<ASI_HK_CRM_Sales_Order_History__c> salesOrderHistory_List = new List<ASI_HK_CRM_Sales_Order_History__c>();
                    //[Ceterna Dec 2020 V1.0] - Change Order by Name to ASI_HK_CRM_Order_No__c
                    salesOrderHistory_List = [SELECT id, Name, ASI_HK_CRM_Order_Date__c,ASI_HK_CRM_Order_No__c, ASI_CRM_G_L_Date__c, ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c
                                                                                      FROM ASI_HK_CRM_Sales_Order_History__c
                                                                                      WHERE ASI_CRM_G_L_Date__c >=: creditNote.ASI_CRM_SG_FWO_Start_Date__c 
                                                                                      AND ASI_CRM_G_L_Date__c <=:creditNote.ASI_CRM_SG_FWO_End_Date__c 
                                                                                      AND ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c = :creditNote.ASI_CRM_Wholesaler__c 
                                                                                      order BY ASI_CRM_G_L_Date__c ASC, ASI_HK_CRM_Order_No__c ASC];

                   
                    if (salesOrderHistory_List!=null && salesOrderHistory_List.size() > 0){
                        
                        system.debug('@#@#'+salesOrderHistory_List);
                        Set<String> salesOrderHistory_List_first2 = new Set<String>();
                        if(salesOrderHistory_List.size() > 0) {
                            salesOrderHistory_List_first2.add(salesOrderHistory_List[0].Id);
                        }
                        if(salesOrderHistory_List.size() > 1) {
                            salesOrderHistory_List_first2.add(salesOrderHistory_List[1].Id);
                        }
                        if(creditNote.ASI_CRM_SG_Rebate_Type__c == 'Portfolio'){
                            //[Ceterna Dec 2020 V1.0] - Change Order by Name to ASI_HK_CRM_Order_No__c
                        salesOrderHistory_List = [SELECT id, Name, ASI_HK_CRM_Order_Date__c, ASI_CRM_G_L_Date__c, ASI_HK_CRM_Order_No__c, ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c
                                                                                      FROM ASI_HK_CRM_Sales_Order_History__c
                                                                                      WHERE CALENDAR_MONTH(ASI_CRM_G_L_Date__c) =: creditNote.ASI_CRM_SG_FWO_End_Date__c.month()
                                                                                      AND ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c = :creditNote.ASI_CRM_Wholesaler__c 
                                                                                      order BY ASI_CRM_G_L_Date__c ASC, ASI_HK_CRM_Order_No__c ASC];
                    }
                    
                        List<ASI_CRM_SG_Credit_Note_Item_Detail__c> fwoItemDetailList = Create_FWO_Portfolio_Rebate_CreditNotes(creditNote, salesOrderHistory_List, salesOrderHistory_List_first2);
                        if(fwoItemDetailList != null && fwoItemDetailList.size()>0){
                            allItemDetails.addAll(fwoItemDetailList);
                        } 
                    } else {
                        System.debug('CreateCreditNoteItemDetail: No Sales Order History Record Found');
                    }    
                }
            }    
            
            if (creditNote.ASI_CRM_SG_Rebate_Type__c == 'OOM' || notUseRebateType) {
                List<ASI_CRM_SG_Credit_Note_Item_Detail__c> oomItemDetailList ;
                if (Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')
                    ||Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note'))
                {
                    oomItemDetailList = Create_OOM_Rebate_Credit_Debit_Notes(creditNote);
                    if(oomItemDetailList != null && oomItemDetailList.size()>0){
                        allItemDetails.addAll(oomItemDetailList);
                    }
                }
            }    
            
            // INSERT ASI_CRM_SG_Credit_Note_Item_Detail__c
            if(allItemDetails != null && allItemDetails.size()>0){
                insert allItemDetails;
            }
        }
        
        List<String> debitNoteIds = new List<String>();
        List<String> creditNoteIds = new List<String>();
        for(ASI_CRM_Credit_Debit_Note__c creditNote :trigger_new){
            
            if (Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note')) {
                debitNoteIds.add(creditNote.Id);
            }
            system.debug(LoggingLevel.error,'@#debugisBatch'+isBatch);
            system.debug(LoggingLevel.error,'@#debugisBatch1'+Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName);
            if(!isBatch && Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')){
                creditNoteIds.add(creditNote.Id);
            }
        }
        
        if(debitNoteIds.size()>0){
            deleteCreditDebitLineItems(debitNoteIds);
            /* [Ceterna Dec 2020 V1.0] Commented delete header for debit Note*/
           // deleteCreditDebitNotes(debitNoteIds);
        }
        if(creditNoteIds.size()>0){
            deleteCreditDebitLineItems(creditNoteIds);
        }
    }
    
    public static List <ASI_CRM_SG_Credit_Note_Item_Detail__c> Create_FWO_Portfolio_Rebate_CreditNotes (ASI_CRM_Credit_Debit_Note__c creditNote, 
                                                                                                        List<ASI_HK_CRM_Sales_Order_History__c> salesOrderHistory_List,
                                                                                                        Set<String> salesOrderHistory_List_first2) 
    {
        List <ASI_CRM_SG_Credit_Note_Item_Detail__c> newFWO_Portfolio_CreditNoteItemDetail_List = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();        
        List <ASI_HK_CRM_Sales_Order_History_Detail__c> updateSOHistoryDetail_List = new List <ASI_HK_CRM_Sales_Order_History_Detail__c>();
        List <ASI_HK_CRM_Sales_Order_History__c> ascending_SalesOrderHistory_List = new List <ASI_HK_CRM_Sales_Order_History__c>(); 
        Integer checkDateOrder = 0;
        
        Set<String> sohIdList = new Set<String>();
        for (ASI_HK_CRM_Sales_Order_History__c  SOH : salesOrderHistory_List){
            sohIdList.add(soh.Id);
        }
        Id recordTypeId = Schema.SObjectType.ASI_CRM_SG_Credit_Note_Item_Detail__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Credit_Note_Item_Detail').getRecordTypeId();  

        List<ASI_HK_CRM_Sales_Order_History_Detail__c> salesOrderHistoryDetail_List = new List<ASI_HK_CRM_Sales_Order_History_Detail__c>();
            salesOrderHistoryDetail_List = [SELECT id, ASI_HK_CRM_Sales_Order_History__c, 
                                                                                       ASI_CRM_SG_Credit_Note_Status__c, ASI_HK_CRM_Product_SKU__c, ASI_CRM_SG_FWO_Rebate__c, 
                                                                                       ASI_CRM_SG_Portfolio_Rebate__c, ASI_CRM_SG_Credit_Note_Portfolio_Created__c,
                                                                                       ASI_CRM_SG_Bottle_Rebate__c, ASI_CRM_SG_Credit_Note_Bottle_Created__c,
                                                                                        ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c,
                                                                                       ASI_HK_CRM_Quantity_in_Bottles__c,
                                                                                      ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SG_Product_Grouping__c,
                                                                                        ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SGComplimentary_Product_Grouping__c
                                                                                       FROM ASI_HK_CRM_Sales_Order_History_Detail__c
                                                                                       WHERE ASI_CRM_SG_Credit_Note_Status__c = 'Required' 
                                                                                        AND ASI_CRM_AG_Code__c != 'STK2' //WL 3.0                                        
                                                                                       AND ASI_CRM_SG_Create_Credit_Note_Checkbox__c = true
                                                                                       AND ASI_HK_CRM_Sales_Order_History__c IN :sohIdList];             
       
        Map<String, Decimal> fwoItemGroupAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> PortfolioItemGroupAmountMap = new Map<String,Decimal>();
        if(creditNote.ASI_CRM_SG_Rebate_Type__c == 'FWO'){
          List<ASI_HK_CRM_Sales_Order_History_Detail__c>  salesOrderHistoryDetailfirst2_List = [SELECT id, ASI_HK_CRM_Sales_Order_History__c, 
                                                                                       ASI_CRM_SG_Credit_Note_Status__c, ASI_HK_CRM_Product_SKU__c, ASI_CRM_SG_FWO_Rebate__c, 
                                                                                       ASI_CRM_SG_Portfolio_Rebate__c, ASI_CRM_SG_Credit_Note_Portfolio_Created__c,
                                                                                       ASI_CRM_SG_Bottle_Rebate__c, ASI_CRM_SG_Credit_Note_Bottle_Created__c,
                                                                                        ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c,
                                                                                       ASI_HK_CRM_Quantity_in_Bottles__c
                                                                                       FROM ASI_HK_CRM_Sales_Order_History_Detail__c
                                                                                       WHERE ASI_CRM_SG_Credit_Note_Status__c = 'Required' 
                                                                                        AND ASI_CRM_AG_Code__c != 'STK2' //WL 3.0                            
                                                                                       AND ASI_CRM_SG_Create_Credit_Note_Checkbox__c = true
                                                                                       AND ASI_HK_CRM_Sales_Order_History__c IN :salesOrderHistory_List_first2]; 
            for (ASI_HK_CRM_Sales_Order_History_Detail__c eachSOHistoryDetail :salesOrderHistoryDetailfirst2_List){
                   Decimal tempTotal = 0 ;
                    if(fwoItemGroupAmountMap.containsKey(eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c)){
                        tempTotal = fwoItemGroupAmountMap.get(eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c);
                    }
                    tempTotal += eachSOHistoryDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
                    fwoItemGroupAmountMap.put(eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c,tempTotal);
                }
        }
        if(creditNote.ASI_CRM_SG_Rebate_Type__c == 'Portfolio'){
            Map<String,String> portfolioRebateMap = new Map<String,String>();

            for (ASI_HK_CRM_Sales_Order_History_Detail__c eachSOHistoryDetail :salesOrderHistoryDetail_List){
                if(eachSOHistoryDetail.ASI_CRM_SG_Portfolio_Rebate__c != null){
                    portfolioRebateMap.put(eachSOHistoryDetail.ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SG_Product_Grouping__c,eachSOHistoryDetail.ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SGComplimentary_Product_Grouping__c);
                }
            }
            List<ASI_HK_CRM_Sales_Order_History_Detail__c>  pfsalesOrderHistoryDetailfirst2_List = [SELECT id, ASI_HK_CRM_Sales_Order_History__c, 
                                                                                       ASI_CRM_SG_Credit_Note_Status__c, ASI_HK_CRM_Product_SKU__c, ASI_CRM_SG_FWO_Rebate__c, 
                                                                                       ASI_CRM_SG_Portfolio_Rebate__c, ASI_CRM_SG_Credit_Note_Portfolio_Created__c,
                                                                                       ASI_CRM_SG_Bottle_Rebate__c, ASI_CRM_SG_Credit_Note_Bottle_Created__c,
                                                                                        ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c,
                                                                                       ASI_HK_CRM_Quantity_in_Bottles__c,
                                                                                      ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SG_Product_Grouping__c,
                                                                                        ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SGComplimentary_Product_Grouping__c
                                                                                       FROM ASI_HK_CRM_Sales_Order_History_Detail__c
                                                                                       WHERE ASI_CRM_SG_Credit_Note_Status__c = 'Required' 
                                                                                        AND ASI_CRM_AG_Code__c != 'STK2' //WL 3.0                                        
                                                                                       AND ASI_CRM_SG_Create_Credit_Note_Checkbox__c = true
                                                                                       AND ASI_HK_CRM_Sales_Order_History__c IN :salesOrderHistory_List_first2];             
            for(String itemGroup : portfolioRebateMap.keySet()){
                for(ASI_HK_CRM_Sales_Order_History_Detail__c eachSOHistoryDetail :pfsalesOrderHistoryDetailfirst2_List){
                    if(portfolioRebateMap.containsKey(itemGroup) && eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c == portfolioRebateMap.get(itemGroup)){
                        Decimal tempTotalAmount = 0;
                        if(PortfolioItemGroupAmountMap.containsKey(itemGroup)){
                            tempTotalAmount = PortfolioItemGroupAmountMap.get(itemGroup);
                        }
                        tempTotalAmount += eachSOHistoryDetail.ASI_HK_CRM_Quantity_in_Bottles__c;
                        PortfolioItemGroupAmountMap.put(itemGroup,tempTotalAmount);
                    }
                }
            }
        }
        
        
        for (ASI_HK_CRM_Sales_Order_History__c parentSOHistory : salesOrderHistory_List) {
            for (ASI_HK_CRM_Sales_Order_History_Detail__c eachSOHistoryDetail :salesOrderHistoryDetail_List){
                
                if (eachSOHistoryDetail.ASI_HK_CRM_Sales_Order_History__c == parentSOHistory.id 
                    && parentSOHistory.ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c == creditNote.ASI_CRM_Wholesaler__c){ 
                        if(creditNote.ASI_CRM_SG_Rebate_Type__c == 'FWO'){
                            eachSOHistoryDetail.ASI_CRM_SG_Credit_Note_FWO_Created__c = TRUE; 
                            if(eachSOHistoryDetail.ASI_CRM_SG_FWO_Rebate__c != null 
                               && salesOrderHistory_List_first2.contains(eachSOHistoryDetail.ASI_HK_CRM_Sales_Order_History__c)){
                                   ASI_CRM_SG_Credit_Note_Item_Detail__c newFWOCreditNoteDetail = new ASI_CRM_SG_Credit_Note_Item_Detail__c();
                                   newFWOCreditNoteDetail.ASI_CRM_SG_Sales_Order_History_Detail__c = eachSOHistoryDetail.id;
                                   newFWOCreditNoteDetail.ASI_CRM_SG_Credit_Debit_Note__c = creditNote.id;
                                   newFWOCreditNoteDetail.ASI_CRM_SG_Rebate_Type__c ='FWO';
                                   newFWOCreditNoteDetail.ASI_CRM_SG_Total_Quantity_SOH__c = fwoItemGroupAmountMap.get(eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__r.ASI_MFM_Item_Group__c);
                                   newFWOCreditNoteDetail.ASI_CRM_SG_SKU__c = eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__c;
                                   newFWOCreditNoteDetail.RecordTypeId = recordTypeId;
                                   newFWO_Portfolio_CreditNoteItemDetail_List.add(newFWOCreditNoteDetail);
                               }
                        }
                        if(creditNote.ASI_CRM_SG_Rebate_Type__c == 'Portfolio'){
                            eachSOHistoryDetail.ASI_CRM_SG_Credit_Note_Portfolio_Created__c = TRUE;
                            if(eachSOHistoryDetail.ASI_CRM_SG_Portfolio_Rebate__c != null 
                              /* && salesOrderHistory_List_first2.contains(eachSOHistoryDetail.ASI_HK_CRM_Sales_Order_History__c)*/){
                                   ASI_CRM_SG_Credit_Note_Item_Detail__c newPortfolioCreditNoteDetail = new ASI_CRM_SG_Credit_Note_Item_Detail__c();
                                   newPortfolioCreditNoteDetail.ASI_CRM_SG_Sales_Order_History_Detail__c = eachSOHistoryDetail.id;
                                   newPortfolioCreditNoteDetail.ASI_CRM_SG_Credit_Debit_Note__c = creditNote.id;
                                   newPortfolioCreditNoteDetail.ASI_CRM_SG_Rebate_Type__c ='Portfolio';
                                   newPortfolioCreditNoteDetail.ASI_CRM_SG_SKU__c = eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__c;
                                   newPortfolioCreditNoteDetail.ASI_CRM_SG_Total_Quantity_SOH__c =  PortfolioItemGroupAmountMap.get(eachSOHistoryDetail.ASI_CRM_SG_Portfolio_Rebate__r.ASI_CRM_SG_Product_Grouping__c);
                                   newPortfolioCreditNoteDetail.RecordTypeId = recordTypeId;
                                   newFWO_Portfolio_CreditNoteItemDetail_List.add(newPortfolioCreditNoteDetail);
                               }
                        }
                        
                        If ( creditNote.ASI_CRM_SG_Rebate_Type__c == 'Bottle') 
                        {
                            eachSOHistoryDetail.ASI_CRM_SG_Credit_Note_Bottle_Created__c = TRUE; 
                            if(eachSOHistoryDetail.ASI_CRM_SG_Bottle_Rebate__c != null){
                                ASI_CRM_SG_Credit_Note_Item_Detail__c newBottleCreditNoteDetail = new ASI_CRM_SG_Credit_Note_Item_Detail__c();
                                newBottleCreditNoteDetail.ASI_CRM_SG_Sales_Order_History_Detail__c = eachSOHistoryDetail.id;
                                newBottleCreditNoteDetail.ASI_CRM_SG_Credit_Debit_Note__c = creditNote.id;
                                newBottleCreditNoteDetail.ASI_CRM_SG_Rebate_Type__c ='Bottle';
                                newBottleCreditNoteDetail.ASI_CRM_SG_SKU__c = eachSOHistoryDetail.ASI_HK_CRM_Product_SKU__c;
                                newBottleCreditNoteDetail.RecordTypeId = recordTypeId;
                                newFWO_Portfolio_CreditNoteItemDetail_List.add(newBottleCreditNoteDetail);
                                
                            }
                        }
                        
                        
                        updateSOHistoryDetail_List.add(eachSOHistoryDetail);
                    }
            }
        }
        
        try{
            system.debug('@#sohh'+updateSOHistoryDetail_List);
            Update updateSOHistoryDetail_List;
            return newFWO_Portfolio_CreditNoteItemDetail_List;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }
    
    public static List <ASI_CRM_SG_Credit_Note_Item_Detail__c> Create_OOM_Rebate_Credit_Debit_Notes(ASI_CRM_Credit_Debit_Note__c creditNote) {
        Id recordTypeId = Schema.SObjectType.ASI_CRM_SG_Credit_Note_Item_Detail__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Credit_Note_Item_Detail').getRecordTypeId();
        List <ASI_CRM_SG_Credit_Note_Item_Detail__c> new_OOM_CreditNoteItemDetail_List = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();        
        List <ASI_TH_CRM_Actual_Offtake__c> updateActualOfftake_List = new List <ASI_TH_CRM_Actual_Offtake__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftake_List ;
        
        system.debug('@#'+creditNote.Id+'@#'+creditNote.RecordTypeId);
        if(Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note')){
            actualOfftake_List = [Select Id, ASI_CRM_SG_Credit_Note_Status__c, ASI_CRM_SKU__c, ASI_CRM_SG_OOM_Rebate__c,
                                  ASI_CRM_SG_Credit_Note_OOM_Created__c,ASI_CRM_FromWS__c
                                  From ASI_TH_CRM_Actual_Offtake__c
                                  Where ASI_CRM_SG_Debit_Note_Status__c = 'Required' and 
                                  ASI_CRM_FromWS__c = :creditNote.ASI_CRM_Wholesaler__c
                                  AND ASI_CRM_SG_OOM_Rebate__c != null
                                 ];
        } else {
            actualOfftake_List = [Select Id, ASI_CRM_SG_Credit_Note_Status__c, ASI_CRM_SKU__c, ASI_CRM_SG_OOM_Rebate__c,
                                  ASI_CRM_SG_Credit_Note_OOM_Created__c,ASI_CRM_FromWS__c
                                  From ASI_TH_CRM_Actual_Offtake__c
                                  Where ASI_CRM_SG_Credit_Note_Status__c = 'Required'
                                  and  ASI_CRM_FromWS__c = :creditNote.ASI_CRM_Wholesaler__c
                                  AND ASI_TH_CRM_Month__c =: String.valueOf(creditNote.ASI_CRM_SG_FWO_Start_Date__c.month())
                                  AND ASI_CRM_SG_OOM_Rebate__c != null
                                  AND ASI_TH_CRM_Year__c =: String.valueOf(creditNote.ASI_CRM_SG_FWO_Start_Date__c.Year())];
        }
        
        if (actualOfftake_List != null && actualOfftake_List.size()>0){
            for (ASI_TH_CRM_Actual_Offtake__c eachActualOfftake :actualOfftake_List){ 
                if (eachActualOfftake.ASI_CRM_FromWS__c == creditNote.ASI_CRM_Wholesaler__c){
                    if (eachActualOfftake.ASI_CRM_SG_OOM_Rebate__c != null){
                        ASI_CRM_SG_Credit_Note_Item_Detail__c newOOMCreditNoteDetail = new ASI_CRM_SG_Credit_Note_Item_Detail__c();
                        if (Global_RecordTypeCache.getRt(creditNote.recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note')){                        
                            newOOMCreditNoteDetail.ASI_CRM_SG_Actual_Offtake_Debit_Note__c =eachActualOfftake.id; 
                            eachActualOfftake.ASI_CRM_SG_Debit_Note_Status__c = 'Issued';
                        } else {
                            newOOMCreditNoteDetail.ASI_CRM_SG_Actual_Offtake__c = eachActualOfftake.id;
                            eachActualOfftake.ASI_CRM_SG_Credit_Note_Status__c = 'Issued';  
                        }
                        newOOMCreditNoteDetail.ASI_CRM_SG_Credit_Debit_Note__c = creditNote.id;
                        //newOOMCreditNoteDetail.CurrencyIsoCode = creditNote.ASI_CRM_Currency__c;
                        newOOMCreditNoteDetail.ASI_CRM_SG_Rebate_Type__c ='OOM';
                        newOOMCreditNoteDetail.ASI_CRM_SG_SKU__c = eachActualOfftake.ASI_CRM_SKU__c;
                        newOOMCreditNoteDetail.RecordTypeId = recordTypeId;
                        new_OOM_CreditNoteItemDetail_List.add(newOOMCreditNoteDetail);
                        eachActualOfftake.ASI_CRM_SG_Credit_Note_OOM_Created__c = true; 
                    }
                    updateActualOfftake_List.add(eachActualOfftake);    
                }
            }
        }
        
        try {
            Update updateActualOfftake_List;
            return new_OOM_CreditNoteItemDetail_List;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    
    /*[WL 1.0] BEGIN*/
    private static String getCreditNoteReason(Date rebateStartDate, String rebateType){
        String reason;
        Switch on rebateStartDate.Month(){  
            when 1 {reason = 'JAN ';}
            when 2 {reason = 'FEB ';}
            when 3 {reason = 'MAR ';}
            when 4 {reason = 'APR ';}
            when 5 {reason = 'MAY ';}
            when 6 {reason = 'JUN ';}
            when 7 {reason = 'JUL ';}
            when 8 {reason = 'AUG ';}
            when 9 {reason = 'SEP ';}
            when 10 {reason = 'OCT ';}
            when 11 {reason = 'NOV ';}
            when 12 {reason = 'DEC ';}
            when else {reason = '';}
        }
        
        reason += String.ValueOf(rebateStartDate.Year()) + ' ' +  rebateType + ' Rebate';
        return reason;
    }
    /*[WL 1.0] END*/
    
    //2020-04-29 Ceterna - Create CreditNote from FWO
    public static void createFWOCreditNote (List<ASI_CRM_Credit_Debit_Note__c> newList){
        List<ASI_CRM_Credit_Debit_Note__c> fwoList = new List<ASI_CRM_Credit_Debit_Note__c>();
        for(ASI_CRM_Credit_Debit_Note__c  creditNote : newList){
            if(creditNote.RecordTypeId == Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_FWO_Period').getRecordTypeId()){
                fwoList.add(creditNote);
            }
        }
        if(fwoList != null && fwoList.size() > 0){
            List<ASI_CRM_Credit_Debit_Note__c> creditNoteHeaderList = new List<ASI_CRM_Credit_Debit_Note__c>();
            List<ASI_CRM_AccountsAdditionalField__c> wholesalerList = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c 
                                                                       WHERE ASI_CRM_Active__c = true 
                                                                       AND ASI_CRM_Record_Type_Name__c = 'ASI_CRM_SG_Wholesaler'];
            
            if (wholesalerList != null && wholesalerList.size() > 0) {
                for (ASI_CRM_Credit_Debit_Note__c fwoCreditNote : fwoList) {  
                    for (ASI_CRM_AccountsAdditionalField__c wholesaler : wholesalerList){
                        system.debug('@##@#@'+fwoCreditNote.Id);
                        ASI_CRM_Credit_Debit_Note__c creditNoteHeader = new ASI_CRM_Credit_Debit_Note__c();
                        creditNoteHeader.ASI_CRM_Currency__c = 'SGD';
                        creditNoteHeader.ASI_CRM_Exchange_Rate__c = 1 ;
                        creditNoteHeader.ASI_CRM_SG_FWO_End_Date__c = fwoCreditNote.ASI_CRM_SG_FWO_End_Date__c;
                        creditNoteHeader.ASI_CRM_SG_FWO_Period__c = fwoCreditNote.Id;
                        creditNoteHeader.ASI_CRM_SG_FWO_Start_Date__c = fwoCreditNote.ASI_CRM_SG_FWO_Start_Date__c;
                        creditNoteHeader.ASI_CRM_Status__c = 'Draft';
                        creditNoteHeader.ASI_CRM_Wholesaler__c = wholesaler.Id;
                        creditNoteHeader.Name = 'WSCN-'+string.valueOf(creditNoteHeader.ASI_CRM_SG_FWO_Start_Date__c.month())+string.valueOf(creditNoteHeader.ASI_CRM_SG_FWO_Start_Date__c.year());
                        creditNoteHeader.RecordTypeId =  Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_Credit_Note').getRecordTypeId();
                        creditNoteHeader.ASI_CRM_SG_Rebate_Type__c = fwoCreditNote.ASI_CRM_SG_Rebate_Type__c;
                        creditNoteHeader.ASI_CRM_Reason__c = getCreditNoteReason(fwoCreditNote.ASI_CRM_SG_FWO_Start_Date__c, fwoCreditNote.ASI_CRM_SG_Rebate_Type__c); //WL 1.0
                        creditNoteHeaderList.add(creditNoteHeader);
                    }
                }
            }
            system.debug('@#'+creditNoteHeaderList.size());
            if (creditNoteHeaderList != null && creditNoteHeaderList.size() > 0){
                Database.insert(creditNoteHeaderList, true);
                List<String> recordIds = new List<String>();
                for(ASI_CRM_Credit_Debit_Note__c creditNoteHeader : creditNoteHeaderList){
                    recordIds.add(creditNoteHeader.Id);
                }
                system.debug('@# recordIds size: '+recordIds.size());
                database.executeBatch(new ASI_CRM_SG_batchGenerateCreditItemDetail(recordIds), 1);
            }   
        }
    }  
    
    //2020-05-03 Ceterna - Delete credit Note headers without any item detail
    public static Integer deleteCreditDebitNotes(List<String> creditNoteIds){
        List<ASI_CRM_Credit_Debit_Note__c> creditDebitNoteToDelete = [Select Id 
                                                                      from ASI_CRM_Credit_Debit_Note__c 
                                                                      where ID IN :creditNoteIds 
                                                                      and ASI_CRM_SG_Delete_Credit_Note_Header__c = true];
        if(creditDebitNoteToDelete != null && creditDebitNoteToDelete.size()>0){
            delete creditDebitNoteToDelete;
            return creditDebitNoteToDelete.size();
        } else{
            return 0;
        }
    }
    
    public static void deleteCreditDebitLineItems(List<String> creditNoteIds){
        List<ASI_CRM_SG_Credit_Note_Item_Detail__c> itemDetailsToDelete = [Select Id 
                                                                           from ASI_CRM_SG_Credit_Note_Item_Detail__c 
                                                                           where ASI_CRM_SG_Credit_Debit_Note__c IN :creditNoteIds 
                                                                           and ASI_CRM_SG_Delete_Credit_Note_Itm_Detail__c = true];
        if(itemDetailsToDelete != null && itemDetailsToDelete.size()>0){
            delete itemDetailsToDelete;
        }
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> lineItemsToDelete = [Select Id 
                                                                          from ASI_CRM_Credit_Debit_Note_Line_Item__c 
                                                                          where ASI_CRM_Credit_Debit_Note__c IN :creditNoteIds 
                                                                          and ASI_CRM_SG_Delete_Credit_Note_Line_Item__c = true];
        if(lineItemsToDelete != null && lineItemsToDelete.size()>0){
            delete lineItemsToDelete;
        }
    }
    
}