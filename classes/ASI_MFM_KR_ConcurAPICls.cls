public class ASI_MFM_KR_ConcurAPICls
{
    public String AccessToken { set; get; }
    public String RefreshToken { set; get; }
    public String errorMessage { set; get; }
    public String objResponse { set; get; }
    public ASI_MFM_KR_Concur_Sync_Setting__c setting { get; set; }
 
    public void getAccessToken()
    {
        if (setting == null)
        {
            setting = ASI_MFM_KR_Concur_Sync_Setting__c.getInstance();
        }

        if (AccessToken != null)
        {
            return;
        }

        try {

            HttpRequest req = new HttpRequest();
            req.setEndpoint(setting.ASI_MFM_End_Point__c);
            //req.setEndpoint(url);
            req.setMethod('POST');
            
            String username = setting.ASI_MFM_Username__c;
            String password = setting.ASI_MFM_Password__c;
            String client_id = setting.ASI_MFM_Client_ID__c;
            String client_secret = setting.ASI_MFM_Client_Secret__c;

            Blob headerValue = Blob.valueOf(username + ':' + password + ':' + client_id + ':' + client_secret);
            
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setBody('grant_type=password'+'&client_id='+ client_id +'&client_secret='+ client_secret+'&username='+ username +'&password='+ password);

            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
            Http http = new Http();
            HTTPResponse res = http.send(req); 
            if (res.getStatusCode() >= 200 && res.getStatusCode() <= 299)
            {
                //System.debug('----response :'+ res.getBody());
                JSONParser jreq = JSON.createParser(res.getBody());
                
                while (jreq.nextToken() != null) 
                {
                    if (jreq.getCurrentToken() == JSONToken.FIELD_NAME && jreq.getText() == 'access_token')
                    {
                        jreq.nextToken();
                        AccessToken = jreq.getText();
                        //System.debug('Token :' + AccessToken);
                    }
                    if (jreq.getCurrentToken() == JSONToken.FIELD_NAME && jreq.getText() == 'refresh_token')
                    {
                        jreq.nextToken();
                        RefreshToken = jreq.getText();
                        //System.debug('RefreshToken :' + RefreshToken);                    
                    }
                }
            }
            else
            {
                errorMessage = 'Connection Error';
                //System.debug('Connection Error');
            }
        }
        catch (Exception ex)
        {  
            errorMessage = ex.getMessage();
            //System.debug('Exception :' + ex.getMessage());
        }    
    }

    // public void getItemListXML(String ItemID) {
    //     String HaveItemID = '';

    //     if (ItemID !='')
    //     {
    //         HaveItemID = '/' + ItemID;
    //     }

    //     getAccessToken(); // Generate new access token before calling bellow API
    //     if (AccessToken == null )
    //     {
    //         errorMessage = 'Error while generating token.';
    //         return;
    //     }
    //     try
    //     {
    //         HttpRequest objReq = new HttpRequest();
    //         objReq.setEndpoint(setting.ASI_MFM_API_End_Point__c + '/api/v3.0/common/listitems' + HaveItemID);
    //         objReq.setMethod('GET');
    //         objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
    //         objReq.setHeader('Accept', 'text/xml');
    //         Http objHttp = new Http();
    //         HTTPResponse objRes = objHttp.send(objReq);
            
    //         if (objRes.getStatusCode() == 200)
    //         {
        
    //             objResponse = objRes.getBody();
    //             System.debug('----response :'+ objRes.getBody());
                
    //             Integer cnt =0;
    //             Dom.Document doc = objRes.getBodyDocument();        
    //             Dom.XMLNode rootItems = doc.getRootElement();
    //             Dom.XMLNode Items = rootItems.getChildElement('Items', null);
    //             for(Dom.XMLNode childnode : Items.getChildElements()) {
    //                 System.debug('----cnt :'+cnt);
    //                 cnt = cnt + 1 ; 

    //                 String RecID = childnode.getChildElement('ID', null).getText();
    //                 String ListID = childnode.getChildElement('ListID', null).getText();
    //                 String Name = childnode.getChildElement('Name', null).getText();
    //                 System.debug('----ID :'+ RecID);
    //                 System.debug('----ListID :'+ ListID);
    //                 System.debug('----Name :'+ Name);      
    //             }                
    //         }
    //         else
    //         {
    //             System.debug('Connection Error');
    //         }
            
    //     }
    //     catch(Exception ex)
    //     {
    //         errorMessage = ex.getMessage();
    //         System.debug('Exception :' + ex.getMessage());
    //     }
    // }

    public String POSTItemListXML(String POSTData) {
        getAccessToken(); // Generate new access token before calling bellow API
        if (AccessToken == null)
        {
            errorMessage = 'Error while generating token.';
            return null;
        }

        try
        {
            HttpRequest objReq = new HttpRequest();
            objReq.setEndpoint(setting.ASI_MFM_API_End_Point__c + '/api/v3.0/common/listitems');
            objReq.setMethod('POST');
            objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
            objReq.setHeader('Accept', 'text/xml');
            objReq.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
            //objReq.setBody('{"listId" : "gWhZKeVQIlyJ5gbjaLu$sIE4Z7AcTqDXe$pNA", "name": "TestK","level1Code" :"TestK"}');
            objReq.setBody(POSTData);
            Http objHttp = new Http();
            HTTPResponse objRes = objHttp.send(objReq);
            //System.debug(objRes.getStatusCode());
            //System.debug(objRes.getBody());
            
            if (objRes.getStatusCode() >= 200 && objRes.getStatusCode() <= 299)
            {
                //System.debug('----response :'+ objRes.getBody());
                
                Integer cnt =0;
                Dom.Document doc = objRes.getBodyDocument();        
                Dom.XMLNode rootItems = doc.getRootElement();
                Dom.XMLNode Items = rootItems.getChildElement('ID', null);
                //System.debug('----ID :'+Items.getText());    
                return Items.getText();  
            }
            else
            {
                System.debug('Fail to create.');
                errorMessage = 'Fail to create.';
                return null;
            }                     
        }
        catch (Exception ex)
        {
            errorMessage = ex.getMessage();
            System.debug('Exception :' + ex.getMessage());
            return null;
        }
    }

    public void PUTItemListXML(String ItemID, String PUTData)
    {
        getAccessToken(); // Generate new access token before calling bellow API
        if (AccessToken == null )
        {
            errorMessage = 'Error while generating token.';
            return;
        }

        try
        {
            HttpRequest objReq = new HttpRequest();
            objReq.setEndpoint(setting.ASI_MFM_API_End_Point__c + '/api/v3.0/common/listitems/' + ItemID);
            objReq.setMethod('PUT');
            objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
            objReq.setHeader('Accept', 'text/xml');
            objReq.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
            //objReq.setBody('{"listId" : "gWhZKeVQIlyJ5gbjaLu$sIE4Z7AcTqDXe$pNA", "name": "TestKoyuki","level1Code" :"TestKoyuki"}');
            objReq.setBody(PUTData);
            Http objHttp = new Http();
            HTTPResponse objRes = objHttp.send(objReq);
            //System.debug(objRes.getStatusCode());
            //System.debug(objRes.getBody());
            
            if (objRes.getStatusCode() >= 200 && objRes.getStatusCode() <= 299)
            {
                //System.debug(objRes.getBody());
                //return blank
            }
            else
            {
                errorMessage = 'Fail to update.';
                System.debug('Fail to update.');
            }                     
        }
        catch(Exception ex)
        {
            errorMessage = ex.getMessage();
            System.debug('Exception :' + ex.getMessage());
        }	
    }

    public void DeleteItemListXML(String ItemID, String ListID) {
        getAccessToken(); // Generate new access token before calling bellow API
        
        if (AccessToken == null)
        {
            errorMessage = 'Error while generating token.';
            return;
        }

        try
        {
            HttpRequest objReq = new HttpRequest();
            objReq.setEndpoint(setting.ASI_MFM_API_End_Point__c + '/api/v3.0/common/listitems/' + ItemID + '?listId=' + ListID);
            objReq.setMethod('DELETE');
            objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
            objReq.setHeader('Accept', 'text/xml');
            objReq.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
            Http objHttp = new Http();
            HTTPResponse objRes = objHttp.send(objReq);
            System.debug(objRes.getStatusCode());
            System.debug(objRes.getBody());
            
            if (objRes.getStatusCode() >= 200 && objRes.getStatusCode() <= 299)
            {
                System.debug(objRes.getBody());
            }
            else
            {
                errorMessage = 'Fail to delete.';
                System.debug('Fail to delete.');
            }                     
        }
        catch(Exception ex)
        {
            errorMessage = ex.getMessage();
            System.debug('Exception :' + ex.getMessage());
        }
   }
   
//    public void getRefreshToken(String AccessToken) {
			
//    }
   
//    public List<String> getItemList(String ItemID) {
//         List<String> retList = new List<String>();
//         String HaveItemID ='';
        
//         if (ItemID !=''){
//             HaveItemID = '/' + ItemID;
//         }
//         else
//         {
//             HaveItemID ='';
//         }
        
//         getAccessToken(); // Generate new access token before calling bellow API
        
//         if (AccessToken == null )
//         {
//             errorMessage = 'Error while generating token.';
//             return retList;
//         }
//         try
//         {
//             HttpRequest objReq = new HttpRequest();
//             objReq.setEndpoint(setting.ASI_MFM_API_End_Point__c + '/api/v3.0/common/listitems'+ HaveItemID +'?limit=20');
//             objReq.setMethod('GET');
//             objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
//             objReq.setHeader('Accept', 'application/json');
//             Http objHttp = new Http();
//             HTTPResponse objRes = objHttp.send(objReq);
//             if (objRes.getStatusCode() == 200) {
//                 Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(objRes.getBody());
//                 List<Object> items = (List<Object>) results.get('Items');
//                 Integer cnt =0;
//                 for (Object ListItem: items) {
//                     // System.debug(ListItem);
//                     Map<String, Object> obj = (Map<String, Object>)ListItem;
//                     System.debug('----cnt :'+cnt);
//                     cnt = cnt + 1;

//                     String listItemID = (String)obj.get('ID');
//                     retList.add(listItemID);
//                 }
//             }
//             else
//             {
//                 System.debug('Connection Error');
//             }            
//         }
//         catch(Exception ex)
//         { 
//             errorMessage = ex.getMessage();
//             System.debug('Exception :' + ex.getMessage());
//         }
            
//         return retList;
//    }
    
//    public void POSTItemList(String POSTData) {
//        getAccessToken(); // Generate new access token before calling bellow API
//        if(AccessToken == null ) {
//             errorMessage = 'Error while generating token.';
//             return;
//         }
//         try{
//             HttpRequest objReq = new HttpRequest();
//             objReq.setEndpoint('https://eu1imp.concursolutions.com/api/v3.0/common/listitems');
//             objReq.setMethod('POST');
//             objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
//             objReq.setHeader('Accept', 'application/json');
//             objReq.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
//             //objReq.setBody('{"listId" : "gWhZKeVQIlyJ5gbjaLu$sIE4Z7AcTqDXe$pNA", "name": "TestK","level1Code" :"TestK"}');
//             objReq.setBody(POSTData);
//             Http objHttp = new Http();
//             HTTPResponse objRes = objHttp.send(objReq);
//             System.debug(objRes.getStatusCode());
//             System.debug(objRes.getBody());
            
//             if (objRes.getStatusCode() == 200) {
//                 System.debug(objRes.getBody());
//             }else
//             {
//                 System.debug('Fail to create.');
//             }                     
//          }
//          catch(Exception ex)
//          {  errorMessage = ex.getMessage();
//             System.debug('Exception :' + ex.getMessage());
//          }		
//    }
    
//    public void PUTItemList(String ItemID, String PUTData) {
// 	getAccessToken(); // Generate new access token before calling bellow API
//        if(AccessToken == null ) {
//             errorMessage = 'Error while generating token.';
//             return;
//         }
//         try{
//             HttpRequest objReq = new HttpRequest();
//             objReq.setEndpoint('https://eu1imp.concursolutions.com/api/v3.0/common/listitems/'+ItemID);
//             objReq.setMethod('PUT');
//             objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
//             objReq.setHeader('Accept', 'application/json');
//             objReq.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
//             //objReq.setBody('{"listId" : "gWhZKeVQIlyJ5gbjaLu$sIE4Z7AcTqDXe$pNA", "name": "TestKoyuki","level1Code" :"TestKoyuki"}');
//             objReq.setBody(PUTData);
//             Http objHttp = new Http();
//             HTTPResponse objRes = objHttp.send(objReq);
//             System.debug(objRes.getStatusCode());
//             System.debug(objRes.getBody());
            
//             if (objRes.getStatusCode() == 200) {
//                 System.debug(objRes.getBody());
//             }else
//             {
//                 System.debug('Fail to update.');
//             }                     
//          }
//          catch(Exception ex)
//          {  errorMessage = ex.getMessage();
//             System.debug('Exception :' + ex.getMessage());
//          }	
//    }
   
// 	public void DeleteItemList(String ItemID, String ListID) {
// 		getAccessToken(); // Generate new access token before calling bellow API
//        if(AccessToken == null ) {
//             errorMessage = 'Error while generating token.';
//             return;
//         }
//         try{
//             HttpRequest objReq = new HttpRequest();
//             objReq.setEndpoint('https://eu1imp.concursolutions.com/api/v3.0/common/listitems/'+ItemID+'?listId='+ListID);
//             objReq.setMethod('DELETE');
//             objReq.setHeader('Authorization', 'Bearer ' + AccessToken);
//             objReq.setHeader('Accept', 'application/json');
//             objReq.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
//             Http objHttp = new Http();
//             HTTPResponse objRes = objHttp.send(objReq);
//             System.debug(objRes.getStatusCode());
//             System.debug(objRes.getBody());
            
//             if (objRes.getStatusCode() == 204) {
//                 System.debug(objRes.getBody());
//             }else
//             {
//                 System.debug('Fail to delete.');
//             }                     
//          }
//          catch(Exception ex)
//          {  errorMessage = ex.getMessage();
//             System.debug('Exception :' + ex.getMessage());
//          }	
			
//    }
}