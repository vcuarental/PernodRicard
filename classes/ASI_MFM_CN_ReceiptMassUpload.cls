global class ASI_MFM_CN_ReceiptMassUpload implements Database.Batchable<sObject>{
    
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
    global final string recEXID {set;get;}
    global final string recEXIDcol {set;get;} 
    global final string parentObjectAPIName {set;get;}
    global final string ParentObjectUploadMsg {set;get;}
    global final boolean upsertMode {set;get;}
    global final boolean batchMode {set;get;}
    global final boolean opt_allOrNone {set;get;}
    global final boolean emailNotification {set;get;}
    global List<Attachment> LAttUpdate;
    
    public string currentPageURLOutput {set;get;}
    private Schema.SObjectType ObjType;
    private Schema.SObjectType ParentObjType;
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private list<Row> LInputRow;
    public list<Row> LErrorRows {set;get;} 
    private list<lookupRecord> LLookupField;
    private map<string,integer> MFieldPos;
    private map<string,integer> MLookupFieldPos;
    private map<string,id> MRecTypeID; 
    public boolean hasError {set;get;}
    public string msg {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    private list<string> LEXIDFieldLabel;
    
    private Integer rowCount;
    private Integer colCount;
    
    //20160509 Ben Elufa
    Map<String, List<ASI_MFM_PO_Line_Item__c>> mapPOLine;
    //Map<String, Boolean> isPrePaidMap;
    Map<String, String> mapPONumber;
    Map<String, Integer> mapRowByPONumber;
    Map<String, String> mapPOReceiptHeader;
    //20160509 End
    
    global ASI_MFM_CN_ReceiptMassUpload(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
                                        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
                                        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone){
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
    
    global database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([select id, name, body, description, parentid,owner.email from attachment where id =:AttID]);
    }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('LCheck:- IN->excute');
        if(scope != null){
            init();
            LAttUpdate = new List<Attachment>();
            List<sObject> LParentObj = new List<sObject>();
            map<Id, string> resultTexts = new map<Id, string>();
            mapRowByPONumber = new Map<String, Integer>();//20160510 Ben @ Elufa
            
            for(sobject sc : scope){
                Attachment att = (Attachment)sc;                
                att.description = '';
                resultTexts.put(att.Id, '');
                LErrorRows = new list<Row>();
                String namefile = att.name;
                system.debug('namefile'+namefile);
                if(namefile.toLowerCase().right(3)=='csv'){
                    list<list<String>> parsedCSV = genResults(att.body);
                    system.debug('LCheck:- parsedCSV 01'+parsedCSV);
                    list<String> LHeader = new list<String>();
                    if(parsedCSV != null && parsedCSV.size()>0){
                        // retrieve header of csv
                        LHeader = addDefaultValues(parsedCSV[0],true);                  
                        parsedCSV.remove(0);
                        system.debug(LHeader);
                        integer i = 0;
                        integer x = 1;
                        for(List<String> LS : parsedCSV){
                            LS = addDefaultValues(LS,false);
                            system.debug('check123 ' + LS[0]);
                            mapRowByPONumber.put(LS[0], x);//20160510 Ben @ Elufa
                            x++;
                        }
                        system.debug('LCheck:- parsedCSV 02'+parsedCSV);
                        MFieldPos = new map<string,integer>();
                        for(string h : LHeader){
                            system.debug('h.toLowerCase().trim() ' + h.toLowerCase().trim());
                            MFieldPos.put(h.toLowerCase().trim(),i);
                            i++;
                            system.debug('MFieldPos:- ' + MFieldPos +'-/-/-'+ h);
                        }
                        
                        LLookupField = new list<lookupRecord>();
                        MLookupFieldPos = new map<string,integer>();
                        if(lookupEXID != '' && lookupEXID != null){
                            system.debug('lookupEXID' +lookupEXID);
                            for(string s : lookupEXID.split(';',0)){
                                system.debug('input string ' + s);
                                lookupRecord tempLookupRecord = new lookupRecord(s);
                                LLookupField.add(tempLookupRecord);
                                system.debug(templookuprecord);
                                MLookupFieldPos.put(tempLookupRecord.field,LLookupField.size()-1);
                            }
                        }
                        for(lookupRecord lookupField : LLookupField){
                            for(List<String> LS : parsedCSV){
                                system.debug(LS);
                                lookupField.addKey(LS, MFieldPos,MRecTypeID);
                            }
                            lookupField.queryResult();
                        }
                        
                        //20160509 Ben @ Elufa
                        
                        //isPrePaidMap = new Map<String, Boolean>();
                        mapPOLine = new Map<String, List<ASI_MFM_PO_Line_Item__c>>();
                        mapPONumber = new Map<String, String>();
    					
                        Set<Id> poSetId = new Set<Id>();
                        
                        for(lookupRecord obj : LLookupField){
                            if(obj.MResult != NULL && obj.MResult.size() > 0)
                                poSetId.addAll(obj.MResult.values());
                        }
                        
                        for(ASI_MFM_PO_Line_Item__c obj : [SELECT id, ASI_MFM_CN_Paid_Amount__c
                                                           , ASI_MFM_PO__c
                                                           , ASI_MFM_PO__r.Name
                                                           , ASI_MFM_PO__r.ASI_MFM_PO_Amount__c
                                                           , ASI_MFM_CN_PrePaid_Amount__c
                                                           , ASI_MFM_Amount__c
                                                           FROM ASI_MFM_PO_Line_Item__c 
                                                           WHERE ASI_MFM_PO__c IN : poSetId 
                                                           AND ASI_MFM_PO__r.RecordType.DeveloperName LIKE 'ASI_MFM_CN_PO%'//20170106 Elufa
                                                           ORDER BY ASI_MFM_PO__c DESC
                                                           , ASI_MFM_CN_PaidAmount_PrePaidAmount__c DESC
                                                           , ASI_MFM_CN_PrePaid_Amount__c DESC
                                                           , ASI_MFM_Amount__c DESC
                                                           ]){
                                                               
                                                               List<ASI_MFM_PO_Line_Item__c> tmpPOLine = new List<ASI_MFM_PO_Line_Item__c>();
                                                               
                                                               mapPONumber.put(obj.ASI_MFM_PO__c, obj.ASI_MFM_PO__r.Name);
                                                               
                                                               if(mapPoLine.containsKey(obj.ASI_MFM_PO__c)){
                                                                   
                                                                   //if(isPrePaidMap.get(obj.ASI_MFM_PO__c) && ( obj.ASI_MFM_CN_PrePaid_Amount__c < obj.ASI_MFM_CN_Paid_Amount__c || obj.ASI_MFM_CN_PrePaid_Amount__c == 0 ))
                                                                       //isPrePaidMap.put(obj.ASI_MFM_PO__c, FALSE);
                                                                   
                                                                   tmpPOLine = mapPOLine.get(obj.ASI_MFM_PO__c);
                                                                   tmpPOLine.add(obj);
                                                                   mapPOLine.put(obj.ASI_MFM_PO__c, tmpPOLine);
                                                               }else{
                                                                   
                                                                   //if(obj.ASI_MFM_CN_Paid_Amount__c == obj.ASI_MFM_CN_PrePaid_Amount__c && obj.ASI_MFM_CN_PrePaid_Amount__c > 0)
                                                                       //isPrePaidMap.put(obj.ASI_MFM_PO__c, TRUE);
                                                                   //else
                                                                       //isPrePaidMap.put(obj.ASI_MFM_PO__c, FALSE);
                                                                   
                                                                   tmpPOLine.add(obj);
                                                                   mapPOLine.put(obj.ASI_MFM_PO__c, tmpPOLine);
                                                               }
                                                           }
                        
                        //20160509 End
                        
                        system.debug('LLookupField: ' + LLookupField);
                        //---------------------------------------------------------------------------------------//
                        system.debug('MFieldPos: ' + MFieldPos);
                        LInputRow = new list<Row>();
                        Integer rowNumber = 1;
                        Map<string,string> MFieldType = new map<string,string>();
                        System.debug(LFieldAPINAme);
                        System.debug(MFieldType);
                        System.debug(ObjType);
                        for(string fieldname : LFieldAPIName){
                            System.debug(fieldname);
                            MFieldType.put(fieldname,ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());
                            
                        }
                        LEXIDFieldLabel = new List<String>();
                        if(recEXID != null && recEXID != ''){
                            LEXIDFieldLabel = recEXID.split(';',0);
                        }
                        
                        for(List<String> LS : parsedCSV){
                            // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                            Row r;
                            if (parentField!= null && parentID!= null)
                                r = new row(ObjType.newSObject(), parentField, parentID);
                            else
                                r = new row(ObjType.newSObject());
                            // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                            
                            if(recordtypid != null){
                                r.sObj.put('recordtypeid',recordtypid);
                            }
                            
                            Integer inputCol = 0;
                            system.debug(LS);
                            system.debug('LFieldAPIName' + LFieldAPIName);
                            for(string fieldname : LFieldAPIName){
                                string labelname = MAPINameLabel.get(fieldname);
                                system.debug('MAPINameLabel' + MAPINameLabel);
                                system.debug('MAPINameLabel.get(fieldname)' + MAPINameLabel.get(fieldname));
                                system.debug('MFieldPos'+MFieldPos);
                                system.debug('MFieldPosLabel'+labelname+MFieldPos.containsKey(labelname));
                                system.debug('MLookupFieldPos'+MLookupFieldPos);
                                system.debug('label'+labelname+'/'+MLookupFieldPos.containsKey(fieldname));
                                
                                if(MFieldPos.containsKey(labelname) && LS[MFieldPos.get(labelname)] != null && LS[MFieldPos.get(labelname)] != ''){
                                    system.debug('Non-Lookup Field:' + fieldname);
                                    system.debug('MFieldPos'+MFieldPos);
                                    system.debug(MFieldPos.get(labelname));
                                    system.debug(ObjType);
                                    
                                    if(MLookupFieldPos.containsKey(fieldname)){
                                        system.debug('Lookup Field:' + fieldname);
                                        system.debug('MLookupFieldPos '+MLookupFieldPos);
                                        system.debug('MLookupFieldPos.get(fieldname)'+MLookupFieldPos.get(fieldname));
                                        if(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID) == null){
                                            system.debug(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                            r.addError(labelname + ': Cannot find record');
                                            hasError = true;
                                        }
                                        try{
                                            r.sObj.put(fieldname, matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                        }catch(exception e){
                                            r.addError(labelname + ': Cannot find record');
                                            hasError = true;
                                        }
                                    }else if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);
                                        system.debug('check111 ' + tempFieldType);
                                        if(tempFieldType=='boolean'){
                                            system.debug('Boolean source '+LS[MFieldPos.get(labelname)].toLowerCase());
                                            if(LS[MFieldPos.get(labelname)].toLowerCase().trim()=='y'||LS[MFieldPos.get(labelname)].trim()=='1'||LS[MFieldPos.get(labelname)].toLowerCase().trim()=='true'){
                                                try{
                                                    r.sObj.put(fieldname, true);
                                                }catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }else{
                                                try{
                                                    r.sObj.put(fieldname, false);
                                                }catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }
                                            
                                        }/*else if(tempFieldType=='date'){//for test class coverage
                                            try{
                                                string dateText = LS[MFieldPos.get(labelname)];
                                                if(dateText.contains('/')){
                                                    date tempdate=dateSpliter(dateText);
                                                    r.sObj.put(fieldname,tempdate);
                                                }else{
                                                    r.sObj.put(fieldname, date.newInstance(integer.valueOf(dateText.subString(0,4)), integer.valueOf(dateText.subString(4,6)), integer.valueOf(dateText.subString(6,8))));
                                                }
                                                
                                            }catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }*/
                                        
                                        else if(tempFieldType=='double' ||
                                                tempFieldType=='percent' ||
                                                tempFieldType=='currency'
                                               ){
                                                   try{
                                                       r.sObj.put(fieldname, decimal.valueof(LS[MFieldPos.get(labelname)]));
                                                   }
                                                   catch(exception e){
                                                       r.addError(labelname + ': ' + e.getMessage());
                                                       hasError = true;
                                                   }
                                               }
                                        else if(tempFieldType=='integer'){
                                            try{
                                                r.sObj.put(fieldname, integer.valueof(LS[MFieldPos.get(labelname)]));
                                            }
                                            catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                        else{
                                            try{
                                                r.sObj.put(fieldname, LS[MFieldPos.get(labelname)]);
                                            }
                                            catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                    }
                                }
                            }
                            r.rowNumber = rowNumber++;
                            if(r.hasErrors){
                                LErrorRows.add(r);
                            }
                            // to generate EXID column
                            String tempEXIDValue = '';
                            for(String exid : LEXIDFieldLabel){
                                exid = exid.tolowercase();
                                system.debug(exid);
                                if(MFieldPos.containsKey(exid) && LS[MFieldPos.get(exid)] != null && LS[MFieldPos.get(exid)] != ''){
                                    tempEXIDvalue += LS[MFieldPos.get(exid)].toLowerCase();
                                    System.debug(tempEXIDvalue);
                                }
                            }
                            if(tempEXIDvalue != ''){
                                r.sObj.put(recEXIDcol,tempEXIDvalue);
                            }
                            System.debug(tempEXIDvalue);
                            LInputRow.add(r);
                            System.debug('row to be insert or updated: ' + r);
                        }//end for: loop att content
                        //--------------------------------------------------------------------------------------------------------------------------//
                        //--------------------------------------------------------------------------------------------------------------------------//
                        //--------------------------------------------------------------------------------------------------------------------------//
                        
                        //20160511 Ben @ Elufa
                        
                        for(Row r : LInputRow){
                            if(!r.hasErrors){
                                ASI_MFM_PO_Receipt_Item__c tmpRI = (ASI_MFM_PO_Receipt_Item__c)r.sObj;
                                if(mapPOLine.containsKey(tmpRI.ASI_MFM_PO__c) && tmpRI.ASI_MFM_Amount__c > mapPOLine.get(tmpRI.ASI_MFM_PO__c)[0].ASI_MFM_PO__r.ASI_MFM_PO_Amount__c){
                                    hasError = TRUE;
                                    r.addError('Receipt Amount cannot be larger than total PO amount');
                                }
                            }
                        }
                        
                        //20160511 End
                        
                        list<sObject> lRecInsert = new list<sobject>();
                        
                        System.debug('Has Error: ' + hasError + ' Is upsertMode?: ' + upsertMode);
                        
                        if(!hasError || upsertMode){
                            
                            Savepoint sp = Database.setSavepoint();//20160511 Ben @ Elufa
                            
                            for(Row r : LInputRow){
                                System.debug('Input Row has Error?: ' + r.hasErrors);
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                            }
                            
                            System.debug('Insert Row: ' + lRecInsert);
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    List<Database.upsertResult> uResults = new List<Database.upsertResult>();
                                    List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
                                    
                                    if(upsertMode){
                                        // Hard Code for Casting before upsert
                                        /*if(ObjAPIName == 'ASI_MFM_PO_Receipt_Item__c'){
                                            List<ASI_MFM_PO_Receipt_Item__c> LUpsert = new List<ASI_MFM_PO_Receipt_Item__c>();
                                            if(!hasError){
                                                for(sObject s : lRecInsert){
                                                    if (((ASI_MFM_PO_Receipt_Item__c)s).ASI_MFM_Amount__c != null&&((ASI_MFM_PO_Receipt_Item__c)s).ASI_MFM_PO__c!=null&&((ASI_MFM_PO_Receipt_Item__c)s).ASI_MFM_List_Item_Description_Temp__c!=null&&((ASI_MFM_PO_Receipt_Item__c)s).ASI_MFM_PO_Receipt__c!=null){
                                                        LUpsert.add((ASI_MFM_PO_Receipt_Item__c)s);
                                                    }
                                                }
                                            }
                                            try{
                                                System.debug(LUpsert);
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                                System.debug(ObjType.getDescribe().fields.getMap().get(recEXIDcol));
                                                System.debug(recEXIDcol);
                                                
                                                System.debug(LUpsert);
                                                //insert LUpsert;
                                                System.debug(LUpsert);
                                            }
                                            catch(exception e){
                                                throw e;
                                                System.debug(e.getMessage());
                                            }
                                        }
                                        else {
                                            System.debug('Error, upsert target object is not defined in ASI_MFM_MassUploadProcess apex class!');
                                        }*/
                                    }else{
                                        
                                        //20160510 Ben @ Elufa
                                        Set<Date> dateSet = new Set<Date>();
                                        
                                        List<ASI_MFM_PO_Receipt_Item__c> receiptList = new List<ASI_MFM_PO_Receipt_Item__c>();
                                        
                                        for(sObject obj : lRecInsert){
                                            
                                            ASI_MFM_PO_Receipt_Item__c poReceiptItem = (ASI_MFM_PO_Receipt_Item__c) obj;
                                            
                                            if(poReceiptItem.ASI_MFM_List_Item_Description_Temp__c != '' && poReceiptItem.ASI_MFM_List_Item_Description_Temp__c != NULL){
                                            	dateSet.add(dateSpliter(poReceiptItem.ASI_MFM_List_Item_Description_Temp__c));
                                            	poReceiptItem.ASI_MFM_List_Item_Description_Temp__c = String.valueOf( dateSpliter(poReceiptItem.ASI_MFM_List_Item_Description_Temp__c) );
                                            }else if(poReceiptItem.ASI_MFM_List_Item_Description_Temp__c == '' || poReceiptItem.ASI_MFM_List_Item_Description_Temp__c == NULL){
                                                dateSet.add(date.newInstance(date.today().year(), date.today().month(), date.today().day()));
                                                poReceiptItem.ASI_MFM_List_Item_Description_Temp__c = String.valueOf( date.newInstance(date.today().year(), date.today().month(), date.today().day()) );
                                            }
                                            receiptList.add(poReceiptItem);
                                        }
                                        
                                        List<ASI_MFM_PO_Receipt__c> insertReceiptList = new List<ASI_MFM_PO_Receipt__c>();
                                        
                                        if(dateSet.size() > 0){
                                            
                                            for(date obj : dateSet){
                                                
                                                ASI_MFM_PO_Receipt__c tmpR = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = obj, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt'));
                                                insertReceiptList.add(tmpR);
                                            }
                                        }
                                        
                                        if(insertReceiptList.size() > 0){
                                            
                                            try{
                                                
                                                Insert insertReceiptList;
                                            }catch(dmlException dmle){
                                                
                                                hasError = TRUE;
                                                Database.rollback(sp);
                                            }
                                        }
                                        
                                        if(!hasError){
                                            
                                            lRecInsert.clear();
                                            mapPOReceiptHeader = new Map<String, String>();
                                            
                                            for(ASI_MFM_PO_Receipt__c obj : insertReceiptList){
                                                
                                                mapPOReceiptHeader.put(String.valueOf( Date.newInstance(obj.ASI_MFM_Receipt_Date__c.year(), obj.ASI_MFM_Receipt_Date__c.month(), obj.ASI_MFM_Receipt_Date__c.day()) ), obj.id);
                                            }
                                            
                                            for(ASI_MFM_PO_Receipt_Item__c ri : receiptList){
                                                
                                                if(mapPOLine.containsKey(ri.ASI_MFM_PO__c)){
                                                    
                                                    List<poLineClass> poLineItemList = new List<poLineClass>();
                                                    Decimal totalPaidAmount = 0;
                                                    for(ASI_MFM_PO_Line_Item__c obj : mapPOLine.get(ri.ASI_MFM_PO__c)){
                                                        
                                                        poLineClass tmpClass = new poLineClass();
                                                        tmpClass.lineItemId = obj.id;
                                                        tmpClass.headerId = obj.ASI_MFM_PO__c;
                                                        tmpClass.remainingRecieptAmt = obj.ASI_MFM_CN_Paid_Amount__c > 0 ? obj.ASI_MFM_CN_Paid_Amount__c : obj.ASI_MFM_Amount__c;
                                                        tmpClass.amount = obj.ASI_MFM_Amount__c;
                                                        poLineItemList.add(tmpClass);
                                                        totalPaidAmount += obj.ASI_MFM_CN_Paid_Amount__c;
                                                    }
                                                    
                                                    Integer j = 0;
                                                    Decimal receiptRemaining = ri.ASI_MFM_Amount__c - totalPaidAmount > 0 ? ri.ASI_MFM_Amount__c - totalPaidAmount : 0;
                                                    ri.ASI_MFM_Amount__c = receiptRemaining > 0 ? totalPaidAmount : ri.ASI_MFM_Amount__c;
                                                    while(j < poLineItemList.size()){
                                                        Id receiptId = mapPOReceiptHeader.containsKey(ri.ASI_MFM_List_Item_Description_Temp__c) ? mapPOReceiptHeader.get(ri.ASI_MFM_List_Item_Description_Temp__c) : NULL;
                                                        ASI_MFM_PO_Receipt_Item__c tmpReceiptLine = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = 0, ASI_MFM_Receipt_Line_Description__c = ri.ASI_MFM_Receipt_Line_Description__c, ASI_MFM_PO__c = ri.ASI_MFM_PO__c, ASI_MFM_PO_Receipt__c = receiptId, ASI_MFM_PO_Line_Item__c = poLineItemList[j].lineItemId, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item'));

                                                        if(poLineItemList[j].remainingRecieptAmt <= 0){
                                                            
                                                        }else if(poLineItemList[j].remainingRecieptAmt > ri.ASI_MFM_Amount__c){
                                                           
                                                            poLineItemList[j].remainingRecieptAmt = poLineItemList[j].remainingRecieptAmt - ri.ASI_MFM_Amount__c;
                                                            tmpReceiptLine.ASI_MFM_Amount__c = ri.ASI_MFM_Amount__c;
                                                            ri.ASI_MFM_Amount__c = 0;
                                                            
                                                            lRecInsert.add(tmpReceiptLine);
                                                        }else if(poLineItemList[j].remainingRecieptAmt < ri.ASI_MFM_Amount__c){
                                                            
                                                            ri.ASI_MFM_Amount__c = ri.ASI_MFM_Amount__c - poLineItemList[j].remainingRecieptAmt;
                                                            tmpReceiptLine.ASI_MFM_Amount__c = poLineItemList[j].remainingRecieptAmt;
                                                            
                                                            lRecInsert.add(tmpReceiptLine);
                                                            
                                                            poLineItemList[j].remainingRecieptAmt = 0;
                                                            
                                                        }else if(poLineItemList[j].remainingRecieptAmt == ri.ASI_MFM_Amount__c){
                                                           
                                                            tmpReceiptLine.ASI_MFM_Amount__c = poLineItemList[j].remainingRecieptAmt;
                                                            lRecInsert.add(tmpReceiptLine);
                                                            
                                                            poLineItemList[j].remainingRecieptAmt = 0;
                                                            ri.ASI_MFM_Amount__c = poLineItemList[j].remainingRecieptAmt;
                                                            
                                                        }
                                                        
                                                        if(poLineItemList[j].amount - tmpReceiptLine.ASI_MFM_Amount__c >= receiptRemaining){
                                                            
                                                            tmpReceiptLine.ASI_MFM_Amount__c += receiptRemaining;
                                                            receiptRemaining = 0;
                                                        }else if(poLineItemList[j].amount - tmpReceiptLine.ASI_MFM_Amount__c < receiptRemaining){
                                                            
                                                            receiptRemaining = receiptRemaining - (poLineItemList[j].amount - tmpReceiptLine.ASI_MFM_Amount__c);
                                                            tmpReceiptLine.ASI_MFM_Amount__c = poLineItemList[j].amount;
                                                        }
                                                        
                                                        j++;
                                                    }
                                                }
                                            }
                                            //20160510 End
                                            
                                            //Added by Wilken on 20150113 Add Insert Result to VF page display
                                            insertResults = Database.insert(lRecInsert, opt_allOrNone);
                                        }
                                    }
                                    integer succInsert = 0;
                                    integer succUpdate = 0;
                                    string validationErrorText = '';
                                    integer rowNo = 0;
                                    
                                    //Upsert Result
                                    
                                    /*for(Database.upsertResult res:uResults) {
                                        rowNo ++;
                                        if (res.isSuccess()) {
                                            if (res.isCreated()) {
                                                System.debug('Created record ID ' + res.getId() + '.');
                                                succInsert ++;
                                            } else {
                                                System.debug('Updated record ID ' + res.getId() + '.');
                                                succUpdate ++;
                                            }
                                        }
                                        else {
                                            if (res.getErrors().size() > 0) {
                                                System.debug(res.getErrors()[0].getMessage());
                                                validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                            
                                        }
                                    }*/
                                    
                                    //Insert Result
                                    for(Database.SaveResult res:insertResults) {
                                        rowNo ++;
                                        if (res.isSuccess()) {
                                            System.debug('Created record ID ' + res.getId() + '.');
                                            succInsert ++;                                            
                                        }else {
                                            if (res.getErrors().size() > 0) {
                                                System.debug(res.getErrors()[0].getMessage());
                                                validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                        }
                                    }
                                    
                                    msg = 'Import Completed! ' + string.valueof(succInsert) + ' record(s) created.\n';
                                    msg += '' + string.valueof(succUpdate) + ' record(s) updated.\n';
                                    string errorText = '';
                                    
                                    if(validationErrorText != ''){
                                        errorText = validationErrorText;
                                    }
                                        
                                    for(Row r : LInputRow){
                                        if(r.hasErrors){
                                            for(string errorMsg :r.errorMsgs) {
                                                if(errorText!='') errorText += '\n';
                                                errorText += 'Row' + String.valueof((r.rowNumber+1))+': ' + errorMsg;
                                            }
                                        }
                                    }
                                    if(errorText!='')
                                        msg += errorText;
                                    resultTexts.put(att.Id, msg);
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,att.description);
                                    LParentObj.add(tempParent);
                                }catch(dmlexception de){
                                    hasError = true;
                                    Set<String> ems = new Set<String>();
                                    for(integer j =0;j<de.getNumDml();j++){
                                        
                                        LInputRow[0].addError(de.getDmlMessage(j));
                                        if(mapPONumber.containsKey(String.valueOf( lRecInsert[de.getDmlIndex(j)].get('ASI_MFM_PO__c'))) && mapRowByPONumber.containsKey(mapPONumber.get(String.valueOf( lRecInsert[de.getDmlIndex(j)].get('ASI_MFM_PO__c') ))))
                                        	ems.add('Row ' + mapRowByPONumber.get(mapPONumber.get( String.valueOf( lRecInsert[de.getDmlIndex(j)].get('ASI_MFM_PO__c') ))) + ':' + de.getDmlMessage(j));
                                        else
                                            ems.add(de.getDmlMessage(j));
                                            
                                        LErrorRows.add(LInputRow[0]);
                                    }
                                    for(String em : ems){
                                        
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n' + em);//de.getDmlMessage(j));
                                    }
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
                                    Database.rollback(sp);
                                }catch(exception e){
                                    system.debug('error'+e);
                                    hasError = true;
                                    LInputRow[0].addError(e.getMessage());
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+e.getMessage());
                                    LErrorRows.add(LInputRow[0]);
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
                                    Database.rollback(sp);
                                }
                            }else{
                                string errorText = '';
                                for(Row r : LInputRow){
                                    if(r.hasErrors){
                                        for(string errorMsg :r.errorMsgs) {
                                            if(errorText!='') errorText += '\n';
                                            errorText += 'Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                        }
                                    }
                                }
                                if(errorText!='')
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                                LAttUpdate.add(att);
                                sObject tempParent = ParentObjType.newSObject();
                                tempParent.put('id',att.parentid);
                                tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                LParentObj.add(tempParent);
                            }
                        }else{
                            string errorText = '';
                            for(Row r : LInputRow){
                                if(r.hasErrors){
                                    for(string errorMsg :r.errorMsgs) {
                                        if(errorText!='') errorText += '\n';
                                        errorText += 'Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                    }
                                }
                            }
                            if(errorText!='')
                                resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                            LAttUpdate.add(att);
                            sObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id',att.parentid);
                            tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                            LParentObj.add(tempParent);
                        }
                    }//end if: att has content
                    System.debug(LAttUpdate);
                    if(LAttUpdate != null && LAttUpdate.size()>0){
                        
                        for(Attachment att1: LAttUpdate) {
                            att1.description = resultTexts.get(att.Id).length()>500? resultTexts.get(att.Id).substring(0,500): resultTexts.get(att.Id);
                        }
                        
                        update LAttUpdate;
                    }
                    if(LParentObj != null && LParentObj.size()>0){
                        update LParentObj;
                    }
                    List<Messaging.Email> LEmails = new List<Messaging.Email>();
                    for(Attachment att1 : LAttUpdate){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        string resultText = resultTexts.get(att1.Id);
                        String resultTextHtml = resultText.replace('\n','<br/>');
                        String URLDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.id;
                        mail.setHtmlBody('Your mass upload submission was processed.<br/>' + resultTextHtml + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>Download Uploaded csv: <a href=\"'+URLDownload+'\">'+URLDownload+'</a>');
                        mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded csv: '+ URLDownload);
                        mail.setToAddresses(new List<String>{att1.owner.email});
                        mail.setReplyTo('noreply@salesforce.com');
                        mail.setSenderDisplayName('Mass Upload Process');
                        mail.setSubject('Mass Upload Process is Completed');
                        LEmails.add(mail);
                    }
                    if(LEmails.size()>0 && emailNotification){
                        if(!test.isrunningtest()){
                            Messaging.sendEmail(LEmails);
                        }
                    }
                }else{//end if: check attachment is CSV
                
                    msg = 'Error: Please select csv file only!';
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public void init(){
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        LFieldAPIName = fields.toLowerCase().split(',',0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',',0);
        
        //20160509 Ben @ Elufa
        List<recordType> tmpRT = new List<recordType>([select id from recordType where name = :recordtypeName and SobjectType = :ObjAPIName]);
        
        if(tmpRT.size()>0){
            recordtypid = tmpRT[0].id;
        }
        //20160509 End
        
        MAPINameLabel = new map<string,string>();
        for(integer i=0;i<LFieldAPIName.size();i++){
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(),LFieldLabel[i].toLowerCase().trim());
        }
        MRecTypeID = new map<string,id>();
        for(RecordType r: [Select id, name, SobjectType from RecordType]){
            string key = r.SobjectType+r.name;
            key = key.toLowerCase();
            MRecTypeID.put(key,r.id);
        }
        system.debug('MRecTypeID'+MRecTypeID);
        hasError = false;
        msg = '';
        LDefaultVales = new list<string>();
        LDefaultValesHeader = new list<string>();
        if(defaultValues != null && defaultValues != ''){
            list<string> LDefaultValuePair = defaultValues.split(';',0);
            for(String s : LDefaultValuePair){
                list<string> l = s.split(':',0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
        }
    }
    
    private list<string> addDefaultValues(list<string> ls, boolean isHeader){
        if(isHeader)
            ls.addAll(LDefaultValesHeader);
        else
            ls.addAll(LDefaultVales);
        return ls;
    }
    
    private id matchLookupField(integer pos,list<string> ls, map<string,integer> mfpos, map<string,id> MRecTypeID){
        String key = '';
        system.debug('mfpos'+mfpos);
        system.debug('ls'+ls);
        system.debug('LLookupField[pos]'+LLookupField[pos]);
        for(string label : LLookupField[pos].MFieldLabelKeyFilter.keySet()){
            system.debug('label '+label+'/'+mfpos.containsKey(label));
            if(mfpos.containsKey(label.toLowerCase())){
                if(label.contains('recordtype')){
                    string tempKey = LLookupField[pos].objectName.toLowerCase() + ls[mfpos.get(label)].toLowerCase();
                    system.debug('MRecTypeID'+MRecTypeID);
                    system.debug('MRecTypeID.containsKey(tempKey)'+tempKey+'/'+MRecTypeID.containsKey(tempKey));
                    if(MRecTypeID.containsKey(tempKey)){
                        key += String.valueof(MRecTypeID.get(tempKey)).toLowerCase();
                    }
                }else{
                    key += ls[mfpos.get(label)].toLowerCase().trim();
                    system.debug('key: '+key);
                }
            }
        }
        system.debug(key);
        return LLookupField[pos].genid(key);
    }
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }        
    private List<List<String>> genResults(blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null){
            //Modify by Steve 20140617
            String fileString = blobToString( contentFile,'GB2312');
            parsedCSV = parseCSV(fileString, false);
            rowCount = parsedCSV.size();
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
        contents = contents.replaceAll('\r\n','\r');
        contents = contents.replaceAll('\n','\r');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            //lines = contents.split('\n'); //correction: this only accomodates windows files
            lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        }catch (System.ListException e) {
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
                    system.debug('composite field2:'+compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
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
    
    // class for storing lookup field name and corresponding key fields
    public class lookupRecord{
        public string Field {set;get;}                        //lookup field name
        public string objectName {set;get;}                   //object of lookup field point to
        public map<string,string> MFieldLabel {set;get;}      //Map for header name & field api name
        private string soql {set;get;}
        private list<set<string>> LkeyFilter;                 //key field values for searching records by soql
        private map<string,integer> MFieldLabelKeyFilter;     //map for key field to access corresponding set of values for filter in LkeyFilter 
        public map<string,id> MResult;
        public lookupRecord(string input){
            soql = '';
            LkeyFilter = new list<set<string>>();
            MFieldLabelKeyFilter = new map<string,integer>();
            MFieldLabel = new map<string,string>();
            list<string> temp = input.split(':',0);
            if(temp.size()>1){
                list<string> objectinfo = temp[0].split('/',0);
                objectName = objectinfo[0].trim();
                Field = objectinfo[1].trim().toLowerCase();
                for(string s : temp[1].split(',',0)){
                    temp = s.split('&',0);
                    if(temp.size()>1){
                        MFieldLabel.put(temp[0].trim().toLowerCase(),temp[1].trim().toLowerCase());
                        LkeyFilter.add(new set<String>());
                        MFieldLabelKeyFilter.put(temp[0].trim().toLowerCase(),LkeyFilter.size()-1);
                    }
                }
            }
        }
        public void addKey(list<string> ls, map<string,integer> Mpos1, map<string,id> MRecTypeID){
            system.debug('ls'+ls);
            system.debug('Mpos1'+Mpos1);
            system.debug('MFieldLabel'+MFieldLabel);
            for(string label : MFieldLabel.keySet()){
                system.debug('Mpos1.containsKey(label)) '+label + '/'+Mpos1.containsKey(label));
                
                if(Mpos1.containsKey(label)){
                    system.debug('key1'+ls[Mpos1.get(label)]);
                    system.debug('MFieldLabelKey'+MFieldLabelKeyFilter.get(label));
                    system.debug('LKeyFilter'+LkeyFilter[MFieldLabelKeyFilter.get(label)]);
                    //handle recordtype id in lookup field component
                    system.debug('label'+label+'/'+label.contains('recordtype'));
                    system.debug('MRecTypeID'+MRecTypeID);
                    if(label.contains('recordtype')){
                        string key = objectName + ls[Mpos1.get(label)].trim();
                        key = key.toLowerCase();
                        
                        system.debug('MRecTypeID.get(key)'+key+'/'+MRecTypeID.containsKey(key));
                        if(MRecTypeID.containsKey(key)){
                            LkeyFilter[MFieldLabelKeyFilter.get(label)].add(MRecTypeID.get(key));
                        }
                    }
                    else{
                        LkeyFilter[MFieldLabelKeyFilter.get(label)].add(ls[Mpos1.get(label)].trim());
                    }
                }
            }
        }
        
        public void queryResult(){
            
            soql = 'Select id ';
            for(String label : MFieldLabel.keySet()){
                soql += ',' + MFieldLabel.get(label);
            }
            soql += ' from ' + objectName;
            if(MFieldLabel.keySet().size()>0){
                soql += ' where id != null ';
            }
            Set<String> setFilter1;
            Set<String> setFilter2;
            Set<String> setFilter3;
            Set<String> setFilter4;
            for(String label : MFieldLabel.keySet()){
                //soql += ' and ' + MFieldLabel.get(label) + ' IN :LkeyFilter[MFieldLabelKeyFilter.get(label)]';
                soql += ' and (';
                system.debug('MFieldLabelKeyFilter '+MFieldLabelKeyFilter); 
                system.debug('MFieldLabel '+MFieldLabel.get(label));
                system.debug('LkeyFilter '+LkeyFilter[MFieldLabelKeyFilter.get(label)]);
                for(string s : LkeyFilter[MFieldLabelKeyFilter.get(label)]){
                    system.debug('string '+ s.replace('\'','\\\''));
                    soql += MFieldLabel.get(label) + ' = \'' + s.replace('\'','\\\'') + '\'  or ';
                }
                soql = soql.substring(0,soql.length()-5);
                if(LkeyFilter[MFieldLabelKeyFilter.get(label)].size()>0)
                    soql += ' ) ';
                
            }
            system.debug('soql: '+soql);
            if(test.isRunningTest()){
                soql += ' limit 1';
            }
            list<sObject> LResult = database.query(soql);
            system.debug('LResult SOQL Result: '+LResult);
            if(LResult != null && LResult.size()>0){
                MResult = new map<string,id>();
                for(sObject s : LResult){
                    string key = '';
                    for(String label : MFieldLabel.keySet()){
                        system.debug('MFieldLabel.get(label)'+MFieldLabel.get(label));
                        system.debug('objectName '+objectName);
                        key += s.get(MFieldLabel.get(label));
                    }
                    MResult.put(key.toLowerCase(),s.id);
                    System.debug('Map of SOQL Result: ' + MResult);
                }
            }
        }
        public id genid(string inputKey){
            System.debug(inputKey);
            System.debug(MResult);
            inputKey = inputKey.trim();
            if(MResult != null && inputKey != null && inputKey != ''){
                system.debug('MResult'+MResult);
                system.debug('genid'+MResult.get(inputKey));
                system.debug('inputKey'+inputKey);
                return MResult.get(inputKey);
                
            }
            
            return null;
        }
    }
    
    //20160511 Ben @ Elufa
    Public Class poLineClass{
        
        String lineItemId;
        String headerId;
        Decimal remainingRecieptAmt;
        Decimal amount;
    }
    
    public class Row {
        public Integer rowNumber {set;get;}
        public sObject sObj {set;get;}
        
        private list<string> m_errorMsgs = new list<string>();
        public list<string> errorMsgs { get { return m_errorMsgs; }}
        public boolean hasErrors { get { return errorMsgs.size()>0; }}
        
        // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        public row(sObject obj){
            sObj = obj;            
        }
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
        }
        public void addError(string errMsg){
            errorMsgs.add( errMsg);
        }
    }
    
    //added by steve on 12/28/2015. To handle currency formatt,e.g. $1,450.00, the range is from $0.00 up to $9,999,999,99.
    public static date dateSpliter(string dateText){
        string test=dateText.substring(5,7);
        integer year;
        integer day;
        integer month;
        if(dateText.length()==10){
            year=integer.valueOf(dateText.subString(0,4));
            day=integer.valueOf(datetext.substring(8,10));
            month=integer.valueOf(dateText.substring(5,7)); 
        }
        else if(dateText.length()==9){
            if(test.contains('/')){
                year=integer.valueOf(dateText.subString(0,4));
                day=integer.valueOf(datetext.substring(7,9));
                month=integer.valueOf(dateText.substring(5,6));
                
            }
            else{
                year=integer.valueOf(dateText.subString(0,4));
                day=integer.valueOf(datetext.substring(8,9));
                month=integer.valueOf(dateText.substring(5,7));
                
            }
        }
        else if (dateText.length()==8){
            if(test.contains('/')){
                year=integer.valueOf(dateText.subString(0,4));
                //20200206:AM@introv - fix date format
                /*
                day=integer.valueOf(datetext.substring(5,6));
                month=integer.valueOf(dateText.substring(7,8));
                */
                month=integer.valueOf(datetext.substring(5,6));
                day=integer.valueOf(dateText.substring(7,8));
            }
        }
        date result=date.newInstance(year, month, day);
        return result;
        
    }//Added by steve on 12/28/2015. Handle different formatting issues, e.g. YYYY/MM/DD
    
}