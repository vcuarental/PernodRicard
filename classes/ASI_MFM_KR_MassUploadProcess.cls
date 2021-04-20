Public with sharing class ASI_MFM_KR_MassUploadProcess implements Database.Batchable<sObject>{
    
    public final String ObjAPIName;
    public final String Activatetype;
    public final String parentID;
    public final String parentField;
    public final String fields;
    public final String fieldsLabel;
    public final String lookupEXID;
    public final String template;
    public final String recordtypeName;
    public final String currentPageURL;
    public final String defaultValues;
    public final String AttID;
    public final string recEXID {set;get;}
    public final string recEXIDcol {set;get;} 
    public final string parentObjectAPIName {set;get;}
    public final string ParentObjectUploadMsg {set;get;}
    public final boolean upsertMode {set;get;}
    public final boolean batchMode {set;get;}
    public final boolean opt_allOrNone {set;get;}
    public final boolean emailNotification {set;get;}
    public List<Attachment> LAttUpdate;
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
    public string MsgAddOn {set;get;}{MsgAddOn='';}
    public Map<string, String> MsgAddOnList {set;get;}{MsgAddOnList=new Map<String, String>();}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    private list<string> LEXIDFieldLabel;
    private Integer rowCount;
    private Integer colCount;
    public String HeaderId;
    
    Public Boolean isOffsetPayment{Get; Set;}//20180111 Introv
    
    public ASI_MFM_KR_MassUploadProcess(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
                                        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
                                        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone,string Activatetype,String HeaderId){
                                            this.ObjAPIName = ObjAPIName;
                                            this.currentPageURL=currentPageURL;
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
                                            this.Activatetype=Activatetype;
                                            this.HeaderId=HeaderId;
                                            this.isOffsetPayment = False;
                                        }
    
    //20180111 Introv
    public ASI_MFM_KR_MassUploadProcess(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
                                        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
                                        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone,string Activatetype,String HeaderId, Boolean isOffsetPayment){
                                            this.ObjAPIName = ObjAPIName;
                                            this.currentPageURL=currentPageURL;
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
                                            this.Activatetype=Activatetype;
                                            this.HeaderId=HeaderId;
                                            this.isOffsetPayment = isOffsetPayment;
                                        }
    
    
    public database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([select id, name, body, description, parentid,owner.email from attachment where id =:AttID]);
    }
    // The executeBatch method is called for each chunk of records returned from start.    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
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
                    
                    if(parsedCSV != null && parsedCSV.size()>0){
                        // retrieve header of csv
                        LHeader = addDefaultValues(parsedCSV[0],true);                  
                        parsedCSV.remove(0);
                        system.debug(LHeader);
                        integer i = 0;
                        for(List<String> LS : parsedCSV){
                            LS = addDefaultValues(LS,false);
                        }
                        MFieldPos = new map<string,integer>();
                        for(string h : LHeader){
                            system.debug('h.toLowerCase().trim() ' + h.toLowerCase().trim());
                            MFieldPos.put(h.toLowerCase().trim(),i);
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
                        
                        for(List<String> LS : parsedCSV){
                            Row r;                                          
                            if (parentField!= null && parentID!= null)
                                r = new row(ObjType.newSObject(), parentField, parentID);
                            else r = new row(ObjType.newSObject());
                            // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                            
                            if(recordtypid != null){ r.sObj.put('recordtypeid',recordtypid);}
                            Integer inputCol = 0;
                            //system.debug(LS);
                            
                            //system.debug('LFieldAPIName' + LFieldAPIName);
                            for(string fieldname : LFieldAPIName){
                                string labelname = MAPINameLabel.get(fieldname);
                                
                                for(string k:MFieldPos.keySet()){
                                    system.debug(MFieldPos.get(k)+'MFieldPos Testing 1.0.1' +k);
                                }
                                                                
                                system.debug('MAPINameLabel.get(fieldname)' + MAPINameLabel.get(fieldname));
                                system.debug('MFieldPos'+MFieldPos);
                                system.debug('MFieldPosLabel 1.2.0'+labelname+MFieldPos.containsKey(labelname));
                                system.debug('MLookupFieldPos'+MLookupFieldPos);
                                system.debug(fieldname+'label'+labelname+'/'+MLookupFieldPos.containsKey(fieldname));
                                system.debug(LS);
                                system.debug(labelname.toLowerCase().trim()+'Testing 1.1.0 : '+MFieldPos.get(labelname.toLowerCase().trim()) );
                                if(MLookupFieldPos.containsKey(fieldname)){
                                    system.debug(MFieldPos.get(labelname)+' TestLookup Field:' + fieldname);//ls[mfpos.get(label)] customer 
                                    system.debug(LS[MFieldPos.get(labelname)]+' TestMLookupFieldPos '+MLookupFieldPos);
                                    system.debug(' TestMLookupFieldPos.get(fieldname)'+MLookupFieldPos.get(fieldname));                                    
                                    if(fieldname =='asi_mfm_venue_where__c' || fieldname =='asi_mfm_accountsadditionalfield__c' || fieldname =='ASI_MFM_Where_Customer__c' || fieldname =='ASI_MFM_Beneficiary_Customer__c' ){ //for customer look up 
                                        if(LS[MFieldPos.get(labelname)]!='' && matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID) == null){
                                            r.addError(labelname + ' :  Cannot find record'+LS[MFieldPos.get(labelname)]);
                                            hasError = true;
                                        }
                                        try{
                                            if(LS[MFieldPos.get(labelname)]!=''){
                                                r.sObj.put(fieldname, matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                            }
                                            
                                        }
                                        catch(exception e){
                                            r.addError(labelname + ': Cannot find record');
                                            hasError = true;
                                        } 
                                        
                                    }else{
                                        if(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID) == null){
                                            if(ObjAPIName != 'ASI_MFM_Purchase_Request_Line__c' && fieldname !='asi_mfm_basic_posm__c'){
                                                system.debug(matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                                r.addError(labelname + ' :  Cannot find record');
                                                //system.assertEquals(null, labelname);
                                                hasError = true;
                                            }
                                        }
                                        try{
                                            r.sObj.put(fieldname, matchLookupField(MLookupFieldPos.get(fieldname),LS,MFieldPos, MRecTypeID));
                                        }
                                        catch(exception e){
                                            r.addError(labelname + ': Cannot find record');
                                            hasError = true;
                                        } 
                                    }
                                }
                                else if(MFieldPos.containsKey(labelname) && LS[MFieldPos.get(labelname)] != null && LS[MFieldPos.get(labelname)] != ''){
                                    system.debug('MFieldPos'+MFieldPos);
                                    system.debug(MFieldPos.get(labelname));
                                    system.debug(ObjType);
                                    //system.debug(ObjType.getDescribe().fields.getMap().get(labelname));//system.debug('Activatetype Test :  '+Activatetype);//system.debug(ObjType.getDescribe().fields.getMap().get(labelname).getDescribe().getType().name());
                                    if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);
                                        
                                        if(fieldname=='asi_mfm_type__c'&& ObjAPIName=='ASI_MFM_Budget__c' && tempFieldType=='picklist'){
                                            Map<String, Integer> TypeMap = new Map<String, Integer>{'Original Budget'=>1,'Budget'=>2,'LE1'=>3,'LE2'=>4,'LE3'=>5,'LE4'=>6}; //system.debug(TypeMap+'Testr'+TypeMap.get(Activatetype)+'Value: Now : '+LS[MFieldPos.get(labelname)]);
                                                if(TypeMap.containsKey(LS[MFieldPos.get(labelname)])){
                                                    
                                                }else{
                                                    r.addError(labelname + ': Budget Type is wrong');
                                                    hasError = true;
                                                }
                                        }
                                        system.debug(ObjAPIName+'Activatetype'+Activatetype+'MFieldType Now: '+MFieldType);
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
                                                if(dateText.contains('/') || dateText.contains('-') || dateText.contains('.')  || dateText.length()!=8){
                                                    if(ObjAPIName == 'ASI_MFM_Purchase_Request_Line__c' || ObjAPIName == 'ASI_MFM_Payment_Line_Item__c' ){
                                                        try{
                                                            if(dateText.contains('/') ){
                                                                List<String> parts =dateText.split('/');
                                                                dateText=parts[2]+'-'+parts[0]+'-'+parts[1];
                                                            }
                                                            
                                                            
                                                            r.sObj.put(fieldname, date.valueof(dateText));
                                                            date.valueof(dateText).addMonths(1);
                                                            System.debug(date.valueof(dateText).addMonths(1));
                                                        }
                                                        catch(exception e){
                                                            r.addError(Labelname + ':' + e.getMessage());
                                                            hasError = true;
                                                        }
                                                        
                                                    }else if (ObjAPIName == 'ASI_MFM_Plan__c' &&  dateText.contains('.')  ){
                                                        try{
                                                            List<String> parts =dateText.split('\\.');
                                                            dateText= parts[0]+'-'+parts[1]+'-'+parts[2];
                                                            
                                                            r.sObj.put(fieldname, date.valueof(dateText));
                                                            date.valueof(dateText).addMonths(1);
                                                            System.debug(date.valueof(dateText).addMonths(1));
                                                        }
                                                        catch(exception e){
                                                            r.addError(Labelname + dateText+':' + e.getMessage());
                                                            hasError = true;
                                                        }
                                                        
                                                    }else{
                                                        try{
                                                            r.sObj.put(fieldname, date.valueof(dateText));
                                                            date.valueof(dateText).addMonths(1);
                                                            System.debug(date.valueof(dateText).addMonths(1));
                                                        }
                                                        catch(exception e){
                                                            r.addError(Labelname + ':' + e.getMessage());
                                                            hasError = true;
                                                        }
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
                                        
                                        else if(tempFieldType=='double' || tempFieldType=='percent' || tempFieldType=='currency'){
                                            try{r.sObj.put(fieldname, decimal.valueof(LS[MFieldPos.get(labelname)]));}
                                            catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                        //else if(ObjType.getDescribe().fields.getMap().get(fieldname).getDescribe().getType().name().toLowerCase()=='integer'){
                                        else if(tempFieldType=='integer'){
                                            try{r.sObj.put(fieldname, integer.valueof(LS[MFieldPos.get(labelname)]));}
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
                            System.debug(r);
                        }
                        list<sObject> lRecInsert = new list<sobject>();
                        if(!hasError || upsertMode){
                            for(Row r : LInputRow){
                                if(!r.hasErrors || Test.isRunningTest() ){
                                    lRecInsert.add(r.sObj);
                                }
                            }
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    List<Database.upsertResult> uResults = new List<Database.upsertResult>();
                                    if(upsertMode){
                                        // Hard Code for Casting before upsert
                                        //Commented by Kammy at 24 Mar 2016 ------- KR CRM Object   
                                        
                                        if(ObjAPIName == 'ASI_KOR_POSM_Order_Request__c'){
                                            List<ASI_KOR_POSM_Order_Request__c> LUpsert = new List<ASI_KOR_POSM_Order_Request__c>();
                                            for(sObject s : lRecInsert){
                                                LUpsert.add((ASI_KOR_POSM_Order_Request__c)s);
                                            }
                                            uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            
                                        }
                                        
                                        else if(ObjAPIName == 'ASI_MFM_plan__c'){
                                            List<ASI_MFM_Plan__c> LUpsert = new List<ASI_MFM_Plan__c>();
                                            Integer randomKey = lRecInsert.size();
                                            Integer KRrandomKey = lRecInsert.size();
                                            Integer indexNum = 0;
                                            
                                            set<Id> PCCodeSet = new set<Id>();
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_Plan__c NewPlan = (ASI_MFM_Plan__c)s;
                                                if (((ASI_MFM_Plan__c)s).ASI_MFM_Plan_External_ID_Upload__c == null || ((ASI_MFM_Plan__c)s).ASI_MFM_Plan_External_ID_Upload__c == ''){
                                                    NewPlan.ASI_MFM_Plan_External_ID_Upload__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                
                                                if(recordtypeName=='KR Plan'){
                                                    
                                                    if(NewPlan.ASI_MFM_Project_Code__c==null){
                                                        LInputRow[indexNum].addError('Project Code cannot be blank.');
                                                        hasError = true;
                                                    }
                                                    
                                                    if(NewPlan.ASI_MFM_Project_Code__c!=null){
                                                        
                                                        if(NewPlan.ASI_MFM_Promotion_Code__c == null || NewPlan.ASI_MFM_Promotion_Code__c ==''){
                                                            NewPlan.ASI_MFM_Promotion_Code__c= String.valueOf(Datetime.now())+ randomKey;
                                                            KRrandomKey++; 
                                                        }
                                                        
                                                        try{
                                                            
                                                            PCCodeSet.add(NewPlan.ASI_MFM_Project_Code__c);//system.debug('Test New Plan '+NewPlan);
                                                        }catch(exception e){
                                                            LInputRow[indexNum].addError('Project Code is invalid.');
                                                            hasError = true;
                                                        }
                                                    }
                                                }
                                                LUpsert.add(NewPlan);
                                                indexNum++;
                                            }
                                            
                                            if(PCCodeSet!=null && PCCodeSet.size() >0 && !hasError){
                                                LUpsert=SelectPrefix(LUpsert,PCCodeSet);
                                            }
                                            
                                            if(!hasError){
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            }
                                        }
                                        else if(ObjAPIName == 'ASI_MFM_Purchase_Request_Line__c'){//system.debug('Test enter ASI_MFM_Purchase_Request_Line__c  ');
                                            List<ASI_MFM_Purchase_Request_Line__c> LUpsert = new List<ASI_MFM_Purchase_Request_Line__c>();
                                            Integer randomKey = lRecInsert.size();
                                            integer cum=0;
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_Purchase_Request_Line__c item = (ASI_MFM_Purchase_Request_Line__c)s;
                                                item.ASI_MFM_Purchase_Request__c=HeaderId;//HeaderId
                                                IF(item.ASI_MFM_Plan_Line_Item__c==null){
                                                    LInputRow[cum].addError('Please input Plan line.');
                                                    hasError = true;
                                                }
                                                if (((ASI_MFM_Purchase_Request_Line__c)s).ASI_MFM_PurchaseRequests_Line_ExternalID__c == null || ((ASI_MFM_Purchase_Request_Line__c)s).ASI_MFM_PurchaseRequests_Line_ExternalID__c == ''){
                                                    item.ASI_MFM_PurchaseRequests_Line_ExternalID__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                LUpsert.add(item);
                                                cum++;
                                            }//system.debug('Test------------');
                                            system.debug(LUpsert);
                                            if(!hasError){
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            }
                                        }
                                        
                                        else if(ObjAPIName == 'ASI_MFM_Plan_Line_Item__c'){
                                            List<ASI_MFM_Plan_Line_Item__c> LUpsert = new List<ASI_MFM_Plan_Line_Item__c>();
                                            Integer randomKey = lRecInsert.size();
                                            Set<String> APCodeSet = new Set<String>();
                                            for(sObject s : lRecInsert){
                                                
                                                ASI_MFM_Plan_Line_Item__c item = (ASI_MFM_Plan_Line_Item__c)s;//insert new ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Error_Message__c=String.valueOf(item) ,ASI_MFM_Configuration__c='!!!'); System.debug('ASI_MFM_Plan_Line_Item__c !@3: '+ item );
                                                item.ASI_MFM_Actual_Spending_Amount__c=0;
                                                //item=CalPlanLineAmount(item); Commented by Elufa PRA Support on 9th Feb 2017
                                                if(item.ASI_MFM_AP_Code__c!=null){
                                                    APCodeSet.add(String.valueOf(item.ASI_MFM_AP_Code__c));
                                                }//if(item.ASI_MFM_Plan_Line_Item_External_IDUpload__c== null || item.ASI_MFM_Plan_Line_Item_External_IDUpload__c==''){
                                                
                                                if (((ASI_MFM_Plan_Line_Item__c)s).ASI_MFM_Plan_Line_Item_External_IDUpload__c == null || ((ASI_MFM_Plan_Line_Item__c)s).ASI_MFM_Plan_Line_Item_External_IDUpload__c == ''){
                                                    item.ASI_MFM_Plan_Line_Item_External_IDUpload__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                LUpsert.add(item);
                                            }// System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol));//System.debug(LUpsert);
                                            
                                            
                                            LUpsert=MapACCodePL(LUpsert,APCodeSet);
                                            if(!hasError){
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            }
                                            
                                        }
                                        else if(ObjAPIName == 'ASI_MFM_Payment_Line_Item__c'){
                                            List<ASI_MFM_Payment_Line_Item__c> LUpsert = new List<ASI_MFM_Payment_Line_Item__c>();
                                            set<id> PlanIDSet= new set<id>();
                                            set<id> APCodeIDSet= new set<id>();
                                            set<String> PayeeSet = new set<String>();
                                            set<String> PayeeCodeSet = new set<String>();
                                            Map<String, Id> PayeeCodeToId = new Map<String, Id>();
                                            set<String> CompanySet = new set<String>();
                                            set<String> CurrencySet = new set<String>();
                                            set<Id> subbrandSet = new set<Id>();
                                            list<Account> accList = [select id from Account where ASI_HK_CRM_Customer_Code__c = '6028513' limit 1];
                                            Set<String> duplicationCheck = new Set<String>();
                                            Boolean hasDuplicated = False;
                                            boolean FisrtFind=true;
                                            Boolean InputTotalPaidAmt=true;
                                            decimal TotalPaymentAmount=0;
                                            boolean diffTotalPaymentAmount=false;
                                            integer cum=0;
                                            
                                            set<id> PlanIDSet2 = new set<id>();//20180122 Introv
                                            set<String> typeAvailableSet = new set<String>();//20180126 Introv
                                            Schema.DescribeFieldResult fieldResult = ASI_MFM_Payment_Line_Item__c.ASI_MFM_Type__c.getDescribe();
        									List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        									for(Schema.PicklistEntry s:ple){
                                                typeAvailableSet.add(s.getValue().toLowerCase());
        									} 
                                            //Howard @Introv 21/01/2020 Payee Code --> Payee Id
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_Payment_Line_Item__c item = (ASI_MFM_Payment_Line_Item__c)s;
                                                PayeeCodeSet.add(item.ASI_MFM_Payee__c);
                                            }
                                            for(Account payeeAcc : [select id, ASI_HK_CRM_Customer_Code__c from Account where ASI_HK_CRM_Customer_Code__c IN: PayeeCodeSet])
                                            {
                                                PayeeCodeToId.put(payeeAcc.ASI_HK_CRM_Customer_Code__c,payeeAcc.Id);
                                            }

                                          
                                            for(sObject s : lRecInsert){
                                                system.debug('s'+s);
                                                ASI_MFM_Payment_Line_Item__c item = (ASI_MFM_Payment_Line_Item__c)s;
                                                //ASI_MFM_AP_Remark__c
                                                if(item.ASI_MFM_AP_Remark__c==null && !isOffsetPayment){//20180111 Introv
                                                    LInputRow[cum].addError('Please input AP Remark.');
                                                    hasError = true;
                                                }
                                                
                                                //20180112 Introv
                                                if(isOffsetPayment){
                                                    
                                                    //20180122 Introv, 20180307 Introv Moved under isOffsetPayment
                                                    if(item.ASI_MFM_Promotion_Month__c == '' || item.ASI_MFM_Promotion_Month__c == Null
                                                       || item.ASI_MFM_Plan_Number__c == Null || item.ASI_MFM_Cashout_Payment_Number__c == Null
                                                       || item.ASI_MFM_Payment_List_Item_Description__c == '' || item.ASI_MFM_Payment_List_Item_Description__c == Null
                                                       || item.ASI_MFM_KR_subLedger__c == Null || item.ASI_MFM_KR_subLedger__c == Null
                                                       || item.ASI_MFM_Payment_Amount__c == Null
                                                       || item.ASI_MFM_Company__c == Null || item.ASI_MFM_Company__c == ''
                                                       || item.ASI_MFM_Type__c == Null || item.ASI_MFM_Type__c == ''
                                                      ){
                                                          LInputRow[cum].addError('Data missing, Please input all information in the upload file.');
                                                          hasError = true;
                                                      }
                                                    
                                                    //20180126 Introv
                                                    if(item.ASI_MFM_Type__c!=Null && !typeAvailableSet.contains(item.ASI_MFM_Type__c.toLowerCase())){
                                                        LInputRow[cum].addError('Type value is not correct.');
                                                    	hasError = true;
                                                    }
													
                                                    
                                                    
                                                    item.ASI_MFM_Currency_Sys__c = 'KRW';
                                                    item.ASI_MFM_Payee__c = accList.size() > 0 ? accList[0].id : null;
                                                    item.ASI_MFM_CN_Pre_Payment__c = False;
                                                    item.ASI_MFM_Offset_Payment__c = True;
                                                    subbrandSet.add(item.ASI_MFM_Sub_brand__c);
                                                    system.debug('subbrandSet'+subbrandSet);
                                                    
                                                    String key = '' + item.ASI_MFM_Promotion_Month__c + item.ASI_MFM_Plan_Number__c + item.ASI_MFM_Cashout_Payment_Number__c + item.ASI_MFM_Sub_brand__c + item.ASI_MFM_Type__c + item.ASI_MFM_KR_subLedger__c;
                                                    system.debug('duplication key ' + key);
                                                    if(!duplicationCheck.contains(key)){
                                                        duplicationCheck.add(key);
                                                    }else{
                                                        hasDuplicated = true;
                                                    }
                                                }
                                                
                                                PayeeSet.add(item.ASI_MFM_Payee__c);
                                                if(PayeeCodeToId.containsKey(item.ASI_MFM_Payee__c))
                                                    if(!Test.isRunningTest())
                                                		item.ASI_MFM_Payee__c = PayeeCodeToId.get(item.ASI_MFM_Payee__c);
                                                else{
                                                    hasError = True;
                                                    LInputRow[0].addError('Cannot not find Account With this Customer Code.' );
                                                    break;
                                                }
                                                CompanySet.add(item.ASI_MFM_Company__c);
                                                
                                                system.debug('item.ASI_MFM_Company__c.   ' + item.ASI_MFM_Company__c);
                                                
                                                CurrencySet.add(item.ASI_MFM_Currency_Sys__c);
                                                
                                                PlanIDSet.add(item.ASI_MFM_Plan_Line_Item__c);
                                                APCodeIDSet.add(item.ASI_MFM_AP_Code__c);
                                                
                                                PlanIDSet2.add(item.ASI_MFM_Plan_Number__c);
                                                
                                                LUpsert.add(item);
                                                
                                                if(!isOffsetPayment){//20180112 Introv
                                                    
                                                    if(item.ASI_MFM_GST_Amount__c==null || item.ASI_MFM_GST_Amount__c==0){
                                                        InputTotalPaidAmt=false;
                                                    }else{
                                                        if(FisrtFind){
                                                            FisrtFind=false;
                                                            TotalPaymentAmount=item.ASI_MFM_GST_Amount__c;
                                                        }else{
                                                            if(math.abs(TotalPaymentAmount-item.ASI_MFM_GST_Amount__c)>1){
                                                                diffTotalPaymentAmount=true;
                                                            }
                                                        }
                                                    }
                                                }
                                                cum++;
                                            }//end of for loop
                                            
                                            List<ASI_MFM_Plan__c> PlanList = new List<ASI_MFM_Plan__c>();
                                            if(isOffsetPayment){
                                                PlanList = [select Id, Name, ASI_MFM_Project_Code__c, ASI_MFM_Allow_Offset__c from ASI_MFM_Plan__c where Id in : PlanIDSet2];
                                                for(ASI_MFM_Plan__c obj : PlanList){
                                                    if(!obj.ASI_MFM_Allow_Offset__c){
                                                        hasError = True;
                                                        LInputRow[0].addError('Only Offset Plan is allowed.' );
                                                        break;
                                                    }
                                                }
                                            }
                                            
                                            if(accList.size() == 0){
                                                hasError = True;
                                                LInputRow[0].addError('Dummy Supplier cannot be found.' );
                                            }
                                            
                                            if(!InputTotalPaidAmt && !isOffsetPayment){
                                                hasError = true;
                                                LInputRow[0].addError('Please input Total Payment Amount(Including VAT).' );
                                            }
                                            
                                            if(diffTotalPaymentAmount && !isOffsetPayment){
                                                hasError = true;
                                                LInputRow[0].addError('There should be only one Total Payment Amount(Including VAT).' );
                                            }
                                            
                                            /*
                                            if(PayeeSet.size()>1){
                                                hasError = true;
                                                LInputRow[0].addError('There should be only one Payee.' );
                                            }*/
                                            
                                            if(CompanySet.size()>1){
                                                hasError = true;
                                                LInputRow[1].addError('There should be only one Company Name.' );
                                            }
                                            
                                            if(CurrencySet.size()>1){
                                                hasError = true;
                                                LInputRow[2].addError('There should be only one Currency Name.' );
                                            }
                                            
                                            if(hasDuplicated){
                                                
                                                hasError = true;
                                                LInputRow[0].addError('Duplicated Offset line(s) found, please verify the upload CSV.' );
                                            }
                                            
                                            if(!hasError){
                                                if(!isOffsetPayment)
                                                    DirectPaymentProcess(LUpsert,PlanIDSet,APCodeIDSet); //insert new ASI_MFM_Mass_Upload_Log__c( ASI_MFM_Name__c=' log!'+string.valueOf(system.now()),ASI_MFM_Error_Message__c=logstr ); 
                                                else if(isOffsetPayment)
                                                    offsetPaymentProcess(LUpsert, PlanList, APCodeIDSet, subbrandSet);
                                            }
                                            /*if(Test.isRunningTest())
                                            {
                                                List<ASI_MFM_Payment_Line_Item__c> TestList = new List<ASI_MFM_Payment_Line_Item__c>([Select id from ASI_MFM_Payment_Line_Item__c limit 1]);
                                                offsetPaymentProcess(TestList, PlanList, APCodeIDSet, subbrandSet);
                                            }*/
                                        }
                                        
                                        else if(ObjAPIName == 'ASI_MFM_Budget__c'){
                                            List<ASI_MFM_Budget__c> LUpsert = new List<ASI_MFM_Budget__c>();
                                            Integer randomKey = lRecInsert.size();
                                            Map<String, Integer> TypeMap = new Map<String, Integer>{'Original Budget'=>1,'Budget'=>2,'LE1'=>3,'LE2'=>4,'LE3'=>5,'LE4'=>6}; //system.debug(TypeMap+'Testr'+TypeMap.get(Activatetype)+'Value: Now : '+LS[MFieldPos.get(labelname)]);
                                                
                                                string Actfy;// FY1516
                                            integer yearnum;
                                            string Acttype;
                                            integer cum=0;
                                            
                                            if(Activatetype!=null){
                                                Actfy=Activatetype.substring(0,6);// FY1516
                                                yearnum=integer.valueOf(Activatetype.substring(4,6));//16
                                                Acttype=Activatetype.substring(6,9);//LE4
                                            }
                                            for(sObject s : lRecInsert){
                                                ASI_MFM_Budget__c item = (ASI_MFM_Budget__c)s;
                                                if(Activatetype!=null && item.ASI_MFM_Fiscal_Year__c!=null){
                                                    if(item.ASI_MFM_Fiscal_Year__c==Actfy && TypeMap.containsKey(item.ASI_MFM_Type__c)){
                                                        if(TypeMap.get(Acttype)>=TypeMap.get(item.ASI_MFM_Type__c)){
                                                            LInputRow[cum].addError('Budget Type is wrong, Activate Type : '+Acttype);
                                                            hasError = true;
                                                        }
                                                    }else{
                                                        integer inputfy=integer.valueOf(item.ASI_MFM_Fiscal_Year__c.substring(4,6));
                                                        if(inputfy<yearnum){
                                                            LInputRow[cum].addError('Budget Type is wrong, Activate Type : '+Actfy+'   with   '+ Acttype );
                                                            hasError = true;
                                                        }
                                                    }
                                                }else if(item.ASI_MFM_Fiscal_Year__c==null){
                                                    LInputRow[cum].addError('Fiscal Year cannot be blank.');
                                                    hasError = true;
                                                }
                                                
                                                if (((ASI_MFM_Budget__c)s).ASI_MFM_Budget_External_ID__c == null || ((ASI_MFM_Budget__c)s).ASI_MFM_Budget_External_ID__c == ''){
                                                    item.ASI_MFM_Budget_External_ID__c= String.valueOf(Datetime.now())+ randomKey;
                                                    randomKey++;
                                                }
                                                System.debug('item.ASI_MFM_Budget_External_ID__c' + item.ASI_MFM_Budget_External_ID__c);
                                                LUpsert.add(item);
                                                cum++;
                                            }
                                            system.debug('Test LUpsert Now: '+LUpsert);
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            if(!hasError){
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                            }
                                        }
                                    }
                                    else
                                        insert lRecInsert;
                                    integer succInsert = 0;
                                    integer succUpdate = 0;
                                    string validationErrorText = '';
                                    integer rowNo = 0;
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
                                    msg = 'Import Completed! ' + string.valueof(succInsert) + ' record(s) created.\n';
                                    msg += '' + string.valueof(succUpdate) + ' record(s) updated.\n';
                                    
                                    if(ObjAPIName == 'ASI_MFM_Budget__c' && hasError){
                                        msg='Have Error in creating Budget: No data created.\n';
                                    }
                                    
                                    if(ObjAPIName == 'ASI_MFM_Plan_Line_Item__c' && hasError){
                                        msg='Have Error in creating Plan Line: No data created.\n';
                                    }
                                    if(ObjAPIName=='ASI_MFM_Payment_Line_Item__c'&& !hasError){
                                        if(!isOffsetPayment){
                                        	msg='Payment Request has been created.<br/>Please click on the Link to view the Payment.	<a href="'+ URL.getSalesforceBaseUrl().toExternalForm() +'/'+MsgAddOn+'">View Payment</a>';
                                        }else{
                                            
                                            msg='Payments Request has been created.<br/>Please click on following Links to view the Payments.';
                                            
                                            for(String s : MsgAddOnList.keySet()){
                                                msg += '<br/>' + MsgAddOnList.get(s) + ' :<a href="'+ URL.getSalesforceBaseUrl().toExternalForm() +'/'+s+'" target="_Blank">View</a>';
                                            }
                                        }
                                    }
                                    
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
                                }
                                catch(dmlexception de){
                                    hasError = true;
                                    
                                    for(integer j =0;j<de.getNumDml();j++){
                                        LInputRow[j].addError(de.getDmlMessage(j));
                                        //att.description += e.getDmlMessage(j) + '\n';
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+de.getDmlMessage(j));
                                        LErrorRows.add(LInputRow[j]);
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
                        update LParentObj;
                    }
                    List<Messaging.Email> LEmails = new List<Messaging.Email>();
                    for(Attachment att1 : LAttUpdate){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        string resultText = resultTexts.get(att1.Id);
                        String resultTextHtml = resultText.replace('\n','<br/>');
                        String URLDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.id;
                        mail.setHtmlBody('Your mass upload submission was processed.<br/>' + resultTextHtml + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>Download Uploaded csv: <a href=\"'+URLDownload+'\">'+URLDownload+'</a>');
                        mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded File: '+ URLDownload);
                        mail.setToAddresses(new List<String>{att1.owner.email});
                        mail.setReplyTo('noreply@salesforce.com');
                        mail.setSenderDisplayName('Mass Upload Process');
                        mail.setSubject('Mass Upload Process is Completed');
                        LEmails.add(mail);
                    }
                    if(LEmails.size()>0 && emailNotification){
                        if(!test.isrunningtest()){ Messaging.sendEmail(LEmails);}
                    }
                }
                else{ msg = 'Error: Please select csv file only!';}
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    public void init(){
        
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType =Schema.getGlobalDescribe().get(parentObjectAPIName);
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
        //LLookupField[pos]
        system.debug('KR MFM matchLookupField mfpos'+mfpos);
        system.debug('KR MFM matchLookupField ls'+ls);
        system.debug('KR MFM matchLookupField LLookupField[pos]'+LLookupField[pos]);
        for(string label : LLookupField[pos].MFieldLabelKeyFilter.keySet()){
            system.debug('matchLookupField label '+label+'/'+mfpos.containsKey(label));
            //bypass where customer/beneficiary customer recordtype
            if(mfpos.containsKey(label.toLowerCase()) 
               && !label.contains('where customer recordtype') 
               && !label.contains('beneficiary customer recordtype') 
               && !label.contains('venue(where) recordtype') 
               && !label.contains('customer recordtype') ){
                   
                   if(label.contains('recordtype') ){
                       string tempKey = LLookupField[pos].objectName.toLowerCase() + ls[mfpos.get(label)].toLowerCase();
                       system.debug(label+'Enter matchLookupField MRecTypeID'+MRecTypeID);
                       system.debug('matchLookupField MRecTypeID.containsKey(tempKey)'+tempKey+'/'+MRecTypeID.containsKey(tempKey));
                       if(MRecTypeID.containsKey(tempKey)){
                           key += String.valueof(MRecTypeID.get(tempKey)).toLowerCase();
                       }
                   }
                   else{ 
                       key += ls[mfpos.get(label)].toLowerCase().trim();
                       system.debug('matchLookupField key: '+key);
                   }
                   
                   
               }
        }
        system.debug(' genid :  '+key+ ' (==) '+LLookupField[pos].genid(key));
        return LLookupField[pos].genid(key);
    }
    
    private List<List<String>> genResults(blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null){
            //String fileString = contentFile.toString().toLowerCase();
            //Modify by Steve 20140617
            //
            String fileString = blobToString(contentFile,'UTF-8');
            //String fileString = contentFile.toString();
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

    public string blobToString(Blob input, String inCharset){
         String hex = EncodingUtil.convertToHex(input);
         System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
        bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
     }    
    
    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders) { // Credit to  http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
        List<List<String>> allFields = new List<List<String>>();
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field

        String doubleQuoteWithLineRegex ='("[^"]+\r?\n?+")'; //this is for new line within double quote 
        String doubleQuoteWithLineReplace = 'DBDQWNL';
        Pattern regexPattern = Pattern.compile(doubleQuoteWithLineRegex);
        Matcher regexMatcher = regexPattern.matcher(contents);    
    
        while(regexMatcher.find()) { 
            System.debug('RegexMatcher for new line inside double quote :'+ regexMatcher.group());
            String replaceWord = regexMatcher.group().replaceAll('\r\n','').replaceAll('\n',doubleQuoteWithLineReplace);//.replaceAll(' ','');
            contents = contents.replace(regexMatcher.group(),replaceWord); 
        } 

        String doubleQuoteCommaRegex = '("[^",]+),([^"]*")'; //this is for Comma within double quote 
        String doubleQuoteWithCommaReplace = 'DBDQWC';
        regexPattern = Pattern.compile(doubleQuoteCommaRegex);
        regexMatcher = regexPattern.matcher(contents);    
        
        while(regexMatcher.find()) {
            System.debug('RegexMatcher for comma inside double quote :'+regexMatcher.group());
            String replaceWord = regexMatcher.group().replaceAll(',',doubleQuoteWithCommaReplace);//.replaceAll(' ','');
            contents = contents.replace(regexMatcher.group(),replaceWord); 
        } 


        
        system.debug('regex convert:' + contents);
        
        String UTF8_BOM = '\uFEFF';
        
        if (contents.startsWith(UTF8_BOM)) {
            system.debug('this file contains UTF-8 BOM');
            contents = contents.substring(1);
        }        
        
      
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        
        //contents = contents.replaceAll('""','DBLQT');
        contents = contents.replaceAll('\r\n','\r');
        contents = contents.replaceAll('\n','\r');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            //lines = contents.split('\n'); //correction: this only accomodates windows files
            lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files  //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a 
            
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
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"').replaceAll(doubleQuoteWithCommaReplace,',').replaceAll(doubleQuoteWithLineReplace,'\n'));
                } else if (field.startsWith('"')  && !makeCompositeField) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"') && makeCompositeField) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"').replaceAll(doubleQuoteWithCommaReplace,',').replaceAll(doubleQuoteWithLineReplace,'\n'));
                    makeCompositeField = false;//system.debug('composite field2:'+compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (makeCompositeField) {
                    								compositeField +=  ',' + field;
                                               } else {
                                                   cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"').replaceAll(doubleQuoteWithCommaReplace,',').replaceAll(doubleQuoteWithLineReplace,'\n'));
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
                        
                        //CR20180802 Introv
                        if(objectName=='ASI_MFM_Project_Code__c' && Field=='ASI_MFM_Code__c') {
                            MFieldLabel.put('fiscal year', 'ASI_MFM_Fiscal_Year__c');
                            LkeyFilter.add(new set<String>());
                            MFieldLabelKeyFilter.put('fiscal year', LkeyFilter.size()-1);
                        } 
                    }
                }
            }
        }
        public void addKey(list<string> ls, map<string,integer> Mpos1, map<string,id> MRecTypeID){
            system.debug('addKey ls'+ls);
            system.debug('addKey Mpos1'+Mpos1);
            system.debug('addKey MFieldLabel'+MFieldLabel);
            for(string label : MFieldLabel.keySet()){
                system.debug('addKey Mpos1.containsKey(label)) '+label + '/'+Mpos1.containsKey(label));
                
                if(Mpos1.containsKey(label)){
                    system.debug('key1'+ls[Mpos1.get(label)]);
                    system.debug('MFieldLabelKey'+MFieldLabelKeyFilter.get(label));
                    system.debug('LKeyFilter'+LkeyFilter[MFieldLabelKeyFilter.get(label)]);
                    //handle recordtype id in lookup field component
                    system.debug('label'+label+'/'+label.contains('recordtype'));
                    system.debug('MRecTypeID'+MRecTypeID);
                    if(label.contains('recordtype')){
                        string key = objectName + ls[Mpos1.get(label)].trim();
                        key = key.toLowerCase();//system.debug('MRecTypeID.get(key)'+key+'/'+MRecTypeID.containsKey(key));
                        if(MRecTypeID.containsKey(key)){ LkeyFilter[MFieldLabelKeyFilter.get(label)].add(MRecTypeID.get(key));}
                        
                    }
                    else{
                        LkeyFilter[MFieldLabelKeyFilter.get(label)].add(ls[Mpos1.get(label)].trim());
                    }
                }
            }
        }
        
        public void queryResult(){
            //Payment Line
            //Where venue -->DeveloperName='ASI_CRM_KR_Venue'
            //Beneficiary Customer --> DeveloperName='ASI_CRM_KR_Wholesaler' or DeveloperName = 'ASI_CRM_KR_Venue'
            soql = 'Select id ';
            for(String label : MFieldLabel.keySet()){ 
                soql += ',' + MFieldLabel.get(label);
            }
            soql += ' from ' + objectName;
            if(MFieldLabel.keySet().size()>0){soql += ' where id != null ';}
            
            Set<String> setFilter1;
            Set<String> setFilter2;
            Set<String> setFilter3;
            Set<String> setFilter4;
            for(String label : MFieldLabel.keySet()){
                //soql += ' and ' + MFieldLabel.get(label) + ' IN :LkeyFilter[MFieldLabelKeyFilter.get(label)]';
                soql += ' and (';
                system.debug('MFieldLabelKeyFilter '+MFieldLabelKeyFilter); 
                system.debug('Get MFieldLabel '+MFieldLabel.get(label));
                system.debug('LkeyFilter '+LkeyFilter[MFieldLabelKeyFilter.get(label)]);
                for(string s : LkeyFilter[MFieldLabelKeyFilter.get(label)]){
                    system.debug(MFieldLabel.get(label)  + 'string tony '+ s.replace('\'','\\\''));  //asi_mfm_venue_where__c  && Field =='ASI_CRM_AccountsAdditionalField__c'  
                   
                    if( objectName!=null && objectName=='ASI_CRM_AccountsAdditionalField__c' && MFieldLabel.get(label)=='recordtypeid' &&  Field !=null ){
                        soql+='  RecordType.DeveloperName = \'ASI_CRM_KR_Venue\' or RecordType.DeveloperName = \'ASI_CRM_KR_Wholesaler\'  or ';
                    }
                    else{
                        soql += MFieldLabel.get(label) + ' = \'' + s.replace('\'','\\\'') + '\'  or ';
                    }
                }
                soql = soql.substring(0,soql.length()-5);
                if(LkeyFilter[MFieldLabelKeyFilter.get(label)].size()>0)
                    soql += ' ) ';
                
                //20180829 Introv
                if(objectName!=null && objectName=='ASI_MFM_Project_Code__c' && MFieldLabel.get(label)=='ASI_MFM_Fiscal_Year__c') {
                    soql+= '  AND ASI_MFM_AP_Type__c != NULL ';
                }
            }
            // system.debug(objectName+'soql for ASI_MFM_Plan_Line_Item__c  : '+Field);
            // insert new ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Error_Message__c=String.valueOf(soql) ,ASI_MFM_Configuration__c=Field+'!!!'+objectName); 
            system.debug(Field+objectName+ 'soql for lookup : '+soql);
                        
            if(test.isRunningTest()){
                soql += ' limit 1';
            }
            list<sObject> LResult = database.query(soql);
            system.debug('Lookup LResult for debug : --'+LResult);
            if(LResult != null && LResult.size()>0){
                MResult = new map<string,id>();
                for(sObject s : LResult){
                    string key = '';
                    for(String label : MFieldLabel.keySet()){
                        //system.debug('MFieldLabel.get(label)'+MFieldLabel.get(label));
                        //system.debug(s.get(MFieldLabel.get(label))+ 'Lokkup : objectName '+objectName);
                        if(objectName=='ASI_CRM_AccountsAdditionalField__c' && MFieldLabel.get(label) =='recordtypeid'){
                            //bypass  ASI_CRM_AccountsAdditionalField__c recordtype
                        }else{
                            key += s.get(MFieldLabel.get(label));
                        }
                        
                    }
                    MResult.put(key.toLowerCase(),s.id);
                    //system.debug('Test : '+MResult);
                }
            }
        }
        public id genid(string inputKey){
            System.debug('inputKey now '+inputKey);
            System.debug('Now MResult : '+MResult);
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
        public row(sObject obj){sObj = obj;    }        
        
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
        }
        public void addError(string errMsg){
            errorMsgs.add( errMsg);
        }
    }
    
/*    
    public ASI_MFM_Plan_Line_Item__c CalPlanLineAmount(ASI_MFM_Plan_Line_Item__c pi){
        Decimal tempSum = 0;
        if(pi.ASI_MFM_Month_1_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_1_Cost__c;
        else
            pi.ASI_MFM_Month_1_Cost__c=0;
        
        if(pi.ASI_MFM_Month_2_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_2_Cost__c;
        else
            pi.ASI_MFM_Month_2_Cost__c=0;
        
        if(pi.ASI_MFM_Month_3_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_3_Cost__c;
        else
            pi.ASI_MFM_Month_3_Cost__c=0;
        
        if(pi.ASI_MFM_Month_4_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_4_Cost__c;
        else
            pi.ASI_MFM_Month_4_Cost__c=0;
        
        if(pi.ASI_MFM_Month_5_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_5_Cost__c;
        else
            pi.ASI_MFM_Month_5_Cost__c=0;
        
        if(pi.ASI_MFM_Month_6_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_6_Cost__c;
        else
            pi.ASI_MFM_Month_6_Cost__c=0;
        
        if(pi.ASI_MFM_Month_7_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_7_Cost__c;
        else
            pi.ASI_MFM_Month_7_Cost__c=0;
        
        if(pi.ASI_MFM_Month_8_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_8_Cost__c;
        else
            pi.ASI_MFM_Month_8_Cost__c=0;
        
        if(pi.ASI_MFM_Month_9_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_9_Cost__c;
        else
            pi.ASI_MFM_Month_9_Cost__c=0;
        
        if(pi.ASI_MFM_Month_10_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_10_Cost__c;
        else
            pi.ASI_MFM_Month_10_Cost__c=0;
        
        if(pi.ASI_MFM_Month_11_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_11_Cost__c;
        else
            pi.ASI_MFM_Month_11_Cost__c=0;
        
        if(pi.ASI_MFM_Month_12_Cost__c != null)
            tempSum += pi.ASI_MFM_Month_12_Cost__c;
        else
            pi.ASI_MFM_Month_12_Cost__c=0;
        
        pi.ASI_MFM_Total_Cost__c=tempSum;
        return pi;
    }
    */
    //Map AC Code in Plan line  
    public List<ASI_MFM_Plan_Line_Item__c>  MapACCodePL(List<ASI_MFM_Plan_Line_Item__c> PlanLineList,Set<String> APCodeSet){
        List<ASI_MFM_AP_AC_Code_Map__c> APACMapList = [select id,ASI_MFM_AP_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c 
                                                       from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__c!=null and  
                                                       ASI_MFM_A_C_Code__c !=null and ASI_MFM_AP_Code__r.RecordType.DeveloperName = 'ASI_KR_AP_Code' 
                                                       and ASI_MFM_AP_Code__c in :  APCodeSet];
        Map<Id,ASI_MFM_AP_Code__c> APMap= new Map<Id,ASI_MFM_AP_Code__c> ();
        set<id> TempApSet= new set<id> ();
        for(ASI_MFM_AP_AC_Code_Map__c apac : APACMapList){
            if(!TempApSet.contains(apac.ASI_MFM_AP_Code__c)){
                TempApSet.add(apac.ASI_MFM_AP_Code__c);
                ASI_MFM_AP_Code__c tempAp =new ASI_MFM_AP_Code__c(ASI_MFM_A_C_Code__c=apac.ASI_MFM_A_C_Code__c );
                if(apac.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c !=null){
                    tempAp.ASI_MFM_AP_Type__c=apac.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                }
                
                if(apac.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c !=null){
                    tempAp.ASI_MFM_AP_Category__c=apac.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c;
                }
                
                APMap.put(apac.ASI_MFM_AP_Code__c, tempAp);
            } 
        }
        
        if(TempApSet.size()>0){
            for(ASI_MFM_Plan_Line_Item__c pl:PlanLineList){
                if(pl.ASI_MFM_AP_Code__c !=null && APMap.containsKey(pl.ASI_MFM_AP_Code__c)){
                    pl.ASI_MFM_A_C_Code__c=APMap.get(pl.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c;
                    if(APMap.get(pl.ASI_MFM_AP_Code__c).ASI_MFM_AP_Type__c!=null)
                        pl.ASI_MFM_AP_Type__c=APMap.get(pl.ASI_MFM_AP_Code__c).ASI_MFM_AP_Type__c;
                    if(APMap.get(pl.ASI_MFM_AP_Code__c).ASI_MFM_AP_Category__c!=null )
                        pl.ASI_MFM_AP_Category__c=APMap.get(pl.ASI_MFM_AP_Code__c).ASI_MFM_AP_Category__c;
                }
            }
        }
        
        return PlanLineList;
    }
    
    //For Upload Plan Creation
    public List<ASI_MFM_Plan__c> SelectPrefix(List<ASI_MFM_Plan__c> PlanList,Set<Id> PCSet){
        
        
        Map<String, ASI_MFM_Prefix__c> PrefixMap = new Map<String, ASI_MFM_Prefix__c> ();
        List<ASI_MFM_Prefix__c> PrefixList=[select Id,Name,ASI_MFM_Project_Code__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Next_Number__c from ASI_MFM_Prefix__c where ASI_MFM_Project_Code__c in : PCSet  and  ASI_MFM_Module__c='Plan' and ASI_MFM_Inactive__c = false];
        for(ASI_MFM_Prefix__c px:PrefixList){
            PrefixMap.put(String.valueOf(px.ASI_MFM_Project_Code__c)+px.ASI_MFM_Fiscal_year__c, px);
        }
        
        
        Map<ID, String> PCmap = new Map<ID, String> ();
        List<ASI_MFM_Project_Code__c> PCcodeList =[select Id,name,ASI_MFM_Code__c from ASI_MFM_Project_Code__c where Id in : PCSet and ASI_MFM_Inactive__c = false];
        for(ASI_MFM_Project_Code__c pc:PCcodeList ){
            PCmap.put(pc.Id, pc.ASI_MFM_Code__c);
        }
        Map<String,ASI_MFM_Prefix__c> NewPrefixMap= new map<String,ASI_MFM_Prefix__c>();
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');  
        set<string> PrefixSet= new  set<string>();
        //Loop Plan 
        for(ASI_MFM_Plan__c Plan:PlanList){
            Plan.ASI_MFM_Single_Approval__c=true;
            string prefixKey=Plan.ASI_MFM_Project_Code__c+Plan.ASI_MFM_Fiscal_year__c;
            if(Plan.ASI_MFM_Project_Code__c!=null && PrefixMap.containsKey(prefixKey)){
                Plan.ASI_MFM_Prefix__c=PrefixMap.get(prefixKey).id;
            }else if (!PrefixSet.contains(prefixKey)){
                PrefixSet.add(prefixKey);
                NewPrefixMap.put(prefixKey, new ASI_MFM_Prefix__c(ASI_MFM_Project_Code__c=Plan.ASI_MFM_Project_Code__c,
                                                                  recordTypeId=rt_map.get('ASI_MFM_KR_Prefix'),
                                                                  ASI_MFM_Type__c='Upload',
                                                                  ASI_MFM_Next_Number__c=1,
                                                                  ASI_MFM_Fiscal_year__c=Plan.ASI_MFM_Fiscal_year__c,ASI_MFM_Module__c='Plan'));
            }
            
        }
        
        //insert Prefix List 
        insert NewPrefixMap.values();
        
        for(ASI_MFM_Plan__c Plan:PlanList){
            string prefixKey=Plan.ASI_MFM_Project_Code__c+Plan.ASI_MFM_Fiscal_year__c;
            if(Plan.ASI_MFM_Prefix__c==null && NewPrefixMap.containsKey(prefixKey)){
                Plan.ASI_MFM_Prefix__c=NewPrefixMap.get(prefixKey).Id;                
            }
            
            
        }
        
        return PlanList;
    }
    
    
    
    public void DirectPaymentProcess(List<ASI_MFM_Payment_Line_Item__c> payList,set<id> PlanIDSet,set<id> APCodeIDSet){
        String StatusMsg='';
        boolean ProcessStatus= True;
        String InvoiceNumber='';
        Map<id,String> SubBrandMap= new Map<id,String>();
        
        ASI_MFM_Prefix__c payment_prefixes = new ASI_MFM_Prefix__c();
        ASI_MFM_Prefix__c po_prefixes = new ASI_MFM_Prefix__c();
        ASI_MFM_Tax_Code__c defaultTax = new ASI_MFM_Tax_Code__c();
        
        if(payList.size()>0){
            //Get Plan
            List<ASI_MFM_Plan_Line_Item__c> PlanLineList = [select Id,Name,ASI_MFM_Plan__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__c from ASI_MFM_Plan_Line_Item__c where Id in : PlanIDSet];
            
            for(ASI_MFM_Plan_Line_Item__c pl:PlanLineList){
                SubBrandMap.put(pl.Id, PL.ASI_MFM_Sub_brand_Code__c);
            }
            system.debug('Test Acc'+ payList[0].ASI_MFM_Payee__c+ ')');
            //Get Default Tax Code
            Account acc= [select id , ASI_HK_CRM_Payment_Term_Code__c from Account where id=:payList[0].ASI_MFM_Payee__c];
            
            List<ASI_MFM_Tax_Code__c> tx= new List<ASI_MFM_Tax_Code__c>(); //ASI_MFM_Tax_Code__c[] tx; 
            
            
            if(acc.ASI_HK_CRM_Payment_Term_Code__c!=null){
                tx=[select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where name =:[select ASI_MFM_Site_Code__c from Account where id=:payList[0].ASI_MFM_Payee__c ].ASI_MFM_Site_Code__c and ASI_MFM_Tax_Expl_Code__c=:acc.ASI_HK_CRM_Payment_Term_Code__c limit 1];
            }else{
                tx=[select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where name =:[select ASI_MFM_Site_Code__c from Account where id=:payList[0].ASI_MFM_Payee__c].ASI_MFM_Site_Code__c limit 1];
            }
            if(tx.size()>0){
                defaultTax=tx[0];
            }
            
            //Get Prefrix
            for(ASI_MFM_Prefix__c px_List: [select id,name,ASI_MFM_Module__c from ASI_MFM_Prefix__c where (ASI_MFM_Module__c='Direct PO' OR ASI_MFM_Module__c='Payment') and ASI_MFM_country_name__c='KR' and ASI_MFM_Inactive__c=false AND Name=: payList[0].ASI_MFM_Company__c]){
                if(px_List.ASI_MFM_Module__c=='Direct PO'){
                    po_prefixes=px_List;
                }
                if(px_List.ASI_MFM_Module__c=='Payment'){
                    payment_prefixes=px_List;
                }
            }  
            
            //Get Sub-Brand
            
            
            Map<Id,String> ACMap= new Map<Id,String> ();
            set<id> TempApSet= new set<id> ();
            List<ASI_MFM_AP_AC_Code_Map__c> APACMapList = [select id,ASI_MFM_AP_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c 
                                                           from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__c!=null and  
                                                           ASI_MFM_A_C_Code__c !=null and ASI_MFM_AP_Code__r.RecordType.DeveloperName = 'ASI_KR_AP_Code' 
                                                           and ASI_MFM_AP_Code__c in : APCodeIDSet];
            for(ASI_MFM_AP_AC_Code_Map__c apac : APACMapList){
                if(!TempApSet.contains(apac.ASI_MFM_AP_Code__c)){
                    TempApSet.add(apac.ASI_MFM_AP_Code__c);
                    ACMap.put(apac.ASI_MFM_AP_Code__c,apac.ASI_MFM_A_C_Code__c);
                }
            }													   
            
            
            if(PlanLineList.size()>0){
                System.Savepoint sp = database.setSavepoint();
                ASI_MFM_PO__c create_po = new ASI_MFM_PO__c(ASI_MFM_Currency__c=payList[0].ASI_MFM_Currency_Sys__c,ASI_MFM_CN_Return_Flag__c=true,ASI_MFM_Exchange_Rate__c=Decimal.valueOf(payList[0].ASI_MFM_BC_Code__c),ASI_MFM_PO_Start_Date__c = System.Today(), ASI_MFM_Plan__c=PlanLineList[0].ASI_MFM_Plan__c,recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'),  ASI_MFM_Project_Code__c=PlanLineList[0].ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,ASI_MFM_Is_Direct_Payment__c = true, ASI_MFM_PO_End_Date__c = System.Today(),ASI_MFM_Prefix__c = po_prefixes.id, ASI_MFM_Supplier_Name__c=payList[0].ASI_MFM_Payee__c,ASI_MFM_Status__c = 'Draft');
                try {    
                    insert create_po;//StatusMsg+='PO insert successfully '+create_po.Id+';';
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                //Insert Payment
                ASI_MFM_Payment__c create_pa= new ASI_MFM_Payment__c(ASI_MFM_Currency__c=payList[0].ASI_MFM_Currency_Sys__c,
                                                                     ASI_MFM_KR_TotalPayAmtIncludeVAT__c=payList[0].ASI_MFM_GST_Amount__c,ASI_MFM_CN_Return_Flag__c=true,ASI_MFM_Exchange_Rate__c=Decimal.valueOf(payList[0].ASI_MFM_BC_Code__c),ASI_MFM_Invoice_Number__c = payList[0].ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c =payList[0].ASI_MFM_Invoice_Date__c,ASI_MFM_Supplier_Name__c=payList[0].ASI_MFM_Payee__c,recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),ASI_MFM_Prefix__c = payment_prefixes.id,ASI_MFM_Plan__c=PlanLineList[0].ASI_MFM_Plan__c,ASI_MFM_Status__c = 'Draft', ASI_MFM_Is_Direct_Payment__c = true, ASI_MFM_G_L_Date__c = System.Today() );
                
                if(defaultTax!=null){
                    create_pa.ASI_MFM_Tax_Code__c=defaultTax.Id;
                    create_pa.ASI_MFM_Tax_Explanation_Code__c=defaultTax.ASI_MFM_Tax_Expl_Code__c;
                }
                try {    
                    insert create_pa;//StatusMsg+='Payment  insert successfully '+create_pa.Id+';';
                    MsgAddOn=create_pa.Id;
                    if(create_pa.ASI_MFM_Invoice_Number__c==null){
                        InvoiceNumber=[select ASI_MFM_Invoice_Number__c from ASI_MFM_Payment__c where id=:create_pa.Id].ASI_MFM_Invoice_Number__c;
                    }
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                List <ASI_MFM_PO_Line_Item__c> Save_POItem = new List <ASI_MFM_PO_Line_Item__c>();
                List <ASI_MFM_Payment_Line_Item__c> Save_PAYItem = new List <ASI_MFM_Payment_Line_Item__c>() ; 
                
                for(ASI_MFM_Payment_Line_Item__c payl:payList){
                    
                    //3rd create PO Line Item
                    ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_AccountsAdditionalField__c=payl.ASI_MFM_Where_Customer__c,recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'), ASI_MFM_PO__c = create_po.id,ASI_MFM_Project_Code__c=string.valueOf(create_po.ASI_MFM_Project_Code__c),ASI_MFM_G_L_Date__c = System.Today(),ASI_MFM_Sub_brand_Code__c = SubBrandMap.get(payl.ASI_MFM_Plan_Line_Item__c),ASI_MFM_AP_Code__c = Id.valueOf(payl.ASI_MFM_AP_Code__c),ASI_MFM_Amount__c = payl.ASI_MFM_Payment_Amount__c, ASI_MFM_Plan_Line_Item__c = payl.ASI_MFM_Plan_Line_Item__c,ASI_MFM_KR_subLedger__c=payl.ASI_MFM_KR_subLedger__c);
                    
                    //4th create Payment Line Item               
                    ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_KR_subLedger__c=payl.ASI_MFM_KR_subLedger__c,recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),ASI_MFM_Payment__c = create_pa.id,ASI_MFM_Payee__c=payl.ASI_MFM_Payee__c,ASI_MFM_Beneficiary_Customer__c =payl.ASI_MFM_Beneficiary_Customer__c,ASI_MFM_Where_Customer__c =payl.ASI_MFM_Where_Customer__c,ASI_MFM_Payment_Amount__c = payl.ASI_MFM_Payment_Amount__c,ASI_MFM_PO__c = create_po.id,ASI_MFM_AP_Remark__c=payl.ASI_MFM_AP_Remark__c,ASI_MFM_Company__c=payl.ASI_MFM_Company__c);
                    
                    if(payl.ASI_MFM_Invoice_Number__c!=null){
                        paline.ASI_MFM_Invoice_Number__c = payl.ASI_MFM_Invoice_Number__c;
                    }else{
                        paline.ASI_MFM_Invoice_Number__c = InvoiceNumber;
                    }
                    
                    if(ACMap.containsKey(payl.ASI_MFM_AP_Code__c)){
                        poline.ASI_MFM_A_C_Code__c=ACMap.get(payl.ASI_MFM_AP_Code__c);
                        paline.ASI_MFM_A_C_Code__c=ACMap.get(payl.ASI_MFM_AP_Code__c);
                    }
                    //only local currency can have exchange rate
                    if(payl.ASI_MFM_Currency_Sys__c=='KRW'){
                        poline.ASI_MFM_Tax_Code__c=defaultTax.id;
                        paline.ASI_MFM_Tax_Code__c=defaultTax.id;
                    }
                    
                    if(payl.ASI_MFM_Invoice_Date__c!=null){
                        paline.ASI_MFM_Invoice_Date__c = payl.ASI_MFM_Invoice_Date__c;
                    }else{
                        paline.ASI_MFM_Invoice_Date__c =system.today();
                    }
                    
                    if(payl.ASI_MFM_Company__c=='PRK'){
                        paline.ASI_MFM_Business_Unit__c='P830';
                    }else{
                        paline.ASI_MFM_Business_Unit__c='J520';
                    }
                    
                    Save_POItem.add(poline);
                    Save_PAYItem.add(paline);
                }// end of for loop
                
                
                //Insert po line
                try {    
                    insert Save_POItem;
                    
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                for (Integer p = 0;p < Save_POItem.size();p++){
                    Save_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_POItem[p].id;
                }
                
                try {    
                    insert Save_PAYItem;
                    
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                if(StatusMsg.length()>0){
                    insert new ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Error_Message__c=String.valueOf(currentPageURL) ,ASI_MFM_Configuration__c=StatusMsg); 
                }
                
            }   
        }
        
    }
    
    public void offsetPaymentProcess(List<ASI_MFM_Payment_Line_Item__c> payList, List<ASI_MFM_Plan__c> PlanList, set<id> APCodeIDSet, Set<id> subbrandSet){//201801112 introv
        String StatusMsg='';
        boolean ProcessStatus= True;
        String InvoiceNumber='';
        Map<id,String> SubBrandMap= new Map<id,String>();
        Map<id,String> SubBrandMap2= new Map<id,String>();
        
        ASI_MFM_Prefix__c payment_prefixes = new ASI_MFM_Prefix__c();
        ASI_MFM_Prefix__c po_prefixes = new ASI_MFM_Prefix__c();
        ASI_MFM_Tax_Code__c defaultTax = new ASI_MFM_Tax_Code__c();
        
        if(payList.size()>0){
            //Get Plan
            
            system.debug('Test Acc'+ payList[0].ASI_MFM_Payee__c+ ')');
            //Get Default Tax Code
            Account acc= [select id , ASI_HK_CRM_Payment_Term_Code__c from Account where id=:payList[0].ASI_MFM_Payee__c];
            
            List<ASI_MFM_Tax_Code__c> tx= new List<ASI_MFM_Tax_Code__c>();
            tx=[select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where name ='JA11' and ASI_MFM_Tax_Expl_Code__c = 'E' limit 1];
            if(tx.size()>0){
                defaultTax=tx[0];
            }
            
            system.debug('payList[0].ASI_MFM_Company__c   ' + payList[0].ASI_MFM_Company__c);
            
            //Get Prefrix
            for(ASI_MFM_Prefix__c px_List: [select id,name,ASI_MFM_Module__c from ASI_MFM_Prefix__c where (ASI_MFM_Module__c='Dummy PO' OR ASI_MFM_Module__c='Payment') and ASI_MFM_country_name__c='KR' and ASI_MFM_Inactive__c=false AND Name=: payList[0].ASI_MFM_Company__c]){
                if(px_List.ASI_MFM_Module__c=='Dummy PO'){
                    po_prefixes=px_List;
                }
                if(px_List.ASI_MFM_Module__c=='Payment'){
                    payment_prefixes=px_List;
                }
            }
            
            ASI_MFM_A_C_Code__c PRKDefaultACCode;
            ASI_MFM_A_C_Code__c PRKIDefaultACCode;
            
            for(ASI_MFM_A_C_Code__c accode : [SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_Offset_Payment__c = TRUE AND RecordType.DeveloperName Like '%_KR_%']){
                if(accode.Name.containsIgnoreCase('222')){
                    PRKDefaultACCode = accode;
                }else if(accode.Name.containsIgnoreCase('286')){
                    PRKIDefaultACCode = accode;
                }else{
                    PRKDefaultACCode = accode;
                    PRKIDefaultACCode = accode;
                }
            }
            
            if(PlanList.size()>0){
                System.Savepoint sp = database.setSavepoint();
                
                List<ASI_MFM_PO__c> insertPOs = new List<ASI_MFM_PO__c>();
                Map<id, ASI_MFM_PO__c> mapPOByPlan = new Map<id, ASI_MFM_PO__c>();
                Map<id, Double> mapPaymentAmount = new Map<Id, Double>();//20180225 Introv
                List<ASI_MFM_Payment__c> insertPayments = new List<ASI_MFM_Payment__c>();
                Map<id, ASI_MFM_Payment__c> mapPaymentByPlan = new Map<id, ASI_MFM_Payment__c>();
                
                for(ASI_MFM_Payment_Line_Item__c payl:payList){
                    
                    Double ttlAmt = 0;
                    
                    if(mapPaymentAmount.containsKey(payl.ASI_MFM_Plan_Number__c))
                        ttlAmt = mapPaymentAmount.get(payl.ASI_MFM_Plan_Number__c);
                    
                    ttlAmt += (payl.ASI_MFM_Payment_Amount__c != Null ? payl.ASI_MFM_Payment_Amount__c : 0);
                    mapPaymentAmount.put(payl.ASI_MFM_Plan_Number__c, ttlAmt);
                    
                }
                
                for(ASI_MFM_Plan__c obj : PlanList){
                    
                    ASI_MFM_PO__c create_po = new ASI_MFM_PO__c(ASI_MFM_Company__c = payList[0].ASI_MFM_Company__c,
                                                                ASI_MFM_Dummy_PO__c = true, 
                                                                ASI_MFM_Currency__c=payList[0].ASI_MFM_Currency_Sys__c,
                                                                ASI_MFM_CN_Return_Flag__c=true,
                                                                ASI_MFM_Exchange_Rate__c=1,
                                                                ASI_MFM_PO_Start_Date__c = System.Today(),
                                                                ASI_MFM_Plan__c = obj.id,
                                                                recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'),
                                                                ASI_MFM_Project_Code__c = obj.ASI_MFM_Project_Code__c,
                                                                ASI_MFM_Is_Direct_Payment__c = false,
                                                                ASI_MFM_Is_Offset_Payment__c = true,
                                                                ASI_MFM_PO_End_Date__c = System.Today(),
                                                                ASI_MFM_Prefix__c = po_prefixes.id, 
                                                                ASI_MFM_Supplier_Name__c=payList[0].ASI_MFM_Payee__c,
                                                                ASI_MFM_Status__c = 'Draft');
                    create_po.ASI_MFM_Company_Code__c = create_po.ASI_MFM_Company__c == 'PRK' ? '222' : '286';
                    insertPOs.add(create_po);
                    mapPOByPlan.put(obj.id, create_po);
                }
                
                try {    
                    insert insertPOs;
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                //Insert Payment
                
                for(ASI_MFM_Plan__c obj : PlanList){
                    ASI_MFM_Payment__c create_pa= new ASI_MFM_Payment__c(ASI_MFM_Company__c = payList[0].ASI_MFM_Company__c, 
                                                                         ASI_MFM_Currency__c=payList[0].ASI_MFM_Currency_Sys__c,
                                                                         ASI_MFM_KR_TotalPayAmtIncludeVAT__c=payList[0].ASI_MFM_GST_Amount__c,
                                                                         ASI_MFM_CN_Return_Flag__c=true,ASI_MFM_Exchange_Rate__c=1,
                                                                         ASI_MFM_Invoice_Number__c = payList[0].ASI_MFM_Invoice_Number__c, 
                                                                         ASI_MFM_Invoice_Date__c =payList[0].ASI_MFM_Invoice_Date__c,
                                                                         ASI_MFM_Supplier_Name__c=payList[0].ASI_MFM_Payee__c,
                                                                         recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                         ASI_MFM_Prefix__c = payment_prefixes.id,
                                                                         ASI_MFM_Plan__c = obj.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         ASI_MFM_PO__c = mapPOByPlan.containsKey(obj.id) ? mapPOByPlan.get(obj.id).id : Null, //20180225 Introv
                                                                         //ASI_MFM_ETL__c = True,
                                                                         ASI_MFM_Offset_Payment__c = true, 
                                                                         ASI_MFM_G_L_Date__c = System.Today() );
                    
                    create_pa.ASI_MFM_Company_Code__c = create_pa.ASI_MFM_Company__c == 'PRK' ? '222' : '286';
                    create_pa.ASI_MFM_KR_TotalPayAmtIncludeVAT__c = 0;
                    create_pa.ASI_MFM_AP_Remark__c = 'Prepayment Offset';
                    create_pa.ASI_MFM_Remarks__c = 'Prepayment Offset';
                    create_pa.ASI_MFM_KR_TotalPayAmtIncludeVAT__c = mapPaymentAmount.containsKey(obj.id) ? mapPaymentAmount.get(obj.id) : 0;//20180225 Introv
                    
                    if(defaultTax!=null){
                        create_pa.ASI_MFM_Tax_Code__c = defaultTax.Id;
                        create_pa.ASI_MFM_Tax_Explanation_Code__c=defaultTax.ASI_MFM_Tax_Expl_Code__c;
                    }
                    
                    insertPayments.add(create_pa);
                    mapPaymentByPlan.put(obj.id, create_pa);
                }
                
                try {    
                    insert insertPayments;//StatusMsg+='Payment  insert successfully '+create_pa.Id+';';
                    
                    MsgAddOnList = new Map<String, String>();//20180125 Introv
                    
                    
                    for(integer i = 0; i < insertPayments.size(); i++){
                        MsgAddOnList.put(insertPayments[i].id, 'Payment ' + (i + 1));
                    }
                    
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                List <ASI_MFM_PO_Line_Item__c> Save_POItem = new List <ASI_MFM_PO_Line_Item__c>();
                List <ASI_MFM_Payment_Line_Item__c> Save_PAYItem = new List <ASI_MFM_Payment_Line_Item__c>() ; 
                
                for(ASI_MFM_Payment_Line_Item__c payl:payList){
                    payl.ASI_MFM_Invoice_Number__c = String.valueOf(date.today().year()) +String.valueOf(date.today().month());
                    //3rd create PO Line Item
                    ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_AccountsAdditionalField__c=payl.ASI_MFM_Where_Customer__c,
                                                                                 recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                                 ASI_MFM_PO__c = mapPOByPlan.containsKey(payl.ASI_MFM_Plan_Number__c) ? mapPOByPlan.get(payl.ASI_MFM_Plan_Number__c).id : Null,
                                                                                 ASI_MFM_Project_Code__c=string.valueOf(mapPOByPlan.containsKey(payl.ASI_MFM_Plan_Number__c) ? mapPOByPlan.get(payl.ASI_MFM_Plan_Number__c).ASI_MFM_Project_Code__c : ''),
                                                                                 ASI_MFM_G_L_Date__c = System.Today(),
                                                                                 //ASI_MFM_Sub_brand_Code__c = SubBrandMap.get(payl.ASI_MFM_Plan_Line_Item__c)/*,ASI_MFM_AP_Code__c = Id.valueOf(payl.ASI_MFM_AP_Code__c)*/,
																				 ASI_MFM_Sub_brand_Code__c=payl.ASI_MFM_Sub_brand__c,
                                                                                 ASI_MFM_Amount__c = payl.ASI_MFM_Payment_Amount__c, 
                                                                                 //ASI_MFM_Plan_Line_Item__c = payl.ASI_MFM_Plan_Line_Item__c,
                                                                                 //ASI_MFM_Plan__c = payl.ASI_MFM_Plan_Number__c,
                                                                                 ASI_MFM_KR_subLedger__c=payl.ASI_MFM_KR_subLedger__c);
                    
                    system.debug('payl.ASI_MFM_Sub_brand__c : '+ payl.ASI_MFM_Sub_brand__c);
                    
                    //4th create Payment Line Item               
                    ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c( ASI_MFM_KR_subLedger__c=payl.ASI_MFM_KR_subLedger__c,
                                                                                           recordTypeID = global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                           ASI_MFM_Payment__c = mapPaymentByPlan.containsKey(payl.ASI_MFM_Plan_Number__c) ? mapPaymentByPlan.get(payl.ASI_MFM_Plan_Number__c).id : Null,
                                                                                           ASI_MFM_Payee__c=payl.ASI_MFM_Payee__c,
                                                                                           ASI_MFM_Beneficiary_Customer__c =payl.ASI_MFM_Beneficiary_Customer__c,
                                                                                           ASI_MFM_Where_Customer__c =payl.ASI_MFM_Where_Customer__c,
                                                                                           ASI_MFM_Payment_Amount__c = payl.ASI_MFM_Payment_Amount__c,
                                                                                           ASI_MFM_PO__c = mapPOByPlan.containsKey(payl.ASI_MFM_Plan_Number__c) ? mapPOByPlan.get(payl.ASI_MFM_Plan_Number__c).id : Null,
                                                                                           ASI_MFM_AP_Remark__c=payl.ASI_MFM_AP_Remark__c,
                                                                                           ASI_MFM_Company__c=payl.ASI_MFM_Company__c,
                                                                                           ASI_MFM_Plan_Number__c=payl.ASI_MFM_Plan_Number__c,
                                                                                           ASI_MFM_Payment_List_Item_Description__c=payl.ASI_MFM_Payment_List_Item_Description__c,
                                                                                           ASI_MFM_CN_Pre_Payment__c=payl.ASI_MFM_CN_Pre_Payment__c,
                                                                                           ASI_MFM_Offset_Payment__c=payl.ASI_MFM_Offset_Payment__c,
                                                                                           ASI_MFM_Type__c=payl.ASI_MFM_Type__c,
                                                                                           ASI_MFM_Sub_brand__c=payl.ASI_MFM_Sub_brand__c,
                                                                                           ASI_MFM_Cashout_Payment_Number__c = payl.ASI_MFM_Cashout_Payment_Number__c,
                                                                                           ASI_MFM_Promotion_Month__c = payl.ASI_MFM_Promotion_Month__c
                                                                                           );
                    
                    if(payl.ASI_MFM_Invoice_Number__c!=null){
                        paline.ASI_MFM_Invoice_Number__c = payl.ASI_MFM_Invoice_Number__c;
                    }
                    
                    //if(ACMap.containsKey(payl.ASI_MFM_AP_Code__c)){
                        //poline.ASI_MFM_A_C_Code__c = Null;//ACMap.get(payl.ASI_MFM_AP_Code__c);
                        //paline.ASI_MFM_A_C_Code__c = Null;//ACMap.get(payl.ASI_MFM_AP_Code__c);
                    //}
                    
                    if(payl.ASI_MFM_Company__c == 'PRK'){
                        poline.ASI_MFM_A_C_Code__c = PRKDefaultACCode.id;
                        paline.ASI_MFM_A_C_Code__c = PRKDefaultACCode.id;
                    }else{
                        poline.ASI_MFM_A_C_Code__c = PRKIDefaultACCode.id;
                        paline.ASI_MFM_A_C_Code__c = PRKIDefaultACCode.id;
                    }
                    
                    //only local currency can have exchange rate
                    if(payl.ASI_MFM_Currency_Sys__c=='KRW'){
                        poline.ASI_MFM_Tax_Code__c=defaultTax.id;
                        paline.ASI_MFM_Tax_Code__c=defaultTax.id;
                        paline.ASI_MFM_Tax_Explanation_Code__c=defaultTax.ASI_MFM_Tax_Expl_Code__c;
                    }
                    
                    if(payl.ASI_MFM_Invoice_Date__c!=null){
                        paline.ASI_MFM_Invoice_Date__c = payl.ASI_MFM_Invoice_Date__c;
                    }else{
                        paline.ASI_MFM_Invoice_Date__c =system.today();
                    }
                    
                    if(payl.ASI_MFM_Company__c=='PRK'){
                        paline.ASI_MFM_Business_Unit__c='P830';
                    }else{
                        paline.ASI_MFM_Business_Unit__c='J520';
                    }
                    
                    if(paline.ASI_MFM_Type__c.containsIgnoreCase('Default Provision')){
                        paline.ASI_MFM_Phase__c = 'A17';
                    }else if(paline.ASI_MFM_Type__c.containsIgnoreCase('Write-off') || paline.ASI_MFM_Type__c.containsIgnoreCase('Write off')){
                        paline.ASI_MFM_Phase__c = '';
                    }else{
                        paline.ASI_MFM_Phase__c = 'A00';
                    }
                    
                    Save_POItem.add(poline);
                    Save_PAYItem.add(paline);
                    
                    system.debug('paline.size() ' + Save_PAYItem.size());
                }// end of for loop
                
                
                //Insert po line
                try {   
                    system.debug('Save_POItem ' + Save_POItem);
                    insert Save_POItem;
                    
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                }
                
                for (Integer p = 0;p < Save_POItem.size();p++){
                    Save_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_POItem[p].id;
                }
                
                try {    
                    system.debug('Save_PAYItem ' + Save_PAYItem);
                    insert Save_PAYItem;
                    
                }catch (DmlException dmle) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                    StatusMsg+=err;
                    hasError = true;
                    database.rollback(sp);
                    
                    system.debug('payment line error 1' + err);
                    
                }catch (Exception e) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                    StatusMsg+=err; 
                    hasError = true;
                    database.rollback(sp);
                    
                    system.debug('payment line error 2' + err);
                }
                
                if(StatusMsg.length()>0){
                    insert new ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Error_Message__c=String.valueOf(currentPageURL) ,ASI_MFM_Configuration__c=StatusMsg); 
                }
                
            }   
        }
        
    }
    
}