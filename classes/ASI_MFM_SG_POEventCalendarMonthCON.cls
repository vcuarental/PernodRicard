public without sharing class ASI_MFM_SG_POEventCalendarMonthCON extends ASI_MFM_SG_EventCalendarCommonClass {
    
    private static final String POPUP_TITLE_PMT = 'PO Event';
    private static final List<String> POPUP_DISPLAY_FIELDS_PMT = new String[] {
        	'ASI_MFM_Owner_Display__c',//20180502 Introv
            'ASI_MFM_Event_Name__c',
            'ASI_MFM_Event_Start_Date__c',
            'ASI_MFM_Event_End_Date__c'
            };
    public static final String URL_PARAM_YEAR = 'year';
    public static final String URL_PARAM_MONTH = 'month';
    
    public String pmtPopupTitle { get { return POPUP_TITLE_PMT; } private set; }
    public ASI_MFM_SG_HoverPopupInfoData pmtPopupTemplate { get; private set; }
    public String curYearStr { get; set; }
    public String curMonthStr { get; set; }
    
    @RemoteAction
    public static List<ASI_MFM_SG_MonthEvent> retrievePromotionsByTimeRange(String fromDateStr, String toDateStr) {
		system.debug('retrievePromotionsByTimeRange');
		
        Date fromDate = Date.valueOf(fromDateStr);
        Date toDate = Date.valueOf(toDateStr);
        Set<String> fieldSet = new Set<String>(POPUP_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('ASI_MFM_Event_Name__c');
		fieldSet.add('ASI_MFM_Event_Start_Date__c');
		fieldSet.add('ASI_MFM_Event_End_Date__c');
        String fieldsStr = String.join(new List<String>(fieldSet), ', ');
        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_MFM_PO__c'
            + ' WHERE '
            + ' ((ASI_MFM_Event_Start_Date__c >= :fromDate AND ASI_MFM_Event_Start_Date__c <= :toDate)'
            + ' OR (ASI_MFM_Event_End_Date__c >= :fromDate AND ASI_MFM_Event_End_Date__c <= :toDate)'
            + ' OR (ASI_MFM_Event_Start_Date__c < :fromDate AND ASI_MFM_Event_End_Date__c > :toDate))'
			+ ' AND RecordType.DeveloperName LIKE \'ASI_MFM_SG_PO%\''
            + ' AND (ASI_MFM_Status__c LIKE \'Final\' OR ASI_MFM_Status__c LIKE \'Complete\')';
        List<ASI_MFM_PO__c> promotionList = database.query(queryStr);
		
		system.debug('queryStr: ' + queryStr + 'promotionList size: ' + promotionList.size());
		
        List<ASI_MFM_SG_MonthEvent> result = new List<ASI_MFM_SG_MonthEvent>();
        for (ASI_MFM_PO__c pmt : promotionList) {
            ASI_MFM_SG_MonthEvent event = new ASI_MFM_SG_MonthEvent();
            event.sObjId = pmt.Id;
            event.title = pmt.ASI_MFM_Event_Name__c;
            event.startDT = pmt.ASI_MFM_Event_Start_Date__c;
            event.endDT = pmt.ASI_MFM_Event_End_Date__c;
            event.allDay = true;
            event.editable = true;
			//event.backgroundColor = '#6777CC';
            event.backgroundColor = getRandomColor();
			event.textColor = '#FFFFFF';
			
            Map<String, Object> others = new Map<String, Object>();
            for (String popupField : POPUP_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        return result;
    }
    
    public static String getRandomColor() {
        String letters = '0123456789ABCDEF';
        String color = '#';
        for (Integer i = 0; i < 6; i++) {
            Integer index = (Integer)(Math.floor(Math.random() * 16));
            color += letters.substring(index, index+1);
        }
        return color;
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

    public ASI_MFM_SG_POEventCalendarMonthCON() {
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
		
		system.debug('curYearStr: ' + curYearStr + ' curMonthStr: ' + curMonthStr);
        return null;
    }
    
    public PageReference redirectToViewPage() {
        String pmtId = ApexPages.currentPage().getParameters().get('pmtId');
        return getRedirectToViewPage(pmtId);
    }
    
    private ASI_MFM_SG_HoverPopupInfoData generatePopupTemplateData() {
        List<ASI_MFM_SG_HoverPopupInfoData.ASI_MFM_SG_HoverPopupInfoDataRow> rowList = generatePopupRow();
        Map<String, Object> popupValueMap = new Map<String, Object>();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) popupValueMap.put(f, '');
        return new ASI_MFM_SG_HoverPopupInfoData(POPUP_TITLE_PMT, rowList, popupValueMap);
    }
	
    private List<ASI_MFM_SG_HoverPopupInfoData.ASI_MFM_SG_HoverPopupInfoDataRow> generatePopupRow() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ASI_MFM_PO__c.fields.getMap();
        List<ASI_MFM_SG_HoverPopupInfoData.ASI_MFM_SG_HoverPopupInfoDataRow> result = new List<ASI_MFM_SG_HoverPopupInfoData.ASI_MFM_SG_HoverPopupInfoDataRow>();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) {
            Schema.SObjectField sObjField = fieldMap.get(f);
            if (sObjField == null) {
                showErrorMessage(String.format('Invalid Field Name in ASI_MFM_SG_POEventCalendarMonthCON: {0}', new String[] {f}));
                continue;
            }
            result.add(new ASI_MFM_SG_HoverPopupInfoData.ASI_MFM_SG_HoverPopupInfoDataRow(f, sObjField.getDescribe().getLabel()));
        }
        return result;
    }
    
    private void showErrorMessage(String msg) {
        showMessage(ApexPages.Severity.ERROR, msg);
    }
    private void showMessage(ApexPages.Severity severity, String msg) {ApexPages.addMessage(new ApexPages.Message(severity, msg));}
    
    public with sharing class ASI_MFM_SG_MonthEvent extends ASI_MFM_SG_FullCalendarEvent {
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