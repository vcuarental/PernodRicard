/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassUploadBatch
 * Description: Test class for ASI_CRM_VN_ActualOfftakeMassUploadBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

    global class ASI_CRM_VN_ActualOfftakeMassUploadBatch implements Database.Batchable<String>, Database.Stateful {
    public final Blob content;
    public final Id ownerId;
//    global List<String> badLines;

    public ASI_CRM_VN_ActualOfftakeMassUploadBatch(){

    }

    public ASI_CRM_VN_ActualOfftakeMassUploadBatch(Blob content, Id ownerId) {
        this.content = content;
        this.ownerId = ownerId;
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
        if (values.size() != 5) {
            return true;
        }
        for (String value : values) {
            if (String.isEmpty(value)) {
                return true;
            }
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
        List<ASI_TH_CRM_Actual_Offtake__c> newOfftakes = new List<ASI_TH_CRM_Actual_Offtake__c>();

        //        for SOQL later
        List<String> subBrandCodes = new List<String>();
        List<String> customerCodes = new List<String>();
        for (String line : fileLines) {
//            possible empty line
            if (badString(line)) {
                continue;
            }

            List<String> values = line.split(',');
            subBrandCodes.add(values[0]);
            customerCodes.add(values[1]);
        }

        Map<String, ASI_MFM_Sub_brand__c> codeToSubBrand = new Map<String, ASI_MFM_Sub_brand__c>();
        for (ASI_MFM_Sub_brand__c subBrand : [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Sub_brand_Code__c IN :subBrandCodes]) {
            codeToSubBrand.put(subBrand.ASI_MFM_Sub_brand_Code__c, subBrand);
        }

        Map<String, ASI_CRM_AccountsAdditionalField__c> codeToCustomer = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        for (ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, ASI_CRM_CustomerCode__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CustomerCode__c IN :customerCodes]) {
            codeToCustomer.put(customer.ASI_CRM_CustomerCode__c, customer);
        }

        for (String line : fileLines) {
            System.debug('line : ' + line + ' is bad ? ' +  badString(line));
            //            possible empty line
            if (badString(line)) {
//                badLines.add(line);
                continue;
            }

            List<String> values = line.split(',');
            ASI_TH_CRM_Actual_Offtake__c offtake = new ASI_TH_CRM_Actual_Offtake__c();

            offtake.ASI_TH_CRM_Sub_brand__c = codeToSubBrand.get(values[0]) != null? codeToSubBrand.get(values[0]).Id : null;
            offtake.ASI_CRM_SG_Customer__c = codeToCustomer.get(values[1]) != null? codeToCustomer.get(values[1]).Id : null;
            offtake.ASI_TH_CRM_Offtake_G_L_Date__c = Date.newInstance(Integer.valueOf(values[2]), Integer.valueOf(values[3]), 1);
            offtake.ASI_TH_CRM_Quantity__c = Decimal.valueOf(values[4].trim());
            offtake.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_VN_Actual_Offtake_Temporary');
            offtake.OwnerId = this.OwnerId;

            newOfftakes.add(offtake);
        }

//        System.debug('badLines : ' + badLines);
//        System.debug('isEmpty : ' + badLines.isEmpty());

        try {
//            if (badLines.isEmpty()) {
                insert newOfftakes;
//            }
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