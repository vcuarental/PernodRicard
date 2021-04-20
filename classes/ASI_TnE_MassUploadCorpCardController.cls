/*********************************************************************************
    * Name: ASI_TnE_MassUploadCorpCardController
    * Description: Controller for ASI_TnE_MassUploadCorpCardComponent. Upload .csv format file to Corp Card Object
    *
    * Version History
    * 2015-03-02        Laputa                  Create
    * 2016-01-18        IPC-DC                  2.0 - Added logic to populate "Name & Company"
    *                                           field on Claim Details.
    * 25/07/2016        Laputa: Hugo Cheung     Updated. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c
    * 29/12/2017        Introv: Linus Ho        Updated. Adding KH(Cambodge) same as SG
*********************************************************************************/ 
public class ASI_TnE_MassUploadCorpCardController {
    //Attributes
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
    
    public String currencyStr {get;set;}
    
    public ASI_TnE_MassUploadCorpCardController(){
        User usr = [Select Id, Country From User Where Id =: Userinfo.getUserId()];
        
        if(usr.Country != '' && usr.Country != null){
            if(usr.Country.trim().toLowerCase() == 'singapore'){
                recordtypeName = 'ASI TnE SG Corp Card Upload';
                country = 'SGP';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Upload');
                reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
                currencyStr = 'SGD';
            }else if(usr.Country.trim().toLowerCase() == 'cambodge'){
                recordtypeName = 'ASI TnE KH Corp Card Upload';
                country = 'KHR';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_KH_Corp_Card_Statement_Upload');
                reportTnE = retrieveTnEReport('ASI_TnE_KH_Corp_Card_TnE_Generated_Rpt');
                currencyStr = 'KHR';
            }else if(usr.Country.trim().toLowerCase() == 'hong kong'){
                recordtypeName = 'ASI TnE HK Corp Card Upload';
                country = 'HKG';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_HK_Corp_Card_Statement_Upload');
                reportTnE = retrieveTnEReport('ASI_TnE_HK_Corp_Card_T_E_Generated_Rpt');
                currencyStr = 'HKD';
            }else if(usr.Country.trim().toLowerCase() == 'malaysia'){
                recordtypeName = 'ASI TnE MY Corp Card Upload';
                country = 'MYS';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_MY_Corp_Card_Statement_Upload');
                reportTnE = retrieveTnEReport('ASI_TnE_MY_Corp_Card_T_E_Generated_Rpt');
                currencyStr = 'MYR';
            }else if(usr.Country.trim().toLowerCase() == 'thailand'){
                recordtypeName = 'ASI TnE TH Corp Card Upload';
                country = 'THA';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_TH_Corp_Card_Statement_Upload');
                reportTnE = retrieveTnEReport('ASI_TnE_TH_Corp_Card_TnE_Generated_Rpt');
                currencyStr = 'THB';
            }else if(usr.Country.trim().toLowerCase() == 'taiwan'){
                recordtypeName = 'ASI TnE TW Corp Card Upload';
                country = 'TWN';
                reportCorpCard = retrieveCorpCardReport('ASI_TnE_TW_Corp_Card_Statement_Uploaded');
                reportTnE = retrieveTnEReport('ASI_TnE_TW_Corp_Card_T_E_Generated');
                currencyStr = 'TWD';
            }
        }else{
            recordtypeName = 'ASI TnE SG Corp Card Upload';
            country = 'SGP';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
            currencyStr = 'SGD';
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
            reportType = '/' + report[0].Id + '?pv2=' + Userinfo.getName();
        }
        return reportType;
    }
    
