/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ActualOfftakeMassValidBatch
 * Description: Apex class for ASI_CRM_VN_ActualOfftakeMassValidBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-05       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

global class ASI_CRM_VN_ActualOfftakeMassValidBatch implements Database.Batchable<String>, Database.Stateful {
    public class BadLineWrapper {
        BadLineWrapper(String line) {
            this.line = line;
            this.reasons = new List<String>();
        }
        public String line;
        public Integer lineNumber;
        public List<String> reasons;
    }

    global final Blob content;
    global final Id ownerId;
    global List<BadLineWrapper> badLines;
    global Integer lineCount;
    @TestVisible static List<BadLineWrapper> testBadLines;

    global String EMPTY_VALUE = 'Contain empty value';
    global String INVALID_SUB_BRAND_CODE = 'Invalid sub-brand code';
    global String INVALID_CUSTOMER_CODE = 'Invalid customer code';
    global String INVALID_YEAR = 'Invalid year';
    global String INVALID_MONTH = 'Invalid month';
    global String INVALID_VOLUME = 'Invalid volume';

    public ASI_CRM_VN_ActualOfftakeMassValidBatch() {

    }

    public ASI_CRM_VN_ActualOfftakeMassValidBatch(Blob content, Id ownerId) {
        this.content = content;
        this.ownerId = ownerId;
        this.badLines = new List<ASI_CRM_VN_ActualOfftakeMassValidBatch.BadLineWrapper>();
        this.lineCount = 2; // start at row 2 cuz the first row is header
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

    public boolean badString(String s) {
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
        List<String> fileLines = safeSplit(this.content.toString(), '\n');
        // Ignore first line because it is csv header
        fileLines.remove(0);

        return fileLines;
    }

    // The executeBatch method is called for each chunk of records returned from start.
    public void execute(Database.BatchableContext BC, List<String> scope) {
        List<String> fileLines = scope;

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
            BadLineWrapper bad = new BadLineWrapper(line);
            bad.lineNumber = lineCount;

            // increase line count for next iteration
            lineCount++;


            if (badString(line)) {
                Boolean allBlank = true;
                for (String s : line.split(',')) {
                    if (String.isNotBlank(s)) {
                        allBlank = false;
                    }
                }

                // do not show error about current line
                if (String.isBlank(line) || allBlank) {
                    continue;
                }

                if (String.isNotEmpty(line)) {
                    bad.reasons.add(EMPTY_VALUE);
                    badLines.add(bad);
                }
                continue;
            }

            // check each values
            List<String> values = line.split(',');

            if (codeToSubBrand.get(values[0]) == null) {
                bad.reasons.add(INVALID_SUB_BRAND_CODE);
            }
            if (codeToCustomer.get(values[1]) == null) {
                bad.reasons.add(INVALID_CUSTOMER_CODE);
            }

            try {
                Integer year = Integer.valueOf(values[2]);
                if (year < 1000 || year > 3000) {
                    bad.reasons.add(INVALID_YEAR);
                }
            } catch (Exception e) {
                bad.reasons.add(INVALID_YEAR);
            }

            try {
                Integer month = Integer.valueOf(values[3]);
                if (month < 1 || month > 12) {
                    bad.reasons.add(INVALID_MONTH);
                }
            } catch (Exception e) {
                bad.reasons.add(INVALID_MONTH);
            }

            try {
                Decimal.valueOf(values[4].trim());
            } catch (Exception e) {
                bad.reasons.add(INVALID_VOLUME);
            }

            if (!bad.reasons.isEmpty()) {
                badLines.add(bad);
            }
        }

    }

    public void finish(Database.BatchableContext BC) {
        // In testing we ues this variable
        testBadLines = badLines;

        User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

        List<Messaging.Email> emails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if (badLines.isEmpty()) {
            Database.executeBatch(new ASI_CRM_VN_ActualOfftakeMassUploadBatch(content,ownerId));
        } else {
            mail.setSubject('Mass Upload Process failed');

            String body = '';
            body += 'Your mass upload submission failed.<br/>Please fix the following lines:<br/>';
            body += '<table style="text-align: left; border: 1px solid; border-collapse: collapse; width: 100%;">';
            body += '<tr style="border: 1px solid black;"> <th>#</th> <th>Line</th> <th>Error</th> </tr>';
            for (BadLineWrapper badLine : badLines) {
                body += String.format('<tr style="border: 1px solid black;"> <td>{0}</td> <td>{1}</td> <td>{2}</td> </tr>', new String[]{
                        String.valueOf(badLine.lineNumber), badLine.line, String.join(badLine.reasons, '<br/>')
                });
            }
            body += '</table>';
            body += '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you have received this message in error.<br/>';

            mail.setHtmlBody(body);
            mail.setToAddresses(new List<String>{
                    u.email
            });
            emails.add(mail);
            Messaging.sendEmail(emails);
        }
    }

}