/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Goal            | Using for factoring code                                                           |
|     - Description     | containing methods used by many classes                                            |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 10/01/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class Utils_UsefulMethods {

    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/ 
    
    /*
     * Get the User email with the username. 
     ***/
    public static String emailFromUsernameEntry(String username) {
        List<User> searchedUser = new List<User>();
        searchedUser = [Select Email From User Where Username = :username AND isActive= true limit 1];
        if ((searchedUser != null) && (searchedUser.size()==1)) {
            return searchedUser[0].Email;
        } else {
            return null;
        }
    }
    
    /*
     * Return the email stored in the custom setting PR_Settings__c if it is not a Test context.
     ***/
    public static String adminEmailOfPRCustomSetting() {
    	String emailAdmin;
		if(!Test.isRunningTest()) // If not test, get the default admin email defined for the entire organization.
	    	emailAdmin = PR_Settings__c.getOrgDefaults().ESN_Admin_Email__c;
		else	//  If test, get a fictive email.
	    	emailAdmin = 'test@test.com';
	    return emailAdmin;
    }
    
    
    /*
     * If an exception is catched, a mail with error message is send to the admin. 
     ***/
    public static void notifyAdminException(String email, String currProcess, String context, Exception e) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org [' + UserInfo.getOrganizationName() + '] in process [' +  currProcess +']');
        mail.setPlainTextBody( 'Context : '+context+'\n Error type :'+e.getTypeName() + '\n Error Message : ' + e.getMessage() + '\n Error Cause : ' + e.getCause());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /*
     * If an error need to be sent to an admin, a mail with error message is send to the admin. 
     ***/
    public static void notifyAdminMsg(String email, String currProcess, String context, String msg) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org [' + UserInfo.getOrganizationName() + '] in process [' +  currProcess +']');
        mail.setPlainTextBody( 'Context : '+context+'\n'+msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /*
     * Convert an ID with 15-digits to an ID with 18-digits. 
     ***/
    public static String sfdc15To18 (String original15) {
        // This method expects a 15-char valid Salesforce ID, and returns the 18-char equivalent
        
        Map<String,String> lookup5bin = new Map<String,String>();
        String Piece1 = '';
        String Piece2 = '';
        String Piece3 = '';
        
        original15 = original15.substring(0,15);
        
        lookup5bin.put('00000','A');    lookup5bin.put('01000','I'); lookup5bin.put('10000','Q');   lookup5bin.put('11000','Y');
        lookup5bin.put('00001','B');    lookup5bin.put('01001','J'); lookup5bin.put('10001','R');   lookup5bin.put('11001','Z');
        lookup5bin.put('00010','C');    lookup5bin.put('01010','K'); lookup5bin.put('10010','S');   lookup5bin.put('11010','0');
        lookup5bin.put('00011','D');    lookup5bin.put('01011','L'); lookup5bin.put('10011','T');   lookup5bin.put('11011','1');
        lookup5bin.put('00100','E');    lookup5bin.put('01100','M'); lookup5bin.put('10100','U');   lookup5bin.put('11100','2');
        lookup5bin.put('00101','F');    lookup5bin.put('01101','N'); lookup5bin.put('10101','V');   lookup5bin.put('11101','3');
        lookup5bin.put('00110','G');    lookup5bin.put('01110','O'); lookup5bin.put('10110','W');   lookup5bin.put('11110','4');
        lookup5bin.put('00111','H');    lookup5bin.put('01111','P'); lookup5bin.put('10111','X');   lookup5bin.put('11111','5');
        
        Piece1 = sfdc0Or1(original15.substring(4,5)) + sfdc0Or1(original15.substring(3,4)) + sfdc0Or1(original15.substring(2,3)) + sfdc0Or1(original15.substring(1,2)) + sfdc0Or1(original15.substring(0,1));

        Piece2 = sfdc0Or1(original15.substring(9,10)) + sfdc0Or1(original15.substring(8,9)) + sfdc0Or1(original15.substring(7,8)) + sfdc0Or1(original15.substring(6,7)) + sfdc0Or1(original15.substring(5,6));

        Piece3 = sfdc0Or1(original15.substring(14,15)) + sfdc0Or1(original15.substring(13,14)) + sfdc0Or1(original15.substring(12,13)) + sfdc0Or1(original15.substring(11,12)) + sfdc0Or1(original15.substring(10,11));

        return (original15 + lookup5bin.get(Piece1) + lookup5bin.get(Piece2) + lookup5bin.get(Piece3));        
    }
    
    private static String sfdc0Or1 (String charX) {
        // This method accepts a one-char string and returns '1' if it's between A and Z, otherwise '0'.        
        if (charX.compareTo('A') >= 0 && charX.compareTo('A') <= 25 && charX.compareTo('Z') >= -25 && charX.compareTo('Z') <= 0) return '1';
            return '0';        
        }
    }