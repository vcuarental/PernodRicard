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
 * Name : ASI_eForm_VendorFileAttachmentController
 * Created Date: 2018-02-28
 * Test Class: ASI_eForm_HK_VendorForm_TriggerTest, ASI_eForm_KR_Test1
 * Revision History:
 * 2018-03-14       Wilken Lee              [WL 1.0] Segregate HK and SG Category pick list options
 * 2018-05-25       Vincent Lam             [VL 2.0] Segregate KR Category pick list options
 * 2020-02-26       Sera Liao               [SL 3.0] Segregate CN Category pick list options

 ***********************************************************************************/
 
 
public virtual with sharing class ASI_eForm_VendorFileAttachmentController {
    
    private static final String ATTACH_PARENT_ID_FIELD = 'ASI_eForm_Vendor_Form__c';
    private static final String ATTACH_FILE_ID_FIELD = 'ASI_eForm_FileId__c';
    private static final String ATTACH_FILE_NAME_FIELD = 'ASI_eForm_File_Name__c';
    private static final String ATTACH_FEED_ITEM_ID_FIELD = 'ASI_eForm_FeedItemId__c';
    private static final String ATTACH_FILE_SIZE_FIELD = 'ASI_eForm_File_Size__c';
    private static final String ATTACH_FILE_EXT_FIELD = 'ASI_eForm_File_Ext__c';
    private static final String ATTACH_CATEGORY_FIELD = 'ASI_eForm_Category__c';
    private static final String ATTACH_RECORD_TYPE_FIELD = 'RecordTypeID';
    private static final String ATTACH_RECORD_REMARK_FIELD = 'ASI_eForm_Remark__c';
    /* [SL 3.0] BEGIN */
    private static final String ATTACH_RECORD_EXPIRATION_DATE_FIELD = 'ASI_CRM_CN_VA_Expiration_Date__c';
    /* [SL 3.0] END */
    public static final Long MAX_FILE_SIZE = 2147483648L; // Max. 2GB
    
	Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
    
    public String sObjParentId { get; set; }
	
    //20180601 Introv
    Public ASI_eForm_Vendor_Form__c parent{
        Get{
            Return [select recordType.DeveloperName
                    , ASI_eForm_Sys_Approver_1__c
                    , ASI_eForm_Sys_Approver_2__c
                    , ASI_eForm_Sys_Approver_3__c
                    , ASI_eForm_Sys_Approver_4__c
                    , ASI_eForm_Sys_Approver_5__c
                    , ASI_eForm_Sys_Approver_6__c
                    , ASI_eForm_Sys_Approver_7__c
                    , ASI_eForm_Sys_Approver_8__c
                    , OwnerId 
                    from ASI_eForm_Vendor_Form__c 
                    where Id = :sObjParentId Limit 1];
        }
        
        Private Set;
    }
    /* [SL 3.0] BEGIN */
    Public ASI_eForm_Vendor_Form_Attachment__c vendorFormAttachment{Get; Set;}
    /* [SL 3.0] END */

	/*[WL 1.0] BEGIN*/
	public String market {
        get {
            //ASI_eForm_Vendor_Form__c parent = [select recordType.DeveloperName from ASI_eForm_Vendor_Form__c where Id = :sObjParentId Limit 1]; //20180601 Introv Commented
			if (parent != null){
				if (parent.recordType.DeveloperName.contains('ASI_eForm_SG'))
					return 'SG';
				else if (parent.recordType.DeveloperName.contains('ASI_eForm_HK'))
					return 'HK';
                /* [VL 2.0] BEGIN */
				else if (parent.recordType.DeveloperName.contains('ASI_eForm_KR'))
					return 'KR';
                /* [VL 2.0] END */
                /* [SL 3.0] BEGIN */
                else if (parent.recordType.DeveloperName.contains('ASI_CRM_CN_VA'))
                    return 'CN';
                /* [SL 3.0] END */
				else 
					return 'Error';
			}
			else
				return 'Error';
        }
        set;
    }
	/*[WL 1.0] END*/
    
    //20180425 Introv
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
			/*[WL 1.0] BEGIN*/
            /*if (categories == null) {
                Schema.DescribeFieldResult cgFieldResult = getDescribeFieldResult(attachmentObj, ATTACH_CATEGORY_FIELD);
                if (cgFieldResult != null) {
                    List<Schema.PicklistEntry> picklist = cgFieldResult.getPicklistValues();
                    categories = new List<SelectOption>();
                    for (Schema.PicklistEntry entry : picklist) {
                        categories.add(new SelectOption(entry.getLabel(), entry.getValue()));
                    }
                }
            }
            return categories;*/
			List<SelectOption> result = new List<SelectOption>();
			
			if (market == 'SG'){
				result.add(new SelectOption('Quotation', 'Quotation'));
				result.add(new SelectOption('Business Registration Profile', 'Business Registration Profile'));
			}
			else if (market == 'HK'){
				result.add(new SelectOption('Company Registration', 'Company Registration'));
                result.add(new SelectOption('Bank', 'Bank'));
                result.add(new SelectOption('Others', 'Others'));
			}
            /* [VL 2.0] BEGIN */
			else if (market == 'KR'){
				result.add(new SelectOption('사업자등록증 사본/주민등록증 사본', '사업자등록증 사본/주민등록증 사본'));
                result.add(new SelectOption('통장사본', '통장사본'));
				result.add(new SelectOption('개인정보 활용 동의서', '개인정보 활용 동의서'));
                result.add(new SelectOption('기타', '기타'));
			}
            /* [VL 2.0] END */
            /* [SL 3.0] BEGIN */
            else if (market == 'CN'){
                Map<String, String> categoryPLEMap = new Map<String, String>();
                List<Schema.PicklistEntry> categoryPLEs = ASI_eForm_Vendor_Form_Attachment__c.ASI_eForm_Category__c.getDescribe().getPicklistValues();
                for(PicklistEntry categoryPLE : categoryPLEs){
                    categoryPLEMap.put(categoryPLE.getValue().trim(), categoryPLE.getLabel().trim());
                }
                if (parent.recordType.DeveloperName.containsIgnoreCase('New')){
                    result.add(new SelectOption('Business Registration Certificate with company chop', categoryPLEMap.containsKey('Business Registration Certificate with company chop') ? categoryPLEMap.get('Business Registration Certificate with company chop') : 'Business Registration Certificate with company chop'));
                    result.add(new SelectOption('Supplier Bank Information Confirmation', categoryPLEMap.containsKey('Supplier Bank Information Confirmation') ? categoryPLEMap.get('Supplier Bank Information Confirmation') : 'Supplier Bank Information Confirmation'));
                    result.add(new SelectOption('Bidding of Price or Design Involved', categoryPLEMap.containsKey('Bidding of Price or Design Involved') ? categoryPLEMap.get('Bidding of Price or Design Involved') : 'Bidding of Price or Design Involved'));
                }
                if (parent.recordType.DeveloperName.containsIgnoreCase('Revise')){
                    result.add(new SelectOption('Business Name Change Approval', categoryPLEMap.containsKey('Business Name Change Approval') ? categoryPLEMap.get('Business Name Change Approval') : 'Business Name Change Approval'));
                    result.add(new SelectOption('Business Registration Certificate with company chop', categoryPLEMap.containsKey('Business Registration Certificate with company chop') ? categoryPLEMap.get('Business Registration Certificate with company chop') : 'Business Registration Certificate with company chop'));
                    result.add(new SelectOption('Permit of Bank Account', categoryPLEMap.containsKey('Permit of Bank Account') ? categoryPLEMap.get('Permit of Bank Account') : 'Permit of Bank Account'));
                }
            }
            /* [SL 3.0] END */
			return result;
			/*[WL 1.0] END*/
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
    public Boolean isForPage;
    private Integer stepCount;
    
    public ASI_eForm_VendorFileAttachmentController() {
        attachment = new FeedItem();
        
        hasCategoryField = false;
        isForPage = true;
        /* [SL 3.0] BEGIN */
        vendorFormAttachment = new ASI_eForm_Vendor_Form_Attachment__c();
        /* [SL 3.0] END */
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
        // validate the uploading file
        String errorMsg = validateFile();
        if (errorMsg != null) {
            displayMsg(ApexPages.Severity.FATAL, errorMsg);
            return false;
        }
        Savepoint sp = Database.setSavepoint();
        Boolean result = false;
        
        try{
            // Create a record linked with the file
            system.debug('Before Attachment Object');
            attachmentObj.put(ATTACH_PARENT_ID_FIELD, sObjParentId);
            attachmentObj.put(ATTACH_FILE_NAME_FIELD, contentFileName);
			
            //20180425 Introv
            attachmentObj.put(ATTACH_RECORD_REMARK_FIELD, remark);
            
			/*[WL 1.0] BEGIN*/
			if (market == 'SG')
				attachmentObj.put(ATTACH_RECORD_TYPE_FIELD, Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_eForm_SG_Vendor_Form_Attachment'));
			else if (market == 'HK')
				attachmentObj.put(ATTACH_RECORD_TYPE_FIELD, Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_eForm_HK_Vendor_Form_Attachment'));
			/*[WL 1.0] END*/
            /* [VL 2.0] BEGIN */
			else if (market == 'KR')
				attachmentObj.put(ATTACH_RECORD_TYPE_FIELD, Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_eForm_KR_Vendor_Form_Attachment'));
            /* [VL 2.0] END */
            /* [SL 3.0] BEGIN */
            else if (market == 'CN'){
                attachmentObj.put(ATTACH_RECORD_TYPE_FIELD, Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_CRM_CN_VA_Vendor_Form_Attachment'));
                attachmentObj.put(ATTACH_RECORD_EXPIRATION_DATE_FIELD, vendorFormAttachment.ASI_CRM_CN_VA_Expiration_Date__c);
            }
            /* [SL 3.0] END */

			assignOptionalFields();
            insert attachmentObj;
            
            // create FeedItem (ContentPost) by the file
            system.debug('Before Insert Feed Item Object');
            attachment.ParentId = attachmentObj.Id;
            attachment.ContentData = contentData;
            attachment.ContentFileName = contentFileName;
            insert attachment;
            
            // update the created FeedItem ID to attachment record
            system.debug('Before Update Feed Item Object');
            FeedItem insertedAttachment = [select RelatedRecordId from FeedItem where Id=:attachment.Id];
            attachmentObj.put(ATTACH_FILE_ID_FIELD, insertedAttachment.RelatedRecordId);
            attachmentObj.put(ATTACH_FEED_ITEM_ID_FIELD, insertedAttachment.Id);
            
            //20180528 Introv
            if(market == 'HK'){
                
                List<User> soaUser = new List<User>([SELECT Id FROM USER WHERE UserName LIKE 'prasia_soa@service.pernod-ricard.com%']);
                ASI_eForm_HK_VendorFormAttac_Security.updateContentVersionSecurity(new Set<Id>{insertedAttachment.RelatedRecordId}, parent/*, gm*/, soaUser.size() > 0 ? soaUser[0].Id : Null);
            }
            
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
                        errMsgList.add(Label.ASI_KOR_VF_ATTACH_ERR_NoPermission);
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
    
    /**
    * Validate file
    * @return error message if invalid. null if valid
    */
    private String validateFile() {
        if (fileSize > MAX_FILE_SIZE)
            return String.format(Label.ASI_KOR_VF_ATTACH_ERR_FileSizeLimit, new String[] {String.valueOf(fileSize)});
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
            throw new ASI_KOR_CustomException(message);
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
        setFieldIfExist(attachmentObj, ATTACH_FILE_EXT_FIELD, getFileExtension(contentFileName));
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