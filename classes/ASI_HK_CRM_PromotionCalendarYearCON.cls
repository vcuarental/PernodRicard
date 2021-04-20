public with sharing class ASI_HK_CRM_PromotionCalendarYearCON extends ASI_HK_CRM_PromotionCalendarCommonClass {

    private static final List<String> POPUP_DISPLAY_FIELDS_PMT = new String[] {
        'Name'
        , 'ASI_HK_CRM_Promotion_Name__c'
        , 'ASI_HK_CRM_Promotion_Start_Date__c'
        , 'ASI_HK_CRM_Promotion_End_Date__c'
        , 'ASI_HK_CRM_Record_Type_Name__c'
    };
    private static final String GROUP_FIELD_DEF = 'ASI_HK_CRM_Sub_Brand__r.Name';
    private static final String GROUP_FIELD_OBJECT = 'ASI_HK_CRM_Promotion_Details__r';
    private static final String GROUP_FIELD_NULL_REPLACE = 'National';
    private static final String GROUP_FIELD_OBJECT_WHERE_STATM = 'RecordType.DeveloperName = \'ASI_HK_CRM_Sub_Brand\'';
    private static final Integer LAYOUT_MONTH_WIDTH = 80;
    private static final Integer LAYOUT_EVENT_HEIGHT = 26;
    private static final Integer LAYOUT_EVENT_DISTANCE_Y = 4;
    private static final Integer LAYOUT_EVENT_BORDER_BOTTOM = 1;
    private static final Integer LAYOUT_EVENT_SPACE_X_BEGIN = 2;
    private static final Integer LAYOUT_EVENT_SPACE_X_END = 2;
    public static final String URL_PARAM_YEAR = 'year';
    public static final String URL_PARAM_MONTH = 'month';

    public Date filterFromDate { get; set; }
    public Date filterToDate { get; set; }
    
    // Calendar Settings
    public List<String> yearList { get; private set; }
    public Map<String, Integer> yearColSpan { get; private set; }
    public List<String> monthList { get; private set; }
    public List<ASI_HK_CRM_PromotionYearGroup> eventGroups { get; private set; }
    
    // Event Data
    public List<ASI_HK_CRM_PromotionYearEvent> eventList { get; private set; }
    public List<ASI_HK_CRM_HoverPopupInfoData> popupDataList { get; private set; }
    
    // Other Info
    public String prevYearLink { get; private set; }
    public String nextYearLink { get; private set; }
    
    private List<String> userMonthStrList;
    private String groupField;
    private String groupFieldObj;
    private Object groupFieldNullReplace;
    private String groupFieldObjWhereStatm;
    private Set<String> filterGroupValues;
    private String pmtLabel;
    private List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> popupTableRow;

    public ASI_HK_CRM_PromotionCalendarYearCON() {
        super(CALENDAR_TYPE_YEAR);
        Map<String, String> urlParamsMap = ApexPages.currentPage().getParameters();
        String paramYear = null;
        String paramMonth = null;
        if (urlParamsMap != null) {
            paramYear = urlParamsMap.get(URL_PARAM_YEAR);
            paramMonth = urlParamsMap.get(URL_PARAM_MONTH);
        }
        Date requestDate = (isValidYear(paramYear) && isValidMonth(paramMonth))
            ? Date.newInstance(Integer.valueOf(paramYear), Integer.valueOf(paramMonth) + 1, 1)
            : Date.today();
        this.filterFromDate = Date.newInstance(requestDate.year(), requestDate.month(), 1);
        Date nextYear = this.filterFromDate.addYears(1).addMonths(-1);
        this.filterToDate = Date.newInstance(nextYear.year(), nextYear.month(), Date.daysInMonth(nextYear.year(), nextYear.month()));
        String yearBtnFormatStr = (ApexPages.currentPage().getUrl().split('\\?')[0]) + '?' + URL_PARAM_YEAR + '={0}&' + URL_PARAM_MONTH + '={1}';
        Date tempPrevDate = this.filterFromDate.addMonths(-11);
        this.prevYearLink = String.format(yearBtnFormatStr, new String[] {String.valueOf(tempPrevDate.year()), String.valueOf(tempPrevDate.month() - 1)});
        Date tempNextDate = this.filterToDate;
        this.nextYearLink = String.format(yearBtnFormatStr, new String[] {String.valueOf(tempNextDate.year()), String.valueOf(tempNextDate.month() - 1)});
        this.yearList = new List<String>();
        this.yearColSpan = new Map<String, Integer>();
        this.monthList = new List<String>();
        this.eventGroups = new List<ASI_HK_CRM_PromotionYearGroup>();
        this.eventList = new List<ASI_HK_CRM_PromotionYearEvent>();
        this.popupDataList = new List<ASI_HK_CRM_HoverPopupInfoData>();
        this.userMonthStrList = getUserMonthStringList();
        this.groupField = GROUP_FIELD_DEF;
        this.groupFieldObj = GROUP_FIELD_OBJECT;
        this.groupFieldNullReplace = GROUP_FIELD_NULL_REPLACE;
        this.groupFieldObjWhereStatm = GROUP_FIELD_OBJECT_WHERE_STATM;
        this.filterGroupValues = null;
        this.pmtLabel = Schema.SObjectType.ASI_HK_CRM_Promotion__c.getLabel();
        this.popupTableRow = getPopupDisplayRowList();
    }
    
    public PageReference initPage() {
        reloadData();
        return null;
    }
    
    public void reloadData() {
        reloadYearAndMonthDisplayList();
        List<ASI_HK_CRM_Promotion__c> promotionList = queryPromotions();
        reloadEventDisplayData(promotionList);
    }
    
    private void reloadYearAndMonthDisplayList() {
        this.yearList = new List<String>();
        Integer finishYear = this.filterToDate.year();
        for (Integer y = this.filterFromDate.year(); y <= finishYear; y++) {
            this.yearList.add(String.valueOf(y));
        }
        
        this.monthList = new List<String>();
        this.yearColSpan = new Map<String, Integer>();
        Integer monthsBetween = this.filterFromDate.monthsBetween(this.filterToDate);
        Integer yearIndex = 0;
        Integer monthCount = 0;
        if (monthsBetween >= 0) {
            Integer fromMonth = this.filterFromDate.month();
            for (Integer i = 0; i <= monthsBetween; i++) {
                Integer monthIndex = Math.mod(fromMonth - 1 + i, 12);
                this.monthList.add(this.userMonthStrList.get(monthIndex));
                monthCount++;
                if (monthIndex == 11 || i == monthsBetween) {
                    this.yearColSpan.put(this.yearList.get(yearIndex), monthCount);
                    yearIndex++;
                    monthCount = 0;
                }
            }
        }
    }
    
    private List<ASI_HK_CRM_Promotion__c> queryPromotions() {
        String groupFilterStatm = null;
        if (filterGroupValues != null && filterGroupValues.size() > 0)
            groupFilterStatm = groupField + ' IN :filterGroupValues';
        else
            groupFilterStatm = '';
        Set<String> fieldSet = new Set<String>(POPUP_DISPLAY_FIELDS_PMT);
        fieldSet.add('Id');
        fieldSet.add('Name');
        fieldSet.add('ASI_HK_CRM_Promotion_Name__c');
        fieldSet.add('ASI_HK_CRM_Promotion_Start_Date__c');
        fieldSet.add('ASI_HK_CRM_Promotion_End_Date__c');
        fieldSet.add('ASI_HK_CRM_Background_Color__c');
        fieldSet.add('ASI_HK_CRM_Text_Color__c');
        if (!isChildObjGroupField()) {
            fieldSet.add(groupField);
        } else {
            String childWhereStatm = '';
            if (this.groupFieldObjWhereStatm != null && this.groupFieldObjWhereStatm.trim() != '') {
                if (childWhereStatm != '') childWhereStatm += ' AND ';
                childWhereStatm += '(' + this.groupFieldObjWhereStatm + ')';
            }
            if (groupFilterStatm != null && groupFilterStatm.trim() != '') {
                if (childWhereStatm != '') childWhereStatm += ' AND ';
                childWhereStatm += '(' + groupFilterStatm + ')';
            }
            if (childWhereStatm != '')
                childWhereStatm = 'WHERE ' + childWhereStatm;
            fieldSet.add(String.format('(SELECT {0} FROM {1} {2})', new String[] {this.groupField, this.groupFieldObj, childWhereStatm}));
        }
        String fieldsStr = String.join(new List<String>(fieldSet), ', ');
        String dateFilterStatm = '(ASI_HK_CRM_Promotion_Start_Date__c >= :filterFromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :filterToDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :filterFromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :filterToDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c <= :filterFromDate AND ASI_HK_CRM_Promotion_End_Date__c >= :filterToDate)';
        
        String whereStatm = '(' + dateFilterStatm + ')'
            + (isChildObjGroupField() || groupFilterStatm == null ? '' : ' AND (' + groupFilterStatm + ')');
        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_HK_CRM_Promotion__c'
            + ' WHERE ' + whereStatm
            + ' ORDER BY ASI_HK_CRM_Promotion_Start_Date__c';
        return database.query(queryStr);
    }
    
    private void reloadEventDisplayData(List<ASI_HK_CRM_Promotion__c> pmtList) {
        Set<String> eventGroupStrSet = new Set<String>();
        Map<String, List<ASI_HK_CRM_PromotionYearEvent>> eventGroupToEventMap = new Map<String, List<ASI_HK_CRM_PromotionYearEvent>>();
        this.popupDataList = new List<ASI_HK_CRM_HoverPopupInfoData>();
        for (ASI_HK_CRM_Promotion__c pmt : pmtList) {
            List<ASI_HK_CRM_PromotionYearEvent> pmtEventList = pmtToEvents(pmt);
            this.popupDataList.add(pmtToEventPopup(pmt));
            for (ASI_HK_CRM_PromotionYearEvent pmtEvent : pmtEventList) {
                Object groupValue = pmtEvent.groupValue;
                String groupValueStr = String.valueOf(groupValue);
                this.eventList.add(pmtEvent);
                eventGroupStrSet.add(groupValueStr);
                List<ASI_HK_CRM_PromotionYearEvent> tempEventList = eventGroupToEventMap.get(groupValueStr);
                if (tempEventList == null) {
                    tempEventList = new List<ASI_HK_CRM_PromotionYearEvent>();
                    eventGroupToEventMap.put(groupValueStr, tempEventList);
                }
                tempEventList.add(pmtEvent);
            }
        }
        List<String> eventGroupStrList = new List<String>(eventGroupStrSet);
        eventGroupStrList.sort();
        this.eventGroups = new List<ASI_HK_CRM_PromotionYearGroup>();
        for (String groupName : eventGroupStrList) {
            this.eventGroups.add(new ASI_HK_CRM_PromotionYearGroup(groupName));
        }
        Map<String, ASI_HK_CRM_PromotionYearQueue> queueMap = new Map<String, ASI_HK_CRM_PromotionYearQueue>();
        for (ASI_HK_CRM_PromotionYearGroup eventGroup : this.eventGroups) {
            queueMap.put(eventGroup.groupName, new ASI_HK_CRM_PromotionYearQueue(eventGroup, eventGroupToEventMap.get(eventGroup.groupName)));
        }
        calculateLayout(this.eventList, this.eventGroups, queueMap);
    }
    
    private void calculateLayout(List<ASI_HK_CRM_PromotionYearEvent> eventList, List<ASI_HK_CRM_PromotionYearGroup> sortedGroupList, Map<String, ASI_HK_CRM_PromotionYearQueue> queueMap) {
        for (ASI_HK_CRM_PromotionYearEvent theEvent : eventList) {
            theEvent.setLayout(this.filterFromDate, this.filterToDate, 0, LAYOUT_MONTH_WIDTH, LAYOUT_EVENT_HEIGHT, LAYOUT_EVENT_SPACE_X_BEGIN, LAYOUT_EVENT_SPACE_X_END);
        }
        Integer curTop = LAYOUT_EVENT_DISTANCE_Y / 2;
        Integer incrementY = LAYOUT_EVENT_HEIGHT + LAYOUT_EVENT_DISTANCE_Y + LAYOUT_EVENT_BORDER_BOTTOM;
        for (ASI_HK_CRM_PromotionYearGroup eventGroup : sortedGroupList) {
            ASI_HK_CRM_PromotionYearQueue queue = queueMap.get(eventGroup.groupName);
            Integer queueNextTop = queue.calculatePosition(curTop, incrementY);
            eventGroup.heightInt = queueNextTop - curTop;
            curTop = queueNextTop;
        }
    }
        
    private List<ASI_HK_CRM_PromotionYearEvent> pmtToEvents(ASI_HK_CRM_Promotion__c pmt) {
        List<ASI_HK_CRM_PromotionYearEvent> result = new List<ASI_HK_CRM_PromotionYearEvent>();
        List<Object> groupFieldValueList = getGroupFieldValues(pmt);
        for (Object groupFieldValue : groupFieldValueList) {
            ASI_HK_CRM_PromotionYearEvent theEvent = new ASI_HK_CRM_PromotionYearEvent();
            theEvent.sObjId = pmt.Id;
            theEvent.groupValue = groupFieldValue;
            theEvent.title = pmt.ASI_HK_CRM_Promotion_Name__c;
            theEvent.startDate = pmt.ASI_HK_CRM_Promotion_Start_Date__c;
            theEvent.endDate = pmt.ASI_HK_CRM_Promotion_End_Date__c;
            theEvent.popupId = pmt.Id;
            theEvent.backgroundColor = pmt.ASI_HK_CRM_Background_Color__c;
            theEvent.color = pmt.ASI_HK_CRM_Text_Color__c;
            result.add(theEvent);
        }
        return result;
    }
        
    private ASI_HK_CRM_HoverPopupInfoData pmtToEventPopup(ASI_HK_CRM_Promotion__c pmt) {
        Map<String, Object> popupValueMap = new Map<String, Object>();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) {
            Object fValue = pmt.get(f);
            popupValueMap.put(f, objToStr(fValue));
        }
        ASI_HK_CRM_HoverPopupInfoData result = new ASI_HK_CRM_HoverPopupInfoData(this.pmtLabel, this.popupTableRow, popupValueMap);
        result.dataId = pmt.Id;
        return result;
    }
    
    private String objToStr(Object theObj) {
        if (theObj == null) {
            return '';
        } else if (theObj instanceof Date) {
            return ((Date)theObj).format();
        } else if (theObj instanceof Datetime) {
            return ((Datetime)theObj).format();
        }
        return String.valueOf(theObj);
    }
    
    private List<String> getUserMonthStringList() {
        List<String> result = new List<String>();
        for (Integer i = 0; i < 12; i++) {
            result.add(Datetime.newInstance(2000, i + 1, 10).format('MMM'));
        }
        return result;
    }
    
    private List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> getPopupDisplayRowList() {
        List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow> result = new List<ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow>();
        Map<String, Schema.SObjectField> pmtFieldMap = Schema.SObjectType.ASI_HK_CRM_Promotion__c.fields.getMap();
        for (String f : POPUP_DISPLAY_FIELDS_PMT) {
            result.add(new ASI_HK_CRM_HoverPopupInfoData.ASI_HK_CRM_HoverPopupInfoDataRow(f, pmtFieldMap.get(f).getDescribe().getLabel()));
        }
        return result;
    }
    
    private Boolean isChildObjGroupField() {
        return this.groupFieldObj != null && this.groupFieldObj != 'ASI_HK_CRM_Promotion__c';
    }
    
    private List<Object> getGroupFieldValues(ASI_HK_CRM_Promotion__c pmt) {
        Set<Object> result = new Set<Object>();
        if (isChildObjGroupField()) {
            List<sObject> childObjList = pmt.getSObjects(this.groupFieldObj);
            if (childObjList == null || childObjList.size() == 0) {
                result.add(this.groupFieldNullReplace);
            } else {
                for (sObject childObj : childObjList) {
                    Object theValue = getLookupValue(childObj, this.groupField);
                    result.add(theValue != null ? theValue : this.groupFieldNullReplace);
                }
            }
        } else {
            Object theValue = getLookupValue(pmt, this.groupField);
            if (theValue != null)
                result.add(theValue != null ? theValue : this.groupFieldNullReplace);
        }
        return new List<Object>(result);
    }
    
    private Object getLookupValue(sObject sObj, String theField) {
        List<String> fieldStrList = theField.split('\\.', 0);
        if (fieldStrList.size() == 0) fieldStrList.add(theField);
        Integer size = fieldStrList.size();
        sObject tempSObj = sObj;
        for (Integer i = 0; i < size - 1; i++) {
            tempSObj = tempSObj.getSObject(fieldStrList.get(i));
            if (tempSObj == null)
                return null;
        }
        return tempSObj.get(fieldStrList.get(size - 1));
    }
    
    public with sharing class ASI_HK_CRM_PromotionYearGroup implements Comparable {
        public String groupName { get; private set; }
        public String height { get; private set; }
        public Integer heightInt { get; set { heightInt = value; height = '' + heightInt + 'px'; } }
        
        public ASI_HK_CRM_PromotionYearGroup(String groupName) {
            this.groupName = groupName;
        }
        
        public Integer compareTo(Object objectToCompareTo) {
            return this.groupName.compareTo(((ASI_HK_CRM_PromotionYearGroup)objectToCompareTo).groupName);
        }
    }
    
    public with sharing class ASI_HK_CRM_PromotionYearQueue {
        public ASI_HK_CRM_PromotionYearGroup eventGroup { get; set; }
        public List<List<ASI_HK_CRM_PromotionYearEvent>> events { get; set; }
        
        public ASI_HK_CRM_PromotionYearQueue(ASI_HK_CRM_PromotionYearGroup eventGroup) {
            this(eventGroup, new List<ASI_HK_CRM_PromotionYearEvent>());
        }
        public ASI_HK_CRM_PromotionYearQueue(ASI_HK_CRM_PromotionYearGroup eventGroup, List<ASI_HK_CRM_PromotionYearEvent> events) {
            this.eventGroup = eventGroup;
            this.setEvents(events);
        }
        
        public void setEvents(List<ASI_HK_CRM_PromotionYearEvent> inputEvents) {
            this.events = new List<List<ASI_HK_CRM_PromotionYearEvent>>();
            inputEvents.sort();
            for (ASI_HK_CRM_PromotionYearEvent inputEvent : inputEvents) {
                Boolean foundEventLine = false;
                for (List<ASI_HK_CRM_PromotionYearEvent> eventLine : this.events) {
                    if (!isConflict(eventLine, inputEvent)) {
                        eventLine.add(inputEvent);
                        foundEventLine = true;
                        break;
                    }
                }
                if (!foundEventLine) {
                    List<ASI_HK_CRM_PromotionYearEvent> newEventLine = new List<ASI_HK_CRM_PromotionYearEvent>();
                    this.events.add(newEventLine);
                    newEventLine.add(inputEvent);
                }
            }
        }
        
        public Integer calculatePosition(Integer initTop, Integer incrementY) {
            for (List<ASI_HK_CRM_PromotionYearEvent> eventLine : events) {
                for (ASI_HK_CRM_PromotionYearEvent theEvent : eventLine) {
                    theEvent.topPos = '' + initTop + 'px';
                }
                initTop += incrementY;
            }
            return initTop;
        }
        
        public Boolean isConflict(List<ASI_HK_CRM_PromotionYearEvent> eventLine, ASI_HK_CRM_PromotionYearEvent checkEvent) {
            Integer eventLineSize = eventLine.size();
            for (Integer i = eventLineSize - 1; i >= 0; i--) {
                ASI_HK_CRM_PromotionYearEvent e = eventLine.get(i);
                if ((compareYearMonthOfTwoDate(e.startDate , checkEvent.startDate) >= 0 && compareYearMonthOfTwoDate(e.startDate, checkEvent.endDate) <= 0)
                    || (compareYearMonthOfTwoDate(e.endDate, checkEvent.startDate) >= 0 && compareYearMonthOfTwoDate(e.endDate, checkEvent.endDate) <= 0)
                    || (compareYearMonthOfTwoDate(e.startDate, checkEvent.startDate) <= 0 && compareYearMonthOfTwoDate(e.endDate, checkEvent.endDate) >= 0)) {
                    return true;
                }
            }
            return false;
        }
        
        public Integer compareYearMonthOfTwoDate(Date theDate1, Date theDate2) {
            if (theDate1.year() > theDate2.year()) {
                return 1;
            } else if (theDate1.year() < theDate2.year()) {
                return -1;
            } else { // if (theDate1.year() == theDate2.year())
                if (theDate1.month() > theDate2.month()) {
                    return 1;
                } else if (theDate1.month() < theDate2.month()) {
                    return -1;
                } else { // if (theDate1.month() == theDate2.month())
                    return 0;
                }
            }
        }
    }
    
    public with sharing class ASI_HK_CRM_PromotionYearEvent implements Comparable {
        public ID sObjId { get; set; }
        public Object groupValue { get; set; }
        public String title { get; set; }
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public String popupId { get; set; }
        public String topPos { get; set; }
        public String leftPos { get; private set; }
        public String width { get; private set; }
        public String height { get; private set; }
        public String color { get {if (color == null) color = '#FFFFFF'; return color; } set; }
        public String backgroundColor { get {if (backgroundColor == null) backgroundColor = '#6777CC'; return backgroundColor; } set; }
        
        public void setLayout(Date fromDate, Date toDate, Integer initLeft, Integer monthWidth, Integer eventHeight, Integer beginXSpace, Integer endXSpace) {
            startDate = fromDate > startDate ? fromDate : startDate;
            endDate = toDate < endDate ? toDate : endDate;
            this.leftPos = String.valueOf(initLeft + (fromDate.monthsBetween(startDate) * monthWidth) + beginXSpace) + 'px';
            this.width = String.valueOf(((startDate.monthsBetween(endDate) + 1) * monthWidth) - beginXSpace - endXSpace) + 'px';
            this.height = String.valueOf(eventHeight) + 'px';
        }
        
        public Integer compareTo(Object objectToCompareTo) {
            Date compareToStartDate = ((ASI_HK_CRM_PromotionYearEvent)objectToCompareTo).startDate;
            if (this.startDate == null || compareToStartDate == null) {
                if (this.startDate == compareToStartDate) return 0;
                return this.startDate == null ? -1 : 1;
            } else if (this.startDate > compareToStartDate) {
                return 1;
            } else if (this.startDate < compareToStartDate) {
                return -1;
            } else if (this.startDate == compareToStartDate) {
                return 0;
            }
            return null;
        }
    }
    
}