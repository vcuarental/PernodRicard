/*********************************************************************************
    * Name: ASI_TnE_MassUploadCorpCardController
    * Description: Controller for ASI_TnE_MassUploadCorpCardComponent. Upload .csv format file to Corp Card Object
    *
    * Version History
    * 2015-03-02        Laputa      Create
*********************************************************************************/ 
    //Attributes
public class ASI_TnE_KR_ProxyDriving_UploadController {
    public string ObjAPIName {set;get;}
    public string parentID {set;get;}
    public string parentField {set;get;}
    public string fields {set;get;}
    public string fieldsLabel {set;get;}
    public string lookupEXID {set;get;}
    public string template {set;get;}
    public string report{set;get;}
    public string recordtypeName {set;get;}
    public string currentPageURL {set;get;}
    public boolean inlineVF {set;get;}
    public Boolean reloadNeeded {get; set;}
    public string defaultValues {set;get;}
    public string recEXID {set;get;}
    public string recEXIDcol {set;get;} 
    public string parentObjectAPIName {set;get;}
    public string ParentObjectUploadMsg {set;get;}
    public boolean upsertMode {set;get;}
    public boolean batchMode {set;get;}
    public boolean opt_allOrNone{set;get;}    
    public boolean emailNotification {set;get;}
    
    public string objName {set;get;} 
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    
    public string Msg {set;get;}
    
    public Blob contentFile {set;get;}
    
