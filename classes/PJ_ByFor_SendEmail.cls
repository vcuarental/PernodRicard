public with sharing class PJ_ByFor_SendEmail {
    

        // toAddresses, subject, Attachment, Documentation, Message  
        public static String toAddresses{get;set;}
        public static String[] toAddressesTest{get;set;}
        public static String isTest{get;set;}
        
        
        public static String subject{get;set;}
        //public static Attachment Attachment{get;set;}
        public static String Message{get;set;}
        public static String Template{get;set;}
        public static String TemplateSave{get;set;}
        public static String TemplateClear{get;set;}
        
        
        
        public String contIdChosen {get; set;}

        public static String fileName {get; set;}
        public static String contentType {get; set;}
        public static transient Blob blo {get; set;}
        public String templateID {get; set;}
        
        
        public List<PJ_ByFor_Client__c> clients{get;set;}
        public String contactId{get;set;}
        
        
        public static String MyCorps{get;set;}
        public static String recipient{get;set;}
        public static ID rId{get;set;}
        private Map<Integer,String> months;
        
        public static Boolean isEmailSent{get;set;}
            
        public Id attId{get;set;}
        private Id attparentId{get;set;}
        public String selectedFileName{get;set;}
        
        
        public static Attachment attachment {
             get {
                  if (attachment == null)
                      attachment = new Attachment();
                      attachment.name = fileName;
                      attachment.body = blo;
                   return attachment;
                 }
             set;
      }
      
        public void init()
        {
            //showParam = '10';
            //experienceNameParam = '';
            initclients();
            selectedFileName = '';
            toAddressesTest = new List<String>{'','','','',''};
            createMonths();
            isEmailSent = false;
            /*for (Integer i=0;i<5; i++)
                toAddressesTest[i] = '';
            */  
        }
        
        private void createMonths()
        {
            months = new Map<Integer,String>();
            months.put(1,'January');
            months.put(2,'February');
            months.put(3,'March');
            months.put(4,'April');
            months.put(5,'May');
            months.put(6,'June');
            months.put(7,'July');
            months.put(8,'August');
            months.put(9,'September');
            months.put(10,'October');
            months.put(11,'November');
            months.put(12,'December');
        }
        
        // Clients set methods (load all the clients and the related  fields)  
        public void initclients() {
            clients = [select Id, PJ_ByFor_Salutation__c, PJ_ByFor_First_name__c, Name, PJ_ByFor_Status__c, PJ_ByFor_Subsidiary__c,  PJ_ByFor_Latest_Situation_Update__c, PJ_ByFor_Latest_Situation_Update_Date__c, PJ_ByFor_Email__c, CreatedDate from PJ_ByFor_Client__c order by Name asc];
        }
        
        private void uploadFile()
        {
            if(attId == null && blo != null)
            {
                PJ_ByFor_AttachmentFile__c attparent = new PJ_ByFor_AttachmentFile__c();
                insert attparent;
                attparentId = attparent.Id;
                Attachment attFile = new Attachment();
                attFile.name = fileName;
                attFile.body = blo;
                attFile.contentType = contentType;
                attFile.ParentId = attparentId;
                
                insert attFile;
                attId = attFile.Id;
                selectedFileName = filename;
            }
        }
    
        public PageReference sendEmail()
        {
            uploadFile();
            // Create an email message object
            System.Debug('##### Create an email message object' + TemplateSave);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> Email = new List<String>();
            
            
            
            System.debug('Email= toAddressesTest' + isTest);
            
            // if isTest is true
            if( isTest == 'true') {
                //System.debug('Email= toAddressesTest' + toAddressesTest + 'toAddressesTest.size()' + toAddressesTest.size());
                /*System.debug('Email[i] = str' + toAddressesTest);
                Integer i = 0; 
                for(String str : toAddressesTest) {
                    if(str!='')
                    {
                        Email[i] = str;
                        i++;
                    }
                }
                
                toAddressesTest.clear();
                */
                Email.add(UserInfo.getUserEmail());
            } else {
                System.debug('Email = toAddresses.split()' + toAddresses);
                Email.addAll(toAddresses.split(';'));
            }
                
            
            for(String val : Email){
        
                if(!checkEmail (val)) {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'##### Error on email address(es)'));
     
                //return null;
                }
            }

            // Create the email attachment
            if(attId != null)
            {
               Attachment attTmp = [select name, body, contentType from Attachment where Id=:attId];
               Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
               efa.setFileName(attTmp.name);
               //efa.setFileName('file.docx');
               efa.setBody(attTmp.body);
               efa.setContentType(attTmp.ContentType);
               mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            }
                        
            //String[] toAddressesa = new String[] {toAddresses};
            mail.setToAddresses(Email); // Ok
            mail.setSubject(subject);
            
            System.debug('######################TemplateSave TemplateSave TemplateSave' + TemplateSave);

            TemplateSave = TemplateSave.replace(TemplateClear,Message);
            //mail.setSubject(TemplateSave);    // Ok
            //mail.setPlainTextBody(Message);   //Ok
            
            TemplateSave = TemplateSave.replace('$$Subject$$',subject);
            
            mail.setHtmlBody(TemplateSave); //Ok
            
            // Pass this email message to the built-in sendEmail method 
            // of the Messaging class
            Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                     new Messaging.SingleEmailMessage[] { mail });
            
            // Call a helper method to inspect the returned results
            inspectResults(results);
            
            /*
            if(isTest == 'true')
            {
                //return null;
            } else {
                
                System.Debug('##### Back to Home page');
                PageReference ref = new PageReference('/apex/PJ_ByFor_Home');
                //ref.getParameters().put('cId',client.Id);
                
                
                System.debug('####################### isEmailSent : ' + isEmailSent);
            }
            */
            isEmailSent = true;
            return null;
                 
        }
    
    
        private static Boolean checkEmail (String email) {
    
            String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern MyPattern = Pattern.compile(emailRegex);
            
            Matcher MyMatcher = MyPattern.matcher(email);
            
            if (!MyMatcher.matches()) {
                System.Debug('##### Error on email addresses');
                return false;
            }
            else {
                return true;
            }
        }  
    
    
            private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
                Boolean sendResult = true;
                
                // sendEmail returns an array of result objects.
                // Iterate through the list to inspect results. 
                // In this class, the methods send only one email, 
                // so we should have only one result.
                for (Messaging.SendEmailResult res : results) {
                    if (res.isSuccess()) {
                        System.debug('Email sent successfully');
                    }
                    else {
                        sendResult = false;
                        System.debug('The following errors occurred: ' + res.getErrors());                 
                    }
                }
                
                return sendResult;

            }
            
            public void getBodyEmailTemplate(){
	            uploadFile();
	            if(templateId != '')
	            {
		            EmailTemplate myEmailTemplate = new EmailTemplate(); 
		            System.Debug('myEmailTemplateId:'+templateId);
		             myEmailTemplate = [select htmlvalue,id from EmailTemplate where Id=:templateID];
		             
		             Template = myEmailTemplate.htmlvalue;
		
		             //TemplateSave = new String();
		             TemplateSave = Template;
		                TemplateClear = Template;       
		        
		        
		        
		             Integer startIndex = Template.indexOf('$$START_body$$');
		             Integer endIndex = Template.indexOf('$$END_body$$');
		             
		             
		             TemplateClear = TemplateClear.substring(startIndex,endIndex + 12);
		             
		             
		             Template=Template.substring(startIndex + 14,endIndex);
		                    
		            
		                System.Debug('TemplateSave+TemplateClear:'+TemplateSave+TemplateClear);
		                
		             
		             Template = Template.replace('$$date$$', Date.today().day() + ' ' + months.get(Date.today().month()) + ' ' + Date.today().year());  
		             replaceEmailCorps();
	            } else {
	            	Message = '';
	            }

        	}

        // Get the fusion fields to the template email  
        public void replaceEmailCorps()
        {
          uploadFile();
          /* 
          * Remplace les champs de fusion présent dans MyCorps
          * Le code va chercher {! et } pour isoler les champs de fusion du type {!targetObject.Field} 
          * puis faire une requête SQL pour récupérer les valeurs.
          * Enfin, on remplace les champs de fusion par les valeurs trouvées
          */
          //String MyCorps = MyCorps.stripHtmlTags();
          
             
            
            
            //System.debug('before if String MyCorps:' + 'Message:'  + Message + 'Templat:' + Template + 'Id:' + rId);
            Message =  Template;
            
            
            
            String id = String.escapeSingleQuotes(rId);
            
            System.debug('String.escapeSingleQuotes(rId):' + id);
            if (Message.length() > 0 && id.length() >= 15) {
                
                
            MyCorps = Message;
            recipient = rId.getSObjectType().getDescribe().getName();
          
            
          
            System.debug('after if String MyCorps:' + MyCorps + '    \n String recipient:' + recipient +  '\n String rId:' + rId);
            
          
          
            
            Set<String> insertedFieldRecipient = new Set<String>();
            Integer lastIndex = 0;
            
            
            while(lastIndex != -1)
            {
                System.Debug('##### Start At Index = ' + lastIndex);
                Integer deb = MyCorps.indexOf('{!',lastIndex);
                Integer bout = MyCorps.indexOf('}',lastIndex);
                if(deb != -1 && bout != -1)
                {
                    String field = MyCorps.substring(deb + 2,bout);
                    System.Debug('##### FIELD = ' + field);
                    if(field.left(field.indexOf('.')) == recipient)
                        insertedFieldRecipient.add(field.right(field.length() - (field.indexOf('.') + 1)));
                    lastIndex = bout+1;
                }
                  
                if(deb == -1)
                    lastIndex = -1;
            }
            
            if(insertedFieldRecipient.size() > 0)
            {
              String queryString = 'select';
              for(String s:insertedFieldRecipient)
                queryString += ' ' + s + ',';
              queryString= queryString.left(queryString.length() - 1);
              queryString += ' from ' + recipient + ' where Id=\'' + rId + '\'';
              System.Debug('##### QueryRecipient = ' + queryString);
              sObject myObject = Database.query(queryString);
              for(String s:insertedFieldRecipient)
              {
                MyCorps = MyCorps.replace('{!' + recipient + '.' + s + '}',(String)myObject.get(s));
              }
            }
            
            
        
            Message = MyCorps;
            }
            
    }
    
}