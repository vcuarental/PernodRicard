/********************************************************************************************
 * Name: PRH_IconicBriefcaseMappingController												*
 * Description: Class to call a batch job that will sync US brands and Iconic brands		*
 *																							*
 * Version History																			*
 * Date             Developer               Comments										*
 * ---------------  --------------------    ------------------------------------------------*
 * 25/02/2015       Laputa                  Created        									*
 * 04/01/2017       CGI                     Modification of core model (add collect)       	* 
*********************************************************************************************/

public class PRH_IconicBriefcaseMappingController{
    public String brandName {get;set;}
    public String surveyName {get;set;}
    public String emailAdd {get;set;}
    public USA_Survey_Answer__c surveyAnswer {get;set;}
    public List<PRH_Iconic_Briefcase_Mapping__c> mappings {get;set;}
    
    public PRH_IconicBriefcaseMappingController(){
        mappings = new List<PRH_Iconic_Briefcase_Mapping__c>();
        mappings = PRH_Iconic_Briefcase_Mapping__c.getall().values();
        surveyAnswer = new USA_Survey_Answer__c();
    }
    
    public List<SelectOption> getIconicBrands(){
        List<PRH_Iconic_Briefcase_Mapping__c> mappings = PRH_Iconic_Briefcase_Mapping__c.getall().values();

        List<SelectOption> options = new List<SelectOption>();
        Set<String> brands = new Set<String>();
        
        options.add(new SelectOption(' All', ' All'));
        for(PRH_Iconic_Briefcase_Mapping__c maps :mappings){
            if(!brands.contains(maps.PRH_Iconic_Brands__c)){
                brands.add(maps.PRH_Iconic_Brands__c);
                options.add(new SelectOption(maps.PRH_Iconic_Brands__c, maps.PRH_Iconic_Brands__c));
            }
        }
        options.sort();
        return options;
    }
    
    
    public void callBriefcaseSync_BatchJob(){
        system.debug('***callBriefcaseSync_BatchJob(), surveyAnswer='+surveyAnswer);
        surveyName = surveyAnswer.USA_Survey__c;
        system.debug('***callBriefcaseSync_BatchJob(), surveyAnswer.USA_Survey__c='+surveyAnswer.USA_Survey__c);
        system.debug('***callBriefcaseSync_BatchJob(), lancement batch PRH_IconicBriefcaseMappingBatch, brandName='+brandName +' surveyName='+surveyName+' emailAdd='+emailAdd );
        Database.executeBatch(new PRH_IconicBriefcaseMappingBatch(brandName, surveyName, emailAdd));
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'An email will be sent after the sync is done.'));
    }
}