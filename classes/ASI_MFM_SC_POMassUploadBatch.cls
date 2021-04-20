global class ASI_MFM_SC_POMassUploadBatch implements Database.Batchable<String>, Database.Stateful {
    public final Blob content;
    public final Id ownerId;
//    global List<String> badLines;

    public ASI_MFM_SC_POMassUploadBatch(){

    }

    public ASI_MFM_SC_POMassUploadBatch(Blob content, Id ownerId) {
        this.content = content;
        this.ownerId = ownerId;
//        this.badLines = new List<String>();
    }

    List<String> safeSplit(String inStr, String delim) {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;

        List<String> output = new List<String>();

        Matcher m = Pattern.compile(delim).matcher(inStr);

        Integer lastEnd = 0;

        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                } else {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }

                regexFindCount++;
            }

            // Note: Using region() to advance instead of substring() saves
            // drastically on heap size. Nonetheless, we still must reset the
            // (unmodified) input sequence to avoid a 'Regex too complicated'
            // error.
            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());

            regexFindCount = 0;
        }

        return output;
    }

    public boolean badString(String s){
        if (String.isEmpty(s)) {
            return true;
        }
        List<String> values = s.split(',');
        if (values.size() != 15) {
            return true;
        }
        
        if(values[0] ==null || values[0].equals('') || values[1] ==null || values[1].equals(''))
            return true;

        return false;
    }

    public List<String> start(Database.BatchableContext BC) {
        // This methods returns a SOQL query locator containing the records
        List<String> fileLines = safeSplit(this.content.toString(),'\n');
        fileLines.remove(0);

        return fileLines;
    }

    // The executeBatch method is called for each chunk of records returned from start.
    public void execute(Database.BatchableContext BC, List<String> scope) {

        List<String> fileLines = scope;

        List<String> planN = new List<String>();
        List<String> supplierN = new List<String>();
        for (String line : fileLines) {
            if (badString(line)) {
                continue;
            }

            List<String> values = line.split(',');
            planN.add(values[0]);
            supplierN.add(values[1]);
        }

        Map<String, ASI_MFM_plan__c> planM = new Map<String, ASI_MFM_plan__c>();
        for (ASI_MFM_plan__c plan : [SELECT Id, name,asi_mfm_plan_type__c FROM ASI_MFM_plan__c WHERE recordtype.name like 'SC%' and name IN :planN]) {
            planM.put(plan.name, plan);
        }

        Map<String, Id> supplierM = new Map<String, ID>();
        for (account supplier : [SELECT Id, ASI_MFM_Customer_Supplier_Number__c FROM account WHERE recordtype.name='SC Supplier' and ASI_MFM_Customer_Supplier_Number__c IN :supplierN]) {
            supplierM.put(supplier.ASI_MFM_Customer_Supplier_Number__c, supplier.id);
        }
        
        Map<String, Id> buM = new Map<String, ID>();
        for (asi_mfm_bu__c bu : [SELECT Id, name FROM asi_mfm_bu__c WHERE recordtype.name='SC BU' and ASI_MFM_Inactive__c=false]) {
            buM.put(bu.name, bu.id);
        }
        
        Map<String, Id> apM = new Map<String, ID>();
        for (asi_mfm_ap_code__c ap : [SELECT Id, name FROM asi_mfm_ap_code__c WHERE recordtype.name='SC AP Code' and ASI_MFM_Inactive__c=false]) {
            apM.put(ap.name, ap.id);
        }

        
        Id prefixId;
        List<ASI_MFM_Prefix__c> prefixL=[Select id,name from ASI_MFM_Prefix__c where recordtype.name='ASI MFM SC Prefix' and ASI_MFM_Inactive__c=false and ASI_MFM_Module__c='PO'];
        for(ASI_MFM_Prefix__c prefix:prefixL){
            prefixId=prefix.id;
        }
        List<account> subledgerL=[SELECT Id, name FROM account WHERE recordtype.name='HK Subleger'];
        
        date sysDate = date.today();
        Id porecordtype=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO');
        Id poDrecordtype=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item');
        
        List<asi_mfm_po__c> newPOL = new List<asi_mfm_po__c>();
        List<asi_mfm_po_line_item__c> newPODL = new List<asi_mfm_po_line_item__c>();
        
        for (String line : fileLines) {
            System.debug('line : ' + line + ' is bad ? ' +  badString(line));
            //            possible empty line
            if (badString(line)) {
//                badLines.add(line);
                continue;
            }

            List<String> values = line.split(',');
            asi_mfm_po__c po = new asi_mfm_po__c();
            
            po.asi_mfm_plan__c = planM.get(values[0]) != null ? planM.get(values[0]).id: null;
            po.ASI_MFM_PO_Type__c=planM.get(values[0]) != null ? planM.get(values[0]).asi_mfm_plan_type__c :'OPEX';
            po.ASI_MFM_sc_Supplier_Name__c = supplierM.get(values[1]) != null? supplierM.get(values[1]): null;
            po.ASI_MFM_Reference_1__c= values[2] != null? values[2]: null;
            po.ASI_MFM_Reference_2__c= values[3] != null? values[3]: null;
            po.ASI_MFM_Remarks__c= values[4] != null? values[4]: null;
            po.ASI_MFM_PO_Start_Date__c=values[5] != null && !values[5].equals('') ? parseDate(values[5]): sysDate;
            po.ASI_MFM_PO_End_Date__c=values[6] != null && !values[6].equals('')? parseDate(values[6]): sysDate;
            po.ASI_MFM_Currency__c=values[7] != null ? values[7].trim(): null;           
            po.asi_mfm_prefix__c=prefixId;
            po.ASI_MFM_PO_Raised_Date__c=sysDate;                           
            po.RecordTypeId = porecordtype;
            po.OwnerId = this.OwnerId;
                        
            ASI_MFM_PO_Line_Item__c pod=new ASI_MFM_PO_Line_Item__c();
            pod.RecordTypeId = poDrecordtype;
            pod.ASI_MFM_BU_Code__c=values[8] != null ? buM.get(values[8]) != null? buM.get(values[8]): null: null;
            pod.ASI_MFM_AP_Code__c=values[9] != null ? apM.get(values[9]) != null? apM.get(values[9]): null: null;
            
            Id subledgerId=null;
            if(values[10] != null){
                for(account a :subledgerL){
                    if(a.name.containsIgnoreCase(values[10].trim())){
                        subledgerId=a.id;
                        break;
                    }
                }
            }
            pod.asi_mfm_sc_Subledger__c= subledgerId;
            
            pod.ASI_MFM_List_Item_Description__c=values[11] != null ? values[11].trim(): null;
            pod.ASI_MFM_Amount__c=(values[12] != null && values[12].isNumeric())? Integer.valueof(values[12].trim()): null;
            values[14]=values[14] != null? values[14].replace('\r','').replace('\n','') :values[14];
            pod.asi_mfm_Recurring_payment_amount__c=(values[14] != null && values[14].isNumeric())? Integer.valueof(values[14].trim()): null;
            
            po.ASI_MFM_Recurring_payment__c= (values[14] != null && values[14].isNumeric())? True: false;
            po.asi_mfm_Recurring_Payment_day_of_month__c=(values[13] != null && values[13].isNumeric())? Integer.valueof(values[13].trim()): null;
                       
system.debug(pod);
            newPOL.add(po);         
            newPODL.add(pod);
        }

//        System.debug('badLines : ' + badLines);
//        System.debug('isEmpty : ' + badLines.isEmpty());

        try {
 //           Savepoint sp = Database.setSavepoint();
            Database.SaveResult[] srList = Database.insert(newPOL, false);
            
            integer i=0;
            for(Database.SaveResult sr: srList){
                if(sr.isSuccess()){
                    system.debug('PO header creates successful '+sr.getId()); 
                    newPODL[i].asi_mfm_po__c=sr.getId();
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('PO fields that affected this error: ' + err.getFields());        
                    }
//                  Database.rollback(sp);
                }
                i++;
            }
                  
            srList = Database.insert(newPODL, false); 
            i=0;
            for(Database.SaveResult sr: srList){
                if(sr.isSuccess()){
                    system.debug('PO detail creates successful '+sr.getId()); 
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('PO fields that affected this error: ' + err.getFields());        
                    }
//                  Database.rollback(sp);
                }
                i++;
            }
                     
            
        } catch (Exception e) {
            throw e;
        }
    }

    public void finish(Database.BatchableContext BC) {
        User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

        List<Messaging.Email> emails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        System.debug('badLines in finish method : ' + badLines);
//
//        if (badLines.isEmpty()) {
//            mail.setSubject('Mass Upload Process is completed');
//
//            mail.setHtmlBody('Your mass upload submission was processed.<br/>' + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>');
//            mail.setPlainTextBody('Your mass upload submission was processed.\n' + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\n');
//        } else {
//            mail.setSubject('Mass Upload Process failed');
//
//            mail.setHtmlBody('Your mass upload submission failed.<br/>Please fix the following lines:<br/>' + String.join(badLines, '<br/>') + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>');
//
//        }
        mail.setSubject('Mass Upload Process is completed');

        mail.setHtmlBody('Your mass upload submission was processed.<br/>' + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you have received this message in error.<br/>');
        mail.setPlainTextBody('Your mass upload submission was processed.\n' + '\n\nPlease do not reply to this message.\nContact your system administrator if you have received this message in error.\n');

        mail.setToAddresses(new List<String>{ u.email });
        emails.add(mail);
        Messaging.sendEmail(emails);

    }
    
    private Date parseDate(String inDate) {
        Date dateRes = null;
        try {
            String candDate    = inDate.substring(0,Math.min(10,inDate.length()));
            dateRes= Date.parse(candDate);
        }catch (Exception e) {}

        if (dateRes == null) {
            try {
                String candDate= inDate.substring(0,10);           // grab date portion only, ignore time, if any
                dateRes= Date.valueOf(candDate);
            }
            catch (Exception e) {}
        }
        return dateRes;
    }



}