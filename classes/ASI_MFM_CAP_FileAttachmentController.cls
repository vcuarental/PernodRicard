/*
Duplicated from eForm
This is use for CAP MFM project
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
public virtual with sharing class ASI_MFM_CAP_FileAttachmentController {
    
    //private static final String ATTACH_PARENT_ID_FIELD = 'ASI_MFM_CAP_IT_Procurement_Service_Request__c';
    private static final String ATTACH_FILE_ID_FIELD = 'ASI_MFM_CAP_FileId__c';
    private static final String ATTACH_FILE_NAME_FIELD = 'ASI_MFM_CAP_File_Name__c';
    private static final String ATTACH_FEED_ITEM_ID_FIELD = 'ASI_MFM_CAP_FeedItemId__c';
    private static final String ATTACH_FILE_SIZE_FIELD = 'ASI_MFM_CAP_File_Size__c';
    private static final String ATTACH_FILE_EXT_FIELD = 'ASI_MFM_CAP_File_Ext__c';
    private static final String ATTACH_CATEGORY_FIELD = 'ASI_MFM_CAP_Category__c';
    private static final String ATTACH_PLAN_LINE_ITEM_FIELD = 'ASI_MFM_Plan_Line_Item__c';
    private static final String ATTACH_IN_APPROVAL_FIELD = 'ASI_MFM_CAP_Attach_in_Approval_Email__c';
    public static final Long MAX_FILE_SIZE = 5242880L; // Max. 5MB
    
    public String sObjParentId { get; set; }
    public String parentIdField { get; set; }
    public String recordTypeName { get; set; }
    public ASI_MFM_Plan__c npl { get; set; }    
    public String attachmentObjType { get; set; }
    public sObject attachmentObj {
        get {
            if (attachmentObj == null)
            {
               attachmentObj = Schema.getGlobalDescribe().get(attachmentObjType).newSObject();
               //recordTypeName = ApexPages.currentPage().getParameters().get('RecordTypeName');
               System.debug('***** RecordTypeName ***** : ' + recordTypeName);
               if (recordTypeName != null && !''.equals(recordTypeName.trim()))
               {
                 RecordType recordType = [SELECT Id from RecordType Where DeveloperName = :recordTypeName];  
                 System.debug('***** RecordTypeId ***** : ' + recordType.Id);      
                 attachmentObj.put('RecordTypeId',recordType.Id);
               }
            }
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
    
    //Added by Laputa(Hector)
    //Add Plan Line Items Selection 
    //  Label: {Plan Line Description} - {Plan Line ID}
    //  Values:  {Plan Line ID}
    public Boolean hasPlanLineItems { get { return hasField(attachmentObj, ATTACH_PLAN_LINE_ITEM_FIELD); } set; }
    public List<SelectOption> planLineItemOptions{
    	get{
    		if (planLineItemOptions == null) {
    			planLineItemOptions = new List<SelectOption>();
    			List<ASI_MFM_Plan_Line_Item__c> planLineItemsList = [SELECT ID, 
    																		Name,
    																		ASI_MFM_List_Item_Description__c 
    																FROM ASI_MFM_Plan_Line_Item__c 
    																WHERE ASI_MFM_Plan__c = :sObjParentId];
    			//Always add empty label
    			planLineItemOptions.add(new SelectOption('', ''));
    			if (planLineItemsList.size() > 0){
    				for (ASI_MFM_Plan_Line_Item__c entry : planLineItemsList) {
    					string optionLabel = entry.ASI_MFM_List_Item_Description__c.rightPad(50) + ' - ' + entry.Name;
	    				planLineItemOptions.add(new SelectOption(entry.Id, optionLabel));
	                }
    			}
    			system.debug('planLineItemOptions');
    		}
    		system.debug(planLineItemOptions);
    		return planLineItemOptions;
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
    public Id planLineItem { get; set; }
    public Boolean isAttachInApproval { get; set;}
    public Boolean isForPage;
    private Integer stepCount;
    //public String recordTypeName {get;set;}

    public ASI_MFM_CAP_FileAttachmentController (ApexPages.StandardController stdController) {
        attachment = new FeedItem();
        sObjParentId = stdController.getId();
        attachmentObjType  = 'ASI_MFM_CAP_Plan_Attachment__c';
       // isAttachInApproval = true;
        npl = [Select ASI_MFM_Status__c From ASI_MFM_Plan__c Where Id = :sObjParentId];
    }
    
    public ASI_MFM_CAP_FileAttachmentController () {
        attachment = new FeedItem();
        hasCategoryField = true;
        isForPage = true;        
        //attachmentObj.set();
       // isAttachInApproval = true;
    }
    
    /**
    * Upload action, store the file or replace if exists
    * @return thePage
    */
    public PageReference uploadAction(){
        PageReference thePage = new PageReference( '/'+ sObjParentId );
        thePage.setRedirect( true );
        return ( this.saveCurrent(false) ) ? thePage : null;
    }

    //Removed by Wilken on 20130526, User will mannual attach the PDF
    /*public PageReference uploadActionBySystem(){
        System.debug('Begin uploadActionBySystem');
        PageReference thePage = new PageReference( '/'+ sObjParentId );
        thePage.setRedirect( true );
        
        //Set Attributes for PDF Attachment
        contentFileName = 'NPL Info Before S&OP.pdf';
        contentCategory = 'NPL History';
        
        System.debug('End uploadActionBySystem');
        if (npl.ASI_MFM_Status__c == 'Waiting for S&OP Alignment'){
            return ( this.saveCurrent(true) ) ? thePage : null;
        }
        else {
            return null;
        }
    }*/
        
    /**
    * Save the New FeedItem
    * @return : boolean
    */
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
             
        Savepoint sp = Database.setSavepoint();
        Boolean result = false;
        
        System.debug('Id from URL parameter: ' + ApexPages.currentPage().getParameters().get('id'));
        
        Id nplID = (Id)ApexPages.currentPage().getParameters().get('id');
                        
        try{
            // Create a record linked with the file
            attachmentObj.put(parentIdField, sObjParentId);
            attachmentObj.put(ATTACH_FILE_NAME_FIELD, contentFileName);           
            
            if (!bySystem){
                setFieldIfExist(attachmentObj, ATTACH_FILE_SIZE_FIELD, Decimal.valueOf(fileSize).divide(1024, 0, System.RoundingMode.UP));
            }
            setFieldIfExist(attachmentObj, ATTACH_FILE_EXT_FIELD, getFileExtension(contentFileName));
            
            //System.debug('Content Category: ' + contentCategory);
            //setFieldIfExist(attachmentObj, ATTACH_CATEGORY_FIELD, contentCategory);

            System.debug('isAttachInApproval: ' + isAttachInApproval);
            setFieldIfExist(attachmentObj, ATTACH_IN_APPROVAL_FIELD, isAttachInApproval);
            
            insert attachmentObj;
            
            // create FeedItem (ContentPost) by the file
            attachment.ParentId = attachmentObj.Id;
            
            //set plan line item
            setFieldIfExist(attachmentObj, ATTACH_PLAN_LINE_ITEM_FIELD, planLineItem);
            /*if (bySystem){
                System.debug('Begin create PDF VF page');
                PageReference pdf = Page.ASI_CN_NPL_RequestSavePDFPage;
                pdf.getParameters().put('id',nplID);
                
                Attachment attach = new Attachment();
                Blob pdfBody;
                
                try {
                    pdfBody = pdf.getContent();
                    System.debug('pdfBody size: ' + pdfBody.size());
                } catch (VisualforceException e) {
                    System.debug('Error occur at pdf getContent');
                     System.debug(e);
                    pdfbody = Blob.valueOf('Some error Text');
                }
                attachment.ContentData = pdfBody;
                attachment.ContentFileName = contentFileName + '.pdf';
            }
            else {*/
                attachment.ContentData = contentData;
                attachment.ContentFileName = contentFileName;
            //}
            insert attachment;
            
            // update the created FeedItem ID to attachment record
            FeedItem insertedAttachment = [select RelatedRecordId from FeedItem where Id=:attachment.Id];
            //attachmentObj.put(ATTACH_FILE_ID_FIELD, String.valueOf(insertedAttachment.RelatedRecordId).subString(0, 15));
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
            contentData = null;
            attachment = new FeedItem();
        }
        return result;
    }
    
    /**
    * Validate file
    * @return error message if invalid. null if valid
    */
    private String validateFile() {
        if (fileSize > MAX_FILE_SIZE)
            return String.format('Your file size is too large ({0} bytes). Maximum file size is 5MB.', new String[] {String.valueOf(fileSize)});
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
            return 4;
        else
            return 3;
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