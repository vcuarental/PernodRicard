/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlanPdfAttach
 * Description: Attach Pdf in Call Plan for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 1/12/2014       Laputa: Hank          Created
*********************************************************************************/
@RestResource(urlMapping='/addPDFtoRecord/*')
global without sharing class ASI_CRM_JP_CallPlanPdfAttach{
   
  @HttpPost
    global static void doPost(list<String> planIdList) {
       list<attachment> insertAttachment = new list<attachment>();
        for(String planId: planIdList){
            //create a pageReference instance of the VF page.
            pageReference pdf = Page.ASI_CRM_JP_CallPlanPDFPage;
            //pass the Plan Id parameter to the class.
            pdf.getParameters().put('id',planId);
            Attachment attach = new Attachment();
            Blob body;
            if(!test.isRunningTest()){
                body = pdf.getContent();
            }else{
                body=blob.valueOf('TestString');
            }
            attach.Body = body;
            attach.Name = system.label.ASI_CRM_JP_Visitation_Header+'.pdf';
            attach.IsPrivate = false;
            attach.ParentId = planId; //This is the record to which the pdf will be attached
            insertAttachment.add(attach);
         }
         //insert the list
         insert insertAttachment;
    }
}