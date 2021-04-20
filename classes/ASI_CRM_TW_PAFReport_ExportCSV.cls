global class ASI_CRM_TW_PAFReport_ExportCSV 
{
    public String comma {get;set;}
    public String newLine {get;set;}
    public List<String> selectedStatus {get;set;}
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    // public transient List<planLineItemDetail> detailList;
    public List<String> dynamicColumnHeaders {get;set;}

    public transient map<integer, List<planLineItemDetail>> detailList_Print_map {get; set;}

    set<string> PAFIId_set = new set<string>();
    map<string, ASI_HK_CRM_Pre_Approval_Form_Item__c> PAFI_map = new map<string, ASI_HK_CRM_Pre_Approval_Form_Item__c>();

    public transient string xmlheader {get;set;}
    /*public transient string xmlstyle {get;set;}
    public transient string xmlworkbook {get;set;}
    public transient string xmlworkbookend {get;set;}
    public transient string xmlworksheet {get;set;}
    public transient string xmlworksheetend {get;set;}
    public transient string xmltable {get;set;}
    public transient string xmltableend {get;set;}
    public transient string xmltabletitle {get;set;}
    public transient string xmltabletitleend {get;set;}
    public transient string xmltablerow {get;set;}
    public transient string xmltablerowend {get;set;}*/
    
    public ASI_CRM_TW_PAFReport_ExportCSV()
    {
        system.debug('++++Limits.getLimitHeapSize1(): '+Limits.getHeapSize());
        comma = ',';
        newLine = '\n';
        selectedStatus = System.currentPageReference().getParameters().get('selectedStatus').split(',');
        startDate = Date.valueof(System.currentPageReference().getParameters().get('startDate'));
        endDate = Date.valueof(System.currentPageReference().getParameters().get('endDate'));
        System.debug('++++param start date: ' + System.currentPageReference().getParameters().get('startDate'));
        System.debug('++++param end date: ' + System.currentPageReference().getParameters().get('endDate'));

        detailList_Print_map = new map<integer, List<planLineItemDetail>>();
        // detailList = new List<planLineItemDetail>();

        List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
        Boolean hasNone = false;
        for(String s : selectedStatus)
        {
            if(s == 'None')
            {
                hasNone = true;
            }
        }
        if(hasNone) selectedStatus.add(null);
        /*pafList = [Select Id, Name, ASI_CRM_Commitment_No__c, ASI_HK_CRM_PAF_Status__c, ASI_CRM_Commitment_No__r.ASI_MFM_Status__c
                    From ASI_HK_CRM_Pre_Approval_Form__c 
                    Where ((ASI_HK_CRM_PAF_End_Date__c <=: endDate And ASI_HK_CRM_PAF_End_Date__c >=: startDate)
                    Or (ASI_HK_CRM_PAF_Start_Date__c <=: endDate And ASI_HK_CRM_PAF_Start_Date__c >=: startDate)
                    Or (ASI_HK_CRM_PAF_Start_Date__c <=: startDate And ASI_HK_CRM_PAF_End_Date__c >=: endDate))
                    And ASI_CRM_Commitment_No__r.ASI_MFM_Status__c in: selectedStatus
                    ];*/

        //只算Enddate
        list<string> ItemRecordTypeId_L = new list<string>();
        /*string TW_Variable_Investment = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment');
        string TW_Conditional_Investment = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment');
        string TW_Fixed_Investment = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment');*/
        string TW_Variable_Investment = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_TW_Variable_Investment' AND sObjectType = 'ASI_HK_CRM_Pre_Approval_Form_Item__c'].Id;
        string TW_Conditional_Investment = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_TW_Conditional_Investment' AND sObjectType = 'ASI_HK_CRM_Pre_Approval_Form_Item__c'].Id;
        string TW_Fixed_Investment = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_TW_Fixed_Investment' AND sObjectType = 'ASI_HK_CRM_Pre_Approval_Form_Item__c'].Id;



        ItemRecordTypeId_L.add(TW_Variable_Investment);
        ItemRecordTypeId_L.add(TW_Conditional_Investment);
        ItemRecordTypeId_L.add(TW_Fixed_Investment);

        system.debug('++++Limits.getLimitHeapSize2(): '+Limits.getHeapSize());

        pafList = [Select Id, Name, ASI_CRM_Commitment_No__c, ASI_HK_CRM_PAF_Status__c, ASI_CRM_Commitment_No__r.ASI_MFM_Status__c
                    From ASI_HK_CRM_Pre_Approval_Form__c 
                    Where 
                    recordtype.developername in ('ASI_CRM_TW_Pre_Approval_Form', 'ASI_CRM_TW_Pre_Approval_Form_Read_Only')
                    and ((ASI_HK_CRM_PAF_End_Date__c <=: endDate And ASI_HK_CRM_PAF_End_Date__c >=: startDate)
                        or (ASI_HK_CRM_PAF_Start_Date__c <=: endDate And ASI_HK_CRM_PAF_Start_Date__c >=: startDate))
                    And ASI_CRM_Commitment_No__r.ASI_MFM_Status__c in: selectedStatus
                    ];
        System.debug('++++pafList: ' + pafList.size());
        
        List<String> planIdList = new List<String>();
        for(ASI_HK_CRM_Pre_Approval_Form__c paf: pafList) planIdList.add(paf.ASI_CRM_Commitment_No__c);

        system.debug('++++Limits.getLimitHeapSize3(): '+Limits.getHeapSize());

        System.debug('++++planIdList: ' + planIdList.size());
        /*List<ASI_MFM_Plan_Line_Item__c> planLineItemsList = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineItemsList = [Select Id, Name, ASI_MFM_Plan__c, ASI_MFM_Plan__r.Name, ASI_MFM_Start_Date_Sys__c, ASI_MFM_End_Date_sys__c, ASI_MFM_Plan__r.ASI_MFM_Status__c, ASI_MFM_List_Item_Description__c
                            , ASI_MFM_TW_Related_PAF_Item__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name, ASI_MFM_TW_Related_PAF_Item__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.RecordType.Name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Contracted_Item__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Contracted_Item__r.Name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Item__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_AD_or_AP__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_or_FOC__c, ASI_MFM_TW_Related_PAF_Item__r.CurrencyIsoCode, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Item__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Per_Bottle_w_VAT__c, ASI_MFM_Unit_Cost__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Target_Volume_Qty__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P4__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P6__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P10__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P12__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Mechanic__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Mechanic__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Mechanic_Detail__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P4__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P6__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P10__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P12__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P4__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P5__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P6__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P10__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P11__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P12__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Total_PG_Cost__c, ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
                            , ASI_MFM_A_C_Code__r.name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Expenses_Product__r.name
                            From ASI_MFM_Plan_Line_Item__c
                            Where ASI_MFM_Plan__c in: planIdList 
                            And ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId in: ItemRecordTypeId_L
                            ];
        System.debug('++++planLineItemsList: ' + planLineItemsList.size());*/

        List<Date> targateDates = new List<Date>();
        dynamicColumnHeaders = new List<String>();
        Integer numOfMonths = (endDate.year() - startDate.year())*12 + endDate.month() - startDate.month() + 1;
        for(Integer i = 0; i< numOfMonths; i++)
        {
            Date targetDate = Date.newInstance(startDate.year(), startDate.month(), 1).addMonths(i);
            targateDates.add(targetDate);
            dynamicColumnHeaders.add(targetDate.year() + '/' + targetDate.month());
        }
        System.debug('++++startDate: ' + startDate);
        System.debug('++++endDate: ' + endDate);
        System.debug('++++numOfMonths: ' + numOfMonths);
        System.debug('++++targateDates: ' + targateDates);

        system.debug('++++Limits.getLimitHeapSize4(): '+Limits.getHeapSize());
        
        for(ASI_MFM_Plan_Line_Item__c planLine : [Select id, ASI_MFM_TW_Related_PAF_Item__c
                            From ASI_MFM_Plan_Line_Item__c
                            Where ASI_MFM_Plan__c in: planIdList 
                            And ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId in: ItemRecordTypeId_L
                            And recordtype.developername = 'ASI_MFM_TW_Plan_Line_Item'
                            ])
        {
            PAFIId_set.add(planLine.ASI_MFM_TW_Related_PAF_Item__c);
        }

        for(ASI_HK_CRM_Pre_Approval_Form_Item__c PAFI : [select id, ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name, RecordType.Name, ASI_CRM_Contracted_Item__c, ASI_CRM_Contracted_Item__r.Name, ASI_CRM_FOC_Item__c,
        ASI_CRM_AD_or_AP__c, ASI_CRM_Cash_or_FOC__c, CurrencyIsoCode, ASI_CRM_FOC_Item__r.Name, ASI_CRM_Cash_Per_Bottle_w_VAT__c, ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c, 
        ASI_HK_CRM_Target_Volume_Qty__c, ASI_CRM_Target_Volume_Qty_P1__c, ASI_CRM_Target_Volume_Qty_P2__c, ASI_CRM_Target_Volume_Qty_P3__c, ASI_CRM_Target_Volume_Qty_P4__c, ASI_CRM_Target_Volume_Qty_P5__c, ASI_CRM_Target_Volume_Qty_P6__c, 
        ASI_CRM_Target_Volume_Qty_P7__c, ASI_CRM_Target_Volume_Qty_P8__c, ASI_CRM_Target_Volume_Qty_P9__c, ASI_CRM_Target_Volume_Qty_P10__c, ASI_CRM_Target_Volume_Qty_P11__c, ASI_CRM_Target_Volume_Qty_P12__c, ASI_HK_CRM_Mechanic__c,
        ASI_HK_CRM_Mechanic__r.Name, ASI_CRM_Mechanic_Detail__c, ASI_CRM_Cash_Amounts_w_VAT__c, ASI_CRM_Cash_Amounts_w_VAT_P1__c, ASI_CRM_Cash_Amounts_w_VAT_P2__c, ASI_CRM_Cash_Amounts_w_VAT_P3__c,
        ASI_CRM_Cash_Amounts_w_VAT_P4__c, ASI_CRM_Cash_Amounts_w_VAT_P5__c, ASI_CRM_Cash_Amounts_w_VAT_P6__c, ASI_CRM_Cash_Amounts_w_VAT_P7__c, ASI_CRM_Cash_Amounts_w_VAT_P8__c, ASI_CRM_Cash_Amounts_w_VAT_P9__c,
        ASI_CRM_Cash_Amounts_w_VAT_P10__c, ASI_CRM_Cash_Amounts_w_VAT_P11__c, ASI_CRM_Cash_Amounts_w_VAT_P12__c, ASI_CRM_FOC_Volume__c, ASI_CRM_FOC_Volume_P1__c, ASI_CRM_FOC_Volume_P2__c, ASI_CRM_FOC_Volume_P3__c,
        ASI_CRM_FOC_Volume_P4__c, ASI_CRM_FOC_Volume_P5__c, ASI_CRM_FOC_Volume_P6__c, ASI_CRM_FOC_Volume_P7__c, ASI_CRM_FOC_Volume_P8__c, ASI_CRM_FOC_Volume_P9__c, ASI_CRM_FOC_Volume_P10__c, ASI_CRM_FOC_Volume_P11__c,
        ASI_CRM_FOC_Volume_P12__c, ASI_CRM_Total_PG_Cost__c, RecordTypeId, ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c, 
        ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c, ASI_CRM_Expenses_Product__r.name, name
        from ASI_HK_CRM_Pre_Approval_Form_Item__c 
        where id in: PAFIId_set
        ]
            
        )
        {
            PAFI_map.put(PAFI.id, PAFI);
        }


        List<ASI_MFM_Plan_Line_Item__c> pList = [Select Id, Name, ASI_MFM_Plan__c, ASI_MFM_Plan__r.Name, ASI_MFM_Start_Date_Sys__c, ASI_MFM_End_Date_sys__c, ASI_MFM_Plan__r.ASI_MFM_Status__c, ASI_MFM_List_Item_Description__c
                            , ASI_MFM_TW_Related_PAF_Item__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name, ASI_MFM_TW_Related_PAF_Item__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.RecordType.Name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Contracted_Item__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Contracted_Item__r.Name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Item__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_AD_or_AP__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_or_FOC__c, ASI_MFM_TW_Related_PAF_Item__r.CurrencyIsoCode, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Item__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Per_Bottle_w_VAT__c, ASI_MFM_Unit_Cost__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Target_Volume_Qty__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P4__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P6__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P10__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P12__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Mechanic__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Mechanic__r.Name
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Mechanic_Detail__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P4__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P6__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P10__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P12__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P2__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P4__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P5__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P6__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P8__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P10__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P11__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P12__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Total_PG_Cost__c, ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c
                            , ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
                            , ASI_MFM_A_C_Code__r.name, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Expenses_Product__r.name
                            From ASI_MFM_Plan_Line_Item__c
                            Where ASI_MFM_Plan__c in: planIdList 
                            And ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId in: ItemRecordTypeId_L
                            And recordtype.developername = 'ASI_MFM_TW_Plan_Line_Item'
                            ];
        
        // List<ASI_MFM_Plan_Line_Item__c> pList = 
        //                     [Select Id, name, ASI_MFM_Plan__c, ASI_MFM_Plan__r.Name, ASI_MFM_Start_Date_Sys__c, ASI_MFM_End_Date_sys__c, ASI_MFM_Plan__r.ASI_MFM_Status__c, ASI_MFM_List_Item_Description__c,
        //                     ASI_MFM_A_C_Code__r.name, ASI_MFM_Unit_Cost__c, ASI_MFM_TW_Related_PAF_Item__c
        //                     From ASI_MFM_Plan_Line_Item__c
        //                     Where ASI_MFM_Plan__c in: planIdList 
        //                     And ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId in: ItemRecordTypeId_L
        //                     And recordtype.developername = 'ASI_MFM_TW_Plan_Line_Item'
        //                     ];
        system.debug('pList: ' + pList.size());
        system.debug('++++Limits.getLimitHeapSize5(): '+Limits.getHeapSize());

        integer counti = 0;
        integer countj = 0;
        list<planLineItemDetail> tempPLD_L = new list<planLineItemDetail>();

        for(ASI_MFM_Plan_Line_Item__c planLine : pList)
        {
            if(countj >= 999)
            {
                countj = 0;
                counti++;
                tempPLD_L = new list<planLineItemDetail>();
            }

            ASI_HK_CRM_Pre_Approval_Form_Item__c PAFI = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
            if(planLine.ASI_MFM_TW_Related_PAF_Item__c != null)
            {
                PAFI = PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c);
            }
            if(PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')*/ TW_Variable_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')*/ TW_Conditional_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')*/ TW_Fixed_Investment ){ 
                planLineItemDetail PLID = new planLineItemDetail();
                PLID.monthlyCost = new List<String>();
                PLID.planLineItem = planLine;
                for(Date targetDate: targateDates)
                {
                    Decimal monthCost;
                    Date PAFStartDate =PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c ;
                    Date PAFEndDate =PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c ;
                    Date targetMonthStartDate = Date.newInstance(targetDate.year(), targetDate.month() , 1);
                    Date targetMonthEndDate = Date.newInstance(targetDate.year(), targetDate.month() , Date.daysInMonth(targetDate.year(), targetDate.month()));
                    Integer fieldNumIndex = (targetMonthStartDate.year() - PAFStartDate.year())*12 + targetMonthStartDate.month() - PAFStartDate.month();
                    fieldNumIndex = fieldNumIndex+1;
                    system.debug('**Accrual PO Batch: fieldNumIndex='+fieldNumIndex);
                    if(fieldNumIndex <=12 && fieldNumIndex >= 1 ){
                        if((PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')*/ TW_Variable_Investment && planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('Cash')) || ((PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')*/ TW_Conditional_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')*/ TW_Fixed_Investment )&&planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('Cash'))){  
                            //2.2.1 Cash Lines:
                            Decimal amtDivisor = 1;
                            if(PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c){
                                amtDivisor =1.05;
                            }
                            //2.2.1 a.Variable Lines:
                            if(PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')*/ TW_Variable_Investment){
                                String qtyFieldName = 'ASI_CRM_Target_Volume_Qty_P'+fieldNumIndex+'__c';
                                //Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(qtyFieldName);
                                Decimal monthQty = (Decimal) PAFI.get(qtyFieldName);
                                Decimal cashPerBottle = PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_CRM_Cash_Per_Bottle_w_VAT__c != null ? PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c :0 ;
                                if(monthQty == null ){
                                    monthCost =0;
                                    // continue;
                                }else{
                                    monthCost = (monthQty * cashPerBottle)/amtDivisor;
                                }
                            }
                            //2.2.1 b. Fixed and Conditional Lines:
                            else if(PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')*/ TW_Conditional_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')*/ TW_Fixed_Investment ){
                                //System.debug('**Accrual PO Batch: PAF Plan -  Cash - Fixed/Conditional Investment');
                                //System.debug('**Accrual PO Batch: planline id = ' + planline.id);
                                String amtFieldName = 'ASI_CRM_Cash_Amounts_w_VAT_P'+fieldNumIndex+'__c';
                                //Decimal monthAmt = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(amtFieldName);
                                Decimal monthAmt = (Decimal) PAFI.get(amtFieldName);
                                if(monthAmt == null){
                                    monthCost = 0;
                                    // continue;
                                }else{
                                    monthCost =monthAmt/amtDivisor;
                                }
                            }
                        }
                        else if((PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')*/ TW_Variable_Investment && planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('FOC') ) || ((PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')*/ TW_Conditional_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')*/ TW_Fixed_Investment )&&planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('FOC'))){  
                            //2.2.2. FOC Lines:
                            
                            //2.2.2 a. Variable Lines:
                            if(PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')*/ TW_Variable_Investment){
                                String qtyFieldName = 'ASI_CRM_Target_Volume_Qty_P'+fieldNumIndex+'__c';
                                //Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(qtyFieldName);
                                Decimal monthQty = (Decimal) PAFI.get(qtyFieldName);
                                Decimal buyQty = PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                                Decimal freeQty =  PAFI_map.get(planLine.ASI_MFM_TW_Related_PAF_Item__c).ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                                Decimal unitCost =planLine.ASI_MFM_Unit_Cost__c;
                                if(monthQty !=null){                                
                                    if( buyQty== null || freeQty== null || unitCost== null  || buyQty==0  ){
                                        monthCost =0;
                                    }else{
                                        monthCost =(monthQty/buyQty)*freeQty * unitCost;
                                    }
                                }
                            }
                            //2.2.2 b. Fixed and Conditional Lines:
                            else if(PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')*/ TW_Conditional_Investment || PAFI.RecordTypeId == /*Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')*/ TW_Fixed_Investment ){
                                String FOCVolFieldName = 'ASI_CRM_FOC_Volume_P'+fieldNumIndex+'__c';
                                //Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(FOCVolFieldName);
                                Decimal monthQty = (Decimal) PAFI.get(FOCVolFieldName);
                                if(monthQty != null ){
                                    if(planLine.ASI_MFM_Unit_Cost__c == null){
                                        monthCost = 0;
                                    }else{
                                        monthCost =monthQty * planLine.ASI_MFM_Unit_Cost__c;
                                    }
                                }
                            }
                        }
                    }else{
                        //system.debug('**Accrual PO Batch: PAF time range may exceed 1 year and not appropriate for PO generation.');
                        // continue;
                    }
                    if(monthCost == null){
                        //system.debug('**Accrual PO Batch: No appropriate month Cost for PO line item.');
                        // continue;
                        PLID.monthlyCost.add('');
                    }
                    else{
                        PLID.monthlyCost.add(String.valueof(monthCost.round(System.RoundingMode.CEILING)));
                    }
                }
                // detailList.add(PLID);

                tempPLD_L.add(PLID);
                detailList_Print_map.put(counti, tempPLD_L);
                countj++;
            }

            PAFI = null;
        }

        system.debug('++++Limits.getLimitHeapSize6(): '+Limits.getHeapSize());
    }

    /*public string DatetoDTstring(date d)
    {
        Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
        String myDate = myDT.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return myDate;
    }

    public string FixNullValue(string value)
    {
        string Rstring;
        Rstring = '';
        if(value == null)
        {
            
        }
        else 
        {
            Rstring = value;
        }
        return Rstring;
    }

    public string FixNullDecimal(decimal value)
    {
        string Rstring;
        Rstring = '';
        if(value == null)
        {
            
        }
        else 
        {
            Rstring = string.valueof(value);
        }
        return Rstring;
    }*/
    
    // public void exportToCSV()
    // {
    //     system.debug('++++Limits.getLimitHeapSize7(): '+Limits.getHeapSize());
    //     xmlheader = '';
    //     xmlheader += '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';

    //     //xmlworkbook = '';
    //     xmlheader += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">';

    //     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //     //xmlstyle = '';
    //     xmlheader += ' <Styles>';
    //     xmlheader += '<Style ss:ID="Default" ss:Name="Normal">';
    //     xmlheader += '<Alignment ss:Vertical="Center"/>';
    //     xmlheader += '<Borders/>';
    //     xmlheader += '<Font ss:FontName="新細明體" x:CharSet="136" ss:Size="12" ss:Color="#000000"/>';
    //     xmlheader += '<Interior/>';
    //     xmlheader += '<NumberFormat/>';
    //     xmlheader += '<Protection/>';
    //     xmlheader += '</Style>';
    //     xmlheader += '<Style ss:ID="s63">';
    //     xmlheader += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>';
    //     xmlheader += '<Borders>';
    //     xmlheader += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '</Borders>';
    //     xmlheader += '<Font ss:FontName="新細明體" x:CharSet="136" ss:Color="#000000"/>';
    //     xmlheader += '</Style>';
    //     xmlheader += '<Style ss:ID="s66">';
    //     xmlheader += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>';
    //     xmlheader += '<Borders>';
    //     xmlheader += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '</Borders>';
    //     xmlheader += '<Font ss:FontName="新細明體" x:CharSet="136" ss:Color="#000000"/>';
    //     //xmlstyle += '<NumberFormat ss:Format="[ENG]mmm\-yy"/>';
    //     xmlheader += '</Style>';
    //     xmlheader += '<Style ss:ID="s67">';
    //     xmlheader += '<Alignment ss:Vertical="Center" ss:WrapText="1"/>';
    //     xmlheader += '<Borders>';
    //     xmlheader += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '</Borders>';
    //     xmlheader += '</Style>';
    //     xmlheader += '<Style ss:ID="s68">';
    //     xmlheader += '<Alignment ss:Vertical="Center" ss:WrapText="1"/>';
    //     xmlheader += '<Borders>';
    //     xmlheader += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '</Borders>';
    //     xmlheader += '<Font ss:FontName="新細明體" x:CharSet="136" ss:Color="#000000"/>';
    //     xmlheader += '</Style>';
    //     xmlheader += '<Style ss:ID="s71">';
    //     xmlheader += '<Alignment ss:Vertical="Center" ss:WrapText="1"/>';
    //     xmlheader += '<Borders>';
    //     xmlheader += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>';
    //     xmlheader += '</Borders>';
    //     xmlheader += '<Font ss:FontName="新細明體" x:CharSet="136" ss:Color="#000000"/>';
    //     xmlheader += '<NumberFormat ss:Format="Short Date"/>';
    //     xmlheader += '</Style>';
    //     xmlheader += '</Styles>';
        
    //     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        

    //     //xmlworksheet = '';
    //     xmlheader += '<Worksheet ss:Name="PAFReport">';

    //     //xmltable = '';
    //     xmlheader += '<Table ss:ExpandedColumnCount="500" ss:ExpandedRowCount="10000" x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="250" ss:DefaultRowHeight="15">';
        
    //     //xmltabletitle = '';
    //     xmlheader += '<Row ss:Height="16">';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Plan: Plan ID</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Start Date</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">End Date</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Status</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Plan Line Item: Plan Line Item ID</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Pre-Approval Form Lookup</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Pre-Approval Form Item Number</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Record Type</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Contracted Item</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Item</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: A&amp;D or A&amp;P</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash or FOC</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Per Bottle (w/ VAT) Currency</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Per Bottle (w/ VAT)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Unit Cost</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Buy Bottle</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Free Bottle</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P1)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P2)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P3)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P4)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P5)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P6)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P7)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P8)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P9)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P10)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P11)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Target Volume Qty (P12)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Mechanic</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Mechanic Detail</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P1)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P2)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P3)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P4)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P5)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P6)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P7)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P8)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P9)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P10)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P11)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Cash Amounts (w/ VAT) (P12)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P1)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P2)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P3)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P4)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P5)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P6)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P7)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P8)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P9)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P10)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P11)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: FOC Volume (P12)</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Total PG Cost Currency</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Related PAF Item: Total PG Cost</Data></Cell>';
    //     xmlheader += '<Cell ss:StyleID="s63"><Data ss:Type="String">Account Code</Data></Cell>';
    //     for(String DCH : dynamicColumnHeaders)
    //     {
    //         xmlheader += '<Cell ss:StyleID="s66"><Data ss:Type="String">' + DCH + '</Data></Cell>';
    //     }
    //     xmlheader += '</Row>';
        
    //     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //     //xmltablerow = '';
    //     system.debug('++++Limits.getLimitHeapSize8(): '+Limits.getHeapSize());

    //     for (Integer key : detailList_Print_map.keySet())
    //     {

    //         for (planLineItemDetail detail : detailList_Print_map.get(key))
    //         {
    //             ASI_HK_CRM_Pre_Approval_Form_Item__c PAFI = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
    //             if(detail.planLineItem.ASI_MFM_TW_Related_PAF_Item__c != null)
    //             {
    //                 PAFI = PAFI_map.get(detail.planLineItem.ASI_MFM_TW_Related_PAF_Item__c);
    //             }

    //             xmlheader += '<Row ss:AutoFitHeight="0">';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(detail.planLineItem.ASI_MFM_Plan__r.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s71"><Data ss:Type="DateTime">'+FixNullValue(DatetoDTstring(detail.planLineItem.ASI_MFM_Start_Date_Sys__c))+'</Data></Cell>'; //
    //             xmlheader += '<Cell ss:StyleID="s71"><Data ss:Type="DateTime">'+FixNullValue(DatetoDTstring(detail.planLineItem.ASI_MFM_End_Date_sys__c))+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(detail.planLineItem.ASI_MFM_Plan__r.ASI_MFM_Status__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(detail.planLineItem.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.RecordType.Name)+'</Data></Cell>';
    //             if(PAFI.ASI_CRM_Contracted_Item__r.Name == null)
    //             {
    //                 xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_Expenses_Product__r.name)+'</Data></Cell>';
    //             }
    //             else 
    //             {
    //                 xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_Contracted_Item__r.Name)+'</Data></Cell>';
    //             }
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_FOC_Item__r.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_AD_or_AP__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_Cash_or_FOC__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.CurrencyIsoCode)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(detail.planLineItem.ASI_MFM_Unit_Cost__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_HK_CRM_Target_Volume_Qty__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P1__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P2__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P3__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P4__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P5__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P6__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P7__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P8__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P9__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P10__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P11__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Target_Volume_Qty_P12__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_HK_CRM_Mechanic__r.Name)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.ASI_CRM_Mechanic_Detail__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P1__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P2__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P3__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P4__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P5__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P6__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P7__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P8__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P9__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P10__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P11__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Cash_Amounts_w_VAT_P12__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P1__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P2__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P3__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P4__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P5__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P6__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P7__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P8__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P9__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P10__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P11__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_FOC_Volume_P12__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(PAFI.CurrencyIsoCode)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="Number">'+FixNullDecimal(PAFI.ASI_CRM_Total_PG_Cost__c)+'</Data></Cell>';
    //             xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">'+FixNullValue(detail.planLineItem.ASI_MFM_A_C_Code__r.name)+'</Data></Cell>';
    //             for(string MC : detail.monthlyCost)
    //             {
    //                 xmlheader += '<Cell ss:StyleID="s68"><Data ss:Type="String">' + FixNullValue(MC) + '</Data></Cell>';
    //             }
    //             xmlheader += '</Row>';

    //             detail = new planLineItemDetail();
    //             PAFI = null;
    //         }
    //     }
    //     system.debug('++++Limits.getLimitHeapSize9(): '+Limits.getHeapSize());


    //     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //     //xmltableend = '';
    //     xmlheader += '</Table>';

    //     //xmlworksheetend = '';
    //     xmlheader += '</Worksheet>';

    //     //xmlworkbookend = '';
    //     xmlheader += '</Workbook>';

    //     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //     system.debug('++++Limits.getLimitHeapSize10(): '+Limits.getHeapSize());
    // }

    public class planLineItemDetail{
        public ASI_MFM_Plan_Line_Item__c planLineItem {get;set;}
        public List<String> monthlyCost {get;set;}
    }
}