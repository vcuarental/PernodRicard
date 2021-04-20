/*
=== Usage ===
    Allow users creating and editing multiple records in single page
    
=== Steps ===
    - Import the codes (MassCreateAndUpdateController.cls, MassCreateAndUpdate.component)
    - Create Custom Setting named "MassCreateAndUpdateSetting" and Setting Type is List
    - Create fields for MassCreateAndUpdateSetting: DisplayFields__c, FieldsToParam__c
    - Create a VF page including the component in MassCreateAndUpdate.component
    - Set the component attribute according to your preferences (See 
      MassCreateAndUpdate.component for detail)
 
=== Custom Setting Description ===
    MassCreateAndUpdateSetting:
        Name:
            Specify which object and record type this setting belongs to
            Format: Object__c:Record_Type_1
            If record type is not specified, the settings would be applied to all types
                of the object
        DisplayFields__c:
            The columns of fields which are shown in the edit page
            Format: Field1__c, Field2__c&req=T&width=150px, Field3__c&read=A
            Attributes:
                Attribute Name      Values          Description
                req                 T               Whether the field is mandatory
                width               150px/25%       The column width
                read                N/O/A           Set this attribute if need readonly. readonly for (N = new records, O = old records, A = all records)
        FieldsToParam__c:
            Show the default value of fields when creating new record
            Specify the mapping of field name (API Name) and URL parameter names
            Format: Field1__c => param1
            In above example, if the url is "https://xxx?param1=DefaultValue", it
                will assign "DefaultValue" to Field1__c when creating new record
*/
public with sharing class ASI_TnE_MassCreateAndUpdateController extends ASI_TnE_AbstractComponentController  {

    public static final String ACTION_EDIT = 'edit';
    public static final String ACTION_CLONE = 'clone';
    public static final String ACTION_ADD_NEW = 'add_new';
    public static final String ACTION_REMOVE_NEW = 'remove_new';
    public static final String RTNAME_MASTER = 'General';
    public static final String RTDEVNAME_MASTER = '_General_';
    public static final Integer NUM_OF_HIDDEN_ROW = 15;
    private static final String FIELD_PARAM_REQUIRED = 'req';
    private static final String FIELD_PARAM_COL_WIDTH = 'width';
    private static final String FIELD_PARAM_READ_ONLY = 'read';
    private static final String FIELD_PARAM_COL_KEY = 'ckey';
    private static final String DELIM_SETTING_KEY = ':';
    private static final String DELIM_RT = ',';
    private static final String DELIM_FIELDS = ',';
    private static final String DELIM_FIELD_ELEMENTS = '&';
    private static final String DELIM_FIELD_SETTING = '=';
    private static final String DEF_ORDER_BY = 'Name';

    // Attributes
    public Boolean isFastModeBool { get; set; }
    public String sObjTypeStr { get; set; }
    public String displayFieldsStr { get; set; }
    public String whereStatm { get; set; }
    public String orderByStr { get { if (orderByStr == null || orderByStr.trim().length() == 0) orderByStr = DEF_ORDER_BY; return orderByStr; } set; }
    public String includeRecordTypes { get; set; }
    public String fieldToURLParamStr { get; set; }
    public String pageBlockTitleStr { get {if (pageBlockTitleStr == null) return sObjLabel; return pageBlockTitleStr;} set; }
    public String successLink { get; set; }
    public String cancelLink { get; set; }
    public String mode { get { if (mode == null) mode = MODE_BOTH; return mode; } set { if (value == null) mode = MODE_BOTH; else mode = value.toUpperCase(); } }
    public Boolean isDefaultEditVal { get; set; }
    public Boolean showAllRT { get; set; }
    public Boolean isUseFirstRowForNew { get; set; }
    public String altSObjectTypeName { get; set; }
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    // Data used in VF page
    public String sObjLabel { get; private set; }
    public List<RecordTypeElement> theRecordTypeElementList { get; set; }
    public List<SelectOption> recordTypeOptionList { get; set; }
    public Integer numOfRecordType { get; set; }
    public String selectedRecordType { get; set; }
    public List<PageBlockActionBtn> pageBlockActionBtnList { get; set; }
    
    // Modes
    public String MODE_NEW { get { return 'NEW'; } private set; }
    public String MODE_EDIT { get { return 'EDIT'; } private set; }
    public String MODE_BOTH { get { return 'BOTH'; } private set; }
    // Parameter Names
    public String PARAM_RTID { get { return 'rtid'; } private set;} // record type id
    public String PARAM_TRID { get { return 'rid'; } private set;} // record id
    public String PARAM_NUM_OF_SHOW_ROW { get { return 'showRowNum'; } private set;}
    
    private Schema.SObjectType sObjType;
    private Map<String, String> fieldNameToValueMap;
    private decimal last_plan_balance;
    
    public ASI_TnE_MassCreateAndUpdateController() {}

    public ASI_TnE_objectPickListHelper helper1{ get; set; }
    public String lookupToPicklist { get; set; } 
    public List<String> checkPicklist { get; set; }
    public Set<String> checkPicklistSet { get; set; }
    public Map<String,List<selectOption>> allLookPicklist { get; set;} 
    
    public Set<String> getcheckPicklistSet(){
        return checkPicklistSet;
    }
    
    public Boolean init() {
        
        checkPicklist = lookupToPicklist.split(',', 0);
        checkPicklistSet = new Set<String>();
        allLookPickList = new Map<String,List<selectOption>>();
        
        if(checkPicklist != null)
         if(checkPicklist[0] != 'hello')
          for(String s: checkPicklist){ 
             checkPicklistSet.add(s);
             helper1 = new ASI_TnE_objectPickListHelper(sObjTypeStr,s);
             allLookPickList.put(s,helper1.pickList);
          }


        // Initialize basic components
        if (pageController != null)
            this.pageBlockActionBtnList = ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_initPageBlockActionButtonList();
        if (this.pageBlockActionBtnList == null) this.pageBlockActionBtnList = new List<PageBlockActionBtn>();
        
        // Handle SF object information
        sObjType = Schema.getGlobalDescribe().get(sObjTypeStr);
        sObjLabel = sObjType.getDescribe().getLabel();
        
        // Handle record types
        List<RecordType> recordTypeList = this.getRecordTypeList();
        if (recordTypeList.size() == 0) { // Record type is not enabled for this sobject type
            recordTypeList.add(new RecordType(Name = RTNAME_MASTER, DeveloperName = RTDEVNAME_MASTER));
        }
        this.numOfRecordType = recordTypeList.size();
        this.selectedRecordType = recordTypeList.get(0).DeveloperName;
        
        // Handle display fields
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        List<DisplayCol> commonDisplayColList= getDisplayColListByFieldStr(displayFieldsStr, sObjFieldMap);
        
        // Handle default field values
        Map<String, String> fieldToValueMap = new Map<String, String>();
        if (fieldToURLParamStr != null) fieldToValueMap = getDefaultFieldValueMapFromStr(fieldToURLParamStr);
        
        recordTypeOptionList = new List<SelectOption>();
        Map<String, ASI_TnE_MassCreateAndUpdateSetting__c> allSettingMap = ASI_TnE_MassCreateAndUpdateSetting__c.getAll();
        if (mode == MODE_EDIT) isDefaultEditVal = true;
        
        theRecordTypeElementList = new List<RecordTypeElement>();
        // Handle record types one by one
        for (RecordType tempRT : recordTypeList) {
            Boolean hasRecordType = (tempRT.DeveloperName != RTDEVNAME_MASTER);
            ID rtId = hasRecordType ? tempRT.Id : null;
            recordTypeOptionList.add(new SelectOption(tempRT.DeveloperName, tempRT.Name));
            ASI_TnE_MassCreateAndUpdateSetting__c rtSetting = getSettingByRecordType(allSettingMap, tempRT.DeveloperName);
            // Get the display fields from settings if no common display fields defined
            List<DisplayCol> displayColList = commonDisplayColList;
            if (commonDisplayColList == null || commonDisplayColList.size() == 0) {
                displayColList = getDisplayColListFromSetting(rtSetting, sObjFieldMap);
            }
            
            // Get default field values from settings if no common default values defined
            if (fieldToValueMap.size() == 0 && fieldToURLParamStr != null)
                fieldToValueMap = getDefaultFieldValueMapFromStr(rtSetting.ASI_TnE_FieldsToParam__c);
            
            // Check other required fields
            Boolean needRecordTypeIdField = hasRecordType;
            if (hasRecordType) {
                for (DisplayCol dc : displayColList) {
                    for (DisplayField df : dc.displayFieldList) {
                        if (df.name.toUpperCase() == 'RECORDTYPEID')
                            needRecordTypeIdField = false;
                    }
                }
            }
            // Generate the query string
            List<sObject> existingSObjList = new List<sObject>();
            if (mode == MODE_BOTH || mode == MODE_EDIT) {
                String displayFieldCommaStr = getCommaStringFromDisplayColList(displayColList);
                if (needRecordTypeIdField) displayFieldCommaStr += ', RecordTypeId';
                String queryStr = 'SELECT ' + displayFieldCommaStr + ' FROM ' + sObjTypeStr;
                String wholeWhereStatm = '';
                if (whereStatm != null && whereStatm.trim().length() > 0) wholeWhereStatm += ' (' + whereStatm + ')';
                if (hasRecordType) wholeWhereStatm += (wholeWhereStatm.length() == 0 ? '' : ' AND') + ' (RecordTypeId = :rtId)';
                if (wholeWhereStatm.trim().length() > 0) queryStr += ' WHERE ' + wholeWhereStatm;
                if (orderByStr != null && orderByStr.trim().length() > 0) queryStr += ' ORDER BY ' + orderByStr;
                
                // Query the results
                existingSObjList = Database.query(queryStr);
            }
            theRecordTypeElementList.add(new RecordTypeElement(sObjType, tempRT, existingSObjList, displayColList, fieldToValueMap, isDefaultEditVal, isUseFirstRowForNew, isFastModeBool));
        }
        return true;
    }
    
    /**
     * Methods used by other classes
     */
    
    public void clearAll() {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            rtEle.deleteAll();
        }
    }
    
    /**
     * Page Actions
     */
    
    public PageReference commitAll() {
        List<sObject> insertList = new List<sObject>();
        List<sObject> updateList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            for (TableRow tr : rtEle.myRecordList) {
                if (!tr.isBlankAndHidden) {
                    if (tr.isDelete) {
                        if (tr.mySObj.Id != null)
                            deleteList.add(tr.mySObj);
                    } else if (tr.isNew) {
                        insertList.add(tr.mySObj.clone(false, true)); 
                    } else if (tr.isEdit) {
                        updateList.add(tr.mySObj);
                    }
                }
            }
        }
        System.Savepoint sp = database.setSavepoint();
        if (deleteList.size() > 0) {
            try {
                database.delete(deleteList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = deleteList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(dmle.getDmlMessage(i));
                }
                database.rollback(sp);
                return null;
            }
        }
        if (updateList.size() > 0) {
            try {
                database.update(updateList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = updateList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(dmle.getDmlMessage(i));                  
                }
                database.rollback(sp);
                return null;
            }
        }
        if (insertList.size() > 0) {
            try {
                database.insert(insertList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = insertList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(dmle.getDmlMessage(i));
                }
                database.rollback(sp);
                return null;
            }
        }        

        return new PageReference(successLink);
    }
    
    /*
     * Methods for non-fast mode only
     * Start {
     */
    public PageReference triggerPageBlockAction() {
        PageReference redirectPage = null;
        String pbBtnId = ApexPages.currentPage().getParameters().get('PARAM_PB_BTN_ID');
        if (pageController != null) redirectPage = ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerPageBlockAction(this, pbBtnId);
        return redirectPage;
    }
    
    public PageReference addNewRow() {
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.createNewSObject();
        if (pageController != null) ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
        return null;
    }
    public void addNewRowByInfo(String rtDevName, sObject sObj) {
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtDevName);
        TableRow tr = null;
        if (curRTEle != null)
            tr = curRTEle.createNewSObject(sObj);
        if (tr != null && pageController != null)
            ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_ADD_NEW, tr.mySObj);
    }
    
    public PageReference cloneRow() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.cloneNewSObjectByTableRowId(trid);
        if (pageController != null) ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_CLONE, tr.mySObj);
        return null;
    }
    
    public PageReference enableForEdit() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.enableForEditByTableRowId(trid);
        if (pageController != null) ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_EDIT, tr.mySObj);
        return null;
    }
    
    public PageReference removeNew() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageController != null) ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public PageReference deleteOld() {
        Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
        String rtid = urlParamMap.get(PARAM_RTID);
        String trid = urlParamMap.get(PARAM_TRID);
        TableRow tr = deleteRow(rtid, trid);
        if (pageController != null) ((ASI_TnE_MassCreateAndUpdateAbstract)pageController).mcau_triggerActionForSObject(this, ACTION_REMOVE_NEW, tr.mySObj);
        return null;
    }
    
    public TableRow deleteRow(String rtid, String trid) {
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        TableRow tr = curRTEle.removeByTableRowId(trid);
        return tr;
    }
    
    /*
     * Methods for non-fast mode only
     * } End
     */
    
    /*
     * Methods for fast mode only
     * Start {
     */
    
    public PageReference addMoreBlankRows() {
        String rtid = ApexPages.currentPage().getParameters().get(PARAM_RTID);
        String numOfShowRowStr = ApexPages.currentPage().getParameters().get(PARAM_NUM_OF_SHOW_ROW);
        Integer numOfShowRow = numOfShowRowStr != null ? Integer.valueOf(numOfShowRowStr) : 1;
        RecordTypeElement curRTEle = getRTElementByRTDevName(rtid);
        for (Integer i = 0; i < NUM_OF_HIDDEN_ROW; i++) {
            TableRow tr = curRTEle.createNewSObject();
            tr.isBlankAndHidden = true;
        }
        return null;
    }
    
    /*
     * Methods for fast mode only
     * } End
     */
     
    public void refresh() {
    }
    
    private RecordTypeElement getRTElementByRTDevName(String rtId) {
        for (RecordTypeElement rtEle : theRecordTypeElementList) {
            if (rtEle.myRecordType.DeveloperName == rtId)
                return rtEle;
        }
        return null;
    }
    
    /**
     * Methods used by init()
     */
    
    private List<RecordType> getRecordTypeList() {
        List<RecordType> allRecordTypeList = database.query('SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :sObjTypeStr AND IsActive = true ORDER BY Name');
        List<RecordType> recordTypeList = new List<RecordType>();
        // include only part of record types if needed
        if (includeRecordTypes != null) {
            Set<String> recordTypeStringSet = new Set<String>(strToStrList(includeRecordTypes, DELIM_RT));
            for (RecordType tempRT : allRecordTypeList) {
                if (recordTypeStringSet.contains(tempRT.DeveloperName))
                    recordTypeList.add(tempRT);
            }
        } else {
            recordTypeList = allRecordTypeList;
        }
        return recordTypeList;
    }
    
    private ASI_TnE_MassCreateAndUpdateSetting__c getSettingByRecordType(Map<String, ASI_TnE_MassCreateAndUpdateSetting__c> allSettingMap, String recordTypeDevName) {
        String settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? sObjTypeStr : sObjTypeStr + DELIM_SETTING_KEY + recordTypeDevName;
        ASI_TnE_MassCreateAndUpdateSetting__c rtSetting = allSettingMap.get(settingKey);
        if (rtSetting == null) {
            settingKey = (recordTypeDevName == RTDEVNAME_MASTER) ? altSObjectTypeName : altSObjectTypeName + DELIM_SETTING_KEY + recordTypeDevName;
            rtSetting = allSettingMap.get(settingKey);
        }
        return rtSetting;
    }
    
    private List<DisplayCol> getDisplayColListByFieldStr(String fieldsStr, Map<String, Schema.SObjectField> sObjFieldMap) {
        //Add by Abel
        List<DisplayCol> result = new List<DisplayCol>();  
        Set<String> nowPickListSet = getCheckPicklistSet();  //Add by Abel
        boolean fieldIsPicklist = false;  //Add by Abel
        if (fieldsStr != null && fieldsStr.trim().length() > 0) {
            List<String> fieldList = fieldsStr.split(DELIM_FIELDS, 0);
            DisplayCol curDC = null;
            for (String fieldStr : fieldList) { // Field1__c&req=t&key=value, Field2__c
                List<String> fieldEleList = fieldStr.trim().split(DELIM_FIELD_ELEMENTS, 0);
                String fieldDevName = fieldEleList.get(0).trim();
                Schema.SObjectField sObjField = sObjFieldMap.get(fieldDevName);
                if (sObjField != null) { // if field exists
                    // Create display field
                    //Add by Abel
                    fieldIsPicklist = CheckPicklistSet.contains(fieldDevName);  //Add by Abel
                        
                    
                    DisplayField df = new DisplayField(sObjField.getDescribe().getLabel(), fieldDevName, fieldIsPicklist);  //Add by Abel
                    String colKey = null;
                    String colLabel = null;
                    String colWidth = null;
                    if (fieldEleList.size() > 1) {
                        for (Integer i = 1; i < fieldEleList.size(); i++) { // req=t&key=value
                            List<String> keyAndValue = fieldEleList.get(i).split(DELIM_FIELD_SETTING, 2);
                            if (keyAndValue.size() == 2) {
                                String key = keyAndValue.get(0).trim().toLowerCase();
                                String value = keyAndValue.get(1).trim();
                                if (FIELD_PARAM_COL_KEY == key) {
                                    colKey = value;
                                    colLabel = value;
                                } else if (FIELD_PARAM_COL_WIDTH == key) {
                                    // TODO: get the maximum value
                                    colWidth = value;
                                }
                                assignDisplayFieldProperty(df, key, value);
                            }
                        }
                        if (colLabel == null) {
                            colLabel = df.label;
                            df.label = null;
                        }
                    }
                    if (curDC == null || colKey == null || curDC.colKey != colKey) {
                        curDC = new DisplayCol(colKey, colLabel);
                        result.add(curDC);
                        curDC.colWidth = colWidth;
                    }
                    curDC.addDisplayField(df);
                } else {
                    System.debug('Unknown field: ' + fieldDevName);
                }
            }
        }
        if (result.size() == 0) {
            DisplayCol dc = new DisplayCol(null, null);
            result.add(dc);
            dc.addDisplayField(new DisplayField('Name', 'Name'));
        }
        return result;
    }
    
    private void assignDisplayFieldProperty(DisplayField df, String key, String value) {
        if (FIELD_PARAM_REQUIRED == key) {
            if (value.toLowerCase() == 't' || value.toLowerCase() == 'true')
                df.isRequired = true;
        } else if (FIELD_PARAM_COL_WIDTH == key) {
            df.width = value;
        } else if (FIELD_PARAM_READ_ONLY == key) {
            df.readonlyMode = value.toLowerCase();
        } else if (FIELD_PARAM_COL_KEY == key) {
            df.colKey = value;
        }
    }
    
    private List<DisplayCol> getDisplayColListFromSetting(ASI_TnE_MassCreateAndUpdateSetting__c rtSetting, Map<String, Schema.SObjectField> sObjFieldMap) {
        if (rtSetting == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'List of display fields is not specified for the object: ' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        String settingDF = rtSetting.ASI_TnE_DisplayFields__c;
        if (settingDF == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Empty displayField' + sObjTypeStr + '. Please edit Custom Setting MassCreateAndUpdateSetting'));
            return null;
        }
        return getDisplayColListByFieldStr(settingDF, sObjFieldMap);
    }
    
    private String getCommaStringFromDisplayColList(List<DisplayCol> dcList) {
        String result = '';
        for (DisplayCol dc : dcList) {
            List<DisplayField> dfList = dc.displayFieldList;
            for (DisplayField df : dfList) {
                result += ', ' + df.name;
            }
        }
        if (result.length() > 2)
            return result.substring(2);
        return '';
    }
    
    private Map<String, String> getDefaultFieldValueMapFromStr(String fieldToParamStr) {
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        if (fieldToParamStr != null && fieldToParamStr.trim().length() > 0) {
            Map<String, String> urlParamMap = ApexPages.currentPage().getParameters();
            Map<String, String> fieldToParamMap = strToStrMap(fieldToParamStr);
            Set<String> fieldNameSet = fieldToParamMap.keySet();
            for (String fieldName : fieldNameSet) {
                String paramName = fieldToParamMap.get(fieldName);
                fieldNameToValueMap.put(fieldName, urlParamMap.get(paramName));
            }
        }
        return fieldNameToValueMap;
    }
    
    /**
     * Other Utils
     */
    
    private List<String> strToStrList(String inputStr) { return this.strToStrList(inputStr, ','); }
    private List<String> strToStrList(String inputStr, String delim) {
        List<String> result = new List<String>();
        if (inputStr != null && delim != null) {
            List<String> inputStrList = inputStr.split(delim, 0);
            for (String ele : inputStrList) {
                result.add(ele.trim());
            }
        }
        return result;
    }
    
    private String strListToStr(List<String> inputStrList) { return this.strListToStr(inputStrList, ','); }
    private String strListToStr(List<String> inputStrList, String delim) {
        String result = '';
        if (inputStrList != null && delim != null) {
            for (String ele : inputStrList) {
                result += delim + ele;
            }
        }
        if (result.length() >= delim.length()) {
            return result.substringAfter(delim);
        }
        return '';
    }
    
    private Map<String, String> strToStrMap(String mapStr) {
        Map<String, String> result = new Map<String, String>();
        if (mapStr.trim().length() > 0) {
            List<String> mapList = strToStrList(mapStr, ',');
            for (String ms : mapList) {
                List<String> keyAndValue = ms.split('=>', 2);
                if (keyAndValue.size() != 2)
                    ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.WARNING, 'Incorrect Map String: ' + mapStr + '. Please check the Custom Setting MassCreateAndUpdateSetting'));
                else
                    result.put(keyAndValue.get(0).trim(), keyAndValue.get(1).trim());
            }
        }
        return result;
    }
    
    public class RecordTypeElement {
        public RecordType myRecordType { get; set; }
        public List<TableRow> myRecordList { get; set; }
        public List<TableRow> myDisplayRecordList {
            get {
                if (myRecordList == null) return null;
                List<TableRow> tempList = new List<TableRow>();
                for (TableRow tr : myRecordList)
                    if (tr.isDelete != true)
                        tempList.add(tr);
                return tempList;
            }
            set;
        }
        public List<DisplayCol> myDisplayColList { get; set; }
        public Set<String> myDisplayFieldSet;
        private Schema.SObjectType sObjType;
        private Map<String, String> fieldNameToValueMap;
        private Boolean hasRecordType;
        public Integer tableRowNextId;
        private Boolean isCreateBeforeFirstRow;
        private Boolean isFastMode;
        
        public RecordTypeElement(Schema.SObjectType sObjType, RecordType recordType, List<sObject> sObjList, List<DisplayCol> displayColList
            , Map<String, String> fieldNameToValueMap, Boolean isAllEdit, Boolean isCreateBeforeFirstRow, Boolean isFastMode) {
            this.myRecordType = recordType;
            this.myDisplayColList = displayColList;
            this.sObjType = sObjType;
            this.fieldNameToValueMap = fieldNameToValueMap;
            this.hasRecordType = (myRecordType.DeveloperName != RTDEVNAME_MASTER);
            this.tableRowNextId = 1;
            this.isCreateBeforeFirstRow = isCreateBeforeFirstRow;
            this.isFastMode = isFastMode;
            this.myRecordList = new List<TableRow>();
            
            for (sObject tempSObj : sObjList) {
                TableRow tr = new TableRow(this, tempSObj, false);
                if (isAllEdit) tr.isEdit = true;
                this.myRecordList.add(tr);
            }
            if (isFastMode) {
                for (Integer i = 0; i < NUM_OF_HIDDEN_ROW; i++) {
                    TableRow tr = createNewSObject(isCreateBeforeFirstRow);
                    tr.isBlankAndHidden = true;
                }
            }
            // Assign display fields developer name to set for later search
            Schema.DescribeSObjectResult sObjTypeDescribe = sObjType.getDescribe();
            Map<String, Schema.SObjectField> sObjFieldMap = sObjTypeDescribe.fields.getMap();
            this.myDisplayFieldSet = new Set<String>();
            for (DisplayCol dc : displayColList) {
                List<DisplayField> displayFieldList = dc.displayFieldList;
                for (DisplayField df : displayFieldList) {
                    this.myDisplayFieldSet.add(df.name);
                }
            }
        }
        
        public TableRow enableForEditByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                tr.isEdit = true;
            return tr;
        }
        
        public TableRow removeByTableRowId(String trId) {
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (tr.id != null && tr.id == trid) {
                    if (tr.isNew) {
                        return myRecordList.remove(i);
                    } else {
                        tr.isDelete = true;
                        return tr;
                    }
                }
            }
            return null;
        }
        
        public TableRow createNewSObject() { return createNewSObject(this.isCreateBeforeFirstRow); }
        public TableRow createNewSObject(Boolean beforeFirstRow) { return createNewSObject(!beforeFirstRow ? this.myRecordList.size() : 0, this.sObjType.newSObject()); }
        public TableRow createNewSObject(sObject newSObj) { return createNewSObject(!this.isCreateBeforeFirstRow ? this.myRecordList.size() : 0, newSObj); }
        public TableRow createNewSObject(Integer index, sObject newSObj) {
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            for (String fieldName : fieldNameSet) {
                newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
            }
            return addNewTableRow(index, newSObj);
        }
        
        public TableRow cloneNewSObjectByTableRowId(String trId) {
            TableRow tr = getTableRowById(trId);
            if (tr != null)
                return cloneNewSObject(tr.mySObj);
            return null;
        }
        public TableRow cloneNewSObject(sObject sObj) { return cloneNewSObject(sObj, this.isCreateBeforeFirstRow); }
        public TableRow cloneNewSObject(sObject sObj, Boolean beforeFirstRow) { return cloneNewSObject(sObj, !beforeFirstRow ? this.myRecordList.size() : 0); }
        public TableRow cloneNewSObject(sObject sObj, Integer index) {
            sObject newSObj = sObj.clone(false, true, false, false);
            if (hasRecordType)
                newSObj.put('RecordTypeId', myRecordType.Id);
            Set<String> fieldNameSet = fieldNameToValueMap.keySet();
            for (String fieldName : fieldNameSet) {
                if (!myDisplayFieldSet.contains(fieldName))
                    newSObj.put(fieldName, fieldNameToValueMap.get(fieldName));
            }
            return addNewTableRow(index, newSObj);
        }
        
        public void deleteAll() {
            List<TableRow> newTRList = new List<TableRow>();
            Integer size = myRecordList.size();
            for (Integer i = 0; i < size; i++) {
                TableRow tr = myRecordList.get(i);
                if (!tr.isNew) {
                    tr.isDelete = true;
                    newTRList.add(tr);
                }
            }
            myRecordList = newTRList;
        }
        
        private TableRow addNewTableRow(Integer index, SObject newSObj) {
            TableRow tr = new TableRow(this, newSObj, true);
            if (this.myRecordList.size() == 0 || index >= this.myRecordList.size())
                this.myRecordList.add(tr);
            else
                this.myRecordList.add(index, tr);
            return tr;
        }
    
        private TableRow getTableRowBySObjId(ID sObjId) {
            for (TableRow tr : myRecordList) {
                if (tr.mySObj.Id != null && tr.mySObj.Id == sObjId)
                    return tr;
            }
            return null;
        }
        private TableRow getTableRowById(String trid) {
            for (TableRow tr : myRecordList) {
                if (tr.id != null && tr.id == trid)
                    return tr;
            }
            return null;
        }
    }
    
    public class TableRow {
        public String id { get; private set; }
        public sObject mySObj { get; set; }
        public Boolean isNew { get; set; }
        public Boolean isEdit { get; set; }
        public Boolean isDelete { get; set; }
        public Boolean isBlankAndHidden { get; set; }
        private RecordTypeElement rtEle;
        
        public TableRow(RecordTypeElement rtEle, sObject mySObj, Boolean isNew) {
            this.id = String.valueOf(rtEle.tableRowNextId++);
            this.mySObj = mySObj;
            this.isNew = isNew;
            this.isEdit = isNew;
            this.isDelete = false;
            this.isBlankAndHidden = false;
        }
    }
    
    public class DisplayCol {
        public String colKey { get; set; }
        public String colLabel { get; set; }
        public List<DisplayField> displayFieldList { get; set; }
        public String colWidth { get; set; }
        
        public DisplayCol(String colKey, String colLabel) {
            this.colKey = colKey;
            this.colLabel = colLabel;
            this.displayFieldList = new List<DisplayField>();
        }
        
        public void addDisplayField(DisplayField displayField) {
            this.displayFieldList.add(displayField);
        }
    }
    
    public class DisplayField {
        public String label { get; set; }
        public String name { get; set; }
        public Boolean isRequired { get; set; }
        public String readonlyMode { get; set; }
        public String width { get; set; }
        public String colKey { get; set; }
        public Boolean isPickList { get; set; }  //Add by Abel
        
        public DisplayField(String label, String name) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
        }

//Add by Abel        
        public DisplayField(String label, String name, Boolean isPickList) {
            this.label = label;
            this.name = name;
            this.isRequired = false;
            this.readonlyMode = null;
            this.width = 'auto';
            this.isPickList = isPickList;
        }        
        
    }
    
    public with sharing class PageBlockActionBtn {
        public String id { get; set; }
        public String label { get; set; }
        
        public PageBlockActionBtn(String id, String label) {
            this.id = id;
            this.label = label;
        }
    }   
}