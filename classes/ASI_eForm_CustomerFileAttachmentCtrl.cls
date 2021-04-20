/*
=== Purpose ===
    This component is used to embed the file attachment page 
    for a Object which needs file attachment.
    
=== Setup ===
    Before using this component, Please create a custom object (Name is auto number)
    with following fields:
    Parent__c: Master-Detail(Target Object which needs file attachment)
    FileId__c: Text(18)   - Record the attached file path
    File_Name__c: Text(255)   - Record the file name
    FeedItemId__c: Text(20)   - Record the ID of attached file
    ---------- Optional: ----------
    File_Ext__c: Text(10)   - Record the file extension of attached file
    File_Size__c: Number(18, 0)   - Record the file size (in KB)
    Category__c: Picklist   - Record the category of attached file
    
    You may create your own fields such as Name: Formula(Text) to provide hyperlink linked to the file "/" & FileId__c
    Important: Enable Feed Tracking for the above custom object (Customize -> Chatter -> Feed Tracking -> Enable Feed Tracking)
    
    Also, a visualforce page is needed to embed this component.
    Create the page with following content:
    <apex:page standardController="<The custom object name created in previous step>" recordSetvar="docs" >
        <c:FileAttachment sObjParentId="{!$CurrentPage.parameters.id}" attachmentObjType="<The custom object name created in previous step>" />
    </apex:page>
    
    Use the above visualforce page to create List Button and put the button to Related List of Target Object
*/
/***********************************************************************************
 * Name : ASI_eForm_CustomerFileAttachmentCtrl
 * Created Date: 2018-10-02
 * Test Class: --ASI_eForm_HK_VendorForm_TriggerTest, ASI_eForm_KR_Test1
 * Revision History:
 * 2018-10-03       fanny yeung			customer form attachment              

 ***********************************************************************************/
 
 
