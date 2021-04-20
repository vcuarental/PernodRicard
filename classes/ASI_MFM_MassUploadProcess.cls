/*********************************************************************************
 * Name: ASI_MFM_MassUploadProcess
 * Test Class: 
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 30/03/2020       Tony Ren               [TR 1.0] Special character handling to avoid lookup error
*/
global class ASI_MFM_MassUploadProcess implements Database.Batchable<sObject>{

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
    public String HeaderId; //Added by Introv for TW CRM FOC/POSM Request Line Uploading @20161111
    
    private Integer rowCount;
    private Integer colCount;

    global ASI_MFM_MassUploadProcess(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
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
        this.HeaderId = currentPageURL; //Added by Introv for TW CRM FOC/POSM Request Line Uploading @20161111
   }
    

    global database.querylocator start(Database.BatchableContext BC){
     // This methods returns a SOQL query locator containing the records
            return Database.getQueryLocator([select id, name, body, description, parentid,owner.email from attachment where id =:AttID]);
     }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope != null){
            init();
            LAttUpdate = new List<Attachment>();
            List<sObject> LParentObj = new List<sObject>();
            map<Id, string> resultTexts = new map<Id, string>();
            
            for(sobject sc : scope){
                Attachment att = (Attachment)sc;                
                att.description = '';
                resultTexts.put(att.Id, '');
                LErrorRows = new list<Row>();
                String namefile = att.name;
                system.debug('namefile'+namefile);
                if(namefile.toLowerCase().right(3)=='csv'){
                    list<list<String>> parsedCSV = genResults(att.body);
                    list<String> LHeader = new list<String>();
                    
                    system.debug('parsedCSV: '+parsedCSV);
                    if(parsedCSV != null && parsedCSV.size()>0){
                        // retrieve header of csv
                        LHeader = addDefaultValues(parsedCSV[0],true);                  
                        parsedCSV.remove(0);
                        
                        system.debug('parsedCSV: '+parsedCSV);
                        system.debug(LHeader); 
                        integer i = 0;
                        for(List<String> LS : parsedCSV){
                            LS = addDefaultValues(LS,false);
                        }
                        MFieldPos = new map<string,integer>();
                        for(string h : LHeader){
                            system.debug('h.toLowerCase().trim():' + h.toLowerCase().trim());
                            //Recognize activity as ac code
                            //modified by andy zhang
                            //20190508
                            if(h.toLowerCase().trim()=='activity'&& ObjAPIName =='ASI_MFM_Budget__c'&& (recordtypeName == 'VN DP Budget'||recordtypeName == 'VN DF Budget')){
                                h = 'A/C';
                            }
                            string strText ='';
                            if(ObjAPIName =='ASI_CRM_JP_Customer_Product_Price__c' ){ //[TR 1.0]
                                strText = h.toLowerCase().trim().replaceAll('[^a-zA-Z0-9\\s+]', '');
                            }else{
                                strText = h.toLowerCase().trim();
                            }
                            MFieldPos.put(strText,i);
                            i++;
                            system.debug('MFieldPos' + MFieldPos + h);
                        }
                        
                        LLookupField = new list<lookupRecord>();
                        MLookupFieldPos = new map<string,integer>();
                        //system.debug('lookupEXID' +lookupEXID);
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
                        system.debug(LLookupField);
                        
                        
                        system.debug(MFieldPos);
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
                        
                        system.debug('parsedCSV: '+parsedCSV);
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
                                system.debug('MAPINameLabel.get(fieldname)' + MAPINameLabel.get(fieldname));
                                system.debug('MFieldPos'+MFieldPos);
                                system.debug('MFieldPosLabel'+labelname+MFieldPos.containsKey(labelname));
                                system.debug('MLookupFieldPos'+MLookupFieldPos);
                                system.debug('label'+labelname+'/'+MLookupFieldPos.containsKey(fieldname));
                                if(MLookupFieldPos.containsKey(fieldname)){
                                    system.debug('Lookup Field 1:' + fieldname);
                                    system.debug('MLookupFieldPos '+MLookupFieldPos);
                                    system.debug('MLookupFieldPos.get(fieldname)'+MLookupFieldPos.get(fieldname));
                                    if(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID) == null){
                                        system.debug('Lookup Field 2 :' + fieldname);
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
                                else if(MFieldPos.containsKey(labelname) && LS[MFieldPos.get(labelname)] != null && LS[MFieldPos.get(labelname)] != ''){
                                    system.debug('Non-Lookup Field:' + fieldname);
                                    system.debug('MFieldPos'+MFieldPos);
                                    system.debug(MFieldPos.get(labelname));
                                    system.debug(ObjType);
                                    //system.debug(ObjType.getDescribe().fields.getMap().get(labelname));
                                    //system.debug(ObjType.getDescribe().fields.getMap().get(labelname).getDescribe().getType().name());
                                    if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);
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
                                                if(dateText.contains('/') || dateText.contains('-') || dateText.length()!=8){
                                                    try{
                                                        r.sObj.put(fieldname, date.valueof(dateText));
                                                        date.valueof(dateText).addMonths(1);
                                                        System.debug(date.valueof(dateText).addMonths(1));
                                                    }
                                                    catch(exception e){
                                                        r.addError(Labelname + ': ' + e.getMessage());
                                                        hasError = true;
                                                    }
                                                }
                                                else {
                                                    r.sObj.put(fieldname, date.newInstance(integer.valueOf(dateText.subString(0,4)), integer.valueOf(dateText.subString(4,6)), integer.valueOf(dateText.subString(6,8))));
                                                }
                                            }
                                            catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                        //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='double' ||
                                        //    ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='percent' ||
                                        //    ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='currency'
                                        //){
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
                            //Added by Twinkle LI @Introv #20160505 - TH WS/SIT offtake
                            else{
                                if(ObjAPIName == 'ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c'){
                                    r.addError('Missing External Id.');
                                    hasError = true;
                                }
                            }
                            System.debug(tempEXIDvalue);
                            LInputRow.add(r);
                            System.debug(r);
                        }
                        list<sObject> lRecInsert = new list<sobject>();
                        if(!hasError || upsertMode){
                            for(Row r : LInputRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                            }
                            system.debug('lRecInsert:'+lRecInsert);
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    List<Database.upsertResult> uResults = new List<Database.upsertResult>();
                                    List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
                                    
                                    if(upsertMode || test.isrunningTest()){
                                        system.debug('ObjAPIName: '+ObjAPIName);
                                        // Hard Code for Casting before upsert
                                        if(ObjAPIName == 'ASI_MFM_Event_Outlet__c'){
                                            List<ASI_MFM_Event_Outlet__c> LUpsert = new List<ASI_MFM_Event_Outlet__c>();
                                            for(sObject s : lRecInsert){
                                                LUpsert.add((ASI_MFM_Event_Outlet__c)s);
                                            }
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            system.debug(LUpsert);
                                        }else if(ObjAPIName == 'ASI_KOR_POSM_Order_Request__c'){
                                            List<ASI_KOR_POSM_Order_Request__c> LUpsert = new List<ASI_KOR_POSM_Order_Request__c>();
                                            for(sObject s : lRecInsert){
                                                LUpsert.add((ASI_KOR_POSM_Order_Request__c)s);
                                            }
                                            system.debug('Test KOR upload '+ObjType.getDescribe().fields.getMap().get(recEXIDcol));
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            system.debug('Test uResults KOR'+LUpsert);
                                        }
                                        //KAMMY PVA OBJECT:
                                       /*
                                       else if(ObjAPIName == 'ASI_CRM_KR_PVA__c'){   
                                            List<ASI_CRM_KR_PVA__c> LUpsert = new List<ASI_CRM_KR_PVA__c>();
                                            for(sObject s : lRecInsert){
                                                LUpsert.add((ASI_CRM_KR_PVA__c)s);
                                            }
                                            system.debug('Test KOR upload '+ObjType.getDescribe().fields.getMap().get(recEXIDcol));
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            system.debug('Test uResults KOR'+LUpsert);
                                        }
                                        */
                                        //KAMMY PVA OBJECT:
                                        else if(ObjAPIName == 'ASI_CRM_KR_PVA__c'){
                                            List<ASI_CRM_KR_PVA__c> LUpsert = new List<ASI_CRM_KR_PVA__c>();
                                            //Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_CRM_KR_PVA__c item = (ASI_CRM_KR_PVA__c)s;
                                                
                                               // if (((ASI_CRM_KR_PVA__c)s).ASI_CRM_KR_External_ID_Upload__c == null || ((ASI_CRM_KR_PVA__c)s).ASI_CRM_KR_External_ID_Upload__c == ''){
                                                    //item.ASI_CRM_KR_External_ID_Upload__c= item.ASI_CRM_KR_Account_Code__c +'&'+ item.ASI_CRM_KR_Brand__c;
                                                   // randomKey++;
                                               // }  
                                                
                                                if(((ASI_CRM_KR_PVA__c)s).ASI_CRM_KR_PVA__c =='P' || ((ASI_CRM_KR_PVA__c)s).ASI_CRM_KR_PVA__c =='V' || ((ASI_CRM_KR_PVA__c)s).ASI_CRM_KR_PVA__c =='A'){
                                                System.debug('item.ASI_CRM_KR_External_ID_Upload__c' + item.ASI_CRM_KR_External_ID_Upload__c);  
                                                LUpsert.add(item);
                                                }
                                                else
                                                {
                                               
                                                }
                                               
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        //KAMMY ASI_CRM_KR_A_P_Guideline OBJECT:
                                        else if(ObjAPIName == 'ASI_CRM_KR_A_P_Guideline__c'){
                                            List<ASI_CRM_KR_A_P_Guideline__c> LUpsert = new List<ASI_CRM_KR_A_P_Guideline__c>();
                                            //Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_CRM_KR_A_P_Guideline__c item = (ASI_CRM_KR_A_P_Guideline__c)s;
                                              //  if (((ASI_CRM_KR_A_P_Guideline__c)s).ASI_CRM_KR_External_ID_Upload__c == null || ((ASI_CRM_KR_A_P_Guideline__c)s).ASI_CRM_KR_External_ID_Upload__c == ''){
                                                    //item.ASI_CRM_KR_External_ID_Upload__c= item.ASI_CRM_KR_Account_Code__c +'&'+ item.ASI_CRM_KR_Activity_Type__c + '&' + item.ASI_CRM_KR_Brand__c;
                                                   // randomKey++;
                                              //  }  
                                                System.debug('item.ASI_CRM_KR_External_ID_Upload__c' + item.ASI_CRM_KR_External_ID_Upload__c);
                                                LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol));   
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        
                                                                             
                                          
                                                                                         
                                                                                                                    
                                            
                                                                        
                                                                                                      
                                                
                                                                                                                                                                                                                           

                                                                                                                                            
                                                                      
                                                
                                               
                                                                                                                                                                           
                                                                                                                                                    
                                                                  
                                         
                                          
                                        else if(ObjAPIName == 'ASI_MFM_plan__c'){
                                            List<ASI_MFM_Plan__c> LUpsert = new List<ASI_MFM_Plan__c>();
                                            for(sObject s : lRecInsert){
                                                LUpsert.add((ASI_MFM_Plan__c)s);
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
                                                
                                            }
                                        }
                                        else if(ObjAPIName == 'ASI_MFM_Plan_Line_Item__c'){
                                            List<ASI_MFM_Plan_Line_Item__c> LUpsert = new List<ASI_MFM_Plan_Line_Item__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                //Special Handling to clear plan line amount
                                                ASI_MFM_Plan_Line_Item__c item = (ASI_MFM_Plan_Line_Item__c)s;
                                                if (recordtypeName !='TH Plan Line Item' && recordtypeName !='SG Plan Line Item' ){  
                                                    item.ASI_MFM_Total_Cost__c = null;
                                                }
                                                //System.debug(s.ASI_MFM_Plan_External_ID_Upload__c );
                                                //((ASI_MFM_Plan_Line_Item__c)s).ASI_MFM_TR_Rec_Type__c = '';
                                                if (((ASI_MFM_Plan_Line_Item__c)s).ASI_MFM_Plan_Line_Item_External_IDUpload__c == null || ((ASI_MFM_Plan_Line_Item__c)s).ASI_MFM_Plan_Line_Item_External_IDUpload__c == ''){
                                                    item.ASI_MFM_Plan_Line_Item_External_IDUpload__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol));
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                             
                                        }
                                        else if(ObjAPIName == 'ASI_MFM_PO_Line_Item__c'){
                                            List<ASI_MFM_PO_Line_Item__c> LUpsert = new List<ASI_MFM_PO_Line_Item__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_PO_Line_Item__c item = (ASI_MFM_PO_Line_Item__c)s;
                                                if (((ASI_MFM_PO_Line_Item__c)s).ASI_MFM_PO_Line_Item_External_IDUpload__c == null || ((ASI_MFM_PO_Line_Item__c)s).ASI_MFM_PO_Line_Item_External_IDUpload__c == ''){
                                                    item.ASI_MFM_PO_Line_Item_External_IDUpload__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('item.ASI_MFM_PO_Line_Item_External_IDUpload__c' + item.ASI_MFM_PO_Line_Item_External_IDUpload__c);
                                                LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        else if(ObjAPIName == 'ASI_MFM_Budget__c'){
                                            List<ASI_MFM_Budget__c> LUpsert = new List<ASI_MFM_Budget__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_Budget__c item = (ASI_MFM_Budget__c)s;
                                                if (((ASI_MFM_Budget__c)s).ASI_MFM_Budget_External_ID__c == null || ((ASI_MFM_Budget__c)s).ASI_MFM_Budget_External_ID__c == ''){
                                                    item.ASI_MFM_Budget_External_ID__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('item.ASI_MFM_Budget_External_ID__c' + item.ASI_MFM_Budget_External_ID__c);
                                                LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        else if(ObjAPIName == 'ASI_CRM_WS_Target__c'){
                                            //Upsert for MY CRM
                                            List<ASI_CRM_WS_Target__c> LUpsert = new List<ASI_CRM_WS_Target__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_CRM_WS_Target__c item = (ASI_CRM_WS_Target__c)s;
                                                if (((ASI_CRM_WS_Target__c)s).ASI_CRM_External_ID__c == null || ((ASI_CRM_WS_Target__c)s).ASI_CRM_External_ID__c == ''){
                                                    item.ASI_CRM_External_ID__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('Upsert ASI_CRM_WS_Target__c, empty external ID in ASI_CRM_External_ID__c field, randomly generated key: ' + item.ASI_CRM_External_ID__c);
                                                LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        else if(ObjAPIName == 'ASI_CRM_Budget__c'){
                                            //Upsert for SG CRM
                                            List<ASI_CRM_Budget__c> LUpsert = new List<ASI_CRM_Budget__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_CRM_Budget__c item = (ASI_CRM_Budget__c)s;
                                                if (((ASI_CRM_Budget__c)s).ASI_CRM_External_Key__c == null || ((ASI_CRM_Budget__c)s).ASI_CRM_External_Key__c == ''){
                                                    item.ASI_CRM_External_Key__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('Upsert ASI_CRM_Budget__c, empty external ID in ASI_CRM_External_Key__c field, randomly generated key: ' + item.ASI_CRM_External_Key__c);
                                                	LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        //Added by Introv for TW CRM FOC Request Line Upload @20161111
                                        else if(ObjAPIName == 'ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c'){
                                            //Upsert for TH CRM
                                            List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> LUpsert = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c item = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c)s;
                                                /*if (((ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c)s).ASI_TH_CRM_OfftakeSITDetail_External_ID__c == null || ((ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c)s).ASI_TH_CRM_OfftakeSITDetail_External_ID__c == ''){
                                                    item.ASI_TH_CRM_OfftakeSITDetail_External_ID__c = String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }*/
                                                System.debug('Upsert ASI_TH_CRM_Offtake_Stock_In_Trade__c, empty external ID in ASI_TH_CRM_OfftakeSITDetail_External_ID__c field, randomly generated key: ' + item.ASI_TH_CRM_OfftakeSITDetail_External_ID__c);
                                                	LUpsert.add(item);
                                            }
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                        }
                                        else if(ObjAPIName == 'ASI_FOC_Request_Item__c'){
                                            List<ASI_FOC_Request_Item__c> LUpsert = new List<ASI_FOC_Request_Item__c>();
                                            Integer randomKey = lRecInsert.size();
                                            for(sObject s : lRecInsert){
                                                ASI_FOC_Request_Item__c item = (ASI_FOC_Request_Item__c)s;
                                                item.ASI_FOC_Request_Order__c = HeaderId;
                                                if (((ASI_FOC_Request_Item__c)s).ASI_FOC_Sys_Unique_Key__c == null || ((ASI_FOC_Request_Item__c)s).ASI_FOC_Sys_Unique_Key__c == ''){
                                                    item.ASI_FOC_Sys_Unique_Key__c = String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('item.ASI_FOC_Sys_Unique_Key__c' + item.ASI_FOC_Sys_Unique_Key__c);
                                                LUpsert.add(item);
                                            }
                                            System.debug('opt_allOrNone:'+opt_allOrNone); //Added by Introv @20170214
                                            System.debug('recEXIDcol: '+recEXIDcol);
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol): ' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            System.debug(LUpsert);
                                            System.debug('Results:'+uResults); //Added by Introv @20170214
                                        }
                                        //End by Introv for TW CRM FOC Request Line Upload @20161111
                                        
                                        //Schema.SObjectField f = ObjType.getDescribe().fields.getMap().get(recEXIDcol);
                                        //upsert (List<ASI_MFM_Event_Outlet__c>)lRecInsert ASI_MFM_EXID__c;
                                    }
                                    else {
                                        //Added by Wilken on 20150113 Add Insert Result to VF page display
                                        insertResults = Database.insert(lRecInsert, opt_allOrNone);
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
                                                validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
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
                                                validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                        }
                                    }
                                    
                                    msg = 'Import Completed! ' + string.valueof(succInsert) + ' record(s) created.\n';
                                    msg += '' + string.valueof(succUpdate) + ' record(s) updated.\n';
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
                                        msg += errorText;
                                    resultTexts.put(att.Id, msg);
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,att.description);
                                    LParentObj.add(tempParent);
                                    //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));
                                    /*if(inlineVF)
                                        refreshPage2();
                                    else
                                        refreshPage();*/
                                }
                                catch(dmlexception de){
                                    hasError = true;
                                    
                                    for(integer j =0;j<de.getNumDml();j++){
                                        //debug += 'fieldname: ' + e.getDmlFieldNames(j)+'|';
                                        //debug += 'index: ' + e.getDmlIndex(j)+'|';
                                        
                                        Integer rowIndex = de.getDmlIndex(j)+1; //Added by Introv @20170216
                                        
                                        LInputRow[j].addError('Row '+rowIndex+': '+de.getDmlMessage(j));
                                        //att.description += e.getDmlMessage(j) + '\n';
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+'Row '+rowIndex+': '+de.getDmlMessage(j));
                                        LErrorRows.add(LInputRow[j]);
                                        //debug += 'statuscode: ' + e.getDmlStatusCode(j)+'|';
                                        
                                    }
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
                                    //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));
                                    
                                }
                            
                                                     
                                                            
                                                    
                                                             
                                    
                                                                                                         
                                                                 
                                             
                                                        
                                                                                    
                                                                      
                                                                                                                                                                                        
                                                               
                                                                                                                                        
                                    
                                                     
                                   
                            }
                            else{
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
                        }
                        else{
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
                            //LParentObj.add(new ASI_MFM_Event__c(id=att.parentid,ASI_MFM_Event_Outlet_Msg__c=att.description));
                        }
                        
                        
                    }
                    System.debug(LAttUpdate);
                    if(LAttUpdate != null && LAttUpdate.size()>0){
                        
                        for(Attachment att1: LAttUpdate) {
                            att1.description = resultTexts.get(att.Id).length()>500? resultTexts.get(att.Id).substring(0,500): resultTexts.get(att.Id);
                        }

                        update LAttUpdate;
                    }
                    if(LParentObj != null && LParentObj.size()>0){
                        if(!test.isRunningTest())
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
                }
                else{
                    msg = 'Error: Please select csv file only!';
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
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
        if([select id from recordType where name = :recordtypeName and SobjectType = :ObjAPIName].size()>0){
            recordtypid = [select id from recordType where name = :recordtypeName and SobjectType = :ObjAPIName].id;
        }
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
        //MRecTypeDefault = new Map<string,string>();
        LDefaultVales = new list<string>();
        LDefaultValesHeader = new list<string>();
        if(defaultValues != null && defaultValues != ''){
            list<string> LDefaultValuePair = defaultValues.split(';',0);
            for(String s : LDefaultValuePair){
                list<string> l = s.split(':',0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
            //MRecTypeDefault.put()
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
                           
                                                           
                                    
                              
                                                            
        for(string label : LLookupField[pos].MFieldLabelKeyFilter.keySet()){
            system.debug('label now '+label+'/ : '+mfpos.containsKey(label.toLowerCase()) + ' ^^ '+mfpos.containsKey(label.toLowerCase().trim()));
            system.debug(label+ 'Testing mfpos '+ mfpos);
            if(mfpos.containsKey(label.toLowerCase())){
                system.debug('enter 1');
                if(label.contains('recordtype')){
                    system.debug('enter 2');
                    string tempKey = LLookupField[pos].objectName.toLowerCase() + ls[mfpos.get(label)].toLowerCase();
                    system.debug('MRecTypeID'+MRecTypeID);
                    system.debug('MRecTypeID.containsKey(tempKey)'+tempKey+'/'+MRecTypeID.containsKey(tempKey));
                    if(MRecTypeID.containsKey(tempKey)){
                        key += String.valueof(MRecTypeID.get(tempKey)).toLowerCase();
                    }
                }
                else{
                    system.debug('enter 3' + mfpos.get(label));
                    key += ls[mfpos.get(label)].toLowerCase().trim();
                    system.debug('key: '+key);
                }
            }
        }
        system.debug('Now 1.0 Key'+key);
        system.debug('************LLookupField[pos].genid(key)**********************');
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
                if(MFieldLabel.get(label) != 'id') //Added by Introv for TW CRM @20161111(if lookup by id, not external key; to avoiding duplicated Id selected)
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
            system.debug('soql'+soql);
            if(test.isRunningTest()){
                soql += ' limit 1';
            }
            list<sObject> LResult = database.query(soql);
            system.debug('LResult'+LResult);
            if(LResult != null && LResult.size()>0){
                MResult = new map<string,id>();
                for(sObject s : LResult){
                    string key = '';
                    for(String label : MFieldLabel.keySet()){
                        system.debug('MFieldLabel.get(label)'+MFieldLabel.get(label));
                        
                        key += s.get(MFieldLabel.get(label));
                        system.debug(key + ' Key  objectName '+objectName + '             s.id : ' +s.id );
                    }
                    MResult.put(key.toLowerCase(),s.id);
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


}