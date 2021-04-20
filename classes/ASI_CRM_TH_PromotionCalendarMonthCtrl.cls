/*********************************************************************************
 * Name: ASI_CRM_TH_PromotionCalendarMonthCtrl 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/04/2016       Introv: Twinkle LI      Cloned & Revised from ASI_CRM_TW_PromotionCalendarMonthCON   
*********************************************************************************/

public with sharing class ASI_CRM_TH_PromotionCalendarMonthCtrl extends ASI_CRM_TH_PromotionCalendarCommonClass {
    
    private static final String POPUP_PROMOSTATUS_TITLE_PMT = 'Promotion Status';
    private static final List<String> POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT = new String[] {
        'Name'
        , 'ASI_CRM_Date__c'
        , 'ASI_CRM_Status__c'
        , 'ASI_CRM_GWP_Allocation__c'
        , 'ASI_CRM_Volume_Target__c'
    };
    
    private static final String POPUP_PROMO_TITLE_PMT = 'Promotion';
    private static final List<String> POPUP_PROMO_DISPLAY_FIELDS_PMT = new String[] {
        'Name'
        , 'ASI_HK_CRM_Promotion_Name__c'
        , 'ASI_HK_CRM_Promotion_Start_Date__c'
        , 'ASI_HK_CRM_Promotion_End_Date__c'
        , 'ASI_HK_CRM_Record_Type_Name__c'
    };
    
    public static final String URL_PARAM_YEAR = 'year';
    public static final String URL_PARAM_MONTH = 'month';
    
    public String pmtPopupTitle_promoStatus { get { return POPUP_PROMOSTATUS_TITLE_PMT; } private set; }
    public String pmtPopupTitle_promo { get { return POPUP_PROMO_TITLE_PMT; } private set; }
    public ASI_HK_CRM_HoverPopupInfoData pmtPopupTemplate { get; private set; }
    public String curYearStr { get; set; }
    public String curMonthStr { get; set; }
    public ASI_CRM_Promotion_Status__c promoStatus { get; set; }
    
    public List<SelectOption> getStatusList() {
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('Proposed','Proposed'));
        options.add(new SelectOption('Rejected','Rejected'));
        options.add(new SelectOption('Agreed','Agreed'));
        return options;
    }
    
    public ASI_CRM_TH_PromotionCalendarMonthCtrl() {
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
        
        ASI_CRM_Promotion_Status__c promoStatus = new ASI_CRM_Promotion_Status__c();
        
        return null;
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
    
    public PageReference redirectToViewPage() {
        String pmtId = ApexPages.currentPage().getParameters().get('pmtId');
        system.debug('pmtId: '+pmtId);
        
        //return getRedirectToViewPage(pmtId);
        PageReference redirectPage = new PageReference('/' + pmtId);
        //redirectPage.setRedirect(true);
        system.debug('redirectPage:' +redirectPage);
        return redirectPage;
    }
    
    private ASI_HK_CRM_HoverPopupInfoData generatePopupTemplateData() {
        List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> rowList = generatePopupRow();
        Map<String, Object> popupValueMap = new Map<String, Object>();
        
        for (String f : POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT) 
            popupValueMap.put(f, '');
            
        return new ASI_HK_CRM_HoverPopupInfoData(this.pmtObjLabel, rowList, popupValueMap);
    }
    
    private List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> generatePopupRow() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ASI_CRM_Promotion_Status__c.fields.getMap();
        List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> result = new List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow>();
        
        for (String f : POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT) {
            Schema.SObjectField sObjField = fieldMap.get(f);
            if (sObjField == null) {
                showErrorMessage(String.format('Invalid Field Name in ASI_CRM_TH_PromotionCalendarMonthCtrl: {0}', new String[] {f}));
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
    
    @RemoteAction
    public static List<ASI_HK_CRM_PromotionMonthEvent> retrieveRecordsByTimeRange(String fromDateStr, String toDateStr) {
        Date fromDate = Date.valueOf(fromDateStr);
        Date toDate = Date.valueOf(toDateStr);
        List<ASI_HK_CRM_PromotionMonthEvent> result = new List<ASI_HK_CRM_PromotionMonthEvent>();
        
        //Quering Promotion
        Set<String> fieldSet = new Set<String>(POPUP_PROMO_DISPLAY_FIELDS_PMT);
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
            + ' ASI_CRM_Type__c = \'GWP\''
            + ' AND ((ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate))'
            + ' AND (RecordType.DeveloperName = \'ASI_TH_CRM_National\' or RecordType.DeveloperName = \'ASI_TH_CRM_Tailor_Made\') ';
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);
        System.Debug('promotionList:' + promotionList.size());
        
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
            for (String popupField : POPUP_PROMO_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        
        //Quering Promotion Status
        fieldSet = new Set<String>(POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_CRM_Date__c');
        fieldSet.add('ASI_CRM_Status__c');
        fieldSet.add('ASI_CRM_GWP_Allocation__c');
        fieldSet.add('ASI_CRM_Volume_Target__c');
        fieldSet.add('ASI_CRM_Promotion__r.Name');
        fieldSet.add('ASI_CRM_Account__r.Name');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c');
        fieldsStr = String.join(new List<String>(fieldSet), ', ');
        queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_CRM_Promotion_Status__c'
            + ' WHERE '
            + ' ASI_CRM_Promotion__r.ASI_CRM_Type__c != \'GWP\''
            + ' AND (ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c <= :toDate)'
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TH_PromotionStatus\') ';
            
        List<ASI_CRM_Promotion_Status__c> promotionStatusList = database.query(queryStr);
        System.Debug('promotionStatusList:' + promotionStatusList.size());
        
        for (ASI_CRM_Promotion_Status__c pmt : promotionStatusList) {
            ASI_HK_CRM_PromotionMonthEvent event = new ASI_HK_CRM_PromotionMonthEvent();
            event.sObjId = pmt.Id;
            event.title = pmt.ASI_CRM_Account__r.Name+' - '+pmt.ASI_CRM_Promotion__r.Name;
            event.startDT = pmt.ASI_CRM_Date__c;
            event.endDT = pmt.ASI_CRM_Date__c;
            event.allDay = true;
            event.editable = true;
            event.backgroundColor = pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c == null ? '#6777CC' : pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c;
            event.textColor = pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c == null ? '#FFFFFF' : pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c;
            Map<String, Object> others = new Map<String, Object>();
            for (String popupField : POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        return result;
    }
    
    @RemoteAction
    public static List<ASI_HK_CRM_PromotionMonthEvent> retrieveFilteringRecordsByTimeRange(String fromDateStr, String toDateStr, String strOutlet, String strStatus) {
        system.debug('Outlet: '+strOutlet);
        system.debug('Status: '+strStatus);
        
        Date fromDate = Date.valueOf(fromDateStr);
        Date toDate = Date.valueOf(toDateStr);
        List<ASI_HK_CRM_PromotionMonthEvent> result = new List<ASI_HK_CRM_PromotionMonthEvent>();
        
        Set<String> setSelectedStatus = new Set<String>();
        if(strStatus != null){
            String[] tmpString = strStatus.split(',');
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '').replace(' ', '');
                setSelectedStatus.add(s);
            }
            system.debug('setSelectedStatus: '+setSelectedStatus);
        }
        
        //Quering Promotion with related Promotion Status
        Set<Id> setPromoId = new Set<Id>();
        Set<String> fieldSet = new Set<String>(POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_CRM_Date__c');
        fieldSet.add('ASI_CRM_Status__c');
        fieldSet.add('ASI_CRM_GWP_Allocation__c');
        fieldSet.add('ASI_CRM_Volume_Target__c');
        fieldSet.add('ASI_CRM_Promotion__c');
        fieldSet.add('ASI_CRM_Promotion__r.Name');
        fieldSet.add('ASI_CRM_Account__r.Name');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c');
        String fieldsStr = String.join(new List<String>(fieldSet), ', ');
        
        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_CRM_Promotion_Status__c'
            + ' WHERE '
            + ' ASI_CRM_Promotion__r.ASI_CRM_Type__c = \'GWP\''
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TH_PromotionStatus\') ';
            
        if(!String.IsEmpty(strOutlet))
            queryStr += ' AND (ASI_CRM_Account__r.Name =: strOutlet) ';
        if(setSelectedStatus != null && setSelectedStatus.size() > 0)    
            queryStr += ' AND (ASI_CRM_Status__c IN: setSelectedStatus) ';
            
        system.debug('queryStr: '+queryStr);
        
        List<ASI_CRM_Promotion_Status__c> promoStatusList = database.query(queryStr);
        for (ASI_CRM_Promotion_Status__c pmt : promoStatusList) {
            setPromoId.add(pmt.ASI_CRM_Promotion__c);
        }
        System.Debug('promoStatusList:' + promoStatusList.size());
        System.Debug('setPromoId:' + setPromoId);
        
        fieldSet = new Set<String>(POPUP_PROMO_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_HK_CRM_Promotion_Name__c');
        fieldSet.add('ASI_HK_CRM_Promotion_Start_Date__c');
        fieldSet.add('ASI_HK_CRM_Promotion_End_Date__c');
        fieldSet.add('ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_HK_CRM_Text_Color__c');
        fieldsStr = String.join(new List<String>(fieldSet), ', ');
        queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_HK_CRM_Promotion__c'
            + ' WHERE '
            + ' ASI_CRM_Type__c = \'GWP\''
            + ' AND ((ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate))'
            + ' AND (RecordType.DeveloperName = \'ASI_TH_CRM_National\' or RecordType.DeveloperName = \'ASI_TH_CRM_Tailor_Made\') '
            + ' AND (Id IN: setPromoId)';
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);
        System.Debug('promotionList:' + promotionList.size());
        
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
            for (String popupField : POPUP_PROMO_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        
        //Quering Promotion Status
        fieldSet = new Set<String>(POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_CRM_Date__c');
        fieldSet.add('ASI_CRM_Status__c');
        fieldSet.add('ASI_CRM_GWP_Allocation__c');
        fieldSet.add('ASI_CRM_Volume_Target__c');
        fieldSet.add('ASI_CRM_Promotion__r.Name');
        fieldSet.add('ASI_CRM_Account__r.Name');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c');
        fieldsStr = String.join(new List<String>(fieldSet), ', ');
        
        queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_CRM_Promotion_Status__c'
            + ' WHERE '
            + ' ASI_CRM_Promotion__r.ASI_CRM_Type__c != \'GWP\''
            + ' AND (ASI_CRM_Date__c >= :fromDate AND ASI_CRM_Date__c <= :toDate)'
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TH_PromotionStatus\') ';
            
        if(!String.IsEmpty(strOutlet))
            queryStr += ' AND (ASI_CRM_Account__r.Name =: strOutlet) ';
        if(setSelectedStatus != null && setSelectedStatus.size() > 0)    
            queryStr += ' AND (ASI_CRM_Status__c IN: setSelectedStatus) ';
            
        system.debug('queryStr: '+queryStr);
        
        List<ASI_CRM_Promotion_Status__c> promotionStatusList = database.query(queryStr);
        System.Debug('promotionStatusList:' + promotionStatusList.size());
        
        for (ASI_CRM_Promotion_Status__c pmt : promotionStatusList) {
            ASI_HK_CRM_PromotionMonthEvent event = new ASI_HK_CRM_PromotionMonthEvent();
            event.sObjId = pmt.Id;
            event.title = pmt.ASI_CRM_Account__r.Name+' - '+pmt.ASI_CRM_Promotion__r.Name;
            event.startDT = pmt.ASI_CRM_Date__c;
            event.endDT = pmt.ASI_CRM_Date__c;
            event.allDay = true;
            event.editable = true;
            event.backgroundColor = pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c == null ? '#6777CC' : pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Background_Color__c;
            event.textColor = pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c == null ? '#FFFFFF' : pmt.ASI_CRM_Promotion__r.ASI_HK_CRM_Text_Color__c;
            Map<String, Object> others = new Map<String, Object>();
            for (String popupField : POPUP_PROMOSTATUS_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        system.debug(result);
        return result;
    }
}