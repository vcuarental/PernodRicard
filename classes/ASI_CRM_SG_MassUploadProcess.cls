public with sharing  class ASI_CRM_SG_MassUploadProcess implements Database.Batchable<sObject>{

    public final String ObjAPIName;
    public final String parentID;
    public final String parentField;
    public final String fields;
    public final String fieldsLabel;
    public final String lookupEXID;
    public final List<String> requiredFields;

    public final String recordtypeName;
    public final String currentPageURL;
    public final String defaultValues;
    public Map<String,String> defaultValuesMap;
    public final String AttID;
    
    public final string recEXID {set;get;}
    public final string recEXIDcol {set;get;}
    public final string parentObjectAPIName {set;get;}
    public final string ParentObjectUploadMsg {set;get;}
    public final boolean upsertMode {set;get;}
    public final boolean batchMode {set;get;}
    public final boolean opt_allOrNone {set;get;}
    public final boolean emailNotification {set;get;}
    public final boolean containsHeader {set;get;}
    public final integer noOfLastRowToIgnore {set;get;}
    public List<Attachment> LAttUpdate;
    
    
    public String AttachmentBatchId {set;get;} {AttachmentBatchId='';}
    public string currentPageURLOutput {set;get;}
    private Schema.SObjectType ObjType;
    private Schema.SObjectType ParentObjType;
    private List<String> LFieldAPIName;
    private List<String> LFieldLabel;
    private Map<string,string> MAPINameLabel;
    private List<Row> LInputRow;
    public List<Row> LErrorRows {set;get;}
    private List<lookupRecord> LLookupField;
    private Map<string,integer> MFieldPos;
    private Map<string,integer> MLookupFieldPos;
    private Map<string,id> MRecTypeID;
    public boolean hasError {set;get;}
    public string msg {set;get;}
    private id recordtypid;
    private List<string> LDefaultVales;
    private List<string> LDefaultValesHeader;
    private List<string> LEXIDFieldLabel;
    public String HeaderId; //Added by Introv for TW CRM FOC/POSM Request Line Uploading @20161111
    
    private Integer rowCount;
    private Integer colCount;
	
	private Map<Integer, Integer> errorRowMap = new Map<Integer, Integer>();

    public String OFFTAKETYPE_ONTRADE = 'INV';
    public String OFFTAKETYPE_OFFTRADE = 'Off-Trade';
	public map<string, string> map_offtradeWholesalerCode = new map<string, string>{
		'CS' => '19855',
		'GH' => '19855'
	};
	
    public ASI_CRM_SG_MassUploadProcess(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName,
        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone, boolean containsHeader, integer noOfLastRowToIgnore, String requiredFields){
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
        this.HeaderId = currentPageURL; //Added by Introv for TW CRM FOC/POSM Request Line Uploading @20161111
		this.containsHeader = containsHeader;
        this.noOfLastRowToIgnore = noOfLastRowToIgnore;
//        this.requiredFields = requiredFields.split(',');
   }
    

    public database.querylocator start(Database.BatchableContext BC){
     // This methods returns a SOQL query locator containing the records
            return Database.getQueryLocator([SELECT id, name, body, description, parentid,owner.email,owner.Name,contenttype   FROM attachment WHERE id =:AttID]);
     }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope != null){
            init();
            LAttUpdate = new List<Attachment>();
            List<sObject> LParentObj = new List<sObject>();
            Map<Id, string> resultTexts = new Map<Id, string>();
			Map<decimal, string> map_resultTextsByRow = new Map<decimal, string>();
			
			Date dateOfFirstRecord;
            
            for(sobject sc : scope){
				
				String offtakeHeaderID = '';
				String offtakeHeaderName = '';
				List<ASI_CRM_ActualOfftakeHeader__c> list_offtakeHeaderToBeOverwritten;
                Attachment att = (Attachment)sc;  
                AttachmentBatchId=att.parentid!=null? att.parentid:'';
                att.description = '';
                resultTexts.put(att.Id, '');
                LErrorRows = new List<Row>();
                String namefile = att.name;
                system.debug('namefile'+namefile);
                if(namefile.toLowerCase().right(3)=='csv'){
                    List<List<String>> parsedCSV = genResults(att.body);
                    List<String> LHeader = new List<String>();
                    
                    if(parsedCSV != null && parsedCSV.size()>0){
                        // retrieve header of csv
						if (containsHeader){
							LHeader = addDefaultValues(parsedCSV[0],true);                  
							parsedCSV.remove(0);
						} else {
							LHeader = addDefaultValues(LFieldLabel,true);
						}
						
						if(noOfLastRowToIgnore>0){
							integer originalSize = parsedCSV.size();
							for(integer lastRowNo = (originalSize-1); lastRowNo >= (originalSize-noOfLastRowToIgnore); lastRowNo--){
								parsedCSV.remove(lastRowNo);
							}
						}
						
                        
                       
                        system.debug(LHeader); 
                        integer i = 0;
                        for(List<String> LS : parsedCSV){
                            LS = addDefaultValues(LS,false);
                        }
                        MFieldPos = new Map<string,integer>();
                        for(string h : LHeader){
                            MFieldPos.put(h.toLowerCase().trim(),i);
                            i++;
                        }
                        
                        LLookupField = new List<lookupRecord>();
                        MLookupFieldPos = new Map<string,integer>();

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
                                //LS = addDefaultValues(LS,false);
                            }
                            lookupField.queryResult();
                        }

                        LInputRow = new List<Row>();
                        // start on 2nd row because the first row is header
                        Integer rowNumber = containsHeader ? 2 : 1;
                        Map<string,string> MFieldType = new Map<string,string>();

                        for(string fieldname : LFieldAPIName){
                            MFieldType.put(fieldname,ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());
                            
                        }
                        LEXIDFieldLabel = new List<String>();
                        if(recEXID != null && recEXID != ''){
                            LEXIDFieldLabel = recEXID.split(';',0);
                        }
                        
                        for(List<String> LS : parsedCSV){
                            // handle if Parent Field and Field ID is null
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
                            
                            for(string fieldname : LFieldAPIName){
                                string labelname = MAPINameLabel.get(fieldname);
                                System.debug('fieldname : ' + fieldname + 'labelname ' + labelname);
								try{
								    
    								if (String.isEmpty(LS[MFieldPos.get(labelname)])){
    									r.addError(labelname + ': Empty');
                                        hasError = true;
    									continue;
    								}
								    
								} catch (Exception e){
								    System.debug(e.getMessage());
								}


                                if(MLookupFieldPos.containsKey(fieldname)){
                                    if(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID) == null){
                                        system.debug(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                        r.addError(labelname + ':Cannot find record');
                                        //r.addError(MLookupFieldPos.get(fieldname)+labelname + ':d Cannot find record'+MFieldPos+MRecTypeID);
                                        hasError = true;
                                    }
                                    try{
                                    r.sObj.put(fieldname, matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                    }
                                    catch(exception e){
                                        r.addError(labelname + ':Cannot find record');
                                        hasError = true;
                                    }
                                }
                                else if(MFieldPos.containsKey(labelname)/* && LS[MFieldPos.get(labelname)] != null && LS[MFieldPos.get(labelname)] != ''*/){
                                    system.debug('Non-Lookup Field:' + fieldname);
                                    system.debug('MFieldPos'+MFieldPos);
                                    system.debug(MFieldPos.get(labelname));
                                    system.debug(ObjType);
                                    //system.debug(ObjType.getDescribe().fields.getMap().get(labelname));
                                    //system.debug(ObjType.getDescribe().fields.getMap().get(labelname).getDescribe().getType().name());
                                    if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);

                                        System.debug('tempFieldType : ' + tempFieldType);

                                        //if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='boolean'){
                                        if(tempFieldType=='boolean'){
                                            system.debug('Boolean source '+LS[MFieldPos.get(labelname)].toLowerCase());
                                            if(LS[MFieldPos.get(labelname)].toLowerCase().trim()=='y'||LS[MFieldPos.get(labelname)].trim()=='1'||LS[MFieldPos.get(labelname)].toLowerCase().trim()=='true'){
                                                try{
                                                r.sObj.put(fieldname, true);
                                                }
                                                catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }
                                            else{
                                                try{
                                                    r.sObj.put(fieldname, false);
                                                }
                                                catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }
                                                
                                        }
                                        //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='date'){
                                        else if(tempFieldType=='date'){
                                            try{
                                                string dateText = LS[MFieldPos.get(labelname)];
                                                System.debug(LoggingLevel.ERROR, 'datetext: ' + dateText);
                                                if(dateText.contains('/') || dateText.contains('-') || dateText.length()!=8){
                                                    try{
                                                        System.debug('******Print date ' + date.valueOf(dateText));
                                                        r.sObj.put(fieldname, date.valueOf(dateText));
                                                    }
                                                    catch(exception e){
                                                        List<String> dayMonthYear = dateText.split('-');
                                                        Map<String, String> monthToNumber = new Map<String, String>{
                                                                'Jan' => '1',
                                                                'Feb' => '2',
                                                                'Mar' => '3',
                                                                'Apr' => '4',
                                                                'May' => '5',
                                                                'Jun' => '6',
                                                                'Jul' => '7',
                                                                'Aug' => '8',
                                                                'Sep' => '9',
                                                                'Oct' => '10',
                                                                'Nov' => '11',
                                                                'Dec' => '12'
                                                        };

                                                        if (monthToNumber.get(dayMonthYear[1]) == null) {
                                                            System.debug(e.getMessage());
                                                            r.addError(Labelname + ': ' + e.getMessage());
                                                            hasError = true;
                                                        }

                                                        String formattedDateString = '20' + dayMonthYear[2] + '-' + monthToNumber.get(dayMonthYear[1]) + '-' + dayMonthYear[0];
                                                        System.debug('formattedDateString ' + formattedDateString);
                                                        r.sObj.put(fieldname, Date.valueOf(formattedDateString));
                                                    }
                                                }
                                                else {
                                                    r.sObj.put(fieldname, date.newInstance(integer.valueOf(dateText.substring(0,4)), integer.valueOf(dateText.substring(4,6)), integer.valueOf(dateText.substring(6,8))));
                                                }
												// For SG offtake upload
												Date uploadDate = Date.valueOf(r.sObj.get(fieldname));
												if (dateOfFirstRecord == null){
													dateOfFirstRecord = uploadDate;
												} else {
													String dateKey_thisRecord = uploadDate.year() + '_' + uploadDate.month();
													String dateKey_default = dateOfFirstRecord.year() + '_' + dateOfFirstRecord.month();
													if (dateKey_thisRecord != dateKey_default){
														r.addError('Offtake G/L Date is not in the same month.');
														hasError = true;
													}
												}
                                            }
                                            catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }else if(tempFieldType=='double' ||
                                            tempFieldType=='percent' ||
                                            tempFieldType=='currency'
                                        ){
                                            try{
                                                r.sObj.put(fieldname, decimal.valueOf(LS[MFieldPos.get(labelname)]));
                                            }
                                                catch(exception e){
                                                        r.addError(labelname + ': ' + e.getMessage());
                                                        hasError = true;
                                                }
                                        }
                                        //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='integer'){
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
                                exid = exid.toLowerCase();
                                system.debug(exid);
                                if(MFieldPos.containsKey(exid) && LS[MFieldPos.get(exid)] != null && LS[MFieldPos.get(exid)] != ''){
                                    tempEXIDvalue += LS[MFieldPos.get(exid)].toLowerCase();
                                    System.debug(tempEXIDvalue);
                                }
                            }
                            if(tempEXIDvalue != ''){
                                r.sObj.put(recEXIDcol,tempEXIDvalue);
                            }/*
                            //Added by Twinkle LI @Introv #20160505 - TH WS/SIT offtake
                            else{
                                if(ObjAPIName == 'ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c'){
                                    r.addError('Missing External Id.');
                                    hasError = true;
                                }
                            }*/
                            
                            System.debug(tempEXIDvalue);
                            LInputRow.add(r);
                            System.debug(r);
                        }
						
						if (!hasError/* || upsertMode*/){
							// check if this wholesaler and offtake has been uploaded before
							Date offtakeDate = Date.valueOf(LInputRow[0].sObj.get('ASI_TH_CRM_Offtake_G_L_Date__c'));

                            System.debug('LInputRow[0].sObj ' + LInputRow[0].sObj);
                            System.debug('LInputRow[0].sObj.get(ASI_TH_CRM_Offtake_G_L_Date__c): ' + LInputRow[0].sObj.get('ASI_TH_CRM_Offtake_G_L_Date__c'));

                            System.debug('offtakeDate: ' + offtakeDate);
							
							string wholesalerCode = String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Type_Uploaded__c')) == OFFTAKETYPE_ONTRADE ?
								String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Wholesaler_Code_Uploaded__c')) :
								map_offtradeWholesalerCode.get(String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Wholesaler_Code_Uploaded__c')));

							List<ASI_CRM_ActualOfftakeHeader__c> list_offtakeHeader = [
								SELECT id, name, ASI_CRM_Confirmed__c
								FROM ASI_CRM_ActualOfftakeHeader__c
								WHERE recordtypeid = :Global_RecordTypeCache.getRtId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_SG_Actual_Offtake_Header')
								AND ASI_CRM_Wholesaler_Code_Uploaded__c = :wholesalerCode
								AND ASI_CRM_Year__c = :String.valueOf(offtakeDate.year())
								AND ASI_CRM_Month__c = :String.valueOf(offtakeDate.month())
							];
							
							if(list_offtakeHeader.size()>0){
								if(list_offtakeHeader[0].ASI_CRM_Confirmed__c){
									hasError = true;
									Row r = LInputRow[0];
									r.addError('This wholesaler has confirmed offtakes at the same month with batch ID '+list_offtakeHeader[0].name);
								}
								// prepare to overwrite uploaded offtakes
								else{
									list_offtakeHeaderToBeOverwritten = list_offtakeHeader;
								}
								
							}						
						}
						
                        List<sObject> lRecInsert = new List<sobject>();
                        if(!hasError/* || upsertMode*/){
                            for(Row r : LInputRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                            }
                            system.debug('lRecInsert:'+lRecInsert);
                            if(lRecInsert != null && lRecInsert.size()>0){
								
								string wholesalerCode = String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Type_Uploaded__c')) == OFFTAKETYPE_ONTRADE ?
									String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Wholesaler_Code_Uploaded__c')) :
									map_offtradeWholesalerCode.get(String.valueOf(LInputRow[0].sObj.get('ASI_CRM_Wholesaler_Code_Uploaded__c')));

								// insert actual offtake header
								ASI_CRM_ActualOfftakeHeader__c h = new ASI_CRM_ActualOfftakeHeader__c(
									recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_SG_Actual_Offtake_Header'),
									ASI_CRM_OfftakeDate__c = Date.valueOf(lRecInsert[0].get('ASI_TH_CRM_Offtake_G_L_Date__c')),
									ASI_CRM_Wholesaler_Code_Uploaded__c = wholesalerCode
								);
								insert h;
								
								offtakeHeaderID = h.id;
								
								List<ASI_CRM_ActualOfftakeHeader__c> list_offtakeHeaderInserted = [
									SELECT id, name
									FROM ASI_CRM_ActualOfftakeHeader__c
									WHERE id = :offtakeHeaderID
									LIMIT 1
								];
								
								if(list_offtakeHeaderInserted.size()>0){
									offtakeHeaderName = list_offtakeHeaderInserted[0].name;
								}				
								
                                try{
                                    List<Database.upsertResult> uResults = new List<Database.upsertResult>();
                                    List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
                                    
									string firstOfftakeId = '';
									
                                    if(upsertMode){
                                        // Hard Code for Casting before upsert
                                    }
                                    else {
                                        //Add Insert Result to VF page display
                                        if(ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c'){//ASI_CRM_FromWS__c,ASI_CRM_SG_Customer__c,ASI_CRM_SKU__c
                                            
											Integer fileRowNo = containsHeader ? 2 : 1;
											Integer insertRowNo = 1;
											
											List<ASI_TH_CRM_Actual_Offtake__c> OfftakeInsertList = new List<ASI_TH_CRM_Actual_Offtake__c>();
                                            for(sObject s : lRecInsert){
                                                ASI_TH_CRM_Actual_Offtake__c tempData= (ASI_TH_CRM_Actual_Offtake__c)s;

                                                System.debug('tempData.ASI_CRM_Type_Uploaded__c ' + tempData.ASI_CRM_Type_Uploaded__c);
                                                System.debug('tempData.ASI_CRM_Type_Uploaded__c == Off-Trade ' + tempData.ASI_CRM_Type_Uploaded__c == 'Off-Trade');
                                                if (defaultValuesMap.get('Type (Uploaded)') == 'Off-Trade') {
                                                    tempData.ASI_CRM_Type_Uploaded__c = 'Off-Trade';
                                                }

												if (tempData.ASI_CRM_Type_Uploaded__c == 'INV' || tempData.ASI_CRM_Type_Uploaded__c == 'Off-Trade'){
                                                    tempData.ASI_CRM_Mass_Uploaded__c = true;
                                                    tempData.ASI_CRM_CN_Batch_Id__c = offtakeHeaderName;
                                                    tempData.ASI_TH_CRM_Quantity__c = tempData.ASI_CRM_Original_Quantity__c != null? tempData.ASI_CRM_Original_Quantity__c : 0;
                                                    tempData.ASI_CRM_ActualOfftakeHeader__c = h.id;
													tempData.ASI_CRM_Row_No_Uploaded__c = fileRowNo;

													OfftakeInsertList.add(tempData);
													
													errorRowMap.put(fileRowNo,insertRowNo);
													
													insertRowNo++;
													
												}
												fileRowNo++;
                                            }
											
											system.debug('errorRowMap:'+errorRowMap);
                                            
                                            if(OfftakeInsertList.size()>0){
                                                System.debug('******');
                                                System.debug(OfftakeInsertList);
                                                insertResults=database.insert(OfftakeInsertList, opt_allOrNone);
												firstOfftakeId = OfftakeInsertList[0].Id;
                                            }
                                        } else {
											insertResults = Database.insert(lRecInsert, opt_allOrNone);
										}
                                        
                                    }
                                       
                                    integer succInsert = 0;
                                    integer succUpdate = 0;
                                    string validationErrorText = '';
                                    integer rowNo = 0;
                                    
                                    //Upsert Result
                                    for(Database.upsertResult res:uResults) {
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
                                                validationErrorText += 'Row' + String.valueOf(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                        }
                                    }
                                    
                                    //Insert Result
                                    for(Database.SaveResult res:insertResults) {
                                        rowNo ++;
                                        if (res.isSuccess()) {
                                            System.debug('Created record ID ' + res.getId() + '.');
                                            succInsert ++;                                            
                                        }
                                        else {
                                            if (res.getErrors().size() > 0) {
                                                System.debug(res.getErrors()[0].getMessage());
                                                validationErrorText += 'Row' + String.valueOf(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                        }
                                    }
                                    
                                    msg = string.valueOf(succInsert) + ' offtakes have been uploaded successfully. Please note the following batch ID for your reference.\n';
                                    // msg += '' + string.valueof(succUpdate) + ' record(s) updated.\n';
								    
									List<ASI_TH_CRM_Actual_Offtake__c> list_a = [SELECT ASI_CRM_FromWS__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE id = :firstOfftakeId LIMIT 1];
									if (list_a.size()>0){
										h.ASI_CRM_From_Wholesaler__c = list_a[0].ASI_CRM_FromWS__c;
										update h;
									}
									
                                    
                                    string errorText = '';
                                    for(Row r : LInputRow){
                                        if(r.hasErrors){
                                            for(string errorMsg :r.errorMsgs) {
                                                if(errorText!='') errorText += '\n';
                                                errorText += 'Row' + String.valueOf(r.rowNumber)+': ' + errorMsg;
                                            }
                                        }
                                    }
                                    if(errorText!='')
                                        msg += errorText;
                                    
                                    resultTexts.put(att.Id, 'Upload Succeeded! '+string.valueOf(succInsert) +' offtakes have been uploaded. An email has been sent to your mailbox.');
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,att.description);
                                    LParentObj.add(tempParent);
                                  
                                }
                                catch(dmlexception de){
                                    hasError = true;
                                    System.debug('******');
                                    System.debug(de.getMessage());
                                    for(integer j =0;j<de.getNumDml();j++){
                                        Integer rowIndex = de.getDmlIndex(j)+1; 
                                        LInputRow[j].addError('Row '+rowIndex+': '+de.getDmlMessage(j));
										map_resultTextsByRow.put(rowIndex, de.getDmlMessage(j));
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+'Row '+rowIndex+': '+de.getDmlMessage(j));
                                        LErrorRows.add(LInputRow[j]);
                                    }
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
									if(ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c'){
										tempParent.put('ASI_CRM_Upload_Failed__c',true);
									}
                                    LParentObj.add(tempParent);
                                }
                               
                            }
                            else{
                                string errorText = '';
                                for(Row r : LInputRow){
                                    if(r.hasErrors){
                                        for(string errorMsg :r.errorMsgs) {
                                            if(errorText!='') errorText += '\n';
                                            errorText += 'Row' + String.valueOf(r.rowNumber)+': ' + errorMsg;
											map_resultTextsByRow.put(r.rowNumber, errorMsg);
                                        }
                                    }
                                }
                                if(errorText!='') {
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
								}
                                LAttUpdate.add(att);
                                sObject tempParent = ParentObjType.newSObject();
                                tempParent.put('id',att.parentid);
                                tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
								if(ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c'){
									tempParent.put('ASI_CRM_Upload_Failed__c',true);
								}
                                LParentObj.add(tempParent);
                            }
                        }
                        else{
                            string errorText = '';
                            for(Row r : LInputRow){
                                if(r.hasErrors){
                                    for(string errorMsg :r.errorMsgs) {
                                        if(errorText!='') errorText += '\n';
                                        errorText += 'Row' + String.valueOf(r.rowNumber)+': ' + errorMsg;
										map_resultTextsByRow.put(r.rowNumber, errorMsg);
										errorRowMap.put(r.rowNumber,r.rowNumber);
                                    }
                                }
                            }
                            if(errorText!='')
                                resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                            LAttUpdate.add(att);
                            sObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id',att.parentid);
                            tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
							if(ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c'){
							    
							    try{
								    tempParent.put('ASI_CRM_Upload_Failed__c',true);
							        
							    } catch(SObjectException e) {
							        System.debug(e.getMessage());
							    }
							    
							}
                            LParentObj.add(tempParent);
                           
                        }
                        
                        
                    }
                    //https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/00OM0000000hxi7?pv0=a9yM00000008SGwIAM
                    System.debug(LAttUpdate);
                    if(LAttUpdate != null && LAttUpdate.size()>0){
                        
                        for(Attachment att1: LAttUpdate) {
                            att1.description = resultTexts.get(att.Id).length()>500? resultTexts.get(att.Id).substring(0,500): resultTexts.get(att.Id);
                        }

                        update LAttUpdate;
                    }
                    if(LParentObj != null && LParentObj.size()>0){
                        
                        try{
                            update LParentObj;
                        } catch(DmlException e){
                            System.debug(e.getMessage());
                        } 

                    }
                    
                    
                    if(!hasError){
                        // delete existing offtakes which haven't been confirmed
						if(list_offtakeHeaderToBeOverwritten != null){
							set<string> set_offtakeHeaderIdToBeOverwritten = new set<string>();
							for(ASI_CRM_ActualOfftakeHeader__c a : list_offtakeHeaderToBeOverwritten){
								a.ASI_CRM_All_Offtakes_Removed__c = true;
								set_offtakeHeaderIdToBeOverwritten.add(a.id);
							}
							update list_offtakeHeaderToBeOverwritten;
							delete [select id from ASI_TH_CRM_Actual_Offtake__c where ASI_CRM_ActualOfftakeHeader__c = :set_offtakeHeaderIdToBeOverwritten];
						}
						
						List <Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE  DeveloperName = 'ASI_CRM_Actual_Offtake_MassUpload_Report'];
                        String reportId ='';
                        if(reportList.size()>0){
                            reportId = (String)reportList.get(0).get('Id');
                        }
                        
                        List<Messaging.Email> LEmails = new List<Messaging.Email>();
                        for(Attachment att1 : LAttUpdate){
                            Attachment att2 = att1.clone(false, true, false, false);
							att2.parentID = offtakeHeaderID;
							insert att2;
							
							List<List<String>> attContent = genResults(att1.body);
							
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            string resultText = resultTexts.get(att1.Id);
                            String resultTextHtml = resultText.replace('\n','<br/>');
                            String URLDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.id;
							
							string emailContent = 'Hi '+att1.Owner.Name+', <br/><br/>';
							emailContent += /*(attContent.size()-1) + */'Offtakes have been uploaded successfully. Please note the following batch ID for your reference.<br/><br/>';
							emailContent += 'Batch ID: '+offtakeHeaderName+'<br/>';
							emailContent += 'Report: '+URL.getSalesforceBaseUrl().toExternalForm() +'/'+reportId+'?pv0='+offtakeHeaderName+'<br/><br/><br/>';
							emailContent += 'Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.';
							
                            mail.setHtmlBody(emailContent);
                            //mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded csv: '+ URLDownload);
                            mail.setToAddresses(new List<String>{att1.owner.email});
                            mail.setReplyTo('noreply@salesforce.com');
                            mail.setSenderDisplayName('Pernod Ricard SG SFDC System');
                            mail.setSubject('Completed SG Offtakes Upload (Batch ID: '+offtakeHeaderName+')');
                            
                             List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                   
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();   //Define the email
                            efa.setFileName(att1.Name);  
                            efa.setBody(att1.body);
                            efa.setContentType(att1.contenttype);
                            
                            efaList.add(efa);       
                            
                            if(efaList.size()>0){
                                mail.setFileAttachments(efaList);   
                            }
                            
                            LEmails.add(mail);
                        }
                        if(LEmails.size()>0 && emailNotification){
                            if(!test.isRunningTest()){
                                Messaging.sendEmail(LEmails);
                            }
                        }
                        
                    }else{//**********Faild*************
                            
						if (offtakeHeaderID != '') delete [SELECT id FROM ASI_CRM_ActualOfftakeHeader__c WHERE id = :offtakeHeaderID];
							
                        List<Messaging.Email> LEmails = new List<Messaging.Email>();
                        for(Attachment att1 : LAttUpdate){
                            List<List<String>> attContent = genResults(att1.body);
							
							Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            string resultText = resultTexts.get(att1.Id);
                            String resultTextHtml = resultText.replace('\n','<br/>');
                            String URLDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.id;
							
							string emailContent = 'Hi '+att1.Owner.Name+', <br/><br/>';
							emailContent += /*(attContent.size()-1) + */'Offtakes have NOT been uploaded. Please note the errors on the attachment.<br/><br/>';
							emailContent += 'Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.';
							
                            mail.setHtmlBody(emailContent);
							//mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded csv: '+ URLDownload);
                            mail.setToAddresses(new List<String>{att1.owner.email});
                            mail.setReplyTo('noreply@salesforce.com');
                            mail.setSenderDisplayName('Mass Upload Process');
                            mail.setSubject('Failed SG Offtakes Upload');
							
                             List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                   
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();   //Define the email
                            efa.setFileName(att1.Name);  
                            efa.setBody(appendErrorMsgToCSV(attContent, map_resultTextsByRow));
                            efa.setContentType(att1.contenttype);
                            
							system.debug('map_resultTextsByRow');
							system.debug(map_resultTextsByRow);
							
                            att1.body = appendErrorMsgToCSV(attContent, map_resultTextsByRow);
							att1.description = 'Upload failed. Please refer to the attachment / error log for details.';
                            upsert att1;

                            efaList.add(efa);       
                            
                            if(efaList.size()>0){
                                mail.setFileAttachments(efaList);   
                            }
							
                            LEmails.add(mail);
                        }
                        if(LEmails.size()>0 && emailNotification){
                            if(!test.isRunningTest()){
                                Messaging.sendEmail(LEmails);
                            }
                        }
                        
                        
                        
                    }
                                        
                    
                    
                }
                else{
                    msg = 'Error: Please select csv file only!';
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
	
	private blob appendErrorMsgToCSV(List<List<string>> csvBody, Map<decimal, string> map_resultTextsByRow){
		system.debug(map_resultTextsByRow);
		Integer count = 1;
		string content = '';
		for (List<string> row : csvBody){
			for (string col : row){
				content += col + ',';
			}
			if (count==1 && containsHeader){
				content += 'Error,';
			} else 
			if (map_resultTextsByRow.containsKey((Decimal)errorRowMap.get(count))){
				content += map_resultTextsByRow.get((Decimal)errorRowMap.get(count)) + ',';
			} else {
				content += ',';
			}
			content += '\n';
			count++;
		}
		return blob.valueOf(content);
	}
    
    public void init(){
        
        /*if(inlineVF){
            currentPageUrlOutput = currentPageUrl;
        }
        else*/
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        LFieldAPIName = fields.toLowerCase().split(',',0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',',0);
        if([SELECT id FROM recordType WHERE name = :recordtypeName AND SobjectType = :ObjAPIName].size()>0){
            recordtypid = [SELECT id FROM recordType WHERE name = :recordtypeName AND SobjectType = :ObjAPIName].id;
        }
        MAPINameLabel = new Map<string,string>();
        for(integer i=0;i<LFieldAPIName.size();i++){
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(),LFieldLabel[i].toLowerCase().trim());
        }
        MRecTypeID = new Map<string,id>();
        for(RecordType r: [SELECT id, name, SobjectType FROM RecordType]){
            string key = r.SobjectType+r.name;
            key = key.toLowerCase();
            MRecTypeID.put(key,r.id);
        }
        system.debug('MRecTypeID'+MRecTypeID);
        hasError = false;
        msg = '';
        //MRecTypeDefault = new Map<string,string>();
        LDefaultVales = new List<string>();
        LDefaultValesHeader = new List<string>();
        defaultValuesMap = new Map<String, String>();
        if(String.isNotBlank(defaultValues)){
            List<string> LDefaultValuePair = defaultValues.split(';',0);
            for(String s : LDefaultValuePair){
                List<string> l = s.split(':',0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
                defaultValuesMap.put(l[0],l[1]);
            }
            //MRecTypeDefault.put()
        }

    }
    
    private List<string> addDefaultValues(List<string> ls, boolean isHeader){
        if(isHeader)
            ls.addAll(LDefaultValesHeader);
        else
            ls.addAll(LDefaultVales);
        return ls;
    }
    
    private id matchLookupField(integer pos,List<string> ls, Map<string,integer> mfpos, Map<string,id> MRecTypeID){
        String key = '';
        //LLookupField[pos]
        system.debug('debug LLookupField : '+LLookupField);
        system.debug('mfpos'+mfpos);
        system.debug('ls'+ls);
        system.debug('LLookupField[pos]'+LLookupField[pos]);
        for(string label : LLookupField[pos].MFieldLabelKeyFilter.keySet()){
            system.debug('label '+label+'/'+mfpos.containsKey(label));
            system.debug(label+ 'Testing mfpos '+ mfpos);
            if(mfpos.containsKey(label.toLowerCase())){
                if(label.contains('recordtype')){
                    string tempKey = LLookupField[pos].objectName.toLowerCase() + ls[mfpos.get(label)].toLowerCase();
                    system.debug('MRecTypeID'+MRecTypeID);
                    system.debug('MRecTypeID.containsKey(tempKey)'+tempKey+'/'+MRecTypeID.containsKey(tempKey));
                    if(MRecTypeID.containsKey(tempKey)){
                        key += String.valueOf(MRecTypeID.get(tempKey)).toLowerCase();
                    }
                }
                else{
                    key += ls[mfpos.get(label)].toLowerCase().trim();
                    system.debug('key: '+key);
                }
            }
        }
        system.debug(key);
        return LLookupField[pos].genid(key);
    }
    
    private List<List<String>> genResults(blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null){
            //String fileString = contentFile.toString().toLowerCase();
            //Modify by Steve 20140617
            String fileString = contentFile.toString();
            parsedCSV = parseCSV(fileString, false);
            rowCount = parsedCSV.size();
            for (List<String> row : parsedCSV){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }
            // fill in empty value to make sure col size is the same for each row
            for (List<string> row : parsedCSV){
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

        // remove double spaces
        contents = contents.replaceAll('  ','');



        contents = contents.replaceAll(',"""',',"DBLQT').replaceAll('""",','DBLQT",');
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
        public Map<string,string> MFieldLabel {set;get;}      //Map for header name & field api name
        private string soql {set;get;}
        private List<Set<string>> LkeyFilter;                 //key field values for searching records by soql
        private Map<string,integer> MFieldLabelKeyFilter;     //map for key field to access corresponding set of values for filter in LkeyFilter
        public Map<string,id> MResult;
        public lookupRecord(string input){
            soql = '';
            LkeyFilter = new List<Set<string>>();
            MFieldLabelKeyFilter = new Map<string,integer>();
            MFieldLabel = new Map<string,string>();
            List<string> temp = input.split(':',0);
            if(temp.size()>1){
                List<string> objectinfo = temp[0].split('/',0);
                objectName = objectinfo[0].trim();
                Field = objectinfo[1].trim().toLowerCase();
                for(string s : temp[1].split(',',0)){
                    temp = s.split('&',0);
                    if(temp.size()>1){
                        MFieldLabel.put(temp[0].trim().toLowerCase(),temp[1].trim().toLowerCase());
                        LkeyFilter.add(new Set<String>());
                        MFieldLabelKeyFilter.put(temp[0].trim().toLowerCase(),LkeyFilter.size()-1);
                    }
                }
            }
        }
        public void addKey(List<string> ls, Map<string,integer> Mpos1, Map<string,id> MRecTypeID){
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
        	system.debug('MFieldLabel  queryResult : '+MFieldLabel);
            soql = 'Select id ';
            for(String label : MFieldLabel.keySet()){
                if(MFieldLabel.get(label) != 'id')
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
                     system.debug(MFieldLabel.get(label)  + 'string tony '+ s.replace('\'','\\\'')); //&& MFieldLabel.get(label)=='recordtypeid' &&  Field !=null
                   /*
                    if( objectName!=null && objectName=='ASI_CRM_AccountsAdditionalField__c'  ){
                        soql+='  RecordType.DeveloperName = \'ASI_CRM_SG_Outlet\' or RecordType.DeveloperName = \'ASI_CRM_SG_Wholesaler\'  or ';
                    }
					else 
					if ( objectName!=null && objectName=='ASI_MFM_SKU_Code__c'  ){
						soql+='  RecordType.DeveloperName = \'ASI_CRM_SG_SKU\' or ';
					}
                    else{
                        soql += MFieldLabel.get(label) + ' = \'' + s.replace('\'','\\\'') + '\'  or ';
                    }
					*/
                    soql += MFieldLabel.get(label) + ' = \'' + s.replace('\'','\\\'') + '\'  or ';
                    
                    
                }
                soql = soql.substring(0,soql.length()-5);
                if(LkeyFilter[MFieldLabelKeyFilter.get(label)].size()>0)
                    soql += ' ) ';
                
            }
            
            
            
            system.debug('soql now : '+soql);
            if(test.isRunningTest()){
                soql += ' limit 1';
            }
            
            try{
                
                List<sObject> LResult = database.query(soql);
                system.debug('LResult'+LResult);
                if(LResult != null && LResult.size()>0){
                    MResult = new Map<string,id>();
                    for(sObject s : LResult){
                        string key = '';
                        for(String label : MFieldLabel.keySet()){
                            //system.debug('MFieldLabel.get(label)'+MFieldLabel.get(label));
                            //system.debug('objectName '+objectName);
                            key += s.get(MFieldLabel.get(label));
                        }
                        MResult.put(key.toLowerCase(),s.id);
                    }
                }
                
            } catch(Exception e){
                System.debug(e.getMessage());
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
    
    
    public class Row {
        public Integer rowNumber {set;get;}
        public sObject sObj {set;get;}
        
        private List<string> m_errorMsgs = new List<string>();
        public List<string> errorMsgs { get { return m_errorMsgs; }}
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


}