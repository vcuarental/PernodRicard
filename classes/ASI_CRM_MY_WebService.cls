global without sharing class ASI_CRM_MY_WebService
{
    WebService static String sendIOTEmail(String param)
    {
        if (String.isNotBlank(param))
        {
            try
            {
                ASI_CRM_IOTHeader__c header = [
                    select Id, ASI_CRM_ContactNumber__c, ASI_CRM_ContactPerson__c, ASI_CRM_Customer__r.Name
                        , ASI_CRM_Customer__r.ASI_CRM_CN_Address__c, ASI_CRM_ExpectedDeliveryDate__c, ASI_CRM_Remarks__c, ASI_CRM_Wholesaler__r.Id
                        , ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c, ASI_CRM_MY_IOTConfirm__c, ASI_CRM_MY_EmailSent__c, CreatedBy.Name, CreatedBy.Email, CreatedBy.Phone
                    from ASI_CRM_IOTHeader__c
                    where Id = :param
                ];
                

                if (header == null)
                {
                    return 'Invalid IOT Header';
                }
                else if (header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c == null)
                {
                    return 'No wholesaler email found';
                }
                else if (header.ASI_CRM_MY_EmailSent__c == true)
                {
                    return 'IOT email has sent before';
                }
                else if (header.ASI_CRM_MY_IOTConfirm__c == false)
                {
                    return 'IOT is not yet confirmed';
                }

                List<ASI_CRM_IOTLine__c> lines = [
                    select Id, ASI_CRM_SubBrand__r.Name, ASI_CRM_SKU__r.Name, ASI_CRM_Quantity__c, ASI_CRM_FOCQuantity__c
                    from ASI_CRM_IOTLine__c
                    where ASI_CRM_IOTHeader__c = :header.Id
                ];

                if (lines.size() == 0)
                {
                    return 'No IOT lines';
                }
                
                String iotemail = header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c;
                iotemail = iotemail.trim().replaceAll(' ', '');
                iotemail = iotemail.replaceAll('\n', '');
                iotemail = iotemail.replaceAll(',', ';');
                iotemail = (iotemail.right(1)==';') ?  iotemail.mid(0, iotemail.length()-1) : iotemail;

                String[] toAddresses = iotemail.split(';');
                if(toAddresses.size()== 0) 
                {
                    return 'no IOT email';
                }
                
                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //String[] toAddresses = new String[] { header.ASI_CRM_Wholesaler__r.ASI_CRM_MY_IOTEmail__c }; 
                String[] ccAddresses = new String[] { header.CreatedBy.Email };
                mail.setToAddresses(toAddresses);
                mail.setccAddresses(ccAddresses);
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
                    htmlBody += '<td>' + l.ASI_CRM_SubBrand__r.Name + '</td>';
                    htmlBody += '<td>' + l.ASI_CRM_SKU__r.Name + '</td>';
                    htmlBody += '<td align="right">' + l.ASI_CRM_Quantity__c + '</td>';
                    htmlBody += '<td align="right">' + l.ASI_CRM_FOCQuantity__c + '</td>';
                    htmlBody += '</tr>';
                }

                htmlBody += '</table><br /><br />';
                htmlBody += 'Thank you,';
                htmlBody += '<br />' + header.CreatedBy.Name;
                htmlBody += '<br />' + header.CreatedBy.Phone;

                mail.setHtmlBody(htmlBody);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                header.ASI_CRM_MY_EmailSent__c = true;
                upsert header;

                return 'IOT email has sent to wholesaler';
            }
            catch (Exception e)
            {
                return e.getMessage();
            }
        }
        else
        {
            return 'Not sent';
        }
    }
    
    webservice static Boolean isGroupMember_WS(Id uid, String gName){
		return ASI_CRM_MY_Function.isGroupMember(uid,gName);
	}
    
}