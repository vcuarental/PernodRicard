({
     queryHomeImageList : function(component) {

        var action = component.get("c.getHomeImageList");
        
         action.setCallback(this, function(response){
            var state = response.getState();
            var showImage = [];
            if(state === 'SUCCESS'){
                var rows = response.getReturnValue();
                for (var i in rows) {
                    if (rows[i].Attachments) {
                        var attfile = rows[i].Attachments;
                        for (var j in attfile) {
                        var imageObj = [];
                        imageObj['AttFile'] = "/PRCVendor/servlet/servlet.FileDownload?file=" + rows[i].Attachments[j].Id;
                        showImage.push(imageObj);
                      }
                    }
                }
                component.set('v.imageList', showImage);
            }else{
                console.log('error getHomeImageList');
            }
        });
        $A.enqueueAction(action);

    },
})