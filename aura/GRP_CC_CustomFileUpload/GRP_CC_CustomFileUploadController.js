({
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        const uploadedFiles = event.getParam("files");
        const documentIds = [];
        const ecran = component.get("v.ecran");
        for (let fileUpload of uploadedFiles) {
            documentIds.push(fileUpload.documentId);
        }
        component.set("v.documentIds", documentIds);
        const action = component.get("c.renameFiles");
        action.setParams({
            idFiles: documentIds,
            prefix: ecran
        });
        action.setCallback(this, function(response) {
            console.log('state upload ID file : ')
            var state = response.getState();

            console.log(state)
            if (state === "SUCCESS") {
                console.log("SUCCESS");

            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);

        const appEvent = $A.get("e.c:GRP_CC_LE_updateFileUpload");
        appEvent.setParams({
            "idDocuments" : documentIds,
            "apiName":  ecran
        });

        appEvent.fire();
    }
})