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
public virtual with sharing class ASI_CRM_CN_ProductWarehouse_AttachCTRL {
    
    private static final String ATTACH_PARENT_ID_FIELD = 'ASI_CRM_Item_Group__c';
    private static final String ATTACH_FILE_ID_FIELD = 'ASI_FileID__c';
    private static final String ATTACH_FILE_NAME_FIELD = 'ASI_File_Name__c';
    private static final String ATTACH_FEED_ITEM_ID_FIELD = 'ASI_FeedItemID__c';
    private static final String ATTACH_FILE_SIZE_FIELD = 'ASI_File_Size__c';
    private static final String ATTACH_FILE_EXT_FIELD = 'ASI_File_Extension__c';
    private static final String ATTACH_CATEGORY_FIELD = 'ASI_CRM_Photo_Category__c';
    private static final String ATTACH_IN_APPROVAL_FIELD;
    private static final String PHOTO_VERSION_FIELD = 'ASI_CRM_Photo_Version__c';
    private static final String COMMENTS_FIELD = 'ASI_CRM_Comments__c';
    private static final String RECORDTYPEID = 'RecordTypeId';
    //private static final String RECORDTYPEID_VALUE = '';//Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo');
    public static final Long MAX_FILE_SIZE = 1258292L; // Max. 1.2MB//5242880L; // Max. 5MB
    
    //20180719 Introv
    Private Static Final Map<String, String> MAP_RECORDTYPE_BY_TYPE = new Map<String, String>{'productwarehouse' => 'ASI_CRM_CN_Product_Warehouse_Photo', 'posmartwork' => 'ASI_MFM_CN_POSM_Final_Artwork_Photo', 'posmphoto' => 'ASI_MFM_CN_POSM_Photo'};
    
    public String sObjParentId { get; set; }
    //public String pageName { get; set; }
    //public ASI_MFM_Item_Group__c itemGroup { get; set; }
    
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
    public transient Blob contentData { get; set; }
    public transient String contentFileName { get; set; }
    public transient String contentType { get; set; }
    public transient Long fileSize { get; set; }
    public String contentCategory { get; set; }
    public Decimal photoVersion;
    public String comment{ get; set; }
    public Boolean generateNewVersion{ get; set; }
    public Boolean byPassSizeChecking{ get; set; }
    Public String reocrdTypeId{Get; Set;}
    Public Boolean isProductWarehouse {Get; Set;}
    
    public Boolean isAttachInApproval;
    public Boolean isForPage;
    
    private Integer stepCount;
    
    public ASI_CRM_CN_ProductWarehouse_AttachCTRL (ApexPages.StandardController stdController) {
        
        attachment = new FeedItem();
        sObjParentId = stdController.getId();
        attachmentObjType = 'ASI_CRM_Product_Warehouse_Photo__c';
        generateNewVersion = TRUE;
        byPassSizeChecking = False;
        setUpRecordType();
    }
    
    public ASI_CRM_CN_ProductWarehouse_AttachCTRL () {
        attachment = new FeedItem();
        hasCategoryField = true;
        isForPage = true;
        generateNewVersion = TRUE;
        byPassSizeChecking = False;
        setUpRecordType();
    }
    
    
    public PageReference uploadAction(){
        //PageReference thePage = new PageReference( '/'+ sObjParentId );
        //thePage.setRedirect( true );
        return ( this.saveCurrent(false) ) ? new PageReference('javascript:opener.location.href = \'/' + sObjParentId + '\';window.close();') : null;
    }
    
    //20180719 Introv
    Public void setUpRecordType(){
        
        isProductWarehouse = False;
        
        reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo');
        String typeOfPhoto = ApexPages.currentPage().getParameters().get('type');
        
        if(String.isNotBlank(typeOfPhoto)){
            if(String.isNotBlank(typeOfPhoto) && MAP_RECORDTYPE_BY_TYPE.containsKey(typeOfPhoto.toLowerCase())){
                reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__c' + MAP_RECORDTYPE_BY_TYPE.get(typeOfPhoto.toLowerCase()));
            }
        }
        
        if(reocrdTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo'))
            isProductWarehouse = True;
    }
    //20180719 End
    
    private Boolean saveCurrent(Boolean bySystem){
        System.debug('Begin saveCurrent, bySystem: ' + bySystem + ' sObjParentId: ' + sObjParentId);
        if (!bySystem){
            // validate the uploading file
            String errorMsg = validateFile();
            if (errorMsg != null) {
                displayMsg(ApexPages.Severity.FATAL, errorMsg);
                return false;
            }
        }
        
        if(isProductWarehouse){
            List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachment = new List<ASI_CRM_Product_Warehouse_Photo__c>([SELECT Id
                                                                                                                   , ASI_CRM_Photo_Version__c
                                                                                                                   FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                                                                   WHERE ASI_CRM_Item_Group__c = : sObjParentId
                                                                                                                   AND ASI_CRM_Photo_Version__c != NULL
                                                                                                                   AND ASI_CRM_Photo_Category__c = : contentCategory
                                                                                                                   AND RecordTypeId = : reocrdTypeId
                                                                                                                   ORDER BY ASI_CRM_Photo_Version__c DESC
                                                                                                                   LIMIT 1
                                                                                                                  ]);
            
            if(tmpAttachment.size() > 0){
                if(generateNewVersion)
                    photoVersion = tmpAttachment[0].ASI_CRM_Photo_Version__c + 0.1;
                else
                    photoVersion = tmpAttachment[0].ASI_CRM_Photo_Version__c;
            }else{
                photoVersion = 0.0;
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        Boolean result = false;
        
        System.debug('Id from URL parameter: ' + ApexPages.currentPage().getParameters().get('id'));
        
        try{
            
            // Create a record linked with the file
            attachmentObj.put(ATTACH_PARENT_ID_FIELD, sObjParentId);
            attachmentObj.put(ATTACH_FILE_NAME_FIELD, contentFileName);           
            
            if (!bySystem){
                setFieldIfExist(attachmentObj, ATTACH_FILE_SIZE_FIELD, Decimal.valueOf(fileSize).divide(1024, 0, System.RoundingMode.UP));
            }
            setFieldIfExist(attachmentObj, ATTACH_FILE_EXT_FIELD, getFileExtension(contentFileName));
            
            System.debug('Content Category: ' + contentCategory);
            System.debug('isAttachInApproval: ' + isAttachInApproval);
            
            //20180720 Introv
            if(isProductWarehouse){
                setFieldIfExist(attachmentObj, PHOTO_VERSION_FIELD, photoVersion);
                setFieldIfExist(attachmentObj, ATTACH_CATEGORY_FIELD, contentCategory);
            }
            
            setFieldIfExist(attachmentObj, COMMENTS_FIELD, comment);
            
            //setFieldIfExist(attachmentObj, RECORDTYPEID, RECORDTYPEID_VALUE); //20180719 Introv
            setFieldIfExist(attachmentObj, RECORDTYPEID, reocrdTypeId);
            
            insert attachmentObj;
            
            attachment.ParentId = attachmentObj.Id;
            
            attachment.ContentData = contentData;
            attachment.ContentFileName = contentFileName;

            // 20200106 Sera
            // show product photos to community users
            attachment.Visibility = 'AllUsers';
            // 20200106 Sera
            
            insert attachment;
            
            // update the created FeedItem ID to attachment record
            FeedItem insertedAttachment = [select RelatedRecordId from FeedItem where Id=:attachment.Id];
            //attachmentObj.put(ATTACH_FILE_ID_FIELD, String.valueOf(insertedAttachment.RelatedRecordId).subString(0, 15));
            attachmentObj.put(ATTACH_FILE_ID_FIELD, insertedAttachment.RelatedRecordId);
            attachmentObj.put(ATTACH_FEED_ITEM_ID_FIELD, insertedAttachment.Id);
            update attachmentObj;
            
            //20180814 Introv
            Update new ASI_MFM_Item_Group__c(id = sObjParentId);
            
            result = true;
        }catch( Exception e ){
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
                displayMsg(ApexPages.Severity.ERROR, errMsg);
            }
            result = false;
        } finally {
            contentData = null;
            attachment = new FeedItem();
        }
        return result;
    }
    
    private String validateFile() {
        if (fileSize > MAX_FILE_SIZE && !byPassSizeChecking)
            return String.format('Your file size is too large ({0} bytes). Maximum file size is 1.2MB.', new String[] {String.valueOf(fileSize)});
        return null;
    }
    
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ sObjParentId );
        thePage.setRedirect( true );
        return NULL;
    }
    
    private void displayMsg(ApexPages.Severity severity, String message) {
        if (isForPage) {
            ApexPages.addMessage(new ApexPages.Message(severity, message));
        } else {
            //throw new ASI_KOR_CustomException(message);
        }
    }
    
    public Integer getUploadStepCount() {
        if (hasCategoryField)
            return 5;
        else
            return 4;
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