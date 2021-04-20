public with sharing class EUR_CRM_WYSIWYGEditorController {

    private static final Set<String> systemFields = new Set<String>{ 'Id',
                                                                    'IsDeleted',
                                                                    'CreatedById',
                                                                    'CreatedDate',
                                                                    'LastModifiedById',
                                                                    'LastModifiedDate',
                                                                    'SystemModstamp'};
    private final static Map<String, Set<String>> typesOperatorsMap = new Map<String, Set<String>>{
            'PICKLIST' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than'//, 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'STRING' => new Set<String>{
                    'equals', 'not equal to'//, 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'TEXTAREA' => new Set<String>{
                    'equals', 'not equal to'//, 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'PHONE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'EMAIL' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'URL' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal', 'contains', 'does not contain', 'starts with', 'ends with'
            },
            'MULTIPICKLIST' => new Set<String>{
                    'equals', 'not equal to', 'includes', 'excludes'
            },
            'BOOLEAN' => new Set<String>{
                    'equals', 'not equal to'
            },
            'ID' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'REFERENCE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DOUBLE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than'//, 'less or equal', 'greater or equal'
            },
            'CURRENCY' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than'//, 'less or equal', 'greater or equal'
            },
            'PERCENT' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than'//, 'less or equal', 'greater or equal'
            },
            'DATE' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than'//, 'less or equal', 'greater or equal'
            },
            'DATETIME' => new Set<String>{
                    'equals', 'not equal to', 'less than', 'greater than', 'less or equal', 'greater or equal'
            },
            'DEFAULT' => new Set<String>{
                    'equals', 'not equal to'
            }
    };
    public static final Set<String> temporaryBannedTypes = new Set<String>{
            'PHONE',
            'EMAIL',
            'URL',
//            'MULTIPICKLIST',
            'BOOLEAN',
            'ID',
//            'REFERENCE',
            'DATETIME'
    };

    public boolean disableButtons = true;
    public boolean isNewDoc {get;set;}
    public Id chosenFolder{ get; set; } 
    public Id chosenFolderNew{ get; set; } 
    public Id chosenDoc{ get; set; }
    public Map<Id,Document> docDescription{ get; set; }
    public String docName{ get; set; }
    public String devName;
    public String countryCode {
        get {
            if(isNewDoc == true) return countryCode;
            if(chosenDoc != null && docDescription != null && docDescription.get(chosenDoc) != null && !String.isEmpty(docDescription.get(chosenDoc).Description)){
                String descr = docDescription.get(chosenDoc).Description;
                DocumentFields dfs = (DocumentFields) JSON.deserialize(descr, DocumentFields.class);
                countryCode = dfs.countryCode;
            } else {
                countryCode = null;
            }
            return countryCode;
        }
        set;
    }

    public transient String textArea{ get; set; }
    public List<List<String>> objFields{ get; set; }
    public List<List<String>> childTable{ get; set; }

    List<SelectOption> docSO;
    List<SelectOption> folderSO;
    Map<Id,String> folderNameById;
    Map<String,List<String>> dsObjects;

    public EUR_CRM_WYSIWYGEditorController(){
        if (folderSO == null || folderSO.isEmpty()){
            folderSO = getFolders();
        }
        System.debug('\n folderSO => ' + folderSO + '\n');
        if (!folderSO.isEmpty()){
            disableButtons = false;
            chosenFolder = folderSO[0].getValue();
            fetchDocuments();
        } else {
            disableButtons = true;
        }
    }

    private List<SelectOption> getFolders(){
        this.dsObjects = new Map<String,List<String>>();
        Set<String> objects = new Set<String>();
        for(EUR_CRM_CTM_DigitalSignatureSettings__c dsCS : EUR_CRM_CTM_DigitalSignatureSettings__c.getAll().values()){
            if (String.isNotEmpty(dsCS.EUR_CRM_Object__c)){
                dsObjects.put(dsCS.EUR_CRM_Object__c.trim() + dsCS.EUR_CRM_CountryCode__c.trim(), dsCS.EUR_CRM_Detailing__c.deleteWhitespace().split(',|;'));
                objects.add(dsCS.EUR_CRM_Object__c);
            }
        }
        folderNameById = new Map<Id,String>();
        List<SelectOption> folders = new List<SelectOption>();
        for(Folder f : [Select Name, DeveloperName, Id from Folder where Name in :objects and IsReadonly = false and Type = 'Document' order by Name]){
            folders.add(new SelectOption(f.Id,f.Name));
            folderNameById.put(f.Id,f.Name);
        }
        return folders;
    }

    public void fetchDocuments(){
        docDescription = new Map<Id,Document>();
        docSO = new List<SelectOption>();
        for(Document doc : [Select Id, Description, Body, DeveloperName, Name from Document where IsDeleted = false and FolderId = :chosenFolder and Type = 'html' order by Name]){
            docSO.add(new SelectOption(doc.Id,doc.Name));
            docDescription.put(doc.Id,doc);
        }
        if(!docSO.isEmpty()){
            chosenDoc = docSO[0].getValue();
        }
    }

    public List<SelectOption> getDocSO(){
        return docSO;
    }

    public List<SelectOption> getFolderSO(){
        return folderSO;
    }

    public void getDescription(){
        docName = '';
    }
    
    public Boolean getDisableButtons(){
        return disableButtons;
    }

    public PageReference nextStepSelect(){
        if(disableButtons){return null;}
        
        isNewDoc = false;
        PageReference pRef = Page.EUR_CRM_WYSIWYGEditor;
        if (!docDescription.isEmpty() && docDescription.containsKey(chosenDoc)){
            textArea = docDescription.get(chosenDoc).Body.toString();
        }
        return nextStepLogic(chosenFolder, pRef);
    }
    
    public PageReference nextStepCreate(){
        if(disableButtons){return null;}
        
        isNewDoc = true;
        PageReference pRef = Page.EUR_CRM_WYSIWYGEditor;
        devName = docName.replaceAll('[^\\w]+',''); //removes all non-characters and whitespaces
        devName = devName.replaceAll('^(\\d|_)+|(_+)$',''); //removes all forwarding numbers and back underscores
        devName = devName.replaceAll('__+','_'); //replaces double and more underscores with single underscore
        if(String.isEmpty(docName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.EUR_CRM_emptyDocNameErr ));
            pRef = null;
        }
        if(String.isEmpty(devName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.EUR_CRM_invalidDocNameErr ));
            pRef = null;
        }
        List<Document> sameDevNameDocs = [SELECT DeveloperName FROM Document WHERE DeveloperName=:devName];
        if(sameDevNameDocs.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.EUR_CRM_notUniqueDocNameErr ));
            pRef = null;
        }
        Set<String> countryCodes = new Set<String>();
        for(EUR_CRM_CTM_DigitalSignatureSettings__c dsCS : EUR_CRM_CTM_DigitalSignatureSettings__c.getAll().values()){
            countryCodes.add(dsCS.EUR_CRM_CountryCode__c.trim());
        }
        if(!countryCodes.contains(countryCode)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.EUR_CRM_CountryCodeErr));
            pRef = null;
        }
        return nextStepLogic(chosenFolderNew, pRef);
    }
    
    private PageReference nextStepLogic(Id chosenFolder, PageReference pRef){
        List<Schema.DescribeSObjectResult> descrObjResult;
        List<String> metaObjects = new List<String>();
        String mainObject = (folderNameById.containsKey(chosenFolder)) ? folderNameById.get(chosenFolder) : '';
        metaObjects.add(mainObject);
        List<String> childObject = (String.isNotEmpty(mainObject) && dsObjects.containsKey(mainObject + countryCode)) ? dsObjects.get(mainObject + countryCode) : new List<String>();
//        List<String> childObject = new List<String>();

        childTable = new List<List<String>>{ new List<String>{'""','""'} };
        if ( ! childObject.isEmpty()){
            metaObjects.addAll(childObject);
        }
        try{
            System.debug('\n metaObjects.size() => ' + metaObjects.size() + '\n');
            System.debug('\n metaObjects => ' + JSON.serializePretty(metaObjects) + '\n');
            descrObjResult = Schema.describeSObjects(metaObjects);
        }
        catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage())); }
        if (descrObjResult == null || descrObjResult.isEmpty()){
            pRef = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(Label.EUR_CRM_noObjectErr, new List<String>{mainObject})));
        }
        else{
            for (Schema.DescribeSObjectResult descrObj : descrObjResult){
                List<List<String>> objFlds = new List<List<String>>{ new List<String>{'""','""'} };
                for (Schema.SObjectField fieldVal : descrObj.fields.getMap().values()){
                    Schema.DescribeFieldResult fieldRes = fieldVal.getDescribe();
                    if (systemFields.contains(fieldRes.getName())){
                        continue;
                    }
                    objFlds.add(new List<String>{'"' + fieldRes.getLabel() + '"','"' + fieldRes.getName() + '"'});
                }
                if (descrObj.getName() == mainObject){
                    objFields = objFlds;
                }
                else if (childObject.contains(descrObj.getName())){
                    childTable.add(new List<String>{'"' + descrObj.getLabel() + '"','"' + descrObj.getName() + '"'});
                }
            }
        }
        objFields = getSortedListOfList(objFields);
        return pRef;
    }

    public void save(){
        Document newDoc = new Document();
        if (!docDescription.isEmpty() && docDescription.containsKey(chosenDoc) && !isNewDoc){
            docDescription.get(chosenDoc).Body = Blob.valueOf(textArea);
            newDoc = docDescription.get(chosenDoc);
        }
        else if(String.isNotEmpty(docName) && String.isNotEmpty(chosenFolderNew) && isNewDoc){
            newDoc.Body = Blob.valueOf(textArea);
            newDoc.Name = docName;
            newDoc.DeveloperName = devName;
            newDoc.FolderId = chosenFolderNew;
            newDoc.Type = 'html';
            newDoc.Description = JSON.serialize(new DocumentFields(countryCode));
        }
        if (newDoc != null){
            upsert newDoc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, String.format(Label.EUR_CRM_saveConfirmMsg, new List<String>{newDoc.Name})));
        }
    }
    
    public void back(){
        isNewDoc = false;
    }
    
    public void newDoc(){
        if(disableButtons){return;}
        
        isNewDoc = true;
    }

    public String getChildObjectWithFields(){
        List<String> objectNames = dsObjects.get(getChosenFolderName() + countryCode);
        Map<String, List<List<String>>> fieldsByObjectName = getFieldsForObject(objectNames);
        return JSON.serialize(fieldsByObjectName);
    }

    public String getChildObjectWithDescribeFields() {
        List<String> objectNames = dsObjects.get(getChosenFolderName() + countryCode);
        Map<String, Map<String, FieldDescribeWrapper>> fieldDescribesByObjectName = getFieldDescribesForObject(objectNames);
        return JSON.serialize(fieldDescribesByObjectName);
    }

    public String getChildObject(){
        List<String> objectNames = dsObjects.get(getChosenFolderName() + countryCode);
        List<List<String>> childObjects = getObjects(objectNames);
        return JSON.serialize(childObjects);
    }


    public String getParentToChildReferences(){
        EUR_CRM_CTM_DigitalSignatureSettings__c dsCS;
        System.debug('settings: ' + EUR_CRM_CTM_DigitalSignatureSettings__c.getAll().values());
        System.debug('getChosenFolderName(): ' + getChosenFolderName());
        System.debug('countryCode: ' + countryCode);
        for(EUR_CRM_CTM_DigitalSignatureSettings__c setting : EUR_CRM_CTM_DigitalSignatureSettings__c.getAll().values()){
            if(setting.EUR_CRM_Object__c.trim() == getChosenFolderName() && setting.EUR_CRM_CountryCode__c.trim() == countryCode) {
                dsCS = setting;
                break;
            }
        }
        Map<String, String> stringMap = getMapParentToChildReferences(dsCS);
        return JSON.serialize(stringMap);
    }

    public static final String SETTING_SPLITING_REGEX = '\\s*[,;]\\s*';

    private Map<String ,String> getMapParentToChildReferences(EUR_CRM_CTM_DigitalSignatureSettings__c dsCS){
        System.debug('dsCS: ' + dsCS);
        System.debug('dsCS: ' + dsCS);
        Map<String ,String> stringMap = new Map<String ,String>();
        if (String.isNotEmpty(dsCS.EUR_CRM_Detailing__c) && String.isNotEmpty(dsCS.EUR_CRM_ChildTableParentToChildRefFields__c)) {
            String childTableString = dsCS.EUR_CRM_Detailing__c;
            String parentToChildReferenceString = dsCS.EUR_CRM_ChildTableParentToChildRefFields__c;
            List<String> childTableStrings = childTableString.trim().split(SETTING_SPLITING_REGEX);
            List<String> parentToChildReferenceStrings = parentToChildReferenceString.trim().split(SETTING_SPLITING_REGEX);
            for(Integer i=0; i< childTableStrings.size(); i++){
                stringMap.put(childTableStrings[i], parentToChildReferenceStrings[i]);
            }
        }
        return stringMap;
    }

    public String getChosenFolderName() {
        return folderNameById.get(chosenFolder);
    }

    private List<List<String>> getObjects(List<String> objectNames){
        List<List<String>> childObject = new List<List<String>>();
        List<Schema.DescribeSObjectResult> descrObjResult;
        try {
            descrObjResult = Schema.describeSObjects(objectNames);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        if (descrObjResult == null || descrObjResult.isEmpty()) {
            return childObject;
        } else {
            for (Schema.DescribeSObjectResult descrObj : descrObjResult) {
                childObject.add(new List<String>{descrObj.getLabel(), descrObj.getName()});
            }
        }
        return childObject;
    }

    private Map<String, Map<String, FieldDescribeWrapper>> getFieldDescribesForObject(List<String> objectNames){
        Map<String, Map<String, FieldDescribeWrapper>> fieldDescribesByObjectName = new Map<String, Map<String, FieldDescribeWrapper>>();
        List<Schema.DescribeSObjectResult> descrObjResult;
        try {
            descrObjResult = Schema.describeSObjects(objectNames);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        if (descrObjResult == null || descrObjResult.isEmpty())
            return fieldDescribesByObjectName;
        for (Schema.DescribeSObjectResult descrObj : descrObjResult) {
            Map<String, FieldDescribeWrapper> fields = new Map<String, FieldDescribeWrapper>();
            for (Schema.SObjectField fieldVal : descrObj.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldRes = fieldVal.getDescribe();
                if (systemFields.contains(fieldRes.getName())) {
                    continue;
                }
                String fieldName = fieldRes.getName();
                if(fieldName=='RecordTypeId'){
                    fieldName='RecordType.Name';
                }
                FieldDescribeWrapper fdw = getFieldDescribe(fieldRes, descrObj.getName());
                if(!temporaryBannedTypes.contains(fdw.fieldType))
                    fields.put(fieldName, fdw);
            }
            fieldDescribesByObjectName.put(descrObj.getName(), fields);
        }
        return fieldDescribesByObjectName;
    }

    private FieldDescribeWrapper getFieldDescribe(Schema.DescribeFieldResult fieldRes, String objectName){
        FieldDescribeWrapper fdw = new FieldDescribeWrapper();
        String fieldLabel = fieldRes.getLabel();
        String fieldType = String.valueOf(fieldRes.getType());
        if(fieldRes.getName()=='RecordTypeId'){
            fieldLabel= SObjectType.RecordType.getLabel();
        }
        fdw.fieldLabel = fieldLabel;
        fdw.fieldType = fieldType;
        fdw.picklistOptions = getPickListOptions(fieldRes, objectName);
        return fdw;
    }

    private Map<String, String> getPickListOptions(Schema.DescribeFieldResult fieldRes, String objectName){
        Map<String, String> picklistOptions = new Map<String, String>();
        if(fieldRes.getName() == 'RecordTypeId') {
            picklistOptions.putAll(getAvailableRecordTypes(objectName));
        } else {
            String fieldType = String.valueOf(fieldRes.getType());
            if (fieldType == 'PICKLIST' || fieldType == 'MULTIPICKLIST') {
                List<Schema.PicklistEntry> ple = fieldRes.getPicklistValues();
                for (Schema.PicklistEntry f : ple) {
                    picklistOptions.put(f.getValue(), f.getLabel());
                }
            }
        }
        return picklistOptions;
    }

    private Map<String, String> getAvailableRecordTypes(String sObjectName){
        Map<String, String> rtsMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult obj = schemaMap.get(sObjectName).getDescribe();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        for(RecordType rt : EUR_CRM_RecordTypeHelper_v2.getObjectRts(sObjectName).values()) {
            if (recordTypeInfos.get(rt.Id) != null && recordTypeInfos.get(rt.Id).isAvailable()) {
                rtsMap.put(rt.DeveloperName, rt.Name);
            }
        }
        return rtsMap;
    }

    private Map<String, List<List<String>>> getFieldsForObject(List<String> objectNames){
        Map<String, List<List<String>>> fieldsByObjectName = new Map<String, List<List<String>>>();
        List<Schema.DescribeSObjectResult> descrObjResult;
        try {
            descrObjResult = Schema.describeSObjects(objectNames);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        if (descrObjResult == null || descrObjResult.isEmpty()) {
            return fieldsByObjectName;
        } else {
            for (Schema.DescribeSObjectResult descrObj : descrObjResult) {
                List<List<String>> fields = new List<List<String>>();
                for (Schema.SObjectField fieldVal : descrObj.fields.getMap().values()) {
                    Schema.DescribeFieldResult fieldRes = fieldVal.getDescribe();
                    if (systemFields.contains(fieldRes.getName())) {
                        continue;
                    }
                    String fieldName = fieldRes.getName();
                    String fieldLabel = fieldRes.getLabel();
                    if(fieldName=='RecordTypeId'){
                        fieldName='RecordType.Name';
                        fieldLabel= SObjectType.RecordType.getLabel();
                    }
                    fields.add(new List<String>{fieldLabel, fieldName});
                }
                fieldsByObjectName.put(descrObj.getName(), getSortedListOfList(fields));
            }
        }
        return fieldsByObjectName;
    }

    private static List<List<String>> getSortedListOfList(List<List<String>> lisStrings){
        List<String> strs = new List<String>();
        List<List<String>> newListStrings = new List<List<String>>();
        if(lisStrings == null || lisStrings.isEmpty()) return newListStrings;

        for(List<String> sl : lisStrings){
            strs.add(sl[0] + '&&&' + sl[1]);
        }
        strs.sort();

        for(String s: strs){
            Integer indForDelete = 0;
            for(Integer i = 0; i<lisStrings.size(); i++){
                List<String> field = s.split('&&&');
                if(field[0] == lisStrings[i][0] && field[1] == lisStrings[i][1]){
                    newListStrings.add(new List<String>{lisStrings[i][0], lisStrings[i][1]});
                    indForDelete = i;
                    break;
                }
            }
            lisStrings.remove(indForDelete);
        }
        return newListStrings;
    }

    public String getClasters(){
        List<List<String>> pickListValues = new List<List<String>>();

        for(EUR_CRM_CTM_Document_Former_Setting__mdt setting :[
            SELECT EUR_CRM_Available_Mechanic_Types__c
            FROM EUR_CRM_CTM_Document_Former_Setting__mdt
            WHERE EUR_CRM_Country_Code__c = :countryCode
        ]) {
            for(String mechanicType : splitSetting(setting.EUR_CRM_Available_Mechanic_Types__c)) {
                pickListValues.add(new List<String>{mechanicType, mechanicType});
            }

        }
        return JSON.serialize(pickListValues);
    }

    public String getTypesOperatorsMap(){
        return JSON.serialize(typesOperatorsMap);
    }

    public class FieldDescribeWrapper {
        public String fieldLabel;
        public String fieldType;
        public Map<String, String> picklistOptions;
    }

    public static List<String> splitSetting(String setting) {
        List<String> settingParts = new List<String>();
        if(setting == null) return settingParts;
        for(String piece : setting.trim().split(SETTING_SPLITING_REGEX)) {
            if(!String.isEmpty(piece)) {
                settingParts.add(piece);
            }
        }
        return settingParts;
    }

    public class DocumentFields {
        public String countryCode {get; set;}

        public DocumentFields (String countryCode) {
            this.countryCode = countryCode;
        }
    }

}