/*********************************************************************************
* Name:ASI_eForm_HK_CustomerFormAPI
*Test class: 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 01/06/2020       PRA COE                  Created
*********************************************************************************/

@RestResource(urlMapping='/ASI_eForm_HK_eFormAPI/*')
global class ASI_eForm_HK_CustomerFormAPI {
  @HttpPatch
    global static string InsertContentVersion(){
        string str = 'OK';
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestBody = body.toString();
        string requestURIStr = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        string[] splitted = requestURIStr.split(':');
        
        String base64Data = EncodingUtil.urlDecode(requestBody, 'UTF-8');
        
        string titlestr = splitted[1].replaceAll('%20',' ');
        
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = titlestr;
        cv.PathOnClient = '/' + titlestr;
        cv.FirstPublishLocationId = splitted[0];
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        
        
        return str;
    }
}