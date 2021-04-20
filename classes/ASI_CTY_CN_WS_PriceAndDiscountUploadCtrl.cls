public without sharing class ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl {
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    
    public string Msg {set;get;}
    
    public Blob contentFile {set;get;}
    
    public list<Row> LErrorRows {set;get;} 
    public list<Row> LSuccessRows {set;get;} 
    private map<string,integer> MFieldPos;
    public boolean hasError {set;get;}
    public string msgEmail {set;get;}
    private id recordtypid;
    
    private Integer rowCount;
    private Integer colCount;
    
    // public Id BatchId {get;set;}
    // public Id AttId {get;set;}
   
   
    public ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl(){
        msgEmail = Label.ASI_CTY_CN_WS_Discount_Upload_Result_Msg;
        hasError = false;
    }
    
    // Non Batch mode with case-sensitive lookup
    public void uploadCSV(){
        if(fileSize <= 1400000){
            msg = '';
            LErrorRows = new list<Row>();
            LSuccessRows = new list<Row>();
            Map<Integer, Row> errorMap= new Map<Integer, Row>();
            Map<Integer, Row> successMap= new Map<Integer, Row>();
            if(namefile.toLowerCase().right(3)=='csv'){
                list<list<String>> parsedCSV = genResults();
                list<String> LHeader = new list<String>();
                Set<String> customerNames = new Set<String>();
                Set<String> itemGroups = new Set<String>();
                Set<String> getXCodes = new Set<String>();
                Set<String> discountCodes = new Set<String>();
                if(parsedCSV != null && parsedCSV.size()>0){
                    System.debug(LoggingLevel.INFO, '*** parsedCSV: ' + parsedCSV);
                    // retrieve header of csv
                    LHeader = parsedCSV[0];
                    integer i = 0;
                    MFieldPos = new map<string,integer>();
                    for(string h : LHeader){
                        MFieldPos.put(h.toLowerCase().trim(),i);
                        i++;
                    }
                    parsedCSV.remove(0);
                    Decimal taxRate = ASI_CTY_CN_WS_Utils.getCNTaxRate();
                    integer line = 2;
                    for(List<String> LS : parsedCSV){

                        //customer is required
                        if (String.isBlank(LS.get(MFieldPos.get('Customer CRM Code'.toLowerCase().trim())))) {
                            errorMap.put(line, new Row(line, String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Result_Required, new String[] {'Customer CRM Code'})));
                            continue;
                        }
                        customerNames.add(LS.get(MFieldPos.get('Customer CRM Code'.toLowerCase().trim())).trim());

                        //item group is required
                        if (String.isBlank(LS.get(MFieldPos.get('item group code'.toLowerCase().trim())))) {
                            errorMap.put(line, new Row(line, String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Result_Required, new String[] {'Item Group Code'})));
                            continue;
                        }
                        itemGroups.add(LS.get(MFieldPos.get('item group code'.toLowerCase().trim())).trim());

                        //record type is required
                        if (String.isBlank(LS.get(MFieldPos.get('Record Type'.toLowerCase().trim())))) {
                            errorMap.put(line, new Row(line, String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Result_Required, new String[] {'Record Type'})));
                            continue;
                        }

                        //promotion type is required
                        if (String.isBlank(LS.get(MFieldPos.get('Promotion Type'.toLowerCase().trim())))) {
                            errorMap.put(line, new Row(line, String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Result_Required, new String[] {'Promotion Type'})));
                            continue;
                        }

                        //effective date is required
                        String effFrom = LS.get(MFieldPos.get('Effective From'.toLowerCase().trim())).trim();
                        String effTo = LS.get(MFieldPos.get('Effective To'.toLowerCase().trim())).trim();
                        if (String.isBlank(effFrom) || String.isBlank(effTo)) {
                            errorMap.put(line, new Row(line, String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Result_Required, new String[] {'Effective From and Effective To'})));
                            continue;
                        }

                        sObject sobj = new ASI_CRM_Price_And_Discount_Detail__c();
                        sObject parentsObj = new ASI_CRM_Price_And_Discount__c();
                        String recordType = LS.get(MFieldPos.get('Record Type'.toLowerCase().trim())).toLowerCase();
                        Boolean isNewDiscount = recordType.contains('trade a&p') || recordType.contains('normal') || recordType.contains('a&d');
                        String discountValue = LS.get(MFieldPos.get('Discount Value'.toLowerCase().trim()));
                        String promotionType = LS.get(MFieldPos.get('Promotion Type'.toLowerCase().trim())).toLowerCase();
                        if (isNewDiscount) {
                            if (String.isBlank(discountValue)) {
                                errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg1));
                                continue;
                            }
                            if (promotionType.contains('discount')){
                                if ((Decimal.valueOf(discountValue) <=0 || Decimal.valueOf(discountValue) >= 100)) {
                                    errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg2));
                                    continue;
                                }
                                sobj.put('ASI_CTY_CN_WS_Value_Type__c', ASI_CTY_CN_WS_Utils.VALUE_TYPE_PERCENT);
                            } else {
                                sobj.put('ASI_CTY_CN_WS_Value_Type__c', ASI_CTY_CN_WS_Utils.VALUE_TYPE_AMOUNT);
                            }
                            sobj.put('ASI_CTY_CN_WS_Disount_Value__c', String.isNotBlank(discountValue) ? Decimal.valueOf(discountValue) : null);
                        } else {
                            if (promotionType.contains('buy x get y')) {
                                if (String.isBlank(LS.get(MFieldPos.get('BUY X'.toLowerCase().trim()))) || String.isBlank(LS.get(MFieldPos.get('GET Y'.toLowerCase().trim())))) {
                                    errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg3));
                                    continue;
                                }
                                getXCodes.add('B'+ LS.get(MFieldPos.get('BUY X'.toLowerCase().trim())) + 'G' + LS.get(MFieldPos.get('GET Y'.toLowerCase().trim())));
                            } else {
                                if (String.isBlank(discountValue)) {
                                    errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg4));
                                    continue;
                                }
                                discountCodes.add(discountValue);
                            }
                        }
                        
                        Date effFromDate;
                        Date effToDate;
                        try {
                            effFromDate = Date.valueOf(effFrom);
                            effToDate = Date.valueOf(effTo);
                        }catch(Exception e1){
                            try{
                                effFromDate = Date.parse(effFrom);
                                effToDate = Date.parse(effTo);
                            }catch(Exception e2){
                                errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_DateFromat));
                                continue;
                            }
                        }
                        
                        if (effToDate < effFromDate) {
                            errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg5));
                            continue;
                        }

                        if (effToDate < Date.today()) {
                            errorMap.put(line, new Row(line, Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Msg6));
                            continue;
                        }

                        parentsObj.put('ASI_CRM_Effective_From__c', effFromDate);
                        parentsObj.put('ASI_CRM_Effective_To__c', effToDate);
                        
                        if (isNewDiscount) {
                            parentsObj.put('ASI_CRM_Status__c', ASI_CTY_CN_WS_Utils.PRICE_AND_DISCOUNT_STATUS_APPROVED);
                            parentsObj.put('ASI_CRM_Approved_Date__c', Datetime.now());
                        } else {
                            parentsObj.put('ASI_CRM_Status__c', ASI_CTY_CN_WS_Utils.PRICE_AND_DISCOUNT_STATUS_OPEN);
                        }
                        parentsObj.put('ASI_CTY_CN_WS_Is_Import__c', true);
                        parentsObj.put('ASI_CRM_Remark__c', namefile);
                        String newPrice = LS.get(MFieldPos.get('New Price'.toLowerCase().trim()));
                        sobj.put('ASI_CRM_New_Price_BT_with_VAT__c', String.isNotBlank(newPrice) ? Decimal.valueOf(newPrice) : null);
                        sobj.put('ASI_CRM_Total_Estimated_Vol_BT__c', 1);


                        successMap.put(line, new Row(line, parentsObj, sobj));

                        line++;
                    }
                    List<SObject> customerList = new List<SObject>();
                    if (successMap.size() > 0) {
                        Map<String, SObject> customerMap = lookUpQueryObject(customerNames, 'ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Region__c, RecordType.Name, RecordType.DeveloperName', 'ASI_CRM_CN_CRM_Code__c');
                        Map<String, Id> itemGroupMap = lookUpQueryId(itemGroups, 'ASI_MFM_Item_Group__c', 'ASI_MFM_Item_Group_Code__c', 'ASI_CRM_CN_CRM_Item_Group');
                        Map<String, Id> getXCodeMap = lookUpQueryId(getXCodes, 'ASI_CRM_Promotion_Master__c', 'Name', 'ASI_CRM_CN_Promotion_Master');
                        Map<String, Id> discountCodeMap = lookUpQueryId(discountCodes, 'ASI_CRM_Promotion_Master__c', 'ASI_CRM_Discount__c', null);
                        Map<String, Id> recordtypeMap = queryRecordType('ASI_CRM_Price_And_Discount__c', 'Customer_Price_and_Discount_Request');
                        Map<String, Id> customerPMMap = queryPromotionMaster(customerMap);

                        integer key = 2;
                        for (List<String> LS : parsedCSV){
                            if (errorMap.containsKey(key)) {
                                LErrorRows.add(errorMap.get(key));
                                continue;
                            }
                            Row r = successMap.get(key);
                            String custmerCode = LS.get(MFieldPos.get('Customer CRM Code'.toLowerCase().trim())).trim();
                            if (!customerMap.containsKey(custmerCode)) {
                                r.addError(String.format(Label.ASI_CTY_CN_WS_Discount_Upload_LookUp_Error, new String[] {'customer'}));
                                LErrorRows.add(r);
                                successMap.remove(key);
                                continue;
                            } else {
                                r.customerId = customerMap.get(custmerCode).id;
                                r.parentsObj.put('ASI_CRM_Customer__c', r.customerId);
                                if (!LS.get(MFieldPos.get('Record Type'.toLowerCase().trim())).toLowerCase().contains('price')) {
                                    customerList.add(customerMap.get(custmerCode));
                                }
                            }

                            String itemGroupCode = LS.get(MFieldPos.get('item group code'.toLowerCase().trim()));
                            if (!itemGroupMap.containsKey(itemGroupCode)) {
                                r.addError(String.format(Label.ASI_CTY_CN_WS_Discount_Upload_LookUp_Error, new String[] {'item group'}));
                                LErrorRows.add(r);
                                successMap.remove(key);
                                continue;
                            } else {
                                r.itemGroupId = itemGroupMap.get(itemGroupCode);
                                r.sObj.put('ASI_CRM_Item_Group_Description__c', r.itemGroupId);
                            }

                            string recordName = LS.get(MFieldPos.get('Record Type'.toLowerCase().trim())).toLowerCase();
                            Boolean isNewDiscount = recordName.contains('trade a&p') || recordName.contains('normal') || recordName.contains('a&d');
                            if (!isNewDiscount) {
                                if (LS.get(MFieldPos.get('Promotion Type'.toLowerCase().trim())).toLowerCase().contains('buy x get y')) {
                                    String code = 'B'+ LS.get(MFieldPos.get('BUY X'.toLowerCase().trim())) + 'G' + LS.get(MFieldPos.get('GET Y'.toLowerCase().trim()));
                                    if (!getXCodeMap.containsKey(code)) {
                                        r.addError(String.format(Label.ASI_CTY_CN_WS_Discount_Upload_LookUp_Error, new String[] {'promotion master : ' + code}));
                                        LErrorRows.add(r);
                                        successMap.remove(key);
                                        continue;
                                    } else {
                                        r.promoterMaseterId = getXCodeMap.get(code);
                                        r.sObj.put('ASI_CRM_Promotion_Code__c', r.promoterMaseterId);
                                    }
                                } else  {
                                    String discountValue = LS.get(MFieldPos.get('Discount Value'.toLowerCase().trim()));
                                    if (!discountCodeMap.containsKey(discountValue)) {
                                        r.addError(String.format(Label.ASI_CTY_CN_WS_Discount_Upload_LookUp_Error, new String[] {'promotion master with a discount value of : ' + discountValue}));
                                        LErrorRows.add(r);
                                        successMap.remove(key);
                                        continue;
                                    } else {
                                        r.promoterMaseterId = discountCodeMap.get(discountValue);
                                        r.sObj.put('ASI_CRM_Promotion_Code__c', r.promoterMaseterId);
                                    }
                                }
                            } else {
                                if (!customerPMMap.containsKey(custmerCode)) {
                                    r.addError(String.format(Label.ASI_CTY_CN_WS_Discount_Upload_LookUp_Error, new String[] {'promotion master that matched the customer\'s crm code' + custmerCode}));
                                    LErrorRows.add(r);
                                    successMap.remove(key);
                                    continue;
                                } else {
                                    r.promoterMaseterId = customerPMMap.get(custmerCode);
                                    r.sObj.put('ASI_CTY_CN_WS_Level1_Promotion_Code__c', r.promoterMaseterId);
                                }
                            }

                            Id recordId;
                            if (isNewDiscount) {
                                 for (String k : recordtypeMap.keySet()) {
                                    if (k.toLowerCase().contains('trade') && recordName.contains('trade')) {
                                        recordId = recordtypeMap.get(k);
                                    } else if (k.toLowerCase().contains('normal') && recordName.contains('normal')) {
                                        recordId = recordtypeMap.get(k);
                                    }else if (k.toLowerCase().contains('a_d') && recordName.contains('a&d')) {
                                        recordId = recordtypeMap.get(k);
                                    }
                                    if (recordId != null) {
                                        break;
                                    }
                                 }
                            } else {
                                recordId = recordtypeMap.get(ASI_CTY_CN_WS_Utils.PRICE_AND_DISCOUNT_RECORDTYPE_PD);
                            }
                            
                            if (recordId != null){
                                r.recordTypeId = recordId;
                                r.parentsObj.put('RecordTypeId', r.recordTypeId);
                            } else {
                                r.addError(Label.ASI_CTY_CN_WS_Discount_Upload_Validate_RecordType);
                                LErrorRows.add(r);
                                successMap.remove(key);
                                continue;
                            }

                            LSuccessRows.add(r);
                            key++;
                        }
                    } else {
                        integer key = 2;
                        for (List<String> LS : parsedCSV){
                            if (errorMap.containsKey(key)) {
                                LErrorRows.add(errorMap.get(key));
                            }
                        }
                    }
                    if (LErrorRows.size() > 0) {
                        hasError = true;
                    }
                    list<sObject> parentInsert = new list<sobject>();
                    list<sObject> childInsert = new list<sobject>();
                    map<string, list<sObject>> customerRecord = new map<string, list<sObject>>();
                    for(Row r : LSuccessRows){
                        if(r.errorMsg == '' && !customerRecord.containsKey(r.customerId + '' + r.recordTypeId)){
                            parentInsert.add(r.parentsObj);
                            customerRecord.put(r.customerId + '' + r.recordTypeId, new list<sObject>());
                        }
                        customerRecord.get(r.customerId + '' + r.recordTypeId).add(r.sObj);
                    }
                    if(parentInsert != null && parentInsert.size()>0){
                        try{
                            insert parentInsert;
                            msg = String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Sucess_Pd, new String[] {string.valueof(parentInsert.size())});
                            for (sObject parentObj : parentInsert) {
                                list<sObject> childs = customerRecord.get(parentObj.get('ASI_CRM_Customer__c') + '' + parentObj.get('RecordTypeId'));
                                for (sObject sobj : childs) {
                                    sobj.put('ASI_CRM_Price_And_Discount__c', parentObj.id);
                                    childInsert.add(sobj);
                                }
                            }
                            if (childInsert.size() > 0) {
                                insert childInsert;
                                msg += String.format(Label.ASI_CTY_CN_WS_Discount_Upload_Sucess_Pd_Detail, new String[] {string.valueof(childInsert.size())});
                            }
                            refreshPage();
                        }
                        catch(exception e){
                            hasError = true;
                            for(integer j =0;j<e.getNumDml();j++){
                                LSuccessRows[j].addError(e.getDmlMessage(j));
                                LErrorRows.add(LSuccessRows[j]);
                            }
                            msg = null;
                        }
                    }
                }
            }
            else{
                msg = Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Csv_File;
            }
        }
        else{
            msg = Label.ASI_CTY_CN_WS_Discount_Upload_Validate_Large_File;
        }
    }
    
    public pageReference refreshPage(){
        hasError = false;
        return ApexPages.currentPage();
    }
    
    private List<List<String>> genResults() {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null){
            String fileString = contentFile.toString();
            parsedCSV = parseCSV(fileString, false);
            rowCount = parsedCSV.size();
            System.debug(LoggingLevel.INFO, '*** rowCount: ' + rowCount);
            for (List<String> row : parsedCSV){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }
            // fill in empty value to make sure col size is the same for each row
            for (list<string> row : parsedCSV){
                while(row.size()<colCount){
                    row.add('');
                }
            }
        }
        return parsedCSV;
    }

    public map<string, id> lookUpQueryId(Set<String> querys, String sobjName, String fieldName, String recordType) {
        map<string, id> result = new map<string,id>();
        if (querys == null || querys.size() == 0) {
            return result;
        }
        String soql = 'Select id, ' + fieldName + ' from ' + sobjName  + ' where id != null '+
                    ' and ' + fieldName + ' IN (\'' + String.join(new List<String>(querys), '\',\'') + '\') ';
        if (String.isNotBlank(recordType)) {
            soql += ' and RecordType.DeveloperName = \'' + recordType + '\'';
        }
        System.debug(LoggingLevel.INFO, '*** soql: ' + soql);
        list<sObject> LResult = database.query(soql);
        for (sObject s : LResult) {
            result.put(string.valueOf(s.get(fieldName)), s.id);
        }
        return result;
    }

    public map<string, sObject> lookUpQueryObject(Set<String> querys, String sobjName, String queryFields, String fieldName) {
        map<string, sObject> result = new map<string,sObject>();
        if (querys == null || querys.size() == 0) {
            return result;
        }
        String soql = 'Select id, ' + queryFields + ' from ' + sobjName  + ' where id != null ' + 
                      ' and ' + fieldName + ' IN (\'' + String.join(new List<String>(querys), '\',\'') + '\') ';
        list<sObject> LResult = database.query(soql);
        for (sObject s : LResult) {
            result.put(string.valueOf(s.get(fieldName)), s);
        }
        return result;
    }

    private map<string, id> queryRecordType(String objName, String queryFiler){
        map<string, id> result = new map<string,id>();
        for (RecordType r: [select Id, DeveloperName from RecordType 
                            where SobjectType = :objName 
                              and DeveloperName like :('%' + queryFiler + '%')]){
            if (!r.DeveloperName.contains('RO')) {
                result.put(r.DeveloperName, r.Id);
            }
        }
        return result;
    }

    private map<string, id> queryPromotionMaster(Map<String, SObject> customerMap){
        map<string, id> result = new map<string,id>();
        if (customerMap == null || customerMap.size() == 0) {
            return result;
        }
        map<string, id> pmMap = new map<string, id>();
        for (ASI_CRM_Promotion_Master__c pm: [select Id, ASI_CTY_CN_WS_Channel__c, ASI_CTY_CN_WS_Commercial_Team__c, 
                                                     ASI_CTY_CN_WS_Region__r.Name,ASI_CTY_CN_WS_Customer_Type__c  
                                                from ASI_CRM_Promotion_Master__c 
                                               where RecordType.DeveloperName = 'ASI_CTY_WS_CN_Promotion_Master_Hierarchy']){
            pmMap.put(pm.ASI_CTY_CN_WS_Channel__c + pm.ASI_CTY_CN_WS_Commercial_Team__c + pm.ASI_CTY_CN_WS_Region__r.Name + pm.ASI_CTY_CN_WS_Customer_Type__c, pm.Id);
        }
        for (string code : customerMap.keySet()) {
            ASI_CRM_AccountsAdditionalField__c customer = (ASI_CRM_AccountsAdditionalField__c) customerMap.get(code);
            String customerType = '';
            if (customer.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS)) {
                customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS ;
            } else if (customer.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET)) {
                customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET ;
            } else {
                continue;
            }
            if (!pmMap.isEmpty() && pmMap.containsKey(customer.ASI_CRM_CN_NewChannel__c + customer.ASI_CRM_CN_Commercial_Team__c + customer.ASI_CRM_CN_Region__c + customerType)) {
                result.put(code, pmMap.get(customer.ASI_CRM_CN_NewChannel__c + customer.ASI_CRM_CN_Commercial_Team__c + customer.ASI_CRM_CN_Region__c + customerType));
            }
        }
        return result;
    }

    
    /* 
    Credit to 
    http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
    */
    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        
        contents = contents.replaceAll('""','DBLQT');
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
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                
                if (field.startsWith('"') && field.endsWith('"') && field.length()>1) {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')  && !makeCompositeField) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"') && makeCompositeField) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
    
    public class Row{
        public Integer rowNumber {set;get;}
        public Id customerId {set;get;}
        public Id itemGroupId {set;get;}
        public Id promoterMaseterId {set;get;}
        public Id priceDiscountId {set;get;}
        public Id recordTypeId {set;get;}
        public sObject parentsObj {set;get;}
        public sObject sObj {set;get;}
        public string errorMsg {set;get;}
        
        public row(Integer rowNumber, sObject parentsObj, sObject obj){
            this.rowNumber = rowNumber;
            this.parentsObj = parentsObj;
            this.sObj = obj;
            this.errorMsg = '';
        }

        public row(Integer rowNumber, string errorMsg){
            this.rowNumber = rowNumber;
            this.errorMsg = errorMsg;
        }
        
        public void addError(string errMsg){
            errorMsg = errMsg;
        }
    }
}