    public void uploadCSVByBatch(){
        if(country == 'SGP'){
            recordtypeName = 'ASI TnE SG Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
            currencyStr = 'SGD';
        }else if(country == 'KHR'){
            recordtypeName = 'ASI TnE KH Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_KH_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_KH_Corp_Card_TnE_Generated_Rpt');
            currencyStr = 'KHR';
        }else if(country == 'HKG'){
            recordtypeName = 'ASI TnE HK Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_HK_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_HK_Corp_Card_T_E_Generated_Rpt');
            currencyStr = 'HKD';
        }else if(country == 'MYS'){
            recordtypeName = 'ASI TnE MY Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_MY_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_MY_Corp_Card_T_E_Generated_Rpt');
            currencyStr = 'MYR';
        }else if(country == 'TWN'){
            recordtypeName = 'ASI TnE TW Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_TW_Corp_Card_Statement_Uploaded');
            reportTnE = retrieveTnEReport('ASI_TnE_TW_Corp_Card_T_E_Generated');
            currencyStr = 'TWD';
        }else if(country == 'THA'){
            recordtypeName = 'ASI TnE TH Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_TH_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_TH_Corp_Card_TnE_Generated_Rpt');
            currencyStr = 'THB';
        }else{
            recordtypeName = 'ASI TnE SG Corp Card Upload';
            reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Upload');
            reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
            currencyStr = 'SGD';
        }
        
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit

            if(currentPageURL == '' || currentPageURL == null){
                //Mass upload log for page without header
                ASI_TnE_Mass_Upload_Log__c uploadLog = new ASI_TnE_Mass_Upload_Log__c();
                insert uploadLog;
                currentPageURL = uploadLog.id;
            }
            if(namefile.toLowerCase().right(3)=='csv'){
                Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                 
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
                
                BatchId = Database.executeBatch(new ASI_TnE_MassUploadCorpCardBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
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
        
        Map<String, Schema.SObjectField> cCorpFieldMap = Schema.SObjectType.ASI_TnE_Corp_Card_Statement_Upload__c.fields.getMap();
        String cCorpQuery = 'Select ';
            
        for(String fields  : cCorpFieldMap.keySet()){
            cCorpQuery += fields + ' ,';
        }

        cCorpQuery = cCorpQuery.subString(0,cCorpQuery.length()-1);
        cCorpQuery += ', Recordtype.Developername From ASI_TnE_Corp_Card_Statement_Upload__c' + 
                        ' Where OwnerId = \'' + userId + '\'' +
                        ' Order by ASI_TnE_Card_Number__c asc, ASI_TnE_Charge_Date__c asc';
        
        List<ASI_TnE_Corp_Card_Statement_Upload__c> cCardList = (List<ASI_TnE_Corp_Card_Statement_Upload__c>)Database.query(cCorpQuery); 
        
        if(cCardList.size() < 1){
            TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Statements to Generate! </span></div>';
        }
        
        Set<String> corpCardNumber = new Set<String>();
        Set<String> mccGroup = new Set<String>();
        for(ASI_TnE_Corp_Card_Statement_Upload__c cCard :cCardList){
            corpCardNumber.add(cCard.ASI_TnE_Card_Number__c);
            if(cCard.ASI_TnE_MCC_Group__c != null && cCard.ASI_TnE_MCC_Group__c != ''){
                mccGroup.add(cCard.ASI_TnE_MCC_Group__c);
            }
        }
        
        Map<String, List<String>> cardNumberEmpMap1 = new Map<String, List<String>>();
        Map<String, List<String>> cardNumberEmpMap2 = new Map<String, List<String>>();
        Map<String, String> cardNumberPayee1 = new Map<String, String>();
        Map<String, String> cardNumberPayee2 = new Map<String, String>();
        
        Map<String, Id> ownerCardNumber = new Map<String, Id>();
        Map<String, Id> employeeCardNumber = new Map<String, Id>();
        for(ASI_TnE_Corp_Card_Employee_Mapping__c empList :[Select Id, ASI_TnE_Assistant_Name__c, ASI_TnE_Employee_Name__c, ASI_TnE_Card_Number_1__c, ASI_TnE_Card_Number_2__c,
                                                            ASI_TnE_Exclude_1__c, ASI_TnE_Exclude_2__c, ASI_TnE_Card_Issuer_1__c, ASI_TnE_Card_Issuer_2__c
                                                            From ASI_TnE_Corp_Card_Employee_Mapping__c
                                                            Where ASI_TnE_Card_Number_1__c IN: corpCardNumber OR ASI_TnE_Card_Number_2__c IN: corpCardNumber]){
            System.debug('empList ' + empList);

            if(empList.ASI_TnE_Card_Number_1__c != '' && empList.ASI_TnE_Card_Number_1__c != null){
                if(!empList.ASI_TnE_Exclude_1__c){
                    List<String> tempArr = new List<String>();
                    tempArr.add(empList.ASI_TnE_Employee_Name__c);                  
                    ownerCardNumber.put(empList.ASI_TnE_Card_Number_1__c, empList.ASI_TnE_Employee_Name__c);
                    employeeCardNumber.put(empList.ASI_TnE_Card_Number_1__c, empList.ASI_TnE_Employee_Name__c);
                    
                    System.debug('tempArr ' + tempArr);

                    if(empList.ASI_TnE_Assistant_Name__c != null){
                        tempArr.add(empList.ASI_TnE_Assistant_Name__c);
                        ownerCardNumber.put(empList.ASI_TnE_Card_Number_1__c, empList.ASI_TnE_Assistant_Name__c);
                    }
                    cardNumberEmpMap1.put(empList.ASI_TnE_Card_Number_1__c, tempArr);
                    if(empList.ASI_TnE_Card_Issuer_1__c != null){
                        cardNumberPayee1.put(empList.ASI_TnE_Card_Number_1__c, empList.ASI_TnE_Card_Issuer_1__c);
                    }
                }
            }
            
            if(empList.ASI_TnE_Card_Number_2__c != '' && empList.ASI_TnE_Card_Number_2__c != null){
                if(!empList.ASI_TnE_Exclude_2__c){
                    List<String> tempArr = new List<String>();
                    tempArr.add(empList.ASI_TnE_Employee_Name__c);
                    ownerCardNumber.put(empList.ASI_TnE_Card_Number_2__c, empList.ASI_TnE_Employee_Name__c);
                    employeeCardNumber.put(empList.ASI_TnE_Card_Number_2__c, empList.ASI_TnE_Employee_Name__c);

                    System.debug('tempArr2 ' + tempArr);

                    if(empList.ASI_TnE_Assistant_Name__c != null){
                        tempArr.add(empList.ASI_TnE_Assistant_Name__c);
                        ownerCardNumber.put(empList.ASI_TnE_Card_Number_2__c, empList.ASI_TnE_Assistant_Name__c);
                    }

                    cardNumberEmpMap2.put(empList.ASI_TnE_Card_Number_2__c, tempArr);
                    
                    if(empList.ASI_TnE_Card_Issuer_2__c != null){
                        cardNumberPayee2.put(empList.ASI_TnE_Card_Number_2__c, empList.ASI_TnE_Card_Issuer_2__c);
                    }
                }
            }
        }
        
        Id claimHeaderRecordType;
        Id claimDetailRecordType;
        Id mccAccountRecordType;
        if(country == 'SGP'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_SG_Corp_Card_Merchant_Category_Account_Mapping');
        }else if(country == 'KHR'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_KH_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_KH_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_KH_Corp_Card_Merchant_Category_Account_Mapping');
        }else if(country == 'HKG'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_HK_Corp_Card_Merchant_Category_Account_Mapping');
        }else if(country == 'MYS'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_MY_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_MY_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_MY_Corp_Card_Merchant_Category_Account_Mapping');
        }else if(country == 'TWN'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_TW_Corp_Card_Merchant_Category_Account_Mapping');
        }else if(country == 'THA'){
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_TH_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_TH_Corp_Card_Merchant_Category_Account_Mapping');
        }else{
            claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
            mccAccountRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_SG_Corp_Card_Merchant_Category_Account_Mapping');
        }
        
        Map<String, List<Date>> claimDateMap = new Map<String, List<Date>>();
        Map<String, Date> claimInvoice = new Map<String, Date>();
        Set<String> checkDup = new Set<String>();
        for(ASI_TnE_Corp_Card_Statement_Upload__c cCard :cCardList){
            if(!claimDateMap.keySet().contains(cCard.ASI_TnE_Card_Number__c)){
                List<Date> dDate = new List<Date>();
                dDate.add(cCard.ASI_TnE_Charge_Date__c);
                claimDateMap.put(cCard.ASI_TnE_Card_Number__c, dDate);
            }else{
                claimDateMap.get(cCard.ASI_TnE_Card_Number__c).add(cCard.ASI_TnE_Charge_Date__c);
            }
            claimInvoice.put(cCard.ASI_TnE_Card_Number__c, cCard.ASI_TnE_Statement_Date__c);
        }
        
        List<String> duplicateClaims = new List<String>();
        for(ASI_TnE_ClaimHeader__c cHeader :[Select Id, ASI_TnE_Invoice_No__c From ASI_TnE_ClaimHeader__c WHERE ASI_TnE_Invoice_No__c <> NULL AND ASI_TnE_Type__c = 'Corp Card'
                                                AND (recordtype.developerName LIKE 'ASI_TnE_TH%' OR recordtype.developerName LIKE 'ASI_TnE_SG%' OR recordtype.developerName LIKE 'ASI_TnE_HK%' OR recordtype.developerName LIKE 'ASI_TnE_TW%' OR recordtype.developerName LIKE 'ASI_TnE_MY%' OR recordtype.developerName LIKE 'ASI_TnE_KH%')]){
            if(cHeader.ASI_TnE_Invoice_No__c != null && cHeader.ASI_TnE_Invoice_No__c != ''){
                if(cHeader.ASI_TnE_Invoice_No__c.split('/').size() > 1) {
                    String tempCardNumber = cHeader.ASI_TnE_Invoice_No__c.split('/')[0];
                    String tempStatementDate = cHeader.ASI_TnE_Invoice_No__c.split('/')[1];
                    if(claimInvoice.get(tempCardNumber) != null && tempStatementDate != null && tempStatementDate != '' && tempStatementDate != 'null'){
                        Datetime claimInvoiceDateTime = claimInvoice.get(tempCardNumber);
                        String claimInvoiceDateTimeStr = claimInvoiceDateTime.format('ddMMMyy');
                        if(claimInvoiceDateTimeStr == tempStatementDate){
                            duplicateClaims.add(cHeader.ASI_TnE_Invoice_No__c);
                        }
                    }
                }
            }
        }
        
        List<ASI_TnE_ClaimHeader__c> claimHeader = new List<ASI_TnE_ClaimHeader__c>();
        List<String> claimHeaderOtherCardNo = new List<String>();
        System.debug('claimDateMap ' + claimDateMap);
        for(String cMap :claimDateMap.keySet()){
            List<Date> claimDate = claimDateMap.get(cMap);

            System.debug('cMap ' + cMap);

            if(cardNumberEmpMap1.get(cMap) != null){

                System.debug('cardNumberEmpMap1.get(cMap) ' + cardNumberEmpMap1.get(cMap));

                List<String> map1Temp = cardNumberEmpMap1.get(cMap);
                if(map1Temp.size() > 0){
                    Id OwnerVal = null;
                    Id PayeeVal = null;
                    if(map1Temp.size() == 1){
                        OwnerVal = map1Temp[0];
                    }else{
                        OwnerVal = map1Temp[1];
                        PayeeVal = map1Temp[0];
                    }
                    
                    Id payeeSup = null;
                    if(cardNumberPayee1.get(cMap) != null){
                        payeeSup = cardNumberPayee1.get(cMap);
                    }
                    
                    Datetime dateInvoice = claimInvoice.get(cMap);
                    String dateInvoiceStr = dateInvoice.format('ddMMMyy');

                    ASI_TnE_ClaimHeader__c claim = new ASI_TnE_ClaimHeader__c(
                        OwnerId = OwnerVal,
                        ASI_TnE_Payee_Employee__c = PayeeVal,
                        ASI_TnE_Status__c = 'Draft',
                        ASI_TnE_Type__c = 'Corp Card',
                        ASI_TnE_Start_Date__c = claimDate[0],
                        ASI_TnE_End_Date__c = claimDate[claimDate.size() - 1],
                        RecordTypeId = claimHeaderRecordType,
                        ASI_TnE_Payee_Supplier__c = payeeSup,
                        ASI_TnE_Invoice_No__c = cMap + '/' + dateInvoiceStr
                    );
                    
                    //Hugo Cheung 17/01/2017 Assign Statement Date to Invoice Date for HK T&E Record
                    if(Global_RecordTypeCache.getRt(claim.recordTypeid).developerName.contains('ASI_TnE_HK')) {
                        claim.ASI_TnE_Invoice_Date__c = date.newinstance(dateInvoice.year(), dateInvoice.month(), dateInvoice.day());                  
                    }
                    
                    claimHeader.add(claim);
                }
            }
            
            if(cardNumberEmpMap2.get(cMap) != null){

                System.debug('cardNumberEmpMap2.get(cMap) ' + cardNumberEmpMap2.get(cMap));

                List<String> map2Temp = cardNumberEmpMap2.get(cMap);
                if(map2Temp.size() > 0){
                    Id OwnerVal = null;
                    Id PayeeVal = null;

                    if(map2Temp.size() == 1){
                        OwnerVal = map2Temp[0];
                    }else{
                        OwnerVal = map2Temp[1];
                        PayeeVal = map2Temp[0];
                    }

                    Id payeeSup = null;
                    if(cardNumberPayee2.get(cMap) != null){
                        payeeSup = cardNumberPayee2.get(cMap);
                    }

                    Datetime dateInvoice = claimInvoice.get(cMap);
                    String dateInvoiceStr = dateInvoice.format('ddMMMyy');

                    ASI_TnE_ClaimHeader__c claim = new ASI_TnE_ClaimHeader__c(
                        OwnerId = OwnerVal,
                        ASI_TnE_Status__c = 'Draft',
                        ASI_TnE_Type__c = 'Corp Card',
                        ASI_TnE_Start_Date__c = claimDate[0],
                        ASI_TnE_End_Date__c = claimDate[claimDate.size() - 1],
                        RecordTypeId = claimHeaderRecordType,
                        ASI_TnE_Payee_Supplier__c = payeeSup,
                        ASI_TnE_Payee_Employee__c = PayeeVal,
                        ASI_TnE_Invoice_No__c = cMap + '/' + dateInvoiceStr
                    );
                    
                    //Hugo Cheung 17/01/2017 Assign Statement Date to Invoice Date for HK T&E Record
                    if(Global_RecordTypeCache.getRt(claim.recordTypeid).developerName.contains('ASI_TnE_HK')) {
                        claim.ASI_TnE_Invoice_Date__c = date.newinstance(dateInvoice.year(), dateInvoice.month(), dateInvoice.day());                  
                    }
                    
                    claimHeader.add(claim);
                }
            }
            
            if(cardNumberEmpMap1.get(cMap) == null && cardNumberEmpMap2.get(cMap) == null){
                claimHeaderOtherCardNo.add(cMap);
            }
        }
        
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        Set<String> claimHeaderIds = new Set<String>();
        List<ASI_TnE_ClaimHeader__c> claimSavePoint = new List<ASI_TnE_ClaimHeader__c>();
        Boolean tneHasError = false;
        
        TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate T&E Failed! </span></div>';
        if(claimHeaderOtherCardNo.size() > 0){
            TnEMessage += '<div style="color:blue;">The following Card No. below does not have a match on the employee mapping table.<ul>';
            for(String cn :claimHeaderOtherCardNo){
                TnEMessage += '<li>' + cn + '</li>';
            }
            TnEMessage += '</ul>Please add the mapping to generate T&E again.</div><br/><br/>';
            tneHasError = true;
        }
        if(duplicateClaims.size() > 0){
            TnEMessage += '<div style="color:blue;">The following Card No. below failed to generage T&E due to duplicate T&E detected.<ul>';
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
                    Map<ID, User> userMap = new Map<ID, User>();
                    Set<ID> userIDSet = new Set<ID>();

                    Map<String, ASI_TnE_ClaimHeader__c> claimheaderMap = new Map<String, ASI_TnE_ClaimHeader__c>();

                    for(ASI_TnE_ClaimHeader__c cH :[Select id, OwnerId, ASI_TnE_Payee_Employee__c From ASI_TnE_ClaimHeader__c Where Id IN: claimHeaderIds]){
                        claimSavePoint.add(cH);
                        //Cater same Assistant name
                        if(cH.ASI_TnE_Payee_Employee__c != null && cH.ASI_TnE_Payee_Employee__c != cH.OwnerId)
                        {
                           claimheaderMap.put((String)cH.OwnerId+(String)ch.ASI_TnE_Payee_Employee__c, cH); 
                        } else {
                          claimheaderMap.put(cH.OwnerId, cH);  
                        }
                        
                        userIDSet.add(cH.OwnerId);
                        if(cH.ASI_TnE_Payee_Employee__c != null) {
                            userIDSet.add(cH.ASI_TnE_Payee_Employee__c);
                        }
                    }

                    userMap = new Map<ID, User>([SELECT ID, Name, ASI_TnE_Sub_Ledger__c FROM User WHERE ID IN : userIDSet]);
                    
                    Map<String, String> mccAccountMap = new Map<String, String>();
                    for(ASI_TnE_Corp_Card_MCC_Account_Mapping__c accMap :[Select Id, ASI_TnE_MCC_Group__c, ASI_TnE_Account_Number__c 
                                                                            From ASI_TnE_Corp_Card_MCC_Account_Mapping__c
                                                                            Where ASI_TnE_MCC_Group__c IN: mccGroup
                                                                            AND RecordtypeId =: mccAccountRecordType]){
                        mccAccountMap.put(accMap.ASI_TnE_MCC_Group__c, accMap.ASI_TnE_Account_Number__c);
                    }

                    List<ASI_TnE_ClaimDetail__c> claimDetail = new List<ASI_TnE_ClaimDetail__c>();
                    Decimal rptNo = 1;
                    ID previousClaimID;
                    for(ASI_TnE_Corp_Card_Statement_Upload__c cCard :cCardList){
                        
                        if(ownerCardNumber.get(cCard.ASI_TnE_Card_Number__c) != null){
                            String ownerId = (String)ownerCardNumber.get(cCard.ASI_TnE_Card_Number__c);
                            String employeeID = (String)employeeCardNumber.get(cCard.ASI_TnE_Card_Number__c) != null ? (String)employeeCardNumber.get(cCard.ASI_TnE_Card_Number__c) : '';
                            String keyID = ownerId == employeeID ? ownerId : ownerId + employeeID;

                            if(claimheaderMap.get(keyID) != null){
                                Id claimId = claimheaderMap.get(keyID).id;
                                
                                if(previousClaimID == null) {
                                    previousClaimID = claimId;
                                } else if (previousClaimID != claimId) {
                                    previousClaimID = claimId;
                                    rptNo = 1;
                                }
                                
                                Id payeeEmployeeID = claimheaderMap.get(keyID).ASI_TnE_Payee_Employee__c;

                                String mccAccount = '';
                                if(mccAccountMap.get(cCard.ASI_TnE_MCC_Group__c) != null && country == 'HKG'){
                                    mccAccount = mccAccountMap.get(cCard.ASI_TnE_MCC_Group__c);
                                }
                                
                                String mccGroupStr = '';
                                
                                
                                if(country != 'SGP' && country != 'THA') {
                                    //mccGroupStr = cCard.ASI_TnE_MCC_Group__c;
                                }
                                
                                String subLedgerStr = (payeeEmployeeID != null && userMap.containsKey(payeeEmployeeID)) ? userMap.get(payeeEmployeeID).ASI_TnE_Sub_Ledger__c : userMap.get(ownerId).ASI_TnE_Sub_Ledger__c ;
                                
                                ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
                                    ASI_TnE_ClaimHeader__c = claimId,
                                    recordTypeId = claimDetailRecordType,
                                    ASI_TnE_Receipt_Date__c = cCard.ASI_TnE_Charge_Date__c,
                                    ASI_TnE_Invoice_Issuer__c = cCard.ASI_TnE_Supplier_Name__c,
                                    ASI_TnE_Description__c = cCard.ASI_TnE_Transaction_Description__c,
                                    ASI_TnE_Details_of_Expense__c = cCard.ASI_TnE_Transaction_Description__c,
                                    ASI_TnE_Currency__c = currencyStr,
                                    ASI_TnE_Receipt_Amount__c = cCard.ASI_TnE_Amount__c,
                                    ASI_TnE_FX_Rate__c = 1,
                                    ASI_TnE_Account_Number__c = mccGroupStr,
                                    ASI_TnE_SG_Sub_Ledger__c = subLedgerStr,
                                    ASI_TnE_MCC_Group__c = mccAccount,
                                    ASI_TnE_Receipt_Number__c = rptNo,
                                    // DC 2.0 - Set Name & Company field on claim details.
                                    ASI_TnE_Name_Company__c = cCard.ASI_TnE_Name_Company__c
                                );
                                
                                claimDetail.add(detail);
                                rptNo++;
                            }
                        }
                    }
                    if(claimDetail.size() > 0){
                        insert claimDetail;
                        List<ASI_TnE_ClaimHeader__c> headerList = [Select Id, ASI_TnE_Total_Amount_Approved__c, (Select ASI_TnE_HK_Payment_Amount__c,ASI_TnE_Payment_Amount__c, ASI_TnE_TW_Payment_Amount__c From ASI_TnE_ClaimDetail__r) From ASI_TnE_ClaimHeader__c WHERE Id In :claimHeaderIds];
                        for(ASI_TnE_ClaimHeader__c h:headerList){
                            h.ASI_TnE_Total_Amount_Approved__c = 0;
                            for(ASI_TnE_ClaimDetail__c d:h.ASI_TnE_ClaimDetail__r){
                                if(country == 'TWN'){
                                    h.ASI_TnE_Total_Amount_Approved__c += d.ASI_TnE_TW_Payment_Amount__c;
                                }else{
                                    h.ASI_TnE_Total_Amount_Approved__c += d.ASI_TnE_HK_Payment_Amount__c;
                                }
                            }
                        }
                        update headerList;
                        TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully generated T&E! </span></div>';
                        TnEMessage += '<div style="color:blue;">Please review the generated T&E by clicking this link > <a href="javascript:void(0)" style="color: blue;" onClick="window.open(\'' + reportTnE + '\',\'T&E Report\', \'height=600,width=1000,left=100,top=80,scrollbars=yes,toolbar=no,status=no\')"> View T&E Report</a><div>';
                    }
                    system.debug('***: ' + TnEMessage);
                }else{
                    TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Record(s) to Generate! </span></div>';
                }
            }catch(DmlException e){
                if(claimSavePoint.size() > 0){
                    delete claimSavePoint;
                }
                TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate T&E Failed! </span></div>';
                TnEMessage += '<div style="color:red;">';
                for(integer j = 0;j < e.getNumDml(); j++){
                    TnEMessage += 'Row ' + j + ': ' + e.getDmlMessage(j) + '\n';
                }
                TnEMessage += '</div>';
            }
        }
        
        try{
            //list<ASI_TnE_Corp_Card_Statement_Upload__c> corpCardDelete = new List<ASI_TnE_Corp_Card_Statement_Upload__c>();
            /*
            for(ASI_TnE_Corp_Card_Statement_Upload__c ccUp: [Select Id From ASI_TnE_Corp_Card_Statement_Upload__c Where OwnerId =: userId]){
                corpCardDelete.add(ccUp);
            }
            */
            if(cCardList.size() > 0){
                delete cCardList;
            }
        }catch(DmlException e){
            TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Corp Card Statements Deletion Failed! </span></div>';
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
        list<ASI_TnE_Corp_Card_Statement_Upload__c> corpCardDelete = new List<ASI_TnE_Corp_Card_Statement_Upload__c>();
        for(ASI_TnE_Corp_Card_Statement_Upload__c ccUp: [Select Id From ASI_TnE_Corp_Card_Statement_Upload__c Where OwnerId =: userId]){
            corpCardDelete.add(ccUp);
        }
        if(corpCardDelete.size() > 0){
            delete corpCardDelete;
        }
        TnEMessage += '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully deleted all Corp Card Statements </span></div>' + 
                        '<div style="color:blue;">Please upload the Corp Card Statement file again.</div>';
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
        if(country == 'HKG'){
            options.add(new SelectOption('HKG','HKG'));
        }else if(country == 'TWN'){
            options.add(new SelectOption('TWN','TWN'));
        }else if(country == 'MYS'){
            options.add(new SelectOption('MYS','MYS'));
        }else if(country == 'THA'){
            options.add(new SelectOption('THA','THA'));
        }else{
            options.add(new SelectOption('SGP','SGP'));
            options.add(new SelectOption('THA','THA'));
            options.add(new SelectOption('KHR','KHR'));
        }
        return options;
    }
}