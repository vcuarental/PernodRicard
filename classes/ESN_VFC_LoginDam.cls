/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Franck Tranchant                                                                   |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | N/A                                                                                |
|     - Description     | ESN_LoginDam Controler                                                             |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 04/09/2014                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC_LoginDam {
    
    public String redirectURL {get; set;}   
    public String targetResource {get; set;}
    
    public String email {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String title {get; set;}
    public String companyName {get; set;}
    public String department {get; set;}
    public String SessionId { get { return UserInfo.getSessionId(); } }
//    public String partnerURL { get { return ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId(); } }
    public String partnerURL { get { return ESN_DamApiEndPoint__c.getInstance('partnerURL').partnerURL__c + UserInfo.getOrganizationId(); } }

//  public String partnerURL { get { return CustomSettingName__c.getValues(''); } }


   
    public ESN_VFC_LoginDam() {
    
        targetResource = '';
        redirectURL = '';
        
        Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
        if (UrlParameterMap.containsKey('TargetResource')){
        
            targetResource = UrlParameterMap.get('TargetResource');
            
            if (targetResource!=''){
                //SCH 18/05/2015 : this parameter needs to be urlencoded, otherwise special characters can be interpreted (like #)
				targetResource = EncodingUtil.urlEncode(targetResource, 'UTF-8');

                firstName = UserInfo.getFirstName();
                lastName = UserInfo.getLastName();
                email = UserInfo.getUserEmail();
                title = [SELECT Title FROM User WHERE Id=:UserInfo.getUserId()].Title;
                companyName = [SELECT CompanyName FROM User WHERE Id=:UserInfo.getUserId()].CompanyName;
                department = [SELECT Department FROM User WHERE Id=:UserInfo.getUserId()].Department;

                /* START DEV Simon G. Team SFDC */
                /*
                System.debug('CONTROLLER : ESN_VFC_LoginDam.cls');
                System.debug('1.FirstName : ' + firstName);
                System.debug('2.LastName : ' + lastName);
                System.debug('3.Email : ' + email);
                System.debug('4.Tilte : ' + title);
                System.debug('5.CompanyName : ' + companyName);
                System.debug('6.Department : ' + department);
                System.debug('7.targetResource : ' + targetResource);
                */
                /* END DEV Simon G. Team SFDC */

                // FTR : No more used. Javascript redirection used in ESN_LoginDam page instead.
                //redirectURL = 'https://pg.pingfed.northplains.com/pf/adapter2adapter.ping?sid='+sessionID+'&apiendpoint={!API.Partner_Server_URL_200}&TargetResource='+targetResource+'&IdpAdapterId=0000001&SpSessionAuthnAdapterId=prID&FirstName='+firstName+'&LastName='+lastName+'&Email='+email;                
                //Apexpages.currentPage().getHeaders().put('Refresh', '0; url='+redirectURL);
            
            }
            
        } 
            
    }        
    
}