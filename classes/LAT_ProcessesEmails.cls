public with sharing class LAT_ProcessesEmails {
	public LAT_ProcessesEmails() {
		
	}

	public static void sendEmail(List<emailMsg> emails) {
		List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
	  	for(emailMsg tmsg : emails){
		  	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	      	mail.setToAddresses(tmsg.emailAddress);

	      	system.debug('hhhhh '+ tmsg.emailAddress);
	      	mail.setSubject(tmsg.Subject);
	      	String msg = tmsg.body;
	      	//msg += '\n\n  https://' + URL.getSalesforceBaseUrl().getHost() + '/apex/'+ Page.LAT_POPClientAssignation;

	      	mail.setPlainTextBody(msg);
	      	mail.setHTMLBody(msg);
	      	emailsList.add(mail);
	  	}
      	Messaging.sendEmail(emailsList); 
   }

   public class emailMsg{
   		public List<String> emailAddress{get;set;}
   		public String Subject{get;set;}
   		public String body{get;set;}

   		public emailMsg(List<String> address, String sub, String body){
   			this.emailAddress = new List<String>();
   			this.subject = sub;
   			this.body = body;

   			if(address != null){
   				for(integer i=0; i < address.size();i++){
   					if(address[i]!= null && address[i]!= '')emailAddress.add(address[i]);
   				}
   			}
   			
   		}
   }


}