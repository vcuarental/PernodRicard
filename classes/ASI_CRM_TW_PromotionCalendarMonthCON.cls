public with sharing class ASI_CRM_TW_PromotionCalendarMonthCON extends ASI_CRM_TW_PromotionCalendarCommonClass {
    
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

    //subbrand filter
    public ASI_CRM_Promotion_Unit__c promotionunit {get;set;}

    //backgroundcolor, channel filter
    public ASI_HK_CRM_Promotion__c promotion {get;set;}

    //MultiselectPicklist
    //public List<SelectOption> leftitemgroupList {get;set;}
    //public List<SelectOption> rightitemgroupList {get;set;}
    set<String> itemgrouplvalues = new Set<String>{};
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}
    set<string> leftvalues = new Set<string>();
    set<string> rightvalues = new Set<string>();

    set<String> Channellvalues = new Set<String>{};
    public List<string> leftselected2{get;set;}
    public List<string> rightselected2{get;set;}
    set<string> leftvalues2 = new Set<string>();
    set<string> rightvalues2 = new Set<string>();
    
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
            + ' ((ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate))'
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TW_ChannelPromotion\' or RecordType.DeveloperName = \'ASI_CRM_TW_TailorMadePromotion\') ';
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);
        List<ASI_HK_CRM_PromotionMonthEvent> result = new List<ASI_HK_CRM_PromotionMonthEvent>();
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
            for (String popupField : POPUP_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        return result;
    }

    @RemoteAction
    public static List<ASI_HK_CRM_PromotionMonthEvent> retrievefilterPromotionsByTimeRange(String fromDateStr, String toDateStr, String Channel, String subBrand, String ItemGroup, String BgColor) {
        system.debug('++++Channel: '+Channel);
        system.debug('++++subBrand: '+subBrand);
        system.debug('++++BgColor: '+ BgColor);
        system.debug('++++ItemGroup: '+ ItemGroup);

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
        fieldSet.add(' (select id, ASI_CRM_Sub_brand__c, ASI_CRM_Item_Group__c, ASI_CRM_Item_Group__r.Name, ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from Promotion_Units__r ) ');

        String fieldsStr = String.join(new List<String>(fieldSet), ', ');

        String whereStatm = '';
        if(Channel != '') 
        {
            list<string> channellist = new list<string>();
            channellist = Channel.split(';');
            string channelstring='';

            for(integer i=0; i<channellist.size(); i++)
            {
                if(i==0){
                    channelstring += '(\'' + channellist[i] + '\'';
                }
                else {
                    channelstring +=  ', \'' + channellist[i] + '\'';
                }
            }
            channelstring += ')';

            whereStatm += ' AND  ASI_CRM_Channel__c includes ' + channelstring;
        }
        if(BgColor != null && BgColor != '')
        {
            whereStatm += ' AND ASI_HK_CRM_Background_Color__c = ' + '\'' + BgColor + '\'';
        }

        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_HK_CRM_Promotion__c'
            + ' WHERE '
            + ' ((ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate))'
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TW_ChannelPromotion\' or RecordType.DeveloperName = \'ASI_CRM_TW_TailorMadePromotion\') '
            + whereStatm;
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);

        if(ItemGroup != '' && ItemGroup != null)
        {
            set<string> subbrandID_set = new set<string>();
            map<string, map<string, ASI_MFM_Item_Group__c>> subbrandId_Itemgroup_map = new map<string, map<string, ASI_MFM_Item_Group__c>>();
            set<ASI_HK_CRM_Promotion__c> reloadpromotionSet = new set<ASI_HK_CRM_Promotion__c>();
            List<ASI_HK_CRM_Promotion__c> reloadpromotionList = new List<ASI_HK_CRM_Promotion__c>();

            list<string> ItemGroup_L = new list<string>();
            set<string> ItemGroup_set = new set<string>();
            ItemGroup_L = ItemGroup.split(';');
            //list<selectoption> tempSO = getSelectedValues();
            for(string s : ItemGroup_L)
            {
                ItemGroup_set.add(s);
            }

            for(ASI_HK_CRM_Promotion__c PL : promotionList)
            {
                for(ASI_CRM_Promotion_Unit__c PU : PL.Promotion_Units__r)
                {
                    if(ItemGroup_set.contains(PU.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c))
                    {
                        reloadpromotionSet.add(PL);
                    }
                }
            }

            if(reloadpromotionSet.size() > 0)
            {
                reloadpromotionList.addall(reloadpromotionSet);
            }

            promotionList = reloadpromotionList;
        }

        List<ASI_HK_CRM_PromotionMonthEvent> result = new List<ASI_HK_CRM_PromotionMonthEvent>();
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
            for (String popupField : POPUP_DISPLAY_FIELDS_PMT) {
                others.put(popupField, objToStr(pmt.get(popupField)));
            }
            event.otherValues = others;
            result.add(event);
        }
        return result;
    }

    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }

    public PageReference selectclick2(){
        rightselected2.clear();
        for(String s : leftselected2){
            leftvalues2.remove(s);
            rightvalues2.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick2(){
        leftselected2.clear();
        for(String s : rightselected2){
            rightvalues2.remove(s);
            leftvalues2.add(s);
        }
        return null;
    }

    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }

    public List<SelectOption> getunSelectedValues2(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues2);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues2(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues2);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }

    public ASI_CRM_Promotion_Unit__c getpromotionunit()
    {
        if(promotionunit == null)
        {
            promotionunit = new ASI_CRM_Promotion_Unit__c();
        }
        return promotionunit;
    }

    public ASI_HK_CRM_Promotion__c getpromotion()
    {
        if(promotion == null)
        {
            promotion = new ASI_HK_CRM_Promotion__c();
            promotion.ASI_HK_CRM_Background_Color__c = '';
        }
        return promotion;
    }

    @RemoteAction
    public static set<string> getitemgrouplvalue(String fromDateStr, String toDateStr)
    {
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
        fieldSet.add(' (select id, ASI_CRM_Sub_brand__c, ASI_CRM_Item_Group__c, ASI_CRM_Item_Group__r.Name, ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from Promotion_Units__r ) ');
        String fieldsStr = String.join(new List<String>(fieldSet), ', ');
        String queryStr = 'SELECT ' + fieldsStr
            + ' FROM ASI_HK_CRM_Promotion__c'
            + ' WHERE '
            + ' ((ASI_HK_CRM_Promotion_Start_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_Start_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_End_Date__c >= :fromDate AND ASI_HK_CRM_Promotion_End_Date__c <= :toDate)'
            + ' OR (ASI_HK_CRM_Promotion_Start_Date__c < :fromDate AND ASI_HK_CRM_Promotion_End_Date__c > :toDate))'
            + ' AND (RecordType.DeveloperName = \'ASI_CRM_TW_ChannelPromotion\' or RecordType.DeveloperName = \'ASI_CRM_TW_TailorMadePromotion\') ';
        List<ASI_HK_CRM_Promotion__c> promotionList = database.query(queryStr);

        system.debug('++++promotionList: '+promotionList);

        set<String> itemgrouplvalues = new set<String>();
        for(ASI_HK_CRM_Promotion__c PO : promotionList)
        {
            for(ASI_CRM_Promotion_Unit__c PU : PO.Promotion_Units__r)
            {
                itemgrouplvalues.add(PU.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c);
            }
        }

        return itemgrouplvalues;
    }

    public void getChannellvalue()
    {
        Channellvalues = new set<String>();

        ASI_CRM_TW_Picklist_Setting__mdt listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TW_Picklist_Setting__mdt
                                                                WHERE ASI_CRM_Object__c = 'ASI_HK_CRM_Promotion__c'
                                                                AND (ASI_CRM_Record_Type__c = 'TW Channel Promotion' OR ASI_CRM_Record_Type__c = 'TW Tailor Made Promotion')
                                                                AND ASI_CRM_Field__c = 'ASI_CRM_Channel__c'  LIMIT 1];

        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        For(String s : tmpString){
            Channellvalues.add(s);
        }


        leftselected2 = new List<String>();
        rightselected2 = new List<String>();
        leftvalues2 = new Set<string>();
        leftvalues2.addAll(Channellvalues);
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

    public ASI_CRM_TW_PromotionCalendarMonthCON() {
        super(CALENDAR_TYPE_MONTH);
        Date todayDate = Date.today();
        this.curYearStr = String.valueOf(todayDate.year());
        this.curMonthStr = String.valueOf(todayDate.month() - 1);
        this.pmtPopupTemplate = generatePopupTemplateData();


        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(itemgrouplvalues);

        getChannellvalue();

        promotionunit = getpromotionunit();
        promotion = getpromotion();
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