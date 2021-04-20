public with sharing class ASI_CRM_OfftakeCreationBatch implements Database.Batchable<SObject> {

    private static final Integer CUSTOMER_CODE_INDEX = 0;
    private static final Integer OFFTAKE_GL_DATE_INDEX = 1;
    private static final Integer SKU_CODE_INDEX = 2;
    private static final Integer INVOICE_NO_INDEX = 3;
    private static final Integer QUANTITY_INDEX = 4;
    private static final String MESSAGE_HEADER = 'Customer,Offtake G/L Date,SKU Code,Invoice No,Quantity,Error\r\n';
    private static final String MESSAGE_ERROR = 'Upload failed. Please refer to the attachment / error log for details.';
	private static final String MESSAGE_SUCCESS = ' offtakes have been uploaded. An email has been sent to your mailbox.';
	private static final String MESSAGE_CURRENTMONTHCONFIRMED = 'The offtake of the upload month has been confirmed. You cannot overwrite it.';
	
	private static final String RTID_OFFTAKEHEADER = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_PH_Actual_Offtake_Header_Upload_Log');
	private static final String RT_SKU_DP = 'ASI_CRM_PH_DP_SKU';
	private static final String RT_SKU_DF = 'ASI_CRM_PH_DF_SKU';
	private static final String DUTYPAID = 'DP';
	private static final String DUTYFREE = 'DF';

    private final Id attachmentId;

    private Date validGlDate;

    public ASI_CRM_OfftakeCreationBatch(Id attachmentId) {
        this.attachmentId = attachmentId;
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Name, Body, Description, ParentId, Owner.Email, Owner.Name, ContentType
                FROM Attachment
                WHERE Id = :attachmentId
        ]);
    }

    public void execute(Database.BatchableContext context, List<Attachment> attachments) {

        if (attachments == null) return;

        //final Id actualOfftakeHeaderRecordTypeId = getActualOfftakeHeaderRecordTypeId();
        final Id actualOfftakeHeaderRecordTypeId = getActualOfftakeHeaderRecordTypeId();
        final Attachment attachmentInfo = attachments.get(0);
		//system.debug(attachmentInfo.parentId);
        final List<List<String>> csvData = ASI_CRM_FileUploadHelper.getCsvData(attachmentInfo.Body.toString(),false);
		
		boolean isConfirmed = false;

        ASI_CRM_FileUploadHelper.removeCsvHeader(csvData);
        setValidGlDate(csvData);

        final List<ASI_CRM_ActualOfftakeHeader__c> existingActualOfftakeHeaders = getActualOfftakeHeadersByGlDate(getValidGlDate());

        if (!existingActualOfftakeHeaders.isEmpty() && existingActualOfftakeHeaders.get(0).ASI_CRM_Confirmed__c) {
            //return;
			isConfirmed = true;
        }

		/*
        final ASI_CRM_ActualOfftakeHeader__c actualOfftakeHeader = new ASI_CRM_ActualOfftakeHeader__c();
        actualOfftakeHeader.RecordTypeId = actualOfftakeHeaderRecordTypeId;
        actualOfftakeHeader.ASI_CRM_OfftakeDate__c = getValidGlDate();
        insert actualOfftakeHeader;
		*/
        ASI_CRM_ActualOfftakeHeader__c actualOfftakeHeader = [select id from ASI_CRM_ActualOfftakeHeader__c where id = :attachmentInfo.parentId limit 1];
        actualOfftakeHeader.RecordTypeId = RTID_OFFTAKEHEADER;
        actualOfftakeHeader.ASI_CRM_OfftakeDate__c = getValidGlDate();
        //insert actualOfftakeHeader;

        final List<String> customerCodes = ASI_CRM_FileUploadHelper.getColumnValueListFromCSVData(csvData, CUSTOMER_CODE_INDEX);
        final List<String> skuCodesBeforeProcceed = ASI_CRM_FileUploadHelper.getColumnValueListFromCSVData(csvData, SKU_CODE_INDEX);
        final List<String> skuCodes = appendLeadingZero(skuCodesBeforeProcceed);
		system.debug(skuCodes);
		
        final Map<String, ASI_CRM_AccountsAdditionalField__c> customerCodeIdMap = getCustomerCodeIdMap(customerCodes);
        final Map<String, Id> skuCodeIdMap = getSkuCodeIdMap(skuCodes);
		system.debug(skuCodeIdMap);
        final Map<String, List<ASI_CRM_MY_SKUPriceCost__c>> skuCodeSkuPriceCostListMap = getSkuCodeSkuPriceCostListMap(skuCodes);
        final Set<String> invoiceNumbers = new Set<String>();

        final List<Row> rows = new List<Row>();
        final List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakesToInsert = new List<ASI_TH_CRM_Actual_Offtake__c>();
		
		Map<string, integer> map_duplicate = getDuplicateKey(csvData);
        

        Integer rowCounter = 0;
        for (List<String> csvRow : csvData) {

            Row row = createRow(rowCounter, csvRow, customerCodeIdMap, skuCodeIdMap, invoiceNumbers, actualOfftakeHeader.Id, skuCodeSkuPriceCostListMap, map_duplicate);

			if(rowCounter == 0 && isConfirmed == true){
				row.addErrorMessage(MESSAGE_CURRENTMONTHCONFIRMED);
			}
			
            if (!row.hasErrors()) {
                actualOfftakesToInsert.add(row.getActualOfftake());
            } else {
                ASI_CRM_FileUploadHelper.addCsvColumn(csvRow, String.join(row.getErrorMessages(), ', '));
            }

            rows.add(row);
            rowCounter++;
        }

        final Boolean hasErrors = validateRows(rows);
        final Attachment attachmentWithErrorMessages = attachmentInfo.clone(false, true, false, false);

        if (hasErrors) {
            //deleteActualOfftakeHeader(actualOfftakeHeader.Id);

            final Blob csvWithErrors = ASI_CRM_CSVReaderHelper.createCSVFile(csvData, MESSAGE_HEADER);
			/*
            attachmentWithErrorMessages.Body = csvWithErrors;
            insert attachmentWithErrorMessages;

            sendFailureEmailNotification(attachmentWithErrorMessages);
			*/
			
			attachmentInfo.Body = csvWithErrors;
			attachmentInfo.description = MESSAGE_ERROR;
			update attachmentInfo;
			
			actualOfftakeHeader.ASI_CRM_Upload_Failed__c = true;
			update actualOfftakeHeader;
			
            sendFailureEmailNotification(attachmentInfo);
			
            return;
        }

		update actualOfftakeHeader;
		if (!existingActualOfftakeHeaders.isEmpty()) {
			ASI_CRM_ActualOfftakeHeader__c existingActualOfftakeHeader = existingActualOfftakeHeaders.get(0);
			existingActualOfftakeHeader.ASI_CRM_All_Offtakes_Removed__c = true;
			update existingActualOfftakeHeader;

			deleteActualOfftakeByHeader(existingActualOfftakeHeader.Id);
		}
		
		/*
        deleteActualOfftakesByHeaderOfftakeDate(
                actualOfftakeHeader.ASI_CRM_OfftakeDate__c,
                ASI_CRM_RecordTypeApiName.ActualOfftake.ASI_CRM_PH_Actual_Offtake.name()
        );
		*/

        final List<Database.SaveResult> saveResults;
        if (actualOfftakesToInsert.size() > 0) {
            saveResults = Database.insert(actualOfftakesToInsert, true);
        }

        Integer totalSavedRecords = 0;
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) totalSavedRecords++;
        }

        //updateExistingActualOfftakeHeaders(existingActualOfftakeHeaders);

        if (totalSavedRecords != saveResults.size()) {
            sendFailureEmailNotification(attachmentWithErrorMessages);
        }
		
		attachmentInfo.description = actualOfftakesToInsert.size() + MESSAGE_SUCCESS;
		update attachmentInfo;
		
        sendSuccessEmailNotification(attachmentInfo);

    }

    public void finish(Database.BatchableContext context) {
    }

	private Map<string, integer> getDuplicateKey(List<List<String>> csvData){
		Map<string, integer> map_duplicate = new Map<string, integer>();
		for (List<String> csvRow : csvData) {

            final String customerCode = csvRow.get(CUSTOMER_CODE_INDEX);
			final String offTakeGLDateString = csvRow.get(OFFTAKE_GL_DATE_INDEX);
			final String skuCodeBeforeProceed = csvRow.get(SKU_CODE_INDEX);
			final String skuCode = skuCodeBeforeProceed.isNumeric() ? skuCodeBeforeProceed.leftPad(6,'0') : skuCodeBeforeProceed;
			final String invoiceNo = csvRow.get(INVOICE_NO_INDEX);
			final String key = customerCode + '_' + offTakeGLDateString + '_' + skuCode + '_' + invoiceNo;
			
			integer count = map_duplicate.containsKey(key) ? map_duplicate.get(key) : 0;
			count++;
			map_duplicate.put(key, count);
        }
		return map_duplicate;
	}
	
    private Boolean validateRows(List<Row> rows) {
        Boolean hasErrors = false;

        final Date glDate = getValidGlDate();
        for (Row row : rows) {
            final ASI_TH_CRM_Actual_Offtake__c actualOfftake = row.getActualOfftake();

            final Boolean invalidGlDate = (
                    actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c == null ||
                            actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.month() != glDate.month() ||
                            actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c.year() != glDate.year()
            );

            if (invalidGlDate) {
                row.addErrorMessage('Offtake G/L Date is not in the same month');
            }

            if (row.hasErrors()) {
                hasErrors = true;
            }
        }

        return hasErrors;
    }

    private Row createRow(
            Integer rowNumber,
            List<String> csvRow,
            Map<String, ASI_CRM_AccountsAdditionalField__c> customerCodeIdMap,
            Map<String, Id> skuCodeIdMap,
            Set<String> invoiceNumbers,
            Id actualOfftakeHeaderId,
            Map<String, List<ASI_CRM_MY_SKUPriceCost__c>> skuCodeSkuPriceCostListMap,
			Map<string, integer> map_duplicate
    ) {
        final Row row = new Row(rowNumber);

        final String customerCode = csvRow.get(CUSTOMER_CODE_INDEX);
        final String offTakeGLDateString = csvRow.get(OFFTAKE_GL_DATE_INDEX);
        final String skuCodeBeforeProceed = csvRow.get(SKU_CODE_INDEX);
		final String skuCode = skuCodeBeforeProceed.isNumeric() ? skuCodeBeforeProceed.leftPad(6,'0') : skuCodeBeforeProceed;
		system.debug(skuCode);
        final String invoiceNo = csvRow.get(INVOICE_NO_INDEX);
        final String quantityString = csvRow.get(QUANTITY_INDEX);
		String key = customerCode + '_' + offTakeGLDateString + '_' + skuCode + '_' + invoiceNo;

        final Id recordTypeId = getActualOfftakeRecordTypeId();
        final Id customerId = customerCodeIdMap.containsKey(customerCode) ? customerCodeIdMap.get(customerCode).Id : null;
		final boolean isDutyFree = customerCodeIdMap.containsKey(customerCode) ? customerCodeIdMap.get(customerCode).ASI_CRM_Duty_Free__c : false;
		final string duty = isDutyFree ? '_DF' : '_DP';

        if (String.isBlank(customerCode)) {
            row.addErrorMessage('Customer Code is empty');
        }
        if (!String.isBlank(customerCode) && customerId == null) {
            row.addErrorMessage('Customer Code does not exist');
        }

        final Date offtakeGlDate;
        if (String.isBlank(offTakeGLDateString)) {
            row.addErrorMessage('');
        } else {
            try {
                offtakeGlDate = ASI_CRM_DateUtil.parseDate(offTakeGLDateString, ASI_CRM_DateUtil.DATE_FORMAT_YYYYMMDD);

                if (offtakeGlDate.month() != getValidGlDate().month() || offtakeGlDate.year() != getValidGlDate().year()) {
                    row.addErrorMessage('Offtake G/L Date is not in the same month.');
                }
            } catch (ASI_CRM_CommonRoutine.ParseException e) {
                row.addErrorMessage(e.getMessage());
            }
        }

        final Id skuId = skuCodeIdMap.get(skuCode+duty);
        if (String.isBlank(skuCode)) {
            row.addErrorMessage('SKU Code is empty');
        }
        if (!String.isBlank(skuCode) && skuId == null) {
            row.addErrorMessage('Sku Code does not exist');
        }

        final Integer quantity;
        try {
            quantity = ASI_CRM_NumberUtil.getIntegerValue(quantityString);
        } catch (ASI_CRM_CommonRoutine.ParseException e) {
            row.addErrorMessage(e.getMessage());
        }

		/*
        //@Todo validate uniquiness of index number
        if (invoiceNumbers.contains(invoiceNo)) {
            row.addErrorMessage('Unique Indicator is duplicated.');
        } else {
            invoiceNumbers.add(invoiceNo);
        }
		*/
		if(map_duplicate.containsKey(key)){
			if(map_duplicate.get(key)>1){
				row.addErrorMessage('Unique Indicator is duplicated.');
			}
			
		}

		key = customerId + '_' + skuId + duty;
		
        //final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = skuCodeSkuPriceCostListMap.get(skuCode);
        final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = skuCodeSkuPriceCostListMap.get(key);
        if (skuPriceCosts == null || skuPriceCosts.isEmpty()) {
            row.addErrorMessage('Outlet Selling Price does not exist. Please maintain it under this Customer and SKU.');
        } else {
            Integer numberOfEffectivePriceCosts = 0;
            for (ASI_CRM_MY_SKUPriceCost__c skuPriceCost : skuPriceCosts) {
                if (skuPriceCost.ASI_CRM_EffectiveDate__c < offtakeGlDate) numberOfEffectivePriceCosts++;
            }
            if (numberOfEffectivePriceCosts == 0) {
                row.addErrorMessage('Outlet Selling Price does not exist before the effective date. Please maintain it under this Customer and SKU.');
            }
        }

        final ASI_TH_CRM_Actual_Offtake__c actualOfftake = new ASI_TH_CRM_Actual_Offtake__c();

        actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c = offtakeGlDate;
        actualOfftake.ASI_CRM_SG_Customer__c = customerId;
        actualOfftake.ASI_CRM_SKU__c = skuId;
        actualOfftake.ASI_CRM_Invoice_Number__c = invoiceNo;
        actualOfftake.ASI_CRM_Original_Quantity__c = quantity;
        actualOfftake.ASI_TH_CRM_Quantity__c = quantity;
        actualOfftake.RecordTypeId = recordTypeId;
        actualOfftake.ASI_CRM_ActualOfftakeHeader__c = actualOfftakeHeaderId;
        actualOfftake.ASI_CRM_Mass_Uploaded__c = true;
//        actualOfftake.ASI_CRM_CN_Batch_Id__c = ;

        row.setActualOfftake(actualOfftake);
        return row;
    }

    private static void updateExistingActualOfftakeHeaders(List<ASI_CRM_ActualOfftakeHeader__c> existingActualOfftakeHeaders) {

        for (ASI_CRM_ActualOfftakeHeader__c existingActualOfftakeHeader : existingActualOfftakeHeaders) {
            existingActualOfftakeHeader.ASI_CRM_All_Offtakes_Removed__c = true;
            existingActualOfftakeHeader.RecordTypeId = getActualOfftakeHeaderLogRecordTypeId();
        }
        update existingActualOfftakeHeaders;
    }

    private static Messaging.SingleEmailMessage createEmailNotification(String subject, String body, Attachment attachmentInfo) {
        final Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
        final List<String> recipients = new List<String>{
                attachmentInfo.Owner.Email
        };
        final List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>{
                createEmailFileAttachment(attachmentInfo)
        };

        mailMessage.setHtmlBody(body);
        mailMessage.setToAddresses(recipients);
        mailMessage.setReplyTo('noreply@salesforce.com');
        mailMessage.setSenderDisplayName('Offset Mass Upload');
        mailMessage.setSubject(subject);
        mailMessage.setFileAttachments(emailFileAttachments);

        return mailMessage;
    }

    private static Messaging.EmailFileAttachment createEmailFileAttachment(Attachment attachmentInfo) {
        final Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();

        emailFileAttachment.setFileName(attachmentInfo.Name);
        emailFileAttachment.setBody(attachmentInfo.Body);
        emailFileAttachment.setContentType(attachmentInfo.ContentType);

        return emailFileAttachment;
    }

    private static void sendSuccessEmailNotification(Attachment attachmentInfo) {

        String body = 'Hi ' + attachmentInfo.Owner.Name + ',<br/>';
        body += 'Offtakes have been uploaded successfully.';

        final Messaging.SingleEmailMessage email = createEmailNotification('Completed Offtakes Upload', body, attachmentInfo);

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
    }

    private static void sendFailureEmailNotification(Attachment attachmentInfo) {

        String body = 'Hi ' + attachmentInfo.Owner.Name + ',<br/>';
        body += 'Offtakes have NOT been uploaded. Please note the errors on the attachment.<br/>';
        body += 'Please do not reply to this message.<br/>';
        body += 'Contact your system administrator if you feel you received this message in error.<br/>';

        final Messaging.SingleEmailMessage email = createEmailNotification('Failed Offtakes Upload', body, attachmentInfo);

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
    }

    //Data Helpers
	
	private List<string> appendLeadingZero(list<string> list_skuCodeBeforeProceed){
		list<string> list_skuCode = new list<string>();
		for(string skuCodeBeforeProceed : list_skuCodeBeforeProceed){
			list_skuCode.add(skuCodeBeforeProceed.isNumeric() ? skuCodeBeforeProceed.leftPad(6,'0') : skuCodeBeforeProceed);
		}
		return list_skuCode;
	}

    private Date getValidGlDate() {
        return this.validGlDate;
    }

    private void setValidGlDate(List<List<String>> csvData) {

        final Date validGlDate = ASI_CRM_DateUtil.parseDate(csvData.get(0).get(OFFTAKE_GL_DATE_INDEX), ASI_CRM_DateUtil.DATE_FORMAT_YYYYMMDD);

        this.validGlDate = validGlDate;
    }

    private static Map<String, ASI_CRM_AccountsAdditionalField__c> getCustomerCodeIdMap(List<String> customerCodes) {
        final Map<String, ASI_CRM_AccountsAdditionalField__c> customerCodeIdMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        for (ASI_CRM_AccountsAdditionalField__c customer : getCustomersByCode(customerCodes)) {
            customerCodeIdMap.put(customer.ASI_CRM_MY_CustomerCode__c, customer);
        }
        return customerCodeIdMap;
    }

    private static Map<String, Id> getSkuCodeIdMap(List<String> skuCodes) {
        system.debug(skuCodes);
        system.debug(getSkuCodes(skuCodes));
		final Map<String, Id> skuCodeIdMap = new Map<String, Id>();
        for (ASI_MFM_SKU_Code__c skuCode : getSkuCodes(skuCodes)) {
            string duty = skuCode.recordtype.developername == 'ASI_CRM_PH_DP_SKU' ? '_DP' : '_DF';
			skuCodeIdMap.put(skuCode.ASI_MFM_SKU_Code__c + duty, skuCode.Id);
        }
        return skuCodeIdMap;
    }

    private static List<ASI_CRM_AccountsAdditionalField__c> getCustomersByCode(List<String> customerCodes) {
        return [
                SELECT Id, ASI_CRM_MY_CustomerCode__c, ASI_CRM_Duty_Free__c
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE ASI_CRM_MY_CustomerCode__c  IN :customerCodes
                AND RecordType.DeveloperName = :ASI_CRM_RecordTypeApiName.AccountsAdditionalField.ASI_CRM_PH_Customer.name()
        ];
    }

    private static List<ASI_MFM_SKU_Code__c> getSkuCodes(List<String> skuCodes) {
        return [
                SELECT Id, ASI_MFM_SKU_Code__c, recordtype.developername
                FROM ASI_MFM_SKU_Code__c
                WHERE ASI_MFM_SKU_Code__c IN :skuCodes
                AND RecordType.DeveloperName IN (
                        :ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DP_SKU.name(),
                        :ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DF_SKU.name()
                )
        ];
    }

    private static List<ASI_CRM_ActualOfftakeHeader__c> getActualOfftakeHeadersByGlDate(Date glDate) {
        String year = String.valueOf(glDate.year());
        String month = String.valueOf(glDate.month());
		return [
                SELECT Id, ASI_CRM_Confirmed__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE 
				//ASI_CRM_OfftakeDate__c = :glDate
                //RecordType.DeveloperName = :ASI_CRM_RecordTypeApiName.ActualOfftakeHeader.ASI_CRM_PH_Actual_Offtake_Header.name()
                RecordTypeId = :RTID_OFFTAKEHEADER
				AND ASI_CRM_Year__c = :year
				AND ASI_CRM_Month__c = :month
				AND ASI_CRM_All_Offtakes_Removed__c = false
				AND ASI_CRM_Upload_Failed__c = false
				limit 1
        ];
    }

    private static Id getActualOfftakeHeaderRecordTypeId() {
        return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
                ASI_CRM_ActualOfftakeHeader__c.getSObjectType(),
                ASI_CRM_RecordTypeApiName.ActualOfftakeHeader.ASI_CRM_PH_Actual_Offtake_Header.name()
        );
    }

    private static Id getActualOfftakeHeaderLogRecordTypeId() {
        return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
                ASI_CRM_ActualOfftakeHeader__c.getSObjectType(),
                ASI_CRM_RecordTypeApiName.ActualOfftakeHeader.ASI_CRM_PH_Actual_Offtake_Header_Upload_Log.name()
        );
    }

    private static Id getActualOfftakeRecordTypeId() {
        return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
                ASI_TH_CRM_Actual_Offtake__c.getSObjectType(),
                ASI_CRM_RecordTypeApiName.ActualOfftake.ASI_CRM_PH_Actual_Offtake.name()
        );
    }

    private static Map<String, List<ASI_CRM_MY_SKUPriceCost__c>> getSkuCodeSkuPriceCostListMap(List<String> skuCodes) {

        final Map<String, List<ASI_CRM_MY_SKUPriceCost__c>> skuCodeSkuPriceCostListMap = new Map<String, List<ASI_CRM_MY_SKUPriceCost__c>>();
        for (ASI_CRM_MY_SKUPriceCost__c skuPriceCost : getSkuPriceCost(skuCodes, ASI_CRM_RecordTypeApiName.SkuPriceCost.ASI_CRM_PH_Outlet_Selling_Price.name())) {

            string duty = skuPriceCost.ASI_CRM_SKU__r.recordtype.developername == 'ASI_CRM_PH_DP_SKU' ? '_DP' : '_DF';
			string customerId = skuPriceCost.ASI_CRM_Customer__c;
			string skuId = skuPriceCost.ASI_CRM_SKU__c;
			string key = customerId + '_' + skuId + duty;
		
			/*
            if (skuCodeSkuPriceCostListMap.get(skuPriceCost.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c) == null) {
                skuCodeSkuPriceCostListMap.put(skuPriceCost.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, new List<ASI_CRM_MY_SKUPriceCost__c>());
            }

            skuCodeSkuPriceCostListMap.get(skuPriceCost.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c).add(skuPriceCost);
			*/
            if (skuCodeSkuPriceCostListMap.get(key) == null) {
                skuCodeSkuPriceCostListMap.put(key, new List<ASI_CRM_MY_SKUPriceCost__c>());
            }

            skuCodeSkuPriceCostListMap.get(key).add(skuPriceCost);
        }
        return skuCodeSkuPriceCostListMap;
    }

    private static List<ASI_CRM_MY_SKUPriceCost__c> getSkuPriceCost(List<String> skuCodes, String recordTypeApiName) {
        return [
                SELECT Id, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_CRM_Customer__c, ASI_CRM_SKU__r.recordtype.developername
                FROM ASI_CRM_MY_SKUPriceCost__c
                WHERE ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c IN :skuCodes
                AND RecordType.DeveloperName = :recordTypeApiName
        ];
    }

    //DML
    private static void deleteActualOfftakeHeader(Id actualOfftakeHeaderId) {
        delete [
                SELECT Id
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE Id = :actualOfftakeHeaderId
        ];
    }

    private static void deleteActualOfftakeByHeader(Id actualOfftakeHeaderId) {
        delete [
                SELECT Id
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__c = :actualOfftakeHeaderId
        ];
    }

    private static void deleteActualOfftakesByHeaderOfftakeDate(Date offtakeDate, String recordTypeApiName) {
        final Date startDate = offtakeDate.toStartOfMonth();
        final Date endDate = offtakeDate.addMonths(1).toStartOfMonth().addDays(-1);

        delete [
                SELECT Id
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_TH_CRM_Offtake_G_L_Date__c >= :startDate
                AND ASI_TH_CRM_Offtake_G_L_Date__c <= :endDate
                AND RecordType.DeveloperName = :recordTypeApiName
        ];
    }

    public class Row {
        private Integer rowNumber;
        private ASI_TH_CRM_Actual_Offtake__c actualOfftake;
        private List<String> errorMessages = new List<String>();

        Row(Integer rowNumber) {
            this.rowNumber = rowNumber;
        }

        public Integer getRowNumber() {
            return rowNumber;
        }

        public ASI_TH_CRM_Actual_Offtake__c getActualOfftake() {
            return actualOfftake;
        }

        public void setActualOfftake(ASI_TH_CRM_Actual_Offtake__c actualOfftake) {
            this.actualOfftake = actualOfftake;
        }

        public List<String> getErrorMessages() {
            return errorMessages;
        }

        public void addErrorMessage(String errorMessage) {
            this.errorMessages.add(errorMessage);
        }

        public Boolean hasErrors() {
            return !this.errorMessages.isEmpty();
        }

    }
}