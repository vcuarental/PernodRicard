global class ASI_MFM_SC_PayDetailMassUploadBatch implements Database.Batchable<String>, Database.Stateful {
    public final Blob content;
    public final Id ownerId,payheaderId;
    public string poHeaderName;
//    global List<String> badLines;

    public ASI_MFM_SC_PayDetailMassUploadBatch(){

    }

    public ASI_MFM_SC_PayDetailMassUploadBatch(Blob content, Id ownerId, Id payheaderId,String poHeaderName) {
        this.content = content;
        this.ownerId = ownerId;
        this.payheaderId=payheaderId;
        this.poHeaderName=poHeaderName;
 System.debug('headerid='+payheaderId+','+poHeaderName)     ;  
//        this.badLines = new List<String>();
    }

    /**
* Split a string of any size, while avoiding the dreaded 'Regex too complicated'
* error, which the String.split(String) method causes on some large inputs.
*
* Note that this method does not avoid other errors, such as those related to
* excess heap size or CPU time.
*/
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
        if (values.size() != 6) {
            return true;
        }

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
        
        for (String line : fileLines) {
//            possible empty line
            if (badString(line)) {
                continue;
            }
        }
               
        Map<String,Id> buM = new Map<String,Id>();
        for (asi_mfm_bu__c bu : [SELECT Id, name FROM asi_mfm_bu__c WHERE recordtype.name='SC BU' and ASI_MFM_Inactive__c=false]) {
            buM.put(bu.name, bu.id);
        }
        
        Map<String,Id> apM = new Map<String,Id>();
        Map<String,Id> apacM = new Map<String,Id>();
        for (asi_mfm_ap_code__c ap : [SELECT Id, name,ASI_MFM_A_C_Code__c FROM asi_mfm_ap_code__c WHERE recordtype.name='SC AP Code' and ASI_MFM_Inactive__c=false]) {
            apM.put(ap.name, ap.id);
            apacM.put(ap.name, ap.ASI_MFM_A_C_Code__c);
        }
        
        Map<String, Id> poDM1 = new Map<String, Id>();
        Map<String, Id> poDM2 = new Map<String, Id>();
        for (ASI_MFM_po_line_item__c pod : [SELECT Id,name,asi_mfm_bu_code__r.name, asi_mfm_ap_code__r.name FROM ASI_MFM_po_line_item__c WHERE recordtype.name ='SC PO Line Item' and asi_mfm_po__r.name = :poHeaderName]) {
            poDM1.put(pod.name, pod.id);
 System.debug(pod.asi_mfm_bu_code__r.name+'_'+pod.asi_mfm_ap_code__r.name);           
            poDM2.put(pod.asi_mfm_bu_code__r.name+'_'+pod.asi_mfm_ap_code__r.name, pod.id);
        }
        
        List<account> subledgerL=[SELECT Id, name FROM account WHERE recordtype.name='HK Subleger'];
        
   
        date sysDate = date.today();
        Id payDrecordtype=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item');
        
        List<ASI_MFM_Payment_Line_Item__c> newPayDL = new List<ASI_MFM_Payment_Line_Item__c>();
        
        for (String line : fileLines) {
            System.debug('line : ' + line + ' is bad ? ' +  badString(line));
            //            possible empty line
            if (badString(line)) {
//                badLines.add(line);
                continue;
            }
//PO Line Item ID, BU Code, AP Code, Subledger sc, Payment Amount, Payment List Item Description

            List<String> values = line.split(',');
            ASI_MFM_Payment_Line_Item__c payd=new ASI_MFM_Payment_Line_Item__c();
            payd.RecordTypeId = payDrecordtype;
            Id poL=null;
          
            if(values[0] != null && !values[0].trim().equals('') )
                poL=poDM1.get(values[0]);
            else{
                if(buM.get(values[1]) != null && apM.get(values[2]) != null){
                    poL=poDM2.get(values[1].trim()+'_'+values[2].trim());
                }
            }    
            
            Id subledgerId=null;
            if(values[3] != null && !values[3].trim().equals('')){
                for(account a :subledgerL){
                    if(a.name.containsIgnoreCase(values[3].trim())){
                        subledgerId=a.id;
                        break;
                    }
                }
            }
            payd.ASI_MFM_Payment__c=payheaderId;
            payd.ASI_MFM_PO_Line_Item__c=poL;
            payd.ASI_MFM_BU__c=values[1] != null ? buM.get(values[1].trim()) != null? buM.get(values[1].trim()): null: null;
            payd.ASI_MFM_AP_Code__c=values[2] != null ? apM.get(values[2].trim()) != null? apM.get(values[2].trim()): null: null;
            payd.ASI_MFM_A_c_Code__c=values[2] != null ? apacM.get(values[2].trim()) != null? apacM.get(values[2].trim()): null: null;
            payd.asi_mfm_sc_Subledger__c=subledgerId;
            payd.ASI_MFM_Payment_Amount__c=(values[4] != null && values[4].isNumeric())? Integer.valueof(values[4].trim()): null;
            payd.ASI_MFM_Payment_List_Item_Description__c=values[5] != null ? values[5].trim(): null;
            
            payd.ASI_MFM_G_L_Date__c=sysDate;
            payd.ASI_MFM_Invoice_Date__c=sysDate;
 System.debug(payd);                 
            if(poL!=null)
                newPayDL.add(payd);
        }

        try {
          insert newPayDL;        
            
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
}