global class ASI_mfm_SC_POMassValidBatch implements Database.Batchable<String>, Database.Stateful {
   /* public class BadLineWrapper {
        BadLineWrapper(String line) {
            this.line = line;
            this.reasons = new List<String>();
        }
        public String line;
        public Integer lineNumber;
        public List<String> reasons;
    }*/

    global final Blob content;
    global final Id ownerId;
    //global List<BadLineWrapper> badLines;
    global Integer lineCount;
    //@TestVisible static List<BadLineWrapper> testBadLines;

    public ASI_mfm_SC_POMassValidBatch() {
    }

    public ASI_mfm_SC_POMassValidBatch(Blob content, Id ownerId) {
        this.content = content;
        this.ownerId = ownerId;
        //this.badLines = new List<ASI_mfm_SC_POMassValidBatch.BadLineWrapper>();
        this.lineCount = 2; // start at row 2 cuz the first row is header
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

            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());

            regexFindCount = 0;
        }

        return output;
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
 
    }

    public void finish(Database.BatchableContext BC) {
        // In testing we ues this variable
        //testBadLines = badLines;

        User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

        List<Messaging.Email> emails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Database.executeBatch(new ASI_mfm_sc_poMassUploadBatch(content,ownerId));
        /*
        if (badLines.isEmpty()) {
            
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
                    'mark.ng@pernod-ricard.com'
            });
            emails.add(mail);
            Messaging.sendEmail(emails);
        }*/
    }

}