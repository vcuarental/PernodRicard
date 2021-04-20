@isTest
global class ESN_BP_MockHttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getBody().contains('refresh_token') && req.getBody().contains('%3D'))
            res.setBody('{"error":"invalid_client_credentials","error_description":"client secret invalid"}');
        else if (req.getBody().contains('refresh_token'))
            res.setBody('{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P","issued_at":"1278448384422","instance_url":"https://na1.salesforce.com","signature":"SSSbLO/gBhmmyNUvN18ODBDFYHzakxOMgqYtu+hDPsc=","access_token":"00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4","token_type":"Bearer","scope":"id api refresh_token"}');
        else if (req.getBody().contains('%3D'))
            res.setBody('{"error":"authentication_failure","error_description":"invalid password"}');
        else
            res.setBody('{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P","issued_at":"1278448101416","refresh_token":"5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZebnUG0h6Sb4KUVDpNtWEofWM39yg==","instance_url":"https://na1.salesforce.com","signature":"CMJ4l+CCaPQiKjoOEwEig9H4wqhpuLSk4J2urAe+fVg=","access_token":"00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4","token_type":"Bearer","scope":"id api refresh_token"}');
        res.setStatusCode(200);
        return res;
    }
}