public virtual with sharing class ASI_eForm_CustomerFileAttachmentCtrl {
    
    private static final String ATTACH_PARENT_ID_FIELD = 'ASI_eForm_Customer_Form__c';
    private static final String ATTACH_FILE_ID_FIELD = 'ASI_eForm_FileId__c';
    private static final String ATTACH_FILE_NAME_FIELD = 'ASI_eForm_File_Name__c';
    private static final String ATTACH_FEED_ITEM_ID_FIELD = 'ASI_eForm_FeedItemId__c';
    private static final String ATTACH_FILE_SIZE_FIELD = 'ASI_eForm_File_Size__c';
    private static final String ATTACH_FILE_EXT_FIELD = 'ASI_eForm_File_Ext__c';
    private static final String ATTACH_CATEGORY_FIELD = 'ASI_eForm_Category__c';
    private static final String ATTACH_RECORD_TYPE_FIELD = 'RecordTypeID';
    private static final String ATTACH_RECORD_REMARK_FIELD = 'ASI_eForm_Remark__c';
    public static final Long MAX_FILE_SIZE = 5242880L; // Max. 5MB
    
	Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Customer_Form__c.fields.getMap();
    
    public String sObjParentId { get; set; }
    Public String remark{Get; Set;}
   public String attachmentObjType { get; set; }
   public sObject attachmentObj {
        get {
            if (attachmentObj == null)
                attachmentObj = Schema.getGlobalDescribe().get(attachmentObjType).newSObject();
            return attachmentObj;
        }
        set;
    }
    public String attachmentObjLabel {
        get {
            if (attachmentObjLabel == null)
                attachmentObjLabel = Schema.getGlobalDescribe().get(attachmentObjType).getDescribe().getLabel();
            return attachmentObjLabel;
        }
        set;
    }
    
    public Boolean hasCategoryField { get { return hasField(attachmentObj, ATTACH_CATEGORY_FIELD); } set; }
    public List<SelectOption> categories {
        get {
            if (categories == null) {
                Schema.DescribeFieldResult cgFieldResult = getDescribeFieldResult(attachmentObj, ATTACH_CATEGORY_FIELD);
                if (cgFieldResult != null) {
                    List<Schema.PicklistEntry> picklist = cgFieldResult.getPicklistValues();
                    categories = new List<SelectOption>();
                    for (Schema.PicklistEntry entry : picklist) {
                        categories.add(new SelectOption(entry.getLabel(), entry.getValue()));
                    }
                }
            }
            return categories;
        }
        private set;
    } 
    
    public FeedItem attachment { get; set; }
    // Attachment Content
    public transient Blob attachmentContentData { get; set; }
    public transient String attachmentFileName { get; set; }
    public transient String contentType { get; set; }
    public transient Long fileSize { get; set; }
    public String contentCategory { get; set; }
    public Boolean isForPage;
    private Integer stepCount;
   
     public ASI_eForm_CustomerFileAttachmentCtrl () {
        attachment = new FeedItem();
        hasCategoryField = true;
        isForPage = true;
    }
     
   
    /**
    * Upload action, store the file or replace if exists
    * @return thePage
    */
    public PageReference uploadAction(){
        PageReference thePage = new PageReference( '/'+ sObjParentId );
        thePage.setRedirect( true );
        return ( this.saveCurrent() ) ? thePage : null;
    }
        
    /**
    * Save the New FeedItem
    * @return : boolean
    */
    private Boolean saveCurrent(){
        String errorMsg = validateFile();
        if (errorMsg != null) {
            system.debug('errorMsg: '+ errorMsg);
            displayMsg(ApexPages.Severity.FATAL, errorMsg);
            return false;
        }
        System.debug('not skipped');
        Savepoint sp = Database.setSavepoint();
        Boolean result = false;
                         
        try{
            // Create a record linked with the file
       		system.debug('Before Attachment Object');
            attachmentObj.put(ATTACH_PARENT_ID_FIELD, sObjParentId);
            attachmentObj.put(ATTACH_FILE_NAME_FIELD, attachmentFileName);
          //  attachmentObj.put(ATTACH_FILE_NAME_FIELD, contentCategory);
            
            attachmentObj.put(ATTACH_RECORD_REMARK_FIELD, remark);
            assignOptionalFields();
          
            insert attachmentObj;
            
            // create FeedItem (ContentPost) by the file
            system.debug('Before Insert Feed Item Object');
            attachment.ParentId = attachmentObj.Id;
            attachment.ContentData = attachmentContentData;
            attachment.ContentFileName = attachmentFileName;
           // attachment.ContentFileName = contentCategory;
            system.debug(attachment);
            insert attachment;
                       
            // update the created FeedItem ID to attachment record
            system.debug('Before Update Feed Item Object');
            FeedItem insertedAttachment = [select RelatedRecordId from FeedItem where Id=:attachment.Id];
            attachmentObj.put(ATTACH_FILE_ID_FIELD, insertedAttachment.RelatedRecordId);
            attachmentObj.put(ATTACH_FEED_ITEM_ID_FIELD, insertedAttachment.Id);
            
            
            update attachmentObj;
        
            result = true;
        } 
        catch( Exception e ){
            System.debug(e);
            Database.rollback( sp );
            List<String> errMsgList = new List<String>();
            if (e.getTypeName() == 'System.DmlException') {
                DMLException dmle = (DMLException)e;
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    if (dmle.getDmlType(i) == StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY)
                        errMsgList.add('You have no permission to attach file to this record');
                    else {
                        
                        errMsgList.add(dmle.getDmlMessage(i));
                    }
                }
            } else {
                errMsgList.add(e.getMessage());
            }
            for (String errMsg : errMsgList) {
                System.debug('XXX System Error: ' + errMsg);
                displayMsg(ApexPages.Severity.ERROR, errMsg);
                
            }
            result = false;
        } finally {
            attachmentContentData = null;
            attachment = new FeedItem();
        }
        return result;
    }
    
    /**
    * Validate file
    * @return error message if invalid. null if valid
    */
    private String validateFile() {
        if (attachmentFileName == null){
            return 'Please choose a file to upload.';
        }
        else if (fileSize > MAX_FILE_SIZE){
            return String.format('Your file size is too large ({0} bytes). Maximum file size is 5MB.', new String[] {String.valueOf(fileSize)});
        }
        return null;
    }
    
    /**
    * Cancel action
    * @return thePage a page reference
    */
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ sObjParentId );
        thePage.setRedirect( true );
        return thePage;
    }
    
    /**
    * Display message on upload page
    */
    private void displayMsg(ApexPages.Severity severity, String message) {
        if (isForPage) {
            ApexPages.addMessage(new ApexPages.Message(severity, message));
        } else {
            //throw new ASI_KOR_CustomException(message);
        }
    }
    
    public Integer getUploadStepCount() {
        if (hasCategoryField)
            return 3;
        else
            return 2;
    }
    
    protected virtual void assignOptionalFields() {
        setFieldIfExist(attachmentObj, ATTACH_FILE_SIZE_FIELD, Decimal.valueOf(fileSize).divide(1024, 0, System.RoundingMode.UP));
        setFieldIfExist(attachmentObj, ATTACH_FILE_EXT_FIELD, getFileExtension(attachmentFileName));
         System.debug('Content Category: ' + contentCategory);
        setFieldIfExist(attachmentObj, ATTACH_CATEGORY_FIELD, contentCategory);
    }
    
    private String getFileExtension(String fileName) {
        String result = '';
        if (fileName != null) {
            Integer lastDotIndex = fileName.lastIndexOf('.');
            if (lastDotIndex > 0)
                result = fileName.substring(lastDotIndex + 1);
        }
        return result;
    }
    
    protected void setFieldIfExist(sObject sObj, String fieldName, Object value) {
        try {
            sObj.put(fieldName, value);
        } catch (SObjectException soe) {
        }
    }
    
    protected Boolean hasField(sObject sObj, String fieldName) {
        try {
            sObj.get(fieldName);
            return true;
        } catch (SObjectException soe) {
            return false;
        }
    }
    
    protected Schema.DescribeFieldResult getDescribeFieldResult(sObject sObj, String fieldName) {
        Schema.SObjectField theField = sObj.getSObjectType().getDescribe().fields.getMap().get(ATTACH_CATEGORY_FIELD);
        if (theField == null)
            return null;
        return theField.getDescribe();
    }
    
   
    
}