global class ASI_CRM_MY_SendIOTEmailBatch implements Database.Batchable<sObject>, Database.Stateful
{   
    public Id headerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader');
    public String log;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'select Id, ASI_CRM_ContactNumber__c, ASI_CRM_ContactPerson__c, ASI_CRM_Customer__r.Name'
                        + ', ASI_CRM_Customer__r.ASI_CRM_CN_Address__c, ASI_CRM_ExpectedDeliveryDate__c, ASI_CRM_Remarks__c, ASI_CRM_Wholesaler__r.Id'
                        + ', ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c, ASI_CRM_MY_EmailSent__c, CreatedBy.Name, CreatedBy.Email, CreatedBy.Phone'
                        + ', Owner.Name, Owner.Email, Owner.Phone '
                        + ' from ASI_CRM_IOTHeader__c'
                        // + ' where RecordTypeId = \'' + headerRecTypeID + '\' and ASI_CRM_MY_IOTConfirm__c = true and ASI_CRM_MY_EmailSent__c = false';
                        + ' where ASI_CRM_Send_Email__c = true and ASI_CRM_MY_IOTConfirm__c = true and ASI_CRM_MY_EmailSent__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_IOTHeader__c> scope)
    {
        try
        {
            for (ASI_CRM_IOTHeader__c header : scope)
            {
                
                //if ( header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c == null )
                //{
                //    continue;
                //}
                String iotemail = (header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c!=null) ? header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c : '';
                
                iotemail = iotemail.trim().replaceAll(' ', '');
                iotemail = iotemail.replaceAll('\n', '');
                iotemail = iotemail.replaceAll(',', ';');
                
                iotemail = (iotemail.right(1)==';') ?  iotemail.mid(0, iotemail.length()-1) : iotemail;
                
                if( header.Owner.Email != null)
                    iotemail = (iotemail=='') ?  header.Owner.Email : iotemail+';'+header.Owner.Email;
                    
                String[] toAddresses = iotemail.split(';');
                
                if(toAddresses.size()== 0) 
                {
                    continue;
                }
                System.debug('iotemail: '+iotemail);

                List<ASI_CRM_IOTLine__c> lines = [

                    //ASI_CRM_SubBrand__r.Name
                    select Id, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SKU__r.Name, ASI_CRM_Quantity__c, ASI_CRM_FOCQuantity__c
                    from ASI_CRM_IOTLine__c
                    where ASI_CRM_IOTHeader__c = :header.Id
                ];

                if (lines.size() == 0)
                {
                    continue;
                }
                
                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //String[] toAddresses = new String[] { header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c }; 
                //String[] ccAddresses = new String[] { header.CreatedBy.Email };
                //Issue #22, please always send the indirect order to the record owner, even if there is no wholesaler email defined in Salesforce.
                
                mail.setToAddresses(toAddresses);
                //mail.setccAddresses(ccAddresses);
                mail.setReplyTo('support@pra.com');
                mail.setSenderDisplayName('PRA');

                mail.setSubject('Indirect order taking : ' + header.ASI_CRM_Customer__r.Name);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                
                String htmlBody = '';

                htmlBody += 'Date: ' + Datetime.now().format('dd-MM-yyyy');
                htmlBody += '<br />Outlet Name: ' + header.ASI_CRM_Customer__r.Name;
                htmlBody += '<br />Outlet Contact Person: ' + header.ASI_CRM_ContactPerson__c;
                htmlBody += '<br />Outlet Contact Number: ' + header.ASI_CRM_ContactNumber__c;
                htmlBody += '<br />Outlet Address: ' + header.ASI_CRM_Customer__r.ASI_CRM_CN_Address__c;
                htmlBody += '<br />Expected Delivery Date: ' + header.ASI_CRM_ExpectedDeliveryDate__c;

                htmlBody += '<br /><br />';

                htmlBody += '<table border="1" style="border-collapse: collapse;" width="100%" cellpadding="2">'
                            + '<tr>'
                            + '<th>Sub Brand</th>'
                            + '<th>SKU</th>'
                            + '<th>Order Qty<br />(Bottle)</th>'
                            + '<th>FOC<br />(Bottle)</th>'
                            + '</tr>';

                for (ASI_CRM_IOTLine__c l : lines)
                {
                    htmlBody += '<tr>';
                    //htmlBody += '<td>' + l.ASI_CRM_SubBrand__r.Name + '</td>';
                    htmlBody += '<td>' + l.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name + '</td>';
                    htmlBody += '<td>' + l.ASI_CRM_SKU__r.Name + '</td>';
                    htmlBody += '<td align="right">' + l.ASI_CRM_Quantity__c + '</td>';
                    htmlBody += '<td align="right">' + l.ASI_CRM_FOCQuantity__c + '</td>';
                    htmlBody += '</tr>';
                }

                htmlBody += '</table><br /><br />';
                htmlBody += 'Thank you,';
                htmlBody += '<br />' + header.Owner.Name;
                htmlBody += '<br />' + header.Owner.Phone;

                mail.setHtmlBody(htmlBody);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                header.ASI_CRM_MY_EmailSent__c = true;
                // upsert header;
            }

            Database.SaveResult[] srList = database.update(scope, false);
            for (Integer i = 0; i < srList.size(); i++)
            {
                if (!srList[i].isSuccess())
                {
                    this.log += '\n Error in scope: ' + scope[i].name + '. Error msg=' + srList[i].getErrors()[0].getMessage();
                }
            }
        }
        catch (exception e)
        {
            this.log += '\nError msg=' + e.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if (!String.isEmpty(this.log) || Test.isRunningTest())
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setSaveAsActivity(false);
            email.setSenderDisplayName('Salesforce Support');
            email.setSubject('error in batch process!');
            email.setPlainTextBody(Test.isRunningTest() ? 'test' : this.log);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}