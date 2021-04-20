public with sharing class ASI_HK_CRM_PromotionCalendarMonthCON extends ASI_HK_CRM_PromotionCalendarCommonClass {
    
    private static final String POPUP_TITLE_PMT = 'Promotion';
    private static final List<String> POPUP_DISPLAY_FIELDS_PMT = new String[] {
        'Name'
        , 'ASI_HK_CRM_Promotion_Name__c'
        , 'ASI_HK_CRM_Promotion_Start_Date__c'
        , 'ASI_HK_CRM_Promotion_End_Date__c'
        , 'ASI_HK_CRM_Record_Type_Name__c'
    };
    public static final String URL_PARAM_YEAR = 'year';
    public static final String URL_PARAM_MONTH = 'month';
    
    public String pmtPopupTitle { get { return POPUP_TITLE_PMT; } private set; }
    public ASI_HK_CRM_HoverPopupInfoData pmtPopupTemplate { get; private set; }
    public String curYearStr { get; set; }
    public String curMonthStr { get; set; }
    
    @RemoteAction
    public static List<ASI_HK_CRM_PromotionMonthEvent> retrievePromotionsByTimeRange(String fromDateStr, String toDateStr) {
        Date fromDate = Date.valueOf(fromDateStr);
        Date toDate = Date.valueOf(toDateStr);
        Set<String> fieldSet = new Set<String>(POPUP_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_HK_CRM_Promotion_Name__c');
        fieldSet.add('ASI_HK_CRM_Promotion_Start_Date__c');
        fieldSet.add('ASI_HK_CRM_Promotion_End_Date__c');
        fieldSet.add('ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_HK_CRM_Text_Color__c');
        String fieldsStr = String.join(new List<String>(fieldSet), ', ');
        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_HK_CRM_Promotion__c'
            + ' WHERE '
            + ' (ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate)';
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);
        List<ASI_HK_CRM_PromotionMonthEvent> result = new List<ASI_HK_CRM_PromotionMonthEvent>();
        for (ASI_HK_CRM_Promotion__c pmt : promotionList) {
            ASI_HK_CRM_PromotionMonthEvent event = new ASI_HK_CRM_PromotionMonthEvent();
            event.sObjId = pmt.Id;
            event.title = pmt.ASI_HK_CRM_Promotion_Name__c;
            event.startDT = pmt.ASI_HK_CRM_Promotion_Start_Date__c;
            event.endDT = pmt.ASI_HK_CRM_Promotion_End_Date__c;
            event.allDay = true;
            event.editable = true;
            event.backgroundColor = pmt.ASI_HK_CRM_Background_Color__c == null ? '#6777CC' : pmt.ASI_HK_CRM_Background_Color__c;
            event.textColor = pmt.ASI_HK_CRM_Text_Color__c == null ? '#FFFFFF' : pmt.ASI_HK_CRM_Text_Color__c;
            Map<String, Object> others = new Map<String, Object>();
            for (String popupField : POPUP_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        return result;
    }
    
    private static String objToStr(Object theObj) {
        if (theObj == null) {
            return '';
        } else if (theObj instanceof Date) {
            return ((Date)theObj).format();
        } else if (theObj instanceof Datetime) {
            return ((Datetime)theObj).format();
        }
        return String.valueOf(theObj);
    }

    public ASI_HK_CRM_PromotionCalendarMonthCON() {
        super(CALENDAR_TYPE_MONTH);
        Date todayDate = Date.today();
        this.curYearStr = String.valueOf(todayDate.year());
        this.curMonthStr = String.valueOf(todayDate.month() - 1);
        this.pmtPopupTemplate = generatePopupTemplateData();
    }
    
    public PageReference initPage() {
        Map<String, String> urlParamsMap = ApexPages.currentPage().getParameters();
        if (urlParamsMap != null) {
            String paramYear = urlParamsMap.get(URL_PARAM_YEAR);
            String paramMonth = urlParamsMap.get(URL_PARAM_MONTH);
            if (isValidYear(paramYear) && isValidMonth(paramMonth)) {
                this.curYearStr = paramYear;
                this.curMonthStr = paramMonth;
            }
        }
        return null;
    }
    
    public PageReference redirectToViewPage() {
        String pmtId = ApexPages.currentPage().getParameters().get('pmtId');
        return getRedirectToViewPage(pmtId);
    }
    
    private ASI_HK_CRM_HoverPopupInfoData generatePopupTemplateData() {
        List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> rowList = generatePopupRow();
        Map<String, Object> popupValueMap = new Map<String, Object>();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) popupValueMap.put(f, '');
        return new ASI_HK_CRM_HoverPopupInfoData(this.pmtObjLabel, rowList, popupValueMap);
    }
    private List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> generatePopupRow() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ASI_HK_CRM_Promotion__c.fields.getMap();
        List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> result = new List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow>();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) {
            Schema.SObjectField sObjField = fieldMap.get(f);
            if (sObjField == null) {
                showErrorMessage(String.format('Invalid Field Name in ASI_HK_CRM_PromotionCalendarMonthCON: {0}', new String[] {f}));
                continue;
            }
            result.add(new ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow(f, sObjField.getDescribe().getLabel()));
        }
        return result;
    }
    
    private void showErrorMessage(String msg) {
        showMessage(ApexPages.Severity.ERROR, msg);
    }
    private void showMessage(ApexPages.Severity severity, String msg) {ApexPages.addMessage(new ApexPages.Message(severity, msg));}
    
    public with sharing class ASI_HK_CRM_PromotionMonthEvent extends ASI_HK_CRM_FullCalendarEvent {
        ID sObjId { get; set; }
        Map<String, Object> otherValues { get; set; }
    }
    
    public static String convertToRetrivalDateFormat(Date inputDate) {
        return convertToRetrivalDateFormat(inputDate.year(), inputDate.month(), inputDate.day());
    }
    public static String convertToRetrivalDateFormat(Integer year, Integer month, Integer day) {
        return String.format('{0}-{1}-{2}', new String[] {String.valueOf(year), String.valueOf(month), String.valueOf(day)});
    }
}