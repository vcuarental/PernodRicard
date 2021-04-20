global class ASI_CRM_CN_MassUploadProcess implements Database.Batchable<SObject> {

    global final String ObjAPIName;
    global final String parentID;
    global final String parentField;
    global final String fields;
    global final String fieldsLabel;
    global final String lookupEXID;
    //global final String template;
    global final String recordtypeName;
    global final String currentPageURL;
    global final String defaultValues;
    global final String AttID;
    //global final boolean inlineVF;
    //global final boolean reloadNeeded;
    global final String recEXID { set; get; }
    global final String recEXIDcol { set; get; }
    global final String parentObjectAPIName { set; get; }
    global final String ParentObjectUploadMsg { set; get; }
    global final Boolean upsertMode { set; get; }
    global final Boolean batchMode { set; get; }
    global final Boolean opt_allOrNone { set; get; }
    global final Boolean emailNotification { set; get; }
    global Boolean removeAttachmentAfterUpload { set; get; } {removeAttachmentAfterUpload = false;}
    global List<Attachment> LAttUpdate;
    global List<SObject> recordsToDelete;

    public String currentPageURLOutput { set; get; }
    private Schema.SObjectType ObjType;
    private Schema.SObjectType ParentObjType;
    private List<String> LFieldAPIName;
    private List<String> LFieldLabel;
    private Map<String, String> MAPINameLabel;
    private List<Row> LInputRow;
    public List<Row> LErrorRows { set; get; }
    private List<lookupRecord> LLookupField;
    private Map<String, Integer> MFieldPos;
    private Map<String, Integer> MLookupFieldPos;
    private Map<String, Id> MRecTypeID;
    public Boolean hasError { set; get; }
    public String msg { set; get; }
    private Id recordtypid;
    private List<String> LDefaultVales;
    private List<String> LDefaultValesHeader;
    private List<String> LEXIDFieldLabel;

    private Integer rowCount;
    private Integer colCount;

    public String encoding { set; get; }

    global ASI_CRM_CN_MassUploadProcess(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName,
        String defaultValues, String currentPageURL, String AttID, String recEXID, String recEXIDcol, String parentObjectAPIName, String ParentObjectUploadMsg,
        Boolean upsertMode, Boolean emailNotification, Boolean opt_allOrNone) {
        this.ObjAPIName = ObjAPIName;
        this.parentID = parentID;
        this.parentField = parentField;
        this.fields = fields;
        this.fieldsLabel = fieldsLabel;
        this.lookupEXID = lookupEXID;
        this.recordtypeName = recordtypeName;
        this.AttID = AttID;
        this.defaultValues = defaultValues;
        this.recEXID = recEXID;
        this.recEXIDcol = recEXIDcol;
        this.parentObjectAPIName = parentObjectAPIName;
        this.ParentObjectUploadMsg = ParentObjectUploadMsg;
        this.upsertMode = upsertMode;
        this.emailNotification = emailNotification;
        this.opt_allOrNone = opt_allOrNone;
    }

    global database.QueryLocator start(Database.BatchableContext BC) {
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([select Id, Name, Body, Description, ParentId,Owner.Email from Attachment where Id = :AttID]);
    }

    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (scope == null) {
            return;
        }

        init();
        LAttUpdate = new List<Attachment>();
        List<SObject> LParentObj = new List<SObject>();
        Map<Id, String> resultTexts = new Map<Id, String>();

        for (SObject sc : scope) {
            Attachment att = (Attachment) sc;
            att.Description = '';
            resultTexts.put(att.Id, '');
            LErrorRows = new List<Row>();
            String namefile = att.Name;
            System.debug('namefile' + namefile);
            if (namefile.toLowerCase().right(3) != 'csv') {
                msg = 'Error: Please select csv file only!';
            }

            List<List<String>> parsedCSV = genResults(att.Body);
            List<String> LHeader = new List<String>();

            if (parsedCSV != null && parsedCSV.size() > 0) {
                System.debug('first row ' + parsedCSV[0]);
                // retrieve header of csv
                LHeader = addDefaultValues(parsedCSV[0], true);
                parsedCSV.remove(0);
                System.debug(LHeader);
                Integer i = 0;
                for (List<String> LS : parsedCSV) {
                    LS = addDefaultValues(LS, false);
                }
                MFieldPos = new Map<String, Integer>();
                for (String h : LHeader) {
                    MFieldPos.put(h.toLowerCase().trim(), i);
                    i++;
                }

                LLookupField = new List<lookupRecord>();
                MLookupFieldPos = new Map<String, Integer>();

                if (String.isNotEmpty(lookupEXID)) {

                    for (String s : lookupEXID.split(';', 0)) {
                        lookupRecord tempLookupRecord = new lookupRecord(s);
                        LLookupField.add(tempLookupRecord);
                        MLookupFieldPos.put(tempLookupRecord.Field, LLookupField.size() - 1);
                    }
                }
                for (lookupRecord lookupField : LLookupField) {
                    for (List<String> LS : parsedCSV) {
                        lookupField.addKey(LS, MFieldPos, MRecTypeID);
                    }
                    lookupField.queryResult();
                }

                LInputRow = new List<Row>();
                Integer rowNumber = 1;
                Map<String, String> MFieldType = new Map<String, String>();

                for (String fieldname : LFieldAPIName) {
                    MFieldType.put(fieldname, ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());

                }
                LEXIDFieldLabel = new List<String>();
                if (String.isNotEmpty(recEXID)) {
                    LEXIDFieldLabel = recEXID.split(';', 0);
                }

                for (List<String> LS : parsedCSV) {
                    // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                    Row r;
                    if (parentField != null && parentID != null)
                        r = new row(ObjType.newSObject(), parentField, parentID); else
                        r = new row(ObjType.newSObject());
                    // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null

                    if (recordtypid != null) {
                        r.sObj.put('recordtypeid', recordtypid);
                    }
                    String testUOMf;
                    String testOrder;
                    String testSO;
                    Integer inputCol = 0;

                    for (String fieldname : LFieldAPIName) {
                        String labelname = MAPINameLabel.get(fieldname);

                        if (MAPINameLabel.get(fieldname) == 'Order Quantity(Wholesaler Input)') {
                            testOrder = LS[MFieldPos.get(labelname)];

                        } else if (MAPINameLabel.get(fieldname) == 'UOM(BOTTLE/CASE)(Wholesaler input)') {
                            testUOMf = LS[MFieldPos.get(labelname)];
                        }
                        if (testOrder != '') {
                            if (MLookupFieldPos.containsKey(fieldname)) {

                                if (matchLookupField(MLookupFieldPos.get(fieldname), LS, MFieldPos, MRecTypeID) == null) {
                                    if (labelname == 'Promotion Code') {
                                        if (LS[MFieldPos.get(labelname)] == '') {
                                            break;
                                        } else if (LS[MFieldPos.get(labelname)] != '') {
                                            r.addError('Please verify the Promotion Code.');
                                            hasError = true;
                                        }
                                    } else if (labelname == 'CRM Code') {
                                        System.debug('missing crm code');
                                        System.debug('fieldname ' + fieldname);
                                        System.debug('MLookupFieldPos ' + MLookupFieldPos.get(fieldname));
                                        System.debug('LS ' +LS);
                                        r.addError(Label.ASI_CRM_CN_Covered_Outlet_Code_Missing_or_Wrong);
                                        hasError = true;
                                    } else {
                                        r.addError('Incomplete information, Please check the Sales Order ID or UOM');
                                        hasError = true;
                                    }
                                } else if (matchLookupField(MLookupFieldPos.get(fieldname), LS, MFieldPos, MRecTypeID) != null) {

                                    if (labelname == 'Promotion Code') {

                                        String discount = LS[MFieldPos.get(labelname)];
                                        String testdis = discount.toLowerCase();
                                        if (testdis.contains('g')) {
                                            Integer orderqty = Integer.valueOf(testOrder);
                                            Integer index;
                                            String [] chars = discount.toLowerCase().split('');
                                            String char2 = '';
                                            for (Integer testi = 0; testi < chars.size(); testi++) {
                                                if (chars[testi] == 'g') {
                                                    index = testi;
                                                }
                                            }
                                            for (Integer testi2 = 1; testi2 < index; testi2++) {
                                                char2 = char2 + chars[testi2];
                                            }
                                            Integer discount2 = Integer.valueOf(char2);
                                            if (Math.mod(orderqty, discount2) != 0 || discount2 > orderqty) {
                                                r.addError(labelname + ' For Buy X Get Y Promotion type, order quantity must be less than X or multiple of X.');
                                                hasError = true;
                                            } else if (Math.mod(orderqty, discount2) == 0) {
                                                break;
                                            }
                                        } else if (!testdis.contains('g')) {
                                            r.addError(labelname + ' break test.');
                                            hasError = true;
                                        }
                                    }
                                }
                                try {
                                    if (labelname != 'Promotion Code') {
                                        r.sObj.put(fieldname, matchLookupField(MLookupFieldPos.get(fieldname), LS, MFieldPos, MRecTypeID));
                                    }
                                } catch (Exception e) {
                                    if (labelname != 'Promotion Code') {
                                        r.addError(labelname + ': Cannot find record.');
                                        hasError = true;
                                    }
                                }
                            }

                            else if (MAPINameLabel.get(fieldname) == 'Order Quantity(Wholesaler Input)' && LS[MFieldPos.get(labelname)] == '') {
                                try {

                                } catch (Exception e) {
                                    r.addError(labelname + ': Please verify the input.');
                                    hasError = true;
                                }
                            } else if (MAPINameLabel.get(fieldname) == 'UOM(BOTTLE/CASE)(Wholesaler input)') {//&&LS[MFieldPos.get(labelname)]!=''){
                                if (LS[MFieldPos.get(labelname)] != '') {//20160122
                                    String testUOM = LS[MFieldPos.get(labelname)].toLowerCase();
                                    if (testUOM == 'bottle') {
                                        r.sObj.put(fieldname, 'BT');
                                    } else if (testUOM == 'case') {
                                        r.sObj.put(fieldname, 'CA');
                                    } else {
                                        r.addError('UOM should be either Bottle or Case, Please check the input!');
                                        hasError = true;
                                    }
                                } else if (LS[MFieldPos.get(labelname)] == '') {//20160122 Ben @ Elufa
                                    r.sObj.put(fieldname, 'CA');
                                }
                            } else if (MFieldPos.containsKey(labelname) && LS[MFieldPos.get(labelname)] != null && LS[MFieldPos.get(labelname)] != '') {


                                if (MFieldType.containsKey(fieldname)) {
                                    String tempFieldType = MFieldType.get(fieldname);
                                    //if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='boolean'){
                                    if (tempFieldType == 'boolean') {

                                        if (LS[MFieldPos.get(labelname)].toLowerCase().trim() == 'y' || LS[MFieldPos.get(labelname)].trim() == '1' || LS[MFieldPos.get(labelname)].toLowerCase().trim() == 'true') {
                                            try {
                                                r.sObj.put(fieldname, true);
                                            } catch (Exception e) {
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        } else {
                                            try {
                                                r.sObj.put(fieldname, false);
                                            } catch (Exception e) {
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }

                                    }
                                    //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='date'){
                                    else if (tempFieldType == 'date') {
                                        try {
                                            String dateText = LS[MFieldPos.get(labelname)];
                                            if (dateText.contains('/')) {
                                                Date tempdate = dateSpliter(dateText);
                                                r.sObj.put(fieldname, tempdate);
                                            } else {
                                                r.sObj.put(fieldname, Date.newInstance(Integer.valueOf(dateText.substring(0, 4)), Integer.valueOf(dateText.substring(4, 6)), Integer.valueOf(dateText.substring(6, 8))));
                                            }

                                        }

                                        catch (Exception e) {
                                            r.addError(labelname + ': ' + e.getMessage());
                                            hasError = true;
                                        }
                                    }//Added by steve at 12/2015. Handle different formatting issues, e.g. DD/MM/YYYY , YYYYMMDD.

                                    //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='double' ||
                                    //    ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='percent' ||
                                    //    ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='currency'
                                    //){
                                    else if (tempFieldType == 'double' ||
                                        tempFieldType == 'percent' ||
                                        tempFieldType == 'currency'
                                        ) { /*string test = LS[MFieldPos.get(labelname)];
                                          if(test.contains(',')){
                                             decimal finalPrice=currencySpliter(test);
                                                  r.sObj.put(fieldname,finalPrice);
                                          }
                                            else*/
                                        try {
                                            r.sObj.put(fieldname, Decimal.valueOf(LS[MFieldPos.get(labelname)]));
                                        } catch (Exception e) {
                                            r.addError(labelname + ': ' + e.getMessage());
                                            hasError = true;
                                        }
                                    }
                                    //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='integer'){
                                    else if (tempFieldType == 'integer') {
                                        try {
                                            r.sObj.put(fieldname, Integer.valueof(LS[MFieldPos.get(labelname)]));
                                        } catch (Exception e) {
                                            r.addError(labelname + ': ' + e.getMessage());
                                            hasError = true;
                                        }
                                    } else {
                                        try {
                                            r.sObj.put(fieldname, LS[MFieldPos.get(labelname)]);
                                        } catch (Exception e) {
                                            r.addError(labelname + ': ' + e.getMessage());
                                            hasError = true;
                                        }
                                    }
                                }
                            }


                        }
                        /*else if(testOrder==''&&MAPINameLabel.get(fieldname)=='UOM(BOTTLE/CASE)(Wholesaler input)'){
                            if(LS[MFieldPos.get(labelname)]!=''){
                               r.addError('Imcomplete information, Please check the Order Qty or Sales Order ID.');
                                hasError = true;
                            }
                        }*/ else if (testOrder == '' && testUOMf == '' && MAPINameLabel.get(fieldname) == 'Sales Order ID(User Input)') {
                            if (LS[MFieldPos.get(labelname)] != '') {
                                r.addError('Incomplete information, Please check the Order Qty or UOM.');
                                hasError = true;
                            }
                        }

                    }
                    r.rowNumber = rowNumber++;
                    if (r.hasErrors) {
                        LErrorRows.add(r);
                    }
                    // to generate EXID column
                    String tempEXIDValue = '';
                    for (String exid : LEXIDFieldLabel) {
                        exid = exid.toLowerCase();

                        if (MFieldPos.containsKey(exid) && LS[MFieldPos.get(exid)] != null && LS[MFieldPos.get(exid)] != '') {
                            tempEXIDValue += LS[MFieldPos.get(exid)].toLowerCase();
                        }
                    }
                    if (tempEXIDValue != '') {
                        r.sObj.put(recEXIDcol, tempEXIDValue);
                    }

                    LInputRow.add(r);

                }

                if (ObjAPIName == 'ASI_CRM_CN_Covered_Outlet__c') {

                    List<ASI_CRM_CN_Covered_Outlet__c> coveredOutlets = new List<ASI_CRM_CN_Covered_Outlet__c>();
                    for (Row row : LInputRow) {
                        ASI_CRM_CN_Covered_Outlet__c coveredOutlet = (ASI_CRM_CN_Covered_Outlet__c) row.sObj;
                        if (coveredOutlet == null) {
                            row.addError(Label.ASI_CRM_CN_Covered_Outlet_Code_Missing_or_Wrong);
                            hasError = true;
                            continue;
                        }
                        coveredOutlets.add(coveredOutlet);
                    }
                    Set<Id> coveredOutletIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_CN_Covered_Outlet__c.ASI_CRM_CN_Outlet__c, coveredOutlets);
                    Map<Id, ASI_CRM_AccountsAdditionalField__c> outletsById = new Map<Id, ASI_CRM_AccountsAdditionalField__c>([SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName = 'ASI_CRM_Outlet_CN' AND Id IN :coveredOutletIds]);

                    List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletsOutsideGroupPO = ASI_CRM_CN_CoveredOutletValidationClass.getCoveredOutletsOutsideGroupPO(coveredOutlets, parentID);
                    if (!coveredOutletsOutsideGroupPO.isEmpty()) {
                        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletsOutsideGroupPO) {
                            if (coveredOutlet.ASI_CRM_CN_Outlet__c != null) {
                                LInputRow[0].addError(
                                    String.format(
                                        Label.ASI_CRM_CN_Covered_Outlet_not_existed_in_Group_PO,
                                        new List<String>{
                                            outletsById.get(coveredOutlet.ASI_CRM_CN_Outlet__c).Name,
                                            ''
                                        }
                                    )
                                );
                                hasError = true;

                            }
                        }
                    }
                    Map<ASI_CRM_CN_Covered_Outlet__c, List<ASI_TH_CRM_Contract__c>> coveredOutletsOverlapWithOtherContracts = ASI_CRM_CN_CoveredOutletValidationClass.getCoveredOutletsOverlapWithOtherContracts(coveredOutlets, parentID);
                    if (!coveredOutletsOverlapWithOtherContracts.isEmpty()) {
                        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletsOverlapWithOtherContracts.keySet()) {
                            List<String> contractName = new List<String>();
                            for (ASI_TH_CRM_Contract__c contract : coveredOutletsOverlapWithOtherContracts.get(coveredOutlet)) {
                                contractName.add(contract.Name);
                            }
                            if (coveredOutlet.ASI_CRM_CN_Outlet__c != null) {
                                LInputRow[0].addError(
                                    String.format(
                                        Label.ASI_CRM_CN_Outlet_overlap,
                                        new List<String>{
                                            outletsById.get(coveredOutlet.ASI_CRM_CN_Outlet__c).Name, String.join(contractName, ',')
                                        }
                                    )
                                );
                                hasError = true;

                            }
                        }
                    }

                }
                List<SObject> lRecInsert = new List<SObject>();

                System.debug('Has Error: ' + hasError + ' Is upsertMode?: ' + upsertMode);

                if (!hasError || upsertMode) {
                    for (Row r : LInputRow) {
                        if (!r.hasErrors) {
                            lRecInsert.add(r.sObj);
                        }
                    }


                    if (lRecInsert != null && lRecInsert.size() > 0) {

                        if (ObjAPIName == 'ASI_CRM_CN_Covered_Outlet__c') {
                            //Add by Keith Yip For Promotion PO
                            if(fields.contains('ASI_CRM_CN_Est_Visibility_Amt__c')){ //Delete Covered Outlet only
                                recordsToDelete = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :parentID and ASI_CRM_CN_Outlet__r.RecordType.DeveloperName ='ASI_CRM_Outlet_CN'];
                            }else if(fields.contains('ASI_CRM_CN_Strategy_WS__c')){ //Delete WS only
                                recordsToDelete = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :parentID and ASI_CRM_CN_Outlet__r.RecordType.DeveloperName ='ASI_CRM_CN_WS'];
                            }else {
                                recordsToDelete = [SELECT Id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :parentID];
                            }
                            System.debug(recordsToDelete);
                            System.debug(recordsToDelete.size());
                            delete recordsToDelete;

                        }


                        try {
                            List<Database.UpsertResult> uResults = new List<Database.UpsertResult>();
                            List<Database.SaveResult> insertResults = new List<Database.SaveResult>();

                            if (upsertMode) {
                                // Hard Code for Casting before upsert
                                if (ObjAPIName == 'ASI_KOR_Sales_Order_Transaction__c') {
                                    List<ASI_KOR_Sales_Order_Transaction__c> LUpsert = new List<ASI_KOR_Sales_Order_Transaction__c>();
                                    if (!hasError) {
                                        for (SObject s : lRecInsert) {
                                            if (((ASI_KOR_Sales_Order_Transaction__c) s).ASI_KOR_Order_Qty__c != null && ((ASI_KOR_Sales_Order_Transaction__c) s).ASI_KOR_Sales_Order_Request__c != null && ((ASI_KOR_Sales_Order_Transaction__c) s).ASI_CRM_UOM_Text__c != null) {
                                                LUpsert.add((ASI_KOR_Sales_Order_Transaction__c) s);
                                            }
                                        }
                                    }
                                    try {

                                        uResults = Database.upsert(LUpsert, ObjType.getDescribe().fields.getMap().get(recEXIDcol), opt_allOrNone);
                                    } catch (Exception e) {
                                        throw e;
                                        System.debug(e.getMessage());
                                    }
                                } else {

                                    System.debug('Error, upsert target object is not defined in ASI_MFM_MassUploadProcess apex class!');
                                }
                                //Schema.SObjectField f = ObjType.getDescribe().fields.getMap().get(recEXIDcol);
                                //upsert (List<ASI_MFM_Event_Outlet__c>)lRecInsert ASI_MFM_EXID__c;
                            } else {
                                //Added by Wilken on 20150113 Add Insert Result to VF page display
                                insertResults = Database.insert(lRecInsert, opt_allOrNone);
                            }
                            Integer succInsert = 0;
                            Integer succUpdate = 0;
                            String validationErrorText = '';
                            Integer rowNo = 0;

                            //Upsert Result

                            for (Database.UpsertResult res : uResults) {
                                rowNo++;
                                if (res.isSuccess()) {
                                    if (res.isCreated()) {
                                        System.debug('Created record ID ' + res.getId() + '.');
                                        succInsert++;
                                    } else {
                                        System.debug('Updated record ID ' + res.getId() + '.');
                                        succUpdate++;
                                    }
                                } else {
                                    if (res.getErrors().size() > 0) {
                                        System.debug(res.getErrors()[0].getMessage());
                                        validationErrorText += 'Row' + String.valueOf(rowNo) + ': ' + res.getErrors()[0].getMessage();
                                    }

                                }
                            }

                            //Insert Result
                            for (Database.SaveResult res : insertResults) {
                                rowNo++;
                                if (res.isSuccess()) {
                                    System.debug('Created record ID ' + res.getId() + '.');
                                    succInsert++;
                                } else {
                                    if (res.getErrors().size() > 0) {
                                        System.debug(res.getErrors()[0].getMessage());
                                        validationErrorText += 'Row' + String.valueOf(rowNo) + ': ' + res.getErrors()[0].getMessage();
                                    }
                                }
                            }

                            msg = Label.ASI_CRM_CN_Upload_Covered_Outlet_Completed + '\n' +
                                String.format(Label.ASI_CRM_CN_Upload_Covered_Outlet_Record_Created, new String[] {String.valueOf(succInsert)}) + '\n' +
                                String.format(Label.ASI_CRM_CN_Upload_Covered_Outlet_Record_Updated, new String[] {String.valueOf(succUpdate)}) + '\n';
                            String errorText = '';
                            for (Row r : LInputRow) {
                                if (r.hasErrors) {
                                    for (String errorMsg : r.errorMsgs) {
                                        if (errorText != '') errorText += '\n';
                                        errorText += 'Row' + String.valueOf((r.rowNumber + 1)) + ': ' + errorMsg;
                                    }
                                }
                            }
                            if (errorText != '')
                                msg += errorText;
                            resultTexts.put(att.Id, msg);
                            LAttUpdate.add(att);
                            SObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id', att.ParentId);
                            tempParent.put(ParentObjectUploadMsg, att.Description);
                            LParentObj.add(tempParent);
                            //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));
                            /*if(inlineVF)
                                refreshPage2();
                            else
                                refreshPage();*/
                        } catch (DmlException de) {
                            hasError = true;

                            for (Integer j = 0; j < de.getNumDml(); j++) {
                                //debug += 'fieldname: ' + e.getDmlFieldNames(j)+'|';
                                //debug += 'index: ' + e.getDmlIndex(j)+'|';
                                LInputRow[j].addError(de.getDmlMessage(j));
                                //att.description += e.getDmlMessage(j) + '\n';
                                resultTexts.put(att.Id, resultTexts.get(att.Id) + '\n' + de.getDmlMessage(j));
                                LErrorRows.add(LInputRow[j]);
                                //debug += 'statuscode: ' + e.getDmlStatusCode(j)+'|';
                            }
                            msg = '';
                            LAttUpdate.add(att);
                            SObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id', att.ParentId);
                            tempParent.put(ParentObjectUploadMsg, resultTexts.get(att.Id).length() > 32000? resultTexts.get(att.Id).substring(0, 32000) : resultTexts.get(att.Id));
                            LParentObj.add(tempParent);
                            //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));

                        } catch (Exception e) {
                            System.debug('error' + e);
                            hasError = true;
                            LInputRow[0].addError(e.getMessage());
                            resultTexts.put(att.Id, resultTexts.get(att.Id) + '\n' + e.getMessage());
                            LErrorRows.add(LInputRow[0]);
                            msg = '';
                            LAttUpdate.add(att);
                            SObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id', att.ParentId);
                            tempParent.put(ParentObjectUploadMsg, resultTexts.get(att.Id).length() > 32000? resultTexts.get(att.Id).substring(0, 32000) : resultTexts.get(att.Id));
                            LParentObj.add(tempParent);
                            //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));

                            //e.getMessage();
                        }
                    } else {
                        String errorText = '';
                        for (Row r : LInputRow) {
                            if (r.hasErrors) {
                                for (String errorMsg : r.errorMsgs) {
                                    if (errorText != '') errorText += '\n';
                                    errorText += 'Row' + String.valueOf(r.rowNumber) + ': ' + errorMsg;
                                }
                            }
                        }
                        if (errorText != '')
                            resultTexts.put(att.Id, resultTexts.get(att.Id) + '\n' + errorText);
                        LAttUpdate.add(att);
                        SObject tempParent = ParentObjType.newSObject();
                        tempParent.put('id', att.ParentId);
                        tempParent.put(ParentObjectUploadMsg, resultTexts.get(att.Id).length() > 32000? resultTexts.get(att.Id).substring(0, 32000) : resultTexts.get(att.Id));
                        LParentObj.add(tempParent);
                    }
                } else {
                    String errorText = '';
                    for (Row r : LInputRow) {
                        if (r.hasErrors) {
                            for (String errorMsg : r.errorMsgs) {
                                if (errorText != '') errorText += '\n';
                                errorText += 'Row' + String.valueOf(r.rowNumber) + ': ' + errorMsg;
                            }
                        }
                    }
                    if (errorText != '')
                        resultTexts.put(att.Id, resultTexts.get(att.Id) + '\n' + errorText);
                    LAttUpdate.add(att);
                    SObject tempParent = ParentObjType.newSObject();
                    tempParent.put('id', att.ParentId);
                    tempParent.put(ParentObjectUploadMsg, resultTexts.get(att.Id).length() > 32000? resultTexts.get(att.Id).substring(0, 32000) : resultTexts.get(att.Id));
                    LParentObj.add(tempParent);
                    //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));
                }


            }
            System.debug(LAttUpdate);
            if (LAttUpdate != null && LAttUpdate.size() > 0) {

                for (Attachment att1 : LAttUpdate) {
                    att1.Description = resultTexts.get(att.Id).length() > 500? resultTexts.get(att.Id).substring(0, 500) : resultTexts.get(att.Id);
                }

                update LAttUpdate;
            }
            if (LParentObj != null && LParentObj.size() > 0) {
                update LParentObj;
            }
            List<Messaging.Email> LEmails = new List<Messaging.Email>();
            for (Attachment att1 : LAttUpdate) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String resultText = resultTexts.get(att1.Id);
                String resultTextHtml = resultText.replace('\n', '<br/>');
                String URLDownload = Url.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.Id;
                mail.setHtmlBody('Your mass upload submission was processed.<br/>' + resultTextHtml + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>Download Uploaded csv: <a href=\"' + URLDownload + '\">' + URLDownload + '</a>');
                mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded csv: ' + URLDownload);
                mail.setToAddresses(new List<String>{
                    att1.Owner.Email
                });
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Mass Upload Process');
                mail.setSubject('Mass Upload Process is Completed');
                LEmails.add(mail);
            }
            if (LEmails.size() > 0 && emailNotification) {
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(LEmails);
                }
            }

        }

    }

    global void finish(Database.BatchableContext BC) {
        System.debug(removeAttachmentAfterUpload);
        System.debug(AttID);
        if (removeAttachmentAfterUpload != null && removeAttachmentAfterUpload) {
            delete [select Id from Attachment where Id = :AttID];
        }

        //Add by Keith Yip For Promotion PO
        if (ObjAPIName == 'ASI_CRM_CN_Covered_Outlet__c' && fields.contains('ASI_CRM_CN_Est_Visibility_Amt__c') && parentID != null) {
            List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletList = [select Id from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c = :parentID and ASI_CRM_CN_Outlet__r.RecordType.DeveloperName = 'ASI_CRM_Outlet_CN'];
            ASI_TH_CRM_Contract__c thisCC = [select Id, ASI_CRM_CN_PO_Version__c from ASI_TH_CRM_Contract__c where Id = :parentID limit 1];
            if(coveredOutletList.size() > ASI_CRM_CN_PromotionContractUtilClass.outletThreshold() && thisCC.ASI_CRM_CN_PO_Version__c != '0.0'){
                Database.executeBatch(new ASI_CRM_CN_PromoVolumeAggregationJob(true, new Set<Id>{
                        parentID
                }));
            }
        }
    }

    public void init() {
        /*if(inlineVF){
            currentPageUrlOutput = currentPageUrl;
        }
        else*/
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        LFieldAPIName = fields.toLowerCase().split(',', 0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',', 0);
        if ([select Id from RecordType where Name = :recordtypeName and SobjectType = :ObjAPIName].size() > 0) {
            recordtypid = [select Id from RecordType where Name = :recordtypeName and SobjectType = :ObjAPIName].Id;
        }
        MAPINameLabel = new Map<String, String>();
        for (Integer i = 0; i < LFieldAPIName.size(); i++) {
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(), LFieldLabel[i].toLowerCase().trim());
        }
        MRecTypeID = new Map<String, Id>();
        for (RecordType r : [Select Id, Name, SobjectType from RecordType]) {
            String key = r.SobjectType + r.Name;
            key = key.toLowerCase();
            MRecTypeID.put(key, r.Id);
        }
        System.debug('MRecTypeID' + MRecTypeID);
        hasError = false;
        msg = '';
        //MRecTypeDefault = new Map<string,string>();
        LDefaultVales = new List<String>();
        LDefaultValesHeader = new List<String>();
        if (defaultValues != null && defaultValues != '') {
            List<String> LDefaultValuePair = defaultValues.split(';', 0);
            for (String s : LDefaultValuePair) {
                List<String> l = s.split(':', 0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
            //MRecTypeDefault.put()
        }

        if (String.isEmpty(encoding)) {
            encoding = 'GB2312';
        }
    }

    private List<String> addDefaultValues(List<String> ls, Boolean isHeader) {
        if (isHeader)
            ls.addAll(LDefaultValesHeader); else
            ls.addAll(LDefaultVales);
        return ls;
    }

    private Id matchLookupField(Integer pos, List<String> ls, Map<String, Integer> mfpos, Map<String, Id> MRecTypeID) {
        String key = '';
        System.debug('LLookupField[pos] ' + LLookupField[pos]);
        System.debug('MFieldLabelKeyFilter ' + LLookupField[pos].MFieldLabelKeyFilter);
        for (String label : LLookupField[pos].MFieldLabelKeyFilter.keySet()) {
            if (mfpos.containsKey(label.toLowerCase())) {
                if (label.contains('recordtype')) {
                    String tempKey = LLookupField[pos].objectName.toLowerCase() + ls[mfpos.get(label)].toLowerCase();
                    if (MRecTypeID.containsKey(tempKey)) {
                        key += String.valueOf(MRecTypeID.get(tempKey)).toLowerCase();
                    }
                } else {
                    key += ls[mfpos.get(label)].toLowerCase().trim();
                }
            }
        }

        return LLookupField[pos].genid(key);
    }
    public static String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for (Integer i = 0; i < bytesCount; ++i)
            bytes[i] = hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
    private List<List<String>> genResults(Blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null) {
            //String fileString = contentFile.toString().toLowerCase();
            //Modify by Steve 20140617
            //String fileString = contentFile.toString();
            System.debug('encoding ' + encoding);
            String fileString = blobToString(contentFile, encoding);
            System.debug(fileString);

            parsedCSV = parseCSV(fileString, false);
            rowCount = parsedCSV.size();
            for (List<String> row : parsedCSV) {
                if (row.size() > colCount) {
                    colCount = row.size();
                }
            }
            // fill in empty value to make sure col size is the same for each row
            for (List<String> row : parsedCSV) {
                while (row.size() < colCount) {
                    row.add('');
                }
            }
        }
        return parsedCSV;
    }


    /*
    Credit to
    http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
    */
    private static List<List<String>> parseCSV(String contents, Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""', ',"DBLQT').replaceAll('""",', 'DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote

        contents = contents.replaceAll('""', 'DBLQT');
        contents = contents.replaceAll('\r\n', '\r');
        contents = contents.replaceAll('\n', '\r');
        // Remove BOM (Byte order mark) in UTF-8
        contents = contents.replaceAll('\ufeff', '');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            //lines = contents.split('\n'); //correction: this only accomodates windows files
            lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for (String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',', '').trim().length() == 0) break;

            List<String> fields = line.split(',');
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for (String field : fields) {

                if (field.startsWith('"') && field.endsWith('"') && field.length() > 1) {
                    cleanFields.add(field.replaceAll('"', '').replaceAll('DBLQT', '"'));
                } else if (field.startsWith('"') && !makeCompositeField) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"') && makeCompositeField) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('"', '').replaceAll('DBLQT', '"'));
                    makeCompositeField = false;
                    System.debug('composite field2:' + compositeField.replaceAll('"', '').replaceAll('DBLQT', '"'));
                } else if (makeCompositeField) {
                    compositeField += ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('"', '').replaceAll('DBLQT', '"'));
                }
            }
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }


    // class for storing lookup field name and corresponding key fields
    public class lookupRecord {
        public String Field { set; get; } //lookup field name
        public String objectName { set; get; } //object of lookup field point to
        public Map<String, String> MFieldLabel { set; get; } //Map for header name & field api name
        private String soql { set; get; }
        public List<Set<String>> LkeyFilter; //key field values for searching records by soql
        public Map<String, Integer> MFieldLabelKeyFilter; //map for key field to access corresponding set of values for filter in LkeyFilter
        public Map<String, Id> MResult;
        public lookupRecord(String input) {
            soql = '';
            LkeyFilter = new List<Set<String>>();
            MFieldLabelKeyFilter = new Map<String, Integer>();
            MFieldLabel = new Map<String, String>();
            List<String> temp = input.split(':', 0);
            if (temp.size() > 1) {
                List<String> objectinfo = temp[0].split('/', 0);
                objectName = objectinfo[0].trim();
                Field = objectinfo[1].trim().toLowerCase();
                for (String s : temp[1].split(',', 0)) {
                    temp = s.split('&', 0);
                    if (temp.size() > 1) {
                        MFieldLabel.put(temp[0].trim().toLowerCase(), temp[1].trim().toLowerCase());
                        LkeyFilter.add(new Set<String>());
                        MFieldLabelKeyFilter.put(temp[0].trim().toLowerCase(), LkeyFilter.size() - 1);
                    }
                }
            }
        }
        public void addKey(List<String> ls, Map<String, Integer> Mpos1, Map<String, Id> MRecTypeID) {
            for (String label : MFieldLabel.keySet()) {
                if (Mpos1.containsKey(label)) {
                    //handle recordtype id in lookup field component
                    if (label.contains('recordtype')) {
                        String key = objectName + ls[Mpos1.get(label)].trim();
                        key = key.toLowerCase();

                        if (MRecTypeID.containsKey(key)) {
                            LkeyFilter[MFieldLabelKeyFilter.get(label)].add(MRecTypeID.get(key));
                        }
                    } else {
                        LkeyFilter[MFieldLabelKeyFilter.get(label)].add(ls[Mpos1.get(label)].trim());
                    }
                }
            }
        }

        public void queryResult() {

            soql = 'Select id ';
            for (String label : MFieldLabel.keySet()) {
                soql += ',' + MFieldLabel.get(label);
            }
            soql += ' from ' + objectName;
            if (MFieldLabel.keySet().size() > 0) {
                soql += ' where id != null ';
            }
            Set<String> setFilter1;
            Set<String> setFilter2;
            Set<String> setFilter3;
            Set<String> setFilter4;
            for (String label : MFieldLabel.keySet()) {
                //soql += ' and ' + MFieldLabel.get(label) + ' IN :LkeyFilter[MFieldLabelKeyFilter.get(label)]';
                soql += ' and (';
                for (String s : LkeyFilter[MFieldLabelKeyFilter.get(label)]) {
                    soql += MFieldLabel.get(label) + ' = \'' + s.replace('\'', '\\\'') + '\'  or ';
                }
                soql = soql.substring(0, soql.length() - 5);
                if (LkeyFilter[MFieldLabelKeyFilter.get(label)].size() > 0)
                    soql += ' ) ';

            }
            System.debug('soql: ' + soql);
            if (Test.isRunningTest()) {
                soql += ' limit 1';
            }
            List<SObject> LResult = Database.query(soql);
            System.debug('LResult SOQL Result: ' + LResult);
            if (LResult != null && LResult.size() > 0) {
                MResult = new Map<String, Id>();
                for (SObject s : LResult) {
                    String key = '';
                    for (String label : MFieldLabel.keySet()) {
                        key += s.get(MFieldLabel.get(label));
                    }
                    MResult.put(key.toLowerCase(), s.Id);
                }
                System.debug('Map of SOQL Result: ' + MResult);
            }
        }
        public Id genid(String inputKey) {
            inputKey = inputKey.trim();
            if (MResult != null && String.isNotEmpty(inputKey)) {
                return MResult.get(inputKey);

            }

            return null;
        }
    }


    public class Row {
        public Integer rowNumber { set; get; }
        public SObject sObj { set; get; }

        private List<String> m_errorMsgs = new List<String>();
        public List<String> errorMsgs { get {return m_errorMsgs;} }
        public Boolean hasErrors { get {return errorMsgs.size() > 0;} }

        // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        public row(SObject obj) {
            sObj = obj;
        }
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null

        public row(SObject obj, String parentField, String parentID) {
            sObj = obj;
            sObj.put(parentField, parentID);
        }
        public void addError(String errMsg) {
            errorMsgs.add(errMsg);
        }
    }
    /*public static decimal currencySpliter(string testString){
      list<string>part=new list<string>();
      string sresult;
      decimal result;
      if(testString.length()==4){
         part.add(testString.substring(0,1));
           part.add(testString.substring(2,4));
          sresult=part[0]+'.'+part[1];
          result=decimal.valueof(sresult);
      }
        if(testString.length()==5){
         part.add(testString.substring(0,2));
           part.add(testString.substring(3,5));
          sresult=part[0]+'.'+part[1];
          result=decimal.valueof(sresult);
      }
        if(testString.length()==6){
         part.add(testString.substring(0,3));
           part.add(testString.substring(4,6));
          sresult=part[0]+'.'+part[1];
          result=decimal.valueof(sresult);
      }
      else if(testString.length()==8){
           part.add(testString.substring(0,1));
         part.add(testString.substring(2,5));
          part.add(testString.substring(6,8));
          sresult=part[0]+part[1]+'.'+part[2];
          result=decimal.valueof(sresult);
      }
      else if(testString.length()==9){
           part.add(testString.substring(0,2));
         part.add(testString.substring(3,6));
          part.add(testString.substring(7,9));
          sresult=part[0]+part[1]+'.'+part[2];
          result=decimal.valueof(sresult);
      }
      else if(testString.length()==10){
           part.add(testString.substring(0,3));
         part.add(testString.substring(4,7));
          part.add(testString.substring(8,10));
          sresult=part[0]+part[1]+'.'+part[2];
          result=decimal.valueof(sresult);
      }
       else if(testString.length()==12){
           part.add(testString.substring(0,1));
         part.add(testString.substring(2,5));
          part.add(testString.substring(6,9));
          part.add(testString.substring(10,12));
          sresult=part[0]+part[1]+part[2]+'.'+part[3];
          result=decimal.valueof(sresult);
      }
      return result;
  }*///added by steve on 12/28/2015. To handle currency formatt,e.g. $1,450.00, the range is from $0.00 up to $9,999,999,99.
    public static Date dateSpliter(String dateText) {
        String test = dateText.substring(0, 2);
        Integer year;
        Integer day;
        Integer month;
        if (dateText.length() == 10) {
            year = Integer.valueOf(dateText.substring(6, 10));
            day = Integer.valueOf(dateText.substring(3, 5));
            month = Integer.valueOf(dateText.substring(0, 2));
        } else if (dateText.length() == 9) {
            if (test.contains('/')) {
                year = Integer.valueOf(dateText.substring(5, 9));
                day = Integer.valueOf(dateText.substring(2, 4));
                month = Integer.valueOf(dateText.substring(0, 1));

            } else {
                year = Integer.valueOf(dateText.substring(5, 9));
                day = Integer.valueOf(dateText.substring(3, 4));
                month = Integer.valueOf(dateText.substring(0, 2));

            }
        } else if (dateText.length() == 8) {
            if (test.contains('/')) {
                year = Integer.valueOf(dateText.substring(4, 8));
                day = Integer.valueOf(dateText.substring(2, 3));
                month = Integer.valueOf(dateText.substring(0, 1));
            }
        }
        Date result = Date.newInstance(year, month, day);
        return result;

    }//Added by steve on 12/28/2015. Handle different formatting issues, e.g. MM/DD/YYYY 
}