    public string currentPageURLOutput {set;get;}
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private map<string,integer> MFieldPos;
    private map<string,integer> MLookupFieldPos;
    private map<string,id> MRecTypeID; 
    public boolean hasError {set;get;}
    public string msgCorpCardEmail {set;get;}
    public string msgGenerateTnEEmail {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    
    private Integer rowCount;
    private Integer colCount;
    
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    
    public String country {get;set;}
    public String TnEMessage {get;set;}
    public String reportCorpCard {get;set;}
    public String reportTnE {get;set;}
    
    String statementDateStr;
    String exId;
    String agencyCode;
    String employeeId;
    String idMap;
    String detailYear;
    String detailMonth;
    String departureTime;
    String destinationTime;
    String usageDate;
    
    public ASI_TnE_KR_ProxyDriving_UploadController(){
        User usr = [Select Id, Country From User Where Id =: Userinfo.getUserId()];
        
        if(usr.Country != '' && usr.Country != null){
            if(usr.Country.trim().toLowerCase() == 'korea'){
                recordtypeName = 'KR Proxy Driving';
                country = 'KR';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_KR_ProxyDrivingStatementReport1');
                reportTnE = retrieveTnEReport('ASI_TnE_KR_ProxyDrivingReport');
            }
        }else{
            recordtypeName = 'KR Proxy Driving';
            country = 'KR';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_KR_ProxyDrivingStatementReport1');
            reportTnE = retrieveTnEReport('ASI_TnE_KR_ProxyDrivingReport');
        }
        
        TnEMessage = '';
        msgCorpCardEmail = 'Email Notification will be sent when upload process is completed';
    }
    
    private String retrieveCorpCardReport(String repRecType){
        String reportType = '#';
        List<Report> report = [Select Id, Name, DeveloperName From Report Where DeveloperName =: repRecType];
        
        if(report.size() > 0){
            reportType = '/' + report[0].Id;
        }
        return reportType;
    }
    
    private String retrieveTnEReport(String repRecType){
        String reportType = '#';
        List<Report> report = [Select Id, Name, DeveloperName From Report Where DeveloperName =: repRecType];
        
        if(report.size() > 0){
            reportType = '/' + report[0].Id;// + '?pv2=' + Userinfo.getName();
        }
        return reportType;
    }
    
    public void uploadCSVByBatch(){
        if(country == 'KR'){
            recordtypeName = 'KR Proxy Driving';
            //reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Uploaded');
            //reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
        }
        
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit

            if(currentPageURL == '' || currentPageURL == null){
                //Mass upload log for page without header
                ASI_TnE_Mass_Upload_Log__c uploadLog = new ASI_TnE_Mass_Upload_Log__c();
                insert uploadLog;
                currentPageURL = uploadLog.id;
            }
            statementDateStr = namefile.toLowerCase().left(10);
            if(namefile.toLowerCase().right(3)=='csv'){
                Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=ANSI');
                 
                insert att;
                System.debug(att.parentid + att.name);
                System.debug(ObjAPIName);
                System.debug(parentID);
                System.debug(parentField);
                System.debug(fields);
                System.debug(fieldsLabel);
                System.debug(lookupEXID);
                System.debug(recordtypeName);
                System.debug(defaultValues);
                System.debug(currentPageURL);
                System.debug(att.id);
                System.debug(recEXID);
                System.debug(recEXIDcol);
                System.debug(parentObjectAPIName);
                System.debug(ParentObjectUploadMsg);
                System.debug(upsertMode);
                System.debug(emailNotification);
                msg = 'executeBatch';
                
                BatchId = Database.executeBatch(new ASI_TnE_KR_ProxyDriving_MassUpload(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                    defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                    upsertMode, emailNotification, opt_allOrNone),1);
                
                AttId = att.id;
                msg = 'Batch Started';
            }else{
                    msg = 'Error: Please select csv file only!';
                }
        }else{
            msg = 'Error: File too large';
        }
        TnEMessage = '';
    }
    
    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0){
                    s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    if(aajs[0].Status=='Completed' && AttId!=null){
                        Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                        if(att.description!=null){
                            s = att.description;
                        }
                    }
                    if(TnEMessage != ''){
                        s = '';
                    }
                }
            }
            return s.split('\n');
        }
    }
    
    public void generateTnERecords(){
        Id userId = UserInfo.getUserId();
        //date statementDate = date.newInstance(integer.valueOf(statementDateStr.split('-')[0]), integer.valueOf(statementDateStr.split('-')[1]), integer.valueOf(statementDateStr.split('-')[2]));
        
        Map<String, Schema.SObjectField> cCorpFieldMap = Schema.SObjectType.ASI_TnE_ProxyDriving_Statement_Upload__c.fields.getMap();
        String cCorpQuery = 'Select ';
            
        for(String fields  : cCorpFieldMap.keySet()){
            cCorpQuery += fields + ' ,';
        }

        cCorpQuery = cCorpQuery.subString(0,cCorpQuery.length()-1);
        cCorpQuery += ', Recordtype.Developername From ASI_TnE_ProxyDriving_Statement_Upload__c' + 
                        ' Where OwnerId = \'' + userId + '\'' +
                        ' Order by ASI_TnE_KR_Employee_No__c asc, ASI_TnE_KR_UsageDate__c asc';
        
        List<ASI_TnE_ProxyDriving_Statement_Upload__c> cCardList = (List<ASI_TnE_ProxyDriving_Statement_Upload__c>)Database.query(cCorpQuery); 
        
        if(cCardList.size() < 1){
            TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Statements to Generate! </span></div>';
        }
        
        Set<String> corpCardNumber = new Set<String>();
        Set<String> mccGroup = new Set<String>();
        for(ASI_TnE_ProxyDriving_Statement_Upload__c cCard :cCardList){
            corpCardNumber.add(cCard.ASI_TnE_KR_Employee_No__c);
            //if(cCard.ASI_TnE_MCC_Group__c != null && cCard.ASI_TnE_MCC_Group__c != ''){
                //mccGroup.add(cCard.ASI_TnE_MCC_Group__c);
            //}
        }
        
        Map<String, List<String>> cardNumberEmpMap1 = new Map<String, List<String>>();
        Map<String, List<String>> cardNumberEmpMap2 = new Map<String, List<String>>();
        Map<String, String> cardNumberPayee1 = new Map<String, String>();
        Map<String, String> cardNumberPayee2 = new Map<String, String>();
        Map<String, String> recordTypeMap = new Map<String,String>();
        Map<String, Id> ownerCardNumber = new Map<String, Id>();
		List<User> krUser = new List<User>([SELECT id,ASI_KOR_Commission_Code__c FROM User WHERE ASI_KOR_Commission_Code__c != null]);
        
        for(User obj : krUser){
            ownerCardNumber.put(obj.ASI_KOR_Commission_Code__c,obj.id);
        }
        
        Id claimHeaderRecordType;
        Id claimDetailRecordType;
        //Id mccAccountRecordType;
        if(country == 'KR'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Proxy_Driving_Request__cASI_TnE_KR_Proxy_Driving_Request');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Proxy_Driving_Detail__cASI_TnE_KR_Proxy_Driving');
            //mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_SG_Corp_Card_Merchant_Category_Account_Mapping');
        }
        
        Map<String, List<Date>> claimDateMap = new Map<String, List<Date>>();
        Map<String, Date> claimInvoice = new Map<String, Date>();
        Map<String, String> claimInvoice2 = new Map<String, String>();
        Map<String, String> agencyMap = new Map<String, String>();
        Set<String> checkDup = new Set<String>();
        for(ASI_TnE_ProxyDriving_Statement_Upload__c cCard :cCardList){
            exId = cCard.ASI_TnE_KR_Month__c;
            agencyCode = cCard.ASI_TnE_KR_Proxy_Agency_Code__c;
            employeeId = cCard.ASI_TnE_KR_Employee_No__c;
            detailYear = String.valueOf(cCard.ASI_TnE_KR_Year__c);
            detailMonth = cCard.ASI_TnE_KR_Month__c;
            departureTime = cCard.ASI_TnE_KR_Departure_Time__c;
            destinationTime = cCard.ASI_TnE_KR_Destination_Time__c;
            usageDate = String.valueOf(cCard.ASI_TnE_KR_UsageDate__c);
            if(!claimDateMap.keySet().contains(cCard.ASI_TnE_KR_Employee_No__c)){
                List<Date> dDate = new List<Date>();
                dDate.add(cCard.ASI_TnE_KR_UsageDate__c);
                claimDateMap.put(cCard.ASI_TnE_KR_Employee_No__c, dDate);
            }else{
                claimDateMap.get(cCard.ASI_TnE_KR_Employee_No__c).add(cCard.ASI_TnE_KR_UsageDate__c);
            }
            //claimInvoice.put(cCard.ASI_TnE_KR_Employee_No__c, statementDate);
            claimInvoice2.put((employeeId+agencyCode), (employeeId+'~'+detailYear+'&'+exId+'&'+usageDate+'&'+departureTime+'&'+destinationTime+'#'+agencyCode));
        }
        
        List<String> duplicateClaims = new List<String>();
        List<ASI_TnE_Proxy_Driving_Request__c> tempHeader = new List<ASI_TnE_Proxy_Driving_Request__c>
            ([Select Id, ASI_TnE_KR_PD_External_ID__c From ASI_TnE_Proxy_Driving_Request__c]);
        for(ASI_TnE_Proxy_Driving_Request__c cHeader :tempHeader){
            if(cHeader.ASI_TnE_KR_PD_External_ID__c != null && cHeader.ASI_TnE_KR_PD_External_ID__c != ''){
                //String tempCardNumber = cHeader.ASI_TnE_KR_PD_External_ID__c.split('~')[0];
                String tempCardNumber = cHeader.ASI_TnE_KR_PD_External_ID__c.split('~')[0]
                    +cHeader.ASI_TnE_KR_PD_External_ID__c.split('#')[1];
                //String tempStatementDate = cHeader.ASI_TnE_KR_PD_External_ID__c.split('~')[1];
                String tempStatementDate = cHeader.ASI_TnE_KR_PD_External_ID__c;
                //if(claimInvoice.get(tempCardNumber) != null){
                if(claimInvoice2.get(tempCardNumber) != null){
                    //if(claimInvoice.get(tempCardNumber) == Date.valueOf(tempStatementDate)){
                    if(claimInvoice2.get(tempCardNumber) == tempStatementDate){
                        duplicateClaims.add(cHeader.ASI_TnE_KR_PD_External_ID__c);
                    }
                }
            }
        }
        /*for(String code: claimInvoice2.keySet()){
            integer i = 0;
            System.debug('Code --- '+i + claimInvoice2.get(code));
            i++;
        }*/
        
        List<ASI_TnE_Proxy_Driving_Request__c> claimHeader = new List<ASI_TnE_Proxy_Driving_Request__c>();
        List<String> claimHeaderOtherCardNo = new List<String>();
        for(String code: claimInvoice2.keySet()){
            idMap = claimInvoice2.get(code).split('~')[0];
            List<Date> claimDate = claimDateMap.get(idMap);
            if(ownerCardNumber.get(idMap) != null){
                    Id OwnerVal = ownerCardNumber.get(idMap);
                    ASI_TnE_Proxy_Driving_Request__c claim =
                    	new ASI_TnE_Proxy_Driving_Request__c(
                        OwnerId = OwnerVal,
                        ASI_TnE_KR_PD_Status__c = 'Draft',
                        ASI_TnE_Requester_ID__c = idMap,
                        RecordTypeId = claimHeaderRecordType,
                        ASI_TnE_KR_Year__c = detailYear,
                        ASI_TnE_KR_Month__c = detailMonth,
                        ASI_TnE_Proxy_Agency_Code__c = claimInvoice2.get(code).split('#')[1],
                        ASI_TnE_KR_PD_External_ID__c = claimInvoice2.get(code)
                    );
                    claimHeader.add(claim);
            }//end if
            
            if(ownerCardNumber.get(idMap) == null){
                claimHeaderOtherCardNo.add(idMap);
            }
        }//end for
        
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        Set<String> claimHeaderIds = new Set<String>();
        List<ASI_TnE_Proxy_Driving_Request__c> claimSavePoint = new List<ASI_TnE_Proxy_Driving_Request__c>();
        Boolean tneHasError = false;
        
        TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate Proxy Driving Failed! </span></div>';
        if(claimHeaderOtherCardNo.size() > 0){
            TnEMessage += '<div style="color:blue;">The following employee number does not have appropriate commission code.<ul>';
            for(String cn :claimHeaderOtherCardNo){
                TnEMessage += '<li>' + cn + '</li>';
            }
            TnEMessage += '</ul>Please check the User profile and generate Proxy Driving again.</div><br/><br/>';
            tneHasError = true;
        }
        if(duplicateClaims.size() > 0){
            TnEMessage += '<div style="color:blue;">The following employee number failed to generate Proxy Driving due to duplicate Proxy Driving detected.<ul>';
            for(String cn :duplicateClaims){
                TnEMessage += '<li>' + cn + '</li>';
            }
            tneHasError = true;
        }
        
        if(!tneHasError){
            TnEMessage = '';
            try{
                if(claimHeader.size() > 0){
                    results = database.insert(claimHeader,true);
                    for(Database.SaveResult res: results){
                        if(res.isSuccess()){
                            claimHeaderIds.add(res.getId());
                        }
                    }
                }
               
                if(claimHeaderIds.size() > 0){
                    Map<String, Id> claimheaderMap = new Map<String, Id>();
                    Map<Id, Id> claimheaderMap2 = new Map<Id, Id>();
                    List<ASI_TnE_Proxy_Driving_Request__c> tempHeader2 = new List<ASI_TnE_Proxy_Driving_Request__c>
                        ([Select id, ASI_TnE_Requester_ID__c, ASI_TnE_Proxy_Agency_Code__c From ASI_TnE_Proxy_Driving_Request__c Where Id IN: claimHeaderIds AND recordTypeID =: claimHeaderRecordType]);
                    for(ASI_TnE_Proxy_Driving_Request__c cH :tempHeader2){
                        claimSavePoint.add(cH);
                        claimheaderMap.put((cH.ASI_TnE_Requester_ID__c+cH.ASI_TnE_Proxy_Agency_Code__c), cH.Id);
                    }
                    
                    /*Map<String, String> mccAccountMap = new Map<String, String>();
                    for(ASI_TnE_Corp_Card_MCC_Account_Mapping__c accMap :[Select Id, ASI_TnE_MCC_Group__c, ASI_TnE_Account_Number__c 
                                                                            From ASI_TnE_Corp_Card_MCC_Account_Mapping__c
                                                                            Where ASI_TnE_MCC_Group__c IN: mccGroup
                                                                            AND RecordtypeId =: mccAccountRecordType]){
                        mccAccountMap.put(accMap.ASI_TnE_MCC_Group__c, accMap.ASI_TnE_Account_Number__c);
                    }*/
                    
                    List<ASI_TnE_Proxy_Driving_Detail__c> claimDetail = new List<ASI_TnE_Proxy_Driving_Detail__c>();
                    for(String code: claimInvoice2.keySet()){
                    for(ASI_TnE_ProxyDriving_Statement_Upload__c cCard :cCardList){
                        if(ownerCardNumber.get(cCard.ASI_TnE_KR_Employee_No__c) != null){
                            Id ownerId = ownerCardNumber.get(cCard.ASI_TnE_KR_Employee_No__c);
                            if(claimheaderMap.get(code) != null 
                               &&(claimInvoice2.get(code).split('#')[1] == cCard.ASI_TnE_KR_Proxy_Agency_Code__c)
                               &&(claimInvoice2.get(code).split('~')[0] == cCard.ASI_TnE_KR_Employee_No__c)){
                                Id claimId = claimheaderMap.get(code);
                                ASI_TnE_Proxy_Driving_Detail__c detail = new ASI_TnE_Proxy_Driving_Detail__c(
                                    ASI_TnE_Proxy_Driving_Request__c = claimId,
                                    recordTypeId = claimDetailRecordType,
                                    ASI_TnE_Date__c = cCard.ASI_TnE_KR_UsageDate__c,
                                    ASI_TnE_Departure_Place__c = cCard.ASI_TnE_KR_Departure_Place__c,
                                    ASI_TnE_Departure_Time__c = cCard.ASI_TnE_KR_Departure_Time__c,
                                    ASI_TnE_Destination_Place__c = cCard.ASI_TnE_KR_Destination_Place__c,
                                    ASI_TnE_Destination_Time__c = cCard.ASI_TnE_KR_Destination_Time__c,
                                    ASI_TnE_Phone_No__c = cCard.ASI_TnE_KR_Phone_No__c,
                                    ASI_TnE_First_Dest__c = cCard.ASI_TnE_KR_First_Dest__c,
                                    ASI_TnE_Amount__c = cCard.ASI_TnE_KR_Amount__c,
                                    ASI_TnE_BasicCost__c = cCard.ASI_TnE_KR_BasicCost__c,
                                    ASI_TnE_RoutingCost__c = cCard.ASI_TnE_KR_RoutingCost__c,
                                    ASI_TnE_WOC__c = cCard.ASI_TnE_KR_WOC__c,
                                    ASI_TnE_VAT__c = cCard.ASI_TnE_KR_VAT__c,
                                    ASI_TnE_Discount__c = cCard.ASI_TnE_KR_Discount__c
                                );
                                claimDetail.add(detail);
                            }//end if
                        }//end if
                        }//end for
                    }//end for
                    if(claimDetail.size() > 0){
                        insert claimDetail;
                        /*List<ASI_TnE_ClaimHeader__c> headerList = [Select Id, (Select ASI_TnE_Receipt_Amount__c From ASI_TnE_ClaimDetail__r) From ASI_TnE_ClaimHeader__c WHERE Id In :claimHeaderIds];
                        for(ASI_TnE_ClaimHeader__c h:headerList){
                            h.ASI_TnE_KR_Total_Amount__c = 0;
                            for(ASI_TnE_ClaimDetail__c d:h.ASI_TnE_ClaimDetail__r){
                                h.ASI_TnE_KR_Total_Amount__c += d.ASI_TnE_Receipt_Amount__c;
                            }
                        }
                        update headerList;*/
                        TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully generated Proxy Driving Statement! </span></div>';
                        TnEMessage += '<div style="color:blue;">Please review the generated Proxy Driving Request by clicking this link > <a href="javascript:void(0)" style="color: blue;" onClick="window.open(\'' + reportTnE + '\',\'T&E Report\', \'height=600,width=1000,left=100,top=80,scrollbars=yes,toolbar=no,status=no\')"> View Proxy Driving Report</a><div>';
                    }
                    system.debug('***: ' + TnEMessage);
                }else{
                    TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Record(s) to Generate! </span></div>';
                }
            }catch(DmlException e){
                if(claimSavePoint.size() > 0){
                    delete claimSavePoint;
                }
                TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate Proxy Failed! </span></div>';
                TnEMessage += '<div style="color:red;">';
                for(integer j = 0;j < e.getNumDml(); j++){
                    TnEMessage += 'Row ' + j + ': ' + e.getDmlMessage(j) + '\n';
                }
                TnEMessage += '</div>';
            }
        }
        
        try{
            list<ASI_TnE_ProxyDriving_Statement_Upload__c> corpCardDelete = new List<ASI_TnE_ProxyDriving_Statement_Upload__c>();
            List<ASI_TnE_ProxyDriving_Statement_Upload__c> tempInTray = new List<ASI_TnE_ProxyDriving_Statement_Upload__c>
                ([Select Id From ASI_TnE_ProxyDriving_Statement_Upload__c Where OwnerId =: userId]);
            for(ASI_TnE_ProxyDriving_Statement_Upload__c ccUp: tempInTray){
                corpCardDelete.add(ccUp);
            }
            if(corpCardDelete.size() > 0){
                delete corpCardDelete;
            }
        }catch(DmlException e){
            TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Proxy Driving Statements Deletion Failed! </span></div>';
            TnEMessage += '<div style="color:red;">';
            for(integer j = 0;j < e.getNumDml(); j++){
                TnEMessage += 'Row ' + j + ': ' + e.getDmlMessage(j) + '\n';
            }
            TnEMessage += '</div>';
        }
    }
    
    public void deleteCorpCardStatements(){
        Id userId = UserInfo.getUserId();
        TnEMessage = '';
        list<ASI_TnE_ProxyDriving_Statement_Upload__c> corpCardDelete = new List<ASI_TnE_ProxyDriving_Statement_Upload__c>();
        List<ASI_TnE_ProxyDriving_Statement_Upload__c> tempInTray = new List<ASI_TnE_ProxyDriving_Statement_Upload__c>
                ([Select Id From ASI_TnE_ProxyDriving_Statement_Upload__c Where OwnerId =: userId]);
        for(ASI_TnE_ProxyDriving_Statement_Upload__c ccUp: tempInTray){
            corpCardDelete.add(ccUp);
        }
        if(corpCardDelete.size() > 0){
            delete corpCardDelete;
        }
        TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully deleted all Proxy Driving Statements </span></div>' + 
                        '<div style="color:blue;">Please upload the Proxy Driving Statement file again.</div>';
    }
    
    public void refreshPage2(){
        reloadNeeded = true;
        {
            currentPageUrlOutput = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
    }
    
    // list of valid country for import
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        if(country == 'KR'){
            options.add(new SelectOption('KR','KR'));
        }
        return options;
    }
}