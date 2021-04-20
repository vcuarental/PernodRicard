@isTest
public class ASI_KOR_SRProposalUploadByBatch_Test{
 
    private static Map<String,SObject> propObjects;
    private static User sr; 
    private static ASI_KOR_SR_Proposal_Header__c srHeader;
    private static ASI_KOR_Incentive_Scheme__c incentiveScheme1;
    private static ApexPages.StandardController sc;
    private static ASI_KOR_SalesRepProposalDetailController srController;
     
    @isTest 
    public static void testBatch(){
        
        propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
        sr = (User) propObjects.get(ASI_KOR_TestClassHelper.SR_USER); 
        srHeader = (ASI_KOR_SR_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.SR_PROP_HEADER);
		
		system.runAS(sr){
			test.startTest();
        
			ASI_KOR_SRProposalUploadByBatch tmpClass = new ASI_KOR_SRProposalUploadByBatch();
			
			String[] myArray = new List<String>();
			
			tmpClass.ObjAPIName = 'ASI_KOR_SR_Proposal_Detail__c';
			tmpClass.parentID = srHeader.id;
			tmpClass.fields = 'ASI_KOR_Venue__c,ASI_KOR_Brand__c,ASI_KOR_Target_Volume__c,ASI_KOR_Proposal_Unit_Cost_Basic_CA__c';
			tmpClass.fieldsLabel = 'Venue,Brand,Target Volume,Proposal Unit Cost';
			tmpClass.template = 'ASI_CRM_KR_SRProposalDetailTemplate';
			tmpClass.parentObjectAPIName = 'ASI_KOR_SR_Proposal_Header__c';
			tmpClass.ParentObjectUploadMsg = 'ASI_KOR_Mass_Upload_Message__c';
			tmpClass.recEXID = '';
			tmpClass.recEXIDcol = '';
			tmpClass.upsertMode = false;
			tmpClass.batchMode = true;
			tmpClass.report = '';
			tmpClass.lookupEXID = 'ASI_KOR_Brand__c/ASI_KOR_Brand__c:Brand&ASI_KOR_Brand_Code__c;Account/ASI_KOR_Venue__c:Venue&ASI_KOR_Customer_Code__c';
			tmpClass.DefaultValues = '';
			tmpClass.opt_allOrNone = true;
			tmpClass.currentPageURL = srHeader.id;
			tmpClass.inlineVF = false;
			tmpClass.emailNotification = false;
			tmpClass.namefile = '2015-05-05.csv';
			tmpClass.filesize = 2000;
			
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\r33322111,ABS1,25,9000');
			tmpClass.uploadCSVByBatch();
			
			tmpClass.parentField = 'ASI_KOR_SR_Proposal_ID__c';
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\r33322111,ABS1,25,9000');
			tmpClass.uploadCSVByBatch();
			
			for(String a : tmpClass.StatusMsgs){
				myArray.add(a);
			}
			
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\r');
			tmpClass.uploadCSVByBatch();
			
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\rtest,ABS1,25,9000\r33322111,ABSS,25,9000\r33322111,ABS1,test,9000\r33322111,ABS1,25,test\r33322111,ABS1,25,9000\r33322111,ABS1,25,9000');
			tmpClass.uploadCSVByBatch();
					
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\r33322111,ABS1,25,9000\r33322111,ABS1,25,9000');
			tmpClass.uploadCSVByBatch();
				
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost\r33322111,ABS1,0,9000\r33322111,ABS1,0,0\r33322111,ABS1,25,9000');
			tmpClass.uploadCSVByBatch();
			
			tmpClass.fields = 'ASI_KOR_Venue__c,ASI_KOR_Brand__c,ASI_KOR_Target_Volume__c,ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,ASI_KOR_Saved__c';
			tmpClass.fieldsLabel = 'Venue,Brand,Target Volume,Proposal Unit Cost,Saved';
			tmpClass.contentFile = blob.valueOf('Venue,Brand,Target Volume,Proposal Unit Cost,Saved\r33322111,ABS1,25,9000,abc');
			tmpClass.uploadCSVByBatch();
			
			test.stopTest();
		}
		
    }
    
}